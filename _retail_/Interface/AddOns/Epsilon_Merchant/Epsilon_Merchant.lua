-------------------------------------------------------------------------------
-- Epsilon (2022)
-------------------------------------------------------------------------------
-- Main module

Epsilon_Merchant = LibStub("AceAddon-3.0"):NewAddon( "Epsilon_Merchant" );
local Me = Epsilon_Merchant;

local soundIsPlaying = false;

-------------------------------------------------------------------------
-- Convert table to string
--
-- @param tbl Table to convert.
--
local function table_to_string(tbl)
	if not( tbl ) then
		return "{}"
	end
    local result = "{"
    for k, v in pairs(tbl) do
        -- Check the key type (ignore any numerical keys - assume its an array)
        if type(k) == "string" then
            result = result.."[\""..k.."\"]".."="
        end

        -- Check the value type
        if type(v) == "table" then
            result = result..table_to_string(v)
        elseif type(v) == "boolean" then
            result = result..tostring(v)
        else
            result = result.."\""..v.."\""
        end
        result = result..","
    end
    -- Remove leading commas from the result
    if result ~= "" then
        result = result:sub(1, result:len()-1)
    end
    return result.."}"
end

-------------------------------------------------------------------------
-- Check if we own/are an officer in the current phase.

function Me.IsPhaseOwner()
	if C_Epsilon.IsOfficer() or C_Epsilon.IsOwner() then
		return true
	end
	return false
end

-------------------------------------------------------------------------
-- Load our vendor data.

local f = CreateFrame("Frame")

function Epsilon_Merchant_LoadVendor()
	if not Epsilon_MerchantFrame.merchantID then
		return
	end
	
	-- Send a request to the server.
	local messageTicketId = C_Epsilon.GetPhaseAddonData( "VENDOR_DATA_" .. Epsilon_MerchantFrame.merchantID )
	
	if not messageTicketId then
		-- vendor not found ??? uh oh...
		return
	end
	
	f:RegisterEvent("CHAT_MSG_ADDON")	
	f:SetScript("OnEvent", function( self, event, prefix, text, channel, sender, ... )
		if event == "CHAT_MSG_ADDON" and prefix == messageTicketId then
			f:UnregisterEvent( "CHAT_MSG_ADDON" )
			text = (loadstring or load)("return "..text)()
			EPSILON_VENDOR_DATA[ Epsilon_MerchantFrame.merchantID ] = text
			Epsilon_MerchantFrame_Update()
		end
	end)
end

-------------------------------------------------------------------------
-- Save a vendor's data and send to server
--
function Epsilon_Merchant_SaveVendor()
	if not Epsilon_MerchantFrame.merchantID then
		return
	end
	
	local str;
	if #EPSILON_VENDOR_DATA[Epsilon_MerchantFrame.merchantID] > 0 then
		str = table_to_string( EPSILON_VENDOR_DATA[Epsilon_MerchantFrame.merchantID] )
	else
		str = "{}"
	end
	
	local key = "VENDOR_DATA_" .. Epsilon_MerchantFrame.merchantID
	
	if key and str then
		C_Epsilon.SetPhaseAddonData( key, str );
	end
end

-------------------------------------------------------------------------
-- Save a vendor's data and send to server
--
function Epsilon_Merchant_SaveSound( soundType, soundKitID )
	if not( UnitExists("target") and soundType and soundKitID ) then
		return
	end
	
	local guid = UnitGUID("target")
	local unitType, _, _, _, _, id, _ = strsplit("-", guid)
	if not(unitType == "Creature") then
		return
	end
	
	id = tonumber( id )
	
	local prefix
	if soundType == "greeting" then
		prefix = "GREET_SOUND_"
	elseif soundType == "farewell" then
		prefix = "BYE_SOUND_"
	elseif soundType == "onclick" then
		prefix = "CLICK_SOUND_"
	elseif soundType == "buyitem" then
		prefix = "BUY_SOUND_"
	end
	
	if not( soundKitID and type( soundKitID ) == "number" and id and type( id ) == "number" ) then
		return
	end
	
	local key = prefix .. id
	
	if key and soundKitID then
		C_Epsilon.SetPhaseAddonData( key, soundKitID );
	end
