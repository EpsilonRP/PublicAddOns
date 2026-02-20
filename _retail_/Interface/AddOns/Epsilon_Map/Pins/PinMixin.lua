local Utils = select(2, ...).utils

local HereBeDragons = LibStub("HereBeDragons-2.0")
local HereBeDragonsPins = LibStub("HereBeDragons-Pins-2.0")
local EpsilonMap = LibStub("AceAddon-3.0"):GetAddon("Epsilon_Map")

-- Pin Pool System

local highlightTex
local pinFrames = {}
local hiddenPinFrames = {}
local pinFrameMap = {}

local pinFrame_OnAcquire = function(pool, frame)
	if not frame.tex then
		local tex = frame:CreateTexture()
		tex:SetAllPoints()
		frame.tex = tex
	end

	if not highlightTex then
		local tex = frame:CreateTexture()
		tex:SetAllPoints()
		tex:SetTexture(Utils.GetAddonAssetsPath("UI\\CartographerNodeHighlight"))
		tex:Hide()
		highlightTex = tex
	end

	-- reset
	frame.tex:SetTexture(nil)
	frame:Hide()
	frame:ClearAllPoints()
	frame:SetParent(nil)
end
local pinPool = CreateFramePool("Button", nil, nil, pinFrame_OnAcquire)
pinPool.creationFunc = function(framePool)
	local frame = CreateFrame(framePool.frameType, nil, framePool.parent, framePool.frameTemplate);
	frame.tex = frame:CreateTexture()
	frame.tex:SetAllPoints()
	frame.highlightTex = frame:CreateTexture()
	frame.highlightTex:SetAllPoints()
	frame.highlightTex:SetTexture(Utils.GetAddonAssetsPath("UI\\CartographerNodeHighlight"))
	frame.highlightTex:Hide()
	return frame
end

local function pinTooltip_OnEnter(self)
	if self.pin.title then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT", -16, -4);
		GameTooltip_SetTitle(GameTooltip, self.pin.title);
		if self.pin.description then
			GameTooltip_AddNormalLine(GameTooltip, self.pin.description);
		end
		if self.pin.actionType == 1 and self.pin.actionValue ~= "" then
			GameTooltip_AddBlankLineToTooltip(GameTooltip)
			GameTooltip_AddInstructionLine(GameTooltip, "Control-Click on this to cast " .. self.pin.actionValue)
		elseif self.pin.actionType == 2 and self.pin.actionValue ~= "" then
			GameTooltip_AddBlankLineToTooltip(GameTooltip)
			GameTooltip_AddInstructionLine(GameTooltip, "Control-Click on this to teleport to " .. self.pin.actionValue)
		elseif self.pin.actionType == 3 and self.pin.actionValue ~= "" then
			GameTooltip_AddBlankLineToTooltip(GameTooltip)
			GameTooltip_AddInstructionLine(GameTooltip, "Control-Click on this to open the map " .. C_Map.GetMapInfo(tonumber(self.pin.actionValue)).name)
		end
		GameTooltip:Show();
	end
end


local currentColor = { r = 1, g = 1, b = 1 }


local function GetPinCoords(key)
	key = key - 1
	if key < 256 then
		local row = math.floor(key / 16)
		local column = key % 16
		local coords = {
			left = column / 16,
			top = row / 16,
			right = (column + 1) / 16,
			bottom = (row + 1) / 16
		}
		return coords
	end
	return { left = 15 / 16, top = 15 / 16, right = 1, bottom = 1 }
end

function EpsilonMap:SetPinTexture(textureWidget, texIndex)
	textureWidget:SetTexture(Utils.GetAddonAssetsPath("Pins\\CartographerMapMarkers"))
	local texCoords = GetPinCoords(texIndex)
	textureWidget:SetTexCoord(texCoords.left, texCoords.right, texCoords.top, texCoords.bottom)
end

EpsilonMap_PinEditorMixin = {}

