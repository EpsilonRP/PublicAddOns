-------------------------------------------------------------------------------
-- Epsilon (2022)
-------------------------------------------------------------------------------
-- Merchant Frame
--

local Me = Epsilon_Merchant;

-------------------------------------------------------------------------------
-- Static Popup Dialogs

StaticPopupDialogs["EPSILON_MERCHANT_ADD_ITEM"] = {
    text = "Enter itemID:",
    button1 = ACCEPT,
    button2 = CANCEL,
    OnAccept = function(self)
		Epsilon_MerchantAddItem( tonumber( self.editBox:GetText() ) or 0 )
    end,
    hasEditBox = true,
	hideOnEscape = true,
	enterClicksFirstButton = true,
}

-------------------------------------------------------------------------------

StaticPopupDialogs["EPSILON_MERCHANT_REMOVE_ITEM"] = {
    text = "Enter itemID:",
    button1 = ACCEPT,
    button2 = CANCEL,
    OnAccept = function(self)
		Epsilon_MerchantRemoveItem( tonumber( self.editBox:GetText() ) or 0 )
    end,
    hasEditBox = true,
	hideOnEscape = true,
	enterClicksFirstButton = true,
}

-------------------------------------------------------------------------------

StaticPopupDialogs["EPSILON_MERCHANT_DELETE_VENDOR"] = {
    text = "Are you sure you want to delete this vendor?|nWhen a vendor is deleted, their stock cannot be recovered!",
    button1 = ACCEPT,
    button2 = CANCEL,
    OnAccept = function()
		Epsilon_MerchantDeleteVendor();
    end,
	showAlert = true,
	hideOnEscape = true,
	enterClicksFirstButton = true,
}

-------------------------------------------------------------------------------

-- StaticPopupDialogs["EPSILON_MERCHANT_RESTOCK_ITEM"] = {
    -- text = "Enter quantity:",
    -- button1 = ACCEPT,
    -- button2 = CANCEL,
    -- OnAccept = function(self, data)
		-- Epsilon_MerchantRestockItem( data, tonumber( self.editBox:GetText() ) or 0 )
    -- end,
    -- hasEditBox = true,
	-- hideOnEscape = true,
	-- enterClicksFirstButton = true,
-- }

-------------------------------------------------------------------------------

StaticPopupDialogs["EPSILON_MERCHANT_SET_SOUND"] = {
    text = "Enter soundKitID:",
    button1 = ACCEPT,
    button2 = CANCEL,
    OnAccept = function(self, data)
		Epsilon_Merchant_SaveSound( data, tonumber( self.editBox:GetText() ) or 0 )
    end,
    hasEditBox = true,
	enterClicksFirstButton = true,
}

-------------------------------------------------------------------------------
-- MERCHANT INFO FUNCTIONS
-------------------------------------------------------------------------------

local MAX_MONEY_DISPLAY_WIDTH = 120;

-------------------------------------------------------------------------------
-- Get number of items on the vendor.
--
local function GetMerchantNumItems()
	if not( Epsilon_MerchantFrame.merchantID ) then
		return 0;
	elseif EPSILON_VENDOR_DATA[ Epsilon_MerchantFrame.merchantID ] then
		return #EPSILON_VENDOR_DATA[ Epsilon_MerchantFrame.merchantID ];
	end
	return 0;
end

-------------------------------------------------------------------------------
-- Get info about a specific item.
--
-- @params index The item's index in the vendor data array.
--
local function GetMerchantItemInfo( index )
	if not( index and Epsilon_MerchantFrame.merchantID ) then
		return
	end
	local name, _, _, _, _, _, _, _, _, _, _ = GetItemInfo(index);
	local itemID, _, _, _, texture = GetItemInfoInstant(index)
	if not EPSILON_VENDOR_DATA[Epsilon_MerchantFrame.merchantID] then
		return nil, nil, nil, nil, nil, nil, nil
	end
	for i = 1, #EPSILON_VENDOR_DATA[Epsilon_MerchantFrame.merchantID] do
		if tonumber( EPSILON_VENDOR_DATA[Epsilon_MerchantFrame.merchantID][i][1] ) == tonumber( index ) then
			local _, price, stackCount, currency, amount = unpack( EPSILON_VENDOR_DATA[Epsilon_MerchantFrame.merchantID][i] )
			itemID = tonumber( itemID )
			price = tonumber( price )
			stackCount = tonumber( stackCount )
			local extendedCost = false;
			if currency and amount then
				extendedCost = true;
			end
			return name, texture, price, stackCount, -1, true, true, extendedCost, currency or nil, amount or nil;
		end
	end
end

-------------------------------------------------------------------------------
-- Get an itemlink for a specific item.
--
-- @params index The item's index in the vendor data array.
--
local function GetMerchantItemLink( index )
	if not( index and Epsilon_MerchantFrame.merchantID ) then
		return
	end
	local name, itemLink = GetItemInfo(index);
	return name, itemLink;
end

-------------------------------------------------------------------------------
-- Check if we can afford an item.
--
-- @params index The item's index in the vendor data array.
--
local function CanAffordMerchantItem( index )
	if not( index and Epsilon_MerchantFrame.merchantID ) then
		return
	end

	local _, _, price, stackCount, _, _, _, extendedCost, currencyID, currencyAmount = GetMerchantItemInfo(index);

	local canAfford;
	if (price and price > 0) then
		if GetMoney() < price then
			return false, ERR_NOT_ENOUGH_MONEY;
		end
	end

	if (extendedCost) then
		local myCount = GetItemCount(currencyID, false, false, true);
		if myCount < tonumber( currencyAmount ) then
			return false, ERR_NOT_ENOUGH_CURRENCY;
		end
	end

	return true;
end

-------------------------------------------------------------------------------
-- Check if the vendor can repair items.
--
local function CanMerchantRepair()
	-- TODO
	return false;
end

-------------------------------------------------------------------------------
-- Get the number of currencies used by the item.
--
-- Note: Currently will always returns 1!
--
-- @params index 		The item's index in the vendor data array.
--
local function GetMerchantItemCostInfo( index )
	if not( index and Epsilon_MerchantFrame.merchantID ) then
		return
	end
	for i = 1, #EPSILON_VENDOR_DATA[Epsilon_MerchantFrame.merchantID] do
		if EPSILON_VENDOR_DATA[Epsilon_MerchantFrame.merchantID][i][1] == index and EPSILON_VENDOR_DATA[Epsilon_MerchantFrame.merchantID][i][4] then
			return 1;
		end
	end
	return 0;
end

-------------------------------------------------------------------------------
-- Get info for the currency cost of an item.
--
-- @params index 		The item's index in the vendor data array.
-- @params itemIndex 	The index for the required item cost type.
--
local function GetMerchantItemCostItem( index, itemIndex )
	if not( index and Epsilon_MerchantFrame.merchantID ) then
		return
	end

	-- Until multiple currencies are made possible, this will do the trick:
	if itemIndex > 1 then
		return
	end

	for i = 1, #EPSILON_VENDOR_DATA[Epsilon_MerchantFrame.merchantID] do
		if EPSILON_VENDOR_DATA[Epsilon_MerchantFrame.merchantID][i][1] == index and EPSILON_VENDOR_DATA[Epsilon_MerchantFrame.merchantID][i][4] then
			local currency = tonumber( EPSILON_VENDOR_DATA[Epsilon_MerchantFrame.merchantID][i][4] );
			local amount = tonumber( EPSILON_VENDOR_DATA[Epsilon_MerchantFrame.merchantID][i][5] );
			local name, link, _, _, _, _, _, _, _, texture, _ = GetItemInfo(currency);
			return texture, amount, link, name;
		end
	end
	return nil, nil, nil, nil;
end

-------------------------------------------------------------------------------
-- Get itemID for the currency cost of an item.
--
-- @params index 		The item's index in the vendor data array.
-- @params itemIndex 	The index for the required item cost type.
--
local function GetMerchantItemCostItemID( index, itemIndex )
	if not( index and Epsilon_MerchantFrame.merchantID ) then
		return
	end

	-- Until multiple currencies are made possible, this will do the trick:
	if itemIndex > 1 then
		return
	end

	for i = 1, #EPSILON_VENDOR_DATA[Epsilon_MerchantFrame.merchantID] do
		if EPSILON_VENDOR_DATA[Epsilon_MerchantFrame.merchantID][i][1] == index and EPSILON_VENDOR_DATA[Epsilon_MerchantFrame.merchantID][i][4] then
			local currency = tonumber( EPSILON_VENDOR_DATA[Epsilon_MerchantFrame.merchantID][i][4] );
			return currency;
		end
	end
	return
end

-------------------------------------------------------------------------------
-- Returns a table of the currencies used by the current vendor.
--
local function GetMerchantCurrencies()
	if not( Epsilon_MerchantFrame.merchantID ) then
		return
	end

	local currencies = {};
	for i = 1, #EPSILON_VENDOR_DATA[Epsilon_MerchantFrame.merchantID] do
		if EPSILON_VENDOR_DATA[Epsilon_MerchantFrame.merchantID][i][4] then
			local currency = tonumber( EPSILON_VENDOR_DATA[Epsilon_MerchantFrame.merchantID][i][4] );
			tinsert( currencies, currency );
		end
	end
	return currencies;
