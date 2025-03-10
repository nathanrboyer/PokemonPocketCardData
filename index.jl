### A Pluto.jl notebook ###
# v0.20.4

using Markdown
using InteractiveUtils

# ╔═╡ aa94d7a0-b24a-11ef-2de2-47a66b1c37be
# ╠═╡ show_logs = false
using DataFramesMeta, HTTP, JSONTables, PlutoUI

# ╔═╡ 34436b8a-b8ad-4875-bf99-86b8f8b2a695
md"# Input"

# ╔═╡ 8e188e7d-5a2d-4d5c-a5a9-81934aa7e01a
md"## List Desired Card Numbers in each Series"

# ╔═╡ 6c639740-2210-4671-b96d-478c7631a2b6
md"### Promo A"

# ╔═╡ 0efcd0e6-6df0-465a-81e2-cea01ab10725
PA = [
	
]

# ╔═╡ 238c0262-3734-4bc6-94ee-b907d91f47a0
md"### Genetic Apex"

# ╔═╡ 4b18f32c-4621-4474-bf3f-808ec2b4fe1f
A1 = [
	41
	45
	84
	125
	128
	203
	267
]

# ╔═╡ 89d6ecd9-1185-47c9-b0ad-fcbc2d8b7941
md"### Mythical Island"

# ╔═╡ 1c594f1f-5119-4e65-b873-9a98de628d7e
A1a = [
	3
	46
	72
]

# ╔═╡ c9a803a2-d30f-4acf-86ee-6a0732a25345
md"### Space-Time Smackdown"

# ╔═╡ 7a394f68-ce0f-47d5-8515-5169925ae687
A2 = [
	24
	29
	37
	41
	50
	53
	61
	67
	71
	75
	79
	82
	92
	95
	109
	110
	123
	125
	128
	129
	136
	150

]

# ╔═╡ 6e1dad95-b6ec-409a-bc6c-fbf479f05ac0
md"### Triumphant Light"

# ╔═╡ 31d599a7-e4d8-4c64-bb68-de6246325213
A2a = [
	5
	7
	10
	12
	13
	17
	21
	26
	32
	41
	42
	47
	50
	51
	55
	57
	61
	69
	71
]

# ╔═╡ d2540a56-4cf4-4a61-a07b-f57de767d224
md"# Output"

# ╔═╡ c47b22d5-fa58-4c3e-b8cf-b79d2a6fc9c7
md"## Selected Cards"

# ╔═╡ 9bd4985d-beb3-4431-acf1-d734b4f6585e
md"## Pack Information"

# ╔═╡ 86e7000b-3675-4703-8819-470f793c2d69
md"# Card Lookup"

# ╔═╡ 6ae9d1a2-3733-40e2-ba0e-6a563cb76ae7
md"""
Search the database by series, number, name, rarity, pack, or health. Edit any of the examples below.
"""

# ╔═╡ 53835b1f-c7e4-47ee-a36f-4adcd2a34182
md"# Appendix"

# ╔═╡ 7284ca8c-09e5-44ab-98de-db8d2e56053d
md"## Function Definitions"

# ╔═╡ 42d22e06-8fd2-42a4-90ca-f81fafb66b7d
"""
	filter_by_desired(source, desired)

Filter `source` dataframe by a dictionary of `desired` cards.
Each key in the dictionary corresponds to a card `:series`,
and each value in the dictionary is a vector of card `:numbers`.
"""
function filter_by_desired(
		source::Union{AbstractDataFrame,GroupedDataFrame},
		desired::AbstractDict,
	)
	vec = DataFrame[]
	for (key,value) in pairs(desired)
		push!(vec, @rsubset(source, :series == key, :number in value))
	end
	df = reduce(vcat, vec)
	sort!(df, [:series, :number])
end

# ╔═╡ c16d8096-8c8d-4487-8ad5-50bc43a5205d
md"## Data Scraping"

