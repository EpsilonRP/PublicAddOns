---@class ns
local ns = select(2, ...)

local Constants = ns.Constants

local Main = ns.Main
local flightFrame = Main.flightFrame
local cmd = Main.cmd
local isNotDefined = Main.isNotDefined

local AC = Main.AC
local ACD = Main.ACD
local ACR = Main.ACR
local AceComm = LibStub:GetLibrary("AceComm-3.0")

local contrastText = Constants.COLORS.CONTRAST_RED
local playerName = Constants.playerName

flightFrame.landTimer = 0
flightFrame.isFlying = false
--flightFrame.enabled = true ---- we were using 2 different control points, one in the settings, one on the frame. Consolidate to only 1 setting to reduce annoyance and confusion..

local C_Timer = C_Timer
local IsFlying = IsFlying
local IsFalling = IsFalling
local IsMounted = IsMounted
local IsMountFlying = function()
	return IsFlying() and IsMounted()
end

local GetPlayerAuraBySpellID = C_UnitAuras and C_UnitAuras.GetPlayerAuraBySpellID or GetPlayerAuraBySpellID

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



-- // Prototype Dragon Riding System:

-- Flight mechanic with inertia + Boost
-- Uses VehicleAimGetAngle -> degrees -> speed scaling based on angle

local FlightPitchSpeed = CreateFrame("Frame")
FlightPitchSpeed:RegisterEvent("PLAYER_LOGIN")

-- ===== Configurable Tuning Defaults =====
local DEFAULT_VALUES       = {
	BASE_SPEED           = 3.0,       -- speed when flat (target baseline)
	MAX_SPEED            = 9.3,       -- max speed when steeply diving
	MIN_SPEED            = 1.0,       -- min speed when steeply climbing
	FLAT_DEADZONE        = 5,         -- degrees: ± around 0 considered flat
	ANGLE_SCALE_POW_DSC  = 0.25,      -- shape of angle->speed mapping when descending (1 = linear) -- (0-1) feels better
	ANGLE_SCALE_POW_ASC  = 2.0,       -- shape of angle->speed mapping when ascending (1 = linear) -- (>1) feels better

	ACCEL_RATE           = 5.0,       -- speed units per second when increasing speed (faster acceleration)
	DECEL_RATE           = 1.2,       -- speed units per second when decreasing speed (slower deceleration -> inertia)
	DECEL_RATE_DIVE      = 0.1,       -- speed units per second when decreasing speed after coming out of a dive (keep speed longer)

	BOOST_SPEED_GAIN     = 3.0,       -- default instantaneous boost added to current speed
	BOOST_ALLOW_OVER_MAX = true,      -- if false, boost is clamped to MAX_SPEED
	BOOST_SPEED_MAX      = 14,        -- only used if BOOST_ALLOW_OVER_MAX == true; nil means no upper clamp

	HIGH_SPEED_THRESHOLD = 0,         -- threshold speed to trigger high-speed auras -- 0 = disabled
	HIGH_SPEED_AURAS     = { 1000941, }, -- auras to apply when above threshold

	REQUIRE_MOUNTED      = true,      -- only enable pitch-based speed control when mounted
	REQUIRE_SPELL        = { 356465, }, -- spellIDs that are required to enable GLIDE (as an alternative to being mounted)
}

-- ===== Speed & Inertia config =====
local BASE_SPEED           = DEFAULT_VALUES.BASE_SPEED          -- speed when flat (target baseline)
local MAX_SPEED            = DEFAULT_VALUES.MAX_SPEED           -- max speed when steeply diving
local MIN_SPEED            = DEFAULT_VALUES.MIN_SPEED           -- min speed when steeply climbing
local FLAT_DEADZONE        = DEFAULT_VALUES.FLAT_DEADZONE       -- degrees: ± around 0 considered flat
local ANGLE_SCALE_POW_DSC  = DEFAULT_VALUES.ANGLE_SCALE_POW_DSC -- shape of angle->speed mapping when descending (1 = linear) -- (0-1) feels better
local ANGLE_SCALE_POW_ASC  = DEFAULT_VALUES.ANGLE_SCALE_POW_ASC -- shape of angle->speed mapping when ascending (1 = linear) -- (>1) feels better

