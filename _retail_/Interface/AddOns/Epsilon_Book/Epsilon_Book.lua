-------------------------------------------------------------------------------
-- Epsilon (2024)
-------------------------------------------------------------------------------

-- Main module
--
local addonName, ns = ...

local C_Epsilon = C_Epsilon;
local EpsiLib = EpsilonLib;
local LibDeflate = LibStub:GetLibrary("LibDeflate");
local AceSerializer = LibStub:GetLibrary("AceSerializer-3.0");

Epsilon_Book = LibStub("AceAddon-3.0"):NewAddon("Epsilon_Book");
Epsilon_Book.RealName = addonName

local SendCommand = EpsilonLib.AddonCommands.Register("Epsilon_Book");

local f = CreateFrame("Frame")
local loadCallbacks = {}

-------------------------------------------------------------------------------
-- Check if DM mode is currently enabled.
--
local function IsDMEnabled()
	if C_Epsilon.IsDM and (C_Epsilon.IsOfficer() or C_Epsilon.IsOwner()) then return true; else return false; end
end

-------------------------------------------------------------------------------
-- Check if player is ranked phase officer.
--
local function IsPhaseOfficer()
	if C_Epsilon.IsOfficer() then return true; else return false; end
end

-------------------------------------------------------------------------------
-- Check if player is ranked phase owner.
--
local function IsPhaseOwner()
	if C_Epsilon.IsOwner() then return true; else return false; end
end
-------------------------------------------------------------------------------
-- Check if player has a valid NPC targeted.
-- If not, give an appropriate error message.
--
local function HasValidGossipTarget()
	if not UnitExists("target") then
		UIErrorsFrame:AddMessage(SPELL_FAILED_BAD_IMPLICIT_TARGETS, 1.0, 0.0, 0.0, 53, 5);
		return false
	elseif UnitIsPlayer("target") then
		UIErrorsFrame:AddMessage(SPELL_FAILED_TARGET_IS_PLAYER, 1.0, 0.0, 0.0, 53, 5);
		return false
	elseif not UnitGUID("target"):find("Creature") then
		UIErrorsFrame:AddMessage(SPELL_FAILED_BAD_TARGETS, 1.0, 0.0, 0.0, 53, 5);
		return false
	elseif not (IsPhaseOwner() or IsPhaseOfficer()) then
		UIErrorsFrame:AddMessage("You must be the phase owner or an officer to do that.", 1.0, 0.0, 0.0, 53, 5);
		return false
	end
	return true
end

---------------------------------------------------------------------------
-- Get the GUID for a given unit.
--
local function GetUnitGUID(unit)
	local guid = UnitGUID(unit)
	if not (guid) then
		return;
	end
	if not (string.find(guid, "-")) then
		return guid;
	end

	local guidType, realmID, unitID = strsplit("-", guid);
	return unitID;
end

---------------------------------------------------------------------------
-- Generate a globally unique identifier (GUID).
--
local function GenerateGUID()
	local lastTime;
	local guid;

	if not (guid) then
		guid = string.gsub(string.gsub(GetUnitGUID("player"), "0x..", ""), "00[0]*", "")
	end

	local t = time();
	if t == 0 and not (lastTime) then
		t = random(100000);
	else
		t = t - 1315000000;
	end

	if lastTime and t <= lastTime then
		t = lastTime + 1;
	end
	lastTime = t;

	local hashTime = string.format("%X", t)

	return guid .. "_" .. hashTime;
end

---------------------------------------------------------------------------
-- Compress data for upload to phase.
--
local function CompressForUpload(str)
	str = AceSerializer:Serialize(str)
	str = LibDeflate:CompressDeflate(str, { level = 9 })
	str = LibDeflate:EncodeForWoWChatChannel(str)
	return str;
end

---------------------------------------------------------------------------
-- Decompress data for download from phase.
--
local function DecompressForDownload(str)
	str = LibDeflate:DecodeForWoWChatChannel(str)
	str = LibDeflate:DecompressDeflate(str)
	if str ~= "" and str ~= nil then
		_, str = AceSerializer:Deserialize(str)
	end
	return str;
