-------------------------------------------------------------------------------
-- Epsilon (2025)
-------------------------------------------------------------------------------

-- Main module
--
local addonName, ns = ...
local prefix = "EPS_AURA"

local C_Epsilon = C_Epsilon;
local EpsiLib = EpsilonLib;
local LibDeflate = LibStub:GetLibrary("LibDeflate");
local AceSerializer = LibStub:GetLibrary("AceSerializer-3.0");
local AceComm = LibStub:GetLibrary("AceComm-3.0")

Epsilon_AuraManager = LibStub("AceAddon-3.0"):NewAddon("Epsilon_AuraManager");
Epsilon_AuraManager.RealName = addonName

local f = CreateFrame("Frame")
local loadCallbacks = {}
local categories = { "overrides", "suppress", "custom" }
local lastPhase = 169

-- to map index of aura to index of button - since we hide some auras
local auraMappingTable = {
	["HELPFUL"] = {},
	["HARMFUL"] = {}
}

local targetAuraMappingTable = {
	["HELPFUL"] = {},
	["HARMFUL"] = {}
}

local raidAuraMappingTable = {}

local localAuras = {}
local phaseAuras = {}
local playerAuras = {
	[UnitName("player")] = localAuras,
}
local sort_func
Epsilon_AuraManager.showHidden = false

-- Static Popup Dialogs

StaticPopupDialogs["EpsilonAuraManager_DELETEAURA"] = {
	text = "Are you sure you want to delete your edits to this spell or aura?",
	button1 = "Accept",
	button2 = "Cancel",
	OnAccept = function(self, data)
		EpsilonAuraManagerAuraEditor_DeleteBuff(data.index, data.isLocal);
	end,
	timeout = 0,
	showAlert = true,
	whileDead = true,
	hideOnEscape = true,
	preferredIndex = 3,
}

StaticPopupDialogs["EpsilonAuraManager_SPELLALREADYINLIST"] = {
	text = "This spell or aura is already in the list - load data now?",
	button1 = "Yes",
	button2 = "No",
	OnAccept = function(self, data)
		local auraList = Epsilon_AuraManager_GetAurasTable()
		for i, aura in ipairs(auraList) do
			if aura.spellID == data then
				EpsilonAuraManagerFrame.selected = i
				EpsilonAuraManagerAuraEditor_Refresh()
				EpsilonAuraManagerFrame_Update()
				break;
			end
		end
	end,
	timeout = 0,
	showAlert = true,
	whileDead = true,
	hideOnEscape = true,
	preferredIndex = 3,
}

StaticPopupDialogs["EpsilonAuraManager_CANCELCONFIRMATION"] = {
	text = "Are you sure you want to close without saving your changes?",
	button1 = "Yes",
	button2 = "No",
	OnAccept = function()
		EpsilonLibIconPicker_Close()
		EpsilonAuraManagerFrame_Update()
		EpsilonAuraManagerAuraEditor:Hide()
	end,
	timeout = 0,
	showAlert = true,
	whileDead = true,
	hideOnEscape = true,
	preferredIndex = 3,
}

-------------------------------------------------------------------------------
-- Check if DM mode is currently enabled.
--
local function IsDMEnabled()
	if C_Epsilon.IsDM and (C_Epsilon.IsOfficer() or C_Epsilon.IsOwner()) then return true; else return false; end
end

-------------------------------------------------------------------------------
-- Check if player is ranked phase officer.
--
local function IsPhaseOfficer()
	if C_Epsilon.IsOfficer() then return true; else return false; end
end

-------------------------------------------------------------------------------
-- Check if player is ranked phase owner.
--
local function IsPhaseOwner()
	if C_Epsilon.IsOwner() then return true; else return false; end
end

---------------------------------------------------------------------------
-- Compress data for upload to phase.
--
local function CompressForUpload(str)
	str = AceSerializer:Serialize(str)
	str = LibDeflate:CompressDeflate(str, { level = 9 })
	str = LibDeflate:EncodeForWoWChatChannel(str)
	return str;
end

---------------------------------------------------------------------------
-- Decompress data for download from phase.
--
local function DecompressForDownload(str)
	str = LibDeflate:DecodeForWoWChatChannel(str)
	str = LibDeflate:DecompressDeflate(str)
	if str ~= "" and str ~= nil then
		_, str = AceSerializer:Deserialize(str)
	end
	return str;