local ACCEL_RATE           = DEFAULT_VALUES.ACCEL_RATE          -- speed units per second when increasing speed (faster acceleration)
local DECEL_RATE           = DEFAULT_VALUES.DECEL_RATE          -- speed units per second when decreasing speed (slower deceleration -> inertia)
local DECEL_RATE_DIVE      = DEFAULT_VALUES.DECEL_RATE_DIVE     -- speed units per second when decreasing speed after coming out of a dive (keep speed longer)
local DIVE_GRACE_PERIOD    = 3.0                                -- seconds after diving during which DECEL_RATE_DIVE is used

-- ===== Boost configuration =====
local BOOST_SPEED_GAIN     = DEFAULT_VALUES.BOOST_SPEED_GAIN     -- default instantaneous boost added to current speed
local BOOST_ALLOW_OVER_MAX = DEFAULT_VALUES.BOOST_ALLOW_OVER_MAX -- if false, boost is clamped to MAX_SPEED
local BOOST_SPEED_MAX      = DEFAULT_VALUES.BOOST_SPEED_MAX      -- only used if BOOST_ALLOW_OVER_MAX == true; nil means no upper clamp
local BOOST_KEYBIND        = "SPACE"                             -- keybind to trigger boost

-- ===== Movement / application guards =====
local MIN_MOVE_SPEED       = 0.1  -- minimal movement speed for "moving" check (yards/sec)
local APPLY_EPSILON        = 0.01 -- only apply speed change if difference greater than this
local UPDATE_INTERVAL      = 0.05 -- seconds between checks (throttle)

-- ===== Mounted Requirements =====
local REQUIRE_MOUNTED      = DEFAULT_VALUES.REQUIRE_MOUNTED
local REQUIRE_SPELL        = CopyTable(DEFAULT_VALUES.REQUIRE_SPELL)

-- ===== Internal state =====
local lastAppliedSpeed     = nil
local timeSinceUpdate      = 0
local enabled              = false
local personalDisable      = false

-- ===== Glide Auras / Visuals =====
local glideAuras           = {
	highSpeed = { threshold = DEFAULT_VALUES.HIGH_SPEED_THRESHOLD, active = false, auras = CopyTable(DEFAULT_VALUES.HIGH_SPEED_AURAS) },
}

-- =====
-- Saving & Loading Settings from Server for per-phase config:

local function applySettingsFromTable(t)
	if not t then return end

	BASE_SPEED                     = tonumber(t.BASE_SPEED) or BASE_SPEED
	MAX_SPEED                      = tonumber(t.MAX_SPEED) or MAX_SPEED
	MIN_SPEED                      = tonumber(t.MIN_SPEED) or MIN_SPEED
	FLAT_DEADZONE                  = tonumber(t.FLAT_DEADZONE) or FLAT_DEADZONE
	--UPDATE_INTERVAL      = tonumber(t.UPDATE_INTERVAL) or UPDATE_INTERVAL
	ANGLE_SCALE_POW_DSC            = tonumber(t.ANGLE_SCALE_POW_DSC) or ANGLE_SCALE_POW_DSC
	ANGLE_SCALE_POW_ASC            = tonumber(t.ANGLE_SCALE_POW_ASC) or ANGLE_SCALE_POW_ASC

	ACCEL_RATE                     = tonumber(t.ACCEL_RATE) or ACCEL_RATE
	DECEL_RATE                     = tonumber(t.DECEL_RATE) or DECEL_RATE
	DECEL_RATE_DIVE                = tonumber(t.DECEL_RATE_DIVE) or DECEL_RATE_DIVE

	MIN_MOVE_SPEED                 = tonumber(t.MIN_MOVE_SPEED) or MIN_MOVE_SPEED
	--APPLY_EPSILON        = tonumber(t.APPLY_EPSILON) or APPLY_EPSILON

	BOOST_SPEED_GAIN               = tonumber(t.BOOST_SPEED_GAIN) or BOOST_SPEED_GAIN
	BOOST_ALLOW_OVER_MAX           = (t.BOOST_ALLOW_OVER_MAX == true) or BOOST_ALLOW_OVER_MAX
	BOOST_SPEED_MAX                = (t.BOOST_SPEED_MAX ~= nil) and tonumber(t.BOOST_SPEED_MAX) or BOOST_SPEED_MAX

	REQUIRE_MOUNTED                = (t.REQUIRE_MOUNTED == true) or REQUIRE_MOUNTED
	REQUIRE_SPELL                  = t.REQUIRE_SPELL or REQUIRE_SPELL

	glideAuras.highSpeed.threshold = t.HIGH_SPEED_THRESHOLD or glideAuras.highSpeed.threshold
	glideAuras.highSpeed.auras     = t.HIGH_SPEED_AURAS or glideAuras.highSpeed.auras

	-- enabled is optional; if provided, use it
	if t.enabled ~= nil then
		enabled = not not t.enabled
	end

	-- Reset runtime state to ensure new settings take effect cleanly
	lastAppliedSpeed = nil
	timeSinceUpdate = 0

	-- Alert settings UI of update if needed
	ACR:NotifyChange("Kinesis-Settings");
end

local function collectSettingsToTable()
	return {
		BASE_SPEED           = BASE_SPEED,
		MAX_SPEED            = MAX_SPEED,
		MIN_SPEED            = MIN_SPEED,
		FLAT_DEADZONE        = FLAT_DEADZONE,
		--UPDATE_INTERVAL      = UPDATE_INTERVAL,
		ANGLE_SCALE_POW_DSC  = ANGLE_SCALE_POW_DSC,
		ANGLE_SCALE_POW_ASC  = ANGLE_SCALE_POW_ASC,

		ACCEL_RATE           = ACCEL_RATE,
		DECEL_RATE           = DECEL_RATE,
		DECEL_RATE_DIVE      = DECEL_RATE_DIVE,

		MIN_MOVE_SPEED       = MIN_MOVE_SPEED,
		--APPLY_EPSILON        = APPLY_EPSILON,

		BOOST_SPEED_GAIN     = BOOST_SPEED_GAIN,
		BOOST_ALLOW_OVER_MAX = BOOST_ALLOW_OVER_MAX,
		BOOST_SPEED_MAX      = BOOST_SPEED_MAX,

		HIGH_SPEED_THRESHOLD = glideAuras.highSpeed.threshold,
		HIGH_SPEED_AURAS     = glideAuras.highSpeed.auras,

		REQUIRE_MOUNTED      = REQUIRE_MOUNTED,
		REQUIRE_SPELL        = REQUIRE_SPELL,

		enabled              = enabled,
	}
end

local function LoadSettingsFromServer(callback)
	EpsilonLib.PhaseAddonData.LoadTable("KN_DR_SETTINGS", function(data)
		if data then
			applySettingsFromTable(data)
		else
			applySettingsFromTable(DEFAULT_VALUES)
			enabled = false
		end
		if callback then callback(data) end
	end)
end

-- Auto-load settings on login (keep original handler intact by hooking) & updating live phase changes
local kn_prefix = "KN_DR_UPDATE"
local phaseChangeWatcher = EpsilonLib.EventManager:Register("EPSILON_PHASE_CHANGE", function(self, event, phaseID)
	LoadSettingsFromServer()
end)

local broadcastChannel = "xtensionxtooltip2" -- default channel
local broadcastChannelID = GetChannelName(broadcastChannel)

local function updateBroadcastChannelID()
	broadcastChannelID = GetChannelName(broadcastChannel)
end

