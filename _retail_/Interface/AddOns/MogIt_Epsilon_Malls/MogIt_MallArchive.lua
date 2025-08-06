local ADDON_NAME, s = ...;
local mog = MogIt;
local L = mog.L

local VERSION = GetAddOnMetadata(ADDON_NAME, "X-MogItModuleVersion")
local addonName, addonTitle = GetAddOnInfo(ADDON_NAME)

local module = mog:GetModule(ADDON_NAME) or mog:RegisterModule(ADDON_NAME, VERSION, {
	label = addonTitle
});


local database = {
	--[[
	[1] = {
		name = "Epsilon (Cosmic)",
		doNotShowID = true,
		data = {
			name = {},
			items = {},
		},
	},
	[2] = {
		name = "Epsilon (Events)",
		doNotShowID = true,
		data = {
			name = {},
			items = {},
		}
	}
	--]]
}
local DB_PhaseLookup = { 1, } -- this needs to be regenerated on reload

local DB_PhaseSetsList = {
	[1] = { --[=[ npcID, npcID, ... ]=] } -- this should be an array of the npcIDs, used in the database.id.data.[name|items].npcID - Auto-Generated on reload, sorted in GUID order
}

local function update_DB_Caches()
	-- Clear current caches
	table.wipe(DB_PhaseLookup)
	table.wipe(DB_PhaseSetsList)

	-- Rebuild Caches
	for phaseId, info in pairs(database) do
		table.insert(DB_PhaseLookup, phaseId)
		DB_PhaseSetsList[phaseId] = {}

		local phaseSets = DB_PhaseSetsList[phaseId]
		for uID, name in pairs(info.data.name) do
			table.insert(phaseSets, uID)
		end

		-- npcGUID order
		table.sort(phaseSets)
	end

	-- PhaseID Order
	table.sort(DB_PhaseLookup)
end

update_DB_Caches()

local list = {}; -- The temp list to actually show; rebuilt on search or changing malls

function s.AddMall(phaseId, name)
	phaseId = tonumber(phaseId)
	if not phaseId then return error("Must supply phaseId as number") end
	if not database[phaseId] then
		if not name then name = EpsilonLib.Phases:Get():GetPhaseName() or ("Phase " .. phaseId) end

		database[phaseId] = {
			name = name,
			data = {
				name = {},
				items = {},
			}
		}

		table.insert(DB_PhaseLookup, phaseId)
	end
end

---@param phaseId number|string PhaseID that this belongs to
---@param id string We will use unitEntry in order to ensure they are unique entries but names can be the same, but not duplicate if selecting multiple times
---@param name string Name of the set for visual & search purposes
---@param items number[] array of the items in this set
local function AddData(phaseId, id, name, items)
	-- Add Mall to ensure it exists before we can add data to it - If it already exists, this will do nothing anyways
	s.AddMall(phaseId)

	if not database[phaseId].data.name[id] then               -- Didn't exist, make sure to cache it to the sets list array
		DB_PhaseSetsList[phaseId] = DB_PhaseSetsList[phaseId] or {} -- ensure it exists, or initiate it
		table.insert(DB_PhaseSetsList[phaseId], id)
	end

	database[phaseId].data.name[id] = name;
	database[phaseId].data.items[id] = items;
end

function s.RefreshList()
	local curSort = mog:GetActiveSort()
	mog:BuildList();
	mog:FilterUpdate();
	mog:SortList(curSort)
end

---@param phaseId number|string PhaseID that this belongs to
---@param id string We will use unitEntry in order to ensure they are unique entries but names can be the same, but not duplicate if selecting multiple times
---@param name string Name of the set for visual & search purposes
---@param items number[]|string[] array of the items in this set
---@param mogSetFormat boolean|nil if the items table is in the mogit set format instead of raw items format. If true, we trust the items, otherwise, we parse them for numbers into item strings if needed
---@param skipRefresh? boolean Skip the RefreshList
function s.AddSetToMall(phaseId, id, name, items, mogSetFormat, skipRefresh)
	-- auto-Phase:
	if not phaseId then phaseId = tonumber(C_Epsilon.GetPhaseId()) end

	-- auto-ID:
	if not tonumber(id) then
		id = select(6, strsplit("-", UnitGUID('target') or ''))
		id = tonumber(id)
	end
	if not id or id == '' then error("Invalid Set ID") end

	-- auto-Name:
	if not name then name = "Set " .. id end

	if type(items) == "string" then
		if items:find("MogIt") then
			--"[MogIt:9cJH;lN6k;KY1H;ynAx;hB0n;Cvey;w7xs;doTg;pZfU:00:0]"
			items = mog:LinkToSet(items)
			mogSetFormat = true
		else
			items = { strsplit(",", items) }
			mogSetFormat = false
		end
	end

	if not mogSetFormat then
		local newItems = {}
		for k, v in ipairs(items) do
			local vType = type(v)
			if vType == "number" then
				v = mog:ToStringItem(v)
			end
			table.insert(newItems, v)
		end

		items = newItems
	end

	-- Add the data to the database &
	AddData(phaseId, id, name, items)

	if not skipRefresh then
		s.RefreshList()
	end
end

local function DropdownTier2(self)
	module.active = self.value
	local moduleString = ("Mall: %s - Phase: %s")
	if database[self.value].doNotShowID then
		moduleString = ("Mall: %s")
	end
	mog:SetModule(self.arg1, moduleString:format(database[self.value].name or "<Unknown>", self.value));
	CloseDropDownMenus();
