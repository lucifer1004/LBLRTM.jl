using LBLRTM
using Documenter

makedocs(;
    modules=[LBLRTM],
    authors="Gabriel Wu <wuzihua@pku.edu.cn> and contributors",
    repo="https://github.com/lucifer1004/LBLRTM.jl/blob/{commit}{path}#L{line}",
    sitename="LBLRTM.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://lucifer1004.github.io/LBLRTM.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/lucifer1004/LBLRTM.jl",
)
