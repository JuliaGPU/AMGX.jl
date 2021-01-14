module TestConfig

using AMGX, Defer, Test
using AMGX: Config, AMGXException

@testset "Config" begin
    @scope @testset "Dict" begin
        cfg = @! Config()
        d = Dict("max_levels" => 10)
        AMGX.create!(cfg, d)

        d = Dict("max_lovels" => 10)
        @test_throws AMGXException("Incorrect amgx configuration provided.") Config(d)
    end
end

end # module
