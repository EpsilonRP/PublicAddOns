local EpsilonLib, EpsiLib = ...;

-- Add PhaseID to MiniMap Zone Tooltip
local grey = CreateColor(0.8, 0.8, 0.8)
local phaseNameOverrides = {
	[169] = "Main Phase",
}

local lastPhaseInfo = {
	name = nil,
	id = 169,
	color = nil
}

local phaseTextFormat = "%s " .. grey:WrapTextInColorCode("(%s)")

hooksecurefunc("Minimap_SetTooltip", function()
	local phaseID = tonumber(C_Epsilon.GetPhaseId())
	local name = lastPhaseInfo.name

	if phaseNameOverrides[phaseID] then name = phaseNameOverrides[phaseID] end

	local text
	if not name then
		text = phaseID
	else
		if lastPhaseInfo.color then name = WrapTextInColorCode(name, lastPhaseInfo.color) end
		text = phaseTextFormat:format(name, phaseID)
	end

	GameTooltip:AddDoubleLine("Phase: ", text, nil, nil, nil, 1, 1, 1)
	GameTooltip:Show() -- To fix the displayed padding
end)

local function joinedPhaseListener(self, event, message)
	--  You have joined phase |cff00CCFF[Prophecy - Fall of Lordaeron - 100]|r.
	local name, phase = message:match("^You have joined phase |cff00CCFF%[(.+) %- (%d+)%]|r%.")
	lastPhaseInfo.name = name
	lastPhaseInfo.id = tonumber(phase)
end
local function leftPhaseListener(self, event, message)
	lastPhaseInfo.name = "Main Phase"
	lastPhaseInfo.id = 169
end

EpsiLib.EventManager:RegisterSimpleCommandWatcher("You have joined phase |cff", joinedPhaseListener)
EpsiLib.EventManager:RegisterSimpleCommandWatcher("You have been returned to the main world from phase |cff", leftPhaseListener)
