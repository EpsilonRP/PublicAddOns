local _, EpsiLib = ...

--// SpellBookUI Module is based on Spell Book Search by Kerbaal for the Searchbar, modified to expand features & fix casting spells directly.
--// Spell Book Search is covered by the MIT License. The MIT License Copyright (c) <year> <copyright holders> Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions: The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software. THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
--// https://www.curseforge.com/wow/addons/spell-book-search/comments#license

EpsiLib.SpellBookUI = {}
local Addon = EpsiLib.SpellBookUI
local spellbook
local runOnce = false

StaticPopupDialogs["EPSILONLIB_RENAMESPELLBOOKTAB"] = {
	text = "What should this Tab be named?",
	button1 = "Accept",
	button2 = "Cancel",
	hasEditBox = true,
	OnAccept = function(self, data)
		spellbook.tabs[data].name = self.editBox:GetText()
		_G["SpellBookSkillLineTab" .. data].tooltip = self.editBox:GetText()
	end,
	timeout = 0,
	showAlert = true,
	whileDead = true,
	hideOnEscape = true,
	preferredIndex = 3,
}

EpsiLib.EventManager:Register("ADDON_LOADED", function(_, event, addon)
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
	spellbook = EpsilLib_Current_Char_DB.spellbook

	local function UpdateSearch()
		SpellBookFrame_Update()
	end

	local function UpdateHideFutureSpellsToggle(self)
		options.hideFutureSpells = self:GetChecked()
		SpellBookFrame_Update()
	end

	local function UpdateShowHiddenSpellsToggle(self)
		options.showHiddenSpells = self:GetChecked()
		SpellBookFrame_Update()
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
		Addon.SearchBox:SetPoint("TOPRIGHT", SpellBookFrame, "TOPRIGHT", -50, -1)
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

		local offset = 65
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

		Addon.ToggleFutureCheckbox = CreateFrame("CheckButton", nil, Addon.SettingsFrame, "UICheckButtonTemplate")
		Addon.ToggleFutureCheckbox:SetPoint("TOPLEFT", Addon.SettingsFrame.Inset, "TOPLEFT", 20, -5)
		Addon.ToggleFutureCheckbox:SetSize(20, 20)
		Addon.ToggleFutureCheckbox:SetChecked(false)
		Addon.ToggleFutureCheckbox:SetScript("OnClick", UpdateHideFutureSpellsToggle)
		Addon.ToggleFutureCheckbox.text:SetText("Hide Unlearned")
		Addon.ToggleFutureCheckbox:Show()
		Addon.ToggleFutureCheckbox:SetChecked(options.hideFutureSpells)
		UpdateHideFutureSpellsToggle(Addon.ToggleFutureCheckbox)

		return Addon.ToggleFutureCheckbox
	end

	function Addon:getOrCreateToggleHiddenCheckbox()
		if (Addon.ToggleHiddenCheckbox ~= nil) then
			return Addon.ToggleHiddenCheckbox
		end

		Addon.ToggleHiddenCheckbox = CreateFrame("CheckButton", nil, Addon.SettingsFrame, "UICheckButtonTemplate")
		Addon.ToggleHiddenCheckbox:SetPoint("TOPLEFT", Addon.SettingsFrame.Inset, "TOPLEFT", 20, -35)
		Addon.ToggleHiddenCheckbox:SetSize(20, 20)
		Addon.ToggleHiddenCheckbox:SetChecked(false)
		Addon.ToggleHiddenCheckbox:SetScript("OnClick", UpdateShowHiddenSpellsToggle)
		Addon.ToggleHiddenCheckbox.text:SetText("Show Hidden Spells")
		Addon.ToggleHiddenCheckbox:Show()
		Addon.ToggleHiddenCheckbox:SetChecked(options.showHiddenSpells)
		UpdateShowHiddenSpellsToggle(Addon.ToggleHiddenCheckbox)

		return Addon.ToggleHiddenCheckbox
	end

	function Addon:getOrCreateSettingsButton()
		if Addon.SettingsButton then
			return Addon.SettingsButton
		end

		Addon.SettingsButton = CreateFrame("Button", nil, SpellBookFrame)
		Addon.SettingsButton:SetPoint("CENTER", SpellBookFrame, "TOPRIGHT", -38, -11)
		Addon.SettingsButton:SetSize(19, 19)
		Addon.SettingsButton:SetScript("OnClick", function() if Addon.SettingsFrame:IsVisible() then Addon.SettingsFrame:Hide() else Addon.SettingsFrame:Show() end end)
		Addon.SettingsButton:SetNormalTexture("Interface\\addons\\EpsilonLib\\Resources\\Settings_Icon")
		Addon.SettingsButton:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight", "ADD")
		Addon.SettingsButton:Show()

		return Addon.SettingsButton
	end

	function Addon:getOrCreateSettingsFrame()
		if Addon.SettingsFrame then
			return Addon.SettingsFrame
		end

		Addon.SettingsFrame = CreateFrame("Frame", nil, SpellBookFrame, "ButtonFrameTemplate")

		Addon.SettingsFrame:SetSize(250, 250)
		Addon.SettingsFrame:SetPoint("TOPLEFT", SpellBookFrame, "TOPRIGHT", 35, 0)
		Addon.SettingsFrame:SetTitle('Settings')
		ButtonFrameTemplate_HidePortrait(Addon.SettingsFrame)
		ButtonFrameTemplate_HideAttic(Addon.SettingsFrame)
		ButtonFrameTemplate_HideButtonBar(Addon.SettingsFrame)
		Addon.SettingsFrame:Hide()

		return Addon.SettingsFrame
	end

	function Addon:updateSearchBox()
		local box = Addon:getOrCreateSearchBox()
		if (SpellBookFrame.bookType ~= BOOKTYPE_SPELL) then
			box:Hide()
		else
			box:Show()
		end

		local settingsFrame = Addon:getOrCreateSettingsFrame()

		local settingsButton = Addon:getOrCreateSettingsButton()
		if (SpellBookFrame.bookType ~= BOOKTYPE_SPELL) then
			settingsButton:Hide()
		else
			settingsButton:Show()
		end

		local futureCheckbox = Addon:getOrCreateToggleFutureCheckbox()
		if (SpellBookFrame.bookType ~= BOOKTYPE_SPELL) then
			futureCheckbox:Hide()
		else
			futureCheckbox:Show()
		end

		local hiddenCheckbox = Addon:getOrCreateToggleHiddenCheckbox()
		if (SpellBookFrame.bookType ~= BOOKTYPE_SPELL) then
			hiddenCheckbox:Hide()
		else
			hiddenCheckbox:Show()
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
			return
		end

		if (not SpellBookFrame.selectedSkillLine) then
			SpellBookFrame.selectedSkillLine = 2;
		end

		local searchText = Addon:getOrCreateSearchBox():GetText():gsub("%s+", "")

		if searchText == "" then
			return
		end


		local spells = {};
		spellbook.tabs[SpellBookFrame.selectedSkillLine].offset = 0
		for k,v in pairs(spellbook.spells) do
			local slotType, spellID = GetSpellBookItemInfo(v, SpellBookFrame.bookType);
			local fullSpellName, desc
			if slotType == "SPELL" or slotType == "FUTURESPELL" then
				fullSpellName = GetFullSpellName(v, SpellBookFrame.bookType);
				desc = GetSpellDescription(spellID)
			elseif slotType == "FLYOUT" then
				name, description, slots = GetFlyoutInfo(spellID)
				for i=1, slots, 1 do
					local _,_,_,flyoutName = GetFlyoutSlotInfo(spellID, i)
					if flyoutName and flyoutName:lower():match(searchText:lower()) then
						table.insert(spells, v)
					end
				end
			end

			if fullSpellName and fullSpellName:lower():match(searchText:lower()) then
				table.insert(spells, v)
			end
		end
		spellbook.tabs[SpellBookFrame.selectedSkillLine].numSlots = #spells
		spellbook.spells = spells
	end


	local function GetMappedSlot(slot)
		for mapped, orig in pairs(spellbook.spells) do
			if orig == slot then
				return mapped
			end
		end
	end
	--override
	function SpellBook_GetSpellBookSlot(spellButton)
		local id = spellButton:GetID()
		if ( SpellBookFrame.bookType == BOOKTYPE_PROFESSION) then
			return id + spellButton:GetParent().spellOffset;
		elseif ( SpellBookFrame.bookType == BOOKTYPE_PET ) then
			local slot = id + (SPELLS_PER_PAGE * (SPELLBOOK_PAGENUMBERS[BOOKTYPE_PET] - 1));
			local slotType, slotID = GetSpellBookItemInfo(slot, SpellBookFrame.bookType);
			return slot, slotType, slotID;
		else
			local relativeSlot = id + ( SPELLS_PER_PAGE * (SPELLBOOK_PAGENUMBERS[SpellBookFrame.selectedSkillLine] - 1));
			if ( SpellBookFrame.selectedSkillLineNumSlots and relativeSlot <= SpellBookFrame.selectedSkillLineNumSlots) then
				local slot = SpellBookFrame.selectedSkillLineOffset + relativeSlot;
				slot = spellbook.spells[slot] or slot
				local slotType, slotID = GetSpellBookItemInfo(slot, SpellBookFrame.bookType);
				return slot, slotType, slotID;
			else
				return nil, nil;
			end
		end
	end

	local function HideSpell(index)
		local tab
		local _ , spellID = GetSpellBookItemInfo(spellbook.spells[index], 'BOOKTYPE_SPELL')

		if spellbook.hidden_spells[spellID] then
			spellbook.hidden_spells[spellID] = nil
			return
		end

		for i = 1, #spellbook.tabs do
			if (spellbook.tabs[i].offset + spellbook.tabs[i].numSlots >= index) and (index > spellbook.tabs[i].offset)  then
				tab = i
			end
		end

		table.remove(spellbook.spells, index)

		for i = tab+1, #spellbook.tabs do
			spellbook.tabs[i].offset = spellbook.tabs[i].offset - 1
		end

		spellbook.tabs[tab].numSlots = spellbook.tabs[tab].numSlots - 1

		table.insert(spellbook.hidden_spells, spellID, true)
		table.remove(spellbook.swapped_spells, spellID)
	end

	local function MoveSpell(startPos, endTab)
		local startTab
		local _ , spellID = GetSpellBookItemInfo(spellbook.spells[startPos], 'BOOKTYPE_SPELL')

		for i = 1, #spellbook.tabs do
			if (spellbook.tabs[i].offset + spellbook.tabs[i].numSlots >= startPos) and (startPos > spellbook.tabs[i].offset)  then
				startTab = i
			end
		end

		if not startTab then
			return
		end

		local spell = table.remove(spellbook.spells, startPos)

		for i = startTab+1, #spellbook.tabs do
			spellbook.tabs[i].offset = spellbook.tabs[i].offset - 1
		end

		spellbook.tabs[startTab].numSlots = spellbook.tabs[startTab].numSlots - 1

		local endPos = (spellbook.tabs[endTab].offset) + 1

		if IsPassiveSpell(spellID) then
			endPos = spellbook.tabs[endTab].offset + spellbook.tabs[endTab].numSlots + 1
		end

		table.insert(spellbook.spells, endPos, spell)

		for i = endTab+1, #spellbook.tabs do
			spellbook.tabs[i].offset = spellbook.tabs[i].offset + 1
		end

		spellbook.tabs[endTab].numSlots = spellbook.tabs[endTab].numSlots + 1

		-- needs to be ID and tab cuz slots and tabs can change when you learn new spells or swap specs
		table.insert(spellbook.swapped_spells, spellID, endTab)
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
	local function quickNestedMenu(level, menuList, ...)
		local menu = quickIndentedButton(level, ...)
		menu.hasArrow = true
		menu.menuList = menuList
		return menu
	end
	-- Note that this frame must be named for the dropdowns to work.
	local menuFrame = CreateFrame("Frame", "ExampleMenuFrame", UIParent, "UIDropDownMenuTemplate")

	local unlearnButton = quickButton("Unlearn", function() cmd(("unlearn %s"):format(menuFrame._spellID)) end)
	local learnButton = quickButton("Learn", function() cmd(("learn %s"):format(menuFrame._spellID)) end)

	local blizzCastButton = quickIndentedButton(1, 'Retail', function() C_Epsilon.RunPrivileged("CastSpell(" .. menuFrame._slotID .. ", 'spell')"); end, "Standard Casting of the Spell",
		"This is how spells normally cast in WoW. AoE spell cast this way can be placed with your cursor.")
	local emptyButton = {}

	local nestedMenu = {}

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
		quickTitle("Management ..."),
		quickNestedMenu(1,nestedMenu, 'Move to...', function() end ),
		quickIndentedButton(1, 'Hide', function() HideSpell(GetMappedSlot(menuFrame._slotID)); CloseDropDownMenus(); SpellBookFrame_Update();  end),
		genSeparator(),
		--18
		unlearnButton,
	}

	local function spellContext(spellInfo, slot)
		local known = IsSpellKnown(spellInfo.spellID)

		if known then
			menu[4] = blizzCastButton
			menu[18] = unlearnButton
		else
			menu[4] = emptyButton
			menu[18] = learnButton
		end

		if spellbook.hidden_spells[spellInfo.spellID] then
			menu[16].text = 'Show'
		end

		menu[1].text = spellInfo.name and (CreateTextureMarkup(spellInfo.iconID, 24, 24, 24, 24, 0, 1, 0, 1) .. " " .. spellInfo.name) or "(Error Loading Spell Name)"
		menuFrame._spellID = spellInfo.spellID
		menuFrame._slotID = slot

		for i = 1, GetNumSpellTabs() do
			local name = GetSpellTabInfo(i)
			nestedMenu[i] = quickIndentedButton(0,name, function()
				local startPos = GetMappedSlot(slot)
				MoveSpell(startPos, i)
				CloseDropDownMenus()
				SpellBookFrame_Update()
			end)
		end

		EasyMenu(menu, menuFrame, "cursor", 0, 0, "MENU");
	end

	--override to hide "not on actionbar" glow
	hooksecurefunc('SpellButton_UpdateButton', function(self)
		self.SpellHighlightTexture:Hide();
	end)

	--override
	function SpellButton_OnClick(self, button)
		local slot, slotType = SpellBook_GetSpellBookSlot(self);
		local spellType, spell_ID = GetSpellBookItemInfo(slot, SpellBookFrame.bookType);
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
		if button == "RightButton" and spellType ~= "FLYOUT" then
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
					local spellType, id = GetSpellBookItemInfo(slot, SpellBookFrame.bookType)
					if IsSpellKnown(id) then
						C_Epsilon.RunPrivileged("CastSpell(" .. slot .. ", '" .. SpellBookFrame.bookType .. "')");
					else
						SendChatMessage(".cast " .. id)
					end
				end
			end
			SpellButton_UpdateSelection(self);
		end
	end

	--override
	local _origSpellTab = GetSpellTabInfo

	function GetSpellTabInfo(index)
		local name, texture, offset, numSlots, isGuild, offspecID = _origSpellTab(index)
		if spellbook.tabs[index] then
			offset = spellbook.tabs[index].offset or offset
			numSlots = spellbook.tabs[index].numSlots or numSlots
			texture = spellbook.tabs[index].icon or texture
			name = spellbook.tabs[index].name or name
		end
		return name, texture, offset, numSlots, isGuild, 0
	end

	local function SetupSpellTabRightClick()
		local spellbookDropdown = CreateFrame("Frame", nil, UIParent, "UIDropDownMenuTemplate")

		UIDropDownMenu_Initialize(spellbookDropdown, function(self)
			local info = UIDropDownMenu_CreateInfo()

			info.text = "Change Icon"
			info.notCheckable = true
			info.func = function() EpsilonLibIconPicker_Open(function(texture)
				spellbook.tabs[spellbookDropdown.index].icon = texture
				_G["SpellBookSkillLineTab" .. spellbookDropdown.index]:SetNormalTexture(texture)
			end, true, true) end
			UIDropDownMenu_AddButton(info)

			info.text = "Rename"
			info.notCheckable = true
			info.func = function()
				local dialog = StaticPopup_Show("EPSILONLIB_RENAMESPELLBOOKTAB")
				dialog.data = self.index
			end
			UIDropDownMenu_AddButton(info)
		end, "MENU")

		for i = 1,8,1 do
			-- OnClick already bound, so MouseDown instead
			_G["SpellBookSkillLineTab" .. i]:SetScript("OnMouseDown", function(self, button)
				if button == "RightButton" then
					spellbookDropdown.index = i
					ToggleDropDownMenu(1, nil, spellbookDropdown, "cursor", 3, -3)
				end
			end)
		end
	end

	local function SetupSpellTabs()
		local numSpellTabs = GetNumSpellTabs()
		local totalSpells = 0
		local swapped_spells = {}
		spellbook.spells = {}
		for i = 1,numSpellTabs do
			local name, texture, offset, numSlots, isGuild, offspecID = _origSpellTab(i)
			local numSpells = 0
			spellbook.tabs[i] = spellbook.tabs[i] or {}
			spellbook.tabs[i].offset = totalSpells
			for j = offset+1, (offset+numSlots)-1 do
				local spellType, id = GetSpellBookItemInfo(j, "BOOKTYPE_SPELL")
				if (not options.hideFutureSpells or (options.hideFutureSpells and spellType ~= "FUTURESPELL")) and (not spellbook.hidden_spells[id] or options.showHiddenSpells) then
					numSpells = numSpells + 1
					totalSpells = totalSpells + 1
					spellbook.spells[totalSpells] = j
				end
			end
			spellbook.tabs[i].numSlots = numSpells
		end

		for spellID, tab in pairs(spellbook.swapped_spells) do
			for  k,v in pairs(spellbook.spells) do
				local spellType, id = GetSpellBookItemInfo(v, "BOOKTYPE_SPELL")
				if spellID == id then
					MoveSpell(k, tab)
				end
			end
		end
	end

	--override
	function SpellBookFrame_Update()
		SetupSpellTabs()
		Addon:updateSearchBox()
		Addon:findSpells()
		OldSpellBookFrame_Update()
	end

	EpsiLib.EventManager:Register("FIRST_FRAME_RENDERED", function(_, event, addon)
		SetupSpellTabs()
		SetupSpellTabRightClick()
	end)
end
