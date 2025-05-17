local EpsilonLib, EpsiLib = ...;

local EPSI_ADDON_PREFIX = "Command"

--- local holder for our module data
local _commands = {}

-- Storage Tables

---@class RegistryData
---@field showMessages boolean
---@field name string

---@type { [string]: RegistryData }
local registry = {
	-- This is us, and an example!
	["EpsilonLib"] = { showMessages = true, name = "EpsilonLib" }
}

local function sprint(...)
	local systemChatInfo = ChatTypeInfo["SYSTEM"]
	local systemChatColor = CreateColor(systemChatInfo.r, systemChatInfo.g, systemChatInfo.b)
	print(systemChatColor:GenerateHexColorMarkup(), ...)
end

local function timeToDate(time)
	local dateString = date("%Y-%m-%d %H:%M:%S", time)
	return dateString
end

---@class CommandBufferData
---@field name string
---@field command string
---@field callback? function
---@field overrideMessages? boolean
---@field returnMessages? string[]
---@field status? string

---@type CommandBufferData[] --// NOTE: WE DO NOT USE THIS AS A REAL ARRAY, IT'S USED AS A STATIC ID LOOKUP / DICTIONARY, NEVER POP OR REORDER, ALWAYS DIRECT SET BASED ON COUNTER STRING ID
local commandBuffer = {}

---@type CommandBufferData[] --// This is a log of all commands sent, for debugging & tracking purposes. It will be cleared on a reload, but you can use it to track what commands are being sent & when.
local commandLog = {}

-- public access as needed for debug or API access, or other UI elements
_commands._CommandBuffer = commandBuffer
_commands._CommandLog = commandLog

-------------------------------------------
--#region Helper Funcs
-------------------------------------------

