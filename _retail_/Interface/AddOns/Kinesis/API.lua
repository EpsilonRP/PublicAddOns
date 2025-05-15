---@class ns
local ns = select(2, ...)

local Constants = ns.Constants

local Main = ns.Main
local Flight = ns.Flight
local Sprint = ns.Sprint
local Dialogs = ns.Dialogs
local Menu = ns.Menu
local menuFrame = ns.Menu.menuFrame

local contrastText = Constants.COLORS.CONTRAST_RED

--#region Profiles

local function setActiveProfile(profileName)
	ns.Main.setActiveProfile(profileName, true)
	menuFrame:RefreshMenuForUpdates()
end

local function createNewProfile(profileName)
	ns.Main.createNewProfile(profileName)
	menuFrame:RefreshMenuForUpdates()
end

--#endregion
--#region Temporary Disable

local function setTempDisableFlight(val)
	if val then
		ns.Main.setTempDisable("flight", val)
	else
		ns.Main.setTempDisable("flight", not ns.Main.getTempDisable("flight"))
	end
end

local function setTempDisableSprint(val)
	if val then
		ns.Main.setTempDisable("sprint", val)
	else
		ns.Main.setTempDisable("sprint", not ns.Main.getTempDisable("sprint"))
	end
end

local function setTempDisableAll(val)
	setTempDisableFlight(val)
	setTempDisableSprint(val)
end

local function TempDisableFlight()
	ns.Main.tempDisableFlight()
end
local function TempDisableSprint()
	ns.Main.tempDisableSprint()
end
local function TempDisableAll()
	ns.Main.tempDisableBoth()
end
local function TempDisableFlightReset()
	ns.Main.removeTempDisableFlight()
end
local function TempDisableSprintReset()
	ns.Main.removeTempDisableSprint()
end
local function TempDisableReset()
	ns.Main.removeTempDisableBoth()
end

--#endregion
--#region Flight

local function setJumpToLand(num)
	local trueVal

	if num == 2 then
		trueVal = true
	elseif num == 3 then
		trueVal = nil
	else
		trueVal = false
	end

	ns.Menu.menuFrame.flight:SetJumpToLand(nil, trueVal)
	menuFrame:RefreshMenuForUpdates()
end

local function setLandingDelay(num)
	ns.Menu.menuFrame.flight:SetLandingDelay(nil, num)
	menuFrame:RefreshMenuForUpdates()
end

local function setExtendedFlightDetection(val)
	KinesisOptions.global.extendedFlightDetection = val
	menuFrame:RefreshMenuForUpdates()
end

--#endregion

--#region Emotes

local function SetEmoteTriggerWalk(val)
	KinesisOptions.profiles[KinesisCharOptions.activeProfile].sprint.sendEmote.walk = val
	menuFrame:RefreshMenuForUpdates()
end
local function SetEmoteTriggerFly(val)
	KinesisOptions.profiles[KinesisCharOptions.activeProfile].sprint.sendEmote.fly = val
	menuFrame:RefreshMenuForUpdates()
end
local function SetEmoteTriggerSwim(val)
	KinesisOptions.profiles[KinesisCharOptions.activeProfile].sprint.sendEmote.swim = val
	menuFrame:RefreshMenuForUpdates()
end

--#endregion

--#region Sprint Spells

local function SetSpellTriggerWalk(val)
	KinesisOptions.profiles[KinesisCharOptions.activeProfile].sprint.sendSpells.walk = val
	menuFrame:RefreshMenuForUpdates()
end
local function SetSpellTriggerFly(val)
	KinesisOptions.profiles[KinesisCharOptions.activeProfile].sprint.sendSpells.fly = val
	menuFrame:RefreshMenuForUpdates()
end
local function SetSpellTriggerSwim(val)
	KinesisOptions.profiles[KinesisCharOptions.activeProfile].sprint.sendSpells.swim = val
	menuFrame:RefreshMenuForUpdates()
end

local function addStandardSprintSpell(val)
	Sprint.addSpellToSpellList(val); menuFrame:RefreshMenuForUpdates()
end
local function removeSprintSpell(val)
	Sprint.removeSpellFromSpellList(val); menuFrame:RefreshMenuForUpdates();
end
local function resetSprintSpells()
	Sprint.removeAllSpellsFromSpellList(); menuFrame:RefreshMenuForUpdates();
end

local function SprintStandardSpellsLoadSet(val)
	Sprint.loadSpellListFromStorage(val)
	menuFrame:RefreshMenuForUpdates()
