---@class ns
local ns = select(2, ...)

local SavedVariables = ns.SavedVariables
local Constants = ns.Constants

local DataUtils = ns.Utils.Data
local AceConfig = ns.Libs.AceConfig
local AceConfigDialog = ns.Libs.AceConfigDialog
local AceGUI = ns.Libs.AceGUI
local SparkPopups = ns.UI.SparkPopups
local ASSETS_PATH = ns.Constants.ASSETS_PATH
local ADDON_COLORS = ns.Constants.ADDON_COLORS
local SPARK_ASSETS_PATH = ASSETS_PATH .. "/Sparks/"
local Tooltip = ns.Utils.Tooltip

local getPlayerPositionData = C_Epsilon.GetPosition or function() return UnitPosition("player") end

local theUIDialogName = Constants.SPARK_CREATE_UI_NAME
local defaultSparkPopupStyle = 629199 -- "Interface\\ExtraButton\\Default";
local addNewSparkPopupStyleTex = 308477
local customStyleTexIter = 0

local event_unlock_dates = { -- add event unlock here, modify the function below
	--halloween2023 = Constants.eventUnlockDates.halloween2023
}

-- modify for next event lol
local function halloweenUnlockTest(key)
	return SavedVariables.unlocks.isUnlockedByKeyOrTime(key, event_unlock_dates.halloween2023)
end

------------------------------------
--#region Spark Types
------------------------------------

---@enum (key) SparkTypes
local _sparkTypes = {
	[1] = "Standard",
	[2] = "Multi",
	[3] = "Emote",
	[4] = "Chat",
	[5] = "Jump",
	[6] = "Auto",
}

local _sparkTypesMap = {}         -- this is a name = value reverse map
for k, v in pairs(_sparkTypes) do -- pairs, not ipairs, because you can comment out a line to disable that type for now
	_sparkTypesMap[v] = k
end

---Checks if a Spark Type is equal to any of the types specified
---@param sparkType number
---@param ... number|SparkTypes
---@return boolean
local function isSparkType(sparkType, ...)
	if not sparkType then sparkType = _sparkTypesMap["Standard"] end -- Legacy Spark - default to standard

	local t = {}
	for _, v in ipairs({ ... }) do
		if type(v) == "string" then
			-- convert from string to type
			if _sparkTypesMap[v] then
				-- found a type for that name
				v = _sparkTypesMap[v]
			end
		end
		t[v] = true
	end
	if t[sparkType] then return true else return false end
end

-- Helper function, but most cases this is called directly. Example: getSparkTypeIDByName("Auto") is the same as _sparkTypesMap["Auto"] but with function overhead.
local function getSparkTypeIDByName(name)
	return _sparkTypesMap[name]
end

--#endregion
------------------------------------
--#region Emote List for UI Choices
------------------------------------

---@type EmoteToken[]
local emotesList = {}

---@type table<EmoteToken, string>
local emotesMap = {}       -- dictionary of token = "command; command1; ..."

for emoteIndex = 1, 626 do -- MAXEMOTEINDEX is local in 927 build, so we're just going to hard code this for now..
	local token = _G["EMOTE" .. emoteIndex .. "_TOKEN"];
	if token then
		local slashCommands = { _G["EMOTE" .. emoteIndex .. "_CMD"] }

		local i = 1
		local label = _G["EMOTE" .. emoteIndex .. "_CMD1"];
		while (label) do
			if not tContains(slashCommands, label) then
				tinsert(slashCommands, label) -- store the command, then iterate to the next label
			end

			i = i + 1
			label = _G["EMOTE" .. emoteIndex .. "_CMD" .. i]
		end

		local fullLabel
		if #slashCommands > 0 then
			fullLabel = table.concat(slashCommands, "; ")
		else
			fullLabel = token
		end

		tinsert(emotesList, token)
		emotesMap[token] = fullLabel
	end
end

--#endregion