end

local function DropdownTier3(self)
	module.active = self.value
	mog:SetModule(self.arg1, "Sub Mall - " .. self.value);
	CloseDropDownMenus();
end

function module.Dropdown(module, tier)
	local info;
	if tier == 1 then
		info = UIDropDownMenu_CreateInfo();
		info.text = module.label;
		info.value = module;
		info.colorCode = "\124cFF00FF00";
		info.hasArrow = true;
		info.keepShownOnClick = true;
		info.notCheckable = true;
		UIDropDownMenu_AddButton(info, tier);
	elseif tier == 2 then
		for k, v in ipairs(DB_PhaseLookup) do
			info = UIDropDownMenu_CreateInfo();
			if database[v].doNotShowID then
				info.text = database[v].name             -- Name Only, No ID
			else
				info.text = ("%s (%s)"):format(database[v].name, v); -- Display Only
			end
			info.value = v;                              -- Phase Id
			info.notCheckable = true;
			info.hasArrow = true;
			info.func = DropdownTier2;
			info.arg1 = module;
			UIDropDownMenu_AddButton(info, tier);
		end
	end
end

function module.FrameUpdate(module, self, value)
	local phaseId = module.active
	self.data.set = value;
	self.data.items = database[phaseId].data.items[value];
	self.data.name = database[phaseId].data.name[value];
	mog.Set_FrameUpdate(self, self.data);
end

function module:OnEnter(frame, value)
	local phaseId = self.active
	mog.ShowSetTooltip(frame, frame.data.items, frame.data.name)
end

function module.OnClick(module, self, btn, value)
	mog.Set_OnClick(self, btn, self.data);
end

function module.Unlist(module)
	wipe(list);
end

function module.BuildList(module)
	wipe(list);
	for k, v in ipairs(DB_PhaseSetsList[module.active]) do
		local nameFilter = mog:GetFilter("name").edit:GetText()
		if nameFilter == "" or database.data.name[v]:find(nameFilter) then
			tinsert(list, v)
		end
	end
	return list;
end

module.Help = {
	L["Shift-left click to link"],
	L["Shift-right click for set URL"],
	L["Ctrl-left click to try on in dressing room"],
	L["Ctrl-right click to preview with MogIt"],
	L["Right click for additional options"],
}

module.filters = {
	"name",
};
module.sorting = {
	"emog_set_none",
	"emog_set_name",
	"emog_set_id",
}
module.sorts = {}

--#region Sorting

do -- emog_set_none
	local sortID, sortName = "emog_set_none", "None"
	local function dropdownTier1(self)
		mog:SortList(sortID);
	end

	mog:CreateSort(sortID, {
		label = L[sortName],
		Dropdown = function(dropdown, module, tier)
			local info = UIDropDownMenu_CreateInfo();
			info.text = L[sortName];
			info.value = sortID;
			info.func = dropdownTier1;
			info.checked = mog.sorting.active == sortID;
			dropdown:AddButton(info, tier);
		end,
		Sort = function(args)

		end,
	});
end


do -- emog_set_name
	local sortID, sortName = "emog_set_name", "Set Name"
	local function dropdownTier1(self)
		mog:SortList(sortID);
	end

	local function sortFunc(a, b)
		local phaseId = module.active
		local setNameA = database[phaseId].data.name[a]
		local setNameB = database[phaseId].data.name[b]

		return setNameA < setNameB;
	end

	mog:CreateSort(sortID, {
		label = L[sortName],
		Dropdown = function(dropdown, module, tier)
			local info = UIDropDownMenu_CreateInfo();
			info.text = L[sortName];
			info.value = sortID;
			info.func = dropdownTier1;
			info.checked = mog.sorting.active == sortID;
			dropdown:AddButton(info, tier);
		end,
		Sort = function(args)
			table.sort(mog.list, sortFunc);
		end,
	});
end

do -- emog_set_id
	local sortID, sortName = "emog_set_id", "Set ID"
	local function dropdownTier1(self)
		mog:SortList(sortID);
	end

	local function sortFunc(a, b)
		return a < b;
	end

	mog:CreateSort(sortID, {
		label = L[sortName],
		Dropdown = function(dropdown, module, tier)
			local info = UIDropDownMenu_CreateInfo();
			info.text = L[sortName];
			info.value = sortID;
			info.func = dropdownTier1;
			info.checked = mog.sorting.active == sortID;
			dropdown:AddButton(info, tier);
		end,
		Sort = function(args)
			table.sort(mog.list, sortFunc);
		end,
	});
end

--#endregion


-- Global Accessor // LAZY!
MogIt_EMOG = s
s.db = database
s.dbCache = {
	phases = DB_PhaseLookup,
	sets = DB_PhaseSetsList
}

local f = CreateFrame("FRAME")
f:RegisterEvent("ADDON_LOADED")
f:RegisterEvent("PLAYER_LOGOUT")
f:SetScript("OnEvent", function(self, event, name)
	if event == "ADDON_LOADED" and name == ADDON_NAME then
		if EpsilonMOGMall_DB then MergeTable(database, EpsilonMOGMall_DB) end
		update_DB_Caches()

		EpsilonMOGMall_DB = database

		self:UnregisterEvent("ADDON_LOADED")
	elseif event == "PLAYER_LOGOUT" then
		-- Space saving; do not store the Epsilon Hard coded stuff
		EpsilonMOGMall_DB[1] = nil
		EpsilonMOGMall_DB[2] = nil
	end
end)
