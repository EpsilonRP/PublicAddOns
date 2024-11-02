-------------------------------------------------------------------------------
-- Simple Chat Functions
-------------------------------------------------------------------------------
local server

if Epsilon then
	local utils = Epsilon.utils
	server = utils.server
end

if EpsilonLib then
	server = EpsilonLib.Server.server
end

if not server then
	server = {
		send = function(...)
			if EpsilonLib and EpsilonLib.Server then -- reattempt assignment?
				server = EpsilonLib.Server.server
				server.send(...)
			else
				error("Error using EpsilonLib server.send() - EpsilonLib not available")
			end
		end
	}
end

local function cmd(text)
	SendChatMessage("." .. text, "GUILD");
end

local function msg(text)
	SendChatMessage("" .. text, "SAY");
end

local function cprint(text)
	local line = strmatch(debugstack(2), ":(%d+):")
	if line then
		print("|cffFFD700 CBDEBUG " .. line .. ": " .. text .. "|r")
	else
		print("|cffFFD700 CBDEBUG @ERROR: " .. text .. "|r")
		print(debugstack(2))
	end
end

-------------------------------------------------------------------------------
-- Some Default Stuff
-------------------------------------------------------------------------------
chatBubbleOptions = {} -- Global cuz I'm an idiot back in the day and now we're stuck with it.

local supportedChatTypes = {
	{ key = "SAY",       display = "Say",        default = 211565 },
	{ key = "EMOTE",     display = "Emote",      default = 142677 },
	{ key = "YELL",      display = "Yell",       default = 90080 },
	{ key = "GUILD",     display = "Guild",      default = 0 },
	{ key = "WHISPER",   display = "Whisper",    default = 0 },
	{ key = "PARTY",     display = "Party",      default = 0 },
	{ key = "RAID",      display = "Raid",       default = 0 },
	{ key = "CHANNEL",   display = "Channel",    default = 0 },
	{ key = "COMMANDS",  display = "Commands",   default = 0 },
	{ key = "OOC",       display = "OOC",        default = 0 },
	{ key = "NPC_SAY",   display = "NPC Say*",   default = 0,     override_pattern = "^%.np?c? say? ",       tooltip = "Applies this 'action' to the NPC when using the '.npc say' command.",   notSelf = true, },
	{ key = "NPC_EMOTE", display = "NPC Emote*", default = 0,     override_pattern = "^%.np?c? e?m?o?t?e? ", tooltip = "Applies this 'action' to the NPC when using the '.npc emote' command.", notSelf = true, },
	{ key = "NPC_YELL",  display = "NPC Yell*",  default = 0,     override_pattern = "^%.np?c? ye?l?l? ",    tooltip = "Applies this 'action' to the NPC when using the '.npc yell' command.",  notSelf = true, },
}

-- Parse our supported chatTypes into quick lookup tables.
local defaultChatSpells = {}
local supportedChatTypes_map = {}
local command_chat_overrides = {}
for k, v in ipairs(supportedChatTypes) do
	defaultChatSpells[v.key] = v.default
	supportedChatTypes_map[v.key] = v
	if v.override_pattern then
		command_chat_overrides[v.key] = v.override_pattern
	end
end

local function newSetDefaultSpells()
	if chatBubbleOptions.ChatSpells == nil or chatBubbleOptions.ChatSpells == "" then chatBubbleOptions.ChatSpells = {} end
	for k, v in pairs(defaultChatSpells) do
		if chatBubbleOptions.ChatSpells[k] == nil then chatBubbleOptions.ChatSpells[k] = v end
	end
end

local function clearAnyChatSpells()
	for _, v in pairs(chatBubbleOptions.ChatSpells) do
		if tonumber(v) and tonumber(v) > 0 then cmd("unaura " .. v .. " self") end
	end
	cmd("mod stand 0")
end

local presetSpells = {}
local presetSpellsName = {}

local function registerPreset(id, name)
	table.insert(presetSpells, id)
	presetSpellsName[id] = name
end

registerPreset("0", "-- Disable Spell/Emote (<Typing> Only) --")
registerPreset("211565", "Spell: Chat Bubble")
registerPreset("142677", "Spell: Gear")
registerPreset("90080", "Spell: Red '!'")
registerPreset("196230", "Spell: Gold '!'")
registerPreset("81204", "Spell: Green '!'")
registerPreset("-396", "Emote: Talk")
registerPreset("-5", "Emote: Exclamation")
registerPreset("-6", "Emote: Question")
registerPreset("-432", "Emote: Working")
registerPreset("-492", "Emote: Reading (Map)")
registerPreset("-588", "Emote: Read & Talk (Map)")
registerPreset("-641", "Emote: Reading (Book)")
registerPreset("*593", "AnimKit: Talking")

-------------------------------------------------------------------------------
-- Securing The Addon to Epsilon (ish)
-------------------------------------------------------------------------------

local isEpsilonWoW = false
local function epsiCheck()
	isEpsilonWoW = (string.match(_G.GetCVar("portal"), "epsilonwow.net")
		or string.match(_G.GetCVar("portal"), "5.199.135.151")) and true or false;
