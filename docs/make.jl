using AMGX
using Documenter

makedocs(;
    modules=[AMGX],
    authors="Julia Computing",
    repo="https://github.com/KristofferC/AMGX.jl/blob/{commit}{path}#L{line}",
    sitename="AMGX.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://KristofferC.github.io/AMGX.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/KristofferC/AMGX.jl",
)
