----------------------------------------------------------------------------------
--- Total RP 3: KuiNameplates
--- Main
---	---------------------------------------------------------------------------
---	Copyright 2017 Renaud "Ellypse" Parize <ellypse@totalrp3.info> @EllypseCelwe
---
---	Licensed under the Apache License, Version 2.0 (the "License");
---	you may not use this file except in compliance with the License.
---	You may obtain a copy of the License at
---
---		http://www.apache.org/licenses/LICENSE-2.0
---
---	Unless required by applicable law or agreed to in writing, software
---	distributed under the License is distributed on an "AS IS" BASIS,
---	WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
---	See the License for the specific language governing permissions and
---	limitations under the License.
----------------------------------------------------------------------------------

local TRPKN = select(2, ...);

local function onModuleStart()

	local addon = KuiNameplates;
	local mod = addon:NewPlugin('Total RP 3: KuiNameplates', 200);
	local nameTextMod = addon:GetPlugin("NameText");
	local guildTextMod = addon:GetPlugin("GuildText");
	local loc = TRP3_API.loc;


	local getConfigValue = TRP3_API.configuration.getValue;

	local isPlayerIC = TRP3_API.dashboard.isPlayerIC;
	local UnitIsPlayer = UnitIsPlayer;
	local UnitIsOtherPlayersPet = UnitIsOtherPlayersPet;

	---HideKuiNameplate
	---@param nameplate Frame
	function TRPKN.HideKuiNameplate(nameplate)
		nameplate.state.no_name = true
		nameplate:UpdateNameText()
		nameplate:UpdateLevelText()
		nameplate:UpdateFrameSize()
		nameplate.NameText:Hide()
		nameplate.GuildText:Hide()
	end

	---ShowKuiNameplate
	---@param nameplate Frame
	function TRPKN.ShowKuiNameplate(nameplate)
		addon.layout:Show(nameplate)
	end


	---
	-- Update the nameplate with informations we get from the Total RP 3 API
	-- @param nameplate
	--
	function mod:UpdateRPName(nameplate)

		-- TRP3_API.Ellyb.Tables.inspect(nameplate)
		if not nameplate.unit -- If we don't have a unit
			or nameplate.state.personal --  or this is the personal nameplate
			or not nameplate.state.friend -- or this is an enemy
		then
			return -- we can stop here
		end;

		nameTextMod:Show(nameplate);
		guildTextMod:Show(nameplate);
		TRPKN.ShowKuiNameplate(nameplate);

		-- Only continue if the customization has not be disabled manually and check if we are in character if the option is checked
		if not getConfigValue(TRPKN.CONFIG.ENABLE_NAMEPLATES_CUSTOMIZATION) or (getConfigValue(TRPKN.CONFIG.DISPLAY_NAMEPLATES_ONLY_IN_CHARACTER) and not isPlayerIC()) then
			return
		end;

		-- TRP3's customizations are overridden when Kui Nameplates' option to show player title is enabled, so we will disable it manually.
		-- I don't like that either, but the complexity of getting all of this to work is too much for me right now, I'll go back on this later.
		if KuiNameplatesCore.config and type(KuiNameplatesCore.config.GetActiveProfile) == "function" then
			local kuiNameplatesCurrentConfigProfile = KuiNameplatesCore.config:GetActiveProfile();
			if type(kuiNameplatesCurrentConfigProfile) == "table" then
				if kuiNameplatesCurrentConfigProfile["title_text_players"] == true then
					TRP3_API.utils.message.displayMessage(loc.KNP_MODULE .. ": " .. loc.KNP_TITLES_WARNING)
					kuiNameplatesCurrentConfigProfile["title_text_players"] = false;
					KuiNameplatesCore:SetLocals();
				end
			end
		end

		if getConfigValue(TRPKN.CONFIG.HIDE_NON_ROLEPLAY) and (UnitIsPlayer(nameplate.unit) or UnitIsOtherPlayersPet(nameplate.unit)) then
			TRPKN.HideKuiNameplate(nameplate);
		end

		-- Check if the unit is a player)
		if UnitIsPlayer(nameplate.unit) then
			TRPKN.modifyPlayerNameplate(nameplate);
		else
			TRPKN.modifyPetNameplate(nameplate);
		end


	end

	function TRPKN.refreshAllNameplates()
		for _, nameplate in addon:Frames() do
			if nameplate:IsShown() then
				mod:UpdateRPName(nameplate);
			end
		end
	end

	mod.RefreshAllNameplates = TRPKN.refreshAllNameplates;

	function mod:Initialise()
		self:RegisterMessage('Create', 'RefreshAllNameplates');
		self:RegisterMessage('Show', 'UpdateRPName');
		self:RegisterMessage('GainedTarget', 'UpdateRPName');
		self:RegisterMessage('LostTarget', 'UpdateRPName');
	end

	-- We listen to the register data update event fired by Total RP 3 when we receive new data
	-- about a player.
	-- It's not super efficient, but we will refresh all RP names on all nameplates for now
	TRP3_API.events.listenToEvent(TRP3_API.events.REGISTER_DATA_UPDATED, TRPKN.refreshAllNameplates);

	C_Timer.After(2, TRPKN.refreshAllNameplates)

	TRPKN.initCompanionNameplates();
	TRPKN.initPlayerNameplates();
	TRPKN.initConfig();
end


TRP3_API.module.registerModule({
	name = "Kui|cff9966ffNameplates|r module",
	description = "Add Total RP 3 customizations to Kui|cff9966ffNameplates|r.",
	version = 1.4,
	id = "trp3_kuinameplates",
	onStart = onModuleStart,
	minVersion = 66,
});
