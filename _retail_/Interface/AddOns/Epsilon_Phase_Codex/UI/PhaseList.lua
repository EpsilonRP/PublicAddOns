local currentActivePhase
local allPhases = {}
-- For the filtered / search phases
local allphasesChache = allPhases
local EpsilonPhases = LibStub("AceAddon-3.0"):GetAddon("EpsilonPhases")
local PhaseClass = EpsilonLib.Classes.Phase
local isQuickAccessed = false
local currentTab = nil

EpsilonPhases.allPhases = allPhases

local function isMainPhase()
    return tonumber(C_Epsilon.GetPhaseId()) == 169
end

local function scrollPhaseList(delta)
    local currentValue = EpsilonPhasesPhaseListScrollbar:GetValue()
    local _, maxValue = EpsilonPhasesPhaseListScrollbar:GetMinMaxValues()
    if (currentValue > 0 or delta < 0) and (currentValue < maxValue or delta > 0) then
        EpsilonPhasesPhaseListScrollbar:SetValue(currentValue - delta)
        EpsilonPhases.SetCurrentActivePhaseByPhaseID(EpsilonPhases.currentActivePhase:GetPhaseID())
    end
end

local function searchPhases(searchterm)
    local filteredPhases = {}

    if searchterm == "" or searchterm == nil then
        currentTab()
    end
    for _, phase in pairs(allPhases) do
        if phase:GetPhaseName():lower():find(searchterm:lower()) then
            table.insert(filteredPhases, phase)
        else
            for _, tag in pairs(phase:GetPhaseTags()) do
                if tag:lower():find(searchterm:lower()) then
                    table.insert(filteredPhases, phase)
                    break
                end
            end
        end
    end
    return filteredPhases
end

local function GetPhaseIndexByUIIndex(UiIndex)
    local offset = EpsilonPhasesPhaseListScrollbar:GetValue()
    return UiIndex + offset
end
EpsilonPhases.GetPhaseIndexByUIIndex = GetPhaseIndexByUIIndex


EpsilonPhases.SubscribeToPhase = SubscribeToPhase

local EpsilonPhasesPhaseListFrame = CreateFrame("Frame", "EpsilonPhasesPhaseListFrame", UIParent, "ButtonFrameTemplate")
ButtonFrameTemplate_HidePortrait(EpsilonPhasesPhaseListFrame)
EpsilonPhasesPhaseListFrame:SetSize(300, 621)
EpsilonPhasesPhaseListFrame:SetPoint("LEFT", EpsilonPhasesMainFrame, "LEFT", -300, -20)
EpsilonPhasesPhaseListFrame:SetToplevel(true)
EpsilonPhasesPhaseListFrame:EnableMouse(true)
EpsilonPhasesPhaseListFrame.TitleBgColor = titleBgColor
EpsilonPhasesPhaseListFrame:SetTitle("Phases")
EpsilonPhasesPhaseListFrame:EnableMouseWheel()
EpsilonPhasesPhaseListFrame:Hide()

NineSliceUtil.ApplyLayoutByName(EpsilonPhasesPhaseListFrame.NineSlice, "EpsilonGoldBorderFrameTemplateNoPortrait")
if EpsilonPhasesPhaseListFrame.NineSlice then
    EpsilonPhasesPhaseListFrame.NineSlice:SetFrameLevel(1)
end
local closeButton = EpsilonPhasesPhaseListFrame.CloseButton
closeButton:SetParent(_G["EpsilonPhasesMainFrame"])
closeButton:SetNormalTexture("interface/buttons/ui-spellbookicon-nextpage-up")
closeButton:SetPushedTexture("interface/buttons/ui-spellbookicon-nextpage-down")
closeButton:SetFrameLevel(500)
closeButton:SetScript("OnClick", function(self, _)
    if EpsilonPhasesPhaseListFrame:IsVisible() then
        EpsilonPhasesPhaseListFrame:Hide()
        closeButton:SetNormalTexture("interface/buttons/ui-spellbookicon-prevpage-up")
        closeButton:SetPushedTexture("interface/buttons/ui-spellbookicon-prevpage-down")
    else
        EpsilonPhasesPhaseListFrame:Show()
        closeButton:SetNormalTexture("interface/buttons/ui-spellbookicon-nextpage-up")
        closeButton:SetPushedTexture("interface/buttons/ui-spellbookicon-nextpage-down")
    end
end)

