using AMGX

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
    include("test_refcount.jl")
end
# Do this last so the print callback handler we set in the test here doesn't mess up things
with_init() do
    include("test_utils.jl")
end
