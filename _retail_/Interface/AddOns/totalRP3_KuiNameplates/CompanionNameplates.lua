----------------------------------------------------------------------------------
--- Total RP 3: KuiNameplates
--- Companion nameplates
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

function TRPKN.initCompanionNameplates()

	local colorHexaToFloats = TRP3_API.utils.color.hexaToFloat;
	local getConfigValue = TRP3_API.configuration.getValue;
	local getCompanionFullID = TRP3_API.ui.misc.getCompanionFullID;
	local getCompanionProfile = TRP3_API.companions.register.getCompanionProfile;
	local TYPE_PET = TRP3_API.ui.misc.TYPE_PET;
	local UnitIsOtherPlayersPet = UnitIsOtherPlayersPet;
	local crop = TRP3_API.utils.str.crop;

	local MAX_TITLE_SIZE = 40;

	---getCompanionData
	---@param companionUnitID string
	---@return bool, string, string
	local function getCompanionData(companionUnitID)
		-- Try to retrieve the profile of the pet
		local companionFullID = getCompanionFullID(companionUnitID, TYPE_PET);
		local companionProfile = getCompanionProfile(companionFullID);

		local companionHasProfile = companionProfile ~= nil;
		local name, title, color;

		if companionHasProfile then
			local info = companionProfile.data;

			name = info.NA;
			title = info.TI;
			color = info.NH;
		end

		return companionHasProfile, name, title, color;
	end

	function TRPKN.modifyPetNameplate(nameplate)
		-- Check if the unit is controlled by a player (it is a pet)
		if getConfigValue(TRPKN.CONFIG.PET_NAMES) and UnitIsOtherPlayersPet(nameplate.unit) then
			local companionHasProfile, name, title, color = getCompanionData(nameplate.unit);

			-- If we do have a profile we can start filling the nameplate with the data
			if companionHasProfile then

				if name then
					nameplate.state.name = name;
					nameplate.NameText:SetText(nameplate.state.name);
				end

				if title and getConfigValue(TRPKN.CONFIG.SHOW_TITLES) then
					nameplate.state.guild_text = "<" .. crop(title, MAX_TITLE_SIZE) .. ">";
					nameplate.GuildText:SetText(nameplate.state.guild_text);
				end

				if getConfigValue(TRPKN.CONFIG.HIDE_NON_ROLEPLAY) then
					TRPKN.ShowKuiNameplate(nameplate);
				end

				if color and getConfigValue(TRPKN.CONFIG.USE_CUSTOM_COLOR) then
					local r, g, b = colorHexaToFloats(color);
					nameplate.NameText:SetTextColor(r, g, b);
				end
			end
		end
	end
end
