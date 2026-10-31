using AMGX

include("test_mode.jl")
include("test_constructors.jl")

repl_output(x) = sprint((io, x) -> show(io, MIME("text/plain"), x), x)

# Hide annoying output from the library
AMGX.register_print_callback(x -> nothing)

function with_init(f)
    AMGX.initialize()
    AMGX.initialize_plugins()
    try
        f()
    finally
        AMGX.finalize_plugins()
        AMGX.finalize()
    end
end

with_init() do
    include("test_config.jl")
end
with_init() do
    include("test_resources.jl")
end
with_init() do
    include("test_vector.jl")
end
with_init() do
    include("test_matrix.jl")
end
with_init() do
    include("test_solver.jl")
end
with_init() do
    include("test_preconditioner.jl")
end
with_init() do
    include("test_close.jl")
end
with_init() do
    include("test_ownership.jl")
end

using Test
@testset "objects outliving their session" begin
    stale = with_init(() -> AMGX.Config(""))
    stale_solver = with_init() do
        c = AMGX.Config("")
        r = AMGX.Resources(c)
        m = AMGX.AMGXMatrix(r, AMGX.dDDI)
        AMGX.upload!(m, Cint[0, 1, 2], Cint[0, 1], [2.0, 4.0])
        s = AMGX.Solver(r, AMGX.dDDI, c)
        AMGX.setup!(s, m)
        return s
    end
    # `finalize` destroys objects that are still referenced; AMGX would
    # otherwise destroy them at process exit, after CUDA is gone, and abort.
    @test stale_solver.handle == C_NULL
    @test stale_solver.bound_matrix.handle == C_NULL
    @test stale_solver.resources.handle == C_NULL
    @test stale_solver.config.handle == C_NULL
    @test repl_output(stale_solver) == "AMGX.Solver invalid"
    # Reject the solver before querying its matrix's raw handle, both after
    # finalization and after a new session has started.
    stale_solver_error = "`AMGX.Solver` belongs to a finalized AMGX session"
    @test_throws stale_solver_error AMGX.aspreconditioner(stale_solver)
    with_init() do
        @test !isopen(stale)
        @test_throws ArgumentError AMGX.Resources(stale)
        close(stale)  # dropped without calling into AMGX
        @test stale.handle == C_NULL
        @test_throws stale_solver_error AMGX.aspreconditioner(stale_solver)
        close(stale_solver)
        @test stale_solver.handle == C_NULL
    end
end
# Do this last so the print callback handler we set in the test here doesn't mess up things
with_init() do
    include("test_utils.jl")
end
