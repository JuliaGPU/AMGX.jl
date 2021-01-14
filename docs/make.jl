using AMGX
using Documenter

makedocs(;
    modules=[AMGX],
    authors="Julia Computing",
    repo="https://github.com/JuliaComputing/AMGX.jl/blob/{commit}{path}#L{line}",
    sitename="AMGX.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://JuliaComputing.github.io/AMGX.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/JuliaComputing/AMGX.jl",
)
