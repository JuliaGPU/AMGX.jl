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
        c = @! AMGX.Config("")
        @test !isempty(result_print)
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
