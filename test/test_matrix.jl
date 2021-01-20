module TestMatrix

# TODO: Test `diag_dat` argument to `upload!` and `replace_coefficients!`

import ..repl_output
using AMGX, Defer, Test, JSON, CUDA, SparseArrays
using AMGX: Config, Resources, AMGXMatrix, dDDI, dFFI

@scope @testset "Matrix" begin
    c = @! Config("")
    r = @! Resources(c)
    m = @! AMGXMatrix(r, dDDI)
    @test occursin("dDDI", repl_output(m))

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

    @testset "upload CUDA sparse matrix" begin
        c = CUDA.CUSPARSE.CuSparseMatrixCSR(sprand(Float64, 10, 10, 0.5))
        AMGX.upload!(m, c)
        @test nnz(m) == nnz(c)
        @test size(m) == size(c)
    end
end

end # module
