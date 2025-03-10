----------------------------------------------------------------------------------
--- Total RP 3
--- Pets/mounts managements
--- ---------------------------------------------------------------------------
--- Copyright 2014 Sylvain Cossement (telkostrasz@telkostrasz.be)
--- Copyright 2014-2019 Morgane "Ellypse" Parize <ellypse@totalrp3.info> @EllypseCelwe
---
--- Licensed under the Apache License, Version 2.0 (the "License");
--- you may not use this file except in compliance with the License.
--- You may obtain a copy of the License at
---
--- 	http://www.apache.org/licenses/LICENSE-2.0
---
--- Unless required by applicable law or agreed to in writing, software
--- distributed under the License is distributed on an "AS IS" BASIS,
--- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
--- See the License for the specific language governing permissions and
--- limitations under the License.
----------------------------------------------------------------------------------

TRP3_API.companions = {
	player = {},
	register = {}
}

-- imports
local Globals, Utils, Events = TRP3_API.globals, TRP3_API.utils, TRP3_API.events;
local loc = TRP3_API.loc;
local log = Utils.log.log;
local pairs, assert, tostring, wipe, tinsert, strtrim, tonumber = pairs, assert, tostring, wipe, tinsert, strtrim, tonumber;
local registerMenu = TRP3_API.navigation.menu.registerMenu;
local setPage = TRP3_API.navigation.page.setPage;
local displayMessage = Utils.message.displayMessage;
local EMPTY = Globals.empty;
local tcopy = Utils.table.copy;
local TYPE_MOUNT = TRP3_API.ui.misc.TYPE_MOUNT;
local Compression = AddOn_TotalRP3.Compression;
local TRP3_Enums = AddOn_TotalRP3.Enums;
local getPlayerCurrentProfile = TRP3_API.profile.getPlayerCurrentProfile;

local function GetMountIDs()
	if C_MountJournal then
		return C_MountJournal.GetMountIDs();
	else
		return TRP3_API.utils.resources.GetMountIDs();
	end
end

local function GetMountInfoByID(mountID)
	if C_MountJournal then
		return C_MountJournal.GetMountInfoByID(mountID);
	else
		return TRP3_API.utils.resources.GetMountInfoByID(mountID);
	end
end

TRP3_API.navigation.menu.id.COMPANIONS_MAIN = "main_20_companions";

function TRP3_API.companions.getCompanionNameFromSpellID(spellID)
	local name = GetSpellInfo(tonumber(spellID));
	return name or spellID;
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Player's companions : API
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local playerCompanions;
local PROFILE_DEFAULT_ICON = "INV_Box_PetCarrier_01";
TRP3_API.companions.PROFILE_DEFAULT_ICON = PROFILE_DEFAULT_ICON;
local DEFAULT_PROFILE = {
	data = {
		IC = PROFILE_DEFAULT_ICON,
		v = 1,
	},
	PE = {
		v = 1
	},
	links = {}
};

local playerProfileAssociation = {};

local function getCompanionProfileID(companionID)
	return playerProfileAssociation[companionID];
end
TRP3_API.companions.player.getCompanionProfileID = getCompanionProfileID;

local function getCompanionProfile(companionID)
	if playerProfileAssociation[companionID] then
		return playerCompanions[playerProfileAssociation[companionID]];
	end
end
TRP3_API.companions.player.getCompanionProfile = getCompanionProfile;

local function getCompanionProfileByID(profileID)
	if playerCompanions[profileID] then
		return playerCompanions[profileID];
	end
end
TRP3_API.companions.player.getCompanionProfileByID = getCompanionProfileByID;

local function parsePlayerProfiles(profiles)
	for profileID, profile in pairs(profiles) do
		for companionID, _ in pairs(profile.links or EMPTY) do
			playerProfileAssociation[companionID] = profileID;
		end
	end
end

