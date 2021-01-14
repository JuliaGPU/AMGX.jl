mutable struct Config
    handle::API.AMGX_config_handle
    function Config(handle::API.AMGX_config_handle)
        v = new(handle)
        finalizer(v) do

        end
    end
end

function Config(path::String)
    if !isfile(path)
        error("file $(repr(path)) not found")
    end
    
    
end

function Config(d::Dict)
    mktemp() do (path, io)
        JSON.print(io, d)
        close(io)
        return Config(path)
    end
end

# API


# Higher level


