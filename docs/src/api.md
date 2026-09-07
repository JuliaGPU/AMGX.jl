# API reference

```@meta
CurrentModule = AMGX
```

## Library lifecycle

```@docs
initialize
initialize_plugins
finalize
finalize_plugins
close
```

## Configuration and resources

```@docs
Config
Resources
create!
Mode
vector_type
matrix_type
```

## Vectors

```@docs
AMGXVector
upload!
download
download!
set_zero!
length
```

## Matrices

```@docs
AMGXMatrix
replace_coefficients!
size
nnz
```

## Solvers

```@docs
Solver
setup!
resetup!
solve!
get_status
SolverStatus
get_iterations_number
get_iteration_residual
```

## Utilities

```@docs
api_version
build_info
versioninfo
pin_memory
unpin_memory
register_print_callback
install_signal_handler
reset_signal_handler
```

## Errors

```@docs
AMGXException
error_string
```
