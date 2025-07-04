---@class ns
local ns = select(2, ...)

local Aura = ns.Utils.Aura
local Cmd = ns.Cmd
local Logging = ns.Logging
local Vault = ns.Vault
local Utils = ns.Utils

local Constants = ns.Constants
local AceConsole = ns.Libs.AceConsole

local cmd, cmdWithDotCheck = Cmd.cmd, Cmd.cmdWithDotCheck
local sendAddonCmd = Cmd.sendAddonCmd
local runMacroText = Cmd.runMacroText
local cprint = Logging.cprint
local eprint = Logging.eprint
local Tooltip = ns.Utils.Tooltip

local commaDelimitedText = "Comma delimited, use \"quotes\" around any text that has a comma."
local commonUnitIDs = "Common UnitIDs: 'player', 'target', 'cursor', 'mouseover', 'partyN' (where N = number 1,2,3,4 for which party member)"

local toBoolean = Utils.Data.toBoolean
local function onToBoolean(val)
	if strtrim(string.lower(val)) == "on" then return true else return false end
end

local parseStringToArgs = ns.Utils.Data.parseStringToArgs
local parseArgsWrapper = function(string, limit)
	local success, argTable, numArgs = pcall(parseStringToArgs, string, limit)
	if not success then
		ns.Logging.eprint("Error Parsing String to Args (Are you missing a \" ?)")
		ns.Logging.dprint(argTable)
		return
	end
	return argTable, numArgs
end

---@param string string CSV Delimited String of Args
---@param limit number Max number of args to grab
---@return ... All the args, capped at the limit or the max number found if no limit given, including nils
local function getArgs(string, limit)
	local argsTable, numArgs = parseArgsWrapper(string, limit)
	if not argsTable then error("Error Parsing String to Args (Are you missing a \" ?)") end
	return unpack(argsTable, 1, numArgs)
end

local maxBackupsPerChar = 3

local Scripts = ns.Actions.Data_Scripts
local RunPrivileged = Scripts.runScriptPriv
local revertHoldingVars = {}

---@enum ActionType
local ACTION_TYPE = {
	MacroText = "MacroText",
	--SecureMacro = "SecureMacro",
	Command = "Command",
	ArcSpell = "ArcSpell",
	ArcSpellPhase = "ArcSpellPhase",
	ArcSpellCastImport = "ArcSpellCastImport",
	ArcSaveFromPhase = "ArcSaveFromPhase",
	ArcCastbar = "ArcCastbar",
	ArcStopSpells = "ArcStopSpells",
	ArcStopThisSpell = "ArcStopThisSpell",
	ArcStopSpellByName = "ArcStopSpellByName",
	ArcTrigCooldown = "ArcTrigCooldown",

	Anim = "Anim",
	AnimKit = "AnimKit",
	Standstate = "Standstate",
	ResetAnim = "ResetAnim",
	ResetStandstate = "ResetStandstate",
	ToggleSheath = "ToggleSheath",

	SpellAura = "SpellAura",
	ToggleAura = "ToggleAura",
	ToggleAuraSelf = "ToggleAuraSelf",
	RemoveAura = "RemoveAura",
	RemoveAllAuras = "RemoveAllAuras",
	PhaseAura = "PhaseAura",
	PhaseUnaura = "PhaseUnaura",
	GroupAura = "GroupAura",
	GroupUnaura = "GroupUnaura",

	SpellCast = "SpellCast",
	SpellTrig = "SpellTrig",

	Equip = "Equip",
	EquipSet = "EquipSet",
	MogitEquip = "MogitEquip",
	Unequip = "Unequip",
	AddItem = "AddItem",
	RemoveItem = "RemoveItem",
	AddRandomItem = "AddRandomItem",

	-- SECURE Actions
	secCast = "secCast",                --Copy of /cast
	secCastID = "secCastID",            --CastSpellByID
	secStopCasting = "secStopCasting",  --StopSpellCasting

	secUseItem = "secUseItem",          --UseItemByName

	secTarget = "secTarget",            --TargetUnit
	secAssist = "secAssist",            --AssistUnit

	secClearTarg = "secClearTarg",      -- ClearTarget
	secTargLEnemy = "secTargLEnemy",    -- TargetLastEnemy
	secTargLFriend = "secTargLFriend",  -- TargetLastFriend
	secTargLTarg = "secTargLTarg",      -- TargetLastTarget
	secTargNAny = "secTargNAny",        -- TargetNearest
	secTargNEnemy = "secTargNEnemy",    -- TargetNearestEnemy
	secTargNEnPlayer = "secTargNEnPlayer", -- TargetNearestEnemyPlayer
	secTargNFriend = "secTargNFriend",  -- TargetNearestFriend
	secTargNFrPlayer = "secTargNFrPlayer", -- TargetNearestFriendPlayer
	secTargNParty = "secTargNParty",    -- TargetNearestPartyMember
	secTargNRaid = "secTargNRaid",      -- TargetNearestRaidMember

	secFocus = "secFocus",              -- FocusUnit
	secClearFocus = "secClearFocus",    -- ClearFocus

	FollowUnit = "FollowUnit",          -- FollowUnit
	StopFollow = "StopFollow",          -- FollowUnit
	ToggleRun = "ToggleRun",            -- ToggleRun
	ToggleAutoRun = "ToggleAutoRun",    -- ToggleAutoRun
	StartAutoRun = "StartAutoRun",      -- StartAutoRun
	StopAutoRun = "StopAutoRun",        -- StopAutoRun

	SendSay = "SendSay",                -- SendChatMessage("SAY")
	SendYell = "SendYell",              -- SendChatMessage("YELL")
	SendEmote = "SendEmote",            -- SendChatMessage("EMOTE")
	SendChannel = "SendChannel",        -- SendChatMessage("CHANNEL")
	SendRaidWarning = "SendRaidWarning", -- SendChatMessage("RAID_WARNING")

	RunMacro = "RunMacro",              -- RunMacro
	RunMacroText = "RunMacroText",      -- RunMacroText
	StopMacro = "StopMacro",            -- StopMacro


	-- Camera Actions
	RotateCameraLeftStart = "RotateCameraLeftStart",
	RotateCameraRightStart = "RotateCameraRightStart",
	RotateCameraUpStart = "RotateCameraUpStart",
	RotateCameraDownStart = "RotateCameraDownStart",
	ZoomCameraOutStart = "ZoomCameraOutStart",
	ZoomCameraInStart = "ZoomCameraInStart",
	ZoomCameraSet = "ZoomCameraSet",
	ZoomCameraOutBy = "ZoomCameraOutBy",
	ZoomCameraInBy = "ZoomCameraInBy",
	ZoomCameraSaveCurrent = "ZoomCameraSaveCurrent",
	ZoomCameraLoadSaved = "ZoomCameraLoadSaved",
	MouselookModeStart = "MouselookModeStart",
	RotateCameraStop = "RotateCameraStop",
	SetViewSmooth = "SetViewSmooth",
	SetViewSnap = "SetViewSnap",

	Scale = "Scale",

	Speed = "Speed",
	SpeedWalk = "SpeedWalk",
	SpeedBackwalk = "SpeedBackwalk",
	SpeedFly = "SpeedFly",
	SpeedSwim = "SpeedSwim",

	TRP3Profile = "TRP3Profile",
	TRP3StatusToggle = "TRP3StatusToggle",
	TRP3StatusIC = "TRP3StatusIC",
	TRP3StatusOOC = "TRP3StatusOOC",

	Morph = "Morph",
	Native = "Native",
	Unmorph = "Unmorph",

	PlayLocalSoundKit = "PlayLocalSoundKit",
	PlayLocalSoundFile = "PlayLocalSoundFile",
	StopLocalSoundKit = "StopLocalSoundKit",
	StopLocalSoundFile = "StopLocalSoundFile",
	PlayPhaseSound = "PlayPhaseSound",

	PlayMusic = "PlayMusic",
	StopMusic = "StopMusic",

	TRP3e_Sound_playLocalSoundID = "TRP3e_Sound_playLocalSoundID", -- Broadcast to play a sound by ID to all nearby people // TRP3_API.utils.music.playLocalSoundID(soundID, channel, distance, source)
	TRP3e_Sound_stopLocalSoundID = "TRP3e_Sound_stopLocalSoundID", -- Broadcast to stop playing a sound to all nearby people // TRP3_API.utils.music.stopLocalSoundID(soundID, channel)
	TRP3e_Sound_playLocalMusic = "TRP3e_Sound_playLocalMusic",  -- Broadcast to play a sound by ID to all nearby people, using the Music Channel // TRP3_API.utils.music.playLocalMusic(soundID, distance, source)
	TRP3e_Sound_stopLocalMusic = "TRP3e_Sound_stopLocalMusic",  -- Broadcast to stop playing a sound to all nearby people, using the Music Channel // TRP3_API.utils.music.stopLocalMusic(soundID)

	--[[
	TRP3e_Sound_stopSoundID = "TRP3e_Sound_stopSoundID",
	TRP3e_Sound_playSoundFileID = "TRP3e_Sound_playSoundFileID",
	TRP3e_Sound_stopMusic = "TRP3e_Sound_stopMusic",
	TRP3e_Sound_playSoundID = "TRP3e_Sound_playSoundID",
	TRP3e_Sound_playMusic = "TRP3e_Sound_playMusic",
	TRP3e_Sound_stopSound = "TRP3e_Sound_stopSound",
	--]]

	TRP3e_Item_QuickImport = "TRP3e_Item_QuickImport",
	TRP3e_Item_AddToInventory = "TRP3e_Item_AddToInventory",
	TRP3e_Cast_showCastingBar = "TRP3e_Cast_showCastingBar", -- Show a TRP3e based Casting Bar - mimics more of the WoW style & can be interrupted. // TRP3_API.extended.showCastingBar(duration, interruptMode, class, soundID, castText)

	CheatOn = "CheatOn",
	CheatOff = "CheatOff",

	ARCSet = "ARCSet",
	ARCTog = "ARCTog",
	ARCCopy = "ARCCopy",

	ARCPhaseSet = "ARCPhaseSet",
	ARCPhaseTog = "ARCPhaseTog",

	ArcImport = "ArcImport",

	-- UI, Prompt & Message Actions
	PrintMsg = "PrintMsg",
	RaidMsg = "RaidMsg",
	ErrorMsg = "ErrorMsg",
	BoxMsg = "BoxMsg",
	BoxPromptCommand = "BoxPromptCommand",
	BoxPromptScript = "BoxPromptScript",
	BoxPromptScriptNoInput = "BoxPromptScriptNoInput",
	BoxPromptCommandNoInput = "BoxPromptCommandNoInput",
	BoxPromptCommandChoice = "BoxPromptCommandChoice",
	BoxPromptScriptChoice = "BoxPromptScriptChoice",
	OpenSendMail = "OpenSendMail",
	SendMail = "SendMail",
	TalkingHead = "TalkingHead",
	ShowBook = "ShowBook",
	HideBook = "HideBook",
	ShowPage = "ShowPage",
	UnitPowerBar = "UnitPowerBar",
	UnitPowerBarValue = "UnitPowerBarValue",

	HideMostUI = "HideMostUI",
	UnhideMostUI = "UnhideMostUI",
	FadeOutMainUI = "FadeOutMainUI",
	FadeInMainUI = "FadeInMainUI",

	HideNames = "HideNames",
	ShowNames = "ShowNames",
	ToggleNames = "ToggleNames",
	RestoreNames = "RestoreNames",

	-- Location Actions
	SaveARCLocation = "SaveARCLocation",
	GotoARCLocation = "GotoARCLocation",
	WorldportCommand = "WorldportCommand",
	TeleCommand = "TeleCommand",
	PhaseTeleCommand = "PhaseTeleCommand",

	-- Spawn Actions
	SpawnBlueprint = "SpawnBlueprint",

	-- QC Actions
	QCBookToggle = "QCBookToggle",
	QCBookStyle = "QCBookStyle",
	QCBookSwitchPage = "QCBookSwitchPage",
	QCBookNewBook = "QCBookNewBook",
	QCBookNewPage = "QCBookNewPage",
	QCBookAddSpell = "QCBookAddSpell",

	-- Kinesis Integration
	Kinesis_TempDisableAll = "Kinesis_TempDisableAll",
	Kinesis_TempDisableFlight = "Kinesis_TempDisableFlight",
	Kinesis_TempDisableSprint = "Kinesis_TempDisableSprint",
	Kinesis_TempDisableAllRst = "Kinesis_TempDisableAllRst",

	Kinesis_FlyEnable = "Kinesis_FlyEnable",
	Kinesis_EFDEnable = "Kinesis_EFDEnable",
	Kinesis_FlyShift = "Kinesis_FlyShift",
	Kinesis_FlyTripleJump = "Kinesis_FlyTripleJump",
	Kinesis_LandJumpSet = "Kinesis_LandJumpSet",
	Kinesis_AutoLandDelay = "Kinesis_AutoLandDelay",

	Kinesis_ToggleFlightSpells = "Kinesis_ToggleFlightSpells",
	Kinesis_FlightArcEnabled = "Kinesis_FlightArcEnabled",
	Kinesis_FlightArcStart = "Kinesis_FlightArcStart",
	Kinesis_FlightArcStop = "Kinesis_FlightArcStop",
	Kinesis_FlightSetSpells = "Kinesis_FlightSetSpells",
	Kinesis_FlightLoadSpellSet = "Kinesis_FlightLoadSpellSet",

	Kinesis_SprintEnabled = "Kinesis_SprintEnabled",
	Kinesis_SprintGround = "Kinesis_SprintGround",
	Kinesis_SprintFly = "Kinesis_SprintFly",
	Kinesis_SprintSwim = "Kinesis_SprintSwim",
	Kinesis_SprintReturnOrig = "Kinesis_SprintReturnOrig",

	Kinesis_SprintEmoteAll = "Kinesis_SprintEmoteAll",
	--Kinesis_SprintEmoteWalk = "Kinesis_SprintEmoteWalk",
	--Kinesis_SprintEmoteFly = "Kinesis_SprintEmoteFly",
	--Kinesis_SprintEmoteSwim = "Kinesis_SprintEmoteSwim",
	Kinesis_SprintEmoteText = "Kinesis_SprintEmoteText",
	Kinesis_SprintEmoteRate = "Kinesis_SprintEmoteRate",

	Kinesis_SprintSpellAll = "Kinesis_SprintSpellAll",
	--Kinesis_SprintSpellWalk = "Kinesis_SprintSpellWalk",
	--Kinesis_SprintSpellFly = "Kinesis_SprintSpellFly",
	--Kinesis_SprintSpellSwim = "Kinesis_SprintSpellSwim",

	Kinesis_SprintArcEnabled = "Kinesis_SprintArcEnabled",
	Kinesis_SprintArcStart = "Kinesis_SprintArcStart",
	Kinesis_SprintArcStop = "Kinesis_SprintArcStop",

	Kinesis_SprintSetSpells = "Kinesis_SprintSetSpells",
	Kinesis_SprintLoadSpellSet = "Kinesis_SprintLoadSpellSet",
}

---@param name string
---@param data ServerActionTypeData
---@return ServerActionTypeData
local function serverAction(name, data)
	data.name = name
	data.comTarget = "server"

	return data
end

---@param name string
---@param data FunctionActionTypeData
---@return FunctionActionTypeData
local function scriptAction(name, data)
	data.name = name
	data.comTarget = "func"

	return data
end

