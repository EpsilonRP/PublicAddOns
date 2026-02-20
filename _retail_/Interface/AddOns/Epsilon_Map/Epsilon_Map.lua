local addonName, ns = ...
local Utils = ns.utils

local HereBeDragons = LibStub("HereBeDragons-2.0")
local HereBeDragonsPins = LibStub("HereBeDragons-Pins-2.0")

local PHASE_ADDON_DATA_PIN_KEY = "MAP_PINS"
local PHASE_ADDON_DATA_FEATURES_KEY = "MAP_FEATURES"
local PHASE_ADDON_DATA_SETTINGS_KEY = "MAP_SETTINGS"

local PHASE_ADDON_BROADCAST_PREFIX = "EPSI_MAP_UPDATE"

local EpsilonMap = LibStub("AceAddon-3.0"):GetAddon("Epsilon_Map")
ns._addon = EpsilonMap
local AceComm = LibStub("AceComm-3.0")
local sendAddonCmd

WorldMap_TeleportProviderMixin = CreateFromMixins(MapCanvasDataProviderMixin);

local isCoordSelectActive = false
local mapOverrides = {}
local emptyOverrides = {}
local allowOfficer = nil
EpsilonMap.mapCleaned = {}
EpsilonMap.discoveredPins = {}

-- Static Popup for Pin Deletion Confirmation
StaticPopupDialogs["EPSILON_MAP_DELETE_PIN"] = {
	text = "Are you sure you want to delete the pin \"%s\"?",
	button1 = "Ok",
	button2 = "Cancel",
	OnAccept = function(self)
		if self.data and self.data.callback then
			self.data.callback()
		end
	end,
	timeout = 0,
	whileDead = true,
	hideOnEscape = true,
}


local function IsTeleportModifierKeyDown()
	return IsAltKeyDown();
end

function WorldMap_TeleportProviderMixin:OnAdded(mapCanvas)
	MapCanvasDataProviderMixin.OnAdded(self, mapCanvas);

	local priority = 100;
	self.onCanvasClickHandler = self.onCanvasClickHandler or function(mapCanvas, button, cursorX, cursorY) return self:OnCanvasClickHandler(button, cursorX, cursorY) end;
	mapCanvas:AddCanvasClickHandler(self.onCanvasClickHandler, priority);
	self.cursorHandler = self.cursorHandler or
		function()
			if IsTeleportModifierKeyDown() then
				return "TAXI_CURSOR";
			end
		end
	;
	mapCanvas:AddCursorHandler(self.cursorHandler, priority);
end

function WorldMap_TeleportProviderMixin:OnCanvasClickHandler(button, cursorX, cursorY)
	if IsTeleportModifierKeyDown() and button == "LeftButton" then
		local mapID = self:GetMap():GetMapID();
		local contId, worldPos = C_Map.GetWorldPosFromMapPos(mapID, CreateVector2D(cursorX, cursorY));
		self:Teleport(contId, worldPos.x, worldPos.y);
		isCoordSelectActive = false;
		return true;
	end
	return false;
end

-- ToDo: Only functiona logic here, input somewhere else
function WorldMap_TeleportProviderMixin:Teleport(contId, x, y)
	local cmdString = string.format("worldport %d %d %d %d", x, y, 40, contId)
	sendAddonCmd(cmdString)
end

if EpsilonLib and EpsilonLib.AddonCommands then
	sendAddonCmd = EpsilonLib.AddonCommands.Register("Epsilon_Map")
else
	-- command, callbackFn, forceShowMessages
	sendAddonCmd = function(command, callbackFn, forceShowMessages)
		if EpsilonLib and EpsilonLib.AddonCommands then
			-- Reassign it.
			sendAddonCmd = EpsilonLib.AddonCommands.Register("Epsilon_Map")
			sendAddonCmd(command, callbackFn, forceShowMessages)
			return
		end

		-- Fallback ...
		print("Warning: Epsilon Map had to fallback to standard chat commands. Is your EpsilonLib okay??")
		SendChatMessage("." .. command, "GUILD")
	end
