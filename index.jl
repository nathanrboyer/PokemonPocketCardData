### A Pluto.jl notebook ###
# v0.20.18

using Markdown
using InteractiveUtils

# ╔═╡ aa94d7a0-b24a-11ef-2de2-47a66b1c37be
# ╠═╡ show_logs = false
using DataFramesMeta, HTTP, JSONTables, PlutoUI

# ╔═╡ 01d0206c-90d7-4dab-a1be-52619d154f40
md"# Desired Cards"

# ╔═╡ 34436b8a-b8ad-4875-bf99-86b8f8b2a695
md"""
Use this section to enter the card numbers you desire in each expansion.

This data will be used to filter the database and sort it by number of desired cards per pack.
"""

# ╔═╡ a1d06a4c-1e18-4dcd-b5d4-8c8a558000d1
PA = [
	
];

# ╔═╡ 4b18f32c-4621-4474-bf3f-808ec2b4fe1f
A1 = [
	254
	262
	267
	273
	274
	275
	276
	277
	280
	281
	282
];

# ╔═╡ 1c594f1f-5119-4e65-b873-9a98de628d7e
A1a = [
	82
	84
];

# ╔═╡ 7a394f68-ce0f-47d5-8515-5169925ae687
A2 = [
	190
	197
	201
];

# ╔═╡ 31d599a7-e4d8-4c64-bb68-de6246325213
A2a = [
	87
	93
	95
];

# ╔═╡ ef199255-e146-4bc8-b2d0-accd69e97d83
A2b = [
	89
	90
	111
];

# ╔═╡ 2bfa8df6-a36d-4d4e-8a87-14c8aabed144
A3 = [
	209
];

# ╔═╡ e74b5827-8f34-43fe-a0da-4f513e6ac388
A3a = [
	88
	103
];

# ╔═╡ d890bce7-bbcc-4f4c-8d00-8922b04c8b15
A3b = [
	89
	90
	91
];

# ╔═╡ 7deeda72-a210-4f92-a059-da6bf63c98f5
A4 = [
	
];

# ╔═╡ 0498932c-95fd-4b70-a10b-1cf32ae1390a
A4a = [
	
];

# ╔═╡ 4e04ba71-26c0-4d99-b04a-37550daf8a0a
A4b = [
	365
	370
	372
	373
	379
];

# ╔═╡ 0d3091f8-d2e2-4cd9-84fe-c1a16cc4c76d
PB = [
	
];

# ╔═╡ d9ad11e7-2099-4ec7-b4c3-70d83adbdecc
B1 = [
	7
	43
	51
	55
	67
	88
	106
	114
	134
	137
	151
	169
	174
	179
	207
	234
	236
	254
	272
	274
	279
	286
	304
];

# ╔═╡ c0d6dc1c-f180-4e41-8784-c86600be7925
B1a = [
	85
	86
];

# ╔═╡ 73208c22-29c9-4031-bd0f-99d8fd82cd2e
md"### Combined"

# ╔═╡ ce1dab1a-edf8-450d-82b6-3ab63f95ba81
desired_card_numbers = Dict(
	"PA" => PA,
	"A1" => A1,
	"A1a" => A1a,
	"A2" => A2,
	"A2a" => A2a,
	"A2b" => A2b,
	"A3" => A3,
	"A3a" => A3a,
	"A3b" => A3b,
	"A4" => A4,
	"A4a" => A4a,
	"A4b" => A4b,
	"PB" => PB,
	"B1" => B1,
	"B1a" => B1a,
);

# ╔═╡ d2540a56-4cf4-4a61-a07b-f57de767d224
md"# Pack Information"

# ╔═╡ da513126-14d4-4eaa-8e7a-f6339cb2bc17
md"Use this section to decide which pack would be best to open next."

# ╔═╡ 86e7000b-3675-4703-8819-470f793c2d69
md"# Card Lookup"

# ╔═╡ 6ae9d1a2-3733-40e2-ba0e-6a563cb76ae7
md"""
Use this section to search the card database.
Example data frame filters are provided below.

Edit these or add your own!
"""

# ╔═╡ 53835b1f-c7e4-47ee-a36f-4adcd2a34182
md"# Appendix"

# ╔═╡ 7079b6c8-bee9-4e5f-a62a-f0e0617b7225
md"Everything below are data processing internals presented for informational purposes."

# ╔═╡ 7284ca8c-09e5-44ab-98de-db8d2e56053d
md"## Function Definitions"

