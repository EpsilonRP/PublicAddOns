---@class ns
local ns = select(2, ...)

local GetPlayerAuraBySpellID = C_UnitAuras and C_UnitAuras.GetPlayerAuraBySpellID or GetPlayerAuraBySpellID

local checkForAuraIDPredicate = function(wantedID, _, _, ...)
	local spellID = select(10, ...)
	return spellID == wantedID
end

---@param wantedID number|string The Spell ID to check
---@param unit? UnitId The unit to check; defaults to "player" if not given
---@return AuraData?
local function checkForAuraID(wantedID, unit)
	if not unit then unit = "player" end
	unit = unit:lower()

	-- SL Shortcut for Player Auras
	if unit == "player" then
		return GetPlayerAuraBySpellID(tonumber(wantedID))
	end

	local helpful = { AuraUtil.FindAura(checkForAuraIDPredicate, unit, nil, tonumber(wantedID)) }
	if #helpful > 0 then
		return unpack(helpful, 1, 15)
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
