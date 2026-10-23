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

Released when garbage collected, or earlier with `close`.
"""
Base.@kwdef mutable struct Config <: AMGXObject
    handle::API.AMGX_config_handle = API.AMGX_config_handle(C_NULL)
    ref_count::Int = 0
    closed::Bool = false
    session::Int = 0
    function Config(handle::API.AMGX_config_handle, ref_count::Int, closed::Bool, session::Int)
        config = new(handle, ref_count, closed, session)
        finalizer(enqueue_finalized, config)
        return config
    end
end
get_api_destroy_call(::Type{Config}) = API.AMGX_config_destroy
release_parents!(::Config) = nothing

function create!(config::Config, content::String)
    drain_pending!()
    cfg_handle_ptr = Ref{API.AMGX_config_handle}()
    @checked API.AMGX_config_create(cfg_handle_ptr, content)
    return set_handle!(config, cfg_handle_ptr[])
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

