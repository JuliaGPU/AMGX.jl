mutable struct AMGXVector
    handle::API.AMGX_vector_handle
    res::Resources
    function AMGXVector(handle::API.AMGX_vector_handle, res::Resources)
        v = new(handle, res)
        res.ref_count[] += 1
        finalizer(destroy!, v)
    end
end

function destroy!(v::AMGXVector)
    @checked API.AMGX_vector_destroy(v.handle)
    v.handle = C_NULL
    v.res.ref_count[] -= 1
    return nothing
end

function AMGXVector(res::Resources; mode::Mode=dDDI)
    vec_handle_ptr = Ref{API.AMGX_vector_handle}()
    amgx_mode = API.AMGX_Mode(Int(mode))
    @checked API.AMGX_vector_create(vec_handle_ptr, res.handle, amgx_mode)
    return AMGXVector(vec_handle_ptr[], res)
end

# TODO: How is Float32 / Float64 handled?
function upload!(v::AMGXVector, data::Vector{Float64}, block_dim::Int=1) 
    n = length(data) ÷ block_dim
    GC.@preserve data begin
        upload_raw!(v, pointer(data), n, block_dim)
    end
    return v
end

function upload_raw!(v::AMGXVector, data::Ptr{Float64}, n::Int, block_dim::Int=1) 
    @checked API.AMGX_vector_upload(v.handle, n, block_dim, data)
    return v
end

function download(v::AMGXVector) 
    buffer = Vector{Float64}(undef, length(v))
    download!(buffer, v)
    return buffer
end

function download!(buffer::Vector{Float64}, v::AMGXVector) 
    m, n = length(buffer), length(v)
    if length(buffer) !== n
        error("invalid buffer length, got $m, expected $n")
    end
    GC.@preserve buffer begin
        download_raw(pointer(buffer), v)
    end
    return buffer
end

function download_raw(ptr::Ptr{Float64}, v::AMGXVector)
    @checked API.AMGX_vector_download(v.handle, ptr)
    return nothing
end

function vector_get_size(v::AMGXVector)
    n_ptr, block_dim_ptr = Ref{Int32}(), Ref{Int32}()
    @checked API.AMGX_vector_get_size(v.handle, n_ptr, block_dim_ptr)
    return Int(n_ptr[]), Int(block_dim_ptr[])
end

Base.length(v::AMGXVector) = vector_get_size(v)[1]

