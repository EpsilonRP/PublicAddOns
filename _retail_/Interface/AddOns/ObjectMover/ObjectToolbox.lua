local ADDON_NAME = ...
---@class ns
local ns = select(2, ...)

local Constants = ns.Constants
local Colors = Constants.colors
local Utils = ns.Utils
local cmd = Utils.cmd           -- Simple Command, no callback
local sendCmd = Utils.sendCmd   -- Full Command with callback
local cmdChain = Utils.cmdChain -- Command Chain
local op_cmd = Utils.op_cmd
local sysMsg = Utils.sysMsg

local ContrastColor = Colors.ORANGE_GOLD
local OM_DARK_RED = Colors.OM_DARK_RED

local AceGUI = LibStub("AceGUI-3.0")

local ASSET_PATH = "Interface/AddOns/" .. ADDON_NAME .. "/media/"

local null = function() end

OBJECT_TOOLBOX_API = {}

local function canEditObject(object)
	if C_Epsilon.IsOfficer() or C_Epsilon.IsOwner() then return true end
	if object and object.isGroup then object = object.leaderObject end
	if C_Epsilon.IsMember() and (object and object.canEdit) then return true end
	return false
end

local baseCommand = "gobject"
local groupCommand = "gobject group"

local function getCommandByContext(isGroup)
	if isGroup then
		return groupCommand
	else
		return baseCommand
	end
end

--#region Main Frame

local f = CreateFrame("Frame", "ObjectToolboxFrame", UIParent, "PortraitFrameTemplateMinimizable")

f:SetSize(200, 540)
f:SetPoint("CENTER")
f:SetMovable(true)
f:EnableMouse(true)
f:SetToplevel(true)
f:SetClampedToScreen(true)
f:SetClampRectInsets(0, 0, 0, 0)
ButtonFrameTemplateMinimizable_HidePortrait(f)
f:SetPortraitShown(false)

function f:Toggle()
	if f:IsShown() then f:Hide() else f:Show() end
end

local maxVisibleHeight = 356.1
function f:UpdateClamp(height)
	if OPMasterTable.Options['alwaysFullClamp'] then -- unimplemented / TODO?
		self:SetClampRectInsets(0, 0, 0, 0)
		return
	end

	if not height then height = self:GetHeight() end
	if height <= maxVisibleHeight then
		-- Allow full frame to stay on screen
		self:SetClampRectInsets(0, 0, 0, 0)
	else
		-- Calculate how much needs to be inset to keep 357px on screen
		local extraHeight = height - maxVisibleHeight
		self:SetClampRectInsets(0, 0, 0, extraHeight)
	end
end

function f:ResizeToFitChildren()
	local farthestBottom = 9999 --[[ Bottom is calculated as 0 = bottom, so we just use a giant number here to create a false top end to start --]]

	local numChildren = self:GetNumChildren()
	local children = { self:GetChildren() }

	-- Iterate through children
	for i = 1, numChildren do
		local child = children[i]
		if child:IsVisible() and not child.BottomEdge then
			local bottom = child:GetBottom()
			if bottom then
				farthestBottom = math.min(farthestBottom, bottom) -- Track the lowest point of the child, or the lowest point so far
			end
		end
	end

	-- Calculate the total height based on the farthest bottom point of the children
	self:SetResizable(true)
	self:StartSizing()
	local totalHeight = self:GetTop() - farthestBottom
	self:UpdateClamp(totalHeight)
	self:SetHeight(totalHeight)
	self:StopMovingOrSizing()
	self:SetResizable(false)
end

f.UpdateSize = f.ResizeToFitChildren -- Alias

NineSliceUtil.ApplyLayoutByName(f.NineSlice, "EpsilonGoldBorderFrameDoubleButtonTemplateNoPortrait")

-- Resizer
local resizeDragger = CreateFrame("BUTTON", nil, f)
resizeDragger:SetSize(16, 16)
resizeDragger:SetPoint("BOTTOMRIGHT", -2, 2)
resizeDragger.BottomEdge = true
resizeDragger:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
resizeDragger:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
resizeDragger:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
resizeDragger:SetScript("OnMouseDown", function(self, button)
	if button == "LeftButton" then
		local parent = self:GetParent()
		self.isScaling = true
	elseif button == "RightButton" then
		local parent = self:GetParent()
		parent:SetScale(1)
	end
end)
resizeDragger:SetScript("OnMouseUp", function(self, button)
	if button == "LeftButton" then
		self.isScaling = false
	end
end)
resizeDragger:HookScript("OnUpdate", function(self)
	if self.isScaling == true then
		local parent = self:GetParent()

		local cx, cy = GetCursorPosition()
		cx = cx / self:GetEffectiveScale() - parent:GetLeft()
		cy = parent:GetHeight() - (cy / self:GetEffectiveScale() - parent:GetBottom())

		local tNewScale = cx / parent:GetWidth()
		local pX, pY = parent:GetLeft(), parent:GetTop() - parent:GetHeight()
		local tx, ty = pX / tNewScale, pY / tNewScale
		local finalScale = parent:GetScale() * tNewScale

		-- limits
		if finalScale <= 0.5 then
			parent:SetScale(0.5)
			return
		elseif finalScale >= 2.0 then
			parent:SetScale(2.0)
			return
		end

		parent:ClearAllPoints()
		parent:SetScale(math.max(0.5, math.min(2.0, finalScale)))
		parent:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", tx, ty)
	end
end)

f.ResizeDragger = resizeDragger



f:HookScript("OnUpdate", function(self)
	if not OPMasterTable.Options["fadePanel"] then
		if self._FadeTimer then
			self._FadeTimer:Cancel()
			self._FadeTimer = nil
		end
		UIFrameFadeIn(self, 0.1, self:GetAlpha(), 1)
	else
		if self:IsMouseOver(6, -6, -6, 6) then
			if self._FadeTimer then
				self._FadeTimer:Cancel(); self._FadeTimer = nil
			end
			if self:GetAlpha() <= 0.3 then
				UIFrameFadeIn(self, 0.2, self:GetAlpha(), 1)
			end
		elseif self:GetAlpha() == 1 then
			if not self._FadeTimer then
				self._FadeTimer = C_Timer.NewTicker(0.75, function()
					UIFrameFadeOut(self, 0.5, self:GetAlpha(), 0.3)
					self._FadeTimer = nil
				end, 1)
			end
		end
	end
end)


-- Create Title Bar Color & Modify Title Area
local titleBgColor = f:CreateTexture(nil, "BACKGROUND")
titleBgColor:SetPoint("TOPLEFT", f.TitleBg, 0, 1)
titleBgColor:SetPoint("BOTTOMRIGHT", f.TitleBg, -20, 0)
titleBgColor:SetColorTexture(CreateColorFromHexString("FF4F1818"):GetRGBA())
f.TitleBgColor = titleBgColor

f.TitleText:SetText("Building Tools")
f.TitleText:SetPoint("LEFT", 15, 0) -- Fix title text position with no portrait

local settingsButton = CreateFrame("Button", nil, f, "SquareIconButtonTemplate")
f.SettingsButton = settingsButton
settingsButton:SetSize(28, 28)
settingsButton:SetPoint("RIGHT", f.CloseButton, "LEFT", 8, 0)
settingsButton:SetIcon("Interface/Buttons/UI-OptionsButton")
-- TODO: Wire up the settings button to open settings panel (Blizz Interface)
settingsButton:SetScript("OnClick", function()
	if not OPNewOptionsFrame:IsShown() then OPNewOptionsFrame:Show() else OPNewOptionsFrame:Hide() end
end)

local dragBar = CreateFrame("Frame", nil, f, "PanelDragBarTemplate")
dragBar:SetPoint("TOPLEFT")
dragBar:SetSize(20, 20)
dragBar:SetPoint("RIGHT", settingsButton, "LEFT", -2, 0)
dragBar:EnableMouse(true)
dragBar:Init(f)
dragBar:HookScript("OnMouseDown", function(self)
	f:SetClampRectInsets(0, 0, 0, 0)
	f:Raise()
end)

local function _OnDragStart(self)
	self.target:StartMoving(true);
	if SetCursor then
		SetCursor("Interface\\CURSOR\\UI-Cursor-Move.blp");
	end
end

local function _OnDragStop(self)
	self.target:StopMovingOrSizing();
	if SetCursor then
		SetCursor(nil);
	end
end
dragBar:SetScript("OnMouseDown", _OnDragStart)
dragBar:SetScript("OnMouseUp", _OnDragStop)

-- Background
EpsilonLib.Utils.NineSlice.SetBackgroundAsViewport(f, f.Bg)

local objectNameLabel = f:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
objectNameLabel:SetTextColor(0.66, 0.66, 0.66, 1) -- Set initial text color to gray
objectNameLabel:SetText("<No Object Selected>")
objectNameLabel:SetFontObject("GameFontWhiteTiny")
objectNameLabel:SetPoint("TOP", 0, -30)
objectNameLabel._SetText = objectNameLabel.SetText
function objectNameLabel:SetText(text)
	if not text or text == "" then
		text = "<No Object Selected>"
	end
	self:_SetText(text)

	local fontName, fontHeight, fontFlags = self:GetFont()
	fontHeight = 10
	self:SetFont(fontName, fontHeight, fontFlags)

	local maxChars = #"buildingtile_jlo_mogu_column_goldtrims_577283"
	while self:GetStringWidth() > f:GetWidth() - 5 do
		fontHeight = fontHeight - 1
		self:SetFont(fontName, fontHeight, fontFlags)
		if fontHeight <= 6 then
			self:_SetText(text:sub(1, maxChars) .. "...") -- Limit to maxChars to prevent infinite loop
			break
		end                                      -- Prevent going too small
	end

	if text == "<No Object Selected>" then
		self:SetTextColor(0.66, 0.66, 0.66, 1) -- Gray color for no object selected
	else
		self:SetTextColor(1, 1, 1, 1)    -- Gold color for valid object name
	end
end

--#endregion

--#region Generic Helper Functions

local basicTtOptions = {
	predicate = EpsilonLib.Utils.Tooltip.GenBasicPredicate(OPMasterTable.Options, "showTooltips"),
	delay = 0.5,
}

local function _eval(t, i)
	if type(t) == "function" then
		return t(i)
	end
	return t
end

local function _tooltip_show(self)
	local tooltipText = _eval(self.tooltip, self) or _eval(self.tooltipText, self)
	local tooltipTitle = _eval(self.tooltipTitle, self)
	if not tooltipText and not tooltipTitle then return end

	GameTooltip:SetOwner(self, "ANCHOR_LEFT")
	local textColor = Colors.game_gold
	if tooltipTitle then
		GameTooltip:AddLine(tooltipTitle, textColor.r, textColor.g, textColor.b, true)
		textColor = Colors.white
	end
	GameTooltip:AddLine(tooltipText, textColor.r, textColor.g, textColor.b, self.tooltipWrap or false)
	GameTooltip:Show()
end

local function genericTooltipOnEnter(self)
	local tooltip = self.tooltip or self.tooltipText
	if not tooltip and not self.tooltipTitle then return end
	if (not self.forceTooltip) and (OPMasterTable.Options["showTooltips"] ~= true) then return end -- Tooltips disabled
	local ttDelay = 0.5

	if type(self.forceTooltip) == "number" then
		ttDelay = self.forceTooltip
	end

	if ttDelay == 0 then
		_tooltip_show(self)
	else
		self.ttTimer = C_Timer.NewTimer(ttDelay, function()
			_tooltip_show(self)
		end)
	end
end

local function genericTooltipOnLeave(self)
	GameTooltip_Hide()
	if self.ttTimer then self.ttTimer:Cancel() end
end

---Attaches tooltip handler scripts to the frame (OnEnter + OnLeave), optionally to overwrite current methods
---@param frame frame
---@param overwrite? boolean
local function addTooltipHandlers(frame, overwrite, force)
	local method = overwrite and "SetScript" or "HookScript"
	frame[method](frame, "OnEnter", genericTooltipOnEnter)
	frame[method](frame, "OnLeave", genericTooltipOnLeave)

	frame.forceTooltip = force
end

local function editBoxNumberValidate(self)
	local text = self:GetText()
	local lastGoodText = self.lastGoodText or ""

	if text:find("%a") then -- remove alpha characters
		text = text:gsub("%a", "")
		self:SetText(text)
	end

	if text == "." then
		-- do nothing, starting with a . is OK
	elseif tonumber(text) then
		self:SetTextColor(255, 255, 255, 1)
		self.lastGoodText = text -- Store the last good text
	elseif text == "" then
		self:SetTextColor(255, 255, 255, 1)
		self.lastGoodText = "" -- Reset last good text if empty
	else
		self:SetTextColor(1, 0, 0, 1)
		self:SetText(lastGoodText) -- Revert to last good text
	end
end

local function round(num, numDecimalPlaces)
	local mult = 10 ^ (numDecimalPlaces or 0)
	return math.floor(num * mult + 0.5) / mult
end

local function roundToStep(value, step)
	if not tonumber(value) then return 0 end
	return math.floor((value + step / 2) / step) * step
end

local function shortest_format(n)
	-- format with 6 significant digits, fixed decimal (not scientific)
	local s = string.format("%.6f", n)

	-- remove trailing zeros
	s = s:gsub("0+$", "")
	-- remove trailing dot if it's now like "20."
	s = s:gsub("%.$", "")

	return s
end

local function colormidpoint(color1, color2)
	-- Calculate the midpoint color between two colors - kinda ugly tho usually, but can be used for gradients
	local r = (color1.r + color2.r) / 2
	local g = (color1.g + color2.g) / 2
	local b = (color1.b + color2.b) / 2

	--print(r, g, b)

	return CreateColor(r, g, b, 1)
end

local function _editcheckbox_OnDisable(self)
	if self.text then self.text:SetTextColor(0.5, 0.5, 0.5) end
end
local function _editcheckbox_OnEnable(self)
	if self.text then self.text:SetTextColor(1, 0.82, 0) end
end

