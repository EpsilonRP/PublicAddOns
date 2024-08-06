-------------------------------------------------------------------------------
-- Epsilon (C) 2022
-------------------------------------------------------------------------------

--
-- Item Editing Panel
--

function Epsilon_MerchantItemEditorStackCount_OnLoad( self )
	local _, _, _, _, _, _, _, stackCount = GetItemInfo(Epsilon_MerchantItemEditor.itemID);
	self:SetMinMaxValues(1, tonumber( stackCount ) )
	self:SetObeyStepOnDrag( true )
	self:SetValueStep( 1 )
	self:SetValue(1)
	_G[self:GetName().."Low"]:Hide()
	_G[self:GetName().."High"]:Hide()
	_G[self:GetName().."Text"]:SetText("|cFFFFD100Stack Size: "..self:GetValue())
	self.tooltipText = "Set the stack size for this item.|n|n|cFF00ADEFTip:|r|cFFFFFFFF This value cannot exceed an item's default stack size!|r"
	self.tooltipOnButton = true
	Epsilon_MerchantItemEditor.itemCount:SetText( "" )
	Epsilon_MerchantItemEditor.itemCount:Hide()
end

function Epsilon_MerchantItemEditorStackCount_OnValueChanged( self, value, userInput )
	_G[self:GetName().."Text"]:SetText("|cFFFFD100Stack Size: "..value)
	if value > 1 then
		Epsilon_MerchantItemEditor.itemCount:SetText( value )
		Epsilon_MerchantItemEditor.itemCount:Show()
	else
		Epsilon_MerchantItemEditor.itemCount:SetText( "" )
		Epsilon_MerchantItemEditor.itemCount:Hide()
	end
end

function Epsilon_MerchantItemEditorUpdateAltCurrency()
	Epsilon_MerchantItemEditorAltCurrencyFrame:Hide();
	for i = 1, 3 do
		local button = _G[Epsilon_MerchantItemEditorAltCurrencyFrame:GetName().."Item"..i];
		if _G["Epsilon_MerchantItemEditorCurrency" .. i].itemID then
			local name, link, _, _, _, _, _, _, _, texture, _ = GetItemInfo( _G["Epsilon_MerchantItemEditorCurrency" .. i].itemID );
			button.itemID = _G["Epsilon_MerchantItemEditorCurrency" .. i].itemID;
			button.itemLink = link;
			AltCurrencyFrame_Update( Epsilon_MerchantItemEditorAltCurrencyFrame:GetName().."Item"..i, texture, 1);
			button:Show();
			Epsilon_MerchantItemEditorAltCurrencyFrame:Show();
		
			local price = Epsilon_MerchantItemEditor.itemPrice:GetText() or 0
			price = tonumber(price) or 0;
			if price <= 0 then
				Epsilon_MerchantItemEditorAltCurrencyFrame:ClearAllPoints();
				Epsilon_MerchantItemEditorAltCurrencyFrame:SetPoint("BOTTOMLEFT", Epsilon_MerchantItemEditorNameFrame, "BOTTOMLEFT", 0, 31);
			else
				Epsilon_MerchantItemEditorAltCurrencyFrame:ClearAllPoints();
				Epsilon_MerchantItemEditorAltCurrencyFrame:SetPoint("LEFT", Epsilon_MerchantItemEditorMoneyFrame, "RIGHT", -14, 0);
			end
		else
			button.itemID = nil;
			button.itemLink = nil;
			button:Hide();
		end
	end
end

function Epsilon_MerchantItemEditorChooseCurrency( itemID, index )
	if itemID and type(itemID) == "number" and itemID > 0 and GetItemInfo(itemID) and index and type(index) == "number" and index <= 3 then
		if tonumber( itemID ) == tonumber( Epsilon_MerchantItemEditor.itemID ) then
			UIErrorsFrame:AddMessage( "Items cannot use themselves as a currency.", 1.0, 0.0, 0.0, 53, 5 );
			return
		end
		
		local name, link, _, _, _, _, _, _, _, texture, _ = GetItemInfo(itemID);
		
		_G["Epsilon_MerchantItemEditorCurrency" .. index].itemID = itemID;
		SetItemButtonTexture(_G["Epsilon_MerchantItemEditorCurrency" .. index], texture or "Interface/Icons/inv_misc_questionmark");
		_G["Epsilon_MerchantItemEditorCurrency" .. index .. "Name"]:SetText( name or "" );
		_G["Epsilon_MerchantItemEditorCurrency" .. index .. "Amount"]:SetText( 1 );

		Epsilon_MerchantItemEditorUpdateAltCurrency()
	end
end

