--
--
--
addonName, GLink = ...;

local origChatFrame_OnHyperlinkShow = ChatFrame_OnHyperlinkShow;
	ChatFrame_OnHyperlinkShow = function(...)
	local chatFrame, link, text, button = ...;
	local event = ...;

	--print(self, event, link, text);
	--print(button, link, text)
	--GLink toggle
	if link:match("GLink_Toggle") then

		local messageContents = {}
		local arg = ""; 
		for word in link:gmatch("([^%:]+)") do
			table.insert(messageContents, word)
		end
		IDType = messageContents[2]:gsub("0", "");
		hyperlink = messageContents[3];
		hidden = messageContents[4];

		--print("FILTER",IDType, hyperlink, hidden)
		GLink:ToggleHyperlink(IDType, hyperlink, hidden);
		return false;

	end
		-- if type(text) == "string" and button == "RightButton" and IsModifiedClick() then
		-- 	local ID, IDType, hyperlink = GLink:GetCommand(link, text);
		-- 	print("toggle button", ID, IDType, hyperlink)
		-- 	GLink:ToggleHyperlink(IDType, hyperlink);
		-- end

		if type(text) == "string" and not IsModifiedClick() then
			local ID, IDType;

			
			ID, IDType, hyperlink = GLink:GetCommand(link, text);
			if link:match("item:%d*:%d*:%d*") and GLink_Settings.clickableItemLinks == false then
				return origChatFrame_OnHyperlinkShow(...); 
			end


			if GLink_debugging == true then
				print("|cff00ccff[DEBUG]|r Hyperlink click: ",link,text,ID,IDType,hyperlink)
			end

			if link:match("gameobject_GPS") then
				IDType = "gameobject_GPS";
				ID = link:gsub(IDType, "");
				hyperlink = text:match("(%[.+%])")
			end
			if text:match("X:-?%d*\.?%d*") then
				ID = link;
				IDType = "gameobject_GPS";
				hyperlink = text:match("(%[.+%])");
				--GLink:ExecuteCommand(text, "gameobject_GPS", "[Teleport]")
			end
			--Make an exception for lookup next. smh
			if text:match("lookup next") then
				ID = 50;
				IDType = "lookup next";
				hyperlink = "[Next]"
			end
			
			if ID and IDType and hyperlink then
				
				if hyperlink:match("%[Copy") then
					if hyperlink:match("Coordinates") then
						GLink:CopyMapCoordinates(ID, IDType)
					else
						GLink:CopyHandler(ID,IDType,hyperlink)
					end
				else
					--print(ID,IDType,hyperlink)
				GLink:ExecuteCommand(ID,IDType,hyperlink)
				end
				return false;
			end
		elseif type(text) == "string" and IsModifiedClick() == true then --shift key is pressed
			if GLink_debugging == true then
				print("|cff00ccff[DEBUG]|r Hyperlink shift+click: ",link,text,ID,IDType,hyperlink)
			end
			if link:match("gameobject_GPS") then
				IDType = "gameobject_GPS";
				ID = link:gsub(IDType, "");
				hyperlink = text:match("(%[.+%])")
				GLink:CopyMapCoordinates(ID, IDType)
			end
			if text:match("X:-?%d*\.?%d*") then
				ID = link;
				IDType = "gameobject_GPS";
				hyperlink = text:match("(%[.+%])");
				GLink:CopyMapCoordinates(ID, IDType)

				--GLink:ExecuteCommand(text, "gameobject_GPS", "[Teleport]")
			end

		end

	return origChatFrame_OnHyperlinkShow(...);
end


local function debugChatLookupFilter(self,event,message,...)

	--print(message:gsub("|", ""))
	local x, y, z, orientation;
	
	for k,v in pairs(GLink.hyperlinks) do
		local ID, IDType;
		for i = 1, table.getn(v["PATTERN"]) do
			if message:match(v["PATTERN"][i]) and not ID and not IDType then
				 --:gsub("%(",""):gsub("%)","")
				ID = message:match(v["PATTERN"][i]);
				IDType = k;
			end
			
			-- if message:match(v["PATTERN"][i]) and not ID and not IDType then --:gsub("%(",""):gsub("%)","")
			-- 	ID = message:match(v["PATTERN"][i]);
			-- 	IDType = k;
			-- end
		end
		if ID and IDType then
			--print(message:gsub("|", ""))
			for k,v in pairs(GLink.hyperlinks[IDType]["RETURNS"]) do
				if IDType == "gameobject_GPS" and not IDType:match("item") then
					x, y, z, orientation = GLink:HandleMapCoordinates(message, IDType)
				
				elseif IDType == "filepath" then
					return false, message,...;
				else
					local hyperlink = GLink:HyperlinkHandler(ID,IDType,v);
					--if hyperlink is hidden then don't concatenate anything
					if hyperlink == 1 then

					else
						message = message .. GLink.altColour .. " -|r " ..  GLink:HyperlinkHandler(ID,IDType,v)
					end
				end
				
			end
			if x and y and z and orientation then
				local teleport = GLink.altColour .. " -|r ".. GLink_Settings.colour .. "|Hgameobject_GPS:" .. x .. ":" .. y .. ":" .. z .. ":" .. orientation .. ":" .. GLink.currentMap .. "|h[Teleport]|h|r";
				local CopyCoords = GLink.altColour .. " -|r ".. GLink_Settings.colour .. "|Hgameobject_GPS:" .. x .. ":" .. y .. ":" .. z .. ":" .. orientation .. ":" .. GLink.currentMap .. "|h[Copy Coordinates]|h|r"
				message = message .. teleport .. CopyCoords;
			end
		end
	end
	return false, message,...;
end
ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", debugChatLookupFilter);
ChatFrame_AddMessageEventFilter("CHAT_MSG_ACHIEVEMENT", debugChatLookupFilter);
ChatFrame_AddMessageEventFilter("CHAT_MSG_BN_WHISPER_INFORM", debugChatLookupFilter);
ChatFrame_AddMessageEventFilter("CHAT_MSG_COMBAT_XP_GAIN", debugChatLookupFilter);
ChatFrame_AddMessageEventFilter("CHAT_MSG_COMBAT_HONOR_GAIN", debugChatLookupFilter);
ChatFrame_AddMessageEventFilter("CHAT_MSG_COMBAT_FACTION_CHANGE", debugChatLookupFilter);
ChatFrame_AddMessageEventFilter("CHAT_MSG_TRADESKILLS", debugChatLookupFilter);
ChatFrame_AddMessageEventFilter("CHAT_MSG_OPENING", debugChatLookupFilter);
ChatFrame_AddMessageEventFilter("CHAT_MSG_PET_INFO", debugChatLookupFilter);
ChatFrame_AddMessageEventFilter("CHAT_MSG_COMBAT_MISC_INFO", debugChatLookupFilter);
ChatFrame_AddMessageEventFilter("CHAT_MSG_BG_SYSTEM_HORDE", debugChatLookupFilter);
ChatFrame_AddMessageEventFilter("CHAT_MSG_BG_SYSTEM_ALLIANCE", debugChatLookupFilter);
ChatFrame_AddMessageEventFilter("CHAT_MSG_BG_SYSTEM_NEUTRAL", debugChatLookupFilter);
ChatFrame_AddMessageEventFilter("CHAT_MSG_TARGETICONS", debugChatLookupFilter);
ChatFrame_AddMessageEventFilter("CHAT_MSG_BN_CONVERSATION_NOTICE", debugChatLookupFilter);
