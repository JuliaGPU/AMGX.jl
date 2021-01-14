# generate AMGX wrappers

using Clang

const LIBAMGX_INCLUDE = joinpath(homedir(), "Applications/AMGX/base/include")
const LIBAMGX_HEADERS = [joinpath(homedir(), "Applications/AMGX/base/include/amgx_c.h"),
                         joinpath(homedir(), "Applications/AMGX/base/include/amgx_config.h")]


wc = init(; headers = LIBAMGX_HEADERS,
            output_file = joinpath(@__DIR__, "libAMGX.jl"),
            common_file = joinpath(@__DIR__, "libAMGX_common.jl"),
            clang_includes = [LIBAMGX_INCLUDE,],
            clang_args = ["-I", joinpath(LIBAMGX_INCLUDE, "..")],
            header_wrapped = (root, current)->root == current,
            header_library = x->"libAMGX",
            )

function main()
    cd(joinpath(@__DIR__, "..", "lib")) do
        run(wc)
    end
end

# TODO, this seems to put things in res instead of lib
isinteractive() || main()
