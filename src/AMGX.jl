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

# All AMGXObject have a `handle` field
abstract type AMGXObject end

struct RefCountError <: Exception
    typ::DataType
    n::Int
end
Base.showerror(io::IO, err::RefCountError) =
    print(io, "an AMGXObject of type `$(err.typ)` was attempted to be closed with a non-zero ref count ($(err.n))")
"""
    close(object)

Destroy an AMGX object — a [`Config`](@ref), [`Resources`](@ref),
[`AMGXVector`](@ref), [`AMGXMatrix`](@ref) or [`Solver`](@ref).

AMGX objects are not garbage collected, so each must be closed explicitly.
Ordering matters: an object cannot be closed while others created from it are
still alive, and doing so raises a `RefCountError`. [Defer.jl](https://github.com/adambrewster/Defer.jl)
makes this considerably less tedious.
"""
function Base.close(object::T) where T <: AMGXObject
    object.handle == C_NULL && return
    if hasfield(T, :ref_count)
        refs = object.ref_count[]
        if refs != 0
            throw(RefCountError(T, refs))
        end
    end
    destroy = get_api_destroy_call(T)
    @checked destroy(object.handle)
    dec_refcount_parents(object)
    object.handle = C_NULL
    return
end

inc_refcount!(x::AMGXObject) = x.ref_count[] += 1
dec_refcount!(x::AMGXObject) = x.ref_count[] -= 1

function warn_not_destroyed_on_finalize(x::AMGXObject)
    !(x.handle == C_NULL) && @async @warn("AMGX: likely memory leak: a `$(typeof(x))` was finalized without having been `close`d")
end

function Base.show(io::IO, ::MIME"text/plain", object::AMGXObject)
    ptr_str = object.handle == C_NULL ? "uninitialized" : "@" * sprint(show, UInt(object.handle))
    print(io, typeof(object), " ", ptr_str)
    object.handle == C_NULL && return
    if hasfield(typeof(object), :mode)
        print(io, " ", object.mode)
    end
end


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

end # module
