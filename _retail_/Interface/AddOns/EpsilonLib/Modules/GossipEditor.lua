-- ============================================================
--  GossipEditor
--  In-game editor for gossip greeting text and options.
--  Only visible to DMs (C_Epsilon.IsDM == true).
-- ============================================================

local sendCommand, sendCommandChain =
	EpsilonLib.AddonCommands.Register("EpsilonLib-Gossip")

-- Raw gossip API functions
local _CloseGossip                  = CloseGossip or C_GossipInfo.CloseGossip;
local _GetGossipText                = GetGossipText or C_GossipInfo.GetText
local _GetGossipOptions             = GetGossipOptions or C_GossipInfo.GetOptions
local _GetNumGossipOptions          = GetNumGossipOptions or C_GossipInfo.GetNumOptions

local showSaveProgress              = true
local baseCommand                   = "gsp1"

-- -- Icon definitions --------------------------------------
local ICON_LIST                     = {
	{ id = 0,  label = "Gossip",       type = "Gossip" },
	{ id = 1,  label = "Vendor",       type = "Vendor" },
	{ id = 2,  label = "Taxi",         type = "Taxi" },
	{ id = 3,  label = "Trainer",      type = "Trainer" },
	{ id = 4,  label = "Healer",       type = "Healer" },
	{ id = 5,  label = "Binder",       type = "Binder" },
	{ id = 6,  label = "Banker",       type = "Banker" },
	{ id = 7,  label = "Petition",     type = "Petition" },
	{ id = 8,  label = "Tabard",       type = "Tabard" },
	{ id = 9,  label = "Battlemaster", type = "Battlemaster" },
	{ id = 10, label = "Auctioneer",   type = "auctioneer" },
	{ id = 28, label = "Work Order",   type = "WorkOrder" },
	{ id = 34, label = "Transmog",     type = "transmogrify" },
}

local iconIDMap                     = {}
local iconTypeMap                   = {}
for k, v in ipairs(ICON_LIST) do
	iconIDMap[v.id] = v
	iconTypeMap[v.type:lower()] = v
end

local function GetIconPath(iconType)
	if type(iconType) == "table" then iconType = iconType.type end
	if type(iconType) ~= "string" then return GetIconPath("gossip") end
	iconType = iconType:lower()
	if not iconTypeMap[iconType] then return iconType end
	return "Interface/GossipFrame/" .. iconTypeMap[iconType].type .. "GossipIcon"
end

local function ParseOptionText(text)
	local pageLink = nil

	-- Try to match the debug prefix (with optional page flag)
	local pageFlag, cleanText = text:match("^|cffFFFFFF%[Option %d+%->(%d+)%]|r (.+)$")

	if pageFlag then
		-- Debug prefix WITH page flag found
		pageLink = tonumber(pageFlag)
	else
		-- Try without page flag
		cleanText = text:match("^|cffFFFFFF%[Option %d+%]|r (.+)$")
	end

	-- If neither matched, return original text unchanged
	if not cleanText then
		return text, nil
	end

	return cleanText, pageLink
end

-- -- Split helpers -----------------------------------------

