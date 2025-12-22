---@class ns
local ns = select(2, ...)

local Aura = ns.Utils.Aura
local Cmd = ns.Cmd
local Logging = ns.Logging
local Vault = ns.Vault
local libs = ns.Libs

local Constants = ns.Constants
local AceConsole = ns.Libs.AceConsole

local cmd, cmdWithDotCheck = Cmd.cmd, Cmd.cmdWithDotCheck
local sendAddonCmd, sendAddonCmdChain = Cmd.sendAddonCmd, Cmd.sendAddonCmdChain
local runMacroText = Cmd.runMacroText
local cprint = Logging.cprint
local eprint = Logging.eprint
local isNotDefined = ns.Utils.Data.isNotDefined
local parseStringToArgs = ns.Utils.Data.parseStringToArgs

local next = next
local tinsert = tinsert
local tremove = tremove

local actionVars = {}
local keybindFrame = CreateFrame("Button", "SCFORGE_ACTION_KEYBIND_HOLDER")

--------------------
--#region General?
--------------------
local ui = {}

function ui.ToggleUIShown(shown)
	-- UI Error Frame & Raid Message Frame are hooked to stay visible when the UI is hidden in SpellCreator.lua AddOn Loaded handler.
	SetUIVisibility(shown)
end

--------------------
--#endregion
--------------------

--------------------
--#region Keybinds
--------------------

---@class KeyBindItem
---@type function[]

---@class KeyBindTable
---@type table { [Hotkey]: KeyBindItem}
keybindFrame.bindings = {}

---@param key Hotkey
---@param func function callback function when the hotkey is triggered
function keybindFrame:RegisterKeybindScript(key, func)
	if not key or not func then return end
	if self.bindings[key] then
		tinsert(self.bindings[key], func)
	else
		self.bindings[key] = {
			func
		}
	end
	SetOverrideBindingClick(self, true, key, "SCFORGE_ACTION_KEYBIND_HOLDER", key)
end

---@param key Hotkey
function keybindFrame:UnregisterKeybindKey(key)
	self.bindings[key] = nil
	SetOverrideBinding(self, true, key, nil)
end

---@param key Hotkey
---@param func function
function keybindFrame:UnregisterKeybindScript(key, func)
	if self.bindings[key] then
		tDeleteItem(self.bindings[key], func)

		if #self.bindings[key] == 0 then -- This key has no more binding scripts, clear it from the holding table
			self:UnregisterKeybindKey(key)
		end
	end
end

keybindFrame:SetScript("OnClick", function(self, key)
	local bindingFuncs = self.bindings[key]
	if bindingFuncs then
		for i = 1, #bindingFuncs do
			local func = bindingFuncs[i]
			if func then
				func(key, func) -- Called with key & itself as the reference, so it's easy to use a UnregisterKeybindScript
			end
		end
	end
end)
------------------------
--#endregion
------------------------

------------------------
--#region Camera Scripts
------------------------
local camera = {}
function camera.SetZoom(zoomAmount)
	local curZoom = GetCameraZoom()
	actionVars.ZoomCameraSet_PreviousZoom = curZoom
	local newZoom = zoomAmount - curZoom
	if newZoom > 0 then CameraZoomOut(newZoom) else CameraZoomIn(math.abs(newZoom)) end
end

function camera.RevertZoom()
	if actionVars.ZoomCameraSet_PreviousZoom then
		local curZoom = GetCameraZoom()
		local newZoom = actionVars.ZoomCameraSet_PreviousZoom - curZoom
		if newZoom > 0 then CameraZoomOut(newZoom) else CameraZoomIn(math.abs(newZoom)) end
	end
end

function camera.SaveZoom()
	actionVars.ZoomCameraSaveCurrent_SavedZoom = GetCameraZoom()
end

function camera.RestoreSavedZoom()
	if actionVars.ZoomCameraSaveCurrent_SavedZoom then
		camera.SetZoom(actionVars.ZoomCameraSaveCurrent_SavedZoom)
	end
end

local function _disableMouselookAndUnregisterSelf(key, func)
	if not IsMouselooking() then return end
	MouselookStop()
	keybindFrame:UnregisterKeybindScript(key, func)
end

function camera.DisableMouselook(key)
	key = string.upper(key)
	_disableMouselookAndUnregisterSelf(key, _disableMouselookAndUnregisterSelf)
end

