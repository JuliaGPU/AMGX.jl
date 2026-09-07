# Configuration

## Initialization

```julia
using AMGX
AMGX.initialize()
```

Pair this with [`AMGX.finalize`](@ref) when you are done; see
[Memory management](@ref).

## `Config`

A [`AMGX.Config`](@ref) holds the parameters controlling a solver. It can be
built from a dictionary or from an AMGX config string:

```julia
config = AMGX.Config(Dict("monitor_residual" => 1, "max_iters" => 10, "store_res_history" => 1))
config = AMGX.Config("monitor_residual=1, max_iters=10")
```

The accepted keys are AMGX's own — see the reference manual. An unknown
parameter raises an [`AMGX.AMGXException`](@ref).

## `Resources`

[`AMGX.Resources`](@ref) is created from a `Config`:

```julia
resources = AMGX.Resources(config)
```

By default AMGX runs on the current device. Pass `device_id` — a zero-based
index in CUDA's numbering — to pin it to a particular GPU:

```julia
CUDA.device!(1)
resources = AMGX.Resources(config; device_id=1)
```

!!! warning
    `device_id` moves AMGX only. Data uploaded from `CuArray`s is allocated on
    CUDA.jl's *current* device, so uploading device arrays into resources bound
    to a different device fails with `CUDA kernel launch error`. Set
    `CUDA.device!` to match, as above. Uploads from host arrays are copied by
    AMGX itself and are unaffected.

## `Mode`

A [`AMGX.Mode`](@ref) selects where AMGX runs and at what precision:

| Mode | Runs on | Vectors | Matrix |
|:--|:--|:--|:--|
| `hDDI` | host | `Float64` | `Float64` |
| `hDFI` | host | `Float64` | `Float32` |
| `hFFI` | host | `Float32` | `Float32` |
| `dDDI` | device | `Float64` | `Float64` |
| `dDFI` | device | `Float64` | `Float32` |
| `dFFI` | device | `Float32` | `Float32` |

Julia arrays passed to `upload!` must match the precision the mode declares.

!!! note
    Upstream AMGX does not support mixed-precision GPU *solves* on CUDA 10.1 or
    later. Use `dDDI` or `dFFI` for solving; `dDFI` still supports uploads and
    downloads.