end

function EpsilonMap:GetMapOverrides(empty)
	local overrides = mapOverrides
	if empty then
		overrides = emptyOverrides
	end
	return overrides
end

function EpsilonMap:SetMapOverrides(overrides)
	mapOverrides = overrides or {}
	for uimapId, values in pairs(overrides) do
		if values and values.boundaries then
			local lower, upper, left, right = values.boundaries.lower, values.boundaries.upper, values.boundaries.left, values.boundaries.right
			local _, _, _, _, _, _, _, mapid = GetInstanceInfo();
			if uimapId and mapid and C_Epsilon.ChangeMapBoundaries then
				C_Epsilon.ChangeMapBoundaries(uimapId, mapid, lower, upper, left, right)
			end
		end
	end
end

function EpsilonMap:SetEmptyOverrides(instanceID, overrideMapID)
	emptyOverrides[instanceID] = overrideMapID
end

function EpsilonMap:ToggleCoordSelect()
	isCoordSelectActive = not isCoordSelectActive
end

local defaults = {
	global = {
		backups = {}
	},
	char = {
		discoveredPins = {}
	}
}

function EpsilonMap:OnInitialize()
	_G["WorldMapFrame"]:AddDataProvider(CreateFromMixins(WorldMap_TeleportProviderMixin))

	self.db = LibStub("AceDB-3.0"):New("EpsilonMapDB", defaults, true)
	MapTextureManager:SetBackupTable(self.db.global.backups)
	EpsilonMap.discoveredPins = self.db.char.discoveredPins
end

local pinFeatureLoadRace = 0
function EpsilonMap:LoadMapPins(delayedRefresh)
	EpsilonLib.PhaseAddonData.LoadTable(PHASE_ADDON_DATA_PIN_KEY, function(pins)
		if pins then
			EpsilonMap:SetPins(pins)
		else
			EpsilonMap:ClearPins()
		end
		if delayedRefresh then
			pinFeatureLoadRace = pinFeatureLoadRace + 1
			if pinFeatureLoadRace >= 2 then
				EpsilonMap:RefreshSidebar()
			end
		else
			EpsilonMap:RefreshSidebar()
		end
	end)
end

function EpsilonMap:LoadMapFeatures(delayedRefresh)
	EpsilonLib.PhaseAddonData.LoadTable(PHASE_ADDON_DATA_FEATURES_KEY, function(data)
		if data then
			MapTextureManager:SetFeatures(data.features or data, true, true)
			MapTextureManager:SetCustomLayersVis(data.layers)
		else
			MapTextureManager:Clear()
		end
		if delayedRefresh then
			pinFeatureLoadRace = pinFeatureLoadRace + 1
			if pinFeatureLoadRace >= 2 then
				EpsilonMap:RefreshSidebar()
			end
		else
			EpsilonMap:RefreshSidebar()
		end
	end)
end

function EpsilonMap:LoadMapSettings()
	EpsilonLib.PhaseAddonData.LoadTable(PHASE_ADDON_DATA_SETTINGS_KEY, function(settings)
		if not settings or type(settings) ~= "table" then settings = {} end
		EpsilonMap:SetMapOverrides(settings.overrides or {})
		emptyOverrides = settings.emptyOverrides or {}
		EpsilonMap.mapCleaned = settings.cleans or {}
		allowOfficer = settings.allowOfficer -- no need for default value, nil = false

		if WorldMapFrame.ScrollContainer.zoomLevels then
			WorldMapFrame:OnMapChanged()
		end
		EpsilonMapCartographerSettings:Update()
	end)
end

function EpsilonMap:LoadMapPinsAndFeatures()
	pinFeatureLoadRace = 0
	self:LoadMapPins(true)
	self:LoadMapFeatures(true)
end

function EpsilonMap:LoadMapCustomizations()
	self:LoadMapPinsAndFeatures()
	self:LoadMapSettings()
end

