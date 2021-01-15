mutable struct Resources
    handle::API.AMGX_resources_handle
    function Resources(handle::API.AMGX_resources_handle)
        res = new(handle)
        finalizer(destroy, res)
    end
end

function destroy(res::Resources)
    API.AMGX_resources_destroy(res.handle)
    res.handle = C_NULL
    return nothing
end

function Resources(cfg::Config)
    res_handle_ptr = Ref{API.AMGX_resources_handle}()
    API.AMGX_resources_create_simple(res_handle_ptr, cfg.handle)
    return Resources(res_handle_ptr[])
end