function camera.EnableMouselook(key)
	if isNotDefined(key) then
		key = "ESCAPE"
		--return eprint("Mouselook mode must have an Exit Key given.")
	end
	key = string.upper(key)
	keybindFrame:RegisterKeybindScript(key, _disableMouselookAndUnregisterSelf)
	MouselookStart()
end

--------------------
--#endregion
--------------------

------------------------
--#region Nametag Scripts
------------------------

local nameCVars = {
	"UnitNameOwn",
	"UnitNameNPC",
	"UnitNamePlayerGuild",
	"UnitNamePlayerPVPTitle",
	"UnitNameFriendlyPlayerName",
	"UnitNameFriendlyPetName",
	"UnitNameFriendlyGuardianName",
	"UnitNameFriendlyTotemName",
	"UnitNameEnemyPlayerName",
	"UnitNameEnemyPetName",
	"UnitNameEnemyGuardianName",
	"UnitNameEnemyTotemName",
	"UnitNameNonCombatCreatureName",
	"UnitNameGuildTitle",
}
local savedNameCVars = {}
local areNamesShown = true
local namesAreToggled = false

local nametags = {}
function nametags.Enable()
	areNamesShown = true
	namesAreToggled = true
	for k, v in pairs(nameCVars) do
		SetCVar(v, 1)
	end
end

function nametags.Disable()
	areNamesShown = false
	namesAreToggled = true
	for k, v in pairs(nameCVars) do
		SetCVar(v, 0)
	end
end

function nametags.Restore()
	namesAreToggled = false
	areNamesShown = true -- might not be true but for toggle purposes let's assume they are
	for k, v in pairs(nameCVars) do
		SetCVar(v, savedNameCVars[v] or "0")
	end
end

function nametags.Toggle()
	--[[
	if namesAreToggled then -- Ignore what the current settings are, we are currently overriding, so toggle should just restore
		nametags.Restore()
		return
	end
	--]]
	if areNamesShown then
		nametags.Disable()
	else
		nametags.Enable()
	end
end

local function updateSavedNametagCVars()
	for k, v in pairs(nameCVars) do
		savedNameCVars[v] = GetCVar(v) or "0"
	end
end
-- Fix that annoying issue with using the interface menu.
InterfaceOptionsFrameOkay:HookScript("OnClick", updateSavedNametagCVars)
ns.AceEvent:RegisterEvent("VARIABLES_LOADED", updateSavedNametagCVars)

--------------------
--#endregion
--------------------

--------------------
--#region RunScript Priv
--------------------

---@param script string
local function runScriptPriv(script)
	if C_Epsilon and C_Epsilon.RunPrivileged then
		C_Epsilon.RunPrivileged(script)
	end
end

--------------------
--#endregion
--------------------

--------------------
--#region TRP3e
--------------------

local TRP3e = {}

-- Sounds
TRP3e.sound = {}
function TRP3e.sound.playLocalSoundID(vars)
	local soundID, channel, distance = unpack(parseStringToArgs(vars), 1, 3)
	if not tonumber(soundID) then
		soundID = TRP3_API.utils.music.convertPathToID(soundID)
	end
	TRP3_API.utils.music.playLocalSoundID(soundID, channel, distance)
end

function TRP3e.sound.stopLocalSoundID(vars)
	local soundID, channel = unpack(parseStringToArgs(vars), 1, 2)
	if not tonumber(soundID) then
		soundID = TRP3_API.utils.music.convertPathToID(soundID)
	end
	TRP3_API.utils.music.stopLocalSoundID(soundID, channel)
end

function TRP3e.sound.playLocalMusic(vars)
	local soundID, distance = unpack(parseStringToArgs(vars), 1, 2)
	if not tonumber(soundID) then
		soundID = TRP3_API.utils.music.convertPathToID(soundID)
	end
	TRP3_API.utils.music.playLocalMusic(soundID, distance)
end

function TRP3e.sound.stopLocalMusic(vars)
	local soundID, distance = unpack(parseStringToArgs(vars), 1, 2)
	if not tonumber(soundID) then
		soundID = TRP3_API.utils.music.convertPathToID(soundID)
	end
	TRP3_API.utils.music.stopLocalMusic(soundID)
end

-- Item Import
TRP3e.items = {}
function TRP3e.items.importItem(code)
	if not code then return end

	TRP3_ToolFrame.list.container.import.content.scroll.text:SetText(code)
	TRP3_ToolFrame.list.container.import.save:Click()
end