local sparkPopupStyles = { -- You can still use one not listed here technically, but these are the ones supported in the UI.

	-- Blizzard Extra Buttons
	{ tex = 629199,                                                     name = "Default" },
	{ tex = 629198,                                                     name = "Champion Light" },
	{ tex = 629200,                                                     name = "Feng Barrier" },
	{ tex = 629201,                                                     name = "Feng Shroud" },
	{ tex = 629202,                                                     name = "Ultra Xion" },
	{ tex = 629203,                                                     name = "Ysera" },
	{ tex = 629479,                                                     name = "Green Keg" },
	{ tex = 629480,                                                     name = "Smash" },
	{ tex = 629738,                                                     name = "Brown Keg" },
	{ tex = 653590,                                                     name = "Lightning Keg" },
	{ tex = 654130,                                                     name = "Hozu Bar" },
	{ tex = 667434,                                                     name = "Airstrike" },
	{ tex = 774879,                                                     name = "Engineering" },
	{ tex = 796702,                                                     name = "Soulswap" },
	{ tex = 876185,                                                     name = "Amber" },
	{ tex = 1016651,                                                    name = "Garr. Armory" },
	{ tex = 1016652,                                                    name = "Garr. Alliance" },
	{ tex = 1016653,                                                    name = "Garr. Horde" },
	{ tex = 1016654,                                                    name = "Garr. Inn (Hearthstone)" },
	{ tex = 1016655,                                                    name = "Garr. Lumbermill" },
	{ tex = 1016656,                                                    name = "Garr. Mage Tower" },
	{ tex = 1016657,                                                    name = "Garr. Stables" },
	{ tex = 1016658,                                                    name = "Garr. Trading Post" },
	{ tex = 1016659,                                                    name = "Garr. Training Pit" },
	{ tex = 1016660,                                                    name = "Garr. Workshop" },
	{ tex = 1129687,                                                    name = "Eye of Terrok" },
	{ tex = 1466424,                                                    name = "Fel" },
	{ tex = 1589183,                                                    name = "Soulcage" },
	{ tex = 2203955,                                                    name = "Heart of Az. Active" },
	{ tex = 2203956,                                                    name = "Heart of Az. Minimal" },

	-- SL
	{ tex = 4391622,                                                    name = "Shadowlands Generic" },
	{ tex = 3853103,                                                    name = "Ardenweald" },
	{ tex = 3853104,                                                    name = "Bastion" },
	{ tex = 3853105,                                                    name = "Maldraxxus" },
	{ tex = 3853106,                                                    name = "Revendreth" },
	{ tex = "progenitor-extrabutton", --[[atlas]]                       name = "Zereth (Progenitor)" },
	{ tex = "Torghast-Empowered", --[[atlas]]                           name = "Torghast" },

	-- Start Custom Ones
	{ tex = SPARK_ASSETS_PATH .. "1Simple",                             name = "Arcanum - Simple" },
	{ tex = SPARK_ASSETS_PATH .. "1Ornate",                             name = "Arcanum - Ornate" },
	{ tex = SPARK_ASSETS_PATH .. "1OrnateBG",                           name = "Arcanum - Aurora" },
	{ tex = SPARK_ASSETS_PATH .. "2Simple",                             name = "Arc Lens - Simple" },
	{ tex = SPARK_ASSETS_PATH .. "2CustomRed",                          name = "Arc Lens - Red" },
	{ tex = SPARK_ASSETS_PATH .. "2CustomOrange",                       name = "Arc Lens - Orange" },
	{ tex = SPARK_ASSETS_PATH .. "2CustomYellow",                       name = "Arc Lens - Yellow" },
	{ tex = SPARK_ASSETS_PATH .. "2CustomGreen",                        name = "Arc Lens - Green" },
	{ tex = SPARK_ASSETS_PATH .. "2CustomJade",                         name = "Arc Lens - Jade" },
	{ tex = SPARK_ASSETS_PATH .. "2CustomBlue",                         name = "Arc Lens - Blue" },
	{ tex = SPARK_ASSETS_PATH .. "2CustomIndigo",                       name = "Arc Lens - Indigo" },
	{ tex = SPARK_ASSETS_PATH .. "2CustomViolet",                       name = "Arc Lens - Violet" },
	{ tex = SPARK_ASSETS_PATH .. "2CustomPink",                         name = "Arc Lens - Pink" },
	{ tex = SPARK_ASSETS_PATH .. "2CustomPrismatic",                    name = "Arc Lens - Prismatic" },
	{ tex = SPARK_ASSETS_PATH .. "dicemaster_sanctum",                  name = "DiceMaster Sanctum" },
	{ tex = SPARK_ASSETS_PATH .. "ethereal-xtrabtn",                    name = "Arc+Dice - Ethereal" },
	{ tex = SPARK_ASSETS_PATH .. "nzoth-xtrabtn",                       name = "Arc+Dice - Nzoth" },
	{ tex = SPARK_ASSETS_PATH .. "forsaken-xtrabtn",                    name = "Arc+Dice - Forsaken" },
	{ tex = SPARK_ASSETS_PATH .. "worgen-xtrabtn",                      name = "Arc+Dice - Worgen" },
	{ tex = SPARK_ASSETS_PATH .. "skylar/Goblin-xtrabtn",               name = "Arc+Dice - Goblin" },
	{ tex = SPARK_ASSETS_PATH .. "skylar/Mechagnome-xtrabtn",           name = "Arc+Dice - Mechagnome" },
	{ tex = SPARK_ASSETS_PATH .. "skylar/KulTiras-xtrabtn",             name = "Arc+Dice - Kul Tiras" },
	{ tex = SPARK_ASSETS_PATH .. "skylar/NightElf-xtrabtn",             name = "Arc+Dice - Kaldorei" },
	{ tex = SPARK_ASSETS_PATH .. "skylar/BloodElf2-xtrabtn",            name = "Arc+Dice - Sin'dorei" },
	{ tex = SPARK_ASSETS_PATH .. "skylar/VoidElf-xtrabtn",              name = "Arc+Dice - Ren'dorei" },

	{ tex = SPARK_ASSETS_PATH .. "sf_dragon_frame_metal",               name = "SF Dragon - Metal" },
	{ tex = SPARK_ASSETS_PATH .. "sf_dragon_frame_arcane",              name = "SF Dragon - Arcane" },
	{ tex = SPARK_ASSETS_PATH .. "sf_dragon_frame_black",               name = "SF Dragon - Black" },
	{ tex = SPARK_ASSETS_PATH .. "sf_dragon_frame_blue",                name = "SF Dragon - Blue" },
	{ tex = SPARK_ASSETS_PATH .. "sf_dragon_frame_bronze",              name = "SF Dragon - Bronze" },
	{ tex = SPARK_ASSETS_PATH .. "sf_dragon_frame_brown",               name = "SF Dragon - Brown" },
	{ tex = SPARK_ASSETS_PATH .. "sf_dragon_frame_darkblue",            name = "SF Dragon - Darkblue" },
	{ tex = SPARK_ASSETS_PATH .. "sf_dragon_frame_emerald",             name = "SF Dragon - Emerald" },
	{ tex = SPARK_ASSETS_PATH .. "sf_dragon_frame_green",               name = "SF Dragon - Green" },
	{ tex = SPARK_ASSETS_PATH .. "sf_dragon_frame_infinite",            name = "SF Dragon - Infinite" },
	{ tex = SPARK_ASSETS_PATH .. "sf_dragon_frame_jade",                name = "SF Dragon - Jade" },
	{ tex = SPARK_ASSETS_PATH .. "sf_dragon_frame_orange",              name = "SF Dragon - Orange" },
	{ tex = SPARK_ASSETS_PATH .. "sf_dragon_frame_phoenix",             name = "SF Dragon - Phoenix" },
	{ tex = SPARK_ASSETS_PATH .. "sf_dragon_frame_pink",                name = "SF Dragon - Pink" },
	{ tex = SPARK_ASSETS_PATH .. "sf_dragon_frame_purple",              name = "SF Dragon - Purple" },
	{ tex = SPARK_ASSETS_PATH .. "sf_dragon_frame_red",                 name = "SF Dragon - Red" },
	{ tex = SPARK_ASSETS_PATH .. "sf_dragon_frame_ruby",                name = "SF Dragon - Ruby" },
	{ tex = SPARK_ASSETS_PATH .. "sf_dragon_frame_white",               name = "SF Dragon - White" },
	{ tex = SPARK_ASSETS_PATH .. "sf_dragon_frame_yellow",              name = "SF Dragon - Yellow" },

	-- SL Custom
	{ tex = SPARK_ASSETS_PATH .. "SL/Ardenweald",                       name = "Arc - Faetouched",         circular = true },
	{ tex = SPARK_ASSETS_PATH .. "SL/Maw",                              name = "Arc - Inevitable",         circular = true },
	{ tex = SPARK_ASSETS_PATH .. "SL/ZerethMortis",                     name = "Arc - Fractal",            circular = true },
	{ tex = SPARK_ASSETS_PATH .. "SL/Tazavesh",                         name = "Arc - Bazaar",             circular = true },
	{ tex = SPARK_ASSETS_PATH .. "SL/Devourer",                         name = "Arc - Devoured",           circular = true },
	{ tex = SPARK_ASSETS_PATH .. "SL/Maldraxxus",                       name = "Arc - Risen",              circular = true },
	{ tex = SPARK_ASSETS_PATH .. "SL/Revendreth",                       name = "Arc - Tithed",             circular = true },
	{ tex = SPARK_ASSETS_PATH .. "SL/Bastion",                          name = "Arc - Ascended",           circular = true },

	-- DF Ports
	{ tex = SPARK_ASSETS_PATH .. "DF/WhiteStorm",                       name = "DF - White Storm" },
	{ tex = SPARK_ASSETS_PATH .. "DF/PurpleStorm",                      name = "DF - Purple Storm" },
	{ tex = SPARK_ASSETS_PATH .. "DF/BlueStorm",                        name = "DF - Blue Storm" },
	{ tex = SPARK_ASSETS_PATH .. "DF/YellowStorm",                      name = "DF - Yellow Storm" },
	{ tex = SPARK_ASSETS_PATH .. "DF/Water",                            name = "DF - Water" },
	{ tex = SPARK_ASSETS_PATH .. "DF/Earth",                            name = "DF - Earth" },
	{ tex = SPARK_ASSETS_PATH .. "DF/Fire",                             name = "DF - Fire" },

	--halloween 2023
	{ tex = SPARK_ASSETS_PATH .. "halloween/" .. "halloween",           name = "Soulfire (Halloween 2023)" },
	{ tex = SPARK_ASSETS_PATH .. "halloween/" .. "halloweentint",       name = "Soulfire (Tint)" },

	-- example for next event
	--{ tex = SPARK_ASSETS_PATH .. "halloween/" .. "halloween",     name = "Soulfire (Halloween 2023)", requirement = function() return halloweenUnlockTest("halloween_spark_01") end },
	--{ tex = SPARK_ASSETS_PATH .. "halloween/" .. "halloweentint", name = "Soulfire (Tint)",           requirement = function() return halloweenUnlockTest("halloween_spark_01") end },

	{ tex = SPARK_ASSETS_PATH .. "Multi/MultiSpark-ArcanumTint-1",      name = "Arcanum (Simple Tint)" },

	{ tex = SPARK_ASSETS_PATH .. "Multi/MultiSpark-ArcanumDecorated-1", name = "Arcanum - Enchanted" },
	{ tex = SPARK_ASSETS_PATH .. "Multi/MultiSpark-Ornate-1",           name = "Arc Deco (Ornate)" },
	{ tex = SPARK_ASSETS_PATH .. "Multi/MultiSpark-Draconic-1",         name = "Draconic" },

	{ tex = SPARK_ASSETS_PATH .. "Multi/MultiSpark-Maw-1",              name = "Maw" },
	{ tex = SPARK_ASSETS_PATH .. "Multi/MultiSpark-Zereth-1",           name = "Zereth (Progenitor)" },
	{ tex = SPARK_ASSETS_PATH .. "Multi/MultiSpark-Ardenweald-1",       name = "Ardenweald" },
	{ tex = SPARK_ASSETS_PATH .. "Multi/MultiSpark-Bastion-1",          name = "Bastion" },
	{ tex = SPARK_ASSETS_PATH .. "Multi/MultiSpark-Maldraxxus-1",       name = "Maldraxxus" },
	{ tex = SPARK_ASSETS_PATH .. "Multi/MultiSpark-Revendreth-1",       name = "Revendreth" },

	{ tex = SPARK_ASSETS_PATH .. "Multi/MultiSpark-Aether-1",           name = "Aether (Tint)" },

	-- always last
	{ tex = addNewSparkPopupStyleTex,                                   name = "Add Other/Custom" },
	-- 	{ tex = SPARK_ASSETS_PATH .. "CustomFrameFile", name = "Custom Frame 1", requirement = func -> bool (true: Show, false: Hide) },
}

