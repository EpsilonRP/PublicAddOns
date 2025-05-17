local EpsilonLib, EpsiLib = ...

-- EpsiLib Generic Config Menu, powered by AceConfig because easy & modular.
-- Add more modules to the config menu by adding them to the myOptionsTable.plugins table.

if not LibStub then error("LibStub Required. Why isn't it here?") end

local AceConfig = LibStub:GetLibrary("AceConfig-3.0")
local AceConfigDialog = LibStub:GetLibrary("AceConfigDialog-3.0")
local AceConfigRegistry = LibStub:GetLibrary("AceConfigRegistry-3.0")


local addonVersion, addonAuthor = GetAddOnMetadata(EpsilonLib, "Version"), "Epsilon Addons Team"

---@param table table The table we want to inspect in WoW's table inspector
function tinspect(table)
	UIParentLoadAddOn("Blizzard_DebugTools");
	DisplayTableInspectorWindow(table);
end

-------------------------------------------------------------------------------
-- Interface Options - Addon section
-------------------------------------------------------------------------------

---@param info table
local function genericGet(info)
	local key = info.arg
	return EpsiLib_DB.options[key]
end

---@param info table
---@param val string|boolean
---@param func function callback function to add on after doing the set
local function genericSet(info, val, func)
	local key = info.arg
	EpsiLib_DB.options[key] = val
	if func then func(val) end
end

---@param info table
local function genericGetModule(info)
	local key = info.arg
	return EpsiLib_DB.Modules[key]
end

---@param info table
---@param val string|boolean
---@param func function callback function to add on after doing the set
local function genericSetModule(info, val, func)
	local key = info.arg
	EpsiLib_DB.Modules[key] = val
	if func then func(val) end
end

local function inlineHeader(text)
	return WrapTextInColorCode(text, "ffFFD700")
end

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

local function spacer(order, size)
	local item = {
		name = " ",
		type = "description",
		order = order or autoOrder(),
		fontSize = size or "medium",
	}
	return item
end

local function divider(order)
	local item = {
		name = " ",
		type = "header",
		order = order or autoOrder(),
	}
	return item
end

StaticPopupDialogs["EPSILONLIB_CONFIG_RELOAD_REQUIRED"] = {
	text = "Toggling a module requires a UI reload to take effect.\n\rReload now?",

	OnAccept = function()
		ReloadUI()
	end,
	button1 = OKAY,
	button2 = CANCEL,
	timeout = 0,
	whileDead = 1,
};

--
-- Addon Command Log Tab Stuff
--

local GAME_GOLD = CreateColorFromHexString("FFFFD700")

local addonLogSTObject
local addonLogSTColumns = {
	{ name = "Time",    width = 70,  defaultsort = "dsc", sortnext = 2,      hcolor = GAME_GOLD },
	{ name = "ID",      width = 40,  defaultsort = "dsc", hcolor = GAME_GOLD },
	{ name = "Command", width = 360, hcolor = GAME_GOLD },
	{ name = "Status",  width = 80,  hcolor = GAME_GOLD },
}

addonLogSTObject = LibStub("ScrollingTable"):CreateST(addonLogSTColumns, 20, 16, nil, UIParent)
addonLogSTObject:Hide()
local addonLogSTFrame = addonLogSTObject.frame

addonLogSTObject:RegisterEvents({
	OnEnter = function(rowFrame, cellFrame, data, cols, row, realrow, column, stSelf)
		if data[realrow] and data[realrow].tooltip then
			GameTooltip:SetOwner(cellFrame, "ANCHOR_TOPLEFT")
			GameTooltip:SetText(data[realrow].tooltip, nil, nil, nil, nil, true)
			GameTooltip:Show()
		end
	end,
	OnLeave = function() GameTooltip:Hide() end,
	OnClick = function(rowFrame, cellFrame, data, cols, row, realrow, column, stSelf)
		if IsShiftKeyDown() then
			local link = data[realrow].cols[3].value

			if not ChatEdit_InsertLink("." .. link) then
				ChatFrame_OpenChat("." .. link);
			end
		end
	end,
})

local commandStatusOpcodes = {
	o = "Success",
	f = "Error",
	a = "Received...",
	m = "Processing...",
	s = "Sent...",
	MANUAL = "Manual",
}

local tooltipTextFormat = [[
Source: %s
ID: %s / %s

Results:
%s
]]