end

local function compressForAddonMsg(str)
	str = AceSerializer:Serialize(str)
	str = LibDeflate:CompressDeflate(str, { level = 9 })
	--str = LibDeflate:EncodeForWoWAddonChannel(str)
	str = LibDeflate:EncodeForWoWChatChannel(str)
	return str;
end

local function decompressForAddonMsg(str)
	--str = LibDeflate:DecodeForWoWAddonChannel(str)
	str = LibDeflate:DecodeForWoWChatChannel(str)
	str = LibDeflate:DecompressDeflate(str)
	_, str = AceSerializer:Deserialize(str)
	return str;
end


local b = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'

-------------------------------------------------------------------------
-- Save phase data.
--

local function SetPhaseData(prefix, data)
	if not (data and prefix) then
		return
	end

	data = CompressForUpload(data);
	EpsiLib.PhaseAddonData.Set(prefix, data);
end

-------------------------------------------------------------------------
-- Hook function for replacing buff/aura tooltip text with our substitutions.
--

local _origSetUnitAura = GameTooltip.SetUnitAura

local function ReplaceBuffText(self, unitID, auraIndex, filter)
	local mappingTable
	local name = UnitName(unitID)

	if not filter then filter = "HELPFUL" end

	if unitID == "player" then
		mappingTable = auraMappingTable
	elseif unitID == "target" then
		mappingTable = targetAuraMappingTable
	elseif string.find(unitID, 'raid') then
		mappingTable = raidAuraMappingTable[unitID]
	end
	if not mappingTable or not mappingTable[filter] then -- dunno how but we got this one time, so just fallback to the default if so
		return _origSetUnitAura(self, unitID, auraIndex, filter)
	end
	if unitID and auraIndex then
		local _, _, _, _, _, _, _, _, _, spellID = UnitAura(unitID, mappingTable[filter][auraIndex], filter);
		if spellID then
			local data
			local isOverridden
			if unitID == "player" and localAuras[spellID] then
				data = localAuras[spellID];
			elseif unitID ~= "player" and playerAuras[name] and playerAuras[name][spellID] then
				data = playerAuras[name][spellID]

				if phaseAuras[spellID] then
					isOverridden = true
				end
			end

			if phaseAuras[spellID] and not phaseAuras[spellID].allowOverride then
				data = phaseAuras[spellID];
			end

			if data then
				GameTooltip:ClearLines();
				GameTooltip:AddLine(data.name, 1, 0.81, 0);
				GameTooltip:AddLine(data.desc, 1, 1, 1, 1);

				if isOverridden then
					GameTooltip:AddLine("|cfff018d8Personal Aura")
				end

				if not (data.visible) then
					GameTooltip:AddLine("|cFF707070Hidden Aura")
				end

				GameTooltip:Show()
			else
				_origSetUnitAura(self, unitID, mappingTable[filter][auraIndex], filter)
			end
		end
	end
end

local function ReplaceDebuffText(self, unitID, auraIndex)
	ReplaceBuffText(self, unitID, auraIndex, "HARMFUL")
end

local _origGetSpellTexture = GetSpellTexture

function GetSpellTexture(id)
	local origTexture, originalIcon = _origGetSpellTexture(id)
	return (phaseAuras[id] and phaseAuras[id].icon) or (localAuras[id] and localAuras[id].icon) or _origGetSpellTexture(id), originalIcon
end

function GetSpellName(id)
	local name = GetSpellInfo(id)

	return (phaseAuras[id] and phaseAuras[id].name) or (localAuras[id] and localAuras[id].name) or name
end

local _origGetSpellInfo = GetSpellInfo

function GetSpellInfo(spell, bookType, original)
	local name, rank, icon, castTime, minRange, maxRange, spellID, originalIcon
	if bookType ~= nil then
		name, rank, icon, castTime, minRange, maxRange, spellID, originalIcon = _origGetSpellInfo(spell, bookType)
	else
		name, rank, icon, castTime, minRange, maxRange, spellID, originalIcon = _origGetSpellInfo(spell)
	end

	if original then
		return name, rank, icon, castTime, minRange, maxRange, spellID, originalIcon
	end

	if phaseAuras[spellID] then
		name = phaseAuras[spellID].name
		icon = phaseAuras[spellID].icon
	end

	if ((phaseAuras[spellID] and phaseAuras[spellID].allowOverride or not phaseAuras[spellID]) and localAuras[spellID]) then
		name = localAuras[spellID].name
		icon = localAuras[spellID].icon
	end

	return name, rank, icon, castTime, minRange, maxRange, spellID, originalIcon
