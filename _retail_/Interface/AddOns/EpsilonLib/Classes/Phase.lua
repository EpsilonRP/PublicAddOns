local EpsilonLib, EpsiLib = ...;

local Phase = {
	Store = {}
}
local PhaseMixin = {}

local phaseLoadCallbacks = {}

local function _handleAndAssignPhaseDataTable(phaseData)
	if not phaseData then return end

	-- If passed string instead of table, split into chunks
	if type(phaseData) == "string" then
		phaseData = { strsplit(strchar(31), phaseData) }
	end

	local phaseID = phaseData[1]

	local keyedData = {
		phaseID = phaseData[1],
		name = phaseData[2],
		icon = phaseData[3],
		message = phaseData[4],
		info = phaseData[5],
		desc = phaseData[6],
		tags = phaseData[7],
		color = phaseData[7],
		background = phaseData[7],
	}

	-- assign data to phase
	local phase = Phase.Store[phaseID] or Phase:Create()
	Mixin(phase.data, keyedData)

	-- run callbacks
	if phaseLoadCallbacks[phaseID] then
		for _, callback in ipairs(phaseLoadCallbacks[phaseID]) do
			callback()
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

	-- parse text into data
	local phases = { strsplit(strchar(30), text) }
	for k, phaseDataStr in ipairs(phases) do
		if #phaseDataStr ~= 0 then -- last one might be an empty string, let's just make sure
			local phaseData = { strsplit(strchar(31), phaseDataStr) }
			_handleAndAssignPhaseDataTable(phaseData)
		end
	end
end
EpsiLib.EventManager:Register("CHAT_MSG_ADDON", OnPhaseDataReceived)

local function requestOverviewData()
	EpsiLib.AddonCommands.SendByChat("phase overview addon")
end

function Phase:Create()
	local phase = CreateFromMixins(PhaseMixin)
	phase.data = {}

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

function Phase:CreateFromInfo(id, name, icon, message, info, desc, tags, color, background)
	-- trust that this is being called from accurate info and allow it to replace the old data
	--local phase = Phase.Store[id] or self:Create()
	local phase = self:Create()

	phase.data.id = id
	phase.data.name = name
	phase.data.icon = icon
	phase.data.message = message
	phase.data.info = info
	phase.data.desc = desc
	phase.data.tags = { strsplit(",", tags) }
	phase.data.color = color
	phase.data.bg = background

	Phase.Store[id] = phase

	return phase
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
	end
	self.data.id = id
	Phase.Store[id] = self
end

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
	--return self.data.color -- This should be converted into a color object - is that at request time, or at declaration though?
end

function PhaseMixin:GetPhaseBackground()
	return self.data.bg
end

function PhaseMixin:ContinueOnPhaseLoad(callback)
	local id = self:GetPhaseID()
	if Phase.Store[id] then
		callback()
	else
		if not phaseLoadCallbacks[id] then phaseLoadCallbacks[id] = {} end
		tinsert(phaseLoadCallbacks[id], callback)
	end
end

EpsiLib.Classes.Phase = Phase
