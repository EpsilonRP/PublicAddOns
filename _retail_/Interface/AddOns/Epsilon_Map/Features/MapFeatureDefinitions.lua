local addon_name, ns = ...
local MTM = MapTextureManager

ns.MFD = {}

ns.MFD.InvalidDefinition = {
	id = "INVALID_DEFINITION",
	name = "ERROR: Missing Definition!",
	atlas = "runecarving-icon-power-empty-error",
	width = 78,
	height = 78,
	catID = "misc"
}

------------------------------------------------------------
--- Utilities
------------------------------------------------------------

local assetPath = "Interface\\AddOns\\" .. addon_name .. "\\Assets\\"
local a = function(...) return assetPath .. table.concat({ ... }, "\\") end

local mapTexturesPath = "Interface\\AddOns\\" .. addon_name .. "\\Assets\\MapTextures\\"
local t = function(...) return mapTexturesPath .. table.concat({ ... }, "\\") end

local defaultCircleMask = t("Terrain", "MapTerrain_Mask")
local defaultHorizMask = t("Terrain_BG", "Mask")
local defaultVertMask = t("Terrain_BG", "MaskVert")

local texCoordByColumnAndRow = function(
	col, row,          -- 1-based cell position
	totalCols, totalRows, -- atlas dimensions
	xInset, yInset,    -- % inset per cell
	colSpan, rowSpan   -- how many columns/rows this entry spans
)
	colSpan          = colSpan or 1
	rowSpan          = rowSpan or 1

	-- base cell coordinates
	local cellLeft   = (col - 1) / totalCols
	local cellTop    = (row - 1) / totalRows

	-- span extends the right/bottom edges by N cells
	local cellRight  = (col - 1 + colSpan) / totalCols
	local cellBottom = (row - 1 + rowSpan) / totalRows

	-- inset is relative to the ACTUAL texture area (including spans) as a percent (i.e., 21 is 21% which is 10.5% cropped each side)
	local xInsetPct  = (xInset and xInset / 100 or 0) / 2
	local yInsetPct  = (yInset and yInset / 100 or 0) / 2

	local texWidth   = cellRight - cellLeft
	local texHeight  = cellBottom - cellTop

	local left       = cellLeft + texWidth * xInsetPct
	local right      = cellRight - texWidth * xInsetPct
	local top        = cellTop + texHeight * yInsetPct
	local bottom     = cellBottom - texHeight * yInsetPct

	return { left, right, top, bottom }
end

local tcCR = texCoordByColumnAndRow

local dimByPercentInset = function(originalSize, percent)
	return math.floor(originalSize * (1 - (percent / 100)) + 0.5)
end
local p = dimByPercentInset

-- Text Support

local textSymbols = { "\"", ".", ",", "'", "-", "/", "(", ")", "[", "]", "!",
	"?", "<", ">", "“", "”", "*", "&", "~", "_", "|", "#", "+", "=" }
local textMap = {
	[string.byte("\"")] = 27,
	[string.byte(".")] = 28,
	[string.byte(",")] = 29,
	[string.byte("'")] = 30,
	[string.byte("-")] = 31,
	[string.byte("/")] = 32,
	[string.byte("(")] = 33,
	[string.byte(")")] = 34,
	[string.byte("[")] = 35,
	[string.byte("]")] = 36,
	[string.byte("!")] = 37,
	[string.byte("?")] = 38,
	[string.byte("<")] = 39,
	[string.byte(">")] = 40,
	[string.byte("“")] = 41,
	[string.byte("”")] = 42,
	[string.byte("*")] = 43,
	[string.byte("&")] = 44,

	[string.byte("~")] = 55,
	[string.byte("_")] = 56,
	[string.byte("|")] = 57,
	[string.byte("#")] = 58,
	[string.byte("+")] = 59,
	[string.byte("=")] = 60,
}

local charWidths = {
	-- manual overrides
	["A"] = 10,
	["C"] = 8,
	["D"] = 9,
	["E"] = 7,
	["F"] = 6,
	["G"] = 9,
	["H"] = 8,
	["I"] = 5,
	["J"] = 6,
	["K"] = 8,
	["M"] = 12,
	["N"] = 9,
	["O"] = 10,
	["P"] = 7,
	["Q"] = 10,
	["R"] = 8,
	["T"] = 8,
	["U"] = 9,
	["V"] = 9,
	["W"] = 13,
	["X"] = 8,	
	["Y"] = 9,
	["'"] = 4,
	["."] = 4,
	["!"] = 4,
	-- fallback for all others:
	default = 7,
}

local kerningPairs = {
	-- AV WY style pairs
	["AV"] = -2,
	["VA"] = -2,
	["AW"] = -1,
	["WA"] = -1,
	["AY"] = -2,
	["YA"] = -2,

	["FA"] = -1,
	["PA"] = -1,
	["RA"] = 0,

	-- V/W/Y/T before rounded letters (O,Q,C,G)
	["VO"] = 0,
	["OV"] = -0.5,
	["OI"] = -1,
	["VC"] = -1,
	["CV"] = -1,
	["VG"] = 0,
	["GV"] = -1,
	["VQ"] = -1,
	["QV"] = -1,

	["WO"] = -1,
	["OW"] = -1,
	["WC"] = -1,
	["CW"] = -1,
	["WG"] = -1,
	["GW"] = -1,
	["WQ"] = -1,
	["QW"] = -1,

	["YO"] = -1,
	["OY"] = -1,
	["YC"] = -1,
	["CY"] = -1,
	["YG"] = -1,
	["GY"] = -1,
	["YQ"] = -1,
	["QY"] = -1,

	-- TA TO pairs (T is tall/overhang shape)
	["TO"] = -1,
	["OT"] = -0.5,
	["TC"] = -1,
	["CT"] = -1,
	["TG"] = -1,
	["GT"] = -1,
	["TQ"] = -1,
	["QT"] = -1,
	["TA"] = -1,
	["AT"] = -1,

	-- Tighten space before punctuation that tucks under overhang letters
	["T."] = -2,
	[".T"] = -1,
	["T,"] = -2,
	[",T"] = -1,
	["T'"] = -1,
	["'T"] = -1,

	["V."] = -2,
	[".V"] = -1,
	["V,"] = -2,
	[",V"] = -1,
	["V'"] = -1,
	["'V"] = -1,

	["W."] = -1,
	[".W"] = -1,
	["W,"] = -1,
	[",W"] = -1,
	["W'"] = -1,
	["'W"] = -1,

	["Y."] = -2,
	[".Y"] = -1,
	["Y,"] = -2,
	[",Y"] = -1,
	["Y'"] = -1,
	["'Y"] = -1,

	-- Left-side punctuation hugging (opening punctuation)
	["(A"] = -1,
	["(O"] = -1,
	["(Q"] = -1,
	["(C"] = -1,
	["(G"] = -1,
	["[A"] = -1,
	["[O"] = -1,
	["[Q"] = -1,
	["[C"] = -1,
	["[G"] = -1,
	["<A"] = -1,
	["<O"] = -1,
	["<Q"] = -1,
	["<C"] = -1,
	["<G"] = -1,

	-- Closing punctuation hugging (looks closer to angled letters)
	["A)"] = -1,
	["O)"] = -1,
	["C)"] = -1,
	["G)"] = -1,
	["Q)"] = -1,
	["A]"] = -1,
	["O]"] = -1,
	["C]"] = -1,
	["G]"] = -1,
	["Q]"] = -1,
	["A>"] = -1,
	["O>"] = -1,
	["C>"] = -1,
	["G>"] = -1,
	["Q>"] = -1,

	-- Slash pairs
	["/A"] = -2,
	["A/"] = -1,
	["/V"] = -1,
	["/Y"] = -1,
	["V/"] = -1,
	["Y/"] = -1,

	-- Digits that commonly kern visually
	["1."] = -1,
	[".1"] = -1,
	["1,"] = -1,
	[",1"] = -1,
	["7."] = -1,
	[".7"] = -1,
	["7,"] = -1,
	[",7"] = -1,

	["1)"] = -1,
	["1]"] = -1,
	["(1"] = -1,
	["[1"] = -1,

	-- Misc symbols that traditionally tighten
	["A-"] = -1,
	["V-"] = -1,
	["Y-"] = -1,
	["T-"] = -1,
	["-A"] = -1,
	["-V"] = -1,
	["-Y"] = -1,
	["-T"] = -1,

	["A_"] = 1, -- underscore visually needs room
	["V_"] = 1,
	["Y_"] = 1,

	["A&"] = -1,
	["T&"] = -1,
	["V&"] = -1,
	["Y&"] = -1,
	["&A"] = -1,
	["&T"] = -1,
	["&V"] = -1,
	["&Y"] = -1,

	-- Tight around "|" vertical bar
	["A|"] = -1,
	["V|"] = -1,
	["Y|"] = -1,
	["|A"] = -1,
	["|V"] = -1,
	["|Y"] = -1,

	-- Apostrophe after angled/tall/open shapes
	["A'"] = -2,
	["F'"] = -1,
	--["T'"] = -1,
	--["V'"] = -1,
	--["W'"] = -1,
	--["Y'"] = -1,
	["R'"] = -1,
	["P'"] = -1,
	["L'"] = -2,

	-- Tighten ' around rounded letters
	["O'"] = -1,
	["C'"] = -1,
	["G'"] = -1,
	["Q'"] = -1,

	-- Common straight/vertical letters
	["H'"] = -1,
	["K'"] = -1,
	["N'"] = -1,
	["M'"] = -1,
	["D'"] = -1,
	["B'"] = -1,
	["E'"] = -1,

	-- Tighten on certain numbers
	["1'"] = -1,
	["2'"] = -1,
	["3'"] = -1,
	["5'"] = -1,
	["7'"] = -1,
	["8'"] = -1,
	["9'"] = -1,

	-- Apostrophe before angled/tall shapes
	["'A"] = -1,
	--["'T"] = -1,
	--["'V"] = -1,
	--["'W"] = -1,
	--["'Y"] = -1,

	-- Rounded letters
	["'O"] = -1,
	["'C"] = -1,
	["'G"] = -1,
	["'Q"] = -1,

	-- Other capitals
	["'F"] = -1,
	["'P"] = -1,
	["'R"] = -1,

	["''"] = -1, -- brings double-apostrophes closer
}


local function computeCharLayouts(line)
	local layouts = {}
	local total = 0

	for i = 1, #line do
		local c = line:sub(i, i)
		local w = charWidths[c] or charWidths.default

		-- kerning adjustment vs previous character
		if i > 1 then
			local prev = line:sub(i - 1, i - 1)
			local pair = prev .. c
			local kern = kerningPairs[pair]
			if kern then
				total = total + kern -- apply kerning space
			end
		end

		layouts[i] = {
			w = w,
			offset = total,
		}

		total = total + w
	end

	return layouts, total
end

ns.MFD._computeCharLayouts = computeCharLayouts


local function getTexCoordsFromAtlasSheetPosition(pos, gridSize)
	local col = ((pos - 1) % gridSize) + 1
	local row = math.ceil(pos / gridSize)

	return tcCR(col, row, gridSize, gridSize)
end
local tcSP = getTexCoordsFromAtlasSheetPosition

local function getCharTextMapPos(char)
	if type(char) == "string" then
		char = string.byte(char)
	end
	return textMap[char]
end

local alphabetTextures = {
	{ name = "Friz Quadrata Map",          tag = "font_frizqt",            file = t("Text", "AtlasAlphabetFrizQuadrata"), },
	{ name = "Friz Quadrata Map (Tint)",   tag = "font_frizqt_tint",       file = t("Text", "AtlasAlphabetFrizQuadrataTint"), },
	{ name = "Friz Quadrata Clean",        tag = "font_frizqt_clean",      file = t("Text", "AtlasAlphabetFrizQuadrataGold"), },
	{ name = "Friz Quadrata Clean (Tint)", tag = "font_frizqt_clean_tint", file = t("Text", "AtlasAlphabetFrizQuadrataPlainTint"), },
}
local defaultFont = "font_frizqt"

local fontMap = {}
for _, v in ipairs(alphabetTextures) do
	fontMap[v.tag] = v
end

function ns.MFD:GetFontList()
	return alphabetTextures
end

local function getTextureAndCoordsForText(charByte, font)
	local atlasPos
	if font and fontMap[font] then
		font = fontMap[font]
	else
		font = fontMap[defaultFont]
	end

	if charByte >= 65 and charByte <= 90 then  -- alphabet
		atlasPos = charByte - 64
	elseif charByte >= 48 and charByte <= 57 then -- numeric
		atlasPos = charByte - 3
	else                                       -- check for symbol
		atlasPos = getCharTextMapPos(charByte)
	end

	if atlasPos then -- supported character
		local texCoords = getTexCoordsFromAtlasSheetPosition(atlasPos, 8)
		return font.file, texCoords
	end
end
ns.MFD._getTextureAndCoordsForText = getTextureAndCoordsForText

------------------------------------------------------------
--- Definitions
--- Format:
--- def = {
---   id = "unique_id",
---   file|atlas = "file_path" or atlasName, -- use t("filename") as a shortcut to the map textures folder
---   texCoords = { left, right, top, bottom }, -- optional, if it's a atlas style texture. Use tcCR(col, row, totalCols, totalRows) to generate easily.
---   width = 128, -- default width in pixels
---   height = 128, -- default height in pixels
---   name = "Friendly Name", -- for UI display
---   tile = boolean, 		-- if the texture should scale by tiling instead of scaling
---   mask = "file_path",	-- mask for tiling, does scale normally; can be 'true' to just use default terrain circular mask
--- }
---
--- Categories
--- Format:
--- cat = {
--- 	id = "unique_id",
--- 	name = "Friendly Name for UX",
--- 	icon = "textureForIcon",
--- 	layer = #defaultLayer (1-16)
--- 	definitions = { def1, def2, ... } -- List of definitions auto-loaded with this Category. Just a helper Util for organization really.
--- }
------------------------------------------------------------

-- Copyable Template:
--[[

MTM:RegisterCategory({
	id = "terrain",
	name = "Base Terrain",
	icon = t("MapTerrain_Scalable"),
	color = CreateColorFromBytes(48 * 3, 78 * 3, 20 * 3, 255),
	layer = 2,
	definitions = {
		{
			id = "trn_grass_01",
			file = t("MapTerrainGreenGrassTile"),
			--texCoords = tcCR(4, 4, 4, 4), -- col, row, totalCols, totalRows
			width = 256,
			height = 256,
			name = "Grass (Grasslands)",
			tile = true,
			mask = t("MapTerrain_Mask"),
		},
	}
})

MTM:RegisterCategory({
	id = "arch_major",
	name = "Major Architecture",
	icon = t("MapTerrain_Scalable"),
	color = CreateColorFromHexString("FF167F9F"),
	layer = 10,
	definitions = {
		{
			id = "bld_dragon_tower",
			file = t("Architecture", "MapArchitecture"),
			texCoords = tcCR(1, 4, 8, 8, 21, 21), -- col, row, totalCols, totalRows, xInset%, yInset%
			width = p(128, 21),
			height = p(128, 21),
			name = "Dragon Tower",
		}
	}
})


--]]

--[[
Categories:

id = name,							default layer (IN NON-REVERSE: 1 = bottom, 16 = top)

terrainbg = Background Terrain,		1
ocean = Surrounding Seas,			3
edges = Coasts/Map Edges,			4
mountains = Mountains,				5
rivers = Lakes/Rivers,				6
ridges = Ridges,					7
roads = Roads,						8
arch_major = Major Structures,		9
garrison = Garrison Structures,		9
arch_minor = Minor Structures,		10
misc = Misc							11
foliage = Foliage,					12
textArt = Text Art					13
text = Text							14
art = Map Art						15
stamps = Stamps, Seals, Stickers	16


--]]

local bgTerrainGen = {}
local bgTerrainFiles = {
	"Base Ground",
	"Base Ocean",
	"Elwynn Grass",
	"Azshara Grass",
	"Barrens Grass",
	"Bioluminescent Dirt",
	"Bloodmyst Grass",
	"Bright Ocean",
	"Crystal Snow",
	"Darkmoon Grass",
	"Dark Slate",
	"Dread Wastes Dirt",
	"Dread Wastes Grass",
	"Dry Ice",
	"Dull Dirt",
	"Dusty Grass",
	"Enchanted Water",
	"Ghostlands Grass",
	"Grey Dirt",
	"Grove Grass",
	"Helheim Dirt",
	"Kaareshi Sand",
	"Lava",
	"Nazjatar Coral",
	"Netherstorm Dirt",
	"Pale Grass",
	"Slime",
	"Snow",
	"Telogrus Dirt",
	"Tirisfal Grass",
	"Tundra Ground",
	"Wavy Sand",
	"Westfall Grass",
	"Wetlands Grass",
	"Mountains 1",
	"Mountains 2*0.5",
}

local function genBGTerrainDefinitionsForFile(baseName, fileName, filePath, scaleOverride)
	fileName = fileName:lower():gsub("%s", "")
	local defHoriz = {
		id = "trn_" .. fileName .. "_hor",
		file = filePath,
		name = baseName .. " (BG Horiz)",
		width = 256,
		height = 256,
		scale = scaleOverride and tonumber(scaleOverride) or nil,
		tile = true,
		mask = defaultHorizMask,
	}
	local defVert = {
		id = "trn_" .. fileName .. "_vrt",
		file = filePath,
		name = baseName .. " (BG Vert)",
		width = 256,
		height = 256,
		scale = scaleOverride and tonumber(scaleOverride) or nil,
		tile = true,
		mask = defaultVertMask,
	}
	local defCircle = {
		id = "trn_" .. fileName .. "_cir",
		file = filePath,
		name = baseName .. " (BG Circle)",
		width = 256,
		height = 256,
		scale = scaleOverride and tonumber(scaleOverride) or nil,
		tile = true,
		mask = defaultCircleMask,
	}
	table.insert(bgTerrainGen, defHoriz)
	table.insert(bgTerrainGen, defVert)
	table.insert(bgTerrainGen, defCircle)
end
for k, v in ipairs(bgTerrainFiles) do
	local baseName, scaleOverride = strsplit("*", v)
	local fileName = baseName:gsub("%s", ""):lower()
	genBGTerrainDefinitionsForFile(baseName, fileName, t("Terrain_BG", fileName), scaleOverride)
end
-- Extra specific ones
genBGTerrainDefinitionsForFile("Adventure Map Parchment", "AdventureMapParchement", "interface/adventuremap/adventuremapparchmenttile", nil)
genBGTerrainDefinitionsForFile("Adventure Map Parchment (Dark)", "AdventureMapParchementDark", "interface/garrison/adventuremissionsframeparchment", nil)
genBGTerrainDefinitionsForFile("Adventure Map Background", "AdventureMapWater", "interface/adventuremap/adventuremaptilebg", 0.25)

-- Category Definitions
MTM:RegisterCategory({ id = "terrainbg", name = "Background Terrain (Tiled)", layer = 1, icon = "Terrain", definitions = bgTerrainGen, color = CreateColorFromHexString("FF9f7030"), })
MTM:RegisterCategory({ id = "ocean", name = "Surrounding Seas", layer = 3, icon = "Oceans", color = CreateColorFromHexString("FF6f98f5"), })
MTM:RegisterCategory({ id = "edges", name = "Coasts / Map Edges", layer = 4, icon = "Edges", color = CreateColorFromHexString("FFffbf00"), })
MTM:RegisterCategory({ id = "mountains", name = "Mountains", layer = 5, icon = "Mountains", color = CreateColorFromHexString("FFD63434"), })
MTM:RegisterCategory({ id = "rivers", name = "Rivers / Lakes", layer = 6, icon = "Rivers", color = CreateColorFromHexString("FF5b9326"), })
MTM:RegisterCategory({ id = "ridges", name = "Ridges", layer = 7, icon = "Ridges", color = CreateColorFromHexString("FF9f7519"), })
MTM:RegisterCategory({ id = "roads", name = "Roads", layer = 8, icon = "Roads", color = CreateColorFromHexString("FFA418A8"), })
MTM:RegisterCategory({ id = "garrison", name = "Garrison Structures", layer = 9, icon = "Garrison", color = CreateColorFromHexString("FF5e999f"), })
MTM:RegisterCategory({ id = "arch_major", name = "Major Structures", layer = 9, icon = "MajorArchitecture", color = CreateColorFromHexString("FF168d9f"), })
MTM:RegisterCategory({ id = "arch_minor", name = "Minor Structures", layer = 10, icon = "MinorArchitecture", color = CreateColorFromHexString("FFB3B53A"), })
MTM:RegisterCategory({ id = "foliage", name = "Plants, Tree, and Rocks", layer = 11, icon = "Foliage", color = CreateColorFromHexString("FF99FF00"), })
MTM:RegisterCategory({ id = "misc", name = "Miscellaneous", layer = 12, icon = "Misc", color = CreateColorFromHexString("FF84B109"), })
MTM:RegisterCategory({ id = "textart", name = "Text Art", layer = 13, icon = "TextArt", color = CreateColorFromHexString("FFEBB962"), })
MTM:RegisterCategory({ id = "text", name = "Text", layer = 14, icon = "Text", color = CreateColorFromHexString("FFFBFF00"), })
MTM:RegisterCategory({ id = "art", name = "Map Art / Overlays", layer = 15, icon = "Art", color = CreateColorFromHexString("FFFF8C00"), })
MTM:RegisterCategory({ id = "stamps", name = "Stamps, Seals, Stickers", layer = 16, icon = "Stamps", color = CreateColorFromHexString("FF9762EB"), })

do -- Alphanumeric Text
	for _, atlasInfo in ipairs(alphabetTextures) do
		local atlasTag = atlasInfo.tag
		local atlasName = atlasInfo.name
		local atlasFile = atlasInfo.file

		for i = 1, 26, 1 do
			local char = i + 64
			MTM:RegisterDefinition({
				id = ("%s_%s"):format(atlasTag, string.char(char)),
				file = atlasFile,
				texCoords = tcSP(i, 8),
				width = (128),
				height = (128),
				catID = "text",
				name = ("Alphabet - %s (%s)"):format(string.char(char), atlasName),
			})
		end
		for i = 0, 9, 1 do
			local char = i + 48
			MTM:RegisterDefinition({
				id = ("%s_%s"):format(atlasTag, string.char(char)),
				file = atlasFile,
				texCoords = tcSP(i + 45, 8),
				width = (128),
				height = (128),
				catID = "text",
				name = ("Number - %s (%s)"):format(string.char(char), atlasName),
			})
		end
		for i = 1, #textSymbols do
			local symbol = textSymbols[i]
			local symPos = getCharTextMapPos(symbol)

			MTM:RegisterDefinition({
				id = ("%s_%s"):format(atlasTag, symbol),
				file = atlasFile,
				texCoords = tcSP(symPos, 8),
				width = (128),
				height = (128),
				catID = "text",
				name = ("Symbol - %s (%s)"):format(symbol, atlasName),
			})
		end
	end
end



---------------------------------------------------------
--- Blizzard Atlas Imports
---------------------------------------------------------

