---@class ns
local ns = select(2, ...)

local Constants = ns.Constants
local ADDON_COLORS = ns.Constants.ADDON_COLORS

local ASSETS_PATH = Constants.ASSETS_PATH .. "/"

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
-- Util Stuff

---Concat the two texts together with a strchar(31) as a delimiter to create a double line.
---@param text1 string
---@param text2 string
---@return string
local function createDoubleLine(text1, text2)
	return text1 .. strchar(31) .. text2
end

---@alias TooltipStyle "contrast" | "example" | "norevert" | "revert" | "lpurple" | "warning"

---@class TooltipStyleData
---@field color string
---@field tag string? text that shows up before the given text
---@field tagColor string?
---@field texture string? path
---@field atlas string? atlasName
---@field iconH integer?
---@field iconW integer?
---@field additionalParsing function? additional parsing function

---@type { [TooltipStyle]: TooltipStyleData }
local tooltipTextStyles = {
	contrast = {
		color = ADDON_COLORS.TOOLTIP_CONTRAST:GenerateHexColor(),
	},
	example = {
		color = ADDON_COLORS.TOOLTIP_EXAMPLE:GenerateHexColor(),
		tag = "Example: ",
		additionalParsing = function(text)
			if text:find("<.*>") then
				-- convert < > to contrast text
				text = text:gsub("<(.-)>", ns.Utils.Tooltip.genContrastText("%1"))
			end
			return text
		end
	},
	grey = {
		color = ADDON_COLORS.TOOLTIP_NOREVERT:GenerateHexColor(),
	},
	norevert = {
		color = ADDON_COLORS.TOOLTIP_NOREVERT:GenerateHexColor(),
	},
	revert = {
		color = ADDON_COLORS.GAME_GOLD:GenerateHexColor(),
		tag = "Revert: ",
		tagColor = ADDON_COLORS.TOOLTIP_REVERT:GenerateHexColor(),
		atlas = "transmog-icon-revert",
		iconH = 16,
	},
	lpurple = {
		color = ADDON_COLORS.LIGHT_PURPLE:GenerateHexColor(),
	},
	warning = {
		tag = "Warning: ",
		color = ADDON_COLORS.TOOLTIP_WARNINGRED:GenerateHexColor(),
	},
}

---@param style TooltipStyle
---@param text string
---@return string
local function stylizeTooltipText(style, text)
	local styledata = tooltipTextStyles[style]

	if styledata.additionalParsing then
		text = styledata.additionalParsing(text)
	end

	local color = styledata.color and "|c" .. styledata.color or nil
	local iconH, iconW = styledata.iconH and styledata.iconH or 0,
		(styledata.iconW and styledata.iconW) or (styledata.iconH and styledata.iconH) or 0

	local icon
	if styledata.texture then
		icon = "|T" .. styledata.texture .. ":" .. iconH .. ":" .. iconW .. "|t "
	elseif styledata.atlas then
		icon = "|A:" .. styledata.atlas .. ":" .. iconH .. ":" .. iconW .. "|a "
	end

	local tag = styledata.tag
	if tag and styledata.tagColor then
		tag = WrapTextInColorCode(tag, styledata.tagColor)
	end

	if styledata.color then
		text = text:gsub("|r", "|r" .. color) -- until SL makes it so colors pop in order instead of all, this will always add our color back, including after the tag! // TODO: Fix this cuz we're SL now
	end

	text = (icon and icon or "") .. (color and color or "") .. (tag and tag or "") .. text .. (color and "|r" or "")

	return text
end

---@param text string | table
local function genContrastText(text)
	if type(text) == "table" then
		local finalText
		for i = 1, #text do
			local string = text[i]
			if finalText then
				finalText = finalText .. ", " .. stylizeTooltipText("contrast", string)
			else
				finalText = stylizeTooltipText("contrast", string)
			end
		end
		return finalText
	else
		return stylizeTooltipText("contrast", text)
	end