local function _editBox_HandleTabbing(self, tabList)
	local index;
	for i = 1, #tabList do
		if (self == tabList[i]) then
			index = i;
			break;
		end
	end
	if (IsShiftKeyDown()) then
		index = index - 1;
	else
		index = index + 1;
	end
	if (index == 0) then
		index = #tabList;
	elseif (index > #tabList) then
		index = 1;
	end
	local target = tabList[index];
	target:SetFocus();
end

local function _setSliderToIgnoreSetValueWhenDragging(slider)
	local originalSetValue = slider.SetValue
	slider.SetValue = function(self, value, userInput)
		if self:IsDraggingThumb() then
			return -- Ignore SetValue calls while dragging
		end
		originalSetValue(self, value)
	end
end

local frameTypeMap = {
	EditBox = { set = "SetText", get = "GetText", hook = "OnEditFocusLost", },
	CheckButton = { set = "SetChecked", get = "GetChecked", hook = "OnClick", },
	Slider = { set = "SetValue", get = "GetValue", hook = "OnDragStop", },
}
local buttonUpdateMap = {}
local function connectButtonWithSavedOption(button, key)
	table.insert(buttonUpdateMap, { button = button, key = key })
	local buttonType = button:GetObjectType()
	local buttonTypeData = frameTypeMap[buttonType]
	if not buttonTypeData then error(("The frame type %s is not supported in _setButtonToSavedOptionOnLoad yet. ADD SUPPORT!"):format(buttonType)) end
	button:HookScript(buttonTypeData.hook, function(self)
		OPMasterTable.Options[key] = button[buttonTypeData.get](button)
	end)
end

-- Preset Handlers

local presetKeyKeyNameMap = {
	ColorPresetKeys = "Color",
	ParamPresetKeys = "Move Info",
	RotPresetKeys = "Rotation"
}

local illegalPresetNames = {
	["__new"] = true,
	["__close"] = true,
	["__reset"] = true,
}

local function getPresetListAndOrder(key)
	local list = {
		["__new"] = CreateTextureMarkup("interface/paperdollinfoframe/character-plus", 1, 1, 16, 16, 0, 1, 0, 1) .. " Save New Preset"
	}
	local order = { "__new" }
	for k, v in ipairs(OPMasterTable[key] or {}) do
		list[v] = v
		table.insert(order, v)
	end

	return list, order
end

local function _getInfoPresetFunc(key)
	return function() return getPresetListAndOrder(key) end
end

local function savePreset(keyKey, contentKey, realKey, force, data)
	if illegalPresetNames[realKey] then return sysMsg("YOU CAN'T DO THAT! WTF IS WRONG WITH YOU!") end -- this is a reserved name
	local friendlyKeyKeyName = presetKeyKeyNameMap[keyKey] or keyKey
	if not force and OPMasterTable[contentKey][realKey] then
		EpsilonLib.Utils.GenericDialogs.GenericConfirmation(
			("%s already exists as a %s preset.\n\rDo you wish to overwrite it?"):format(ContrastColor:WrapTextInColorCode(realKey), friendlyKeyKeyName),
			function() savePreset(keyKey, contentKey, realKey, true, data) end
		)
	else
		if not OPMasterTable[contentKey][realKey] then
			-- didn't exist, add it
			table.insert(OPMasterTable[keyKey], realKey)
		end
		OPMasterTable[contentKey][realKey] = data
		sysMsg(string.format("Saved New %s Preset: %s", friendlyKeyKeyName, realKey))
	end
end

local function deletePreset(keyKey, contentKey, realKey, force)
	if realKey:find("Reset") then return sysMsg("Cannot delete Reset pre-sets.") end
	if illegalPresetNames[realKey] then return sysMsg("YOU CAN'T DO THAT! WTF IS WRONG WITH YOU!") end -- this is a reserved key
	local friendlyKeyKeyName = presetKeyKeyNameMap[keyKey] or contentKey
	if not OPMasterTable[contentKey][realKey] then return sysMsg(("'%s' does not exist as a preset. (Preset Type: %s)"):format(realKey, friendlyKeyKeyName)) end

	if not force then
		EpsilonLib.Utils.GenericDialogs.GenericConfirmation(("Are you sure you wish to delete %s preset:\n\r%s\n"):format(friendlyKeyKeyName, ContrastColor:WrapTextInColorCode(realKey)), function() deletePreset(keyKey, contentKey, realKey, true) end)
	else
		--table.insert(OPMasterTable[keyKey], realKey)
		tDeleteItem(OPMasterTable[keyKey], realKey)
		OPMasterTable[contentKey][realKey] = nil
		sysMsg(string.format("Deleted %s Preset: %s", friendlyKeyKeyName, realKey))
	end
end

local function _registerPresetDropdown(button, presetType, onSelectCB, saveCollector)
	local presetKeyKey = presetType .. "PresetKeys"
	local presetContentKey = presetType .. "PresetContent"
	button.presetKeyKey = presetKeyKey
	button.presetContentKey = presetContentKey

	button:SetScript("OnClick", function(self)
		EpsilonLib.Utils.Misc.ContextMenu.Toggle(self, _getInfoPresetFunc(presetKeyKey),
			function(key)
				local button = GetMouseButtonClicked()
				if button == "LeftButton" then
					if key == "__close" then return false end
					if key == "__new" then
						EpsilonLib.Utils.GenericDialogs.CustomInput({
							text = "Save New Preset",
							callback = function(text)
								savePreset(presetKeyKey, presetContentKey, text, false, saveCollector())
							end,
							acceptText = "Save",
							maxLetters = 60
						}) -- TODO: FIX THIS NAME IDK (idk what this means now...)
						return false
					end
					local content = OPMasterTable[presetContentKey][key]
					-- ObjectID, Height, Width, Length, Scale -- In our case here, Scale is being modified in how it works to be the Magnitude instead.

					onSelectCB(content)
					f.DistanceControls.SetDimensions(content.Length, content.Width, content.Height, content.Scale)
				elseif button == "RightButton" then
					deletePreset(presetKeyKey, presetContentKey, key)
				end
			end,
			{ enableRightClick = true, hasClose = true }
		)
	end)
end

local function invalidatePresetSelected()
	EpsilonLib.Utils.Misc.ContextMenu.SetValue(nil)
end

-- REMINDERS: RotPresetKeys, RotPresetContent, ParamPresetKeys, ParamPresetContent

--#endregion

--#region Utility & Frame Generation Functions

local numPullouts = 1
local function genPulloutButton(parent, name, width, height)
	--local f = CreateFrame("Frame", "OTPullout" .. numPullouts, parent, "ObjectToolboxPulloutTemplate")
	local f = CreateFrame("Frame", nil, parent, "ObjectToolboxPulloutTemplate")
	EpsilonLib.Utils.Misc.AdjustDevTex(ADDON_NAME, f.Background)
	numPullouts = numPullouts + 1
	f._height = height + 32
	f:SetSize(width, height + 32)
	--f:SetClipsChildren(true)
	f:SetPoint("TOPLEFT") -- needs set for some sizing calcs below first
	f.Label:SetText(name)

	--[[
	f.bg = f:CreateTexture(nil, "BACKGROUND")
	f.bg:SetColorTexture(0, 0.5, 0, 0.5)
	f.bg:SetAllPoints()
	--]]

	f._ContentClipFrame = CreateFrame("Frame", nil, f)
	f._ContentClipFrame:SetClipsChildren(true)
	f._ContentClipFrame:SetPoint("TOPLEFT", 0, -32)
	f._ContentClipFrame:SetPoint("BOTTOMRIGHT")

	f._ContentClipFrame.Content = CreateFrame("Frame", nil, f._ContentClipFrame)
	f.Content = f._ContentClipFrame.Content -- Shortcut
	f.Content:SetFixedFrameLevel(true)
	f:SetFrameLevel(f.Content:GetFrameLevel() + 1)
	local c = f.Content
	c:SetSize(width, height)
	c:SetPoint("TOPLEFT")

	--[[
	c.bg = c:CreateTexture(nil, "BACKGROUND")
	c.bg:SetColorTexture(0, 0, 0.5, 0.25)
	c.bg:SetAllPoints()
	--]]

	local animGroup = c:CreateAnimationGroup()
	local animInSpeed = 0.2
	local slide = animGroup:CreateAnimation("Translation")
	slide:SetDuration(animInSpeed)
	slide:SetSmoothing("OUT")
	slide:SetOffset(0, -height) -- Slides down into place from Y offset -200
	slide:SetOrder(1)

	local fade = animGroup:CreateAnimation("Alpha")
	fade:SetDuration(animInSpeed)
	fade:SetFromAlpha(0)
	fade:SetToAlpha(1)
	fade:SetOrder(1)

	animGroup:SetToFinalAlpha(true)
	animGroup:SetScript("OnPlay", function()
		local offset = c:GetHeight()
		slide:SetOffset(0, -offset)
		c:SetAlpha(0)
		c:SetPoint("TOPLEFT", 0, offset) -- Start offscreen (above)
		c:SetShown(true)
	end)

	animGroup:SetScript("OnFinished", function()
		c:SetAlpha(1)
		c:SetPoint("TOPLEFT") -- ensure it's back in place after
	end)

	c:SetScript("OnShow", function()
		animGroup:Stop()
		animGroup:Play()
	end)

	c:SetScript("OnHide", function()
		animGroup:Stop()
	end)

	function f:Open()
		self:SetHeight(self._height)
		self.Button.ActivateAnim:Stop()
		self.Button.ActivateAnim.isReverse = false
		self.Button.ActivateAnim:Play()
		c:Show()
	end

	function f:Close()
		self:SetHeight(32)
		self.Button.ActivateAnim:Stop()
		self.Button.ActivateAnim.isReverse = true
		self.Button.ActivateAnim:Play(true)
		c:Hide()
	end

	function f:Toggle()
		if c:IsShown() then self:Close() else self:Open() end
	end

	f.Button.ActivateAnim:SetScript("OnPlay", function(self)
		f.Button:RotateTextures(0)
	end)
	f.Button.ActivateAnim:SetScript("OnFinished", function(self)
		if self.isReverse then f.Button:RotateTextures(0) else f.Button:RotateTextures(math.rad(-90)) end
		C_Timer.After(0, function()
			if parent.UpdateSize then parent:UpdateSize() end
		end)
	end)

	f.Button:SetHitRectInsets(f:GetLeft() - f.Button:GetLeft() + 4, 0, 0, 0) -- Autosize Button Hitbox
	f.Button:SetScript("OnClick", function(self)
		f:Toggle()
		if parent.UpdateSize then parent:UpdateSize() end
	end)

	f:Close()
	f:ClearAllPoints()
	return f, c
end

local lastControlGroup = f

---Create a control group frame
---@param parent Frame The parent frame for the control group
---@param name string The label for the control group (used for naming in the parent frame table)
---@param offsetX number The horizontal offset from the parent frame
---@param offsetY number The vertical offset from the parent frame; always has a extra 2 padding
---@param height number The height of the control group frame
---@param label? string Optional label for the control group, displayed at the top
---@param dontUseAsLastControlGroup? boolean If true, this control group will not be used as the last control group for positioning
---@param usePullout? boolean If true, creates a collapsable header for this group
---@return table|Frame MainGroup Main Group - should always use this for anchoring & positioning the button
---@return table|Frame? ContentGroup Content Group - Always add children to this (if pullout)
local function CreateControlGroup(parent, name, offsetX, offsetY, height, label, dontUseAsLastControlGroup, usePullout)
	if not parent then
		error("Parent frame is required for CreateControlGroup")
	end

	local pullout, group
	if usePullout then
		pullout, group = genPulloutButton(parent, label, parent:GetWidth(), height)
		-- group = pullout.Content
		-- so therefor, the ending is groupToUse.Content = group, for future reference.
		pullout:SetPoint("TOP", lastControlGroup, "BOTTOM", offsetX, offsetY)
		pullout.Label:SetTextColor(Colors.ORANGE_GOLD:GetRGB())
	else
		group = CreateFrame("Frame", nil, parent)
		group:SetSize(parent:GetWidth(), height)
		group:SetPoint("TOP", lastControlGroup, "BOTTOM", offsetX, offsetY - 8)

		if label then
			local text = group:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
			text:SetText(label)
			text:SetPoint("TOP", 0, 0)
			group.Label = text
		end
	end

	local groupToUse = pullout or group
	if not dontUseAsLastControlGroup then
		lastControlGroup = groupToUse
	end
	parent[name .. "Controls"] = groupToUse

	return groupToUse, group
end

---Lays out the given buttons evenly spaced from the center of the parent, given spacing & offset
---@param buttons (Button|CheckButton|frame)[]
---@param parent frame
---@param spacing number
---@param yOffset number
local function LayoutCenteredRow(buttons, parent, spacing, yOffset)
	-- Default spacing and Y offset if not provided
	spacing = spacing or 10
	yOffset = yOffset or -10

	-- Calculate total width of all buttons
	local totalWidth = 0
	for _, button in ipairs(buttons) do
		totalWidth = totalWidth + button:GetWidth()
	end

	local numButtons = #buttons
	local totalRowWidth = totalWidth + (numButtons - 1) * spacing
	local parentWidth = parent:GetWidth()

	-- Compute starting X to center the group
	local startX = (parentWidth - totalRowWidth) / 2
	local currentX = startX

	-- Position each button
	for _, button in ipairs(buttons) do
		button:ClearAllPoints()
		button:SetPoint("TOPLEFT", parent, "TOPLEFT", currentX, yOffset)
		currentX = currentX + button:GetWidth() + spacing
	end
end

---Create a set of control group frames that occupy the same space but are controlled by selecting their 'label' at the top of the full group
---@param parent any
---@param name string The name of the control group
---@param offsetX any
---@param offsetY any
---@param height any
---@param tabData table A table containing the tab data, where each entry is a table with 'name' and 'label' keys
local function CreateTabControlGroup(parent, name, offsetX, offsetY, height, tabData)
	local mainGroup = CreateControlGroup(parent, name, offsetX, offsetY, height)
	mainGroup.Tabs = {}
	mainGroup.TabButtons = {}

	function mainGroup:ShowTab(tabName)
		if self.Tabs[tabName] then
			for _, otherTab in pairs(self.Tabs) do
				otherTab:Hide()
				otherTab.Button:SetNormalFontObject("GameFontNormal")
			end
			self.Tabs[tabName]:Show()
			self.Tabs[tabName].Button:SetNormalFontObject("ObjectToolboxFontHighlight")
		else
			print("Tab " .. tabName .. " does not exist.")
		end
	end

	local totalWidth = 0
	for i, tab in ipairs(tabData) do
		local tabButton = CreateFrame("Button", nil, mainGroup, "ObjectToolboxSimpleButtonTemplate")
		tabButton:SetSize(20, 12)
		tabButton:SetText(tab.label)
		DynamicResizeButton_Resize(tabButton)

		totalWidth = totalWidth + tabButton:GetWidth()

		tabButton:SetPoint("TOPLEFT", mainGroup, "TOPLEFT", (i - 1) * 80 + 20, 2) -- default meh positioning, redo it with the LayoutCenteredRow function later
		tabButton.name = tab.name

		tabButton:SetScript("OnClick", function(self)
			mainGroup:ShowTab(self.name)
		end)

		local tabGroup = CreateControlGroup(mainGroup, tab.name, 0, 0, height - 10, nil, true)
		tabGroup:SetPoint("TOP", mainGroup, "TOP", 0, -10) -- Position below the tab buttons
		tabGroup.Button = tabButton                  -- Store the button reference in the tab group for easy access

		mainGroup.Tabs[tab.name] = tabGroup
		table.insert(mainGroup.TabButtons, tabButton)
		tabGroup:Hide() -- Hide all tab groups initially
	end

	local tabButtons = mainGroup.TabButtons

	LayoutCenteredRow(tabButtons, mainGroup, 10, 2) -- Center the tab buttons in the main group

	return mainGroup
end

--- Create a background texture for a control group (neon blue bars at top and bottom with shadow)
---@param group Frame The control group frame to create the background for
---@param padding number Optional padding for the background texture; defaults to 0
---@return table bg table containing the background and overlay textures
local function CreateControlGroupBG(group, padding)
	padding = padding or 0
	local background = group:CreateTexture(nil, "BACKGROUND", nil, 5)
	background:SetAllPoints()
	--background:SetColorTexture(100 / 255, 32 / 255, 33 / 255, 1)
	background:SetAtlas("CreditsScreen-Selected") -- AftLevelup-ToastBG; Garr_BuildingInfoShadow; Rewards-Shadow
	background:SetAlpha(0.5)
	background:SetPoint("TOPLEFT", -20, padding)
	background:SetPoint("BOTTOMRIGHT", 10, -padding)
	background:SetDesaturated(true)
	background:SetVertexColor(OM_DARK_RED:GetRGB())

	local overlay = group:CreateTexture(nil, "BACKGROUND", nil, 6)
	overlay:SetPoint("TOPLEFT", 0, padding)
	overlay:SetPoint("BOTTOMRIGHT", 0, -padding)
	overlay:SetAtlas("search-select") -- Garr_CostBar
	overlay:SetDesaturated(true)
	--overlay:SetVertexColor(0.35, 0.7, 0.85)
	overlay:SetVertexColor(OM_DARK_RED:GetRGB())
	overlay:SetTexCoord(0.075, 0.925, 0, 1)

	return { background = background, overlay = overlay }
end

-- This could be remade to use LayoutCenteredRow, but this is a more specific use case
--- Create a row of icon buttons centered in the parent frame
---@param parent frame
---@param iconTable table A table containing icon information, where each entry is a table with 'name' and 'icon' keys for display
---@param buttonSize number The size of each button; defaults to 32
---@param spacing number The spacing between buttons; defaults to 4
---@return table
local function CreateCenteredIconButtons(parent, iconTable, buttonSize, spacing)
	buttonSize = buttonSize or 32
	spacing = spacing or 4

	local totalWidth = #iconTable * buttonSize + (#iconTable - 1) * spacing
	local startOffsetX = -totalWidth / 2

	local buttons = { _map = {} } -- Initialize buttons table with a map for easy access
	local previousButton

	for i, info in ipairs(iconTable) do
		local b = CreateFrame("Button", nil, parent, "IconButtonTemplate")
		b:SetSize(buttonSize, buttonSize)

		if i == 1 then
			b:SetPoint("LEFT", parent, "CENTER", startOffsetX, 0)
		else
			b:SetPoint("LEFT", previousButton, "RIGHT", spacing, 0)
		end

		--[[
		local border = b:CreateTexture(nil, "OVERLAY")
		border:SetPoint("TOPLEFT", -12, 12)
		border:SetPoint("BOTTOMRIGHT", 12, -12)
		border:SetTexture("interface/buttons/UI-Quickslot2")
		--]]

		local icon = b:CreateTexture(nil, "ARTWORK")
		icon:SetPoint("CENTER", -1, 0)
		icon:SetSize(buttonSize - 2, buttonSize - 2)
		icon:SetTexture(info.icon)
		--icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
		b.Icon = icon

		-- Create a mask for the icon
		--[[
		local mask = b:CreateMaskTexture()
		mask:SetSize(buttonSize, buttonSize)
		mask:SetPoint("CENTER", b, "CENTER", 0, 0)
		mask:SetTexture("interface/common/common-iconmask.blp", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
		icon:AddMaskTexture(mask)
		--]]

		local highlight = b:CreateTexture(nil, "HIGHLIGHT")
		highlight:SetAllPoints()
		highlight:SetTexture("interface/buttons/buttonhilight-square")
		b:SetHighlightTexture(highlight)

		addTooltipHandlers(b, true, 0)
		b.tooltipTitle = info.name
		b.tooltip = info.tooltip

		b:SetScript("OnDisable", function()
			b.Icon:SetDesaturated(true)
		end)
		b:SetScript("OnEnable", function()
			b.Icon:SetDesaturated(false)
		end)

		b:RegisterForClicks("LeftButtonUp", "RightButtonUp")
		if info.func then b:HookScript("OnClick", info.func) end

		buttons._map[info.name] = b -- Store button by name for easy direct access
		buttons[#buttons + 1] = b -- Add button to the array for iteration, but really idk if we need this
		previousButton = b
	end

	return buttons
end

local function CreateSimpleSlider(parent, name, minValue, maxValue, step, initialValue, width, height, label)
	local slider = CreateFrame("Slider", nil, parent, "OptionsSliderTemplate")
	parent[name .. "Slider"] = slider -- Store the slider in the parent frame's table
	slider:SetMinMaxValues(minValue, maxValue)
	slider:SetValueStep(step)
	slider:SetValue(initialValue or minValue)
	slider:SetWidth(width or 200)
	slider:SetHeight(height or 20)
	slider:SetObeyStepOnDrag(true)

	slider:HookScript("OnDisable", function(self)
		slider.Thumb:SetVertexColor(0.5, 0.5, 0.5, 1)
	end)

	slider:HookScript("OnEnable", function(self)
		slider.Thumb:SetVertexColor(1, 1, 1, 1)
	end)

	slider.Low:SetText(tostring(minValue))
	slider.High:SetText(tostring(maxValue))
	slider.Text:SetText(label)

	_setSliderToIgnoreSetValueWhenDragging(slider)

	return slider
end

local function GenRotationSlider(parent, name, label, axis)
	local slider = CreateSimpleSlider(parent, name, 0, 360, 1, 0, 270, 14, label)
	slider:SetValueStep(0.01)

	slider.Text:ClearAllPoints()
	slider.Text:SetPoint("BOTTOMLEFT", slider, "TOPLEFT", 10, 0)

	local labelFormat = axis .. ": %s"
	slider.Label = slider:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	slider.Label:SetPoint("BOTTOMRIGHT", slider, "TOPRIGHT", -10, 0)
	slider.Label:SetText(labelFormat:format(0))

	slider:HookScript("OnDisable", function(self)
		slider.Label:SetTextColor(0.5, 0.5, 0.5, 1)
		slider.High:SetTextColor(0.5, 0.5, 0.5, 1)
		slider.Low:SetTextColor(0.5, 0.5, 0.5, 1)
	end)

	slider:HookScript("OnEnable", function(self)
		slider.Label:SetTextColor(1, 1, 1, 1)
		slider.High:SetTextColor(1, 1, 1, 1)
		slider.Low:SetTextColor(1, 1, 1, 1)
	end)

	slider:HookScript("OnValueChanged", function(self, value, userInput)
		local labelVal = round(value, 6)
		self.Label:SetText(labelFormat:format(labelVal))
		invalidatePresetSelected()

		if userInput then
			-- do rotate here // client side only, full set is on OnDragStop
			local gob = EpsilonLib.GameObject:GetSelected()
			if not gob then
				sysMsg('No Object Selected. Slider should be disabled?')
				return
			end
			gob:Rotate(axis == "X" and value, axis == "Y" and value, axis == "Z" and value, true)
		end
	end)

	slider:HookScript("OnMouseDown", function(self)
		if not self:IsEnabled() then return end
		-- Apply Step
		self:SetValueStep(1)
	end)

	slider:HookScript("OnMouseUp", function(self)
		if not self:IsEnabled() then return end

		-- Remove Harsh Step
		self:SetValueStep(0.01)
		local val = self:GetValue()

		-- do full set here
		local gob = EpsilonLib.GameObject:GetSelected()
		if not gob then
			sysMsg('No Game Object Selected.')
			return
		end
		gob:Rotate(axis == "X" and val, axis == "Y" and val, axis == "Z" and val, false)
	end)

	return slider
end

local colMap = { -- hacky
	Red = "r",
	Green = "g",
	Blue = "b",
}
local function GenColorSlider(parent, color, group)
	local slider = CreateSimpleSlider(parent, color, 0, 100, 5, 100, 200, 14, color .. ":")
	local colorObj = Colors["pastel_" .. color:lower()]
	slider.Text:ClearAllPoints()
	slider.Text:SetPoint("BOTTOMLEFT", slider, "TOPLEFT", 10, 0)
	slider.Text:SetTextColor(colorObj:GetRGBA()) -- Set text color to pastel variant of the color

	slider.Low:Hide()

	slider.High:ClearAllPoints()
	slider.High:SetPoint("BOTTOMRIGHT", slider, "TOPRIGHT", -10, 0)
	slider.High:SetTextColor(colorObj:GetRGBA()) -- Set high text color to pastel variant of the color
	slider.High:SetText("100")
	slider.Label = slider.High

	slider._lastValue = nil


	local function doColor(value)
		slider.Label:SetText(string.format("%d", value))
		-- TODO: Need to smooth out how this interacts with the Color Selector Wheel
		local info = group.GetColorInfo()
		info[colMap[color]] = value
		group.ColorSelect.isUpdating = true
		group.SetColorInfo(info, true)
		group.ColorSelect:SetColorRGB(info.r / 100, info.g / 100, info.b / 100)
		group.ColorSelect.isUpdating = false

		invalidatePresetSelected()
	end

	slider:SetScript("OnValueChanged", function(self, value, userInput)
		if slider._lastValue == value then return end
		if not userInput then return end
		if self._updating then return end
		self._updating = true
		slider._lastValue = value

		-- Rate limit now applied in SetColorInfo
		-- rate limit: only allow running once every 0.1 second
		--local now = GetTime()
		--if slider._lastRun and (now - slider._lastRun) < 0.1 then return end
		--slider._lastRun = now

		doColor(value)
		self._updating = false
	end)
	slider:SetScript("OnMouseDown", function()
		group.ColorSelect.isSelecting = true
	end)
	slider:SetScript("OnMouseUp", function(self)
		slider._lastValue = nil
		--doColor(self:GetValue())
		group.ColorSelect.isSelecting = false
	end)

	return slider
end

---Create radio buttons
---@param parent frame	-- the parent frame
---@param name string -- Name of the radio group basically; adds it as a sub-table on the parent
---@param radioData table -- array style table where each item is a radio with name & optional label
---@param useCheckbox? boolean -- use checkboxes instead of radios
---@param leftText? boolean -- use text anchored to the left
---@return CheckButton[] radios radios array, in order
---@return table<string, CheckButton|UIRadioButtonTemplate> parentTable sub-table added to the parent by the name, with each radio added as a named key inside
local function CreateRadioButtons(parent, name, radioData, useCheckbox, leftText, forceClickOnUncheck)
	local radios = {}

	parent[name] = parent[name] or {} -- use current table or instantiate a new one if needed
	local parentTable = parent[name]

	for i = 1, #radioData do
		local data = radioData[i]
		local callback = data.callback
		local template = useCheckbox and "UICheckButtonTemplate" or "UIRadioButtonTemplate"
		local radio = CreateFrame("CheckButton", nil, parent, template)
		radio.name = data.name

		function radio:SetSelected(enabled)
			self:SetChecked(enabled)
			if useCheckbox then
				-- For checkboxes: allow toggling this one on/off, but always uncheck all others when checked
				if self:GetChecked() then
					for _, checkbox in ipairs(radios) do
						if checkbox ~= self then
							if forceClickOnUncheck and checkbox:GetChecked() then checkbox:Click() end
							checkbox:SetChecked(false)
						end
					end
				end
			else
				-- For radio buttons: always set only this one checked, all others off
				for _, checkbox in ipairs(radios) do
					if checkbox ~= self then if forceClickOnUncheck and checkbox:GetChecked() then checkbox:Click() end end
					checkbox:SetChecked(checkbox == self)
				end
			end
		end

		radio:SetScript("OnClick", function(self, ...)
			self:SetSelected(self:GetChecked())
			invalidatePresetSelected()
			if callback then callback(self, ...) end
		end)

		radio:HookScript("OnDisable", _editcheckbox_OnDisable)
		radio:HookScript("OnEnable", _editcheckbox_OnEnable)

		radio.text:SetText(data.label or data.name)
		local hitWidthOffset = radio.text:GetStringWidth() + 2
		if leftText then
			radio.text:ClearAllPoints()
			radio.text:SetPoint("RIGHT", radio, "LEFT", -1, 0)
			radio:SetHitRectInsets(-hitWidthOffset, 0, 0, 0)
		else
			radio.text:ClearAllPoints()
			radio.text:SetPoint("LEFT", radio, "RIGHT", 1, 0)
			radio:SetHitRectInsets(0, -hitWidthOffset, 0, 0)
		end
		parentTable[data.name or "Radio" .. i] = radio
		table.insert(radios, radio)
	end

	function radios:GetSelected()
		for i = 1, #self do
			local rad = self[i]
			if rad:GetChecked() then return rad.name end
		end
	end

	function radios:SetSelected(name)
		if not name then return end
		if not parentTable[name] then error("No Option in Radio Group with name " .. name) end
		parentTable[name]:SetSelected(true)
	end

	function parentTable:GetSelected() return radios:GetSelected() end

	parentTable.SetSelected = radios.SetSelected

	return radios, parentTable
end


-- Create a vector edit box with buttons for ×2 and ½
-- This will create a group with an edit box and two buttons for each axis (X, Y, Z)
---@param parent Frame The parent frame for the edit box group
---@param name string Internal Name for the Editbox
---@param label string The label for the edit box (e.g., "X:", "Y:", "Z:")
---@param offsetX number The horizontal offset from the parent frame
---@param offsetY number The vertical offset from the parent frame
---@param linkedModifiers boolean? Optional flag if it should be linked with other vector edit boxes on this parent
---@return table|Frame
---@return table|EditBox|InputBoxTemplate
local function CreateVectorEditBox(parent, name, label, offsetX, offsetY, linkedModifiers)
	local group = CreateFrame("Frame", nil, parent)
	group:SetSize(60, 38) -- increased height to fit buttons above
	group:SetPoint("TOP", offsetX, offsetY)

	local eb = CreateFrame("EditBox", nil, group, "ObjectToolboxEditBoxTemplate")
	eb:SetSize(45, 20)
	eb:SetPoint("BOTTOMLEFT", 13, 4)
	eb:SetAutoFocus(false)
	eb:SetText("1")
	eb:HookScript("OnTextChanged", function(...)
		editBoxNumberValidate(...)
		invalidatePresetSelected()
	end)

	group.editbox = eb

	local text = eb.Label
	text:SetText(label)

	function eb:SetBackgroundTransparency(alpha)
		self.Left:SetAlpha(alpha)
		self.Middle:SetAlpha(alpha)
		self.Right:SetAlpha(alpha)
	end

	eb:HookScript("OnDisable", function(self)
		self:SetTextColor(Colors.disabled:GetRGB())
	end)
	eb:HookScript("OnEnable", function(self)
		self:SetTextColor(Colors.white:GetRGB())
	end)

	eb:HookScript("OnTabPressed", function(self) _editBox_HandleTabbing(self, self.tabList) end)
	if not parent.EditBox_TabList then parent.EditBox_TabList = {} end
	table.insert(parent.EditBox_TabList, eb)
	eb.tabList = parent.EditBox_TabList

	eb:SetBackgroundTransparency(0.33) -- Set initial transparency

	local doubleBtn = CreateFrame("Button", nil, group, "UIPanelButtonTemplate")
	doubleBtn:SetSize(20, 16)
	doubleBtn:SetText("×2")
	doubleBtn:SetPoint("BOTTOMRIGHT", eb, "TOP", 0, 2)
	doubleBtn:Hide()

	local halfBtn = CreateFrame("Button", nil, group, "UIPanelButtonTemplate")
	halfBtn:SetSize(20, 16)
	halfBtn:SetText("½")
	halfBtn:SetPoint("BOTTOMLEFT", eb, "TOP", 0, 2)
	halfBtn:Hide()


	-- Hover logic using counter
	local hoverCount = 0
	local function ShowButtons()
		doubleBtn:Show()
		halfBtn:Show()
		eb:SetBackgroundTransparency(0.75) -- Make the edit box semi-transparent when buttons are shown
	end

	local function HideButtons()
		C_Timer.After(0.05, function()
			if hoverCount == 0 then
				doubleBtn:Hide()
				halfBtn:Hide()

				if eb:HasFocus() then return end
				eb:SetBackgroundTransparency(0.33) -- Restore edit box transparency when buttons are hidden
			end
		end)
	end

	local function AttachHoverScripts(frame)
		frame:EnableMouse(true)
		frame:SetScript("OnEnter", function()
			hoverCount = hoverCount + 1
			ShowButtons()
		end)
		frame:SetScript("OnLeave", function()
			hoverCount = hoverCount - 1
			HideButtons()
		end)
	end

	for _, frame in pairs({ group, eb, doubleBtn, halfBtn }) do
		AttachHoverScripts(frame)
	end

	eb:HookScript("OnEditFocusLost", function(self)
		if self:IsMouseOver() then return end
		eb:SetBackgroundTransparency(0.33)
	end)
	eb:HookScript("OnEditFocusGained", function(self)
		eb:SetBackgroundTransparency(0.75)
	end)

	eb:HookScript("OnTextSet", function(self)
		self:SetCursorPosition(0)
	end)

	if linkedModifiers then
		parent["_linkedVectorBoxes"] = parent["_linkedVectorBoxes"] or {}
		table.insert(parent["_linkedVectorBoxes"], eb)
	end

	doubleBtn:SetScript("OnClick", function()
		local v = tonumber(eb:GetText()) or 1
		eb:SetText(v * 2)

		if linkedModifiers and parent["_linkedVectorBoxes"] and IsShiftKeyDown() then
			for _, otherEb in ipairs(parent["_linkedVectorBoxes"]) do
				if otherEb ~= eb then
					local otherV = tonumber(otherEb:GetText()) or 1
					otherEb:SetText(otherV * 2)
				end
			end
		end
	end)

	halfBtn:SetScript("OnClick", function()
		local v = tonumber(eb:GetText()) or 1
		eb:SetText(v / 2)

		if linkedModifiers and parent["_linkedVectorBoxes"] and IsShiftKeyDown() then
			for _, otherEb in ipairs(parent["_linkedVectorBoxes"]) do
				if otherEb ~= eb then
					local otherV = tonumber(otherEb:GetText()) or 1
					otherEb:SetText(otherV / 2)
				end
			end
		end
	end)

	parent["_" .. name .. "Vector"] = group

	return group, eb
end

local function CreateSimpleEditBox(label, parent, anchor, anchor2, offsetX, offsetY)
	local template = label and "ObjectToolboxEditBoxTemplate" or "ObjectToolboxEditBoxNoLabelTemplate"
	local eb = CreateFrame("EditBox", nil, parent, template)
	eb:SetSize(40, 20)
	eb:SetPoint(anchor, parent, anchor2 or anchor, offsetX or 0, offsetY or 0)
	eb:SetAutoFocus(false)
	eb:SetText("0")

	function eb:SetBackgroundTransparency(alpha)
		self.Left:SetAlpha(alpha)
		self.Middle:SetAlpha(alpha)
		self.Right:SetAlpha(alpha)
	end

	eb:SetBackgroundTransparency(0.33) -- Set initial transparency

	eb:HookScript("OnDisable", function(self)
		self:SetTextColor(Colors.disabled:GetRGB())
		self:SetBackgroundTransparency(0.33)
		--self:SetMouseMotionEnabled(false)
	end)
	eb:HookScript("OnEnable", function(self)
		self:SetTextColor(Colors.white:GetRGB())
		--self:SetMouseMotionEnabled(true)
	end)

	eb:HookScript("OnEnter", function(self)
		if not self:IsEnabled() then return end
		self:SetBackgroundTransparency(0.75)
	end)
	eb:HookScript("OnLeave", function(self)
		if self:HasFocus() then return end
		self:SetBackgroundTransparency(0.33)
	end)
	eb:HookScript("OnEditFocusLost", function(self)
		if self:IsMouseOver() then return end
		self:SetBackgroundTransparency(0.33)
	end)
	eb:HookScript("OnEditFocusGained", function(self)
		self:SetBackgroundTransparency(0.75)
	end)

	eb:HookScript("OnTextSet", function(self)
		self:SetCursorPosition(0)
	end)

	eb:HookScript("OnTabPressed", function(self) _editBox_HandleTabbing(self, self.tabList) end)
	if not parent.EditBox_TabList then parent.EditBox_TabList = {} end
	table.insert(parent.EditBox_TabList, eb)
	eb.tabList = parent.EditBox_TabList


	if label then eb.Label:SetText(label) end

	return eb
end

local function CreateSimpleNumberEditBox(label, parent, anchor, anchor2, offsetX, offsetY)
	local eb = CreateSimpleEditBox(label, parent, anchor, anchor2, offsetX, offsetY)
	eb:HookScript("OnTextChanged", function(...)
		editBoxNumberValidate(...)
		invalidatePresetSelected()
	end)
	return eb
end

local presetKeyToName = {
	Param = "Object Info",
	Rot = "Rotation",
	Color = "Color"
}

local function CreatePresetSaveLoadButton(key, parent, anchor, anchorFrame, anchor2, offsetX, offsetY, callback, saveCollector)
	local button = CreateFrame("Button", nil, parent)
	button:SetSize(20, 20)
	button:SetPoint(anchor, anchorFrame, anchor2 or anchor, offsetX or 0, offsetY or 0)
	EpsilonLib.Utils.Misc.SetupCoherentButtonTextures(button, "AnimCreate_Icon_Folder", true)
	button.NormalTexture:SetVertexColor(1, 0.82, 0, 1) -- Gold color
	button.PushedTexture:SetVertexColor(1, 0.92, 0.1, 1) -- Gold color
	button.tooltipTitle = ("Save/Load |5 %s Preset"):format(presetKeyToName[key])
	button.tooltip = EpsilonLib.Utils.Tooltip.ReplaceTags("{right-click-text-icon} a preset to delete")
	addTooltipHandlers(button, true)

	_registerPresetDropdown(button, key, callback, saveCollector)

	return button
end

local autoUpdateChecks = {
	-- [Button] = { update, get, key, name }
}

local function createGetAutoUpdateHybridButton(parent, name, key, getCallback, tooltipDesc, applyFunc)
	local button = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
	button:SetSize(40, 20)
	button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
	button.tooltipTitle = "Get/Auto-Update " .. name
	button.tooltip = (tooltipDesc and tooltipDesc .. "\n\r" or "") .. EpsilonLib.Utils.Tooltip.ReplaceTags("{left-click-text-icon} : Get Current Object\n{right-click-text-icon} : Toggle Auto-Update" .. (applyFunc and "\n{shift}+{left-click-text-icon} : Apply Current Data to Selected Object" or ""))
	button.tooltipWrap = true
	addTooltipHandlers(button)

	button:SetNormalFontObject("GameFontNormalSmall")
	button:SetDisabledFontObject("GameFontDisableSmall")
	button:SetHighlightFontObject("GameFontHighlightSmall")

	function button:RefreshText()
		if OPMasterTable.Options[key] then
			self:SetText(Colors.HYPER_GREEN:WrapTextInColorCode("AUTO"))
		else
			self:SetText("GET")
		end
	end

	button:SetScript("OnClick", function(self, buttonClicked)
		if buttonClicked == "LeftButton" then
			if IsShiftKeyDown() and applyFunc then
				applyFunc()
			else
				getCallback()
			end
		elseif buttonClicked == "RightButton" then
			OPMasterTable.Options[key] = not OPMasterTable.Options[key]
			self:RefreshText() -- Update the button text based on the new state
		end
	end)
	button:HookScript("OnShow", button.RefreshText)
	button:RefreshText() -- Initial text setup

	autoUpdateChecks[button] = { callback = getCallback, key = key, name = name, apply = applyFunc }

	return button
end

local function createAutoUpdateCheckbox(parent, name, key)
	local cb = CreateFrame("CheckButton", nil, parent)
	cb:SetNormalAtlas("common-icon-undo")
	cb.NormalTexture = cb:GetNormalTexture()
	cb.NormalTexture:ClearAllPoints()
	cb.NormalTexture:SetPoint("CENTER")
	cb.NormalTexture:SetSize(16, 16)

	cb:SetHighlightTexture("Interface\\Buttons\\UI-CheckBox-Highlight", "ADD")
	cb.HighlightTexture = cb:GetHighlightTexture()

	cb:SetCheckedTexture("Interface\\Buttons\\UI-CheckBox-Check")
	cb.CheckedTexture = cb:GetCheckedTexture()
	cb.CheckedTexture:SetAtlas("common-icon-checkmark")

	cb:SetDisabledCheckedTexture("Interface\\Buttons\\UI-CheckBox-Check-Disabled")
	cb.DisabledCheckedTexture = cb:GetDisabledCheckedTexture()
	cb.DisabledCheckedTexture:SetAtlas("common-icon-checkmark")
	cb.DisabledCheckedTexture:SetDesaturated(true)

	if name then
		cb.name = name
		cb.tooltipTitle = "Update " .. cb.name
	end
	cb.tooltip = EpsilonLib.Utils.Tooltip.ReplaceTags("{left-click-text-icon} : Toggle Auto-Update\n{right-click-text-icon} : Get Current Object\n{shift}+{right-click-text-icon} : Apply")

	cb:SetScript("OnClick", function(self, ...)
		OPMasterTable.Options[key] = self:GetChecked()
	end)
	cb:SetScript("OnShow", function(self)
		self:SetChecked(OPMasterTable.Options[key])
	end)

	addTooltipHandlers(cb)
	connectButtonWithSavedOption(cb, key)

	cb:SetSize(24, 24)

	return cb
end

local function CreateAndShowAdvancedCopyMenu()
	local ttOpts = {
		delay = 0.1
	}

	local f = AceGUI:Create("Window")
	f:SetCallback("OnClose", function(widget) AceGUI:Release(widget) end)
	f:EnableResize(false)
	f:SetWidth(234)
	f:SetHeight(200)
	f:SetTitle("Game Object - Advanced Copy")
	f:SetLayout("Flow")

	local copyData = {
		direction = "Forward",
		distance = 1,
		count = 1,
		entry = 0,
	}

	-- direction
	local directionDropdown = AceGUI:Create("Dropdown")
	directionDropdown:SetLabel("Direction")
	directionDropdown:SetList({
		["Forward"] = "Forward",
		["Backward"] = "Backward",
		["Left"] = "Left",
		["Right"] = "Right",
		["Up"] = "Up",
		["Down"] = "Down"
	}, { "Forward", "Backward", "Left", "Right", "Up", "Down" })
	directionDropdown:SetValue("Forward") -- Default value
	directionDropdown:SetWidth(100)
	directionDropdown:SetCallback("OnValueChanged", function(widget, event, value)
		copyData.direction = value
	end)
	f:AddChild(directionDropdown)
	EpsilonLib.Utils.Tooltip.SetAce(directionDropdown, "Direction", "The direction to copy the object in, based on the direction the object is facing.", ttOpts)

	-- distance
	local distanceEditBox = AceGUI:Create("MAW-Editbox")
	distanceEditBox:SetLabel("Distance")
	distanceEditBox:SetText(1) -- Default value
	distanceEditBox:SetWidth(100)
	distanceEditBox:SetCallback("OnTextChanged", function(widget, event, text)
		if text:find("[^%d]") then -- remove alpha characters
			text = text:gsub("[^%d]", "")
			distanceEditBox:SetText(text)
		end

		local num = tonumber(text)
		if num then
			copyData.distance = num           -- Store the last good text
		elseif text == "" then
			copyData.distance = ""            -- Reset last good text if empty
		else
			distanceEditBox:SetText(copyData.distance) -- Revert to last good text
		end
	end)
	f:AddChild(distanceEditBox)
	EpsilonLib.Utils.Tooltip.SetAce(distanceEditBox, "Distance", "The distance each copy will be moved, from the previous.", ttOpts)

	-- count
	local countEditBox = AceGUI:Create("MAW-Editbox")
	countEditBox:SetLabel("Count")
	countEditBox:SetText(1) -- Default value
	countEditBox:SetWidth(100)
	countEditBox:SetCallback("OnTextChanged", function(widget, event, text)
		if text:find("[^%d]") then -- remove alpha characters
			text = text:gsub("[^%d]", "")
			countEditBox:SetText(text)
		end

		local num = tonumber(text) and math.floor(tonumber(text))
		if num then
			copyData.count = num        -- Store the last good text
		elseif text == "" then
			copyData.count = ""         -- Reset last good text if empty
		else
			countEditBox:SetText(copyData.count) -- Revert to last good text
		end
	end)
	f:AddChild(countEditBox)
	EpsilonLib.Utils.Tooltip.SetAce(countEditBox, "Count", "The number of times to copy the object, moving by #distance each time.\n\rMust be any whole number of 1 or more.", ttOpts)

	-- entry
	local entryEditBox = AceGUI:Create("MAW-Editbox")
	entryEditBox:SetLabel("Override Entry")
	entryEditBox:SetText(0) -- Default value
	entryEditBox:SetWidth(100)
	entryEditBox:SetCallback("OnTextChanged", function(widget, event, text)
		if text:find("[^%d]") then -- remove alpha characters
			text = text:gsub("[^%d]", "")
			entryEditBox:SetText(text)
		end

		local num = tonumber(text)
		if num then
			copyData.entry = num        -- Store the last good text
		elseif text == "" then
			copyData.entry = ""         -- Reset last good text if empty
		else
			entryEditBox:SetText(copyData.entry) -- Revert to last good text
		end
	end)
	f:AddChild(entryEditBox)
	EpsilonLib.Utils.Tooltip.SetAce(entryEditBox, "Override Entry", "Override the entry ID of the copied object.\n\nIf set to 0 or blank, the original entry will be used.", ttOpts)

	-- Create a button
	local btn = AceGUI:Create("Button")
	btn:SetWidth(100)
	btn:SetText("Copy")
	btn:SetCallback("OnClick", function()
		local dir = copyData.direction:lower()
		local dist = copyData.distance
		assert(dist and dist ~= "", "Distance must be a valid number")
		local count = copyData.count or 1
		local entry = copyData.entry or ""
		if entry == 0 then entry = "" end -- if entry is 0, we don't want to send it
		local commandStr = ("gobject copy %s %s %d %s"):format(dir, dist, count, entry)

		if not EpsilonLib.GameObject:GetSelected() then
			sysMsg("No object selected to copy. Select an object first.")
			return
		end

		sendCmd(commandStr, function(success, errorMsg)
			if success then
				f:Hide()
			end
		end, true)
	end)
	-- Add the button to the container
	f:AddChild(btn)
	f:PauseLayout()
	btn:ClearAllPoints()
	btn:SetPoint("BOTTOM", 0, 10) -- Position the button at the bottom center
end

--#endregion

--#region Object Spawn & Info Controls

local objectSpawnInfoControls = CreateControlGroup(f, "ObjectSpawnInfo", 0, 0, 20)
objectSpawnInfoControls:SetPoint("TOP", 0, -46) -- Manual override position for the first control group

local objectSpawnIDEditBox = CreateSimpleNumberEditBox("ID", objectSpawnInfoControls, "TOPLEFT", "TOPLEFT", 24, 2)
objectSpawnIDEditBox:SetSize(80, 20)
connectButtonWithSavedOption(objectSpawnIDEditBox, "ObjectID")

local function GetCurrentObjectIDCallback()
	local object = EpsilonLib.GameObject:GetSelected()
	if not object then
		sysMsg("No object selected. Select an Object First.")
		return
	end

	if object.isGroup then return end -- don't update if it's a group

	objectSpawnIDEditBox:SetText(object.entry)
end
objectSpawnInfoControls.GetCurrentObjectIDButton = ChainWrap(createGetAutoUpdateHybridButton(objectSpawnInfoControls, "Object ID", "autoUpdateObjectID",
		GetCurrentObjectIDCallback,
		"Update the Object Entry ID to that of the currently selected object.\n\rIf Auto-Update is enabled, this will automatically update the ID whenever an object is selected."
	))
	:SetPoint("LEFT", objectSpawnIDEditBox, "RIGHT", 4, 0)
OBJECT_TOOLBOX_API.GetObjectID = GetCurrentObjectIDCallback

local openViewerButton = CreateFrame("Button", nil, objectSpawnInfoControls)
objectSpawnInfoControls.OpenViewerButton = ChainWrap(openViewerButton)
	:SetSize(16, 16)
	:SetPoint("LEFT", objectSpawnInfoControls.GetCurrentObjectIDButton:Unwrap(), "RIGHT", 4, 0)
	:SetScript("OnClick", function(self)
		(SlashCmdList["EPSV"] or null)()
	end)
openViewerButton.tooltipText = "Open Viewer to find Objects"
EpsilonLib.Utils.Misc.SetupCoherentButtonTextures(openViewerButton, "common-search-magnifyingglass", true, Colors.game_gold)
addTooltipHandlers(openViewerButton, true)


local openGobHistoryButton = CreateFrame("Button", nil, objectSpawnInfoControls)
objectSpawnInfoControls.OpenGobHistoryButton = ChainWrap(openGobHistoryButton)
	:SetSize(22, 22)
	:SetPoint("LEFT", objectSpawnInfoControls.OpenViewerButton:Unwrap(), "RIGHT", 2, 0)
	:SetScript("OnClick", function(self)
		EpsilonLibGobHistoryFrame:SetShown(not EpsilonLibGobHistoryFrame:IsShown())
	end)
openGobHistoryButton.tooltipText = "Open Gob History"
EpsilonLib.Utils.Misc.SetupCoherentButtonTextures(openGobHistoryButton, "unitframeicon-chromietime", true)
addTooltipHandlers(openGobHistoryButton, true)


local openObjectInfoPanelButton = CreateFrame("Button", nil, objectSpawnInfoControls)
objectSpawnInfoControls.OpenObjInfoPanelButton = ChainWrap(openObjectInfoPanelButton)
	:SetSize(28, 28)
	:SetPoint("TOPLEFT", 2, 49)
	:RegisterForClicks("LeftButtonUp", "RightButtonUp")
	:SetScript("OnClick", function(self, button)
		if button == "LeftButton" then
			if OPPanelPopout:IsShown() then
				OPPanelPopout:Hide()
				OPPanelPopout.visWithMainFrame = false
			else
				OPPanelPopout:Show()
			end
		elseif button == "RightButton" then
			local parent = OPPanelPopout
			parent:Show()
			parent:SetUserPlaced(false)
			parent:ClearAllPoints()
			parent:SetPoint("RIGHT", ObjectToolboxFrame, "LEFT", 0, 0)
			parent:SetHeight(ObjectToolboxFrame:GetHeight() - 20)
		end
	end)

openObjectInfoPanelButton.tooltipTitle = "Open Object Info Panel"
openObjectInfoPanelButton.tooltipText = "Shows an extended panel with Currently Selected Object Information\n\rRight Click to re-attach the Info frame to the main frame."

EpsilonLib.Utils.Misc.SetupCoherentButtonTextures(openObjectInfoPanelButton, ASSET_PATH .. "eps_om_icon_objinfo")
addTooltipHandlers(openObjectInfoPanelButton, true)

--#endregion

--#region Game Object Basic Control Icon Buttons Row

-- Icon Buttons Row

local function spawnObject_OnClick(self, btn)
	local objectID = tonumber(objectSpawnIDEditBox:GetText())
	if not objectID or objectID <= 0 then
		sysMsg("Invalid Object ID. Please enter a valid number.")
		return
	end

	if btn == "RightButton" then
		local scale = f.GobScaleControls.Content.ScaleEditBox:GetText()
		local rotation = f.RotationControls.Content:GetRotationInfo()
		local color = f.GetColorInfo()

		cmd("gobject spawn " .. objectID .. " rot " .. rotation.x .. " " .. rotation.y .. " " .. rotation.z .. " scale " .. scale .. " " .. color.mode .. " " .. color.r .. " " .. color.g .. " " .. color.b)
	else
		cmd("gobject spawn " .. objectID)
	end
end
OBJECT_TOOLBOX_API.SpawnGob = spawnObject_OnClick

local function gobDelete_OnClick(self, btn)
	local object = EpsilonLib.GameObject:GetSelected()
	if not object then
		sysMsg("No object selected.")
		return
	end

	if object.isDeleted then
		sysMsg("Object Already Deleted!")
		return
	end

	if btn == "RightButton" then -- bypass confirmation
		object:Delete()
	else
		EpsilonLib.Utils.GenericDialogs.GenericConfirmation(
			("Are you sure you you want to delete selected object?\n\r%s\nGUID: %s / Entry: %s"):format(ContrastColor:WrapTextInColorCode(object:GetName()), ContrastColor:WrapTextInColorCode(object:GetGUID()), ContrastColor:WrapTextInColorCode(object:GetEntry())),
			function() object:Delete() end
		)
	end
end

local additional_tools = {
	LibScrollableDropdown:CreateTitle("More Tools"),
	LibScrollableDropdown:CreateDivider(),
}

local lastToolUsedData
local function openMoreToolsMenu(frame)
	local button = GetMouseButtonClicked()

	if button == "RightButton" and lastToolUsedData then
		lastToolUsedData[2](unpack(lastToolUsedData, 3))
		return
	end

	-- generate module dropdown here from the additional_tools, dynamic so new ones can be added by other addons or modules
	LibScrollableDropdown:Open(frame, additional_tools)
end

local function deepReplaceFuncWithMemory(data)
	if not data then return end
	local _origFunc = data.func
	if _origFunc then
		data.func = function(...)
			local forceName, forceFunc = _origFunc(...)
			local toolName = forceName or data.text
			local item = ...
			if item._menu._parentItem then toolName = item._menu._parentItem._info.text .. " - " .. toolName end -- capture name of the nested menu to include
			lastToolUsedData = { toolName, forceFunc or _origFunc, ... }
		end
	end

	-- recurse for subMenus
	if data.subMenu then
		for k, v in ipairs(data.subMenu) do
			deepReplaceFuncWithMemory(v)
		end
	end
end

local function registerToolModule(moduleData, subModule)
	local insertSector = additional_tools

	if subModule then
		if not insertSector[subModule] then insertSector[subModule] = LibScrollableDropdown:CreateSubMenu(subModule, {}) end
		insertSector = insertSector[subModule].subMenu
	end

	for _, line in ipairs(moduleData) do
		deepReplaceFuncWithMemory(line)

		table.insert(insertSector, line)
	end
end

local gobBasicControls = {
	{
		name = "Select",
		icon = ASSET_PATH .. "icons/eps_om_icon_select",
		func = function(self, btn)
			if IsModifierKeyDown() then -- group select
				local selectedObject = EpsilonLib.GameObject:GetSelected()
				if not selectedObject then
					sysMsg("Must select a single object first, in order to select it's group.")
					return
				end
				selectedObject:SelectGroup()
			end

			if btn == "RightButton" then
				--EpsilonLib.GameObject:SelectByName()
				EpsilonLib.Utils.GenericDialogs.CustomInput({
					text = "Select Object by Name, GUID, or Entry:",
					callback = function(text)
						EpsilonLib.GameObject:Select(text)
					end,
					acceptText = "Select",
					maxLetters = 60
				})
			else
				EpsilonLib.GameObject:Select()
			end
		end,
		tooltip = EpsilonLib.Utils.Tooltip.ReplaceTags(
			table.concat({
				"{left-click-text-icon}: Select nearest object",
				"{right-click-text-icon}: Select by name, guid, or entry",
				"{shift}+{left-click-text-icon}: Select group of objects",
			}, "\n")
		),
	},
	{
		name = "Unselect",
		icon = ASSET_PATH .. "icons/eps_om_icon_unselect",
		func = function(self, btn)
			EpsilonLib.GameObject:Unselect()
		end,
		tooltip = EpsilonLib.Utils.Tooltip.ReplaceTags("{left-click-text-icon}: Unselect object"),
	},
	{
		name = "Spawn",
		icon = ASSET_PATH .. "icons/eps_om_icon_spawn",
		func = spawnObject_OnClick,
		tooltip = function()
			local gobID = objectSpawnIDEditBox:GetText()
			if gobID == '' then gobID = nil end
			--return gobID and ("Spawn an object with entry ID %s at your current position"):format(ContrastColor:WrapTextInColorCode(gobID)) or "Spawn an object\n\rMust Set a Valid Entry ID in the ID box"
			return EpsilonLib.Utils.Tooltip.ReplaceTags(table.concat(
				{ ("{left-click-text-icon}: Spawn %s"):format(gobID and ContrastColor:WrapTextInColorCode(gobID) or "Object"), "{right-click-text-icon}: Spawn with Current Rotation, Scale & Color", ((not gobID) and ("\n%s"):format(Colors.GENTLE_RED:WrapTextInColorCode("Must Set a Valid Entry ID in the ID box"))) or nil }, "\n"))
		end,
	},
	{
		name = "Delete",
		icon = ASSET_PATH .. "icons/eps_om_icon_delete",
		func = gobDelete_OnClick,
		tooltip = EpsilonLib.Utils.Tooltip.ReplaceTags(table.concat({ "{left-click-text-icon}: Prompt to Delete", "{right-click-text-icon}: Delete Selected Object" }, "\n"))
	},
	{
		name = "More Tools",
		icon = ASSET_PATH .. "icons/eps_om_icon_tools",
		func = openMoreToolsMenu,
		tooltip = function()
			local lastToolUsedName = lastToolUsedData and lastToolUsedData[1] or nil
			return EpsilonLib.Utils.Tooltip.ReplaceTags(table.concat({ "{left-click-text-icon}: Additional Tools", "{right-click-text-icon}: Repeat Last Tool" .. (lastToolUsedName and (" (" .. lastToolUsedName .. ")") or " (None)") }, "\n"))
		end
	},
}

local gobBasicControlsGroup = CreateControlGroup(f, "GobBasic", 0, 0, 46)
gobBasicControlsGroup.bg = CreateControlGroupBG(gobBasicControlsGroup, 0)

local gobBasicActionButtons = CreateCenteredIconButtons(gobBasicControlsGroup, gobBasicControls, 32, 4)
gobBasicControlsGroup.buttons = gobBasicActionButtons

--#endregion


--#region Object Movement Controls (Arrows)

local objectMovementPullout, objectMovementControls = CreateControlGroup(f, "ObjectMovement", 0, 0, 262, "CONTROL / COPY / MOVE", nil, true)
--f.ObjectMovementControls.Content

-- Create directional arrow buttons using texture
local function CreateArrowButton(parent, dir, texture, rotation, x, y, sizeX, sizeY, color)
	local b = CreateFrame("Button", nil, parent)
	b:SetSize(sizeX, sizeY or sizeX) -- Use sizeX for both dimensions if sizeY is not provided
	b:SetPoint("CENTER", x, y)
	b.dir = dir
	b.tex = b:CreateTexture(nil, "ARTWORK")
	b.tex:SetTexture(texture)
	b.tex:SetAllPoints()
	if rotation then
		b.tex:SetRotation(rotation)
	end
	b.tex:SetTexCoord(0 + 0.1875, 1 - 0.1875, 0 + 0.25, 1 - 0.25)

	-- Highlight effect
	b.highlight = b:CreateTexture(nil, "HIGHLIGHT")
	b.highlight:SetTexture(texture)
	b.highlight:SetBlendMode("ADD")
	b.highlight:SetAllPoints()
	b.highlight:SetRotation(rotation or 0)
	b.highlight:SetAlpha(0.6)
	b.highlight:SetTexCoord(0 + 0.1875, 1 - 0.1875, 0 + 0.25, 1 - 0.25)

	if color then
		b.tex:SetVertexColor(color.r, color.g, color.b, color.a or 1) -- Set color with alpha
		b.highlight:SetVertexColor(color.r, color.g, color.b, color.a or 1) -- Set highlight color with alpha
	end
	b.color = {
		r = color.r or 1,
		g = color.g or 1,
		b = color.b or 1,
		a = color.a or 1,
	}

	b:SetScript("OnDisable", function(self)
		self.tex:SetVertexColor(0.66, 0.66, 0.66, 1)
		self.tex:SetDesaturated(true)
	end)
	b:SetScript("OnEnable", function(self)
		self.tex:SetVertexColor(self.color.r, self.color.g, self.color.b, self.color.a)
		self.tex:SetDesaturated(false)
	end)

	b:HookScript("OnClick", function(self, ...)
		if self.OnClick then self:OnClick(...) end
	end)

	return b
end

local arrowSpacing = 36
local arrowGroup = CreateFrame("Frame", nil, objectMovementControls)
arrowGroup:SetSize(100, 100)
arrowGroup:SetPoint("TOP", objectMovementControls, "TOP", -20, -22)
objectMovementControls.ArrowGroup = arrowGroup

local compassSize = 120

local arrowCompassGear = arrowGroup:CreateTexture(nil, "BACKGROUND")
--arrowCompassGear:SetAtlas("Azerite-TitanBG-Rank5-1Gear")
arrowCompassGear:SetTexture(ASSET_PATH .. "OMCompassBG")
arrowCompassGear:SetSize(compassSize * 1.75, compassSize * 1.75)
arrowCompassGear:SetPoint("CENTER", arrowGroup, "CENTER", 0, 0)

--[[
local arrowCompassRing = arrowGroup:CreateTexture(nil, "BACKGROUND")
arrowCompassRing:SetAtlas("Azerite-GoldRing-Rank3")
arrowCompassRing:SetSize(compassSize - 20, compassSize - 20)
arrowCompassRing:SetPoint("CENTER", arrowGroup, "CENTER", 0, 0)

local arrowCompassNorthRing = arrowGroup:CreateTexture(nil, "ARTWORK")
arrowCompassNorthRing:SetTexture("interface/minimap/compassring")
arrowCompassNorthRing:SetSize(compassSize, compassSize)
arrowCompassNorthRing:SetPoint("CENTER", arrowGroup, "CENTER", 0, 0)
local texCoordOffset = 0.25 -- Adjust this value to change the size of the "N" ring
arrowCompassNorthRing:SetTexCoord(0 + texCoordOffset, 1 - texCoordOffset, 0 + texCoordOffset, 1 - texCoordOffset)
--]]

arrowGroup.compassElements = {
	arrowCompassGear,
	--arrowCompassRing,
	--arrowCompassNorthRing
}

arrowGroup.UpdateRotation = function(self, compassFacing, buttonFacing)
	if not compassFacing then return end

	if self.cFacing == compassFacing and self.bFacing == buttonFacing then
		return -- No change in facing, skip update
	end
	self.cFacing = compassFacing
	self.bFacing = buttonFacing


	for _, tex in ipairs(self.compassElements) do
		tex:SetRotation(-compassFacing)
	end

	if OPMasterTable.Options['LockArrowOrientation'] then return end
	self.buttons:UpdateRotation(-(buttonFacing or 0))
end
-- On Update script is set later to update the rotation based on current movement mode


-- Store compass textures in a table for unified rotation

local dirs = {
	forward = "forward",
	back = "back",
	left = "left",
	right = "right",
	forward_left = "forward_left",
	forward_right = "forward_right",
	back_left = "back_left",
	back_right = "back_right",
	up = "up",
	down = "down"
}
local arrowButtons = { array = {} }
arrowGroup.buttons = arrowButtons

local arrowTexture = ASSET_PATH .. "OMCompassArrow"
local arrowTexOverride = {
	forward = ASSET_PATH .. "OMCompassArrowForward",
	up = ASSET_PATH .. "OMCompassArrowZ",
	down = ASSET_PATH .. "OMCompassArrowZ",
}
local arrowRotations = {
	back = math.pi,
	forward = 0,
	right = -math.pi / 2,
	left = math.pi / 2,
	back_right = -3 * math.pi / 4,
	back_left = 3 * math.pi / 4,
	forward_right = -math.pi / 4,
	forward_left = math.pi / 4,
	up = 0,
	down = math.pi
}
local arrowOffsets = {
	forward = { x = 0, y = arrowSpacing, axis = "L" },
	back = { x = 0, y = -arrowSpacing, axis = "L" },
	right = { x = arrowSpacing, y = 0, axis = "W" },
	left = { x = -arrowSpacing, y = 0, axis = "W" },
	forward_left = { x = -arrowSpacing, y = arrowSpacing, axis = "L_W" },
	forward_right = { x = arrowSpacing, y = arrowSpacing, axis = "L_W" },
	back_left = { x = -arrowSpacing, y = -arrowSpacing, axis = "L_W" },
	back_right = { x = arrowSpacing, y = -arrowSpacing, axis = "L_W" },
	up = { x = arrowSpacing * 2.5, y = arrowSpacing * 0.5, axis = "H" },
	down = { x = arrowSpacing * 2.5, y = -arrowSpacing * 0.5, axis = "H" }
}


local arrowColors = {
	forward = Colors.HYPER_GREEN,
	back = Colors.HYPER_GREEN,
	left = Colors.FULL_RED,
	right = Colors.FULL_RED,
	forward_left = Colors.neon_blue,
	forward_right = Colors.neon_blue,
	back_left = Colors.neon_blue,
	back_right = Colors.neon_blue,
	up = Colors.OM_BRONZE_GOLD,
	down = Colors.OM_BRONZE_GOLD,
}
local arrowSizeOverride = {
	up = { width = 40, height = 32 },
	down = { width = 40, height = 32 }
}

local moveObject = function(dir1, dist1, ...)
	if not dir1 and not tonumber(dist1) then return error("Must provide at least one valid direction & distance") end
	local object = EpsilonLib.GameObject:GetSelected()

	if select("#", ...) % 2 == 1 then return error("Invalid Number of Arguments for MoveObject - Must provide equal number of dir & dist args") end

	local distances = { tonumber(dist1) }
	local directions = { dir1 }
	local dirXdistStrs = { strjoin(" ", dir1, dist1) }
	local _lastDir
	if ... then
		for i, arg in ipairs({ ... }) do
			if i % 2 == 1 then -- direction
				tinsert(directions, arg)
				_lastDir = arg -- save the dir to use with the next dist
			else      -- distance
				tinsert(distances, arg)
				tinsert(dirXdistStrs, strjoin(" ", _lastDir, arg))
			end
		end
	end

	if f.MovePlayerCheck:GetChecked() then
		-- Special Handler; need to move player using ".gps dir dist" command instead. GPS allows batch movement, even tho it's undocumented.
		cmd("gps " .. table.concat(dirXdistStrs, " "))
		return
	end

	if f.WorldCheck:GetChecked() then
		-- Move as if facing north, using player's facing for math, outputting relative directions
		local playerFacing = GetPlayerFacing() or 0
		-- We'll convert all movement into a net X/Y vector, rotate it by -playerFacing, then decompose into relative directions

		local dx, dy, dz = 0, 0, 0
		for i = 1, #directions do
			local dir = directions[i]
			local dist = distances[i]
			if dir == "forward" then
				dx = dx + 0
				dy = dy + dist
			elseif dir == "back" then
				dx = dx + 0
				dy = dy - dist
			elseif dir == "left" then
				dx = dx - dist
				dy = dy + 0
			elseif dir == "right" then
				dx = dx + dist
				dy = dy + 0
			elseif dir == "forward_left" then
				local d = dist / math.sqrt(2)
				dx = dx - d
				dy = dy + d
			elseif dir == "forward_right" then
				local d = dist / math.sqrt(2)
				dx = dx + d
				dy = dy + d
			elseif dir == "back_left" then
				local d = dist / math.sqrt(2)
				dx = dx - d
				dy = dy - d
			elseif dir == "back_right" then
				local d = dist / math.sqrt(2)
				dx = dx + d
				dy = dy - d
			elseif dir == "up" then
				dz = dz + dist
			elseif dir == "down" then
				dz = dz - dist
			end
		end

		-- Rotate vector by -playerFacing
		local cos = math.cos(-playerFacing)
		local sin = math.sin(-playerFacing)
		local rx = dx * cos - dy * sin
		local ry = dx * sin + dy * cos

		-- Decompose into relative forward/back and left/right
		local rel = {}
		if math.abs(ry) > 0.0001 then
			if ry > 0 then
				table.insert(rel, ("forward %.4f"):format(ry))
			else
				table.insert(rel, ("back %.4f"):format(-ry))
			end
		end
		if math.abs(rx) > 0.0001 then
			if rx > 0 then
				table.insert(rel, ("right %.4f"):format(rx))
			else
				table.insert(rel, ("left %.4f"):format(-rx))
			end
		end
		if dz ~= 0 then
			table.insert(rel, ("up %.4f"):format(dz))
		end


		local finalDist = table.concat(rel, " ")
		if finalDist ~= "" then
			-- If both copy and relative are checked, we need to use "copy" first, then "relative" after it's done
			if f.CopyCheck:GetChecked() then
				op_cmd("gobject", ("%s %s"):format("copy", "up 0"), true,
					function(success, msgs)
						if not success then
							Utils.eprint("Failed copy command before world-relative movement")
							return false
						end
						op_cmd("gobject", ("%s %s"):format("relative", finalDist), true)
						return nil
					end
				)
			else
				op_cmd("gobject", ("%s %s"):format("relative", finalDist), true)
			end
		end
		return
	end


	local moveCmd = "move"
	local copyCheck = f.CopyCheck:GetChecked()
	local relativeCheck = f.RelativeCheck:GetChecked()

	if relativeCheck then moveCmd = "relative" end
	if copyCheck then moveCmd = "copy" end

	local finalCom = table.concat(dirXdistStrs, " ")
	local secondCom

	if copyCheck and (relativeCheck or select("#", ...) > 0) then
		-- If both copy and relative are checked, or we have multiple movements to make, we need to use "copy" first, then "relative" after it's done
		secondCom = finalCom
		finalCom = "up 0"
	end

	op_cmd("gobject", ("%s %s"):format(moveCmd, finalCom), true,
		nil,
		function(success, msgs)
			if not success and msgs[1]:find("Impossible selection error") then
				local _command = moveCmd
				if _command == "relative" then _command = "move" end
				Utils.eprint(("You cannot %s an object if there is none selected. Did you delete it?"):format(_command))
				return false
			else
				if secondCom then
					-- If we had to use a second command, run it now
					op_cmd("gobject", ("%s %s"):format("relative", secondCom), true, function(success, msgs)
						if not success then
							Utils.eprint("Failed relative movement command: " .. secondCom)
							return false
						end
					end)
				end
				return nil
			end
		end
	)
end

for dir, name in pairs(dirs) do
	local texture = arrowTexOverride[name] or arrowTexture
	local rotation = arrowRotations[name]
	local offset = arrowOffsets[name]
	local sizeX, sizeY = 32, 26
	if arrowSizeOverride[name] then
		sizeX = arrowSizeOverride[name].width
		sizeY = arrowSizeOverride[name].height
	end

	local color = arrowColors[name]

	arrowButtons[dir] = CreateArrowButton(arrowGroup, dir, texture, rotation, offset.x, offset.y, sizeX, sizeY, color)
	arrowButtons[dir].name = name
	table.insert(arrowButtons.array, arrowButtons[dir])

	arrowButtons[dir]:SetScript("OnClick", function(self)
		local distMultiplier = (tonumber(f:GetMoveDistance("M")) or 1)
		local axis = arrowOffsets[dir].axis

		local dirs = { strsplit("_", dir) }

		local distances = {}
		if axis:find("_") then
			local parts = { strsplit("_", axis) }
			for i, part in ipairs(parts) do
				distances[i] = f:GetMoveDistance(part) * distMultiplier
			end
		else
			distances[1] = f:GetMoveDistance(axis) * distMultiplier
		end
		moveObject(dirs[1], distances[1], dirs[2], distances[2])
	end)
end

function OBJECT_TOOLBOX_API.MoveObject(dir)
	arrowButtons[dir]:Click()
end

function arrowButtons:UpdateRotation(rads)
	for dir, btn in pairs(self) do
		if dir ~= "up" and dir ~= "down" then
			if type(btn) == "table" and btn.tex and arrowRotations[dir] then
				local baseRotation = arrowRotations[dir]
				btn.tex:SetRotation(baseRotation + rads)
				if btn.highlight then
					btn.highlight:SetRotation((dir == "up" and math.pi or dir == "down" and 0) or (baseRotation + rads))
				end

				-- Move the button around the center
				local offset = arrowOffsets[dir]
				if offset then
					-- Rotate the offset vector by rads
					local cosR = math.cos(rads)
					local sinR = math.sin(rads)
					local x = offset.x * cosR - offset.y * sinR
					local y = offset.x * sinR + offset.y * cosR
					btn:ClearAllPoints()
					btn:SetPoint("CENTER", btn:GetParent(), "CENTER", x, y)
				end
			end
		end
	end
end

function arrowButtons:SetEnabledState(enabled)
	for k, v in ipairs(arrowButtons.array) do
		v:SetEnabled(enabled)
	end
end

function arrowButtons:CheckIfEnableValid()
	local obj = EpsilonLib.GameObject:GetSelected()
	local enabled = obj and obj:CanEdit()

	if f.MovePlayerCheck:GetChecked() then enabled = true end
	self:SetEnabledState(enabled)
end

local arrowLockButton = CreateFrame("Button", nil, objectMovementControls)
objectMovementControls.ArrowLockButton = ChainWrap(arrowLockButton)
	:SetSize(16, 16)
	:SetPoint("CENTER", arrowGroup, "TOPRIGHT", 11, 11)
	:SetScript("OnClick", function(self, button)
		if button == "LeftButton" then
			OPMasterTable.Options['LockArrowOrientation'] = not OPMasterTable.Options['LockArrowOrientation']
			self:UpdateIcon()
			arrowGroup.bFacing = nil
			arrowGroup.cFacing = nil
		elseif button == "RightButton" then
			arrowGroup.buttons:UpdateRotation(0)
		end
	end)
	:SetScript("OnShow", function(self) self:UpdateIcon() end)
	:RegisterForClicks("LeftButtonUp", "RightButtonUp")

local lockIcon = EpsilonLib.API.Resource("LockedTintable")
local unlockIcon = EpsilonLib.API.Resource("UnlockedTintable")
function arrowLockButton:UpdateIcon()
	if OPMasterTable.Options['LockArrowOrientation'] then
		EpsilonLib.Utils.Misc.SetupCoherentButtonTextures(arrowLockButton, lockIcon, nil, Colors.game_gold, true)
	else
		EpsilonLib.Utils.Misc.SetupCoherentButtonTextures(arrowLockButton, unlockIcon, nil, Colors.GAME_GREY, true)
	end
end

arrowLockButton.tooltipTitle = "Lock Arrow Orientation"
arrowLockButton.tooltipText = EpsilonLib.Utils.Tooltip.ReplaceTags(table.concat(
	{
		"{left-click-text-icon}: Lock to Current Orientation",
		"{right-click-text-icon}: Reset Orientation (North)",
	},
	"\n")
)
addTooltipHandlers(arrowLockButton, true)


--#endregion

--#region Distance EditBox Controls

local distanceControls = {}
f.DistanceControls = distanceControls

local moveDownDist = 134
local editX, editXBox = CreateVectorEditBox(objectMovementControls, "Length", Colors.HYPER_GREEN:WrapTextInColorCode("L") .. ":", -65, -moveDownDist, true)
local editY, editYBox = CreateVectorEditBox(objectMovementControls, "Width", Colors.FULL_RED:WrapTextInColorCode("W") .. ":", 0, -moveDownDist, true)
local editZ, editZBox = CreateVectorEditBox(objectMovementControls, "Height", Colors.game_gold:WrapTextInColorCode("H") .. ":", 65, -moveDownDist, true)
local editM, editMBox = CreateVectorEditBox(objectMovementControls, "Mult", Colors.game_gold:WrapTextInColorCode("MULT"), 0, 0)
distanceControls.EditGroups = { X = editX, Y = editY, Z = editZ, M = editM }
distanceControls.EditBox = { X = editXBox, Y = editYBox, Z = editZBox, M = editMBox }

connectButtonWithSavedOption(editXBox, "Length")
connectButtonWithSavedOption(editYBox, "Width")
connectButtonWithSavedOption(editZBox, "Height")
connectButtonWithSavedOption(editMBox, "Scale")

local dirToAxis = { ["L"] = editXBox, ["W"] = editYBox, ["H"] = editZBox }
function f:GetMoveDistance(dir)
	if (not dir) or (type(dir) ~= "string") then return end
	local box = dirToAxis[dir:upper()] or distanceControls.EditBox[dir:upper()]
	local value = box and tonumber(box:GetText())
	if not value or value <= 0 then
		sysMsg(("Invalid distance value for %s. Please enter a valid, positive number."):format(dir))
		return 0
	end
	return value
end

function distanceControls.SetDimensions(l, w, h, m)
	if l then editXBox:SetText(l) end
	if w then editYBox:SetText(w) end
	if h then editZBox:SetText(h) end
	if m then editMBox:SetText(m) end
end

function distanceControls.GetDimensions(presetFormat)
	if presetFormat then
		return { Length = editXBox:GetText(), Width = editYBox:GetText(), Height = editZBox:GetText(), Scale = editMBox:GetText() }
	else
		return { x = editXBox:GetText(), y = editYBox:GetText(), z = editZBox:GetText(), m = editMBox:GetText() }
	end
end

editM:ClearAllPoints()
editM:SetPoint("CENTER", arrowGroup)
editMBox:ClearAllPoints()
editMBox:SetPoint("CENTER", 2, 0)
editMBox:SetWidth(30)
editMBox:SetJustifyH("CENTER")
editMBox.Label:ClearAllPoints()
editMBox.Label:SetPoint("TOP", editMBox, "BOTTOM", -2, 0)

local function objSizeCallback(size)
	if size == false then -- size is still loading
		sysMsg("Object Size is still loading... You got quick fingers, kid.")
		return
	elseif not size then
		--sysMsg("Object does not have a size. Probably a WMO. Blizz ain't ever gonna add WMO support..")
		return
	end

	local width, height, length = size.x, size.y, size.z
	distanceControls.SetDimensions(round(width, 2), round(height, 2), round(length, 2))

	--print(string.format("Updated sizes: Width: %.2f, Height: %.2f, Length: %.2f", width, height, length))
end

local function UpdateDistanceControlsWithSelectedObject(object, source)
	if source == "EPSILON_OBJ_INFO" then return end -- no auto-update on INFO updates since these are the same object.
	object = object or EpsilonLib.GameObject:GetSelected()
	if not object then
		-- TODO: Make this prettier?
		sysMsg("No object selected. Select an object first.")
		return
	end

	if object.isGroup then return end

	local size = object:GetSize(objSizeCallback)
end


distanceControls.GetCurrentObjectSizeButton = ChainWrap(createGetAutoUpdateHybridButton(objectMovementControls, "Distance / Dimensions", "autoUpdateParams",
		UpdateDistanceControlsWithSelectedObject,
		"Update the Distance / Dimensions (L x W x H) to that of the currently selected object.\n\rIf Auto-Update is enabled, this will automatically update the dimensions whenever an object is selected."
	))
	:SetPoint("TOP", 0, -174)


local function paramPresetCallback(content)
	if not content then return sysMsg("No Preset Content Selected?") end
	local currData = f.DistanceControls.GetDimensions(true)

	for k, v in pairs(content) do
		if v == "" then content[k] = nil end -- don't use blank data (old saves)
	end

	local length, width, height, scale = content.Length or currData.Length, content.Width or currData.Width, content.Height or currData.Height, content.Scale or currData.Scale

	f.DistanceControls.SetDimensions(length, width, height, scale)
end
local function paramSaveCollector()
	local params = f.DistanceControls.GetDimensions(true)
	for k, v in pairs(params) do
		if v == "" then params[k] = nil end -- don't save blank data
	end
	return params
end
objectMovementControls.SaveLoadObjectButton = CreatePresetSaveLoadButton("Param", objectMovementControls, "TOPLEFT", objectMovementControls, nil, 6, 0, paramPresetCallback,
	paramSaveCollector)

-- Radio-style checkboxes under arrows for movement mode (Relative or World)

local _, moveRadios = CreateRadioButtons(objectMovementControls, "ModeToggles", { { name = "relative", label = "Relative" }, { name = "world", label = "World" } }, true, nil, true)

moveRadios.relative:SetSize(20, 20)
moveRadios.relative:SetPoint("BOTTOMLEFT", objectMovementControls, "TOPLEFT", 2, -208)
moveRadios.relative:SetChecked(false)
moveRadios.relative.tooltip = "Move the object relative to the player's facing direction instead of the object's facing direction.\n\r" ..
	"This is the same as 'gobject relative' commands.\n\r" ..
	"Compass: Reflects Object Selected Direction\n" ..
	"Arrows:  Reflects Direction Object Will Move"
f.RelativeCheck = moveRadios.relative
addTooltipHandlers(moveRadios.relative)
connectButtonWithSavedOption(f.RelativeCheck, "RelativeToPlayer")

moveRadios.world:SetSize(20, 20)
moveRadios.world:SetPoint("BOTTOM", moveRadios.relative, "TOP", 0, -4)
moveRadios.world:SetChecked(false)
moveRadios.world.tooltip = "Move the object in relation to the world instead of the object's facing direction.\n\r" ..
	"The equivalent would be '.gob relative' while facing perfectly north ('.gps face north').\n\r" ..
	"Compass: Reflects Object Selected Direction\n" ..
	"Arrows:  Reflects Direction Object Will Move"
f.WorldCheck = moveRadios.world
addTooltipHandlers(moveRadios.world)
connectButtonWithSavedOption(f.WorldCheck, "RelativeToWorld")


local altMoveRadios = {}
--f.ObjectMovementControls.Content.AltModeToggles.player
objectMovementControls.AltModeToggles = altMoveRadios
altMoveRadios.player = CreateFrame("CheckButton", nil, objectMovementControls, "UICheckButtonTemplate")
altMoveRadios.player:HookScript("OnDisable", _editcheckbox_OnDisable)
altMoveRadios.player:HookScript("OnEnable", _editcheckbox_OnEnable)
altMoveRadios.player.text:SetText("Player")
altMoveRadios.player.text:ClearAllPoints()
altMoveRadios.player.text:SetPoint("RIGHT", altMoveRadios.player, "LEFT", -1, 0)
altMoveRadios.player:SetHitRectInsets(-(altMoveRadios.player.text:GetStringWidth() + 2), 0, 0, 0)

altMoveRadios.copy = CreateFrame("CheckButton", nil, objectMovementControls, "UICheckButtonTemplate")
altMoveRadios.copy:HookScript("OnDisable", _editcheckbox_OnDisable)
altMoveRadios.copy:HookScript("OnEnable", _editcheckbox_OnEnable)
altMoveRadios.copy.text:SetText("Copy")
altMoveRadios.copy.text:ClearAllPoints()
altMoveRadios.copy.text:SetPoint("RIGHT", altMoveRadios.copy, "LEFT", -1, 0)
altMoveRadios.copy:SetHitRectInsets(-(altMoveRadios.copy.text:GetStringWidth() + 2), 0, 0, 0)


altMoveRadios.player:SetSize(20, 20)
altMoveRadios.player:SetPoint("BOTTOMRIGHT", objectMovementControls, "TOPRIGHT", -2, -208)
altMoveRadios.player:SetChecked(false)
altMoveRadios.player.tooltip = "Moves the player instead of the selected object."
f.MovePlayerCheck = altMoveRadios.player
addTooltipHandlers(altMoveRadios.player)
connectButtonWithSavedOption(f.MovePlayerCheck, "MovePlayer")
altMoveRadios.player:HookScript("OnClick", function(self)
	local checked = self:GetChecked()
	moveRadios.relative:SetEnabled(not checked)
	moveRadios.world:SetEnabled(not checked)
	altMoveRadios.copy:SetEnabled(not checked)
	arrowButtons:CheckIfEnableValid()
end)
hooksecurefunc(altMoveRadios.player, "SetChecked", function(self, val)
	local checked = self:GetChecked()
	moveRadios.relative:SetEnabled(not checked)
	moveRadios.world:SetEnabled(not checked)
	altMoveRadios.copy:SetEnabled(not checked)
	arrowButtons:CheckIfEnableValid()
end)

altMoveRadios.copy:SetSize(20, 20)
altMoveRadios.copy:SetPoint("BOTTOM", altMoveRadios.player, "TOP", 0, -4)
altMoveRadios.copy:SetChecked(false)
altMoveRadios.copy.tooltip = "Copies the currently selected object instead of moving it."
f.CopyCheck = altMoveRadios.copy
addTooltipHandlers(altMoveRadios.copy)
connectButtonWithSavedOption(f.CopyCheck, "MoveCopy")

-- Set up OnUpdate to rotate the compass elements based on current movement mode selected
arrowGroup:SetScript("OnUpdate", function(self, elapsed)
	local northFacing = 0 -- North is always at 0 radians
	if moveRadios.relative:GetChecked() or altMoveRadios.player:GetChecked() then
		-- Relative mode or Player alt-mode: use player's facing direction
		local facing = GetPlayerFacing() -- Get the player's current facing direction
		if not facing then return end

		-- Update the rotation of the compass elements
		self:UpdateRotation(facing, northFacing)
	elseif moveRadios.world:GetChecked() then
		-- World mode: north is always forward

		-- Update the rotation of the compass elements
		self:UpdateRotation(northFacing)
	else
		-- No mode modifier selected, use the object's facing direction for compass,
		-- and show the "forward" arrow as the direction the object would move if you pressed forward, relative to your current facing.
		local gob = EpsilonLib.GameObject:GetSelected()
		if not gob or not gob.orientation then
			-- No object selected, reset compass to north
			-- This will keep the compass in a neutral state until an object is selected
			self:UpdateRotation(northFacing, northFacing)
			return
		end
		local objOri = gob.orientation
		local playerFacing = GetPlayerFacing() or 0

		-- The compass ring shows the object's facing (objOri)
		-- The forward arrow should show the direction the object would move if you pressed forward (relative to player)
		-- So, the "forward" arrow is rotated by (-objOri + playerFacing)
		self:UpdateRotation(objOri, -objOri + playerFacing)
	end
end)

-- TODO: Add GetMovementInfo function and embed on f as a shortcut
--#endregion

--#region Game Object Edit Control Icon Buttons Row
-- Gob Edit Icon Buttons Row

local objectMemory
local function copyObjectButton_OnClick(self, button)
	-- idea:
	-- Left Click: Copy Object in Place
	-- Right Click: Copy Object Here (at player position)
	-- Ctrl + Click: Save Object Copy to Memory
	-- Shift + Click: Spawn Copy from Memory (follow left / right from above)
	-- Alt + Click: Open Copy Custom Dialog
	if IsControlKeyDown() then
		objectMemory = EpsilonLib.GameObject:GetSelected()
		return
	end

	if IsShiftKeyDown() then
		if not objectMemory then
			sysMsg("No Object in Memory. Please select an object to copy.")
			return
		end
		objectMemory:DeepCopy(button ~= "RightButton")
		return
	end

	if IsAltKeyDown() then
		CreateAndShowAdvancedCopyMenu()
		return
	end

	if button == "RightButton" then
		cmd("gobject copy")
		return
	end
	cmd("gobject copy up 0")
end

local function gotoObjectButton_OnClick(self, button)
	if button == "RightButton" then
		EpsilonLib.Utils.GenericDialogs.CustomInput({
			text = "Go To Object (GUID):",
			isNumeric = true,
			callback = function(text)
				cmd(("gobject go %s"):format(text))
			end,
			acceptText = "Go To",

			maxLetters = 60
		})
		return
	end
	cmd("gobject go")
end
OBJECT_TOOLBOX_API.Cmd = cmd

local replace_memory_ID
local function replaceObjectButton_OnClick(self, button)
	if button == "RightButton" then
		if IsShiftKeyDown() then
			replace_memory_ID = nil
			_tooltip_show(self) -- forces the tooltip to update
			return
		end

		local object = EpsilonLib.GameObject:GetSelected()
		if not object then return end
		replace_memory_ID = object:GetEntry()
		_tooltip_show(self) -- forces the tooltip to update
		return
	end

	if replace_memory_ID then
		cmd(("gobject replace %s"):format(replace_memory_ID))
	else
		EpsilonLib.Utils.GenericDialogs.CustomInput({
			text = "Replace Object with (Entry):",
			isNumeric = true,
			callback = function(text)
				cmd(("gobject replace %s"):format(text))
			end,
			acceptText = "Replace",

			maxLetters = 60
		})
	end
end

local gobEditControls = {
	{
		name = "Replace",
		icon = ASSET_PATH .. "icons/eps_om_icon_replace",
		func = replaceObjectButton_OnClick,
		tooltip = function(self)
			local tt = {
				"Replace Selected Object with another Entry ID. If no saved entry, prompts for which entry ID to use.",
				" ",
				"{left-click-text-icon}: Replace Object (%s)",
				"{right-click-text-icon}: Save Entry",
			}
			if replace_memory_ID then
				tt[3] = tt[3]:format(replace_memory_ID)
				table.insert(tt, "{shift}+{right-click-text-icon}: Clear Saved Entry")
			else
				tt[3] = tt[3]:format("Prompt")
			end
			return EpsilonLib.Utils.Tooltip.ReplaceTags(table.concat(tt, "\n"))
		end,
	},
	{
		name = "GoTo",
		icon = ASSET_PATH .. "icons/eps_om_icon_goto",
		func = gotoObjectButton_OnClick,
		tooltip = EpsilonLib.Utils.Tooltip.ReplaceTags(table.concat({ "{left-click-text-icon}: GoTo Selected", "{right-click-text-icon}: GoTo GUID (Prompt)" }, "\n"))
	},
	{
		name = "Copy",
		icon = ASSET_PATH .. "icons/eps_om_icon_copy",
		func = copyObjectButton_OnClick,
		tooltip = function()
			return EpsilonLib.Utils.Tooltip.ReplaceTags(table.concat(
				{
					"{left-click-text-icon}: Copy in Place",
					"{right-click-text-icon}: Copy Here",
					" ",
					"{ctrl}+{left-click-text-icon}: Save Object Copy to Memory",
					"{shift}+{left-click-text-icon}: Spawn Copy from Memory at Original Position",
					"{shift}+{right-click-text-icon}: Spawn Copy from Memory at Player Position",
					"{alt}+{left-click-text-icon}: Open Copy Custom Dialog",
				},
				"\n")
			)
		end
	},
	{
		name = "Activate",
		icon = ASSET_PATH .. "icons/eps_om_icon_activate",
		func = function(self, btn) cmd("gobject activate") end
	},
}

local gobEditControlsGroup = CreateControlGroup(objectMovementControls, "GobEdit", 0, 0, 46, nil, true)
gobEditControlsGroup:ClearAllPoints()
gobEditControlsGroup:SetPoint("BOTTOMLEFT", 0, 2)
gobEditControlsGroup.bg = CreateControlGroupBG(gobEditControlsGroup, 0)

local gobEditActionButtons = CreateCenteredIconButtons(gobEditControlsGroup, gobEditControls, 32, 4)
gobEditControlsGroup.buttons = gobEditActionButtons

--#endregion

--#region Game Object Rotation + Tint Tab Region Set-up -- KEPT AS EXAMPLE OF HOW TO USE TabControlGroup?
--[[
local gobTabData = {
	{ name = "Rotation", label = "Rotation" },
	{ name = "Tint",     label = "Tint" },
}
local gobTabControls = CreateTabControlGroup(f, "GobControls", 0, -6, 140, gobTabData)
--]]

--#region Game Object Rotation Controls
local gobRotationPullout, gobRotationControls = CreateControlGroup(f, "Rotation", 0, 0, 140, "ROTATION", nil, true)
--NOTE: gobRotationControls=f.RotationControls.Content

local gobRotArrowsFrame = CreateFrame("Frame", nil, gobRotationControls)
gobRotArrowsFrame:SetSize(120, 120)
gobRotArrowsFrame:SetPoint("TOP", gobRotationControls, "TOP", 0, 0)
gobRotationControls.ArrowsFrame = gobRotArrowsFrame

--[[ -- Position Helper (DEBUG)
gobRotArrowsFrame:SetScript("OnMouseDown", function(self, button)
	if button == "LeftButton" then
		-- print where in the frame the click happened
		local x, y = self:GetCenter()
		local width, height = self:GetSize()

		local cursorX, cursorY = GetCursorPosition()
		local scale = self:GetEffectiveScale()
		cursorX = cursorX / scale
		cursorY = cursorY / scale
		local relativeX = cursorX - x + (width / 2)
		local relativeY = cursorY - y + (height / 2)
		print(string.format("Clicked at relative position: (%.2f, %.2f)", relativeX, height - relativeY))
	end
end)
--]]

local axisCanvasBase = 120
local axisCanvasSize = 150
local axisCanvasScale = axisCanvasSize / axisCanvasBase
local offsetCorrection = (axisCanvasSize - axisCanvasBase) / 2
local axisOffsetX = -3
local axisOffsetY = 4

local gobRotateRedAxis = gobRotArrowsFrame:CreateTexture(nil, "ARTWORK")
gobRotateRedAxis:SetTexture(ASSET_PATH .. "rotation-tools-red")
gobRotateRedAxis:SetSize(axisCanvasSize, axisCanvasSize)
gobRotateRedAxis:SetPoint("CENTER", axisOffsetX, axisOffsetY)

local gobRotateGreenAxis = gobRotArrowsFrame:CreateTexture(nil, "ARTWORK")
gobRotateGreenAxis:SetTexture(ASSET_PATH .. "rotation-tools-green")
gobRotateGreenAxis:SetSize(axisCanvasSize, axisCanvasSize)
gobRotateGreenAxis:SetPoint("CENTER", axisOffsetX, axisOffsetY)

local gobRotateBlueAxis = gobRotArrowsFrame:CreateTexture(nil, "ARTWORK")
gobRotateBlueAxis:SetTexture(ASSET_PATH .. "rotation-tools-blue")
gobRotateBlueAxis:SetSize(axisCanvasSize, axisCanvasSize)
gobRotateBlueAxis:SetPoint("CENTER", axisOffsetX, axisOffsetY)

local gobRotateHighlightAxis = gobRotArrowsFrame:CreateTexture(nil, "OVERLAY")
gobRotateHighlightAxis:SetTexture(ASSET_PATH .. "rotation-tools-blue-highlight-1")
gobRotateHighlightAxis:SetSize(axisCanvasSize, axisCanvasSize)
gobRotateHighlightAxis:SetPoint("CENTER", axisOffsetX, axisOffsetY)
gobRotateHighlightAxis:Hide()

local gobRotateBG = gobRotArrowsFrame:CreateTexture(nil, "BACKGROUND")
gobRotateBG:SetAtlas("BonusChest-CircleGlow")
gobRotateBG:SetSize(axisCanvasSize * 1.25, axisCanvasSize * 1.25)
gobRotateBG:SetPoint("CENTER", axisOffsetX, axisOffsetY)
gobRotateBG:SetVertexColor(Colors.OM_PURE_DARK_RED:GetRGB())
gobRotateBG:SetAlpha(0.4)
GOB_ROT_BG = gobRotateBG -- for debugging

function gobRotateHighlightAxis:Set(color, index)
	local file = ("rotation-tools-%s-highlight-%d"):format(color, index)
	self:SetTexture(ASSET_PATH .. file)
	self:Show()
end

-- Create axis buttons for rotation controls

local function CreateAxisButton(parent, name, x, y, width, height)
	local btn = CreateFrame("Button", name, parent)
	btn:SetSize(width, height)
	btn:SetPoint("TOPLEFT", parent, "TOPLEFT", x + axisOffsetX, -y + axisOffsetY)

	local tex = btn:CreateTexture(nil, "BACKGROUND")
	tex:SetAllPoints()
	--tex:SetColorTexture(1, 1, 0, 0.3) -- semi-transparent yellow
	btn.texture = tex

	local color, index = name:match("%a*_(%a*)"):lower(), name:match("%d", -1)
	btn:SetScript("OnEnter", function(self)
		--self.texture:SetColorTexture(1, 1, 0, 0.6)
		gobRotateHighlightAxis:Set(color, index)
	end)
	btn:SetScript("OnLeave", function(self)
		--self.texture:SetColorTexture(1, 1, 0, 0)
		gobRotateHighlightAxis:Hide()
	end)

	local holdThreshold     = 0.2 -- seconds before "hold" mode kicks in
	local repeatRate        = 0.05 -- how often to repeat while held
	local holdStart, lastRepeat
	local isHolding         = false
	local finalHeldRotation = nil

	btn:SetScript("OnMouseDown", function(self, btnClick)
		if btnClick ~= "LeftButton" then return end
		if not self:IsEnabled() then return end

		holdStart         = GetTime()
		lastRepeat        = holdStart
		isHolding         = false
		finalHeldRotation = nil

		self:SetScript("OnUpdate", function(self, elapsed)
			local now = GetTime()
			local gob = EpsilonLib.GameObject:GetSelected()
			if not gob then return end

			local axisN  = self.axisN or "turn"
			local axis   = self.axis or "z"
			local scalar = self.scalar or 1
			axisN        = (axisN:gsub("^%l", string.upper))

			if not isHolding and (now - holdStart) >= holdThreshold then
				isHolding = true
			end

			if isHolding and (now - lastRepeat) >= repeatRate then
				lastRepeat = now
				local current = gob.transform.rotation[axis] or 0
				local scalarNormalized = (finalHeldRotation or current) + scalar
				finalHeldRotation = scalarNormalized
				gob:Rotate(
					axis == "x" and scalarNormalized,
					axis == "y" and scalarNormalized,
					axis == "z" and scalarNormalized,
					true
				)
			end
		end)
	end)

	btn:SetScript("OnMouseUp", function(self, btnClick)
		if btnClick ~= "LeftButton" then return end
		if not self:IsEnabled() then return end

		self:SetScript("OnUpdate", nil)

		local gob = EpsilonLib.GameObject:GetSelected()
		if gob then
			local axisN  = self.axisN or "turn"
			local axis   = self.axis or "z"
			local scalar = self.scalar or 1
			axisN        = axisN:gsub("^%l", string.upper)

			if not isHolding then
				-- Quick click
				gob[axisN](gob, scalar)
			else
				-- end of holding, apply rotation:
				gob:Rotate(
					axis == "x" and finalHeldRotation,
					axis == "y" and finalHeldRotation,
					axis == "z" and finalHeldRotation
				)
			end
		else
			sysMsg("No object selected to rotate.")
		end

		holdStart, lastRepeat, isHolding = nil, nil, false
	end)



	return btn
end


--Button positions based on 120x120 canvas, adjusted from overlay image
--y is inverted in WoW UI coordinates (positive y is down)
--Each entry is: name, xOffset, yOffset, width, height, then axisN, axis, scalar as defined keys for the actual button click behavior

local buttonData = {
	-- name, x, y, width, height

	-- Blue arrow (left side)
	{ "Blue1",  19, 50, 18, 26, axisN = "pitch", axis = "y", scalar = -5 },
	{ "Blue2",  25, 28, 15, 22, axisN = "pitch", axis = "y", scalar = -1 },
	{ "Blue3",  40, 28, 15, 16, axisN = "pitch", axis = "y", scalar = 1 },
	{ "Blue4",  42, 44, 15, 20, axisN = "pitch", axis = "y", scalar = 5 },

	-- Red arrow (top-right)
	{ "Red1",   89, 56, 17, 18, axisN = "roll",  axis = "x", scalar = 5 },
	{ "Red2",   80, 43, 20, 13, axisN = "roll",  axis = "x", scalar = 1 },
	{ "Red3",   72, 27, 22, 16, axisN = "roll",  axis = "x", scalar = -1 },
	{ "Red4",   54, 22, 18, 17, axisN = "roll",  axis = "x", scalar = -5 },
	--]]

	-- Green arrow (bottom)
	{ "Green1", 44, 82, 26, 18, axisN = "turn",  axis = "z", scalar = -5 },
	{ "Green2", 70, 78, 21, 15, axisN = "turn",  axis = "z", scalar = -1 },
	{ "Green3", 76, 65, 14, 13, axisN = "turn",  axis = "z", scalar = 1 },
	{ "Green4", 56, 58, 20, 18, axisN = "turn",  axis = "z", scalar = 5 },
	--]]
}

