local addon_name, ns = ...
local Utils = ns.utils

EpsilonMap_SidebarMixin = {}
EpsilonMap_SidebarEntryMixin = {}
EpsilonMap_SidebarTabMixin = {}

local EpsilonMap = LibStub("AceAddon-3.0"):GetAddon("Epsilon_Map")

local assetPath = "Interface\\AddOns\\" .. addon_name .. "\\Assets\\"
local mapTexturesPath = "Interface\\AddOns\\" .. addon_name .. "\\Assets\\MapTextures\\"
local t = function(...) return mapTexturesPath .. table.concat({ ... }, "\\") end
local defaultMask = t("Terrain", "MapTerrain_Mask")


local function OnEvent(_, event)
	if event == "ZONE_CHANGED_NEW_AREA" or event == "PLAYER_ENTERING_WORLD" then
		EpsilonMap:RefreshSidebar()
	end
end

local showFeatures = false
local displayedGroups = {}

local fallbackColor = CreateColor(1, 1, 1, 1)
local featureLayerColor = CreateColorFromHexString("ff2c4b9f")
local featureHighlightColor = CreateColorFromHexString("FFCFDDFF")
CreateFont("Epsilon_Map_FeatureFontHighlight"):CopyFontObject("GameFontHighlight")
Epsilon_Map_FeatureFontHighlight:SetTextColor(featureHighlightColor:GetRGBA())

local FEATURE_LIST_ENTRY_HEIGHT = 24
local PIN_LIST_ENTRY_HEIGHT = 50

local function reverseIndex(max, i)
	return max - i + 1
end

-- Default height for description if not available
local DEFAULT_DESCRIPTION_HEIGHT = 75
local animateExpandLayerOnNextDraw = {}
--local selectedEntry = EpsilonMapSidebarMapFrame.selectedPinEntry -- moved to frame for access in pin editor

function EpsilonMap_SidebarTabMixin:SetSelected(selected)
	self:SetEnabled(not selected)
end

function EpsilonMap_SidebarTabMixin:OnEnter()
	self:SetNormalTexture(assetPath .. "UI\\CartographerTabHighlight")
end

function EpsilonMap_SidebarTabMixin:OnLeave()
	self:SetNormalTexture(assetPath .. "UI\\CartographerTab")
end

local function _showFeaturesTab()
	local sidebar = _G["EpsilonMapSidebarMapFrame"]
	local openEditorButton = sidebar.ToggleEditor
	openEditorButton:SetAsFeatureButton()
	sidebar.ToggleFeatures:SetSelected(true)
	sidebar.TogglePins:SetSelected(false)

	-- hide pin editor if open
	_G["EpsilonMapPinPicker"]:Hide()

	sidebar.FeatureScrollBox:Show()
	sidebar.FeatureScrollBar:Show()
	-- restore saved scroll position
	if sidebar._scrollPositions and sidebar._scrollPositions.features then
		if sidebar.FeatureScrollBox and sidebar.FeatureScrollBox.ScrollToOffset then
			sidebar.FeatureScrollBox:ScrollToOffset(sidebar._scrollPositions.features, FEATURE_LIST_ENTRY_HEIGHT, 0)
		end
	end

	sidebar.PinScrollBox:Hide()
	sidebar.PinScrollBar:Hide()
end
local function _showPinTab()
	local sidebar = _G["EpsilonMapSidebarMapFrame"]
	local openEditorButton = sidebar.ToggleEditor
	openEditorButton:SetAsPinButton()
	sidebar.ToggleFeatures:SetSelected(false)
	sidebar.TogglePins:SetSelected(true)

	-- hide feature picker if open
	_G["EpsilonMapFeaturePicker"]:Hide()

	sidebar.PinScrollBox:Show()
	sidebar.PinScrollBar:Show()
	-- restore saved scroll position using helper
	if sidebar._scrollPositions and sidebar._scrollPositions.pins then
		if sidebar.PinScrollBox and sidebar.PinScrollBox.ScrollToOffset then
			sidebar.PinScrollBox:ScrollToOffset(sidebar._scrollPositions.pins, PIN_LIST_ENTRY_HEIGHT, 0)
		end
	end

	sidebar.FeatureScrollBox:Hide()
	sidebar.FeatureScrollBar:Hide()
