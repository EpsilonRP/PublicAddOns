-------------------------------------------------------------------------------
-- Epsilon (C) 2025
-------------------------------------------------------------------------------

--
-- Aura editor interface.
--

local filteredList;
local FPSThrottle = 30;
local MinFPS = 5;
local maxSpellID = 403865 + 100000; --	Last known spell (This is the internal limit for this build)
local extraRangeStart = 100001;     -- For skybox spells
local extraRangeEnd = 1003865;

local searchCache = {};
local Scanner = CreateFrame("Frame");

local function SetSearch(text)
	text = text:lower();
	local tokens = {};
	for word in text:gmatch("%S+") do
		table.insert(tokens, word)
	end

	local cacheKey = table.concat(tokens, " ")
	if searchCache[cacheKey] then
		filteredList = searchCache[cacheKey]
		EpsilonAuraManagerAuraEditor_UpdateSearchPreview()
		return
	end

	-- build new list
	filteredList = {};
	local ScanPos = 0;
	local inExtraRange = false;
	local FirstPass = false;
	local RunTime = 0;
	local resultList = {}

	Scanner:SetScript("OnUpdate", function(self, elapsed)
		debugprofilestart();
		local changeflag = false;
		local limit = 1 / math.max(FPSThrottle, MinFPS)

		while (elapsed - RunTime + debugprofilestop() / 1000 < limit or not FirstPass) and ScanPos do
			if ScanPos then
				local name, rank, icon = GetSpellInfo(ScanPos, nil, true); -- this breaks icons if changed
				local desc = EpsilonAuraManagerAuraEditor_GetSpellTooltip(ScanPos)
				local lowerName = name and name:lower()
				local match = false

				for _, token in ipairs(tokens) do
					if lowerName and lowerName:find(token, 1, true) then
						match = true
					elseif lowerName and not lowerName:find(token, 1, true) then
						match = false
						break
					end
				end

				if match then
					local tbl = {
						spellID = ScanPos,
						name = name,
						icon = icon or "Interface\\Icons\\INV_Misc_QuestionMark",
						desc = desc
					};
					C_Spell.RequestLoadSpellData(ScanPos)
					table.insert(resultList, tbl);
				end

				-- increment scan position
				ScanPos = ScanPos + 1

				-- move to extra range if normal range is done
				if not inExtraRange and ScanPos > maxSpellID then
					ScanPos = extraRangeStart
					inExtraRange = true
				elseif inExtraRange and ScanPos > extraRangeEnd then
					ScanPos = nil
					break
				end
			end
			FirstPass = true;
		end

		filteredList = resultList
		EpsilonAuraManagerAuraEditor_UpdateSearchPreview(ScanPos == nil)

		-- cache the result
		if ScanPos == nil then
			searchCache[text] = resultList
		end

		FirstPass = false;
		RunTime = debugprofilestop() / 1000;
	end);
end

local function GetNumSearchResults()
	if filteredList then
		return #filteredList
	end
	return 0;
end

local function GetSearchDisplay(index)
	if not (filteredList) then
		return
	end
	local spellDesc = GetSpellDescription(filteredList[index].spellID, true) or "";

	return filteredList[index].name, filteredList[index].icon, filteredList[index].spellID, desc;
end

function EpsilonAuraManagerAuraEditor_ResetSearch()
	Scanner:SetScript("OnUpdate", nil)
	EpsilonAuraManagerAuraEditor_HideSearchPreview();
end

