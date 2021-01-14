struct AMGXException <: Exception
    e::String
end

function error_string(err_code)
    buf = zeros(UInt8, 1024)
    GC.@preserve buf begin
        cstr = Cstring(pointer(buf))
        v = API.AMGX_get_error_string(err_code, cstr, length(buf))
        if v == API.AMGX_RC_OK
            return unsafe_string(cstr)
        else
            return "error occured when getting error string for error code $(err_code)"
        end
    end
end

macro checked(expr)
    return quote
        v = $(esc(expr))::API.AMGX_RC
        if v != API.AMGX_RC_OK
            throw(AMGXException(error_string(v)))
        end
        nothing
    end
end
