local ADDON_NAME = ...
---@class ns
local ns = select(2, ...)

local Constants = ns.Constants
local Colors = Constants.colors
local Utils = ns.Utils
local cmd = Utils.cmd
local cmdChain = Utils.cmdChain
local op_cmd = Utils.op_cmd
local clearMsg = Utils.clearMsg


--#region Vis Menu
local staticList = {
	{ text = "Select a Visibility", isTitle = true },
	{ text = "Ultra Low (5)",       func = OPSetObjVis, arg1 = 5 },
	{ text = "Super Low (10)",      func = OPSetObjVis, arg1 = 10 },
	{ text = "Very Low (50)",       func = OPSetObjVis, arg1 = 50 },
	{ text = "Low (100)",           func = OPSetObjVis, arg1 = 100 },
	{ text = "Medium (300)",        func = OPSetObjVis, arg1 = 300 },
	{ text = "High (533)",          func = OPSetObjVis, arg1 = 533 },
	{ text = "Permanent (-1)",      func = OPSetObjVis, arg1 = "-1" },
	{ text = "None/Reset (0)",      func = OPSetObjVis, arg1 = "0" },
	{
		text = "Custom",
		func = function()
			EpsilonLib.Utils.GenericDialogs.CustomInput({
				text = "Set Object Visibility Distance:",
				subText = "Range: 0 - 533",
				exclusive = true,
				callback = function(text)
					cmd(("gobject set vis %s"):format(text), true)
				end,
				expandedNumeric = true,
				acceptText = "Apply Vis",
				maxLetters = 4,
				customValidation = function(text)
					if text == "" then return false end
					local num = tonumber(text)
					if not num then return false end
					if num == -1 then return true end
					if num < 0 or num > 533 then -- must be between 0 and 533 for vis
						return false
					end
					return true
				end
			})
		end,
	},
}

local function OPSetObjVis(_, num)
	local cmdPref
	if isGroupSelected then cmdPref = "gobject group" else cmdPref = "gobject set" end
	cmd(cmdPref .. " vis " .. num, true)
end

local visOption = {
	text = "Visibility",
	tooltipText = "Set Visibility of Selected Object",
	subMenu = staticList,
	disabled = function()
		local selected = EpsilonLib.GameObject:GetSelected()
		if not selected then return true end
	end
}
ns.AddTool({ visOption })
--#endregion

--#region Anim Menu
local staticList = {
	{ text = "Select an Animation", isTitle = true },
	{ text = "0 - Stand (Default)", func = OPSetObjAnim, arg1 = 0 },
	{ text = "145 - Spawn",         func = OPSetObjAnim, arg1 = 145 },
	{ text = "146 - Close",         func = OPSetObjAnim, arg1 = 146 },
	{ text = "147 - Closed",        func = OPSetObjAnim, arg1 = 147 },
	{ text = "148 - Open",          func = OPSetObjAnim, arg1 = 148 },
	{ text = "149 - Opened",        func = OPSetObjAnim, arg1 = 149 },
	{ text = "150 - Destroy",       func = OPSetObjAnim, arg1 = 150 },
	{ text = "157 - Despawn",       func = OPSetObjAnim, arg1 = 157 },
	{
		text = "Custom",
		func = function()
			EpsilonLib.Utils.GenericDialogs.CustomInput({
				text = "Animation:",
				exclusive = true,
				callback = function(text)
					cmd(("gobject anim %s"):format(text), true)
				end,
				isNumeric = true,
				acceptText = "Apply Anim",
				maxLetters = 60
			})
		end,
	},
}

local function OPSetObjAnim(_, num)
	cmd("gobject anim " .. num, true)
end

local animOption = {
	text = "Animation",
	tooltipText = "Set Anim on Selected Object",
	subMenu = staticList,
	disabled = function()
		local selected = EpsilonLib.GameObject:GetSelected()
		if not selected then return true end
	end
}
ns.AddTool({ animOption })
--#endregion

--#region Activate Object

local function activateObject(frame, arg1, arg2, entry, button)
	local selected = EpsilonLib.GameObject:GetSelected()
	if not selected then return end
	local forceName, forceFunc

	local commandStr = "gobject activate"
	if button == "RightButton" then
		commandStr = commandStr .. " permanent"
		forceName = "Activate Object (Permanent)"
		forceFunc = function()
			cmd(commandStr, true)
		end
	end

	cmd(commandStr, true)

	return forceName, forceFunc
end

local activateOption = {
	text = "Activate Object",
	tooltipText = "Activate the selected object\nRight-Click to activate permanent (persists through restarts)",
	func = activateObject,
	disabled = function()
		local selected = EpsilonLib.GameObject:GetSelected()
		if not selected then return true end
	end,
	registerForRightClick = true,
}
ns.AddTool({ activateOption })

--#endregion

--#region Toggle Highlight

local togHighlightOption = {
	text = "Toggle Highlight Selected",
	tooltipText = "Toggles highlighting selected objects.\r\nUseful if selecting large groups of objects, as it can cause the game to crash if too many objectts are highlighted at once.",
	func = function()
		cmd("toggle highlight", true)
	end,
}
ns.AddTool({ togHighlightOption })

--#endregion
