# Utilities

## Version information

```julia
AMGX.api_version()   # the C API version, as a VersionNumber
AMGX.versioninfo()   # library version, build date, CUDA runtime and driver
```

## Pinning memory

Page-locking host memory makes transfers to and from the GPU faster:

```julia
v = rand(5)
AMGX.pin_memory(v)
# ... upload / download ...
AMGX.unpin_memory(v)
```

Unpin before the array is freed.

## Print callback

By default AMGX writes to `stdout`. Route it somewhere else — or silence it —
with a callback taking a `String`:

```julia
AMGX.register_print_callback(_ -> nothing)             # silence AMGX

captured = String[]
AMGX.register_print_callback(s -> (push!(captured, s); nothing))

AMGX.register_print_callback(s -> print(stdout, s))    # restore
```

This can be set before [`AMGX.initialize`](@ref).

!!! note
    AMGX 2.5 prints considerably less than 2.4 did. Creating a config from an
    empty string, for instance, used to emit a warning and is now silent.

## Signal handlers

AMGX can install its own handler, which prints a stack trace on a fatal signal:

```julia
AMGX.install_signal_handler()
AMGX.reset_signal_handler()
```
