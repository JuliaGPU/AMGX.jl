# Store size in matrix


function upload!(row_ptrs, col_indices, data, block_dims=(1,1))
    
end

function upload!(matrix::CuSparseMatrixCSR)
end

function replace_coefficients!(matrix::AMGXMatrix, 

end

function get_size(matrix::AMGXMatrix)
    n_ptr, block_dim_x_ptr, block_dim_y_ptr = Ref{Cint}(), Ref{Cint}(), Ref{Cint}()
    @checked API.AMGX_matrix_size(matrix.handle, n_ptr, block_dim_x_ptr, block_dim_y_ptr)
    return Int(n_ptr[]), (Int(block_dim_x_ptr[]), Int(block_dim_y_ptr[]))
end