-- so that the close button is properly clickable <.<
local inviscloseButton = CreateFrame("Button", nil, EpsilonPhasesPhaseListFrame, "UIPanelCloseButton")
inviscloseButton:SetPoint("CENTER", closeButton, "CENTER")
inviscloseButton:SetNormalTexture(nil)
inviscloseButton:SetPushedTexture(nil)
inviscloseButton:SetFrameLevel(500)
inviscloseButton:SetScript("OnClick", function(self, _)
    if EpsilonPhasesPhaseListFrame:IsVisible() then
        EpsilonPhasesPhaseListFrame:Hide()
        closeButton:SetNormalTexture("interface/buttons/ui-spellbookicon-prevpage-up")
        closeButton:SetPushedTexture("interface/buttons/ui-spellbookicon-prevpage-down")
    else
        EpsilonPhasesPhaseListFrame:Show()
        closeButton:SetNormalTexture("interface/buttons/ui-spellbookicon-nextpage-up")
        closeButton:SetPushedTexture("interface/buttons/ui-spellbookicon-nextpage-down")
    end
end)

EpsilonPhasesPhaseListFrame.TopTileStreaks:SetTexture(EpsilonPhases.ASSETS_PATH .. "/EpsiIndexBG")
EpsilonPhasesPhaseListFrame.TopTileStreaks:SetVertexColor(0.45, 0.45, 0.45)
EpsilonPhasesPhaseListFrame.TopTileStreaks:SetPoint("TOPLEFT", 0, -22)
EpsilonPhasesPhaseListFrame.TopTileStreaks:SetPoint("TOPRIGHT", -2, -22)
EpsilonPhasesPhaseListFrame.TopTileStreaks:SetHeight(42)

EpsilonPhasesPhaseListFrame.Inset:SetPoint("TOPLEFT", 4, -63)
EpsilonPhasesPhaseListFrame.Inset:SetPoint("BOTTOMRIGHT", -6, 20)
local phaseListBackground = EpsilonPhasesPhaseListFrame.Inset.Bg
phaseListBackground:SetTexture(EpsilonPhases.ASSETS_PATH .. "/ManagerBG")
phaseListBackground:SetAllPoints()

local phaseListTitleBgColor = EpsilonPhasesPhaseListFrame:CreateTexture(nil, "BACKGROUND")
phaseListTitleBgColor:SetPoint("TOPLEFT", EpsilonPhasesPhaseListFrame.TitleBg)
phaseListTitleBgColor:SetPoint("BOTTOMRIGHT", EpsilonPhasesPhaseListFrame.TitleBg)
phaseListTitleBgColor:SetColorTexture(0.30, 0.10, 0.40, 0.5)


EpsilonPhasesPhaseListScrollbar = CreateFrame("Slider", EpsilonPhasesPhaseListScrollbar, EpsilonPhasesPhaseListFrame,
    "MinimalScrollBarTemplate")

EpsilonPhasesPhaseListScrollbar:SetSize(18, EpsilonPhasesPhaseListFrame:GetHeight() - 62)
EpsilonPhasesPhaseListScrollbar:SetPoint("TOPRIGHT", EpsilonPhasesPhaseListFrame, "TOPRIGHT", -4, -40)
EpsilonPhasesPhaseListScrollbar:EnableMouseWheel()
EpsilonPhasesPhaseListScrollbar:SetObeyStepOnDrag(true)
EpsilonPhasesPhaseListScrollbar:SetValueStep(1)
EpsilonPhasesPhaseListScrollbar:SetValue(1)
EpsilonPhasesPhaseListScrollbar:SetScript("OnValueChanged", function(self, value)
    EpsilonPhases.RefreshPhases()
end)

EpsilonPhasesPhaseListFrame:SetScript("OnMouseWheel", function(self, delta)
    scrollPhaseList(delta)
end)