end

local sideBarEntryCount = 0

function EpsilonMap:RefreshSidebar()
	--print("Sidebar refreshed by", debugstack(2, 2, 0))
	local mapID = WorldMapFrame.mapID
	local sidebar = _G["EpsilonMapSidebarMapFrame"]
	local pins = EpsilonMap:GetPins(mapID) or {}
	local featureGroups = MapTextureManager:GetFeaturesByLayersForCurrentMap()
	sideBarEntryCount = 0

	sidebar._scrollPositions = sidebar._scrollPositions or { pins = 0, features = 0 }
	sidebar._scrollPositions.lock = true

	if showFeatures then
		-- populate a tree-backed ScrollBox list for features
		if not sidebar.FeatureScrollView or not sidebar.FeatureDataProvider then return end

		local DataProvider = sidebar.FeatureDataProvider
		DataProvider:Flush()

		for layerIndex = #featureGroups, 1, -1 do
			local layerHint = ""
			if layerIndex == 1 then
				layerHint = "   |cFF808080Bottom|r"
			elseif layerIndex == 16 then
				layerHint = "       |cFF808080Top|r"
			end
			local featureGroup = featureGroups[layerIndex]
			local layerData = {
				ButtonText = "Layer " .. reverseIndex(16, layerIndex) .. layerHint,
				type = "layer",
				count = #featureGroup,
				id = layerIndex,
			}

			local layerNode = DataProvider:Insert(layerData)
			if displayedGroups[layerIndex] == nil then displayedGroups[layerIndex] = false end
			layerNode:SetCollapsed(not displayedGroups[layerIndex])

			for _, instance in ipairs(featureGroup) do
				local def = MapTextureManager:GetDefinitionOfInstance(instance)
				local cat = MapTextureManager:GetCatForInst(instance)
				local featureData = {
					ButtonText = def and def.name or "Feature",
					type = "feature",
					__category = cat,
					__definition = def,
					__mtm_instance = instance,
				}
				layerNode:Insert(featureData)
			end
		end

		DataProvider:Invalidate()
		_showFeaturesTab()
	else
		-- pins mode: populate the linear ScrollBox data provider so pins use the same styling as features
		if not sidebar or not sidebar.Contents then return end

		local DataProvider = sidebar.PinDataProvider or self.PinDataProvider
		if not DataProvider then return end

		DataProvider:Flush()

		for i, pin in ipairs(pins) do
			if pin then
				if pin.discoverable and (not EpsilonMap.discoveredPins[pin.uid] and not C_Epsilon.IsDM) then
					-- skip undiscovered discoverable pins
				else
					local pdata = {
						title = pin.title,
						subtitle = pin.subtitle,
						textureIndex = pin.textureIndex,
						background = pin.background,
						pinIndex = i,
					}
					local node = DataProvider:Insert(pdata)
					node:Insert({ isDescription = true, pin = pin })
					node:SetCollapsed(i ~= EpsilonMapSidebarMapFrame.selectedPinEntry)
				end
			end
		end

		_showPinTab()
	end

	sidebar._scrollPositions.lock = false
end