end

local _origGetSpellBookItemTexture = GetSpellBookItemTexture

function GetSpellBookItemTexture(index, bookType)
	local name, subName, id = GetSpellBookItemName(index, bookType)
	local icon = _origGetSpellBookItemTexture(index, bookType)

	if GetSpellBookItemInfo(index, bookType) == "FLYOUT" or bookType == "pet" then
		return icon
	end

	return GetSpellTexture(id)
end

local _origGetSpellBookItemName = GetSpellBookItemName

function GetSpellBookItemName(slot, bookType)
	local name, subName, id = _origGetSpellBookItemName(slot, bookType)

	return (phaseAuras[id] and phaseAuras[id].name) or (localAuras[id] and localAuras[id].name) or name, subName, id
end

local _origGetSpellDescription = GetSpellDescription

function GetSpellDescription(id, original)
	local desc = _origGetSpellDescription(id)

	if original then
		return desc
	end

	return (phaseAuras[id] and phaseAuras[id].spellDesc) or (localAuras[id] and localAuras[id].spellDesc) or desc
end

local function rebuildTTwithDesc(desc)
	-- Insert a new line at the given position in GameTooltip.
	-- Move all lines from 'position' and below down by one, copying text and font objects (left and right).
	local tooltip = GameTooltip
	local numLines = tooltip:NumLines()
	local cleanSetSpellByID = Epsilon_AuraManager_OrigSpellTooltip.SetSpellByID
	local spellID = select(2, GameTooltip:GetSpell())
	local origOnTTSetSpell = GameTooltip:GetScript("OnTooltipSetSpell")
	GameTooltip:SetScript("OnTooltipSetSpell", nil)

	cleanSetSpellByID(tooltip, spellID)

	tooltip:AddLine(desc, 1, 0.81, 0, true)
	tooltip:AddLine(" ")
	local idTip = LibStub:GetLibrary("idTip")
	idTip:addLine(tooltip, spellID, "SpellID")

	-- Restore the original OnTooltipSetSpell script.
	if origOnTTSetSpell then
		tooltip:SetScript("OnTooltipSetSpell", origOnTTSetSpell)
	end

	tooltip:Show()
end

function SetSpellTooltip(id)
	local lines = GameTooltip:NumLines()
	-- check if the last 2 lines are from IdTip addon
	if string.find(_G["GameTooltipTextLeft" .. lines]:GetText(), "SpellID") or string.find(_G["GameTooltipTextLeft" .. lines]:GetText(), "IconID") then
		lines = lines - 2
	end

	local origDesc = GetSpellDescription(id, true)
	local desc = GetSpellDescription(id)
	if origDesc and origDesc ~= "" then
		_G["GameTooltipTextLeft" .. lines]:SetText(desc .. "\r\r")
	else
		rebuildTTwithDesc(desc)
	end

	-- Override name after desc, because it might be rebuilt by the desc function.
	GameTooltipTextLeft1:SetText(GetSpellName(id))

	GameTooltip:SetPadding(0, 0)
end

local _origGetActionTexture = GetActionTexture

function GetActionTexture(slot)
	local actionType, id, ActionSubtype = GetActionInfo(slot)

	if actionType == "spell" then
		return GetSpellTexture(id)
	end

	return _origGetActionTexture(slot)
end

local _origGetActionText = GetActionText


