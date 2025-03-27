function istranslated(md::Markdown.MD)
    cachedir = TRANSLATION_CACHE_DIR[]
    lang = DEFAULT_LANG[]
    isfile(joinpath(cachedir, hashmd(md), lang * ".md"))
end

function load_translation(hash::String)
    cachedir = TRANSLATION_CACHE_DIR[]
    lang = DEFAULT_LANG[]
    Markdown.parse(
        postprocess_content(read(joinpath(cachedir, hash, lang * ".md"), String)),
    )
end

function cache_translation(hash::String, transmd::Markdown.MD)
    cachedir = TRANSLATION_CACHE_DIR[]
    lang = DEFAULT_LANG[]
    mkpath(joinpath(cachedir, hash))
    write(joinpath(cachedir, hash, lang * ".md"), string(transmd))
end