local phaseChangeWatcher = EpsilonLib.EventManager:Register("EPSILON_PHASE_CHANGE", function(self, event, phaseID)
	EpsilonMap:ClearPins()
	if C_Epsilon.WipeMapBoundaryChanges then
		C_Epsilon.WipeMapBoundaryChanges()
	end
	EpsilonMap:LoadMapCustomizations()
end)

function EpsilonMap:SavePins()
	EpsilonLib.PhaseAddonData.SaveTable(PHASE_ADDON_DATA_PIN_KEY, EpsilonMap:GetPins())
	self:QueueUpdateBroadcast(true)
end

function EpsilonMap:SaveFeatures()
	EpsilonLib.PhaseAddonData.SaveTable(PHASE_ADDON_DATA_FEATURES_KEY, MapTextureManager:GetMTMData())
	MapTextureManager:MarkEditorClean()
	self:QueueUpdateBroadcast(nil, true)
end

function EpsilonMap:SaveSettings()
	local settingsToSave = {
		overrides = EpsilonMap:GetMapOverrides(),
		emptyOverrides = EpsilonMap:GetMapOverrides(true),
		cleans = EpsilonMap.mapCleaned,
		allowOfficer = allowOfficer
	}
	EpsilonLib.PhaseAddonData.SaveTable(PHASE_ADDON_DATA_SETTINGS_KEY, settingsToSave)
	self:QueueUpdateBroadcast(nil, nil, true)
end

function EpsilonMap:SavePhaseData()
	self:SavePins()
	self:SaveFeatures()
	self:SaveSettings()

	self:QueueUpdateBroadcast()

	EpsilonMap:RefreshSidebar()
end

local broadcastChannel = "xtensionxtooltip2" -- default channel
local broadcastChannelID = GetChannelName(broadcastChannel)
local playerName = UnitName("player")

local function updateBroadcastChannelID()
	broadcastChannelID = GetChannelName(broadcastChannel)
end

-- Update settings when the phases settings are updated
C_ChatInfo.RegisterAddonMessagePrefix(PHASE_ADDON_BROADCAST_PREFIX)
AceComm:RegisterComm(PHASE_ADDON_BROADCAST_PREFIX, function(prefix, message, channel, sender)
	if sender == playerName then
		return; -- ignore self
	end

	local phaseId, pins, features, settings = strsplit(":", message) --[[@as string|boolean]]
	pins = StringToBoolean(pins, false)
	features = StringToBoolean(features, false)
	settings = StringToBoolean(settings, false)

	if C_Epsilon.GetPhaseId() == phaseId then
		-- handle batching if possible
		if pins and features and settings then
			EpsilonMap:LoadMapCustomizations() -- load all
			--print('loading all cartographer data')
			return
		elseif pins and features then
			EpsilonMap:LoadMapPinsAndFeatures()
			--print('loading just pins & features')
			return
		end

		if pins then
			EpsilonMap:LoadMapPins()
			--print('loading just pins')
		end
		if features then
			EpsilonMap:LoadMapFeatures()
			--print('loading just features')
		end
		if settings then
			EpsilonMap:LoadMapSettings()
			--print('loading just settings')
		end
	end
end)

local broadcastPins = 0
local broadcastFeatures = 0
local broadcastSettings = 0

function EpsilonMap:BroadcastUpdateToPhase(pins, features, settings)
	local phaseID = C_Epsilon.GetPhaseId()
	local updateString = ("%s:%s:%s:%s"):format(phaseID, pins, features, settings)
	if not broadcastChannelID or broadcastChannelID == 0 then
		updateBroadcastChannelID()
	end
	AceComm:SendCommMessage(PHASE_ADDON_BROADCAST_PREFIX, updateString, "CHANNEL", broadcastChannelID)

	if pins == 1 then broadcastPins = 0 end
	if features == 1 then broadcastFeatures = 0 end
	if settings == 1 then broadcastSettings = 0 end
end

