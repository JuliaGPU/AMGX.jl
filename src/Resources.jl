Base.@kwdef mutable struct Resources <: AMGXObject
    handle::API.AMGX_resources_handle = C_NULL
    ref_count::Threads.Atomic{Int} = Threads.Atomic{Int}(0)
    cfg::Union{Config, Nothing} = nothing
end
get_api_destroy_call(::Type{Resources}) = API.AMGX_resources_destroy
function dec_refcount_parents(resources::Resources)
    dec_refcount!(resources.cfg)
    resources.cfg = nothing
    nothing
end

function create!(resources::Resources, cfg::Config)
    res_handle_ptr = Ref{API.AMGX_resources_handle}()
    @checked API.AMGX_resources_create_simple(res_handle_ptr, cfg.handle)
    resources.handle = res_handle_ptr[]
    resources.cfg = cfg
    inc_refcount!(resources.cfg)
    return resources
end

Resources(cfg::Config) = create!(Resources(), cfg)
