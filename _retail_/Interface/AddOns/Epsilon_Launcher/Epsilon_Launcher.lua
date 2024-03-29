---@class ns
local ns = select(2, ...)

-------------------------------------------------------------------------------
-- Epsilon Mini-Map Launcher Tray System
--
-- Looking to add your AddOn's icon to the tray?
-- Usage: LibStub("EpsiLauncher-1.0").API.new(name, func, icon, lines, ttOptions)
--
-- name				Either a the name (string), or alternatively a pre-made button frame to use. If using a pre-made button, you can skip the rest. If name is string, it's used as both the ID and the name in the tooltip.
-- func? 			The function to run when clicked. For instance, showing a frame for a simple frame toggle icon button
-- icon? 			The string of the texture to use as the icon. Must be a single texture, and does not include any other fluff. Use a premade button if you need more fluff.
-- lines? 			A string, or an array of strings, to add to the tooltip. Optionally can be a function that generates such lines dynamically.
-- ttOptions? 		TooltipOptions Table - See below for more information on what this can be used for.
--
--
-- TooltipOptions Table Fields:
-- updateOnClick boolean?			- If the Tooltip should refresh when the icon is clicked (Useful for toggles where the tooltip shows the status)
-- delay (integer | function)?		- If there should be any delay when opening the tooltip - Likely should not be used in this case
-- anchor string?					- Idk, just don't use this, let it anchor default
-- predicate function?				- An optional function to determine if the tooltip is shown. Function must return true to show.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Initialize Variables
-------------------------------------------------------------------------------

local ADDON_NAME = ...
local addonVersion, addonAuthor, addonName = GetAddOnMetadata(ADDON_NAME, "Version"),
	GetAddOnMetadata(ADDON_NAME, "Author"), GetAddOnMetadata(ADDON_NAME, "Title")

local tooltip = ns.Utils.Tooltip

local addon = LibStub("AceAddon-3.0"):NewAddon(ADDON_NAME)

local LDB = LibStub("LibDataBroker-1.1")
local icon = LibStub("LibDBIcon-1.0")

local CONSTANTS = {}
CONSTANTS.addonPath = "Interface/AddOns/" .. tostring(ADDON_NAME)
CONSTANTS.assetsPath = CONSTANTS.addonPath .. "/assets/"
CONSTANTS.addon = {}
CONSTANTS.addon.version = addonVersion
CONSTANTS.addon.name = addonName
CONSTANTS.addon.author = addonAuthor

local tray_MaxCol = 4

Epsilon_Launcher_DB = {}

local _defaultDB = {
	profile = {
		minimap = {
			hide = false,
			maxCols = 4
		},
	},
}
addon.db = LibStub("AceDB-3.0"):New("Epsilon_Launcher_DB", _defaultDB, true)

-------------------------------------------------------------------------------
-- Custom Prints & Utility
-------------------------------------------------------------------------------

local function dprint(text, force, rest)
	if force == true or Epsilon_Launcher_DB.Options["debug"] then
		local line = strmatch(debugstack(2), ":(%d+):")
		if line then
			print("|cffFFD700" ..
				addonName .. " DEBUG " .. line .. ": " .. text .. (rest and " | " .. rest or "") .. " |r")
		else
			print("|cffFFD700" .. addonName .. " DEBUG: " .. text .. (rest and " | " .. rest or "") .. " |r")
			print(debugstack(2))
		end
	end
end

local function eprint(text, rest)
	local line = strmatch(debugstack(2), ":(%d+):")
	if line then
		print("|cffFFD700 " ..
			addonName .. " Error @ " .. line .. ": " .. text .. " | " .. (rest and " | " .. rest or "") .. " |r")
	else
		print("|cffFFD700 " .. addonName .. " @ ERROR: " .. text .. " | " .. rest .. " |r")
		print(debugstack(2))
	end
end

local noop = function(...) return ... end


local initFuncs = {}
local initAlreadyRan
local function runOnInit(func)
	if initAlreadyRan then return false end
	tinsert(initFuncs, func)
	return true
end

-------------------------------------------------------------------------------
-- Main
-------------------------------------------------------------------------------

local arrow
local minimapButton
local tray = CreateFrame("Frame", nil, UIParent, "TooltipBackdropTemplate")
tray:SetSize(10, 32)
tray:SetBackdropBorderColor(1, 0.75, 0)
tray:Hide()

--[[
tray.bg = tray:CreateTexture(nil, "BACKGROUND")
tray.bg:SetAllPoints()
tray.endcap = tray:CreateTexture(nil, "BACKGROUND")
--]]

tray.anim = tray:CreateAnimationGroup()
tray.anim.scale = tray.anim:CreateAnimation("Scale")
tray.anim.scale:SetFromScale(0, 0)
tray.anim.scale:SetToScale(1, 1)
tray.anim.scale:SetDuration(1)
tray.anim.scale:SetOrigin("TOPRIGHT", 0, 0)
tray.anim.scale:SetSmoothing("IN_OUT")

