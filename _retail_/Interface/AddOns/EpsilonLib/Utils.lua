local EpsilonLib, EpsiLib = ...;

--EpsiLib.Utils = {}

function EpsiLib.Utils:Test()
	return "UTILS WORK";
end

function EpsiLib.Utils:SanitizeMessage(message)
	message = message:gsub("|cff%x%x%x%x%x%x", "");
	message = message:gsub("|r", "");
	return message;
end

function EpsiLib.Utils:Sanitize(message)
	message = message:gsub("[,.%):]$", ""):gsub("%)", "");
	message = message:gsub("%:?", "")
	return message;
end

function EpsiLib.Utils:ConvertToRadians(degrees)
	return degrees * (math.pi / 180);
end

function EpsiLib.Utils:ConvertToDegrees(radians)
	return radians * (180 / math.pi);
end

local trueVal = {
	-- False
	[0] = false,
	["0"] = false,
	["false"] = false,

	--True
	[1] = true,
	["1"] = true,
	["true"] = true
}
function EpsiLib.Utils:ToBoolean(val)
	return trueVal[val]
end

function EpsiLib.Utils:ToNumberOrFalse(val)
	val = tonumber(val)
	if val == 0 then val = false end
	return val
end
