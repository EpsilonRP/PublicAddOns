---@class ns
local ns = select(2, ...)
local Constants = ns.Constants

local Main = ns.Main
local sprintFrame = Main.sprintFrame
local cmd = Main.cmd
local playerName = Constants.playerName

local defaultSpeedWalk = 1.6
local defaultSpeedFly = 10
local defaultSpeedSwim = 10

local isNotDefined = ns.Main.isNotDefined

local contrastText = Constants.COLORS.CONTRAST_RED

local function emote(text)
	SendChatMessage(text, "EMOTE");
end

---@param num number the number to round
---@param n integer number of decimal places
---@return number number the rounded number
local function roundToNthDecimal(num, n)
	local mult = 10 ^ (n or 0)
	return math.floor(num * mult + 0.5) / mult
end

----------------------------
--#region Speed Updating
----------------------------

local sprintSpeedTypes = {
	["walk"] = "Walk",
	["fly"] = "Fly",
	["swim"] = "Swim",
	--["backwalk"] = "Backwalk", -- WoW API can't give us backwalk speed..
}
local sprintSpeedDivisors = {
	["walk"] = 7,
	["fly"] = 7,
	["swim"] = 4.7222876548767,
	--["backwalk"] = 4.5
}

local speeds = { currentSpeed = 0, returnSpeedWalk = sprintSpeedDivisors["walk"], returnSpeedFly = sprintSpeedDivisors["fly"], returnSpeedSwim = sprintSpeedDivisors["swim"] }
local currentSpeeds = {} -- reusable table

local function updateSpeeds()
	currentSpeeds.actual, currentSpeeds.walk, currentSpeeds.fly, currentSpeeds.swim = GetUnitSpeed("player")
	speeds.currentSpeed = currentSpeeds.actual
	for k, v in pairs(sprintSpeedTypes) do
		local sprintSpeed = KinesisOptions.profiles[KinesisCharOptions.activeProfile].sprint["speed" .. v]
		local returnSpeed = speeds["returnSpeed" .. v]
		local currentSpeed = roundToNthDecimal(currentSpeeds[k], 2)
		local sprintSpeedNormal = roundToNthDecimal(sprintSpeed * sprintSpeedDivisors[k], 2)
		if returnSpeed ~= currentSpeed then
			if currentSpeed ~= sprintSpeedNormal then
				if currentSpeed == 0 then
					--speeds["returnSpeed" .. v] = sprintSpeedDivisors[k]
				else
					speeds["returnSpeed" .. v] = currentSpeed
				end
			end
		end
	end
end

----------------------------
--#endregion
----------------------------
----------------------------
--#region Sprint Spell Controls
----------------------------

local spellsActive
local arcanumActive

-- Cast Spells Command
local function castSpellList()
	spellsActive = true
	for k, v in ipairs(KinesisOptions.profiles[KinesisCharOptions.activeProfile].sprint.spellList) do
		-- Ensure that it's a proper number, to avoid invalid entries.
		if tonumber(v) ~= nil then
			cmd("aura " .. tostring(v) .. " self")
		end
	end
end

-- Unaura the Cast Spells
local function unauraSpells()
	spellsActive = false
	for k, v in ipairs(KinesisOptions.profiles[KinesisCharOptions.activeProfile].sprint.spellList) do
		-- Ensure that it's a proper number, to avoid invalid entries (again).
		if tonumber(v) ~= nil then
			cmd("unaura " .. tostring(v) .. " self")
		end
	end
end

local function addSpellToSpellList(id)
	if id and tonumber(id) then
		tinsert(KinesisOptions.profiles[KinesisCharOptions.activeProfile].sprint.spellList, tonumber(id))
	end
end

local function removeSpellFromSpellList(id)
	if id and tonumber(id) then
		id = tonumber(id)
		--tDeleteItem(KinesisOptions.profiles[KinesisCharOptions.activeProfile].sprint.spellList, id)
		local table = KinesisOptions.profiles[KinesisCharOptions.activeProfile].sprint.spellList
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
	wipe(KinesisOptions.profiles[KinesisCharOptions.activeProfile].sprint.spellList)
