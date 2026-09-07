# Using AMGX as a preconditioner

AMGX's two-phase design — build the hierarchy once, apply it many times — is
exactly what a Krylov method wants from a preconditioner. `AMGX.aspreconditioner`
wraps a set-up [`AMGX.Solver`](@ref) in an object supporting `ldiv!` and `\`, so
it can be handed to Krylov.jl, IterativeSolvers.jl or LinearSolve.jl.

```@docs
AMGX.AMGXPreconditioner
AMGX.aspreconditioner
AMGX.update!
```

## Example

```jldoctest precon
julia> using AMGX, CUDA, SparseArrays, LinearAlgebra

julia> AMGX.register_print_callback(_ -> nothing);  # keep AMGX quiet

julia> AMGX.initialize()

julia> config = AMGX.Config(Dict("max_iters" => 50, "monitor_residual" => 1));

julia> resources = AMGX.Resources(config);

julia> A = sparse([1,1,2,2,3,3], [1,2,2,3,1,3], [4.0,1.0,4.0,1.0,1.0,4.0], 3, 3);

julia> matrix = AMGX.AMGXMatrix(resources, AMGX.dDDI);

julia> AMGX.upload!(matrix, CUDA.CUSPARSE.CuSparseMatrixCSR(A));

julia> solver = AMGX.Solver(resources, AMGX.dDDI, config);

julia> AMGX.setup!(solver, matrix);

julia> p = AMGX.aspreconditioner(solver);

julia> size(p), eltype(p)
((3, 3), Float64)

julia> b = [1.0, 2.0, 3.0]; y = similar(b);

julia> ldiv!(y, p, b);

julia> A * y ≈ b
true

julia> A * (p \ b) ≈ b
true
```

The right-hand side may equally be a `CuVector`, in which case nothing is copied
to the host:

```jldoctest precon
julia> b_gpu = CuVector(b); y_gpu = similar(b_gpu);

julia> ldiv!(y_gpu, p, b_gpu);

julia> A * Vector(y_gpu) ≈ b
true
```

## Reusing the hierarchy

In a Newton or time-stepping loop the sparsity pattern usually stays fixed while
the values change. Rebuilding the whole hierarchy each step is wasteful — use
[`AMGX.replace_coefficients!`](@ref) and [`AMGX.update!`](@ref) instead, which
maps onto [`AMGX.resetup!`](@ref):

```jldoctest precon
julia> new_values = [8.0, 1.0, 8.0, 1.0, 1.0, 8.0];

julia> AMGX.replace_coefficients!(matrix, new_values);

julia> AMGX.update!(p);

julia> A2 = sparse([1,1,2,2,3,3], [1,2,2,3,1,3], new_values, 3, 3);

julia> ldiv!(y, p, b);

julia> A2 * y ≈ b
true
```

## Cleaning up

The preconditioner owns two scratch vectors and must be closed. It does **not**
own the solver — that stays yours to close:

```jldoctest precon
julia> close(p); close(solver); close(matrix); close(resources); close(config);

julia> AMGX.finalize()
```

!!! note
    AMGX is GPU-resident, so this is not a drop-in replacement for a CPU
    preconditioner such as the one from
    [AlgebraicMultigrid.jl](https://github.com/JuliaLinearAlgebra/AlgebraicMultigrid.jl).
    Both expose `ldiv!`, but AMGX operates on device data — passing host arrays
    means a transfer on each application.
