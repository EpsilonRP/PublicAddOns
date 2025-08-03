-------------------------------------------------------------------------------
-- Epsilon (C) 2025
-------------------------------------------------------------------------------

--
-- Aura list interface.
--
local addonName = ...
local addonPath = "Interface/AddOns/" .. tostring(addonName)
local assetsPath = addonPath .. "/Texture/"
-- TUTORIAL STRINGS

local ROLL_TRACKER_TUTORIAL = {
	"Select a list to edit:|n|n|cFFFFD100Personal|r edits apply only to auras affecting (or spells cast by) your character. Other players will see these edits too.|n|n|cFFFFD100Phase|r edits apply to every player character and NPC in your phase. (Requires Officer Permissions)",
	"Auras and Spells are listed here. You can sort the list using the column headers, and edit or delete existing items using the icons on the right.",
	"Click 'New...' to edit a new spell or aura.",
}

function EpsilonAuraManagerFrame_OnLoad(self)
	self:SetClampedToScreen(true);
	self:SetMovable(true);
	self:EnableMouse(true);
	self:RegisterForDrag("LeftButton");
	self:SetScript("OnDragStart", self.StartMoving);
	self:SetScript("OnDragStop", self.StopMovingOrSizing);
	self:SetUserPlaced(true);

	local icon = assetsPath .. "EpsilonAuraIcon.blp"
	self.portrait:SetTexture(icon)
	self.TitleText:SetText("Aura Manager")

	self.TitleBgColor = self:CreateTexture(nil, "BACKGROUND")
	self.TitleBgColor:SetPoint("TOPLEFT", self.TitleBg)
	self.TitleBgColor:SetPoint("BOTTOMRIGHT", self.TitleBg)
	self.TitleBgColor:SetColorTexture(2 / 255, 102 / 255, 148 / 255, 0.5)

	NineSliceUtil.ApplyLayoutByName(self.NineSlice, "EpsilonGoldBorderFrameTemplate")


	for i = 2, 17 do
		local button = CreateFrame("Button", "EpsilonAuraManagerFrameButton" .. i, EpsilonAuraManagerFrame, "EpsilonAuraManagerButtonTemplate");
		button:SetID(i)
		button:SetPoint("TOP", _G["EpsilonAuraManagerFrameButton" .. (i - 1)], "BOTTOM");
	end
end

function EpsilonAuraManagerButton_OnClick(self, button)
	if (button == "LeftButton") then
		if EpsilonAuraManagerFrame.selected == self.index then
			EpsilonAuraManagerFrame.selected = nil
		else
			EpsilonAuraManagerFrame.selected = self.index
		end
		EpsilonAuraManagerFrame_Update()
	end
end

local originalSpellTooltip = CreateFrame("GameTooltip", "Epsilon_AuraManager_OrigSpellTooltip", GameTooltip, "SharedTooltipTemplate")

function EpsilonAuraManagerButton_OnEnter(self)
	if (self.guid) then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip:SetSpellByID(self.guid);
		GameTooltip:Show();

		originalSpellTooltip:SetOwner(GameTooltip, "ANCHOR_NONE");
		originalSpellTooltip:SetPoint("TOPLEFT", GameTooltip, "BOTTOMLEFT", 0, 0);
		originalSpellTooltip:SetSpellByID(self.guid);
		originalSpellTooltip:AddLine("(Original Spell)", 0.66, 0.66, 0.66);
		originalSpellTooltip:Show();

		SetSpellTooltip(self.guid)
	end
end

function EpsilonAuraManagerButton_OnLeave(self)
	GameTooltip:Hide();
	originalSpellTooltip:Hide();
end

function EpsilonAuraManagerButton_Edit(self, button)
	if (button == "LeftButton") then
		EpsilonAuraManagerFrame.selected = self.index
		EpsilonAuraManagerFrame_Update()
		EpsilonAuraManagerAuraEditor_Open()
	end
end

function EpsilonAuraManager_Sort(self, reversed, sortKey, sortType)
	local sort_func = function(a, b)
		if not a then
			a = 0
		end
		if not b then
			b = 0
		end
		if sortType == "numeric" then
			return tonumber(a[sortKey]) < tonumber(b[sortKey])
		else
			return tostring(a[sortKey]) < tostring(b[sortKey])
		end
	end
	if not reversed then
		self.reversed = true
	else
		sort_func = function(a, b)
			if not a then
				a = 0
			end
			if not b then
				b = 0
			end
			if sortType == "numeric" then
				return tonumber(a[sortKey]) > tonumber(b[sortKey])
			else
				return tostring(a[sortKey]) > tostring(b[sortKey])
			end
		end
		self.reversed = false
	end
	return sort_func
