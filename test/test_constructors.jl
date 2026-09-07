module TestConstructors

using AMGX, Test

@testset "Solver keyword constructor" begin
    default = AMGX.Solver()
    @test default.handle == C_NULL
    @test default.config === nothing
    @test default.mode === nothing

    mode_only = AMGX.Solver(mode=AMGX.dDDI)
    @test mode_only.mode === AMGX.dDDI
    @test mode_only.config === nothing

    config = AMGX.Config()
    config_only = AMGX.Solver(config=config)
    @test config_only.config === config
    @test config_only.mode === nothing

    resources = AMGX.Resources()
    matrix = AMGX.AMGXMatrix()
    solver = AMGX.Solver(resources=resources, config=config, mode=AMGX.dDFI,
                         bound_matrix=matrix)
    @test solver.handle == C_NULL
    @test solver.resources === resources
    @test solver.config === config
    @test solver.mode === AMGX.dDFI
    @test solver.bound_matrix === matrix
end

end # module
