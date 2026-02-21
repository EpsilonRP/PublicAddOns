local Utils         = select(2, ...).utils
local EpsilonMap    = LibStub("AceAddon-3.0"):GetAddon("Epsilon_Map")
local HereBeDragons = LibStub("HereBeDragons-2.0")

local dropDown

local bg            = WorldMapFrame.ScrollContainer.Child:CreateTexture(nil, "BACKGROUND")
bg:SetTexture(Utils.GetAddonAssetsPath("MapTextures\\BaseMapBG.blp"))
bg:SetTexCoord(1, 0, 0.2, 0.8)
bg:SetPoint("TOPLEFT")
bg:SetPoint("BOTTOMRIGHT")
local function CleanMap()
	for i, _ in pairs(WorldMapFrame.dataProviders) do
		--We use that to check if the dataProvider is HBD
		if not i.RemovePinByIcon then
			i:RemoveAllData()
		end
	end
	bg:Show()
end

local _origOnMapChanged = WorldMapFrame.OnMapChanged

local customHandledTemplates = {
	MapExplorationPinTemplate = true,
	FogOfWarPinTemplate = true,
}
local OnMapChanged = function(s)
	_origOnMapChanged(s)
	if EpsilonMap.mapCleaned[s.mapID] and EpsilonMap.mapCleaned[s.mapID]["all"] then
		CleanMap()
	else
		for pinTemplate, shouldRemove in pairs(EpsilonMap.mapCleaned[s.mapID] or {}) do
			if shouldRemove and not customHandledTemplates[pinTemplate] then
				WorldMapFrame.ScrollContainer:GetMap():RemoveAllPinsByTemplate(pinTemplate);
			elseif pinTemplate == "FogOfWarPinTemplate" then
				MapTextureManager:ToggleFogOfWarLayer(not shouldRemove)
			end
		end
		bg:Hide()
	end

	EpsilonMap:RefreshHiddenPinVisibility()
end
WorldMapFrame.OnMapChanged = OnMapChanged
WorldMapFrame:HookScript("OnShow", OnMapChanged)

local function SetMapID(_, map)
	if map then
		WorldMapFrame:SetMapID(map.mapID)
		WorldMapFrame:OnMapChanged()
	else
		WorldMapFrame.mapID = nil
		CleanMap()
	end

	if map and map.mapID then
		UIDropDownMenu_SetText(dropDown, string.sub(map.name, 1, 25))
	else
		UIDropDownMenu_SetText(dropDown, "Empty Map")
	end
end


