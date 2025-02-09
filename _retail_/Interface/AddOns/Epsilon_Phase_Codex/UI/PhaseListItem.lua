local EpsilonPhases = LibStub("AceAddon-3.0"):GetAddon("EpsilonPhases")
local linkPhase = EpsilonPhases.Utils.linkPhase
local calcBackground = EpsilonPhases.Utils.calcBackground

local function CreatePhaseListItem(index, phase)

    local EpsilonPhasesPhaseListPhaseItem = CreateFrame("Button", "EpsilonPhasesPhaseListPhaseItem" .. index, EpsilonPhasesPhaseListFrame, nil)
    EpsilonPhasesPhaseListPhaseItem:SetSize(272, EpsilonPhases.PHASELIST_ITEM_HEIGHT)
    EpsilonPhasesPhaseListPhaseItem:SetNormalTexture(EpsilonPhases.ASSETS_PATH .. "/EpsiLoginWPEngineCorner-Box.blp")
    local r,g,b = phase:GetPhaseColor():GetRGB()
    EpsilonPhasesPhaseListPhaseItem:GetNormalTexture():SetVertexColor(r,g,b,1)
    EpsilonPhasesPhaseListPhaseItem.phase = phase


    EpsilonPhasesPhaseListPhaseItem.ActiveTexture = EpsilonPhasesPhaseListPhaseItem:CreateTexture(nil, "OVERLAY", 7)
    EpsilonPhasesPhaseListPhaseItem.ActiveTexture:SetSize(272, EpsilonPhases.PHASELIST_ITEM_HEIGHT)
    EpsilonPhasesPhaseListPhaseItem.ActiveTexture:SetPoint("CENTER", EpsilonPhasesPhaseListPhaseItem, "CENTER") 

    local backgroundX, backgroundX2, backgroundY, backgroundY2 = calcBackground(phase:GetPhaseBackground())

    local EpsilonPhasesPhaseListPhaseItemBackground = EpsilonPhasesPhaseListPhaseItem:CreateTexture(nil, "BACKGROUND")
    if (phase:GetPhaseBackground() > 91) then
        EpsilonPhasesPhaseListPhaseItemBackground:SetTexture(EpsilonPhases.ASSETS_PATH .. "/Backgrounds2")
    else
        EpsilonPhasesPhaseListPhaseItemBackground:SetTexture(EpsilonPhases.ASSETS_PATH .. "/Backgrounds1")
    end
    EpsilonPhasesPhaseListPhaseItemBackground:SetAllPoints()
    EpsilonPhasesPhaseListPhaseItemBackground:SetSize(272, EpsilonPhases.PHASELIST_ITEM_HEIGHT)
    EpsilonPhasesPhaseListPhaseItemBackground:SetTexCoord(backgroundX,  backgroundX2 ,backgroundY, backgroundY2  )
    EpsilonPhasesPhaseListPhaseItemBackground:SetAlpha(0.4)

    EpsilonPhasesPhaseListPhaseItem.background = EpsilonPhasesPhaseListPhaseItemBackground


    if index == 1 then
            EpsilonPhasesPhaseListPhaseItem:SetPoint("TOPLEFT", EpsilonPhasesPhaseListFrame.Inset, "TOPLEFT", 0, -10)
        else
            EpsilonPhasesPhaseListPhaseItem:SetPoint("BOTTOM", _G["EpsilonPhasesPhaseListPhaseItem" .. index-1], "BOTTOM", 0, -EpsilonPhases.PHASELIST_ITEM_HEIGHT)
    end

    local EpsilonPhasesPhaseListPhaseItemRing = EpsilonPhasesPhaseListPhaseItem:CreateTexture(nil, "OVERLAY")
    EpsilonPhasesPhaseListPhaseItemRing:SetTexture(EpsilonPhases.ASSETS_PATH .. "/EpsiLoginWPEngineEpsilonFrameRing")
    EpsilonPhasesPhaseListPhaseItemRing:SetSize(54, 54)
    EpsilonPhasesPhaseListPhaseItemRing:SetPoint("LEFT", EpsilonPhasesPhaseListPhaseItem, "LEFT", 13, 0)

    local EpsilonPhasesPhaseListPhaseItemIcon = EpsilonPhasesPhaseListPhaseItem:CreateTexture(nil, "ARTWORK")
    EpsilonPhasesPhaseListPhaseItemIcon:SetTexture(EpsilonPhases.ICON_PATH .. phase:GetPhaseIcon())
    EpsilonPhasesPhaseListPhaseItemIcon:SetSize(54, 54)
    EpsilonPhasesPhaseListPhaseItemIcon:SetPoint("LEFT", EpsilonPhasesPhaseListPhaseItem, "LEFT", 13, 0)

    EpsilonPhasesPhaseListPhaseItem.icon = EpsilonPhasesPhaseListPhaseItemIcon

    local EpsilonPhasesPhaseListPhaseItemIconMask = EpsilonPhasesPhaseListPhaseItem:CreateMaskTexture()
    EpsilonPhasesPhaseListPhaseItemIconMask:SetTexture("Interface\\CHARACTERFRAME\\TempPortraitAlphaMask")  -- Blizzard's standard runde Maske
    EpsilonPhasesPhaseListPhaseItemIconMask:SetAllPoints(EpsilonPhasesPhaseListPhaseItemIcon)

    EpsilonPhasesPhaseListPhaseItemIcon:AddMaskTexture(EpsilonPhasesPhaseListPhaseItemIconMask)

    local EpsilonPhasesPhaseListPhaseName = EpsilonPhasesPhaseListPhaseItem:CreateFontString(nil, "OVERLAY", "GameFontNormalMed2")
    EpsilonPhasesPhaseListPhaseName:SetJustifyH("LEFT")
    EpsilonPhasesPhaseListPhaseName:SetPoint("LEFT", EpsilonPhasesPhaseListPhaseItem, "LEFT", 80, 18)
    EpsilonPhasesPhaseListPhaseName:SetText(phase:GetPhaseName())
    EpsilonPhasesPhaseListPhaseName:SetTextScale(0.9)

    local EpsilonPhasesPhaseListPhaseID = EpsilonPhasesPhaseListPhaseItem:CreateFontString(nil, "OVERLAY", "GameTooltipText")
    EpsilonPhasesPhaseListPhaseID :SetJustifyH("LEFT")
    EpsilonPhasesPhaseListPhaseID :SetPoint("LEFT", EpsilonPhasesPhaseListPhaseItem, "LEFT", 80, 3)
    EpsilonPhasesPhaseListPhaseID :SetText(phase:GetPhaseID())
    EpsilonPhasesPhaseListPhaseID :SetTextScale(0.9)

    local EpsilonPhasesPhaseListPhaseHosting = EpsilonPhasesPhaseListPhaseItem:CreateFontString(nil, "OVERLAY", "GameTooltipText")
    EpsilonPhasesPhaseListPhaseHosting:SetJustifyH("LEFT")
    EpsilonPhasesPhaseListPhaseHosting:SetPoint("LEFT", EpsilonPhasesPhaseListPhaseItem, "LEFT", 80, -22)
    EpsilonPhasesPhaseListPhaseHosting:SetTextScale(0.92)
    EpsilonPhasesPhaseListPhaseHosting:SetWidth(180)
    EpsilonPhasesPhaseListPhaseHosting:SetWordWrap(false)
    EpsilonPhasesPhaseListPhaseHosting:SetText(phase:GetPhaseDescription())

    EpsilonPhasesPhaseListPhaseItem.id = EpsilonPhasesPhaseListPhaseID
    EpsilonPhasesPhaseListPhaseItem.name = EpsilonPhasesPhaseListPhaseName
    EpsilonPhasesPhaseListPhaseItem.description = EpsilonPhasesPhaseListPhaseHosting

    local EpsilonPhasesPhaseListPhaseItemQuickJoin = CreateFrame("Button", EpsilonPhasesPhaseListPhaseItemQuickJoin,
    EpsilonPhasesPhaseListPhaseItem)

    EpsilonPhasesPhaseListPhaseItemQuickJoin:SetSize(50, 30)
    EpsilonPhasesPhaseListPhaseItemQuickJoin:SetPoint("TOPRIGHT", EpsilonPhasesPhaseListPhaseItem, "TOPRIGHT", 0, 0)
    EpsilonPhasesPhaseListPhaseItemQuickJoin:SetFrameStrata("HIGH")
    EpsilonPhasesPhaseListPhaseItemQuickJoin:SetScript("OnClick", function(self, button)
        EpsilonPhases.JoinPhase(EpsilonPhasesPhaseListPhaseItem.phase)
    end)

    local EpsilonPhasesPhaseListPhaseItemPin = CreateFrame("Button", EpsilonPhasesPhaseListPhaseItemPin,
    EpsilonPhasesPhaseListPhaseItem)

    EpsilonPhasesPhaseListPhaseItem:SetScript("OnEnter", function(self, button)
        EpsilonPhasesPhaseListPhaseItemQuickJoin:SetNormalTexture(EpsilonPhases.ASSETS_PATH .. "/EpsiLoginWPEngineCornerQuickJoin")
        EpsilonPhasesPhaseListPhaseItemQuickJoin:GetNormalTexture():SetVertexColor(0, 0.98, 0.51, 1)
        if not EpsilonPhases.Favourites[EpsilonPhasesPhaseListPhaseItem.phase.data.id] then
            EpsilonPhasesPhaseListPhaseItemPin:SetNormalTexture(EpsilonPhases.ASSETS_PATH .. "/PMStar")
        end
    end)

    EpsilonPhasesPhaseListPhaseItem:SetScript("OnLeave", function(self, button)
        EpsilonPhasesPhaseListPhaseItemQuickJoin:SetNormalTexture(nil)
        if not EpsilonPhases.Favourites[EpsilonPhasesPhaseListPhaseItem.phase.data.id] then
            EpsilonPhasesPhaseListPhaseItemPin:SetNormalTexture(nil)
        end
    end)


    EpsilonPhasesPhaseListPhaseItemPin:SetSize(40, 40)
    EpsilonPhasesPhaseListPhaseItemPin:SetPoint("BOTTOMRIGHT", EpsilonPhasesPhaseListPhaseItem, "BOTTOMRIGHT", 0, 0)
    if EpsilonPhases.Favourites[EpsilonPhasesPhaseListPhaseItem.phase.data.id] then
        EpsilonPhasesPhaseListPhaseItemPin:SetNormalTexture(EpsilonPhases.ASSETS_PATH .. "/PMStarSelected")
    else 
        EpsilonPhasesPhaseListPhaseItemPin:SetNormalTexture(nil)
    end
    EpsilonPhasesPhaseListPhaseItemPin:SetFrameStrata("HIGH")
    EpsilonPhasesPhaseListPhaseItemPin:SetScript("OnClick", function(self, button)
        local phaseId = EpsilonPhases.GetPhase(EpsilonPhases.GetPhaseIndexByUIIndex(index)).data.id
        if EpsilonPhases.Favourites[phaseId] then
            EpsilonPhases.Favourites[phaseId] = nil
            EpsilonPhasesPhaseListPhaseItemPin:SetNormalTexture(EpsilonPhases.ASSETS_PATH .. "/PMStar")
        else
            EpsilonPhases.Favourites[phaseId] = true
            EpsilonPhasesPhaseListPhaseItemPin:SetNormalTexture(EpsilonPhases.ASSETS_PATH .. "/PMStarSelected")
        end
        EpsilonPhases.SortPhaseList()
    end)

    EpsilonPhasesPhaseListPhaseItem.ItemPin = EpsilonPhasesPhaseListPhaseItemPin

    EpsilonPhasesPhaseListPhaseItemPin:SetScript("OnLeave", function(self, button)
        local GameTooltip = _G["GameTooltip"]
        GameTooltip:Hide()

        EpsilonPhasesPhaseListPhaseItemQuickJoin:SetNormalTexture(nil)
        if not EpsilonPhases.Favourites[EpsilonPhasesPhaseListPhaseItem.phase.data.id] then
            EpsilonPhasesPhaseListPhaseItemPin:SetNormalTexture(nil)
        end
    end)

    EpsilonPhasesPhaseListPhaseItemPin:SetScript("OnEnter", function(self, button)
        local GameTooltip = _G["GameTooltip"]
        GameTooltip:SetOwner(self, "ANCHOR_CURSOR");
        GameTooltip:ClearLines();

        EpsilonPhasesPhaseListPhaseItemQuickJoin:SetNormalTexture(EpsilonPhases.ASSETS_PATH .. "/EpsiLoginWPEngineCornerQuickJoin")
        EpsilonPhasesPhaseListPhaseItemQuickJoin:GetNormalTexture():SetVertexColor(0, 0.98, 0.51, 1)
        if not EpsilonPhases.Favourites[EpsilonPhasesPhaseListPhaseItem.phase.data.id] then
            GameTooltip:SetText("Favourite " .. EpsilonPhasesPhaseListPhaseItem.phase:GetPhaseName())
            EpsilonPhasesPhaseListPhaseItemPin:SetNormalTexture(EpsilonPhases.ASSETS_PATH .. "/PMStar")
        else 
            GameTooltip:SetText("Un-Favourite " .. EpsilonPhasesPhaseListPhaseItem.phase:GetPhaseName())
        end
        GameTooltip:Show()
    end)

    EpsilonPhasesPhaseListPhaseItemQuickJoin:SetScript("OnLeave", function(self, button)
        local GameTooltip = _G["GameTooltip"]
        GameTooltip:Hide()

        EpsilonPhasesPhaseListPhaseItemQuickJoin:SetNormalTexture(nil)
        if not EpsilonPhases.Favourites[EpsilonPhasesPhaseListPhaseItem.phase.data.id] then
            EpsilonPhasesPhaseListPhaseItemPin:SetNormalTexture(nil)
        end
    end)

    EpsilonPhasesPhaseListPhaseItemQuickJoin:SetScript("OnEnter", function(self, button)
        local GameTooltip = _G["GameTooltip"]
        GameTooltip:SetOwner(self, "ANCHOR_CURSOR");
        GameTooltip:ClearLines();
        GameTooltip:SetText("Join " .. EpsilonPhasesPhaseListPhaseItem.phase:GetPhaseName())
        GameTooltip:Show()

        EpsilonPhasesPhaseListPhaseItemQuickJoin:SetNormalTexture(EpsilonPhases.ASSETS_PATH .. "/EpsiLoginWPEngineCornerQuickJoin")
        EpsilonPhasesPhaseListPhaseItemQuickJoin:GetNormalTexture():SetVertexColor(0, 0.98, 0.51, 1)
        if not EpsilonPhases.Favourites[EpsilonPhasesPhaseListPhaseItem.phase.data.id] then
            EpsilonPhasesPhaseListPhaseItemPin:SetNormalTexture(EpsilonPhases.ASSETS_PATH .. "/PMStar")
        end
    end)



    EpsilonPhasesPhaseListPhaseItem:GetNormalTexture():SetAllPoints(EpsilonPhasesPhaseListPhaseItem)

    EpsilonPhasesPhaseListPhaseItem:SetScript("OnClick", function (self, button)
        if IsShiftKeyDown() then 
            linkPhase(self.phase)
        else
            EpsilonPhases.SetCurrentActivePhase(index)
        end
    end)
