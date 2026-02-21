local addon_name, ns = ...
local Utils = ns.utils

local EpsilonMap = LibStub("AceAddon-3.0"):GetAddon("Epsilon_Map")
EpsilonMap_FeaturePickerMixin = {}
EpsilonMap_FeaturePickerButtonMixin = {}

local assetPath = "Interface\\AddOns\\" .. addon_name .. "\\Assets\\"
local mapTexturesPath = assetPath .. "MapTextures\\"
local t = function(...) return mapTexturesPath .. table.concat({ ... }, "\\") end
local defaultMask = t("Terrain", "MapTerrain_Mask")

local maskPool
local function _createMaskPool(canvas)
	if not canvas then return end
	if maskPool then return end

	local function resetter(_, tex)
		tex:ClearAllPoints()
		tex:SetTexture(nil)
		tex:Hide()
	end

	maskPool = CreateMaskPool(canvas, nil, nil, nil, resetter)
end

local function styleTextureByDefinition(texture, definition)
	if not texture or not definition then return end
	-- Tiling
	local tileMode
	if definition.tile then
		tileMode = "REPEAT"
	end

	local texW, texH, texAspect

	-- Atlas
	if definition.atlas then
		texture:SetHorizTile(false)
		texture:SetVertTile(false)
		texture:SetAtlas(definition.atlas, false, nil, true)

		local atlasInfo = C_Texture.GetAtlasInfo(definition.atlas)
		texAspect = atlasInfo.width / atlasInfo.height
	else -- Texture / TexCoords
		texture:SetTexture(definition.file)
		texAspect = definition.width / definition.height

		if definition.texCoords then
			texture:SetTexCoord(unpack(definition.texCoords))
		else
			texture:SetTexCoord(0, 1, 0, 1)
		end

		if definition.tile then
			--texture:SetHorizTile(true)
			--texture:SetVertTile(true)

			local tileScaleOffset = (2 / 5) * (definition.scale or 1)
			local tl_Inset = 0 + (1 * tileScaleOffset)
			local br_Inset = 1 - (1 * tileScaleOffset)

			texture:SetTexCoord(tl_Inset, br_Inset, tl_Inset, br_Inset)
		else
			--texture:SetHorizTile(false)
			--texture:SetVertTile(false)
		end
	end

	-- Set Texture size based on aspect ratio, max 74 in largest dimension
	local maxSize = 72
	local width, height
	if texAspect >= 1 then
		width = maxSize
		height = maxSize / texAspect
	else
		height = maxSize
		width = maxSize * texAspect
	end
	texture:SetSize(width, height)


	-- Masking
	if definition.mask then
		local maskTex = (type(definition.mask) == "string" and definition.mask) or defaultMask
		texture.mask = texture.mask or maskPool:Acquire()
		texture.mask:SetAllPoints(texture)
		texture.mask:SetTexture(maskTex)
		texture.mask:Show()
		texture:AddMaskTexture(texture.mask)
	elseif texture.mask then
		texture:RemoveMaskTexture(texture.mask)
		maskPool:Release(texture.mask)
		texture.mask = nil
	end
end

local function reverseIndex(max, i)
	return max - i + 1
end

local definitions = {}
local selectedCat
local currentSearch
local featureButtons

function EpsilonMap_FeaturePickerButtonMixin:Refresh()
	local definition = definitions[self.pickerIndex]

	if not definition then
		self:Hide()
		if self:IsMouseOver() then GameTooltip_Hide() end
	else
		self:Show()
		styleTextureByDefinition(self.FeatureTexture, definition)
		self.definition = definition

		if self:IsMouseOver() then
			self:GetScript("OnEnter")(self)
		end
	end
end

function EpsilonMap_FeaturePickerButtonMixin:OnClick()
	-- nothing to do here for now
end

function EpsilonMap_FeaturePickerButtonMixin:OnDoubleClick()
	local nx, ny = MapTextureManager:GetCenterCanvasPosition()
	local layer = (EpsilonMapFeaturePicker and EpsilonMapFeaturePicker.LayerOverrideInput) and (EpsilonMapFeaturePicker.LayerOverrideInput:GetValue() > 0 and EpsilonMapFeaturePicker.LayerOverrideInput:GetValue()) or nil
	MapTextureManager:AddFeature({ x = nx, y = ny, defID = self.definition.id, layer = (layer and reverseIndex(16, layer)) })
