local LibRPMedia = LibStub:GetLibrary("LibRPMedia-1.0");
local EpsilonPhases = LibStub("AceAddon-3.0"):GetAddon("EpsilonPhases")

local EPSILON_PHASES_ICONS = {}
local filteredList = nil
local startOffset = 0

for _, name in LibRPMedia:FindAllIcons() do
	tinsert(EPSILON_PHASES_ICONS, name)
end

local iconPicker = CreateFrame("Frame", "EpsilonPhasesIconPicker", _G["EpsilonPhasesSettingsFrame"], "ButtonFrameTemplate")
iconPicker:EnableMouse()
iconPicker:SetSize(260, 320)
iconPicker:SetPoint("RIGHT", _G["EpsilonPhasesSettingsFrame"], "RIGHT", 260, 80)

local searchBox = CreateFrame("EditBox", "EpsilonPhasesIconPickerSearch", iconPicker, "SearchBoxTemplate")
searchBox:SetSize(150, 8)
searchBox:SetPoint("TOPLEFT", iconPicker, "TOPLEFT", 72, -42)

local selectorFrame = CreateFrame("Frame", "EpsilonPhasesIconPickerSelectorFrame", iconPicker)
selectorFrame:SetPoint("TOPLEFT", iconPicker, "TOPLEFT", 5, -5)
selectorFrame:SetPoint("BOTTOMRIGHT", iconPicker, "BOTTOMRIGHT", -5, 5)
selectorFrame:EnableMouseWheel(true)

local selectorFrameSlider = CreateFrame("Slider", "EpsilonPhasesIconPickerSelectorFrameSlider", selectorFrame, "UIPanelScrollBarTrimTemplate")
selectorFrameSlider:SetMinMaxValues(0, 1)
selectorFrameSlider:SetValueStep(3)
selectorFrameSlider:SetPoint("TOPRIGHT", iconPicker.Inset, "TOPRIGHT", 2, -16)
selectorFrameSlider:SetPoint("BOTTOMRIGHT", iconPicker.Inset, "BOTTOMRIGHT", 2, 14)
selectorFrameSlider:SetValueStep(1)
selectorFrameSlider.scrollStep = 4

local backgroundTexture = selectorFrameSlider:CreateTexture(nil, "BACKGROUND")
backgroundTexture:SetColorTexture(0, 0, 0, 0.25)

local function GetIconPath(button)
	if not button or not button.pickerIndex then
		return ""
	end

	local list = filteredList or EPSILON_PHASES_ICONS
	local texture = list[button.pickerIndex + startOffset]

	texture = texture
	return texture
end

local function OnIconClick(self)
	local icon = GetIconPath(self)
	local settingsFrameIconButton = _G["EpsilonPhasesSettingsIconChangeButton"]
	EpsilonPhases.SendAddonCommand("phase set icon " .. icon)
	EpsilonPhases.currentActivePhase.data.icon = icon
	EpsilonPhases.DrawPhases(EpsilonPhases.PrivatePhases)
	EpsilonPhases.WritePhaseDetailData(EpsilonPhases.currentActivePhase)
	settingsFrameIconButton:SetNormalTexture(EpsilonPhases.ICON_PATH .. EpsilonPhases.currentActivePhase.data.icon)
	iconPicker:Hide()
end

iconPicker.icons = {}
for y = 0, 6 do
	for x = 0, 6 do
		local btn = CreateFrame("Button", nil, selectorFrame)
		btn:SetSize(28, 28)
		btn:SetHighlightTexture("Interface/BUTTONS/ButtonHilight-Square", "ADD")
		btn:SetPoint("TOPLEFT", "EpsilonPhasesIconPickerInset", 32 * x + 5, -32 * y - 5)
		btn:SetSize(32, 32)
		btn:SetScript("OnClick", OnIconClick)

		table.insert(iconPicker.icons, btn)
		btn.pickerIndex = #iconPicker.icons
	end
end

local function RefreshGrid()
	local list = filteredList or EPSILON_PHASES_ICONS
	for k, v in ipairs(iconPicker.icons) do
		local tex = list[startOffset + k]
		if tex then
			v:Show()
			if tex:find("AddOns/") then
				tex = "Interface/" .. tex
			else
				tex = "Interface/Icons/" .. tex
			end

			v:SetNormalTexture(tex)
		else
			v:Hide()
		end
	end
end



local function ScrollChanged(value)
	-- Our "step" is 6 icons, which is one line.
	startOffset = math.floor(value) * 7
	RefreshGrid()
end

local function MouseScroll(delta)
	local a = selectorFrameSlider:GetValue() - delta
	selectorFrameSlider:SetValue(a)
end

local function RefreshScroll(reset)
	local list = filteredList or EPSILON_PHASES_ICONS
	local max = math.floor((#list - 42) / 7)
	if max < 0 then max = 0 end
	selectorFrameSlider:SetMinMaxValues(0, max)

	if reset then
		selectorFrameSlider:SetValue(0)
	end
	-- todo: does scroller auto clamp value?

	ScrollChanged(selectorFrameSlider:GetValue())
end
iconPicker.RefreshScroll = RefreshScroll

local function FilterChanged()
	local filter = searchBox:GetText():lower()
	if #filter < 3 then
		-- Ignore filters less than three characters
		if filteredList then
			filteredList = nil
			RefreshScroll()
			RefreshGrid()
		end
	else
		-- build new list
		filteredList = {}
		for k, v in ipairs(EPSILON_PHASES_ICONS) do
			if v:lower():find(filter) then
				table.insert(filteredList, v)
			end
		end
		RefreshScroll()
	end
end


selectorFrame:SetScript("OnMouseWheel", function(self, delta)
	MouseScroll(delta)
end)

selectorFrameSlider:SetScript("OnValueChanged", function(self, value)
	ScrollChanged(value)
end)

searchBox:SetScript("OnTextChanged", function(self)
	SearchBoxTemplate_OnTextChanged(self)
	FilterChanged()
end)

iconPicker:Hide()
