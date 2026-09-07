# Memory management

AMGX objects are **not** garbage collected. Every `Config`, `Resources`,
`AMGXVector`, `AMGXMatrix` and `Solver` must be freed explicitly with `close`.

```julia
close(solver)
close(matrix)
close(resources)
close(config)
```

Order matters. AMGX.jl reference-counts the objects, and closing a parent while
a child is still alive raises a `RefCountError` — for example closing
`Resources` before a vector created from it. Close children first.

Forgetting to close an object is not silent either: the finalizer warns.

## Defer.jl

[Defer.jl](https://github.com/adambrewster/Defer.jl) removes most of the
bookkeeping. `@!` registers an object for closing at the end of the enclosing
`@scope`, in the right order:

```julia
using Defer

@scope begin
    config    = @! AMGX.Config(Dict("max_iters" => 10))
    resources = @! AMGX.Resources(config)
    matrix    = @! AMGX.AMGXMatrix(resources, AMGX.dDDI)
    solver    = @! AMGX.Solver(resources, AMGX.dDDI, config)
    # ... use them ...
end   # everything closed here, children before parents
```

This is how the package's own test suite is written.

## Finalizing the library

When you are finished with AMGX altogether:

```julia
AMGX.finalize_plugins()
AMGX.finalize()
```

All AMGX objects must be closed before this.