function EpsilonMap_SidebarMixin:OnLoad()
	---------------------------------------------
	--- Set-up our frame, override blizzard frame, and watch for events
	---------------------------------------------

	self:RegisterEvent("ZONE_CHANGED_NEW_AREA")
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:SetScript("OnEvent", OnEvent)

	self:SetParent(_G["WorldMapFrame"]);
	self:SetFrameStrata("HIGH");
	self:ClearAllPoints();
	self:SetPoint("TOPRIGHT", -3, -25);
	self:SetPoint("BOTTOMRIGHT", -3, 3);
	self:Hide();

	Utils.AdjustDevTex(self.Background)
	Utils.AdjustDevTex(self.Header)

	_G["WorldMapFrame"].QuestLog = self
	self:HookScript("OnHide", function()
		MapTextureManager:DisableEditModeBecauseFramesHidden()
	end)

	-- Quick inject simple methods to the openEditor button to switch between pins<->features
	local openEditorButton = self.ToggleEditor
	function openEditorButton:SetAsFeatureButton()
		self:SetPoint("TOPRIGHT", self:GetParent().TogglePins, "BOTTOMRIGHT", -4, 0)
		self:SetText("Add Feature")
		self:GetParent().AddTextButton:Show()
	end

	function openEditorButton:SetAsPinButton()
		self:SetPoint("TOPRIGHT", self:GetParent().ToggleFeatures, "BOTTOMRIGHT", -4, 0)
		self:SetText("Add Pin")
		self:GetParent().AddTextButton:Hide()
	end

	--featureGroups = MapTextureManager:GetFeaturesByLayersForCurrentMap()

	---------------------------------------------
	--- Create Features Tab using ScrollBox set-up
	---------------------------------------------

	local contents = self.Contents
	local featureScroll = CreateFrame("Frame", nil, contents, "WowScrollBoxList")
	featureScroll:SetPoint("TOPLEFT", contents, "TOPLEFT", 0, 0)
	featureScroll:SetPoint("BOTTOMRIGHT", contents, "BOTTOMRIGHT", 0, 0)
	self.FeatureScrollBox = featureScroll

	local indent, top, bottom, left, right, spacing
	spacing = 2

	local ScrollView = CreateScrollBoxListTreeListView(indent, top, bottom, left, right, spacing)
	local DataProvider = CreateTreeListDataProvider()
	ScrollView:SetDataProvider(DataProvider)
	ScrollView:SetElementExtent(FEATURE_LIST_ENTRY_HEIGHT)

	self.FeatureScrollView = ScrollView
	self.FeatureDataProvider = DataProvider

	local featureScrollBar = CreateFrame("EventFrame", nil, contents, "WowTrimScrollBar")
	featureScrollBar:SetPoint("TOPLEFT", featureScroll, "TOPRIGHT", -0, -0)
	featureScrollBar:SetPoint("BOTTOMLEFT", featureScroll, "BOTTOMRIGHT", -0, 0)
	featureScrollBar:Hide()
	self.FeatureScrollBar = featureScrollBar

	ScrollUtil.InitScrollBoxListWithScrollBar(featureScroll, featureScrollBar, ScrollView)

	local function UpdateExpandVisual(button, expanded, animate)
		if not button or not button.ExpandButton then return end
		local btn = button.ExpandButton
		local tex = btn.GetNormalTexture and btn:GetNormalTexture()
		if tex and tex.SetRotation then
			local func = expanded and btn.Open or btn.Close
			func(btn, animate)
		end
	end

	local function _featureButton_OnClick(button, mouse_button, down)
		local data = button:GetElementData().data
		local instData = data.__mtm_instance

		if mouse_button == "RightButton" then
			button:OpenFeatureContextMenu(data.type, data)
			return
		end

		if data.type == "layer" then
			-- toggle tracked collapse state and rebuild tree
			if data.id then
				if displayedGroups[data.id] == nil then displayedGroups[data.id] = false end
				displayedGroups[data.id] = not displayedGroups[data.id]

				UpdateExpandVisual(button, displayedGroups[data.id])
				animateExpandLayerOnNextDraw[data.id] = true
				EpsilonMap:RefreshSidebar()
			end
		else
			if instData then
				MapTextureManager:SelectInstance(instData)
			end
		end
	end

	local function _visButton_OnClick(self)
		local data = self:GetParent():GetElementData().data

		if data.type == "layer" then
			MapTextureManager:ToggleCustomLayer(data.id)
			self:SetIconState(MapTextureManager:GetCustomLayerVis(data.id))
			MapTextureManager:RefreshAll()
			MapTextureManager:MarkEditorDirtyAndRequestSave()
		else
			local instData = data.__mtm_instance

			MapTextureManager:ToggleInstanceVis(instData)
			self:SetIconState(not instData.dis)
			MapTextureManager:RefreshAll()
			MapTextureManager:MarkEditorDirtyAndRequestSave()
		end
	end

	local function _lockButton_OnClick(self)
		local data = self:GetParent():GetElementData().data
		local instData = data.__mtm_instance
		local locked

		if data.type == "layer" then
			-- layer
			locked = MapTextureManager:ToggleLayerLocked(data.id)
		else
			-- feature
			locked = MapTextureManager:ToggleInstanceLock(instData)
			MapTextureManager:MarkEditorDirtyAndRequestSave()
		end
		self:SetIconState(locked)
		MapTextureManager:PositionHandles(instData)
	end

	local function _FeatureInitializer(button, node)
		local data = node:GetData()
		local text = data.ButtonText or ""
		local instData = data.__mtm_instance
		if instData and instData.text then text = ("Text: %s"):format(instData.text:gsub("[\n\r]", "\\")) end
		button:SetText(text)

		-- Click Handler
		button:SetScript("OnClick", _featureButton_OnClick)

		-- Visuals
		if data.type == "layer" then
			-- Layer Visuals:
			-- Update background
			local texture = Utils.GetAddonAssetsPath("UI\\CartographerEntryBackground" .. ((data.id - 1) % 4) + 1)
			button.Background:SetTexture(texture)

			-- Hide Icon Stuff
			button.Icon:SetWidth(6); button.Icon:Hide(); button.IconBorder:Hide(); button.IconBg:Hide()

			-- Show & Set FeatureCount
			button.FeatureCount:Show(); button.FeatureCount:SetText("(" .. (data.count or 0) .. ")")

			-- Show expand button & update it's visual/animate; remove any pending animate on next draw.
			button.ExpandButton:Show()
			UpdateExpandVisual(button, displayedGroups[data.id], animateExpandLayerOnNextDraw[data.id])
			animateExpandLayerOnNextDraw[data.id] = nil

			-- Update Vis Button
			button.VisibilityButton:Show()
			button.VisibilityButton:SetPoint("RIGHT", button.ExpandButton, "LEFT", 0, 0)
			button.VisibilityButton:SetIconState(MapTextureManager:GetCustomLayerVis(data.id))

			-- Update Lock Button
			local layer = data.id
			local isLayerLocked = MapTextureManager.layerLock[layer]
			button.LockButton:SetIconState(isLayerLocked or false)

			-- Set the color
			button.Background:SetVertexColor(featureLayerColor:GetRGB())

			-- Set the font
			button:SetNormalFontObject("GameFontNormalLarge")
			button:SetHighlightFontObject("GameFontHighlightLarge")

			-- Hide Highlight if not moused over
			if not button:IsMouseOver() then
				button.Highlight:Hide()
			end
		else
			local def = data.__definition or ns.MFD.InvalidDefinition
			local category = data.__category
			-- Feature Visuals:
			-- Update Background
			sideBarEntryCount = sideBarEntryCount + 1
			local texture = Utils.GetAddonAssetsPath("UI\\CartographerEntryBackground" .. ((sideBarEntryCount - 1) % 4) + 1)
			button.Background:SetTexture(texture)

			-- Show Icon Stuff
			button.Icon:SetWidth(25); button.Icon:Show(); button.IconBorder:Show(); button.IconBg:Show()

			--[[
			if def.mask then
				button.IconMask:SetTexture(def.mask or defaultMask)
			else
				button.IconMask:SetAtlas("CircleMaskScalable")
			end
			--]]
			button.IconMask:SetAtlas("CircleMaskScalable")
			button.IconMask:Show()

			-- Hide FeatureCount & Expand Button
			if button.FeatureCount then button.FeatureCount:Hide() end
			if button.ExpandButton then button.ExpandButton:Hide() end

			-- Update Vis Button
			button.VisibilityButton:Show()
			button.VisibilityButton:SetPoint("RIGHT", button.ExpandButton, "RIGHT", 0, 0) -- takes spot of expand button
			button.VisibilityButton:SetIconState(not instData.dis)

			-- Update Lock Button
			button.LockButton:SetIconState((instData and instData.lock) or false)

			-- Set Color by Category
			local color = category and category.color or fallbackColor
			button.Background:SetVertexColor(color:GetRGB())

			-- Update Icon
			if def.atlas then
				button.Icon:SetAtlas(def.atlas, false, nil, true)
			else -- Texture / TexCoords
				button.Icon:SetTexture(def.file)

				if def.texCoords then
					button.Icon:SetTexCoord(unpack(def.texCoords))
				else
					button.Icon:SetTexCoord(0, 1, 0, 1)
				end
			end

			-- Set the font
			button:SetNormalFontObject("GameFontHighlight")
			button:SetHighlightFontObject("Epsilon_Map_FeatureFontHighlight")

			-- Update the highlight as needed
			if data.__mtm_instance and MapTextureManager:GetSelected() == data.__mtm_instance then
				button.Highlight:SetAlpha(1)
				button.Highlight:Show(1)
			else
				button.Highlight:SetAlpha(1)
				button.Highlight:Hide()
			end
		end

		-- Add Button Click Handlers
		button.VisibilityButton:SetScript("OnClick", _visButton_OnClick)
		button.LockButton:SetScript("OnClick", _lockButton_OnClick)

		-- cleanse old references if present
		if button.__mtm_instance then
			if button.__mtm_instance.__sidebar == button then -- same button, remove it
				data.__mtm_instance.__sidebar = nil
			end

			--remove
			button.__mtm_instance = nil
		end

		if data.__mtm_instance then
			data.__mtm_instance.__sidebar = button
			button.__mtm_instance = data.__mtm_instance
		end
	end

	ScrollView:SetElementInitializer("BUTTON", "EpsilonMapSidebarFeatureListEntryTemplate", _FeatureInitializer)

	---------------------------------------------
	--- Create Pins Tab using ScrollBox set-up
	---------------------------------------------

	local pinScroll = CreateFrame("Frame", nil, contents, "WowScrollBoxList")
	pinScroll:SetPoint("TOPLEFT", contents, "TOPLEFT", 0, 0)
	pinScroll:SetPoint("BOTTOMRIGHT", contents, "BOTTOMRIGHT", 0, 0)
	self.PinScrollBox = pinScroll

	local PinScrollView = CreateScrollBoxListTreeListView(-1)
	local PinDataProvider = CreateTreeListDataProvider()
	PinScrollView:SetDataProvider(PinDataProvider)
	PinScrollView:SetElementExtent(PIN_LIST_ENTRY_HEIGHT)

	self.PinScrollView = PinScrollView
	self.PinDataProvider = PinDataProvider

	-- initialize the list element to use the same entry template as the XML pin frames
	local function PinInitializer(button, node)
		local data = node:GetData()
		if not data then return end
		if not data.isDescription then
			EpsilonMap:SetPinTexture(button.Icon, data.textureIndex)
			button.Title:SetText(data.title or "")
			button.SubTitle:SetText(data.subtitle or "")
			button.Description:Hide()
			button.Title:Show()
			button.SubTitle:Show()
			button.Icon:Show()
			button.IconBorder:Show()
			button.EditButton:Show()

			sideBarEntryCount = sideBarEntryCount + 1
			local texture = Utils.GetAddonAssetsPath("UI\\CartographerEntryBackground" .. ((sideBarEntryCount - 1) % 4) + 1)
			button.Background:SetTexture(texture)

			if button.Background and data.background then
				button.Background:SetVertexColor(data.background.r or 1, data.background.g or 1, data.background.b or 1, 1)
			end
			button.pinIndex = data.pinIndex
			button:SetScript("OnClick", function(self)
				-- Toggle Collapsed State (Showing the description in this case)
				PinDataProvider:CollapseAll()
				if EpsilonMapSidebarMapFrame.selectedPinEntry ~= node.data.pinIndex then
					node:ToggleCollapsed()
				end
				local editor = _G["EpsilonMapPinEditor"]

				if self.pinIndex then
					if node:IsCollapsed() then
						-- Collapsed - unselect, unless selected in editor, in which case still keep the highlight
						self:UnselectPinEntry()
						self.selectedNode = nil
						if editor and editor:IsShown() and editor.editIndex == data.pinIndex then
							EpsilonMap_PinEditorMixin:SetHighlightTexture(data.pinIndex)
						end
					else
						-- Expanded - select
						self:SelectPinEntry()
					end
				else
					-- No index; weird. Just unselect I guess
					self:UnselectPinEntry()
				end
			end)
		else
			button.Description:SetText(data.pin.description)
			button.Description:Show()
			button.Title:Hide()
			button.SubTitle:Hide()
			button.Icon:Hide()
			button.IconBorder:Hide()
			button.EditButton:Hide()
			button.Background:SetVertexColor(0, 0, 0, 0.5)
			if data.pin.pinIndex ~= EpsilonMapSidebarMapFrame.selectedPinEntry then
				button:Hide()
			else
				button:Show()
			end
		end
	end

	PinScrollView:SetElementInitializer("BUTTON", "EpsilonMapSidebarPinListEntryTemplate", PinInitializer)

	local pinScrollBar = CreateFrame("EventFrame", nil, contents, "WowTrimScrollBar")
	pinScrollBar:SetPoint("TOPLEFT", pinScroll, "TOPRIGHT", -0, -0)
	pinScrollBar:SetPoint("BOTTOMLEFT", pinScroll, "BOTTOMRIGHT", -0, 0)
	pinScrollBar:Hide()
	self.PinScrollBar = pinScrollBar

	ScrollUtil.InitScrollBoxListWithScrollBar(pinScroll, pinScrollBar, PinScrollView)

	---------------------------------------------
	--- Scroll Position Persistence on Pins & Features
	---------------------------------------------

	self._scrollPositions = self._scrollPositions or { pins = 0, features = 0 }
	-- update stored scroll positions when scrollbars move
	local function onFeatureScrollValueChanged()
		self._scrollPositions = self._scrollPositions or { pins = 0, features = 0 }
		if self._scrollPositions.lock then return end
		if featureScroll and featureScroll.GetDerivedScrollOffset then
			self._scrollPositions.features = featureScroll:GetDerivedScrollOffset() or 0
		end
	end
	local function onPinScrollValueChanged()
		self._scrollPositions = self._scrollPositions or { pins = 0, features = 0 }
		if self._scrollPositions.lock then return end
		if pinScroll and pinScroll.GetDerivedScrollOffset then
			self._scrollPositions.pins = pinScroll:GetDerivedScrollOffset() or 0
		end
	end
	featureScrollBar:RegisterCallback("OnScroll", onFeatureScrollValueChanged, "scrollSaver")
	pinScrollBar:RegisterCallback("OnScroll", onPinScrollValueChanged, "scrollSaver")
