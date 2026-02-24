-- =========================================================
--  Map Texture Manager - Allows you to add textures to the Map Canvas directly w/o supporting frames (for decorations, etc, that don't need full pin functionality)
-- =========================================================

local addon_name, ns = ...
local EpsilonLib = EpsilonLib


local MTM = {}

MTM.definitions = {} -- Static templates; registered once
MTM.defOrder = {}    -- Order of the definitions; as they are added.
MTM.categories = {}  -- Categories for getting definitions, and their defaults.
MTM.catOrder = {}    -- Order of the categories; as they are added.

MTM.instances = {}   -- Active placed textures
MTM.texPool = nil    -- Internal Texture pool
MTM.maskPool = nil   -- Internal Tex Mask Pool

local layerVis = {}
setmetatable(layerVis, {
	__index = function() return true end
})
MTM.layerVis                     = layerVis

MTM.layerLock                    = {}

MTM.editor                       = {
	enabled = false,
	dragInstance = nil,
	dragOffsetX = 0,
	dragOffsetY = 0,
	frame = nil,
	dirty = false,
	autoSave = true,
}

MTM.highlightPool                = nil
MTM.selected                     = nil
MTM.ui                           = {}

local AUTO_SAVE_IN_SECONDS       = 5
local MAX_AUTO_BACKUPS_PER_PHASE = 5

-- Utils
local ttText                     = EpsilonLib.Utils.Tooltip.ReplaceTags

local LibSerialize               = LibStub("LibSerialize")
local LibDeflate                 = LibStub("LibDeflate")

local function compressAndSerialize(data)
	local serialized = LibSerialize:Serialize(data)
	local compressed = LibDeflate:CompressDeflate(serialized)
	local encoded = LibDeflate:EncodeForPrint(compressed)
	return encoded
end


local function deserializeAndDecompress(data)
	local decoded = LibDeflate:DecodeForPrint(data)
	if not decoded then return nil, "Error: Fail Decode" end
	local decompressed = LibDeflate:DecompressDeflate(decoded)
	if not decompressed then return nil, "Error: Fail DecompressDeflate" end
	local success, data = LibSerialize:Deserialize(decompressed)
	if not success then return success, data end

	return data
end

-- Process dynamic fields
local function resolve(v, ...)
	if type(v) == "function" then
		return v(...)
	else
		return v
	end
end

-- Copy Raw Instance Data - Gives a clean copy with Data Only. Only data here is actually saved.
local function rawCopyInstData(inst)
	local copy = {
		text       = inst.text,              -- the text to use, if provided. IF GIVEN, IT OVERRIDES MOST OF THE OTHER STUFF
		defID      = inst.defID,             -- definition ID
		definition = inst.definition,        -- custom definition
		map        = inst.map,               -- UIMapID
		x          = inst.x,                 -- map x offset
		y          = inst.y,                 -- map y offset
		rot        = inst.rot,               -- rotation
		scale      = inst.scale,             -- scale of the entire instance
		layer      = inst.layer,             -- layer, 1-16 - Effectively translates to: SetDrawLayer("ARTWORK", layer - 9)
		col        = inst.col,               -- color in hex format (RRGGBB) - No Alpha
		alpha      = inst.alpha,             -- transparency (0-1)
		tile       = inst.tile,              -- if it should be treated as a tilable texture.
		flipX      = inst.flipX,             -- if the texture should be flipped horizontally
		flipY      = inst.flipY,             -- if it should be flipped vertically
		dis        = inst.dis,               -- disabled
		lock       = inst.lock,              -- locked from selection
		texture    = nil,                    -- internally used for referencing the actual texture object if the instance is currently spawned
		font       = inst.font,              -- font to use for text instances
	}
	if copy.text then copy.definition = nil end -- clean the fake custom def for text instances
	return copy
end

local defaultInstValues = {
	tile = false,
	layer = 9,
	scale = function() return MTM:GetBestAutoDefaultScale() end,
}

local mapTexturesPath = "Interface\\AddOns\\" .. addon_name .. "\\Assets\\MapTextures\\"
local UITexturePath = "Interface\\AddOns\\" .. addon_name .. "\\Assets\\UI\\"
local t = function(...) return mapTexturesPath .. table.concat({ ... }, "\\") end
local uiT = function(...) return UITexturePath .. table.concat({ ... }, "\\") end
local defaultMask = t("Terrain", "MapTerrain_Mask")

------------------------------------------------------------
-- Utility Accessors
------------------------------------------------------------

local EpsiCanvasFrame = CreateFrame("Frame", nil, WorldMapFrame.ScrollContainer.Child)
WorldMapFrame.ScrollContainer.Child.EpsiCanvasFrame = EpsiCanvasFrame
EpsiCanvasFrame:SetAllPoints()
EpsiCanvasFrame:SetFrameLevel(2008)

local function GetCanvas()
	if EpsiCanvasFrame then return EpsiCanvasFrame end
	return WorldMapFrame and WorldMapFrame.ScrollContainer.Child
end

local function GetScrollContainer()
	return WorldMapFrame and WorldMapFrame.ScrollContainer
end

local addonAssetsPath = "Interface\\AddOns\\" .. addon_name .. "\\Assets\\"
local t = function(p) return addonAssetsPath .. p end

local function iterLines(s)
	if s:sub(-1) ~= "\n" then s = s .. "\n" end

	local g = s:gmatch("(.-)[\r\n]")
	local i = 0

	return function()
		local line = g()
		if line == nil then return nil end
		i = i + 1
		return i, line
	end
end

local function _flipTexHoriz(tex)
	if not tex then return end
	local left, top, _, bottom, right = tex:GetTexCoord()
	tex:SetTexCoord(right, left, top, bottom)
end

local function _flipTexVert(tex)
	if not tex then return end
	local left, top, _, bottom, right = tex:GetTexCoord()
	tex:SetTexCoord(left, right, bottom, top)
end

function MTM:FlipInstHoriz(inst, texOnly)
	if not inst.texture then return end
	_flipTexHoriz(inst.texture)
	if not texOnly then -- save
		inst.flipX = not inst.flipX or nil
		self:MarkEditorDirtyAndRequestSave()
	end
end

function MTM:FlipInstVert(inst, texOnly)
	if not inst.texture then return end
	_flipTexVert(inst.texture)
	if not texOnly then -- save
		inst.flipY = not inst.flipY or nil
		self:MarkEditorDirtyAndRequestSave()
	end
end

local function _reverseIndex(i, max)
	return max - i + 1
end

------------------------------------------------------------
-- Generic Map Utilities
------------------------------------------------------------

-- FogOfWarPinTemplate
-- MapExplorationPinTemplate

local pinLayers = {}
local function _getPinLayerByName(name)
	-- Already have it, just return it
	if pinLayers[name] then return pinLayers[name] end

	-- Try grabbing directly from the pinPools by the template name:
	local pin = WorldMapFrame.pinPools[name] and WorldMapFrame.pinPools[name].GetNextActive and WorldMapFrame.pinPools[name]:GetNextActive()
	if pin then
		pinLayers[name] = pin
		return pin
	end

	-- Manually searching the dataProviders if needed
	for k in pairs(WorldMapFrame.dataProviders) do
		if k.pin and k.pin.pinTemplate and k.pin.pinTemplate == name then
			pinLayers[name] = k.pin
			return k.pin
		end
	end
end

function MTM:SetPinLayerShownByName(name, shown)
	local pin = _getPinLayerByName(name)
	if shown == nil then
		shown = not pin:IsShown()
	end
	pin:SetShown(shown)
	return pin
end

function MTM:HideExplorationLayer()
	self:SetPinLayerShownByName("MapExplorationPinTemplate", false)
end

function MTM:ShowExplorationLayer()
	self:SetPinLayerShownByName("MapExplorationPinTemplate", true)
end

function MTM:ToggleExplorationLayer(shown)
	self:SetPinLayerShownByName("MapExplorationPinTemplate", shown)
end

function MTM:ToggleFogOfWarLayer(shown)
	local pin = self:SetPinLayerShownByName("FogOfWarPinTemplate", shown)
	-- TODO: Add support for forcing a FoW on a map that didn't have one yet.
end

function MTM:HideFogOfWarLayer()
	self:ToggleFogOfWarLayer(false)
end

function MTM:ShowFogOfWarLayer()
	self:ToggleFogOfWarLayer(true)
end

function MTM:GetBestAutoDefaultScale(mapBaseScale)
	if not mapBaseScale then mapBaseScale = WorldMapFrame.ScrollContainer.baseScale end
	if not mapBaseScale or mapBaseScale <= 0 then
		return 1
	end

	-- Derived from good scales on various maps, but using the baseline:
	--   scale = 4.66 when baseScale = ~0.18151
	--   leads to constant ~0.846
	local K = 0.846

	return K / mapBaseScale
end

function MTM:MarkEditorDirtyAndRequestSave()
	self.editor.dirty = true
	self:RequestSave()
end

function MTM:MarkEditorDirty()
	self.editor.dirty = true
end

function MTM:MarkEditorClean()
	self.editor.dirty = false
end

function MTM:IsEditorDirty()
	return self.editor.dirty
end

------------------------------------------------------------
-- Pool Setup
------------------------------------------------------------

local function _SetUXDrawLayer(frame, layer, subLayer, ...)
	if subLayer then
		if subLayer == 0 then
			subLayer = 9
		else
			subLayer = subLayer - 9
		end
	end
	frame:SetDrawLayer(layer, subLayer, ...)

	if frame.subTextures then
		for _, v in ipairs(frame.subTextures) do
			v:SetDrawLayer(layer, subLayer)
		end
	end
end

function MTM:CreateTexturePool()
	if self.texPool then return end -- hard escape
	local canvas = GetCanvas()
	if not canvas then return end

	local function resetter(_, tex)
		if not tex.SetUXDrawLayer then tex.SetUXDrawLayer = _SetUXDrawLayer end

		tex:ClearAllPoints()
		tex:SetTexture(nil)
		tex:SetTexCoord(0, 1, 0, 1)
		tex:SetRotation(0)
		tex:SetVertexColor(1, 1, 1, 1)
		tex:SetAlpha(1)
		tex:SetVertTile(false)
		tex:SetHorizTile(false)
		tex:SetDrawLayer("ARTWORK")

		if tex.subTextures then
			for _, subTex in ipairs(tex.subTextures) do
				self.texPool:Release(subTex)
			end
			table.wipe(tex.subTextures)
			tex.subTextures = nil
		end

		if tex.mask then
			tex:RemoveMaskTexture(tex.mask)
			self.maskPool:Release(tex.mask)
			tex.mask = nil
		end

		tex.__mtm_instance = nil

		tex:Hide()
	end

	self.texPool = CreateTexturePool(canvas, "ARTWORK", 0, nil, resetter)
end

function MTM:CreateMaskPool()
	local canvas = GetCanvas()
	if not canvas then return end

	local function resetter(_, tex)
		tex:ClearAllPoints()
		tex:SetTexture(nil)
		tex:Hide()
	end

	self.maskPool = CreateMaskPool(canvas, nil, nil, nil, resetter)
end

function MTM:CreateHighlightPool()
	local canvas = GetCanvas()
	if not canvas then return end

	local function resetter(_, tex)
		tex:ClearAllPoints()
		tex:SetTexture(nil)
		tex:Hide()
	end

	self.highlightPool = CreateTexturePool(canvas, "OVERLAY", 7, nil, resetter)
end

function MTM:ApplyTextureVisualsToInstance(inst)
	local def = MTM:GetDefinitionOfInstance(inst)
	if not def then return end

	if not inst.texture then return end

	-- Tiling
	local tileMode
	if def.tile then
		tileMode = "REPEAT"
	end

	-- Atlas
	if def.atlas then
		inst.texture:SetAtlas(def.atlas, false, nil, true)
	else -- Texture / TexCoords
		inst.texture:SetTexture(def.file, tileMode, tileMode)

		if def.texCoords then
			inst.texture:SetTexCoord(unpack(def.texCoords))
		else
			inst.texture:SetTexCoord(0, 1, 0, 1)
		end

		if def.tile then
			inst.texture:SetHorizTile(true)
			inst.texture:SetVertTile(true)
		end
	end

	-- Flips
	if inst.flipX then
		self:FlipInstHoriz(inst, true)
	end
	if inst.flipY then
		self:FlipInstVert(inst, true)
	end

	-- Color
	--[[
	if inst.col then -- If color, handle both color & alpha in vertex. Idk.
		local alpha = (("%02X"):format((inst.alpha and inst.alpha or 1) * 255))
		inst.texture:SetAlpha(1)
		inst.texture:SetVertexColor(CreateColorFromHexString(alpha .. inst.col):GetRGBA())
	elseif inst.alpha then -- If only alpha, use only alpha. Might be more performant at scale? TBD.
		inst.texture:SetVertexColor(1, 1, 1, 1)
		inst.texture:SetAlpha(inst.alpha)
	else -- nothing, ensure we're clean.
		inst.texture:SetVertexColor(1, 1, 1, 1)
		inst.texture:SetAlpha(1)
	end
	--]]
	self:UpdateColorOnInst(inst)

	-- Layer
	local layer = self:GetBestValueForInstField(inst, "layer")
	inst.texture:SetUXDrawLayer("ARTWORK", layer)
end

function MTM:_acquireTexture(inst)
	if not self.texPool then
		self:CreateTexturePool()
	end

	if not inst.texture then
		inst.texture = self.texPool:Acquire()
		inst.texture.__mtm_instance = inst
	end
end

function MTM:AcquireTexture(inst)
	if inst.text then -- short-circuit into acquire by text instead
		self:AcquireByTextString(inst)
		return
	end

	local def = MTM:GetDefinitionOfInstance(inst)
	if not def then return error("Failed to Acquire Texture - No Valid Def") end

	MTM:_acquireTexture(inst)

	self:PositionInstance(inst)           -- handles position + rotation + scale
	self:ApplyTextureVisualsToInstance(inst) -- handles texture file + texcoords + drawlayer + vertex color
end

local _textHeight = 20
local _lineSpacing = -4
function MTM:AcquireByTextString(inst)
	if not inst then return end
	local font = inst.font
	local text = inst.text
	if not text then return end

	-- Adjust for Scaling
	local scale = inst.scale or self:GetBestAutoDefaultScale()

	local textHeight = _textHeight * scale
	local lineSpacing = _lineSpacing * scale

	-- This is our master texture that will be used for control & master placement
	MTM:_acquireTexture(inst)
	local mainTexture = inst.texture
	mainTexture.subTextures = mainTexture.subTextures or {}

	text = strtrim(string.upper(text)) -- we only work in caps, and no blank lines / spaces at start/end

	local maxLineWidth = 20
	local totalLineHeight = 20

	local computeCharLayouts = ns.MFD._computeCharLayouts
	local texCharNum = 0
	for lineNum, line in iterLines(text) do -- iter by line
		local widths, totalWidth = computeCharLayouts(line)
		local scaledTotalWidth = totalWidth * scale
		local center = scaledTotalWidth / 2

		totalLineHeight = (lineNum) * (_textHeight + _lineSpacing)
		maxLineWidth = math.max(maxLineWidth, totalWidth)

		for i = 1, #line do -- iter by character
			local charVal = line:byte(i)
			local texPath, texCoords = ns.MFD._getTextureAndCoordsForText(charVal, font)

			if texPath then -- supported character, create it's texture
				texCharNum = texCharNum + 1
				local tex = mainTexture.subTextures[texCharNum] or self.texPool:Acquire()
				tex.__mtm_instance = inst

				tex:SetSize(textHeight, textHeight)
				tex:SetTexture(texPath)
				tex:SetTexCoord(unpack(texCoords))

				if inst.col then -- If color, handle both color & alpha in vertex. Idk.
					local alpha = (("%02X"):format((inst.alpha and inst.alpha or 1) * 255))
					tex:SetAlpha(1)
					tex:SetVertexColor(CreateColorFromHexString(alpha .. inst.col):GetRGBA())
				elseif inst.alpha then -- If only alpha, use only alpha. Might be more performant at scale? TBD.
					tex:SetVertexColor(1, 1, 1, 1)
					tex:SetAlpha(inst.alpha)
				else
					tex:SetVertexColor(1, 1, 1, 1)
					tex:SetAlpha(1)
				end

				-- Positioning
				local w = widths[i].w * scale
				local offset = widths[i].offset * scale

				local xOffset = offset - center + (w / 2)
				local yOffset = -((lineNum - 1) * (textHeight + lineSpacing)) - (10 * scale)

				tex:ClearAllPoints()
				tex:SetPoint("TOP", mainTexture, "TOP", xOffset, yOffset)
				tex:SetUXDrawLayer("ARTWORK", self:GetBestValueForInstField(inst, "layer"))
				tex:Show()

				--[[
				inst.textTextures = inst.textTextures or {}
				tinsert(inst.textTextures, tex)
				--]]
				mainTexture.subTextures[texCharNum] = tex
			end
		end
	end

	inst.definition = { width = maxLineWidth, height = totalLineHeight + 20 }
	self:PositionInstance(inst)
end

------------------------------------------------------------
-- Editor Frame (Background Mouse Click Handler)
------------------------------------------------------------

function MTM:ApplyArrowKeyMove()
	if not self.selected then return end
	local inst = self.selected
	local overlay = self.editor.frame

	if not self:IsInstanceSelectable(inst) then return end -- don't allow editing of unselectable instances

	local step = 1
	if IsShiftKeyDown() then
		step = 5
	elseif IsControlKeyDown() then
		step = 0.25
	end

	-- Mod Scale
	if IsAltKeyDown() then
		step = step / 10
		if overlay.heldKeys.DOWN then
			inst.scale = (inst.scale or MTM:GetBestAutoDefaultScale()) - step
			if inst.scale < 0.01 then inst.scale = 0.01 end
		end
		if overlay.heldKeys.UP then
			inst.scale = (inst.scale or MTM:GetBestAutoDefaultScale()) + step
		end
		if overlay.heldKeys.LEFT then
			inst.rot = (inst.rot or 0) + math.rad(step * 10)
		end
		if overlay.heldKeys.RIGHT then
			inst.rot = (inst.rot or 0) - math.rad(step * 10)
		end
	else -- Mod Position
		if overlay.heldKeys.LEFT then
			inst.x = inst.x - step
		end
		if overlay.heldKeys.RIGHT then
			inst.x = inst.x + step
		end
		if overlay.heldKeys.UP then
			inst.y = inst.y - step
		end
		if overlay.heldKeys.DOWN then
			inst.y = inst.y + step
		end
	end

	self:PositionInstance(inst)
	self:HighlightInstance(inst)
	self:PositionHandles(inst)
	self:MarkEditorDirtyAndRequestSave()
end

function MTM:DisableEditModeBecauseFramesHidden()
	if not MTM.editor.enabled then return end

	MTM:ToggleEditMode(false)
	EpsilonMapSidebarMapFrame:SetShowFeatures(false)
end

function MTM:CreateEditorFrame()
	if self.editor.frame then return end

	local overlay = CreateFrame("Frame", nil, WorldMapFrame.ScrollContainer.Child)
	overlay:SetAllPoints()
	overlay:EnableMouse(true)
	overlay:EnableKeyboard(true)
	overlay:SetPropagateKeyboardInput(true)
	overlay:SetFrameStrata("HIGH")
	overlay:Hide()

	overlay.editLabel = overlay:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	overlay.editLabel:SetIgnoreParentScale(true)
	--overlay.editLabel:SetTextHeight(12)
	overlay.editLabel:SetPoint("TOP", WorldMapFrame.ScrollContainer, "TOP", 0, 0)
	overlay.editLabel:SetText("Canvas Editing Mode Enabled")

	overlay.editInfo = CreateFrame("Button", nil, overlay, "UIPanelInfoButton")
	overlay.editInfo:SetPoint("LEFT", overlay.editLabel, "RIGHT", 4, 0)
	overlay.editInfo:SetScale(UIParent:GetScale())
	overlay.editInfo:SetIgnoreParentScale(true)
	overlay.editInfo:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT", -16, -4)
		--[[
		GameTooltip_SetTitle(GameTooltip, "Edit Mode Controls", NORMAL_FONT_COLOR)
		GameTooltip_AddHighlightLine(GameTooltip, "- Hold Shift to Navigate (Drag/Right-Click)", false)
		GameTooltip_AddHighlightLine(GameTooltip, "- Click to select a feature (or select from the sidebar)")
		GameTooltip_AddHighlightLine(GameTooltip, "- Click and drag a feature to move it around (Use Right-Click to move the currently selected feature without triggering selection again)", false)
		GameTooltip_AddHighlightLine(GameTooltip, "- Press/Hold Arrow Keys for fine-positioning (Hold Shift = x5, Ctrl = x0.25)", false)
		GameTooltip_AddHighlightLine(GameTooltip, "- Hold Alt + Arrow Key Up/Down to adjust scale (Shift = x5, Ctrl = x0.25)", false)
		GameTooltip_AddHighlightLine(GameTooltip, "- Hold Alt + Arrow Key Left/Right to adjust rotation (Shift = x5, Ctrl = x0.25)", false)
		GameTooltip_AddHighlightLine(GameTooltip, "- Press Delete/Backspace to delete selected feature.")
		--]]

		GameTooltip_SetTitle(GameTooltip, "Edit Mode Controls", NORMAL_FONT_COLOR)
		GameTooltip_AddHighlightLine(GameTooltip, ttText "{shift}+{left-click}{right-click}: Navigate Map (Pan & Back)", false)
		GameTooltip_AddHighlightLine(GameTooltip, ttText "{left-click}: Select a feature (or select from the sidebar)", false)
		GameTooltip_AddHighlightLine(GameTooltip, ttText "{left-click}+ Drag: Select & Move Feature", false)
		GameTooltip_AddHighlightLine(GameTooltip, ttText "{right-click}+ Drag: Move current selected feature", false)
		GameTooltip_AddHighlightLine(GameTooltip, ttText "{arrow-keys}: Fine movement ({shift} = x5, {ctrl} = x0.25)", false)
		GameTooltip_AddHighlightLine(GameTooltip, ttText "{alt}+{up-arrow}{down-arrow}: Scale ({shift} = x5, {ctrl} = x0.25)", false)
		GameTooltip_AddHighlightLine(GameTooltip, ttText "{alt}+{left-arrow}{right-arrow}: Rotate ({shift} = x5, {ctrl} = x0.25)", false)
		GameTooltip_AddHighlightLine(GameTooltip, ttText "Delete / Backspace: Remove selected feature", false)

		GameTooltip:Show();
	end)
	overlay.editInfo:SetScript("OnLeave", GameTooltip_Hide)


	local saveIconButton = WorldMapFrame:AddOverlayFrame("IconButtonTemplate", "BUTTON", "TOPRIGHT", WorldMapFrame:GetCanvasContainer(), "TOPRIGHT", (-32 * 3) - 4, -2)
	saveIconButton:SetFrameStrata("HIGH")
	overlay.saveIcon = saveIconButton
	overlay.saveIcon:Hide() -- default hidden

	function saveIconButton:Refresh()
		if MTM.editor.enabled then self:Show() else self:Hide() end
	end

	local savedIcon = uiT("CartographerIconSaved")
	local unsavedIcon = uiT("CartographerIconUnsaved")
	overlay.saveIcon.Icon = overlay.saveIcon:CreateTexture(nil, "OVERLAY")
	overlay.saveIcon.Icon:SetSize(32, 32)
	overlay.saveIcon.Icon:SetPoint("CENTER", -1, 0)
	overlay.saveIcon.Icon:SetTexture(savedIcon)

	overlay.saveIcon.dirty = false
	overlay.saveIcon:SetSize(32, 32)
	overlay.saveIcon:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT", -16, -4)
		GameTooltip_SetTitle(GameTooltip, "Feature " .. (MTM:IsEditorDirty() and "Changes NOT Saved" or "Changes Saved"), NORMAL_FONT_COLOR)
		GameTooltip_AddHighlightLine(GameTooltip, "Left-Click to Save Changes")
		GameTooltip_AddHighlightLine(GameTooltip, "Right-Click to Toggle Auto-Save")
		GameTooltip_AddHighlightLine(GameTooltip, "Auto-Save: " .. (MTM.editor.autoSave and ("|cff00ff00Enabled|r (%ss)"):format(AUTO_SAVE_IN_SECONDS) or "|cffff0000Disabled|r"))
		GameTooltip:Show();
	end)
	overlay.saveIcon:SetScript("OnUpdate", function()
		if MTM.editor.dirty then
			if overlay.saveIcon.dirty then return end -- already dirty, do nothing
			overlay.saveIcon.dirty = true
			overlay.saveIcon.Icon:SetTexture(unsavedIcon)
			if GameTooltip:GetOwner() == overlay.saveIcon then
				overlay.saveIcon:GetScript("OnEnter")(overlay.saveIcon)
			end
		else
			if not overlay.saveIcon.dirty then return end -- already clean, do nothing
			overlay.saveIcon.dirty = false
			overlay.saveIcon.Icon:SetTexture(savedIcon)
			if GameTooltip:GetOwner() == overlay.saveIcon then
				overlay.saveIcon:GetScript("OnEnter")(overlay.saveIcon)
			end
		end
	end)
	overlay.saveIcon:SetScript("OnLeave", GameTooltip_Hide)
	overlay.saveIcon:HookScript("OnClick", function(self, button)
		if button == "RightButton" then
			MTM.editor.autoSave = not MTM.editor.autoSave
			overlay.saveIcon:GetScript("OnEnter")(overlay.saveIcon)
			if MTM.editor.autoSave and MTM:IsEditorDirty() then
				MTM:RequestSave()
			end
		else
			MTM:SaveInstant()
		end
	end)
	overlay.saveIcon:RegisterForClicks("LeftButtonUp", "RightButtonUp")

	local zoomIconButton = WorldMapFrame:AddOverlayFrame("IconButtonTemplate", "BUTTON", "TOPRIGHT", WorldMapFrame:GetCanvasContainer(), "TOPRIGHT", (-32 * 2) - 4, -2)
	zoomIconButton:SetFrameStrata("HIGH")
	overlay.zoomButton = zoomIconButton

	function zoomIconButton:Refresh()
		self:Show()
		--if MTM.editor.enabled then self:Show() else self:Hide() end
	end

	overlay.zoomButton.Icon = overlay.zoomButton:CreateTexture(nil, "OVERLAY")
	overlay.zoomButton.Icon:SetSize(32, 32)
	overlay.zoomButton.Icon:SetPoint("CENTER", -1, 0)
	overlay.zoomButton.Icon:SetTexture(uiT("CartographerIconZoom"))

	overlay.zoomButton:SetSize(32, 32)

	overlay.zoomSlider = CreateFrame("Frame", nil, WorldMapFrame:GetCanvasContainer(), "BackdropTemplate")
	overlay.zoomSlider:SetSize(200, 60)
	overlay.zoomSlider:SetPoint("TOP", overlay.zoomButton, "BOTTOM", 0, -5)
	overlay.zoomSlider:SetBackdrop({
		bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
		edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
		tile = true,
		tileSize = 32,
		edgeSize = 32,
		insets = { left = 11, right = 12, top = 12, bottom = 11 }
	})
	overlay.zoomSlider:Hide()
	overlay.zoomSlider:SetFrameStrata("DIALOG")
	overlay.zoomSlider:SetIgnoreParentScale(true)
	overlay.zoomSlider:SetScale(0.7)

	overlay.zoomSlider.slider = CreateFrame("Slider", nil, overlay.zoomSlider, "OptionsSliderTemplate")
	overlay.zoomSlider.slider:SetPoint("CENTER", 0, -5)
	overlay.zoomSlider.slider:SetWidth(160)
	--overlay.zoomSlider.slider:SetMinMaxValues(0.25, 10)
	--overlay.zoomSlider.slider:SetValue(1)
	--overlay.zoomSlider.slider:SetValueStep(0.25)
	overlay.zoomSlider.slider:SetObeyStepOnDrag(true)

	function overlay.zoomSlider.slider:UpdateZoomValues()
		local minZoom, maxZoom = WorldMapFrame:GetScaleForMinZoom(), WorldMapFrame:GetScaleForMaxZoom()
		self:SetMinMaxValues(minZoom / 4, maxZoom * 4)
		local zoomLevels = WorldMapFrame.ScrollContainer.zoomLevels
		local zoomStep = ((zoomLevels[1] and zoomLevels[2]) and (zoomLevels[2].scale - zoomLevels[1].scale) or ((maxZoom - minZoom) / 4)) / 2
		self:SetValueStep(zoomStep)
		self:SetValue(WorldMapFrame:GetCanvasScale())
	end

	overlay.zoomSlider.slider:HookScript("OnShow", function(self)
		self:UpdateZoomValues()
	end)

	overlay.zoomSlider.label = overlay.zoomSlider:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	overlay.zoomSlider.label:SetPoint("TOP", overlay.zoomSlider.slider, "TOP", 0, 15)
	overlay.zoomSlider.label:SetText("Map Zoom")

	overlay.zoomSlider.valueText = overlay.zoomSlider:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	overlay.zoomSlider.valueText:SetPoint("BOTTOM", overlay.zoomSlider.slider, "BOTTOM", 0, -10)
	overlay.zoomSlider.valueText:SetText("1x")

	overlay.zoomSlider.slider:SetScript("OnValueChanged", function(self, value, userInput)
		overlay.zoomSlider.valueText:SetText(string.format("%.3gx", value))
		if WorldMapFrame.ScrollContainer and userInput then
			WorldMapFrame.ScrollContainer.targetScale = value
		end
	end)

	overlay.zoomButton:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT", -16, -4)
		GameTooltip_SetTitle(GameTooltip, "Map Zoom", NORMAL_FONT_COLOR)
		GameTooltip_AddHighlightLine(GameTooltip, "Click to adjust map zoom level")
		GameTooltip:Show()
	end)
	overlay.zoomButton:SetScript("OnLeave", GameTooltip_Hide)

	overlay.zoomButton:SetScript("OnClick", function(self)
		if overlay.zoomSlider:IsShown() then
			overlay.zoomSlider:Hide()
		else
			overlay.zoomSlider:Show()
		end
	end)

	overlay:SetScript("OnMouseDown", function(_, button)
		--if button ~= "LeftButton" then return end
		if not MTM.editor.enabled then return end

		-- IF a handle is the clicked widget, do nothing.
		local focus = GetMouseFocus()
		if MTM.ui._frames[focus] then return end

		-- normal hit-test selection
		local inst
		if button == "LeftButton" then
			inst = MTM:HitTest()
			MTM:SelectInstance(inst)
		end

		if not inst then inst = self.selected end
		if not MTM:IsInstanceSelectable(inst) then return end -- do not allow editing of unselectable / locked instances

		if inst then
			local cx, cy = MTM:GetCursorCanvasPosition()
			MTM.editor.dragInstance = inst
			MTM.editor.dragOffsetX = cx - inst.x
			MTM.editor.dragOffsetY = cy - inst.y

			inst._origDragX = inst.x
			inst._origDragY = inst.y
		end
	end)

	overlay:SetScript("OnMouseUp", function(_, ...)
		local inst = MTM.editor.dragInstance
		if inst and ((math.abs(inst._origDragX - inst.x) > 0.0001) or
				(math.abs(inst._origDragY - inst.y) > 0.0001)) then
			self:MarkEditorDirtyAndRequestSave()
		end


		MTM.editor.dragInstance = nil
	end)

	-- Arrow Key for fine-tune positioning
	overlay.heldKeys = {}
	overlay.isRepeating = false
	overlay.repeatElapsed = 0
	overlay.initialRepeatDelay = 0.35 -- delay before hold begins
	overlay.repeatDelay = 0.05     -- repeat rate once active
	overlay.repeatActive = false

	local captureKeys = {
		["UP"] = true,
		["DOWN"] = true,
		["LEFT"] = true,
		["RIGHT"] = true,
		["LSHIFT"] = true,
		["RSHIFT"] = true,
		["DELETE"] = true,
		["BACKSPACE"] = true,
		["ESCAPE"] = true,
	}
	overlay:SetScript("OnKeyDown", function(self, key)
		if captureKeys[key] then
			self:SetPropagateKeyboardInput(false)
		else
			self:SetPropagateKeyboardInput(true)
			return
		end

		if key:sub(2) == "SHIFT" then
			self:EnableMouse(false)
			return
		end

		if key == "ESCAPE" then
			if MTM.selected then
				MTM:Deselect()
			else
				MTM:ToggleEditMode(false)
				EpsilonMapSidebarMapFrame:SetShowFeatures(false)
			end
			return
		end

		-- No selection, nothing to do further
		if not MTM.selected then return end
		if not MTM:IsInstanceSelectable(MTM.selected) then return end -- don't allow editing of unselectable / locked instances

		-- DELETE / BACKSPACE removes selected instance
		if key == "DELETE" or key == "BACKSPACE" then
			local inst = MTM.selected

			MTM.selected = nil
			MTM.editor.dragInstance = nil
			MTM.editor.activeTool = nil

			MTM:RemoveInstance(inst)
			MTM:Deselect()
			MTM:MarkEditorDirtyAndRequestSave()

			return -- Exit; don't bother with arrow keys if not relevant
		end

		-- Arrow key handling
		self.heldKeys[key] = true

		-- Prepare repeat timing
		if next(self.heldKeys) and not self.repeatActive then
			MTM:ApplyArrowKeyMove()

			self.repeatElapsed = 0
			self.repeatActive = false
			self.isRepeating = true
		end
	end)
	overlay:SetScript("OnKeyUp", function(self, key)
		if key:sub(2) == "SHIFT" then
			self:EnableMouse(true)
		end

		self.heldKeys[key] = nil

		if not next(self.heldKeys) then
			self.isRepeating = false
			self.repeatActive = false
			self.repeatElapsed = 0
		end
	end)

	local updateDelta = 0
	overlay:SetScript("OnUpdate", function(self, elapsed)
		if not MTM.editor.enabled then
			-- editor disabled, but we're still running? Request a save, then hide
			MTM:SaveInstant()
			overlay:Hide()
			table.wipe(self.heldKeys)
			self.isRepeating = false
			return
		end

		if MTM.editor.activeTool == "rotate" then
			MTM:UpdateRotate()
			return
		end

		if MTM.editor.activeTool == "resize" then
			MTM:UpdateResize()
			return
		end

		-- Arrow Key Held Handling
		if MTM.selected and self.isRepeating then
			self.repeatElapsed = self.repeatElapsed + elapsed

			if not self.repeatActive then
				-- waiting for initial delay
				if self.repeatElapsed >= self.initialRepeatDelay then
					self.repeatActive = true
					self.repeatElapsed = 0
					MTM:ApplyArrowKeyMove()
				end
			else
				-- repeating
				if self.repeatElapsed >= self.repeatDelay then
					self.repeatElapsed = 0
					MTM:ApplyArrowKeyMove()
				end
			end
		end

		-- normal movement only when no tool active
		if MTM.editor.dragInstance then
			local inst = MTM.editor.dragInstance
			local cx, cy = MTM:GetCursorCanvasPosition()
			inst.x = cx - MTM.editor.dragOffsetX
			inst.y = cy - MTM.editor.dragOffsetY

			MTM:PositionInstance(inst)
			MTM:HighlightInstance(inst)
			MTM:PositionHandles(inst)
		end
	end)

	overlay:SetScript("OnHide", function()
		if MTM.editor.autoSave then
			MTM:SaveInstant()
		end

		saveIconButton:Hide()
		--zoomIconButton:Hide()
	end)

	overlay:SetScript("OnShow", function()
		saveIconButton:Show()
		--zoomIconButton:Show()
	end)

	WorldMapFrame:HookScript("OnHide", MTM.DisableEditModeBecauseFramesHidden)

	self.editor.frame = overlay
