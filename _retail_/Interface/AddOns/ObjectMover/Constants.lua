local addonName = ...
---@class ns
local ns = select(2, ...)

local ADDON_NAME = addonName:gsub("%-dev", "")
local ADDON_TITLE = GetAddOnMetadata(addonName, "Title")
local ADDON_PATH = "Interface/AddOns/" .. tostring(addonName)
local ASSET_PATH = ADDON_PATH .. "/media"

local colors = {
	addon_color = CreateColorFromHexString("ffFFA600"),
	disabled = CreateColor(0.66, 0.66, 0.66, 1), -- Disabled Grey

	soft_red = CreateColor(0.8, 0.2, 0.2, 1),  -- Soft Red
	soft_blue = CreateColor(0.2, 0.2, 0.8, 1), -- Soft Blue
	soft_green = CreateColor(0.2, 0.8, 0.2, 1), -- Soft Green
	soft_yellow = CreateColor(0.8, 0.8, 0.2, 1), -- Soft Yellow

	pastel_red = CreateColor(1, 0.75, 0.75, 1), -- Pastel Red
	pastel_blue = CreateColor(0.75, 0.75, 1, 1), -- Pastel Blue
	pastel_green = CreateColor(0.75, 1, 0.75, 1), -- Pastel Green

	red = CreateColor(0.6, 0.1, 0, 1),         -- Red
	green = CreateColor(0.1, 0.6, 0, 1),       -- Green
	blue = CreateColor(0, 0, 1, 1),            -- Blue
	yellow = CreateColor(1, 1, 0, 1),          -- Yellow

	neon_blue = CreateColor(0.1, 0.8, 1, 1),   -- Neon Blue

	game_gold = CreateColor(1, 0.82, 0, 1),    -- game gold
	white = CreateColor(1, 1, 1, 1),

	BRILLIANT_GREEN = CreateColorFromHexString("ff57F287"),      -- 57F287 : Brilliant Green
	HYPER_GREEN = CreateColorFromHexString("FF00FF51"),          -- 00FF51 : Hyper Green
	MINT_GREEN = CreateColorFromHexString("ff85FF85"),           -- 85FF85 : Mint Green
	LIGHT_PURPLE = CreateColorFromHexString("ffAAAAFF"),         -- AAAAFF : Light Purple
	BURNT_SIENA = CreateColorFromHexString("ffAA6F6F"),          -- AA6F6F : Dark Red
	ORANGE_GOLD = CreateColorFromHexString("ffFFA600"),          -- FFA600 : Orange-Gold
	MID_GREY = CreateColorFromHexString("ffAAAAAA"),             -- AAAAAA : Mid Grey
	LIGHT_RED = CreateColorFromHexString("FFFFAAAA"),            -- FFAAAA : Light Red
	GENTLE_RED = CreateColorFromHexString("FFD74B4B"),           -- FFAAAA : Light Red
	FULL_RED = CreateColorFromHexString("FFFF0000"),             -- FF0000 : Bright Red
	LIGHT_BLUE_ALMOST_WHITE = CreateColorFromHexString("FFd7eef1"), -- d7eef1 : Light Light Blue
	LIGHT_BLUE = CreateColorFromHexString("ff71d5ff"),           -- 71d5ff : Light Blue / Cyan
	MID_CYAN = CreateColorFromHexString("ff00d8ff"),             -- 71d5ff : Light Blue / Cyan
	TEAL = CreateColorFromHexString("FF04BABE"),

	GAME_GREY = CreateColor(0.8, 0.8, 0.8), -- "FFCCCCCC"

	OM_PURE_DARK_RED = CreateColorFromHexString("FF640000"),
	OM_DARK_RED = CreateColorFromHexString("ff642021"), -- 642021 : Dark Red
	OM_BRONZE_GOLD = CreateColorFromHexString("ffBFA06A"), -- BFA06A : Bronze Gold
}

---@class NS_Constants
ns.Constants = {
	colors = colors,

	ADDON_COLOR = colors.addon_color,
	ADDON_NAME = ADDON_NAME,
	ADDON_TITLE = ADDON_TITLE,
	ADDON_PATH = ADDON_PATH,
	ASSET_PATH = ASSET_PATH,
}

------
---

OPMasterTable = {
	Options = {
		debug = false,
		SliderStep = 0.01,
		locked = false,
		fadePanel = false,
		autoShow = false,
		autoShowPopout = false,
		wasPopoutShown = false,
		showMessages = false,
		showTooltips = true,
		MovePlayer = false,
		useOverlayMethod = false,
		autoUpdateRot = true,
		autoUpdateTint = true,
		autoUpdateScale = true,
		autoUpdateObjectID = true,
		autoUpdateParams = true,
		autoUpdateColor = true,
	},
	ParamPresetKeys = { "Building Tile", "Fine Positioning" },
	ParamPresetContent = {
		["Building Tile"] = {
			["ObjectID"] = false,
			["Length"] = 4,
			["Width"] = 4,
			["Height"] = 0.25,
			["Scale"] = 1,
		},
		["Fine Positioning"] = {
			["ObjectID"] = false,
			["Length"] = 0.01,
			["Width"] = 0.01,
			["Height"] = 0.01,
			["Scale"] = 1,
		},
	},
	RotPresetKeys = { "Reset (0,0,0)" },
	RotPresetContent = {
		["Reset (0,0,0)"] = {
			["RotX"] = 0,
			["RotY"] = 0,
			["RotZ"] = 0,
		},
	},
}
local default_db = OPMasterTable

---Loads a settings table into a master table, but does not over-write if data is already present
---@param settings table The Default Settings to Copy
---@param master table The Actual Table to hold the settings (aka: your global table saved)
local function loadDefaultsIntoMaster(settings, master)
	for k, v in pairs(settings) do
		if (type(v) == "table") then
			if (master[k] == nil or type(master[k]) ~= "table") then master[k] = {} end
			loadDefaultsIntoMaster(v, master[k]);
		else
			if master and master[k] == nil then
				master[k] = v;
			end
		end
	end
end

local function loadAddonSavedVariables()
	loadDefaultsIntoMaster(default_db, OPMasterTable)
end

local f = CreateFrame("FRAME")
f:RegisterEvent("ADDON_LOADED");
f:SetScript("OnEvent", function(self, event, name)
	if name == addonName then
		loadAddonSavedVariables()
	end
end)