end

-------------------------------------------------------------------------------
-- Get the maximum stack size of an item.
--
-- @params index The item's index in the vendor data array.
--
local function GetMerchantItemMaxStack( index )
	if not( index and Epsilon_MerchantFrame.merchantID ) then
		return
	end
	local stackCount = 0
	for i = 1, #EPSILON_VENDOR_DATA[Epsilon_MerchantFrame.merchantID] do
		if EPSILON_VENDOR_DATA[Epsilon_MerchantFrame.merchantID][i][1] == index then
			stackCount = EPSILON_VENDOR_DATA[Epsilon_MerchantFrame.merchantID][i][3]
			break
		end
	end
	return stackCount
end

-------------------------------------------------------------------------------
-- MERCHANT ITEM FUNCTIONS
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Remove an item from the vendor.
--
-- @params itemID The itemID of the item.
--
function Epsilon_MerchantRemoveItem( itemID )
	if not Me.IsPhaseOwner() then
		return
	end
	if itemID and type(itemID) == "number" and itemID > 0 and GetItemInfo(itemID) then
		for i = 1, #EPSILON_VENDOR_DATA[Epsilon_MerchantFrame.merchantID] do
			if tonumber(EPSILON_VENDOR_DATA[Epsilon_MerchantFrame.merchantID][i][1]) == tonumber(itemID) then
				tremove( EPSILON_VENDOR_DATA[Epsilon_MerchantFrame.merchantID], i );
				break
			end
		end
	else
		PlaySound( 47355 );
		PrintMessage("SYSTEM", "Item not found.");
	end
	Epsilon_MerchantFrame_Update()
	Epsilon_Merchant_SaveVendor()
end

-------------------------------------------------------------------------------
-- Add an item to the vendor.
--
-- @params itemID The itemID of the item.
--
function Epsilon_MerchantAddItem( itemID )
	if not Me.IsPhaseOwner() then
		return
	end
	if itemID and type(itemID) == "number" and itemID > 0 and GetItemInfo(itemID) then
		if not EPSILON_VENDOR_DATA[Epsilon_MerchantFrame.merchantID] then
			EPSILON_VENDOR_DATA[Epsilon_MerchantFrame.merchantID] = {}
		end

		local found = false;
		for i = 1, #EPSILON_VENDOR_DATA[Epsilon_MerchantFrame.merchantID] do
			if EPSILON_VENDOR_DATA[Epsilon_MerchantFrame.merchantID][i][1] == itemID then
				PlaySound( 47355 );
				UIErrorsFrame:AddMessage( "That item is already sold by this vendor.", 1.0, 0.0, 0.0, 53, 5 );
				found = true;
				return
			end
		end

		if not( found ) then
			local name, _, _, _, _, _, _, stackCount, _, _, price = GetItemInfo(itemID);
			local itemData = { itemID, price, stackCount, -1 }
			tinsert(EPSILON_VENDOR_DATA[Epsilon_MerchantFrame.merchantID], itemData)
		end
	else
		PlaySound( 47355 );
		PrintMessage("SYSTEM", "Invalid item id: " .. itemID or 0 )
	end
	Epsilon_MerchantFrame_Update()
	Epsilon_Merchant_SaveVendor()
end

-------------------------------------------------------------------------------
-- Set the price of a vendor item.
--
-- @params itemID The itemID of the item.
-- @params price The price of the item (in copper).
--
function Epsilon_MerchantPriceItem( itemID, price )
	if not( Me.IsPhaseOwner() and itemID and price ) then
		return
	end
	itemID = tonumber( itemID )
	price = tonumber( price ) or 0
	if itemID and type(itemID) == "number" and itemID > 0 and GetItemInfo(itemID) and EPSILON_VENDOR_DATA[Epsilon_MerchantFrame.merchantID] then
		for i = 1, #EPSILON_VENDOR_DATA[Epsilon_MerchantFrame.merchantID] do
			if tonumber(EPSILON_VENDOR_DATA[Epsilon_MerchantFrame.merchantID][i][1]) == itemID then
				EPSILON_VENDOR_DATA[Epsilon_MerchantFrame.merchantID][i][2] = price;
			end
		end
	end
	Epsilon_MerchantFrame_Update()
	Epsilon_Merchant_SaveVendor()
end

-------------------------------------------------------------------------------
-- Delete the vendor.
--
-- *Note: This will PERMANENTLY erase the vendor's stock.
--
function Epsilon_MerchantDeleteVendor()
	if not Me.IsPhaseOwner() then
		return
	end
	if Epsilon_MerchantFrame.merchantID then
		-- Iterate through gossip options and remove any
		-- that match ours.
		--
		for i = 1, GetNumGossipOptions() do
			titleButton = _G["GossipTitleButton" .. i];
			titleButtonText = _G["GossipTitleButton" .. i]:GetText();
			if titleButtonText == "I want to browse your goods." then
				SendChatMessage( ".phase forge npc gossip option remove ".. ( i - 1 ), "GUILD" );
				Epsilon_MerchantFrame.removingVendor = true;
			end
		end
		EPSILON_VENDOR_DATA[Epsilon_MerchantFrame.merchantID] = {};
	else
		PlaySound( 47355 );
		PrintMessage("SYSTEM", "Vendor not found.");
	end
	Epsilon_MerchantFrame_Update()
	Epsilon_Merchant_SaveVendor()
	CloseGossip()
end

-------------------------------------------------------------------------------
-- Restock a limited supply vendor item.
--
-- @params itemID The itemID of the item.
-- @params amount The # of the item to restock.
--
-- function Epsilon_MerchantRestockItem( itemID, amount )
	-- if not( Me.IsPhaseOwner() and itemID and amount ) then
		-- return
	-- end
	-- itemID = tonumber( itemID )
	-- amount = tonumber( amount ) or -1
	-- if itemID and type(itemID) == "number" and itemID > 0 and GetItemInfo(itemID) and EPSILON_VENDOR_DATA[Epsilon_MerchantFrame.merchantID] then
		-- for i = 1, #EPSILON_VENDOR_DATA[Epsilon_MerchantFrame.merchantID] do
			-- if tonumber(EPSILON_VENDOR_DATA[Epsilon_MerchantFrame.merchantID][i][1]) == itemID then
				-- EPSILON_VENDOR_DATA[Epsilon_MerchantFrame.merchantID][i][4] = amount;
				-- return
			-- end
		-- end
	-- end
	-- Epsilon_MerchantFrame_Update()
	-- Epsilon_Merchant_SaveVendor()
-- end

-------------------------------------------------------------------------------
-- BUYBACK FUNCTIONS
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Add an item to the vendor.
--
-- @params itemID The itemID of the item.
--
local function GetNumBuybackItems()
	return #EPSILON_ITEM_BUYBACK or 0;
end

-------------------------------------------------------------------------------
-- Get an itemLink for a buyback item.
--
-- @params index The index of the item in the vendor data array.
--
local function GetBuybackItemLink( index )
	return GetMerchantItemLink( EPSILON_ITEM_BUYBACK[index]["itemID"] );
end

-------------------------------------------------------------------------------
-- Get info about a buyback item.
--
-- @params index The index of the item in the vendor data array.
--
local function GetBuybackItemInfo( index )
	if not( index and EPSILON_ITEM_BUYBACK[index] ) then
		return
	end
	if EPSILON_ITEM_BUYBACK[index] then
		local itemID = EPSILON_ITEM_BUYBACK[index]["itemID"];
		local price = EPSILON_ITEM_BUYBACK[index]["price"];
		local stackCount = EPSILON_ITEM_BUYBACK[index]["stackCount"];
		local name, _, _, _, _, _, _, _, _, texture, _ = GetItemInfo(itemID);
		return name, texture, price, stackCount, -1, true, true;
	else
		return nil, nil, nil, nil, -1, nil, nil
	end
end

-------------------------------------------------------------------------------
-- PURCHASE FUNCTIONS
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Purchase an item from the vendor.
--
-- @params itemID 	The itemID of the item.
-- @params amount 	The # of items to purchase.
--
local function BuyEpsilon_MerchantItem( itemID, amount )
	Epsilon_MerchantFrame.makingPurchase = true

	if not( amount ) then
		amount = 1
	end

	if CanAffordMerchantItem( itemID ) then
		local _, _, price, _, _, _, _, extendedCost, currencyID, currencyAmount = GetMerchantItemInfo( itemID )
		if price then
			SendChatMessage( ".mod money -" .. (price * amount), "GUILD" )
		end
		if extendedCost then
			SendChatMessage( ".additem "..currencyID.." -"..currencyAmount, "GUILD" )
		end
	else
		PlaySound( 47355 );
		UIErrorsFrame:AddMessage( select(2, CanAffordMerchantItem( itemID )), 1.0, 0.0, 0.0, 53, 5 );
		return
	end

	if not( stackCount ) then
		stackCount = 1;
	end

	SendChatMessage( ".additem " .. itemID .. " " .. ( amount * stackCount ), "GUILD" )
	C_Timer.After( 0.5, function() Epsilon_Merchant_PlaySound( "buyitem" ) end )
	Epsilon_MerchantFrame_Update()
