local EpsilonPhases = LibStub("AceAddon-3.0"):GetAddon("EpsilonPhases")
local linkPhase = EpsilonPhases.Utils.linkPhase
local isPhaseTemp = EpsilonPhases.Utils.isPhaseTemp

EpsilonPhasesMainFrame = CreateFrame("Frame", "EpsilonPhasesMainFrame", UIParent, "ButtonFrameTemplate")
EpsilonPhasesMainFrame:SetPoint("CENTER")
EpsilonPhasesMainFrame:SetSize(500, 657)
EpsilonPhasesMainFrame:SetMovable(true)
EpsilonPhasesMainFrame:SetToplevel(true)
EpsilonPhasesMainFrame:EnableMouse(true)
EpsilonPhasesMainFrame:SetTitle("Phase Codex")
ButtonFrameTemplate_HideButtonBar(EpsilonPhasesMainFrame)
EpsilonPhasesMainFrame:Hide()
EpsilonPhasesMainFrame:SetHyperlinksEnabled(true)
NineSliceUtil.ApplyLayoutByName(EpsilonPhasesMainFrame.NineSlice, "EpsilonGoldBorderFrameTemplate")

if EpsilonPhasesMainFrame.NineSlice then
    EpsilonPhasesMainFrame.NineSlice:SetFrameLevel(1)
  end

EpsilonPhasesMainFrameCloseButton:SetScript("OnClick", function()
    EpsilonPhasesMainFrame:Hide()
    EpsilonPhasesPhaseListFrame:Hide()
    _G["EpsilonPhasesSettingsFrame"]:Hide()
end)

EpsilonPhasesMainFrame:SetScript("OnHyperlinkClick",(function(self, link)
    local dialog = StaticPopup_Show("CLICK_LINK_CLICKURL", "", "", link)
end))

local titleBgColor = EpsilonPhasesMainFrame:CreateTexture(nil, "BACKGROUND")
titleBgColor:SetPoint("TOPLEFT", EpsilonPhasesMainFrame.TitleBg)
titleBgColor:SetPoint("BOTTOMRIGHT", EpsilonPhasesMainFrame.TitleBg)
titleBgColor:SetColorTexture(0.30, 0.10, 0.40, 0.5)

EpsilonPhasesMainFrame.TitleBgColor = titleBgColor

EpsilonPhasesMainFrame.TopTileStreaks:SetTexture(EpsilonPhases.ASSETS_PATH .. "/EpsiIndexBG")
EpsilonPhasesMainFrame.TopTileStreaks:SetVertexColor(0.45,0.45,0.45)

local background = EpsilonPhasesMainFrame.Inset.Bg
background:SetTexture(EpsilonPhases.ASSETS_PATH .. "/ManagerBG")
background:SetAllPoints()

local dragBar = CreateFrame("Frame", nil, EpsilonPhasesMainFrame)
dragBar:SetPoint("TOPLEFT")
dragBar:SetSize(700, 20)
dragBar:EnableMouse(true)
dragBar:RegisterForDrag("LeftButton")
dragBar:SetScript("OnMouseDown", function(self)
	self:GetParent():Raise()
end)
dragBar:SetScript("OnDragStart", function(self)
	self:GetParent():StartMoving()
end)
dragBar:SetScript("OnDragStop", function(self)
	self:GetParent():StopMovingOrSizing()
end)

local portrait = EpsilonPhasesMainFrame:CreateTexture(nil, "OVERLAY")
portrait:SetTexture(EpsilonPhases.ASSETS_PATH .. "/EpsilonTrayIconCodex.blp")
portrait:SetSize(64, 64)
portrait:SetPoint("CENTER", EpsilonPhasesMainFramePortrait, "CENTER", 0, 0)

EpsilonPhasesMainFrame.DragBar = dragBar

local prevButton = CreateFrame("Button", "prevButton", EpsilonPhasesMainFrame)
prevButton:SetSize(26, 26)
prevButton:SetPoint("TOPLEFT", EpsilonPhasesMainFrame, "TOPLEFT", 60, -30)
prevButton:SetNormalTexture(EpsilonPhases.ASSETS_PATH .. "/Glue-LeftArrow-Button-Up")
prevButton:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight", "ADD")
prevButton:SetScript("OnClick", function(self, button)
    EpsilonPhases.SetPreviousPhase()
end)

