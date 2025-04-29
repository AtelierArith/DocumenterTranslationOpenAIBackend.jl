function pathofcachedir(md::Markdown.MD)
	s = split(string(md.meta[:module]), ".")
	v = something(pkgversion(md.meta[:module]), VERSION)
	major = v.major
	minor = v.minor
	insert!(s, 2, "$(major).$(minor)")
	joinpath(TRANSLATION_CACHE_DIR[], s...)
end

function istranslated(md::Markdown.MD)
    cachedir = joinpath(pathofcachedir(md), hashmd(md))
    lang = DEFAULT_LANG[]
    mdpath = joinpath(cachedir, lang * ".md")
    isfile(mdpath)
end

function load_translation(md::Markdown.MD)
    cachedir = joinpath(pathofcachedir(md), hashmd(md))
    lang = DEFAULT_LANG[]
    mdpath = joinpath(cachedir, lang * ".md")
    Markdown.parse(postprocess_content(read(mdpath, String)))
end

function cache_original(md::Markdown.MD)
    cachedir = joinpath(pathofcachedir(md), hashmd(md))
    mkpath(cachedir)
    mdpath = joinpath(cachedir, "original.md")
    write(mdpath, string(md))
end

function cache_translation(md_hash_original::String, transmd::Markdown.MD)
    cachedir = joinpath(pathofcachedir(transmd), md_hash_original)
    lang = DEFAULT_LANG[]
    mdpath = joinpath(cachedir, lang * ".md")
    mkpath(cachedir)
    write(mdpath, string(transmd))
end
