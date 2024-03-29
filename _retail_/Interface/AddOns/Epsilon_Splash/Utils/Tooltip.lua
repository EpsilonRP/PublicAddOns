---@class ns
local ns = select(2, ...)

local timer

---@param title string
local function setTitle(title)
	GameTooltip:SetText(title, nil, nil, nil, nil, true)
end

local function clearLines()
	GameTooltip:ClearLines()
end

---@param line string
local function addLine(line)
	if line:match(strchar(31)) then
		--GameTooltip:AddLine(line, 1, 1, 1, true)
		local line1, line2 = strsplit(strchar(31), line, 2)
		GameTooltip:AddDoubleLine(line1, line2, 1, 1, 1, 1, 1, 1)
	else
		GameTooltip:AddLine(line, 1, 1, 1, true)
	end
end

---Concat the two texts together with a strchar(31) as a delimiter to create a double line.
---@param text1 string
---@param text2 string
---@return string
local function createDoubleLine(text1, text2, r1, g1, b1, r2, g2, b2)

	if r1 and g1 and b1 then
		text1 = CreateColor(r1, g1, b1):WrapTextInColorCode(text1)
	end

	if r2 and g2 and b2 then
		text2 = CreateColor(r2, g2, b2):WrapTextInColorCode(text2)
	end

	return text1 .. strchar(31) .. text2
end

---@param title string | fun(self): string
---@param lines? string[] | string | fun(self): (string[] | string)
local function setTooltip(self, title, lines)
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

	GameTooltip:Show()
end

---Call to directly show a tooltip; this is mostly so you can update / redraw a tooltip live if needed.
---@param title string | fun(self): string
---@param lines? string[] | string | fun(self): (string[] | string)
local function rawSetTooltip(self, title, lines)
	GameTooltip:SetOwner(self, self.tooltipAnchor or "ANCHOR_LEFT")
	setTooltip(self, title, lines)
end

---@class TooltipOptions
---@field updateOnClick boolean?
---@field delay (integer | function)?
---@field anchor string?
---@field predicate function?

---@param title string | fun(self): string
---@param lines? string[] | string | fun(self): (string[] | string)
---@param options? TooltipOptions
local function onEnter(title, lines, options)
	return function(self)
		local delay = options and options.delay or 0
		if type(delay) == "function" then delay = delay(self) end

		if options and options.predicate then
			if not options.predicate(self) then return end
		end

		if timer then timer:Cancel() end

		GameTooltip:SetOwner(self, self.tooltipAnchor or "ANCHOR_LEFT")

		timer = C_Timer.NewTimer(delay, function()
			setTooltip(self, title, lines)
		end)
	end
end

local function onLeave(self)
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
				setTooltip(self, title, lines)
			end)
		end

		if options.anchor then
			frame.tooltipAnchor = options.anchor
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
	createDoubleLine = createDoubleLine,

	setAceTT = setAceTT,

	rawSetTooltip = rawSetTooltip,
}