end

function EpsilonAuraManagerFrame_Update(sort_func)
	local name, spellID, icon, originalName, originalIcon;
	local index;
	if sort_func then Epsilon_AuraManager_SetSortFunc(sort_func) end
	local auraList = Epsilon_AuraManager_GetAurasTable();
	if #auraList > 0 then
		EpsilonAuraManagerFrameTotals:Hide()
	else
		EpsilonAuraManagerFrameTotals:Show()
		EpsilonAuraManagerFrameTotals:SetText("No Spells or Auras Found")
	end

	local offset = FauxScrollFrame_GetOffset(EpsilonAuraManagerFrameScrollFrame);
	local frameWidth = EpsilonAuraManagerFrameInset:GetWidth();
	local width = frameWidth - 27;

	WhoFrameColumn_SetWidth(EpsilonAuraManagerColumnHeader2, width / 3 + 4);
	WhoFrameColumn_SetWidth(EpsilonAuraManagerColumnHeader3, width / 3 + 4);

	for i = 1, 17, 1 do
		index = offset + i;
		local button = _G["EpsilonAuraManagerFrameButton" .. i];
		button.index = index
		button:SetWidth(width);
		local info = auraList[index];
		if (info) then
			button.guid = info.spellID
			spellID = info.spellID;
			icon = info.icon;
			name = info.name;
			originalName, _, originalIcon = GetSpellInfo(info.spellID, nil, true)
			local buttonText = _G["EpsilonAuraManagerFrameButton" .. i .. "SpellID"];
			buttonText:SetText(spellID)
			local buttonText = _G["EpsilonAuraManagerFrameButton" .. i .. "Name"];
			buttonText:SetText("|T" .. icon .. ":16|t " .. name)
			buttonText:SetWidth(width / 3)
			local buttonText = _G["EpsilonAuraManagerFrameButton" .. i .. "Details"];
			buttonText:SetText("|T" .. originalIcon .. ":16|t " .. originalName)
			buttonText:SetWidth(width / 3)
		end

		-- Highlight the correct button
		if (EpsilonAuraManagerFrame.selected == index) then
			button:LockHighlight();
		else
			button:UnlockHighlight();
		end

		if (index > #auraList) then
			button:Hide();
		else
			button:Show();
		end
	end

	FauxScrollFrame_Update(EpsilonAuraManagerFrameScrollFrame, #auraList, 17, 16, nil, nil, nil, nil, nil, nil, true);
end

-------------------------------------------------------------------------------
-- HelpFrame Stuff
--
EpsilonAuraManagerFrameTutorialMixin = {}

function EpsilonAuraManagerFrameTutorialMixin:OnLoad()
	self.helpInfo = {
		FramePos = { x = 0, y = -20 },
		FrameSize = { width = 338, height = 364 },
	};
end

function EpsilonAuraManagerFrameTutorialMixin:OnHide()
	self:CheckAndHideHelpInfo();
end

function EpsilonAuraManagerFrameTutorialMixin:CheckAndShowTooltip()
	if not HelpPlate:IsShown() then
		HelpPlate_ShowTutorialPrompt(self.helpInfo, self);
	end
end

function EpsilonAuraManagerFrameTutorialMixin:CheckAndHideHelpInfo()
	if HelpPlate:IsShown() then
		HelpPlate_Hide();
		HelpPlate_TooltipHide();
	end
end

function EpsilonAuraManagerFrameTutorialMixin:ToggleHelpInfo()
	local rollFrame = EpsilonAuraManagerFrame;
	for i = 1, #self.helpInfo do
		self.helpInfo[i] = nil;
	end
	self.helpInfo[1] = { ButtonPos = { x = 150, y = 2 }, HighLightBox = { x = 155, y = -2, width = 174, height = 39 }, ToolTipDir = "DOWN", ToolTipText = ROLL_TRACKER_TUTORIAL[1] };
	self.helpInfo[2] = { ButtonPos = { x = 146, y = -170 }, HighLightBox = { x = 10, y = -66, width = 320, height = 270 }, ToolTipDir = "DOWN", ToolTipText = ROLL_TRACKER_TUTORIAL[2] };
	self.helpInfo[3] = { ButtonPos = { x = 146, y = -329 }, HighLightBox = { x = 10, y = -340, width = 320, height = 24 }, ToolTipDir = "UP", ToolTipText = ROLL_TRACKER_TUTORIAL[3] };

	if (not HelpPlate:IsShown() and rollFrame:IsShown()) then
		HelpPlate_Show(self.helpInfo, rollFrame, self, true);
	else
		HelpPlate_Hide(true);
	end
end
