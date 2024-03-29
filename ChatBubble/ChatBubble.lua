-------------------------------------------------------------------------------
-- Simple Chat Functions
-------------------------------------------------------------------------------

local utils = Epsilon.utils
local messages = utils.messages
local server = utils.server
local tabs = utils.tabs

local main = Epsilon.main

local function cmd(text)
  SendChatMessage("."..text, "GUILD");
end

local function msg(text)
  SendChatMessage(""..text, "SAY");
end

local function cprint(text)
	local line = strmatch(debugstack(2),":(%d+):")
	if line then
		print("|cffFFD700 CBDEBUG "..line..": "..text.."|r")
	else
		print("|cffFFD700 CBDEBUG @ERROR: "..text.."|r")
		print(debugstack(2))
	end
end

-------------------------------------------------------------------------------
-- Login Handle / Start-up Initialization / Saved Variables
-------------------------------------------------------------------------------

chatBubbleOptions = {}
local currentVersion = GetAddOnMetadata("ChatBubble", "Version")
local author = GetAddOnMetadata("ChatBubble", "Author")
local isTyping = false
local isEpsilonWoW = false

local function InitializeSavedVars()
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
	if chatBubbleOptions.CBICChats["SAY"] ~= true and chatBubbleOptions.CBICChats["SAY"] ~= false then chatBubbleOptions.CBICChats["SAY"]=true end
	if chatBubbleOptions.CBICChats["YELL"] ~= true and chatBubbleOptions.CBICChats["YELL"] ~= false then chatBubbleOptions.CBICChats["YELL"]=true end
	if chatBubbleOptions.CBICChats["EMOTE"] ~= true and chatBubbleOptions.CBICChats["EMOTE"] ~= false then chatBubbleOptions.CBICChats["EMOTE"]=true end
	if chatBubbleOptions.CBICChats["GUILD"] ~= true and chatBubbleOptions.CBICChats["GUILD"] ~= false then chatBubbleOptions.CBICChats["GUILD"]=false end
	if chatBubbleOptions.CBICChats["WHISPER"] ~= true and chatBubbleOptions.CBICChats["WHISPER"] ~= false then chatBubbleOptions.CBICChats["WHISPER"]=false end
	if chatBubbleOptions.CBICChats["PARTY"] ~= true and chatBubbleOptions.CBICChats["PARTY"] ~= false then chatBubbleOptions.CBICChats["PARTY"]=false end
	if chatBubbleOptions.CBICChats["RAID"] ~= true and chatBubbleOptions.CBICChats["RAID"] ~= false then chatBubbleOptions.CBICChats["RAID"]=false end
	if chatBubbleOptions.CBICChats["CHANNEL"] ~= true and chatBubbleOptions.CBICChats["CHANNEL"] ~= false then chatBubbleOptions.CBICChats["CHANNEL"]=false end
	if chatBubbleOptions.CBICChats["COMMANDS"] ~= true and chatBubbleOptions.CBICChats["COMMANDS"] ~= false then chatBubbleOptions.CBICChats["COMMANDS"]=false end
	if chatBubbleOptions.CBICChats["OOC"] ~= true and chatBubbleOptions.CBICChats["OOC"] ~= false then chatBubbleOptions.CBICChats["OOC"]=false end
	if chatBubbleOptions.CBICChats["LINKS"] ~= true and chatBubbleOptions.CBICChats["LINKS"] ~= false then chatBubbleOptions.CBICChats["LINKS"]=false end
end

local loginhandle = CreateFrame("frame","loginhandle");
loginhandle:RegisterEvent("PLAYER_LOGIN");
loginhandle:RegisterEvent("PLAYER_ENTERING_WORLD");
loginhandle:SetScript("OnEvent", function(self, event)
	if event == "PLAYER_LOGIN" then
		InitializeSavedVars();
		epsiCheck();
		CreateChatBubbleInterfaceOptions();
		if chatBubbleOptions["debug"] then
			cprint("OnEvent PLAYER_LOGIN Fired / Initialized Login")
		end
	elseif event == "PLAYER_ENTERING_WORLD" then
		ClearAnyChatSpells();
		if chatBubbleOptions["debug"] then
			cprint("OnEvent PLAYER_ENTERING_WORLD Fired")
		end
		if not chatBubbleOptions["enabled"] then 
			DisableOptions(true)
		end
	end
end);

allowedChatTypes = {"Say", "Emote", "Yell", "Guild", "Whisper", "Party", "Raid", "Channel", "Commands", "OOC"}

defaultChatSpells = {
		["SAY"] = 211565,
		["EMOTE"] = 142677,
		["YELL"] = 90080,
		["GUILD"] = 0,
		["WHISPER"] = 0,
		["PARTY"] = 0,
		["RAID"] = 0,
		["CHANNEL"] = 0,
		["COMMANDS"] = 0,
		["OOC"] = 0
	}

function newSetDefaultSpells()
	if chatBubbleOptions.ChatSpells == nil or chatBubbleOptions.ChatSpells == "" then chatBubbleOptions.ChatSpells = {} end
	for k,v in pairs(defaultChatSpells) do
		if chatBubbleOptions.ChatSpells[k] == nil then chatBubbleOptions.ChatSpells[k] = v end
	end