local blizzAtlasDefinitions = {
	{
		name = "Alliance Garrison (Tier 1)",
		category = "garrison",
		data = {
			{ name = "Barracks",      atlas = "Alliance_Tier1_Barracks" },
			{ name = "Professions",   atlas = "Alliance_Tier1_Professions" },
			{ name = "Town Hall",     atlas = "Alliance_Tier1_TownHall" },
			{ name = "Mine",          atlas = "Alliance_Tier1_Mine" },
			{ name = "Trading 1",     atlas = "Alliance_Tier1_Trading1" },
			{ name = "Armory 1",      atlas = "Alliance_Tier1_Armory1" },
			{ name = "Mage 1",        atlas = "Alliance_Tier1_Mage1" },
			{ name = "Mage 2",        atlas = "Alliance_Tier1_Mage2" },
			{ name = "Armory 2",      atlas = "Alliance_Tier1_Armory2" },
			{ name = "Stables 1",     atlas = "Alliance_Tier1_Stables1" },
			{ name = "Barracks 1",    atlas = "Alliance_Tier1_Barracks1" },
			{ name = "Stables 2",     atlas = "Alliance_Tier1_Stables2" },
			{ name = "Lumber 1",      atlas = "Alliance_Tier1_Lumber1" },
			{ name = "Barn 2",        atlas = "Alliance_Tier1_Barn2" },
			{ name = "Professions 2", atlas = "Alliance_Tier1_Professions2" },
			{ name = "Inn 1",         atlas = "Alliance_Tier1_Inn1" },
			{ name = "Farm",          atlas = "Alliance_Tier1_Farm" },
			{ name = "Menagery 1",    atlas = "Menagery1" },
			{ name = "Arena 2",       atlas = "Alliance_Tier1_Arena2" },
			{ name = "Lumbere 2",     atlas = "Alliance_Tier1_Lumber2" },
			{ name = "Trading 2",     atlas = "Alliance_Tier1_Trading2" },
			{ name = "Fishing",       atlas = "Alliance_Tier1_Fishing" },
			{ name = "Barn 1",        atlas = "Alliance_Tier1_Barn1" },
			{ name = "Inn 2",         atlas = "Alliance_Tier1_Inn2" },
			{ name = "Arena 1",       atlas = "Alliance_Tier1_Arena1" },
			{ name = "Barracks 2",    atlas = "Alliance_Tier1_Barracks2" },
			{ name = "Workshop 1",    atlas = "Alliance_Tier1_Workshop1" },
			{ name = "Workshop 2",    atlas = "Alliance_Tier1_Workshop2" },
		}
	},

	{
		name = "Alliance Garrison (Tier 2)",
		category = "garrison",
		data = {
			{ name = "Arena 1",    atlas = "Alliance_Tier2_Arena1" },
			{ name = "Arena 2",    atlas = "Alliance_Tier2_Arena2" },
			{ name = "Armory 1",   atlas = "Alliance_Tier2_Armory1" },
			{ name = "Armory 2",   atlas = "Alliance_Tier2_Armory2" },
			{ name = "Barn 1",     atlas = "Alliance_Tier2_Barn1" },
			{ name = "Barn 2",     atlas = "Alliance_Tier2_Barn2" },
			{ name = "Barracks 1", atlas = "Alliance_Tier2_Barracks1" },
			{ name = "Inn 1",      atlas = "Alliance_Tier2_Inn1" },
			{ name = "Inn 2",      atlas = "Alliance_Tier2_Inn2" },
			{ name = "Lumber 1",   atlas = "Alliance_Tier2_Lumber1" },
			{ name = "Lumber 2",   atlas = "Alliance_Tier2_Lumber2" },
			{ name = "Mage 1",     atlas = "Alliance_Tier2_Mage1" },
			{ name = "Mage 2",     atlas = "Alliance_Tier2_Mage2" },
			{ name = "Stables 1",  atlas = "Alliance_Tier2_Stables1" },
			{ name = "Stables 2",  atlas = "Alliance_Tier2_Stables2" },
			{ name = "Trading 1",  atlas = "Alliance_Tier2_Trading1" },
			{ name = "Trading 2",  atlas = "Alliance_Tier2_Trading2" },
			{ name = "Barracks 2", atlas = "Alliance_Tier2_Barracks2" },
			{ name = "Workshop 1", atlas = "Alliance_Tier2_Workshop1" },
			{ name = "Workshop 2", atlas = "Alliance_Tier2_Workshop2" },
		}
	},

	{
		name = "Alliance Garrison (Tier 3)",
		category = "garrison",
		data = {
			{ name = "Barn 1",     atlas = "Alliance_Tier3_Barn1" },
			{ name = "Lumber 1",   atlas = "Alliance_Tier3_Lumber1" },
			{ name = "Mage 2",     atlas = "Alliance_Tier3_Mage2" },
			{ name = "Inn 1",      atlas = "Alliance_Tier3_Inn1" },
			{ name = "Barracks 1", atlas = "Alliance_Tier3_Barracks1" },
			{ name = "Armory 2",   atlas = "Alliance_Tier3_Armory2" },
			{ name = "Mage 1",     atlas = "Alliance_Tier3_Mage1" },
			{ name = "Lumber 2",   atlas = "Alliance_Tier3_Lumber2" },
			{ name = "Inn 2",      atlas = "Alliance_Tier3_Inn2" },
			{ name = "Stables 1",  atlas = "Alliance_Tier3_Stables1" },
			{ name = "Trading 2",  atlas = "Alliance_Tier3_Trading2" },
			{ name = "Arena 1",    atlas = "Alliance_Tier3_Arena1" },
			{ name = "Trading 1",  atlas = "Alliance_Tier3_Trading1" },
			{ name = "STables 2",  atlas = "Alliance_Tier3_Stables2" },
			{ name = "Barn 2",     atlas = "Alliance_Tier3_Barn2" },
			{ name = "Armory 1",   atlas = "Alliance_Tier3_Armory1" },
			{ name = "Arena 2",    atlas = "Alliance_Tier3_Arena2" },
			{ name = "Barracks 1", atlas = "Alliance_Tier3_Barracks2" },
			{ name = "Workshop 1", atlas = "Alliance_Tier3_Workshop1" },
			{ name = "Workshop 2", atlas = "Alliance_Tier3_Workshop2" },
		}
	},

	{
		name = "Vindicaar",
		category = "misc",
		data = {
			{ name = "Gray",   atlas = "FlightMaster_VindicaarArgus-Taxi_Frame_Gray" },
			{ name = "Green",  atlas = "FlightMaster_VindicaarArgus-Taxi_Frame_Green" },
			{ name = "Yellow", atlas = "FlightMaster_VindicaarArgus-Taxi_Frame_Yellow" },
		}
	},




	{
		name = "Argus Vindicaar",
		category = "misc",
		data = {
			{ name = "Vindicaar (Map)",      atlas = "FlightMaster_VindicaarArgus-TaxiNode_Neutral" },
			{ name = "Vindicaar (Map Dark)", atlas = "FlightMaster_VindicaarArgus-TaxiNode_Special" },
		}
	},

	{
		name = "Artifact Runes",
		category = "text",
		data = {
			{ name = "Rune 1 Light",  atlas = "Rune-01-light" },
			{ name = "Rune 2 Light",  atlas = "Rune-02-light" },
			{ name = "Rune 3 Light",  atlas = "Rune-03-light" },
			{ name = "Rune 4 Light",  atlas = "Rune-04-light" },
			{ name = "Rune 5 Light",  atlas = "Rune-05-light" },
			{ name = "Rune 6 Light",  atlas = "Rune-06-light" },
			{ name = "Rune 7 Light",  atlas = "Rune-07-light" },
			{ name = "Rune 8 Light",  atlas = "Rune-08-light" },
			{ name = "Rune 9 Light",  atlas = "Rune-09-light" },
			{ name = "Rune 10 Light", atlas = "Rune-10-light" },
			{ name = "Rune 11 Light", atlas = "Rune-11-light" },
			{ name = "Rune 1 Dark",   atlas = "Rune-01-dark" },
			{ name = "Rune 2 Dark",   atlas = "Rune-02-dark" },
			{ name = "Rune 3 Dark",   atlas = "Rune-03-dark" },
			{ name = "Rune 4 Dark",   atlas = "Rune-04-dark" },
			{ name = "Rune 5 Dark",   atlas = "Rune-05-dark" },
			{ name = "Rune 6 Dark",   atlas = "Rune-06-dark" },
			{ name = "Rune 7 Dark",   atlas = "Rune-07-dark" },
			{ name = "Rune 8 Dark",   atlas = "Rune-08-dark" },
			{ name = "Rune 9 Dark",   atlas = "Rune-09-dark" },
			{ name = "Rune 10 Dark",  atlas = "Rune-10-dark " },
			{ name = "Rune 11 Dark",  atlas = "Rune-11-dark" },
		}
	},








	{
		name = "Mission List",
		category = "stamps",
		data = {
			{ name = "Hub",           atlas = "BfAMission-Icon-HUB" },
			{ name = "Normal",        atlas = "BfAMission-Icon-Normal" },
			{ name = "Quick Strike",  atlas = "BfAMission-Icon-QuickStrike" },
			{ name = "Stealth",       atlas = "BfAMission-Icon-Stealth" },
			{ name = "Long Campaing", atlas = "BfAMission-Icon-LongCampaign" },
			{ name = "Treasure",      atlas = "BfAMission-Icon-Treasure" },
			{ name = "Deep Sea",      atlas = "BfAMission-Icon-DeepSea" },
		}
	},

	{
		name = "Mission Landing",
		category = "art",
		data = {
			{ name = "Alliance", atlas = "BfAMissionsLandingPage-Background-Alliance" },
			{ name = "Horde",    atlas = "BfAMissionsLandingPage-Background-Horde" },
		}
	},

	{
		name = "Class Hall Icon",
		category = "misc",
		data = {
			{ name = "Treasure",  atlas = "ClassHall-TreasureIcon-Desaturated" },
			{ name = "Legendary", atlas = "ClassHall-LegendaryIcon-Desaturated" },
			{ name = "Quest",     atlas = "ClassHall-QuestIcon-Desaturated" },
			{ name = "Bonus",     atlas = "ClassHall-BonusIcon-Desaturated" },
			{ name = "Combat",    atlas = "ClassHall-CombatIcon-Desaturated" },
		}
	},

	{
		name = "Garrison Building Alliance (3D)",
		category = "garrison",
		data = {
			{ name = "Empty Plot 1",     atlas = "GarrBuilding_EmptyPlot_A_1" },
			{ name = "Empty Plot 2",     atlas = "GarrBuilding_EmptyPlot_A_2" },
			{ name = "Empty Plot 3",     atlas = "GarrBuilding_EmptyPlot_A_3" },
			{ name = "Alchemy 1",        atlas = "GarrBuilding_Alchemy_1_A_Info" },
			{ name = "Alchemy 2",        atlas = "GarrBuilding_Alchemy_2_A_Info" },
			{ name = "Alchemy 3",        atlas = "GarrBuilding_Alchemy_3_A_Info" },
			{ name = "Armory 1",         atlas = "GarrBuilding_Armory_1_A_Info" },
			{ name = "Armory 2",         atlas = "GarrBuilding_Armory_2_A_Info" },
			{ name = "Armory 3",         atlas = "GarrBuilding_Armory_3_A_Info" },
			{ name = "Barn 1",           atlas = "GarrBuilding_Barn_1_A_Info" },
			{ name = "Barn 2",           atlas = "GarrBuilding_Barn_2_A_Info" },
			{ name = "Barn 3",           atlas = "GarrBuilding_Barn_3_A_Info" },
			{ name = "Barracks 1",       atlas = "GarrBuilding_Barracks_1_A_Info" },
			{ name = "Barracks 2",       atlas = "GarrBuilding_Barracks_2_A_Info" },
			{ name = "Barracks 3",       atlas = "GarrBuilding_Barracks_3_A_Info" },
			{ name = "Blacksmith 1",     atlas = "GarrBuilding_Blacksmith_1_A_Info" },
			{ name = "Blacksmith 2",     atlas = "GarrBuilding_Blacksmith_2_A_Info" },
			{ name = "Blacksmith 3",     atlas = "GarrBuilding_Blacksmith_3_A_Info" },
			{ name = "Enchanting 1",     atlas = "GarrBuilding_Enchanting_1_A_Info" },
			{ name = "Enchanting 2",     atlas = "GarrBuilding_Enchanting_2_A_Info" },
			{ name = "Enchanting 3",     atlas = "GarrBuilding_Enchanting_3_A_Info" },
			{ name = "Engineering 1",    atlas = "GarrBuilding_Engineering_1_A_Info" },
			{ name = "Engineering 2",    atlas = "GarrBuilding_Engineering_2_A_Info" },
			{ name = "Engineering 3",    atlas = "GarrBuilding_Engineering_3_A_Info" },
			{ name = "Farm 1",           atlas = "GarrBuilding_Farm_1_A_Info" },
			{ name = "Farm 2",           atlas = "GarrBuilding_Farm_2_A_Info" },
			{ name = "Farm 3",           atlas = "GarrBuilding_Farm_3_A_Info" },
			{ name = "Fishing 1",        atlas = "GarrBuilding_Fishing_1_A_Info" },
			{ name = "Fishing 2",        atlas = "GarrBuilding_Fishing_2_A_Info" },
			{ name = "Fishing 3",        atlas = "GarrBuilding_Fishing_3_A_Info" },
			{ name = "Inn 1",            atlas = "GarrBuilding_Inn_1_A_Info" },
			{ name = "Inn 2",            atlas = "GarrBuilding_Inn_2_A_Info" },
			{ name = "Inn 3",            atlas = "GarrBuilding_Inn_3_A_Info" },
			{ name = "Inscription 1",    atlas = "GarrBuilding_Inscription_1_A_Info" },
			{ name = "Inscription 2",    atlas = "GarrBuilding_Inscription_2_A_Info" },
			{ name = "Inscription 3",    atlas = "GarrBuilding_Inscription_3_A_Info" },
			{ name = "Jewelcrafting 1",  atlas = "GarrBuilding_Jewelcrafting_1_A_Info" },
			{ name = "Jewelcrafting 2",  atlas = "GarrBuilding_Jewelcrafting_2_A_Info" },
			{ name = "Jewelcrafting 3",  atlas = "GarrBuilding_Jewelcrafting_3_A_Info" },
			{ name = "Leatherworking 1", atlas = "GarrBuilding_Leatherworking_1_A_Info" },
			{ name = "Leatherworking 2", atlas = "GarrBuilding_Leatherworking_2_A_Info" },
			{ name = "Leatherworking 3", atlas = "GarrBuilding_Leatherworking_3_A_Info" },
			{ name = "LumberMill 1",     atlas = "GarrBuilding_LumberMill_1_A_Info" },
			{ name = "LumberMill 2",     atlas = "GarrBuilding_LumberMill_2_A_Info" },
			{ name = "LumberMill 3",     atlas = "GarrBuilding_LumberMill_3_A_Info" },
			{ name = "MageTower 1",      atlas = "GarrBuilding_MageTower_1_A_Info" },
			{ name = "MageTower 2",      atlas = "GarrBuilding_MageTower_2_A_Info" },
			{ name = "MageTower 3",      atlas = "GarrBuilding_MageTower_3_A_Info" },
			{ name = "Mine 1",           atlas = "GarrBuilding_Mine_1_A_Info" },
			{ name = "PetStable 1",      atlas = "GarrBuilding_PetStable_1_A_Info" },
			{ name = "SalvageYard 1",    atlas = "GarrBuilding_SalvageYard_1_A_Info" },
			{ name = "SparringArena 1",  atlas = "GarrBuilding_SparringArena_1_A_Info" },
			{ name = "SparringArena 2",  atlas = "GarrBuilding_SparringArena_2_A_Info" },
			{ name = "SparringArena 3",  atlas = "GarrBuilding_SparringArena_3_A_Info" },
			{ name = "Stables 1",        atlas = "GarrBuilding_Stables_1_A_Info" },
			{ name = "Stables 2",        atlas = "GarrBuilding_Stables_2_A_Info" },
			{ name = "Stables 3",        atlas = "GarrBuilding_Stables_3_A_Info" },
			{ name = "Storehouse 1",     atlas = "GarrBuilding_Storehouse_1_A_Info" },
			{ name = "Tailoring 1",      atlas = "GarrBuilding_Tailoring_1_A_Info" },
			{ name = "Tailoring 2",      atlas = "GarrBuilding_Tailoring_2_A_Info" },
			{ name = "Tailoring 3",      atlas = "GarrBuilding_Tailoring_3_A_Info" },
			{ name = "TownHall 1",       atlas = "GarrBuilding_TownHall_1_A_Info" },
			{ name = "TownHall 2",       atlas = "GarrBuilding_TownHall_2_A_Info" },
			{ name = "TownHall 3",       atlas = "GarrBuilding_TownHall_3_A_Info" },
			{ name = "TradingPost 1",    atlas = "GarrBuilding_TradingPost_1_A_Info" },
			{ name = "TradingPost 2",    atlas = "GarrBuilding_TradingPost_2_A_Info" },
			{ name = "TradingPost 3",    atlas = "GarrBuilding_TradingPost_3_A_Info" },
			{ name = "Workshop 1",       atlas = "GarrBuilding_Workshop_1_A_Info" },
			{ name = "Workshop 2",       atlas = "GarrBuilding_Workshop_2_A_Info" },
			{ name = "Workshop 3",       atlas = "GarrBuilding_Workshop_3_A_Info" },
		}
	},

	{
		name = "Garrison Building Horde (3D)",
		category = "garrison",
		data = {
			{ name = "Empty Plot 1",     atlas = "GarrBuilding_EmptyPlot_H_1" },
			{ name = "Empty Plot 2",     atlas = "GarrBuilding_EmptyPlot_H_2" },
			{ name = "Empty Plot 3",     atlas = "GarrBuilding_EmptyPlot_H_3" },
			{ name = "Alchemy 1",        atlas = "GarrBuilding_Alchemy_1_H_Info" },
			{ name = "Alchemy 2",        atlas = "GarrBuilding_Alchemy_2_H_Info" },
			{ name = "Alchemy 3",        atlas = "GarrBuilding_Alchemy_3_H_Info" },
			{ name = "Armory 1",         atlas = "GarrBuilding_Armory_1_H_Info" },
			{ name = "Armory 2",         atlas = "GarrBuilding_Armory_2_H_Info" },
			{ name = "Armory 3",         atlas = "GarrBuilding_Armory_3_H_Info" },
			{ name = "Barn 1",           atlas = "GarrBuilding_Barn_1_H_Info" },
			{ name = "Barn 2",           atlas = "GarrBuilding_Barn_2_H_Info" },
			{ name = "Barn 3",           atlas = "GarrBuilding_Barn_3_H_Info" },
			{ name = "Barracks 1",       atlas = "GarrBuilding_Barracks_1_H_Info" },
			{ name = "Barracks 2",       atlas = "GarrBuilding_Barracks_2_H_Info" },
			{ name = "Barracks 3",       atlas = "GarrBuilding_Barracks_3_H_Info" },
			{ name = "Blacksmith 1",     atlas = "GarrBuilding_Blacksmith_1_H_Info" },
			{ name = "Blacksmith 2",     atlas = "GarrBuilding_Blacksmith_2_H_Info" },
			{ name = "Blacksmith 3",     atlas = "GarrBuilding_Blacksmith_3_H_Info" },
			{ name = "Enchanting 1",     atlas = "GarrBuilding_Enchanting_1_H_Info" },
			{ name = "Enchanting 2",     atlas = "GarrBuilding_Enchanting_2_H_Info" },
			{ name = "Enchanting 3",     atlas = "GarrBuilding_Enchanting_3_H_Info" },
			{ name = "Engineering 1",    atlas = "GarrBuilding_Engineering_1_H_Info" },
			{ name = "Engineering 2",    atlas = "GarrBuilding_Engineering_2_H_Info" },
			{ name = "Engineering 3",    atlas = "GarrBuilding_Engineering_3_H_Info" },
			{ name = "Farm 1",           atlas = "GarrBuilding_Farm_1_H_Info" },
			{ name = "Fishing 1",        atlas = "GarrBuilding_Fishing_1_H_Info" },
			{ name = "Fishing 2",        atlas = "GarrBuilding_Fishing_2_H_Info" },
			{ name = "Fishing 3",        atlas = "GarrBuilding_Fishing_3_H_Info" },
			{ name = "Inn 1",            atlas = "GarrBuilding_Inn_1_H_Info" },
			{ name = "Inn 2",            atlas = "GarrBuilding_Inn_2_H_Info" },
			{ name = "Inn 3",            atlas = "GarrBuilding_Inn_3_H_Info" },
			{ name = "Inscription 1",    atlas = "GarrBuilding_Inscription_1_H_Info" },
			{ name = "Inscription 2",    atlas = "GarrBuilding_Inscription_2_H_Info" },
			{ name = "Inscription 3",    atlas = "GarrBuilding_Inscription_3_H_Info" },
			{ name = "Jewelcrafting 1",  atlas = "GarrBuilding_Jewelcrafting_1_H_Info" },
			{ name = "Jewelcrafting 2",  atlas = "GarrBuilding_Jewelcrafting_2_H_Info" },
			{ name = "Jewelcrafting 3",  atlas = "GarrBuilding_Jewelcrafting_3_H_Info" },
			{ name = "Leatherworking 1", atlas = "GarrBuilding_Leatherworking_1_H_Info" },
			{ name = "Leatherworking 2", atlas = "GarrBuilding_Leatherworking_2_H_Info" },
			{ name = "Leatherworking 3", atlas = "GarrBuilding_Leatherworking_3_H_Info" },
			{ name = "LumberMill 1",     atlas = "GarrBuilding_LumberMill_1_H_Info" },
			{ name = "LumberMill 2",     atlas = "GarrBuilding_LumberMill_2_H_Info" },
			{ name = "LumberMill 3",     atlas = "GarrBuilding_LumberMill_3_H_Info" },
			{ name = "MageTower 1",      atlas = "GarrBuilding_MageTower_1_H_Info" },
			{ name = "MageTower 2",      atlas = "GarrBuilding_MageTower_2_H_Info" },
			{ name = "MageTower 3",      atlas = "GarrBuilding_MageTower_3_H_Info" },
			{ name = "Mine 1",           atlas = "GarrBuilding_Mine_1_H_Info" },
			{ name = "PetStable 1",      atlas = "GarrBuilding_PetStable_1_H_Info" },
			{ name = "SalvageYard 1",    atlas = "GarrBuilding_SalvageYard_1_H_Info" },
			{ name = "SparringArena 1",  atlas = "GarrBuilding_SparringArena_1_H_Info" },
			{ name = "SparringArena 2",  atlas = "GarrBuilding_SparringArena_2_H_Info" },
			{ name = "SparringArena 3",  atlas = "GarrBuilding_SparringArena_3_H_Info" },
			{ name = "Stables 1",        atlas = "GarrBuilding_Stables_1_H_Info" },
			{ name = "Stables 2",        atlas = "GarrBuilding_Stables_2_H_Info" },
			{ name = "Stables 3",        atlas = "GarrBuilding_Stables_3_H_Info" },
			{ name = "Storehouse 1",     atlas = "GarrBuilding_Storehouse_1_H_Info" },
			{ name = "Tailoring 1",      atlas = "GarrBuilding_Tailoring_1_H_Info" },
			{ name = "Tailoring 2",      atlas = "GarrBuilding_Tailoring_2_H_Info" },
			{ name = "Tailoring 3",      atlas = "GarrBuilding_Tailoring_3_H_Info" },
			{ name = "TownHall 1",       atlas = "GarrBuilding_TownHall_1_H_Info" },
			{ name = "TownHall 2",       atlas = "GarrBuilding_TownHall_2_H_Info" },
			{ name = "TownHall 3",       atlas = "GarrBuilding_TownHall_3_H_Info" },
			{ name = "TradingPost 1",    atlas = "GarrBuilding_TradingPost_1_H_Info" },
			{ name = "TradingPost 2",    atlas = "GarrBuilding_TradingPost_2_H_Info" },
			{ name = "TradingPost 3",    atlas = "GarrBuilding_TradingPost_3_H_Info" },
			{ name = "Workshop 1",       atlas = "GarrBuilding_Workshop_1_H_Info" },
			{ name = "Workshop 2",       atlas = "GarrBuilding_Workshop_2_H_Info" },
			{ name = "Workshop 3",       atlas = "GarrBuilding_Workshop_3_H_Info" },
		}
	},

	{
		name = "Garrison Watermark",
		category = "misc",
		data = {
			{ name = "Tradeskill", atlas = "GarrLanding_Watermark-Tradeskill" },
		}
	},

	{
		name = "Garrison Mission Watermark",
		category = "art",
		data = {
			{ name = "Blacksmithing",   atlas = "GarrMission_MissionIcon-Blacksmithing" },
			{ name = "Combat",          atlas = "GarrMission_MissionIcon-Combat" },
			{ name = "Exploration",     atlas = "GarrMission_MissionIcon-Exploration" },
			{ name = "Enchanting",      atlas = "GarrMission_MissionIcon-Enchanting" },
			{ name = "Salvage",         atlas = "GarrMission_MissionIcon-Salvage" },
			{ name = "Provision",       atlas = "GarrMission_MissionIcon-Provision" },
			{ name = "Generic",         atlas = "GarrMission_MissionIcon-Generic" },
			{ name = "Siege",           atlas = "GarrMission_MissionIcon-Siege" },
			{ name = "Alchemy",         atlas = "GarrMission_MissionIcon-Alchemy" },
			{ name = "Wildlife",        atlas = "GarrMission_MissionIcon-Wildlife" },
			{ name = "Tailoring",       atlas = "GarrMission_MissionIcon-Tailoring" },
			{ name = "Training",        atlas = "GarrMission_MissionIcon-Training" },
			{ name = "Trading",         atlas = "GarrMission_MissionIcon-Trading" },
			{ name = "Jewelcrafting",   atlas = "GarrMission_MissionIcon-Jewelcrafting" },
			{ name = "Defense",         atlas = "GarrMission_MissionIcon-Defense" },
			{ name = "Construction",    atlas = "GarrMission_MissionIcon-Construction" },
			{ name = "Inscription",     atlas = "GarrMission_MissionIcon-Inscription" },
			{ name = "Logistics",       atlas = "GarrMission_MissionIcon-Logistics" },
			{ name = "Engineering",     atlas = "GarrMission_MissionIcon-Engineering" },
			{ name = "Patrol",          atlas = "GarrMission_MissionIcon-Patrol" },
			{ name = "Recruit",         atlas = "GarrMission_MissionIcon-Recruit" },
			{ name = "Leatherworking",  atlas = "GarrMission_MissionIcon-Leatherworking" },
			{ name = "Ship Combat",     atlas = "ShipMissionIcon-Combat-Mission" },
			{ name = "Oil",             atlas = "ShipMissionIcon-Oil-Mission" },
			{ name = "Ship Siege (A)",  atlas = "ShipMissionIcon-SiegeA-Mission" },
			{ name = "Ship Siege (H)",  atlas = "ShipMissionIcon-SiegeH-Mission" },
			{ name = "Ship Training",   atlas = "ShipMissionIcon-Training-Mission" },
			{ name = "Ship Treasure",   atlas = "ShipMissionIcon-Treasure-Mission" },
			{ name = "Ship Bonus",      atlas = "ShipMissionIcon-Bonus-Mission" },
			{ name = "Ship Legendary",  atlas = "ShipMissionIcon-Legendary-Mission" },
			{ name = "Ship Siege (IH)", atlas = "ShipMissionIcon-SiegeIHA-Mission" },
		}
	},

	{
		name = "Horde Garrison (Tier 1)",
		category = "garrison",
		data = {
			{ name = "Arena 1",      atlas = "Horde_Tier1_Arena1" },
			{ name = "Arena 2",      atlas = "Horde_Tier1_Arena2" },
			{ name = "Armory 1",     atlas = "Horde_Tier1_Armory1" },
			{ name = "Armory 2",     atlas = "Horde_Tier1_Armory2" },
			{ name = "Barn 1",       atlas = "Horde_Tier1_Barn1" },
			{ name = "Barn 2",       atlas = "Horde_Tier1_Barn2" },
			{ name = "Barracks 1",   atlas = "Horde_Tier1_Barracks1" },
			{ name = "Barracks 2",   atlas = "Horde_Tier1_Barracks2" },
			{ name = "Farm 1",       atlas = "Horde_Tier1_Farm1" },
			{ name = "Fishing 1",    atlas = "Horde_Tier1_Fishing1" },
			{ name = "Inn 1",        atlas = "Horde_Tier1_Inn1" },
			{ name = "Inn 2",        atlas = "Horde_Tier1_Inn2" },
			{ name = "Lumber 1",     atlas = "Horde_Tier1_Lumber1" },
			{ name = "Lumber 2",     atlas = "Horde_Tier1_Lumber2" },
			{ name = "Mage 1",       atlas = "Horde_Tier1_Mage1" },
			{ name = "Mage 2",       atlas = "Horde_Tier1_Mage2" },
			{ name = "Mine 1",       atlas = "Horde_Tier1_Mine1" },
			{ name = "Profession 1", atlas = "Horde_Tier1_Profession1" },
			{ name = "Profession 2", atlas = "Horde_Tier1_Profession2" },
			{ name = "Profession 3", atlas = "Horde_Tier1_Profession3" },
			{ name = "Stables 1",    atlas = "Horde_Tier1_Stables1" },
			{ name = "Stables 2",    atlas = "Horde_Tier1_Stables2" },
			{ name = "Trading 1",    atlas = "Horde_Tier1_Trading1" },
			{ name = "Trading 2",    atlas = "Horde_Tier1_Trading2" },
			{ name = "Workshop 1",   atlas = "Horde_Tier1_Workshop1" },
			{ name = "Workshop 2",   atlas = "Horde_Tier1_Workshop2" },
		}
	},

	{
		name = "Horde Garrison (Tier 2)",
		category = "garrison",
		data = {
			{ name = "Arena 1",    atlas = "Horde_Tier2_Arena1" },
			{ name = "Arena 2",    atlas = "Horde_Tier2_Arena2" },
			{ name = "Armory 1",   atlas = "Horde_Tier2_Armory1" },
			{ name = "Armory 2",   atlas = "Horde_Tier2_Armory2" },
			{ name = "Barn 1",     atlas = "Horde_Tier2_Barn1" },
			{ name = "Barn 2",     atlas = "Horde_Tier2_Barn2" },
			{ name = "Barracks 1", atlas = "Horde_Tier2_Barracks1" },
			{ name = "Barracks 2", atlas = "Horde_Tier2_Barracks2" },
			{ name = "Inn 1",      atlas = "Horde_Tier2_Inn1" },
			{ name = "Inn 2",      atlas = "Horde_Tier2_Inn2" },
			{ name = "Lumber 1",   atlas = "Horde_Tier2_Lumber1" },
			{ name = "Lumber 2",   atlas = "Horde_Tier2_Lumber2" },
			{ name = "Mage 1",     atlas = "Horde_Tier2_Mage1" },
			{ name = "Mage 2",     atlas = "Horde_Tier2_Mage2" },
			{ name = "Stables 1",  atlas = "Horde_Tier2_Stables1" },
			{ name = "Stables 2",  atlas = "Horde_Tier2_Stables2" },
			{ name = "Trading 1",  atlas = "Horde_Tier2_Trading1" },
			{ name = "Trading 2",  atlas = "Horde_Tier2_Trading2" },
			{ name = "Workshop 1", atlas = "Horde_Tier2_Workshop1" },
			{ name = "Workshop 2", atlas = "Horde_Tier2_Workshop2" },
		}
	},

	{
		name = "Horde Garrison (Tier 3)",
		category = "garrison",
		data = {
			{ name = "Arena 1",    atlas = "Horde_Tier3_Arena1" },
			{ name = "Arena 2",    atlas = "Horde_Tier3_Arena2" },
			{ name = "Armory 1",   atlas = "Horde_Tier3_Armory1" },
			{ name = "Armory 2",   atlas = "Horde_Tier3_Armory2" },
			{ name = "Barn 1",     atlas = "Horde_Tier3_Barn1" },
			{ name = "Barn 2",     atlas = "Horde_Tier3_Barn2" },
			{ name = "Barracks 1", atlas = "Horde_Tier3_Barracks1" },
			{ name = "Barracks 2", atlas = "Horde_Tier3_Barracks2" },
			{ name = "Inn 1",      atlas = "Horde_Tier3_Inn1" },
			{ name = "Inn 2",      atlas = "Horde_Tier3_Inn2" },
			{ name = "Lumber 1",   atlas = "Horde_Tier3_Lumber1" },
			{ name = "Lumber 2",   atlas = "Horde_Tier3_Lumber2" },
			{ name = "Mage 1",     atlas = "Horde_Tier3_Mage1" },
			{ name = "Mage 2",     atlas = "Horde_Tier3_Mage2" },
			{ name = "Stables 1",  atlas = "Horde_Tier3_Stables1" },
			{ name = "Stables 2",  atlas = "Horde_Tier3_Stables2" },
			{ name = "Trading 1",  atlas = "Horde_Tier3_Trading1" },
			{ name = "Trading 2",  atlas = "Horde_Tier3_Trading2" },
			{ name = "Workshop 1", atlas = "Horde_Tier3_Workshop1" },
			{ name = "Workshop 2", atlas = "Horde_Tier3_Workshop2" },
		}
	},

	{
		name = "Progenitor Symbols",
		category = "text",
		data = {
			{ name = "1",  atlas = "proglan-1" },
			{ name = "2",  atlas = "proglan-2" },
			{ name = "3",  atlas = "proglan-3" },
			{ name = "4",  atlas = "proglan-4" },
			{ name = "5",  atlas = "proglan-5" },
			{ name = "6",  atlas = "proglan-6" },
			{ name = "7",  atlas = "proglan-7" },
			{ name = "8",  atlas = "proglan-8" },
			{ name = "9",  atlas = "proglan-9" },
			{ name = "10", atlas = "proglan-10" },
			{ name = "11", atlas = "proglan-11" },
			{ name = "12", atlas = "proglan-12" },
			{ name = "13", atlas = "proglan-13" },
			{ name = "14", atlas = "proglan-14" },
			{ name = "15", atlas = "proglan-15" },
			{ name = "16", atlas = "proglan-16" },
			{ name = "17", atlas = "proglan-17" },
			{ name = "18", atlas = "proglan-18" },
			{ name = "19", atlas = "proglan-19" },
			{ name = "20", atlas = "proglan-20" },
			{ name = "21", atlas = "proglan-21" },
			{ name = "22", atlas = "proglan-22" },
			{ name = "23", atlas = "proglan-23" },
			{ name = "24", atlas = "proglan-24" },
			{ name = "25", atlas = "proglan-25" },
			{ name = "26", atlas = "proglan-26" },
			{ name = "27", atlas = "proglan-27" },
			{ name = "28", atlas = "proglan-28" },
			{ name = "29", atlas = "proglan-29" },
			{ name = "30", atlas = "proglan-30" },
			{ name = "31", atlas = "proglan-31" },
			{ name = "32", atlas = "proglan-32" },
			{ name = "33", atlas = "proglan-33" },
			{ name = "34", atlas = "proglan-34" },
			{ name = "35", atlas = "proglan-35" },
			{ name = "36", atlas = "proglan-36" },
		}
	},

	{
		name = "Progenitor Symbols (Tint)",
		category = "text",
		data = {
			{ name = "1",  atlas = "proglan-w-1" },
			{ name = "2",  atlas = "proglan-w-2" },
			{ name = "3",  atlas = "proglan-w-3" },
			{ name = "4",  atlas = "proglan-w-4" },
			{ name = "5",  atlas = "proglan-w-5" },
			{ name = "6",  atlas = "proglan-w-6" },
			{ name = "7",  atlas = "proglan-w-7" },
			{ name = "8",  atlas = "proglan-w-8" },
			{ name = "9",  atlas = "proglan-w-9" },
			{ name = "10", atlas = "proglan-w-10" },
			{ name = "11", atlas = "proglan-w-11" },
			{ name = "12", atlas = "proglan-w-12" },
			{ name = "13", atlas = "proglan-w-13" },
			{ name = "14", atlas = "proglan-w-14" },
			{ name = "15", atlas = "proglan-w-15" },
			{ name = "16", atlas = "proglan-w-16" },
			{ name = "17", atlas = "proglan-w-17" },
			{ name = "18", atlas = "proglan-w-18" },
			{ name = "19", atlas = "proglan-w-19" },
			{ name = "20", atlas = "proglan-w-20" },
			{ name = "21", atlas = "proglan-w-21" },
			{ name = "22", atlas = "proglan-w-22" },
			{ name = "23", atlas = "proglan-w-23" },
			{ name = "24", atlas = "proglan-w-24" },
			{ name = "25", atlas = "proglan-w-25" },
			{ name = "26", atlas = "proglan-w-26" },
			{ name = "27", atlas = "proglan-w-27" },
			{ name = "28", atlas = "proglan-w-28" },
			{ name = "29", atlas = "proglan-w-29" },
			{ name = "30", atlas = "proglan-w-30" },
			{ name = "31", atlas = "proglan-w-31" },
			{ name = "32", atlas = "proglan-w-32" },
			{ name = "33", atlas = "proglan-w-33" },
			{ name = "34", atlas = "proglan-w-34" },
			{ name = "35", atlas = "proglan-w-35" },
			{ name = "36", atlas = "proglan-w-36" },
		}
	},

	{
		name = "Island Art - Crestfall",
		category = "art",
		data = {
			{ name = "Dragon",  atlas = "islands-queue-card-crestfall-dragon" },
			{ name = "Orc",     atlas = "islands-queue-card-crestfall-orc" },
			{ name = "Pirates", atlas = "islands-queue-card-crestfall-pirates" },

		}
	},

	{
		name = "Island Art - Dread Chain",
		category = "art",
		data = {
			{ name = "Ice Troll", atlas = "islands-queue-card-dreadchain-icetroll" },
			{ name = "Kvaldir",   atlas = "islands-queue-card-dreadchain-kvaldir" },
			{ name = "Mogu",      atlas = "islands-queue-card-dreadchain-mogu" },

		}
	},

	{
		name = "Island Art - Havenswood",
		category = "art",
		data = {
			{ name = "Cultist",  atlas = "islands-queue-card-havenswood-cultist" },
			{ name = "Faceless", atlas = "islands-queue-card-havenswood-faceless" },
			{ name = "Worgen",   atlas = "islands-queue-card-havenswood-worgen" },

		}
	},

	{
		name = "Island Art - Jorundall",
		category = "art",
		data = {
			{ name = "Taunka", atlas = "islands-queue-card-jorundall-taunka" },
			{ name = "Vargul", atlas = "islands-queue-card-jorundall-vargul" },
			{ name = "Vrykul", atlas = "islands-queue-card-jorundall-vrykul" },

		}
	},

	{
		name = "Island Art - Molten Cay",
		category = "art",
		data = {
			{ name = "Jungle Troll", atlas = "islands-queue-card-moltencay-jungletroll" },
			{ name = "Ogre",         atlas = "islands-queue-card-moltencay-ogre" },
			{ name = "Sand Troll",   atlas = "islands-queue-card-moltencay-sandtroll" },
			{ name = "Yaungol",      atlas = "islands-queue-card-moltencay-yaungol" },

		}
	},

	{
		name = "Island Art - Rotting Mire",
		category = "art",
		data = {
			{ name = "Jinyu",   atlas = "islands-queue-card-rottingmire-jinyu" },
			{ name = "Saurok",  atlas = "islands-queue-card-rottingmire-saurok" },
			{ name = "Pirates", atlas = "islands-queue-card-rottingmire-strandedpirates" },

		}
	},

	{
		name = "Island Art - Skittering Hollow",
		category = "art",
		data = {
			{ name = "Kobolds",   atlas = "islands-queue-card-skitteringhollow-kobolds" },
			{ name = "Nerubians", atlas = "islands-queue-card-skitteringhollow-nerubians" },
			{ name = "Troggs",    atlas = "islands-queue-card-skitteringhollow-troggs" },

		}
	},

	{
		name = "Island Art - Snowblossom",
		category = "art",
		data = {
			{ name = "Mantid", atlas = "islands-queue-card-snowblossom-mantid" },
			{ name = "Mogu",   atlas = "islands-queue-card-snowblossom-mogu" },
			{ name = "Vermin", atlas = "islands-queue-card-snowblossom-vermin" },

		}
	},

	{
		name = "Island Art - Ungol Ruins",
		category = "art",
		data = {
			{ name = "Hozen",    atlas = "islands-queue-card-ungolruins-hozen" },
			{ name = "Pygmy",    atlas = "islands-queue-card-ungolruins-pygmy" },
			{ name = "Quilboar", atlas = "islands-queue-card-ungolruins-quilboar" },

		}
	},

	{
		name = "Island Art - Verdant Wilds",
		category = "art",
		data = {
			{ name = "Druids",   atlas = "islands-queue-card-verdantwilds-druids" },
			{ name = "Furbolgs", atlas = "islands-queue-card-verdantwilds-furbolgs" },
			{ name = "Keepers",  atlas = "islands-queue-card-verdantwilds-keepers" },

		}
	},

	{
		name = "Island Art - Whispering Reef",
		category = "art",
		data = {
			{ name = "Makrura", atlas = "islands-queue-card-whisperingreef-makrura" },
			{ name = "Murlocs", atlas = "islands-queue-card-whisperingreef-murlocs" },
			{ name = "Naga",    atlas = "islands-queue-card-whisperingreef-naga" },

		}
	},

	{
		name = "Faction Icon (Faded)",
		category = "art",
		data = {
			{ name = "Alliance", atlas = "MountJournalIcons-Alliance" },
			{ name = "Horde",    atlas = "MountJournalIcons-Horde" },
		}
	},

	{
		name = "Class Watermark",
		category = "art",
		data = {
			{ name = "Death Knight", atlas = "legionmission-landingpage-background-deathknight" },
			{ name = "Demon Hunter", atlas = "legionmission-landingpage-background-demonhunter" },
			{ name = "Druid",        atlas = "legionmission-landingpage-background-druid" },
			{ name = "Hunter",       atlas = "legionmission-landingpage-background-hunter" },
			{ name = "Mage",         atlas = "legionmission-landingpage-background-mage" },
			{ name = "Monk",         atlas = "legionmission-landingpage-background-monk" },
			{ name = "Paladin",      atlas = "legionmission-landingpage-background-paladin" },
			{ name = "Priest",       atlas = "legionmission-landingpage-background-priest" },
			{ name = "Rogue",        atlas = "legionmission-landingpage-background-rogue" },
			{ name = "Shaman",       atlas = "legionmission-landingpage-background-shaman" },
			{ name = "Warlock",      atlas = "legionmission-landingpage-background-warlock" },
			{ name = "Warrior",      atlas = "legionmission-landingpage-background-warrior" },
		}
	},

	{
		name = "Wax Seal",
		category = "stamps",
		data = {
			{ name = "Alliance",   atlas = "Quest-Alliance-WaxSeal" },
			{ name = "Horde",      atlas = "Quest-Horde-WaxSeal" },
			{ name = "Legionfall", atlas = "Quest-Legionfall-WaxSeal" },
		}
	},

	{
		name = "Shadowlands Faction Lineart",
		category = "art",
		data = {
			{ name = "Kyrian",    atlas = "ShadowlandsMissionsLandingPage-Background-Kyrian" },
			{ name = "Necrolord", atlas = "ShadowlandsMissionsLandingPage-Background-Necrolord" },
			{ name = "Night Fae", atlas = "ShadowlandsMissionsLandingPage-Background-NightFae" },
			{ name = "Venthyr",   atlas = "ShadowlandsMissionsLandingPage-Background-Venthyr" },
		}
	},

	{
		name = "Garrison Ship",
		category = "misc",
		data = {
			{ name = "Cargo",           atlas = "Ships_CargoShip-Map" },
			{ name = "Carrier (A)",     atlas = "Ships_CarrierA-Map" },
			{ name = "Carrier (H)",     atlas = "Ships_CarrierH-Map" },
			{ name = "Carrier",         atlas = "Ships_Carrier-Map" },
			{ name = "Dreadnaught (A)", atlas = "Ships_DreadnaughtA-Map" },
			{ name = "Dreadnaught (H)", atlas = "Ships_DreadnaughtH-Map" },
			{ name = "Dreadnaught",     atlas = "Ships_Dreadnaught-Map" },
			{ name = "Galleon (A)",     atlas = "Ships_GalleonA-Map" },
			{ name = "Galleon (H)",     atlas = "Ships_GalleonH-Map" },
			{ name = "Submarine (A)",   atlas = "Ships_SubmarineA-Map" },
			{ name = "Submarine (H)",   atlas = "Ships_SubmarineH-Map" },
			{ name = "Troop Transport", atlas = "Ships_TroopTransport-Map" },
		}
	},

	{
		name = "Banner",
		category = "textart",
		data = {
			{ name = "1",                        atlas = "GarrMission_RewardsBanner" },
			{ name = "1 (Desat)",                atlas = "GarrMission_RewardsBanner-Desaturate" },
			{ name = "Island",                   atlas = "islands-queue-card-namescroll" },
			{ name = "Ribbon - Neutral",         atlas = "UI-Frame-Neutral-Ribbon" },
			{ name = "Ribbon - Alliance",        atlas = "UI-Frame-Alliance-Ribbon" },
			{ name = "Ribbon - Horde",           atlas = "UI-Frame-Horde-Ribbon" },
			{ name = "Ribbon - Kyrian",          atlas = "UI-Frame-Kyrian-Ribbon" },
			{ name = "Ribbon - Marine",          atlas = "UI-Frame-Marine-Ribbon" },
			{ name = "Ribbon - Mechagon",        atlas = "UI-Frame-Mechagon-Ribbon" },
			{ name = "Ribbon - Necrolord",       atlas = "UI-Frame-Necrolord-Ribbon" },
			{ name = "Ribbon - Night Fae",       atlas = "UI-Frame-NightFae-Ribbon" },
			{ name = "Ribbon - Venthyr",         atlas = "UI-Frame-Venthyr-Ribbon" },
			{ name = "Ribbon - Legionfall",      atlas = "Legionfall_Banner" },
			{ name = "Ribbon - Legionfall Grey", atlas = "Legionfall_GrayBanner" },
			{ name = "Subtitle - Horde",         atlas = "UI-Frame-Horde-Subtitle" },
			{ name = "Subtitle - Alliance",      atlas = "UI-Frame-Alliance-Subtitle" },
			{ name = "Subtitle - Kyrian",        atlas = "UI-Frame-Kyrian-Subtitle" },
			{ name = "Subtitle - Marine",        atlas = "UI-Frame-Marine-Subtitle" },
			{ name = "Subtitle - Mechagon",      atlas = "UI-Frame-Mechagon-Subtitle" },
			{ name = "Subtitle - Necrolord",     atlas = "UI-Frame-Necrolord-Subtitle" },
			{ name = "Subtitle - Night Fae",     atlas = "UI-Frame-NightFae-Subtitle" },
			{ name = "Subtitle - Venthyr",       atlas = "UI-Frame-Venthyr-Subtitle" },
			{ name = "Subtitle - Garrison",      atlas = "GarrMission_LevelUpBanner" },
			{ name = "Parchment 1 (L)",          atlas = "Adventures-Parchment-Tile-Left" },
			{ name = "Parchment 1 (C)",          atlas = "_Adventures-Parchment-Tile-Mid" },
			{ name = "Parchment 1 (R)",          atlas = "Adventures-Parchment-Tile-Right" },
			{ name = "Parchment A (L)",          atlas = "AllianceFrame_Title-End-2" },
			{ name = "Parchment A (C)",          atlas = "_AllianceFrame_Title-Tile" },
			{ name = "Parchment A (R)",          atlas = "AllianceFrame_Title-End" },
			{ name = "Parchment H (L)",          atlas = "HordeFrame_Title-End-2" },
			{ name = "Parchment H (C)",          atlas = "_HordeFrame_Title-Tile" },
			{ name = "Parchment H (R)",          atlas = "HordeFrame_Title-End" },
			{ name = "Title - Alliance (L)",     atlas = "UI-Frame-Alliance-TitleLeft" },
			{ name = "Title - Alliance (C)",     atlas = "_UI-Frame-Alliance-TitleMiddle" },
			{ name = "Title - Alliance (R)",     atlas = "UI-Frame-Alliance-TitleRight" },
			{ name = "Title - Horde (L)",        atlas = "UI-Frame-Horde-TitleLeft" },
			{ name = "Title - Horde (C)",        atlas = "_UI-Frame-Horde-TitleMiddle" },
			{ name = "Title - Horde (R)",        atlas = "UI-Frame-Horde-TitleRight" },
			{ name = "Title - Kyrian (L)",       atlas = "UI-Frame-Kyrian-TitleLeft" },
			{ name = "Title - Kyrian (C)",       atlas = "_UI-Frame-Kyrian-TitleMiddle" },
			{ name = "Title - Kyrian (R)",       atlas = "UI-Frame-Kyrian-TitleRight" },
			{ name = "Title - Marine (L)",       atlas = "UI-Frame-Marine-TitleLeft" },
			{ name = "Title - Marine (C)",       atlas = "_UI-Frame-Marine-TitleMiddle" },
			{ name = "Title - Marine (R)",       atlas = "UI-Frame-Marine-TitleRight" },
			{ name = "Title - Mechagon (L)",     atlas = "UI-Frame-Mechagon-TitleLeft" },
			{ name = "Title - Mechagon (C)",     atlas = "_UI-Frame-Mechagon-TitleMiddle" },
			{ name = "Title - Mechagon (R)",     atlas = "UI-Frame-Mechagon-TitleRight" },
			{ name = "Title - Necrolord (L)",    atlas = "UI-Frame-Necrolord-TitleLeft" },
			{ name = "Title - Necrolord (C)",    atlas = "_UI-Frame-Necrolord-TitleMiddle" },
			{ name = "Title - Necrolord (R)",    atlas = "UI-Frame-Necrolord-TitleRight" },
			{ name = "Title - Neutral (L)",      atlas = "UI-Frame-Neutral-TitleLeft" },
			{ name = "Title - Neutral (C)",      atlas = "_UI-Frame-Neutral-TitleMiddle" },
			{ name = "Title - Neutral (R)",      atlas = "UI-Frame-Neutral-TitleRight" },
			{ name = "Title - Night Fae (L)",    atlas = "UI-Frame-NightFae-TitleLeft" },
			{ name = "Title - Night Fae (C)",    atlas = "_UI-Frame-NightFae-TitleMiddle" },
			{ name = "Title - Night Fae (R)",    atlas = "UI-Frame-NightFae-TitleRight" },
			{ name = "Title - Venthyr (L)",      atlas = "UI-Frame-Venthyr-TitleLeft" },
			{ name = "Title - Venthyr (C)",      atlas = "_UI-Frame-Venthyr-TitleMiddle" },
			{ name = "Title - Venthyr (R)",      atlas = "UI-Frame-Venthyr-TitleRight" },
		}
	},
}


