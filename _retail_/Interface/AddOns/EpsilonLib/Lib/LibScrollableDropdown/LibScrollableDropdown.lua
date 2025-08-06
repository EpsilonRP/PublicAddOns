local LibScrollableDropdown = {}
LibScrollableDropdown.__index = LibScrollableDropdown

local VERSION = 1
local lib = LibStub:NewLibrary("LibScrollableDropdown", VERSION)
if not lib then return end

local menuPool, itemPool, activeMenus = {}, {}, {}

local MENU_BASE_WIDTH = 125 -- minimum width fallback
local MENU_ITEM_HEIGHT = 20
local MAX_MENU_HEIGHT = 300

local LEFT_ICON_WIDTH = 14
local RIGHT_ICON_WIDTH = 12
local TEXT_PADDING_LEFT = 4
local TEXT_PADDING_RIGHT = 10
local BUTTON_SIDE_PADDING = 4 -- Padding between button edges and inner content

-- Process dynamic fields
local function resolve(v, ...)
	if type(v) == "function" then
		return v(...)
	else
		return v
	end
end

local unresolvableFields = {
	func = true,
}
local function resolveEntry(entry)
	local out = {}
	for k, v in pairs(entry) do
		if unresolvableFields[k] then
			out[k] = v
		else
			out[k] = resolve(v)
		end
	end
	return out
end

-- Create menu frame
local numFrames = 0
local function CreateMenuFrame()
	numFrames = numFrames + 1
	local frame = CreateFrame("Frame", "LibScrollableDropdownMenu" .. numFrames, UIParent, "BackdropTemplate")
	frame:SetBackdrop({
		bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		edgeSize = 8,
		insets = { left = 2, right = 2, top = 2, bottom = 2 },
	})
	frame:SetSize(MENU_BASE_WIDTH, 10)
	frame:SetFrameStrata("TOOLTIP")
	frame:EnableMouse(true)
	frame:SetToplevel(true)
	frame:SetClampedToScreen(true)
	frame.items = {}
	frame.scroll = CreateFrame("ScrollFrame", nil, frame, "UIPanelScrollFrameTemplate")
	frame.scroll:SetPoint("TOPLEFT", 0, -4)
	frame.scroll:SetPoint("BOTTOMRIGHT", -4, 4)
	frame.scrollChild = CreateFrame("Frame", nil, frame.scroll)
	frame.scrollChild:SetSize(MENU_BASE_WIDTH, 10)
	frame.scroll:SetScrollChild(frame.scrollChild)
	return frame
end

-- Create button
local function CreateMenuItem()
	local btn = CreateFrame("Button", nil, UIParent)
	btn:SetHeight(MENU_ITEM_HEIGHT)
	btn:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight")
	btn.leftIcon = btn:CreateTexture(nil, "ARTWORK")
	btn.leftIcon:SetSize(14, 14)
	btn.leftIcon:SetPoint("LEFT", 4, 0)
	btn.leftIcon:Hide()
	btn.check = btn:CreateTexture(nil, "OVERLAY")
	btn.check:SetSize(16, 16)
	btn.check:SetPoint("LEFT", 0, 0)
	btn.check:SetTexture("Interface\\Buttons\\UI-CheckBox-Check")
	btn.check:Hide()
	btn.text = btn:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	btn.text:SetPoint("LEFT", btn.leftIcon, "RIGHT", 4, 0)
	btn.text:SetJustifyH("LEFT")
	btn.rightIcon = btn:CreateTexture(nil, "ARTWORK")
	btn.rightIcon:SetSize(12, 12)
	btn.rightIcon:SetPoint("RIGHT", -10, 0)
	btn.rightIcon:SetTexture("Interface\\ChatFrame\\ChatFrameExpandArrow")
	btn.rightIcon:Hide()
	return btn
end

-- Reset menu for reuse
local function ResetMenu(menu)
	for _, item in ipairs(menu.items) do
		item:Hide()
		item.subMenuFrame = nil
		item._info = nil
		tinsert(itemPool, item)
	end
	wipe(menu.items)
	menu:Hide()
	menu:ClearAllPoints()
