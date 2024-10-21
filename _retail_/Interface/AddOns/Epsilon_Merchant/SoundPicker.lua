-------------------------------------------------------------------------------
-- Epsilon (2022)
-------------------------------------------------------------------------------
--
-- Sound picker interface.
--

local filteredList = nil
local filterCategories = {};

local SOUND_FILTER_CATEGORIES = {
	{ 1, "Spells" },
	{ 2, "UI" },
	{ 3, "Footsteps" },
	{ 4, "Combat Impacts" },
	{ 6, "Combat Swings" },
	{ 7, "Greetings" },
	{ 8, "Casting" },
	{ 9, "Pick Up/Put Down" },
	{ 10, "NPC Combat" },
	{ 12, "Errors" },
	{ 13, "Birds" },
	{ 14, "Doodad Sounds" },
	{ 16, "Death Thud Sounds" },
	{ 17, "NPC Sounds" },
	{ 18, "Test/Temporary" },
	{ 19, "Foley Sounds" },
	{ 20, "Footsteps (Splashes)" },
	{ 21, "Character Splash Sounds" },
	{ 22, "Water Volume Sounds" },
	{ 23, "Tradeskill Sounds" },
	{ 24, "Terrain Emitter Sounds" },
	{ 25, "Game Object Sounds" },
	{ 26, "Spell Fizzles" },
	{ 27, "Creature Loops" },
	{ 28, "Zone Music Files" },
	{ 29, "Character Macro Lines" },
	{ 30, "Cinematic Music" },
	{ 31, "Cinematic Voice" },
	{ 50, "Zone Ambience" },
	{ 52, "Sound Emitters" },
	{ 53, "Vehicle States" },
};

local function SetCategoryFilter(category, value)
	if not(filterCategories) then
		filterCategories = {};
	end
	filterCategories[category] = value

	Epsilon_MerchantSoundPicker_FilterChanged()
end

local function SetAllCategoryFilter(setAllSources)
	if setAllSources then
		for i = 1, #SOUND_FILTER_CATEGORIES do
			filterCategories[SOUND_FILTER_CATEGORIES[i][2]] = SOUND_FILTER_CATEGORIES[i][1];
		end
	else
		filterCategories = {};
	end
	Epsilon_MerchantSoundPicker_FilterChanged()
end

local function GetCategoryFromFilterID( filterID )
	for i = 1, #SOUND_FILTER_CATEGORIES do
		if filterID == SOUND_FILTER_CATEGORIES[i][1] then
			return SOUND_FILTER_CATEGORIES[i][2];
		end
	end
	return "(Unknown)"
end

