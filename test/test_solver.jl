module TestSolver

using AMGX, Defer, Test, JSON, CUDA, SparseArrays
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
        status = AMGX.get_status(s)
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
        @test AMGX.get_status(s) == AMGX.DIVERGED

        # Need a proper way to test for build version
        if AMGX.build_info()[1] != "2.2.0.132-opensource"
            @test AMGX.get_iterations_number(s) == 0
            @test AMGX.get_iteration_residual(s) > 1.0
        else
            @test AMGX.get_iterations_number(s) == -1
            @test_throws AMGX.AMGXException("Incorrect parameters for amgx call.") AMGX.get_iteration_residual(s)
        end

        close(M)
        @test_throws ErrorException AMGX.solve!(x, s, b; zero_inital_guess=true)
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
        @show niter = AMGX.get_iterations_number(s)
        @test AMGX.get_iteration_residual(s) < 1e-14
        @show niter = AMGX.get_iterations_number(s)
        @test AMGX.get_iteration_residual(s, niter) == AMGX.get_iteration_residual(s)
    end
end

end # module

