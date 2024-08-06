---@class ns
local ns = select(2, ...)

---comment
---@param spell VaultSpell
local function mig_UpdateSkyboxSpellIDs(spell, verbose)
	-- Update Skybox Spell IDs
	local startSkyboxID = 350001
	local endSkyboxID = 353865
	local skyboxAdjustment = 650000

	local hadUpdate = false

	-- Actions
	local actionsTypesToCheck = {
		[ns.Actions.Data.ACTION_TYPE.SpellAura] = true,
		[ns.Actions.Data.ACTION_TYPE.SpellCast] = true,
		[ns.Actions.Data.ACTION_TYPE.SpellTrig] = true,
		[ns.Actions.Data.ACTION_TYPE.RemoveAura] = true,
		[ns.Actions.Data.ACTION_TYPE.ToggleAura] = true,
		[ns.Actions.Data.ACTION_TYPE.ToggleAuraSelf] = true,
		[ns.Actions.Data.ACTION_TYPE.GroupAura] = true,
		[ns.Actions.Data.ACTION_TYPE.GroupUnaura] = true,
		[ns.Actions.Data.ACTION_TYPE.PhaseAura] = true,
		[ns.Actions.Data.ACTION_TYPE.PhaseUnaura] = true,
		[ns.Actions.Data.ACTION_TYPE.Kinesis_SprintSetSpells] = true,
		[ns.Actions.Data.ACTION_TYPE.Kinesis_FlightSetSpells] = true,

	}

	for k, action in ipairs(spell.actions) do
		if actionsTypesToCheck[action.actionType] then
			action.vars, hadUpdate = ns.Utils.Data.adjustNumbersInRange(action.vars, startSkyboxID, endSkyboxID, skyboxAdjustment)
		end
	end

	-- Conditions
	if spell.conditions then
		local conditionTypesToCheck = {
			hasAura = true,
			hasAuraNum = true,
			isSpellOnCooldown = true,
			tarAura = true,
			tarAuraNum = true,
		}

		for k, conditionsGroup in ipairs(spell.conditions) do
			for _, condition in ipairs(conditionsGroup) do
				if conditionTypesToCheck[condition.Type] then
					condition.Input, hadUpdate = ns.Utils.Data.adjustNumbersInRange(condition.Input, startSkyboxID, endSkyboxID, skyboxAdjustment)
				end
			end
		end
	end

	ns.Utils.Flags.add(spell, ns.Utils.Flags.spell_flags.SKYBOX_SPELLS_UPDATED_TO_SL)
	if hadUpdate and verbose then
		ns.Logging.cprint(("Migrated ArcSpell (%s): %s"):format(spell.commID, "Skybox Spells Updated"))
		return true
	end
	return false
end

local migrations = {
	{
		name = "Skybox Spells Updated",
		relatedFlag = "SKYBOX_SPELLS_UPDATED_TO_SL",
		func = mig_UpdateSkyboxSpellIDs,
	},
}

local function migrateSpell(spell, verbose)
	for k, mig in ipairs(migrations) do
		local flag_name = mig.name
		if mig.relatedFlag then flag_name = mig.relatedFlag end

		local flag_value = ns.Utils.Flags.spell_flags[flag_name]

		if not ns.Utils.Flags.has(spell, flag_value) then
			local alreadyAnnounced = mig.func(spell, verbose)
			ns.Logging.dprint(false, ("Running Mig (%s) on %s"):format(mig.name, spell.commID))
			if verbose and alreadyAnnounced == nil then
				ns.Logging.cprint(("Migrated ArcSpell (%s): %s"):format(spell.name, mig.name))
			end
		end
	end
end

local function applyDefaultSpellMigrationFlags(spell)
	-- Only use on new spells that don't need migrations
	for k, mig in ipairs(migrations) do
		local flag_name = mig.name
		if mig.relatedFlag then flag_name = mig.relatedFlag end
		local flag_value = ns.Utils.Flags.spell_flags[flag_name]

		ns.Utils.Flags.add(spell, flag_value)
	end
end

---@class Actions_Migrations
ns.Actions.Migrations = {
	run = migrations,
	migrateSpell = migrateSpell,
	applyDefaultSpellMigrationFlags = applyDefaultSpellMigrationFlags,
}