end

-------------------------------------------------------------------------------
-- Sell an item to the vendor.
--
-- @params bag	The bag in which the item exists.
-- @params slot	The slot the item is occupying.
--
local function SellEpsilon_MerchantItem( bag, slot )
	local itemID = GetContainerItemID( bag, slot );
	local _, count = GetContainerItemInfo( bag, slot );
	if count and count > 0 then
		Epsilon_MerchantFrame.makingPurchase = true
		local _, _, price, _, _, _, _, extendedCost, currencyID, currencyAmount = GetMerchantItemInfo( itemID )
		if ( price and tonumber( price ) ~= nil and price > 0 ) or ( extendedCost and currencyID and currencyAmount ) then
			if price then
				SendChatMessage( ".mod money " .. ( tonumber( price ) * count), "GUILD" )
				SendChatMessage( ".additem "..itemID.." -"..count, "GUILD" )

				local item = {
					itemID = itemID;
					price = price;
					stackCount = count;
				}

				tinsert( EPSILON_ITEM_BUYBACK, 1, item );
			end

			if extendedCost then
				SendChatMessage( ".additem "..currencyID.." "..currencyAmount, "GUILD" )
			end
			--PlaySound(895)

			-- Purge any item data beyond the 12 item cap.
			if #EPSILON_ITEM_BUYBACK > 12 then
				for i = 1, #EPSILON_ITEM_BUYBACK do
					tremove( EPSILON_ITEM_BUYBACK, 12 + i );
				end
			end
		else
			PlaySound( 47355 );
			UIErrorsFrame:AddMessage( ERR_VENDOR_NOT_INTERESTED, 1.0, 0.0, 0.0, 53, 5 );
			return
		end
	end
	Epsilon_MerchantFrame_Update()
end

-------------------------------------------------------------------------------
-- Buyback an item from the vendor.
--
-- @params itemID 	The itemID of the item.
--
local function BuybackEpsilon_MerchantItem( itemID, amount )
	for i = 1, #EPSILON_ITEM_BUYBACK do
		if EPSILON_ITEM_BUYBACK[i]["itemID"] == itemID then
			tremove( EPSILON_ITEM_BUYBACK, i );
			BuyEpsilon_MerchantItem( itemID, amount );
			break
		end
	end
end

-------------------------------------------------------------------------------
-- INVENTORY SHENANIGANS
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Hook inventory items so we can use the OnClick handler
--
hooksecurefunc("ContainerFrameItemButton_OnClick", function( self, button )
	if not( Epsilon_MerchantFrame:IsShown() ) then
		return
	end

	if CursorHasItem() and Epsilon_MerchantFrame.PickupItem then
		BuyEpsilon_MerchantItem( Epsilon_MerchantFrame.PickupItem )
	elseif ( button == "RightButton" and Epsilon_MerchantFrame.selectedTab == 1 ) then
		SellEpsilon_MerchantItem( self:GetParent():GetID(), self:GetID() );
	end
	Epsilon_MerchantFrame.PickupItem = nil;
end)

-------------------------------------------------------------------------------
-- Change the cursor to the "sell" texture.
--
local function SetInventoryCursor( self )
	if ( Epsilon_MerchantFrame:IsShown() and Epsilon_MerchantFrame.selectedTab == 1 ) and not Epsilon_MerchantCursorOverlay:IsShown() then
		ShowContainerSellCursor(self:GetParent():GetID(),self:GetID());
	end
end

-------------------------------------------------------------------------------
-- Hook the cursor.
--
local function HookCursor( self )
	if GetMouseFocus() and type(GetMouseFocus()) == "table" and GetMouseFocus():GetName() and strfind(GetMouseFocus():GetName(), "ContainerFrame%d*Item") then
		SetInventoryCursor( GetMouseFocus() )
	end
end

-------------------------------------------------------------------------------
-- Yo-ho, yo-ho,
-- Near the hooks I'll never go...
--
hooksecurefunc("ContainerFrameItemButton_OnEnter", SetInventoryCursor)
hooksecurefunc("ContainerFrameItemButton_OnUpdate", SetInventoryCursor)
hooksecurefunc("ResetCursor", HookCursor)
hooksecurefunc("SetCursor", HookCursor)

function Epsilon_MerchantRefreshItemButtons()
	if not Epsilon_MerchantFrame.ItemButtons then
		Epsilon_MerchantFrame.ItemButtons = {}
	end

	local index = 1
	for x = 0, NUM_BAG_FRAMES, 1 do
		if ( GetContainerNumSlots(x) > 0 ) then
			for y = 1, GetContainerNumSlots(x) do
				local itemButton = Epsilon_MerchantFrame.ItemButtons[index]
				if not( itemButton ) then
					itemButton = CreateFrame("Button", "Epsilon_MerchantItemButtonDummy".. (x+1) .."Item"..y, _G["ContainerFrame".. (x+1) .."Item"..y], "Epsilon_MerchantItemButtonDummyTemplate")
					tinsert( Epsilon_MerchantFrame.ItemButtons, itemButton )
				end
				itemButton:SetPoint("CENTER", _G["ContainerFrame".. (x+1) .."Item"..y], "CENTER", 0, 0)
				itemButton.x = x
				itemButton.y = y
				itemButton:Show()
				index = index + 1
			end
		end
	end
end

-------------------------------------------------------------------------------
-- MERCHANT FRAME
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- When the Merchant Frame is loaded.
--
function Epsilon_MerchantFrame_OnLoad(self)
	self:RegisterEvent("BAG_UPDATE");
	self:RegisterEvent("GOSSIP_SHOW");
	self:RegisterEvent("GOSSIP_CLOSED");
	self:RegisterUnitEvent("UNIT_INVENTORY_CHANGED", "player");
	self:RegisterForDrag("LeftButton");
	self.page = 1;
	Epsilon_MerchantFrame.makingPurchase = false;
	Epsilon_MerchantFrame.addingVendor = false;
	Epsilon_MerchantFrame.removingVendor = false;
	-- Tab Handling code
	PanelTemplates_SetNumTabs(self, 2);
	PanelTemplates_SetTab(self, 1);

	if self.NineSlice then
		self.NineSlice:SetFrameLevel(1)
	end

	MoneyFrame_SetMaxDisplayWidth(Epsilon_MerchantMoneyFrame, 160);
end

-------------------------------------------------------------------------------

function Epsilon_MerchantFrame_OnEvent(self, event, ...)
	if ( event == "UNIT_INVENTORY_CHANGED" ) then
		Epsilon_MerchantFrame_Update();
	elseif ( event == "GOSSIP_SHOW" ) then
		Epsilon_Merchant_PlaySound( "greeting" )
		-- Revert the GossipFrame and MerchantFrame to default.
		MerchantFrame:SetAlpha(1)
		MerchantFrame:EnableMouse(true)
		GossipFrame:SetAlpha(1)
		GossipFrame:EnableMouse(true)
		if Me.IsPhaseOwner() then
			GossipFrameEditSoundsButton:Show()
		else
			GossipFrameEditSoundsButton:Hide()
		end
		-- Reset gossip options to link to their appropriate pages.
		for i = 1, GetNumGossipOptions() do
			_G["GossipTitleButton" .. i]:SetScript("OnClick", function()
				SelectGossipOption(i)
			end)
		end
		if UnitExists("npc") then
			local titleButton;
			local titleIndex = 1;
			local titleButtonIcon;
			local guid = UnitGUID("target")
			local unitType, _, _, _, _, id, _ = strsplit("-", guid)
			if not(unitType == "Creature") then
				return
			end

			-- Iterate through gossip options to find if ours already exists...
			--
			local found = false;
			for i = 1, GetNumGossipOptions() do
				titleButton = _G["GossipTitleButton" .. i];
				titleButtonIcon = _G["GossipTitleButton" .. i .. "GossipIcon"]:GetTexture();
				titleButtonText = _G["GossipTitleButton" .. i]:GetText();
				titleIndex = titleIndex + 1;
				if id and titleButtonText == "I want to browse your goods." then
					-- ...and it does! :D
					--
					found = true;
					if not EPSILON_VENDOR_DATA[id] then
						EPSILON_VENDOR_DATA[id] = {};
					end
					Epsilon_MerchantFrame.merchantID = id;
					_G["GossipTitleButton" .. i]:SetScript("OnClick", function()
						Epsilon_MerchantFrame:Show()
						MerchantFrame:Show()
						MerchantFrame:SetAlpha(0)
						MerchantFrame:EnableMouse(false)
						MerchantFrame.selectedTab = 2
						GossipFrame:SetAlpha(0)
						GossipFrame:EnableMouse(false)
					end)
					GossipTitleButtonAddVendor:Hide()
					if Me.IsPhaseOwner() then
						GossipTitleButtonRemoveVendor:Show()
					end
					break
				end
			end
			if found then
				Epsilon_Merchant_LoadVendor()
			elseif not( found ) and Me.IsPhaseOwner() then
				GossipTitleButtonAddVendor:Show()
				GossipTitleButtonRemoveVendor:Hide()
			end
		end
	elseif ( event == "GOSSIP_CLOSED" ) then
		Epsilon_Merchant_PlaySound( "farewell" )
		-- Revert GossipFrame and MerchantFrame to default.
		MerchantFrame:Hide()
		MerchantFrame:SetAlpha(1)
		MerchantFrame:EnableMouse(true)

		GossipFrame:SetAlpha(1)
		GossipFrame:EnableMouse(true)

		GossipFrameEditSoundsButton:Hide()

		GossipTitleButtonAddVendor:Hide()
		GossipTitleButtonRemoveVendor:Hide()

		if ( Epsilon_MerchantFrame:IsShown() ) then
			Epsilon_MerchantFrame:Hide()
			return;
		end

		Epsilon_MerchantSoundPicker_Close()

		Epsilon_MerchantFrame.merchantID = nil;
	end
