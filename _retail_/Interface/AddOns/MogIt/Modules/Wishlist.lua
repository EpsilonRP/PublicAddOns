local _, MogIt = ...
local L = MogIt.L

local Wishlist = MogIt:RegisterModule("Wishlist", MogIt.moduleVersion)
MogIt.wishlist = Wishlist
Wishlist.base = true

Wishlist.filters = {
	"name",
	-- "level",
	-- "itemLevel",
	-- "faction",
	-- "class",
	-- "source",
	-- "quality",
	-- "bind",
	-- "chestType",
	"hasItem",
}

local itemSlots = {
	["HEAD"] = 1,
	["SHOULDER"] = 3,
	["SHIRT"] = 4,
	["CHEST"] = 5,
	["WAIST"] = 6,
	["LEGS"] = 7,
	["FEET"] = 8,
	["WRIST"] = 9,
	["HANDS"] = 10,
	["BACK"] = 15,
	["MAINHAND"] = 16,
	["OFFHAND"] = 17,
	["RANGED"] = 18,
	["TABARD"] = 19,
};

Wishlist.Help = {
	L["Right click for additional options"],
	L["Shift-left click to link"],
	L["Shift-right click for item URL"],
	L["Ctrl-left click to try on in dressing room"],
	L["Ctrl-right click to preview with MogIt"],
}

local function convertBowSlots()
	for i, set in ipairs(Wishlist.db.profile.sets) do
		local offhand = set.items["SecondaryHandSlot"]
		local item = offhand and MogIt:GetItemInfo(offhand, "convertBowSlots")
		if item and item.invType == "INVTYPE_RANGED" then
			set.items["MainHandSlot"] = offhand
			set.items["SecondaryHandSlot"] = nil
		end
	end
end

MogIt:AddItemCacheCallback("convertBowSlots", convertBowSlots)

local function onProfileUpdated(self, event)
	MogIt:BuildList(true, "Wishlist")
end

local defaults = {
	profile = {
		items = {},
		sets = {},
	}
}

function Wishlist:MogItLoaded()
	local db = LibStub("AceDB-3.0"):New("MogItWishlist", defaults)
	self.db = db

	local _, _, _, tocversion = GetBuildInfo()

	-- add alternate items table to sets
	for i, set in ipairs(db.profile.sets) do
		set.alternateItems = set.alternateItems or {}
	end

	-- convert all bows into main hand instead of off hand
	convertBowSlots()

	do -- convert to 6.0 string format
		for k, profile in pairs(self.db.profiles) do
			if profile.items then
				for k, item in pairs(profile.items) do
					if type(item) == "number" then
						profile.items[k] = MogIt:ToStringItem(item)
					end
				end
			end

			if profile.sets then
				for i, set in ipairs(profile.sets) do
					for k, item in pairs(set.items) do
						if type(item) == "number" then
							set.items[k] = MogIt:ToStringItem(item)
						end
					end
				end
			end
		end
	end

	-- convert item strings to 6.2 format
	if not db.global.version then
		local origPattern = MogIt.itemStringPattern
		MogIt.itemStringPattern = "item:(%d+):%d+:%d+:%d+:%d+:%d+:%d+:%d+:%d+:%d+:%d+:(%d+):([%d:]+)";

		for k, profile in pairs(self.db.profiles) do
			if profile.items then
				for k, item in pairs(profile.items) do
					profile.items[k] = MogIt:NormaliseItemString(item)
				end
			end

			if profile.sets then
				for i, set in ipairs(profile.sets) do
					for k, item in pairs(set.items) do
						set.items[k] = MogIt:NormaliseItemString(item)
					end
				end
			end
		end

		MogIt.itemStringPattern = origPattern
	end

	do -- update item strings wherever possible as the format changes
		for k, profile in pairs(self.db.profiles) do
			if profile.items then
				for k, item in pairs(profile.items) do
					profile.items[k] = MogIt:NormaliseItemString(item)
				end
			end

			if profile.sets then
				for i, set in ipairs(profile.sets) do
					for k, item in pairs(set.items) do
						set.items[k] = MogIt:NormaliseItemString(item)
					end
				end
			end
		end
	end

	db.global.version = tocversion

	db.RegisterCallback(self, "OnProfileChanged", onProfileUpdated)
	db.RegisterCallback(self, "OnProfileCopied", onProfileUpdated)
	db.RegisterCallback(self, "OnProfileReset", onProfileUpdated)