tray.anim.alpha = tray.anim:CreateAnimation("Alpha")
tray.anim.alpha:SetFromAlpha(0)
tray.anim.alpha:SetToAlpha(1)
tray.anim.alpha:SetStartDelay(0)
tray.anim.alpha:SetDuration(0.5)
tray.anim.alpha:SetSmoothing("IN_OUT")

local function onAlphaFinish()
	if not tray.anim.dir then
		tray:Hide() -- insert: everything is awesome song, but instead of awesome, hard coded
	end
end

tray.anim.alpha:SetScript("OnFinished", onAlphaFinish)
tray.anim.dir = true

local function setTrayAnims(open)
	tray.anim.dir = open
	if open then -- open
		tray.anim.scale:SetFromScale(0, 0)
		tray.anim.scale:SetToScale(1, 1)

		tray.anim.alpha:SetFromAlpha(0)
		tray.anim.alpha:SetToAlpha(1)
		tray.anim.alpha:SetStartDelay(0)
	else -- close
		tray.anim.scale:SetFromScale(1, 1)
		tray.anim.scale:SetToScale(0, 0)

		tray.anim.alpha:SetFromAlpha(1)
		tray.anim.alpha:SetToAlpha(0)
		tray.anim.alpha:SetStartDelay(0.25)
	end

	if tray.anim.scale:IsPlaying() then tray.anim.scale:Stop() end
	if tray.anim.alpha:IsPlaying() or tray.anim.alpha:IsDelaying() then tray.anim.alpha:Stop() end

	tray.anim.scale:Play()
	tray.anim.alpha:Play()
end


local lastTrayCount
local trayIcons = {}

local function updateTraySizeLayout()
	local numIcons = #trayIcons
	lastTrayCount = numIcons

	local tray_MaxCol = addon.db.profile.minimap.maxCols or tray_MaxCol

	local numRows = math.ceil(numIcons / tray_MaxCol)

	tray:SetHeight(numRows * 26 + 12)

	if numIcons < tray_MaxCol then
		tray:SetWidth((26 * numIcons) + 12)
	else
		tray:SetWidth((26 * tray_MaxCol) + 12)
	end

	for i = 1, numIcons do
		local icon = trayIcons[i]
		if i == 1 then
			icon:SetPoint("TOPRIGHT", tray, "TOPRIGHT", -7, -7)
		else
			local colNumber = ((i - 1) % tray_MaxCol) + 1
			if colNumber == 1 then
				icon:SetPoint("TOPRIGHT", trayIcons[i - tray_MaxCol], "BOTTOMRIGHT", 0, -2)
			else
				icon:SetPoint("TOPRIGHT", trayIcons[i - 1], "TOPLEFT", -2, 0)
			end
		end
	end
end

---@param mmIcon frame
local function genLauncherTray(mmIcon)
	tray:SetParent(mmIcon)
	tray:SetPoint("TOPRIGHT", mmIcon, "TOPLEFT", 0, 3)

	local arrowHolder = CreateFrame("Frame", nil, mmIcon)
	arrow = arrowHolder:CreateTexture(nil, "OVERLAY")
	arrow:SetSize(8, 16)
	arrow:SetTexture(CONSTANTS.assetsPath .. "EpsilonTrayArrowOut")
	arrow:SetPoint("RIGHT", mmIcon, "LEFT", 3, 0)

	arrow.flip = function(self, open)
		if open then
			self:SetTexture(CONSTANTS.assetsPath .. "EpsilonTrayArrow")
		else
			self:SetTexture(CONSTANTS.assetsPath .. "EpsilonTrayArrowOut")
		end
	end

	tray._Icons = mmIcon._Icons -- duplicate the reference for easy access

	updateTraySizeLayout()
end

local function openLauncherTray()
	if #trayIcons ~= lastTrayCount then
		updateTraySizeLayout()
	end

	--setTrayAnims(true)
	tray:Show()
	arrow:flip(true)
end

local function closeLauncherTray()
	--setTrayAnims(false)
	tray:Hide()
	arrow:flip(false)
end

local function toggleLauncherTray()
	local trayOpen = tray:IsShown()
	if trayOpen then closeLauncherTray() else openLauncherTray() end
end

