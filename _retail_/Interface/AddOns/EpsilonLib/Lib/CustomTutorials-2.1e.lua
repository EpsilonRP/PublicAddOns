--[[
Copyright 2010-2024 João Cardoso
CustomTutorials is distributed under the terms of the GNU General Public License (or the Lesser GPL).
This file is part of CustomTutorials.

CustomTutorials is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

CustomTutorials is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with CustomTutorials. If not, see <http://www.gnu.org/licenses/>.
--]]

-- Heavily Modified version of CustomTutorials-2.1 for Epsilon.
-- For compatibility, this modified as major version: 2.1e.
-- However this should remain compatible with the original CustomTutorials-2.1.
--
-- This version is designed to be extensible and flexible for a variety of uses,
-- along with a more direct method of defining continuations and managing how a
-- tutorial should advance. Please consult the docs below for more info on how
-- to use this library.

--[[ Docs:

-- Supported keys inside the main Tutorial Settings (frame.data):
-- title: string - The title of the tutorial.
-- savedvariable: string - The name of the saved variable to track progress.
-- key?: string - The key within the savedvariable to use. In such a case, savedvariable should be a string name of the global savedvariable table.
-- onShow?: function(frame.data, index) - Callback function when the tutorial is shown.
-- bg?: string - Background image for the tutorial - Can be overwrote by Tutorial Objects.

-- Tutorial Objects (data) should then be an array based on index order to define each tutorial step.

-- Supported Keys inside each Tutorial Object (data):
-- // Outside of text, all other keys are optional.
-- title: string - Overrides the main title for this step.
-- text: string - The text content of the tutorial step.
-- textY: number - Vertical offset for the text.
-- textX: number - Horizontal offset for the text.
-- point: string - Anchor point for the tutorial frame.
-- anchor: frame - The frame to anchor to.
-- relPoint: string - Relative point for the anchor.
-- x: number - X offset for the anchor.
-- y: number - Y offset for the anchor.
-- height: number - Height of the tutorial frame. Default is a dynamic height, recommend to leave unless you specifically need to override it.
-- image: string - Path to an image to display in the tutorial.
-- imageX: number - X offset for the image.
-- imageY: number - Y offset for the image.
-- imageW: number - Width of the image.
-- imageH: number - Height of the image.
-- shine: frame - Frame reference for the shine effect.
-- shineRight: number - Right offset for the shine effect.
-- shineBottom: number - Bottom offset for the shine effect.
-- shineLeft: number - Left offset for the shine effect.
-- shineTop: number - Top offset for the shine effect.

-- Epsi Custom Stuff:
-- bg: string - Background image for the tutorial step.
-- flash: frame|table - Frame reference for default handling, or a table containing flash data.
-- continue: function - Custom script to determine if the tutorial should continue. This is run OnUpdate with forced 1s interval. Return true to continue.
-- continueHook: table - Table with the following data: { frame = frame, hookScript = name, callback = function() } - Only runs that hook if this tutorial is shown. If tutorial is shown, runs your custom function on the frame's script hook given; if return true, continue to next tutorial step.
-- button1: table - Data to create a button at the bottom. If only one button, it is centered. If two buttons, it is on the left.
-- button2: table - Data to create a button at the bottom. If only one button, it is centered. If two buttons, it is on the right.
-- -- button table keys supported:
-- -- -- text: string - Text on the button.
-- -- -- callback: function - Function to call when the button is clicked.
-- -- -- shown: function - Function to determine if the button should be shown.
-- -- -- enabled: function - Function to determine if the button should be enabled.

--]]

local Lib = LibStub:NewLibrary('CustomTutorials-2.1e', 1)
if Lib then
	Lib.NewFrame, Lib.NewButton, Lib.UpdateFrame = nil, nil, nil
	Lib.numFrames = Lib.numFrames or 1
	Lib.frames = Lib.frames or {}
else
	return
end

