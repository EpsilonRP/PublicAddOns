local EpsilonLib, EpsiLib = ...;

EpsiLib.Modules.UnitPopupMenus = {}

------------------------
-- Unit Popups

local function cmd(text)
	SendChatMessage("." .. text, "GUILD");
end

local function eval(test, ...)
	if type(test) == "function" then return test(...) end
	return test
end

local UnitPopupsModule = {};

UnitPopupsModule.MenuButtons = {};
UnitPopupsModule.MenuEntries = {};

function UnitPopupsModule:ShouldCustomizeMenus()
	if InCombatLockdown() then
		return false;
	else
		return true;
	end
end

function UnitPopupsModule:GetButtonsForMenu(menuType, unit)
	local entries = self.MenuEntries[menuType];
	local buttons = {};

	if entries then
		for _, buttonId in ipairs(entries) do
			local button = self.MenuButtons[buttonId];

			if (button.ShouldShow == nil) or eval(button.ShouldShow, unit) then
				table.insert(buttons, button);
			end
		end
	end

	return buttons;
end

function UnitPopupsModule:OnUnitPopupShown(dropdownMenu, menuType, unit, name, userData, ...)
	local buttons
	if not dropdownMenu or dropdownMenu:IsForbidden() then
		return; -- Invalid or forbidden menu.
	elseif UIDROPDOWNMENU_MENU_LEVEL ~= 1 then
		-- We support submenus now thx
		if dropdownMenu.menuList then
			buttons = dropdownMenu.menuList
		end
	else
		buttons = self:GetButtonsForMenu(menuType, unit);
	end

	if not buttons or not next(buttons) then
		return; -- No buttons to be shown.
	end

	if UIDROPDOWNMENU_MENU_LEVEL == 1 then
		UIDropDownMenu_AddSeparator();
		UIDropDownMenu_AddButton(self.MenuButtons.TitleBar);
	end

	for _, button in ipairs(buttons) do
		if button.text == " " then
			UIDropDownMenu_AddSeparator(UIDROPDOWNMENU_MENU_LEVEL);
		else
			local copy = CopyTable(button)
			copy.disabled = eval(copy.disabled)
			if (copy.ShouldShow == nil) or eval(copy.ShouldShow, unit) then
				UIDropDownMenu_AddButton(copy, UIDROPDOWNMENU_MENU_LEVEL);
			end
		end
	end
end

hooksecurefunc("UnitPopup_ShowMenu", function(...) return UnitPopupsModule:OnUnitPopupShown(...); end);

-- util references:
-- UnitIsConnected(unit)
-- UnitIsPlayer(unit)

local function getItemInfoFromHyperlink(link)
	local strippedItemLink, itemID = link:match("|Hitem:((%d+).-)|h");
	if itemID then
		return tonumber(itemID), strippedItemLink;
	end
end