local addonLogUpdateData
addonLogUpdateData = function()
	if addonLogSTObject and addonLogSTFrame:IsShown() then
		if not EpsiLib.AddonCommands._CommandLogUpdate then EpsiLib.AddonCommands._CommandLogUpdate = addonLogUpdateData end
		local commandLog = EpsiLib.AddonCommands._CommandLog
		-- Refresh table data
		local data = {}
		for i = #commandLog, 1, -1 do
			local entry = commandLog[i]
			tinsert(data, {
				cols = {
					{ value = date("%H:%M:%S", entry.time) },
					{ value = entry.realID or entry.id },
					{ value = entry.command },
					{ value = commandStatusOpcodes[entry.status] or "Unknown" },
				},
				tooltip = tooltipTextFormat:format(entry.name, entry.realID, entry.id, ((entry.status == "MANUAL") and "Cannot Track Manual Results") or table.concat(entry.returnMessages or {}, "\n")),
			})
		end
		addonLogSTObject:SetData(data)
	end
end


-- Recursively search the children for a userdata key match
local function FindAceGUIWidgetByUserdataKey(root, targetKey)
	if type(root) ~= "table" or not root.children then return nil end

	for _, child in ipairs(root.children) do
		if type(child) == "table" and child.userdata then
			local udata = child.userdata
			if udata and udata[#udata] == targetKey then
				return child
			end
		end

		-- Recurse deeper
		local result = FindAceGUIWidgetByUserdataKey(child, targetKey)
		if result then return result end
	end

	return nil
end

-- Usage: pass in your app name and field name
local function GetAnchorWidget(appName, fieldName)
	local blizOpts = AceConfigDialog.BlizOptions
	local appGroup = blizOpts and blizOpts[appName] and blizOpts[appName][appName]
	if not appGroup then return nil end

	return FindAceGUIWidgetByUserdataKey(appGroup, fieldName)
end


local myOptionsTable = {
	name = "Epsilon AddOns - General Settings" .. " (v" .. addonVersion .. ")",
	type = "group",
	childGroups = "tab",
	args = {
		generalOptions = {
			name = "General Settings",
			type = "group",
			order = autoOrder(true),
			args = {
				miscOptionsSection = {
					name = "Miscellaneous Options",
					type = "group",
					order = autoOrder(),
					inline = true,
					args = {
						forceEntityLoD = {
							name = "Force Entity LoD Distance",
							desc =
							"Higher values increase the distance before an object switches to a lower detail (LoD) model / textures, allowing you to see 'fully quality' models from further away.\n\rSet to 0 to disable the override.",
							type = "range",
							min = 0,
							max = 1000,
							step = 1,
							get = genericGet,
							set = function(info, value)
								value = tonumber(value)
								if value == 0 then value = false end
								EpsiLib_DB.options.forceEntityLoD = value
								if value then
									SetCVar("EntityLodDist", value)
								end
							end,
							arg = "forceEntityLoD",
							order = autoOrder(),
						},
						rippleDetail = {
							name = "Ripple Detail",
							desc = "Adjust rippleDetail to improve performance with minor loss of water quality",
							type = "range",
							min = 0,
							max = 3,
							step = 1,
							get = genericGet,
							set = function(info, value)
								EpsiLib_DB.options.rippleDetail = value
								SetCVar("rippleDetail", value)
							end,
							arg = "rippleDetail",
							order = autoOrder(),
						},
					},
				},
			},
		},
	},
	plugins = {
		['Modules'] = {
			modGroup = {
				name = "Integrated Modules",
				type = "group",
				order = autoOrder(true),
				args = {
					SpellBookUI = {
						name = "SpellBookUI",
						desc =
						"Toggle the SpellBookUI module\n\rThis module is an expansion for the default Spellbook UI that adds a searchbar, and right-click menus to spells for additional options.\n\rSpellBookUI is based on by SpellBookSearch by Kerbaal for the Searchbar, modified to expand features & fix casting spells directly.",
						type = "toggle",
						get = genericGetModule,
						set = function(info, val)
							genericSetModule(info, val,
								function() StaticPopup_Show('EPSILONLIB_CONFIG_RELOAD_REQUIRED') end)
						end,
						arg = "SpellBookUI",
						order = autoOrder(),
					},
				},
			},
			addonCommandsLogTab = {
				name = "Command Log",
				type = "group",
				order = autoOrder(true),
				args = {
					logHeader = {
						type = "description",
						fontSize = "large",
						order = autoOrder(),
						name = function(info)
							--tinspect(info)
							local appName = info.appName
							local pathKey = info[#info]

							C_Timer.After(0, function()
								local anchorWidget = GetAnchorWidget(appName, pathKey)
								local anchorWidgetFrame = anchorWidget.frame
								local anchorParent = anchorWidget.parent
								local anchorParentFrame = anchorParent.frame

								if not anchorWidget or not addonLogSTObject then return end

								local origOnRelease = anchorWidget.events["OnRelease"]
								anchorWidget:SetCallback("OnRelease", function(...)
									origOnRelease(...)
									addonLogSTObject:Hide()
									addonLogSTFrame:SetParent(nil)
								end)

								if addonLogSTObject then
									addonLogSTFrame:SetParent(anchorWidgetFrame)
									addonLogSTFrame:SetPoint("CENTER", anchorParentFrame, "CENTER", 0, -40)
									addonLogSTObject:Show()

									-- Refresh table data
									addonLogUpdateData()
								end
							end)

							return inlineHeader("Command Log")
						end,
					},
					logHints = {
						type = "description",
						fontSize = "medium",
						order = autoOrder(),
						name = "This log tracks all commands (including AddOn Commands) for debug & transparency.\n\rClick a Column Header to sort by that column (default: Sorted by newest (ID) on top).\n\rShift + Click a Command to insert it to your chatbox.",
					},
					logPlaceholder = {
						type = "description",
						order = autoOrder(),
						name = " ",
						image = "interface/containerframe/cosmeticiconborder",
						imageWidth = 1,
						imageHeight = 360,
						imageCoords = { 0, 0.01, 0, 0.01 },
					},
					UseACSForManualCommands = {
						name = "Use AddOn Commands for Manual Commands (READ DESCRIPTION)",
						desc =
						"Use the AddOn Commands system for manual commands.\n\rThis allows the Command Log to track Manual Command replies, but may cause issues with some commands that are not designed to be used this way.\n\rWARNING: This is not compatible with the '.Command Channel' system; all command replies will be returned in the System Messages channel.",
						type = "toggle",
						width = "full",
						get = genericGet,
						set = genericSet,
						arg = "UseACSForManualCommands",
						order = autoOrder(),
					},
				},
			}
		}
	}
}

EpsiLib.ConfigMenuPlugins = myOptionsTable.plugins

local function newOptionsInit()
	AceConfig:RegisterOptionsTable(EpsilonLib, myOptionsTable)
	local frame = AceConfigDialog:AddToBlizOptions(EpsilonLib, "* Epsilon AddOns")

	EpsiLib.ConfigMenuFrame = frame
	function frame:NotifyChange()
		AceConfigRegistry:NotifyChange(EpsilonLib)
	end

	function frame:AddPluginOptions(name, optionsTable)
		myOptionsTable.plugins[name] = optionsTable
	end
end

local registerForAddonDataLoaded
function registerForAddonDataLoaded(_, event, addonName, containsBindings)
	if addonName ~= EpsilonLib then return end

	newOptionsInit()

	-- Run anything here you need to load default values into the config options
	local onLoads = {
		{ -- Force set the Entity LoD Distance when we load in
			name = "forceEntityLoD",
			func = function()
				if EpsiLib_DB.options.forceEntityLoD then
					SetCVar("EntityLodDist", EpsiLib_DB.options.forceEntityLoD)
				end
			end
		},
	}

	local funcs = {}
	for k, v in ipairs(onLoads) do
		if v.func then
			table.insert(funcs, v.func)
		end
	end
	C_Timer.After(0, function() for k, v in ipairs(funcs) do v() end end)
	C_Timer.After(5, function() for k, v in ipairs(funcs) do v() end end)

	-- Remove our hook
	EpsiLib.EventManager:Remove(registerForAddonDataLoaded, "ADDON_LOADED")
end

EpsiLib.EventManager:Register("ADDON_LOADED", registerForAddonDataLoaded)


SLASH_EPSILONLIB_ACL1 = "/acl"
SlashCmdList["EPSILONLIB_ACL"] = function()
	-- Open the Blizzard options to our addon
	InterfaceOptionsFrame_OpenToCategory(EpsiLib.ConfigMenuFrame)
	InterfaceOptionsFrame_OpenToCategory(EpsiLib.ConfigMenuFrame) -- Called twice due to Blizzard bug

	-- Try to select the Addon Commands Log tab
	local appName = EpsilonLib
	local tabKey = "addonCommandsLogTab"

	AceConfigDialog:SelectGroup(appName, tabKey)
end