end

function EpsilonMap_SidebarMixin:OnShow()
	if EpsilonMap:HasElevatedEditPermissions() then
		self.ToggleEditor:Show()
		self.ToggleFeatures:Show()
		self.TogglePins:Show()
		self.TogglePins:Enable()
		self.AddTextButton:Show()
		self.SettingsButton:Show()

		self.TogglePins:SetPoint("TOPRIGHT", self.TogglePins:GetParent().Header, "BOTTOM", 0, 1)
		self.TogglePins:SetHeight(26)
	else
		self.ToggleEditor:Hide()
		self.ToggleFeatures:Hide()
		self.TogglePins:Disable()
		self.AddTextButton:Hide()
		self.SettingsButton:Hide()

		self.TogglePins:SetPoint("TOPRIGHT", self.TogglePins:GetParent().Header, "BOTTOMRIGHT")
		self.TogglePins:SetHeight(47)
	end
end

function EpsilonMap_SidebarEntryMixin:SelectPinEntry(index)
	index = index or self.pinIndex
	if not index then return end
	EpsilonMapSidebarMapFrame.selectedPinEntry = index
	EpsilonMap_PinEditorMixin:SetHighlightTexture(index)
end

function EpsilonMap_SidebarEntryMixin:UnselectPinEntry()
	EpsilonMapSidebarMapFrame.selectedPinEntry = nil
	EpsilonMap_PinEditorMixin:SetHighlightTexture()