--[[
local sparkPopupStylesKVTable = {}
local sparkPopupStylesSortTable = {}
for k, v in ipairs(sparkPopupStyles) do
	local newKey = v.tex
	local newVal = CreateTextureMarkup(v.tex, 48, 24, 48, 24, 0, 1, 0, 1) .. " " .. v.name
	sparkPopupStylesKVTable[newKey] = newVal
	tinsert(sparkPopupStylesSortTable, newKey)
end
--]]

local sparkPopupStyles_Map = {}
local function getSparkPopupStylesKV()
	local style_KV_Table = {}
	for k, v in ipairs(sparkPopupStyles) do
		if not v.requirement or v.requirement() then
			local newKey = v.tex

			local texString
			local isAtlas = (type(v.tex) == "string") and C_Texture.GetAtlasInfo(v.tex)
			if isAtlas then
				texString = CreateAtlasMarkup(v.tex, 48, 24) .. " " .. v.name
			else
				texString = CreateTextureMarkup(v.tex, 48, 24, 48, 24, 0, 1, 0, 1) .. " " .. v.name
			end

			style_KV_Table[newKey] = texString
			sparkPopupStyles_Map[newKey] = v
		end
	end
	return style_KV_Table
end
getSparkPopupStylesKV() -- just call it once to instantiate our Map also

local function getSparkPopupStylesSorted()
	local style_Sort_Table = {}
	for k, v in ipairs(sparkPopupStyles) do
		if not v.requirement or v.requirement() then
			local newKey = v.tex
			tinsert(style_Sort_Table, newKey)
		end
	end
	return style_Sort_Table
end