-- Split text into blocks of at most 255 chars, never breaking
-- on a space (to avoid leading/trailing space trimming by server).
-- If a word is longer than 255 chars it is force-split at 255.
local maxCmdLen = 255 - 5 - 1 -- while it's 255 technically, effectively it is 254. 255 causes it yell it can't be over 255; also minus 5 for the addon command ID tracking
local cmdLen = #(baseCommand .. " text overwrite ## ")
local function splitIntoBlocks(text)
	local blocks = {}
	local len    = #text
	local pos    = 1

	while pos <= len do
		local blockEnd = pos + (maxCmdLen - cmdLen) -- 0-indexed slice of 255 chars, minus the command itself + buffer

		if blockEnd >= len then
			-- Remainder fits in one block.
			blocks[#blocks + 1] = text:sub(pos, len)
			break
		end

		-- Walk backwards from blockEnd to find a non-space boundary.
		local splitAt = blockEnd
		while splitAt > pos and text:sub(splitAt, splitAt) == " " do
			splitAt = splitAt - 1
		end

		-- If the whole slice is spaces (pathological), force-split.
		if splitAt == pos then
			splitAt = blockEnd
		end

		blocks[#blocks + 1] = text:sub(pos, splitAt)

		-- Advance past the split point; skip exactly one space if
		-- the character immediately after the split is a space,
		-- since that space would be trimmed by the server anyway.
		local nextPos = splitAt + 1
		if nextPos <= len and text:sub(nextPos, nextPos) == " " then
			nextPos = nextPos + 1
		end
		pos = nextPos
	end

	return blocks
end

-- GossipEditor Mixin
GossipEditorMixin = {}

function GossipEditorMixin:OnLoad()
	self:EnableMouse(true)
	self.Bg:SetAlpha(0.7)

	local greetingScroll = self.GreetingScroll
	local editBox = greetingScroll.EditBox

	editBox:SetText("Loading...")
	editBox:SetEnabled(false)

	greetingScroll.CharCount:ClearAllPoints()
	greetingScroll.CharCount:SetPoint("BOTTOMRIGHT", greetingScroll, "TOPRIGHT", 0, 4)
	greetingScroll.CharCount:SetFontObject(GameFontDisable)
	greetingScroll.CharCount:Show()

	editBox:SetFontObject(SystemFont_Med2)
	editBox:SetScript("OnTextChanged", function(self, userInput)
		local scrollFrame = self:GetParent();
		ScrollingEdit_OnTextChanged(self, scrollFrame);
		if (self:GetText() ~= "") then
			self.Instructions:Hide();
		else
			self.Instructions:Show();
		end

		if userInput then GossipEditor:OnGreetingChanged(self) end
	end)

	-- Sync Save & Reset Button Status:
	GossipEditorFrame.Reset:HookScript("OnEnable", function()
		GossipEditorFrame.Save:SetEnabled(true)
	end)
	GossipEditorFrame.Reset:HookScript("OnDisable", function()
		GossipEditorFrame.Save:SetEnabled(false)
	end)

	-- Initially Disabled
	GossipEditorFrame.Reset:SetEnabled(false)

	-- Setup Info Buttons:
	self.greetingInfo = CreateFrame("Button", "GossipEditorGreetingInfoIcon", self, "UIPanelInfoButton")
	self.greetingInfo:SetPoint("LEFT", self.GreetingLabel, "LEFT", 100, 0)
	self.greetingInfo:SetScale(13 / 16)
	self.greetingInfo:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT", -16, -4)
		GameTooltip_SetTitle(GameTooltip, "Greeting / Page Text", NORMAL_FONT_COLOR)
		GameTooltip_AddHighlightLine(GameTooltip, "Supports a multitude of text tags:", false)
		GameTooltip_AddHighlightLine(GameTooltip, "$B = newline; $c = class; $r = race; $n = name; ", false)
		GameTooltip_AddHighlightLine(GameTooltip, "$Gx:y = gender (you choose specifics, x=male/y=female),", false)
		GameTooltip_AddHighlightLine(GameTooltip, "$p or $n = player name, %n = player's target.", false)
		GameTooltip_AddHighlightLine(GameTooltip, " ")
		GameTooltip_AddHighlightLine(GameTooltip, "Capitalized letter leads to the first letter being capitalized except for name, that leads to all caps")
		GameTooltip_AddHighlightLine(GameTooltip, "Note: Gossip Editor cannot detect text tags in use. You'll need to fix them before saving again. Sorry.")
		GameTooltip:Show();
	end)
	self.greetingInfo:SetScript("OnLeave", GameTooltip_Hide)


	self.optionInfo = CreateFrame("Button", "GossipEditorOptionsInfoIcon", self, "UIPanelInfoButton")
	self.optionInfo:SetPoint("LEFT", self.OptionsLabel, "LEFT", 100, 0)
	self.optionInfo:SetScale(13 / 16)
	self.optionInfo:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT", -16, -4)
		GameTooltip_SetTitle(GameTooltip, "Options", NORMAL_FONT_COLOR)
		GameTooltip_AddHighlightLine(GameTooltip, "Supports the same text tags as Greeting Text", false)
		GameTooltip_AddHighlightLine(GameTooltip, " ", false)
		GameTooltip_AddHighlightLine(GameTooltip, "Note: Gossip Editor cannot detect text tags in use. You'll need to fix them before saving again. Sorry.")
		GameTooltip:Show();
	end)
	self.optionInfo:SetScript("OnLeave", GameTooltip_Hide)


	-- Setup Options Area:

	if not self.OptionsArea then
		self.OptionsArea = CreateFrame("Frame", "GossipEditorFrameOptionsArea", self, "InsetFrameTemplate")
		local frame = self.OptionsArea
		frame:SetSize(330, 180)
		frame:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", 14, 44)

		-- Scroll view with linear layout
		local scrollBox = CreateFrame("Frame", nil, frame, "WowScrollBoxList")
		scrollBox:SetPoint("TOPLEFT", frame, "TOPLEFT", 6, -2)
		scrollBox:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -10, 2)

		local scrollView = CreateScrollBoxListLinearView(4, 0, 0, 12, 2)
		--scrollView:SetPadding(0, 0, 0, 12, 2)
		scrollView:SetElementExtent(34)

		-- Create one single dropdown to reuse
		local iconDropdown = CreateFrame("Frame", "GossipEditorIconDropdown", UIParent, "UIDropDownMenuTemplate")
		iconDropdown.selectedButton = nil
		local function Dropdown_Initialize(self, level)
			if level ~= 1 then return end
			for _, entry in ipairs(ICON_LIST) do
				local info   = UIDropDownMenu_CreateInfo()
				info.text    = entry.label .. " (" .. entry.id .. ")"
				info.icon    = GetIconPath(entry.type)
				info.checked = (iconDropdown.selectedButton._type == entry.type)
				info.func    = function()
					iconDropdown.selectedButton._type = entry.type
					iconDropdown.rootFrame.data.type = entry.type:lower()
					iconDropdown.selectedButton.Icon:SetTexture(GetIconPath(entry))
					GossipEditorFrame.Reset:SetEnabled(true)
					CloseDropDownMenus()
				end
				UIDropDownMenu_AddButton(info, level)
			end
		end
		UIDropDownMenu_Initialize(iconDropdown, Dropdown_Initialize)

		local function _setupElementEntryFrame(frame, elementData)
			local iconTexture = "Interface/GossipFrame/" .. elementData.type .. "GossipIcon"

			if not frame.initialized then
				local root = frame:GetParent():GetParent():GetParent():GetParent()
				frame:SetSize(330, 34)
				frame.initialized = true

				local iconButton = CreateFrame("Button", nil, frame, "IconButtonTemplate")
				iconButton:SetSize(16, 16)
				iconButton:SetPoint("TOPLEFT", 2, 0)
				frame.iconButton = iconButton

				local iconTex = iconButton:CreateTexture(nil, "ARTWORK")
				iconTex:SetSize(16, 16)
				iconTex:SetPoint("CENTER", -1, 0)

				local setTex = iconTex.SetTexture
				iconTex.SetTexture = function(self, texture)
					setTex(self, texture)
					iconButton:SetHighlightTexture(texture)
				end

				iconTex:SetTexture(GetIconPath(ICON_LIST[1]))
				iconButton.Icon = iconTex
				iconButton._type = ICON_LIST[1].type
				local highlight = iconButton:GetHighlightTexture()
				highlight:ClearAllPoints()
				highlight:SetPoint("CENTER")
				highlight:SetSize(16, 16)

				iconButton:SetScript("OnClick", function(self)
					iconDropdown.selectedButton = self
					iconDropdown.rootFrame = frame
					ToggleDropDownMenu(1, nil, iconDropdown, self, 0, -4)
				end)

				local pageLinkEditBox = CreateFrame("EditBox", nil, frame, "InputBoxScriptTemplate")
				pageLinkEditBox:SetSize(18, 18)
				pageLinkEditBox:SetPoint("BOTTOMLEFT")
				pageLinkEditBox:SetText("?")
				pageLinkEditBox:SetJustifyH("CENTER")
				pageLinkEditBox:SetJustifyV("MIDDLE")
				pageLinkEditBox:SetFontObject(SystemFont_Tiny)
				pageLinkEditBox:SetAutoFocus(false)

				pageLinkEditBox:SetScript("OnEnter", function(self)
					GameTooltip:SetOwner(self, "ANCHOR_RIGHT", -16, -4)
					GameTooltip_SetTitle(GameTooltip, "Page Link", NORMAL_FONT_COLOR)
					GameTooltip_AddHighlightLine(GameTooltip, "Link this option to a specific page", false)
					GameTooltip_AddHighlightLine(GameTooltip, " ", false)
					GameTooltip_AddHighlightLine(GameTooltip, "? = Not Linked, or Cannot get Page Link Data", false)
					GameTooltip_AddHighlightLine(GameTooltip, "NOTE: Gossip Editor CANNOT Get Page Link Data unless Gossip Debug (.phase forge npc gossip debug) is ENABLED.")
					GameTooltip:Show();
				end)
				pageLinkEditBox:SetScript("OnLeave", GameTooltip_Hide)


				local bg = pageLinkEditBox:CreateTexture(nil, "BACKGROUND")
				bg:SetAllPoints()
				bg:SetAtlas("common-button-square-gray-down")
				pageLinkEditBox:HookScript("OnTextChanged", function(self, userInput)
					if userInput and self:GetText() ~= "" then
						frame.data.link = self:GetText()
						GossipEditorFrame.Reset:SetEnabled(true)
					end
				end)
				frame.pageLinkEditBox = pageLinkEditBox

				local optionText = CreateFrame("ScrollFrame", nil, frame, "InputScrollFrameTemplate")
				optionText:SetPoint("TOPLEFT", 24, -2)
				--optionText:SetPoint("BOTTOMRIGHT", -34, 6)
				optionText:SetSize(275, 26)
				optionText.CharCount:SetFontObject(GameFontDisableTiny)
				optionText.EditBox:SetWidth(234)
				optionText.EditBox:SetFontObject(SystemFont_Med2)
				optionText.EditBox:SetMaxLetters(254 - #(baseCommand .. " option text ## "))
				optionText.EditBox:HookScript("OnTextChanged", function(self, userInput)
					if userInput and self:GetText() ~= "" then
						frame.data.text = self:GetText()
						GossipEditorFrame.Reset:SetEnabled(true)
					end
				end)
				frame.optionTextEditBox = optionText.EditBox

				local optionDeleteButton = CreateFrame("Button", nil, frame, "IconButtonTemplate")
				optionDeleteButton:SetSize(22, 22)
				optionDeleteButton:SetPoint("TOPRIGHT", optionText, "TOPRIGHT", 3, 4)
				optionDeleteButton:SetFrameLevel(math.max(optionText:GetFrameLevel(), optionText.EditBox:GetFrameLevel()) + 1)
				optionDeleteButton.Icon = optionDeleteButton:CreateTexture(nil, "OVERLAY")
				optionDeleteButton.Icon:SetPoint("CENTER", -1, 0)
				optionDeleteButton.Icon:SetSize(26, 26)
				optionDeleteButton.Icon:SetAtlas("Islands-MarkedArea")
				optionDeleteButton:SetHighlightAtlas("Islands-MarkedArea")
				optionDeleteButton:RegisterForClicks("RightButtonUp", "LeftButtonUp")
				optionDeleteButton:SetScript("OnClick", function(self, button, down)
					-- TODO: Convert this to RemoveByData to reduce bug chance
					GossipEditorFrame.OptionsArea:RemoveOptionByID(self:GetParent().id)
					GossipEditorFrame.Reset:SetEnabled(true)
				end)
				frame.optionDeleteButton = optionDeleteButton
			end

			-- store ID & data on button
			frame.id = elementData.id
			frame.data = elementData

			-- set texture on iconButton
			frame.iconButton.Icon:SetTexture(iconTexture)

			-- set optionTextEditBox text
			frame.optionTextEditBox:SetText(elementData.text or "ERROR")

			-- set page link text
			frame.pageLinkEditBox:SetText(elementData.link or "?")
		end

		scrollView:SetElementInitializer(
			"Frame",
			nil,
			_setupElementEntryFrame
		)

		scrollBox:SetView(scrollView)

		--- /tinspect GossipEditorFrame.OptionsArea:GetProvider()
		local dataProvider = CreateDataProvider()
		scrollBox:SetDataProvider(dataProvider)

		local ARROW_TOP_BUFFER = 4
		local scrollBar = CreateFrame("EventFrame", nil, frame, "MinimalScrollBar")
		scrollBar:SetPoint("TOPRIGHT", scrollBox, "TOPRIGHT", 0, 0)
		scrollBar:SetPoint("BOTTOMRIGHT", scrollBox, "BOTTOMRIGHT", 0, 0)
		scrollBar.Back:SetPoint("TOP", scrollBar, "TOP", 0, -ARROW_TOP_BUFFER)
		scrollBar.Forward:SetPoint("BOTTOM", scrollBar, "BOTTOM", 0, ARROW_TOP_BUFFER)

		scrollBox:GetScrollTarget():HookScript("OnUpdate", function()
			--self:UpdateDragScroll()
		end)

		ScrollUtil.InitScrollBoxListWithScrollBar(
			scrollBox,
			scrollBar,
			scrollView
		)

		local function populateDataProvider()
			dataProvider:Flush()
			local options = _GetGossipOptions(true)
			for i, opt in ipairs(options) do
				--local text = opt.name:gsub("|", "||")
				local text, pageLink = ParseOptionText(opt.name)
				dataProvider:Insert({
					-- Editable fields for saving modified data
					text     = text,
					type     = opt.type,
					link     = pageLink,

					-- ORIGINALS FOR INTERNAL CHANGE TRACKING: DON'T EDIT THESE
					id       = i - 1, -- DON'T EDIT THIS ONE
					origText = text,
					origType = opt.type,
					origLink = pageLink,
				})
			end
		end

		function frame:Refresh()
			populateDataProvider()
		end

		function frame:GetProvider()
			return dataProvider
		end

		function frame:GetHighestOptionID()
			local id = 0
			dataProvider:ForEach(function(elementData)
				if elementData.id then
					id = math.max(id, elementData.id)
				end
			end)
			return id
		end

		function frame:AddRawOption(text, iconType)
			text = text or "New Option"
			iconType = iconType or "gossip"
			dataProvider:Insert({
				id = self:GetHighestOptionID() + 1,
				text = text,
				type = iconType,
				origText = text,
				origType = iconType,
			})
		end

		-- THIS IS BY DATAPROVIDER INDEX, NOT OPTION ID.
		function frame:RemoveOption(index)
			dataProvider:RemoveIndex(index)
		end

		-- This is by ID
		function frame:RemoveOptionByID(id)
			for index, elementData in dataProvider:Enumerate() do
				if elementData.id == id then
					dataProvider:RemoveIndex(index)
					--self:ResetOptionIDsByIndex()
					return
				end
			end
		end

		function frame:ResetOptionIDsByIndex()
			for index, elementData in dataProvider:Enumerate() do
				local newID = index - 1
				if elementData.id ~= newID then
					elementData.id = newID
					elementData.dirty = true
				end
			end
		end
	end
end

-- -- GossipEditor namespace --------------------------------

GossipEditor                = {}

-- Internal state
local currentGreetingBlocks = {} -- raw blocks from server (0-indexed IDs)
local currentOptions        = {} -- { id, text, icon } per live option
local greetingDirty         = false
local isGossipDebugDetected = false
local isGossipLoading       = false

local gossipTargetGUID      = nil

-- -- Greeting character counter ----------------------------

function GossipEditor:OnGreetingChanged(editBox)
	local text   = editBox:GetText()
	local len    = #text
	local blocks = splitIntoBlocks(text)
	GossipEditorFrame.GreetingScroll.CharCount:SetText(
		len .. " chars / " .. #blocks .. " block(s)"
	)
	greetingDirty = true
	GossipEditorFrame.Reset:SetEnabled(true)
end

local debugGreetingText = "|cffFFFFFF%[Page "
local debugOptionText = "^|cffFFFFFF%[Option "
local noGreetingText = "|cffFF0000Gossip forge %- no text found for page %d+|r"

--	if rawText:find("|cffFF0000Gossip forge %- no text found for page %d+|r") then


local function setDebugLabel(tog)
	if tog then
		-- enabled
		--GossipEditorFrame.DebugLabel:SetText("Debug Enabled")
		--GossipEditorFrame.DebugLabel:SetTextColor(26 / 255, 255 / 255, 26 / 255)
		GossipEditorFrame.ToggleDebug:SetText("Debug: On")
		GossipEditorFrame.ToggleDebug.debugEnabled = true
	elseif tog == false then
		-- disabled
		--GossipEditorFrame.DebugLabel:SetText("Debug Not Enabled")
		--GossipEditorFrame.DebugLabel:SetTextColor(255 / 255, 26 / 255, 26 / 255)
		GossipEditorFrame.ToggleDebug:SetText("Debug: Off")
		GossipEditorFrame.ToggleDebug.debugEnabled = false
	else
		-- we don't know
		--GossipEditorFrame.DebugLabel:SetText("¿Debug Unknown?")
		--GossipEditorFrame.DebugLabel:SetTextColor(255 / 255, 255 / 255, 26 / 255)
		GossipEditorFrame.ToggleDebug:SetText("Debug: ??")
		GossipEditorFrame.ToggleDebug.debugEnabled = nil
	end
end

function GossipEditor:CheckForDebug()
	local greetingText = _GetGossipText(true)
	local gossipOptions = _GetGossipOptions(true)
	if greetingText:find(noGreetingText) and #gossipOptions == 0 then
		-- no greeting, no options. WHO KNOWS!?
		setDebugLabel(nil)
		isGossipDebugDetected = false
		return
	elseif _GetGossipText(true):find(debugGreetingText) then
		setDebugLabel(true)
		isGossipDebugDetected = true
		return true
	else
		if gossipOptions and gossipOptions[1] and gossipOptions[1].name and gossipOptions[1].name:find(debugOptionText) then
			setDebugLabel(true)
			isGossipDebugDetected = true
			return true
		end
	end

	setDebugLabel(false)
	isGossipDebugDetected = false
	return false
end

function GossipEditor:ToggleDebug()
	sendCommand("phase forge npc gossip debug", function(success, msgs)
		if success then
			self:ForceRefreshGossip(function()
				GossipEditor:Open()
			end)
		end
	end)
end

function GossipEditor:ToggleSavingSteps(checked)
	if checked ~= nil then
		showSaveProgress = checked
	else
		showSaveProgress = not showSaveProgress
	end
end

function GossipEditor:OopsPrevention(text, callback)
	text = "Gossip Editor may have unsaved changes. " .. (text or "\n\rAre you sure?")
	if type(callback) == "string" then
		local methodName = callback -- capture the string now
		callback = function() GossipEditor[methodName](GossipEditor) end
	end
	if GossipEditorFrame.Reset:IsEnabled() then
		EpsilonLib.Utils.GenericDialogs.GenericConfirmation(text, callback)
		return false
	else
		if callback then callback() end
		return true
	end
end

-- -- Force Refresh Gossip ----------------------------
-- Closes & then re-opens the gossip, forcing a full refresh

local interruptPendingGossipShow = false

function GossipEditor:ForceRefreshGossip(callback)
	_CloseGossip()
	EpsilonLib.RunScript.raw("InteractUnit('target')")
	EpsilonLib.EventManager:OnNext("GOSSIP_SHOW", function()
		if interruptPendingGossipShow then
			interruptPendingGossipShow = false
			return
		end
		if callback then callback() end
	end)
end

function GossipEditor:WatchForNextAndRefresh(callback)
	EpsilonLib.EventManager:OnNext("GOSSIP_SHOW", function()
		if interruptPendingGossipShow then
			interruptPendingGossipShow = false
			return
		end
		GossipEditor:ForceRefreshGossip(callback)
	end)
end

function GossipEditor:WaitForGossipOpen(callback)
	EpsilonLib.EventManager:OnNext("GOSSIP_SHOW", function()
		if interruptPendingGossipShow then
			interruptPendingGossipShow = false
			return
		end
		callback()
	end)
end

function GossipEditor:InterruptWaitWatchRefresh()
	interruptPendingGossipShow = true
end

-- -- Open / toggle -----------------------------------------

function GossipEditor:Toggle()
	if GossipEditorFrame:IsShown() then
		GossipEditorFrame:Hide()
	else
		self:Open()
	end
end

function GossipEditor:Open()
	self:LoadGossip()
	GossipEditorFrame:Show()
end

function GossipEditor:Close()
	gossipTargetGUID = nil
	currentGreetingBlocks = {}
	currentOptions = {}
	greetingDirty = false
	GossipEditorFrame:Hide()
end

function GossipEditor:LoadGossip()
	if not GossipFrame:IsShown() then return end
	if not UnitGUID("npc") then return end
	gossipTargetGUID = UnitGUID("npc")
	self:LoadGreeting()
	self:LoadOptions()
end

-- -- Load greeting -----------------------------------------
-- Fetches the raw server blocks via `phase forge npc gossip text get`.
-- Parses the achievement-link formatted return messages to extract
-- the real text for each block, then joins them for display.

function GossipEditor:LoadGreeting()
	local scrollFrame = GossipEditorFrame.GreetingScroll
	local editBox = scrollFrame.EditBox
	editBox:SetText("Loading...")
	editBox:SetEnabled(false)
	GossipEditorFrame.Reset:SetEnabled(false)
	greetingDirty = false

	self:CheckForDebug()

	local rawText = _GetGossipText(true)
	if rawText:find(noGreetingText) then
		currentGreetingBlocks = {}
		editBox:SetText("")
		editBox:SetEnabled(true)
		return
	end

	isGossipLoading = true
	sendCommand("phase forge npc gossip text get", function(success, msgs)
		currentGreetingBlocks = {}

		if not success or not msgs then
			editBox:SetText("")
			editBox:SetEnabled(true)
			GossipEditorFrame.Reset:SetEnabled(true)
			isGossipLoading = false
			return
		end

		-- msgs[1] is the info line — discard it.
		-- Each subsequent message is an achievement link:
		-- |cffffffff|Hachievement:9999:0:H:0:0:0:0:0:0:0|h.ph f n g t o 0 BlockText|h|r
		-- We want the blockID and the text after the last space-separated token
		-- that follows the pattern ".ph f n g t o <blockID> <text>".
		for i = 2, #msgs do
			local msg = msgs[i]
			-- Strip the link formatting to get the inner content.
			-- The |h....|h wraps ".ph f n g t o <blockID> <text>"
			local inner = msg:match("|h(.+)|h")
			if inner then
				-- Tokenise: split on spaces, first 7 tokens are
				-- ".ph", "f", "n", "g", "t", "o", "<blockID>"
				-- Everything after is the block text.
				local tokens = {}
				for token in inner:gmatch("%S+") do
					tokens[#tokens + 1] = token
				end
				-- Token index 7 (1-indexed) is the blockID (0-based on server).
				-- Token index 8 onward is the text (rejoin with spaces).
				if #tokens >= 8 then
					local blockId   = tonumber(tokens[7])
					local blockText = table.concat(tokens, " ", 8)
					if blockId then
						currentGreetingBlocks[blockId] = blockText
					end
				end
			end
		end

		-- Reconstruct display text by joining blocks in ID order.
		local parts = {}
		for id = 0, #currentGreetingBlocks do
			if currentGreetingBlocks[id] then
				parts[#parts + 1] = currentGreetingBlocks[id]
			end
		end

		local fullText = table.concat(parts, " "):gsub("$b", "\r")
		editBox:SetText(fullText)
		editBox:SetEnabled(true)
		scrollFrame.CharCount:SetText(
			#fullText .. " chars / " .. #currentGreetingBlocks + 1 .. " block(s)"
		)
		greetingDirty = false
		isGossipLoading = false
	end)
end

-- -- Load options ------------------------------------------
-- Reads the live gossip options from the client using the raw
-- API shims, then builds a row for each option.

function GossipEditor:LoadOptions()
	GossipEditorFrame.OptionsArea:Refresh()
end

-- -- Add option --------------------------------------------

function GossipEditor:AddOption(text, icon)
	GossipEditorFrame.OptionsArea:AddRawOption(text, icon)
	--[[
	if not text then text = "New Option" end
	sendCommand("phase forge npc gossip option add " .. text,
		function(success)
			if success then
				self:Open()
			end
		end)
	--]]
end

-- -- Remove option -----------------------------------------

function GossipEditor:RemoveOption(optionId)
	sendCommand("phase forge npc gossip option remove " .. optionId,
		function(success)
			if success then
				-- Refresh the Gossip when it re-opens, because it always
				-- re-opens wrong the first time after deleting an option
				GossipEditor:WatchForNextAndRefresh(function()
					GossipEditor:Open()
				end)
			end
		end)
end

-- -- Save --------------------------------------------------
-- Saves greeting and all modified options as a command chain
-- so the server processes them sequentially.

function GossipEditor:Save()
	if (UnitGUID("target") ~= gossipTargetGUID) or (UnitGUID("target") ~= UnitGUID("npc")) then
		EpsilonLib.Utils.GenericDialogs.GenericAlert("You need to have the Gossip NPC targeted.")
		return
	end

	local commands = { "command alias " .. baseCommand .. "=phase forge npc gossip" }

	-- -- Greeting -------------------------------------------
	if greetingDirty then
		local text      = GossipEditorFrame.GreetingScroll.EditBox:GetText():gsub("[\n\r]", "$b")
		local newBlocks = splitIntoBlocks(text)
		local oldCount  = 0
		for _ in pairs(currentGreetingBlocks) do -- might be able to efficiently change this to #currentGreetingBlocks + 1? idk
			oldCount = oldCount + 1
		end
		local newCount = #newBlocks

		-- Overwrite blocks that existed before (0-indexed block IDs).
		for i = 1, math.min(newCount, oldCount) do
			commands[#commands + 1] =
				baseCommand .. " text overwrite " .. (i - 1)
				.. " " .. newBlocks[i]
		end

		if newCount > oldCount then
			-- Add any new blocks beyond the old count.
			for i = oldCount + 1, newCount do
				commands[#commands + 1] =
					baseCommand .. " text add " .. newBlocks[i]
			end
		elseif newCount < oldCount then
			-- Remove any surplus blocks (walk backwards to avoid
			-- decrementing IDs shifting under us).
			for i = oldCount, newCount + 1, -1 do
				commands[#commands + 1] =
					baseCommand .. " text remove " .. (i - 1)
			end
		end
	end

	-- -- Options --------------------------------------------
	local dataProvider = GossipEditorFrame.OptionsArea:GetProvider()
	local maxID = 0
	local currentNumOptions = _GetNumGossipOptions(true)

	local deletedRows = {}

	local index = -1
	dataProvider:ForEach(function(elementData)
		local newText = elementData.text:gsub("[\n\r]", "$b")
		local id = elementData.id -- original server ID, or assigned ID if added in this save
		local type, typeID, originalType = elementData.type, iconTypeMap[elementData.type:lower()].id, elementData.origType
		local pageLink, originalPageLink = elementData.link, elementData.origLink
		index = index + 1
		maxID = math.max(maxID, id, index) + 1

		if (index + 1) > currentNumOptions then
			-- we are already past how many we originally had, do not handle deleting things from here
			-- and just add -- basically, ignore IDs and just use the optionIndex and add new
			commands[#commands + 1] = (baseCommand .. (" opt add %s"):format(newText))

			-- set icon if needed
			if type ~= "gossip" then
				commands[#commands + 1] = (baseCommand .. (" opt icon %s %s"):format(index, typeID))
			end

			-- set pageLink if needed
			if pageLink and pageLink ~= "" then
				commands[#commands + 1] = (baseCommand .. (" opt link %s %s"):format(index, pageLink))
			end

			return
		end

		-- check if there are deletions between current iter & the actual ID
		if index < id then
			-- deletions occurred between this ID, add them for deleting at the end
			for i = index, id - 1 do
				-- for the current index that is empty, thru whatever our current ID is, log remove to do at end
				deletedRows[#deletedRows + 1] = (baseCommand .. (" opt remove %s"):format(i))
			end

			-- then iterate our index forward
			index = id
		end

		-- we are past removals & new lines: Just check if this line changed and we need to update
		if (elementData.origText ~= elementData.text) then
			commands[#commands + 1] = (baseCommand .. (" opt text %s %s"):format(index, newText))
		end
		if (type:lower() ~= originalType:lower()) then
			commands[#commands + 1] = (baseCommand .. (" opt icon %s %s"):format(index, typeID))
		end
		if pageLink and (pageLink ~= "") and (pageLink ~= originalPageLink) then
			commands[#commands + 1] = (baseCommand .. (" opt link %s %s"):format(index, pageLink))
		end
	end)
	maxID = maxID

	-- maxID is less than current, so remove excess
	if maxID < (currentNumOptions) then
		for i = currentNumOptions, maxID + 1, -1 do
			commands[#commands + 1] = (baseCommand .. (" opt remove " .. i - 1))
		end
	end

	if #deletedRows > 0 then
		for i = 1, #deletedRows do
			local cmd = deletedRows[i]
			commands[#commands + 1] = cmd
		end
	end

	if #commands == 1 then --- only command was our alias, just exit
		print("|cff00ff00GossipEditor:|r Nothing to save.")
		return
	end

	table.insert(commands, "command alias " .. baseCommand)

	print("|cff00ff00GossipEditor:|r Saving Gossip - Please wait.. (do not unselect your Gossip NPC!)")

	local commandIndex = 1
	local hadError = false
	local function processNextCommand()
		local command = commands[commandIndex]
		local curIndex = commandIndex
		commandIndex = commandIndex + 1

		if not command then -- we have finished processing! Just trigger a watch for next and refresh
			GossipEditor:ForceRefreshGossip(function()
				GossipEditor:Open()
				if hadError then
					print("|cffff4444GossipEditor:|r Save Complete with Errors.")
				else
					print("|cff00ff00GossipEditor:|r All Edits Saved successfully.")
				end
			end)
			commandIndex = 1
			greetingDirty = false
			return
		end

		if showSaveProgress and ((curIndex > 1) and (curIndex < #commands)) then
			print("|cff00ffffGossipEditor: |r Saving ", curIndex - 1, "/", #commands - 2, ": ..", command:sub(#baseCommand + 2))
		end

		sendCommand(command, function(success)
			if not success then
				hadError = true
				print("|cffff4444GossipEditor:|r Save failed — check server response.")
				print("|cffff4444Failed Command:|r " .. command)

				-- interrupt, or just push onwards with a forced refresh?
				--GossipEditor:InterruptWaitWatchRefresh()
				GossipEditor:WatchForNextAndRefresh(processNextCommand)
			else
				if curIndex > 1 and curIndex < #commands then
					GossipEditor:WaitForGossipOpen(processNextCommand)
				else -- first and last do not need to wait, they are alias commands
					processNextCommand()
				end
			end
		end)
	end
	processNextCommand()
end

-- -- Hook GossipFrame to show/hide the edit button ---------

local function onGossipShow()
	if GossipEditorFrame:IsShown() then
		if isGossipLoading then return end
		GossipEditor:LoadGossip()
	end

	if (C_Epsilon and C_Epsilon.IsDM) or UnitName("player") == "Lua" then
		GossipEditorButton:Show()
	else
		GossipEditorButton:Hide()
	end
end

local function onGossipHide()
	GossipEditorButton:Hide()
	GossipEditorFrame:Hide()
end

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("GOSSIP_SHOW")
eventFrame:RegisterEvent("GOSSIP_CLOSED")
eventFrame:SetScript("OnEvent", function(self, event)
	if event == "GOSSIP_SHOW" then onGossipShow() end
	if event == "GOSSIP_CLOSED" then onGossipHide() end
end)