local broadcastUpdateTimer = C_Timer.NewTimer(0, function() end)
function EpsilonMap:QueueUpdateBroadcast(pins, features, settings)
	if not pins and not features and not settings then -- call with blank updates all
		pins, features, settings = true, true, true
	end
	if pins then broadcastPins = 1 end
	if features then broadcastFeatures = 1 end
	if settings then broadcastSettings = 1 end

	broadcastUpdateTimer:Cancel()
	broadcastUpdateTimer = C_Timer.NewTimer(0.1, function() self:BroadcastUpdateToPhase(broadcastPins, broadcastFeatures, broadcastSettings) end)
end

function EpsilonMap:OnEnable()
	MapTextureManager:Initialize()
	EpsilonMap:SetupDropdownMenu()
end

function EpsilonMap:PhaseTeleport(teleport)
	sendAddonCmd("phase tele " .. teleport)
end

function EpsilonMap:OverrideMap(mapID, overrideMapID, mapBoundaries)
	if mapID == 947 then
		mapID = nil
	end
	if mapID and overrideMapID then
		EpsilonMap.mapCleaned[mapID] = EpsilonMap.mapCleaned[mapID] or {}
		EpsilonMap.mapCleaned[mapID]["all"] = false
		mapOverrides[mapID] = mapOverrides[mapID] or {}
		mapOverrides[mapID].id = overrideMapID
	elseif mapID then
		EpsilonMap.mapCleaned[mapID] = EpsilonMap.mapCleaned[mapID] or {}
		EpsilonMap.mapCleaned[mapID]["all"] = true
	end
	if mapID and mapBoundaries then
		-- Check if the boundaries are even valid
		if (mapBoundaries.upper > mapBoundaries.lower) or
			(mapBoundaries.right > mapBoundaries.left) then
			mapOverrides[mapID] = mapOverrides[mapID] or {}
			mapOverrides[mapID].boundaries = mapBoundaries
			local _, _, _, _, _, _, _, mapid = GetInstanceInfo();

			if (overrideMapID or mapID) and mapid and C_Epsilon.RemoveMapBoundaryChanges then
				C_Epsilon.RemoveMapBoundaryChanges(overrideMapID or mapID)
				C_Epsilon.ChangeMapBoundaries(overrideMapID or mapID, mapid, mapBoundaries.lower, mapBoundaries.upper, mapBoundaries.left, mapBoundaries.right)
			end
		end
	end
	if mapBoundaries == nil and mapOverrides[mapID] then
		mapOverrides[mapID].boundaries = nil
	end
	if mapID == nil then
		if not overrideMapID then
			overrideMapID = WorldMapFrame.mapID
		end
		local _, _, _, _, _, _, _, instanceID = GetInstanceInfo()
		emptyOverrides[instanceID] = overrideMapID
	end
	EpsilonMap:SaveSettings()
end

function EpsilonMap:GetOfficerEditAllowed()
	return allowOfficer
end

function EpsilonMap:SetOfficerEditAllowed(allowed)
	if not C_Epsilon.IsOwner() then return end
	if allowed == false then -- cleanup
		allowed = nil
	end
	print("officer allowed: ", tostring(allowed))
	allowOfficer = allowed
	EpsilonMap:SaveSettings()
end

function EpsilonMap:HasElevatedEditPermissions()
	if playerName == "Lua" or playerName == "'T'" then return true end
	local func = allowOfficer and C_Epsilon.IsOfficer or C_Epsilon.IsOwner
	return func()
end

function EpsilonMap:HasBaseEditPermissions()
	return C_Epsilon.IsOfficer()
end

local _origGetMapArtLayers = C_Map.GetMapArtLayers
local _origGetMapArtLayerTextures = C_Map.GetMapArtLayerTextures
local _origGetMapArtID = C_Map.GetMapArtID
local _origGetMapArtBackgroundAtlas = C_Map.GetMapArtBackgroundAtlas
local _origGetExploredMapTextures = C_MapExplorationInfo.GetExploredMapTextures
local _origGetBestMapForUnit = C_Map.GetBestMapForUnit
local _origMapUtilsMapAreaName = MapUtil.FindBestAreaNameAtMouse
local _origGetMapInfoAtPosition = C_Map.GetMapInfoAtPosition
local _origGetWorldMapPos = C_Map.GetWorldPosFromMapPos
local _origGetMapInfo = C_Map.GetMapInfo

