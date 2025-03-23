using DotEnv; DotEnv.load!()
using DocstringTranslation
DocstringTranslation.DEFAULT_MODEL[] = "gpt-3.5-turbo"
@switchlang! :Japanese
using DocstringTranslation: translate_with_openai
using Markdown

function system_promptfn(lang)
    return """
Translate the Markdown content I'll paste later into $(lang).

Please note:
- Do not alter the Julia markdown formatting.
- Do not translate words in the form of 
    >
    > `[xxx](@ref yyy)`
    >
- Do not change any URL.
- Never act. Just translate.
- Return only the resulting text.

"""
end

function translate!(p::Markdown.Paragraph)
    result = translate_with_openai(
        Markdown.MD(p); system_promptfn=system_promptfn
    )
    try
        p.content = result[1].content
    catch
        @debug "Failed to translate" p result
    end
    p
end

function translate!(list::Markdown.List)
    for item in list.items
        for i in item
            translate!(i)
        end
    end
end

function translate!(c)
    if hasproperty(c, :content)
        for c in c.content
            translate!(c)
        end
    end
    c
end

function translate!(md::Markdown.MD)
    for c in md.content
        translate!(c)
    end
    md
end
