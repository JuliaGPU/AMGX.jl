mutable struct Config
    handle::API.AMGX_config_handle
    function Config(handle::API.AMGX_config_handle)
        cfg = new(handle)
        finalizer(destroy!, cfg)
        cfg
    end
end

function destroy!(cfg::Config)
    @checked API.AMGX_config_destroy(cfg.handle)
    cfg.handle = C_NULL
    return nothing
end

function Config(path::String)
    if !isfile(path)
        error("file $(repr(path)) not found")
    end
    cfg_handle_ptr = Ref{API.AMGX_config_handle}()
    @checked API.AMGX_config_create_from_file(cfg_handle_ptr, path)
    return Config(cfg_handle_ptr[])
end

function Config(d::Dict)
    mktemp() do path, io
        JSON.print(io, d)
        close(io)
        Config(path)
    end
end

