--#region Setup and models
local addonName = ...
BlueprintManager = {}

BlueprintManager.selectedTagForFiltering={}

-- Safe comparison function for blueprint sorting
local function safeCompare(a, b, field)
    local valueA = a[field] or ""
    local valueB = b[field] or ""
    
    -- Handle numeric fields
    if field == "blueprintObjectCount" then
        valueA = tonumber(valueA) or 0
        valueB = tonumber(valueB) or 0
    end
    
    -- Handle string fields (convert to lowercase for case-insensitive sorting)
    if type(valueA) == "string" and type(valueB) == "string" then
        valueA = string.lower(valueA)
        valueB = string.lower(valueB)
    end
    
    return valueA < valueB
end

BlueprintManager.orderingModeList={
    {label="Default",func= function(a,b) return safeCompare(a, b, "dateOfCreation") end},
    {label="By name (A-Z)",func= function(a,b) return safeCompare(a, b, "blueprintName") end},
    {label="By name (Z-A)",func= function(a,b) return safeCompare(b, a, "blueprintName") end},
    {label="By creator (A-Z)",func= function(a,b) return safeCompare(a, b, "creator") end},
    {label="By creator (Z-A)",func= function(a,b) return safeCompare(b, a, "creator") end},
    {label="By date (oldest first)",func= function(a,b) return safeCompare(a, b, "dateOfCreation") end},
    {label="By date (newest first)",func= function(a,b) return safeCompare(b, a, "dateOfCreation") end},
    {label="By object count (less first)",func= function(a,b) return safeCompare(a, b, "blueprintObjectCount") end},
    {label="By object count (more first)",func= function(a,b) return safeCompare(b, a, "blueprintObjectCount") end},
}
BlueprintManager.lastOrderingMode="Default"

-- Variables saved to WTF
BlueprintManagerSavedVars = BlueprintManagerSavedVars or {}

-- Initialize saved variables with defaults
local function InitializeSavedVars()
    BlueprintManagerSavedVars.lastOrderingMode = BlueprintManagerSavedVars.lastOrderingMode or "Default"
    BlueprintManager.lastOrderingMode = BlueprintManagerSavedVars.lastOrderingMode
end

-- Save variables to WTF
local function SaveVarsToWTF()
    BlueprintManagerSavedVars.lastOrderingMode = BlueprintManager.lastOrderingMode
end

-- Function to apply sorting based on selected mode
local function ApplySorting()
    if not BlueprintManagerData or not BlueprintManagerData.blueprint then
        return
    end
    
    -- Find the sorting function for the current mode
    local sortFunc = nil
    for _, mode in ipairs(BlueprintManager.orderingModeList) do
        if mode.label == BlueprintManager.lastOrderingMode then
            sortFunc = mode.func
            break
        end
    end
    
    -- Apply sorting if a function is found
    if sortFunc then
        table.sort(BlueprintManagerData.blueprint, sortFunc)
    end
    
    -- Refresh the left panel to show sorted results
    BlueprintManager.RefreshLeftPanelKeepOffset()
end

-- Function to create ordering dropdown
local function CreateOrderingDropdown(parent)
    local dropdown = CreateFrame("Frame", "BlueprintOrderingDropdown", parent, "UIDropDownMenuTemplate")
    dropdown:SetPoint("TOPLEFT", 47.5, -20) -- Position to the right of refresh button
    
    -- Initialize dropdown
    UIDropDownMenu_SetWidth(dropdown, 120)
    UIDropDownMenu_SetText(dropdown, BlueprintManager.lastOrderingMode)
    
    -- Dropdown initialization function
    local function InitializeDropdown(self, level)
        local info = UIDropDownMenu_CreateInfo()
        
        for i, mode in ipairs(BlueprintManager.orderingModeList) do
            info.text = mode.label
            info.value = mode.label
            info.func = function()
                BlueprintManager.lastOrderingMode = mode.label
                UIDropDownMenu_SetText(dropdown, mode.label)
                SaveVarsToWTF() -- Save the selection
                ApplySorting() -- Apply the sorting
            end
            info.checked = (mode.label == BlueprintManager.lastOrderingMode)
            UIDropDownMenu_AddButton(info, level)
        end
    end
    
    UIDropDownMenu_Initialize(dropdown, InitializeDropdown)
    
    return dropdown
end

-- Event frame for ADDON_LOADED and PLAYER_LOGOUT
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_LOGOUT")
eventFrame:SetScript("OnEvent", function(self, event, addonName)
    if event == "ADDON_LOADED" and addonName == "BlueprintManager" then
        InitializeSavedVars()
    elseif event == "PLAYER_LOGOUT" then
        SaveVarsToWTF()
    end
end)

--BlueprintManagerData={}
-- model for blueprint data 
-- [blueprintId] = {
--         blueprintName = "",
--         blueprintObjectCount = 0,
--         creator = "",
--         dateOfCreation = "",
--         icon="",
--         tags={NUMBERS},
--}
--BlueprintManagerData.blueprint={}

--model for tags data 
-- [tagId] = {
--         tagName = "",
--         icon="",
--         color=""
--}
--BlueprintManagerData.tags={}
-- // EpsilonLib for AddOnCommands:
local sendAddonCmd

if EpsilonLib and EpsilonLib.AddonCommands then
    sendAddonCmd = EpsilonLib.AddonCommands.Register("BlueprintManager")
else
    -- command, callbackFn, forceShowMessages
    function sendAddonCmd(command, callbackFn, forceShowMessages)
        if EpsilonLib and EpsilonLib.AddonCommands then
            -- Reassign it.
            sendAddonCmd = EpsilonLib.AddonCommands.Register("BlueprintManager")
            sendAddonCmd(command, callbackFn, forceShowMessages)
            return
        end

        -- Fallback ...
        print("Something went wrong with epsilib... report this please")
        SendChatMessage("." .. command, "GUILD")
    end
end

--#endregion

local lastClickedObject;
local lastClickedObjectIndex;
local lastOffset=0
local filteredTags = {}
local isFilteringTags = false

local function RGBAToNormalized(r, g, b,a)
    return r / 255, g / 255, b / 255, a / 255
end

