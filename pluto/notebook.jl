### A Pluto.jl notebook ###
# v0.20.1

using Markdown
using InteractiveUtils

# ╔═╡ 463eec94-8fed-4947-a931-ae9422346ee0
begin
	using DotEnv
	DotEnv.load!()
end

# ╔═╡ ca75801e-0769-11f0-36d9-6d630a718dfd
using Markdown

# ╔═╡ 3678dfcf-7344-4ca7-a5a2-841d8c6e6a72
md = Markdown.parse(read("Documenter.jl/docs/src/index.md", String))

# ╔═╡ 58a29c0e-6d51-480b-ac6f-8f5779b21984
md.content

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
DotEnv = "4dc1fcf4-5e3b-5448-94ab-0c38ec0385c1"
Markdown = "d6f4376e-aef5-505a-96c1-9c027394607a"

[compat]
DotEnv = "~1.0.0"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.11.4"
manifest_format = "2.0"
project_hash = "1adcc9e4dce9d95f5f077d8ed84a7237f6ba1fd4"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"
version = "1.11.0"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"
version = "1.11.0"

[[deps.DotEnv]]
deps = ["PrecompileTools"]
git-tree-sha1 = "92e88cb68a5b10545234f46dfaeb2fa8a8a50c45"
uuid = "4dc1fcf4-5e3b-5448-94ab-0c38ec0385c1"
version = "1.0.0"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"
version = "1.11.0"

[[deps.PrecompileTools]]
deps = ["Preferences"]
git-tree-sha1 = "5aa36f7049a63a1528fe8f7c3f2113413ffd4e1f"
uuid = "aea7be01-6a6a-4083-8856-8a6e6704d82a"
version = "1.2.1"

[[deps.Preferences]]
deps = ["TOML"]
git-tree-sha1 = "9306f6085165d270f7e3db02af26a400d580f5c6"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.4.3"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"
version = "1.11.0"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"
version = "1.0.3"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"
version = "1.11.0"
"""

# ╔═╡ Cell order:
# ╠═463eec94-8fed-4947-a931-ae9422346ee0
# ╠═ca75801e-0769-11f0-36d9-6d630a718dfd
# ╠═3678dfcf-7344-4ca7-a5a2-841d8c6e6a72
# ╠═58a29c0e-6d51-480b-ac6f-8f5779b21984
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
