local EpsilonLib, EpsiLib = ...;

--- ---------------------------------------
--- Epsilon Lib - Event Manager Systems
--- ---------------------------------------

--#region WoW Events Listeners & Callbacks
--- Uses a single frame to handle all events & callbacks, versus making a new frame every time we want a module to watch for an event

local eventFrame = CreateFrame("Frame")

local _events = {}
local _table = {}

local addonLoadedAlreadyRan = false
eventFrame:RegisterEvent("ADDON_LOADED")

---@param event FrameEvent
---@param callback function
---@return function
function _events:Register(event, callback)
	if type(event) ~= "string" or type(callback) ~= "function" then error("Register requires an event & callback function.") end

	-- Case handler:
	if event == "ADDON_LOADED" and addonLoadedAlreadyRan then
		callback(nil, "ADDON_LOADED", EpsilonLib)
		return
	end


	if not _table[event] then _table[event] = {} end

	table.insert(_table[event], callback)

	eventFrame:RegisterEvent(event)

	return callback
end

---@param reference function
---@param event FrameEvent
function _events:Remove(reference, event)
	if event then
		tDeleteItem(_table[event], reference)
		return
	end

	for k, v in pairs(_table) do
		-- expensive, always try and call with your known event!
		tDeleteItem(v, reference)
	end
end

---@param event? FrameEvent
---@return table
function _events:GetCallbackTable(event)
	if event then return _table[event] end
	return _table
end

eventFrame:SetScript("OnEvent", function(self, event, ...)
	if event == "ADDON_LOADED" and select(1, ...) == EpsilonLib then
		addonLoadedAlreadyRan = true
	end

	local _callbacks = CopyTable(_table[event])
	if _callbacks then
		for i = 1, #_callbacks do
			local callback = _callbacks[i]
			self = nil -- don't pass back our eventFrame, keep it protected
			callback(self, event, ...)
		end
	end
end)

--#endregion

--#region Command Event Manager
--- Watching for Command Replies & handling if needed - Mostly for static capture of data & logging


local filter_events = {
	"CHAT_MSG_ADDON",
	"CHAT_MSG_SYSTEM",
	"CHAT_MSG_ACHIEVEMENT",
	"CHAT_MSG_BN_WHISPER_INFORM",
	"CHAT_MSG_COMBAT_XP_GAIN",
	"CHAT_MSG_COMBAT_HONOR_GAIN",
	"CHAT_MSG_COMBAT_FACTION_CHANGE",
	"CHAT_MSG_TRADESKILLS",
	"CHAT_MSG_OPENING",
	"CHAT_MSG_PET_INFO",
	"CHAT_MSG_COMBAT_MISC_INFO",
	"CHAT_MSG_BG_SYSTEM_HORDE",
	"CHAT_MSG_BG_SYSTEM_ALLIANCE",
	"CHAT_MSG_BG_SYSTEM_NEUTRAL",
	"CHAT_MSG_TARGETICONS",
	"CHAT_MSG_BN_CONVERSATION_NOTICE",
}

---Helper Util to quickly create a command reply filter through all the possible command reply channels, with proper handling of AddOn Commands
---@param callback function The callback function to run on reply. You should pattern match first to make sure it's the reply you want.
---@return function reference The callback provided in the input is wrapped, so is no longer valid for using in removal - This reference is the new, wrapped callback
function _events:AddCommandFilter(callback)
	if not callback then error("AddCommandFilter Syntax Error: No Callback given. Are you calling with a : ?") end
	local function wrapper(self, event, message)
		if event == "CHAT_MSG_ADDON" then
			message = message:sub(5) -- remove the addon command part
		end
		return callback(nil, event, message)
	end
	for i = 1, #filter_events do
		ChatFrame_AddMessageEventFilter(filter_events[i], wrapper)
	end

	return wrapper
end

---Removes a command filter by function reference from the return on AddCommandFilter
---@param reference function
function _events:RemoveCommandFilter(reference)
	for i = 1, #filter_events do
		ChatFrame_RemoveMessageEventFilter(filter_events[i], reference)
	end
end

-- Simple Pattern -> Callback system
local commandWatchers = {}

---Registers a simple pattern match to callback on command replies.
---@param pattern string The pattern that must be matched in order to run this callback
---@param callback fun(self, event, message) The callback function, with the same args as a standard MessageEventFilter, except self is always nil
---@return table reference The table reference for this new entry, which is a table housing the pattern & callback, which can then technically be modified live as well.
function _events:RegisterSimpleCommandWatcher(pattern, callback)
	local new_table = { pattern = pattern, callback = callback }
	tinsert(commandWatchers, new_table)
	return new_table
end

---Removes a simple command watcher by reference from the return on RegisterSimpleCommandWatcher
---@param reference table
function _events:DeleteSimpleCommandWatcher(reference)
	tDeleteItem(commandWatchers, reference)
end

local function simpleCommandReplyListener(_, event, message)
	for i = 1, #commandWatchers do
		local data = commandWatchers[i]
		if message:find(data.pattern) then
			return data.callback(nil, event, message)
		end
	end
end

_events:AddCommandFilter(simpleCommandReplyListener)

--#endregion

EpsiLib.EventManager = _events
