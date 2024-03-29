---@class ns
local ns = select(2, ...)
local addonName = ...
local Constants = ns.Constants
local ver = ns.semver

--[[
Add ## at the start of a line to make it a header style line. Uses SFX Header II widget, so add >>> after ## if you want to center it.
Wrap a section in {} to indent each string inside the array. Indents are only supported to one level, don't try multiple indents.
Use a blank " " for a spacer.
--]]

local versions = {
	{
		ver = "1.0.1b",
		changes = {
			"##>>>Kinesis v1.0.1b - July 15th, 2023",
			"##Bug Fixes:",
			"Added Toggle EFD API"
		}
	},
	{
		ver = "1.0.1",
		changes = {
			"##>>>Kinesis v1.0.1 - June 24th, 2023",
			"##New Features / Changes:",
			"Added a new 'Welcome to Kinesis!' Menu",
			"Changed UI in Flight Settings to be a little more clear what settings do, kinda.",
			"Changed 'Auto-Land Delay' to 0 (disabled) as the default.. Soz",
			" ",
			"##Bug Fixes:",
			"Fixed 'Enable Shift-Sprint' toggle not working.. Also soz.",
			"Fixed Mod Speed messages showing if you have 'Return to Original Speed' disabled.",
			"Fixed Cheat Fly messages bypassing the chat filter when toggled by Kinesis. #ByeSpam!",
		}
	},

	{
		ver = "1.0.0",
		changes = {
			"##>>>Kinesis v1.0.0 - June 21st, 2023",
			"Release",
		}
	},
}

---------------------- AceConfig table generation
local orderGroup = 0
local orderItem = 0
local function autoOrder(isGroup)
	if isGroup then
		orderGroup = orderGroup + 1
		orderItem = 0
		return orderGroup
	else
		orderItem = orderItem + 1
		return orderItem
	end
end

local function genChangeItem(change, subItem)
	local changeItem = {
		order = autoOrder(),
		width = subItem and 1.83 or "full",
	}
	if change:find("^##") then
		changeItem.name = change:gsub("^##", "")
		changeItem.type = "header"
		changeItem.dialogControl = "SFX-Header-II"
	else
		changeItem.name = change
		changeItem.type = "description"
		changeItem.fontSize = "medium"
		if strtrim(change) ~= "" then
			changeItem.image = "interface/questframe/ui-quest-bulletpoint.blp"
			changeItem.imageWidth = 12
			changeItem.imageHeight = 12
		end
	end
	return changeItem
end

local argsTable = {}
local function genChangeLogArgs()
	for k, v in ipairs(versions) do
		local versionTable = {
			name = "v" .. v.ver,
			type = "group",
			order = autoOrder(),
			args = {}
		}
		for i, change in ipairs(v.changes) do
			if type(change) == "table" then
				for j, subchange in ipairs(change) do
					versionTable.args["indent" .. tostring(i) .. "+" .. tostring(j)] = {
						type = "description",
						name = " ",
						order = autoOrder(),
						width = 0.1
					}
					versionTable.args[tostring(i) .. "+" .. tostring(j)] = genChangeItem(subchange, true)
				end
			else
				versionTable.args[tostring(i)] = genChangeItem(change)
			end
		end
		argsTable[v.ver] = versionTable
	end
	return argsTable
end


ns.Changes = {
	genChangeLogArgs = genChangeLogArgs,
}