-- Update settings when the phases settings are updated
C_ChatInfo.RegisterAddonMessagePrefix(kn_prefix)
AceComm:RegisterComm(kn_prefix, function(prefix, message, channel, sender)
	if sender == playerName then
		return; -- ignore self
	end
	if C_Epsilon.GetPhaseId() == message then
		LoadSettingsFromServer()
	end
end)

local function notifyPhaseSettingsUpdated()
	local phaseID = C_Epsilon.GetPhaseId()
	if not broadcastChannelID or broadcastChannelID == 0 then
		updateBroadcastChannelID()
	end
	AceComm:SendCommMessage(kn_prefix, phaseID, "CHANNEL", broadcastChannelID)
end

local function SaveSettingsToServer()
	local data = collectSettingsToTable()
	EpsilonLib.PhaseAddonData.SaveTable("KN_DR_SETTINGS", data)
	C_Timer.After(0.1, notifyPhaseSettingsUpdated)
end

ns.DRSettings = ns.DRSettings or {}
ns.DRSettings.SaveToServer = SaveSettingsToServer
ns.DRSettings.LoadFromServer = LoadSettingsFromServer
ns.DRSettings.ApplyFromTable = applySettingsFromTable
ns.DRSettings.CollectToTable = collectSettingsToTable
ns.DRSettings.GetDefaults = function() return DEFAULT_VALUES end



-- Helper for checking if flying state meets mounted requirements
local flyCheck = function()
	if not IsFlying() then return false end -- early exit if not flying

	-- from here on, we know they are flying already, so return true unless other special requirements needed
	if REQUIRE_MOUNTED then
		if IsMounted() then
			return true
		else
			-- check exceptions
			if #REQUIRE_SPELL > 0 then
				for _, spellID in ipairs(REQUIRE_SPELL) do
					if GetPlayerAuraBySpellID(tonumber(spellID)) then
						return true
					end
				end
			end
			return false
		end
		return false
	elseif #REQUIRE_SPELL > 0 then
		for _, spellID in ipairs(REQUIRE_SPELL) do
			if GetPlayerAuraBySpellID(tonumber(spellID)) then
				return true
			end
		end
		return false
	end

	-- no special requirements, just flying
	return true
end

-- Helper: clamp
local function clamp(v, lo, hi)
	if lo and v < lo then return lo end
	if hi and v > hi then return hi end
	return v
end

local inDiveGracePeriod = false
local diveGraceTimer = nil
local function dive()
	inDiveGracePeriod = true
	if diveGraceTimer then
		diveGraceTimer:Cancel()
		diveGraceTimer = nil
	end
	diveGraceTimer = C_Timer.NewTimer(DIVE_GRACE_PERIOD, function()
		inDiveGracePeriod = false
	end)
end
local function endDive()
	inDiveGracePeriod = false
	if diveGraceTimer then
		diveGraceTimer:Cancel()
		diveGraceTimer = nil
	end
end

local function isInImmersiveFlight()
	if enabled and not personalDisable and flyCheck() then
		return true
	end
end

-- Map pitch (degrees) to a target speed
local function computeTargetSpeed(pitchDeg)
	if pitchDeg >= -FLAT_DEADZONE and pitchDeg <= FLAT_DEADZONE then
		return BASE_SPEED
	end

	if pitchDeg < -45 then
		dive()
	elseif pitchDeg > 45 then
		endDive()
	end

	if pitchDeg < -FLAT_DEADZONE then
		-- diving -> increase speed between BASE and MAX
		local diveAmount = clamp((-pitchDeg) / 90, 0, 1)
		diveAmount = diveAmount ^ ANGLE_SCALE_POW_DSC
		return BASE_SPEED + (MAX_SPEED - BASE_SPEED) * diveAmount
	else
		-- climbing -> reduce speed between BASE and MIN
		local climbAmount = clamp(pitchDeg / 90, 0, 1)
		climbAmount = climbAmount ^ ANGLE_SCALE_POW_ASC
		return BASE_SPEED - (BASE_SPEED - MIN_SPEED) * climbAmount
	end
end

