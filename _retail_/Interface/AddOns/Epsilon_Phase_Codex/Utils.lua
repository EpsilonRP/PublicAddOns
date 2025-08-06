local EpsilonPhases = LibStub("AceAddon-3.0"):GetAddon("EpsilonPhases")
local PhaseClass = EpsilonLib.Classes.Phase
local Utils = {}

---- Chatstuff ----

local phaseLinkColor = CreateColorFromHexString("FF14D6B6")
local linkFormat = phaseLinkColor:WrapTextInColorCode("|Hphase:%s:%s:%s|h|T%s:16|t[%s]|h")
local chat_events = {
	"SAY",
	"YELL",
	"EMOTE",
	"GUILD",
	"OFFICER",
	"PARTY",
	"PARTY_LEADER",
	"RAID",
	"RAID_LEADER",
	"RAID_WARNING",
	"BATTLEGROUND",
	"BATTLEGROUND_LEADER",
	"WHISPER",
	"WHISPER_INFORM",
	"BN_WHISPER",
	"BN_WHISPER_INFORM",
	"BN_CONVERSATION",
	"BN_INLINE_TOAST_BROADCAST",
	"BN_INLINE_TOAST_BROADCAST_INFORM",
	"CHANNEL",

	"SYSTEM",
	"GUILD_ACHIEVEMENT",
	"ACHIEVEMENT",        --achievement_announce,
	"COMBAT_XP_GAIN",     --experience,
	"COMBAT_HONOR_GAIN",  --honor,
	"COMBAT_FACTION_CHANGE", --reputation,
	"SKILL",              --skill-ups,
	"TRADESKILLS",        --tradeskills,
	"OPENING",            --opening,
	"PET_INFO",           --pet_info,
	"COMBAT_MISC_INFO",   --misc_info,
	"BG_SYSTEM_HORDE",    --battleground_horde,
	"BG_SYSTEM_ALLIANCE", --battleground_alliance,
	"BG_SYSTEM_NEUTRAL",  --battleground_neutral,
	"TARGETICONS",        --target_icons,
}

local function getPhaseLinkStr(id, name, icon)
	return linkFormat:format(icon, name, id, icon, name)
end
Utils.getPhaseLinkStr = getPhaseLinkStr

local function parseChatLinkForSafeSend(str)
	local formatString = linkFormat:gsub("(phase:%%s:%%s:%%s)", "(%1)"):gsub("([%[%]])", "%%%1"):gsub("%%s", "[^|]+")
	local formatted = string.gsub(str, formatString, "[%1]")
	return formatted
end
Utils.parseChatLinkForSafeSend = parseChatLinkForSafeSend

local function convertSafeLinkToRealLink(str)
	return string.gsub(str, "%[phase:(%d+):(.-):(%d+)%]", function(icon, name, id)
		return getPhaseLinkStr(id, name, icon)
	end);
end
Utils.convertSafeLinkToRealLink = convertSafeLinkToRealLink

local _origFunc = SendChatMessage
SendChatMessage = function(text, ...)
	local filteredText = parseChatLinkForSafeSend(text)
	_origFunc(filteredText, ...)
end

local function ChatFilter(self, event, msg, sender, ...)
	local clean = convertSafeLinkToRealLink(msg)
	return false, clean, sender, ...;
end
Utils.ChatFilter = ChatFilter

local function ChatLinks_Init()
	-- We really want to wait until we're setup before we accept anything
	-- so we hook stuff in here
	for _, event in ipairs(chat_events) do
		ChatFrame_AddMessageEventFilter("CHAT_MSG_" .. event, ChatFilter);
	end
end
Utils.ChatLinks_Init = ChatLinks_Init

local function linkPhase(phase)
	local id = phase:GetPhaseID()
	local name = phase:GetPhaseName()
	local icon = phase:GetPhaseIcon(true)
	local link = getPhaseLinkStr(id, name, icon)

	if not ChatEdit_InsertLink(link) then
		ChatFrame_OpenChat(link);
	end
end
Utils.linkPhase = linkPhase

--- Calculations ---

local function calcBackground(number)
	if (number > 91) then
		number = number - 91
		if number > 71 then
			number = number + 14
		end
	end
	local x = math.floor(number / 13)
	local y = math.fmod(number, 13)
	if y ~= 0 then
		y = y - 1
	else
		y = 12
		x = x - 1
	end
	local phaseEmptyRightPercentage = EpsilonPhases.PHASEBACKGROUNDS_EMPTYSPACE_X / EpsilonPhases.PHASEBACKGROUNDS_X
	local phaseEmptyBottomPercentage = EpsilonPhases.PHASEBACKGROUNDS_EMPTYSPACE_Y / EpsilonPhases.PHASEBACKGROUNDS_Y
	local backgroundX = (x / 7) - (x / 7 * phaseEmptyRightPercentage)
	local backgroundY = (y / 13) - (y / 13 * phaseEmptyBottomPercentage)
	local backgroundX2 = ((x + 1) / 7) - (((x + 1) / 7) * phaseEmptyRightPercentage)
	local backgroundY2 = ((y + 1) / 13) - (((y + 1) / 13) * phaseEmptyBottomPercentage)
	return backgroundX, backgroundX2, backgroundY, backgroundY2
end
Utils.calcBackground = calcBackground

---- Misc ----

local function isPhaseTemp(phase)
	local phaseID = phase

	if type(phase) == 'table' then
		phaseID = phase:GetPhaseID()
	end

	if phaseID == 169 then
		return false
	end

	if EpsilonPhases:IsPhaseInTable(phaseID, EpsilonPhases.PublicPhases) then
		return false
	end

	for k, _ in pairs(EpsilonPhases.db.global.PrivatePhases) do
		if k == phaseID then
			return false
		end
	end
	return true
end
Utils.isPhaseTemp = isPhaseTemp

EpsilonPhases.Utils = Utils