local function boundPlayerCompanion(companionID, profileID, targetType)
	assert(playerCompanions[profileID], "Unknown profile: " .. tostring(profileID));
	if not playerCompanions[profileID].links then
		playerCompanions[profileID].links = {};
	end
	playerCompanions[profileID].links[companionID] = targetType;
	-- Unbound from others
	for id, profile in pairs(playerCompanions) do
		if id ~= profileID then
			profile.links[companionID] = nil;
		end
	end
	playerProfileAssociation[companionID] = profileID;
	if targetType == TYPE_MOUNT then
		Events.fireEvent(Events.REGISTER_DATA_UPDATED, Globals.player_id, profileID);
	else
		Events.fireEvent(Events.REGISTER_DATA_UPDATED, Globals.player_id .. "_" .. companionID, profileID);
	end
	log(("%s bounded to profile %s"):format(companionID, profileID));
end
TRP3_API.companions.player.boundPlayerCompanion = boundPlayerCompanion;



local function unboundPlayerCompanion(companionID, targetType)
	local profileID = playerProfileAssociation[companionID];
	assert(profileID, "Cannot find any bound for companionID " .. tostring(companionID));
	playerProfileAssociation[companionID] = nil;
	if profileID and playerCompanions[profileID] and playerCompanions[profileID].links then
		playerCompanions[profileID].links[companionID] = nil;
	end
	if targetType == TYPE_MOUNT then
		Events.fireEvent(Events.REGISTER_DATA_UPDATED, Globals.player_id, profileID);
	else
		Events.fireEvent(Events.REGISTER_DATA_UPDATED, Globals.player_id .. "_" .. companionID, profileID);
	end
	log(("%s unbounded"):format(companionID));
end
TRP3_API.companions.player.unboundPlayerCompanion = unboundPlayerCompanion;

-- Check if the profileName is not already used
local function isProfileNameAvailable(profileName)
	for _, profile in pairs(playerCompanions) do
		if profile.profileName == profileName then
			return false;
		end
	end
	return true;
end
TRP3_API.companions.player.isProfileNameAvailable = isProfileNameAvailable;

-- Duplicate an existing profile
local function duplicateProfile(duplicatedProfile, profileName)
	assert(duplicatedProfile, "Nil profile");
	assert(isProfileNameAvailable(profileName), "Unavailable profile name: " .. tostring(profileName));
	local profileID = Utils.str.id();
	playerCompanions[profileID] = {};
	Utils.table.copy(playerCompanions[profileID], duplicatedProfile);
	playerCompanions[profileID].profileName = profileName;
	displayMessage(loc.PR_PROFILE_CREATED:format(Utils.str.color("g") .. profileName .. "|r"));
	return profileID;
end
TRP3_API.companions.player.duplicateProfile = duplicateProfile;

-- Creating a new profile using PR_DEFAULT_PROFILE as a template
local function createProfile(profileName)
	local profileID = duplicateProfile(DEFAULT_PROFILE, profileName);
	playerCompanions[profileID].data.NA = profileName;
	return profileID;
end
TRP3_API.companions.player.createProfile = createProfile;

-- Edit a profile name
local function editProfile(profileID, newName)
	assert(playerCompanions[profileID], "Unknown profile: " .. tostring(profileID));
	assert(isProfileNameAvailable(newName), "Unavailable profile name: " .. tostring(newName));
	playerCompanions[profileID]["profileName"] = newName;
end
TRP3_API.companions.player.editProfile = editProfile;

-- Delete a profile
-- If the deleted profile is the currently selected one, assign the default profile
local function deleteProfile(profileID, silently)
	assert(playerCompanions[profileID], "Unknown profile: " .. tostring(profileID));
	local profileName = playerCompanions[profileID]["profileName"];
	for companionID, _ in pairs(playerCompanions[profileID].links or EMPTY) do
		unboundPlayerCompanion(companionID);
	end
	wipe(playerCompanions[profileID]);
	playerCompanions[profileID] = nil;
	if not silently then
		displayMessage(loc.PR_PROFILE_DELETED:format(Utils.str.color("g") .. profileName .. "|r"));
		Events.fireEvent(Events.REGISTER_PROFILE_DELETED, profileID);
	end