function EpsilonAuraManagerAuraEditor_SelectSearch(index)
	local buff = filteredList[index];

	if not (buff) then
		return
	end

	local name          = buff.name
	local icon          = buff.icon
	local desc          = buff.desc
	local spellDesc     = GetSpellDescription(buff.spellID, true);
	local spellID       = buff.spellID
	local visible       = true
	local allowOverride = false

	if Epsilon_AuraManager_IsAlreadyInAuraList(spellID) then
		local popup = StaticPopup_Show("EpsilonAuraManager_SPELLALREADYINLIST", nil, nil, spellID)
	else
		EpsilonAuraManagerAuraEditor.buffIcon:Enable()
		EpsilonAuraManagerAuraEditor.buffDesc.EditBox:Enable()
		EpsilonAuraManagerAuraEditor.spellDesc.EditBox:Enable()
		EpsilonAuraManagerAuraEditor.buffName:Enable()
		--EpsilonAuraManagerAuraEditor.Search:SetText(spellID .. ' - ' .. name)
		EpsilonAuraManagerAuraEditor.originalBuffIcon:SetTexture(icon)
		EpsilonAuraManagerAuraEditor.originalBuffName:SetText("|cFFFFFFFF" .. spellID .. " -|r " .. name)
		EpsilonAuraManagerAuraEditor.buffVisibility:Enable()
		EpsilonAuraManagerAuraEditor.buffOverride:Enable()
		EpsilonAuraManagerAuraEditor.buffName.Label:SetTextColor(1.0, 0.82, 0)
		EpsilonAuraManagerAuraEditor.buffDesc.Label:SetTextColor(1.0, 0.82, 0)
		EpsilonAuraManagerAuraEditor.spellDesc.Label:SetTextColor(1.0, 0.82, 0)
		EpsilonAuraManagerAuraEditor.buffOverride.Text:SetTextColor(1.0, 0.82, 0)
		EpsilonAuraManagerAuraEditor.buffID = spellID
		EpsilonAuraManagerAuraEditor.buffIcon:SetNormalTexture(icon)
		EpsilonAuraManagerAuraEditor.buffName:SetText(name)
		EpsilonAuraManagerAuraEditor.buffDesc.EditBox:SetText(desc)
		EpsilonAuraManagerAuraEditor.spellDesc.EditBox:SetText(spellDesc)
		EpsilonAuraManagerAuraEditor.buffVisibility:SetChecked(visible)
		EpsilonAuraManagerAuraEditor.buffVisibility.Text:SetTextColor(1.0, 0.82, 0)
		EpsilonAuraManagerAuraEditor.buffOverride:SetChecked(allowOverride);
		EpsilonAuraManagerAuraEditorSaveButton:Enable()
	end
	EpsilonAuraManagerSearchResults:Hide()
end

function EpsilonAuraManagerAuraEditor_UpdateSearchPreview(isSearchDone)
	if strlen(EpsilonAuraManagerAuraEditor.Search:GetText()) < 3 then
		EpsilonAuraManagerAuraEditor_ResetSearch();
		return;
	end

	local numResults = GetNumSearchResults();
	local lastShownEntry

	if numResults == 0 then
		EpsilonAuraManagerAuraEditor_HideSearchPreview();
		return;
	end

	for index = 1, 5 do
		local button = EpsilonAuraManagerAuraEditor.Search.searchPreview[index];
		if index <= numResults then
			local name, icon, spellID = GetSearchDisplay(index);
			button.name:SetText(name);
			button.spellID:SetText(spellID);
			button.icon:SetTexture(icon);
			button:SetID(index);
			button.SpellID = spellID;
			button:Show();
			lastShownEntry = index
		else
			button:Hide();
		end
	end

	EpsilonAuraManagerAuraEditor.Search.searchIndicator:SetPoint("TOP", EpsilonAuraManagerAuraEditor.Search.searchPreview[lastShownEntry], "BOTTOM")
	EpsilonAuraManagerAuraEditor.Search.showAllResults:SetPoint("TOP", EpsilonAuraManagerAuraEditor.Search.searchPreview[lastShownEntry], "BOTTOM")

	EpsilonAuraManagerAuraEditor.Search.showAllResults:Hide();
	if isSearchDone then
		EpsilonAuraManagerAuraEditor.Search.showAllResults.text:SetText(string.format("Show All %d Results", numResults));
		EpsilonAuraManagerAuraEditor.Search.searchIndicator:Hide()
		EpsilonAuraManagerAuraEditor.Search.showAllResults:Show();
	else
		EpsilonAuraManagerAuraEditor.Search.searchIndicator.text:SetText('Searching...');
		EpsilonAuraManagerAuraEditor.Search.showAllResults:Hide()
		EpsilonAuraManagerAuraEditor.Search.searchIndicator:Show()
	end


	EpsilonAuraManagerAuraEditor_FixSearchPreviewBottomBorder();
	EpsilonAuraManagerAuraEditor.Search.searchPreviewContainer:Show();