end

local baseZoomLevel = 1
function WorldMapFrame.ScrollContainer:CreateZoomLevels()
	local layers = C_Map.GetMapArtLayers(self.mapID);
	local widthScale = self:GetWidth() / layers[1].layerWidth;
	local heightScale = self:GetHeight() / layers[1].layerHeight;
	self.baseScale = math.min(widthScale, heightScale);

	local currentScale = 0;
	local MIN_SCALE_DELTA = 0.01; -- zoomLevels must have increasing scales
	self.zoomLevels = {};
	for layerIndex, layerInfo in ipairs(layers) do
		local zoomDeltaPerStep, numZoomLevels;
		local zoomDelta = layerInfo.maxScale - layerInfo.minScale;
		if zoomDelta > 0 then
			-- make multiple zoom levels
			numZoomLevels = 2 + layerInfo.additionalZoomSteps;
			zoomDeltaPerStep = zoomDelta / (numZoomLevels - 1);
		else
			numZoomLevels = 1;
			zoomDeltaPerStep = 1;
		end

		local minScale = layerInfo.minScale
		for zoomLevelIndex = 0, numZoomLevels - 1 + 4 do -- +4 adds 4 extra zoom levels beyond maxScale
			--[[
			-- This method worked but I changed it for some reason I don't remember to just force a zoomLevel at index 0 for another out-step. Idk why again.
			if zoomLevelIndex == baseZoomLevel then
				currentScale = layerInfo.minScale; -- force the "normal" zoom level to be exact
			else
				currentScale = math.max(minScale + zoomDeltaPerStep * zoomLevelIndex, currentScale + MIN_SCALE_DELTA);
			end
			--]]

			currentScale = math.max(minScale + zoomDeltaPerStep * zoomLevelIndex, currentScale + MIN_SCALE_DELTA);
			local desiredScale = currentScale * self.baseScale;
			if desiredScale == 0 then
				desiredScale = 1;
			end

			table.insert(self.zoomLevels, { scale = desiredScale, layerIndex = layerIndex })
		end

		self.zoomLevels[0] = { scale = self.zoomLevels[1].scale / 1.40, layerIndex = layerIndex }
	end