# ╔═╡ 42d22e06-8fd2-42a4-90ca-f81fafb66b7d
"""
	filter_by_desired(source, desired)

Filter `source` dataframe by a dictionary of `desired` cards.
Each key in the dictionary corresponds to a card `:expansion`,
and each value in the dictionary is a vector of card `:numbers`.
"""
function filter_by_desired(
		source::Union{AbstractDataFrame,GroupedDataFrame},
		desired::AbstractDict,
	)
	df = DataFrame()
	for (key, value) in pairs(desired)
		append!(df, @rsubset(source, :expansionid == key, :number in value))
	end
	sort!(df, [:expansionid, :number])
end

# ╔═╡ 287c75f4-5d2e-492d-be95-1819f6ca274d
"""
	lt_shared(x,y)

Compare `x`, and `y` normally, unless one of them has value `"Shared"`.
`"Shared"` is always considered "smallest".
"""
function lt_shared(x, y)
	if x == "Shared"
		return true
	elseif y == "Shared"
		return false
	else
		return isless(x,y)
	end
end	

# ╔═╡ c16d8096-8c8d-4487-8ad5-50bc43a5205d
md"## Data Scraping"

# ╔═╡ de7fcd25-b476-4e50-a649-370a08b3d5df
md"""
Card and pack data is scraped from [Chase Manning's Github repository](https://github.com/chase-manning/pokemon-tcg-pocket-cards).
"""

# ╔═╡ d9d35c7c-311d-4ae1-8737-80ff3500744a
begin
	repo_version = "v4"
	website_response1 = HTTP.request(
		"GET",
		join([
			"https://raw.githubusercontent.com/chase-manning/",
			"pokemon-tcg-pocket-cards/refs/heads/main/",
			repo_version,
			".json",
		]),
	)
	card_data_download = website_response1.body |> jsontable |> DataFrame
	website_response2 = HTTP.request(
		"GET",
		"https://raw.githubusercontent.com/chase-manning/pokemon-tcg-pocket-cards/refs/heads/main/expansions.json",
	)
	expansion_data_download = website_response2.body |> jsontable |> DataFrame
	alternate_sources = md"""
		If this stops working, some other potential sources for Pokémon data are listed below.

		- https://pocket.limitlesstcg.com/cards/

		- https://www.pokemon-zone.com/cards/

		- https://github.com/LucachuTW/CARDS-PokemonPocket-scrapper

		- https://github.com/diogofelizardo/PocketDB

		- https://github.com/lu-jim/pokemon-tcgp
	"""
	Text("Data scraped successfully.")
end

# ╔═╡ bdd147b1-3e4b-4c63-a11c-462c1e90c612
md"## Data Cleaning"

# ╔═╡ fcb064ab-b4ca-4898-951d-7fd623d6c8ac
begin
	expansion_data = @chain expansion_data_download begin
		@aside image_width = 60
		transform(:packs => ByRow(jsontable) => :packs)
		flatten(:packs)
		select!(
			:id => :expansionid,
			:name => :expansionname,
			:packs => ByRow(NamedTuple) => [:packid, :packname, :packimage],
		)
		transform!(:packimage => ByRow(x -> [Resource(x, :width => image_width)]), renamecols=false)
		@rtransform! :expansionid = ifelse(:expansionid == "promo", first(:packid)*last(:packid), :expansionid)
		@rtransform! :expansionname = ifelse(:expansionname == "Promo", :packname, :expansionname)
		@aside for i in unique(_.expansionid)
			push!(
				_,
				(
					expansionid = i,
					expansionname = first(@rsubset(_, :expansionid == i).expansionname),
					packid = i*"-shared",
					packname = "Shared",
					packimage = only.(@rsubset(_, :expansionid == i).packimage),
				),
				promote = true,
			)
		end
		sort!
	end
	Text("Expansion data cleaned successfully.")
end

# ╔═╡ 8ed2462b-c5b2-4ff4-b77f-8febe42eac58
begin
	card_data = @chain card_data_download begin
		@rtransform $[:expansionid, :number] = split(:id, '-')
		@rtransform! :number = parse(Int, :number)
		@rtransform! :image = Resource(:image)
		@rtransform! :rarity = replace(:rarity, "Crown Rare" => "♛")
		@rtransform! :health = ifelse(:health == "", NaN, tryparse(Int, :health))
		@rtransform! :packid =
			if first(:expansionid) =='p'
				"promo-" * last(:expansionid)
			else
				:expansionid * '-' * lowercase(replace(replace(:pack, r"\(.*\)" => ""), " " => ""))
			end
		@rtransform! :expansionid =
			if length(:expansionid) == 3
				uppercase(:expansionid[1]) * uppercase(:expansionid[2]) * lowercase(:expansionid[3])
			else
				uppercase(:expansionid)
			end
	end
	Text("Card data cleaned successfully.")
end

