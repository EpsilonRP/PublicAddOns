local EpsilonLib, EpsiLib = ...;

EpsiLib.Utils.Tooltip = {}
local _tt = EpsiLib.Utils.Tooltip

local contrastColor = CreateColorFromHexString("FFFFAAAA") -- FFAAAA : Light Red
local ASSETS_PATH = "Interface/AddOns/" .. tostring(EpsilonLib) .. "/Resources/"

local timer

-- Adding a cool icon system...
if not GameTooltip.extraIcon then
	local tooltipIcon = CreateFrame("Frame", nil, GameTooltip)
	tooltipIcon:SetPoint("TOPRIGHT", GameTooltip, "TOPLEFT", 0, -2)
	tooltipIcon:SetSize(39, 39)

	GameTooltip.extraIcon = tooltipIcon -- for easy access

	tooltipIcon.tex = tooltipIcon:CreateTexture()
	tooltipIcon.tex:SetAllPoints(tooltipIcon)
	tooltipIcon.tex:SetTexture("interface/icons/inv_mushroom_11")
	tooltipIcon:Hide() -- default hide

	GameTooltip:HookScript("OnShow", function(self)
		tooltipIcon:Hide()
	end)
end

---Concat the two texts together with a strchar(31) as a delimiter to create a double line.
---@param text1 string
---@param text2 string
---@return string
function _tt.CreateDoubleLine(text1, text2)
	return text1 .. strchar(31) .. text2
end

--#region Tag Replacement System

local raw_atlas_tags = {
	["left-click"] = CreateAtlasMarkup("NPE_LeftClick"),
	["right-click"] = CreateAtlasMarkup("NPE_RightClick"),
	["mouse-wheel"] = CreateAtlasMarkup("newplayertutorial-icon-mouse-middlebutton"),
	["shift"] = CreateTextureMarkup(ASSETS_PATH .. "KeyPressIcons.tga", 64, 128, 24, 12, 0, 0.5, 0, 0.5),
	["ctrl"] = CreateTextureMarkup(ASSETS_PATH .. "KeyPressIcons.tga", 64, 128, 24, 12, 0, 0.5, 0.5, 1),
	["alt"] = CreateTextureMarkup(ASSETS_PATH .. "KeyPressIcons.tga", 64, 128, 24, 12, 0.5, 1, 0, 0.5),
	["esc"] = CreateTextureMarkup(ASSETS_PATH .. "KeyPressIcons.tga", 64, 128, 24, 12, 0.5, 1, 0.5, 1),
}
local text_replacement_tags = {
	["{left-click}"] = raw_atlas_tags["left-click"],
	["{right-click}"] = raw_atlas_tags["right-click"],
	["{mouse-wheel}"] = raw_atlas_tags["mouse-wheel"],
	["{middle-click}"] = raw_atlas_tags["mouse-wheel"],

	["{left-click-text}"] = contrastColor:WrapTextInColorCode("Left-Click"),
	["{right-click-text}"] = contrastColor:WrapTextInColorCode("Right-Click"),
	["{mouse-wheel-text}"] = contrastColor:WrapTextInColorCode("Mouse Wheel"),
	["{middle-click-text}"] = contrastColor:WrapTextInColorCode("Middle-Click"),

	["{shift-text}"] = contrastColor:WrapTextInColorCode("Shift"),
	["{ctrl-text}"] = contrastColor:WrapTextInColorCode("Ctrl"),
	["{alt-text}"] = contrastColor:WrapTextInColorCode("Alt"),
	["{esc-text}"] = contrastColor:WrapTextInColorCode("Esc"),

	["{shift}"] = raw_atlas_tags["shift"],
	["{ctrl}"] = raw_atlas_tags["ctrl"],
	["{alt}"] = raw_atlas_tags["alt"],
	["{esc}"] = raw_atlas_tags["esc"],

	["{shift-left-click-text}"] = contrastColor:WrapTextInColorCode("Shift + Left-Click"),
	["{shift-right-click-text}"] = contrastColor:WrapTextInColorCode("Shift + Right-Click"),
	["{alt-right-click-text}"] = contrastColor:WrapTextInColorCode("Alt + Right-Click"),
	["{alt-left-click-text}"] = contrastColor:WrapTextInColorCode("Alt + Left-Click"),
	["{ctrl-left-click-text}"] = contrastColor:WrapTextInColorCode("Ctrl + Left-Click"),
	["{ctrl-right-click-text}"] = contrastColor:WrapTextInColorCode("Ctrl + Right-Click"),

	["{shift-left-click}"] = raw_atlas_tags["shift"] .. "+" .. raw_atlas_tags["left-click"],
	["{shift-right-click}"] = raw_atlas_tags["shift"] .. "+" .. raw_atlas_tags["right-click"],
	["{alt-right-click}"] = raw_atlas_tags["alt"] .. "+" .. raw_atlas_tags["right-click"],
	["{alt-left-click}"] = raw_atlas_tags["alt"] .. "+" .. raw_atlas_tags["left-click"],
	["{ctrl-left-click}"] = raw_atlas_tags["ctrl"] .. "+" .. raw_atlas_tags["left-click"],
	["{ctrl-right-click}"] = raw_atlas_tags["ctrl"] .. "+" .. raw_atlas_tags["right-click"],

	["{right-click-text-icon}"] = raw_atlas_tags["right-click"] .. contrastColor:WrapTextInColorCode(" Right-Click"),
	["{left-click-text-icon}"] = raw_atlas_tags["left-click"] .. contrastColor:WrapTextInColorCode(" Left-Click"),
}