end

function EpsilonAuraManagerAuraEditor_FixSearchPreviewBottomBorder()
	local lastShownButton = nil;
	if EpsilonAuraManagerAuraEditor.Search.showAllResults:IsShown() then
		lastShownButton = EpsilonAuraManagerAuraEditor.Search.showAllResults;
	elseif EpsilonAuraManagerAuraEditor.Search.searchIndicator:IsShown() then
		lastShownButton = EpsilonAuraManagerAuraEditor.Search.searchIndicator;
	else
		for index = 1, 5 do
			local button = EpsilonAuraManagerAuraEditor.Search.searchPreview[index];
			if button:IsShown() then
				lastShownButton = button;
			end
		end
	end

	if lastShownButton ~= nil then
		EpsilonAuraManagerAuraEditor.Search.searchPreviewContainer.botRightCorner:SetPoint("BOTTOM", lastShownButton, "BOTTOM", 0, -8);
		EpsilonAuraManagerAuraEditor.Search.searchPreviewContainer.botLeftCorner:SetPoint("BOTTOM", lastShownButton, "BOTTOM", 0, -8);
	else
		EpsilonAuraManagerAuraEditor_HideSearchPreview();
	end
end

function EpsilonAuraManagerAuraEditor_HideSearchPreview()
	EpsilonAuraManagerAuraEditor.Search.showAllResults:Hide();
	EpsilonAuraManagerAuraEditor.Search.searchIndicator:Hide();

	local index = 1;
	local unusedButton = EpsilonAuraManagerAuraEditor.Search.searchPreview[index];
	while unusedButton do
		unusedButton:Hide();
		index = index + 1;
		unusedButton = EpsilonAuraManagerAuraEditor.Search.searchPreview[index];
	end

	EpsilonAuraManagerAuraEditor.Search.searchPreviewContainer:Hide();
end

function EpsilonAuraManagerAuraEditor_ClearSearch()
	EpsilonAuraManagerAuraEditor_HideSearchPreview();
end

function EpsilonAuraManagerAuraEditor_OnTextChanged(self)
	SearchBoxTemplate_OnTextChanged(self);

	local text = self:GetText();
	if strlen(text) < 3 then
		EpsilonAuraManagerAuraEditor_ClearSearch();
		EpsilonAuraManagerAuraEditor_HideSearchPreview();
		return;
	end

	EpsilonAuraManagerAuraEditor_SetSearchPreviewSelection(1);
	SetSearch(text);
end

function EpsilonAuraManagerAuraEditor_OnEnterPressed(self)
	if self.selectedIndex > 6 or self.selectedIndex < 0 then
		return;
	elseif self.selectedIndex == 6 then
		if EpsilonAuraManagerAuraEditor.Search.showAllResults:IsShown() then
			EpsilonAuraManagerAuraEditor.Search.showAllResults:Click();
		end
	else
		local preview = EpsilonAuraManagerAuraEditor.Search.searchPreview[self.selectedIndex];
		if preview:IsShown() then
			preview:Click();
		end
	end

	EpsilonAuraManagerAuraEditor_HideSearchPreview();
end

function EpsilonAuraManagerAuraEditor_OnKeyDown(self, key)
	if key == "UP" then
		EpsilonAuraManagerAuraEditor_SetSearchPreviewSelection(EpsilonAuraManagerAuraEditor.Search.selectedIndex - 1);
	elseif key == "DOWN" then
		EpsilonAuraManagerAuraEditor_SetSearchPreviewSelection(EpsilonAuraManagerAuraEditor.Search.selectedIndex + 1);
	end