end

local function SprintStandardSpellsSetSpells(spells)
	local spellTable = { strsplit(",", spells) }
	if #spellTable == 0 then return end
	ns.Sprint.removeAllSpellsFromSpellList()
	for i = 1, #spellTable do
		local v = spellTable[i]
		ns.Sprint.addSpellToSpellList(v)
	end
	menuFrame:RefreshMenuForUpdates()
end

--#endregion
--#region Flight Spells

local function addStandardFlightSpell(val)
	Flight.addSpellToSpellList(val); menuFrame:RefreshMenuForUpdates()
end
local function removeFlightSpell(val)
	Flight.removeSpellFromSpellList(val); menuFrame:RefreshMenuForUpdates();
end
local function resetFlightSpells()
	Flight.removeAllSpellsFromSpellList(); menuFrame:RefreshMenuForUpdates();
end

local function FlightStandardSpellsLoadSet(val)
	Flight.loadSpellListFromStorage(val)
	menuFrame:RefreshMenuForUpdates()
end

local function FlightStandardSpellsSetSpells(spells)
	local spellTable = { strsplit(",", spells) }
	if #spellTable == 0 then return end
	ns.Flight.removeAllSpellsFromSpellList()
	for i = 1, #spellTable do
		local v = spellTable[i]
		ns.Flight.addSpellToSpellList(v)
	end
	menuFrame:RefreshMenuForUpdates()
end

--#endregion
--#region Generic Value Functions

---Generic Set Value Function..
---@param key string
---@param val any
---@param subTable string?
local function genericSafeSetVal(key, val, subTable)
	local table = KinesisOptions.profiles[KinesisCharOptions.activeProfile]
	if subTable and type(subTable) == "table" then
		for i = 1, #subTable do
			table = table[i]
		end
	elseif subTable then -- not a table, string or number? get the single sub table
		table = table[subTable]
	end
	table[key] = val
end

---Easy Function Gen for the genericSafeSetVal function
---@param key string
---@param subTable string?
---@return function
local function genGenericSetFunction(key, subTable)
	local func = function(val)
		genericSafeSetVal(key, val, subTable)
		menuFrame:RefreshMenuForUpdates()
	end
	return func
end

--#endregion
--#region Generic Set Value Functions

local SetFlightControlsEnabled = genGenericSetFunction("enabled", "flight")
local SetShiftSprintEnabled = genGenericSetFunction("enabled", "sprint")

--#endregion

