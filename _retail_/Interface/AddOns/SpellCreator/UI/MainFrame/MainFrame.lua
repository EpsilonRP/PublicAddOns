---@class ns
local ns = select(2, ...)

local Constants = ns.Constants

local TITLE = Constants.ADDON_TITLE
local TITLE_WITH_CHANGES = Constants.ADDON_TITLE .. "*"

local size = {
	["x"] = 700,
	["y"] = 700,
	["Xmin"] = 550,
	["Ymin"] = 550,
	["Xmax"] = math.min(1100, UIParent:GetHeight()), -- Don't let them resize it bigger than their screen is.. then you can't resize it down w/o using hidden right-click on X button
	["Ymax"] = math.min(1100, UIParent:GetHeight()),

	columnWidths = {
		delay = 80,
		action = 100,
		self = 32,
		inputEntry = 140 + 42,
		revertDelay = 80,
		conditional = 32
	},

	rowHeight = 60,
}

local framesToResizeWithMainFrame = {}

---@param frame Frame
local function setResizeWithMainFrame(frame)
	table.insert(framesToResizeWithMainFrame, frame)
end

---@param frame SCForgeMainFrame
---@return number
local function updateFrameChildScales(frame)
	local n = frame:GetWidth()
	frame:SetHeight(n)
	frame.DragBar:SetWidth(n)
	n = n / size.x
	local childrens = { frame.Inset:GetChildren() }
	for _, child in ipairs(childrens) do
		child:SetScale(n)
	end
	for _, child in pairs(framesToResizeWithMainFrame) do
		child:SetScale(n)
	end
	return n;
end

---@param hasChanges boolean
local function markTitleChanges(hasChanges)
	SCForgeMainFrame:SetTitle(hasChanges and TITLE_WITH_CHANGES or TITLE)
end

---@class SCForgeMainFrame : ButtonFrameTemplate, Frame
---@field conditionsData ConditionDataTable
SCForgeMainFrame = CreateFrame("Frame", "SCForgeMainFrame", UIParent, "ButtonFrameTemplate")
SCForgeMainFrame:SetPoint("CENTER")
SCForgeMainFrame:SetSize(size.x, size.y)
SCForgeMainFrame:SetMaxResize(size.Xmax, size.Ymax)
SCForgeMainFrame:SetMinResize(size.Xmin, size.Ymin)
SCForgeMainFrame:SetMovable(true)
SCForgeMainFrame:SetResizable(true)
SCForgeMainFrame:SetToplevel(true);
SCForgeMainFrame:EnableMouse(true)
SCForgeMainFrame:SetClampedToScreen(true)
SCForgeMainFrame:SetClampRectInsets(300, -300, 0, 500)

markTitleChanges(false)

local titleBgColor = SCForgeMainFrame:CreateTexture(nil, "BACKGROUND")
titleBgColor:SetPoint("TOPLEFT", SCForgeMainFrame.TitleBg)
titleBgColor:SetPoint("BOTTOMRIGHT", SCForgeMainFrame.TitleBg)
titleBgColor:SetColorTexture(Constants.ADDON_COLORS.PERSONAL_VAULT:GetRGBA())

SCForgeMainFrame.TitleBgColor = titleBgColor