end
TRP3_API.companions.player.deleteProfile = deleteProfile;

local registerCompanions;

function TRP3_API.companions.player.getProfiles()
	return playerCompanions;
end

local function getCurrentMountSpellID()
	if IsMounted() then
		for _, id in pairs(GetMountIDs()) do
			local _, spellID, _, active = GetMountInfoByID(id);
			if active then
				return spellID;
			end
		end
	end
end
TRP3_API.companions.player.getCurrentMountSpellID = getCurrentMountSpellID;

local function getCurrentMountProfile()
	local currentMountSpellID = getCurrentMountSpellID();
	if currentMountSpellID then
		local currentMountID = tostring(currentMountSpellID);
		if playerProfileAssociation[currentMountID] then
			return playerCompanions[playerProfileAssociation[currentMountID]], playerProfileAssociation[currentMountID];
		end
	end
end
TRP3_API.companions.player.getCurrentMountProfile = getCurrentMountProfile;

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Exchange
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local function getCompanionVersionNumbers(profileID)
	local profile = playerCompanions[profileID];
	if profile and profile.data then
		return profile.data.v, profile.PE.v;
	end
end

local function getPossessedVersionNumbers(profilleID)
	local profile = playerCompanions[profilleID];
	if profile and profile.data then
		return profile.data.v, profile.PE.v;
	end
end

local function UpdateSummonedPetGUID(speciesID)
	RegisterCVar("totalRP3_SummonedPetID", "");
	SetCVar("totalRP3_SummonedPetID", speciesID);
end

local function UpdateSummonedPetGUIDFromCast(unitToken, castGUID)
	-- For Classic clients we need to be creative with how we know what
	-- non-combat pet the player has summoned. None of the companion API
	-- exists, nor does the COMPANION_UPDATE event.
	--
	-- Our approach is to monitor for successful spellcasts whose spell IDs
	-- are associated with that of a known companion pet. We assume that the
	-- last successful cast will represent the current battle pet.
	--
	-- Note that we can't tell when a companion pet is dismissed, so our query
	-- data will always contain the data for the last-successful cast even if
	-- that cast dismissed the pet. Realistically this should be fine since
	-- if it's dismissed other players can't see the unit to request the data
	-- anyway.
	--
	-- For persistence across UI reloads we store the summoned pet data in a
	-- temporary CVar. When logging out pets aren't resummoned in Classic, so
	-- we don't need to worry about the case where a player switches
	-- characters.

	if unitToken ~= "player" then
		return;
	end

	local spellID = tonumber((select(6, string.split("-", castGUID, 7))));
	local speciesID = TRP3_API.utils.resources.GetPetSpeciesBySpellID(spellID);

	if speciesID then
		UpdateSummonedPetGUID(speciesID);
	end
end

local function ResetSummonedPetGUIDFromLogin(isInitialLogin)
	if isInitialLogin then
		UpdateSummonedPetGUID(nil);
	end
end

local function GetSummonedPetGUID()
	if C_PetJournal then
		return C_PetJournal.GetSummonedPetGUID();
	else
		return GetCVar("totalRP3_SummonedPetID");
	end
end

local function GetPetInfoByPetID(petID)
	if C_PetJournal then
		return C_PetJournal.GetPetInfoByPetID(petID);
	else
		return TRP3_API.utils.resources.GetPetInfoByPetID(petID);
	end
end

function TRP3_API.companions.player.getCurrentMountQueryLine()
	local currentMountSpellID = getCurrentMountSpellID();
	if currentMountSpellID then
		local queryLine = tostring(currentMountSpellID);
		local summonedMountProfile, summonedMountProfileID = getCurrentMountProfile();
		if summonedMountProfile then
			return queryLine .. "_" .. summonedMountProfileID, getCompanionVersionNumbers(summonedMountProfileID);
		end
		return queryLine;
	end