end

-------------------------------------------------------------------------------

function Epsilon_MerchantFrame_OnUpdate(self, dt)
	if ( self.update == true ) then
		self.update = false;
		if ( self:IsVisible() ) then
			Epsilon_MerchantFrame_Update();
		end
	end
	if ( Epsilon_MerchantFrame.itemHover ) then
		if ( IsModifiedClick("DRESSUP") ) then
			ShowInspectCursor();
		else
			if (CanAffordMerchantItem(Epsilon_MerchantFrame.itemHover) == false) then
				SetCursor("BUY_ERROR_CURSOR");
			else
				SetCursor("BUY_CURSOR");
			end
		end
	end
	if ( Epsilon_MerchantRepairItemButton:IsShown() ) then
		if ( InRepairMode() ) then
			Epsilon_MerchantRepairItemButton:LockHighlight();
		else
			Epsilon_MerchantRepairItemButton:UnlockHighlight();
		end
	end
end

-------------------------------------------------------------------------------

function Epsilon_MerchantFrame_OnShow(self)
	local forceUpdate = true;
	OpenAllBags(self, forceUpdate);

	Epsilon_MerchantFrame_UpdateCanRepairAll();
	PanelTemplates_SetTab(Epsilon_MerchantFrame, 1);
	Epsilon_MerchantFrame.page = 1;

	Epsilon_MerchantFrame_UpdateCurrencies();
	Epsilon_MerchantFrame_Update();

	Epsilon_Merchant_GetPortrait();
	self.EditMerchantButton:SetShown(Me.IsPhaseOwner())

	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_OPEN);
end

-------------------------------------------------------------------------------

function Epsilon_MerchantFrame_OnHide(self)
	CloseGossip();
	Epsilon_MerchantItemEditor_Close()
	Epsilon_MerchantEditor_Close()

	local forceUpdate = true;
	CloseAllBags(self, forceUpdate);
	Epsilon_MerchantFrame.page = 1;

	ResetCursor();

	Epsilon_MerchantFrame_HidePortrait();

    StaticPopup_Hide("CONFIRM_PROFESSION");
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_CLOSE);
end

-------------------------------------------------------------------------------

function Epsilon_MerchantFrame_OnMouseWheel(self, value)
	if ( value > 0 ) then
		if ( Epsilon_MerchantPrevPageButton:IsShown() and Epsilon_MerchantPrevPageButton:IsEnabled() ) then
			Epsilon_MerchantPrevPageButton_OnClick();
		end
	else
		if ( Epsilon_MerchantNextPageButton:IsShown() and Epsilon_MerchantNextPageButton:IsEnabled() ) then
			Epsilon_MerchantNextPageButton_OnClick();
		end
	end
end

-------------------------------------------------------------------------------

function Epsilon_MerchantFrame_Update()
	if ( Epsilon_MerchantFrame.lastTab ~= Epsilon_MerchantFrame.selectedTab ) then
		Epsilon_MerchantFrame_CloseStackSplitFrame();
		Epsilon_MerchantFrame.lastTab = Epsilon_MerchantFrame.selectedTab;
	end
	if ( Epsilon_MerchantFrame.selectedTab == 1 ) then
		Epsilon_MerchantFrame_UpdateEpsilon_MerchantInfo();
	else
		Epsilon_MerchantFrame_UpdateBuybackInfo();
	end
end

-------------------------------------------------------------------------------

function Epsilon_MerchantFrameItem_UpdateQuality(self, link, isBound)
	local quality = link and select(3, GetItemInfo(link)) or nil;
	if ( quality ) then
		self.Name:SetTextColor(ITEM_QUALITY_COLORS[quality].r, ITEM_QUALITY_COLORS[quality].g, ITEM_QUALITY_COLORS[quality].b);
	else
		self.Name:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
		Epsilon_MerchantFrame_RegisterForQualityUpdates();
	end

	local doNotSuppressOverlays = false;
	SetItemButtonQuality(self.ItemButton, quality, link, doNotSuppressOverlays, isBound);
end

-------------------------------------------------------------------------------

function Epsilon_MerchantFrame_RegisterForQualityUpdates()
	if ( not Epsilon_MerchantFrame:IsEventRegistered("GET_ITEM_INFO_RECEIVED") ) then
		Epsilon_MerchantFrame:RegisterEvent("GET_ITEM_INFO_RECEIVED");
	end
end

-------------------------------------------------------------------------------

function Epsilon_MerchantFrame_UnregisterForQualityUpdates()
	if ( Epsilon_MerchantFrame:IsEventRegistered("GET_ITEM_INFO_RECEIVED") ) then
		Epsilon_MerchantFrame:UnregisterEvent("GET_ITEM_INFO_RECEIVED");
	end
end

-------------------------------------------------------------------------------

function Epsilon_MerchantFrame_UpdateItemQualityBorders(self)
	Epsilon_MerchantFrame_UnregisterForQualityUpdates(); -- We'll re-register if we need to.

	if ( Epsilon_MerchantFrame.selectedTab == 1 ) then
		local numMerchantItems = GetMerchantNumItems();
		for i=1, MERCHANT_ITEMS_PER_PAGE do
			local index = (((Epsilon_MerchantFrame.page - 1) * MERCHANT_ITEMS_PER_PAGE) + i);
			local item = _G["Epsilon_MerchantItem"..i];
			if ( index <= numMerchantItems ) then
				local itemLink = GetMerchantItemLink(index);
				Epsilon_MerchantFrameItem_UpdateQuality(item, itemLink);
			end
		end
	else
		local numBuybackItems = GetNumBuybackItems();
		for index=1, BUYBACK_ITEMS_PER_PAGE do
			local item = _G["Epsilon_MerchantItem"..index];
			if ( index <= numBuybackItems ) then
				local itemLink = GetBuybackItemLink(index);
				Epsilon_MerchantFrameItem_UpdateQuality(item, itemLink);
			end
		end
	end
end

-------------------------------------------------------------------------------