local Embeds = { 'RegisterTutorials', 'TriggerTutorial', 'ShowTutorial', 'StartTutorial', 'NextTutorial', 'HideTutorial', 'GetLastUnlockedTutorial', 'ResetTutorials', 'GetTutorials' }
local ButtonTextures = 'Interface\\Buttons\\UI-SpellbookIcon-%sPage-%s'
local Frames = Lib.frames


--[[ Internal API ]] --

---Update the Unlocked SavedVariable (And Optionally Frame.unlocked)
---@param table table
---@param sv string
---@param i integer
---@param frame? frame
---@return any
local function UpdateUnlockedSV(table, sv, i, frame)
	assert(type(table) == 'table', 'UpdateUnlockedSV: table must be a table', 2)
	assert(sv, 'UpdateUnlockedSV: sv must be a key name', 2)
	local max_i = max(i, table[sv] or 0)
	table[sv] = max_i
	if frame then frame.unlocked = max_i end
	return max_i
end

local function _evalWrapper(val)
	if val then
		return val
	else
		return function(...) return true end
	end
end

local function UpdateFrame(frame, i)
	frame:GetScript("OnHide")() -- Run the OnHide to end the last regions flash etc if needed

	local data = frame.data[i]
	if not data then
		return
	end

	-- Callback
	if frame.data.onShow then
		frame.data.onShow(frame.data, i)
	end

	-- Frame
	local title = frame.TitleText or frame.TitleContainer.TitleText
	title:SetText(data.title or frame.data.title)

	frame.text:SetPoint('BOTTOM', frame, 0, (data.textY or 20) + 30)
	frame.text:SetWidth(frame:GetWidth() - (data.textX or 30) * 2)
	frame.text:SetText(data.text)

	if data.point or (not frame:IsUserPlaced()) then
		frame:ClearAllPoints()
		frame:SetPoint(data.point or 'CENTER', data.anchor or UIParent, data.relPoint or data.point or 'CENTER', data.x or 0, data.y or 0)
	end
	frame:SetHeight((data.height or data.image and 220 or 100) + (data.text and frame.text:GetHeight() + (data.textY or 20) or 0))
	frame.i = i

	local bgTex = data.bg or frame.data.bg
	if bgTex then frame.Inset.Bg:SetTexture(bgTex) else frame.Inset.Bg:SetColorTexture(0, 0, 0) end

	frame:Show()

	-- Image
	for _, image in pairs(frame.images) do
		image:Hide()
	end

	if data.image then
		local img = frame.images[i] or frame:CreateTexture()
		img:SetPoint('TOP', frame, data.imageX or 0, (data.imageY or 40) * -1)
		img:SetSize(data.imageW or 0, data.imageH or 0)
		img:SetTexture(data.image)
		img:Show()

		frame.images[i] = img
	end

	-- Shine
	if data.shine then
		frame.shine:SetParent(data.shine)
		frame.shine:SetPoint('BOTTOMRIGHT', data.shineRight or 0, data.shineBottom or 0)
		frame.shine:SetPoint('TOPLEFT', data.shineLeft or 0, data.shineTop or 0)
		frame.shine:Show()
		frame.flash:Play()
	else
		frame.flash:Stop()
		frame.shine:Hide()
	end

	-- Flash
	if data.flash then
		if type(data.flash) == "table" and not data.flash.GetObjectType then
			UIFrameFlash(unpack(data.flash))
		else
			UIFrameFlash(data.flash, 1, 1, -1, false, 0, 0)
		end
	end

	-- Buttons
	if i == 1 then
		frame.prev:Disable()
	else
		frame.prev:Enable()
	end

	local hasButton1 = data.button1 and _evalWrapper(data.button1.shown)(frame.lib, frame)
	if hasButton1 then
		frame.button1:Update(data.button1)
		frame.button1:Show()
	else
		frame.button1:Hide()
	end

	local hasButton2 = data.button2 and _evalWrapper(data.button2.shown)(frame.lib, frame)
	if hasButton2 then
		frame.button2:Update(data.button2)
		frame.button2:Show()
	else
		frame.button2:Hide()
	end
	if hasButton1 or hasButton2 then
		frame:LayoutButtons()
	end

	-- Save
	local sv = frame.data.key or frame.data.savedvariable
	if sv then
		local table = frame.data.key and frame.data.savedvariable or _G
		UpdateUnlockedSV(table, sv, i, frame)
	end

	if i < (frame.unlocked or 0) then
		frame.next:Enable()
	else
		frame.next:Disable()
	end