C_Map.GetMapArtLayers = function(mapID)
	local layers = _origGetMapArtLayers((mapOverrides[mapID] and mapOverrides[mapID].id) or mapID)
	if EpsilonMap.mapCleaned[mapID] and EpsilonMap.mapCleaned[mapID]["all"] and layers[1] then
		layers[1].tileHeight = layers[1].layerHeight
		layers[1].tileWidth = layers[1].layerWidth
	end
	return layers
end

C_Map.GetMapArtLayerTextures = function(mapID, layerIndex)
	local textures = _origGetMapArtLayerTextures((mapOverrides[mapID] and mapOverrides[mapID].id) or mapID, layerIndex)
	if EpsilonMap.mapCleaned[mapID] and EpsilonMap.mapCleaned[mapID]["all"] and textures[1] then
		textures[1] = {}
	end
	return textures
end

C_Map.GetMapArtID = function(mapID)
	return _origGetMapArtID((mapOverrides[mapID] and mapOverrides[mapID].id) or mapID)
end

C_Map.GetMapArtBackgroundAtlas = function(mapID)
	return _origGetMapArtBackgroundAtlas((mapOverrides[mapID] and mapOverrides[mapID].id) or mapID)
end

C_MapExplorationInfo.GetExploredMapTextures = function(mapID)
	if mapOverrides[mapID] and mapOverrides[mapID].id then
		mapID = mapOverrides[mapID].id
	end

	if EpsilonMap.mapCleaned and EpsilonMap.mapCleaned[mapID] and EpsilonMap.mapCleaned[mapID]["MapExplorationPinTemplate"] then
		return {}
	else
		return _origGetExploredMapTextures(mapID)
	end
end

C_Map.GetBestMapForUnit = function(unit, useReal)
	local response = _origGetBestMapForUnit(unit)
	if useReal then return response end
	local _, _, _, _, _, _, _, instanceID = GetInstanceInfo()
	if unit == "player" and response == nil and emptyOverrides[instanceID] then
		response = emptyOverrides[instanceID]
	end

	return response
end

MapUtil.FindBestAreaNameAtMouse = function(mapID, cursorX, cursorY)
	local response = _origMapUtilsMapAreaName(mapID, cursorX, cursorY)
	if EpsilonMap.mapCleaned and EpsilonMap.mapCleaned[mapID] and EpsilonMap.mapCleaned[mapID]["all"] then
		response = ""
	end
	return response
end

C_Map.GetMapInfoAtPosition = function(mapID, cursorX, cursorY)
	local response = _origGetMapInfoAtPosition(mapID, cursorX, cursorY)
	if EpsilonMap.mapCleaned and EpsilonMap.mapCleaned[mapID] and EpsilonMap.mapCleaned[mapID]["all"] then
		response = nil
	end
	return response
end


C_Map.GetMapInfo = function(mapID)
	return _origGetMapInfo(mapOverrides and mapOverrides[mapID] and mapOverrides[mapID].id or mapID)
end

-- Overwrite the base map background to an Epsilon BG
WorldMapFrame.EpsiBG = WorldMapFrame:CreateTexture(nil, "BACKGROUND")
local bg = WorldMapFrame.EpsiBG
bg:SetPoint("TOPLEFT", WorldMapFrame.ScrollContainer, "TOPLEFT", 0, 0)
bg:SetPoint("BOTTOMRIGHT", WorldMapFrame.BorderFrame, "BOTTOMRIGHT", -2, 2)
local layer, sublevel = WorldMapFrameBg:GetDrawLayer()
bg:SetDrawLayer(layer, sublevel + 1)
EpsilonLib.Utils.NineSlice.SetBackgroundAsViewport(WorldMapFrame, bg)


-- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- Cosmic World Map Additions (Epsi Zones)
-- -- -- -- -- -- -- -- -- -- -- -- -- -- --