end

function EpsilonMap_FeaturePickerButtonMixin:OnDragStart()
	local dragIcon = _G["EpsilonMapDragIcon"]
	local uiScale, x, y = UIParent:GetEffectiveScale(), GetCursorPosition()
	styleTextureByDefinition(dragIcon.Texture, self.definition)
	dragIcon:Show()
	dragIcon:ClearAllPoints()
	local scale = MapTextureManager:GetBestAutoDefaultScale()
	local canvasScale = WorldMapFrame.ScrollContainer.Child:GetScale()
	dragIcon:SetSize(self.definition.width * scale * canvasScale, self.definition.height * scale * canvasScale)

	dragIcon:SetPoint("CENTER", nil, "BOTTOMLEFT", x / uiScale, y / uiScale)
	dragIcon:StartMoving()
end

function EpsilonMap_FeaturePickerButtonMixin:OnDragStop()
	local dragIcon = _G["EpsilonMapDragIcon"]
	dragIcon:Hide()
	dragIcon:ClearAllPoints()
	dragIcon:StopMovingOrSizing();
	local uiScale, x, y = UIParent:GetEffectiveScale(), GetCursorPosition()
	local x, y = MapTextureManager:GetCursorCanvasPosition()
	local scale = MapTextureManager:GetBestAutoDefaultScale()
	local layer = (EpsilonMapFeaturePicker and EpsilonMapFeaturePicker.LayerOverrideInput) and (EpsilonMapFeaturePicker.LayerOverrideInput:GetValue() > 0 and EpsilonMapFeaturePicker.LayerOverrideInput:GetValue()) or nil
	MapTextureManager:AddFeature({ x = x, y = y, scale = scale, defID = self.definition.id, layer = (layer and reverseIndex(16, layer)) })
end

function EpsilonMap_FeaturePickerButtonMixin:OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT", -16, -4)
	GameTooltip_SetTitle(GameTooltip, self.definition.name)
	GameTooltip:Show();
end

function EpsilonMap_FeaturePickerButtonMixin:OnLeave()
	GameTooltip_Hide()
end

function EpsilonMap_FeaturePickerMixin:OnScroll(scrollbar)
	local offset = scrollbar:GetValue()
	for index, featureFrame in ipairs(featureButtons or {}) do
		featureFrame.pickerIndex = index + offset
		featureFrame:Refresh()
	end
end