end

-------------------------------------------------------------------------------
--- Main Frame Pre-Def
-------------------------------------------------------------------------------

ChatBubbleInterfaceOptions = {};
ChatBubbleInterfaceOptions.panel = CreateFrame("Frame", "ChatBubbleInterfaceOptionsPanel", UIParent);
ChatBubbleInterfaceOptions.panel.name = "ChatBubble";

local mainPanel = ChatBubbleInterfaceOptions.panel


-------------------------------------------------------------------------------
-- UI Option Handler Functions
-------------------------------------------------------------------------------

local function disableOptions(toggle)
	if toggle == true then
		for k, v in ipairs(supportedChatTypes) do
			local _holder = mainPanel.chatToggles[v.key]
			_holder.checkButton:Disable()
			_holder.inputBox:SetTextColor(0.5, 0.5, 0.5, 1)
			_holder.inputBox:Disable()
			_holder.presetDropDown.Button:Disable()
			_holder.defaultButton:Disable()
			mainPanel.CBNameToggleOption:Disable()
			mainPanel.CBChatToggleLinks:Disable()
			mainPanel.CBToggleDiverse:Disable()
		end
		if chatBubbleOptions["debug"] then
			cprint("Main Addon is not enabled, disabled options")
		end
	else
		for k, v in ipairs(supportedChatTypes) do
			local _holder = mainPanel.chatToggles[v.key]
			_holder.checkButton:Enable()
			_holder.inputBox:SetTextColor(1, 1, 1, 1)
			_holder.inputBox:Enable()
			_holder.presetDropDown.Button:Enable()
			_holder.defaultButton:Enable()
			mainPanel.CBNameToggleOption:Enable()
			mainPanel.CBChatToggleLinks:Enable()
			mainPanel.CBToggleDiverse:Enable()
		end
		if chatBubbleOptions["debug"] then
			cprint("Main Addon re-enabled, enabled options")
		end
	end
end

local function updateCBInterfaceOptions()
	if chatBubbleOptions["enabled"] == true then mainPanel.CBMainToggleOption:SetChecked(true) else mainPanel.CBMainToggleOption:SetChecked(false) end
	if chatBubbleOptions["debug"] == true then mainPanel.CBDebugToggleOption:SetChecked(true) else mainPanel.CBDebugToggleOption:SetChecked(false) end
	if chatBubbleOptions["nametag"] == true then mainPanel.CBNameToggleOption:SetChecked(true) else mainPanel.CBNameToggleOption:SetChecked(false) end
	if chatBubbleOptions["diverseAura"] then mainPanel.CBToggleDiverse:SetChecked(false) else mainPanel.CBToggleDiverse:SetChecked(true) end
	if chatBubbleOptions.CBICChats["LINKS"] then mainPanel.CBChatToggleLinks:SetChecked(true) else mainPanel.CBChatToggleLinks:SetChecked(false) end

	for k, v in ipairs(supportedChatTypes) do
		if chatBubbleOptions.CBICChats[v.key] then
			mainPanel.chatToggles[v.key].checkButton:SetChecked(true)
			--_G["CBChatToggle" .. v]:SetChecked(true)
		else
			mainPanel.chatToggles[v.key].checkButton:SetChecked(false)
			--_G["CBChatToggle" .. v]:SetChecked(false)
		end
	end
end

-------------------------------------------------------------------------------
-- Login Handle / Start-up Initialization / Saved Variables
-------------------------------------------------------------------------------

local currentVersion = GetAddOnMetadata("ChatBubble", "Version")
local author = GetAddOnMetadata("ChatBubble", "Author")
local isTyping = false
local lastSpellType

