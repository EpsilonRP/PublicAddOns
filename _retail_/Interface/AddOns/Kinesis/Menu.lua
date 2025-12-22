---@class ns
local ns = select(2, ...)
local addonName = ...
local Constants = ns.Constants

local addonVersion, addonAuthor, addonTitle = Constants.addonVersion, Constants.addonAuthor, Constants.addonTitle

UIParentLoadAddOn("Blizzard_DebugTools");

local Main = ns.Main
local Dialogs = ns.Dialogs
local Sprint = ns.Sprint
local Flight = ns.Flight

local isNotDefined = ns.Main.isNotDefined

local enableAddon = Main.enableAddon
local disableAddon = Main.disableAddon
local TRIGGER_TYPES = Main.TRIGGER_TYPES

local menuFrame = Main.Kinesis:NewModule("KinesisMenuModule", "AceConsole-3.0")
local AC = Main.AC
local ACD = Main.ACD
local ACR = Main.ACR

local contrastText = Constants.COLORS.CONTRAST_RED

---Generic Get Val Function (from Options Table)
---@param key string
---@param subTable string|table
---@param table string?
local function genericGetFromOptions(key, subTable, table)
	if not table then
		table = KinesisOptions.profiles[KinesisCharOptions.activeProfile]
	else
		table = _G[table]
	end
	if subTable and type(subTable) == "table" then
		for i = 1, #subTable do
			table = table[i]
		end
	elseif subTable then -- not a table, string or number? get the single sub table
		table = table[subTable]
	end
	return table[key]
end

---Easy Function Gen for the genericGetFromOptions function
---@param key string
---@param subTable string|table
---@param table string?
---@return function
local function genGenericGetFromOptions(key, subTable, table)
	local func = function(val)
		return genericGetFromOptions(key, subTable, table)
	end
	return func
end

---Generic Set Value Function..
---@param key string
---@param val any
---@param subTable string?
---@param table string?
local function genericSafeSetVal(key, val, subTable, table)
	if isNotDefined(key) then return end
	if not table then
		table = KinesisOptions.profiles[KinesisCharOptions.activeProfile]
	else
		table = _G[table]
	end
	if subTable and type(subTable) == "table" then
		for i = 1, #subTable do
			table = table[i]
		end
	elseif subTable then -- not a table, string or number? get the single sub table
		table = table[subTable]
	end
	table[key] = val
end

---Easy Function Gen for the genericSafeSetVal function
---@param key string
---@param subTable string?
---@param table string?
---@param callback function?
---@return function
local function genGenericSetFunction(key, subTable, table, callback)
	local func = function(info, val)
		genericSafeSetVal(key, val, subTable, table)
		if callback then callback(info, val) end
		--menuFrame:RefreshMenuForUpdates()
	end
	return func
end

local unsavedPhaseChanges = false
local function markChangesDirty_Phase()
	unsavedPhaseChanges = true
end

local function set(func)
	return function(info, val)
		markChangesDirty_Phase()
		func(val)
	end
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

local function spacer(width, height)
	local item = {
		name = "",
		type = "description",
		order = autoOrder(),
		width = width or nil
	}
	if height then
		item.name = string.rep("\n", height)
	end

	return item
end

local function divider(order)
	local item = {
		name = "",
		type = "header",
		order = order or autoOrder(),
	}
	return item
end

local function g(text)
	return WrapTextInColorCode(text, "ffFFD700")
end

local function w(text)
	return WrapTextInColorCode(text, "ffFFFFFF")
end

local function drDefault(key)
	local defaults = ns.DRSettings.GetDefaults()
	local val = defaults[key]
	if type(val) == "table" then
		val = table.concat(val, ", ")
	end
	return "\n\rDefault: " .. val
end

local function caseInsensitiveCompare(a, b)
	if type(a) == "number" and type(b) == "number" then
		return a < b
	else
		return string.lower(a) < string.lower(b)
	end
end

menuFrame.flight = {}
menuFrame.sprint = {}

local addSpellIDTemp