end

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

	["{left-click-text}"] = stylizeTooltipText("contrast", "Left-Click"),
	["{right-click-text}"] = stylizeTooltipText("contrast", "Right-Click"),
	["{mouse-wheel-text}"] = stylizeTooltipText("contrast", "Mouse Wheel"),
	["{middle-click-text}"] = stylizeTooltipText("contrast", "Middle-Click"),

	["{shift-text}"] = stylizeTooltipText("contrast", "Shift"),
	["{ctrl-text}"] = stylizeTooltipText("contrast", "Ctrl"),
	["{alt-text}"] = stylizeTooltipText("contrast", "Alt"),
	["{esc-text}"] = stylizeTooltipText("contrast", "Esc"),

	["{shift}"] = raw_atlas_tags["shift"],
	["{ctrl}"] = raw_atlas_tags["ctrl"],
	["{alt}"] = raw_atlas_tags["alt"],
	["{esc}"] = raw_atlas_tags["esc"],

	["{shift-left-click-text}"] = stylizeTooltipText("contrast", "Shift + Left-Click"),
	["{shift-right-click-text}"] = stylizeTooltipText("contrast", "Shift + Right-Click"),
	["{alt-right-click-text}"] = stylizeTooltipText("contrast", "Alt + Right-Click"),
	["{alt-left-click-text}"] = stylizeTooltipText("contrast", "Alt + Left-Click"),
	["{ctrl-left-click-text}"] = stylizeTooltipText("contrast", "Ctrl + Left-Click"),
	["{ctrl-right-click-text}"] = stylizeTooltipText("contrast", "Ctrl + Right-Click"),

	["{shift-left-click}"] = raw_atlas_tags["shift"] .. "+" .. raw_atlas_tags["left-click"],
	["{shift-right-click}"] = raw_atlas_tags["shift"] .. "+" .. raw_atlas_tags["right-click"],
	["{alt-right-click}"] = raw_atlas_tags["alt"] .. "+" .. raw_atlas_tags["right-click"],
	["{alt-left-click}"] = raw_atlas_tags["alt"] .. "+" .. raw_atlas_tags["left-click"],
	["{ctrl-left-click}"] = raw_atlas_tags["ctrl"] .. "+" .. raw_atlas_tags["left-click"],
	["{ctrl-right-click}"] = raw_atlas_tags["ctrl"] .. "+" .. raw_atlas_tags["right-click"],

	["{right-click-text-icon}"] = stylizeTooltipText("contrast", "Right-Click ") .. raw_atlas_tags["right-click"],
	["{left-click-text-icon}"] = stylizeTooltipText("contrast", "Left-Click ") .. raw_atlas_tags["left-click"],
}
local function replace_text_tags(text)
	return text:gsub("(%b{})", text_replacement_tags)
end

local function getTooltipTag(text)
	if not text:find("{") then text = "{" .. text .. "}" end
	return text_replacement_tags[text] or text
end

---@param style TooltipStyle
---@param text string
---@return string
local function genTooltipText(style, text)
	if not text then return "" end
	return stylizeTooltipText(style, replace_text_tags(text))
end

-- Back to your regularly scheduled program

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

---Call to directly show a tooltip; this is mostly so you can update / redraw a tooltip live if needed.
---@param title string | fun(self): string
---@param lines? string[] | string | fun(self): (string[] | string)
---@param icon? string | fun(self):string
---@param dontSetOwner? boolean Ignore setting owner, if that's not how it visually should be..
local function rawSetTooltip(self, title, lines, icon, dontSetOwner)
	if not dontSetOwner then GameTooltip:SetOwner(self, self.tooltipAnchor or "ANCHOR_LEFT") end
	setTooltip(self, title, lines, icon)
end

---@class TooltipOptions
---@field updateOnClick boolean?
---@field delay (integer | function)?
---@field forced boolean?
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
		if not SpellCreatorMasterTable.Options["showTooltips"] and not self.tooltipForced then return end
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
	if not SpellCreatorMasterTable.Options["showTooltips"] and not self.tooltipForced then return end
	GameTooltip_Hide()
	if timer then
		timer:Cancel()
	end
end

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
		if options.forced then
			frame.tooltipForced = true
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

---@class Utils_Tooltip
ns.Utils.Tooltip = {
	set = set,

	genTooltipText = genTooltipText,
	genContrastText = genContrastText,
	createDoubleLine = createDoubleLine,

	applyStyle = stylizeTooltipText,
	replaceTags = replace_text_tags,

	tag = getTooltipTag,

	setAceTT = setAceTT,

	rawSetTooltip = rawSetTooltip,
}
