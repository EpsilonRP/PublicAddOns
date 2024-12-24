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
	EpsilonBookTexturePicker.Selected = self;
	EpsilonBookTexturePicker.Inset2.FileName:SetText( self.texture );
	EpsilonBookTexturePicker.Inset2.Width:SetText( self.width );
	EpsilonBookTexturePicker.Inset2.Height:SetText( self.height );
	EpsilonBookTexturePicker.Inset2.Alignment:SetValue(1);

	if self.texCoords then
		EpsilonBookTexturePicker.Inset2.Left:SetText( self.texCoords.l );
		EpsilonBookTexturePicker.Inset2.Right:SetText( self.texCoords.r );
		EpsilonBookTexturePicker.Inset2.Top:SetText( self.texCoords.t );
		EpsilonBookTexturePicker.Inset2.Bottom:SetText( self.texCoords.b );
	else
		EpsilonBookTexturePicker.Inset2.Left:SetText( 0 );
		EpsilonBookTexturePicker.Inset2.Right:SetText( 1 );
		EpsilonBookTexturePicker.Inset2.Top:SetText( 0 );
		EpsilonBookTexturePicker.Inset2.Bottom:SetText( 1 );
	end
	EpsilonBookTexturePicker.Red = 1;
	EpsilonBookTexturePicker.Green = 1;
	EpsilonBookTexturePicker.Blue = 1;
	EpsilonBookTexturePicker.Inset2.TexturePreview:SetVertexColor( 1, 1, 1 );
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
	if self.atlas then
		GameTooltip:AddLine(CreateAtlasMarkup(self.atlas, width, height))
		GameTooltip:AddLine( self.atlas, 1, 0.81, 0, true )
	else
		GameTooltip:AddLine( "|T"..texture..":"..height..":"..width.."|t", 1, 1, 1, true )
		GameTooltip:AddLine( texture, 1, 0.81, 0, true )
	end
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
-- Update the preview image after an editbox field is changed
-- or an image is selected from the list.
--
function EpsilonBookTexturePicker_ResetPreview()
	local selected = EpsilonBookTexturePicker.Selected;

	if not selected then
		return
	end

	EpsilonBookTexturePicker.Inset2.FileName:SetText( selected.texture );
	EpsilonBookTexturePicker.Inset2.Width:SetText( selected.width );
	EpsilonBookTexturePicker.Inset2.Height:SetText( selected.height );
	EpsilonBookTexturePicker.Inset2.Alignment:SetValue(1);

	if selected.texCoords then
		EpsilonBookTexturePicker.Inset2.Left:SetText( selected.texCoords.l );
		EpsilonBookTexturePicker.Inset2.Right:SetText( selected.texCoords.r );
		EpsilonBookTexturePicker.Inset2.Top:SetText( selected.texCoords.t );
		EpsilonBookTexturePicker.Inset2.Bottom:SetText( selected.texCoords.b );
	else
		EpsilonBookTexturePicker.Inset2.Left:SetText( 0 );
		EpsilonBookTexturePicker.Inset2.Right:SetText( 1 );
		EpsilonBookTexturePicker.Inset2.Top:SetText( 0 );
		EpsilonBookTexturePicker.Inset2.Bottom:SetText( 1 );
	end
	EpsilonBookTexturePicker.Red = 1;
	EpsilonBookTexturePicker.Green = 1;
	EpsilonBookTexturePicker.Blue = 1;
	EpsilonBookTexturePicker.Inset2.TexturePreview:SetVertexColor( 1, 1, 1 );
	EpsilonBookTexturePicker_UpdatePreview()
end