local searchbar = CreateFrame("EditBox", nil, EpsilonPhasesPhaseListFrame, "SearchBoxTemplate")
searchbar:SetSize(260, 10)
searchbar:SetPoint("CENTER", EpsilonPhasesPhaseListFrame.TopTileStreaks, "CENTER", -5, 7)
searchbar:SetAutoFocus(false)
searchbar:SetScript("OnTextChanged", function(self, userInput)
    allPhases = searchPhases(self:GetText())
    EpsilonPhases.RefreshPhases()
    SearchBoxTemplate_OnTextChanged(self, userInput)
end)

local EpsilonPhasesPhaseListPublicTab = CreateFrame("Button", "EpsilonPhasesPhaseListPublicTab",
    EpsilonPhasesPhaseListFrame)
EpsilonPhasesPhaseListPublicTab:SetSize(90, 37)
EpsilonPhasesPhaseListPublicTab:SetPoint("CENTER", EpsilonPhasesPhaseListFrame.TopTileStreaks, "BOTTOMLEFT", 50, 3)
EpsilonPhasesPhaseListPublicTab:SetNormalTexture(EpsilonPhases.ASSETS_PATH .. "/EpsiTabSelected")
EpsilonPhasesPhaseListPublicTab:GetNormalTexture():SetTexCoord(0.21, 0.79, 0, 1)
EpsilonPhasesPhaseListPublicTab:SetHighlightTexture(EpsilonPhases.ASSETS_PATH .. "/EpsiTabHighlight")
EpsilonPhasesPhaseListPublicTab:GetHighlightTexture():SetTexCoord(0.21, 0.79, 0, 1)
local publicTabText = EpsilonPhasesPhaseListPublicTab:CreateFontString(nil, "OVERLAY", "GameFontNormalMed2")
publicTabText:SetPoint("CENTER", EpsilonPhasesPhaseListPublicTab, "CENTER")
publicTabText:SetText("Public")



local EpsilonPhasesPhaseListMallTab = CreateFrame("Button", "EpsilonPhasesPhaseListMallTab", EpsilonPhasesPhaseListFrame)
EpsilonPhasesPhaseListMallTab:SetSize(90, 37)
EpsilonPhasesPhaseListMallTab:SetPoint("CENTER", EpsilonPhasesPhaseListFrame.TopTileStreaks, "BOTTOM", -8, 3)
EpsilonPhasesPhaseListMallTab:SetNormalTexture(EpsilonPhases.ASSETS_PATH .. "/EpsiTabUnselected")
EpsilonPhasesPhaseListMallTab:GetNormalTexture():SetTexCoord(0.21, 0.79, 0, 1)
EpsilonPhasesPhaseListMallTab:SetHighlightTexture(EpsilonPhases.ASSETS_PATH .. "/EpsiTabHighlight")
EpsilonPhasesPhaseListMallTab:GetHighlightTexture():SetTexCoord(0.21, 0.79, 0, 1)
local MallTabText = EpsilonPhasesPhaseListMallTab:CreateFontString(nil, "OVERLAY", "GameFontNormalMed2")
MallTabText:SetPoint("CENTER", EpsilonPhasesPhaseListMallTab, "CENTER")
MallTabText:SetText("Malls")

local EpsilonPhasesPhaseListMallAdminButton = CreateFrame("Button", nil, EpsilonPhasesPhaseListFrame,
    "IconButtonTemplate")
