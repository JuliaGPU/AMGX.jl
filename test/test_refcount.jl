module TestRefCount

using AMGX, Test
using AMGX: Config, Resources, AMGXVector, dDDI, AMGXMatrix, Solver, RefCountError

@testset "ref counts" begin
    c = Config("")
    @test c.ref_count[] == 0
    r = Resources(c)
    @test c.ref_count[] == 1
    @test_throws RefCountError close(c)
    v = AMGXVector(r, dDDI)
    @test_throws RefCountError close(r)
    @test r.ref_count[] == 1
    close(v)
    @test r.ref_count[] == 0
    m = AMGXMatrix(r, dDDI)
    @test r.ref_count[] == 1
    @test_throws RefCountError close(r)
    close(m)
    m = AMGXMatrix(r, dDDI)
    s = Solver(r, dDDI, c)
    @test c.ref_count[] == 2
    @test r.ref_count[] == 2
    close(s)
    close(m)
    close(r)
    close(c)
end

end #module
