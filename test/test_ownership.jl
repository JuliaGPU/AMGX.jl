module TestOwnership

using AMGX, Test
using AMGX: Config, Resources, AMGXVector, AMGXMatrix, Solver, dDDI

@testset "ownership" begin
    @testset "ref counts" begin
        c = Config("")
        r = Resources(c)
        @test c.ref_count == 1
        v = AMGXVector(r, dDDI)
        m = AMGXMatrix(r, dDDI)
        s = Solver(r, dDDI, c)
        @test r.ref_count == 3
        @test c.ref_count == 2
        foreach(close, (v, m, s))
        @test r.ref_count == 0
        @test c.ref_count == 1
        close(r)
        @test c.ref_count == 0
        close(c)
        @test c.handle == C_NULL
    end

    @testset "close in any order" begin
        c = Config("")
        r = Resources(c)
        v = AMGXVector(r, dDDI)
        close(c)
        close(r)
        @test !isopen(r) && r.handle != C_NULL
        @test_throws ArgumentError AMGX.create!(c, "")
        @test_throws ArgumentError AMGX.create!(r, c)
        @test occursin("closed", sprint(show, MIME("text/plain"), r))
        @test_throws ArgumentError AMGXVector(r, dDDI)
        AMGX.upload!(v, [1.0, 2.0])
        @test Vector(v) == [1.0, 2.0]
        close(v)
        @test v.handle == C_NULL && r.handle == C_NULL && c.handle == C_NULL
        @test_throws ArgumentError Vector(v)
    end

    @testset "solver keeps the bound matrix alive" begin
        c = Config("")
        r = Resources(c)
        m = AMGXMatrix(r, dDDI)
        AMGX.upload!(m, Cint[0, 1, 2], Cint[0, 1], [2.0, 4.0])
        s = Solver(r, dDDI, c)
        AMGX.setup!(s, m)
        @test m.ref_count == 1
        close(m)
        @test m.handle != C_NULL
        @test_throws ArgumentError AMGX.create!(m, r, dDDI)
        b = AMGXVector(r, dDDI)
        AMGX.upload!(b, [2.0, 2.0])
        x = AMGXVector(r, dDDI)
        AMGX.set_zero!(x, 2)
        AMGX.solve!(x, s, b)
        @test Vector(x) ≈ [1.0, 0.5]
        p = AMGX.aspreconditioner(s)
        @test size(p) == (2, 2)

        # binding another matrix releases the old one
        m2 = AMGXMatrix(r, dDDI)
        AMGX.upload!(m2, Cint[0, 1, 2], Cint[0, 1], [1.0, 1.0])
        AMGX.setup!(s, m2)
        @test m.handle == C_NULL
        @test m2.ref_count == 1
        foreach(close, (p, x, b, s, m2, r, c))
        @test c.handle == C_NULL
    end

    @testset "destroying resources waits for all device data" begin
        c = Config("")
        r1 = Resources(c)
        r2 = Resources(c)
        v2 = AMGXVector(r2, dDDI)
        AMGX.upload!(v2, rand(10))
        close(r1)
        @test r1.handle != C_NULL
        @test_throws ArgumentError AMGX.create!(r1, c)
        AMGX.upload!(v2, rand(10))
        close(v2)
        @test r1.handle == C_NULL
        close(r2); close(c)
        @test AMGX.LIVE_DATA[] == 0
    end

    @testset "recreate closed objects" begin
        c = Config("")
        r = Resources(c)
        v = AMGXVector(r, dDDI)
        m = AMGXMatrix(r, dDDI)
        s = Solver(r, dDDI, c)
        objects = (s, m, v, r, c)
        foreach(close, objects)
        @test all(x -> x.handle == C_NULL, objects)

        @test AMGX.create!(c, "") === c
        @test AMGX.create!(r, c) === r
        @test AMGX.create!(v, r, dDDI) === v
        @test AMGX.create!(m, r, dDDI) === m
        @test AMGX.create!(s, r, dDDI, c) === s
        @test all(isopen, objects)
        @test c.ref_count == 2
        @test r.ref_count == 3

        AMGX.upload!(m, Cint[0, 1, 2], Cint[0, 1], [2.0, 4.0])
        AMGX.setup!(s, m)
        AMGX.upload!(v, [2.0, 2.0])
        x = AMGXVector(r, dDDI)
        AMGX.set_zero!(x, 2)
        AMGX.solve!(x, s, v)
        @test Vector(x) ≈ [1.0, 0.5]
        close(x)
        foreach(close, objects)
        @test all(x -> x.handle == C_NULL, objects)
        @test c.ref_count == r.ref_count == 0
    end

    @testset "garbage collection" begin
        c = Config(Dict("max_iters" => 10))
        function solve_unclosed(c)
            r = Resources(c)
            m = AMGXMatrix(r, dDDI)
            AMGX.upload!(m, Cint[0, 1, 2], Cint[0, 1], [2.0, 4.0])
            s = Solver(r, dDDI, c)
            AMGX.setup!(s, m)
            b = AMGXVector(r, dDDI)
            AMGX.upload!(b, [2.0, 2.0])
            x = AMGXVector(r, dDDI)
            AMGX.set_zero!(x, 2)
            AMGX.solve!(x, s, b)
            return Vector(x)
        end
        for _ in 1:10
            @test solve_unclosed(c) ≈ [1.0, 0.5]
        end
        @test c.ref_count > 0
        AMGX.collect_garbage()
        @test c.ref_count == 0
        @test AMGX.LIVE_DATA[] == 0
        @test isempty(AMGX.DEFERRED_RESOURCES)
        close(c)
    end
end

@testset "create! on an open object" begin
    c = Config("")
    @test_throws ArgumentError AMGX.create!(c, "")
    r = Resources(c)
    @test_throws ArgumentError AMGX.create!(r, c)
    @test c.ref_count == 1
    v = AMGXVector(r, dDDI)
    m = AMGXMatrix(r, dDDI)
    s = Solver(r, dDDI, c)
    @test_throws ArgumentError AMGX.create!(v, r, dDDI)
    @test_throws ArgumentError AMGX.create!(m, r, dDDI)
    @test_throws ArgumentError AMGX.create!(s, r, dDDI, c)
    @test r.ref_count == 3
    @test c.ref_count == 2

    # a closed object can be created again
    close(v)
    @test AMGX.create!(v, r, dDDI) === v
    @test r.ref_count == 3

    foreach(close, (s, m, v, r, c))
end

end # module
