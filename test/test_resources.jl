module TestResources

using AMGX, Defer, Test, CUDA
using AMGX: Config, Resources

@scope @testset "Resources" begin
    cfg = @! Config("")
    resources = @! Resources(cfg)
    @test resources isa Resources

    @scope @testset "device_id" begin
        r0 = @! Resources(cfg; device_id=0)
        @test r0 isa Resources

        # Only exercise a second device when one is actually present.
        if CUDA.ndevices() > 1
            r1 = @! Resources(cfg; device_id=1)
            @test r1 isa Resources
        end
    end
end

end # module