function TRP3e.items.addItem(id)
	if not id then return end
	if not TRP3_API.extended.classExists(id) then
		eprint("TRP3e Add Item to Inventory Error: Given class ID (" .. id .. ") does not exist in your TRP3 Extended Database.")
		return false
	end
	return TRP3_API.inventory.addItem(nil, id)
end

if TRP3_API and TRP3_API.extended then
	local TRP3_Globals, TRP3_Events, TRP3_Utils = TRP3_API.globals, TRP3_API.events, TRP3_API.utils;
	local getClass, isContainerByClassID, isUsableByClass = TRP3_API.extended.getClass, TRP3_API.inventory.isContainerByClassID, TRP3_API.inventory.isUsableByClass;

	local function doUseSlot(info, class, container)
		if info.cooldown then
			TRP3_Utils.message.displayMessage(ERR_ITEM_COOLDOWN, TRP3_Utils.message.type.ALERT_MESSAGE);
		else
			local useWorkflow = class.US.SC;
			if class.LI and class.LI.OU then
				useWorkflow = class.LI.OU;
			end
			local retCode = TRP3_API.script.executeClassScript(useWorkflow, class.SC,
				{ object = info, container = container, class = class }, info.id);
			TRP3_Events.fireEvent(TRP3_API.extended.ITEM_USED_EVENT, info.id, retCode);
			return retCode;
		end
	end


	function TRP3e.items.useItemById(id)
		if not id or id == '' then
			eprint("TRP3e Use Item Error: Must supply a valid TRP3 Extended Object ID.")
			return
		end

		-- Simplified Method: Does not require item in inventory
		local class = getClass(id)
		if class and isUsableByClass(class) then
			local dummyInfo = { id = id }
			return doUseSlot(dummyInfo, class, nil)
		end

		-- Old Inventory Scan Method:
		--[[
		-- Scan Inventory for the Item, use it if found
		local inventory = TRP3_API.inventory.getInventory()
		for slot, container in pairs(inventory.content) do
			if container.id == id then
				-- This is what we are looking for in the main inventory, use it (maybe not a container, misnomer really)
				TRP3_API.inventory.useContainerSlotID(inventory, slot)
				return
			end
			if container.content then
				for slotID, object in pairs(container.content) do
					if object.id == id then
						TRP3_API.inventory.useContainerSlotID(container, slotID)
						return
					end
				end
			end
		end
		--]]

		-- No item found, warn:
		eprint(("TRP3e Use Item Error: Could not find TRP3e Object with ID (%s) in your TRP3e Database."):format(id))
	end
end
--------------------
--#endregion
--------------------
--------------------
--#region Mail
--------------------

local mail = {}

function mail.openMailCallback(name, subject, body)
	if not MailFrame:IsShown() then return end

	C_Timer.After(0, function()
		-- delayed so the frame is for sure shown and the click doesn't fail
		if not SendMailFrame:IsShown() then MailFrameTab2:Click() end

		SendMailNameEditBox:SetText(name or "")
		SendMailSubjectEditBox:SetText(subject or "")
		SendMailBodyEditBox:SetText(body or "")

		C_Timer.After(0, function()
			-- delayed so MailFrameTab2:Click finishes
			if subject then
				SendMailBodyEditBox:SetFocus()
			elseif name then
				SendMailSubjectEditBox:SetFocus()
			end
		end)
	end)
end

function mail.sendMailCallback(name, subject, body)
	SendMail(name, subject, body)
	CloseMail();
end

--------------------
--#region Custom Sound
--------------------

local soundHandles = {}
local soundHistory = {}
local eventFrame = keybindFrame -- reusing it because we can, it doesn't use events

local sounds = {}

function sounds.getHandles()
	return soundHandles
end

function sounds.getHistory()
	return soundHistory
end

function sounds.logSound(soundItem)
	tinsert(soundHandles, soundItem)
	tinsert(soundHistory, soundItem)
	ns.UI.Options.notifyChange()
end

function sounds.isHandlePlaying(handle)
	for i = 1, #soundHandles do
		local handler = soundHandles[i]
		if handler.soundHandle == handle then
			return true
		end
	end
end

function sounds.isSoundIDPlaying(soundID)
	for i = 1, #soundHandles do
		local handler = soundHandles[i]
		if handler.soundID == soundID then
			return true
		end
	end
end

function sounds.isSoundFilePlaying(fileID)
	for i = 1, #soundHandles do
		local handler = soundHandles[i]
		if handler.soundFile == tostring(fileID) then
			return true
		end
	end
