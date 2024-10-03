local EpsilonLib, EpsiLib = ...;

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

EpsiLib.EventManager = _events