-------------------------------------------------------------------------
-- When the sound picker is first loaded.
--
-- @param self	The sound picker fraEpsilon_Merchant
--
function Epsilon_MerchantSoundPicker_OnLoad(self)
	self.Inset:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -6, 100)

	self:SetPoint("LEFT", GossipFrame, "RIGHT");

	self:RegisterEvent("SOUNDKIT_FINISHED")
	self:SetScript("OnEvent", function(self, event, arg1)
		if arg1 == Epsilon_MerchantSoundPicker.soundHandle then
			Epsilon_MerchantSoundPicker.soundPlaying = nil;
			Epsilon_MerchantSoundPicker_Update();
		end
	end)

	if self.NineSlice then
		self.NineSlice:SetFrameLevel(1)
	end

	self.TitleText:SetText("Sounds");
	SetPortraitToTexture(self.portrait,"Interface/Icons/misc_rnrpaintbuttonup");

	self.pool = CreateFramePool("Button", self, "Epsilon_MerchantSoundPickerButtonTemplate")

	self.includeLooping = false; -- // false = non-looping only (default); true = looping only; nil = both

	UIDropDownMenu_Initialize(self.FilterDropDown, function(dropdown, level)
		local filterSystem = {
			filters = {
				--{ type = FilterComponent.Checkbox, text = "Include Looping", set = function() self.includeLooping = not self.includeLooping; Epsilon_MerchantSoundPicker_FilterChanged(); end, isSet = function() return self.includeLooping end, },
				{ type = FilterComponent.Submenu, text = "Include Looping", value = 1, childrenInfo = {
					filters = {
						{
							type = FilterComponent.Radio,
						 	text = "Non-Looping Only",
						  	set = function()
								self.includeLooping = false;
								Epsilon_MerchantSoundPicker_FilterChanged();
								UIDropDownMenu_RefreshAll(self.FilterDropDown, UIDROPDOWNMENU_MENU_VALUE);
							end,
							isSet = function() return self.includeLooping == false end
						},
						{
							type = FilterComponent.Radio,
							text = "Looping Only",
							set = function()
								self.includeLooping = true;
								Epsilon_MerchantSoundPicker_FilterChanged();
								UIDropDownMenu_RefreshAll(self.FilterDropDown, UIDROPDOWNMENU_MENU_VALUE);
							end,
							isSet = function() return self.includeLooping == true end
						},
						{
							type = FilterComponent.Radio,
							text = "Both",
							set = function()
								self.includeLooping = nil;
								Epsilon_MerchantSoundPicker_FilterChanged();
								UIDropDownMenu_RefreshAll(self.FilterDropDown, UIDROPDOWNMENU_MENU_VALUE);
						  	end,
							isSet = function() return self.includeLooping == nil end
					  },
					},
				},
			},
				{ type = FilterComponent.Submenu, text = "Types", value = 2, childrenInfo = {
						filters = {
							{ type = FilterComponent.TextButton,
							  text = CHECK_ALL,
							  set = function()
									SetAllCategoryFilter(true);
									UIDropDownMenu_RefreshAll(self.FilterDropDown, UIDROPDOWNMENU_MENU_VALUE);
								end,
							},
							{ type = FilterComponent.TextButton,
							  text = UNCHECK_ALL,
							  set = function()
									SetAllCategoryFilter(false);
									UIDropDownMenu_RefreshAll(self.FilterDropDown, UIDROPDOWNMENU_MENU_VALUE);
								end,
							},
						},
					},
				},
			},
		};

		for i = 1, #SOUND_FILTER_CATEGORIES do
			local category = {
				type = FilterComponent.Checkbox,
				text = SOUND_FILTER_CATEGORIES[i][2],
				set = function(filter, value)
					if filter then
						SetCategoryFilter(SOUND_FILTER_CATEGORIES[i][2], SOUND_FILTER_CATEGORIES[i][1]);
					else
						SetCategoryFilter(SOUND_FILTER_CATEGORIES[i][2], nil);
					end
				end,
				isSet = function()
					return filterCategories[SOUND_FILTER_CATEGORIES[i][2]]
				end,
			};
			tinsert( filterSystem.filters[2].childrenInfo.filters, category );
		end

		FilterDropDownSystem.Initialize(dropdown, filterSystem, level);
	end, "MENU");

	--Epsilon_MerchantSoundPicker_Update()
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
		Epsilon_MerchantSoundPicker.selectedSound = self.soundKitID;
		Epsilon_MerchantSoundPicker.selectedName = self.name;
		Epsilon_MerchantSoundPicker_Update()
	end
end

