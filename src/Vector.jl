"""
    AMGXVector(resources::Resources, mode::Mode)

A dense vector living wherever `mode` says — on the device for the `d*` modes.

Created empty; fill it with [`upload!`](@ref) or [`set_zero!`](@ref), and read it
back with `Vector`, `Array`, `CuVector` or `copy!`.

```julia
v = AMGX.AMGXVector(resources, AMGX.dDDI)
AMGX.upload!(v, [1.0, 2.0, 3.0])
Vector(v)
```

Must be freed with `close` before the [`Resources`](@ref) it was created from.
"""
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

"""
    upload!(v::AMGXVector, data; block_dim=1)

Copy `data` into `v`. `data` may be a `Vector` on the host or a `CuVector`
already on the device, and its element type must match the precision of the
vector's [`Mode`](@ref).

`block_dim` gives the block size for block systems; `length(data)` must be an
exact multiple of it, and the resulting vector has `length(data) ÷ block_dim`
block rows.
"""
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

"""
    download(v::AMGXVector)

Copy `v` back to a newly allocated host `Vector` of the mode's element type.

`Vector(v)` and `Array(v)` are equivalent; `CuVector(v)` downloads to the device
instead.
"""
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
"""
    download!(buffer, v::AMGXVector)
    copy!(buffer, v::AMGXVector)

Copy `v` into an existing `buffer`, avoiding an allocation. `buffer` may live on
the host or the device, and `length(buffer)` must equal `length(v)`.
"""
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
"""
    length(v::AMGXVector)

Total number of scalar entries, i.e. block rows times block dimension.
"""
Base.length(v::AMGXVector) = prod(vector_get_size(v))


"""
    set_zero!(v::AMGXVector, n=length(v); block_dim=1)

Resize `v` to `n` block rows of size `block_dim` and fill it with zeros. Useful
for the solution vector before a [`solve!`](@ref), which needs a vector of the
right size to write into.
"""
function set_zero!(v::AMGXVector, n::Int=vector_get_size(v)[1]; block_dim=vector_get_size(v)[2])
    @checked API.AMGX_vector_set_zero(v.handle, Cint(n), Cint(block_dim))
    return v
end
