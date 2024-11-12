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
using JSON
using SparseArrays
using AMGX_jll

libAMGX = ""

set_libAMGX_path(s::String) = (global libAMGX = s)

function __init__()
    if AMGX.AMGX_jll.is_available()
        amgx_dir = get(ENV, "JULIA_AMGX_PATH", nothing)
        if amgx_dir !== nothing
            set_libAMGX_path(amgx_dir)
        else
            set_libAMGX_path(AMGX_jll.libamgxsh)
        end
    end
end

#########
# C API #
#########

module API
    using CEnum
    import ..libAMGX

    libdir = joinpath(@__DIR__, "..", "lib")
    include(joinpath(libdir, "libAMGX_common.jl"))
    include(joinpath(libdir, "libAMGX.jl"))
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
function Base.close(object::T) where T <: AMGXObject
    object.handle == C_NULL && return
    if hasfield(T, :ref_count)
        refs = object.ref_count[]
        if refs != 0
            throw(RefCountError(T, refs))
        end
    end
    dec_refcount_parents(object)
    destroy = get_api_destroy_call(T)
    @checked destroy(object.handle)
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

end # module
