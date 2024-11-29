local EpsilonLib, EpsiLib = ...;

local Phase = {
	Store = {}
}
local PhaseMixin = {}

local phaseLoadCallbacks = {}
local phaseOverviewCallbacks = {}
local currentOverviewOrder = {}

local function _handleAndAssignPhaseDataTable(phaseData)
	if not phaseData then return end

	-- If passed string instead of table, split into chunks
	if type(phaseData) == "string" then
		phaseData = { strsplit(strchar(31), phaseData) }
	end

	local phaseID = tonumber(phaseData[1])

	local _phase = Phase:CreateFromInfo(phaseID, phaseData[2], phaseData[3], phaseData[4], phaseData[5], phaseData[6], phaseData[7], phaseData[8], phaseData[9])

	-- track it's order in currentOverviewOrder for possible display purposes
	table.insert(currentOverviewOrder, _phase)

	-- run callbacks
	if phaseLoadCallbacks[phaseID] then
		for _, callback in ipairs(phaseLoadCallbacks[phaseID]) do
			callback(_phase)
		end
		phaseLoadCallbacks[phaseID] = nil -- Clear it
	end
end

local function OnPhaseDataReceived(self, event, prefix, text, channel, sender, ...)
	-- Check it's a message for us!
	if prefix ~= "EPSILON_PH_INFO" then return end -- not what we're looking for

	local myself = table.concat({ UnitFullName("PLAYER") }, "-")
	if sender ~= myself and (not string.gsub(myself, "%s+", "")) then
		return -- spoofed? ignore
	end

	-- Clean out our current overview order
	table.wipe(currentOverviewOrder)

	-- parse text into data
	local phases = { strsplit(strchar(30), text) }
	for k, phaseDataStr in ipairs(phases) do
		if #phaseDataStr ~= 0 then -- last one might be an empty string, let's just make sure
			local phaseData = { strsplit(strchar(31), phaseDataStr) }
			_handleAndAssignPhaseDataTable(phaseData)
		end
	end

	for _, callback in ipairs(phaseOverviewCallbacks) do
		callback(currentOverviewOrder, Phase.Store)
	end
	table.wipe(phaseOverviewCallbacks)
end
EpsiLib.EventManager:Register("CHAT_MSG_ADDON", OnPhaseDataReceived)

function Phase:RequestOverview(callback)
	EpsiLib.AddonCommands.SendByChat("phase overview addon")
	if callback then
		tinsert(phaseOverviewCallbacks, callback)
	end
end

function Phase:GetOrderedList()
	local list = {}
	for _, _phase in pairs(self.Store) do
		tinsert(list, _phase)
	end
	table.sort(list, function(a, b) return a.data.id < b.data.id end)
	return list
end

function Phase:GetOverviewList()
	return currentOverviewOrder
end

---Create a baseline phase class object & return it
---@return PhaseClass
function Phase:Create()
	local phase = CreateFromMixins(PhaseMixin)
	phase.data = {}
	phase.loaded = false

	return phase
end

function Phase:CreateFromID(id)
	-- Check store first & return existing object if found
	if Phase.Store[id] then return Phase.Store[id] end

	-- Didn't exist, create & init
	local phase = self:Create()
	phase:_SetPhaseID(id)
	--phase:_Init()
	return phase
end

---Create or Update a Phase in Store based on info
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
	local phase = Phase.Store[id] or self:Create()
	--local phase = self:Create()

	phase.data.id = id
	phase.data.name = name
	phase.data.icon = icon
	phase.data.message = message
	phase.data.info = info
	phase.data.desc = desc
	phase.data.tags = { strsplit(",", tags) }
	phase.data.color = color
	phase.data.bg = background

	phase.loaded = true

	Phase.Store[id] = phase

	return phase
end

function Phase:Get(id, callback)
	local _phase = self:CreateFromID(id) --[[@as PhaseClass]]

	if _phase.loaded then
		callback(_phase)
	else
		_phase:ContinueOnPhaseLoad(callback)
	end

	return _phase
end

function PhaseMixin:_Clear()
	wipe(self.data)
end

function PhaseMixin:_SetDataByKey(key, value)
	if not key then error("PhaseClass:_SetDataByKey(key, value) - Syntax Error: key cannot be nil") end
	self.data[key] = value
end

function PhaseMixin:_GetDataByKey(key)
	return self.data[key]
end

function PhaseMixin:_SetPhaseID(id, noClear)
	if not noClear then
		self:_Clear()
		self.loaded = false
	end
	self.data.id = id
	Phase.Store[id] = self

	self:_Init()
end

-- Goal of this function is singular calls to request a specific phases information
function PhaseMixin:_Init()
	--C_Epsilon.RequestPhaseInfo(self.id) -- Maybe?
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

function PhaseMixin:GetPhaseTags()
	return self.data.tags -- Tags is an array of tags, may need this changed to a k,v but for now it is what it is
end

function PhaseMixin:GetPhaseColor()
	return (self.data.color and CreateColorFromHexCode(self.data.color)) or nil
end

function PhaseMixin:GetPhaseBackground()
	return self.data.bg
end

function PhaseMixin:ContinueOnPhaseLoad(callback)
	local id = self:GetPhaseID()
	if self.loaded then
		callback(self)
	else
		if not phaseLoadCallbacks[id] then phaseLoadCallbacks[id] = {} end
		tinsert(phaseLoadCallbacks[id], callback)
	end
end

EpsiLib.Classes.Phase = Phase
