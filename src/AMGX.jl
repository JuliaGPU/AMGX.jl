module AMGX

# API docs:
# https://raw.githubusercontent.com/NVIDIA/AMGX/main/doc/AMGX_Reference.pdf

# Ownership hierarchy
#                    +----> Vector
#                    |
#                    +
# Config +-----> Resources+----------------+
#                    +                     |
#                    |                     v
#                    +----> Matrix +---> Solver

using Libdl 
using CUDA
using LinearAlgebra
using SparseArrays
using AMGX_jll

libAMGX = ""

set_libAMGX_path(s::String) = (global libAMGX = s)

function __init__()
    # `JULIA_AMGX_PATH` points at a locally built AMGX and has to take effect
    # even when the JLL provides nothing for this platform -- that is precisely
    # when it is needed, e.g. when no artifact exists for the installed CUDA.
    amgx_path = get(ENV, "JULIA_AMGX_PATH", nothing)
    if amgx_path !== nothing
        set_libAMGX_path(amgx_path)
    elseif AMGX_jll.is_available()
        set_libAMGX_path(AMGX_jll.libamgxsh)
    end
end

#########
# C API #
#########

module API
    using CEnum
    import ..libAMGX

    libdir = joinpath(@__DIR__, "..", "lib")
    include(joinpath(libdir, "libamgx.jl"))
end

include("errors.jl")

##############
# AMGXObject #
##############

# All AMGXObjects have the fields
#   handle::Ptr      -- the AMGX handle, C_NULL once destroyed
#   ref_count::Int   -- number of live objects that depend on this one
#   closed::Bool     -- released by `close` or the GC; destroyed once `ref_count` is 0
#   session::Int     -- the `initialize` session the handle belongs to
# and implement `get_api_destroy_call` and `release_parents!`.
#
# Finalizers cannot call into AMGX: they may run on any thread, concurrently
# with other AMGX calls, after the library was finalized, and in no particular
# order relative to the objects they depend on. They instead queue the object,
# and the queue is drained from regular code (see `drain_pending!`).
abstract type AMGXObject end

const SESSION = Ref(0)
const INITIALIZED = Ref(false)

# Destroying resources frees a device memory pool that AMGX shares between all
# resources, corrupting vectors, matrices and solvers that are still alive --
# even ones belonging to other resources. Resources are therefore only
# destroyed once no such objects exist.
const LIVE_DATA = Ref(0)
const DEFERRED_RESOURCES = AMGXObject[]
holds_device_data(::AMGXObject) = false

const PENDING = AMGXObject[]
const PENDING_LOCK = Threads.SpinLock() # disables finalizers while held

function enqueue_finalized(x::AMGXObject)
    x.handle == C_NULL && return
    @lock PENDING_LOCK push!(PENDING, x)
    return
end

function drain_pending!()
    objects = @lock PENDING_LOCK splice!(PENDING, eachindex(PENDING))
    for x in objects
        x.closed = true
    end
    for x in objects
        try
            try_destroy!(x)
        catch err
            @warn "AMGX: failed to destroy a garbage collected `$(typeof(x))`" exception=err
        end
    end
    return
end

function set_handle!(x::AMGXObject, handle)
    x.handle = handle
    x.session = SESSION[]
    holds_device_data(x) && (LIVE_DATA[] += 1)
    return x
end

# Destroy `x` if it is released and nothing depends on it anymore. Handles from
# an earlier `initialize` session are dropped without calling into AMGX.
function try_destroy!(x::AMGXObject)
    (x.closed && x.ref_count == 0 && x.handle != C_NULL) || return
    if INITIALIZED[] && x.session == SESSION[]
        if x isa Resources && LIVE_DATA[] > 0
            any(y -> y === x, DEFERRED_RESOURCES) || push!(DEFERRED_RESOURCES, x)
            return
        end
        destroy = get_api_destroy_call(typeof(x))
        @checked destroy(x.handle)
        holds_device_data(x) && (LIVE_DATA[] -= 1)
    end
    x.handle = C_NULL
    release_parents!(x)
    if LIVE_DATA[] == 0 && !isempty(DEFERRED_RESOURCES)
        foreach(try_destroy!, splice!(DEFERRED_RESOURCES, eachindex(DEFERRED_RESOURCES)))
    end
    return
end

retain!(x::AMGXObject) = (x.ref_count += 1; x)
function release!(x::AMGXObject)
    x.ref_count -= 1
    try_destroy!(x)
end
release!(::Nothing) = nothing

"""
    close(object)

Release an AMGX object — a [`Config`](@ref), [`Resources`](@ref),
[`AMGXVector`](@ref), [`AMGXMatrix`](@ref) or [`Solver`](@ref).

Objects are released automatically when garbage collected, so calling `close`
is optional. It frees the GPU memory held by the object right away, which the
garbage collector does not know about.

Closing can happen in any order: an object that others still depend on, like
`Resources` with live vectors, is destroyed once the last of them is. A closed
object can no longer be used.
"""
function Base.close(x::AMGXObject)
    drain_pending!()
    x.closed = true
    try_destroy!(x)
    return
end

function check_open(x::AMGXObject)
    x.closed && throw(ArgumentError("`$(typeof(x))` has been closed"))
    x.handle == C_NULL && throw(ArgumentError("`$(typeof(x))` has not been created"))
    return x
end

function Base.show(io::IO, ::MIME"text/plain", object::AMGXObject)
    state = object.closed ? "closed" :
            object.handle == C_NULL ? "uninitialized" :
            "@" * sprint(show, UInt(object.handle))
    print(io, typeof(object), " ", state)
    isopen(object) || return
    if hasfield(typeof(object), :mode)
        print(io, " ", object.mode)
    end
end
Base.isopen(x::AMGXObject) = !x.closed && x.handle != C_NULL


############
# Includes #
############

# Supported vector types
const VectorOrCuVector{T} = Union{Vector{T}, CuVector{T}}
# TODO: We currently reinterpret CuPtr to Ptr when calling the API. Better would be
# to add support for CuPtr directly in the ccall wrappers.
const PtrOrCuPtrUnion{T} = Union{Ptr{T}, CuPtr{T}}

include("utilities.jl")
include("Mode.jl")
include("Config.jl")
include("Resources.jl")
include("Vector.jl")
include("Matrix.jl")
include("Solver.jl")
include("Preconditioner.jl")

# Passing the object itself to the C API, rather than its `handle`, keeps it
# from being collected during the call.
for (T, H) in ((:Config, :AMGX_config_handle), (:Resources, :AMGX_resources_handle),
               (:AMGXVector, :AMGX_vector_handle), (:AMGXMatrix, :AMGX_matrix_handle),
               (:Solver, :AMGX_solver_handle))
    @eval begin
        Base.cconvert(::Type{API.$H}, x::$T) = x
        Base.unsafe_convert(::Type{API.$H}, x::$T) = check_open(x).handle
    end
end

end # module