local firstRunLoadingInterfaceOptions
local options = {
	name = function()
		if not firstRunLoadingInterfaceOptions then
			menuFrame:RefreshMenuForUpdates(); firstRunLoadingInterfaceOptions = true
		end -- This fixes the UI glitches that AceConfig has with tabs.. Fucking stupid.
		return addonTitle .. " (v" .. addonVersion .. ") - /kinesis, /kn"
	end,
	--name = addonTitle .. " (v" .. addonVersion .. ")",
	type = "group",
	childGroups = "tab",
	args = {
		generalOptions = {
			name = "General Settings",
			type = "group",
			order = autoOrder(true),
			args = {
				aboutGroup = {
					name = "",
					type = "group",
					inline = true,
					order = autoOrder(true),
					args = {
						header = {
							type = "header",
							name = ">>>kinesis",
							order = autoOrder(),
							disabled = true,
							dialogControl = "SFX-Header-II",
						},
						definition = {
							type = "header",
							name = ">>>latin, greek: to move, motion, movement",
							order = autoOrder(),
							dialogControl = "SFX-Header-II",
						},
						spacer = spacer(),
						addonDescription = {
							type = "description",
							name =
							"Kinesis brings two missing movement elements from other popular games & genres to Epsilon: On-Demand Sprinting, and Creative-Mode Style Flight controls.\n\rBoth include a bunch of options to customize your experience to what suits you, and include some fun options like being able to cast spells for cool visual effects when sprinting/flying. We hope you enjoy!",
							order = autoOrder(),
						},
						bottomBorder = {
							type = "header",
							name = "",
							dialogControl = "SFX-Header-II",
						}
					},
				},
				globalToggles = {
					name = "Global Toggles",
					type = "group",
					inline = true,
					order = autoOrder(true),
					args = {
						tempDisableNotice = {
							type = "header",
							name = function()
								local tempDisable = ns.Main.getTempDisable()
								if not tempDisable then return "Nothing to see here, move along" end
								if tempDisable.sprint and tempDisable.flight then
									return contrastText:WrapTextInColorCode "Flight & Sprint are temporarily disabled by another AddOn or script."
								elseif tempDisable.sprint then
									return contrastText:WrapTextInColorCode "Sprint is temporarily disabled by another AddOn or script."
								elseif tempDisable.flight then
									return contrastText:WrapTextInColorCode "Flight is temporarily disabled by another AddOn or script."
								end
							end,
							hidden = function() return not (ns.Main.getTempDisable("sprint") or ns.Main.getTempDisable("flight")) end,
							order = autoOrder(),
						},
						restoreTempDisable = {
							type = "execute",
							name = function()
								local tempDisable = ns.Main.getTempDisable()
								if not tempDisable then return "Restore" end
								if tempDisable.sprint and tempDisable.flight then
									return "Restore Flight & Sprint."
								elseif tempDisable.sprint then
									return "Restore Sprint"
								elseif tempDisable.flight then
									return "Restore Flight"
								end
							end,
							desc = "Click to remove the Temporary Disable Override.",
							order = autoOrder(),
							func = function()
								ns.Main.removeTempDisableBoth()
								menuFrame:RefreshMenuForUpdates()
							end,
							hidden = function() return not (ns.Main.getTempDisable("sprint") or ns.Main.getTempDisable("flight")) end,
							width = "full",
						},
						flightToggle = {
							type = "toggle",
							name = "Enable Flight Controls ('Creative Mode')",
							desc =
							"Toggle the Flight Module on/off.\n\rCreative Mode style Flight Controls allow you to use your jump-key to enable and disable flying, instead of typing a command.\n\rBy default, we use similar settings to games like Minecraft - Double Jump to toggle flight on, and double-tap jump again while flying to disable flight. Check out the Flight Settings tab to customize this experience.",
							handler = menuFrame.flight,
							get = "GetFlightToggle",
							set = "SetFlightToggle",
							order = autoOrder(),
							width = 1.75,
						},
						extendedFlightDetection = {
							type = "toggle",
							name = "Extended Flight Detection",
							desc = "When Extended Flight Detection is enabled, Flight Spells toggle based on your current flight status immediately, regardless of Kinesis Flight Controls.\n\rThis also allows Flight Spells to function even if Flight Controls ('Creative Mode') are disabled.",
							get = genGenericGetFromOptions("extendedFlightDetection", "global", "KinesisOptions"),
							set = genGenericSetFunction("extendedFlightDetection", "global", "KinesisOptions", function(info, val) ns.Flight.toggleExtendedFlightDetection(val) end),
							order = autoOrder(),
							width = 1.25,
						},
						sprintToggle = {
							type = "toggle",
							name = "Enable Shift-Sprint",
							desc = "Toggle Shift-Sprint on/off.\n\rShift-Sprint does exactly what it says: Allows you to simply press shift to start sprinting! When done, just release shift and you'll return to whatever speed you previously were at.\n\rBut what good is sprinting if you don't look " ..
								contrastText:WrapTextInColorCode("cool") .. " doing it? So we added support to also trigger Spells (auras) while sprinting.\n\rBut Spells wasn't enough.. So we also included Arcanum Support, so you can morph into a cat, or grow twice in size -- I'm sure you'll think of better ideas! Your possibilities are limitless!",
							handler = menuFrame.sprint,
							get = "GetFullToggle",
							set = "SetFullToggle",
							order = autoOrder(),
							width = 1,
						},
						gap2 = spacer(0.75),
						sprintModeToggle = {
							type = "select",
							name = "Sprint Mode",
							desc = "Switch between Shift-Sprint modes:\n\r" ..
								contrastText:WrapTextInColorCode("Dual") ..
								": The 'best of both worlds'! Tap to Toggle Sprint, or Hold to only sprint until you let go. Adjust the time it takes for tap to turn into hold in Sprint Settings.\n\r" ..
								contrastText:WrapTextInColorCode("Hold") .. ": Sprint activates when pressing Shift, and deactivates when released.\n\r" .. contrastText:WrapTextInColorCode("Toggle") .. ": Sprint activates when you press Shift, and stays active until you press Shift again.",
							values = { toggle = "Toggle", hold = "Hold", dual = "Dual" },
							sorting = { "dual", "hold", "toggle" },
							get = genGenericGetFromOptions("sprintMode", "global", "KinesisOptions"),
							set = genGenericSetFunction("sprintMode", "global", "KinesisOptions"),
							order = autoOrder(),
							width = 1.25,
						},
					},
				},
				profileGroup = {
					name = "Profiles",
					type = "group",
					inline = true,
					order = autoOrder(true),
					args = {
						profileSelect = {
							type = "select",
							name = "Current Profile",
							desc = "Select your current profile.",
							get = function() return Main.getActiveProfile() end,
							set = function(info, val) if val == "addNewProfile" then Dialogs.showNewProfilePopup() else Main.setActiveProfile(val, true) end end,
							values = function()
								local valTable = {}
								for k, v in pairs(KinesisOptions.profiles) do
									if k == "default" then
										valTable[k] = "Default"
									else
										valTable[k] = k
									end
								end
								valTable["addNewProfile"] = CreateAtlasMarkup("communities-icon-addchannelplus", 16, 16) .. " Add New"
								return valTable
							end,
							sorting = function()
								local keys = {}
								for k in pairs(KinesisOptions.profiles) do
									if k ~= "default" and k ~= KinesisCharOptions.activeProfile then
										keys[#keys + 1] = k
									end
								end
								table.sort(keys, caseInsensitiveCompare)
								tinsert(keys, 1, KinesisCharOptions.activeProfile)
								if KinesisCharOptions.activeProfile ~= "default" then
									tinsert(keys, "default")
								end
								--tDeleteItem(keys, "addNewProfile")
								tinsert(keys, "addNewProfile")
								return keys
							end,
							order = autoOrder(),
							width = 1,
						},
						profileResetCurrent = {
							name = "Reset Profile",
							desc = "Resets your currently selected profile to default settings.",
							order = autoOrder(),
							type = "execute",
							func = function()
								ns.Dialogs.showGenericConfirmation("Are you sure you want to reset this profile? (" .. KinesisCharOptions.activeProfile .. ")", function()
									ns.Main.resetProfile(KinesisCharOptions.activeProfile)
									menuFrame:RefreshMenuForUpdates()
								end)
							end,
							width = 1,
						},
						profileDeleteCurrent = {
							name = "Delete Profile",
							desc = "Deletes your currently selected profile.",
							order = autoOrder(),
							type = "execute",
							disabled = function() return KinesisCharOptions.activeProfile == "default" end,
							func = function()
								ns.Dialogs.showGenericConfirmation("Are you sure you want to delete this profile? (" .. KinesisCharOptions.activeProfile .. ")", function()
									ns.Main.deleteProfile(KinesisCharOptions.activeProfile)
									menuFrame:RefreshMenuForUpdates()
								end)
							end,
							width = 1,
						},
						profileCopy = {
							type = "select",
							name = "Copy Profile Settings",
							desc = "Copy Profile Settings from another profile to your current profile.",
							get = function() return "copyProfileSettings" end,
							set = function(info, val)
								if val ~= "copyProfileSettings" then
									ns.Dialogs.showGenericConfirmation("Are you sure you want to overwrite " .. contrastText:WrapTextInColorCode(KinesisCharOptions.activeProfile) .. " with " .. contrastText:WrapTextInColorCode(val) .. "'s settings?", function()
										Main.copyProfileSettings(KinesisCharOptions.activeProfile, val)
										menuFrame:RefreshMenuForUpdates()
									end)
								end
							end,
							values = function()
								local valTable = {
									copyProfileSettings = "Copy Profile Settings",
								}
								for k, v in pairs(KinesisOptions.profiles) do
									if k == "default" then
										valTable[k] = "Default"
									elseif k ~= KinesisCharOptions.activeProfile then -- skip active profile
										valTable[k] = k
									end
								end
								return valTable
							end,
							sorting = function()
								local keys = {}
								for k in pairs(KinesisOptions.profiles) do
									if k ~= KinesisCharOptions.activeProfile and k ~= "copyProfileSettings" then
										keys[#keys + 1] = k
									end
								end
								table.sort(keys, caseInsensitiveCompare)
								return keys
							end,
							order = autoOrder(),
							width = 1,
						},
						useDefaultForNewChar = {
							type = "toggle",
							name = "Use 'Default' profile on new characters",
							desc =
								"Use the 'Default' profile for new characters, instead of creating a new character specific profile for them.\n\r" ..
								ns.Constants.COLORS.CONTRAST_RED:WrapTextInColorCode("WARNING:") ..
								" Current Flight Spells & Sprint Spells settings are SAVED IN YOUR PROFILE. That means, if you are using the 'default' profile on all characters, any change to those also changes for all.\n\r" ..
								"Leaving this unchecked and editing the default profile will apply those changes to all new character profiles made on this account.",
							get = genGenericGetFromOptions("useDefaultForNewChar", "global", "KinesisOptions"),
							set = genGenericSetFunction("useDefaultForNewChar", "global", "KinesisOptions", nil),
							order = autoOrder(),
							width = 2,
						},
					}
				},
				quickToolsGroup = {
					name = "Tools",
					type = "group",
					inline = true,
					order = autoOrder(true),
					args = {
						fixSprintJump = {
							type = "execute",
							name = "Fix Sprint+Jump",
							desc = "By default, WoW has Shift+Space bound to something stupid. This blocks you from being able to sprint & jump (*insert Skyrim flashbacks of falling off a cliff because you can't sprint+jump*). Thankfully we can fix it here! Usually, we fix this for you on login, but if that failed, click here to fix it again.",
							order = autoOrder(),
							func = ns.Main.clearShiftSpaceBinds,
							width = 0.95,
						},
						alwaysFixSprintJump = {
							type = "toggle",
							name = "Always Fix Sprint+Jump",
							desc = "When enabled, Sprint+Jump will be checked & fixed every time you login.",
							get = genGenericGetFromOptions("alwaysFixSprintJump", "global", "KinesisOptions"),
							set = genGenericSetFunction("alwaysFixSprintJump", "global", "KinesisOptions"),
							order = autoOrder(),
							width = 1.1,
						},
						showChangelog = {
							type = "execute",
							name = "Show Changelog",
							desc = "Show the Kinesis version Changelog.\n\rAlso, the 'Welcome' intro screen lives here too, if you want to revisit it!",
							order = autoOrder(),
							func = function() ns.Welcome.showWelcomeScreen(true) end,
							width = 0.95,
						},
						--[[ -- There is no Debug in Kinesis Land
						debugToggle = {
							type = "toggle",
							name = "Debug",
							desc = "Enable Debug Mode.",
							get = function() return KinesisOptions.global.debug end,
							set = function(info, val) KinesisOptions.global.debug = val end,
							order = autoOrder(),
							width = 1,
						},
						--]]
						mouseoverHint = {
							type = "header",
							name = "TIP: Mouse-over things to get a better description on what they do!",
							order = autoOrder(),
						}
					},
				},
			},
		},
		dragonriding = {
			type = "group",
			name = "GLIDE",
			order = autoOrder(),
			args = {
				dragonRidingTitle = {
					type = "header",
					name = g("GLIDE - Immersive Flying") .. w(" (BETA)"),
					order = autoOrder(),
					dialogControl = "SFX-Header-II",
				},
				dragonRidingInfo = {
					type = "description",
					name =
					"GLIDE - Immersive Flying is a lite recreation of Skyriding / Dragonriding from retail, where speed is a dynamic response to your current flight angle, such as diving & climbing, and caries momentum.\n\rGLIDE is customizable per-phase; only Officer+ may adjust the settings below.\nNOTE: You must click 'Save Phase Settings' to save. This allows you to test changes before saving.\r",
					order = autoOrder(),
				},

				drSettingsGroup = {
					type = "group",
					name = "GLIDE Phase Settings",
					inline = true,
					order = autoOrder(),
					disabled = function()
						if not C_Epsilon.IsOfficer() then return true end
						return not ns.DR_API.IsEnabled()
					end,
					args = {
						dragonRidingToggle = {
							type = "toggle",
							name = "Enable Immersive Flying in this Phase",
							desc = "When enabled, a recreation of Dragon Riding systems are enabled in the phase for everyone. You may customize the settings further below.\n\rOnly an Officer+ may toggle or adjust Dragon Riding in the phase.",
							get = ns.DR_API.IsEnabled,
							set = set(ns.DR_API.SetEnabled),
							order = autoOrder(),
							width = 2,
							disabled = function() return not C_Epsilon.IsOfficer() end,
						},
						dragonRidingSaveSettings = {
							type = "execute",
							name = "Save Phase Settings",
							desc = "Save the current GLIDE settings to the phase, applying to all members in phase.",
							order = autoOrder(),
							func = function()
								ns.DRSettings.SaveToServer()
								unsavedPhaseChanges = false
							end,
							disabled = function()
								if not C_Epsilon.IsOfficer() then return true end
								return not unsavedPhaseChanges
							end,
							width = 1,
						},
						dragonRidingReqMounted = {
							type = "toggle",
							name = "Require Mount",
							desc = "When enabled, you must be mounted (or have a spell active from the Require Spell/Aura Whitelist) to activate Immersive Flying in this phase. Otherwise, traditional flying will be used.",
							get = ns.DR_API.GetRequireMounted,
							set = set(ns.DR_API.SetRequireMounted),
							order = autoOrder(),
							width = 1,
						},
						dragonRidingReqSpellWhitelist = {
							type = "input",
							dialogControl = "MAW-Editbox",
							name = "Require Spell/Aura Whitelist",
							desc =
							"When set, you must have one of the spells listed here as an active aura in order to activate Immersive Flying in this phase. Otherwise, traditional flying will be used. You may add multiple spells, separated by commas.\n\rIf Require Mounted is also enabled, this acts as an OR, meaning they must be mounted OR have one of these auras.",
							usage = "spellID1, spellID2, ...\nExample: Players using a flying morph instead of a mount may apply an aura (i.e., 356465) to enable Immersive Flying instead.",
							get = ns.DR_API.GetRequireSpellsString,
							set = set(ns.DR_API.SetRequireSpellsString),
							order = autoOrder(),
							width = 2,
						},
						speedSection = {
							type = "header",
							name = g("Speed"),
							order = autoOrder(),
							dialogControl = "SFX-Header-II",
						},
						dragonRidingMinSpeed = {
							type = "range",
							dialogControl = "MAW-Slider",
							min = 0.1,
							softMax = 5,
							max = 10,
							step = 0.01,
							bigStep = 0.1,
							name = w "Minimum Speed (Climb)",
							desc = g "Adjust the minimum speed. This is the slowest speed you can reach when climbing." .. drDefault("MIN_SPEED"),
							get = ns.DR_API.GetMinSpeed,
							set = set(ns.DR_API.SetMinSpeed),
							order = autoOrder(),
							width = 1,
						},
						dragonRidingBaseSpeed = {
							type = "range",
							dialogControl = "MAW-Slider",
							min = 1,
							softMax = 10,
							max = 50,
							step = 0.01,
							bigStep = 0.1,
							name = w "Base Flight Speed",
							desc = g "Adjust the base flight speed. This is the speed you fly when flying completely level / flat." .. drDefault("BASE_SPEED"),
							get = ns.DR_API.GetBaseSpeed,
							set = set(ns.DR_API.SetBaseSpeed),
							order = autoOrder(),
							width = 1,
						},
						dragonRidingMaxSpeed = {
							type = "range",
							dialogControl = "MAW-Slider",
							min = 1,
							softMax = 25,
							max = 50,
							step = 0.01,
							bigStep = 0.1,
							name = w "Max Speed (Dive)",
							desc = g "Adjust the maximum speed. This is the fastest you can reach, without boosting, while diving. Higher values allow for greater top speeds, making flight feel more exhilarating." .. drDefault("MAX_SPEED"),
							get = ns.DR_API.GetMaxSpeed,
							set = set(ns.DR_API.SetMaxSpeed),
							order = autoOrder(),
							width = 1,
						},
						spacer1 = spacer(nil, 2),
						accelSection = {
							type = "header",
							name = g("Acceleration"),
							order = autoOrder(),
							dialogControl = "SFX-Header-II",
						},
						dragonRidingAccelRate = {
							type = "range",
							dialogControl = "MAW-Slider",
							min = 0.1,
							softMax = 5,
							max = 10,
							step = 0.01,
							bigStep = 0.1,
							name = w "Acceleration Rate",
							desc = g "Adjust how quickly you accelerate to your target speed. Higher values result in faster acceleration, making flight feel more responsive." .. drDefault("ACCEL_RATE"),
							get = ns.DR_API.GetAccelRate,
							set = set(ns.DR_API.SetAccelRate),
							order = autoOrder(),
							width = 1,
						},
						dragonRidingDecelRate = {
							type = "range",
							dialogControl = "MAW-Slider",
							min = 0.1,
							softMax = 5,
							max = 10,
							step = 0.01,
							bigStep = 0.1,
							name = w "Deceleration Rate",
							desc = g "Adjust how quickly you decelerate when reducing speed. Higher values result in faster deceleration, reducing your overall ability to retain speed." .. drDefault("DECEL_RATE"),
							get = ns.DR_API.GetDecelRate,
							set = set(ns.DR_API.SetDecelRate),
							order = autoOrder(),
							width = 1,
						},
						dragonRidingDecelDiveRate = {
							type = "range",
							dialogControl = "MAW-Slider",
							min = 0,
							softMax = 5,
							max = 10,
							step = 0.01,
							bigStep = 0.1,
							name = w "Deceleration (Dive Grace)",
							desc = g "Alternative Deceleration Rate when exiting a Dive. Lower values than standard decel allow you to retain speed longer." .. drDefault("DECEL_RATE_DIVE"),
							get = ns.DR_API.GetDecelDiveRate,
							set = set(ns.DR_API.SetDecelDiveRate),
							order = autoOrder(),
							width = 1,
						},
						dragonRidingAngleScalePowDsc = {
							type = "range",
							dialogControl = "MAW-Slider",
							min = 0.1,
							softMax = 3,
							max = 5,
							step = 0.01,
							bigStep = 0.1,
							name = w "Angle Power (Dive)",
							desc = g "Adjusts how much your angle affects accel/deceleration when diving. Recommend values between 0-1 for a quicker response to diving / easier to gain speed." .. drDefault("ANGLE_SCALE_POW_DSC"),
							get = ns.DR_API.GetAngleScalePowDsc,
							set = set(ns.DR_API.SetAngleScalePowDsc),
							order = autoOrder(),
							width = 1.5,
						},
						dragonRidingAngleScalePowAsc = {
							type = "range",
							dialogControl = "MAW-Slider",
							min = 0.1,
							softMax = 3,
							max = 5,
							step = 0.01,
							bigStep = 0.1,
							name = w "Angle Power (Climb)",
							desc = g "Adjusts how much your angle affects accel/deceleration when climbing. Recommend values >1 for a slower response to diving / less penalty for gradual climbs." .. drDefault("ANGLE_SCALE_POW_ASC"),
							get = ns.DR_API.GetAngleScalePowAsc,
							set = set(ns.DR_API.SetAngleScalePowAsc),
							order = autoOrder(),
							width = 1.5,
						},
						spacer2 = spacer(nil, 2),
						boostSection = {
							type = "header",
							name = g("Boost"),
							order = autoOrder(),
							dialogControl = "SFX-Header-II",
						},
						dragonRidingBoostSpeed = {
							type = "range",
							dialogControl = "MAW-Slider",
							min = 1,
							softMax = 5,
							max = 10,
							step = 0.01,
							bigStep = 0.1,
							name = w "Boost: Speed Gain",
							desc = g "Adjust the speed gained when using boost. This determines how much speed is added when boosting during flight." .. drDefault("BOOST_SPEED_GAIN"),
							get = ns.DR_API.GetBoostSpeed,
							set = set(ns.DR_API.SetBoostSpeed),
							order = autoOrder(),
							width = 1.5,
						},
						dragonRidingBoostMax = {
							type = "range",
							dialogControl = "MAW-Slider",
							min = 1,
							softMax = 20,
							max = 50,
							step = 0.01,
							bigStep = 0.1,
							name = w "Boost: Max Speed",
							desc = g "Adjust the maximum speed achievable through boosting. This sets the upper limit for your boosted flight speed." .. drDefault("BOOST_SPEED_MAX"),
							get = ns.DR_API.GetBoostMax,
							set = set(ns.DR_API.SetBoostMax),
							order = autoOrder(),
							width = 1.5,
						},
						spacer3 = spacer(nil, 2),
						visualSection = {
							type = "header",
							name = g("Visuals"),
							order = autoOrder(),
							dialogControl = "SFX-Header-II",
						},
						highSpeedThreshold = {
							type = "range",
							dialogControl = "MAW-Slider",
							min = 0,
							softMax = 20,
							max = 50,
							step = 0.01,
							bigStep = 0.1,
							name = w "High Speed Threshold",
							desc = g "The speed in which you must be going faster than to activate the high-speed auras.\n\r0 Disables this system." .. drDefault("HIGH_SPEED_THRESHOLD"),
							get = ns.DR_API.GetHSThreshold,
							set = set(ns.DR_API.SetHSThreshold),
							order = autoOrder(),
							width = 1.5,
						},
						highSpeedAuras = {
							type = "input",
							dialogControl = "MAW-Editbox",
							name = w "High Speed Auras",
							desc = g "Auras to apply when your speed is higher than the high speed threshold. You may add multiple, separated by commas." .. drDefault("HIGH_SPEED_AURAS"),
							usage = "Aura1, Aura2, ...",
							get = ns.DR_API.GetHSAurasString,
							set = set(ns.DR_API.SetHSAurasString),
							order = autoOrder(),
							width = 1.5,
						},
					},
				},
				drPersonalSettings = {
					type = "group",
					name = "GLIDE Player Settings",
					inline = true,
					order = autoOrder(),
					args = {
						personalDRInfo = {
							type = "description",
							name = "These settings allow you to customize your personal experience with GLIDE - Immersive Flying, independent of the phase settings. Adjust these to suit your preferences!",
							order = autoOrder(),
						},
						disableGlideGlobal = {
							type = "toggle",
							name = "Disable GLIDE",
							desc = "Disable GLIDE, even in phases that have enabled it.",
							get = ns.DR_API.GetPersonalDisableOverride,
							set = set(ns.DR_API.SetPersonalDisableOverride),
							order = autoOrder(),
							width = "full",
						},
						boostKeybind = {
							type = "keybinding",
							name = "Boost Hotkey",
							desc = "Set the hotkey used to activate boost while flying with GLIDE.",
							get = ns.DR_API.GetBoostKeybind,
							set = set(ns.DR_API.SetBoostKeybind),
							order = autoOrder(),
							width = 1.5,
						},
					},
				},
			},
		},
		flightOptions = {
			name = "Flight Settings",
			handler = menuFrame.flight,
			type = "group",
			order = autoOrder(true),
			disabled = function() return not menuFrame.flight:GetFlightToggle() end,
			args = {
				modifiers = {
					type = "group",
					name = "Flight Modifiers",
					inline = true,
					order = autoOrder(),
					args = {
						needShift = {
							type = "toggle",
							name = "Require Shift+Jump to Enable Flight",
							desc = "When enabled, Shift must be pressed along-side jump to toggle flight on.\n\rThis allows the Double Jump spell to work alongside double-jump to fly.",
							get = "GetNeedShift",
							set = "SetNeedShift",
							order = autoOrder(),
							width = "full",
						},
						tripleJump = {
							type = "toggle",
							name = "Require Triple Jump to Enable Flight",
							desc = "When enabled, you must triple-jump to toggle flight on.\n\rThis allows the Double Jump spell to work properly without toggling flight.",
							get = "GetNeedTripleJump",
							set = "SetNeedTripleJump",
							order = autoOrder(),
							width = "full",
						},
						--[[
						jumpToTurnOff = {
							type = "toggle",
							name = "Double / Triple Jump to Disable Flight",
							desc = "Unchecked: No Jumping will turn off flight.\n\rChecked: Double Jump while flying to turn off flight.\n\rGrey Check: Triple Jump while flying to turn off flight.",
							get = "GetJumpToLand",
							set = "SetJumpToLand",
							order = autoOrder(),
							width = "full",
							tristate = true,
						},
						--]]
						jumpToTurnOffRadios = {
							type = "select",
							style = "radio",
							name = "Double / Triple Jump to Disable Flight",
							desc = "Require Double or Triple Jump to disable flight when flying - or disable the function entirely.",
							values = { [2] = "Double Jump", [3] = "Triple Jump", [0] = "Disable" },
							sorting = { 2, 3, 0 },
							get = genGenericGetFromOptions("jumpToLand", "flight"),
							set = genGenericSetFunction("jumpToLand", "flight"),
							order = autoOrder(),
							width = "full",
						},
						autoLandLabel = {
							type = "description",
							name = "Auto-Land Delay:",
							fontSize = "medium",
							order = autoOrder(),
							width = 1,
						},
						landDelay = {
							type = "range",
							dialogControl = "MAW-Slider",
							min = 0,
							softMax = 5,
							max = 20,
							step = 0.1,
							bigStep = 0.5,
							--name = "Auto-Land Delay Time (s)",
							name = "Disable Flight when on the ground for .. seconds:",
							desc = "How long, in seconds, after landing on the ground before toggling flight off.\n\rSet to 0 to disable.",
							get = "GetLandingDelay",
							set = "SetLandingDelay",
							order = autoOrder(),
							width = 2,
						},
						maxKeyLabel = {
							type = "description",
							name = "Jump Trigger Speed:",
							fontSize = "medium",
							order = autoOrder(),
							width = 1,
						},
						maxKeyDelay = {
							type = "range",
							dialogControl = "MAW-Slider",
							min = 0.05,
							softMax = 1,
							max = 5,
							step = 0.01,
							bigStep = 0.05,
							name = "Max Jump Delay (s)",
							desc = "How quickly you must hit the 2nd and/or 3rd jump in order to toggle flight.\n\rSmaller numbers reduce accidental activation, but may make it more difficult to trigger.\n\rSuggested delay for best compatibility with Double Jump & less accidental activation: 0.25 seconds",
							get = "GetMaxKeyDelay",
							set = "SetMaxKeyDelay",
							order = autoOrder(),
							width = 2,
						},
					},
				},
			},
		},
		flightSpellsOptions = {
			name = "Flight Spells",
			type = "group",
			handler = menuFrame.flight,
			childGroups = "tree",
			order = autoOrder(true),
			disabled = function()
				return not (menuFrame.flight:GetFlightToggle() or KinesisOptions.global.extendedFlightDetection)
			end,
			args = {
				mainGroup = {
					name = "Flight Spells",
					type = "group",
					inline = true,
					order = autoOrder(),
					args = {
						description = {
							type = "description",
							name = "Flight Spells toggle on (or cast the Flight Start Arcanum) when enabling flight via Kinesis, and toggle off (or cast the Flight Stop Arcanum) when disabling flight via Kinesis.",
							order = autoOrder(),
						},
						toggle = {
							type = "toggle",
							name = "Enable Flight Spells",
							desc = "Enable or Disable casting of Spells / ArcSpells when starting or stopping flight.",
							get = genGenericGetFromOptions("sendSpells", "flight"),
							set = genGenericSetFunction("sendSpells", "flight"),
						},
					},
				},
				arcanumGroup = {
					name = "Arcanum Flight Spells",
					type = "group",
					inline = true,
					disabled = function() return not ARC end,
					order = autoOrder(),
					args = {
						arcNotDetected = {
							type = "header",
							name = "Arcanum was not detected. Be sure the Arcanum AddOn (SpellCreator) is enabled.",
							hidden = function() return ARC end,
							order = autoOrder(),
						},
						arcanumToggle = {
							type = "toggle",
							name = "Enabled",
							desc = "Enable or Disable Arcanum Casting when you toggle flight.",
							get = genGenericGetFromOptions("arcanumToggle", "flight"),
							set = genGenericSetFunction("arcanumToggle", "flight"),
							order = autoOrder(),
							width = 0.75,
						},
						arcFlyStart = {
							type = "input",
							dialogControl = "MAW-Editbox",
							name = "Arcanum - Flight Start",
							desc = "Enter an Arcanum ArcSpell ID here to cast that Arcanum when you start flying.",
							usage = "Arcanum ArcSpell ID",
							get = genGenericGetFromOptions("arcanumStart", "flight"),
							set = genGenericSetFunction("arcanumStart", "flight"),
							order = autoOrder(),
							width = 1,
						},
						arcFlyStop = {
							type = "input",
							dialogControl = "MAW-Editbox",
							name = "Arcanum - Flight Stop",
							desc = "Enter an Arcanum ArcSpell ID here to cast that Arcanum when you stop flying.",
							usage = "Arcanum ArcSpell ID",
							get = genGenericGetFromOptions("arcanumStop", "flight"),
							set = genGenericSetFunction("arcanumStop", "flight"),
							order = autoOrder(),
							width = 1,
						},
					},
				},
				normalSpellsGroup = {
					name = "Standard Flight Spells",
					type = "group",
					inline = true,
					order = autoOrder(),
					args = {
						addSpellID = {
							type = "input",
							name = "Add Spell (ID)",
							desc = "Type a Spell ID here and then hit 'Okay' to add it to your current Flight-Spells.",
							usage = "Spell ID",
							--get = function() end,
							set = function(info, val)
								Flight.addSpellToSpellList(val); menuFrame:RefreshMenuForUpdates()
							end,
							order = autoOrder(),
							width = 1,
						},
						removeSpellDropdown = {
							type = "select",
							name = "Remove Spell",
							desc = "Remove a Spell from the current Flight-Spells.",
							values = function()
								local t = Flight.getSpellsInCurrentProfileList()
								t["removeSpellLabel"] = "Remove Spell"
								return t
							end,
							sorting = function() return select(2, Flight.getSpellsInCurrentProfileList()) end,
							get = function() return "removeSpellLabel" end,
							set = function(info, val)
								Flight.removeSpellFromSpellList(val); menuFrame:RefreshMenuForUpdates();
							end,
							order = autoOrder(),
							width = 1.25,
						},
						resetSpellsButton = {
							type = "execute",
							name = "Reset Spells",
							desc = "Click to remove all your current Flight-Spells.",
							func = function(info, val)
								Dialogs.showGenericConfirmation(
									"Are you sure you want to remove all your currently set Flight-Spells?",
									function()
										Flight.removeAllSpellsFromSpellList(); menuFrame:RefreshMenuForUpdates()
									end
								)
							end,
							order = autoOrder(),
							width = 0.75,
						},

						spacer2 = spacer(),
						saveSpellSet = {
							type = "execute",
							name = "Save Flight Spell Set",
							desc = "Click to save your current Flight-Spells as a Spell Set.",
							func = function()
								Dialogs.showCustomGenericInputBox({
									text = "Give your Spell Set a name:",
									callback = function(text)
										Flight.saveSpellListToStorage(text)
										menuFrame:RefreshMenuForUpdates();
									end,
									acceptText = SAVE,
									cancelText = CANCEL,
								})
							end,
							order = autoOrder(),
							width = 1,
						},
						loadSpellSet = {
							type = "select",
							name = "Load Flight Spell Set",
							desc = "Load a previously saved spell set, overwriting your currently set Flight-Spells.\n\rNote: You must re-save with the same name in order to update a Spell Set, it does not update when you modify it after loading.",
							values = function()
								local t = Flight.getSpellListsInStorage()
								t["loadSpellSetLabel"] = "Load Spell Set"
								return t
							end,
							sorting = function() return select(2, Flight.getSpellListsInStorage()) end,
							get = function() return "loadSpellSetLabel" end,
							set = function(info, val)
								Flight.loadSpellListFromStorage(val); menuFrame:RefreshMenuForUpdates();
							end,
							order = autoOrder(),
							width = 1,
						},
						deleteSpellSet = {
							type = "select",
							name = "Delete Flight Spell Set",
							desc = "Delete's a previously saved Spell Set. Permanently.",
							values = function()
								local t = Flight.getSpellListsInStorage()
								t["deleteSpellSetLabel"] = "Delete Spell Set"
								return t
							end,
							sorting = function() return select(2, Flight.getSpellListsInStorage()) end,
							get = function() return "deleteSpellSetLabel" end,
							set = function(info, val)
								Dialogs.showGenericConfirmation("Are you sure you want to delete " .. contrastText:WrapTextInColorCode(val) .. "?", function()
									Flight.deleteSpellListFromStorage(val); menuFrame:RefreshMenuForUpdates();
								end)
							end,
							order = autoOrder(),
							width = 1,
						},
						currentSpellsVisualizer = {
							type = "select",
							style = "radio",
							name = "Current Spells:",
							--desc = "",
							values = function()
								local t = Flight.getSpellsInCurrentProfileList()
								--t["removeSpellLabel"] = "Remove Spell"
								return t
							end,
							sorting = function() return select(2, Flight.getSpellsInCurrentProfileList()) end,
							get = function() return end,
							set = function(info, val) end,
							order = autoOrder(),
							width = "full",
						},
					},
				},
			},
		},
		sprintOptions = {
			name = "Sprint Settings",
			type = "group",
			handler = menuFrame.sprint,
			childGroups = "tree",
			order = autoOrder(true),
			disabled = function() return not menuFrame.sprint:GetFullToggle() end,
			args = {
				sprintSettings = {
					name = "Sprint Settings",
					type = "group",
					inline = true,
					order = autoOrder(true),
					args = {
						speedWalkToggle = {
							type = "toggle",
							name = " ",
							desc = "Enable sprinting when on the ground.",
							arg = "speedWalkEnabled",
							get = "GenericGet",
							set = "GenericSet",
							order = autoOrder(),
							width = 0.15,
						},
						speedWalk = {
							type = "range",
							dialogControl = "MAW-Slider",
							min = 0,
							softMax = 10,
							max = 50,
							step = 0.01,
							bigStep = 0.1,
							name = "Ground Sprint Speed",
							desc = "The speed to use for sprinting on the ground (Walk/Run).\n\rYou can type in any value from 0 to 50 if needed.\n\rDefault: 1.66",
							arg = "speedWalk",
							get = "GenericGet",
							set = "GenericSet",
							disabled = function() return not menuFrame.sprint:GenericGet("speedWalkEnabled") end,
							order = autoOrder(),
							width = 2.20,
						},
						speedWalkReset = {
							name = "Reset Ground",
							desc = "Reset Ground (Walk/Run) Sprint Speed to Default (1.66).",
							order = autoOrder(),
							type = "execute",
							func = function()
								menuFrame.sprint:resetSpeed("speedWalk")
							end,
							width = 0.75,
						},
						spacer1 = spacer(),
						speedFlyToggle = {
							type = "toggle",
							name = " ",
							desc = "Toggle sprinting when flying.",
							arg = "speedFlyEnabled",
							get = "GenericGet",
							set = "GenericSet",
							order = autoOrder(),
							width = 0.15,
						},
						speedFly = {
							type = "range",
							dialogControl = "MAW-Slider",
							min = 0,
							softMax = 50,
							max = 50,
							step = 0.01,
							bigStep = 0.5,
							name = "Fly Sprint Speed",
							desc = "The speed to use for sprinting while flying.\n\rYou can type in more precise speeds if needed.\n\rDefault: 10",
							arg = "speedFly",
							get = "GenericGet",
							set = "GenericSet",
							disabled = function() return not menuFrame.sprint:GenericGet("speedFlyEnabled") end,
							order = autoOrder(),
							width = 2.20,
						},
						speedFlyReset = {
							name = "Reset Fly",
							desc = "Reset Fly Sprint Speed to Default (10).",
							order = autoOrder(),
							type = "execute",
							func = function()
								menuFrame.sprint:resetSpeed("speedFly")
							end,
							width = 0.75,
						},
						spacer2 = spacer(),
						speedSwimToggle = {
							type = "toggle",
							name = " ",
							desc = "Toggle sprinting when swimming.",
							arg = "speedSwimEnabled",
							get = "GenericGet",
							set = "GenericSet",
							order = autoOrder(),
							width = 0.15,
						},
						speedSwim = {
							type = "range",
							dialogControl = "MAW-Slider",
							min = 0,
							softMax = 50,
							max = 50,
							step = 0.01,
							bigStep = 0.5,
							name = "Swim Sprint Speed",
							desc = "The speed to use for sprinting while swimming.\n\rYou can type in more precise speeds if needed.\n\rDefault: 10",
							arg = "speedSwim",
							get = "GenericGet",
							set = "GenericSet",
							disabled = function() return not menuFrame.sprint:GenericGet("speedSwimEnabled") end,
							order = autoOrder(),
							width = 2.20,
						},
						speedSwimReset = {
							name = "Reset Swim",
							desc = "Reset Swim Sprint Speed to Default (10).",
							order = autoOrder(),
							type = "execute",
							func = function()
								menuFrame.sprint:resetSpeed("speedSwim")
							end,
							width = 0.75,
						},
						spacer3 = spacer(),
						sprintReturnSpeedToggle = {
							type = "toggle",
							name = "Return to Original Speed",
							desc = "When you stop sprinting, return you to the last speed you were at. If disabled, you will always return to speed 1.",
							arg = "sprintReturnLastSpeed",
							get = "GenericGet",
							set = "GenericSet",
							order = autoOrder(),
							width = 1.5,
						},
						sprintEnableCtrlToggle = {
							type = "toggle",
							name = "Enable Ctrl-Shift-Sprint Toggle",
							desc = "Allow Ctrl+Shift to Toggle Sprint instead of Holding it. When toggled, sprint does not stop until you hit Shift again.\n\rThis is best left disabled in Dual Mode, and does not function in Toggle Mode. It's really made for Hold Mode.",
							arg = "enableCtrlSprintToggle",
							get = "GenericGet",
							set = "GenericSet",
							order = autoOrder(),
							width = 1.5,
						},
						sprintAllowFromStillToggle = {
							type = "toggle",
							name = "Allow Sprint Activation when Still",
							desc = "Allows Sprint to be activated when you're not moving. Otherwise, you must be moving first in order to activate sprinting.",
							arg = "allowSprintWhenNotMoving",
							get = "GenericGet",
							set = "GenericSet",
							order = autoOrder(),
							width = 1.5,
						},
						sprintToggleDelay = {
							type = "range",
							dialogControl = "MAW-Slider",
							min = 0.1,
							max = 1,
							step = 0.01,
							bigStep = 0.01,
							name = "Toggle/Hold Shift Delay",
							desc = "In Dual-Sprint Mode, this controls how long you must hold down Shift in order to transition from Toggle to Hold mode.\n\rAdjusting this to a lower value can allow you have shorter bursts of sprinting without activating as a toggle, but may make it harder to accurately toggle.\n\rDefault: 0.35 seconds",
							arg = "toggleHoldShiftDelay",
							get = "GenericGet",
							set = "GenericSet",
							disabled = function() return KinesisOptions.global.sprintMode ~= "dual" end,
							order = autoOrder(),
							width = 1.5,
						},
					},
				},

				emoteSettings = {
					name = "Emotes",
					type = "group",
					inline = true,
					order = autoOrder(true),
					args = {
						triggerGroup = {
							name = "Trigger When..",
							type = "group",
							inline = true,
							order = autoOrder(),
							args = {
								sendEmoteToggleWalk = {
									type = "toggle",
									name = "Walking/Running",
									desc = "When you start sprinting on the ground, the provided emote will be sent.",
									get = function() return KinesisOptions.profiles[KinesisCharOptions.activeProfile].sprint.sendEmote.walk end,
									set = function(info, val) KinesisOptions.profiles[KinesisCharOptions.activeProfile].sprint.sendEmote.walk = val end,
									order = autoOrder(),
									width = 1,
								},
								sendEmoteToggleFly = {
									type = "toggle",
									name = "Flying",
									desc = "When you start sprinting while flying, the provided emote will be sent.",
									get = function() return KinesisOptions.profiles[KinesisCharOptions.activeProfile].sprint.sendEmote.fly end,
									set = function(info, val) KinesisOptions.profiles[KinesisCharOptions.activeProfile].sprint.sendEmote.fly = val end,
									order = autoOrder(),
									width = 1,
								},
								sendEmoteToggleSwim = {
									type = "toggle",
									name = "Swimming",
									desc = "When you start sprinting while swimming, the provided emote will be sent.",
									get = function() return KinesisOptions.profiles[KinesisCharOptions.activeProfile].sprint.sendEmote.swim end,
									set = function(info, val) KinesisOptions.profiles[KinesisCharOptions.activeProfile].sprint.sendEmote.swim = val end,
									order = autoOrder(),
									width = 1,
								},
							},
						},
						emoteMessage = {
							type = "input",
							dialogControl = "MAW-Editbox",
							name = "Set the emote to use:",
							desc = "When you start sprinting, the provided emote will be sent.",
							arg = "emoteMessage",
							get = "GenericGet",
							set = "GenericSet",
							order = autoOrder(),
							width = "full",
						},
						emoteRateLimit = {
							type = "range",
							dialogControl = "MAW-Slider",
							min = 0.5,
							softMax = 100,
							bigStep = 0.25,
							name = "Emote Rate Limit (Seconds)",
							desc = "How long, in seconds, after a Sprint-Emote, before another Sprint-Emote can trigger, to avoid spamming.\n\rWant it even longer than 100? You can type it in to the box also.",
							get = genGenericGetFromOptions("emoteRateLimit", "sprint"),
							set = genGenericSetFunction("emoteRateLimit", "sprint", nil, function() ns.Sprint.resetEmoteRateLimited() end),
							order = autoOrder(),
							width = "full",
						},
					},
				},
			},
		},
		sprintSpellsOptions = {
			name = "Sprint Spells",
			type = "group",
			handler = menuFrame.sprint,
			childGroups = "tree",
			order = autoOrder(true),
			disabled = function() return not menuFrame.sprint:GetFullToggle() end,
			args = {
				triggerGroup = {
					name = "Trigger Spells When..",
					type = "group",
					inline = true,
					order = autoOrder(),
					args = {
						sendSpellsWalk = {
							type = "toggle",
							name = "Walking/Running",
							desc = "When Sprinting on the Ground, Aura all Spells in your Sprint-Spells list.",
							get = function() return KinesisOptions.profiles[KinesisCharOptions.activeProfile].sprint.sendSpells.walk end,
							set = function(info, val) KinesisOptions.profiles[KinesisCharOptions.activeProfile].sprint.sendSpells.walk = val end,
							order = autoOrder(),
							width = 1,
						},
						sendSpellsFly = {
							type = "toggle",
							name = "Flying",
							desc = "When Sprinting while flying, Aura all Spells in your Sprint-Spells list.",
							get = function() return KinesisOptions.profiles[KinesisCharOptions.activeProfile].sprint.sendSpells.fly end,
							set = function(info, val) KinesisOptions.profiles[KinesisCharOptions.activeProfile].sprint.sendSpells.fly = val end,
							order = autoOrder(),
							width = 1,
						},
						sendSpellsSwim = {
							type = "toggle",
							name = "Swimming",
							desc = "When Sprinting while swimming, Aura all Spells in your Sprint-Spells list.",
							get = function() return KinesisOptions.profiles[KinesisCharOptions.activeProfile].sprint.sendSpells.swim end,
							set = function(info, val) KinesisOptions.profiles[KinesisCharOptions.activeProfile].sprint.sendSpells.swim = val end,
							order = autoOrder(),
							width = 1,
						},
					},
				},
				arcanumGroup = {
					name = "Arcanum Sprint Spells",
					type = "group",
					inline = true,
					disabled = function() return not ARC end,
					order = autoOrder(),
					args = {
						arcNotDetected = {
							type = "header",
							name = "Arcanum was not detected. Be sure the Arcanum AddOn (SpellCreator) is enabled.",
							hidden = function() return ARC end,
							order = autoOrder(),
						},
						arcanumToggle = {
							type = "toggle",
							name = "Enabled",
							desc = "Enable or Disable Arcanum Casting when you sprint.",
							get = function() return KinesisOptions.profiles[KinesisCharOptions.activeProfile].sprint.arcanumToggle end,
							set = function(info, val) KinesisOptions.profiles[KinesisCharOptions.activeProfile].sprint.arcanumToggle = val end,
							order = autoOrder(),
							width = 0.75,
						},
						arcSprintStart = {
							type = "input",
							name = "Arcanum - Sprint Start",
							desc = "Enter an Arcanum ArcSpell ID here to cast that Arcanum when you start sprinting.",
							usage = "Arcanum ArcSpell ID",
							get = function() return KinesisOptions.profiles[KinesisCharOptions.activeProfile].sprint.arcanumStart end,
							set = function(info, val) KinesisOptions.profiles[KinesisCharOptions.activeProfile].sprint.arcanumStart = val end,
							order = autoOrder(),
							width = 1,
						},
						arcSprintStop = {
							type = "input",
							name = "Arcanum - Sprint Stop",
							desc = "Enter an Arcanum ArcSpell ID here to cast that Arcanum when you stop sprinting.",
							usage = "Arcanum ArcSpell ID",
							get = function() return KinesisOptions.profiles[KinesisCharOptions.activeProfile].sprint.arcanumStop end,
							set = function(info, val) KinesisOptions.profiles[KinesisCharOptions.activeProfile].sprint.arcanumStop = val end,
							order = autoOrder(),
							width = 1,
						},
					},
				},
				normalSpellsGroup = {
					name = "Standard Sprint Spells",
					type = "group",
					inline = true,
					order = autoOrder(),
					args = {
						addSpellID = {
							type = "input",
							name = "Add Spell (ID)",
							desc = "Type a Spell ID here and then hit 'Okay' to add it to your current Sprint-Spells.",
							usage = "Spell ID",
							--get = function() end,
							set = function(info, val)
								Sprint.addSpellToSpellList(val); menuFrame:RefreshMenuForUpdates()
							end,
							order = autoOrder(),
							width = 1,
						},
						--[[
						addSpellButton = {
							type = "execute",
							name = "Add Spell",
							desc = "Click to add the spell to the left to your current Sprint-Spells.",
							func = function(info, val) Sprint.addSpellToSpellList(addSpellIDTemp); addSpellIDTemp = nil; menuFrame:RefreshMenuForUpdates() end,
							order = autoOrder(),
							width = 0.75,
						},
						--]]
						removeSpellDropdown = {
							type = "select",
							name = "Remove Spell",
							desc = "Remove a Spell from the current Sprint-Spells.",
							values = function()
								local t = Sprint.getSpellsInCurrentProfileList()
								t["removeSpellLabel"] = "Remove Spell"
								return t
							end,
							sorting = function() return select(2, Sprint.getSpellsInCurrentProfileList()) end,
							get = function() return "removeSpellLabel" end,
							set = function(info, val)
								Sprint.removeSpellFromSpellList(val); menuFrame:RefreshMenuForUpdates();
							end,
							order = autoOrder(),
							width = 1.25,
						},
						resetSpellsButton = {
							type = "execute",
							name = "Reset Spells",
							desc = "Click to remove all your current Sprint-Spells.",
							func = function(info, val)
								Dialogs.showGenericConfirmation(
									"Are you sure you want to remove all your currently set Shift-Sprint-Spells?",
									function()
										Sprint.removeAllSpellsFromSpellList(); menuFrame:RefreshMenuForUpdates()
									end
								)
							end,
							order = autoOrder(),
							width = 0.75,
						},

						spacer2 = spacer(),
						saveSpellSet = {
							type = "execute",
							name = "Save Sprint Spell Set",
							desc = "Click to save your current Sprint-Spells as a Spell Set.",
							func = function()
								Dialogs.showCustomGenericInputBox({
									text = "Give your Spell Set a name:",
									callback = function(text)
										Sprint.saveSpellListToStorage(text)
										menuFrame:RefreshMenuForUpdates();
									end,
									acceptText = SAVE,
									cancelText = CANCEL,
								})
							end,
							order = autoOrder(),
							width = 1,
						},
						loadSpellSet = {
							type = "select",
							name = "Load Sprint Spell Set",
							desc = "Load a previously saved spell set, overwriting your currently set Sprint-Spells.\n\rNote: You must re-save with the same name in order to update a Spell Set, it does not update when you modify it after loading.",
							values = function()
								local t = Sprint.getSpellListsInStorage()
								t["loadSpellSetLabel"] = "Load Spell Set"
								return t
							end,
							sorting = function() return select(2, Sprint.getSpellListsInStorage()) end,
							get = function() return "loadSpellSetLabel" end,
							set = function(info, val)
								Sprint.loadSpellListFromStorage(val); menuFrame:RefreshMenuForUpdates();
							end,
							order = autoOrder(),
							width = 1,
						},
						deleteSpellSet = {
							type = "select",
							name = "Delete Sprint Spell Set",
							desc = "Delete's a previously saved Spell Set. Permanently.",
							values = function()
								local t = Sprint.getSpellListsInStorage()
								t["deleteSpellSetLabel"] = "Delete Spell Set"
								return t
							end,
							sorting = function() return select(2, Sprint.getSpellListsInStorage()) end,
							get = function() return "deleteSpellSetLabel" end,
							set = function(info, val)
								Dialogs.showGenericConfirmation("Are you sure you want to delete " .. contrastText:WrapTextInColorCode(val) .. "?", function()
									Sprint.deleteSpellListFromStorage(val); menuFrame:RefreshMenuForUpdates();
								end)
							end,
							order = autoOrder(),
							width = 1,
						},

						currentSpellsVisualizer = {
							type = "select",
							style = "radio",
							name = "Current Spells:",
							--desc = "",
							values = function()
								local t = Sprint.getSpellsInCurrentProfileList()
								--t["removeSpellLabel"] = "Remove Spell"
								return t
							end,
							sorting = function() return select(2, Sprint.getSpellsInCurrentProfileList()) end,
							get = function() return end,
							set = function(info, val) end,
							order = autoOrder(),
							width = "full",
						},
					},
				},
			},
		},
	}
}

----------------------------------
--#region Flight Menu Functions
----------------------------------

function menuFrame.flight:GetFlightToggle(info)
	return KinesisOptions.profiles[KinesisCharOptions.activeProfile].flight.enabled
end

function menuFrame.flight:SetFlightToggle(info, value)
	if value == true then enableAddon(TRIGGER_TYPES[1]) else disableAddon(TRIGGER_TYPES[1]) end
	if info and info[0] and info[0] ~= "" then print("Addon Enabled was set to: " .. tostring(value)) end
end

function menuFrame.flight:GetNeedShift(info)
	return KinesisOptions.profiles[KinesisCharOptions.activeProfile].flight.needShift
end

function menuFrame.flight:SetNeedShift(info, value)
	KinesisOptions.profiles[KinesisCharOptions.activeProfile].flight.needShift = value
	if info and info[0] and info[0] ~= "" then print("Shift Required was set to: " .. tostring(value)) end
end

function menuFrame.flight:GetNeedTripleJump(info)
	return KinesisOptions.profiles[KinesisCharOptions.activeProfile].flight.tripleJump
end

function menuFrame.flight:SetNeedTripleJump(info, value)
	KinesisOptions.profiles[KinesisCharOptions.activeProfile].flight.tripleJump = value
	if info and info[0] and info[0] ~= "" then print("Triple Jump Required was set to: " .. tostring(value)) end
end

function menuFrame.flight:GetJumpToLand(info)
	local tristateAsNum = KinesisOptions.profiles[KinesisCharOptions.activeProfile].flight.jumpToLand
	local tristateTrueVal

	if tristateAsNum == 2 then
		tristateTrueVal = true
	elseif tristateAsNum == 3 then
		tristateTrueVal = nil
	else
		tristateTrueVal = false
	end

	return tristateTrueVal
end

function menuFrame.flight:SetJumpToLand(info, value)
	local tristateToNum

	if value == true then
		tristateToNum = 2
	elseif value == nil then
		tristateToNum = 3
	elseif value == false then
		tristateToNum = 0
	end

	KinesisOptions.profiles[KinesisCharOptions.activeProfile].flight.jumpToLand = tristateToNum

	if info and info[0] and info[0] ~= "" then print("Jump To Land was set to: " .. tostring(tristateToNum) .. " jumps.") end
end

function menuFrame.flight:GetLandingDelay(info)
	return tonumber(KinesisOptions.profiles[KinesisCharOptions.activeProfile].flight.landDelay)
end

function menuFrame.flight:SetLandingDelay(info, value)
	KinesisOptions.profiles[KinesisCharOptions.activeProfile].flight.landDelay = tonumber(value)
	if info and info[0] and info[0] ~= "" then print("Landing Delay was set to: " .. tostring(value)) end
end

function menuFrame.flight:GetMaxKeyDelay(info)
	return tonumber(KinesisOptions.profiles[KinesisCharOptions.activeProfile].flight.maxKeyDelay)
end

function menuFrame.flight:SetMaxKeyDelay(info, value)
	KinesisOptions.profiles[KinesisCharOptions.activeProfile].flight.maxKeyDelay = tonumber(value)
	if info and info[0] and info[0] ~= "" then print("Max Jump Delay was set to: " .. tostring(value)) end
end

----------------------------------
--#endregion
----------------------------------

----------------------------------
--#region Sprint Menu Functions
----------------------------------

function menuFrame.sprint:GetFullToggle(info)
	return KinesisOptions.profiles[KinesisCharOptions.activeProfile].sprint.enabled
end

function menuFrame.sprint:SetFullToggle(info, value)
	if value == true then enableAddon(TRIGGER_TYPES[2]) else disableAddon(TRIGGER_TYPES[2]) end
	if info and info[0] and info[0] ~= "" then print("Addon Enabled was set to: " .. tostring(value)) end
end

---@param info table|string
function menuFrame.sprint:GenericGet(info)
	local key = info
	if info and type(info) == "table" then key = info.arg end
	return KinesisOptions.profiles[KinesisCharOptions.activeProfile].sprint[key]
end

---@param info table|string
---@param val string|boolean
---@param func function? callback function to add on after doing the set
function menuFrame.sprint:GenericSet(info, val, func)
	local key = info
	if info and type(info) == "table" then key = info.arg end
	KinesisOptions.profiles[KinesisCharOptions.activeProfile].sprint[key] = val
	if func then func(val) end
end

function menuFrame.sprint:resetSpeed(type)
	KinesisOptions.profiles[KinesisCharOptions.activeProfile].sprint[type] = ns.Sprint[type .. "Default"]
end

----------------------------------
--#endregion
----------------------------------

function menuFrame:AddOptionsMenu()
	AC:RegisterOptionsTable("Kinesis-Settings", options)
	self.optionsFrame = ACD:AddToBlizOptions("Kinesis-Settings", "Kinesis")
end

function menuFrame:RefreshMenuForUpdates()
	ACR:NotifyChange("Kinesis-Settings");
end

local function chatCommandHandler(msg)
	if msg == "off" then
		menuFrame.flight:SetFlightToggle(nil, false)
		menuFrame.sprint:SetFullToggle(nil, false)
		ns.Flight.toggleExtendedFlightDetection(false)
		KinesisOptions.global.extendedFlightDetection = false
		ACR:NotifyChange("Kinesis-Settings");
	elseif msg == "on" then
		menuFrame.flight:SetFlightToggle(nil, true)
		menuFrame.sprint:SetFullToggle(nil, true)
		ns.Flight.toggleExtendedFlightDetection(true)
		KinesisOptions.global.extendedFlightDetection = true
		ACR:NotifyChange("Kinesis-Settings");
	else
		if InterfaceOptionsFrame:IsShown() and InterfaceOptionsFramePanelContainer.displayedPanel == menuFrame.optionsFrame then
			InterfaceOptionsFrame:Hide()
		else
			InterfaceOptionsFrame_OpenToCategory(menuFrame.optionsFrame)
			InterfaceOptionsFrame_OpenToCategory(menuFrame.optionsFrame)
		end
	end
end
menuFrame:RegisterChatCommand("kinesis", chatCommandHandler)
menuFrame:RegisterChatCommand("kn", chatCommandHandler)

ns.Menu = {
	menuFrame = menuFrame,
}