local commandCounter = 0
local counterChars = { '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z', 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z' }
local numCounterChars = #counterChars
local function CommandCounterToString(counter)
	local char4, char3, char2, char1
	char4 = counter % numCounterChars
	counter = floor(counter / numCounterChars)
	char3 = counter % numCounterChars
	counter = floor(counter / numCounterChars)
	char2 = counter % numCounterChars
	counter = floor(counter / numCounterChars)
	char1 = counter % numCounterChars
	return ("%s%s%s%s"):format(counterChars[char1 + 1], counterChars[char2 + 1], counterChars[char3 + 1], counterChars[char4 + 1])
end

local function iterCommandCounter()
	commandCounter = commandCounter + 1
end

local charToIndex = {}
for i, char in ipairs(counterChars) do
	charToIndex[char] = i - 1
end

local function StringToCommandCounter(str)
	if #str ~= 4 then
		error("Encoded string must be exactly 4 characters.")
	end

	local value = 0
	for i = 1, 4 do
		local char = str:sub(i, i)
		local index = charToIndex[char]
		if not index then
			error("Invalid character in encoded string: " .. char)
		end
		value = value * numCounterChars + index
	end

	return value
end


---@generic V
---@param value (V | fun(): V)
---@return V
local function evaluate(value)
	if type(value) == "function" then
		return value()
	end

	return value
end

--#endregion
-------------------------------------------
--#region Handler Functions
-------------------------------------------

---@param success boolean
---@param data CommandBufferData
---@param addon RegistryData
local function handleCallbackAndMessages(success, data, addon)
	if data.callback then
		data.callback(success, data.returnMessages)
		data.callback = nil -- // Clear our callback so we can't call it twice on accident somehow? I don't think we can get both f & o but... Even TCLib does this to be safe
	end

	if data.overrideMessages == false then return end -- // Force block replies if this send had a force hide messages
	local showMessages = (data.overrideMessages or (addon and evaluate(addon.showMessages) and data.overrideMessages ~= false))
	if success == false then showMessages = true end -- Force Show Messages on Failure!
	if showMessages and data.returnMessages then
		for k, v in ipairs(data.returnMessages) do
			SendSystemMessage(v)
			-- sprint(v) -- SystemMessage? Print? We're gonna use system message so it can be parsed by GLink if needed & looks more like a real SystemMessage reply from the server
		end
	end
end

local function recordCommandBufferAndLog(commandID, commandData)
	local data = {
		id = commandID,
		realID = commandData.realID,
		name = commandData.name,
		command = commandData.command,
		callback = commandData.callback,
		overrideMessages = commandData.overrideMessages,
		status = "s",  -- // s = sent, o = okay, f = failure, m = message (message received), a = ack (acknowledged)
		returnMessages = {}, -- pre-making this so it can be referenced in the log before we get a reply
		time = time(), -- // Time of command sent
	}
	commandBuffer[commandID] = data
	tinsert(commandLog, data) -- // Log the command in order of sending
	return data
end

local function recordCommandLogOnly(commandID, commandData)
	local data = {
		id = commandID,
		realID = commandData.realID,
		name = commandData.name,
		command = commandData.command,
		--callback = commandData.callback,
		--overrideMessages = commandData.overrideMessages,
		status = "MANUAL", -- MANUAL LOG // Cannot track status of this, so we just set it to manual
		--returnMessages = {}, -- Cannot track replies
		time = time(),     -- // Time of command sent
	}
	tinsert(commandLog, data) -- // Log the command in order of sending
	return data
end

---Safely adding data to the returnMessages (creating if non existent)
---@param data CommandBufferData
---@param msg string
local function addMessageToReturns(data, msg)
	if not data.returnMessages then data.returnMessages = {} end
	tinsert(data.returnMessages, msg)
end

local commandStatusOpcodes = {
	a = {
		status = "ack",
		fn = function(data, addon, rest)
			-- nothing to do on ack
		end
	},
	f = {
		status = "failure",
		fn = function(data, addon, rest)
			local addonName = (addon and addon.name) or data.name or "<UNKNOWN ADDON>"

			-- Report the failure to chat, and report the failure to the callback. Result messages are handled in the callback & messages handler
			if data.overrideMessages ~= false and addon.showMessages ~= true then
				local output = strconcat(("EpsiLib -> Failed Command by %s: "):format(addonName), data.command .. (data.returnMessages and "; Results:" or ""))
				SendSystemMessage(output)
			end
			handleCallbackAndMessages(false, data, addon)
		end
	},
	o = {
		status = "okay",
		fn = function(data, addon, rest)
			-- nothing to do but callback here?
			handleCallbackAndMessages(true, data, addon)
		end
	},
	m = {
		status = "message",
		fn = function(data, addon, rest)
			-- always log the message for using later in callbacks
			-- data.returnMessages = rest
			addMessageToReturns(data, rest)

			-- Handle sending the messages in okay or failure
		end
	},
}

--#endregion
-------------------------------------------
--#region Command Reply Listener Frame
-------------------------------------------

local f = CreateFrame("Frame")
f:RegisterEvent("CHAT_MSG_ADDON")
f:SetScript("OnEvent",
	function(self, event, prefix, text, channel, sender, target, zoneChannelID, localID, name, instanceID)
		if prefix == EPSI_ADDON_PREFIX and channel == "WHISPER" and sender == target then -- Sender == Target is the easiest way to check its ourself, as that's the only time it's possible. Nice.
			local resultOpcode, counter, rest = text:match("^([afom])([0-9a-zA-Z][0-9a-zA-Z][0-9a-zA-Z][0-9a-zA-Z])(.*)$")
			if not counter or #counter ~= 4 then return end                         -- // early exit if ID doesn't exist or not in our format, some other addon using addon commands???
			if not commandStatusOpcodes[resultOpcode] then return end               -- ensure it's a result status we can handle

			local commandBufferData = commandBuffer[counter]

			if not commandBufferData then -- // Command is not logged.. who the f?
				rest = ("<!! AddonCommand #%s not Logged !! How? Report this!>: "):format(counter) .. tostring(rest)
				SendSystemMessage(rest)
				if _commands._CommandLogUpdate then _commands._CommandLogUpdate() end
				return
			end

			local addon = registry[commandBufferData.name]
			commandBufferData.status = resultOpcode                                                                        -- Log our current status. This should? follow a -> m -> o/f; hopefully..

			if commandStatusOpcodes[resultOpcode].fn then commandStatusOpcodes[resultOpcode].fn(commandBufferData, addon, rest) end -- handle that opcode

			if resultOpcode == "o" or resultOpcode == "f" then
				-- in theory we're done, let's clean up..
				commandBuffer[counter] = nil
			end

			if _commands._CommandLogUpdate then _commands._CommandLogUpdate() end
		end
	end
)
C_ChatInfo.RegisterAddonMessagePrefix(EPSI_ADDON_PREFIX)

--#endregion
-------------------------------------------
--#region API Commands
-- EpsilonLib.AddonCommands 	...
-- 	.Register(name <string>, showMessages <boolean>)	-> SendAddonCommand<func>: command<string>, callback<function: success, returnMessages[]>, overrideMessages?<boolean>
--		Notes: 	If showMessages is not given/nil, default is same as false, which only shows returns in chat if it's a error/syntax message.
--				In the SendAddonCommand function, overrideMessages when not given respects showMessages from register. If given, true = show all, false = show NONE, and nil = respect register (which is default of Show only error/syntax)
--				Basically: You should very likely call Register with false on showMessages, and then SendAddonCommand with nil/not given on the overrideMessages :)
--  .Send(AddonName <string>, command <string>, callback <function: success<boolean>, returnMessages[]>, overrideMessages<boolean>)
-------------------------------------------

