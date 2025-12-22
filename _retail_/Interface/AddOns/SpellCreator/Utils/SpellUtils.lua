---@class ns
local ns = select(2, ...)

---@class Utils_SpellUtils
local spell = {}

---@param _spell VaultSpell
spell.GetDuration = function(_spell)
	local duration = 0
	if not _spell.actions then return nil end
	for _, action in ipairs(_spell.actions) do
		duration = max(duration, action.delay, (action.revertDelay or 0))
	end

	return duration
end

spell.GetDescriptionForUI = function(_spell)
	if _spell.description then
		return _spell.description:gsub("||", "|"):gsub("\\n", "\n"):gsub("\\r", "\r")
	end
end


---@class Utils_SpellUtils
ns.Utils.SpellUtils = spell
