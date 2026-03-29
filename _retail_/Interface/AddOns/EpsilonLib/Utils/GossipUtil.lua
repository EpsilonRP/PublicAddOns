local EpsilonLib, EpsiLib = ...;

--[=====[

EXAMPLE DOCS:

--- ## Definition & Example for Button Hooks (AKA: Options)

---@param predicate fun(text:string, optionInfo:GossipOptionUIInfo):boolean|nil Predicate for if this hook even applies here. True = Callback & Filter apply. False = No Callback / Filter, and Hide this Option. Nil = No modifications.
---@param callback? fun(self:frame, button:string, down:boolean, originalText:string, optionInfo:GossipOptionUIInfo) OnClick handler callback. Passed standard OnClick, but also the originalText as the last arg.
---@param filter fun(newText:string, originalText?:string):newText:string Text Filter Function. Takes in newText, originalText?, and returns newText. You should only use newText to for string modifications, don't use originalText as you'll replace other hooks data, only use it for reference if needed!
---@param options table Table of Optional Modifiers. Currently only supports blockOriginalOnClick to block the SelectOption / page change.
-- Usage: EpsilonLib.Utils.Gossip:RegisterButtonHook(predicate, callback, filter, options)

	local option_predicate = function(text, button)
		return text and (text == "Example") -- best way to do this
	end

	local option_callback = function(self, button, down, originalText)
		-- You do not need to parse originalText for `if text == "Example"` again here, as it will not be called if the predicate fails.
		print("The world does not reply.. Because this is an example.")
	end

	local option_filter = function(newText, originalText)
		newText = newText:gsub("Example", "Hello World!")
		return newText
	end

	EpsilonLib.Utils.Gossip:RegisterButtonHook(option_predicate, option_callback, option_filter)

---@param predicate fun(text:string, isReload:boolean) Predicate for if this hook even applies here
---@param callback? fun(originalText:string, isReload:boolean) Optional callback to do something on specific text.
---@param filter fun(newText:string, originalText?:string):newText:string Text Filter Function. Takes in originalText, currentText, and returns newText
-- Usage: EpsilonLib.Utils.Gossip:RegisterGreetingHook(predicate, callback, filter)

	local greeting_predicate = function(text, isReload)
	-- // WARNING: Using the isReload in a predicate also blocks the FILTER; so if you need the filter to run, handle isReload in the callback instead.
		if isReload then return false
		if text == "Example" then return true end
		return false
	end

	local greeting_callback = function(originalText, isReload)
		-- You do not need to parse originalText for `if text == "Example"` again here, as it will not be called if the predicate fails.
		if isReload then return end
		print("The world does not reply.. Because this is an example.")
	end

	local greeting_filter = function(newText, originalText)
		newText = newText:gsub("Example", "Hello World!")
		return newText
	end

	EpsilonLib.Utils.Gossip:RegisterGreetingHook(greeting_predicate, greeting_callback, greeting_filter)

--]=====]

local _gossip = {}
local _buttonHooks = {}
local _greetingHooks = {}
local _customButtons = {}

local isGossipLoaded
local lastGossipText
local lastGossipNPC
local lastGossipName
local lastGossipDupeText
local lastGossipNumOptions
local lastGossipOptions

local curGossipData = {
	original = {
		text = '',
		options = {}
	},
	modified = {
		text = '',
		options = {}
	}
}

-- Original Functions
local _CloseGossip = CloseGossip or C_GossipInfo.CloseGossip;
local _GetNumGossipOptions = GetNumGossipOptions or C_GossipInfo.GetNumOptions;
local _SelectGossipOption = SelectGossipOption or C_GossipInfo.SelectOption;
local _GetGossipText = GetGossipText or C_GossipInfo.GetText;
local _GetGossipOptions = GetGossipOptions or C_GossipInfo.GetOptions;

if not _GetNumGossipOptions then
	-- DF+ support for simplicity
	_GetNumGossipOptions = function()
		return #_GetGossipOptions()
	end
end

local tinsert = tinsert
local tremove = tremove
local tWipe = table.wipe

local function overrideBaseGossipFunc(name, c_name, func)
	if _G[name] then _G[name] = func end
	if C_GossipInfo and C_GossipInfo[c_name] then C_GossipInfo[c_name] = func end
end

---@class HookOptions
---@field blockOriginalOnClick boolean