end

-- Call this any time an edit box field is changed.
-- This will make the 'Cancel' button give a confirmation prompt.

local isDirty = false;
function EpsilonAuraManagerAuraEditor_MarkDirty(self, userInput)
	if userInput and not isDirty then
		isDirty = true;
	end
end

function EpsilonAuraManagerAuraEditor_OnFocusLost(self)
	SearchBoxTemplate_OnEditFocusLost(self);
	EpsilonAuraManagerAuraEditor_HideSearchPreview();
end

function EpsilonAuraManagerAuraEditor_OnFocusGained(self)
	SearchBoxTemplate_OnEditFocusGained(self);
	EpsilonAuraManagerAuraEditor_SetSearchPreviewSelection(1);
	EpsilonAuraManagerAuraEditor.Search.isHidden = false;
	EpsilonAuraManagerAuraEditor_UpdateSearchPreview();
end

function EpsilonAuraManagerAuraEditor_SearchUpdate()
	local scrollFrame = EpsilonAuraManagerSearchResults.scrollFrame;
	local offset = HybridScrollFrame_GetOffset(scrollFrame);
	local results = scrollFrame.buttons;
	local result, index;

	local numResults = GetNumSearchResults();

	for i = 1, #results do
		result = results[i];
		index = offset + i;
		if index <= numResults then
			local name, icon, spellID, desc = GetSearchDisplay(index);

			result.spellID = spellID;
			result.SpellName:SetText(name);
			result.SpellDesc:SetText(desc);
			result.SpellID:SetText(spellID);
			result.SpellIcon:SetTexture(icon);
			result:SetID(index);
			result:Show();

			if result.showingTooltip then
				if spellID then
					GameTooltip:SetOwner(result, "ANCHOR_RIGHT");
					GameTooltip:SetSpellByID(spellID)
				else
					GameTooltip:Hide();
				end
			end
		else
			result:Hide();
		end
	end

	local totalHeight = numResults * 49;
	HybridScrollFrame_Update(scrollFrame, totalHeight, 370);
end

function EpsilonAuraManagerAuraEditor_SetSearchPreviewSelection(selectedIndex)
	local searchBox = EpsilonAuraManagerAuraEditor.Search;
	local numShown = 0;
	for index = 1, 5 do
		searchBox.searchPreview[index].selectedTexture:Hide();

		if searchBox.searchPreview[index]:IsShown() then
			numShown = numShown + 1;
		end
	end

	if searchBox.showAllResults:IsShown() then
		numShown = numShown + 1;
	end

	searchBox.showAllResults.selectedTexture:Hide();

	if numShown == 0 then
		selectedIndex = 1;
	elseif selectedIndex > numShown then
		-- Wrap under to the beginning.
		selectedIndex = 1;
	elseif selectedIndex < 1 then
		-- Wrap over to the end;
		selectedIndex = numShown;
	end

	searchBox.selectedIndex = selectedIndex;

	if selectedIndex == 6 then
		searchBox.showAllResults.selectedTexture:Show();
	else
		searchBox.searchPreview[selectedIndex].selectedTexture:Show();
	end
end

function EpsilonAuraManagerAuraEditor_ShowFullSearch()
	local numResults = GetNumSearchResults();

	EpsilonAuraManagerAuraEditor_SearchUpdate();
	EpsilonAuraManagerAuraEditor_HideSearchPreview();
	EpsilonAuraManagerAuraEditor.Search:ClearFocus();

	EpsilonAuraManagerSearchResults.scrollFrame.scrollBar:SetValue(0);
	EpsilonAuraManagerSearchResults:Show();
end