# ╔═╡ de7fcd25-b476-4e50-a649-370a08b3d5df
md"""
Card data is scraped from [Chase Manning's Github repository](https://github.com/chase-manning/pokemon-tcg-pocket-cards).

Pack images are scraped from [serebii.net](https://www.serebii.net/tcgpocket).

If this stops working, some other potential sources for Pokémon data are listed below.

- https://pocket.limitlesstcg.com/cards/

- https://github.com/LucachuTW/CARDS-PokemonPocket-scrapper

- https://github.com/diogofelizardo/PocketDB

- https://github.com/lu-jim/pokemon-tcgp

"""

# ╔═╡ e0de3c3d-4a10-4da3-a3a6-8783543fe0c0
pack_images = Dict(
	"Charizard" => Resource(
		"https://www.serebii.net/tcgpocket/geneticapex/charizard.jpg"
	),
	"Pikachu" => Resource(
		"https://www.serebii.net/tcgpocket/geneticapex/pikachu.jpg"
	),
	"Mewtwo" => Resource(
		"https://www.serebii.net/tcgpocket/geneticapex/mewtwo.jpg"
	),
	"Mew" => Resource(
		"https://www.serebii.net/tcgpocket/mythicalisland/mew.jpg"
	),
	"Dialga" => Resource(
		"https://www.serebii.net/tcgpocket/space-timesmackdown/dialga.jpg"
	),
	"Palkia" => Resource(
		"https://www.serebii.net/tcgpocket/space-timesmackdown/palkia.jpg"
	),
	"Arceus" => Resource(
		"https://www.serebii.net/tcgpocket/triumphantlight/arceus.jpg"
	),
	"PA" => Resource(
		"https://www.serebii.net/tcgpocket/logo/promo-a.png"
	)
)

# ╔═╡ d9d35c7c-311d-4ae1-8737-80ff3500744a
begin
	repo_version = "v3"
	website_response = HTTP.request(
		"GET",
		join([
			"https://raw.githubusercontent.com/chase-manning/",
			"pokemon-tcg-pocket-cards/refs/heads/main/",
			repo_version,
			".json",
		]),
	)
	rawdf = website_response.body |> jsontable |> DataFrame
	Text("Data scraped successfully.")
end

# ╔═╡ bdd147b1-3e4b-4c63-a11c-462c1e90c612
md"## Data Cleaning"

# ╔═╡ b7486cfa-fc49-4cde-993e-78d6d5768db0
fulldf = @chain begin rawdf
	@rselect(
		$[:series, :number] = split(:id, '-'),
		$(Not(:id)),
	)
	@rtransform! :series =
		if length(:series) == 3
			uppercase(:series[1]) * uppercase(:series[2]) * lowercase(:series[3])
		else
			uppercase(:series)
		end
	@rtransform! :number = parse(Int, :number)
	@rtransform! :image = Resource(:image)
	@transform! :health = passmissing(parse).(Int, replace(:health, "" => missing))
end

# ╔═╡ c3c0fa78-d354-42d0-9490-c8572b305f74
@rsubset(fulldf, contains(:name, "Gastly"))

# ╔═╡ 2916685d-07b4-4fce-822a-c42ec8f8605c
@rsubset(fulldf, :health ≥ 180).image

# ╔═╡ dd81ee04-72ca-4a2b-aa9a-24c9a91dbf7c
@rsubset(fulldf, :rarity == "☆")[:, [:image, :series, :number]]

# ╔═╡ 684d49af-05c5-4fae-84c0-33867f619371
@rsubset(fulldf, :series == "A2a")[:, [:number, :image]]

# ╔═╡ 762e56e8-087e-4a7c-9c7f-a6b5006a0cbf
@rsubset(fulldf, :series == "A2", :number == 204).image |> only