end

local function setModule(self)
	if MogIt.db.profile.loadModulesWishlist then
		MogIt:LoadBaseModules()
	end
	MogIt:SetModule(Wishlist, L["Wishlist"])
end

local function newSetOnClick(self)
	StaticPopup_Show("MOGIT_WISHLIST_CREATE_SET")
	CloseDropDownMenus()
end

local setMenu = {
	{ --Epsilon function
		text = L["|cff00ccffEquip Set|r"],
		func = function(self)
		end,
	},
	{
		text = L["Rename set"],
		func = function(self)
			Wishlist:RenameSet(self.value)
			CloseDropDownMenus()
		end,
	},
	{
		text = L["Delete set"],
		func = function(self)
			Wishlist:DeleteSet(self.value)
			CloseDropDownMenus()
		end,
	},
}

function Wishlist:Dropdown(level)
	if level == 1 then
		local info = UIDropDownMenu_CreateInfo()
		info.text = L["Wishlist"]
		info.value = self
		info.colorCode = YELLOW_FONT_COLOR_CODE
		info.notCheckable = true
		info.func = setModule
		UIDropDownMenu_AddButton(info, level)
	end
end

function Wishlist:FrameUpdate(frame, value, index)
	local data = frame.data
	if type(value) == "table" then
		data.name = value.name
		data.items = value.items
		MogIt.Set_FrameUpdate(frame, data)
	else
		data.item = value
		if MogIt:HasItem(MogIt:GetSourceFromItem(value), true) then
			frame:ShowIndicator("hasItem")
		end
		MogIt.Item_FrameUpdate(frame, data)
	end
end

function Wishlist:OnEnter(frame, value)
	if type(value) == "table" then
		MogIt.ShowSetTooltip(frame, value.items, value.name)
	else
		MogIt.ShowItemTooltip(frame, value, value)
	end
end

function Wishlist:OnClick(frame, button, value)
	if type(value) == "table" then
		MogIt.Set_OnClick(frame, button, frame.data, true)
	else
		MogIt.Item_OnClick(frame, button, frame.data, true)
	end
end

local list = {}