local function initializeSavedVars()
	if chatBubbleOptions["enabled"] == nil then
		chatBubbleOptions["enabled"] = true
	end
	if chatBubbleOptions["diverseAura"] == nil then
		chatBubbleOptions["diverseAura"] = true
	end
	if chatBubbleOptions["debug"] == nil then
		chatBubbleOptions["debug"] = false
	end
	if chatBubbleOptions["nametag"] == nil then
		chatBubbleOptions["nametag"] = true
	end

	newSetDefaultSpells() -- Separate it to keep it a bit neater / Then make sure we've initialized each chat type, set to default if not

	if chatBubbleOptions.CBICChats == nil or chatBubbleOptions.CBICChats == "" then chatBubbleOptions.CBICChats = {} end
	if chatBubbleOptions.CBICChats["SAY"] ~= true and chatBubbleOptions.CBICChats["SAY"] ~= false then chatBubbleOptions.CBICChats["SAY"] = true end
	if chatBubbleOptions.CBICChats["YELL"] ~= true and chatBubbleOptions.CBICChats["YELL"] ~= false then chatBubbleOptions.CBICChats["YELL"] = true end
	if chatBubbleOptions.CBICChats["EMOTE"] ~= true and chatBubbleOptions.CBICChats["EMOTE"] ~= false then chatBubbleOptions.CBICChats["EMOTE"] = true end
	if chatBubbleOptions.CBICChats["GUILD"] ~= true and chatBubbleOptions.CBICChats["GUILD"] ~= false then chatBubbleOptions.CBICChats["GUILD"] = false end
	if chatBubbleOptions.CBICChats["WHISPER"] ~= true and chatBubbleOptions.CBICChats["WHISPER"] ~= false then chatBubbleOptions.CBICChats["WHISPER"] = false end
	if chatBubbleOptions.CBICChats["PARTY"] ~= true and chatBubbleOptions.CBICChats["PARTY"] ~= false then chatBubbleOptions.CBICChats["PARTY"] = false end
	if chatBubbleOptions.CBICChats["RAID"] ~= true and chatBubbleOptions.CBICChats["RAID"] ~= false then chatBubbleOptions.CBICChats["RAID"] = false end
	if chatBubbleOptions.CBICChats["CHANNEL"] ~= true and chatBubbleOptions.CBICChats["CHANNEL"] ~= false then chatBubbleOptions.CBICChats["CHANNEL"] = false end
	if chatBubbleOptions.CBICChats["COMMANDS"] ~= true and chatBubbleOptions.CBICChats["COMMANDS"] ~= false then chatBubbleOptions.CBICChats["COMMANDS"] = false end
	if chatBubbleOptions.CBICChats["OOC"] ~= true and chatBubbleOptions.CBICChats["OOC"] ~= false then chatBubbleOptions.CBICChats["OOC"] = false end
	if chatBubbleOptions.CBICChats["LINKS"] ~= true and chatBubbleOptions.CBICChats["LINKS"] ~= false then chatBubbleOptions.CBICChats["LINKS"] = false end
	if chatBubbleOptions.CBICChats["NPC_SAY"] ~= true and chatBubbleOptions.CBICChats["NPC_SAY"] ~= false then chatBubbleOptions.CBICChats["NPC_SAY"] = false end
	if chatBubbleOptions.CBICChats["NPC_EMOTE"] ~= true and chatBubbleOptions.CBICChats["NPC_EMOTE"] ~= false then chatBubbleOptions.CBICChats["NPC_EMOTE"] = false end
	if chatBubbleOptions.CBICChats["NPC_YELL"] ~= true and chatBubbleOptions.CBICChats["NPC_YELL"] ~= false then chatBubbleOptions.CBICChats["NPC_YELL"] = false end
end

-------------------------------------------------------------------------------
-- Main / ChatFrameEditBox Focus Detect / Typing Checks
-------------------------------------------------------------------------------

local CBIllegalFirstChar = {}
CBIllegalFirstChar.Commands = { ["."] = true, ["!"] = true, ["?"] = true, ["/"] = true }
CBIllegalFirstChar.OOC = { ["("] = true }
local CBIllegalText = { "|H", "|h", "MogIt:%d*" }

local function handleApplyingActionID(chatType, id, applyToSelf)
	local selfStr = ""
	if applyToSelf then selfStr = " self" end
	local isNPC = chatType:find("^NPC")

	-- Early exit for ID 0, technically already fails below but this saves the checks.
	local _idNum = tonumber(id)
	local _idString = tostring(id)
	if _idNum and (_idNum == 0) then return end

	if isNPC then
		-- Early exit if no target, or target is player
		if not UnitExists("target") or UnitIsPlayer("target") then return end
	end


	-- AnimKit (starts with *)
	if _idString:find("^*") then
		cmd("mod animkit " .. (id):gsub("^%*", "") .. selfStr)
		if chatBubbleOptions["debug"] then
			cprint("" .. chatType .. " cast using AnimKit " .. id)
		end

		-- Spell (Positive Number)
	elseif _idNum > 0 then
		local comm = isNPC and "npc set aura " or "aura "
		cmd(comm .. id .. selfStr)
		if chatBubbleOptions["debug"] then
			cprint("" .. chatType .. " cast using Spell " .. id)
		end

		-- Emote (Negative Number)
	elseif _idNum < 0 then --if less than zero (negative) then it's an emote
		local comm = isNPC and "npc emote " or "mod stand "
		cmd(comm .. math.abs(id))
		if chatBubbleOptions["debug"] then
			cprint("" .. chatType .. " cast using Emote " .. math.abs(id))
		end
	end
end