# ╔═╡ f0dcb13a-7706-45e6-8f3c-1d45e7f36a9e
seriespacks = let gdf = groupby(fulldf, :series)
	d = Dict{String,Vector{String}}()
	for (key, df) in pairs(gdf)
		packs = unique(df.pack)
		filter!(!(==("Every")), packs)
		push!(d, key.series => packs)
	end
	filter!.(!contains("Shared"), values(d))
	filter!.(!contains("Achievement"), values(d))
	d
end

# ╔═╡ b8765ce3-da72-4b92-acb8-f8cec96df80d
"""
	unpack_shared(df)

Convert rows with a "Shared(<series_name>)" pack value into multiple rows with specific packs.
"""
function unpack_shared(df_original)
	df = copy(df_original)
	for (i, row) in pairs(eachrow(df))
		if contains(row.pack, "Shared")
			for packname in seriespacks[row.series]
				row.pack = packname
				push!(df, row)
			end
			deleteat!(df, i)
		end
	end
	sort!(df, [:series, :number])
	return df
end

# ╔═╡ cc875dfe-baae-4a6a-95f3-d638fe2aa7a1
begin
	desired_card_numbers = Dict(
		"PA" => PA,
		"A1" => A1,
		"A1a" => A1a,
		"A2" => A2,
		"A2a" => A2a,
	)
	desired_cards = filter_by_desired(fulldf, desired_card_numbers)
	desired_cards_unpacked = unpack_shared(desired_cards)
	desired_cards_images = desired_cards.image
end

# ╔═╡ 5726b945-44d7-4208-bc85-200a73863e21
@chain desired_cards_unpacked begin
	groupby(:pack)
	@combine(
		$"Desired Cards" = [copy(:image)],
		:Total = $nrow,
		#$"◊'s" = count(in(["◊", "◊◊", "◊◊◊", "◊◊◊◊"]), :rarity),
		#$"☆'s" = count(in(["☆", "☆☆", "☆☆☆"]), :rarity),
		#$"♛'s" = count(in(["♛"]), :rarity),
		:◊ = count(==("◊"), :rarity),
		:◊◊ = count(==("◊◊"), :rarity),
		:◊◊◊ = count(==("◊◊◊"), :rarity),
		:◊◊◊◊ = count(==("◊◊◊◊"), :rarity),
		:☆ = count(==("☆"), :rarity),
		:☆☆ = count(==("☆☆"), :rarity),
		:☆☆☆ = count(==("☆☆☆"), :rarity),
		:♛ = count(==("Crown Rare"), :rarity),
	)
	@rselect!(:Pack = [pack_images[:pack]], $(Not(:pack)))
	sort!([:Total, :◊, :◊◊, :◊◊◊, :◊◊◊◊, :☆, :☆☆, :☆☆☆, :♛], rev=true)
end

# ╔═╡ 92588797-2b09-4146-bce6-68a5a5cf428c
md"## Data Summary"

# ╔═╡ 7b2279cb-dbf4-4077-8c66-002d925b7806
@chain begin fulldf
	groupby(:series)
	combine(nrow)
	rename!(["Series", "Total Cards"])
	sort!
end

# ╔═╡ 404c6734-61d2-4dc3-839c-204a16a561d5
@chain begin fulldf
	groupby(:pack)
	combine(
		nrow, 
		:series => unique => :series,
	)
	sort!([:series, :pack])
	select!(:series, :)
	rename!(
		:series => "Series",
		:pack => "Pack",
		:nrow => "Total Cards",
	)
end

# ╔═╡ 97e51f8d-91d4-4aab-a594-516b3aae6d90
@chain begin fulldf
	groupby(:rarity)
	combine(nrow)
	rename!(["Rarity", "Total Cards"])
end

# ╔═╡ 5b7621b1-d0da-4955-844c-fd4c31373efd
md"## Package Loading"

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
DataFramesMeta = "1313f7d8-7da2-5740-9ea0-a2ca25f37964"
HTTP = "cd3eb016-35fb-5094-929b-558a96fad6f3"
JSONTables = "b9914132-a727-11e9-1322-f18e41205b0b"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"