ns.API = {
	--Kinesis = Main.Kinesis,

	-- Profiles
	Profiles = {
		SetActiveProfile = setActiveProfile,
		CreateNewProfile = createNewProfile,
	},

	-- Temporary Override; Mainly for Mini-Games and such where you want to disable Kinesis
	TempDisableAll = TempDisableAll,
	TempDisableReset = TempDisableReset,

	TempDisableFlight = TempDisableFlight,
	TempDisableFlightReset = TempDisableFlightReset,

	TempDisableSprint = TempDisableSprint,
	TempDisableSprintReset = TempDisableSprintReset,

	-- Flight
	Flight = {

		Enable = function()
			SetFlightControlsEnabled(true)
		end,
		Disable = function()
			SetFlightControlsEnabled(false)
		end,
		Get = function()
			return KinesisOptions.profiles[KinesisCharOptions.activeProfile].flight.enabled
		end,
		Toggle = function()
			local enabled = KinesisOptions.profiles[KinesisCharOptions.activeProfile].flight.enabled
			SetFlightControlsEnabled(not enabled)
		end,

		TempDisable = TempDisableFlight(),
		TempDisableReset = TempDisableFlightReset(),

		IsCreativeFlying = function() return ns.Main.flightFrame.isFlying end,

		SetFlightControlsEnabled = SetFlightControlsEnabled,
		GetFlightControlsEnabled = function() return KinesisOptions.profiles[KinesisCharOptions.activeProfile].flight.enabled end,

		SetEFDEnabled = setExtendedFlightDetection,
		GetEFDEnabled = function() return KinesisOptions.global.extendedFlightDetection end,

		SetNeedShiftJumpFlight = genGenericSetFunction("needShift", "flight"),
		SetNeedTripleJumpFlight = genGenericSetFunction("tripleJump", "flight"),

		SetDoubleJumpToLand = function() setJumpToLand(2) end,
		SetTripleJumpToLand = function() setJumpToLand(3) end,
		DisableJumpToLand = function() setJumpToLand(0) end,
		SetJumpToLand = function(val) setJumpToLand(val) end,

		SetLandingDelay = genGenericSetFunction("landDelay", "flight"),
		DisableAutoFlightDisableOnLand = function() setLandingDelay(0) end,

		Spells = {
			SetSpellsEnabled = genGenericSetFunction("sendSpells", "flight"),
			SetSpellArcanumEnabled = genGenericSetFunction("arcanumToggle", "flight"),
			SetSpellArcanumStart = genGenericSetFunction("arcanumStart", "flight"),
			SetSpellArcanumStop = genGenericSetFunction("arcanumStop", "flight"),

			AddStandardSpell = addStandardFlightSpell,
			RemoveStandardSpell = removeFlightSpell,
			ResetCurrentStandardSpells = resetFlightSpells,
			GetCurrentSpellList = ns.Flight.getSpellsInCurrentProfileList,

			StandardSpellsLoadSet = FlightStandardSpellsLoadSet,
			StandardSpellsSaveSet = ns.Flight.saveSpellListToStorage,
			StandardSpellsGetSets = ns.Flight.getSpellListsInStorage,

			StandardSpellsSetSpells = FlightStandardSpellsSetSpells,
		},
	},

	-- Sprint
	Sprint = {

		Enable = function()
			SetShiftSprintEnabled(true)
		end,
		Disable = function()
			SetShiftSprintEnabled(false)
		end,
		Get = function()
			return KinesisOptions.profiles[KinesisCharOptions.activeProfile].sprint.enabled
		end,
		Toggle = function()
			local enabled = KinesisOptions.profiles[KinesisCharOptions.activeProfile].sprint.enabled
			SetShiftSprintEnabled(not enabled)
		end,

		TempDisable = TempDisableSprint(),
		TempDisableReset = TempDisableSprintReset(),

		IsSprinting = function() return ns.Main.sprintFrame.isSprinting end,

		SetShiftSprintEnabled = SetShiftSprintEnabled,
		GetShiftSprintEnabled = function() return KinesisOptions.profiles[KinesisCharOptions.activeProfile].sprint.enabled end,

		SetSprintSpeedGround = genGenericSetFunction("speedWalk", "sprint"),
		SetSprintSpeedFly = genGenericSetFunction("speedFly", "sprint"),
		SetSprintSpeedSwim = genGenericSetFunction("speedSwim", "sprint"),
		SetSprintGroundEnabled = genGenericSetFunction("speedWalkEnabled", "sprint"),
		SetSprintFlyEnabled = genGenericSetFunction("speedFlyEnabled", "sprint"),
		SetSprintSwimEnabled = genGenericSetFunction("speedSwimEnabled", "sprint"),
		SetReturnToOriginalSpeed = genGenericSetFunction("sprintReturnLastSpeed", "sprint"),

		-- Emotes
		Emotes = {
			SetEmoteTriggerWalk = SetEmoteTriggerWalk,
			SetEmoteTriggerFly = SetEmoteTriggerFly,
			SetEmoteTriggerSwim = SetEmoteTriggerSwim,
			SetEmoteText = genGenericSetFunction("emoteMessage", "sprint"),
			SetEmoteRateLimit = genGenericSetFunction("emoteRateLimit", "sprint"),
		},

		-- Sprint Spells
		Spells = {
			SetSpellTriggerWalk = SetSpellTriggerWalk,
			SetSpellTriggerFly = SetSpellTriggerFly,
			SetSpellTriggerSwim = SetSpellTriggerSwim,

			SetSpellArcanumEnabled = genGenericSetFunction("arcanumToggle", "sprint"),
			SetSpellArcanumStart = genGenericSetFunction("arcanumStart", "sprint"),
			SetSpellArcanumStop = genGenericSetFunction("arcanumStop", "sprint"),

			AddStandardSpell = addStandardSprintSpell,
			RemoveStandardSpell = removeSprintSpell,
			ResetCurrentStandardSpells = resetSprintSpells,
			GetCurrentSpellList = ns.Sprint.getSpellsInCurrentProfileList,

			StandardSpellsLoadSet = SprintStandardSpellsLoadSet,
			StandardSpellsSaveSet = ns.Sprint.saveSpellListToStorage,
			StandardSpellsGetSets = ns.Sprint.getSpellListsInStorage,

			StandardSpellsSetSpells = SprintStandardSpellsSetSpells,
		},
	},
}

Kinesis = ns.API