-------------------------------------------------------------------------
-- Update the sound picker.
--
function Epsilon_MerchantSoundPicker_Update()
	local list;
	if not( filteredList ) then
		list = C_Epsilon.SoundKit_Count();
	else
		list = filteredList;
	end
	local soundOffset = FauxScrollFrame_GetOffset(Epsilon_MerchantSoundPickerScrollFrame);
	local index;
	Epsilon_MerchantSoundPicker.pool:ReleaseAll();
	local insetHeight = Epsilon_MerchantSoundPicker.Inset:GetHeight();
	local totalHeight = math.floor( insetHeight / 16 );
	for i = 1, totalHeight, 1 do
		local id = soundOffset + ( i - 1 );
		local button = Epsilon_MerchantSoundPicker.pool:Acquire();
		button:SetPoint("TOPLEFT", Epsilon_MerchantSoundPicker, 3, -49 - (16*i) );
		if id < list then
			button.id = id
			local info = filteredList and C_Epsilon.SoundKit_RetrieveSearch(id) or C_Epsilon.SoundKit_Get(id);
			if ( info ) then
				index = info.id;
				local name = info.sounds[0];
				for sound = 1, #info.sounds do
					name = name .. ", " .. info.sounds[sound];
				end
				button.soundKitID = index;
				button.name = name;
				local buttonText = button.Name;
				buttonText:SetText( "|cFFFFD100" .. info.id .. ":|r " .. name );
				button:SetScript("OnEnter", function(self)
					GameTooltip:SetOwner( self, "ANCHOR_RIGHT" )
					if info.loops then
						GameTooltip:AddDoubleLine( "|cFFFFD100SoundKitID:|r " .. info.id, "Loops", 1, 1, 1, 0.7, 0.7, 0.7 );
					else
						GameTooltip:AddLine( "|cFFFFD100SoundKitID:|r " .. info.id, 1, 1, 1 );
					end
					if info.soundType then
						GameTooltip:AddLine( "|cFFFFD100Type:|r " .. GetCategoryFromFilterID( info.soundType ), 1, 1, 1 );
					end
					if #info.sounds == 1 then
						GameTooltip:AddLine( "|cFFFFD100Sounds:|r " .. info.sounds[0], 1, 1, 1 );
					else
						GameTooltip:AddDoubleLine( "|cFFFFD100Sounds:|r", info.sounds[0], 1, 1, 1, 1, 1, 1 );
						for sound = 1, #info.sounds do
							GameTooltip:AddDoubleLine( " ", info.sounds[sound], 1, 1, 1, 1, 1, 1 );
						end
					end
					GameTooltip:AddLine( "<Left Click to Select>", 0.7, 0.7, 0.7, true );
					GameTooltip:Show()
				end);
				button:SetScript("OnLeave", GameTooltip_Hide);
			end

			if ( Epsilon_MerchantSoundPicker.soundPlaying == index ) then
				button.playButton:Hide();
				button.stopButton:Show();
			else
				button.playButton:Show();
				button.stopButton:Hide();
			end

			-- Highlight the correct who
			if ( Epsilon_MerchantSoundPicker.selectedSound == index ) then
				button:LockHighlight();
			else
				button:UnlockHighlight();
			end
			button:Show();
		else
			button:Hide();
		end

	end

	FauxScrollFrame_Update(Epsilon_MerchantSoundPickerScrollFrame, list, 14, 16 );
end


-------------------------------------------------------------------------
-- OnUpdate for when the sound picker is resized.
--
--
function Epsilon_MerchantSoundPicker_UpdateSize()

	local width = Epsilon_MerchantSoundPicker:GetWidth();

	for button in Epsilon_MerchantSoundPicker.pool:EnumerateActive() do
		button:SetWidth( width - 26 );
		local buttonText = button.Name
		buttonText:SetWidth( button:GetWidth() - 40 );
		local buttonHighlight = button.Highlight
		buttonHighlight:SetWidth( button:GetWidth() - 20 );
	end

	Epsilon_MerchantSoundPickerGreetingSound:SetWidth( width - 106 );
	Epsilon_MerchantSoundPickerGreetingSoundText:SetSize( width - 126, 16 );
	Epsilon_MerchantSoundPickerOnClickSound:SetWidth( width - 106 );
	Epsilon_MerchantSoundPickerOnClickSoundText:SetSize( width - 126, 16 );
	Epsilon_MerchantSoundPickerBuyItemSound:SetWidth( width - 106 );
	Epsilon_MerchantSoundPickerBuyItemSoundText:SetSize( width - 126, 16 );
	Epsilon_MerchantSoundPickerFarewellSound:SetWidth( width - 106 );
	Epsilon_MerchantSoundPickerFarewellSoundText:SetSize( width - 126, 16 );