end

function sounds.clearHandle(handleIndex, soundID, soundHandle)
	if handleIndex then
		tremove(soundHandles, handleIndex)
	elseif soundID then
		for k, v in ipairs(soundHandles) do
			if v.soundID == soundID then
				tremove(soundHandles, k)
				break -- only remove the first one
			end
		end
	elseif soundHandle then
		for k, v in ipairs(soundHandles) do
			if v.soundHandle == soundHandle then
				tremove(soundHandles, k)
				break
			end
		end
	end
	ns.UI.Options.notifyChange()
end

function sounds.clearFinishedHandles()
	for i = #soundHandles, 1, -1 do
		if soundHandles[i].stopped then
			tremove(soundHandles, i)
		end
	end
end

local function soundFinishedCallback(self, event, soundHandle)
	if event ~= "SOUNDKIT_FINISHED" then return end -- just incase
	soundHandle = tonumber(soundHandle)          -- to be safe
	if not soundHandle then return end
	sounds.clearHandle(nil, nil, soundHandle)
end
eventFrame:RegisterEvent("SOUNDKIT_FINISHED")
eventFrame:SetScript("OnEvent", soundFinishedCallback) -- Keeps our table clean if the sound finished

---@param index number
---@param fadeout? number
function sounds.stopSoundIndex(index, fadeout)
	assert(index, "Index cannot be nil")
	local soundInfo = soundHandles[index]
	StopSound(soundInfo.soundHandle, fadeout)
	sounds.clearHandle(index)
end

function sounds.stopSoundHandle(handle, fadeout)
	handle = tonumber(handle)
	assert(handle, "Handle cannot be nil")
	for k = #soundHandles, 1, -1 do
		local v = soundHandles[k]
		if v.soundHandle == handle then
			sounds.stopSoundIndex(k, fadeout)
		end
	end
end

---@param soundID number
---@param fadeout? number
function sounds.stopSoundID(soundID, fadeout)
	assert(soundID, "Sound ID cannot be nil")
	for k = #soundHandles, 1, -1 do
		local v = soundHandles[k]
		if v.soundID == soundID then
			sounds.stopSoundIndex(k, fadeout)
		end
	end
end

---@param file fileID|string
---@param fadeout? number
function sounds.stopSoundFile(file, fadeout)
	file = file and tostring(file) or nil
	assert(file, "Sound File cannot be nil")
	for k = #soundHandles, 1, -1 do
		local v = soundHandles[k]
		if v.soundFile == file then
			sounds.stopSoundIndex(k, fadeout)
		end
	end
end

---@param channel string
---@param fadeout? number
function sounds.stopSoundChannel(channel, fadeout)
	assert(channel, "Channel cannot be nil")
	for k = #soundHandles, 1, -1 do
		local v = soundHandles[k]
		if string.lower(v.channel) == string.lower(channel) then
			sounds.stopSoundIndex(k, fadeout)
		end
	end
end

---@param fadeout? number
function sounds.stopAll(fadeout)
	for k = #soundHandles, 1, -1 do
		--StopSound(v.soundHandle, fadeout)
		sounds.stopSoundIndex(k, fadeout)
	end
end

---@param id number
---@param channel string? defaults to SFX if not given
function sounds.playSoundID(id, channel)
	assert(id, "Sound ID cannot be nil")
	local willPlay, soundHandle = PlaySound(id, channel, nil, true)
	if willPlay and soundHandle then
		local soundItem = { soundHandle = soundHandle, soundID = id, channel = (channel or "SFX") }
		sounds.logSound(soundItem)
	end
end

---@param file string|fileID
---@param channel string? defaults to SFX if not given
function sounds.playSoundFile(file, channel)
	file = file and tostring(file) or nil -- always treat them as string no matter what
	assert(file, "File ID cannot be nil")
	local willPlay, soundHandle = PlaySoundFile(file, channel)
	if willPlay and soundHandle then
		local soundItem = { soundHandle = soundHandle, soundFile = file, channel = (channel or "SFX") }
		sounds.logSound(soundItem)
	end
end

-- // Music
local lastMusicID

function sounds.getLastMusicID()
	return lastMusicID
end

function sounds.playMusic(id)
	id = tonumber(id)
	if not id then return false end -- invalid ID given / not number, exit & return false to let'em know.

	PlayMusic(id)
	lastMusicID = id
	return true
end

