-------------------------------------
--- EXAMPLE 1: Attaching to a Button
-------------------------------------
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
LibScrollableDropdown:AttachToButton(btn, menuData, "BOTTOMLEFT", nil, 0, 0, "RightButton")


--------
--- EXAMPLE 2: Open manually
--------

local additional_tools = {
	LibScrollableDropdown:CreateTitle("More Tools"),
	LibScrollableDropdown:CreateDivider(),
}

local lastToolUsedData
local function openMoreToolsMenu(frame)
	local button = GetMouseButtonClicked() -- allows us to know what button was clicked without OnClick, i.e., in a MouseDown, and not change how we support it

	if button == "RightButton" and lastToolUsedData then
		lastToolUsedData[2](unpack(lastToolUsedData, 3))
		return
	end

	-- generate module dropdown here from the additional_tools, dynamic so new ones can be added by other addons or modules
	LibScrollableDropdown:Open(frame, additional_tools)
end

btn:SetScript("OnClick", function(self)
	openMoreToolsMenu(self)
end)
