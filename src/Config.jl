Base.@kwdef mutable struct Config <: AMGXObject
    handle::API.AMGX_config_handle = C_NULL
    ref_count::Threads.Atomic{Int} = Threads.Atomic{Int}(0)
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
    str = sprint(JSON.print, d)
    create!(config, str)
end
Config(d::Dict) = create!(Config(), d)

