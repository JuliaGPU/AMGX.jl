using Documenter
using AMGX

makedocs(;
    sitename = "AMGX.jl",
    authors = "JuliaHub",
    modules = [AMGX],
    format = Documenter.HTML(;
        canonical = "https://juliagpu.github.io/AMGX.jl",
        prettyurls = get(ENV, "CI", nothing) == "true",
    ),
    pages = [
        "Home" => "index.md",
        "Usage" => [
            "Configuration" => "config.md",
            "Vectors and matrices" => "arrays.md",
            "Solving" => "solving.md",
        ],
        "Memory management" => "memory.md",
        "Utilities" => "utilities.md",
        "API reference" => "api.md",
    ],
    # The examples need a GPU, so they are not run as doctests.
    doctest = false,
    checkdocs = :exports,
)

deploydocs(;
    repo = "github.com/JuliaGPU/AMGX.jl.git",
    push_preview = true,
)
