---@class ns
local ns = select(2, ...)

local Constants = ns.Constants
local Cmd = ns.Cmd
local Execute = ns.Actions.Execute
local Gossip = ns.Gossip
local SavedVariables = ns.SavedVariables
local Vault = ns.Vault
local Permissions = ns.Permissions

local Tooltip = ns.Utils.Tooltip

local ChatLink = ns.UI.ChatLink
local Dropdown = ns.UI.Dropdown
local ImportExport = ns.UI.ImportExport
local LoadSpellFrame = ns.UI.LoadSpellFrame
local Popups = ns.UI.Popups

local ADDON_COLORS = ns.Constants.ADDON_COLORS
local VAULT_TYPE = Constants.VAULT_TYPE
local PLAYER_NAME = Constants.CHARACTER_NAME --[[@as string]]

local cmd = Cmd.cmd
local executeSpell = Execute.executeSpell
local getCurrentVault = LoadSpellFrame.getCurrentVault
local isOfficerPlus = Permissions.isOfficerPlus

---@type fun(index: integer)
local downloadToPersonal
---@type fun(spell: VaultSpell)
local loadSpell
---@type fun(commID: CommID)
local upload
---@type fun()
local updateRows

---@param commID CommID
---@param profileName string
local function setSpellProfile(commID, profileName)
	local spell = Vault.personal.findSpellByID(commID)

	if spell then
		spell.profile = profileName
	end
	Vault.personal.findSpellByID(commID).profile = profileName

	updateRows()
end

---@param spell VaultSpell
---@param profileName string
---@return DropdownItem
local function genProfileItem(spell, profileName)
	return Dropdown.radio(profileName, {
		get = function()
			return spell.profile == profileName
		end,
		set = function()
			setSpellProfile(spell.commID, profileName)
		end,
	})
end

---@return string[]
local function getProfileNames()
	local profileNames = SavedVariables.getProfileNames(true, true)
	sort(SavedVariables.getProfileNames(true, true))
	return profileNames
end

---@param spell VaultSpell
---@param isPhase boolean?
---@return DropdownItem
local function createAssignItemMenu(spell, isPhase)
	local hasSpells, items = ns.UI.ItemIntegration.manageUI.genItemMenuSubMenu(spell, isPhase)
	local shouldDisable = isPhase and not Permissions.isMemberPlus()
	local text = hasSpells and "Manage Items" or (shouldDisable and "No Items" or "Assign Items")
	return Dropdown.submenu(text, items, {
		disabled = not (hasSpells or not shouldDisable)
	})
end

---@param spell VaultSpell
---@return table<string, AceConfigOptionsTable>
local function getPhaseSpellArgs(spell)
	return {
		Dropdown.header(spell.fullName),
		Dropdown.execute(
			"Cast",
			function()
				executeSpell(spell.actions, nil, spell.fullName, spell)
			end
		),
		Dropdown.execute(
			"Edit",
			function()
				loadSpell(spell)
			end
		),
		Dropdown.divider(),
		Dropdown.execute(
			function()
				return Gossip.isLoaded() and "Add to Gossip" or "(Open a Gossip Menu)"
			end,
			function()
				Popups.showAddGossipPopup(spell.commID)
				-- Why the hell did we originally try and just click the button here? probably cuz we needed rowID, not commID..
				--_G["scForgeLoadRow" .. spell.commID].gossipButton:Click()

				-- Alt method is to add a row reference in the createMenu which is very easy to add, but lets do this for now.
			end,
			{
				disabled = function()
					return not (Gossip.isLoaded() and Permissions.isMemberPlus())
				end,
			}
		),
		Dropdown.execute(
			"Create Spark",
			function()
				ns.UI.SparkPopups.CreateSparkUI.openSparkCreationUI(spell.commID)
			end,
			{
				tooltipTitle = "Create a Spark!",
				tooltipText =
					"Sparks are Pop-up ArcSpell Icons that trigger when a player gets within range of the trigger location. Players can click the Spark's Icon to then cast the spell directly.\n\r"
					.. Tooltip.genTooltipText("example", "Set a Spark for a dark ritual ArcSpell at the center of a ritual circle!"),
				hidden = function()
					return not isOfficerPlus()
				end,
			}
		),
		createAssignItemMenu(spell, true),
	}
end