[compat]
DataFramesMeta = "~0.15.4"
HTTP = "~1.10.13"
JSONTables = "~1.0.3"
PlutoUI = "~0.7.23"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.11.3"
manifest_format = "2.0"
project_hash = "621d443c0f16fbcd161b3ce40000d5a4a5613d67"

[[deps.AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "6e1d2a35f2f90a4bc7c2ed98079b2ba09c35b83a"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.3.2"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.2"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"
version = "1.11.0"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"
version = "1.11.0"

[[deps.BitFlags]]
git-tree-sha1 = "0691e34b3bb8be9307330f88d1a3c3f25466c24d"
uuid = "d1d4a3ce-64b1-5f1a-9ba4-7e7e69966f35"
version = "0.1.9"

[[deps.Chain]]
git-tree-sha1 = "9ae9be75ad8ad9d26395bf625dea9beac6d519f1"
uuid = "8be319e6-bccf-4806-a6f7-6fae938471bc"
version = "0.6.0"

[[deps.CodecZlib]]
deps = ["TranscodingStreams", "Zlib_jll"]
git-tree-sha1 = "bce6804e5e6044c6daab27bb533d1295e4a2e759"
uuid = "944b1d66-785c-5afd-91f1-9de20f533193"
version = "0.7.6"

[[deps.Compat]]
deps = ["TOML", "UUIDs"]
git-tree-sha1 = "8ae8d32e09f0dcf42a36b90d4e17f5dd2e4c4215"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "4.16.0"
weakdeps = ["Dates", "LinearAlgebra"]

    [deps.Compat.extensions]
    CompatLinearAlgebraExt = "LinearAlgebra"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "1.1.1+0"

[[deps.ConcurrentUtilities]]
deps = ["Serialization", "Sockets"]
git-tree-sha1 = "ea32b83ca4fefa1768dc84e504cc0a94fb1ab8d1"
uuid = "f0e56b4a-5159-44fe-b623-3e5288b988bb"
version = "2.4.2"

[[deps.Crayons]]
git-tree-sha1 = "249fe38abf76d48563e2f4556bebd215aa317e15"
uuid = "a8cc5b0e-0ffa-5ad4-8c14-923d3ee1735f"
version = "4.1.1"

[[deps.DataAPI]]
git-tree-sha1 = "abe83f3a2f1b857aac70ef8b269080af17764bbe"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.16.0"

[[deps.DataFrames]]
deps = ["Compat", "DataAPI", "DataStructures", "Future", "InlineStrings", "InvertedIndices", "IteratorInterfaceExtensions", "LinearAlgebra", "Markdown", "Missings", "PooledArrays", "PrecompileTools", "PrettyTables", "Printf", "Random", "Reexport", "SentinelArrays", "SortingAlgorithms", "Statistics", "TableTraits", "Tables", "Unicode"]
git-tree-sha1 = "fb61b4812c49343d7ef0b533ba982c46021938a6"
uuid = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
version = "1.7.0"

[[deps.DataFramesMeta]]
deps = ["Chain", "DataFrames", "MacroTools", "OrderedCollections", "Reexport", "TableMetadataTools"]
git-tree-sha1 = "21a4335f249f8b5f311d00d5e62938b50ccace4e"
uuid = "1313f7d8-7da2-5740-9ea0-a2ca25f37964"
version = "0.15.4"

[[deps.DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "1d0a14036acb104d9e89698bd408f63ab58cdc82"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.20"

[[deps.DataValueInterfaces]]
git-tree-sha1 = "bfc1187b79289637fa0ef6d4436ebdfe6905cbd6"
uuid = "e2d170a0-9d28-54be-80f0-106bbe20a464"
version = "1.0.0"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"
version = "1.11.0"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.6.0"

[[deps.ExceptionUnwrapping]]
deps = ["Test"]
git-tree-sha1 = "d36f682e590a83d63d1c7dbd287573764682d12a"
uuid = "460bff9d-24e4-43bc-9d9f-a8973cb893f4"
version = "0.1.11"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"
version = "1.11.0"

[[deps.Future]]
deps = ["Random"]
uuid = "9fa8497b-333b-5362-9e8d-4d0656e87820"
version = "1.11.0"

[[deps.HTTP]]
deps = ["Base64", "CodecZlib", "ConcurrentUtilities", "Dates", "ExceptionUnwrapping", "Logging", "LoggingExtras", "MbedTLS", "NetworkOptions", "OpenSSL", "PrecompileTools", "Random", "SimpleBufferStream", "Sockets", "URIs", "UUIDs"]
git-tree-sha1 = "6c22309e9a356ac1ebc5c8a217045f9bae6f8d9a"
uuid = "cd3eb016-35fb-5094-929b-558a96fad6f3"
version = "1.10.13"

[[deps.Hyperscript]]
deps = ["Test"]
git-tree-sha1 = "8d511d5b81240fc8e6802386302675bdf47737b9"
uuid = "47d2ed2b-36de-50cf-bf87-49c2cf4b8b91"
version = "0.0.4"

[[deps.HypertextLiteral]]
deps = ["Tricks"]
git-tree-sha1 = "7134810b1afce04bbc1045ca1985fbe81ce17653"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.5"

[[deps.IOCapture]]
deps = ["Logging", "Random"]
git-tree-sha1 = "b6d6bfdd7ce25b0f9b2f6b3dd56b2673a66c8770"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "0.2.5"

[[deps.InlineStrings]]
git-tree-sha1 = "45521d31238e87ee9f9732561bfee12d4eebd52d"
uuid = "842dd82b-1e85-43dc-bf29-5d0ee9dffc48"
version = "1.4.2"

    [deps.InlineStrings.extensions]
    ArrowTypesExt = "ArrowTypes"
    ParsersExt = "Parsers"

    [deps.InlineStrings.weakdeps]
    ArrowTypes = "31f734f8-188a-4ce0-8406-c8a06bd891cd"
    Parsers = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"
version = "1.11.0"

[[deps.InvertedIndices]]
git-tree-sha1 = "0dc7b50b8d436461be01300fd8cd45aa0274b038"
uuid = "41ab1584-1d38-5bbf-9106-f11c6c58b48f"
version = "1.3.0"

[[deps.IteratorInterfaceExtensions]]
git-tree-sha1 = "a3f24677c21f5bbe9d2a714f95dcd58337fb2856"
uuid = "82899510-4779-5014-852e-03e436cf321d"
version = "1.0.0"

[[deps.JLLWrappers]]
deps = ["Artifacts", "Preferences"]
git-tree-sha1 = "be3dc50a92e5a386872a493a10050136d4703f9b"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.6.1"

[[deps.JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "31e996f0a15c7b280ba9f76636b3ff9e2ae58c9a"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.4"

[[deps.JSON3]]
deps = ["Dates", "Mmap", "Parsers", "PrecompileTools", "StructTypes", "UUIDs"]
git-tree-sha1 = "eb3edce0ed4fa32f75a0a11217433c31d56bd48b"
uuid = "0f8b85d8-7281-11e9-16c2-39a750bddbf1"
version = "1.14.0"

    [deps.JSON3.extensions]
    JSON3ArrowExt = ["ArrowTypes"]

    [deps.JSON3.weakdeps]
    ArrowTypes = "31f734f8-188a-4ce0-8406-c8a06bd891cd"

[[deps.JSONTables]]
deps = ["JSON3", "StructTypes", "Tables"]
git-tree-sha1 = "13f7485bb0b4438bb5e83e62fcadc65c5de1d1bb"
uuid = "b9914132-a727-11e9-1322-f18e41205b0b"
version = "1.0.3"

[[deps.LaTeXStrings]]
git-tree-sha1 = "dda21b8cbd6a6c40d9d02a73230f9d70fed6918c"
uuid = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
version = "1.4.0"

[[deps.LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"
version = "0.6.4"

[[deps.LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"
version = "8.6.0+0"

[[deps.LibGit2]]
deps = ["Base64", "LibGit2_jll", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"
version = "1.11.0"

[[deps.LibGit2_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll"]
uuid = "e37daf67-58a4-590a-8e99-b0245dd2ffc5"
version = "1.7.2+0"

[[deps.LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"
version = "1.11.0+1"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"
version = "1.11.0"

[[deps.LinearAlgebra]]
deps = ["Libdl", "OpenBLAS_jll", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"
version = "1.11.0"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"
version = "1.11.0"

[[deps.LoggingExtras]]
deps = ["Dates", "Logging"]
git-tree-sha1 = "f02b56007b064fbfddb4c9cd60161b6dd0f40df3"
uuid = "e6f89c97-d47a-5376-807f-9c37f3926c36"
version = "1.1.0"

[[deps.MacroTools]]
deps = ["Markdown", "Random"]
git-tree-sha1 = "2fa9ee3e63fd3a4f7a9a4f4744a52f4856de82df"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.13"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"
version = "1.11.0"

[[deps.MbedTLS]]
deps = ["Dates", "MbedTLS_jll", "MozillaCACerts_jll", "NetworkOptions", "Random", "Sockets"]
git-tree-sha1 = "c067a280ddc25f196b5e7df3877c6b226d390aaf"
uuid = "739be429-bea8-5141-9913-cc70e7f3736d"
version = "1.1.9"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"
version = "2.28.6+0"

[[deps.Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "ec4f7fbeab05d7747bdf98eb74d130a2a2ed298d"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.2.0"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"
version = "1.11.0"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"
version = "2023.12.12"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.2.0"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.27+1"

[[deps.OpenSSL]]
deps = ["BitFlags", "Dates", "MozillaCACerts_jll", "OpenSSL_jll", "Sockets"]
git-tree-sha1 = "38cb508d080d21dc1128f7fb04f20387ed4c0af4"
uuid = "4d8831e6-92b7-49fb-bdf8-b643e874388c"
version = "1.4.3"

[[deps.OpenSSL_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "7493f61f55a6cce7325f197443aa80d32554ba10"
uuid = "458c3c95-2e84-50aa-8efc-19380b2a3a95"
version = "3.0.15+1"

[[deps.OrderedCollections]]
git-tree-sha1 = "12f1439c4f986bb868acda6ea33ebc78e19b95ad"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.7.0"

[[deps.Parsers]]
deps = ["Dates", "PrecompileTools", "UUIDs"]
git-tree-sha1 = "8489905bcdbcfac64d1daa51ca07c0d8f0283821"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.8.1"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "FileWatching", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "Random", "SHA", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.11.0"

    [deps.Pkg.extensions]
    REPLExt = "REPL"

    [deps.Pkg.weakdeps]
    REPL = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[deps.PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "Dates", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "Markdown", "Random", "Reexport", "UUIDs"]
git-tree-sha1 = "5152abbdab6488d5eec6a01029ca6697dff4ec8f"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.23"

[[deps.PooledArrays]]
deps = ["DataAPI", "Future"]
git-tree-sha1 = "36d8b4b899628fb92c2749eb488d884a926614d3"
uuid = "2dfb63ee-cc39-5dd5-95bd-886bf059d720"
version = "1.4.3"

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

[[deps.PrettyTables]]
deps = ["Crayons", "LaTeXStrings", "Markdown", "PrecompileTools", "Printf", "Reexport", "StringManipulation", "Tables"]
git-tree-sha1 = "1101cd475833706e4d0e7b122218257178f48f34"
uuid = "08abe8d2-0d0c-5749-adfa-8a2ac140af0d"
version = "2.4.0"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"
version = "1.11.0"

[[deps.Random]]
deps = ["SHA"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"
version = "1.11.0"

[[deps.Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.SentinelArrays]]
deps = ["Dates", "Random"]
git-tree-sha1 = "d0553ce4031a081cc42387a9b9c8441b7d99f32d"
uuid = "91c51154-3ec4-41a3-a24f-3f23e20d615c"
version = "1.4.7"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"
version = "1.11.0"

[[deps.SimpleBufferStream]]
git-tree-sha1 = "f305871d2f381d21527c770d4788c06c097c9bc1"
uuid = "777ac1f9-54b0-4bf8-805c-2214025038e7"
version = "1.2.0"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"
version = "1.11.0"

[[deps.SortingAlgorithms]]
deps = ["DataStructures"]
git-tree-sha1 = "66e0a8e672a0bdfca2c3f5937efb8538b9ddc085"
uuid = "a2af1166-a08f-5f64-846c-94a0d3cef48c"
version = "1.2.1"

[[deps.Statistics]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "ae3bb1eb3bba077cd276bc5cfc337cc65c3075c0"
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"
version = "1.11.1"

    [deps.Statistics.extensions]
    SparseArraysExt = ["SparseArrays"]

    [deps.Statistics.weakdeps]
    SparseArrays = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[deps.StringManipulation]]
deps = ["PrecompileTools"]
git-tree-sha1 = "a6b1675a536c5ad1a60e5a5153e1fee12eb146e3"
uuid = "892a3eda-7b42-436c-8928-eab12a02cf0e"
version = "0.4.0"

[[deps.StructTypes]]
deps = ["Dates", "UUIDs"]
git-tree-sha1 = "ca4bccb03acf9faaf4137a9abc1881ed1841aa70"
uuid = "856f2bd8-1eba-4b0a-8007-ebc267875bd4"
version = "1.10.0"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"
version = "1.0.3"

[[deps.TableMetadataTools]]
deps = ["DataAPI", "Dates", "TOML", "Tables", "Unitful"]
git-tree-sha1 = "c0405d3f8189bb9a9755e429c6ea2138fca7e31f"
uuid = "9ce81f87-eacc-4366-bf80-b621a3098ee2"
version = "0.1.0"

[[deps.TableTraits]]
deps = ["IteratorInterfaceExtensions"]
git-tree-sha1 = "c06b2f539df1c6efa794486abfb6ed2022561a39"
uuid = "3783bdb8-4a98-5b6b-af9a-565f29a5fe9c"
version = "1.0.1"

[[deps.Tables]]
deps = ["DataAPI", "DataValueInterfaces", "IteratorInterfaceExtensions", "OrderedCollections", "TableTraits"]
git-tree-sha1 = "598cd7c1f68d1e205689b1c2fe65a9f85846f297"
uuid = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"
version = "1.12.0"

[[deps.Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"
version = "1.10.0"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"
version = "1.11.0"

[[deps.TranscodingStreams]]
git-tree-sha1 = "0c45878dcfdcfa8480052b6ab162cdd138781742"
uuid = "3bb67fe8-82b1-5028-8e26-92a6c54297fa"
version = "0.11.3"

[[deps.Tricks]]
git-tree-sha1 = "6cae795a5a9313bbb4f60683f7263318fc7d1505"
uuid = "410a4b4d-49e4-4fbc-ab6d-cb71b17b3775"
version = "0.1.10"

[[deps.URIs]]
git-tree-sha1 = "67db6cc7b3821e19ebe75791a9dd19c9b1188f2b"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.5.1"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"
version = "1.11.0"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"
version = "1.11.0"

[[deps.Unitful]]
deps = ["Dates", "LinearAlgebra", "Random"]
git-tree-sha1 = "01915bfcd62be15329c9a07235447a89d588327c"
uuid = "1986cc42-f94f-5a68-af5c-568840ba703d"
version = "1.21.1"

    [deps.Unitful.extensions]
    ConstructionBaseUnitfulExt = "ConstructionBase"
    InverseFunctionsUnitfulExt = "InverseFunctions"

    [deps.Unitful.weakdeps]
    ConstructionBase = "187b0558-2788-49d3-abe0-74a17ed4e7c9"
    InverseFunctions = "3587e190-3f89-42d0-90ee-14403ec27112"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"
version = "1.2.13+1"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.11.0+0"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"
version = "1.59.0+0"

[[deps.p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
version = "17.4.0+2"
"""

# ╔═╡ Cell order:
# ╟─34436b8a-b8ad-4875-bf99-86b8f8b2a695
# ╟─8e188e7d-5a2d-4d5c-a5a9-81934aa7e01a
# ╟─6c639740-2210-4671-b96d-478c7631a2b6
# ╠═0efcd0e6-6df0-465a-81e2-cea01ab10725
# ╟─238c0262-3734-4bc6-94ee-b907d91f47a0
# ╠═4b18f32c-4621-4474-bf3f-808ec2b4fe1f
# ╟─89d6ecd9-1185-47c9-b0ad-fcbc2d8b7941
# ╠═1c594f1f-5119-4e65-b873-9a98de628d7e
# ╟─c9a803a2-d30f-4acf-86ee-6a0732a25345
# ╠═7a394f68-ce0f-47d5-8515-5169925ae687
# ╟─6e1dad95-b6ec-409a-bc6c-fbf479f05ac0
# ╠═31d599a7-e4d8-4c64-bb68-de6246325213
# ╟─d2540a56-4cf4-4a61-a07b-f57de767d224
# ╟─c47b22d5-fa58-4c3e-b8cf-b79d2a6fc9c7
# ╟─cc875dfe-baae-4a6a-95f3-d638fe2aa7a1
# ╟─9bd4985d-beb3-4431-acf1-d734b4f6585e
# ╟─5726b945-44d7-4208-bc85-200a73863e21
# ╟─86e7000b-3675-4703-8819-470f793c2d69
# ╟─6ae9d1a2-3733-40e2-ba0e-6a563cb76ae7
# ╠═c3c0fa78-d354-42d0-9490-c8572b305f74
# ╠═2916685d-07b4-4fce-822a-c42ec8f8605c
# ╠═dd81ee04-72ca-4a2b-aa9a-24c9a91dbf7c
# ╠═684d49af-05c5-4fae-84c0-33867f619371
# ╠═762e56e8-087e-4a7c-9c7f-a6b5006a0cbf
# ╟─53835b1f-c7e4-47ee-a36f-4adcd2a34182
# ╟─7284ca8c-09e5-44ab-98de-db8d2e56053d
# ╟─42d22e06-8fd2-42a4-90ca-f81fafb66b7d
# ╟─b8765ce3-da72-4b92-acb8-f8cec96df80d
# ╟─c16d8096-8c8d-4487-8ad5-50bc43a5205d
# ╟─de7fcd25-b476-4e50-a649-370a08b3d5df
# ╟─e0de3c3d-4a10-4da3-a3a6-8783543fe0c0
# ╟─d9d35c7c-311d-4ae1-8737-80ff3500744a
# ╟─bdd147b1-3e4b-4c63-a11c-462c1e90c612
# ╟─b7486cfa-fc49-4cde-993e-78d6d5768db0
# ╟─f0dcb13a-7706-45e6-8f3c-1d45e7f36a9e
# ╟─92588797-2b09-4146-bce6-68a5a5cf428c
# ╟─7b2279cb-dbf4-4077-8c66-002d925b7806
# ╟─404c6734-61d2-4dc3-839c-204a16a561d5
# ╟─97e51f8d-91d4-4aab-a594-516b3aae6d90
# ╟─5b7621b1-d0da-4955-844c-fd4c31373efd
# ╠═aa94d7a0-b24a-11ef-2de2-47a66b1c37be
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