-- Multi Sparks
local multiSparkStyles = { -- You can still use one not listed here technically, but these are the ones supported in the UI.

	-- Custom to support variable 1 to 4 Buttons
	{ tex = SPARK_ASSETS_PATH .. "Multi/MultiSpark-ArcanumTint",      name = "Arcanum (Tint)" },
	{ tex = SPARK_ASSETS_PATH .. "Multi/MultiSpark-Arcanum",          name = "Arcanum" },

	{ tex = SPARK_ASSETS_PATH .. "Multi/MultiSpark-ArcanumDecorated", name = "Arcanum - Enchanted" },
	{ tex = SPARK_ASSETS_PATH .. "Multi/MultiSpark-Ornate",           name = "Arc Deco (Ornate)" },
	{ tex = SPARK_ASSETS_PATH .. "Multi/MultiSpark-Draconic",         name = "Draconic" },

	{ tex = SPARK_ASSETS_PATH .. "Multi/MultiSpark-Maw",              name = "Maw" },
	{ tex = SPARK_ASSETS_PATH .. "Multi/MultiSpark-Zereth",           name = "Zereth (Progenitor)" },
	{ tex = SPARK_ASSETS_PATH .. "Multi/MultiSpark-Ardenweald",       name = "Ardenweald" },
	{ tex = SPARK_ASSETS_PATH .. "Multi/MultiSpark-Bastion",          name = "Bastion" },
	{ tex = SPARK_ASSETS_PATH .. "Multi/MultiSpark-Maldraxxus",       name = "Maldraxxus" },
	{ tex = SPARK_ASSETS_PATH .. "Multi/MultiSpark-Revendreth",       name = "Revendreth" },

	{ tex = SPARK_ASSETS_PATH .. "Multi/MultiSpark-Aether",           name = "Aether (Tint)" },
}

local multiSparkStyles_Map = {}
local function getMultiSparkStylesKV()
	local style_KV_Table = {}
	for k, v in ipairs(multiSparkStyles) do
		if not v.requirement or v.requirement() then
			local newKey = v.tex

			local texString
			local isAtlas = (type(v.tex) == "string") and C_Texture.GetAtlasInfo(v.tex)
			if isAtlas then
				texString = CreateAtlasMarkup(v.tex, 48, 24) .. " " .. v.name
			else
				-- let's show both 2 & 4, it's nice to see the range
				texString = CreateTextureMarkup(v.tex .. "-2", 48, 24, 48, 24, 0, 1, 0, 1) .. "-  "
				texString = texString .. CreateTextureMarkup(v.tex .. "-4", 48, 24, 48, 24, 0, 1, 0, 1) .. " " .. v.name
			end


			style_KV_Table[newKey] = texString
			multiSparkStyles_Map[newKey] = v
		end
	end
	return style_KV_Table
end
getMultiSparkStylesKV() -- just call it once to instantiate our Map also

local function getMultiSparkStylesSorted()
	local style_Sort_Table = {}
	for k, v in ipairs(multiSparkStyles) do
		if not v.requirement or v.requirement() then
			local newKey = v.tex
			tinsert(style_Sort_Table, newKey)
		end
	end
	return style_Sort_Table
end

---@class SparkUIHelper
---@field type SparkTypes|number
---@field commID string
---@field radius number
---@field style integer|string
---@field x number
---@field y number
---@field z number
---@field mapID number
---@field overwriteIndex? number
---@field spellInputs? string
---@field cooldownTime? number|false
---@field cooldownTriggerSpellCooldown? boolean
---@field cooldownBroadcastToPhase? boolean
---@field requirement? string
---@field conditionsData? ConditionData
---@field emote? EmoteToken
---@field chat? string
---@field showHSI? boolean

---@type SparkUIHelper
local sparkUI_Helper = {
	type = 1,
	commID = "Type a CommID",
	radius = 5,
	style = defaultSparkPopupStyle,
	x = 0,
	y = 0,
	z = 0,
	mapID = 0,
	overwriteIndex = nil,
	spellInputs = nil,
	cooldownTime = false,
	cooldownTriggerSpellCooldown = false,
	cooldownBroadcastToPhase = false,
	requirement = nil,
	conditionsData = nil,
	showHSI = nil,
	uncastID = nil,
}

---@param num integer
---@return number
local function getPosData(num)
	return DataUtils.roundToNthDecimal(select(num, getPlayerPositionData()), 4)
end

---@param ... number|SparkTypes
---@return function
local function requiredSparkTypes(...)
	local t = {}
	for k, v in ipairs({ ... }) do
		t[v] = true
	end
	return function() return not t[sparkUI_Helper.type] end
end

local orderGroup = 0
local orderItem = 0
---Auto incrementing order number. Use isGroup true to increment the orderGroup and reset the orderItem counter.
---@param isGroup boolean?
---@return integer
local function autoOrder(isGroup)
	if isGroup then
		orderGroup = orderGroup + 1
		orderItem = 0
		return orderGroup
	else
		orderItem = orderItem + 1
		return orderItem
	end
end

--[[
	[1] = "Standard",
	[2] = "Multi",
	[3] = "Emote",
	[4] = "Chat",
	[5] = "Jump",
	[6] = "Auto",
]]
local function _updateCreateSparkUIHeight()
	local heights = {
		[_sparkTypesMap["Standard"]] = 500,
		[_sparkTypesMap["Multi"]] = 500,
		[_sparkTypesMap["Emote"]] = 510 - 50,
		[_sparkTypesMap["Chat"]] = 540 - 50,
		[_sparkTypesMap["Jump"]] = 490 - 50,
		[_sparkTypesMap["Auto"]] = 510 - 50,
	}

	local height = sparkUI_Helper.type and heights[sparkUI_Helper.type] or 500
	AceConfigDialog:SetDefaultSize(theUIDialogName, 600, height + 50)

	local openFrame = AceConfigDialog.OpenFrames[theUIDialogName]
	if openFrame then
		openFrame:SetHeight(height + 50)
	end
end

local function _openCreateSparkUI() -- Hook so we can force disable Resize lol
	AceConfigDialog:Open(theUIDialogName)
	AceConfigDialog.OpenFrames[theUIDialogName]:EnableResize(false)
end