local nextButton = CreateFrame("Button", "nextButton", EpsilonPhasesMainFrame)
nextButton:SetSize(26, 26)
nextButton:SetPoint("TOPLEFT", EpsilonPhasesMainFrame, "TOPLEFT", 90, -30)
nextButton:SetNormalTexture(EpsilonPhases.ASSETS_PATH .. "/Glue-RightArrow-Button-Up")
nextButton:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight", "ADD")
nextButton:SetScript("OnClick", function(self, button)
    EpsilonPhases.SetNextPhase()
end)

local refreshButton = CreateFrame("Button", "refreshButton", EpsilonPhasesMainFrame, nil)
refreshButton:SetSize(30, 30)
refreshButton:SetPoint("TOPRIGHT", EpsilonPhasesMainFrame, "TOPRIGHT", -10, -30)
refreshButton:SetNormalTexture(EpsilonPhases.ASSETS_PATH .. "/EpsiLoginWPEngineButtonRefresh")
refreshButton:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight", "ADD")
refreshButton:SetScript("OnClick", function(self, button)
    EpsilonPhases.SetScrollbarValue(0)
    EpsilonPhases.GetPublicPhases()
end)
refreshButton:SetScript("OnEnter", function(self, button)
    local GameTooltip = _G["GameTooltip"]
    GameTooltip:SetOwner(self, "ANCHOR_CURSOR");
    GameTooltip:ClearLines();
    GameTooltip:SetText("Refresh public phases")
    GameTooltip:Show()
end)

refreshButton:SetScript("OnLeave", function(self, button)
    local GameTooltip = _G["GameTooltip"]
    GameTooltip:Hide()
end)

local settingsButton = CreateFrame("Button", "EpsilonPhasesMainFrameSettingsButton", EpsilonPhasesMainFrame)
settingsButton:SetSize(25, 25)
settingsButton:SetNormalTexture(EpsilonPhases.ASSETS_PATH .. "/CodexSettings")
settingsButton:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight", "ADD")
settingsButton:SetPoint("TOPRIGHT", EpsilonPhasesMainFrame, "TOPRIGHT", -40, -33)
settingsButton:SetScript("OnClick", function(self, button)
    EpsilonPhases:showHideSettings()
end)
settingsButton:SetScript("OnEnter", function(self, button)
    local GameTooltip = _G["GameTooltip"]
    GameTooltip:SetOwner(self, "ANCHOR_CURSOR");
    GameTooltip:ClearLines();
    GameTooltip:SetText("Edit")
    GameTooltip:Show()
end)
settingsButton:SetScript("OnLeave", function(self, button)
    local GameTooltip = _G["GameTooltip"]
    GameTooltip:Hide()
end)

local shareButton = CreateFrame("Button", "EpsilonPhasesMainFrameShareButton", EpsilonPhasesMainFrame)
shareButton:SetSize(25, 25)
shareButton:SetNormalTexture(EpsilonPhases.ASSETS_PATH .. "/CodexShare")
shareButton:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight", "ADD")
shareButton:SetPoint("RIGHT", settingsButton, "LEFT")
shareButton:SetScript("OnClick", function(self, button)
    linkPhase(EpsilonPhases.currentActivePhase)
end)
shareButton:SetScript("OnEnter", function(self, button)
    local GameTooltip = _G["GameTooltip"]
    GameTooltip:SetOwner(self, "ANCHOR_CURSOR");
    GameTooltip:ClearLines();
    GameTooltip:SetText("Share Phase")
    GameTooltip:Show()
end)
shareButton:SetScript("OnLeave", function(self, button)
    local GameTooltip = _G["GameTooltip"]
    GameTooltip:Hide()
end)


local saveButton = CreateFrame("Button", "EpsilonPhasesMainFrameSaveButton", EpsilonPhasesMainFrame)
saveButton:SetSize(25, 25)
saveButton:SetNormalTexture(EpsilonPhases.ASSETS_PATH .. "/CodexSave")
saveButton:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight", "ADD")
saveButton:SetPoint("RIGHT", shareButton, "LEFT")

saveButton:SetScript("OnEnter", function(self, button)
    local GameTooltip = _G["GameTooltip"]
    GameTooltip:SetOwner(self, "ANCHOR_CURSOR");
    GameTooltip:ClearLines();
    GameTooltip:SetText("Save Phase")
    GameTooltip:Show()
end)
saveButton:SetScript("OnLeave", function(self, button)
    local GameTooltip = _G["GameTooltip"]
    GameTooltip:Hide()
end)