function EpsilonAuraManagerSearchResults_OnLoad(self)
	self:SetClampedToScreen(true);
	self:SetMovable(true);
	self:EnableMouse(true);
	self:RegisterForDrag("LeftButton");
	self:SetScript("OnDragStart", self.StartMoving);
	self:SetScript("OnDragStop", self.StopMovingOrSizing);
	self:SetUserPlaced(true);

	self.scrollFrame.update = EpsilonAuraManagerAuraEditor_SearchUpdate;
	self.scrollFrame.scrollBar.doNotHide = true;
	HybridScrollFrame_CreateButtons(self.scrollFrame, "EpsilonAuraManagerSearchEntryTemplate", 0, 0);
end

function EpsilonAuraManagerAuraEditor_BuffButton_FormatTime(seconds)
	local timeRemaining = math.floor(seconds) .. " seconds"
	if seconds > 86400 then
		seconds = math.ceil(seconds / 86400)
		timeRemaining = seconds .. " days"
	elseif seconds > 3600 then
		seconds = math.ceil(seconds / 3600)
		timeRemaining = seconds .. " hours"
	elseif seconds > 60 then
		seconds = math.ceil(seconds / 60)
		timeRemaining = seconds .. " minutes"
	end
	return timeRemaining
end

function EpsilonAuraManagerAuraEditor_Refresh()
	local auraList = Epsilon_AuraManager_GetAurasTable()
	local selected = EpsilonAuraManagerFrame.selected
	local buff, spellID
	if selected then
		EpsilonAuraManagerAuraEditorSaveButton:Enable()
		EpsilonAuraManagerAuraEditor.buffIcon:Enable()
		EpsilonAuraManagerAuraEditor.buffDesc.EditBox:Enable()
		EpsilonAuraManagerAuraEditor.spellDesc.EditBox:Enable()
		EpsilonAuraManagerAuraEditor.buffName:Enable()
		EpsilonAuraManagerAuraEditor.buffVisibility:Enable()
		EpsilonAuraManagerAuraEditor.buffOverride:Enable()
		EpsilonAuraManagerAuraEditor.buffName.Label:SetTextColor(1.0, 0.82, 0)
		EpsilonAuraManagerAuraEditor.buffDesc.Label:SetTextColor(1.0, 0.82, 0)
		EpsilonAuraManagerAuraEditor.spellDesc.Label:SetTextColor(1.0, 0.82, 0)
		EpsilonAuraManagerAuraEditor.buffVisibility.Text:SetTextColor(1.0, 0.82, 0)
		EpsilonAuraManagerAuraEditor.buffOverride.Text:SetTextColor(1.0, 0.82, 0)
		spellID = auraList[selected].spellID
		EpsilonAuraManagerAuraEditor.buffID = spellID
		buff = Epsilon_AuraManager_GetSelected()
	else
		buff = {
			icon = "Interface/Icons/inv_misc_questionmark",
			name = "",
			desc = "",
			spellDesc = "",
			visible = false,
			allowOverride = false
		}
		EpsilonAuraManagerAuraEditorSaveButton:Disable()
		EpsilonAuraManagerAuraEditor.buffIcon:Disable()
		EpsilonAuraManagerAuraEditor.buffDesc.EditBox:Disable()
		EpsilonAuraManagerAuraEditor.spellDesc.EditBox:Disable()
		EpsilonAuraManagerAuraEditor.buffName:Disable()
		EpsilonAuraManagerAuraEditor.buffVisibility:Disable()
		EpsilonAuraManagerAuraEditor.buffOverride:Disable()
		EpsilonAuraManagerAuraEditor.buffVisibility.Text:SetTextColor(0.6, 0.6, 0.6)
		EpsilonAuraManagerAuraEditor.buffOverride.Text:SetTextColor(0.6, 0.6, 0.6)
		EpsilonAuraManagerAuraEditor.buffName.Label:SetTextColor(0.6, 0.6, 0.6)
		EpsilonAuraManagerAuraEditor.buffDesc.Label:SetTextColor(0.6, 0.6, 0.6)
		EpsilonAuraManagerAuraEditor.spellDesc.Label:SetTextColor(0.6, 0.6, 0.6)
		EpsilonAuraManagerAuraEditor.Search:SetText('')
	end

	if Epsilon_AuraManager.isLocal then
		EpsilonAuraManagerAuraEditor.buffOverride:Hide()
		EpsilonAuraManagerAuraEditor:SetHeight(445)
	else
		EpsilonAuraManagerAuraEditor.buffOverride:Show()
		EpsilonAuraManagerAuraEditor:SetHeight(470)
	end

	local originalName, _, originalIcon = GetSpellInfo(spellID, nil, true)

	EpsilonAuraManagerAuraEditor.originalBuffIcon:SetTexture(originalIcon)
	if spellID then
		EpsilonAuraManagerAuraEditor.originalBuffIcon:SetDesaturated(false)
		EpsilonAuraManagerAuraEditor.originalBuffName:SetText("|cFFFFFFFF" .. spellID .. " -|r " .. originalName)
	else
		EpsilonAuraManagerAuraEditor.originalBuffIcon:SetDesaturated(true)
		EpsilonAuraManagerAuraEditor.originalBuffName:SetText("|cFF999999(No Aura Selected)")
	end
	EpsilonAuraManagerAuraEditor.buffIcon:SetNormalTexture(buff.icon)
	EpsilonAuraManagerAuraEditor.buffName:SetText(buff.name)
	EpsilonAuraManagerAuraEditor.buffVisibility:SetChecked(buff.visible)
	EpsilonAuraManagerAuraEditor.buffOverride:SetChecked(buff.allowOverride)
	EpsilonAuraManagerAuraEditor.buffDesc.EditBox:SetText(buff.desc)
	EpsilonAuraManagerAuraEditor.spellDesc.EditBox:SetText(buff.spellDesc)
	EpsilonAuraManagerAuraEditor.selected = nil

	isDirty = false;