-------------------------------------------------------------------------
-- Hook function for suppressing BuffFrame auras from displaying.
--
local function CheckBuffFrame(buttonName, unit, filter, maxCount)
	local index = 1
	local realIndex = 1
	local auraTable

	table.wipe(auraMappingTable[filter])
	AuraUtil.ForEachAura(unit, filter, maxCount, function(...)
		auraMappingTable[filter][index] = realIndex
		local spellID = select(10, ...);
		local aura = phaseAuras[spellID];
		if (aura and aura.allowOverride and localAuras[spellID]) or (not aura) then
			aura = localAuras[spellID]
		end
		local shouldSuppress = (aura and not aura.visible)
		local buff = BuffFrame[buttonName][index];

		-- check if we're suppressing this aura, and if so, ignore it.
		if (spellID and not shouldSuppress) or C_Epsilon.IsDM or Epsilon_AuraManager.showHidden then
			local _, texture, count, debuffType, duration, expirationTime, _, _, _, _, _, _, _, _, timeMod = UnitAura(unit, auraMappingTable[filter][index], filter);
			texture = (aura and aura.icon) or texture
			AuraButton_Update(buttonName, index, filter, texture, count, debuffType, duration, expirationTime, timeMod);
			if shouldSuppress then
				buff:SetAlpha(0.6)
			end
			index = index + 1;
		end
		realIndex = realIndex + 1
		return index > maxCount;
	end);
	local count = index - 1;
	-- Hide remaining frames
	local buffArray = BuffFrame[buttonName];
	if buffArray then
		for i = index, #buffArray do
			auraMappingTable[filter][i] = i
			buffArray[i]:Hide();
		end
	end
	return count;
end

-------------------------------------------------------------------------
-- Hook function for suppressing TargetFrame auras from displaying.
--
local function CheckTargetBuffFrame(self, buttonName, unit, filter, maxCount)
	if not playerAuras[UnitName(unit)] and not phaseAuras then
		return
	end
	local numBuffs = 0;
	local index = 1;
	table.wipe(targetAuraMappingTable[filter])
	local auraArray = TargetFrame[buttonName]
	AuraUtil.ForEachAura(unit, filter, maxCount, function(...)
		targetAuraMappingTable[filter][numBuffs + 1] = index
		local spellID = select(10, ...);
		local aura = phaseAuras[spellID]

		playerAuras[UnitName('PLAYER')] = localAuras
		if (aura and aura.allowOverride and playerAuras[UnitName(unit)] and playerAuras[UnitName(unit)][spellID]) or (not aura and playerAuras[UnitName(unit)] and playerAuras[UnitName(unit)][spellID]) then
			aura = playerAuras[UnitName(unit)][spellID]
		end

		local shouldSuppress = (aura and not aura.visible)
		-- check if we're suppressing this aura, and if so, ignore it.
		if (spellID and not shouldSuppress) or C_Epsilon.IsDM then
			local icon = (aura and aura.icon) or select(2, UnitAura(unit, index, filter));
			numBuffs = numBuffs + 1;
			local frame = auraArray and auraArray[numBuffs];
			frame.Icon:SetTexture(icon);
			-- Handle cooldowns
			frame:Show();
		end
		index = index + 1
		return numBuffs >= maxCount;
	end);
	if auraArray then
		for i = numBuffs + 1, MAX_TARGET_BUFFS do
			local frame = auraArray[i];
			if (frame) then
				targetAuraMappingTable[filter][i] = i
				frame:Hide();
			else
				break;
			end
		end
	end
end