end

function EpsilonMap_SidebarEntryMixin:ToggleFeatureGroup(id)
	if displayedGroups[id] == nil then displayedGroups[id] = false end
	displayedGroups[id] = not displayedGroups[id]
	EpsilonMap:RefreshSidebar()
end

function EpsilonMap_SidebarEntryMixin:EditButtonLoad()
	self.defaultHeight = self:GetHeight()
	if not C_Epsilon.IsOwner() or (EpsilonMap.allowOfficers and C_Epsilon.IsOfficer()) then
		self.EditButton:Hide()
	end
end

local selectedContextMenuData
local layer_move_menu = {}
for i = 16, 1, -1 do
	table.insert(layer_move_menu,
		LibScrollableDropdown:CreateButton(
			"Layer " .. reverseIndex(16, i),
			function(item, arg1, arg2, entry, button)
				if selectedContextMenuData then
					if selectedContextMenuData.__mtm_instance then -- instance
						MapTextureManager:SetInstanceLayer(selectedContextMenuData.__mtm_instance, i)
					elseif selectedContextMenuData.id then -- layer
						if selectedContextMenuData.id == i then return end -- do nothing on same layer
						MapTextureManager:MoveAllOnLayerToOtherLayer(selectedContextMenuData.id, i)
					end
				end
			end, -- callback
			function()
				if selectedContextMenuData then
					if selectedContextMenuData.__mtm_instance
						and MapTextureManager:GetBestValueForInstField(selectedContextMenuData.__mtm_instance, "layer") == i -- 9 = default layer
					then
						return true
					elseif selectedContextMenuData.id == i then
						return true
					end
				end
			end -- checked
		)
	)