end

function WorldMapFrame.ScrollContainer:ZoomIn()
	local nextZoomOutScale, nextZoomInScale = self:GetCurrentZoomRange();

	local beyondNormal = false
	if nextZoomInScale < self.zoomLevels[baseZoomLevel].scale then
		beyondNormal = true
	end

	if nextZoomInScale > self:GetCanvasScale() then
		if self:ShouldZoomInstantly() then
			self:InstantPanAndZoom(nextZoomInScale, self.targetScrollX, self.targetScrollY);
			if beyondNormal then
				self.currentScrollX = 0.5;
				self.currentScrollY = 0.5;
				self:SetPanTarget(0.5, 0.5);
				self:SetNormalizedHorizontalScroll(0.5);
				self:SetNormalizedVerticalScroll(0.5);
			end
		else
			self:SetZoomTarget(nextZoomInScale);
		end
	end
end

function WorldMapFrame.ScrollContainer:ZoomOut()
	local nextZoomOutScale, nextZoomInScale = self:GetCurrentZoomRange();

	local beyondNormal = false
	if nextZoomOutScale < self.zoomLevels[baseZoomLevel].scale then
		beyondNormal = true
	end

	if nextZoomOutScale < self:GetCanvasScale() then
		if self:ShouldZoomInstantly() then
			self:InstantPanAndZoom(nextZoomOutScale, self.targetScrollX, self.targetScrollY);
			if beyondNormal then
				self.currentScrollX = 0.5;
				self.currentScrollY = 0.5;
				self:SetPanTarget(0.5, 0.5);
				self:SetNormalizedHorizontalScroll(0.5);
				self:SetNormalizedVerticalScroll(0.5);
			end
		else
			self:SetZoomTarget(nextZoomOutScale);
			self:SetPanTarget(0.5, 0.5);
		end
	end
