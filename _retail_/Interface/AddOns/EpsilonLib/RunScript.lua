local EpsilonLib, EpsiLib = ...;

EpsiLib.RunScript = EpsiLib.RunScript or {}
local runScript = EpsiLib.RunScript
EpsiLib.RunScript.SecureScriptReturns = {}

local runPrivileged = C_Epsilon.RunPrivileged
local returnTablePath = "EpsilonLib.RunScript.SecureScriptReturns"

function runScript.run(script)
	script = "local vars = {" .. script .. "}; " .. returnTablePath .. " = vars;"
	runPrivileged(script)
	return unpack(EpsiLib.RunScript.SecureScriptReturns)
end

function runScript.raw(script)
	runPrivileged(script)
end
