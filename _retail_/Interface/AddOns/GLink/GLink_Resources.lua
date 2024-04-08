--Linkifier_GPS

addonName, GLink = ...;
local x, y, z, mapID, orientation = nil
local reload = false;

GLink.currentMap = nil;

GLink_Settings = {}

GLink_Settings.clickableItemLinks = GLink_Settings.clickableItemLinks or false;
GLink_Settings.clickableSpellLinks = GLink_Settings.clickableSpellLinks or false;

GLink_Settings.colour = GLink_Settings.colour or "|cff00CCFF";
GLink.altColour = "|cffADFFFF";

local GLink_Startup = CreateFrame("FRAME");
GLink_Startup:RegisterEvent("ADDON_LOADED");
GLink_Startup:SetScript("OnEvent", function(self)

	GLink_Settings.colour = GLink_Settings.colour or "|cff00CCFF";
end) 

GLink.currentMap = select(8,GetInstanceInfo());
--Linkifier_GPS

--[[
local function debugAddonMessageFilter(self,event,message,...)

	print(event,message,sender)
	--print(message:gsub("|",""));

end
ChatFrame_AddMessageEventFilter("CHAT_MSG_ADDON", debugAddonMessageFilter);
--]]

local input = {}
SLASH_GL1, SLASH_GL2 = '/gl', '/GL';
local function handler(message, editBox)

	local messageContents = {}
	local arg = ""; 
	for word in message:gmatch("[^%s]+") do
		table.insert(messageContents, word)
	end

	for i = 2, table.getn(messageContents) do
		arg = arg .. messageContents[i];
	end
	EpsilonMessage(tonumber(messageContents[1]),arg)

	
	-- local prefix = "EPSILON_G_PHASES";
	-- RegisterAddonMessagePrefix(prefix);
	-- SendAddonMessage(prefix)

end
SlashCmdList["GL"] = handler;

local prefixes = {
	[1] = "EPSILON_G_PHASES",
    [2] = "EPSILON_G_INFO",
    [3] = "EPSILON_G_LOGS",
	[4] = "EPSILON_TYPING",
	[5] = "EPSILON_P_MAP",
}
function EpsilonMessage(prefix, message)

	--print(prefixes[prefix], message)
	C_ChatInfo.SendAddonMessage(prefixes[prefix], message, "CHANNEL", 1)

end

GLink_GetMap = CreateFrame("FRAME");
GLink_GetMap:RegisterEvent("PLAYER_ENTERING_WORLD");
GLink_GetMap:SetScript("OnEvent", function(self, event)

	GLink.currentMap = select(8,GetInstanceInfo());
	--print(GLink.currentMap)

end)