function EpsilonMap_FeaturePickerMixin:SetFilter(catID, ...)
	local filtered = {}
	local searches = { ... }

	local categoryDefs
	if self.searchAll:GetChecked() then
		self.CategoryLabel:SetText("Category: All")
		categoryDefs = MapTextureManager:GetDefinitionsOrdered()
	else
		self.CategoryLabel:SetText("Category: " .. (MapTextureManager:GetCategories()[catID].name or "Unknown"))
		categoryDefs = MapTextureManager:GetDefinitionsInCategory(catID)
	end

	if #searches == 0 then -- just the categoryDefs in raw, and move on
		filtered = categoryDefs
	else                -- actually do the searching
		-- Normalize search strings
		for i = 1, #searches do
			searches[i] = strtrim(string.lower(searches[i]))
		end

		for i = 1, #categoryDefs do
			local def = categoryDefs[i]

			-- Build searchable text
			local haystack = string.lower(
				table.concat({
					def.name or "",
					def.id or "",
				}, " ")
			)

			local pass = true

			for j = 1, #searches do
				if searches[j] ~= "" and not string.find(haystack, searches[j], 1, true) then
					pass = false
					break
				end
			end

			if pass then
				filtered[#filtered + 1] = def
			end
		end
	end

	definitions = filtered
	selectedCat = catID
	self.search.currentSearch = searches
	self:RefreshFeatureButtons(true)
end

function EpsilonMap_FeaturePickerMixin:SetCategory(catID)
	self:SetFilter(catID, unpack(self.search.currentSearch))
end

function EpsilonMap_FeaturePickerMixin:SetSearchByString(str)
	local tbl = {}
	if strtrim(str) ~= "" then
		for v in string.gmatch(str, "[^ ]+") do
			tinsert(tbl, v)
		end
	end

	self.search.currentSearch = tbl -- log for category change only
	self:SetFilter(selectedCat, unpack(tbl))
end

local CATEGORY_BUTTON_SIZE = 32
local CATEGORY_BUTTON_PADDING = 2
local CATEGORY_BUTTON_EXTENT = CATEGORY_BUTTON_SIZE + CATEGORY_BUTTON_PADDING
local VISIBLE_CATEGORY_ROWS = 12
local ARROW_TOP_BUFFER = 16

local function _setupCatButton(button, elementData)
	-- One-time setup
	if not button.initialized then
		local root = button:GetParent():GetParent():GetParent():GetParent()
		button:SetSize(CATEGORY_BUTTON_SIZE, CATEGORY_BUTTON_SIZE)

		button:SetScript("OnEnter", function(self)
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT", -16, -4)
			GameTooltip_SetTitle(GameTooltip, self.catData.name, NORMAL_FONT_COLOR)
			GameTooltip:Show();
		end)

		button:SetScript("OnLeave", GameTooltip_Hide)

		button:SetScript("OnClick", function(self)
			--local root = self:GetParent():GetParent():GetParent():GetParent()
			root:SetCategory(self.catID)
			root.CategorySelectionBehaviorRegistry:SelectElementData(elementData)
			--self.SelectedTexture:Show()
			root:RefreshFeatureButtons(true)
		end)

		root.CategorySelectionBehaviorRegistry:RegisterCallback("OnSelectionChanged", function()
			if button.catID == selectedCat then
				button.SelectedTexture:Show()
			else
				button.SelectedTexture:Hide()
			end
		end, button)

		button:SetScript("OnMouseDown", function(self)
			if IsMouseButtonDown("LeftButton") then
				local _, y = GetCursorPosition()
				local scale = UIParent:GetEffectiveScale()
				y = y / scale

				self:GetParent():GetParent():GetParent():GetParent():BeginDragScroll(y)
			end
		end)

		button:SetScript("OnMouseUp", function(self)
			self:GetParent():GetParent():GetParent():GetParent():EndDragScroll()
		end)

		button:SetHighlightTexture(assetPath .. "UI\\CartographerNodeHighlight.blp")
		local highlight = button:GetHighlightTexture()

		highlight:SetAlpha(1)
		highlight:SetBlendMode("ADD")

		button.SelectedTexture = button:CreateTexture(nil, "OVERLAY")
		button.SelectedTexture:SetAllPoints(button)
		button.SelectedTexture:SetTexture(assetPath .. "UI\\FeatureCategories\\CategoryHighlight.blp")
		button.SelectedTexture:Hide()

		button.initialized = true
	end

	-- Per-element data
	local catData = elementData.catData
	if not catData then return end
	if catData.icon and catData.icon ~= "" then
		local texturePath = assetPath .. "UI\\FeatureCategories\\Category" .. catData.icon
		button:SetNormalTexture(texturePath)
	else
		button:SetNormalAtlas("128-Store-Main")
	end

	if selectedCat == elementData.catID then
		button.SelectedTexture:Show()
	else
		button.SelectedTexture:Hide()
	end

	button.catID   = elementData.catID
	button.catData = elementData.catData
end

function EpsilonMap_FeaturePickerMixin:InitCategoryScrollBox()
	if self.scrollBox then return end

	-- ScrollBox
	self.scrollBox = CreateFrame("Frame", nil, self.selectorFrame, "WowScrollBoxList")
	self.scrollBox:SetPoint("TOPRIGHT", self.Inset, "TOPLEFT", -2, -20)
	self.scrollBox:SetSize(
		CATEGORY_BUTTON_SIZE,
		VISIBLE_CATEGORY_ROWS * CATEGORY_BUTTON_EXTENT
	)

	-- View (LIST view)
	self.scrollView = CreateScrollBoxListLinearView()
	self.scrollView:SetPadding(0, 0, 0, 0, 2)
	self.scrollView:SetElementExtent(CATEGORY_BUTTON_SIZE)

	self.scrollView:SetElementInitializer(
		"Button",
		nil,
		_setupCatButton
	)

	-- Assign view AFTER initializer
	self.scrollBox:SetView(self.scrollView)

	-- Data provider
	self.dataProvider = CreateDataProvider()
	self.scrollBox:SetDataProvider(self.dataProvider)

	-- Scrollbar (Minimal)
	self.scrollBar = CreateFrame("EventFrame", nil, self.selectorFrame, "MinimalScrollBar")
	self.scrollBar:SetPoint("TOPRIGHT", self.scrollBox, "TOPLEFT", 0, ARROW_TOP_BUFFER)
	self.scrollBar:SetPoint("BOTTOMRIGHT", self.scrollBox, "BOTTOMLEFT", 0, -ARROW_TOP_BUFFER)
	self.scrollBar.Back:SetPoint("TOP", self.scrollBox, "TOP", 0, ARROW_TOP_BUFFER)
	self.scrollBar.Forward:SetPoint("BOTTOM", self.scrollBox, "BOTTOM", 0, -ARROW_TOP_BUFFER)

	self.scrollBox:GetScrollTarget():HookScript("OnUpdate", function()
		self:UpdateDragScroll()
	end)

	-- Final hookup
	ScrollUtil.InitScrollBoxListWithScrollBar(
		self.scrollBox,
		self.scrollBar,
		self.scrollView
	)

	self.editInfo = CreateFrame("Button", nil, self, "UIPanelInfoButton")
	self.editInfo:SetPoint("TOPRIGHT", EpsilonMapFeaturePicker, "TOPRIGHT", -100, -3)
	self.editInfo:SetScale(UIParent:GetScale())
	self.editInfo:SetIgnoreParentScale(true)
	self.editInfo:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT", -16, -4)
		GameTooltip_SetTitle(GameTooltip, "Feature Placement", NORMAL_FONT_COLOR)
		GameTooltip_AddHighlightLine(GameTooltip, "Drag a feature onto the map to place it.", false)
		GameTooltip_AddHighlightLine(GameTooltip, " ")
		GameTooltip_AddHighlightLine(GameTooltip, "Placed features start with a default scale and layer. Change the layer by selecting it on the map and using the layer arrows, or right-clicking it in the sidebar.")
		GameTooltip:Show();
	end)
	self.editInfo:SetScript("OnLeave", GameTooltip_Hide)


	self.CategorySelectionBehaviorRegistry = ScrollUtil.AddSelectionBehavior(self.scrollBox, nil)
	-- call root.CategorySelectionBehaviorRegistry:RegisterCallback("OnSelectionChanged", func, owner, ...)
	-- add selection by using root.CategorySelectionBehaviorRegistry:SetSelectedElementData(elementData)