gobRotationControls.Arrows = {}
gobRotArrowsFrame.Arrows = {}

for _, info in ipairs(buttonData) do
	local scaledX = info[2] * axisCanvasScale - offsetCorrection
	local scaledY = info[3] * axisCanvasScale - offsetCorrection
	local scaledWidth = info[4] * axisCanvasScale
	local scaledHeight = info[5] * axisCanvasScale

	local btn = CreateAxisButton(gobRotArrowsFrame, "gobRotateBtn_" .. info[1], scaledX, scaledY, scaledWidth, scaledHeight)
	gobRotationControls.Arrows[info[1]] = btn
	table.insert(gobRotArrowsFrame.Arrows, btn)
	btn.axisN = info.axisN
	btn.axis = info.axis
	btn.scalar = info.scalar
end

-- create rotation value edit boxes
gobRotationControls.RotEditBox = {}
gobRotationControls.RotSlider = {}
local rotationLabelNames = { X = "Roll", Y = "Pitch", Z = "Turn" } -- Use these names for the edit boxes
local rotationLabelNamesColor = { X = CreateColorFromHexString("FFFF6060"), Y = CreateColorFromHexString("FF386EF7"), Z = CreateColorFromHexString("FF21FC8B") }
local edgeScale = 24

local epsi_rollout_backdrop = {
	bgFile = ASSET_PATH .. "ui-party-background",
	edgeFile = ASSET_PATH .. "ui-party-borderuprez",
	tile = true,
	tileEdge = true,
	tileSize = 32,
	edgeSize = edgeScale,
	insets = { left = edgeScale, right = edgeScale, top = edgeScale, bottom = edgeScale },
};