end

function ClearAnyChatSpells()
	for _,v in pairs(chatBubbleOptions.ChatSpells) do
		if tonumber(v) > 0 then cmd("unaura "..v.." self") end
	end
	cmd("mod stand 0")
end

presetSpells = {"211565", "142677", "90080", "196230", "81204", "0", "-396", "-5", "-6", "-432", "-492", "-588", "-641"}
presetSpellsName = {
	["211565"] = "Spell: Chat Bubble",
	["142677"] = "Sepll: Gear",
	["90080"] = "Spell: Red '!'",
	["196230"] = "Spell: Gold '!'",
	["81204"] = "Spell: Green '!'",
	["0"] = "-- Disable Spell/Emote (<Typing> Only) --",
	["-396"] = "Emote: Talk",
	["-5"] = "Emote: Exclamation",
	["-6"] = "Emote: Question",
	["-432"] = "Emote: Working",
	["-492"] = "Emote: Reading (Map)",
	["-588"] = "Emote: Read & Talk (Map)",
	["-641"] = "Emote: Reading (Book)",
	}
	
-------------------------------------------------------------------------------
-- Securing The Addon to Epsilon (ish)
-------------------------------------------------------------------------------

function epsiCheck()
	isEpsilonWoW = (string.match(_G.GetCVar("portal"), "epsilonwow.net")
                        or string.match(_G.GetCVar("portal"), "5.199.135.151")) and true or false;
end

-------------------------------------------------------------------------------
-- Main / ChatFrameEditBox Focus Detect / Typing Checks
-------------------------------------------------------------------------------

CBIllegalFirstChar = {}
CBIllegalFirstChar.Commands = {["."]=true, ["!"]=true, ["?"]=true, ["/"]=true}
CBIllegalFirstChar.OOC = {["("]=true}
local CBIllegalText = {"|H", "|h", "MogIt:%d*"}

function startTyping(spellType)
	if not isTyping then
		if chatBubbleOptions["nametag"] == true then
			server.send("TYPING", "1")
			if chatBubbleOptions["debug"] then
				cprint("Showing <Typing> indicator")
			end
		end
		if chatBubbleOptions["diverseAura"] then
			if chatBubbleOptions.ChatSpells[spellType] then
				if tonumber(chatBubbleOptions.ChatSpells[spellType]) > 0 then --if greater than 0, it's a spell and we aura it
					cmd("aura "..chatBubbleOptions.ChatSpells[spellType].." self")
					if chatBubbleOptions["debug"] then
						cprint(""..spellType.." cast using Spell "..chatBubbleOptions.ChatSpells[spellType] )
					end
				elseif tonumber(chatBubbleOptions.ChatSpells[spellType]) < 0 then --if less than zero (negative) then it's an emote
					cmd("mod stand "..math.abs(chatBubbleOptions.ChatSpells[spellType]))
					if chatBubbleOptions["debug"] then
						cprint(""..spellType.." cast using Emote "..math.abs(chatBubbleOptions.ChatSpells[spellType]) )
					end
				end
			end
		else
			if chatBubbleOptions.ChatSpells["SAY"] then
				if tonumber(chatBubbleOptions.ChatSpells["SAY"]) > 0 then -- if greater than 0, spell
					cmd("aura "..chatBubbleOptions.ChatSpells["SAY"].." self")
					if chatBubbleOptions["debug"] then
						cprint(""..spellType.." cast using Spell "..chatBubbleOptions.ChatSpells["SAY"] )
					end
				elseif tonumber(chatBubbleOptions.ChatSpells["SAY"]) < 0 then -- if less than 0, emote
					cmd("mod stand "..math.abs(chatBubbleOptions.ChatSpells["SAY"]))
					if chatBubbleOptions["debug"] then
						cprint(""..spellType.." applied using Emote "..math.abs(chatBubbleOptions.ChatSpells["SAY"]) )
					end
				end
			end
		end
		lastSpellType = spellType
		isTyping = true
	end
end

function stopTyping()
	if isTyping then
		server.send("TYPING", "2") -- this technically should be within an "if chatBubbleOptions["nametag"] == true then" statement, however it's not just incase somehow they turn off nametag setting while typing, much easier this way than checking if that happened lol
		if chatBubbleOptions["debug"] then
			cprint("Hiding <Typing> indicator")
		end
		if chatBubbleOptions["diverseAura"] then
			if chatBubbleOptions.ChatSpells[lastSpellType] then
				if tonumber(chatBubbleOptions.ChatSpells[lastSpellType]) > 0 then
					cmd("unaura "..chatBubbleOptions.ChatSpells[lastSpellType].." self")
				elseif tonumber(chatBubbleOptions.ChatSpells[lastSpellType]) < 0 then
					cmd("mod stand 0")
				end
			end
		else
			if chatBubbleOptions.ChatSpells["SAY"] then
				if tonumber(chatBubbleOptions.ChatSpells["SAY"]) > 0 then
					cmd("unaura "..chatBubbleOptions.ChatSpells["SAY"].." self")
				elseif tonumber(chatBubbleOptions.ChatSpells["SAY"]) < 0 then
					cmd("mod stand 0")
				end
			end
		end
		if chatBubbleOptions["debug"] then
			cprint(""..lastSpellType.." Finished and Removed")
		end
		isTyping = false
	end