end

local function _scaleEntry_SetScale(self, text)
	if not text then text = self:GetText() end

	local value = tonumber(text)
	if not value then value = 0 end -- 0 turns into auto-best-scale
	if value and selectedContextMenuData and selectedContextMenuData.__mtm_instance then
		MapTextureManager:SetInstanceScale(selectedContextMenuData.__mtm_instance, value)
	end
end

local sidebar_feature_context_menus = {
	feature = {
		LibScrollableDropdown:CreateTitle("Edit Feature"),
		LibScrollableDropdown:CreateButton("Copy", function()
			if not selectedContextMenuData or not selectedContextMenuData.__mtm_instance then return end
			MapTextureManager:CopyInstance(selectedContextMenuData.__mtm_instance)
		end),
		LibScrollableDropdown:CreateDivider(),
		LibScrollableDropdown:CreateSubMenu("Move to Layer..", layer_move_menu),
		LibScrollableDropdown:CreateSubMenu("Set Scale",
			{ LibScrollableDropdown:CreateInput({
				width = 100,
				autoFocus = true,
				OnTextChanged = _scaleEntry_SetScale,
				inputText = function()
					if not selectedContextMenuData or not selectedContextMenuData.__mtm_instance then return "" end
					local scale = MapTextureManager:GetBestValueForInstField(selectedContextMenuData.__mtm_instance, "scale") or 1
					return ("%.4g"):format(scale)
				end,
			}, _scaleEntry_SetScale) }
		),
		LibScrollableDropdown:CreateDivider(),
		LibScrollableDropdown:CreateButton("Delete", function()
			if not selectedContextMenuData or not selectedContextMenuData.__mtm_instance then return end
			MapTextureManager:RemoveInstance(selectedContextMenuData.__mtm_instance)
		end)
	},
	layer = {
		LibScrollableDropdown:CreateTitle("Edit Layer"),
		LibScrollableDropdown:CreateDivider(),
		LibScrollableDropdown:CreateSubMenu("Move All to Layer..", layer_move_menu),
		LibScrollableDropdown:CreateSubMenu("Delete All in Layer..", {
			LibScrollableDropdown:CreateButton("Confirm Delete All", function()
				if not selectedContextMenuData or not selectedContextMenuData.id then return end
				MapTextureManager:RemoveAllInstanceInLayer(selectedContextMenuData.id)
			end),
		}),
		--LibScrollableDropdown:CreateSubMenu("Copy All to Layer..", layer_move_menu), -- // needs it's own menu probably, or fix menu to include extra data properly
		LibScrollableDropdown:CreateDivider(),
	},
}
function EpsilonMap_SidebarEntryMixin:OpenFeatureContextMenu(context, data)
	selectedContextMenuData = data
	LibScrollableDropdown:Open(self, sidebar_feature_context_menus[context])
