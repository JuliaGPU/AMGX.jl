struct AMGXException <: Exception
    e::String
end

function error_string(err_code)
    buf = zeros(UInt8, 1024)
    GC.@preserve buf begin
        cstr = Cstring(pointer(buf))
        API.AMGX_get_error_string(err_code, cstr, length(buf))
        return unsafe_string(cstr)
    end
end

macro checked(expr)
    return quote
        v = $(esc(expr))
        if v != AMGX_RC_OK
            throw(AMGXException(error_string(v)))
        end
        return nothing
    end
end