end

local function NewButton(frame, name, direction)
	local button = CreateFrame('Button', nil, frame)
	button:SetHighlightTexture('Interface\\Buttons\\UI-Common-MouseHilight')
	button:SetDisabledTexture(ButtonTextures:format(name, 'Disabled'))
	button:SetPushedTexture(ButtonTextures:format(name, 'Down'))
	button:SetNormalTexture(ButtonTextures:format(name, 'Up'))
	button:SetPoint('BOTTOM', 120 * direction, 2)
	button:SetSize(26, 26)
	button:SetScript('OnClick', function()
		UpdateFrame(frame, frame.i + direction)
	end)

	local text = button:CreateFontString(nil, nil, 'GameFontHighlightSmall')
	text:SetText(_G[strupper(name)])
	text:SetPoint('LEFT', (13 + text:GetStringWidth() / 2) * direction, 0)

	return button
end

local function NewOptionButton(frame)
	local button = CreateFrame("BUTTON", nil, frame, "UIPanelButtonTemplate")
	button:SetSize(24 * 4, 24)
	button:SetText("Temp")
	button:SetScript("OnClick", function(self, ...)
		if self.OnClick then self:OnClick(frame, ...) end
	end)

	function button:MoveLeft()
		self:ClearAllPoints()
		self:SetPoint("BOTTOMRIGHT", self:GetParent(), "BOTTOM", -2, 3)
		return self
	end

	function button:MoveRight()
		self:ClearAllPoints()
		self:SetPoint("BOTTOMLEFT", self:GetParent(), "BOTTOM", 2, 3)
		return self
	end

	function button:MoveCenter()
		self:ClearAllPoints()
		self:SetPoint("BOTTOM", self:GetParent(), "BOTTOM", 0, 3)
		return self
	end

	function button:Update(data)
		self:SetText(data.text)
		self.OnClick = data.callback
		self.tooltipText = data.tooltipText
		self.enabled = data.enabled

		if self.enabled and not self.enabled(frame.lib, frame) then
			self:Disable()
		else
			self:Enable()
		end
	end

	button:SetScript("OnUpdate", function(self, elapsed)
		if self.enabled == nil then return end
		self.elapsed = (self.elapsed or 0) + elapsed
		if self.elapsed > 1 then
			self.elapsed = 0
			if self.enabled then
				if self.enabled(frame.lib, frame) then
					self:Enable()
				else
					self:Disable()
				end
			else
				self:Disable()
			end
		end
	end)

	return button
end

