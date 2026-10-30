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

@testset "create! on an open object" begin
    c = Config("")
    @test_throws ArgumentError AMGX.create!(c, "")
    r = Resources(c)
    @test_throws ArgumentError AMGX.create!(r, c)
    @test c.ref_count[] == 1
    v = AMGXVector(r, dDDI)
    m = AMGXMatrix(r, dDDI)
    s = Solver(r, dDDI, c)
    @test_throws ArgumentError AMGX.create!(v, r, dDDI)
    @test_throws ArgumentError AMGX.create!(m, r, dDDI)
    @test_throws ArgumentError AMGX.create!(s, r, dDDI, c)
    @test r.ref_count[] == 3
    @test c.ref_count[] == 2

    # a closed object can be created again
    close(v)
    @test AMGX.create!(v, r, dDDI) === v
    @test r.ref_count[] == 3

    foreach(close, (s, m, v, r, c))
end

end #module