end

function TRP3_API.companions.player.getCurrentBattlePetQueryLine()
	local summonedPetGUID = GetSummonedPetGUID();
	if summonedPetGUID then
		local _, customName, _, _, _, _, _, name = GetPetInfoByPetID(summonedPetGUID);
		local queryLine = customName or name;
		if getCompanionProfileID(customName or name) then
			local profileID = getCompanionProfileID(customName or name);
			return queryLine .. "_" .. profileID, getCompanionVersionNumbers(profileID);
		end
		return queryLine;
	end
end

function TRP3_API.companions.player.getCurrentPetQueryLine()
	local summonedPet = UnitName("pet");
	if summonedPet then
		local queryLine = summonedPet;
		if getCompanionProfileID(summonedPet) then
			local profileID = getCompanionProfileID(summonedPet);
			return queryLine .. "_" .. profileID, getCompanionVersionNumbers(profileID);
		end
		return queryLine;
	end
end

function TRP3_API.companions.player.getCurrentPossessedQueryLine()
	local possessedNPC = UnitName("pet");
	if possessedNPC then
		local queryLine = possessedNPC;
		if getPossessedProfileID(possessedNPC) then
			local profileID = getPossessedProfileID(possessedNPC);
			return queryLine .. "_" .. profileID, getPossessedVersionNumbers(possessedNPC);
		end
	end
end

function TRP3_API.companions.player.getCurrentSecondaryPetQueryLine()
	-- Secondary pets are those summoned through the Beast Mastery talent
	-- "Animal Companion". This talent works by summoning a second pet from
	-- the first stable slot. The summoned pet currently has no unit token,
	-- but does carry a "Pet" type GUID and works with the
	-- UnitIsOwnerOrControllerOfUnit API when queried against the player.

	local FIRST_STABLE_SLOT = 6; -- Index 1 through 5 are for Call Pet slots.

	local _, petName = GetStablePetInfo(FIRST_STABLE_SLOT);
	if not petName or petName == UNKNOWNOBJECT then
		return nil, nil, nil;
	end

	local profileID = getCompanionProfileID(petName);
	if not profileID then
		return nil, nil, nil;
	end

	local queryLine = petName .. "_" .. profileID;
	return queryLine, getCompanionVersionNumbers(profileID);
end

function TRP3_API.companions.player.getCompanionData(profileID, v)
	local profile = playerCompanions[profileID];
	local data = {};
	if profile and profile.data then
		if v == "1" then
			tcopy(data, profile.data);
		elseif v == "2" then
			tcopy(data, profile.PE);
		end
	end
	return data;
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Register companions (other players companions)
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local registerProfileAssociation = {};

local function parseRegisterProfiles(profiles)
	for profileID, profile in pairs(profiles) do
		for fullID, _ in pairs(profile.links or EMPTY) do
			registerProfileAssociation[fullID] = profileID;
		end
	end
end

local function registerCreateProfile(profileID)
	registerCompanions[profileID] = {
		data = {
			v = 0,
		},
		PE = {
			v = 0
		},
		links = {}
	};
	log(("Create companion register profile %s"):format(profileID));
end
TRP3_API.companions.register.registerCreateProfile = registerCreateProfile;