local menuInfo = {
	func = SetMapID
}
local function InitMapsDropdown(self, level)
	local mapGroupsInMenu = {}
	level = level or 1
	menuInfo.disabled = false
	menuInfo.tooltipTitle = ""
	menuInfo.tooltipText = ""
	if (level == 1) then
		local maps = C_Map.GetMapChildrenInfo(946)
		table.sort(maps, function(a, b) return a.name < b.name end)
		for _, v in ipairs(maps) do
			local map = C_Map.GetMapInfo(v.mapID)
			menuInfo.hasArrow = true
			menuInfo.text = map.name
			menuInfo.value = map.mapID
			menuInfo.arg1 = map
			UIDropDownMenu_AddButton(menuInfo, level);
		end
		menuInfo.hasArrow = false
		menuInfo.text = "Empty Map"
		menuInfo.arg1 = nil
		if not C_Map.GetBestMapForUnit("player") or C_Map.GetBestMapForUnit("player") == 947 then
			menuInfo.disabled = true
			menuInfo.tooltipTitle = "Empty Map"
			menuInfo.tooltipText = "To use an empty map here, choose a different map first. Then, use that as the basis to empty out"
			menuInfo.tooltipOnButton = true
			menuInfo.tooltipWhileDisabled = true
		end
		UIDropDownMenu_AddButton(menuInfo, level);
	else
		local maps = C_Map.GetMapChildrenInfo(UIDROPDOWNMENU_MENU_VALUE)
		table.sort(maps, function(a, b) return a.name < b.name end)
		for _, map in ipairs(maps) do
			if not mapGroupsInMenu[map.name] then
				local mapGroupID = C_Map.GetMapGroupID(map.mapID)

				local text = map.name
				if C_Map.MapHasArt(map.mapID) and not mapGroupsInMenu[map.name] then
					if map.mapID == 1524 then
						text = "Deepsea Slave Pen"
					elseif map.mapID == 1500 then
						text = "Ghitterspine Grotto"
					end
					menuInfo.text = text
					menuInfo.value = map.mapID
					menuInfo.arg1 = map
					if (#C_Map.GetMapChildrenInfo(map.mapID) > 0) then
						menuInfo.hasArrow = true
					else
						menuInfo.hasArrow = false
					end
					UIDropDownMenu_AddButton(menuInfo, level);
					if mapGroupID then
						mapGroupsInMenu[map.name] = true
					end
				end
			end
		end
	end
end


function EpsilonMap:SetupDropdownMenu()
	dropDown = _G["EpsilonMapMapsDropdown"]
	UIDropDownMenu_Initialize(dropDown, InitMapsDropdown)

	local button = CreateFrame("Button", nil, WorldMapFrame.ScrollContainer, "EpsilonMap_ButtonTemplate")
	WorldMapFrame.ScrollContainer.showMapSettings = button
	button:SetNormalTexture(Utils.GetAddonAssetsPath("UI\\CartographerButton.blp"))
	button:SetHighlightAtlas("Interface/BUTTONS/ButtonHilight-Square", "ADD")
	button:SetPoint("BOTTOMLEFT", 50, 5)
	button:SetWidth(100)
	button:SetText("Map Settings")
	button:SetHeight(35)
	button:SetScript("OnClick", function() _G["EpsilonMapSettings"]:Show() end)
end

hooksecurefunc(WorldMapFrame.ScrollContainer, "Show", function()
end)

WorldMapFrame.ScrollContainer:HookScript("OnShow", function()
	if (EpsilonMap:HasElevatedEditPermissions()) then
		WorldMapFrame.ScrollContainer.showMapSettings:Show()
	else
		WorldMapFrame.ScrollContainer.showMapSettings:Hide()
	end
end)

EpsilonMap_SettingsMixin = {}

EpsilonMap_SettingsMixin.OnLoad = function(self)
	ButtonFrameTemplate_HidePortrait(self)
	ButtonFrameTemplate_HideAttic(self)
	ButtonFrameTemplate_HideButtonBar(self)
	self.TitleText:SetText("Map Settings")

	-- Create green TitleBG overlay (same as PinMixin.lua)
	local titleBg = self:CreateTexture(nil, "ARTWORK")
	titleBg:SetPoint("TOPLEFT", self.TitleBg)
	titleBg:SetPoint("BOTTOMRIGHT", self.TitleBg)
	titleBg:SetColorTexture(0.184, 0.29, 0.0, 1)

	NineSliceUtil.ApplyLayoutByName(self.NineSlice, "EpsilonGoldBorderFrameTemplateNoPortrait")
	EpsilonLib.Utils.NineSlice.SetBackgroundAsViewport(self.Inset, self.Inset.Bg)

	self.boundaryHelpIcon = CreateFrame("Button", nil, self, "UIPanelInfoButton")
	self.boundaryHelpIcon:SetPoint("LEFT", self.MapBoundariesLabel, "RIGHT", 10, 0)
	self.boundaryHelpIcon:SetScale(UIParent:GetScale())
	self.boundaryHelpIcon:SetIgnoreParentScale(true)
	self.boundaryHelpIcon:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT", -16, -4)
		GameTooltip_SetTitle(GameTooltip, "Map Boundaries", NORMAL_FONT_COLOR)
		GameTooltip_AddHighlightLine(GameTooltip, "Map boundaries control the edges of the UI map where your player icon shows, based on in-game coordinates.")
		GameTooltip_AddHighlightLine(GameTooltip, "Outside the bounds = off-map.")
		GameTooltip_AddHighlightLine(GameTooltip, " ")
		GameTooltip_AddHighlightLine(GameTooltip, "Boundaries match '.gps' coordinates (Top/Bottom = X, Left/Right = Y), or use \"Use Current Position\".")
		GameTooltip:Show();
	end)
	self.boundaryHelpIcon:SetScript("OnLeave", GameTooltip_Hide)
end

EpsilonMap_SettingsMixin.OnShow = function(self)
	local currentMapID = C_Map.GetBestMapForUnit("player")
	if currentMapID and C_Map.GetMapInfo(currentMapID).mapType >= 3 then
		local width, height = HereBeDragons:GetZoneSize(currentMapID)
		local startingWidth, startingHeight = HereBeDragons:GetWorldCoordinatesFromZone(0, 0, currentMapID)

		if startingWidth and startingHeight then
			local left = startingWidth
			local upper = startingHeight
			local right = startingWidth - width
			local lower = startingHeight - height

			local mapOverrides = EpsilonMap:GetMapOverrides()
			if mapOverrides and mapOverrides[currentMapID] and mapOverrides[currentMapID].boundaries then
				local mapBoundaries = mapOverrides[currentMapID].boundaries
				left = mapBoundaries.left
				upper = mapBoundaries.upper
				right = mapBoundaries.right
				lower = mapBoundaries.lower
			end

			self.LeftBoundary:SetText(math.floor(left))
			self.UpperBoundary:SetText(math.floor(upper))
			self.RightBoundary:SetText(math.floor(right))
			self.LowerBoundary:SetText(math.floor(lower))
		end
	end

	-- Update the map name label inside the window
	if currentMapID then
		local mapInfo = C_Map.GetMapInfo(currentMapID)
		if mapInfo then
			self.MapNameLabel:SetText(mapInfo.name)
		else
			self.MapNameLabel:SetText("")
		end
	else
		self.MapNameLabel:SetText("")
	end
