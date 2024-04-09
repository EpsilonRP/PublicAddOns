addonName, GLink = ...;
--Debug

--Linkifier_Debug

--print("Linkifier_Debug")

local currentCreatureID = "nil";

StaticPopupDialogs["PHASENPC_CONFIRM_DELETE"] = {
	text = "Do you wish to delete npc with ID: |cff00ccff%s|r",
	button1 = "Yes",
	button2 = "No",
	OnAccept = function(self, event)
		SendChatMessage(".ph forge npc delete " .. self.text["text_arg1"], "GUILD");
	end,
	timeout = 0,
	whileDead = true,
	hideOnEscape = true,
	preferredIndex = 3,
  }

function GLink:Sanitize(arg)

	arg = arg:match("(%[.+%])") or arg:gsub("|cff00CCFF", ""):gsub("|r", "");

	return arg;

end

function GLink:GetSettings(IDType, hyperlink)

	print("GetSettings", IDType,  hyperlink)
	local callBack = false;

	if IDType then
		for k,v in pairs(GLink.hyperlinks[IDType]["RETURNS"]) do
			if v == hyperlink then
				print(v, IDType, hyperlink)
				--Matches a valid hyperlink.
				callBack = true;
			end
		end
	end

	if callBack == false then
		if IDType == "item" then
			print("item")
			return GLink_Settings.clickableItemLinks;
		elseif IDType == "spell" then
			print("spell")
			return GLink_Settings.clickableSpellLinks;
		end
	end

	return callBack;

end

function GLink:GetCommand(link, text)

	--link = GLink:Sanitize(link);
	text = GLink:Sanitize(text);
	local hidden = 0;
	
	--
	local ID, IDType, hyperlink;

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
	if link:match("lookup next") then
		ID = 50;
		IDType = "lookup next";
		hyperlink = "[Next]"
	end
	
	for k,v in pairs(GLink.hyperlinks) do
		for i = 1, table.getn(v["PATTERN"]) do
			if link:match(v["PATTERN"][i]:gsub("%(",""):gsub("%)","")) then
				
				if link:match(v["PATTERN"][i]) and not ID then
					ID = link:match(v["PATTERN"][i]);
				end

				IDType = k;

				--loop through returns
				if #v["RETURNS"] == 1 then
					
					if GLink_Settings.clickableItemLinks == false and IDType == "Item" then
						--do nothing
							hyperlink = nil;
							--hyperlink = text:match("(%[.+%])")
					else
					hyperlink = v["RETURNS"][1];
					hidden = v["HIDDEN"]
					end
				end
				if not hyperlink then
					hyperlink = text:match("(%[.+%])") or "[Copy GUID]";
				end
			end
		end
	end
	
	if GLink_debugging == true then
		print("|cff00ccff[DEBUG]|r Get Command Handler:", ID,IDType,hyperlink)
	end

	return ID, IDType, hyperlink;
end

function GLink:HyperlinkHandler(ID,IDType,hyperlink)
	local sHyperlink = hyperlink;
	local hyperlink = GLink_Settings.colour.. "|H"..IDType..":"..ID.."|h"..hyperlink.."|h|r";
	
	if GLink_debugging == true then
		print("|cff00ccff[DEBUG]|r Hyperlink Handler:", ID,IDType,hyperlink)
	end
	--print("test", IDType, sHyperlink)
	--print("table test",GLink_Settings.hiddenLinks["gameobject_entry"]["[Copy Entry]"])
	local hidden = 0;
	for k,v in pairs(GLink_Settings.hiddenLinks) do
		--print(k,v);
		if k == IDType then
			for k1,v1 in pairs(v) do
				--print(k1,v1)
				if sHyperlink == k1 then
					hidden = v1[1];
					--print("both match",sHyperlink, IDType, "with",k,k1, "hidden is:",hidden)
				end
			end
		end
	end
	if hidden == 1 then
		return hidden;
	else
		return hyperlink;
	end
end