# ╔═╡ cb34c847-da1c-47d4-99bd-5522a55cb3fb
begin
	data = leftjoin(card_data, expansion_data, on=:packid, order=:left, makeunique=true)
	select!(
		data,
		:expansionid,
		:expansionname,
		:number,			
		:name,
		:image,
		:rarity,
		:type,
		:health,
		:fullart,
		:ex,
		:packid,
		:packname,
		:packimage,
	)
	if nrow(data) != sum(completecases(data))
		md"## Warning: missing data detected"
	else
		Text("Data combined successfully.")
	end
end

# ╔═╡ c22b8b8e-f178-425c-8882-da6ace3626f6
let name = "PA"
	md"### $(@rsubset(data, :expansionid == name).expansionname |> unique)"
end

# ╔═╡ 238c0262-3734-4bc6-94ee-b907d91f47a0
let	name = "A1"
	md"### $(@rsubset(data, :expansionid == name).expansionname |> unique)"
end

# ╔═╡ 89d6ecd9-1185-47c9-b0ad-fcbc2d8b7941
let	name = "A1a"
	md"### $(@rsubset(data, :expansionid == name).expansionname |> unique)"
end

# ╔═╡ c9a803a2-d30f-4acf-86ee-6a0732a25345
let	name = "A2"
	md"### $(@rsubset(data, :expansionid == name).expansionname |> unique)"
end

# ╔═╡ 6e1dad95-b6ec-409a-bc6c-fbf479f05ac0
let	name = "A2a"
	md"### $(@rsubset(data, :expansionid == name).expansionname |> unique)"
end

# ╔═╡ 3cc50f07-e16c-4b0d-9799-cf61671a5e3d
let	name = "A2b"
	md"### $(@rsubset(data, :expansionid == name).expansionname |> unique)"
end

# ╔═╡ 647797c9-0ad3-44b4-b35a-ad78dfafa60c
let	name = "A3"
	md"### $(@rsubset(data, :expansionid == name).expansionname |> unique)"
end

# ╔═╡ 45a5ec15-30a3-41b7-a8b1-cc7a0a5a52d8
let	name = "A3a"
	md"### $(@rsubset(data, :expansionid == name).expansionname |> unique)"
end

# ╔═╡ da7c71ce-e6b7-40db-b2bc-50fbf0b59c1f
let	name = "A3b"
	md"### $(@rsubset(data, :expansionid == name).expansionname |> unique)"
end

# ╔═╡ 03550662-ee38-4879-9a63-8380880dcc8f
let	name = "A4"
	md"### $(@rsubset(data, :expansionid == name).expansionname |> unique)"
end

# ╔═╡ 2cc2b217-e0d2-445b-b9ee-aaa16964621f
let	name = "A4a"
	md"### $(@rsubset(data, :expansionid == name).expansionname |> unique)"
end

# ╔═╡ 36ddd671-212d-4e2d-816e-8ca32a0528ee
let	name = "A4b"
	md"### $(@rsubset(data, :expansionid == name).expansionname |> unique)"
end

# ╔═╡ 05544a2f-15d5-4d77-a786-a72b3f35e4fb
let	name = "PB"
	md"### $(@rsubset(data, :expansionid == name).expansionname |> unique)"
end

# ╔═╡ c7452d22-8045-44d5-ae5b-be375f8f2fe0
let	name = "B1"
	md"### $(@rsubset(data, :expansionid == name).expansionname |> unique)"
end

# ╔═╡ 6a209624-266f-4379-b371-85ee746f5c85
let	name = "B1a"
	md"### $(@rsubset(data, :expansionid == name).expansionname |> unique)"
end

# ╔═╡ 157c9090-554c-4515-9458-5d017b304aad
begin
	desired_cards = filter_by_desired(data, desired_card_numbers)
	desired_cards_unpacked = flatten(desired_cards, :packimage)
	Text("Card data successfully filtered by desired.")
end

# ╔═╡ deaa9324-b1f2-4167-8500-5f0039486d4f
@rsubset(desired_cards, :expansionid == "PA").image

# ╔═╡ 136c4134-3423-447c-8a38-e3346407112c
@rsubset(desired_cards, :expansionid == "A1").image

# ╔═╡ fbc08814-1279-4614-99ae-c3f23434ad17
@rsubset(desired_cards, :expansionid == "A1a").image

# ╔═╡ e3813ced-c01a-4745-99b3-fd77bf6ee6ba
@rsubset(desired_cards, :expansionid == "A2").image

# ╔═╡ c01d4362-bdf1-4e40-b6ee-246fbb5be730
@rsubset(desired_cards, :expansionid == "A2a").image

# ╔═╡ f659b84a-22f5-4aa9-a2c4-ece9a1175ede
@rsubset(desired_cards, :expansionid == "A2b").image