-- Move current toward target with different rates for accel/decel (inertia)
local function approachWithInertia(current, target, elapsed)
	if current == target then return current end

	local decelRate = inDiveGracePeriod and DECEL_RATE_DIVE or DECEL_RATE
	if decelRate == 0 then return current end

	local diff = target - current
	local rate = (diff > 0) and ACCEL_RATE or decelRate
	local maxDelta = rate * elapsed

	-- clamp by remaining distance and step toward target
	if math.abs(diff) <= maxDelta then
		return target
	end

	return current + (diff > 0 and 1 or -1) * maxDelta
end

-- Internal helper to issue ARC command safely
local function applySpeed(speed)
	local formatted = ("%.3f"):format(speed)
	cmd(("mod speed fly %s"):format(formatted))
	lastAppliedSpeed = speed

	-- High Speed Auras
	if (glideAuras.highSpeed.threshold > 0) and (speed > glideAuras.highSpeed.threshold) then
		if not glideAuras.highSpeed.active then
			glideAuras.highSpeed.active = true
			for k, v in ipairs(glideAuras.highSpeed.auras) do
				cmd("aura " .. (v) .. " self")
			end
		end
	else
		if glideAuras.highSpeed.active then
			glideAuras.highSpeed.active = false
			for k, v in ipairs(glideAuras.highSpeed.auras) do
				cmd("unaura " .. (v) .. " self")
			end
		end
	end
end

-- Public Boost function: instantly add `amount` to current speed (or use default)
-- Only applies when flying and moving. Respects clamping based on BOOST_ALLOW_OVER_MAX.
local function Boost(amount)
	local boostAmt = amount or BOOST_SPEED_GAIN

	-- Only apply while enabled
	if not enabled then return end
	if personalDisable then return end

	-- Only when flying
	if not flyCheck() then return end

	-- Only when moving
	local moveSpeed = GetUnitSpeed("player") or 0
	if moveSpeed <= MIN_MOVE_SPEED then return end

	-- Ensure lastAppliedSpeed is initialized: if nil, compute current target and use that
	if not lastAppliedSpeed then
		local rawAngle = VehicleAimGetAngle and VehicleAimGetAngle() or 0
		local pitchDeg = rawAngle * 360 / (2 * math.pi)
		lastAppliedSpeed = computeTargetSpeed(pitchDeg)
	end

	-- Compute boosted value
	local boosted = lastAppliedSpeed + boostAmt

	if not BOOST_ALLOW_OVER_MAX then
		boosted = clamp(boosted, MIN_SPEED, MAX_SPEED)
	else
		-- if BOOST_ALLOW_OVER_MAX true and BOOST_MAX_LIMIT is set, clamp to that
		if BOOST_SPEED_MAX then
			boosted = clamp(boosted, MIN_SPEED, BOOST_SPEED_MAX)
		else
			boosted = clamp(boosted, MIN_SPEED, nil)
		end
	end

	-- Only apply if difference is enough
	if math.abs(boosted - (lastAppliedSpeed or 0)) >= APPLY_EPSILON then
		applySpeed(boosted)
	else
		-- still update internal state even if no ARC call
		lastAppliedSpeed = boosted
	end
end

local function IsBoostable()
	-- Only apply while enabled
	if not enabled then return false end
	if personalDisable then return false end

	-- Only when flying
	if not flyCheck() then return false end

	-- Only when boost keybind is space
	if not BOOST_KEYBIND or BOOST_KEYBIND:upper() ~= "SPACE" then return false end

	-- Only when moving
	local moveSpeed = GetUnitSpeed("player") or 0
	if moveSpeed <= MIN_MOVE_SPEED then return false end

	return true
end

local JorAS_Override = [[
JumpOrAscendStartBlizz = JumpOrAscendStart
JumpOrAscendStart = function()
	-- If flying, use boost instead of jump
	if GLIDE_API.IsBoostable() then
		GLIDE_API.Boost()
		return
	end
	EpsilonLib.RunScript.raw("JumpOrAscendStartBlizz()")
end
]]
EpsilonLib.RunScript.raw(JorAS_Override)

