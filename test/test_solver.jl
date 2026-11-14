module TestSolver

using AMGX, Defer, Test, CUDA, SparseArrays
using AMGX: Config, Resources, AMGXVector, AMGXMatrix, Solver, dDDI, dFFI

@scope @testset "Solver" begin
    mode = dDDI

    @scope @testset "solver defaults" begin
        c = @! Config("")
        r = @! Resources(c)
        M = @! AMGXMatrix(r, mode)
        x = @! AMGXVector(r, mode)
        b = @! AMGXVector(r, mode)
        s = @! Solver(r, mode, c)

        AMGX.upload!(M, Cint[0, 1, 2, 3], Cint[0, 1, 2], [1.0, 1.0, 1.0])
        AMGX.upload!(x, [0.0, 0.0, 0.0])
        AMGX.upload!(b, [1.0, 2.0, 4.0])

        AMGX.setup!(s, M)
        AMGX.solve!(x, s, b)
        x_h = AMGX.download(b)
        @test x_h ≈ [1.0, 2.0, 4.0]

        AMGX.upload!(x, [1.0, 2.0, 3.0])
        AMGX.solve!(x, s, b; zero_inital_guess=true)
        x_h = AMGX.download(x)
        @test x_h ≈ [1.0, 2.0, 4.0]

        # We can reuse the same sparsity structure, but change the coefficients
        AMGX.replace_coefficients!(M, [0.1, 0.1, 0.1])
        AMGX.resetup!(s, M)
        AMGX.solve!(x, s, b)
        x_h2 = AMGX.download(x)
        @test x_h2 ≈ [10.0, 20.0, 40.0]
    end

    @scope @testset "solver with residuals" begin
        # Same test as above, but this time output residuals.
        c = @! Config(Dict("monitor_residual" => 1))
        r = @! Resources(c)
        M = @! AMGXMatrix(r, mode)
        x = @! AMGXVector(r, mode)
        b = @! AMGXVector(r, mode)
        s = @! Solver(r, mode, c)

        AMGX.upload!(M, Cint[0, 1, 2, 3], Cint[0, 1, 2], [1.0, 1.0, 1.0])
        AMGX.upload!(x, [0.0, 0.0, 0.0])
        AMGX.upload!(b, [1.0, 2.0, 4.0])

        AMGX.setup!(s, M)
        AMGX.solve!(x, s, b)
        x_h = AMGX.download(b)
        @test x_h ≈ [1.0, 2.0, 4.0]
        status = AMGX.get_status(s)
        # Note: If we don't set monitor_residual, the status flag does not
        # reflect if the solution has converged or not.
        @test status == AMGX.SUCCESS

        AMGX.upload!(x, [1.0, 2.0, 3.0])
        AMGX.solve!(x, s, b; zero_inital_guess=true)
        x_h = AMGX.download(x)
        @test x_h ≈ [1.0, 2.0, 4.0]
        status = AMGX.get_status(s)
        @test status == AMGX.SUCCESS
    end

    @scope @testset "get_status / get_iterations_number" begin
        c = @! Config(Dict("monitor_residual" => 1, "max_iters" => 0, "store_res_history" => 1))
        r = @! Resources(c)
        M = @! AMGXMatrix(r, mode)
        x = @! AMGXVector(r, mode)
        b = @! AMGXVector(r, mode)
        s = @! Solver(r, mode, c)

        AMGX.upload!(M, Cint[0, 1, 2, 3], Cint[0, 1, 2], [1.0, 1.0, 1.0])
        AMGX.upload!(x, [0.0, 0.0, 0.0])
        AMGX.upload!(b, [1.0, 2.0, 4.0])
        AMGX.setup!(s, M)
        AMGX.solve!(x, s, b; zero_inital_guess=true)
        @test AMGX.get_status(s) == AMGX.NOT_CONVERGED
        @test AMGX.get_iterations_number(s) == 0
        @test AMGX.get_iteration_residual(s) > 1.0

        # the solver keeps its matrix alive
        close(M)
        AMGX.solve!(x, s, b; zero_inital_guess=true)
        @test AMGX.get_status(s) == AMGX.NOT_CONVERGED

        s2 = @! Solver(r, mode, c)
        @test_throws ErrorException AMGX.solve!(x, s2, b)
    end

    @scope @testset "get_iterations_number" begin
        c = @! Config(Dict("monitor_residual" => 1, "tolerance" => "1e-14", "store_res_history" => 1))
        r = @! Resources(c)
        M = @! AMGXMatrix(r, mode)
        x = @! AMGXVector(r, mode)
        b = @! AMGXVector(r, mode)
        s = @! Solver(r, mode, c)

        AMGX.upload!(M, Cint[0, 1, 2, 3], Cint[0, 1, 2], [1.0, 1.0, 1.0])
        AMGX.upload!(x, [0.0, 0.0, 0.0])
        AMGX.upload!(b, [1.0, 2.0, 4.0])
        AMGX.setup!(s, M)
        AMGX.solve!(x, s, b)
        niter = AMGX.get_iterations_number(s)
        @test niter > 0
        @test AMGX.get_iteration_residual(s) < 1e-14
        @test AMGX.get_iteration_residual(s, niter) == AMGX.get_iteration_residual(s)
    end

    # AMGX's solve with a zero initial guess assumes `sol` already holds n
    # zeros (NVIDIA/AMGX#80): reusing `sol` returned its old contents plus
    # A \ rhs, and an unsized `sol` was an illegal memory access.
    n = 50
    A = spdiagm(-1 => fill(-1.0, n - 1), 0 => fill(2.0, n), 1 => fill(-1.0, n - 1))
    pcg = "config_version=2, solver(s)=PCG, s:max_iters=1000, s:tolerance=1e-12, " *
          "s:convergence=RELATIVE_INI_CORE, s:monitor_residual=1, s:preconditioner=NOSOLVER"
    rhs(k) = (b = zeros(n); b[1] = -1.0; b[n - k] = 1.0; b)

    @scope @testset "zero initial guess with a reused sol" begin
        c = @! Config(pcg)
        r = @! Resources(c)
        M = @! AMGXMatrix(r, mode)
        x = @! AMGXVector(r, mode)
        b = @! AMGXVector(r, mode)
        s = @! Solver(r, mode, c)

        # A is symmetric, so its CSC arrays are its CSR arrays.
        AMGX.upload!(M, Cint.(A.colptr .- 1), Cint.(A.rowval .- 1), A.nzval)
        AMGX.setup!(s, M)
        AMGX.upload!(x, ones(n))
        for k in 1:3
            AMGX.upload!(b, rhs(k))
            AMGX.solve!(x, s, b; zero_inital_guess=true)
            @test AMGX.get_status(s) == AMGX.SUCCESS
            @test AMGX.download(x) ≈ A \ rhs(k)
        end
    end

    @scope @testset "zero initial guess with an unsized sol" begin
        c = @! Config(pcg)
        r = @! Resources(c)
        M = @! AMGXMatrix(r, mode)
        x = @! AMGXVector(r, mode)
        b = @! AMGXVector(r, mode)
        s = @! Solver(r, mode, c)

        AMGX.upload!(M, Cint.(A.colptr .- 1), Cint.(A.rowval .- 1), A.nzval)
        AMGX.setup!(s, M)
        AMGX.upload!(b, rhs(1))
        AMGX.solve!(x, s, b; zero_inital_guess=true)
        @test AMGX.get_status(s) == AMGX.SUCCESS
        @test AMGX.download(x) ≈ A \ rhs(1)
    end
end

end # module