local addPhaseButton = CreateFrame("Button", nil, EpsilonPhasesMainFrame)
addPhaseButton:SetSize(25,25)
addPhaseButton:SetNormalTexture(EpsilonPhases.ASSETS_PATH .. "/CodexAdd")
addPhaseButton:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight", "ADD")
addPhaseButton:SetPoint("RIGHT", saveButton, "LEFT")
addPhaseButton:SetScript("OnClick", function(self)
    StaticPopup_Show("ADD_PHASE");
end)

local removePhaseButton = CreateFrame("Button", "EpsilonPhasesMainFrameRemovePhaseButton", EpsilonPhasesMainFrame)
removePhaseButton:SetSize(25,25)
removePhaseButton:SetNormalTexture(EpsilonPhases.ASSETS_PATH .. "/CodexDelete")
removePhaseButton:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight", "ADD")
removePhaseButton:SetPoint("RIGHT", addPhaseButton, "LEFT")
removePhaseButton:SetScript("OnClick", function(self)
    StaticPopup_Show("REMOVE_PHASE", EpsilonPhases.currentActivePhase:GetPhaseName(), "", EpsilonPhases.currentActivePhase:GetPhaseID())
end)
local autoJoinButton = CreateFrame("CheckButton", nil, EpsilonPhasesMainFrame, "ChatConfigCheckButtonTemplate")
autoJoinButton:SetSize(32, 32)
autoJoinButton.tooltip = "Join phase on login"
autoJoinButton:SetPoint("RIGHT", removePhaseButton, "LEFT")
autoJoinButton:SetScript("OnClick", function(self)
    if self:GetChecked() then
        EpsilonPhases.db.global.HomePhase = EpsilonPhases.currentActivePhase:GetPhaseID()
        EpsilonPhases.HomePhase = EpsilonPhases.currentActivePhase:GetPhaseID()
    else 
        EpsilonPhases.db.global.HomePhase = nil
        EpsilonPhases.HomePhase = nil
    end
end)

local function SetSettingsButtonEnable()
    if  (EpsilonPhases.currentActivePhase ~= nil and EpsilonPhases.currentActivePhase.data.id == tonumber(C_Epsilon:GetPhaseId())) and (C_Epsilon:IsOwner()) then
        settingsButton:GetNormalTexture():SetDesaturated(false)
        settingsButton:Enable()
    else
        settingsButton:GetNormalTexture():SetDesaturated(true)
        settingsButton:Disable()
    end
end

local function SetSaveButtonEnable()
    if (isPhaseTemp(EpsilonPhases.currentActivePhase)) then
        saveButton:GetNormalTexture():SetDesaturated(false)
        saveButton:Enable()
    else
        saveButton:GetNormalTexture():SetDesaturated(true)
        saveButton:Disable()
    end
end

saveButton:SetScript("OnClick", function(self, button)
    EpsilonPhases.addPrivatePhase(EpsilonPhases.currentActivePhase:GetPhaseID(), true)
    if EpsilonPhases.currentActivePhase:GetPhaseID() == EpsilonPhases.previousTempPhase then
        EpsilonPhases.previousTempPhase = nil
    end
    SetSaveButtonEnable()
end)

EpsilonPhases.SetSettingsButtonEnable = SetSettingsButtonEnable

SetSettingsButtonEnable()

local detailsFrameRing = EpsilonPhasesMainFrame:CreateTexture(nil, "OVERLAY")
detailsFrameRing:SetTexture(EpsilonPhases.ASSETS_PATH .. "/EpsiLoginWPEngineEpsilonFrameRing")
detailsFrameRing:SetVertTile(false)
detailsFrameRing:SetHorizTile(false)
detailsFrameRing:SetSize(64, 64)
detailsFrameRing:SetPoint("TOP", EpsilonPhasesMainFrame.Inset, "TOP", 0, -30)

local detailsFrameRingDecorationLeft = EpsilonPhasesMainFrame:CreateTexture(nil, "OVERLAY")
detailsFrameRingDecorationLeft:SetTexture(EpsilonPhases.ASSETS_PATH .. "/EpsiLoginWPEngineEpsilonFrameLeft")
detailsFrameRingDecorationLeft:SetVertTile(false)
detailsFrameRingDecorationLeft:SetHorizTile(false)
detailsFrameRingDecorationLeft:SetPoint("TOP", EpsilonPhasesMainFrame.Inset, "TOP", -94, -25)

local detailsFrameRingDecorationRight = EpsilonPhasesMainFrame:CreateTexture(nil, "OVERLAY")
detailsFrameRingDecorationRight:SetTexture(EpsilonPhases.ASSETS_PATH .. "/EpsiLoginWPEngineEpsilonFrameRight")
detailsFrameRingDecorationRight:SetVertTile(false)
detailsFrameRingDecorationRight:SetHorizTile(false)
detailsFrameRingDecorationRight:SetPoint("TOP", EpsilonPhasesMainFrame.Inset, "TOP", 94, -25)