end

function lib:Close(menu)
	ResetMenu(menu)
	if menu.parent == lib.currentParent then
		-- top level menu, reset currentParent
		lib.currentParent = nil
	end
	tDeleteItem(activeMenus, menu)
	tinsert(menuPool, menu)
end

function lib:CloseAll()
	for _, menu in ipairs(activeMenus) do ResetMenu(menu) end
	wipe(activeMenus)
	lib.currentParent = nil
end

function lib:IsMenuOpen(menu)
	return tIndexOf(activeMenus, menu) ~= nil
end

function lib:CloseSubMenus()
	for _, menu in ipairs(activeMenus) do
		if menu ~= lib.currentParent then
			ResetMenu(menu)
			tDeleteItem(activeMenus, menu)
			tinsert(menuPool, menu)
		end
	end
end

function lib:Open(parent, menuData, anchor, anchor2, x, y, isSubMenu)
	if not isSubMenu then
		self:CloseAll()
		lib.currentParent = parent -- only update for primary opens, don't update for submenus
	end
	local menu = tremove(menuPool) or CreateMenuFrame()
	menu.maxItemWidth = MENU_BASE_WIDTH
	menu.parent = parent
	menu:SetClampedToScreen(true)


	if isSubMenu and parent then
		local parentLevel = parent:GetFrameLevel()
		menu:SetFrameLevel(parentLevel + 10)                     -- Ensure it's above the parent
		menu:SetClampedToScreen(false)
		menu._topParent = menu.parent._topParent or menu.parent.parent -- save the highest level parent for reference. This is usually the dropdown menu or button.
	end

	menu:ClearAllPoints()
	menu:SetPoint(anchor or "TOPLEFT", parent, anchor2 or (anchor or "TOPRIGHT"), x or 0, y or 0)
	menu:Show()

	menuData = resolve(menuData) -- Allow menuData to also be a generator func

	local lastButton
	local totalHeight = 0
	for i, entry in ipairs(menuData) do
		repeat -- we're gonna use repeat here to allow break to early exit iterations as needed
			local entry = resolveEntry(entry)
			if not entry then error("Invalid Dropdown Entry " .. i) end
			if entry.hidden then break end

			if entry.menuTable and not entry.subMenu then entry.subMenu = entry.menuTable end

			local itemHeight = (entry.isDivider and 8) or entry.height or MENU_ITEM_HEIGHT
			local itemWidth = MENU_BASE_WIDTH
			local item

			if entry.customFrame then
				item = item
				itemHeight = item:GetHeight()
				itemWidth = item:GetWidth()
				item:SetParent(menu.scrollChild)

				-- Anchor to previous button, or to the top of the dropdown if none existed yet
				item:SetPoint("TOPLEFT", lastButton or menu.scrollChild, lastButton and "BOTTOMLEFT" or "TOPLEFT", lastButton and 0 or BUTTON_SIDE_PADDING, 0)
			else
				item = tremove(itemPool) or CreateMenuItem()
				item:SetParent(menu.scrollChild)

				-- Anchor to previous button, or to the top of the dropdown if none existed yet
				item:SetPoint("TOPLEFT", lastButton or menu.scrollChild, lastButton and "BOTTOMLEFT" or "TOPLEFT", lastButton and 0 or BUTTON_SIDE_PADDING, 0)
				item:SetPoint("RIGHT", -BUTTON_SIDE_PADDING, 0)
				item:SetHeight(itemHeight)

				item.text:SetText(entry.text or "")
				item.rightIcon:SetShown(entry.subMenu ~= nil or entry.hasArrow)

				item.check:SetShown(entry.checked and not entry.notCheckable)
				item.leftIcon:SetShown((entry.icon or entry.isDivider) ~= nil)
				if entry.icon then item.leftIcon:SetTexture(entry.icon) end

				-- Reset positions
				item.check:ClearAllPoints()
				item.leftIcon:ClearAllPoints()
				item.text:ClearAllPoints()

				-- Base offsets
				local paddingLeft = 4
				local spacing = 4

				-- Layout logic
				if item.check:IsShown() then
					item.check:SetPoint("LEFT", paddingLeft, 0)

					if item.leftIcon:IsShown() then
						item.leftIcon:SetPoint("LEFT", item.check, "RIGHT", spacing, 0)
						item.leftIcon:SetHeight(14)
						item.text:SetPoint("LEFT", item.leftIcon, "RIGHT", spacing, 0)
					else
						item.text:SetPoint("LEFT", item.check, "RIGHT", spacing, 0)
					end
				else
					if item.leftIcon:IsShown() then
						item.leftIcon:SetPoint("LEFT", paddingLeft, 0)
						item.text:SetPoint("LEFT", item.leftIcon, "RIGHT", spacing, 0)
					else
						item.text:SetPoint("LEFT", paddingLeft, 0)
					end
				end

				-- Default font fallbacks
				local defaultFont = "GameFontHighlightSmall"
				local defaultHighlightFont = "GameFontNormalSmall"

				-- Apply custom font if provided
				if entry.fontObject then
					item.text:SetFontObject(entry.fontObject)
				else
					item.text:SetFontObject(defaultFont)
				end

				if entry.colorCode then item.text:SetText("|c" .. entry.colorCode .. entry.text .. "|r") end
				if entry.justifyH then item.text:SetJustifyH(entry.justifyH) end

				if entry.disabled then
					item:Disable()
					item.text:SetTextColor(0.5, 0.5, 0.5)
				elseif entry.notClickable then
					item:Disable()
				elseif entry.isTitle then
					item.text:SetFontObject(defaultHighlightFont)
					item:Disable()
				elseif entry.isDivider then
					item.text:SetText(" ")
					item:Disable()
					--item.leftIcon:SetTexture("Interface\\Common\\UI-TooltipDivider-Transparent")
					item.leftIcon:SetAtlas("CovenantSanctum-Renown-Title-Divider-Kyrian")
					item.leftIcon:SetDesaturation(0.9)
					item.leftIcon:Show()
					item.leftIcon:SetPoint("LEFT", BUTTON_SIDE_PADDING, 0)
					item.leftIcon:SetPoint("RIGHT", -BUTTON_SIDE_PADDING, 0)
					item.leftIcon:SetHeight(4)
				else
					item:SetScript("OnClick", function(_, button)
						if entry.subMenu and not entry.func then return end -- Don't close if subMenu & no func
						if entry.func then entry.func(item, entry.arg1, entry.arg2, entry, button) end
						if not entry.ignoreAsMenuSelection then
							local dropdownMain = menu._topParent or menu.parent
							if dropdownMain.Text then dropdownMain:SetText(item._info.text) end
							dropdownMain.value = item._info.value or item._info.text
						end

						if not entry.keepShownOnClick then self:CloseAll() end
					end)

					if entry.registerForRightClick then
						item:RegisterForClicks("LeftButtonUp", "RightButtonUp")
					else
						item:RegisterForClicks("LeftButtonUp")
					end

					item:Enable()
				end

				item:SetScript("OnEnter", function()
					-- Close any other submenus from the same level
					for _, sibling in ipairs(menu.items) do
						if sibling ~= item and sibling.subMenuFrame and sibling.subMenuFrame:IsShown() then
							sibling.subMenuFrame:Hide()
							sibling.subMenuFrame = nil
						end
					end

					-- If this entry has a submenu, open it
					if entry.subMenu and not item.subMenuFrame then
						-- Open submenu initially to the right
						local subMenu = self:Open(item, entry.subMenu, "TOPLEFT", "TOPRIGHT", 0, 0, true)
						subMenu._parentMenu = menu
						subMenu._parentItem = item
						--subMenu:Raise()

						-- If it would go off-screen, reanchor it to the left
						local screenWidth = GetScreenWidth()
						local subRight = subMenu:GetRight()

						if subRight and subRight > screenWidth then
							-- Reanchor to the left
							subMenu:ClearAllPoints()
							subMenu:SetPoint("TOPRIGHT", item, "TOPLEFT", 0, 0)
						end

						-- clamp it back to the screen
						subMenu:SetClampedToScreen(true)

						item.subMenuFrame = subMenu
					end

					-- Tooltip setup (keep if you have one)
					if entry.tooltipTitle or entry.tooltipText then
						GameTooltip:SetOwner(item, "ANCHOR_RIGHT")
						GameTooltip:SetText(entry.tooltipTitle or entry.text, 1, 1, 1)
						if entry.tooltipText then GameTooltip:AddLine(entry.tooltipText, nil, nil, nil, true) end
						GameTooltip:Show()
					end
				end)

				item:SetScript("OnLeave", function()
					if entry.tooltipTitle or entry.tooltipText then
						GameTooltip:Hide()
					end
				end)
			end

			item._info = entry
			item._menu = menu

			item:Show()
			tinsert(menu.items, item)

			-- Auto-width calculation
			local textWidth = item.text:GetStringWidth() or 0
			local totalWidth = BUTTON_SIDE_PADDING + textWidth + TEXT_PADDING_LEFT + TEXT_PADDING_RIGHT

			if entry.icon then
				totalWidth = totalWidth + LEFT_ICON_WIDTH
			end
			if entry.subMenu or entry.hasArrow then
				totalWidth = totalWidth + RIGHT_ICON_WIDTH
			end

			menu.maxItemWidth = math.max(menu.maxItemWidth or itemWidth, totalWidth)

			lastButton = item
			totalHeight = totalHeight + itemHeight
		until true
	end

	menu.scrollChild:SetHeight(totalHeight)

	local visibleHeight = math.min(totalHeight + 8, MAX_MENU_HEIGHT)
	menu:SetHeight(visibleHeight)

	-- Calculate final width
	local scrollbarShown = (totalHeight + 8 > MAX_MENU_HEIGHT)
	local scrollbarWidth = scrollbarShown and 26 or 0
	local finalMenuWidth = math.max(menu.maxItemWidth + scrollbarWidth + 2 * BUTTON_SIDE_PADDING, MENU_BASE_WIDTH)

	menu:SetWidth(finalMenuWidth)
	menu.scrollChild:SetWidth(finalMenuWidth - scrollbarWidth)


	-- Hide scrollbar if not needed
	if scrollbarShown then
		menu.scroll.ScrollBar:Show()
		if menu.scroll.ScrollBarThumb then menu.scroll.ScrollBarThumb:Show() end
		-- Anchor scrollChild with room for scrollbar
		menu.scroll:SetPoint("BOTTOMRIGHT", -26, 4)
	else
		menu.scroll.ScrollBar:Hide()
		if menu.scroll.ScrollBarThumb then menu.scroll.ScrollBarThumb:Hide() end
		-- Reclaim full width
		menu.scroll:SetPoint("BOTTOMRIGHT", -4, 4)
	end

	menu.menuData = menuData

	tinsert(activeMenus, menu)
	return menu
end

function lib:AttachToButton(button, menuData, anchor, anchor2, xOff, yOff, mouseButton)
	button:SetScript("OnClick", function(self, btn)
		if btn ~= (mouseButton or "LeftButton") then return end
		if lib.currentParent == button then
			lib:CloseAll()
		else
			lib:Open(button, menuData, anchor or "TOPLEFT", anchor2 or "TOPRIGHT", xOff or 0, yOff or 0)
		end
	end)
end

-- Close on click outside
hooksecurefunc("UIDropDownMenu_HandleGlobalMouseEvent", function(button, event)
	if lib.currentParent and lib.currentParent:IsMouseOver() then return end -- Don't handle if we're over the button, let the OnClick handle
	for _, menu in ipairs(activeMenus) do
		if menu:IsMouseOver() then return end
	end
	lib:CloseAll()
end)

-- API Helpers
function lib:CreateTitle(text)
	return { text = text, isTitle = true, notCheckable = true }
end

function lib:CreateDivider()
	return { isDivider = true, notCheckable = true }
end

function lib:CreateButton(text, func, checked)
	return { text = text, func = func, checked = checked }
end

function lib:CreateSubMenu(text, items)
	return { text = text, subMenu = items }
end

_G.LibScrollableDropdown = lib
