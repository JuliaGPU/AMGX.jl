# AMGX.jl

*AMGX in Julia*

| **Documentation**                       | **Build Status**                                                    |
|:---------------------------------------:|:-------------------------------------------------------------------:|
| [![][docs-stable-img]][docs-stable-url] | [![][buildkite-img]][buildkite-url] [![][codecov-img]][codecov-url] |

The AMGX.jl package provides an interface for using NVIDIA's [AMGX](https://github.com/NVIDIA/AMGX) library from the Julia language.

[docs-stable-img]: https://img.shields.io/badge/docs-stable-blue.svg
[docs-stable-url]: https://juliagpu.github.io/AMGX.jl/stable/

[buildkite-img]: https://badge.buildkite.com/ce21dc6bf28e053c02c8c726ea0c65cc981a22ec2934e01e56.svg?branch=master
[buildkite-url]: https://buildkite.com/julialang/amgx-dot-jl

[codecov-img]: https://codecov.io/gh/JuliaGPU/AMGX.jl/branch/master/graph/badge.svg
[codecov-url]: https://codecov.io/gh/JuliaGPU/AMGX.jl

## Installation

```julia
using Pkg; Pkg.add("AMGX")
```

Prebuilt binaries are available for Linux. On other systems you need a local AMGX
build; point `JULIA_AMGX_PATH` at the shared library before loading the package.

## Quick start

```julia
using AMGX, CUDA, SparseArrays

AMGX.initialize()

config    = AMGX.Config(Dict("monitor_residual" => 1, "max_iters" => 100))
resources = AMGX.Resources(config)

A = sparse([1,1,2,2,3,3], [1,2,2,3,1,3], [4.0,1.0,4.0,1.0,1.0,4.0], 3, 3)

matrix = AMGX.AMGXMatrix(resources, AMGX.dDDI)
AMGX.upload!(matrix, CUDA.CUSPARSE.CuSparseMatrixCSR(A))

rhs = AMGX.AMGXVector(resources, AMGX.dDDI)
AMGX.upload!(rhs, [1.0, 2.0, 3.0])

x = AMGX.AMGXVector(resources, AMGX.dDDI)
AMGX.set_zero!(x, 3)

solver = AMGX.Solver(resources, AMGX.dDDI, config)
AMGX.setup!(solver, matrix)
AMGX.solve!(x, solver, rhs)

@show AMGX.get_status(solver)
@show Vector(x)

# AMGX objects are not garbage collected: close them, children before parents
foreach(close, (solver, x, rhs, matrix, resources, config))
AMGX.finalize()
```

Note that AMGX objects must be closed explicitly and in the right order — see
[Memory management](https://juliagpu.github.io/AMGX.jl/stable/memory/) — and that
a solve which does not converge is not an error, so `get_status` should always be
checked.

## Documentation

Full documentation is at
[juliagpu.github.io/AMGX.jl](https://juliagpu.github.io/AMGX.jl/dev/), covering
configuration, vectors and matrices, solving, memory management, the utility
functions, and the complete API reference.

Reading the [official AMGX reference
manual](https://github.com/NVIDIA/AMGX/blob/main/doc/AMGX_Reference.pdf) is also
recommended — the configuration parameters are AMGX's own.
