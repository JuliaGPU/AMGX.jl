# TODO: Add support for uploading a CuSparseMatrixBSR

Base.@kwdef mutable struct AMGXMatrix <: AMGXObject
    handle::API.AMGX_matrix_handle = C_NULL
    mode::Union{Mode, Nothing} = nothing
    resources::Union{Resources, Nothing} = nothing
end
get_api_destroy_call(::Type{AMGXMatrix}) = API.AMGX_matrix_destroy
function dec_refcount_parents(m::AMGXMatrix)
    dec_refcount!(m.resources)
    m.resources = nothing
    nothing
end

function create!(m::AMGXMatrix, res::Resources, mode::Mode)
    mat_handle_ptr = Ref{API.AMGX_matrix_handle}()
    amgx_mode = API.AMGX_Mode(Int(mode))
    @checked API.AMGX_matrix_create(mat_handle_ptr, res.handle, amgx_mode)
    m.handle = mat_handle_ptr[]
    m.mode = mode
    m.resources = res
    inc_refcount!(m.resources)
    return m
end
AMGXMatrix(res::Resources, mode::Mode) = create!(AMGXMatrix(), res, mode)

function upload!(m::AMGXMatrix, n::Int, nnz::Int, row_ptrs_ptr::PtrOrCuPtrUnion{Cint}, col_indices_ptr::PtrOrCuPtrUnion{Cint},
                 data_ptr::PtrOrCuPtrUnion{T}; block_dims::Tuple{Int, Int}=(1,1),
                 diag_data_ptr::PtrOrCuPtrUnion{T}=Ptr{T}(C_NULL)) where {T <: Union{Float64, Float32}}
    mT = matrix_type(m.mode)
    if mT != T
        throw(ArgumentError("inconsistent AMGX matrix mode ($mT) with element type of upload ($T)"))
    end
    # TODO the CuPtr conversions should be handled in the ccall
    diag_data_ptr = reinterpret(Ptr{T}, diag_data_ptr)
    col_indices_ptr = reinterpret(Ptr{Cint}, col_indices_ptr)
    data_ptr = reinterpret(Ptr{T}, data_ptr)
    row_ptrs_ptr = reinterpret(Ptr{Cint}, row_ptrs_ptr)
    block_dim_x, block_dim_y = block_dims
    @checked API. AMGX_matrix_upload_all(m.handle, n, nnz, block_dim_x, block_dim_y, row_ptrs_ptr,
                                            col_indices_ptr, data_ptr, diag_data_ptr)
    return m
end

# Note: Data within the block is assumed to be arranged in row-major scanline order.
function upload!(m::AMGXMatrix, row_ptrs::VectorOrCuVector{Cint}, col_indices::VectorOrCuVector{Cint},
                 data::VectorOrCuVector{T}; block_dims::Tuple{Int, Int}=(1,1),
                 diag_data::Union{VectorOrCuVector{T}, Nothing}=nothing) where {T <: Union{Float64, Float32}}
    nnz, rem = divrem(length(data), prod(block_dims))
    if rem != 0
        throw(ArgumentError("length of `data` ($length(data)) is not an integer multiple of block dimension size $block_dims"))
    end
    n = length(row_ptrs) - 1
    if nnz != length(col_indices)
        throw(ArgumentError("length of `data` ($(length(data))) is inconsistent with length of `row_ptrs` ($(length(row_ptrs))"))
    end
    # Disable this check if we have a CUArray since it does a scalar index (perhaps harmless here though)
    if row_ptrs isa Vector
        if row_ptrs[end] != nnz
            throw(ArgumentError("length of data ($(length(data)) is inconsitent with last element of `row_ptrs` ($(row_ptrs[end]))"))
        end
    end
    if diag_data !== nothing
        if length(diag_dat) != n * prod(block_dims)
            throw(ArgumentError("length of `diag_data` ($(length(diag_data))) is not equal to number of elements on diagonal"))
        end
    end
    GC.@preserve row_ptrs col_indices data diag_data begin
        diag_data_ptr = diag_data === nothing ? Ptr{T}(C_NULL) : pointer(diag_data)
        upload!(m, n, nnz, pointer(row_ptrs), pointer(col_indices), pointer(data); block_dims, diag_data_ptr)
    end
    return m
end

function upload!(matrix::AMGXMatrix, cu_matrix::CUDA.CUSPARSE.CuSparseMatrixCSR)
    upload!(matrix, cu_matrix.rowPtr, cu_matrix.colVal, cu_matrix.nzVal)
end

function get_size(matrix::AMGXMatrix)
    n_ptr, block_dim_x_ptr, block_dim_y_ptr = Ref{Cint}(), Ref{Cint}(), Ref{Cint}()
    @checked API.AMGX_matrix_get_size(matrix.handle, n_ptr, block_dim_x_ptr, block_dim_y_ptr)
    return Int(n_ptr[]), (Int(block_dim_x_ptr[]), Int(block_dim_y_ptr[]))
end
function Base.size(matrix::AMGXMatrix)
    n, block_dims = get_size(matrix)
    return n * block_dims[1], n * block_dims[2]
end

function replace_coefficients!(m::AMGXMatrix, data::VectorOrCuVector{T}, diag_data::Union{VectorOrCuVector{T}, Nothing}=nothing) where {T <: Union{Float64, Float32}}
    n, block_dims = get_size(m)
    _amgx_nnz = amgx_nnz(m)
    if length(data) != _amgx_nnz * prod(block_dims)
        throw(ArgumentError("can not change the number of nnz entries in `replace_coefficients!`"))
    end
    mT = matrix_type(m.mode)
    if mT != T
        throw(ArgumentError("inconsistent AMGX matrix mode ($mT) with element type of upload ($T)"))
    end
        GC.@preserve data diag_data begin
            diag_data_ptr = diag_data === nothing ? Ptr{T}(C_NULL) : pointer(diag_data)
            replace_coefficients!(m, n, _amgx_nnz, pointer(data), diag_data_ptr)
        end
    return m
end

function replace_coefficients!(m::AMGXMatrix, n::Int, nnz::Int, data_ptr::PtrOrCuPtrUnion{T},
                               diag_data_ptr::PtrOrCuPtrUnion{T}=Ptr{T}(C_NULL)) where {T <: Union{Float64, Float32}}
    # TODO the CuPtr conversions should be handled in the ccall
    data_ptr = reinterpret(Ptr{T}, data_ptr)
    diag_data_ptr = reinterpret(Ptr{T}, diag_data_ptr)
    @checked API.AMGX_matrix_replace_coefficients(m.handle, n, nnz, data_ptr, diag_data_ptr)
    return m
end

function amgx_nnz(matrix)
    nnz_ptr = Ref{Cint}()
    @checked API.AMGX_matrix_get_nnz(matrix.handle, nnz_ptr)
    return Int(nnz_ptr[])
end

function SparseArrays.nnz(matrix::AMGXMatrix)
    _, block_dims = get_size(matrix)
    return amgx_nnz(matrix) * prod(block_dims)
end
