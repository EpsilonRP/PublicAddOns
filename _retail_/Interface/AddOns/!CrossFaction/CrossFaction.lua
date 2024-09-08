local currentVersion = GetAddOnMetadata("!CrossFaction", "Version")
local author = GetAddOnMetadata("!CrossFaction", "Author")

local factionGroup, factionName = UnitFactionGroup("PLAYER")
function UnitFactionGroup(unit, name)
	return factionGroup, factionName
end

UnitFullNameOld = UnitFullName
function UnitFullName(unit)
	return (UnitFullNameOld(unit)), select(2, UnitFullNameOld("player"))
end

SLASH_CFACT1, SLASH_CFACT2 = '/cf', '/crossfaction'; -- 3.
function SlashCmdList.CFACT(msg, editbox)            -- 4.
	print("CrossFaction v" .. currentVersion .. " by " .. author .. " running.")
end