local _button = EpsilonPhasesPhaseListMallAdminButton
EpsilonPhasesPhaseListFrame.MallAdminButton = _button
_button:SetScript("OnEnter", SquareIconButtonMixin.OnEnter)
_button:SetScript("OnLeave", SquareIconButtonMixin.OnLeave)
_button.tooltipTitle = "Mall Admin"
_button.tooltipText = "Manage the baseline list of malls"
_button:SetSize(16, 16)
_button:SetPoint("TOPLEFT", EpsilonPhasesPhaseListFrame, "TOPLEFT", 10, -5)
_button:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight")
_button.Icon = _button:CreateTexture(nil, "OVERLAY")
_button.Icon:SetPoint("CENTER", -1, 0)
_button.Icon:SetSize(_button:GetSize())
_button.Icon:SetTexture("interface/buttons/ui-optionsbutton")
_button:SetScript("OnClick", function()
    local phaseId = tonumber(C_Epsilon.GetPhaseId())
    if not C_Epsilon.IsMember() then
        EpsilonLib.Utils.GenericDialogs.CustomConfirmation({
            text = "You must be a member to manage malls",
            showAlert = true,
            cancelText = false,
        })
        return
    elseif phaseId ~= 169 then
        EpsilonLib.Utils.GenericDialogs.CustomConfirmation({
            text = "You must be in the main phase to manage malls",
            showAlert = true,
            cancelText = false,
        })
        return
    end
    PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
    EpsilonLib.PhaseAddonData.Get("BH_MALLS", function(data)
        local malls = string.gsub(data, ",", "\n")

        EpsilonLib.Utils.GenericDialogs.CustomConfirmation({
            text = "== Codex Mall Admin ==",
            subText = "Current Malls:\n" .. malls,
            acceptText = "Add Mall",
            cancelText = "Remove Mall",
            noCancelOnEscape = true,
            showAlert = false,
            callback = function()
                EpsilonLib.Utils.GenericDialogs.CustomInput({
                    text = "== Codex Mall Admin ==\nEnter the phase ID of the mall you want to add",
                    subText =
                    "Optionally, you can add a teleport point name by adding a colon and the name after the phase ID\n(e.g. 123:TeleportName)",
                    acceptText = "Add",
                    cancelText = CANCEL,
                    callback = function(phaseID)
                        local phaseID, teleName = strsplit(":", phaseID)
                        EpsilonPhases:AddMallToMPDirectory(tonumber(phaseID), teleName)
                    end
                })
            end,
            cancelCallback = function(from)
                if from == "override" then return end
                EpsilonLib.Utils.GenericDialogs.CustomInput({
                    text = "== Codex Mall Admin ==\nEnter the phase ID of the mall you want to remove",
                    subText = "Current Malls:\n" .. malls,
                    acceptText = "Remove",
                    cancelText = CANCEL,
                    callback = function(phaseID)
                        EpsilonPhases:RemoveMallFromMPDirectory(tonumber(phaseID))
                    end
                })
            end
        })
    end)
end)
function _button:ShowIfMember()
    self:SetShown((allPhases == EpsilonPhases.Malls) and isMainPhase() and C_Epsilon.IsMember())
end

_button:Raise()

local EpsilonPhasesPhaseListPrivateTab = CreateFrame("Button", EpsilonPhasesPhaseListPrivateTab,
    EpsilonPhasesPhaseListFrame)
EpsilonPhasesPhaseListPrivateTab:SetSize(90, 37)
EpsilonPhasesPhaseListPrivateTab:SetPoint("CENTER", EpsilonPhasesPhaseListFrame.TopTileStreaks, "BOTTOMRIGHT", -66, 3)
EpsilonPhasesPhaseListPrivateTab:SetNormalTexture(EpsilonPhases.ASSETS_PATH .. "/EpsiTabUnselected")
EpsilonPhasesPhaseListPrivateTab:GetNormalTexture():SetTexCoord(0.21, 0.79, 0, 1)
EpsilonPhasesPhaseListPrivateTab:SetHighlightTexture(EpsilonPhases.ASSETS_PATH .. "/EpsiTabHighlight")
EpsilonPhasesPhaseListPrivateTab:GetHighlightTexture():SetTexCoord(0.21, 0.79, 0, 1)
local PrivateTabText = EpsilonPhasesPhaseListPrivateTab:CreateFontString(nil, "OVERLAY", "GameFontNormalMed2")
PrivateTabText:SetPoint("CENTER", EpsilonPhasesPhaseListPrivateTab, "CENTER")
PrivateTabText:SetText("Personal")

ButtonFrameTemplate_HideButtonBar(EpsilonPhasesPhaseListFrame)
EpsilonPhasesPhaseListFrame.TitleBgColor = titleBgColor


function EpsilonPhases:InsertPhase(phase)
    table.insert(allPhases, phase)
end

