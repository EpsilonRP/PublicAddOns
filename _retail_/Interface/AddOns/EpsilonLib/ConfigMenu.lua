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
widget.High:SetText("500")
widget.Value = widget:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
widget.Value:SetPoint("TOP", widget, "BOTTOM")
widget:SetMinMaxValues(0, 500)
widget:SetValueStep(1)
widget:SetObeyStepOnDrag(true)
widget:SetScript("OnValueChanged", function(self, value, userInput)
	if not userInput then return end
	value = tonumber(value)
	if value == 0 then value = false end
	EpsiLib_DB.options.forceEntityLoD = value
	SetCVar("EntityLodDist", value)
	self.Value:SetText(value)
end)

InterfaceOptions_AddCategory(EpsiLib_Interface_Panel);
InterfaceAddOnsList_Update()


local registerForAddonDataLoaded
function registerForAddonDataLoaded(_, event, addonName, containsBindings)
	if addonName ~= EpsilonLib then return end

	-- Run anything here you need to load default values into the config options
	local onLoads = {
		{
			name = "forceEntityLoD",
			func = function()
				if EpsiLib_DB.options.forceEntityLoD then
					SetCVar("EntityLodDist", EpsiLib_DB.options.forceEntityLoD)
				end
				local val = (EpsiLib_DB.options.forceEntityLoD and EpsiLib_DB.options.forceEntityLoD or 0)
				panel.forceEntityLODDistanceSlider.Value:SetText(val)
				panel.forceEntityLODDistanceSlider:SetValue(val)
			end
		},
	}

	local funcs = {}
	for k, v in ipairs(onLoads) do
		if v.func then
			table.insert(funcs, v.func)
		end
	end
	C_Timer.After(0, function() for k, v in ipairs(funcs) do v() end end)
	C_Timer.After(5, function() for k, v in ipairs(funcs) do v() end end)

	-- Remove our hook
	EpsiLib.EventManager:Remove(registerForAddonDataLoaded, "ADDON_LOADED")
end

EpsiLib.EventManager:Register("ADDON_LOADED", registerForAddonDataLoaded)