end

function WorldMapFrame.ScrollContainer:GetScaleForMinZoom()
	return self.zoomLevels[0].scale;
end

function WorldMapFrame.ScrollContainer:GetZoomLevelIndexForScale(scale)
	local bestIndex = 0;
	--for i, zoomLevel in ipairs(self.zoomLevels) do
	for i = 0, #self.zoomLevels do
		local zoomLevel = self.zoomLevels[i];
		if scale >= zoomLevel.scale then
			bestIndex = i;
		else
			break;
		end
	end
	return bestIndex;
end

if baseZoomLevel ~= 1 then
	function WorldMapFrame.ScrollContainer:ResetZoom()
		self:InstantPanAndZoom(self.zoomLevels[baseZoomLevel].scale, 0.5, 0.5);
	end
end

function MTM:GetCursorCanvasPosition()
	local container = GetScrollContainer()
	local canvas = GetCanvas()
	if not container or not canvas then return 0, 0 end

	-- Get cursor in UIParent space
	local cx, cy = GetCursorPosition()
	local scale = UIParent:GetEffectiveScale()
	cx, cy = cx / scale, cy / scale

	-- Convert cursor to normalized canvas coords (0–1)
	local nx, ny = container:NormalizeUIPosition(cx, cy)
	if not nx or not ny then return 0, 0 end

	-- Convert normalized to canvas pixels from TOPLEFT
	local width = canvas:GetWidth()
	local height = canvas:GetHeight()

	return nx * width, ny * height
end

function MTM:GetCenterCanvasPosition()
	local container = GetScrollContainer()
	local canvas = GetCanvas()
	if not container or not canvas then return 0, 0 end

	-- Get map container center in UIParent space
	local cx, cy = container:GetCenter()
	local scale = UIParent:GetEffectiveScale()
	cx, cy = cx / scale, cy / scale

	-- Convert center to normalized canvas coords (0–1)
	local nx, ny = container:NormalizeUIPosition(cx, cy)
	if not nx or not ny then return 0, 0 end

	-- Convert normalized coords to canvas pixels from TOPLEFT
	local width = canvas:GetWidth()
	local height = canvas:GetHeight()

	return nx * width, ny * height
end

function MTM:HitTest()
	local cx, cy = self:GetCursorCanvasPosition()
	local canvas = GetCanvas()
	if not canvas then return end

	local closestInst, instDist = nil, math.huge

	for _, inst in ipairs(self.instances) do
		if inst.texture and self:IsInstanceSelectable(inst) and inst.map == WorldMapFrame.mapID then
			local def = MTM:GetDefinitionOfInstance(inst)
			local scale = inst.scale or self:GetBestAutoDefaultScale()
			local w = def.width * scale
			local h = def.height * scale

			local left = inst.x - w / 2
			local right = inst.x + w / 2
			local bottom = inst.y - h / 2
			local top = inst.y + h / 2

			if cx >= left and cx <= right and cy >= bottom and cy <= top then
				local dx = cx - inst.x
				local dy = cy - inst.y
				local dist = math.sqrt(dx * dx + dy * dy)
				if dist < instDist then
					instDist = dist
					closestInst = inst
				end
			end
		end
	end

	return closestInst
end

function MTM:EnableEditMode()
	self.editor.enabled = true
	self:CreateEditorFrame()
	self.editor.frame:Show()
	self.editor.frame:EnableMouse(true)
	self:RefreshOnNextFrame()
end

function MTM:DisableEditMode()
	self.editor.enabled = false
	if not self.editor.frame then return end
	self.editor.frame:Hide()
	self.editor.dragInstance = nil
	MTM:Deselect()
	self.highlightPool:ReleaseAll()
end

function MTM:ToggleEditMode(enable)
	if enable ~= nil then
		if enable then
			self:EnableEditMode()
		else
			self:DisableEditMode()
		end
		return
	end
	if self.editor.enabled then
		self:DisableEditMode()
	else
		self:EnableEditMode()
	end
end

function MTM:SelectInstance(inst)
	-- Clear previous selection
	if self.selected then
		if self.selected.highlight then
			self.highlightPool:Release(self.selected.highlight)
			self.selected.highlight = nil
		end
		if self.selected.__sidebar then
			if not self.selected.__sidebar:IsMouseOver() then
				self.selected.__sidebar.Highlight:Hide()
			else
				self.selected.__sidebar.Highlight:SetAlpha(1)
			end
		end
	end
	self.highlightPool:ReleaseAll()
	self:HideEditHandles()

	self.selected = inst

	if not inst then return end

	-- sidebar update
	if inst.__sidebar then
		inst.__sidebar.Highlight:SetAlpha(1)
		inst.__sidebar.Highlight:Show()
	end

	self:HighlightInstance(inst)
	self:PositionHandles(inst)
end

function MTM:Deselect()
	if self.selected and self.selected.highlight then
		self.highlightPool:Release(self.selected.highlight)
		self.selected.highlight = nil
	end
	self.highlightPool:ReleaseAll()
	self:HideEditHandles()
	self.selected = nil
end

function _updateTextureColorAndAlpha(tex, col, alpha)
	if not tex then return end

	if col then -- If color, handle both color & alpha in vertex. Idk.
		local a = (("%02X"):format((alpha and alpha or 1) * 255))
		tex:SetAlpha(1)
		tex:SetVertexColor(CreateColorFromHexString(a .. col):GetRGBA())
	elseif alpha then -- If only alpha, use only alpha. Might be more performant at scale? TBD.
		tex:SetVertexColor(1, 1, 1, 1)
		tex:SetAlpha(alpha)
	else -- nothing, ensure we're clean.
		tex:SetVertexColor(1, 1, 1, 1)
		tex:SetAlpha(1)
	end
end

function MTM:UpdateColorOnInst(inst)
	if not inst.texture then return end

	if inst.text then
		-- Text instance, update all sub-textures
		if inst.texture.subTextures then
			for _, tex in pairs(inst.texture.subTextures) do
				_updateTextureColorAndAlpha(tex, inst.col, inst.alpha)
			end
		end
		return
	end

	-- Color
	_updateTextureColorAndAlpha(inst.texture, inst.col, inst.alpha)
end

function MTM:SetInstanceVis(inst, vis)
	inst.dis = vis
end

function MTM:ToggleInstanceVis(inst, toggle)
	if toggle == nil then -- toggle, not direct set
		inst.dis = not inst.dis
	else
		inst.dis = not not toggle -- direct set
	end
	if inst.dis == false then
		inst.dis = nil
	end

	return inst.dis
end

function MTM:SetInstanceLock(inst, vis)
	inst.lock = vis
end

function MTM:ToggleInstanceLock(inst, toggle)
	if toggle == nil then -- toggle, not direct set
		inst.lock = not inst.lock
	else
		inst.lock = not not toggle -- direct set
	end
	if inst.lock == false then
		inst.lock = nil
	end

	return inst.lock
end

---Returns if the instance is selectable or not, based on self-lock & layer lock
---@param inst any instance
---@return boolean?
function MTM:IsInstanceSelectable(inst)
	if not inst then return end
	if inst.lock then return false end
	local layer = self:GetBestValueForInstField(inst, "layer")
	return not MTM:IsLayerLocked(layer)
end

------------------------------------------------------------
-- Modifier Handles (On-Map Editors, i.e., size, layer, flip)
------------------------------------------------------------

function MTM:CreateOrShowColorPicker()
	if self.ui.colorPicker then
		-- just trigger an overwrite of lastCol/lastAlpha
		self.ui.colorPicker.lastCol = self.selected.col
		self.ui.colorPicker.lastAlpha = self.selected.alpha
		return
	end

	local picker = CreateFrame("ColorSelect", "EpsilonMapColorPickerFrame", UIParent, "BackdropTemplate")
	self.ui.colorPicker = picker
	self.ui._frames[picker] = "colorPicker"

	-- Save last colors
	self.ui.colorPicker.lastCol = self.selected.col
	self.ui.colorPicker.lastAlpha = self.selected.alpha

	picker:SetSize(180, 200)
	picker:SetFrameStrata("DIALOG")
	picker:SetFrameLevel(100)
	picker:EnableMouse(true)
	picker:Hide()

	picker:SetBackdrop({
		bgFile = "Interface/Buttons/WHITE8x8",
		edgeFile = "Interface/Buttons/WHITE8x8",
		edgeSize = 1,
	})
	picker:SetBackdropColor(0, 0, 0, 0.35)
	picker:SetBackdropBorderColor(1, 1, 1, 0.2)

	--picker._position = function() end -- no position

	------------------------------------------------
	-- Wheel (Hue / Sat)
	------------------------------------------------
	picker.wheel = picker:CreateTexture(nil, "ARTWORK")
	picker.wheel:SetSize(110, 110)
	picker.wheel:SetPoint("TOPLEFT", 10, -10)
	picker.wheel:SetTexture("Interface\\ColorPicker\\ColorWheel")

	picker:SetColorWheelTexture(picker.wheel)

	picker.wheelThumb = picker:CreateTexture()
	picker.wheelThumb:SetTexture("Interface/Buttons/UI-ColorPicker-Buttons")
	picker.wheelThumb:SetSize(10, 10)
	picker.wheelThumb:SetTexCoord(0, 0.15625, 0, 0.625)

	picker:SetColorWheelThumbTexture(picker.wheelThumb)

	------------------------------------------------
	-- Value (Brightness)
	------------------------------------------------
	picker.value = picker:CreateTexture(nil, "ARTWORK")
	picker.value:SetSize(16, 110)
	picker.value:SetPoint("LEFT", picker.wheel, "RIGHT", 8, 0)
	picker.value:SetTexture("Interface\\ColorPicker\\ColorValue")

	picker:SetColorValueTexture(picker.value)

	picker.valueThumb = picker:CreateTexture(nil, "ARTWORK")
	picker.valueThumb:SetTexture("Interface/Buttons/UI-ColorPicker-Buttons")
	picker.valueThumb:SetSize(24, 14)
	picker.valueThumb:SetTexCoord(0.25, 1.0, 0, 0.875)

	picker:SetColorValueThumbTexture(picker.valueThumb)

	------------------------------------------------
	-- Hex Input
	------------------------------------------------
	local hex = CreateFrame("EditBox", nil, picker, "InputBoxTemplate")
	picker.hex = hex
	hex:SetSize(90, 20)
	hex:SetPoint("TOP", picker.wheel, "BOTTOM", 0, -6)
	hex:SetAutoFocus(false)
	hex:SetTextInsets(6, 6, 0, 0)
	hex:SetMaxLetters(9)

	------------------------------------------------
	-- Alpha Slider
	------------------------------------------------
	local alpha = CreateFrame("Slider", nil, picker, "OptionsSliderTemplate")
	picker.alpha = alpha
	alpha:SetWidth(140)
	alpha:SetPoint("TOPLEFT", hex, "BOTTOMLEFT", 0, -8)
	alpha:SetMinMaxValues(0, 1)
	alpha:SetValueStep(0.01)
	alpha:SetValue(1)
	alpha.Text:SetText("Alpha")
	alpha.Text:ClearAllPoints()
	alpha.Text:SetPoint("TOP", alpha, "BOTTOM")
	alpha.Low:SetText("0")
	alpha.High:SetText("255")

	picker.a = 1

	------------------------------------------------
	-- Reset Button (to white)
	------------------------------------------------
	local reset = CreateFrame("Button", nil, picker)
	picker.reset = reset
	reset:SetSize(20, 20)
	reset:SetPoint("LEFT", hex, "RIGHT", 4, 0)
	reset:SetFrameLevel(picker:GetFrameLevel() + 1)

	reset.tex = reset:CreateTexture(nil, "ARTWORK")
	reset.tex:SetAllPoints()
	reset.tex:SetAtlas("transmog-icon-revert")

	reset:SetHighlightAtlas("transmog-icon-revert")

	reset:SetScript("OnMouseUp", function()
		-- Reset to white, full alpha
		picker:SetColorRGB(1, 1, 1)
		picker.a = 1
		picker.alpha:SetValue(1)

		-- Update output
		local r, g, b = picker:GetColorRGB()
	end)

	------------------------------------------------
	-- Unified Update
	------------------------------------------------
	local function UpdateFromPicker()
		if not self.selected then return end -- can't update if nothing selected
		local r, g, b = picker:GetColorRGB()
		local a = picker.a or 1

		local hexText = string.format(
			"#%02X%02X%02X%02X",
			r * 255, g * 255, b * 255, a * 255
		)
		local hexNoAlpha = string.format(
			"%02X%02X%02X",
			r * 255, g * 255, b * 255
		)
		picker.hex:SetText(hexText)

		self.selected.col = hexNoAlpha
		if hexNoAlpha == "FFFFFF" then
			self.selected.col = nil
		end
		self.selected.alpha = a < 1 and a or nil
		self:UpdateColorOnInst(self.selected)
		--print(("Color: r=%.2f g=%.2f b=%.2f a=%.2f"):format(r, g, b, a))
	end

	------------------------------------------------
	-- Picker Changed
	------------------------------------------------
	picker:SetScript("OnColorSelect", UpdateFromPicker)

	------------------------------------------------
	-- Alpha Changed
	------------------------------------------------
	alpha:SetScript("OnValueChanged", function(_, value)
		picker.a = value < 1 and value or nil
		UpdateFromPicker()
	end)

	------------------------------------------------
	-- Save on Hide
	------------------------------------------------

	picker:SetScript("OnHide", function()
		if not self.selected then return end

		UpdateFromPicker()
		if self.selected.alpha ~= self.ui.colorPicker.lastAlpha or self.selected.col ~= self.ui.colorPicker.lastCol then
			-- alpha or col did not match; save
			MTM:MarkEditorDirtyAndRequestSave()
		end
	end)

	WorldMapFrame:HookScript("OnHide", function()
		picker:Hide()
	end)

	------------------------------------------------
	-- Hex Box
	------------------------------------------------

	hex:SetScript("OnEditFocusLost", function(self)
		local text = self:GetText():gsub("#", "")
		if #text ~= 6 and #text ~= 8 then return end

		local r = tonumber(text:sub(1, 2), 16) / 255
		local g = tonumber(text:sub(3, 4), 16) / 255
		local b = tonumber(text:sub(5, 6), 16) / 255
		local a = picker.a

		if #text == 8 then
			a = tonumber(text:sub(7, 8), 16) / 255
		end

		picker:SetColorRGB(r, g, b)
		picker.a = (a and a < 1) and a or nil
		alpha:SetValue(a)

		UpdateFromPicker()
	end)

	hex:SetScript("OnEnterPressed", function(self)
		self:ClearFocus()
	end)