local function stopTyping()
	if isTyping then
		server.send("TYPING", "2") -- this technically should be within an "if chatBubbleOptions["nametag"] == true then" statement, however it's not just incase somehow they turn off nametag setting while typing, much easier this way than checking if that happened lol
		if chatBubbleOptions["debug"] then
			cprint("Hiding <Typing> indicator")
		end

		local selfStr = " self"

		if supportedChatTypes_map[lastSpellType].notSelf then selfStr = "" end
		local isNPC = lastSpellType:find("^NPC")
		local unauraComm = isNPC and "npc set unaura " or "unaura "
		local unemoteComm = isNPC and "npc emote 0" or "mod stand 0"

		if isNPC and ((not UnitExists("target")) or UnitIsPlayer("target")) then return end -- Early escape if isNPC but no NPC selected

		if chatBubbleOptions["diverseAura"] then
			if chatBubbleOptions.ChatSpells[lastSpellType] then
				if not tonumber(chatBubbleOptions.ChatSpells[lastSpellType]) then
					-- not a number, handle the alternatives. For now, there's no way to undo an animkit, so nothing to do.
				elseif tonumber(chatBubbleOptions.ChatSpells[lastSpellType]) > 0 then
					cmd(unauraComm .. chatBubbleOptions.ChatSpells[lastSpellType] .. selfStr)
				elseif tonumber(chatBubbleOptions.ChatSpells[lastSpellType]) < 0 then
					cmd(unemoteComm)
				end
			end
		else
			if chatBubbleOptions.ChatSpells["SAY"] then
				if tonumber(chatBubbleOptions.ChatSpells["SAY"]) > 0 then
					cmd(unauraComm .. chatBubbleOptions.ChatSpells["SAY"] .. selfStr)
				elseif tonumber(chatBubbleOptions.ChatSpells["SAY"]) < 0 then
					cmd(unemoteComm)
				end
			end
		end
		if chatBubbleOptions["debug"] then
			cprint(lastSpellType .. " Finished and Removed")
		end
		isTyping = false
	end
end

local function startTyping(chatType)
	local _origChatType = chatType
	local _normalizedChatType = chatBubbleOptions["diverseAura"] and chatType or "SAY"

	if isTyping and chatType == lastSpellType then
		-- Already typing in this type, don't do anything
		return
	elseif isTyping and chatType ~= lastSpellType then
		-- Was already typing, but now a different type. Remove our previous startTyping first
		stopTyping()
	end

	-- Ensure Self if needed, or not
	local isSelf = true
	if supportedChatTypes_map[_origChatType].notSelf then isSelf = false end
	if supportedChatTypes_map[_origChatType].requireDM and not C_Epsilon.IsDM then return end

	-- Handle the nameplate <Typing> tag
	if chatBubbleOptions["nametag"] == true then
		server.send("TYPING", "1")
		if chatBubbleOptions["debug"] then
			cprint("Showing <Typing> indicator")
		end
	end

	local actionID = chatBubbleOptions.ChatSpells[_normalizedChatType]
	if actionID then
		handleApplyingActionID(chatType, actionID, isSelf)
	end

	lastSpellType = chatType
	isTyping = true
end

local function CheckForLinks(text)
	if not chatBubbleOptions.CBICChats["LINKS"] then
		for _, v in pairs(CBIllegalText) do
			if string.match(text, v) ~= nil then
				return false
			else
				return true
			end
		end
	else
		return true
	end
end

local function CheckForIllegalFirstChar(text, _type)
	if _type == "commands" then
		if chatBubbleOptions.CBICChats["COMMANDS"] then
			return true
		elseif CBIllegalFirstChar.Commands[string.sub(text, 1, 1)] then
			local charTwo = strlower(strsub(text, 2, 2));
			--if (charTwo == " ") or (charTwo == ".") or (charTwo == "!") or (charTwo == "?") or (charTwo == "/") then
			if (charTwo == " ") or CBIllegalFirstChar.Commands[charTwo] then
				return true
			else
				return false
			end
		else
			return true
		end
	end
	if _type == "ooc" then
		if chatBubbleOptions.CBICChats["OOC"] then
			return true
		elseif not chatBubbleOptions.CBICChats["OOC"] then
			if CBIllegalFirstChar.OOC[string.sub(text, 1, 1)] then
				return false
			else
				return true
			end
		end
	end
end

for i = 1, NUM_CHAT_WINDOWS do
	local chat = _G["ChatFrame" .. i .. "EditBox"]
	if chat then
		chat:HookScript("OnEditFocusGained", function(self)
			epsiCheck()
		end)
		chat:HookScript("OnTextChanged", function(self)
			local text = chat:GetText()
			local _chatType = chat:GetAttribute("chatType")

			if (not isEpsilonWoW) or (not chatBubbleOptions["enabled"]) or text:len() < 2 then
				stopTyping()
				return
			end

			-- Check for Command Overrides
			local isCommandOverride
			for command_type, pattern in pairs(command_chat_overrides) do
				if text:find(pattern) then
					isCommandOverride = true
					_chatType = command_type
					break
				end
			end

			-- Early Exit if this _chatType is disabled, or OOC found & disabled, or link found & disabled
			if (not chatBubbleOptions.CBICChats[_chatType]) or (not CheckForIllegalFirstChar(text, "ooc")) or (not CheckForLinks(text)) then
				stopTyping()
				return
			end

			if CBIllegalFirstChar.OOC[string.sub(text, 1, 1)] then
				startTyping("OOC")
			elseif CBIllegalFirstChar.Commands[string.sub(text, 1, 1)] and (not isCommandOverride) then
				-- Starts with a command character, and not a command override, check if we are allowed to show it
				local charTwo = strlower(strsub(text, 2, 2));
				if (charTwo == " ") or (charTwo == ".") or (charTwo == "!") or (charTwo == "?") or (charTwo == "/") then
					-- not a valid command, will be standard text, continue as that _chatType
					startTyping(_chatType)
				elseif chatBubbleOptions.CBICChats["COMMANDS"] then
					-- was a valid command, and commands is enabled
					startTyping("COMMANDS")
				end
			else
				startTyping(_chatType)
			end
		end)

		chat:HookScript("OnEnterPressed", function(self)
			server.send("TYPING", "2")
			if chatBubbleOptions["debug"] then
				cprint("Hiding <Typing> indicator")
			end
			--C_Timer.NewTimer(0.7, function() -- Why where these on delays? I can't remember.
			stopTyping();
			server.send("TYPING", "2")
			if chatBubbleOptions["debug"] then
				cprint("Hiding <Typing> indicator")
			end
			--end)
		end)

		chat:HookScript("OnEditFocusLost", function(self)
			if chat:GetText() == "" then
				server.send("TYPING", "2")
				if chatBubbleOptions["debug"] then
					cprint("Hiding <Typing> indicator")
				end
				--C_Timer.NewTimer(0.7, function()
				stopTyping();
				server.send("TYPING", "2")
				if chatBubbleOptions["debug"] then
					cprint("Hiding <Typing> indicator")
				end
				--end)
			end
		end)
	end