--local classicPopoutSliderFrameColor = CreateColor(0.75, 0.235, 0.235, 0.6)
local classicPopoutSliderFrameColor = CreateColor(1, 1, 1, 0.6)
local rotSliderFrame = CreateFrame("Frame", "ObjectToolboxRotationSlidersFrame", UIParent, "BackdropTemplate")
gobRotationControls.rotSliderFrame = rotSliderFrame -- Store the frame in the controls for easy access
rotSliderFrame.realParent = gobRotationControls     -- Store the parent for easy access later
rotSliderFrame:SetSize(300, 110)
rotSliderFrame:SetBackdrop(epsi_rollout_backdrop)
rotSliderFrame:SetBackdropColor(classicPopoutSliderFrameColor:GetRGBA())
rotSliderFrame:SetBackdropBorderColor(classicPopoutSliderFrameColor:GetRGBA())
rotSliderFrame:SetPoint("RIGHT", rotSliderFrame.realParent, "LEFT", 4, 0)
rotSliderFrame:Hide()

rotSliderFrame.realParent:HookScript("OnHide", function(self)
	if rotSliderFrame:IsShown() then
		rotSliderFrame:Hide() -- Close the popout if the main controls are hidden
	end
end)

do
	local frame = rotSliderFrame
	local animGroup = frame:CreateAnimationGroup()
	local animInSpeed = 0.2
	local slide = animGroup:CreateAnimation("Translation")
	local offset = 200
	slide:SetDuration(animInSpeed)
	slide:SetSmoothing("OUT")
	slide:SetOffset(-offset, 0)
	slide:SetOrder(1)

	local fade = animGroup:CreateAnimation("Alpha")
	fade:SetDuration(animInSpeed)
	fade:SetFromAlpha(0)
	fade:SetToAlpha(1)
	fade:SetOrder(1)

	animGroup:SetToFinalAlpha(true)
	animGroup:SetScript("OnPlay", function(self)
		slide:SetOffset(-offset, 0)
		frame:SetAlpha(0)
		frame:SetPoint("RIGHT", frame.realParent, "LEFT", 4 + offset, 0) -- Start offscreen (right)
		frame:SetShown(true)
	end)

	animGroup:SetScript("OnFinished", function(self)
		frame:SetAlpha(1)
		frame:SetPoint("RIGHT", frame.realParent, "LEFT", 4, 0) -- ensure it's back in place after
		if self.isReverse then
			frame:Hide()                                  -- Hide the frame after sliding out
		end
	end)

	frame:SetScript("OnShow", function()
		animGroup:Stop()
		animGroup:Play()
	end)

	frame:SetScript("OnHide", function()
		animGroup:Stop()
	end)

	function frame:Open()
		animGroup:Stop()
		animGroup.isReverse = false
		animGroup:Play()
		frame:Show()
	end

	function frame:Close()
		animGroup:Stop()
		animGroup.isReverse = true
		animGroup:Play(true)
	end

	function frame:Toggle()
		if self:IsShown() then self:Close() else self:Open() end
	end