end

function CheckForLinks(text)
	if not chatBubbleOptions.CBICChats["LINKS"] then
		for _,v in pairs(CBIllegalText) do
			if string.match(text,v) ~= nil then
				return false
			else
				return true
			end
		end
	else return true
	end
end

function CheckForIllegalFirstChar(text,typ)
	if typ == "commands" then
		if chatBubbleOptions.CBICChats["COMMANDS"] then
			return true
		elseif not chatBubbleOptions.CBICChats["COMMANDS"] then
			if CBIllegalFirstChar.Commands[string.sub(text,1,1)] then
				local chartwo = strlower(strsub(text,2,2));
				if (chartwo == " ") or (chartwo == ".") then
					return true
				else
					return false
				end
			else
				return true
			end
		end
	end
	if typ == "ooc" then
		if chatBubbleOptions.CBICChats["OOC"] then
			return true
		elseif not chatBubbleOptions.CBICChats["OOC"] then
			if CBIllegalFirstChar.OOC[string.sub(text,1,1)] then
				return false
			else
				return true
			end
		end
	end
end

for i = 1, NUM_CHAT_WINDOWS do
    local chat = _G["ChatFrame"..i.."EditBox"]
    if chat then
		chat:HookScript("OnEditFocusGained", function(self)
			epsiCheck()
		end)
		chat:HookScript("OnTextChanged", function(self)
			local text = chat:GetText()
			if isEpsilonWoW and chatBubbleOptions["enabled"] and text:len() > 0 and chatBubbleOptions.CBICChats[chat:GetAttribute("chatType")] and CheckForIllegalFirstChar(text,"commands") and CheckForIllegalFirstChar(text,"ooc") and CheckForLinks(text) then
				if CBIllegalFirstChar.OOC[string.sub(text,1,1)] then
					startTyping("OOC")
				elseif CBIllegalFirstChar.Commands[string.sub(text,1,1)] then
					if text:len() > 2 then
						local chartwo = strlower(strsub(text,2,2));
						if (chartwo == " ") or (chartwo == ".") or (chartwo == "!") or (chartwo == "?") or (chartwo == "/") then
							startTyping(chat:GetAttribute("chatType"))
						else
							startTyping("COMMANDS")
						end
					else
						stopTyping()
					end
				else
					startTyping(chat:GetAttribute("chatType"))
				end
			else
				stopTyping()
			end
		end)

		chat:HookScript("OnEnterPressed", function(self)
			server.send("TYPING", "2")
			if chatBubbleOptions["debug"] then
				cprint("Hiding <Typing> indicator")
			end
			C_Timer.NewTimer(0.7,function()
				stopTyping();
				server.send("TYPING", "2")
				if chatBubbleOptions["debug"] then
					cprint("Hiding <Typing> indicator")
				end
				return false;
			end,1)
			

		end) 
	end
end

function DisableOptions(toggle)
	if toggle == true then
		for k,v in ipairs(allowedChatTypes) do
			_G["CBChatToggle"..v]:Disable()
			_G["CBChatSpellBox"..v]:SetTextColor(0.5,0.5,0.5,1)
			_G["CBChatSpellBox"..v]:Disable()
			_G["spellDropDownMenu"..v.."Button"]:Disable()
			_G["CBChatSpellResetButton"..v]:Disable()
			CBNameToggleOption:Disable()
			CBChatToggleLinks:Disable()
			CBToggleDiverse:Disable()
		end
		if chatBubbleOptions["debug"] then
			cprint("Main Addon is not enabled, disabled options")
		end
	else
		for k,v in ipairs(allowedChatTypes) do
			_G["CBChatToggle"..v]:Enable()
			_G["CBChatSpellBox"..v]:SetTextColor(1,1,1,1)
			_G["CBChatSpellBox"..v]:Enable()
			_G["spellDropDownMenu"..v.."Button"]:Enable()
			_G["CBChatSpellResetButton"..v]:Enable()
			CBNameToggleOption:Enable()
			CBChatToggleLinks:Enable()
			CBToggleDiverse:Enable()
		end
		if chatBubbleOptions["debug"] then
			cprint("Main Addon re-enabled, enabled options")
		end
	end
end

-------------------------------------------------------------------------------
-- Interface Options - Addon
-------------------------------------------------------------------------------

