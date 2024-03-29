local addonName, ns = ...

---@type string
local addonPath = "Interface/AddOns/" .. tostring(addonName)
local assetsPath = addonPath.."/assets/"

---@enum
local scopes = {
	ACCOUNT = "Account",
	CHARACTER = "Character"
}

---@param text string command text to run, no dot
local function cmd(text)
	SendChatMessage("." .. text, "GUILD");
end

---Evaluates a given value as itself, or as the result of itself if it was a function.
---@generic V
---@param value (V | fun(): V)
---@return V
local function evaluate(value)
	if type(value) == "function" then
		return value()
	end

	return value
end

---Finds & returns the currently scoped table (Account vs Character) from the master (account) table's setting. 
---@return table scopedTable
local function getScopedTable()
	return _G["Epsilon_ChatToggle_" .. Epsilon_ChatToggle_Account.scope]
end

-- -- -- -- -- -- -- -- -- -- -- -- 
--- Options Loading
-- -- -- -- -- -- -- -- -- -- -- -- 

local Epsilon_ChatToggle_Account_Defaults = {
	scope = "Character",
	ignore = true,
	AnnounceEnabled = {
		ann = true,
		event = true,
		guild = true,
	}
}
local Epsilon_ChatToggle_Character_Defaults = {
	AnnounceEnabled = {
		ann = true,
		event = true,
		guild = true,
	}
}

---Loads a settings table into a master table, but does not over-write if data is already present
---@param settings table The Default Settings to Copy
---@param master table The Actual Table to hold the settings (aka: your global table saved)
local function loadDefaultsIntoMaster(settings, master)
	for k, v in pairs(settings) do
		if (type(v) == "table") then
			if (master[k] == nil or type(master[k]) ~= "table") then master[k] = {} end
			loadDefaultsIntoMaster(v, master[k]);
		else
			if master and master[k] == nil then
				master[k] = v;
			end
		end
	end
end

-- -- -- -- -- -- -- -- -- -- -- -- 
--- Create the chat frame button & menu holding frame
-- -- -- -- -- -- -- -- -- -- -- -- 

local updateButtonLabels

local announceButton = CreateFrame("Button", "EpsilonChatToggleButton", UIParent)
announceButton:SetNormalTexture(assetsPath .. "UI-ChatIcon-Chat-Up")
announceButton:SetPushedTexture(assetsPath .. "UI-ChatIcon-Chat-Down")
announceButton:SetDisabledTexture(assetsPath .. "UI-ChatIcon-Chat-Disabled")
announceButton:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight")
announceButton:SetPoint("TOP", ChatFrameChannelButton, "BOTTOM", 0, -2)
announceButton:SetSize(32, 32)
announceButton.tooltipTitle = "Server Announce Channels"

