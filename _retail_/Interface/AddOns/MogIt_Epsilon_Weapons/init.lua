local addon, s = ...;
local mog = MogIt;
local L = mog.L

local LBI = LibStub("LibBabble-Inventory-3.0"):GetUnstrictLookupTable();
local LBB = LibStub("LibBabble-Boss-3.0"):GetUnstrictLookupTable();
local tinsert = table.insert;
local sort = table.sort;
local ipairs = ipairs;
local select = select;


if mog.base.AddSlot then -- Default implementation available, just reset to using this and escape - modified mogit will handle the rest
	s.AddSlot = mog.base.AddSlot
	return
end

local allowUseGlobalModuleExtensionBase = true
--- DEFINE THE BASE MODULE FUNCS
local module_base = {}
if MogIt.ModuleExtension_Base and allowUseGlobalModuleExtensionBase then
	-- another ModuleExtension exists and created the base, and we can use it, so use it.
	module_base = MogIt.ModuleExtension_Base
else

	--// Base Functions

	function module_base.DropdownTier1(self)
		if self.value.loaded then
			self.value.active = nil;
			mog:SetModule(self.value, self.value.label);
		else
			LoadAddOn(self.value.name);
		end
	end

	function module_base.DropdownTier2(self)
		self.arg1.active = self.value;
		mog:SetModule(self.arg1, self.arg1.label .. " - " .. self.value.label);
		CloseDropDownMenus();
	end

	function module_base.Dropdown(module, tier)
		local info;
		if tier == 1 then
			info = UIDropDownMenu_CreateInfo();
			info.text = module.label .. (module.loaded and "" or " \124cFFFFFFFF(" .. L["Click to load addon"] .. ")");
			info.value = module;
			info.colorCode = "\124cFF" .. (module.loaded and "00FF00" or "FF0000");
			info.hasArrow = module.loaded;
			info.keepShownOnClick = not module.loaded;
			info.notCheckable = true;
			info.func = module_base.DropdownTier1;
			if not module.loaded then
				if module.version < mog.moduleVersion then
					info.tooltipOnButton = true;
					info.tooltipTitle = RED_FONT_COLOR_CODE .. ADDON_INTERFACE_VERSION;
					info.tooltipText = L["This module was created for an older version of MogIt and may not work correctly."];
				elseif module.version > mog.moduleVersion then
					info.tooltipOnButton = true;
					info.tooltipTitle = RED_FONT_COLOR_CODE .. ADDON_INTERFACE_VERSION;
					info.tooltipText = L["This module was created for a newer version of MogIt and may not work correctly."];
				end
			end
			UIDropDownMenu_AddButton(info, tier);
		elseif tier == 2 then
			for _, slot in ipairs(module.slotList) do
				info = UIDropDownMenu_CreateInfo();
				info.text = module.slots[slot].label;
				info.value = module.slots[slot];
				info.notCheckable = true;
				info.func = module_base.DropdownTier2;
				info.arg1 = module;
				UIDropDownMenu_AddButton(info, tier);
			end
		end
	end

	function module_base:FrameUpdate(frame, value)
		frame.data.items = value; -- this is a list of the items that we should be previewing
		frame.data.cycle = 1;
		frame.data.item = value[frame.data.cycle];
		for i, item in ipairs(value) do
			if GetItemCount(mog:ToNumberItem(item)) > 0 then
				frame:ShowIndicator("hasItem");
			end
			if mog.wishlist:IsItemInWishlist(item) then
				frame:ShowIndicator("wishlist");
			end
		end
		frame.model:Undress() -- force an undress before we dress, to clear any old items previewed
		mog.Item_FrameUpdate(frame, frame.data);
	end


	function module_base.GetFilterArgs(filter, item)
		if filter == "name" then
			return item:match(":(%d*):")
		elseif filter == "level" or filter == "quality" or filter == "itemLevel" or filter == "bind" or filter == "hasItem" or filter == "chestType" then
			return item;
		elseif filter == "source" then
			return mog:GetData("item", item, "source"), mog:GetData("item", item, "sourceinfo");
		else
			return mog:GetData("item", item, filter);
		end
	end

	function module_base.SortAlphabetical(items)
		return items;
	end

end