end

-------------------------------------------------------------------------------
-- Interface Options - Addon
-------------------------------------------------------------------------------

local function createChatBubbleInterfaceOptions()
	local ChatBubbleInterfaceOptionsHeader = ChatBubbleInterfaceOptions.panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	ChatBubbleInterfaceOptionsHeader:SetPoint("TOPLEFT", 15, -15)
	ChatBubbleInterfaceOptionsHeader:SetText(GetAddOnMetadata("ChatBubble", "Title") ..
		" v" .. currentVersion .. " by " .. author)

	local ChatBubbleInterfaceOptionsSpellList = ChatBubbleInterfaceOptions.panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLeft")
	ChatBubbleInterfaceOptionsSpellList:SetPoint("BOTTOMLEFT", 25, 5)
	ChatBubbleInterfaceOptionsSpellList:SetText("Action IDs above can be either a Spell, Emote, or AnimKit" ..
		"\n - Spells: Enter the spell ID as a positive number (i.e., 211565)" ..
		"\n - Emotes: enter the emote/anim ID as a negative number (i.e., -396)" ..
		"\n - AnimKits: enter the AnimKit ID with a * at the start (i.e., *593)")


	local npcTypeHint = ChatBubbleInterfaceOptions.panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLeft")
	npcTypeHint:SetPoint("BOTTOMLEFT", 25, 60)
	npcTypeHint:SetText("*NPC Options apply to the target NPC when using that command.")

	--Main Addon Toggle
	local ChatBubbleInterfaceOptionsFullToggle = CreateFrame("CHECKBUTTON", nil, ChatBubbleInterfaceOptions.panel, "InterfaceOptionsCheckButtonTemplate")
	mainPanel.CBMainToggleOption = ChatBubbleInterfaceOptionsFullToggle

	ChatBubbleInterfaceOptionsFullToggle:SetPoint("TOPLEFT", 20, -40)
	ChatBubbleInterfaceOptionsFullToggle.Text:SetText("Enable ChatBubbles Addon")
	ChatBubbleInterfaceOptionsFullToggle:SetScript("OnShow", function(self)
		if chatBubbleOptions["enabled"] == true then
			self:SetChecked(true)
		else
			self:SetChecked(false)
			disableOptions(true)
		end
	end)
	ChatBubbleInterfaceOptionsFullToggle:SetScript("OnClick", function(self)
		chatBubbleOptions["enabled"] = not chatBubbleOptions["enabled"]
		disableOptions(not self:GetChecked())
		if chatBubbleOptions["debug"] then
			cprint("Toggled Entire Addon: " .. tostring(self:GetChecked()))
		end
	end)
	ChatBubbleInterfaceOptionsFullToggle:SetScript("OnEnter", function()
		GameTooltip:SetOwner(ChatBubbleInterfaceOptionsFullToggle, "ANCHOR_LEFT")
		ChatBubbleInterfaceOptionsFullToggle.Timer = C_Timer.NewTimer(0.7, function()
			GameTooltip:SetText("Toggle the entire functionality of the addon on / off.", nil, nil, nil, nil, true)
			GameTooltip:Show()
		end)
	end)
	ChatBubbleInterfaceOptionsFullToggle:SetScript("OnLeave", function()
		GameTooltip_Hide()
		ChatBubbleInterfaceOptionsFullToggle.Timer:Cancel()
	end)

	--Typing Flag Toggle
	local ChatBubbleInterfaceOptionsNametagToggle = CreateFrame("CHECKBUTTON", nil, ChatBubbleInterfaceOptions.panel, "InterfaceOptionsCheckButtonTemplate")
	mainPanel.CBNameToggleOption = ChatBubbleInterfaceOptionsNametagToggle

	mainPanel.CBNameToggleOption:SetPoint("TOPLEFT", 20, -60)
	mainPanel.CBNameToggleOption.Text:SetText("Enable <Typing> Indicator")
	if not server then
		mainPanel.CBNameToggleOption:Disable(); mainPanel.CBNameToggleOption:SetMotionScriptsWhileDisabled(true)
	end
	mainPanel.CBNameToggleOption:SetScript("OnShow", function(self)
		if chatBubbleOptions["nametag"] == true then
			self:SetChecked(true)
		else
			self:SetChecked(false)
		end
	end)
	mainPanel.CBNameToggleOption:SetScript("OnClick", function(self)
		chatBubbleOptions["nametag"] = not chatBubbleOptions["nametag"]
		if chatBubbleOptions["debug"] then
			cprint("Toggled <Typing> Indicator")
		end
	end)
	mainPanel.CBNameToggleOption:SetScript("OnEnter", function()
		GameTooltip:SetOwner(mainPanel.CBNameToggleOption, "ANCHOR_LEFT")
		mainPanel.CBNameToggleOption.Timer = C_Timer.NewTimer(0.7, function()
			if not server then
				GameTooltip:SetText(
					"<Typing> Indicator support requires the Epsilon / EpsilonLib AddOn to function. Please ensure to enable the Epsilon AddOns for the full experience.",
					nil, nil, nil, nil, true)
				GameTooltip:Show()
				return
			end
			GameTooltip:SetText(
				"Toggle the <Typing> indicator on your overhead Name Tag.\n\nThis will only show when a chat type is enabled. If you want <Typing> only, set your spell/emote to '0' and keep that chat type enabled.",
				nil, nil, nil, nil, true)
			GameTooltip:Show()
		end)
	end)
	mainPanel.CBNameToggleOption:SetScript("OnLeave", function()
		GameTooltip_Hide()
		mainPanel.CBNameToggleOption.Timer:Cancel()
	end)



	local cbLinksToggle = CreateFrame("CHECKBUTTON", nil, ChatBubbleInterfaceOptions.panel, "InterfaceOptionsCheckButtonTemplate")
	mainPanel.CBChatToggleLinks = cbLinksToggle

	cbLinksToggle:SetPoint("TOPLEFT", 250, -40)
	mainPanel.CBChatToggleLinks.Text:SetText("Allow Links")
	cbLinksToggle:SetScript("OnClick", function()
		chatBubbleOptions.CBICChats["LINKS"] = not chatBubbleOptions.CBICChats["LINKS"]
	end)
	cbLinksToggle:SetScript("OnEnter", function()
		GameTooltip:SetOwner(cbLinksToggle, "ANCHOR_LEFT")
		cbLinksToggle.Timer = C_Timer.NewTimer(0.7, function()
			GameTooltip:SetText(
				"When enabled, ChatBubbles will still react to typing if there's an Item, Object, or Spell linked in chat.\n\nDefault: Disabled.",
				nil, nil, nil, nil, true)
			GameTooltip:Show()
		end)
	end)
	cbLinksToggle:SetScript("OnLeave", function()
		GameTooltip_Hide()
		cbLinksToggle.Timer:Cancel()
	end)

	local cbDiverseToggle = CreateFrame("CHECKBUTTON", nil, ChatBubbleInterfaceOptions.panel, "InterfaceOptionsCheckButtonTemplate")
	mainPanel.CBToggleDiverse = cbDiverseToggle

	cbDiverseToggle:SetPoint("TOPLEFT", 400, -40)
	mainPanel.CBToggleDiverse.Text:SetText("Use 'Say' Spell for All")
	cbDiverseToggle:SetScript("OnClick", function()
		chatBubbleOptions["diverseAura"] = not chatBubbleOptions["diverseAura"]
		if chatBubbleOptions["debug"] then
			cprint("Diverse Aura's Toggled to: " ..
				tostring(chatBubbleOptions["diverseAura"]) .. " (This is Backwards from Checkbox, shh)")
		end
	end)
	cbDiverseToggle:SetScript("OnEnter", function()
		GameTooltip:SetOwner(cbDiverseToggle, "ANCHOR_LEFT")
		cbDiverseToggle.Timer = C_Timer.NewTimer(0.7, function()
			GameTooltip:SetText(
				"When enabled, every chat type will use the 'Say' spell or emote, ignoring their own.\n\nDefault: Disabled.",
				nil, nil, nil, nil, true)
			GameTooltip:Show()
		end)
	end)
	cbDiverseToggle:SetScript("OnLeave", function()
		GameTooltip_Hide()
		cbDiverseToggle.Timer:Cancel()
	end)

	local ChatBubbleInterfaceOptionsDebug = CreateFrame("CHECKBUTTON", nil, ChatBubbleInterfaceOptions.panel, "OptionsSmallCheckButtonTemplate")
	mainPanel.CBDebugToggleOption = ChatBubbleInterfaceOptionsDebug

	ChatBubbleInterfaceOptionsDebug:SetPoint("BOTTOMRIGHT", 0, 0)
	ChatBubbleInterfaceOptionsDebug:SetHitRectInsets(-35, 0, 0, 0)
	ChatBubbleInterfaceOptionsDebug.Text:SetTextColor(1, 1, 1, 1)
	ChatBubbleInterfaceOptionsDebug.Text:SetText("Debug")
	ChatBubbleInterfaceOptionsDebug.Text:SetPoint("LEFT", -30, 0)
	ChatBubbleInterfaceOptionsDebug:SetScript("OnShow", function(self)
		updateCBInterfaceOptions()
	end)
	ChatBubbleInterfaceOptionsDebug:SetScript("OnClick", function(self)
		chatBubbleOptions["debug"] = not chatBubbleOptions["debug"]
		if chatBubbleOptions["debug"] then
			cprint("Toggled Debug (VERBOSE) Mode")
		end
	end)

	mainPanel.chatToggles = {}
	for k, v in ipairs(supportedChatTypes) do
		-- Create holding table for the pieces
		mainPanel.chatToggles[v.key] = {}
		local _holder = mainPanel.chatToggles[v.key]

		local checkButton = CreateFrame("CHECKBUTTON", nil, ChatBubbleInterfaceOptions.panel, "InterfaceOptionsCheckButtonTemplate")
		_holder.checkButton = checkButton

		checkButton:SetPoint("TOPLEFT", 20, -80 - tonumber(k) * 30)
		checkButton:SetAttribute("chatType", v.key)
		checkButton:SetScript("OnClick", function()
			chatBubbleOptions.CBICChats[v.key] = not chatBubbleOptions.CBICChats[v.key]
			if chatBubbleOptions["debug"] then
				cprint("Toggled " .. v.key .. " Chat Bubble " .. (chatBubbleOptions.CBICChats[v.key] and "on." or "off."))
			end
		end)
		checkButton.Text:SetText("  " .. v.display)
		checkButton.Text:SetWidth(100)

		if v.tooltip then
			checkButton:SetScript("OnEnter", function()
				GameTooltip:SetOwner(checkButton, "ANCHOR_LEFT")
				checkButton.Timer = C_Timer.NewTimer(0.1, function()
					GameTooltip:SetText(v.tooltip, nil, nil, nil, nil, true)
					GameTooltip:Show()
				end)
			end)
			checkButton:SetScript("OnLeave", function()
				GameTooltip_Hide()
				checkButton.Timer:Cancel()
			end)
		end

		local inputBox = CreateFrame("EditBox", nil, ChatBubbleInterfaceOptions.panel, "InputBoxTemplate")
		_holder.inputBox = inputBox

		inputBox:SetAutoFocus(false)
		inputBox:SetSize(80, 23)
		inputBox:SetPoint("TOPLEFT", 160, -80 - tonumber(k) * 30)
		inputBox:SetAttribute("chatType", v.key)
		inputBox:SetText(chatBubbleOptions.ChatSpells[v.key])
		inputBox:SetCursorPosition(0)
		inputBox:SetScript("OnEditFocusLost", function()
			chatBubbleOptions.ChatSpells[v.key] = inputBox:GetText()
			if chatBubbleOptions["debug"] then
				cprint("Chat " .. v.key .. " Action set to " .. inputBox:GetText())
			end
		end)
		inputBox:SetScript("OnTextChanged", function()
			local _text = inputBox:GetText()
			if _text == _text:match("%d+") or _text == _text:match("-%d+") or _text == _text:match("^%*%d+") then
				inputBox:SetTextColor(255, 255, 255, 1)
			elseif _text == "" then
				inputBox:SetTextColor(255, 255, 255, 1)
			elseif _text:find("%a") then
				inputBox:SetText(_text:gsub("%a", ""))
			else
				inputBox:SetTextColor(1, 0, 0, 1)
			end
		end)
		inputBox:SetScript("OnEnter", function()
			GameTooltip:SetOwner(inputBox, "ANCHOR_LEFT")
			inputBox.Timer = C_Timer.NewTimer(0.35, function()
				GameTooltip:SetText(
					"Set the Spell, Emote, or AnimKit you with to use." ..
					"\n\r - Spells: Enter the spell ID as a positive number." ..
					"\n\r - Emotes: Enter the emote ID as a negative number." ..
					"\n\r - AnimKit: Enter the AnimKit ID with a * at the start." ..
					"\n\rSet to 0 to disable spell/emote/animkit and only use <Typing> if enabled.",
					nil, nil, nil, nil, true)
				GameTooltip:Show()
			end)
		end)
		inputBox:SetScript("OnLeave", function()
			GameTooltip_Hide()
			inputBox.Timer:Cancel()
		end)

		local defaultButton = CreateFrame("Button", nil, ChatBubbleInterfaceOptions.panel, "OptionsButtonTemplate")
		_holder.defaultButton = defaultButton

		defaultButton:SetPoint("TOPLEFT", 410, -80 - tonumber(k) * 30)
		defaultButton:SetSize(120, 23)
		defaultButton:SetAttribute("chatType", v.key)
		defaultButton:SetScript("OnClick", function()
			_holder.inputBox:SetText(defaultChatSpells[v.key])
			chatBubbleOptions.ChatSpells[v.key] = defaultChatSpells[v.key]
			if chatBubbleOptions["debug"] then
				cprint("Reset " .. v.key .. " to default spell")
			end
		end)
		defaultButton.Text:SetText("Default (" .. defaultChatSpells[v.key] .. ")")

		local presetDropDown = CreateFrame("Frame", nil, ChatBubbleInterfaceOptions.panel, "UIDropDownMenuTemplate")
		_holder.presetDropDown = presetDropDown

		presetDropDown:SetPoint("TOPLEFT", 250, -80 - tonumber(k) * 30 + 2) -- DropDown Boxes are naturally offset by a few pixels down, +2 to fix it
		presetDropDown:SetAttribute("chatType", v.key)
		local function OnClick(self)
			UIDropDownMenu_SetSelectedID(presetDropDown, self:GetID())
			if self.value ~= "" then
				_holder.inputBox:SetText(self.value)
				chatBubbleOptions.ChatSpells[v.key] = tonumber(self.value) or self.value
				if chatBubbleOptions["debug"] then
					cprint(v.key .. " set to " .. self.value)
				end
			end
		end
		local function initialize(self, level)
			local info = UIDropDownMenu_CreateInfo()
			for k, v in ipairs(presetSpells) do
				info = UIDropDownMenu_CreateInfo()
				info.text = presetSpellsName[v]
				info.value = v
				info.func = OnClick
				UIDropDownMenu_AddButton(info, level)
			end
		end
		UIDropDownMenu_Initialize(presetDropDown, initialize)
		UIDropDownMenu_SetWidth(presetDropDown, 100);
		UIDropDownMenu_SetButtonWidth(presetDropDown, 124)
		UIDropDownMenu_SetSelectedID(presetDropDown, 0)
		UIDropDownMenu_JustifyText(presetDropDown, "LEFT")
		UIDropDownMenu_SetText(presetDropDown, "Select a Preset")
	end

	local titles = {}
	mainPanel.titles = titles
	local _toggleChatTypeTitle = ChatBubbleInterfaceOptions.panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLeft")
	_toggleChatTypeTitle:SetPoint("BOTTOMLEFT", mainPanel.chatToggles["SAY"].checkButton, "TOPLEFT", 0, 8)
	_toggleChatTypeTitle:SetText("Toggle Chat Type")
	titles.toggle = _toggleChatTypeTitle

	local _actionInputTitle = ChatBubbleInterfaceOptions.panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLeft")
	_actionInputTitle:SetPoint("TOP", mainPanel.chatToggles["SAY"].inputBox, "TOP", -5, 20)
	_actionInputTitle:SetText("'Action' ID")
	titles.actionID = _actionInputTitle

	local _presetSelectionTitle = ChatBubbleInterfaceOptions.panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLeft")
	_presetSelectionTitle:SetPoint("TOP", mainPanel.chatToggles["SAY"].presetDropDown, "TOP", 0, 18)
	_presetSelectionTitle:SetText("Preset Spells")
	titles.preset = _presetSelectionTitle

	local _defaultButtonTitle = ChatBubbleInterfaceOptions.panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLeft")
	_defaultButtonTitle:SetPoint("TOP", mainPanel.chatToggles["SAY"].defaultButton, "TOP", 0, 20)
	_defaultButtonTitle:SetText("Reset to Default")
	titles.default = _defaultButtonTitle

	InterfaceOptions_AddCategory(ChatBubbleInterfaceOptions.panel);
	updateCBInterfaceOptions() -- Call this because OnShow isn't triggered first time, and neither is OnLoad for some reason, so lets just update them manually
