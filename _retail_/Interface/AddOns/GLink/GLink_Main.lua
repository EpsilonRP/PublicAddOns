addonName, GLink = ...;
GLink.settings = {}
GLink_debugging = GLink_debugging or false;
GLink.settings.addonMessageMode = true;

local phases, EPSILON_PHASES = ...
local EpsiLib = EpsilonLib;


GLink_UI = CreateFrame("FRAME", addonName, UIParent, "ButtonFrameTemplate")
GLink_UI:Hide()
GLink_UI:SetWidth(340)
GLink_UI:SetPoint("CENTER")
GLink_UI:EnableMouse(true)
GLink_UI:SetAttribute("UIPanelLayout-area", "left")
GLink_UI:SetAttribute("UIPanelLayout-defined", true)
GLink_UI:SetAttribute("UIPanelLayout-enabled", true)
GLink_UI:SetAttribute("UIPanelLayout-pushable", 3)
GLink_UI:SetAttribute("UIPanelLayout-whileDead", true)
GLink_UI:SetAttribute("UIPanelLayout-width", GLink_UI:GetWidth())
GLink_UI.portrait:SetTexture("Interface\\AddOns\\Epsilon\\Epsilon_Icon")
GLink_UI:SetScript("OnShow", function()
	PlaySoundFile("igCharacterInfoTab");
end)
GLink_UI:SetScript("OnHide", function()
	PlaySoundFile("igMainMenuClose");
end)


local main = EpsiLib.Container
local container = EpsiLib.ContainerTemplate.Tabs.createTab("GLink", EpsiLib.Container);
local settings = EpsiLib.ContainerTemplate.Headers.createHeader("Links", container);

SLASH_GLINK1, SLASH_GLINK2 = '/glink', '/GLINK'
function SlashCmdList.GLINK()
	EpsiLib.ContainerTemplate.Tabs.setTab(main, container:GetID())
end



settings.middle = CreateFrame("FRAME", "settingsMiddle", settings)
settings.middle.clickableItemLinks = settings.middle:CreateFontString(nil, nil, "GameFontHighlightSmall")
settings.middle.clickableItemLinks:SetPoint("TOPLEFT", settings, 10, -15)
settings.middle.clickableItemLinks:SetText("Toggle Clickable Item Links")

settings.clickableItemLinks = CreateFrame("CHECKBUTTON", "toggleDebugRadio", settings.middle, "UIRadioButtonTemplate")
settings.clickableItemLinks:SetSize(15,15)
settings.clickableItemLinks:SetPoint("TOPLEFT", settings, 160, -13)

settings.clickableItemLinks:SetScript("OnClick", function(self)

    if self:GetChecked() then
        GLink_Settings.clickableItemLinks = true;
    else
        GLink_Settings.clickableItemLinks = false;
    end
    print("|cff00ccff[SETTINGS]|r GLink clickable item links: ", GLink_Settings.clickableItemLinks)
end)

settings.middle.clickableSpellLinks = settings.middle:CreateFontString(nil, nil, "GameFontHighlightSmall")
settings.middle.clickableSpellLinks:SetPoint("TOPLEFT", settings, 10, -36)
settings.middle.clickableSpellLinks:SetText("Change Colour")

settings.linkColour = CreateFrame("EDITBOX", "$parentEdit", settings.middle, "InputBoxTemplate")
settings.linkColour:SetSize(150,15)
settings.linkColour:SetPoint("TOPLEFT", settings, 160, -34)
settings.linkColour:SetAutoFocus(false);
settings.linkColour:SetScript("OnEnterPressed", function(self, event)
    local colour = self:GetText():match("(%x%x%x%x%x%x)"):upper();
    GLink_Settings.colour = "|cff"..colour;
    self:SetText(GLink_Settings.colour.. "" .. GLink_Settings.colour:gsub("|cff", ""):gsub("|r", ""))

end)
settings.linkColour:SetScript("OnEscapePressed", function(self)
    settings.linkColour:ClearFocus();
end)




local debugging = EpsiLib.ContainerTemplate.Headers.createHeader("Debug", container)
debugging.Middle = CreateFrame("FRAME", "debuggingMiddle", debugging)

debugging.Middle.label = debugging.Middle:CreateFontString(nil, nil, "GameFontHighlightSmall")
debugging.Middle.label:SetPoint("TOPLEFT", debugging, 10, -15)
debugging.Middle.label:SetText("Toggle GLink Debug")

debugging.ToggleDebug = CreateFrame("CHECKBUTTON", "toggleDebugRadio", debugging.Middle, "UIRadioButtonTemplate")
debugging.ToggleDebug:SetSize(15,15)
debugging.ToggleDebug:SetPoint("TOPLEFT", debugging, 130, -13)

debugging.ToggleDebug:SetChecked(GLink_debugging);
debugging.ToggleDebug:SetScript("OnClick", function(self)

    if self:GetChecked() then
        GLink_debugging = true;
    else
        GLink_debugging = false;
    end
    print("|cff00ccff[DEBUGGING]|r GLink", GLink_debugging)
end)

debugging.Middle.label2 = debugging.Middle:CreateFontString(nil, nil, "GameFontHighlightSmall")
debugging.Middle.label2:SetPoint("TOPLEFT", debugging, 10, -36)
debugging.Middle.label2:SetText("Toggle Epsilon Debug")

debugging.ToggleDebug2 = CreateFrame("CHECKBUTTON", "toggleDebugRadio", debugging.Middle, "UIRadioButtonTemplate")
debugging.ToggleDebug2:SetSize(15,15)

debugging.ToggleDebug2:SetPoint("TOPLEFT", debugging, 130, -34)
debugging.ToggleDebug2:SetChecked(Epsilon_debugging)
debugging.ToggleDebug2:SetScript("OnClick", function(self)

    if self:GetChecked() then
        Epsilon_debugging = true;
    else
        Epsilon_debugging = false;
    end
    print("|cff00ccff[DEBUGGING]|r Epsilon", Epsilon_debugging)
end)




--LOAD
local GLink_Startup = CreateFrame("FRAME");
GLink_Startup:RegisterEvent("ADDON_LOADED");
GLink_Startup:SetScript("OnEvent", function(self)
    settings.clickableItemLinks:SetChecked(GLink_Settings["clickableItemLinks"]);
    local colour = GLink_Settings.colour
    settings.linkColour:SetText(colour.. "" .. colour:gsub("|cff", ""):gsub("|r", ""))
    --settings.clickableSpellLinks:SetChecked(GLink_Settings["clickableSpellLinks"]);
end) 