-- Create our Name Sort Option, if needed, otherwise assume one exists and allow just using it
if not mog:GetSort("name") then

	local sort_tracker = {}
	local function getItemData(itemID)

		if type(itemID) == "table" then
			itemID = itemID[1]
		end

		if type(itemID) == "string" then
			if itemID:find(":") then
				itemID = tonumber(itemID:match(":(%d*):"))
			end
		end

		local _itemData = mog:GetItemInfo(itemID)
		if not _itemData then 
			_itemData = GetItemInfo(itemID)
			local newItemInfo
			if _itemData then
				newItemInfo = {
					name = _itemData[1]
				}
				return newItemInfo
			end
		else
			return _itemData
		end
	end

	local function dropdownTier1(self)
		local module = mog:GetModule(addon)
		local slotLabel = module.active.label
		if sort_tracker[addon] and sort_tracker[addon][slotLabel] then
			-- we've already sorted this before? Go!
			mog:SortList("name")
		else
			-- haven't sorted this before, let's try and preload some, and delay calling the actual sort
			if not sort_tracker[addon] then sort_tracker[addon] = {} end
			sort_tracker[addon][slotLabel] = true

			-- PRELOAD SOME DATA IF WE CAN..
			for i = 1, #mog.list do
				getItemData(mog.list[i])
			end

			-- And delay call hoping our pre-load is done
			print(("|cff00ccff[MogIt]|r Sorting by %s Item Names (loading names) ... "):format(slotLabel))
			C_Timer.After(1, function() mog:SortList("name") end);
		end
	end

	local function nameSort(a, b)
		local item1 = getItemData(a[1])
		local item2 = getItemData(b[1])

		if item1 ~= nil and item2 ~= nil then
			return item1.name < item2.name;
		end
	end

	mog:CreateSort("name", {
		label = L["Name"],
		Dropdown = function(dropdown, module, tier)
			local info = UIDropDownMenu_CreateInfo();
			info.text = L["Name"];
			info.value = "name";
			info.func = dropdownTier1;
			info.checked = mog.sorting.active == "name";
			info.tooltipOnButton = true;
			info.tooltipTitle = "Sort by Name (Alphabetical)";
			info.tooltipText = "Takes a second to sort on the first run.\n\rIf it does not load properly the first time you click sort, some items may not have been cached yet. Sort back by Display, and then by Name and it should work then!";
			dropdown:AddButton(info, tier);
		end,
		Sort = function(args)
			table.sort(mog.list, nameSort)
		end
	})
end

--- CREATE OUR MODULE
local newDefaults = {
	slots = {},
	slotList = {},

	Dropdown = module_base.Dropdown,
	BuildList = mog.base.BuildList,
	FrameUpdate = module_base.FrameUpdate,
	OnEnter = mog.base.OnEnter,
	OnClick = mog.base.OnClick,
	Unlist = mog.base.Unlist,
	Help = mog.base.Help,
	GetFilterArgs = module_base.GetFilterArgs,
	filters = {
		"name",
		"chestType",
		-- (addon == "MogIt_OneHanded" and "slot") or nil,
	},
	sorting = {
		"display",
		"name",
		"alphabetical",
	},
	sorts = {},
}
local module = mog:RegisterModule(addon, tonumber(GetAddOnMetadata(addon, "X-MogItModuleVersion")), newDefaults);

for k, v in pairs(newDefaults) do
	module[k] = v
end

--[[
if module then -- MogIt says this is 'needed for a bug fix' - Fuck that, these buttons don't even work.
	if not module.filters then module.filters = {} end
	tinsert(module.filters, "hasItem");
end
--]]

local function noop() end
function s.AddSlot(slot, addon)
	local module = mog:GetModule(addon);
	if not module then return noop end
	
	if not module.slots[slot] then
		module.slots[slot] = {
			label = LBI[slot] or slot,
			list = {},
		};
		tinsert(module.slotList, slot);
	end
	local list = module.slots[slot].list;

	return function(itemID, bonusID, display, quality, lvl, faction, class, bind, slot, source, sourceid, zone, sourceinfo)
		local id = mog:ToStringItem(itemID, bonusID);
		tinsert(list, id);
		-- function mog:AddData(data, id, key, value)
		-- 	mog.data[data][key][id] = value;
		-- 	mog.data["item"]["display"][123456] = nil;

		mog:AddData("item", id, "display", display);
		mog:AddData("item", id, "bonusID", bonusID);
		mog:AddData("item", id, "quality", quality);
		mog:AddData("item", id, "level", lvl);
		mog:AddData("item", id, "faction", faction);
		mog:AddData("item", id, "class", class);
		mog:AddData("item", id, "bind", bind);
		mog:AddData("item", id, "slot", slot);
		mog:AddData("item", id, "source", source);
		mog:AddData("item", id, "sourceid", sourceid);
		mog:AddData("item", id, "sourceinfo", sourceinfo);
		mog:AddData("item", id, "zone", zone);
		tinsert(mog:GetData("display", display, "items") or mog:AddData("display", display, "items", {}), id);
	end
end
