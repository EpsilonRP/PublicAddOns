local EpsilonLib, EpsiLib = ...;

--- ---------------------------------------
--- Epsilon Lib - Event Manager Systems
--- ---------------------------------------

--#region WoW Events Listeners & Callbacks
--- Uses a single frame to handle all events & callbacks, versus making a new frame every time we want a module to watch for an event

local eventFrame = CreateFrame("Frame")

local EventManager = {}
local _events = {}

local addonLoadedAlreadyRan
eventFrame:RegisterEvent("ADDON_LOADED")

local function safeRegEvent(event)
	return pcall(eventFrame.RegisterEvent, eventFrame, event)
end

local function safeUnregEvent(event)
	return pcall(eventFrame.UnregisterEvent, eventFrame, event)
end

---@param event FrameEvent|string
---@param callback function
---@param runOnce? boolean If true, the given script is unregistered after it's first ran
---@return function?
function EventManager:Register(event, callback, runOnce)
	if type(event) ~= "string" or type(callback) ~= "function" then error("Register requires an event & callback function.") end

	-- Case handler - We replicate AddOn Loaded for EpsiLib always. Anyone who wants to watch for their own ADDON_LOADED should double check that the addon name is there's and that EpsilonLib is a dep so it loads first and then doesn't miss their ADDON_LOADED. Or.. just do it themself.
	if event == "ADDON_LOADED" and addonLoadedAlreadyRan then
		callback(nil, "ADDON_LOADED", unpack(addonLoadedAlreadyRan))
	end

	if not _events[event] then _events[event] = {} end

	table.insert(_events[event], { callback = callback, runOnce = runOnce })

	safeRegEvent(event)

	return callback
end

---@param reference function
---@param event? FrameEvent|string
function EventManager:Remove(reference, event)
	if event then
		if _events[event] then
			tDeleteItem(_events[event], reference)

			-- Cleanup if there's no callbacks on this left
			if #_events[event] == 0 then
				_events[event] = nil
				safeUnregEvent(event)
			end

			return
		else
			error(("Event %s had no registered callbacks. Did you already unregister?"):format(event))
		end
	end

	-- Unknown event, or done on purpose if removing from all events
	for k, v in pairs(_events) do
		-- expensive, always try and call with your known event!
		local event = k
		local numDeleted = tDeleteItem(v, reference)

		if numDeleted > 0 then -- something was removed, check if we need to unregister the event
			if #v == 0 then
				_events[event] = nil
				safeUnregEvent(event)
			end
			-- we don't return here, as technically this allows you to unregister it from every event, if you registered to multiple events
		end
	end
end

---@param event? FrameEvent|string
---@return table
function EventManager:GetCallbackTable(event)
	if event then return _events[event] end
	return _events
end

---Fires an event manually, using custom given args. This can be a totally custom event as well.
---@param event FrameEvent|string
---@param ... unknown
function EventManager:Fire(event, ...)
	if not _events[event] then return end -- No events registered for this, just exit out
	local _callbacks = CopyTable(_events[event])
	if _callbacks then
		if #_callbacks == 0 then return end -- no callbacks registered (all unregistered or runOnce completed)
		for i = 1, #_callbacks do
			local callbackData = _callbacks[i]
			local callback = _callbacks[i].callback
			callback(nil, event, ...) -- self is passed back as nil; we do not provide access to our event frame itself.
			if callbackData.runOnce then
				EventManager:Remove(callback, event)
			end
		end
	end
end

eventFrame:SetScript("OnEvent", function(self, event, ...)
	if event == "ADDON_LOADED" and select(1, ...) == EpsilonLib then
		addonLoadedAlreadyRan = { ... }
	end

	EventManager:Fire(event, ...)
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
function EventManager:AddCommandFilter(callback)
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
function EventManager:RemoveCommandFilter(reference)
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
function EventManager:RegisterSimpleCommandWatcher(pattern, callback)
	local new_table = { pattern = pattern, callback = callback }
	tinsert(commandWatchers, new_table)
	return new_table
end

---Removes a simple command watcher by reference from the return on RegisterSimpleCommandWatcher
---@param reference table
function EventManager:DeleteSimpleCommandWatcher(reference)
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

EventManager:AddCommandFilter(simpleCommandReplyListener)

--#endregion

EpsiLib.EventManager = EventManager