-------------------------------------------------------------------------------
-- Update the preview image after an editbox field is changed
-- or an image is selected from the list.
--
function EpsilonBookTexturePicker_UpdatePreview()
	local fileName	= EpsilonBookTexturePicker.Inset2.FileName:GetText();
	local width		= tonumber( EpsilonBookTexturePicker.Inset2.Width:GetText() ) or 150;
	local height	= tonumber( EpsilonBookTexturePicker.Inset2.Height:GetText() ) or 150;
	
	if width > 150 then
		local ratio = height / width;
		width = 150;
		height = ratio * width;
	end
	if height > 150 then
		local ratio = width / height;
		height = 150;
		width = ratio * height;
	end

	local left		= tonumber( EpsilonBookTexturePicker.Inset2.Left:GetText()) or 0;
	local right		= tonumber( EpsilonBookTexturePicker.Inset2.Right:GetText()) or 1;
	local top		= tonumber( EpsilonBookTexturePicker.Inset2.Top:GetText()) or 0;
	local bottom	= tonumber( EpsilonBookTexturePicker.Inset2.Bottom:GetText()) or 1;

	local red		= EpsilonBookTexturePicker.Red or 1;
	local green		= EpsilonBookTexturePicker.Green or 1;
	local blue		= EpsilonBookTexturePicker.Blue or 1;
	
	EpsilonBookTexturePicker.Inset2.TexturePreview:SetSize( width, height );
	EpsilonBookTexturePicker.Inset2.TexturePreview:SetTexture( fileName );
	EpsilonBookTexturePicker.Inset2.TexturePreview:SetTexCoord( left, right, top, bottom );
	EpsilonBookTexturePicker.Inset2.TexturePreview:SetVertexColor( red, green, blue );
end

-------------------------------------------------------------------------------
-- When one of the texture buttons are clicked.
--

local alignments = { "l", "c", "r" };

function EpsilonBookTexturePicker_InsertImage()
	-- Apply the texture and close the picker. 

	local fileName	= EpsilonBookTexturePicker.Inset2.FileName:GetText();
	local width		= EpsilonBookTexturePicker.Inset2.Width:GetText();
	local height	= EpsilonBookTexturePicker.Inset2.Height:GetText();
	local alignment = alignments[EpsilonBookTexturePicker.Inset2.Alignment:GetValue()] or "l";

	local left		= tonumber( EpsilonBookTexturePicker.Inset2.Left:GetText()) or 0;
	local right		= tonumber( EpsilonBookTexturePicker.Inset2.Right:GetText()) or 1;
	local top		= tonumber( EpsilonBookTexturePicker.Inset2.Top:GetText()) or 0;
	local bottom	= tonumber( EpsilonBookTexturePicker.Inset2.Bottom:GetText()) or 1;
	
	local red		= EpsilonBookTexturePicker.Red or 1;
	local green		= EpsilonBookTexturePicker.Green or 1;
	local blue		= EpsilonBookTexturePicker.Blue or 1;

	if not( fileName and width and height and alignment ) then
		-- Sanitise all those fields...
		return
	end

	local tag = "{img:"..fileName..":"..width..":"..height..":"..alignment

	if ( left~=0 or right~=1 or top~=0 or bottom~=1 ) or ( red~=1 or green~=1 or blue~=1 ) then
		-- include texCoords if they're non-standard
		-- or if the following tag (colour) is used
		tag = tag .. ":"..left..":"..right..":"..top..":"..bottom;
	end
	if red~=1 or green~=1 or blue~=1 then
		-- include colours if they're non-standard
		tag = tag..":"..red..":"..green..":"..blue;
	end
	-- close the tag with end bracket
	tag = tag .. "}";

	EpsilonBookEditor_Insert( tag );
	
	PlaySound(54129);
	EpsilonBookTexturePicker_Close()
end

-------------------------------------------------------------------------------
-- Set the textures of the grid from the textures in the list at the
-- current offset.
--
function EpsilonBookTexturePicker_RefreshGrid()
	local list = filteredList
	if not list then
		EpsilonBookTexturePicker_FilterChanged()
		return
	end

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
				local normalTexture = btn:GetNormalTexture();
				if ( texture.texCoords ) then
					normalTexture:SetTexCoord(texture.texCoords.l, texture.texCoords.r, texture.texCoords.t, texture.texCoords.b);
					btn.texCoords = texture.texCoords;
				else
					normalTexture:SetTexCoord(0, 1, 0, 1);
					btn.texCoords = nil;
				end
				if texture.atlas then
					btn.atlas = texture.atlas;
				end
				btn:Show();
			end
		end
	end
end

