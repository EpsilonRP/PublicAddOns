-------------------------------------------------------------------------------
-- Epsilon (2022)
-------------------------------------------------------------------------------
-- Main module

Epsilon_Merchant = LibStub("AceAddon-3.0"):NewAddon( "Epsilon_Merchant" );
local Me = Epsilon_Merchant;

local soundIsPlaying = false;
local gettingSound;

-------------------------------------------------------------------------
-- Convert table to string
--
-- @param tbl Table to convert.
--
local function table_to_string(tbl)
	if type(tbl) ~= "table" then return tostring(tbl) end
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
-- Strip the ID of a unit from its GUID.
--
-- @param unitID Unit identifier, e.g. "player", "target", "NPC", etc.
--
local function GetUnitID( unitID )
	if not( UnitExists( unitID )) then
		return
	end

	local guid = UnitGUID( unitID )
	local unitType, _, _, _, _, id, _ = strsplit("-", guid)
	if not( (unitType == "Creature" or unitType == "Vehicle") and id ) then
		return
	end

	id = tonumber( id );
	return id;
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
-- Save phase data.

MSG_MULTI_FIRST       = "\001"
MSG_MULTI_NEXT        = "\002"
MSG_MULTI_LAST        = "\003"
MAX_CHARS_PER_SEGMENT = 3000

local function SetPhaseData( prefix, data )
	if not( data and prefix ) then
		return
	end

	local str = table_to_string( data )
	print(prefix, str)
	local length = #str
	if length > MAX_CHARS_PER_SEGMENT then
		local numEntriesRequired = math.ceil(length / MAX_CHARS_PER_SEGMENT)

		for i = 1, numEntriesRequired do
			-- Grab the substring for this segment
			local strSub = string.sub(str, (MAX_CHARS_PER_SEGMENT * (i - 1)) + 1, (MAX_CHARS_PER_SEGMENT * i))

			-- Stupid case handler for the first segment, so it's just the normal entry name & uses the 'FIRST' flag to we know to request more blocks after
			if i == 1 then
				strSub = MSG_MULTI_FIRST .. strSub
				C_Epsilon.SetPhaseAddonData(prefix, strSub)
			else
			-- For all else, append the segment number to the key
			-- We also prepend either the NEXT or the LAST character to the string, to act as a signal for if we need to request another block or this is the end
				local controlChar = MSG_MULTI_NEXT
				if i == numEntriesRequired then controlChar = MSG_MULTI_LAST end
				strSub = controlChar .. strSub
				C_Epsilon.SetPhaseAddonData(prefix .. i, strSub)
			end
		end
	else
		-- Wasn't long enough to need multi-part, save as one and move on with our lives
		C_Epsilon.SetPhaseAddonData(prefix, str)
	end
end

-------------------------------------------------------------------------
-- Load our vendor data.

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

	local register = {
		id = messageTicketId;
		type = "items";
	}

	tinsert( Epsilon_Merchant.RegisteredPrefixes, register );
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
		SetPhaseData( key, str );
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
		SetPhaseData( key, soundKitID );
	end
end

-------------------------------------------------------------------------
-- Play an NPC sound.
--

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

	local register = {
		id = messageTicketId;
		type = "playsound";
	}

	tinsert( Epsilon_Merchant.RegisteredPrefixes, register );
end

-------------------------------------------------------------------------
-- Get an NPC sound.
--

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

	local register = {
		id = messageTicketId;
		type = "loadsound";
		soundType = soundType;
	}

	tinsert( Epsilon_Merchant.RegisteredPrefixes, register );
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
		SetPhaseData( key, text );
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

	local register = {
		id = messageTicketId;
		type = "text";
	}

	tinsert( Epsilon_Merchant.RegisteredPrefixes, register );
end

