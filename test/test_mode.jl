module TestMode

using AMGX, Test

@testset "Mode precision" begin
    for (modes, vector_type, matrix_type) in (
        ((AMGX.hDDI, AMGX.dDDI), Float64, Float64),
        ((AMGX.hDFI, AMGX.dDFI), Float64, Float32),
        ((AMGX.hFFI, AMGX.dFFI), Float32, Float32),
    )
        for mode in modes
            @test AMGX.vector_type(mode) === vector_type
            @test AMGX.matrix_type(mode) === matrix_type
        end
    end
end

end # module
