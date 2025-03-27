using DotEnv;
DotEnv.load!();
using DocstringTranslation
# @switchlang! :Japanese
using DocstringTranslation: translate_with_openai
using Markdown

using Documenter

function system_promptfn(lang)
    return """
Translate the Markdown content or text I'll paste later into $(lang).

You must strictly follow the rules below.

- Do not alter the Markdown formatting.
- Return only the resulting text.
"""
end

function create_hex(l::Markdown.Link)
    (bytes2hex(codeunits(join(l.text))) * "_" * bytes2hex(codeunits(l.url)))
end

function translate!(p::Markdown.Paragraph)
    hex2link = Dict()
    link2hex = Dict()
    content = map(p.content) do c
        # Protect Link so that it does not break during translation
        if c isa Markdown.Link
            h = create_hex(c)
            hex2link[string(h)] = c
            link2hex[c] = h
            "`" * h * "`"
        else
            c
        end
    end
    p_orig = deepcopy(p)
    p.content = content
    result = translate_with_openai(Markdown.MD(p), lang = "Japanese")
    try
        translated_content = map(result[1].content) do c
            if c isa Markdown.Code
                if isempty(c.language)
                    c = get(hex2link, c.code, c)
                else
                    c
                end
            else
                c
            end
        end
        p.content = translated_content
    catch e
        @warn "Failed to translate by $(e)" p
        return p_orig
    end
    return p
end

function translate!(list::Markdown.List)
    for item in list.items
        Base.Threads.@threads for i in item
            translate!(i)
        end
    end
end

function translate!(c)
    if hasproperty(c, :content)
        Base.Threads.@threads for c in c.content
            translate!(c)
        end
    end
    c
end

function translate!(md::Markdown.MD)
    Base.Threads.@threads for c in md.content
        translate!(c)
    end
    md
end

# Overrides Page constructor to hack Documenter to translate docstrings
function Documenter.Page(
    source::AbstractString,
    build::AbstractString,
    workdir::AbstractString,
)
    # The Markdown standard library parser is sensitive to line endings:
    #   https://github.com/JuliaLang/julia/issues/29344
    # This can lead to different AST and therefore differently rendered docs, depending on
    # what platform the docs are being built (e.g. when Git checks out LF files with
    # CRFL line endings on Windows). To make sure that the docs are always built consistently,
    # we'll normalize the line endings when parsing Markdown files by removing all CR characters.

    if !isfile(joinpath("jp", relpath(source)))
        mdsrc = replace(read(source, String), '\r' => "")
        mdpage = Markdown.parse(mdsrc)
        @info "Translating ..." mdpage
        mdpage = translate!(mdpage)
        @info "Translated" mdpage
        # end DocstringTranslationOllamaBackend
        mkpath(dirname(joinpath("jp", relpath(source))))
        write(joinpath("jp", relpath(source)), string(mdpage))
    else
        @info "Translating ..." joinpath("jp", relpath(source))
        mdsrc = replace(read(joinpath("jp", relpath(source)), String), '\r' => "")
        mdpage = Markdown.parse(mdsrc)
    end
    # end DocstringTranslationOllamaBackend
    mdast = try
        convert(Documenter.MarkdownAST.Node, mdpage)
    catch err
        @error """
        MarkdownAST conversion error on $(source).
        This is a bug — please report this on the Documenter issue tracker
        """
        rethrow(err)
    end
    return Documenter.Page(
        source,
        build,
        workdir,
        mdpage.content,
        Documenter.Globals(),
        mdast,
    )
end
