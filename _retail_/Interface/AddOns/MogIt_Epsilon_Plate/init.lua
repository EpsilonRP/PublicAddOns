local addon,s = ...;
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


--- DEFINE THE BASE MODULE FUNCS

local module_base = {}

--// Base Functions
local list = {};

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
	mog:SetModule(self.arg1, self.arg1.label.." - "..self.value.label);
	CloseDropDownMenus();
end

function module_base.Dropdown(module, tier)
	local info;
	if tier == 1 then
		info = UIDropDownMenu_CreateInfo();
		info.text = module.label..(module.loaded and "" or " \124cFFFFFFFF("..L["Click to load addon"]..")");
		info.value = module;
		info.colorCode = "\124cFF"..(module.loaded and "00FF00" or "FF0000");
		info.hasArrow = module.loaded;
		info.keepShownOnClick = not module.loaded;
		info.notCheckable = true;
		info.func = module_base.DropdownTier1;
		if not module.loaded then
			if module.version < mog.moduleVersion then
				info.tooltipOnButton = true;
				info.tooltipTitle = RED_FONT_COLOR_CODE..ADDON_INTERFACE_VERSION;
				info.tooltipText = L["This module was created for an older version of MogIt and may not work correctly."];
			elseif module.version > mog.moduleVersion then
				info.tooltipOnButton = true;
				info.tooltipTitle = RED_FONT_COLOR_CODE..ADDON_INTERFACE_VERSION;
				info.tooltipText = L["This module was created for a newer version of MogIt and may not work correctly."];
			end
		end
		UIDropDownMenu_AddButton(info, tier);
	elseif tier == 2 then
		for _,slot in ipairs(module.slotList) do
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
	frame.data.items = value;
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
	mog.Item_FrameUpdate(frame, frame.data);
end

function module_base:OnEnter(frame, value)
	local data = frame.data;
	mog.ShowItemTooltip(frame, data.item, data.items);
end

function module_base:OnClick(frame, btn, value)
	mog.Item_OnClick(frame, btn, frame.data);
end

function module_base.Unlist(module)
	wipe(list);
end

local function itemSort(a, b)
	local aLevel = mog:GetData("item", a, "level") or 0;
	local bLevel = mog:GetData("item", b, "level") or 0;
	if aLevel == bLevel then
		return a < b;
	else
		return aLevel < bLevel;
	end
end
local function nameSort(a, b)


    item1 = mog:GetItemInfo(a[1])
    item2 = mog:GetItemInfo(b[1])
    
    if item1 ~= nil and item2 ~= nil then
        return item1.name < item2.name;
    end



end
local function buildList(module, slot, list, items)
	local startTime = GetTime();
	--print("|cff00ccff[MogIt]|r debug: list build started at: "..startTime);

	local endTime;
	for _, item in ipairs(slot) do
		if mog:CheckFilters(module,item) then
			local display = mog:GetData("item", item, "display");
			if display then
				if not items[display] then
					items[display] = {};
					tinsert(list, items[display]);
				end
				tinsert(items[display], item);
				
			end
		end	
	end

	endTime = GetTime();
	--print("|cff00ccff[MogIt]|r debug: list build ended at: "..endTime);
	--print(MogIt.db.profile.toggleDebug)
	if mog.db.profile.toggleDebug then
		print("|cff00ccff[MogIt]|r debug: list built in "..(endTime-startTime).."ms.")
	end
	--table.sort(tab, list)
end

function module_base.BuildList(module)
	wipe(list);
	local items = {};
	if module.active then
		buildList(module, module.active.list, list, items);
	else
		for _, data in pairs(module.slots) do
			buildList(module, data.list, list, items);
		end

	end
	
	local searchTimer_OnUpdate = function(self, elapsed)
		local searchesEachFrame = 1024;
		local startIndex = self.startIndex;
		
		for _,tbl in ipairs(list) do
			sort(tbl, itemSort);
		end
	
		-- for i = startIndex, startIndex + searchesEachFrame do
			-- sort(tbl, itemSort);
		-- end
		self.startIndex = startIndex + searchesEachFrame;
	

	end
	
	
	items = nil;
	return list;
	
end




--- CREATE OUR MODULE

local module = mog:GetModule(addon) or mog:RegisterModule(addon, tonumber(GetAddOnMetadata(addon, "X-MogItModuleVersion")));
local defaults = {
	slots = {},
	slotList = {},

	Dropdown = module_base.Dropdown,
	BuildList = module_base.BuildList,
	FrameUpdate = module_base.FrameUpdate,
	OnEnter = module_base.OnEnter,
	OnClick = module_base.OnClick,
	Unlist = module_base.Unlist,
	Help = module_base.Help,
	GetFilterArgs = module_base.GetFilterArgs,
	filters = {
		"name",
		"level",
		"itemLevel",
		"faction",
		"class",
		"source",
		"quality",
		"bind",
		"chestType",
		-- (addon == "MogIt_OneHanded" and "slot") or nil,
	},

	sorting = {
		"display",
	},
	sorts = {},
}

for k,v in pairs(defaults) do
	module[k] = v
end

function s.AddSlot(slot, addon)
	local module = mog:GetModule(addon);
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
		mog:AddData("item", id, "display", display);
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