end

local function setupButtonTextureWithStupidWhiteSpaceFix(btn, texturePath, size, inset)
	btn.texture = btn:CreateTexture(nil, "OVERLAY")
	btn.texture:SetAllPoints()
	btn.texture:SetTexture(texturePath)

	-- fix for stupid whitespace in some of these icons
	local texCoordInset = inset / size
	btn.texture:SetTexCoord(texCoordInset, 1 - texCoordInset, texCoordInset, 1 - texCoordInset)
end

function MTM:CreateHandles()
	local canvas = GetCanvas()
	if not canvas then return end

	local handleAlpha = 0.9
	local handleScale = 0.66

	-- Rotation handle (small circular button)
	local rot = CreateFrame("Button", nil, canvas)
	self.ui.rotationHandle = rot
	rot:SetSize(20, 20)
	rot:SetFrameStrata("DIALOG")
	rot:SetFrameLevel(50)
	rot:Hide()
	rot:SetIgnoreParentScale(true)
	rot:SetScale(handleScale)
	setupButtonTextureWithStupidWhiteSpaceFix(rot, uiT("FeatureEditButtons", (select(random(1, 2), "Rotate", "Rotate2"))), 64, 13)
	--[[
	rot.texture = rot:CreateTexture(nil, "OVERLAY")
	rot.texture:SetAllPoints()
	--rot.texture:SetAtlas("poi-traveldirections-arrow2")
	rot.texture:SetTexture(uiT("FeatureEditButtons", (select(random(1, 2), "Rotate", "Rotate2"))))
	--]]
	rot.texture:SetAlpha(handleAlpha)

	rot._position = function(btn, inst)
		btn:ClearAllPoints()
		btn:SetPoint("BOTTOMLEFT", inst.highlight, "TOPRIGHT")

		local def = MTM:GetDefinitionOfInstance(inst)
		if inst.text or def.tile then -- not supported on text or tile texture
			btn:Hide()
		else
			btn:Show()
		end
	end

	rot:SetScript("OnMouseDown", function()
		if not MTM.selected then return end
		MTM:BeginRotate(MTM.selected)
	end)

	rot:SetScript("OnMouseUp", function()
		MTM:EndRotate()
	end)

	-- Resize handle (square corner drag)
	local resize = CreateFrame("Button", nil, canvas)
	self.ui.resizeHandle = resize
	resize:SetSize(20, 20)
	resize:SetFrameStrata("DIALOG")
	resize:SetFrameLevel(50)
	resize:Hide()
	resize:SetIgnoreParentScale(true)
	resize:SetScale(handleScale)
	setupButtonTextureWithStupidWhiteSpaceFix(resize, uiT("FeatureEditButtons", "Scale"), 64, 9)

	--[[
	resize.texture = resize:CreateTexture(nil, "OVERLAY")
	resize.texture:SetAllPoints()
	--resize.texture:SetTexture("Interface/CURSOR/UI-Cursor-SizeRight")
	resize.texture:SetTexture(uiT("FeatureEditButtons", "Scale"))
	--]]
	resize.texture:SetAlpha(handleAlpha)

	resize._position = function(btn, inst)
		btn:ClearAllPoints()
		btn:SetPoint("TOPLEFT", inst.highlight, "BOTTOMRIGHT")
		btn:Show()
	end

	resize:SetScript("OnMouseDown", function()
		if not MTM.selected then return end
		MTM:BeginResize(MTM.selected)
	end)

	resize:SetScript("OnMouseUp", function()
		MTM:EndResize()
	end)

	-- Tint & Alpha
	local colorBtn = CreateFrame("Button", nil, canvas)
	self.ui.colorHandle = colorBtn
	colorBtn:SetSize(20, 20)
	colorBtn:SetFrameStrata("DIALOG")
	colorBtn:SetFrameLevel(50)
	colorBtn:Hide()
	colorBtn:SetIgnoreParentScale(true)
	colorBtn:SetScale(handleScale)
	setupButtonTextureWithStupidWhiteSpaceFix(colorBtn, uiT("FeatureEditButtons", "ColourWheel"), 64, 13)
	--[[
	colorBtn.texture = colorBtn:CreateTexture(nil, "OVERLAY")
	colorBtn.texture:SetAllPoints()
	--colorBtn.texture:SetAtlas("colorblind-colorwheel")
	colorBtn.texture:SetTexture(uiT("FeatureEditButtons", "ColourWheel"))
	--]]
	colorBtn.texture:SetAlpha(handleAlpha)

	colorBtn._position = function(btn, inst)
		btn:ClearAllPoints()
		btn:SetPoint("TOPRIGHT", inst.highlight, "BOTTOMLEFT")
		btn:Show()
	end

	colorBtn:SetScript("OnMouseUp", function()
		if not MTM.selected then return end

		MTM:CreateOrShowColorPicker()
		local picker = MTM.ui.colorPicker

		picker:ClearAllPoints()
		picker:SetPoint("LEFT", self.selected.highlight, "RIGHT", 6, 0)
		picker:Show()

		-- init color as white or from previous setting
		local r, g, b = 1, 1, 1 -- default
		if self.selected.col then -- override if there is a saved color
			r, g, b = CreateColorFromHexString("FF" .. self.selected.col):GetRGB()
		end
		picker:SetColorRGB(r, g, b, self.selected.alpha or 1)
	end)

	-- Current Layer Label
	local layerLabel = canvas:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	self.ui.layerLabel = layerLabel
	layerLabel:SetIgnoreParentScale(true)
	layerLabel:SetJustifyH("CENTER")
	layerLabel._position = function(_self, inst)
		if not inst then inst = MTM.selected end
		if not inst then return _self:Hide() end

		local layer = MTM:GetBestValueForInstField(inst, "layer")
		_self:ClearAllPoints()
		_self:SetPoint("CENTER", inst.highlight, "RIGHT", 7, 0)
		_self:SetText(_reverseIndex(layer, 16) or 0)
		_self:SetShown(MTM:GetSelected() == inst)
	end

	-- Layer Up handle
	local layerUp = CreateFrame("Button", nil, canvas)
	self.ui.layerUpButton = layerUp
	layerUp:SetSize(20, 20)
	layerUp:SetFrameStrata("DIALOG")
	layerUp:SetFrameLevel(50)
	layerUp:Hide()
	layerUp:SetIgnoreParentScale(true)
	layerUp:SetScale(handleScale)
	setupButtonTextureWithStupidWhiteSpaceFix(layerUp, uiT("FeatureEditButtons", "UpLayer"), 64, 15)

	--[[
	layerUp.texture = layerUp:CreateTexture(nil, "OVERLAY")
	layerUp.texture:SetAllPoints()
	--layerUp.texture:SetAtlas("poi-door-arrow-up")
	layerUp.texture:SetTexture(uiT("FeatureEditButtons", "UpLayer"))
	--]]
	layerUp.texture:SetAlpha(handleAlpha)

	layerUp._position = function(btn, inst)
		btn:ClearAllPoints()
		btn:SetPoint("BOTTOMLEFT", inst.highlight, "RIGHT", 0, 4)
		btn:Show()
	end

	layerUp:SetScript("OnClick", function()
		MTM:MoveForwardLayer(MTM.selected)
	end)

	local layerDown = CreateFrame("Button", nil, canvas)
	self.ui.layerDownButton = layerDown
	layerDown:SetSize(20, 20)
	layerDown:SetFrameStrata("DIALOG")
	layerDown:SetFrameLevel(50)
	layerDown:Hide()
	layerDown:SetIgnoreParentScale(true)
	layerDown:SetScale(handleScale)
	setupButtonTextureWithStupidWhiteSpaceFix(layerDown, uiT("FeatureEditButtons", "UpLayer"), 64, 15)

	--[[
	layerDown.texture = layerDown:CreateTexture(nil, "OVERLAY")
	layerDown.texture:SetAllPoints()
	--layerDown.texture:SetAtlas("poi-door-arrow-down")
	layerDown.texture:SetTexture(uiT("FeatureEditButtons", "UpLayer"))
	--]]
	layerDown.texture:SetRotation(math.rad(180))
	layerDown.texture:SetAlpha(handleAlpha)

	layerDown._position = function(btn, inst)
		btn:ClearAllPoints()
		btn:SetPoint("TOPLEFT", inst.highlight, "RIGHT", 0, -4)
		btn:Show()
	end

	layerDown:SetScript("OnClick", function()
		MTM:MoveBackLayer(MTM.selected)
	end)

	-- Layer Up handle
	local layerFront = CreateFrame("Button", nil, canvas)
	self.ui.layerFrontButton = layerFront
	layerFront:SetSize(20, 20)
	layerFront:SetFrameStrata("DIALOG")
	layerFront:SetFrameLevel(50)
	layerFront:Hide()
	layerFront:SetIgnoreParentScale(true)
	layerFront:SetScale(handleScale)
	setupButtonTextureWithStupidWhiteSpaceFix(layerFront, uiT("FeatureEditButtons", "TopLayer"), 64, 15)

	--[[
	layerFront.texture = layerFront:CreateTexture(nil, "OVERLAY")
	layerFront.texture:SetAllPoints()
	--layerFront.texture:SetAtlas("NPE_ArrowUp")
	layerFront.texture:SetTexture(uiT("FeatureEditButtons", "TopLayer"))
	--]]
	layerFront.texture:SetAlpha(handleAlpha)

	layerFront._position = function(btn, inst)
		btn:ClearAllPoints()
		btn:SetPoint("BOTTOM", self.ui.layerUpButton, "TOP")
		btn:Show()
	end

	layerFront:SetScript("OnClick", function()
		MTM:BringToFront(MTM.selected)
	end)

	local layerBack = CreateFrame("Button", nil, canvas)
	self.ui.layerBackButton = layerBack
	layerBack:SetSize(20, 20)
	layerBack:SetFrameStrata("DIALOG")
	layerBack:SetFrameLevel(50)
	layerBack:Hide()
	layerBack:SetIgnoreParentScale(true)
	layerBack:SetScale(handleScale)
	setupButtonTextureWithStupidWhiteSpaceFix(layerBack, uiT("FeatureEditButtons", "TopLayer"), 64, 15)

	--[[
	layerBack.texture = layerBack:CreateTexture(nil, "OVERLAY")
	layerBack.texture:SetAllPoints()
	--layerBack.texture:SetAtlas("NPE_ArrowDown")
	layerBack.texture:SetTexture(uiT("FeatureEditButtons", "TopLayer"))
	--]]
	layerBack.texture:SetRotation(math.rad(180))
	layerBack.texture:SetAlpha(handleAlpha)

	layerBack._position = function(btn, inst)
		btn:ClearAllPoints()
		btn:SetPoint("TOP", self.ui.layerDownButton, "BOTTOM")
		btn:Show()
	end

	layerBack:SetScript("OnClick", function()
		MTM:SendToBack(MTM.selected)
	end)

	local flipHoriz = CreateFrame("Button", nil, canvas)
	self.ui.flipHorizButton = flipHoriz
	flipHoriz:SetSize(20, 20)
	flipHoriz:SetFrameStrata("DIALOG")
	flipHoriz:SetFrameLevel(50)
	flipHoriz:Hide()
	flipHoriz:SetIgnoreParentScale(true)
	flipHoriz:SetScale(handleScale)
	setupButtonTextureWithStupidWhiteSpaceFix(flipHoriz, uiT("FeatureEditButtons", "Flip"), 64, 15)

	--[[
	flipHoriz.texture = flipHoriz:CreateTexture(nil, "OVERLAY")
	flipHoriz.texture:SetAllPoints()
	--flipHoriz.texture:SetAtlas("orderhalltalents-choice-arrow-large")
	flipHoriz.texture:SetTexture(uiT("FeatureEditButtons", "Flip"))
	--]]
	flipHoriz.texture:SetRotation(math.rad(90))
	flipHoriz.texture:SetAlpha(handleAlpha)

	flipHoriz._position = function(btn, inst)
		btn:ClearAllPoints()
		btn:SetPoint("TOP", inst.highlight, "BOTTOM", 0, 0)

		local def = MTM:GetDefinitionOfInstance(inst)
		if inst.text or def.tile then -- not supported on text or tile texture
			btn:Hide()
		else
			btn:Show()
		end
	end

	flipHoriz:SetScript("OnClick", function()
		MTM:FlipInstHoriz(MTM.selected)
	end)

	local flipVert = CreateFrame("Button", nil, canvas)
	self.ui.flipVertButton = flipVert
	flipVert:SetSize(20, 20)
	flipVert:SetFrameStrata("DIALOG")
	flipVert:SetFrameLevel(50)
	flipVert:Hide()
	flipVert:SetIgnoreParentScale(true)
	flipVert:SetScale(handleScale)
	setupButtonTextureWithStupidWhiteSpaceFix(flipVert, uiT("FeatureEditButtons", "Flip"), 64, 15)
	--[[
	flipVert.texture = flipVert:CreateTexture(nil, "OVERLAY")
	flipVert.texture:SetAllPoints()
	--flipVert.texture:SetAtlas("orderhalltalents-choice-arrow-large")
	flipVert.texture:SetTexture(uiT("FeatureEditButtons", "Flip"))
	--]]
	flipVert.texture:SetAlpha(handleAlpha)

	flipVert._position = function(btn, inst)
		btn:ClearAllPoints()
		btn:SetPoint("RIGHT", inst.highlight, "LEFT", 0, 0)

		local def = MTM:GetDefinitionOfInstance(inst)
		if inst.text or def.tile then -- not supported on text or tile texture
			btn:Hide()
		else
			btn:Show()
		end
	end

	flipVert:SetScript("OnClick", function()
		MTM:FlipInstVert(MTM.selected)
	end)

	local copyButton = CreateFrame("Button", nil, canvas)
	self.ui.copyButton = copyButton
	copyButton:SetSize(20, 20)
	copyButton:SetFrameStrata("DIALOG")
	copyButton:SetFrameLevel(50)
	copyButton:Hide()
	copyButton:SetIgnoreParentScale(true)
	copyButton:SetScale(handleScale)
	setupButtonTextureWithStupidWhiteSpaceFix(copyButton, uiT("FeatureEditButtons", "Copy"), 64, 13)
	--[[
	copyButton.texture = copyButton:CreateTexture(nil, "OVERLAY")
	copyButton.texture:SetAllPoints()
	--copyButton.texture:SetAtlas("auctionhouse-icon-coin-copper")
	copyButton.texture:SetTexture(uiT("FeatureEditButtons", "Copy"))
	--]]
	copyButton.texture:SetAlpha(handleAlpha)
	copyButton._position = function(btn, inst)
		btn:ClearAllPoints()
		btn:SetPoint("BOTTOM", inst.highlight, "TOP")
		btn:Show()
	end

	copyButton:SetScript("OnClick", function()
		MTM:CopyInstance(MTM.selected)
	end)

	local deleteBtn = CreateFrame("Button", nil, canvas)
	self.ui.deleteButton = deleteBtn
	deleteBtn:SetSize(20, 20)
	deleteBtn:SetFrameStrata("DIALOG")
	deleteBtn:SetFrameLevel(50)
	deleteBtn:Hide()
	deleteBtn:SetIgnoreParentScale(true)
	deleteBtn:SetScale(handleScale)
	setupButtonTextureWithStupidWhiteSpaceFix(deleteBtn, uiT("FeatureEditButtons", "Delete"), 64, 14)
	--[[
	deleteBtn.texture = deleteBtn:CreateTexture(nil, "OVERLAY")
	deleteBtn.texture:SetAllPoints()
	--deleteBtn.texture:SetAtlas("transmog-icon-remove")
	deleteBtn.texture:SetTexture(uiT("FeatureEditButtons", "Delete"))
	--]]
	deleteBtn.texture:SetAlpha(handleAlpha)

	deleteBtn._position = function(btn, inst)
		btn:ClearAllPoints()
		btn:SetPoint("BOTTOMRIGHT", inst.highlight, "TOPLEFT")
		btn:Show()
	end

	deleteBtn:SetScript("OnClick", function()
		MTM:RemoveInstance(MTM.selected)
		MTM:Deselect()
	end)

	local _frames = {}
	for k, v in pairs(self.ui) do
		_frames[v] = k
	end
	self.ui._frames = _frames -- track the frames in a inverse table map, so we can check them directly in OnClick
