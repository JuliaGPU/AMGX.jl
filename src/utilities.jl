##################
# Initialization #
##################

initialize() = @checked API.AMGX_initialize()
initialize_plugins() = @checked API.AMGX_initialize_plugins()
finalize() = @checked API.AMGX_finalize()
finalize_plugins() = @checked API.AMGX_finalize_plugins()


##############
# Versioning #
##############

function api_version()
    major, minor = Ref{Cint}(), Ref{Cint}()
    @checked API.AMGX_get_api_version(major, minor)
    VersionNumber(major[], minor[])
end

function build_info()
    ref_version = Ref{Cstring}()
    ref_date = Ref{Cstring}()
    ref_time = Ref{Cstring}()
    @checked API.AMGX_get_build_info_strings(ref_version, ref_date, ref_time)
    return unsafe_string(ref_version[]), unsafe_string(ref_date[]), unsafe_string(ref_time[])
end

function versioninfo(io::IO=stdout)
    version, date, time = build_info()
    println(io, "AMGX version $(version)")
    println(io, "Built on $(date), $(time)")
    print(io, "API version $(api_version())")
end


###########
# Pinning #
###########

function pin_memory(v::Vector)
    GC.@preserve v begin
        pin_memory(pointer(v), sizeof(v))
    end
end

function pin_memory(ptr::Ptr, n_bytes::Int)
    @checked API.AMGX_pin_memory(ptr, n_bytes)
end

function unpin_memory(v::Vector)
    GC.@preserve v begin
        unpin_memory(pointer(v))
    end
end

function unpin_memory(ptr::Ptr)
    @checked API.AMGX_unpin_memory(ptr)
end


##################
# Print callback #
##################

# This can be set before initializing the library
function register_print_callback(f)
    run_f(str::Cstring, _::Cint) = f(unsafe_string(str))
    f_cfunc = @cfunction($run_f, Cvoid, (Cstring, Cint)) 
    @checked API.AMGX_register_print_callback(f_cfunc)
end


##################
# Signal handler #
##################

install_signal_handler() = @checked API.AMGX_install_signal_handler()
reset_signal_handler() = @checked API.AMGX_reset_signal_handler()