end
EpsilonPhases.CreatePhaseListItem = CreatePhaseListItem

local function SetPhaseListItem(phaseListItem, phase)
    local backgroundX, backgroundX2, backgroundY, backgroundY2 = calcBackground(phase:GetPhaseBackground())

    phaseListItem.phase = phase
    if (phase:GetPhaseBackground() > 91) then
        phaseListItem.background:SetTexture(EpsilonPhases.ASSETS_PATH .. "/Backgrounds2")
    else
        phaseListItem.background:SetTexture(EpsilonPhases.ASSETS_PATH .. "/Backgrounds1")
    end
    phaseListItem.background:SetTexCoord(backgroundX,  backgroundX2 ,backgroundY, backgroundY2)
    local r, g, b = phase:GetPhaseColor():GetRGB()
    phaseListItem:GetNormalTexture():SetVertexColor(r,g,b,1)

    phaseListItem.icon:SetTexture(EpsilonPhases.ICON_PATH .. phase:GetPhaseIcon())
    phaseListItem.id:SetText(phase:GetPhaseID())
    phaseListItem.name:SetText(string.sub(phase.data.name, 1, 24))
    phaseListItem.description:SetText(phase:GetPhaseDescription())
    if EpsilonPhases.Favourites[phase.data.id] then
        phaseListItem.ItemPin:SetNormalTexture(EpsilonPhases.ASSETS_PATH .. "/PMStarSelected")
    else 
        phaseListItem.ItemPin:SetNormalTexture(nil)
    end
    phaseListItem:Show()
end
EpsilonPhases.SetPhaseListItem = SetPhaseListItem