
d = JSON.parsefile(joinpath(@__DIR__, "example_config.json"))
c = AMGX.Config(d)
r = AMGX.Resources(c)

v = AMGX.AMGXVector(r)
v_h = [1.0, 2.0, 3.0]
AMGX.upload!(v, v_h)
@test length(v) == 3
@test AMGX.download(v) == v_h

