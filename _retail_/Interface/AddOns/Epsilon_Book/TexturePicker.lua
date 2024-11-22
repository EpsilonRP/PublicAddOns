-------------------------------------------------------------------------------
--
-- Texture picker interface.
--

local startOffset = 0
local filteredList = nil

-------------------------------------------------------------------------------
-- When one of the texture buttons are clicked.
--
function EpsilonBookTexturePickerButton_OnClick( self )
	-- Apply the texture to the edited trait and close the picker. 
	EpsilonBookEditor_Insert( "{img:".. ( self.texture ) ..":".. ( self.width or 64 ) ..":".. ( self.height or 128 ) ..":l}" )
	
	PlaySound(54129)
	EpsilonBookTexturePicker_Close()
end

-------------------------------------------------------------------------------
-- OnEnter handler, to magnify the texture and show the texture path.
--
function EpsilonBookTexturePickerButton_ShowTooltip( self )
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
	
	local texture = self.texture;
	local width = self.width;
	local height = self.height;
	if width > 200 then
		local ratio = height / width;
		width = 128;
		height = ratio * width;
	end
	if height > 200 then
		local ratio = width / height;
		height = 128;
		width = ratio * height;
	end
    GameTooltip:AddLine( "|T"..texture..":"..height..":"..width.."|t", 1, 1, 1, true )
    GameTooltip:AddLine( texture, 1, 0.81, 0, true )
    GameTooltip:Show()
end

-------------------------------------------------------------------------------
-- When the mousewheel is used on the texture map.
--
function EpsilonBookTexturePicker_MouseScroll( delta )

	local a = EpsilonBookTexturePicker.selectorFrame.scroller:GetValue() - delta
	-- todo: do we need to clamp?
	EpsilonBookTexturePicker.selectorFrame.scroller:SetValue( a )
end
   
-------------------------------------------------------------------------------
-- When the scrollbar's value is changed.
--
function EpsilonBookTexturePicker_ScrollChanged( value )
	
	local width = EpsilonBookTexturePicker.Inset:GetWidth();
	width = width - EpsilonBookTexturePicker.ImageSize;
	local texturesPerLine = math.ceil( width / EpsilonBookTexturePicker.ImageSize );
	-- Our "step" is 7 textures, which is one line.
	startOffset = math.floor(value) * texturesPerLine
	EpsilonBookTexturePicker_RefreshGrid()
end

function EpsilonBookTexturePicker_ResolutionScale_OnLoad( self )
	self:SetObeyStepOnDrag( true )
	self:SetValue( EpsilonBookTexturePicker.ImageSize )
	_G[self:GetName().."Low"]:Hide()
	_G[self:GetName().."High"]:Hide()
	self.tooltipText = "Set the size of textures in the grid."
end

function EpsilonBookTexturePicker_ResolutionScale_OnValueChanged( self, value, userInput )
	EpsilonBookTexturePicker.ImageSize = value;
	EpsilonBookTexturePicker_RefreshScroll()
	EpsilonBookTexturePicker_RefreshGrid()
end

-------------------------------------------------------------------------------
-- Set the textures of the grid from the textures in the list at the
-- current offset.
--
function EpsilonBookTexturePicker_RefreshGrid()
	local list = filteredList or EPSILON_BOOK_TEXTURES

	if not EpsilonBookTexturePicker.icons then return end

	EpsilonBookTexturePicker.icons:ReleaseAll();
	local width, height = EpsilonBookTexturePicker.Inset:GetSize();
	width = width - EpsilonBookTexturePicker.ImageSize;
	height = height - EpsilonBookTexturePicker.ImageSize;
	local totalWidth, totalHeight = math.floor( width / EpsilonBookTexturePicker.ImageSize ), math.floor( height / EpsilonBookTexturePicker.ImageSize );
	local offset = 0;
	for y = 0, totalHeight do
        for x = 0, totalWidth do
			offset = offset + 1;
			local texture = list[startOffset + offset];
			if texture then
				local btn = EpsilonBookTexturePicker.icons:Acquire();
				btn:SetPoint( "TOPLEFT", "EpsilonBookTexturePickerInset", EpsilonBookTexturePicker.ImageSize*x+5, -1*EpsilonBookTexturePicker.ImageSize*y-5 );
				btn:SetSize( EpsilonBookTexturePicker.ImageSize, EpsilonBookTexturePicker.ImageSize )
				btn.texture = texture.file;
				btn.height = texture.height;
				btn.width = texture.width;
				btn:SetNormalTexture( texture.file );
				btn:Show();
			end
		end
	end
end

-------------------------------------------------------------------------------
-- Called when the user types into the search box.
--
function EpsilonBookTexturePicker_FilterChanged()
	local filter = EpsilonBookTexturePicker.search:GetText():lower()
	if #filter < 3 then
		-- Ignore filters less than three characters
		if filteredList then
			filteredList = nil
			EpsilonBookTexturePicker_RefreshScroll()
			EpsilonBookTexturePicker_RefreshGrid()
		end
	else
		-- build new list
		filteredList = {}
		for k,v in ipairs( EPSILON_BOOK_TEXTURES ) do
			local file = v.file
			if file:lower():find( filter ) then
				table.insert( filteredList, v )
			end	
		end
		EpsilonBookTexturePicker_RefreshScroll()
	end
end

-------------------------------------------------------------------------------
-- When we change the size of the list, update the scroll bar range.
--
-- @param reset Reset the scroll bar to the beginning.
--
function EpsilonBookTexturePicker_RefreshScroll( reset )
	local list = filteredList or EPSILON_BOOK_TEXTURES

	if not EpsilonBookTexturePicker.icons then return end

	local width = EpsilonBookTexturePicker.Inset:GetWidth();
	width = width - EpsilonBookTexturePicker.ImageSize;
	local texturesPerLine = math.ceil( width / EpsilonBookTexturePicker.ImageSize );
	local max = math.floor((#list - EpsilonBookTexturePicker.icons:GetNumActive()) / texturesPerLine)
	if max < 0 then max = 0 end
	EpsilonBookTexturePicker.selectorFrame.scroller:SetMinMaxValues( 0, max )
	
	if reset then
		EpsilonBookTexturePicker.selectorFrame.scroller:SetValue( 0 )
	end
	-- todo: does scroller auto clamp value?
	
	EpsilonBookTexturePicker_ScrollChanged( EpsilonBookTexturePicker.selectorFrame.scroller:GetValue() )
end
    
-------------------------------------------------------------------------------
-- 
--
function EpsilonBookTexturePicker_OnLoad( self )
	SetPortraitToTexture(self.portrait,"Interface/Icons/misc_rnrpaintbuttonup");
	self.TitleText:SetText( "Textures" )
		
	self:SetClampedToScreen( true )
	self:RegisterForDrag( "LeftButton" )
	self:SetScript( "OnDragStart", self.StartMoving )
	self:SetScript( "OnDragStop", self.StopMovingOrSizing )
	
	self.icons = CreateFramePool("Button", self.selectorFrame, "EpsilonBookTexturePickerButton");
end    

-------------------------------------------------------------------------------
-- Close the texture picker window. Use this instead of a direct Hide()
--
function EpsilonBookTexturePicker_Close()
	EpsilonBookTexturePicker:Hide()
end
    
-------------------------------------------------------------------------------
-- Open the texture picker window.
--
function EpsilonBookTexturePicker_Open()
	filteredList = nil
	
	EpsilonBookTexturePicker_RefreshScroll( true )
	EpsilonBookTexturePicker.search:SetText("")
	EpsilonBookTexturePicker:Show()
end
