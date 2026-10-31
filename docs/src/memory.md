# Memory management

AMGX objects — `Config`, `Resources`, `AMGXVector`, `AMGXMatrix` and `Solver` —
are released automatically when they are garbage collected. Each object keeps
the objects it was created from alive, so a `Resources` is never destroyed while
a vector created from it is still in use, and a `Solver` keeps the matrix bound
by `setup!` alive.

## Releasing early with `close`

The garbage collector does not know about the GPU memory AMGX allocates, so it
may not run before the device runs out of memory. `close` releases an object
right away:

```julia
close(solver)
close(matrix)
```

`close` can be called in any order. An object that others still depend on is
only destroyed once the last of them is, but can no longer be used after
`close`. [Defer.jl](https://github.com/adambrewster/Defer.jl) closes objects at
the end of a scope:

```julia
using Defer

@scope begin
    config    = @! AMGX.Config(Dict("max_iters" => 10))
    resources = @! AMGX.Resources(config)
    matrix    = @! AMGX.AMGXMatrix(resources, AMGX.dDDI)
    solver    = @! AMGX.Solver(resources, AMGX.dDDI, config)
    # ... use them ...
end   # everything closed here
```

Finalizers do not call into AMGX: collected objects are queued, and destroyed
the next time an AMGX object is created or closed, or on `AMGX.finalize`.

!!! note
    Destroying a `Resources` frees device memory that AMGX shares between all
    resources. AMGX.jl therefore postpones destroying resources until no
    vectors, matrices or solvers are alive.

## Finalizing the library

When you are finished with AMGX altogether:

```julia
AMGX.finalize_plugins()
AMGX.finalize()
```

These run the garbage collector first, so unreachable objects are destroyed.
`finalize` then destroys the objects that are still referenced too. They become
invalid and cannot be used anymore; closing them is a no-op.
