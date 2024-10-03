local EpsilonLib, EpsiLib = ...;

--[=====[

EXAMPLE DOCS:

--- ## Definition & Example for Button Hooks (AKA: Options)

---@param predicate fun(text:string, titleButton:button):boolean Predicate for if this hook even applies here
---@param callback? fun(self:frame, button:string, down:boolean, originalText:string) OnClick handler callback. Passed standard OnClick, but also the originalText as the last arg.
---@param filter fun(newText:string, originalText?:string):newText:string Text Filter Function. Takes in newText, originalText?, and returns newText. You should only use newText to for string modifications, don't use originalText as you'll replace other hooks data, only use it for reference if needed!
---@param options table
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

local isGossipLoaded

local lastGossipText
local currGossipText

-- Original Functions
local CloseGossip = CloseGossip or C_GossipInfo.CloseGossip;
local GetNumGossipOptions = GetNumGossipOptions or C_GossipInfo.GetNumOptions;
local SelectGossipOption = SelectGossipOption or C_GossipInfo.SelectOption;
local GetGossipText = GetGossipText or C_GossipInfo.GetText;
local GetGossipOptions = GetGossipOptions or C_GossipInfo.GetOptions;

local tinsert = tinsert
local tremove = tremove
local tWipe = table.wipe

-------------------------------------------
--#region Main Gossip Functions
-------------------------------------------

---Returns if the gossip is a reload (true) or a fresh load (false)
---@return boolean isReload
function _gossip:ReloadCheck()
	return isGossipLoaded and lastGossipText and lastGossipText == currGossipText
end

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

---@return string
function _gossip:GetGreetingText()
	if ImmersionFrame and ImmersionFrame.TalkBox and ImmersionFrame.TalkBox.TextFrame then
		return ImmersionFrame.TalkBox.TextFrame.Text.storedText
	end
	return GossipGreetingText:GetText()
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

---Register a new hook
---@param predicate fun(text:string, isReload:boolean) Predicate for if this hook even applies here
---@param callback? fun(originalText:string, isReload:boolean) Optional callback to do something on specific text.
---@param filter fun(newText:string, originalText?:string):newText:string Text Filter Function. Takes in originalText, currentText, and returns newText
function _gossip:RegisterGreetingHook(predicate, callback, filter)
	if type(predicate) ~= "function" then error("RegisterGreetingHook Usage: Predicate must be a function: predicate(text, isReload) -> boolean.") end
	if callback and (type(callback) ~= "function") then error("RegisterGreetingHook Usage: callback must be nil, false, or a function: callback(originalText, isReload).") end

	local data = {
		predicate = predicate,
		filter = filter,
		callback = callback,
	}
	tinsert(_greetingHooks, data)
end

function _gossip:RemoveGreetingHook(callbackGen)
	for i = 1, #_greetingHooks do
		local data = _greetingHooks[i]
		if data.callbackGen == callbackGen then
			tremove(_greetingHooks, i)
		end
	end
end

---@class HookOptions
---@field blockOriginalOnClick boolean

---Register a new hook
---@param predicate fun(text:string, titleButton:button):boolean Predicate for if this hook even applies here
---@param callback? fun(self:frame, button:string, down:boolean, originalText:string) OnClick handler callback. Passed standard OnClick, but also the originalText as the last arg.
---@param filter fun(newText:string, originalText?:string):newText:string Text Filter Function. Takes in newText, originalText?, and returns newText. You should only use newText to for string modifications, don't use originalText as you'll replace other hooks data, only use it for reference if needed!
---@param options table
function _gossip:RegisterButtonHook(predicate, callback, filter, options)
	if type(predicate) ~= "function" then error("RegisterButtonHook Usage: Predicate must be a function: predicate(text, titleButton) -> boolean.") end
	if callback and (type(callback) ~= "function") then error("RegisterButtonHook Usage: callback must be nil, false, or a function: callback(self, button, down, originalText).") end

	local data = {
		predicate = predicate,
		filter = filter,
		callback = callback,
		options = options,
	}
	tinsert(_buttonHooks, data)
end

function _gossip:RemoveButtonHook(callbackGen)
	for i = 1, #_buttonHooks do
		local data = _buttonHooks[i]
		if data.callbackGen == callbackGen then
			tremove(_buttonHooks, i)
		end
	end
end

local nullFunc = function() end
local modifiedGossips = {}

local function runGossipHooks()
	currGossipText = GetGossipText();
	local currentOptions = GetGossipOptions()
	local isReload = _gossip:ReloadCheck()

	-- Handle Greeting Text (Body)
	--	local gossipGreetingText = _gossip:GetGreetingText() -- Why did we do this instead of pulling the real text? Idk
	local gossipGreetingText = currGossipText
	local newGreetingText = gossipGreetingText
	local greetingCallbacks = {}
	for i = 1, #_greetingHooks do
		local data = _greetingHooks[i]
		if data.predicate(gossipGreetingText, isReload) then
			if data.filter then
				newGreetingText = data.filter(newGreetingText, gossipGreetingText)
			end

			if data.callback and type(data.callback) == "function" then
				tinsert(greetingCallbacks, data.callback)
			end
		end
	end

	-- Finished Parsing Greeting Text, Set Updated Text & Run Callbacks
	_gossip:SetGreetingText(newGreetingText)
	for i = 1, #greetingCallbacks do
		greetingCallbacks[i](gossipGreetingText, isReload)
	end

	-- Handle Title Buttons
	for i = 1, GetNumGossipOptions() do
		local titleButton = _gossip:GetTitleButton(i)

		local alreadyHooked = titleButton:GetAttribute("HookedByEpsiLib")
		local prevOriginalOnClick = titleButton:GetAttribute("EL_PrevOrigOnClick")

		if alreadyHooked then
			-- Already Hooked buttons are no longer valid, due to frame pooling. We need to reset it first
			titleButton:SetAttribute("HookedByEpsiLib", false)
			titleButton:SetAttribute("EL_PrevOrigOnClick", nil)

			if prevOriginalOnClick and (type(prevOriginalOnClick) == "function") then
				titleButton:SetScript("OnClick", prevOriginalOnClick)
			else
				titleButton:SetScript("OnClick", nullFunc)
				print("WARNING: EPSI LIB DETECTED ALREADY HOOKED GOSSIP BUT NO ONCLICK TO RESTORE. GOSSIP OPTIONS MAY NOT WORK UNTIL YOU RE-OPEN THE GOSSIP!")
				print("Maybe report this? Debug: Index=", i)
			end
		end

		local originalOnClick = titleButton:GetScript("OnClick")
		--local originalText = titleButton:GetText() -- // We can't trust this because we modify it..
		local originalText = currentOptions[i].name
		local newText = originalText

		local _callbacks = {}
		local blockOriginalOnClick = false

		for j = 1, #_buttonHooks do
			local data = _buttonHooks[j]
			if data.predicate(originalText, titleButton) then
				tinsert(_callbacks, data.callback)

				if data.filter then
					newText = data.filter(newText, originalText)
				end

				if data.options then
					if data.options.blockOriginalOnClick then
						blockOriginalOnClick = true
					end
				end
			end
		end

		titleButton:SetText(newText)
		if ImmersionFrame then C_Timer.After(0, function() titleButton:SetText(newText) end) end -- Force next frame as Immersion likes to reset the text on us..
		if titleButton.Resize then titleButton:Resize() end                                -- Force resize on buttons that support it (blizz like buttons)

		if #_callbacks > 0 then
			tinsert(modifiedGossips, { button = titleButton, originalOnClick = originalOnClick })
			titleButton:SetAttribute("HookedByEpsiLib", true)
			titleButton:SetAttribute("EL_PrevOrigOnClick", originalOnClick)
			if blockOriginalOnClick then titleButton:SetScript("OnClick", nullFunc) end
			titleButton:HookScript("OnClick", function(self, button, down)
				for k = 1, #_callbacks do
					_callbacks[k](self, button, down, originalText)
				end
			end)
		end
	end

	isGossipLoaded = true
	lastGossipText = currGossipText
end

local events = {
	GOSSIP_SHOW = function()
		local canCallRightAway = true
		for i = 1, GetNumGossipOptions() do
			if not _gossip:GetTitleButton(i) then
				canCallRightAway = false
				break
			end
		end

		if canCallRightAway then
			runGossipHooks()
		else
			C_Timer.After(0, runGossipHooks)
		end
	end,
	GOSSIP_CLOSED = function()
		for i = 1, #modifiedGossips do
			local data = modifiedGossips[i]
			local button = data.button
			local onClick = data.originalOnClick

			if onClick then
				button:SetScript("OnClick", onClick)
			end

			button:SetAttribute("HookedByEpsiLib", false)
		end
		tWipe(modifiedGossips)

		isGossipLoaded = false
	end,
}

for k, v in pairs(events) do
	EpsiLib.EventManager:Register(k, v)
end

EpsiLib.Utils.Gossip = _gossip
