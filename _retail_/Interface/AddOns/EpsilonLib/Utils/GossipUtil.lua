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

	EpsilonLib.Utils.Gossip:RegisterButtonHook(option_predicate, option_callback, option_filter)

--]=====]

local _gossip = {}
local _buttonHooks = {}
local _greetingHooks = {}
local _customButtons = {}

local isGossipLoaded
local lastGossipText
local lastGossipNPC
local lastGossipDupeText

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

local function dupeCheck()
	if UnitGUID('npc') == lastGossipNPC then return false end   -- Same NPC, not a dupe
	if lastGossipDupeText == '' then return false end           -- Can't detect no text; unreliable.
	if lastGossipDupeText == _GetGossipText() then return true end -- Different NPC, same text. Dupe.
end

function GetGossipText()
	local originalText = _GetGossipText()
	local isReload = (originalText == lastGossipText)
	local newText = originalText
	local _callbacks = {}

	if dupeCheck() then
		_CloseGossip()
		message("EpsiLib: GossipUtil caught unhandled Gossip Target Swap. Re-try this Gossip.")
		lastGossipDupeText = nil -- Force reset, incase it was a false positive and they try again
		return
	end

	lastGossipText = originalText
	lastGossipDupeText = originalText
	lastGossipNPC = UnitGUID('npc')

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
---@param options table Table of Optional Modifiers. Currently only supports blockOriginalOnClick to block the SelectOption / page change.
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

local function GetGossipOptions(onlyPredCheck)
	local options = _GetGossipOptions()
	local newOptions = {}

	if dupeCheck() then return {} end -- dupeCheck calls a cancel in the greeting anyways

	for index, option in ipairs(options) do
		local originalText = option.name
		local newText = originalText
		local _callbacks = {}
		local blockOriginalOnClick
		local hideThisOption

		for j = 1, #_buttonHooks do
			local data = _buttonHooks[j]
			local pred = data.predicate(originalText, option)
			if pred then
				tinsert(_callbacks, data.callback)

				if data.filter and not onlyPredCheck then
					newText = data.filter(newText, originalText, option)
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

		local newOption = CopyTable(option)
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
overrideBaseGossipFunc("GetGossipOptions", "GetOptions", function() return GetGossipOptions() end)

local function GetNumGossipOptions(real)
	if real then return _GetNumGossipOptions() end
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

local function SelectGossipOption(id, text, confirmed)
	runTitleButtonCallbacksByIndex(id, _gossip:GetTitleButton(id), GetMouseButtonClicked())

	if not curGossipData.modified.options[id].blockOriginalOnClick then
		local realID = curGossipData.modified.options[id].originalID
		_SelectGossipOption(realID);
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
