# AMGX.jl

*AMGX in Julia*

| **Build Status**                                                    |
|:-------------------------------------------------------------------:|
| [![][buildkite-img]][buildkite-url] [![][codecov-img]][codecov-url] |

The AMGX.jl package provides an interface for using NVIDIA's [AMGX](https://github.com/NVIDIA/AMGX) library from the Julia language.

[buildkite-img]: https://badge.buildkite.com/ce21dc6bf28e053c02c8c726ea0c65cc981a22ec2934e01e56.svg?branch=master
[buildkite-url]: https://buildkite.com/julialang/amgx-dot-jl

[codecov-img]: https://codecov.io/gh/JuliaGPU/AMGX.jl/branch/master/graph/badge.svg
[codecov-url]: https://codecov.io/gh/JuliaGPU/AMGX.jl

## Installation

The package is installed using the Julia package manager:

```julia
using Pkg; Pkg.add("AMGX")
```

Currently, only prebuilt binaries are available for Linux, on other operating systems you need to have AMGX available
locally.

Before using the package, reading through the [official API reference docs for
AMGX](https://github.com/NVIDIA/AMGX/blob/main/doc/AMGX_Reference.pdf) is recommended.


## API


### Initialization

If you do not want to use the provided prebuilt binaries, set the environment variable `JULIA_AMGX_PATH` to the path to the local AMGX library.

The library can now be initialized with:

```julia
using AMGX
AMGX.initialize()
```

### `Config`

An AMGX `Config` can be created from a dictionary or a string:

```julia
config = AMGX.Config(Dict("monitor_residual" => 1, "max_iters" => 10, "store_res_history" => 1));
```

### `Resources`

An AMGX `Resources` object is created from an AMGX `Config`. Currently, only simple resources are wrapped:

```julia
resources = AMGX.Resources(config)
```

### `Mode`

The different modes in AMGX are available as:

- `AMGX.hDDI`
- `AMGX.hDFI`
- `AMGX.hFFI`
- `AMGX.dDDI`
- `AMGX.dDFI`
- `AMGX.dFFI`


### `Vector`

An `AMGXVector` is created from a resource object with a given mode.

```julia
v = AMGX.AMGXVector(resources, AMGX.dDDI)
```

Data can then be uploaded to the vectorusing `upload!`:

```julia
AMGX.upload!(v, [1.0, 2.0, 3.0])
```

Optionally, the "block dimension" can be given:

```julia
v_block = AMGX.AMGXVector(resources, AMGX.dDDI)
AMGX.upload!(v_block, [1.0, 2.0, 3.0, 4.0]; block_dim=2)
```

Data can be downloaded from the vector (for example after solving a system) using `Vector`:

```julia
v_h = Vector(v)
```

It is also possible to download to a preallocated buffer using `copy!`:

```julia
v_h_buffer = zeros(3)
copy!(v_h_buffer, v)
```

Note that data can be uploaded / downloaded from arrays already allocated on the GPU (`CuArray`):

```julia
using CUDA
v_cu = AMGX.AMGXVector(resources, AMGX.dDDI)
cu = CuVector([1.0, 2.0, 3.0])
AMGX.upload!(v_cu, cu)
cu_buffer = CUDA.zeros(Float64, 3)
copy!(cu_buffer, v_cu)
```

A vector can be set to zero:

```julia
v_zero = AMGX.AMGXVector(resources, AMGX.dDDI)
AMGX.set_zero!(v_zero, 5)
```


### `AMGXMatrix`

Matrices in AMGX are stored in CSR format (as opposed to CSC which is typically used in Julia).
An `AMGXMatrix` is created from a `Resources` and a `mode`:

```julia
matrix = AMGX.AMGXMatrix(resources, AMGX.dDDI)
```

Data can be uploaded to it using the 3 CSR arrays:

```julia
AMGX.upload!(matrix, 
    Cint[0, 1, 3], # row_ptrs
    Cint[1, 0, 1], # col_indices
    [1.0, 2.0, 3.0] # data
)
```

These arrays can also be uploaded from `CuArrays` already residing on the GPU.

Alternatively, a `CUDA.CUSPARSE.CuSparseMatrixCSR` can be directly uploaded.

The non zero values can be replaced:

```julia
AMGX.replace_coefficients!(matrix, [3.0, 2.0, 1.0])
```

### `Solver`

A solver is created from a `Resources`, a `Mode`, and a `Config`:

```julia
solver = AMGX.Solver(resources, AMGX.dDDI, config)
```

A system can now be solved as:

```julia
x = AMGX.AMGXVector(resources, AMGX.dDDI)
AMGX.set_zero!(x, 3)
AMGX.setup!(solver, matrix)
AMGX.solve!(x, solver, v)
```

The solution vector can now be downloaded:

```julia
Vector(x)
```

After a solve, the status can be retrieved using `AMGX.get_status(solver)`. It is of type `AMGX.SolverStatus` and can be either:

- `AMGX.SUCCESS`
- `AMGX.FAILED`
- `AMGX.DIVERGED`
- `AMGX.NOT_CONVERGED`

The total number of iterations can be retrieved with `AMGX.get_iterations_number(solver)`.

The residual for a given iteration can be retrieved with

```julia
AMGX.get_iteration_residual(solver)
AMGX.get_iteration_residual(solver, 0)
```

### Utilities

#### Version information

The API version is retrieved with `AMGX.api_version()`.
Some more version info can be printed using `AMGX.versioninfo()`.

#### Pinning/Unpinning memory

For performance, it is recommended to pin host memory before uploading it to the GPU. Pinning and unpinning of memory is done using:

```julia
v = rand(5)
AMGX.pin_memory(v)
AMGX.unpin_memory(v)
``` 

#### Print callback

By default, the AMGX library prints various things to `stdout`. This can be overridden by registering a print callback, which is a Julia function accepting a `String` and returning `nothing`:

```julia
str = ""
store_to_str(amgx_printed::String) = (global str = amgx_printed; nothing)
AMGX.register_print_callback(store_to_str)
c_config = AMGX.Config("")
print(str)
print_stdout(amgx_printed::String) = print(stdout, amgx_printed)
AMGX.register_print_callback(print_stdout)
```


#### Signal handlers

Signal handlers can be installed and reset using:

```julia
AMGX.install_signal_handler()
AMGX.reset_signal_handler()
``` 

## Memory management and finalizing

You need to explicitly free memory of every AMGX object (`Config`, `Resources`, `AMGXVector`, `AMGXMatrix`, `Solver`) created using the julia call
`close`.
Using [Defer.jl](https://github.com/adambrewster/Defer.jl) can significantly
increase the convenience of this.

AMGX.jl contains a reference counting system so that it errors if you try to close things in the wrong order (e.g. closing the `Resources` object before the `AMGXVector` created from it is closed (destroyed))

When usage of the library is done, it should be finalized with:

```jl
AMGX.finalize_plugins()
AMGX.finalize()
```


## Not implemented:

The following functions from the C-API are not yet implemented:

- `AMGX_read_system`
- `AMGX_read_system_distributed`
- `AMGX_write_system`
- `AMGX_write_system_distributed`
- `AMGX_config_create_from_file`
- `AMGX_config_get_default_number_of_rings`
- `AMGX_resources_create` (only simple is currently wrapped)
- `AMGX_matrix_upload_all_global`
- `AMGX_matrix_comm_from_maps`
- `AMGX_matrix_comm_from_maps_one_ring`
- `AMGX_vector_bind`
