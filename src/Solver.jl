"""
    Solver(resources::Resources, mode::Mode, config::Config)

An AMGX solver. `config` determines which algorithm is used and its parameters.

A solver is used in three steps: bind a matrix with [`setup!`](@ref), solve with
[`solve!`](@ref), and — if only the coefficients changed — rebind cheaply with
[`resetup!`](@ref).

```julia
solver = AMGX.Solver(resources, AMGX.dDDI, config)
AMGX.setup!(solver, matrix)
AMGX.solve!(x, solver, b)
```

The solver keeps the matrix bound by [`setup!`](@ref) alive, so that matrix may
be closed while the solver is still in use. Released when garbage collected, or
earlier with `close`.
"""
Base.@kwdef mutable struct Solver <: AMGXObject
    handle::API.AMGX_solver_handle = API.AMGX_solver_handle(C_NULL)
    ref_count::Int = 0
    closed::Bool = false
    session::Int = 0
    resources::Union{Resources, Nothing} = nothing
    config::Union{Config, Nothing} = nothing
    mode::Union{Mode, Nothing} = nothing
    bound_matrix::Union{AMGXMatrix, Nothing} = nothing
    function Solver(handle::API.AMGX_solver_handle, ref_count::Int, closed::Bool, session::Int,
                    resources::Union{Resources, Nothing}, config::Union{Config, Nothing},
                    mode::Union{Mode, Nothing}, bound_matrix::Union{AMGXMatrix, Nothing})
        solver = new(handle, ref_count, closed, session, resources, config, mode, bound_matrix)
        finalizer(enqueue_finalized, solver)
        return solver
    end
end
function release_parents!(solver::Solver)
    res, solver.resources = solver.resources, nothing
    cfg, solver.config = solver.config, nothing
    m, solver.bound_matrix = solver.bound_matrix, nothing
    release!(m)
    release!(res)
    release!(cfg)
end
get_api_destroy_call(::Type{Solver}) = API.AMGX_solver_destroy
holds_device_data(::Solver) = true

function create!(solver::Solver, res::Resources, mode::Mode, config::Config)
    drain_pending!()
    check_not_created(solver)
    solver_handle_ptr = Ref{API.AMGX_solver_handle}()
    amgx_mode = API.AMGX_Mode(Int(mode))
    @checked API.AMGX_solver_create(solver_handle_ptr, res, amgx_mode, config)
    set_handle!(solver, solver_handle_ptr[])
    solver.resources = retain!(res)
    solver.config = retain!(config)
    solver.mode = mode
    return solver
end
Solver(res::Resources, mode::Mode, config::Config) = create!(Solver(), res, mode, config)

"""
    setup!(solver::Solver, matrix::AMGXMatrix)

Bind `matrix` to `solver` and perform the setup phase, building the multigrid
hierarchy. This is the expensive part of a solve.
"""
function setup!(solver::Solver, matrix::AMGXMatrix)
    @checked API.AMGX_solver_setup(solver, matrix)
    if solver.bound_matrix !== matrix
        old, solver.bound_matrix = solver.bound_matrix, retain!(matrix)
        release!(old)
    end
    return solver
end

"""
    resetup!(solver::Solver, matrix::AMGXMatrix)

Redo the setup for a matrix whose coefficients changed but whose sparsity
structure did not — typically after [`replace_coefficients!`](@ref). Much cheaper
than a full [`setup!`](@ref).

`matrix` must be the one already bound by [`setup!`](@ref); otherwise an
`ArgumentError` is thrown.
"""
function resetup!(solver::Solver, matrix::AMGXMatrix)
    solver.bound_matrix == matrix || throw(ArgumentError("Matrix is not the same as the one bound to the solver"))
    @checked API.AMGX_solver_resetup(solver, matrix)
    return solver
end

"""
    solve!(sol::AMGXVector, solver::Solver, rhs::AMGXVector; zero_inital_guess=false)

Solve `A * sol = rhs`, where `A` is the matrix bound by [`setup!`](@ref), writing
the result into `sol`. The current contents of `sol` are used as the initial
guess unless `zero_inital_guess` is `true`.

Note that a solve that does not converge is *not* an error: check
[`get_status`](@ref) afterwards.
"""
function solve!(sol::AMGXVector, solver::Solver, rhs::AMGXVector; zero_inital_guess::Bool=false)
    solver.bound_matrix === nothing && error("no matrix attached to solver")
    if zero_inital_guess
        @checked API.AMGX_solver_solve_with_0_initial_guess(solver, rhs, sol)
    else
        @checked API.AMGX_solver_solve(solver, rhs, sol)
    end
    return sol
end

"""
    get_iterations_number(solver::Solver)

Number of iterations taken by the last [`solve!`](@ref).
"""
function get_iterations_number(solver::Solver)
    n_ptr = Ref{Cint}()
    @checked API.AMGX_solver_get_iterations_number(solver, n_ptr)
    return Int(n_ptr[])
end

"""
    get_iteration_residual(solver::Solver, iter=get_iterations_number(solver), block_idx=0)

Residual recorded at iteration `iter` of the last [`solve!`](@ref), defaulting to
the final one.

Requires `store_res_history=1` in the [`Config`](@ref) for iterations other than
the last.
"""
function get_iteration_residual(solver::Solver, iter::Int=get_iterations_number(solver), block_idx::Int=0)
    res_ptr = Ref{Float64}()
    @checked API.AMGX_solver_get_iteration_residual(solver, iter, block_idx, res_ptr)
    return res_ptr[]
end

"""
    SolverStatus

Outcome of the last [`solve!`](@ref), as returned by [`get_status`](@ref):

- `SUCCESS` — the convergence criterion was met.
- `FAILED` — the solver stopped on an internal error.
- `DIVERGED` — the solver reported divergence.
- `NOT_CONVERGED` — the criterion was not met, typically because `max_iters` was
  reached.
"""
@enum SolverStatus begin
   SUCCESS = Int(API.AMGX_SOLVE_SUCCESS)
   FAILED = Int(API.AMGX_SOLVE_FAILED)
   DIVERGED = Int(API.AMGX_SOLVE_DIVERGED)
   NOT_CONVERGED = Int(API.AMGX_SOLVE_NOT_CONVERGED)
end

"""
    get_status(solver::Solver)

The [`SolverStatus`](@ref) of the last [`solve!`](@ref). Always worth checking:
a non-converged solve returns normally and leaves a partial result in the
solution vector.
"""
function get_status(solver::Solver)
    status_ptr = Ref{API.AMGX_SOLVE_STATUS}()
    @checked API.AMGX_solver_get_status(solver, status_ptr)
    return SolverStatus(Int(status_ptr[]))
end