function TRP3_API.companions.register.boundAndCheckCompanion(queryLine, ownerID, _, v1, v2)
	local companionID, profileID, companionFullID;
	if queryLine:find("_") then
		companionID = queryLine:sub(1, queryLine:find('_') - 1);
		profileID = queryLine:sub(queryLine:find('_') + 1);
	else
		companionID = queryLine;
	end

	companionFullID = ownerID .. "_" .. companionID;
	local isMount = companionID:match("^%d+$");
	if companionID and companionID:len() > 0 then
		if profileID then
			-- Check profile exists
			if not registerCompanions[profileID] then
				registerCreateProfile(profileID);
			end
			local profile = registerCompanions[profileID];

			-- Check profile link
			registerProfileAssociation[companionFullID] = profileID;
			if not profile.links[companionFullID] then
				-- Unbound from others
				for _, otherProfile in pairs(registerCompanions) do
					otherProfile.links[companionFullID] = nil;
				end
				profile.links[companionFullID] = 1;
				log(("Bound %s to profile %s"):format(companionFullID, profileID));
				if isMount then
					Events.fireEvent(Events.REGISTER_DATA_UPDATED, ownerID, nil);
				else
					Events.fireEvent(Events.REGISTER_DATA_UPDATED, companionFullID, profileID);
				end
			end

			return profileID, profile.data.v ~= v1, profile.PE.v ~= v2;
		else
			local old = registerProfileAssociation[companionFullID];
			registerProfileAssociation[companionFullID] = nil;
			if old and registerCompanions[old] then
				log(("Unbound %s"):format(companionFullID));
				registerCompanions[old].links[companionFullID] = nil;
				if isMount then
					Events.fireEvent(Events.REGISTER_DATA_UPDATED, ownerID, nil);
				else
					Events.fireEvent(Events.REGISTER_DATA_UPDATED, companionFullID, nil);
				end
			end
		end
	end
end

function TRP3_API.companions.register.saveInformation(profileID, v, data)
	local profile = registerCompanions[profileID];
	assert(profile, "Profile does not exists: " .. tostring(profileID));
	if v == "1" then
		wipe(profile.data);
		tcopy(profile.data, data);
		profile.data.read = not profile.data.TX or strtrim(profile.data.TX):len() == 0;
		Events.fireEvent(Events.REGISTER_DATA_UPDATED, nil, profileID, "characteristics");
	elseif v == "2" then
		wipe(profile.PE);
		tcopy(profile.PE, data);
		Events.fireEvent(Events.REGISTER_DATA_UPDATED, nil, profileID, "misc");
	end
end

function TRP3_API.companions.register.setProfileData(profileID, profile)
	registerCompanions[profileID] = profile;
	Events.fireEvent(Events.REGISTER_DATA_UPDATED, nil, profileID, "characteristics");
	Events.fireEvent(Events.REGISTER_DATA_UPDATED, nil, profileID, "misc");
end

function TRP3_API.companions.register.setProfile(npcFullID, profileID)
	registerProfileAssociation[npcFullID] = profileID;
end

local function boundNPC(npcID, profileID, _)
	assert(playerCompanions[profileID], "Unknown profile: " .. tostring(profileID));
	local profile = playerCompanions[profileID]

	local phaseData = {};
	phaseData['id'] = profileID;
	phaseData['profile'] = profile;
	if getPlayerCurrentProfile().notes ~= nil then
		phaseData['notes'] = getPlayerCurrentProfile().notes[profileID];		
	else
		phaseData['notes'] = ''
	end


	local key = 'TOTALRP_PROFILE_' .. npcID;
	local str = Utils.serial.serialize(phaseData);
	str = Compression.compress(str, true);

	local strLength = #str
	local fullNpcID = C_Epsilon.GetPhaseId() .. "_" .. npcID;
	if strLength > 3500 then
		print('Whoops - your profile is a bit too big');
		return
	end

	registerProfileAssociation[fullNpcID] = profileID;
	playerProfileAssociation[fullNpcID] = profileID;


	if not playerCompanions[profileID].links then
		playerCompanions[profileID].links = {};
	end
	playerCompanions[profileID].links[fullNpcID] = TRP3_Enums.UNIT_TYPE.NPC;

	Events.fireEvent(Events.REGISTER_DATA_UPDATED, fullNpcID, profileID);

	--C_Epsilon.SetPhaseAddonData(key, str);
	EpsilonLib.PhaseAddonData.Set(key, str)
end
TRP3_API.companions.player.boundNPC = boundNPC;