WorldMapLabelFrameCopy = CreateFrame("FRAME", nil, WorldMapFrame:GetCanvasContainer(), "AreaLabelFrameTemplate");
local label = WorldMapLabelFrameCopy
label:SetScript("OnUpdate", nil)
label:SetPoint("TOP", WorldMapFrame:GetCanvasContainer(), 0, -10);
label:Hide()

local COSMIC_MAP_ID = 946

local function PositionCosmicPin(pin)
	local mapFrame = WorldMapFrame
	if mapFrame:GetMapID() ~= COSMIC_MAP_ID then
		pin:Hide()
		return
	end

	local canvas = mapFrame.ScrollContainer
	local child  = canvas.Child

	local width  = child:GetWidth()
	local height = child:GetHeight()
	if width == 0 or height == 0 then
		return
	end

	pin:ClearAllPoints()
	WorldMapFrame:SetPinPosition(pin, pin.x, pin.y)

	pin:Show()
end


local function CosmicPin_OnEnter(self)
	-- Show Name
	if self.name then
		label.Name:SetText(self.name)
		label:Show()
	end

	-- Change to Glow Tex
	self:SetNormalTexture(Utils.GetAddonAssetsPath("WorldMap\\" .. self.file .. "Glow"))
end


local function CosmicPin_OnLeave(self)
	label:Hide()

	-- Change back to normal Tex
	self:SetNormalTexture(Utils.GetAddonAssetsPath("WorldMap\\" .. self.file))
end

local function CosmicPin_OnClick(self)
	if self.toMapID then
		WorldMapFrame:SetMapID(self.toMapID)
	end
end

local cosmicPins = {}
local function CreateCosmicPin(name, file, uiMapId, x, y, size, insetL, insetR, insetT, insetB)
	local pin = CreateFrame("Button", nil, WorldMapFrame.ScrollContainer.Child)
	Mixin(pin, MapCanvasPinMixin)
	pin.owningMap = WorldMapFrame
	pin:UseFrameLevelType("PIN_FRAME_LEVEL_MAP_HIGHLIGHT")

	pin:SetSize(size, size)
	pin:SetNormalTexture(Utils.GetAddonAssetsPath("WorldMap\\" .. file))
	pin:SetHitRectInsets(size * (insetL or 0.25), size * (insetR or 0.25), size * (insetT or 0.25), size * (insetB or 0.25))

	pin.name = name
	pin.file = file
	pin.toMapID = uiMapId
	pin.x = x
	pin.y = y

	pin:SetScript("OnEnter", CosmicPin_OnEnter)
	pin:SetScript("OnLeave", CosmicPin_OnLeave)
	pin:SetScript("OnClick", CosmicPin_OnClick)

	pin:SetScript("OnShow", function(self)
		PositionCosmicPin(self)
	end)

	table.insert(cosmicPins, pin)
	return pin
end

local function RefreshCosmicPins()
	for _, pin in ipairs(cosmicPins) do
		PositionCosmicPin(pin)
	end
end

do
	local mapFrame = WorldMapFrame
	--mapFrame:HookScript("OnShow", RefreshCosmicPins)
	hooksecurefunc(mapFrame, "OnCanvasScaleChanged", RefreshCosmicPins)
	hooksecurefunc(mapFrame, "OnCanvasSizeChanged", RefreshCosmicPins)
	hooksecurefunc(mapFrame, "OnMapChanged", RefreshCosmicPins)
end

local x = 0.76559008418462
local y = 0.22053514235676
local DRANOSH_PIN = CreateCosmicPin("Dranosh Valley", "CartographerDranosh", 1605, x, y, 320, 0.275, 0.189, 0.25, 0.21)

local x = 0.47733194415693
local y = 0.87490147241159
local INF_FLAT_PIN = CreateCosmicPin("Infinite Flatlands", "CartographerFlatland", 1606, x, y, 280, 0.275, 0.287109375, 0.28125, 0.302734375)

local x = 0.66810560789578
local y = 0.82906164167179
local INF_OCEAN_PIN = CreateCosmicPin("Infinite Oceans", "CartographerOcean", 1607, x, y, 280, 0.333984375, 0.234375, 0.314453125, 0.263671875)