local detailsFrameIcon = EpsilonPhasesMainFrame:CreateTexture(nil, "ARTWORK")
detailsFrameIcon:SetTexture(236757)
detailsFrameIcon:SetSize(64, 64)
detailsFrameIcon:SetPoint("TOP", EpsilonPhasesMainFrame.Inset, "TOP", 0, -30)

local detailsFrameIconMask = EpsilonPhasesMainFrame:CreateMaskTexture()
detailsFrameIconMask:SetTexture("Interface\\CHARACTERFRAME\\TempPortraitAlphaMask")  -- Blizzard's standard runde Maske
detailsFrameIconMask:SetAllPoints(detailsFrameIcon)

detailsFrameIcon:AddMaskTexture(detailsFrameIconMask)

local ringAndNameSeparator = EpsilonPhasesMainFrame:CreateTexture(nil, "OVERLAY")
ringAndNameSeparator:SetTexture(EpsilonPhases.ASSETS_PATH .. "/EpsiLoginWPEnginePageBreak")
ringAndNameSeparator:SetVertTile(false)
ringAndNameSeparator:SetHorizTile(false)
ringAndNameSeparator:SetPoint("TOP", detailsFrameIcon, "BOTTOM", 0, -5)

local phaseName = EpsilonPhasesMainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
phaseName:SetJustifyH("CENTER")
phaseName:SetPoint("TOP", ringAndNameSeparator, "BOTTOM", 0, -2)
phaseName:SetText("Phase ID - Phase Name")

local nameAndDetailsSeparator = EpsilonPhasesMainFrame:CreateTexture(nil, "OVERLAY")
nameAndDetailsSeparator:SetTexture(EpsilonPhases.ASSETS_PATH .. "/EpsiLoginWPEnginePageBreak")
nameAndDetailsSeparator:SetVertTile(false)
nameAndDetailsSeparator:SetHorizTile(false)
nameAndDetailsSeparator:SetPoint("TOP", phaseName, "BOTTOM", 0, -4)

local hostedByAndDetailsSeparator = EpsilonPhasesMainFrame:CreateTexture(nil, "OVERLAY")
hostedByAndDetailsSeparator:SetTexture(EpsilonPhases.ASSETS_PATH .. "/EpsiLoginWPEnginePageBreak")
hostedByAndDetailsSeparator:SetVertTile(false)
hostedByAndDetailsSeparator:SetHorizTile(false)
hostedByAndDetailsSeparator:SetPoint("TOP", nameAndDetailsSeparator, "BOTTOM", 0, -20)

local phaseDescription = EpsilonPhasesMainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
phaseDescription:SetJustifyH("CENTER")
phaseDescription:SetJustifyV("MIDDLE")
phaseDescription:SetPoint("TOP", nameAndDetailsSeparator, "BOTTOM", 0, 0)
phaseDescription:SetPoint("BOTTOM", hostedByAndDetailsSeparator, "TOP", 0, 0)
phaseDescription:SetWidth(350)
phaseDescription:SetWordWrap(false)
phaseDescription:SetTextColor(1,1,1,1)
phaseDescription:SetText("Type of Roleplay")


local tags = EpsilonPhasesMainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
tags:SetTextScale(0.9)
tags:SetJustifyH("CENTER")
tags:SetJustifyV("CENTER")
tags:SetWidth(400)
tags:SetPoint("TOP", hostedByAndDetailsSeparator, "BOTTOM")
tags:SetWordWrap(true)

local details = EpsilonPhasesMainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
details:SetPoint("TOP", hostedByAndDetailsSeparator, "TOP", 0, -100)
details:SetTextColor(255,255,255)
details:SetText("Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet.")
details:SetWidth(400)
details:SetWordWrap(true)
details:SetNonSpaceWrap(true)
details:SetTextScale(1.1)

local BigJoinButton = CreateFrame("Button", nil, EpsilonPhasesMainFrame)
BigJoinButton:SetSize(200, 50)
BigJoinButton:SetNormalTexture(EpsilonPhases.ASSETS_PATH .. "/ManagerButton")
BigJoinButton:SetPushedTexture(EpsilonPhases.ASSETS_PATH .. "/ManagerButtonPressed")
BigJoinButton:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight", "ADD")
BigJoinButton:SetPoint("BOTTOM", EpsilonPhasesMainFrame.Inset, "BOTTOM")
BigJoinButton.text = BigJoinButton:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
BigJoinButton.text:SetPoint("CENTER", BigJoinButton, "CENTER")
BigJoinButton.text:SetJustifyH("CENTER")
BigJoinButton.text:SetText("JOIN")
BigJoinButton:SetScript("OnClick", function(self, button)
    EpsilonPhases.JoinPhase(EpsilonPhases.currentActivePhase)
end)

