module AMGX

using Libdl
using CUDA
using JSON

const libamgx = Ref{String}()
libAMGX = joinpath(homedir(), "Applications/AMGX/build/libamgxsh.so")

module API
    using CEnum
    import ..libAMGX

    libdir = joinpath(@__DIR__, "..", "lib")
    include(joinpath(libdir, "libAMGX_common.jl"))
    include(joinpath(libdir, "libAMGX.jl"))
end

include("errors.jl")
include("Mode.jl")
include("Config.jl")
include("Resources.jl")
include("Vector.jl")


initialize()         = @checked API.AMGX_initialize()
initialize_plugins() = @checked API.AMGX_initialize_plugins()
finalize()           = @checked API.AMGX_finalize()
finalize_plugins()   = @checked API.AMGX_finalize_plugins()

function __init__()
    initialize()
    initialize_plugins()
    atexit(finalize)
    atexit(finalize_plugins)
end

end # module