---@param name string|frame The name, or alternatively a pre-made button frame to use.
---@param func? function OnClick function
---@param icon? string
---@param lines? string[] | string | fun(self): (string[] | string)
---@param ttOptions? TooltipOptions
local function registerTrayIcon(name, func, icon, lines, ttOptions)
	local f
	if type(name) == "table" then -- icon can be an actual frame already made instead if you want to use a pre-made. I.e., registering Arcanum..
		f = name
		f:SetParent(tray --[[@as frame]])
		f:SetScript("OnDragStart", noop)
	else
		if not name or not func or not icon then return error("registerTrayIcon usage invalid. Refer to annotations.") end
		f = CreateFrame("Button", nil, tray)
		f:SetSize(24, 24)
		f:SetNormalTexture(icon --[[@as string]])
		f:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight", "ADD")

		if func then f:SetScript("OnClick", func) end

		ns.Utils.Tooltip.set(f, name, lines, ttOptions)
	end

	--[[
	if #trayIcons > 0 then
		local lastIcon = trayIcons[#trayIcons]
		f:SetPoint("RIGHT", lastIcon, "LEFT", 0, 0)
	else
		f:SetPoint("TOPRIGHT", tray, "TOPRIGHT", -2, -2)
	end
	--]]
	-- handled in updateTraySizeLayout

	tinsert(trayIcons, f)


	if not initAlreadyRan then -- Tray is not initialized yet, delay the call until it is
		runOnInit(function() tray._Icons[name] = f end)
	else
		tray._Icons[name] = f
	end

	updateTraySizeLayout()

	return f
end

-------------------------------------------------------------------------------
-- Options Table
-------------------------------------------------------------------------------
local orderGroup = 0
local orderItem = 0
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

local addonOptions = {
	name = "Epsilon Minimap Launcher Tray - Options",
	handler = addon,
	type = "group",
	args = {
		hide = {
			type = "toggle",
			name = "Disable Mini-Map Icon",
			desc = "Effectively disables this AddOn.\nBut why?",
			order = autoOrder(),
			arg = function() minimapButton:SetShown(not minimapButton:IsShown()) end,
			get = "GenericGetter",
			set = "GenericSetter"
		},
		spacer = {
			name = " ",
			type = "description",
			width = "full",
			order = autoOrder(),
		},
		maxCols = {
			type = "range",
			name = "Number of Icons Per Row",
			desc = "How many of icons are allowed per row (AKA: Number of columns in the tray).",
			order = autoOrder(),
			arg = updateTraySizeLayout,
			step = 1,
			min = 1,
			max = 6,
			get = "GenericGetter",
			set = "GenericSetter",
		},
	},
}

function addon:GenericGetter(info)
	return self.db.profile.minimap[info[#info]]
end

function addon:GenericSetter(info, value)
	self.db.profile.minimap[info[#info]] = value

	if info.arg and type(info.arg) == "function" then info.arg(value) end
end

-------------------------------------------------------------------------------
-- AddOn Inits
-------------------------------------------------------------------------------

local function init()
	initAlreadyRan = true

	genLauncherTray(icon:GetMinimapButton(ADDON_NAME))

	for _, func in ipairs(initFuncs) do
		func()
	end
end

local launcherLDB = LibStub("LibDataBroker-1.1"):NewDataObject(ADDON_NAME, {
	type = "data source",
	text = "Epsilon AddOns Launcher",
	icon = CONSTANTS.assetsPath .. "EpsilonTrayIcon",
	OnClick = function(self, button)
		if button == "RightButton" then
			InterfaceOptionsFrame_OpenToCategory(addon.optionsFrame)
			InterfaceOptionsFrame_OpenToCategory(addon.optionsFrame)
		else
			toggleLauncherTray()
		end
	end,
})

local defaultCoords = { 0, 1, 0, 1 }
function addon:OnInitialize()
	self.db = LibStub("AceDB-3.0"):New("Epsilon_Launcher_DB", _defaultDB, true)
	icon:Register(ADDON_NAME, launcherLDB, self.db.profile.minimap)
	icon:Refresh(ADDON_NAME)

	local mmButton = icon:GetMinimapButton(ADDON_NAME)
	minimapButton = mmButton
	local regions = { mmButton:GetRegions() }
	for i, region in ipairs(regions) do
		if region.GetDrawLayer and region:GetDrawLayer() == "OVERLAY" then
			region:Hide()
		end
	end
	mmButton.icon:ClearAllPoints()
	mmButton.icon:SetPoint("CENTER")
	mmButton.icon:SetSize(24, 24)

	mmButton.icon.UpdateCoord = function(self)
		local coords = self:GetParent().dataObject.iconCoords or defaultCoords
		local deltaX, deltaY = 0, 0
		if self:GetParent().isMouseDown then
			deltaX = (coords[2] - coords[1]) * -0.05
			deltaY = (coords[4] - coords[3]) * -0.05
		end
		self:SetTexCoord(coords[1] + deltaX, coords[2] - deltaX, coords[3] + deltaY, coords[4] - deltaY)
	end
	mmButton.icon:UpdateCoord()

	mmButton._Icons = {} -- dictionary for the icons to call them if needed

	ns.Utils.Tooltip.set(mmButton, "Epsilon AddOns Launcher",
		{
			"|cffFFD700Left-Click|r to open the AddOns tray!",
			"|cffFFD700Right-Click|r to open settings.",
		}
	)

	-- And.. Create our BlizzOptions

	LibStub("AceConfig-3.0"):RegisterOptionsTable("EpsilonLauncher", addonOptions)
	self.optionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("EpsilonLauncher", "Epsilon Minimap")
end

function addon:OnEnable()
	C_Timer.After(0, init)
end

-------------------------------------------------------------------------------
-- bring us into the ns era
-------------------------------------------------------------------------------

ns.Launcher = {
	registerForInit = runOnInit,

	new = registerTrayIcon,

	CONSTANTS = CONSTANTS,
}

local lib = LibStub:NewLibrary("EpsiLauncher-1.0", 1)
if lib then
	lib.API = ns.Launcher
end