function Epsilon_MerchantFrame_UpdateEpsilon_MerchantInfo()
	Epsilon_MerchantNameText:SetText(UnitName("NPC"));
	SetPortraitTexture(Epsilon_MerchantFramePortrait, "NPC");

	-- Make sure this vendor exists.
	if not( UnitExists("NPC") and Epsilon_MerchantFrame.merchantID ) then
		return
	end
	local numMerchantItems = GetMerchantNumItems();

	Epsilon_MerchantPageText:SetFormattedText(MERCHANT_PAGE_NUMBER, Epsilon_MerchantFrame.page, math.ceil(numMerchantItems / MERCHANT_ITEMS_PER_PAGE));

	local name, texture, price, stackCount, numAvailable, isPurchasable, isUsable, extendedCost, currencyID, currencyAmount;
	for i=1, MERCHANT_ITEMS_PER_PAGE do
		local itemIndex = (((Epsilon_MerchantFrame.page - 1) * MERCHANT_ITEMS_PER_PAGE) + i)
		local index
		if EPSILON_VENDOR_DATA[Epsilon_MerchantFrame.merchantID] and EPSILON_VENDOR_DATA[Epsilon_MerchantFrame.merchantID][itemIndex] then
			index = EPSILON_VENDOR_DATA[Epsilon_MerchantFrame.merchantID][itemIndex][1]
		end
		local itemButton = _G["Epsilon_MerchantItem"..i.."ItemButton"];
		local merchantButton = _G["Epsilon_MerchantItem"..i];
		local merchantMoney = _G["Epsilon_MerchantItem"..i.."MoneyFrame"];
		local merchantAltCurrency = _G["Epsilon_MerchantItem"..i.."AltCurrencyFrame"];
		local merchantRemove = _G["Epsilon_MerchantItem"..i.."RemoveButton"];
		-- local merchantRestock = _G["Epsilon_MerchantItem"..i.."RestockButton"];
		local merchantPrice = _G["Epsilon_MerchantItem"..i.."PriceButton"];
		if ( itemIndex == numMerchantItems + 1 and Me.IsPhaseOwner() ) then
			-- the "Add Item" button, appended to the vendor's last item
			SetItemButtonCount(itemButton, 0)
			SetItemButtonStock(itemButton, 0)
			_G["Epsilon_MerchantItem"..i.."Name"]:SetText("Add Item")
			_G["Epsilon_MerchantItem"..i.."Name"]:SetTextColor(1, 0.81, 0);
			SetItemButtonTexture(itemButton, "Interface/PaperDollInfoFrame/Character-Plus")
			itemButton.hasItem = false
			itemButton:SetID(0)
			itemButton.slotID = 0
			merchantRemove:Hide()
			-- merchantRestock:Hide()
			merchantPrice:Hide()
			merchantMoney:Hide()
			merchantAltCurrency:Hide()
			SetItemButtonNameFrameVertexColor(merchantButton, 0.5, 0.5, 0.5);
			SetItemButtonSlotVertexColor(merchantButton, 1.0, 1.0, 1.0);
			SetItemButtonTextureVertexColor(itemButton, 1.0, 1.0, 1.0);
			SetItemButtonNormalTextureVertexColor(itemButton, 1.0, 1.0, 1.0);
			Epsilon_MerchantFrameItem_UpdateQuality(merchantButton, nil);
			itemButton:Show()
		elseif ( itemIndex <= numMerchantItems ) then
			name, texture, price, stackCount, numAvailable, isPurchasable, isUsable, extendedCost, currencyID, currencyAmount = GetMerchantItemInfo(index);

			--if(extendedCost) then
				--name, texture, numAvailable = CurrencyContainerUtil.GetCurrencyContainerInfo(currencyID, numAvailable, name, texture, nil);
			--end

			local canAfford = CanAffordMerchantItem(index);
			_G["Epsilon_MerchantItem"..i.."Name"]:SetText(name);
			SetItemButtonCount(itemButton, stackCount);
			SetItemButtonStock(itemButton, numAvailable);
			SetItemButtonTexture(itemButton, texture);

			if ( extendedCost and (price <= 0) ) then
				itemButton.price = nil;
				itemButton.extendedCost = true;
				itemButton.name = name;
				itemButton.link = GetMerchantItemLink(index);
				itemButton.texture = texture;
				Epsilon_MerchantFrame_UpdateAltCurrency(index, i, canAfford);
				merchantAltCurrency:ClearAllPoints();
				merchantAltCurrency:SetPoint("BOTTOMLEFT", "Epsilon_MerchantItem"..i.."NameFrame", "BOTTOMLEFT", 0, 31);
				merchantMoney:Hide();
				merchantAltCurrency:Show();
			elseif ( extendedCost and (price > 0) ) then
				itemButton.price = price;
				itemButton.extendedCost = true;
				itemButton.name = name;
				itemButton.link = GetMerchantItemLink(index);
				itemButton.texture = texture;
				local altCurrencyWidth = Epsilon_MerchantFrame_UpdateAltCurrency(index, i, canAfford);
				MoneyFrame_SetMaxDisplayWidth(merchantMoney, MAX_MONEY_DISPLAY_WIDTH - altCurrencyWidth);
				MoneyFrame_Update(merchantMoney:GetName(), price or 0);
				local color;
				if (canAfford == false) then
					color = "gray";
				end
				SetMoneyFrameColor(merchantMoney:GetName(), color);
				merchantAltCurrency:ClearAllPoints();
				merchantAltCurrency:SetPoint("LEFT", merchantMoney:GetName(), "RIGHT", -14, 0);
				merchantAltCurrency:Show();
				merchantMoney:Show();
			else
				itemButton.price = price;
				itemButton.extendedCost = nil;
				itemButton.name = name;
				itemButton.link = GetMerchantItemLink(index);
				itemButton.texture = texture;
				MoneyFrame_SetMaxDisplayWidth(merchantMoney, MAX_MONEY_DISPLAY_WIDTH);
				MoneyFrame_Update(merchantMoney:GetName(), price or 0);
				local color;
				if (canAfford == false) then
					color = "gray";
				end
				SetMoneyFrameColor(merchantMoney:GetName(), color);
				merchantAltCurrency:Hide();
				merchantMoney:Show();
			end

			local itemLink = GetMerchantItemLink(index);
			Epsilon_MerchantFrameItem_UpdateQuality(merchantButton, itemLink);

			local merchantItemID = Epsilon_MerchantFrame.merchantID;
			local isHeirloom = merchantItemID and C_Heirloom.IsItemHeirloom(merchantItemID);
			local isKnownHeirloom = isHeirloom and C_Heirloom.PlayerHasHeirloom(merchantItemID);

			itemButton.showNonrefundablePrompt = false;

			itemButton.hasItem = true;
			itemButton:SetID(index);
			itemButton.slotID = itemIndex;
			itemButton:Show();

			local tintRed = not isPurchasable or (not isUsable and not isHeirloom);

			SetItemButtonDesaturated(itemButton, isKnownHeirloom);

			if ( numAvailable == 0 or isKnownHeirloom ) then
				-- If not available and not usable
				if ( tintRed ) then
					SetItemButtonNameFrameVertexColor(merchantButton, 0.5, 0, 0);
					SetItemButtonSlotVertexColor(merchantButton, 0.5, 0, 0);
					SetItemButtonTextureVertexColor(itemButton, 0.5, 0, 0);
					SetItemButtonNormalTextureVertexColor(itemButton, 0.5, 0, 0);
				else
					SetItemButtonNameFrameVertexColor(merchantButton, 0.5, 0.5, 0.5);
					SetItemButtonSlotVertexColor(merchantButton, 0.5, 0.5, 0.5);
					SetItemButtonTextureVertexColor(itemButton, 0.5, 0.5, 0.5);
					SetItemButtonNormalTextureVertexColor(itemButton,0.5, 0.5, 0.5);
				end

			elseif ( tintRed ) then
				SetItemButtonNameFrameVertexColor(merchantButton, 1.0, 0, 0);
				SetItemButtonSlotVertexColor(merchantButton, 1.0, 0, 0);
				SetItemButtonTextureVertexColor(itemButton, 0.9, 0, 0);
				SetItemButtonNormalTextureVertexColor(itemButton, 0.9, 0, 0);
			else
				SetItemButtonNameFrameVertexColor(merchantButton, 0.5, 0.5, 0.5);
				SetItemButtonSlotVertexColor(merchantButton, 1.0, 1.0, 1.0);
				SetItemButtonTextureVertexColor(itemButton, 1.0, 1.0, 1.0);
				SetItemButtonNormalTextureVertexColor(itemButton, 1.0, 1.0, 1.0);
			end

			if ( Me.IsPhaseOwner() and Epsilon_MerchantFrame.selectedTab == 1 ) then
				merchantRemove:Show();
				-- if numAvailable == 0 then
					-- merchantRestock:Show();
				-- end
				merchantPrice:Show();
			else
				merchantRemove:Hide();
				-- merchantRestock:Hide();
				merchantPrice:Hide();
			end
		else
			itemButton.price = nil;
			itemButton.hasItem = nil;
			itemButton.name = nil;
			itemButton:Hide();
			merchantRemove:Hide();
			-- merchantRestock:Hide();
			merchantPrice:Hide();
			SetItemButtonNameFrameVertexColor(merchantButton, 0.5, 0.5, 0.5);
			SetItemButtonSlotVertexColor(merchantButton,0.4, 0.4, 0.4);
			_G["Epsilon_MerchantItem"..i.."Name"]:SetText("");
			_G["Epsilon_MerchantItem"..i.."MoneyFrame"]:Hide();
			_G["Epsilon_MerchantItem"..i.."AltCurrencyFrame"]:Hide();
		end
	end

	-- Handle repair items
	Epsilon_MerchantFrame_UpdateRepairButtons();

	-- Handle vendor buy back item
	local numBuybackItems = GetNumBuybackItems();
	local buybackName, buybackTexture, buybackPrice, buybackQuantity, buybackNumAvailable, buybackIsUsable, buybackIsBound = GetBuybackItemInfo(1);
	if ( buybackName ) then
		Epsilon_MerchantBuyBackItemName:SetText(buybackName);
		SetItemButtonCount(Epsilon_MerchantBuyBackItemItemButton, buybackQuantity);
		SetItemButtonStock(Epsilon_MerchantBuyBackItemItemButton, buybackNumAvailable);
		SetItemButtonTexture(Epsilon_MerchantBuyBackItemItemButton, buybackTexture);
		Epsilon_MerchantFrameItem_UpdateQuality(Epsilon_MerchantBuyBackItem, GetBuybackItemLink(1), buybackIsBound);
		Epsilon_MerchantBuyBackItemMoneyFrame:Show();
		MoneyFrame_Update("Epsilon_MerchantBuyBackItemMoneyFrame", buybackPrice or 0);
		Epsilon_MerchantBuyBackItem:Show();
	else
		Epsilon_MerchantBuyBackItemName:SetText("");
		Epsilon_MerchantBuyBackItemMoneyFrame:Hide();
		SetItemButtonTexture(Epsilon_MerchantBuyBackItemItemButton, "");
		SetItemButtonCount(Epsilon_MerchantBuyBackItemItemButton, 0);
		Epsilon_MerchantFrameItem_UpdateQuality(Epsilon_MerchantBuyBackItem, nil);
		-- Hide the tooltip upon sale
		if ( GameTooltip:IsOwned(Epsilon_MerchantBuyBackItemItemButton) ) then
			GameTooltip:Hide();
		end
	end

	-- Handle paging buttons
	if ( numMerchantItems + 1 > MERCHANT_ITEMS_PER_PAGE ) then
		if ( Epsilon_MerchantFrame.page == 1 ) then
			Epsilon_MerchantPrevPageButton:Disable();
		else
			Epsilon_MerchantPrevPageButton:Enable();
		end
		if ( Epsilon_MerchantFrame.page == ceil( ( numMerchantItems + 1 ) / MERCHANT_ITEMS_PER_PAGE) or numMerchantItems == 0) then
			Epsilon_MerchantNextPageButton:Disable();
		else
			Epsilon_MerchantNextPageButton:Enable();
		end
		Epsilon_MerchantPageText:Show();
		Epsilon_MerchantPrevPageButton:Show();
		Epsilon_MerchantNextPageButton:Show();
	else
		Epsilon_MerchantPageText:Hide();
		Epsilon_MerchantPrevPageButton:Hide();
		Epsilon_MerchantNextPageButton:Hide();
	end

	--
	if Me.IsPhaseOwner() then
		Epsilon_MerchantFrameAddItemButton:Show()
		Epsilon_MerchantFrameRemoveItemButton:Show()
	else
		Epsilon_MerchantFrameAddItemButton:Hide()
		Epsilon_MerchantFrameRemoveItemButton:Hide()
	end

	-- Show all merchant related items
	Epsilon_MerchantBuyBackItem:Show();
	Epsilon_MerchantFrameBottomLeftBorder:Show();
	Epsilon_MerchantFrameBottomRightBorder:Show();

	-- Hide buyback related items
	Epsilon_MerchantItem11:Hide();
	Epsilon_MerchantItem12:Hide();
	Epsilon_MerchantBuybackBG:Hide();

	-- Position merchant items
	Epsilon_MerchantItem3:SetPoint("TOPLEFT", "Epsilon_MerchantItem1", "BOTTOMLEFT", 0, -8);
	Epsilon_MerchantItem5:SetPoint("TOPLEFT", "Epsilon_MerchantItem3", "BOTTOMLEFT", 0, -8);
	Epsilon_MerchantItem7:SetPoint("TOPLEFT", "Epsilon_MerchantItem5", "BOTTOMLEFT", 0, -8);
	Epsilon_MerchantItem9:SetPoint("TOPLEFT", "Epsilon_MerchantItem7", "BOTTOMLEFT", 0, -8);