-------------------------------------------------------------------------
-- Save a vendor's extra options and send to server
--
function Epsilon_Merchant_SaveOptions( options )
	if not( UnitExists("npc") and options ) then
		return
	end

	local guid = UnitGUID("npc");
	local unitType, _, _, _, _, id, _ = strsplit("-", guid);
	if not(unitType == "Creature" or unitType == "Vehicle") then
		return
	end

	EPSILON_VENDOR_OPTIONS[id] = options;

	Epsilon_MerchantFrame_UpdateRepairButtons();

	local text;
	if options then
		text = table_to_string( options );
	else
		text = "{}";
	end

	local prefix = "VENDOR_OPTIONS_";
	local key = prefix .. id;

	if key and text then
		SetPhaseData( key, text );
	end
end

-------------------------------------------------------------------------
-- Get a vendor's extra options.
--

function Epsilon_Merchant_GetOptions()
	if not Epsilon_MerchantFrame.merchantID then
		return
	end

	-- Send a request to the server.
	local prefix = "VENDOR_OPTIONS_";

	local messageTicketId = C_Epsilon.GetPhaseAddonData( prefix .. Epsilon_MerchantFrame.merchantID );

	if not messageTicketId then
		-- vendor not found ??? uh oh...
		return
	end

	local register = {
		id = messageTicketId;
		type = "options";
	}

	tinsert( Epsilon_Merchant.RegisteredPrefixes, register );
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
-- Sets a distance-based volume for NPC sounds.
--

local range_items = {
    { 37727,	1.0		},		-- 5:     Ruby Acorn, 36771 Sturdy Crates
    { 63427,	0.9		},		-- 6:     Worgsaw
    { 40551,	0.8		},		-- 10:    Gore Bladder, 34913 Highmesa's Cleansing Seeds, 21267 Toasting Goblet, 32321 Sparrowhawk Net, 42441 Bouldercrag's Bomb
    { 46722,	0.7		},		-- 15:    Grol'dom Net, 56184 Duarn's Net, 31129 Blackwhelp Net, 1251 Linen Bandage, 33069 Sturdy Rope
    { 10645,	0.6		},		-- 20:    Gnomish Death Ray, 21519 Mistletoe (F NPC/P)
    { 86567,	0.5		},		-- 25:    Yaungol Wind Chime, 13289 Egan's Blaster, 31463 Zezzak's Shard (F NPC/P)
    { 32960,	0.4		},		-- 30:    Elekk Dispersion Ray, 21713 Elune's Candle, 85231 Bag of Clams, 9328 Super Snapper FX, 7734 Six Demon Bag, 34191 Handful of Snowflakes
    { 24501,	0.3		},		-- 35:    Gordawg's Boulder, 18904 Zorbin's Ultra-Shrinker
    { 44114,	0.2		},		-- 40:    Old Spices, 44228 Baby Spice, 90888 Foot Ball, 90883 The Pigskin, 28767 The Decapitator, 109167 Findle's Loot-A-Rang, 34471 Vial of the Sunwell
    { 23836,	0.1		},		-- 45:    Wrangling Rope, 23836 Goblin Rocket Launcher
    { 116139,	0		},		-- 50:    Haunting Memento
};

local function SetVolumeFromNPCDistance()
	SetCVar("Sound_DialogVolume", 0);
	for i = 1, #range_items do
		if IsItemInRange( range_items[i][1] ) then
			SetCVar("Sound_DialogVolume", range_items[i][2]);
			break
		end
	end
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

local STORED_STRINGS_TABLE = {};
local multipartIter = 0;

