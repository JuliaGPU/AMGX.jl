module TestVector

import ..repl_output
using AMGX, Defer, Test, JSON, CUDA
using AMGX: Config, Resources, AMGXVector, dDDI, dFFI

@scope @testset "Vector" begin
    c = @! Config("")
    r = @! Resources(c)

    @scope @testset "upload/download" begin
        v = @! AMGXVector(r, dDDI)
        @test occursin("dDDI", repl_output(v))
        v_h = [1.0, 2.0, 3.0]
        AMGX.upload!(v, v_h)
        @test occursin("of length 3", repl_output(v))
        @test length(v) == 3
        @test AMGX.download(v) == v_h
        @test Vector(v) == v_h
        @test Array(v) == v_h

        # Copy in place
        v_h_buffer = zeros(Float64, 3)
        copy!(v_h_buffer, v)
        @test v_h_buffer == v_h

        # Copy in place wrong size
        v_h_buffer_wrong_length = zeros(Float64, 4)
        @test_throws ArgumentError copy!(v_h_buffer_wrong_length, v)

        # Wrong element type
        v_h = Float32[1.0, 2.0, 3.0]
        @test_throws ArgumentError AMGX.upload!(v, v_h)

        # Float32
        v = @! AMGXVector(r, dFFI)
        v_h = Float32[1.0, 2.0, 3.0]
        AMGX.upload!(v, v_h)
        @test length(v) == 3
        @test AMGX.download(v) == v_h

        # Set zero
        v = @! AMGXVector(r, dDDI)
        AMGX.set_zero!(v, 5)
        @test length(v) == 5
        @test Vector(v) == zeros(Float64, 5)

        # Blocked
        v = @! AMGXVector(r, dDDI)
        v_h = [1.0, 2.0, 3.0, 4.0]
        AMGX.upload!(v, v_h; block_dim = 2)
        @test occursin("of length 2⋅2", repl_output(v))
        @test length(v_h) == 4
        @test AMGX.vector_get_size(v) == (2, 2)
        v_h = [1.0, 2.0, 3.0]
        @test_throws ArgumentError AMGX.upload!(v, v_h; block_dim = 2)
    end

    @scope @testset "upload/download cuarray" begin
        v = @! AMGXVector(r, dDDI)
        v_h = [1.0, 2.0, 3.0]
        v_d = CuArray(v_h)
        AMGX.upload!(v, v_d)
        @test length(v) == 3
        @test AMGX.download(v) == v_h

        # Copy in place
        v_d_buffer = CUDA.zeros(Float64, 3)
        copy!(v_d_buffer, v)
        @test Vector(v_d_buffer) == v_h
        v_h_buffer = zeros(Float64, 3)
        copy!(v_h_buffer, v)
        @test v_h_buffer == v_h
        v_d_buffer = CUDA.zeros(Float32, 3)
        @test_throws ArgumentError copy!(v_d_buffer, v)

        # Float32
        v = @! AMGXVector(r, dFFI)
        v_h = Float32[1.0, 2.0, 3.0]
        v_d = CuArray(v_h)
        AMGX.upload!(v, v_d)
        @test Vector(v) == v_h
    end
end
end # module