end

-------------------------------------------------------------------------
-- Play an NPC sound.
--
local g = CreateFrame("Frame")

function Epsilon_Merchant_PlaySound( soundType )
	if not( UnitExists("target") and soundType ) then
		return
	end
	
	if soundIsPlaying then
		return
	end
	
	local guid = UnitGUID("target")
	local unitType, _, _, _, _, id, _ = strsplit("-", guid)
	if not(unitType == "Creature") then
		return
	end
	
	id = tonumber( id )
	
	-- Send a request to the server.
	local prefix
	if soundType == "greeting" then
		prefix = "GREET_SOUND_"
	elseif soundType == "farewell" then
		prefix = "BYE_SOUND_"
	elseif soundType == "onclick" then
		prefix = "CLICK_SOUND_"
	elseif soundType == "buyitem" then
		prefix = "BUY_SOUND_"
	end
	
	local messageTicketId = C_Epsilon.GetPhaseAddonData( prefix .. id )
	
	if not messageTicketId then
		-- vendor not found ??? uh oh...
		return
	end
	
	g:RegisterEvent("CHAT_MSG_ADDON")	
	g:SetScript("OnEvent", function( self, event, prefix, text, channel, sender, ... )
		if event == "CHAT_MSG_ADDON" and prefix == messageTicketId and text then
			g:UnregisterEvent( "CHAT_MSG_ADDON" )
			local soundKitID = tonumber( text )
			if type( soundKitID ) ~= "number" then
				return
			end
			soundIsPlaying = true;
			PlaySound( soundKitID, "Dialog", true, true )
		end
	end)
end

-------------------------------------------------------------------------
-- Get an NPC sound.
--
local v = CreateFrame("Frame")
local gettingSound

function Epsilon_Merchant_GetSound( soundType )
	if not( UnitExists("target") and soundType ) then
		return
	end
	
	if gettingSound then
		C_Timer.After( 0.2, function() Epsilon_Merchant_GetSound( soundType ) end )
		return
	end
	
	local guid = UnitGUID("target")
	local unitType, _, _, _, _, id, _ = strsplit("-", guid)
	if not(unitType == "Creature") then
		return
	end
	
	id = tonumber( id )
	
	-- Send a request to the server.
	local prefix
	if soundType == "greeting" then
		prefix = "GREET_SOUND_"
	elseif soundType == "farewell" then
		prefix = "BYE_SOUND_"
	elseif soundType == "onclick" then
		prefix = "CLICK_SOUND_"
	elseif soundType == "buyitem" then
		prefix = "BUY_SOUND_"
	end
		
	local messageTicketId = C_Epsilon.GetPhaseAddonData( prefix .. id )
	gettingSound = true;
	
	if not messageTicketId then
		-- vendor not found ??? uh oh...
		return
	end
	
	v:RegisterEvent("CHAT_MSG_ADDON")
	v:SetScript("OnEvent", function( self, event, prefix, text, channel, sender, ... )
		if event == "CHAT_MSG_ADDON" and prefix == messageTicketId and text then
			v:UnregisterEvent( "CHAT_MSG_ADDON" )
			local soundKitID = tonumber( text )
			Epsilon_MerchantSoundPicker[soundType.."Sound"]:SetText( "(Not Bound)" )
			if type( soundKitID ) ~= "number" then
				gettingSound = false
				return
			end
			for i = 1, #DB_SoundList do
				if DB_SoundList[i].id == soundKitID then
					Epsilon_MerchantSoundPicker[soundType.."Sound"]:SetText( DB_SoundList[i].name )
				end
			end
			gettingSound = false
		end
	end)
