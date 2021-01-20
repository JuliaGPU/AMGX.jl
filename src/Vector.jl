Base.@kwdef mutable struct AMGXVector <: AMGXObject
    handle::API.AMGX_vector_handle = API.AMGX_vector_handle(C_NULL)
    mode::Union{Mode, Nothing} = nothing
    resources::Union{Resources, Nothing} = nothing
    function AMGXVector(handle::API.AMGX_vector_handle, mode::Union{Mode, Nothing},
                       resources::Union{Resources, Nothing})
        v = new(handle, mode, resources)
        finalizer(warn_not_destroyed_on_finalize, v)
        return v
    end
end
function Base.show(io::IO, mime::MIME"text/plain", v::AMGXVector)
    invoke(show, Tuple{IO, MIME"text/plain", AMGXObject}, io, mime, v)
    v.handle == C_NULL && return
    n, block_dim = vector_get_size(v)
    if n !== 0
        if block_dim == 1
            print(io, " of length $n")
        else
            print(io, " of length $n⋅$block_dim")
        end
    end
end
get_api_destroy_call(::Type{AMGXVector}) = API.AMGX_vector_destroy
function dec_refcount_parents(v::AMGXVector)
    dec_refcount!(v.resources)
    v.resources = nothing
    nothing
end

function create!(v::AMGXVector, res::Resources, mode::Mode)
    vec_handle_ptr = Ref{API.AMGX_vector_handle}()
    amgx_mode = API.AMGX_Mode(Int(mode))
    @checked API.AMGX_vector_create(vec_handle_ptr, res.handle, amgx_mode)
    v.handle = vec_handle_ptr[]
    v.mode = mode
    v.resources = res
    inc_refcount!(v.resources)
    return v
end
AMGXVector(res::Resources, mode::Mode) = create!(AMGXVector(), res, mode)

function upload!(v::AMGXVector, data::VectorOrCuVector; block_dim::Int=1)
    n, rem = divrem(length(data), block_dim)
    if rem != 0
        throw(ArgumentError("vector length ($(length(data))) not an integer multiple of block dimension ($(block_dim))"))
    end
    GC.@preserve data begin
        upload_raw!(v, pointer(data), n, block_dim)
    end
    return v
end

function upload_raw!(v::AMGXVector, data::PtrOrCuPtrUnion{T}, n::Int, block_dim::Int=1) where T <: Union{Float64, Float32}
    # TODO: This should be handled in the ccall
    data = reinterpret(Ptr{T}, data)
    vT = vector_type(v.mode)
    if vT != T
        throw(ArgumentError("inconsistent AMGX vector mode ($vT) with element type of upload ($T)"))
    end
    @checked API.AMGX_vector_upload(v.handle, n, block_dim, data)
    return v
end

function download(v::AMGXVector) 
    vT = vector_type(v.mode)
    buffer = Vector{vT}(undef, length(v))
    download!(buffer, v)
    return buffer
end
Base.Vector(v::AMGXVector) = download(v)
Base.Array(v::AMGXVector) = download(v)
CUDA.CuArray(v::AMGXVector) = CUDA.CuVector(v)
function CUDA.CuVector(v::AMGXVector)
    vT = vector_type(v.mode)
    buffer = CUDA.CuVector{vT}(undef, length(v))
    download!(buffer, v)
    return buffer
end
function download!(buffer::VectorOrCuVector, v::AMGXVector)
    m, n = length(buffer), length(v)
    if length(buffer) !== n
        throw(ArgumentError("invalid buffer length, got $m, expected $n"))
    end
    GC.@preserve buffer begin
        download_raw(pointer(buffer), v)
    end
    return buffer
end
Base.copy!(buffer::VectorOrCuVector, v::AMGXVector) = download!(buffer, v)

function download_raw(ptr::PtrOrCuPtrUnion{T}, v::AMGXVector) where T <: Union{Float64, Float32}
    # TODO: This should be handled in the ccall
    ptr = reinterpret(Ptr{T}, ptr)
    vT = vector_type(v.mode)
    if vT != T
        throw(ArgumentError("inconsistent AMGX vector mode ($vT) with element type of download ($T)"))
    end
    @checked API.AMGX_vector_download(v.handle, ptr)
end

function vector_get_size(v::AMGXVector)
    n_ptr, block_dim_ptr = Ref{Cint}(), Ref{Cint}()
    @checked API.AMGX_vector_get_size(v.handle, n_ptr, block_dim_ptr)
    return Int(n_ptr[]), Int(block_dim_ptr[])
end
Base.length(v::AMGXVector) = prod(vector_get_size(v))


function set_zero!(v::AMGXVector, n::Int=vector_get_size(v)[1]; block_dim=vector_get_size(v)[2])
    @checked API.AMGX_vector_set_zero(v.handle, Cint(n), Cint(block_dim))
    return v
end