end

function EpsilonMap_SidebarMixin:SetShowFeatures(show)
	-- persist current scrollbar value for current mode
	self._scrollPositions = self._scrollPositions or { pins = 0, features = 0 }
	self._scrollPositions.lock = true
	local sidebar = _G["EpsilonMapSidebarMapFrame"]
	if showFeatures then
		-- currently in features mode, save features scrollbar
		self._scrollPositions.features = self.FeatureScrollBox:GetDerivedScrollOffset() or 0
	else
		-- currently in pins mode, save pins scrollbar
		self._scrollPositions.pins = self.PinScrollBox:GetDerivedScrollOffset() or 0
	end

	showFeatures = show

	-- show/hide scrollbars and restore saved positions
	if showFeatures then
		_showFeaturesTab()
	else
		_showPinTab()
	end

	self:Refresh()
	self._scrollPositions.lock = false
end

function EpsilonMap_SidebarMixin:OpenEditor()
	if showFeatures then
		_G["EpsilonMapFeaturePicker"]:Show()
	else
		_G["EpsilonMapPinPicker"]:Show()
	end
end

function EpsilonMap_SidebarMixin:OpenSettingsMenu()
	-- TODO
	EpsilonMapCartographerSettings:Show()
end

function EpsilonMap_SidebarMixin:OpenPinEditor()
	local editor = _G["EpsilonMapPinEditor"]
	if editor and editor:IsShown() then
		editor:Hide()
	else
		editor:Show()
	end