-------------------------------------------
--#region Greeting Gossip System
-------------------------------------------

---Register a new hook
---@param predicate fun(text:string, isReload:boolean) Predicate for if this hook even applies here
---@param callback? fun(originalText:string, isReload:boolean) Optional callback to do something on specific text.
---@param filter fun(newText:string, originalText?:string):newText:string Text Filter Function. Takes in originalText, currentText, and returns newText
---@return table greetingHookData Table containing the data for the hook. Modifiable live. Used in Remove.
function _gossip:RegisterGreetingHook(predicate, callback, filter)
	if type(predicate) ~= "function" then error("RegisterGreetingHook Usage: Predicate must be a function: predicate(text, isReload) -> boolean.") end
	if callback and (type(callback) ~= "function") then error("RegisterGreetingHook Usage: callback must be nil, false, or a function: callback(originalText, isReload).") end

	local data = {
		predicate = predicate,
		filter = filter,
		callback = callback,
	}
	tinsert(_greetingHooks, data)
	return data
end

function _gossip:RemoveGreetingHook(hookData)
	tDeleteItem(_greetingHooks, hookData)
end

local function areTablesFunctionallyEquivalent(a, b, deep, seen)
	-- If they are literally the same table, they are equivalent
	if a == b then return true end

	-- Must both be tables
	if type(a) ~= "table" or type(b) ~= "table" then
		return false
	end

	-- For deep mode: avoid circular-reference loops
	seen = seen or {}
	if deep then
		if seen[a] and seen[a] == b then
			return true
		end
		seen[a] = b
	end

	-- Compare all keys in A
	for key, valA in pairs(a) do
		local valB = b[key]
		if valB == nil then
			return false
		end

		if deep and type(valA) == "table" and type(valB) == "table" then
			if not areTablesFunctionallyEquivalent(valA, valB, true, seen) then
				return false
			end
		elseif valA ~= valB then
			return false
		end
	end

	-- Ensure B has no extra keys
	for key in pairs(b) do
		if a[key] == nil then
			return false
		end
	end

	return true
end


local function dupeCheck(options)
	--print("dupeCheck", UnitGUID('npc'), UnitGUID('target'), UnitName('npc'), UnitName('target'))

	if not lastGossipDupeText then return false end                                          -- no last text, exit (unreliable or we never had a text before)
	if lastGossipDupeText:find("Gossip forge - no text found") then lastGossipDupeText = '' end -- debug message for no text - just remove it.

	if (lastGossipDupeText == '' and _GetNumGossipOptions() == 0) then return false end      -- Can't detect no text / no options; unreliable.
	if lastGossipDupeText ~= _GetGossipText() then return false end                          -- Different text, not a dupe
	if UnitGUID('target') == lastGossipNPC then return false end                             -- Same NPC GUID, not a dupe
	if UnitName('target') == lastGossipName then return false end                            -- Same NPC name, probably not a dupe, just double spawned NPC

	if _GetNumGossipOptions() ~= lastGossipNumOptions then                                   -- Different number of options, not a dupe
		return false
	else                                                                                     -- same number of options.. check if they are the same
		if not areTablesFunctionallyEquivalent(options, lastGossipOptions, true) then        -- not the same, exit
			return false
		end
	end

	-- we made it past all checks. I guess it's probably a dupe?
	return true
end

local function badGossipCheck()
	if not UnitGUID("npc") then return true end
end

local grey = CreateColor(0.8, 0.8, 0.8)
function GetGossipText(original)
	local originalText = _GetGossipText()
	if original then return originalText end

	local isReload = (originalText == lastGossipText)
	local newText = originalText
	local _callbacks = {}

	if dupeCheck() then
		_CloseGossip()

		local msg = "Oops! Gossip got confused and tried showing the last NPC's gossip instead of the new one. Give it another try!"
		local subMsg = grey:WrapTextInColorCode("(This isn't an addon error - it's a bug safeguard. Only report it if you're seeing it when you shouldn't.)")

		EpsiLib.Utils.GenericDialogs.CustomConfirmation({
			text = msg,
			subText = subMsg,
			acceptText = "Okay",
			cancelText = false,
			showAlert = true,
		})

		lastGossipDupeText = nil -- Force reset, incase it was a false positive and they try again
		lastGossipNPC = nil
		lastGossipName = nil
		return
	elseif badGossipCheck() then
		_CloseGossip()
		return
	end

	lastGossipText = originalText
	lastGossipDupeText = originalText
	lastGossipNumOptions = _GetNumGossipOptions()
	lastGossipOptions = _GetGossipOptions()
	lastGossipNPC = UnitGUID('target')
	lastGossipName = UnitName('target')

	for j = 1, #_greetingHooks do
		local data = _greetingHooks[j]
		local pred = data.predicate(originalText)
		if pred then
			tinsert(_callbacks, data.callback)

			if data.filter then
				newText = data.filter(newText, originalText)
			end
		end
	end
	for i = 1, #_callbacks do
		_callbacks[i](originalText, isReload)
	end

	curGossipData.original.text = originalText
	curGossipData.modified.text = newText
	return newText