announceButton:SetScript("OnEnter", function(self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
	GameTooltip:SetText(self.tooltipTitle, 1, 1, 1, 1, true)
	GameTooltip:Show();
end)
announceButton:SetScript("OnLeave", function(self)
	GameTooltip:Hide();
end)

local announceMenu = CreateFrame("Frame", "EpsilonChatMenu", UIParent, "UIMenuTemplate")
announceMenu:SetPoint("TOPLEFT", announceButton, "BOTTOMRIGHT")
announceMenu:SetShown(false)
announceMenu:SetClampedToScreen(true)
tinsert(UIMenus, "EpsilonChatMenu")

announceButton:SetScript("OnClick", function()
	announceMenu:SetShown(not announceMenu:IsShown());
end)

announceMenu:SetScript("OnShow", function(self)
	UIMenu_OnShow(self)
	ChatMenu:Hide()
end)

ChatMenu:HookScript("OnShow", function(self)
	announceMenu:Hide()
end)

-- Override Default Menu Handlers for customization:

local function UIMenuButton_OnClick_OVERRIDE(self)
	local func = self.func;
	if ( func ) then
		func(self);
	end

	if ( not self.dontHideParentOnClick ) then
		self:GetParent():Hide();
	end

	PlaySound(SOUNDKIT.U_CHAT_SCROLL_BUTTON);
end

local menuName = announceMenu:GetName()
for id = 1, UIMENU_NUMBUTTONS do
	local button = _G[menuName.."Button"..id];
	button:SetScript("OnClick", UIMenuButton_OnClick_OVERRIDE)
end

-- -- -- -- -- -- -- -- -- -- -- -- 
--- Functions for the buttons when clicked
-- -- -- -- -- -- -- -- -- -- -- -- 

local function toggleAnn(button_fromUI)
	cmd("toggle announce")

	if button_fromUI then 
		local shortcutString = _G[button_fromUI:GetName().."ShortcutText"];
		shortcutString:SetText("...");
	end
end

local function toggleEventAnn(button_fromUI)
	cmd("toggle event")

	if button_fromUI then 
		local shortcutString = _G[button_fromUI:GetName().."ShortcutText"];
		shortcutString:SetText("...");
	end
end

local function toggleGuildAnn(button_fromUI)
	cmd("toggle guild")

	if button_fromUI then 
		local shortcutString = _G[button_fromUI:GetName().."ShortcutText"];
		shortcutString:SetText("...");
	end
end

local function toggleScope()
	if Epsilon_ChatToggle_Account.scope == "Character" then
		-- was character, switch to account, copy settings from character->account to match current settings
		Epsilon_ChatToggle_Account.scope = scopes.ACCOUNT
		Epsilon_ChatToggle_Account.AnnounceEnabled = CopyTable(Epsilon_ChatToggle_Character.AnnounceEnabled)
	else
		-- was account, switch to character, copy settings from account->character to match current settings
		Epsilon_ChatToggle_Account.scope = scopes.CHARACTER
		Epsilon_ChatToggle_Character.AnnounceEnabled = CopyTable(Epsilon_ChatToggle_Account.AnnounceEnabled)

	end

	updateButtonLabels()
end

local function toggleIgnore()
	Epsilon_ChatToggle_Account.ignore = not Epsilon_ChatToggle_Account.ignore

	updateButtonLabels()
end

-- -- -- -- -- -- -- -- -- -- -- -- 
--- Button Info table & helper functions
-- -- -- -- -- -- -- -- -- -- -- -- 

---@class buttonInfo
---@field tag string? the tag to reference within the AnnounceEnabled sub table
---@field text string|function the main text label of the button
---@field shortcut string|function? the optional additional white text on the right side of the button (2 column text)
---@field disabled boolean? if the button should be disabled.
---@field func function? function that should be ran when the button is clicked.

---@type buttonInfo[]
local buttonsList = {
	[1] = { tag = "ann", text = "Toggle Announce", shortcut = function() return (getScopedTable().AnnounceEnabled.ann and "Enabled" or "Disabled") end, func = toggleAnn, keepOpen = true},
	[2] = { tag = "event", text = "Toggle Event Announce", shortcut = function() return (getScopedTable().AnnounceEnabled.event and "Enabled" or "Disabled") end, func = toggleEventAnn, keepOpen = true},
	[3] = { tag = "guild", text = "Toggle Guild Announce", shortcut = function() return (getScopedTable().AnnounceEnabled.guild and "Enabled" or "Disabled") end, func = toggleGuildAnn, keepOpen = true},

	[4] = { text = " ", disabled = true },

	[5] = { text = "Sync Toggles to:", shortcut = function() return Epsilon_ChatToggle_Account.scope end, func = toggleScope, keepOpen = true},
	[6] = { text = "Ann Respects Ignore:", shortcut = function() return (Epsilon_ChatToggle_Account.ignore and "Enabled" or "Disabled") end, func = toggleIgnore, keepOpen = true},

	[7] = { text = " ", disabled = true },

	[8] = { text = "Close"}
}

---Gets the proper text & shortcutText of a button from the buttonsList by index, accounting for function returns
---@param index integer Index of the button from the buttonsList
---@return string buttonText
---@return string shortcutText
local function getTextForButton(index)
	local buttonInfo = buttonsList[index]
	local scopedTable = getScopedTable()
	local text
	local shortcut

	-- no if because if you don't give text you should get an error lol
	text = evaluate(buttonInfo.text) --[[@as string]]
	
	if buttonInfo.tag then
		text = text .. " " .. (scopedTable.AnnounceEnabled[buttonInfo.tag] and "Off" or "On")
	end
	if buttonInfo.shortcut then
		shortcut = evaluate(buttonInfo.shortcut) --[[@as string]]
	end
	return text, shortcut
end

updateButtonLabels = function()
	for i = 1, #buttonsList do
		local button = _G["EpsilonChatMenuButton"..i]
		local shortcut = _G["EpsilonChatMenuButton"..i.."ShortcutText"]
		local text, shortcutText = getTextForButton(i)
		button:SetText(text)
		shortcut:SetText(shortcutText)
	end
	UIMenu_AutoSize(announceMenu);
end

local function initMenu()
	UIMenu_Initialize(announceMenu);
	for k = 1, #buttonsList do
		local v = buttonsList[k]
		local text, shortcutText = getTextForButton(k)
		UIMenu_AddButton(announceMenu, text, shortcutText, v.func)
		local button = _G["EpsilonChatMenuButton"..k]
		if v.keepOpen then button.dontHideParentOnClick = true end
		if v.disabled then button:Disable() end
	end
	UIMenu_AutoSize(announceMenu);
	updateButtonLabels()
end

-- -- -- -- -- -- -- -- -- -- -- -- 
--- Event Frame for Loading & Restore Toggles, and init menu
-- -- -- -- -- -- -- -- -- -- -- -- 

local listener = CreateFrame("Frame")
listener:SetScript("OnEvent", function(self, event, addon)
	if addon ~= addonName then return end
	if not Epsilon_ChatToggle_Account then Epsilon_ChatToggle_Account = {} end
	if not Epsilon_ChatToggle_Character then Epsilon_ChatToggle_Character = {} end
	loadDefaultsIntoMaster(Epsilon_ChatToggle_Account_Defaults, Epsilon_ChatToggle_Account)
	loadDefaultsIntoMaster(Epsilon_ChatToggle_Character_Defaults, Epsilon_ChatToggle_Character)

	local scopedTable = getScopedTable()
	for k,v in pairs( scopedTable.AnnounceEnabled ) do
		if v == false then
			C_Timer.After(2, function() cmd("toggle "..k.." off") end)
		end
	end

	initMenu()
end)
listener:RegisterEvent("ADDON_LOADED")

-- -- -- -- -- -- -- -- -- -- -- -- 
--- Message Filters to Capture & Handle Announce Toggled Messages
-- -- -- -- -- -- -- -- -- -- -- -- 

---Update the Saved State in our Scoped Table for if that Announce Type is enabled or not.
---@param annType "ann"|"event"|"guild" direct string reference for that announce type, based on the table construction
---@param toggled boolean if the type is enabled or not
local function setAnnounceToggled(annType, toggled)
	local scope = Epsilon_ChatToggle_Account.scope
	_G["Epsilon_ChatToggle_"..scope].AnnounceEnabled[annType] = toggled
	updateButtonLabels()
end

local announceMessages = {
	["|cff00CCFFBroadcasts are now |renabled|cff00CCFF.|r"] = function() setAnnounceToggled("ann", true) end,
	["|cff00CCFFBroadcasts are now |rdisabled|cff00CCFF.|r"] = function() setAnnounceToggled("ann", false) end,

	["|cff00CCFFEvent broadcasts are now |renabled|cff00CCFF.|r"] = function() setAnnounceToggled("event", true) end,
	["|cff00CCFFEvent broadcasts are now |rdisabled|cff00CCFF.|r"] = function() setAnnounceToggled("event", false) end,

	["|cff00CCFFGuild broadcasts are now |renabled|cff00CCFF.|r"] = function() setAnnounceToggled("guild", true) end,
	["|cff00CCFFGuild broadcasts are now |rdisabled|cff00CCFF.|r"] = function() setAnnounceToggled("guild", false) end,
}
--[[

|cff00CCFFBroadcasts are now |rdisabled|cff00CCFF.|r
|cff00CCFFEvent broadcasts are now |rdisabled|cff00CCFF.|r
|cff00CCFFGuild broadcasts are now |rdisabled|cff00CCFF.|r

|cff00CCFFBroadcasts are now |renabled|cff00CCFF.|r
|cff00CCFFEvent broadcasts are now |renabled|cff00CCFF.|r
|cff00CCFFGuild broadcasts are now |renabled|cff00CCFF.|r

]]

local function announceToggleListener(self, event, message)
	-- Announce Toggle Listener
	if announceMessages[message] then
		announceMessages[message]()
		return false
	end

	-- Ignore Filter
	if Epsilon_ChatToggle_Account.ignore then
		local playerName = message:match("|Hplayer:(.-)|h")
		if playerName then
			if C_FriendList.IsIgnored(playerName) then
				--print(playerName.." is Ignored. Message should be hidden.")
				return true;
			end
		end
	end
end

ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", announceToggleListener)
ChatFrame_AddMessageEventFilter("CHAT_MSG_ACHIEVEMENT", announceToggleListener);
ChatFrame_AddMessageEventFilter("CHAT_MSG_BN_WHISPER_INFORM", announceToggleListener);
ChatFrame_AddMessageEventFilter("CHAT_MSG_COMBAT_XP_GAIN", announceToggleListener);
ChatFrame_AddMessageEventFilter("CHAT_MSG_COMBAT_HONOR_GAIN", announceToggleListener);
ChatFrame_AddMessageEventFilter("CHAT_MSG_COMBAT_FACTION_CHANGE", announceToggleListener);
ChatFrame_AddMessageEventFilter("CHAT_MSG_TRADESKILLS", announceToggleListener);
ChatFrame_AddMessageEventFilter("CHAT_MSG_OPENING", announceToggleListener);
ChatFrame_AddMessageEventFilter("CHAT_MSG_PET_INFO", announceToggleListener);
ChatFrame_AddMessageEventFilter("CHAT_MSG_COMBAT_MISC_INFO", announceToggleListener);
ChatFrame_AddMessageEventFilter("CHAT_MSG_BG_SYSTEM_HORDE", announceToggleListener);
ChatFrame_AddMessageEventFilter("CHAT_MSG_BG_SYSTEM_ALLIANCE", announceToggleListener);
ChatFrame_AddMessageEventFilter("CHAT_MSG_BG_SYSTEM_NEUTRAL", announceToggleListener);
ChatFrame_AddMessageEventFilter("CHAT_MSG_TARGETICONS", announceToggleListener);
ChatFrame_AddMessageEventFilter("CHAT_MSG_BN_CONVERSATION_NOTICE", announceToggleListener);
