-------------------------------------------------------------------------------
--
-- Icon picker interface.
--

local LibRPMedia = LibStub:GetLibrary("LibRPMedia-1.0");

EPSILON_BOOK_ICONS = {};

-- Generate the default icon list using LibRPMedia.

for index, name in LibRPMedia:FindAllIcons() do
	EPSILON_BOOK_ICONS[#EPSILON_BOOK_ICONS + 1] = name;
end

local startOffset = 0
local filteredList = nil

local function GetIconPath( button )
	if not button or not button.pickerIndex then
		return ""
	end
	
	local list = filteredList or EPSILON_BOOK_ICONS
	local texture = list[ button.pickerIndex + startOffset ]
	
	if texture:find("EpsilonBook") then
		texture = "Interface/" .. texture
	else
		texture = "Interface/Icons/" .. texture
	end
	return texture
end

-------------------------------------------------------------------------------
-- When one of the icon buttons are clicked.
--
function EpsilonBookIconPickerButton_OnClick( self )
	-- Apply the icon to the edited trait and close the picker.
	if EpsilonBookIconPicker.parent == EpsilonBookEditor then
		EpsilonBookEditor_Insert( "{icon:"..GetIconPath(self)..":32}" );
	elseif EpsilonBookIconPicker.parent == EpsilonBookFrame then
		if not EpsilonBookFrame.bookData then
			return
		end
		EpsilonBookFrame.bookData.icon = GetIconPath(self);
		EpsilonBookFrame_Update();
		EpsilonBook_SaveCurrentBook();
	end
	--PlaySound(54129)
	EpsilonBookIconPicker_Close()
end

-------------------------------------------------------------------------------
-- OnEnter handler, to magnify the icon and show the texture path.
--
function EpsilonBookIconPickerButton_ShowTooltip( self )
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
	local texture = GetIconPath(self)
	
    GameTooltip:AddLine( "|T"..texture..":64|t", 1, 1, 1, true )
    GameTooltip:AddLine( texture, 1, 0.81, 0, true )
    GameTooltip:Show()
end

-------------------------------------------------------------------------------
-- When the mousewheel is used on the icon map.
--
function EpsilonBookIconPicker_MouseScroll( delta )

	local a = EpsilonBookIconPicker.selectorFrame.scroller:GetValue() - delta
	-- todo: do we need to clamp?
	EpsilonBookIconPicker.selectorFrame.scroller:SetValue( a )
end
   
-------------------------------------------------------------------------------
-- When the scrollbar's value is changed.
--
function EpsilonBookIconPicker_ScrollChanged( value )
	
	-- Our "step" is 6 icons, which is one line.
	startOffset = math.floor(value) * 7
	EpsilonBookIconPicker_RefreshGrid()
end

-------------------------------------------------------------------------------
-- Set the textures of the icon grid from the icons in the list at the
-- current offset.
--
function EpsilonBookIconPicker_RefreshGrid()
	local list = filteredList or EPSILON_BOOK_ICONS
	for k,v in ipairs( EpsilonBookIconPicker.icons ) do
		local tex = list[startOffset + k]
		if tex then
			v:Show()
			if tex:find( "AddOns/" ) then
				tex = "Interface/" .. tex
			else
				tex = "Interface/Icons/" .. tex
			end
			
			v:SetNormalTexture( tex )
				
		else
			v:Hide()
		end
	end
end

-------------------------------------------------------------------------------
-- Called when the user types into the search box.
--
function EpsilonBookIconPicker_FilterChanged()
	local filter = EpsilonBookIconPicker.search:GetText():lower()
	if #filter < 3 then
		-- Ignore filters less than three characters
		if filteredList then
			filteredList = nil
			EpsilonBookIconPicker_RefreshScroll()
			EpsilonBookIconPicker_RefreshGrid()
		end
	else
		-- build new list
		filteredList = {}
		for k,v in ipairs( EPSILON_BOOK_ICONS ) do
			if v:lower():find( filter ) then
				table.insert( filteredList, v )
			end	
		end
		EpsilonBookIconPicker_RefreshScroll()
	end
end

-------------------------------------------------------------------------------
-- When we change the size of the list, update the scroll bar range.
--
-- @param reset Reset the scroll bar to the beginning.
--
function EpsilonBookIconPicker_RefreshScroll( reset )
	local list = filteredList or EPSILON_BOOK_ICONS 
	local max = math.floor((#list - 42) / 7)
	if max < 0 then max = 0 end
	EpsilonBookIconPicker.selectorFrame.scroller:SetMinMaxValues( 0, max )
	
	if reset then
		EpsilonBookIconPicker.selectorFrame.scroller:SetValue( 0 )
	end
	-- todo: does scroller auto clamp value?
	
	EpsilonBookIconPicker_ScrollChanged( EpsilonBookIconPicker.selectorFrame.scroller:GetValue() )
end
    
-------------------------------------------------------------------------------
-- Close the icon picker window. Use this instead of a direct Hide()
--
function EpsilonBookIconPicker_Close()
	EpsilonBookIconPicker.parent = nil;
	EpsilonBookIconPicker:Hide()
end
    
-------------------------------------------------------------------------------
-- Open the icon picker window.
--
function EpsilonBookIconPicker_Open( parent )
	filteredList = nil
	EpsilonBookIconPicker.parent = parent;
	
	EpsilonBookIconPicker_RefreshScroll( true )
	EpsilonBookIconPicker.search:SetText("")
	EpsilonBookIconPicker:Show()
end
