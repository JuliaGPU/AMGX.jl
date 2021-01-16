#=
AMGX solver create
AMGX solver destroy
AMGX solver setup
AMGX solver solve
AMGX solver solve with 0 initial guess 
AMGX solver get iterations number
AMGX solver get iteration residual
AMGX solver get status
=#

# All Matrix or Vector objects attached to this Solver must be created with the same Resources object.

mutable struct AMGXSolver <: AMGXObject
    handle::API.AMGX_solver_handle
end

c_destroy(::Type{AMGXSolver}) = API.AMGX_solver_destroy


#=
After an instance has been destroyed, subsequent attempts to use the Solver object will result in undefined behavior.
=#

function AMGXSolver(res::Resources; mode::Mode, config::Config)
    solver_handle_ptr = Ref{API.AMGX_solver_handle}()
    amgx_mode = API.AMGX_Mode(Int(mode))
    @checked API.AMGX_solver_create(solver_handle_ptr, res.handle, amgx_mode, config.handle)
    return AMGXSolver(solver_handle_ptr[])
end

#=
Repeated calls to AMGX solver setup are allowed without requiring the Solver
object to be destroyed and created again. The previously bound Matrix will be
unbound, and the Matrix will be associated with this Solver object instead.
=#


function setup!(solver::AMGXSolver, matrix::AMGXMatrix)
    # TODO, check same resource object 
end

#= Therefore, calls to AMGX solver solve with 0 initial guess will result in
undefined behavior if the referenced Matrix has been destroyed after being
passed to the solver via AMGX solver setup
=#
function solve_with_0_initial_guess!(sol::AMGXVector, solver::AMGXSolver, rhs::AMGXVector)
    @checked API.AMGX_solver_solve_with_0_initial_guess(solver.handle, rhs.handle, sol.handle)
    return
end

function solve!(sol::AMGXVector, solver::AMGXSolver, rhs::AMGXVector)
    @checked API.AMGX_solver_solve(solver.handle, rhs.handle, sol.handle)
    return
end

function get_iterations_number(solver::AMGXSolver)
    n_ptr = Ref{Cint}()
    @checked API.AMGX_solver_get_iteratons_number(solver.handle, n_ptr)
    return Int(n_ptr[])
end

function get_iteration_residual(solver::AMGXSolver, iter::Int, idx::Int)
    res_ptr = Ref{Float64}()
    @checked API.AMGX_solver_get_iteraton_residual(solver.handle, iter, idx, res_ptr)
    return res_ptr[]
end

function get_status(solver::AMGXSolver)
    # TODO, create our own enum
    status_ptr = Ref{API.AMGX_SOLVE_STATUS}()
    @checked API.AGMX_solver_get_status(solver.handle, status_ptr)
    return status_ptr[]
end




