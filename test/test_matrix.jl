module TestMatrix

import ..repl_output
using AMGX, Defer, Test, CUDA, SparseArrays
using AMGX: Config, Resources, AMGXMatrix, dDDI, dFFI

@scope @testset "Matrix" begin
    c = @! Config("")
    r = @! Resources(c)
    m = @! AMGXMatrix(r, dDDI)
    @test occursin("dDDI", repl_output(m))

    @scope @testset "mixed precision uploads" begin
        # AMGX's cuSPARSE solve path rejects mixed precision on CUDA >= 10.1.
        # Transfers still exercise the matrix/vector precision and buffer sizes.
        matrix = @! AMGXMatrix(r, AMGX.dDFI)
        vector = @! AMGX.AMGXVector(r, AMGX.dDFI)
        AMGX.upload!(matrix, Cint[0, 1, 2], Cint[0, 1], Float32[2, 4])
        AMGX.upload!(vector, Float64[6, 20])
        @test Vector(vector) == Float64[6, 20]
        @test_throws ArgumentError AMGX.upload!(vector, Float32[6, 20])
        @test_throws ArgumentError AMGX.upload!(matrix, Cint[0, 1, 2], Cint[0, 1], Float64[2, 4])
    end

    @testset "upload" begin
        AMGX.upload!(m, 
            Cint[0, 1, 3],
            Cint[1, 0, 1],
            [1.0, 2.0, 3.0]
        )
        @test nnz(m) == 3
        @test AMGX.matrix_get_size(m) == (2, (1,1))
        @test size(m) == (2, 2)
        @test occursin("of size 2×2 with 3 stored entries", repl_output(m))

        @testset "replace coefficients" begin
            # TODO: Should test this does something
            AMGX.replace_coefficients!(m, [2.0, 3.0, 4.0])
            @test_throws ArgumentError AMGX.replace_coefficients!(m, [2.0, 3.0, 4.0, 5.0])
            @test_throws ArgumentError AMGX.replace_coefficients!(m, Float32[2.0, 3.0, 4.0])
        end

        # Wrong element type
        m2 = @! AMGXMatrix(r, dFFI)
        @test_throws ArgumentError AMGX.upload!(m2, 
            Cint[0, 1, 3],
            Cint[1, 0, 1],
            [1.0, 2.0, 3.0]
        )
    end

    @testset "blocked upload" begin
        # blocked
        blocks = [[1.0 2.0; 3.0 4.0],
                  [5.0 6.0; 7.0 8.0],
                  [9.0 10.0; 11.0 12.0]]
        blocks_flatten = collect(Iterators.flatten(blocks))
        AMGX.upload!(m, 
            Cint[0, 1, 3],
            Cint[1, 0, 1],
            blocks_flatten;
            block_dims = (2,2)
        )
        @test AMGX.matrix_get_size(m) == (2, (2,2))
        @test size(m) == (4, 4)
        @test nnz(m) == 12
        @test occursin("of size 2⋅2×2⋅2 with 3 stored block entries", repl_output(m))

        @testset "replace coefficients" begin
            AMGX.replace_coefficients!(m, ones(Float64, length(blocks_flatten)))
            @test_throws ArgumentError AMGX.replace_coefficients!(m, ones(Float64, length(blocks_flatten)-1))
            @test_throws ArgumentError AMGX.replace_coefficients!(m, Float32.(blocks_flatten))
        end
    end

    @scope @testset "separate diagonal upload" begin
        for block_dim in (1, 2), storage in (identity, CuArray)
            matrix = @! AMGXMatrix(r, dDDI)
            x = @! AMGX.AMGXVector(r, dDDI)
            y = @! AMGX.AMGXVector(r, dDDI)
            block_dims = (block_dim, block_dim)
            # Two block rows with dense off-diagonal blocks of ones and
            # dense diagonal blocks of twos.
            data = storage(ones(2 * block_dim^2))
            diagonal = storage(fill(2.0, 2 * block_dim^2))
            rows, cols = storage(Cint[0, 1, 2]), storage(Cint[1, 0])
            @test AMGX.upload!(matrix, rows, cols, data; block_dims, diag_data=diagonal) === matrix
            @test_throws ArgumentError AMGX.upload!(matrix, rows, cols, data;
                block_dims, diag_data=storage(ones(2 * block_dim^2 - 1)))
            @test_throws ArgumentError AMGX.upload!(matrix, rows, cols, data;
                block_dims, diag_data=storage(ones(2 * block_dim^2 + 1)))

            values = collect(1.0:2 * block_dim)
            AMGX.upload!(x, values; block_dim)
            AMGX.set_zero!(y, 2; block_dim)
            AMGX.@checked AMGX.API.AMGX_matrix_vector_multiply(matrix.handle, x.handle, y.handle)
            first_sum, second_sum = sum(values[1:block_dim]), sum(values[block_dim+1:end])
            expected = vcat(fill(2 * first_sum + second_sum, block_dim),
                            fill(first_sum + 2 * second_sum, block_dim))
            @test Vector(y) ≈ expected

            @testset "replace separate diagonal" begin
                for count in (0, 2 * block_dim^2 - 1, 2 * block_dim^2 + 1)
                    @test_throws ArgumentError AMGX.replace_coefficients!(matrix, data, storage(ones(count)))
                end
                diagonal = storage(fill(3.0, 2 * block_dim^2))
                @test AMGX.replace_coefficients!(matrix, data, diagonal) === matrix
                AMGX.@checked AMGX.API.AMGX_matrix_vector_multiply(matrix.handle, x.handle, y.handle)
                expected = vcat(fill(3 * first_sum + second_sum, block_dim),
                                fill(first_sum + 3 * second_sum, block_dim))
                @test Vector(y) ≈ expected
            end
        end
    end

    @testset "upload rectangular" begin
        # rectangular
        AMGX.upload!(m, 
            Cint[0, 1, 3],
            Cint[1, 0, 2],
            [1.0, 2.0, 3.0]
        )
        @test nnz(m) == 3
    end

    @testset "wrong element type" begin
        @test_throws ArgumentError AMGX.upload!(m, 
            Cint[0, 1, 3],
            Cint[1, 0, 1],
            Float32[1.0, 2.0, 3.0]
        )
    end

    @scope @testset "upload device" begin
        AMGX.upload!(m, 
            CuArray(Cint[0, 1, 3]),
            CuArray(Cint[1, 0, 1]),
            CuArray([1.0, 2.0, 3.0])
        )
        @test nnz(m) == 3
    end

    @scope @testset "upload CUDA sparse matrix" begin
        host_matrix = sparse([4.0 1.0 0.0; 0.0 3.0 2.0; 1.0 0.0 5.0])
        c = CUDA.CUSPARSE.CuSparseMatrixCSR(host_matrix)
        row_ptrs, col_indices = Array(c.rowPtr), Array(c.colVal)
        AMGX.upload!(m, c)
        @test nnz(m) == nnz(c)
        @test size(m) == size(c)
        @test Array(c.rowPtr) == row_ptrs
        @test Array(c.colVal) == col_indices

        x = @! AMGX.AMGXVector(r, dDDI)
        y = @! AMGX.AMGXVector(r, dDDI)
        values = [1.0, 2.0, 3.0]
        AMGX.upload!(x, values)
        AMGX.set_zero!(y, 3)
        AMGX.@checked AMGX.API.AMGX_matrix_vector_multiply(m.handle, x.handle, y.handle)
        @test Vector(y) ≈ host_matrix * values
    end
end

end # module