end

overrideBaseGossipFunc("GetGossipText", "GetText", GetGossipText)



--[[ -- Example / Testing Gossip Greeting Hook Set-up
_gossip:RegisterGreetingHook(
	function(text, isReload) -- Predicate. Must return true to effect this greeting text at all
		return text:find("NPC4")
	end,
	function(text, isReload) -- Callback. This is what is ran when the predicate is true. Does not implicitly effect anything, but allows you to run additional code.
		if isReload then
			print(text, "reload")
		else
			print(text, "found")
		end
	end,
	function(newText, originalText) -- Filter. This is how you can modify the gossip's greeting text. If given, must atleast return some text, otherwise you will cause errors (blizzard expects at least "" empty string if the gossip is blank)
		return newText:gsub("NPC4", "Testing!")
	end
)
--]]

-------------------------------------------
--#region Title Button Gossip System
-------------------------------------------

---Register a new hook
---@param predicate fun(text:string, optionInfo:GossipOptionUIInfo):boolean|nil Predicate for if this hook even applies here. True = Callback & Filter apply. False = No Callback / Filter, and Hide this Option. Nil = No modifications.
---@param callback? fun(self:frame, button:string, down:boolean, originalText:string, optionInfo:GossipOptionUIInfo) OnClick handler callback. Passed standard OnClick, but also the originalText as the last arg.
---@param filter fun(newText:string, originalText?:string):newText:string Text Filter Function. Takes in newText, originalText?, and returns newText. You should only use newText to for string modifications, don't use originalText as you'll replace other hooks data, only use it for reference if needed!
---@param options? table Table of Optional Modifiers. Currently only supports blockOriginalOnClick to block the SelectOption / page change.
---@return table hookData Table containing this hooks data. Modifiable live. Used as reference for Remove.
function _gossip:RegisterButtonHook(predicate, callback, filter, options)
	if type(predicate) ~= "function" then error("RegisterButtonHook Usage: Predicate must be a function: predicate(text) -> boolean.") end
	if callback and (type(callback) ~= "function") then error("RegisterButtonHook Usage: callback must be nil, false, or a function: callback(self, button, down, originalText).") end

	local data = {
		predicate = predicate,
		filter = filter,
		callback = callback,
		options = options,
	}
	tinsert(_buttonHooks, data)
	return data
end

function _gossip:RemoveButtonHook(hookData)
	tDeleteItem(_buttonHooks, hookData)
end

function _gossip:RegisterCustomButton(predicate, type, text, callback)
	local data = {
		predicate = predicate,
		type = type,
		text = text,
		callback = callback
	}
	tinsert(_customButtons, data)
	return data
end

function _gossip:RemoveCustomButton(hookData)
	tDeleteItem(_customButtons, hookData)
end