end

-------------------------------------------------------------------------------

function Epsilon_MerchantFrame_UpdateAltCurrency(index, indexOnPage, canAfford)
	local itemCount = GetMerchantItemCostInfo(index);
	local frameName = "Epsilon_MerchantItem"..indexOnPage.."AltCurrencyFrame";
	local usedCurrencies = 0;
	local width = 0;

	-- update Alt Currency Frame with itemValues
	if ( itemCount > 0 ) then
		for i=1, MAX_ITEM_COST do
			local itemTexture, itemValue, itemLink = GetMerchantItemCostItem(index, i);
			if ( itemTexture ) then
				usedCurrencies = usedCurrencies + 1;
				local button = _G[frameName.."Item"..usedCurrencies];
				button.index = index;
				button.item = i;
				button.itemID = GetMerchantItemCostItemID(index, i);
				button.itemLink = itemLink;
				AltCurrencyFrame_Update(frameName.."Item"..usedCurrencies, itemTexture, itemValue, canAfford);
				width = width + button:GetWidth();
				if ( usedCurrencies > 1 ) then
					-- button spacing;
					width = width + 4;
				end
				button:Show();
			end
		end
		for i = usedCurrencies + 1, MAX_ITEM_COST do
			_G[frameName.."Item"..i]:Hide();
		end
	else
		for i=1, MAX_ITEM_COST do
			_G[frameName.."Item"..i]:Hide();
		end
	end
	return width;
end

-------------------------------------------------------------------------------

function Epsilon_MerchantFrame_UpdateBuybackInfo()
	Epsilon_MerchantNameText:SetText(MERCHANT_BUYBACK);
	Epsilon_MerchantFramePortrait:SetTexture("Interface\\Epsilon_MerchantFrame\\UI-BuyBack-Icon");

	-- Show Buyback specific items
	Epsilon_MerchantItem11:Show();
	Epsilon_MerchantItem12:Show();
	Epsilon_MerchantBuybackBG:Show();

	-- Position buyback items
	Epsilon_MerchantItem3:SetPoint("TOPLEFT", "Epsilon_MerchantItem1", "BOTTOMLEFT", 0, -15);
	Epsilon_MerchantItem5:SetPoint("TOPLEFT", "Epsilon_MerchantItem3", "BOTTOMLEFT", 0, -15);
	Epsilon_MerchantItem7:SetPoint("TOPLEFT", "Epsilon_MerchantItem5", "BOTTOMLEFT", 0, -15);
	Epsilon_MerchantItem9:SetPoint("TOPLEFT", "Epsilon_MerchantItem7", "BOTTOMLEFT", 0, -15);

	local numBuybackItems = GetNumBuybackItems();
	local itemButton, buybackButton, merchantRemove, merchantRestock, merchantPrice;
	local buybackName, buybackTexture, buybackPrice, buybackQuantity, buybackNumAvailable, buybackIsUsable, buybackIsBound;
	local buybackItemLink;
	for i=1, BUYBACK_ITEMS_PER_PAGE do
		itemButton = _G["Epsilon_MerchantItem"..i.."ItemButton"];
		buybackButton = _G["Epsilon_MerchantItem"..i];
		merchantRemove = _G["Epsilon_MerchantItem"..i.."RemoveButton"];
		-- merchantRestock = _G["Epsilon_MerchantItem"..i.."RestockButton"];
		merchantPrice = _G["Epsilon_MerchantItem"..i.."PriceButton"];
		_G["Epsilon_MerchantItem"..i.."AltCurrencyFrame"]:Hide();
		if ( i <= numBuybackItems ) then
			buybackName, buybackTexture, buybackPrice, buybackQuantity, buybackNumAvailable, buybackIsUsable, buybackIsBound = GetBuybackItemInfo(i);
			_G["Epsilon_MerchantItem"..i.."Name"]:SetText(buybackName);
			SetItemButtonCount(itemButton, buybackQuantity);
			SetItemButtonStock(itemButton, 0);
			SetItemButtonTexture(itemButton, buybackTexture);
			_G["Epsilon_MerchantItem"..i.."MoneyFrame"]:Show();
			MoneyFrame_Update("Epsilon_MerchantItem"..i.."MoneyFrame", buybackPrice or 0);
			buybackItemLink = GetBuybackItemLink(i);
			Epsilon_MerchantFrameItem_UpdateQuality(buybackButton, buybackItemLink, buybackIsBound);
			itemButton:SetID( EPSILON_ITEM_BUYBACK[i]["itemID"] or nil );
			itemButton:Show();
			if ( not buybackIsUsable ) then
				SetItemButtonNameFrameVertexColor(buybackButton, 1.0, 0, 0);
				SetItemButtonSlotVertexColor(buybackButton, 1.0, 0, 0);
				SetItemButtonTextureVertexColor(itemButton, 0.9, 0, 0);
				SetItemButtonNormalTextureVertexColor(itemButton, 0.9, 0, 0);
			else
				SetItemButtonNameFrameVertexColor(buybackButton, 0.5, 0.5, 0.5);
				SetItemButtonSlotVertexColor(buybackButton, 1.0, 1.0, 1.0);
				SetItemButtonTextureVertexColor(itemButton, 1.0, 1.0, 1.0);
				SetItemButtonNormalTextureVertexColor(itemButton, 1.0, 1.0, 1.0);
			end
		else
			SetItemButtonNameFrameVertexColor(buybackButton, 0.5, 0.5, 0.5);
			SetItemButtonSlotVertexColor(buybackButton,0.4, 0.4, 0.4);
			_G["Epsilon_MerchantItem"..i.."Name"]:SetText("");
			_G["Epsilon_MerchantItem"..i.."MoneyFrame"]:Hide();
			itemButton:Hide();
		end
		merchantRemove:Hide();
		-- merchantRestock:Hide();
		merchantPrice:Hide();
	end

	-- Hide all merchant related items
	Epsilon_MerchantRepairAllButton:Hide()
	Epsilon_MerchantRepairItemButton:Hide()
	Epsilon_MerchantBuyBackItem:Hide();
	Epsilon_MerchantPrevPageButton:Hide();
	Epsilon_MerchantNextPageButton:Hide();
	Epsilon_MerchantFrameBottomLeftBorder:Hide();
	Epsilon_MerchantFrameBottomRightBorder:Hide();
	Epsilon_MerchantRepairText:Hide();
	Epsilon_MerchantPageText:Hide();