local function CheckPartyMemberBuffFrame(self)
	local numBuffs = 0;
	local numDebuffs = 0;
	PartyMemberBuffTooltip:SetID(self:GetID());

	local filter = (SHOW_CASTABLE_BUFFS == "1") and "HELPFUL|RAID" or "HELPFUL";
	local index = 1;
	local realIndex = 1

	AuraUtil.ForEachAura(self.unit, filter, MAX_PARTY_TOOLTIP_BUFFS, function(...)
		local spellID = select(10, ...);
		local aura = phaseAuras[spellID]

		local unit = self.unit
		playerAuras[UnitName('PLAYER')] = localAuras
		if (aura and aura.allowOverride and playerAuras[UnitName(unit)] and playerAuras[UnitName(unit)][spellID]) or (not aura and playerAuras[UnitName(unit)] and playerAuras[UnitName(unit)][spellID]) then
			aura = playerAuras[UnitName(unit)][spellID]
		end

		local shouldSuppress = (aura and not aura.visible)
		-- check if we're suppressing this aura, and if so, ignore it.
		if (spellID and not shouldSuppress) or C_Epsilon.IsDM then
			local icon = aura and aura.icon or select(2, UnitAura(self.unit, realIndex, filter));
			PartyMemberBuffTooltip.Buff[index].Icon:SetTexture(icon);
			PartyMemberBuffTooltip.Buff[index]:Show();
			index = index + 1;
			numBuffs = numBuffs + 1;
		end
		realIndex = realIndex + 1
		return index > MAX_PARTY_TOOLTIP_BUFFS
	end);

	for i = index, MAX_PARTY_TOOLTIP_BUFFS do
		PartyMemberBuffTooltip.Buff[i]:Hide();
	end

	filter = (SHOW_DISPELLABLE_DEBUFFS == "1") and "HARMFUL|RAID" or "HARMFUL";
	index = 1;
	AuraUtil.ForEachAura(self.unit, filter, MAX_PARTY_TOOLTIP_DEBUFFS, function(...)
		local debuffBorder = PartyMemberBuffTooltip.Debuff[index].Border;
		local partyDebuff = PartyMemberBuffTooltip.Debuff[index].Icon;
		local spellID = select(10, ...);
		local shouldSuppress = (EPSILON_CUSTOM_AURAS[spellID] and not EPSILON_CUSTOM_AURAS[spellID].visible)
		-- check if we're suppressing this aura, and if so, ignore it.
		if (spellID and not shouldSuppress) or C_Epsilon.IsDM then
			local _, icon = UnitAura(self.unit, index, filter);
			partyDebuff:SetTexture(icon);
			local color;
			if (debuffType) then
				color = DebuffTypeColor[debuffType];
			else
				color = DebuffTypeColor["none"];
			end
			debuffBorder:SetVertexColor(color.r, color.g, color.b);
			PartyMemberBuffTooltip.Debuff[index]:Show();
			numDebuffs = numDebuffs + 1;
			index = index + 1;
		end
		return index > MAX_PARTY_TOOLTIP_DEBUFFS;
	end);
	for i = index, MAX_PARTY_TOOLTIP_DEBUFFS do
		PartyMemberBuffTooltip.Debuff[i]:Hide();
	end

	-- Size the tooltip
	local rows = ceil(numBuffs / 8) + ceil(numDebuffs / 8);
	local columns = min(8, max(numBuffs, numDebuffs));
	if ((rows > 0) and (columns > 0)) then
		PartyMemberBuffTooltip:SetWidth((columns * 17) + 15);
		PartyMemberBuffTooltip:SetHeight((rows * 17) + 15);
		PartyMemberBuffTooltip:Show();
	else
		PartyMemberBuffTooltip:Hide();
	end
end

local function CheckRaidMemberBuffFrame(self)
	local unit = self.displayedUnit
	local filter = "HARMFUL";
	local numFrames = 0
	local index = 1
	local auraCount = self.maxDebuffs

	raidAuraMappingTable[unit] = { ["HARMFUL"] = {} }
	AuraUtil.ForEachAura(unit, filter, auraCount, function(...)
		local spellID = select(10, ...);
		local buffFrame = self.debuffFrames[numFrames + 1]
		raidAuraMappingTable[unit][filter][numFrames + 1] = index
		local aura = phaseAuras[spellID]

		playerAuras[UnitName('PLAYER')] = localAuras
		if (aura and aura.allowOverride and playerAuras[UnitName(unit)] and playerAuras[UnitName(unit)][spellID]) or (not aura and playerAuras[UnitName(unit)] and playerAuras[UnitName(unit)][spellID]) then
			aura = playerAuras[UnitName(unit)][spellID]
		end

		local shouldSuppress = (aura and not aura.visible)
		-- check if we're suppressing this aura, and if so, ignore it.
		if (spellID and not shouldSuppress) or C_Epsilon.IsDM then
			local icon = aura and aura.icon or select(2, UnitAura(unit, index, filter));
			buffFrame.icon:SetTexture(icon)
			numFrames = numFrames + 1;
		end
		index = index + 1
		return numFrames >= auraCount;
	end);

	for i = numFrames + 1, auraCount do
		local frame = self.debuffFrames[i]
		if frame then
			raidAuraMappingTable[unit][filter][i] = i
			frame:Hide();
		else
			break;
		end
	end
end

local function CheckCastingBarFrame(self, spellID, unit)
	name, _, texture = GetSpellInfo(spellID)

	if (self.Icon) then
		self.Icon:SetTexture(texture);
	end

	if (self.Text) then
		self.Text:SetText(name);
	end

	if _G["CastingBarFrame"].Text and unit == "player" then
		_G["CastingBarFrame"].Text:SetText(name)
	end
end

function Epsilon_AuraManager_SetSortFunc(func)
	sort_func = func