# ╔═╡ 6f93bd90-25d8-497f-92ff-562fe614b5e5
@rsubset(desired_cards, :expansionid == "A3").image

# ╔═╡ 0f4bf200-6daa-4036-86b0-c8caa23f0ec2
@rsubset(desired_cards, :expansionid == "A3a").image

# ╔═╡ 030f56ad-6a21-4bcb-aba5-d8ac9b2736b6
@rsubset(desired_cards, :expansionid == "A3b").image

# ╔═╡ 764efb07-7619-4ea5-974e-cd36d892e90e
@rsubset(desired_cards, :expansionid == "A4").image

# ╔═╡ 14216bf3-d98c-4d0f-bd6f-d65318ef3aad
@rsubset(desired_cards, :expansionid == "A4a").image

# ╔═╡ 1b1ca141-7aa3-4d1b-890d-aa4de36d7a15
@rsubset(desired_cards, :expansionid == "A4b").image

# ╔═╡ d7e49d4c-a24a-4b1e-a454-379903413c0e
@rsubset(desired_cards, :expansionid == "PB").image

# ╔═╡ e6eb9f63-7eda-4e94-bc0b-700121f13ea0
@rsubset(desired_cards, :expansionid == "B1").image

# ╔═╡ a823c6f8-6311-4343-b51b-d6599c1abd8e
@rsubset(desired_cards, :expansionid == "B1a").image

# ╔═╡ 5726b945-44d7-4208-bc85-200a73863e21
@chain desired_cards_unpacked begin
	groupby([:packimage, :rarity])
	combine(
		:image => (x -> [copy(x)]),
		nrow,
		renamecols = false,
	)  # rarities by pack
	sort!(:rarity)
	unstack(:rarity, :nrow, fill=0)  # create rarity columns
	groupby(:packimage)
	combine(
		:image => (x -> [reduce(vcat, x)]),
		Not(:packimage, :image) .=> sum,
		renamecols = false,
	)  # combine rarities in the same pack
	transform!(Not(:packimage, :image) => (+) => :total)  # add total column
	select!(
		:packimage => "Pack",
		:image => "Desired Cards",
		:total => "Total",
		Not(:packimage, :image, :total),
	)  # add pack images and column headers
	sort!("Total", rev=true)
end

# ╔═╡ c3c0fa78-d354-42d0-9490-c8572b305f74
@rsubset(data, contains(:name, r"blast"i))

# ╔═╡ 762e56e8-087e-4a7c-9c7f-a6b5006a0cbf
@rsubset(data, :expansionid == "A2a", :number == 93).image |> only

# ╔═╡ 5a7f7ec0-67e4-424b-9a1c-03cf870d735b
@rsubset(data, :rarity == "☆☆☆")[:, [:image, :expansionid, :number]] |> reverse

# ╔═╡ 684d49af-05c5-4fae-84c0-33867f619371
@rsubset(data, :expansionid == "B1a")[:, [:image, :number]]

# ╔═╡ 2916685d-07b4-4fce-822a-c42ec8f8605c
@rsubset(data, :health ≥ 200).image

# ╔═╡ 92588797-2b09-4146-bce6-68a5a5cf428c
md"## Data Summary"

# ╔═╡ 3a097238-6f24-402b-aaeb-216f3f2ba7ef
md"### Cards / Expansion"

# ╔═╡ 7b2279cb-dbf4-4077-8c66-002d925b7806
@chain begin data
	groupby(:expansionid)
	combine(
		:expansionname => unique => :expansionname,
		nrow,
	)
	rename!(["ID", "Expansion", "Total Cards"])
	sort!
end

# ╔═╡ d18c0e0f-aa4e-4a6b-8ed6-7697b28a3192
md"### Cards / Pack"

# ╔═╡ 404c6734-61d2-4dc3-839c-204a16a561d5
@chain begin data
	groupby(:packid)
	combine(
		nrow,
		:expansionid => unique => :expansionid,
		:expansionname => unique => :expansionname,
		:packname => unique => :packname,
	)
	sort!([:expansionid, :packname], lt=lt_shared)
	select!(
		:expansionid => "ID",
		:expansionname => "Expansion",
		:packname => "Pack",
		:nrow => "Total Cards",
	)
end

# ╔═╡ 831e5e30-3522-41ec-b74f-939230c0065a
md"### Rarities"

# ╔═╡ 97e51f8d-91d4-4aab-a594-516b3aae6d90
@chain begin data
	groupby(:rarity)
	combine(nrow)
	rename!(["Rarity", "Total Cards"])
end

# ╔═╡ 5b7621b1-d0da-4955-844c-fd4c31373efd
md"## Dependency Package Loading"

# ╔═╡ 9888e0c8-335a-45f7-a16f-2ffda567f98b
md"## Visual Tweaks"

