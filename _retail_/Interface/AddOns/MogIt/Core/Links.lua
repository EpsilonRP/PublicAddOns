local MogIt, mog = ...;
local L = mog.L;

local charset = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";
local base = #charset;
local maxlen = 3;

local function toBase(num)
	local str;
	if num <= 0 then
		str = "0";
	else
		str = "";
		while num > 0 do
			str = charset:sub((num % base) + 1, (num % base) + 1) .. str;
			num = math.floor(num / base);
		end
	end
	return str;
end

local function fromBase(str)
	local num = 0;
	for i = 1, #str do
		num = num + ((charset:find(str:sub(i, i)) - 1) * base ^ (#str - i));
	end
	return num;
end

function mog:SetToLink(set, enchant)
	local items = {};
	for k, v in pairs(set) do
		local itemID, bonusID, diffID = mog:ToNumberItem(v);
		if bonusID or diffID then
			tinsert(items, format("%s.%s.%s", toBase(itemID), toBase(bonusID or 0), toBase(diffID or 0)));
		else
			tinsert(items, toBase(itemID));
		end
	end
	return format("[MogIt:%s:00:%s]", table.concat(items, ";"), toBase(enchant or 0));
end

function mog:LinkToSet(link)
	local set = {};
	-- local items, race, gender, enchant = strsplit(":", link:match("MogIt:(.+)"));
	local items, enchant = link:match("MogItN?P?C?:([^:]*):?%w?%w?:?(%w*)");
	if items then
		if items:find("[.;]") then
			for item in gmatch(items, "[^;]+") do
				local itemID, bonusID, diffID = strsplit(".", item);
				table.insert(set, mog:ToStringItem(tonumber(fromBase(itemID)), bonusID and tonumber(fromBase(bonusID)), diffID and tonumber(fromBase(diffID))));
			end
		else
			for i = 1, #items / maxlen do
				local itemID = items:sub((i - 1) * maxlen + 1, i * maxlen);
				table.insert(set, mog:ToStringItem(tonumber(fromBase(itemID))));
			end
		end
	end
	enchant = enchant ~= "" and fromBase(enchant) or nil;
	return set, enchant;
end

function mog:NPCSetToLink(set, enchant)
	local items = {};
	for k, v in pairs(set) do
		local itemID, bonusID = mog:ToNumberItem(v);
		if bonusID then
			tinsert(items, format("%s.%s", toBase(itemID), toBase(bonusID)));
		else
			tinsert(items, toBase(itemID));
		end
	end
	return format("[MogItNPC:%s:00:%s]", table.concat(items, ";"), toBase(enchant or 0));
end

local function filter(self, event, msg, ...)
	if msg:match("%[(MogItNPC[^%]]+)%]") then
		msg = msg:gsub("%[(MogIt[^%]]+)%]", "|cff00ccff|H%1|h[MogIt NPC]|h|r");
	else
		msg = msg:gsub("%[(MogIt[^%]]+)%]", "|cffcc99ff|H%1|h[MogIt]|h|r");
	end
	return false, msg, ...;
end

local events = {
	"CHAT_MSG_SAY",
	"CHAT_MSG_YELL",
	"CHAT_MSG_EMOTE",
	"CHAT_MSG_GUILD",
	"CHAT_MSG_OFFICER",
	"CHAT_MSG_PARTY",
	"CHAT_MSG_PARTY_LEADER",
	"CHAT_MSG_RAID",
	"CHAT_MSG_RAID_LEADER",
	"CHAT_MSG_RAID_WARNING",
	"CHAT_MSG_BATTLEGROUND",
	"CHAT_MSG_BATTLEGROUND_LEADER",
	"CHAT_MSG_WHISPER",
	"CHAT_MSG_WHISPER_INFORM",
	"CHAT_MSG_BN_WHISPER",
	"CHAT_MSG_BN_WHISPER_INFORM",
	"CHAT_MSG_BN_CONVERSATION",
	"CHAT_MSG_BN_INLINE_TOAST_BROADCAST",
	"CHAT_MSG_BN_INLINE_TOAST_BROADCAST_INFORM",
	"CHAT_MSG_CHANNEL",

	-- EPSILON POSSIBLE COMMAND CHANNELS - So if you use .command channel for announce, it still gets parsed.
	"CHAT_MSG_SYSTEM",         --system
	"CHAT_MSG_GUILD_ACHIEVEMENT", --guild_announce,
	"CHAT_MSG_ACHIEVEMENT",    --achievement_announce,
	-- "CHAT_MSG_BN_WHISPER_INFORM", --blizzard_whisper, -- Remove Duplicate
	-- "CHAT_MSG_INSTANCE_CHAT", 	--instance,
	-- "CHAT_MSG_INSTANCE_CHAT_LEADER", --instance_leader,
	"CHAT_MSG_COMBAT_XP_GAIN",     --experience,
	"CHAT_MSG_COMBAT_HONOR_GAIN",  --honor,
	"CHAT_MSG_COMBAT_FACTION_CHANGE", --reputation,
	"CHAT_MSG_SKILL",              --skill-ups,
	"CHAT_MSG_TRADESKILLS",        --tradeskills,
	"CHAT_MSG_OPENING",            --opening,
	"CHAT_MSG_PET_INFO",           --pet_info,
	"CHAT_MSG_COMBAT_MISC_INFO",   --misc_info,
	"CHAT_MSG_BG_SYSTEM_HORDE",    --battleground_horde,
	"CHAT_MSG_BG_SYSTEM_ALLIANCE", --battleground_alliance,
	"CHAT_MSG_BG_SYSTEM_NEUTRAL",  --battleground_neutral,
	-- "CHAT_MSG_CHANNEL", --channel,
	"CHAT_MSG_TARGETICONS",        --target_icons,
	-- "CHAT_MSG_BN_CONVERSATION_NOTICE", --blizzard_services_alerts,
	-- "CHAT_MSG_PET_BATTLE_COMBAT_LOG", --pet_battle_combat,
	-- "CHAT_MSG_PET_BATTLE_INFO", --pet_battle_info,
};

for i, event in ipairs(events) do
	ChatFrame_AddMessageEventFilter(event, filter);
end

local SetHyperlink = ItemRefTooltip.SetHyperlink;

--epsi function to detect if key is down... really don't like this
-- local f  = CreateFrame("Frame", "mogTest", UIParent)
-- local keyPress = "";
-- local function detectKey(self,key)
-- 	keyPress = key;
-- 	print(key)
-- end

-- f:SetScript("OnKeyDown", detectKey)
-- f:SetPropagateKeyboardInput(true)

local f            = CreateFrame("Frame", "mogtarget", UIParent)
f:RegisterEvent("PLAYER_TARGET_CHANGED")
f:SetScript("OnEvent", function(self, event, target)
	if mog.db.profile.autoShowMogNPCNamePreviews then
		local targetName = UnitName("target")
		if targetName and targetName:match("MogIt") then
			local preview = mog:GetPreview();
			local set, enchant = mog:LinkToSet(targetName);
			preview.data.displayRace = mog.playerRace;
			preview.data.displayGender = mog.playerGender;
			preview.data.weaponEnchant = enchant;
			preview.model:ResetModel();
			preview.model:Undress();
			mog:AddToPreview(set, preview);
		end
	end
end)

function ItemRefTooltip:SetHyperlink(link)
	if link:find("^MogIt") then
		if IsModifiedClick("CHATLINK") then
			ChatEdit_InsertLink("[" .. link .. "]")
		else
			local preview = mog:GetPreview();
			local set, enchant = mog:LinkToSet(link);
			preview.data.displayRace = mog.playerRace;
			preview.data.displayGender = mog.playerGender;
			preview.data.weaponEnchant = enchant;
			preview.model:ResetModel();
			preview.model:Undress();
			mog:AddToPreview(set, preview);
		end
	else
		SetHyperlink(self, link);
	end
end