local uiOptionsTable = {
	type = "group",
	desc = "test",
	name = "Arcanum - Spark Creator",
	args = {
		spellInfo = {
			name = "Spark Info",
			type = "group",
			inline = true,
			order = autoOrder(true),
			args = {
				sparkType = {
					name = "Spark Type",
					desc =
						"Type of Spark - This changes the behavior of the Spark & how you would interact with it.\n\r" ..
						Tooltip.genContrastText("Standard: ") .. "The Original, Classic style Single-Spell Pop-Up button.\n" ..
						Tooltip.genContrastText("Multi: ") .. "Spark that supports up to 4 Arc Spells shown at once.\n" ..
						Tooltip.genContrastText("Emote: ") .. "Invisible Spark that triggers when the given emote is performed while in radius (i.e., /kneel).\n" ..
						Tooltip.genContrastText("Chat: ") .. "Invisible Spark that triggers when a specified word or phrase is said in /say, /yell, or /emote while in radius.\n" ..
						Tooltip.genContrastText("Jump: ") .. "Invisible Spark that triggers any time you jump while within radius. Triggers each jump.\n" ..
						Tooltip.genContrastText("Auto: ") .. "Invisible Spark that triggers when a you walk in radius. Only casts once, until you leave & re-enter radius.\n" ..
						Tooltip.genContrastText("   WARNING: ") .. "Auto Sparks take away player choice & interaction. Please use sparingly and with careful consideration.",
					type = "select",
					order = autoOrder(),
					values = _sparkTypes,
					set = function(info, val)
						sparkUI_Helper.type = val
					end,
					get = function(info)
						_updateCreateSparkUIHeight()
						return sparkUI_Helper.type or 1
					end
				},
				gap = {
					type = "description",
					order = autoOrder(),
					width = 1,
					name = " ",
				},
				conditionsEditor = {
					type = "execute",
					name = function()
						if (sparkUI_Helper.requirement and #sparkUI_Helper.requirement > 0) or (sparkUI_Helper.conditionsData and #sparkUI_Helper.conditionsData > 0) then
							return "Edit Conditions"
						else
							return "Add Conditions"
						end
					end,
					desc = function()
						local lines = {
							"Sets conditions on this Spark. If the conditions are not met, then the Spark will not be shown at all.",
							" ",
						}
						if sparkUI_Helper.conditionsData and #sparkUI_Helper.conditionsData > 0 then
							tinsert(lines, "Current Conditions:")
							for gi, groupData in ipairs(sparkUI_Helper.conditionsData) do
								local groupString = (gi == 1 and "If") or "..Or"
								for ri, rowData in ipairs(groupData) do
									local continueStatement = (ri ~= 1 and "and ") or ""
									local condName = ns.Actions.ConditionsData.getByKey(rowData.Type).name
									groupString = string.join(" ", groupString, continueStatement .. condName)
								end
								tinsert(lines, groupString)
							end
						else
							tinsert(lines, "This Spark has no conditions. Click to add some!")
						end
						local str = ""
						local numLines = #lines
						for k, v in ipairs(lines) do
							str = str .. v .. (k ~= numLines and "\n" or "")
						end
						return str
					end,
					order = autoOrder(),
					width = 1,
					func = function()
						ns.UI.ConditionsEditor.open(sparkUI_Helper, "spark", sparkUI_Helper.conditionsData)
					end,
				},
				commID = {
					name = function()
						local msg = "ArcSpell"
						if sparkUI_Helper.type == 2 then
							msg = "ArcSpells (Multi)"
						end
						return msg
					end,
					desc = function()
						local msg = "CommID of the ArcSpell from the Phase Vault"
						if sparkUI_Helper.type == _sparkTypesMap["Multi"] then
							msg = "CommIDs for the ArcSpells (from the Phase Vault) to include in the Spark, separated by commas.\n\rSupports up to 4 ArcSpells/commIDs."
						end
						if sparkUI_Helper.type == _sparkTypesMap["Auto"] then
							msg = msg ..
								"\n\rMay be left blank on AutoSparks, in coordination with 'Cast On Leave', to not cast anything on enter, and only cast on leave, creating an 'inverse auto spark'."
						end
						return msg
					end,
					type = "input",
					dialogControl = "MAW-Editbox",
					order = autoOrder(),
					set = function(info, val) sparkUI_Helper.commID = val end,
					get = function(info) return sparkUI_Helper.commID end
				},
				arcSpellInputs = {
					name = "Spell Input(s)",
					dialogControl = "MAW-Editbox",
					desc =
					"Set your spell inputs, separated by commas. Wrap an input in \"quotes, if you want to include a comma\" in it.\n\rInput values can be used dynamically in an ArcSpell by using it's alias (@input#@) in an action's input.",
					type = "input",
					order = autoOrder(),
					get = function()
						return sparkUI_Helper.spellInputs
					end,
					set = function(info, val)
						if val and val ~= "" then
							sparkUI_Helper.spellInputs = val
						else
							sparkUI_Helper.spellInputs = nil
						end
					end,
					width = 2,
				},
				cooldownTime = {
					name = "Spark Cooldown Override",
					dialogControl = "MAW-Editbox",
					desc = "Sets a cooldown on this Spark. Spark Cooldowns override spell cooldowns, and only apply for this instance of the Spell.",
					type = "input",
					order = autoOrder(),
					get = function()
						if sparkUI_Helper.cooldownTime then
							return sparkUI_Helper.cooldownTime
						else
							return 0
						end
					end,
					set = function(info, val)
						if val and val ~= "" then
							sparkUI_Helper.cooldownTime = val
						else
							sparkUI_Helper.cooldownTime = nil
						end
					end,
					width = 0.8,
				},
				cooldownTriggerSpellCooldown = {
					type = "toggle",
					name = "Trigger Spell Cooldown",
					desc = "When enabled, the Spark will still toggle both it's own Cooldown, and the Spells' cooldown.\nIf disabled, only this Spark's cooldown is triggered.",
					order = autoOrder(),
					get = function()
						if sparkUI_Helper.cooldownTriggerSpellCooldown ~= nil then
							return sparkUI_Helper.cooldownTriggerSpellCooldown
						else
							return false
						end
					end,
					set = function(info, val)
						sparkUI_Helper.cooldownTriggerSpellCooldown = val
					end,
					disabled = function() return not sparkUI_Helper.cooldownTime end,
					width = 1.2,
				},
				cooldownBroadcastToPhase = {
					type = "toggle",
					name = "Broadcast Cooldown",
					desc =
					"When enabled, the Spark Cooldown is sent to everyone in the phase, and they will have the same cooldown.\n\rNote: The main spells' cooldown is NOT triggered for them, ONLY this single Spark's!\n\rNote note: This is broadcast to the phase when triggered; if anyone joins the phase AFTER, they will NOT be subject to the cooldown. Deal with it.",
					order = autoOrder(),
					get = function()
						if sparkUI_Helper.cooldownBroadcastToPhase ~= nil then
							return sparkUI_Helper.cooldownBroadcastToPhase
						else
							return false
						end
					end,
					set = function(info, val)
						sparkUI_Helper.cooldownBroadcastToPhase = val
					end,
					disabled = function() return not sparkUI_Helper.cooldownTime end,
					width = 1,
				},
				--[[
				requirementScript = {
					name = "Spark Requirement (Script)",
					dialogControl = "MAW-Editbox",
					desc =
						"Sets a requirement on this Spark via a script. If the script does not return a true value, then the Spark will not be shown. Leave blank to not have any requirement.\n\rExample Scripts:\n" ..
						Tooltip.genContrastText("ARC.XAPI.HasItem(19222)") ..
						" to only show if they have atleast one \124cff1eff00\124Hitem:19222::::::::70:::::\124h[Cheap Beer]\124h\124r item." .. "\n\r" ..
						Tooltip.genContrastText("ARC.XAPI.HasAura(131437)") .. " to only show if they have \124cff71d5ff\124Hspell:131437\124h[See Quest Invis 9]\124h\124r aura." .. "\n\r" ..
						Tooltip.genContrastText("GetItemCount(108499) >= 23") ..
						" to only show if they have 23 or more \124cff1eff00\124Hitem:108499::::::::70:::::\124h[Soothepetal Flower]\124h\124r in their inventory." .. "\n\r" ..
						Tooltip.genContrastText("ARC.PHASE.IsMember()") .. " to only show if they are a Member of the Phase.",
					type = "input",
					order = autoOrder(),
					get = function()
						if sparkUI_Helper.requirement then
							return sparkUI_Helper.requirement
						else
							return false
						end
					end,
					set = function(info, val)
						if val and val ~= "" then
							sparkUI_Helper.requirement = val
						else
							sparkUI_Helper.requirement = nil
						end
					end,
					width = "half",
				},
				--]]
				spacer2 = {
					name = " ",
					type = "description",
					width = "full",
					order = autoOrder(),
				},
				uncastID = {
					name = "Cast on Leave (Uncast)",
					desc = "Casts another ArcSpell, by CommID (from Phase Vault), when leaving the radius of the Auto Spark.\rRespects Spark Cooldown Overrides if given (for uncast only).",
					type = "input",
					dialogControl = "MAW-Editbox",
					order = autoOrder(),
					hidden = requiredSparkTypes(6),
					set = function(info, val)
						if val == "" then val = nil end -- Force blank into nil, otherwise it tries to cast "" lol..
						sparkUI_Helper.uncastID = val
					end,
					get = function(info) return sparkUI_Helper.uncastID end
				},
				style = { -- This is for Standard Sparks ONLY
					name = "Border Style",
					desc = "The decorative border around the Spark spell icon",
					type = "select",
					width = 1.5,
					values = getSparkPopupStylesKV,
					sorting = getSparkPopupStylesSorted,
					order = autoOrder(),
					hidden = requiredSparkTypes(1),
					set = function(info, val)
						if val == addNewSparkPopupStyleTex then
							ns.UI.Popups.showCustomGenericInputBox({
								text = "Texture Path or FileID:",
								acceptText = ADD,
								maxLetters = 999,
								callback = function(texPath)
									if tonumber(texPath) then texPath = tonumber(texPath) end
									local newKey = texPath -- path

									customStyleTexIter = customStyleTexIter + 1
									local styleData = {
										tex = newKey,
										name = "Custom Texture " .. customStyleTexIter
									}
									tinsert(sparkPopupStyles, styleData)
									sparkPopupStyles_Map[newKey] = styleData

									sparkUI_Helper.style = newKey
									_openCreateSparkUI()
								end,
							})
							return
						end
						sparkUI_Helper.style = val
					end,
					get = function(info)
						if not sparkUI_Helper.style then sparkUI_Helper.style = 629199 end -- this forces the style if switching from non-visual spark type
						if multiSparkStyles_Map[sparkUI_Helper.style] then
							-- the style is a multi one, we should overwrite it to a default standard style
							sparkUI_Helper.style = 629199
						end

						return sparkUI_Helper.style
					end
				},
				multiStyle = { -- This is for Multi Sparks ONLY
					name = "Backdrop Style (Multi)",
					desc = "The decorative backdrop behind the Spark's spell icons",
					type = "select",
					width = 1.5,
					values = getMultiSparkStylesKV,
					sorting = getMultiSparkStylesSorted,
					order = autoOrder(),
					hidden = requiredSparkTypes(2),
					set = function(info, val)
						if val == addNewSparkPopupStyleTex then
							ns.UI.Popups.showCustomGenericInputBox({
								text = "Texture Path or FileID:",
								acceptText = ADD,
								maxLetters = 999,
								callback = function(texPath)
									if tonumber(texPath) then texPath = tonumber(texPath) end
									local newKey = texPath -- path

									customStyleTexIter = customStyleTexIter + 1
									local styleData = {
										tex = newKey,
										name = "Custom Texture " .. customStyleTexIter
									}
									tinsert(multiSparkStyles, styleData)
									multiSparkStyles_Map[newKey] = styleData

									sparkUI_Helper.style = newKey
									_openCreateSparkUI()
								end,
							})
							return
						end
						sparkUI_Helper.style = val
					end,
					get = function(info)
						if not sparkUI_Helper.style then sparkUI_Helper.style = multiSparkStyles[1].tex end -- this forces the style if switching from non-visual spark type
						if sparkPopupStyles_Map[sparkUI_Helper.style] then
							-- the style is a standard one, we should overwrite it to a default multi style
							sparkUI_Helper.style = multiSparkStyles[1].tex
						end

						return sparkUI_Helper.style
					end
				},
				styleColor = {
					name = ADDON_COLORS.GAME_GOLD:WrapTextInColorCode("Border Tint"),
					desc = "Tint the Border Style",
					type = "color",
					width = 0.75,
					order = autoOrder(),
					hidden = requiredSparkTypes(1, 2),
					set = function(info, vR, vG, vB)
						if vR and vG and vB then
							sparkUI_Helper.color = CreateColor(vR, vG, vB):GenerateHexColor()
						else
							sparkUI_Helper.color = nil
						end
					end,
					get = function(info)
						if sparkUI_Helper.color then
							return CreateColorFromHexString(sparkUI_Helper.color):GetRGB()
						else
							return 1, 1, 1
						end
					end
				},
				resetColor = {
					type = "execute",
					name = "Reset Tint",
					order = autoOrder(),
					hidden = requiredSparkTypes(1, 2),
					width = 0.75,
					func = function()
						sparkUI_Helper.color = nil
					end,
				},
				stylePreviewTitle = {
					type = "description",
					name = "\nBorder Preview:",
					hidden = requiredSparkTypes(1, 2),
					order = autoOrder(),
				},
				stylePreview = {
					--name = ""
					name = function()
						if not sparkUI_Helper.style then return "No Preview" end
						local vR, vG, vB = 255, 255, 255
						if sparkUI_Helper.color then vR, vG, vB = CreateColorFromHexString(sparkUI_Helper.color):GetRGBAsBytes() end

						local style = sparkUI_Helper.style

						-- For Multi-Sparks, ensure our border accounts for needing a "-number" at the end.
						if type(style) == "string" and isSparkType(sparkUI_Helper.type, _sparkTypesMap["Multi"]) then
							style = style .. "-2"
						end

						local texString
						local isAtlas = (type(style) == "string") and C_Texture.GetAtlasInfo(style)
						if isAtlas then
							texString = CreateAtlasMarkup(style, 64 * 2, 32 * 2, 0, 0, vR, vG, vB)
						else
							texString = ns.Utils.UIHelpers.CreateTextureMarkupWithColor(style, 64 * 2, 32 * 2, 64 * 2, 32 * 2, 0, 1, 0, 1, 0, 0, vR, vG, vB)
						end

						return texString
					end,
					type = "header",
					width = "full",
					order = autoOrder(),
					hidden = requiredSparkTypes(1, 2),
					--image = function() return sparkUI_Helper.style, 64 * 2, 32 * 2 end,
				},
				emoteTrigger = {
					name = "Activation Emote",
					desc = "The Emote required to activate / trigger this Spark, when in radius.",
					type = "select",
					values = emotesMap,
					order = autoOrder(),
					hidden = requiredSparkTypes(_sparkTypesMap["Emote"]),
					get = function()
						return sparkUI_Helper.emote
					end,
					set = function(info, val) sparkUI_Helper.emote = val end,
				},
				chatText = {
					name = "Chat Text (say|yell|emote)",
					desc = "The word or phrase required to activate / trigger this Spark, when in radius.",
					dialogControl = "MAW-Editbox",
					type = "input",
					width = "full",
					order = autoOrder(),
					hidden = requiredSparkTypes(_sparkTypesMap["Chat"]),
					get = function() return sparkUI_Helper.chat end,
					set = function(info, val) sparkUI_Helper.chat = val end,
				},
				showHiddenSparkIcon = {
					type = "toggle",
					name = "Show 'Spark Nearby' Icon",
					desc =
					"When enabled, shows a small 'Hidden Spark' icon underneath where visual Sparks would normally show.\n\rThink of it like a 'clue' they're in the right place to do the thing.",
					order = autoOrder(),
					get = function()
						if sparkUI_Helper.showHSI == nil then
							sparkUI_Helper.showHSI = true
						end

						return sparkUI_Helper.showHSI
					end,
					set = function(info, val)
						sparkUI_Helper.showHSI = val
					end,
					hidden = requiredSparkTypes(_sparkTypesMap["Chat"], _sparkTypesMap["Emote"], _sparkTypesMap["Jump"]),
					width = 1.5,
				},
				spacer = {
					name = " ",
					type = "description",
					width = "full",
					order = autoOrder(),
				},
			}
		},
		locationInfo = {
			name = "Trigger Location (Default: Your current location)",
			type = "group",
			inline = true,
			order = autoOrder(true),
			args = {
				xPos = {
					name = "X",
					desc = "The X Coordinate of the Trigger. Default is your current location.",
					type = "input",
					dialogControl = "MAW-Editbox",
					width = 0.85,
					validate = function(info, val) return tonumber(val) end,
					order = autoOrder(),
					set = function(info, val) sparkUI_Helper.x = (tonumber(val) and tonumber(val) or tonumber(getPosData(1))) end,
					get = function(info) return sparkUI_Helper.x and tostring(sparkUI_Helper.x) or tostring(getPosData(1)) end,
				},
				yPos = {
					name = "Y",
					desc = "The Y Coordinate of the Trigger. Default is your current location.",
					type = "input",
					dialogControl = "MAW-Editbox",
					width = 0.85,
					validate = function(info, val) if tonumber(val) then return true else return "You need to supply a valid number!" end end,
					order = autoOrder(),
					set = function(info, val) sparkUI_Helper.y = (tonumber(val) and tonumber(val) or tonumber(getPosData(2))) end,
					get = function(info) return sparkUI_Helper.y and tostring(sparkUI_Helper.y) or tostring(getPosData(2)) end,
				},
				zPos = {
					name = "Z",
					desc = "The Z Coordinate of the Trigger. Default is your current location.",
					type = "input",
					dialogControl = "MAW-Editbox",
					width = 0.85,
					validate = function(info, val) if tonumber(val) then return true else return "You need to supply a valid number!" end end,
					order = autoOrder(),
					set = function(info, val) sparkUI_Helper.z = (tonumber(val) and tonumber(val) or tonumber(getPosData(3))) end,
					get = function(info) return sparkUI_Helper.z and tostring(sparkUI_Helper.z) or tostring(getPosData(3)) end,
				},
				hereButton = {
					type = "execute",
					name = "Here",
					desc = "Set the X, Y, Z, and Map ID to your current position.",
					order = autoOrder(),
					width = 0.5,
					func = function()
						local posX = tonumber(getPosData(1))
						local posY = tonumber(getPosData(2))
						local posZ = tonumber(getPosData(3))
						local mapID = tonumber(getPosData(4))
						sparkUI_Helper.x = posX
						sparkUI_Helper.y = posY
						sparkUI_Helper.z = posZ
						sparkUI_Helper.mapID = mapID
					end,
				},
				mapID = {
					name = "Map ID",
					desc = "The Map ID to place the Trigger on. Default is your current map.",
					type = "input",
					dialogControl = "MAW-Editbox",
					pattern = "%d+",
					validate = function(info, val) if tonumber(val) then return true else return "You need to supply a valid number!" end end,
					order = autoOrder(),
					set = function(info, val) sparkUI_Helper.mapID = tonumber(val) end,
					get = function(info) return sparkUI_Helper.mapID and tostring(sparkUI_Helper.mapID) or tostring(getPosData(4)) end,
				},
				radius = {
					name = "Radius",
					desc = "How close to the point a player must be to show the Spark.\n\rYou can manually input numbers bigger than 20 if you need a larger radius.",
					type = "range",
					dialogControl = "MAW-Slider",
					min = 0,
					max = 99999999999,
					softMin = 0.25,
					softMax = 20,
					bigStep = 0.25,
					width = "double",
					order = autoOrder(),
					set = function(info, val) sparkUI_Helper.radius = val end,
					get = function(info) return sparkUI_Helper.radius end,
				},
			},
		},
		createButton = {
			type = "execute",
			name = function() if sparkUI_Helper.overwriteIndex then return "Save Spark" else return "Create Spark" end end,
			width = "full",
			func = function(info)
				SparkPopups.SparkPopups.addPopupTriggerToPhaseData(sparkUI_Helper.commID, sparkUI_Helper.radius, sparkUI_Helper.style, sparkUI_Helper.x, sparkUI_Helper.y, sparkUI_Helper.z,
					sparkUI_Helper.color,
					sparkUI_Helper.mapID,
					{
						cooldownTime = sparkUI_Helper.cooldownTime,
						trigSpellCooldown = sparkUI_Helper.cooldownTriggerSpellCooldown,
						broadcastCooldown = sparkUI_Helper.cooldownBroadcastToPhase,
						inputs = sparkUI_Helper.spellInputs,
						conditions = sparkUI_Helper.conditionsData,
						emote = sparkUI_Helper.emote,
						chat = sparkUI_Helper.chat,
						showHSI = sparkUI_Helper.showHSI,
						uncast = ((sparkUI_Helper.type == _sparkTypesMap["Auto"]) and sparkUI_Helper.uncastID or nil),
					},
					sparkUI_Helper.overwriteIndex, sparkUI_Helper.type)
				AceConfigDialog:Close(theUIDialogName)
			end,
		},
	}
}

AceConfig:RegisterOptionsTable(theUIDialogName, uiOptionsTable)
AceConfigDialog:SetDefaultSize(theUIDialogName, 600, 495 + 50)

---@param num number the number to verify if it's a number
---@return number
local function verifyNumber(num)
	if num then return num else return 99999999 end
end

---comment
---@param commID CommID
---@param editIndex integer?
---@param editMapID integer?
local function openSparkCreationUI(commID, editIndex, editMapID)
	table.wipe(sparkUI_Helper) -- clear any old data

	sparkUI_Helper.overwriteIndex = editIndex or nil
	sparkUI_Helper.commID = commID

	local sparkType, x, y, z, mapID, radius, style, colorHex, cooldownTime, cooldownTriggerSpellCooldown, cooldownBroadcastToPhase, requirement, spellInputs, conditions
	local emote, chat, showHSI, uncastID
	if editIndex then
		local phaseSparkTriggers = SparkPopups.SparkPopups.getPhaseSparkTriggersCache()
		local triggerData = phaseSparkTriggers[editMapID][editIndex] --[[@as SparkTriggerData]]
		x, y, z, mapID, radius, style, colorHex = triggerData[2], triggerData[3], triggerData[4], editMapID, triggerData[5], triggerData[6], triggerData[7]
		sparkType = triggerData[9] or 1
		local sparkOptions = triggerData[8] --[[@as SparkTriggerDataOptions]]
		if sparkOptions ~= nil then
			cooldownTime, cooldownTriggerSpellCooldown, cooldownBroadcastToPhase = sparkOptions.cooldownTime, sparkOptions.trigSpellCooldown, sparkOptions.broadcastCooldown
			requirement = sparkOptions.requirement -- Kept for back compatibility, should not be used going forward
			conditions = sparkOptions.conditions
			spellInputs = sparkOptions.inputs
			emote = sparkOptions.emote
			chat = sparkOptions.chat
			showHSI = sparkOptions.showHSI
			uncastID = sparkOptions.uncast
		end
	else
		sparkType = 1
		radius = 5
		x, y, z, mapID = getPlayerPositionData()
		style = defaultSparkPopupStyle
		colorHex = "ffffffff"
		cooldownTime = false
		cooldownTriggerSpellCooldown = false
		cooldownBroadcastToPhase = false
		requirement = nil
		spellInputs = nil
		showHSI = true
		uncastID = nil
		-- the nils here are not actually needed to specify but are written to ensure I don't forget them I guess.
	end

	x, y, z = DataUtils.roundToNthDecimal(verifyNumber(x), 4), DataUtils.roundToNthDecimal(verifyNumber(y), 4), DataUtils.roundToNthDecimal(verifyNumber(z), 4)
	sparkUI_Helper.x, sparkUI_Helper.y, sparkUI_Helper.z, sparkUI_Helper.mapID, sparkUI_Helper.radius, sparkUI_Helper.style, sparkUI_Helper.color = x, y, z, mapID, radius, style, colorHex
	sparkUI_Helper.cooldownTime, sparkUI_Helper.cooldownTriggerSpellCooldown, sparkUI_Helper.cooldownBroadcastToPhase = cooldownTime, cooldownTriggerSpellCooldown, cooldownBroadcastToPhase
	sparkUI_Helper.requirement = requirement
	sparkUI_Helper.conditionsData = conditions
	sparkUI_Helper.spellInputs = spellInputs
	sparkUI_Helper.type = sparkType
	sparkUI_Helper.emote = emote
	sparkUI_Helper.chat = chat
	sparkUI_Helper.showHSI = showHSI
	sparkUI_Helper.uncastID = uncastID

	if (sparkUI_Helper.requirement and #sparkUI_Helper.requirement > 0) then
		-- convert old requirement
		local newData = {
			Type = "script",
			Input = sparkUI_Helper.requirement
		}
		sparkUI_Helper.conditionsData = { { newData } }
		sparkUI_Helper.requirement = nil
	end

	_openCreateSparkUI()
end

local function closeSparkCreationUI()
	AceConfigDialog:Close(theUIDialogName)
end

---@class UI_SparkPopups_CreateSparkUI
ns.UI.SparkPopups.CreateSparkUI = {
	openSparkCreationUI = openSparkCreationUI,
	closeSparkCreationUI = closeSparkCreationUI,

	sparkPopupStyles = sparkPopupStyles,
	sparkPopupStyles_Map = sparkPopupStyles_Map,
	getSparkStyles = getSparkPopupStylesKV,
	--sparkPopupStyles = sparkPopupStylesKVTable,

	isSparkType = isSparkType,

	sparkTypes = _sparkTypes,
	sparkTypesMap = _sparkTypesMap,
	getSparkTypeIDByName = getSparkTypeIDByName,

	emotesList = emotesList,
	emotesMap = emotesMap,
}