end

for i, axis in ipairs({ "X", "Y", "Z" }) do
	local offsetX = (i - 2) * 66 -- -48 for X, 0 for Y, 48 for Z (spaced horizontally)
	local offsetY = ((i - 1) * 32)
	local rotationFriendlyName = rotationLabelNames[axis]
	local rotationLabelColor = rotationLabelNamesColor[axis]
	local rotationLabelStr = rotationLabelColor:WrapTextInColorCode(rotationFriendlyName)

	local eb = CreateSimpleNumberEditBox(rotationLabelStr .. ":", gobRotationControls, "BOTTOM", "BOTTOM", (4 + offsetX), -2)
	--local eb = CreateSimpleNumberEditBox(rotationLabelStr .. ":", gobRotationControls, "TOPRIGHT", "TOPRIGHT", 0, -offsetY - 20)

	eb:SetSize(56, 20)
	eb.Label:ClearAllPoints()
	eb.Label:SetPoint("BOTTOM", eb, "TOP", 0, 2)

	gobRotationControls.RotEditBox[axis] = eb

	-- setup the sliders for the popout rot panel
	local slider = GenRotationSlider(rotSliderFrame, rotationFriendlyName, rotationLabelStr, axis)
	slider:SetPoint("TOPLEFT", 16, -18 - offsetY)
	slider:HookScript("OnValueChanged", function(self, value)
		if not value then return end
		local roundedValue = round(value, 4)
		eb:SetText(roundedValue) -- Update the edit box when the slider value changes
		invalidatePresetSelected()
	end)

	-- rotSliderFrame.RollSlider / PitchSlider / TurnSlider, or...
	gobRotationControls.RotSlider[axis] = slider

	-- Sync Slider to EditBox
	eb:HookScript("OnTextChanged", function(self)
		local value = tonumber(self:GetText())
		if not value then return end
		slider:SetValue(value)
		invalidatePresetSelected()
	end)

	eb:HookScript("OnEditFocusLost", function(self)
		local value = tonumber(self:GetText())
		if not value then return end

		-- do rotate here

		local gob = EpsilonLib.GameObject:GetSelected()
		if not gob then
			sysMsg('No Game Object Selected.')
			return
		end
		gob:Rotate(axis == "X" and value, axis == "Y" and value, axis == "Z" and value, false)
	end)