function GLink:CopyHandler(ID,IDType,hyperlink)

	local output = "";

	if GLink_debugging == true then
		print("|cff00ccff[DEBUG]|r CopyHandler:",ID,IDType,hyperlink, type(ID));
	end
	if type(ID) == "table" then
		for k,v in pairs(ID) do
			output = output .. " " .. v;
		end
	else
		output = ID;
	end
	ChatFrame1EditBox:SetFocus()

	if ChatFrame1EditBox:GetText() ~= "" then
		ChatFrame1EditBox:SetText(ChatFrame1EditBox:GetText() .. output)
	else
		ChatFrame1EditBox:SetText(output)
	end
	
	ChatFrame1EditBox:HighlightText()
end

function GLink:HandleMapCoordinates(message, IDType)

	local x, y, z, orientation, map, degrees, radians;

	x = message:match(GLink.hyperlinks["gameobject_GPS"]["PATTERN"][1])
	y = message:match(GLink.hyperlinks["gameobject_GPS"]["PATTERN"][2])
	z = message:match(GLink.hyperlinks["gameobject_GPS"]["PATTERN"][3])
	degrees = message:match(GLink.hyperlinks["gameobject_GPS"]["PATTERN"][4])
	orientation = message:match(GLink.hyperlinks["gameobject_GPS"]["PATTERN"][5])
	--orientation = message:match(GLink.hyperlinks["gameobject_GPS"]["PATTERN"][4]) or 
	map = message:match(GLink.hyperlinks["gameobject_GPS"]["PATTERN"][6])
	if not orientation then --if it doesn't match via the various patterns, split the fucking string and put it into an array

		messageContents = {}
		for word in message:gmatch("([^:]+)") do
			table.insert(messageContents, word)
		end
		if #messageContents == 5 then
			x = messageContents[1]
			y = messageContents[2]
			z = messageContents[3]
			orientation = messageContents[4]
			map = messageContents[5]
		end

	end
	--orientation must be radians
	if message:match("Yaw/Turn: %d*") then
		--Convert to radians
		orientation = degrees*(math.pi/180)
	end
	return x, y, z, orientation, map;
end

function GLink:ExecuteCommand(ID,IDType,hyperlink)

	local commandIndex;

	if IDType == "lnkfer" or hyperlink:match("Copy URL") or IDType == "filepath" then --Don't touch URLS
		print("BREAK")
		return false;
	end

	for k,v in pairs(GLink.hyperlinks[IDType]["RETURNS"]) do
		if v == hyperlink then
			commandIndex = k;
		end
	end
	--GPS is weird

	if GLink_debugging == true then
		print("|cff00ccff[DEBUG]|r Execute Command:",ID,IDType,hyperlink, GLink.hyperlinks[IDType]["COMMAND"][commandIndex]);
	end

	if ID and IDType and commandIndex then
		if IDType == "gameobject_GPS" then
			local x, y, z, ori, map = GLink:HandleMapCoordinates(ID, IDType);
				SendChatMessage("." .. GLink.hyperlinks[IDType]["COMMAND"][commandIndex]:match("^%w*") .. " " .. x .. " " .. y .. " " .. z .. " " .. map .. " " .. ori);
			return true;
		
		elseif IDType == "phase_npc" and hyperlink == "[Delete]" then
			print(ID, IDType, hyperlink)

			currentCreatureID = ID;
			StaticPopup_Show("PHASENPC_CONFIRM_DELETE", ID);
		
		else
			--print(GLink.hyperlinks[IDType]["COMMAND"][commandIndex], GLink.hyperlinks[IDType]["RETURNS"][commandIndex])

			if hyperlink:match(GLink.hyperlinks[IDType]["RETURNS"][commandIndex]) then
				local theCommand = GLink.hyperlinks[IDType]["COMMAND"][commandIndex]
				if type(theCommand) == "function" then
					theCommand(ID)
				else
					SendChatMessage("." .. GLink.hyperlinks[IDType]["COMMAND"][commandIndex]:gsub("%#"..IDType,ID));
				end
				return true;
			end
		end
	else
		return false;
	end
end

--SHIFT click pastes in hyperlink, CTRL click outputs coordinates to chat.
function GLink:CopyMapCoordinates(message, IDType)

	local x, y, z, ori, map = GLink:HandleMapCoordinates(message, IDType);

	if GLink_debugging == true then
		print("|cff00ccff[DEBUG]|r CopyMapCoordinates:", x,y,z,ori,map)
	end

	local coordinates = { x, y, z, map, ori }
	GLink:CopyHandler(coordinates,IDType,hyperlink)

end



