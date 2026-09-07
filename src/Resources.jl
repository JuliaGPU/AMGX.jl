Base.@kwdef mutable struct Resources <: AMGXObject
    handle::API.AMGX_resources_handle = API.AMGX_resources_handle(C_NULL)
    ref_count::Threads.Atomic{Int} = Threads.Atomic{Int}(0)
    cfg::Union{Config, Nothing} = nothing
    function Resources(handle::API.AMGX_resources_handle, ref_count::Threads.Atomic{Int},
                       cfg::Union{Config, Nothing})
        resources = new(handle, ref_count, cfg)
        finalizer(warn_not_destroyed_on_finalize, resources)
        return resources
    end
end
get_api_destroy_call(::Type{Resources}) = API.AMGX_resources_destroy
function dec_refcount_parents(resources::Resources)
    dec_refcount!(resources.cfg)
    resources.cfg = nothing
    nothing
end

"""
    create!(resources::Resources, cfg::Config; device_id=nothing)

Create AMGX `resources` from `cfg`.

`device_id` selects the CUDA device AMGX should run on, as a zero-based index
matching CUDA's own numbering. When it is `nothing` (the default) AMGX picks the
device itself, which is the current device for the calling thread.

!!! note
    `device_id` only moves AMGX. Data uploaded from `CuArray`s is allocated on
    CUDA.jl's *current* device, so uploading device arrays into resources bound
    to a different device fails with `CUDA kernel launch error`. Switch CUDA.jl
    to the same device first:

    ```julia
    CUDA.device!(1)
    resources = Resources(cfg; device_id=1)
    ```

    Uploads from ordinary host arrays are copied by AMGX itself and are
    unaffected by the current device.
"""
function create!(resources::Resources, cfg::Config;
                 device_id::Union{Integer, Nothing}=nothing)
    res_handle_ptr = Ref{API.AMGX_resources_handle}()
    if device_id === nothing
        @checked API.AMGX_resources_create_simple(res_handle_ptr, cfg.handle)
    else
        devices = Ref{Cint}(device_id)
        # A null communicator means the non-distributed path; one device.
        @checked API.AMGX_resources_create(res_handle_ptr, cfg.handle, C_NULL, 1, devices)
    end
    resources.handle = res_handle_ptr[]
    resources.cfg = cfg
    inc_refcount!(resources.cfg)
    return resources
end

"""
    Resources(cfg::Config; device_id=nothing)

Create AMGX resources from `cfg`, optionally pinning them to a specific CUDA
device. See [`create!`](@ref).
"""
Resources(cfg::Config; device_id::Union{Integer, Nothing}=nothing) =
    create!(Resources(), cfg; device_id)
