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

initialize()         = @checked API.AMGX_initialize()
initialize_plugins() = @checked API.AMGX.initialize_plugins()
finalize()           = @checked API.AMGX_finalize()
finalize_plugins()   = @checked API.AMGX.finalize_plugins()

include("Config.jl")
include("Resources.jl")

end # module
