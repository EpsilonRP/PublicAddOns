---@class ns
local ns = select(2, ...)

local Constants = ns.Constants

local Main = ns.Main
local flightFrame = Main.flightFrame
local cmd = Main.cmd
local isNotDefined = Main.isNotDefined

local contrastText = Constants.COLORS.CONTRAST_RED
local playerName = Constants.playerName

flightFrame.landTimer = 0
flightFrame.isFlying = false
--flightFrame.enabled = true ---- we were using 2 different control points, one in the settings, one on the frame. Consolidate to only 1 setting to reduce annoyance and confusion..

local C_Timer = C_Timer
local IsFlying = IsFlying
local IsFalling = IsFalling

----------------------------
--#region Flight Spell Controls
----------------------------

local spellsActive
local arcanumActive

-- Cast Spells Command
local function castSpellList()
	spellsActive = true
	for k, v in ipairs(KinesisOptions.profiles[KinesisCharOptions.activeProfile].flight.spellList) do
		-- Ensure that it's a proper number, to avoid invalid entries.
		if tonumber(v) ~= nil then
			cmd("aura " .. tostring(v) .. " self")
		end
	end
end

-- Unaura the Cast Spells
local function unauraSpells()
	spellsActive = false
	for k, v in ipairs(KinesisOptions.profiles[KinesisCharOptions.activeProfile].flight.spellList) do
		-- Ensure that it's a proper number, to avoid invalid entries (again).
		if tonumber(v) ~= nil then
			cmd("unaura " .. tostring(v) .. " self")
		end
	end
end

local function castArcStartSpells()
	local flightSettings = KinesisOptions.profiles[KinesisCharOptions.activeProfile].flight

	if not (isNotDefined(flightSettings.arcanumStart) or flightSettings.arcanumStart == false) then
		ARC:CAST(flightSettings.arcanumStart)
	end

	arcanumActive = true
end

local function castArcStopSpells()
	local flightSettings = KinesisOptions.profiles[KinesisCharOptions.activeProfile].flight

	if arcanumActive then
		if not (isNotDefined(flightSettings.arcanumStop) or flightSettings.arcanumStop == false) then
			ARC:CAST(flightSettings.arcanumStop)
		end
	end

	arcanumActive = false
end

local function addSpellToSpellList(id)
	if id and tonumber(id) then
		tinsert(KinesisOptions.profiles[KinesisCharOptions.activeProfile].flight.spellList, tonumber(id))
	end
end

local function removeSpellFromSpellList(id)
	if id and tonumber(id) then
		id = tonumber(id)
		--tDeleteItem(KinesisOptions.profiles[KinesisCharOptions.activeProfile].flight.spellList, id)
		local table = KinesisOptions.profiles[KinesisCharOptions.activeProfile].flight.spellList
		local index = 1;
		while table[index] do
			if (id == table[index]) then
				tremove(table, index);
				return -- this differs from tDeleteItem in that we want to end early on the first successful removal instead of continuing to remove more.
			else
				index = index + 1;
			end
		end
	end
end

local function removeAllSpellsFromSpellList()
	wipe(KinesisOptions.profiles[KinesisCharOptions.activeProfile].flight.spellList)
end

local function saveSpellListToStorage(name, overwrite, spellListData)
	if not spellListData then spellListData = KinesisOptions.profiles[KinesisCharOptions.activeProfile].flight.spellList end
	if name then
		if KinesisOptions.flightSpellListStorage[name] and not overwrite then
			ns.Dialogs.showGenericConfirmation("Do you want to overwrite your current Spell Set (" .. contrastText:WrapTextInColorCode(name) .. ")?", function()
				saveSpellListToStorage(name, true, spellListData)
			end)
		else
			KinesisOptions.flightSpellListStorage[name] = CopyTable(spellListData)
			ns.Menu.menuFrame:RefreshMenuForUpdates()
		end
	end
end

