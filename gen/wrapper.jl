# generate AMGX wrappers
using Clang
using Clang.Generators

using JuliaFormatter
using AMGX_jll


function main()
    amgx = joinpath(AMGX_jll.artifact_dir, "include")
    @assert AMGX_jll.is_available()

    args = get_default_args()
    push!(args, "-I$amgx")

    options = load_options(joinpath(@__DIR__, "amgx.toml"))

    # create context
    headers = ["$amgx/amgx_config.h", "$amgx/amgx_c.h"]
    targets = headers

    ctx = create_context(headers, args, options)
    build!(ctx)

    output_file = options["general"]["output_file_path"]
    format_file(output_file, YASStyle())
    return nothing
end

if abspath(PROGRAM_FILE) == @__FILE__
    main()
end