end

function Epsilon_MerchantSoundPicker_OnSizeChanged(self, width, height)
	Epsilon_MerchantSoundPicker_Update()
end

-------------------------------------------------------------------------
-- Test a sound.
--
function Epsilon_MerchantSoundPicker_TestSound( self )
	-- Stop playing any current sounds.
	Epsilon_MerchantSoundPicker_StopSound();
	-- Play the new sound.
	if self.soundKitID then
		local willPlay, soundHandle = PlaySound( self.soundKitID, nil, false, true)
		-- Save the new soundHandle.
		if willPlay then
			Epsilon_MerchantSoundPicker.soundPlaying = self.soundKitID;
			Epsilon_MerchantSoundPicker.soundHandle = soundHandle;
		end
	end
	Epsilon_MerchantSoundPicker_Update()
end

-------------------------------------------------------------------------
-- Stop the current sound.
--
function Epsilon_MerchantSoundPicker_StopSound()
	if Epsilon_MerchantSoundPicker.soundHandle then
		StopSound( Epsilon_MerchantSoundPicker.soundHandle )
	end
	Epsilon_MerchantSoundPicker.soundPlaying = nil;
	Epsilon_MerchantSoundPicker_Update()
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
		StopSound( Epsilon_MerchantSoundPicker.soundHandle );
	end

	self:SetText( "(Not Bound)" );
	Epsilon_Merchant_SaveSound( self.soundType, 0 );
	PlaySound(840);
	PrintMessage( "Sound successfully unbound." );
end

-------------------------------------------------------------------------------
-- Called when the user types into the search box, or changes the filter.
--
local lastFilterTerm
function Epsilon_MerchantSoundPicker_FilterChanged()
	local filter		= Epsilon_MerchantSoundPicker.search:GetText():lower();
	local includeLoops  = Epsilon_MerchantSoundPicker.includeLooping; -- // false = non-looping only (default); true = looping only; nil = both

	local soundTypes = {};
	for k, v in pairs( filterCategories ) do
		tinsert( soundTypes, v );
	end
	C_Epsilon.SoundKit_FilterSoundTypes( unpack( soundTypes ) );
	if includeLoops then -- // In theory, we SHOULD be able to just pass includeLoops AS the arg.. however the C_ function is taking nil as false instead of true nil/not-given.
		filteredList = C_Epsilon.SoundKit_Search( filter, true );
	elseif includeLoops == false then
		filteredList = C_Epsilon.SoundKit_Search( filter, false );
	else
		filteredList = C_Epsilon.SoundKit_Search( filter )
	end
	-- build new list
	Epsilon_MerchantSoundPickerScrollFrame:SetVerticalScroll(0)
	Epsilon_MerchantSoundPicker_Update();

	lastFilterTerm = filter
end

local searchTimer_Length = 0.5
local searchTimer = C_Timer.NewTimer(0, function() end)

local function newSearch()
	if lastFilterTerm == Epsilon_MerchantSoundPicker.search:GetText():lower() then return end --// don't re-search on same term
	Epsilon_MerchantSoundPicker_FilterChanged()
end

function Epsilon_MerchantSoundPickerSearch_OnEnterPressed(self)
   self:ClearFocus()
   searchTimer:Cancel()
   newSearch()
end;

function Epsilon_MerchantSoundPickerSearch_OnTextChanged(self, userInput)
	SearchBoxTemplate_OnTextChanged(self);
	if userInput then
	  searchTimer:Cancel()
	  searchTimer = C_Timer.NewTimer(searchTimer_Length, newSearch)
	end
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
	Epsilon_MerchantSoundPicker.soundPlaying = nil
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
	Epsilon_MerchantSoundPicker_UpdateSize()
end
