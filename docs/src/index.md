# AMGX.jl

AMGX.jl wraps NVIDIA's [AMGX](https://github.com/NVIDIA/AMGX), a GPU-accelerated
algebraic multigrid solver library, for use from Julia.

Reading the [official AMGX reference
manual](https://github.com/NVIDIA/AMGX/blob/main/doc/AMGX_Reference.pdf) is
recommended — the configuration parameters in particular are AMGX's own, and this
package does not redocument them.

## Installation

```julia
using Pkg; Pkg.add("AMGX")
```

Prebuilt binaries are available for Linux. On other systems you need a local
AMGX build; point `JULIA_AMGX_PATH` at the shared library before loading the
package:

```julia
ENV["JULIA_AMGX_PATH"] = "/path/to/libamgxsh.so"
using AMGX
```

## A complete example

Solving a small system on the GPU:

```julia
using AMGX, CUDA, SparseArrays

AMGX.initialize()

config    = AMGX.Config(Dict("monitor_residual" => 1, "max_iters" => 100))
resources = AMGX.Resources(config)

A = sparse([1,1,2,2,3,3], [1,2,2,3,1,3], [4.0,1.0,4.0,1.0,1.0,4.0], 3, 3)
b = [1.0, 2.0, 3.0]

matrix = AMGX.AMGXMatrix(resources, AMGX.dDDI)
AMGX.upload!(matrix, CUDA.CUSPARSE.CuSparseMatrixCSR(A))

rhs = AMGX.AMGXVector(resources, AMGX.dDDI)
AMGX.upload!(rhs, b)

x = AMGX.AMGXVector(resources, AMGX.dDDI)
AMGX.set_zero!(x, 3)

solver = AMGX.Solver(resources, AMGX.dDDI, config)
AMGX.setup!(solver, matrix)
AMGX.solve!(x, solver, rhs)

@show AMGX.get_status(solver)
@show Vector(x)

# AMGX objects are not garbage collected: close them, children before parents
for obj in (solver, x, rhs, matrix, resources, config)
    close(obj)
end

AMGX.finalize()
```

See [Memory management](@ref) for why the `close` calls are necessary and how
[Defer.jl](https://github.com/adambrewster/Defer.jl) makes them less tedious.

## Not implemented

These C API functions are not yet wrapped:

- `AMGX_read_system`, `AMGX_read_system_distributed`
- `AMGX_write_system`, `AMGX_write_system_distributed`
- `AMGX_config_create_from_file`
- `AMGX_config_get_default_number_of_rings`
- `AMGX_matrix_upload_all_global`
- `AMGX_matrix_comm_from_maps`, `AMGX_matrix_comm_from_maps_one_ring`
- `AMGX_vector_bind`

The multi-GPU and distributed APIs are tracked in
[#8](https://github.com/JuliaGPU/AMGX.jl/issues/8), which depends on MPI support
in the JLL ([#7](https://github.com/JuliaGPU/AMGX.jl/issues/7)).