end

function EpsilonMap_FeaturePickerMixin:BeginDragScroll(startY)
	self.dragScrollActive = true
	self.dragStartY = startY
	self.dragStartOffset = self.scrollBox:GetDerivedScrollOffset()
end

function EpsilonMap_FeaturePickerMixin:EndDragScroll()
	self.dragScrollActive = false
end

function EpsilonMap_FeaturePickerMixin:UpdateDragScroll()
	if not self.dragScrollActive then return end
	if not IsMouseButtonDown("LeftButton") then
		self.dragScrollActive = nil
		return
	end

	local _, cursorY = GetCursorPosition()
	local scale = UIParent:GetEffectiveScale()
	cursorY = cursorY / scale

	local deltaY = self.dragStartY - cursorY

	-- Convert pixels → rows
	local deltaRows = deltaY

	local newOffset = self.dragStartOffset - deltaRows
	newOffset = math.max(0, newOffset)

	self.scrollBox:ScrollToOffset(newOffset, CATEGORY_BUTTON_EXTENT, 0)
end

function EpsilonMap_FeaturePickerMixin:SetCategories()
	self:InitCategoryScrollBox()

	self.dataProvider:Flush()

	local categories = MapTextureManager:GetCategories()
	local catOrder   = MapTextureManager:GetCategoriesList()

	for _, catID in ipairs(catOrder) do
		self.dataProvider:Insert({
			catID   = catID,
			catData = categories[catID],
		})
	end

	-- Default selection
	if catOrder[1] then
		definitions = MapTextureManager:GetDefinitionsInCategory(catOrder[1])
		selectedCat = catOrder[1]
		self.CategorySelectionBehaviorRegistry:SelectElementData(self.dataProvider:Find(1))
	end
