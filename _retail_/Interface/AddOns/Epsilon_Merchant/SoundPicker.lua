-------------------------------------------------------------------------------
-- Epsilon (2022)
-------------------------------------------------------------------------------
--
-- Sound picker interface.
--

local filteredList = nil

-------------------------------------------------------------------------
-- When the sound picker is first loaded.
--
-- @param self	The sound picker fraEpsilon_Merchant
--
function Epsilon_MerchantSoundPicker_OnLoad(self)
	self.Inset:SetPoint("TOPLEFT", self, "TOPLEFT", 3, -48)
	self.Inset:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -6, 100)
	
	if self.NineSlice then
		-- No idea why Blizzard added this dumb thing but it's DUMB so let's mess with it.
		self.NineSlice:SetFrameLevel(1)
	end

	for i = 2, 14 do
		local button = CreateFrame("Button", "Epsilon_MerchantSoundPickerButton"..i, Epsilon_MerchantSoundPicker, "Epsilon_MerchantSoundPickerButtonTemplate");
		button:SetID(i)
		button:SetPoint("TOP", _G["Epsilon_MerchantSoundPickerButton"..(i-1)], "BOTTOM");
	end
	
	Epsilon_MerchantSoundPicker_Update()
end

-------------------------------------------------------------------------
-- When one of the sound buttons is clicked.
--
-- @param self		The sound picker fraEpsilon_Merchant
-- @param button	The mouse button used.
--
function Epsilon_MerchantSoundPickerButton_OnClick(self, button)
	if ( button == "LeftButton" ) then
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
		local list = filteredList or DB_SoundList;
		Epsilon_MerchantSoundPicker.selectedSound = list[ self.id ].id
		Epsilon_MerchantSoundPicker.selectedName = list[ self.id ].name
		Epsilon_MerchantSoundPicker_Update()
	end
end