end

-------------------------------------------------------------------------------

function Epsilon_MerchantPrevPageButton_OnClick()
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	Epsilon_MerchantFrame.page = Epsilon_MerchantFrame.page - 1;
	Epsilon_MerchantFrame_CloseStackSplitFrame();
	Epsilon_MerchantFrame_Update();
end

-------------------------------------------------------------------------------

function Epsilon_MerchantNextPageButton_OnClick()
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	Epsilon_MerchantFrame.page = Epsilon_MerchantFrame.page + 1;
	Epsilon_MerchantFrame_CloseStackSplitFrame();
	Epsilon_MerchantFrame_Update();
end

-------------------------------------------------------------------------------

function Epsilon_MerchantFrame_CloseStackSplitFrame()
	if ( StackSplitFrame:IsShown() ) then
		local numButtons = max(MERCHANT_ITEMS_PER_PAGE, BUYBACK_ITEMS_PER_PAGE);
		for i = 1, numButtons do
			if ( StackSplitFrame.owner == _G["Epsilon_MerchantItem"..i.."ItemButton"] ) then
				StackSplitCancelButton_OnClick();
				return;
			end
		end
	end
end

-------------------------------------------------------------------------------

function Epsilon_MerchantItemBuybackButton_OnClick(self, button)
	local _, _, _, stackCount, numAvailable, isPurchasable, isUsable, extendedCost, currencyID, currencyAmount = GetMerchantItemInfo(self:GetID());
	if button == "RightButton" then
		BuybackEpsilon_MerchantItem( EPSILON_ITEM_BUYBACK[1]["itemID"], stackCount );
	end
end

-------------------------------------------------------------------------------

function Epsilon_MerchantItemBuybackButton_OnLoad(self)
	self:RegisterEvent("MERCHANT_UPDATE");
	self:RegisterForClicks("LeftButtonUp","RightButtonUp");
	self:RegisterForDrag("LeftButton");

	self.SplitStack = function(button, split)
		if ( split > 0 ) then
			BuyEpsilon_MerchantItem(button:GetID(), split);
		end
	end
end

-------------------------------------------------------------------------------

function Epsilon_MerchantItemButton_OnLoad(self)
	self:RegisterForClicks("LeftButtonUp","RightButtonUp");
	self:RegisterForDrag("LeftButton");

	self.SplitStack = function(button, split)
		if ( split > 0 ) then
			BuyEpsilon_MerchantItem(button:GetID(), split);
		end
	end

	self.UpdateTooltip = Epsilon_MerchantItemButton_OnEnter;
end

-------------------------------------------------------------------------------

MERCHANT_HIGH_PRICE_COST = 1500000;

function Epsilon_MerchantItemButton_OnClick(self, button)
	Epsilon_MerchantFrame.extendedCost = nil;
	Epsilon_MerchantFrame.highPrice = nil;

	local _, _, _, stackCount, numAvailable, isPurchasable, isUsable, extendedCost, currencyID, currencyAmount = GetMerchantItemInfo(self:GetID());

	if ( Epsilon_MerchantFrame.selectedTab == 1 ) then
		-- Is merchant frame
		if self:GetID() == 0 then
			OpenAllBags()
			Epsilon_MerchantFrame.choosingItem = true;
			Epsilon_MerchantItemEditor.choosingItem = false;
			Epsilon_MerchantCursorOverlay:Show()
			Epsilon_MerchantCursorOverlay:SetScript("OnUpdate", function()
				SetCursor("CAST_CURSOR")
			end)
			PlaySound( 83 )
		elseif ( button == "LeftButton" ) then
			if ( Epsilon_MerchantFrame.refundItem ) then
				if ( ContainerFrame_GetExtendedPriceString(Epsilon_MerchantFrame.refundItem, Epsilon_MerchantFrame.refundItemEquipped)) then
					-- a confirmation dialog has been shown
					return;
				end
			end

			PickupItem(self:GetID());
			Epsilon_MerchantFrame.PickupItem = self:GetID()
			if ( self.extendedCost ) then
				Epsilon_MerchantFrame.extendedCost = self;
			elseif ( self.showNonrefundablePrompt ) then
				Epsilon_MerchantFrame.extendedCost = self;
			elseif ( self.price and self.price >= MERCHANT_HIGH_PRICE_COST ) then
				Epsilon_MerchantFrame.highPrice = self;
			end
		else
			BuyEpsilon_MerchantItem(self:GetID() );
		end
	else
		-- Is buyback item
		BuybackEpsilon_MerchantItem(self:GetID() );
	end
end

-------------------------------------------------------------------------------

function Epsilon_MerchantItemButton_OnModifiedClick(self, button)
	if ( Epsilon_MerchantFrame.selectedTab == 1 ) then
		-- Is merchant frame
		if ( HandleModifiedItemClick(GetMerchantItemLink(self:GetID())) ) then
			return;
		end
		if ( IsModifiedClick("SPLITSTACK")) then
			local maxStack = GetMerchantItemMaxStack(self:GetID());
			local _, _, price, stackCount, numAvailable, isPurchasable, isUsable, extendedCost, currencyID, currencyAmount = GetMerchantItemInfo(self:GetID());

			local canAfford;
			if (price and price > 0) then
				canAfford = floor(GetMoney() / (price / stackCount));
			else
				canAfford = maxStack;
			end

			if (extendedCost) then
				local itemCount = GetMerchantItemCostInfo(self:GetID());
				for i = 1, MAX_ITEM_COST do
					local itemTexture, itemValue, itemLink, currencyName = GetMerchantItemCostItem(self:GetID(), i);
					if (itemLink and not currencyName) then
						local myCount = GetItemCount(itemLink, false, false, true);
						canAfford = min(canAfford, floor(myCount / (itemValue / stackCount)));
					end
				end
			end

			if ( maxStack > 1 ) then
				local maxPurchasable = min(maxStack, canAfford);
				StackSplitFrame:OpenStackSplitFrame(maxPurchasable, self, "BOTTOMLEFT", "TOPLEFT", stackCount);
			end
			return;
		end
	else
		HandleModifiedItemClick(GetBuybackItemLink(self:GetID()));
	end
end

-------------------------------------------------------------------------------

function Epsilon_MerchantItemButton_OnEnter(button)
	GameTooltip:SetOwner(button, "ANCHOR_RIGHT");
	if ( Epsilon_MerchantFrame.selectedTab == 1 ) then
		if button:GetID() == 0 then
			GameTooltip:AddLine("|TInterface/PaperDollInfoFrame/Character-Plus:12|t Add Item", 1, 1, 1)
			GameTooltip:AddLine("Select an item from your inventory to add to this vendor.", 1.0, 0.81, 0.0, true)
			GameTooltip:Show()
		else
			GameTooltip:SetItemByID(button:GetID());
			GameTooltip_ShowCompareItem(GameTooltip);
			Epsilon_MerchantFrame.itemHover = button:GetID();
		end
	else
		GameTooltip:SetItemByID(button:GetID());
		if ( IsModifiedClick("DRESSUP") and button.hasItem ) then
			ShowInspectCursor();
		else
			if (CanAffordMerchantItem(button:GetID()) == false) then
				SetCursor("BUY_ERROR_CURSOR");
			else
				SetCursor("BUY_CURSOR");
			end
		end
	end
end

-------------------------------------------------------------------------------

function Epsilon_MerchantFrame_UpdateCanRepairAll()
	if ( Epsilon_MerchantRepairAllIcon ) then
		local repairAllCost, canRepair = GetRepairAllCost();
		if ( canRepair ) then
			SetDesaturation(Epsilon_MerchantRepairAllIcon, false);
			Epsilon_MerchantRepairAllButton:Enable();
		else
			SetDesaturation(Epsilon_MerchantRepairAllIcon, true);
			Epsilon_MerchantRepairAllButton:Disable();
		end
	end
end