Mixin(UnitPopupsModule.MenuButtons, {
	TitleBar = {
		text = "Epsilon",
		isTitle = true,
		isUninteractable = true,
		notCheckable = true,
	},

	Appear = {
		text = "Appear",
		colorCode = "|cff00ccff",
		notCheckable = true,
		func = function()
			local unitpopupframe = UIDROPDOWNMENU_INIT_MENU
			cmd("appear " .. unitpopupframe.name)
		end,
		ShouldShow = function(unit) return UnitIsPlayer(unit) end,
	},
	Summon = {
		text = "Summon",
		colorCode = "|cff00ccff",
		notCheckable = true,
		func = function()
			local unitpopupframe = UIDROPDOWNMENU_INIT_MENU
			cmd("summon " .. unitpopupframe.name)
		end,
		ShouldShow = function(unit) return UnitIsPlayer(unit) end,
	},
	Epsilon_Phase = {
		text = "Phase",
		colorCode = "|cff00ccff",
		hasArrow = true,
		notCheckable = true,
		ShouldShow = function(unit) return C_Epsilon.IsOfficer() and UnitIsPlayer(unit) end,
		menuList = {
			{
				text = "Add to Whitelist",
				notCheckable = true,
				func = function()
					cmd("cheat mailbox")
				end,
			},
			{
				text = "Add Member",
				notCheckable = true,
				func = function()
					cmd("cheat mailbox")
				end,
			},
			{
				text = "Promote to Officer",
				notCheckable = true,
				ShouldShow = function() return C_Epsilon.IsOwner() end,
				func = function()
					cmd("cheat mailbox")
				end,
			},
			{
				text = " ",
			},
			{
				text = "Kick",
				notCheckable = true,
				func = function()
					cmd("cheat mailbox")
				end,
			},
			{
				text = "Demote Officer",
				notCheckable = true,
				ShouldShow = function() return C_Epsilon.IsOwner() end,
				func = function()
					cmd("cheat mailbox")
				end,
			},
			{
				text = "Add to Blacklist",
				notCheckable = true,
				func = function()
					cmd("cheat mailbox")
				end,
			},
		}
	},
	Epsilon_Cheats = {
		text = "Cheats",
		colorCode = "|cff00ccff",
		hasArrow = true,
		notCheckable = true,
		ShouldShow = function(unit) return UnitIsUnit(unit, "player") end,
		menuList = {
			{
				text = "Toggle Fly",
				isNotRadio = true,
				--notCheckable = true,
				func = function()
					cmd("cheat fly")
				end,
				checked = function() return EpsiLib.Cheat.Status.fly end,
			},
			{
				text = "Casttime",
				isNotRadio = true,
				func = function()
					cmd("cheat casttime")
				end,
				checked = function() return EpsiLib.Cheat.Status.casttime end,
			},
			{
				text = "Cooldown",
				isNotRadio = true,
				func = function()
					cmd("cheat cooldown")
				end,
				checked = function() return EpsiLib.Cheat.Status.cooldown end,
			},
			{
				text = "Duration",
				isNotRadio = true,
				func = function()
					cmd("cheat duration")
				end,
				checked = function() return EpsiLib.Cheat.Status.duration end,
			},
			{
				text = "God",
				isNotRadio = true,
				func = function()
					cmd("cheat god")
				end,
				checked = function() return EpsiLib.Cheat.Status.god end,
			},
			{
				text = "Power",
				isNotRadio = true,
				func = function()
					cmd("cheat power")
				end,
				checked = function() return EpsiLib.Cheat.Status.power end,
			},
			{
				text = "Slowcast",
				isNotRadio = true,
				func = function()
					cmd("cheat slowcast")
				end,
				checked = function() return EpsiLib.Cheat.Status.slowcast end,
			},
			{
				text = "Waterwalk",
				isNotRadio = true,
				func = function()
					cmd("cheat waterwalk")
				end,
				checked = function() return EpsiLib.Cheat.Status.waterwalk end,
			},
			{
				text = " ",
			},
			{
				text = "Bank",
				notCheckable = true,
				func = function()
					cmd("cheat bank")
				end,
			},
			{
				text = "Barber",
				notCheckable = true,
				func = function()
					cmd("cheat barber")
				end,
			},
			{
				text = "Mailbox",
				notCheckable = true,
				func = function()
					cmd("cheat mailbox")
				end,
			},
		}
	},
	StealMog = {
		text = "Preview in MogIt",
		colorCode = "|cff00ccff",
		notCheckable = true,
		func = function()
			local npc_name = UnitName("target")
			local guid = UnitGUID("target")
			local phaseID = C_Epsilon.GetPhaseId()
			local unitType, _, _, _, _, npc_id, _ = strsplit("-", guid)

			EpsiLib.AddonCommands._SendAddonCommand("npc info", function(success, messages)
				if not success or not messages then
					print("|cffff0000Error: 'npc info' command failed, You need to be in the creature's origin phase to gather info and be it's creator or a Phase officer|r")
					return
				end

				local outfitInformation = {}

				for _, line in ipairs(messages) do
					local cleanLine = line:gsub("|cff%x%x%x%x%x%x", ""):gsub("|r", "")
					-- Also clean item links
					cleanLine = cleanLine:gsub("|H[^|]*|h", ""):gsub("|h", "")

					local slot, itemData = string.match(cleanLine, "^([^:]+):%s*%[(.+)")
					if slot and itemData then
						slot = slot:gsub("^%s+", ""):gsub("%s+$", "")

						-- Filter lines that are not really equipment
						if not (string.find(slot, "NPC") or string.find(slot, "Info")) then
							-- Use existing function to extract ID from item link
							local itemID, strippedLink = getItemInfoFromHyperlink(line)

							if itemID then
								local slotLower = string.lower(slot)
								if slotLower:find("main") or slotLower:find("off") or slotLower:find("ranged") then
									-- This is a weapon slot
									if not outfitInformation["_weapons"] then
										outfitInformation["_weapons"] = {}
									end
									if slotLower:find("main") then
										outfitInformation["_weapons"]["0"] = itemID
									elseif slotLower:find("off") then
										outfitInformation["_weapons"]["1"] = itemID
									elseif slotLower:find("ranged") then
										outfitInformation["_weapons"]["2"] = itemID
									end
								else
									-- This is equipment slot
									if not outfitInformation["_equipment"] then
										outfitInformation["_equipment"] = {}
									end
									outfitInformation["_equipment"][slot] = itemID
								end
							end
						end
					end
				end

				local preview = MogIt:GetPreview()
				local hasItems = false

				if outfitInformation["_equipment"] then
					for slot, itemID in pairs(outfitInformation["_equipment"] or {}) do
						MogIt.view.AddItem(itemID, preview, nil, true)
						hasItems = true
					end
				end
				if outfitInformation["_weapons"] then
					for slot, itemID in pairs(outfitInformation["_weapons"]) do
						MogIt.view.AddItem(itemID, preview, nil, true)
						hasItems = true
					end
				end

				local title = ("NPC Equipment - %s (%s-%s)"):format(npc_name or "Unknown", phaseID or "Unknown Phase", npc_id or "Unknown ID")
				preview.TitleText:SetText(title);
				preview.data.title = title;

				if not hasItems then
					print("|cffff0000Error: No valid equipment found on target NPC to open in MogIt. They may be using a default NPC Display ID instead of custom forged outfit.|r")
					return
				end
				ShowUIPanel(MogIt.view);
			end, false)
		end,
		ShouldShow = function(unit) return (not UnitIsPlayer(unit)) and C_Epsilon.IsOfficer() end,
	},
	--[[
	CharacterStatus = {
		text = L.DB_STATUS_RP_OOC,
		notCheckable = false,
		isNotRadio = true,
		keepShownOnClick = true,
		checked = IsOutOfCharacter,
		func = ToggleCharacterStatus,
		ShouldShow = true,
	},
    --]]
});

Mixin(UnitPopupsModule.MenuEntries, {
	CHAT_ROSTER    = { "Appear", "Summon", "Epsilon_Phase", },
	FRIEND         = { "Appear", "Summon", "Epsilon_Phase", },
	FRIEND_OFFLINE = { "Appear", "Summon", "Epsilon_Phase", },
	GUILD          = { "Appear", "Summon", "Epsilon_Phase", },
	GUILD_OFFLINE  = { "Appear", "Summon", "Epsilon_Phase", },
	PARTY          = { "Appear", "Summon", "Epsilon_Phase", },
	PLAYER         = { "Appear", "Summon", "Epsilon_Phase", },
	ENEMY_PLAYER   = { "Appear", "Summon", "Epsilon_Phase", },
	RAID           = { "Appear", "Summon", "Epsilon_Phase", },
	RAID_PLAYER    = { "Appear", "Summon", "Epsilon_Phase", },
	TARGET         = { "Appear", "Summon", "Epsilon_Phase", "StealMog" },
	FOCUS          = { "Appear", "Summon", "Epsilon_Phase", },


	SELF = { "Epsilon_Cheats", },
});