function EpsilonPhases:SetupPhaseList(list)
    allPhases = list
    local count = 0
    local currentActivePhaseId = nil
    if next(allPhases) ~= nil then
        if currentActivePhase ~= nil then
            currentActivePhaseId = EpsilonPhases.currentActivePhase:GetPhaseID()
        else
            currentActivePhase = 1
        end
        for i, phase in ipairs(allPhases) do
            EpsilonPhases.SetPhase(count + 1, phase)
            count = count + 1
            if phase:GetPhaseID() == currentActivePhaseId then
                currentActivePhase = count
            end
        end
        for i = count + 1, #allPhases, 1 do
            EpsilonPhases.PublicPhases[i] = nil
        end

        EpsilonPhases.SortPhaseList()
    end
    EpsilonPhases.DrawPhases(allPhases)
    EpsilonPhases.SetScrollbarValues(count)
    EpsilonPhases.SetCurrentActivePhase(currentActivePhase)
end

local function RefreshPhases()
    EpsilonPhases.DrawPhases(allPhases)
end
EpsilonPhases.RefreshPhases = RefreshPhases

local function DrawPhases(phases)
    local offset = EpsilonPhasesPhaseListScrollbar:GetValue()
    for i = 1, 7, 1 do
        local phase = _G["EpsilonPhasesPhaseListPhaseItem" .. i]
        if phase ~= nil and phases[i + offset] ~= nil then
            EpsilonPhases.SetPhaseListItem(_G["EpsilonPhasesPhaseListPhaseItem" .. i], phases[i + offset])
        elseif phase ~= nil and phases[i + offset] == nil then
            phase:Hide()
        elseif phase == nil and phases[i + offset] ~= nil then
            EpsilonPhases.CreatePhaseListItem(i, phases[i + offset])
        end
    end
end
EpsilonPhases.DrawPhases = DrawPhases

local function SetPhase(i, phase)
    allPhases[i] = phase
end
EpsilonPhases.SetPhase = SetPhase

local function SetScrollbarValue(value)
    EpsilonPhasesPhaseListScrollbar:SetValue(value)
end
EpsilonPhases.SetScrollbarValue = SetScrollbarValue

