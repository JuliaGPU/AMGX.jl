module TestPreconditioner

using AMGX, Defer, Test, CUDA, SparseArrays, LinearAlgebra
using AMGX: Config, Resources, AMGXMatrix, Solver, dDDI, aspreconditioner

@scope @testset "Preconditioner" begin
    cfg = @! Config(Dict("monitor_residual" => 1, "max_iters" => 50, "store_res_history" => 1))
    res = @! Resources(cfg)

    A = sparse([1, 1, 2, 2, 3, 3], [1, 2, 2, 3, 1, 3],
               [4.0, 1.0, 4.0, 1.0, 1.0, 4.0], 3, 3)
    b = [1.0, 2.0, 3.0]

    m = @! AMGXMatrix(res, dDDI)
    AMGX.upload!(m, CUDA.CUSPARSE.CuSparseMatrixCSR(A))

    s = @! Solver(res, dDDI, cfg)
    AMGX.setup!(s, m)

    p = aspreconditioner(s)
    try
        @test size(p) == (3, 3)
        @test eltype(p) == Float64

        y = similar(b)
        ldiv!(y, p, b)
        @test A * y ≈ b

        @test A * (p \ b) ≈ b

        # the same, with data already on the device
        b_cu = CuVector(b)
        y_cu = similar(b_cu)
        ldiv!(y_cu, p, b_cu)
        @test A * Vector(y_cu) ≈ b

        @test_throws DimensionMismatch ldiv!(similar(b), p, [1.0, 2.0])

        # new coefficients, same sparsity: `update!` rather than a new hierarchy
        new_values = [8.0, 1.0, 8.0, 1.0, 1.0, 8.0]
        AMGX.replace_coefficients!(m, new_values)
        AMGX.update!(p)
        A2 = sparse([1, 1, 2, 2, 3, 3], [1, 2, 2, 3, 1, 3], new_values, 3, 3)
        ldiv!(y, p, b)
        @test A2 * y ≈ b
    finally
        close(p)
    end

    # a solver with no matrix bound cannot be wrapped
    s2 = @! Solver(res, dDDI, cfg)
    @test_throws ArgumentError aspreconditioner(s2)
end

end # module