end

local NUM_COLUMNS = 3
local NUM_ROWS = 6
local CELL_SIZE = 74
local CELL_SPACING = 4

function EpsilonMap_FeaturePickerMixin:SetupFeatureButtons()
	if featureButtons then return end
	featureButtons = {}
	self.Inset.Bg:Hide()

	for y = 0, NUM_ROWS - 1 do
		for x = 0, NUM_COLUMNS - 1 do
			local btn = CreateFrame("Button", nil, self.selectorFrame, "EpsilonMapFeaturePickerButton");
			local offsetX = (CELL_SIZE * x) + (x > 0 and CELL_SPACING * x or 0) + 4
			local offsetY = ((-CELL_SIZE * y) - (y > 0 and CELL_SPACING * y or 0)) - 4
			btn:SetPoint("TOPLEFT", self.Inset, offsetX, offsetY);
			btn:RegisterForDrag("LeftButton")
			btn:SetSize(CELL_SIZE, CELL_SIZE);

			table.insert(featureButtons, btn);
			btn.pickerIndex = #featureButtons;
		end
	end
end

function EpsilonMap_FeaturePickerMixin:RefreshFeatureButtons(resetScroll)
	if not featureButtons then self:SetupFeatureButtons() end
	for _, v in ipairs(featureButtons) do
		v:Refresh()
	end

	local scrollSize = math.max(#definitions - (NUM_COLUMNS * NUM_ROWS), 0)
	self.selectorFrame.scroller:SetMinMaxValues(0, scrollSize)

	if resetScroll then
		self.selectorFrame.scroller:SetValue(0)
	end
end

function EpsilonMap_FeaturePickerMixin:OnLoad()
	ButtonFrameTemplate_HidePortrait(self)
	NineSliceUtil.ApplyLayoutByName(self.NineSlice, "EpsilonGoldBorderFrameTemplateNoPortrait")
	EpsilonLib.Utils.NineSlice.SetBackgroundAsViewport(self, self.Bg)

	local titleBgColor = self:CreateTexture(nil, "BACKGROUND")
	titleBgColor:SetPoint("TOPLEFT", self.TitleBg)
	titleBgColor:SetPoint("BOTTOMRIGHT", self.TitleBg)
	titleBgColor:SetColorTexture(0.184, 0.29, 0.0, 1)

	self.TitleText:SetText("Features");

	self.Inset:SetPoint("TOPLEFT", 4 + 20 + 18, -60)
	self.Inset:SetPoint("BOTTOMRIGHT", -6, 4)

	self:SetClampedToScreen(true);

	self:SetupFeatureButtons()
	self:SetCategories()

	self.search.Instructions:SetText("Search (space/comma separated)")
	self.search.currentSearch = nil
	self.search.searchDebounce = C_Timer.NewTimer(0, function() end) -- soft creation
	self.search.UpdateSearch = function()
		self.search.searchDebounce:Cancel()
		self:SetSearchByString(self.search:GetText())
	end

	self.search:HookScript("OnEditFocusLost", self.search.UpdateSearch)
	self.search:HookScript("OnTextChanged", function(editBox, userInput)
		self.search.searchDebounce:Cancel()
		self.search.searchDebounce = C_Timer.NewTimer(userInput and 0.5 or 0, self.search.UpdateSearch)
	end)

	self.searchAll:HookScript("OnClick", function()
		self.search.UpdateSearch()
	end)

	_createMaskPool(self)
end

function EpsilonMap_FeaturePickerMixin:OnShow()
	self:RefreshFeatureButtons()
end