end

local function saveSpellListToStorage(name, overwrite, spellListData)
	if not spellListData then spellListData = KinesisOptions.profiles[KinesisCharOptions.activeProfile].sprint.spellList end
	if name then
		if KinesisOptions.sprintSpellListStorage[name] and not overwrite then
			ns.Dialogs.showGenericConfirmation("Do you want to overwrite your current Spell Set (" .. contrastText:WrapTextInColorCode(name) .. ")?", function()
				saveSpellListToStorage(name, true, spellListData)
			end)
		else
			KinesisOptions.sprintSpellListStorage[name] = CopyTable(spellListData)
			ns.Menu.menuFrame:RefreshMenuForUpdates()
		end
	end
end

local function loadSpellListFromStorage(name)
	if name and KinesisOptions.sprintSpellListStorage[name] then
		KinesisOptions.profiles[KinesisCharOptions.activeProfile].sprint.spellList = CopyTable(KinesisOptions.sprintSpellListStorage[name])
	end
end

local function deleteSpellListFromStorage(name)
	if name then
		KinesisOptions.sprintSpellListStorage[name] = nil
	end
end

---@return table AceGUISelectValuesTable
---@return table OriginalSpellListTable
local function getSpellsInCurrentProfileList()
	local t = {}
	for k, v in ipairs(KinesisOptions.profiles[KinesisCharOptions.activeProfile].sprint.spellList) do
		local spellName = GetSpellInfo(v)
		t[v] = "(" .. v .. ") " .. (spellName and spellName or "Unknown")
	end
	return t, KinesisOptions.profiles[KinesisCharOptions.activeProfile].sprint.spellList
end

---@return table AceGUISelectValuesTable
---@return table SortedKeysTable
local function getSpellListsInStorage()
	local t, tSort = {}, {}
	for k, v in pairs(KinesisOptions.sprintSpellListStorage) do
		t[k] = k
		tinsert(tSort, k)
	end
	table.sort(tSort)
	return t, tSort
end

----------------------
--#endregion
----------------------

local emoteRateLimited = false
local sprintDualHoldToggleModeTimer = C_Timer.NewTimer(0, function() end) -- init as a timer object
local function resetEmoteRateLimited()
	emoteRateLimited = false
end

function sprintFrame:sprintStart()
	updateSpeeds()
	if speeds.currentSpeed > 0 or KinesisOptions.profiles[KinesisCharOptions.activeProfile].sprint.allowSprintWhenNotMoving then
		local sprintSettings = KinesisOptions.profiles[KinesisCharOptions.activeProfile].sprint
		local sendSpells = sprintSettings.sendSpells
		local sendEmote = sprintSettings.sendEmote

		for k, v in pairs(sprintSpeedTypes) do
			local speed = sprintSettings["speed" .. v]
			local sprintEnabled = sprintSettings["speed" .. v .. "Enabled"]
			if sprintEnabled and speed > 0 then
				cmd(("mod speed %s %s"):format(k, speed))
			end
		end

		local isFlying = IsFlying()
		local isSwimming = IsSwimming()
		--if sendSpells == 1 or (sendSpells == 2 and not isFlying and not isSwimming) or (sendSpells == 3 and isFlying) or (sendSpells == 4 and isSwimming) then
		if (isFlying and sendSpells.fly) or (isSwimming and sendSpells.swim) or (not isFlying and not isSwimming and sendSpells.walk) then
			if ARC and sprintSettings.arcanumToggle and not (isNotDefined(sprintSettings.arcanumStart) or sprintSettings.arcanumStart == false) then
				ARC:CAST(sprintSettings.arcanumStart)
				arcanumActive = true
			end
			castSpellList()
		end

		if not emoteRateLimited then
			if (isFlying and sendEmote.fly) or (isSwimming and sendEmote.swim) or (not isFlying and not isSwimming and sendEmote.walk) then
				emote(sprintSettings.emoteMessage)
				emoteRateLimited = true
				local emoteRateLimit = sprintSettings.emoteRateLimit
				C_Timer.After(emoteRateLimit >= 0.5 and emoteRateLimit or 5, function() emoteRateLimited = false end)
			end
		end

		self.isSprinting = true
		local sprintMode = KinesisOptions.global.sprintMode
		if (sprintMode == "toggle" or sprintMode == "dual") or (sprintSettings.enableCtrlSprintToggle and IsControlKeyDown()) then
			self.isSprintingToggle = true
			if sprintMode == "dual" then
				local delayTime = sprintSettings.toggleHoldShiftDelay or 0.35
				sprintDualHoldToggleModeTimer = C_Timer.NewTimer(delayTime, function() self.isSprintingToggle = false end)
			end
		end
	end