local function loadSpellListFromStorage(name)
	if name and KinesisOptions.flightSpellListStorage[name] then
		KinesisOptions.profiles[KinesisCharOptions.activeProfile].flight.spellList = CopyTable(KinesisOptions.flightSpellListStorage[name])
	end
end

local function deleteSpellListFromStorage(name)
	if name then
		KinesisOptions.flightSpellListStorage[name] = nil
	end
end

---@return table AceGUISelectValuesTable
---@return table OriginalSpellListTable
local function getSpellsInCurrentProfileList()
	local t = {}
	for k, v in ipairs(KinesisOptions.profiles[KinesisCharOptions.activeProfile].flight.spellList) do
		local spellName = GetSpellInfo(v)
		t[v] = "(" .. v .. ") " .. (spellName and spellName or "Unknown")
	end
	return t, KinesisOptions.profiles[KinesisCharOptions.activeProfile].flight.spellList
end

---@return table AceGUISelectValuesTable
---@return table SortedKeysTable
local function getSpellListsInStorage()
	local t, tSort = {}, {}
	for k, v in pairs(KinesisOptions.flightSpellListStorage) do
		t[k] = k
		tinsert(tSort, k)
	end
	table.sort(tSort)
	return t, tSort
end

----------------------
--#endregion
----------------------

local efdFrame = CreateFrame("Frame")

local function efdOnUpdate()
	local flightSettings = KinesisOptions.profiles[KinesisCharOptions.activeProfile].flight
	-- if not flightSettings.enabled then return end -- Nope, we want this to function even if they disable Flight Controls
	if Main.getTempDisable("flight") then return; end

	if IsFlying() then
		if not spellsActive then castSpellList() end

		if not arcanumActive and flightSettings.arcanumToggle and ARC then castArcStartSpells() end
	else
		if spellsActive then unauraSpells() end

		if arcanumActive and flightSettings.arcanumToggle and ARC then castArcStopSpells() end
	end
end

local efdActive
---@param toggle boolean
local function toggleExtendedFlightDetection(toggle)
	if toggle == false or (toggle ~= true and efdActive) then
		efdActive = false
		efdFrame:SetScript("OnUpdate", nil)
	else
		efdActive = true
		efdFrame:SetScript("OnUpdate", efdOnUpdate)
	end
end

---OnUpdate Function that watches for if you have landed, then starts counting to disable flying.
---@param self frame the frame passed from the OnUpdate
---@param elapsed number Time Elapsed, private
local function hookLandingOnUpdate(self, elapsed)
	local flightSettings = KinesisOptions.profiles[KinesisCharOptions.activeProfile].flight
	if not flightFrame.isFlying or not flightSettings.enabled or flightSettings.landDelay == 0 then return; end
	if Main.getTempDisable("flight") then return; end

	if not IsFlying() and not IsFalling() then
		if self.landTimer > (tonumber(flightSettings.landDelay) or 1) then
			flightFrame.ToggleFlight(false)
		end
		self.landTimer = self.landTimer + elapsed
	else
		self.landTimer = 0
	end
end

function flightFrame.SetLandingOnUpdate(switch)
	if switch == true then
		flightFrame:SetScript("OnUpdate", hookLandingOnUpdate)
		flightFrame.landTimer = -1
	else
		flightFrame:SetScript("OnUpdate", nil)
	end
end

function flightFrame.ToggleFlight(switch)
	local flightSettings = KinesisOptions.profiles[KinesisCharOptions.activeProfile].flight
	local sendSpells = flightSettings.sendSpells

	if switch == true then
		cmd("cheat fly on")
		flightFrame.isFlying = true
		flightFrame.SetLandingOnUpdate(true)

		if sendSpells and not KinesisOptions.global.extendedFlightDetection then -- if KinesisOptions.global.extendedFlightDetection then we skip because the OnUpdate will handle it.
			if ARC and flightSettings.arcanumToggle then
				castArcStartSpells()
			end
			castSpellList()
		end
	else
		cmd("cheat fly off")
		flightFrame.isFlying = false
		flightFrame.SetLandingOnUpdate(false)

		if sendSpells and not KinesisOptions.global.extendedFlightDetection then -- if KinesisOptions.global.extendedFlightDetection then we skip because the OnUpdate will handle it.
			if spellsActive then
				unauraSpells()
			end
			if ARC and arcanumActive and flightSettings.arcanumToggle then
				castArcStopSpells()
			end
		end
	end