-------------------------------------------------------------------------------
-- Called when the user types into the search box
-- or sets the filter dropdown.
--
function EpsilonBookTexturePicker_FilterChanged()
	if not EpsilonBookTexturePicker.search then
		return
	end
	local search = EpsilonBookTexturePicker.search:GetText():lower()
	if #search < 3 then
		-- Ignore searches less than three characters
		filteredList = {};
		if EpsilonBookTexturePicker.ShowTextures then
			for k,v in ipairs( EPSILON_BOOK_TEXTURES ) do
				local fileName = v.file
				table.insert( filteredList, v )
			end
		end
		if EpsilonBookTexturePicker.ShowAtlas then
			for k,v in pairs( EPSILON_BOOK_ATLAS_INFO ) do
				local fileName = k;
				for atlasName, atlasInfo in pairs(v) do
					local atlas = {
						file	= fileName;
						atlas	= atlasName;
						width	= atlasInfo[1];
						height	= atlasInfo[2];
						texCoords = {
							l		= atlasInfo[3] or 0;
							r		= atlasInfo[4] or 1;
							t		= atlasInfo[5] or 0;
							b		= atlasInfo[6] or 1;
						};
					}
					table.insert( filteredList, atlas )
				end
			end
		end
		EpsilonBookTexturePicker_RefreshScroll()
		EpsilonBookTexturePicker_RefreshGrid()
	else
		-- build new list
		filteredList = {}
		if EpsilonBookTexturePicker.ShowTextures then
			for k,v in ipairs( EPSILON_BOOK_TEXTURES ) do
				local fileName = v.file
				if fileName:lower():find( search ) then
					table.insert( filteredList, v )
				end	
			end
		end
		if EpsilonBookTexturePicker.ShowAtlas then
			for k,v in pairs( EPSILON_BOOK_ATLAS_INFO ) do
				local fileName = k;
				local foundFile = false;
				if fileName:lower():find( search ) then
					foundFile = true;
				end
				for atlasName, atlasInfo in pairs(v) do
					local foundAtlas = false;
					if atlasName:lower():find( search ) then
						foundAtlas = true;
					end
					local atlas = {
						file	= fileName;
						atlas	= atlasName;
						width	= atlasInfo[1];
						height	= atlasInfo[2];
						texCoords = {
							l		= atlasInfo[3] or 0;
							r		= atlasInfo[4] or 1;
							t		= atlasInfo[5] or 0;
							b		= atlasInfo[6] or 1;
						};
					}
					if foundFile or foundAtlas then
						table.insert( filteredList, atlas )
					end
				end
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
	local list = filteredList
	if not list then
		EpsilonBookTexturePicker_FilterChanged()
		return
	end

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

	EpsilonBookTexturePicker.Inset:SetPoint("RIGHT", -200, 0)

	EpsilonBookTexturePicker.ShowTextures = true;
	EpsilonBookTexturePicker.ShowAtlas = true;
		
	self:SetClampedToScreen( true )
	self:RegisterForDrag( "LeftButton" )
	self:SetScript( "OnDragStart", self.StartMoving )
	self:SetScript( "OnDragStop", self.StopMovingOrSizing )
	
	self.icons = CreateFramePool("Button", self.selectorFrame, "EpsilonBookTexturePickerButton");

	UIDropDownMenu_Initialize(self.FilterDropdown, function(dropdown, level)
		local filterSystem = {
			filters = {
				{ type = FilterComponent.Checkbox,
					text = "Textures",
					set = function(filter, value)
						EpsilonBookTexturePicker.ShowTextures = not EpsilonBookTexturePicker.ShowTextures;
						--UIDropDownMenu_RefreshAll(self.FilterDropdown, "Test");
						EpsilonBookTexturePicker_FilterChanged()
					end,
					isSet = function()
						return EpsilonBookTexturePicker.ShowTextures == true;
					end,
				},
				{ type = FilterComponent.Checkbox,
					text = "Atlas",
					set = function(filter, value)
						EpsilonBookTexturePicker.ShowAtlas = not EpsilonBookTexturePicker.ShowAtlas;
						--UIDropDownMenu_RefreshAll(self.FilterDropdown, "Test");
						EpsilonBookTexturePicker_FilterChanged()
					end,
					isSet = function()
						return EpsilonBookTexturePicker.ShowAtlas == true;
					end,
				},
			},
		};

		FilterDropDownSystem.Initialize(dropdown, filterSystem, level);
	end);
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
