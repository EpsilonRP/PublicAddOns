local EpsilonPhases = LibStub("AceAddon-3.0"):GetAddon("EpsilonPhases")
local AceGUI = LibStub("AceGUI-3.0")
local calcBackground = EpsilonPhases.Utils.calcBackground

local settingsFrame = CreateFrame("Frame", "EpsilonPhasesSettingsFrame", UIParent,
	"ButtonFrameTemplate")

local currentTagColor = nil

local sendAddonCmd = EpsilonPhases.SendAddonCommand
local function selectBackground(key)
	local backgroundID = key.value
	sendAddonCmd("phase set adbgicon " .. backgroundID)
	EpsilonPhases.currentActivePhase.data.bg = backgroundID
	EpsilonPhases.DrawPhases(EpsilonPhases.PrivatePhases)
end

local function sendPhaseInfo(detailsInput)
	local text = detailsInput:GetText()
	if #text == 0 then
		return
	end
	if #text > 200 then
		sendAddonCmd("phase set info init " .. string.sub(text, 1, 200))
		for i = 201, math.min(#text, 800), 201 do
			sendAddonCmd("phase set info append " .. string.sub(text, i, i + 200))
		end
	else
		sendAddonCmd("phase set info init " .. text)
	end
	EpsilonPhases.currentActivePhase.data.info = text
	EpsilonPhases.WritePhaseDetailData(EpsilonPhases.currentActivePhase)
end

settingsFrame:SetSize(250, 600)
settingsFrame:SetPoint("TOPRIGHT", EpsilonPhasesMainFrame, "TOPRIGHT", 251, 0)
settingsFrame.Inset.Bg:SetTexture(EpsilonPhases.ASSETS_PATH .. "/ManagerBG")
settingsFrame:SetToplevel(true)
ButtonFrameTemplate_HidePortrait(settingsFrame)
ButtonFrameTemplate_HideAttic(settingsFrame)
ButtonFrameTemplate_HideButtonBar(settingsFrame)
NineSliceUtil.ApplyLayoutByName(settingsFrame.NineSlice, "EpsilonGoldBorderFrameTemplateNoPortrait")
settingsFrame:Hide()

local colorPickerFrame = _G["ColorPickerFrame"]

--[[
local hexInput = CreateFrame("EditBox", nil, colorPickerFrame, 'InputBoxInstructionsTemplate')
hexInput:SetSize(73, 22)
hexInput:SetPoint("BOTTOMRIGHT", colorPickerFrame, "BOTTOMRIGHT", -23, 44)
hexInput:SetMaxBytes(7)
hexInput:SetAutoFocus(false)
hexInput:SetCursorPosition(0)
hexInput:Hide()

hexInput:SetScript("OnEnterPressed", function(self)
	local text = self:GetText();
	local length = string.len(text);
	if length == 0 then
		self:SetText("ffffff");
	elseif length < 6 then
		local startingText = text;
		while length < 6 do
			for i = 1, #startingText do
				local char = startingText:sub(i, i);
				text = text .. char;

				length = length + 1;
				if length == 6 then
					break;
				end
			end
		end
		self:SetText(text);
	end

	-- Update color to match string.
	-- Add alpha values to the end to be correct format.
	local color = CreateColorFromHexString("ff" .. self:GetText());
	_G["ColorPickerFrame"]:SetColorRGB(color:GetRGB());
end)


local hexLabel = hexInput:CreateFontString('Label', "OVERLAY", "GameFontNormal")
hexLabel:SetText("Hex Code")
hexLabel:SetPoint("CENTER", hexInput, "TOP")
hexLabel:SetJustifyH("CENTER")
--]]

local titleBgColor = settingsFrame:CreateTexture(nil, "BACKGROUND")
titleBgColor:SetPoint("TOPLEFT", settingsFrame.TitleBg)
titleBgColor:SetPoint("BOTTOMRIGHT", settingsFrame.TitleBg)
titleBgColor:SetColorTexture(0.30, 0.10, 0.40, 0.5)

local iconChangeButton = CreateFrame("Button", "EpsilonPhasesSettingsIconChangeButton", settingsFrame)
iconChangeButton:SetSize(64, 64)
iconChangeButton:SetPoint("TOPLEFT", settingsFrame, "TOPLEFT", 10, -30)
iconChangeButton:SetNormalTexture(134400)
iconChangeButton:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square", "ADD")
iconChangeButton:SetScript("OnClick", function()
	local returnfunc = function(icon)
		local icon = string.gsub(icon, 'Interface/Icons/', '')
		sendAddonCmd("phase set icon " .. icon)
		EpsilonPhases.currentActivePhase.data.icon = icon
		EpsilonPhases.DrawPhases(EpsilonPhases.PrivatePhases)
		EpsilonPhases.WritePhaseDetailData(EpsilonPhases.currentActivePhase)
		iconChangeButton:SetNormalTexture('Interface/Icons/' .. icon)
	end
	EpsilonLibIconPicker_Open(returnfunc, true, false, false, true):SetPoint("TOPLEFT", settingsFrame, "TOPRIGHT")
end)
settingsFrame.iconChangeButton = iconChangeButton

local phaseColorPickerLabel = settingsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
phaseColorPickerLabel:SetPoint("BOTTOM", iconChangeButton, "BOTTOM", 80, -25)
phaseColorPickerLabel:SetJustifyH("CENTER")
phaseColorPickerLabel:SetText("Phase Colour")

local phaseColorPicker = CreateFrame("Button", nil, settingsFrame)
phaseColorPicker:SetSize(64, 20)
phaseColorPicker:SetNormalTexture(EpsilonPhases.ASSETS_PATH .. "/InterfaceSwatch")
phaseColorPicker:SetPoint("BOTTOM", iconChangeButton, "BOTTOM", 80, -50)
phaseColorPicker:Show()
settingsFrame.phaseColorPicker = phaseColorPicker

local backgroundDropdownLabel = settingsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
backgroundDropdownLabel:SetJustifyH("CENTER")
backgroundDropdownLabel:SetPoint("TOPLEFT", iconChangeButton, "TOPLEFT", 70, -5)
backgroundDropdownLabel:SetText("Icon & Background")

local backgroundDropdown = AceGUI:Create("Dropdown")
backgroundDropdown:SetList(EpsilonPhases.PHASE_BACKGROUNDS)
backgroundDropdown:SetValue(1)
backgroundDropdown.frame:SetParent(settingsFrame)
backgroundDropdown.frame:SetSize(160, 20)
backgroundDropdown.frame:SetPoint("TOP", backgroundDropdownLabel, "BOTTOM", 20, -10)
backgroundDropdown.frame:Show()
backgroundDropdown:SetCallback("OnValueChanged", selectBackground)
settingsFrame.backgroundDropdown = backgroundDropdown

for i = 1, #EpsilonPhases.PHASE_BACKGROUNDS, 1 do
	local item = _G["AceGUI30DropDownItem" .. i]
	item:SetScript("OnEnter", function(self)
		local backgroundX, backgroundX2, backgroundY, backgroundY2 = calcBackground(i)

		local textureInfoTable = {
			width = 200,
			height = 72,
			margin = { left = 0, right = -8, top = 0, bottom = 0 }
		}
		local GameTooltip = _G["GameTooltip"]
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT", 20);
		GameTooltip:ClearLines();
		GameTooltip:AddLine(" ")
		if (i > 91) then
			GameTooltip:AddTexture(EpsilonPhases.ASSETS_PATH .. "/Backgrounds2.blp", textureInfoTable)
			_G["GameTooltipTexture1"]:SetTexture(EpsilonPhases.ASSETS_PATH .. "/Backgrounds2")
			_G["GameTooltipTexture1"]:SetTexCoord(backgroundX, backgroundX2, backgroundY, backgroundY2)
		else
			GameTooltip:AddTexture(EpsilonPhases.ASSETS_PATH .. "/Backgrounds1.blp", textureInfoTable)
			_G["GameTooltipTexture1"]:SetTexture(EpsilonPhases.ASSETS_PATH .. "/Backgrounds1")
			_G["GameTooltipTexture1"]:SetTexCoord(backgroundX, backgroundX2, backgroundY, backgroundY2)
		end
		GameTooltip:Show()
	end)
	item:SetScript("OnLeave", function()
		local GameTooltip = _G["GameTooltip"]
		GameTooltip:Hide()
	end)
end

local phaseTypeLabel = settingsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
phaseTypeLabel:SetJustifyH("CENTER")
phaseTypeLabel:SetPoint("BOTTOM", phaseColorPicker, "BOTTOM", 0, -30)
phaseTypeLabel:SetText("Type of Roleplay or Phase")

local phaseType = CreateFrame("EditBox", nil, settingsFrame, "InputBoxTemplate")
phaseType:SetSize(200, 10)
phaseType:SetPoint("TOP", phaseTypeLabel, "BOTTOM", 0, -20)
phaseType:SetAutoFocus(false)
phaseType:Show()

local detailsLabel = settingsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
detailsLabel:SetJustifyH("CENTER")
detailsLabel:SetPoint("TOP", phaseType, "BOTTOM", 0, -20)
detailsLabel:SetText("Information")

local details = CreateFrame("FRAME", "EpsilonPhasesSettingsFrameDetailsInput", settingsFrame,
	"EpsilonInputScrollTemplate")
details:SetSize(200, 140)
details:SetPoint("TOP", detailsLabel, "BOTTOM", 0, -20)
details:Show()

local tagsLabel = settingsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
tagsLabel:SetJustifyH("CENTER")
tagsLabel:SetPoint("BOTTOM", details, "BOTTOM", 0, -30)
tagsLabel:SetText("Tags")

local tagsInput = CreateFrame("EditBox", nil, settingsFrame, "InputBoxTemplate")
tagsInput:SetSize(190, 20)
tagsInput:SetPoint("BOTTOM", tagsLabel, "BOTTOM", -10, -30)
tagsInput:SetAutoFocus(false)
tagsInput:SetCursorPosition(0)

tagsInput:SetScript("OnEscapePressed", function(self)
	self:ClearFocus()
end)

local tagsButton = CreateFrame("Button", nil, settingsFrame)
tagsButton:SetSize(20, 20)
tagsButton:SetPoint("LEFT", tagsInput, "RIGHT")
tagsButton:SetNormalTexture(EpsilonPhases.ASSETS_PATH .. "/CodexAdd")
tagsButton:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight", "ADD")


local tagsColor = CreateFrame("Button", nil, settingsFrame)
tagsColor:SetSize(64, 20)
tagsColor:SetNormalTexture(EpsilonPhases.ASSETS_PATH .. "/InterfaceSwatch")
tagsColor:SetPoint("TOP", tagsInput, "BOTTOM")
tagsColor:Show()
settingsFrame.tagsColor = tagsColor

local function setupTags(phase)
	if phase == nil then return end
	local i = 1
	local currentLine = 1
	local currentLineLength = 0
	while _G["EpsilonPhasesSettingsFrameTag" .. i] ~= nil do
		_G["EpsilonPhasesSettingsFrameTag" .. i]:Hide()
		_G["EpsilonPhasesSettingsFrameTagButton" .. i]:Hide()
		i = i + 1
	end
	i = 1

	for tagIndex, tag in pairs(phase:GetPhaseTags()) do
		local tagFontString
		if _G["EpsilonPhasesSettingsFrameTag" .. i] == nil then
			tagFontString = settingsFrame:CreateFontString("EpsilonPhasesSettingsFrameTag" .. i, "OVERLAY",
				"GameTooltipText")
			local deleteButton = CreateFrame("Button", "EpsilonPhasesSettingsFrameTagButton" .. i, settingsFrame)
			deleteButton:SetPoint("CENTER", tagFontString, "TOPRIGHT", 2, 2)
			deleteButton:SetNormalTexture("Interface\\Buttons\\UI-GroupLoot-Pass-Up")
			deleteButton:SetSize(12, 12)
			deleteButton:Show()
			deleteButton:SetScript("OnClick", function()
				local dialog = StaticPopup_Show("DELETE_PHASE_TAG",
					EpsilonPhases.currentActivePhase:GetPhaseTags()[tagIndex])
				dialog.data = EpsilonPhases.currentActivePhase:GetRawPhaseTags()
				dialog.data2 = tagIndex
			end)
		else
			tagFontString = _G["EpsilonPhasesSettingsFrameTag" .. i];
			_G["EpsilonPhasesSettingsFrameTagButton" .. i]:Show()
			tagFontString:Show()
		end
		tagFontString:SetText(tag)
		if currentLineLength + tagFontString:GetWidth() > 180 then
			currentLine = currentLine + 1
			currentLineLength = 0
		end
		tagFontString:SetPoint("TOP", tagsColor, "BOTTOM", 0, 15 + (-20 * currentLine))
		tagFontString:SetPoint("LEFT", settingsFrame, "LEFT", currentLineLength + 10, 0)
		currentLineLength = currentLineLength + tagFontString:GetWidth() + 10

		i = i + 1
	end
end

local function addTag(success, data)
	if success then
		local tagString = string.match(data[1], 'CCFF(.+)|r')
		tinsert(EpsilonPhases.currentActivePhase.data.tags, tagString)
		setupTags(EpsilonPhases.currentActivePhase)
		EpsilonPhases.WritePhaseDetailData(EpsilonPhases.currentActivePhase)
	else
		UIErrorsFrame:AddMessage("The tag could not be added - maybe it contains forbidden characters?", 1.0, 0.0, 0.0,
			53, 5);
	end
end

local function sendTag(tagString)
	if currentTagColor ~= nil then
		if currentTagColor ~= nil then
			tagString = tagString .. '-' .. currentTagColor.r .. '-' .. currentTagColor.g .. '-' .. currentTagColor.b
		end
	end
	sendAddonCmd("phase set addtag " .. #EpsilonPhases.currentActivePhase:GetPhaseTags() + 1 .. " " .. tagString, addTag)
end

tagsInput:SetScript("OnEnterPressed", function(self)
	sendTag(self:GetText())
	self:SetText('')
end)

tagsInput:SetScript("OnTextChanged", function(self)
	local text = self:GetText()
	if text:match("[%sB]") ~= nil then
		self:SetText(text:gsub("%s+", ""))
	end
end)

tagsButton:SetScript("OnClick", function()
	sendTag(tagsInput:GetText())
	tagsInput:SetText('')
end)

tagsButton:SetScript("OnEnter", function(self)
	local tooltip = _G["GameTooltip"]
	tooltip:SetOwner(self, "ANCHOR_CURSOR");
	tooltip:ClearLines()
	tooltip:AddLine('Add Tag')
	tooltip:Show()
end)

tagsButton:SetScript('OnLeave', function()
	local tooltip = _G["GameTooltip"]
	tooltip:ClearLines()
	tooltip:Hide()
end)

StaticPopupDialogs["DELETE_PHASE_TAG"] = {
	text = "Are you sure you want to delete %s?",
	button1 = "Yes",
	button2 = "No",
	OnAccept = function(self, data, data2)
		local tag = data[data2]
		sendAddonCmd("phase set deltag " .. tag)
		table.remove(data, data2)
		setupTags(EpsilonPhases.currentActivePhase)
		EpsilonPhases.WritePhaseDetailData(EpsilonPhases.currentActivePhase)
	end,
	timeout = 0,
	whileDead = true,
	hideOnEscape = true,
}

local function setupFrame()
	iconChangeButton:SetNormalTexture(EpsilonPhases.ICON_PATH .. EpsilonPhases.currentActivePhase.data.icon)
	setupTags(EpsilonPhases.currentActivePhase)
	local r, g, b = EpsilonPhases.currentActivePhase:GetPhaseColor():GetRGB()
	settingsFrame.phaseColorPicker:GetNormalTexture():SetVertexColor(r, g, b)
	phaseType:SetText(EpsilonPhases.currentActivePhase:GetPhaseDescription())
	_G["EpsilonPhasesSettingsFrameDetailsInputScrollFrameEditBox"]:SetText(EpsilonPhases.currentActivePhase:GetPhaseInfo())
	settingsFrame.backgroundDropdown:SetValue(EpsilonPhases.currentActivePhase:GetPhaseBackground())
end

details.ScrollFrame.EditBox:SetScript("OnEnterPressed", function(self)
	if IsShiftKeyDown() then
		self:Insert("\n")
	else
		local type = self:GetText()
		if #type == 0 then
			print("You cant send empty phase info")
		end
		self:ClearFocus()
	end
end)

details.ScrollFrame.EditBox:SetScript("OnEditFocusLost", sendPhaseInfo)

phaseType:SetScript("OnEnterPressed", function(self)
	local type = self:GetText()
	if #type == 0 then
		print("You cant send an empty phase type")
	end
	self:ClearFocus()
end)

phaseType:SetScript("OnEditFocusLost", function(self)
	local type = self:GetText()
	if #type == 0 then
		return
	end
	EpsilonPhases.currentActivePhase.data.desc = type
	EpsilonPhases:RefreshPhases()
	sendAddonCmd("phase set description " .. type)
	EpsilonPhases.WritePhaseDetailData(EpsilonPhases.currentActivePhase)
end)

phaseColorPicker:SetScript("OnClick", function()
	--hexInput:Show()
	local function swatchFunc()
		local r, g, b = ColorPickerFrame:GetColorRGB();
		local color = CreateColor(r, g, b)
		--hexInput:SetText(color:GenerateHexColor():sub(3, 8))
		settingsFrame.phaseColorPicker:GetNormalTexture():SetVertexColor(r, g, b)
	end

	local ColorPickerOkayButton = _G["ColorPickerOkayButton"]
	local origOKButtonOnClick = ColorPickerOkayButton:GetScript("OnClick")

	local function cancelFunc()
		local r, g, b = EpsilonPhases.currentActivePhase:GetPhaseColor():GetRGB()
		settingsFrame.phaseColorPicker:GetNormalTexture():SetVertexColor(r, g, b)
		_G["ColorPickerOkayButton"]:SetScript("OnClick", origOKButtonOnClick)
		--hexInput:Hide()
	end

	ColorPickerOkayButton:SetScript("OnClick", function(self)
		local r, g, b = ColorPickerFrame:GetColorRGB()
		r, g, b = CreateColor(r, g, b):GetRGBAsBytes()
		local uintColor = (r * 2 ^ 24) + (g * 2 ^ 16) + (b * 2 ^ 8) + 0
		sendAddonCmd("phase set adbgcolor " .. uintColor)
		EpsilonPhases.currentActivePhase.data.color = uintColor
		EpsilonPhases.DrawPhases(EpsilonPhases.PrivatePhases)
		EpsilonPhases.WritePhaseDetailData(EpsilonPhases.currentActivePhase)

		_G["ColorPickerFrame"]:Hide()
		self:SetScript("OnClick", origOKButtonOnClick)
		--hexInput:Hide()
	end)

	local r, g, b = EpsilonPhases.currentActivePhase:GetPhaseColor():GetRGB()

	local options = {
		swatchFunc = swatchFunc,
		opacityFunc = nil,
		cancelFunc = cancelFunc,
		hasOpacity = false,
		opacity = 0,
		r = r,
		g = g,
		b = b,
	};

	OpenColorPicker(options)
end)

tagsColor:SetScript("OnClick", function()
	tagsColor:SetNormalTexture(EpsilonPhases.ASSETS_PATH .. "/InterfaceSwatch")
	--hexInput:Show()

	local function swatchFunc()
		local r, g, b = ColorPickerFrame:GetColorRGB();
		local color = CreateColor(r, g, b)
		--hexInput:SetText(color:GenerateHexColor():sub(3, 8))
		settingsFrame.tagsColor:GetNormalTexture():SetVertexColor(r, g, b)
	end

	local function cancelFunc()
		currentTagColor = nil
		tagsColor:SetNormalTexture(EpsilonPhases.ASSETS_PATH .. "/InterfaceSwatch")
		settingsFrame.tagsColor:GetNormalTexture():SetVertexColor(255, 255, 255)
		_G["ColorPickerOkayButton"]:SetScript("OnClick", function()
			_G["ColorPickerFrame"]:Hide()
		end)
		--hexInput:Hide()
	end

	_G["ColorPickerOkayButton"]:SetScript("OnClick", function(self)
		local r, g, b = ColorPickerFrame:GetColorRGB()
		r, g, b = CreateColor(r, g, b):GetRGBAsBytes()
		currentTagColor = { r = r, g = g, b = b }

		_G["ColorPickerFrame"]:Hide()
		self:SetScript("OnClick", function()
			_G["ColorPickerFrame"]:Hide()
		end)
		--hexInput:Hide()
	end)

	if currentTagColor ~= nil then
		r = currentTagColor.r
		g = currentTagColor.g
		b = currentTagColor.b
	else
		r = 255
		g = 255
		b = 255
	end

	local options = {
		swatchFunc = swatchFunc,
		opacityFunc = nil,
		cancelFunc = cancelFunc,
		hasOpacity = false,
		opacity = 0,
		r = r,
		g = g,
		b = b,
	};

	OpenColorPicker(options)
end)

function EpsilonPhases:showHideSettings()
	if settingsFrame:IsVisible() then
		settingsFrame:Hide()
	else
		setupFrame()
		settingsFrame:Show()
	end
end
