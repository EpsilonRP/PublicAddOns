-- Example button
local btn = CreateFrame("Button", "MyDropdownButton", UIParent, "UIPanelButtonTemplate")
btn:SetSize(120, 22)
btn:SetPoint("CENTER")
btn:SetText("Right-Click Me")

-- Dropdown menu data
local function dynamicText() return "Time: " .. date("%H:%M:%S") end
local menuData = {
	{
		text = dynamicText,
		icon = "Interface\\Icons\\inv_misc_questionmark",
		checked = function() return true end,
		func = function() print("Hello clicked") end,
	},
	{
		isDivider = true
	},
	{
		text = "Nested",
		subMenu = {
			{ text = "Sub Item 1", func = function() print("Sub 1") end },
			{ text = "Sub Item 2", func = function() print("Sub 2") end },
		}
	},
	{
		text = "Unchecked Item",
		checked = false,
		func = function() print("Unchecked clicked") end,
	},
}

-- Attach on right-click
LibScrollableDropdown:AttachToButton(btn, menuData, "BOTTOMLEFT", 0, 0, "RightButton")
