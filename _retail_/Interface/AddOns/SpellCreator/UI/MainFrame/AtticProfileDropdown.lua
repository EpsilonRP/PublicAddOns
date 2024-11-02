---@class ns
local ns = select(2, ...)

-- DEV NOTE: This used to be the profile dropdown.
-- It has migrated to handling all spell options, but due to not wanting to fuck with removing & adding a file for renaming it,
-- it's staying named as ProfileDropdown in the files...
-- This does still contain the profile selection & it's logic, so there's that!

local Constants = ns.Constants
local ProfileFilter = ns.ProfileFilter
local SavedVariables = ns.SavedVariables
local Tooltip = ns.Utils.Tooltip

local Dropdown = ns.UI.Dropdown

local ADDON_COLORS = Constants.ADDON_COLORS
local DEFAULT_PROFILE_NAME = ProfileFilter.DEFAULT_PROFILE_NAME

local markEditorUnsaved
local optionsDropdown
local PLAYER_NAME = UnitName("player") --[[@as string]]

local selectedProfile
---@return string profileName
local function getSelectedProfile()
	return selectedProfile or DEFAULT_PROFILE_NAME
	--return optionsDropdown.Text:GetText()
end

---@param profileName? string
local function setSelectedProfile(profileName)
	if not profileName then
		profileName = DEFAULT_PROFILE_NAME
	end

	selectedProfile = profileName
	--optionsDropdown.Text:SetText(profileName)
	markEditorUnsaved()
end

---@param profileName string
---@return DropdownItem
local function genFilterItem(profileName)
	return Dropdown.radio(profileName, {
		get = function()
			return getSelectedProfile() == profileName
		end,
		set = function()
			setSelectedProfile(profileName)
		end,
	})
end

---@param profileNames string[]
---@return DropdownItem[]
local function createProfileMenu(profileNames)
	local dropdownItems = {
		Dropdown.header("Select a Profile"),
		genFilterItem("Account"),
		genFilterItem(PLAYER_NAME),
	}

	for _, profileName in ipairs(profileNames) do
		tinsert(dropdownItems, genFilterItem(profileName))
	end

	tinsert(dropdownItems, Dropdown.input(ADDON_COLORS.GAME_GOLD:WrapTextInColorCode("Add New"), {
		tooltipTitle = "New Profile",
		tooltipText = "Set the spell you are currently editing to a new profile when saved.\n\r" ..
			Tooltip.genTooltipText("norevert", "Profiles added here will not show in menus until the spell is created/saved."),
		placeholder = "New Profile Name",
		get = function() end,
		set = function(self, text)
			setSelectedProfile(text)
		end,
	}))

	return dropdownItems
end

---@return string[]
local function getProfileNames()
	local profileNames = SavedVariables.getProfileNames(true, true)
	sort(SavedVariables.getProfileNames(true, true))
	return profileNames
end

--[[ -- // This is the old profileDropdown creation function. TO-DO: Remove this on a future commit, keeping it for backup for now
---@param inject { mainFrame: SCForgeMainFrame, markEditorUnsaved: fun() }
local function createDropdown(inject)
	markEditorUnsaved = inject.markEditorUnsaved

	profileDropdown = Dropdown.create(inject.mainFrame, "SCForgeAtticProfileButton"):WithAppearance(75)
	profileDropdown:SetPoint("BOTTOMRIGHT", inject.mainFrame.Inset, "TOPRIGHT", 16, 0)
	profileDropdown:SetText(DEFAULT_PROFILE_NAME)

	profileDropdown.Button:SetScript("OnClick", function(self)
		Dropdown.open(createProfileMenu(getProfileNames()), profileDropdown)
	end)

	-- Fixes error when opening, clicking outside, then opening again
	profileDropdown.Button:SetScript("OnMouseDown", nil)


	Tooltip.set(profileDropdown.Button,
		"Assign Profile",
		"Assign this spell to the selected profile when created or saved.",
		{ delay = 0.3 }
	)

	return profileDropdown
end
--]]

------ OPTIONS HIJACK
---

-- Break On Movement
local breakOnMove
---@return boolean
local function getBreakOnMove()
	return breakOnMove or false
end

---@param enabled? boolean
local function setBreakOnMove(enabled)
	breakOnMove = enabled
	markEditorUnsaved()
end


---@param inject { mainFrame: SCForgeMainFrame, markEditorUnsaved: fun() }
---@return DropdownItem[]
local function createOptionsMenu(inject)
	local dropdownItems = {
		Dropdown.header("Spell Options:"),

		Dropdown.submenu("Castbar Style", {
			Dropdown.radio("Castbar", {
				get = function() return ns.UI.MainFrame.Attic.getInfo().castbar == 1 end,
				set = function()
					ns.UI.MainFrame.Attic.setCastbarType(1)
					markEditorUnsaved()
				end,
			}),
			Dropdown.radio("Channel", {
				get = function() return ns.UI.MainFrame.Attic.getInfo().castbar == 2 end,
				set = function()
					ns.UI.MainFrame.Attic.setCastbarType(2)
					markEditorUnsaved()
				end,
			}),
			Dropdown.radio("None", {
				get = function() return ns.UI.MainFrame.Attic.getInfo().castbar == 0 end,
				set = function()
					ns.UI.MainFrame.Attic.setCastbarType(0)
					markEditorUnsaved()
				end,
			}),
		}, {
			tooltipTitle = "Casting Bar Style",
			tooltipText =
			"Spells under 0.25s in length will not show a casting bar even if set; this is because it looks bad. You can force it manually if you want using a Castbar action.. but it looks bad!"
		}),

		Dropdown.submenu("Change Profile", createProfileMenu(getProfileNames())),

		Dropdown.checkbox("Break on Movement", {
			get = function() return breakOnMove end,
			set = function(self, val) setBreakOnMove(val) end,
			tooltipTitle = "Break on Movement",
			tooltipText = "Cancels casting the spell if the character begins moving.",
		})
	}

	return dropdownItems
end

-- We're going to hijack this as our options going forward!
---@param inject { mainFrame: SCForgeMainFrame, markEditorUnsaved: fun() }
local function createDropdown(inject)
	markEditorUnsaved = inject.markEditorUnsaved

	optionsDropdown = Dropdown.create(inject.mainFrame, "SCForgeAtticOptionsButton"):WithAppearance(75)
	optionsDropdown:SetPoint("BOTTOMRIGHT", inject.mainFrame.Inset, "TOPRIGHT", 16, 0)
	optionsDropdown:SetText("Options")

	optionsDropdown.Button:SetScript("OnClick", function(self)
		Dropdown.open(createOptionsMenu(inject), optionsDropdown)
	end)

	-- Fixes error when opening, clicking outside, then opening again
	optionsDropdown.Button:SetScript("OnMouseDown", nil)


	Tooltip.set(optionsDropdown.Button,
		"Spell Options",
		"Change various options for this spell, such as castbar, profile, and more.",
		{ delay = 0.3 }
	)

	return optionsDropdown
end

---@class UI_MainFrame_AtticProfileDropdown
ns.UI.MainFrame.AtticProfileDropdown = {
	createDropdown = createDropdown,
	getSelectedProfile = getSelectedProfile,
	setSelectedProfile = setSelectedProfile,

	getBreakOnMove = getBreakOnMove,
	setBreakOnMove = setBreakOnMove,
}