local function GetGossipOptions(onlyPredCheck, original)
	local options = _GetGossipOptions()
	if original then return options end

	local newOptions = {}

	if dupeCheck(options) then return {} end -- dupeCheck calls a cancel in the greeting anyways

	for index, option in ipairs(options) do
		local originalText = option.name
		local newText = originalText
		local _callbacks = {}
		local blockOriginalOnClick
		local hideThisOption

		-- Create newOption early, so we can pass originalID also
		local newOption = CopyTable(option)
		newOption.originalText = originalText
		newOption.name = newText
		--newOption.callbacks = _callbacks
		--newOption.blockOriginalOnClick = blockOriginalOnClick
		newOption.originalID = index
		newOption.originalData = option
		newOption.originalOptions = options

		for j = 1, #_buttonHooks do
			local data = _buttonHooks[j]
			local pred = data.predicate(originalText, newOption)
			if pred then
				tinsert(_callbacks, data.callback)

				if data.filter and not onlyPredCheck then
					newText = data.filter(newText, originalText, newOption)
					newOption.name = newText
				end

				if data.options then
					if data.options.blockOriginalOnClick then
						blockOriginalOnClick = true
					end
				end
			elseif pred == false then
				hideThisOption = true
			end
		end

		-- set again for any changes made in the loop, and also to embed the new callbacks and blockOriginalOnClick if they were set
		newOption.originalText = originalText
		newOption.name = newText
		newOption.callbacks = _callbacks
		newOption.blockOriginalOnClick = blockOriginalOnClick
		newOption.originalID = index
		newOption.originalData = option
		newOption.originalOptions = options

		if not hideThisOption then
			tinsert(newOptions, newOption)
		end
	end

	for i = 1, #_customButtons do
		local data = _customButtons[i]
		local pred = data.predicate(newOptions)
		if pred then
			local newButton = {
				type = data.type,
				name = data.text,
				callbacks = { data.callback },
				blockOriginalOnClick = true,
			}
			tinsert(newOptions, newButton)
		end
	end

	curGossipData.original.options = options
	curGossipData.modified.options = newOptions

	return newOptions
end
overrideBaseGossipFunc("GetGossipOptions", "GetOptions", function(original) return GetGossipOptions(nil, original) end)

local function GetNumGossipOptions(original)
	if original then return _GetNumGossipOptions() end
	return #GetGossipOptions(true)
end
overrideBaseGossipFunc("GetNumGossipOptions", "GetNumOptions", GetNumGossipOptions)


local function runTitleButtonCallbacksByIndex(index, self, button, down)
	local customData = curGossipData.modified.options[index]
	if not customData then return print("Error: Could not find hook data for index", index) end
	local _callbacks = customData.callbacks
	if #_callbacks > 0 then
		for k = 1, #_callbacks do
			_callbacks[k](self, button, down, customData.originalText, customData)
		end
	end
end

local function SelectGossipOption(id, text, confirmed, original)
	if original then
		_SelectGossipOption(id, text, confirmed);
	end
	runTitleButtonCallbacksByIndex(id, _gossip:GetTitleButton(id), GetMouseButtonClicked())

	if not curGossipData.modified.options[id].blockOriginalOnClick then
		local realID = curGossipData.modified.options[id].originalID
		_SelectGossipOption(realID, text, confirmed);
	end
end
overrideBaseGossipFunc("SelectGossipOption", "SelectOption", SelectGossipOption)

--[[
local _orig_GossipTitleButton_OnClick = GossipTitleButton_OnClick
local function _GossipTitleButton_OnClick(self, button, down)
	local customData = self.customData
	if customData then
		local _callbacks = customData.callbacks
		if #_callbacks > 0 then
			for k = 1, #_callbacks do
				_callbacks[k](self, button, down, customData.originalText)
			end
		end
	end
	if not customData.blockOriginalOnClick then
		_orig_GossipTitleButton_OnClick(self, button, down)
	end
end
GossipTitleButton_OnClick = _GossipTitleButton_OnClick
--]]

-- Stock Blizz Transferred // Un-needed, but really helpful for debugging, so keeping it for now.
local function GossipFrame_AcquireTitleButton()
	local button = GossipFrame.titleButtonPool:Acquire();
	table.insert(GossipFrame.buttons, button);
	button:Show();
	return button;
end

local function GossipFrame_CancelTitleSeparator()
	GossipFrame.insertSeparator = false;
end

local function GossipFrame_AnchorTitleButton(button)
	local buttonCount = GossipFrame_GetTitleButtonCount();
	if buttonCount > 1 then
		button:SetPoint("TOPLEFT", GossipFrame_GetTitleButton(buttonCount - 1), "BOTTOMLEFT", 0, (GossipFrame.insertSeparator and -19 or 0) - 3);
	else
		button:SetPoint("TOPLEFT", GossipGreetingText, "BOTTOMLEFT", -10, -20);
	end
	GossipFrame_CancelTitleSeparator();
end

-- Modified to embed customData
function GossipFrameOptionsUpdate()
	local gossipOptions = C_GossipInfo.GetOptions();
	local titleIndex = 1;
	for titleIndex, optionInfo in ipairs(gossipOptions) do
		local button = GossipFrame_AcquireTitleButton();
		button:SetOption(optionInfo.name, optionInfo.type, optionInfo.spellID);

		button.customData = optionInfo -- embed the optionInfo, which includes any custom modification embedded

		button:SetID(titleIndex);
		GossipFrame_AnchorTitleButton(button);
	end