local function replace_text_tags(text)
	return text:gsub("(%b{})", text_replacement_tags)
end
_tt.ReplaceTags = replace_text_tags

local function getTooltipTag(text)
	if not text:find("{") then text = "{" .. text .. "}" end
	return text_replacement_tags[text] or text
end
_tt.Tag = getTooltipTag

--#endregion

--#region Internal Creation Functions

---@param title string
local function setTitle(title)
	GameTooltip:SetText(title, nil, nil, nil, nil, true)
end

local function setIcon(icon)
	if not icon then return end
	GameTooltip.extraIcon.tex:SetTexture(icon)
	GameTooltip.extraIcon:Show()
end

local function clearLines()
	GameTooltip:ClearLines()
end

---@param line string
local function addLine(line)
	line = replace_text_tags(line)

	if line:match(strchar(31)) then
		--GameTooltip:AddLine(line, 1, 1, 1, true)
		local line1, line2 = strsplit(strchar(31), line, 2)
		GameTooltip:AddDoubleLine(line1, line2, 1, 1, 1, 1, 1, 1)
	else
		GameTooltip:AddLine(line, 1, 1, 1, true)
	end
end


---@param self frame
---@param title string | fun(self): string
---@param lines? string[] | string | fun(self): (string[] | string)
---@param icon? string | fun(self): (string)
local function setTooltip(self, title, lines, icon)
	local _title = title
	local _lines = lines

	if type(_title) == "function" then
		_title = _title(self)
	end

	if _title then
		setTitle(_title)
	else
		clearLines()
	end

	if _lines then
		if type(_lines) == "function" then
			_lines = _lines(self)
		end

		if type(_lines) == "string" then
			addLine(_lines)
		else
			for _, line in ipairs(_lines) do
				addLine(line)
			end
		end
	end

	if icon then
		if type(icon) == "function" then
			icon = icon()
		end

		setIcon(icon)
	end

	GameTooltip:Show()
end

---@class TooltipOptions
---@field updateOnClick boolean?
---@field delay (integer | function)?
---@field anchor string? Custom anchor position - If not given, defaults to left, as standard in WoW
---@field predicate function?
---@field updateOnUpdate boolean?
---@field icon? string | fun(self): string

---@param title string | fun(self): string
---@param lines? string[] | string | fun(self): (string[] | string)
---@param options? TooltipOptions
local function onEnter(title, lines, options)
	return function(self)
		local delay = options and options.delay or 0.7
		if type(delay) == "function" then delay = delay(self) end
		if options and options.predicate then
			if not options.predicate(self) then return end
		end

		if timer then timer:Cancel() end

		GameTooltip:SetOwner(self, self.tooltipAnchor or "ANCHOR_LEFT")

		timer = C_Timer.NewTimer(delay, function()
			setTooltip(self, title, lines, options and options.icon)
		end)
	end
end

local function onLeave(self)
	--if GameTooltip:GetOwner() ~= self then return end
	GameTooltip_Hide()
	if timer then
		timer:Cancel()
	end
end

--#endregion

--#region Public Call Functions - Some Internally Used Also

---@generic F
---@param frame F | Frame | Button
---@param title string | fun(self: F): string | nil
---@param lines? string[] | string | fun(self: F): (string[] | string)
---@param options? TooltipOptions
local function set(frame, title, lines, options)
	frame:HookScript("OnEnter", onEnter(title, lines, options))

	if options then
		if options.updateOnClick then
			frame:HookScript("OnClick", function(self)
				setTooltip(self, title, lines, options and options.icon)
			end)
		end
		if options.anchor then
			frame.tooltipAnchor = options.anchor
		end

		if options.updateOnUpdate then
			frame:HookScript("OnUpdate", function(self)
				if GameTooltip:GetOwner() == self then
					setTooltip(self, title, lines, options and options.icon)
				end
			end)
		end
	end

	frame:HookScript("OnLeave", onLeave)
end
_tt.Set = set

---Call to directly show a tooltip; this is mostly so you can update / redraw a tooltip live if needed.
---@param self frame
---@param title string | fun(self): string
---@param lines? string[] | string | fun(self): (string[] | string)
---@param icon? string | fun(self):string
---@param dontSetOwner? boolean Ignore setting owner, if that's not how it visually should be..
local function rawSetTooltip(self, title, lines, icon, dontSetOwner)
	if not dontSetOwner then GameTooltip:SetOwner(self, self.tooltipAnchor or "ANCHOR_LEFT") end
	setTooltip(self, title, lines, icon)
end
_tt.RawSet = rawSetTooltip

---Set a Tooltip on an AceGui Frame since we need to use their custom callbacks instead of hookscripts
---@param frame AceGUIFrame|AceGUIWidget
---@param title string | fun(self: F): string | nil
---@param lines? string[] | string | fun(self: F): (string[] | string)
---@param options? TooltipOptions
local function setAceTT(frame, title, lines, options)
	frame:SetCallback("OnEnter", function(widget)
		onEnter(title, lines, options)(widget.frame)
	end)

	frame:SetCallback("OnLeave", function(widget)
		onLeave(widget.frame)
	end)
end
_tt.SetAce = setAceTT

local function genTableKeyPredicate(table, key, invert)
	if invert then -- Example: key is 'hideTooltips'
		return function(self)
			return not table[key]
		end
	else -- Example: key is 'showTooltips'
		return function(self)
			return table[key]
		end
	end
end
_tt.GenBasicPredicate = genTableKeyPredicate
