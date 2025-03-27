module DocumenterTranslationOpenAIBackend

using Base.Docs: DocStr

using SHA
using Markdown

using Scratch
using Base: Docs
using Documenter

using OpenAI
const DEFAULT_MODEL = Ref{String}("gpt-4o-mini-2024-07-18")
function default_model()
    return DEFAULT_MODEL[]
end

function default_system_promptfn(lang=default_lang())
    return """
Translate the Markdown content I'll paste later into $(lang).

Please note:
- Do not alter the Julia markdown formatting.
- Do not change code fence such as jldoctest or math.
- Do not change words in the form of `[xxx](@ref)`.
- Do not change any URL.
- If $(lang) indicates English (e.g., "en"), return the input unchanged.

Return only the resulting text.
"""
end

function postprocess_content(content::AbstractString)
    # Replace each match with the text wrapped in a math code block
    return replace(
        content, 
        r":\$(.*?):\$"s => s"```math\1```",
        r"\$\$(.*?)\$\$"s => s"```math\1```"
        )
end

function translate_docstring_with_openai(
    doc::Union{Markdown.MD, AbstractString};
    lang::String = default_lang(),
    model::String = default_model(),
    system_promptfn = default_system_promptfn,
)
    c = create_chat(
        ENV["OPENAI_API_KEY"],
        model,
        [
            Dict("role" => "system", "content" => system_promptfn(lang)),
            Dict("role" => "user", "content" => string(doc)),
        ];
        temperature=0.1,
    )
    content = c.response[:choices][begin][:message][:content]
    content = postprocess_content(content)
    return Markdown.parse(content)
end


const DEFAULT_LANG = Ref{String}()
const TRANSLATION_CACHE_DIR = Ref{String}()

export @switchlang!

greet() = print("Hello World!")

function default_lang()
    return DEFAULT_LANG[]
end

function _switchlang!(lang::Union{String,Symbol})
    DEFAULT_LANG[] = String(lang)
end

function _switchlang!(node::QuoteNode)
    lang = node.value
    _switchlang!(lang)
end

function hashmd(md::Markdown.MD)::String
	return bytes2hex(sha256(string(md)))
end

function istranslated(md::Markdown.MD)
	cachedir = TRANSLATION_CACHE_DIR[]
	lang = DEFAULT_LANG[]
	isfile(joinpath(cachedir, hashmd(md), lang * ".md"))
end

function load_translation(hash::String)
	cachedir = TRANSLATION_CACHE_DIR[]
	lang = DEFAULT_LANG[]
	Markdown.parse(
		postprocess_content(read(joinpath(cachedir, hash, lang * ".md"), String))
	)
end

function cache_translation(hash::String, transmd::Markdown.MD)
	cachedir = TRANSLATION_CACHE_DIR[]
	lang = DEFAULT_LANG[]
	mkpath(joinpath(cachedir, hash))
	write(joinpath(cachedir, hash, lang * ".md"), string(transmd))
end

"""
	@switchlang!(lang)

Modify Docs.parsedoc(d::DocStr) to insert translation engine.
"""
macro switchlang!(lang)
    _switchlang!(lang)
    @eval function Docs.parsedoc(d::DocStr)
        if d.object === nothing
            md = Docs.formatdoc(d)
            md.meta[:module] = d.data[:module]
            md.meta[:path] = d.data[:path]
            d.object = md
        end
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
end

function __init__()
	global TRANSLATION_CACHE_DIR[] = @get_scratch!("translation")
end

end # module DocumenterTranslationOpenAIBackend