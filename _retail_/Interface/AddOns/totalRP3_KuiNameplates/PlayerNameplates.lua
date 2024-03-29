----------------------------------------------------------------------------------
--- Total RP 3: KuiNameplates
--- Player nameplates
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

function TRPKN.initPlayerNameplates()

	local getUnitID = TRP3_API.utils.str.getUnitID;
	local unitIDIsKnown = TRP3_API.register.isUnitIDKnown;
	local hasProfile = TRP3_API.register.hasProfile;
	local getConfigValue = TRP3_API.configuration.getValue;
	local crop = TRP3_API.utils.str.crop;
	local loc = TRP3_API.loc;

	local profilesRequestByUnitForThisSession = {}

	local CONFIG_COLOR_CONTRAST = "increase_color_contrast";

	local OOC_TEXT_INDICATOR = TRP3_API.Ellyb.ColorManager.RED("[" .. loc.CM_OOC .. "] ");
	local OOC_ICON_INDICATOR = TRP3_API.Ellyb.Icon([[Interface\COMMON\Indicator-Red]], 15);

	local MAX_TITLE_SIZE = 40;

	function TRPKN.modifyPlayerNameplate(nameplate)
		local characterID = getUnitID(nameplate.unit);

		-- If we didn't get a proper unit ID or we don't have any data for this unit ID we can stop here
		if not characterID then
			return
		end

		local player = AddOn_TotalRP3.Player.CreateFromCharacterID(characterID);

		-- TODO Switch to newer API when available
		-- if not player:IsKnown() or not player:HasAnRPProfile() then
		if not unitIDIsKnown(characterID) or not hasProfile(characterID) then
			-- We don't know this unit we will try to ask for their profile
			if getConfigValue(TRPKN.CONFIG.ACTIVE_QUERY) and not profilesRequestByUnitForThisSession[characterID] then
				-- TODO Switch to newer API when available
				-- player:SendProfileUpdateRequest()
				TRP3_API.r.sendQuery(characterID);
				profilesRequestByUnitForThisSession[characterID] = true
			end

			return;
		end

		--{{{ Player name
		local name = player:GetRoleplayingName();
		if getConfigValue(TRPKN.CONFIG.SHOW_OOC_INDICATOR) and not player:IsInCharacter() then
			if getConfigValue(TRPKN.CONFIG.PREFERRED_OOC_ICON) == "TEXT" then
				name = OOC_TEXT_INDICATOR .. " " .. name;
			else
				name = tostring(OOC_ICON_INDICATOR).. " " .. name
			end
		end
		nameplate.state.name = name;
		nameplate.NameText:SetText(nameplate.state.name);
		--}}}

		--{{{ Titles
		if getConfigValue(TRPKN.CONFIG.SHOW_TITLES) then
			if not nameplate.state.old_guild_text then
				nameplate.state.old_guild_text = nameplate.state.guild_text;
			end

			-- TODO Switch to newer API when available
			-- local title = player:GetFullTitle();
			local profile = player:GetProfile()
			local title;
			if profile and profile.characteristics then
				title = profile.characteristics.FT
			end
			if title then
				nameplate.state.guild_text = "<" .. crop(title, MAX_TITLE_SIZE) .. ">";
			else
				nameplate.state.guild_text = "";
			end
			nameplate.GuildText:SetText(nameplate.state.guild_text)
		end
		--}}}

		if getConfigValue(TRPKN.CONFIG.HIDE_NON_ROLEPLAY) then
			TRPKN.ShowKuiNameplate(nameplate);
		end

		--{{{ Custom color
		if getConfigValue(TRPKN.CONFIG.USE_CUSTOM_COLOR) then
			local customColor = player:GetCustomColorForDisplay();
			if customColor then
				nameplate.NameText:SetTextColor(customColor:GetRGB())
			end
		end
		--}}}
	end

	TRP3_API.events.listenToEvent(TRP3_API.events.WORKFLOW_ON_LOADED, function()
		TRP3_API.configuration.registerHandler(CONFIG_COLOR_CONTRAST, TRPKN.refreshAllNameplates);
	end)
end