end

function MTM:PositionHandles(inst)
	if not inst then inst = self.selected end
	if not inst or not inst.texture or not self:IsInstanceSelectable(inst) then
		self:HideEditHandles()
		return
	end

	local canvas = GetCanvas()
	if not canvas then return end

	for frame, name in pairs(self.ui._frames) do
		if frame._position then
			frame:_position(inst)
		end
	end
end

function MTM:HideEditHandles()
	for frame, name in pairs(self.ui._frames) do
		frame:Hide()
	end
end

function MTM:BeginRotate(inst)
	if not inst then return end

	self.editor.activeTool = "rotate"
	self.editor.rotateInst = inst

	local cx, cy = self:GetCursorCanvasPosition()

	-- store the starting rotation
	inst._startAngle = inst.rot or 0

	-- compute cursor offset from texture center
	local dx = cx - inst.x
	local dy = cy - inst.y
	inst._rotateStartAngle = math.atan2(dy, dx)
end

function MTM:UpdateRotate()
	local inst = self.editor.rotateInst
	if not inst then return end

	local cx, cy = self:GetCursorCanvasPosition()

	local dx = cx - inst.x
	local dy = cy - inst.y
	local curAngle = math.atan2(dy, dx)

	local delta = curAngle - inst._rotateStartAngle

	-- Negate delta so dragging right rotates clockwise
	inst.rot = inst._startAngle - delta
	inst.texture:SetRotation(inst.rot)

	self:HighlightInstance(inst)
	self:PositionHandles(inst)
end

function MTM:EndRotate()
	self.editor.activeTool = nil
	self.editor.rotateInst = nil
	self:MarkEditorDirtyAndRequestSave()
end

function MTM:BeginResize(inst)
	if not inst then return end

	self.editor.activeTool = "resize"
	self.editor.resizeInst = inst

	local cx, cy = self:GetCursorCanvasPosition()

	-- store starting scale
	inst._startScale = inst.scale or self:GetBestAutoDefaultScale()

	-- distance from center to cursor at start
	local dx = cx - inst.x
	local dy = cy - inst.y
	inst._resizeStartDist = math.sqrt(dx * dx + dy * dy)
end

function MTM:UpdateResize()
	local inst = self.editor.resizeInst
	if not inst then return end

	local cx, cy = self:GetCursorCanvasPosition()

	-- current cursor distance from center
	local dx = cx - inst.x
	local dy = cy - inst.y
	local curDist = math.sqrt(dx * dx + dy * dy)

	if inst._resizeStartDist <= 0 then return end

	-- ratio of new distance to original distance
	local ratio = curDist / inst._resizeStartDist

	-- new scale = original scale * ratio
	inst.scale = math.max(0.05, inst._startScale * ratio)

	if inst.text then
		self:AcquireByTextString(inst)
	else
		self:PositionInstance(inst)
	end
	self:HighlightInstance(inst)
	self:PositionHandles(inst)
end

function MTM:EndResize()
	self.editor.activeTool = nil
	self.editor.resizeInst = nil
	self:MarkEditorDirtyAndRequestSave()
end

function MTM:SetInstanceScale(inst, scale)
	if not inst then return end
	if scale <= 0 then scale = MTM:GetBestAutoDefaultScale() end
	inst.scale = scale

	if inst.texture then
		inst.texture.scale = scale
		self:PositionInstance(inst)

		if self.selected == inst then
			self:HighlightInstance(inst)
			self:PositionHandles(inst)
		end
	end

	self:MarkEditorDirtyAndRequestSave()
end

function MTM:SetInstanceLayer(inst, layer)
	if not inst then return end
	layer = math.min(math.max((layer or 9), 1), 16) -- normalize to valid range
	inst.layer = layer

	if inst.texture then
		inst.texture:SetUXDrawLayer("ARTWORK", inst.layer)
		ns._addon:RefreshSidebar()
	end

	self:MarkEditorDirtyAndRequestSave()

	--[[ Layer Map is offset for player UX
	-8	1
	-7	2
	-6	3
	-5	4
	-4	5
	-3	6
	-2	7
	-1	8
	 0	9
	 1	10
	 2	11
	 3	12
	 4	13
	 5	14
	 6	15
	 7	16
	--]]

	self.ui.layerLabel:_position(inst)
end

function MTM:MoveAllOnLayerToOtherLayer(source, target)
	local instances = MTM:GetFeaturesByLayersForCurrentMap()
	for index, inst in ipairs(instances[source]) do
		-- set the layer
		inst.layer = target

		-- update if currently drawn
		if inst.texture then inst.texture:SetUXDrawLayer("ARTWORK", inst.layer) end
	end

	-- Done with all, now we mark to save & update
	ns._addon:RefreshSidebar()
	self:MarkEditorDirtyAndRequestSave()
	self.ui.layerLabel:_position()
end

function MTM:MoveForwardLayer(inst)
	if not inst or not inst.texture then return end
	local layer = self:GetBestValueForInstField(inst, "layer")
	layer = layer + 1
	self:SetInstanceLayer(inst, layer)
end

function MTM:MoveBackLayer(inst)
	if not inst or not inst.texture then return end
	local layer = self:GetBestValueForInstField(inst, "layer")
	layer = layer - 1
	self:SetInstanceLayer(inst, layer)
end

function MTM:BringToFront(inst)
	if not inst or not inst.texture then return end
	self:SetInstanceLayer(inst, 16)
end

function MTM:SendToBack(inst)
	if not inst or not inst.texture then return end
	self:SetInstanceLayer(inst, 1)
end

------------------------------------------------------------
-- Texture Definitions
------------------------------------------------------------
-- def = {
--   id = "mountainrange",
--   name = "Mountain Range" -- General name; For use in the UI display
--   file = "...",
--   width = 300,
--   height = 300,
--   texCoords = { 0, 1, 0, 1 }, -- optional, if it's a atlas style texture
-- }
--
-- Categories support same fields as def and are used as a 'default for this definition' and for organizing in the UI.
-- These are the base, typical fields you would use:
-- cat = {
--		id = "terrain",
--		name = "Terrain",
--		icon = texture, -- used for UI button
--		layer = 2,		-- default layer features in this cat get added on
-- }
------------------------------------------------------------

