local EpsilonLib, EpsiLib = ...;

EpsiLib.RunScript = EpsiLib.RunScript or {}
local runScript = EpsiLib.RunScript
_G[EpsilonLib].RunScript.SecureScriptReturns = {}

local runPrivileged = C_Epsilon.RunPrivileged
local returnTablePath = tostring(EpsilonLib) .. ".RunScript.SecureScriptReturns"

function runScript.run(script)
    script = "local vars = {" .. script .. "}; " .. returnTablePath .. " = vars;"
    runPrivileged(script)
    return unpack(_G[EpsilonLib].RunScript.SecureScriptReturns)
end

function runScript.raw(script)
    runPrivileged(script)
end