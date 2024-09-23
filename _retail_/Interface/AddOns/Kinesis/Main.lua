---@class ns
local ns = select(2, ...)
local addonName = ...
local Constants = ns.Constants

local addonVersion, addonAuthor, addonTitle = Constants.addonVersion, Constants.addonAuthor, Constants.addonTitle

local controlFrame = CreateFrame("FRAME")
local Kinesis = LibStub("AceAddon-3.0"):NewAddon(controlFrame, "Kinesis", "AceConsole-3.0")
local AC = LibStub("AceConfig-3.0")
local ACD = LibStub("AceConfigDialog-3.0")
local ACR = LibStub("AceConfigRegistry-3.0")
local AceGUI = LibStub("AceGUI-3.0")

local ver = ns.semver

local playerName = Constants.playerName

KinesisOptions = {}
KinesisOptions.global = {}
KinesisOptions.global["debug"] = false
KinesisOptions.sprintSpellListStorage = {}
KinesisOptions.profiles = {}
KinesisOptions.profiles.default = {}
KinesisOptions.runOnceFixBindings = {}
KinesisCharOptions = {}
KinesisCharOptions.activeProfile = playerName

local flightFrame = CreateFrame("FRAME")
flightFrame.isFlying = false
local sprintFrame = CreateFrame("FRAME")
sprintFrame.isSprinting = false
sprintFrame.isSprintingToggle = false


local cmd
if EpsilonLib and EpsilonLib.AddonCommands then
	cmd = EpsilonLib.AddonCommands.Register("Kinesis")
else
	local SendChatMessage = SendChatMessage
	cmd = function(text)
		SendChatMessage("." .. text, "GUILD");
	end
end

local function isNotDefined(s)
	return s == nil or s == '';
end

local TRIGGER_TYPES = Constants.TRIGGER_TYPES

local addonToggleFuncs = {
	[TRIGGER_TYPES[1]] = { -- Flight Control
		enable = function()
			KinesisOptions.profiles[KinesisCharOptions.activeProfile].flight.enabled = true
			--flightFrame.enabled = true
			--flightFrame.SetLandingOnUpdate(true) -- disabled, toggles itself on when needed
		end,
		disable = function()
			KinesisOptions.profiles[KinesisCharOptions.activeProfile].flight.enabled = false
			--flightFrame.enabled = false
			flightFrame.SetLandingOnUpdate(false)
		end
	},
	[TRIGGER_TYPES[2]] = { -- Sprint Control
		enable = function()
			KinesisOptions.profiles[KinesisCharOptions.activeProfile].sprint.enabled = true
		end,
		disable = function()
			KinesisOptions.profiles[KinesisCharOptions.activeProfile].sprint.enabled = false
		end,
	},
}
addonToggleFuncs[TRIGGER_TYPES[3]] = { -- Both Control
	enable = function()
		addonToggleFuncs[TRIGGER_TYPES[1]].enable()
		addonToggleFuncs[TRIGGER_TYPES[2]].enable()
	end,
	disable = function()
		addonToggleFuncs[TRIGGER_TYPES[1]].disable()
		addonToggleFuncs[TRIGGER_TYPES[2]].disable()
	end,
}

---comment
---@param triggerType TRIGGER_TYPES
local function enableAddon(triggerType)
	if not triggerType then triggerType = TRIGGER_TYPES[3] end -- convert none to both
	addonToggleFuncs[triggerType].enable()
end

local function disableAddon(triggerType)
	if not triggerType then triggerType = TRIGGER_TYPES[3] end -- convert none to both
	addonToggleFuncs[triggerType].disable()
end

local function updateEnabledModules()
	if KinesisOptions.profiles[KinesisCharOptions.activeProfile].flight.enabled then enableAddon(TRIGGER_TYPES[1]) else disableAddon(TRIGGER_TYPES[1]) end
	if KinesisOptions.profiles[KinesisCharOptions.activeProfile].sprint.enabled then enableAddon(TRIGGER_TYPES[2]) else disableAddon(TRIGGER_TYPES[2]) end