end

function EpsilonMap_SidebarMixin:UpdatePOIs()
	-- wtf was this for? I don't remember LOL
end

function EpsilonMap_SidebarMixin:Refresh()
	-- disabled so that Blizzard stops redundantly calling this; let us control instead.
	--EpsilonMap:RefreshSidebar()
end

EpsilonDropdownExpandButtonMixin = {}
function EpsilonDropdownExpandButtonMixin:Open(animate)
	self.ActivateAnim:Stop()
	self.ActivateAnim.isReverse = false
	if animate then
		self.ActivateAnim:Play()
	else
		self.ActivateAnim:GetScript("OnFinished")(self.ActivateAnim)
	end
end

function EpsilonDropdownExpandButtonMixin:Close(animate)
	self.ActivateAnim:Stop()
	self.ActivateAnim.isReverse = true
	if animate then
		self.ActivateAnim:Play(true)
	else
		self.ActivateAnim:GetScript("OnFinished")(self.ActivateAnim)
	end
end

function EpsilonDropdownExpandButtonMixin:OnLoad()
	self:EnableMouse(false) -- we made it a button, but the main button also does the same thing & we want the nice highlight, so just.. don't use mouse on this one.. lol
	self.ActivateAnim:SetScript("OnPlay", function()
		self.ArrowIcon:SetRotation(0)
	end)
	self.ActivateAnim:SetScript("OnFinished", function()
		if self.ActivateAnim.isReverse then self.ArrowIcon:SetRotation(0) else self.ArrowIcon:SetRotation(math.rad(-90)) end
	end)

	LibStub("AceAddon-3.0"):GetAddon("Epsilon_Map")._Utils.AdjustDevTex(self:GetNormalTexture())
	LibStub("AceAddon-3.0"):GetAddon("Epsilon_Map")._Utils.AdjustDevTex(self.ArrowIcon)
end

function EpsilonDropdownExpandButtonMixin:OnClick(...)
	self:GetParent():Click(...)
end