function Wishlist:BuildList()
	wipe(list)
	local db = self.db.profile
	for i, v in ipairs(self:GetSets(nil, true)) do
		if MogIt:CheckFilters(self, v) then
			list[#list + 1] = v
		end
	end
	for i, v in ipairs(db.items) do
		if MogIt:CheckFilters(self, v) then
			list[#list + 1] = v
		end
	end
	return list
end

function Wishlist.GetFilterArgs(filter, item)
	if filter == "name" or filter == "itemLevel" or filter == "hasItem" or filter == "chestType" then
		if type(item) ~= "table" then
			item = select(2, C_TransmogCollection.GetItemInfo(item))
		end
		return item
	end
end

local t = {}

-- returns a sorted array of existing wishlist profiles
function Wishlist:GetProfiles()
	self.db:GetProfiles(t)
	sort(t)
	return t
end

function Wishlist:GetCurrentProfile()
	return self.db:GetCurrentProfile()
end

function Wishlist:AddItem(item, setName, slot, isAlternate)
	item = MogIt:NormaliseItemString(item)
	-- don't add single items that are already on the wishlist
	if not setName and self:IsItemInWishlist(item, true, nil, true) then
		return false
	end
	-- if a valid set name was provided, the item is supposed to go into the set, otherwise be added as a single item
	local set = self:GetSet(setName)
	if set then
		if type(slot) ~= "string" then
			slot = nil
		end
		slot = slot or MogIt.slotsType[select(4, GetItemInfoInstant(item))]
		if isAlternate then
			local altItems = set.alternateItems[slot] or {}
			set.alternateItems[slot] = altItems
			tinsert(altItems, item)
		else
			set.items[slot] = item
		end
	else
		tinsert(self.db.profile.items, item)
	end
	return true
end

-- deletes an item from the database
-- if setName not provided, will look for a single item
-- if isAlternate is not true, will look among the primary items
function Wishlist:DeleteItem(itemID, setName, isAlternate)
	if setName then
		local set = assert(self:GetSet(setName), format("Set '%s' does not exist.", setName))
		if isAlternate then
			for slot, items in pairs(set.alternateItems) do
				for i, item in ipairs(items) do
					if item == itemID then
						tremove(items, i)
						if #items == 0 then
							set.alternateItems[slot] = nil
						end
						return
					end
				end
			end
		else
			for slot, item in pairs(set.items) do
				if item == itemID then
					set.items[slot] = nil
					return slot
				end
			end
		end
	else
		local items = self.db.profile.items
		for i = 1, #items do
			local v = items[i]
			if v == itemID then
				tremove(items, i)
				break
			end
		end
	end
end

function Wishlist:CreateSet(name)
	if self:GetSet(name) then
		return false
	end
	tinsert(self.db.profile.sets, {
		name = name,
		items = {},
		alternateItems = {},
	})
	return true
end

function Wishlist:RenameSet(set)
	StaticPopup_Show("MOGIT_WISHLIST_RENAME_SET", nil, nil, self:GetSet(set))
end

function Wishlist:DeleteSet(setName, noConfirm)
	if noConfirm then
		local sets = self:GetSets()
		for i, set in ipairs(sets) do
			if set.name == setName then
				tremove(sets, i)
				break
			end
		end
		MogIt:BuildList(nil, "Wishlist")
	else
		StaticPopup_Show("MOGIT_WISHLIST_DELETE_SET", setName, nil, setName)
	end
end

local function tableFind(tbl, value, token)
	if not tbl then return end
	for i, v in pairs(tbl) do
		if MogIt:GetSourceFromItem(v) == value or (token and token[v]) then
			return true
		end
	end
end

function Wishlist:IsItemInWishlist(item, noSet, profile, noAlts)
	if MogIt.db.profile.wishlistCheckAlts and not noAlts then
		local found = false
		local profiles = {}
		for i, profile in ipairs(self.db:GetProfiles()) do
			if self:IsItemInWishlist(item, nil, profile, true) then
				found = true
				tinsert(profiles, profile)
			end
		end
		return found, profiles
	end
	item = MogIt:NormaliseItemString(item)
	local token = MogIt.tokens[MogIt:ToNumberItem(item)]
	local items
	if profile then
		local profile = self.db.profiles[profile]
		if not profile then return end
		items = profile.items
	else
		items = self.db.profile.items
	end
	local _, item = C_TransmogCollection.GetItemInfo(item)
	if not item then return end
	if tableFind(items, item, token) then return true end
	if not noSet then
		local sets = self:GetSets(profile)
		if sets then
			for i, set in ipairs(sets) do
				if tableFind(set.items, item, token) then return true end
			end
		end
	end
	return false
end

local function sortAlpha(a, b)
	return a.name < b.name
end

local sortedSets = {}

function Wishlist:GetSets(profile, doSort)
	local sets
	if profile then
		assert(self.db.profiles[profile], format("Profile '%s' does not exist.", profile))
		sets = self.db.profiles[profile].sets
	else
		sets = self.db.profile.sets
	end
	if sets and doSort and MogIt.db.profile.sortWishlist then
		wipe(sortedSets)
		for i, set in ipairs(sets) do
			sortedSets[i] = set
		end
		sort(sortedSets, sortAlpha)
		sets = sortedSets
	end
	return sets
end

function Wishlist:GetSet(name, profile)
	for i, set in ipairs(self:GetSets(profile)) do
		if set.name == name then
			return set
		end
	end
end

function Wishlist:GetSetItems(setName, profile)
	return self:GetSet(setName, profile).items
end

local setFuncs = {
	addItem = function(self, set, item)
		if Wishlist:AddItem(item, set, select(4, GetItemInfoInstant(item)) == "INVTYPE_WEAPON" and IsShiftKeyDown() and "SecondaryHandSlot" or nil) then
			MogIt:BuildList(nil, "Wishlist")
		end
		CloseDropDownMenus()
	end,
}

function Wishlist:DeleteProfileSet(setName, noConfirm, profile)
	if noConfirm then
		local sets = Wishlist:GetSets(profile)
		for k, set in ipairs(sets) do
			if set.name == setName then
				tremove(sets, k)
				break
			end
		end
		print("|cff00ccff[MogIt]|r deleted set", setName, "from profile", profile)
		MogIt:BuildList(nil, "Wishlist")
	else
		StaticPopup_Show("MOGIT_WISHLIST_DELETE_PROFILE_SET", profile, setName)
	end
end

function Wishlist:AddSetMenuItems(level, func, arg2, profile)
	local sets = self:GetSets(profile, true)
	if not sets then
		return
	end

	local onehand
	if type(func) ~= "function" then
		func = setFuncs[func]
		if select(4, GetItemInfoInstant(arg2)) == "INVTYPE_WEAPON" then
			onehand = true
		end
	end
	for i, set in ipairs(sets) do
		local info = UIDropDownMenu_CreateInfo()
		info.text = set.name
		info.func = func
		info.notCheckable = true
		info.arg1 = set.name
		info.arg2 = arg2
		if onehand then
			info.tooltipTitle = "|cffffd200" .. L["Shift-click to add to off hand"] .. "|r"
			info.tooltipOnButton = true
		end
		UIDropDownMenu_AddButton(info, level)
	end
end

do
	local function onAccept(self, data)
		local text = self.editBox:GetText()
		local create = Wishlist:CreateSet(text)
		if not create then
			print("MogIt: A set with this name already exists.")
			return
		end
		if data then
			for slot, v in pairs(data.items) do
				Wishlist:AddItem(v, text, slot)
			end
			if data.previewFrame then
				data.previewFrame.TitleText:SetText(text)
				data.previewFrame.data.title = text
			end
		end
		MogIt:BuildList(nil, "Wishlist")
	end

	StaticPopupDialogs["MOGIT_WISHLIST_CREATE_SET"] = {
		text = L["Enter set name"],
		button1 = ACCEPT,
		button2 = CANCEL,
		hasEditBox = true,
		OnAccept = onAccept,
		EditBoxOnEnterPressed = function(self, data)
			local parent = self:GetParent()
			onAccept(parent, data)
			parent:Hide()
		end,
		OnShow = function(self, data)
			self.editBox:SetText(data and data.name or ("Set " .. (#Wishlist:GetSets() + 1)))
			self.editBox:HighlightText()
		end,
		whileDead = true,
	}
end

do
	local function onAccept(self, data)
		local text = self.editBox:GetText()
		local set = Wishlist:GetSet(text)
		if set then
			print("MogIt: A set with this name already exists.")
			return
		end
		data.name = text
		MogIt:BuildList(nil, "Wishlist")
	end

	StaticPopupDialogs["MOGIT_WISHLIST_RENAME_SET"] = {
		text = L["Enter new set name"],
		button1 = ACCEPT,
		button2 = CANCEL,
		hasEditBox = true,
		OnAccept = onAccept,
		EditBoxOnEnterPressed = function(self, data)
			local parent = self:GetParent()
			onAccept(parent, data)
			parent:Hide()
		end,
		OnShow = function(self, data)
			self.editBox:SetText(data.name)
			self.editBox:HighlightText()
		end,
		whileDead = true,
	}
end


StaticPopupDialogs["MOGIT_WISHLIST_DELETE_PROFILE_SET"] = {
	text = L["Delete profile %s set '%s'?"],
	button1 = YES,
	button2 = NO,
	OnAccept = function(self, data)
		--(self.text["text_arg1"], self.text["text_arg2"])
		Wishlist:DeleteProfileSet(self.text["text_arg2"], true, self.text["text_arg1"])
	end,
	whileDead = true,
}

StaticPopupDialogs["MOGIT_WISHLIST_DELETE_SET"] = {
	text = L["Delete set '%s'?"],
	button1 = YES,
	button2 = NO,
	OnAccept = function(self, data)
		Wishlist:DeleteSet(data, true)
	end,
	whileDead = true,
}

StaticPopupDialogs["MOGIT_WISHLIST_OVERWRITE_SET"] = {
	text = L["Overwrite set '%s'?"],
	button1 = YES,
	button2 = NO,
	OnAccept = function(self, data)
		local setName = data.name
		-- first clear all items since every slot might not be used
		wipe(Wishlist:GetSet(setName).items)
		for slot, v in pairs(data.items) do
			Wishlist:AddItem(v, setName, slot)
		end
		if data.previewFrame then
			data.previewFrame.TitleText:SetText(setName)
			data.previewFrame.data.title = setName
		end
		MogIt:BuildList(nil, "Wishlist")
	end,
	whileDead = true,
}

--EPSI

--EPSI EQUIP FUNCS

local function getBagPos(itemID, bonusID)
	--CHECK SLOTS
	local matchItem = 0;

	for k, v in pairs(itemSlots) do
		if GetInventoryItemID("player", v) ~= nil then
			eItem = tostring(GetInventoryItemID("player", v));
			if eItem == itemID then
				matchItem = 1;
			else
			end
		end
	end

	for bag = 0, NUM_BAG_SLOTS do
		for slot = 1, GetContainerNumSlots(bag) do
			local invItem = GetContainerItemLink(bag, slot);
			if invItem ~= nil and itemID ~= 0 then
				if invItem:match(itemID) then
					--equip item and set item exist flag to 1
					matchItem = 1;
				end
			else
			end
		end
	end
	if matchItem == 0 and itemID ~= 0 then
		SendChatMessage(".additem " .. itemID .. " 1 " .. bonusID, "GUILD");
	end
end

local function equipItem(itemID, slot)
	if itemID ~= 0 then
		C_Timer.NewTicker(1.5, function(self)
			if not MogIt.db.profile.toggleMessages then
				print("|cff00ccff[MogIt]|r equipping item: " .. itemID)
			end
			EquipItemByName(itemID);
			EquipPendingItem(0);
		end, 1)
	end
end

function Wishlist:equipLinkItems(set)
	--unequip everything first
	for k, v in pairs(itemSlots) do
		PickupInventoryItem(v);
		PutItemInBackpack();
	end
	for k, v in pairs(set) do
		local item = 0;
		local itemBonus = 0;
		if v ~= nil then
			item, itemBonus = v:match("item%:(%d*)%:(%d*)");
		end
		if item ~= nil then
			getBagPos(item, itemBonus);
			equipItem(item, itemSlot);
			if k == "MainHandSlot" then
				equipItem(item, 16)
				EquipPendingItem(16)
			end
			if k == "SecondaryHandSlot" then
				C_Timer.NewTicker(0.5, function(self)
					equipItem(item, slotID);
				end, 1)
			end
		end
	end
end

function Wishlist:mogequipWishlistItems(set, items)
	--unequip everything first
	for k, v in pairs(itemSlots) do
		PickupInventoryItem(v);
		PutItemInBackpack();
	end
	--second check if items are in backpack
	for k, v in pairs(items) do
		local itemSlot = GetInventorySlotInfo(k);
		local item = 0;
		local itemBonus = 0;
		if v ~= nil then
			item, itemBonus = v:match("item%:(%d*)%:(%d*)");
		end
		if item ~= nil then
			getBagPos(item, itemBonus);
			equipItem(item, itemSlot);
			if k == "MainHandSlot" then
				equipItem(item, 16)
				EquipPendingItem(16)
			end
			if k == "SecondaryHandSlot" then
				C_Timer.NewTicker(0.5, function(self)
					equipItem(item, slotID);
				end, 1)
			end
		end
	end
end

local function GetProfileFromString(profile)
	local profileString = "";
	for k, v in pairs(MogIt.wishlist.db.profiles) do
		for word in k:gmatch("[^%s]+") do
			for k1, v1 in pairs(profile) do
				if v1:lower() == word:lower() then
					profileString = profileString .. word;
					if profileString .. "-Apertus" == k:gsub("%s*", "") then
						profile = k;
						return profile;
					end
				end
			end
		end
	end
	profile = profileString:gsub("^%s", "") .. " - " .. GetRealmName();
	if profile == " - " .. GetRealmName() then
		profile = nil;
	end
	return profile;
end

local function GetSet(profile, setName)
	local setItems = nil;
	local sets = Wishlist:GetSets(profile)
	if sets then
		for i, set in pairs(sets) do
			local setN = set.name:gsub("%s*", ""):lower()
			if setN == setName then
				setName = set.name;
				setItems = MogIt.wishlist:GetSetItems(set.name, profile)
			end
		end
	end
	return setName, setItems;
end

local function ClearSet()
	local _slots =
	{ 1, --head
		2, --neck
		3, --shoulder
		4, --shirt
		5, --chest
		6, --belt
		7, --legs
		8, --feet
		9, --wrist
		10, --gloves
		11, --ring1
		12, --ring2
		13, --trinket1
		14, --trinket2
		15, --back
		16, --main hand
		17, --off hand
		19 }; --tabard

	for k, v in pairs(_slots) do
		PickupInventoryItem(v);
		PutItemInBackpack();
	end
end

local function CleanBags()
	for bag = 0, 4 do
		for slot = 1, GetContainerNumSlots(bag) do
			PickupContainerItem(bag, slot);
			DeleteCursorItem();
		end
	end
end

local function filterArgs(args)
	if args[1] == "clear" then
		print("|cff00ccff[MogIt]|r Clearing equipped items.")
		ClearSet();
		return false;
	end

	if args[1] == "clean" then
		print("|cff00ccff[MogIt]|r Clearing equipped items.")
		CleanBags();
		return false;
	end

	local argString = "";
	for k, v in pairs(args) do
		argString = argString .. v;
	end

	local profile = GetProfileFromString(args);
	if not profile then
		print("|cff00ccff[MogIt]|r profile not found.")
	else
		local setString = argString:gsub("%s*", ""):gsub(" - " .. GetRealmName(), ""):lower()
		local setS = setString:gsub(profile:gsub("-%s" .. GetRealmName(), ""):gsub("%s*", ""):lower(), "")
		local set, setItems = GetSet(profile, setS);

		if set and setItems then
			MogIt.wishlist:mogequipWishlistItems(set, setItems);
			print("|cff00ccff[MogIt]|r Equipping set:", set, "from profile", profile)
		else
			print("|cff00ccff[MogIt]|r Set not found.")
		end
	end
end


function Wishlist:EquipItems(profile, setName)
	profile = profile:gsub("^%l", string.upper) .. " - " .. GetRealmName();
	setName = setName:gsub("^%s", "");

	local found = false;
	for k, v in pairs(self.db.profiles) do
		if k:match(profile) then
			local sets = Wishlist:GetSets(profile)
			for i, set in pairs(sets) do
				if set.name == setName then
					local setItems = self:GetSetItems(set.name, profile)
					if setItems then
						self:mogequipWishlistItems(set.name, setItems);
						found = true;
						break;
					end
				end
			end
		end
	end
	if not found then
		print("|cff00ccff[MogIt]|r set|cff00ccff", setName, "|rfrom profile|cff00ccff", profile, "|rnot found.")
	end
end

--// Bindings
SLASH_MOGITE1 = "/moge";
SLASH_MOGITE2 = "/mogitequip";
local function handler(message, editBox)
	local messageContents = {}
	local arg = "";
	for word in message:gmatch("[^%s]+") do
		table.insert(messageContents, word)
	end

	for i = 2, table.getn(messageContents) do
		arg = arg .. messageContents[i];
	end

	filterArgs(messageContents);

	-- --First argument must be profile name, or help
	-- local profile = messageContents[1];
	-- local itemSet = "";
	-- if profile:match("[Hh]elp") then
	-- 	print("|cff00ccff[MogIt - Equip]|r Syntax: /mogitequip, /moge $profile $set.|ne.g. /moge John Long Trousers")
	-- else
	-- 	for i = 2, #messageContents do
	-- 		itemSet = itemSet .. " " .. messageContents[i];
	-- 	end
	-- 	if profile and itemSet then
	-- 		Wishlist:EquipItems(profile, itemSet)
	-- 	end
	-- end
end
SlashCmdList["MOGITE"] = handler;
