"""
    Config(content::String)
    Config(d::Dict)

An AMGX configuration, holding the parameters that control how a [`Solver`](@ref)
behaves.

It can be built from a comma-separated AMGX config string, or from a dictionary
whose pairs are joined into one:

```julia
cfg = AMGX.Config("max_iters=10, monitor_residual=1")
cfg = AMGX.Config(Dict("max_iters" => 10, "monitor_residual" => 1))
```

The accepted parameters are those of the AMGX library itself; see the [AMGX
reference manual](https://github.com/NVIDIA/AMGX/blob/main/doc/AMGX_Reference.pdf).
An unknown parameter raises an [`AMGXException`](@ref).

Must be freed with `close` once no longer needed; see the note on memory
management in the README.
"""
Base.@kwdef mutable struct Config <: AMGXObject
    handle::API.AMGX_config_handle = API.AMGX_config_handle(C_NULL)
    ref_count::Threads.Atomic{Int} = Threads.Atomic{Int}(0)
    function Config(handle::API.AMGX_config_handle, ref_count::Threads.Atomic{Int})
        config = new(handle, ref_count)
        finalizer(warn_not_destroyed_on_finalize, config)
        return config
    end
end
get_api_destroy_call(::Type{Config}) = API.AMGX_config_destroy
dec_refcount_parents(config::Config) = nothing

function create!(config::Config, content::String)
    cfg_handle_ptr = Ref{API.AMGX_config_handle}()
    @checked API.AMGX_config_create(cfg_handle_ptr, content)
    config.handle = cfg_handle_ptr[]
    return config
end
Config(content::String) = create!(Config(), content)

function create!(config::Config, d::Dict)
    buf = IOBuffer()
    for (key, val) in d
        write(buf, "$key=$val,")
    end
    create!(config, String(take!(buf)))
end
Config(d::Dict) = create!(Config(), d)