local function NewFrame(lib)
	local frame = CreateFrame('Frame', 'CustomTutorials' .. Lib.numFrames, UIParent, 'ButtonFrameTemplate')
	local title = frame.TitleText or frame.TitleContainer.TitleText
	frame.lib = lib
	frame.Inset:SetPoint('TOPLEFT', 4, -23)
	frame.Inset.Bg:SetColorTexture(0, 0, 0)
	frame:SetFrameStrata('DIALOG')
	frame:SetClampedToScreen(true)
	frame:EnableMouse(true)
	frame:SetToplevel(true)
	frame:SetWidth(350)
	frame:SetMovable(true)
	frame:SetClampedToScreen(true)
	frame:SetScript('OnHide', function()
		frame.flash:Stop()
		frame.shine:Hide()
		local data = frame.data and frame.data[frame.i]
		if data and data.flash then
			if type(data.flash) == "table" and not data.flash.GetObjectType then
				UIFrameFlashStop(data.flash[1])
			else
				UIFrameFlashStop(data.flash)
			end
		end
	end)

	local top = (frame.NineSlice or frame):CreateTexture(nil, 'OVERLAY', nil, 5) -- the blue top
	top:SetTexture('Interface\\TutorialFrame\\UI-Tutorial-Frame')
	top:SetTexCoord(0.0019531, 0.7109375, 0.0019531, 0.15625)
	top:SetPoint('TOPLEFT', -13, 13)
	top:SetPoint('TOPRIGHT', 0, 13)
	top:SetHeight(80)

	local titleContainer = CreateFrame('Frame', nil, frame)
	frame.TitleContainer = titleContainer
	titleContainer:SetFrameLevel(510)
	titleContainer:SetSize(0, 20)
	titleContainer:SetPoint("TOPLEFT", 58, -1)
	titleContainer:SetPoint("TOPRIGHT", -24, -1)
	title:SetParent(titleContainer)
	titleContainer.TitleText = title
	titleContainer:EnableMouse(true)
	titleContainer:RegisterForDrag("LeftButton")
	titleContainer:RegisterForDrag("LeftButton")
	titleContainer:SetScript("OnDragStart", function(self, button)
		frame:StartMoving()
	end)
	titleContainer:SetScript("OnDragStop", function(self)
		frame:StopMovingOrSizing()
	end)
	local text = frame:CreateFontString(nil, nil, 'GameFontHighlight')
	text:SetJustifyH('LEFT')

	local shine = CreateFrame('Frame', nil, UIParent, BackdropTemplateMixin and 'BackdropTemplate')
	shine:SetBackdrop({ edgeFile = 'Interface\\TutorialFrame\\UI-TutorialFrame-CalloutGlow', edgeSize = 16 })

	local flash = shine:CreateAnimationGroup()
	flash:SetLooping('BOUNCE')

	local step = flash:CreateAnimation('Alpha')
	step:SetDuration(.75)
	step:SetFromAlpha(1)
	step:SetToAlpha(.3)

	for i = 1, shine:GetNumRegions() do
		select(i, shine:GetRegions()):SetBlendMode('ADD')
	end

	frame.text, frame.shine, frame.flash = text, shine, flash
	frame.prev = NewButton(frame, 'Prev', -1)
	frame.next = NewButton(frame, 'Next', 1)
	frame.images = {}

	frame.button1 = NewOptionButton(frame):MoveLeft()
	frame.button2 = NewOptionButton(frame):MoveRight()

	function frame:LayoutButtons()
		if self.button1:IsShown() and self.button2:IsShown() then
			self.button1:MoveLeft()
			self.button2:MoveRight()
		elseif self.button1:IsShown() then
			self.button1:MoveCenter()
		elseif self.button2:IsShown() then
			self.button2:MoveCenter()
		end
	end

	Lib.numFrames = Lib.numFrames + 1

	frame:HookScript("OnUpdate", function(self, ...)
		local data = self.data and self.data[self.i]
		if self.unlocked > self.i then return end -- Auto-Continue is disabled if you have already unlocked next steps
		if data and data.continue then
			if data.continue(self) then
				self.lib:NextTutorial()
			end
		end
	end)

	frame:Hide()
	return frame
end

--[[ User API ]] --

---Registers a set of tutorials.
---@param data table - The tutorial data.
---@return frame - The created tutorial frame.
function Lib:RegisterTutorials(data)
	assert(type(data) == 'table', 'RegisterTutorials: 2nd arg must be a table', 2)
	assert(self, 'RegisterTutorials: 1st arg (self/Lib) was not provided', 2)

	if not Lib.frames[self] then
		Lib.frames[self] = NewFrame(self)
	end

	Lib.frames[self].data = data

	for k, v in ipairs(data) do
		if v.startHook then
			local hookData = v.startHook
			hookData.frame:HookScript(hookData.hookScript, function(...)
				if _evalWrapper(hookData.condition)(self, Lib.frames[self], ...) then
					self:StartTutorial(k)
				end
			end)
		end
		if v.showHook then
			local hookData = v.showHook
			hookData.frame:HookScript(hookData.hookScript, function(...)
				if _evalWrapper(hookData.condition)(self, Lib.frames[self], ...) then
					self:ShowTutorial(k)
				end
			end)
		end
		if v.continueHook then
			local hookData = v.continueHook
			hookData.frame:HookScript(hookData.hookScript, function(...)
				if Lib.frames[self].i ~= k then return end -- continueHook has intrinsic check for if this tutorial is shown first
				if _evalWrapper(hookData.condition)(self, Lib.frames[self], ...) then
					self:NextTutorial()
				end
			end)
		end
	end

	return Lib.frames[self]