end

local function clearShiftSpaceBinds(force)
	local jumpBind1, jumpBind2 = GetBindingKey("JUMP")
	local shiftSpaceBind = GetBindingByKey("SHIFT-SPACE")
	if force then
		local sprintKey = "SHIFT"
		local sprintJumpKeyCombo = ("" .. sprintKey .. "-" .. jumpBind1 .. "")
		local oldBindingConflict = GetBindingByKey(sprintJumpKeyCombo)

		if oldBindingConflict ~= "JUMP" then
			SetBinding(sprintJumpKeyCombo, nil)
			C_Timer.After(0, function() SaveBindings(GetCurrentBindingSet()) end)
			print("Kinesis | Key Bindings for " .. sprintJumpKeyCombo .. " have been removed.")
			print("Previous binding: " .. oldBindingConflict)
		else
			print("Kinesis | No Bindings Found to Conflict with Sprint-Jump.")
		end
	else
		if jumpBind1 == "SPACE" or jumpBind2 == "SPACE" then
			if shiftSpaceBind == "TOGGLEWORLDSTATESCORES" then
				SetBinding("SHIFT-SPACE", nil)
				C_Timer.After(0, function() SaveBindings(GetCurrentBindingSet()) end)
				print(
					"Kinesis | Shift+Space was bound (default). We've deleted this binding to enable sprint-jumping. This will only occur once (per character), and you may re-set your binding if you wish, but it will block jumping while shift is held down.")
			elseif shiftSpaceBind ~= "JUMP" then
				print("Kinesis | Shift+Space is bound to " ..
					shiftSpaceBind ..
					", which is a custom bind you have set. This bind will block the ability to sprint-jump (holding shift to sprint + space to jump). We advise you to remove this binding if you wish to sprint-jump. You can use the 'Fix Sprint+Jump' button in the '/kinesis' menu to fix it automatically.")
			end
		else
			print(
				"Kinesis | Jump is not set to the Space Bar. Please note that any bindings with Shift+Jump Key will interfere with your ability to sprint-jump. We advise you remove such bindings if they are present, or revert to using the Space Bar. You can use the 'Fix Sprint+Jump' button in the '/kinesis' menu to remove any conflicting bindings automatically.")
		end
	end
end

local defaultGlobalSettings = Constants.defaultGlobalSettings
local defaultCharSettings = Constants.defaultCharSettings

---Loads a settings table into a master table, but does not over-write if data is already present
---@param settings table
---@param master table
local function loadDefaultsIntoMaster(settings, master)
	for k, v in pairs(settings) do
		if (type(v) == "table") then
			if (master[k] == nil or type(master[k]) ~= "table") then master[k] = {} end
			loadDefaultsIntoMaster(v, master[k]);
		else
			if master and master[k] == nil then
				master[k] = v;
			end
		end
	end
end

---Change the Active Profile
---@param profile string
local function setActiveProfile(profile, fromUI)
	KinesisCharOptions.activeProfile = profile
	if isNotDefined(KinesisOptions.profiles[KinesisCharOptions.activeProfile]) then KinesisOptions.profiles[KinesisCharOptions.activeProfile] = CopyTable(KinesisOptions.profiles.default) end
	if fromUI then ns.Menu.menuFrame:RefreshMenuForUpdates() end
	updateEnabledModules()
end

---Get the currently active profile
---@return string
local function getActiveProfile()
	return KinesisCharOptions.activeProfile
end

local function createNewProfile(name)
	if KinesisOptions.profiles[name] then return print("ERROR: Kinesis Profile with name " .. name .. " already exists.") end
	KinesisOptions.profiles[name] = {}
	loadDefaultsIntoMaster(KinesisOptions.profiles.default, KinesisOptions.profiles[name])
	setActiveProfile(name, true)
end

local function deleteProfile(name)
	if name == "default" then return end -- cannot delete default, fuck off
	KinesisOptions.profiles[name] = nil
	if name == KinesisCharOptions.activeProfile then
		setActiveProfile("default", true)
	end