end

EpsilonMap_SettingsMixin.DropdownOnShow = function(self)
	local mapName
	if WorldMapFrame.mapID and
		((not EpsilonMap.mapCleaned) or
			(EpsilonMap.mapCleaned and not EpsilonMap.mapCleaned[WorldMapFrame.mapID]) or
			(EpsilonMap.mapCleaned and EpsilonMap.mapCleaned[WorldMapFrame.mapID] and not EpsilonMap.mapCleaned[WorldMapFrame.mapID]["all"])) then
		mapName = C_Map.GetMapInfo(WorldMapFrame.mapID).name
	else
		mapName = "Empty Map"
	end
	UIDropDownMenu_SetText(dropDown, mapName)
end

EpsilonMap_SettingsMixin.OverrideMap = function(self, mapID)
	local overrideID = C_Map.GetBestMapForUnit("player")
	local left = tonumber(self.LeftBoundary:GetText())
	local right = tonumber(self.RightBoundary:GetText())
	local lower = tonumber(self.LowerBoundary:GetText())
	local upper = tonumber(self.UpperBoundary:GetText())
	local mapBoundaries

	if not mapID and (not EpsilonMap.mapCleaned[WorldMapFrame.mapID] or EpsilonMap.mapCleaned[WorldMapFrame.mapID] and not EpsilonMap.mapCleaned[WorldMapFrame.mapID]["all"]) then
		mapID = WorldMapFrame.mapID
	end

	if left and right and lower and upper then
		mapBoundaries = { left = left, right = right, lower = lower, upper = upper }
	end

	EpsilonMap:OverrideMap(overrideID, mapID, mapBoundaries)
	if (overrideID or mapID) and overrideID ~= 947 then
		WorldMapFrame:SetMapID(mapID or overrideID)
		WorldMapFrame:OnMapChanged()
	end
	local map = overrideID or mapID
	if ((not EpsilonMap.mapCleaned) or
			(EpsilonMap.mapCleaned and not EpsilonMap.mapCleaned[map]) or
			(EpsilonMap.mapCleaned and EpsilonMap.mapCleaned[map] and not EpsilonMap.mapCleaned[map]["all"])) then
		if not map or map == 947 then
			map = WorldMapFrame.mapID
		end
		local mapInfo = C_Map.GetMapInfo(map)
		local name = string.sub(mapInfo.name, 1, 25)
		UIDropDownMenu_SetText(dropDown, name)
		self.MapNameLabel:SetText(name)
	else
		self.MapNameLabel:SetText("Empty Map")
		UIDropDownMenu_SetText(dropDown, "Empty Map")
	end
end

function EpsilonMap_SettingsMixin.UndoOverrides(self, mapID)
	local trueBestMap = C_Map.GetBestMapForUnit("player", true)
	local isEmpty = not not mapID
	local OverrideID = EpsilonMap:GetMapOverrides() and EpsilonMap:GetMapOverrides(isEmpty)[mapID] and EpsilonMap:GetMapOverrides(isEmpty)[mapID].id or mapID
	if mapID == OverrideID then
		OverrideID = 947
	end
	if OverrideID then
		WorldMapFrame:SetMapID(OverrideID)
		WorldMapFrame:OnMapChanged()
	end
	if not trueBestMap then
		local _, _, _, _, _, _, _, instanceID = GetInstanceInfo()
		local emptyOverrides = EpsilonMap:GetMapOverrides(true)
		if emptyOverrides[instanceID] then
			UIDropDownMenu_SetText(dropDown, "Azeroth")
			EpsilonMap:SetEmptyOverrides(instanceID, nil)
		end
	end
	EpsilonMap:OverrideMap(mapID, mapID, nil)
	if mapID then
		C_Epsilon.RemoveMapBoundaryChanges(mapID)
	end
	if trueBestMap or mapID then
		UIDropDownMenu_SetText(dropDown, C_Map.GetMapInfo(C_Map.GetBestMapForUnit("player", true) or mapID).name)
	end

	if trueBestMap then
		local width, height = HereBeDragons:GetZoneSize(mapID)
		local startingWidth, startingHeight = HereBeDragons:GetWorldCoordinatesFromZone(0, 0, mapID)
		self.LeftBoundary:SetText(math.floor(startingWidth))
		self.UpperBoundary:SetText(math.floor(startingHeight))
		self.RightBoundary:SetText(math.floor(startingWidth - width))
		self.LowerBoundary:SetText(math.floor(startingHeight - height))
		WorldMapFrame:SetMapID(mapID)
		WorldMapFrame:OnMapChanged()
	end
