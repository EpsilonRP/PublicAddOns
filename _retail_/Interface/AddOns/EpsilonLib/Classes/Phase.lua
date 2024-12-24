local EpsilonLib, EpsiLib = ...;

--[[

==== DOCS:
==== EpsilonLib.Classes.Phase for main module functions
====
==== Primary expected usage is:
==== 	Single Phase Info: EpsilonLib.Classes.Phase ..
====		Get .. 					:Get(id, callback<_phase>) - Request a Phase Object, and handle a callback when that data is available (immediately if already avail)
====		Update ..				:Update(id, callback<_phase>) - Requests an update to this phases data, with an optional callback once data is updated.
====
====	Phase Overview: EpsilonLib.Classes.Phase ..
====		Request Overview .. 	:RequestOverview(callback<order, store>) to request for current phase overview data.
====		Get Overview (Cache) .. :GetOverviewList() -> Returns the current orderList from cache immediately (if you know you queried it already recently)
====
====	Phase Object Methods: (_phase)
====		Update			:Update(callback) - Requests an update to this phases data, with an optional callback once data is updated.
====		GetPhase ..		Requests specific data about this phase from currently supported data types
====			.. ID, Name, Info, Message, Description, Tags, Color, Background
====

--]]

local tinsert = table.insert

--#region Main Storage Containers

local Phase = {
	Store = {}
}
local PhaseMixin = {}

local phaseLoadCallbacks = {}
local phaseOverviewCallbacks = {}
local currentOverviewOrder = {}

--#endregion
--#region Event Handlers

local function _handleAndAssignPhaseDataTable(phaseData, isOverview)
	if not phaseData then return end

	-- If passed string instead of table, split into chunks
	if type(phaseData) == "string" then
		phaseData = { strsplit(strchar(31), phaseData) }
	end

	local phaseID = tonumber(phaseData[1])

	local _phase = Phase:CreateFromInfo(phaseID, phaseData[2], phaseData[3], phaseData[4], phaseData[5], phaseData[6], phaseData[7], phaseData[8], phaseData[9])

	-- track its order in currentOverviewOrder for possible display purposes
	if isOverview then
		tinsert(currentOverviewOrder, _phase)
	end
	-- run callbacks
	local callbacks = phaseLoadCallbacks[phaseID]
	if callbacks then
		for _, callback in ipairs(callbacks) do
			callback(_phase)
		end
		phaseLoadCallbacks[phaseID] = nil -- Clear it
	end
end

local function OnPhaseInfoDataReceived(self, event, prefix, text, channel, sender, ...)
	-- Check prefix for phase info [id] addon command
	if prefix ~= "EPSILON_PH_INFO" then return end

	local myself = table.concat({ UnitFullName("PLAYER") }, "-")
	if sender ~= myself and (not string.gsub(myself, "%s+", "")) then
		return -- spoofed? ignore
	end

	local phaseData = { strsplit(strchar(31), text) }

	_handleAndAssignPhaseDataTable(phaseData, false);
end
EpsiLib.EventManager:Register("CHAT_MSG_ADDON", OnPhaseInfoDataReceived)

local function OnPhaseOverviewDataReceived(self, event, prefix, text, channel, sender, ...)
	-- Check it's a message for us!
	if prefix ~= "EPSILON_PH_OVE" then return end -- not what we're looking for

	local myself = table.concat({ UnitFullName("PLAYER") }, "-")
	if sender ~= myself and (not string.gsub(myself, "%s+", "")) then
		return -- spoofed? ignore
	end

	-- Clean out our current overview order
	table.wipe(currentOverviewOrder)

	-- parse text into data
	local phases = { strsplit(strchar(30), text) }
	for _, phaseDataStr in ipairs(phases) do
		if #phaseDataStr ~= 0 then -- last one might be an empty string, let's just make sure
			local phaseData = { strsplit(strchar(31), phaseDataStr) }
			_handleAndAssignPhaseDataTable(phaseData, true)
		end
	end

	for _, callback in ipairs(phaseOverviewCallbacks) do
		callback(currentOverviewOrder, Phase.Store)
	end
	table.wipe(phaseOverviewCallbacks)
end
EpsiLib.EventManager:Register("CHAT_MSG_ADDON", OnPhaseOverviewDataReceived)

--#endregion
--#region Phase Module Systems

---Requests a Phase's Info by ID. Does not handle callback, as that should be handled by wherever calls this instead.
---@param id string|integer
function Phase:RequestPhaseInfo(id)
	EpsiLib.AddonCommands.SendByChat("phase info " .. id .. " addon")
end

---Requests the current Phase Overview list from the server, handling the callback once the entire list / phases are loaded. Callback is passed the currentOverviewOrder and Phase.Store as its 2 args for immediate access.
---@param callback fun(order:table, store:table)
function Phase:RequestOverview(callback)
	EpsiLib.AddonCommands.SendByChat("phase overview addon")
	if callback then
		tinsert(phaseOverviewCallbacks, callback)
	end
end

---Get the current Phase.Store list, ordered by PhaseID
---@return table
function Phase:GetOrderedList()
	local list = {}
	for _, _phase in pairs(self.Store) do
		tinsert(list, _phase)
	end
	table.sort(list, function(a, b) return a.data.id < b.data.id end)
	return list
end

---Gets the current overview order
---@return table
function Phase:GetOverviewList()
	return currentOverviewOrder
end

---Create a baseline phase class object & return it
---@return PhaseClass
function Phase:_Create()
	local phase = CreateFromMixins(PhaseMixin)
	phase.data = {}
	phase.loaded = false

	return phase
end