function CreateChatBubbleInterfaceOptions()
	ChatBubbleInterfaceOptions = {};
	ChatBubbleInterfaceOptions.panel = CreateFrame( "Frame", "ChatBubbleInterfaceOptionsPanel", UIParent );
	ChatBubbleInterfaceOptions.panel.name = "ChatBubble";
	
	local ChatBubbleInterfaceOptionsHeader = ChatBubbleInterfaceOptions.panel:CreateFontString("HeaderString", "OVERLAY", "GameFontNormalLarge")
	ChatBubbleInterfaceOptionsHeader:SetPoint("TOPLEFT", 15, -15)
	ChatBubbleInterfaceOptionsHeader:SetText(GetAddOnMetadata("ChatBubble", "Title").." v"..currentVersion.." by "..author)
	
	local ChatBubbleInterfaceOptionsSpellList = ChatBubbleInterfaceOptions.panel:CreateFontString("SpellList", "OVERLAY", "GameFontNormalLeft")
	ChatBubbleInterfaceOptionsSpellList:SetPoint("BOTTOMLEFT", 20, 140)
	ChatBubbleInterfaceOptionsSpellList:SetText("Spells:")
	SpellListHorizontalSpacing = 160
		local ChatBubbleInterfaceOptionsSpellListRow1 = ChatBubbleInterfaceOptions.panel:CreateFontString("SpellRow1","OVERLAY",ChatBubbleInterfaceOptionsSpellList)
		ChatBubbleInterfaceOptionsSpellListRow1:SetPoint("TOPLEFT",ChatBubbleInterfaceOptionsSpellList,"BOTTOMLEFT",9,-15)
		local ChatBubbleInterfaceOptionsSpellListRow2 = ChatBubbleInterfaceOptions.panel:CreateFontString("SpellRow2","OVERLAY",ChatBubbleInterfaceOptionsSpellListRow1)
		ChatBubbleInterfaceOptionsSpellListRow2:SetPoint("TOPLEFT",ChatBubbleInterfaceOptionsSpellListRow1,"BOTTOMLEFT",0,-25)
			local ChatBubbleInterfaceOptionsSpellListSpell1 = ChatBubbleInterfaceOptions.panel:CreateFontString("Spell1","OVERLAY","GameFontNormalLeft")
				ChatBubbleInterfaceOptionsSpellListSpell1:SetPoint("LEFT",ChatBubbleInterfaceOptionsSpellListRow1,"RIGHT",SpellListHorizontalSpacing*0,0)
				ChatBubbleInterfaceOptionsSpellListSpell1:SetText("Chat Bubble: 211565")
			local ChatBubbleInterfaceOptionsSpellListSpell2 = ChatBubbleInterfaceOptions.panel:CreateFontString("Spell2","OVERLAY","GameFontNormalLeft")
				ChatBubbleInterfaceOptionsSpellListSpell2:SetPoint("LEFT",ChatBubbleInterfaceOptionsSpellListRow1,"RIGHT",SpellListHorizontalSpacing*1,0)
				ChatBubbleInterfaceOptionsSpellListSpell2:SetText("Gear: 142677")
			local ChatBubbleInterfaceOptionsSpellListSpell3 = ChatBubbleInterfaceOptions.panel:CreateFontString("Spell3","OVERLAY","GameFontNormalLeft")
				ChatBubbleInterfaceOptionsSpellListSpell3:SetPoint("LEFT",ChatBubbleInterfaceOptionsSpellListRow1,"RIGHT",SpellListHorizontalSpacing*2,0)
				ChatBubbleInterfaceOptionsSpellListSpell3:SetText("Golden '!': 196230")
			local ChatBubbleInterfaceOptionsSpellListSpell4 = ChatBubbleInterfaceOptions.panel:CreateFontString("Spell4","OVERLAY","GameFontNormalLeft")
				ChatBubbleInterfaceOptionsSpellListSpell4:SetPoint("LEFT",ChatBubbleInterfaceOptionsSpellListRow2,"RIGHT",SpellListHorizontalSpacing*0,0)
				ChatBubbleInterfaceOptionsSpellListSpell4:SetText("Red '!': 90080")
			local ChatBubbleInterfaceOptionsSpellListSpell5 = ChatBubbleInterfaceOptions.panel:CreateFontString("Spell5","OVERLAY","GameFontNormalLeft")
				ChatBubbleInterfaceOptionsSpellListSpell5:SetPoint("LEFT",ChatBubbleInterfaceOptionsSpellListRow2,"RIGHT",SpellListHorizontalSpacing*1,0)
				ChatBubbleInterfaceOptionsSpellListSpell5:SetText("Green '!': 81204")
	
	local ChatBubbleInterfaceOptionsEmoteList = ChatBubbleInterfaceOptions.panel:CreateFontString("EmoteList", "OVERLAY", "GameFontNormalLeft")
	ChatBubbleInterfaceOptionsEmoteList:SetPoint("TOPLEFT", ChatBubbleInterfaceOptionsSpellList, "BOTTOMLEFT", 0, -70)
	ChatBubbleInterfaceOptionsEmoteList:SetText("Emotes: (Use Negative Number Above)")
		local ChatBubbleInterfaceOptionsEmoteListRow1 = ChatBubbleInterfaceOptions.panel:CreateFontString("EmoteRow1","OVERLAY",ChatBubbleInterfaceOptionsEmoteList)
		ChatBubbleInterfaceOptionsEmoteListRow1:SetPoint("TOPLEFT",ChatBubbleInterfaceOptionsEmoteList,"BOTTOMLEFT",9,-15)
		local ChatBubbleInterfaceOptionsEmoteListRow2 = ChatBubbleInterfaceOptions.panel:CreateFontString("EmoteRow2","OVERLAY",ChatBubbleInterfaceOptionsEmoteListRow1)
		ChatBubbleInterfaceOptionsEmoteListRow2:SetPoint("TOPLEFT",ChatBubbleInterfaceOptionsEmoteListRow1,"BOTTOMLEFT",0,-25)
			local ChatBubbleInterfaceOptionsEmoteListEmote1 = ChatBubbleInterfaceOptions.panel:CreateFontString("Emote1","OVERLAY","GameFontNormalLeft")
				ChatBubbleInterfaceOptionsEmoteListEmote1:SetPoint("LEFT",ChatBubbleInterfaceOptionsEmoteListRow1,"RIGHT",SpellListHorizontalSpacing*0,0)
				ChatBubbleInterfaceOptionsEmoteListEmote1:SetText("Talk: 396")
			local ChatBubbleInterfaceOptionsEmoteListEmote2 = ChatBubbleInterfaceOptions.panel:CreateFontString("Emote2","OVERLAY","GameFontNormalLeft")
				ChatBubbleInterfaceOptionsEmoteListEmote2:SetPoint("LEFT",ChatBubbleInterfaceOptionsEmoteListRow1,"RIGHT",SpellListHorizontalSpacing*1,0)
				ChatBubbleInterfaceOptionsEmoteListEmote2:SetText("Exclamation: 5")
			local ChatBubbleInterfaceOptionsEmoteListEmote3 = ChatBubbleInterfaceOptions.panel:CreateFontString("Emote3","OVERLAY","GameFontNormalLeft")
				ChatBubbleInterfaceOptionsEmoteListEmote3:SetPoint("LEFT",ChatBubbleInterfaceOptionsEmoteListRow1,"RIGHT",SpellListHorizontalSpacing*2,0)
				ChatBubbleInterfaceOptionsEmoteListEmote3:SetText("Question: 6")
			local ChatBubbleInterfaceOptionsEmoteListEmote4 = ChatBubbleInterfaceOptions.panel:CreateFontString("Emote4","OVERLAY","GameFontNormalLeft")
				ChatBubbleInterfaceOptionsEmoteListEmote4:SetPoint("LEFT",ChatBubbleInterfaceOptionsEmoteListRow1,"RIGHT",SpellListHorizontalSpacing*3,0)
				ChatBubbleInterfaceOptionsEmoteListEmote4:SetText("Working: 432")
			local ChatBubbleInterfaceOptionsEmoteListEmote5 = ChatBubbleInterfaceOptions.panel:CreateFontString("Emote5","OVERLAY","GameFontNormalLeft")
				ChatBubbleInterfaceOptionsEmoteListEmote5:SetPoint("LEFT",ChatBubbleInterfaceOptionsEmoteListRow2,"RIGHT",SpellListHorizontalSpacing*0,0)
				ChatBubbleInterfaceOptionsEmoteListEmote5:SetText("Read Book: 641")
			local ChatBubbleInterfaceOptionsEmoteListEmote6 = ChatBubbleInterfaceOptions.panel:CreateFontString("Emote5","OVERLAY","GameFontNormalLeft")
				ChatBubbleInterfaceOptionsEmoteListEmote6:SetPoint("LEFT",ChatBubbleInterfaceOptionsEmoteListRow2,"RIGHT",SpellListHorizontalSpacing*1,0)
				ChatBubbleInterfaceOptionsEmoteListEmote6:SetText("Read Map: 492")
			local ChatBubbleInterfaceOptionsEmoteListEmote7 = ChatBubbleInterfaceOptions.panel:CreateFontString("Emote5","OVERLAY","GameFontNormalLeft")
				ChatBubbleInterfaceOptionsEmoteListEmote7:SetPoint("LEFT",ChatBubbleInterfaceOptionsEmoteListRow2,"RIGHT",SpellListHorizontalSpacing*2,0)
				ChatBubbleInterfaceOptionsEmoteListEmote7:SetText("Read Map & Talk: 588")
	
	--Main Addon Toggle
	local ChatBubbleInterfaceOptionsFullToggle = CreateFrame("CHECKBUTTON", "CBMainToggleOption", ChatBubbleInterfaceOptions.panel, "InterfaceOptionsCheckButtonTemplate")
	CBMainToggleOption:SetPoint("TOPLEFT", 20, -40)
	CBMainToggleOptionText:SetText("Enable ChatBubbles Addon")
	CBMainToggleOption:SetScript("OnShow", function(self)
		if chatBubbleOptions["enabled"] == true then
			self:SetChecked(true)
		else
			self:SetChecked(false)
			DisableOptions(true)
		end
	end)
	CBMainToggleOption:SetScript("OnClick", function(self)
		chatBubbleOptions["enabled"] = not chatBubbleOptions["enabled"]
		DisableOptions(not self:GetChecked())
		if chatBubbleOptions["debug"] then
			cprint("Toggled Entire Addon: "..tostring(self:GetChecked()))
		end
	end)
	CBMainToggleOption:SetScript("OnEnter", function()
		GameTooltip:SetOwner(CBMainToggleOption, "ANCHOR_LEFT")
		CBMainToggleOption.Timer = C_Timer.NewTimer(0.7,function()
			GameTooltip:SetText("Toggle the entire functionality of the addon on / off.", nil, nil, nil, nil, true)
			GameTooltip:Show()
		end)
	end)
	CBMainToggleOption:SetScript("OnLeave", function()
		GameTooltip_Hide()
		CBMainToggleOption.Timer:Cancel()
	end)
	
	--Typing Flag Toggle
	local ChatBubbleInterfaceOptionsNametagToggle = CreateFrame("CHECKBUTTON", "CBNameToggleOption", ChatBubbleInterfaceOptions.panel, "InterfaceOptionsCheckButtonTemplate")
	CBNameToggleOption:SetPoint("TOPLEFT", 20, -60)
	CBNameToggleOptionText:SetText("Enable <Typing> Indicator")
	CBNameToggleOption:SetScript("OnShow", function(self)
		if chatBubbleOptions["nametag"] == true then
			self:SetChecked(true)
		else
			self:SetChecked(false)
		end
	end)
	CBNameToggleOption:SetScript("OnClick", function(self)
		chatBubbleOptions["nametag"] = not chatBubbleOptions["nametag"]
		if chatBubbleOptions["debug"] then
			cprint("Toggled <Typing> Indicator")
		end
	end)
	CBNameToggleOption:SetScript("OnEnter", function()
		GameTooltip:SetOwner(CBNameToggleOption, "ANCHOR_LEFT")
		CBNameToggleOption.Timer = C_Timer.NewTimer(0.7,function()
			GameTooltip:SetText("Toggle the <Typing> indicator on your overhead Name Tag.\n\nThis will only show when a chat type is enabled. If you want <Typing> only, set your spell/emote to '0' and keep that chat type enabled.", nil, nil, nil, nil, true)
			GameTooltip:Show()
		end)
	end)
	CBNameToggleOption:SetScript("OnLeave", function()
		GameTooltip_Hide()
		CBNameToggleOption.Timer:Cancel()
	end)
	
	
	
	local cbLinksToggle = CreateFrame("CHECKBUTTON", "CBChatToggleLinks", ChatBubbleInterfaceOptions.panel, "InterfaceOptionsCheckButtonTemplate")
	cbLinksToggle:SetPoint("TOPLEFT", 250, -40)
	CBChatToggleLinksText:SetText("Allow Links")
	cbLinksToggle:SetScript("OnClick", function()
		chatBubbleOptions.CBICChats["LINKS"] = not chatBubbleOptions.CBICChats["LINKS"]
	end)
	cbLinksToggle:SetScript("OnEnter", function()
		GameTooltip:SetOwner(cbLinksToggle, "ANCHOR_LEFT")
		cbLinksToggle.Timer = C_Timer.NewTimer(0.7,function()
			GameTooltip:SetText("When enabled, ChatBubbles will still react to typing if there's an Item, Object, or Spell linked in chat.\n\nDefault: Disabled.", nil, nil, nil, nil, true)
			GameTooltip:Show()
		end)
	end)
	cbLinksToggle:SetScript("OnLeave", function()
		GameTooltip_Hide()
		cbLinksToggle.Timer:Cancel()
	end)
	
	local cbDiverseToggle = CreateFrame("CHECKBUTTON", "CBToggleDiverse", ChatBubbleInterfaceOptions.panel, "InterfaceOptionsCheckButtonTemplate")
	cbDiverseToggle:SetPoint("TOPLEFT", 400, -40)
	CBToggleDiverseText:SetText("Use 'Say' Spell for All")
	cbDiverseToggle:SetScript("OnClick", function()
		chatBubbleOptions["diverseAura"] = not chatBubbleOptions["diverseAura"]
		if chatBubbleOptions["debug"] then
			cprint("Diverse Aura's Toggled to: "..tostring(chatBubbleOptions["diverseAura"]).." (This is Backwards from Checkbox, shh)")
		end
	end)
	cbDiverseToggle:SetScript("OnEnter", function()
		GameTooltip:SetOwner(cbDiverseToggle, "ANCHOR_LEFT")
		cbDiverseToggle.Timer = C_Timer.NewTimer(0.7,function()
			GameTooltip:SetText("When enabled, every chat type will use the 'Say' spell or emote, ignoring their own.\n\nDefault: Disabled.", nil, nil, nil, nil, true)
			GameTooltip:Show()
		end)
	end)
	cbDiverseToggle:SetScript("OnLeave", function()
		GameTooltip_Hide()
		cbDiverseToggle.Timer:Cancel()
	end)
	
	local ChatBubbleInterfaceOptionsDebug = CreateFrame("CHECKBUTTON", "CBDebugToggleOption", ChatBubbleInterfaceOptions.panel, "OptionsSmallCheckButtonTemplate")
	CBDebugToggleOption:SetPoint("BOTTOMRIGHT", 0, 0)
	CBDebugToggleOption:SetHitRectInsets(-35,0,0,0)
	CBDebugToggleOptionText:SetTextColor(1,1,1,1)
	CBDebugToggleOptionText:SetText("Debug")
	CBDebugToggleOptionText:SetPoint("LEFT", -30, 0)
	CBDebugToggleOption:SetScript("OnShow", function(self)
		updateCBInterfaceOptions()
	end)
	CBDebugToggleOption:SetScript("OnClick", function(self)
		chatBubbleOptions["debug"] = not chatBubbleOptions["debug"]
		if chatBubbleOptions["debug"] then
			cprint("Toggled Debug (VERBOSE) Mode")
		end
	end)
	
	for k,v in ipairs(allowedChatTypes) do
		local checkbutton = CreateFrame("CHECKBUTTON", "CBChatToggle"..v, ChatBubbleInterfaceOptions.panel, "InterfaceOptionsCheckButtonTemplate")
		checkbutton:SetPoint("TOPLEFT", 20, -80-tonumber(k)*30)
		checkbutton:SetAttribute("chatType", string.upper(v))
		checkbutton:SetScript("OnClick", function() 
			chatBubbleOptions.CBICChats[checkbutton:GetAttribute("chatType")] = not chatBubbleOptions.CBICChats[checkbutton:GetAttribute("chatType")]
			if chatBubbleOptions["debug"] then
				cprint("Toggled "..checkbutton:GetAttribute("chatType").." Chat Bubble")
			end
		end)
		_G["CBChatToggle"..v.."Text"]:SetText("  "..v)
		
		local spellbox = CreateFrame("EditBox", "CBChatSpellBox"..v, ChatBubbleInterfaceOptions.panel, "InputBoxTemplate")
		spellbox:SetAutoFocus(false)
		spellbox:SetSize(80,23)
		spellbox:SetPoint("TOPLEFT", 160, -80-tonumber(k)*30)
		--spellbox:SetNumeric(true)
		spellbox:SetAttribute("chatType", string.upper(v))
		spellbox:SetText(chatBubbleOptions.ChatSpells[checkbutton:GetAttribute("chatType")])
		spellbox:SetCursorPosition(0)
		spellbox:SetScript("OnEditFocusLost", function()
			chatBubbleOptions.ChatSpells[spellbox:GetAttribute("chatType")] = tonumber(spellbox:GetText())
			if chatBubbleOptions["debug"] then
				cprint("Chat "..spellbox:GetAttribute("chatType").." Spell set to "..spellbox:GetText())
			end
		end)
		spellbox:SetScript("OnTextChanged", function()
			--if not tonumber(spellbox:GetText()) then
			if spellbox:GetText() == spellbox:GetText():match("%d+") or spellbox:GetText() == spellbox:GetText():match("-%d+") then
				spellbox:SetTextColor(255,255,255,1)
			elseif spellbox:GetText() == "" then
				spellbox:SetTextColor(255,255,255,1)
			elseif spellbox:GetText():find("%a") then
				spellbox:SetText(spellbox:GetText():gsub("%a", ""))
			else
				spellbox:SetTextColor(1,0,0,1)
			end
		end)
		spellbox:SetScript("OnEnter", function()
			GameTooltip:SetOwner(spellbox, "ANCHOR_LEFT")
			spellbox.Timer = C_Timer.NewTimer(0.7,function()
				GameTooltip:SetText("Set the Spell ID or Emote ID you with to use.\n\rAdd a negative to use an emote instead of a spell. (I.e. -1 for talking emote)\n\rSet to 0 to disable spell/emote and only use <Typing> if enabled.", nil, nil, nil, nil, true)
				GameTooltip:Show()
			end)
		end)
		spellbox:SetScript("OnLeave", function()
			GameTooltip_Hide()
			spellbox.Timer:Cancel()
		end)
		
		local defaultSpellButton = CreateFrame("Button", "CBChatSpellResetButton"..v, ChatBubbleInterfaceOptions.panel, "OptionsButtonTemplate")
		defaultSpellButton:SetPoint("TOPLEFT", 410, -80-tonumber(k)*30)
		defaultSpellButton:SetSize(120,23)
		defaultSpellButton:SetAttribute("chatType", v)
		defaultSpellButton:SetScript("OnClick", function() 
			_G["CBChatSpellBox"..defaultSpellButton:GetAttribute("chatType")]:SetText(defaultChatSpells[string.upper(defaultSpellButton:GetAttribute("chatType"))])
			chatBubbleOptions.ChatSpells[string.upper(defaultSpellButton:GetAttribute("chatType"))] = defaultChatSpells[string.upper(defaultSpellButton:GetAttribute("chatType"))]
			if chatBubbleOptions["debug"] then
				cprint("Reset "..defaultSpellButton:GetAttribute("chatType").." to default spell")
			end
		end)
		_G["CBChatSpellResetButton"..v.."Text"]:SetText("Default ("..defaultChatSpells[checkbutton:GetAttribute("chatType")]..")")
		
		local spellDropSelect = CreateFrame("Frame", "spellDropDownMenu"..v, ChatBubbleInterfaceOptions.panel, "UIDropDownMenuTemplate")
		spellDropSelect:SetPoint("TOPLEFT", 250, -80-tonumber(k)*30+2) -- DropDown Boxes are naturally offset by a few pixels down, +2 to fix it
		spellDropSelect:SetAttribute("chatType", v)
		local function OnClick(self)
			UIDropDownMenu_SetSelectedID(spellDropSelect, self:GetID())
			if self.value ~= "" then
				_G["CBChatSpellBox"..spellDropSelect:GetAttribute("chatType")]:SetText(self.value)
				chatBubbleOptions.ChatSpells[string.upper(spellDropSelect:GetAttribute("chatType"))] = tonumber(self.value)
				if chatBubbleOptions["debug"] then
					cprint(""..spellDropSelect:GetAttribute("chatType").." set to "..self.value)
				end
			end
		end
		local function initialize(self,level)
			local info = UIDropDownMenu_CreateInfo()
			for k,v in ipairs(presetSpells) do
				info = UIDropDownMenu_CreateInfo()
				info.text = presetSpellsName[v]
				info.value = v
				info.func = OnClick
				UIDropDownMenu_AddButton(info,level)
			end
		end
		UIDropDownMenu_Initialize(spellDropSelect, initialize)
		UIDropDownMenu_SetWidth(spellDropSelect, 100);
		UIDropDownMenu_SetButtonWidth(spellDropSelect, 124)
		UIDropDownMenu_SetSelectedID(spellDropSelect, 0)
		UIDropDownMenu_JustifyText(spellDropSelect, "LEFT")
		UIDropDownMenu_SetText(spellDropSelect, "Select a Preset")
	end
	
	
	local ChatBubbleInterfaceTitles = ChatBubbleInterfaceOptions.panel:CreateFontString("CBTitleChatType", "OVERLAY", "GameFontNormalLeft")
	ChatBubbleInterfaceTitles:SetPoint("BOTTOM", CBChatToggleSayText, "TOP", 0, 14)
	ChatBubbleInterfaceTitles:SetText("Toggle Chat Type")
	
	local ChatBubbleInterfaceTitles = ChatBubbleInterfaceOptions.panel:CreateFontString("CBTitleSpellID", "OVERLAY", "GameFontNormalLeft")
	ChatBubbleInterfaceTitles:SetPoint("TOP", CBChatSpellBoxSay, "TOP", 0, 20)
	ChatBubbleInterfaceTitles:SetText("Spell / Emote ID")
	
	local ChatBubbleInterfaceTitles = ChatBubbleInterfaceOptions.panel:CreateFontString("CBTitlePresets", "OVERLAY", "GameFontNormalLeft")
	ChatBubbleInterfaceTitles:SetPoint("TOP", spellDropDownMenuSay, "TOP", 0, 18)
	ChatBubbleInterfaceTitles:SetText("Preset Spells")
	
	local ChatBubbleInterfaceTitles = ChatBubbleInterfaceOptions.panel:CreateFontString("CBTitleReset", "OVERLAY", "GameFontNormalLeft")
	ChatBubbleInterfaceTitles:SetPoint("TOP", CBChatSpellResetButtonSay, "TOP", 0, 20)
	ChatBubbleInterfaceTitles:SetText("Reset to Default")
	
	InterfaceOptions_AddCategory(ChatBubbleInterfaceOptions.panel);
	updateCBInterfaceOptions() -- Call this because OnShow isn't triggered first time, and neither is OnLoad for some reason, so lets just update them manually