end

local function copyProfileSettings(to, from)
	if not KinesisOptions.profiles[from] then return end
	KinesisOptions.profiles[to] = CopyTable(KinesisOptions.profiles[from])
end

local function resetProfile(name)
	KinesisOptions.profiles[name] = CopyTable(defaultGlobalSettings.profiles.default)
end

function Kinesis:OnInitialize()
	loadDefaultsIntoMaster(defaultGlobalSettings, KinesisOptions)
	loadDefaultsIntoMaster(defaultCharSettings, KinesisCharOptions)
	if KinesisCharOptions.activeProfile ~= playerName and not KinesisOptions.profiles[KinesisCharOptions.activeProfile] then
		setActiveProfile("default") -- Active Profile was changed from there character one, and then deleted; set them to default.
	else
		if KinesisCharOptions.activeProfile == playerName and (not KinesisOptions.profiles[KinesisCharOptions.activeProfile]) and KinesisOptions.global.useDefaultForNewChar then
			-- The activeProfile was self, but didn't exist, and the global setting for useDefaultForNewChar is on. So use default profile.
			setActiveProfile("default")
		else
			setActiveProfile(KinesisCharOptions.activeProfile)
		end
	end
	--if isNotDefined(KinesisOptions.profiles[KinesisCharOptions.activeProfile]) then KinesisOptions.profiles[KinesisCharOptions.activeProfile] = CopyTable(KinesisOptions.profiles.default) end
	loadDefaultsIntoMaster(defaultGlobalSettings.profiles.default, KinesisOptions.profiles[KinesisCharOptions.activeProfile])

	updateEnabledModules()

	ns.Sprint.updateSpeeds()
	ns.Menu.menuFrame:AddOptionsMenu()

	ns.Flight.toggleExtendedFlightDetection(KinesisOptions.global.extendedFlightDetection)

	if KinesisOptions.global.lastRunVersion then
		if ver(KinesisOptions.global.lastRunVersion) < ver(addonVersion) then
			-- show changelog here?
		end
	else
		-- first run
		C_Timer.After(0, function() ns.Welcome.showWelcomeScreen() end) -- delayed a frame cuz it doesn't work otherwise wtf
	end
	KinesisOptions.global.lastRunVersion = addonVersion           -- update the lastRunVersion for changelog later
end

-- Binding Controls need to load later after everything is loaded, otherwise they might fail..
local loadFrame = CreateFrame("Frame")
loadFrame.LoadingPoints = 0
loadFrame:HookScript("OnEvent", function(self, event, isLogin, isReload)
	if event == "VARIABLES_LOADED" then
		if KinesisOptions.global.alwaysFixSprintJump or isNotDefined(KinesisOptions.runOnceFixBindings[playerName]) then
			C_Timer.After(0, clearShiftSpaceBinds) -- Delayed because VARIABLES_LOADED is not actually reliably loaded until the next frame
			KinesisOptions.runOnceFixBindings[playerName] = true
		end
	end
end)
loadFrame:RegisterEvent("VARIABLES_LOADED")

ns.Main = {
	AC = AC,
	ACD = ACD,
	ACR = ACR,
	AceGUI = AceGUI,
	cmd = cmd,
	controlFrame = controlFrame,
	isNotDefined = isNotDefined,
	Kinesis = Kinesis,
	flightFrame = flightFrame,
	sprintFrame = sprintFrame,
	enableAddon = enableAddon,
	disableAddon = disableAddon,
	TRIGGER_TYPES = TRIGGER_TYPES,
	getActiveProfile = getActiveProfile,
	setActiveProfile = setActiveProfile,
	createNewProfile = createNewProfile,
	deleteProfile = deleteProfile,
	copyProfileSettings = copyProfileSettings,
	resetProfile = resetProfile,
	updateEnabledModules = updateEnabledModules,
	clearShiftSpaceBinds = clearShiftSpaceBinds,
}