end

function gobRotationControls:SetAxisEnabled(axis, enabled)
	if axis == "X" then
		gobRotationControls.Arrows.Red1:SetEnabled(enabled)
		gobRotationControls.Arrows.Red2:SetEnabled(enabled)
		gobRotationControls.Arrows.Red3:SetEnabled(enabled)
		gobRotationControls.Arrows.Red4:SetEnabled(enabled)
		gobRotateRedAxis:SetDesaturated(not enabled)
	elseif axis == "Y" then
		gobRotationControls.Arrows.Blue1:SetEnabled(enabled)
		gobRotationControls.Arrows.Blue2:SetEnabled(enabled)
		gobRotationControls.Arrows.Blue3:SetEnabled(enabled)
		gobRotationControls.Arrows.Blue4:SetEnabled(enabled)
		gobRotateBlueAxis:SetDesaturated(not enabled)
	elseif axis == "Z" then
		gobRotationControls.Arrows.Green1:SetEnabled(enabled)
		gobRotationControls.Arrows.Green2:SetEnabled(enabled)
		gobRotationControls.Arrows.Green3:SetEnabled(enabled)
		gobRotationControls.Arrows.Green4:SetEnabled(enabled)
		gobRotateGreenAxis:SetDesaturated(not enabled)
	end

	gobRotationControls.RotEditBox[axis]:SetEnabled(enabled)
	gobRotationControls.RotSlider[axis]:SetEnabled(enabled)
end

function gobRotationControls:SetEnabledState(enabled, group)
	if group then
		self:SetAxisEnabled("X", false)
		self:SetAxisEnabled("Y", false)
		self:SetAxisEnabled("Z", enabled)
	else
		self:SetAxisEnabled("X", enabled)
		self:SetAxisEnabled("Y", enabled)
		self:SetAxisEnabled("Z", enabled)
	end
	--[[
	for k, btn in ipairs(gobRotArrowsFrame.Arrows) do
		btn:SetEnabled(enabled)
	end

	gobRotationControls.RotEditBox.X:SetEnabled(enabled)
	gobRotationControls.RotEditBox.Y:SetEnabled(enabled)
	gobRotationControls.RotEditBox.Z:SetEnabled(enabled)

	rotSliderFrame.RollSlider:SetEnabled(enabled)
	rotSliderFrame.PitchSlider:SetEnabled(enabled)
	rotSliderFrame.TurnSlider:SetEnabled(enabled)

	gobRotateBlueAxis:SetDesaturated(not enabled)
	gobRotateGreenAxis:SetDesaturated(not enabled)
	gobRotateRedAxis:SetDesaturated(not enabled)
	--]]
end