end

-------------------------------------------------------------------------
-- Save a vendor's portrait text and send to server
--
function Epsilon_Merchant_SavePortrait( text )
	if not( UnitExists("npc") and text ) then
		return
	end
	
	local guid = UnitGUID("npc")
	local unitType, _, _, _, _, id, _ = strsplit("-", guid)
	if not(unitType == "Creature") then
		return
	end
	
	id = tonumber( id )
	
	if not( text and type( text ) == "string" and string.len( text ) < 500 and id and type( id ) == "number" ) then
		return
	end
	
	local prefix = "VENDOR_TEXT_"
	local key = prefix .. id
	
	if key and text then
		C_Epsilon.SetPhaseAddonData( key, text );
	end
	
	if ( Epsilon_MerchantFrame:IsShown() ) then
		if ( text ~= "" ) then
			Epsilon_MerchantFrame_ShowPortrait(Epsilon_MerchantFrame, nil, text, -3, -42)
		else
			Epsilon_MerchantFrame_HidePortrait();
		end
	end
end

-------------------------------------------------------------------------
-- Get a vendor's portrait text.
--
local p = CreateFrame("Frame")

function Epsilon_Merchant_GetPortrait()
	if not( UnitExists("npc") ) then
		return
	end
	
	local guid = UnitGUID("npc")
	local unitType, _, _, _, _, id, _ = strsplit("-", guid)
	if not(unitType == "Creature") then
		return
	end
	
	id = tonumber( id )
	
	-- Send a request to the server.
	local prefix = "VENDOR_TEXT_"
		
	local messageTicketId = C_Epsilon.GetPhaseAddonData( prefix .. id )
	
	if not messageTicketId then
		-- vendor not found ??? uh oh...
		return
	end
	
	p:RegisterEvent("CHAT_MSG_ADDON")
	p:SetScript("OnEvent", function( self, event, prefix, text, channel, sender, ... )
		if event == "CHAT_MSG_ADDON" and prefix == messageTicketId and text then
			p:UnregisterEvent( "CHAT_MSG_ADDON" );
			text = tostring( text );
			
			-- Sanitise
			if string.len( text ) > 500 then
				return
			end
			
			if not( text ) or string.len( text ) < 0 then
				text = "";
			end
			
			if ( Epsilon_MerchantFrame:IsShown() ) then
				if ( text ~= "" ) then
					Epsilon_MerchantFrame_ShowPortrait(Epsilon_MerchantFrame, nil, text, -3, -42)
				else
					--print('not works')
					Epsilon_MerchantFrame_HidePortrait();
				end
			end
			if Epsilon_MerchantEditor:IsShown() and Me.IsPhaseOwner() then
				if text == "" then
					Epsilon_MerchantEditor.enableGreeting:SetChecked( false );
				else
					Epsilon_MerchantEditor.enableGreeting:SetChecked( true );
				end
				Epsilon_MerchantEditor.greeting.EditBox:SetText( text );
			end
		end
	end)
end

-------------------------------------------------------------------------
-- EXTREMELY TEDIOUS FILTERING :sob:
--
local EPSILON_FILTER_PATTERNS = {
	"Removed itemID \= %d+, amount \= %d+ from (.+)", -- remove item
	"You give %d+ copper to (.+)", -- gief monies
	"You take %d+ copper from (.+)", -- take monies
	"Added new option \".-\" to creature (%d+) on page %d+%.",	-- add new gossip option
	"Removed option %d+ from creature (%d+) on page %d+%.",	-- remove gossip option
	"Option %d+ on page %d+ now uses icon %d+ for creature (%d+).",	-- change gossip option icon
}

local EPSILON_LOOT_FILTER_PATTERNS = {
	"You create: item:.+%b[]%.", -- create an item
}

