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

    return degrees*(math.pi/180);
end

function EpsiLib.Utils:ConvertToDegrees(radians)

    return radians*(180/math.pi);
end