function Epsilon_MerchantFrame_UpdateRepairButtons()
	if ( CanMerchantRepair() ) then
		Epsilon_MerchantRepairAllButton:SetWidth(36);
		Epsilon_MerchantRepairAllButton:SetHeight(36);
		Epsilon_MerchantRepairItemButton:SetWidth(36);
		Epsilon_MerchantRepairItemButton:SetHeight(36);
		Epsilon_MerchantRepairItemButton:SetPoint("RIGHT", Epsilon_MerchantRepairAllButton, "LEFT", -2, 0);
		Epsilon_MerchantRepairAllButton:SetPoint("BOTTOMRIGHT", Epsilon_MerchantFrame, "BOTTOMLEFT", 160, 32);
		Epsilon_MerchantRepairText:ClearAllPoints();
		Epsilon_MerchantRepairText:SetPoint("BOTTOMLEFT", Epsilon_MerchantFrame, "BOTTOMLEFT", 14, 45);
		Epsilon_MerchantRepairText:Show();
		Epsilon_MerchantRepairAllButton:Show();
		Epsilon_MerchantRepairItemButton:Show();
		Epsilon_MerchantFrame_UpdateCanRepairAll();
	else
		Epsilon_MerchantRepairText:Hide();
		Epsilon_MerchantRepairAllButton:Hide();
		Epsilon_MerchantRepairItemButton:Hide();
	end
end

function Epsilon_MerchantFrame_UpdateCurrencies()
	local currencies = GetMerchantCurrencies();

	if ( #currencies == 0 ) then	-- common case
		Epsilon_MerchantFrame:UnregisterEvent("CURRENCY_DISPLAY_UPDATE");
		Epsilon_MerchantMoneyFrame:SetPoint("BOTTOMRIGHT", -4, 8);
		Epsilon_MerchantMoneyFrame:Show();
		Epsilon_MerchantExtraCurrencyInset:Hide();
		Epsilon_MerchantExtraCurrencyBg:Hide();
	else
		Epsilon_MerchantFrame:RegisterEvent("CURRENCY_DISPLAY_UPDATE");
		Epsilon_MerchantExtraCurrencyInset:Show();
		Epsilon_MerchantExtraCurrencyBg:Show();
		Epsilon_MerchantFrame.numCurrencies = #currencies;
		if ( Epsilon_MerchantFrame.numCurrencies > 3 ) then
			Epsilon_MerchantMoneyFrame:Hide();
		else
			Epsilon_MerchantMoneyFrame:SetPoint("BOTTOMRIGHT", -169, 8);
			Epsilon_MerchantMoneyFrame:Show();
		end
		for index = 1, Epsilon_MerchantFrame.numCurrencies do
			local tokenButton = _G["Epsilon_MerchantToken"..index];
			-- if this button doesn't exist yet, create it and anchor it
			if ( not tokenButton ) then
				tokenButton = CreateFrame("BUTTON", "Epsilon_MerchantToken"..index, Epsilon_MerchantFrame, "BackpackTokenTemplate");
				-- token display order is: 6 5 4 | 3 2 1
				if ( index == 1 ) then
					tokenButton:SetPoint("BOTTOMRIGHT", -16, 8);
				elseif ( index == 4 ) then
					tokenButton:SetPoint("BOTTOMLEFT", 89, 8);
				else
					tokenButton:SetPoint("RIGHT", _G["Epsilon_MerchantToken"..index - 1], "LEFT", 0, 0);
				end
				tokenButton:SetScript("OnEnter", Epsilon_MerchantFrame_ShowCurrencyTooltip);
			end

			local name, _, _, _, _, _, _, _, _, icon = GetItemInfo(currencies[index]);
			if ( name and name ~= "" ) then
				tokenButton.icon:SetTexture(icon);
				tokenButton.currencyID = currencies[index];
				tokenButton:Show();
				Epsilon_MerchantFrame_UpdateCurrencyButton(tokenButton);
			else
				tokenButton.currencyID = nil;
				tokenButton:Hide();
			end
		end
	end

	for i = #currencies + 1, MAX_MERCHANT_CURRENCIES do
		local tokenButton = _G["Epsilon_MerchantToken"..i];
		if ( tokenButton ) then
			tokenButton.currencyID = nil;
			tokenButton:Hide();
		else
			break;
		end
	end
end

-------------------------------------------------------------------------------

function Epsilon_MerchantFrame_ShowCurrencyTooltip(self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip:SetItemByID(self.currencyID);
end

-------------------------------------------------------------------------------

function Epsilon_MerchantFrame_UpdateCurrencyAmounts()
	for i = 1, MAX_MERCHANT_CURRENCIES do
		local tokenButton = _G["Epsilon_MerchantToken"..i];
		if ( tokenButton ) then
			Epsilon_MerchantFrame_UpdateCurrencyButton(tokenButton);
		else
			return;
		end
	end
end

-------------------------------------------------------------------------------

function Epsilon_MerchantFrame_UpdateCurrencyButton(tokenButton)
	if ( tokenButton.currencyID ) then
		local count = GetItemCount(tokenButton.currencyID, false, false, true);
		local displayCount = count;
		local displayWidth = 50;
		if ( count > 99999 ) then
			if Epsilon_MerchantFrame.numCurrencies == 1 then
				displayWidth = 100;
			else
				displayCount = "*"
			end
		end
		tokenButton.count:SetText(displayCount);
		tokenButton:SetWidth(displayWidth);
	end
end

-------------------------------------------------------------------------------
local tuples = {
	{ "$c", UnitClass("player") },
	{ "$r", UnitRace("player") },
	{ "$n", UnitName("player") },
	{ "$p", UnitName("player") },
	{ "$G(.-)\:(.-)", function(a, b)
		if UnitSex("player") == 3 then
			return b
		else
			return a
		end
	end },
}

function Epsilon_MerchantFrame_UpdatePortraitText(text)
	if (text and text ~= "") then

		for i = 1, #tuples do
			text = text:gsub( tuples[i][1], tuples[i][2] );
		end

		Epsilon_MerchantNPCModelTextFrame:Show();
		Epsilon_MerchantNPCModelText:SetText(text);
		Epsilon_MerchantNPCModelText:SetWidth(178);
		if (Epsilon_MerchantNPCModelText:GetHeight() > Epsilon_MerchantNPCModelTextScrollFrame:GetHeight()) then
			Epsilon_MerchantNPCModelTextScrollChildFrame:SetHeight(Epsilon_MerchantNPCModelText:GetHeight()+10);
			Epsilon_MerchantNPCModelText:SetWidth(162);
		else
			Epsilon_MerchantNPCModelTextScrollChildFrame:SetHeight(Epsilon_MerchantNPCModelText:GetHeight());
		end
	else
		Epsilon_MerchantNPCModelTextFrame:Hide();
	end
end

-------------------------------------------------------------------------------

function Epsilon_MerchantFrame_ShowPortrait(parentFrame, portraitDisplayID, text, x, y)
	Epsilon_MerchantModel:SetParent(parentFrame);
	Epsilon_MerchantModel:SetFrameLevel(600);
	Epsilon_MerchantModel:ClearAllPoints();
	Epsilon_MerchantModel:SetPoint("TOPLEFT", parentFrame, "TOPRIGHT", x, y);
	Epsilon_MerchantModel:Show();
	Epsilon_MerchantFrame_UpdatePortraitText(text);
	Epsilon_MerchantNPCModelNameplate:Show();
	Epsilon_MerchantNPCModelBlankNameplate:Hide();
	Epsilon_MerchantNPCModelNameText:Show();
	Epsilon_MerchantNPCModelNameText:SetText( UnitName("npc") );
	if portraitDisplayID == -1 then
		Epsilon_MerchantModel:SetUnit( "player" );
		Epsilon_MerchantModel:SetPortraitZoom( 0.6 );
	else
		Epsilon_MerchantModel:SetUnit( "npc" );
		Epsilon_MerchantModel:SetPortraitZoom( 0.6 );

		-- Animations shenanigans
		--
		local animations = {}
		local animIndex = { ["."]=60,["!"]=64,["?"]=65 }

		-- Sentences ending in a period (.) will trigger the EmoteTalk animation
		-- Sentences ending in an exclamation point (!) trigger the EmoteTalkExcalamation animation
		-- Sentences ending in a question mark (?) trigger the EmoteTalkQuestion animation

		text:gsub("%p",function(c)
			if animIndex[c] and Epsilon_MerchantModel:HasAnimation( animIndex[c] ) then
				table.insert(animations, animIndex[c])
			end
		end)
		Epsilon_MerchantModel:SetAnimation(60)
		Epsilon_MerchantModel:SetScript("OnAnimFinished", function( self )
			if ( animations ) then
				tremove( animations, 1 )
				if #animations > 0 then
					self:SetAnimation( animations[1] );
				else
					self:SetAnimation( 0 );
				end
			end
		end)
	end
end

-------------------------------------------------------------------------------

function Epsilon_MerchantFrame_HidePortrait(optPortraitOwnerCheckFrame)
	optPortraitOwnerCheckFrame = optPortraitOwnerCheckFrame or Epsilon_MerchantModel:GetParent();
	if optPortraitOwnerCheckFrame == Epsilon_MerchantModel:GetParent() then
		Epsilon_MerchantModel:Hide();
		Epsilon_MerchantModel:SetParent(nil);
	end
end