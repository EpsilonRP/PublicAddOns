local EpsilonLib, EpsiLib = ...;

EpsiLib.Cheat = {}

local myName = UnitNameUnmodified("player")

local function executeOnly(disableOverride)
	return { executeOnly = true, disableOverride = disableOverride }
end

local cheatData = {
	bank      = executeOnly(CloseBankFrame or C_Bank.CloseBankFrame),
	barber    = executeOnly(C_BarberShop.Cancel),
	casttime  = { msg = "Instant cast time is (...?)", default = false, on = "|cff00CCFF[Cheat] Instant cast time|r cheat has been |cff00CCFFenabled|r", off = "|cff00CCFF[Cheat] Instant cast time|r cheat has been |cff00CCFFdisabled|r" },
	cooldown  = { msg = "No cooldown is (...?)", default = false, on = "|cff00CCFF[Cheat] No cooldown|r cheat has been |cff00CCFFenabled|r", off = "|cff00CCFF[Cheat] No cooldown|r cheat has been |cff00CCFFdisabled|r" },
	duration  = { msg = "Infinite aura duration is (...?)", default = true, on = "|cff00CCFF[Cheat] Infinite aura duration|r cheat has been |cff00CCFFenabled|r", off = "|cff00CCFF[Cheat] Infinite aura duration|r cheat has been |cff00CCFFdisabled|r" },
	fly       = { msg = "Fly Mode has been set to (...?)%.", default = false, on = "|cff00CCFF[" .. myName .. "]|r's Fly Mode has been set to |cff00CCFFon|r.", off = "|cff00CCFF[" .. myName .. "]|r's Fly Mode has been set to |cff00CCFFoff|r." },
	god       = { msg = "Godmode is (...?)", default = true, on = "|cff00CCFF[Cheat] Godmode|r cheat has been |cff00CCFFenabled|r", off = "|cff00CCFF[Cheat] Godmode|r cheat has been |cff00CCFFdisabled|r" },
	mail      = executeOnly(CloseMail),
	power     = { msg = "No mana/rage/energy spell cost is (...?)", default = false, on = "|cff00CCFF[Cheat] No mana/rage/energy spell cost|r cheat has been |cff00CCFFenabled|r", off = "|cff00CCFF[Cheat] No mana/rage/energy spell cost|r cheat has been |cff00CCFFdisabled|r" },
	slowcast  = { msg = "Long spell cast & channel time is (...?)", default = false, on = "|cff00CCFF[Cheat] Long spell cast & channel time|r cheat has been |cff00CCFFenabled|r", off = "|cff00CCFF[Cheat] Long spell cast & channel time|r cheat has been |cff00CCFFdisabled|r" },
	tabard    = executeOnly(function() HideUIPanel(TabardFrame) end),
	waterwalk = { msg = "Walking on water is (...?)", default = false, on = "|cff00CCFF[Cheat] Walking on water|r cheat has been |cff00CCFFenabled|r", off = "|cff00CCFF[Cheat] Walking on water|r cheat has been |cff00CCFFdisabled|r" },
}

local cheatStatus = {}
for k, v in pairs(cheatData) do
	if v.default ~= nil then
		cheatStatus[k] = v.default
	end
end

EpsiLib.Cheat.Status = cheatStatus
EpsiLib.Cheat._cheatData = cheatData

local function normalizeCheat(cheat)
	if type(cheat) ~= "string" then return end -- this includes a nil check, as type(nil) == "nil"
	cheat = cheat:lower()
	if cheatData[cheat] then return cheat end
	if cheat:sub(1, 4) == "mail" then return "mail" end -- anything starting with mail is just changed to mail .. idc if it's mailinthehouseboxthing, IT'S MAIL NOW!
	return
end

function EpsiLib.Cheat.GetCheatStatus(cheat)
	cheat = normalizeCheat(cheat)
	if not cheat then return cheatStatus end
	return cheatStatus[cheat]
end

function EpsiLib.Cheat.SetCheatStatus(cheat, val)
	cheat = normalizeCheat(cheat)
	if not cheat then return end
	if cheatStatus[cheat] == nil then error(("No such cheat as %s, or the cheat does not have a state (on/off)."):format(cheat)) end
	cheatStatus[cheat] = val
end

local cheatCommandFormat = "cheat %s %s"
function EpsiLib.Cheat.Enable(cheat, vocal)
	cheat = normalizeCheat(cheat)
	if not cheat then return end
	if cheatData[cheat] == nil then error(("No such cheat as %s."):format(cheat)) end

	local enableFlag = "on"
	if cheatData[cheat].executeOnly then
		enableFlag = ""
	end

	local command = cheatCommandFormat:format(cheat, enableFlag)
	EpsiLib.AddonCommands.Send("EpsiLib_Cheat", command, nil, vocal)
end

function EpsiLib.Cheat.Disable(cheat, vocal)
	cheat = normalizeCheat(cheat)
	if not cheat then return end
	if cheatData[cheat] == nil then error(("No such cheat as %s."):format(cheat)) end

	local disableFlag = "off"
	if cheatData[cheat].executeOnly then
		disableFlag = ""

		if cheatData[cheat].disableOverride then
			cheatData[cheat].disableOverride()
			return
		end
	end

	local command = cheatCommandFormat:format(cheat, disableFlag)
	EpsiLib.AddonCommands.Send("EpsiLib_Cheat", command, nil, vocal)
end

--- Watching for manual changes to cheat status + updating at login

local function cheatStatusCallback(success, messages)
	if not success then return end
	for i = 1, #messages do
		local msg = messages[i]:gsub("|cff%x%x%x%x%x%x", ""):gsub("|r", "")
		for k, v in pairs(cheatData) do
			if not v.executeOnly then -- skip executeOnly cheats, they have no data to check or update
				local matchStr = msg:match(v.msg)
				if matchStr then
					EpsiLib.Cheat.SetCheatStatus(k, ((matchStr == "on") and true or false))
				end
			end
		end
	end
end

EpsiLib.EventManager:Register("ADDON_LOADED", function(_, event, addon)
	if addon == EpsilonLib then
		EpsiLib.AddonCommands.Send("EpsiLib_UPM", "cheat status", cheatStatusCallback, false)
		EpsiLib.AddonCommands.Send("EpsiLib_UPM", "cheat fly", nil, false) -- don't care to listen to this one
		EpsiLib.AddonCommands.Send("EpsiLib_UPM", "cheat fly", cheatStatusCallback, false)
	end
end)

local cheatMessages = {}
for k, v in pairs(cheatData) do
	if v.on and v.off then
		cheatMessages[v.on] = { type = true, ref = k }
		cheatMessages[v.off] = { type = false, ref = k }
	end
end

local function cheatToggleListener(self, event, message)
	if cheatMessages[message] then
		local table = cheatMessages[message]

		EpsiLib.Cheat.SetCheatStatus(table.ref:lower(), table.type)

		return false
	end
end
EpsiLib.EventManager:AddCommandFilter(cheatToggleListener)
