-------------------------------------------------------------------------------
-- Epsilon (C) 2022
-------------------------------------------------------------------------------

--
-- Merchant Editing Panel
--

local Me = Epsilon_Merchant;

-------------------------------------------------------------------------------
-- Initial request for vendor info from the server.
--
function Epsilon_MerchantEditor_Load()
	Epsilon_Merchant_GetPortrait();
end

-------------------------------------------------------------------------------
-- Save changes.
--
function Epsilon_MerchantEditor_Save()
	local greetingEnabled = Epsilon_MerchantEditor.enableGreeting:GetChecked();
	
	if not( greetingEnabled ) then
		Epsilon_Merchant_SavePortrait( "" );
		return
	end
	
	local greeting = Epsilon_MerchantEditor.greeting.EditBox:GetText();
	
	if ( greeting ) then
		greeting = tostring( greeting );
	end
	
	if string.len( greeting ) < 1 then
		PlaySound( 47355 );
		UIErrorsFrame:AddMessage( "That greeting is too short.", 1.0, 0.0, 0.0, 53, 5 );
		return
	elseif string.len( greeting ) > 500 then
		PlaySound( 47355 );
		UIErrorsFrame:AddMessage( "That greeting is too long.", 1.0, 0.0, 0.0, 53, 5 );
		return
	elseif not( Me.IsPhaseOwner() ) then
		PlaySound( 47355 );
		UIErrorsFrame:AddMessage( "Only the phase owner and phase officers can change that.", 1.0, 0.0, 0.0, 53, 5 );
		return
	end
	
	Epsilon_Merchant_SavePortrait( greeting );
	
	PrintMessage( "SYSTEM", "Vendor greeting saved." )
	
	Epsilon_MerchantFrame_UpdateCurrencies();
	Epsilon_MerchantFrame_Update();
	PlaySound( 83 );
end

-------------------------------------------------------------------------------
-- Reset all form fields.
--
function Epsilon_MerchantEditor_ClearAllFields()
	Epsilon_MerchantEditor.greeting.EditBox:SetText( "" );
	Epsilon_MerchantEditor.enableGreeting:SetChecked( false );
end

-------------------------------------------------------------------------------
-- Close the merchant editor window. Use this instead of a direct Hide()
--
function Epsilon_MerchantEditor_Close()
	Epsilon_MerchantEditor_ClearAllFields();
	Epsilon_MerchantEditor:Hide();
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_CLOSE);
end
    
-------------------------------------------------------------------------------
-- Open the merchant editor window.
--
function Epsilon_MerchantEditor_Open()
	Epsilon_MerchantItemEditor:Hide()
	Epsilon_MerchantEditor_ClearAllFields();
	Epsilon_MerchantEditor:Show();
end