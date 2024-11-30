---@class ns
local ns = select(2, ...)

local checkForAuraIDPredicate = function(wantedID, _, _, ...)
	local spellID = select(10, ...)
	return spellID == wantedID
end

-- SL 927 TODO: Convert to GetPlayerAuraBySpellID(id) for player.
local function checkForAuraID(wantedID, unit)
	local helpful = { AuraUtil.FindAura(checkForAuraIDPredicate, unit, nil, tonumber(wantedID)) }
	if #helpful > 0 then
		return unpack(helpful)
	else
		return AuraUtil.FindAura(checkForAuraIDPredicate, unit, "HARMFUL", tonumber(wantedID))
	end
end

local function checkPlayerAuraID(wantedID)
	return checkForAuraID(wantedID, "player")
end

local function checkTargetAuraID(wantedID)
	return checkForAuraID(wantedID, "target")
end

---Toggle aura from self or target
---@param spellID number|string The Spell ID to check
---@param useTarget boolean? A tri-state boolean. Nil = adaptive, will use target if DM is enabled & target available. False = always use player. True = always use target.
local function toggleAura(spellID, useTarget)
	if useTarget == nil then
		if C_Epsilon.IsDM and UnitExists("target") then
			useTarget = true
		else
			useTarget = false
		end
	end

	local func = checkPlayerAuraID
	local auraComm = "aura "
	local unauraComm = "unaura "

	if useTarget then
		func = checkTargetAuraID
		local isNPC = not UnitIsPlayer('target')
		if isNPC then
			auraComm = "npc set aura "
			unauraComm = "npc set unaura "
		end
	end

	if func(tonumber(spellID)) then
		ns.Cmd.cmd(unauraComm .. spellID .. (useTarget and "" or " self"))
	else
		ns.Cmd.cmd(auraComm .. spellID .. (useTarget and "" or " self"))
	end
end

---@class Utils_Aura
ns.Utils.Aura = {
	checkForAuraID = checkForAuraID,
	checkPlayerAuraID = checkPlayerAuraID,
	checkTargetAuraID = checkTargetAuraID,
	toggleAura = toggleAura
}