end

---Triggers a tutorial at a specific index.
---@param index integer - The index of the tutorial to trigger.
---@param maxAdvance boolean - Whether to advance to the maximum unlocked step.
function Lib:TriggerTutorial(index, maxAdvance)
	assert(type(index) == 'number', 'TriggerTutorial: 2nd arg must be a number', 2)
	assert(self, 'TriggerTutorial: 1st arg (self/Lib) was not provided', 2)

	local frame = Lib.frames[self]
	if frame then
		local sv = frame.data.key or frame.data.savedvariable
		local table = frame.data.key and frame.data.savedvariable or _G
		local last = sv and table[sv] or 0

		if index > last then
			frame.unlocked = index
			UpdateFrame(frame, (maxAdvance == true or not sv) and index or last + (maxAdvance or 1))
		end
	end
end

---Starts a tutorial at the specified index. Only shows if it's 'new'.
---@param index integer - The index of the tutorial to start.
---@param advanceToMax boolean - Whether to advance to the maximum unlocked step.
function Lib:StartTutorial(index, advanceToMax)
	assert(type(index) == 'number', 'StartTutorial: 2nd arg must be a number', 2)
	assert(self, 'StartTutorial: 1st arg (self/Lib) was not provided', 2)

	local frame = Lib.frames[self]
	if frame then
		local sv = frame.data.key or frame.data.savedvariable
		local table = frame.data.key and frame.data.savedvariable or _G
		local maxUnlocked = sv and table[sv] or 0

		-- In StartTutorial, we only want to show if they have not seen this far yet.
		if index > maxUnlocked then
			local stepToUse = index
			if advanceToMax == true then
				stepToUse = max(index, maxUnlocked, frame.unlocked)
			end

			--frame.unlocked = stepToUse
			UpdateFrame(frame, stepToUse)
		end
	end
end

---Shows a tutorial at a specific tutorial index. Always shows, even if not new.
---@param index integer - The index of the tutorial to start.
---@param overrideUnlocked? integer - Whether to override the max unlocked step to this value.
function Lib:ShowTutorial(index, overrideUnlocked)
	assert(type(index) == 'number', 'ShowTutorial: 2nd arg must be a number', 2)
	assert(self, 'ShowTutorial: 1st arg (self/Lib) was not provided', 2)

	local frame = Lib.frames[self]
	if frame then
		local sv = frame.data.key or frame.data.savedvariable
		local table = frame.data.key and frame.data.savedvariable or _G

		overrideUnlocked = tonumber(overrideUnlocked)
		if overrideUnlocked then
			frame.unlocked = overrideUnlocked
			table[sv] = overrideUnlocked
		end
		UpdateFrame(frame, index)
	end
end

function Lib:NextTutorial()
	assert(self, 'NextTutorial: 1st arg (self/Lib) was not provided', 2)
	local frame = Lib.frames[self]
	if frame then
		self:ShowTutorial(frame.i + 1)
	end
end

function Lib:HideTutorial()
	assert(self, 'HideTutorial: 1st arg (self/Lib) was not provided', 2)
	local frame = Lib.frames[self]
	if frame then
		frame:Hide()
	end
end

function Lib:GetLastUnlockedTutorial()
	assert(self, 'GetLastUnlockedTutorial: 1st arg (self/Lib) was not provided', 2)
	local frame = Lib.frames[self]
	if frame then
		local sv = frame.data.key or frame.data.savedvariable
		local table = frame.data.key and frame.data.savedvariable or _G
		local maxUnlocked = sv and table[sv] or 0

		return max(maxUnlocked, frame.unlocked or 0)
	end
	return 0
