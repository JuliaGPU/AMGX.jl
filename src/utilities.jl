##################
# Initialization #
##################

"""
    initialize()

Initialize the AMGX library. Must be called before any other AMGX call, and
paired with [`finalize`](@ref).
"""
initialize() = @checked API.AMGX_initialize()

"""
    initialize_plugins()

Initialize AMGX's plugins. Pair with [`finalize_plugins`](@ref).
"""
initialize_plugins() = @checked API.AMGX_initialize_plugins()

"""
    finalize()

Shut the AMGX library down. All AMGX objects must be `close`d first.
"""
finalize() = @checked API.AMGX_finalize()

"""
    finalize_plugins()

Shut AMGX's plugins down, before [`finalize`](@ref).
"""
finalize_plugins() = @checked API.AMGX_finalize_plugins()


##############
# Versioning #
##############

"""
    api_version()

The AMGX C API version as a `VersionNumber`.
"""
function api_version()
    major, minor = Ref{Cint}(), Ref{Cint}()
    @checked API.AMGX_get_api_version(major, minor)
    VersionNumber(major[], minor[])
end

"""
    build_info()

The library's `(version, date, time)` build strings.
"""
function build_info()
    ref_version = Ref{Cstring}()
    ref_date = Ref{Cstring}()
    ref_time = Ref{Cstring}()
    @checked API.AMGX_get_build_info_strings(ref_version, ref_date, ref_time)
    return unsafe_string(ref_version[]), unsafe_string(ref_date[]), unsafe_string(ref_time[])
end

"""
    versioninfo(io=stdout)

Print the AMGX version, build date and API version, along with the CUDA runtime
and driver it was built against.
"""
function versioninfo(io::IO=stdout)
    version, date, time = build_info()
    println(io, "AMGX version $(version)")
    println(io, "Built on $(date), $(time)")
    print(io, "API version $(api_version())")
end


###########
# Pinning #
###########

"""
    pin_memory(v::Vector)

Page-lock `v` so transfers to and from the GPU are faster. Release it again with
[`unpin_memory`](@ref) before the array is freed.
"""
function pin_memory(v::Vector)
    GC.@preserve v begin
        pin_memory(pointer(v), sizeof(v))
    end
end

function pin_memory(ptr::Ptr, n_bytes::Int)
    @checked API.AMGX_pin_memory(ptr, n_bytes)
end

"""
    unpin_memory(v::Vector)

Undo [`pin_memory`](@ref).
"""
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

# The closure `@cfunction` below allocates a trampoline that is freed when the
# returned `CFunction` is garbage collected. AMGX keeps calling the raw pointer
# after that, so we have to keep the object alive for as long as it is
# registered.
const _print_callback = Ref{Any}(nothing)

"""
    register_print_callback(f)

Route everything AMGX would print through `f`, a function taking a `String` and
returning `nothing`. Can be called before [`initialize`](@ref).

```julia
AMGX.register_print_callback(_ -> nothing)          # silence AMGX
AMGX.register_print_callback(s -> print(stdout, s)) # restore
```
"""
# This can be set before initializing the library
function register_print_callback(f)
    run_f(str::Cstring, _::Cint) = f(unsafe_string(str))
    f_cfunc = @cfunction($run_f, Cvoid, (Cstring, Cint))
    _print_callback[] = f_cfunc
    @checked API.AMGX_register_print_callback(f_cfunc)
end


##################
# Signal handler #
##################

"""
    install_signal_handler()

Install AMGX's own signal handler, which prints a stack trace on a fatal signal.
"""
install_signal_handler() = @checked API.AMGX_install_signal_handler()

"""
    reset_signal_handler()

Undo [`install_signal_handler`](@ref).
"""
reset_signal_handler() = @checked API.AMGX_reset_signal_handler()