---Create a new Phase in the Phase Store, if needed. If it already exists, it returns the existing object. If not, it handles creating the object and assigning the phase ID.
---@param id any
---@return PhaseClass _phase, boolean isNew
function Phase:CreateFromID(id)
	-- Check store first & return existing object if found
	if Phase.Store[id] then return Phase.Store[id], false end

	-- Didn't exist, create & init
	local phase = self:_Create()
	phase:_SetPhaseID(id)
	phase:_Init()
	return phase, true
end

---Create or Update a Phase in Store based on info provided. You can use this when locally defining a phase, i.e., from Cache.
---@param id number
---@param name string
---@param icon string
---@param message string
---@param info string
---@param desc string
---@param tags string
---@param color string
---@param background string
---@return PhaseClass
function Phase:CreateFromInfo(id, name, icon, message, info, desc, tags, color, background)
	-- Keep using the old data as a baseline if exists, as there might be additional data stored on it
	local phase = Phase.Store[id] or self:_Create()
	--local phase = self:Create()

	phase.data.id = id
	phase.data.name = name
	phase.data.icon = icon
	phase.data.message = message
	phase.data.info = info
	phase.data.desc = desc
	phase.data.color = color
	phase.data.bg = background

	phase.data.tags = phase.data.tags or {}
	wipe(phase.data.tags)
	tAppendAll(phase.data.tags, { strsplit(",", tags) })

	phase.loaded = true

	Phase.Store[id] = phase

	return phase
end

---Get a phase from the phase store if it exists, or creates a new one if not. If a new phase is created, callback is async and is called when the phase data is loaded.
---If phase is already loaded, callback is run immediately. Callback is passed the actual phase object as the first arg.
---Returns the phaseClass object, along with if the phase is loaded or not yet, so you know what's happening.
---@param id integer
---@param callback fun(phase:PhaseClass)
---@return PhaseClass phase, boolean isLoaded
function Phase:Get(id, callback)
	local _phase = self:CreateFromID(id) --[[@as PhaseClass]]

	if _phase.loaded then
		if callback then
			callback(_phase)
		end
	else
		_phase:ContinueOnPhaseLoad(callback)
	end

	return _phase, _phase.loaded
end

function Phase:Update(id, callback)
	local _phase, new = self:CreateFromID(id) --[[@as PhaseClass]]

	if not new then
		_phase:Update(callback)
	end

	return _phase, _phase.loaded
end

--#endregion
--#region PhaseMixin / PhaseClass Object Systems

function PhaseMixin:_Clear()
	local tags = self.data.tags
	wipe(tags)
	wipe(self.data)
	self.data.tags = tags
end

---Internal Function to set a specific data value by key
---@param key string
---@param value string
function PhaseMixin:_SetDataByKey(key, value)
	if not key then error("PhaseClass:_SetDataByKey(key, value) - Syntax Error: key cannot be nil") end
	self.data[key] = value
end

---Get a specific data value from the phase; marked _ because there's 'public' accessors for all defined data instead (i.e., PhaseMixin:GetPhaseName())
---@param key string
---@return string
function PhaseMixin:_GetDataByKey(key)
	return self.data[key]
end

---Internal function to set the phaseID on a phase object. By default, clears all current data on the object, but can be passed noClear to retain the old data and only change the ID.
---Honestly you should probably never need this & it likely only should be used by the internal creation sequence.
---@param id number
---@param noClear boolean
function PhaseMixin:_SetPhaseID(id, noClear)
	if not noClear then
		self:_Clear()
		self.loaded = false
	end
	self.data.id = id
	Phase.Store[id] = self
end

---Internal function to initialize a phase object by requesting its data directly from the server. Does not handle callbacks, this should be handled by Phase:Get() or _phase:ContinueOnPhaseLoad()
function PhaseMixin:_Init()
	if not self.data.id then error("EpsiLib:PhaseClass Error: Phase Object _Init called on object with no valid data.id") end
	self.loaded = false -- force mark it as not loaded, as we're requesting data. This is useful in cases like :Update
	Phase:RequestPhaseInfo(self.data.id)
end

---Requests an update of this phase's data, queuing up a callback once it's loaded, if provided.
---@param callback any
function PhaseMixin:Update(callback)
	self:_Init()
	self:ContinueOnPhaseLoad(callback)
end

function PhaseMixin:GetPhaseID()
	return self.data.id
end

function PhaseMixin:GetPhaseName()
	return self.data.name
end

function PhaseMixin:GetPhaseInfo()
	return self.data.info
end

function PhaseMixin:GetPhaseDescription()
	return self.data.desc
end

function PhaseMixin:GetPhaseMessage()
	return self.data.message
end

function PhaseMixin:GetPhaseIcon()
	return self.data.icon
end

---Get Phase Tags
---@return string[]
function PhaseMixin:GetPhaseTags()
	return self.data.tags -- Tags is an array of tags, may need this changed to a k,v but for now it is what it is
end

---Get the Phase Color, as a ColorMixin Object, or nil if no color assigned.
---@return ColorMixin? color
function PhaseMixin:GetPhaseColor()
	return (self.data.color and CreateColorFromHexCode(self.data.color)) or nil
end

function PhaseMixin:GetPhaseBackground()
	return self.data.bg
end

---If the phase is already loaded, runs the callback immediately. If not, sets the callback to run when the phase data has finished loading. Does not actually request the phase to load though. Use :Get() instead if needed.
---@param callback fun(phase:PhaseClass)
function PhaseMixin:ContinueOnPhaseLoad(callback)
	if not callback then return end
	local id = self:GetPhaseID()
	if self.loaded then
		callback(self)
	else
		if not phaseLoadCallbacks[id] then phaseLoadCallbacks[id] = {} end
		tinsert(phaseLoadCallbacks[id], callback)
	end
end

--#endregion

EpsiLib.Classes.Phase = Phase
