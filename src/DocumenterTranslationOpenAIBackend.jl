module DocumenterTranslationOpenAIBackend

using Base.Docs: DocStr

using SHA
using Markdown

using Scratch
import Documenter

using OpenAI

const DEFAULT_LANG = Ref{String}()
const TRANSLATION_CACHE_DIR = Ref{String}()

include("util.jl")
include("scratchspace.jl")

include("openai.jl")
export swithcmodel!

include("switchlang.jl")
export @switchlang!

function __init__()
    global TRANSLATION_CACHE_DIR[] = @get_scratch!("translation")
end

end # module DocumenterTranslationOpenAIBackend
