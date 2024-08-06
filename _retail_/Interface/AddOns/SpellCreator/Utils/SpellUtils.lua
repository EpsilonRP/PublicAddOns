---@class ns
local ns = select(2, ...)

---@class Utils_SpellUtils
local spell = {}

---@param _spell VaultSpell
spell.GetDuration = function(_spell)
	local duration = 0
	for _, action in ipairs(_spell.actions) do
		duration = max(duration, action.delay, (action.revertDelay or 0))
	end

	return duration
end


---@class Utils_SpellUtils
ns.Utils.SpellUtils = spell
