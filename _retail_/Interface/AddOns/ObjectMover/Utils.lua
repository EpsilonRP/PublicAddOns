local addonName = ...
---@class ns
local ns = select(2, ...)

local Constants = ns.Constants
local ADDON_COLOR = Constants.ADDON_COLOR:GenerateHexColorMarkup()
local ADDON_TITLE = Constants.ADDON_TITLE

local function cprint(text)
	print(ADDON_COLOR .. addonName .. ": " .. (text and text or "ERROR") .. "|r")
end

local function sysMsg(text)
	SendSystemMessage(Constants.ADDON_COLOR:WrapTextInColorCode(ADDON_TITLE) .. ": " .. (text and text or "ERROR") .. "|r")
end

local function dprint(force, text, ...)
	local statements = { ... }
	if type(force) ~= "boolean" then
		table.insert(statements, 1, text)
		text = force
		force = false
	end

	if #statements == 0 then tinsert(statements, "") end -- avoid printing nil on unpack by padding an empty string.
	if text and (force == true or OPMasterTable.Options["debug"]) then
		local line = strmatch(debugstack(2), ":(%d+):")
		if line then
			print(ADDON_COLOR .. addonName .. " DEBUG " .. line .. ": " .. text, unpack(statements))
		else
			print(ADDON_COLOR .. addonName .. " DEBUG: " .. text, unpack(statements))
			print(debugstack(2))
		end
	end
end

local function eprint(text, ...)
	local line = strmatch(debugstack(2), ":(%d+):")

	if line then
		print(ADDON_COLOR .. addonName .. " Error @ " .. line .. ": " .. text, ...)
	else
		print(ADDON_COLOR .. addonName .. " @ ERROR: " .. text, ...)
		print(debugstack(2))
	end
end

local function clearMsg(text)
	return text:gsub("|cff%x%x%x%x%x%x", ""):gsub("|r", "")
end

---@type fun(command:string, callbackFn?:fun(success:boolean, messages:string[]), overrideMessages?:boolean)
local sendAddonCmd

---@type fun(commands:string[], callbackFn?:fun(success:boolean, messages:string[]), overrideMessages?:boolean)
local sendAddonCmdChain


if EpsilonLib and EpsilonLib.AddonCommands then
	sendAddonCmd, sendAddonCmdChain = EpsilonLib.AddonCommands.Register("ObjectToolbox")
else
	function sendAddonCmd(text)
		local cmdPref = "i:om:"
		local fullCmd = cmdPref .. text

		C_ChatInfo.SendAddonMessage("Command", fullCmd, "GUILD")
	end
end

local function cmd(text, forceShowReply)
	sendAddonCmd(text, nil, forceShowReply)
end

function OPManagerPrint(text)
	cprint(text)
end

local function OPManagerCMD(mainCom, text, groupCheck, callback, overrideMessages)
	if groupCheck then
		if isGroupSelected then mainCom = mainCom .. " group" end
	end
	local comm
	if mainCom and text then
		comm = (mainCom .. " " .. text)
	else
		comm = (mainCom)
	end
	sendAddonCmd(comm, callback, overrideMessages)
end

local function noop(...)
	return ... -- No Operation function, returns the arguments passed to it.
end


ns.Utils = {
	noop = noop,
	op_cmd = OPManagerCMD,
	cmd = cmd,
	sendCmd = sendAddonCmd,
	cmdChain = sendAddonCmdChain,

	sysMsg = sysMsg,
	cprint = cprint,
	dprint = dprint,
	eprint = eprint,
	clearMsg = clearMsg,
}
