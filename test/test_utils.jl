module TestUtils

using AMGX, Test, Defer

@testset "Utils" begin
    @testset "api_version" begin
        v = AMGX.api_version()
        @test v isa VersionNumber
    end

    @testset "build_info" begin
        version, date, time = AMGX.build_info()
        @test version isa String
        @test date isa String
        @test time isa String
    end

    @testset "versioninfo" begin
        str = sprint(AMGX.versioninfo)
        @test occursin("AMGX version", str)
        @test occursin("Built on", str)
        @test occursin("API version", str)
    end

    @testset "error_string begin" begin
        @test AMGX.error_string(AMGX.API.AMGX_RC_BAD_PARAMETERS) == "Incorrect parameters for amgx call."
        @test AMGX.error_string(AMGX.API.AMGX_RC_OK) == "No error."
        @test AMGX.error_string(AMGX.API.AMGX_RC_INTERNAL) == "Internal error."
    end

    @scope @testset "print callback" begin
        result_print = ""
        AMGX.register_print_callback(x -> (result_print = x; nothing))
        # An unknown parameter is reported through the print callback. Building
        # a config from an empty string used to print too, but AMGX has been
        # silent about that since 2.5.
        @test_throws AMGX.AMGXException AMGX.Config("bogus_parameter=1")
        @test !isempty(result_print)

        # The `CFunction` handed to AMGX must stay reachable from Julia: it owns
        # the trampoline AMGX calls, and freeing it leaves AMGX with a dangling
        # pointer that segfaults on the next library print (e.g. during
        # `AMGX.finalize()`).
        @test AMGX._print_callback[] !== nothing
        GC.gc(); GC.gc()
        @test AMGX._print_callback[] !== nothing
    end

    @testset "pin / unpin" begin
        v = rand(10);
        AMGX.pin_memory(v)
        AMGX.unpin_memory(v)
    end

    @testset "signal handler" begin
        AMGX.install_signal_handler()
        AMGX.reset_signal_handler()
    end
end

end # module