end

-------------------------------------------------------------------------------
-- Initialize on Login
-------------------------------------------------------------------------------

local loginHandle = CreateFrame("frame", "loginhandle");
loginHandle:RegisterEvent("PLAYER_LOGIN");
loginHandle:RegisterEvent("PLAYER_ENTERING_WORLD");
loginHandle:SetScript("OnEvent", function(self, event)
	if event == "PLAYER_LOGIN" then
		initializeSavedVars();
		epsiCheck();
		createChatBubbleInterfaceOptions();
		if chatBubbleOptions["debug"] then
			cprint("OnEvent PLAYER_LOGIN Fired / Initialized Login")
		end
	elseif event == "PLAYER_ENTERING_WORLD" then
		clearAnyChatSpells();
		if chatBubbleOptions["debug"] then
			cprint("OnEvent PLAYER_ENTERING_WORLD Fired")
		end
		if not chatBubbleOptions["enabled"] then
			disableOptions(true)
		end
	end
end);

-------------------------------------------------------------------------------
-- Version / Help / Toggle
-------------------------------------------------------------------------------

SLASH_CCCBHELP1, SLASH_CCCBHELP2 = '/chatbubble', '/cb'; -- 3.
function SlashCmdList.CCCBHELP(msg, editbox)             -- 4.
	if isEpsilonWoW == false then
		cprint("ChatBubbles is disabled, as it has detected you are not on a compatible server.")
	elseif chatBubbleOptions["debug"] and msg == "debug" then
		cprint("ConvenientCommands: ChatBubble | DEBUG LIST")
		cprint("currentVersion: " .. currentVersion)
		cprint("isEpsilonWoW: " .. tostring(isEpsilonWoW))
	else
		InterfaceOptionsFrame_OpenToCategory("ChatBubble");
		InterfaceOptionsFrame_OpenToCategory("ChatBubble");
	end
end
