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

---@class CommandLogData
---@field name string
---@field command string
---@field callback? function
---@field forceShowMessages? boolean
---@field returnMessages? string[]
---@field status? string

---@type CommandLogData[] NOTE: WE DO NOT USE THIS AS A REAL ARRAY, IT'S USED AS A STATIC ID LOG / DICTIONARY, NEVER POP OR REORDER, ALWAYS DIRECT SET BASED ON ITER ID
local commandLog = {}

-- public access as needed for debug.
-- Likely need to open it first, then watch with update live, otherwise the auto-cleanup will clear it.
-- Or just watch etrace.
_commands._CommandLog = commandLog

-------------------------------------------
--#region Helper Funcs
-------------------------------------------

local iter = 9 -- We start with and only use 10-99 because too lazy to use single digit numbers in double digit format (i.e., 01, 02, etc - since that would require a string formatting... and we should not ever need 99 vs 89 logs..)
local function iterate()
	iter = iter + 1
	if iter > 99 then iter = 10 end -- loop back
	return iter
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
---@param data CommandLogData
---@param addon RegistryData
local function handleCallbackAndMessages(success, data, addon)
	if data.callback then
		data.callback(success, data.returnMessages)
		data.callback = nil -- // Clear our callback so we can't call it twice on accident somehow? I don't think we can get both f & o but... Even TCLib does this to be safe
	end

	if data.forceShowMessages == false then return end -- // Force block replies if this send had a force hide messages
	local showMessages = (data.forceShowMessages or (addon and evaluate(addon.showMessages) and data.forceShowMessages ~= false))
	if success == false then showMessages = true end -- Force Show Messages on Failure!
	if showMessages and data.returnMessages then
		for k, v in ipairs(data.returnMessages) do
			SendSystemMessage(v)
			-- sprint(v) -- SystemMessage? Print? We're gonna use system message so it can be parsed by GLink if needed & looks more like a real SystemMessage reply from the server
		end
	end
end

---Safely adding data to the returnMessages (creating if non existent)
---@param data CommandLogData
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
			if data.forceShowMessages ~= false then
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
			local resultOpcode, cmdID, rest = strsplit(":", text, 3)
			if not cmdID or #cmdID ~= 2 then return end                             -- // early exit if ID doesn't exist or not in our format, some other addon using addon commands???

			if not commandStatusOpcodes[resultOpcode] then return end               -- ensure it's a result status we can handle

			local commandLogData = commandLog[tonumber(cmdID)]

			if not commandLogData then -- // Command is not logged.. who the f?
				rest = ("<!! AddonCommand #%s not Logged !! How? Report this!>: "):format(cmdID) .. tostring(rest)
				SendSystemMessage(rest)
				return
			end

			local addon = registry[commandLogData.name]
			commandLogData.status = resultOpcode                                                                        -- Log our current status. This should? follow a -> m -> o/f; hopefully..

			if commandStatusOpcodes[resultOpcode].fn then commandStatusOpcodes[resultOpcode].fn(commandLogData, addon, rest) end -- handle that opcode

			if resultOpcode == "o" or resultOpcode == "f" then
				-- in theory we're done, let's clean up..
				commandLog[tonumber(cmdID)] = nil
			end
		end
	end
)
C_ChatInfo.RegisterAddonMessagePrefix(EPSI_ADDON_PREFIX)

--#endregion
-------------------------------------------
--#region API Commands
-- EpsilonLib.AddonCommands 	...
-- 	.Register(name <string>, showMessages <boolean>)	-> SendAddonCommand<func>: command<string>, callback<function>, forceShowMessages<boolean>
--  .Send(AddonName <string>, command <string>, callback <function: success<boolean>, returnMessages[]>, forceShowMessages <boolean>)
-------------------------------------------

---Register for AddonCommands, returning a dedicated function for sending commands using our queue & log system for reporting & handling return data.
---@param name string Whatever the name of your AddOn is
---@param showMessages boolean If reply messages for your addon should be shown by default. You can overwrite per call also. Default is nil (no messages shown)
---@return function? SendAddonCommand SendAddonCommand(text, callbackFn, forceShowMessages) - Callbacks are called with (success <bool>, returnMessages <string[] (array of the strings, to account for multiple replies on some commands)>)
_commands.Register = function(name, showMessages)
	if registry[name] then
		return error(("EpsilonLib.AddonCommands.Register Warning: Name '%s' is already registered. If you need to overwrite.. Add the code support & commit or let MindScape know why and he will add it."):format(name))
	end

	registry[name] = { name = name, showMessages = showMessages }

	return function(text, callbackFn, forceShowMessages)
		iterate()

		--ChatThrottleLib:SendAddonMessage("prio",  "prefix", "text", "chattype"[, "target"[, "queueName"[, callbackFn, callbackArg]]]);
		ChatThrottleLib:SendAddonMessage("ALERT", EPSI_ADDON_PREFIX, ("i:%s:"):format(iter) .. text, "GUILD")

		commandLog[iter] = { name = name, command = text, callback = callbackFn, forceShowMessages = forceShowMessages }
	end
end

---Send a one-off command; If you're using this consistently, you might be better off registering instead.
---@param name string AddOn name calling this command, for logging & debug
---@param text string The command to run
---@param callbackFn function The callback function called when the replies are complete
---@param forceShowMessages
_commands.Send = function(name, text, callbackFn, forceShowMessages)
	if not name then return error("EpsilonLib.AddonCommands.Send Usage: You must supply a name of the addon calling this as arg1.") end
	iterate()
	ChatThrottleLib:SendAddonMessage("ALERT", EPSI_ADDON_PREFIX, ("i:%s:"):format(iter) .. text, "GUILD")
	commandLog[iter] = { name = name, command = text, callback = callbackFn, forceShowMessages = forceShowMessages }
end

---Sends a command by the standard chat message instead of the addon command system.
---@param text string
_commands.SendByChat = function(text)
	SendChatMessage("." .. text, "GUILD");
end

EpsiLib.AddonCommands = _commands
