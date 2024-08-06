---@class ns
local ns = select(2, ...)

---@enum (key) SpellFlags
local spell_flags = {
	num_flags = 0,

	SKYBOX_SPELLS_UPDATED_TO_SL = 1 -- 2^0 = 1

	--[[ Examples:
	FLAG_ONE = 1, -- 2^0
	FLAG_TWO = 2, -- 2^1
	FLAG_THREE = 4, -- 2^2
	FLAG_FOUR = 8 -- 2^3
	--]]
}


-- Utility table for flag operations
local flagUtil = {}

-- Raw Functions - These act on a field explicitly and must be called with value = function(value, flag) to update the value.
-- Use the flagUtil main functions as wrappers when called on a table to update that tables 'flags' field directly.
do
	flagUtil.raw = {}
	function flagUtil.raw._add(field, flag)
		if not field then field = 0 end
		return bit.bor(field, flag)
	end

	function flagUtil.raw._remove(field, flag)
		if not field then field = 0 end
		return bit.band(field, bit.bnot(flag))
	end

	function flagUtil.raw._has(field, flag)
		if not field then return false end
		return bit.band(field, flag) ~= 0
	end
end

-- Function to check if a flag exists
function flagUtil.hasFlag(table, flag)
	if not table.flags then table.flags = 0 end
	return flagUtil.raw._has(table.flags, flag)
end

-- Function to add a flag
function flagUtil.addFlag(table, flag)
	if not table.flags then table.flags = 0 end
	table.flags = flagUtil.raw._add(table.flags, flag)
	return table.flags
end

-- Function to remove a flag
function flagUtil.removeFlag(table, flag)
	if not table.flags then table.flags = 0 end
	table.flags = flagUtil.raw._remove(table.flags, flag)
	return table.flags
end

---@class Utils_Flags
ns.Utils.Flags = {
	raw = flagUtil.raw,
	add = flagUtil.addFlag,
	remove = flagUtil.removeFlag,
	has = flagUtil.hasFlag,

	spell_flags = spell_flags,
}