end

function Epsilon_AuraManager_Save(spell, id)
	local list = {}

	if Epsilon_AuraManager.isLocal then
		list = localAuras
	else
		list = phaseAuras
	end

	list[id] = spell

	if phaseAuras then
		SetPhaseData("CUSTOM_AURAS", phaseAuras);
	end


	BuffFrame_Update()
end

function EpsilonAuraManagerAuraEditor_DeleteBuff(index, isLocal)
	local auraList = Epsilon_AuraManager_GetAurasTable()
	local spellID = auraList[index].spellID
	if isLocal then
		localAuras[spellID] = nil
	else
		phaseAuras[spellID] = nil
		SetPhaseData("CUSTOM_AURAS", phaseAuras)
	end
	EpsilonAuraManagerAuraEditor:Hide()
	EpsilonAuraManagerFrame_Update()
end

function EpsilonAuraManagerAuraEditor_DeleteSpell(index, isLocal)
	local spellList = Epsilon_AuraManager_GetAurasTable()
	local spellID = spellList[index].spellID

	if isLocal then
		localAuras[spellID] = nil
	else
		phaseAuras[spellID] = nil
		Epsilon_AuraManager_SaveSpells()
	end
	EpsilonAuraManagerAuraEditor:Hide()
	EpsilonAuraManagerFrame_Update()
end

-------------------------------------------------------------------------
-- Returns a list of all customised auras.
--
-- @returns
--
-- EPSILON_CUSTOM_AURAS = {
--		["spellID"] = {
--			name = "Name";
--			icon = "IconPath";
--			desc = "Description";
--		};
-- };
--
function Epsilon_AuraManager_GetAurasList()
	EpsilonLib.PhaseAddonData.Get("CUSTOM_AURAS", loadCallbacks.listHelper(phaseAuras))
end

function Epsilon_AuraManager_WipePhaseData()
	phaseAuras = {}
	phaseAuras = {}
end

-------------------------------------------------------------------------
-- Returns an indexed table of all customised auras.
--
function Epsilon_AuraManager_GetAurasTable()
	local list = {}

	if Epsilon_AuraManager.isLocal then
		list = localAuras
	else
		list = phaseAuras
	end

	if not list then
		return {}
	end
	local auraTable = {}
	for spellID, spellInfo in pairs(list) do
		spellInfo.spellID = spellID;
		tinsert(auraTable, spellInfo);
	end
	if sort_func then table.sort(auraTable, sort_func) end
	return auraTable
end

function Epsilon_AuraManager_GetSelected()
	return Epsilon_AuraManager_GetAurasTable()[EpsilonAuraManagerFrame.selected]
end

-------------------------------------------------------------------------
-- Check if an aura is already in our list.
--
-- @returns
--
function Epsilon_AuraManager_IsAlreadyInAuraList(spellID)
	if not EPSILON_CUSTOM_AURAS then
		return
	end
	if EPSILON_CUSTOM_AURAS[spellID] then
		return true
	end
	return false
end

function Epsilon_AuraManager_GetMappedAura(targetType, index, filter)
	filter = filter or 'HELPFUL'

	if targetType == 'player' and not Epsilon_AuraManager.showHidden then
		index = auraMappingTable[filter][index]
	elseif targetType == 'target' then
		index = targetAuraMappingTable[filter][index]
	end

	return UnitAura(targetType:upper(), index, filter);
end

function EpsilonAuraManager_ShowHide()
	if not EpsilonAuraManagerFrame:IsVisible() then
		EpsilonAuraManagerFrame:Show()
	else
		EpsilonAuraManagerFrame:Hide()
	end
end

function Epsilon_AuraManager_ToggleShowHidden()
	Epsilon_AuraManager.showHidden = not Epsilon_AuraManager.showHidden
	BuffFrame_Update()
end

-------------------------------------------------------------------------------
-- Add the Epsilon Aura Manager icon to the Epsilon Addon Tray.
--
local function CreateMinimapIcon()
	LibStub("EpsiLauncher-1.0").API.new("Epsilon Aura Manager", function()
		EpsilonAuraManager_ShowHide()
	end, "Interface/AddOns/" .. addonName .. "/Texture/EpsilonAuraIcon", { "Click to open the Aura Manager." })
end