function Epsilon_MerchantItemEditor_LoadItem( itemIndex )
	if not( itemIndex and EPSILON_VENDOR_DATA[Epsilon_MerchantFrame.merchantID][itemIndex] ) then
		return
	end
	Epsilon_MerchantItemEditor.itemIndex = itemIndex
	Epsilon_MerchantItemEditor.itemID = EPSILON_VENDOR_DATA[Epsilon_MerchantFrame.merchantID][itemIndex][1]
	
	local itemName, _, _, _, _, _, _, _, _, itemTexture = GetItemInfo(Epsilon_MerchantItemEditor.itemID);
	local _, price, stackCount, currency, amount = unpack( EPSILON_VENDOR_DATA[Epsilon_MerchantFrame.merchantID][itemIndex] )
	
	price = tonumber( price ) or 0;
	stackCount = tonumber( stackCount ) or 1;
	
	Epsilon_MerchantItemEditorStackCount_OnLoad( Epsilon_MerchantItemEditor.stackCount )
	
	Epsilon_MerchantItemEditor.Name:SetText( itemName )
	Epsilon_MerchantItemEditor.itemIcon:SetTexture( itemTexture )
	Epsilon_MerchantItemEditor.itemCount:SetText( stackCount )
	Epsilon_MerchantItemEditor.itemPrice:SetText( price )
	Epsilon_MerchantItemEditor.stackCount:SetValue( stackCount )
	
	if currency and amount then
		Epsilon_MerchantItemEditorCurrency1.itemID = currency;
		local name, _, _, _, _, _, _, _, _, texture, _ = GetItemInfo(currency);
		SetItemButtonTexture(Epsilon_MerchantItemEditorCurrency1, texture or "Interface/Icons/inv_misc_questionmark");
		Epsilon_MerchantItemEditorCurrency1Name:SetText( name or "" );
		Epsilon_MerchantItemEditorCurrency1Amount:SetText( amount );
	elseif type(currency) == "table" then
		for i = 1, #currency do
			_G["Epsilon_MerchantItemEditorCurrency" .. i].itemID = currency[i][1];
			local name, _, _, _, _, _, _, _, _, texture, _ = GetItemInfo(currency[i][1]);
			SetItemButtonTexture(_G["Epsilon_MerchantItemEditorCurrency" .. i], texture or "Interface/Icons/inv_misc_questionmark");
			_G["Epsilon_MerchantItemEditorCurrency" .. i .."Name"]:SetText( name or "" );
			_G["Epsilon_MerchantItemEditorCurrency" .. i .."Amount"]:SetText( currency[i][2] or 0 );
		end
	end
	
	MoneyFrame_Update( Epsilon_MerchantItemEditorMoneyFrame, price );
	Epsilon_MerchantItemEditorUpdateAltCurrency()
end

function Epsilon_MerchantItemEditor_SaveItem()

	local price = Epsilon_MerchantItemEditor.itemPrice:GetText() or 0
	local stackCount = Epsilon_MerchantItemEditor.stackCount:GetValue() or 1
	price = tonumber( price )
	stackCount = tonumber( stackCount )

	EPSILON_VENDOR_DATA[Epsilon_MerchantFrame.merchantID][Epsilon_MerchantItemEditor.itemIndex][2] = price;
	EPSILON_VENDOR_DATA[Epsilon_MerchantFrame.merchantID][Epsilon_MerchantItemEditor.itemIndex][3] = stackCount;
	
	local currencies = {};
	for i = 1, 3 do
		if _G["Epsilon_MerchantItemEditorCurrency" .. i].itemID then
			local itemID = tonumber( _G["Epsilon_MerchantItemEditorCurrency" .. i].itemID );
			local amount = tonumber( _G["Epsilon_MerchantItemEditorCurrency" .. i .. "Amount"]:GetText() ) or 1;
			if amount > 9999 then amount = 9999; elseif amount < 1 then amount = 1; end
			tinsert( currencies, { itemID, amount } );
		end
	end
	if #currencies > 0 then
		EPSILON_VENDOR_DATA[Epsilon_MerchantFrame.merchantID][Epsilon_MerchantItemEditor.itemIndex][4] = currencies;
		EPSILON_VENDOR_DATA[Epsilon_MerchantFrame.merchantID][Epsilon_MerchantItemEditor.itemIndex][5] = nil;
	else
		EPSILON_VENDOR_DATA[Epsilon_MerchantFrame.merchantID][Epsilon_MerchantItemEditor.itemIndex][4] = nil;
		EPSILON_VENDOR_DATA[Epsilon_MerchantFrame.merchantID][Epsilon_MerchantItemEditor.itemIndex][5] = nil;
	end
	
	Epsilon_MerchantFrame_UpdateCurrencies()
	Epsilon_MerchantFrame_Update()
	Epsilon_Merchant_SaveVendor()
	PlaySound( 83 )
end

function Epsilon_MerchantItemEditor_ClearAllFields()
	Epsilon_MerchantItemEditor.Name:SetText( "" )
	Epsilon_MerchantItemEditor.itemIcon:SetTexture( "Interface/Icons/inv_misc_questionmark" )
	Epsilon_MerchantItemEditor.itemCount:SetText( "" )
	Epsilon_MerchantItemEditor.itemPrice:SetText( "0" )
	Epsilon_MerchantItemEditor.stackCount:SetValue( 1 )
	for i = 1, 3 do
		_G["Epsilon_MerchantItemEditorCurrency" .. i].itemID = nil;
		SetItemButtonTexture(_G["Epsilon_MerchantItemEditorCurrency" .. i], "Interface/Icons/inv_misc_questionmark");
		_G["Epsilon_MerchantItemEditorCurrency" .. i .. "Name"]:SetText( "" );
		_G["Epsilon_MerchantItemEditorCurrency" .. i .. "Amount"]:SetText( "0" );
	end
end

-------------------------------------------------------------------------------
-- Close the item editor window. Use this instead of a direct Hide()
--
function Epsilon_MerchantItemEditor_Close()
	Epsilon_MerchantItemEditor_ClearAllFields()
	Epsilon_MerchantItemEditor:Hide()
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_CLOSE);
end
    
-------------------------------------------------------------------------------
-- Open the item editor window.
--
function Epsilon_MerchantItemEditor_Open()
	Epsilon_MerchantEditor:Hide()
	Epsilon_MerchantItemEditor_ClearAllFields()
	Epsilon_MerchantItemEditor:Show()
end