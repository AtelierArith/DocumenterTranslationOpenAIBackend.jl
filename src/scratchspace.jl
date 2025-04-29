function istranslated(md::Markdown.MD)
    cachedir = joinpath(TRANSLATION_CACHE_DIR[], hashmd(md))
    lang = DEFAULT_LANG[]
    mdpath = joinpath(cachedir, lang * ".md")
    isfile(mdpath)
end

function load_translation(hash::String)
    cachedir = joinpath(TRANSLATION_CACHE_DIR[], hash)
    lang = DEFAULT_LANG[]
    mdpath = joinpath(cachedir, lang * ".md")
    Markdown.parse(postprocess_content(read(mdpath, String)))
end

function cache_original(md::Markdown.MD)
    cachedir = joinpath(TRANSLATION_CACHE_DIR[], hashmd(md))
    mkpath(cachedir)
    mdpath = joinpath(cachedir, "original.md")
    write(mdpath, string(md))
end

function cache_translation(hash::String, transmd::Markdown.MD)
    cachedir = joinpath(TRANSLATION_CACHE_DIR[], hash)
    lang = DEFAULT_LANG[]
    mdpath = joinpath(cachedir, lang * ".md")
    mkpath(cachedir)
    write(mdpath, string(transmd))
end
