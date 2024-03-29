---@class ns
local ns = select(2, ...)
local addonName = ...

local Constants = ns.Constants

local addonVersion, addonAuthor, addonTitle = Constants.addonVersion, Constants.addonAuthor, Constants.addonTitle

local Main = ns.Main
local AC = Main.AC
local ACD = Main.ACD
local AceGUI = Main.AceGUI

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

local COLORS = Constants.COLORS

local whatIsKinesis = [[
Kinesis is your one-stop shop for all things movement! Customize your sprint, fly and swim speeds! Add spells and arcanums to your sprint or flight! Quickly toggle sprint by hitting shift like all of your favourite RPGs, and toggle flight like you're playing in a true Sandbox game with Creative Mode. All this and more, quickly and all with keybinds - instead of filling your macro slots.
]]

local shiftSprintDesc = [[
- Ditch the macros & stop typing '.mod speed'! Tap or Hold SHIFT to start sprinting!
- Customize your Sprint to anything from a simple run, to an ominous hover, complete with Aura & Arcanum functionality.
- Set your speeds for ground, flight and swim separately, & switch between hold and toggle options!

]] .. COLORS.GREEN:WrapTextInColorCode("TL;DR: Tap or Hold SHIFT to start sprinting! Use '/kn' to configure Sprint Speeds & Spells!")

local flightDesc = [[
- Double or triple Jump to enable/disable fly mode, also complete with Aura/Arcanum functionality!
- Complete with auto-land to disable flying, you can customize how long it takes before auto-land takes effect - or disable it entirely!
- Customize how fast your double/triple jumps will need to connect to enable/disable flight.

]] .. COLORS.GREEN:WrapTextInColorCode("TL;DR: Double/Triple Jump to Fly, Double/Triple Jump again to land! Use '/kn' to configure Flight Toggle customization options & Spells!")

local welcomeMenu = {
	name = "Welcome to Kinesis!" .. " (v" .. addonVersion .. ")",
	type = "group",
	childGroups = "tab",
	args = {
		welcomeTab = {
			type = "group",
			name = "Welcome!",
			order = autoOrder(true),
			args = {
				overview = {
					name = "What is Kinesis?",
					type = "group",
					inline = true,
					order = autoOrder(true),
					args = {
						knDesc = {
							type = "description",
							fontSize = "medium",
							name = whatIsKinesis,
							order = autoOrder(),
						},
					},
				},
				shiftSprintDesc = {
					name = "Shift-to-Sprint!",
					type = "group",
					inline = true,
					order = autoOrder(true),
					args = {
						knDesc = {
							type = "description",
							fontSize = "medium",
							image = "interface/icons/petbattle_speed.blp",
							name = shiftSprintDesc,
							order = autoOrder(),
						},
					},
				},
				flightDesc = {
					name = "Hit that Spacebar, let's fly!",
					type = "group",
					inline = true,
					order = autoOrder(true),
					args = {
						knDesc = {
							type = "description",
							fontSize = "medium",
							image = "interface/icons/icon_petfamily_flying.blp",
							name = flightDesc,
							order = autoOrder(),
						},
					},
				},
				settingsDesc = {
					type = "header",
					dialogControl = "SFX-Header-II",
					order = autoOrder(true),
					disabled = true,
					name = (">>>Use %s in chat to open Kinesis' Settings, where you can customize\nall the settings to fit your preferences, and more!"):format(COLORS.GREEN:WrapTextInColorCode("/kn"))
				},
				spacer = {
					name = " ",
					type = "description",
					order = autoOrder(true),
					width = "full",
				},
				forumsDesc = {
					type = "description",
					name = "Found a bug? Have some feedback?\nWant to see some examples of what Kinesis can do?\nCheck out the forums post:",
					fontSize = "medium",
					order = autoOrder(true),
					width = 2,
				},
				forumsButton = {
					type = "execute",
					name = "Copy Forum URL",
					order = autoOrder(true),
					width = 1,
					arg = "https://forums.epsilonwow.net/topic/3638-kinesis-sandbox-flight-shift-sprint-addon/",
					func = function(info)
						ns.Dialogs.copyLink(info.arg)
					end,
				},
			},
		},
		changelogTab = {
			type = "group",
			name = "Changelog",
			childGroups = "tree",
			order = autoOrder(true),
			args = ns.Changes.genChangeLogArgs(), -- generated in Changelog.lua! Edit there!
		},
    },
}
AC:RegisterOptionsTable(addonName .. "-Welcome", welcomeMenu)
ACD:SetDefaultSize(addonName .. "-Welcome", 600, 620)

local function showWelcomeScreen(showChangelog)
	local self = ACD
	local f
	local appName = addonName .. "-Welcome"
	if not self.OpenFrames[appName] then
		f = AceGUI:Create("Frame")
		self.OpenFrames[appName] = f
	else
		f = self.OpenFrames[appName]
	end
	f:ReleaseChildren()
	f:SetCallback("OnClose", function()
		local appName = f:GetUserData("appName")
		ACD.OpenFrames[appName] = nil
		AceGUI:Release(f)
	end)
	f:SetUserData("appName", appName)

	f:SetWidth(600)
	f:SetHeight(620)
	f:EnableResize(false)

	ACD:Open(addonName .. "-Welcome", f)
	if showChangelog then
		ACD:SelectGroup(addonName .. "-Welcome", "changelogTab")
	end
end

local function hideWelcomeScreen()
	ACD:Close(addonName .. "-Welcome")
end

ns.Welcome = {
	showWelcomeScreen = showWelcomeScreen,
	hideWelcomeScreen = hideWelcomeScreen,
}