local settingsButton = CreateFrame("BUTTON", nil, SCForgeMainFrame, "UIPanelButtonNoTooltipTemplate")
settingsButton:SetSize(24, 24)
settingsButton:SetPoint("RIGHT", SCForgeMainFrame.CloseButton, "LEFT", 4, 0)
settingsButton.icon = settingsButton:CreateTexture(nil, "ARTWORK")
settingsButton.icon:SetTexture("interface/buttons/ui-optionsbutton")
settingsButton.icon:SetSize(16, 16)
settingsButton.icon:SetPoint("CENTER")
settingsButton:SetScript("OnClick", function()
	-- Needs to be called twice because of a bug in Blizzard's frame - the first call will initialize the frame if it's not initialized
	InterfaceOptionsFrame_OpenToCategory(Constants.ADDON_TITLE)
	InterfaceOptionsFrame_OpenToCategory(Constants.ADDON_TITLE)
end)
settingsButton:SetScript("OnMouseDown", function(self)
	local point, relativeTo, relativePoint, xOfs, yOfs = self.icon:GetPoint(1)
	self.icon:SetPoint(point, relativeTo, relativePoint, xOfs + 2, yOfs - 2)
end)
settingsButton:SetScript("OnMouseUp", function(self)
	local point, relativeTo, relativePoint, xOfs, yOfs = self.icon:GetPoint(1)
	self.icon:SetPoint(point, relativeTo, relativePoint, xOfs - 2, yOfs + 2)
end)
settingsButton:SetScript("OnDisable", function(self)
	self.icon:GetDisabledTexture():SetDesaturated(true)
end)
settingsButton:SetScript("OnEnable", function(self)
	self.icon:GetDisabledTexture():SetDesaturated(false)
end)

SCForgeMainFrame.SettingsButton = settingsButton

-- Help Button (Tutorial)

local function normalizedOffset(n)
	return n * UIParent:GetScale()
end
local _n = normalizedOffset

local helpPlate = {
	FramePos = { x = 5, y = -22 },
	FrameSize = { width = 580, height = 500 },

	-- Attic 1 - Spell Info
	{
		ButtonPos = { x = _n(209), y = 10 },
		HighLightBox = { x = _n(65), y = 0, width = 295, height = 35 },
		ToolTipDir = "DOWN",
		ToolTipText =
			"Spell Information" ..
			"\n\rThis section lets you control the basic details of your spell, including the icon, name, description, and ArcID." ..
			"\n\rThe ArcID is a unique identifier for each spell, meaning no two spells can share the same ID."
	},

	-- Attic 2 - Spell Options
	{
		ButtonPos = { x = _n(209 + 295), y = 10 },
		HighLightBox = { x = _n(65) + 295, y = 0, width = 195, height = 35 },
		ToolTipDir = "DOWN",
		ToolTipText =
		"Spell Options\n\rThis section lets you configure additional settings for your spell, such as cooldowns, conditions, and other customizable options."
	},

	-- Forge Action Rows
	{
		ButtonPos = { x = _n(507 / 2), y = _n(-(459 + 46) / 2) },
		HighLightBox = { x = _n(16), y = _n(-46), width = 530, height = 460 },
		ToolTipDir = "LEFT",
		ToolTipText =
			"Action Rows" ..
			"This is the section where you define the steps your spell will take when cast." ..
			"\n\rEach Action requires a Delay, Action Type, and an input (if applicable) to work properly." ..
			"\n\rYou can add more rows by clicking the large + button, or duplicate a row by clicking the smaller + at the top left when hovering over a row."
	},

	-- Basement
	{
		ButtonPos = { x = 390, y = -490 },
		HighLightBox = { x = _n(16), y = _n(-46) - 460, width = 530, height = 27 },
		ToolTipDir = "RIGHT",
		ToolTipText =
		"This is the forge 'Basement', where you can Cast a spell currently edited for testing, Save your current data as a new spell (or save your work if editing), and open your ArcSpell Vaults."
	},

}