-------------------------------------------------------------------------------
-- Callbacks
--
loadCallbacks.listHelper = function(list)
	return function(text)
		text = DecompressForDownload(text);

		if text ~= nil then
			for id, value in pairs(text) do
				list[id] = value
			end
		end
		EpsilonAuraManagerFrame_Update();
		BuffFrame_Update();
	end
end

-------------------------------------------------------------------------------
-- Init
--

local function Epsilon_AuraManager_OnEvent(self, event, ...)
	if event == "SCENARIO_UPDATE" or event == "PLAYER_ENTERING_WORLD" then
		Epsilon_AuraManager_WipePhaseData()
		Epsilon_AuraManager_GetAurasList()
	elseif event == "UPDATE_MOUSEOVER_UNIT" then
		if UnitIsPlayer("mouseover") then
			local name = UnitName("mouseover")
			AceComm:SendCommMessage(prefix, "REQ_INFO", "WHISPER", name)
		end
	end
end

function Epsilon_AuraManager:OnInitialize()
	Epsilon_AuraManager.RealName = addonName

	if LibStub.libs["EpsiLauncher-1.0"] then
		CreateMinimapIcon()
	else
		C_Timer.After(1, function()
			CreateMinimapIcon()
		end)
	end

	self.db = LibStub("AceDB-3.0"):New("Epsilon_AuraManager", {
		char = {
			spells = {},
			auras = {},
		}
	})

	localAuras = self.db.char.spells
	localAuras = self.db.char.auras

	f:RegisterEvent("SCENARIO_UPDATE")
	f:RegisterEvent("PLAYER_ENTERING_WORLD")
	f:RegisterEvent("CHAT_MSG_ADDON")
	f:RegisterEvent("UPDATE_MOUSEOVER_UNIT")
	f:SetScript("OnEvent", Epsilon_AuraManager_OnEvent)
	-- For suppressing/hiding auras from the BuffFrame:
	hooksecurefunc("BuffFrame_Update", function()
		CheckBuffFrame("BuffButton", PlayerFrame.unit, "HELPFUL", BUFF_MAX_DISPLAY);
		CheckBuffFrame("DebuffButton", PlayerFrame.unit, "HARMFUL", DEBUFF_MAX_DISPLAY);

		BuffFrame_UpdateAllBuffAnchors();
	end)

	-- For suppressing/hiding auras from the TargetFrame:
	hooksecurefunc("TargetFrame_UpdateAuras", function(self)
		local maxBuffs = math.min(self.maxBuffs or MAX_TARGET_BUFFS, MAX_TARGET_BUFFS);
		local maxDebuffs = math.min(self.maxDebuffs or MAX_TARGET_DEBUFFS, MAX_TARGET_DEBUFFS);

		CheckTargetBuffFrame(self, "Buff", self.unit, "HELPFUL", BUFF_MAX_DISPLAY);
		CheckTargetBuffFrame(self, "Debuff", self.unit, "HARMFUL", DEBUFF_MAX_DISPLAY);

		BuffFrame_UpdateAllBuffAnchors();
	end)

	hooksecurefunc("PartyMemberBuffTooltip_Update", function(self)
		CheckPartyMemberBuffFrame(self)
	end)

	hooksecurefunc("CompactUnitFrame_UpdateAuras", function(frame)
		CheckRaidMemberBuffFrame(frame)
	end)

	-- [AURA TOOLTIP HOOKS]
	-- For replacing aura tooltips with our own:
	hooksecurefunc(GameTooltip, "SetUnitAura", ReplaceBuffText)
	hooksecurefunc(GameTooltip, "SetUnitBuff", ReplaceBuffText)
	hooksecurefunc(GameTooltip, "SetUnitDebuff", ReplaceDebuffText)
	hooksecurefunc(GameTooltip, "SetAction", function(_, actionID)
		local actionType, spellID, _ = GetActionInfo(actionID)
		if actionType == "spell" then
			return SetSpellTooltip(spellID)
		end
	end)
	hooksecurefunc(GameTooltip, "SetSpellBookItem", function(_, spellBookID, bookType)
		local spellType, spellID = GetSpellBookItemInfo(spellBookID, bookType)
		if spellType == "SPELL" then
			return SetSpellTooltip(spellID)
		end
	end)

	-- [AURA ICON HOOKS]
	-- For replacing aura icons in the BuffFrame:
	hooksecurefunc("AuraButton_Update", function(buttonName, index, filter, texture, count, debuffType, duration, expirationTime, timeMod)
		if not (EPSILON_CUSTOM_AURAS) then
			return
		end
		local buffArray = BuffFrame[buttonName];
		local buff = buffArray and BuffFrame[buttonName][index];
		local _, icon, _, _, _, _, _, _, _, spellID = UnitAura("player", auraMappingTable[filter][index] or index, filter);
		if spellID and EPSILON_CUSTOM_AURAS[spellID] and not C_Epsilon.IsDM then
			local data = EPSILON_CUSTOM_AURAS[spellID];
			buff.Icon:SetTexture(data.icon);
		end
	end);

	-- For replacing aura icons in the TargetFrame:
	hooksecurefunc("TargetFrame_UpdateAuras", function(self)
		if not (EPSILON_CUSTOM_AURAS) then
			return
		end
		local numBuffs = 0;
		local numDebuffs = 0;
		local maxBuffs = math.min(self.maxBuffs or MAX_TARGET_BUFFS, MAX_TARGET_BUFFS);
		local maxDebuffs = math.min(self.maxDebuffs or MAX_TARGET_DEBUFFS, MAX_TARGET_DEBUFFS);
		AuraUtil.ForEachAura(self.unit, "HELPFUL", maxBuffs, function(...)
			local _, icon, _, _, _, _, _, _, _, spellID = UnitAura("target", targetAuraMappingTable["HELPFUL"][numBuffs + 1] or numBuffs + 1, "HELPFUL");
			local shouldSuppress = (EPSILON_CUSTOM_AURAS[spellID] and not EPSILON_CUSTOM_AURAS[spellID].visible)
			if (icon) then
				numBuffs = numBuffs + 1;
				local frame = self.Buff and self.Buff[numBuffs];
				if spellID and EPSILON_CUSTOM_AURAS[spellID] and not shouldSuppress and not C_Epsilon.IsDM then
					local data = EPSILON_CUSTOM_AURAS[spellID];
					frame.Icon:SetTexture(data.icon);
				end
			end
		end);
		AuraUtil.ForEachAura(self.unit, "HARMFUL|INCLUDE_NAME_PLATE_ONLY", maxDebuffs, function(...)
			local _, icon, _, _, _, _, _, _, _, spellID = UnitAura("target", targetAuraMappingTable["HARMFUL"][numBuffs + 1] or numBuffs + 1, "HARMFUL");
			local shouldSuppress = (EPSILON_CUSTOM_AURAS[spellID] and not EPSILON_CUSTOM_AURAS[spellID].visible)
			if (icon) then
				numDebuffs = numDebuffs + 1;
				local frame = self.Debuff and self.Debuff[numDebuffs];
				if spellID and not shouldSuppress and not C_Epsilon.IsDM then
					local data = EPSILON_CUSTOM_AURAS[spellID];
					frame.Icon:SetTexture(data.icon);
				end
			end
		end);
	end);

	-- For replacing spell name in castingbar
	hooksecurefunc("CastingBarFrame_OnEvent", function(castingbar, event, unit)
		if event == "UNIT_SPELLCAST_START" or event == "UNIT_SPELLCAST_CHANNEL_START" then
			local spellID
			if event == "UNIT_SPELLCAST_START" then
				if unit == "target" then
					spellID = select(9, UnitCastingInfo(unit))
				else
					_, _, _, _, _, _, spellID = UnitCastingInfo(unit)
				end
			else
				_, _, _, _, _, _, _, spellID = UnitChannelInfo(unit);
			end

			CheckCastingBarFrame(castingbar, spellID, unit)
		end
	end)

	Epsilon_AuraManager.isLocal = true
	C_ChatInfo.RegisterAddonMessagePrefix(prefix)

	AceComm:RegisterComm(prefix, function(prefix, message, channel, sender)
		if sender == UnitName('player') then
			-- we're talking to ourselves here
			return;
		end
		if message == "REQ_INFO" then
			local table = {
				auras = localAuras,
				spells = localAuras
			};
			local data = compressForAddonMsg(table)
			AceComm:SendCommMessage(prefix, data, "WHISPER", sender)
		else
			local table = decompressForAddonMsg(message)
			playerAuras[sender] = table.auras
		end
	end)
end