end

function Lib:ResetTutorials()
	assert(self, 'ResetTutorials: 1st arg (self/Lib) was not provided', 2)

	local frame = Lib.frames[self]
	if frame then
		local sv = frame.data.key or frame.data.savedvariable
		if sv then
			local table = frame.data.key and frame.data.savedvariable or _G
			table[sv] = nil
		end
		frame.unlocked = 0
		frame:Hide()
	end
end

function Lib:GetTutorials()
	assert(self, 'GetTutorials: 1st arg (self/Lib) was not provided', 2)
	return self and Lib.frames[self] and Lib.frames[self].data
end

function Lib:Embed(object)
	for _, k in ipairs(Embeds) do
		object[k] = self[k]
	end
end

-- An extension of the HelpPlate system to allow HelpPlateData to contain custom anchor data for buttons and highlight boxes.
-- While not part of the original CustomTutorials-2.1, this is a useful extension for the SCForge UI for the 'i' help buttons also.

local function getGlobalReferenceByString(str)
	local t = _G
	for w in str:gmatch("[^%.]+") do
		t = t[w]
		if not t then return end -- Path invalid; cannot continue
	end
	return t
end

local function _eval(t, i)
	if type(t) == "function" then
		return t(i)
	end
	return t
end

local function getFrameRef(frame)
	if not frame then return HelpPlate end
	if type(frame) == "string" then
		return getGlobalReferenceByString(frame)
	end
	return frame
end

hooksecurefunc("HelpPlate_Show", function(self, parent, mainHelpButton)
	for i = 1, #self do
		local button = HELP_PLATE_BUTTONS[i]
		if button then
			local buttonData = self[i]

			-- Custom ButtonPos anchor support, overrides all previous point data.
			if buttonData.ButtonPos and buttonData.ButtonPos.anchor then
				local point = buttonData.ButtonPos.anchor
				button:ClearAllPoints();
				button:SetPoint(point[1], getFrameRef(point.frame), point[2], point[3], point[4]);
			end

			-- Custom HighLightBox anchorData support, overrides all previous point data.
			if buttonData.HighLightBox and buttonData.HighLightBox.anchorData then
				button.box:ClearAllPoints();
				button.boxHighlight:ClearAllPoints();
				local frame = getFrameRef(buttonData.HighLightBox.anchorData.frame) -- base frame to use unless overridden by points
				if not buttonData.HighLightBox.anchorData.points then
					buttonData.HighLightBox.anchorData.points = { { "TOPLEFT", 0, 0 }, { "BOTTOMRIGHT", 0, 0 } }
				end
				for j = 1, #buttonData.HighLightBox.anchorData.points do
					local point = buttonData.HighLightBox.anchorData.points[j]
					local frame = frame
					if point.frame then
						frame = getFrameRef(point.frame)
					end
					button.boxHighlight:SetPoint(point[1], frame, point[2], point[3], point[4]);
					button.box:SetPoint(point[1], frame, point[2], point[3], point[4]);
				end
				if buttonData.HighLightBox.anchorData.width then
					button.boxHighlight:SetWidth(_eval(buttonData.HighLightBox.anchorData.width))
					button.box:SetWidth(_eval(buttonData.HighLightBox.anchorData.width))
				end
				if buttonData.HighLightBox.anchorData.height then
					button.boxHighlight:SetHeight(_eval(buttonData.HighLightBox.anchorData.height))
					button.box:SetHeight(_eval(buttonData.HighLightBox.anchorData.height))
				end
			end
		end
	end

	if self.anchorData then
		HelpPlate:ClearAllPoints();
		local frame = self.anchorData.frame
		for j = 1, #self.anchorData.points do
			local point = self.anchorData.points[j]
			HelpPlate:SetPoint(point[1], frame, point[2], point[3], point[4]);
		end
	end
end)
-- Force cleanse HelpPlate anchors on hide to prevent anchor bleed-over
HelpPlate:HookScript("OnHide", function(self)
	self:ClearAllPoints()
end)
