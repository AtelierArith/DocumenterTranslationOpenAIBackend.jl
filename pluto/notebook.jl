### A Pluto.jl notebook ###
# v0.20.4

using Markdown
using InteractiveUtils

# ╔═╡ 463eec94-8fed-4947-a931-ae9422346ee0
begin
	using Markdown
	
	using Pkg
	Pkg.add(path=joinpath(@__DIR__, "../../DocstringTranslation.jl"))
	using DocstringTranslation
	using DocstringTranslation: translate_with_openai
	using DotEnv
	DotEnv.load!()
end

# ╔═╡ 3678dfcf-7344-4ca7-a5a2-841d8c6e6a72
Markdown.parse(read("Documenter.jl/docs/src/man/hosting/walkthrough.md", String))

# ╔═╡ d39fd752-7bf0-43b4-9e48-db7b94655b08
begin
	function create_hex(l::Markdown.Link)
		(bytes2hex(codeunits(join(l.text))) * "_" * bytes2hex(codeunits(l.url)))
	end
end

# ╔═╡ 5215a931-34d2-4e94-bf1d-e8135571ce9a
begin
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
	    result = translate_with_openai(
			Markdown.MD(p), 
			lang="Japanese",
		)
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
	        @debug "Failed to translate by $(e)" p
	        return p_orig
	    end
	    return p
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
end

# ╔═╡ 9b7bffbb-5d24-409e-b911-463466662ff7
begin
	paragraph = Markdown.parse(
		read("Documenter.jl/docs/src/man/hosting/walkthrough.md", String)
	)
	translated = translate!(paragraph)
end

# ╔═╡ Cell order:
# ╠═463eec94-8fed-4947-a931-ae9422346ee0
# ╠═3678dfcf-7344-4ca7-a5a2-841d8c6e6a72
# ╠═d39fd752-7bf0-43b4-9e48-db7b94655b08
# ╠═5215a931-34d2-4e94-bf1d-e8135571ce9a
# ╠═9b7bffbb-5d24-409e-b911-463466662ff7