end

--@region Utility Functions

---@param index integer
---@return Button
function _gossip:GetTitleButton(index)
	local titleButton

	if ImmersionFrame then
		local immersionButton = _G["ImmersionTitleButton" .. index]
		if immersionButton then
			titleButton = immersionButton
		end
	else
		titleButton = GossipFrame.buttons[index]
	end

	return titleButton
end

function _gossip:GetCurrentGossipInfo()
	return curGossipData
end

---@param text string
function _gossip:SetGreetingText(text)
	if ImmersionFrame and ImmersionFrame.TalkBox and ImmersionFrame.TalkBox.TextFrame then
		ImmersionFrame.TalkBox.TextFrame.Text.storedText = text
		ImmersionFrame.TalkBox.TextFrame.Text:RepeatTexts() -- this triggers Immersion to restart the text, pulling from its storedText, which we already cleaned.
	else
		GossipGreetingText:SetText(text)
	end
end

--#endregion


local events = {
	GOSSIP_SHOW = function()
		isGossipLoaded = true
	end,
	GOSSIP_CLOSED = function()
		lastGossipText = nil
		isGossipLoaded = false
	end,
}

for k, v in pairs(events) do
	EpsiLib.EventManager:Register(k, v)
end

EpsiLib.Utils.Gossip = _gossip


-- FORCE GOSSIP OPTIONS TO ALWAYS SHOW:
local function newForceGossip()
	return true
end
overrideBaseGossipFunc("ForceGossip", "ForceGossip", newForceGossip)



-- ============================================================
--  GossipConditions Core  (Generic Basic Hook System for Dynamic Gossip Systems)
-- ============================================================

_gossip.Conditions = {

	_registry = {},

	-- -- Built-in condition checkers -----------------------
	_checkers = {

		-- Accepts phaseVar:value for exact match, or just phaseVar to check if truthy
		phaseVar = function(var)
			local var, val = strsplit(":", var)
			if not val or val == "" then
				local pVar = ARC.PHASE.GET(var)
				return pVar == true or pVar == "true"
			end
			return ARC.PHASE.GET(var) == val
		end,

		-- Accepts comma separates list of names
		name = function(val)
			local charName = UnitName("player"):lower()

			local names = { strsplit(",", val) }
			local nameKeys = {}
			for _, name in ipairs(names) do
				local key = strtrim(name:lower()):gsub("%s+", "")
				nameKeys[key] = true
			end

			return charName and nameKeys[charName]
		end,


		-- Accepts "Horde" or "Alliance" (case-insensitive), since there's no other player factions to worry about
		faction = function(val)
			local f = UnitFactionGroup("player")
			return f and f:lower() == val:lower()
		end,

		-- Accepts comma separated list of races
		race = function(val)
			local _, raceId = UnitRace("player")

			local races = { strsplit(",", val) }
			local raceKeys = {}
			for _, race in ipairs(races) do
				local key = strtrim(race:lower()):gsub("%s+", "")
				raceKeys[key] = true
			end

			return raceId and raceKeys[raceId:lower()]
		end,

		-- Accepts comma separated list of classes
		class = function(val)
			local _, classId = UnitClass("player")

			local classes = { strsplit(",", val) }
			local classKeys = {}
			for _, class in ipairs(classes) do
				local key = strtrim(class:lower()):gsub("%s+", "")
				classKeys[key] = true
			end

			return classId and classKeys[classId:lower()]
		end,

		-- Accepts "HH:MM-HH:MM" 24-hour format; only supports game time, not real time
		time = function(val)
			local timeH, timeM = GetGameTime()
			local startH, startM, endH, endM = val:match("(%d%d?):(%d%d)-(%d%d?):(%d%d)")
			startH, startM, endH, endM = tonumber(startH), tonumber(startM), tonumber(endH), tonumber(endM)
			if not startH or not startM or not endH or not endM then return false end
			local startTotal = startH * 60 + startM
			local endTotal = endH * 60 + endM
			local currentTotal = timeH * 60 + timeM
			if startTotal <= endTotal then -- if the range doesn't cross midnight, calculate normally
				return currentTotal >= startTotal and currentTotal < endTotal
			else                  -- if the range crosses midnight, calculate on each side of midnight and return true if either is satisfied
				return currentTotal >= startTotal or currentTotal < endTotal
			end
		end,

		-- Accepts a function that returns true or false; use for any custom logic you want
		custom = function(val)
			if type(val) == "function" then
				local ok, result = pcall(val)
				return ok and result == true
			end
			return false
		end,
	},

	-- Register a new Gossip Override for NPC ID using a variants table.
	-- Variants table is an array of overrides in priority order, with sub-tables at keys "conditions", "pages", and "options". See Examples.
	Register = function(self, npcId, variants)
		self._registry[npcId] = variants
	end,

	-- Add a new checker, aka: built-in-condition
	-- Name = Key used in a variant's condition table
	-- func = callback for the checker, should return true/false
	AddChecker = function(self, name, func)
		self._checkers[name] = func
	end,

	-- internal
	_resolve = function(self, npcId)
		local variants = self._registry[npcId]
		if not variants then return nil end
		for _, variant in ipairs(variants) do
			if self:_matchesAll(variant.conditions) then
				return variant
			end
		end
		return nil
	end,

	-- internal
	_matchesAll = function(self, conditions)
		if not conditions or next(conditions) == nil then
			return true
		end
		for condType, condVal in pairs(conditions) do
			local checker = self._checkers[condType]
			if not checker then return false end
			if not checker(condVal) then return false end
		end
		return true
	end,
}

