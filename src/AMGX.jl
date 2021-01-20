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
    amgx_dir = get(ENV, "JULIA_AMGX_PATH", nothing)
    if amgx_dir !== nothing
        set_libAMGX_path(amgx_dir)
    else
        set_libAMGX_path(AMGX_jll.libamgxsh)
    end
end

#########
# C API #
#########

module API
    using Libdl
    # Taken from LLVM.jl, can be removed when package only supports 1.6 and higher
    macro runtime_ccall(target, args...)
        if VERSION >= v"1.6.0-DEV.819"
            quote
                ccall($(esc(target)), $(map(esc, args)...))
            end
        else
            # decode ccall function/library target
            Meta.isexpr(target, :tuple) || error("Expected (function_name, library) tuple")
            function_name, library = target.args

            # global const ref to hold the function pointer
            @gensym fptr_cache
            @eval __module__ begin
                # uses atomics (release store, acquire load) for thread safety.
                # see https://github.com/JuliaGPU/CUDAapi.jl/issues/106 for details
                const $fptr_cache = Threads.Atomic{UInt}(0)
            end

            quote
                # use a closure to hold the lookup and avoid code bloat in the caller
                @noinline function cache_fptr!()
                    library = Libdl.dlopen($(esc(library)))
                    $(esc(fptr_cache))[] = Libdl.dlsym(library, $(esc(function_name)))

                    $(esc(fptr_cache))[]
                end

                fptr = $(esc(fptr_cache))[]
                if fptr == 0        # folded into the null check performed by ccall
                    fptr = cache_fptr!()
                end

                ccall(reinterpret(Ptr{Cvoid}, fptr), $(map(esc, args)...))
            end
        end
    end

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