# ╔═╡ bc238aa5-05db-40bc-9ed1-cfa8dd891441
Text("Page width and scroll bar height were increased from the default values.")

# ╔═╡ 0c19b482-4946-4ee4-96db-0b5fc5f6f551
# Increase page width
# Reference: https://discourse.julialang.org/t/pluto-pdf-and-printing/65055/5
# Reference: https://discourse.julialang.org/t/cell-width-in-pluto-notebook/49761/11
html"""
<style>
body:not(.fake_class) main {
	max-width: max(50%, 1000px);
	margin-right: 0px;
	align-self: center;
}
</style>
"""

# ╔═╡ 46bf0b39-6f4a-4748-bcd4-07cdb9ec3272
# Increase vertical cell height
# Reference: https://stackoverflow.com/questions/66624243/how-to-fit-pluto-jl-output-cell-to-dataframe-size
html"""<style>
pluto-output.scroll_y {
    max-height: 600px;
}
"""

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
DataFramesMeta = "1313f7d8-7da2-5740-9ea0-a2ca25f37964"
HTTP = "cd3eb016-35fb-5094-929b-558a96fad6f3"
JSONTables = "b9914132-a727-11e9-1322-f18e41205b0b"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"

[compat]
DataFramesMeta = "~0.15.6"
HTTP = "~1.10.15"
JSONTables = "~1.0.3"
PlutoUI = "~0.7.77"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.11.8"
manifest_format = "2.0"
project_hash = "89567afe4d0df870b337766197e3bfd8c3e85491"

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
git-tree-sha1 = "765487f32aeece2cf28aa7038e29c31060cb5a69"
uuid = "8be319e6-bccf-4806-a6f7-6fae938471bc"
version = "1.0.0"

[[deps.CodecZlib]]
deps = ["TranscodingStreams", "Zlib_jll"]
git-tree-sha1 = "962834c22b66e32aa10f7611c08c8ca4e20749a9"
uuid = "944b1d66-785c-5afd-91f1-9de20f533193"
version = "0.7.8"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "67e11ee83a43eb71ddc950302c53bf33f0690dfe"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.12.1"
weakdeps = ["StyledStrings"]

    [deps.ColorTypes.extensions]
    StyledStringsExt = "StyledStrings"

[[deps.Compat]]
deps = ["TOML", "UUIDs"]
git-tree-sha1 = "9d8a54ce4b17aa5bdce0ea5c34bc5e7c340d16ad"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "4.18.1"
weakdeps = ["Dates", "LinearAlgebra"]

    [deps.Compat.extensions]
    CompatLinearAlgebraExt = "LinearAlgebra"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "1.1.1+0"

[[deps.ConcurrentUtilities]]
deps = ["Serialization", "Sockets"]
git-tree-sha1 = "d9d26935a0bcffc87d2613ce14c527c99fc543fd"
uuid = "f0e56b4a-5159-44fe-b623-3e5288b988bb"
version = "2.5.0"

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
git-tree-sha1 = "d8928e9169ff76c6281f39a659f9bca3a573f24c"
uuid = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
version = "1.8.1"

[[deps.DataFramesMeta]]
deps = ["Chain", "DataFrames", "MacroTools", "OrderedCollections", "PrettyTables", "Reexport", "TableMetadataTools"]
git-tree-sha1 = "b0652fb7f3c094cf453bf22e699712a0bed9fc83"
uuid = "1313f7d8-7da2-5740-9ea0-a2ca25f37964"
version = "0.15.6"

[[deps.DataStructures]]
deps = ["OrderedCollections"]
git-tree-sha1 = "e357641bb3e0638d353c4b29ea0e40ea644066a6"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.19.3"

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