end

local b = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'

---------------------------------------------------------------------------
-- Encrypt data for export codes.
--
local function Encrypt(data)
	return ((data:gsub('.', function(x)
		local r, b = '', x:byte()
		for i = 8, 1, -1 do r = r .. (b % 2 ^ i - b % 2 ^ (i - 1) > 0 and '1' or '0') end
		return r;
	end) .. '0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
		if (#x < 6) then return '' end
		local c = 0
		for i = 1, 6 do c = c + (x:sub(i, i) == '1' and 2 ^ (6 - i) or 0) end
		return b:sub(c + 1, c + 1)
	end) .. ({ '', '==', '=' })[#data % 3 + 1])
end

---------------------------------------------------------------------------
-- Decrypt data for export codes.
--
local function Decrypt(data)
	data = string.gsub(data, '[^' .. b .. '=]', '')
	return (data:gsub('.', function(x)
		if (x == '=') then return '' end
		local r, f = '', (b:find(x) - 1)
		for i = 6, 1, -1 do r = r .. (f % 2 ^ i - f % 2 ^ (i - 1) > 0 and '1' or '0') end
		return r;
	end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
		if (#x ~= 8) then return '' end
		local c = 0
		for i = 1, 8 do c = c + (x:sub(i, i) == '1' and 2 ^ (8 - i) or 0) end
		return string.char(c)
	end))
end

-------------------------------------------------------------------------
-- Save phase data.
--

local function SetPhaseData(prefix, data)
	if not (data and prefix) then
		return
	end

	data = CompressForUpload(data);
	EpsiLib.PhaseAddonData.Set(prefix, data);
end

-------------------------------------------------------------------------------
-- Generate a new book from an import code.
--
function EpsilonBook_ImportBook(text)
	if not (EPSILON_BOOK_LIST) then
		return
	end

	if not (text) or text == "" then
		PlaySound(47355);
		UIErrorsFrame:AddMessage("Invalid import code.", 1.0, 0.0, 0.0, 53, 5);
		return
	end

	text = Decrypt(text);
	local table = DecompressForDownload(text)

	--local _, table = AceSerializer:Deserialize(text)
	if not (table and table.icon and table.title and table.material and table.pages and table.fontFamily and table.fontSize) then
		PlaySound(47355);
		UIErrorsFrame:AddMessage("Invalid import code.", 1.0, 0.0, 0.0, 53, 5);
		return
	end

	local bookID = GenerateGUID();
	if EPSILON_BOOK_LIST[bookID] then
		-- GUIDs are seeded using time() so
		-- identicals can occur if generated
		-- within the same second!
		print("|cFFFF0000Error encountered generating book GUID. Please try again.");
		return
	end

	-- create new guid and add to book list...

	EPSILON_BOOK_LIST[bookID] = {
		icon = table.icon,
		title = table.title,
	};

	-- push new book to server...

	SetPhaseData("BOOK_DATA_" .. bookID, table);
	SetPhaseData("BOOK_LIST", EPSILON_BOOK_LIST);

	C_Timer.After(1, function() EpsilonBookLibrary_Update() end);
end

-------------------------------------------------------------------------------
-- Generate export code from book data.
--
function EpsilonBook_ExportBook(guid)
	if not (guid) then
		return
	end

	EpsilonLib.PhaseAddonData.Get("BOOK_DATA_" .. guid, loadCallbacks.export)
end

-------------------------------------------------------------------------------
-- Add a book GUID to an NPC so it auto opens to a book.
--
function EpsilonBook_TurnNPCIntoBook(guid)
	if not (guid) then
		return
	end

	if not (HasValidGossipTarget()) then
		return
	end

	SendChatMessage(".phase forge npc gossip enable", "GUILD");                      -- enable gossip on NPC
	SendChatMessage(".phase forge npc gossip text add <BOOK:" .. guid .. ">", "GUILD"); -- add the <BOOK:ID> tag
end

-------------------------------------------------------------------------------
-- Add a gossip option to the target NPC that links to a book.
--
function EpsilonBook_AddBookToNPCGossip(text, guid)
	if not (text and guid) then
		return
	end

	if not (HasValidGossipTarget()) then
		return
	end

	SendChatMessage(".phase forge npc gossip enable", "GUILD");                  -- enable gossip on NPC
	SendChatMessage(".ph f n g o a " .. text .. " <BOOK:" .. guid .. ">", "GUILD"); -- add the <BOOK:ID> tag
end

-------------------------------------------------------------------------------
-- Link a book directly to an item so it opens on right click.
--
function EpsilonBook_LinkItemToBook(itemID, guid)
	if not (itemID and guid) then
		return
	end

	if not (EPSILON_BOOK_ITEMS) then
		EpsilonBook_GetBookItemList(true);
		return
	end

	if not (EPSILON_BOOK_LIST and EPSILON_BOOK_LIST[guid]) then
		EpsilonBook_GetBookList(true);
		return
	end

	EPSILON_BOOK_ITEMS[itemID] = guid;
	SetPhaseData("EPSILON_BOOK_ITEMS", EPSILON_BOOK_ITEMS);

	EpsilonBookLibrary_Update();

	local bookLink = "|T" .. EPSILON_BOOK_LIST[guid].icon .. ":16|t |cFFFFFFFF[" .. EPSILON_BOOK_LIST[guid].title .. "]|r";
	--local itemName, itemLink = C_Item.GetItemInfo(itemID);
	print(bookLink .. "|cFFFFFF00 successfully linked to " .. itemID .. ".|r")
end

-------------------------------------------------------------------------------
-- Remove a book to item link.
--
function EpsilonBook_RemoveBookItemLink(itemID, guid)
	if not (itemID and guid) then
		return
	end

	if not (EPSILON_BOOK_ITEMS) then
		EpsilonBook_GetBookItemList(true);
		return
	end

	if not (EPSILON_BOOK_LIST and EPSILON_BOOK_LIST[guid]) then
		EpsilonBook_GetBookList(true);
		return
	end

	itemID = tostring(itemID);
	EPSILON_BOOK_ITEMS[itemID] = nil;
	SetPhaseData("EPSILON_BOOK_ITEMS", EPSILON_BOOK_ITEMS);

	EpsilonBookLibrary_Update();

	local bookLink = "|T" .. EPSILON_BOOK_LIST[guid].icon .. ":16|t |cFFFFFFFF[" .. EPSILON_BOOK_LIST[guid].title .. "]|r";
	--local itemName, itemLink = C_Item.GetItemInfo(itemID);
	print(bookLink .. "|cFFFFFF00 unlinked from " .. itemID .. ".|r")
end

-------------------------------------------------------------------------
-- Returns a list of all items linked to books.*
--
-- *Executes automatically on phase change.
--
function EpsilonBook_GetBookItemList(reasonFailed)
	if (reasonFailed) then
		print("|cFFFF0000Error encountered retrieving phase book item list. Please try again.");
	end
	-- Any previous list is irrelevant now.
	EPSILON_BOOK_ITEMS = {};

	EpsilonLib.PhaseAddonData.Get("EPSILON_BOOK_ITEMS", loadCallbacks.items)
end

-------------------------------------------------------------------------
-- Try to open a book linked to an item.
--
function EpsilonBook_TryBookFromItemID(itemID)
	if not (itemID) then
		return
	end

	itemID = tostring(itemID);

	if not (EPSILON_BOOK_ITEMS) then
		EpsilonBook_GetBookItemList();
		return
	end

	if EPSILON_BOOK_ITEMS[itemID] then
		EpsilonBook_LoadBook(EPSILON_BOOK_ITEMS[itemID])
		EpsilonBookFrame:ClearAllPoints();
		EpsilonBookFrame:SetPoint("TOPLEFT", UIParent, 16, -116);
	end
end

-------------------------------------------------------------------------
-- Returns a list of all books.
--
function EpsilonBook_GetBookList(reasonFailed)
	if (reasonFailed) then
		print("|cFFFF0000Error encountered retrieving phase book list. Please try again.");
	end
	EPSILON_BOOK_LIST = {};

	EpsilonLib.PhaseAddonData.Get("BOOK_LIST", loadCallbacks.list)
end

-------------------------------------------------------------------------
-- Load book data
--
function EpsilonBook_LoadBook(guid)
	if not (guid) then
		-- No GUID? >:(
		-- Fine, then no book!
		return
	end

	EpsilonLib.PhaseAddonData.Get("BOOK_DATA_" .. guid, function(text)
		loadCallbacks.book(text, guid);
	end)
end

-------------------------------------------------------------------------------
-- Generate a new book.
--
function EpsilonBook_CreateBook()
	if not EPSILON_BOOK_LIST then
		EpsilonBook_GetBookList(true);
		return
	end

	local data = {
		icon = "Interface/Icons/inv_misc_book_09",
		title = UnitName("player") .. "'s Book",
		material = "Book",
		pages = { [[]] },
		fontFamily = {
			p = "Frizqt",
			h1 = "Frizqt",
			h2 = "Frizqt",
			h3 = "Frizqt",
		},
		fontSize = {
			p = 13,
			h1 = 18,
			h2 = 16,
			h3 = 14,
		},
	}

	local guid = GenerateGUID();
	if EPSILON_BOOK_LIST[guid] then
		-- GUIDs are seeded using time() so
		-- identicals can occur if generated
		-- within the same second!
		print("|cFFFF0000Error encountered generating book GUID. Please try again.");
		return
	end

	return guid, data
end

-------------------------------------------------------------------------
-- Duplicate book data
--
function EpsilonBook_DuplicateBook(guid)
	if not (EPSILON_BOOK_LIST and guid) then
		return
	end

	EpsilonLib.PhaseAddonData.Get("BOOK_DATA_" .. guid, loadCallbacks.duplicate)
end

-------------------------------------------------------------------------
-- Delete book data
--
function EpsilonBook_DeleteBook(guid)
	if not (EPSILON_BOOK_LIST and guid) then
		return
	end

	EPSILON_BOOK_LIST[guid] = nil;

	SetPhaseData("BOOK_DATA_" .. guid, "");
	SetPhaseData("BOOK_LIST", EPSILON_BOOK_LIST);

	EpsilonBookLibrary_Update()
end

-------------------------------------------------------------------------
-- Save book data and send to server
--
function EpsilonBook_SaveCurrentBook()
	if not (EpsilonBookFrame.bookID and EpsilonBookFrame.bookData) then
		return
	end

	if EPSILON_BOOK_LIST then
		EPSILON_BOOK_LIST[EpsilonBookFrame.bookID] = {
			icon = EpsilonBookFrame.bookData.icon,
			title = EpsilonBookFrame.bookData.title,
		};

		for i = 1, #EpsilonBookFrame.bookData.pages do
			EpsilonBookFrame.bookData.pages[i]:gsub("\n", "[br]");
		end

		SetPhaseData("BOOK_DATA_" .. EpsilonBookFrame.bookID, EpsilonBookFrame.bookData);
		SetPhaseData("BOOK_LIST", EPSILON_BOOK_LIST);
	end
end

-------------------------------------------------------------------------------
-- Hook Gossip Options to check for <BOOK:GUID> tags.
--
local option_predicate = function(text, button)
	return text and text:match("<BOOK:.->")
end

local option_filter = function(newText, originalText)
	if (IsPhaseOfficer() or IsPhaseOwner()) and C_Epsilon.IsDM then
		newText = originalText:gsub("(<BOOK:.->)", "|cFFFF0000%1|r");
	else
		newText = originalText:gsub("<BOOK:.->", "");
	end
	return newText
end

local option_callback = function(self, button, down, originalText)
	local bookID = originalText:match("<BOOK:(.-)>");
	EpsilonLib.PhaseAddonData.Get("BOOK_DATA_" .. bookID, function(text)
		loadCallbacks.book(text, bookID, true, true);
	end)
end

EpsilonLib.Utils.Gossip:RegisterButtonHook(option_predicate, option_callback, option_filter)

-------------------------------------------------------------------------------
-- OnEvent handler for Gossip NPC books.
--
function EpsilonBook_OnEvent(self, event, ...)
	if (event == "GOSSIP_SHOW") then
		if UnitExists("npc") then
			local guid = UnitGUID("npc");
			local unitType, _, _, _, _, id, _ = strsplit("-", guid);
			if not (unitType == "Creature") then
				return
			end
			local gossipText = C_GossipInfo.GetText();
			if gossipText and gossipText:match("<BOOK:.->") then
				if (IsPhaseOfficer() or IsPhaseOwner()) and C_Epsilon.IsDM then
					GossipGreetingText:SetText(gossipText:gsub("(<BOOK:.->)", "|cFFFF0000%1|r"))
				else
					if ImmersionFrame then
						-- This doesn't work because of the whole 'fadeIn' it does I think.. but not sure the best way to solve it w/o modifying Immersion
						ImmersionFrame:SetAlpha(0)
						ImmersionFrame:EnableMouse(false);
					else
						GossipFrame:SetAlpha(0);
						GossipFrame:EnableMouse(false);
					end
					bookID = gossipText:match("<BOOK:(.-)>");
					EpsilonLib.PhaseAddonData.Get("BOOK_DATA_" .. bookID, function(text)
						loadCallbacks.book(text, bookID, true, true);
					end)
				end
			end
		end
	elseif (event == "GOSSIP_CLOSED") then
		if (EpsilonBookFrame:IsShown()) then
			EpsilonBookFrame_Hide()
			return;
		end
	elseif (event == "SCENARIO_UPDATE" or event == "PLAYER_ENTERING_WORLD") then
		EpsilonBook_GetBookItemList();
	end
end

-------------------------------------------------------------------------------
-- Add the Epsilon Book icon to the Epsilon Addon Tray.
--
local function CreateMinimapIcon()
	if not LibStub.libs["EpsiLauncher-1.0"] then
		C_Timer.After(0, CreateMinimapIcon)
		return
	end
	LibStub("EpsiLauncher-1.0").API.new("Epsilon Book", function()
		if EpsilonBookFrame:IsShown() then
			EpsilonBookFrame_Hide()
			return
		end

		if IsPhaseOfficer() or IsPhaseOwner() then
			EpsilonBookLibrary_Show()
		else
			UIErrorsFrame:AddMessage("You must be the phase owner or an officer to do that.", 1.0, 0.0, 0.0, 53, 5);
		end
	end, "Interface/AddOns/" .. addonName .. "/Texture/EpsilonTrayIconBook", { "Click to open the Book Library." })
end

-- CALLBACKS:

loadCallbacks.book = function(text, guid, isAttached, isGossip)
	text = DecompressForDownload(text);
	local canEdit = IsPhaseOfficer() or IsPhaseOwner();
	if isGossip then
		if text == "" then
			if ImmersionFrame then
				ImmersionFrame:SetAlpha(1);
				ImmersionFrame:EnableMouse(true);
			end
			GossipFrame:SetAlpha(1);
			GossipFrame:EnableMouse(true);
			if IsPhaseOfficer() or IsPhaseOwner() then
				EpsilonLib.Utils.Gossip:SetGreetingText("|cFFFF0000Error: Book " .. bookID .. " was not found and could not be displayed.|n|nMake sure the book was not deleted by mistake!");
			else
				EpsilonLib.Utils.Gossip:SetGreetingText("|cFFFF0000Error: Book " .. bookID .. " was not found and could not be displayed.|n|nReport this issue to a phase officer!");
			end
			return
		else
			if ImmersionFrame then
				ImmersionFrame:SetAlpha(0);
				ImmersionFrame:EnableMouse(false);
			else
				GossipFrame:SetAlpha(0);
				GossipFrame:EnableMouse(false);
			end
		end
	end
	if guid then
		EpsilonBookFrame_Show(guid, text, canEdit, isAttached);
	end
	PlaySound(SOUNDKIT.IG_SPELLBOOK_OPEN);
	if isAttached and not ImmersionFrame then
		EpsilonBookFrame:ClearAllPoints();
		EpsilonBookFrame:SetPoint("TOPLEFT", GossipFrame);
	end
end

loadCallbacks.list = function(text)
	text = DecompressForDownload(text);

	if text ~= "" then
		EPSILON_BOOK_LIST = text;
	else
		EPSILON_BOOK_LIST = {};
	end
	if EpsilonBookLibraryFrame:IsShown() then
		EpsilonBookLibrary_Update();
	end
end

loadCallbacks.items = function(text)
	text = DecompressForDownload(text);

	if text and text ~= "" then
		EPSILON_BOOK_ITEMS = text;
	else
		EPSILON_BOOK_ITEMS = {};
	end
end

loadCallbacks.duplicate = function(text)
	text = DecompressForDownload(text);
	-- obtain data from target book...

	-- create new guid
	local bookID = GenerateGUID();
	if EPSILON_BOOK_LIST[bookID] then
		-- GUIDs are seeded using time() so
		-- identicals can occur if generated
		-- LITERALLY WITHIN THE SAME SECOND!!!
		-- (don't do this...)
		print("|cFFFF0000Error encountered generating book GUID. Please try again.");
		return
	end

	-- add to book list
	EPSILON_BOOK_LIST[bookID] = {
		icon = text.icon,
		title = text.title,
	};

	-- upload to phase and add to phase list
	SetPhaseData("BOOK_DATA_" .. bookID, text);
	SetPhaseData("BOOK_LIST", EPSILON_BOOK_LIST);

	C_Timer.After(1, function() EpsilonBookLibrary_Update() end);
end

loadCallbacks.export = function(text)
	text = DecompressForDownload(text);

	text = CompressForUpload(text);
	text = Encrypt(text);
	EpsilonBookExportDialog.Title:SetText("Export Book");
	EpsilonBookExportDialog:Show();
	EpsilonBookExportDialog.ImportButton:Hide();
	EpsilonBookExportDialog.CancelButton:Show();
	EpsilonBookExportDialog.ImportControl.InputContainer.EditBox:SetText(text);
	EpsilonBookExportDialog.ImportControl.InputContainer:UpdateScrollChildRect();
	EpsilonBookExportDialog.ImportControl.InputContainer:SetVerticalScroll(EpsilonBookExportDialog.ImportControl.InputContainer:GetVerticalScrollRange());
	EpsilonBookExportDialog.ImportControl.InputContainer.EditBox:HighlightText();
	EpsilonBookExportDialog.ImportControl.InputContainer.EditBox:SetFocus();
end

-------------------------------------------------------------------------------
-- Init
--
function Epsilon_Book:OnInitialize()
	Epsilon_Book.RealName = addonName

	-- Borrowed from Arcanum / SpellCreator!
	local itemUseHooks = {
		["UseContainerItem"] = function(bagID, slot)
			local icon, itemCount, _, _, _, _, itemLink, _, _, itemID, _ = GetContainerItemInfo(bagID, slot)
			if IsEquippableItem(itemID) then return end
			EpsilonBook_TryBookFromItemID(itemID)
		end,
		["UseInventoryItem"] = function(slot)
			local itemID = GetInventoryItemID("player", slot)
			EpsilonBook_TryBookFromItemID(itemID)
		end,
	}

	for k, v in pairs(itemUseHooks) do
		hooksecurefunc(k, v)
	end

	GameTooltip:HookScript("OnTooltipSetItem", function(tooltip)
		local _, link = tooltip:GetItem()
		if not link then return; end

		local itemString = strmatch(link, "item[%-?%d:]+")
		local _, itemId = strsplit(":", itemString)

		--From idTip: http://www.wowinterface.com/downloads/info17033-idTip.html
		if itemId == "0" and TradeSkillFrame ~= nil and TradeSkillFrame:IsVisible() then
			if (GetMouseFocus():GetName()) == "TradeSkillSkillIcon" then
				itemId = GetTradeSkillItemLink(TradeSkillFrame.selectedSkill):strmatch("item:(%d+):") or nil
			else
				for i = 1, 8 do
					if (GetMouseFocus():GetName()) == "TradeSkillReagent" .. i then
						itemId = GetTradeSkillReagentItemLink(TradeSkillFrame.selectedSkill, i):strmatch("item:(%d+):") or nil
						break
					end
				end
			end
		end

		if not (EPSILON_BOOK_ITEMS) then
			return
		end

		if not (EPSILON_BOOK_ITEMS[itemId]) then
			return
		end

		itemId = tonumber(itemId);

		-- Store all text and text colours of the original tooltip lines.
		local leftText = {}
		local leftTextR = {}
		local leftTextG = {}
		local leftTextB = {}

		local rightText = {}
		local rightTextR = {}
		local rightTextG = {}
		local rightTextB = {}

		-- Store the number of lines for after ClearLines().
		local numLines = tooltip:NumLines()

		-- Store all lines of the original tooltip.
		local offset = 0;
		for i = 1, numLines, 1 do
			leftText[i] = _G[tooltip:GetName() .. "TextLeft" .. i]:GetText()
			leftTextR[i], leftTextG[i], leftTextB[i] = _G[tooltip:GetName() .. "TextLeft" .. i]:GetTextColor()

			rightText[i] = _G[tooltip:GetName() .. "TextRight" .. i]:GetText()
			rightTextR[i], rightTextG[i], rightTextB[i] = _G[tooltip:GetName() .. "TextRight" .. i]:GetTextColor()

			if leftText[i]:match("ItemID") then
				offset = 2;
			end
		end

		tooltip:ClearLines();

		-- Refill the tooltip with the stored lines plus my added lines.
		local found;
		for i = 1, numLines do
			if rightText[i] then
				tooltip:AddDoubleLine(leftText[i], rightText[i], leftTextR[i], leftTextG[i], leftTextB[i], rightTextR[i], rightTextG[i], rightTextB[i])
			else
				-- TODO: Unfortunately I do not know how to store the "indented word wrap".
				--       Therefore, we have to put wrap=true for all lines in the new tooltip.
				if not (found) and i > 1 and (leftText[i]:find("^Use:") or leftText[i]:find("^Equip:") or leftText[i]:match("[\"].-[\"]") or leftText[i]:find("^Requires") or leftText[i]:find("^Durability") or leftText[i]:match("ItemID")) then
					found = true;
					tooltip:AddLine("<Right Click to Read>", 0, 1, 0, true);
				end

				if leftText[i] ~= [[""]] and leftText[i] ~= "" then -- force skip blank description lines if there was one.
					tooltip:AddLine(leftText[i], leftTextR[i], leftTextG[i], leftTextB[i], true)
				end

				if not (found) and i == (numLines - offset) then
					tooltip:AddLine("<Right Click to Read>", 0, 1, 0, true);
				end
			end
		end

		--tooltip:Show();
	end)

	EpsilonBookFrame:RegisterEvent("GOSSIP_SHOW")
	EpsilonBookFrame:RegisterEvent("GOSSIP_CLOSED")
	EpsilonBookFrame:RegisterEvent("SCENARIO_UPDATE")
	EpsilonBookFrame:RegisterEvent("PLAYER_ENTERING_WORLD")

	Epsilon_Book.RegisteredPrefixes = {};

	hooksecurefunc(GossipFrame, "Hide", function(self)
		self:SetAlpha(1);
		self:EnableMouse(true)
	end);
	if ImmersionFrame then
		hooksecurefunc(ImmersionFrame, "Hide", function(self)
			self:SetAlpha(1);
			self:EnableMouse(true);
		end);
	end

	EpsilonBookFrame:SetScript("OnEvent", EpsilonBook_OnEvent);
	CreateMinimapIcon()
end
