using Documenter
using AMGX
using CUDA

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
        "Preconditioning" => "preconditioner.md",
        "Memory management" => "memory.md",
        "Utilities" => "utilities.md",
        "API reference" => "api.md",
    ],
    # The doctests drive a real solver, so they can only run where a GPU is
    # available. On CPU-only CI they are skipped rather than failing.
    doctest = CUDA.functional(),
    checkdocs = :exports,
)

deploydocs(;
    repo = "github.com/JuliaGPU/AMGX.jl.git",
    push_preview = true,
)
