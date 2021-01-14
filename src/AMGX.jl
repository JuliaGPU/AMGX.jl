module AMGX

using Libdl
using CUDA

const libamgx = Ref{String}()
libAMGX = joinpath(homedir(), "Applications/AMGX/build/libamgxsh.so")

module API
    using CEnum
    import ..libAMGX

    libdir = joinpath(@__DIR__, "..", "lib")
    include(joinpath(libdir, "libAMGX_common.jl"))
    include(joinpath(libdir, "libAMGX.jl"))
end

include("Config.jl")
include("errors.jl")

end # module
