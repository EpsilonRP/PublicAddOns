local EpsilonLib, EpsiLib = ...

-- EpsiLib Generic Config Menu, powered by AceConfig because easy & modular.
-- Add more modules to the config menu by adding them to the myOptionsTable.plugins table.

if not LibStub then error("LibStub Required. Why isn't it here?") end

local AceConfig = LibStub:GetLibrary("AceConfig-3.0")
local AceConfigDialog = LibStub:GetLibrary("AceConfigDialog-3.0")
local AceConfigRegistry = LibStub:GetLibrary("AceConfigRegistry-3.0")


local addonVersion, addonAuthor = GetAddOnMetadata(EpsilonLib, "Version"), "Epsilon Addons Team"

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
