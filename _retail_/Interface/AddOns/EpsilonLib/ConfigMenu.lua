local EpsilonLib, EpsiLib = ...



-- Extra Utils Config Menu
local EpsiLib_Interface_Panel = CreateFrame("Frame");
EpsiLib_Interface_Panel.name = "Epsilon (Misc)";

local panel = EpsiLib_Interface_Panel
local widget

local title = panel:CreateFontString("ARTWORK", nil, "GameFontNormalLarge")
title:SetPoint("TOP")
title:SetText("Epsilon - Miscellaneous Config")
title:SetPoint("TOPLEFT", 15, -15)

--[[
local resetGammaRayBarPosButton = CreateFrame("Button", nil, panel, "OptionsButtonTemplate")
resetGammaRayBarPosButton:SetPoint("TOPLEFT", 20, -40)
resetGammaRayBarPosButton:SetSize(256, 23)
resetGammaRayBarPosButton.Text:SetText("Reset GammaRay Toolbar Position")
resetGammaRayBarPosButton:SetScript("OnClick", function()

end)
--]]

widget = CreateFrame("SLIDER", nil, panel, "OptionsSliderTemplate")
panel.forceEntityLODDistanceSlider = widget
widget:SetPoint("TOPLEFT", 20, -60)
widget:SetSize(144, 17)
widget.Text:SetText("Force Entity LoD CVar")
widget.Low:SetText("0")
widget.High:SetText("200")
widget:SetMinMaxValues(0, 200)
widget:SetValueStep(1)
widget:SetScript("OnValueChanged", function(self, value, userInput)
	if not userInput then return end
	value = tonumber(value)
	if value == 0 then value = false end
	EpsiLib_DB.options.forceEntityLoD = value
	SetCVar("EntityLodDist", value)
end)

InterfaceOptions_AddCategory(EpsiLib_Interface_Panel);
InterfaceAddOnsList_Update()


local registerForAddonDataLoaded
function registerForAddonDataLoaded(_, event, addonName, containsBindings)
	if addonName ~= EpsilonLib then return end

	-- Run anything here you need to load default values into the config options
	local function updateEntityLoD()
		if EpsiLib_DB.options.forceEntityLoD then
			SetCVar("EntityLodDist", EpsiLib_DB.options.forceEntityLoD)
		end
		panel.forceEntityLODDistanceSlider:SetValue(EpsiLib_DB.options.forceEntityLoD and EpsiLib_DB.options.forceEntityLoD or 0)
	end
	C_Timer.After(0, updateEntityLoD)
	C_Timer.After(5, updateEntityLoD)

	-- Remove our hook
	EpsiLib.EventManager:Remove(registerForAddonDataLoaded, "ADDON_LOADED")
end

EpsiLib.EventManager:Register("ADDON_LOADED", registerForAddonDataLoaded)