---Register for AddonCommands, returning a dedicated function for sending commands using our queue & log system for reporting & handling return data.
---@param name string Whatever the name of your AddOn is
---@param showMessages? boolean If reply messages for your addon should be shown by default. You can overwrite per call also. Default is nil (only error messages shown)
---@return function? SendAddonCommand SendAddonCommand(text, callbackFn, overrideMessages) - Callbacks are called with (success <bool>, returnMessages <string[] (array of the strings, to account for multiple replies on some commands)>, overrideMessages<boolean>)
_commands.Register = function(name, showMessages)
	if registry[name] then
		return error(("EpsilonLib.AddonCommands.Register Warning: Name '%s' is already registered. If you need to overwrite.. Add the code support & commit or let MindScape know why and he will add it."):format(name))
	end

	registry[name] = { name = name, showMessages = showMessages }


	---@param text string The command to run
	---@param callbackFn function The callback function called when the replies are complete
	---@param overrideMessages? boolean An override flag on return messages; true = force show messages; false = force hide all messages including error/syntax messages; nil = follow Registered syntax
	local function SendAddonCommand(text, callbackFn, overrideMessages)
		iterCommandCounter()
		local commandID = CommandCounterToString(commandCounter)
		recordCommandBufferAndLog(commandID, { realID = commandCounter, name = name, command = text, callback = callbackFn, overrideMessages = overrideMessages })
		ChatThrottleLib:SendAddonMessage("ALERT", EPSI_ADDON_PREFIX, ("i%s%s"):format(commandID, text), "GUILD")
	end
	return SendAddonCommand
end

---Send a one-off command; If you're using this consistently, you might be better off registering instead.
---@param name string AddOn name calling this command, for logging & debug
---@param text string The command to run
---@param callbackFn function The callback function called when the replies are complete
---@param overrideMessages? boolean An override flag on return messages; true = force show messages; false = force hide all messages including error/syntax messages; nil = follow Registered syntax
_commands.Send = function(name, text, callbackFn, overrideMessages)
	if not name then return error("EpsilonLib.AddonCommands.Send Usage: You must supply a name of the addon calling this as arg1.") end
	iterCommandCounter()
	local commandID = CommandCounterToString(commandCounter)
	recordCommandBufferAndLog(commandID, { realID = commandCounter, name = name, command = text, callback = callbackFn, overrideMessages = overrideMessages })
	ChatThrottleLib:SendAddonMessage("ALERT", EPSI_ADDON_PREFIX, ("i%s%s"):format(commandID, text), "GUILD")
end

---Sends a command by the standard chat message instead of the addon command system, allowing it to split into chunks like UCM if too long for one.
---@param message string
local function sendMessageInChunks(message)
	local maxLength = 254       -- Max bytes per message chunk
	local messageLength = #message -- Get the length of the message in bytes

	-- If message length is less than or equal to maxLength, send it as is
	if messageLength <= maxLength then
		SendChatMessage("." .. message, "GUILD")
		return
	end

	-- Split the message into chunks of maxLength bytes
	for i = 1, messageLength, maxLength do
		local chunk = string.sub(message, i, i + maxLength - 1)
		SendChatMessage((i == 1 and "." or "") .. chunk, "GUILD") -- Send chunks, adding . to first one
	end
end
_commands.SendByChat = sendMessageInChunks

EpsiLib.AddonCommands = _commands





-- -- -- -- -- -- -- -- --
-- -- Manual Command Logging
-- -- -- -- -- -- -- -- --

local sendManualCommand = _commands.Register("EL: Manual Command", true)

-- Save original function
local Original_SendChatMessage = SendChatMessage
local cmdPrefixChars = { ["."] = true, ["!"] = true }

-- Override SendChatMessage
SendChatMessage = function(msg, chatType, language, channel, ...)
	local first = msg:sub(1, 1)
	local second = msg:sub(2, 2)

	if cmdPrefixChars[first] and first ~= second then
		local cmdNoDot = msg:sub(2)

		if EpsiLib_DB.options.UseACSForManualCommands then
			--// Send commands using the EpsilonLib AddonCommand system so that they are fully tracked & logged for results also
			sendManualCommand(cmdNoDot)
			return --// Don't send the command the normal way, we already sent it
		else
			--// Send commands the normal way and just log them
			iterCommandCounter()
			local commandID = CommandCounterToString(commandCounter)
			recordCommandLogOnly(commandID, { realID = commandCounter, name = "Manual Command", command = cmdNoDot })
			if _commands._CommandLogUpdate then _commands._CommandLogUpdate() end
		end
	end

	-- Call the original function
	return Original_SendChatMessage(msg, chatType, language, channel, ...)
end