end

function updateCBInterfaceOptions()
	if chatBubbleOptions["enabled"] == true then CBMainToggleOption:SetChecked(true) else CBMainToggleOption:SetChecked(false) end
	if chatBubbleOptions["debug"] == true then CBDebugToggleOption:SetChecked(true) else CBDebugToggleOption:SetChecked(false) end
	if chatBubbleOptions["nametag"] == true then CBNameToggleOption:SetChecked(true) else CBNameToggleOption:SetChecked(false) end
	if chatBubbleOptions["diverseAura"] then CBToggleDiverse:SetChecked(false) else CBToggleDiverse:SetChecked(true) end
	if chatBubbleOptions.CBICChats["LINKS"] then CBChatToggleLinks:SetChecked(true) else CBChatToggleLinks:SetChecked(false) end
	for k,v in ipairs(allowedChatTypes) do
		local V = string.upper(v)
		if chatBubbleOptions.CBICChats[V] then _G["CBChatToggle"..v]:SetChecked(true) else _G["CBChatToggle"..v]:SetChecked(false) end
	end
end

-------------------------------------------------------------------------------
-- Version / Help / Toggle
-------------------------------------------------------------------------------

SLASH_CCCBHELP1, SLASH_CCCBHELP2 = '/chatbubble', '/cb'; -- 3.
function SlashCmdList.CCCBHELP(msg, editbox) -- 4.
	if isEpsilonWoW == false then
		cprint("ChatBubbles is disabled, as it has detected you are not on a compatible server.")
	elseif chatBubbleOptions["debug"] and msg == "debug" then
		cprint("ConvenientCommands: ChatBubble | DEBUG LIST")
		cprint("currentVersion: "..currentVersion)
		cprint("isEpsilonWoW: "..tostring(isEpsilonWoW))
	else
		 InterfaceOptionsFrame_OpenToCategory("ChatBubble");
		 InterfaceOptionsFrame_OpenToCategory("ChatBubble");
	end
end