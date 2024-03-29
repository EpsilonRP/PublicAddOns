----------------------------------------------------------------------------------
--- Total RP 3: Kui Nameplates
--- Locales
---    ---------------------------------------------------------------------------
---    Copyright 2017 Renaud "Ellypse" Parize <ellypse@totalrp3.info> @EllypseCelwe
---
---    Licensed under the Apache License, Version 2.0 (the "License");
---    you may not use this file except in compliance with the License.
---    You may obtain a copy of the License at
---
---        http://www.apache.org/licenses/LICENSE-2.0
---
---    Unless required by applicable law or agreed to in writing, software
---    distributed under the License is distributed on an "AS IS" BASIS,
---    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
---    See the License for the specific language governing permissions and
---    limitations under the License.
----------------------------------------------------------------------------------

-- Imports
local Localization = TRP3_API.loc;

---@type TRP3_API This is to trick IntelliJ IDEA to get auto-completion for locale keys inside TRP3_API.loc
local TRP3_API = {}
TRP3_API.loc = {
	KNP_MODULE = "Kui |cff9966ffNameplates|r module",
	KNP_ENABLE_CUSTOMIZATION = "Enable nameplates customizations",
	KNP_ONLY_IC = "Only when in character",
	KNP_HIDE_NON_RP = "Hide non-roleplay nameplates",
	KNP_HIDE_NON_RP_TT = [[Hide nameplates of players who do not have a roleplay profile, so you only see the names of people with a RP profile.

Note: If you have enabled the option ot only enable nameplate customisation when you are In Character, you can quickly switch the Out Of Character to see everyone's name!]],
	KNP_CUSTOM_COLORS = "Use custom colors",
	KNP_INCREASE_CONTRAST = "Increase color contrast",
	KNP_CUSTOM_TITLES = "Show custom titles",
	KNP_CUSTOM_TITLES_TT = "Replace the guild text by the RP title of the player. Be aware that custom titles may be really long and take a lot of space.",
	KNP_PET_NAMES = "Pet names",
	KNP_SHOW_OOC_INDICATOR = "Show OOC indicator",
	KNP_ACTIVELY_QUERY_FOR_PROFILE = "Actively query players profiles",
	KNP_ACTIVELY_QUERY_FOR_PROFILE_TT = [[When this option is enabled and the add-on sees a nameplate of a player without an RP profile, it will actively query this player for their profile, like if you had put your cursor over them.

This means that RP names will appear automatically without the need to move your cursor over the players to request their profile.

|cffff0000Caution: This option potentially uses more add-on bandwidth and may cause lags. If you have trouble with profiles loading slowly, try to disable this option.|r]],
	KNP_TITLES_WARNING = "Disabled display of player's titles in Kui Nameplates' settings as it conflicts with this module's customization."
}

Localization:GetDefaultLocale():AddTexts(TRP3_API.loc)

local localeContent = {}

Localization:GetLocale("enUS"):AddTexts(localeContent);

localeContent = {
	KNP_MODULE = "Module pour Kui |cff9966ffNameplates|r",
	KNP_ENABLE_CUSTOMIZATION = "Activer les modifications des barres d'infos",
	KNP_ONLY_IC = "Seulement quand je suis \"Dans le personnage\"",
	KNP_HIDE_NON_RP = "Cacher les noms des joueurs non RP",
	KNP_HIDE_NON_RP_TT = [[Cacher les barres d'infos des joueurs n'ayant pas de profil roleplay, pour ne voir plus que les noms des joueurs avec un profile RP.

Note: Si vous avez activé l'option de modifier les barres d'infos uniquement lorsque vous êtes "dans le personnage", vous pouvez passer de "dans le personnage" à "hors du personnage" pour afficher toutes les barres d'infos à nouveau!]],
	KNP_CUSTOM_COLORS = "Utiliser les couleurs personnalisées",
	KNP_INCREASE_CONTRAST = "Améliorer le contraste des couleurs",
	KNP_CUSTOM_TITLES = "Afficher les titres personnalisés",
	KNP_CUSTOM_TITLES_TT = [[Remplace la ligne du texte de guilde par le titre RP du joueur. Attention, certains titres peuvent être très long et prendre beaucoup de place]],
	KNP_PET_NAMES = "Nom des familiers",
	KNP_SHOW_OOC_INDICATOR = "Afficher l'indicateur HRP",
    KNP_ACTIVELY_QUERY_FOR_PROFILE = "Récupérer les profils automatiquement",
    KNP_ACTIVELY_QUERY_FOR_PROFILE_TT = [[Quand cette option est activée et que l'add-on rencontre la barre d'un joueur sans profil, une requête sera automatiquement envoyée pour récupérer les informations sur ce joueurs, comme si vous aviez passé votre souris sur lui.

Cela signifie que les nom RP apparaîtront automatiquement, sans avoir besoin de passer votre curseur sur les personnages.

|cffff0000Attention: Cette option peut potentiellement utiliser beaucoup de bande passante dédidée aux add-ons. Si vous rencontrez des soucis de lag ou de profils qui chargent lentement, essayez de désactiver cette option.|r]],
	KNP_TITLES_WARNING = "L'affichage des titres des joueurs dans Kui Nameplates a été désactivé car il entre en conflit avec des fonctionnalités de ce module. "

}

Localization:GetLocale("frFR"):AddTexts(localeContent);