local function unboundNPC(npcID, _)
	local profileID = registerProfileAssociation[C_Epsilon.GetPhaseId() .. "_" .. npcID];

	registerProfileAssociation[C_Epsilon.GetPhaseId() .. "_" .. npcID] = nil;
	playerCompanions[C_Epsilon.GetPhaseId() .. "_" .. npcID] = nil;

	if profileID then
		local key = 'TOTALRP_PROFILE_' .. npcID;
		Events.fireEvent(Events.REGISTER_DATA_UPDATED, C_Epsilon.GetPhaseId() .. "_" .. npcID, profileID);

		C_Epsilon.SetPhaseAddonData(key, '');
	end
end
TRP3_API.companions.player.unboundNPC = unboundNPC;



function TRP3_API.companions.register.getCompanionProfile(companionFullID)
	if registerProfileAssociation[companionFullID] and registerCompanions[registerProfileAssociation[companionFullID]] then
		return registerCompanions[registerProfileAssociation[companionFullID]];
	end
end

function TRP3_API.companions.register.getCompanionProfileID(npcFullID)
	if registerProfileAssociation[npcFullID] then
		return registerProfileAssociation[npcFullID];
	end
end

function TRP3_API.companions.register.companionHasProfile(companionFullID)
	return registerProfileAssociation[companionFullID];
end

function TRP3_API.companions.register.getProfiles()
	return registerCompanions;
end

function TRP3_API.companions.register.getAssociationsForProfile(profileID)
	local list = {};
	for companionFullID, id in pairs(registerProfileAssociation) do
		if id == profileID then
			tinsert(list, companionFullID);
		end
	end
	return list;
end

function TRP3_API.companions.register.deleteProfile(profileID, silently)
	assert(registerCompanions[profileID], "Unknown profile ID: " .. tostring(profileID));
	wipe(registerCompanions[profileID]);
	registerCompanions[profileID] = nil;
	for key, value in pairs(registerProfileAssociation) do
		if value == profileID then
			registerProfileAssociation[key] = nil;
		end
	end
	if not silently then
		Events.fireEvent(Events.REGISTER_DATA_UPDATED, nil, profileID, nil);
		Events.fireEvent(Events.REGISTER_PROFILE_DELETED, profileID);
	end
end

function TRP3_API.companions.register.getUnitMount(ownerID, unitType)
	local buffIndex = 1;
	local spellBuffID = select(10, UnitAura(unitType, buffIndex));
	while (spellBuffID) do
		spellBuffID = select(10, UnitAura(unitType, buffIndex));
		local companionFullID = ownerID .. "_" .. tostring(spellBuffID);
		if registerProfileAssociation[companionFullID] then
			return companionFullID, registerProfileAssociation[companionFullID], tostring(spellBuffID);
		end
		buffIndex = buffIndex + 1;
	end
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Init
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

TRP3_API.events.listenToEvent(TRP3_API.events.WORKFLOW_ON_LOAD, function()
	if not TRP3_Companions then
		TRP3_Companions = {};
	end

	if not TRP3_Companions.player then
		TRP3_Companions.player = {};
	end
	playerCompanions = TRP3_Companions.player;
	parsePlayerProfiles(playerCompanions);

	if not TRP3_Register.companion then
		TRP3_Register.companion = {};
	end
	registerCompanions = TRP3_Register.companion;
	parseRegisterProfiles(registerCompanions);

	if not C_PetJournal then
		-- Classic support for companion pets.
		Utils.event.registerHandler("UNIT_SPELLCAST_SUCCEEDED", UpdateSummonedPetGUIDFromCast);
		Utils.event.registerHandler("PLAYER_ENTERING_WORLD", ResetSummonedPetGUIDFromLogin);
	end

	registerMenu({
		id = TRP3_API.navigation.menu.id.COMPANIONS_MAIN,
		text = loc.REG_COMPANIONS,
		onSelected = function() setPage(TRP3_API.navigation.page.id.COMPANIONS_PROFILES) end,
		closeable = true,
	});
end);
