Base.@kwdef mutable struct Solver <: AMGXObject
    handle::API.AMGX_solver_handle = API.AMGX_solver_handle(C_NULL)
    resources::Union{Resources, Nothing} = nothing
    config::Union{Config, Nothing} = nothing
    bound_matrix::Union{AMGXMatrix, Nothing} = nothing
    function Solver(handle::API.AMGX_solver_handle, resources::Union{Resources, Nothing},
                    config::Union{Config, Nothing}, bound_matrix::Union{AMGXMatrix, Nothing})
        solver = new(handle, resources, config, bound_matrix)
        finalizer(warn_not_destroyed_on_finalize, solver)
        return solver
    end
end
function dec_refcount_parents(solver::Solver)
    dec_refcount!(solver.resources)
    dec_refcount!(solver.config)
    solver.resources = nothing
    solver.config = nothing
    solver.bound_matrix = nothing
    nothing
end
get_api_destroy_call(::Type{Solver}) = API.AMGX_solver_destroy

function create!(solver::Solver, res::Resources, mode::Mode, config::Config)
    solver_handle_ptr = Ref{API.AMGX_solver_handle}()
    amgx_mode = API.AMGX_Mode(Int(mode))
    @checked API.AMGX_solver_create(solver_handle_ptr, res.handle, amgx_mode, config.handle)
    solver.handle = solver_handle_ptr[]
    solver.resources = res
    solver.config = config
    inc_refcount!(solver.resources)
    inc_refcount!(solver.config)
    return solver
end
Solver(res::Resources, mode::Mode, config::Config) = create!(Solver(), res, mode, config)

function setup!(solver::Solver, matrix::AMGXMatrix)
    @checked API.AMGX_solver_setup(solver.handle, matrix.handle)
    solver.bound_matrix = matrix
    return solver
end

function solve!(sol::AMGXVector, solver::Solver, rhs::AMGXVector; zero_inital_guess::Bool=false)
    if solver.bound_matrix === nothing 
        error("no matrix attached to solver")
    elseif solver.bound_matrix.handle == C_NULL
        error("matrix has already been destroyed")
    end
    if zero_inital_guess
        @checked API.AMGX_solver_solve_with_0_initial_guess(solver.handle, rhs.handle, sol.handle)
    else
        @checked API.AMGX_solver_solve(solver.handle, rhs.handle, sol.handle)
    end
    return sol
end

function get_iterations_number(solver::Solver)
    n_ptr = Ref{Cint}()
    @checked API.AMGX_solver_get_iterations_number(solver.handle, n_ptr)
    # for some reason AMGX returns 1 + number of iterations.
    return Int(n_ptr[]) - 1
end

function get_iteration_residual(solver::Solver, iter::Int=get_iterations_number(solver), block_idx::Int=0)
    res_ptr = Ref{Float64}()
    @checked API.AMGX_solver_get_iteration_residual(solver.handle, iter, block_idx, res_ptr)
    return res_ptr[]
end

@enum SolverStatus begin
   SUCCESS = Int(API.AMGX_SOLVE_SUCCESS)
   FAILED = Int(API.AMGX_SOLVE_FAILED)
   DIVERGED = Int(API.AMGX_SOLVE_DIVERGED)
end

function get_status(solver::Solver)
    status_ptr = Ref{API.AMGX_SOLVE_STATUS}()
    @checked API.AMGX_solver_get_status(solver.handle, status_ptr)
    return SolverStatus(Int(status_ptr[]))
end