local defDefaults = {
	{ key = 'texCoords', val = { 0, 1, 0, 1 } },
	{ key = 'width',     val = 128 },
	{ key = 'height',    val = 128 },
}

function MTM:RegisterDefinition(def, overwrite)
	assert(def and (type(def) == "table"), "RegisterDefinition requires a definition table. See internal documentation.")
	assert(def.id, "RegisterDefinition defTable requires an id")
	if not overwrite then
		assert((not self.definitions[def.id]), "Definition for ID '" .. def.id .. "' already exists. Run with overwrite flag if intentional.")
	end

	if not def.atlas then
		for _, default in ipairs(defDefaults) do
			def[default.key] = def[default.key] or default.val
		end
	end
	def.name = def.name or def.id

	if not def.catID then def.catID = "misc" end -- no non-categorized definitions. Default to misc.
	self:AddDefToCat(def.catID, def)

	self.definitions[def.id] = def
	tinsert(self.defOrder, def.id)

	return self.definitions[def.id]
end

function MTM:GetDefinitions(original)
	local _table = self.definitions
	if original then return table else return CopyTable(_table) end
end

function MTM:GetDefinitionByID(id)
	return self.definitions[id]
end

function MTM:GetDefinitionByIndex(index) -- ONLY EVER USE THIS INTERNALLY AT SESSION RUN TIME, NOT GUARANTEED TO BE STABLE
	return self.definitions[self.defOrder[index]]
end

function MTM:GetDefinitionsOrdered()
	local _table = {}

	for i = 1, #self.defOrder do
		table.insert(_table, self:GetDefinitionByIndex(i))
	end
	return _table
end

function MTM:GetDefinitionOfInstance(inst)
	return ((inst.defID and self.definitions[inst.defID]) or inst.definition) or ns.MFD.InvalidDefinition
end

function MTM:GetSelected()
	return self.selected
end

-- Categories

function MTM:RegisterCategory(data, overwrite)
	assert(data and (type(data) == "table"), "RegisterCategory requires a category data table. See internal documentation.")
	assert(data.id, "RegisterCategory data table requires an id")
	if not overwrite then
		assert((not self.definitions[data.id]), "RegisterCategory for ID '" .. data.id .. "' already exists. Run with overwrite flag if intentional.")
	end

	data.name = data.name or data.id

	self.categories[data.id] = data
	tinsert(self.catOrder, data.id)

	if data.definitions then
		local definitions = data.definitions
		data.definitions = {} -- empty; RegisterDefinition will re-add it after it's sanitized.
		for k, v in ipairs(definitions) do
			v.catID = data.id
			self:RegisterDefinition(v)
		end
	else
		data.definitions = {}
	end

	return self.categories[data.id]
end

function MTM:GetCategories(original) -- default = gives you a copy, so you can't edit.
	local _table = self.categories
	if original then return table else return CopyTable(_table) end
end

function MTM:GetCategory(id) -- Mutable. Used in a mutable state to add definitions into it's list, but could also just use the helper util below..
	return self.categories[id]
end

function MTM:AddDefToCat(id, def)
	if not self.categories[id] then
		error(("Attempted to add defID (%s) to catID (%s); category did not exist."):format(def.id, id))
	end

	table.insert(self.categories[id].definitions, def)
end

function MTM:GetCategoriesList(original) -- default = gives a copy.
	local _table = self.catOrder
	if original then return table else return CopyTable(_table) end
end

function MTM:GetDefinitionsInCategory(categoryID)
	return self.categories[categoryID].definitions
end

function MTM:GetCatForInst(inst)
	local category = (inst.catID and self.categories[inst.catID])
	if not category then
		local definition = (inst.defID and self.definitions[inst.defID]) or inst.definition
		if not definition then return end
		category = self.categories[definition.catID]
	end
	return category
end

