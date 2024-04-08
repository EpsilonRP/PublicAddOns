--
--Epsilon funcs
local EpsiLib_Server = EpsilonLib.Server
local server = EpsiLib_Server.server
--

GLink.channel = "xtensionxtooltip2";
local channelID = GetChannelName(GLink.channel)
local function debugAddonMessageFilter(self,event,message,...)

	--print("GLINK:", event,message,sender)
	--print(message:gsub("|",""));

end
ChatFrame_AddMessageEventFilter("CHAT_MSG_ADDON", debugAddonMessageFilter);

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

	if message:match("toggle") then
		GLink:ToggleOption();
		return;
	end

	if message:match("debug") then
		if GLink_debugging == true then
			GLink_debugging = false;
		else
			GLink_debugging = true;
		end
		print("|cff00ccff[DEBUGGING]|r", GLink_debugging)
	else
		EpsilonMessage(tonumber(messageContents[1]),arg)
	end
	
	-- local prefix = "EPSILON_G_PHASES";
	-- RegisterAddonMessagePrefix(prefix);
	-- SendAddonMessage(prefix)

end
SlashCmdList["GL"] = handler;

local prefixes = {
	[1] = "EPSILON_G_PHASES",
    [2] = "EPSILON_G_INFO",
	[3] = "EPSILON_TYPING",
	[4] = "EPSILON_G_SKBX",
	[5] = "EPSILON_G_LOGS",
	[6] = "EPSILON_P_PHASE",
	[7] = "EPSILON_G_MAP",
	[8] = "EPSILON_G_TOGLS",
	[9] = "EPSILON_S_PRVCY",
	[10] = "EPSILON_S_MOTD",
	[11] = "EPSILON_S_NAME",
	[12] = "EPSILON_S_INFO",
	[13] = "EPSILON_S_DESC",
	[14] = "EPSILON_P_INFO",
	[15] = "EPSILON_P_DESC",
	[16] = "EPSILON_S_TIME",
	[17] = "EPSILON_P_NPCS",
	[18] = "EPSILON_P_NPC",
	[19] = "EPSILON_S_GOBJ",
	[20] = "EPSILON_P_PHASE",
	[21] = "EPSILON_P_MEMS",
	[22] = "EPSILON_P_DSPLY",
	[23] = "EPSILON_G_APP",
	[24] = "EPSILON_G_SUMM",
	[25] = "EPSILON_G_PCFG",
}

server.receive("P_MAP", function(message, channel, sender)

	local records = {string.split(Epsilon.record, message)}

	for _, record in pairs(records) do
		--print(record)
		
	end

end)


function EpsilonMessage(prefix, message)

	--print(prefixes[prefix], message)
	--RegisterAddonMessagePrefix(prefixes[prefix])

	--SendAddonMessage(prefixes[prefix], strchar(31).. message .. strchar(30), "CHANNEL", channelID)
	server.send(prefixes[prefix]:gsub("EPSILON_",""), message);

end

local init = CreateFrame("FRAME");
init:RegisterEvent("PLAYER_ENTERING_WORLD");
init:SetScript("OnEvent", function(self,event)

    JoinChannelByName(GLink.channel)

end);