end

function sprintFrame:sprintStop()
	local sprintSettings = KinesisOptions.profiles[KinesisCharOptions.activeProfile].sprint

	if sprintSettings.sprintReturnLastSpeed then
		for k, v in pairs(sprintSpeedTypes) do
			local speed = speeds["returnSpeed" .. v]
			local speedToUse = roundToNthDecimal(speed / sprintSpeedDivisors[k], 2)
			if speedToUse <= 0 then
				print("Warning: Speed returned as <= 0 for speed type: %s. Please report this along with the next line.")
				print("Relevant Debug Speeds:", "current=", speeds.currentSpeed, "returnActual=", speed, "returnRound=", speedToUse, " sprint=",
					KinesisOptions.profiles[KinesisCharOptions.activeProfile].sprint["speed" .. v])
				if speed <= 0 then
					speedToUse = 1
				else
					speedToUse = speed -- use the unrounded one idfk
				end
			end
			cmd(("mod speed %s %s"):format(k, speedToUse))
		end
	else
		cmd("mod speed 1")
	end

	if spellsActive then
		unauraSpells()
	end
	if ARC and arcanumActive and sprintSettings.arcanumToggle and not (isNotDefined(sprintSettings.arcanumStop) or sprintSettings.arcanumStop == false) then
		ARC:CAST(sprintSettings.arcanumStop)
		arcanumActive = false
	end

	sprintDualHoldToggleModeTimer:Cancel()
	self.isSprinting = false
	self.isSprintingToggle = false
end

local SPRINT_KEY = "LSHIFT"

sprintFrame:EnableKeyboard(true); sprintFrame:SetPropagateKeyboardInput(true);
sprintFrame.isSprinting = false
sprintFrame:SetScript("OnKeyDown", function(self, key)
	self:SetPropagateKeyboardInput(key ~= SPRINT_KEY)
	if key ~= SPRINT_KEY then return end

	-- exit if sprinting is globally disabled.
	local sprintSettings = KinesisOptions.profiles[KinesisCharOptions.activeProfile].sprint
	if not sprintSettings.enabled then return end

	if self.isSprinting then
		if self.isSprintingToggle then
			self:sprintStop()
			return
		else
			return
		end
	end
	self:sprintStart()
end)

sprintFrame:SetScript("OnKeyUp", function(self, key)
	--if key ~= SPRINT_KEY then return end -- our propagate block stops any other keys but shift from firing OnKeyUp
	if self.isSprinting == true then
		if self.isSprintingToggle then return end -- if the sprint is a toggle, we do not want to stop sprinting when we release sprint, obvs.
		self:sprintStop()
	end
end)

ns.Sprint = {
	updateSpeeds = updateSpeeds,
	speedWalkDefault = defaultSpeedWalk,
	speedFlyDefault = defaultSpeedFly,
	speedSwimDefault = defaultSpeedSwim,

	addSpellToSpellList = addSpellToSpellList,
	removeSpellFromSpellList = removeSpellFromSpellList,
	removeAllSpellsFromSpellList = removeAllSpellsFromSpellList,
	getSpellsInCurrentProfileList = getSpellsInCurrentProfileList,

	saveSpellListToStorage = saveSpellListToStorage,
	loadSpellListFromStorage = loadSpellListFromStorage,
	deleteSpellListFromStorage = deleteSpellListFromStorage,
	getSpellListsInStorage = getSpellListsInStorage,

	resetEmoteRateLimited = resetEmoteRateLimited,
}