-- create a boost keybinding
local keybindFrame = CreateFrame("Button", "KN_BOOST_KEYBIND_HOLDER")
keybindFrame:SetScript("OnClick", function(self, button, down)
	Boost()
end)

local function SetBoostKeybind(self, key)
	-- clear existing binding
	if BOOST_KEYBIND then SetOverrideBinding(self, false, BOOST_KEYBIND, nil) end

	-- set new binding
	if key and key ~= "" then
		BOOST_KEYBIND = key:upper()
		if key:upper() ~= "SPACE" then -- don't set a keybind for space, we handle that in JumpOrAscendStart override
			SetOverrideBindingClick(self, false, key, "KN_BOOST_KEYBIND_HOLDER")
		end
	end
end

-- Core update
local function DoFlightUpdate(elapsed)
	if not enabled then return end
	if personalDisable then return end

	timeSinceUpdate = timeSinceUpdate + elapsed
	if timeSinceUpdate < UPDATE_INTERVAL then return end
	local dt = timeSinceUpdate
	timeSinceUpdate = 0

	-- Only when flying
	if not flyCheck() then
		if lastAppliedSpeed then
			-- reset speed when exiting flight mode
			applySpeed(1)
		end

		lastAppliedSpeed = nil
		return
	end

	-- Only when moving
	local moveSpeed = GetUnitSpeed("player") or 0
	if moveSpeed <= MIN_MOVE_SPEED then
		return
	end

	-- Get pitch degrees
	local rawAngle = VehicleAimGetAngle and VehicleAimGetAngle() or 0
	local pitchDeg = rawAngle * 360 / (2 * math.pi)

	-- Compute target speed
	local target = computeTargetSpeed(pitchDeg)

	-- Initialize lastAppliedSpeed if needed
	if not lastAppliedSpeed then
		lastAppliedSpeed = target
	end

	-- Apply inertia: move lastAppliedSpeed toward target using approachWithInertia
	local newSpeed = approachWithInertia(lastAppliedSpeed, target, dt)

	-- Decide how to apply speed changes:
	-- Apply the computed inertial step whenever it actually moves the speed (even if it's small),
	-- to avoid snapping directly to the target when maxDelta < APPLY_EPSILON (which made very
	-- small decel rates appear to instantly drop to the target).
	local stepDiff = math.abs(newSpeed - lastAppliedSpeed)
	local targetDiff = math.abs(target - lastAppliedSpeed)

	if stepDiff > 0 then
		-- apply the inertial step (may be small)
		applySpeed(newSpeed)
	elseif targetDiff >= APPLY_EPSILON then
		-- fallback: no inertial step available but target is meaningfully different, snap to target
		applySpeed(target)
	end
end

-- OnUpdate handler
local function OnUpdate(self, elapsed)
	DoFlightUpdate(elapsed)
end

FlightPitchSpeed:SetScript("OnEvent", function(self, event, ...)
	if event == "PLAYER_LOGIN" then
		self:SetScript("OnUpdate", OnUpdate)
	end
end)

local function strToNumArray(s)
	local t = {}
	for str in string.gmatch(s, '([^,]+)') do
		table.insert(t, tonumber(str))
	end
	return t
end

-- Public API for runtime tuning and Boost
local dragonRidingAPI = {
	Enable                     = function() enabled = true end,
	Disable                    = function() enabled = false end,
	IsEnabled                  = function() return enabled end,
	SetEnabled                 = function(k) enabled = k end,

	InFlight                   = isInImmersiveFlight,

	-- tuning setters
	SetBaseSpeed               = function(v) BASE_SPEED = v end,
	GetBaseSpeed               = function() return BASE_SPEED end,

	SetMaxSpeed                = function(v) MAX_SPEED = v end,
	GetMaxSpeed                = function() return MAX_SPEED end,

	SetMinSpeed                = function(v) MIN_SPEED = v end,
	GetMinSpeed                = function() return MIN_SPEED end,

	SetFlatDeadzone            = function(v) FLAT_DEADZONE = v end,
	GetFlatDeadzone            = function() return FLAT_DEADZONE end,

	SetUpdateInterval          = function(v) UPDATE_INTERVAL = v end,
	GetUpdateInterval          = function() return UPDATE_INTERVAL end,

	SetAngleScalePowDsc        = function(v) ANGLE_SCALE_POW_DSC = v end,
	GetAngleScalePowDsc        = function() return ANGLE_SCALE_POW_DSC end,

	GetAngleScalePowAsc        = function() return ANGLE_SCALE_POW_ASC end,
	SetAngleScalePowAsc        = function(v) ANGLE_SCALE_POW_ASC = v end,

	-- Inertia
	SetAccelRate               = function(v) ACCEL_RATE = v end,
	GetAccelRate               = function() return ACCEL_RATE end,

	SetDecelRate               = function(v) DECEL_RATE = v end,
	GetDecelRate               = function() return DECEL_RATE end,

	SetDecelDiveRate           = function(v) DECEL_RATE_DIVE = v end,
	GetDecelDiveRate           = function() return DECEL_RATE_DIVE end,

	-- Boost API
	Boost                      = Boost,
	IsBoostable                = IsBoostable,

	-- Boost config helpers (optional convenience)
	SetBoostSpeed              = function(v) BOOST_SPEED_GAIN = v end,
	GetBoostSpeed              = function() return BOOST_SPEED_GAIN end,

	SetBoostMax                = function(v) BOOST_SPEED_MAX = v end,
	GetBoostMax                = function() return BOOST_SPEED_MAX end,

	AllowBoostOverMax          = function(allow, maxLimit)
		BOOST_ALLOW_OVER_MAX = not not allow; BOOST_SPEED_MAX = maxLimit
	end,
	GetAllowBoostOverMax       = function() return BOOST_ALLOW_OVER_MAX, BOOST_SPEED_MAX end,

	SetBoostKeybind            = SetBoostKeybind,
	GetBoostKeybind            = function() return BOOST_KEYBIND end,

	GetHSAuras                 = function() return glideAuras.highSpeed.auras end,
	SetHSAuras                 = function(t) glideAuras.highSpeed.auras = t end,
	GetHSAurasString           = function() return table.concat(glideAuras.highSpeed.auras, ", ") end,
	SetHSAurasString           = function(s) glideAuras.highSpeed.auras = strToNumArray(s) end,
	GetHSThreshold             = function() return glideAuras.highSpeed.threshold end,
	SetHSThreshold             = function(v) glideAuras.highSpeed.threshold = v end,

	GetRequireMounted          = function() return REQUIRE_MOUNTED end,
	SetRequireMounted          = function(v) REQUIRE_MOUNTED = not not v end,

	SetRequireSpells           = function(t) REQUIRE_SPELL = t end,
	GetRequireSpells           = function() return REQUIRE_SPELL end,
	SetRequireSpellsString     = function(s) REQUIRE_SPELL = strToNumArray(s) end,
	GetRequireSpellsString     = function() return table.concat(REQUIRE_SPELL, ", ") end,

	SetPersonalDisableOverride = function(disable)
		personalDisable = not not disable
	end,
	GetPersonalDisableOverride = function() return not not personalDisable end,
}
ns.DR_API = dragonRidingAPI
GLIDE_API = dragonRidingAPI -- global access

-- End of FlightPitchSpeed_Inertia_Boost

-- IDEA: Immersive Speed mode: W to increase speed, S to decrease speed, double tap W to boost, double tap S for quick stop
-- IDEA: Visual indicator of current pitch and speed (like flight instruments) (Integrate with FlyPitch addon)
-- IDEA: Special effects for boosting, leveling out, diving, climbing / Ideas: Arcane Buildup (250693); Speed Up (314489)
-- I.e., wind rush when boosting, slight blur effect when at max speed, etc.
-- TODO: Adjust IsMountFlying as a toggle, or add a whitelist of spells?