end

function EpsilonAuraManagerAuraEditor_Save()
	if not EpsilonAuraManagerAuraEditor.buffID then
		return
	end

	if EpsilonAuraManagerAuraEditor.buffName:GetText() == "" then
		UIErrorsFrame:AddMessage("Invalid name: too short.", 1.0, 0.0, 0.0, 53, 5);
		return
	end

	local spellID = EpsilonAuraManagerAuraEditor.buffID;

	spell = {
		name          = EpsilonAuraManagerAuraEditor.buffName:GetText(),
		icon          = EpsilonAuraManagerAuraEditor.buffIcon.icon:GetTexture(),
		desc          = EpsilonAuraManagerAuraEditor.buffDesc.EditBox:GetText(),
		spellDesc     = EpsilonAuraManagerAuraEditor.spellDesc.EditBox:GetText(),
		visible       = EpsilonAuraManagerAuraEditor.buffVisibility:GetChecked(),
		allowOverride = EpsilonAuraManagerAuraEditor.buffOverride:GetChecked(),
	};
	Epsilon_AuraManager_Save(spell, spellID)
	EpsilonAuraManagerAuraEditor_Close()
	EpsilonAuraManagerFrame_Update()
end

function EpsilonAuraManagerAuraEditor_SelectIcon(texture)
	EpsilonAuraManagerAuraEditor.buffIcon:SetNormalTexture(texture)
end

function EpsilonAuraManager_PickIcon()
	EpsilonLibIconPicker_Open(EpsilonAuraManagerAuraEditor_SelectIcon, true, true)
end

function EpsilonAuraManagerAuraEditor_Close(checkForEdits)
	if checkForEdits and isDirty then
		StaticPopup_Show("EpsilonAuraManager_CANCELCONFIRMATION")
	else
		EpsilonLibIconPicker_Close()
		EpsilonAuraManagerFrame_Update()
		EpsilonAuraManagerAuraEditor:Hide()
	end
end

function EpsilonAuraManagerAuraEditor_Open()
	EpsilonAuraManagerAuraEditor_Refresh()
	EpsilonAuraManagerAuraEditor:Show()
end

-------------------------------------------------------------------------------