local function SetCurrentActivePhase(index)
    if index ~= nil then
        if index > #allPhases or index < 1 then return end
    end
    _G["EpsilonPhasesSettingsFrame"]:Hide()
    for i = 1, math.min(7, #allPhases), 1 do
        local phaseListItem = _G["EpsilonPhasesPhaseListPhaseItem" .. i]
        if phaseListItem ~= nil then
            phaseListItem.ActiveTexture:SetTexture(nil)
        end
    end
    currentActivePhase = index
    if next(allPhases) ~= nil and currentActivePhase ~= nil then
        EpsilonPhases.currentActivePhase = allPhases[index + EpsilonPhasesPhaseListScrollbar:GetValue()]
        local phaseListItem = _G["EpsilonPhasesPhaseListPhaseItem" .. currentActivePhase]
        if phaseListItem ~= nil then
            _G["EpsilonPhasesPhaseListPhaseItem" .. currentActivePhase].ActiveTexture:SetTexture(EpsilonPhases
                .ASSETS_PATH .. "/EpsiIndexObjectFrameHover")
        end
        local currentOffset = EpsilonPhasesPhaseListScrollbar:GetValue()
        EpsilonPhases.WritePhaseDetailData(allPhases[index + currentOffset])
    end
    EpsilonPhases:SetSettingsButtonEnable()
end
EpsilonPhases.SetCurrentActivePhase = SetCurrentActivePhase

local function GetCurrentActivePhase()
    return currentActivePhase
end
EpsilonPhases.GetCurrentActivePhase = GetCurrentActivePhase

local function GetPhaseByUIIndex(i)
    return allPhases[i + EpsilonPhasesPhaseListScrollbar:GetValue()]
end
EpsilonPhases.GetPhaseByUIIndex = GetPhaseByUIIndex

local function SetScrollbarValues(numberOfPhases)
    if (numberOfPhases > 7) then
        EpsilonPhasesPhaseListScrollbar:SetMinMaxValues(0, numberOfPhases - 7)
    else
        EpsilonPhasesPhaseListScrollbar:SetMinMaxValues(0, 0)
    end
end
EpsilonPhases.SetScrollbarValues = SetScrollbarValues

local function SetNextPhase()
    local nextPhaseIndex = currentActivePhase + 1
    local scrollOffset = EpsilonPhasesPhaseListScrollbar:GetValue()
    if nextPhaseIndex + scrollOffset > 7 then
        EpsilonPhasesPhaseListScrollbar:SetValue(EpsilonPhasesPhaseListScrollbar:GetValue() + 1)
    end
    SetCurrentActivePhase(math.min(7, nextPhaseIndex))
end
EpsilonPhases.SetNextPhase = SetNextPhase

local function SetPreviousPhase()
    local prevPhaseIndex = currentActivePhase - 1
    local scrollOffset = EpsilonPhasesPhaseListScrollbar:GetValue()
    if prevPhaseIndex - scrollOffset < 0 then
        EpsilonPhasesPhaseListScrollbar:SetValue(EpsilonPhasesPhaseListScrollbar:GetValue() - 1)
    end
    SetCurrentActivePhase(math.max(prevPhaseIndex, 1))
end
EpsilonPhases.SetPreviousPhase = SetPreviousPhase

local function SetCurrentActivePhaseByPhaseID(phaseID)
    local phaseSet = false
    for i = 1, #allPhases, 1 do
        if allPhases[i]:GetPhaseID() == phaseID then
            local phaselistPosition = i - EpsilonPhasesPhaseListScrollbar:GetValue()
            if phaselistPosition > 0 and phaselistPosition <= 7 then
                SetCurrentActivePhase(phaselistPosition)
                phaseSet = true
            end
        end
    end
    if not phaseSet then
        SetCurrentActivePhase(nil)
    end
end

EpsilonPhases.SetCurrentActivePhaseByPhaseID = SetCurrentActivePhaseByPhaseID

local forcedMallsOnTop = {
    [200] = true,
    [26000] = true,
    [94590] = true,
}

local function SortPhaseList()
    local phaseList = allPhases
    if #phaseList == 0 then return end
    local currentOrder = {}
    for i, phase in ipairs(phaseList) do
        currentOrder[phase:GetPhaseID()] = i
    end
    if currentActivePhase > #phaseList then currentActivePhase = 1 end
    local currentActivePhaseId = phaseList[currentActivePhase]:GetPhaseID()
    table.sort(phaseList, function(phase1, phase2)
        local id1, id2 = phase1.data.id, phase2.data.id
        local name1, name2 = phase1.data.name, phase2.data.name

        -- Check always on top priority
        local aAlwaysOnTop, bAlwaysOnTop = forcedMallsOnTop[id1], forcedMallsOnTop[id2]
        if aAlwaysOnTop ~= bAlwaysOnTop then
            return aAlwaysOnTop
        end

        -- Check Favourites Priority
        local aFavorite, bFavorite = EpsilonPhases.Favourites[id1], EpsilonPhases.Favourites[id2]
        if aFavorite ~= bFavorite then
            return aFavorite -- true sorts before false
        end

        -- Keep current order otherwise
        return currentOrder[phase1.data.id] < currentOrder[phase2.data.id]
    end)
    SetCurrentActivePhaseByPhaseID(currentActivePhaseId)
    RefreshPhases()
end

EpsilonPhases.SortPhaseList = SortPhaseList

local function RemovePhaseFromList(phaseID, phaseList)
    for key, phase in pairs(phaseList) do
        if phase:GetPhaseID() == phaseID then
            table.remove(phaseList, key)
        end
    end
    EpsilonPhases.RefreshPhases()
end

EpsilonPhases.RemovePhaseFromList = RemovePhaseFromList

local function GetPhase(index)
    return allPhases[index]
end

EpsilonPhases.GetPhase = GetPhase

local function SetPhaseListToMalls()
    local removePhaseButton = _G["EpsilonPhasesMainFrameRemovePhaseButton"]
    removePhaseButton:Disable()
    removePhaseButton:GetNormalTexture():SetDesaturated(true)
    allPhases = EpsilonPhases.Malls
    currentTabList = EpsilonPhases.Malls
    EpsilonPhases.SetScrollbarValues(#allPhases)
    EpsilonPhases.SetScrollbarValue(0)
    if #allPhases ~= 0 then
        EpsilonPhases.SetCurrentActivePhase(1)
    end
    EpsilonPhases.DrawPhases(EpsilonPhases.Malls)
    EpsilonPhasesPhaseListPrivateTab:SetNormalTexture(EpsilonPhases.ASSETS_PATH .. "/EpsiTabUnselected")
    EpsilonPhasesPhaseListPublicTab:SetNormalTexture(EpsilonPhases.ASSETS_PATH .. "/EpsiTabUnselected")
    EpsilonPhasesPhaseListMallTab:SetNormalTexture(EpsilonPhases.ASSETS_PATH .. "/EpsiTabSelected")
    EpsilonPhases.SortPhaseList()
    currentTab = SetPhaseListToMalls


    EpsilonPhasesPhaseListMallAdminButton:ShowIfMember()
end
EpsilonPhases.SetPhaseListToMalls = SetPhaseListToMalls

function SetPhaseListToPublic()
    allPhases = EpsilonPhases.PublicPhases
    local removePhaseButton = _G["EpsilonPhasesMainFrameRemovePhaseButton"]
    removePhaseButton:Disable()
    removePhaseButton:GetNormalTexture():SetDesaturated(true)
    EpsilonPhases.SetScrollbarValues(#allPhases)
    EpsilonPhases.SetScrollbarValue(0)
    EpsilonPhases.GetPublicPhases()
    EpsilonPhasesPhaseListPrivateTab:SetNormalTexture(EpsilonPhases.ASSETS_PATH .. "/EpsiTabUnselected")
    EpsilonPhasesPhaseListMallTab:SetNormalTexture(EpsilonPhases.ASSETS_PATH .. "/EpsiTabUnselected")
    EpsilonPhasesPhaseListPublicTab:SetNormalTexture(EpsilonPhases.ASSETS_PATH .. "/EpsiTabSelected")
    EpsilonPhases.SortPhaseList()
    currentTab = SetPhaseListToPublic

    EpsilonPhasesPhaseListMallAdminButton:Hide()
end

EpsilonPhases.SetPhaseListToPublic = SetPhaseListToPublic

local function SetPhaseListToPrivate()
    local removePhaseButton = _G["EpsilonPhasesMainFrameRemovePhaseButton"]
    removePhaseButton:Enable()
    removePhaseButton:GetNormalTexture():SetDesaturated(false)
    allPhases = EpsilonPhases.PrivatePhases
    currentTabList = EpsilonPhases.PrivatePhases
    EpsilonPhases.SetScrollbarValues(#allPhases)
    EpsilonPhases.DrawPhases(EpsilonPhases.PrivatePhases)
    EpsilonPhases.SetScrollbarValue(0)
    if #allPhases ~= 0 then
        EpsilonPhases.SetCurrentActivePhase(1)
    end
    EpsilonPhasesPhaseListMallTab:SetNormalTexture(EpsilonPhases.ASSETS_PATH .. "/EpsiTabUnselected")
    EpsilonPhasesPhaseListPublicTab:SetNormalTexture(EpsilonPhases.ASSETS_PATH .. "/EpsiTabUnselected")
    EpsilonPhasesPhaseListPrivateTab:SetNormalTexture(EpsilonPhases.ASSETS_PATH .. "/EpsiTabSelected")
    EpsilonPhases.SortPhaseList()
    currentTab = SetPhaseListToPrivate

    EpsilonPhasesPhaseListMallAdminButton:Hide()
end
EpsilonPhases.SetPhaseListToPrivate = SetPhaseListToPrivate

local function quickAcessShowHide(keystate)
    if isQuickAccessed and EpsilonPhasesPhaseListFrame:IsVisible() then
        EpsilonPhasesPhaseListFrame:Hide()
        isQuickAccessed = false
    elseif not EpsilonPhasesPhaseListFrame:IsVisible() then
        EpsilonPhases.SetStartTab()
        EpsilonPhasesPhaseListFrame:Show()
        isQuickAccessed = true
    end
end
EpsilonPhases.quickAccessShowHide = quickAcessShowHide


EpsilonPhasesPhaseListPrivateTab:SetScript("OnClick", function(self, button)
    EpsilonPhases.SetPhaseListToPrivate()
end)

EpsilonPhasesPhaseListPublicTab:SetScript("OnClick", function(self, button)
    EpsilonPhases.SetPhaseListToPublic()
end)

EpsilonPhasesPhaseListMallTab:SetScript("OnClick", function(self, button)
    EpsilonPhases.UpdatePhaseMallsHorizCache()
    SetPhaseListToMalls()
end)