local help = CreateFrame("BUTTON", nil, SCForgeMainFrame, "MainHelpPlateButton")
local scale = 0.75
help:SetPoint("TOPLEFT", 32 / scale, 21 * scale)
help:SetScale(scale)
help.I:SetDesaturated(true)
help.I:SetVertexColor(89 / 255, 196 / 255, 217 / 255)
help.Ring:SetTexture(Constants.ASSETS_PATH .. "/" .. "icon_portrait_gold_ring_border")
help.Ring:SetPoint("CENTER")
help.Ring:SetSize(24, 24)
help.Hilight = help:GetHighlightTexture()
help.Hilight:SetSize(36, 36)
help.Hilight:SetPoint("CENTER", 0, -1)
help:HookScript("OnEnter", function(self)
	if HelpPlateTooltip:IsShown() then
		HelpPlateTooltip.Text:SetText(MAIN_HELP_BUTTON_TOOLTIP .. "\nRight-Click to Open the Basic Spell Creation Tutorial!")
		HelpPlateTooltip:SetHeight(HelpPlateTooltip.Text:GetHeight() + 30)
	end
end)
help:SetScript("OnClick", function(self, button, down)
	if button == "RightButton" then
		ns.UI.Tutorials:Show(2)
		return
	else
		if not SCForgeMainFrame:IsShown() then return end
		if HelpPlate_IsShowing(helpPlate) then
			HelpPlate_Hide(true)
		else
			HelpPlate_Show(helpPlate, SCForgeMainFrame, help)
		end
	end
end)
help:RegisterForClicks("LeftButtonUp", "RightButtonUp")

SCForgeMainFrame.MainHelpButton = help


local dragBar = CreateFrame("Frame", nil, SCForgeMainFrame)
dragBar:SetPoint("TOPLEFT")
dragBar:SetSize(size.x, 20)
dragBar:EnableMouse(true)
dragBar:RegisterForDrag("LeftButton")
dragBar:SetScript("OnMouseDown", function(self)
	self:GetParent():Raise()
end)
dragBar:SetScript("OnDragStart", function(self)
	self:GetParent():StartMoving()
end)
dragBar:SetScript("OnDragStop", function(self)
	self:GetParent():StopMovingOrSizing()
end)

SCForgeMainFrame.DragBar = dragBar

local scrollFrame = CreateFrame("ScrollFrame", nil, SCForgeMainFrame.Inset, "UIPanelScrollFrameTemplate")
scrollFrame:SetPoint("TOPLEFT", 0, -35)
scrollFrame:SetPoint("BOTTOMRIGHT", -24, 0)

SCForgeMainFrame.Inset.scrollFrame = scrollFrame

local scrollChild = CreateFrame("Frame")
scrollFrame:SetScrollChild(scrollChild)
scrollChild:SetWidth(SCForgeMainFrame.Inset:GetWidth() - 18)
scrollChild:SetHeight(1)

scrollFrame.scrollChild = scrollChild

scrollFrame.ScrollBar:SetPoint("TOPLEFT", scrollFrame, "TOPRIGHT", 6, 18)
scrollFrame.ScrollBar.scrollStep = size.rowHeight

local resizeDragger = CreateFrame("BUTTON", nil, SCForgeMainFrame)
resizeDragger:SetSize(16, 16)
resizeDragger:SetPoint("BOTTOMRIGHT", -2, 2)
resizeDragger:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
resizeDragger:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
resizeDragger:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
resizeDragger:SetScript("OnMouseDown", function(self, button)
	if button == "LeftButton" then
		local parent = self:GetParent()
		self.isScaling = true
		parent:StartSizing("BOTTOMRIGHT")
	end
end)
resizeDragger:SetScript("OnMouseUp", function(self, button)
	if button == "LeftButton" then
		local parent = self:GetParent()
		self.isScaling = false
		parent:StopMovingOrSizing()
	end
end)

SCForgeMainFrame.ResizeDragger = resizeDragger

SCForgeMainFrame:SetScript("OnSizeChanged", function(self)
	updateFrameChildScales(self)
	local newHeight = self:GetHeight()
	local ratio = newHeight / size.y
	SCForgeMainFrame.LoadSpellFrame:SetSize(280 * ratio, self:GetHeight())
end)

---@param callback fun(width: integer)
local function onSizeChanged(callback)
	SCForgeMainFrame:HookScript("OnSizeChanged", function()
		callback(SCForgeMainFrame:GetWidth())
	end)
end

---@class UI_MainFrame_MainFrame
ns.UI.MainFrame.MainFrame = {
	size = size,

	setResizeWithMainFrame = setResizeWithMainFrame,
	updateFrameChildScales = updateFrameChildScales,
	markTitleChanges = markTitleChanges,
	onSizeChanged = onSizeChanged,
}