local rotSliderPopoutButton = CreateFrame("Button", nil, gobRotationControls)
rotSliderPopoutButton:SetSize(16, 16)
rotSliderPopoutButton:SetPoint("BOTTOMLEFT", gobRotationControls, "BOTTOMLEFT", 8, 36)
rotSliderPopoutButton.tooltipText = "Open a pop-out for classic rotation sliders."
rotSliderPopoutButton.tooltipTitle = "Rotation Sliders"
EpsilonLib.Utils.Misc.SetupCoherentButtonTextures(rotSliderPopoutButton, ASSET_PATH .. "OMSliders")
addTooltipHandlers(rotSliderPopoutButton, true)
rotSliderPopoutButton:SetScript("OnClick", function(self)
	rotSliderFrame:Toggle()
end)

local function updateGobRotAutoStuff(gob)
	local gob = gob or EpsilonLib.GameObject:GetSelected()
	if not gob then return end

	local x, y, z = 0, 0, 0
	if gob.isGroup then
		z = gob.orientation or 0
		--gobRotationControls:SetAxisEnabled("X", false)
		--gobRotationControls:SetAxisEnabled("Y", false)
		--gobRotationControls:SetAxisEnabled("Z", true)
	else
		--gobRotationControls:SetEnabledState(true, gob.isGroup)
		x, y, z = gob.transform.rotation.x, gob.transform.rotation.y, gob.transform.rotation.z
	end
	gobRotationControls:SetEnabledState(true, gob.isGroup)
	gobRotationControls:SetRotationInfo(x, y, z)
end


gobRotationControls.GetRotationButton = ChainWrap(createGetAutoUpdateHybridButton(gobRotationControls, "Object Rotation", "autoUpdateRot",
		updateGobRotAutoStuff,
		"Update the Rotation Values (Roll x Pitch x Turn) to that of the currently selected object.\n\rIf Auto-Update is enabled, this will automatically update the dimensions whenever an object is selected."
	))
	:SetPoint("TOPRIGHT", gobRotationControls, "TOPRIGHT", -4, -2)

gobRotationControls.ApplyRotationButton = ChainWrap(CreateFrame("Button", nil, gobRotationControls, "UIPanelButtonTemplate"))
	:SetSize(40, 20)
	:RegisterForClicks("LeftButtonUp", "RightButtonUp")
	:SetNormalFontObject("GameFontNormalSmall")
	:SetDisabledFontObject("GameFontDisableSmall")
	:SetHighlightFontObject("GameFontHighlightSmall")
	:SetText("Apply")
	:SetPoint("TOP", gobRotationControls.GetRotationButton:Unwrap(), "BOTTOM", 0, 0)

gobRotationControls.ApplyRotationButton.tooltipTitle = "Apply Rotation"
gobRotationControls.ApplyRotationButton.tooltip = EpsilonLib.Utils.Tooltip.ReplaceTags("{left-click-text-icon} : Apply Current Rotation to Selected Object")
gobRotationControls.ApplyRotationButton.tooltipWrap = true
addTooltipHandlers(gobRotationControls.ApplyRotationButton)

gobRotationControls.ApplyRotationButton:SetScript("OnClick", function()
	gobRotationControls:ApplyCurrentRotation()
end)

function gobRotationControls:SetRotationInfo(x, y, z, apply)
	if x == "-0" then x = 0 end -- Fix for -0.0 showing up in the edit box
	if y == "-0" then y = 0 end
	if z == "-0" then z = 0 end
	gobRotationControls.RotEditBox.X:SetText(x)
	gobRotationControls.RotEditBox.Y:SetText(y)
	gobRotationControls.RotEditBox.Z:SetText(z)

	if apply then
		local gob = EpsilonLib.GameObject:GetSelected()
		if not gob then
			sysMsg('No Object Selected. Cannot Apply Rotations.')
			return
		end
		gob:Rotate(x, y, z)
	end
end

function gobRotationControls:GetRotationInfo(presetFormat)
	local x, y, z = tonumber(self.RotEditBox.X:GetText()), tonumber(self.RotEditBox.Y:GetText()), tonumber(self.RotEditBox.Z:GetText())
	if presetFormat then
		return { RotX = x, RotY = y, RotZ = z }
	else
		return { x = x, y = y, z = z }
	end
end

function gobRotationControls:ApplyCurrentRotation()
	local rots = gobRotationControls:GetRotationInfo()

	local gob = EpsilonLib.GameObject:GetSelected()
	if not gob then
		sysMsg('No Object Selected. Cannot Apply Rotations.')
		return
	end
	gob:Rotate(rots.x, rots.y, rots.z)
end

local function rotPresetCallback(content)
	if not content then return sysMsg("No Rot Preset Content Selected?") end
	local currData = gobRotationControls:GetRotationInfo(true)
	local rotX, rotY, rotZ = (content.RotX or currData.RotX), (content.RotY or currData.RotY), (content.RotZ or currData.RotZ)
	gobRotationControls:SetRotationInfo(rotX, rotY, rotZ, true)
	--f.DistanceControls.SetDimensions(content.Length, content.Width, content.Height, content.Scale)
end
local function rotSaveCollector()
	return gobRotationControls:GetRotationInfo(true)
end
gobRotationControls.SaveLoadPresetButton = CreatePresetSaveLoadButton("Rot", gobRotationControls, "TOPLEFT", gobRotationControls, nil, 6, 0, rotPresetCallback, rotSaveCollector)


--#region Game Object Scale Controls

-- Create a control group for scale controls
--local gobScaleControlsPullout, gobScaleControlsControls = CreateControlGroup(f, "Scale", 0, 0, 262, "SCALE", nil, true)

local gobScalePullout, gobScaleControls = CreateControlGroup(f, "GobScale", 0, 0, 50, "SCALE", nil, true)
--gobScaleControls:ClearAllPoints()
--gobScaleControls:SetPoint("BOTTOM")
--gobScaleControls.bg = CreateControlGroupBG(gobScaleControls, 4)

local scaleSlider = CreateSimpleSlider(gobScaleControls, "Scale", 0.1, 10, 0.1, 1, 130, 17, "Scale")
scaleSlider:SetPoint("TOPLEFT", 12, -10)
scaleSlider.Text:ClearAllPoints()
scaleSlider.Text:SetPoint("BOTTOM", scaleSlider, "TOP", 0, 0)
scaleSlider.Text:SetFontObject("GameFontNormalSmall")
scaleSlider.High:ClearAllPoints()
scaleSlider.High:SetPoint("BOTTOMRIGHT", scaleSlider, "TOPRIGHT", 4, 0)
scaleSlider.Low:ClearAllPoints()
scaleSlider.Low:SetPoint("BOTTOMLEFT", scaleSlider, "TOPLEFT", -4, 0)

do
	local eb = CreateFrame("EditBox", nil, gobScaleControls, "ObjectToolboxEditBoxNoLabelTemplate")
	eb:SetSize(40, 20)
	eb:SetPoint("LEFT", scaleSlider, "RIGHT", 10, 1)
	eb:SetAutoFocus(false)
	eb:SetText("1")
	eb:SetScript("OnTextChanged", function(...)
		editBoxNumberValidate(...)
		invalidatePresetSelected()
	end)
	eb:HookScript("OnEditFocusLost", function(self)
		local value = tonumber(self:GetText())
		if value then
			if value < 0 then value = 0 end -- Prevent negative scale values
			self:SetText(round(value, 4))
			scaleSlider:SetValue(value) -- Update the slider when the edit box value changes
		else
			self:SetText("1")      -- Reset to default if invalid input
		end

		if self.lastVal and self.lastVal == value then
			return -- No change, skip applying scale
		end
		self.lastVal = value

		local gob = EpsilonLib.GameObject:GetSelected()
		if not gob then return end -- No object selected, skip applying scale
		gob:SetScale(value)
	end)
	eb:HookScript("OnDisable", function(self)
		self:SetTextColor(Colors.disabled:GetRGB())
	end)
	eb:HookScript("OnEnable", function(self)
		self:SetTextColor(Colors.white:GetRGB())
	end)
	gobScaleControls.ScaleEditBox = eb
end

scaleSlider:SetScript("OnValueChanged", function(self, value, userInput)
	if not userInput then return end -- Only update if the user is dragging the slider

	-- Ignore if we didn't change the value
	if self.lastVal and self.lastVal == value then
		return -- No change, skip applying scale
	end
	self.lastVal = value

	-- Update the edit box when the slider value changes
	gobScaleControls.ScaleEditBox:SetText(round(value, 4))
	local gob = EpsilonLib.GameObject:GetSelected()
	if not gob then return end -- No object selected, skip applying scale
	gob:SetScale(value)
end)

scaleSlider:SetScript("OnDisable", function(self)
	self.Text:SetFontObject("GameFontDisableSmall")
	gobScaleControls.ScaleEditBox:Disable()
end)
scaleSlider:SetScript("OnEnable", function(self)
	self.Text:SetFontObject("GameFontNormalSmall")
	gobScaleControls.ScaleEditBox:Enable()
end)

gobScaleControls.GetCurrentScaleButton = ChainWrap(createGetAutoUpdateHybridButton(gobScaleControls, "Scale", "autoUpdateScale",
		function()
			local object = EpsilonLib.GameObject:GetSelected()
			if not object then
				sysMsg("No object selected. Select an Object First.")
				return
			end

			local scale = object:GetScale()
			scaleSlider:SetValue(scale)
			gobScaleControls.ScaleEditBox:SetText(round(scale, 4))
		end,
		"Update the Scale slider to the values on the currently selected object.\n\rIf Auto-Update is enabled, this will automatically update the scale valuse whenever an object is selected.",
		function()
			local object = EpsilonLib.GameObject:GetSelected()
			if not object then return end -- No object selected, skip applying scale
			object:SetScale(scaleSlider:GetValue())
		end
	))
	:SetPoint("TOP", gobScaleControls.ScaleEditBox, "BOTTOM", -3, 0)
	:SetSize(40, 16)


--#endregion

--#region Game Object Tint Controls
--local gobTintControls = gobTabControls.TintControls
--gobTabControls:ShowTab("Tint") -- Show the Tint tab by default // Dev usage mostly, this should be commented out for release
local gobTintPullout, gobTintControls = CreateControlGroup(f, "Tint", 0, 0, 140, "TINT / OVERLAY", nil, true)

local colorSliderFrame = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
colorSliderFrame.realParent = gobTintControls
colorSliderFrame:SetSize(225, 110)
colorSliderFrame:SetBackdrop(epsi_rollout_backdrop)
colorSliderFrame:SetBackdropColor(classicPopoutSliderFrameColor:GetRGBA())
colorSliderFrame:SetBackdropBorderColor(classicPopoutSliderFrameColor:GetRGBA())
colorSliderFrame:SetPoint("RIGHT", colorSliderFrame.realParent, "LEFT", 4, 0)
colorSliderFrame:Hide()

colorSliderFrame.realParent:HookScript("OnHide", function(self)
	if colorSliderFrame:IsShown() then
		colorSliderFrame:Hide() -- Close the popout if the main controls are hidden
	end
end)

do
	local frame = colorSliderFrame
	local animGroup = frame:CreateAnimationGroup()
	local animInSpeed = 0.2
	local slide = animGroup:CreateAnimation("Translation")
	local offset = 200
	slide:SetDuration(animInSpeed)
	slide:SetSmoothing("OUT")
	slide:SetOffset(-offset, 0)
	slide:SetOrder(1)

	local fade = animGroup:CreateAnimation("Alpha")
	fade:SetDuration(animInSpeed)
	fade:SetFromAlpha(0)
	fade:SetToAlpha(1)
	fade:SetOrder(1)

	animGroup:SetToFinalAlpha(true)
	animGroup:SetScript("OnPlay", function(self)
		slide:SetOffset(-offset, 0)
		frame:SetAlpha(0)
		frame:SetPoint("RIGHT", frame.realParent, "LEFT", 4 + offset, 0) -- Start offscreen (right)
		frame:SetShown(true)
	end)

	animGroup:SetScript("OnFinished", function(self)
		frame:SetAlpha(1)
		frame:SetPoint("RIGHT", frame.realParent, "LEFT", 4, 0) -- ensure it's back in place after
		if self.isReverse then
			frame:Hide()                                  -- Hide the frame after sliding out
		end
	end)

	frame:SetScript("OnShow", function()
		animGroup:Stop()
		animGroup:Play()
	end)

	frame:SetScript("OnHide", function()
		animGroup:Stop()
	end)

	function frame:Open()
		animGroup:Stop()
		animGroup.isReverse = false
		animGroup:Play()
		frame:Show()
	end

	function frame:Close()
		animGroup:Stop()
		animGroup.isReverse = true
		animGroup:Play(true)
	end

	function frame:Toggle()
		if self:IsShown() then self:Close() else self:Open() end
	end
end

-- Convert RGB (0-1) to Hex
local function RGBToHex(r, g, b)
	return string.format("#%02X%02X%02X", r * 255, g * 255, b * 255)
end