-- -- Helpers -----------------------------------------------

local function getCurrentNpcId()
	local guid = UnitGUID("npc")
	if not guid then return nil end
	local unitType, _, _, _, _, id = strsplit("-", guid)
	if unitType ~= "Creature" then return nil end
	return id
end

-- -- Per-open state ----------------------------------------

local currentVariant = nil

-- -- Greeting hook -----------------------------------------

local function findPageReplacement(text)
	if not currentVariant or not currentVariant.pages then return nil end
	for pattern, replacement in pairs(currentVariant.pages) do
		if text:find(pattern) then
			return replacement
		end
	end
	return nil
end

local greeting_predicate = function(text, isReload)
	if isReload then return false end

	-- Resolve the variant here, before any other hook logic runs.
	-- This replaces the GOSSIP_SHOW listener entirely, guaranteeing
	-- currentVariant is populated before the filter and button hooks fire.
	currentVariant = nil
	local npcId = getCurrentNpcId()
	if npcId then
		currentVariant = _gossip.Conditions:_resolve(npcId)
	end

	if not currentVariant then return false end
	return findPageReplacement(text) ~= nil
end

local greeting_callback = function(originalText, isReload)
	if isReload then return end
end

local greeting_filter = function(newText, originalText)
	local replacement = findPageReplacement(originalText)
	if replacement then return replacement end
	return newText
end

_gossip.Conditions._GreetingHook = _gossip:RegisterGreetingHook(
	greeting_predicate,
	greeting_callback,
	greeting_filter
)

-- -- Button hook -------------------------------------------
-- currentVariant is guaranteed set by the time any button hook
-- fires, since the greeting predicate always runs first on open.

local button_predicate = function(text, optionInfo)
	if not currentVariant then return nil end

	local entry = currentVariant.options
		and currentVariant.options[optionInfo.originalID]

	if entry == nil then return nil end
	if entry == false then return false end
	return true
end

local button_callback = function(self, button, down, originalText, optionInfo)
	if not currentVariant then return end
	local entry = currentVariant.options
		and currentVariant.options[optionInfo.originalID]

	if type(entry) == "table" and type(entry.callback) == "function" then
		local ok, err = pcall(entry.callback, self, button, down, originalText, optionInfo)
		if not ok then
			print("|cffff4444GossipConditions button callback error:|r " .. tostring(err))
		end
	end
end

local button_filter = function(newText, originalText, optionInfo)
	if not currentVariant then return nil end
	local entry = currentVariant.options
		and currentVariant.options[optionInfo.originalID]

	-- assume our entry is normal handler (nil|false|string) and then adjust for table if needed
	local text = currentVariant.options[optionInfo.originalID]
	if type(entry) == "table" then
		text = entry.text
	end

	if type(text) == "string" then return text end
	return newText
end

_gossip.Conditions._ButtonHook = _gossip:RegisterButtonHook(
	button_predicate,
	button_callback,
	button_filter
)
