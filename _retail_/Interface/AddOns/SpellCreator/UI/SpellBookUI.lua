---@class ns
local ns = select(2, ...)

local SKILL_LINE_TAB = MAX_SKILLLINE_TABS - 1
local SPELL_BOOK_TAB = 5
local MaxSpellBookTypes = 5

local Constants = ns.Constants
local Cooldowns = ns.Actions.Cooldowns
local Execute = ns.Actions.Execute
local Gossip = ns.Gossip
local Hotkeys = ns.Actions.Hotkeys
local Logging = ns.Logging
local Permissions = ns.Permissions
local UIHelpers = ns.Utils.UIHelpers
local Vault = ns.Vault

local DataUtils = ns.Utils.Data
local Tooltip = ns.Utils.Tooltip

local ChatLink = ns.UI.ChatLink
local Dropdown = ns.UI.Dropdown
local LoadSpellFrame = ns.UI.LoadSpellFrame
local Icons = ns.UI.Icons
local Popups = ns.UI.Popups

local ADDON_COLORS = Constants.ADDON_COLORS
local ASSETS_PATH = Constants.ASSETS_PATH
local VAULT_TYPE = Constants.VAULT_TYPE

local TAB_TEXTURE = ns.UI.Gems.gemPath("Violet")
local LEFT_BG_TEXTURE = GetFileIDFromPath("Interface\\Spellbook\\Spellbook-Page-1")
local RIGHT_BG_TEXTURE = GetFileIDFromPath("Interface\\Spellbook\\Spellbook-Page-2")
local FULL_BG_TEXTURE = UIHelpers.getAddonAssetFilePath("spellbook-page-arcanum")

-- Create the main frame we will show ontop of the Spell Book, made to look like another spellbook page
local mainFrame = CreateFrame("FRAME", "Arcanum_SpellBook", SpellBookFrame)
mainFrame:SetPoint("TOPLEFT", SpellBookFrame, "TOPLEFT", 0, 0)
mainFrame:SetPoint("BOTTOMRIGHT", SpellBookFrame, "BOTTOMRIGHT", 0, 0)
mainFrame:SetFrameStrata("MEDIUM")
mainFrame:SetFrameLevel(200)
--mainFrame:EnableMouse(true)
mainFrame:Hide()

-- create the texture for the background
local background = mainFrame:CreateTexture(nil, "ARTWORK")
background:SetTexture(FULL_BG_TEXTURE)
background:SetPoint("TOPLEFT", 7, -25)
background:SetPoint("TOPRIGHT", -10, -25)

-- create the holder frame of our spell icons & page data
local spellIconsFrame = CreateFrame("Frame", nil, mainFrame)
mainFrame.iconsFrame = spellIconsFrame
spellIconsFrame:SetAllPoints(mainFrame)
--spellIconsFrame:EnableMouse(true)

spellIconsFrame.maxPages = 1
spellIconsFrame.currentPage = 1

local prevButton = CreateFrame("Button", nil, mainFrame)
prevButton:SetSize(32, 32)
prevButton:SetPoint("BOTTOMRIGHT", -66, 26)
prevButton:SetNormalTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Up")
prevButton:SetPushedTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Down")
prevButton:SetDisabledTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Disabled")
prevButton:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight", "ADD")
--OnClick set later

local nextButton = CreateFrame("Button", nil, mainFrame)
nextButton:SetSize(32, 32)
nextButton:SetPoint("BOTTOMRIGHT", -31, 26)
nextButton:SetNormalTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Up")
nextButton:SetPushedTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Down")
nextButton:SetDisabledTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Disabled")
nextButton:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight", "ADD")
--OnClick set later

local pageText = mainFrame:CreateFontString(nil, "OVERLAY", "GameFontBlack")
pageText:SetJustifyH("RIGHT")
pageText:SetSize(102, 0)
pageText:SetPoint("BOTTOMRIGHT", -110, 38)
pageText:SetTextColor(ADDON_COLORS.LIGHT_BLUE_ALMOST_WHITE:GetRGB())
pageText:SetText("Page 1")

