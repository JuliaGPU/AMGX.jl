module TestResources

using AMGX, Defer, Test
using AMGX: Config, Resources

@scope @testset "Resources" begin
    cfg = @! Config("")
    resources = @! Resources(cfg)
end

end # module
