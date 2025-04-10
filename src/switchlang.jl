
function _switchlang!(lang::Union{String,Symbol})
    DEFAULT_LANG[] = String(lang)
end

"""
	@switchlang!(lang)

Modify Docs.parsedoc(d::DocStr) to insert translation engine.
"""
macro switchlang!(lang)
    @eval function Docs.parsedoc(d::DocStr)
        if d.object === nothing
            md = Docs.formatdoc(d)
            md.meta[:module] = d.data[:module]
            md.meta[:path] = d.data[:path]
            d.object = md
        end
        cache_original(d.object)
        hash = hashmd(d.object)
        if istranslated(d.object)
            transmd = load_translation(hash)
            return transmd
        else
            transmd = translate_docstring_with_openai(d.object)
            cache_translation(hash, transmd)
            return transmd
        end
    end

    # Overrides Page constructor to hack Documenter to translate docstrings
    @eval function Documenter.Page(
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

        mdsrc = replace(read(source, String), '\r' => "")
        mdpage = Markdown.parse(mdsrc)
        cache_original(mdpage)
        @info "Translating ..." mdpage
        hashvalue = hashmd(mdpage)
        if !istranslated(mdpage)
            # Update mdpage object
            mdpage = translate_md!(mdpage)
            # end DocstringTranslationOllamaBackend
            cache_translation(hashvalue, mdpage)
        else
            mdpage = load_translation(hashvalue)
        end
        @info "Translated" mdpage
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
    quote
        local _lang = $(esc(lang))
        _switchlang!(_lang)
    end
end