local buttonSize = 32
local openForgeButton = CreateFrame("Button", nil, mainFrame)
openForgeButton:SetSize(buttonSize, buttonSize * 2)
openForgeButton:SetPoint("BOTTOMLEFT", 27, 30)
openForgeButton:SetScript("OnClick", function()
	ns.MainFuncs.scforge_showhide()
end)

openForgeButton.iconArea = CreateFrame("Frame", nil, openForgeButton)
openForgeButton.iconArea:SetFrameLevel(openForgeButton:GetFrameLevel() - 1)
openForgeButton.iconArea:SetPoint("TOPLEFT")
openForgeButton.iconArea:SetSize(buttonSize, buttonSize)
openForgeButton.iconArea.icon = openForgeButton.iconArea:CreateTexture(nil, "OVERLAY", nil, -1)
openForgeButton.iconArea.icon:SetAllPoints()
ns.UI.Portrait.createGemPortraitOnFrame(openForgeButton.iconArea.icon, openForgeButton.iconArea)
local runeX, runeY = openForgeButton.iconArea.icon.rune:GetSize()
openForgeButton.iconArea.icon.rune:SetSize((runeX / 61) * buttonSize, (runeY / 61) * buttonSize) -- fix rune scaling since it's setup only for the size of a real portrait hah

openForgeButton.iconArea:EnableMouse(false)
openForgeButton.iconArea.icon.Model:EnableMouse(false)

UIHelpers.setupCoherentButtonTextures(openForgeButton, UIHelpers.getAddonAssetFilePath("icon_portrait_gold_ring_border"), false)
openForgeButton.normal = openForgeButton:GetNormalTexture()
openForgeButton.pushed = openForgeButton:GetPushedTexture()
openForgeButton.normal:SetAllPoints(openForgeButton.iconArea)
openForgeButton.pushed:SetAllPoints(openForgeButton.iconArea)

openForgeButton:SetHighlightAtlas("Artifacts-PerkRing-Highlight")
openForgeButton.highlight = openForgeButton:GetHighlightTexture()
openForgeButton.highlight:SetAllPoints(openForgeButton.iconArea)

openForgeButton.Text = openForgeButton:CreateFontString(nil, "OVERLAY", "GameFontNormal")
openForgeButton:SetFontString(openForgeButton.Text)
openForgeButton.Text:SetPoint("TOP", openForgeButton.iconArea, "BOTTOM", 0, -2)
openForgeButton.Text:SetTextColor(ADDON_COLORS.LIGHT_BLUE_ALMOST_WHITE:GetRGB())
openForgeButton:SetText("Open\nForge")
openForgeButton:SetPushedTextOffset(0, 0) -- looks weird when the text spasms

mainFrame.OpenForgeButton = openForgeButton

local mainFrameMouseBlocker = CreateFrame("FRAME", nil, mainFrame)
mainFrame.mouseBlocker = mainFrameMouseBlocker
mainFrameMouseBlocker:SetPoint("TOPLEFT", 7, -25)
mainFrameMouseBlocker:SetPoint("BOTTOMRIGHT", -10, 5)
mainFrameMouseBlocker:EnableMouse(true)


local searchbox = CreateFrame("EditBox", nil, mainFrame, "SearchBoxTemplate")
mainFrame.searchbar = searchbox -- Arcanum_SpellBook.searchbar
searchbox:SetPoint("TOP", mainFrame, "TOP", 30, -30)
searchbox:SetSize(480, 12)
searchbox:SetFrameStrata("HIGH")

local offAlpha = 0.2
local onAlpha = 0.5
searchbox.Left:SetAlpha(offAlpha)
searchbox.Right:SetAlpha(offAlpha)
searchbox.Middle:SetAlpha(offAlpha)

searchbox:HookScript("OnEditFocusLost", function(self)
	searchbox.Left:SetAlpha(offAlpha)
	searchbox.Right:SetAlpha(offAlpha)
	searchbox.Middle:SetAlpha(offAlpha)
end)
searchbox:HookScript("OnEditFocusGained", function(self)
	searchbox.Left:SetAlpha(onAlpha)
	searchbox.Right:SetAlpha(onAlpha)
	searchbox.Middle:SetAlpha(onAlpha)
end)

