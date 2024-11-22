-------------------------------------------------------------------------------
--
-- Colour picker interface.
--

local PRESET_COLOUR_OPTIONS = {
	["Default"] = {
		{ "Red", "FF0000" },
		{ "Orange", "FFA500" },
		{ "Yellow", "FFFF00" },
		{ "Green", "00FF00" },
		{ "Blue", "0000FF" },
		{ "Purple", "FF00FF" },
		{ "White", "FFFFFF" },
		{ "Black", "000000" },
	},
	["Class"] = {
		{ "Death Knight", "C41F3B" },
		{ "Demon Hunter", "A330C9" },
		{ "Druid", "FF7D0A" },
		{ "Evoker", "33937F" },
		{ "Hunter", "ABD473" },
		{ "Mage", "40C7EB" },
		{ "Monk", "00FF96" },
		{ "Paladin", "F58CBA" },
		{ "Priest", "FFFFFF" },
		{ "Rogue", "FFF569" },
		{ "Shaman", "0070DE" },
		{ "Warlock", "8787ED" },
		{ "Warrior", "C79C6E" },
	},
	["Quality"] = {
		{ "Poor", "9D9D9D" },
		{ "Common", "FFFFFF" },
		{ "Uncommon", "1EFF00" },
		{ "Rare", "0070DD" },
		{ "Epic", "A335EE" },
		{ "Legendary", "FF8000" },
		{ "Artifact", "E6CC80" },
		{ "Heirloom", "00CCFF" },
	},
	["Chat"] = {
		{ "System", "FFFF00" },
		{ "Guild", "3CE13F" },
		{ "Officer", "40BC40" },
		{ "Party", "AAABFE" },
		{ "Party Leader", "77C8FF" },
		{ "Spell Link", "67BCFF" },
		{ "Say", "FFFFFF" },
		{ "Whisper", "FF7EFF" },
		{ "Yell", "FF3F40" },
		{ "Emote", "FF7E40" },
		{ "Raid", "FF7D01" },
		{ "Raid Leader", "FF4709" },
		{ "Raid Warning", "FF4700" },
		{ "Achievement", "FFFC01" },
		{ "Battle.net Whisper", "00FAF6" },
		{ "Battle.net Conversation", "00ADEF" },
	},
}

local function RGBToHex( r, g, b )
	-- default to white
	if not r or not g or not b then return "ffffff" end
	r = r * 255
	g = g * 255
	b = b * 255
	r = r <= 255 and r >= 0 and r or 0
	g = g <= 255 and g >= 0 and g or 0
	b = b <= 255 and b >= 0 and b or 0
	return string.format("%02x%02x%02x", r, g, b)
end

local function HexToRGBPerc( hex )
	local rhex, ghex, bhex, base
    if strlen(hex) == 6 then
        rhex, ghex, bhex = strmatch(hex, "(%x%x)(%x%x)(%x%x)")
        base = 255
    end
    if not (rhex and ghex and bhex) then
        return 1, 1, 1
    else
        return tonumber(rhex, 16)/base, tonumber(ghex, 16)/base, tonumber(bhex, 16)/base
    end
end

function EpsilonBookColourPickerDropDown_OnClick(self, arg1, arg2)
	local r, g, b = HexToRGBPerc( arg2 );
	EpsilonBookColourPicker.colourSelect:SetColorRGB( r, g, b )
	
	UIDropDownMenu_SetText(EpsilonBookColourPicker.selectPreset, "|cFF"..arg2..arg1.."|r")
end

function EpsilonBookColourPickerDropDown_OnLoad(frame, level, menuList)
	local info = UIDropDownMenu_CreateInfo()
	
	if level == 1 then
		for k,v in pairs( PRESET_COLOUR_OPTIONS ) do
			info.text = k
			info.disabled = false;
			info.notClickable = false;
			info.notCheckable = true;
			info.hasArrow = true;
			info.menuList = k
			UIDropDownMenu_AddButton(info)
		end
	elseif menuList then
		for i = 1, #PRESET_COLOUR_OPTIONS[menuList] do
		   info.text = "|cFF"..PRESET_COLOUR_OPTIONS[menuList][i][2]..PRESET_COLOUR_OPTIONS[menuList][i][1].."|r";
		   info.arg1 = PRESET_COLOUR_OPTIONS[menuList][i][1];
		   info.arg2 = PRESET_COLOUR_OPTIONS[menuList][i][2]
		   info.hasArrow = false;
		   info.notCheckable = false;
		   info.checked = strmatch(EpsilonBookColourPicker.value:GetText(), info.arg2);
		   info.func = EpsilonBookColourPickerDropDown_OnClick;
		   UIDropDownMenu_AddButton(info, level)
		end
	end
	
end

-------------------------------------------------------------------------------
-- When a colour is selected.
--
function EpsilonBookColourPicker_OnColourSelect( r, g, b )
	local hex = RGBToHex( r, g, b )
	EpsilonBookColourPicker.value:SetText( CreateColor( r, g, b, 1 ):WrapTextInColorCode( strupper( hex ) ) )
	UIDropDownMenu_SetText(EpsilonBookColourPicker.selectPreset, "Select a Preset Colour")
end

-------------------------------------------------------------------------------
-- When a hexadecimal value is entered.
--
function EpsilonBookColourPicker_OnTextChanged( self )
	local r, g, b = HexToRGBPerc( self:GetText() or "" )
	EpsilonBookColourPicker.colourSelect:SetColorRGB( r, g, b )
	UIDropDownMenu_SetText(EpsilonBookColourPicker.selectPreset, "Select a Preset Colour")
end

-------------------------------------------------------------------------------
-- When the Select Colour button is clicked.
--
function EpsilonBookColourPicker_OnColourPick()
	local hex = RGBToHex( EpsilonBookColourPicker.colourSelect:GetColorRGB() )
	EpsilonBookEditor_InsertTag( "color:"..hex, "color" )
	EpsilonBookColourPicker_Close()
end
    
-------------------------------------------------------------------------------
-- Close the colour picker window. Use this instead of a direct Hide()
--
function EpsilonBookColourPicker_Close()
	EpsilonBookColourPicker:Hide()
end
    
-------------------------------------------------------------------------------
-- Open the colour picker window.
--
function EpsilonBookColourPicker_Open( parent )
	EpsilonBookColourPicker:Show()
end