-------------------------------------------------------------------------------
-- Print a message to chat.
--
-- @param channel	The chat channel to print in.
-- @param msg 		Text to print.
--
function PrintMessage( channel, msg )
	if not( channel and msg ) then
		return
	end

	local info = ChatTypeInfo[channel]
	
	if not( info ) then
		return
	end
	
	for i = 1, NUM_CHAT_WINDOWS do
		local frame = _G["ChatFrame" .. i]
		
		if frame then
		
			-- well this seems fairly nasty
			local registered = {GetChatWindowMessages(i)}
			 
			for _,v in ipairs(registered) do
				if v == channel then
				 
					frame:AddMessage( msg, info.r, info.g, info.b )
					break
				end
			end
		end
	end
end

-------------------------------------------------------------------------------
-- Strip special codes from system message.
--
--	@param	msg	The string to strip.
--
local function StripMessage( msg )
	local escapes = {
		["|c%x%x%x%x%x%x%x%x"] = "", -- color start
		["|r"] = "", -- color end
		["|H(.+)|h"] = "%1", -- hyperlinks
		["creature_entry%:(%d+)%[.-%s%-%s%d+%]"] = "%1", -- creature entries
		["player%:(.-)%[.-%]"] = "%1", -- player entries
		["|T.-|t"] = "", -- textures
		["{.-}"] = "", -- raid target icons (unlikely but :shrug:)
	}
	for k, v in pairs(escapes) do
        msg = msg:gsub(k, v)
    end
	return msg
end

-------------------------------------------------------------------------------
-- Filter chat frames to suppress our system messages.
--
local function OnSystemMessage( chatFrame, event, message ) 
	message = StripMessage( message )
	for i = 1, #EPSILON_FILTER_PATTERNS do
		if message:match( EPSILON_FILTER_PATTERNS[i] ) then
			local name = message:match( EPSILON_FILTER_PATTERNS[i] )
			if Epsilon_MerchantFrame:IsShown() then
				return true
			elseif UnitExists("target") and not UnitIsPlayer("target") then
				local guid = UnitGUID("target")
				local unitType, _, _, _, _, id, _ = strsplit("-", guid)
				if name == id and Epsilon_MerchantFrame.addingVendor then
					if i == #EPSILON_FILTER_PATTERNS then
						PrintMessage( "SYSTEM", "|cff00CCFF|Hcreature_entry:"..name.."|h["..UnitName("target").." - "..name.."]|h|r is now a vendor." )
						Epsilon_MerchantFrame.addingVendor = nil
					end
					return true
				elseif name == id and Epsilon_MerchantFrame.removingVendor then
					PrintMessage( "SYSTEM", "|cff00CCFF|Hcreature_entry:"..name.."|h["..UnitName("target").." - "..name.."]|h|r is no longer a vendor. You may need to reopen the Gossip Frame for changes to take effect." )
					Epsilon_MerchantFrame.removingVendor = nil
					return true
				end
			end
		end
	end
end

-------------------------------------------------------------------------------
-- Filter chat frames to suppress our loot messages.
--
local function OnLootMessage( chatFrame, event, message ) 
	strippedMessage = StripMessage( message )
	for i = 1, #EPSILON_LOOT_FILTER_PATTERNS do
		if strippedMessage:match( EPSILON_LOOT_FILTER_PATTERNS[i] ) then
			if Epsilon_MerchantFrame:IsShown() then
				message = message:gsub( "create", "receive item" )
				PrintMessage( "LOOT", message )
				return true
			end
		end
	end
	return false
end

-------------------------------------------------------------------------------
-- Init
--
local DB_Defaults = {
	profile = {
		EPSILON_ITEM_BUYBACK = {};
	};
};