local function CreateColorPickerControlGroup(parent, name)
	local group = parent

	---Sets all the color fields in the group to the specified RGBAS values. Optionally skips updating the color wheel.
	---@param r integer red value (0-1)
	---@param g integer green value (0-1)
	---@param b integer blue value (0-1)
	---@param a? integer alpha value (0-100) or nil
	---@param s? integer saturation value (0-100) or nil
	---@param skipWheel? boolean
	local function SetColorFields(r, g, b, a, s, skipWheel)
		group.RBox:SetText(string.format("%.0f", r * 100))
		group.GBox:SetText(string.format("%.0f", g * 100))
		group.BBox:SetText(string.format("%.0f", b * 100))
		if a and not group.ASlider:IsDraggingThumb() then
			if a <= 1 then a = a * 100 end -- stupid protection for if we pass it on 0-1 space
			group.ABox:SetText(string.format("%.0f", a))
			group.ASlider:SetValue(a)
		end
		if s and not group.SSlider:IsDraggingThumb() then
			if s <= 1 then s = s * 100 end -- stupid protection for if we pass it on 0-1 space
			group.SBox:SetText(string.format("%.0f", s))
			group.SSlider:SetValue(100 - s)
		end
		group.HexBox:SetText(RGBToHex(r, g, b))

		if not skipWheel and not group.ColorSelect.isSelecting then
			-- Update the wheel but assume we've validated fine already, so avoid the double-tap set
			group.ColorSelect.isUpdating = true
			group.ColorSelect:SetColorRGB(r, g, b)
			group.ColorSelect.isUpdating = false
		end

		-- slider popouts
		group.ColorSliders.Red:SetValue(r * 100)
		group.ColorSliders.Green:SetValue(g * 100)
		group.ColorSliders.Blue:SetValue(b * 100)

		invalidatePresetSelected()
	end
	group.SetColorFields = SetColorFields

	local rgba = { "R", "G", "B", "A", "S" }
	local function getColTable()
		local col = {}
		for i = 1, #rgba do
			local key = rgba[i]
			col[key:lower()] = tonumber(group[key .. "Box"]:GetText())
		end
		return col
	end

	local function UpdateColorFields(apply)
		local col = getColTable()
		SetColorFields(col.r / 100, col.g / 100, col.b / 100, col.a, col.s)
		invalidatePresetSelected()

		if apply then
			group.ApplyColorToGob()
		end
	end

	function group.SetColorInfo(info, apply)
		SetColorFields(info.r / 100, info.g / 100, info.b / 100, info.a, info.s)
		if info.mode then
			group.ColorModeRadio:SetSelected(info.mode)
		end

		if apply then
			group.ApplyColorToGobThrottled()
		end
	end

	function group.GetColorInfo()
		local colorInfo = getColTable()
		colorInfo.mode = group.ColorModeRadio:GetSelected()
		return colorInfo
	end

	function group.ApplyColorToGob()
		local colorInfo = group.GetColorInfo()
		local gob = EpsilonLib.GameObject:GetSelected()
		if gob == nil then
			return
		end
		--Syntax: .gobject tint #r #g #b [#s] [#t]
		--Syntax: .gobject overlay #r #g #b [#s] [#t]

		if colorInfo.s == 0 then
			return -- Cannot handle Sat 0
		end

		gob:SetColor(colorInfo.mode, colorInfo.r, colorInfo.g, colorInfo.b, colorInfo.a, colorInfo.s)
		--cmd(("gobject %s %s %s %s %s %s"):format(colorInfo.mode, colorInfo.r, colorInfo.g, colorInfo.b, colorInfo.s, colorInfo.a))
	end

	-- Create the ColorSelect widget
	local cs = CreateFrame("ColorSelect", nil, group)
	cs:SetPoint("TOPLEFT", 8, -8)
	cs:SetSize(113, 100) -- includes value bar
	group.ColorSelect = cs
	cs:EnableMouse(true)

	cs:HookScript("OnMouseDown", function(self)
		self.isSelecting = true
	end)
	cs:HookScript("OnMouseUp", function(self)
		self.isSelecting = false
	end)

	-- Color wheel
	local wheel = cs:CreateTexture()
	wheel:SetSize(100, 100)
	wheel:SetPoint("TOPLEFT", 0, 0)
	cs:SetColorWheelTexture(wheel)

	local wheelThumb = cs:CreateTexture()
	wheelThumb:SetTexture("Interface/Buttons/UI-ColorPicker-Buttons")
	wheelThumb:SetSize(10, 10)
	wheelThumb:SetTexCoord(0, 0.15625, 0, 0.625)
	cs:SetColorWheelThumbTexture(wheelThumb)

	-- Value bar
	local valueBar = cs:CreateTexture()
	valueBar:SetSize(8, 100)
	valueBar:SetPoint("LEFT", wheel, "RIGHT", 5, 0)
	cs:SetColorValueTexture(valueBar)

	local valueThumb = cs:CreateTexture()
	valueThumb:SetTexture("Interface/Buttons/UI-ColorPicker-Buttons")
	valueThumb:SetSize(16, 14)
	valueThumb:SetTexCoord(0.25, 1.0, 0, 0.875)
	cs:SetColorValueThumbTexture(valueThumb)

	cs:SetColorRGB(1, 1, 1) -- Default red

	cs.isUpdating = false
	cs.lastApplyColor = 0
	cs._ApplyColorThrottle = nil
	local throttle_delay = 0.1

	function group.ApplyColorToGobThrottled(self)
		local self = self or cs
		local now = GetTime()
		local elapsed = now - self.lastApplyColor
		if elapsed >= throttle_delay then
			self.lastApplyColor = now
			group.ApplyColorToGob()
		else
			if self._ApplyColorThrottle then
				self._ApplyColorThrottle:Cancel() -- Cancel any existing throttle timer, trashing that scheduled set color
			end
			self._ApplyColorThrottle = C_Timer.NewTimer(throttle_delay - elapsed, function()
				self.lastApplyColor = GetTime()
				group.ApplyColorToGob()
				self._ApplyColorThrottle = nil
			end)
		end
	end

	cs:SetScript("OnColorSelect", function(self, r, g, b)
		if self.isUpdating then return end -- prevent recursion from the internal quantified values
		self.isUpdating = true

		local r, g, b = roundToStep(r, 0.05), roundToStep(g, 0.05), roundToStep(b, 0.05)
		self:SetColorRGB(r, g, b)
		SetColorFields(r, g, b, nil, nil, true)
		group.ApplyColorToGobThrottled(self)

		self.isUpdating = false
	end)

	function cs:SetSaturation(val)
		val = 1 - val
		wheel:SetDesaturation(val)
		valueBar:SetDesaturation(val)
	end

	-- RGB Sliders, but these are tucked into our class color popout frame
	group.ColorSliders = {}
	for i, color in ipairs({ "Red", "Green", "Blue" }) do
		local slider = GenColorSlider(colorSliderFrame, color, group)
		local offsetY = ((i - 1) * 32)
		slider:SetPoint("TOPLEFT", 12, -20 - offsetY)
		group.ColorSliders[color] = slider
	end

	-- Alpha slider
	local alphaSlider = CreateFrame("Slider", nil, cs, "OptionsSliderTemplate")
	alphaSlider:SetOrientation("VERTICAL")
	alphaSlider:SetSize(9, 100)
	alphaSlider:SetPoint("BOTTOMLEFT", valueBar, "BOTTOMRIGHT", 7, -4)
	alphaSlider:SetHitRectInsets(-2, -2, 0, 0)
	alphaSlider:SetMinMaxValues(0, 100)
	alphaSlider:SetValueStep(20)
	alphaSlider:SetObeyStepOnDrag(true)
	alphaSlider:SetValue(0)
	alphaSlider.Text:SetText("T")
	alphaSlider.Text:SetPoint("BOTTOM", alphaSlider, "TOP", 0, -2)
	alphaSlider.Text:SetFontObject("GameFontNormalTiny")
	alphaSlider.Text:SetTextColor(1, 1, 1)
	_setSliderToIgnoreSetValueWhenDragging(alphaSlider)
	group.ASlider = alphaSlider

	alphaSlider.Low:Hide()
	alphaSlider.High:Hide()

	local setValue = alphaSlider.SetValue
	function alphaSlider:SetValue(value, ...)
		value = 100 - value -- invert
		setValue(self, value, ...)
	end

	local getValue = alphaSlider.GetValue
	function alphaSlider:GetValue()
		return 100 - getValue(alphaSlider)
	end

	alphaSlider:SetScript("OnValueChanged", function(self, val, userInput)
		if not userInput then return end
		--val = 100 - val -- inverse for the slider direction.. ugh
		group.ABox:SetText(100 - (val))

		if self.lastVal and self.lastVal == val then
			return -- No change, skip applying color
		end
		self.lastVal = val
		invalidatePresetSelected()
		group.ApplyColorToGobThrottled()
	end)

	local satSlider = CreateFrame("Slider", nil, cs, "OptionsSliderTemplate")
	satSlider:SetOrientation("VERTICAL")
	satSlider:SetSize(9, 100)
	satSlider:SetPoint("BOTTOMLEFT", alphaSlider, "BOTTOMRIGHT", 4, 0)
	satSlider:SetHitRectInsets(-2, -2, 0, 0)
	satSlider:SetMinMaxValues(0, 80)
	satSlider:SetValueStep(20)
	satSlider:SetObeyStepOnDrag(true)
	satSlider:SetValue(100)
	satSlider.Low:Hide()
	satSlider.High:Hide()
	satSlider.Text:SetText("S")
	satSlider.Text:SetPoint("BOTTOM", satSlider, "TOP", 0, -2)
	satSlider.Text:SetFontObject("GameFontNormalTiny")
	satSlider.Text:SetTextColor(1, 1, 1)
	_setSliderToIgnoreSetValueWhenDragging(satSlider)
	group.SSlider = satSlider

	satSlider:SetScript("OnValueChanged", function(self, val, userInput)
		if not userInput then return end
		val = 100 - val -- inverse for the slider direction.. ugh
		group.SBox:SetText(val)

		cs:SetSaturation(val / 100)

		if self.lastVal and self.lastVal == val then
			return -- No change, skip applying color
		end
		self.lastVal = val

		invalidatePresetSelected()
		group.ApplyColorToGobThrottled()
	end)

	-- Hex box under the wheel
	--local hexBox = CreateFrame("EditBox", nil, group, "ObjectToolboxEditBoxNoLabelTemplate")
	local hexBox = CreateSimpleEditBox(nil, group, "BOTTOMLEFT", "BOTTOMLEFT", 10, 0)
	hexBox:SetSize(80, 20)
	hexBox:SetAutoFocus(false)
	hexBox:SetMaxLetters(9)
	hexBox:SetText("#FF0000")
	--	hexBox:SetPoint("BOTTOMLEFT", 10, 0)
	group.HexBox = hexBox

	--[[
	local hexLabel = hexBox:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	hexLabel:SetText("Hex")
	hexLabel:SetPoint("BOTTOMLEFT", hexBox, "TOPLEFT", 0, 2)
	--]]

	hexBox:HookScript("OnEditFocusLost", function(self)
		local hex = self:GetText():gsub("#", "")
		local valid = hex:match("^[%x]+$") and (#hex == 6 or #hex == 8)

		if not valid then
			self:SetTextColor(1, 0, 0, 1)
			return
		end

		self:SetTextColor(1, 1, 1, 1)

		local r = roundToStep(tonumber(hex:sub(1, 2), 16) / 255, 0.05)
		local g = roundToStep(tonumber(hex:sub(3, 4), 16) / 255, 0.05)
		local b = roundToStep(tonumber(hex:sub(5, 6), 16) / 255, 0.05)
		local a = (#hex == 8 and tonumber(hex:sub(7, 8), 16) / 255) or (alphaSlider:GetValue())

		if a <= 1 then a = a * 100 end
		cs:SetColorRGB(r, g, b)
		SetColorFields(r, g, b, a, 100)

		if self.lastVal and self.lastVal == self:GetText() then
			return -- No change, skip applying color
		end
		self.lastVal = self:GetText()
		group.ApplyColorToGob()
	end)

	-- Vertical RGBA and S boxes on the right
	local tabList = {}
	for i, key in ipairs(rgba) do
		local box = CreateFrame("EditBox", nil, group, "InputBoxTemplate")
		box:SetSize(30, 20)
		box:SetAutoFocus(false)
		box:SetMaxLetters(3)
		box:SetNumeric(true)
		box:SetText("100")
		box.key = key

		tinsert(tabList, box)
		box.tabList = tabList
		box:HookScript("OnTabPressed", function(self) _editBox_HandleTabbing(self, self.tabList) end)

		local label = box:CreateFontString(nil, "OVERLAY", "GameFontNormalTiny")
		box.Label = label
		label:SetText(key)

		local y = -((i - 1) * 22)
		box:SetPoint("TOPRIGHT", group, "TOPRIGHT", -6, y)
		label:SetPoint("CENTER", box, "LEFT", -7, 0)

		box:SetScript("OnEditFocusLost", function(self)
			local val
			if self.key == "S" or self.key == "A" then
				val = roundToStep(self:GetText(), 20)
				self:SetText(val)
			else
				val = roundToStep(self:GetText(), 5)
				self:SetText(val)
			end

			if self.lastVal and self.lastVal == val then
				return -- No change, skip applying color
			end
			self.lastVal = val

			UpdateColorFields(true)
		end)
		box:SetScript("OnEnterPressed", EditBox_ClearFocus) -- Clear focus on Enter key, use OnEditFocusLost for further handling

		box:HookScript("OnDisable", function(self)
			self:SetTextColor(Colors.disabled:GetRGB())
		end)
		box:HookScript("OnEnable", function(self)
			self:SetTextColor(Colors.white:GetRGB())
		end)

		group.ColorEditBoxes = group.ColorEditBoxes or {}
		table.insert(group.ColorEditBoxes, box)
		group[key .. "Box"] = box
	end
	group["ABox"].Label:SetText("T")

	local radioData = {
		{ name = "overlay", label = "Overlay", callback = group.ApplyColorToGob },
		{ name = "tint",    label = "Tint",    callback = group.ApplyColorToGob },
	}
	local _, radios = CreateRadioButtons(group, "ColorModeRadio", radioData)
	radios.overlay:SetPoint("BOTTOMRIGHT", group, "BOTTOMRIGHT", -50, 0)
	radios.tint:SetPoint("RIGHT", radios.overlay, "LEFT", -25, 0)
	radios.tint:SetChecked(true)

	local colorSliderPopoutButton = CreateFrame("Button", nil, group)
	colorSliderPopoutButton:SetSize(16, 16)
	colorSliderPopoutButton:SetPoint("BOTTOMLEFT", group, "BOTTOMLEFT", 8, 20)
	colorSliderPopoutButton.tooltipText = "Open a pop-out for classic color sliders."
	colorSliderPopoutButton.tooltipTitle = "Color Sliders"
	EpsilonLib.Utils.Misc.SetupCoherentButtonTextures(colorSliderPopoutButton, ASSET_PATH .. "OMSliders")
	addTooltipHandlers(colorSliderPopoutButton, true)
	colorSliderPopoutButton:SetFrameLevel(cs:GetFrameLevel() + 1)
	group.ColorSliderPopoutButton = colorSliderPopoutButton

	colorSliderPopoutButton:SetScript("OnClick", function(self)
		colorSliderFrame:Toggle()
	end)


	local function colorPresetCallback(content)
		if not content then return sysMsg("No Color Preset Content Selected?") end
		group.SetColorInfo(content, true)
		-- TODO: FIX THAT THIS IS USING THE VALUES *100 WTF -- i tthink fixed?
		--invalidatePresetSelected() -- Don't save this one, colors change too much
	end
	local colorSaveLoadPresetButton = CreatePresetSaveLoadButton("Color", group, "TOPLEFT", group, nil, 6, 2, colorPresetCallback, group.GetColorInfo)
	group.SaveLoadPresetButton = colorSaveLoadPresetButton
	colorSaveLoadPresetButton:SetFrameLevel(cs:GetFrameLevel() + 1)


	function group:SetEnabledState(enabled, gob)
		alphaSlider:SetEnabled(enabled)
		satSlider:SetEnabled(enabled)
		hexBox:SetEnabled(enabled)

		local color = gob and gob.color or { red = 1, green = 1, blue = 1, alpha = 100, saturation = 100 }

		cs:EnableMouse(enabled)
		cs:SetSaturation(enabled and (color.saturation / 100) or 0.1)

		self.ColorModeRadio.tint:SetEnabled(enabled)
		self.ColorModeRadio.overlay:SetEnabled(enabled)

		for k, v in ipairs(group.ColorEditBoxes) do
			v:SetEnabled(enabled)
		end

		for k, v in pairs(group.ColorSliders) do
			v:SetEnabled(enabled)
		end
	end

	SetColorFields(1, 1, 1, 100, 100)

	return group
end

local colorGroup = CreateColorPickerControlGroup(gobTintControls, "Color")
f.GetColorInfo = colorGroup.GetColorInfo -- shortcut

gobTintControls.GetCurrentColorButton = ChainWrap(createGetAutoUpdateHybridButton(gobTintControls, "Tint/Overlay", "autoUpdateColor",
		function()
			local object = EpsilonLib.GameObject:GetSelected()
			if not object then
				sysMsg("No object selected. Select an Object First.")
				return
			end

			if object.isGroup then return end -- Groups don't have color info, skip without warning

			if not object.color then
				sysMsg("Selected object has no color information.")
				return
			end

			local hasTint = tonumber(object.HasTint)
			local mode = hasTint and ((hasTint == 1) and "tint" or "overlay")

			colorGroup.SetColorInfo({
				r = object.color.red,
				g = object.color.green,
				b = object.color.blue,
				a = object.color.alpha,
				s = object.color.saturation,
				mode = mode
			})
		end,
		"Update the Tint / Overlay Info to the values on the currently selected object.\n\rIf Auto-Update is enabled, this will automatically update the color section whenever an object is selected.",
		function()
			colorGroup.ApplyColorToGob()
		end
	))
	:SetPoint("TOP", colorGroup.SBox, "BOTTOM", -4, 0)
	:SetSize(40, 16)

--[[
gobTintControls.ApplyColorButton = ChainWrap(CreateFrame("Button", nil, gobTintControls, "UIPanelButtonTemplate"))
	:SetSize(40, 20)
	:RegisterForClicks("LeftButtonUp", "RightButtonUp")
	:SetNormalFontObject("GameFontNormalSmall")
	:SetDisabledFontObject("GameFontDisableSmall")
	:SetHighlightFontObject("GameFontHighlightSmall")
	:SetText("Apply")
	:SetPoint("RIGHT", gobTintControls.GetCurrentColorButton:Unwrap(), "LEFT", 0, 0)

gobTintControls.ApplyColorButton.tooltipTitle = "Apply Color"
gobTintControls.ApplyColorButton.tooltip = EpsilonLib.Utils.Tooltip.ReplaceTags("{left-click-text-icon} : Apply Current Color to Selected Object")
gobTintControls.ApplyColorButton.tooltipWrap = true
addTooltipHandlers(gobTintControls.ApplyColorButton)

gobTintControls.ApplyColorButton:SetScript("OnClick", function()
	colorGroup.ApplyColorToGob()
end)
--]]

--#endregion


-- #region Game Object Advanced Controls
local gobBottomSpacerPlaceholder = CreateControlGroup(f, "GobAdvanced", 0, 0, 4)
--[[
local gobAdvancedControls = CreateControlGroup(f, "GobAdvanced", 0, 8, 48)
gobAdvancedControls.bg = CreateControlGroupBG(gobAdvancedControls, -2)

local advancedControls = {
	{ name = "Add to Group",            icon = ASSET_PATH .. "icons/eps_om_icon_groupadd" },
	{ name = "Remove from Group",       icon = ASSET_PATH .. "icons/eps_om_icon_groupremove" },
	{ name = "Promote to Group Leader", icon = ASSET_PATH .. "icons/eps_om_icon_groupleader" },

}

local advancedActionButtons = CreateCenteredIconButtons(gobAdvancedControls, advancedControls, 32, 4)
--]]
--#endregion

--#region Game Object Delete Button Group
--[[
local gobDeleteControls = CreateControlGroup(f, "GobDelete", 0, -6, 32)

local gobDeleteButton = CreateFrame("Button", nil, gobDeleteControls, "SharedGoldRedButtonSmallTemplate")
gobDeleteButton:SetSize(120, 20)
gobDeleteButton:SetText("Delete Object")
gobDeleteButton:SetPoint("TOP", gobDeleteControls, "TOP", 0, -2)
gobDeleteButton:SetScript("OnClick", function()
	print("Delete button clicked. Implement deletion logic here.")
end)
gobDeleteControls.GobDeleteButton = gobDeleteButton

local gobHistoryButton = CreateFrame("Button", nil, gobDeleteControls, "SquareIconButtonTemplate")
gobHistoryButton:SetPoint("LEFT", gobDeleteButton, "RIGHT", 6, 0)
gobHistoryButton:SetAtlas("auctionhouse-icon-clock")
gobHistoryButton:SetTooltipInfo("Gobject History", "Open a history of objects you have selected, including deleted ones.")
gobHistoryButton:SetScript("OnClick", function()
	if not EpsilonLib then return end
	local frame = EpsilonLib.GameObject.GobLogFrame
	frame:SetShown(not frame:IsShown())
end)
--]]

--#endregion

--#region Mass Control of Controls based on Gob Selection Status

---Updates the object control state based on whether an object is selected or not.
---@param enabled boolean
---@param gob? GameObjectClass
function f:SetObjectSelected(enabled, gob, source)
	--gobBasicActionButtons._map.Select:SetEnabled(enabled)
	gobBasicActionButtons._map.Unselect:SetEnabled(enabled)
	gobEditActionButtons._map.GoTo:SetEnabled(enabled)
	gobEditActionButtons._map.Copy:SetEnabled(enabled)

	if enabled and gob then
		for btn, data in pairs(autoUpdateChecks) do
			if OPMasterTable.Options[data.key] then
				data.callback(gob, source)
			end
		end

		objectNameLabel:SetText(gob:GetName(true) or "Unknown Object")
	else
		objectNameLabel:SetText()
	end

	-- anything that needs permissions should go under this check:
	if not canEditObject(gob) then enabled = false end

	gobBasicActionButtons._map.Delete:SetEnabled(enabled)
	gobEditActionButtons._map.Replace:SetEnabled(enabled)
	gobEditActionButtons._map.Activate:SetEnabled(enabled)

	gobRotationControls:SetEnabledState(enabled, gob and gob.isGroup)
	scaleSlider:SetEnabled(enabled)
	colorGroup:SetEnabledState(enabled, gob)

	arrowButtons:CheckIfEnableValid()
end

--#endregion

local function injectSettingsToOldOMSettingsMenu()
	local menu = OPNewOptionsPanel
	local newMenuItem, lastMenuItem
	do
		local setting = "autoShow"
		lastMenuItem = OPAutoshowPopoutToggleButton
		newMenuItem = CreateFrame("CheckButton", nil, menu, "UICheckButtonTemplate")

		newMenuItem.text:SetText("Auto Show")
		newMenuItem:SetPoint("TOP", lastMenuItem, "BOTTOM", 0, 0)

		newMenuItem:SetScript("OnEnter", function(self)
			if OPMasterTable.Options["showTooltips"] then
				GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
				self.Timer = C_Timer.NewTimer(0.5, function()
					GameTooltip:SetText("Auto Show", nil, nil, nil, nil, true)
					GameTooltip:AddLine(" ")
					GameTooltip:AddLine("Automatically Show Building Tools menu when you load in.", 1, 1, 1, true)
					GameTooltip:Show()
				end)
			end
		end)
		newMenuItem:SetScript("OnLeave", function(self)
			GameTooltip_Hide()
			if self.Timer then self.Timer:Cancel() end
		end)
		connectButtonWithSavedOption(newMenuItem, setting)
		if OPMasterTable.Options[setting] then newMenuItem:SetChecked(true) end
	end

	do
		local setting = "fadePanel"
		lastMenuItem = newMenuItem
		newMenuItem = CreateFrame("CheckButton", nil, menu, "UICheckButtonTemplate")

		newMenuItem.text:SetText("Fade Panel")
		newMenuItem:SetPoint("TOP", lastMenuItem, "BOTTOM", 0, 0)

		newMenuItem:SetScript("OnEnter", function(self)
			if OPMasterTable.Options["showTooltips"] then
				GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
				self.Timer = C_Timer.NewTimer(0.5, function()
					GameTooltip:SetText("Fade Panel", nil, nil, nil, nil, true)
					GameTooltip:AddLine(" ")
					GameTooltip:AddLine("Fade the Building Tools panel out when not actively in focus.", 1, 1, 1, true)
					GameTooltip:Show()
				end)
			end
		end)
		newMenuItem:SetScript("OnLeave", function(self)
			GameTooltip_Hide()
			if self.Timer then self.Timer:Cancel() end
		end)
		connectButtonWithSavedOption(newMenuItem, setting)
		if OPMasterTable.Options[setting] then newMenuItem:SetChecked(true) end
	end
end


f:ResizeToFitChildren()
maxVisibleHeight = f:GetHeight() + 0.01
f:UpdateClamp(f:GetHeight())

--#region Event Management

local event_handlers = {
	EPSILON_OBJ_UPDATE = function(self, event, source, gob)
		local enabled = gob and true or false
		f:SetObjectSelected(enabled, gob, source)
	end,
	ADDON_LOADED = function(_, event, addonName)
		if addonName == ADDON_NAME then
			-- this is us!
			for k, v in ipairs(buttonUpdateMap) do
				local button = v.button
				local key = v.key

				local buttonType = button:GetObjectType()
				local buttonTypeData = frameTypeMap[buttonType]
				if not buttonTypeData then error(("The frame type %s is not supported in _setButtonToSavedOptionOnLoad yet. ADD SUPPORT!"):format(buttonType)) end

				local value = OPMasterTable.Options[key]
				if value ~= nil then -- only set if we actually had a saved value
					button[buttonTypeData.set](button, value)
				end
			end

			injectSettingsToOldOMSettingsMenu()

			-- update text on all getautobuttons
			for btn, data in pairs(autoUpdateChecks) do
				btn:RefreshText()
			end

			if not OPMasterTable.Options["autoShow"] then
				f:Hide()
			end
			EpsilonLib.EventManager:Remove(onAddonLoaded, "ADDON_LOADED")
		end
	end
}

for k, v in pairs(event_handlers) do
	EpsilonLib.EventManager:Register(k, v)
end

--#endregion

-- More Tools Module Management
ns.AddTool = registerToolModule
ns.AddedTools = additional_tools

-- Hotsteal the old OPPanelPopout
if OPPanelPopout then OPPanelPopout:SetPoint("RIGHT", f, "LEFT") end

-- SlashCommands:

BINDING_HEADER_OBJECTMANIP = "Object Mover"
SLASH_OM_SHOWCLOSE1, SLASH_OM_SHOWCLOSE2, SLASH_OM_SHOWCLOSE3 = "/obj", "/om", "/op"
function SlashCmdList.OM_SHOWCLOSE(old)
	if old == "" then old = nil end
	if old then
		if not OPMainFrame:IsShown() then
			OPMainFrame:Show()
		else
			OPMainFrame:Hide()
		end
	else
		f:Toggle()
	end
end

--[[ -- Example Pullout Usage
local f = CreateFrame("Frame", nil, UIParent)
f:SetPoint("TOP", 0, -100)
f:SetSize(140, 300)
f.bg = f:CreateTexture(nil, "BACKGROUND")
f.bg:SetColorTexture(0.5, 0, 0, 0.5)
f.bg:SetAllPoints()

function f:UpdateSize()
	local height = 20
	for k, v in ipairs({ self:GetChildren() }) do
		if v:IsShown() then height = height + v:GetHeight() end
	end

	self:SetHeight(height)
end

f.pullout1, f.content1 = genPulloutButton(f, "Rotations", 130, 200)
f.pullout1:SetPoint("TOP", 0, -10)

f.content1.title = f.content1:CreateFontString(nil, "OVERLAY", "GameFontNormal")
f.content1.title:SetText("Something Here")
f.content1.title:SetPoint("BOTTOM", 0, 20)

f.pullout2, f.content2 = genPulloutButton(f, "Tint / Overlay", 130, 200)
f.pullout2:SetPoint("TOP", f.pullout1, "BOTTOM")
f.content2.title = f.content2:CreateFontString(nil, "OVERLAY", "GameFontNormal")
f.content2.title:SetText("Tint Stuff Here")
f.content2.title:SetPoint("BOTTOM", 0, 20)
--]]
