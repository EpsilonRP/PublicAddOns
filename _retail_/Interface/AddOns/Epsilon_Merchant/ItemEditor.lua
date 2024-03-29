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

function Epsilon_MerchantItemEditorChooseCurrency( itemID )
	if itemID and type(itemID) == "number" and itemID > 0 and GetItemInfo(itemID) then
		if tonumber( itemID ) == tonumber( Epsilon_MerchantItemEditor.itemID ) then
			UIErrorsFrame:AddMessage( "Items cannot use themselves as a currency.", 1.0, 0.0, 0.0, 53, 5 );
			return
		end
		
		local name, _, _, _, _, _, _, _, _, texture, _ = GetItemInfo(itemID);
		
		Epsilon_MerchantItemEditorCurrency.itemID = itemID;
		SetItemButtonTexture(Epsilon_MerchantItemEditorCurrency, texture or "Interface/Icons/inv_misc_questionmark");
		Epsilon_MerchantItemEditorCurrencyName:SetText( name or "" );
		Epsilon_MerchantItemEditorCurrencyAmount:SetText( 1 );
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
		Epsilon_MerchantItemEditorCurrency.itemID = currency;
		local name, _, _, _, _, _, _, _, _, texture, _ = GetItemInfo(currency);
		SetItemButtonTexture(Epsilon_MerchantItemEditorCurrency, texture or "Interface/Icons/inv_misc_questionmark");
		Epsilon_MerchantItemEditorCurrencyName:SetText( name or "" );
		Epsilon_MerchantItemEditorCurrencyAmount:SetText( amount );
	end
	
	MoneyFrame_Update( Epsilon_MerchantItemEditorMoneyFrame, price );
end

function Epsilon_MerchantItemEditor_SaveItem()

	local price = Epsilon_MerchantItemEditor.itemPrice:GetText() or 0
	local stackCount = Epsilon_MerchantItemEditor.stackCount:GetValue() or 1
	price = tonumber( price )
	stackCount = tonumber( stackCount )

	EPSILON_VENDOR_DATA[Epsilon_MerchantFrame.merchantID][Epsilon_MerchantItemEditor.itemIndex][2] = price;
	EPSILON_VENDOR_DATA[Epsilon_MerchantFrame.merchantID][Epsilon_MerchantItemEditor.itemIndex][3] = stackCount;
	
	if Epsilon_MerchantItemEditorCurrency.itemID then
		local itemID = tonumber( Epsilon_MerchantItemEditorCurrency.itemID );
		local amount = tonumber( Epsilon_MerchantItemEditorCurrencyAmount:GetText() ) or 1;
		if amount > 9999 then amount = 9999; elseif amount < 1 then amount = 1; end
		EPSILON_VENDOR_DATA[Epsilon_MerchantFrame.merchantID][Epsilon_MerchantItemEditor.itemIndex][4] = itemID;
		EPSILON_VENDOR_DATA[Epsilon_MerchantFrame.merchantID][Epsilon_MerchantItemEditor.itemIndex][5] = amount;
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
	Epsilon_MerchantItemEditorCurrency.itemID = nil;
	SetItemButtonTexture(Epsilon_MerchantItemEditorCurrency, "Interface/Icons/inv_misc_questionmark");
	Epsilon_MerchantItemEditorCurrencyName:SetText( "" );
	Epsilon_MerchantItemEditorCurrencyAmount:SetText( "0" );
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