function searchbox:GetFilter()
	local text = self:GetText()
	return (text and #text > 2) and text or nil
end

Tooltip.set(searchbox,
	"Search Arcanum Spells",
	"You can search multiple key-words by separating them with a comma! Searches must be three characters or more.",
	{
		forced = true,
		delay = 0,
	}
)

-- holding table for our buttons to easier iterate them
local arcSpellFrameButtons = {}
local lastOddButton -- easier memory of the last odd button for positioning

-- default mixin for easier creation of buttons that all do the same stuff
local spellButtonMixin = {}
spellButtonMixin.OnEnter = function() end
spellButtonMixin.OnLeave = function() end
spellButtonMixin.OnEvent = function() end
spellButtonMixin.PreClick = function(self)
	self:SetChecked(false)
end
spellButtonMixin.OnClick = function(self, button)
	if not self.commID then
		SCForgeMainFrame:Show()
		local resetUI = ns.MainFuncs.resetEditorUI
		if not ns.UI.Popups.checkAndShowResetForgeConfirmation("reset", resetUI, SCForgeMainFrame.ResetUIButton) then
			resetUI(SCForgeMainFrame.ResetUIButton)
		end
		return
	end

	local spell = Vault.personal.findSpellByID(self.commID)
	if not spell then return Logging.eprint("OnClick - No spell found with ArcSpell ID in personal vault: ", self.commID) end

	if button == "LeftButton" then
		if IsModifiedClick("CHATLINK") then
			ChatLink.linkSpell(spell, VAULT_TYPE.PERSONAL)
			return;
		end
		ARC:CAST(self.commID)
	elseif button == "RightButton" then
		ns.UI.SpellLoadRowContextMenu.showSB(self, self.commID)
	end
end
spellButtonMixin.OnDragStart = function() end
spellButtonMixin.OnDragStop = function() end
spellButtonMixin.OnReceiveDrag = function() end
spellButtonMixin.UpdateCooldown = function(self)
	local cooldown = self.cooldown;
	local commID = self.commID

	local remainingTime, cooldownTime = Cooldowns.isSpellOnCooldown(commID)
	if remainingTime then
		cooldown:SetCooldown(GetTime() - (cooldownTime - remainingTime), cooldownTime)
	else
		cooldown:Clear()
	end
end
spellButtonMixin.UpdateButton = function(self)
	local iconTexture = _G[self:GetName() .. "IconTexture"]
	local slotFrameTexture = _G[self:GetName() .. "SlotFrame"]

	if self.commID then
		local spell = Vault.personal.findSpellByID(self.commID)
		if not spell then
			Logging.eprint("UpdateButton - No spell found with ArcSpell ID in personal vault: ", self.commID)
			return
		end

		--icon
		iconTexture:SetTexture(Icons.getFinalIcon(spell.icon))
		iconTexture:Show()
		slotFrameTexture:Show()

		self.SpellName:SetText(spell.fullName); self.SpellName:Show()
		self.SpellSubName:SetText(spell.commID); self.SpellSubName:Show()
		self:Enable()
		self:UpdateCooldown()
	else
		if self.id == 1 or arcSpellFrameButtons[self.id - 1].commID then
			-- no spell, but first ID, or the button before this has a spell - let's show a fun "Create Spell" button here instead!
			self:Enable()
			slotFrameTexture:Show()
			iconTexture:Show()
			iconTexture:SetAtlas("communities-chat-icon-plus")
			self.SpellName:Show()
			self.SpellName:SetText("Create New Spell")
			self.SpellSubName:SetText()
			self.SpellSubName:Hide()
		else
			self:Disable()
			slotFrameTexture:Hide()
			iconTexture:Hide()
			self.SpellSubName:Hide()
			self.SpellName:Hide()
		end
	end
end

-- create the spell buttons!
for i = 1, SPELLS_PER_PAGE do
	local spellButton = CreateFrame("CheckButton", "Arcanum_SpellBook_SpellButton" .. i, spellIconsFrame, "ArcanumSpellButtonTemplate")
	spellButton.id = i
	if i == 1 then
		spellButton:SetPoint("TOPLEFT", 100, -72)
		spellButton.commID = "drunk"
		lastOddButton = spellButton
	elseif (i % 2 == 0) then
		-- number is even
		spellButton:SetPoint("TOPLEFT", lastOddButton, "TOPLEFT", 225, 0)
	else
		-- number is odd
		spellButton:SetPoint("TOPLEFT", lastOddButton, "BOTTOMLEFT", 0, -29)
		lastOddButton = spellButton
	end
	if i == SPELLS_PER_PAGE then
		-- last button, trash our variable
		lastOddButton = nil
	end

	spellButton.TextBackground:SetPoint("TOPLEFT", spellButton.EmptySlot, "TOPRIGHT", -4, -5)
	spellButton.TextBackground2:SetPoint("TOPLEFT", spellButton.EmptySlot, "TOPRIGHT", -4, -5)

	local remapTextures = {
		"EmptySlot", "TextBackground", "TextBackground2", "UnlearnedFrame", "TrainFrame", "TrainTextBackground"
	}
	for k, v in ipairs(remapTextures) do
		spellButton[v]:SetTexture(UIHelpers.getAddonAssetFilePath("spellbook-parts-arcanum"))
	end

	local remapByNameTextures = {
		"SlotFrame",
	}
	for k, v in ipairs(remapByNameTextures) do
		_G[spellButton:GetName() .. v]:SetTexture(UIHelpers.getAddonAssetFilePath("spellbook-parts-arcanum"))
	end

	spellButton.SpellName:SetPoint("LEFT", spellButton, "RIGHT", 8, 3); -- Blizzard moves theres from the default of y-offset 0 to 4 for some reason. I can't decide which looks better.
	spellButton.SpellSubName:SetTextColor(ADDON_COLORS.LIGHT_BLUE_ALMOST_WHITE:GetRGB())
	spellButton.TextBackground:SetAlpha(0.75)
	spellButton.TextBackground2:SetAlpha(0.0)

	Mixin(spellButton, spellButtonMixin)
	for k, v in pairs(spellButtonMixin) do
		if spellButton:HasScript(k) then
			spellButton:SetScript(k, spellButton[k])
		end
	end
	spellButton:RegisterForClicks("LeftButtonUp", "RightButtonUp")

	local getSpell = Vault.personal.findSpellByID
	ns.Utils.Tooltip.set(
		spellButton,
		function(self)
			--return getSpell(self.commID).fullName
			return ns.UI.SpellTooltip.getTitle("vault", getSpell(self.commID))
		end,
		function(self)
			local spell = getSpell(self.commID)
			--local strings = genSpellTooltipLines(spell, true)
			local strings = ns.UI.SpellTooltip.getLines("vault", spell, false, true)
			tinsert(strings, " ")
			tinsert(strings, Tooltip.genContrastText("Shift-Click") .. Tooltip.tag("left-click") .. " to link in chat.")
			tinsert(strings, Tooltip.genContrastText("Right-Click") .. Tooltip.tag("right-click") .. " for more options.")
			return strings
		end,
		{
			-- we expect a tooltip on the spell even if tooltips are disabled
			forced = true,
			delay = 0,
			predicate = function(self) return self.commID end, -- make sure we have a commID to use lol
		}
	)

	ns.UI.ActionButton.makeButtonDraggableToActionBar(spellButton, spellButton.Icon)
	spellButton.contextMenu = ns.UI.SpellLoadRowContextMenu.createFor(spellButton, "SB" .. i)

	tinsert(arcSpellFrameButtons, spellButton)
end

local function filterSpells(spells, filter)
	if (not filter) or (#filter < 3) then
		return spells
	end

	local filteredList = {}
	local filterKeys = { strsplit(",", filter:lower()) }

	for _, commID in ipairs(spells) do
		local spell = Vault.personal.findSpellByID(commID)
		local commIDLower = spell.commID:lower()
		local nameLower = spell.fullName:lower()
		local descLower = spell.description and spell.description:lower()

		local match = true
		for _, v in ipairs(filterKeys) do
			v = strtrim(v)
			if not (commIDLower:find(v) or nameLower:find(v) or (descLower and descLower:find(v))) then
				match = false
				break
			end
		end

		if match then
			tinsert(filteredList, commID)
		end
	end

	return filteredList
end

local function updateButtons()
	for k, v in ipairs(arcSpellFrameButtons) do
		local spellIDs = filterSpells(ns.Vault.personal.getIDs(), searchbox:GetFilter())
		table.sort(spellIDs, DataUtils.caseInsensitiveCompare)

		local pageOffset = (12 * (spellIconsFrame.currentPage - 1))
		local commID = spellIDs[k + pageOffset]
		v.commID = commID
		v:UpdateButton()
	end
end

local function updatePage()
	local spellIDs = filterSpells(ns.Vault.personal.getIDs(), searchbox:GetFilter())
	local numSpells = #spellIDs + 1 -- // + 1 so we always get a "create new spell" button even if it's a final full page
	spellIconsFrame.maxPages = ceil(numSpells / SPELLS_PER_PAGE)

	do
		local maxPages = spellIconsFrame.maxPages
		local currentPage = spellIconsFrame.currentPage

		if (maxPages == nil or maxPages == 0) then
			return;
		end
		if (currentPage > maxPages) then
			currentPage = maxPages;
		end
		if (currentPage == 1) then
			prevButton:Disable();
		else
			prevButton:Enable();
		end
		if (currentPage == maxPages) then
			nextButton:Disable();
		else
			nextButton:Enable();
		end
		pageText:SetText("Page " .. currentPage .. " / " .. maxPages);
	end

	updateButtons()
end

local timer = C_Timer.NewTimer(0, function() end)

searchbox:HookScript("OnTextChanged", function(self)
	timer:Cancel()
	timer = C_Timer.NewTimer(0.25, function(self)
		updatePage()
	end)
end)

searchbox:HookScript("OnEditFocusLost", function(self)
	updatePage()
end)
searchbox.clearButton:HookScript("OnClick", function(self)
	updatePage()
end)



local function prevButtonOnClick(self)
	spellIconsFrame.currentPage = spellIconsFrame.currentPage - 1
	updatePage()
end
local function nextButtonOnClick(self)
	spellIconsFrame.currentPage = spellIconsFrame.currentPage + 1
	updatePage()
end
prevButton:SetScript("OnClick", prevButtonOnClick)
nextButton:SetScript("OnClick", nextButtonOnClick)

local function OnMouseWheel(self, value, scrollBar)
	--do nothing if not on an appropriate book type
	local currentPage = spellIconsFrame.currentPage
	local maxPages = spellIconsFrame.maxPages

	if (value > 0) then
		if (currentPage > 1) then
			prevButtonOnClick()
		end
	else
		if (currentPage < maxPages) then
			nextButtonOnClick()
		end
	end
end
mainFrame:SetScript("OnMouseWheel", OnMouseWheel)

mainFrame:SetScript("OnShow", function()
	SpellBookFrame.TitleText:SetText("Arcanum Spellbook")
	updatePage()
end)

--[[
local skillLineTab = _G["SpellBookSkillLineTab" .. SKILL_LINE_TAB]
hooksecurefunc("SpellBookFrame_UpdateSkillLineTabs", function()
	skillLineTab:SetNormalTexture(TAB_TEXTURE)
	skillLineTab.tooltip = "Arcanum Spell Vault"
	skillLineTab:Show()
	if (SpellBookFrame.selectedSkillLine == SKILL_LINE_TAB) then
		skillLineTab:SetChecked(true)
		mainFrame:Show()
	else
		skillLineTab:SetChecked(false)
		mainFrame:Hide()
	end
end)
--]]



local customTabButton = CreateFrame("Button", "Arcanum_SpellBook_TabButton", SpellBookFrame, "SpellBookFrameTabButtonTemplate")
customTabButton:SetPoint("TOPRIGHT", SpellBookFrame, "BOTTOMRIGHT", 0, 2)
customTabButton:Show()
customTabButton:SetText(ns.Utils.UIHelpers.CreateSimpleTextureMarkup(TAB_TEXTURE, 20) .. " Arcanum")

local function showArcSpellBook()
	if not SpellBookFrame:IsShown() then
		ShowUIPanel(SpellBookFrame);
	end

	do
		SpellBookFrame.bookType = BOOKTYPE_PROFESSION
		SpellBookFrame_Update()
		SpellBookFrame.bookType = "arcanum"
	end

	mainFrame:Show()
	PanelTemplates_TabResize(customTabButton, 0, nil, 40);
	if mainFrame:IsShown() then
		PanelTemplates_SelectTab(customTabButton)
		SpellBookFrame.currentTab = customTabButton

		for i = 1, MaxSpellBookTypes do
			local tab = _G["SpellBookFrameTabButton" .. i];
			PanelTemplates_TabResize(tab, 0, nil, 40);
			PanelTemplates_DeselectTab(tab);
		end
	else
		PanelTemplates_DeselectTab(customTabButton)
	end
end

customTabButton:SetScript("OnEnter", function(self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip:SetText("Arcanum Spellbook", 1.0, 1.0, 1.0);
end)
customTabButton:SetScript("OnClick", function(self)
	self:Disable();
	if SpellBookFrame.currentTab then
		SpellBookFrame.currentTab:Enable();
	end
	SpellBookFrame.currentTab = self;
	showArcSpellBook()
end)

hooksecurefunc("SpellBookFrame_Update", function()
	mainFrame:Hide()
	PanelTemplates_DeselectTab(customTabButton);
	--[[
	PanelTemplates_TabResize(customTabButton, 0, nil, 40);
	if mainFrame:IsShown() then
		PanelTemplates_SelectTab(customTabButton)
		SpellBookFrame.currentTab = customTabButton

		for i = 1, MaxSpellBookTypes do
			local tab = _G["SpellBookFrameTabButton" .. i];
			PanelTemplates_TabResize(tab, 0, nil, 40);
			PanelTemplates_DeselectTab(tab);
		end
	else
		PanelTemplates_DeselectTab(customTabButton)
	end
	--]]
end)

local function updateArcSpellBook()
	if mainFrame:IsShown() then
		updatePage()
	end
end

local helpPlate = {
	FramePos = { x = 5, y = -22 },
	FrameSize = { width = 580, height = 500 },
	[1] = { ButtonPos = { x = 250, y = -50 }, HighLightBox = { x = 65, y = -25, width = 460, height = 410 }, ToolTipDir = "DOWN", ToolTipText = "Spells in your Personal Vault are shown here. You can drag them to your action bars, or left-click to cast, or right-click to edit the spell!" },
	[2] = { ButtonPos = { x = 330, y = -435 }, HighLightBox = { x = 360, y = -440, width = 160, height = 40 }, ToolTipDir = "LEFT", ToolTipText = "Vault getting too big for one page? You can also use your scroll-wheel anywhere in the Spellbook to quick flip through pages!" },
	[3] = { ButtonPos = { x = 7, y = -375 }, HighLightBox = { x = 13, y = -400, width = 50, height = 80 }, ToolTipDir = "RIGHT", ToolTipText = "Open the Spell Forge to create new Arcanum Spells!" },

}
hooksecurefunc("SpellBook_ToggleTutorial", function()
	if not mainFrame:IsShown() then return end
	if HelpPlate_IsShowing(helpPlate) then
		HelpPlate_Hide(true)
	else
		HelpPlate_Show(helpPlate, mainFrame, SpellBookFrame.MainHelpButton)
	end
end)

---@class UI_SpellBookUI
ns.UI.SpellBookUI = {
	updateArcSpellBook = updateArcSpellBook,
	updateButtons = updateButtons,

	open = showArcSpellBook,
}
