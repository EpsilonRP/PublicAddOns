local _, EpsiLib = ...

--// SpellBookUI Module is based on Spell Book Search by Kerbaal for the Searchbar, modified to expand features & fix casting spells directly.
--// Spell Book Search is covered by the MIT License. The MIT License Copyright (c) <year> <copyright holders> Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions: The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software. THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
--// https://www.curseforge.com/wow/addons/spell-book-search/comments#license

EpsiLib.SpellBookUI = {}
local Addon = EpsiLib.SpellBookUI

local runOnce = false
EpsiLib.EventManager:Register("ADDON_LOADED", function()
	if runOnce then return end
	if EpsiLib_DB.Modules.SpellBookUI then
		Addon:initialize()
		runOnce = true
	end
end)

--- @return number StartPos, number EndPos
local function GetTextHighlight(self)
	local Text, Cursor = self:GetText(), self:GetCursorPosition();
	self:Insert(""); -- Delete selected text
	local TextNew, CursorNew = self:GetText(), self:GetCursorPosition();
	-- Restore previous text
	self:SetText(Text);
	self:SetCursorPosition(Cursor);
	local Start, End = CursorNew, #Text - (#TextNew - CursorNew);
	self:HighlightText(Start, End);
	return Start, End;
end

function Addon:initialize()
	EpsiLib_DB.options.spellBookUI = EpsiLib_DB.options.spellBookUI or {}
	local options = EpsiLib_DB.options.spellBookUI

	local function UpdateSearch()
		SpellBookFrame_Update()
	end

	local function UpdateHideFutureSpellsToggle(self)
		SpellBookFrame_Update()
		options.hideFutureSpells = self:GetChecked()
	end

	local function SearchBox_OnTextChanged(self, userInput)
		Addon.SearchBox_OldOnTextChanged(self, userInput)
		SpellBookFrame_Update()
	end

	local function dbgprnt(...)
		--return print(...)
	end

	local function cmd(text)
		SendChatMessage("." .. text, "GUILD");
	end

	function Addon:getOrCreateSearchBox()
		if (Addon.SearchBox ~= nil) then
			return Addon.SearchBox
		end

		Addon.SearchBox = CreateFrame("EditBox", "SearchBox", SpellBookFrame, "SearchBoxTemplate")
		Addon.SearchBox:SetWidth(150) -- Set these to whatever height/width is needed
		Addon.SearchBox:SetHeight(20) -- for your Texture
		Addon.SearchBox:SetPoint("TOPRIGHT", SpellBookFrame, "TOPRIGHT", -25, -1)
		Addon.SearchBox:Show()
		Addon.SearchBox.Left:SetAlpha(0.5)
		Addon.SearchBox.Right:SetAlpha(0.5)
		Addon.SearchBox.Middle:SetAlpha(0.5)
		Addon.SearchBox.Left:Hide()
		Addon.SearchBox.Right:Hide()
		Addon.SearchBox.Middle:Hide()

		Addon.SearchBox:SetScript("OnEnterPressed", UpdateSearch)
		Addon.SearchBox_OldOnTextChanged = Addon.SearchBox:GetScript("OnTextChanged")
		Addon.SearchBox:SetScript("OnTextChanged", SearchBox_OnTextChanged)

		local offset = 35
		Addon.SearchBox:HookScript("OnEditFocusLost", function(self)
			self.Left:Hide()
			self.Right:Hide()
			self.Middle:Hide()
			SpellBookFrame.TitleText:AdjustPointsOffset(offset, 0)
			self:SetWidth(150)
		end)
		Addon.SearchBox:HookScript("OnEditFocusGained", function(self)
			self.Left:Show()
			self.Right:Show()
			self.Middle:Show()
			SpellBookFrame.TitleText:AdjustPointsOffset(-offset, 0)
			self:SetWidth(250)
			local startPos, endPos = GetTextHighlight(self)
			self:HighlightText(0, 0)
			self:SetCursorPosition(startPos)
		end)

		return Addon.SearchBox;
	end

	function Addon:getOrCreateToggleFutureCheckbox()
		if (Addon.ToggleFutureCheckbox ~= nil) then
			return Addon.ToggleFutureCheckbox
		end

		Addon.ToggleFutureCheckbox = CreateFrame("CheckButton", nil, SpellBookFrame, "UICheckButtonTemplate")
		Addon.ToggleFutureCheckbox:SetPoint("TOPLEFT", SpellBookFrame, "TOPLEFT", 85, -2)
		Addon.ToggleFutureCheckbox:SetSize(20, 20)
		Addon.ToggleFutureCheckbox:SetChecked(false)
		Addon.ToggleFutureCheckbox:SetScript("OnClick", UpdateHideFutureSpellsToggle)
		Addon.ToggleFutureCheckbox.text:SetText("Hide Unlearned")
		Addon.ToggleFutureCheckbox:Show()
		Addon.ToggleFutureCheckbox:SetChecked(options.hideFutureSpells)
		UpdateHideFutureSpellsToggle(Addon.ToggleFutureCheckbox)

		return Addon.ToggleFutureCheckbox
	end

	function Addon:updateSearchBox()
		local box = Addon:getOrCreateSearchBox()
		if (SpellBookFrame.bookType ~= BOOKTYPE_SPELL) then
			box:Hide()
		else
			box:Show()
		end

		local futureCheckbox = Addon:getOrCreateToggleFutureCheckbox()
		if (SpellBookFrame.bookType ~= BOOKTYPE_SPELL) then
			futureCheckbox:Hide()
		else
			futureCheckbox:Show()
		end
	end

	local function GetFullSpellName(slot, bookType)
		local spellName, subSpellName = GetSpellBookItemName(slot, bookType);
		local isPassive = IsPassiveSpell(slot, bookType);

		if (not subSpellName) then
			subSpellName = ""
		end

		if (subSpellName == "") then
			if (IsTalentSpell(slot, bookType)) then
				if (isPassive) then
					subSpellName = TALENT_PASSIVE
				else
					subSpellName = TALENT
				end
			elseif (isPassive) then
				subSpellName = SPELL_PASSIVE;
			end
		end

		return spellName .. " " .. subSpellName
	end

	OldSpellBookFrame_Update = SpellBookFrame_Update

	function Addon:findSpells()
		if (SpellBookFrame.bookType ~= BOOKTYPE_SPELL) then
			Addon.spells = {};
			Addon.numSpells = j;
			return
		end

		if (not SpellBookFrame.selectedSkillLine) then
			SpellBookFrame.selectedSkillLine = 2;
		end

		local _, _, offset, numSlots, _, _ = GetSpellTabInfo(SpellBookFrame.selectedSkillLine);

		Addon.spells = {};
		local j = 1
		dbgprnt("Indexing from" .. offset .. "up to " .. (numSlots + offset)
			.. " on " .. SpellBookFrame.bookType)
		for i = 1, numSlots do
			local slotType, spellID = GetSpellBookItemInfo(i + offset, SpellBookFrame.bookType);
			local fullSpellName = GetFullSpellName(i + offset, SpellBookFrame.bookType);
			local searchText = Addon:getOrCreateSearchBox():GetText():gsub("%s+", "")
			local desc = GetSpellDescription(spellID)

			dbgprnt(spellName)
			if searchText == "" or
				fullSpellName:lower():match(searchText:lower()) then
				Addon.spells[offset + j] = i + offset;
				j = j + 1
			end
		end
		Addon.numSpells = j
	end

	--override
	function SpellBookFrame_Update()
		Addon:updateSearchBox()
		Addon:findSpells()
		OldSpellBookFrame_Update()
	end

	--override
	function SpellBook_GetCurrentPage()
		local currentPage, maxPages;
		local numPetSpells = HasPetSpells() or 0;
		if (SpellBookFrame.bookType == BOOKTYPE_PET) then
			currentPage = SPELLBOOK_PAGENUMBERS[BOOKTYPE_PET];
			maxPages = ceil(numPetSpells / SPELLS_PER_PAGE);
		elseif (SpellBookFrame.bookType == BOOKTYPE_SPELL) then
			currentPage = SPELLBOOK_PAGENUMBERS[SpellBookFrame.selectedSkillLine];
			local _, _, _, numSlots = GetSpellTabInfo(SpellBookFrame.selectedSkillLine);
			maxPages = ceil(Addon.numSpells / SPELLS_PER_PAGE);
		end
		return currentPage, maxPages;
	end

	--override
	function SpellBook_GetSpellBookSlot(spellButton)
		local id = spellButton:GetID()
		if (SpellBookFrame.bookType == BOOKTYPE_PROFESSION) then
			return id + spellButton:GetParent().spellOffset;
		elseif (SpellBookFrame.bookType == BOOKTYPE_PET) then
			local slot = id + (SPELLS_PER_PAGE * (SPELLBOOK_PAGENUMBERS[BOOKTYPE_PET] - 1));
			local slotType, slotID = GetSpellBookItemInfo(slot, SpellBookFrame.bookType);
			return slot, slotType, slotID;
		else
			local relativeSlot = id + (SPELLS_PER_PAGE * (SPELLBOOK_PAGENUMBERS[SpellBookFrame.selectedSkillLine] - 1));
			if (SpellBookFrame.selectedSkillLineNumSlots and relativeSlot <= SpellBookFrame.selectedSkillLineNumSlots) then
				local slot = SpellBookFrame.selectedSkillLineOffset + relativeSlot;
				dbgprnt("Slot" .. slot)
				local filteredSlot = Addon.spells[slot];
				if filteredSlot then
					dbgprnt(" to " .. filteredSlot)
					local slotType, slotID = GetSpellBookItemInfo(Addon.spells[slot], SpellBookFrame.bookType);
					local spellName, subSpellName = GetSpellBookItemName(Addon.spells[slot], SpellBookFrame.bookType);
					dbgprnt(spellName)
					return filteredSlot, slotType, slotID;
				end
				return nil, nil
			else
				return nil, nil;
			end
		end
	end

	local function genSeparator()
		local separatorInfo = {
			text = true,
			hasArrow = false,
			dist = 0,
			isTitle = true,
			isUninteractable = true,
			notCheckable = true,
			iconOnly = true,
			icon = "Interface\\Common\\UI-TooltipDivider-Transparent",
			tCoordLeft = 0,
			tCoordRight = 1,
			tCoordTop = 0,
			tCoordBottom = 1,
			tSizeX = 0,
			tSizeY = 8,
			tFitDropDownSizeX = true,
			iconInfo = {
				tCoordLeft = 0,
				tCoordRight = 1,
				tCoordTop = 0,
				tCoordBottom = 1,
				tSizeX = 0,
				tSizeY = 8,
				tFitDropDownSizeX = true
			},
		};
		return separatorInfo
	end
	local function genSpacer()
		local spaceInfo = {
			text = true,
			hasArrow = false,
			dist = 0,
			isTitle = true,
			isUninteractable = true,
			notCheckable = true,
		};
		return spaceInfo
	end

	local function quickButton(name, func, ttTitle, ttText)
		return {
			text = name,
			func = func,
			notCheckable = true,
			tooltipOnButton = true,
			tooltipTitle = ttTitle,
			tooltipText = ttText
		}
	end
	local function quickIndentedButton(level, ...)
		local button = quickButton(...)
		button.leftPadding = 8 * (level or 1)
		return button
	end
	local function quickTitle(name)
		return {
			text = name,
			isTitle = true,
			notCheckable = true,
		}
	end
	-- Note that this frame must be named for the dropdowns to work.
	local menuFrame = CreateFrame("Frame", "ExampleMenuFrame", UIParent, "UIDropDownMenuTemplate")

	local unlearnButton = quickButton("Unlearn", function() cmd(("unlearn %s"):format(menuFrame._spellID)) end)
	local learnButton = quickButton("Learn", function() cmd(("learn %s"):format(menuFrame._spellID)) end)

	local blizzCastButton = quickIndentedButton(1, 'Retail', function() C_Epsilon.RunPrivileged("CastSpell(" .. menuFrame._slotID .. ", 'spell')"); end, "Standard Casting of the Spell",
		"This is how spells normally cast in WoW. AoE spell cast this way can be placed with your cursor.")
	local emptyButton = {}

	local menu = {
		{
			text = "[Dynamic Spell Name]",
			isTitle = true,
			justifyH = "CENTER"
		},
		genSeparator(),
		quickTitle("Cast ..."),
		--4
		blizzCastButton,
		quickIndentedButton(1, 'Command', function() cmd(("cast %s"):format(menuFrame._spellID)) end),
		quickIndentedButton(2, 'Self', function() cmd(("cast %s %s"):format(menuFrame._spellID, "self")) end),
		quickIndentedButton(2, 'Trig', function() cmd(("cast %s %s"):format(menuFrame._spellID, "triggered")) end),
		quickIndentedButton(2, 'Self & Trig', function() cmd(("cast %s %s %s"):format(menuFrame._spellID, "self", "triggered")) end),
		genSeparator(),
		quickTitle("Aura ..."),
		quickIndentedButton(1, 'Aura', function() cmd(("aura %s"):format(menuFrame._spellID)) end),
		quickIndentedButton(1, 'Self', function() cmd(("aura %s %s"):format(menuFrame._spellID, "self")) end),
		genSeparator(),
		--14
		unlearnButton,
	}

	local function spellContext(spellInfo, slot)
		local known = IsSpellKnown(spellInfo.spellID)

		if known then
			menu[4] = blizzCastButton
			menu[14] = unlearnButton
		else
			menu[4] = emptyButton
			menu[14] = learnButton
		end

		menu[1].text = spellInfo.name and (CreateTextureMarkup(spellInfo.iconID, 24, 24, 24, 24, 0, 1, 0, 1) .. " " .. spellInfo.name) or "(Error Loading Spell Name)"
		menuFrame._spellID = spellInfo.spellID
		menuFrame._slotID = slot
		EasyMenu(menu, menuFrame, "cursor", 0, 0, "MENU");
	end

	--override
	function SpellButton_OnClick(self, button)
		local slot, slotType = SpellBook_GetSpellBookSlot(self);
		local _, spell_ID = GetSpellBookItemInfo(slot, SpellBookFrame.bookType);
		local spellInfo = C_SpellBook.GetSpellInfo(spell_ID)

		--[[ -- Old override handler, we don't like it, we can simulate the blizzlike!
		if spell_ID and not IsShiftKeyDown() then
			if button == "LeftButton" then
				print(button, IsControlKeyDown())
				if IsControlKeyDown() then
					print("Casting spell (normally): " .. spell_ID .. " from spellbook: " .. slotType)
					CastSpell(spell_ID, slotType)
				else
					print("Casting spell: " .. spell_ID);
					SendChatMessage(".cast " .. spell_ID .. " trig", "GUILD");
				end
			elseif button == "RightButton" then
				print("Using aura for spell: " .. spell_ID);
				SendChatMessage(".aura " .. spell_ID, "GUILD");
			end
		end
		--]]

		-- New Custom Right-Click Handler:
		if button == "RightButton" then
			-- Open a custom context menu here!

			spellContext(spellInfo, slot)

			return
		end

		-- Stock Blizzard Handling, except we run CastSpell privileged
		if (slot > MAX_SPELLS or slotType == "FUTURESPELL") then
			return;
		end
		if InClickBindingMode() then
			if ClickBindingFrame:HasNewSlot() and self.canClickBind then
				local slot = SpellBook_GetSpellBookSlot(self);
				local _, spellID = GetSpellBookItemInfo(slot, SpellBookFrame.bookType);
				ClickBindingFrame:AddNewAction(Enum.ClickBindingType.Spell, spellID);
			end
			return;
		end
		if (HasPendingGlyphCast() and SpellBookFrame.bookType == BOOKTYPE_SPELL) then
			local slotType, spellID = GetSpellBookItemInfo(slot, SpellBookFrame.bookType);
			if (slotType == "SPELL") then
				if (HasAttachedGlyph(spellID)) then
					if (IsPendingGlyphRemoval()) then
						StaticPopup_Show("CONFIRM_GLYPH_REMOVAL", nil, nil, { name = GetCurrentGlyphNameForSpell(spellID), id = spellID });
					else
						StaticPopup_Show("CONFIRM_GLYPH_PLACEMENT", nil, nil, { name = GetPendingGlyphName(), currentName = GetCurrentGlyphNameForSpell(spellID), id = spellID });
					end
				else
					AttachGlyphToSpell(spellID);
				end
			elseif (slotType == "FLYOUT") then
				SpellFlyout:Toggle(spellID, self, "RIGHT", 1, false, self.offSpecID, true);
				SpellFlyout:SetBorderColor(181 / 256, 162 / 256, 90 / 256);
			end
			return;
		end
		if (self.isPassive) then
			return;
		end
		if (button ~= "LeftButton" and SpellBookFrame.bookType == BOOKTYPE_PET) then
			if (self.offSpecID == 0) then
				ToggleSpellAutocast(slot, SpellBookFrame.bookType);
			end
		else
			local _, id = GetSpellBookItemInfo(slot, SpellBookFrame.bookType);
			if (slotType == "FLYOUT") then
				SpellFlyout:Toggle(id, self, "RIGHT", 1, false, self.offSpecID, true);
				SpellFlyout:SetBorderColor(181 / 256, 162 / 256, 90 / 256);
			else
				if (SpellBookFrame.bookType ~= BOOKTYPE_SPELLBOOK or self.offSpecID == 0) then
					C_Epsilon.RunPrivileged("CastSpell(" .. slot .. ", '" .. SpellBookFrame.bookType .. "')");
				end
			end
			SpellButton_UpdateSelection(self);
		end
	end

	-- Force Override hide future spells
	hooksecurefunc("SpellButton_UpdateButton", function(self)
		local _, _, offset, numSlots, _, offSpecID, shouldHide, specID = GetSpellTabInfo(SpellBookFrame.selectedSkillLine);
		SpellBookFrame.selectedSkillLineNumSlots = numSlots;
		SpellBookFrame.selectedSkillLineOffset = offset;
		local isOffSpec = (offSpecID ~= 0) and (SpellBookFrame.bookType == BOOKTYPE_SPELL);
		self.offSpecID = offSpecID;

		local slot, slotType, slotID = SpellBook_GetSpellBookSlot(self);
		local name = self:GetName();
		local iconTexture = _G[name .. "IconTexture"];
		local levelLinkLockTexture = _G[name .. "LevelLinkLockTexture"];
		local levelLinkLockBg = _G[name .. "LevelLinkLockBg"];
		local spellString = _G[name .. "SpellName"];
		local subSpellString = _G[name .. "SubSpellName"];
		local cooldown = _G[name .. "Cooldown"];
		local autoCastableTexture = _G[name .. "AutoCastable"];
		local slotFrame = _G[name .. "SlotFrame"];

		local highlightTexture = _G[name .. "Highlight"];
		local texture;
		if (slot) then
			texture = GetSpellBookItemTexture(slot, SpellBookFrame.bookType);
		end

		-- If no spell, hide everything and return, or kiosk mode and future spell
		if (not texture or (strlen(texture) == 0) or (slotType == "FUTURESPELL" and Addon.ToggleFutureCheckbox:GetChecked())) then
			iconTexture:Hide();
			levelLinkLockTexture:Hide();
			levelLinkLockBg:Hide();
			spellString:Hide();
			subSpellString:Hide();
			cooldown:Hide();
			autoCastableTexture:Hide();
			SpellBook_ReleaseAutoCastShine(self.shine);
			self.shine = nil;
			self.canClickBind = false;
			highlightTexture:SetTexture("Interface\\Buttons\\ButtonHilight-Square");
			self:SetChecked(false);
			slotFrame:Hide();
			self.IconTextureBg:Hide();
			self.SeeTrainerString:Hide();
			self.RequiredLevelString:Hide();
			self.UnlearnedFrame:Hide();
			self.TrainFrame:Hide();
			self.TrainTextBackground:Hide();
			self.TrainBook:Hide();
			self.FlyoutArrow:Hide();
			self.AbilityHighlightAnim:Stop();
			self.AbilityHighlight:Hide();
			self.GlyphIcon:Hide();
			self:Disable();
			self.TextBackground:SetDesaturated(isOffSpec);
			self.TextBackground2:SetDesaturated(isOffSpec);
			self.EmptySlot:SetDesaturated(isOffSpec);
			self.ClickBindingIconCover:Hide();
			self.ClickBindingHighlight:Hide();
			if self.SpellHighlightTexture then
				self.SpellHighlightTexture:Hide();
			end
		end
	end)
end