[[deps.FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "05882d6995ae5c12bb5f36dd2ed3f61c98cbb172"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.5"

[[deps.Future]]
deps = ["Random"]
uuid = "9fa8497b-333b-5362-9e8d-4d0656e87820"
version = "1.11.0"

[[deps.HTTP]]
deps = ["Base64", "CodecZlib", "ConcurrentUtilities", "Dates", "ExceptionUnwrapping", "Logging", "LoggingExtras", "MbedTLS", "NetworkOptions", "OpenSSL", "PrecompileTools", "Random", "SimpleBufferStream", "Sockets", "URIs", "UUIDs"]
git-tree-sha1 = "5e6fe50ae7f23d171f44e311c2960294aaa0beb5"
uuid = "cd3eb016-35fb-5094-929b-558a96fad6f3"
version = "1.10.19"

[[deps.Hyperscript]]
deps = ["Test"]
git-tree-sha1 = "179267cfa5e712760cd43dcae385d7ea90cc25a4"
uuid = "47d2ed2b-36de-50cf-bf87-49c2cf4b8b91"
version = "0.0.5"

[[deps.HypertextLiteral]]
deps = ["Tricks"]
git-tree-sha1 = "7134810b1afce04bbc1045ca1985fbe81ce17653"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.5"

[[deps.IOCapture]]
deps = ["Logging", "Random"]
git-tree-sha1 = "0ee181ec08df7d7c911901ea38baf16f755114dc"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "1.0.0"

[[deps.InlineStrings]]
git-tree-sha1 = "8f3d257792a522b4601c24a577954b0a8cd7334d"
uuid = "842dd82b-1e85-43dc-bf29-5d0ee9dffc48"
version = "1.4.5"

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
git-tree-sha1 = "6da3c4316095de0f5ee2ebd875df8721e7e0bdbe"
uuid = "41ab1584-1d38-5bbf-9106-f11c6c58b48f"
version = "1.3.1"

[[deps.IteratorInterfaceExtensions]]
git-tree-sha1 = "a3f24677c21f5bbe9d2a714f95dcd58337fb2856"
uuid = "82899510-4779-5014-852e-03e436cf321d"
version = "1.0.0"

[[deps.JLLWrappers]]
deps = ["Artifacts", "Preferences"]
git-tree-sha1 = "0533e564aae234aff59ab625543145446d8b6ec2"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.7.1"

[[deps.JSON3]]
deps = ["Dates", "Mmap", "Parsers", "PrecompileTools", "StructTypes", "UUIDs"]
git-tree-sha1 = "411eccfe8aba0814ffa0fdf4860913ed09c34975"
uuid = "0f8b85d8-7281-11e9-16c2-39a750bddbf1"
version = "1.14.3"

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
git-tree-sha1 = "f00544d95982ea270145636c181ceda21c4e2575"
uuid = "e6f89c97-d47a-5376-807f-9c37f3926c36"
version = "1.2.0"

[[deps.MIMEs]]
git-tree-sha1 = "c64d943587f7187e751162b3b84445bbbd79f691"
uuid = "6c6e2e6c-3030-632d-7369-2d6c69616d65"
version = "1.1.0"

[[deps.MacroTools]]
git-tree-sha1 = "1e0228a030642014fe5cfe68c2c0a818f9e3f522"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.16"

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
deps = ["BitFlags", "Dates", "MozillaCACerts_jll", "NetworkOptions", "OpenSSL_jll", "Sockets"]
git-tree-sha1 = "1d1aaa7d449b58415f97d2839c318b70ffb525a0"
uuid = "4d8831e6-92b7-49fb-bdf8-b643e874388c"
version = "1.6.1"

[[deps.OpenSSL_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "f19301ae653233bc88b1810ae908194f07f8db9d"
uuid = "458c3c95-2e84-50aa-8efc-19380b2a3a95"
version = "3.5.4+0"

[[deps.OrderedCollections]]
git-tree-sha1 = "05868e21324cede2207c6f0f466b4bfef6d5e7ee"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.8.1"

[[deps.Parsers]]
deps = ["Dates", "PrecompileTools", "UUIDs"]
git-tree-sha1 = "7d2f8f21da5db6a806faf7b9b292296da42b2810"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.8.3"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "FileWatching", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "Random", "SHA", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.11.0"
weakdeps = ["REPL"]

    [deps.Pkg.extensions]
    REPLExt = "REPL"

[[deps.PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "Downloads", "FixedPointNumbers", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "Logging", "MIMEs", "Markdown", "Random", "Reexport", "URIs", "UUIDs"]
git-tree-sha1 = "6ed167db158c7c1031abf3bd67f8e689c8bdf2b7"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.77"

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
git-tree-sha1 = "522f093a29b31a93e34eaea17ba055d850edea28"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.5.1"

[[deps.PrettyTables]]
deps = ["Crayons", "LaTeXStrings", "Markdown", "PrecompileTools", "Printf", "REPL", "Reexport", "StringManipulation", "Tables"]
git-tree-sha1 = "c5a07210bd060d6a8491b0ccdee2fa0235fc00bf"
uuid = "08abe8d2-0d0c-5749-adfa-8a2ac140af0d"
version = "3.1.2"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"
version = "1.11.0"

[[deps.REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "StyledStrings", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"
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
git-tree-sha1 = "ebe7e59b37c400f694f52b58c93d26201387da70"
uuid = "91c51154-3ec4-41a3-a24f-3f23e20d615c"
version = "1.4.9"

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
git-tree-sha1 = "64d974c2e6fdf07f8155b5b2ca2ffa9069b608d9"
uuid = "a2af1166-a08f-5f64-846c-94a0d3cef48c"
version = "1.2.2"

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
git-tree-sha1 = "a3c1536470bf8c5e02096ad4853606d7c8f62721"
uuid = "892a3eda-7b42-436c-8928-eab12a02cf0e"
version = "0.4.2"

[[deps.StructTypes]]
deps = ["Dates", "UUIDs"]
git-tree-sha1 = "159331b30e94d7b11379037feeb9b690950cace8"
uuid = "856f2bd8-1eba-4b0a-8007-ebc267875bd4"
version = "1.11.0"

[[deps.StyledStrings]]
uuid = "f489334b-da3d-4c2e-b8f0-e476e12c162b"
version = "1.11.0"

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
git-tree-sha1 = "f2c1efbc8f3a609aadf318094f8fc5204bdaf344"
uuid = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"
version = "1.12.1"

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
git-tree-sha1 = "311349fd1c93a31f783f977a71e8b062a57d4101"
uuid = "410a4b4d-49e4-4fbc-ab6d-cb71b17b3775"
version = "0.1.13"

[[deps.URIs]]
git-tree-sha1 = "bef26fb046d031353ef97a82e3fdb6afe7f21b1a"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.6.1"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"
version = "1.11.0"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"
version = "1.11.0"

[[deps.Unitful]]
deps = ["Dates", "LinearAlgebra", "Random"]
git-tree-sha1 = "c25751629f5baaa27fef307f96536db62e1d754e"
uuid = "1986cc42-f94f-5a68-af5c-568840ba703d"
version = "1.27.0"

    [deps.Unitful.extensions]
    ConstructionBaseUnitfulExt = "ConstructionBase"
    ForwardDiffExt = "ForwardDiff"
    InverseFunctionsUnitfulExt = "InverseFunctions"
    LatexifyExt = ["Latexify", "LaTeXStrings"]
    NaNMathExt = "NaNMath"
    PrintfExt = "Printf"

    [deps.Unitful.weakdeps]
    ConstructionBase = "187b0558-2788-49d3-abe0-74a17ed4e7c9"
    ForwardDiff = "f6369f11-7733-5829-9624-2563aa707210"
    InverseFunctions = "3587e190-3f89-42d0-90ee-14403ec27112"
    LaTeXStrings = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
    Latexify = "23fbe1c1-3f47-55db-b15f-69d7ec21a316"
    NaNMath = "77ba4419-2d1f-58cd-9bb1-8ffee604a2e3"
    Printf = "de0858da-6303-5e67-8744-51eddeeeb8d7"

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
# ╟─01d0206c-90d7-4dab-a1be-52619d154f40
# ╟─34436b8a-b8ad-4875-bf99-86b8f8b2a695
# ╟─c22b8b8e-f178-425c-8882-da6ace3626f6
# ╠═a1d06a4c-1e18-4dcd-b5d4-8c8a558000d1
# ╟─deaa9324-b1f2-4167-8500-5f0039486d4f
# ╟─238c0262-3734-4bc6-94ee-b907d91f47a0
# ╠═4b18f32c-4621-4474-bf3f-808ec2b4fe1f
# ╟─136c4134-3423-447c-8a38-e3346407112c
# ╟─89d6ecd9-1185-47c9-b0ad-fcbc2d8b7941
# ╠═1c594f1f-5119-4e65-b873-9a98de628d7e
# ╟─fbc08814-1279-4614-99ae-c3f23434ad17
# ╟─c9a803a2-d30f-4acf-86ee-6a0732a25345
# ╠═7a394f68-ce0f-47d5-8515-5169925ae687
# ╟─e3813ced-c01a-4745-99b3-fd77bf6ee6ba
# ╟─6e1dad95-b6ec-409a-bc6c-fbf479f05ac0
# ╠═31d599a7-e4d8-4c64-bb68-de6246325213
# ╟─c01d4362-bdf1-4e40-b6ee-246fbb5be730
# ╟─3cc50f07-e16c-4b0d-9799-cf61671a5e3d
# ╠═ef199255-e146-4bc8-b2d0-accd69e97d83
# ╟─f659b84a-22f5-4aa9-a2c4-ece9a1175ede
# ╟─647797c9-0ad3-44b4-b35a-ad78dfafa60c
# ╠═2bfa8df6-a36d-4d4e-8a87-14c8aabed144
# ╟─6f93bd90-25d8-497f-92ff-562fe614b5e5
# ╟─45a5ec15-30a3-41b7-a8b1-cc7a0a5a52d8
# ╠═e74b5827-8f34-43fe-a0da-4f513e6ac388
# ╟─0f4bf200-6daa-4036-86b0-c8caa23f0ec2
# ╟─da7c71ce-e6b7-40db-b2bc-50fbf0b59c1f
# ╠═d890bce7-bbcc-4f4c-8d00-8922b04c8b15
# ╟─030f56ad-6a21-4bcb-aba5-d8ac9b2736b6
# ╟─03550662-ee38-4879-9a63-8380880dcc8f
# ╠═7deeda72-a210-4f92-a059-da6bf63c98f5
# ╟─764efb07-7619-4ea5-974e-cd36d892e90e
# ╟─2cc2b217-e0d2-445b-b9ee-aaa16964621f
# ╠═0498932c-95fd-4b70-a10b-1cf32ae1390a
# ╟─14216bf3-d98c-4d0f-bd6f-d65318ef3aad
# ╟─36ddd671-212d-4e2d-816e-8ca32a0528ee
# ╠═4e04ba71-26c0-4d99-b04a-37550daf8a0a
# ╟─1b1ca141-7aa3-4d1b-890d-aa4de36d7a15
# ╟─05544a2f-15d5-4d77-a786-a72b3f35e4fb
# ╠═0d3091f8-d2e2-4cd9-84fe-c1a16cc4c76d
# ╟─d7e49d4c-a24a-4b1e-a454-379903413c0e
# ╟─c7452d22-8045-44d5-ae5b-be375f8f2fe0
# ╠═d9ad11e7-2099-4ec7-b4c3-70d83adbdecc
# ╟─e6eb9f63-7eda-4e94-bc0b-700121f13ea0
# ╟─6a209624-266f-4379-b371-85ee746f5c85
# ╠═c0d6dc1c-f180-4e41-8784-c86600be7925
# ╟─a823c6f8-6311-4343-b51b-d6599c1abd8e
# ╟─73208c22-29c9-4031-bd0f-99d8fd82cd2e
# ╠═ce1dab1a-edf8-450d-82b6-3ab63f95ba81
# ╟─157c9090-554c-4515-9458-5d017b304aad
# ╟─d2540a56-4cf4-4a61-a07b-f57de767d224
# ╟─da513126-14d4-4eaa-8e7a-f6339cb2bc17
# ╟─5726b945-44d7-4208-bc85-200a73863e21
# ╟─86e7000b-3675-4703-8819-470f793c2d69
# ╟─6ae9d1a2-3733-40e2-ba0e-6a563cb76ae7
# ╠═c3c0fa78-d354-42d0-9490-c8572b305f74
# ╠═762e56e8-087e-4a7c-9c7f-a6b5006a0cbf
# ╠═5a7f7ec0-67e4-424b-9a1c-03cf870d735b
# ╠═684d49af-05c5-4fae-84c0-33867f619371
# ╠═2916685d-07b4-4fce-822a-c42ec8f8605c
# ╟─53835b1f-c7e4-47ee-a36f-4adcd2a34182
# ╟─7079b6c8-bee9-4e5f-a62a-f0e0617b7225
# ╟─7284ca8c-09e5-44ab-98de-db8d2e56053d
# ╟─42d22e06-8fd2-42a4-90ca-f81fafb66b7d
# ╟─287c75f4-5d2e-492d-be95-1819f6ca274d
# ╟─c16d8096-8c8d-4487-8ad5-50bc43a5205d
# ╟─de7fcd25-b476-4e50-a649-370a08b3d5df
# ╟─d9d35c7c-311d-4ae1-8737-80ff3500744a
# ╟─bdd147b1-3e4b-4c63-a11c-462c1e90c612
# ╟─fcb064ab-b4ca-4898-951d-7fd623d6c8ac
# ╟─8ed2462b-c5b2-4ff4-b77f-8febe42eac58
# ╟─cb34c847-da1c-47d4-99bd-5522a55cb3fb
# ╟─92588797-2b09-4146-bce6-68a5a5cf428c
# ╟─3a097238-6f24-402b-aaeb-216f3f2ba7ef
# ╟─7b2279cb-dbf4-4077-8c66-002d925b7806
# ╟─d18c0e0f-aa4e-4a6b-8ed6-7697b28a3192
# ╟─404c6734-61d2-4dc3-839c-204a16a561d5
# ╟─831e5e30-3522-41ec-b74f-939230c0065a
# ╟─97e51f8d-91d4-4aab-a594-516b3aae6d90
# ╟─5b7621b1-d0da-4955-844c-fd4c31373efd
# ╠═aa94d7a0-b24a-11ef-2de2-47a66b1c37be
# ╟─9888e0c8-335a-45f7-a16f-2ffda567f98b
# ╟─bc238aa5-05db-40bc-9ed1-cfa8dd891441
# ╟─0c19b482-4946-4ee4-96db-0b5fc5f6f551
# ╟─46bf0b39-6f4a-4748-bcd4-07cdb9ec3272
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