------------------------------------------------------------
-- Internal: Position a texture instance
------------------------------------------------------------
function MTM:PositionInstance(inst)
	-- Release if map mismatch
	if WorldMapFrame.mapID ~= inst.map then
		if inst.texture then
			self.texPool:Release(inst.texture)
			inst.texture = nil
		end
		return
	end

	local def = MTM:GetDefinitionOfInstance(inst)
	if not def then return end


	local container = GetScrollContainer()
	local canvas = GetCanvas()
	if not (container and canvas) then return end

	local scale = inst.scale or self:GetBestAutoDefaultScale()
	local texScaleOverride = def.scale or 1

	inst.texture:ClearAllPoints()

	if def.tile then
		inst.texture:SetAllPoints(canvas)
		inst.texture:SetScale(texScaleOverride)
	else
		inst.texture:SetPoint("CENTER", canvas, "TOPLEFT", inst.x, -inst.y)
		inst.texture:SetRotation(inst.rot or 0)
		inst.texture:SetSize(def.width * scale, def.height * scale)
		inst.texture:SetScale(texScaleOverride)
	end
	inst.texture:Show()

	-- Masking
	if def.mask then
		local maskTex = (type(def.mask) == "string" and def.mask) or defaultMask
		inst.texture.mask = inst.texture.mask or self.maskPool:Acquire()
		--inst.texture.mask:SetAllPoints(inst.texture)
		inst.texture.mask:SetPoint("CENTER", canvas, "TOPLEFT", inst.x, -inst.y)
		inst.texture.mask:SetSize(def.width * scale, def.height * scale)
		inst.texture.mask:SetTexture(maskTex, "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
		inst.texture.mask:Show()
		inst.texture:AddMaskTexture(inst.texture.mask)
	elseif inst.texture.mask then
		inst.texture:RemoveMaskTexture(inst.texture.mask)
		self.maskPool:Release(inst.texture.mask)
		inst.texture.mask = nil
	end
end

function MTM:HighlightInstance(inst)
	if not inst.texture then return end -- cannot highlight an inst with no drawn texture

	local highlight = inst.highlight or self.highlightPool:Acquire()
	inst.highlight = highlight

	highlight:SetTexture(t("UI\\CartographerObjectHighlight"))
	highlight:SetBlendMode("ADD")
	highlight:SetAlpha(0.8)

	local def = MTM:GetDefinitionOfInstance(inst)
	if not def then return end
	local canvas = GetCanvas()

	local scale = inst.scale or self:GetBestAutoDefaultScale()

	local w = def.width * scale
	local h = def.height * scale

	-- 10% larger glow
	local glow = 0
	local gw = w * (1 + glow)
	local gh = h * (1 + glow)

	local minX, minY = 80, 80
	gw = math.max(gw, minX)
	gh = math.max(gh, minY)

	inst.highlight:ClearAllPoints()
	--inst.highlight:SetPoint("CENTER", inst.texture, "CENTER")
	inst.highlight:SetPoint("CENTER", canvas, "TOPLEFT", inst.x, -inst.y)
	inst.highlight:SetSize(gw, gh)
	inst.highlight:Show()
end

------------------------------------------------------------
-- Create an instance of a texture definition
------------------------------------------------------------
-- Refer to rawCopyInstData function for full detailed instance params
-- params = {
--
-- -- Primary:
-- 	 text 	-- the text to use, if provided. IF GIVEN, IT OVERRIDES MOST OF THE OTHER STUFF
--		OR
--   defID / definition = defID / <definition ref object>,
--
-- 	-- Required
--   x 		-- x value from topleft,
--   y 		-- y value from topleft,

-- 	-- Optional / Auto if not given:
--   map 	-- UIMapID - If not given, uses the current map directly.
-- 	 layer	-- optional sublayer; 1-16 range. Defaults to 9 if not given.
--   scale 	-- scale -- if not given, automatically uses the 'best scale' from the current map.
--	 rot 	-- rotation in some degree or radian idk.
--	 col 	-- color as a table of { r = 0-255, g = 0-255, b = 0-255, a = 0-255 }
--	 flipX	-- Boolean: flip texture horizontally
--	 flipY	-- Boolean: flip texture vertically
--	 alpha	-- number: [0-1) transparency
--	 tile	-- Boolean: if it should be treated as a tile texture
-- 	 dis 	-- Boolean: disabled (hidden)
--	 lock 	-- Boolean: locked (not selectable)
-- }

---@class FeatureInstance
---@field text? string
---@field defID? string
---@field definition? table
---@field map integer
---@field x number
---@field y number
---@field rot? number
---@field scale? number
---@field layer? integer
---@field col? string"RRGGBB"
---@field alpha? number
---@field tile? boolean
---@field flipX? boolean
---@field flipY? boolean
---@field dis? boolean
---@field lock? boolean
---@field texture? Texture|nil
---@field font? string

------------------------------------------------------------

function MTM:GetBestValueForInstField(inst, field)
	if not field then return end
	local definition = self:GetDefinitionOfInstance(inst)
	local category = self:GetCatForInst(inst)
	local value

	--print(field, inst[field], definition and definition[field], category and category[field], resolve(defaultInstValues[field]))

	if inst[field] ~= nil then                       -- use instance data
		value = inst[field]
	elseif definition and definition[field] ~= nil then -- use definition data
		value = definition[field]
	elseif category and category[field] ~= nil then  -- use category data
		value = category[field]
	else                                             -- use default data
		value = resolve(defaultInstValues[field])
	end

	return value
end

---Add a Feature to our Map!
---@param params table See the Params above for available options
---@param noSave? boolean If true, will not request an auto save. Still marks editor dirty. Call a mark clean after bulk if needed.
---@param doNotRefreshSidebar? boolean If true, will not refresh the sidebar UI after adding. Must manually call a refresh if needed (i.e., after bulk actions)
---@return table|nil FeatureInstance
function MTM:AddFeature(params, noSave, doNotRefreshSidebar)
	local defID

	-- Accept either defID or definition object
	if params.definition then
		defID = params.definition.id
	elseif params.defID then
		defID = params.defID
	elseif params.text then
		-- bypass
	else
		error("AddFeature requires .definition, .defID, or .text")
	end

	local defData = self.definitions[defID]
	if not defData then
		defID = ns.MFD.InvalidDefinition.id
		defData = ns.MFD.InvalidDefinition
	end

	if not params.map then
		params.map = GetScrollContainer():GetMap():GetMapID()
	end
	assert(params.x and params.y, "AddFeature requires x, y")

	local inst = rawCopyInstData(params)
	inst.defID = defID

	table.insert(self.instances, inst)

	if not (params.text or defData) then
		return
		--error("Unknown texture definition: " .. tostring(defID))
	end


	-- Spawn texture if map matches & it's not disabled & the layer is not disabled
	local layer = tonumber(MTM:GetBestValueForInstField(inst, "layer"))
	if (WorldMapFrame.mapID == inst.map) and (not params.dis) and self.layerVis[layer] then
		self:AcquireTexture(inst)
		if not doNotRefreshSidebar then
			ns._addon:RefreshSidebar()
		end
	end

	if not noSave then
		self:MarkEditorDirtyAndRequestSave()
	else
		self:MarkEditorDirty()
	end
	return inst
end

function MTM:CopyInstance(inst)
	if not inst then return end
	return self:AddFeature(rawCopyInstData(inst))
end

-- Add Text Feature Prompt
local selectedFont
local promptData = {
	text = "Enter New Text",
	subText = "Supports multiple lines",
	callback = function(text)
		local x, y = MTM:GetCenterCanvasPosition()
		local data = {
			text = text,
			x = x,
			y = y,
			layer = 14,
			font = selectedFont,
		}
		MTM:SelectInstance(MTM:AddFeature(data))
	end,

	acceptText = "Add to Map",
	maxLetters = 155,
	countInvisibleLetters = true,
	editBoxWidth = nil,
	editJustifyH = "CENTER",
	hideOnEscape = true,
}

-- create a fontpicker dropdown menu using an EasyMenu dropdown
local fontPicker
local function createFontPickerDropdown()
	local fontList = ns.MFD:GetFontList()
	local menuItems = {}

	local btn = CreateFrame("Button", "EpsilonMapFontPickerButton", UIParent, "UIPanelButtonTemplate")

	for _, fontData in ipairs(fontList) do
		table.insert(menuItems, {
			text = fontData.name,
			func = function(self)
				selectedFont = fontData.tag
				btn.Text:SetText(fontData.name)
			end,
		})
	end

	btn:SetSize(200, 22)
	btn.Text:SetText("Select Font")

	LibScrollableDropdown:AttachToButton(btn, menuItems, "TOPLEFT", "BOTTOMLEFT", 0, 0)

	return btn
end

function MTM:PromptForNewTextFeature()
	if not fontPicker then
		fontPicker = createFontPickerDropdown()
		promptData.insertedFrame = fontPicker
	end
	selectedFont = nil
	fontPicker.Text:SetText("Select Font")
	EpsilonLib.Utils.GenericDialogs.CustomMultiLineInput(promptData)
end

------------------------------------------------------------
-- Remove an instance using its reference
------------------------------------------------------------

function MTM:ReleaseInstHighlight(inst, dontDeselect)
	if not inst or not inst.highlight then return end

	self.highlightPool:Release(inst.highlight)
	inst.highlight = nil
	if not dontDeselect and (self.selected == inst) then
		self.selected = nil
	end
end

function MTM:ReleaseInstTexture(inst)
	if not inst or not inst.texture then return end

	self.texPool:Release(inst.texture)
	inst.texture = nil
end

function MTM:RemoveInstance(inst)
	if not inst then return end

	-- Remove the instance from the list
	for i, v in ipairs(self.instances) do
		if v == inst then
			table.remove(self.instances, i)
			MTM:MarkEditorDirtyAndRequestSave()
			break
		end
	end

	self:ReleaseInstHighlight(inst)
	self:ReleaseInstTexture(inst)
	ns._addon:RefreshSidebar()
end

function MTM:RemoveAllInstanceInLayer(layerID)
	if not layerID then error("MTM:RemoveAllInstanceInLayer requires a layerID") end

	local isDirty = false
	for i = #self.instances, 1, -1 do -- reverse iterate
		local inst = self.instances[i]
		local layer = tonumber(MTM:GetBestValueForInstField(inst, "layer"))
		if layer == layerID then
			table.remove(self.instances, i)
			self:ReleaseInstHighlight(inst)
			self:ReleaseInstTexture(inst)
			isDirty = true
		end
	end

	if isDirty then
		self:MarkEditorDirtyAndRequestSave()
		ns._addon:RefreshSidebar()
	end
end

------------------------------------------------------------
-- Clear everything
------------------------------------------------------------
function MTM:Clear()
	self.highlightPool:ReleaseAll()
	self.texPool:ReleaseAll()
	self.selected = nil
	self:HideEditHandles()
	wipe(self.instances)
end

------------------------------------------------------------
-- Layer Visibility Management
------------------------------------------------------------

function MTM:ToggleCustomLayer(layerID, toggle)
	if toggle then -- true translates to nil, so just set nil
		self.layerVis[layerID] = nil
	elseif toggle == false then
		self.layerVis[layerID] = false
	else
		self.layerVis[layerID] = not self.layerVis[layerID]
	end
end

function MTM:SetCustomLayersVis(table)
	if not table then table = {} end
	for i = 1, 16 do
		self:ToggleCustomLayer(i, table[i] ~= false)
	end
end

function MTM:GetCustomLayerVis(layerID)
	return self.layerVis[layerID]
end

function MTM:GetCustomLayersVis()
	return CopyTable(self.layerVis)
end

------------------------------------------------------------
-- Layer Lock Management
------------------------------------------------------------

function MTM:ToggleLayerLocked(layerID, toggle)
	if toggle == nil then
		self.layerLock[layerID] = not self.layerLock[layerID]
	else
		self.layerLock[layerID] = not not toggle
	end
	if self.layerLock[layerID] == false then
		self.layerLock[layerID] = nil
	end
	return self.layerLock[layerID]
end

function MTM:IsLayerLocked(layerID)
	return self.layerLock[layerID]
end

------------------------------------------------------------
-- Refresh visuals on zoom/pan/map changes
------------------------------------------------------------
function MTM:RefreshAll()
	EpsiCanvasFrame:SetFrameLevel(GetScrollContainer():GetMap():GetPinFrameLevelsManager():GetValidFrameLevel("PIN_FRAME_LEVEL_GARRISON_PLOT"))
	for _, inst in ipairs(self.instances) do
		local def = MTM:GetDefinitionOfInstance(inst)
		local layer = tonumber(MTM:GetBestValueForInstField(inst, "layer"))

		if (WorldMapFrame.mapID == inst.map) and (not inst.dis) and self.layerVis[layer] then
			-- map matches & not disabled; ensure texture exists and is positioned
			self:AcquireTexture(inst)
		else
			-- map mismatch or disabled - ensure texture removed if present before
			if inst.texture then
				self.texPool:Release(inst.texture) -- this also releases any subTextures in the resetter.
				inst.texture = nil
			end

			-- clear old highlight if it had it - happens if u toggle or delete from sidebar while selected
			if inst.highlight then
				self.highlightPool:Release(inst.highlight)
				inst.highlight = nil
			end
		end

		if inst == self.selected then
			self:HighlightInstance(inst)
			self:PositionHandles(inst)
		else
			if inst.highlight then
				self.highlightPool:Release(inst.highlight)
				inst.highlight = nil

				self:HideEditHandles()
			end
		end
	end

	if self.editor.frame then
		self.editor.frame.zoomSlider.slider:UpdateZoomValues()
	end

	ns._addon:RefreshSidebar()
end

local isRefreshScheduled = false
function MTM:RefreshOnNextFrame()
	if isRefreshScheduled then return end
	isRefreshScheduled = true
	C_Timer.After(0, function()
		MTM:RefreshAll()
		isRefreshScheduled = false
	end)
end

------------------------------------------------------------
-- Hook events once
------------------------------------------------------------
local hooked = false
function MTM:HookEvents()
	if hooked then return end
	hooked = true

	local SC = WorldMapFrame
	SC:HookScript("OnShow", function()
		MTM:CreateEditorFrame()
	end)

	hooksecurefunc(SC, "OnCanvasScaleChanged", function()
		MTM:RefreshOnNextFrame()
	end)
	hooksecurefunc(SC, "OnCanvasSizeChanged", function()
		MTM:RefreshOnNextFrame()
	end)
	hooksecurefunc(SC, "OnMapChanged", function()
		MTM:RefreshOnNextFrame()
	end)
end

------------------------------------------------------------
-- Save / Load
------------------------------------------------------------

local saveTicker
function MTM:RequestSave()
	if not self.editor.autoSave then return end
	if saveTicker then saveTicker:Cancel() end
	saveTicker = C_Timer.After(AUTO_SAVE_IN_SECONDS, function()
		if not self.editor.autoSave then return end
		if self.editor.dirty then
			ns._addon:SaveFeatures()
		end
	end)
end

function MTM:SaveInstant(force)
	if saveTicker then saveTicker:Cancel() end
	if self.editor.dirty or force then
		ns._addon:SaveFeatures()
	end
end

---Returns the direct access to current feature instances table. Includes direct access in the instances to textures if spawned, and the data here is mutable.
---@return table
function MTM:GetFeatures()
	return self.instances
end

---Same as GetFeatures, but only returns the instances relevant to the current UIMapID
---@return table
function MTM:GetFeaturesForCurrentMap()
	local features = {}
	for _, inst in ipairs(self.instances) do
		if inst.map == WorldMapFrame.mapID then
			table.insert(features, inst)
		end
	end

	return features
end

---Returns a COPY of the current feature instances, trimmed to data only.
---@return table
function MTM:GetFeaturesData()
	local features = {}
	for _, inst in ipairs(self.instances) do
		table.insert(features, rawCopyInstData(inst))
	end
	return features
end

---Gets all current MTM Data for saving
function MTM:GetMTMData()
	local data = {}
	data.features = self:GetFeaturesData()
	data.layers = self:GetCustomLayersVis()

	return data
end

local function getFeaturesByLayer(copyData, mapID)
	local features = {}
	for i = 1, 16 do features[i] = {} end -- pre-populate so it's always a valid array

	for _, inst in ipairs(MTM.instances) do
		if not mapID or (inst.map == mapID) then
			local layer = MTM:GetBestValueForInstField(inst, "layer")

			local dataObj = copyData and rawCopyInstData(inst) or inst
			table.insert(features[layer], dataObj)
		end
	end
	return features
end

---This returns a table with references to the live instances. This includes raw access to the .texture if it's currently spawned on the map, along with transitional data temporarily stored on the object.
---@return table layerTable Array table of the layers (1-16) containing the array of n instances.
function MTM:GetFeaturesByLayers()
	return getFeaturesByLayer()
end

---Same as GetFeaturesByLayers but only for current mapID
---@return table layerTable Array table of the layers (1-16) containing the array of n instances.
function MTM:GetFeaturesByLayersForCurrentMap()
	return getFeaturesByLayer(false, WorldMapFrame.mapID)
end

---This returns a table with a COPY of all current instance info in data-only format.
---@return table layerTable Array table of the layers (1-16) containing the array of n data-only instance copies. These are not live and not mutable, so idk why this is useful anymore anyways.
function MTM:GetFeaturesDataByLayers()
	return getFeaturesByLayer(true)
end

function MTM:AddFeatures(features, noSave, forceRefresh)
	for _, feat in ipairs(features) do
		self:AddFeature(rawCopyInstData(feat), noSave, true)
	end

	if forceRefresh then
		self:RefreshOnNextFrame()
		--ns._addon:RefreshSidebar() -- refresh all calls a sidebar refresh, dummy
	end
end

function MTM:SetFeatures(features, noSave, noRefresh)
	self:Clear()
	local makeAutoBackup

	-- if it's a layer-map, add each layer in order
	if features.layers then
		for i = 1, 16, 1 do
			local layer = features.layers[i]
			if layer then
				self:AddFeatures(layer, noSave)
				makeAutoBackup = true
			end
		end
	elseif #features > 0 then
		-- not layer map, just add all the features
		self:AddFeatures(features, noSave)
		makeAutoBackup = true
	end

	if makeAutoBackup then
		self:CreateBackup()
	end

	self:MarkEditorClean()
	if not noRefresh then
		self:RefreshOnNextFrame()
	end
end

local backups = {}
function MTM:CreateBackup()
	local backup = {}
	local phaseID = tonumber(C_Epsilon.GetPhaseId())
	backup.features = self:GetFeaturesData()
	backup.phaseID = phaseID
	backup.date = date("%Y-%m-%d %H:%M:%S")
	backup.layers = self:GetCustomLayersVis()

	if not backups[phaseID] then backups[phaseID] = {} end
	table.insert(backups[phaseID], 1, backup)

	if #backups[phaseID] > MAX_AUTO_BACKUPS_PER_PHASE then
		table.remove(backups[phaseID])
	end
end

function MTM:GetBackups()
	return backups
end

function MTM:DeleteBackup(indexOrBackup, phaseID)
	if type(indexOrBackup) == "table" then
		if not indexOrBackup.phaseID or not backups[indexOrBackup.phaseID] then return false end
		local numDeleted = tDeleteItem(backups[indexOrBackup.phaseID], indexOrBackup)
		return (numDeleted > 0)
	end

	return (table.remove(phaseID, indexOrBackup) ~= nil)
end

function MTM:RestoreBackup(indexOrBackup, phaseID)
	if type(indexOrBackup) == "table" then
		self:SetFeatures(indexOrBackup.features)
		return true
	end

	local backup = backups[phaseID] and backups[phaseID][indexOrBackup]
	if not backup then return false end
	self:SetFeatures(backup.features)
	self:SetCustomLayersVis(backup.layers)
	return true
end

function MTM:SetBackupTable(table)
	backups = table
end

function MTM:ExportBackup(indexOrBackup, phaseID)
	if not indexOrBackup then indexOrBackup = self:GetFeaturesData() end
	local backup
	if type(indexOrBackup) == "table" then
		backup = indexOrBackup
	else
		backup = backups[phaseID] and backups[phaseID][indexOrBackup]
	end

	backup = compressAndSerialize(backup)
	EpsilonLib.Utils.GenericDialogs.CopyMultiLine(backup)
	-- TODO: serialize the table and show a popup to copy it
end

function MTM:ImportBackup(importString, phaseID, apply)
	-- deserialize the table, then import to the phase backups, then apply if requested
	local importedFeatures = deserializeAndDecompress(importString) -- TODO

	if not phaseID then phaseID = tonumber(C_Epsilon.GetPhaseId()) end

	if not backups[phaseID] then backups[phaseID] = {} end
	table.insert(backups[phaseID], importedFeatures)

	if apply then
		self:SetFeatures(importedFeatures)
	end
end

function MTM:ShowImportDialog()
	EpsilonLib.Utils.GenericDialogs.CustomMultiLineInput({
		text = "Paste Cartographer Import Code",
		subText = "Warning: This will |cffFF0000OVERRIDE / REPLACE|r all current Cartographer Features data in the phase.",
		callback = function(text)
			MTM:ImportBackup(text, C_Epsilon.GetPhaseId(), true)
		end,
		acceptText = "Import & Replace",
		cancelText = "Nevermind!",
		editBoxWidth = GetScreenWidth() * 0.5,
	})
end

------------------------------------------------------------
-- Initialization
------------------------------------------------------------
function MTM:Initialize()
	self:CreateTexturePool()
	self:CreateHighlightPool()
	self:CreateMaskPool()
	self:CreateHandles()
	self:HookEvents()
end

MapTextureManager = MTM