local function TruncateTextToWidth(text, fontString, maxWidth)
    -- Handle empty or nil text
    if not text or text == "" then
        return ""
    end
    
    local originalFontString = fontString
    local isEditBox = fontString:GetObjectType() == "EditBox"
    
    -- If fontString is an editbox, create a temp fontString for measurement
    if isEditBox then
        local tempFontString = fontString:CreateFontString(nil, "OVERLAY")
        -- Get font from EditBox, with fallback
        local fontObject = fontString:GetFontObject()
        if fontObject then
            tempFontString:SetFontObject(fontObject)
        else
            -- Fallback to a default font if EditBox doesn't have one
            tempFontString:SetFontObject("GameFontHighlight")
        end
        fontString = tempFontString
    end
    
    -- Set the text temporarily to measure it
    fontString:SetText(text)
    local textWidth = fontString:GetStringWidth()
    
    -- If it fits, return as is (don't modify EditBox)
    if textWidth <= maxWidth then
        if not isEditBox then
            fontString:SetText(text)
        end
        return text
    end
    
    -- If it doesn't fit, truncate with ellipsis
    local ellipsis = "..."
    fontString:SetText(ellipsis)
    local ellipsisWidth = fontString:GetStringWidth()
    
    -- If even ellipsis doesn't fit, return just ellipsis
    if ellipsisWidth > maxWidth then
        if not isEditBox then
            fontString:SetText(ellipsis)
        end
        return ellipsis
    end
    
    -- Binary search to find the longest text that fits
    local left, right = 1, #text
    local result = ""
    
    while left <= right do
        local mid = math.floor((left + right) / 2)
        local truncated = string.sub(text, 1, mid) .. ellipsis
        fontString:SetText(truncated)
        local truncatedWidth = fontString:GetStringWidth()
        
        if truncatedWidth <= maxWidth then
            result = truncated
            left = mid + 1
        else
            right = mid - 1
        end
    end
    
    local finalResult = result ~= "" and result or ellipsis
    
    -- Only set text on the original fontString if it's NOT an EditBox
    if not isEditBox then
        originalFontString:SetText(finalResult)
    end

    return finalResult
end

function BlueprintManager.HideTooltip()
    GameTooltip:Hide() -- Cache le tooltip
end

function BlueprintManager.ShowTooltip(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT") -- Positionne le tooltip à droite du bouton
    
    -- Clear any existing tooltip content
    GameTooltip:ClearLines()
    
    local text = self.tooltipText or ""
    local maxLineLength = 50 -- Increased to allow more text per line
    
    -- Function to break long text into manageable chunks (word-aware)
    local function wrapText(inputText, maxLen)
        local lines = {}
        
        -- Split by existing line breaks first
        for line in (inputText .. "\n"):gmatch("([^\n]*)\n") do
            if #line <= maxLen then
                if #line > 0 then -- Don't add empty lines
                    table.insert(lines, line)
                end
            else
                -- Break long lines at word boundaries
                local words = {}
                for word in line:gmatch("%S+") do
                    table.insert(words, word)
                end
                
                local currentLine = ""
                for i, word in ipairs(words) do
                    local testLine = currentLine == "" and word or (currentLine .. " " .. word)
                    if #testLine <= maxLen then
                        currentLine = testLine
                    else
                        -- Add current line and start new one
                        if currentLine ~= "" then
                            table.insert(lines, currentLine)
                        end
                        currentLine = word
                    end
                end
                
                -- Add the last line if it's not empty
                if currentLine ~= "" then
                    table.insert(lines, currentLine)
                end
            end
        end
        
        return lines
    end
    
    -- Always use the wrapping approach for consistency
    local wrappedLines = wrapText(text, maxLineLength)
    
    if #wrappedLines > 1 then
        -- For multi-line tooltips, combine all lines with newlines and use SetText
        local combinedText = table.concat(wrappedLines, "\n")
        GameTooltip:SetText(combinedText, 1, 1, 1, 1, true)
    elseif #wrappedLines == 1 then
        -- Single line tooltip
        GameTooltip:SetText(wrappedLines[1], 1, 1, 1, 1, false)
    else
        -- Fallback for empty text
        GameTooltip:SetText(text, 1, 1, 1, 1, false)
    end
    
    GameTooltip:Show() -- Affiche le tooltip
end

function BlueprintManager.RegisterTooltip(frame, tooltip)
    frame.tooltipText = tooltip
    frame:HookScript("OnEnter", BlueprintManager.ShowTooltip)
    frame:HookScript("OnLeave", PhaseToolkit.HideTooltip)
end

local function disableInteraction(component)
    component:EnableMouse(false)
    component:SetMouseClickEnabled(false)
end

local function enableInteraction(component)
    component:EnableMouse(true)
    component:SetMouseClickEnabled(true)
end

local function getTagInfoByName(tagName)
    if BlueprintManagerData.tags then
        for i, tag in ipairs(BlueprintManagerData.tags) do
            if tag.name == tagName then
                return tag
            end
        end
    end
    return nil
end

local function UpdateBlueprint(BlueprintToLoad)
    if BlueprintToLoad then
        -- Use the stored full name if available, otherwise get from EditBox
        local newName = BlueprintManager.currentBlueprintFullNameUntruncated or BlueprintManager.editionPanel.champDeNom:GetText()
        
        -- Store original name for comparison
        local originalName = BlueprintToLoad.blueprintName
        
        --getting rid of space in the name of the blueprint
        newName = newName:gsub("%s+", "_")
        local newDescription = BlueprintManager.editionPanel.descriptionField:GetText()

        if newDescription ~= BlueprintToLoad.description then
            sendAddonCmd("gobject blueprint description "..originalName.." "..newDescription,function(success, replies)
                BlueprintToLoad.description = newDescription;
                if success then
                    BlueprintManager.RefreshLeftPanelKeepOffset()
                    BlueprintManager.createRightPanelForMainFrame(BlueprintToLoad)
                end
            end)
            return
        end
        print("Renaming blueprint to "..newName)
        if newName ~= originalName then
            sendAddonCmd("gobject blueprint rename "..originalName.." "..newName, function(success, replies)
            BlueprintToLoad.blueprintName = newName;
            BlueprintManager.currentBlueprintFullNameUntruncated = newName; -- Update stored name
            if success then
                BlueprintManager.RefreshLeftPanelKeepOffset()
                BlueprintManager.createRightPanelForMainFrame(BlueprintToLoad)
            end
            end)
            return
        end

        BlueprintManager.RefreshLeftPanelKeepOffset()
        BlueprintManager.createRightPanelForMainFrame(BlueprintToLoad)
    end
end

local function createTechnicalButton(BlueprintToLoad)
    BlueprintManager.editionPanel.SpawnButton= CreateFrame("Button", nil, BlueprintManager.editionPanel)
    BlueprintManager.editionPanel.SpawnButton:SetSize(25, 25)
    BlueprintManager.editionPanel.SpawnButton:SetPoint("TOPLEFT",-5,29)
    BlueprintManager.editionPanel.SpawnButton.icon = BlueprintManager.editionPanel.SpawnButton:CreateTexture(nil, "OVERLAY")

    BlueprintManager.editionPanel.SpawnButton.icon:SetTexture("Interface\\AddOns\\BlueprintManager\\assets\\buttons\\BPMAddButton.blp")
    BlueprintManager.editionPanel.SpawnButton.icon:SetSize(25,25)
    BlueprintManager.editionPanel.SpawnButton.icon:SetAllPoints()
    
    BlueprintManager.editionPanel.SpawnButton:SetScript("OnEnter", function(self)
        self.icon:SetVertexColor(0.8, 0.8, 1, 1) -- Light blue highlight
    end)

    BlueprintManager.editionPanel.SpawnButton:SetScript("OnLeave", function(self)
        self.icon:SetVertexColor(1, 1, 1, 1) -- Reset to normal
    end)

    BlueprintManager.editionPanel.SpawnButton:SetScript("OnMouseDown", function(self)
        self:SetSize(23, 23)
    end)
    BlueprintManager.editionPanel.SpawnButton:SetScript("OnMouseUp", function(self)
        self:SetSize(25, 25)
    end)
    BlueprintManager.RegisterTooltip(BlueprintManager.editionPanel.SpawnButton, "Spawn the blueprint")

    if(not BlueprintToLoad) then
        disableInteraction(BlueprintManager.editionPanel.SpawnButton);
    
        BlueprintManager.editionPanel.SpawnButton:SetScript("OnClick", function()
        end)
    else
        enableInteraction(BlueprintManager.editionPanel.SpawnButton);
        
        BlueprintManager.editionPanel.SpawnButton:SetScript("OnClick", function()
            sendAddonCmd("gobject blueprint spawn "..BlueprintToLoad.blueprintName)
        end)
    end

    BlueprintManager.editionPanel.deleteButton = CreateFrame("Button", nil, BlueprintManager.editionPanel)
    BlueprintManager.editionPanel.deleteButton:SetSize(25, 25)
    BlueprintManager.editionPanel.deleteButton:SetPoint("TOPLEFT",20,29)
    BlueprintManager.editionPanel.deleteButton.icon = BlueprintManager.editionPanel.deleteButton:CreateTexture(nil, "OVERLAY")
    BlueprintManager.editionPanel.deleteButton.icon:SetTexture("Interface\\AddOns\\BlueprintManager\\assets\\buttons\\BPMXButton.blp")
    BlueprintManager.editionPanel.deleteButton.icon:SetSize(25,25)
    BlueprintManager.editionPanel.deleteButton.icon:SetAllPoints()

    BlueprintManager.editionPanel.deleteButton:SetScript("OnEnter", function(self)
        self.icon:SetVertexColor(0.8, 0.8, 1, 1) -- Light blue highlight
    end)

    BlueprintManager.editionPanel.deleteButton:SetScript("OnLeave", function(self)
        self.icon:SetVertexColor(1, 1, 1, 1) -- Reset to normal
    end)

    BlueprintManager.editionPanel.deleteButton:SetScript("OnMouseDown", function(self)
        self:SetSize(23, 23)
    end)
    BlueprintManager.editionPanel.deleteButton:SetScript("OnMouseUp", function(self)
        self:SetSize(25, 25)
    end)
    -- color the word "DELETE" in the tooltip
    --#FFFF0000

    BlueprintManager.RegisterTooltip(BlueprintManager.editionPanel.deleteButton, "|cffff0000Delete|r the blueprint from your blueprints")

    if(not BlueprintToLoad) then
        disableInteraction(BlueprintManager.editionPanel.deleteButton);
    
        BlueprintManager.editionPanel.deleteButton:SetScript("OnClick", function()
        end)
    else
        enableInteraction(BlueprintManager.editionPanel.deleteButton);
        
        BlueprintManager.editionPanel.deleteButton:SetScript("OnClick", function()
            StaticPopup_Show("CONFIRM_DELETE_BLUEPRINT", nil, nil, BlueprintToLoad)
        end)
    end

    BlueprintManager.editionPanel.resetButton = CreateFrame("Button", nil, BlueprintManager.editionPanel)
    BlueprintManager.editionPanel.resetButton:SetSize(25, 25)
    BlueprintManager.editionPanel.resetButton:SetPoint("TOPLEFT", -30, 29)
    BlueprintManager.editionPanel.resetButton.texture = BlueprintManager.editionPanel.resetButton:CreateTexture(nil, "BORDER")
    BlueprintManager.editionPanel.resetButton.texture:SetTexture("Interface\\AddOns\\BlueprintManager\\assets\\buttons\\BPMBackButton.blp")
    BlueprintManager.editionPanel.resetButton.texture:SetSize(25,25)
    BlueprintManager.editionPanel.resetButton.texture:SetAllPoints()

    BlueprintManager.editionPanel.resetButton:SetScript("OnEnter", function(self)
        self.texture:SetVertexColor(0.8, 0.8, 1, 1) -- Light blue highlight
    end)

    BlueprintManager.editionPanel.resetButton:SetScript("OnLeave", function(self)
        self.texture:SetVertexColor(1, 1, 1, 1) -- Reset to normal
    end)

    BlueprintManager.editionPanel.resetButton:SetScript("OnMouseDown", function(self)
        self:SetSize(23, 23)
    end)
    BlueprintManager.editionPanel.resetButton:SetScript("OnMouseUp", function(self)
        self:SetSize(25, 25)
    end)


    BlueprintManager.RegisterTooltip(BlueprintManager.editionPanel.resetButton, "Stop modifying the blueprint")

    if(not BlueprintToLoad) then
        disableInteraction(BlueprintManager.editionPanel.resetButton);
    
        BlueprintManager.editionPanel.resetButton:SetScript("OnClick", function()end)
    else
        enableInteraction(BlueprintManager.editionPanel.resetButton);
        
        BlueprintManager.editionPanel.resetButton:SetScript("OnClick", function()
            if(lastClickedObject and lastClickedObjectIndex) then
                lastClickedObject.background:SetVertexColor(1, 1, 1) -- Revert to original color
                lastClickedObject = nil
                lastClickedObjectIndex = nil
            end
            BlueprintManager.createRightPanelForMainFrame()
        end)
    end

    BlueprintManager.editionPanel.updateButton = CreateFrame("Button", nil, BlueprintManager.editionPanel)
    BlueprintManager.editionPanel.updateButton:SetSize(25, 25)
    BlueprintManager.editionPanel.updateButton:SetPoint("TOPLEFT",45,29)
    BlueprintManager.editionPanel.updateButton.texture = BlueprintManager.editionPanel.updateButton:CreateTexture(nil, "OVERLAY")
    BlueprintManager.editionPanel.updateButton.texture:SetTexture("Interface\\AddOns\\BlueprintManager\\assets\\buttons\\BPMUpButton.blp")
    BlueprintManager.editionPanel.updateButton.texture:SetSize(25,25)
    BlueprintManager.editionPanel.updateButton.texture:SetAllPoints()

    BlueprintManager.editionPanel.updateButton:SetScript("OnEnter", function(self)
        self.texture:SetVertexColor(0.8, 0.8, 1, 1) -- Light blue highlight
    end)

    BlueprintManager.editionPanel.updateButton:SetScript("OnLeave", function(self)
        self.texture:SetVertexColor(1, 1, 1, 1) -- Reset to normal
    end)

    BlueprintManager.editionPanel.updateButton:SetScript("OnMouseDown", function(self)
        self:SetSize(23, 23)
    end)
    BlueprintManager.editionPanel.updateButton:SetScript("OnMouseUp", function(self)
        self:SetSize(25, 25)
    end)

    if(not BlueprintToLoad) then
        disableInteraction(BlueprintManager.editionPanel.updateButton);
    
        BlueprintManager.editionPanel.updateButton:SetScript("OnClick", function()end)
    else
        enableInteraction(BlueprintManager.editionPanel.updateButton);
        
        BlueprintManager.editionPanel.updateButton:SetScript("OnClick", function()
            StaticPopup_Show("CONFIRM_UPDATE_BLUEPRINT", nil, nil, BlueprintToLoad)
        end)
    end

    BlueprintManager.RegisterTooltip(BlueprintManager.editionPanel.updateButton, "Update the blueprint with selected group")


    BlueprintManager.editionPanel.validationButton = CreateFrame("Button", nil, BlueprintManager.editionPanel)
    BlueprintManager.editionPanel.validationButton:SetSize(25, 25)
    BlueprintManager.editionPanel.validationButton:SetPoint("TOPRIGHT",BlueprintManager.editionPanel,"TOPRIGHT",15,29)
    BlueprintManager.editionPanel.validationButton.texture = BlueprintManager.editionPanel.validationButton:CreateTexture(nil, "OVERLAY")
    BlueprintManager.editionPanel.validationButton.texture:SetTexture("Interface/AddOns/"..addonName.."/assets/buttons/BPMTickButton.blp")
    BlueprintManager.editionPanel.validationButton.texture:SetSize(25,25)
    BlueprintManager.editionPanel.validationButton.texture:SetAllPoints()

    BlueprintManager.editionPanel.validationButton:SetScript("OnEnter", function(self)
        self.texture:SetVertexColor(0.8, 0.8, 1, 1) -- Light blue highlight
    end)

    BlueprintManager.editionPanel.validationButton:SetScript("OnLeave", function(self)
        self.texture:SetVertexColor(1, 1, 1, 1) -- Reset to normal
    end)

    BlueprintManager.editionPanel.validationButton:SetScript("OnMouseDown", function(self)
        self:SetSize(23, 23)
    end)
    BlueprintManager.editionPanel.validationButton:SetScript("OnMouseUp", function(self)
        self:SetSize(25, 25)
    end)

    BlueprintManager.RegisterTooltip(BlueprintManager.editionPanel.validationButton, "Apply the changes")

    if(not BlueprintToLoad) then
        disableInteraction(BlueprintManager.editionPanel.validationButton);
    
        BlueprintManager.editionPanel.validationButton:SetScript("OnClick", function()end)
    else
        enableInteraction(BlueprintManager.editionPanel.validationButton);
        
        BlueprintManager.editionPanel.validationButton:SetScript("OnClick", function()
            StaticPopup_Show("CONFIRM_APPLY_CHANGES", nil, nil, BlueprintToLoad)
        end)
    end

end

local function createTagListForRightPanel(lineTexture,BlueprintToLoad)
    for i = 1, 4 do
        local blueprintFrame = _G["RPTagFrame"..i] 
        if blueprintFrame then
            blueprintFrame:Hide()
            _G["RPTagFrame"..i]  = nil
        end
    end
    
    BlueprintManager.editionPanel.tagSection = CreateFrame("Frame", nil, BlueprintManager.editionPanel)
    BlueprintManager.editionPanel.tagSection:SetSize(200, 100)
    BlueprintManager.editionPanel.tagSection:SetPoint("TOP", lineTexture, "BOTTOM", 0, -10)

    BlueprintManager.editionPanel.tagSection.title = BlueprintManager.editionPanel.tagSection:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    BlueprintManager.editionPanel.tagSection.title:SetPoint("TOP", BlueprintManager.editionPanel.tagSection, "TOP", -70, 5)
    BlueprintManager.editionPanel.tagSection.title:SetText("Tags")

    BlueprintManager.editionPanel.tagSection.tagList = CreateFrame("Frame", nil, BlueprintManager.editionPanel.tagSection)
    BlueprintManager.editionPanel.tagSection.tagList:SetSize(110, 80)
    BlueprintManager.editionPanel.tagSection.tagList:SetPoint("TOP", BlueprintManager.editionPanel.tagSection, "BOTTOM", 20, -5)

    -- Create scroll frame with original positioning
    BlueprintManager.editionPanel.tagSection.tagList.scrollFrame = CreateFrame("ScrollFrame", nil, BlueprintManager.editionPanel.tagSection.tagList, "FauxScrollFrameTemplate")
    BlueprintManager.editionPanel.tagSection.tagList.scrollFrame:SetPoint("TOPLEFT",BlueprintManager.editionPanel.tagSection.title,"BOTTOMLEFT", -40, -5)
    BlueprintManager.editionPanel.tagSection.tagList.scrollFrame:SetSize(110, 120)
    BlueprintManager.editionPanel.tagSection.tagList.scrollFrame.ScrollBar:Hide()

    BlueprintManager.editionPanel.tagSection.tagList.scrollFrame.ScrollBar = CreateFrame("Slider", nil, BlueprintManager.editionPanel.tagSection.tagList.scrollFrame, "UIPanelScrollBarTemplate")
    BlueprintManager.editionPanel.tagSection.tagList.scrollFrame.ScrollBar:SetMinMaxValues(0, math.max(0, math.ceil(#BlueprintToLoad.tags/6) - 1))
    BlueprintManager.editionPanel.tagSection.tagList.scrollFrame.ScrollBar:SetValueStep(1)
    BlueprintManager.editionPanel.tagSection.tagList.scrollFrame.ScrollBar.scrollStep = 1
    BlueprintManager.editionPanel.tagSection.tagList.scrollFrame.ScrollBar:SetValue(0)
    BlueprintManager.editionPanel.tagSection.tagList.scrollFrame.ScrollBar:SetWidth(16)
    BlueprintManager.editionPanel.tagSection.tagList.scrollFrame:Show()
    BlueprintManager.editionPanel.tagSection.tagList.scrollFrame.ScrollBar:SetScript("OnValueChanged", function(self, value)
        FauxScrollFrame_OnVerticalScroll(self:GetParent(), value, 20, function()
            BlueprintManager.editionPanel.tagSection.tagList.Update()
        end)
    end)

    local content = CreateFrame("Frame", nil, BlueprintManager.editionPanel.tagSection.tagList)
    content:SetSize(BlueprintManager.editionPanel.tagSection.tagList.scrollFrame:GetWidth(), BlueprintManager.editionPanel.tagSection.tagList.scrollFrame:GetHeight())
    content:SetPoint("TOPLEFT",BlueprintManager.editionPanel.tagSection.title,"BOTTOMLEFT", -40, -5)
    content:Show()
    
    -- Also enable mouse wheel on content frame
    content:EnableMouseWheel(true)
    content:SetScript("OnMouseWheel", function(self, direction)
        -- Forward to parent scrollFrame
        BlueprintManager.editionPanel.tagSection.tagList.scrollFrame:GetScript("OnMouseWheel")(BlueprintManager.editionPanel.tagSection.tagList.scrollFrame, direction)
    end)

    -- Update function for the scroll frame
    function BlueprintManager.editionPanel.tagSection.tagList.Update()
        local scrollOffset = BlueprintManager.editionPanel.tagSection.tagList.scrollFrame.ScrollBar:GetValue()
        local numTags = #BlueprintToLoad.tags
        
        for i = 1, 6 do
            local index = scrollOffset * 6 + i
            local tagFrame = _G["RPTagFrame"..i]

            if not tagFrame then
                tagFrame = CreateFrame("Frame", "RPTagFrame"..i, content)
                tagFrame:SetSize(110, 20)
                tagFrame:SetPoint("TOPLEFT", 0, -((i - 1) * 20))

                tagFrame.background = tagFrame:CreateTexture(nil, "BACKGROUND")
                tagFrame.background:SetTexture("Interface/AddOns/"..addonName.."/assets/BlueprintManagerFrame.blp");
                    tagFrame.background:SetTexCoord(
                        77/512, (77+360)/512,
                        26/128, (26+78)/128
                    );
                tagFrame.background:SetPoint("TOPLEFT", 0, 0)
                tagFrame.background:SetSize(tagFrame:GetWidth(), tagFrame:GetHeight())

                tagFrame.topLeftDecoration = tagFrame:CreateTexture(nil, "OVERLAY")
                tagFrame.topLeftDecoration:SetTexture("Interface/AddOns/"..addonName.."/assets/CornerTopLeft.blp");
                tagFrame.topLeftDecoration:SetPoint("TOPLEFT", tagFrame, "TOPLEFT", 1, 0)
                tagFrame.topLeftDecoration:SetSize(20, 20)

                tagFrame.bottomRightDecoration = tagFrame:CreateTexture(nil, "OVERLAY")
                tagFrame.bottomRightDecoration:SetTexture("Interface/AddOns/"..addonName.."/assets/CornerBottomRight.blp");
                tagFrame.bottomRightDecoration:SetPoint("BOTTOMRIGHT", tagFrame, "BOTTOMRIGHT", -1, 0)
                tagFrame.bottomRightDecoration:SetSize(20, 20)

                tagFrame.nameText = tagFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
                tagFrame.nameText:SetPoint("LEFT",tagFrame.background,"LEFT", 10, 0)
                tagFrame.nameText:SetSize(100, 20)
                tagFrame.nameText:SetJustifyH("LEFT")
                -- use the triming func here
            end

            if index <= numTags then
                local tag = BlueprintToLoad.tags[index]

                TruncateTextToWidth(tag, tagFrame.nameText,100)

                local fetchedTag=getTagInfoByName(tag)
                if fetchedTag then
                    local color = CreateColorFromHexString("FF"..fetchedTag.color[1])
                    local r,g,b = color:GetRGB()
                    tagFrame.topLeftDecoration:SetVertexColor(r,g,b)
                    tagFrame.bottomRightDecoration:SetVertexColor(r,g,b)
                else
                    -- Use default colors when tag doesn't exist in database
                    tagFrame.topLeftDecoration:SetVertexColor(0.5, 0.5, 0.5) -- Gray
                    tagFrame.bottomRightDecoration:SetVertexColor(0.5, 0.5, 0.5) -- Gray
                end
                tagFrame:Show()
            else
                tagFrame:Hide()
            end
        end

        -- Update scrollbar range based on current number of tags
        local maxScroll = math.max(0, math.ceil(numTags/6) - 1)
        BlueprintManager.editionPanel.tagSection.tagList.scrollFrame.ScrollBar:SetMinMaxValues(0, maxScroll)
        
        -- Don't use FauxScrollFrame_Update as it overrides our scrollbar settings
    end

    BlueprintManager.editionPanel.tagSection.tagList.scrollFrame:SetScript("OnVerticalScroll", function(self, offset)
        FauxScrollFrame_OnVerticalScroll(self, offset, 20, function()
            BlueprintManager.editionPanel.tagSection.tagList.Update()
        end)
    end)

    -- Enable mouse wheel scrolling
    BlueprintManager.editionPanel.tagSection.tagList.scrollFrame:EnableMouseWheel(true)
    
    BlueprintManager.editionPanel.tagSection.tagList.scrollFrame:SetScript("OnMouseWheel", function(self, direction)
        local scrollBar = self.ScrollBar
        local currentValue = scrollBar:GetValue()
        local minValue, maxValue = scrollBar:GetMinMaxValues()
        
        local newValue
        if direction > 0 then
            -- Scroll up
            newValue = math.max(minValue, currentValue - 1)
        else
            -- Scroll down  
            newValue = math.min(maxValue, currentValue + 1)
        end
        
        -- Force the scroll update even if value doesn't change
        if newValue ~= currentValue then
            scrollBar:SetValue(newValue)
        else
            -- Manually trigger the scroll update when at boundaries
            FauxScrollFrame_OnVerticalScroll(self, newValue * 20, 20, function()
                BlueprintManager.editionPanel.tagSection.tagList.Update()
            end)
        end
    end)

    BlueprintManager.editionPanel.tagSection.tagList.Update()

    -- Adjust the position of the vertical scroll bar (ORIGINAL POSITIONING)
    BlueprintManager.editionPanel.tagSection.tagList.scrollFrame.ScrollBar:ClearAllPoints()
    BlueprintManager.editionPanel.tagSection.tagList.scrollFrame.ScrollBar:SetPoint("TOPRIGHT", BlueprintManager.editionPanel.tagSection.tagList.scrollFrame, "TOPRIGHT", 18, -18)
    BlueprintManager.editionPanel.tagSection.tagList.scrollFrame.ScrollBar:SetPoint("BOTTOMRIGHT", BlueprintManager.editionPanel.tagSection.tagList.scrollFrame, "BOTTOMRIGHT", 18, 18)
end

function BlueprintManager.RefreshLeftPanelKeepOffset()
    -- Throttle re-entrant calls to avoid rapid repeated recreation loops
    -- If a refresh is already in progress, ignore subsequent calls for a short window.
    if BlueprintManager._isRefreshingLeftPanel then
        -- Debug print kept minimal to avoid flooding; uncomment for deeper diagnostics
        -- print("RefreshLeftPanelKeepOffset: already running, skipping")
        return
    end
    BlueprintManager._isRefreshingLeftPanel = true
    -- safety reset in case something went wrong; unlock after 0.6s
    C_Timer.After(0.6, function() BlueprintManager._isRefreshingLeftPanel = false end)

    if not BlueprintManager.mainFrame or not BlueprintManager.mainFrame.leftPannel or not BlueprintManager.mainFrame.leftPannel.scrollFrame then
        BlueprintManager._isRefreshingLeftPanel = false
        return
    end

    -- Diagnostic helper: when enabled, print a rate-limited stacktrace to help identify
    -- where repeated calls originate. Enable by setting BlueprintManager._diagnoseRefresh = true
    -- (you can toggle it at runtime from the Lua console). Rate-limited to once per 5s.
    if BlueprintManager._diagnoseRefresh then
        if not BlueprintManager._didLogStack then
            BlueprintManager._didLogStack = true
            print("[BlueprintManager] RefreshLeftPanelKeepOffset diagnostic stacktrace:")
            if debugstack then
                print(debugstack(2, 10, 0))
            else
                print("(debugstack not available)")
            end
            C_Timer.After(5, function() BlueprintManager._didLogStack = false end)
        end
    end

    local scrollBar = BlueprintManager.mainFrame.leftPannel.scrollFrame.ScrollBar
    local currentOffset = scrollBar:GetValue()
    BlueprintManager.createLeftPanelForMainFrame(true, true, false, isFilteringTags)
    C_Timer.After(0.25, function()
        if BlueprintManager.mainFrame and BlueprintManager.mainFrame.leftPannel and BlueprintManager.mainFrame.leftPannel.scrollFrame then
            BlueprintManager.mainFrame.leftPannel.scrollFrame.ScrollBar:SetValue(currentOffset)
            if BlueprintManager.mainFrame.leftPannel.UpdateScrollFrame then
                BlueprintManager.mainFrame.leftPannel.UpdateScrollFrame(isFilteringTags)
            end
        end
    end)
end

local function createTagAddingThing(lineTexture,BlueprintToLoad)
    -- Create a search-enabled tag selector
    local tagSelector = CreateFrame("Frame", nil, BlueprintManager.editionPanel)
    tagSelector:SetSize(150, 140)
    tagSelector:SetPoint("TOP", lineTexture, "BOTTOM", 70, -20)
    
    -- Title
    tagSelector.title = tagSelector:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    tagSelector.title:SetPoint("TOP", 0, 15)
    tagSelector.title:SetText("Add/Remove Tags")
    
    -- Search box
    tagSelector.searchBox = CreateFrame("EditBox", nil, tagSelector, "InputBoxTemplate")
    tagSelector.searchBox:SetSize(115, 20)
    tagSelector.searchBox:SetPoint("TOP", tagSelector.title, "BOTTOM", 0, -5)
    tagSelector.searchBox:SetAutoFocus(false)
    tagSelector.searchBox:SetFontObject("GameFontHighlight")
    tagSelector.searchBox:SetMaxLetters(50)
    tagSelector.searchBox:SetScript("OnEnterPressed", function(self) self:ClearFocus() end)
    tagSelector.searchBox:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
    
    -- Search placeholder text
    tagSelector.searchBox.placeholder = tagSelector.searchBox:CreateFontString(nil, "OVERLAY", "GameFontDisable")
    tagSelector.searchBox.placeholder:SetPoint("LEFT", 8, 0)
    tagSelector.searchBox.placeholder:SetText("Search tags...")
    
    -- Container for the tag list (like the existing tag list)
    tagSelector.tagListContainer = CreateFrame("Frame", nil, tagSelector)
    tagSelector.tagListContainer:SetSize(140, 100)
    tagSelector.tagListContainer:SetPoint("TOP", tagSelector.searchBox, "BOTTOM", 0, -5)
    
    -- Scroll frame using the same style as existing tag list
    tagSelector.scrollFrame = CreateFrame("ScrollFrame", nil, tagSelector.tagListContainer, "FauxScrollFrameTemplate")
    tagSelector.scrollFrame:SetSize(140, 100)
    tagSelector.scrollFrame:SetPoint("TOPLEFT", 0, 0)
    tagSelector.scrollFrame.ScrollBar:Hide()
    
    -- Content frame (must be created before setting as scroll child)
    tagSelector.content = CreateFrame("Frame", nil, tagSelector.scrollFrame)
    tagSelector.content:SetSize(140, 100)
    tagSelector.scrollFrame:SetScrollChild(tagSelector.content)
    
    -- Custom scrollbar (same style as existing)
    tagSelector.scrollFrame.ScrollBar = CreateFrame("Slider", nil, tagSelector.scrollFrame, "UIPanelScrollBarTemplate")
    tagSelector.scrollFrame.ScrollBar:SetWidth(16)
    tagSelector.scrollFrame.ScrollBar:SetValueStep(1)
    tagSelector.scrollFrame.ScrollBar.scrollStep = 1
    tagSelector.scrollFrame.ScrollBar:SetValue(0)
    
    -- Filtered tags storage
    local filteredTagList = {}
    local selectorTagFrames = {}
    
    -- Function to filter tags based on search
    local function filterTags(searchText)
        filteredTagList = {}
        searchText = searchText:lower()
        
        -- Always show all available tags for selection
        for _, tag in ipairs(BlueprintManagerData.tags or {}) do
            if searchText == "" or tag.name:lower():find(searchText, 1, true) then
                table.insert(filteredTagList, tag)
            end
        end
        
        -- Update scrollbar with proper calculation
        local maxScroll = math.max(0, math.ceil(#filteredTagList/5) - 1)
        tagSelector.scrollFrame.ScrollBar:SetMinMaxValues(0, maxScroll)
        
        if #filteredTagList <= 5 then
            tagSelector.scrollFrame.ScrollBar:Hide()
        else
            tagSelector.scrollFrame.ScrollBar:Show()
        end
        
        updateTagDisplay()
    end
    
    -- Function to update tag display (matching existing tag list style)
    function updateTagDisplay()
        local scrollOffset = tagSelector.scrollFrame.ScrollBar:GetValue()
        
        -- Display 5 tags at a time (like existing lists)
        for i = 1, 5 do
            local index = math.floor(scrollOffset) * 5 + i
            
            -- Create frame if it doesn't exist (using same style as existing tag frames)
            if not selectorTagFrames[i] then
                local tagFrame = CreateFrame("Button", "SelectorTagFrame"..i, tagSelector.content)
                tagFrame:SetSize(130, 18)
                tagFrame:SetPoint("TOPLEFT", 5, -((i - 1) * 20 + 2))
                
                -- Background using same texture as existing tag list
                tagFrame.background = tagFrame:CreateTexture(nil, "BACKGROUND")
                tagFrame.background:SetTexture("Interface/AddOns/"..addonName.."/assets/BlueprintManagerFrame.blp")
                tagFrame.background:SetTexCoord(
                    77/512, (77+360)/512,   -- left, right (77 to 437)
                    26/128, (26+78)/128     -- top, bottom (26 to 104)
                )
                tagFrame.background:SetPoint("TOPLEFT", 0, 0)
                tagFrame.background:SetSize(130, 18)

                tagFrame.topLeftDecoration = tagFrame:CreateTexture(nil, "OVERLAY")
                tagFrame.topLeftDecoration:SetTexture("Interface/AddOns/"..addonName.."/assets/CornerTopLeft.blp");
                tagFrame.topLeftDecoration:SetPoint("TOPLEFT", tagFrame, "TOPLEFT", 1, 0)
                tagFrame.topLeftDecoration:SetSize(20, 20)

                tagFrame.bottomRightDecoration = tagFrame:CreateTexture(nil, "OVERLAY")
                tagFrame.bottomRightDecoration:SetTexture("Interface/AddOns/"..addonName.."/assets/CornerBottomRight.blp");
                tagFrame.bottomRightDecoration:SetPoint("BOTTOMRIGHT", tagFrame, "BOTTOMRIGHT", -1, 0)
                tagFrame.bottomRightDecoration:SetSize(20, 20)
                
                -- Text using same style as existing
                tagFrame.nameText = tagFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
                tagFrame.nameText:SetPoint("LEFT", tagFrame.background, "LEFT", 8, 0)
                tagFrame.nameText:SetSize(100, 18)
                tagFrame.nameText:SetJustifyH("LEFT")
                
                -- Checkmark for selected tags
                tagFrame.checkmark = tagFrame:CreateTexture(nil, "OVERLAY")
                tagFrame.checkmark:SetSize(12, 12)
                tagFrame.checkmark:SetPoint("RIGHT", -5, 0)
                tagFrame.checkmark:SetAtlas("UI-HUD-MicroMenu-StreamDLRed-Up")
                
                -- Hover effects (same as existing)
                tagFrame:SetScript("OnEnter", function(self)
                    self.background:SetVertexColor(0.5, 0.5, 1, 1)
                end)
                
                tagFrame:SetScript("OnLeave", function(self)
                    -- Only reset color if not selected
                    local isSelected = false
                    if index <= #filteredTagList then
                        local tag = filteredTagList[index]
                        isSelected = tContains(BlueprintToLoad.tags, tag.name)
                    end
                    if isSelected then
                        self.background:SetVertexColor(0.7, 1, 0.7, 1)
                    else
                        self.background:SetVertexColor(1, 1, 1, 1)
                    end
                end)
                
                selectorTagFrames[i] = tagFrame
            end
            
            local tagFrame = selectorTagFrames[i]
            
            if index <= #filteredTagList then
                local tag = filteredTagList[index]
                local truncatedText = TruncateTextToWidth(tag.name, tagFrame.nameText,130)
                if string.sub(truncatedText, -3) == "..." then
                    BlueprintManager.RegisterTooltip(tagFrame, tag.name)
                else
                    tagFrame:HookScript("OnEnter", function() end)
                    tagFrame:HookScript("OnLeave", function() end)
                end

                if tag then
                    local color = CreateColorFromHexString("FF"..tag.color[1])
                    local r,g,b = color:GetRGB()
                    tagFrame.topLeftDecoration:SetVertexColor(r,g,b)
                    tagFrame.bottomRightDecoration:SetVertexColor(r,g,b)
                else
                    -- Use default colors when tag doesn't exist in database
                    tagFrame.topLeftDecoration:SetVertexColor(0.5, 0.5, 0.5) -- Gray
                    tagFrame.bottomRightDecoration:SetVertexColor(0.5, 0.5, 0.5) -- Gray
                end
                
                -- Show/hide checkmark based on selection
                local isSelected = tContains(BlueprintToLoad.tags, tag.name)
                tagFrame.checkmark:SetShown(isSelected)
                
                -- Update background color to indicate selection
                if isSelected then
                    tagFrame.background:SetVertexColor(0.7, 1, 0.7, 1) -- Light green tint
                else
                    tagFrame.background:SetVertexColor(1, 1, 1, 1)
                end

                -- Click handler
                tagFrame:SetScript("OnClick", function()
                    if tContains(BlueprintToLoad.tags, tag.name) then
                        -- Remove tag
                        for j, existingTag in ipairs(BlueprintToLoad.tags) do
                            if existingTag == tag.name then
                                table.remove(BlueprintToLoad.tags, j)
                                break
                            end
                        end
                    else
                        -- Add tag
                        table.insert(BlueprintToLoad.tags, tag.name)
                    end

                    BlueprintManager.RefreshLeftPanelKeepOffset()
                    BlueprintManager.editionPanel.tagSection.tagList.Update()
                    updateTagDisplay() -- Refresh checkmarks
                end)
                
                tagFrame:Show()
            else
                tagFrame:Hide()
            end
        end
        
        -- Update scrollbar range and visibility
        local maxScroll = math.max(0, math.ceil(#filteredTagList/5) - 1)
        tagSelector.scrollFrame.ScrollBar:SetMinMaxValues(0, maxScroll)
        
        -- Don't use FauxScrollFrame_Update as it can override our custom scrollbar settings
    end
    
    -- Search box events
    tagSelector.searchBox:SetScript("OnTextChanged", function(self)
        local text = self:GetText()
        
        -- Show/hide placeholder
        tagSelector.searchBox.placeholder:SetShown(text == "")
        
        -- Filter tags and reset scroll to top
        tagSelector.scrollFrame.ScrollBar:SetValue(0)
        filterTags(text)
    end)
    
    -- Scrollbar events (fixed to work properly)
    tagSelector.scrollFrame.ScrollBar:SetScript("OnValueChanged", function(self, value)
        FauxScrollFrame_OnVerticalScroll(self:GetParent(), value, 20, updateTagDisplay)
    end)
    
    tagSelector.scrollFrame:SetScript("OnVerticalScroll", function(self, offset)
        FauxScrollFrame_OnVerticalScroll(self, offset, 20, updateTagDisplay)
    end)
    
    -- Position scrollbar relative to the scroll frame
    tagSelector.scrollFrame.ScrollBar:ClearAllPoints()
    tagSelector.scrollFrame.ScrollBar:SetPoint("TOPRIGHT", tagSelector.scrollFrame, "TOPRIGHT", 12, -16)
    tagSelector.scrollFrame.ScrollBar:SetPoint("BOTTOMRIGHT", tagSelector.scrollFrame, "BOTTOMRIGHT", 12, 16)
    
    -- Initialize display
    filterTags("")
    
    -- Store reference for cleanup
    BlueprintManager.editionPanel.tagSection.tagSelector = tagSelector
end

function BlueprintManager.createRightPanelForMainFrame(BlueprintToLoad)
    if BlueprintToLoad then 
        if BlueprintToLoad == lastClickedObject then
            return
        end
    end
    
    if(BlueprintManager.editionPanel) then
        BlueprintManager.editionPanel:Hide()
        BlueprintManager.editionPanel = nil
    end

    BlueprintManager.editionPanel= CreateFrame("Frame", nil, BlueprintManager.mainFrame);
    BlueprintManager.editionPanel:SetSize(230, 370)
    BlueprintManager.editionPanel:SetPoint("RIGHT",BlueprintManager.mainFrame, "RIGHT", -20, -10)

    if(BlueprintManager.editionPanel.champDeNom ==nil) then 
        BlueprintManager.editionPanel.champDeNom = CreateFrame("EditBox", nil, BlueprintManager.editionPanel )
    end
    if(not BlueprintToLoad) then
        disableInteraction(BlueprintManager.editionPanel.champDeNom);
    else
        enableInteraction(BlueprintManager.editionPanel.champDeNom);
    end

    BlueprintManager.editionPanel.champDeNom:SetSize(200, 30);
    BlueprintManager.editionPanel.champDeNom:SetPoint("TOPLEFT", 0, -15);
    BlueprintManager.editionPanel.champDeNom:SetAutoFocus(false);
    BlueprintManager.editionPanel.champDeNom:SetFontObject("GameFontNormalLarge2");


    BlueprintManager.editionPanel.champDeNom:SetMaxLetters(50);

    local textureTopNom= BlueprintManager.editionPanel.champDeNom:CreateTexture(nil, "OVERLAY");
    textureTopNom:SetTexture("Interface/AddOns/"..addonName.."/assets/BPMLineName.blp");
    textureTopNom:SetPoint("BOTTOM",BlueprintManager.editionPanel.champDeNom,"TOP", 0, -7.5);
    textureTopNom:SetSize(250,12);
    textureTopNom:SetVertexColor(0.1, 0.1, 0.8);

    local textureBottomNom= BlueprintManager.editionPanel.champDeNom:CreateTexture(nil, "OVERLAY");
    textureBottomNom:SetTexture("Interface/AddOns/"..addonName.."/assets/BPMLineName.blp");
    textureBottomNom:SetPoint("TOP",BlueprintManager.editionPanel.champDeNom,"BOTTOM", 0, 7.5);
    textureBottomNom:SetSize(250,12);
    textureBottomNom:SetVertexColor(0.1, 0.1, 0.8);

    BlueprintManager.editionPanel.champDeNom:SetJustifyH("CENTER")
    BlueprintManager.editionPanel.champDeNom:SetMultiLine(false)

    BlueprintManager.editionPanel.champDeNom:SetScript("OnEnterPressed", function(self)
        self:ClearFocus()
    end)
    BlueprintManager.editionPanel.champDeNom:SetScript("OnEscapePressed", function(self)
        self:ClearFocus()
    end)

    
    BlueprintManager.editionPanel.descriptionField = CreateFrame("EditBox", nil, BlueprintManager.editionPanel)
    BlueprintManager.editionPanel.descriptionField:SetSize(220, 100)
    BlueprintManager.editionPanel.descriptionField:SetPoint("TOP",BlueprintManager.editionPanel.champDeNom,"BOTTOM",5, -25)
    BlueprintManager.editionPanel.descriptionField:SetAutoFocus(false)
    BlueprintManager.editionPanel.descriptionField:SetFontObject("GameFontHighlight")
    BlueprintManager.editionPanel.descriptionField.texture= BlueprintManager.editionPanel.descriptionField:CreateTexture(nil, "BACKGROUND")

    BlueprintManager.editionPanel.descriptionField.interactionOverlay = CreateFrame("Frame", nil, BlueprintManager.editionPanel.descriptionField)
    BlueprintManager.editionPanel.descriptionField.interactionOverlay:SetPoint("TOPLEFT", BlueprintManager.editionPanel.descriptionField, "TOPLEFT", 0, 0)
    BlueprintManager.editionPanel.descriptionField.interactionOverlay:SetSize(BlueprintManager.editionPanel.descriptionField:GetWidth(), BlueprintManager.editionPanel.descriptionField:GetHeight())
    BlueprintManager.editionPanel.descriptionField.interactionOverlay:EnableMouse(true)

    BlueprintManager.editionPanel.descriptionField.interactionOverlay:SetScript("OnMouseDown", function(self, button)
        if button == "LeftButton" then
            BlueprintManager.editionPanel.descriptionField:SetFocus()
        end
    end)

    BlueprintManager.editionPanel.descriptionField:SetScript("OnEnterPressed", function(self)
        BlueprintManager.editionPanel.descriptionField:ClearFocus()
    end)

    BlueprintManager.editionPanel.descriptionField:SetScript("OnEscapePressed", function(self)
        BlueprintManager.editionPanel.descriptionField:ClearFocus()
    end)

    BlueprintManager.editionPanel.descriptionField.texture:SetAtlas("UI-Frame-Kyrian-PortraitWiderDisable")
    BlueprintManager.editionPanel.descriptionField.texture:SetPoint("TOPLEFT", -10, 10)
    BlueprintManager.editionPanel.descriptionField.texture:SetSize(240,120)
    BlueprintManager.editionPanel.descriptionField:SetMultiLine(true)
    BlueprintManager.editionPanel.descriptionField:SetJustifyH("LEFT")
    BlueprintManager.editionPanel.descriptionField:SetMaxLetters(0) -- unlimited text length
    BlueprintManager.editionPanel.descriptionField:EnableMouse(true) -- ensure mouse interaction
    BlueprintManager.editionPanel.descriptionField:SetCursorPosition(0) -- set initial cursor position

    BlueprintManager.editionPanel.descriptionField.title = BlueprintManager.editionPanel.descriptionField:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    BlueprintManager.editionPanel.descriptionField.title:SetPoint("BOTTOM",BlueprintManager.editionPanel.descriptionField,"TOP", -5, 10)
    BlueprintManager.editionPanel.descriptionField.title:SetText("Description")

    if(BlueprintToLoad and BlueprintToLoad.description~="") then
        BlueprintManager.editionPanel.descriptionField:SetText(BlueprintToLoad.description)
    end

    if(BlueprintToLoad) then
        -- Initialize the full name storage
        BlueprintManager.currentBlueprintFullNameUntruncated = BlueprintToLoad.blueprintName
        
        local truncatedName = TruncateTextToWidth(BlueprintToLoad.blueprintName, BlueprintManager.editionPanel.champDeNom, 200)
        BlueprintManager.editionPanel.champDeNom:SetText(truncatedName)

        BlueprintManager.editionPanel.champDeNom:SetScript("OnEditFocusGained", function(self)
            -- Show the full untruncated name for editing
            self:SetText(BlueprintManager.currentBlueprintFullNameUntruncated)
        end)

        BlueprintManager.editionPanel.champDeNom:SetScript("OnEditFocusLost", function(self)
            -- Store the full edited name
            local newName = self:GetText()
            BlueprintManager.currentBlueprintFullNameUntruncated = newName
            
            -- Show truncated version in the EditBox
            local truncatedName = TruncateTextToWidth(newName, self, 200)
            self:SetText(truncatedName)
        end)

        BlueprintManager.editionPanel.champDeNom:SetCursorPosition(0)
        createTechnicalButton(BlueprintToLoad)

        BlueprintManager.editionPanel.iconPickerButton = CreateFrame("Button", nil, BlueprintManager.editionPanel, "UIPanelButtonTemplate")
        BlueprintManager.editionPanel.iconPickerButton:SetSize(40, 40)
        BlueprintManager.editionPanel.iconPickerButton:SetPoint("CENTER", -20, -30)
        BlueprintManager.editionPanel.iconPickerButton.texture = BlueprintManager.editionPanel.iconPickerButton:CreateTexture(nil, "OVERLAY")
        if(BlueprintToLoad.icon=="") then
            BlueprintManager.editionPanel.iconPickerButton.texture:SetTexture("Interface\\Icons\\inv_mechagon_blueprints")
        else
            BlueprintManager.editionPanel.iconPickerButton.texture:SetTexture(BlueprintToLoad.icon)
        end
        BlueprintManager.editionPanel.iconPickerButton.texture:SetSize(38,38)
        BlueprintManager.editionPanel.iconPickerButton.texture:SetAllPoints()

        BlueprintManager.editionPanel.iconPickerButton:SetScript("OnMouseDown", function(self)
            self:SetSize(38, 38)
        end)
        BlueprintManager.editionPanel.iconPickerButton:SetScript("OnMouseUp", function(self)
            self:SetSize(40, 40)
        end)

        BlueprintManager.editionPanel.iconPickerButton:SetScript("OnClick", function()
            EpsilonLibIconPicker_Open(function(iconPath)
                BlueprintManager.editionPanel.iconPickerButton.texture:SetTexture(iconPath)
                
                BlueprintToLoad.icon = iconPath
            end, true, true)
        end)

        BlueprintManager.RegisterTooltip(BlueprintManager.editionPanel.iconPickerButton, "Open the icon picker")

        local lineTexture = BlueprintManager.editionPanel:CreateTexture(nil, "ARTWORK")
        lineTexture:SetColorTexture(0.25, 0.25, 0.25, 0.75) -- White color with 50% opacity
        lineTexture:SetSize(200, 2)
        lineTexture:SetPoint("TOP", BlueprintManager.editionPanel.iconPickerButton, "BOTTOM", 0, -10)

        createTagListForRightPanel(lineTexture,BlueprintToLoad)
        createTagAddingThing(lineTexture,BlueprintToLoad)
    else
        BlueprintManager.editionPanel.champDeNom:SetScript("OnTextChanged", nil)
    end
    
end

function BlueprintManager.createLeftPanelForMainFrame(regen,fetchAgain,Updating,filtering)
    -- Debug: createLeftPanelForMainFrame called with params (suppressed to avoid log spam)
    -- print("Called createLeftPanelForMainFrame with regen:", regen, "fetchAgain:", fetchAgain, "filtering:", filtering)
    if regen then
        for i = 1, 5 do
            local blueprintFrame = _G["BlueprintFrame"..i]
            if blueprintFrame then
                blueprintFrame:Hide()
                _G["BlueprintFrame"..i] = nil
            end
        end
        if BlueprintManager.mainFrame.leftPannel then
            BlueprintManager.mainFrame.leftPannel:Hide()
            BlueprintManager.mainFrame.leftPannel = nil
        end
    end
    -- Style it
    BlueprintManager.mainFrame.leftPannel = CreateFrame("Frame", nil, BlueprintManager.mainFrame)
    BlueprintManager.mainFrame.leftPannel:SetSize(300, 370)
    BlueprintManager.mainFrame.leftPannel:SetPoint("LEFT",25)

    BlueprintManager.mainFrame.leftPannel.rightBorder = BlueprintManager.mainFrame:CreateTexture(nil, "BORDER")
    BlueprintManager.mainFrame.leftPannel.rightBorder:SetTexture("Interface/AddOns/" .. addonName .. "/assets/ninesplice/frame_border_vertical.tga")
    BlueprintManager.mainFrame.leftPannel.rightBorder:SetSize(100,425)
    BlueprintManager.mainFrame.leftPannel.rightBorder:SetPoint("RIGHT", BlueprintManager.mainFrame.leftPannel, "RIGHT",120,-10)
    BlueprintManager.mainFrame.leftPannel.rightBorder:SetTexCoord(0, 0.2, 0, 1)

    BlueprintManager.mainFrame.leftPannel.topBorder = BlueprintManager.mainFrame:CreateTexture(nil, "BORDER")
    BlueprintManager.mainFrame.leftPannel.topBorder:SetTexture("Interface/AddOns/" .. addonName .. "/assets/ninesplice/frame_border_horizontal.tga")
    BlueprintManager.mainFrame.leftPannel.topBorder:SetSize(620,100)
    BlueprintManager.mainFrame.leftPannel.topBorder:SetPoint("TOP", BlueprintManager.mainFrame.leftPannel, "TOP", 160, 2.5)
    BlueprintManager.mainFrame.leftPannel.topBorder:SetTexCoord(0, 1, 0.32,0.5)

    -- Make the working thingy
    --fetch the data
    if(fetchAgain) then
        BlueprintManager.FetchBlueprintData(Updating)
        return
    end
    if (regen and regen==true) then 
        -- Create a scroll frame using FauxScrollFrameTemplate
        BlueprintManager.mainFrame.leftPannel.scrollFrame = CreateFrame("ScrollFrame", "BlueprintScrollFrame", BlueprintManager.mainFrame.leftPannel, "FauxScrollFrameTemplate")
        BlueprintManager.mainFrame.leftPannel.scrollFrame:SetPoint("TOPLEFT", -10, -5)
        BlueprintManager.mainFrame.leftPannel.scrollFrame:SetPoint("BOTTOMRIGHT", -5, 5)
        BlueprintManager.mainFrame.leftPannel.scrollFrame.ScrollBar:Hide()

        BlueprintManager.mainFrame.leftPannel.scrollFrame.ScrollBar = CreateFrame("Slider", nil, BlueprintManager.mainFrame.leftPannel.scrollFrame, "UIPanelScrollBarTemplate")
        BlueprintManager.mainFrame.leftPannel.scrollFrame.ScrollBar:SetPoint("TOPLEFT", BlueprintManager.mainFrame.leftPannel.scrollFrame, "TOPRIGHT", 50, -16)
        BlueprintManager.mainFrame.leftPannel.scrollFrame.ScrollBar:SetPoint("BOTTOMLEFT", BlueprintManager.mainFrame.leftPannel.scrollFrame, "BOTTOMRIGHT", 34, 16)

        local numBlueprints = filtering and #BlueprintManager.filteredBlueprints or #BlueprintManagerData.blueprint
        local maxScroll = math.max(0, math.ceil(numBlueprints/5) - 1)
        BlueprintManager.mainFrame.leftPannel.scrollFrame.ScrollBar:SetMinMaxValues(0, maxScroll)
        BlueprintManager.mainFrame.leftPannel.scrollFrame.ScrollBar:SetValueStep(1)
        BlueprintManager.mainFrame.leftPannel.scrollFrame.ScrollBar.scrollStep = 1
        BlueprintManager.mainFrame.leftPannel.scrollFrame.ScrollBar:SetValue(0)
        BlueprintManager.mainFrame.leftPannel.scrollFrame.ScrollBar:SetWidth(16)

        BlueprintManager.mainFrame.leftPannel.scrollFrame.ScrollBar:SetScript("OnValueChanged", function(self, value)
            FauxScrollFrame_OnVerticalScroll(self:GetParent(), value, 78.5, function()
                BlueprintManager.mainFrame.leftPannel.UpdateScrollFrame(filtering)
            end)
        end)
        

        local content = CreateFrame("Frame", nil, BlueprintManager.mainFrame.leftPannel)
        content:SetSize(310, 350) -- Adjust size as needed
        content:SetPoint("TOPLEFT", -10, -15)
        content:Show()

        -- Update function for the scroll frame
        function BlueprintManager.mainFrame.leftPannel.UpdateScrollFrame(_filtering)
            local scrollOffset = BlueprintManager.mainFrame.leftPannel.scrollFrame.ScrollBar:GetValue()
            local numBlueprints = #BlueprintManagerData.blueprint
            if(_filtering) then
                numBlueprints = #BlueprintManager.filteredBlueprints
            end
            for i = 1, 5 do
                local index = math.floor(scrollOffset)*5+i
                local blueprintFrame = _G["BlueprintFrame"..i]

                if not blueprintFrame then
                    blueprintFrame = CreateFrame("Frame", "BlueprintFrame"..i, content)
                    blueprintFrame:SetSize(295, 75)
                    blueprintFrame:SetPoint("TOPLEFT", 15, -((i - 1) * 78.5))

                    blueprintFrame.background = blueprintFrame:CreateTexture(nil, "BACKGROUND");
                    blueprintFrame.background:SetTexture("Interface/AddOns/"..addonName.."/assets/BlueprintManagerFrameBackground.blp");
                    blueprintFrame.background:SetTexCoord(
                        77/512, (77+360)/512,   -- left, right (77 to 437)
                        26/128, (26+78)/128     -- top, bottom (26 to 104)
                    );
                    
                    blueprintFrame.foreground = blueprintFrame:CreateTexture(nil, "OVERLAY");
                    blueprintFrame.foreground:SetTexture("Interface/AddOns/"..addonName.."/assets/BlueprintManagerFrameForeground.blp");
                    blueprintFrame.foreground:SetTexCoord(
                        77/512, (77+360)/512,   -- left, right (77 to 437)
                        26/128, (26+78)/128     -- top, bottom (26 to 104)
                    ); 
                    blueprintFrame.foreground:SetPoint("TOPLEFT", 0, 0);
                    blueprintFrame.foreground:SetSize(305, 75);
                    
                    blueprintFrame.background:SetPoint("TOPLEFT", 0, 0);
                    blueprintFrame.background:SetSize(305, 75);

                    blueprintFrame.icon = blueprintFrame:CreateTexture(nil, "ARTWORK")
                    blueprintFrame.icon:SetSize(62, 60)
                    blueprintFrame.icon:SetPoint("TOPLEFT", 7, -7)

                    blueprintFrame.iconRing = blueprintFrame:CreateTexture(nil, "OVERLAY")
                    blueprintFrame.iconRing:SetTexture("Interface/AddOns/"..addonName.."/assets/BPMRing.blp")
                    blueprintFrame.iconRing:SetSize(64, 64)
                    blueprintFrame.iconRing:SetPoint("CENTER",blueprintFrame.icon,"CENTER",0, 0)

                    local mask = blueprintFrame:CreateMaskTexture()
                    mask:SetTexture("Interface\\CHARACTERFRAME\\TempPortraitAlphaMask", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
                    mask:SetAllPoints(blueprintFrame.icon) -- Match the button's size and position

                    -- Apply the mask to the icon
                    blueprintFrame.icon:AddMaskTexture(mask)

                    blueprintFrame.nameText = blueprintFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalMed2")
                    blueprintFrame.nameText:SetPoint("TOPLEFT", 75, -5)
                    blueprintFrame.nameText:SetSize(220, 20) -- Adjusted to match our available width calculation
                    blueprintFrame.nameText:SetJustifyH("LEFT")
                    blueprintFrame.nameText:SetWordWrap(false)
                    blueprintFrame.nameText:SetNonSpaceWrap(true)

                    blueprintFrame.objectCountText = blueprintFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
                    blueprintFrame.objectCountText:SetPoint("BOTTOMLEFT", 77, 21)
                    blueprintFrame.objectCountText:SetFont("Fonts\\FRIZQT__.TTF", 12)

                    blueprintFrame.creatorText = blueprintFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
                    blueprintFrame.creatorText:SetPoint("BOTTOMLEFT", 77.5, 11)
                    blueprintFrame.creatorText:SetFont("Fonts\\FRIZQT__.TTF", 10)

                    blueprintFrame.dateOfCreationText = blueprintFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
                    blueprintFrame.dateOfCreationText:SetPoint("BOTTOMRIGHT", 2.5, 11)
                    blueprintFrame.dateOfCreationText:SetFont("Fonts\\FRIZQT__.TTF", 10)

                    blueprintFrame.tagSpace = blueprintFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
                    blueprintFrame.tagSpace:SetText("")
                    blueprintFrame.tagSpace:SetPoint("TOPLEFT", 77.5, -25)
                    blueprintFrame.tagSpace:SetFont("Fonts\\FRIZQT__.TTF", 10)
                end

                if index <= numBlueprints then
                    local blueprint={}
                    if(filtering) then
                        blueprint = BlueprintManager.filteredBlueprints[index]
                    else
                        blueprint = BlueprintManagerData.blueprint[index]
                    end
                    blueprintFrame.icon:SetTexture(blueprint.icon == "" and "Interface\\Icons\\inv_mechagon_blueprints" or blueprint.icon)
                    -- Truncate the blueprint name to fit available width (305px background - 75px offset - 10px margin = 220px)
                    blueprintFrame.nameText:SetText(blueprint.blueprintName)
                    --230
                    TruncateTextToWidth(blueprint.blueprintName,blueprintFrame.nameText, 230)
                    blueprintFrame.objectCountText:SetText("Objects: " .. blueprint.blueprintObjectCount)
                    blueprintFrame.creatorText:SetText("Creator: |cFFFFFFFF" .. blueprint.creator .. "|r")
                    blueprintFrame.dateOfCreationText:SetText(blueprint.dateOfCreation)

                    if(blueprint and  #blueprint.tags>0) then 
                        --get the first tag color 
                        local firstTag = getTagInfoByName(blueprint.tags[1]);
                        if firstTag then
                            local color = CreateColorFromHexString("FF"..firstTag.color[1])
                            local r,g,b = color:GetRGB()
                            blueprintFrame.foreground:SetVertexColor(r,g,b, 1)
                        else
                            blueprintFrame.foreground:SetVertexColor(0.1, 0.1, 0.8);
                        end
                    else
                        blueprintFrame.foreground:SetVertexColor(0.1, 0.1, 0.8);
                    end

                    -- Generate the tag list under the blueprint's name, limited to 3 because I said so
                    local limit = 1;
                    local tagString =""
                    for index,tag in ipairs (blueprint.tags) do 
                        if(limit>3) then
                            break;
                        else
                            local fetchedTag = getTagInfoByName(tag);
                            if fetchedTag then
                                local colorstart = "|cFF"..fetchedTag.color[1]
                                local colorend = "|r"
                                -- Crop tag name if it's too long (max 12 chars for last tag)

                                if(limit==3 or index == #blueprint.tags) then
                                    tagString = tagString..colorstart..tag..colorend
                                else
                                    tagString = tagString..colorstart..tag..colorend.." | "
                                end
                            end
                        end
                        limit = limit + 1;
                    end
                    if(#blueprint.tags<1) then
                        blueprintFrame.tagSpace:Hide()
                    else
                        blueprintFrame.tagSpace:Show()
                    end
                    TruncateTextToWidth(tagString, blueprintFrame.tagSpace, 227.5)
                    
                    -- Réinitialiser la couleur du background à blanc pour que la texture apparaisse correctement
                    blueprintFrame.background:SetVertexColor(1, 1, 1, 1)

                    blueprintFrame:SetScript("OnEnter", function()
                        blueprintFrame.background:SetVertexColor(0.5, 0.5, 1) -- Change to a highlight color
                    end)
    
                    blueprintFrame:SetScript("OnLeave", function()
                        if lastClickedObjectIndex ~= index then
                            blueprintFrame.background:SetVertexColor(1, 1, 1) -- Revert to original color
                        end
                    end)
    
                    blueprintFrame:SetScript("OnMouseDown", function()
                    if lastClickedObject and lastClickedObjectIndex then
                        lastClickedObject.background:SetVertexColor(1, 1, 1) -- Revert to original color
                    end

                    if string.sub(blueprint.description, -3) == "..." then
                        sendAddonCmd("gobject blueprint info " .. blueprint.blueprintName, function(success, replies)
                            if success then
                                for replyIndex, reply in ipairs(replies) do
                                    reply = reply:gsub("|cff%x%x%x%x%x%x", ""):gsub("|r", "")
                                    if replyIndex ~= 1 then 
                                        blueprint.description = reply
                                        if(_filtering) then 
                                            BlueprintManager.selectedBlueprint=BlueprintManager.filteredBlueprints[index]
                                            BlueprintManager.createRightPanelForMainFrame(BlueprintManager.filteredBlueprints[index])
                                        else
                                            BlueprintManager.selectedBlueprint=BlueprintManagerData.blueprint[index]
                                            BlueprintManager.createRightPanelForMainFrame(BlueprintManagerData.blueprint[index])
                                        end
                                        break
                                    end
                                end
                            end
                        end)
                    else
                        if(filtering) then
                            BlueprintManager.createRightPanelForMainFrame(BlueprintManager.filteredBlueprints[index])
                        else
                            BlueprintManager.createRightPanelForMainFrame(BlueprintManagerData.blueprint[index])
                        end
                    end
                    lastClickedObject = blueprintFrame
                    lastClickedObject.background = blueprintFrame.background
                    lastClickedObjectIndex = index



                    blueprintFrame.background:SetVertexColor(0.5, 0.5, 1) -- Change to a highlight color
                    
                    end)

                    blueprintFrame:Show()
                else
                    blueprintFrame:Hide()
                end
            end

            FauxScrollFrame_Update(BlueprintManager.mainFrame.leftPannel.scrollFrame, numBlueprints, 5, 78.5)
        end

        BlueprintManager.mainFrame.leftPannel.scrollFrame:SetScript("OnVerticalScroll", function(self, offset)
            FauxScrollFrame_OnVerticalScroll(self, offset, 78.5, function()
                BlueprintManager.mainFrame.leftPannel.UpdateScrollFrame(filtering)
            end)
        end)

        BlueprintManager.mainFrame.leftPannel.UpdateScrollFrame(filtering)

        -- Adjust the position of the vertical scroll bar
        BlueprintManager.mainFrame.leftPannel.scrollFrame.ScrollBar:ClearAllPoints()
        BlueprintManager.mainFrame.leftPannel.scrollFrame.ScrollBar:SetPoint("TOPRIGHT", BlueprintManager.mainFrame.leftPannel, "TOPRIGHT", 30, -30)
        BlueprintManager.mainFrame.leftPannel.scrollFrame.ScrollBar:SetPoint("BOTTOMRIGHT", BlueprintManager.mainFrame.leftPannel, "BOTTOMRIGHT", 30, -19)
    end
end

local function checkIfDescriptionIsValid(description,dateOfCreation)
    if(description==dateOfCreation..")") then
        return ""
    elseif(string.find(description,"lookup")) then 
        return ""
    else
        return description
    end
end

local function areBlueprintsIdentical(savedBlueprint,_blueprintId, blueprintName, blueprintObjectCount, creator, dateOfCreation, description)
    return savedBlueprint.blueprintId == _blueprintId and
           savedBlueprint.blueprintName == blueprintName and
           savedBlueprint.blueprintObjectCount == blueprintObjectCount and
           savedBlueprint.creator == creator and
           savedBlueprint.dateOfCreation == dateOfCreation and
           savedBlueprint.description == description
end

local function createBlueprintObject(_blueprintId, blueprintName, blueprintObjectCount, creator, dateOfCreation, description,isUpdating)
    for index, blueprint in ipairs(BlueprintManagerData.blueprint) do
        if blueprint.blueprintId == _blueprintId then
            if(not areBlueprintsIdentical(blueprint,_blueprintId, blueprintName, blueprintObjectCount, creator, dateOfCreation, description)) then
                BlueprintManagerData.blueprint[index] = {
                    blueprintId = _blueprintId,
                    blueprintName = blueprintName,
                    blueprintObjectCount = tonumber(blueprintObjectCount),
                    creator = creator,
                    dateOfCreation = dateOfCreation,
                    description = checkIfDescriptionIsValid(description, dateOfCreation),
                    icon = blueprint.icon, -- You can set a default icon or fetch it from somewhere
                    tags = blueprint.tags -- Initialize with an empty table or fetch tags if available
                }
                return nil
            else
                return nil
            end
        end
    end
        return {
            blueprintId = _blueprintId,
            blueprintName = blueprintName,
            blueprintObjectCount = tonumber(blueprintObjectCount),
            creator = creator,
            dateOfCreation = dateOfCreation,
            description = checkIfDescriptionIsValid(description, dateOfCreation),
            icon = "", -- You can set a default icon or fetch it from somewhere
            tags = {} -- Initialize with an empty table or fetch tags if available
        }
end

local function parseBlueprintResponse(IsCommandSuccessful,replies,isUpdating)
    if IsCommandSuccessful then
        for i,reply in ipairs(replies) do
            reply = reply:gsub("|cff%x%x%x%x%x%x", ""):gsub("|r", "")
            local isCallingAgainNeeded = string.find(reply, "Enter .lookup next") ~= nil
            local isFirstMessage = string.find(reply, "fetched") ~= nil
            
            if(not isFirstMessage) then
                --283379 - [50] | #2 objects (Created by: Xraan on 2025-03-06).

                local blueprintId = string.match(reply, "(%d+) %-")
                local blueprintName = string.match(reply, "%[(.+)%]")
                local blueprintObjectCount = string.match(reply, "#(%d+) objects")
                local creator = string.match(reply, "Created by: (.+) on")
                local dateOfCreation = string.match(reply, "on (%d+-%d+-%d+)")
                local description=string.match(reply,"%) (.+)%.")
                if (not description) then
                    description = ""
                end


                if(not BlueprintManagerData.blueprint[blueprintId] and not isCallingAgainNeeded and blueprintId) then
                    if (createBlueprintObject(blueprintId, blueprintName, blueprintObjectCount, creator, dateOfCreation, description,isUpdating)) then
                        table.insert(BlueprintManagerData.blueprint, createBlueprintObject(blueprintId, blueprintName, blueprintObjectCount, creator, dateOfCreation, description,isUpdating))
                    end
                end
                
                if isCallingAgainNeeded then
                    sendAddonCmd("lookup next ", function(success, replies) parseBlueprintResponse(success, replies) end, false)
                end
            end
        end
        BlueprintManager.createLeftPanelForMainFrame(true)
    else
        print("Failed to fetch blueprints")
    end
end

function BlueprintManager.FetchBlueprintData(isUpdating)
    sendAddonCmd("lo blueprint ",function(IsCommandSuccessful,replies) parseBlueprintResponse(IsCommandSuccessful,replies,isUpdating) end)
end

local function rotateTexture(texture, orientation)
    if orientation == "right" then
        texture:SetRotation(math.rad(-90))
    elseif orientation == "left" then
        texture:SetRotation(math.rad(90))
    end
end

local function updateCreateTagButtonIcon(tagObject, button)
    local numberOrConditionMet=0
    if(tagObject.name and tagObject.name ~="") then
        numberOrConditionMet=numberOrConditionMet+1
    end
    if(tagObject.color) then
        numberOrConditionMet=numberOrConditionMet+1
    end

    if(numberOrConditionMet==2) then
        button.texture:SetAtlas("Vehicle-HammerGold")
    elseif (numberOrConditionMet==1) then
        button.texture:SetAtlas("Vehicle-HammerGold-3")
    else
        button.texture:SetAtlas("Vehicle-HammerGold-1")
    end
    button.texture:SetAllPoints()

end

local function doesTagExist(tagName)
    for _, tag in ipairs(BlueprintManagerData.tags) do
        if tag.name == tagName then
            return true
        end
    end
    return false
end

local function playHammerAnimation(_createcreateTagButton)
    local animationGroup = _createcreateTagButton.texture:CreateAnimationGroup()

    local scaleUp = animationGroup:CreateAnimation("Scale")
    scaleUp:SetScale(1.5, 1.5)
    scaleUp:SetDuration(0.25)
    scaleUp:SetOrder(1)

    local shine = animationGroup:CreateAnimation("Alpha")
    shine:SetFromAlpha(1)
    shine:SetToAlpha(0)
    shine:SetDuration(0.1)
    shine:SetOrder(2)
    shine:SetScript("OnPlay", function()
        _createcreateTagButton.texture:SetVertexColor(0, 1, 0) -- Green color
    end)
    shine:SetScript("OnFinished", function()
        _createcreateTagButton.texture:SetVertexColor(1, 1, 1) -- Reset to original color
    end)

    local shineBack = animationGroup:CreateAnimation("Alpha")
    shineBack:SetFromAlpha(0)
    shineBack:SetToAlpha(1)
    shineBack:SetDuration(0.1)
    shineBack:SetOrder(3)
    shineBack:SetScript("OnPlay", function()
        _createcreateTagButton.texture:SetVertexColor(0, 1, 0) -- Green color
    end)
    shineBack:SetScript("OnFinished", function()
        _createcreateTagButton.texture:SetVertexColor(1, 1, 1) -- Reset to original color
    end)

    local scaleDown = animationGroup:CreateAnimation("Scale")
    scaleDown:SetScale(0.67, 0.67) -- Scale down to original size
    scaleDown:SetDuration(0.25)
    scaleDown:SetOrder(4)

    animationGroup:Play()
end

local function playIncorrectDataAnimation(_createcreateTagButton,editbox,isNameAlreadyUsed,isNameIncorrect,isColorSelected,SelectColorButton)
    local flashTexture = _createcreateTagButton:CreateTexture(nil, "OVERLAY")
    flashTexture:SetAtlas("Capacitance-General-WorkOrderActive")
    flashTexture:SetSize(41, 41)
    flashTexture:SetPoint("CENTER", _createcreateTagButton, "CENTER")
    flashTexture:SetVertexColor(1, 0, 0) -- Set color to red

    local flashAnimation = flashTexture:CreateAnimationGroup()
    local fadeOut = flashAnimation:CreateAnimation("Alpha")
    fadeOut:SetFromAlpha(1)
    fadeOut:SetToAlpha(0)
    fadeOut:SetDuration(0.5)
    fadeOut:SetSmoothing("IN_OUT")
    fadeOut:SetScript("OnFinished", function()
        flashTexture:Hide()
    end)

    flashTexture:Show()
    flashAnimation:Play()
    if isNameIncorrect or isNameAlreadyUsed then
        local flashTexture2 = editbox:CreateTexture(nil, "OVERLAY")
        flashTexture2:SetAtlas("Capacitance-General-WorkOrderActive")
        flashTexture2:SetSize(220, 30)
        flashTexture2:SetPoint("CENTER", editbox, "CENTER")
        flashTexture2:SetVertexColor(1, 0, 0) -- Set color to red

        local flashAnimation2 = flashTexture2:CreateAnimationGroup()
        local fadeOut2 = flashAnimation2:CreateAnimation("Alpha")
        fadeOut2:SetFromAlpha(1)
        fadeOut2:SetToAlpha(0)
        fadeOut2:SetDuration(0.5)
        fadeOut2:SetSmoothing("IN_OUT")
        fadeOut2:SetScript("OnFinished", function()
            flashTexture2:Hide()
        end)

        flashTexture2:Show()
        flashAnimation2:Play()
    end

    if not isColorSelected then
        local flashTexture3 = SelectColorButton:CreateTexture(nil, "OVERLAY")
        flashTexture3:SetAtlas("Capacitance-General-WorkOrderActive")
        flashTexture3:SetSize(41, 41)
        flashTexture3:SetPoint("CENTER", SelectColorButton, "CENTER")
        flashTexture3:SetVertexColor(1, 0, 0) -- Set color to red

        local flashAnimation3 = flashTexture3:CreateAnimationGroup()
        local fadeOut3 = flashAnimation3:CreateAnimation("Alpha")
        fadeOut3:SetFromAlpha(1)
        fadeOut3:SetToAlpha(0)
        fadeOut3:SetDuration(0.5)
        fadeOut3:SetSmoothing("IN_OUT")
        fadeOut3:SetScript("OnFinished", function()
            flashTexture3:Hide()
        end)

        flashTexture3:Show()
        flashAnimation3:Play()
    end
end

local function removeTagFromBlueprints(tagName)
    for _, blueprint in ipairs(BlueprintManagerData.blueprint) do
        for i, tag in ipairs(blueprint.tags) do
            if tag == tagName then
                table.remove(blueprint.tags, i)
                break
            end
        end
    end
end

local function createTagList(lineTexture)
    for i = 1, 5 do
        local blueprintFrame = _G["TagFrame"..i] 
        if blueprintFrame then
            blueprintFrame:Hide()
            _G["TagFrame"..i]  = nil
        end
    end
    BlueprintManager.tagManager.tagListFrame = CreateFrame("Frame",nil,BlueprintManager.tagManager)
    BlueprintManager.tagManager.tagListFrame:SetSize(195, 140)
    BlueprintManager.tagManager.tagListFrame:SetPoint("TOP",lineTexture,"BOTTOM",-65,-5)
    BlueprintManager.tagManager.tagListFrame.texture = BlueprintManager.tagManager.tagListFrame:CreateTexture(nil, "BACKGROUND")
    BlueprintManager.tagManager.tagListFrame.texture:SetAtlas("UI-Frame-Kyrian-PortraitWiderDisable")
    BlueprintManager.tagManager.tagListFrame.texture:SetAllPoints()

    --create a scroll frame 

    BlueprintManager.tagManager.tagListFrame.scrollFrame = CreateFrame("ScrollFrame", "TagScrollFrame", BlueprintManager.tagManager.tagListFrame, "FauxScrollFrameTemplate")
    BlueprintManager.tagManager.tagListFrame.scrollFrame:SetSize(155, 120) -- Adjust size as needed
    BlueprintManager.tagManager.tagListFrame.scrollFrame:SetPoint("TOP", 0, -7.5)
    BlueprintManager.tagManager.tagListFrame.scrollFrame.ScrollBar:Hide()
    
    BlueprintManager.tagManager.tagListFrame.scrollFrame.ScrollBar = CreateFrame("Slider", nil, BlueprintManager.tagManager.tagListFrame.scrollFrame, "UIPanelScrollBarTemplate")
    BlueprintManager.tagManager.tagListFrame.scrollFrame.ScrollBar:SetPoint("TOPRIGHT", BlueprintManager.tagManager.tagListFrame.scrollFrame, "TOPRIGHT", 0, -16)
    BlueprintManager.tagManager.tagListFrame.scrollFrame.ScrollBar:SetPoint("BOTTOMLEFT", BlueprintManager.tagManager.tagListFrame.scrollFrame, "BOTTOMRIGHT", 0, 16)
    BlueprintManager.tagManager.tagListFrame.scrollFrame.ScrollBar:SetMinMaxValues(0, math.max(0, math.ceil(#BlueprintManagerData.tags/4) - 1))
    BlueprintManager.tagManager.tagListFrame.scrollFrame.ScrollBar:SetValueStep(1)
    BlueprintManager.tagManager.tagListFrame.scrollFrame.ScrollBar.scrollStep = 1
    BlueprintManager.tagManager.tagListFrame.scrollFrame.ScrollBar:SetValue(0)
    BlueprintManager.tagManager.tagListFrame.scrollFrame.ScrollBar:SetWidth(16)
    BlueprintManager.tagManager.tagListFrame.scrollFrame.ScrollBar:Show()

    BlueprintManager.tagManager.tagListFrame.scrollFrame.ScrollBar:SetScript("OnValueChanged", function(self, value)
        self:GetParent():SetVerticalScroll(value)
    end)
    
    local content = CreateFrame("Frame", nil, BlueprintManager.tagManager.tagListFrame)
    content:SetSize(155, 120) -- Adjust size as needed
    content:SetPoint("TOP", 0, -12)
    content:Show()

    -- Update function for the scroll frame
    
    function BlueprintManager.tagManager.tagListFrame.UpdateScrollFrame()
        local dataSource = isFilteringTags and filteredTags or BlueprintManagerData.tags
        local numTags = #dataSource
        BlueprintManager.tagManager.tagListFrame.scrollFrame.ScrollBar:SetMinMaxValues(0, math.max(0, math.ceil(numTags/4) - 1))
        local scrollOffset = BlueprintManager.tagManager.tagListFrame.scrollFrame.ScrollBar:GetValue()
        local numToDisplay = math.min(numTags, 4) -- Display 4 tags at a time
        
        for i = 1, 4 do
            local index = math.floor(scrollOffset)*4+i

            local tagFrame = _G["TagFrame"..i] 
            if not tagFrame then
                tagFrame = CreateFrame("Frame", "TagFrame"..i, content)
                tagFrame:SetSize(175, 27.5)
                tagFrame:SetPoint("TOPLEFT", -10, -((i - 1) * 30))

                tagFrame.background = tagFrame:CreateTexture(nil, "BACKGROUND")
                --use the same background as the blueprint list element
                tagFrame.background:SetTexture("Interface/AddOns/"..addonName.."/assets/BlueprintManagerFrame.blp");
                    tagFrame.background:SetTexCoord(
                        77/512, (77+360)/512,   -- left, right (77 to 437)
                        26/128, (26+78)/128     -- top, bottom (26 to 104)
                    );

                tagFrame:SetScript("OnEnter", function()
                    tagFrame.background:SetVertexColor(0.5, 0.5, 1) -- Change to a highlight color
                end)

                tagFrame:SetScript("OnLeave", function()
                    tagFrame.background:SetVertexColor(1, 1, 1) -- Revert to original color
                end)
    
                tagFrame.background:SetPoint("TOPLEFT", 0, 0)
                tagFrame.background:SetSize(tagFrame:GetWidth(), tagFrame:GetHeight())

                tagFrame.nameText = tagFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
                tagFrame.nameText:SetPoint("TOPLEFT", 15, -5)

                tagFrame.colorTexture = tagFrame:CreateTexture(nil, "ARTWORK")
                tagFrame.colorTexture:SetSize(16, 16)
                tagFrame.colorTexture:SetPoint("TOPRIGHT", -30, -5)

                -- we need a delete button
                tagFrame.deleteButton = CreateFrame("Button", nil, tagFrame)
                tagFrame.deleteButton:SetSize(25, 25)
                tagFrame.deleteButton:SetPoint("TOPRIGHT", 0, -2.5)

                tagFrame.deleteButton.texture = tagFrame.deleteButton:CreateTexture(nil, "ARTWORK")

                tagFrame.deleteButton.texture:SetTexture("Interface\\AddOns\\" .. addonName .. "\\assets\\buttons\\BPMXButton.blp")
                tagFrame.deleteButton.texture:SetSize(25, 25)
                tagFrame.deleteButton.texture:SetAllPoints()

                tagFrame.deleteButton:SetScript("OnEnter", function()
                    tagFrame.deleteButton.texture:SetVertexColor(0.8, 0.8, 1,1) -- Change to a highlight color
                end)

                tagFrame.deleteButton:SetScript("OnLeave", function(self)
                    tagFrame.deleteButton.texture:SetVertexColor(1, 1, 1, 1) -- Reset to normal
                end)

                tagFrame.deleteButton:SetScript("OnMouseDown", function(self)
                    self:SetSize(23, 23)
                end)

                tagFrame.deleteButton:SetScript("OnMouseUp", function(self)
                    self:SetSize(25, 25)
                end)

            end

            if index <= numTags then
                local tag = dataSource[index]
                TruncateTextToWidth(tag.name, tagFrame.nameText,100)
                if string.sub(tagFrame.nameText:GetText(), -3) == "..." then
                    BlueprintManager.RegisterTooltip(tagFrame, tag.name)
                else
                    tagFrame:HookScript("OnEnter", function() end)
                    tagFrame:HookScript("OnLeave", function() end)
                end

                tagFrame.colorTexture:SetColorTexture(tag.color[2], tag.color[3], tag.color[4])
                tagFrame.colorTexture.border = tagFrame:CreateTexture(nil, "OVERLAY")
                tagFrame.colorTexture.border:SetAtlas("UI-Frame-IconBorder")
                tagFrame.colorTexture.border:SetSize(20, 20)
                tagFrame.colorTexture.border:SetPoint("CENTER", tagFrame.colorTexture, "CENTER")
                tagFrame:Show()

                tagFrame.deleteButton:SetScript("OnClick", function()
                    removeTagFromBlueprints(dataSource[index].name)
                    table.remove(BlueprintManagerData.tags, index)
                    BlueprintManager.createLeftPanelForMainFrame(true)
                    BlueprintManager.tagManager.tagListFrame.scrollFrame.ScrollBar:SetValue(0)
                    BlueprintManager.tagManager.tagListFrame.UpdateScrollFrame()
                end)

                tagFrame:SetScript("OnMouseDown", function()
                    BlueprintManager.tagManager.selectedTag = tag
                    -- we need to show 
                    BlueprintManager.tagManager.editBoxForSelectedTag:Show()
                    BlueprintManager.tagManager.editBoxForSelectedTag:SetText(tag.name)
                    BlueprintManager.tagManager.title:Show()
                    BlueprintManager.tagManager.renameTagButton:Show()
                end)
            else
                tagFrame:Hide()
            end
        end

        FauxScrollFrame_Update(BlueprintManager.tagManager.tagListFrame.scrollFrame, numTags, 4, 30)
    end

    BlueprintManager.tagManager.tagListFrame.scrollFrame:SetScript("OnVerticalScroll", function(self, offset)
        FauxScrollFrame_OnVerticalScroll(self, offset, 30, BlueprintManager.tagManager.tagListFrame.UpdateScrollFrame)
    end)

    BlueprintManager.tagManager.tagListFrame.UpdateScrollFrame()

    -- Adjust the position of the vertical scroll bar
    BlueprintManager.tagManager.tagListFrame.scrollFrame.ScrollBar:ClearAllPoints()
    BlueprintManager.tagManager.tagListFrame.scrollFrame.ScrollBar:SetPoint("TOPRIGHT", BlueprintManager.tagManager.tagListFrame, "TOPRIGHT", 15, -17)
    BlueprintManager.tagManager.tagListFrame.scrollFrame.ScrollBar:SetPoint("BOTTOMRIGHT", BlueprintManager.tagManager.tagListFrame, "BOTTOMRIGHT", 15, 17)
end

local function OpenTagManagerUI()
    if BlueprintManager.tagManager then
        if BlueprintManager.tagManager:IsShown() then
            BlueprintManager.tagManager:Hide()
            BlueprintManager.tagManager = nil
            return
        else
            BlueprintManager.tagManager:Show()
            return
        end
    end

    BlueprintManager.tagManager = CreateFrame("Frame", nil, BlueprintManager.mainFrame ,"PortraitFrameTemplate")
    ButtonFrameTemplateMinimizable_HidePortrait(BlueprintManager.tagManager)
    NineSliceUtil.ApplyLayoutByName(BlueprintManager.tagManager.NineSlice, "EpsilonGoldBorderFrameTemplateNoPortrait")

    BlueprintManager.tagManager.bgTexture = BlueprintManager.tagManager:CreateTexture(nil, "BACKGROUND")
    BlueprintManager.tagManager.bgTexture:SetTexture("Interface/AddOns/" .. addonName .. "/assets/ninesplice/ManagerBG.blp")
    BlueprintManager.tagManager.bgTexture:SetPoint("CENTER", BlueprintManager.tagManager, "CENTER",0,0)
    BlueprintManager.tagManager.bgTexture:SetSize(325, 300)

    EpsilonLib.Utils.NineSlice.SetBackgroundAsViewport(BlueprintManager.tagManager, BlueprintManager.tagManager.bgTexture)

    local f = BlueprintManager.tagManager
    local titleBgColor = f:CreateTexture(nil, "BACKGROUND")
    local color = CreateColorFromHexString("FF3d2145")
    titleBgColor:SetPoint("TOPLEFT", f.TitleBg)
    titleBgColor:SetPoint("BOTTOMRIGHT", f.TitleBg, -0, 0)
    titleBgColor:SetColorTexture(color:GetRGBA())
    f.TitleBgColor = titleBgColor
    local r,g,b = color:GetRGB()
    f.TitleBg:SetVertexColor(r,g,b, 1)

    f.TitleText:SetText("Tag Manager")
    f.TitleText:SetPoint("LEFT", 80, 0) -- Fix title text position with no portrait

    BlueprintManager.tagManager:SetSize(325, 300)
    BlueprintManager.tagManager:SetPoint("BOTTOMLEFT", BlueprintManager.mainFrame, "BOTTOMRIGHT", 5, 0)

    local title = BlueprintManager.tagManager:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOP", 5, -30)
    title:SetText("Create a tag")

    local tagObject={}

    

    local editBox = CreateFrame("EditBox", nil, BlueprintManager.tagManager, "InputBoxTemplate")
    editBox:SetSize(180, 30)
    editBox:SetPoint("TOP", title, "BOTTOM", 0, -10)
    editBox:SetAutoFocus(false)
    editBox:SetFontObject("GameFontHighlight")
    editBox:SetMaxLetters(50)
    editBox:SetScript("OnEnterPressed", function(self)
        self:ClearFocus()
    end)
    editBox:SetScript("OnEscapePressed", function(self)
        self:ClearFocus()
    end)

    BlueprintManager.RegisterTooltip(editBox, "Enter the name of the tag")

    local createTagButton = CreateFrame("Button", nil, BlueprintManager.tagManager, "UIPanelButtonTemplate")
    createTagButton:SetSize(40, 40)
    createTagButton:SetPoint("TOPRIGHT", editBox, "BOTTOMRIGHT", -10, -2.5)
    createTagButton.texture = createTagButton:CreateTexture(nil, "ARTWORK")
    createTagButton.texture:SetAtlas("Vehicle-HammerGold-1")
    createTagButton.texture:SetSize(30,30)
    createTagButton.texture:SetPoint("CENTER")
    createTagButton:SetScript("OnMouseDown", function(self)
        self:SetSize(38, 38)
    end)
    createTagButton:SetScript("OnMouseUp", function(self)
        self:SetSize(40, 40)
    end)

    BlueprintManager.RegisterTooltip(createTagButton, "Create the tag")

    local SelectColorButton = CreateFrame("Button", nil, BlueprintManager.tagManager, "UIPanelButtonTemplate")
    SelectColorButton:SetSize(40, 40)
    SelectColorButton:SetPoint("TOPLEFT",editBox,"BOTTOMLEFT", 10, -2.5)
    SelectColorButton.texture = SelectColorButton:CreateTexture(nil, "ARTWORK")
    SelectColorButton.texture:SetAtlas("colorblind-colorwheel")
    SelectColorButton.texture:SetSize(30,30)
    SelectColorButton.texture:SetPoint("CENTER")


    local colorIndicator = CreateFrame("Frame", nil, SelectColorButton)
    colorIndicator:SetSize(60, 50)
    colorIndicator:SetPoint("LEFT", SelectColorButton, "RIGHT", 5, 0)
    colorIndicator.texture = colorIndicator:CreateTexture(nil, "ARTWORK")
    colorIndicator.texture:SetPoint("CENTER",colorIndicator,"CENTER",-5,-2.5)
    colorIndicator.texture:SetSize(60,30)
    colorIndicator.texture:SetTexture("Interface\\AddOns\\" .. addonName .. "\\assets\\InterfaceSwatch.blp")

    BlueprintManager.RegisterTooltip(SelectColorButton, "Select the tag color")

    SelectColorButton:SetScript("OnMouseDown", function(self)
        self:SetSize(38, 38)
    end)
    SelectColorButton:SetScript("OnMouseUp", function(self)
        self:SetSize(40, 40)
    end)

    SelectColorButton:SetScript("OnClick", function()
        EpsilonLibColourPicker_Open(function(r, g, b, a)
            tagObject.color = {r, g, b, a}
            updateCreateTagButtonIcon(tagObject, createTagButton)
            local color = CreateColorFromHexString("FF"..r);
            local rr,gg,bb = color:GetRGB()
            colorIndicator.texture:SetVertexColor(rr, gg, bb, 1);
        end, true, true)
        -- EpsilonLibColourPicker is a frame name get the frame
        local EpsilonLibColourPicker = _G["EpsilonLibColourPicker"]
        EpsilonLibColourPicker:ClearAllPoints()
        EpsilonLibColourPicker:SetPoint("BOTTOMLEFT", BlueprintManager.tagManager, "TOPLEFT", 0, 5)

        BlueprintManager.tagManager:HookScript("OnHide", function()
            EpsilonLibColourPicker:ClearAllPoints()
            EpsilonLibColourPicker:SetPoint("CENTER", UIParent, "CENTER")
        end)
    end)

    createTagButton:SetScript("OnClick", function()
        if tagObject.name and tagObject.name~="" and tagObject.color and not doesTagExist(tagObject.name) then
            tagObject.name = string.gsub(tagObject.name, " ", "_")
            table.insert(BlueprintManagerData.tags, tagObject)
            BlueprintManager.RefreshLeftPanelKeepOffset()

            playHammerAnimation(createTagButton)
            tagObject={}
            if(BlueprintManager.selectedBlueprint and BlueprintManager.editionPanel.tagSection.tagListFrame.dropDown) then
                BlueprintManager.editionPanel.tagSection.tagListFrame.dropDown:Hide()
                BlueprintManager.editionPanel.tagSection.tagListFrame.dropDown=nil
                BlueprintManager.editionPanel.tagSection.createTagDropdown(BlueprintManager.selectedBlueprint)
            end
            editBox:SetText("")
            colorIndicator.texture:SetVertexColor(1, 1, 1, 1)
            BlueprintManager.tagManager.tagListFrame.UpdateScrollFrame()
        else
            playIncorrectDataAnimation(createTagButton, editBox,doesTagExist(tagObject.name), not tagObject.name or tagObject.name=="",tagObject.color=={} ,SelectColorButton)
        end
    end)

    editBox:SetScript("OnTextChanged", function(self)
        tagObject.name = self:GetText()
        updateCreateTagButtonIcon(tagObject, createTagButton)
    end)

    local lineTexture =BlueprintManager.tagManager:CreateTexture(nil, "ARTWORK")
    
    lineTexture:SetColorTexture(RGBAToNormalized(217,201,178,255)) -- White color with 50% opacity
    lineTexture:SetSize(200, 2)
    lineTexture:SetPoint("TOP", editBox, "BOTTOM", 0, -50)

    createTagList(lineTexture)

    -- on the right side of the taglist I want an editbox that will filter those tags in case there is a lot
    local filterEditBox = CreateFrame("EditBox", nil, BlueprintManager.tagManager, "InputBoxTemplate")
    filterEditBox:SetSize(85, 30)
    filterEditBox:SetPoint("TOP", lineTexture, "BOTTOM", 100, -20)
    filterEditBox:SetAutoFocus(false)
    filterEditBox:SetFontObject("GameFontHighlight")
    filterEditBox:SetMaxLetters(50)
    filterEditBox:SetScript("OnEnterPressed", function(self)
        self:ClearFocus()
    end)
    filterEditBox:SetScript("OnEscapePressed", function(self)
        self:ClearFocus()
    end)

    --insert "filter tags" on top
    local filterText = BlueprintManager.tagManager:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    filterText:SetPoint("BOTTOM", filterEditBox, "TOP", -2.5, -2.5)
    filterText:SetText("Filter tags")


    filterEditBox:SetScript("OnTextChanged", function(self)
        local filterText = self:GetText()
        if filterText == "" then
            isFilteringTags = false
            BlueprintManager.tagManager.tagListFrame.UpdateScrollFrame()
            return
        end

        local _filteredTags = {}
        for index, tag in ipairs(BlueprintManagerData.tags) do
            if(string.find(string.trim(tag.name),string.trim(filterText))) then
                table.insert(_filteredTags, tag)
            end
        end

        isFilteringTags = true
        filteredTags = _filteredTags
        BlueprintManager.tagManager.tagListFrame.UpdateScrollFrame()
    end)

    -- I need another editbox, similar but only visible when a tag is selected
    BlueprintManager.tagManager.editBoxForSelectedTag = CreateFrame("EditBox", nil, BlueprintManager.tagManager, "InputBoxTemplate")
    BlueprintManager.tagManager.editBoxForSelectedTag:SetSize(80, 30)
    BlueprintManager.tagManager.editBoxForSelectedTag:SetPoint("TOP", filterEditBox, "BOTTOM", 0, -15)
    BlueprintManager.tagManager.editBoxForSelectedTag:SetAutoFocus(false)
    BlueprintManager.tagManager.editBoxForSelectedTag:SetFontObject("GameFontHighlight")
    BlueprintManager.tagManager.editBoxForSelectedTag:SetMaxLetters(50)
    BlueprintManager.tagManager.editBoxForSelectedTag:Hide()
    BlueprintManager.tagManager.editBoxForSelectedTag:SetScript("OnEnterPressed", function(self)
        self:ClearFocus()
    end)
    BlueprintManager.tagManager.editBoxForSelectedTag:SetScript("OnEscapePressed", function(self)
        self:ClearFocus()
    end)

    BlueprintManager.tagManager.title = BlueprintManager.tagManager.editBoxForSelectedTag:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    BlueprintManager.tagManager.title:SetPoint("BOTTOM", BlueprintManager.tagManager.editBoxForSelectedTag, "TOP", 0, 5)
    BlueprintManager.tagManager.title:SetText("Rename Tag")
    BlueprintManager.tagManager.title:Hide()

     BlueprintManager.tagManager.renameTagButton = CreateFrame("Button", nil, BlueprintManager.tagManager.editBoxForSelectedTag, "UIPanelButtonTemplate")
     BlueprintManager.tagManager.renameTagButton:SetSize(30, 30)
     BlueprintManager.tagManager.renameTagButton:SetPoint("TOP", BlueprintManager.tagManager.editBoxForSelectedTag, "BOTTOM", 0, -10)
     BlueprintManager.tagManager.renameTagButton.texture =  BlueprintManager.tagManager.renameTagButton:CreateTexture(nil, "ARTWORK")
     BlueprintManager.tagManager.renameTagButton.texture:SetTexture("Interface\\AddOns\\" .. addonName .. "\\assets\\buttons\\BPMRenameButton.blp")
     BlueprintManager.tagManager.renameTagButton.texture:SetSize(BlueprintManager.tagManager.renameTagButton:GetWidth(), BlueprintManager.tagManager.renameTagButton:GetHeight())
     BlueprintManager.tagManager.renameTagButton.texture:SetPoint("CENTER")
     BlueprintManager.tagManager.renameTagButton:SetScript("OnMouseDown", function(self)
        self:SetSize(BlueprintManager.tagManager.renameTagButton:GetWidth()-2, BlueprintManager.tagManager.renameTagButton:GetHeight()-2)
    end)
     BlueprintManager.tagManager.renameTagButton:SetScript("OnMouseUp", function(self)
        self:SetSize(BlueprintManager.tagManager.renameTagButton:GetWidth(), BlueprintManager.tagManager.renameTagButton:GetHeight())
    end)
    BlueprintManager.RegisterTooltip(BlueprintManager.tagManager.renameTagButton, "Rename the selected tag")

     BlueprintManager.tagManager.renameTagButton:SetScript("OnClick", function()
        local newTagName = BlueprintManager.tagManager.editBoxForSelectedTag:GetText()
        if newTagName and newTagName ~= "" and not doesTagExist(string.gsub(newTagName, " ", "_")) then
            newTagName = string.gsub(newTagName, " ", "_")
            for _, blueprint in ipairs(BlueprintManagerData.blueprint) do
                for i, tag in ipairs(blueprint.tags) do
                    if tag == BlueprintManager.tagManager.selectedTag.name then
                        blueprint.tags[i] = newTagName
                    end
                end
            end
            BlueprintManager.tagManager.selectedTag.name = newTagName
            BlueprintManager.createLeftPanelForMainFrame(true)
            BlueprintManager.tagManager.tagListFrame.UpdateScrollFrame()
            if BlueprintManager.editionPanel and BlueprintManager.editionPanel.tagSection and BlueprintManager.editionPanel.tagSection.dropDown then
                BlueprintManager.editionPanel.tagSection.dropDown:Hide()
                BlueprintManager.editionPanel.tagSection.dropDown = nil
                BlueprintManager.editionPanel.tagSection.createTagDropdown(BlueprintManager.selectedBlueprint)
            end
            BlueprintManager.tagManager.editBoxForSelectedTag:Hide()
            BlueprintManager.tagManager.title:Hide()
            BlueprintManager.tagManager.renameTagButton:Hide()
        else
            playIncorrectDataAnimation(BlueprintManager.tagManager.renameTagButton, BlueprintManager.tagManager.editBoxForSelectedTag, doesTagExist(newTagName), not newTagName or newTagName == "")
        end
    end)

    -- Hide the rename button and edit box initially
    BlueprintManager.tagManager.renameTagButton:Hide()
    BlueprintManager.tagManager.editBoxForSelectedTag:Hide()
    
end

function BlueprintManager.createPanelForFiltering()
    if BlueprintManager.filterPanel then
        if BlueprintManager.filterPanel:IsShown() then
            BlueprintManager.filterPanel:Hide()
            BlueprintManager.filterPanel = nil
            return
        end
    end

    BlueprintManager.filterPanel = CreateFrame("Frame", nil, BlueprintManager.mainFrame,"PortraitFrameTemplate")
    ButtonFrameTemplateMinimizable_HidePortrait(BlueprintManager.filterPanel)
    NineSliceUtil.ApplyLayoutByName(BlueprintManager.filterPanel.NineSlice, "EpsilonGoldBorderFrameTemplateNoPortrait")
    
    BlueprintManager.filterPanel:SetSize(180, 150)
    BlueprintManager.filterPanel:SetPoint("TOPRIGHT", BlueprintManager.mainFrame, "TOPLEFT", 0, -40)

    BlueprintManager.filterPanel.bgTexture = BlueprintManager.filterPanel:CreateTexture(nil, "BACKGROUND")
    BlueprintManager.filterPanel.bgTexture:SetTexture("Interface/AddOns/" .. addonName .. "/assets/ninesplice/ManagerBG.blp")
    BlueprintManager.filterPanel.bgTexture:SetPoint("CENTER", BlueprintManager.filterPanel, "CENTER",0,0)
    BlueprintManager.filterPanel.bgTexture:SetSize(180, 150)

    EpsilonLib.Utils.NineSlice.SetBackgroundAsViewport(BlueprintManager.filterPanel, BlueprintManager.filterPanel.bgTexture)

    local f = BlueprintManager.filterPanel
    local titleBgColor = f:CreateTexture(nil, "BACKGROUND")
    local color = CreateColorFromHexString("FF3d2145")
    titleBgColor:SetPoint("TOPLEFT", f.TitleBg)
    titleBgColor:SetPoint("BOTTOMRIGHT", f.TitleBg, -0, 0)
    titleBgColor:SetColorTexture(color:GetRGBA())
    f.TitleBgColor = titleBgColor
    local r,g,b = color:GetRGB()
    f.TitleBg:SetVertexColor(r,g,b, 1)

    f.TitleText:SetText("Filtering panel")
    f.TitleText:SetPoint("LEFT", 30, 0) -- Fix title text position with no portrait

    -- Zone de recherche textuelle
    local searchBox = CreateFrame("EditBox", nil, BlueprintManager.filterPanel, "InputBoxTemplate")
    searchBox:SetSize(120, 24)
    searchBox:SetPoint("TOP",BlueprintManager.filterPanel,"TOP",0, -40)
    searchBox:SetAutoFocus(false)
    searchBox:SetFontObject("GameFontHighlight")
    
    searchBox:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)

    local searchLabel = BlueprintManager.filterPanel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    searchLabel:SetPoint("BOTTOM", searchBox, "TOP", 0, 2)
    searchLabel:SetText("Filter by Name")

    -- Dropdown de sélection de tags
    local tagDropDown = CreateFrame("Frame", "BlueprintFilterTagDropdown", BlueprintManager.filterPanel, "UIDropDownMenuTemplate")
    tagDropDown:SetPoint("TOP", searchBox, "TOP", 0, -50)
    UIDropDownMenu_SetWidth(tagDropDown, 120)
    UIDropDownMenu_SetText(tagDropDown, "Filter with Tags")

    local function UpdateBlueprintListByFilter()
        local filterText = searchBox:GetText():lower()
        if(filterText == "" and #BlueprintManager.selectedTagForFiltering == 0) then
            BlueprintManager.createLeftPanelForMainFrame(true,false,false,false)
            return
        end

        local filtered = {}
        for _, blueprint in ipairs(BlueprintManagerData.blueprint) do
            local matchText = filterText == "" or blueprint.blueprintName:lower():find(filterText, 1, true)
            local matchTags = #BlueprintManager.selectedTagForFiltering == 0
            if #BlueprintManager.selectedTagForFiltering > 0 then
                for _, tag in ipairs(BlueprintManager.selectedTagForFiltering) do
                    for _, btag in ipairs(blueprint.tags) do
                        if btag == tag then
                            matchTags = true
                            break
                        end
                    end
                    if matchTags then break end
                end
            end
            if matchText and matchTags then
                table.insert(filtered, blueprint)
            end
        end
        -- Remplace la liste affichée par la liste filtrée
        BlueprintManager.filteredBlueprints = filtered
        BlueprintManager.createLeftPanelForMainFrame(true,false,false,true)
    end

    local function TagDropDown_OnClick(self, arg1, arg2, checked)
        local tagName = self.value
        local found = false
        for i, v in ipairs(BlueprintManager.selectedTagForFiltering) do
            if v == tagName then
                table.remove(BlueprintManager.selectedTagForFiltering, i)
                found = true
                break
            end
        end
        if not found then
            table.insert(BlueprintManager.selectedTagForFiltering, tagName)
        end
        UIDropDownMenu_SetText(tagDropDown, #BlueprintManager.selectedTagForFiltering > 0 and table.concat(BlueprintManager.selectedTagForFiltering, ", ") or "Filtrer par tags")
        UpdateBlueprintListByFilter()
    end

    local function TagDropDown_Initialize(self, level)
        local info = UIDropDownMenu_CreateInfo()
        for _, tag in ipairs(BlueprintManagerData.tags) do
            info.text = tag.name
            info.value = tag.name
            info.func = TagDropDown_OnClick
            info.checked = tContains(BlueprintManager.selectedTagForFiltering, tag.name)
            info.keepShownOnClick = true
            UIDropDownMenu_AddButton(info, level)
        end
    end

    UIDropDownMenu_Initialize(tagDropDown, TagDropDown_Initialize)

    searchBox:SetScript("OnEnterPressed", function(self)
         UpdateBlueprintListByFilter()
    end)

end

function BlueprintManager:CreateFrameWithTexture()
    if BlueprintManager.mainFrame then
        if BlueprintManager.mainFrame:IsShown() then
            BlueprintManager.mainFrame:Hide()
            return
        else
            BlueprintManager.mainFrame:Show()
            return
        end
    else

        BlueprintManager.mainFrame = CreateFrame("Frame", "NPCCustomiserMainFrame", UIParent, "PortraitFrameTemplate")
        ButtonFrameTemplateMinimizable_HidePortrait(BlueprintManager.mainFrame)
        NineSliceUtil.ApplyLayoutByName(BlueprintManager.mainFrame.NineSlice, "EpsilonGoldBorderFrameTemplateNoPortrait")

        

        -- BlueprintManager.mainFrame = CreateFrame("Frame", nil, UIParent)
        BlueprintManager.mainFrame:SetSize(620, 450) -- Set the size of the frame
        BlueprintManager.mainFrame:SetPoint("CENTER") -- Position the frame in the center of the screen


        local f = BlueprintManager.mainFrame
        local titleBgColor = f:CreateTexture(nil, "BACKGROUND")
        local color = CreateColorFromHexString("FF3d2145")
        titleBgColor:SetPoint("TOPLEFT", f.TitleBg)
        titleBgColor:SetPoint("BOTTOMRIGHT", f.TitleBg, -0, 0)
        titleBgColor:SetColorTexture(color:GetRGBA())
        f.TitleBgColor = titleBgColor
        local r,g,b = color:GetRGB()
        f.TitleBg:SetVertexColor(r,g,b, 1)

        f.TitleText:SetText("Blueprint Manager")
        f.TitleText:SetPoint("LEFT", 80, 0) -- Fix title text position with no portrait

        BlueprintManager.mainFrame:EnableMouse(true)
        BlueprintManager.mainFrame:SetMovable(true)
        BlueprintManager.mainFrame:RegisterForDrag("LeftButton")
        BlueprintManager.mainFrame:SetScript("OnDragStart", BlueprintManager.mainFrame.StartMoving)
        BlueprintManager.mainFrame:SetScript("OnDragStop", BlueprintManager.mainFrame.StopMovingOrSizing)

        BlueprintManager.mainFrame.bgTexture = BlueprintManager.mainFrame:CreateTexture(nil, "BACKGROUND")
        BlueprintManager.mainFrame.bgTexture:SetTexture("Interface/AddOns/" .. addonName .. "/assets/ninesplice/ManagerBG.blp")
        BlueprintManager.mainFrame.bgTexture:SetPoint("CENTER", BlueprintManager.mainFrame, "CENTER",0,0)
        BlueprintManager.mainFrame.bgTexture:SetSize(620, 450)

        EpsilonLib.Utils.NineSlice.SetBackgroundAsViewport(BlueprintManager.mainFrame, BlueprintManager.mainFrame.bgTexture)

        BlueprintManager.createLeftPanelForMainFrame(nil,true)

        BlueprintManager.createRightPanelForMainFrame()

        BlueprintManager.mainFrame:Show();

        local searchButton=CreateFrame("Button", nil, BlueprintManager.mainFrame )
        searchButton:SetSize(25, 25)
        searchButton:SetPoint("TOPLEFT", 2.5, -22)
        searchButton.texture = searchButton:CreateTexture(nil, "OVERLAY")
        searchButton.texture:SetTexture("Interface/AddOns/" .. addonName .. "/assets/buttons/BPMSearchButton.blp")
        searchButton.texture:SetPoint("CENTER",searchButton, "CENTER",0,0)
        searchButton.texture:SetSize(25,25)

        searchButton:SetScript("OnEnter", function(self)
            self.texture:SetVertexColor(0.8, 0.8, 1, 1) -- Light blue highlight
        end)
        searchButton:SetScript("OnLeave", function(self)
            self.texture:SetVertexColor(1, 1, 1, 1) -- Reset to normal
        end)

        searchButton:SetScript("OnMouseDown", function(self)
            self:SetSize(23, 23)
        end)
        searchButton:SetScript("OnMouseUp", function(self)
            self:SetSize(25, 25)
        end)

        searchButton:SetScript("OnClick", function()
            BlueprintManager.createPanelForFiltering()
        end)

        BlueprintManager.RegisterTooltip(searchButton, "Open the filtering panel")
        

        local refreshButton = CreateFrame("Button", nil, BlueprintManager.mainFrame)
        refreshButton:SetSize(25, 25)
        refreshButton:SetPoint("TOPLEFT", 27.5, -22)
        refreshButton.texture = refreshButton:CreateTexture(nil, "OVERLAY")
        refreshButton.texture:SetTexture("Interface/AddOns/" .. addonName .. "/assets/buttons/BPMRefreshButton.blp")
        refreshButton.texture:SetPoint("CENTER",refreshButton, "CENTER",0,0)
        refreshButton.texture:SetSize(25,25)

        refreshButton:SetScript("OnEnter", function(self)
            self.texture:SetVertexColor(0.8, 0.8, 1, 1) -- Light blue highlight
        end)

        refreshButton:SetScript("OnLeave", function(self)
            self.texture:SetVertexColor(1, 1, 1, 1) -- Reset to normal
        end)

        refreshButton:SetScript("OnMouseDown", function(self)
            self:SetSize(23, 23)
        end)

        refreshButton:SetScript("OnMouseUp", function(self)
            self:SetSize(25, 25)
        end)
        refreshButton:SetScript("OnClick", function()
            BlueprintManager.createLeftPanelForMainFrame(true,true)
        end)
        BlueprintManager.RegisterTooltip(refreshButton, "Refresh the blueprint list")

        -- Create ordering dropdown to the right of refresh button
        local orderingDropdown = CreateOrderingDropdown(BlueprintManager.mainFrame)
        BlueprintManager.RegisterTooltip(orderingDropdown, "Select sorting mode for blueprints")

        local tagManagerButton = CreateFrame("Button", nil, BlueprintManager.mainFrame, "UIPanelButtonTemplate")
        tagManagerButton:SetSize(23, 23)
        tagManagerButton:SetPoint("TOPLEFT", 310, -22)
        tagManagerButton.texture = tagManagerButton:CreateTexture(nil, "ARTWORK")
        tagManagerButton.texture:SetTexture("Interface/AddOns/" .. addonName .. "/assets/buttons/BPMEmptyButton.blp")
        tagManagerButton.texture:SetSize(23, 2523)
        tagManagerButton.texture:SetAllPoints()

        tagManagerButton.icon=tagManagerButton:CreateTexture(nil, "OVERLAY")
        tagManagerButton.icon:SetAtlas('poi-workorders')
        tagManagerButton.icon:SetSize(16, 16)
        tagManagerButton.icon:SetPoint("CENTER",tagManagerButton, "CENTER",0,0)

        tagManagerButton:SetScript("OnMouseDown", function(self)
            self:SetSize(21, 21)
        end)
        tagManagerButton:SetScript("OnMouseUp", function(self)
            self:SetSize(23, 23)
        end)
        tagManagerButton:SetScript("OnClick", function()
            -- Open the tag manager UI
            OpenTagManagerUI()
        end)
        BlueprintManager.RegisterTooltip(tagManagerButton, "Open the tag manager")
    end
end

local function CreateMinimapIcon()
    LibStub("EpsiLauncher-1.0").API.new("Blueprint Manager", function()
        if BlueprintManager.mainFrame and BlueprintManager.mainFrame:IsShown() then
            BlueprintManager.mainFrame:Hide()
            return
        else
            BlueprintManager:CreateFrameWithTexture()
            return
        end
    end, "Interface/AddOns/" .. addonName .. "/assets/EpsilonBlueprintManagerIcon2025.blp", { "Click to open the Blueprint Manager." })
end

-- Event handling
function BlueprintManager:OnEvent(event,arg1, ...)
    if event == "ADDON_LOADED" and arg1 == addonName then
        if BlueprintManagerData == nil then
            BlueprintManagerData = {}
        end
        if(BlueprintManagerData.blueprint==nil) then
            BlueprintManagerData.blueprint={}
        end
        if(BlueprintManagerData.tags==nil) then
            BlueprintManagerData.tags={}
        end
        if LibStub.libs["EpsiLauncher-1.0"] then
            CreateMinimapIcon()
        else
            C_Timer.After(1, function()
                CreateMinimapIcon()
            end)
        end
    end
end

-- Register the addon
BlueprintManager.frame = CreateFrame("Frame")
BlueprintManager.frame:SetScript("OnEvent", function(_, event, ...)
    BlueprintManager:OnEvent(event, ...)
end)


BlueprintManager.frame:RegisterEvent("ADDON_LOADED")

-- Slash command handling
SLASH_BLUEPRINTMANAGER1 = "/BLUM"
SLASH_BLUEPRINTMANAGER2 = "/blum"

SlashCmdList["BLUEPRINTMANAGER"] = function(msg)
    BlueprintManager:CreateFrameWithTexture()
end

StaticPopupDialogs["CONFIRM_DELETE_BLUEPRINT"] = {
    text = "Are you sure you want to delete this blueprint ? (this |cffff0000delete it from the servers data|r, if you want to remove it from your phase see group commands.)",
    button1 = "Yes",
    button2 = "No",
    OnAccept = function(self, data)
        sendAddonCmd("gobject blueprint delete "..data.blueprintName)
        for index, blueprint in ipairs(BlueprintManagerData.blueprint) do
            if blueprint.blueprintId == data.blueprintId then
                table.remove(BlueprintManagerData.blueprint, index)
                break
            end
        end
        --Passing nil to fetch the data again
        BlueprintManager.createLeftPanelForMainFrame(true,true)
        BlueprintManager.createRightPanelForMainFrame()

       
    end,
    OnCancel = function(self, data)end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}

StaticPopupDialogs["CONFIRM_UPDATE_BLUEPRINT"] = {
    text = "Are you sure you want to update this blueprint with the selected group ?",
    button1 = "Yes",
    button2 = "No",
    OnAccept = function(self, data)
        sendAddonCmd("gobject blueprint update "..data.blueprintName,function(success,replies)
            if(success) then
                BlueprintManager.RefreshLeftPanelKeepOffset()
                BlueprintManager.createRightPanelForMainFrame(data)
            end
        end)
        -- Optionally, you can refresh the blueprint data or update the UI here

    end,
    OnCancel = function(self, data) end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}

StaticPopupDialogs["CONFIRM_APPLY_CHANGES"] = {
    text = "Are you sure you want to apply the changes to this blueprint?",
    button1 = "Yes",
    button2 = "No",
    OnAccept = function(self, data)
        UpdateBlueprint(data)
    end,
    OnCancel = function(self, data) end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}