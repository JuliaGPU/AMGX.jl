module TestConfig

import ..repl_output
using AMGX, Defer, Test
using AMGX: Config, AMGXException

@testset "Config" begin
    @scope @testset "Dict" begin
        cfg = @! Config()
        @test occursin("uninitialized", repl_output(cfg))
        d = Dict("max_levels" => 10)
        AMGX.create!(cfg, d)
        str = sprint((io, cfg) -> show(io, MIME("text/plain"), cfg), cfg)
        @test !occursin("uninitialized", repl_output(cfg))
        @test occursin("@", repl_output(cfg))

        d = Dict("max_lovels" => 10)
        @test_throws AMGXException("Incorrect amgx configuration provided.") Config(d)
    end
end

end # module