local settingsButtonDecoration = EpsilonPhasesMainFrame:CreateTexture(nil, "OVERLAY")
settingsButtonDecoration:SetTexture(EpsilonPhases.ASSETS_PATH .. "/EpsiIndexFavourite.blp")
settingsButtonDecoration:SetScale(1.2)
settingsButtonDecoration:SetVertTile(false)
settingsButtonDecoration:SetHorizTile(false)
settingsButtonDecoration:SetPoint("CENTER", BigJoinButton, "CENTER", 0, 40)

local cornerCosmeticTopRight = EpsilonPhasesMainFrame:CreateTexture(nil, "OVERLAY")
cornerCosmeticTopRight:SetTexture(EpsilonPhases.ASSETS_PATH .. "/CornerTopRight")
cornerCosmeticTopRight:SetPoint("TOPRIGHT", EpsilonPhasesMainFrame.Inset, "TOPRIGHT", -2, -6)

local cornerCosmeticTopLeft = EpsilonPhasesMainFrame:CreateTexture(nil, "OVERLAY")
cornerCosmeticTopLeft:SetTexture(EpsilonPhases.ASSETS_PATH .. "/CornerTopLeft")
cornerCosmeticTopLeft:SetPoint("TOPLEFT", EpsilonPhasesMainFrame.Inset, "TOPLEFT", 2, -6)

local cornerCosmeticBottomRight = EpsilonPhasesMainFrame:CreateTexture(nil, "OVERLAY")
cornerCosmeticBottomRight:SetTexture(EpsilonPhases.ASSETS_PATH .. "/CornerBottomRight")
cornerCosmeticBottomRight:SetPoint("BOTTOMRIGHT", EpsilonPhasesMainFrame.Inset, "BOTTOMRIGHT", -2, 6)

local cornerCosmeticBottomLeft = EpsilonPhasesMainFrame:CreateTexture(nil, "OVERLAY")
cornerCosmeticBottomLeft:SetTexture(EpsilonPhases.ASSETS_PATH .. "/CornerBottomLeft")
cornerCosmeticBottomLeft:SetPoint("BOTTOMLEFT", EpsilonPhasesMainFrame.Inset, "BOTTOMLEFT", 2, 6)

local function WritePhaseDetailData(phase)
    local r, g, b = phase:GetPhaseColor():GetRGB()
    local tagsString = ""
    for _, v in pairs(phase:GetPhaseTags()) do
        tagsString = tagsString .. v .." | "
    end
    local info = phase:GetPhaseInfo()
    local colour = phase:GetPhaseColor()
    local colourString = colour:GenerateHexColorMarkup()

    info = info:gsub('(http://)([^%s]+)', colourString .. '|H%1%2|h%2|h|r')
    info = info:gsub('(https://)([^%s]+)', colourString .. '|H%1%2|h%2|h|r')
    tagsString = tagsString:sub(1, -3)
    detailsFrameIcon:SetTexture(EpsilonPhases.ICON_PATH .. phase.data.icon)
    phaseName:SetText(phase.data.name)
    tags:SetText(tagsString)
    details:SetText(info)
    details:SetPoint("TOP", tags, "BOTTOM", 0, -20)
    phaseDescription:SetText(phase:GetPhaseDescription())
    ringAndNameSeparator:SetVertexColor(r,g,b)
    nameAndDetailsSeparator:SetVertexColor(r,g,b)
    hostedByAndDetailsSeparator:SetVertexColor(r,g,b)
    cornerCosmeticTopRight:SetVertexColor(r,g,b)
    cornerCosmeticTopLeft:SetVertexColor(r,g,b)
    cornerCosmeticBottomRight:SetVertexColor(r,g,b)
    cornerCosmeticBottomLeft:SetVertexColor(r,g,b)

    if phase:GetPhaseID() == EpsilonPhases.HomePhase then
        autoJoinButton:SetChecked(true)
    else
        autoJoinButton:SetChecked(false)
    end

    SetSettingsButtonEnable()
    SetSaveButtonEnable()
end

EpsilonPhases.WritePhaseDetailData = WritePhaseDetailData