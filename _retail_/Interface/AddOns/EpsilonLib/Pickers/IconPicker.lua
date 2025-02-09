-------------------------------------------------------------------------------
--
-- Icon picker interface.
--
-- Use EpsilonLibIconPicker_Open( returnFunc, closeOnClick, playSound ) to open.
--
-- @param returnFunc	If provided, clicking an icon will return its file path
--						as a string to this function.
--						If none provided, clicking an icon will instead set the 
--						following global variables you can call instead:
--
--						EpsilonLibIconPicker.IconPath	string	The icon path.
--
-- @param closeOnClick	If true, the picker will close when an icon is clicked.
-- @param playSound		If true, the picker will play a sound when an icon is
--						clicked.
--

local LibRPMedia = LibStub:GetLibrary("LibRPMedia-1.0");

EPSILONLIB_ICONS = {};

-- Generate the default icon list using LibRPMedia.

for index, name in LibRPMedia:FindAllIcons() do
	EPSILONLIB_ICONS[#EPSILONLIB_ICONS + 1] = name;
end

local startOffset = 0
local filteredList = nil

local MAX_ICONS		 = 42;
local ICONS_PER_LINE = 7;
local ICON_SIZE	 = 32;
local ICON_SPACING	 = 5;

local function GetIconPath( button )
	if not button or not button.pickerIndex then
		return ""
	end
	
	local list = filteredList or EPSILONLIB_ICONS;
	local texture = list[ button.pickerIndex + startOffset ];
	
	texture = "Interface/Icons/" .. texture

	return texture
end

-------------------------------------------------------------------------------
-- When the icon picker first loads, set up the icon map.
--
function EpsilonLibIconPicker_OnLoad( self )
	SetPortraitToTexture(self.portrait,"Interface/Icons/misc_rnrpaintbuttonup");
	self.TitleText:SetText( "Icons" );
		
	self:SetClampedToScreen( true );
	self:RegisterForDrag( "LeftButton" );
	self:SetScript( "OnDragStart", self.StartMoving );
	self:SetScript( "OnDragStop", self.StopMovingOrSizing );
	
    -- create icon map
    self.icons = {};
    for y = 0, (ICONS_PER_LINE - 1) do
        for x = 0, (ICONS_PER_LINE - 1) do
        local btn = CreateFrame( "Button", nil, self.selectorFrame, "EpsilonLibIconPickerButton" );
        btn:SetPoint( "TOPLEFT", "EpsilonLibIconPickerInset", ICON_SIZE*x+ICON_SPACING, (-1*ICON_SIZE)*(y-ICON_SPACING) );
        btn:SetSize( ICON_SIZE, ICON_SIZE );
            
        table.insert( self.icons, btn );
        btn.pickerIndex = #self.icons;
        end
    end
end

-------------------------------------------------------------------------------
-- When one of the icon buttons are clicked.
--
function EpsilonLibIconPickerButton_OnClick( self )
	-- Return the icon path through the provided return function
	if EpsilonLibIconPicker.returnFunc then
		EpsilonLibIconPicker.returnFunc( GetIconPath(self) );
	end
	EpsilonLibIconPicker.IconPath = GetIconPath(self);
	if EpsilonLibIconPicker.playSound then
		PlaySound(54129);
	end
	if EpsilonLibIconPicker.closeOnClick then
		EpsilonLibIconPicker_Close();
	end
end

-------------------------------------------------------------------------------
-- OnEnter handler, to magnify the icon and show the texture path.
--
function EpsilonLibIconPickerButton_ShowTooltip( self )
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	local texture = GetIconPath(self);
	
    GameTooltip:AddLine( "|T"..texture..":64|t", 1, 1, 1, true );
    GameTooltip:AddLine( texture, 1, 0.81, 0, true );
    GameTooltip:Show();
end

-------------------------------------------------------------------------------
-- When the mousewheel is used on the icon map.
--
function EpsilonLibIconPicker_MouseScroll( delta )

	local a = EpsilonLibIconPicker.selectorFrame.scroller:GetValue() - delta;
	-- todo: do we need to clamp?
	EpsilonLibIconPicker.selectorFrame.scroller:SetValue( a );
end
   
-------------------------------------------------------------------------------
-- When the scrollbar's value is changed.
--
function EpsilonLibIconPicker_ScrollChanged( value )
	
	-- Our "step" is ICONS_PER_LINE, which is one line.
	startOffset = math.floor(value) * ICONS_PER_LINE;
	EpsilonLibIconPicker_RefreshGrid();
end

-------------------------------------------------------------------------------
-- Set the textures of the icon grid from the icons in the list at the
-- current offset.
--
function EpsilonLibIconPicker_RefreshGrid()
	local list = filteredList or EPSILONLIB_ICONS;
	for k,v in ipairs( EpsilonLibIconPicker.icons ) do
		local tex = GetIconPath(v)
		if tex then
			v:Show();
			v:SetNormalTexture( tex );
		else
			v:Hide()
		end
	end
end

-------------------------------------------------------------------------------
-- Called when the user types into the search box.
--
function EpsilonLibIconPicker_FilterChanged()
	local filter = EpsilonLibIconPicker.search:GetText():lower();
	if #filter < 3 then
		-- Ignore filters less than three characters
		if filteredList then
			filteredList = nil;
			EpsilonLibIconPicker_RefreshScroll();
			EpsilonLibIconPicker_RefreshGrid();
		end
	else
		-- build new list
		filteredList = {}
		for k,v in ipairs( EPSILONLIB_ICONS ) do
			if v:lower():find( filter ) then
				table.insert( filteredList, v );
			end	
		end
		EpsilonLibIconPicker_RefreshScroll();
	end
end

-------------------------------------------------------------------------------
-- When we change the size of the list, update the scroll bar range.
--
-- @param reset Reset the scroll bar to the beginning.
--
function EpsilonLibIconPicker_RefreshScroll( reset )
	local list = filteredList or EPSILONLIB_ICONS;
	local max = math.floor((#list - MAX_ICONS) / ICONS_PER_LINE);
	if max < 0 then max = 0 end		-- can't have negative max value here
	EpsilonLibIconPicker.selectorFrame.scroller:SetMinMaxValues( 0, max );
	
	if reset then
		EpsilonLibIconPicker.selectorFrame.scroller:SetValue( 0 );
	end
	
	EpsilonLibIconPicker_ScrollChanged( EpsilonLibIconPicker.selectorFrame.scroller:GetValue() );
end
    
-------------------------------------------------------------------------------
-- Close the icon picker window. Use this instead of a direct Hide()
--
function EpsilonLibIconPicker_Close()
	EpsilonLibIconPicker.returnFunc = nil;
	EpsilonLibIconPicker.playSound = nil;
	EpsilonLibIconPicker.closeOnClick = nil;
	EpsilonLibIconPicker:Hide();
end
    
-------------------------------------------------------------------------------
-- Open the icon picker window.
--
-- @param returnFunc	If provided, clicking an icon will return its file path
--						as a string to this function.
--						If none provided, clicking an icon will instead set the 
--						following global variables you can call instead:
--
--						EpsilonLibIconPicker.IconPath	string	The icon path.
--
-- @param closeOnClick	If true, the picker will close when an icon is clicked.
-- @param playSound		If true, the picker will play a sound when an icon is
--						clicked.
--
function EpsilonLibIconPicker_Open( returnFunc, closeOnClick, playSound )
	filteredList = nil;
	EpsilonLibIconPicker.returnFunc = returnFunc or nil;
	EpsilonLibIconPicker.playSound = playSound or nil;
	EpsilonLibIconPicker.closeOnClick = closeOnClick or nil;
	
	EpsilonLibIconPicker_RefreshScroll( true );
	EpsilonLibIconPicker.search:SetText("");
	EpsilonLibIconPicker:Show();
end