-------------------------------------------------------------------------
-- Update the sound picker.
--
function Epsilon_MerchantSoundPicker_Update()
	local list = filteredList or DB_SoundList;
	local soundOffset = FauxScrollFrame_GetOffset(Epsilon_MerchantSoundPickerScrollFrame);
	local index, name
	for i=1,14,1 do
		local id = soundOffset + i;
		local button = _G["Epsilon_MerchantSoundPickerButton"..i];
		button.id = id
		local info = list[id];
		if ( info ) then
			index = info.id;
			name = info.name;
		end
		local buttonText = _G["Epsilon_MerchantSoundPickerButton"..i.."Name"];
		buttonText:SetText(name)
		
		-- Highlight the correct who
		if ( Epsilon_MerchantSoundPicker.selectedSound == index ) then
			button:LockHighlight();
		else
			button:UnlockHighlight();
		end
		
		if ( id > #list ) then
			button:Hide();
		else
			button:Show();
		end
		
	end
	
	FauxScrollFrame_Update(Epsilon_MerchantSoundPickerScrollFrame, #list, 14, 16 );
end

-------------------------------------------------------------------------
-- Test a sound.
--
function Epsilon_MerchantSoundPicker_TestSound( self )
	local list = filteredList or DB_SoundList;
	-- Stop playing any current sounds.
	Epsilon_MerchantSoundPicker_StopSound()
	-- Play the new sound.
	if list[self.id].id then
		local willPlay, soundHandle = PlaySound( list[self.id].id, nil, false )
		-- Save the new soundHandle.
		if willPlay then
			Epsilon_MerchantSoundPicker.soundHandle = soundHandle;
		end
	end
end

-------------------------------------------------------------------------
-- Stop the current sound.
--
function Epsilon_MerchantSoundPicker_StopSound()
	if Epsilon_MerchantSoundPicker.soundHandle then
		StopSound( Epsilon_MerchantSoundPicker.soundHandle )
	end
end

-------------------------------------------------------------------------
-- Bind a sound assignment.
--
-- @param self		The keybind frame.
--
function Epsilon_MerchantSoundPicker_BindSound( self )
	if not( Epsilon_MerchantSoundPicker.selectedSound and Epsilon_MerchantSoundPicker.selectedName and self.soundType ) then
		UIErrorsFrame:AddMessage( "You must select a sound file from the list.", 1.0, 0.0, 0.0, 53, 5 );
		return
	end
	
	if not( UnitExists("target") ) then
		UIErrorsFrame:AddMessage( "You must select a creature.", 1.0, 0.0, 0.0, 53, 5 );
		return
	end
	
	-- Stop playing any current sounds.
	if Epsilon_MerchantSoundPicker.soundHandle then
		StopSound( Epsilon_MerchantSoundPicker.soundHandle )
	end
	
	self:SetText( Epsilon_MerchantSoundPicker.selectedName )
	Epsilon_Merchant_SaveSound( self.soundType, Epsilon_MerchantSoundPicker.selectedSound )
	PlaySound(840);
	PrintMessage( "Sound successfully bound." )
end

-------------------------------------------------------------------------
-- Unbind a sound assignment.
--
-- @param self		The keybind frame.
--
function Epsilon_MerchantSoundPicker_UnbindSound( self )
	if not( self.soundType ) then
		return
	end
	
	if not( UnitExists("target") ) then
		UIErrorsFrame:AddMessage( "You must select a creature.", 1.0, 0.0, 0.0, 53, 5 );
		return
	end
	
	-- Stop playing any current sounds.
	if Epsilon_MerchantSoundPicker.soundHandle then
		StopSound( Epsilon_MerchantSoundPicker.soundHandle )
	end
	
	self:SetText( "(Not Bound)" )
	Epsilon_Merchant_SaveSound( self.soundType, 0 )
	PlaySound(840);
	PrintMessage( "Sound successfully unbound." )
end

-------------------------------------------------------------------------------
-- Called when the user types into the search box.
--
function Epsilon_MerchantSoundPicker_FilterChanged()
	local filter = Epsilon_MerchantSoundPicker.search:GetText():lower()
	-- searches must be at least 3 characters long or this could get ugly...
	if #filter < 3 then
		filteredList = nil;
		Epsilon_MerchantSoundPicker_Update()
		return
	end
	-- build new list
	filteredList = {}
	for i = 1, #DB_SoundList do
		if strfind( DB_SoundList[i].name:lower(), filter ) then 
			tinsert( filteredList, DB_SoundList[i] )
		end
	end
	Epsilon_MerchantSoundPicker_Update()
end
    
-------------------------------------------------------------------------------
-- Close the sound picker window. Use this instead of a direct Hide()
--
function Epsilon_MerchantSoundPicker_Close()
	Epsilon_MerchantSoundPicker.selectedSound = nil
	Epsilon_MerchantSoundPicker.selectedName = nil
	Epsilon_MerchantSoundPicker:Hide()
end
    
-------------------------------------------------------------------------------
-- Open the sound picker window.
--
function Epsilon_MerchantSoundPicker_Open()
	filteredList = nil
	Epsilon_MerchantSoundPicker.selectedSound = nil
	Epsilon_MerchantSoundPicker.selectedName = nil
	Epsilon_MerchantSoundPicker.search:SetText("")
	Epsilon_MerchantSoundPicker.greetingSound:SetText("Loading...")
	Epsilon_MerchantSoundPicker.onclickSound:SetText("Loading...")
	Epsilon_MerchantSoundPicker.buyitemSound:SetText("Loading...")
	Epsilon_MerchantSoundPicker.farewellSound:SetText("Loading...")
	Epsilon_Merchant_GetSound( "greeting" )
	Epsilon_Merchant_GetSound( "onclick" )
	Epsilon_Merchant_GetSound( "buyitem" )
	Epsilon_Merchant_GetSound( "farewell" )
	Epsilon_MerchantSoundPicker:Show()
end