function EpsilonMap_PinEditorMixin:ClickCoordsButton()
	EpsilonMap:ToggleCoordSelect()
end

function EpsilonMap_PinEditorMixin:OnHide()
	if self.editIndex and self.editIndex ~= EpsilonMapSidebarMapFrame.selectedPinEntry then
		EpsilonMap_SidebarEntryMixin:UnselectPinEntry()
	elseif EpsilonMapSidebarMapFrame.selectedPinEntry then
		EpsilonMap_SidebarEntryMixin:SelectPinEntry(EpsilonMapSidebarMapFrame.selectedPinEntry)
	end
	if self.cancel then
		EpsilonMap:RemovePin(self.pin)
	end
end

function EpsilonMap_PinEditorMixin:OnLoad()
	ButtonFrameTemplate_HidePortrait(self)
	ButtonFrameTemplate_HideAttic(self)
	ButtonFrameTemplate_HideButtonBar(self)
	self.TitleText:SetText("Edit Pin")
	local titleBg = self:CreateTexture(nil, "ARTWORK")

	titleBg:SetPoint("TOPLEFT", self.TitleBg)
	titleBg:SetPoint("BOTTOMRIGHT", self.TitleBg)
	titleBg:SetColorTexture(0.184, 0.29, 0.0, 1)
	self.CancelButton:SetText("Delete")
	self.CancelButton:SetScript("OnClick", function() EpsilonMap_PinEditorMixin.DeletePin(self) end)

	NineSliceUtil.ApplyLayoutByName(self.NineSlice, "EpsilonGoldBorderFrameTemplateNoPortrait")
	EpsilonLib.Utils.NineSlice.SetBackgroundAsViewport(self.Inset, self.Inset.Bg)
end

local function DeletePinCallback(editor)
	EpsilonMap:RemovePin(editor.pin)
	editor:Hide()
	EpsilonMap:RefreshSidebar()
	EpsilonMap:SavePins()
end

function EpsilonMap_PinEditorMixin:DeletePin()
	local pinTitle = self.pin and self.pin.title

	local dialog = StaticPopup_Show("EPSILON_MAP_DELETE_PIN", pinTitle)
	if dialog then
		dialog.data = {
			callback = function()
				DeletePinCallback(self)
			end
		}
	end
end

function EpsilonMap:SetCurrentMap(mapID)
	currentMap = mapID
end

function EpsilonMap:SetCurrentCoords(x, y)
	currentCoords = { x = x, y = y }
	_G["EpsilonMapPinEditorPlacePinButtonX"]:SetText(string.sub(x, 1, 8))
	_G["EpsilonMapPinEditorPlacePinButtonY"]:SetText(string.sub(y, 1, 8))
end

EpsilonMap_PinPickerButtonMixin = {}

function EpsilonMap_PinPickerButtonMixin:OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT", -16, -4)
	GameTooltip_SetTitle(GameTooltip, "Map Pin")
	GameTooltip_AddInstructionLine(GameTooltip, "Drag and drop the pin onto the map to place it.")
	GameTooltip:Show()
end

function EpsilonMap_PinPickerButtonMixin:OnLeave()
	GameTooltip:Hide()
end

function EpsilonMap_PinPickerButtonMixin:Refresh()
	if self.pickerIndex > 256 then
		self:Disable()
		self.NormalTexture:Hide()
		return
	else
		self.NormalTexture:Show()
		self:Enable()
	end
	local pinCoords = GetPinCoords(self.pickerIndex)
	self.NormalTexture:SetTexCoord(pinCoords.left, pinCoords.right, pinCoords.top, pinCoords.bottom)
end

function EpsilonMap_PinPickerButtonMixin:SelectPinTexture(i)
	local pinCoords = GetPinCoords(self.pickerIndex)
	local editor = _G["EpsilonMapPinEditor"]
	if not editor.pin then
		print("Drag and Drop the pin onto the map to place it")
	end
	editor.pin.textureIndex = self.pickerIndex
	editor.texture.icon:SetTexture(Utils.GetAddonAssetsPath("Pins\\CartographerMapMarkers"))
	editor.texture.icon:SetTexCoord(pinCoords.left, pinCoords.right, pinCoords.top, pinCoords.bottom)
	_G["EpsilonMapPinPicker"]:Hide()