---@param spell VaultSpell
---@return DropdownItem
local function createProfileMenu(spell)
	local items = {
		Dropdown.header("Select a Profile"),
		genProfileItem(spell, "Account"),
		genProfileItem(spell, PLAYER_NAME),
	}

	for _, profileName in ipairs(getProfileNames()) do
		tinsert(items, genProfileItem(spell, profileName))
	end

	tinsert(items, Dropdown.input(ADDON_COLORS.GAME_GOLD:WrapTextInColorCode("Add New"), {
		tooltipTitle = "New Profile",
		tooltipText = "Assign this to a new profile.",
		placeholder = "New Profile Name",
		get = function() end,
		set = function(self, text)
			setSpellProfile(spell.commID, text)
		end,
	}))

	return Dropdown.submenu("Profile", items)
end

local function doesPageContainSpell(spell, page)
	if page.spells and tContains(page.spells, spell.commID) then
		return true
	end
	return false
end

---@param spell VaultSpell
---@param book QuickcastBook
---@return DropdownItem
local function genQCBookItem(spell, book)
	local items = {}

	for k, page in ipairs(book.savedData._pages) do
		local title = "Page " .. k .. (page.profileName and "* (" .. page.profileName .. ")" or "")
		tinsert(items, Dropdown.checkbox(title,
			{
				get = function() return doesPageContainSpell(spell, page) end,
				set = function(self, value)
					local spells = page.spells
					if value then
						tinsert(spells, spell.commID)
					else
						tremove(spells, tIndexOf(spells, spell.commID))
					end
				end,
				disabled = function() return page.profileName and true or false end
			}
		))
	end

	return Dropdown.selectmenu(book.savedData.name, items)
end

---@param spell VaultSpell
---@return DropdownItem
local function createAddQCMenu(spell)
	local items = {
		Dropdown.header("Assign to Quickcast Pages"),
	}

	for _, book in ipairs(ns.UI.Quickcast.Book.booksDB) do
		tinsert(items, genQCBookItem(spell, book))
	end

	return Dropdown.submenu("Assign Quickcast", items)
end

---@param spell VaultSpell
---@return DropdownItem
local function createStratacastMenu(spell)
	local items = { Dropdown.header("Stratacast") }
	local pos, data = ns.UI.Stratacast.get(spell.commID)
	if pos then
		tinsert(items, Dropdown.execute("Move Up", function() ns.UI.Stratacast.moveUp(pos) end))
		tinsert(items, Dropdown.execute("Move Down", function() ns.UI.Stratacast.moveDown(pos) end))
		tinsert(items, Dropdown.execute("Disconnect Spell", function() ns.UI.Stratacast.remove(spell.commID) end))
	else
		tinsert(items, Dropdown.execute("Connect", function() ns.UI.Stratacast.showAdder(spell) end))
	end

	return Dropdown.submenu("Stratacast", items, { hidden = function() return not SpellCreatorCharacterTable.stratacastEnabled end })
end

---@param spell VaultSpell
---@return DropdownItem
local function createAutoCastMenu(spell)
	return Dropdown.submenu("Toggle AutoCast", {
		Dropdown.header("AutoCast on Login:"),
		Dropdown.checkbox("Account-wide", {
			get = function() return ns.MainFuncs.isSpellInAccountAutoCast(spell.commID) end,
			set = function(self, value)
				if value then
					ns.MainFuncs.addSpellToAccountAutoCast(spell.commID)
				else
					ns.MainFuncs.removeSpellFromAccountAutoCast(spell.commID)
				end
			end,
			tooltipTitle = "Account-wide",
			tooltipText = "Automatically Cast this ArcSpell when you login to any character on this account.\n\r" ..
				"Note: Spells are cast on a slight delay, to allow the UI to finish loading.",
		}),
		Dropdown.checkbox("This Character", {
			get = function() return ns.MainFuncs.isSpellInCharAutoCast(spell.commID) end,
			set = function(self, value)
				if value then
					ns.MainFuncs.addSpellToCharAutoCast(spell.commID)
				else
					ns.MainFuncs.removeSpellFromCharAutoCast(spell.commID)
				end
			end,
			tooltipTitle = "This Character",
			tooltipText = "Automatically Cast this ArcSpell when you login to this character.\n\r" ..
				"Note: Spells are cast on a slight delay, to allow the UI to finish loading.",
		}),
	}, {})
end

