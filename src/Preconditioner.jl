"""
    AMGXPreconditioner

An AMGX solver exposed as a left preconditioner, so it can be handed to Krylov
methods from packages like Krylov.jl, IterativeSolvers.jl or LinearSolve.jl.

Construct one with [`aspreconditioner`](@ref) and apply it with `ldiv!` or `\\`.

The mapping onto AMGX is direct: [`setup!`](@ref) builds the multigrid hierarchy
once, and each `ldiv!` is one [`solve!`](@ref) against it. If the matrix
coefficients change but its sparsity does not, use
[`replace_coefficients!`](@ref) followed by [`update!`](@ref) rather than
building a new preconditioner.

It owns two scratch vectors and must be `close`d. The [`Solver`](@ref) it wraps
is not owned by it: the solver must outlive the preconditioner, and closing the
solver is still the caller's responsibility.
"""
mutable struct AMGXPreconditioner{T}
    solver::Solver
    rhs::AMGXVector
    sol::AMGXVector
    n::Int
end

"""
    aspreconditioner(solver::Solver)

Wrap an already set-up [`Solver`](@ref) as an [`AMGXPreconditioner`](@ref).

`solver` must have had [`setup!`](@ref) called on it; the preconditioner takes
its size and precision from the bound matrix.

```julia
solver = AMGX.Solver(resources, AMGX.dDDI, config)
AMGX.setup!(solver, matrix)
p = AMGX.aspreconditioner(solver)

ldiv!(x, p, b)     # one AMGX solve
close(p)
```
"""
function aspreconditioner(solver::Solver)
    matrix = solver.bound_matrix
    matrix === nothing && throw(ArgumentError("solver has no matrix bound; call `setup!` first"))
    matrix.handle == C_NULL && throw(ArgumentError("the matrix bound to the solver has been destroyed"))

    n, _ = size(matrix)
    res = solver.resources
    mode = solver.mode
    T = vector_type(mode)

    rhs = AMGXVector(res, mode)
    sol = AMGXVector(res, mode)
    set_zero!(rhs, n)
    set_zero!(sol, n)

    return AMGXPreconditioner{T}(solver, rhs, sol, n)
end

"""
    close(p::AMGXPreconditioner)

Free the scratch vectors the preconditioner allocated. The [`Solver`](@ref) it
wraps is *not* closed — it was created by the caller and stays theirs to close.
"""
function Base.close(p::AMGXPreconditioner)
    close(p.rhs)
    close(p.sol)
    return nothing
end

Base.size(p::AMGXPreconditioner) = (p.n, p.n)
Base.eltype(::AMGXPreconditioner{T}) where {T} = T

"""
    update!(p::AMGXPreconditioner)

Rebuild the preconditioner after the coefficients of its matrix changed, reusing
the existing hierarchy. Equivalent to [`resetup!`](@ref) on the wrapped solver,
and much cheaper than constructing a new preconditioner.

```julia
AMGX.replace_coefficients!(matrix, new_values)
AMGX.update!(p)
```
"""
function update!(p::AMGXPreconditioner)
    resetup!(p.solver, p.solver.bound_matrix)
    return p
end

function LinearAlgebra.ldiv!(y::VectorOrCuVector, p::AMGXPreconditioner, b::VectorOrCuVector)
    length(b) == p.n || throw(DimensionMismatch("preconditioner has size $(p.n), got right-hand side of length $(length(b))"))
    length(y) == p.n || throw(DimensionMismatch("preconditioner has size $(p.n), got output of length $(length(y))"))
    upload!(p.rhs, b)
    set_zero!(p.sol, p.n)
    solve!(p.sol, p.solver, p.rhs; zero_inital_guess=true)
    download!(y, p.sol)
    return y
end

LinearAlgebra.ldiv!(p::AMGXPreconditioner, b::VectorOrCuVector) = ldiv!(b, p, copy(b))

Base.:\(p::AMGXPreconditioner, b::VectorOrCuVector) = ldiv!(similar(b), p, b)
