mutable struct Resources
    handle::API.AMGX_resources_handle
    ref_count::Threads.Atomic{Int}
    function Resources(handle::API.AMGX_resources_handle)
        res = new(handle, Threads.Atomic{Int}(0))
        finalizer(destroy!, res)
    end
end

function destroy!(res::Resources)
    @assert res.ref_count[] == 0
    @checked API.AMGX_resources_destroy(res.handle)
    res.handle = C_NULL
    return nothing
end

function Resources(cfg::Config)
    res_handle_ptr = Ref{API.AMGX_resources_handle}()
    @checked API.AMGX_resources_create_simple(res_handle_ptr, cfg.handle)
    return Resources(res_handle_ptr[])
end