---@param spell VaultSpell
---@return DropdownItem[]
local function getPersonalSpellItems(spell, isSB)
	local items = {
		Dropdown.header(spell.fullName),
		Dropdown.execute(
			"Cast",
			function()
				ARC:CAST(spell.commID)
			end
		),
		Dropdown.execute(
			"Edit",
			function()
				SCForgeMainFrame:Show()
				loadSpell(spell)
			end
		),
	}
	if not isSB then
		tinsert(items, createProfileMenu(spell))

		-- TODO change to input
		tinsert(items,
			Dropdown.execute(
				function()
					return spell.author and "Change Author" or "Assign Author"
				end,
				function()
					if spell.author then
						Popups.showAssignPersonalSpellAuthorPopup(spell.commID, spell.author)
					else
						Popups.showAssignPersonalSpellAuthorPopup(spell.commID)
					end
				end,
				{
					tooltipTitle = function()
						if spell.author then
							return "Change Author"
						end

						return "Assign Author"
					end,
					tooltipText = function()
						if spell.author then
							return "You can change the author of this spell. If you did not author this spell, please respect the original author and leave their credit.\n\rCurrent Author: " ..
								Tooltip.genContrastText(spell.author)
						end

						return "This spell has no assigned author. You can manually set the author now."
					end,
				}
			)
		)
	end
	table.insert(items, Dropdown.divider())

	table.insert(items, createAddQCMenu(spell))
	table.insert(items, createAssignItemMenu(spell))

	table.insert(items,
		Dropdown.execute(
			"Assign Hotkey",
			function()
				Popups.showLinkHotkeyDialog(spell.commID)
			end
		)
	)

	table.insert(items, createAutoCastMenu(spell))
	table.insert(items, createStratacastMenu(spell))

	return items
end

local function createSBMenu(commID)
	if not commID then return end
	local spell = Vault.personal.findSpellByID(commID)
	if not spell then return end

	local dropdownItems = getPersonalSpellItems(spell, true)
	tAppendAll(dropdownItems, {
		Dropdown.divider(),
		Dropdown.execute(
			"Chatlink",
			function()
				ChatLink.linkSpell(spell, VAULT_TYPE.PERSONAL)
			end
		),
		Dropdown.execute(
			"Export",
			function()
				ImportExport.exportSpell(spell)
			end
		),
	})

	return dropdownItems
end

---@param spell VaultSpell
---@return DropdownItem[]
local function createMenu(spell)
	local dropdownItems

	local vault = getCurrentVault()
	local isPhaseVault = (vault == VAULT_TYPE.PHASE)

	if isPhaseVault then
		dropdownItems = getPhaseSpellArgs(spell)
	else
		dropdownItems = getPersonalSpellItems(spell)
	end

	tAppendAll(dropdownItems, {
		Dropdown.divider(),
		Dropdown.execute(
			isPhaseVault and "Copy to Personal Vault" or "Copy to Phase Vault",
			function()
				if isPhaseVault then
					downloadToPersonal(Vault.phase.findSpellIndexByID(spell.commID))
				else
					upload(spell.commID)
				end
			end
		),
		Dropdown.execute(
			"Chatlink",
			function()
				ChatLink.linkSpell(spell, vault)
			end
		),
		Dropdown.execute(
			"Export",
			function()
				ImportExport.exportSpell(spell)
			end
		),
	})

	return dropdownItems
end

---@param row SpellLoadRow
---@param rowNum integer
local function createFor(row, rowNum)
	return Dropdown.create(row, "SCSpellLoadRowContextMenu" .. rowNum)
end

---@param row SpellLoadRow
---@param spell VaultSpell
local function show(row, spell)
	Dropdown.open(createMenu(spell), row.contextMenu, "cursor", 0, 0, "MENU")
end

local function showSB(sb, commID)
	Dropdown.open(createSBMenu(commID), sb.contextMenu, sb, 32, 0, "MENU")
end

---@param inject { loadSpell: fun(spell: VaultSpell), downloadToPersonal: fun(index: integer), upload: fun(commID: CommID), updateRows: fun() }
local function init(inject)
	loadSpell = inject.loadSpell
	downloadToPersonal = inject.downloadToPersonal
	upload = inject.upload
	updateRows = inject.updateRows
end

---@class UI_SpellLoadRowContextMenu
ns.UI.SpellLoadRowContextMenu = {
	init = init,
	createFor = createFor,
	show = show,
	showSB = showSB,
}