end

function EpsilonMap_PinPickerButtonMixin:OnDragStart()
	if not self:IsEnabled() then return end
	local dragIcon = _G["EpsilonMapDragIcon"]
	local uiScale, x, y = UIParent:GetEffectiveScale(), GetCursorPosition()
	dragIcon.Texture:SetTexture(self:GetNormalTexture():GetTextureFilePath())
	dragIcon.Texture:SetTexCoord(self:GetNormalTexture():GetTexCoord())
	dragIcon:Show()
	dragIcon:ClearAllPoints()
	dragIcon:SetPoint("CENTER", nil, "BOTTOMLEFT", x / uiScale, y / uiScale)
	dragIcon:StartMoving()
end

function EpsilonMap_PinPickerButtonMixin:OnDragStop()
	if not self:IsEnabled() then return end
	local dragIcon = _G["EpsilonMapDragIcon"]
	dragIcon:ClearAllPoints()
	dragIcon:Hide()
	dragIcon:SetParent(UIParent)
	dragIcon:StopMovingOrSizing()
	local x, y = WorldMapFrame.ScrollContainer:GetNormalizedCursorPosition()
	local pin = EpsilonMap:CreatePin(x, y, self.pickerIndex, WorldMapFrame.mapID)
	EpsilonMap:PlacePin(pin, WorldMapFrame.mapID)
	_G["EpsilonMapPinPicker"]:Hide()
	local pins = EpsilonMap:GetPins(WorldMapFrame.mapID)
	EpsilonMap_PinEditorMixin:OpenEditor(WorldMapFrame.mapID, #pins, true)
end

EpsilonMap_PinPickerMixin = {}

function EpsilonMap_PinPickerMixin:OnScroll(scrollbar)
	local offset = scrollbar:GetValue()
	for index, pinFrame in ipairs(self.pins or {}) do
		pinFrame.pickerIndex = index + offset
		pinFrame:Refresh()
	end
end

function EpsilonMap_PinPickerMixin:OnLoad()
	ButtonFrameTemplate_HidePortrait(self)
	ButtonFrameTemplate_HideAttic(self)
	ButtonFrameTemplate_HideButtonBar(self)
	local titleBg = self:CreateTexture(nil, "ARTWORK")

	titleBg:SetPoint("TOPLEFT", self.TitleBg)
	titleBg:SetPoint("BOTTOMRIGHT", self.TitleBg)
	titleBg:SetColorTexture(0.184, 0.29, 0.0, 1)
	self.TitleText:SetText("Pins");

	self:SetClampedToScreen(true);

	self.pins = {}
	for y = 0, 8 do
		for x = 0, 6 do
			local btn = CreateFrame("Button", nil, self.selectorFrame, "EpsilonMapPinPickerButton");
			btn:SetPoint("TOPLEFT", "EpsilonMapPinPickerInset", 32 * x + 5, -32 * y - 5);
			btn:RegisterForDrag("LeftButton");
			btn:SetSize(32, 32);

			table.insert(self.pins, btn);
			btn.pickerIndex = #self.pins;
		end
	end

	NineSliceUtil.ApplyLayoutByName(self.NineSlice, "EpsilonGoldBorderFrameTemplateNoPortrait")
	EpsilonLib.Utils.NineSlice.SetBackgroundAsViewport(self.Inset, self.Inset.Bg)
end

local pins = {}

local function pin_OnClickArcanum(self)
	if IsControlKeyDown() and self.pin.actionType == 1 and self.pin.actionValue ~= "" then
		ARC.PHASE:CAST(self.pin.actionValue)
	end
end

local function pin_OnClickPhaseTeleport(self)
	if IsControlKeyDown() and self.pin.actionType == 2 and self.pin.actionValue ~= "" then
		EpsilonMap:PhaseTeleport(self.pin.actionValue)
	end
end

local function pin_OnClickOpenMap(self)
	if IsControlKeyDown() and self.pin.actionType == 3 and self.pin.actionValue ~= "" then
		WorldMapFrame:SetMapID(tonumber(self.pin.actionValue))
		WorldMapFrame:OnMapChanged()
	end
end

local function pin_OnClickDirections(self)
	local mapID = C_Map.GetBestMapForUnit("player")

	if C_Map.CanSetUserWaypointOnMap(mapID) then
		if C_SuperTrack.IsSuperTrackingUserWaypoint() then
			C_SuperTrack.SetSuperTrackedUserWaypoint(false)
		else
			local pos = UiMapPoint.CreateFromCoordinates(mapID, self.pin.x, self.pin.y)
			--local mapPoint = UiMapPoint.CreateFromVector2D(mapID, pos)
			C_Map.SetUserWaypoint(pos)
			C_SuperTrack.SetSuperTrackedUserWaypoint(true)
		end
	else
		print("Cannot set waypoints on this map")
	end
end

local function pin_OnClick(pinFrame)
	local pin = pinFrame.pin
	if pin.actionType == 1 and pin.actionValue ~= "" then
		pin_OnClickArcanum(pinFrame)
	elseif pin.actionType == 2 and pin.actionValue ~= "" then
		pin_OnClickPhaseTeleport(pinFrame)
	elseif pin.actionType == 3 and pin.actionValue ~= "" then
		pin_OnClickOpenMap(pinFrame)
	else
		--pin_OnClickDirections(pinFrame)
	end
end

local function CreatePinFrame(pin, minimap)
	local pinFrame = pinPool:Acquire()
	pinFrame:SetPoint("CENTER")
	pinFrame:SetSize(36, 36)
	pinFrame._isMiniMap = minimap or false

	local tex = pinFrame.tex
	local texCoords = GetPinCoords(pin.textureIndex)
	tex:SetSize(16, 16)
	tex:SetPoint("CENTER")
	tex:SetTexture(Utils.GetAddonAssetsPath("Pins\\CartographerMapMarkers"))
	tex:SetTexCoord(texCoords.left, texCoords.right, texCoords.top, texCoords.bottom)

	if pin.title then
		pinFrame:SetScript("OnEnter", pinTooltip_OnEnter)
		pinFrame:SetScript("OnLeave", GameTooltip_Hide)
	else
		pinFrame:SetScript("OnEnter", nil)
		pinFrame:SetScript("OnLeave", nil)
	end

	pinFrame:SetScript("OnClick", pin_OnClick)
	pinFrame.pin = pin

	return pinFrame
end

function EpsilonMap:CreatePin(cursorX, cursorY, textureIndex, mapID, title, subtitle, description, actionValue, background, phaseTeleport, discoverable, discoverRadius, actionType)
	local worldx, worldy, worldInstanceID = HereBeDragons:GetWorldCoordinatesFromZone(cursorX, cursorY, WorldMapFrame.mapID)
	local uid = worldx .. worldy .. WorldMapFrame.mapID
	local pin = {
		x = cursorX or 0.5,
		y = cursorY or 0.5,
		mapID = mapID or WorldMapFrame.mapID,
		textureIndex = textureIndex or "",
		title = title or "Generic Pin",
		subtitle = subtitle or nil,
		description = description or nil,
		actionType = 4,
		actionValue = actionValue or nil,
		background = background or { r = 1, g = 1, b = 1 },
		phaseTeleport = phaseTeleport or nil,
		discoverable = discoverable or false,
		discoverRadius = discoverRadius or 0,
		uid = uid,
		instance = worldInstanceID
	}
	return pin
end

function EpsilonMap_PinEditorMixin:SetColor()
	local button = self.ColorButton
	local function swatchFunc()
		local r, g, b = ColorPickerFrame:GetColorRGB();
		currentColor = { r = r, g = g, b = b }
		button:GetNormalTexture():SetVertexColor(r, g, b)
	end

	local ColorPickerOkayButton = _G["ColorPickerOkayButton"]
	local origOKButtonOnClick = ColorPickerOkayButton:GetScript("OnClick")

	local function cancelFunc()
	end

	ColorPickerOkayButton:SetScript("OnClick", function(self)
		local r, g, b = ColorPickerFrame:GetColorRGB()
		r, g, b = CreateColor(r, g, b):GetRGBAsBytes()
		local uintColor = (r * 2 ^ 24) + (g * 2 ^ 16) + (b * 2 ^ 8) + 0

		_G["ColorPickerFrame"]:Hide()
		self:SetScript("OnClick", origOKButtonOnClick)
	end)

	local options = {
		swatchFunc = swatchFunc,
		opacityFunc = nil,
		cancelFunc = cancelFunc,
		hasOpacity = false,
		opacity = 0,
		r = currentColor and currentColor.r or 1,
		g = currentColor and currentColor.g or 1,
		b = currentColor and currentColor.b or 1,
	};

	OpenColorPicker(options)
end

local actionTypeValue = 4
function EpsilonMap_PinEditorMixin:SavePin()
	local pinFrame

	for _, pinFrames in pairs(pinFrames) do
		for i, frame in pairs(pinFrames) do
			if frame.pin == self.pin then
				pinFrame = frame
			end
		end
	end
	self.pin.title = self.title:GetText()
	self.pin.subtitle = self.subtitle:GetText()
	self.pin.description = self.description.EditBox:GetText()
	self.pin.actionType = actionTypeValue
	self.pin.actionValue = self.actionValue:GetText()
	self.pin.discoverable = self.discoverableCheckButton:GetChecked()
	self.pin.discoverRadius = tonumber(self.radius:GetText() or 0)
	self.pin.background = currentColor or { r = 1, g = 1, b = 1 }
	currentColor = nil
	self.cancel = false
	EpsilonMap:SavePins()
	local mapID = WorldMapFrame.mapID
	local texCoords = GetPinCoords(self.pin.textureIndex)
	pinFrame.tex:SetTexCoord(texCoords.left, texCoords.right, texCoords.top, texCoords.bottom)

	hiddenPinFrames[mapID] = hiddenPinFrames[mapID] or {}
	if self.pin.discoverable then
		if not (C_Epsilon.IsDM or EpsilonMap.discoveredPins[self.pin.uid]) then
			pinFrame:Hide()
		end
		tinsert(hiddenPinFrames[mapID], pinFrame)
		for _, mapPinFrames in pairs(pinFrameMap) do
			for i, pinFrame in pairs(mapPinFrames) do
				if pinFrame.pin == self.pin then
					if not C_Epsilon.IsDM then
						pinFrame:Hide()
					end
				end
			end
		end
	else
		for i, frame in pairs(hiddenPinFrames[mapID]) do
			if frame == pinFrame then
				table.remove(hiddenPinFrames[mapID], i)
			end
		end
	end
	EpsilonMap:RefreshSidebar()
	self:Hide()
end

function EpsilonMap_PinEditorMixin:SetHighlightTexture(index)
	if not index then -- call with no index to clear / hide
		highlightTex:ClearAllPoints()
		highlightTex:Hide()
		return
	end

	local mapID = WorldMapFrame.mapID
	local pinFrame = pinFrames[mapID] and pinFrames[mapID][index]
	if not pinFrame then return end
	highlightTex:SetParent(pinFrame)
	highlightTex:ClearAllPoints()
	highlightTex:SetAllPoints()
	highlightTex:Show()
end

local info = UIDropDownMenu_CreateInfo()
local actionTypes = { "Arcanum Spell", "Phase Teleport", "Open Map", "Nothing" }
function EpsilonMap_PinEditorMixin:InitActionDropdown(self)
	UIDropDownMenu_SetWidth(self, 180)
	UIDropDownMenu_Initialize(self, function(dropdown, level)
		for i, actionType in ipairs(actionTypes) do
			info.text = actionType
			info.value = i
			info.checked = actionTypeValue == i
			info.func = function(self)
				actionTypeValue = i
				UIDropDownMenu_SetText(dropdown, self:GetText())
				if i == 3 then
					dropdown:GetParent().actionValueDropdown:Show()
					dropdown:GetParent().actionValue:Hide()
				else
					dropdown:GetParent().actionValueDropdown:Hide()
					dropdown:GetParent().actionValue:Show()
				end
			end
			UIDropDownMenu_AddButton(info, level)
		end
	end)
end

local menuInfo = {
}
function EpsilonMap_PinEditorMixin:InitActionValueDropdown(self)
	UIDropDownMenu_Initialize(self, function(dropdown, level)
		level = level or 1
		if (level == 1) then
			local maps = C_Map.GetMapChildrenInfo(946)
			for _, v in pairs(maps) do
				local map = C_Map.GetMapInfo(v.mapID)
				menuInfo.hasArrow = true
				menuInfo.text = map.name
				menuInfo.value = map.mapID
				menuInfo.arg1 = map
				menuInfo.checked = dropdown:GetParent().pin and dropdown:GetParent().pin.actionValue == map.mapID
				menuInfo.func = function(self)
					UIDropDownMenu_SetSelectedValue(dropdown, self:GetText())
					UIDropDownMenu_SetText(dropdown, self:GetText())
					dropdown:GetParent().actionValue:SetText(map.mapID)
				end
				UIDropDownMenu_AddButton(menuInfo, level);
			end
		else
			local maps = C_Map.GetMapChildrenInfo(UIDROPDOWNMENU_MENU_VALUE)
			for _, map in pairs(maps) do
				if C_Map.MapHasArt(map.mapID) then
					local text    = map.name
					local groupID = C_Map.GetMapGroupID(map.mapID)
					if groupID then
						local mapGroups = C_Map.GetMapGroupMembersInfo(groupID)
						if mapGroups then
							for _, groupMap in pairs(mapGroups) do
								if map.mapID == groupMap.mapID then
									text = text .. " - " .. groupMap.name
								end
							end
						end
					end

					menuInfo.text = text
					menuInfo.value = map.mapID
					menuInfo.arg1 = map
					menuInfo.checked = dropdown:GetParent().pin.actionValue == map.mapID
					menuInfo.func = function(self)
						UIDropDownMenu_SetSelectedValue(dropdown, self:GetText())
						UIDropDownMenu_SetText(dropdown, self:GetText())
						dropdown:GetParent().actionValue:SetText(map.mapID)
					end
					if (#C_Map.GetMapChildrenInfo(map.mapID) > 0) then
						menuInfo.hasArrow = true
					else
						menuInfo.hasArrow = false
					end
					UIDropDownMenu_AddButton(menuInfo, level);
				end
			end
		end
	end)
end

function EpsilonMap_PinEditorMixin:OpenEditor(mapID, index, cancel)
	if not EpsilonMap:HasBaseEditPermissions() then
		return
	end
	local editor = _G["EpsilonMapPinEditor"]
	if cancel then
		editor.CancelButton:SetText("Cancel")
		editor.CancelButton:SetScript("OnClick", function() DeletePinCallback(editor) end)
		editor.cancel = cancel
	else
		editor.CancelButton:SetText("Delete")
		editor.CancelButton:SetScript("OnClick", function() EpsilonMap_PinEditorMixin.DeletePin(editor) end)
		editor.cancel = false
	end
	editor:Show()
	local pin = pins[mapID] and pins[mapID][index]
	actionTypeValue = pin.actionType
	UIDropDownMenu_SetText(editor.actionTypeDropdown, actionTypes[pin.actionType])
	if not pin then return end
	EpsilonMap:SetPinTexture(editor.texture:GetNormalTexture(), pin.textureIndex)
	editor.editIndex = index
	editor.title:SetText(pin.title or "")
	editor.subtitle:SetText(pin.subtitle or "")
	editor.description.EditBox:SetText(pin.description or "")
	editor.actionValue:SetText(pin.actionValue or "")
	if pin.actionType == 3 then
		editor.actionValueDropdown:Show()
		editor.actionValue:Hide()
		actionTypeValue = pin.actionValue
		UIDropDownMenu_SetSelectedValue(editor.actionValueDropdown, tonumber(pin.actionValue))
		UIDropDownMenu_SetText(editor.actionValueDropdown, C_Map.GetMapInfo(tonumber(pin.actionValue)).name)
	else
		editor.actionValueDropdown:Hide()
		editor.actionValue:Show()
	end
	editor.pin = pin
	editor.discoverableCheckButton:SetChecked(pin.discoverable)
	editor.radius:SetText(pin.discoverRadius)
	editor.ColorButton:GetNormalTexture():SetVertexColor(pin.background.r, pin.background.g, pin.background.b)
	currentColor = pin.background
	EpsilonMap_PinEditorMixin:SetHighlightTexture(index)
end

function EpsilonMap:SetPins(pinTable, addToCurrent)
	if not pinTable then return end
	if not addToCurrent then
		self:ClearPins()
	end
	for mapID, mapPins in pairs(pinTable) do
		for _, pin in ipairs(mapPins) do
			if pin and (pin.x and pin.y and pin.textureIndex) then
				EpsilonMap:PlacePin(pin, mapID)
			end
		end
	end
end

function EpsilonMap:GetPins(mapID)
	if mapID then
		return pins[mapID]
	end
	return pins
end

local function __pin_OnShowHook(self)
	if not self.pin then return end

	-- always hide if pin is minimap and not set to show on minimap
	if self._isMiniMap and not self.pin.showOnMiniMap then return self:Hide() end

	-- hide if discoverable and not yet discovered / not in DM mode
	if self.pin.discoverable and (not EpsilonMap.discoveredPins[self.pin.uid] and not C_Epsilon.IsDM) then
		self:Hide()
	end
end

function EpsilonMap:PlacePin(pin, mapID)
	local pinFrame = CreatePinFrame(pin)
	local minimapPinFrame = CreatePinFrame(pin, true)

	if not minimapPinFrame.__onShowHooked then
		minimapPinFrame.__onShowHooked = true
		minimapPinFrame:HookScript("OnShow", __pin_OnShowHook)
	end

	HereBeDragonsPins:AddWorldMapIconMap(EpsilonMap, pinFrame, mapID, pin.x, pin.y)
	HereBeDragonsPins:AddMinimapIconMap(EpsilonMap, minimapPinFrame, mapID, pin.x, pin.y, nil, true)

	pinFrameMap[pin] = { map = pinFrame, minimap = minimapPinFrame }

	pins[mapID] = pins[mapID] or {}
	tinsert(pins[mapID], pin)

	pinFrames[mapID] = pinFrames[mapID] or {}
	tinsert(pinFrames[mapID], pinFrame)

	if pin.discoverable and (not EpsilonMap.discoveredPins[pin.uid] and not C_Epsilon.IsDM) then
		pinFrame:Hide()
		minimapPinFrame:Hide()
		hiddenPinFrames[mapID] = hiddenPinFrames[mapID] or {}
		tinsert(hiddenPinFrames[mapID], pinFrame)
	end
end

function EpsilonMap:RemovePin(pin)
	for _, mapFrames in pairs(pinFrames) do
		for _, frame in ipairs(mapFrames) do
			if frame.pin == pin then
				HereBeDragonsPins:RemoveWorldMapIcon(EpsilonMap, frame)
				frame:Hide()
			end
		end
	end
	for mapID, maps in pairs(pins) do
		for i, mapPin in ipairs(maps) do
			if mapPin == pin then
				table.remove(pins[mapID], i)
			end
		end
	end
	for _, mapPinFrames in pairs(pinFrames) do
		for i, pinFrame in pairs(mapPinFrames) do
			if pinFrame.pin == pin then
				table.remove(mapPinFrames, i)
				pinFrame:Hide()
			end
		end
	end
	for _, hiddenPinMapFrames in pairs(hiddenPinFrames) do
		for i, pinFrame in pairs(hiddenPinMapFrames) do
			if pinFrame.pin == pin then
				table.remove(hiddenPinMapFrames, i)
				pinFrame:Hide();
			end
		end
	end
end

function EpsilonMap:RemoveAllPins()
	HereBeDragonsPins:RemoveAllWorldMapIcons(EpsilonMap)
	HereBeDragonsPins:RemoveAllMinimapIcons(EpsilonMap)
	pinPool:ReleaseAll()
end

function EpsilonMap:ClearPins()
	self:RemoveAllPins()
	wipe(pins)
	wipe(pinFrames)
	wipe(hiddenPinFrames)
	wipe(pinFrameMap)
end

local function GetPinCoordinates(pin)
	local overrides = EpsilonMap.GetMapOverrides()
	if not (overrides[pin.mapID] and overrides[pin.mapID].boundaries) then
		return HereBeDragons:GetWorldCoordinatesFromZone(pin.x, pin.y, pin.mapID)
	end

	local x, y
	x = overrides[pin.mapID].boundaries.left - (overrides[pin.mapID].boundaries.left - overrides[pin.mapID].boundaries.right) * pin.x
	y = overrides[pin.mapID].boundaries.upper - (overrides[pin.mapID].boundaries.upper - overrides[pin.mapID].boundaries.lower) * pin.y
	return x, y
end

function EpsilonMap:RefreshHiddenPinVisibility()
	for mapID, mapPins in pairs(hiddenPinFrames) do
		for i = #mapPins, 1, -1 do
			local pinFrame = mapPins[i]
			local pin = pinFrame.pin
			local mmPin = pinFrameMap[pin] and pinFrameMap[pin].minimap

			local playerY, playerX = C_Epsilon.GetPosition()
			local _, _, _, _, _, _, _, instanceID = GetInstanceInfo()
			local pinX, pinY = GetPinCoordinates(pin)
			local radius = pin.discoverRadius

			if instanceID == pin.instance or (mapID == WorldMapFrame.mapID and EpsilonMap:GetMapOverrides(true)[instanceID]) then
				local isInRadius = math.pow((playerX - pinX), 2) + math.pow((playerY - pinY), 2) < math.pow(radius, 2)
				if isInRadius then
					EpsilonMap.discoveredPins[pin.uid] = true
					if mmPin and pin.showOnMiniMap then mmPin:Show() end
					EpsilonMap:RefreshSidebar()
					pinFrame:Show()
					tremove(mapPins, i)
				elseif C_Epsilon.IsDM and (instanceID == pin.instance or (mapID == WorldMapFrame.mapID and EpsilonMap:GetMapOverrides(true)[instanceID])) then
					if not pinFrame:IsShown() and mapID == WorldMapFrame.mapID then
						pinFrame:Show()
						EpsilonMap:RefreshSidebar()
					end
					if mmPin and pin.showOnMiniMap and not mmPin:IsShown() then
						mmPin:Show()
					end
				else
					if pinFrame:IsShown() then
						pinFrame:Hide()
						EpsilonMap:RefreshSidebar()
					end
					if mmPin and mmPin:IsShown() then
						mmPin:Hide()
					end
				end
			end
		end
	end
end

local pinWatch = CreateFrame("Frame")
local totalElapsed = 0
local discoveryTickTime = 0.5
pinWatch:SetScript("OnUpdate", function(self, elapsed)
	totalElapsed = totalElapsed + elapsed
	if totalElapsed < discoveryTickTime then return end
	totalElapsed = 0

	EpsilonMap:RefreshHiddenPinVisibility()
end)