function Epsilon_Merchant:OnInitialize()
	Epsilon_Merchant.db = LibStub( "AceDB-3.0" ):New( "Epsilon_Merchant", DB_Defaults, true );

	EPSILON_ITEM_BUYBACK = Epsilon_Merchant.db['profile']['EPSILON_ITEM_BUYBACK'];
	EPSILON_VENDOR_DATA = {};
	EPSILON_VENDOR_OPTIONS = {};

	--ChatFrame_AddMessageEventFilter( "CHAT_MSG_SYSTEM", OnSystemMessage );
	ChatFrame_AddMessageEventFilter( "CHAT_MSG_LOOT", OnLootMessage );

	hooksecurefunc(GossipFrame, "Hide", function(self)
		self:SetAlpha(1);
		self:EnableMouse(true)
	end);

	-- local original = GameTooltip:GetScript("SetInventoryItem")
	hooksecurefunc(GameTooltip, "SetBagItem", function(tooltip, bag, slot)
		if not( Epsilon_MerchantFrame.merchantID and Epsilon_MerchantFrame:IsShown() and EPSILON_VENDOR_DATA[Epsilon_MerchantFrame.merchantID] and #EPSILON_VENDOR_DATA[Epsilon_MerchantFrame.merchantID] > 0 ) then
			return
		end

		local texture, itemCount, _, _, _, _, link, _, _, itemID = GetContainerItemInfo(bag, slot)
		local price, vanillaPrice, count, currency, isListed;

		for i = 1, #EPSILON_VENDOR_DATA[Epsilon_MerchantFrame.merchantID] do
			if tonumber( EPSILON_VENDOR_DATA[Epsilon_MerchantFrame.merchantID][i][1] ) == tonumber( itemID ) then
				_, price, count, currency = unpack( EPSILON_VENDOR_DATA[Epsilon_MerchantFrame.merchantID][i] )
				price = tonumber( price );
				pricePerUnit = price / count
				price = math.ceil( pricePerUnit * itemCount);
				isListed = true;
			end
		end

		if itemID and ( not( price or isListed ) ) then
			_, _, _, _, _, _, _, _, _, _, vanillaPrice = GetItemInfo( itemID );
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

		if EPSILON_VENDOR_OPTIONS[Epsilon_MerchantFrame.merchantID].allowRefunds then
			if currency and ( itemCount % count == 0 ) then
				tooltip:AddLine( "|nYou may sell this item to a vendor for a full refund.", 0, 0.8, 1, 1, true );
			end

			if price and not currency then
				if appearanceIndex and appearanceStr then
					textLeft[appearanceIndex]:SetText( SELL_PRICE..": "..GetCoinTextureString( price ), 1, 1, 1 );
					textLeft[appearanceIndex]:SetTextColor( 1, 1, 1 );
					tooltip:AddLine( "|cFF87a9fe"..TRANSMOG_TOOLTIP_STRINGS[appearanceStr] );
				else
					tooltip:AddLine( SELL_PRICE..": "..GetCoinTextureString( price ), 1, 1, 1 );
				end
			elseif EPSILON_VENDOR_OPTIONS[Epsilon_MerchantFrame.merchantID] and EPSILON_VENDOR_OPTIONS[Epsilon_MerchantFrame.merchantID].allowSellJunk and not price and vanillaPrice then
				tooltip:AddLine( SELL_PRICE..": "..GetCoinTextureString( vanillaPrice ), 1, 1, 1 );
			end
		end
		tooltip:Show()
	end)

	GameTooltip:SetScript("OnTooltipAddMoney", function(self)
		-- >:D
	end)

	Epsilon_Merchant.RegisteredPrefixes = {};

	Epsilon_Merchant.EventFrame = CreateFrame( "Frame" );
	Epsilon_Merchant.EventFrame:RegisterEvent( "PLAYER_TARGET_CHANGED" );
	Epsilon_Merchant.EventFrame:RegisterEvent( "SOUNDKIT_FINISHED" );
	Epsilon_Merchant.EventFrame:RegisterEvent( "CHAT_MSG_ADDON" );
	Epsilon_Merchant.EventFrame:SetScript( "OnEvent", function(  self, event, prefix, text, channel, sender, ... )
		if event == "PLAYER_TARGET_CHANGED" and UnitExists("target") then
			Epsilon_Merchant_PlaySound( "onclick" );
		elseif event == "SOUNDKIT_FINISHED" then
			if soundIsPlaying then
				SetCVar("Sound_DialogVolume", 1);
			end
			soundIsPlaying = false;
		elseif event == "CHAT_MSG_ADDON" then

			if ( not( prefix and Epsilon_Merchant.RegisteredPrefixes ) or #Epsilon_Merchant.RegisteredPrefixes == 0 ) then
				return
			end

			for prefixIndex = 1, #Epsilon_Merchant.RegisteredPrefixes do
				if Epsilon_Merchant.RegisteredPrefixes[prefixIndex] and Epsilon_Merchant.RegisteredPrefixes[prefixIndex].id and prefix == Epsilon_Merchant.RegisteredPrefixes[prefixIndex].id then
					local prefixType = Epsilon_Merchant.RegisteredPrefixes[prefixIndex].type;

					if text == nil then text = "" end

					if string.match(text, "^[\001-\002]") then
						multipartIter = multipartIter + 1;
						text = text:gsub("^[\001-\002]", "");
						STORED_STRINGS_TABLE[multipartIter] = text;

						local messageTicketID = C_Epsilon.GetPhaseAddonData(prefix + ( multipartIter + 1 ) );
						local register = {
							id = messageTicketId;
							type = prefix;
						}

						tinsert( Epsilon_Merchant.RegisteredPrefixes, register );
						return
					elseif string.match(text, "^[\003]") then
						multipartIter = multipartIter + 1;
						text = text:gsub("^[\003]", "");
						STORED_STRINGS_TABLE[multipartIter] = text;
						text = table.concat(STORED_STRINGS_TABLE, "")

						-- reset our temp data
						wipe(STORED_STRINGS_TABLE);
						multipartIter = 0;
					end

					if prefixType == "items" then
						text = (loadstring or load)("return "..text)()
						if EPSILON_VENDOR_DATA[ Epsilon_MerchantFrame.merchantID ] then
							EPSILON_VENDOR_DATA[ Epsilon_MerchantFrame.merchantID ] = text;
						end
						Epsilon_MerchantFrame_Update();
					elseif prefixType == "loadsound" and gettingSound then
						local soundType = Epsilon_Merchant.RegisteredPrefixes[prefixIndex].soundType;
						local soundKitID = tonumber( text ) or 0;
						if not( soundKitID and Epsilon_MerchantSoundPicker[soundType.."Sound"] ) then
							return
						end
						Epsilon_MerchantSoundPicker[soundType.."Sound"]:SetText( "(Not Bound)" );
						gettingSound = false;
						if type( soundKitID ) ~= "number" then
							return
						end
						local soundName
						local i, iMax = 0, C_Epsilon.SoundKit_Count()-1
						while not soundName do
							local tempSound = C_Epsilon.SoundKit_Get(i)
							if tempSound.id == soundKitID then
								soundName = table.concat(tempSound.sounds, ", ", 0)
								print(soundName)
							end
							i = i + 1
							if i > iMax then break end
						end
						if soundName then
							Epsilon_MerchantSoundPicker[soundType.."Sound"]:SetText( soundName );
						end
					elseif prefixType == "playsound" then
						local soundKitID = tonumber( text );
						if type( soundKitID ) ~= "number" then
							return
						end
						soundIsPlaying = true;
						SetVolumeFromNPCDistance()
						C_Timer.After(0.01, function() SetVolumeFromNPCDistance() end);
						PlaySound( soundKitID, "Dialog", true, true )
					elseif prefixType == "options" then
						text = (loadstring or load)("return "..text)()
						local merchantID = Epsilon_MerchantFrame.merchantID or GetUnitID("npc") or GetUnitID("target")

						if not merchantID then error("MerchantID was nil. Debug:" .. tostring(UnitExists("npc")) .. " - " .. tostring(UnitGUID("npc"))) end

						EPSILON_VENDOR_OPTIONS[ merchantID ] = text or {};
						if Epsilon_MerchantEditor:IsShown() and Me.IsPhaseOwner() then
							local allowRefunds = ( EPSILON_VENDOR_OPTIONS[ merchantID ] and EPSILON_VENDOR_OPTIONS[ merchantID ].allowRefunds ) or false;
							local allowSellJunk = ( EPSILON_VENDOR_OPTIONS[ merchantID ] and EPSILON_VENDOR_OPTIONS[ merchantID ].allowSellJunk ) or false;
							Epsilon_MerchantEditor.allowRefunds:SetChecked( allowRefunds );
							Epsilon_MerchantEditor.allowSellJunk:SetChecked( allowSellJunk );
						end
					elseif prefixType == "text" then
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
					tremove( Epsilon_Merchant.RegisteredPrefixes, prefixIndex );
				end
			end
		end
	end)
end