local function buildBlizzAtlasDefinitions()
	for _, group in ipairs(blizzAtlasDefinitions) do
		for _, item in ipairs(group.data) do
			local itemFullName = ("%s - %s"):format(group.name, item.name)
			local atlasInfo = C_Texture.GetAtlasInfo(item.atlas)

			MTM:RegisterDefinition({
				id = item.atlas,
				name = itemFullName,
				catID = group.category,
				atlas = item.atlas,
				width = atlasInfo.width,
				height = atlasInfo.height,
			})
		end
	end
end


-- Epsilon Sprites
do
	MTM:RegisterDefinition({ id = "dwarven_mountainside_entrance", name = "Dwarven Mountainside Entrance", catID = "arch_major", file = t("Architecture\\MapArchitecture"), texCoords = tcCR(1, 1, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "titanic_overlook_entrance_left", name = "Titanic Overlook Entrance Left", catID = "arch_major", file = t("Architecture\\MapArchitecture"), texCoords = tcCR(2, 1, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })

	MTM:RegisterDefinition({ id = "tomb_entrance_left", name = "Tomb Entrance Left", catID = "arch_major", file = t("Architecture\\MapArchitecture"), texCoords = tcCR(4, 1, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })

	MTM:RegisterDefinition({ id = "cave_entrance_left", name = "Cave Entrance Left", catID = "arch_major", file = t("Architecture\\MapArchitecture"), texCoords = tcCR(6, 1, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })

	MTM:RegisterDefinition({ id = "greymane_manor", name = "Greymane Manor", catID = "arch_major", file = t("Architecture\\MapArchitecture"), texCoords = tcCR(8, 1, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "emerald_tree_trunk_1", name = "Emerald Tree Trunk 1", catID = "foliage", file = t("Architecture\\MapArchitecture"), texCoords = tcCR(1, 2, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "emerald_tree_trunk_2", name = "Emerald Tree Trunk 2", catID = "foliage", file = t("Architecture\\MapArchitecture"), texCoords = tcCR(2, 2, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "emerald_tree_trunk_3", name = "Emerald Tree Trunk 3", catID = "foliage", file = t("Architecture\\MapArchitecture"), texCoords = tcCR(3, 2, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "emerald_tree_1", name = "Emerald Tree 1", catID = "foliage", file = t("Architecture\\MapArchitecture"), texCoords = tcCR(4, 2, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "emerald_tree_2", name = "Emerald Tree 2", catID = "foliage", file = t("Architecture\\MapArchitecture"), texCoords = tcCR(5, 2, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "emerald_tree_3", name = "Emerald Tree 3", catID = "foliage", file = t("Architecture\\MapArchitecture"), texCoords = tcCR(6, 2, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "emerald_tree_4", name = "Emerald Tree 4", catID = "foliage", file = t("Architecture\\MapArchitecture"), texCoords = tcCR(7, 2, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "wooden_bridge", name = "Wooden Bridge", catID = "roads", file = t("Architecture\\MapArchitecture"), texCoords = tcCR(8, 2, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "world_root_portal", name = "World Root Portal", catID = "arch_major", file = t("Architecture\\MapArchitecture"), texCoords = tcCR(1, 3, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "world_root_1", name = "World Root 1", catID = "foliage", file = t("Architecture\\MapArchitecture"), texCoords = tcCR(2, 3, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "world_root_2", name = "World Root 2", catID = "foliage", file = t("Architecture\\MapArchitecture"), texCoords = tcCR(3, 3, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "world_root_3", name = "World Root 3", catID = "foliage", file = t("Architecture\\MapArchitecture"), texCoords = tcCR(4, 3, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "world_root_4", name = "World Root 4", catID = "foliage", file = t("Architecture\\MapArchitecture"), texCoords = tcCR(5, 3, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "world_root_5", name = "World Root 5", catID = "foliage", file = t("Architecture\\MapArchitecture"), texCoords = tcCR(6, 3, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "the_stonecore", name = "The Stonecore", catID = "arch_major", file = t("Architecture\\MapArchitecture"), texCoords = tcCR(7, 3, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "bronze_dragon_hourglass", name = "Bronze Dragon Hourglass", catID = "arch_major", file = t("Architecture\\MapArchitecture"), texCoords = tcCR(8, 3, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "draconic_round_tower", name = "Draconic Round Tower", catID = "arch_major", file = t("Architecture\\MapArchitecture"), texCoords = tcCR(1, 4, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "draconic_wall_post", name = "Draconic Wall Post", catID = "arch_major", file = t("Architecture\\MapArchitecture"), texCoords = tcCR(2, 4, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "draconic_ledge", name = "Draconic Ledge", catID = "arch_major", file = t("Architecture\\MapArchitecture"), texCoords = tcCR(3, 4, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "draconic_wall", name = "Draconic Wall", catID = "arch_major", file = t("Architecture\\MapArchitecture"), texCoords = tcCR(4, 4, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "draconic_square_building", name = "Draconic Square Building", catID = "arch_major", file = t("Architecture\\MapArchitecture"), texCoords = tcCR(5, 4, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "deepholm_rock_pillar_large", name = "Deepholm Rock Pillar Large", catID = "arch_major", file = t("Architecture\\MapArchitecture"), texCoords = tcCR(6, 4, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "deepholm_rock_pillar_small", name = "Deepholm Rock Pillar Small", catID = "arch_major", file = t("Architecture\\MapArchitecture"), texCoords = tcCR(7, 4, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "deepholm_rock_shards", name = "Deepholm Rock Shards", catID = "arch_major", file = t("Architecture\\MapArchitecture"), texCoords = tcCR(8, 4, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "blood_elven_round_building", name = "Blood Elven Round Building", catID = "arch_major", file = t("Architecture\\MapArchitecture"), texCoords = tcCR(1, 5, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "blood_elven_square_building", name = "Blood Elven Square Building", catID = "arch_major", file = t("Architecture\\MapArchitecture"), texCoords = tcCR(2, 5, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "blood_elven_square_post", name = "Blood Elven Square Post", catID = "arch_major", file = t("Architecture\\MapArchitecture"), texCoords = tcCR(3, 5, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "blood_elven_round_tower", name = "Blood Elven Round Tower", catID = "arch_major", file = t("Architecture\\MapArchitecture"), texCoords = tcCR(4, 5, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "blood_elven_farstrider_building", name = "Blood Elven Farstrider Building", catID = "arch_major", file = t("Architecture\\MapArchitecture"), texCoords = tcCR(5, 5, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "blood_elven_two_story_building", name = "Blood Elven Two Story Building", catID = "arch_major", file = t("Architecture\\MapArchitecture"), texCoords = tcCR(6, 5, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "blood_elven_arcane_sanctum", name = "Blood Elven Arcane Sanctum", catID = "arch_major", file = t("Architecture\\MapArchitecture"), texCoords = tcCR(7, 5, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "blood_elven_small_two_story_building", name = "Blood Elven Small Two Story Building", catID = "arch_major", file = t("Architecture\\MapArchitecture"), texCoords = tcCR(8, 5, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "elven_straight_wall", name = "Elven Straight Wall", catID = "arch_major", file = t("Architecture\\MapArchitecture"), texCoords = tcCR(1, 6, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "elven_round_wall", name = "Elven Round Wall", catID = "arch_major", file = t("Architecture\\MapArchitecture"), texCoords = tcCR(2, 6, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "elven_bridge", name = "Elven Bridge", catID = "arch_major", file = t("Architecture\\MapArchitecture"), texCoords = tcCR(3, 6, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "elven_wall_post", name = "Elven Wall Post", catID = "arch_major", file = t("Architecture\\MapArchitecture"), texCoords = tcCR(4, 6, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "elven_wall_post_hedge", name = "Elven Wall Post Hedge", catID = "arch_major", file = t("Architecture\\MapArchitecture"), texCoords = tcCR(5, 6, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "blood_elven_round_platform", name = "Blood Elven Round Platform", catID = "arch_major", file = t("Architecture\\MapArchitecture"), texCoords = tcCR(6, 6, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "human_two_tower_keep", name = "Human Two Tower Keep", catID = "arch_major", file = t("Architecture\\MapArchitecture"), texCoords = tcCR(7, 6, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "orcish_large_tower", name = "Orcish Large Tower", catID = "arch_major", file = t("Architecture\\MapArchitecture"), texCoords = tcCR(8, 6, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "titanic_icy_round_platform", name = "Titanic Icy Round Platform", catID = "arch_major", file = t("Architecture\\MapArchitecture"), texCoords = tcCR(1, 7, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "titanic_icy_round_tower", name = "Titanic Icy Round Tower", catID = "arch_major", file = t("Architecture\\MapArchitecture"), texCoords = tcCR(2, 7, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "titanic_icy_square_tower", name = "Titanic Icy Square Tower", catID = "arch_major", file = t("Architecture\\MapArchitecture"), texCoords = tcCR(3, 7, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "titanic_icy_entrance_tower", name = "Titanic Icy Entrance Tower", catID = "arch_major", file = t("Architecture\\MapArchitecture"), texCoords = tcCR(4, 7, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "titanic_round_platform", name = "Titanic Round Platform", catID = "arch_major", file = t("Architecture\\MapArchitecture"), texCoords = tcCR(5, 7, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "titanic_round_tower", name = "Titanic Round Tower", catID = "arch_major", file = t("Architecture\\MapArchitecture"), texCoords = tcCR(6, 7, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "titanic_square_tower", name = "Titanic Square Tower", catID = "arch_major", file = t("Architecture\\MapArchitecture"), texCoords = tcCR(7, 7, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "titanic_entrance_tower", name = "Titanic Entrance Tower", catID = "arch_major", file = t("Architecture\\MapArchitecture"), texCoords = tcCR(8, 7, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "ethereal_portal", name = "Ethereal Portal", catID = "arch_major", file = t("Architecture\\MapArchitecture"), texCoords = tcCR(1, 8, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "drustvar_tree", name = "Drustvar Tree", catID = "foliage", file = t("Architecture\\MapArchitecture"), texCoords = tcCR(2, 8, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "wooden_ship", name = "Wooden Ship", catID = "arch_major", file = t("Architecture\\MapArchitecture"), texCoords = tcCR(3, 8, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "ancient_night_elven_tower", name = "Ancient Night Elven Tower", catID = "arch_major", file = t("Architecture\\MapArchitecture"), texCoords = tcCR(4, 8, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "troll_pyramid", name = "Troll Pyramid", catID = "arch_major", file = t("Architecture\\MapArchitecture"), texCoords = tcCR(5, 8, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "draenei_temple", name = "Draenei Temple", catID = "arch_major", file = t("Architecture\\MapArchitecture"), texCoords = tcCR(6, 8, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "troll_altar", name = "Troll Altar", catID = "arch_major", file = t("Architecture\\MapArchitecture"), texCoords = tcCR(7, 8, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "vrykul_keep", name = "Vrykul Keep", catID = "arch_major", file = t("Architecture\\MapArchitecture"), texCoords = tcCR(8, 8, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })

	MTM:RegisterDefinition({ id = "stone_large_tower", name = "Stone Large Tower", catID = "arch_major", file = t("Architecture\\MapArchitecture2"), texCoords = tcCR(1, 1, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "stone_platform", name = "Stone Platform", catID = "arch_major", file = t("Architecture\\MapArchitecture2"), texCoords = tcCR(2, 1, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "stone_stairs", name = "Stone Stairs", catID = "arch_major", file = t("Architecture\\MapArchitecture2"), texCoords = tcCR(3, 1, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "stone_small_tower", name = "Stone Small Tower", catID = "arch_major", file = t("Architecture\\MapArchitecture2"), texCoords = tcCR(4, 1, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "stone_bridge", name = "Stone Bridge", catID = "arch_major", file = t("Architecture\\MapArchitecture2"), texCoords = tcCR(5, 1, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "metal_tower", name = "Metal Tower", catID = "arch_major", file = t("Architecture\\MapArchitecture2"), texCoords = tcCR(6, 1, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "metal_small_building", name = "Metal Small Building", catID = "arch_major", file = t("Architecture\\MapArchitecture2"), texCoords = tcCR(7, 1, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "metal_square_tower", name = "Metal Square Tower", catID = "arch_major", file = t("Architecture\\MapArchitecture2"), texCoords = tcCR(8, 1, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "metal_rectangular_tower", name = "Metal Rectangular Tower", catID = "arch_major", file = t("Architecture\\MapArchitecture2"), texCoords = tcCR(1, 2, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "metal_big_building", name = "Metal Big Building", catID = "arch_major", file = t("Architecture\\MapArchitecture2"), texCoords = tcCR(2, 2, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "venthyr_hexagonal_tower", name = "Venthyr Hexagonal Tower", catID = "arch_major", file = t("Architecture\\MapArchitecture2"), texCoords = tcCR(3, 2, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "venthyr_wall_post", name = "Venthyr Wall Post", catID = "arch_major", file = t("Architecture\\MapArchitecture2"), texCoords = tcCR(4, 2, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "venthyr_small_building_1", name = "Venthyr Small Building 1", catID = "arch_major", file = t("Architecture\\MapArchitecture2"), texCoords = tcCR(5, 2, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "venthyr_small_building_2", name = "Venthyr Small Building 2", catID = "arch_major", file = t("Architecture\\MapArchitecture2"), texCoords = tcCR(6, 2, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "venthyr_medium_building_1", name = "Venthyr Medium Building 1", catID = "arch_major", file = t("Architecture\\MapArchitecture2"), texCoords = tcCR(7, 2, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "venthyr_medium_building_2", name = "Venthyr Medium Building 2", catID = "arch_major", file = t("Architecture\\MapArchitecture2"), texCoords = tcCR(8, 2, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "venthyr_mage_tower", name = "Venthyr Mage Tower", catID = "arch_major", file = t("Architecture\\MapArchitecture2"), texCoords = tcCR(1, 3, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "zereth_mortis_large_orb", name = "Zereth Mortis Large Orb", catID = "arch_major", file = t("Architecture\\MapArchitecture2"), texCoords = tcCR(2, 3, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "zereth_mortis_small_orb_1", name = "Zereth Mortis Small Orb 1", catID = "arch_major", file = t("Architecture\\MapArchitecture2"), texCoords = tcCR(3, 3, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "zereth_mortis_small_orb_2", name = "Zereth Mortis Small Orb 2", catID = "arch_major", file = t("Architecture\\MapArchitecture2"), texCoords = tcCR(4, 3, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "zereth_mortis_medium_orb", name = "Zereth Mortis Medium Orb", catID = "arch_major", file = t("Architecture\\MapArchitecture2"), texCoords = tcCR(5, 3, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "zereth_mortis_small_orb_3", name = "Zereth Mortis Small Orb 3", catID = "arch_major", file = t("Architecture\\MapArchitecture2"), texCoords = tcCR(6, 3, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "gnomish_metal_platform", name = "Gnomish Metal Platform", catID = "arch_major", file = t("Architecture\\MapArchitecture2"), texCoords = tcCR(7, 3, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "gnomish_metal_wall", name = "Gnomish Metal Wall", catID = "arch_major", file = t("Architecture\\MapArchitecture2"), texCoords = tcCR(8, 3, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "gnomish_metal_dungeon_entrance", name = "Gnomish Metal Dungeon Entrance", catID = "arch_major", file = t("Architecture\\MapArchitecture2"), texCoords = tcCR(1, 4, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "gnomish_metal_complex", name = "Gnomish Metal Complex", catID = "arch_major", file = t("Architecture\\MapArchitecture2"), texCoords = tcCR(2, 4, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "gnomish_metal_buildings", name = "Gnomish Metal Buildings", catID = "arch_major", file = t("Architecture\\MapArchitecture2"), texCoords = tcCR(3, 4, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "suramar_round_building_1", name = "Suramar Round Building 1", catID = "arch_major", file = t("Architecture\\MapArchitecture2"), texCoords = tcCR(4, 4, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "suramar_round_building_2", name = "Suramar Round Building 2", catID = "arch_major", file = t("Architecture\\MapArchitecture2"), texCoords = tcCR(5, 4, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "suramar_round_building_3", name = "Suramar Round Building 3", catID = "arch_major", file = t("Architecture\\MapArchitecture2"), texCoords = tcCR(6, 4, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "suramar_square_building_1", name = "Suramar Square Building 1", catID = "arch_major", file = t("Architecture\\MapArchitecture2"), texCoords = tcCR(7, 4, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "suramar_square_building_2", name = "Suramar Square Building 2", catID = "arch_major", file = t("Architecture\\MapArchitecture2"), texCoords = tcCR(8, 4, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "dreamgrove_tree_1", name = "Dreamgrove Tree 1", catID = "foliage", file = t("Architecture\\MapArchitecture2"), texCoords = tcCR(1, 5, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "dreamgrove_tree_2", name = "Dreamgrove Tree 2", catID = "foliage", file = t("Architecture\\MapArchitecture2"), texCoords = tcCR(2, 5, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "dreamgrove_tree_3", name = "Dreamgrove Tree 3", catID = "foliage", file = t("Architecture\\MapArchitecture2"), texCoords = tcCR(3, 5, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "dreamgrove_tree_4", name = "Dreamgrove Tree 4", catID = "foliage", file = t("Architecture\\MapArchitecture2"), texCoords = tcCR(4, 5, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "night_elven_gazebo", name = "Night Elven Gazebo", catID = "arch_major", file = t("Architecture\\MapArchitecture2"), texCoords = tcCR(5, 5, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "night_elven_small_building", name = "Night Elven Small Building", catID = "arch_major", file = t("Architecture\\MapArchitecture2"), texCoords = tcCR(6, 5, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "night_elven_large_building", name = "Night Elven Large Building", catID = "arch_major", file = t("Architecture\\MapArchitecture2"), texCoords = tcCR(7, 5, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "nightmare_tree", name = "Nightmare Tree", catID = "foliage", file = t("Architecture\\MapArchitecture2"), texCoords = tcCR(8, 5, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "nightmare_thorn_1", name = "Nightmare Thorn 1", catID = "foliage", file = t("Architecture\\MapArchitecture2"), texCoords = tcCR(1, 6, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "nightmare_thorn_2", name = "Nightmare Thorn 2", catID = "foliage", file = t("Architecture\\MapArchitecture2"), texCoords = tcCR(2, 6, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "nightmare_thorn_3", name = "Nightmare Thorn 3", catID = "foliage", file = t("Architecture\\MapArchitecture2"), texCoords = tcCR(3, 6, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "nightmare_thorn_4", name = "Nightmare Thorn 4", catID = "foliage", file = t("Architecture\\MapArchitecture2"), texCoords = tcCR(4, 6, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "nightmare_thorn_5", name = "Nightmare Thorn 5", catID = "foliage", file = t("Architecture\\MapArchitecture2"), texCoords = tcCR(5, 6, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "nightmare_thorn_6", name = "Nightmare Thorn 6", catID = "foliage", file = t("Architecture\\MapArchitecture2"), texCoords = tcCR(6, 6, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "nightmare_thorn_7", name = "Nightmare Thorn 7", catID = "foliage", file = t("Architecture\\MapArchitecture2"), texCoords = tcCR(7, 6, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "nightmare_thorn_8", name = "Nightmare Thorn 8", catID = "foliage", file = t("Architecture\\MapArchitecture2"), texCoords = tcCR(8, 6, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "nightmare_thorn_9", name = "Nightmare Thorn 9", catID = "foliage", file = t("Architecture\\MapArchitecture2"), texCoords = tcCR(1, 7, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "dreamgrove_spiral_1", name = "Dreamgrove Spiral 1", catID = "foliage", file = t("Architecture\\MapArchitecture2"), texCoords = tcCR(2, 7, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "dreamgrove_spiral_2", name = "Dreamgrove Spiral 2", catID = "foliage", file = t("Architecture\\MapArchitecture2"), texCoords = tcCR(3, 7, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "dreamgrove_spiral_3", name = "Dreamgrove Spiral 3", catID = "foliage", file = t("Architecture\\MapArchitecture2"), texCoords = tcCR(4, 7, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "dreamgrove_golem_1", name = "Dreamgrove Golem 1", catID = "arch_major", file = t("Architecture\\MapArchitecture2"), texCoords = tcCR(5, 7, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "dreamgrove_golem_2", name = "Dreamgrove Golem 2", catID = "arch_major", file = t("Architecture\\MapArchitecture2"), texCoords = tcCR(6, 7, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "dreamgrove_golem_3", name = "Dreamgrove Golem 3", catID = "arch_major", file = t("Architecture\\MapArchitecture2"), texCoords = tcCR(7, 7, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "draenei_ship", name = "Draenei Ship", catID = "arch_major", file = t("Architecture\\MapArchitecture2"), texCoords = tcCR(8, 7, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "draenei_ship_lightforged", name = "Draenei Ship Lightforged", catID = "arch_major", file = t("Architecture\\MapArchitecture2"), texCoords = tcCR(1, 8, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "draenei_ship_pink", name = "Draenei Ship Pink", catID = "arch_major", file = t("Architecture\\MapArchitecture2"), texCoords = tcCR(2, 8, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "zandalari_ship", name = "Zandalari Ship", catID = "arch_major", file = t("Architecture\\MapArchitecture2"), texCoords = tcCR(3, 8, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "crystal_mound", name = "Crystal Mound", catID = "arch_major", file = t("Architecture\\MapArchitecture2"), texCoords = tcCR(4, 8, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "ogre_complex", name = "Ogre Complex", catID = "arch_major", file = t("Architecture\\MapArchitecture2"), texCoords = tcCR(5, 8, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "ogre_platform", name = "Ogre Platform", catID = "arch_major", file = t("Architecture\\MapArchitecture2"), texCoords = tcCR(6, 8, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "ogre_tower", name = "Ogre Tower", catID = "arch_major", file = t("Architecture\\MapArchitecture2"), texCoords = tcCR(7, 8, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "leaning_rocks", name = "Leaning Rocks", catID = "arch_major", file = t("Architecture\\MapArchitecture2"), texCoords = tcCR(8, 8, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })

	MTM:RegisterDefinition({ id = "human_mage_tower", name = "Human Mage Tower", catID = "arch_major", file = t("Architecture\\MapArchitecture3"), texCoords = tcCR(1, 1, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "human_trading_post", name = "Human Trading Post", catID = "arch_major", file = t("Architecture\\MapArchitecture3"), texCoords = tcCR(2, 1, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "human_town_hall", name = "Human Town Hall", catID = "arch_major", file = t("Architecture\\MapArchitecture3"), texCoords = tcCR(3, 1, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "human_small_house", name = "Human Small House", catID = "arch_major", file = t("Architecture\\MapArchitecture3"), texCoords = tcCR(4, 1, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "human_blacksmith", name = "Human Blacksmith", catID = "arch_major", file = t("Architecture\\MapArchitecture3"), texCoords = tcCR(5, 1, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "human_tent", name = "Human Tent", catID = "arch_major", file = t("Architecture\\MapArchitecture3"), texCoords = tcCR(6, 1, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "human_wagon_1", name = "Human Wagon 1", catID = "arch_major", file = t("Architecture\\MapArchitecture3"), texCoords = tcCR(7, 1, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "human_wagon_2", name = "Human Wagon 2", catID = "arch_major", file = t("Architecture\\MapArchitecture3"), texCoords = tcCR(8, 1, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "human_infirmary", name = "Human Infirmary", catID = "arch_major", file = t("Architecture\\MapArchitecture3"), texCoords = tcCR(1, 2, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "human_construction_1", name = "Human Construction 1", catID = "arch_major", file = t("Architecture\\MapArchitecture3"), texCoords = tcCR(2, 2, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "human_construction_2", name = "Human Construction 2", catID = "arch_major", file = t("Architecture\\MapArchitecture3"), texCoords = tcCR(3, 2, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "gnomish_engineering_depot", name = "Gnomish Engineering Depot", catID = "arch_major", file = t("Architecture\\MapArchitecture3"), texCoords = tcCR(4, 2, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "human_town_hall_3d", name = "Human Town Hall 3D", catID = "arch_major", file = t("Architecture\\MapArchitecture3"), texCoords = tcCR(5, 2, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "orcish_town_hall", name = "Orcish Town Hall", catID = "arch_major", file = t("Architecture\\MapArchitecture3"), texCoords = tcCR(6, 2, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "orcish_tavern", name = "Orcish Tavern", catID = "arch_major", file = t("Architecture\\MapArchitecture3"), texCoords = tcCR(7, 2, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "orcish_hut_1", name = "Orcish Hut 1", catID = "arch_major", file = t("Architecture\\MapArchitecture3"), texCoords = tcCR(8, 2, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "orcish_hut_2", name = "Orcish Hut 2", catID = "arch_major", file = t("Architecture\\MapArchitecture3"), texCoords = tcCR(1, 3, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "orcish_hut_3", name = "Orcish Hut 3", catID = "arch_major", file = t("Architecture\\MapArchitecture3"), texCoords = tcCR(2, 3, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "orcish_town_hall_3d", name = "Orcish Town Hall 3D", catID = "arch_major", file = t("Architecture\\MapArchitecture3"), texCoords = tcCR(3, 3, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "pandaren_temple_center", name = "Pandaren Temple Center", catID = "arch_major", file = t("Architecture\\MapArchitecture3"), texCoords = tcCR(4, 3, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "pandaren_temple_building_1", name = "Pandaren Temple Building 1", catID = "arch_major", file = t("Architecture\\MapArchitecture3"), texCoords = tcCR(5, 3, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "pandaren_temple_building_2", name = "Pandaren Temple Building 2", catID = "arch_major", file = t("Architecture\\MapArchitecture3"), texCoords = tcCR(6, 3, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "pandaren_temple_building_conjoined", name = "Pandaren Temple Building Conjoined", catID = "arch_major", file = t("Architecture\\MapArchitecture3"), texCoords = tcCR(7, 3, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "mogu_tower_post", name = "Mogu Tower Post", catID = "arch_major", file = t("Architecture\\MapArchitecture3"), texCoords = tcCR(8, 3, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "mogu_building_1", name = "Mogu Building 1", catID = "arch_major", file = t("Architecture\\MapArchitecture3"), texCoords = tcCR(1, 4, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "mogu_building_2", name = "Mogu Building 2", catID = "arch_major", file = t("Architecture\\MapArchitecture3"), texCoords = tcCR(2, 4, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "mogu_building_3", name = "Mogu Building 3", catID = "arch_major", file = t("Architecture\\MapArchitecture3"), texCoords = tcCR(3, 4, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "wooden_dock_1", name = "Wooden Dock 1", catID = "arch_major", file = t("Architecture\\MapArchitecture3"), texCoords = tcCR(4, 4, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "wooden_dock_2", name = "Wooden Dock 2", catID = "arch_major", file = t("Architecture\\MapArchitecture3"), texCoords = tcCR(5, 4, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "legion_base_(colour)", name = "Legion Base (Colour)", catID = "arch_major", file = t("Architecture\\MapArchitecture3"), texCoords = tcCR(6, 4, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "legion_ship_(colour)", name = "Legion Ship (Colour)", catID = "arch_major", file = t("Architecture\\MapArchitecture3"), texCoords = tcCR(7, 4, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "legion_tower_(colour)", name = "Legion Tower (Colour)", catID = "arch_major", file = t("Architecture\\MapArchitecture3"), texCoords = tcCR(8, 4, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "legion_workshop_(colour)", name = "Legion Workshop (Colour)", catID = "arch_major", file = t("Architecture\\MapArchitecture3"), texCoords = tcCR(1, 5, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "legion_workshop", name = "Legion Workshop", catID = "arch_major", file = t("Architecture\\MapArchitecture3"), texCoords = tcCR(2, 5, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "legion_tower", name = "Legion Tower", catID = "arch_major", file = t("Architecture\\MapArchitecture3"), texCoords = tcCR(3, 5, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "legion_ship", name = "Legion Ship", catID = "arch_major", file = t("Architecture\\MapArchitecture3"), texCoords = tcCR(4, 5, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "destroyed_dark_portal", name = "Destroyed Dark Portal", catID = "arch_major", file = t("Architecture\\MapArchitecture3"), texCoords = tcCR(5, 5, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "goblin_workshop", name = "Goblin Workshop", catID = "arch_major", file = t("Architecture\\MapArchitecture3"), texCoords = tcCR(6, 5, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "kul_tiras_turret", name = "Kul Tiras Turret", catID = "arch_major", file = t("Architecture\\MapArchitecture3"), texCoords = tcCR(7, 5, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "kul_tiras_medium_archway", name = "Kul Tiras Medium Archway", catID = "arch_major", file = t("Architecture\\MapArchitecture3"), texCoords = tcCR(8, 5, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "kul_tiras_small_archway", name = "Kul Tiras Small Archway", catID = "arch_major", file = t("Architecture\\MapArchitecture3"), texCoords = tcCR(1, 6, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "kul_tiras_wall", name = "Kul Tiras Wall", catID = "arch_major", file = t("Architecture\\MapArchitecture3"), texCoords = tcCR(2, 6, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "kul_tiras_fishing_hut", name = "Kul Tiras Fishing Hut", catID = "arch_major", file = t("Architecture\\MapArchitecture3"), texCoords = tcCR(3, 6, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "kul_tiras_round_wall", name = "Kul Tiras Round Wall", catID = "arch_major", file = t("Architecture\\MapArchitecture3"), texCoords = tcCR(4, 6, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "kul_tiras_seawall_tower", name = "Kul Tiras Seawall Tower", catID = "arch_major", file = t("Architecture\\MapArchitecture3"), texCoords = tcCR(5, 6, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "orcish_wall", name = "Orcish Wall", catID = "arch_major", file = t("Architecture\\MapArchitecture3"), texCoords = tcCR(6, 6, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "earthen_ritual_ground", name = "Earthen Ritual Ground", catID = "arch_major", file = t("Architecture\\MapArchitecture3"), texCoords = tcCR(7, 6, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "swirly_cloud", name = "Swirly Cloud", catID = "art", file = t("Architecture\\MapArchitecture3"), texCoords = tcCR(8, 6, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "blue_dragon_nexus", name = "Blue Dragon Nexus", catID = "arch_major", file = t("Architecture\\MapArchitecture3"), texCoords = tcCR(1, 7, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "titanic_tower", name = "Titanic Tower", catID = "arch_major", file = t("Architecture\\MapArchitecture3"), texCoords = tcCR(2, 7, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "exodar", name = "Exodar", catID = "arch_major", file = t("Architecture\\MapArchitecture3"), texCoords = tcCR(3, 7, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "goblin_wooden_face_board", name = "Goblin Wooden Face Board", catID = "arch_major", file = t("Architecture\\MapArchitecture3"), texCoords = tcCR(4, 7, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "troll_square_building", name = "Troll Square Building", catID = "arch_major", file = t("Architecture\\MapArchitecture3"), texCoords = tcCR(5, 7, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "troll_stairs", name = "Troll Stairs", catID = "arch_major", file = t("Architecture\\MapArchitecture3"), texCoords = tcCR(6, 7, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "troll_bridge", name = "Troll Bridge", catID = "arch_major", file = t("Architecture\\MapArchitecture3"), texCoords = tcCR(7, 7, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "troll_skull_temple", name = "Troll Skull Temple", catID = "arch_major", file = t("Architecture\\MapArchitecture3"), texCoords = tcCR(8, 7, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "troll_bear_temple", name = "Troll Bear Temple", catID = "arch_major", file = t("Architecture\\MapArchitecture3"), texCoords = tcCR(1, 8, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "jagged_rocks_1", name = "Jagged Rocks 1", catID = "arch_major", file = t("Architecture\\MapArchitecture3"), texCoords = tcCR(2, 8, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "jagged_rocks_2", name = "Jagged Rocks 2", catID = "arch_major", file = t("Architecture\\MapArchitecture3"), texCoords = tcCR(3, 8, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "jagged_rocks_3", name = "Jagged Rocks 3", catID = "arch_major", file = t("Architecture\\MapArchitecture3"), texCoords = tcCR(4, 8, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "jagged_rocks_4", name = "Jagged Rocks 4", catID = "arch_major", file = t("Architecture\\MapArchitecture3"), texCoords = tcCR(5, 8, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "jagged_rocks_5", name = "Jagged Rocks 5", catID = "arch_major", file = t("Architecture\\MapArchitecture3"), texCoords = tcCR(6, 8, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "jagged_rocks_6", name = "Jagged Rocks 6", catID = "arch_major", file = t("Architecture\\MapArchitecture3"), texCoords = tcCR(7, 8, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "jagged_rocks_7", name = "Jagged Rocks 7", catID = "arch_major", file = t("Architecture\\MapArchitecture3"), texCoords = tcCR(8, 8, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })

	MTM:RegisterDefinition({ id = "elven_round_building", name = "Elven Round Building", catID = "arch_major", file = t("Architecture\\MapArchitecture4"), texCoords = tcCR(1, 1, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "elven_square_building", name = "Elven Square Building", catID = "arch_major", file = t("Architecture\\MapArchitecture4"), texCoords = tcCR(2, 1, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "elven_square_post", name = "Elven Square Post", catID = "arch_major", file = t("Architecture\\MapArchitecture4"), texCoords = tcCR(3, 1, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "elven_round_tower", name = "Elven Round Tower", catID = "arch_major", file = t("Architecture\\MapArchitecture4"), texCoords = tcCR(4, 1, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "elven_round_platform", name = "Elven Round Platform", catID = "arch_major", file = t("Architecture\\MapArchitecture4"), texCoords = tcCR(5, 1, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "planet_1", name = "Planet 1", catID = "art", file = t("Architecture\\MapArchitecture4"), texCoords = tcCR(6, 1, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "planet_2", name = "Planet 2", catID = "art", file = t("Architecture\\MapArchitecture4"), texCoords = tcCR(7, 1, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "planet_3", name = "Planet 3", catID = "art", file = t("Architecture\\MapArchitecture4"), texCoords = tcCR(8, 1, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "high_elven_round_building", name = "High Elven Round Building", catID = "arch_major", file = t("Architecture\\MapArchitecture4"), texCoords = tcCR(1, 2, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "high_elven_square_building", name = "High Elven Square Building", catID = "arch_major", file = t("Architecture\\MapArchitecture4"), texCoords = tcCR(2, 2, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "high_elven_square_post", name = "High Elven Square Post", catID = "arch_major", file = t("Architecture\\MapArchitecture4"), texCoords = tcCR(3, 2, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "high_elven_round_tower", name = "High Elven Round Tower", catID = "arch_major", file = t("Architecture\\MapArchitecture4"), texCoords = tcCR(4, 2, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "high_elven_farstrider_building", name = "High Elven Farstrider Building", catID = "arch_major", file = t("Architecture\\MapArchitecture4"), texCoords = tcCR(5, 2, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "high_elven_two_story_building", name = "High Elven Two Story Building", catID = "arch_major", file = t("Architecture\\MapArchitecture4"), texCoords = tcCR(6, 2, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "high_elven_arcane_sanctum", name = "High Elven Arcane Sanctum", catID = "arch_major", file = t("Architecture\\MapArchitecture4"), texCoords = tcCR(7, 2, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "high_elven_small_two_story_building", name = "High Elven Small Two Story Building", catID = "arch_major", file = t("Architecture\\MapArchitecture4"), texCoords = tcCR(8, 2, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "high_elven_round_platform", name = "High Elven Round Platform", catID = "arch_major", file = t("Architecture\\MapArchitecture4"), texCoords = tcCR(1, 3, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "crystal_outcrop_1", name = "Crystal Outcrop 1", catID = "arch_major", file = t("Architecture\\MapArchitecture4"), texCoords = tcCR(2, 3, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "crystal_outcrop_2", name = "Crystal Outcrop 2", catID = "arch_major", file = t("Architecture\\MapArchitecture4"), texCoords = tcCR(3, 3, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "crystal_outcrop_3", name = "Crystal Outcrop 3", catID = "arch_major", file = t("Architecture\\MapArchitecture4"), texCoords = tcCR(4, 3, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "celestial_anomaly", name = "Celestial Anomaly", catID = "art", file = t("Architecture\\MapArchitecture4"), texCoords = tcCR(5, 3, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "star_1", name = "Star 1", catID = "art", file = t("Architecture\\MapArchitecture4"), texCoords = tcCR(6, 3, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "star_2", name = "Star 2", catID = "art", file = t("Architecture\\MapArchitecture4"), texCoords = tcCR(7, 3, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "kaareshi_spiky_rock_1", name = "Kaareshi Spiky Rock 1", catID = "arch_major", file = t("Architecture\\MapArchitecture4"), texCoords = tcCR(8, 3, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "kaareshi_spiky_rock_2", name = "Kaareshi Spiky Rock 2", catID = "arch_major", file = t("Architecture\\MapArchitecture4"), texCoords = tcCR(1, 4, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "kaareshi_spiky_rock_3", name = "Kaareshi Spiky Rock 3", catID = "arch_major", file = t("Architecture\\MapArchitecture4"), texCoords = tcCR(2, 4, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "kaareshi_spiky_rock_4", name = "Kaareshi Spiky Rock 4", catID = "arch_major", file = t("Architecture\\MapArchitecture4"), texCoords = tcCR(3, 4, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "kaareshi_spiky_rock_5", name = "Kaareshi Spiky Rock 5", catID = "arch_major", file = t("Architecture\\MapArchitecture4"), texCoords = tcCR(4, 4, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "kaareshi_spiky_rock_6", name = "Kaareshi Spiky Rock 6", catID = "arch_major", file = t("Architecture\\MapArchitecture4"), texCoords = tcCR(5, 4, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "kaareshi_spiky_rock_7", name = "Kaareshi Spiky Rock 7", catID = "arch_major", file = t("Architecture\\MapArchitecture4"), texCoords = tcCR(6, 4, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "kaareshi_spiky_rock_8", name = "Kaareshi Spiky Rock 8", catID = "arch_major", file = t("Architecture\\MapArchitecture4"), texCoords = tcCR(7, 4, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "kaareshi_spiky_rock_9", name = "Kaareshi Spiky Rock 9", catID = "arch_major", file = t("Architecture\\MapArchitecture4"), texCoords = tcCR(8, 4, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "venthyr_elevator", name = "Venthyr Elevator", catID = "arch_major", file = t("Architecture\\MapArchitecture4"), texCoords = tcCR(1, 5, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "venthyr_elevator_house", name = "Venthyr Elevator House", catID = "arch_major", file = t("Architecture\\MapArchitecture4"), texCoords = tcCR(2, 5, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "vindicaar", name = "Vindicaar", catID = "arch_major", file = t("Architecture\\MapArchitecture4"), texCoords = tcCR(3, 5, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "darkmoon_tent_round", name = "Darkmoon Tent Round", catID = "arch_major", file = t("Architecture\\MapArchitecture4"), texCoords = tcCR(4, 5, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "darkmoon_tent_long", name = "Darkmoon Tent Long", catID = "arch_major", file = t("Architecture\\MapArchitecture4"), texCoords = tcCR(5, 5, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "darkmoon_tent_small", name = "Darkmoon Tent Small", catID = "arch_major", file = t("Architecture\\MapArchitecture4"), texCoords = tcCR(6, 5, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "darkmoon_tent_large", name = "Darkmoon Tent Large", catID = "arch_major", file = t("Architecture\\MapArchitecture4"), texCoords = tcCR(7, 5, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "nazmir_titanic_facility", name = "Nazmir Titanic Facility", catID = "arch_major", file = t("Architecture\\MapArchitecture4"), texCoords = tcCR(8, 5, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "blue_dragon_nexus_large", name = "Blue Dragon Nexus Large", catID = "arch_major", file = t("Architecture\\MapArchitecture4"), texCoords = tcCR(1, 6, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "goblin_hotel", name = "Goblin Hotel", catID = "arch_major", file = t("Architecture\\MapArchitecture4"), texCoords = tcCR(2, 6, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "black_dragon_temple", name = "Black Dragon Temple", catID = "arch_major", file = t("Architecture\\MapArchitecture4"), texCoords = tcCR(3, 6, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "dragon_tower", name = "Dragon Tower", catID = "arch_major", file = t("Architecture\\MapArchitecture4"), texCoords = tcCR(4, 6, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "titanic_incarnate_vault_entrance", name = "Titanic Incarnate Vault Entrance", catID = "arch_major", file = t("Architecture\\MapArchitecture4"), texCoords = tcCR(5, 6, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "dwarven_forge", name = "Dwarven Forge", catID = "arch_major", file = t("Architecture\\MapArchitecture4"), texCoords = tcCR(6, 6, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "twilight_highlands_void_platform", name = "Twilight Highlands Void Platform", catID = "arch_major", file = t("Architecture\\MapArchitecture4"), texCoords = tcCR(7, 6, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "twilight_highlands_void_tower", name = "Twilight Highlands Void Tower", catID = "arch_major", file = t("Architecture\\MapArchitecture4"), texCoords = tcCR(8, 6, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "icecrown_saronite_building", name = "Icecrown Saronite Building", catID = "arch_major", file = t("Architecture\\MapArchitecture4"), texCoords = tcCR(1, 7, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "icecrown_saronite_gateway", name = "Icecrown Saronite Gateway", catID = "arch_major", file = t("Architecture\\MapArchitecture4"), texCoords = tcCR(2, 7, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "icecrown_saronite_wall", name = "Icecrown Saronite Wall", catID = "arch_major", file = t("Architecture\\MapArchitecture4"), texCoords = tcCR(3, 7, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "old_god_mouth", name = "Old God Mouth", catID = "arch_major", file = t("Architecture\\MapArchitecture4"), texCoords = tcCR(4, 7, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "titanic_facility_tyrhold", name = "Titanic Facility Tyrhold", catID = "arch_major", file = t("Architecture\\MapArchitecture4"), texCoords = tcCR(5, 7, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "goblin_mega_cannon", name = "Goblin Mega Cannon", catID = "arch_major", file = t("Architecture\\MapArchitecture4"), texCoords = tcCR(6, 7, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "dwarven_mountainside_tower", name = "Dwarven Mountainside Tower", catID = "arch_major", file = t("Architecture\\MapArchitecture4"), texCoords = tcCR(7, 7, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "dwarven_stronghold_entrance", name = "Dwarven Stronghold Entrance", catID = "arch_major", file = t("Architecture\\MapArchitecture4"), texCoords = tcCR(8, 7, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "gnomeregan_entrance", name = "Gnomeregan Entrance", catID = "arch_major", file = t("Architecture\\MapArchitecture4"), texCoords = tcCR(1, 8, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "troll_arena", name = "Troll Arena", catID = "arch_major", file = t("Architecture\\MapArchitecture4"), texCoords = tcCR(2, 8, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "night_elven_colosseum", name = "Night Elven Colosseum", catID = "arch_major", file = t("Architecture\\MapArchitecture4"), texCoords = tcCR(3, 8, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "human_island_complex", name = "Human Island Complex", catID = "arch_major", file = t("Architecture\\MapArchitecture4"), texCoords = tcCR(4, 8, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "human_barracks", name = "Human Barracks", catID = "arch_major", file = t("Architecture\\MapArchitecture4"), texCoords = tcCR(5, 8, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "draenei_round_temple", name = "Draenei Round Temple", catID = "arch_major", file = t("Architecture\\MapArchitecture4"), texCoords = tcCR(6, 8, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "maldraxxus_necrolord_statue", name = "Maldraxxus Necrolord Statue", catID = "arch_major", file = t("Architecture\\MapArchitecture4"), texCoords = tcCR(7, 8, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "orcish_gateway", name = "Orcish Gateway", catID = "arch_major", file = t("Architecture\\MapArchitecture4"), texCoords = tcCR(8, 8, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })

	MTM:RegisterDefinition({ id = "azeroth_dark_portal", name = "Azeroth Dark Portal", catID = "arch_major", file = t("Architecture\\MapArchitecture5"), texCoords = tcCR(1, 1, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "ruined_dark_portal", name = "Ruined Dark Portal", catID = "arch_major", file = t("Architecture\\MapArchitecture5"), texCoords = tcCR(2, 1, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "undercity", name = "Undercity", catID = "arch_major", file = t("Architecture\\MapArchitecture5"), texCoords = tcCR(3, 1, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "manaforge", name = "Manaforge", catID = "arch_major", file = t("Architecture\\MapArchitecture5"), texCoords = tcCR(4, 1, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "legion_citadel_1", name = "Legion Citadel 1", catID = "arch_major", file = t("Architecture\\MapArchitecture5"), texCoords = tcCR(5, 1, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "goblin_statue", name = "Goblin Statue", catID = "arch_major", file = t("Architecture\\MapArchitecture5"), texCoords = tcCR(6, 1, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "goblin_house_1", name = "Goblin House 1", catID = "arch_major", file = t("Architecture\\MapArchitecture5"), texCoords = tcCR(7, 1, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "goblin_house_2", name = "Goblin House 2", catID = "arch_major", file = t("Architecture\\MapArchitecture5"), texCoords = tcCR(8, 1, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "goblin_house_3", name = "Goblin House 3", catID = "arch_major", file = t("Architecture\\MapArchitecture5"), texCoords = tcCR(1, 2, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "goblin_house_4", name = "Goblin House 4", catID = "arch_major", file = t("Architecture\\MapArchitecture5"), texCoords = tcCR(2, 2, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "goblin_house_5", name = "Goblin House 5", catID = "arch_major", file = t("Architecture\\MapArchitecture5"), texCoords = tcCR(3, 2, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "goblin_house_6", name = "Goblin House 6", catID = "arch_major", file = t("Architecture\\MapArchitecture5"), texCoords = tcCR(4, 2, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "goblin_house_7", name = "Goblin House 7", catID = "arch_major", file = t("Architecture\\MapArchitecture5"), texCoords = tcCR(5, 2, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "goblin_house_8", name = "Goblin House 8", catID = "arch_major", file = t("Architecture\\MapArchitecture5"), texCoords = tcCR(6, 2, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "goblin_tower_post", name = "Goblin Tower Post", catID = "arch_major", file = t("Architecture\\MapArchitecture5"), texCoords = tcCR(7, 2, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "ruby_sanctum_tree_1", name = "Ruby Sanctum Tree 1", catID = "arch_major", file = t("Architecture\\MapArchitecture5"), texCoords = tcCR(8, 2, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "goblin_wall_1", name = "Goblin Wall 1", catID = "arch_major", file = t("Architecture\\MapArchitecture5"), texCoords = tcCR(1, 3, 8, 8, 0, 0, 3, 1), width = p(192, 0), height = p(64, 0) })


	MTM:RegisterDefinition({ id = "goblin_wall_2", name = "Goblin Wall 2", catID = "arch_major", file = t("Architecture\\MapArchitecture5"), texCoords = tcCR(4, 3, 8, 8, 0, 0, 3, 1), width = p(192, 0), height = p(64, 0) })


	MTM:RegisterDefinition({ id = "ruby_sanctum_tree_2", name = "Ruby Sanctum Tree 2", catID = "arch_major", file = t("Architecture\\MapArchitecture5"), texCoords = tcCR(7, 3, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "ruby_sanctum_tree_3", name = "Ruby Sanctum Tree 3", catID = "arch_major", file = t("Architecture\\MapArchitecture5"), texCoords = tcCR(8, 3, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "bamboo_cluster", name = "Bamboo Cluster", catID = "arch_major", file = t("Architecture\\MapArchitecture5"), texCoords = tcCR(1, 4, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "farraki_entrance", name = "Farraki Entrance", catID = "arch_major", file = t("Architecture\\MapArchitecture5"), texCoords = tcCR(2, 4, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "uldum_pyramid", name = "Uldum Pyramid", catID = "arch_major", file = t("Architecture\\MapArchitecture5"), texCoords = tcCR(3, 4, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "first_ones_ruined_platform_1", name = "First Ones Ruined Platform 1", catID = "arch_major", file = t("Architecture\\MapArchitecture5"), texCoords = tcCR(4, 4, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "first_ones_ruined_platform_2", name = "First Ones Ruined Platform 2", catID = "arch_major", file = t("Architecture\\MapArchitecture5"), texCoords = tcCR(5, 4, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "first_ones_ruins", name = "First Ones Ruins", catID = "arch_major", file = t("Architecture\\MapArchitecture5"), texCoords = tcCR(6, 4, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "kobold_entrance", name = "Kobold Entrance", catID = "arch_major", file = t("Architecture\\MapArchitecture5"), texCoords = tcCR(7, 4, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "mantid_keep", name = "Mantid Keep", catID = "arch_major", file = t("Architecture\\MapArchitecture5"), texCoords = tcCR(8, 4, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "pandaren_jade_temple", name = "Pandaren Jade Temple", catID = "arch_major", file = t("Architecture\\MapArchitecture5"), texCoords = tcCR(1, 5, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "forsaken_ship_1", name = "Forsaken Ship 1", catID = "arch_major", file = t("Architecture\\MapArchitecture5"), texCoords = tcCR(2, 5, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "pandaren_monk_statue", name = "Pandaren Monk Statue", catID = "arch_major", file = t("Architecture\\MapArchitecture5"), texCoords = tcCR(3, 5, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "forsaken_ship_2", name = "Forsaken Ship 2", catID = "arch_major", file = t("Architecture\\MapArchitecture5"), texCoords = tcCR(4, 5, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "orcish_ship", name = "Orcish Ship", catID = "arch_major", file = t("Architecture\\MapArchitecture5"), texCoords = tcCR(5, 5, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "human_ship_1", name = "Human Ship 1", catID = "arch_major", file = t("Architecture\\MapArchitecture5"), texCoords = tcCR(6, 5, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "human_airship", name = "Human Airship", catID = "arch_major", file = t("Architecture\\MapArchitecture5"), texCoords = tcCR(7, 5, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "pandaren_red_crane_temple", name = "Pandaren Red Crane Temple", catID = "arch_major", file = t("Architecture\\MapArchitecture5"), texCoords = tcCR(8, 5, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "human_ship_2", name = "Human Ship 2", catID = "arch_major", file = t("Architecture\\MapArchitecture5"), texCoords = tcCR(1, 6, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "shipwreck", name = "Shipwreck", catID = "arch_major", file = t("Architecture\\MapArchitecture5"), texCoords = tcCR(2, 6, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "stormstout_brewery_1", name = "Stormstout Brewery 1", catID = "arch_major", file = t("Architecture\\MapArchitecture5"), texCoords = tcCR(3, 6, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "stormstout_brewery_2", name = "Stormstout Brewery 2", catID = "arch_major", file = t("Architecture\\MapArchitecture5"), texCoords = tcCR(4, 6, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "mogu_statue_1", name = "Mogu Statue 1", catID = "arch_major", file = t("Architecture\\MapArchitecture5"), texCoords = tcCR(5, 6, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "mogu_statue_2", name = "Mogu Statue 2", catID = "arch_major", file = t("Architecture\\MapArchitecture5"), texCoords = tcCR(6, 6, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "pandaren_crypt_entrance", name = "Pandaren Crypt Entrance", catID = "arch_major", file = t("Architecture\\MapArchitecture5"), texCoords = tcCR(7, 6, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "pandaren_ruined_tower", name = "Pandaren Ruined Tower", catID = "arch_major", file = t("Architecture\\MapArchitecture5"), texCoords = tcCR(8, 6, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "pandaren_tower", name = "Pandaren Tower", catID = "arch_major", file = t("Architecture\\MapArchitecture5"), texCoords = tcCR(1, 7, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "legion_citadel_2", name = "Legion Citadel 2", catID = "arch_major", file = t("Architecture\\MapArchitecture5"), texCoords = tcCR(2, 7, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "legion_fortress", name = "Legion Fortress", catID = "arch_major", file = t("Architecture\\MapArchitecture5"), texCoords = tcCR(3, 7, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })














	MTM:RegisterDefinition({ id = "wall_corner_1_(tintable)", name = "Wall Corner 1 (Tintable)", catID = "arch_major", file = t("Architecture\\MapArchitecture6"), texCoords = tcCR(1, 1, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "wall_angled_(tintable)", name = "Wall Angled (Tintable)", catID = "arch_major", file = t("Architecture\\MapArchitecture6"), texCoords = tcCR(2, 1, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "wall_post_(tintable)", name = "Wall Post (Tintable)", catID = "arch_major", file = t("Architecture\\MapArchitecture6"), texCoords = tcCR(3, 1, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "wall_diagonal_1_(tintable)", name = "Wall Diagonal 1 (Tintable)", catID = "arch_major", file = t("Architecture\\MapArchitecture6"), texCoords = tcCR(4, 1, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "wall_diagonal_2_(tintable)", name = "Wall Diagonal 2 (Tintable)", catID = "arch_major", file = t("Architecture\\MapArchitecture6"), texCoords = tcCR(5, 1, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "wall_straight_short_1_(tintable)", name = "Wall Straight Short 1 (Tintable)", catID = "arch_major", file = t("Architecture\\MapArchitecture6"), texCoords = tcCR(6, 1, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "wall_straight_short_2_(tintable)", name = "Wall Straight Short 2 (Tintable)", catID = "arch_major", file = t("Architecture\\MapArchitecture6"), texCoords = tcCR(7, 1, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "wall_corner_piece_2_(tintable)", name = "Wall Corner Piece 2 (Tintable)", catID = "arch_major", file = t("Architecture\\MapArchitecture6"), texCoords = tcCR(8, 1, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "circle_shape_(tintable)", name = "Circle Shape (Tintable)", catID = "arch_major", file = t("Architecture\\MapArchitecture6"), texCoords = tcCR(1, 2, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "small_circle_shape_(tintable)", name = "Small Circle Shape (Tintable)", catID = "arch_major", file = t("Architecture\\MapArchitecture6"), texCoords = tcCR(2, 2, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "diamond_shape_(tintable)", name = "Diamond Shape (Tintable)", catID = "arch_major", file = t("Architecture\\MapArchitecture6"), texCoords = tcCR(3, 2, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "hexagon_shape_(tintable)", name = "Hexagon Shape (Tintable)", catID = "arch_major", file = t("Architecture\\MapArchitecture6"), texCoords = tcCR(4, 2, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "small_hexagon_shape_(tintable)", name = "Small Hexagon Shape (Tintable)", catID = "arch_major", file = t("Architecture\\MapArchitecture6"), texCoords = tcCR(5, 2, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "pentagon_shape_(tintable)", name = "Pentagon Shape (Tintable)", catID = "arch_major", file = t("Architecture\\MapArchitecture6"), texCoords = tcCR(6, 2, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "small_pentagon_shape_(tintable)", name = "Small Pentagon Shape (Tintable)", catID = "arch_major", file = t("Architecture\\MapArchitecture6"), texCoords = tcCR(7, 2, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "triangle_shape_(tintable)", name = "Triangle Shape (Tintable)", catID = "arch_major", file = t("Architecture\\MapArchitecture6"), texCoords = tcCR(8, 2, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "small_triangle_shape_(tintable)", name = "Small Triangle Shape (Tintable)", catID = "arch_major", file = t("Architecture\\MapArchitecture6"), texCoords = tcCR(1, 3, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "right_angle_triangle_shape_(tintable)", name = "Right Angle Triangle Shape (Tintable)", catID = "arch_major", file = t("Architecture\\MapArchitecture6"), texCoords = tcCR(2, 3, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "small_right_angle_triangle_shape_(tintable)", name = "Small Right Angle Triangle Shape (Tintable)", catID = "arch_major", file = t("Architecture\\MapArchitecture6"), texCoords = tcCR(3, 3, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "semi_circle_shape_(tintable)", name = "Semi Circle Shape (Tintable)", catID = "arch_major", file = t("Architecture\\MapArchitecture6"), texCoords = tcCR(4, 3, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "small_semi_circle_shape_(tintable)", name = "Small Semi Circle Shape (Tintable)", catID = "arch_major", file = t("Architecture\\MapArchitecture6"), texCoords = tcCR(5, 3, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "oval_shape_(tintable)", name = "Oval Shape (Tintable)", catID = "arch_major", file = t("Architecture\\MapArchitecture6"), texCoords = tcCR(6, 3, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "small_oval_shape_(tintable)", name = "Small Oval Shape (Tintable)", catID = "arch_major", file = t("Architecture\\MapArchitecture6"), texCoords = tcCR(7, 3, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "cross_shape_(tintable)", name = "Cross Shape (Tintable)", catID = "arch_major", file = t("Architecture\\MapArchitecture6"), texCoords = tcCR(8, 3, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "small_cross_shape_(tintable)", name = "Small Cross Shape (Tintable)", catID = "arch_major", file = t("Architecture\\MapArchitecture6"), texCoords = tcCR(1, 4, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "trapezium_shape_(tintable)", name = "Trapezium Shape (Tintable)", catID = "arch_major", file = t("Architecture\\MapArchitecture6"), texCoords = tcCR(2, 4, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "small_trapezium_shape_(tintable)", name = "Small Trapezium Shape (Tintable)", catID = "arch_major", file = t("Architecture\\MapArchitecture6"), texCoords = tcCR(3, 4, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "quarter_circle_shape_(tintable)", name = "Quarter Circle Shape (Tintable)", catID = "arch_major", file = t("Architecture\\MapArchitecture6"), texCoords = tcCR(4, 4, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "small_quarter_circle_shape_(tintable)", name = "Small Quarter Circle Shape (Tintable)", catID = "arch_major", file = t("Architecture\\MapArchitecture6"), texCoords = tcCR(5, 4, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "octagon_shape_(tintable)", name = "Octagon Shape (Tintable)", catID = "arch_major", file = t("Architecture\\MapArchitecture6"), texCoords = tcCR(6, 4, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "small_octagon_shape_(tintable)", name = "Small Octagon Shape (Tintable)", catID = "arch_major", file = t("Architecture\\MapArchitecture6"), texCoords = tcCR(7, 4, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "square_shape_(tintable)", name = "Square Shape (Tintable)", catID = "arch_major", file = t("Architecture\\MapArchitecture6"), texCoords = tcCR(8, 4, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "small_square_shape_(tintable)", name = "Small Square Shape (Tintable)", catID = "arch_major", file = t("Architecture\\MapArchitecture6"), texCoords = tcCR(1, 5, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "thin_rectangle_shape_(tintable)", name = "Thin Rectangle Shape (Tintable)", catID = "arch_major", file = t("Architecture\\MapArchitecture6"), texCoords = tcCR(2, 5, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "rectangle_shape_(tintable)", name = "Rectangle Shape (Tintable)", catID = "arch_major", file = t("Architecture\\MapArchitecture6"), texCoords = tcCR(3, 5, 8, 8, 0, 0, 2, 1), width = p(256, 0), height = p(128, 0) })

	MTM:RegisterDefinition({ id = "small_rectangle_shape_(tintable)", name = "Small Rectangle Shape (Tintable)", catID = "arch_major", file = t("Architecture\\MapArchitecture6"), texCoords = tcCR(5, 5, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })




























	MTM:RegisterDefinition({ id = "camping_tent", name = "Camping Tent", catID = "arch_minor", file = t("Architecture\\MapSprites"), texCoords = tcCR(1, 1, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "enclosed_altar", name = "Enclosed Altar", catID = "arch_minor", file = t("Architecture\\MapSprites"), texCoords = tcCR(2, 1, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "beacon_tower", name = "Beacon Tower", catID = "arch_minor", file = t("Architecture\\MapSprites"), texCoords = tcCR(3, 1, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "tribal_tent_large", name = "Tribal Tent Large", catID = "arch_minor", file = t("Architecture\\MapSprites"), texCoords = tcCR(4, 1, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "large_temple", name = "Large Temple", catID = "arch_minor", file = t("Architecture\\MapSprites"), texCoords = tcCR(5, 1, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "small_temple", name = "Small Temple", catID = "arch_minor", file = t("Architecture\\MapSprites"), texCoords = tcCR(6, 1, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "tribal_tent_small", name = "Tribal Tent Small", catID = "arch_minor", file = t("Architecture\\MapSprites"), texCoords = tcCR(7, 1, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "zandalari_tent", name = "Zandalari Tent", catID = "arch_minor", file = t("Architecture\\MapSprites"), texCoords = tcCR(8, 1, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "spiked_gateway", name = "Spiked Gateway", catID = "arch_minor", file = t("Architecture\\MapSprites"), texCoords = tcCR(1, 2, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "light_temple", name = "Light Temple", catID = "arch_minor", file = t("Architecture\\MapSprites"), texCoords = tcCR(2, 2, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "tribal_tent_huge", name = "Tribal Tent Huge", catID = "arch_minor", file = t("Architecture\\MapSprites"), texCoords = tcCR(3, 2, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "jagged_rock", name = "Jagged Rock", catID = "arch_minor", file = t("Architecture\\MapSprites"), texCoords = tcCR(4, 2, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "orcish_houses", name = "Orcish Houses", catID = "arch_minor", file = t("Architecture\\MapSprites"), texCoords = tcCR(5, 2, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "windmill", name = "Windmill", catID = "arch_minor", file = t("Architecture\\MapSprites"), texCoords = tcCR(6, 2, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "human_house_medium", name = "Human House Medium", catID = "arch_minor", file = t("Architecture\\MapSprites"), texCoords = tcCR(7, 2, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "human_house_small", name = "Human House SMall", catID = "arch_minor", file = t("Architecture\\MapSprites"), texCoords = tcCR(8, 2, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "ethereal_manaforge", name = "Ethereal Manaforge", catID = "arch_minor", file = t("Architecture\\MapSprites"), texCoords = tcCR(1, 3, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "hot_air_balloon", name = "Hot Air Balloon", catID = "arch_minor", file = t("Architecture\\MapSprites"), texCoords = tcCR(2, 3, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "draenei_crystal", name = "Draenei Crystal", catID = "arch_minor", file = t("Architecture\\MapSprites"), texCoords = tcCR(3, 3, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "ardenweald_tree_canopy", name = "Ardenweald Tree Canopy", catID = "arch_minor", file = t("Architecture\\MapSprites"), texCoords = tcCR(4, 3, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "centaur_tent", name = "Centaur Tent", catID = "arch_minor", file = t("Architecture\\MapSprites"), texCoords = tcCR(5, 3, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "ethereal_home", name = "Ethereal Home", catID = "arch_minor", file = t("Architecture\\MapSprites"), texCoords = tcCR(6, 3, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "quilboar_roots", name = "Quilboar Roots", catID = "arch_minor", file = t("Architecture\\MapSprites"), texCoords = tcCR(7, 3, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "large_tree", name = "Large Tree", catID = "arch_minor", file = t("Architecture\\MapSprites"), texCoords = tcCR(8, 3, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "large_town", name = "Large Town", catID = "arch_minor", file = t("Architecture\\MapSprites"), texCoords = tcCR(1, 4, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "blood_elven_tower", name = "Blood Elven Tower", catID = "arch_minor", file = t("Architecture\\MapSprites"), texCoords = tcCR(2, 4, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "draenei_mine_entrance", name = "Draenei Mine Entrance", catID = "arch_minor", file = t("Architecture\\MapSprites"), texCoords = tcCR(3, 4, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "draenei_home", name = "Draenei Home", catID = "arch_minor", file = t("Architecture\\MapSprites"), texCoords = tcCR(4, 4, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "round_tower", name = "Round Tower", catID = "arch_minor", file = t("Architecture\\MapSprites"), texCoords = tcCR(5, 4, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "flying_necropolis", name = "Flying Necropolis", catID = "arch_minor", file = t("Architecture\\MapSprites"), texCoords = tcCR(6, 4, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "spiked_tower", name = "Spiked Tower", catID = "arch_minor", file = t("Architecture\\MapSprites"), texCoords = tcCR(7, 4, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "dragon", name = "Dragon", catID = "arch_minor", file = t("Architecture\\MapSprites"), texCoords = tcCR(8, 4, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "void_beacon", name = "Void Beacon", catID = "arch_minor", file = t("Architecture\\MapSprites"), texCoords = tcCR(1, 5, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "void_tower", name = "Void Tower", catID = "arch_minor", file = t("Architecture\\MapSprites"), texCoords = tcCR(2, 5, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "void_stronghold", name = "Void Stronghold", catID = "arch_minor", file = t("Architecture\\MapSprites"), texCoords = tcCR(3, 5, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "wild_elf_hut_1", name = "Wild Elf Hut 1", catID = "arch_minor", file = t("Architecture\\MapSprites"), texCoords = tcCR(4, 5, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "wild_elf_hut_2", name = "Wild Elf Hut 2", catID = "arch_minor", file = t("Architecture\\MapSprites"), texCoords = tcCR(5, 5, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "legion_outpost", name = "Legion Outpost", catID = "arch_minor", file = t("Architecture\\MapSprites"), texCoords = tcCR(6, 5, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "legion_spire", name = "Legion Spire", catID = "arch_minor", file = t("Architecture\\MapSprites"), texCoords = tcCR(7, 5, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "mushroom_cluster_1", name = "Mushroom Cluster 1", catID = "arch_minor", file = t("Architecture\\MapSprites"), texCoords = tcCR(8, 5, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "mushroom_cluster_2", name = "Mushroom Cluster 2", catID = "arch_minor", file = t("Architecture\\MapSprites"), texCoords = tcCR(1, 6, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
























	MTM:RegisterDefinition({ id = "troll_raid_entrance", name = "Troll Raid Entrance", catID = "arch_major", file = t("Architecture\\MapBigArchitecture"), texCoords = tcCR(1, 1, 4, 4, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "ulduar_icy", name = "Ulduar Icy", catID = "arch_major", file = t("Architecture\\MapBigArchitecture"), texCoords = tcCR(2, 1, 4, 4, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "ulduar", name = "Ulduar", catID = "arch_major", file = t("Architecture\\MapBigArchitecture"), texCoords = tcCR(3, 1, 4, 4, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "blood_elven_complex", name = "Blood Elven Complex", catID = "arch_major", file = t("Architecture\\MapBigArchitecture"), texCoords = tcCR(4, 1, 4, 4, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "tempest_keep", name = "Tempest Keep", catID = "arch_major", file = t("Architecture\\MapBigArchitecture"), texCoords = tcCR(1, 2, 4, 4, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "dalaran", name = "Dalaran", catID = "arch_major", file = t("Architecture\\MapBigArchitecture"), texCoords = tcCR(2, 2, 4, 4, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "temple_of_sethraliss", name = "Temple of Sethraliss", catID = "arch_major", file = t("Architecture\\MapBigArchitecture"), texCoords = tcCR(3, 2, 4, 4, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "maelstrom", name = "Maelstrom", catID = "arch_major", file = t("Architecture\\MapBigArchitecture"), texCoords = tcCR(4, 2, 4, 4, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "kul_tiran_castle", name = "Kul Tiran Castle", catID = "arch_major", file = t("Architecture\\MapBigArchitecture"), texCoords = tcCR(1, 3, 4, 4, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "arathi_castle", name = "Arathi Castle", catID = "arch_major", file = t("Architecture\\MapBigArchitecture"), texCoords = tcCR(2, 3, 4, 4, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "ardenweald_dream_tree", name = "Ardenweald Dream Tree", catID = "arch_major", file = t("Architecture\\MapBigArchitecture"), texCoords = tcCR(3, 3, 4, 4, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "venthyr_gargoyle", name = "Venthyr Gargoyle", catID = "arch_major", file = t("Architecture\\MapBigArchitecture"), texCoords = tcCR(4, 3, 4, 4, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "map_name_banner", name = "Map Name Banner", catID = "textart", file = t("Architecture\\MapBigArchitecture"), texCoords = tcCR(1, 4, 4, 4, 0, 0, 2, 1), width = p(128, 0), height = p(64, 0) })

	MTM:RegisterDefinition({ id = "waycrest_manor", name = "Waycrest Manor", catID = "arch_major", file = t("Architecture\\MapBigArchitecture"), texCoords = tcCR(3, 4, 4, 4, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "dark_portal", name = "Dark Portal", catID = "arch_major", file = t("Architecture\\MapBigArchitecture"), texCoords = tcCR(4, 4, 4, 4, 0, 0), width = p(128, 0), height = p(128, 0) })

	MTM:RegisterDefinition({ id = "large_draenei_temple", name = "Large Draenei Temple", catID = "arch_major", file = t("Architecture\\MapBigArchitecture2"), texCoords = tcCR(1, 1, 4, 4, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "large_goblin_casino", name = "Large Goblin Casino", catID = "arch_major", file = t("Architecture\\MapBigArchitecture2"), texCoords = tcCR(2, 1, 4, 4, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "kul_tiran_prison", name = "Kul Tiran Prison", catID = "arch_major", file = t("Architecture\\MapBigArchitecture2"), texCoords = tcCR(3, 1, 4, 4, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "large_first_ones_ruin", name = "Large First Ones Ruin", catID = "arch_major", file = t("Architecture\\MapBigArchitecture2"), texCoords = tcCR(4, 1, 4, 4, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "large_pandaren_gate", name = "Large Pandaren Gate", catID = "arch_major", file = t("Architecture\\MapBigArchitecture2"), texCoords = tcCR(1, 2, 4, 4, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "large_earthen_dwarf_keep", name = "Large Earthen Dwarf Keep", catID = "arch_major", file = t("Architecture\\MapBigArchitecture2"), texCoords = tcCR(2, 2, 4, 4, 0, 0), width = p(128, 0), height = p(128, 0) })











	MTM:RegisterDefinition({ id = "islet_1", name = "Islet 1", catID = "edges", file = t("MountainRidges\\MapEdges"), texCoords = tcCR(1, 1, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "islet_2", name = "Islet 2", catID = "edges", file = t("MountainRidges\\MapEdges"), texCoords = tcCR(2, 1, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "islet_3", name = "Islet 3", catID = "edges", file = t("MountainRidges\\MapEdges"), texCoords = tcCR(3, 1, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })





	MTM:RegisterDefinition({ id = "edge_1", name = "Edge 1", catID = "edges", file = t("MountainRidges\\MapEdges"), texCoords = tcCR(1, 2, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "edge_2", name = "Edge 2", catID = "edges", file = t("MountainRidges\\MapEdges"), texCoords = tcCR(2, 2, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "edge_3", name = "Edge 3", catID = "edges", file = t("MountainRidges\\MapEdges"), texCoords = tcCR(3, 2, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "edge_4", name = "Edge 4", catID = "edges", file = t("MountainRidges\\MapEdges"), texCoords = tcCR(4, 2, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "edge_5", name = "Edge 5", catID = "edges", file = t("MountainRidges\\MapEdges"), texCoords = tcCR(5, 2, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "edge_6", name = "Edge 6", catID = "edges", file = t("MountainRidges\\MapEdges"), texCoords = tcCR(6, 2, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "edge_7", name = "Edge 7", catID = "edges", file = t("MountainRidges\\MapEdges"), texCoords = tcCR(7, 2, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "edge_8", name = "Edge 8", catID = "edges", file = t("MountainRidges\\MapEdges"), texCoords = tcCR(8, 2, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "edge_9", name = "Edge 9", catID = "edges", file = t("MountainRidges\\MapEdges"), texCoords = tcCR(1, 3, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "edge_10", name = "Edge 10", catID = "edges", file = t("MountainRidges\\MapEdges"), texCoords = tcCR(2, 3, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "edge_11", name = "Edge 11", catID = "edges", file = t("MountainRidges\\MapEdges"), texCoords = tcCR(3, 3, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "edge_12", name = "Edge 12", catID = "edges", file = t("MountainRidges\\MapEdges"), texCoords = tcCR(4, 3, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "edge_13", name = "Edge 13", catID = "edges", file = t("MountainRidges\\MapEdges"), texCoords = tcCR(5, 3, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "edge_14", name = "Edge 14", catID = "edges", file = t("MountainRidges\\MapEdges"), texCoords = tcCR(6, 3, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "edge_15", name = "Edge 15", catID = "edges", file = t("MountainRidges\\MapEdges"), texCoords = tcCR(7, 3, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "edge_16", name = "Edge 16", catID = "edges", file = t("MountainRidges\\MapEdges"), texCoords = tcCR(8, 3, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "edge_17", name = "Edge 17", catID = "edges", file = t("MountainRidges\\MapEdges"), texCoords = tcCR(1, 4, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "edge_18", name = "Edge 18", catID = "edges", file = t("MountainRidges\\MapEdges"), texCoords = tcCR(2, 4, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "edge_19", name = "Edge 19", catID = "edges", file = t("MountainRidges\\MapEdges"), texCoords = tcCR(3, 4, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "edge_20", name = "Edge 20", catID = "edges", file = t("MountainRidges\\MapEdges"), texCoords = tcCR(4, 4, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "edge_21", name = "Edge 21", catID = "edges", file = t("MountainRidges\\MapEdges"), texCoords = tcCR(5, 4, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "edge_22", name = "Edge 22", catID = "edges", file = t("MountainRidges\\MapEdges"), texCoords = tcCR(6, 4, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "edge_23", name = "Edge 23", catID = "edges", file = t("MountainRidges\\MapEdges"), texCoords = tcCR(7, 4, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "edge_24", name = "Edge 24", catID = "edges", file = t("MountainRidges\\MapEdges"), texCoords = tcCR(8, 4, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "edge_25", name = "Edge 25", catID = "edges", file = t("MountainRidges\\MapEdges"), texCoords = tcCR(1, 5, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "edge_26", name = "Edge 26", catID = "edges", file = t("MountainRidges\\MapEdges"), texCoords = tcCR(2, 5, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })














	MTM:RegisterDefinition({ id = "epsi_edge_1", name = "Epsi Edge 1", catID = "edges", file = t("MountainRidges\\MapEdges"), texCoords = tcCR(1, 7, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "epsi_edge_2", name = "Epsi Edge 2", catID = "edges", file = t("MountainRidges\\MapEdges"), texCoords = tcCR(2, 7, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "epsi_edge_3", name = "Epsi Edge 3", catID = "edges", file = t("MountainRidges\\MapEdges"), texCoords = tcCR(3, 7, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "epsi_edge_4", name = "Epsi Edge 4", catID = "edges", file = t("MountainRidges\\MapEdges"), texCoords = tcCR(4, 7, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "epsi_edge_5", name = "Epsi Edge 5", catID = "edges", file = t("MountainRidges\\MapEdges"), texCoords = tcCR(5, 7, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "epsi_edge_6", name = "Epsi Edge 6", catID = "edges", file = t("MountainRidges\\MapEdges"), texCoords = tcCR(6, 7, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "epsi_edge_7", name = "Epsi Edge 7", catID = "edges", file = t("MountainRidges\\MapEdges"), texCoords = tcCR(7, 7, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })











	MTM:RegisterDefinition({ id = "mountain_tile_1_(tl)", name = "Mountain Tile 1 (TL)", catID = "mountains", file = t("MountainRidges\\MapMountains"), texCoords = tcCR(1, 1, 4, 4, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "mountain_tile_2_(tr)", name = "Mountain Tile 2 (TR)", catID = "mountains", file = t("MountainRidges\\MapMountains"), texCoords = tcCR(2, 1, 4, 4, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "mountain_tile_3_(bl)", name = "Mountain Tile 3 (BL)", catID = "mountains", file = t("MountainRidges\\MapMountains"), texCoords = tcCR(3, 1, 4, 4, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "mountain_tile_4_(br)", name = "Mountain Tile 4 (BR)", catID = "mountains", file = t("MountainRidges\\MapMountains"), texCoords = tcCR(4, 1, 4, 4, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "mountain_tile_5", name = "Mountain Tile 5", catID = "mountains", file = t("MountainRidges\\MapMountains"), texCoords = tcCR(1, 2, 4, 4, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "mountain_tile_6", name = "Mountain Tile 6", catID = "mountains", file = t("MountainRidges\\MapMountains"), texCoords = tcCR(2, 2, 4, 4, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "mountain_tile_7", name = "Mountain Tile 7", catID = "mountains", file = t("MountainRidges\\MapMountains"), texCoords = tcCR(3, 2, 4, 4, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "mountain_tile_8", name = "Mountain Tile 8", catID = "mountains", file = t("MountainRidges\\MapMountains"), texCoords = tcCR(4, 2, 4, 4, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "mountain_tile_9", name = "Mountain Tile 9", catID = "mountains", file = t("MountainRidges\\MapMountains"), texCoords = tcCR(1, 3, 4, 4, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "mountain_tile_10", name = "Mountain Tile 10", catID = "mountains", file = t("MountainRidges\\MapMountains"), texCoords = tcCR(2, 3, 4, 4, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "mountain_tile_11", name = "Mountain Tile 11", catID = "mountains", file = t("MountainRidges\\MapMountains"), texCoords = tcCR(3, 3, 4, 4, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "mountain_tile_12", name = "Mountain Tile 12", catID = "mountains", file = t("MountainRidges\\MapMountains"), texCoords = tcCR(4, 3, 4, 4, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "floating_island_1", name = "Floating Island 1", catID = "mountains", file = t("MountainRidges\\MapMountains"), texCoords = tcCR(1, 4, 4, 4, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "floating_island_2", name = "Floating Island 2", catID = "mountains", file = t("MountainRidges\\MapMountains"), texCoords = tcCR(2, 4, 4, 4, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "mountain_peak_1", name = "Mountain Peak 1", catID = "mountains", file = t("MountainRidges\\MapMountains"), texCoords = tcCR(3, 4, 4, 4, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "mountain_peak_2", name = "Mountain Peak 2", catID = "mountains", file = t("MountainRidges\\MapMountains"), texCoords = tcCR(4, 4, 4, 4, 0, 0), width = p(128, 0), height = p(128, 0) })

	MTM:RegisterDefinition({ id = "ridge_1", name = "Ridge 1", catID = "ridges", file = t("MountainRidges\\MapRidges"), texCoords = tcCR(1, 1, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "ridge_2", name = "Ridge 2", catID = "ridges", file = t("MountainRidges\\MapRidges"), texCoords = tcCR(2, 1, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "ridge_3", name = "Ridge 3", catID = "ridges", file = t("MountainRidges\\MapRidges"), texCoords = tcCR(3, 1, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "ridge_4", name = "Ridge 4", catID = "ridges", file = t("MountainRidges\\MapRidges"), texCoords = tcCR(4, 1, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "ridge_5", name = "Ridge 5", catID = "ridges", file = t("MountainRidges\\MapRidges"), texCoords = tcCR(5, 1, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "ridge_6", name = "Ridge 6", catID = "ridges", file = t("MountainRidges\\MapRidges"), texCoords = tcCR(6, 1, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "ridge_7", name = "Ridge 7", catID = "ridges", file = t("MountainRidges\\MapRidges"), texCoords = tcCR(7, 1, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "ridge_8", name = "Ridge 8", catID = "ridges", file = t("MountainRidges\\MapRidges"), texCoords = tcCR(8, 1, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "ridge_9", name = "Ridge 9", catID = "ridges", file = t("MountainRidges\\MapRidges"), texCoords = tcCR(1, 2, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "ridge_10", name = "Ridge 10", catID = "ridges", file = t("MountainRidges\\MapRidges"), texCoords = tcCR(2, 2, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "ridge_11", name = "Ridge 11", catID = "ridges", file = t("MountainRidges\\MapRidges"), texCoords = tcCR(3, 2, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "ridge_12", name = "Ridge 12", catID = "ridges", file = t("MountainRidges\\MapRidges"), texCoords = tcCR(4, 2, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "ridge_13", name = "Ridge 13", catID = "ridges", file = t("MountainRidges\\MapRidges"), texCoords = tcCR(5, 2, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "ridge_14", name = "Ridge 14", catID = "ridges", file = t("MountainRidges\\MapRidges"), texCoords = tcCR(6, 2, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "ridge_15", name = "Ridge 15", catID = "ridges", file = t("MountainRidges\\MapRidges"), texCoords = tcCR(7, 2, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "ridge_16", name = "Ridge 16", catID = "ridges", file = t("MountainRidges\\MapRidges"), texCoords = tcCR(8, 2, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "ridge_17", name = "Ridge 17", catID = "ridges", file = t("MountainRidges\\MapRidges"), texCoords = tcCR(1, 3, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "ridge_18", name = "Ridge 18", catID = "ridges", file = t("MountainRidges\\MapRidges"), texCoords = tcCR(2, 3, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "ridge_19", name = "Ridge 19", catID = "ridges", file = t("MountainRidges\\MapRidges"), texCoords = tcCR(3, 3, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "ridge_20", name = "Ridge 20", catID = "ridges", file = t("MountainRidges\\MapRidges"), texCoords = tcCR(4, 3, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "ridge_21", name = "Ridge 21", catID = "ridges", file = t("MountainRidges\\MapRidges"), texCoords = tcCR(5, 3, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "ridge_22", name = "Ridge 22", catID = "ridges", file = t("MountainRidges\\MapRidges"), texCoords = tcCR(6, 3, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "ridge_23", name = "Ridge 23", catID = "ridges", file = t("MountainRidges\\MapRidges"), texCoords = tcCR(7, 3, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "ridge_24", name = "Ridge 24", catID = "ridges", file = t("MountainRidges\\MapRidges"), texCoords = tcCR(8, 3, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "ridge_25", name = "Ridge 25", catID = "ridges", file = t("MountainRidges\\MapRidges"), texCoords = tcCR(1, 4, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "ridge_26", name = "Ridge 26", catID = "ridges", file = t("MountainRidges\\MapRidges"), texCoords = tcCR(2, 4, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "ridge_27", name = "Ridge 27", catID = "ridges", file = t("MountainRidges\\MapRidges"), texCoords = tcCR(3, 4, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "ridge_28", name = "Ridge 28", catID = "ridges", file = t("MountainRidges\\MapRidges"), texCoords = tcCR(4, 4, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "ridge_29", name = "Ridge 29", catID = "ridges", file = t("MountainRidges\\MapRidges"), texCoords = tcCR(5, 4, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "ridge_30", name = "Ridge 30", catID = "ridges", file = t("MountainRidges\\MapRidges"), texCoords = tcCR(6, 4, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "ridge_31", name = "Ridge 31", catID = "ridges", file = t("MountainRidges\\MapRidges"), texCoords = tcCR(7, 4, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "ridge_32", name = "Ridge 32", catID = "ridges", file = t("MountainRidges\\MapRidges"), texCoords = tcCR(8, 4, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "ridge_33", name = "Ridge 33", catID = "ridges", file = t("MountainRidges\\MapRidges"), texCoords = tcCR(1, 5, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "ridge_34", name = "Ridge 34", catID = "ridges", file = t("MountainRidges\\MapRidges"), texCoords = tcCR(2, 5, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "ridge_35", name = "Ridge 35", catID = "ridges", file = t("MountainRidges\\MapRidges"), texCoords = tcCR(3, 5, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "ridge_36", name = "Ridge 36", catID = "ridges", file = t("MountainRidges\\MapRidges"), texCoords = tcCR(4, 5, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "ridge_37", name = "Ridge 37", catID = "ridges", file = t("MountainRidges\\MapRidges"), texCoords = tcCR(5, 5, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "ridge_38", name = "Ridge 38", catID = "ridges", file = t("MountainRidges\\MapRidges"), texCoords = tcCR(6, 5, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "ridge_39", name = "Ridge 39", catID = "ridges", file = t("MountainRidges\\MapRidges"), texCoords = tcCR(7, 5, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "ridge_40", name = "Ridge 40", catID = "ridges", file = t("MountainRidges\\MapRidges"), texCoords = tcCR(8, 5, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "ridge_41", name = "Ridge 41", catID = "ridges", file = t("MountainRidges\\MapRidges"), texCoords = tcCR(1, 6, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "ridge_42", name = "Ridge 42", catID = "ridges", file = t("MountainRidges\\MapRidges"), texCoords = tcCR(2, 6, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "ridge_43", name = "Ridge 43", catID = "ridges", file = t("MountainRidges\\MapRidges"), texCoords = tcCR(3, 6, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "ridge_44", name = "Ridge 44", catID = "ridges", file = t("MountainRidges\\MapRidges"), texCoords = tcCR(4, 6, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "ridge_45", name = "Ridge 45", catID = "ridges", file = t("MountainRidges\\MapRidges"), texCoords = tcCR(5, 6, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "ridge_46", name = "Ridge 46", catID = "ridges", file = t("MountainRidges\\MapRidges"), texCoords = tcCR(6, 6, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "ridge_47", name = "Ridge 47", catID = "ridges", file = t("MountainRidges\\MapRidges"), texCoords = tcCR(7, 6, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "ridge_48", name = "Ridge 48", catID = "ridges", file = t("MountainRidges\\MapRidges"), texCoords = tcCR(8, 6, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })

















	MTM:RegisterDefinition({ id = "water_1", name = "Water 1", catID = "rivers", file = t("Rivers\\MapLiquidWater"), texCoords = tcCR(1, 1, 4, 4, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "water_2", name = "Water 2", catID = "rivers", file = t("Rivers\\MapLiquidWater"), texCoords = tcCR(2, 1, 4, 4, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "water_3", name = "Water 3", catID = "rivers", file = t("Rivers\\MapLiquidWater"), texCoords = tcCR(3, 1, 4, 4, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "water_4", name = "Water 4", catID = "rivers", file = t("Rivers\\MapLiquidWater"), texCoords = tcCR(4, 1, 4, 4, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "water_5", name = "Water 5", catID = "rivers", file = t("Rivers\\MapLiquidWater"), texCoords = tcCR(1, 2, 4, 4, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "water_6", name = "Water 6", catID = "rivers", file = t("Rivers\\MapLiquidWater"), texCoords = tcCR(2, 2, 4, 4, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "water_7", name = "Water 7", catID = "rivers", file = t("Rivers\\MapLiquidWater"), texCoords = tcCR(3, 2, 4, 4, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "water_8", name = "Water 8", catID = "rivers", file = t("Rivers\\MapLiquidWater"), texCoords = tcCR(4, 2, 4, 4, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "water_9", name = "Water 9", catID = "rivers", file = t("Rivers\\MapLiquidWater"), texCoords = tcCR(1, 3, 4, 4, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "water_10", name = "Water 10", catID = "rivers", file = t("Rivers\\MapLiquidWater"), texCoords = tcCR(2, 3, 4, 4, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "water_11", name = "Water 11", catID = "rivers", file = t("Rivers\\MapLiquidWater"), texCoords = tcCR(3, 3, 4, 4, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "water_12", name = "Water 12", catID = "rivers", file = t("Rivers\\MapLiquidWater"), texCoords = tcCR(4, 3, 4, 4, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "water_13", name = "Water 13", catID = "rivers", file = t("Rivers\\MapLiquidWater"), texCoords = tcCR(1, 4, 4, 4, 0, 0), width = p(128, 0), height = p(128, 0) })




	MTM:RegisterDefinition({ id = "dark_water_1", name = "Dark Water 1", catID = "rivers", file = t("Rivers\\MapLiquidDarkWater"), texCoords = tcCR(1, 1, 4, 4, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "dark_water_2", name = "Dark Water 2", catID = "rivers", file = t("Rivers\\MapLiquidDarkWater"), texCoords = tcCR(2, 1, 4, 4, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "dark_water_3", name = "Dark Water 3", catID = "rivers", file = t("Rivers\\MapLiquidDarkWater"), texCoords = tcCR(3, 1, 4, 4, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "dark_water_4", name = "Dark Water 4", catID = "rivers", file = t("Rivers\\MapLiquidDarkWater"), texCoords = tcCR(4, 1, 4, 4, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "dark_water_5", name = "Dark Water 5", catID = "rivers", file = t("Rivers\\MapLiquidDarkWater"), texCoords = tcCR(1, 2, 4, 4, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "dark_water_6", name = "Dark Water 6", catID = "rivers", file = t("Rivers\\MapLiquidDarkWater"), texCoords = tcCR(2, 2, 4, 4, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "dark_water_7", name = "Dark Water 7", catID = "rivers", file = t("Rivers\\MapLiquidDarkWater"), texCoords = tcCR(3, 2, 4, 4, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "dark_water_8", name = "Dark Water 8", catID = "rivers", file = t("Rivers\\MapLiquidDarkWater"), texCoords = tcCR(4, 2, 4, 4, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "dark_water_9", name = "Dark Water 9", catID = "rivers", file = t("Rivers\\MapLiquidDarkWater"), texCoords = tcCR(1, 3, 4, 4, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "dark_water_10", name = "Dark Water 10", catID = "rivers", file = t("Rivers\\MapLiquidDarkWater"), texCoords = tcCR(2, 3, 4, 4, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "dark_water_11", name = "Dark Water 11", catID = "rivers", file = t("Rivers\\MapLiquidDarkWater"), texCoords = tcCR(3, 3, 4, 4, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "dark_water_12", name = "Dark Water 12", catID = "rivers", file = t("Rivers\\MapLiquidDarkWater"), texCoords = tcCR(4, 3, 4, 4, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "dark_water_13", name = "Dark Water 13", catID = "rivers", file = t("Rivers\\MapLiquidDarkWater"), texCoords = tcCR(1, 4, 4, 4, 0, 0), width = p(128, 0), height = p(128, 0) })




	MTM:RegisterDefinition({ id = "lava_1", name = "Lava 1", catID = "rivers", file = t("Rivers\\MapLiquidLava"), texCoords = tcCR(1, 1, 4, 4, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "lava_2", name = "Lava 2", catID = "rivers", file = t("Rivers\\MapLiquidLava"), texCoords = tcCR(2, 1, 4, 4, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "lava_3", name = "Lava 3", catID = "rivers", file = t("Rivers\\MapLiquidLava"), texCoords = tcCR(3, 1, 4, 4, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "lava_4", name = "Lava 4", catID = "rivers", file = t("Rivers\\MapLiquidLava"), texCoords = tcCR(4, 1, 4, 4, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "lava_5", name = "Lava 5", catID = "rivers", file = t("Rivers\\MapLiquidLava"), texCoords = tcCR(1, 2, 4, 4, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "lava_6", name = "Lava 6", catID = "rivers", file = t("Rivers\\MapLiquidLava"), texCoords = tcCR(2, 2, 4, 4, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "lava_7", name = "Lava 7", catID = "rivers", file = t("Rivers\\MapLiquidLava"), texCoords = tcCR(3, 2, 4, 4, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "lava_8", name = "Lava 8", catID = "rivers", file = t("Rivers\\MapLiquidLava"), texCoords = tcCR(4, 2, 4, 4, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "lava_9", name = "Lava 9", catID = "rivers", file = t("Rivers\\MapLiquidLava"), texCoords = tcCR(1, 3, 4, 4, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "lava_10", name = "Lava 10", catID = "rivers", file = t("Rivers\\MapLiquidLava"), texCoords = tcCR(2, 3, 4, 4, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "lava_11", name = "Lava 11", catID = "rivers", file = t("Rivers\\MapLiquidLava"), texCoords = tcCR(3, 3, 4, 4, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "lava_12", name = "Lava 12", catID = "rivers", file = t("Rivers\\MapLiquidLava"), texCoords = tcCR(4, 3, 4, 4, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "lava_13", name = "Lava 13", catID = "rivers", file = t("Rivers\\MapLiquidLava"), texCoords = tcCR(1, 4, 4, 4, 0, 0), width = p(128, 0), height = p(128, 0) })




	MTM:RegisterDefinition({ id = "pink_water_1", name = "Pink Water 1", catID = "rivers", file = t("Rivers\\MapLiquidPink"), texCoords = tcCR(1, 1, 4, 4, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "pink_water_2", name = "Pink Water 2", catID = "rivers", file = t("Rivers\\MapLiquidPink"), texCoords = tcCR(2, 1, 4, 4, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "pink_water_3", name = "Pink Water 3", catID = "rivers", file = t("Rivers\\MapLiquidPink"), texCoords = tcCR(3, 1, 4, 4, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "pink_water_4", name = "Pink Water 4", catID = "rivers", file = t("Rivers\\MapLiquidPink"), texCoords = tcCR(4, 1, 4, 4, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "pink_water_5", name = "Pink Water 5", catID = "rivers", file = t("Rivers\\MapLiquidPink"), texCoords = tcCR(1, 2, 4, 4, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "pink_water_6", name = "Pink Water 6", catID = "rivers", file = t("Rivers\\MapLiquidPink"), texCoords = tcCR(2, 2, 4, 4, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "pink_water_7", name = "Pink Water 7", catID = "rivers", file = t("Rivers\\MapLiquidPink"), texCoords = tcCR(3, 2, 4, 4, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "pink_water_8", name = "Pink Water 8", catID = "rivers", file = t("Rivers\\MapLiquidPink"), texCoords = tcCR(4, 2, 4, 4, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "pink_water_9", name = "Pink Water 9", catID = "rivers", file = t("Rivers\\MapLiquidPink"), texCoords = tcCR(1, 3, 4, 4, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "pink_water_10", name = "Pink Water 10", catID = "rivers", file = t("Rivers\\MapLiquidPink"), texCoords = tcCR(2, 3, 4, 4, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "pink_water_11", name = "Pink Water 11", catID = "rivers", file = t("Rivers\\MapLiquidPink"), texCoords = tcCR(3, 3, 4, 4, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "pink_water_12", name = "Pink Water 12", catID = "rivers", file = t("Rivers\\MapLiquidPink"), texCoords = tcCR(4, 3, 4, 4, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "pink_water_13", name = "Pink Water 13", catID = "rivers", file = t("Rivers\\MapLiquidPink"), texCoords = tcCR(1, 4, 4, 4, 0, 0), width = p(128, 0), height = p(128, 0) })




	MTM:RegisterDefinition({ id = "slime_1", name = "Slime 1", catID = "rivers", file = t("Rivers\\MapLiquidSlime"), texCoords = tcCR(1, 1, 4, 4, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "slime_2", name = "Slime 2", catID = "rivers", file = t("Rivers\\MapLiquidSlime"), texCoords = tcCR(2, 1, 4, 4, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "slime_3", name = "Slime 3", catID = "rivers", file = t("Rivers\\MapLiquidSlime"), texCoords = tcCR(3, 1, 4, 4, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "slime_4", name = "Slime 4", catID = "rivers", file = t("Rivers\\MapLiquidSlime"), texCoords = tcCR(4, 1, 4, 4, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "slime_5", name = "Slime 5", catID = "rivers", file = t("Rivers\\MapLiquidSlime"), texCoords = tcCR(1, 2, 4, 4, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "slime_6", name = "Slime 6", catID = "rivers", file = t("Rivers\\MapLiquidSlime"), texCoords = tcCR(2, 2, 4, 4, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "slime_7", name = "Slime 7", catID = "rivers", file = t("Rivers\\MapLiquidSlime"), texCoords = tcCR(3, 2, 4, 4, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "slime_8", name = "Slime 8", catID = "rivers", file = t("Rivers\\MapLiquidSlime"), texCoords = tcCR(4, 2, 4, 4, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "slime_9", name = "Slime 9", catID = "rivers", file = t("Rivers\\MapLiquidSlime"), texCoords = tcCR(1, 3, 4, 4, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "slime_10", name = "Slime 10", catID = "rivers", file = t("Rivers\\MapLiquidSlime"), texCoords = tcCR(2, 3, 4, 4, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "slime_11", name = "Slime 11", catID = "rivers", file = t("Rivers\\MapLiquidSlime"), texCoords = tcCR(3, 3, 4, 4, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "slime_12", name = "Slime 12", catID = "rivers", file = t("Rivers\\MapLiquidSlime"), texCoords = tcCR(4, 3, 4, 4, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "slime_13", name = "Slime 13", catID = "rivers", file = t("Rivers\\MapLiquidSlime"), texCoords = tcCR(1, 4, 4, 4, 0, 0), width = p(128, 0), height = p(128, 0) })





	MTM:RegisterDefinition({ id = "plant_1", name = "Plant 1", catID = "foliage", file = t("MapPlants"), texCoords = tcCR(1, 1, 16, 16, 0, 0), width = p(64, 0), height = p(64, 0) })
	MTM:RegisterDefinition({ id = "plant_2", name = "Plant 2", catID = "foliage", file = t("MapPlants"), texCoords = tcCR(2, 1, 16, 16, 0, 0), width = p(64, 0), height = p(64, 0) })
	MTM:RegisterDefinition({ id = "plant_3", name = "Plant 3", catID = "foliage", file = t("MapPlants"), texCoords = tcCR(3, 1, 16, 16, 0, 0), width = p(64, 0), height = p(64, 0) })
	MTM:RegisterDefinition({ id = "plant_4", name = "Plant 4", catID = "foliage", file = t("MapPlants"), texCoords = tcCR(4, 1, 16, 16, 0, 0), width = p(64, 0), height = p(64, 0) })
	MTM:RegisterDefinition({ id = "plant_5", name = "Plant 5", catID = "foliage", file = t("MapPlants"), texCoords = tcCR(5, 1, 16, 16, 0, 0), width = p(64, 0), height = p(64, 0) })
	MTM:RegisterDefinition({ id = "plant_6", name = "Plant 6", catID = "foliage", file = t("MapPlants"), texCoords = tcCR(6, 1, 16, 16, 0, 0), width = p(64, 0), height = p(64, 0) })
	MTM:RegisterDefinition({ id = "plant_7", name = "Plant 7", catID = "foliage", file = t("MapPlants"), texCoords = tcCR(7, 1, 16, 16, 0, 0), width = p(64, 0), height = p(64, 0) })
	MTM:RegisterDefinition({ id = "plant_8", name = "Plant 8", catID = "foliage", file = t("MapPlants"), texCoords = tcCR(8, 1, 16, 16, 0, 0), width = p(64, 0), height = p(64, 0) })
	MTM:RegisterDefinition({ id = "plant_9", name = "Plant 9", catID = "foliage", file = t("MapPlants"), texCoords = tcCR(9, 1, 16, 16, 0, 0), width = p(64, 0), height = p(64, 0) })
	MTM:RegisterDefinition({ id = "plant_10", name = "Plant 10", catID = "foliage", file = t("MapPlants"), texCoords = tcCR(10, 1, 16, 16, 0, 0), width = p(64, 0), height = p(64, 0) })
	MTM:RegisterDefinition({ id = "plant_11", name = "Plant 11", catID = "foliage", file = t("MapPlants"), texCoords = tcCR(11, 1, 16, 16, 0, 0), width = p(64, 0), height = p(64, 0) })
	MTM:RegisterDefinition({ id = "emerald_plant_1", name = "Emerald Plant 1", catID = "foliage", file = t("MapPlants"), texCoords = tcCR(12, 1, 16, 16, 0, 0), width = p(64, 0), height = p(64, 0) })
	MTM:RegisterDefinition({ id = "emerald_plant_2", name = "Emerald Plant 2", catID = "foliage", file = t("MapPlants"), texCoords = tcCR(13, 1, 16, 16, 0, 0), width = p(64, 0), height = p(64, 0) })
	MTM:RegisterDefinition({ id = "emerald_plant_3", name = "Emerald Plant 3", catID = "foliage", file = t("MapPlants"), texCoords = tcCR(14, 1, 16, 16, 0, 0), width = p(64, 0), height = p(64, 0) })
	MTM:RegisterDefinition({ id = "emerald_plant_4", name = "Emerald Plant 4", catID = "foliage", file = t("MapPlants"), texCoords = tcCR(15, 1, 16, 16, 0, 0), width = p(64, 0), height = p(64, 0) })
	MTM:RegisterDefinition({ id = "emerald_plant_5", name = "Emerald Plant 5", catID = "foliage", file = t("MapPlants"), texCoords = tcCR(16, 1, 16, 16, 0, 0), width = p(64, 0), height = p(64, 0) })
	MTM:RegisterDefinition({ id = "emerald_plant_6", name = "Emerald Plant 6", catID = "foliage", file = t("MapPlants"), texCoords = tcCR(1, 2, 16, 16, 0, 0), width = p(64, 0), height = p(64, 0) })
	MTM:RegisterDefinition({ id = "emerald_plant_7", name = "Emerald Plant 7", catID = "foliage", file = t("MapPlants"), texCoords = tcCR(2, 2, 16, 16, 0, 0), width = p(64, 0), height = p(64, 0) })
	MTM:RegisterDefinition({ id = "emerald_plant_8", name = "Emerald Plant 8", catID = "foliage", file = t("MapPlants"), texCoords = tcCR(3, 2, 16, 16, 0, 0), width = p(64, 0), height = p(64, 0) })
	MTM:RegisterDefinition({ id = "emerald_plant_9", name = "Emerald Plant 9", catID = "foliage", file = t("MapPlants"), texCoords = tcCR(4, 2, 16, 16, 0, 0), width = p(64, 0), height = p(64, 0) })
	MTM:RegisterDefinition({ id = "emerald_plant_10", name = "Emerald Plant 10", catID = "foliage", file = t("MapPlants"), texCoords = tcCR(5, 2, 16, 16, 0, 0), width = p(64, 0), height = p(64, 0) })
	MTM:RegisterDefinition({ id = "emerald_plant_11", name = "Emerald Plant 11", catID = "foliage", file = t("MapPlants"), texCoords = tcCR(6, 2, 16, 16, 0, 0), width = p(64, 0), height = p(64, 0) })
	MTM:RegisterDefinition({ id = "green_plant_1", name = "Green Plant 1", catID = "foliage", file = t("MapPlants"), texCoords = tcCR(7, 2, 16, 16, 0, 0), width = p(64, 0), height = p(64, 0) })
	MTM:RegisterDefinition({ id = "green_plant_2", name = "Green Plant 2", catID = "foliage", file = t("MapPlants"), texCoords = tcCR(8, 2, 16, 16, 0, 0), width = p(64, 0), height = p(64, 0) })
	MTM:RegisterDefinition({ id = "green_plant_3", name = "Green Plant 3", catID = "foliage", file = t("MapPlants"), texCoords = tcCR(9, 2, 16, 16, 0, 0), width = p(64, 0), height = p(64, 0) })
	MTM:RegisterDefinition({ id = "green_plant_4", name = "Green Plant 4", catID = "foliage", file = t("MapPlants"), texCoords = tcCR(10, 2, 16, 16, 0, 0), width = p(64, 0), height = p(64, 0) })
	MTM:RegisterDefinition({ id = "green_plant_5", name = "Green Plant 5", catID = "foliage", file = t("MapPlants"), texCoords = tcCR(11, 2, 16, 16, 0, 0), width = p(64, 0), height = p(64, 0) })
	MTM:RegisterDefinition({ id = "green_plant_6", name = "Green Plant 6", catID = "foliage", file = t("MapPlants"), texCoords = tcCR(12, 2, 16, 16, 0, 0), width = p(64, 0), height = p(64, 0) })
	MTM:RegisterDefinition({ id = "green_plant_7", name = "Green Plant 7", catID = "foliage", file = t("MapPlants"), texCoords = tcCR(13, 2, 16, 16, 0, 0), width = p(64, 0), height = p(64, 0) })
	MTM:RegisterDefinition({ id = "large_green_plant_1", name = "Large Green Plant 1", catID = "foliage", file = t("MapPlants"), texCoords = tcCR(14, 2, 16, 16, 0, 0, 3, 2), width = p(192, 0), height = p(128, 0) })


	MTM:RegisterDefinition({ id = "brown_plant_1", name = "Brown Plant 1", catID = "foliage", file = t("MapPlants"), texCoords = tcCR(1, 3, 16, 16, 0, 0), width = p(64, 0), height = p(64, 0) })
	MTM:RegisterDefinition({ id = "brown_plant_2", name = "Brown Plant 2", catID = "foliage", file = t("MapPlants"), texCoords = tcCR(2, 3, 16, 16, 0, 0), width = p(64, 0), height = p(64, 0) })
	MTM:RegisterDefinition({ id = "brown_plant_3", name = "Brown Plant 3", catID = "foliage", file = t("MapPlants"), texCoords = tcCR(3, 3, 16, 16, 0, 0), width = p(64, 0), height = p(64, 0) })
	MTM:RegisterDefinition({ id = "brown_plant_4", name = "Brown Plant 4", catID = "foliage", file = t("MapPlants"), texCoords = tcCR(4, 3, 16, 16, 0, 0), width = p(64, 0), height = p(64, 0) })
	MTM:RegisterDefinition({ id = "brown_plant_5", name = "Brown Plant 5", catID = "foliage", file = t("MapPlants"), texCoords = tcCR(5, 3, 16, 16, 0, 0), width = p(64, 0), height = p(64, 0) })
	MTM:RegisterDefinition({ id = "brown_plant_6", name = "Brown Plant 6", catID = "foliage", file = t("MapPlants"), texCoords = tcCR(6, 3, 16, 16, 0, 0), width = p(64, 0), height = p(64, 0) })
	MTM:RegisterDefinition({ id = "brown_plant_7", name = "Brown Plant 7", catID = "foliage", file = t("MapPlants"), texCoords = tcCR(7, 3, 16, 16, 0, 0), width = p(64, 0), height = p(64, 0) })
	MTM:RegisterDefinition({ id = "brown_plant_8", name = "Brown Plant 8", catID = "foliage", file = t("MapPlants"), texCoords = tcCR(8, 3, 16, 16, 0, 0), width = p(64, 0), height = p(64, 0) })
	MTM:RegisterDefinition({ id = "brown_plant_9", name = "Brown Plant 9", catID = "foliage", file = t("MapPlants"), texCoords = tcCR(9, 3, 16, 16, 0, 0), width = p(64, 0), height = p(64, 0) })
	MTM:RegisterDefinition({ id = "brown_plant_10", name = "Brown Plant 10", catID = "foliage", file = t("MapPlants"), texCoords = tcCR(10, 3, 16, 16, 0, 0), width = p(64, 0), height = p(64, 0) })
	MTM:RegisterDefinition({ id = "brown_plant_11", name = "Brown Plant 11", catID = "foliage", file = t("MapPlants"), texCoords = tcCR(11, 3, 16, 16, 0, 0), width = p(64, 0), height = p(64, 0) })
	MTM:RegisterDefinition({ id = "brown_plant_12", name = "Brown Plant 12", catID = "foliage", file = t("MapPlants"), texCoords = tcCR(12, 3, 16, 16, 0, 0), width = p(64, 0), height = p(64, 0) })
	MTM:RegisterDefinition({ id = "brown_plant_13", name = "Brown Plant 13", catID = "foliage", file = t("MapPlants"), texCoords = tcCR(13, 3, 16, 16, 0, 0), width = p(64, 0), height = p(64, 0) })



	MTM:RegisterDefinition({ id = "beige_plant_1", name = "Beige Plant 1", catID = "foliage", file = t("MapPlants"), texCoords = tcCR(1, 4, 16, 16, 0, 0), width = p(64, 0), height = p(64, 0) })
	MTM:RegisterDefinition({ id = "beige_plant_2", name = "Beige Plant 2", catID = "foliage", file = t("MapPlants"), texCoords = tcCR(2, 4, 16, 16, 0, 0), width = p(64, 0), height = p(64, 0) })
	MTM:RegisterDefinition({ id = "beige_plant_3", name = "Beige Plant 3", catID = "foliage", file = t("MapPlants"), texCoords = tcCR(3, 4, 16, 16, 0, 0), width = p(64, 0), height = p(64, 0) })
	MTM:RegisterDefinition({ id = "beige_plant_4", name = "Beige Plant 4", catID = "foliage", file = t("MapPlants"), texCoords = tcCR(4, 4, 16, 16, 0, 0), width = p(64, 0), height = p(64, 0) })
	MTM:RegisterDefinition({ id = "beige_plant_5", name = "Beige Plant 5", catID = "foliage", file = t("MapPlants"), texCoords = tcCR(5, 4, 16, 16, 0, 0), width = p(64, 0), height = p(64, 0) })
	MTM:RegisterDefinition({ id = "beige_plant_6", name = "Beige Plant 6", catID = "foliage", file = t("MapPlants"), texCoords = tcCR(6, 4, 16, 16, 0, 0), width = p(64, 0), height = p(64, 0) })
	MTM:RegisterDefinition({ id = "beige_plant_7", name = "Beige Plant 7", catID = "foliage", file = t("MapPlants"), texCoords = tcCR(7, 4, 16, 16, 0, 0), width = p(64, 0), height = p(64, 0) })
	MTM:RegisterDefinition({ id = "oasis_plant_1", name = "Oasis Plant 1", catID = "foliage", file = t("MapPlants"), texCoords = tcCR(8, 4, 16, 16, 0, 0), width = p(64, 0), height = p(64, 0) })
	MTM:RegisterDefinition({ id = "oasis_plant_2", name = "Oasis Plant 2", catID = "foliage", file = t("MapPlants"), texCoords = tcCR(9, 4, 16, 16, 0, 0), width = p(64, 0), height = p(64, 0) })
	MTM:RegisterDefinition({ id = "oasis_plant_3", name = "Oasis Plant 3", catID = "foliage", file = t("MapPlants"), texCoords = tcCR(10, 4, 16, 16, 0, 0), width = p(64, 0), height = p(64, 0) })
	MTM:RegisterDefinition({ id = "oasis_plant_4", name = "Oasis Plant 4", catID = "foliage", file = t("MapPlants"), texCoords = tcCR(11, 4, 16, 16, 0, 0), width = p(64, 0), height = p(64, 0) })
	MTM:RegisterDefinition({ id = "oasis_plant_5", name = "Oasis Plant 5", catID = "foliage", file = t("MapPlants"), texCoords = tcCR(12, 4, 16, 16, 0, 0), width = p(64, 0), height = p(64, 0) })
	MTM:RegisterDefinition({ id = "oasis_plant_6", name = "Oasis Plant 6", catID = "foliage", file = t("MapPlants"), texCoords = tcCR(13, 4, 16, 16, 0, 0), width = p(64, 0), height = p(64, 0) })
	MTM:RegisterDefinition({ id = "large_oasis_plant_1", name = "Large Oasis Plant 1", catID = "foliage", file = t("MapPlants"), texCoords = tcCR(14, 4, 16, 16, 0, 0, 3, 2), width = p(192, 0), height = p(128, 0) })


	MTM:RegisterDefinition({ id = "oasis_flower_1", name = "Oasis Flower 1", catID = "foliage", file = t("MapPlants"), texCoords = tcCR(1, 5, 16, 16, 0, 0, 2, 2), width = p(128, 0), height = p(128, 0) })

	MTM:RegisterDefinition({ id = "oasis_flower_2", name = "Oasis Flower 2", catID = "foliage", file = t("MapPlants"), texCoords = tcCR(3, 5, 16, 16, 0, 0, 2, 2), width = p(128, 0), height = p(128, 0) })

	MTM:RegisterDefinition({ id = "oasis_flower_3", name = "Oasis Flower 3", catID = "foliage", file = t("MapPlants"), texCoords = tcCR(5, 5, 16, 16, 0, 0, 2, 2), width = p(128, 0), height = p(128, 0) })

	MTM:RegisterDefinition({ id = "oasis_flower_4", name = "Oasis Flower 4", catID = "foliage", file = t("MapPlants"), texCoords = tcCR(7, 5, 16, 16, 0, 0, 2, 2), width = p(128, 0), height = p(128, 0) })

	MTM:RegisterDefinition({ id = "oasis_plant_7", name = "Oasis Plant 7", catID = "foliage", file = t("MapPlants"), texCoords = tcCR(9, 5, 16, 16, 0, 0), width = p(64, 0), height = p(64, 0) })
	MTM:RegisterDefinition({ id = "oasis_plant_8", name = "Oasis Plant 8", catID = "foliage", file = t("MapPlants"), texCoords = tcCR(10, 5, 16, 16, 0, 0), width = p(64, 0), height = p(64, 0) })
	MTM:RegisterDefinition({ id = "oasis_plant_9", name = "Oasis Plant 9", catID = "foliage", file = t("MapPlants"), texCoords = tcCR(11, 5, 16, 16, 0, 0), width = p(64, 0), height = p(64, 0) })
	MTM:RegisterDefinition({ id = "oasis_plant_10", name = "Oasis Plant 10", catID = "foliage", file = t("MapPlants"), texCoords = tcCR(12, 5, 16, 16, 0, 0, 2, 1), width = p(128, 0), height = p(64, 0) })












	MTM:RegisterDefinition({ id = "oasis_plant_11", name = "Oasis Plant 11", catID = "foliage", file = t("MapPlants"), texCoords = tcCR(9, 6, 16, 16, 0, 0), width = p(64, 0), height = p(64, 0) })
	MTM:RegisterDefinition({ id = "oasis_plant_12", name = "Oasis Plant 12", catID = "foliage", file = t("MapPlants"), texCoords = tcCR(10, 6, 16, 16, 0, 0), width = p(64, 0), height = p(64, 0) })
	MTM:RegisterDefinition({ id = "oasis_plant_13", name = "Oasis Plant 13", catID = "foliage", file = t("MapPlants"), texCoords = tcCR(11, 6, 16, 16, 0, 0), width = p(64, 0), height = p(64, 0) })
	MTM:RegisterDefinition({ id = "oasis_plant_14", name = "Oasis Plant 14", catID = "foliage", file = t("MapPlants"), texCoords = tcCR(12, 6, 16, 16, 0, 0, 2, 1), width = p(128, 0), height = p(64, 0) })

	MTM:RegisterDefinition({ id = "oasis_plant_15", name = "Oasis Plant 15", catID = "foliage", file = t("MapPlants"), texCoords = tcCR(14, 6, 16, 16, 0, 0, 3, 1), width = p(192, 0), height = p(64, 0) })



	MTM:RegisterDefinition({ id = "crossroads_1", name = "Crossroads 1", catID = "roads", file = t("MapRoads"), texCoords = tcCR(1, 1, 8, 8, 56.25, 56.25), width = p(128, 56.25), height = p(128, 56.25) })
	MTM:RegisterDefinition({ id = "crossroads_2", name = "Crossroads 2", catID = "roads", file = t("MapRoads"), texCoords = tcCR(2, 1, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "crossroads_3", name = "Crossroads 3", catID = "roads", file = t("MapRoads"), texCoords = tcCR(3, 1, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "crossroads_4", name = "Crossroads 4", catID = "roads", file = t("MapRoads"), texCoords = tcCR(4, 1, 8, 8, 56.25, 56.25), width = p(128, 56.25), height = p(128, 56.25) })
	MTM:RegisterDefinition({ id = "crossroads_5", name = "Crossroads 5", catID = "roads", file = t("MapRoads"), texCoords = tcCR(5, 1, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "crossroads_6", name = "Crossroads 6", catID = "roads", file = t("MapRoads"), texCoords = tcCR(6, 1, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "crossroads_7", name = "Crossroads 7", catID = "roads", file = t("MapRoads"), texCoords = tcCR(7, 1, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })

	MTM:RegisterDefinition({ id = "road_1", name = "Road 1", catID = "roads", file = t("MapRoads"), texCoords = tcCR(1, 2, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "road_2", name = "Road 2", catID = "roads", file = t("MapRoads"), texCoords = tcCR(2, 2, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "road_3", name = "Road 3", catID = "roads", file = t("MapRoads"), texCoords = tcCR(3, 2, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "road_4", name = "Road 4", catID = "roads", file = t("MapRoads"), texCoords = tcCR(4, 2, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "road_5", name = "Road 5", catID = "roads", file = t("MapRoads"), texCoords = tcCR(5, 2, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "road_6", name = "Road 6", catID = "roads", file = t("MapRoads"), texCoords = tcCR(6, 2, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "road_7", name = "Road 7", catID = "roads", file = t("MapRoads"), texCoords = tcCR(7, 2, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "road_8", name = "Road 8", catID = "roads", file = t("MapRoads"), texCoords = tcCR(8, 2, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "road_9", name = "Road 9", catID = "roads", file = t("MapRoads"), texCoords = tcCR(1, 3, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "road_10", name = "Road 10", catID = "roads", file = t("MapRoads"), texCoords = tcCR(2, 3, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "road_11", name = "Road 11", catID = "roads", file = t("MapRoads"), texCoords = tcCR(3, 3, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "road_12", name = "Road 12", catID = "roads", file = t("MapRoads"), texCoords = tcCR(4, 3, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "road_13", name = "Road 13", catID = "roads", file = t("MapRoads"), texCoords = tcCR(5, 3, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "road_14", name = "Road 14", catID = "roads", file = t("MapRoads"), texCoords = tcCR(6, 3, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "road_15", name = "Road 15", catID = "roads", file = t("MapRoads"), texCoords = tcCR(7, 3, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "road_16", name = "Road 16", catID = "roads", file = t("MapRoads"), texCoords = tcCR(8, 3, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "road_17", name = "Road 17", catID = "roads", file = t("MapRoads"), texCoords = tcCR(1, 4, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "road_18", name = "Road 18", catID = "roads", file = t("MapRoads"), texCoords = tcCR(2, 4, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "road_19", name = "Road 19", catID = "roads", file = t("MapRoads"), texCoords = tcCR(3, 4, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "road_20", name = "Road 20", catID = "roads", file = t("MapRoads"), texCoords = tcCR(4, 4, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "road_21", name = "Road 21", catID = "roads", file = t("MapRoads"), texCoords = tcCR(5, 4, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "road_22", name = "Road 22", catID = "roads", file = t("MapRoads"), texCoords = tcCR(6, 4, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "road_23", name = "Road 23", catID = "roads", file = t("MapRoads"), texCoords = tcCR(7, 4, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "road_24", name = "Road 24", catID = "roads", file = t("MapRoads"), texCoords = tcCR(8, 4, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "road_25", name = "Road 25", catID = "roads", file = t("MapRoads"), texCoords = tcCR(1, 5, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "road_26", name = "Road 26", catID = "roads", file = t("MapRoads"), texCoords = tcCR(2, 5, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "road_27", name = "Road 27", catID = "roads", file = t("MapRoads"), texCoords = tcCR(3, 5, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "road_28", name = "Road 28", catID = "roads", file = t("MapRoads"), texCoords = tcCR(4, 5, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "road_29", name = "Road 29", catID = "roads", file = t("MapRoads"), texCoords = tcCR(5, 5, 8, 8, 0, 0), width = p(128, 0), height = p(128, 0) })




























	MTM:RegisterDefinition({ id = "epsilon_corner_1", name = "Epsilon Corner 1", catID = "art", file = t("MapCorners"), texCoords = tcCR(1, 1, 8, 4, 1, 1), width = p(256, 1), height = p(256, 1) })
	MTM:RegisterDefinition({ id = "epsilon_corner_2", name = "Epsilon Corner 2", catID = "art", file = t("MapCorners"), texCoords = tcCR(2, 1, 8, 4, 1, 1), width = p(256, 1), height = p(256, 1) })
	MTM:RegisterDefinition({ id = "draenei_corner", name = "Draenei Corner", catID = "art", file = t("MapCorners"), texCoords = tcCR(3, 1, 8, 4, 1, 1), width = p(256, 1), height = p(256, 1) })
	MTM:RegisterDefinition({ id = "iron_horde_corner", name = "Iron Horde Corner", catID = "art", file = t("MapCorners"), texCoords = tcCR(4, 1, 8, 4, 1, 1), width = p(256, 1), height = p(256, 1) })
	MTM:RegisterDefinition({ id = "dwarven_corner_1", name = "Dwarven Corner 1", catID = "art", file = t("MapCorners"), texCoords = tcCR(5, 1, 8, 4, 1, 1), width = p(256, 1), height = p(256, 1) })
	MTM:RegisterDefinition({ id = "dwarven_corner_2", name = "Dwarven Corner 2", catID = "art", file = t("MapCorners"), texCoords = tcCR(6, 1, 8, 4, 1, 1), width = p(256, 1), height = p(256, 1) })
	MTM:RegisterDefinition({ id = "earthen_dwarf_corner_1", name = "Earthen Dwarf Corner 1", catID = "art", file = t("MapCorners"), texCoords = tcCR(7, 1, 8, 4, 1, 1), width = p(256, 1), height = p(256, 1) })
	MTM:RegisterDefinition({ id = "earthen_dwarf_corner_2", name = "Earthen Dwarf Corner 2", catID = "art", file = t("MapCorners"), texCoords = tcCR(8, 1, 8, 4, 1, 1), width = p(256, 1), height = p(256, 1) })
	MTM:RegisterDefinition({ id = "legion_corner_1", name = "Legion Corner 1", catID = "art", file = t("MapCorners"), texCoords = tcCR(1, 2, 8, 4, 1, 1), width = p(256, 1), height = p(256, 1) })
	MTM:RegisterDefinition({ id = "legion_corner_2", name = "Legion Corner 2", catID = "art", file = t("MapCorners"), texCoords = tcCR(2, 2, 8, 4, 1, 1), width = p(256, 1), height = p(256, 1) })
	MTM:RegisterDefinition({ id = "void_corner_1", name = "Void Corner 1", catID = "art", file = t("MapCorners"), texCoords = tcCR(3, 2, 8, 4, 1, 1), width = p(256, 1), height = p(256, 1) })
	MTM:RegisterDefinition({ id = "void_corner_2", name = "Void Corner 2", catID = "art", file = t("MapCorners"), texCoords = tcCR(4, 2, 8, 4, 1, 1), width = p(256, 1), height = p(256, 1) })
	MTM:RegisterDefinition({ id = "kul_tiran_corner", name = "Kul Tiran Corner", catID = "art", file = t("MapCorners"), texCoords = tcCR(5, 2, 8, 4, 1, 1), width = p(256, 1), height = p(256, 1) })
	MTM:RegisterDefinition({ id = "pandaren_corner", name = "Pandaren Corner", catID = "art", file = t("MapCorners"), texCoords = tcCR(6, 2, 8, 4, 1, 1), width = p(256, 1), height = p(256, 1) })
	MTM:RegisterDefinition({ id = "troll_corner", name = "Troll Corner", catID = "art", file = t("MapCorners"), texCoords = tcCR(7, 2, 8, 4, 1, 1), width = p(256, 1), height = p(256, 1) })
	MTM:RegisterDefinition({ id = "classic_corner_1", name = "Classic Corner 1", catID = "art", file = t("MapCorners"), texCoords = tcCR(8, 2, 8, 4, 1, 1), width = p(256, 1), height = p(256, 1) })
	MTM:RegisterDefinition({ id = "classic_corner_2", name = "Classic Corner 2", catID = "art", file = t("MapCorners"), texCoords = tcCR(1, 3, 8, 4, 1, 1), width = p(256, 1), height = p(256, 1) })
	MTM:RegisterDefinition({ id = "nightborne_corner_1", name = "Nightborne Corner 1", catID = "art", file = t("MapCorners"), texCoords = tcCR(2, 3, 8, 4, 1, 1), width = p(256, 1), height = p(256, 1) })
	MTM:RegisterDefinition({ id = "nightborne_corner_2", name = "Nightborne Corner 2", catID = "art", file = t("MapCorners"), texCoords = tcCR(3, 3, 8, 4, 1, 1), width = p(256, 1), height = p(256, 1) })
	MTM:RegisterDefinition({ id = "death_knight_corner_1", name = "Death Knight Corner 1", catID = "art", file = t("MapCorners"), texCoords = tcCR(4, 3, 8, 4, 1, 1), width = p(256, 1), height = p(256, 1) })
	MTM:RegisterDefinition({ id = "death_knight_corner_2", name = "Death Knight Corner 2", catID = "art", file = t("MapCorners"), texCoords = tcCR(5, 3, 8, 4, 1, 1), width = p(256, 1), height = p(256, 1) })
	MTM:RegisterDefinition({ id = "draconic_corner_1", name = "Draconic Corner 1", catID = "art", file = t("MapCorners"), texCoords = tcCR(6, 3, 8, 4, 1, 1), width = p(256, 1), height = p(256, 1) })
	MTM:RegisterDefinition({ id = "draconic_corner_2", name = "Draconic Corner 2", catID = "art", file = t("MapCorners"), texCoords = tcCR(7, 3, 8, 4, 1, 1), width = p(256, 1), height = p(256, 1) })
	MTM:RegisterDefinition({ id = "shadowlands_corner", name = "Shadowlands Corner", catID = "art", file = t("MapCorners"), texCoords = tcCR(8, 3, 8, 4, 1, 1), width = p(256, 1), height = p(256, 1) })





	MTM:RegisterDefinition({ id = "boom_seal", name = "Boom Seal", catID = "stamps", file = t("Stickers\\boom"), texCoords = nil, width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "bbay_stamp", name = "Bootybay Postage Stamp", catID = "stamps", file = t("Stickers\\bootybay"), texCoords = nil, width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "org_stamp", name = "Orgrimmar Postage Stamp", catID = "stamps", file = t("Stickers\\orgrimmar"), texCoords = nil, width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "paradise_stamp", name = "Paradise Postage Stamp", catID = "stamps", file = t("Stickers\\perilsinparadise"), texCoords = nil, width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "sw_stamp", name = "Stormwind Postage Stamp", catID = "stamps", file = t("Stickers\\stormwind"), texCoords = nil, width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "thbluff_stamp", name = "Thunderbluff Postage Stamp", catID = "stamps", file = t("Stickers\\thunderbluff"), texCoords = nil, width = p(128, 0), height = p(128, 0) })
	MTM:RegisterDefinition({ id = "twilight_seal", name = "Twilight Seal", catID = "stamps", file = t("Stickers\\twilight"), texCoords = nil, width = p(128, 0), height = p(128, 0) })


	MTM:RegisterDefinition({ id = "edge_island", name = "Island", catID = "ocean", file = t("IslandPieces\\Island"), texCoords = nil, width = p(1024, 12.5), height = p(1024, 0) })
	MTM:RegisterDefinition({ id = "edge_north", name = "North", catID = "ocean", file = t("IslandPieces\\North"), texCoords = nil, width = p(1024, 12.5), height = p(1024, 0) })
	MTM:RegisterDefinition({ id = "edge_northeast", name = "North East", catID = "ocean", file = t("IslandPieces\\NorthEast"), texCoords = nil, width = p(1024, 12.5), height = p(1024, 0) })
	MTM:RegisterDefinition({ id = "edge_northwest", name = "North West", catID = "ocean", file = t("IslandPieces\\NorthWest"), texCoords = nil, width = p(1024, 12.5), height = p(1024, 0) })
	MTM:RegisterDefinition({ id = "edge_righttopleft", name = "Right Top Left", catID = "ocean", file = t("IslandPieces\\RightTopLeft"), texCoords = nil, width = p(1024, 12.5), height = p(1024, 0) })
	MTM:RegisterDefinition({ id = "edge_south", name = "South", catID = "ocean", file = t("IslandPieces\\South"), texCoords = nil, width = p(1024, 12.5), height = p(1024, 0) })
	MTM:RegisterDefinition({ id = "edge_southeast", name = "South East", catID = "ocean", file = t("IslandPieces\\SouthEast"), texCoords = nil, width = p(1024, 12.5), height = p(1024, 0) })
	MTM:RegisterDefinition({ id = "edge_southwest", name = "South West", catID = "ocean", file = t("IslandPieces\\SouthWest"), texCoords = nil, width = p(1024, 12.5), height = p(1024, 0) })
	MTM:RegisterDefinition({ id = "edge_west", name = "West", catID = "ocean", file = t("IslandPieces\\West"), texCoords = nil, width = p(1024, 12.5), height = p(1024, 0) })
	MTM:RegisterDefinition({ id = "edge_bottomleftright", name = "Bottom Left Right", catID = "ocean", file = t("IslandPieces\\BottomLeftRight"), texCoords = nil, width = p(1024, 12.5), height = p(1024, 0) })
	MTM:RegisterDefinition({ id = "edge_bottomlefttop", name = "Bottom Left Top", catID = "ocean", file = t("IslandPieces\\BottomLeftTop"), texCoords = nil, width = p(1024, 12.5), height = p(1024, 0) })
	MTM:RegisterDefinition({ id = "edge_bottomrighttop", name = "Bottom Right Top", catID = "ocean", file = t("IslandPieces\\BottomRightTop"), texCoords = nil, width = p(1024, 12.5), height = p(1024, 0) })
	MTM:RegisterDefinition({ id = "edge_east", name = "East", catID = "ocean", file = t("IslandPieces\\East"), texCoords = nil, width = p(1024, 12.5), height = p(1024, 0) })
end

-- Build Blizz after Epsi so ours always take precedence in the UI list
buildBlizzAtlasDefinitions()
