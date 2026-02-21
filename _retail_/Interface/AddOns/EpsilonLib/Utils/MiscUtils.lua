local EpsilonLib, EpsiLib = ...;

EpsiLib.Utils.Misc = {}
local _misc = EpsiLib.Utils.Misc

-- SimpleHTML with Custom Img Tag Attributes Util

-- mask helper functions
local function removeAllMasks(tex)
	for i = 1, tex:GetNumMaskTextures() do
		tex:RemoveMaskTexture(tex:GetMaskTexture(i))
	end
end

local function maskUp(tex, str)
	if not tex or not str then return end
	local frame = tex:GetParent()
	local mask = tex.mask or frame:CreateMaskTexture()
	tex.mask = mask
	mask:SetAllPoints(tex)
	mask:SetTexture(str, "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
	tex:AddMaskTexture(mask)
end

local function _eval(t, ...)
	if type(t) == "function" then
		return t(...)
	end
	return t
end

local function convertDevFilePath(addonName, filePath)
	if not filePath then return end
	if not addonName then addonName = EpsilonLib end
	local baseAddOnName = addonName:gsub("%-dev", "")

	filePath = filePath:gsub("%-dev", "")
	filePath = filePath:gsub(baseAddOnName, addonName)
	return filePath
end

-- Custom Attributes (customAttrs) are an array of tables, containing the following valid keys:
-- key = 'string' -- The key that the found data is store in during calls, and really just for easier remembering what this stuff is.
-- handler = 'string:methodName'|func(region, foundStr) -- Either a string, being a method name on the region object, passed the values of the found string split by commas (strsplit(",", match), OR a function that takes in the region, and the RAW string found as the value of that attribute)
-- pattern = 'string' -- The pattern to use when searching the preAttrs and postAttrs of the img tag. Optional, and just uses the key formatted in the default 'keyPattern' below if not given.

-- Feel free to extend the usage more if needed - right now, it's primary use is texCoord support in SimpleHTML

local customAttrs = {
	{
		key = 'texCoords',
		--pattern = 'texCoords="([^"]+)"', -- Not needed, using 'key' for the 'keyPattern' instead here
		--handler="SetTexCoord", -- This should ALSO work, but highlighting both cases here
		handler = function(region, texCoordsStr)
			if texCoordsStr then
				local coords = { strsplit(",", texCoordsStr, 4) }
				region:SetTexCoord(unpack(coords))
			end
		end
	},
	{
		key = 'vertexColour',
		handler = function(region, vertexColourStr)
			if vertexColourStr then
				local rgb = { strsplit(",", vertexColourStr, 3) }
				region:SetVertexColor(unpack(rgb));
			end
		end
	},
	{
		key = 'blendMode',
		handler = function(region, blendMode)
			if blendMode then
				region:SetBlendMode(blendMode)
			end
		end
	},
	{
		key = 'desaturate',
		handler = function(region)
			region:SetDesaturated(true)
		end
	},
	{
		key = 'rotation',
		handler = function(region, degrees)
			if degrees then
				local radians = rad(degrees)
				if radians then
					region:SetRotation(radians)
				end
			end
		end
	},
	{
		key = 'mask',
		handler = function(region, maskStr)
			if maskStr then
				maskUp(region, maskStr)
			end
		end
	}
}

local keyPattern = '%s="([^"]+)"'

_misc.SetSimpleHTMLWithImageExtensions = function(simpleHTMLFrame, html)
	local imageLookups = {}

	-- Function to process <img> tags
	local id = 1
	html = string.gsub(html, '<img%s+([^>]-)src="([^"]+)"([^>]*)>', function(preAttrs, src, postAttrs)
		-- Store the src value in the lookup table
		local srcData = { file = src }

		-- Check for customAttrs in preAttrs or postAttrs
		for _, attrData in ipairs(customAttrs) do
			local pattern = attrData.pattern or keyPattern:format(attrData.key) -- if no specific pattern, uses default of key based pattern
			local match = preAttrs:match(pattern) or postAttrs:match(pattern)
			if match then
				srcData[attrData.key] = match
			end
		end

		table.insert(imageLookups, srcData)
		-- Replace the src value with the sequential ID.
		-- Note that unsupported ATTRIBUTES are just ignored, and DO NOT CAUSE AN ISSUE, so we are fine leaving them in!
		local replacement = string.format('<img %ssrc="%d"%s>', preAttrs, id, postAttrs)
		id = id + 1
		return replacement
	end)

	-- Set the processed HTML to the SimpleHTML object
	simpleHTMLFrame:SetText(html)

	-- Process the regions to fix textures
	local regions = { simpleHTMLFrame:GetRegions() }
	for idx, region in ipairs(regions) do
		if region:GetObjectType() == "Texture" then
			local texturePath = region:GetTextureFilePath()
			if texturePath then
				local index = tonumber(texturePath)
				if index and imageLookups[index] then
					local lookupData = imageLookups[index]
					-- Update the texture using the original src value
					region:SetTexture(lookupData.file)
					region:SetBlendMode("BLEND")
					region:SetVertexColor(1, 1, 1, 1);
					region:SetDesaturated(false)
					removeAllMasks(region)
					region:SetRotation(0)
					region:SetTexCoord(0, 1, 0, 1) -- Always reset first, to ensure previous modifications are not kept

					-- process custom attributes
					for _, attrData in ipairs(customAttrs) do
						local match = lookupData[attrData.key]
						if match then
							if type(attrData.handler) == "string" then
								local splitMatches = { strsplit(",", match) }
								region[attrData.handler](region, unpack(splitMatches))
							elseif type(attrData.handler) == "function" then
								attrData.handler(region, match)
							end
						end
					end
				else
					-- non-blocking error handling
					geterrorhandler()(string.format("EL-SetSimpleHTMLWithImageExtensions Error: Texture ID %s not found in imageLookups!", texturePath))
				end
			else
				-- non-blocking error handling
				geterrorhandler()(string.format("EL-SetSimpleHTMLWithImageExtensions Error: Region %s (%s) does not have a valid texture path.", idx, tostring(region)))
			end
		end
	end
end

-- Simple Frame Measurement Tool:
-- Use '/run MEASURE_FRAME(frame)' to initiate
-- Use '/run MARK_POINT()' to mark a point to measure distance from. Default point is where the cursor is when MEASURE_FRAME is ran.
-- Both 'Frame Relative' coords, and distance from last marked point, are shown in the tooltip.

local lastX, lastY, curX, curY = 0, 0, 0, 0
function MARK_POINT()
	lastX = curX
	lastY = curY
end

local function measure_script(self, elapsed)
	-- Get the mouse's position relative to the frame
	local mouseX, mouseY = GetCursorPosition()
	local frameLeft, frameBottom = self:GetLeft(), self:GetBottom()
	local frameScale = self:GetEffectiveScale()
	local frameHeight = self:GetHeight()

	-- Convert global coordinates to frame-relative coordinates
	local relativeX = (mouseX / frameScale) - frameLeft
	local relativeY = (mouseY / frameScale) - frameBottom
	relativeY = frameHeight - relativeY

	curX = relativeX
	curY = relativeY

	-- Display the relative coordinates in a tooltip
	GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
	GameTooltip:ClearLines()
	GameTooltip:AddLine("Mouse Coordinates (Relative to Frame):")
	GameTooltip:AddLine(string.format("X: %.1f, Y: %.1f", relativeX, relativeY))
	GameTooltip:AddLine(string.format("dX: %.1f, dY: %.1f", relativeX - lastX, relativeY - lastY))
	GameTooltip:Show()
end

function MEASURE_FRAME(frame)
	frame:HookScript("OnUpdate", measure_script)
	MARK_POINT()
end

-- Button Texture Setup Functions

local function setTextureOffset(frameTexture, x, y)
	frameTexture:SetVertexOffset(UPPER_LEFT_VERTEX, x, y)
	frameTexture:SetVertexOffset(UPPER_RIGHT_VERTEX, x, y)
	frameTexture:SetVertexOffset(LOWER_LEFT_VERTEX, x, y)
	frameTexture:SetVertexOffset(LOWER_RIGHT_VERTEX, x, y)
end

local function setHighlightToOffsetWithPushed(frame, x, y)
	if not x then x = 1 end
	if not y then y = -1 end
	local highlight = frame:GetHighlightTexture()
	frame:HookScript("OnMouseDown", function(self) setTextureOffset(highlight, x, y) end)
	frame:HookScript("OnMouseUp", function(self) setTextureOffset(highlight, 0, 0) end)
end

---@param button BUTTON|Button
---@param path string
---@param useAtlas? boolean
function _misc.SetupCoherentButtonTextures(button, path, useAtlas)
	if useAtlas then
		button:SetNormalAtlas(path)
		button:SetHighlightAtlas(path, "ADD")
		button:SetDisabledAtlas(path)
		button:SetPushedAtlas(path)
	else
		button:SetNormalTexture(path)
		button:SetHighlightTexture(path, "ADD")
		button:SetDisabledTexture(path)
		button:SetPushedTexture(path)
	end
	button.NormalTexture = button:GetNormalTexture()
	button.HighlightTexture = button:GetHighlightTexture()
	button.DisabledTexture = button:GetDisabledTexture()
	button.PushedTexture = button:GetPushedTexture()

	button.HighlightTexture:SetAlpha(0.33)

	setHighlightToOffsetWithPushed(button)
	button.DisabledTexture:SetDesaturated(true)
	button.DisabledTexture:SetVertexColor(.6, .6, .6)
	setTextureOffset(button.PushedTexture, 1, -1)
end

function _misc.AdjustDevTex(addonName, ...)
	local textures = { ... }
	for i = 1, #textures do
		local tex = textures[i]
		if tex:IsObjectType("Texture") then
			local file = tex:GetTextureFilePath()
			if type(file) == "string" and file:lower():find("addon") then
				file = convertDevFilePath(addonName, file)
				tex:SetTexture(file)
			end
		end
	end
end

-- Internal - Uses a tracker table to handle recurse to ensure we cannot get stuck in a loop somehow.
local function _AdjustAllDevTex(addonName, frame, tracker)
	if not tracker then return end
	if not frame:IsObjectType("Frame") then return end -- cannot handle non-frames
	if tracker[frame] then return end               -- already handled this frame
	tracker[frame] = true

	-- handle this frames regions
	_misc.AdjustDevTex(addonName, frame:GetRegions())

	-- dig to fix this frames children (recurse)
	local children = { frame:GetChildren() }
	for i = 1, #children do
		_AdjustAllDevTex(addonName, children[i], tracker)
	end
end

function _misc.AdjustAllDevTex(addonName, frame)
	local handledFrames = {}
	_AdjustAllDevTex(addonName, frame, handledFrames)
end

--#region AceGUI powered Context Menus

local t = {}
_misc.ContextMenu = t


local AceGUI = LibStub("AceGUI-3.0")

-- Dropdown widget (but we don't show it immediately)
local dropdown = AceGUI:Create("Dropdown")
dropdown:SetWidth(200)
dropdown:SetCallback("OnValueChanged", function(widget, event, key, checked)
	--print("You selected:", key)
end)

-- Hide it by default
dropdown.frame:Hide()

local pullout = dropdown.pullout
pullout.frame:SetFrameStrata("TOOLTIP") -- so it floats over other frames
pullout.frame:Hide()

function t.SetValue(value)
	dropdown:SetValue(value)
	dropdown.lastVal = value
end

--ContextMenu.Open
function t.Open(parent, list, callback, options)
	assert(parent, "Must be called with parent"); assert(list, "Must be called with list"); assert(type(callback) == "function", "Must be called with callback function")

	local order
	list, order = _eval(list)
	if not list or type(list) ~= "table" then error("List returned invalid") end

	if options then
		if options.width then pullout:SetWidth(math.max(100, options.width)) end
	end

	dropdown:SetList(list, order)
	dropdown:SetCallback("OnValueChanged", function(widget, event, key, checked)
		if key == "__close" then
			widget.value = widget.lastVal
			return
		end
		local cbVal = callback(key, checked, GetMouseButtonClicked())
		if GetMouseButtonClicked() == "RightButton" then
			-- Right-Click = Not a true select, revert to last selected in the UI
			widget.value = widget.lastVal
			return
		end
		if cbVal == false then
			-- reuse the lastVal; resaves below reduntently but that's fine
			widget.value = widget.lastVal
		elseif cbVal then
			-- cbVal was truthy, use it's value
			widget.value = cbVal
		end
		-- Save the value as the lastValue
		widget.lastVal = widget.value -- Record the last value for revert tracking if needed
	end)

	for k, item in pullout:IterateItems() do
		if item.type == "Dropdown-Item-Toggle" then
			if options.enableRightClick then
				item.frame:RegisterForClicks("LeftButtonUp", "RightButtonUp")
			end
			local _origOnRelease = item.OnRelease -- Should this be item.events["OnRelease"] ?? Idk
			local _origOnValueChanged = item.events["OnValueChanged"]

			item.events["OnValueChanged"] = function(this, event, checked)
				local self = this.userdata.obj

				if self.multiselect then
					self:Fire("OnValueChanged", this.userdata.value, checked)
				else
					if checked then
						self:SetValue(this.userdata.value)
						self:Fire("OnValueChanged", this.userdata.value)
					else
						this:SetValue(true)
						self:Fire("OnValueChanged", this.userdata.value) -- CUSTOM EDIT: We still allow firing on re-select
					end
					if self.open then
						self.pullout:Close()
					end
				end
			end
			item:SetCallback("OnRelease", function(self)
				item.frame:RegisterForClicks("LeftButtonUp") -- fix our right-click hack
				item.events["OnValueChanged"] = _origOnValueChanged
				item:SetCallback("OnRelease", _origOnRelease)
				_origOnRelease(self)
			end)
		end
	end

	--pullout.frame:SetParent(parent)
	pullout.frame.virtualparent = parent

	dropdown.open = true
	AceGUI:SetFocus(dropdown)

	if options.hasClose then
		dropdown:AddItem("__closeLine", "-", "Dropdown-Item-Separator")
		dropdown:AddItem("__close", "Close", "Dropdown-Item-Execute")
	end

	pullout:SetPoint("TOP", parent, "BOTTOM", 0, -2)
	pullout:Open("TOP", parent, "BOTTOM", 0, -2)
end

function t.Close(parent)
	if parent and (parent ~= pullout.frame:GetParent()) then return end -- Only close if parent matches parent if parent given

	dropdown.open = nil
	pullout:Close()
	pullout:Clear()
	AceGUI:ClearFocus()

	return true
end

--ContextMenu.Toggle
function t.Toggle(parent, list, callback, options)
	if pullout.frame:IsShown() then
		if t.Close(parent) then return end
		t.Close()
	end
	t.Open(parent, list, callback, options)
end

if UIDropDownMenu_HandleGlobalMouseEvent then
	hooksecurefunc("UIDropDownMenu_HandleGlobalMouseEvent", function(button, event)
		if dropdown.open and event == "GLOBAL_MOUSE_DOWN" and (button == "LeftButton" or button == "RightButton") then
			if pullout.frame:IsMouseOver() then return end
			t.Close()
		end
	end)
else
	EventRegistry:RegisterFrameEventAndCallback("GLOBAL_MOUSE_DOWN", function(ownerID, button)
		if dropdown.open and (button == "LeftButton" or button == "RightButton") then
			if pullout.frame:IsMouseOver() then return end
			t.Close()
		end
	end)
end


-- Unit Subname Util

local subNameTTName = "MogitSubnameHiddenTooltipScanner"
local subNameTT = CreateFrame("GameTooltip", subNameTTName, nil, "GameTooltipTemplate")
subNameTT:SetOwner(UIParent, "ANCHOR_NONE")

function UnitSubName(unit)
	if UnitIsPlayer(unit) then return nil end
	local tooltip = subNameTT
	tooltip:SetUnit(unit)

	-- The first line is the name, second line is subname, unless colorblind mode is enabled, then subname is the third line
	local line = 2
	local colorblindMode = GetCVar("colorblindMode")
	if colorblindMode == "1" then
		line = 3
	end
	local subName = _G[subNameTTName .. "TextLeft" .. line]
	if subName then
		subName = subName:GetText()
		if not subName or subName == "" then return end
		if subName:find("Level") then return end
		return subName
	end
end

-- Frame Dragbar Builder
function _misc.AddDragBarToFrame(frame)
	local dragBar = CreateFrame("Frame", nil, frame)
	dragBar:SetPoint("TOPLEFT")
	dragBar:SetSize(20, 20)
	if frame.CloseButton then
		dragBar:SetPoint("RIGHT", frame.CloseButton, "LEFT", -20, 0)
	else
		dragBar:SetPoint("TOPRIGHT", 0, 0)
	end
	dragBar:RegisterForDrag("LeftButton");
	dragBar:EnableMouse(true)
	dragBar:HookScript("OnMouseDown", function(self)
		frame:Raise()
		frame:StartMoving()
	end)
	dragBar:HookScript("OnMouseUp", function(self)
		frame:StopMovingOrSizing()
	end)
end