---@type table<ActionType, FunctionActionTypeData | ServerActionTypeData>
local actionTypeData = {
	[ACTION_TYPE.SpellCast] = serverAction("Cast Spell", {
		command = "cast @N@",
		description = "Cast a spell using a Spell ID, to selected target, or self if no target.",
		dataName = "Spell ID(s)",
		inputDescription = "Accepts multiple IDs, separated by commas, to cast multiple spells at once.\n\rUse " .. Tooltip.genContrastText('.look spell') .. " to find IDs.",
		revert = "unaura @N@",
		revertDesc = "unaura",
		revertValidation = function(input)
			if not input then return end
			input = tostring(input)
			if type(input) ~= "string" then return input end
			input = input:gsub(" tr?i?g?g?e?r?e?d?", "")
			return input
		end,
		selfAble = true,
		convertLinks = true,
	}),
	[ACTION_TYPE.SpellTrig] = serverAction("Cast Spell (Trig)", {
		command = "cast @N@ trig",
		description = "Cast a spell using a Spell ID, to selected target, or self if no target, using the triggered flag.",
		dataName = "Spell ID(s)",
		inputDescription = "Accepts multiple IDs, separated by commas, to cast multiple spells at once.\n\rUse " .. Tooltip.genContrastText('.look spell') .. " to find IDs.",
		revert = "unaura @N@",
		revertDesc = "unaura",
		selfAble = true,
		convertLinks = true,
	}),
	[ACTION_TYPE.SpellAura] = serverAction("Apply Aura", {
		command = "aura @N@",
		description = "Applies an Aura from a Spell ID on your target if able, or yourself otherwise.",
		dataName = "Spell ID(s)",
		inputDescription = "Accepts multiple IDs, separated by commas, to apply multiple auras at once.\n\rUse " .. Tooltip.genContrastText('.look spell') .. " to find IDs.",
		revert = "unaura @N@",
		revertDesc = "unaura",
		selfAble = true,
		convertLinks = true,
	}),
	[ACTION_TYPE.PhaseAura] = serverAction("Phase Aura", {
		command = "phase aura @N@",
		description = "Applies an Aura to everyone in the phase.",
		dataName = "Spell ID(s)",
		inputDescription = "Accepts multiple IDs, separated by commas, to apply multiple auras at once.\n\rUse " .. Tooltip.genContrastText('.look spell') .. " to find IDs.",
		revert = "phase unaura @N@",
		revertDesc = "phase unaura",
		convertLinks = true,
	}),
	[ACTION_TYPE.PhaseUnaura] = serverAction("Phase Unaura", {
		command = "phase unaura @N@",
		description = "Removes an Aura from everyone in the phase.",
		dataName = "Spell ID(s)",
		inputDescription = "Accepts multiple IDs, separated by commas, to remove multiple auras at once.\n\rUse " .. Tooltip.genContrastText('.look spell') .. " to find IDs.",
		revert = "phase aura @N@",
		revertDesc = "phase aura",
		convertLinks = true,
	}),
	[ACTION_TYPE.GroupAura] = serverAction("Group Aura", {
		command = "group aura @N@",
		description = "Applies an Aura to everyone in the group.",
		dataName = "Spell ID(s)",
		inputDescription = "Accepts multiple IDs, separated by commas, to apply multiple auras at once.\n\rUse " .. Tooltip.genContrastText('.look spell') .. " to find IDs.",
		revert = "group unaura @N@",
		revertDesc = "group unaura",
		convertLinks = true,
	}),
	[ACTION_TYPE.GroupUnaura] = serverAction("Group Unaura", {
		command = "group unaura @N@",
		description = "Removes an Aura from everyone in the group.",
		dataName = "Spell ID(s)",
		inputDescription = "Accepts multiple IDs, separated by commas, to remove multiple auras at once.\n\rUse " .. Tooltip.genContrastText('.look spell') .. " to find IDs.",
		revert = "group aura @N@",
		revertDesc = "group aura",
		convertLinks = true,
	}),
	[ACTION_TYPE.ToggleAura] = scriptAction("Toggle Aura", {
		command = function(spellID)
			Aura.toggleAura(spellID)
		end,
		description = "Toggles an Aura on / off.\n\rApplies to your target if you have Phase DM on & Officer+",
		dataName = "Spell ID",
		inputDescription = "Accepts multiple IDs, separated by commas, to cast multiple spells at once.\n\rUse " .. Tooltip.genContrastText('.look spell') .. " to find IDs.",
		revert = function(spellID)
			Aura.toggleAura(spellID)
		end,
		revertDesc = "Toggles the Aura again",
		convertLinks = true,
	}),
	[ACTION_TYPE.ToggleAuraSelf] = scriptAction("Toggle Aura (Self)", {
		command = function(spellID)
			Aura.toggleAura(spellID, false)
		end,
		description = "Toggles an Aura on / off.\n\rAlways applies on yourself.",
		dataName = "Spell ID",
		inputDescription = "Accepts multiple IDs, separated by commas, to cast multiple spells at once.\n\rUse" .. Tooltip.genContrastText('.look spell') .. " to find IDs.",
		revert = function(spellID)
			Aura.toggleAura(spellID, false)
		end,
		revertDesc = "Toggles the Aura again",
		convertLinks = true,
	}),
	[ACTION_TYPE.Anim] = serverAction("Emote/Anim", {
		command = "mod anim @N@",
		description = "Modifies target's current animation using 'mod anim'.\n\rUse " .. Tooltip.genContrastText('.look emote') .. " to find IDs.",
		dataName = "Emote ID",
		inputDescription = "Accepts multiple IDs, separated by commas, to do multiple anims at once -- but the second usually over-rides the first anyways.\n\rUse " ..
			Tooltip.genContrastText('.look emote') .. " to find IDs.",
		revert = "mod stand 30",
		revertDesc = "Reset to Standstate 30 (none)",
		convertLinks = true,
	}),
	[ACTION_TYPE.AnimKit] = serverAction("Anim Kit", {
		command = "mod animkit @N@",
		description = "Modifies target's current animation kit using 'mod animkit'.",
		dataName = "AnimKit ID",
		inputDescription = "Accepts multiple IDs, separated by commas, to do multiple animkits at once, stacking them.",
		revertAlternative = "Cannot revert AnimKits, however they are one-shot and end.. sooner or later, depending on how long that animkit is.",
		selfAble = true,
		convertLinks = true,
	}),
	[ACTION_TYPE.ResetAnim] = serverAction("Reset Emote/Anim", {
		command = "mod stand 30",
		description = "Reset target's current animation to Standstate 30 (none).",
		dataName = nil,
		revert = nil,
		revertAlternative = "another emote action",
	}),
	[ACTION_TYPE.ResetStandstate] = serverAction("Reset Standstate", {
		command = "mod stand 0",
		description = "Reset the Standstate of your character to 0 (none).",
		dataName = nil,
		revert = nil,
		revertAlternative = "another emote action",
	}),
	[ACTION_TYPE.Morph] = serverAction("Morph", {
		command = "morph @N@",
		description = "Morph into a Display ID.",
		dataName = "Display ID/Link",
		inputDescription = "No, you can't put multiple to become a hybrid monster..\n\rUse " .. Tooltip.genContrastText('.look displayid') .. " to find IDs.",
		revert = "demorph",
		revertDesc = "demorph",
		convertLinks = true,
	}),
	[ACTION_TYPE.Native] = serverAction("Native", {
		command = "mod native @N@",
		description = "Modifies your Native to specified Display ID.",
		dataName = "Display ID/Link",
		inputDescription = "Use " .. Tooltip.genContrastText('.look displayid') .. " to find IDs.",
		revert = "demorph",
		revertDesc = "demorph",
		convertLinks = true,
	}),
	[ACTION_TYPE.Standstate] = serverAction("Standstate", {
		command = "mod standstate @N@",
		description = "Change the emote of your character while standing to an Emote ID.",
		dataName = "Standstate ID/Link",
		inputDescription = "Accepts multiple IDs, separated by commas, to set multiple standstates at once.. but you can't have two, so probably don't try it.\n\rUse " ..
			Tooltip.genContrastText('.look emote') .. " to find IDs.",
		revert = "mod stand 0",
		revertDesc = "Set Standstate to 0 (none)",
		convertLinks = true,
	}),
	[ACTION_TYPE.ToggleSheath] = scriptAction("Sheath/Unsheath Weapon", {
		command = function() ToggleSheath() end,
		description = "Sheath or unsheath your weapon.",
	}),
	[ACTION_TYPE.Equip] = scriptAction("Equip Item", {
		command = function(vars) EquipItemByName(vars) end,
		description = "Equip an Item by name or ID. Item must be in your inventory.\n\rName is a search in your inventory by keyword - using ID is recommended.",
		dataName = "Item ID or Name(s)",
		inputDescription = "Accepts multiple IDs/Names/Links, separated by commas, to equip multiple items at once.\n\rUse " ..
			Tooltip.genContrastText('.look item') .. ", or mouse-over an item in your inventory for IDs.",
		example =
		"You want to equip 'Violet Guardian's Helm', ID: 141357, but have 'Guardian's Leather Belt', ID: 35156 in your inventory also, using 'Guardian' as the text will equip the belt, so you'll want to use the full name, or better off just use the actual item ID.",
		revert = nil,
		revertAlternative = "a separate unequip item action",
	}),
	--[ACTION_TYPE.AddItem] = serverAction("Add Item", {
	[ACTION_TYPE.AddItem] = scriptAction("Add Item", {
		--command = "additem @N@",
		command = Scripts.items.addRemoveItemWithNegativeCheck,
		description = "Add an item to your inventory.\n\rYou may specify multiple items separated by commas, and may specify item count & bonusID per item as well.",
		dataName = "Item ID/Links(s)",
		inputDescription = "Accepts multiple IDs/Links, separated by commas, to add multiple items at once.\n\rUse " ..
			Tooltip.genContrastText('.look item') .. ", or mouse-over an item in your inventory for IDs.",
		example = Tooltip.genContrastText("125775 1 449, 125192 1 449") .. " will add 1 of each item with Heroic (449) tier",
		revert = nil,
		revertAlternative = "a separate remove item action",
	}),
	[ACTION_TYPE.RemoveItem] = serverAction("Remove Item", {
		command = "additem @N@ -1",
		description =
		"Remove an item from your inventory.\n\rYou may specify multiple items separated by commas, and may optionally specify item count as a negative number to remove that many of the item.",
		dataName = "Item ID/Links(s)",
		inputDescription = "Accepts multiple IDs/Links, separated by commas, to remove multiple items at once.\n\rUse " ..
			Tooltip.genContrastText('.look item') .. ", or mouse-over an item in your inventory for IDs.",
		example = Tooltip.genContrastText("125775 -10") .. " to remove 10 of that item.",
		revert = nil,
		revertAlternative = "a separate add item action",
	}),
	[ACTION_TYPE.AddRandomItem] = scriptAction("Add Random Item", {
		command = function(vars)
			-- Item Format Method (comma delimit): itemID amount bonusIDs+weight
			local itemsTable = { strsplit(",", vars) }
			local finalItems = {}
			for i = 1, #itemsTable do
				local v = itemsTable[i]
				local item, weight = strsplit("+", v)
				if not weight or weight == "" then weight = 1 end
				table.insert(finalItems, { tonumber(strtrim(weight)), strtrim(item) })
			end
			local randomItem = ns.Utils.Data.getRandomWeightedArg(finalItems)
			--cmd("additem " .. randomItem)
			Scripts.items.addRemoveItemWithNegativeCheck(randomItem)
		end,
		description = "Add a random item to your inventory from the given list.\n\rItems may be weighted to modify their chance at being chosen.",
		dataName = "Item Pool",
		inputDescription = "Items should be separated by commas, and formatted as:" ..
			Tooltip.genContrastText("#FirstItemID [#Amount [#BonusIDs]], #SecondItemID [#Amount [#BonusIDs]], ..etc..") ..
			".\n\rAmount & BonusIDs are optional, but amount must be given if bonusIDs is given also." ..
			"\n\rBy default, each item has an equal chance (aka weight) of being chosen. To change this, you may specify a weight by adding a number with a + in front after each items data, like so:" ..
			Tooltip.genContrastText("#ItemID #Amount #BonusIDs +#weight") .. ". Note, weights may only be whole numbers (integers)." ..
			"\n\rWeight is optional and defaults to 1 if not given." ..
			"\n\rWeights are normalized, so if they're all the same value they have equal chance of being used. For example: " ..
			Tooltip.genContrastText("1234+1, 4567+2, 7891+1") .. ". There is a total of 4 chances, with 1234 having 1/4 (25%) chance, 4567 having 2/4 (50%) chance, and 7891 having 1/4 (25%) chance).",
		example = Tooltip.genContrastText("125775 1 449+99, 125192 2+1") .. " will randomly choose between a 99% chance to add 1 copy of 125775 (Heroic), or 1% chance for 2 copies of 125192 (Normal)",
		revert = nil,
		revertAlternative = "a separate remove item action",
		doNotDelimit = true,
	}),
	[ACTION_TYPE.RemoveAura] = serverAction("Remove Aura", {
		command = "unaura @N@",
		description = "Remove an Aura by Spell ID.",
		dataName = "Spell ID(s)",
		inputDescription = "Accepts multiple IDs, separated by commas, to remove multiple auras at once.",
		revert = "aura @N@",
		revertDesc = "Reapplies the same aura",
		selfAble = true,
		convertLinks = true,
	}),
	[ACTION_TYPE.RemoveAllAuras] = serverAction("Remove All Auras", {
		command = "unaura all",
		description = "Remove all Auras.",
		dataName = nil,
		revert = nil,
		revertAlternative = "another aura/cast action",
		selfAble = true,
	}),
	[ACTION_TYPE.Unmorph] = serverAction("Remove Morph", {
		command = "demorph",
		description = "Remove all morphs, including natives.",
		dataName = nil,
		revert = nil,
		revertAlternative = "another morph/native action",
	}),
	[ACTION_TYPE.Unequip] = scriptAction("Unequip Item", {
		command = function(slotID)
			PickupInventoryItem(slotID); PutItemInBackpack();
		end,
		description =
		"Unequips an item by item slot.\n\rCommon IDs:\rHead: 1          Shoulders: 3\rShirt: 4          Chest: 5\rWaist: 6         Legs: 7\rFeet: 8           Wrist: 9\rHands: 10       Back: 15\rTabard: 19\rMain-hand: 16\rOff-hand: 17",
		dataName = "Item Slot ID(s)",
		inputDescription =
		"Common IDs:\rHead: 1          Shoulders: 3\rShirt: 4           Chest: 5\rWaist: 6         Legs: 6\rFeet: 8            Wrist: 9\rHands: 10       Back: 15\rTabard: 19\rMain-hand: 16\rOff-hand: 17\n\rAccepts multiple slot ID's, separated by commas, to remove multiple slots at the same time.",
		revert = nil,
		revertAlternative = "a separate Equip Item action",
	}),
	[ACTION_TYPE.TRP3Profile] = scriptAction("TRP3 Profile", {
		command = function(profile) SlashCmdList.TOTALRP3("profile " .. profile) end,
		description = "Change the active Total RP profile to the profile with the specified name.",
		dataName = "Profile name",
		inputDescription = "The name of the profile as it appears in Total RP's profile list.",
		revert = nil,
		dependency = "totalRP3",
	}),
	[ACTION_TYPE.TRP3StatusToggle] = scriptAction("TRP3: IC/OOC", {
		command = function() SlashCmdList.TOTALRP3("status toggle") end,
		description = "Switch your Total RP 3 status to the opposite state.",
		dataName = nil,
		revert = nil,
		dependency = "totalRP3",
	}),
	[ACTION_TYPE.TRP3StatusIC] = scriptAction("TRP3: IC", {
		command = function() SlashCmdList.TOTALRP3("status ic") end,
		description = "Set your Total RP 3 status to IC.",
		dataName = nil,
		revert = nil,
		dependency = "totalRP3",
	}),
	[ACTION_TYPE.TRP3StatusOOC] = scriptAction("TRP3: OOC", {
		command = function() SlashCmdList.TOTALRP3("status ooc") end,
		description = "Set your Total RP 3 status to OOC.",
		dataName = nil,
		revert = nil,
		dependency = "totalRP3",
	}),
	[ACTION_TYPE.Scale] = serverAction("Scale", {
		command = "mod scale @N@",
		description = "Modifies your targets size using 'mod scale'.\n\rApplies to self if no target is selected and/or not in DM mode.",
		dataName = "Scale",
		inputDescription = "Value may range from 0.1 to 10.",
		revert = "mod scale 1",
		revertDesc = "Reset to scale 1",
	}),
	[ACTION_TYPE.Speed] = serverAction("Speed", {
		command = "mod speed @N@",
		description = "Modifies movement speed using 'mod speed'.",
		dataName = "Speed",
		inputDescription = "Value may range from 0.1 to 50.",
		revert = "mod speed 1",
		revertDesc = "Reset to speed 1",
	}),
	[ACTION_TYPE.SpeedBackwalk] = serverAction("Walk Speed (Back)", {
		command = "mod speed backwalk @N@",
		description = "Modifies speed of walking backwards.",
		dataName = "Speed",
		inputDescription = "Value may range from 0.1 to 50.",
		revert = "mod speed backwalk 1",
		revertDesc = "Reset to backwalk speed 1",
	}),
	[ACTION_TYPE.SpeedFly] = serverAction("Fly Speed", {
		command = "mod speed fly @N@",
		description = "Modifies flying speed.",
		dataName = "Speed",
		inputDescription = "Value may range from 0.1 to 50.",
		revert = "mod speed fly 1",
		revertDesc = "Reset to fly speed 1",
	}),
	[ACTION_TYPE.SpeedWalk] = serverAction("Walk Speed", {
		command = "mod speed walk @N@",
		description = "Modifies walking speed.",
		dataName = "Speed",
		inputDescription = "Value may range from 0.1 to 50.",
		revert = "mod speed walk 1",
		revertDesc = "Reset to walk speed 1",
	}),
	[ACTION_TYPE.SpeedSwim] = serverAction("Swim Speed", {
		command = "mod speed swim @N@",
		description = "Modifies swimming speed.",
		dataName = "Speed",
		inputDescription = "Value may range from 0.1 to 50.",
		revert = "mod speed swim 1",
		revertDesc = "Reset to swim speed 1",
	}),
	-- [ACTION_TYPE.DefaultEmote] = scriptAction("Default Emote", {
	-- 	["command"] = function(emoteID) DoEmote(string.upper(emoteID)); end,
	-- 	["description"] = "Any default emote.\n\rMust be a valid emote 'token', i.e., 'WAVE'\n\rGoogle 'Wowpedia DoEmote' for a full list - most match their /command, but some don't.",
	-- 	["dataName"] = "Emote Token",
	-- 	["inputDescription"] = "Usually just the text from the /command, i.e., /wave = wave.\n\rIf not working: Search Google for 'Wowpedia DoEmote', and go to the Wowpedia page, and find the table of tokens - some don't exactly match their command.",
	-- 	["revert"] = nil,
	-- }),

	[ACTION_TYPE.CheatOn] = serverAction("Enable Cheat", {
		command = "cheat @N@ on",
		description = "Enables the specified cheat.\n\rUse " .. Tooltip.genContrastText('.cheat') .. " to view available cheats.",
		dataName = "Cheat",
		inputDescription = "The cheat command to enable.\n\rCommon Cheats:\r" ..
			Tooltip.genContrastText({ "casttime", "cooldown", "god", "waterwalk", "duration", "slowcast" }) .. "\n\rUse " .. Tooltip.genContrastText(".cheat") .. " to view all available cheats.",
		example = "\r" .. Tooltip.genContrastText("cast") .. " will enable instant cast cheat\r" .. Tooltip.genContrastText("cool") .. " will enable no cooldowns cheat",
		revert = "cheat @N@ off",
		revertDesc = "Disable the cheat",
	}),
	[ACTION_TYPE.CheatOff] = serverAction("Disable Cheat", {
		command = "cheat @N@ off",
		description = "Disables the specified cheat.\n\rUse " .. Tooltip.genContrastText('.cheat') .. " to view available cheats.",
		dataName = "Cheat",
		inputDescription = "The cheat command to disable.\n\rUse " .. Tooltip.genContrastText('.cheat') .. " to view available cheats.",
		example = "\r" .. Tooltip.genContrastText("cast") .. " will disable instant cast cheat\r" .. Tooltip.genContrastText("cool") .. " will disable no cooldowns cheat",
		revert = "cheat @N@ on",
		revertDesc = "Enable the cheat",
	}),

	-- -- -- -- -- -- -- -- --
	--#region Sound
	-- -- -- -- -- -- -- -- --

	[ACTION_TYPE.PlayLocalSoundKit] = scriptAction("Play Sound (Self - Kit)", {
		command = function(vars)
			local soundID = tonumber(vars)
			if not soundID then soundID = (SOUNDKIT[vars] or SOUNDKIT[string.upper(vars)]) end
			if not soundID then
				Logging.eprint(("No Sound Found for '%s'."):format(ns.Utils.Tooltip.genContrastText("vars")))
				return
			end

			Scripts.sounds.playSoundID(soundID)
		end,
		description = "Play a sound locally (to yourself only), by SoundKit/Sound ID or SoundKit Constant.",
		dataName = "SoundKit ID / Name",
		inputDescription = "Accepts multiple IDs/Names, separated by commas, to play multiple sounds at once.",
		example = "Use " ..
			Tooltip.genContrastText("IG_BACKPACK_OPEN") ..
			" or SoundKit ID " ..
			Tooltip.genContrastText("862") .. " to play the Backpack Opened sound.\n\rUse " .. Tooltip.genContrastText('wowhead.com/sounds') .. " or similar to search for SoundKit/Sound IDs.",
		revertDesc = "Stops any/all instances of this sound kit ID that was played via Arcanum.",
		revert = function(vars)
			local soundID = tonumber(vars)
			if not soundID then soundID = (SOUNDKIT[vars] or SOUNDKIT[string.upper(vars)]) end
			if not soundID then
				Logging.eprint(("No Sound Found for '%s'."):format(ns.Utils.Tooltip.genContrastText("vars")))
				return
			end

			Scripts.sounds.stopSoundID(soundID, 0.5)
		end,
	}),
	[ACTION_TYPE.PlayLocalSoundFile] = scriptAction("Play Sound (Self - File)", {
		command = function(vars)
			--PlaySoundFile(vars)
			if not vars or vars == "" then return end
			Scripts.sounds.playSoundFile(vars)
		end,
		description = "Play a sound locally (to yourself only), by File ID.",
		dataName = "File ID",
		inputDescription = "Accepts multiple IDs, separated by commas, to play multiple sounds at once.",
		example = "Use File ID " .. Tooltip.genContrastText("569593") .. " to play the Level-Up sound.\n\rUse " .. Tooltip.genContrastText('WoW.tools') .. " or similar to look for sound File IDs.",
		revertDesc = "Stops any/all instances of this sound file ID that was played via Arcanum.",
		revert = function(vars)
			if not vars or vars == "" then return end
			Scripts.sounds.stopSoundFile(vars, 0.5)
		end,
	}),
	[ACTION_TYPE.StopLocalSoundKit] = scriptAction("Stop Sound (Self - Kit)", {
		command = function(vars)
			local soundID = tonumber(vars)
			if not soundID then soundID = (SOUNDKIT[vars] or SOUNDKIT[string.upper(vars)]) end
			if not soundID then
				Logging.eprint(("No Sound Found for '%s'."):format(ns.Utils.Tooltip.genContrastText("vars")))
				return
			end

			Scripts.sounds.stopSoundID(soundID, 0.5)
		end,
		description = "Stops any/all instances of this sound kit ID that was played via Arcanum.",
		dataName = "SoundKit ID / Name",
		inputDescription = "Accepts multiple IDs/names, separated by commas, to stop multiple sounds at once.",
		example = "Use " ..
			Tooltip.genContrastText("IG_BACKPACK_OPEN") ..
			" or SoundKit ID " ..
			Tooltip.genContrastText("862") .. " to STOP the Backpack Opened sound.\n\rUse " .. Tooltip.genContrastText('wowhead.com/sounds') .. " or similar to search for SoundKit/Sound IDs.",
		revertDesc = "Play the sound locally (to yourself only), by Sound Kit ID/Name.",
		revert = function(vars)
			local soundID = tonumber(vars)
			if not soundID then soundID = (SOUNDKIT[vars] or SOUNDKIT[string.upper(vars)]) end
			if not soundID then
				Logging.eprint(("No Sound Found for '%s'."):format(ns.Utils.Tooltip.genContrastText("vars")))
				return
			end

			Scripts.sounds.playSoundID(soundID)
		end,
	}),
	[ACTION_TYPE.StopLocalSoundFile] = scriptAction("Stop Sound (Self - File)", {
		command = function(vars)
			--PlaySoundFile(vars)
			if not vars or vars == "" then return end
			Scripts.sounds.stopSoundFile(vars, 0.5)
		end,
		description = "Stops any/all instances of this sound file ID that was played via Arcanum.",
		dataName = "File ID",
		inputDescription = "Accepts multiple file IDs, separated by commas, to stop multiple sounds at once.",
		example = "Use File ID " .. Tooltip.genContrastText("569593") .. " to STOP the Level-Up sound.\n\rUse " .. Tooltip.genContrastText('WoW.tools') .. " or similar to look for sound File IDs.",
		revertDesc = "Play the sound locally (to yourself only), by File ID.",
		revert = function(vars)
			if not vars or vars == "" then return end
			Scripts.sounds.playSoundFile(vars)
		end,
	}),


	[ACTION_TYPE.PlayPhaseSound] = serverAction("Phase Sound", {
		command = "phase playsound @N@",
		description = "Play a sound to the whole phase. Requires Phase Officer permissions.",
		dataName = "Sound ID",
		inputDescription = "The sound ID to play to the phase.",
		example = "Use Sound ID " ..
			Tooltip.genContrastText("11466") ..
			" to play Illidan's 'You are Not Prepared!' voice line to the entire phase.\n\rUse " .. Tooltip.genContrastText('wowhead.com/sounds') .. " to find Sound IDs to use.",
		revert = nil,
	}),

	[ACTION_TYPE.PlayMusic] = scriptAction("Play Music (Self)", {
		command = Scripts.sounds.playMusic,
		description =
			"Play music locally (to yourself only), by File ID only. Music plays on loop until cancelled with a Stop Music action, or a revert.\n\rUse " ..
			Tooltip.genContrastText("https://old.wow.tools/files/#search=sound/music") .. " to find music IDs.",
		dataName = "Sound File ID",
		inputDescription = "The File ID of a sound.",
		example = Tooltip.genContrastText("53184") .. " to play Darnassus music. RIP Darnassus.",
		revert = Scripts.sounds.stopMusic,
		revertDesc =
		"Stops this specific music, if it's still playing. If another Play Music (Self) action was used after this action but before the revert, this will fail. Use another Stop Music (Self) action instead if needed.",
	}),
	[ACTION_TYPE.StopMusic] = scriptAction("Stop Music (Self)", {
		command = Scripts.sounds.stopMusic,
		description = "Stops the currently playing music, or, if an ID is given, only stops it if that was the last played music by a Play Music (Self) action.",
		dataName = "Blank / Sound File ID",
		inputDescription = "The File ID of a sound, or leave blank to stop any / all music.",
		example = "Leave blank to stop ANY currently playing music, OR, i.e., use " ..
			Tooltip.genContrastText("53184") .. " to only stop the music if the last played music is the Darnassus music (53184).",
		revert = Scripts.sounds.playMusic,
		revertDesc = "If given a File ID, a revert will then start playing that music again. Does not work if input is blank however, as it cannot remember what that last music ID was.",
	}),

	--TRP3e Nearby (Local..) Sound Actions
	[ACTION_TYPE.TRP3e_Sound_playLocalSoundID] = scriptAction("Play Sound Nearby", {
		command = Scripts.TRP3e_sound.playLocalSoundID,
		description =
		"Play a sound to all players within the radius given, by SoundKit ID, via the TRP3e Sound System. Requires them to have TRP3 Extended as well to hear it.\n\rAbuse of this action to spam sounds can and will be met with administrative action.",
		dataName = "soundID, channel, distance",
		inputDescription = "The Sound Kit ID, the channel to use, and the distance / radius from yourself for who can hear the sound." ..
			("\n\rAvailable Channels: %s, %s, %s, %s"):format(Tooltip.genContrastText("Master"), Tooltip.genContrastText("SFX"), Tooltip.genContrastText("Ambience"), Tooltip.genContrastText("Dialog")),
		example = Tooltip.genContrastText("124, SFX, 10") ..
			" to play the Level-Up sound to everyone within 10 units, using the SFX Channel.\n\rUse " ..
			Tooltip.genContrastText('wow.tools/dbc/?dbc=soundkitentry') .. " or similar to look for sound kit IDs.",
		revert = Scripts.TRP3e_sound.stopLocalSoundID,
		revertDesc = "Stops the sound to all nearby players, by the same ID.",
		doNotDelimit = true,
		dependency = "totalRP3_Extended"
	}),
	[ACTION_TYPE.TRP3e_Sound_playLocalMusic] = scriptAction("Play Music Nearby", {
		command = Scripts.TRP3e_sound.playLocalMusic,
		description =
		"Play a sound to all players within the radius given, by SoundKit ID, via the Music channel & TRP3e Sound System. Requires them to have TRP3 Extended as well to hear it.\n\rAbuse of this action to spam music can and will be met with administrative action.",
		dataName = "soundID, distance",
		inputDescription = "The Sound Kit ID, and the distance / radius from yourself for who can hear the sound.",
		example = Tooltip.genContrastText("7319, 25") ..
			" to play Ironforge ambience music to everyone within 25 units.\n\rUse " ..
			Tooltip.genContrastText('wow.tools/dbc/?dbc=soundkitentry') .. " or similar to look for sound kit IDs.",
		revert = Scripts.TRP3e_sound.stopLocalMusic,
		revertDesc = "Stops the sound to all nearby players, by the same ID.",
		doNotDelimit = true,
		dependency = "totalRP3_Extended"
	}),

	[ACTION_TYPE.TRP3e_Sound_stopLocalSoundID] = scriptAction("Stop Sound Nearby", {
		command = Scripts.TRP3e_sound.stopLocalSoundID,
		description =
		"Stops a sound for all nearby players, by ID & channel, in the TRP3e Sound System.",
		dataName = "soundID, channel",
		inputDescription = "The Sound Kit ID, and the channel it's in to stop" ..
			("\n\rAvailable Channels: %s, %s, %s, %s"):format(Tooltip.genContrastText("Master"), Tooltip.genContrastText("SFX"), Tooltip.genContrastText("Ambience"), Tooltip.genContrastText("Dialog")),
		example = Tooltip.genContrastText("124, SFX") ..
			" to stop the Level-Up sound, using the SFX Channel, for everyone that heard the sound originally from you.",
		revertAlternative = "another TRP3-Play Sound Nearby action",
		dependency = "totalRP3_Extended"
	}),
	[ACTION_TYPE.TRP3e_Sound_stopLocalMusic] = scriptAction("Stop Music Nearby", {
		command = Scripts.TRP3e_sound.stopLocalMusic,
		description =
		"Stops a playing music for all nearby players, by ID & channel, in the TRP3e Sound System.",
		dataName = "soundID",
		inputDescription = "The Sound Kit ID",
		example = Tooltip.genContrastText("7319") ..
			" to stop the Ironforge ambience music, for everyone that heard the music originally from you.",
		revertAlternative = "another TRP3-Play Music Nearby action",
		dependency = "totalRP3_Extended"
	}),

	-- -- -- -- -- -- -- -- --
	--#endregion Sound
	-- -- -- -- -- -- -- -- --

	[ACTION_TYPE.MacroText] = scriptAction("Macro Script", {
		command = function(command) runMacroText(command); end,
		description =
		"Any line that can be processed in a macro (any slash commands & macro flags), or any valid Lua script.\n\rYou can use this for pretty much ANYTHING, technically, including custom short Lua scripts.\rDoes not accept comma separated multi-actions.",
		dataName = "/command or script",
		inputDescription =
		"Any /commands that can be processed in a macro-script, including emotes, addon commands, etc., or Lua scripts.\n\rYou can use any part of the ARC:API here as well. Use /arc for more info.",
		example = Tooltip.genContrastText("/emote begins to conjure up a fireball in their hand.") ..
			" to perform the emote.\n\r" .. Tooltip.genTooltipText("example", Tooltip.genContrastText("print(\"Example\")") .. " to print 'Example' in chat to yourself."),
		revert = nil,
		doNotDelimit = true,
		doNotSanitizeNewLines = true,
	}),
	[ACTION_TYPE.Command] = scriptAction("Server .Command", {
		command = cmdWithDotCheck,
		description = "Any other server command.\n\rType the full command you want in the input box.",
		dataName = "Full Command",
		inputDescription = "You can use any server command here, with or without the '.', and it will run after the delay.\n\rDoes NOT accept comma separated multi-actions.",
		example = "mod drunk 100",
		revert = nil,
		doNotDelimit = true,
		convertLinks = true,
	}),
	[ACTION_TYPE.MogitEquip] = scriptAction("Equip Mogit Set", {
		command = function(vars) SlashCmdList["MOGITE"](vars); end,
		description = "Equip a saved Mogit Wishlist set.\n\rMust specify the character name (profile) it's saved under first, then the set name.",
		dataName = "Profile & Set",
		inputDescription = "The Mogit Profile, and set name, just as if using the /moge chat command.",
		example = Tooltip.genContrastText(Constants.CHARACTER_NAME .. " Cool Armor Set") .. " to equip Cool Armor Set from this character.",
		revert = nil,
		dependency = "MogIt",
	}),
	[ACTION_TYPE.EquipSet] = scriptAction("Equip Set", {
		command = function(vars) C_EquipmentSet.UseEquipmentSet(C_EquipmentSet.GetEquipmentSetID(vars)) end,
		description = "Equip a saved set from Blizzard's Equipment Manager, by name.",
		dataName = "Set Name",
		inputDescription = "Set name from Equipment Manager (Blizzard's built in set manager).",
		revert = nil,
		revertAlternative = "a series of unequip actions",
	}),
	[ACTION_TYPE.ArcSpell] = scriptAction("Cast ArcSpell (Personal)", {
		command = function(commID)
			local spell = Vault.personal.findSpellByID(commID)
			if not spell then
				cprint("No spell with ArcID '" .. commID .. "' found in your Personal Vault.")
				return
			end
			ns.Actions.Execute.executeSpell(spell.actions, nil, spell.fullName, spell)
		end,
		description = "Cast another Arcanum Spell from your Personal Vault.",
		dataName = "ArcSpell ID",
		inputDescription = "The ArcSpell ID (ArcID) used to cast the ArcSpell",
		example = "From " .. Tooltip.genContrastText('/sf MySpell') .. ", input just " .. Tooltip.genContrastText("MySpell") .. " as this input.",
		revert = nil,
	}),
	[ACTION_TYPE.ArcSpellCastImport] = scriptAction("Cast ArcSpell (Import)", {
		command = function(importString)
			local spell = ns.UI.ImportExport.getDataFromImportString(importString)
			if not spell then
				cprint("Import Error: Invalid ArcSpell data. Try again.")
				return
			end
			ns.Actions.Execute.executeSpell(spell.actions, nil, spell.fullName, spell)
		end,
		description = "Cast another exported Arcanum Spell.",
		dataName = "Import Code",
		inputDescription =
		"The export/import code from exporting an ArcSpell in your vault.\n\rNote: ArcSpells exported are a snap-shot of that spell at that exact moment. Any edits you make to that spell later, will not be reflected in this export, and thus casting via import will not be updated either. You'd need to re-export the spell and update the input.",
		example = "Right-Click an ArcSpell in your vault, then click 'Export'. Copy that code and paste it here.",
		revert = nil,
	}),
	[ACTION_TYPE.ArcSpellPhase] = scriptAction("Cast ArcSpell (Phase)", {
		command = function(commID)
			local spell = Vault.phase.findSpellByID(commID)
			if not spell then
				cprint("No spell with ArcID '" .. commID .. "' found in your current phase's Phase Vault.")
				return
			end
			ns.Actions.Execute.executeSpell(spell.actions, nil, spell.fullName, spell)
		end,
		description = "Cast another Arcanum Spell from your Personal Vault.",
		dataName = "ArcSpell ID",
		inputDescription = "The ArcSpell ID (ArcID) used to cast the ArcSpell",
		example = "From " .. Tooltip.genContrastText('/sf MySpell') .. ", input just " .. Tooltip.genContrastText("MySpell") .. " as this input.",
		revert = nil,
	}),
	[ACTION_TYPE.ArcSaveFromPhase] = scriptAction("Save ArcSpell (Phase)", {
		command = function(data)
			--local commID, vocal = strsplit(",", data, 2)
			--local args, numArgs = parseArgsWrapper(data)
			--if not args then return end
			local success, commID, vocal = pcall(getArgs, data)
			if not success then return end

			if vocal and (vocal == "false" or vocal == "nil" or vocal == "0") then vocal = nil end
			if vocal and vocal == "true" then vocal = true end
			ARC.PHASE:SAVE(commID, vocal)
		end,
		description = "Save an Arcanum Spell from the Phase Vault, with an optional message to let them know they learned a new ArcSpell!",
		dataName = "ArcSpell ID, [send message (true/false)]",
		inputDescription = "Syntax: The ArcSpell ID (ArcID) used to cast the ArcSpell, [print a 'New Spell Learned' message (true/false)]",
		example = "My Cool Spell, true",
		revert = nil,
		doNotDelimit = true,
	}),
	[ACTION_TYPE.ArcImport] = scriptAction("Import ArcSpell", {
		command = function(data)
			local importString, vocal = strsplit(",", data, 2)
			if vocal then vocal = strtrim(vocal) end
			if vocal and (vocal == "false" or vocal == "nil" or vocal == "0") then vocal = nil end
			if vocal and vocal == "true" then vocal = true end
			ns.UI.ImportExport.importSpell(importString, vocal)
		end,
		description = "Import an ArcSpell from an export, directly to your Personal Vault, with an optional message to let them know they learned a new ArcSpell!",
		dataName = "ArcSpell Data, Learned Message",
		inputDescription =
		"ArcSpell Data = The exported string / import data for the ArcSpell. You can get this by right-clicking a spell in your vault and hitting 'Export'.\n\rLearned Message = true/false - If it should show a 'You learned the spell!' message.",
		revert = nil,
		doNotDelimit = true,
	}),
	[ACTION_TYPE.ArcCastbar] = scriptAction("Show Castbar", {
		command = function(data)
			--local length, text, iconPath, channeled, showIcon, showShield = strsplit(",", data, 6)

			--[[
			--local args, numArgs = parseArgsWrapper(data)
			if not args then return end
			local length, text, iconPath, channeled, showIcon, showShield = unpack(args)
			--]]
			local success, length, text, iconPath, channeled, showIcon, showShield = pcall(getArgs, data)
			if not success then return end

			if length then length = tonumber(strtrim(length)) end
			if not length then return error("Arcanum Action Usage (Show Castbar): Requires valid length number.") end
			if text then text = strtrim(text) end
			if iconPath then iconPath = { ["icon"] = strtrim(iconPath) } end
			if channeled then channeled = toBoolean(strtrim(channeled)) end
			if showIcon then showIcon = toBoolean(strtrim(showIcon)) end
			if showShield then showShield = toBoolean(strtrim(showShield)) end
			ns.UI.Castbar.showCastBar(length, text, iconPath, channeled, showIcon, showShield)
		end,
		description =
		"Show a custom Arcanum Castbar with your own settings & duration.\n\rSyntax: duration, [title, [iconPath/FileID, [channeled (true/false), [showIcon (true/false), [showShield (true/false)]]]]]\n\rDuration is the only required input.",
		dataName = "Castbar Settings",
		inputDescription = "Syntax: duration, [title, [iconPath/FileID, [channeled (true/false), [showIcon (true/false), [showShield (true/false)]]]]]\n\rDuration is the only required input. " ..
			commaDelimitedText,
		example = Tooltip.genContrastText("5, Cool Spell!, 1, true, true, false") ..
			" will show a Castbar for 5 seconds, named 'Cool Spell!', with a gem icon, but no shield frame.\n\r" ..
			Tooltip.genTooltipText("lpurple", "Icon ID's " .. Tooltip.genContrastText("1 - " .. ns.UI.Icons.getNumCustomIcons()) .. " can be used for Arcanum's custom Icons."),
		revert = nil,
		doNotDelimit = true,
	}),
	[ACTION_TYPE.ArcStopSpells] = scriptAction("Stop ArcSpells", {
		command = function() ns.Actions.Execute.stopRunningActions() end,
		description =
		"Stops all currently running ArcSpells - including this spell if called on a delay.\n\rUse it as the first action with a delay of 0 if you want to cancel any other running ArcSpells before you cast this spell.",
		revert = nil,
	}),
	[ACTION_TYPE.ArcStopThisSpell] = scriptAction("Stop This ArcSpell (If)", {
		command = function(script)
			if script then
				if not script:match("return") then
					script = "return " .. script
				end
				return runMacroText(script)
			else
				return true
			end
		end,
		description =
		"Stops this spell's remaining actions only. Will always stop this spell's actions no matter if used on a delay or not. You may optionally provide a script as the input, and the spell will only be stopped if that script returns true.",
		dataName = "Script",
		inputDescription = "A Lua Script to test if the spell should be stopped.",
		example = Tooltip.genContrastText("GetItemCount(143861) == 0") .. " to only stop if they do not have item 143861 (Tower Key) in their inventory.",
		doNotDelimit = true,
		revert = nil,
	}),
	[ACTION_TYPE.ArcStopSpellByName] = scriptAction("Stop Other ArcSpell", {
		command = function(spellCommID) ns.Actions.Execute.cancelSpellByCommID(spellCommID) end,
		description =
		"Stops another ArcSpell that's currently running, by ArcID.\n\rUse ARC:STOP('ArcID') in a script if you wish to only stop the spell if certain conditions are met.",
		dataName = "ArcSpell ID",
		inputDescription = "The ArcSpell ID (ArcID) of the ArcSpell you wish to stop all remaining actions for.",
		revert = nil,
	}),
	[ACTION_TYPE.ARCSet] = scriptAction("Set My Variable", {
		command = function(data)
			local var, val = strsplit("|", data, 2);
			var = strtrim(var, " \t\r\n\124");
			val = strtrim(val, " \t\r\n\124");
			ARC:SET(var, val);
		end,
		description =
		"Set a Personal ARCVAR to a specific value.\n\rMy ARCVARs can be accessed via the table ARC.VAR, or via ARC:GET() in a macro script.\n\rPersonal ArcVars do not save between sessions.",
		dataName = "VarName | Value",
		inputDescription = "Provide the variable name & the value to set it as, separated by a | character. Inputs are trimmed of leading & trailing spaces.",
		revert = nil,
		revertAlternative = "another Set Variable action",
		example = "KeysCollected | 3",
		doNotDelimit = true,
	}),
	[ACTION_TYPE.ARCTog] = scriptAction("Toggle My Variable", {
		command = function(var) ARC:TOG(var) end,
		description =
		"Toggle a Personal ARCVAR, like a light switch.\n\rPersonal ARCVARs can be accessed via the table ARC.VAR, or via ARC:GET() in a macro script.\n\rPersonal ArcVars do not save between sessions.",
		dataName = "Variable Name",
		inputDescription = "The variable name to toggle.",
		revert = function(var) ARC:TOG(var) end,
		revertDesc = "Toggles the ARCVAR again.",
		doNotDelimit = true,
	}),
	[ACTION_TYPE.ARCPhaseSet] = scriptAction("Set Phase Variable", {
		command = function(data)
			local var, val = strsplit("|", data, 2);
			var = strtrim(var, " \t\r\n\124");
			val = strtrim(val, " \t\r\n\124");
			ARC.PHASE:SET(var, val);
		end,
		description =
		"Set a Phase ARCVAR to a specific value.\n\rPhase ARCVARs can be accessed via the table ARC.PHASEVAR, or via ARC.PHASE:GET() in a macro script.\n\rPhase ArcVars are saved between sessions, but should not be considered secure as a user can manipulate them as well.",
		dataName = "VarName | Value",
		inputDescription = "Provide the variable name & the value to set it as, separated by a | character.",
		revert = nil,
		revertAlternative = "another Phase Set Variable action",
		example = "KeysCollected | 3",
		doNotDelimit = true,
	}),
	[ACTION_TYPE.ARCPhaseTog] = scriptAction("Toggle Phase Variable", {
		command = function(var) ARC.PHASE:TOG(var) end,
		description =
		"Toggle a Phase ARCVAR, like a light switch.\n\rPhase ARCVARs can be accessed via the table ARC.PHASEVAR, or via ARC.PHASE:GET() in a macro script.\n\rPhase ArcVars are saved between sessions, but should not be considered secure as a user can manipulate them as well.",
		dataName = "Variable Name",
		inputDescription = "The variable name to toggle.",
		revert = function(var) ARC.PHASE:TOG(var) end,
		revertDesc = "Toggles the Phase ARCVAR again.",
		doNotDelimit = true,
	}),
	[ACTION_TYPE.ARCCopy] = scriptAction("Copy Text/URL", {
		command = function(text) ARC:COPY(text) end,
		description = "Open a dialog box to copy the given text (i.e., a URL).",
		dataName = "Text / URL",
		inputDescription = "The text / link / URL to copy.",
		example = "https://discord.gg/C8DZ7AxxcG",
		revert = nil,
		doNotDelimit = true,
	}),
	[ACTION_TYPE.PrintMsg] = scriptAction("Chatbox Message", {
		command = print,
		description = "Prints a message in the chatbox.",
		dataName = "Text",
		inputDescription = "The text to print into the chatbox.",
		revert = nil,
		doNotDelimit = true,
	}),
	[ACTION_TYPE.RaidMsg] = scriptAction("Raid Message", {
		command = function(msg)
			RaidNotice_AddMessage(RaidWarningFrame, msg, ChatTypeInfo["RAID_WARNING"])
		end,
		description = "Shows a custom Raid Warning message, only to the person casting the spell.",
		dataName = "Text",
		inputDescription = "The text to show as the raid warning.",
		revert = nil,
		doNotDelimit = true,
	}),
	[ACTION_TYPE.ErrorMsg] = scriptAction("UI Message", {
		command = function(msg)
			--[[
			--local args, numArgs = parseArgsWrapper(msg)
			if not args then return end
			local text, r, g, b, voiceID, soundKitID = unpack(args)
			--]]

			local success, text, r, g, b, voiceID, soundKitID = pcall(getArgs, msg)
			if not success then return end

			ns.Logging.uiErrorMessage(text, r, g, b, voiceID, soundKitID)
		end,
		description = "Shows a custom UI 'Error' message, only to the person casting the spell.\n\rThis is the same style message as 'You cannot do that.' etc.",
		dataName = "Text, R, G, B, voiceID, soundKitID",
		inputDescription =
		"The text to show as the UI Error Message (wrap in quotes \" \" if it contains a comma), along with any RGB (0-1 range). You may provide a voiceID to play also, or put it as 'nil' and then add a soundKitID to play a sound effect.",
		revert = nil,
		example = [["Look, a message!", 1, 0, 0, 12]],
		doNotDelimit = true,
	}),
	[ACTION_TYPE.HideMostUI] = scriptAction("Hide UI", {
		command = function() Scripts.ui.ToggleUIShown(false) end,
		description = "Hides your UI (just like ALT+Z), but leaves Raid Warning & UI Errors shown so you can see messages. UI can always be re-enabled/shown manually by hitting Escape.",
		revertDesc = "Unhides/Re-Shows the UI.",
		revert = function() Scripts.ui.ToggleUIShown(true) end,
	}),
	[ACTION_TYPE.UnhideMostUI] = scriptAction("Unhide/Show UI", {
		command = function() Scripts.ui.ToggleUIShown(true) end,
		description = "Unhides/Shows the UI (just like ALT+Z, a 2nd time).",
		revert = nil,
	}),
	[ACTION_TYPE.FadeOutMainUI] = scriptAction("Fade Out UI", {
		command = function(vars) UIFrameFadeOut(UIParent, tonumber(vars), UIParent:GetAlpha(), 0) end,
		description = "Fades out the main UI over the time given, until it's fully hidden.",
		dataName = "Seconds",
		inputDescription = "The number of seconds it takes for the UI to fade out.",

		revertDesc = "Fades the UI back in, over the same time. Revert timer should likely be longer than your fade out time input, otherwise it will not fully fade out before fading back in.",
		revert = function(vars) UIFrameFadeIn(UIParent, tonumber(vars), UIParent:GetAlpha(), 1) end,
	}),
	[ACTION_TYPE.FadeInMainUI] = scriptAction("Fade In UI", {
		command = function(vars) UIFrameFadeIn(UIParent, tonumber(vars), UIParent:GetAlpha(), 1) end,
		description = "Fades in the main UI over the time given, until it's fully visible.",
		dataName = "Seconds",
		inputDescription = "The number of seconds it takes for the UI to fade in.",

		revertDesc = "Fades the UI out.",
		revert = function(vars) UIFrameFadeOut(UIParent, tonumber(vars), UIParent:GetAlpha(), 0) end,
	}),
	--

	--HideNametags = "HideNametags",
	--ShowNametags = "ShowNametags",
	--ToggleNametags = "ToggleNametags",
	[ACTION_TYPE.HideNames] = scriptAction("Hide Names", {
		command = function() ns.Actions.Data_Scripts.nametags.Disable() end,
		description = "Hides names above NPCs & Players.\n\r" ..
			Tooltip.genContrastText("Please use Revert or Restore Names once done, to ensure you are restoring the original settings!"),

		revertDesc = "Restores your non-Arcanum-modified name settings.",
		revert = function() ns.Actions.Data_Scripts.nametags.Restore() end,
	}),
	[ACTION_TYPE.ShowNames] = scriptAction("Show Names", {
		command = function() ns.Actions.Data_Scripts.nametags.Enable() end,
		description = "Shows names above NPCs & Players.\n\r" ..
			Tooltip.genContrastText("Please use Revert or Restore Names once done, to ensure you are restoring the original settings!"),

		revertDesc = "Restores your non-Arcanum-modified name settings.",
		revert = function() ns.Actions.Data_Scripts.nametags.Restore() end,
	}),
	[ACTION_TYPE.ToggleNames] = scriptAction("Toggle Names", {
		command = function() ns.Actions.Data_Scripts.nametags.Toggle() end,
		description = "Toggles names above NPCs & Players.\n\r" ..
			Tooltip.genContrastText("Please use Restore Names once done, to ensure you are restoring the original settings!"),

		revertDesc = "Toggles names again (NOT A RESTORE - This is still another override).",
		revert = function() ns.Actions.Data_Scripts.nametags.Restore() end,
	}),
	[ACTION_TYPE.RestoreNames] = scriptAction("Restore Names", {
		command = function() ns.Actions.Data_Scripts.nametags.Restore() end,
		description = "Restores your non-Arcanum-modified name settings.",
	}),


	[ACTION_TYPE.BoxMsg] = scriptAction("Popup Box Message", {
		command = function(msg)
			ns.UI.Popups.showCustomGenericConfirmation({
				text = msg,
				acceptText = OKAY,
				cancelText = false,
			})
		end,
		description = "Shows a pop-up box with a custom message.",
		dataName = "Text",
		inputDescription = "The text to show in the popup box.",
		revert = nil,
		doNotDelimit = true,
	}),
	[ACTION_TYPE.BoxPromptCommand] = scriptAction("Command Input Prompt", {
		command = function(msg)
			msg = msg:gsub("nil", "false") -- convert nil to false for backwards compatibility, since parseArgsWrapper makes nil a true nil, and we don't want that

			local success, description, okayText, cancText, command = pcall(getArgs, msg, 4)
			if not success then return end

			if not cancText and not command then command = okayText end
			if not okayText or strtrim(okayText) == "" then okayText = OKAY else okayText = strtrim(okayText) end
			if not cancText or strtrim(cancText) == "" then cancText = CANCEL else cancText = strtrim(cancText) end
			if cancText == "false" then cancText = false end

			command = strtrim(command)
			ns.UI.Popups.showCustomGenericInputBox({
				callback = function(input)
					command = command:gsub("@input", input)
					command = command:gsub("@", input) -- legacy support
					command = command:gsub("||", "|")
					cmdWithDotCheck(command)
				end,
				text = description,
				acceptText = okayText,
				cancelText = cancText,
				editBoxWidth = 260,
				maxLetters = 200,
			})
		end,
		description = "Prompts the user with an input box, then adds that input to the command given.",
		dataName = "Text, OK, Cancel, Command",
		inputDescription = "The text to show in the prompt message, Okay Button Text, Cancel Button Text, and the command to use; separated by commas.\n" ..
			"Use " .. Tooltip.genContrastText("@input") .. " as the placeholder to be replaced by the user input.\n\r" ..
			"Okay and Cancel can be left blank and will default as 'Okay' and 'Cancel'.\n" ..
			"Set Cancel text as 'nil' to hide the Cancel button.",
		example = 'What item do you want to add?,,, additem @input',
		revert = nil,
		doNotDelimit = true,
	}),
	[ACTION_TYPE.BoxPromptScript] = scriptAction("Script Input Prompt", {
		command = function(msg)
			msg = msg:gsub("nil", "false") -- convert nil to false for backwards compatibility, since parseArgsWrapper makes nil a true nil, and we don't want that

			local success, description, okayText, cancText, scriptString = pcall(getArgs, msg, 4)
			if not success then return end

			if not cancText and not scriptString then scriptString = okayText end
			if not okayText or strtrim(okayText) == "" then okayText = OKAY else okayText = strtrim(okayText) end
			if not cancText or strtrim(cancText) == "" then cancText = CANCEL else cancText = strtrim(cancText) end
			if cancText == "false" then cancText = false end

			scriptString = strtrim(scriptString):gsub("@input", "userInput")
			local scriptTest, errorMessageTest = loadstring(scriptString)
			if scriptTest and not errorMessageTest then
				ns.UI.Popups.showCustomGenericInputBox({
					callback = function(userInput)
						local script, errorMessage = loadstring([[
							return function(userInput)
								]] .. (scriptString) .. [[
							end
						]])
						if script and not errorMessage then
							userInput = userInput:gsub("||", "|")
							script()(userInput)
						else
							ns.Logging.eprint("Error with Input while loading Script (Script Input Prompt), please check your input or script. Error:")
							print(errorMessage)
						end
					end,
					text = description,
					acceptText = okayText,
					cancelText = cancText,
					editBoxWidth = 260,
					maxLetters = 9999,
				})
			else
				ns.Logging.eprint("Error Loading Script in ArcSpell Action (Script Input Prompt), please check your script. Error:")
				print(errorMessageTest)
			end
		end,
		description = "Prompts the user with an input box, then adds that input to the script given.",
		dataName = "Text, OK, Cancel, Script",
		inputDescription = "The text to show in the prompt message, Okay Button Text, Cancel Button Text, and the script to use; separated by a comma.\n" ..
			"Use the " .. Tooltip.genContrastText("@input") .. " tag as the placeholder to be replaced by the user input.\n\r" ..
			"Okay and Cancel can be left blank and will default as 'Okay' and 'Cancel'.\n" ..
			"Set Cancel text as 'nil' to hide the Cancel button.",
		example = [[What's 2+2?,,, if @input == "4" then print("Correct!") else print("Nope!") end]],
		revert = nil,
		doNotDelimit = true,
		doNotSanitizeNewLines = true,
	}),
	[ACTION_TYPE.BoxPromptCommandNoInput] = scriptAction("Command Run Prompt", {
		command = function(msg)
			msg = msg:gsub("nil", "false") -- convert nil to false for backwards compatibility, since parseArgsWrapper makes nil a true nil, and we don't want that

			local success, description, okayText, cancText, command = pcall(getArgs, msg, 4)
			if not success then return end

			if not cancText and not command then command = okayText end
			if not okayText or strtrim(okayText) == "" then okayText = OKAY else okayText = strtrim(okayText) end
			if not cancText or strtrim(cancText) == "" then cancText = CANCEL else cancText = strtrim(cancText) end
			if cancText == "false" then cancText = false end

			command = strtrim(command)
			ns.UI.Popups.showCustomGenericConfirmation({
				callback = function()
					cmdWithDotCheck(command)
				end,
				text = description,
				acceptText = okayText,
				cancelText = cancText,
			})
		end,
		description = "Prompts the user with a pop-up confirmation dialogue to run the given command.",
		dataName = "Text, OK, Cancel, Command",
		inputDescription =
		"The text to show in the prompt message, Okay Button Text, Cancel Button Text, and the command to use; separated by commas.\n\rOkay and Cancel can be left blank and will default as 'Okay' and 'Cancel'.\nSet Cancel text as 'nil' to hide the Cancel button.",
		example = 'Do you wish to teleport?, Sure, No thanks!, phase tele CoolArea',
		revert = nil,
		doNotDelimit = true,
	}),
	[ACTION_TYPE.BoxPromptScriptNoInput] = scriptAction("Script Run Prompt", {
		command = function(msg)
			msg = msg:gsub("nil", "false") -- convert nil to false for backwards compatibility, since parseArgsWrapper makes nil a true nil, and we don't want that

			local success, description, okayText, cancText, scriptString = pcall(getArgs, msg, 4)
			if not success then return end

			if not cancText and not scriptString then scriptString = okayText end
			if not okayText or strtrim(okayText) == "" then okayText = OKAY else okayText = strtrim(okayText) end
			if not cancText or strtrim(cancText) == "" then cancText = CANCEL else cancText = strtrim(cancText) end
			if cancText == "false" then cancText = false end

			scriptString = strtrim(scriptString)
			local script, errorMessage = loadstring(scriptString)
			if script and not errorMessage then
				ns.UI.Popups.showCustomGenericConfirmation({
					callback = script,
					text = description,
					acceptText = okayText,
					cancelText = cancText,
				})
			else
				ns.Logging.eprint("Error Loading Script in ArcSpell Action (Run Script Prompt), please check your script. Error:")
				print(errorMessage)
			end
		end,
		description = "Prompts the user with a pop-up confirmation dialog to run the script.",
		dataName = "Text, OK, Cancel, Script",
		inputDescription =
		"The text to show in the prompt message, Okay Button Text, Cancel Button Text, and the script to use; separated by commas.\n\rOkay and Cancel can be left blank and will default as 'Okay' and 'Cancel'.\nSet Cancel text as 'nil' to hide the Cancel button.",
		example = [[Do you want to know the answer?, Yes, No, print("42! But what is the question..?")]],
		revert = nil,
		doNotDelimit = true,
		doNotSanitizeNewLines = true,
	}),
	[ACTION_TYPE.BoxPromptCommandChoice] = scriptAction("Command Choice Prompt", {
		command = function(msg)
			msg = msg:gsub("nil", "false") -- convert nil to false for backwards compatibility, since parseArgsWrapper makes nil a true nil, and we don't want that

			local success, description, okayText, cancText, command, optionsString = pcall(getArgs, msg, 5)
			if not success then return end
			local success, _rawOptions = pcall(parseArgsWrapper, optionsString)
			if not success then return end

			local optionsTable = {}
			local defaultOption

			for k, v in ipairs(_rawOptions) do
				local value, display = strsplit(":", v, 2)

				if value:find("^*") then
					value = value:gsub("^*", "")
					defaultOption = value
				end

				optionsTable[k] = { value = value, text = display or value }
			end

			if not cancText and not command then command = okayText end
			if not okayText or strtrim(okayText) == "" then okayText = OKAY else okayText = strtrim(okayText) end
			if not cancText or strtrim(cancText) == "" then cancText = CANCEL else cancText = strtrim(cancText) end
			if cancText == "false" then cancText = false end
			if okayText == "false" then okayText = false end
			command = strtrim(command)
			local callback = function(input)
				cmdWithDotCheck((command):gsub("@input", input))
			end
			ns.UI.Popups.showCustomGenericDropDown({
				callback = callback,
				text = description,
				acceptText = okayText,
				cancelText = cancText,
				options = optionsTable,
				hasButtons = okayText or cancText, -- wtf happens if you have cancText but not okayText? EEK.
				defaultOption = defaultOption or nil,
			})
		end,
		description = "Prompts the user with a dropdown of choices, then adds that choice as input to the command given.",
		dataName = "Description, OK Button Text, Cancel Button Text, Command, value1:DisplayText1, value2:DisplayText2, ...",
		inputDescription = "The text to show in the prompt message, Okay Button Text, Cancel Button Text, Command to use, and a list a values; separated by commas.\n" ..
			"Use " .. Tooltip.genContrastText("@input") .. " as the placeholder to be replaced by the user input.\n\r" ..
			"Okay and Cancel can be left blank and will default as 'Okay' and 'Cancel'. Cancel can be set as 'nil' to hide the Cancel button.\n" ..
			"Set Okay AND Cancel text as 'nil' to hide both buttons & auto-run when an option is selected.\n" ..
			"Add a " .. Tooltip.genContrastText("*") .. " to the start of a VALUE to make that the default selected option.\n\r" ..
			("Options can be given as either '%s' alone, or as '%s'; value is what is passed into the script, Display Text is what would be shown in the dropdown."):format(
				Tooltip.genContrastText("value"), Tooltip.genContrastText("value:DisplayText")),
		example = [[Where do you want to go?, Teleport, Cancel, .tele @input, oldironforge:Old Iron Forge, Stormwind, *start:Return to Start]],
		revert = nil,
		doNotDelimit = true,
	}),
	[ACTION_TYPE.BoxPromptScriptChoice] = scriptAction("Script Choice Prompt", {
		command = function(msg)
			msg = msg:gsub("nil", "false") -- convert nil to false for backwards compatibility, since parseArgsWrapper makes nil a true nil, and we don't want that

			local success, description, okayText, cancText, scriptString, optionsString = pcall(getArgs, msg, 5)
			if not success then return end
			local success, _rawOptions = pcall(parseArgsWrapper, optionsString)
			if not success then return end

			local optionsTable = {}
			local defaultOption

			for k, v in ipairs(_rawOptions) do
				local value, display = strsplit(":", v, 2)

				if value:find("^*") then
					value = value:gsub("^*", "")
					defaultOption = value
				end

				optionsTable[k] = { value = value, text = display or value }
			end


			if not cancText and not scriptString then scriptString = okayText end
			if not okayText or strtrim(okayText) == "" then okayText = OKAY else okayText = strtrim(okayText) end
			if not cancText or strtrim(cancText) == "" then cancText = CANCEL else cancText = strtrim(cancText) end
			if cancText == "false" then cancText = false end
			if okayText == "false" then okayText = false end

			scriptString = strtrim(scriptString):gsub("@input", "userInput")
			local scriptTest, errorMessageTest = loadstring(scriptString)
			if scriptTest and not errorMessageTest then
				local callback = function(userInput)
					local script, errorMessage = loadstring([[
						return function(userInput)
							]] .. (scriptString) .. [[
						end
					]])
					if script and not errorMessage then
						script()(userInput)
					else
						ns.Logging.eprint("Error with Input while running script (Script Choice Prompt), please check your input or script. Error:")
						print(errorMessage)
					end
				end
				ns.UI.Popups.showCustomGenericDropDown({
					callback = callback,
					text = description,
					acceptText = okayText,
					cancelText = cancText,
					options = optionsTable,
					hasButtons = okayText or cancText,
					defaultOption = defaultOption or nil,
				})
			else
				ns.Logging.eprint("Error Loading Script in ArcSpell Action (Script Choice Prompt), please check your script. Error:")
				print(errorMessageTest)
			end
		end,
		description = "Prompts the user with an dialog box with a dropdown box of options, then adds their choice to the script given.",
		dataName = "Description, OK Button Text, Cancel Button Text, script string, value1:DisplayText1, value2:DisplayText2, ...",
		inputDescription = "The text to show in the prompt message, Okay Button Text, Cancel Button Text, Command to use, and a list a values; separated by commas.\n" ..
			"Use " .. Tooltip.genContrastText("@input") .. " as the placeholder to be replaced by the user input.\n\r" ..
			"Okay and Cancel can be left blank and will default as 'Okay' and 'Cancel'. Cancel can be set as 'nil' to hide the Cancel button.\n" ..
			"Set Okay AND Cancel text as 'nil' to hide both buttons & auto-run when an option is selected.\n" ..
			"Add a " .. Tooltip.genContrastText("*") .. " to the start of a VALUE to make that the default selected option.\n\r" ..
			("Options can be given as either '%s' alone, or as '%s'; value is what is passed into the script, Display Text is what would be shown in the dropdown."):format(
				Tooltip.genContrastText("value"), Tooltip.genContrastText("value:DisplayText")),
		example = [[What color is an Orange?, nil, nil, if @input == 'orange' then print('Nice') end, orange:Orange, apple:Red, banana:Yellow, Green]],
		revert = nil,
		doNotDelimit = true,
		doNotSanitizeNewLines = true,
	}),
	[ACTION_TYPE.OpenSendMail] = scriptAction("Open Mail", {
		command = function(vars)
			--local to, subject, body = unpack(parseStringToArgs(vars))
			--[[
			--local args = parseArgsWrapper(vars)
			if not args then return end
			local to, subject, body = unpack(args, 1, 3)
			--]]
			local success, to, subject, body = pcall(getArgs, vars)
			if not success then return end

			local callback = function()
				Scripts.mail.openMailCallback(to, subject, body)
			end
			if MailFrame:IsShown() then
				callback()
			else
				ns.Utils.Hooks.HookFrameScriptOneShot(MailFrame, "OnShow", callback)
				cmd("cheat mail")
			end
		end,
		description = "Open's the mail UI, and optionally pre-fills a given To: name, Subject, and Body Text if given.",
		dataName = "name, subject, text",
		inputDescription = "the name of who to send the mail, the subject, and the body text.\n\r" .. commaDelimitedText,
		example = [[Mindscape, "Arcanum Rocks, Woo!"]],
		revert = nil,
		doNotDelimit = true,
	}),
	[ACTION_TYPE.SendMail] = scriptAction("Send Mail", {
		command = function(vars)
			--local to, subject, body = unpack(parseStringToArgs(vars))
			--[[
			--local args = parseArgsWrapper(vars)
			if not args then return end
			local to, subject, body = unpack(args, 1, 3)
			--]]

			local success, to, subject, body = pcall(getArgs, vars)
			if not success then return end

			local callback = function()
				Scripts.mail.sendMailCallback(to, subject, body)
			end
			if MailFrame:IsShown() then
				cmd("mod money 30") -- make sure we have the 30 copper to pay
				callback()
			else
				ns.Utils.Hooks.HookFrameScriptOneShot(MailFrame, "OnShow", callback)
				cmd("mod money 30") -- make sure we have the 30 copper to pay
				cmd("cheat mail")
			end
		end,
		description = "Send mail to another player directly, with a specified subject & body text.",
		dataName = "name, subject, text",
		inputDescription = "the name of who to send the mail, the subject, and the body text. All three are required.\n\r" .. commaDelimitedText,
		example = [[Mindscape, "Arcanum Rocks, Woo!", "Dude, I can send you mail automatically now, nice."]],
		revert = nil,
		doNotDelimit = true,
	}),
	-- TalkingHead = "TalkingHead"
	[ACTION_TYPE.TalkingHead] = scriptAction("Show Talking Head", {
		command = function(vars)
			--local args, numArgs = parseArgsWrapper(vars)
			--if not args then return end
			--local message, name, displayID, sound, textureKit, chatType, timeout = unpack(args, 1, numArgs)
			local success, message, name, displayID, sound, textureKit, chatType, timeout = pcall(getArgs, vars)
			if not success then return end

			if not message and name and displayID then return end
			message = tostring(message);
			name = tostring(name) or "Unknown";
			displayID = tonumber(displayID) or displayID;
			-- don't sanitise displayID! it could be a unitID.
			sound = tonumber(sound) or nil;
			timeout = tonumber(timeout) or nil;

			SCForgeTalkingHeadFrame_SetUnit(displayID, name, textureKit, message, sound, chatType, timeout);
		end,
		description =
		"Displays a Talking Head frame with customizable options.",
		dataName = "message, title, displayID [, soundKitID, textureKit, chatType]",
		inputDescription =
			"Syntax: message, title, displayID [, soundKitID, textureKit, chatType, timeout]\n\r" ..
			commaDelimitedText .. "Only message, title, and displayID are required; leave an option blank to skip it.\n\r" ..
			"Available Texture Kits:" ..
			Constants.ADDON_COLORS.TOOLTIP_CONTRAST:GenerateHexColorMarkup() ..
			table.concat({ "Normal", "Neutral", "Epsilon", "Horde", "Alliance" }, "|r, " .. Constants.ADDON_COLORS.TOOLTIP_CONTRAST:GenerateHexColorMarkup()) .. "|r\n\r" ..
			"Available Chat Types:" ..
			Constants.ADDON_COLORS.TOOLTIP_CONTRAST:GenerateHexColorMarkup() ..
			table.concat({ "SAY", "WHISPER", "YELL", "EMOTE", "NONE" }, "|r, " .. Constants.ADDON_COLORS.TOOLTIP_CONTRAST:GenerateHexColorMarkup()) .. "|r\n\r",
		example = [["Message text goes here.", John Doe, 21, , Normal, SAY, 10]],
		revert = nil,
		doNotDelimit = true,
	}),
	-- ShowBook = "ShowBook"
	[ACTION_TYPE.ShowBook] = scriptAction("Show Book", {
		command = function(vars)
			local success, guid = pcall(getArgs, vars);
			if not (guid) then
				return
			end
			EpsilonBook_LoadBook(guid);
		end,
		description =
		"Displays a Book from the current phase's Book Library.\n\nMust be currently in the correct phase or the book will not load.",
		dataName = "GUID",
		inputDescription =
		"Syntax: GUID\r\nThe GUID of the book. GUIDs are case sensitive.",
		example = [[1E2P3_S4I5L60N]],
		revertDesc = "Closes the Book frame.",
		revert = function() EpsilonBookFrame_Hide(); end,
		dependency = "Epsilon_Book",
	}),
	-- HideBook = "HideBook"
	[ACTION_TYPE.HideBook] = scriptAction("Hide Book", {
		command = function()
			EpsilonBookFrame_Hide();
		end,
		description =
		"Closes any currently open Book.",
		revert = nil,
		dependency = "Epsilon_Book",
	}),
	-- ShowPage = "ShowPage"
	[ACTION_TYPE.ShowPage] = scriptAction("Show Page", {
		command = function(vars)
			local success, title, text, material, fontFamily, fontSize, icon = pcall(getArgs, vars);
			if not (title and text) then
				return
			end
			local data = {
				icon = icon or "Interface/Icons/inv_misc_book_09",
				title = title,
				material = material or "Book",
				pages = { text },
				fontFamily = {
					p = fontFamily or "Frizqt",
					h1 = fontFamily or "Frizqt",
					h2 = fontFamily or "Frizqt",
					h3 = fontFamily or "Frizqt",
				},
				fontSize = {
					p = fontSize or 13,
					h1 = fontSize or 18,
					h2 = fontSize or 16,
					h3 = fontSize or 14,
				},
			}
			-- Use a dummy ID of [0] since it's not "real"
			EpsilonBookFrame_Show(0, data, false, true);
		end,
		description =
		"Displays a dummy Book page (not attached to an actual Book) with customisable options (see input syntax for help).",
		dataName = "title, text, [material, fontFamily, fontSize, icon]",
		inputDescription =
			"Syntax: title, text, [material, fontFamily, fontSize, icon].\n\r" ..
			commaDelimitedText .. "\nOnly title and text are required.",
		example = [["Book of Secrets", "Loose lips sink ships!", Trading Post, Frizqt, 13, Interface/Icons/ability_ambush]],
		revertDesc = "Closes the Book frame.",
		revert = function() EpsilonBookFrame_Hide(); end,
		dependency = "Epsilon_Book",
		doNotDelimit = true,
	}),
	-- UnitPowerBar = "UnitPowerBar"
	[ACTION_TYPE.UnitPowerBar] = scriptAction("Show UnitPowerBar", {
		command = function(vars)
			local success, powerValue, minPower, maxPower, textureKit, powerName, powerTooltip, r, g, b, onFinished, isPercentage, flashEnabled = pcall(getArgs, vars)
			if not success then return end

			ns.Logging.dprint(false,
				"pv", powerValue,
				"mnP", minPower,
				"mxP", maxPower,
				"tx", textureKit,
				"pN", powerName,
				"pT", powerTooltip,
				"r", r,
				"g", g,
				"b", b,
				"onF", onFinished,
				"isP", isPercentage,
				"fE", flashEnabled
			)

			if not powerValue and minPower and maxPower then
				SCForge_UnitPowerBar:Hide()
				return
			end
			powerValue = tonumber(powerValue);
			minPower = tonumber(minPower) or 0;
			maxPower = tonumber(maxPower) or 100;
			textureKit = textureKit or "WoWUI"; -- no tostrings, need to allow nil so we can default if nil (instead of giving string 'nil')
			powerName = powerName or "";
			powerTooltip = powerTooltip or nil;
			local colour;
			if tonumber(r) and tonumber(g) and tonumber(b) then
				colour = { r, g, b };
			end

			SCForge_UnitPowerBar:ApplyTextures(textureKit, powerName, powerTooltip, powerValue, colour, onFinished, isPercentage, flashEnabled);
			SCForge_UnitPowerBar:SetMinMaxPower(minPower, maxPower);
			SCForge_UnitPowerBar:Show();
		end,
		description =
		"Displays a UnitPowerBar frame with customizable options (see input syntax for help).",
		dataName = "powerValue, minPower, maxPower, [textureKit, powerName, powerTooltip, r, g, b, onFinished, isPercentage, flashEnabled]",
		inputDescription =
			"Syntax: powerValue, minPower, maxPower, [textureKit, powerName, powerTooltip, r, g, b, onFinished, isPercentage, flashEnabled].\n\r" ..
			commaDelimitedText .. "\nOnly powerValue, minPower, and maxPower are required.\n\rAvailable Texture Kits: " ..
			Constants.ADDON_COLORS.TOOLTIP_CONTRAST:GenerateHexColorMarkup() ..
			table.concat(ns.UI.TalkingHead.TalkingHead.availablePowerBars, "|r, " .. Constants.ADDON_COLORS.TOOLTIP_CONTRAST:GenerateHexColorMarkup()) .. "|r\n\rTexture Kit names are case sensitive.",
		example = [[10, 0, 100, Azerite, Borrowed Power, "Don't worry - you'll get it back eventually!", 1, 1, 1, nil, false, false]],
		revertDesc = "Hides the UnitPowerBar frame.",
		revert = function() SCForge_UnitPowerBar:Hide(); end,
		doNotDelimit = true,
	}),
	[ACTION_TYPE.UnitPowerBarValue] = scriptAction("Update UnitPowerBar Value", {
		command = function(value)
			if SCForge_UnitPowerBar then SCForge_UnitPowerBar.value = tonumber(value) end
		end,
		description =
		"Updates the displaed UnitPowerBar to the value given.\n\rTip: Use a condition to verify if the UnitPowerBar is shown, and is the powerName you are expecting to modify!",
		dataName = "powerValue",
		inputDescription = "Syntax: powerValue",
		example = [[10]],
		doNotDelimit = true,
	}),
	[ACTION_TYPE.TRP3e_Item_QuickImport] = scriptAction("TRP3e Import Item", {
		command = function(code)
			Scripts.TRP3e_items.importItem(code)
		end,
		description =
		"Import a TRP3 Extended item to your TRP3 Extended database.",
		dataName = "trp3e import code",
		inputDescription =
		"The Quick Export/import code for the TRP3 Extended object/item. You can get this code by right-clicking an item in your TRP3 Extended Database and hitting 'Quick export object'.",
		revert = nil,
		doNotDelimit = true,
		dependency = "totalRP3_Extended"
	}),
	[ACTION_TYPE.TRP3e_Item_AddToInventory] = scriptAction("TRP3e Add Item", {
		command = function(id)
			Scripts.TRP3e_items.addItem(id)
		end,
		description =
			"Add a TRP3 Extended item to your TRP3 Extended inventory.\n\rItems will be added to the first free inventory space in the main inventory, and must already exist in your TRP3 Extended Database.\n\rIf you need more control, you'll need to use the " ..
			Tooltip.genContrastText("TRP3_API.inventory.addItem") .. " function in a Macro Script.",
		dataName = "trp3e item ID(s)",
		inputDescription =
		"The Generated ID of an item. You can get this ID from your TRP3 Extended Database, by mousing over an item, or right clicking item and clicking 'Copy ID'. You may provide multiple ID's, separated by commas, to add multiple items.",
		revert = nil,
		dependency = "totalRP3_Extended"
	}),
	[ACTION_TYPE.TRP3e_Cast_showCastingBar] = scriptAction("TRP3e Castbar", {
		command = function(vars)
			--local duration, interruptMode, soundID, castText = unpack(parseStringToArgs(vars))
			--[[
			--local args = parseArgsWrapper(vars)
			if not args then return end
			local duration, interruptMode, soundID, castText = unpack(args, 1, 4)
			--]]
			local success, duration, interruptMode, soundID, castText = pcall(getArgs, vars)
			if not success then return end

			if not duration then return end
			TRP3_API.extended.showCastingBar(tonumber(duration), tonumber(interruptMode), nil, tonumber(soundID), castText)
		end,
		description =
		"Shows a TRP3 Extended Castbar. This is different than an Arcanum Castbar in that it works & looks similar to a default WoW Castbar. You can also make it interrupt on movement.",
		dataName = "duration, interruptMode, soundID, castText",
		inputDescription = Tooltip.genContrastText("duration") .. ": How long the castbar lasts\r" ..
			Tooltip.genContrastText("interruptMode") .. ": 1 = not interruptable, 2 = interrupts on movement\r" ..
			Tooltip.genContrastText("soundID") .. ": Sound ID to play when the cast bar starts\r" ..
			Tooltip.genContrastText("castText") .. [[: The text; defaults to 'Casting' if not set. Wrap in "quotes" if it contains a comma.]],
		revert = function()
			local frame = TRP3_CastingBarFrame
			frame.interruptMode = 2
			frame:GetScript("OnEvent")() -- fires the OnEvent which is a wrapper to the interrupt function that's only local in TRP3's castbar system. Nice hack huh..
		end,
		doNotDelimit = true,
		revertDesc = "Interrupts the castbar to cancel it, even if it was not interruptable.",
		dependency = "totalRP3_Extended"
	}),

	-- Location Actions
	[ACTION_TYPE.SaveARCLocation] = scriptAction("Save Location (ARC)", {
		command = function(key)
			ARC.LOCATIONS:SAVE(key)
		end,
		description =
			("Saves the current location when cast to the ARC.LOCATIONS Storage. You can recall to these locations later by using a revert, the ARC.LOCATIONS API, or using a 'Recall to Location (ARC)' action.).\n\rLocations are preserved thru reloads and relogs, but are not Phase Specific. If using for a phase, consider naming it with your phase number included, i.e., %s instead of just %s.")
			:format(Tooltip.genContrastText("169_Tavern"), Tooltip.genContrastText("Tavern")),
		dataName = "Location Key",
		inputDescription = "The Key (Name) you want to save it as. Keys are unique, so saving another with the same Key/Name will overwrite it.",
		revert = function(key)
			ARC.LOCATIONS:GOTO(key)
		end,
		revertDesc = "Recalls to this saved location at the end of the revert time.",
	}),
	[ACTION_TYPE.GotoARCLocation] = scriptAction("Recall to Location (ARC)", {
		command = function(key)
			ARC.LOCATIONS:GOTO(key)
		end,
		description = "Recalls to a previously saved ARC Location.",
		dataName = "Location Key",
		inputDescription = "The Key (Name) you want to recall to.",
		revert = nil,
	}),
	[ACTION_TYPE.WorldportCommand] = serverAction("Worldport", {
		command = "worldport @N@",
		description = "Worldport to the location data given.",
		dataName = "#x #y [#z [#mapid [#orientation]]]",
		inputDescription = "The location data you would like to world port to. This matches the same format as the command, '.worldport'.",
		revert = nil,
	}),
	[ACTION_TYPE.TeleCommand] = serverAction("Teleport", {
		command = "tele @N@",
		description = "Teleport to a given location.\n\rCommand: " .. Tooltip.genContrastText(".tele"),
		dataName = "Location Name",
		inputDescription = "The location name you would like to tele to. Use " .. Tooltip.genContrastText(".lookup tele") .. " to find teleport location names.",
		revert = nil,
		convertLinks = true,
	}),
	[ACTION_TYPE.PhaseTeleCommand] = serverAction("Phase Tele", {
		command = "phase tele @N@",
		description = "Teleport to a given phase location.\n\rCommand: " .. Tooltip.genContrastText(".phase tele"),
		dataName = "Phase Location",
		inputDescription = "The phase location name you would like to tele to. Use " .. Tooltip.genContrastText(".phase tele list") .. " to find phase tele location names.",
		revert = nil,
		convertLinks = true,
	}),


	-- QC Actions
	[ACTION_TYPE.QCBookToggle] = scriptAction("Toggle Book", {
		command = function(bookName)
			ns.UI.Quickcast.Book.toggleBookByName(bookName)
		end,
		description = "Toggle a Quickcast Book from being displayed on this character.",
		dataName = "Book Name",
		inputDescription = "The name of the Quickcast Book",
		revert = function(bookName)
			ns.UI.Quickcast.Book.toggleBookByName(bookName)
		end,
		revertDesc = "Re-Toggles the Quickcast Book on this character. Why tho?",
	}),
	[ACTION_TYPE.QCBookStyle] = scriptAction("Change Book Style", {
		command = function(vars)
			--[[
			--local args = parseArgsWrapper(vars)
			if not args then return end
			local bookName, styleName = unpack(args, 1, 2)
			--]]
			local success, bookName, styleName = pcall(getArgs, vars)
			if not success then return end

			ns.UI.Quickcast.Book.changeBookStyle(strtrim(bookName), strtrim(styleName))
		end,
		description = "Change a Quickcast Book's Style to another style, either by using the style name or ID.",
		dataName = "Book Name, Style Name/ID",
		inputDescription = "The name of the Quickcast Book & style name or ID.\n\r" .. commaDelimitedText,
		example = '"Quickcast Book 1" Arcfox',
		revert = nil,
		revertAlternative = "another Change Style action",
		doNotDelimit = true,
	}),
	[ACTION_TYPE.QCBookSwitchPage] = scriptAction("Switch Page", {
		command = function(vars)
			--[[
			--local args = parseArgsWrapper(vars)
			if not args then return end
			local bookName, pageNumber = unpack(args, 1, 2)
			--]]
			local success, bookName, pageNumber = pcall(getArgs, vars)
			if not success then return end

			ns.UI.Quickcast.Book.setPageInBook(strtrim(bookName), strtrim(pageNumber))
		end,
		description = "Switch a Quickcast Book to a specific page number.",
		dataName = "Book Name, Page Number",
		inputDescription = "The name of the Quickcast Book & the page number.\n\r" .. commaDelimitedText,
		example = '"Quickcast Book 1", 2',
		revert = nil,
		revertAlternative = "another Switch Page action",
		doNotDelimit = true,
	}),
	[ACTION_TYPE.QCBookNewBook] = scriptAction("New Book", {
		command = function(vars)
			--[[
			--local args = parseArgsWrapper(vars)
			if not args then return end
			local bookName, styleName = unpack(args, 1, 2)
			--]]
			local success, bookName, styleName = pcall(getArgs, vars)
			if not success then return end

			ns.UI.Quickcast.Quickcast.API.NewBook(strtrim(bookName), strtrim(styleName))
		end,
		description = "Create a new Quickcast Book, with an optional default style set.",
		dataName = "Book Name, Style Name/ID",
		inputDescription = "The name for the Quickcast Book & style name/ID to use (optional).\n\r" .. commaDelimitedText,
		example = '"Quickcast Book 1", Red',
		revert = nil,
		doNotDelimit = true,
	}),
	[ACTION_TYPE.QCBookNewPage] = scriptAction("Add Page to Book", {
		command = function(vars)
			local args, numArgs = parseArgsWrapper(vars) -- need to keep using the parseArgsWrapper here because we want the table
			if not args then return end
			local spells
			local success, spellTable = nil, {}
			local bookName, profile = unpack(args, 1, 2)
			if numArgs >= 3 then
				for i = 3, numArgs do
					tinsert(spellTable, args[i])
				end
			end
			if type(profile) == "string" then
				profile = strtrim(profile)
				if profile == "nil" then
					profile = nil
				end
			end

			ns.UI.Quickcast.Quickcast.API.NewPage(strtrim(bookName), spellTable, profile)
		end,
		description = "Add a new page to a Quickcast Book, with optional default spells or dynamic profile assignment.",
		dataName = "Book, Profile|nil, Spell(s)",
		inputDescription =
		"The name of the Quickcast Book; Profile Name to use for dymanic profile, or nil to not use a profile; and a list of ArcSpell ID's to add as the default spells on the page (ignored if using a profile). If your book name, profile name, or any ArcIDs have spaces, enclose it in quotations.",
		example = '"Quickcast Book 1", nil, MySpell1, "My Cool Spell 2"',
		revert = nil,
		doNotDelimit = true,
	}),
	[ACTION_TYPE.QCBookAddSpell] = scriptAction("Add Spell to Book/Page", {
		command = function(vars)
			--local bookName, pageNumber, commID = AceConsole:GetArgs(vars, 3)
			local args, numArgs = parseArgsWrapper(vars) -- need to keep using the parseArgsWrapper here because we want the table
			if not args then return end
			local spells
			local success, spellTable = nil, {}
			local bookName, pageNumber = unpack(args, 1, 2)
			if numArgs >= 3 then
				for i = 3, numArgs do
					tinsert(spellTable, args[i])
				end
			end
			if not next(spellTable) then return end
			for _, commID in ipairs(spellTable) do
				ns.UI.Quickcast.Quickcast.API.AddSpell(bookName, tonumber(pageNumber), commID)
			end
		end,
		description = "Add a spell by ArcSpell ID to a specific page in a Quickcast Book.",
		dataName = "Book, Page, ArcSpell(s)",
		inputDescription = "The name of the Quickcast Book & the page number, followed by a list of spells to add.\n\r" .. commaDelimitedText,
		example = '"Quickcast Book 1", 2, ArcSpellID1, ArcSpellID2',
		revert = nil,
		doNotDelimit = true,
	}),
	[ACTION_TYPE.RotateCameraLeftStart] = scriptAction("Rotate Cam Left", {
		command = function(speed)
			SaveView(5)
			local realSpeed = (speed / tonumber(GetCVar("cameraYawMoveSpeed")))
			MoveViewLeftStart(realSpeed)

			-- Bugfix for Rotation triggered on delay calculates as if it was rotating the entire time. We offset by applying an inverse rotation for the delay time, which gets stopped on the next frame (which is actually the frame rotation starts on)
			MoveViewRightStart(realSpeed)
			C_Timer.After(0, MoveViewRightStop)
		end,
		description = "Rotate the camera left, in degrees per second. " .. Tooltip.genTooltipText("warning", "Must be reverted to properly stop rotation!"),
		dataName = "Degrees per Second",
		inputDescription = "The number of degrees, per second, to rotate.",
		example = Tooltip.genContrastText("45") .. " to rotate 45 degrees to the left each second.",
		revert = function()
			MoveViewLeftStop()
			SetView(5)
		end,
		revertDesc = "Stops the camera rotation & returns the camera to the players original camera view.",
		doNotDelimit = true,
	}),
	[ACTION_TYPE.RotateCameraRightStart] = scriptAction("Rotate Cam Right", {
		command = function(speed)
			SaveView(5)
			local realSpeed = (speed / tonumber(GetCVar("cameraYawMoveSpeed")))
			MoveViewRightStart(realSpeed)

			-- Bugfix for Rotation triggered on delay calculates as if it was rotating the entire time. We offset by applying an inverse rotation for the delay time, which gets stopped on the next frame (which is actually the frame rotation starts on)
			MoveViewLeftStart(realSpeed)
			C_Timer.After(0, MoveViewLeftStop)
		end,
		description = "Rotate the camera right, in degrees per second. " .. Tooltip.genTooltipText("warning", "Must be reverted to properly stop rotation!"),
		dataName = "Degrees per Second",
		inputDescription = "The number of degrees, per second, to rotate.",
		example = Tooltip.genContrastText("45") .. " to rotate 45 degrees to the right each second.",
		revert = function()
			MoveViewRightStop()
			SetView(5)
		end,
		revertDesc = "Stops the camera rotation & returns the camera to the players original camera view.",
		doNotDelimit = true,
	}),
	[ACTION_TYPE.RotateCameraUpStart] = scriptAction("Rotate Cam Up", {
		command = function(speed)
			SaveView(5)
			MoveViewUpStart(speed / tonumber(GetCVar("cameraPitchMoveSpeed")))
		end,
		description = "Rotate the camera up, in degrees per second. " .. Tooltip.genTooltipText("warning", "Must be reverted to properly stop rotation!"),
		dataName = "Degrees per Second",
		inputDescription = "The number of degrees, per second, to rotate.",
		example = Tooltip.genContrastText("45") .. " to rotate 45 degrees up each second.",
		revert = function()
			MoveViewUpStop()
			SetView(5)
		end,
		revertDesc = "Stops the camera rotation & returns the camera to the players original camera view.",
		doNotDelimit = true,
	}),
	[ACTION_TYPE.RotateCameraDownStart] = scriptAction("Rotate Cam Down", {
		command = function(speed)
			SaveView(5)
			MoveViewDownStart(speed / tonumber(GetCVar("cameraPitchMoveSpeed")))
		end,
		description = "Rotate the camera down, in degrees per second. " .. Tooltip.genTooltipText("warning", "Must be reverted to properly stop rotation!"),
		dataName = "Degrees per Second",
		inputDescription = "The number of degrees, per second, to rotate.",
		example = Tooltip.genContrastText("45") .. " to rotate 45 degrees down each second.",
		revert = function()
			MoveViewDownStop()
			SetView(5)
		end,
		revertDesc = "Stops the camera rotation & returns the camera to the players original camera view.",
		doNotDelimit = true,
	}),
	[ACTION_TYPE.ZoomCameraOutStart] = scriptAction("Zoom Cam Out", {
		command = function(speed)
			--SaveView(5)
			MoveViewOutStart(speed / tonumber(GetCVar("cameraZoomSpeed")))
		end,
		description = "Zoom the camera out by the given amount per second. " .. Tooltip.genTooltipText("warning", "Must be reverted to properly stop movement!"),
		dataName = "Zoom Speed",
		inputDescription = "The speed at which to zoom (roughly yards per second).",
		example = Tooltip.genContrastText("5") .. " to zoom the camera out at 5 yards per second.",
		revert = function()
			MoveViewOutStop()
			--SetView(5)
		end,
		revertDesc = "Stops the camera movement, but does NOT return the camera to the players original camera view. Use a separate Save & Load Zoom action to restore Zoom levels after if needed.",
		doNotDelimit = true,
	}),
	[ACTION_TYPE.ZoomCameraInStart] = scriptAction("Zoom Cam In", {
		command = function(speed)
			--SaveView(5)
			MoveViewInStart(speed / tonumber(GetCVar("cameraZoomSpeed")))
		end,
		description = "Zoom the camera in by the given amount per second. " .. Tooltip.genTooltipText("warning", "Must be reverted to properly stop movement!"),
		dataName = "Zoom Speed",
		inputDescription = "The speed at which to zoom (roughly yards per second).",
		example = Tooltip.genContrastText("5") .. " to zoom the camera in at 5 yards per second.",
		revert = function()
			MoveViewInStop()
			--SetView(5)
		end,
		revertDesc = "Stops the camera movement, but does NOT return the camera to the players original camera view. Use a separate Save & Load Zoom action to restore Zoom levels after if needed.",
		doNotDelimit = true,
	}),
	[ACTION_TYPE.ZoomCameraSet] = scriptAction("Set Cam Zoom", {
		command = Scripts.camera.SetZoom,
		description = "Zoom the camera to a specific zoom amount. ",
		dataName = "Zoom Distance",
		inputDescription = "The Zoom amount you wish to set the camera to.",
		example = Tooltip.genContrastText("0") .. " to set the camera zoom to 0 (First Person).",
		revert = Scripts.camera.RevertZoom,
		revertDesc = "Returns the Camera Zoom level to the previous level before this action.",
		doNotDelimit = true,
	}),
	[ACTION_TYPE.ZoomCameraOutBy] = scriptAction("Zoom Cam Out By..", {
		command = CameraZoomOut,
		description = "Zoom the camera out by an exact distance. ",
		dataName = "Zoom Speed",
		inputDescription = "The Zoom amount you wish to zoom out by.",
		example = Tooltip.genContrastText("3") .. " to zoom out by 3 yards.",
		revert = CameraZoomIn,
		revertDesc = "Zooms the camera back in by the same amount.",
		doNotDelimit = true,
	}),
	[ACTION_TYPE.ZoomCameraInBy] = scriptAction("Zoom Cam In By..", {
		command = CameraZoomIn,
		description = "Zoom the camera in by an exact distance. ",
		dataName = "Zoom Speed",
		inputDescription = "The Zoom amount you wish to zoom in by.",
		example = Tooltip.genContrastText("3") .. " to zoom in by 3 yards.",
		revert = CameraZoomOut,
		revertDesc = "Zooms the camera back out by the same amount.",
		doNotDelimit = true,
	}),
	[ACTION_TYPE.ZoomCameraSaveCurrent] = scriptAction("Save Current Zoom", {
		command = Scripts.camera.SaveZoom,
		description = "Saves the current Zoom Level. Can be used with a Restore Zoom action to return to the last saved Zoom level.",
		dataName = nil,
		revert = Scripts.camera.RestoreSavedZoom,
		revertDesc = "Restores the saved Zoom level. You can use this to simplify instead of needing a separate Restore Zoom action.",
	}),
	[ACTION_TYPE.ZoomCameraLoadSaved] = scriptAction("Restore Zoom", {
		command = Scripts.camera.RestoreSavedZoom,
		description = "Saves the current Zoom Level. Can be used with a Restore Zoom action to return to the last saved Zoom level.",
		dataName = nil,
		revert = nil,
	}),
	[ACTION_TYPE.MouselookModeStart] = scriptAction("Enter Mouselook Mode", {
		command = Scripts.camera.EnableMouselook,
		description =
			"Enters mouse look mode; alters the character's movement/facing direction to where your mouse is aiming.\n\rInput: The Key to Exit Mouselook Mode. Exit Keys can accept modifiers (alt, shift, and ctrl) by adding them before the key, separated by a dash (" ..
			Tooltip.genTooltipText("example", "ALT-SHIFT-Z") .. ").\n\r" .. Tooltip.genContrastText("If not given, exit key defaults to 'Escape'."),
		dataName = "Exit Key",
		inputDescription =
		"The Key-Binding to use to Exit Mouselook Mode. Exit Key binds are also cleared as soon as they are ran, meaning you can use it to override a key, and then that key will return to original behavior after done.\n\rEx: Using Z will override Z for Sheathe while in Mouselook mode, but once Mouselook mode is exited, Z will return to Sheathe control.",
		example = Tooltip.genContrastText("Z") .. " to set it so that pressing Z cancels Mouselook mode.",
		revert = Scripts.camera.DisableMouselook,
		revertDesc = "Exits Mouselook Mode & Clears the Exit Binding.",
		doNotDelimit = true,
	}),

	[ACTION_TYPE.RotateCameraStop] = scriptAction("Stop Cam Movement", {
		command = function()
			MoveViewRightStop()
			MoveViewLeftStop()
			MoveViewUpStop()
			MoveViewDownStop()
			MoveViewInStop()
			MoveViewOutStop()
			MouselookStop()
		end,
		description = "Stops All Camera Rotations, including Mouselook. " ..
			Tooltip.genTooltipText("warning", "You should really use a revert delay on the original rotate action instead of this! This can get skipped/cancelled and leave the camera in rotate hell!"),
		revert = nil,
		revertAlternative = "another rotate camera action",
	}),
	[ACTION_TYPE.SpawnBlueprint] = serverAction("Spawn Blueprint", {
		command = "gob blue spawn @N@",
		description = "Spawns a Gob Blueprint at your position.",
		dataName = "Blueprint ID",
		inputDescription = "The ID of the Blueprint to spawn.",
		example = Tooltip.genContrastText("144997") .. " to spawn a Teacup Blueprint.",
		revert = "go group del",
		revertDesc = "Deletes the currently selected gob group. " ..
			Tooltip.genTooltipText("warning", "Do not select another Gob Group between this action & it's revert or else it will delete that other gob group instead of the spawned blueprint!"),
		doNotDelimit = true,
	}),
	[ACTION_TYPE.ArcTrigCooldown] = scriptAction("Trigger ArcSpell Cooldown", {
		command = function(vars)
			local commID, cooldownTime, isPhase = AceConsole:GetArgs(vars, 3) -- TODO: GET RID OF THIS I HATE IT
			if isPhase then isPhase = toBoolean(isPhase) end
			ns.Actions.Cooldowns.addSpellCooldown(commID, cooldownTime, (isPhase and C_Epsilon.GetPhaseId() or nil))
		end,
		description = "Triggers a Cooldown on another ArcSpell. Useful for Sparks that are just pre-checks to then cast another ArcSpell.",
		dataName = "$arcSpellID #length &phase",
		inputDescription =
			"#arcSpellID = The ArcSpell ID of the spell to put on cooldown\n\r#length = How long (in seconds) for the cooldown\n\r&phase = " ..
			Tooltip.genContrastText("true") .. " if it should be a Phase Spell, leave blank for Personal Spell.\n\rIf your ArcSpell ID has spaces, enclose it in quotations.",
		example = Tooltip.genContrastText('"Watergun Blast" 2 true') .. " to put the Phase ArcSpell 'Watergun Blast' on a 2 second cooldown.",
		revert = nil,
		revertAlternative = true,
		doNotDelimit = true,
	}),

	-- Kinesis Integrations
	[ACTION_TYPE.Kinesis_TempDisableAll] = scriptAction("Temp Disable All", {
		command = function(vars)
			if not Kinesis then return end
			Kinesis.TempDisableAll()
		end,
		description = "Temporarily Disable Kinesis (Sprint, Flight, and EFD).",
		revert = function(vars)
			if not Kinesis then return end
			Kinesis.TempDisableReset()
		end,
		revertDesc =
		"Removes this Temporary Disable, allowing Kinesis to function as per the user's original settings.",
		dependency = "Kinesis",
	}),
	[ACTION_TYPE.Kinesis_TempDisableFlight] = scriptAction("Temp Disable Flight", {
		command = function(vars)
			if not Kinesis then return end
			Kinesis.TempDisableFlight()
		end,
		description = "Temporarily Disable Kinesis' Flight Controls & EFD Modules.",
		revert = function(vars)
			if not Kinesis then return end
			Kinesis.TempDisableFlightReset()
		end,
		revertDesc =
		"Removes this Temporary Disable, allowing Kinesis to function as per the user's original settings.",
		dependency = "Kinesis",
	}),
	[ACTION_TYPE.Kinesis_TempDisableSprint] = scriptAction("Temp Disable Sprint", {
		command = function(vars)
			if not Kinesis then return end
			Kinesis.TempDisableSprint()
		end,
		description = "Temporarily Disable Kinesis' Shift-Sprint Module.",
		revert = function(vars)
			if not Kinesis then return end
			Kinesis.TempDisableSprintReset()
		end,
		revertDesc =
		"Removes this Temporary Disable, allowing Kinesis to function as per the user's original settings.",
		dependency = "Kinesis",
	}),

	[ACTION_TYPE.Kinesis_TempDisableAllRst] = scriptAction("Reset Temp Disable (All)", {
		command = function(vars)
			if not Kinesis then return end
			Kinesis.TempDisableReset()
		end,
		description = "Remove all Temporary Disables, allowing Kinesis to function as per the user's original settings.",
		dependency = "Kinesis",
	}),

	[ACTION_TYPE.Kinesis_FlyEnable] = scriptAction("Toggle Flight Controls", {
		command = function(vars)
			if not Kinesis then return end
			revertHoldingVars[ACTION_TYPE.Kinesis_FlyEnable] = Kinesis.Flight.GetFlightControlsEnabled()
			Kinesis.Flight.SetFlightControlsEnabled(onToBoolean(vars))
		end,
		description = "Toggle Kinesis' 'Creative Mode' Flight Controls On/Off",
		dataName = "on/off",
		inputDescription = "On or Off to set the Flight Controls ('Creative Mode') toggle to that.",
		example = Tooltip.genContrastText("On") .. " to turn on Creative Mode Flight Controls.",
		revert = function(vars)
			if not Kinesis then return end
			if onToBoolean(vars) then
				Kinesis.Flight.SetFlightControlsEnabled(not (onToBoolean(vars)))
			else
				Kinesis.Flight.SetFlightControlsEnabled(revertHoldingVars[ACTION_TYPE.Kinesis_FlyEnable])
			end
		end,
		revertDesc =
		"Resets the Flight Controls toggle back to what it was set to before. Note that this may not directly revert your action. For example, if the Flight Controls is toggled off, and you run this action to turn if off, with a revert, it will remain off.",
		dependency = "Kinesis",
		softDependency = true,
		doNotDelimit = true,
	}),
	[ACTION_TYPE.Kinesis_EFDEnable] = scriptAction("Toggle Ext. Flight Detection", {
		command = function(vars)
			if not Kinesis then return end
			revertHoldingVars[ACTION_TYPE.Kinesis_EFDEnable] = Kinesis.Flight.GetEFDEnabled()
			Kinesis.Flight.SetEFDEnabled(onToBoolean(vars))
		end,
		description = "Toggle Kinesis' Extended Flight Detection On/Off",
		dataName = "on/off",
		inputDescription = "On or Off to set the Extended Flight Detection toggle to that.",
		example = Tooltip.genContrastText("Off") .. " to turn on Kinesis Extended Flight Detection.",
		revert = function(vars)
			if not Kinesis then return end
			if onToBoolean(vars) then
				Kinesis.Flight.SetEFDEnabled(not (onToBoolean(vars)))
			else
				Kinesis.Flight.SetEFDEnabled(revertHoldingVars[ACTION_TYPE.Kinesis_EFDEnable])
			end
		end,
		revertDesc =
		"Resets the Extended Flight Detection toggle back to what it was set to before. Note that this may not directly revert your action. For example, if the Extended Flight Detection is toggled off, and you run this action to turn if off, with a revert, it will remain off.",
		dependency = "Kinesis",
		softDependency = true,
		doNotDelimit = true,
	}),
	[ACTION_TYPE.Kinesis_LandJumpSet] = scriptAction("Jump-To-Land", {
		command = function(vars)
			if not Kinesis then return end
			Kinesis.Flight.SetJumpToLand(tonumber(vars))
		end,
		description = "Set Kinesis' Jump-To-Land Feature as Double Jump, Triple Jump, or Disabled.",
		dataName = "Number of Jumps",
		inputDescription = Tooltip.genContrastText("0, 2, or 3") .. "\n\rThe number of jumps (2 or 3) needed to disable flight (AKA: Land).\rUse 0 to disable.",
		example = Tooltip.genContrastText("2") .. " to set Double Jump to disable flight.",
		revert = nil,
		dependency = "Kinesis",
		doNotDelimit = true,
	}),
	[ACTION_TYPE.Kinesis_AutoLandDelay] = scriptAction("Auto-Land Delay", {
		command = function(vars)
			if not Kinesis then return end
			Kinesis.Flight.SetLandingDelay(tonumber(vars))
		end,
		description = "Set Kinesis' Auto-Land Delay Timer (in seconds). This is how long you are on the ground before automatically disabling flight. Set to 0 to disable.",
		dataName = "Seconds",
		inputDescription = "The number of seconds you are on the ground before disabling flight mode.\n\rSet to 0 to disable.",
		example = Tooltip.genContrastText("2") .. " to disable flight if you have been on the ground for 2 seconds.",
		revert = nil,
		dependency = "Kinesis",
	}),

	-- Kinesis Flight Spells
	[ACTION_TYPE.Kinesis_ToggleFlightSpells] = scriptAction("Enable Flight Spells", {
		command = function(vars)
			if not Kinesis then return end
			Kinesis.Flight.Spells.SetSpellsEnabled(onToBoolean(vars))
		end,
		description =
		"Enable or Disable triggering standard spells when you start Flying. Standard spells are applied using aura; if you need more control, consider using an ArcSpell.",
		dataName = "On/Off",
		inputDescription = "The Move Type (walk/fly/swim), followed by on/off to enable or disable that Move Type.",
		example = Tooltip.genContrastText("on") .. " to enable Flight Spells when triggering flying.",
		revert = nil,
		dependency = "Kinesis",
		doNotDelimit = true,
	}),

	[ACTION_TYPE.Kinesis_FlightArcEnabled] = scriptAction("Tog. Flight ArcSpells", {
		command = function(vars)
			if not Kinesis then return end
			Kinesis.Flight.Spells.SetSpellArcanumEnabled(onToBoolean(vars))
		end,
		description = "Enable or Disable triggering ArcSpells when you start & stop Flying.",
		dataName = "On/Off",
		inputDescription = "On to enable triggering ArcSpells, Off to disable.",
		example = Tooltip.genContrastText("on") .. " to enable Flight triggering Arc Spells.",
		revert = nil,
		dependency = "Kinesis",
		doNotDelimit = true,
	}),
	[ACTION_TYPE.Kinesis_FlightArcStart] = scriptAction("Flight Start ArcSpell", {
		command = function(vars)
			if not Kinesis then return end
			Kinesis.Flight.Spells.SetSpellArcanumStart(vars)
		end,
		description = "Set the ArcSpell that will be cast when you start Flying.",
		dataName = "ArcSpell ID",
		inputDescription = "The ArcSpell ID of the spell to cast when you start flying. Must be an ArcSpell in your Personal Vault.",
		example = Tooltip.genContrastText("myFlightModeArcSpell") .. " to set that Arcanum Spell to be cast when you start flying.",
		revert = nil,
		dependency = "Kinesis",
		doNotDelimit = true,
	}),
	[ACTION_TYPE.Kinesis_FlightArcStop] = scriptAction("Flight Stop ArcSpell", {
		command = function(vars)
			if not Kinesis then return end
			Kinesis.Flight.Spells.SetSpellArcanumStop(vars)
		end,
		description = "Set the ArcSpell that will be cast when you stop Flying.",
		dataName = "ArcSpell ID",
		inputDescription = "The ArcSpell ID of the spell to cast when you stop flying. Must be an ArcSpell in your Personal Vault.",
		example = Tooltip.genContrastText("stopFlyingArcSpell") .. " to set that Arcanum Spell to be cast when you stop flying.",
		revert = nil,
		dependency = "Kinesis",
		doNotDelimit = true,
	}),

	[ACTION_TYPE.Kinesis_FlightSetSpells] = scriptAction("Set Flight Spells", {
		command = function(vars)
			if not Kinesis then return end
			local spellLists = Kinesis.Flight.Spells.StandardSpellsGetSets()
			local backupName = "ArcBackup_" .. UnitName("player")
			if spellLists[backupName] then
				local index = 1
				while (spellLists[backupName .. tostring(index)]) do
					index = index + 1
					if index > maxBackupsPerChar - 1 then
						index = 1
						break
					end
				end
				Kinesis.Flight.Spells.StandardSpellsSaveSet(backupName .. tostring(index), true, select(2, Kinesis.Flight.Spells.GetCurrentSpellList()))
			else
				Kinesis.Flight.Spells.StandardSpellsSaveSet(backupName, true, select(2, Kinesis.Flight.Spells.GetCurrentSpellList()))
			end
			Kinesis.Flight.Spells.StandardSpellsSetSpells(vars)
		end,
		description =
		"Set your Kinesis Flight Spells to the spells you specify.\n\rYour previous set of spells will be saved in a temporary backup Spell Set in the /kinesis menu.",
		dataName = "Spell ID(s)",
		inputDescription = "Spell IDs, separated by a command if you want multiple.",
		example = Tooltip.genContrastText("123, 456, 789") .. " to set your Flight Spells as 123, 456, 789.",
		revert = nil,
		dependency = "Kinesis",
		doNotDelimit = true,
	}),
	[ACTION_TYPE.Kinesis_FlightLoadSpellSet] = scriptAction("Load Flight Spell Set", {
		command = function(vars)
			if not Kinesis then return end
			Kinesis.Flight.Spells.StandardSpellsLoadSet(vars)
		end,
		description = "Load a Flight Spell Set by name.",
		dataName = "Spell Set Name",
		inputDescription = "The name of the Flight Spell Set to set as your current spells. Case sensitive (because MindScape was too lazy to fix it).",
		example = Tooltip.genContrastText("My Awesome Flight spells!") .. " to set that Flight Spell Set as your current Flight Spells.",
		revert = nil,
		dependency = "Kinesis",
		doNotDelimit = true,
	}),


	-- Kinesis Sprint

	[ACTION_TYPE.Kinesis_SprintEnabled] = scriptAction("Toggle All Shift-Sprint", {
		command = function(vars)
			if not Kinesis then return end
			revertHoldingVars[ACTION_TYPE.Kinesis_SprintEnabled] = Kinesis.Sprint.GetShiftSprintEnabled()
			Kinesis.Sprint.SetShiftSprintEnabled(onToBoolean(vars))
		end,
		description = "Toggle Kinesis' 'Shift-Sprint' Module On/Off",
		dataName = "on/off",
		inputDescription = "On or Off to set the Shift-Sprint toggle to that.",
		example = Tooltip.genContrastText("On") .. " to turn on Shift-Sprinting.",
		revert = function(vars)
			if not Kinesis then return end
			if onToBoolean(vars) then
				Kinesis.Sprint.SetShiftSprintEnabled(not (onToBoolean(vars)))
			else
				Kinesis.Sprint.SetShiftSprintEnabled(revertHoldingVars[ACTION_TYPE.Kinesis_SprintEnabled])
			end
		end,
		revertDesc =
		"Resets the Shift-Sprint Enabled toggle back to what it was set to before. Note that this may not directly revert your action. For example, if it is toggled off, and you run this action to turn if off, with a revert, it will remain off.",
		dependency = "Kinesis",
		softDependency = true,
		doNotDelimit = true,
	}),
	[ACTION_TYPE.Kinesis_SprintGround] = scriptAction("Sprint Speed (Ground)", {
		command = function(vars)
			if not Kinesis then return end
			Kinesis.Sprint.SetSprintSpeedGround(tonumber(vars))
		end,
		description = "Set the speed to use when sprinting on the ground.",
		dataName = "speed",
		inputDescription = "The speed to use for sprinting on the ground.",
		example = Tooltip.genContrastText("1.6") .. " to set your ground sprint speed to 1.6x normal speed.",
		revert = nil,
		dependency = "Kinesis",
		doNotDelimit = true,
	}),
	[ACTION_TYPE.Kinesis_SprintFly] = scriptAction("Sprint Speed (Fly)", {
		command = function(vars)
			if not Kinesis then return end
			Kinesis.Sprint.SetSprintSpeedFly(tonumber(vars))
		end,
		description = "Set the speed to use when sprinting while flying.",
		dataName = "speed",
		inputDescription = "The speed to use for sprinting while flying.",
		example = Tooltip.genContrastText("10") .. " to set your flying sprint speed to 10x normal speed.",
		revert = nil,
		dependency = "Kinesis",
		doNotDelimit = true,
	}),
	[ACTION_TYPE.Kinesis_SprintSwim] = scriptAction("Sprint Speed (Swim)", {
		command = function(vars)
			if not Kinesis then return end
			Kinesis.Sprint.SetSprintSpeedSwim(tonumber(vars))
		end,
		description = "Set the speed to use when sprinting while swimming.",
		dataName = "speed",
		inputDescription = "The speed to use for sprinting while swimming.",
		example = Tooltip.genContrastText("5") .. " to set your swimming sprint speed to 5x normal speed.",
		revert = nil,
		dependency = "Kinesis",
		doNotDelimit = true,
	}),
	[ACTION_TYPE.Kinesis_SprintReturnOrig] = scriptAction("Tog. Return Speed", {
		command = function(vars)
			if not Kinesis then return end
			Kinesis.Sprint.SetReturnToOriginalSpeed(onToBoolean(vars))
		end,
		description = "Toggles if your speed should return to the last speed you were at (Original Speed), or always return to speed 1, when you stop sprinting.",
		dataName = "On/Off",
		inputDescription = "On = Return to Last Speed (Original Speed)\nOff = Always Return to Speed One",
		example = Tooltip.genContrastText("On") .. " to always return to your last speed when stopping sprinting.",
		revert = nil,
		dependency = "Kinesis",
		doNotDelimit = true,
	}),

	[ACTION_TYPE.Kinesis_SprintEmoteAll] = scriptAction("Enable Sprint Emote", {
		command = function(vars)
			if not Kinesis then return end
			--local movetype, val = strsplit(",", vars)

			--[[
			--local args = parseArgsWrapper(vars)
			if not args then return end
			local movetype, val = unpack(args)
			--]]
			local success, movetype, val = pcall(getArgs, vars)
			if not success then return end

			movetype = strtrim(string.lower(movetype))
			if movetype == "walk" or movetype == "ground" then
				Kinesis.Sprint.Emotes.SetEmoteTriggerWalk(onToBoolean(val))
			elseif movetype == "fly" then
				Kinesis.Sprint.Emotes.SetEmoteTriggerFly(onToBoolean(val))
			elseif movetype == "swim" then
				Kinesis.Sprint.Emotes.SetEmoteTriggerSwim(onToBoolean(val))
			end
		end,
		description = "Toggles sending the Sprint Emote when you start sprinting for the various Move Types (Ground, Fly, Swim).",
		dataName = "MoveType, on/off",
		inputDescription = "The movetype (walk/fly/swim), followed by on/off to enable or disable that move-type.",
		example = Tooltip.genContrastText("swim, off") .. " to disable .",
		revert = nil,
		dependency = "Kinesis",
		doNotDelimit = true,
	}),
	[ACTION_TYPE.Kinesis_SprintEmoteText] = scriptAction("Sprint Emote Message", {
		command = function(vars)
			if not Kinesis then return end
			Kinesis.Sprint.Emotes.SetEmoteText(vars)
		end,
		description = "desc",
		dataName = "data",
		inputDescription = "input.",
		example = Tooltip.genContrastText("begins to sprint.") .. " to set your Sprint Emote as '/emote begins to sprint.'.",
		revert = nil,
		dependency = "Kinesis",
		doNotDelimit = true,
	}),
	[ACTION_TYPE.Kinesis_SprintEmoteRate] = scriptAction("Sprint Emote Rate", {
		command = function(vars)
			if not Kinesis then return end
			Kinesis.Sprint.Emotes.SetEmoteRateLimit(tonumber(vars))
		end,
		description = "desc",
		dataName = "data",
		inputDescription = "input.",
		example = Tooltip.genContrastText("5") .. " to limit Sprint Emotes to once every 5 seconds max.",
		revert = nil,
		dependency = "Kinesis",
		doNotDelimit = true,
	}),

	[ACTION_TYPE.Kinesis_SprintSpellAll] = scriptAction("Enable Sprint Spell", {
		command = function(vars)
			if not Kinesis then return end
			--local movetype, val = strsplit(",", vars)

			--[[
			--local args = parseArgsWrapper(vars)
			if not args then return end
			local movetype, val = unpack(args)
			--]]
			local success, movetype, val = pcall(getArgs, vars)
			if not success then return end

			movetype = strtrim(string.lower(movetype))
			if movetype == "walk" or movetype == "ground" then
				Kinesis.Sprint.Spells.SetSpellTriggerWalk(onToBoolean(val))
			elseif movetype == "fly" then
				Kinesis.Sprint.Spells.SetSpellTriggerFly(onToBoolean(val))
			elseif movetype == "swim" then
				Kinesis.Sprint.Spells.SetSpellTriggerSwim(onToBoolean(val))
			end
		end,
		description =
		"Enable or Disable triggering standard spells when you start sprinting for the different Move Types (Ground, Fly, Swim). Standard spells are applied using aura; if you need more control, consider using an ArcSpell.",
		dataName = "MoveType, On/Off",
		inputDescription = "The Move Type (walk/fly/swim), followed by on/off to enable or disable that Move Type.",
		example = Tooltip.genContrastText("fly, on") .. " to enable Sprint Spells when triggering sprinting while flying.",
		revert = nil,
		dependency = "Kinesis",
		doNotDelimit = true,
	}),

	[ACTION_TYPE.Kinesis_SprintArcEnabled] = scriptAction("Tog. Sprint ArcSpells", {
		command = function(vars)
			if not Kinesis then return end
			Kinesis.Sprint.Spells.SetSpellArcanumEnabled(onToBoolean(vars))
		end,
		description = "Enable or Disable triggering ArcSpells when you start & stop sprinting.",
		dataName = "On/Off",
		inputDescription = "On to enable triggering ArcSpells, Off to disable.",
		example = Tooltip.genContrastText("on") .. " to enable Sprint triggering Arc Spells.",
		revert = nil,
		dependency = "Kinesis",
		doNotDelimit = true,
	}),
	[ACTION_TYPE.Kinesis_SprintArcStart] = scriptAction("Sprint Start ArcSpell", {
		command = function(vars)
			if not Kinesis then return end
			Kinesis.Sprint.Spells.SetSpellArcanumStart(vars)
		end,
		description = "Set the ArcSpell that will be cast when you start sprinting.",
		dataName = "ArcSpell ID",
		inputDescription = "The ArcSpell ID of the spell to cast when you start sprinting. Must be an ArcSpell in your Personal Vault.",
		example = Tooltip.genContrastText("mySprintingArcSpell") .. " to set that Arcanum Spell to be cast when you start sprinting.",
		revert = nil,
		dependency = "Kinesis",
		doNotDelimit = true,
	}),
	[ACTION_TYPE.Kinesis_SprintArcStop] = scriptAction("Sprint Stop ArcSpell", {
		command = function(vars)
			if not Kinesis then return end
			Kinesis.Sprint.Spells.SetSpellArcanumStop(vars)
		end,
		description = "Set the ArcSpell that will be cast when you stop sprinting.",
		dataName = "ArcSpell ID",
		inputDescription = "The ArcSpell ID of the spell to cast when you stop sprinting. Must be an ArcSpell in your Personal Vault.",
		example = Tooltip.genContrastText("stopSprintingArcSpell") .. " to set that Arcanum Spell to be cast when you stop sprinting.",
		revert = nil,
		dependency = "Kinesis",
		doNotDelimit = true,
	}),

	[ACTION_TYPE.Kinesis_SprintSetSpells] = scriptAction("Set Sprint Spells", {
		command = function(vars)
			if not Kinesis then return end
			local spellLists = Kinesis.Sprint.Spells.StandardSpellsGetSets()
			local backupName = "ArcBackup_" .. UnitName("player")
			if spellLists[backupName] then
				local index = 1
				while (spellLists[backupName .. tostring(index)]) do
					index = index + 1
					if index > maxBackupsPerChar - 1 then
						index = 1
						break
					end
				end
				Kinesis.Sprint.Spells.StandardSpellsSaveSet(backupName .. tostring(index), true, select(2, Kinesis.Sprint.Spells.GetCurrentSpellList()))
			else
				Kinesis.Sprint.Spells.StandardSpellsSaveSet(backupName, true, select(2, Kinesis.Sprint.Spells.GetCurrentSpellList()))
			end
			Kinesis.Sprint.Spells.StandardSpellsSetSpells(vars)
		end,
		description =
		"Set your Kinesis Sprint Spells to the spells you specify.\n\rYour previous set of spells will be saved in a temporary backup Spell Set in the /kinesis menu.",
		dataName = "Spell ID(s)",
		inputDescription = "Spell IDs, separated by a command if you want multiple.",
		example = Tooltip.genContrastText("123, 456, 789") .. " to set your Sprint Spells as 123, 456, 789.",
		revert = nil,
		dependency = "Kinesis",
		doNotDelimit = true,
	}),
	[ACTION_TYPE.Kinesis_SprintLoadSpellSet] = scriptAction("Load Sprint Spell Set", {
		command = function(vars)
			if not Kinesis then return end
			Kinesis.Sprint.Spells.StandardSpellsLoadSet(vars)
		end,
		description = "Load a Sprint Spell Set by name.",
		dataName = "Spell Set Name",
		inputDescription = "The name of the Sprint Spell Set to set as your current spells. Case sensitive (because MindScape was too lazy to fix it).",
		example = Tooltip.genContrastText("My Awesome sprint spells!") .. " to set that Sprint Spell Set as your current Sprint Spells.",
		revert = nil,
		dependency = "Kinesis",
		doNotDelimit = true,
	}),

	-- SECURE Actions
	-- secCast = "secCast",							-- Copy of /cast
	[ACTION_TYPE.secCast] = scriptAction("Cast Spell (/cast)", {
		command = function(vars)
			local script = [[/cast ]] .. vars
			RunPrivileged("RunMacroText('" .. script .. "')")
		end,
		description = "Casts a Spell using the same parsing as /cast.\nSpell must be known in order to be able to cast it.",
		dataName = "[options] spell name",
		inputDescription = "Anything you would normally include in a macro using /cast (but not including '/cast' itself). Reminder: /cast only accepts spells by name.",
		example =
		"[@cursor] Jump Jets",
		revert = nil,
		revertAlternative = "a separate unaura or stop spell action.",
		doNotDelimit = true,
		requirement = "C_Epsilon.RunPrivileged",
		disabledWarning = "\nAction Unavailable (EPSI_RSP_MISSING)"
	}),
	-- secCastID = "secCastID",                        --CastSpellByID(spellID [, target]) #protected
	[ACTION_TYPE.secCastID] = scriptAction("Cast Spell by ID (Blizz-like)", {
		command = function(vars)
			RunPrivileged("CastSpellByID(" .. vars .. ")")
		end,
		description =
		"Casts a spell by ID. This is 'Blizz-like' and casts the real spell from your spell book, not using server commands.\nThis means spells like ground-targeted spells still give you the option to click where to cast it.\nMust also have the spell known/learned.",
		dataName = "SpellID [, \"unitID\"]",
		inputDescription =
		"Any Spell ID, and optionally a UnitID to set who it will target. If unitID is not given, default is whatever the default of that spell is (i.e., target, or cursor, or self).\n\rCommon UnitIDs: 'player', 'target', 'cursor', 'mouseover', 'partyN' (where N = number 1,2,3,4 for which party member).\nUnitIDs must be wrapped in \"quotes\".",
		example =
		"<4336> to cast 'Jump Jets', and still gives you the option to select where to cast it at.",
		revert = function()
			RunPrivileged("SpellStopCasting()")
		end,
		doNotDelimit = true,
		revertDesc = "Stops any currently casting spells (yes, any, even if it's not the one cast by this action).",
		requirement = "C_Epsilon.RunPrivileged",
		disabledWarning = "\nAction Unavailable (EPSI_RSP_MISSING)"
	}),
	-- secStopCasting = "secStopCasting",                --SpellStopCasting() #protected - Stops the current spellcast.
	[ACTION_TYPE.secStopCasting] = scriptAction("Stop Casting", {
		command = function(vars)
			RunPrivileged("SpellStopCasting()")
		end,
		description =
		"Stops the current spellcast.",
		revertAlternative = "another cast spell action",
		requirement = "C_Epsilon.RunPrivileged",
		disabledWarning = "\nAction Unavailable (EPSI_RSP_MISSING)"
	}),
	-- secUseItem = "secUseItem",                      --UseItemByName(itemName, unit) #protected - Uses the specified item.
	[ACTION_TYPE.secUseItem] = scriptAction("Use Item", {
		command = function(vars)
			RunPrivileged("UseItemByName(" .. vars .. ")")
		end,
		description =
		"Use an item by name.",
		dataName = "\"Item Name\" [, \"unitID\"]",
		inputDescription =
		"Any Item Name, and optionally a UnitID to set who it will target. If unitID is not given, default is whatever the default of that item is (i.e., target, or cursor, or self).\n\rCommon UnitIDs: 'player', 'target', 'cursor', 'mouseover', 'partyN' (where N = number 1,2,3,4 for which party member).\nUnitIDs must be wrapped in \"quotes\".\n\rMust have the item in your inventory in order to use it.",
		example =
		"<Cheap Beer> to use the item 'Cheap Beer' (19222).",
		revert = function()
			RunPrivileged("SpellStopCasting()")
		end,
		doNotDelimit = true,
		revertDesc = "Stops any currently casting spells (because most item uses are just casting spells - and yes, stops any casting spell, even if it's not the one cast by this item).",
		requirement = "C_Epsilon.RunPrivileged",
		disabledWarning = "\nAction Unavailable (EPSI_RSP_MISSING)"
	}),

	-- secTarget = "secTarget",                        --TargetUnit([name, exactMatch]) #protected - Targets the specified unit.
	[ACTION_TYPE.secTarget] = scriptAction("Target (/target)", {
		command = function(vars)
			RunPrivileged("TargetUnit(" .. vars .. ")")
		end,
		description =
		"Targets the specified unit.",
		dataName = "[\"name\" [, exactMatch]]",
		inputDescription =
		"Any Name, and optionally if it should only search for an exact match (true/false).\nName must be wrapped in \"quotes\".",
		example =
		"<\"Bear\", true> to target the first found unit with the name <Bear> exactly. Since it is flagged for exact match, it will NOT target anything else with Bear in the name, like 'Brown Bear'.",
		revert = function()
			RunPrivileged("ClearTarget()")
		end,
		revertDesc = "Clears your current target.",
		doNotDelimit = true,
		requirement = "C_Epsilon.RunPrivileged",
		disabledWarning = "\nAction Unavailable (EPSI_RSP_MISSING)"
	}),
	-- SecureAssist = "SecureAssist",                        --AssistUnit([name, exactMatch]) #protected - Assists the unit by targeting the same target.
	[ACTION_TYPE.secAssist] = scriptAction("Assist Target (/assist)", {
		command = function(vars)
			RunPrivileged("AssistUnit(" .. vars .. ")")
		end,
		description =
		"Assists the specified unit.",
		dataName = "[\"name\" [, exactMatch]]",
		inputDescription =
		"Any Name, or UnitID, maybe? And optionally if it should only search for an exact match (true/false).\nName must be wrapped in \"quotes\". If no input is given, assists your current target, if able.",
		example =
		"<\"Mindscape\", true> to target the same thing character 'Mindscape' is targeting, if they're around you.",
		revert = function()
			RunPrivileged("ClearTarget()")
		end,
		revertDesc = "Clears your current target.",
		doNotDelimit = true,
		requirement = "C_Epsilon.RunPrivileged",
		disabledWarning = "\nAction Unavailable (EPSI_RSP_MISSING)"
	}),
	-- ClearTarget = "ClearTarget",                          -- ClearTarget() : willMakeChange #protected - Clears the selected target
	[ACTION_TYPE.secClearTarg] = scriptAction("Clear Target", {
		command = function(vars)
			RunPrivileged("ClearTarget()")
		end,
		description =
		"Clears the selected target.",
		dataName = nil,
		revert = nil,
		revertAlternative = "another Target action",
		requirement = "C_Epsilon.RunPrivileged",
		disabledWarning = "\nAction Unavailable (EPSI_RSP_MISSING)"
	}),

	-- secTargLEnemy = "secTargLEnemy",                  -- TargetLastEnemy() #protected - Targets the previously targeted enemy.
	[ACTION_TYPE.secTargLEnemy] = scriptAction("Target Last (Enemy)", {
		command = function(vars)
			RunPrivileged("TargetLastEnemy()")
		end,
		description =
		"Targets the last previously targeted enemy.",
		dataName = nil,
		revert = function()
			RunPrivileged("ClearTarget()")
		end,
		revertDesc = "Clears your current target.",
		requirement = "C_Epsilon.RunPrivileged",
		disabledWarning = "\nAction Unavailable (EPSI_RSP_MISSING)"
	}),
	-- secTargLFriend = "secTargLFriend",                -- TargetLastFriend
	[ACTION_TYPE.secTargLFriend] = scriptAction("Target Last (Friend)", {
		command = function(vars)
			RunPrivileged("TargetLastFriend()")
		end,
		description =
		"Targets the last previously targeted friend.",
		dataName = nil,
		revert = function()
			RunPrivileged("ClearTarget()")
		end,
		revertDesc = "Clears your current target.",
		requirement = "C_Epsilon.RunPrivileged",
		disabledWarning = "\nAction Unavailable (EPSI_RSP_MISSING)"
	}),
	-- secTargLTarg = "secTargLTarg",                -- TargetLastTarget() #protected - Selects the last target as the current target.
	[ACTION_TYPE.secTargLTarg] = scriptAction("Target Last (Any)", {
		command = function(vars)
			RunPrivileged("TargetLastTarget()")
		end,
		description =
		"Selects the last target as the current target.",
		dataName = nil,
		revert = function()
			RunPrivileged("ClearTarget()")
		end,
		revertDesc = "Clears your current target.",
		requirement = "C_Epsilon.RunPrivileged",
		disabledWarning = "\nAction Unavailable (EPSI_RSP_MISSING)"
	}),
	-- secTargNAny = "secTargNAny",                      -- TargetNearest([reverse]) #protected
	[ACTION_TYPE.secTargNAny] = scriptAction("Target Nearest (Any)", {
		command = function(vars)
			RunPrivileged("TargetNearest(" .. vars .. ")")
		end,
		description =
		"Targets the nearest thing to you.\nOptional flag to reverse the targetting order (selecting furthest instead of nearest).",
		dataName = "[reverse]",
		inputDescription = "Reverse targetting order (true | false). Default if left blank is false (nearest).",
		revert = function()
			RunPrivileged("ClearTarget()")
		end,
		revertDesc = "Clears your current target.",
		requirement = "C_Epsilon.RunPrivileged",
		disabledWarning = "\nAction Unavailable (EPSI_RSP_MISSING)"
	}),
	-- secTargNEnemy = "secTargNEnemy",            -- TargetNearestEnemy([reverse]) #protected - Selects the nearest enemy as the current target.
	[ACTION_TYPE.secTargNEnemy] = scriptAction("Target Nearest (Enemy)", {
		command = function(vars)
			RunPrivileged("TargetNearestEnemy(" .. vars .. ")")
		end,
		description =
		"Selects the nearest enemy as the current target.\nOptional flag to reverse the targetting order (selecting furthest instead of nearest).",
		dataName = "[reverse]",
		inputDescription = "Reverse targetting order (true | false). Default if left blank is false (nearest).",
		revert = function()
			RunPrivileged("ClearTarget()")
		end,
		revertDesc = "Clears your current target.",
		requirement = "C_Epsilon.RunPrivileged",
		disabledWarning = "\nAction Unavailable (EPSI_RSP_MISSING)"
	}),
	-- TargetNearestEnemyPlayer = "TargetNearestEnemyPlayer", -- TargetNearestEnemyPlayer([reverse]) #protected - Selects the nearest enemy player as the current target.
	[ACTION_TYPE.secTargNEnPlayer] = scriptAction("Target Nearest (Enemy Player)", {
		command = function(vars)
			RunPrivileged("TargetNearestEnemyPlayer(" .. vars .. ")")
		end,
		description =
		"Selects the nearest enemy player as the current target.\nOptional flag to reverse the targetting order (selecting furthest instead of nearest).",
		dataName = "[reverse]",
		inputDescription = "Reverse targetting order (true | false). Default if left blank is false (nearest).",
		revert = function()
			RunPrivileged("ClearTarget()")
		end,
		revertDesc = "Clears your current target.",
		requirement = "C_Epsilon.RunPrivileged",
		disabledWarning = "\nAction Unavailable (EPSI_RSP_MISSING)"
	}),
	-- TargetNearestFriend = "TargetNearestFriend",          -- TargetNearestFriend([reverse]) #protected - Targets the nearest friendly unit.
	[ACTION_TYPE.secTargNFriend] = scriptAction("Target Nearest (Friend)", {
		command = function(vars)
			RunPrivileged("TargetNearestFriend(" .. vars .. ")")
		end,
		description =
		"Targets the nearest friendly unit.\nOptional flag to reverse the targetting order (selecting furthest instead of nearest).",
		dataName = "[reverse]",
		inputDescription = "Reverse targetting order (true | false). Default if left blank is false (nearest).",
		revert = function()
			RunPrivileged("ClearTarget()")
		end,
		revertDesc = "Clears your current target.",
		requirement = "C_Epsilon.RunPrivileged",
		disabledWarning = "\nAction Unavailable (EPSI_RSP_MISSING)"
	}),
	-- TargetNearestFriendPlayer = "TargetNearestFriendPlayer", -- TargetNearestFriendPlayer([reverse]) #protected - Selects the nearest friendly player as the current target.
	[ACTION_TYPE.secTargNFrPlayer] = scriptAction("Target Nearest (Friendly Player)", {
		command = function(vars)
			RunPrivileged("TargetNearestFriendPlayer(" .. vars .. ")")
		end,
		description =
		"Selects the nearest friendly player as the current target.\nOptional flag to reverse the targetting order (selecting furthest instead of nearest).",
		dataName = "[reverse]",
		inputDescription = "Reverse targetting order (true | false). Default if left blank is false (nearest).",
		revert = function()
			RunPrivileged("ClearTarget()")
		end,
		revertDesc = "Clears your current target.",
		requirement = "C_Epsilon.RunPrivileged",
		disabledWarning = "\nAction Unavailable (EPSI_RSP_MISSING)"
	}),
	-- TargetNearestPartyMember = "TargetNearestPartyMember", -- TargetNearestPartyMember([reverse]) #protected - Selects the nearest Party member as the current target.
	[ACTION_TYPE.secTargNParty] = scriptAction("Target Nearest (Party)", {
		command = function(vars)
			RunPrivileged("TargetNearestPartyMember(" .. vars .. ")")
		end,
		description =
		"Selects the nearest Party member as the current target.\nOptional flag to reverse the targetting order (selecting furthest instead of nearest).",
		dataName = "[reverse]",
		inputDescription = "Reverse targetting order (true | false). Default if left blank is false (nearest).",
		revert = function()
			RunPrivileged("ClearTarget()")
		end,
		revertDesc = "Clears your current target.",
		requirement = "C_Epsilon.RunPrivileged",
		disabledWarning = "\nAction Unavailable (EPSI_RSP_MISSING)"
	}),
	-- TargetNearestRaidMember = "TargetNearestRaidMember",  -- TargetNearestRaidMember([reverse]) #protected - Selects the nearest Raid member as the current target.
	[ACTION_TYPE.secTargNRaid] = scriptAction("Target Nearest (Raid)", {
		command = function(vars)
			RunPrivileged("TargetNearestRaidMember(" .. vars .. ")")
		end,
		description =
		"Selects the nearest Raid member as the current target.\nOptional flag to reverse the targetting order (selecting furthest instead of nearest).",
		dataName = "[reverse]",
		inputDescription = "Reverse targetting order (true | false). Default if left blank is false (nearest).",
		revert = function()
			RunPrivileged("ClearTarget()")
		end,
		revertDesc = "Clears your current target.",
		requirement = "C_Epsilon.RunPrivileged",
		disabledWarning = "\nAction Unavailable (EPSI_RSP_MISSING)"
	}),

	-- FocusUnit = "FocusUnit",                              -- FocusUnit([name]) #protected - Sets the focus target.
	[ACTION_TYPE.secFocus] = scriptAction("Set Focus", {
		command = function(vars)
			RunPrivileged("FocusUnit('" .. vars .. "')")
		end,
		description =
		"Sets the focus target.",
		dataName = "name",
		inputDescription =
		"Name of the unit to set as the focus target, or optionally a UnitID instead.\n\rCommon UnitIDs: 'player', 'target', 'cursor', 'mouseover', 'partyN' (where N = number 1,2,3,4 for which party member)",
		revert = function()
			RunPrivileged("ClearFocus()")
		end,
		revertDesc = "Clears your current focus.",
		requirement = "C_Epsilon.RunPrivileged",
		disabledWarning = "\nAction Unavailable (EPSI_RSP_MISSING)"
	}),

	-- secClearFocus = "secClearFocus",                      -- ClearFocus() #protected - Clears the focus target.
	[ACTION_TYPE.secClearFocus] = scriptAction("Clear Focus", {
		command = function(vars)
			RunPrivileged("ClearFocus()")
		end,
		description =
		"Clears the focus target.",
		dataName = nil,
		revertAlternative = "another Set Focus action",
		requirement = "C_Epsilon.RunPrivileged",
		disabledWarning = "\nAction Unavailable (EPSI_RSP_MISSING)"
	}),

	-- FollowUnit = "FollowUnit",                            -- FollowUnit(unit) #hwevent - Follows a friendly player unit.
	[ACTION_TYPE.FollowUnit] = scriptAction("Follow Unit", {
		command = function(vars)
			if not vars then vars = "target" end
			RunPrivileged("FollowUnit('" .. vars .. "')")
		end,
		description =
			"Follows the given unit. Potentially only works on a friendly player unit.\n\r" .. commonUnitIDs,
		dataName = nil,
		revert = function() RunPrivileged("MoveForwardStart(0); MoveForwardStop(0)") end,
		revertDesc = "Stops following the unit.",
		requirement = "C_Epsilon.RunPrivileged",
		disabledWarning = "\nAction Unavailable (EPSI_RSP_MISSING)"
	}),
	[ACTION_TYPE.StopFollow] = scriptAction("Stop Following", {
		command = function(vars)
			RunPrivileged("MoveForwardStart(0); MoveForwardStop(0)")
		end,
		description =
		"Stops Following anything, if you are.",
		dataName = nil,
		revertAlternative = "another Follow Unit action",
		requirement = "C_Epsilon.RunPrivileged",
		disabledWarning = "\nAction Unavailable (EPSI_RSP_MISSING)"
	}),
	-- ToggleRun = "ToggleRun",                              -- ToggleRun() #protected - Toggle between running and walking.
	[ACTION_TYPE.ToggleRun] = scriptAction("Toggle Run/Walk", {
		command = function(vars)
			RunPrivileged("ToggleRun()")
		end,
		description =
		"Toggle between running and walking.",
		dataName = nil,
		revert = function() RunPrivileged("ToggleRun()") end,
		revertDesc = "Toggles between running & walking again.",
		requirement = "C_Epsilon.RunPrivileged",
		disabledWarning = "\nAction Unavailable (EPSI_RSP_MISSING)"
	}),
	-- ToggleAutoRun = "ToggleAutoRun",                      -- ToggleAutoRun() #protected - Turns auto-run on or off.
	[ACTION_TYPE.ToggleAutoRun] = scriptAction("Toggle Auto Run", {
		command = function(vars)
			RunPrivileged("ToggleAutoRun()")
		end,
		description =
		"Toggle Auto Run On or Off (Depending if it's already on or not).",
		dataName = nil,
		revert = function() RunPrivileged("ToggleAutoRun()") end,
		revertDesc = "Toggles Auto Run again.",
		requirement = "C_Epsilon.RunPrivileged",
		disabledWarning = "\nAction Unavailable (EPSI_RSP_MISSING)"
	}),
	-- StartAutoRun = "StartAutoRun" 			-- StartAutoRun() #protected
	[ACTION_TYPE.StartAutoRun] = scriptAction("Start Auto Run", {
		command = function(vars)
			RunPrivileged("StartAutoRun()")
		end,
		description =
		"Starts Auto Running.",
		dataName = nil,
		revert = function() RunPrivileged("StopAutoRun()") end,
		revertDesc = "Stops Auto Running.",
		requirement = "C_Epsilon.RunPrivileged",
		disabledWarning = "\nAction Unavailable (EPSI_RSP_MISSING)"
	}),
	-- StopAutoRun = "StopAutoRun" 				-- StopAutoRun() #protected
	[ACTION_TYPE.StopAutoRun] = scriptAction("Stop Auto Run", {
		command = function(vars)
			RunPrivileged("StopAutoRun()")
		end,
		description =
		"Stops Auto Running.",
		dataName = nil,
		revert = function() RunPrivileged("StartAutoRun()") end,
		revertDesc = "Starts Auto Running.",
		requirement = "C_Epsilon.RunPrivileged",
		disabledWarning = "\nAction Unavailable (EPSI_RSP_MISSING)"
	}),

	-- SendSay = "SendSay",              -- SendChatMessage("SAY")
	[ACTION_TYPE.SendSay] = scriptAction("/say", {
		command = function(vars)
			local rps_command = ("SendChatMessage('%s', 'SAY')"):format(vars:gsub("'", "\\'"))
			RunPrivileged(rps_command)
		end,
		description =
		"Sends a /say chat message.",
		dataName = 'Message to Say',
		doNotDelimit = true,
		revertAlternative = "You can't unsay things..",
		requirement = "C_Epsilon.RunPrivileged",
		disabledWarning = "\nAction Unavailable (EPSI_RSP_MISSING)"
	}),

	-- SendYell = "SendYell",            -- SendChatMessage("YELL")
	-- SendEmote = "SendEmote",          -- SendChatMessage("EMOTE")
	-- SendChannel = "SendChannel",      -- SendChatMessage("CHANNEL")
	-- SendRaidWarning = "SendRaidWarning", -- SendChatMessage("RAID_WARNING")



	-- TBD if we want to use these..
	-- RunMacro = "RunMacro",                                -- RunMacro(id or name) #protected - Executes a macro.
	-- RunMacroText = "RunMacroText",                        -- RunMacroText(macro) #protected - Executes a string as if it was a macro.
	-- StopMacro = "StopMacro",                              -- StopMacro() #protected - Stops the currently executing macro.

}


---End Point for Registering a New Action; Other AddOns can use this to add their own actions to the database. // We should convert the above to use this instead in another data library file for easier organization..
---@param key string
---@param type "server"|string|any
---@param name string
---@param category string
---@param actionData FunctionActionTypeData|ServerActionTypeData
---@return boolean|nil
local function registerActionData(key, type, name, category, actionData)
	if not key or not type or not name or not actionData then return false end
	if ACTION_TYPE[key] then return false, error(key .. " is already a defined ACTION_TYPE - Cannot Overwrite.") end

	local typeFunction
	if type == "server" then
		typeFunction = serverAction
	else
		typeFunction = scriptAction
	end

	ACTION_TYPE[key] = key

	actionTypeData[key] = typeFunction(name, actionData)

	-- The main ARC.RegisterAction() func will handle both this & adding to the dropdowns.

	return true
end

---@class Actions_Data
ns.Actions.Data = {
	ACTION_TYPE = ACTION_TYPE,
	actionTypeData = actionTypeData,

	registerActionData = registerActionData,

	parseArgsWrapper = parseArgsWrapper,
	getArgs = getArgs
}
