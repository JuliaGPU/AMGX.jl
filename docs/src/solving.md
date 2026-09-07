# Solving

A [`AMGX.Solver`](@ref) is created from a `Resources`, a `Mode` and a `Config`:

```julia
solver = AMGX.Solver(resources, AMGX.dDDI, config)
```

Solving is two phases. [`AMGX.setup!`](@ref) binds a matrix and builds the
multigrid hierarchy — the expensive part — and [`AMGX.solve!`](@ref) then solves
against a right-hand side:

```julia
x = AMGX.AMGXVector(resources, AMGX.dDDI)
AMGX.set_zero!(x, 3)

AMGX.setup!(solver, matrix)
AMGX.solve!(x, solver, rhs)

Vector(x)
```

The current contents of `x` are used as the initial guess; pass
`zero_inital_guess=true` to ignore them.

## Checking the result

!!! warning
    A solve that does not converge is **not** an error — `solve!` returns
    normally and leaves a partial result in the solution vector. Always check
    the status.

```julia
AMGX.get_status(solver)
```

returns a [`AMGX.SolverStatus`](@ref):

- `AMGX.SUCCESS` — the convergence criterion was met.
- `AMGX.FAILED` — the solver stopped on an internal error.
- `AMGX.DIVERGED` — the solver reported divergence.
- `AMGX.NOT_CONVERGED` — the criterion was not met, typically because
  `max_iters` was reached.

Iteration counts and residuals are available too:

```julia
AMGX.get_iterations_number(solver)
AMGX.get_iteration_residual(solver)     # final iteration
AMGX.get_iteration_residual(solver, 0)  # a specific iteration
```

Residuals for iterations other than the last require `store_res_history=1` in
the `Config`.

## Re-solving with new coefficients

When only the matrix values changed, [`AMGX.resetup!`](@ref) reuses the existing
hierarchy and is much cheaper than a second `setup!`:

```julia
AMGX.replace_coefficients!(matrix, new_values)
AMGX.resetup!(solver, matrix)
AMGX.solve!(x, solver, rhs)
```

`resetup!` requires the same matrix that `setup!` was given.