function sounds.stopMusic(id)
	id = tonumber(id)
	if not id then
		StopMusic()
		lastMusicID = nil
		return true
	end -- No ID given, stop all music

	-- ID given, check if it's the last one and only stop if so:
	if id == lastMusicID then
		StopMusic()
		lastMusicID = nil
		return true -- was & stopped
	else
		return false -- was not & nothing done
	end
end

--------------------
--#endregion
--------------------

--------------------
--#region Items
--------------------
local items = {}

function items.addRemoveItemWithNegativeCheck(vars)
	-- If vars ends with a negative number (e.g. "12345 -1"), remove item verbose, else add item
	local trimmed = strtrim(vars)
	local negativeNumber = trimmed:match("%s%-[%d]+$") -- matches space, negative sign, digits at end
	if negativeNumber then
		-- Remove item(s)
		cmd("additem " .. trimmed)
	else
		-- Add item(s)
		sendAddonCmd("additem " .. trimmed)
	end
end

--------------------
--#endregion
--------------------

--------------------
--#region Generic Teleport Visual System
--------------------
local tele = {}

local function CallbackClosure(func, ...)
	if type(func) ~= "function" then error("newCallback arg #1 must be a function") end
	local args = { ... }
	local numArgs = select("#", ...)
	return function() func(unpack(args, numArgs)) end
end

local function cast(id, trig, self, revert)
	if trig == nil then trig = true end
	if self == nil then self = true end
	cmd(("cast %s %s %s"):format(id, (trig and "triggered" or ""), (self and "self" or "")))

	if revert then
		C_Timer.After(tonumber(revert) or 0.25, CallbackClosure(cmd, "unaura " .. id .. " self"))
	end
end

---@class CastSpellData
---@field [1] number SpellID
---@field [2] boolean? triggered
---@field [3] boolean? self
---@field [4] boolean|number? revert (true, false, or a number to specify the revert time)

---@alias TeleVisual CastSpellData[]

---@type TeleVisual[]
local teleVisuals = {
	{ -- [1] Classic
		delay = 0.8,
		{ 41232 },
	},
	{ -- [2] Bastion
		delay = 2,
		{ 335419, nil, true, 3 },
	},
	{ -- [3] Progenitor
		{ 367049 },
		{ 364475, false, false },
	},
	{ -- [4] Arcane
		-- 361504,361505,355673,367731
		{ 361504 },
		{ 361505 },
	},
	{ -- [5] Holy
		{ 253303, nil, nil, true },
		--317142
	},
	{ -- [6] Epsilon Sparkle FX
		delay = 7.01,
		{ 272187, nil, true, 3 },
		{ 274920, nil, true, 6 - 0.5, delay = 0.5 },
		{ 237075, nil, true, 7 - 3,   delay = 3 },
	},
	{ -- [7] Fade to Black Screen FX
		{ 1000112, nil, true, 1 },
	},
	{ -- [8] Tele Full Screen FX
		delay = 2,
		{ 344538, nil, true, 3 },
	},
	{ -- [9] Zereth Mortis Holy Screen FX
		delay = 1.5,
		{ 364782, nil, true, 3 }
	},
	{ -- [10] Chromie Time FX
		delay = 1.5,
		{ 340741, nil, true, 0.5 }
	},
	{ -- [11] Blood Screen FX
		delay = 1.5,
		{ 344545, nil, true, 2 },
	},
}

function tele.port(comm, visualID)
	visualID = tonumber(visualID)
	if not visualID then visualID = 1 end

	for _, v in ipairs(teleVisuals[visualID]) do
		if v.delay then
			C_Timer.After(v.delay, function() cast(v[1], v[2], v[3], v[4]) end)
		else
			cast(v[1], v[2], v[3], v[4])
		end
	end

	local delay = teleVisuals[visualID].delay or 1

	C_Timer.After(delay, CallbackClosure(cmd, comm))
end

--------------------
--#endregion
--------------------

ARC._DEBUG.DATA_SCRIPTS = {
	keybindings = keybindFrame.bindings
}

---@class Actions_Data_Scripts
ns.Actions.Data_Scripts = {
	camera = camera,
	nametags = nametags,
	keybind = keybindFrame,
	ui = ui,
	mail = mail,
	sounds = sounds,
	TRP3e_sound = TRP3e.sound,
	TRP3e_items = TRP3e.items,

	items = items,
	tele = tele,

	runScriptPriv = runScriptPriv
}