end

EpsilonMap_SettingsMixin.RemovePins = function(self, pin)
	local mapID = WorldMapFrame.mapID
	EpsilonMap.mapCleaned[mapID] = EpsilonMap.mapCleaned[mapID] or {}
	if not self:GetChecked() then
		EpsilonMap.mapCleaned[mapID][pin] = true
		WorldMapFrame:OnMapChanged()
	else
		EpsilonMap.mapCleaned[mapID][pin] = false
		WorldMapFrame:OnMapChanged()
	end
	EpsilonMap:SaveSettings()
end

EpsilonMap_SettingsMixin.SetCheckedState = function(self, pin)
	local mapID = WorldMapFrame.mapID
  local checked = true
  if EpsilonMap.mapCleaned and EpsilonMap.mapCleaned[mapID] and EpsilonMap.mapCleaned[mapID][pin] then
	  checked = false
  end
	self:SetChecked(checked)
end

EpsilonMap_SettingsMixin.ValidateBoundaries = function(self)
	local settingsFrame = self:GetParent()
	local left = tonumber(settingsFrame.LeftBoundary:GetText())
	local right = tonumber(settingsFrame.RightBoundary:GetText())
	local upper = tonumber(settingsFrame.UpperBoundary:GetText())
	local lower = tonumber(settingsFrame.LowerBoundary:GetText())

	local isValid = true
	local errorAnchor = nil
	local errorMessage = nil

	if not left or not right or not upper or not lower then
		isValid = false
	else
		if left < right then
			isValid = false
			errorAnchor = settingsFrame.LeftBoundary
			errorMessage = "Left boundary must be higher than Right boundary."
		elseif upper < lower then
			isValid = false
			errorAnchor = settingsFrame.UpperBoundary
			errorMessage = "Top boundary must be higher than Bottom boundary."
		end
	end

	-- areas without maps have no data in any spot - we just don't save the overrides in that case
	if left == nil and right == nil and upper == nil and lower == nil then
		isValid = true
	end

	if isValid then
		settingsFrame.OverrideMapButton:Enable()
		GameTooltip:Hide()
	else
		settingsFrame.OverrideMapButton:Disable()
		if errorAnchor and errorMessage then
			GameTooltip:SetOwner(errorAnchor, "ANCHOR_RIGHT")
			GameTooltip:SetText(errorMessage, 1, 0.2, 0.2)
			GameTooltip:Show()
		else
			GameTooltip:Hide()
		end
	end
end


EpsilonMap_CartographerSettingsMixin = {}

function EpsilonMap_CartographerSettingsMixin:OnLoad()
	ButtonFrameTemplate_HidePortrait(self)
	ButtonFrameTemplate_HideAttic(self)
	ButtonFrameTemplate_HideButtonBar(self)
	self.TitleText:SetText("Cartographer Settings")

	-- Create green TitleBG overlay (same as PinMixin.lua)
	local titleBg = self:CreateTexture(nil, "ARTWORK")
	titleBg:SetPoint("TOPLEFT", self.TitleBg)
	titleBg:SetPoint("BOTTOMRIGHT", self.TitleBg)
	titleBg:SetColorTexture(0.184, 0.29, 0.0, 1)

	EpsilonLib.Utils.Misc.AddDragBarToFrame(self)

	NineSliceUtil.ApplyLayoutByName(self.NineSlice, "EpsilonGoldBorderFrameTemplateNoPortrait")
	EpsilonLib.Utils.NineSlice.SetBackgroundAsViewport(self.Inset, self.Inset.Bg)
end

function EpsilonMap_CartographerSettingsMixin:OnShow()

end

function EpsilonMap_CartographerSettingsMixin:Update()
	self.AllowOfficerToEditCheckButton:GetScript("OnShow")(self.AllowOfficerToEditCheckButton)
end

EpsilonMap_CartographerSettingsMixin.IsOfficerAllowed = EpsilonMap.GetOfficerEditAllowed
EpsilonMap_CartographerSettingsMixin.SetOfficerAllowed = EpsilonMap.SetOfficerEditAllowed