local TRANSMOG_TOOLTIP_STRINGS = {
	TRANSMOGRIFY_TOOLTIP_APPEARANCE_KNOWN,
	TRANSMOGRIFY_TOOLTIP_APPEARANCE_UNKNOWN,
	TRANSMOGRIFY_TOOLTIP_ITEM_UNKNOWN_APPEARANCE_KNOWN,
	TRANSMOGRIFY_TOOLTIP_REVERT,
}

function Epsilon_Merchant:OnInitialize()
	Epsilon_Merchant.db = LibStub( "AceDB-3.0" ):New( "Epsilon_Merchant", DB_Defaults, true );
	
	EPSILON_ITEM_BUYBACK = Epsilon_Merchant.db['profile']['EPSILON_ITEM_BUYBACK'];
	EPSILON_VENDOR_DATA = {};
	
	ChatFrame_AddMessageEventFilter( "CHAT_MSG_SYSTEM", OnSystemMessage );
	ChatFrame_AddMessageEventFilter( "CHAT_MSG_LOOT", OnLootMessage );
	
	local original = GameTooltip:GetScript("OnTooltipSetItem")
	GameTooltip:SetScript("OnTooltipSetItem", function(tooltip, ...)
		if not( Epsilon_MerchantFrame.merchantID and Epsilon_MerchantFrame:IsShown() and #EPSILON_VENDOR_DATA[Epsilon_MerchantFrame.merchantID] > 0 ) then
			return original(tooltip, ...)
		end
		
		local name, link = tooltip:GetItem();
		local price;
		local itemID, _, _, _, texture = GetItemInfoInstant(link)
		
		for i = 1, #EPSILON_VENDOR_DATA[Epsilon_MerchantFrame.merchantID] do
			if tonumber( EPSILON_VENDOR_DATA[Epsilon_MerchantFrame.merchantID][i][1] ) == tonumber( itemID ) then
				price = EPSILON_VENDOR_DATA[Epsilon_MerchantFrame.merchantID][i][2]
				price = tonumber( price );
			end
		end
		
		if not( price ) then
			return original(tooltip, ...)
		end
		
		local textLeft = tooltip.textLeft
		if not textLeft then
			local tooltipName = tooltip:GetName()
			textLeft = setmetatable({}, { __index = function(t, i)
				local line = _G[tooltipName .. "TextLeft" .. i]
				t[i] = line
				return line
			end })
			tooltip.textLeft = textLeft
		end
		local hasPrice = false;
		local appearanceIndex;
		for i = 2, tooltip:NumLines() do
			local line = textLeft[i]
			local text = line:GetText()
			for str = 1, #TRANSMOG_TOOLTIP_STRINGS do
				if text:find( TRANSMOG_TOOLTIP_STRINGS[str] ) then
					-- Save this for later...
					-- o_O
					--
					appearanceIndex = i;
					appearanceStr = str;
				end
			end
		end
		if appearanceIndex and appearanceStr then
			textLeft[appearanceIndex]:SetText( SELL_PRICE..": "..GetCoinTextureString( price ), 1, 1, 1 );
			textLeft[appearanceIndex]:SetTextColor( 1, 1, 1 );
			tooltip:AddLine( "|cFF87a9fe"..TRANSMOG_TOOLTIP_STRINGS[appearanceStr] );
		else
			tooltip:AddLine( SELL_PRICE..": "..GetCoinTextureString( price ), 1, 1, 1 );
		end
		tooltip:Show()
	end)
	
	GameTooltip:SetScript("OnTooltipAddMoney", function(self)
	end)
	
	local f = CreateFrame("Frame")
	f:RegisterEvent( "PLAYER_TARGET_CHANGED" )
	f:RegisterEvent( "SOUNDKIT_FINISHED" )
	f:SetScript( "OnEvent", function( self, event, ...)
		if event == "PLAYER_TARGET_CHANGED" and UnitExists("target") then
			Epsilon_Merchant_PlaySound( "onclick" )
		elseif event == "SOUNDKIT_FINISHED" then
			soundIsPlaying = false;
		end
	end)
end