end

local spaceCount = 0
hooksecurefunc("JumpOrAscendStart", function()
	--if not flightFrame.enabled then return end
	local flightSettings = KinesisOptions.profiles[KinesisCharOptions.activeProfile].flight
	if not flightSettings.enabled then return end
	if Main.getTempDisable("flight") then return; end

	local numJumpsRequired = 2
	if flightSettings.tripleJump then numJumpsRequired = 3 end

	flightFrame.landTimer = 0
	spaceCount = spaceCount + 1

	local maxKeyDelay = tonumber(flightSettings.maxKeyDelay)
	if flightFrame.fallTimer then flightFrame.fallTimer:Cancel() end
	flightFrame.fallTimer = C_Timer.NewTicker(maxKeyDelay, function()
		spaceCount = 0
	end)

	if IsFalling() then
		if spaceCount >= numJumpsRequired then
			if flightSettings.needShift and not IsShiftKeyDown() then return; end
			flightFrame.ToggleFlight(true)
			spaceCount = 0
		end
	end
	if IsFlying() then
		if flightSettings.jumpToLand > 0 and spaceCount == flightSettings.jumpToLand then
			flightFrame.ToggleFlight(false)
		elseif not flightFrame.isFlying then
			flightFrame.isFlying = true
			flightFrame.SetLandingOnUpdate(true)
		end
	end
end)

local channels = {
	["CHAT_MSG_SYSTEM"] = true,
	["CHAT_MSG_ACHIEVEMENT"] = true,
	["CHAT_MSG_BN_WHISPER_INFORM"] = true,
	["CHAT_MSG_COMBAT_XP_GAIN"] = true,
	["CHAT_MSG_COMBAT_HONOR_GAIN"] = true,
	["CHAT_MSG_COMBAT_FACTION_CHANGE"] = true,
	["CHAT_MSG_TRADESKILLS"] = true,
	["CHAT_MSG_OPENING"] = true,
	["CHAT_MSG_PET_INFO"] = true,
	["CHAT_MSG_COMBAT_MISC_INFO"] = true,
	["CHAT_MSG_BG_SYSTEM_HORDE"] = true,
	["CHAT_MSG_BG_SYSTEM_ALLIANCE"] = true,
	["CHAT_MSG_BG_SYSTEM_NEUTRAL"] = true,
	["CHAT_MSG_TARGETICONS"] = true,
	--["CHAT_MSG_BN_CONVERSATION_NOTICE"] = true,
}
Main.controlFrame:SetScript("OnEvent", function(self, event, text, ...)
	if channels[event] then
		if text:match("Fly Mode has been set to .*on") then
			flightFrame.isFlying = true
			flightFrame.SetLandingOnUpdate(true)
		elseif text:match("Fly Mode has been set to .*off") then
			flightFrame.isFlying = false
			flightFrame.SetLandingOnUpdate(false)
		end
	end
end)

for k, v in pairs(channels) do
	Main.controlFrame:RegisterEvent(k)
end

ns.Flight = {
	addSpellToSpellList = addSpellToSpellList,
	removeSpellFromSpellList = removeSpellFromSpellList,
	removeAllSpellsFromSpellList = removeAllSpellsFromSpellList,
	getSpellsInCurrentProfileList = getSpellsInCurrentProfileList,

	saveSpellListToStorage = saveSpellListToStorage,
	loadSpellListFromStorage = loadSpellListFromStorage,
	deleteSpellListFromStorage = deleteSpellListFromStorage,
	getSpellListsInStorage = getSpellListsInStorage,

	toggleExtendedFlightDetection = toggleExtendedFlightDetection,
}
