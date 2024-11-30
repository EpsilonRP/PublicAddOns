----------------------------------------------------------------------------------
--- Total RP 3
--- Localization system
---
--- This new system is based on a meta-table.
--- The goal here is to have IDE auto-completion by directly using the table and
--- accessing its indexes in the code, but actually having the meta table call
--- the localization functions on runtime to get the localized version of the text.
--- ---------------------------------------------------------------------------
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

---@type TRP3_API
local _, TRP3_API = ...;
local Ellyb = Ellyb(_);

-- WoW imports
local pairs = pairs;
local tinsert = table.insert;

local IS_FRENCH_LOCALE = GetLocale() == "frFR";

-- Bindings locale
BINDING_HEADER_TRP3 = "Total RP 3";

-- Complete locale declaration
TRP3_API.loc = {

	--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
	-- GENERAL
	--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

	GEN_WELCOME_MESSAGE = "Thank you for using Total RP 3 (v %s) ! Have fun !",
	GEN_VERSION = "Version: %s (Build %s)",

	--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
	-- REGISTER
	--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
	REG_PLAYER = "Character",
	REG_PLAYER_CHANGE_CONFIRM = "You may have unsaved data changes.\nDo you want to change page anyway ?\n|cffff9900Any changes will be lost.",
	REG_PLAYER_CARACT = "Characteristics",
	REG_PLAYER_NAMESTITLES = "Names and titles",
	REG_PLAYER_CHARACTERISTICS = "Characteristics",
	REG_PLAYER_REGISTER = "Directory information",
	REG_PLAYER_ICON = "Character's icon",
	REG_PLAYER_ICON_TT = "Select a graphic representation for your character.",
	REG_PLAYER_TITLE = "Title",
	REG_PLAYER_TITLE_TT = "Your character's title is the title by which your character is usually called. Avoid long titles, as for those you should use the Full title attribute below.\n\nExample of |c0000ff00appropriate titles |r:\n|c0000ff00- Countess,\n- Marquis,\n- Magus,\n- Lord,\n- etc.\n|rExample of |cffff0000inappropriate titles|r:\n|cffff0000- Countess of the North Marshes,\n- Magus of the Stormwind Tower,\n- Diplomat for the Draenei Government,\n- etc.",
	REG_PLAYER_FIRSTNAME = "First name",
	REG_PLAYER_FIRSTNAME_TT = "This is your character's first name. This is a mandatory field, so if you don't specify a name, the default character's name (|cffffff00%s|r) will be used.\n\nYou can use a |c0000ff00nickname |r!",
	REG_PLAYER_LASTNAME = "Last name",
	REG_PLAYER_LASTNAME_TT = "This is your character's family name.",
	REG_PLAYER_HERE = "Set position",
	REG_PLAYER_HERE_TT = "|cffffff00Click|r: Set to your current position",
	REG_PLAYER_HERE_HOME_TT = "|cffffff00Click|r: Use your current coordinates as your house position.\n|cffffff00Right-click|r: Discard your house position.",
	REG_PLAYER_HERE_HOME_PRE_TT = "Current house map coordinates:\n|cff00ff00%s|r.",
	REG_PLAYER_RESIDENCE_SHOW = "Residence coordinates",
	REG_PLAYER_RESIDENCE_SHOW_TT = "|cff00ff00%s\n\n|rClick to show on map",
	REG_PLAYER_COLOR_CLASS = "Class color",
	REG_PLAYER_COLOR_CLASS_TT = "This will also determine the name color.\n\n",
	REG_PLAYER_COLOR_TT = "|cffffff00Click:|r Select a color\n|cffffff00Right-click:|r Discard color\n|cffffff00Shift-Click:|r Use the default color picker",
	REG_PLAYER_COLOR_ALWAYS_DEFAULT_TT = "|cffffff00Click:|r Select a color\n|cffffff00Right-click:|r Discard color",
	REG_PLAYER_FULLTITLE = "Full title",
	REG_PLAYER_FULLTITLE_TT = "Here you can write down your character's full title. It can either be a longer version of the Title or another title entirely.\n\nHowever, you may want to avoid repetitions, in case there's no additional info to mention.",
	REG_PLAYER_RACE = "Race",
	REG_PLAYER_RACE_TT = "Here goes your character's race. It doesn't have to be restricted to playable races. There are many Warcraft races that can assume common shapes ...",
	REG_PLAYER_BKG = "Background layout",
	REG_PLAYER_BKG_TT = "This represents the graphical background to use for your Characteristics layout.",
	REG_PLAYER_CLASS = "Class",
	REG_PLAYER_CLASS_TT = "This is your character's custom class.\n\n|cff00ff00For instance :|r\nKnight, Pyrotechnist, Necromancer, Elite shooter, Arcanist ...",
	REG_PLAYER_AGE = "Age",
	REG_PLAYER_AGE_TT = "Here you can indicate how old your character is.\n\nThere are several ways to do this:|c0000ff00\n- Either use years,\n- Or an adjective (Young, Mature, Adult, Venerable, etc.).",
	REG_PLAYER_EYE = "Eye color",
	REG_PLAYER_EYE_TT = "Here you can indicate the color of your character's eyes.\n\nKeep in mind that, even if your character's face is constantly hidden, that might still be worth mentioning, just in case.",
	REG_PLAYER_HEIGHT = "Height",
	REG_PLAYER_HEIGHT_TT = "This is your character's height.\nThere are several ways to do this:|c0000ff00\n- A precise number: 170 cm, 6'5\" ...\n- A qualificative: Tall, short ...",
	REG_PLAYER_WEIGHT = "Body shape",
	REG_PLAYER_WEIGHT_TT = "This is your character's body shape.\nFor instance they could be |c0000ff00slim, fat or muscular...|r Or they could simply be regular !",
	REG_PLAYER_BIRTHPLACE = "Birthplace",
	REG_PLAYER_BIRTHPLACE_TT = "Here you can indicate the birthplace of your character. This can either be a region, a zone, or even a continent. It's for you to decide how accurate you want to be.\n\n|c00ffff00You can use the button to the right to easily set your current location as Birthplace.",
	REG_PLAYER_RESIDENCE = "Residence",
	REG_PLAYER_RESIDENCE_TT = "Here you can indicate where your character normally lives. This could be their personal address (their home) or a place they can crash.\nNote that if your character is a wanderer or even homeless, you will need to change the information accordingly.\n\n|c00ffff00You can use the button to the right to easily set your current location as Residence.",
	REG_PLAYER_MSP_MOTTO = "Motto",
	REG_PLAYER_MSP_HOUSE = "House name",
	REG_PLAYER_MSP_NICK = "Nickname",
	REG_PLAYER_TRP2_TRAITS = "Physiognomy",
	REG_PLAYER_TRP2_PIERCING = "Piercings",
	REG_PLAYER_TRP2_TATTOO = "Tattoos",
	REG_PLAYER_PSYCHO = "Personality traits",
	REG_PLAYER_ADD_NEW = "Create new",
	REG_PLAYER_HISTORY = "History",
	REG_PLAYER_MORE_INFO = "Additional information",
	REG_PLAYER_PHYSICAL = "Physical Description",
	REG_PLAYER_NO_CHAR = "No characteristics",
	REG_PLAYER_SHOWPSYCHO = "Show personality frame",
	REG_PLAYER_SHOWPSYCHO_TT = "Check if you want to use the personality description.\n\nIf you don't want to indicate your character's personality this way, keep this box unchecked and the personality frame will remain totally hidden.",
	REG_PLAYER_PSYCHO_ADD = "Add a personality trait",
	REG_PLAYER_PSYCHO_POINT = "Add a point",
	REG_PLAYER_PSYCHO_MORE = "Add a point to \"%s\"",
	REG_PLAYER_PSYCHO_ATTIBUTENAME_TT = "Attribute name",
	REG_PLAYER_PSYCHO_RIGHTICON_TT = "Set the right attribute icon.",
	REG_PLAYER_PSYCHO_LEFTICON_TT = "Set the left attribute icon.",
	REG_PLAYER_PSYCHO_SOCIAL = "Social traits",
	REG_PLAYER_PSYCHO_PERSONAL = "Personal traits",
	REG_PLAYER_PSYCHO_CHAOTIC = "Chaotic";
	REG_PLAYER_PSYCHO_Loyal = "Lawful";
	REG_PLAYER_PSYCHO_Chaste = "Chaste";
	REG_PLAYER_PSYCHO_Luxurieux = "Lustful";
	REG_PLAYER_PSYCHO_Indulgent = "Forgiving";
	REG_PLAYER_PSYCHO_Rencunier = "Vindictive";
	REG_PLAYER_PSYCHO_Genereux = "Altruistic";
	REG_PLAYER_PSYCHO_Egoiste = "Selfish";
	REG_PLAYER_PSYCHO_Sincere = "Truthful";
	REG_PLAYER_PSYCHO_Trompeur = "Deceitful";
	REG_PLAYER_PSYCHO_Misericordieux = "Gentle ";
	REG_PLAYER_PSYCHO_Cruel = "Brutal";
	REG_PLAYER_PSYCHO_Pieux = "Superstitious";
	REG_PLAYER_PSYCHO_Pragmatique = "Renegade";
	REG_PLAYER_PSYCHO_Conciliant = "Paragon";
	REG_PLAYER_PSYCHO_Rationnel = "Rational";
	REG_PLAYER_PSYCHO_Reflechi = "Cautious";
	REG_PLAYER_PSYCHO_Impulsif = "Impulsive";
	REG_PLAYER_PSYCHO_Acete = "Ascetic";
	REG_PLAYER_PSYCHO_Bonvivant = "Bon vivant";
	REG_PLAYER_PSYCHO_Valeureux = "Valorous";
	REG_PLAYER_PSYCHO_Couard = "Spineless";
	REG_PLAYER_PSYCHO_CUSTOM = "Custom trait",
	REG_PLAYER_PSYCHO_CREATENEW = "Create a trait",
	REG_PLAYER_PSYCHO_CUSTOMCOLOR = "Select attribute color",
	REG_PLAYER_PSYCHO_CUSTOMCOLOR_LEFT_TT = "Select a color used by the bar for the left attribute.\n\n|cffffff00Click:|r Select a color\n|cffffff00Right-click:|r Discard color\n|cffffff00Shift-Click:|r Use the default color picker",
	REG_PLAYER_PSYCHO_CUSTOMCOLOR_RIGHT_TT = "Select a color used by the bar for the right attribute.\n\n|cffffff00Click:|r Select a color\n|cffffff00Right-click:|r Discard color\n|cffffff00Shift-Click:|r Use the default color picker",
	REG_PLAYER_LEFTTRAIT = "Left attribute",
	REG_PLAYER_RIGHTTRAIT = "Right attribute",
	REG_DELETE_WARNING = "Are you sure you want to delete %s's profile?\n",
	REG_IGNORE_TOAST = "Character ignored",
	REG_CODE_INSERTION_WARNING = [[
|TInterface\AddOns\totalRP3\resources\policegar.tga:50:50|t
Wait a minute!

We found that you have manually inserted invalid codes inside your Total RP 3 profile.
This behavior is not supported at all and we strongly discourage anyone from doing it.
It can lead to instabilities and bugs inside the add-on, data corruption/loss of profiles and it also creates incompatibility issues with other add-ons (such as MRP).

The codes you have inserted in your profile have been removed to prevent you from breaking the add-on.]],
	REG_PLAYER_IGNORE = "Ignore linked characters (%s)",
	REG_PLAYER_IGNORE_WARNING = "Do you want to ignore those characters ?\n\n|cffff9900%s\n\n|rYou can optionally enter the reason below. This is a personal note that will serve as reminder.",
	REG_PLAYER_SHOWMISC = "Show miscellaneous frame",
	REG_PLAYER_SHOWMISC_TT = "Check if you want to show custom fields for your character.\n\nIf you don't want to show custom fields, keep this box unchecked and the miscellaneous frame will remain totally hidden.",
	REG_PLAYER_MISC_ADD = "Add an additional field",
	REG_PLAYER_ABOUT = "About",
	REG_PLAYER_ABOUTS = "About %s",
	REG_PLAYER_ABOUT_NOMUSIC = "|cffff9900No theme",
	REG_PLAYER_ABOUT_UNMUSIC = "|cffff9900Unknown theme",
	REG_PLAYER_ABOUT_MUSIC_SELECT = "Select character theme",
	REG_PLAYER_ABOUT_MUSIC_REMOVE = "Unselect theme",
	REG_PLAYER_ABOUT_MUSIC_LISTEN = "Play theme",
	REG_PLAYER_ABOUT_MUSIC_STOP = "Stop theme",
	REG_PLAYER_ABOUT_MUSIC_SELECT2 = "Select theme",
	REG_PLAYER_ABOUT_T1_YOURTEXT = "Your text here",
	REG_PLAYER_ABOUT_HEADER = "Title tag",
	REG_PLAYER_ABOUT_ADD_FRAME = "Add a frame",
	REG_PLAYER_ABOUT_REMOVE_FRAME = "Remove this frame",
	REG_PLAYER_ABOUT_P = "Paragraph tag",
	REG_PLAYER_ABOUT_TAGS = "Formatting tools",
	REG_PLAYER_ABOUT_SOME = "Some text ...",
	REG_PLAYER_ABOUT_EMPTY = "No description",
	REG_PLAYER_STYLE_RPSTYLE_SHORT = "RP style",
	REG_PLAYER_STYLE_RPSTYLE = "Roleplay style",
	REG_PLAYER_STYLE_HIDE = "Do not show",
	REG_PLAYER_STYLE_WOWXP = "World of Warcraft experience",
	REG_PLAYER_STYLE_FREQ = "In-character frequence",
	REG_PLAYER_STYLE_FREQ_1 = "Full-time, no OOC",
	REG_PLAYER_STYLE_FREQ_2 = "Most of the time",
	REG_PLAYER_STYLE_FREQ_3 = "Mid-time",
	REG_PLAYER_STYLE_FREQ_4 = "Casual",
	REG_PLAYER_STYLE_FREQ_5 = "Full-time OOC, not a RP character",
	REG_PLAYER_STYLE_PERMI = "With player permission",
	REG_PLAYER_STYLE_ASSIST = "Roleplay assistance",
	REG_PLAYER_STYLE_INJURY = "Accept character injury",
	REG_PLAYER_STYLE_DEATH = "Accept character death",
	REG_PLAYER_STYLE_ROMANCE = "Accept character romance",
	REG_PLAYER_STYLE_BATTLE = "Roleplay battle resolution",
	REG_PLAYER_STYLE_BATTLE_1 = "World of Warcraft PvP",
	REG_PLAYER_STYLE_BATTLE_2 = "TRP roll battle",
	REG_PLAYER_STYLE_BATTLE_3 = "/roll battle",
	REG_PLAYER_STYLE_BATTLE_4 = "Emote battle",
	REG_PLAYER_STYLE_EMPTY = "No roleplay attribute shared",
	REG_PLAYER_STYLE_GUILD = "Guild membership",
	REG_PLAYER_STYLE_GUILD_IC = "IC membership",
	REG_PLAYER_STYLE_GUILD_OOC = "OOC membership",
	REG_PLAYER_ALERT_HEAVY_SMALL = "|cffff0000The total size of your profile is quite big.\n|cffff9900You should reduce it.",
	CO_GENERAL_HEAVY = "Heavy profile alert",
	CO_GENERAL_HEAVY_TT = "Get an alert when your profile total size exceed a reasonable value.",
	REG_PLAYER_PEEK = "Miscellaneous",
	REG_PLAYER_CURRENT = "Currently",
	REG_PLAYER_CURRENTOOC = "Currently (OOC)",
    REG_PLAYER_CURRENT_OOC = "This is OOC information",
	REG_COMPANIONS_SHORTDESCRIPTION = "Short description",
	REG_PLAYER_GLANCE = "At first glance",
	REG_PLAYER_GLANCE_USE = "Activate this slot",
	REG_PLAYER_GLANCE_TITLE = "Attribute name",
	REG_PLAYER_GLANCE_UNUSED = "Unused slot",
	REG_PLAYER_GLANCE_CONFIG = "|cff00ff00\"At first glance\"|r is a set of slots you can use to define important information about this character.\n\nYou can use these actions on the slots:\n|cffffff00Click:|r configure slot\n|cffffff00Double-click:|r toggle slot activation\n|cffffff00Right-click:|r slot presets\n|cffffff00Drag & drop:|r reorder slots",
	REG_PLAYER_GLANCE_EDITOR = "Glance editor : Slot %s",
	REG_PLAYER_GLANCE_BAR_TARGET = "\"At first glance\" presets",
	REG_PLAYER_GLANCE_BAR_LOAD_SAVE = "Group presets",
	REG_PLAYER_GLANCE_BAR_SAVE = "Save group as a preset",
	REG_PLAYER_GLANCE_BAR_LOAD = "Group preset",
	REG_PLAYER_GLANCE_BAR_EMPTY = "The preset name can't be empty.",
	REG_PLAYER_GLANCE_BAR_NAME = "Please enter the preset name.\n\n|cff00ff00Note: If the name is already used by another group preset, this other group will be replaced.",
	REG_PLAYER_GLANCE_BAR_SAVED = "Group preset |cff00ff00%s|r has been created.",
	REG_PLAYER_GLANCE_BAR_DELETED = "Group preset |cffff9900%s|r deleted.",
	REG_PLAYER_GLANCE_PRESET = "Load a preset",
	REG_PLAYER_GLANCE_PRESET_SELECT = "Select a preset",
	REG_PLAYER_GLANCE_PRESET_SAVE = "Save information as a preset",
	REG_PLAYER_GLANCE_PRESET_SAVE_SMALL = "Save as a preset",
	REG_PLAYER_GLANCE_PRESET_CATEGORY = "Preset category",
	REG_PLAYER_GLANCE_PRESET_NAME = "Preset name",
	REG_PLAYER_GLANCE_PRESET_CREATE = "Create preset",
	REG_PLAYER_GLANCE_PRESET_REMOVE = "Removed preset |cff00ff00%s|r.";
	REG_PLAYER_GLANCE_PRESET_ADD = "Created preset |cff00ff00%s|r.";
	REG_PLAYER_GLANCE_PRESET_ALERT1 = "You must enter a preset category.",
	REG_PLAYER_GLANCE_PRESET_GET_CAT = "%s\n\nPlease enter the category name for this preset.",
	REG_PLAYER_GLANCE_MENU_COPY = "Copy slot",
	REG_PLAYER_GLANCE_MENU_PASTE = "Paste slot: %s",
	REG_PLAYER_TUTO_ABOUT_COMMON = [[|cff00ff00Character theme:|r
You can choose a |cffffff00theme|r for your character. Think of it as an |cffffff00ambiance music for reading your character description|r.

|cff00ff00Background:|r
This is a |cffffff00background texture|r for your character description.

|cff00ff00Template:|r
The chosen template defines |cffffff00the general layout and writing possibilities|r for your description.
|cffff9900Only the selected template is visible by others, so you don't have to fill them all.|r
Once a template is selected, you can open this tutorial again to have more help about each template.]],
	REG_PLAYER_TUTO_ABOUT_T1 = [[This template allows you to |cff00ff00freely structure your description|r.

The description doesn't have to be limited to your character's |cffff9900physical description|r. Feel free to indicate parts from their |cffff9900background|r or details about their |cffff9900personality|r.

With this template you can use the formatting tools to access several layout parameters like |cffffff00texts sizes, colors and alignments|r.
These tools also allow you to insert |cffffff00images, icons or links to external web sites|r.]],
	REG_PLAYER_TUTO_ABOUT_T2 = [[This template is more structured and consist of |cff00ff00a list of independent frames|r.

Each frame is caracterized by an |cffffff00icon, a background and a text|r. Note that you can use some text tags in these frames, like the color and the icon text tags.

The description doesn't have to be limited to your character's |cffff9900physical description|r. Feel free to indicate parts from their |cffff9900background|r or details about their |cffff9900personality|r.]],
	REG_PLAYER_TUTO_ABOUT_T3 = [[This template is cut in 3 sections: |cff00ff00Physical description, personality and history|r.

You don't have to fill all the frames, |cffff9900if you leave an empty frame it won't be shown on your description|r.

Each frame is caracterized by an |cffffff00icon, a background and a text|r. Note that you can use some text tags in these frames, like the color and the icon text tags.]],
	REG_PLAYER_TUTO_ABOUT_MISC_1 = [[This section provides you |cffffff005 slots|r with which you can describe |cff00ff00the most important pieces of information about your character|r.

These slots will be visible on the |cffffff00"At first glance bar"|r when someone selects your character.

|cff00ff00Hint: You can drag & drop slots to reorder them.|r
It also works on the |cffffff00"At first glance" bar|r!]],
	REG_PLAYER_TUTO_ABOUT_MISC_3 = [[This section contains |cffffff00a list of flags|r to answer a lot of |cffffff00common questions people could ask about you, your character and the way you want to play him/her|r.]],
	REG_RELATION = "Relationship",
	REG_RELATION_BUTTON_TT = "Relation: %s\n|cff00ff00%s\n\n|cffffff00Click to display possible actions",
	REG_RELATION_UNFRIENDLY = "Unfriendly",
	REG_RELATION_NONE = "None",
	REG_RELATION_NEUTRAL = "Neutral",
	REG_RELATION_BUSINESS = "Business",
	REG_RELATION_FRIEND = "Friendly",
	REG_RELATION_LOVE = "Love",
	REG_RELATION_FAMILY = "Family",
	REG_RELATION_UNFRIENDLY_TT = "%s clearly doesn't like %s.",
	REG_RELATION_NONE_TT = "%s doesn't know %s.",
	REG_RELATION_NEUTRAL_TT = "%s doesn't feel anything particular toward %s.",
	REG_RELATION_BUSINESS_TT = "%s and %s are in a business relationship.",
	REG_RELATION_FRIEND_TT = "%s considers %s a friend.",
	REG_RELATION_LOVE_TT = "%s is in love with %s !",
	REG_RELATION_FAMILY_TT = "%s shares blood ties with %s.",
	REG_RELATION_TARGET = "|cffffff00Click: |rChange relation",
	REG_TIME = "Time last seen",
	REG_REGISTER = "Directory",
	REG_REGISTER_CHAR_LIST = "Characters list",
	REG_TRIAL_ACCOUNT = "Trial Account",
	REG_TT_GUILD_IC = "IC member",
	REG_TT_GUILD_OOC = "OOC member",
	REG_TT_LEVEL = "Level %s %s",
	REG_TT_REALM = "Realm: |cffff9900%s",
	REG_TT_GUILD = "%s of |cffff9900%s",
	REG_TT_TARGET = "Target: |cffff9900%s",
	REG_TT_ZONE = "Zone",
	REG_TT_NOTIF = "Unread description",
	REG_TT_IGNORED = "< Character is ignored >",
	REG_TT_IGNORED_OWNER = "< Owner is ignored >",
	REG_LIST_CHAR_TITLE = "Character list",
	REG_LIST_CHAR_SEL = "Selected character",
	REG_LIST_CHAR_TT = "Click to show page",
	REG_LIST_CHAR_TT_RELATION = "Relation:\n|cff00ff00%s",
	REG_LIST_CHAR_TT_CHAR = "Bound WoW character(s):",
	REG_LIST_CHAR_TT_CHAR_NO = "Not bound to any character",
	REG_LIST_CHAR_TT_DATE = "Last seen date: |cff00ff00%s|r\nLast seen location: |cff00ff00%s|r",
	REG_LIST_CHAR_TT_GLANCE = "At first glance",
	REG_LIST_CHAR_TT_NEW_ABOUT = "Unread description",
	REG_LIST_CHAR_TT_IGNORE = "Ignored character(s)",
	REG_LIST_CHAR_FILTER = "Characters: %s / %s",
	REG_LIST_CHAR_EMPTY = "No character",
	REG_LIST_CHAR_EMPTY2 = "No character matches your selection",
	REG_LIST_CHAR_IGNORED = "Ignored",
	REG_LIST_CHAR_NAME_COPY = "Copy character name",
	REG_LIST_IGNORE_TITLE = "Ignored list",
	REG_LIST_IGNORE_EMPTY = "No ignored character",
	REG_LIST_IGNORE_TT = "Reason:\n|cff00ff00%s\n\n|cffffff00Click to remove from ignore list",
	REG_LIST_PETS_FILTER = "Companions: %s / %s",
	REG_LIST_PETS_TITLE = "Companion list",
	REG_LIST_PETS_EMPTY = "No companion",
	REG_LIST_PETS_EMPTY2 = "No companion matches your selection",
	REG_LIST_PETS_TOOLTIP = "Has been seen on",
	REG_LIST_PETS_TOOLTIP2 = "Has been seen with",
	REG_LIST_PET_NAME = "Companion's name",
	REG_LIST_PET_TYPE = "Companion's type",
	REG_LIST_PET_MASTER = "Master's name",
	REG_LIST_FILTERS = "Filters",
	REG_LIST_FILTERS_TT = "|cffffff00Click:|r Apply filters\n|cffffff00Right-Click:|r Clear filters",
	REG_LIST_REALMONLY = "This realm only",
	REG_LIST_NOTESONLY = "Has notes only",
	REG_LIST_GUILD = "Character's guild",
	REG_LIST_NAME = "Character's name",
	REG_LIST_FLAGS = "Flags",
	REG_LIST_ADDON = "Profile type",
	REG_LIST_ACTIONS_PURGE = "Purge register",
	REG_LIST_ACTIONS_PURGE_ALL = "Remove all profiles",
	REG_LIST_ACTIONS_PURGE_ALL_COMP_C = "This purge will remove all companions from the directory.\n\n|cff00ff00%s companions.",
	REG_LIST_ACTIONS_PURGE_ALL_C = "This purge will remove all profiles and linked characters from the directory.\n\n|cff00ff00%s characters.",
	REG_LIST_ACTIONS_PURGE_TIME = "Profiles not seen for 1 month",
	REG_LIST_ACTIONS_PURGE_TIME_C = "This purge will remove all profiles that have not been seen for a month.\n\n|cff00ff00%s",
	REG_LIST_ACTIONS_PURGE_UNLINKED = "Profiles not bound to a character",
	REG_LIST_ACTIONS_PURGE_UNLINKED_C = "This purge will remove all profiles that are not bound to a WoW character.\n\n|cff00ff00%s",
	REG_LIST_ACTIONS_PURGE_IGNORE = "Profiles from ignored characters",
	REG_LIST_ACTIONS_PURGE_IGNORE_C = "This purge will remove all profiles linked to an ignored WoW character.\n\n|cff00ff00%s",
	REG_LIST_ACTIONS_PURGE_EMPTY = "No profile to purge.",
	REG_LIST_ACTIONS_PURGE_COUNT = "%s profiles will be removed.",
	REG_LIST_ACTIONS_MASS = "Action on %s selected profiles",
	REG_LIST_ACTIONS_MASS_REMOVE = "Remove profiles",
	REG_LIST_ACTIONS_MASS_REMOVE_C = "This action will remove |cff00ff00%s selected profile(s)|r.",
	REG_LIST_ACTIONS_MASS_IGNORE = "Ignore profiles",
	REG_LIST_ACTIONS_MASS_IGNORE_C = [[This action will add |cff00ff00%s character(s)|r to the ignore list.

You can optionally enter the reason below. This is a personal note, it will serve as a reminder.]],
	REG_LIST_CHAR_TUTO_ACTIONS = "This column allows you to select multiple characters and perform an action on all of them.",
	REG_LIST_CHAR_TUTO_LIST = [[The first column shows the character's name.

The second column shows the relation between these characters and your current character.

The last column is for various flags. (ignored ..etc.)]],
	REG_LIST_CHAR_TUTO_FILTER = [[You can filter the character list.

The |cff00ff00name filter|r will perform a search on the profile full name (first name + last name) but also on any bound WoW characters.

The |cff00ff00guild filter|r will search on guild name from bound WoW characters.

The |cff00ff00realm only filter|r will show only profiles bound to a WoW character of your current realm.]],
	REG_LIST_NOTIF_ADD = "New profile discovered for |cff00ff00%s",
	REG_LIST_NOTIF_ADD_CONFIG = "New profile discovered",
	REG_LIST_NOTIF_ADD_NOT = "This profile doesn't exist anymore.",
	REG_COMPANION_LINKED = "The companion %s is now linked to the profile %s.",
	REG_COMPANION = "Companion",
	REG_COMPANIONS = "Companions",
	REG_COMPANION_BOUNDS = "Binds",
	REG_COMPANION_TARGET_NO = "Your target is not a valid pet, minion, ghoul, mage elemental or a renamed battle pet.",
	REG_COMPANION_BOUND_TO = "Bound to ...",
	REG_COMPANION_UNBOUND = "Unbound from ...",
	REG_COMPANION_LINKED_NO = "The companion %s is no longer linked to any profile.",
	REG_COMPANION_BOUND_TO_TARGET = "Target",
	REG_COMPANION_BROWSER_BATTLE = "Battle pet browser",
	REG_COMPANION_BROWSER_MOUNT = "Mount browser",
	REG_COMPANION_PROFILES = "Companions profiles",
	REG_COMPANION_TF_PROFILE = "Companion profile",
    REG_COMPANION_TF_PROFILE_MOUNT = "Mount profile",
	REG_NPC_PROFILE = "NPC profile",
	REG_COMPANION_TF_NO = "No profile",
	REG_COMPANION_TF_CREATE = "Create new profile",
	REG_COMPANION_TF_UNBOUND = "Unlink from profile",
	REG_COMPANION_TF_BOUND_TO = "Select a profile",
	REG_COMPANION_TF_OPEN = "Open page",
	REG_COMPANION_TF_OWNER = "Owner: %s",
	REG_COMPANION_INFO = "Information",
	REG_COMPANION_NAME = "Name",
	REG_COMPANION_TITLE = "Title",
	REG_COMPANION_NAME_COLOR = "Name color",
	REG_MSP_ALERT = [[|cffff0000WARNING

You can't have simultaneously more than one addon using the Mary Sue Protocol, as they would be in conflict.|r

Currently loaded: |cff00ff00%s

|cffff9900Therefore the MSP support for Total RP3 will be disabled.|r

If you don't want TRP3 to be your MSP addon and don't want to see this alert again, you can disable the Mary Sue Protocol module in the TRP3 Settings -> Module status.]],
	REG_COMPANION_PAGE_TUTO_C_1 = "Consult",
	REG_COMPANION_PAGE_TUTO_E_1 = "This is |cff00ff00your companion main information|r.\n\nAll these information will appear on |cffff9900your companion's tooltip|r.",
	REG_COMPANION_PAGE_TUTO_E_2 = [[This is |cff00ff00your companion description|r.

It isn't limited to |cffff9900physical description|r. Feel free to indicate parts from their |cffff9900background|r or details about their |cffff9900personality|r.

There are a lot of ways to customize the description.
You can choose a |cffffff00background texture|r for the description. You can also use the formatting tools to access several layout parameters like |cffffff00texts sizes, colors and alignments|r.
These tools also allow you to insert |cffffff00images, icons or links to external web sites|r.]],

	--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
	-- CONFIGURATION
	--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

	CO_CONFIGURATION = "Settings",
	CO_GENERAL = "General settings",
	CO_GENERAL_CHANGELOCALE_ALERT = "Reload the interface in order to change the language to %s now ?\n\nIf not, the language will be changed on the next connection.",
	CO_GENERAL_LOCALE = "Addon locale",
	CO_GENERAL_COM = "Communication",
	CO_GENERAL_MISC = "Miscellaneous",
	CO_GENERAL_TT_SIZE = "Info tooltip text size",
	CO_GENERAL_NEW_VERSION = "Update alert",
	CO_GENERAL_NEW_VERSION_TT = "Get an alert when a new version is available.",
	CO_GENERAL_UI_SOUNDS = "UI sounds",
	CO_GENERAL_UI_SOUNDS_TT = "Activate the UI sounds (when opening windows, switching tabs, clicking buttons).",
	CO_GENERAL_UI_ANIMATIONS = "UI animations",
	CO_GENERAL_UI_ANIMATIONS_TT = "Activate the UI animations.",
	CO_GENERAL_BROADCAST = "Use broadcast channel",
	CO_GENERAL_BROADCAST_TT = "The broadcast channel is used by a lot of features. Disabling it will disable all the features like characters position on the map, playing local sounds, stashes and signposts access...",
	CO_GENERAL_DEFAULT_COLOR_PICKER = "Default color picker",
	CO_GENERAL_DEFAULT_COLOR_PICKER_TT = "Activate to always use the default color picker. Useful if you're using a color picker addon.",
	CO_GENERAL_RESET_CUSTOM_COLORS = "Reset custom colors",
	CO_GENERAL_RESET_CUSTOM_COLORS_TT = "Removes all custom colors saved in the color picker.",
	CO_GENERAL_RESET_CUSTOM_COLORS_WARNING = "Are you sure you want to remove all custom colors saved in the color picker ?",
	CO_TOOLTIP = "Tooltip settings",
	CO_TOOLTIP_USE = "Use characters/companions tooltip",
	CO_TOOLTIP_COMBAT = "Hide during combat",
	CO_TOOLTIP_COLOR = "Show custom colors",
	CO_TOOLTIP_CONTRAST = "Increase color contrast",
	CO_TOOLTIP_CONTRAST_TT = "Enable this option to allow Total RP 3 to modify the custom colors to make the text more readable if the color is too dark.",
	CO_TOOLTIP_CROP_TEXT = "Crop unreasonably long texts",
	CO_TOOLTIP_CROP_TEXT_TT = [[Limit the number of characters that can be displayed by each field in the tooltip to prevent unreasonably long texts and possible layout issues.

|cfffff569Limit details:
Name: 100 characters
Title: 150 characters
Race: 50 characters
Class: 50 characters|r]],
	CO_TOOLTIP_CHARACTER = "Characters tooltip",
	CO_TOOLTIP_ANCHORED = "Anchored frame",
	CO_TOOLTIP_ANCHOR = "Anchor point",
	CO_TOOLTIP_HIDE_ORIGINAL = "Hide original tooltip",
	CO_TOOLTIP_MAINSIZE = "Main font size",
	CO_TOOLTIP_SUBSIZE = "Secondary font size",
	CO_TOOLTIP_TERSIZE = "Tertiary font size",
	CO_TOOLTIP_SPACING = "Show spacing",
	CO_TOOLTIP_SPACING_TT = "Place spaces to lighten the tooltip, in the style of MyRoleplay tooltip.",
	CO_TOOLTIP_NO_FADE_OUT = "Hide immediately instead of fading",
	CO_TOOLTIP_PETS = "Companions tooltip",
	CO_TOOLTIP_OWNER = "Show owner",
	CO_TOOLTIP_PETS_INFO = "Show companion info",
	CO_TOOLTIP_COMMON = "Common settings",
	CO_TOOLTIP_ICONS = "Show icons",
	CO_TOOLTIP_FT = "Show full title",
	CO_TOOLTIP_RACE = "Show race, class and level",
	CO_TOOLTIP_REALM = "Show realm",
	CO_TOOLTIP_GUILD = "Show guild info",
	CO_TOOLTIP_PRONOUNS = "Show pronouns",
	CO_TOOLTIP_TARGET = "Show target",
	CO_TOOLTIP_TITLE = "Show title",
	CO_TOOLTIP_CLIENT = "Show client",
	CO_TOOLTIP_NOTIF = "Show notifications",
	CO_TOOLTIP_NOTIF_TT = "The notifications line is the line containing the client version, the unread description marker and the 'At first glance' marker.",
	CO_TOOLTIP_RELATION = "Show relationship color",
	CO_TOOLTIP_RELATION_TT = "Set the character tooltip border to a color representing the relation.",
	CO_TOOLTIP_CURRENT = "Show \"current\" information",
	CO_TOOLTIP_CURRENT_SIZE = "Max \"current\" information length",
	CO_TOOLTIP_PROFILE_ONLY = "Use only if target has a profile",
	CO_TOOLTIP_IN_CHARACTER_ONLY = "Hide when out of character",
	CO_TOOLTIP_HIDE_IN_INSTANCE = "Hide while in instance",
	CO_TOOLTIP_ZONE = "Show zone",
	CO_TOOLTIP_ZONE_TT = "This will only show if the target is not in the same zone as you.",
	CO_TOOLTIP_HEALTH = "Show health",
	CO_TOOLTIP_HEALTH_TT = "This will only show if the target is not at full health.",
	CO_TOOLTIP_HEALTH_DISABLED = "Disabled",
	CO_TOOLTIP_HEALTH_NUMBER = "Number",
	CO_TOOLTIP_HEALTH_PERCENT = "Percentage",
	CO_TOOLTIP_HEALTH_BOTH = "Number + Percentage",
	CO_TOOLTIP_TITLE_COLOR = "Title text color",
	CO_TOOLTIP_TITLE_COLOR_HELP = [[The color used in the tooltip to display full-length character titles.]],
	CO_TOOLTIP_MAIN_COLOR = "Main text color",
	CO_TOOLTIP_MAIN_COLOR_HELP = [[The color used in the tooltip to display text such as the race, level, and currently and OOC headers.]],
	CO_TOOLTIP_SECONDARY_COLOR = "Secondary text color",
	CO_TOOLTIP_SECONDARY_COLOR_HELP = [[The color used in the tooltip to display secondary subtext such as realm and guild names, the currently and OOC contents, and zone or health information.]],
	CO_REGISTER = "Register settings",
	CO_REGISTER_ABOUT_SETTINGS = "\"About\" settings",
	CO_REGISTER_ABOUT_H1_SIZE = "Header 1 text size",
	CO_REGISTER_ABOUT_H1_SIZE_TT = "Size of the text between {h1} tags. Default: %s",
	CO_REGISTER_ABOUT_H2_SIZE = "Header 2 text size",
	CO_REGISTER_ABOUT_H2_SIZE_TT = "Size of the text between {h2} tags. Default: %s",
	CO_REGISTER_ABOUT_H3_SIZE = "Header 3 text size",
	CO_REGISTER_ABOUT_H3_SIZE_TT = "Size of the text between {h3} tags. Default: %s",
	CO_REGISTER_ABOUT_P_SIZE = "Paragraph text size",
	CO_REGISTER_ABOUT_P_SIZE_TT = "Size of the text outside of header tags. Default: %s",
	CO_REGISTER_AUTO_PURGE = "Auto purge directory",
	CO_REGISTER_AUTO_PURGE_TT = "Automatically remove from directory the profiles of characters you haven't crossed for a certain time. You can choose the delay before deletion.\n\n|cff00ff00Note that profiles with a relation toward one of your characters will never be purged.\n\n|cffff9900There is a bug in WoW losing all the saved data when it reaches a certain threshold. We strongly recommend to avoid disabling the purge system.",
	CO_REGISTER_AUTO_PURGE_0 = "Disable purge",
	CO_REGISTER_AUTO_PURGE_1 = "After %s day(s)",
	CO_CURSOR_TITLE = "Cursor interactions",
	CO_CURSOR_RIGHT_CLICK = "Right-click to open profile",
	CO_CURSOR_RIGHT_CLICK_TT = [[Right-click on a player in the 3D world to open their profile, if they have one.

|TInterface\Cursor\WorkOrders:25|t This icon will be attached to the cursor when a player has a profile and you can right-click them.

|cffccccccNote: This feature is disabled during combat.|r]],
	CO_CURSOR_DISABLE_OOC = "Disabled while OOC",
	CO_CURSOR_DISABLE_OOC_TT = "Disable the cursor modifications when your roleplay status is set to |cffccccccOut Of Character|f.",
	CO_CURSOR_MODIFIER_KEY = "Modifier key",
	CO_CURSOR_MODIFIER_KEY_TT = "Requires a modifier key to be held down while right-clicking a player, to prevent accidental clicks.",
	CO_MODULES = "Modules status",
	CO_MODULES_VERSION = "Version: %s",
	CO_MODULES_ID = "Module ID: %s",
	CO_MODULES_STATUS = "Status: %s",
	CO_MODULES_STATUS_0 = "Missing dependencies",
	CO_MODULES_STATUS_1 = "Loaded",
	CO_MODULES_STATUS_2 = "Disabled",
	CO_MODULES_STATUS_3 = "Total RP 3 update required",
	CO_MODULES_STATUS_4 = "Error on initialization",
	CO_MODULES_STATUS_5 = "Error on startup",
	CO_MODULES_TT_NONE = "No dependencies";
	CO_MODULES_TT_DEPS = "Dependencies";
	CO_MODULES_TT_TRP = "%sFor Total RP 3 build %s minimum.|r",
	CO_MODULES_TT_DEP = "\n%s- %s (version %s)|r",
	CO_MODULES_TT_ERROR = "\n\n|cffff0000Error:|r\n%s";
	CO_MODULES_TUTO = [[A module is a independent feature that can be enabled or disabled.

Possible status:
|cff00ff00Loaded:|r The module is enabled and loaded.
|cff999999Disabled:|r The module is disabled.
|cffff9900Missing dependencies:|r Some dependencies are not loaded.
|cffff9900TRP update required:|r The module requires a more recent version of TRP3.
|cffff0000Error on init or on startup:|r The module loading sequence failed. The module will likely create errors !

|cffff9900When disabling a module, a UI reload is necessary.]],
	CO_MODULES_SHOWERROR = "Show error",
	CO_MODULES_DISABLE = "Disable module",
	CO_MODULES_ENABLE = "Enable module",
	CO_TOOLBAR = "Frames settings",
	CO_TOOLBAR_CONTENT = "Toolbar settings",
	CO_TOOLBAR_ICON_SIZE = "Icons size",
	CO_TOOLBAR_MAX = "Max icons per line",
	CO_TOOLBAR_MAX_TT = "Set to 1 if you want to display the bar vertically !",
	CO_TOOLBAR_CONTENT_CAPE = "Cape switch",
	CO_TOOLBAR_CONTENT_HELMET = "Helmet switch",
	CO_TOOLBAR_CONTENT_STATUS = "Player status (AFK/DND)",
	CO_TOOLBAR_CONTENT_RPSTATUS = "Character status (IC/OOC)",
	CO_TOOLBAR_SHOW_ON_LOGIN = "Show toolbar on login",
	CO_TOOLBAR_SHOW_ON_LOGIN_HELP = "If you don't want the toolbar to be displayed on login, you can disable this option.",
	CO_TOOLBAR_HIDE_TITLE = "Hide Toolbar Title",
	CO_TOOLBAR_HIDE_TITLE_HELP = "Hides the title shown above the toolbar.",
	CO_TARGETFRAME = "Target frame settings",
	CO_TARGETFRAME_USE = "Display conditions",
	CO_TARGETFRAME_USE_TT = "Determines in which conditions the target frame should be shown on target selection.",
	CO_TARGETFRAME_USE_1 = "Always",
	CO_TARGETFRAME_USE_2 = "Only when IC",
	CO_TARGETFRAME_USE_3 = "Never (Disabled)",
	CO_TARGETFRAME_ICON_SIZE = "Icons size",
	CO_MINIMAP_BUTTON = "Minimap button",
	CO_MINIMAP_BUTTON_SHOW_TITLE = "Show minimap button",
	CO_MINIMAP_BUTTON_SHOW_HELP = [[If you are using another add-on to display Total RP 3's minimap button (FuBar, Titan, Bazooka) you can remove the button from the minimap.

|cff00ff00Reminder : You can open Total RP 3 using /trp3 switch main|r]],
	CO_MINIMAP_BUTTON_FRAME = "Frame to anchor",
	CO_MINIMAP_BUTTON_RESET = "Reset position",
	CO_MINIMAP_BUTTON_RESET_BUTTON = "Reset",
	CO_MAP_BUTTON = "Map scan button",
	CO_MAP_BUTTON_POS = "Scan button anchor on map",
	CO_ANCHOR_TOP = "Top",
	CO_ANCHOR_TOP_LEFT = "Top left",
	CO_ANCHOR_TOP_RIGHT = "Top right",
	CO_ANCHOR_BOTTOM = "Bottom",
	CO_ANCHOR_BOTTOM_LEFT = "Bottom left",
	CO_ANCHOR_BOTTOM_RIGHT = "Bottom right",
	CO_ANCHOR_LEFT = "Left",
	CO_ANCHOR_RIGHT = "Right",
	CO_ANCHOR_CURSOR = "Show on cursor",
	CO_CHAT = "Chat settings",
	CO_CHAT_DISABLE_OOC = "Disable customizations when OOC",
	CO_CHAT_DISABLE_OOC_TT = "Disable all of Total RP 3's chat customizations (custom names, emote detection, NPC speeches, etc.) when your character is set as Out Of Character.",
	CO_CHAT_MAIN = "Chat main settings",
	CO_CHAT_MAIN_NAMING = "Naming method",
	CO_CHAT_MAIN_NAMING_1 = "Keep original names",
	CO_CHAT_MAIN_NAMING_2 = "Use custom names",
	CO_CHAT_MAIN_NAMING_3 = "First name + last name",
	CO_CHAT_MAIN_NAMING_4 = "Short title + first name + last name",
	CO_CHAT_REMOVE_REALM = "Remove realm from player names",
	CO_CHAT_INSERT_FULL_RP_NAME = "Insert RP names on shift-click",
	CO_CHAT_INSERT_FULL_RP_NAME_TT = [[Insert the complete RP name of a player when SHIFT-Clicking their name in the chat frame.

(When this option is enabled, you can ALT-SHIFT-Click on a name when you want the default behavior and insert the character name instead of the full RP name.)]],
	CO_CHAT_MAIN_COLOR = "Use custom colors for names",
	CO_CHAT_INCREASE_CONTRAST = "Increase color contrast",
	CO_CHAT_SHOW_OOC = "Show OOC indicator",
	CO_CHAT_USE_ICONS = "Show player icons",
	CO_CHAT_USE = "Used chat channels",
	CO_CHAT_USE_SAY = "Say channel",
	CO_CHAT_MAIN_NPC = "NPC talk detection",
	CO_CHAT_MAIN_NPC_USE = "Use NPC talk detection",
	CO_CHAT_MAIN_NPC_PREFIX = "NPC talk detection pattern",
	CO_CHAT_MAIN_NPC_PREFIX_TT = "If a chat line said in the EMOTE channel begins with this prefix, it will be interpreted as an NPC chat.\n\n|cff00ff00By default : \"|| \"\n(without the \" and with a space after the pipe)",
	CO_CHAT_MAIN_EMOTE = "Emote detection",
	CO_CHAT_MAIN_EMOTE_USE = "Use emote detection",
	CO_CHAT_MAIN_EMOTE_PATTERN = "Emote detection pattern",
	CO_CHAT_MAIN_OOC = "OOC detection",
	CO_CHAT_MAIN_OOC_USE = "Use OOC detection",
	CO_CHAT_MAIN_OOC_PATTERN = "OOC detection pattern",
	CO_CHAT_MAIN_OOC_COLOR = "OOC color",
	CO_CHAT_MAIN_EMOTE_YELL = "No yelled emote",
	CO_CHAT_MAIN_EMOTE_YELL_TT = "Do not show *emote* or <emote> in yelling.",
	CO_CHAT_NPCSPEECH_REPLACEMENT = "Customize companion names in NPC speeches",
	CO_CHAT_NPCSPEECH_REPLACEMENT_TT = "If a companion name is in brackets in an NPC speech, it will be colored and its icon will be shown depending on your settings above.",
	CO_GLANCE_MAIN = "\"At first glance\" bar",
	CO_GLANCE_RESET_TT = "Reset the bar position to the bottom left of the anchored frame.",
	CO_GLANCE_LOCK = "Lock bar",
	CO_GLANCE_LOCK_TT = "Prevent the bar from being dragged",
	CO_GLANCE_PRESET_TRP2 = "Use Total RP 2 style positions",
	CO_GLANCE_PRESET_TRP2_BUTTON = "Use",
	CO_GLANCE_PRESET_TRP2_HELP = "Shortcut to setup the bar in a TRP2 style : to the right of WoW target frame.",
	CO_GLANCE_PRESET_TRP3 = "Use Total RP 3 style positions",
	CO_GLANCE_PRESET_TRP3_HELP = "Shortcut to setup the bar in a TRP3 style : to the bottom of the TRP3 target frame.",
	CO_GLANCE_TT_ANCHOR = "Tooltips anchor point",
	CO_HIDE_EMPTY_MAP_BUTTON = "Hide when no scans available",
	CO_MSP = "Mary Sue Protocol",
	CO_WIM = "|cffff9900Whisper channels are disabled.",
	CO_WIM_TT = "You are using |cff00ff00WIM|r, the handling for whisper channels is disabled for compatibility purposes",
	CO_LOCATION = "Location settings",
	CO_LOCATION_ACTIVATE = "Enable character location",
	CO_LOCATION_ACTIVATE_TT = "Enable the character location system, allowing you to scan for other Total RP users on the world map and allowing them to find you.",
	CO_LOCATION_DISABLE_OOC = "Disable location when OOC",
	CO_LOCATION_DISABLE_OOC_TT = "You will not respond to location requests from other players when you've set your RP status to Out Of Character.",
	CO_LOCATION_DISABLE_CLASSIC_PVP = "Disable location when flagged for PvP",
	CO_LOCATION_DISABLE_CLASSIC_PVP_TT = "You will not respond to location requests from other players when you are flagged for PvP.\n\nThis option is particularly useful to avoid abuses of the location system to track you.",
	CO_SANITIZER = "Sanitize incoming profiles",
	CO_SANITIZER_TT = "Remove escaped sequences in tooltip fields from incoming profiles when TRP doesn't allow it (color, images ...).",

	--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
	-- TOOLBAR AND UI BUTTONS
	--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

	TB_TOOLBAR = "Toolbar",
	TB_SWITCH_TOOLBAR = "Switch toolbar",
	TB_SWITCH_CAPE_ON = "Cloak: |cff00ff00Shown",
	TB_SWITCH_CAPE_OFF = "Cloak: |cffff0000Hidden",
	TB_SWITCH_CAPE_1 = "Show cloak",
	TB_SWITCH_CAPE_2 = "Hide cloak",
	TB_SWITCH_HELM_ON = "Helm: |cff00ff00Shown",
	TB_SWITCH_HELM_OFF = "Helm: |cffff0000Hidden",
	TB_SWITCH_HELM_1 = "Show helmet",
	TB_SWITCH_HELM_2 = "Hide helmet",
	TB_GO_TO_MODE = "Switch to %s mode",
	TB_NORMAL_MODE = "Normal",
	TB_DND_MODE = "Do not disturb",
	TB_AFK_MODE = "Away",
	TB_STATUS = "Player",
	TB_RPSTATUS_ON = "Character: |cff00ff00In character",
	TB_RPSTATUS_OFF = "Character: |cffff0000Out of character",
	TB_RPSTATUS_TO_ON = "Go |cff00ff00in character",
	TB_RPSTATUS_TO_OFF = "Go |cffff0000out of character",
	TB_SWITCH_PROFILE = "Switch to another profile",
	TF_OPEN_CHARACTER = "Show character page",
    TF_OPEN_COMPANION = "Show companion page",
	TF_OPEN_NPC = "Show npc page",
	TF_OPEN_DM_NOTES = "Open DM notes",
	TF_OPEN_MOUNT = "Show mount page",
	TF_PLAY_THEME = "Play character theme",
	TF_PLAY_THEME_TT = "|cffffff00Click:|r Play |cff00ff00%s\n|cffffff00Right-click:|r Stop theme",
	TF_IGNORE = "Ignore player",
	TF_IGNORE_TT = "|cffffff00Click:|r Ignore player",
	TF_IGNORE_CONFIRM = "Are you sure you want to ignore this ID ?\n\n|cffffff00%s|r\n\n|cffff7700You can optionally enter below the reason why you ignore it. This is a personal note, it won't be visible by others and will serve as a reminder.",
	TF_IGNORE_NO_REASON = "No reason",
	TB_LANGUAGE = "Language",
	TB_LANGUAGES_TT = "Change language",

	--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
	-- PROFILES
	--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

	PR_PROFILEMANAGER_TITLE = "Characters profiles",
	PR_PROFILEMANAGER_DELETE_WARNING = "Are you sure you want to delete the profile %s?\nThis action cannot be undone and all TRP3 information linked to this profile (Character info, inventory, quest log, applied states ...) will be destroyed !",
	PR_PROFILE = "Profile",
	PR_PROFILES = "Profiles",
	PR_PROFILE_CREATED = "Profile %s created.",
	PR_CREATE_PROFILE = "Create profile",
	PR_PROFILE_DELETED = "Profile %s deleted.",
	PR_PROFILE_HELP = "A profile contains all information about a |cffffff00\"character\"|r as a |cff00ff00roleplay character|r.\n\nA real |cffffff00\"WoW character\"|r can be bound to only one profile at a time, but can switch from one to another whenever you want.\n\nYou can also bind several |cffffff00\"WoW characters\"|r to the same |cff00ff00profile|r !",
	PR_PROFILE_DETAIL = "This profile is currently bound to these WoW characters",
	PR_DELETE_PROFILE = "Delete profile",
	PR_DUPLICATE_PROFILE = "Duplicate profile",
	PR_UNUSED_PROFILE = "This profile is currently not bound to any WoW character.",
	PR_PROFILE_LOADED = "The profile %s is loaded.",
	PR_PROFILEMANAGER_CREATE_POPUP = "Please enter a name for the new profile.\nThe name cannot be empty.",
	PR_PROFILEMANAGER_DUPP_POPUP = "Please enter a name for the new profile.\nThe name cannot be empty.\n\nThis duplication will not change the character's binds to %s.",
	PR_PROFILEMANAGER_EDIT_POPUP = "Please enter a new name for this profile %s.\nThe name cannot be empty.\n\nChanging the name will not change any link between this profile and your characters.",
	PR_PROFILEMANAGER_ALREADY_IN_USE = "The profile name %s is not available.",
	PR_PROFILEMANAGER_COUNT = "%s WoW character(s) bound to this profile.",
	PR_PROFILEMANAGER_ACTIONS = "Actions",
	PR_PROFILEMANAGER_SWITCH = "Select profile",
	PR_PROFILEMANAGER_RENAME = "Rename profile",
	PR_PROFILEMANAGER_CURRENT = "Current profile",
	PR_PROFILEMANAGER_SEARCH_PROFILE = "Search profile",
	PR_PROFILEMANAGER_EMPTY = "No profiles found",
	PR_CO_PROFILEMANAGER_TITLE = "Companions profiles",
	PR_CO_PROFILE_HELP = [[A profile contains all information about a |cffffff00"pet"|r as a |cff00ff00roleplay character|r.

A companion profile can be linked to:
- A battle pet |cffff9900(only if it has been renamed)|r
- A hunter pet
- A warlock minion
- A mage elemental
- A death knight ghoul |cffff9900(see below)|r

Just like characters profiles, a |cff00ff00companion profile|r can be linked to |cffffff00several pets|r, and a |cffffff00pet|r can switch easily from one profile to another.

|cffff9900Ghouls:|r As ghouls get a new name each time they are summoned, you will have to re-link the profile to the ghoul for all possible names.]],
	PR_CO_PROFILE_HELP2 = [[Click here to create a new companion profile.

|cff00ff00To link a profile to a pet (hunter pet, warlock minion ...), just summon the pet, select it and use the target frame to link it to a existing profile (or create a new one).|r]],
	PR_CO_MASTERS = "Masters",
	PR_CO_EMPTY = "No companion profile",
	PR_CO_NEW_PROFILE = "New companion profile",
	PR_CO_COUNT = "%s pets/mounts bound to this profile.",
	PR_CO_UNUSED_PROFILE = "This profile is currently not bound to any pet or mount.",
	PR_CO_PROFILE_DETAIL = "This profile is currently bound to",
	PR_CO_PROFILEMANAGER_DELETE_WARNING = "Are you sure you want to delete the companion profile %s?\nThis action cannot be undone and all TRP3 information linked to this profile will be destroyed !",
	PR_CO_PROFILEMANAGER_DUPP_POPUP = "Please enter a name for the new profile.\nThe name cannot be empty.\n\nThis duplication will not change your pets/mounts binds to %s.",
	PR_CO_PROFILEMANAGER_EDIT_POPUP = "Please enter a new name for this profile %s.\nThe name cannot be empty.\n\nChanging the name will not change any link between this profile and your pets/mounts.",
	PR_CO_WARNING_RENAME = "|cffff0000Warning:|r it's strongly recommended that you rename your pet before linking it to a profile.\n\nLink it anyway ?",
	PR_CO_PET = "Pet",
	PR_CO_BATTLE = "Battle pet",
	PR_CO_MOUNT = "Mount",
	PR_IMPORT_CHAR_TAB = "Characters importer",
	PR_IMPORT_PETS_TAB = "Companions importer",
	PR_IMPORT_IMPORT_ALL = "Import all",
	PR_IMPORT_WILL_BE_IMPORTED = "Will be imported",
	PR_IMPORT_EMPTY = "No importable profile",
	PR_PROFILE_MANAGEMENT_TITLE = "Profile management",
	PR_EXPORT_IMPORT_TITLE = "Export/import profile",
	PR_EXPORT_IMPORT_HELP = [[You can export and import profiles using the options in the dropdown menu.

Use the |cffffff00Export profile|r option to generate a chunk of text containing the profile serialized data. You can copy the text using Control-C (or Command-C on a Mac) and paste it somewhere else as a backup. (|cffff0000Please note that some advanced text editing tools like Microsoft Word will reformat special characters like quotes, altering the data. Use simpler text editing tools like Notepad.|r)

Use the |cffffff00Import profile|r option to paste data from a previous export inside an existing profile. The existing data in this profile will be replaced by the ones you have pasted. You cannot import data directly into your currently selected profile.]],
	PR_EXPORT_PROFILE = "Export profile",
	PR_IMPORT_PROFILE = "Import profile",
	PR_EXPORT_NAME = "Serial for profile %s (size %0.2f kB)",
	PR_EXPORT_TOO_LARGE = "This profile is too large and can't be exported.\n\nSize of profile: %0.2f kB\nMax: 20 kB",
	PR_IMPORT_PROFILE_TT = "Paste a profile serial here",
	PR_IMPORT = "Import",
	PR_PROFILEMANAGER_IMPORT_WARNING = "Replace all the content of profile %s with this imported data?",
	PR_PROFILEMANAGER_IMPORT_WARNING_2 = "Warning: this profile serial has been made from an older version of TRP3.\nThis can bring incompatibilities.\n\nReplacing all the content of profile %s with this imported data?",
	PR_SLASH_SWITCH_HELP = "Switch to another profile using its name.",
	PR_SLASH_EXAMPLE = "|cffffff00Command usage:|r |cffcccccc/trp3 profile Millidan Foamrage|r |cffffff00to switch to Millidan Foamrage's profile.|r",
	PR_SLASH_NOT_FOUND = "|cffff0000Could not find a profile named|r |cffffff00%s|r|cffff0000.|r",
	PR_SLASH_OPEN_HELP = "Open a character's profile using its in-game name, or your target's profile if no name is provided.",
	PR_SLASH_OPEN_EXAMPLE = "|cffffff00Command usage:|r |cffcccccc/trp3 open|r |cffffff00to open your target's profile or |cffcccccc/trp3 open CharacterName-RealmName|r |cffffff00to open that character's profile.|r",
	PR_SLASH_OPEN_WAITING = "|cffffff00Requesting profile, please wait...|r",
	PR_SLASH_OPEN_ABORTING = "|cffffff00Aborted profile request.|r",
	PR_DEFAULT_PROFILE_NAME = "Default profile",
	PR_DEFAULT_PROFILE_WARNING = "Create a new profile\nor link to an existing one in Profiles\nto edit your character's information.",

	--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
	-- DASHBOARD
	--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

	DB_STATUS = "Status",
	DB_STATUS_CURRENTLY_COMMON = "These statuses will be displayed on your character's tooltip. Keep it clear and brief as |cffff9900by default TRP3 players will only see the first 140 characters of them!",
	DB_STATUS_CURRENTLY = "Currently (IC)",
	DB_STATUS_CURRENTLY_TT = "Here you can indicate something important about your character.",
	DB_STATUS_CURRENTLY_OOC = "Other information (OOC)",
	DB_STATUS_CURRENTLY_OOC_TT = "Here you can indicate something important about you, as a player, or anything out of your character.",
	DB_STATUS_RP = "Character status",
	DB_STATUS_RP_IC = "In character",
	DB_STATUS_RP_IC_TT = "That means you are currently playing your character.\nAll your actions will be interpreted as if it's your character doing them.",
	DB_STATUS_RP_OOC = "Out of character",
	DB_STATUS_RP_OOC_TT = "You are out of your character.\nYour actions can't be associated to him/her.",
	DB_STATUS_XP = "Roleplayer status",
	DB_STATUS_XP_BEGINNER = "Rookie roleplayer",
	DB_STATUS_XP_BEGINNER_TT = "This selection will show an icon on your tooltip, indicating\nto others that you are a beginner roleplayer.",
	DB_STATUS_RP_EXP = "Experienced roleplayer",
	DB_STATUS_RP_EXP_TT = "Shows that you are an experienced roleplayer.\nIt will not show any specific icon on your tooltip.",
	DB_STATUS_RP_VOLUNTEER = "Volunteer roleplayer",
	DB_STATUS_RP_VOLUNTEER_TT = "This selection will show an icon on your tooltip, indicating\nto beginner roleplayers that you are willing to help them.",
	DB_STATUS_LC = "Roleplay language",
	DB_STATUS_LC_TT = [[Sets your preferred roleplaying language. This will be shared with other compatible RP addon users.

|cffff9900Note:|r This does |cffff0000not|r change the user interface language of Total RP 3. This option can instead be found in the |cfffff569Advanced Settings|r page.]],

	-- DB_STATUS_LC_DEFAULT will be formatted with the current locale name, eg. "Italiano".
	DB_STATUS_LC_DEFAULT = "Default (%1$s)",

	-- DB_STATUS_ICON_ITEM will be formatted with an icon texture and a label for a dropdown item.
	DB_STATUS_ICON_ITEM = "%1$s %2$s",
	DB_TUTO_1 = [[|cffffff00The character status|r indicates if you are currently playing your character's role or not.

|cffffff00The roleplayer status|r allows you to state that you are a beginner, or a veteran willing to help rookies!

|cff00ff00These information will be placed in your character's tooltip.]],
	DB_NEW = "What's new?",
	DB_ABOUT = "About Total RP 3",
	DB_MORE = "More modules",
	DB_HTML_GOTO = "Click to open",
	--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
	-- COMMON UI TEXTS
	--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

	UI_BKG = "Background %s",
	UI_ICON_BROWSER = "Icon browser",
	UI_ICON_BROWSER_HELP = "Copy icon",
	UI_ICON_BROWSER_HELP_TT = [[While this frame is open you can |cffffff00ctrl + click|r on a icon to copy its name.

This will works:|cff00ff00
- On any item in your bags
- On any icon in the spellbook|r]],
	UI_COMPANION_BROWSER_HELP = "Select a battle pet",
	UI_COMPANION_BROWSER_HELP_TT = "|cffffff00Warning: |rOnly renamed battle pets can be bound to a profile.\n\n|cff00ff00This section lists these battle pets only.",
	UI_ICON_SELECT = "Select icon",
	UI_MUSIC_BROWSER = "Music browser",
	UI_MUSIC_SELECT = "Select music",
	UI_MUSIC_DURATION = "Duration",
	UI_MUSIC_ALTTITLE = "Alternate title",
	UI_COLOR_BROWSER = "Color browser",
	UI_COLOR_BROWSER_SELECT = "Select color",
	UI_COLOR_BROWSER_PRESETS = "Presets",
	UI_COLOR_BROWSER_PRESETS_BASIC = "Basic",
	UI_COLOR_BROWSER_PRESETS_CLASSES = "Class",
	UI_COLOR_BROWSER_PRESETS_RESOURCES = "Resource",
	UI_COLOR_BROWSER_PRESETS_ITEMS = "Item quality",
	UI_COLOR_BROWSER_PRESETS_CUSTOM = "Custom",
	UI_IMAGE_BROWSER = "Image browser",
	UI_IMAGE_SELECT = "Select image",
	UI_FILTER = "Filter",
	UI_LINK_URL = "http://your.url.here",
	UI_LINK_TEXT = "Your text here",
	UI_LINK_SAFE = [[Here's the link URL.]],
	UI_LINK_WARNING = [[Here's the link URL.
You can copy/paste it in your web browser.

|cffff0000!! Disclaimer !!|r
Total RP is not responsible for links leading to harmful content.]],
	UI_TUTO_BUTTON = "Tutorial mode",
	UI_TUTO_BUTTON_TT = "Click to toggle on/off the tutorial mode",
	UI_CLOSE_ALL = "Close all",

	NPC_TALK_SAY_PATTERN = "says:",
	NPC_TALK_YELL_PATTERN = "yells:",
	NPC_TALK_WHISPER_PATTERN = "whispers:",

	--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
	-- COMMON TEXTS
	--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

	CM_SHOW = "Show",
	CM_ACTIONS = "Actions",
	CM_IC = "IC",
	CM_OOC = "OOC",
	CM_CLICK = "Click",
	CM_R_CLICK = "Right-click",
	CM_L_CLICK = "Left-click",
	CM_M_CLICK = "Middle-click",
	CM_ALT = "Alt",
	CM_CTRL = "Ctrl",
	CM_SHIFT = "Shift",
	CM_DRAGDROP = "Drag & drop",
	CM_DOUBLECLICK = "Double-click",
	CM_LINK = "Link",
	CM_SAVE = "Save",
	CM_CANCEL = "Cancel",
	CM_DELETE = "Delete",
	CM_RESET = "Reset",
	CM_NAME = "Name",
	CM_VALUE = "Value",
	CM_UNKNOWN = "Unknown",
	CM_PLAY = "Play",
	CM_STOP = "Stop",
	CM_LOAD = "Load",
	CM_REMOVE = "Remove",
	CM_EDIT = "Edit",
	CM_LEFT = "Left",
	CM_CENTER = "Center",
	CM_RIGHT = "Right",
	CM_COLOR = "Color",
	CM_ICON = "Icon",
	CM_IMAGE = "Image",
	CM_SELECT = "Select",
	CM_OPEN = "Open",
	CM_APPLY = "Apply",
	CM_MOVE_UP = "Move up",
	CM_MOVE_DOWN = "Move down",
	CM_CLASS_WARRIOR = "Warrior",
	CM_CLASS_PALADIN = "Paladin",
	CM_CLASS_HUNTER = "Hunter",
	CM_CLASS_ROGUE = "Rogue",
	CM_CLASS_PRIEST = "Priest",
	CM_CLASS_DEATHKNIGHT = "Death Knight",
	CM_CLASS_SHAMAN = "Shaman",
	CM_CLASS_MAGE = "Mage",
	CM_CLASS_WARLOCK = "Warlock",
	CM_CLASS_MONK = "Monk",
	CM_CLASS_DRUID = "Druid",
	CM_CLASS_DEMONHUNTER = "Demon Hunter",
	CM_CLASS_EVOKER = "Evoker",
	CM_CLASS_UNKNOWN = "Unknown",
	CM_RESIZE = "Resize",
	CM_RESIZE_TT = "Drag to resize the frame.",
	CM_TWEET_PROFILE = "Show profile url",
	CM_TWEET = "Send a tweet",

	CM_ORANGE = "Orange",
	CM_WHITE = "White",
	CM_YELLOW = "Yellow",
	CM_CYAN = "Cyan",
	CM_BLUE = "Blue",
	CM_GREEN = "Green",
	CM_RED = "Red",
	CM_PURPLE = "Purple",
	CM_PINK = "Pink",
	CM_BLACK = "Black",
	CM_GREY = "Grey",

	--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
	-- Minimap button
	--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

	MM_SHOW_HIDE_MAIN = "Show/hide the main frame",
	MM_SHOW_HIDE_SHORTCUT = "Show/hide the toolbar",
	MM_SHOW_HIDE_MOVE = "Move button",

	--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
	-- Browsers
	--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

	BW_COLOR_CODE = "Color code",
	BW_COLOR_CODE_TT = "You can paste a 6 figures hexadecimal color code here and press Enter.",
	BW_COLOR_CODE_ALERT = "Wrong hexadecimal code !",
	BW_CUSTOM_NAME = "Custom color name",
	BW_CUSTOM_NAME_TITLE = "Name (Optional)",
	BW_CUSTOM_NAME_TT = "You can set a name for the custom color you're saving. If left empty, it will use the hexadecimal color code.",

	--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
	-- Databroker
	--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

	DTBK_HELMET = "Total RP 3 - Helmet",
	DTBK_CLOAK = "Total RP 3 - Cloak",
	DTBK_AFK = "Total RP 3 - AFK/DND",
	DTBK_RP = "Total RP 3 - IC/OOC",
	DTBK_LANGUAGES = "Total RP 3 - Languages",

	--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
	-- Bindings
	--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

	BINDING_NAME_TRP3_TOGGLE = "Toggle main frame";
	BINDING_NAME_TRP3_TOOLBAR_TOGGLE = "Toggle toolbar";

	--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
	-- About TRP3
	--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

	ABOUT_TITLE = "About",

	--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
	-- Slash commands
	--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

	SLASH_CMD_STATUS_USAGE = "ic || ooc || toggle",
	SLASH_CMD_STATUS_HELP = [[Usage: |cff00ff00/trp3 status ic || ooc || toggle|r
Changes your character status to the specified option:

|cffff9900/trp3 status ic|r will set your status to |cff00ff00in character|r.
|cffff9900/trp3 status ooc|r will set your status to |cffff0000out of character|r.
|cffff9900/trp3 status toggle|r will switch your status to the opposite state.]],

	--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
	-- MAP
	--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

	MAP_BUTTON_TITLE = "Scan for roleplay",
	MAP_BUTTON_SUBTITLE = "Click to show available scans",
	MAP_BUTTON_SUBTITLE_OFFLINE = "Map scanning is unavailable right now: %s",
	MAP_BUTTON_SUBTITLE_CONNECTING = "Map scanning is setting up. Please wait.",
	MAP_BUTTON_NO_SCAN = "No scan available",
	MAP_BUTTON_SCANNING = "Scanning",
	MAP_SCAN_CHAR = "Scan for characters",
	MAP_SCAN_CHAR_TITLE = "Characters",

	--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
	-- MATURE FILTER
	--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
	MATURE_FILTER_TITLE = "Mature profiles filter",
	MATURE_FILTER_TOOLTIP_WARNING = "Mature content",
	MATURE_FILTER_TOOLTIP_WARNING_SUBTEXT = "This character profile contains mature content. Use the target bar action button to reveal the content if you really want to…",
	MATURE_FILTER_OPTION = "Filter mature profiles",
	MATURE_FILTER_OPTION_TT = [[Check this option to enable mature profile filtering. Total RP 3 will scan incoming profiles when they are received for specific keywords reported as being for a mature audience and flag the profile as mature if it finds such word.

A mature profile will have a muted tooltip and you will have to confirm that you want to view the profile the first time you open it.

|cffccccccNote: The mature filter dictionary is pre-populated with a list of words from a crowd sourced repository. You can edit the words using the option below.|r]],
	MATURE_FILTER_STRENGTH = "Mature filter strength",
	MATURE_FILTER_STRENGTH_TT = [[Set the strength of the mature filter.

|cffcccccc1 is weak (10 bad words required to flag), 10 is strong (only 1 bad word required to flag).|r]],
	MATURE_FILTER_FLAG_PLAYER = "Flag as mature",
	MATURE_FILTER_FLAG_PLAYER_TT = "Flag this profile has containing mature content. The profile content will be hidden.",
	MATURE_FILTER_FLAG_PLAYER_OPTION = "Flag as mature",
	MATURE_FILTER_FLAG_PLAYER_TEXT = [[Confirm that you want to flag %s's profile as containing mature content. This profile content will be hidden.

|cffffff00Optional:|r Indicate the offensive words you found in this profile (separated by a space character) to add them to the filter.]],
	MATURE_FILTER_EDIT_DICTIONARY = "Edit custom dictionary",
	MATURE_FILTER_EDIT_DICTIONARY_TT = "Edit the custom dictionary used to filter mature profiles.",
	MATURE_FILTER_EDIT_DICTIONARY_BUTTON = "Edit",
	MATURE_FILTER_EDIT_DICTIONARY_TITLE = "Custom dictionary editor",
	MATURE_FILTER_EDIT_DICTIONARY_ADD_BUTTON = "Add",
	MATURE_FILTER_EDIT_DICTIONARY_ADD_TEXT = "Add a new word to the dictionary",
	MATURE_FILTER_EDIT_DICTIONARY_EDIT_WORD = [[Edit this word]],
	MATURE_FILTER_EDIT_DICTIONARY_DELETE_WORD = [[Delete the word from the custom dictionary]],
	MATURE_FILTER_EDIT_DICTIONARY_RESET_TITLE = "Reset dictionary",
	MATURE_FILTER_EDIT_DICTIONARY_RESET_BUTTON = "Reset",
	MATURE_FILTER_EDIT_DICTIONARY_RESET_WARNING = "Are you sure you want to reset the dictionary? This will empty the dictionary and fill it with the default words provided for your current language (if available).",
	MATURE_FILTER_WARNING_TITLE = "Mature content",
	MATURE_FILTER_WARNING_CONTINUE = "Continue",
	MATURE_FILTER_WARNING_GO_BACK = "Go back",
	MATURE_FILTER_WARNING_TEXT = [[You have Total RP 3's mature content filtering system enabled.

This profile has been flagged as containing mature content.

Are you sure you want to view this profile?]],
	MATURE_FILTER_ADD_TO_SAFELIST = "Add this profile to the |cffffffffmature safelist|r",
	MATURE_FILTER_ADD_TO_SAFELIST_TT = "Add this profile to the |cffffffffmature safelist|r and reveal the mature content found inside.",
	MATURE_FILTER_ADD_TO_SAFELIST_OPTION = "Add to the |cffffffffmature safelist|r",
	MATURE_FILTER_ADD_TO_SAFELIST_TEXT = [[Confirm that you want to add %s to the |cffffffffmature safelist|r.

The content of their profiles will no longer be hidden.]],
	MATURE_FILTER_REMOVE_FROM_SAFELIST = "Remove this profile from the |cffffffffmature safelist|r",
	MATURE_FILTER_REMOVE_FROM_SAFELIST_TT = "Remove this profile from the |cffffffffmature safelist|r and hide again the mature content found inside.",
	MATURE_FILTER_REMOVE_FROM_SAFELIST_OPTION = "Remove from the |cffffffffmature safelist|r",
	MATURE_FILTER_REMOVE_FROM_SAFELIST_TEXT = [[Confirm that you want to remove %s from the |cffffffffmature safelist|r.

The content of their profiles will be hidden again.]],

	--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
	-- DICE ROLL
	--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

	DICE_ROLL = "%s Rolled |cffff9900%sx d%s|r|cffcc6600%s|r and got |cff00ff00%s|r.",
	DICE_TOTAL = "%s Total of |cff00ff00%s|r for the roll.",
	DICE_HELP = "A dice roll or rolls separated by spaces, example: 1d6, 2d12 3d20 ...",
	DICE_ROLL_T = "%s %s rolled |cffff9900%sx d%s|r|cffcc6600%s|r and got |cff00ff00%s|r.",
	DICE_TOTAL_T = "%s %s got a total of |cff00ff00%s|r for the roll.",

	--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
	-- NPC Speeches
	--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

	NPC_TALK_TITLE = "NPC speeches",
	NPC_TALK_NAME = "NPC name",
	NPC_TALK_NAME_TT = [[You can use standard chat tags like %t to insert your target's name or %f to insert your focus' name.

You can also leave this field empty to create emotes without an NPC name at the start.

Putting your companion name in [brackets] will allow color and icon customization.
]],
	NPC_TALK_MESSAGE = "Message",
	NPC_TALK_CHANNEL = "Channel: ",
	NPC_TALK_SEND = "Send",
	NPC_TALK_ERROR_EMPTY_MESSAGE = "The message cannot be empty.",
	NPC_TALK_COMMAND_HELP = "Open the NPC speeches frame.",
	NPC_TALK_BUTTON_TT = "Open the NPC speeches frame allowing you to do NPC speeches or emotes.",

	--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
	-- MISC
	--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

	PATTERN_ERROR = "Error in pattern.",
	PATTERN_ERROR_TAG = "Error in pattern : unclosed text tag.",
	SCRIPT_UNKNOWN_EFFECT = "Script error, unknown FX",
	SCRIPT_ERROR = "Error in script.",
	NEW_VERSION_TITLE = "New update available",
	NEW_VERSION = "|cff00ff00A new version of Total RP 3 (v %s) is available.\n\n|cffffff00We strongly encourage you to stay up-to-date.|r\n\nThis message will only appear once per session and can be disabled in the settings (General settings => Miscellaneous).",
	BROADCAST_PASSWORD = "|cffff0000There is a password placed on the broadcast channel (%s).\n|cffff9900TRP3 won't try again to connect to it but you won't be able to use some features like players location on map.\n|cff00ff00You can disable or change the broadcast channel in the TRP3 general settings.",
	BROADCAST_PASSWORDED = "|cffff0000The user |r%s|cffff0000 just placed a password on the broadcast channel (%s).\n|cffff9900If you don't know that password, you won't be able to use features like players location on the map.",
	BROADCAST_10 = "|cffff9900You already are in 10 channels. TRP3 won't try again to connect to the broadcast channel but you won't be able to use some features like players location on map.",
	BROADCAST_OFFLINE_DISABLED = "Broadcast has been disabled.",

	--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
	-- CHAT LINKS
	--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

	CL_REQUESTING_DATA = "Requesting link data from %s.",
	CL_EXPIRED = "This link has expired.",
	CL_PLAYER_PROFILE = "Player profile",
	CL_OPEN_PROFILE = "Open profile",
	CL_IMPORT_PROFILE = "Import profile",
	CL_GLANCE = "At-first-glance",
	CL_IMPORT_GLANCE = "Import at-first-glance",
	CL_COMPANION_PROFILE = "Companion profile",
	CL_IMPORT_COMPANION = "Import companion profile",
	CL_OPEN_COMPANION = "Open companion profile",
	CL_VERSIONS_DIFFER = [[This link has been generated using a different version of Total RP 3.

Importing content coming from a different version may cause issues in case of incompatibilities. Do you want to proceed anyway?]],

	--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
	-- COMMANDS
	--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

	COM_LIST = "List of commands:",
	COM_SWITCH_USAGE = "Usage: |cff00ff00/trp3 switch main|r to switch main frame or |cff00ff00/trp3 switch toolbar|r to switch the toolbar.",
	COM_RESET_USAGE = "Usage: |cff00ff00/trp3 reset frames|r to reset all frames positions.",
	COM_RESET_RESET = "The frames positions have been reset!",
	COM_STASH_DATA = [[|cffff0000Are you sure you want to stash away your Total RP 3 data?|r

Your profiles, companions profiles and settings will be temporarily stashed away and your UI will reload with empty data, as if your installation of Total RP 3 was brand new.
|cff00ff00Use the same command again (|cff999999/trp3 stash|cff00ff00) to restore your data.|r]],
	OPTION_ENABLED_TOAST = "Option enabled",
	OPTION_DISABLED_TOAST = "Option disabled",
	MORE_MODULES_2 = [[{h2:c}Optional modules{/h2}
{h3}Total RP 3: Extended{/h3}
|cff9999ffTotal RP 3: Extended|r add the possibility to create new content in WoW: campaigns with quests and dialogues, items, documents (books, signs, contracts, …) and many more!
{link*https://www.curseforge.com/wow/addons/total-rp-3-extended*Download on CurseForge}

{h3}TRP3 Currently Frame{/h3}
Adds a standalone frame to your UI that displays your "Currently" text and allows you to edit it easily.
{link*https://www.curseforge.com/wow/addons/trp3-currently-frame*Download on CurseForge}

{h3}TRP3 Location Toggle{/h3}
Adds a simple button to the toolbar to toggle on and off the map scan location feature.
{link*https://www.curseforge.com/wow/addons/trp3-location-toggle*Download on CurseForge}
]],

	THANK_YOU_1 = [[{h1:c}Total RP 3{/h1}
{p:c}{col:6eff51}Version %s (build %s){/col}{/p}
{p:c}{link*http://totalrp3.info*TotalRP3.info} — {twitter*TotalRP3*@TotalRP3} {/p}
{p:c}{link*http://discord.totalrp3.info*Join us on Discord}{/p}

{h2}{icon:INV_Eng_gizmo1:20} Created by{/h2}
%AUTHORS$s

{h2}{icon:QUEST_KHADGAR:20} The Rest of the Team{/h2}
%CONTRIBUTORS$s

{h2}{icon:THUMBUP:20} Acknowledgements{/h2}
{col:ffffff}Logo and minimap button icon:{/col}
- {link*https://twitter.com/Kelandiir*@Kelandiir}

{col:ffffff}Our pre-alpha QA team:{/col}
%TESTERS$s

{col:ffffff}Thanks to all our friends for their support all these years:{/col}
- For Telkos: Kharess, Kathryl, Marud, Solona, Stretcher, Lisma...
- For Ellypse: The guilds Eglise du Saint Gamon, Maison Celwë'Belore, Mercenaires Atal'ai, and more particularly Erzan, Elenna, Caleb, Siana and Adaeria

{col:ffffff}For helping us creating the Total RP guild on Kirin Tor (EU):{/col}
%GUILD_MEMBERS$s

{col:ffffff}Thanks to Horionne for sending us the magazine Gamer Culte Online #14 with an article about Total RP.{/col}]],

	MO_ADDON_NOT_INSTALLED = "The %s add-on is not installed, custom Total RP 3 integration disabled.",
	MO_TOOLTIP_CUSTOMIZATIONS_DESCRIPTION = "Add custom compatibility for the %s add-on, so that your tooltip preferences are applied to Total RP 3's tooltips.",
	MO_CHAT_CUSTOMIZATIONS_DESCRIPTION = "Add custom compatibility for the %s add-on, so that chat messages and player names are modified by Total RP 3 in that add-on.",
	CO_TOOLTIP_PREFERRED_OOC_INDICATOR = "Preferred OOC indicator",
	CO_TOOLTIP_PREFERRED_OOC_INDICATOR_TEXT = "Text: ",
	CO_TOOLTIP_PREFERRED_OOC_INDICATOR_ICON = "Icon: ",
	PR_EXPORT_WARNING_TITLE = "Warning:",
	PR_EXPORT_WARNING_WINDOWS = [[Please note that some advanced text editing tools like Microsoft Word or Discord will reformat special characters like quotes, altering the content of the data.

If you are planning on copying the text below inside a document, please use simpler text editing tools that do not automatically change characters, like Notepad.]],
	PR_EXPORT_WARNING_MAC = [[Please note that some advanced text editing tools like Text Edit or Discord will reformat special characters like quotes, altering the content of the data.

If you are planning on copying the text below inside a document, please use simpler text editing tools that do not automatically change characters (in Text Edit go to Format > Make Plain Text before pasting)]],
	BW_COLOR_PRESET_TITLE = "Color presets",
	BW_COLOR_PRESET_SAVE = "Save current color",
	BW_COLOR_PRESET_RENAME = "Rename %s preset",
	BW_COLOR_PRESET_DELETE = "Delete %s preset",
	CL_DIRECTORY_PLAYER_PROFILE = "Directory player profile",
	CL_DIRECTORY_COMPANION_PROFILE = "Directory companion profile",
	CL_CONTENT_SIZE = [[Size: %s]],
	THANK_YOU_ROLE_AUTHOR = "Author",
	THANK_YOU_ROLE_CONTRIBUTOR = "Contributor",
	THANK_YOU_ROLE_COMMUNITY_MANAGER = "Community Manager",
	THANK_YOU_ROLE_TESTER = "QA Team",
	THANK_YOU_ROLE_GUILD_MEMBER = "Guild Member",
	CL_SENT_BY = "Link sent by: %s",
	CL_TYPE = "TRP3 Link type: %s",
	CL_MAKE_IMPORTABLE_SIMPLER = [[Make this %s link importable?

People will be able to copy and use the content of the link.]],
	CL_MAKE_IMPORTABLE_BUTTON_TEXT = "Make importable",
	CL_MAKE_NON_IMPORTABLE = "Viewable only",
	CL_TOOLTIP = "Create a chat link",
	CL_DOWNLOADING = "Downloading: %0.1f %%",
	CL_SENDING_COMMAND = "Sending command…",
	CO_UI_RELOAD_WARNING = [[The interface needs to be reloaded in order for the changes to be applied.

Would you like to reload the interface now?]],
	TT_ELVUI_SKIN = "ElvUI skin",
	TT_ELVUI_SKIN_ENABLE_TOOLTIPS = "Skin tooltips",
	TT_ELVUI_SKIN_ENABLE_TARGET_FRAME = "Skin target frame",
	MAP_BUTTON_SUBTITLE_80_DISABLED = "Scans temporarily unavailable due to 8.0 changes",
	CO_ADVANCED_SETTINGS = "Advanced settings",
	CO_ADVANCED_SETTINGS_MENU_NAME = "Advanced",
	CO_ADVANCED_SETTINGS_POPUP = [[You have just modified an advanced setting.

Please keep in mind that changing those settings might alter your experience with the add-on and could prevent some features from working correctly. Use at your own risk.]],
	CO_ADVANCED_SETTINGS_RESET = "Reset advanced settings",
	CO_ADVANCED_SETTINGS_RESET_TT = "Reset all the advanced settings to their default value. Use this if you have issues after modifying the settings.",
	CO_GENERAL_BROADCAST_C = "Broadcast channel name",
	CO_ADVANCED_BROADCAST = "Add-on communications",
	CO_ADVANCED_LANGUAGES = "Languages",
	CO_ADVANCED_LANGUAGES_REMEMBER = "Remember last language used",
	CO_ADVANCED_LANGUAGES_REMEMBER_TT = "Total RP 3 will remember what language you were using before logging off and automatically select this language back on next login.",
	CO_TOOLTIP_CURRENT_LINES = "Max \"Currently\" line breaks",
	REG_PLAYERS = "Players",
	CO_LOCATION_DISABLE_WAR_MODE = "Disable location when in War Mode",
	CO_LOCATION_DISABLE_WAR_MODE_TT = "You will not respond to location requests from other players when you have War Mode enabled and you are outside of a |cff69CCF0Sanctuary|r.\n\nThis option is particularly useful to avoid abuses of the location system to track you.",
	CO_LOCATION_SHOW_DIFFERENT_WAR_MODES = "Show players in different War Mode",
	CO_LOCATION_SHOW_DIFFERENT_WAR_MODES_TT = "Players who are currently in the zone but have a different War Mode status than you will be shown on the map, with a lower opacity and a special icon in the tooltip.",
	REG_LOCATION_DIFFERENT_WAR_MODE = "Different War Mode",
	CO_ADVANCED_BROADCAST_CHANNEL_ALWAYS_LAST = "Keep broadcast channel last",
	CO_ADVANCED_BROADCAST_CHANNEL_ALWAYS_LAST_TT = "This option will make sure that the broadcast channel is always the last channel in your channels list.",
	REG_PLAYER_ABOUT_MUSIC_THEME = "Character music theme",
	REG_PLAYER_EDIT_MUSIC_THEME = "Music theme",
	LANG_CHANGE_CAUSED_REVERT_TO_DEFAULT = "Current spoken language reverted to default %s because you no longer know the previously selected language %s.",
	CO_ADVANCED_LANGUAGE_WORKAROUND = "Enable workaround against language reset",
	CO_ADVANCED_LANGUAGE_WORKAROUND_TT = "Since patch 8.0.1 the game will reset the selected language to the default language for your faction during every loading screen. This workaround makes sure to restore the selected language after a loading screen.",

	REG_REPORT_PLAYER_PROFILE = "Report profile to |cff449fe0Blizzard|r",
	REG_REPORT_PLAYER_PROFILE_TT = [[You can report a profile that infringe on Blizzard's Terms of Service. This can include harassment, doxxing, hate speech, obscene content or other form of disruptive content.

|cffff0000Please note that this option is NOT to report RP profiles of disputable quality or griefing. Abuses of this feature are punishable!]],
	REG_REPORT_PLAYER_TEMPLATE = "This player is using the RP profile addon %s to share content against the Terms of Service.",
	REG_REPORT_PLAYER_TEMPLATE_DATE = "The addon data was transferred through logged addon messages on %s.",
	REG_REPORT_PLAYER_TEMPLATE_TRIAL_ACCOUNT = "This player was on a trial account.",
	REG_REPORT_PLAYER_OPEN_URL = [[You can only report players directly from within the game if you can target them (use TRP3's target frame button).

If you wish to report %s's profile and you cannot target them you will need to open a ticket with Blizzard's support using the link bellow.]],
	REG_REPORT_PLAYER_OPEN_URL_160 = [[If you wish to report %s's profile, you will need to open a ticket with Blizzard's support using the link below.]],
	NEW_VERSION_BEHIND = "You are currently %s versions behind and are missing on many bug fixes and new features. Other players might not be able to see your profile correctly. Please consider updating the add-on.",
	REG_PLAYER_RELATIONSHIP_STATUS_UNKNOWN = "Do not show",
	REG_PLAYER_RELATIONSHIP_STATUS_SINGLE = "Single",
	REG_PLAYER_RELATIONSHIP_STATUS_TAKEN = "Taken",
	REG_PLAYER_RELATIONSHIP_STATUS_MARRIED = "Married",
	REG_PLAYER_RELATIONSHIP_STATUS_DIVORCED = "Divorced",
	REG_PLAYER_RELATIONSHIP_STATUS_WIDOWED = "Widowed",
	REG_PLAYER_RELATIONSHIP_STATUS = "Relationship status",
	REG_PLAYER_RELATIONSHIP_STATUS_TT = [[Indicate the relationship status of your character. Select "Do not show" if you wish to keep that information hidden.]],
	REG_NOTES_PROFILE = "Notes",
	REG_NOTES_PROFILE_TT = "Open the notes window for the target character.",
	REG_PLAYER_NOTES = "Notes",
	REG_PLAYER_NOTES_PROFILE = "Notes from %s",
	REG_PLAYER_NOTES_PROFILE_NONAME = "Profile notes",
	REG_PLAYER_NOTES_PROFILE_HELP = "These private notes are tied to your current profile and will change based on what profile you currently have active.",
	REG_PLAYER_NOTES_ACCOUNT = "Common notes",
	REG_PLAYER_NOTES_ACCOUNT_HELP = "These private notes are tied to your account and will be shared with all of your profiles.",
	REG_PLAYER_NOTES_DM = "DM Notes - these notes get saved to the phase",
	REG_PLAYER_NOTES_PHASE = "Phase Notes - these notes are what you last saw in the phase profile",
	---@language Markdown
	WHATS_NEW_23_4 = [[
# Changelog version 1.6.4

We are aware of a current issue on Retail causing **quest item usage from the objective tracker** to sometimes fail. While we do not have a fix for it just yet, **typing /reload after getting the error message** temporarily fixes the issue. Sorry for the inconvenience.

## WoW: Classic support

- Total RP 3: Classic is now available as a separate download on CurseForge and WoWInterface! Be sure to install it instead of the retail version of Total RP 3 if you plan on roleplaying in WoW: Classic.
- Important points to be aware of for the Classic version:
  - A few icons have been changed across the addon to replace missing icons in Classic.
  - Companion profiles have been disabled for mounts and non-combat pets, as Blizzard did not provide us with beta access. We will work on implementing them back as soon as possible.
  - Total RP 3: Extended will not be ported to Classic at launch. We will be evaluating if a Classic port makes sense for us to do at a later date.

## Changed

- When using the character map scan, characters with which you have set a relationship will now appear on top of the others.

]],

	---@language Markdown
	WHATS_NEW_23_5 = [[
# Changelog version 1.6.5

## Added

- Added Total RP 3: Extended version number alongside Total RP 3 version number at the bottom of the tooltip.

## Fixed

- Fixed an error when someone executes a scan in your zone. (Classic only)
- Fixed a potential error when saving a glance slot.

]],

	---@language Markdown
	WHATS_NEW_23_6 = [[
# Changelog version 1.6.6

## Added

- Added slash commands to change your roleplay status, which you can use in macros. You can now use `/trp3 status ic` to get in character, `/trp3 status ooc` to get out of character, or `/trp3 status toggle` to switch status.
- Added a chat setting to display the OOC indicator next to the name in chat.
- Added a setting to hide the map scan button if no scan is available.
- Added a roleplay language field to the main dashboard.
  - This setting is profile-based, defaults to your addon language, and allows you to indicate the language you're roleplaying in.
  - If your addon language doesn't match a player's roleplaying language, you'll see a flag at the bottom of their tooltip indicating their roleplaying language.
  - This change is mainly aimed at Classic roleplayers, as only English RP realms were made.
- Added back buttons to toggle helmet and cloak display for Classic.

## Changed

- Renamed the war mode setting to PvP mode for Classic.

## Fixed

- Fixed issues when the target bar module was disabled.
- Fixed an issue causing duplicate Mary-Sue Protocol profiles to appear in the register when unchecking "This realm only".
- Fixed a few remaining missing icons for Classic (default template 3 icons and `/trp3 roll` icons)
- Fixed an issue when using the "Right-click to open profile" setting on Classic.

]],
	CO_CHAT_MAIN_SPEECH = "Speech detection",
	CO_CHAT_MAIN_SPEECH_USE = "Use speech detection",
	CO_CHAT_MAIN_SPEECH_USE_TT = "Text surrounded by quotation marks will be colored as if written in /say.",

	---@language Markdown
	WHATS_NEW_23_7 = [[
# Changelog version 1.6.7

## Added

- Added a setting to detect speech in emotes and automatically color it.
- Added 7 icons and 1 music from patch 8.2.5.

## Changed

- The companion profiles list accessed through the target frame is now alphabetically sorted, and "Create new profile" has been moved out of it.

]],
	---@language Markdown
	WHATS_NEW_23_8 = [[
# Changelog version 1.6.8

## Changed

- **Classic:** Due to 1.13.3 API changes, the map scan has been modified to find characters in yell range only. It will only show on the map you're in. **Only characters using Total RP 3 version 1.6.8 will be visible on the scan.**

*Reminder : You can disable your scan appearance by unchecking "Register settings > Location settings > Enable character location. Please don't hold on the update for visibility reasons.*

- Speech detection will now only apply to emotes (including NPC emotes).

## Fixed

- Fixed a rare issue where the addon loading process would be interrupted by a setting key unable to be read.

]],
	---@language Markdown
	WHATS_NEW_23_9 = [[
# Changelog version 1.6.9

## Added

- Added 61 musics, 5 images and 223 icons on Retail from patch 8.3.
- Added 177 images on Retail from previous patches.
- Added 1 icon on Classic from patch 1.13.3.
- Added default icons for Vulperas and Mechagnomes.

## Changed

- Changed default Kul Tiran female icon.

## Fixed

- Added workaround to Classic map scan to handle Blizzard's lack of tests.
- Fixed an issue when trying to use icons with an apostrophe in their name.
- Image browser filter now correctly handles some special characters.

]],
	---@language Markdown
	WHATS_NEW_23_10 = [[
# Changelog version 1.6.10

## Added

- Added %xt and %xf chat tokens. These will automatically be replaced by the RP name of your target and focus respectively when sending a message.
- Added settings to adjust About font sizes.

]],
	WHATS_NEW_23_11 = [[
	# Changelog version 1.6.11

## Added

- Added new chat tokens for first and last names: %xtf (Target's first name), %xtl (Target's last name), %xff (Focus' first name), %xfl (Focus' last name).

## Fixed

- Fixed an issue when trying to add a chat link to an empty chatbox.
- Fixed a compatibility issue with PallyPower.

]],
	WHATS_NEW_23_12 = [[
# Changelog version 1.6.12

## Fixed

- Tentatively fixed an issue with tooltip lines.
- Fixed an issue with the residence button on Classic.

]],
	WHATS_NEW_23_13 =  [[# Changelog version 1.6.13

## Fixed

- Fixed an issue with upgrade patches that would happen only for people with a clean install of the add-on. - #407

]],
	WHATS_NEW_24_1 =  [[# Changelog version 2.0

## Added

- Added a default profile.
  - This profile cannot be modified and only contains basic character information (name, race, class).
  - New characters will now be bound to the default profile instead of creating a new one automatically.
  - A new profile is still required to add custom information.

- Added a search bar in the character and companion profiles lists.

## Fixed

- Fixed a conflict between OOC detection and Russian declensions.
- Fixed an issue related to Prat + WIM chat history.

## Changed

- Removed a personality trait preset.
- Improved communication protocol to reduce profile transfer size.
- Various compatibility changes related to 9.0 API modifications.

]],

	BINDING_NAME_TRP3_OPEN_TARGET_PROFILE = "Open target profile",
	BINDING_NAME_TRP3_TOGGLE_CHARACTER_STATUS = "Toggle character status",
	WHATS_NEW_24_2 =  [[# Changelog version 2.1

## Added

- Added 113 images, 1437 icons and 613 musics from patch 9.0.
- Added modifier to the dice roll output text.
- Added keybinding options for opening the target profile and toggling RP status.

## Fixed

- Fixed an issue with the default tooltip appearing sometimes despite "Hide original tooltip" setting being checked.
- Fixed an issue with the TRP3 tooltip being offset while the default tooltip is hidden.
- Fixed an issue with the TRP3 tooltip briefly overlapping the default tooltip if quickly hovering from a player to a spell/item.
- Fixed an issue when trying to open the Prat modules window while TRP3 is running.
- Fixed a display issue with the NPC speech frame background.
- Fixed alphabetical sorting when hovering a cluster of players in the map scan.
- Potential fix for the guide channel being swapped with the xtensionxtooltip2 channel.

]],

	REG_COMPANION_BIND_TO_PET = "Pet",
	UI_PET_BROWSER_ACCEPT = "Assign",
	UI_PET_BROWSER_EMPTY_TEXT = "You have no pets that can be assigned a profile.",
	UI_PET_BROWSER_INTRO_TEXT = "Select a pet with the buttons below and click |cffffff00Assign|r to bind it to the profile.",
	UI_PET_BROWSER_BOUND_WARNING = "|cffff0000Warning: |rThis pet is currently assigned to the profile |cff00ff00%1$s|r. Assigning a profile to this pet will replace the current profile.",
	UI_PET_BROWSER_NAME_WARNING = "|cffff0000Warning: |rThis pet has not been renamed. We recommend renaming the pet to prevent showing this profile on other pets you own with the same name.",
	REG_PLAYER_MISC_PRESET_PRONOUNS = "Pronouns",
	WHATS_NEW_24_3 =  [[# Changelog version 2.2

## Added

- Added Pronouns preset in Additional information. When using this preset, the pronouns will be shown on your tooltip.
- Added support for companion profiles on the secondary pet summoned with the hunter talent Animal Companion.
- Added a hunter pet browser when binding a companion profile through the profile list.

## Fixed

- Fixed chat link tooltips being invisible when first opening one.
- Fixed formatting issues with chat links.
- Fixed an issue causing the battle pet browser to show an incomplete list if the battle pet collection had search filters applied.
- Fixed invalid icons in the About tab when receiving a profile from other RP addons on Classic.
- Fixed incorrect information on the tooltip of the NPC speech prefix setting.
- Fixed an issue with Tukui chat history.

]],
	WHATS_NEW_24_4 = [[# Changelog version 2.3

## Added

- Added a module to customize nameplates with RP information. At present, **only default Blizzard nameplates and KuiNameplates** are supported.

*As it is now redundant, the TRP3: KuiNameplates module will now disable itself and should be uninstalled.*

- Added support for companion profiles in Classic.
- Added entries on unit frames right-click menu to open profile + change roleplay status.
- Added a window to copy character names linked to a profile when right-clicking it in the directory list.
- Added an option to disable profile tooltips in instances.

## Changed

- The URL copy window now closes after pressing the copy shortcut.
- The default profile no longer shows the amount of characters bound to it.
- Cropped characteristic fields will now show a tooltip on hover with the full content of the field.
- The description editor will now receive input focus after clicking any formatting tool button.
- Customized names in chat frames that have excessively large lengths will now be cropped.
- Custom colors for personality traits now apply to attribute names.

## Fixed

- Fixed an issue with chat customization not properly registering on login while using Prat.
- Fixed missing sound cue when opening/closing the main window.
- Fixed an issue that could cause PvP flagged players to show their location on map scans in Classic.
- Fixed missing vulpera language icon.

]],
	WHATS_NEW_24_5 = [[# Changelog version 2.3.2

## Added

- Added settings for right-click options on unit frames and chat names.

## Fixed

- Fixed incorrect names showing up on Blizzard NPC nameplates.
- Fixed display issue with KuiNameplates tank mode.
- Fixed a dependency issue preventing chat customization from working when using Prat and Listener.
- Fixed localization not being properly applied to various settings.

]],
	WHATS_NEW_24_6 = [[# Changelog version 2.3.3

## Added
- Added tooltip fields for character zone and health. These fields can be toggled in Tooltip settings.
  - The zone field will only show when the character is in another zone (if looking at a party member for instance).
  - The health field will only show if the character is not full health. It is disabled by default.

## Fixed
- Fixed a few issues with profile transfer.
- Fixed Kui name-only RP nameplates not updating when level text and health were both disabled.
- Fixed inability to set a pet profile when the pet is first summoned.
- Fixed TRP tooltip overlapping with the main tooltip if the profile has been caught by the mature filter.
- Fixed TRP chat links breaking from emote/OOC/speech detection.
- Fixed Currently/OOC fields not properly hiding on tooltips if they only contained whitespaces.

]],
	COPY_DROPDOWN_POPUP_TEXT = "Copy with %1$s. Paste with %2$s.\nThis frame will close upon copy.",
	COPY_SYSTEM_MESSAGE = "Copied to clipboard.",
	UNIT_POPUPS_MODULE_NAME = "Unit Popups",
	UNIT_POPUPS_MODULE_DESCRIPTION = "Adds integration with right-click menus on unit frames and player names in chat frames.",
	UNIT_POPUPS_ROLEPLAY_OPTIONS_HEADER = "Roleplay Options",
    UNIT_POPUPS_OPEN_PROFILE = "Open Profile",
	UNIT_POPUPS_ASSIGN_FLAG = "Assign Profile",
	UNIT_POPUPS_CURRENT_PROFILE = "Current Profile",
	UNIT_POPUPS_CURRENT_PROFILE_NAME = "Current Profile: %1$s",
	UNIT_POPUPS_CHARACTER_STATUS = "Character Status",
	UNIT_POPUPS_CONFIG_MENU_TITLE = "Menu settings",
	UNIT_POPUPS_CONFIG_PAGE_TEXT = "Menu settings",
	UNIT_POPUPS_CONFIG_PAGE_HELP = "The unit popups module adds additional entries to the right-click menus found on unit frames and names in the chat frame.",
	UNIT_POPUPS_CONFIG_ENABLE_MODULE = "Module |cff00ff00enabled|r",
	UNIT_POPUPS_MODULE_DISABLE_WARNING = "A user interface reload is required to disable the unit popups module.|n|n|cffff0000Warning: |rOnce disabled, this module can only be re-enabled from the |cffffcc00Modules status|r page.|n|nAre you sure you want to disable this module?",
	UNIT_POPUPS_CONFIG_ENTRIES_HEADER = "Menu entries",
	UNIT_POPUPS_CONFIG_SHOW_HEADER_TEXT = "Show header text",
	UNIT_POPUPS_CONFIG_SHOW_HEADER_TEXT_HELP = "If checked, shows a \"Roleplay Options\" header above any added menu entries.",
	UNIT_POPUPS_CONFIG_SHOW_SEPARATOR = "Show separator",
	UNIT_POPUPS_CONFIG_SHOW_SEPARATOR_HELP = "If checked, shows a separator bar above any added menu entries.",
	UNIT_POPUPS_CONFIG_SHOW_CHARACTER_STATUS = "Show character status toggle",
	UNIT_POPUPS_CONFIG_SHOW_CHARACTER_STATUS_HELP = "If checked, adds a checkbox to your own unit frame menu that allows you to toggle your in-character/out-of-character status.",
	UNIT_POPUPS_CONFIG_SHOW_OPEN_PROFILE = "Show open profile button",
	UNIT_POPUPS_CONFIG_SHOW_OPEN_PROFILE_HELP = "If checked, adds a button that opens the selected units' RP profile when clicked.|n|nThis option will be visible on all unit frame and chat menus.",
	UNIT_POPUPS_CONFIG_VISIBILITY_HEADER = "Visibility options",
	UNIT_POPUPS_CONFIG_DISABLE_OUT_OF_CHARACTER = "Hide menu entries while out of character",
	UNIT_POPUPS_CONFIG_DISABLE_OUT_OF_CHARACTER_HELP = "If checked, additional menu entries will not be shown while out-of-character.",
	UNIT_POPUPS_CONFIG_DISABLE_IN_COMBAT = "Hide menu entries while in combat",
	UNIT_POPUPS_CONFIG_DISABLE_IN_COMBAT_HELP = "If checked, additional menu entries will not be shown while in combat.",
	UNIT_POPUPS_CONFIG_DISABLE_IN_INSTANCES = "Hide menu entries while in instances",
	UNIT_POPUPS_CONFIG_DISABLE_IN_INSTANCES_HELP = "If checked, additional menu entries will not be shown while in instanced content.",
	UNIT_POPUPS_CONFIG_DISABLE_ON_UNIT_FRAMES = "Hide menu entries on unit frames",
	UNIT_POPUPS_CONFIG_DISABLE_ON_UNIT_FRAMES_HELP = "If checked, additional menu entries will not be shown in menus activated by right-clicking unit frames.",

	NAMEPLATES_MODULE_NAME = "Nameplates",
	NAMEPLATES_MODULE_DESCRIPTION = "Enables the customization of nameplates with information obtained from roleplay profiles.",
	NAMEPLATES_MODULE_DISABLED_BY_EXTERNAL = "This module was disabled automatically due to a conflict with another module or addon.",
	NAMEPLATES_MODULE_DISABLED_BY_DEPENDENCY = "This module was disabled automatically due to a missing dependency.",

	NAMEPLATES_CONFIG_MENU_TITLE = "Nameplates",
	NAMEPLATES_CONFIG_PAGE_TEXT = "Nameplate settings",
	NAMEPLATES_CONFIG_PAGE_HELP = "Please note that only |cff449fe0Blizzard|r and |cff9966ffKui|r nameplates are currently supported. Refer to the help tip on each setting below for additional information.",
	NAMEPLATES_CONFIG_VISIBILITY_HEADER = "Visibility settings",
	NAMEPLATES_CONFIG_DISABLE_IN_COMBAT = "Disable customizations when in combat",
	NAMEPLATES_CONFIG_DISABLE_IN_COMBAT_HELP = "If checked, disables nameplate customizations while you are in combat.",
	NAMEPLATES_CONFIG_DISABLE_OUT_OF_CHARACTER = "Disable customizations when OOC",
	NAMEPLATES_CONFIG_DISABLE_OUT_OF_CHARACTER_HELP = "If checked, disables all nameplate customizations while you are out of character.",
	NAMEPLATES_CONFIG_DISABLE_OUT_OF_CHARACTER_UNITS = "Disable customizations on OOC units",
	NAMEPLATES_CONFIG_DISABLE_OUT_OF_CHARACTER_UNITS_HELP = "If checked, disables nameplate customizations on units that are out of character.",
	NAMEPLATES_CONFIG_HIDE_NON_ROLEPLAY_UNITS = "Hide non-roleplay units",
	NAMEPLATES_CONFIG_HIDE_NON_ROLEPLAY_UNITS_HELP = "If checked, hides the nameplates of player and companion units that do not have roleplay profiles.",
	NAMEPLATES_CONFIG_HIDE_OUT_OF_CHARACTER_UNITS = "Hide out of character units",
	NAMEPLATES_CONFIG_HIDE_OUT_OF_CHARACTER_UNITS_HELP = "If checked, hides the nameplates of units that are currently out of character.",
	NAMEPLATES_CONFIG_ELEMENT_HEADER = "Customization settings",
	NAMEPLATES_CONFIG_CUSTOMIZE_NAMES = "Show custom names",
	NAMEPLATES_CONFIG_CUSTOMIZE_NAMES_HELP = "If checked, replaces the name shown on nameplates.",
	NAMEPLATES_CONFIG_CUSTOMIZE_NAME_COLORS = "Show custom name colors",
	NAMEPLATES_CONFIG_CUSTOMIZE_NAME_COLORS_HELP = "If checked, overrides the color of name texts with the class color of a units' profile.",
	NAMEPLATES_CONFIG_CUSTOMIZE_HEALTH_COLORS = "Show custom health colors",
	NAMEPLATES_CONFIG_CUSTOMIZE_HEALTH_COLORS_HELP = "If checked, overrides the color of health bars with the class color of a units' profile.",
	NAMEPLATES_CONFIG_CUSTOMIZE_TITLES = "Show prefix titles",
	NAMEPLATES_CONFIG_CUSTOMIZE_TITLES_HELP = "If checked, shows the short title of a unit on nameplates before their name.",
	NAMEPLATES_CONFIG_CUSTOMIZE_FULL_TITLES = "Show full length titles",
	NAMEPLATES_CONFIG_CUSTOMIZE_FULL_TITLES_HELP = "If checked, shows the full title of a unit on nameplates.|n|nFor |cff449fe0Blizzard|r and |cff9966ffKui|r nameplates, full titles are only shown in name-only mode.",
	NAMEPLATES_CONFIG_CUSTOMIZE_ROLEPLAY_STATUS = "Show roleplay status indicator",
	NAMEPLATES_CONFIG_CUSTOMIZE_ROLEPLAY_STATUS_HELP = "If checked, shows an indicator of a units' roleplay status (IC or OOC) on nameplates.",
	NAMEPLATES_CONFIG_CUSTOMIZE_ICONS = "Show icons",
	NAMEPLATES_CONFIG_CUSTOMIZE_ICONS_HELP = "If checked, shows profile icons on nameplates.",
	NAMEPLATES_CONFIG_ICON_SIZE = "Icon size",
	NAMEPLATES_CONFIG_ICON_SIZE_HELP = "Configures the size of icons displayed on nameplates if the |cffffff00Show icons|r option is enabled.",
	NAMEPLATES_CONFIG_ACTIVE_QUERY = "Automatically fetch profiles",
	NAMEPLATES_CONFIG_ACTIVE_QUERY_HELP = "If checked, automatically fetches roleplay profiles for units with nameplates attached.",
	NAMEPLATES_CONFIG_ENABLE_CLASS_COLOR_FALLBACK = "Use class color by default",
	NAMEPLATES_CONFIG_ENABLE_CLASS_COLOR_FALLBACK_HELP = "If checked, this enables the use of class colors for names and health bars as a fallback for units that do not have a custom class color in their profile.|n|nUnits that do not have roleplay profiles are unaffected by this setting and will not be class-colored.",
	NAMEPLATES_CONFIG_BLIZZARD_NAME_ONLY = "Hide bars on |cff449fe0Blizzard|r nameplates",
	NAMEPLATES_CONFIG_BLIZZARD_NAME_ONLY_HELP = "If checked, this enables the use of name-only mode for |cff449fe0Blizzard|r nameplates.|n|nIn this mode, all nameplates will have their health bars hidden, including those of enemy units and other players with or without roleplay profiles.|n|nThis option requires a UI reload to take effect.",

	NAMEPLATES_MODULE_DISABLE_WARNING = "Disabling the nameplates module will prevent any nameplate customizations from being made. A user interface reload is required for this to take effect.|n|n|cffff0000Warning: |rOnce disabled, this module can only be re-enabled from the |cffffcc00Modules status|r page.|n|nAre you sure you want to disable this module?",
	NAMEPLATES_MODULE_ACTIVE_STATUS = "Module |cff00ff00active|r (%1$s|r)",
	NAMEPLATES_MODULE_INACTIVE_STATUS = "Module |cffff9900inactive|r (no addon found)",

	BLIZZARD_NAMEPLATES_MODULE_NAME = "Blizzard Nameplates",
	BLIZZARD_NAMEPLATES_MODULE_DESCRIPTION = "Enables the customization of Blizzard's default nameplates.",

	KUI_NAMEPLATES_MODULE_NAME = "Kui Nameplates",
	KUI_NAMEPLATES_MODULE_DESCRIPTION = "Enables the customization of Kui nameplates.",
	KUI_NAMEPLATES_WARN_OUTDATED_MODULE = "The Kui |cff9966ffNameplates|r plugin for Total RP 3 has been integrated directly into the main addon.|n|nThe old plugin has been disabled automatically, and |cffffcc00we recommend that you uninstall it|r as it is no longer needed.",

	CONFIG_COMMS_SETTINGS_HEADER = "Communications settings",
	CONFIG_COMMS_QUEUE_POOL_COUNT = "Queue pool size",
	CONFIG_COMMS_QUEUE_POOL_COUNT_DESCRIPTION = "Controls the size of the queue pool used for profile communications.|n|nLower values will reduce latency of addon communications for non-RP profile data, but may increase the amount of time before other players begin to receive any profile data at all in high load scenarios.",
	CONFIG_COMMS_QUEUE_POOL_WEIGHT_THRESHOLD = "Queue pool data weight threshold",
	CONFIG_COMMS_QUEUE_POOL_WEIGHT_THRESHOLD_DESCRIPTION = "Controls the minimum weight your RP profile data must be before queue pools will be used.|n|nFor larger profiles, increasing this value may |cffff0000severely deteriorate|r the performance of all addon communications.",

	CREDITS_THANK_YOU_SECTION_1 = [[{h1:c}Total RP 3{/h1}]],
	CREDITS_THANK_YOU_SECTION_2 = [[{h2}%1$s Created by{/h2}]],
	CREDITS_THANK_YOU_SECTION_3 = [[{h2}%1$s The Rest of the Team{/h2}]],
	CREDITS_THANK_YOU_SECTION_4 = [[{h2}%1$s Acknowledgements{/h2}]],
	CREDITS_THANK_YOU_SECTION_5 = [[{col:ffffff}Logo and minimap button icon:{/col} %1$s]],
	CREDITS_THANK_YOU_SECTION_6 = [[{col:ffffff}Our pre-alpha QA team:{/col}]],
	CREDITS_THANK_YOU_SECTION_7 = [[{col:ffffff}Thanks to all our friends for their support all these years:{/col}]],
	CREDITS_THANK_YOU_SECTION_8 = [[{col:ffffff}For helping us creating the Total RP guild on Kirin Tor (EU):{/col}]],
	CREDITS_THANK_YOU_SECTION_9 = [[{col:ffffff}Thanks to Horionne for sending us the magazine Gamer Culte Online #14 with an article about Total RP.{/col}]],
	CREDITS_THANK_YOU_SECTION_10 = [[{col:ffffff}Thanks to our active community members on Discord:{/col}]],
	CREDITS_THANK_YOU_SECTION_11 = [[{col:ffffff}Thanks to Bor Blasthammer for his help during BfA testing.{/col}]],

	CREDITS_THANK_YOU_ROLE_1 = "Project Lead",
	CREDITS_THANK_YOU_ROLE_2 = "Author",
	CREDITS_THANK_YOU_ROLE_3 = "Developer",
	CREDITS_THANK_YOU_ROLE_4 = "Community Manager",
	CREDITS_THANK_YOU_ROLE_5 = "Mascot",

	CREDITS_VERSION_TEXT = "Version %s",
	CREDITS_DISCORD_LINK_TEXT = "Join us on Discord",
	CREDITS_WEBSITE_LINK_TEXT = "Website",
	CREDITS_NAME_WITH_ROLE = "%1$s (%2$s)",
	CREDITS_GUILD_NAME = "<%1$s>",


	WHATS_NEW_24_7 = [[# Changelog version 2.3.4

## Fixed

- Fixed an issue with links in brackets displaying incorrectly in chat while using ElvUI.

]],
	WHATS_NEW_24_8 = [[# Changelog version 2.3.5

## Added

- Added support for Burning Crusade Classic.

## Fixed

- Fixed several performance issues when requesting character profiles.

	]],
	WHATS_NEW_24_9 = [[# Changelog version 2.3.6

## Added

- Added 323 new icons, 7 images and 138 new music files from patch 9.1.0.

## Removed

- Removed the roleplay language flag.
- Fixed a bug with chat channels on Classic.

	]],
	WHATS_NEW_24_10 = [[# Changelog version 2.3.7

This version is updated for TBC Classic 2.5.2.

# Fixed

- 9.1 icons and musics have been properly added for retail.
- Fixed an issue with TRP3: Extended creation exchange failing in very specific cases.

]],
	WHATS_NEW_24_11 = [[# Changelog version 2.3.9

## Added

- Added 32 icons and 7 music files from patch 9.1.5, 21 icons from Burning Crusade Classic and 2 icons from Classic Era.

## Fixed

- Fixed an issue with the character scan tooltips not showing since patch 9.1.5.

]],
	WHATS_NEW_24_12 = [[# Changelog version 2.3.11

With the recent changes of patch 9.2.5, profiles can now be seen cross-faction for players in your party, or with whom you share a cross-faction WoW community.

## Added

- Added 3 icons and 4 music files from patch 9.2.5.
- Surrounding link tags with color tags will now apply the color to the link.

## Fixed

- Fixed the target frame not having the proper skin when using ElvUI.

]],
	WHATS_NEW_24_13 = [[# Changelog version 2.3.12

Classic users: Companion profiles may have to be relinked due to API changes.

## Added

- Added settings to change the colors you see for other players' tooltips.
- Added 5 new music files from patch 9.2.7, as well as data for WotLK Classic.
- Added macro conditionals support for the "/trp3 profile" command.
- Added a tooltip to view settings texts in full even if they are too long.
- Added Evoker class color preset to the color picker.

## Fixed

- Fixed an issue with tooltip color rendering when using some Unicode characters.
- Fixed inconsistent linebreaks in Template 1.
- Removed some unwanted modifications in profiles.
- Fixed a potential crash when reordering miscellaneous information lines.
- Added a delay before joining the broadcast channel to reduce issues with chat channels swapping numbers/colors.
- Fixed dead links in "About Total RP 3".

]],

	------------------------------------------------------------------------------------------------
	--- PLACE LOCALIZATION NOT ALREADY UPLOADED TO CURSEFORGE HERE
	--- THEN MOVE IT UP ONCE IMPORTED
	------------------------------------------------------------------------------------------------

	WHATS_NEW_24_14 = [[# Changelog version 2.3.13

	## Fixed

		- Fixed missing death knight icons on Classic WotLK.
		- Fixed some more profile modifications.

]],

};

-- Use Ellyb to generate the Localization system
TRP3_API.loc = Ellyb.Localization(TRP3_API.loc);

-- Register all locales into the localization system
-- Note the localeContent is filled by the publishing script using CurseForge's localization tool when packaging builds
-- See https://wow.curseforge.com/projects/total-rp-3/localization
---@type table<string, string>
local localeContent = {};

localeContent = {
	["ABOUT_TITLE"] = "About",
	["BINDING_NAME_TRP3_OPEN_TARGET_PROFILE"] = "Open target profile",
	["BINDING_NAME_TRP3_TOGGLE"] = "Toggle main frame",
	["BINDING_NAME_TRP3_TOGGLE_CHARACTER_STATUS"] = "Toggle character status",
	["BINDING_NAME_TRP3_TOOLBAR_TOGGLE"] = "Toggle toolbar",
	["BLIZZARD_NAMEPLATES_MODULE_DESCRIPTION"] = "Enables the customization of Blizzard's default nameplates.",
	["BLIZZARD_NAMEPLATES_MODULE_NAME"] = "Blizzard Nameplates",
	["BROADCAST_10"] = "|cffff9900You already are in 10 channels. TRP3 won't try again to connect to the broadcast channel but you won't be able to use some features like players location on map.",
	["BROADCAST_OFFLINE_DISABLED"] = "Broadcast has been disabled.",
	["BROADCAST_PASSWORD"] = [=[|cffff0000There is a password placed on the broadcast channel (%s).
|cffff9900TRP3 won't try again to connect to it but you won't be able to use some features like players location on map.
|cff00ff00You can disable or change the broadcast channel in the TRP3 general settings.]=],
	["BROADCAST_PASSWORDED"] = [=[|cffff0000The user |r%s|cffff0000 just placed a password on the broadcast channel (%s).
|cffff9900If you don't know that password, you won't be able to use features like players location on the map.]=],
	["BW_COLOR_CODE"] = "Color code",
	["BW_COLOR_CODE_ALERT"] = "Wrong hexadecimal code !",
	["BW_COLOR_CODE_TT"] = "You can paste a 6 figures hexadecimal color code here and press Enter.",
	["BW_COLOR_PRESET_DELETE"] = "Delete %s preset",
	["BW_COLOR_PRESET_RENAME"] = "Rename %s preset",
	["BW_COLOR_PRESET_SAVE"] = "Save current color",
	["BW_COLOR_PRESET_TITLE"] = "Color presets",
	["BW_CUSTOM_NAME"] = "Custom color name",
	["BW_CUSTOM_NAME_TITLE"] = "Name (Optional)",
	["BW_CUSTOM_NAME_TT"] = "You can set a name for the custom color you're saving. If left empty, it will use the hexadecimal color code.",
	["CL_COMPANION_PROFILE"] = "Companion profile",
	["CL_CONTENT_SIZE"] = "Size: %s",
	["CL_DIRECTORY_COMPANION_PROFILE"] = "Directory companion profile",
	["CL_DIRECTORY_PLAYER_PROFILE"] = "Directory player profile",
	["CL_DOWNLOADING"] = "Downloading: %0.1f %%",
	["CL_EXPIRED"] = "This link has expired.",
	["CL_GLANCE"] = "At-first-glance",
	["CL_IMPORT_COMPANION"] = "Import companion profile",
	["CL_IMPORT_GLANCE"] = "Import at-first-glance",
	["CL_IMPORT_PROFILE"] = "Import profile",
	["CL_MAKE_IMPORTABLE"] = "Make importable",
	["CL_MAKE_IMPORTABLE_BUTTON_TEXT"] = "Make importable",
	["CL_MAKE_IMPORTABLE_SIMPLER"] = [=[Make this %s link importable?

People will be able to copy and use the content of the link.]=],
	["CL_MAKE_NON_IMPORTABLE"] = "Viewable only",
	["CL_OPEN_COMPANION"] = "Open companion profile",
	["CL_OPEN_PROFILE"] = "Open profile",
	["CL_PLAYER_PROFILE"] = "Player profile",
	["CL_REQUESTING_DATA"] = "Requesting link data from %s.",
	["CL_SENDING_COMMAND"] = "Sending command…",
	["CL_SENT_BY"] = "Link sent by: %s",
	["CL_TOOLTIP"] = "Create a chat link",
	["CL_TYPE"] = "TRP3 Link type: %s",
	["CL_VERSIONS_DIFFER"] = [=[This link has been generated using a different version of Total RP 3.

Importing content coming from a different version may cause issues in case of incompatibilities. Do you want to proceed anyway?]=],
	["CM_ACTIONS"] = "Actions",
	["CM_ALT"] = "Alt",
	["CM_APPLY"] = "Apply",
	["CM_BLACK"] = "Black",
	["CM_BLUE"] = "Blue",
	["CM_CANCEL"] = "Cancel",
	["CM_CENTER"] = "Center",
	["CM_CLASS_DEATHKNIGHT"] = "Death Knight",
	["CM_CLASS_DEMONHUNTER"] = "Demon Hunter",
	["CM_CLASS_DRUID"] = "Druid",
	["CM_CLASS_EVOKER"] = "Evoker",
	["CM_CLASS_HUNTER"] = "Hunter",
	["CM_CLASS_MAGE"] = "Mage",
	["CM_CLASS_MONK"] = "Monk",
	["CM_CLASS_PALADIN"] = "Paladin",
	["CM_CLASS_PRIEST"] = "Priest",
	["CM_CLASS_ROGUE"] = "Rogue",
	["CM_CLASS_SHAMAN"] = "Shaman",
	["CM_CLASS_UNKNOWN"] = "Unknown",
	["CM_CLASS_WARLOCK"] = "Warlock",
	["CM_CLASS_WARRIOR"] = "Warrior",
	["CM_CLICK"] = "Click",
	["CM_COLOR"] = "Color",
	["CM_CTRL"] = "Ctrl",
	["CM_CYAN"] = "Cyan",
	["CM_DELETE"] = "Delete",
	["CM_DOUBLECLICK"] = "Double-click",
	["CM_DRAGDROP"] = "Drag & drop",
	["CM_EDIT"] = "Edit",
	["CM_GREEN"] = "Green",
	["CM_GREY"] = "Grey",
	["CM_IC"] = "IC",
	["CM_ICON"] = "Icon",
	["CM_IMAGE"] = "Image",
	["CM_L_CLICK"] = "Left-click",
	["CM_LEFT"] = "Left",
	["CM_LINK"] = "Link",
	["CM_LOAD"] = "Load",
	["CM_M_CLICK"] = "Middle-click",
	["CM_MOVE_DOWN"] = "Move down",
	["CM_MOVE_UP"] = "Move up",
	["CM_NAME"] = "Name",
	["CM_OOC"] = "OOC",
	["CM_OPEN"] = "Open",
	["CM_ORANGE"] = "Orange",
	["CM_PINK"] = "Pink",
	["CM_PLAY"] = "Play",
	["CM_PURPLE"] = "Purple",
	["CM_R_CLICK"] = "Right-click",
	["CM_RED"] = "Red",
	["CM_REMOVE"] = "Remove",
	["CM_RESET"] = "Reset",
	["CM_RESIZE"] = "Resize",
	["CM_RESIZE_TT"] = "Drag to resize the frame.",
	["CM_RIGHT"] = "Right",
	["CM_SAVE"] = "Save",
	["CM_SELECT"] = "Select",
	["CM_SHIFT"] = "Shift",
	["CM_SHOW"] = "Show",
	["CM_STOP"] = "Stop",
	["CM_TWEET"] = "Send a tweet",
	["CM_TWEET_PROFILE"] = "Show profile url",
	["CM_UNKNOWN"] = "Unknown",
	["CM_VALUE"] = "Value",
	["CM_WHITE"] = "White",
	["CM_YELLOW"] = "Yellow",
	["CO_ADVANCED_BROADCAST"] = "Add-on communications",
	["CO_ADVANCED_BROADCAST_CHANNEL_ALWAYS_LAST"] = "Keep broadcast channel last",
	["CO_ADVANCED_BROADCAST_CHANNEL_ALWAYS_LAST_TT"] = "This option will make sure that the broadcast channel is always the last channel in your channels list.",
	["CO_ADVANCED_LANGUAGE_WORKAROUND"] = "Enable workaround against language reset",
	["CO_ADVANCED_LANGUAGE_WORKAROUND_TT"] = "Since patch 8.0.1 the game will reset the selected language to the default language for your faction during every loading screen. This workaround makes sure to restore the selected language after a loading screen.",
	["CO_ADVANCED_LANGUAGES"] = "Languages",
	["CO_ADVANCED_LANGUAGES_REMEMBER"] = "Remember last language used",
	["CO_ADVANCED_LANGUAGES_REMEMBER_TT"] = "Total RP 3 will remember what language you were using before logging off and automatically select this language back on next login.",
	["CO_ADVANCED_SETTINGS"] = "Advanced settings",
	["CO_ADVANCED_SETTINGS_MENU_NAME"] = "Advanced",
	["CO_ADVANCED_SETTINGS_POPUP"] = [=[You have just modified an advanced setting.

Please keep in mind that changing those settings might alter your experience with the add-on and could prevent some features from working correctly. Use at your own risk.]=],
	["CO_ADVANCED_SETTINGS_RESET"] = "Reset advanced settings",
	["CO_ADVANCED_SETTINGS_RESET_TT"] = "Reset all the advanced settings to their default value. Use this if you have issues after modifying the settings.",
	["CO_ANCHOR_BOTTOM"] = "Bottom",
	["CO_ANCHOR_BOTTOM_LEFT"] = "Bottom left",
	["CO_ANCHOR_BOTTOM_RIGHT"] = "Bottom right",
	["CO_ANCHOR_CURSOR"] = "Show on cursor",
	["CO_ANCHOR_LEFT"] = "Left",
	["CO_ANCHOR_RIGHT"] = "Right",
	["CO_ANCHOR_TOP"] = "Top",
	["CO_ANCHOR_TOP_LEFT"] = "Top left",
	["CO_ANCHOR_TOP_RIGHT"] = "Top right",
	["CO_CHAT"] = "Chat settings",
	["CO_CHAT_DISABLE_OOC"] = "Disable customizations when OOC",
	["CO_CHAT_DISABLE_OOC_TT"] = "Disable all of Total RP 3's chat customizations (custom names, emote detection, NPC speeches, etc.) when your character is set as Out Of Character.",
	["CO_CHAT_INCREASE_CONTRAST"] = "Increase color contrast",
	["CO_CHAT_INSERT_FULL_RP_NAME"] = "Insert RP names on shift-click",
	["CO_CHAT_INSERT_FULL_RP_NAME_TT"] = [=[Insert the complete RP name of a player when SHIFT-Clicking their name in the chat frame.

(When this option is enabled, you can ALT-SHIFT-Click on a name when you want the default behavior and insert the character name instead of the full RP name.)]=],
	["CO_CHAT_MAIN"] = "Chat main settings",
	["CO_CHAT_MAIN_COLOR"] = "Use custom colors for names",
	["CO_CHAT_MAIN_EMOTE"] = "Emote detection",
	["CO_CHAT_MAIN_EMOTE_PATTERN"] = "Emote detection pattern",
	["CO_CHAT_MAIN_EMOTE_USE"] = "Use emote detection",
	["CO_CHAT_MAIN_EMOTE_YELL"] = "No yelled emote",
	["CO_CHAT_MAIN_EMOTE_YELL_TT"] = "Do not show *emote* or <emote> in yelling.",
	["CO_CHAT_MAIN_NAMING"] = "Naming method",
	["CO_CHAT_MAIN_NAMING_1"] = "Keep original names",
	["CO_CHAT_MAIN_NAMING_2"] = "Use custom names",
	["CO_CHAT_MAIN_NAMING_3"] = "First name + last name",
	["CO_CHAT_MAIN_NAMING_4"] = "Short title + first name + last name",
	["CO_CHAT_MAIN_NPC"] = "NPC talk detection",
	["CO_CHAT_MAIN_NPC_PREFIX"] = "NPC talk detection pattern",
	["CO_CHAT_MAIN_NPC_PREFIX_TT"] = [=[If a chat line said in the EMOTE channel begins with this prefix, it will be interpreted as an NPC chat.

|cff00ff00By default : "|| "
(without the " and with a space after the pipe)]=],
	["CO_CHAT_MAIN_NPC_USE"] = "Use NPC talk detection",
	["CO_CHAT_MAIN_OOC"] = "OOC detection",
	["CO_CHAT_MAIN_OOC_COLOR"] = "OOC color",
	["CO_CHAT_MAIN_OOC_PATTERN"] = "OOC detection pattern",
	["CO_CHAT_MAIN_OOC_USE"] = "Use OOC detection",
	["CO_CHAT_MAIN_SPEECH"] = "Speech detection",
	["CO_CHAT_MAIN_SPEECH_USE"] = "Use speech detection",
	["CO_CHAT_MAIN_SPEECH_USE_TT"] = "Text surrounded by quotation marks will be colored as if written in /say.",
	["CO_CHAT_NPCSPEECH_REPLACEMENT"] = "Customize companion names in NPC speeches",
	["CO_CHAT_NPCSPEECH_REPLACEMENT_TT"] = "If a companion name is in brackets in an NPC speech, it will be colored and its icon will be shown depending on your settings above.",
	["CO_CHAT_REMOVE_REALM"] = "Remove realm from player names",
	["CO_CHAT_SHOW_OOC"] = "Show OOC indicator",
	["CO_CHAT_USE"] = "Used chat channels",
	["CO_CHAT_USE_ICONS"] = "Show player icons",
	["CO_CHAT_USE_SAY"] = "Say channel",
	["CO_CONFIGURATION"] = "Settings",
	["CO_CURSOR_DISABLE_OOC"] = "Disabled while OOC",
	["CO_CURSOR_DISABLE_OOC_TT"] = "Disable the cursor modifications when your roleplay status is set to |cffccccccOut Of Character|r.",
	["CO_CURSOR_MODIFIER_KEY"] = "Modifier key",
	["CO_CURSOR_MODIFIER_KEY_TT"] = "Requires a modifier key to be held down while right-clicking a player, to prevent accidental clicks.",
	["CO_CURSOR_RIGHT_CLICK"] = "Right-click to open profile",
	["CO_CURSOR_RIGHT_CLICK_TT"] = [=[Right-click on a player in the 3D world to open their profile, if they have one.

|TInterface\Cursor\WorkOrders:25|t This icon will be attached to the cursor when a player has a profile and you can right-click them.

|cffccccccNote: This feature is disabled during combat.|r]=],
	["CO_CURSOR_TITLE"] = "Cursor interactions",
	["CO_GENERAL"] = "General settings",
	["CO_GENERAL_BROADCAST"] = "Use broadcast channel",
	["CO_GENERAL_BROADCAST_C"] = "Broadcast channel name",
	["CO_GENERAL_BROADCAST_TT"] = "The broadcast channel is used by a lot of features. Disabling it will disable all the features like characters position on the map, playing local sounds, stashes and signposts access...",
	["CO_GENERAL_CHANGELOCALE_ALERT"] = [=[Reload the interface in order to change the language to %s now ?

If not, the language will be changed on the next connection.]=],
	["CO_GENERAL_COM"] = "Communication",
	["CO_GENERAL_DEFAULT_COLOR_PICKER"] = "Default color picker",
	["CO_GENERAL_DEFAULT_COLOR_PICKER_TT"] = "Activate to always use the default color picker. Useful if you're using a color picker addon.",
	["CO_GENERAL_HEAVY"] = "Heavy profile alert",
	["CO_GENERAL_HEAVY_TT"] = "Get an alert when your profile total size exceed a reasonable value.",
	["CO_GENERAL_LOCALE"] = "Addon locale",
	["CO_GENERAL_MISC"] = "Miscellaneous",
	["CO_GENERAL_NEW_VERSION"] = "Update alert",
	["CO_GENERAL_NEW_VERSION_TT"] = "Get an alert when a new version is available.",
	["CO_GENERAL_RESET_CUSTOM_COLORS"] = "Reset custom colors",
	["CO_GENERAL_RESET_CUSTOM_COLORS_TT"] = "Removes all custom colors saved in the color picker.",
	["CO_GENERAL_RESET_CUSTOM_COLORS_WARNING"] = "Are you sure you want to remove all custom colors saved in the color picker ?",
	["CO_GENERAL_TT_SIZE"] = "Info tooltip text size",
	["CO_GENERAL_UI_ANIMATIONS"] = "UI animations",
	["CO_GENERAL_UI_ANIMATIONS_TT"] = "Activate the UI animations.",
	["CO_GENERAL_UI_SOUNDS"] = "UI sounds",
	["CO_GENERAL_UI_SOUNDS_TT"] = "Activate the UI sounds (when opening windows, switching tabs, clicking buttons).",
	["CO_GLANCE_LOCK"] = "Lock bar",
	["CO_GLANCE_LOCK_TT"] = "Prevent the bar from being dragged",
	["CO_GLANCE_MAIN"] = "\"At first glance\" bar",
	["CO_GLANCE_PRESET_TRP2"] = "Use Total RP 2 style positions",
	["CO_GLANCE_PRESET_TRP2_BUTTON"] = "Use",
	["CO_GLANCE_PRESET_TRP2_HELP"] = "Shortcut to setup the bar in a TRP2 style : to the right of WoW target frame.",
	["CO_GLANCE_PRESET_TRP3"] = "Use Total RP 3 style positions",
	["CO_GLANCE_PRESET_TRP3_HELP"] = "Shortcut to setup the bar in a TRP3 style : to the bottom of the TRP3 target frame.",
	["CO_GLANCE_RESET_TT"] = "Reset the bar position to the bottom left of the anchored frame.",
	["CO_GLANCE_TT_ANCHOR"] = "Tooltips anchor point",
	["CO_HIDE_EMPTY_MAP_BUTTON"] = "Hide when no scans available",
	["CO_LOCATION"] = "Location settings",
	["CO_LOCATION_ACTIVATE"] = "Enable character location",
	["CO_LOCATION_ACTIVATE_TT"] = "Enable the character location system, allowing you to scan for other Total RP users on the world map and allowing them to find you.",
	["CO_LOCATION_DISABLE_CLASSIC_PVP"] = "Disable location when flagged for PvP",
	["CO_LOCATION_DISABLE_CLASSIC_PVP_TT"] = [=[You will not respond to location requests from other players when you are flagged for PvP.

This option is particularly useful to avoid abuses of the location system to track you.]=],
	["CO_LOCATION_DISABLE_OOC"] = "Disable location when OOC",
	["CO_LOCATION_DISABLE_OOC_TT"] = "You will not respond to location requests from other players when you've set your RP status to Out Of Character.",
	["CO_LOCATION_DISABLE_PVP"] = "Disable location when flagged for PvP",
	["CO_LOCATION_DISABLE_PVP_TT"] = [=[You will not respond to location requests from other players when you are flagged for PvP.

This option is particularly useful on PvP realms where players from the other faction can abuse the location system to track you.]=],
	["CO_LOCATION_DISABLE_WAR_MODE"] = "Disable location when in War Mode",
	["CO_LOCATION_DISABLE_WAR_MODE_TT"] = [=[You will not respond to location requests from other players when you have War Mode enabled and you are outside of a |cff69CCF0Sanctuary|r.

This option is particularly useful to avoid abuses of the location system to track you.]=],
	["CO_LOCATION_SHOW_DIFFERENT_WAR_MODES"] = "Show players in different War Mode",
	["CO_LOCATION_SHOW_DIFFERENT_WAR_MODES_TT"] = "Players who are currently in the zone but have a different War Mode status than you will be shown on the map, with a lower opacity and a special icon in the tooltip.",
	["CO_MAP_BUTTON"] = "Map scan button",
	["CO_MAP_BUTTON_POS"] = "Scan button anchor on map",
	["CO_MINIMAP_BUTTON"] = "Minimap button",
	["CO_MINIMAP_BUTTON_FRAME"] = "Frame to anchor",
	["CO_MINIMAP_BUTTON_RESET"] = "Reset position",
	["CO_MINIMAP_BUTTON_RESET_BUTTON"] = "Reset",
	["CO_MINIMAP_BUTTON_SHOW_HELP"] = [=[If you are using another add-on to display Total RP 3's minimap button (FuBar, Titan, Bazooka) you can remove the button from the minimap.

|cff00ff00Reminder : You can open Total RP 3 using /trp3 switch main|r]=],
	["CO_MINIMAP_BUTTON_SHOW_TITLE"] = "Show minimap button",
	["CO_MODULES"] = "Modules status",
	["CO_MODULES_DISABLE"] = "Disable module",
	["CO_MODULES_ENABLE"] = "Enable module",
	["CO_MODULES_ID"] = "Module ID: %s",
	["CO_MODULES_SHOWERROR"] = "Show error",
	["CO_MODULES_STATUS"] = "Status: %s",
	["CO_MODULES_STATUS_0"] = "Missing dependencies",
	["CO_MODULES_STATUS_1"] = "Loaded",
	["CO_MODULES_STATUS_2"] = "Disabled",
	["CO_MODULES_STATUS_3"] = "Total RP 3 update required",
	["CO_MODULES_STATUS_4"] = "Error on initialization",
	["CO_MODULES_STATUS_5"] = "Error on startup",
	["CO_MODULES_TT_DEP"] = [=[
%s- %s (version %s)|r]=],
	["CO_MODULES_TT_DEPS"] = "Dependencies",
	["CO_MODULES_TT_ERROR"] = [=[

|cffff0000Error:|r
%s]=],
	["CO_MODULES_TT_NONE"] = "No dependencies",
	["CO_MODULES_TT_TRP"] = "%sFor Total RP 3 build %s minimum.|r",
	["CO_MODULES_TUTO"] = [=[A module is a independent feature that can be enabled or disabled.

Possible status:
|cff00ff00Loaded:|r The module is enabled and loaded.
|cff999999Disabled:|r The module is disabled.
|cffff9900Missing dependencies:|r Some dependencies are not loaded.
|cffff9900TRP update required:|r The module requires a more recent version of TRP3.
|cffff0000Error on init or on startup:|r The module loading sequence failed. The module will likely create errors !

|cffff9900When disabling a module, a UI reload is necessary.]=],
	["CO_MODULES_VERSION"] = "Version: %s",
	["CO_MSP"] = "Mary Sue Protocol",
	["CO_MSP_T3"] = "Use template 3 only",
	["CO_MSP_T3_TT"] = "Even if you choose another \"about\" template, the template 3 will always be used for MSP compatibility.",
	["CO_REGISTER"] = "Register settings",
	["CO_REGISTER_ABOUT_H1_SIZE"] = "Header 1 text size",
	["CO_REGISTER_ABOUT_H1_SIZE_TT"] = "Size of the text between {h1} tags. Default: %s",
	["CO_REGISTER_ABOUT_H2_SIZE"] = "Header 2 text size",
	["CO_REGISTER_ABOUT_H2_SIZE_TT"] = "Size of the text between {h2} tags. Default: %s",
	["CO_REGISTER_ABOUT_H3_SIZE"] = "Header 3 text size",
	["CO_REGISTER_ABOUT_H3_SIZE_TT"] = "Size of the text between {h3} tags. Default: %s",
	["CO_REGISTER_ABOUT_P_SIZE"] = "Paragraph text size",
	["CO_REGISTER_ABOUT_P_SIZE_TT"] = "Size of the text outside of header tags. Default: %s",
	["CO_REGISTER_ABOUT_SETTINGS"] = "\"About\" settings",
	["CO_REGISTER_ABOUT_VOTE"] = "Use voting system",
	["CO_REGISTER_ABOUT_VOTE_TT"] = "Enables the voting system, allowing you to vote ('like' or 'unlike') for others' descriptions and allowing them to do the same for you.",
	["CO_REGISTER_AUTO_ADD"] = "Auto add new players",
	["CO_REGISTER_AUTO_ADD_TT"] = [=[Automatically add new players you encounter to the register.

|cffff0000Note: Disabling this option will prevent you from receiving any new profiles from players you have not encountered yet! Use this option if you do not want to receive new profiles form other players, only updates from players you have already seen.]=],
	["CO_REGISTER_AUTO_PURGE"] = "Auto purge directory",
	["CO_REGISTER_AUTO_PURGE_0"] = "Disable purge",
	["CO_REGISTER_AUTO_PURGE_1"] = "After %s day(s)",
	["CO_REGISTER_AUTO_PURGE_TT"] = [=[Automatically remove from directory the profiles of characters you haven't crossed for a certain time. You can choose the delay before deletion.

|cff00ff00Note that profiles with a relation toward one of your characters will never be purged.

|cffff9900There is a bug in WoW losing all the saved data when it reaches a certain threshold. We strongly recommend to avoid disabling the purge system.]=],
	["CO_SANITIZER"] = "Sanitize incoming profiles",
	["CO_SANITIZER_TT"] = "Remove escaped sequences in tooltip fields from incoming profiles when TRP doesn't allow it (color, images ...).",
	["CO_TARGETFRAME"] = "Target frame settings",
	["CO_TARGETFRAME_ICON_SIZE"] = "Icons size",
	["CO_TARGETFRAME_USE"] = "Display conditions",
	["CO_TARGETFRAME_USE_1"] = "Always",
	["CO_TARGETFRAME_USE_2"] = "Only when IC",
	["CO_TARGETFRAME_USE_3"] = "Never (Disabled)",
	["CO_TARGETFRAME_USE_TT"] = "Determines in which conditions the target frame should be shown on target selection.",
	["CO_TOOLBAR"] = "Frames settings",
	["CO_TOOLBAR_CONTENT"] = "Toolbar settings",
	["CO_TOOLBAR_CONTENT_CAPE"] = "Cape switch",
	["CO_TOOLBAR_CONTENT_HELMET"] = "Helmet switch",
	["CO_TOOLBAR_CONTENT_RPSTATUS"] = "Character status (IC/OOC)",
	["CO_TOOLBAR_CONTENT_STATUS"] = "Player status (AFK/DND)",
	["CO_TOOLBAR_HIDE_TITLE"] = "Hide Toolbar Title",
	["CO_TOOLBAR_HIDE_TITLE_HELP"] = "Hides the title shown above the toolbar.",
	["CO_TOOLBAR_ICON_SIZE"] = "Icons size",
	["CO_TOOLBAR_MAX"] = "Max icons per line",
	["CO_TOOLBAR_MAX_TT"] = "Set to 1 if you want to display the bar vertically !",
	["CO_TOOLBAR_SHOW_ON_LOGIN"] = "Show toolbar on login",
	["CO_TOOLBAR_SHOW_ON_LOGIN_HELP"] = "If you don't want the toolbar to be displayed on login, you can disable this option.",
	["CO_TOOLTIP"] = "Tooltip settings",
	["CO_TOOLTIP_ANCHOR"] = "Anchor point",
	["CO_TOOLTIP_ANCHORED"] = "Anchored frame",
	["CO_TOOLTIP_CHARACTER"] = "Characters tooltip",
	["CO_TOOLTIP_CLIENT"] = "Show client",
	["CO_TOOLTIP_COLOR"] = "Show custom colors",
	["CO_TOOLTIP_COMBAT"] = "Hide during combat",
	["CO_TOOLTIP_COMMON"] = "Common settings",
	["CO_TOOLTIP_CONTRAST"] = "Increase color contrast",
	["CO_TOOLTIP_CONTRAST_TT"] = "Enable this option to allow Total RP 3 to modify the custom colors to make the text more readable if the color is too dark.",
	["CO_TOOLTIP_CROP_TEXT"] = "Crop unreasonably long texts",
	["CO_TOOLTIP_CROP_TEXT_TT"] = [=[Limit the number of characters that can be displayed by each field in the tooltip to prevent unreasonably long texts and possible layout issues.

|cfffff569Limit details:
Name: 100 characters
Title: 150 characters
Race: 50 characters
Class: 50 characters|r]=],
	["CO_TOOLTIP_CURRENT"] = "Show \"current\" information",
	["CO_TOOLTIP_CURRENT_LINES"] = "Max \"Currently\" line breaks",
	["CO_TOOLTIP_CURRENT_SIZE"] = "Max \"current\" information length",
	["CO_TOOLTIP_FT"] = "Show full title",
	["CO_TOOLTIP_GUILD"] = "Show guild info",
	["CO_TOOLTIP_HEALTH"] = "Show health",
	["CO_TOOLTIP_HEALTH_BOTH"] = "Number + Percentage",
	["CO_TOOLTIP_HEALTH_DISABLED"] = "Disabled",
	["CO_TOOLTIP_HEALTH_NUMBER"] = "Number",
	["CO_TOOLTIP_HEALTH_PERCENT"] = "Percentage",
	["CO_TOOLTIP_HEALTH_TT"] = "This will only show if the target is not at full health.",
	["CO_TOOLTIP_HIDE_IN_INSTANCE"] = "Hide while in instance",
	["CO_TOOLTIP_HIDE_ORIGINAL"] = "Hide original tooltip",
	["CO_TOOLTIP_ICONS"] = "Show icons",
	["CO_TOOLTIP_IN_CHARACTER_ONLY"] = "Hide when out of character",
	["CO_TOOLTIP_MAIN_COLOR"] = "Main text color",
	["CO_TOOLTIP_MAIN_COLOR_HELP"] = "The color used in the tooltip to display text such as the race, level, and currently and OOC headers.",
	["CO_TOOLTIP_MAINSIZE"] = "Main font size",
	["CO_TOOLTIP_NO_FADE_OUT"] = "Hide immediately instead of fading",
	["CO_TOOLTIP_NOTIF"] = "Show notifications",
	["CO_TOOLTIP_NOTIF_TT"] = "The notifications line is the line containing the client version, the unread description marker and the 'At first glance' marker.",
	["CO_TOOLTIP_OWNER"] = "Show owner",
	["CO_TOOLTIP_PETS"] = "Companions tooltip",
	["CO_TOOLTIP_PETS_INFO"] = "Show companion info",
	["CO_TOOLTIP_PREFERRED_OOC_INDICATOR"] = "Preferred OOC indicator",
	["CO_TOOLTIP_PREFERRED_OOC_INDICATOR_ICON"] = "Icon: ",
	["CO_TOOLTIP_PREFERRED_OOC_INDICATOR_TEXT"] = "Text: ",
	["CO_TOOLTIP_PROFILE_ONLY"] = "Use only if target has a profile",
	["CO_TOOLTIP_PRONOUNS"] = "Show pronouns",
	["CO_TOOLTIP_RACE"] = "Show race, class and level",
	["CO_TOOLTIP_REALM"] = "Show realm",
	["CO_TOOLTIP_RELATION"] = "Show relationship color",
	["CO_TOOLTIP_RELATION_TT"] = "Set the character tooltip border to a color representing the relation.",
	["CO_TOOLTIP_SECONDARY_COLOR"] = "Secondary text color",
	["CO_TOOLTIP_SECONDARY_COLOR_HELP"] = "The color used in the tooltip to display secondary subtext such as realm and guild names, the currently and OOC contents, and zone or health information.",
	["CO_TOOLTIP_SPACING"] = "Show spacing",
	["CO_TOOLTIP_SPACING_TT"] = "Place spaces to lighten the tooltip, in the style of MyRoleplay tooltip.",
	["CO_TOOLTIP_SUBSIZE"] = "Secondary font size",
	["CO_TOOLTIP_TARGET"] = "Show target",
	["CO_TOOLTIP_TERSIZE"] = "Tertiary font size",
	["CO_TOOLTIP_TITLE"] = "Show title",
	["CO_TOOLTIP_TITLE_COLOR"] = "Title text color",
	["CO_TOOLTIP_TITLE_COLOR_HELP"] = "The color used in the tooltip to display full-length character titles.",
	["CO_TOOLTIP_USE"] = "Use characters/companions tooltip",
	["CO_TOOLTIP_ZONE"] = "Show zone",
	["CO_TOOLTIP_ZONE_TT"] = "This will only show if the target is not in the same zone as you.",
	["CO_UI_RELOAD_WARNING"] = [=[The interface needs to be reloaded in order for the changes to be applied.

Would you like to reload the interface now?]=],
	["CO_WIM"] = "|cffff9900Whisper channels are disabled.",
	["CO_WIM_TT"] = "You are using |cff00ff00WIM|r, the handling for whisper channels is disabled for compatibility purposes",
	["COM_LIST"] = "List of commands:",
	["COM_RESET_RESET"] = "The frames positions have been reset!",
	["COM_RESET_USAGE"] = "Usage: |cff00ff00/trp3 reset frames|r to reset all frames positions.",
	["COM_STASH_DATA"] = [=[|cffff0000Are you sure you want to stash away your Total RP 3 data?|r

Your profiles, companions profiles and settings will be temporarily stashed away and your UI will reload with empty data, as if your installation of Total RP 3 was brand new.
|cff00ff00Use the same command again (|cff999999/trp3 stash|cff00ff00) to restore your data.|r]=],
	["COM_SWITCH_USAGE"] = "Usage: |cff00ff00/trp3 switch main|r to switch main frame or |cff00ff00/trp3 switch toolbar|r to switch the toolbar.",
	["CONFIG_COMMS_QUEUE_POOL_COUNT"] = "Queue pool size",
	["CONFIG_COMMS_QUEUE_POOL_COUNT_DESCRIPTION"] = "Controls the size of the queue pool used for profile communications.|n|nLower values will reduce latency of addon communications for non-RP profile data, but may increase the amount of time before other players begin to receive any profile data at all in high load scenarios.",
	["CONFIG_COMMS_QUEUE_POOL_WEIGHT_THRESHOLD"] = "Queue pool data weight threshold",
	["CONFIG_COMMS_QUEUE_POOL_WEIGHT_THRESHOLD_DESCRIPTION"] = "Controls the minimum weight your RP profile data must be before queue pools will be used.|n|nFor larger profiles, increasing this value may |cffff0000severely deteriorate|r the performance of all addon communications.",
	["CONFIG_COMMS_SETTINGS_HEADER"] = "Communications settings",
	["COPY_DROPDOWN_POPUP_TEXT"] = [=[Copy with %1$s. Paste with %2$s.
This frame will close upon copy.]=],
	["COPY_SYSTEM_MESSAGE"] = "Copied to clipboard.",
	["CREDITS_DISCORD_LINK_TEXT"] = "Join us on Discord",
	["CREDITS_GUILD_NAME"] = "<%1$s>",
	["CREDITS_NAME_WITH_ROLE"] = "%1$s (%2$s)",
	["CREDITS_THANK_YOU_ROLE_1"] = "Project Lead",
	["CREDITS_THANK_YOU_ROLE_2"] = "Author",
	["CREDITS_THANK_YOU_ROLE_3"] = "Developer",
	["CREDITS_THANK_YOU_ROLE_4"] = "Community Manager",
	["CREDITS_THANK_YOU_ROLE_5"] = "Mascot",
	["CREDITS_THANK_YOU_SECTION_1"] = "{h1:c}Total RP 3{/h1}",
	["CREDITS_THANK_YOU_SECTION_10"] = "{col:ffffff}Thanks to our active community members on Discord:{/col}",
	["CREDITS_THANK_YOU_SECTION_11"] = "{col:ffffff}Thanks to Bor Blasthammer for his help during BfA testing.{/col}",
	["CREDITS_THANK_YOU_SECTION_2"] = "{h2}%1$s Created by{/h2}",
	["CREDITS_THANK_YOU_SECTION_3"] = "{h2}%1$s The Rest of the Team{/h2}",
	["CREDITS_THANK_YOU_SECTION_4"] = "{h2}%1$s Acknowledgements{/h2}",
	["CREDITS_THANK_YOU_SECTION_5"] = "{col:ffffff}Logo and minimap button icon:{/col} %1$s",
	["CREDITS_THANK_YOU_SECTION_6"] = "{col:ffffff}Our pre-alpha QA team:{/col}",
	["CREDITS_THANK_YOU_SECTION_7"] = "{col:ffffff}Thanks to all our friends for their support all these years:{/col}",
	["CREDITS_THANK_YOU_SECTION_8"] = "{col:ffffff}For helping us creating the Total RP guild on Kirin Tor (EU):{/col}",
	["CREDITS_THANK_YOU_SECTION_9"] = "{col:ffffff}Thanks to Horionne for sending us the magazine Gamer Culte Online #14 with an article about Total RP.{/col}",
	["CREDITS_VERSION_TEXT"] = "Version %s",
	["CREDITS_WEBSITE_LINK_TEXT"] = "Website",
	["DB_ABOUT"] = "About Total RP 3",
	["DB_HTML_GOTO"] = "Click to open",
	["DB_MORE"] = "More modules",
	["DB_NEW"] = "What's new?",
	["DB_STATUS"] = "Status",
	["DB_STATUS_CURRENTLY"] = "Currently (IC)",
	["DB_STATUS_CURRENTLY_COMMON"] = "These statuses will be displayed on your character's tooltip. Keep it clear and brief as |cffff9900by default TRP3 players will only see the first 140 characters of them!",
	["DB_STATUS_CURRENTLY_OOC"] = "Other information (OOC)",
	["DB_STATUS_CURRENTLY_OOC_TT"] = "Here you can indicate something important about you, as a player, or anything out of your character.",
	["DB_STATUS_CURRENTLY_TT"] = "Here you can indicate something important about your character.",
	["DB_STATUS_ICON_ITEM"] = "%1$s %2$s",
	["DB_STATUS_LC"] = "Roleplay language",
	["DB_STATUS_LC_DEFAULT"] = "Default (%1$s)",
	["DB_STATUS_LC_TT"] = [=[Sets your preferred roleplaying language. This will be shared with other compatible RP addon users.

|cffff9900Note:|r This does |cffff0000not|r change the user interface language of Total RP 3. This option can instead be found in the |cfffff569Advanced Settings|r page.]=],
	["DB_STATUS_RP"] = "Character status",
	["DB_STATUS_RP_EXP"] = "Experienced roleplayer",
	["DB_STATUS_RP_EXP_TT"] = [=[Shows that you are an experienced roleplayer.
It will not show any specific icon on your tooltip.]=],
	["DB_STATUS_RP_IC"] = "In character",
	["DB_STATUS_RP_IC_TT"] = [=[That means you are currently playing your character.
All your actions will be interpreted as if it's your character doing them.]=],
	["DB_STATUS_RP_OOC"] = "Out of character",
	["DB_STATUS_RP_OOC_TT"] = [=[You are out of your character.
Your actions can't be associated to him/her.]=],
	["DB_STATUS_RP_VOLUNTEER"] = "Volunteer roleplayer",
	["DB_STATUS_RP_VOLUNTEER_TT"] = [=[This selection will show an icon on your tooltip, indicating
to beginner roleplayers that you are willing to help them.]=],
	["DB_STATUS_XP"] = "Roleplayer status",
	["DB_STATUS_XP_BEGINNER"] = "Rookie roleplayer",
	["DB_STATUS_XP_BEGINNER_TT"] = [=[This selection will show an icon on your tooltip, indicating
to others that you are a beginner roleplayer.]=],
	["DB_TUTO_1"] = [=[|cffffff00The character status|r indicates if you are currently playing your character's role or not.

|cffffff00The roleplayer status|r allows you to state that you are a beginner, or a veteran willing to help rookies!

|cff00ff00These information will be placed in your character's tooltip.]=],
	["DICE_HELP"] = "A dice roll or rolls separated by spaces, example: 1d6, 2d12 3d20 ...",
	["DICE_ROLL"] = "%s Rolled |cffff9900%sx d%s|r|cffcc6600%s|r and got |cff00ff00%s|r.",
	["DICE_ROLL_T"] = "%s %s rolled |cffff9900%sx d%s|r|cffcc6600%s|r and got |cff00ff00%s|r.",
	["DICE_TOTAL"] = "%s Total of |cff00ff00%s|r for the roll.",
	["DICE_TOTAL_T"] = "%s %s got a total of |cff00ff00%s|r for the roll.",
	["DTBK_AFK"] = "Total RP 3 - AFK/DND",
	["DTBK_CLOAK"] = "Total RP 3 - Cloak",
	["DTBK_HELMET"] = "Total RP 3 - Helmet",
	["DTBK_LANGUAGES"] = "Total RP 3 - Languages",
	["DTBK_RP"] = "Total RP 3 - IC/OOC",
	["GEN_VERSION"] = "Version: %s (Build %s)",
	["GEN_WELCOME_MESSAGE"] = "Thank you for using Total RP 3 (v %s) ! Have fun !",
	["KUI_NAMEPLATES_MODULE_DESCRIPTION"] = "Enables the customization of Kui nameplates.",
	["KUI_NAMEPLATES_MODULE_NAME"] = "Kui Nameplates",
	["KUI_NAMEPLATES_WARN_OUTDATED_MODULE"] = "The Kui |cff9966ffNameplates|r plugin for Total RP 3 has been integrated directly into the main addon.|n|nThe old plugin has been disabled automatically, and |cffffcc00we recommend that you uninstall it|r as it is no longer needed.",
	["LANG_CHANGE_CAUSED_REVERT_TO_DEFAULT"] = "Current spoken language reverted to default %s because you no longer know the previously selected language %s.",
	["MAP_BUTTON_NO_SCAN"] = "No scan available",
	["MAP_BUTTON_SCANNING"] = "Scanning",
	["MAP_BUTTON_SUBTITLE"] = "Click to show available scans",
	["MAP_BUTTON_SUBTITLE_80_DISABLED"] = "Scans temporarily unavailable due to 8.0 changes",
	["MAP_BUTTON_SUBTITLE_CONNECTING"] = "Map scanning is setting up. Please wait.",
	["MAP_BUTTON_SUBTITLE_OFFLINE"] = "Map scanning is unavailable right now: %s",
	["MAP_BUTTON_TITLE"] = "Scan for roleplay",
	["MAP_SCAN_CHAR"] = "Scan for characters",
	["MAP_SCAN_CHAR_TITLE"] = "Characters",
	["MATURE_FILTER_ADD_TO_SAFELIST"] = "Add this profile to the |cffffffffmature safelist|r",
	["MATURE_FILTER_ADD_TO_SAFELIST_OPTION"] = "Add to the |cffffffffmature safelist|r",
	["MATURE_FILTER_ADD_TO_SAFELIST_TEXT"] = [=[Confirm that you want to add %s to the |cffffffffmature safelist|r.

The content of their profiles will no longer be hidden.]=],
	["MATURE_FILTER_ADD_TO_SAFELIST_TT"] = "Add this profile to the |cffffffffmature safelist|r and reveal the mature content found inside.",
	["MATURE_FILTER_ADD_TO_WHITELIST"] = "Add this profile to the |cffffffffmature white list|r",
	["MATURE_FILTER_ADD_TO_WHITELIST_OPTION"] = "Add to the |cffffffffmature white list|r",
	["MATURE_FILTER_ADD_TO_WHITELIST_TEXT"] = [=[Confirm that you want to add %s to the |cffffffffmature white list|r.

The content of their profiles will no longer be hidden.]=],
	["MATURE_FILTER_ADD_TO_WHITELIST_TT"] = "Add this profile to the |cffffffffmature white list|r and reveal the mature content found inside.",
	["MATURE_FILTER_EDIT_DICTIONARY"] = "Edit custom dictionary",
	["MATURE_FILTER_EDIT_DICTIONARY_ADD_BUTTON"] = "Add",
	["MATURE_FILTER_EDIT_DICTIONARY_ADD_TEXT"] = "Add a new word to the dictionary",
	["MATURE_FILTER_EDIT_DICTIONARY_BUTTON"] = "Edit",
	["MATURE_FILTER_EDIT_DICTIONARY_DELETE_WORD"] = "Delete the word from the custom dictionary",
	["MATURE_FILTER_EDIT_DICTIONARY_EDIT_WORD"] = "Edit this word",
	["MATURE_FILTER_EDIT_DICTIONARY_RESET_BUTTON"] = "Reset",
	["MATURE_FILTER_EDIT_DICTIONARY_RESET_TITLE"] = "Reset dictionary",
	["MATURE_FILTER_EDIT_DICTIONARY_RESET_WARNING"] = "Are you sure you want to reset the dictionary? This will empty the dictionary and fill it with the default words provided for your current language (if available).",
	["MATURE_FILTER_EDIT_DICTIONARY_TITLE"] = "Custom dictionary editor",
	["MATURE_FILTER_EDIT_DICTIONARY_TT"] = "Edit the custom dictionary used to filter mature profiles.",
	["MATURE_FILTER_FLAG_PLAYER"] = "Flag as mature",
	["MATURE_FILTER_FLAG_PLAYER_OPTION"] = "Flag as mature",
	["MATURE_FILTER_FLAG_PLAYER_TEXT"] = [=[Confirm that you want to flag %s's profile as containing mature content. This profile content will be hidden.

|cffffff00Optional:|r Indicate the offensive words you found in this profile (separated by a space character) to add them to the filter.]=],
	["MATURE_FILTER_FLAG_PLAYER_TT"] = "Flag this profile has containing mature content. The profile content will be hidden.",
	["MATURE_FILTER_OPTION"] = "Filter mature profiles",
	["MATURE_FILTER_OPTION_TT"] = [=[Check this option to enable mature profile filtering. Total RP 3 will scan incoming profiles when they are received for specific keywords reported as being for a mature audience and flag the profile as mature if it finds such word.

A mature profile will have a muted tooltip and you will have to confirm that you want to view the profile the first time you open it.

|cffccccccNote: The mature filter dictionary is pre-populated with a list of words from a crowd sourced repository. You can edit the words using the option below.|r]=],
	["MATURE_FILTER_REMOVE_FROM_SAFELIST"] = "Remove this profile from the |cffffffffmature safelist|r",
	["MATURE_FILTER_REMOVE_FROM_SAFELIST_OPTION"] = "Remove from the |cffffffffmature safelist|r",
	["MATURE_FILTER_REMOVE_FROM_SAFELIST_TEXT"] = [=[Confirm that you want to remove %s from the |cffffffffmature safelist|r.

The content of their profiles will be hidden again.]=],
	["MATURE_FILTER_REMOVE_FROM_SAFELIST_TT"] = "Remove this profile from the |cffffffffmature safelist|r and hide again the mature content found inside.",
	["MATURE_FILTER_REMOVE_FROM_WHITELIST"] = "Remove this profile from the |cffffffffmature white list|r",
	["MATURE_FILTER_REMOVE_FROM_WHITELIST_OPTION"] = "Remove from the |cffffffffmature white list|r",
	["MATURE_FILTER_REMOVE_FROM_WHITELIST_TEXT"] = [=[Confirm that you want to remove %s from the |cffffffffmature white list|r.

The content of their profiles will be hidden again.]=],
	["MATURE_FILTER_REMOVE_FROM_WHITELIST_TT"] = "Remove this profile from the |cffffffffmature white list|r and hide again the mature content found inside.",
	["MATURE_FILTER_STRENGTH"] = "Mature filter strength",
	["MATURE_FILTER_STRENGTH_TT"] = [=[Set the strength of the mature filter.

|cffcccccc1 is weak (10 bad words required to flag), 10 is strong (only 1 bad word required to flag).|r]=],
	["MATURE_FILTER_TITLE"] = "Mature profiles filter",
	["MATURE_FILTER_TOOLTIP_WARNING"] = "Mature content",
	["MATURE_FILTER_TOOLTIP_WARNING_SUBTEXT"] = "This character profile contains mature content. Use the target bar action button to reveal the content if you really want to…",
	["MATURE_FILTER_WARNING_CONTINUE"] = "Continue",
	["MATURE_FILTER_WARNING_GO_BACK"] = "Go back",
	["MATURE_FILTER_WARNING_TEXT"] = [=[You have Total RP 3's mature content filtering system enabled.

This profile has been flagged as containing mature content.

Are you sure you want to view this profile?]=],
	["MATURE_FILTER_WARNING_TITLE"] = "Mature content",
	["MM_SHOW_HIDE_MAIN"] = "Show/hide the main frame",
	["MM_SHOW_HIDE_MOVE"] = "Move button",
	["MM_SHOW_HIDE_SHORTCUT"] = "Show/hide the toolbar",
	["MO_ADDON_NOT_INSTALLED"] = "The %s add-on is not installed, custom Total RP 3 integration disabled.",
	["MO_CHAT_CUSTOMIZATIONS_DESCRIPTION"] = "Add custom compatibility for the %s add-on, so that chat messages and player names are modified by Total RP 3 in that add-on.",
	["MO_TOOLTIP_CUSTOMIZATIONS_DESCRIPTION"] = "Add custom compatibility for the %s add-on, so that your tooltip preferences are applied to Total RP 3's tooltips.",
	["MORE_MODULES_2"] = [=[{h2:c}Optional modules{/h2}
{h3}Total RP 3: Extended{/h3}
|cff9999ffTotal RP 3: Extended|r add the possibility to create new content in WoW: campaigns with quests and dialogues, items, documents (books, signs, contracts, …) and many more!
{link*http://extended.totalrp3.info*Download on Curse.com}

{h3}Kui |cff9966ffNameplates|r module{/h3}
The Kui |cff9966ffNameplates|r module adds several Total RP 3 customizations to the KuiNameplates add-on:
• See the full RP name of a character on their nameplate, instead of their default name, colored like in their tooltip.
• See customized pets names.
• Hide the names of players without an RP profile!
{link*http://mods.curse.com/addons/wow/total-rp-3-kuinameplates-module*Download on Curse.com}.


]=],
	["NAMEPLATES_CONFIG_ACTIVE_QUERY"] = "Automatically fetch profiles",
	["NAMEPLATES_CONFIG_ACTIVE_QUERY_HELP"] = "If checked, automatically fetches roleplay profiles for units with nameplates attached.",
	["NAMEPLATES_CONFIG_BLIZZARD_NAME_ONLY"] = "Hide bars on |cff449fe0Blizzard|r nameplates",
	["NAMEPLATES_CONFIG_BLIZZARD_NAME_ONLY_HELP"] = "If checked, this enables the use of name-only mode for |cff449fe0Blizzard|r nameplates.|n|nIn this mode, all nameplates will have their health bars hidden, including those of enemy units and other players with or without roleplay profiles.|n|nThis option requires a UI reload to take effect.",
	["NAMEPLATES_CONFIG_CUSTOMIZE_FULL_TITLES"] = "Show full length titles",
	["NAMEPLATES_CONFIG_CUSTOMIZE_FULL_TITLES_HELP"] = "If checked, shows the full title of a unit on nameplates.|n|nFor |cff449fe0Blizzard|r and |cff9966ffKui|r nameplates, full titles are only shown in name-only mode.",
	["NAMEPLATES_CONFIG_CUSTOMIZE_HEALTH_COLORS"] = "Show custom health colors",
	["NAMEPLATES_CONFIG_CUSTOMIZE_HEALTH_COLORS_HELP"] = "If checked, overrides the color of health bars with the class color of a units' profile.",
	["NAMEPLATES_CONFIG_CUSTOMIZE_ICONS"] = "Show icons",
	["NAMEPLATES_CONFIG_CUSTOMIZE_ICONS_HELP"] = "If checked, shows profile icons on nameplates.",
	["NAMEPLATES_CONFIG_CUSTOMIZE_NAME_COLORS"] = "Show custom name colors",
	["NAMEPLATES_CONFIG_CUSTOMIZE_NAME_COLORS_HELP"] = "If checked, overrides the color of name texts with the class color of a units' profile.",
	["NAMEPLATES_CONFIG_CUSTOMIZE_NAMES"] = "Show custom names",
	["NAMEPLATES_CONFIG_CUSTOMIZE_NAMES_HELP"] = "If checked, replaces the name shown on nameplates.",
	["NAMEPLATES_CONFIG_CUSTOMIZE_ROLEPLAY_STATUS"] = "Show roleplay status indicator",
	["NAMEPLATES_CONFIG_CUSTOMIZE_ROLEPLAY_STATUS_HELP"] = "If checked, shows an indicator of a units' roleplay status (IC or OOC) on nameplates.",
	["NAMEPLATES_CONFIG_CUSTOMIZE_TITLES"] = "Show prefix titles",
	["NAMEPLATES_CONFIG_CUSTOMIZE_TITLES_HELP"] = "If checked, shows the short title of a unit on nameplates before their name.",
	["NAMEPLATES_CONFIG_DISABLE_IN_COMBAT"] = "Disable customizations when in combat",
	["NAMEPLATES_CONFIG_DISABLE_IN_COMBAT_HELP"] = "If checked, disables nameplate customizations while you are in combat.",
	["NAMEPLATES_CONFIG_DISABLE_OUT_OF_CHARACTER"] = "Disable customizations when OOC",
	["NAMEPLATES_CONFIG_DISABLE_OUT_OF_CHARACTER_HELP"] = "If checked, disables all nameplate customizations while you are out of character.",
	["NAMEPLATES_CONFIG_DISABLE_OUT_OF_CHARACTER_UNITS"] = "Disable customizations on OOC units",
	["NAMEPLATES_CONFIG_DISABLE_OUT_OF_CHARACTER_UNITS_HELP"] = "If checked, disables nameplate customizations on units that are out of character.",
	["NAMEPLATES_CONFIG_ELEMENT_HEADER"] = "Customization settings",
	["NAMEPLATES_CONFIG_ENABLE_CLASS_COLOR_FALLBACK"] = "Use class color by default",
	["NAMEPLATES_CONFIG_ENABLE_CLASS_COLOR_FALLBACK_HELP"] = "If checked, this enables the use of class colors for names and health bars as a fallback for units that do not have a custom class color in their profile.|n|nUnits that do not have roleplay profiles are unaffected by this setting and will not be class-colored.",
	["NAMEPLATES_CONFIG_HIDE_NON_ROLEPLAY_UNITS"] = "Hide non-roleplay units",
	["NAMEPLATES_CONFIG_HIDE_NON_ROLEPLAY_UNITS_HELP"] = "If checked, hides the nameplates of player and companion units that do not have roleplay profiles.",
	["NAMEPLATES_CONFIG_HIDE_OUT_OF_CHARACTER_UNITS"] = "Hide out of character units",
	["NAMEPLATES_CONFIG_HIDE_OUT_OF_CHARACTER_UNITS_HELP"] = "If checked, hides the nameplates of units that are currently out of character.",
	["NAMEPLATES_CONFIG_ICON_SIZE"] = "Icon size",
	["NAMEPLATES_CONFIG_ICON_SIZE_HELP"] = "Configures the size of icons displayed on nameplates if the |cffffff00Show icons|r option is enabled.",
	["NAMEPLATES_CONFIG_MENU_TITLE"] = "Nameplates",
	["NAMEPLATES_CONFIG_PAGE_HELP"] = "Please note that only |cff449fe0Blizzard|r and |cff9966ffKui|r nameplates are currently supported. Refer to the help tip on each setting below for additional information.",
	["NAMEPLATES_CONFIG_PAGE_TEXT"] = "Nameplate settings",
	["NAMEPLATES_CONFIG_VISIBILITY_HEADER"] = "Visibility settings",
	["NAMEPLATES_MODULE_ACTIVE_STATUS"] = "Module |cff00ff00active|r (%1$s|r)",
	["NAMEPLATES_MODULE_DESCRIPTION"] = "Enables the customization of nameplates with information obtained from roleplay profiles.",
	["NAMEPLATES_MODULE_DISABLE_WARNING"] = "Disabling the nameplates module will prevent any nameplate customizations from being made. A user interface reload is required for this to take effect.|n|n|cffff0000Warning: |rOnce disabled, this module can only be re-enabled from the |cffffcc00Modules status|r page.|n|nAre you sure you want to disable this module?",
	["NAMEPLATES_MODULE_DISABLED_BY_DEPENDENCY"] = "This module was disabled automatically due to a missing dependency.",
	["NAMEPLATES_MODULE_DISABLED_BY_EXTERNAL"] = "This module was disabled automatically due to a conflict with another module or addon.",
	["NAMEPLATES_MODULE_INACTIVE_STATUS"] = "Module |cffff9900inactive|r (no addon found)",
	["NAMEPLATES_MODULE_NAME"] = "Nameplates",
	["NEW_VERSION"] = [=[|cff00ff00A new version of Total RP 3 (v %s) is available.

|cffffff00We strongly encourage you to stay up-to-date.|r

This message will only appear once per session and can be disabled in the settings (General settings => Miscellaneous).]=],
	["NEW_VERSION_BEHIND"] = "You are currently %s versions behind and are missing on many bug fixes and new features. Other players might not be able to see your profile correctly. Please consider updating the add-on.",
	["NEW_VERSION_TITLE"] = "New update available",
	["NPC_TALK_BUTTON_TT"] = "Open the NPC speeches frame allowing you to do NPC speeches or emotes.",
	["NPC_TALK_CHANNEL"] = "Channel: ",
	["NPC_TALK_COMMAND_HELP"] = "Open the NPC speeches frame.",
	["NPC_TALK_ERROR_EMPTY_MESSAGE"] = "The message cannot be empty.",
	["NPC_TALK_MESSAGE"] = "Message",
	["NPC_TALK_NAME"] = "NPC name",
	["NPC_TALK_NAME_TT"] = [=[You can use standard chat tags like %t to insert your target's name or %f to insert your focus' name.

You can also leave this field empty to create emotes without an NPC name at the start.

Putting your companion name in [brackets] will allow color and icon customization.
]=],
	["NPC_TALK_SAY_PATTERN"] = "says:",
	["NPC_TALK_SEND"] = "Send",
	["NPC_TALK_TITLE"] = "NPC speeches",
	["NPC_TALK_WHISPER_PATTERN"] = "whispers:",
	["NPC_TALK_YELL_PATTERN"] = "yells:",
	["OPTION_DISABLED_TOAST"] = "Option disabled",
	["OPTION_ENABLED_TOAST"] = "Option enabled",
	["PATTERN_ERROR"] = "Error in pattern.",
	["PATTERN_ERROR_TAG"] = "Error in pattern : unclosed text tag.",
	["PR_CO_BATTLE"] = "Battle pet",
	["PR_CO_COUNT"] = "%s pets/mounts bound to this profile.",
	["PR_CO_EMPTY"] = "No companion profile",
	["PR_CO_MASTERS"] = "Masters",
	["PR_CO_MOUNT"] = "Mount",
	["PR_CO_NEW_PROFILE"] = "New companion profile",
	["PR_CO_PET"] = "Pet",
	["PR_CO_PROFILE_DETAIL"] = "This profile is currently bound to",
	["PR_CO_PROFILE_HELP"] = [=[A profile contains all information about a |cffffff00"pet"|r as a |cff00ff00roleplay character|r.

A companion profile can be linked to:
- A battle pet |cffff9900(only if it has been renamed)|r
- A hunter pet
- A warlock minion
- A mage elemental
- A death knight ghoul |cffff9900(see below)|r

Just like characters profiles, a |cff00ff00companion profile|r can be linked to |cffffff00several pets|r, and a |cffffff00pet|r can switch easily from one profile to another.

|cffff9900Ghouls:|r As ghouls get a new name each time they are summoned, you will have to re-link the profile to the ghoul for all possible names.]=],
	["PR_CO_PROFILE_HELP2"] = [=[Click here to create a new companion profile.

|cff00ff00To link a profile to a pet (hunter pet, warlock minion ...), just summon the pet, select it and use the target frame to link it to a existing profile (or create a new one).|r]=],
	["PR_CO_PROFILEMANAGER_DELETE_WARNING"] = [=[Are you sure you want to delete the companion profile %s?
This action cannot be undone and all TRP3 information linked to this profile will be destroyed !]=],
	["PR_CO_PROFILEMANAGER_DUPP_POPUP"] = [=[Please enter a name for the new profile.
The name cannot be empty.

This duplication will not change your pets/mounts binds to %s.]=],
	["PR_CO_PROFILEMANAGER_EDIT_POPUP"] = [=[Please enter a new name for this profile %s.
The name cannot be empty.

Changing the name will not change any link between this profile and your pets/mounts.]=],
	["PR_CO_PROFILEMANAGER_TITLE"] = "Companions profiles",
	["PR_CO_UNUSED_PROFILE"] = "This profile is currently not bound to any pet or mount.",
	["PR_CO_WARNING_RENAME"] = [=[|cffff0000Warning:|r it's strongly recommended that you rename your pet before linking it to a profile.

Link it anyway ?]=],
	["PR_CREATE_PROFILE"] = "Create profile",
	["PR_DEFAULT_PROFILE_NAME"] = "Default profile",
	["PR_DEFAULT_PROFILE_WARNING"] = [=[Create a new profile
or link to an existing one in Profiles
to edit your character's information.]=],
	["PR_DELETE_PROFILE"] = "Delete profile",
	["PR_DUPLICATE_PROFILE"] = "Duplicate profile",
	["PR_EXPORT_IMPORT_HELP"] = [=[You can export and import profiles using the options in the dropdown menu.

Use the |cffffff00Export profile|r option to generate a chunk of text containing the profile serialized data. You can copy the text using Control-C (or Command-C on a Mac) and paste it somewhere else as a backup. (|cffff0000Please note that some advanced text editing tools like Microsoft Word will reformat special characters like quotes, altering the data. Use simpler text editing tools like Notepad.|r)

Use the |cffffff00Import profile|r option to paste data from a previous export inside an existing profile. The existing data in this profile will be replaced by the ones you have pasted. You cannot import data directly into your currently selected profile.]=],
	["PR_EXPORT_IMPORT_TITLE"] = "Export/import profile",
	["PR_EXPORT_NAME"] = "Serial for profile %s (size %0.2f kB)",
	["PR_EXPORT_PROFILE"] = "Export profile",
	["PR_EXPORT_TOO_LARGE"] = [=[This profile is too large and can't be exported.

Size of profile: %0.2f kB
Max: 20 kB]=],
	["PR_EXPORT_WARNING_MAC"] = [=[Please note that some advanced text editing tools like Text Edit or Discord will reformat special characters like quotes, altering the content of the data.

If you are planning on copying the text below inside a document, please use simpler text editing tools that do not automatically change characters (in Text Edit go to Format > Make Plain Text before pasting)]=],
	["PR_EXPORT_WARNING_TITLE"] = "Warning:",
	["PR_EXPORT_WARNING_WINDOWS"] = [=[Please note that some advanced text editing tools like Microsoft Word or Discord will reformat special characters like quotes, altering the content of the data.

If you are planning on copying the text below inside a document, please use simpler text editing tools that do not automatically change characters, like Notepad.]=],
	["PR_IMPORT"] = "Import",
	["PR_IMPORT_CHAR_TAB"] = "Characters importer",
	["PR_IMPORT_EMPTY"] = "No importable profile",
	["PR_IMPORT_IMPORT_ALL"] = "Import all",
	["PR_IMPORT_PETS_TAB"] = "Companions importer",
	["PR_IMPORT_PROFILE"] = "Import profile",
	["PR_IMPORT_PROFILE_TT"] = "Paste a profile serial here",
	["PR_IMPORT_WILL_BE_IMPORTED"] = "Will be imported",
	["PR_PROFILE"] = "Profile",
	["PR_PROFILE_CREATED"] = "Profile %s created.",
	["PR_PROFILE_DELETED"] = "Profile %s deleted.",
	["PR_PROFILE_DETAIL"] = "This profile is currently bound to these WoW characters",
	["PR_PROFILE_HELP"] = [=[A profile contains all information about a |cffffff00"character"|r as a |cff00ff00roleplay character|r.

A real |cffffff00"WoW character"|r can be bound to only one profile at a time, but can switch from one to another whenever you want.

You can also bind several |cffffff00"WoW characters"|r to the same |cff00ff00profile|r !]=],
	["PR_PROFILE_LOADED"] = "The profile %s is loaded.",
	["PR_PROFILE_MANAGEMENT_TITLE"] = "Profile management",
	["PR_PROFILEMANAGER_ACTIONS"] = "Actions",
	["PR_PROFILEMANAGER_ALREADY_IN_USE"] = "The profile name %s is not available.",
	["PR_PROFILEMANAGER_COUNT"] = "%s WoW character(s) bound to this profile.",
	["PR_PROFILEMANAGER_CREATE_POPUP"] = [=[Please enter a name for the new profile.
The name cannot be empty.]=],
	["PR_PROFILEMANAGER_CURRENT"] = "Current profile",
	["PR_PROFILEMANAGER_DELETE_WARNING"] = [=[Are you sure you want to delete the profile %s?
This action cannot be undone and all TRP3 information linked to this profile (Character info, inventory, quest log, applied states ...) will be destroyed !]=],
	["PR_PROFILEMANAGER_DUPP_POPUP"] = [=[Please enter a name for the new profile.
The name cannot be empty.

This duplication will not change the character's binds to %s.]=],
	["PR_PROFILEMANAGER_EDIT_POPUP"] = [=[Please enter a new name for this profile %s.
The name cannot be empty.

Changing the name will not change any link between this profile and your characters.]=],
	["PR_PROFILEMANAGER_EMPTY"] = "No profiles found",
	["PR_PROFILEMANAGER_IMPORT_WARNING"] = "Replace all the content of profile %s with this imported data?",
	["PR_PROFILEMANAGER_IMPORT_WARNING_2"] = [=[Warning: this profile serial has been made from an older version of TRP3.
This can bring incompatibilities.

Replacing all the content of profile %s with this imported data?]=],
	["PR_PROFILEMANAGER_RENAME"] = "Rename profile",
	["PR_PROFILEMANAGER_SEARCH_PROFILE"] = "Search profile",
	["PR_PROFILEMANAGER_SWITCH"] = "Select profile",
	["PR_PROFILEMANAGER_TITLE"] = "Characters profiles",
	["PR_PROFILES"] = "Profiles",
	["PR_SLASH_EXAMPLE"] = "|cffffff00Command usage:|r |cffcccccc/trp3 profile Millidan Foamrage|r |cffffff00to switch to Millidan Foamrage's profile.|r",
	["PR_SLASH_NOT_FOUND"] = "|cffff0000Could not find a profile named|r |cffffff00%s|r|cffff0000.|r",
	["PR_SLASH_OPEN_ABORTING"] = "|cffffff00Aborted profile request.|r",
	["PR_SLASH_OPEN_EXAMPLE"] = "|cffffff00Command usage:|r |cffcccccc/trp3 open|r |cffffff00to open your target's profile or |cffcccccc/trp3 open CharacterName-RealmName|r |cffffff00to open that character's profile.|r",
	["PR_SLASH_OPEN_HELP"] = "Open a character's profile using its in-game name, or your target's profile if no name is provided.",
	["PR_SLASH_OPEN_WAITING"] = "|cffffff00Requesting profile, please wait...|r",
	["PR_SLASH_SWITCH_HELP"] = "Switch to another profile using its name.",
	["PR_UNUSED_PROFILE"] = "This profile is currently not bound to any WoW character.",
	["REG_CODE_INSERTION_WARNING"] = [=[
|TInterface\AddOns\totalRP3\resources\policegar.tga:50:50|t
Wait a minute!

We found that you have manually inserted invalid codes inside your Total RP 3 profile.
This behavior is not supported at all and we strongly discourage anyone from doing it.
It can lead to instabilities and bugs inside the add-on, data corruption/loss of profiles and it also creates incompatibility issues with other add-ons (such as MRP).

The codes you have inserted in your profile have been removed to prevent you from breaking the add-on.]=],
	["REG_COMPANION"] = "Companion",
	["REG_COMPANION_BIND_TO_PET"] = "Pet",
	["REG_COMPANION_BOUND_TO"] = "Bound to ...",
	["REG_COMPANION_BOUND_TO_TARGET"] = "Target",
	["REG_COMPANION_BOUNDS"] = "Binds",
	["REG_COMPANION_BROWSER_BATTLE"] = "Battle pet browser",
	["REG_COMPANION_BROWSER_MOUNT"] = "Mount browser",
	["REG_COMPANION_INFO"] = "Information",
	["REG_COMPANION_LINKED"] = "The companion %s is now linked to the profile %s.",
	["REG_COMPANION_LINKED_NO"] = "The companion %s is no longer linked to any profile.",
	["REG_COMPANION_NAME"] = "Name",
	["REG_COMPANION_NAME_COLOR"] = "Name color",
	["REG_COMPANION_PAGE_TUTO_C_1"] = "Consult",
	["REG_COMPANION_PAGE_TUTO_E_1"] = [=[This is |cff00ff00your companion main information|r.

All these information will appear on |cffff9900your companion's tooltip|r.]=],
	["REG_COMPANION_PAGE_TUTO_E_2"] = [=[This is |cff00ff00your companion description|r.

It isn't limited to |cffff9900physical description|r. Feel free to indicate parts from their |cffff9900background|r or details about their |cffff9900personality|r.

There are a lot of ways to customize the description.
You can choose a |cffffff00background texture|r for the description. You can also use the formatting tools to access several layout parameters like |cffffff00texts sizes, colors and alignments|r.
These tools also allow you to insert |cffffff00images, icons or links to external web sites|r.]=],
	["REG_COMPANION_PROFILES"] = "Companions profiles",
	["REG_COMPANION_TARGET_NO"] = "Your target is not a valid pet, minion, ghoul, mage elemental or a renamed battle pet.",
	["REG_COMPANION_TF_BOUND_TO"] = "Select a profile",
	["REG_COMPANION_TF_CREATE"] = "Create new profile",
	["REG_COMPANION_TF_NO"] = "No profile",
	["REG_COMPANION_TF_OPEN"] = "Open page",
	["REG_COMPANION_TF_OWNER"] = "Owner: %s",
	["REG_COMPANION_TF_PROFILE"] = "Companion profile",
	["REG_COMPANION_TF_PROFILE_MOUNT"] = "Mount profile",
	["REG_COMPANION_TF_UNBOUND"] = "Unlink from profile",
	["REG_COMPANION_TITLE"] = "Title",
	["REG_COMPANION_UNBOUND"] = "Unbound from ...",
	["REG_COMPANIONS"] = "Companions",
	["REG_DELETE_WARNING"] = [=[Are you sure you want to delete %s's profile?
]=],
	["REG_IGNORE_TOAST"] = "Character ignored",
	["REG_LIST_ACTIONS_MASS"] = "Action on %s selected profiles",
	["REG_LIST_ACTIONS_MASS_IGNORE"] = "Ignore profiles",
	["REG_LIST_ACTIONS_MASS_IGNORE_C"] = [=[This action will add |cff00ff00%s character(s)|r to the ignore list.

You can optionally enter the reason below. This is a personal note, it will serve as a reminder.]=],
	["REG_LIST_ACTIONS_MASS_REMOVE"] = "Remove profiles",
	["REG_LIST_ACTIONS_MASS_REMOVE_C"] = "This action will remove |cff00ff00%s selected profile(s)|r.",
	["REG_LIST_ACTIONS_PURGE"] = "Purge register",
	["REG_LIST_ACTIONS_PURGE_ALL"] = "Remove all profiles",
	["REG_LIST_ACTIONS_PURGE_ALL_C"] = [=[This purge will remove all profiles and linked characters from the directory.

|cff00ff00%s characters.]=],
	["REG_LIST_ACTIONS_PURGE_ALL_COMP_C"] = [=[This purge will remove all companions from the directory.

|cff00ff00%s companions.]=],
	["REG_LIST_ACTIONS_PURGE_COUNT"] = "%s profiles will be removed.",
	["REG_LIST_ACTIONS_PURGE_EMPTY"] = "No profile to purge.",
	["REG_LIST_ACTIONS_PURGE_IGNORE"] = "Profiles from ignored characters",
	["REG_LIST_ACTIONS_PURGE_IGNORE_C"] = [=[This purge will remove all profiles linked to an ignored WoW character.

|cff00ff00%s]=],
	["REG_LIST_ACTIONS_PURGE_TIME"] = "Profiles not seen for 1 month",
	["REG_LIST_ACTIONS_PURGE_TIME_C"] = [=[This purge will remove all profiles that have not been seen for a month.

|cff00ff00%s]=],
	["REG_LIST_ACTIONS_PURGE_UNLINKED"] = "Profiles not bound to a character",
	["REG_LIST_ACTIONS_PURGE_UNLINKED_C"] = [=[This purge will remove all profiles that are not bound to a WoW character.

|cff00ff00%s]=],
	["REG_LIST_ADDON"] = "Profile type",
	["REG_LIST_CHAR_EMPTY"] = "No character",
	["REG_LIST_CHAR_EMPTY2"] = "No character matches your selection",
	["REG_LIST_CHAR_FILTER"] = "Characters: %s / %s",
	["REG_LIST_CHAR_IGNORED"] = "Ignored",
	["REG_LIST_CHAR_NAME_COPY"] = "Copy character name",
	["REG_LIST_CHAR_SEL"] = "Selected character",
	["REG_LIST_CHAR_TITLE"] = "Character list",
	["REG_LIST_CHAR_TT"] = "Click to show page",
	["REG_LIST_CHAR_TT_CHAR"] = "Bound WoW character(s):",
	["REG_LIST_CHAR_TT_CHAR_NO"] = "Not bound to any character",
	["REG_LIST_CHAR_TT_DATE"] = [=[Last seen date: |cff00ff00%s|r
Last seen location: |cff00ff00%s|r]=],
	["REG_LIST_CHAR_TT_GLANCE"] = "At first glance",
	["REG_LIST_CHAR_TT_IGNORE"] = "Ignored character(s)",
	["REG_LIST_CHAR_TT_NEW_ABOUT"] = "Unread description",
	["REG_LIST_CHAR_TT_RELATION"] = [=[Relation:
|cff00ff00%s]=],
	["REG_LIST_CHAR_TUTO_ACTIONS"] = "This column allows you to select multiple characters and perform an action on all of them.",
	["REG_LIST_CHAR_TUTO_FILTER"] = [=[You can filter the character list.

The |cff00ff00name filter|r will perform a search on the profile full name (first name + last name) but also on any bound WoW characters.

The |cff00ff00guild filter|r will search on guild name from bound WoW characters.

The |cff00ff00realm only filter|r will show only profiles bound to a WoW character of your current realm.]=],
	["REG_LIST_CHAR_TUTO_LIST"] = [=[The first column shows the character's name.

The second column shows the relation between these characters and your current character.

The last column is for various flags. (ignored ..etc.)]=],
	["REG_LIST_FILTERS"] = "Filters",
	["REG_LIST_FILTERS_TT"] = [=[|cffffff00Click:|r Apply filters
|cffffff00Right-Click:|r Clear filters]=],
	["REG_LIST_FLAGS"] = "Flags",
	["REG_LIST_GUILD"] = "Character's guild",
	["REG_LIST_IGNORE_EMPTY"] = "No ignored character",
	["REG_LIST_IGNORE_TITLE"] = "Ignored list",
	["REG_LIST_IGNORE_TT"] = [=[Reason:
|cff00ff00%s

|cffffff00Click to remove from ignore list]=],
	["REG_LIST_NAME"] = "Character's name",
	["REG_LIST_NOTESONLY"] = "Has notes only",
	["REG_LIST_NOTIF_ADD"] = "New profile discovered for |cff00ff00%s",
	["REG_LIST_NOTIF_ADD_CONFIG"] = "New profile discovered",
	["REG_LIST_NOTIF_ADD_NOT"] = "This profile doesn't exist anymore.",
	["REG_LIST_PET_MASTER"] = "Master's name",
	["REG_LIST_PET_NAME"] = "Companion's name",
	["REG_LIST_PET_TYPE"] = "Companion's type",
	["REG_LIST_PETS_EMPTY"] = "No companion",
	["REG_LIST_PETS_EMPTY2"] = "No companion matches your selection",
	["REG_LIST_PETS_FILTER"] = "Companions: %s / %s",
	["REG_LIST_PETS_TITLE"] = "Companion list",
	["REG_LIST_PETS_TOOLTIP"] = "Has been seen on",
	["REG_LIST_PETS_TOOLTIP2"] = "Has been seen with",
	["REG_LIST_REALMONLY"] = "This realm only",
	["REG_LOCATION_DIFFERENT_WAR_MODE"] = "Different War Mode",
	["REG_MSP_ALERT"] = [=[|cffff0000WARNING

You can't have simultaneously more than one addon using the Mary Sue Protocol, as they would be in conflict.|r

Currently loaded: |cff00ff00%s

|cffff9900Therefore the MSP support for Total RP3 will be disabled.|r

If you don't want TRP3 to be your MSP addon and don't want to see this alert again, you can disable the Mary Sue Protocol module in the TRP3 Settings -> Module status.]=],
	["REG_NOTES_PROFILE"] = "Notes",
	["REG_NOTES_PROFILE_TT"] = "Open the notes window for the target character.",
	["REG_PLAYER"] = "Character",
	["REG_PLAYER_ABOUT"] = "About",
	["REG_PLAYER_ABOUT_ADD_FRAME"] = "Add a frame",
	["REG_PLAYER_ABOUT_EMPTY"] = "No description",
	["REG_PLAYER_ABOUT_HEADER"] = "Title tag",
	["REG_PLAYER_ABOUT_MUSIC"] = "Character theme",
	["REG_PLAYER_ABOUT_MUSIC_LISTEN"] = "Play theme",
	["REG_PLAYER_ABOUT_MUSIC_REMOVE"] = "Unselect theme",
	["REG_PLAYER_ABOUT_MUSIC_SELECT"] = "Select character theme",
	["REG_PLAYER_ABOUT_MUSIC_SELECT2"] = "Select theme",
	["REG_PLAYER_ABOUT_MUSIC_STOP"] = "Stop theme",
	["REG_PLAYER_ABOUT_MUSIC_THEME"] = "Character music theme",
	["REG_PLAYER_ABOUT_NOMUSIC"] = "|cffff9900No theme",
	["REG_PLAYER_ABOUT_P"] = "Paragraph tag",
	["REG_PLAYER_ABOUT_REMOVE_FRAME"] = "Remove this frame",
	["REG_PLAYER_ABOUT_SOME"] = "Some text ...",
	["REG_PLAYER_ABOUT_T1_YOURTEXT"] = "Your text here",
	["REG_PLAYER_ABOUT_TAGS"] = "Formatting tools",
	["REG_PLAYER_ABOUT_UNMUSIC"] = "|cffff9900Unknown theme",
	["REG_PLAYER_ABOUT_VOTE_DOWN"] = "I don't like this content",
	["REG_PLAYER_ABOUT_VOTE_NO"] = [=[No characters linked to this profile seem to be online.
Do you want to force Total RP 3 to send your vote anyway ?]=],
	["REG_PLAYER_ABOUT_VOTE_SENDING"] = "Sending your vote to %s ...",
	["REG_PLAYER_ABOUT_VOTE_SENDING_OK"] = "Your vote has been sent to %s !",
	["REG_PLAYER_ABOUT_VOTE_TT"] = "Your vote is totally anonymous and can only be seen by this player.",
	["REG_PLAYER_ABOUT_VOTE_TT2"] = "You can vote only if the player is online.",
	["REG_PLAYER_ABOUT_VOTE_UP"] = "I like this content",
	["REG_PLAYER_ABOUT_VOTES"] = "Statistics",
	["REG_PLAYER_ABOUT_VOTES_R"] = [=[|cff00ff00%s like this content
|cffff0000%s dislike this content]=],
	["REG_PLAYER_ABOUTS"] = "About %s",
	["REG_PLAYER_ADD_NEW"] = "Create new",
	["REG_PLAYER_AGE"] = "Age",
	["REG_PLAYER_AGE_TT"] = [=[Here you can indicate how old your character is.

There are several ways to do this:|c0000ff00
- Either use years,
- Or an adjective (Young, Mature, Adult, Venerable, etc.).]=],
	["REG_PLAYER_ALERT_HEAVY_SMALL"] = [=[|cffff0000The total size of your profile is quite big.
|cffff9900You should reduce it.]=],
	["REG_PLAYER_BIRTHPLACE"] = "Birthplace",
	["REG_PLAYER_BIRTHPLACE_TT"] = [=[Here you can indicate the birthplace of your character. This can either be a region, a zone, or even a continent. It's for you to decide how accurate you want to be.

|c00ffff00You can use the button to the right to easily set your current location as Birthplace.]=],
	["REG_PLAYER_BKG"] = "Background layout",
	["REG_PLAYER_BKG_TT"] = "This represents the graphical background to use for your Characteristics layout.",
	["REG_PLAYER_CARACT"] = "Characteristics",
	["REG_PLAYER_CHANGE_CONFIRM"] = [=[You may have unsaved data changes.
Do you want to change page anyway ?
|cffff9900Any changes will be lost.]=],
	["REG_PLAYER_CHARACTERISTICS"] = "Characteristics",
	["REG_PLAYER_CLASS"] = "Class",
	["REG_PLAYER_CLASS_TT"] = [=[This is your character's custom class.

|cff00ff00For instance :|r
Knight, Pyrotechnist, Necromancer, Elite shooter, Arcanist ...]=],
	["REG_PLAYER_COLOR_ALWAYS_DEFAULT_TT"] = [=[|cffffff00Click:|r Select a color
|cffffff00Right-click:|r Discard color]=],
	["REG_PLAYER_COLOR_CLASS"] = "Class color",
	["REG_PLAYER_COLOR_CLASS_TT"] = [=[This will also determine the name color.

]=],
	["REG_PLAYER_COLOR_TT"] = [=[|cffffff00Click:|r Select a color
|cffffff00Right-click:|r Discard color
|cffffff00Shift-Click:|r Use the default color picker]=],
	["REG_PLAYER_CURRENT"] = "Currently",
	["REG_PLAYER_CURRENT_OOC"] = "This is OOC information",
	["REG_PLAYER_CURRENTOOC"] = "Currently (OOC)",
	["REG_PLAYER_EDIT_MUSIC_THEME"] = "Music theme",
	["REG_PLAYER_EYE"] = "Eye color",
	["REG_PLAYER_EYE_TT"] = [=[Here you can indicate the color of your character's eyes.

Keep in mind that, even if your character's face is constantly hidden, that might still be worth mentioning, just in case.]=],
	["REG_PLAYER_FIRSTNAME"] = "First name",
	["REG_PLAYER_FIRSTNAME_TT"] = [=[This is your character's first name. This is a mandatory field, so if you don't specify a name, the default character's name (|cffffff00%s|r) will be used.

You can use a |c0000ff00nickname |r!]=],
	["REG_PLAYER_FULLTITLE"] = "Full title",
	["REG_PLAYER_FULLTITLE_TT"] = [=[Here you can write down your character's full title. It can either be a longer version of the Title or another title entirely.

However, you may want to avoid repetitions, in case there's no additional info to mention.]=],
	["REG_PLAYER_GLANCE"] = "At first glance",
	["REG_PLAYER_GLANCE_BAR_DELETED"] = "Group preset |cffff9900%s|r deleted.",
	["REG_PLAYER_GLANCE_BAR_EMPTY"] = "The preset name can't be empty.",
	["REG_PLAYER_GLANCE_BAR_LOAD"] = "Group preset",
	["REG_PLAYER_GLANCE_BAR_LOAD_SAVE"] = "Group presets",
	["REG_PLAYER_GLANCE_BAR_NAME"] = [=[Please enter the preset name.

|cff00ff00Note: If the name is already used by another group preset, this other group will be replaced.]=],
	["REG_PLAYER_GLANCE_BAR_SAVE"] = "Save group as a preset",
	["REG_PLAYER_GLANCE_BAR_SAVED"] = "Group preset |cff00ff00%s|r has been created.",
	["REG_PLAYER_GLANCE_BAR_TARGET"] = "\"At first glance\" presets",
	["REG_PLAYER_GLANCE_CONFIG"] = [=[|cff00ff00"At first glance"|r is a set of slots you can use to define important information about this character.

You can use these actions on the slots:
|cffffff00Click:|r configure slot
|cffffff00Double-click:|r toggle slot activation
|cffffff00Right-click:|r slot presets
|cffffff00Drag & drop:|r reorder slots]=],
	["REG_PLAYER_GLANCE_EDITOR"] = "Glance editor : Slot %s",
	["REG_PLAYER_GLANCE_MENU_COPY"] = "Copy slot",
	["REG_PLAYER_GLANCE_MENU_PASTE"] = "Paste slot: %s",
	["REG_PLAYER_GLANCE_PRESET"] = "Load a preset",
	["REG_PLAYER_GLANCE_PRESET_ADD"] = "Created preset |cff00ff00%s|r.",
	["REG_PLAYER_GLANCE_PRESET_ALERT1"] = "You must enter a preset category.",
	["REG_PLAYER_GLANCE_PRESET_CATEGORY"] = "Preset category",
	["REG_PLAYER_GLANCE_PRESET_CREATE"] = "Create preset",
	["REG_PLAYER_GLANCE_PRESET_GET_CAT"] = [=[%s

Please enter the category name for this preset.]=],
	["REG_PLAYER_GLANCE_PRESET_NAME"] = "Preset name",
	["REG_PLAYER_GLANCE_PRESET_REMOVE"] = "Removed preset |cff00ff00%s|r.",
	["REG_PLAYER_GLANCE_PRESET_SAVE"] = "Save information as a preset",
	["REG_PLAYER_GLANCE_PRESET_SAVE_SMALL"] = "Save as a preset",
	["REG_PLAYER_GLANCE_PRESET_SELECT"] = "Select a preset",
	["REG_PLAYER_GLANCE_TITLE"] = "Attribute name",
	["REG_PLAYER_GLANCE_UNUSED"] = "Unused slot",
	["REG_PLAYER_GLANCE_USE"] = "Activate this slot",
	["REG_PLAYER_HEIGHT"] = "Height",
	["REG_PLAYER_HEIGHT_TT"] = [=[This is your character's height.
There are several ways to do this:|c0000ff00
- A precise number: 170 cm, 6'5" ...
- A qualificative: Tall, short ...]=],
	["REG_PLAYER_HERE"] = "Set position",
	["REG_PLAYER_HERE_HOME_PRE_TT"] = [=[Current house map coordinates:
|cff00ff00%s|r.]=],
	["REG_PLAYER_HERE_HOME_TT"] = [=[|cffffff00Click|r: Use your current coordinates as your house position.
|cffffff00Right-click|r: Discard your house position.]=],
	["REG_PLAYER_HERE_TT"] = "|cffffff00Click|r: Set to your current position",
	["REG_PLAYER_HISTORY"] = "History",
	["REG_PLAYER_ICON"] = "Character's icon",
	["REG_PLAYER_ICON_TT"] = "Select a graphic representation for your character.",
	["REG_PLAYER_IGNORE"] = "Ignore linked characters (%s)",
	["REG_PLAYER_IGNORE_WARNING"] = [=[Do you want to ignore those characters ?

|cffff9900%s

|rYou can optionally enter the reason below. This is a personal note that will serve as reminder.]=],
	["REG_PLAYER_LASTNAME"] = "Last name",
	["REG_PLAYER_LASTNAME_TT"] = "This is your character's family name.",
	["REG_PLAYER_LEFTTRAIT"] = "Left attribute",
	["REG_PLAYER_MISC_ADD"] = "Add an additional field",
	["REG_PLAYER_MISC_PRESET_PRONOUNS"] = "Pronouns",
	["REG_PLAYER_MORE_INFO"] = "Additional Information",
	["REG_PLAYER_MSP_HOUSE"] = "House name",
	["REG_PLAYER_MSP_MOTTO"] = "Motto",
	["REG_PLAYER_MSP_NICK"] = "Nickname",
	["REG_PLAYER_NAMESTITLES"] = "Names and titles",
	["REG_PLAYER_NO_CHAR"] = "No characteristics",
	["REG_PLAYER_NOTES"] = "Notes",
	["REG_PLAYER_NOTES_ACCOUNT"] = "Common notes",
	["REG_PLAYER_NOTES_ACCOUNT_HELP"] = "These private notes are tied to your account and will be shared with all of your profiles.",
	["REG_PLAYER_NOTES_PROFILE"] = "Notes from %s",
	["REG_PLAYER_NOTES_PROFILE_HELP"] = "These private notes are tied to your current profile and will change based on what profile you currently have active.",
	["REG_PLAYER_NOTES_PROFILE_NONAME"] = "Profile notes",
	["REG_PLAYER_PEEK"] = "Miscellaneous",
	["REG_PLAYER_PHYSICAL"] = "Physical Description",
	["REG_PLAYER_PSYCHO"] = "Personality Traits",
	["REG_PLAYER_PSYCHO_Acete"] = "Ascetic",
	["REG_PLAYER_PSYCHO_ADD"] = "Add a personality trait",
	["REG_PLAYER_PSYCHO_ATTIBUTENAME_TT"] = "Attribute name",
	["REG_PLAYER_PSYCHO_Bonvivant"] = "Bon vivant",
	["REG_PLAYER_PSYCHO_CHAOTIC"] = "Chaotic",
	["REG_PLAYER_PSYCHO_Chaste"] = "Chaste",
	["REG_PLAYER_PSYCHO_Conciliant"] = "Paragon",
	["REG_PLAYER_PSYCHO_Couard"] = "Spineless",
	["REG_PLAYER_PSYCHO_CREATENEW"] = "Create a trait",
	["REG_PLAYER_PSYCHO_Cruel"] = "Brutal",
	["REG_PLAYER_PSYCHO_CUSTOM"] = "Custom trait",
	["REG_PLAYER_PSYCHO_CUSTOMCOLOR"] = "Select attribute color",
	["REG_PLAYER_PSYCHO_CUSTOMCOLOR_LEFT_TT"] = [=[Select a color used by the bar for the left attribute.

|cffffff00Click:|r Select a color
|cffffff00Right-click:|r Discard color
|cffffff00Shift-Click:|r Use the default color picker]=],
	["REG_PLAYER_PSYCHO_CUSTOMCOLOR_RIGHT_TT"] = [=[Select a color used by the bar for the right attribute.

|cffffff00Click:|r Select a color
|cffffff00Right-click:|r Discard color
|cffffff00Shift-Click:|r Use the default color picker]=],
	["REG_PLAYER_PSYCHO_Egoiste"] = "Selfish",
	["REG_PLAYER_PSYCHO_Genereux"] = "Altruistic",
	["REG_PLAYER_PSYCHO_Impulsif"] = "Impulsive",
	["REG_PLAYER_PSYCHO_Indulgent"] = "Forgiving",
	["REG_PLAYER_PSYCHO_LEFTICON_TT"] = "Set the left attribute icon.",
	["REG_PLAYER_PSYCHO_Loyal"] = "Lawful",
	["REG_PLAYER_PSYCHO_Luxurieux"] = "Lustful",
	["REG_PLAYER_PSYCHO_Misericordieux"] = "Gentle",
	["REG_PLAYER_PSYCHO_MORE"] = "Add a point to \"%s\"",
	["REG_PLAYER_PSYCHO_PERSONAL"] = "Personal traits",
	["REG_PLAYER_PSYCHO_Pieux"] = "Superstitious",
	["REG_PLAYER_PSYCHO_POINT"] = "Add a point",
	["REG_PLAYER_PSYCHO_Pragmatique"] = "Renegade",
	["REG_PLAYER_PSYCHO_Rationnel"] = "Rational",
	["REG_PLAYER_PSYCHO_Reflechi"] = "Cautious",
	["REG_PLAYER_PSYCHO_Rencunier"] = "Vindictive",
	["REG_PLAYER_PSYCHO_RIGHTICON_TT"] = "Set the right attribute icon.",
	["REG_PLAYER_PSYCHO_Sincere"] = "Truthful",
	["REG_PLAYER_PSYCHO_SOCIAL"] = "Social traits",
	["REG_PLAYER_PSYCHO_Trompeur"] = "Deceitful",
	["REG_PLAYER_PSYCHO_Valeureux"] = "Valorous",
	["REG_PLAYER_RACE"] = "Race",
	["REG_PLAYER_RACE_TT"] = "Here goes your character's race. It doesn't have to be restricted to playable races. There are many Warcraft races that can assume common shapes ...",
	["REG_PLAYER_REGISTER"] = "Directory Information",
	["REG_PLAYER_RELATIONSHIP_STATUS"] = "Relationship status",
	["REG_PLAYER_RELATIONSHIP_STATUS_DIVORCED"] = "Divorced",
	["REG_PLAYER_RELATIONSHIP_STATUS_MARRIED"] = "Married",
	["REG_PLAYER_RELATIONSHIP_STATUS_SINGLE"] = "Single",
	["REG_PLAYER_RELATIONSHIP_STATUS_TAKEN"] = "Taken",
	["REG_PLAYER_RELATIONSHIP_STATUS_TT"] = "Indicate the relationship status of your character. Select \"Do not show\" if you wish to keep that information hidden.",
	["REG_PLAYER_RELATIONSHIP_STATUS_UNKNOWN"] = "Do not show",
	["REG_PLAYER_RELATIONSHIP_STATUS_WIDOWED"] = "Widowed",
	["REG_PLAYER_RESIDENCE"] = "Residence",
	["REG_PLAYER_RESIDENCE_SHOW"] = "Residence coordinates",
	["REG_PLAYER_RESIDENCE_SHOW_TT"] = [=[|cff00ff00%s

|rClick to show on map]=],
	["REG_PLAYER_RESIDENCE_TT"] = [=[Here you can indicate where your character normally lives. This could be their personal address (their home) or a place they can crash.
Note that if your character is a wanderer or even homeless, you will need to change the information accordingly.

|c00ffff00You can use the button to the right to easily set your current location as Residence.]=],
	["REG_PLAYER_RIGHTTRAIT"] = "Right attribute",
	["REG_PLAYER_SHOWMISC"] = "Show miscellaneous frame",
	["REG_PLAYER_SHOWMISC_TT"] = [=[Check if you want to show custom fields for your character.

If you don't want to show custom fields, keep this box unchecked and the miscellaneous frame will remain totally hidden.]=],
	["REG_PLAYER_SHOWPSYCHO"] = "Show personality frame",
	["REG_PLAYER_SHOWPSYCHO_TT"] = [=[Check if you want to use the personality description.

If you don't want to indicate your character's personality this way, keep this box unchecked and the personality frame will remain totally hidden.]=],
	["REG_PLAYER_STYLE_ASSIST"] = "Roleplay assistance",
	["REG_PLAYER_STYLE_BATTLE"] = "Roleplay battle resolution",
	["REG_PLAYER_STYLE_BATTLE_1"] = "World of Warcraft PvP",
	["REG_PLAYER_STYLE_BATTLE_2"] = "TRP roll battle",
	["REG_PLAYER_STYLE_BATTLE_3"] = "/roll battle",
	["REG_PLAYER_STYLE_BATTLE_4"] = "Emote battle",
	["REG_PLAYER_STYLE_DEATH"] = "Accept character death",
	["REG_PLAYER_STYLE_EMPTY"] = "No roleplay attribute shared",
	["REG_PLAYER_STYLE_FREQ"] = "In-character frequence",
	["REG_PLAYER_STYLE_FREQ_1"] = "Full-time, no OOC",
	["REG_PLAYER_STYLE_FREQ_2"] = "Most of the time",
	["REG_PLAYER_STYLE_FREQ_3"] = "Mid-time",
	["REG_PLAYER_STYLE_FREQ_4"] = "Casual",
	["REG_PLAYER_STYLE_FREQ_5"] = "Full-time OOC, not a RP character",
	["REG_PLAYER_STYLE_GUILD"] = "Guild membership",
	["REG_PLAYER_STYLE_GUILD_IC"] = "IC membership",
	["REG_PLAYER_STYLE_GUILD_OOC"] = "OOC membership",
	["REG_PLAYER_STYLE_HIDE"] = "Do not show",
	["REG_PLAYER_STYLE_INJURY"] = "Accept character injury",
	["REG_PLAYER_STYLE_PERMI"] = "With player permission",
	["REG_PLAYER_STYLE_ROMANCE"] = "Accept character romance",
	["REG_PLAYER_STYLE_RPSTYLE"] = "Roleplay style",
	["REG_PLAYER_STYLE_RPSTYLE_SHORT"] = "RP style",
	["REG_PLAYER_STYLE_WOWXP"] = "World of Warcraft experience",
	["REG_PLAYER_TITLE"] = "Title",
	["REG_PLAYER_TITLE_TT"] = [=[Your character's title is the title by which your character is usually called. Avoid long titles, as for those you should use the Full title attribute below.

Example of |c0000ff00appropriate titles |r:
|c0000ff00- Countess,
- Marquis,
- Magus,
- Lord,
- etc.
|rExample of |cffff0000inappropriate titles|r:
|cffff0000- Countess of the North Marshes,
- Magus of the Stormwind Tower,
- Diplomat for the Draenei Government,
- etc.]=],
	["REG_PLAYER_TRP2_PIERCING"] = "Piercings",
	["REG_PLAYER_TRP2_TATTOO"] = "Tattoos",
	["REG_PLAYER_TRP2_TRAITS"] = "Physiognomy",
	["REG_PLAYER_TUTO_ABOUT_COMMON"] = [=[|cff00ff00Character theme:|r
You can choose a |cffffff00theme|r for your character. Think of it as an |cffffff00ambiance music for reading your character description|r.

|cff00ff00Background:|r
This is a |cffffff00background texture|r for your character description.

|cff00ff00Template:|r
The chosen template defines |cffffff00the general layout and writing possibilities|r for your description.
|cffff9900Only the selected template is visible by others, so you don't have to fill them all.|r
Once a template is selected, you can open this tutorial again to have more help about each template.]=],
	["REG_PLAYER_TUTO_ABOUT_MISC_1"] = [=[This section provides you |cffffff005 slots|r with which you can describe |cff00ff00the most important pieces of information about your character|r.

These slots will be visible on the |cffffff00"At first glance bar"|r when someone selects your character.

|cff00ff00Hint: You can drag & drop slots to reorder them.|r
It also works on the |cffffff00"At first glance" bar|r!]=],
	["REG_PLAYER_TUTO_ABOUT_MISC_3"] = "This section contains |cffffff00a list of flags|r to answer a lot of |cffffff00common questions people could ask about you, your character and the way you want to play him/her|r.",
	["REG_PLAYER_TUTO_ABOUT_T1"] = [=[This template allows you to |cff00ff00freely structure your description|r.

The description doesn't have to be limited to your character's |cffff9900physical description|r. Feel free to indicate parts from their |cffff9900background|r or details about their |cffff9900personality|r.

With this template you can use the formatting tools to access several layout parameters like |cffffff00texts sizes, colors and alignments|r.
These tools also allow you to insert |cffffff00images, icons or links to external web sites|r.]=],
	["REG_PLAYER_TUTO_ABOUT_T2"] = [=[This template is more structured and consist of |cff00ff00a list of independent frames|r.

Each frame is caracterized by an |cffffff00icon, a background and a text|r. Note that you can use some text tags in these frames, like the color and the icon text tags.

The description doesn't have to be limited to your character's |cffff9900physical description|r. Feel free to indicate parts from their |cffff9900background|r or details about their |cffff9900personality|r.]=],
	["REG_PLAYER_TUTO_ABOUT_T3"] = [=[This template is cut in 3 sections: |cff00ff00Physical description, personality and history|r.

You don't have to fill all the frames, |cffff9900if you leave an empty frame it won't be shown on your description|r.

Each frame is caracterized by an |cffffff00icon, a background and a text|r. Note that you can use some text tags in these frames, like the color and the icon text tags.]=],
	["REG_PLAYER_WEIGHT"] = "Body shape",
	["REG_PLAYER_WEIGHT_TT"] = [=[This is your character's body shape.
For instance they could be |c0000ff00slim, fat or muscular...|r Or they could simply be regular !]=],
	["REG_PLAYERS"] = "Players",
	["REG_REGISTER"] = "Directory",
	["REG_REGISTER_CHAR_LIST"] = "Characters list",
	["REG_RELATION"] = "Relationship",
	["REG_RELATION_BUSINESS"] = "Business",
	["REG_RELATION_BUSINESS_TT"] = "%s and %s are in a business relationship.",
	["REG_RELATION_BUTTON_TT"] = [=[Relation: %s
|cff00ff00%s

|cffffff00Click to display possible actions]=],
	["REG_RELATION_FAMILY"] = "Family",
	["REG_RELATION_FAMILY_TT"] = "%s shares blood ties with %s.",
	["REG_RELATION_FRIEND"] = "Friendly",
	["REG_RELATION_FRIEND_TT"] = "%s considers %s a friend.",
	["REG_RELATION_LOVE"] = "Love",
	["REG_RELATION_LOVE_TT"] = "%s is in love with %s !",
	["REG_RELATION_NEUTRAL"] = "Neutral",
	["REG_RELATION_NEUTRAL_TT"] = "%s doesn't feel anything particular toward %s.",
	["REG_RELATION_NONE"] = "None",
	["REG_RELATION_NONE_TT"] = "%s doesn't know %s.",
	["REG_RELATION_TARGET"] = "|cffffff00Click: |rChange relation",
	["REG_RELATION_UNFRIENDLY"] = "Unfriendly",
	["REG_RELATION_UNFRIENDLY_TT"] = "%s clearly doesn't like %s.",
	["REG_REPORT_PLAYER_OPEN_URL"] = [=[You can only report players directly from within the game if you can target them (use TRP3's target frame button).

If you wish to report %s's profile and you cannot target them you will need to open a ticket with Blizzard's support using the link bellow.]=],
	["REG_REPORT_PLAYER_OPEN_URL_160"] = "If you wish to report %s's profile, you will need to open a ticket with Blizzard's support using the link below.",
	["REG_REPORT_PLAYER_PROFILE"] = "Report profile to |cff449fe0Blizzard|r",
	["REG_REPORT_PLAYER_PROFILE_TT"] = [=[You can report a profile that infringe on Blizzard's Terms of Service. This can include harassment, doxxing, hate speech, obscene content or other form of disruptive content.

|cffff0000Please note that this option is NOT to report RP profiles of disputable quality or griefing. Abuses of this feature are punishable!]=],
	["REG_REPORT_PLAYER_TEMPLATE"] = "This player is using the RP profile addon %s to share content against the Terms of Service.",
	["REG_REPORT_PLAYER_TEMPLATE_DATE"] = "The addon data was transferred through logged addon messages on %s.",
	["REG_REPORT_PLAYER_TEMPLATE_TRIAL_ACCOUNT"] = "This player was on a trial account.",
	["REG_TIME"] = "Time last seen",
	["REG_TRIAL_ACCOUNT"] = "Trial Account",
	["REG_TT_GUILD"] = "%s of |cffff9900%s",
	["REG_TT_GUILD_IC"] = "IC member",
	["REG_TT_GUILD_OOC"] = "OOC member",
	["REG_TT_IGNORED"] = "< Character is ignored >",
	["REG_TT_IGNORED_OWNER"] = "< Owner is ignored >",
	["REG_TT_LEVEL"] = "Level %s %s",
	["REG_TT_NOTIF"] = "Unread description",
	["REG_TT_REALM"] = "Realm: |cffff9900%s",
	["REG_TT_TARGET"] = "Target: |cffff9900%s",
	["REG_TT_ZONE"] = "Zone",
	["SCRIPT_ERROR"] = "Error in script.",
	["SCRIPT_UNKNOWN_EFFECT"] = "Script error, unknown FX",
	["SLASH_CMD_STATUS_HELP"] = [=[Usage: |cff00ff00/trp3 status ic || ooc || toggle|r
Changes your character status to the specified option:

|cffff9900/trp3 status ic|r will set your status to |cff00ff00in character|r.
|cffff9900/trp3 status ooc|r will set your status to |cffff0000out of character|r.
|cffff9900/trp3 status toggle|r will switch your status to the opposite state.]=],
	["SLASH_CMD_STATUS_USAGE"] = "ic || ooc || toggle",
	["TB_AFK_MODE"] = "Away",
	["TB_DND_MODE"] = "Do not disturb",
	["TB_GO_TO_MODE"] = "Switch to %s mode",
	["TB_LANGUAGE"] = "Language",
	["TB_LANGUAGES_TT"] = "Change language",
	["TB_NORMAL_MODE"] = "Normal",
	["TB_RPSTATUS_OFF"] = "Character: |cffff0000Out of character",
	["TB_RPSTATUS_ON"] = "Character: |cff00ff00In character",
	["TB_RPSTATUS_TO_OFF"] = "Go |cffff0000out of character",
	["TB_RPSTATUS_TO_ON"] = "Go |cff00ff00in character",
	["TB_STATUS"] = "Player",
	["TB_SWITCH_CAPE_1"] = "Show cloak",
	["TB_SWITCH_CAPE_2"] = "Hide cloak",
	["TB_SWITCH_CAPE_OFF"] = "Cloak: |cffff0000Hidden",
	["TB_SWITCH_CAPE_ON"] = "Cloak: |cff00ff00Shown",
	["TB_SWITCH_HELM_1"] = "Show helmet",
	["TB_SWITCH_HELM_2"] = "Hide helmet",
	["TB_SWITCH_HELM_OFF"] = "Helm: |cffff0000Hidden",
	["TB_SWITCH_HELM_ON"] = "Helm: |cff00ff00Shown",
	["TB_SWITCH_PROFILE"] = "Switch to another profile",
	["TB_SWITCH_TOOLBAR"] = "Switch toolbar",
	["TB_TOOLBAR"] = "Toolbar",
	["TF_IGNORE"] = "Ignore player",
	["TF_IGNORE_CONFIRM"] = [=[Are you sure you want to ignore this ID ?

|cffffff00%s|r

|cffff7700You can optionally enter below the reason why you ignore it. This is a personal note, it won't be visible by others and will serve as a reminder.]=],
	["TF_IGNORE_NO_REASON"] = "No reason",
	["TF_IGNORE_TT"] = "|cffffff00Click:|r Ignore player",
	["TF_OPEN_CHARACTER"] = "Show character page",
	["TF_OPEN_COMPANION"] = "Show companion page",
	["TF_OPEN_MOUNT"] = "Show mount page",
	["TF_PLAY_THEME"] = "Play character theme",
	["TF_PLAY_THEME_TT"] = [=[|cffffff00Click:|r Play |cff00ff00%s
|cffffff00Right-click:|r Stop theme]=],
	["THANK_YOU_1"] = [=[{h1:c}Total RP 3{/h1}
{p:c}{col:6eff51}Version %s (build %s){/col}{/p}
{p:c}{link*http://totalrp3.info*TotalRP3.info} — {twitter*TotalRP3*@TotalRP3} {/p}
{p:c}{link*http://discord.totalrp3.info*Join us on Discord}{/p}

{h2}{icon:INV_Eng_gizmo1:20} Created by{/h2}
%AUTHORS$s

{h2}{icon:QUEST_KHADGAR:20} The Rest of the Team{/h2}
%CONTRIBUTORS$s

{h2}{icon:THUMBUP:20} Acknowledgements{/h2}
{col:ffffff}Logo and minimap button icon:{/col}
- {link*https://twitter.com/Kelandiir*@Kelandiir}

{col:ffffff}Our pre-alpha QA team:{/col}
%TESTERS$s

{col:ffffff}Thanks to all our friends for their support all these years:{/col}
- For Telkos: Kharess, Kathryl, Marud, Solona, Stretcher, Lisma...
- For Ellypse: The guilds Eglise du Saint Gamon, Maison Celwë'Belore, Mercenaires Atal'ai, and more particularly Erzan, Elenna, Caleb, Siana and Adaeria

{col:ffffff}For helping us creating the Total RP guild on Kirin Tor (EU):{/col}
%GUILD_MEMBERS$s

{col:ffffff}Thanks to Horionne for sending us the magazine Gamer Culte Online #14 with an article about Total RP.{/col}]=],
	["THANK_YOU_ROLE_AUTHOR"] = "Author",
	["THANK_YOU_ROLE_COMMUNITY_MANAGER"] = "Community Manager",
	["THANK_YOU_ROLE_CONTRIBUTOR"] = "Contributor",
	["THANK_YOU_ROLE_GUILD_MEMBER"] = "Guild Member",
	["THANK_YOU_ROLE_TESTER"] = "QA Team",
	["TT_ELVUI_SKIN"] = "ElvUI skin",
	["TT_ELVUI_SKIN_ENABLE_TARGET_FRAME"] = "Skin target frame",
	["TT_ELVUI_SKIN_ENABLE_TOOLTIPS"] = "Skin tooltips",
	["UI_BKG"] = "Background %s",
	["UI_CLOSE_ALL"] = "Close all",
	["UI_COLOR_BROWSER"] = "Color browser",
	["UI_COLOR_BROWSER_PRESETS"] = "Presets",
	["UI_COLOR_BROWSER_PRESETS_BASIC"] = "Basic",
	["UI_COLOR_BROWSER_PRESETS_CLASSES"] = "Class",
	["UI_COLOR_BROWSER_PRESETS_CUSTOM"] = "Custom",
	["UI_COLOR_BROWSER_PRESETS_ITEMS"] = "Item quality",
	["UI_COLOR_BROWSER_PRESETS_RESOURCES"] = "Resource",
	["UI_COLOR_BROWSER_SELECT"] = "Select color",
	["UI_COMPANION_BROWSER_HELP"] = "Select a battle pet",
	["UI_COMPANION_BROWSER_HELP_TT"] = [=[|cffffff00Warning: |rOnly renamed battle pets can be bound to a profile.

|cff00ff00This section lists these battle pets only.]=],
	["UI_FILTER"] = "Filter",
	["UI_ICON_BROWSER"] = "Icon browser",
	["UI_ICON_BROWSER_HELP"] = "Copy icon",
	["UI_ICON_BROWSER_HELP_TT"] = [=[While this frame is open you can |cffffff00ctrl + click|r on a icon to copy its name.

This will works:|cff00ff00
- On any item in your bags
- On any icon in the spellbook|r]=],
	["UI_ICON_SELECT"] = "Select icon",
	["UI_IMAGE_BROWSER"] = "Image browser",
	["UI_IMAGE_SELECT"] = "Select image",
	["UI_LINK_SAFE"] = "Here's the link URL.",
	["UI_LINK_TEXT"] = "Your text here",
	["UI_LINK_URL"] = "http://your.url.here",
	["UI_LINK_WARNING"] = [=[Here's the link URL.
You can copy/paste it in your web browser.

|cffff0000!! Disclaimer !!|r
Total RP is not responsible for links leading to harmful content.]=],
	["UI_MUSIC_ALTTITLE"] = "Alternate title",
	["UI_MUSIC_BROWSER"] = "Music browser",
	["UI_MUSIC_DURATION"] = "Duration",
	["UI_MUSIC_SELECT"] = "Select music",
	["UI_PET_BROWSER_ACCEPT"] = "Assign",
	["UI_PET_BROWSER_BOUND_WARNING"] = "|cffff0000Warning: |rThis pet is currently assigned to the profile |cff00ff00%1$s|r. Assigning a profile to this pet will replace the current profile.",
	["UI_PET_BROWSER_EMPTY_TEXT"] = "You have no pets that can be assigned a profile.",
	["UI_PET_BROWSER_INTRO_TEXT"] = "Select a pet with the buttons below and click |cffffff00Assign|r to bind it to the profile.",
	["UI_PET_BROWSER_NAME_WARNING"] = "|cffff0000Warning: |rThis pet has not been renamed. We recommend renaming the pet to prevent showing this profile on other pets you own with the same name.",
	["UI_TUTO_BUTTON"] = "Tutorial mode",
	["UI_TUTO_BUTTON_TT"] = "Click to toggle on/off the tutorial mode",
	["UNIT_POPUPS_CHARACTER_STATUS"] = "Character Status",
	["UNIT_POPUPS_CONFIG_DISABLE_IN_COMBAT"] = "Hide menu entries while in combat",
	["UNIT_POPUPS_CONFIG_DISABLE_IN_COMBAT_HELP"] = "If checked, additional menu entries will not be shown while in combat.",
	["UNIT_POPUPS_CONFIG_DISABLE_IN_INSTANCES"] = "Hide menu entries while in instances",
	["UNIT_POPUPS_CONFIG_DISABLE_IN_INSTANCES_HELP"] = "If checked, additional menu entries will not be shown while in instanced content.",
	["UNIT_POPUPS_CONFIG_DISABLE_ON_UNIT_FRAMES"] = "Hide menu entries on unit frames",
	["UNIT_POPUPS_CONFIG_DISABLE_ON_UNIT_FRAMES_HELP"] = "If checked, additional menu entries will not be shown in menus activated by right-clicking unit frames.",
	["UNIT_POPUPS_CONFIG_DISABLE_OUT_OF_CHARACTER"] = "Hide menu entries while out of character",
	["UNIT_POPUPS_CONFIG_DISABLE_OUT_OF_CHARACTER_HELP"] = "If checked, additional menu entries will not be shown while out-of-character.",
	["UNIT_POPUPS_CONFIG_ENABLE_MODULE"] = "Module |cff00ff00enabled|r",
	["UNIT_POPUPS_CONFIG_ENTRIES_HEADER"] = "Menu entries",
	["UNIT_POPUPS_CONFIG_MENU_TITLE"] = "Menu settings",
	["UNIT_POPUPS_CONFIG_PAGE_HELP"] = "The unit popups module adds additional entries to the right-click menus found on unit frames and names in the chat frame.",
	["UNIT_POPUPS_CONFIG_PAGE_TEXT"] = "Menu settings",
	["UNIT_POPUPS_CONFIG_SHOW_CHARACTER_STATUS"] = "Show character status toggle",
	["UNIT_POPUPS_CONFIG_SHOW_CHARACTER_STATUS_HELP"] = "If checked, adds a checkbox to your own unit frame menu that allows you to toggle your in-character/out-of-character status.",
	["UNIT_POPUPS_CONFIG_SHOW_HEADER_TEXT"] = "Show header text",
	["UNIT_POPUPS_CONFIG_SHOW_HEADER_TEXT_HELP"] = "If checked, shows a \"Roleplay Options\" header above any added menu entries.",
	["UNIT_POPUPS_CONFIG_SHOW_OPEN_PROFILE"] = "Show open profile button",
	["UNIT_POPUPS_CONFIG_SHOW_OPEN_PROFILE_HELP"] = "If checked, adds a button that opens the selected units' RP profile when clicked.|n|nThis option will be visible on all unit frame and chat menus.",
	["UNIT_POPUPS_CONFIG_SHOW_SEPARATOR"] = "Show separator",
	["UNIT_POPUPS_CONFIG_SHOW_SEPARATOR_HELP"] = "If checked, shows a separator bar above any added menu entries.",
	["UNIT_POPUPS_CONFIG_VISIBILITY_HEADER"] = "Visibility options",
	["UNIT_POPUPS_CURRENT_PROFILE"] = "Current Profile",
	["UNIT_POPUPS_CURRENT_PROFILE_NAME"] = "Current Profile: %1$s",
	["UNIT_POPUPS_MODULE_DESCRIPTION"] = "Adds integration with right-click menus on unit frames and player names in chat frames.",
	["UNIT_POPUPS_MODULE_DISABLE_WARNING"] = "A user interface reload is required to disable the unit popups module.|n|n|cffff0000Warning: |rOnce disabled, this module can only be re-enabled from the |cffffcc00Modules status|r page.|n|nAre you sure you want to disable this module?",
	["UNIT_POPUPS_MODULE_NAME"] = "Unit Popups",
	["UNIT_POPUPS_OPEN_PROFILE"] = "Open Profile",
	["UNIT_POPUPS_ASSIGN_FLAG"] = "Assign Profile",
	["UNIT_POPUPS_ROLEPLAY_OPTIONS_HEADER"] = "Roleplay Options",
	["WHATS_NEW_23"] = [=[
# Changelog version 1.6.0

## Personal notes

You can now write personal notes inside the addon !

These notes can either be written on your own profile (if you wish to take generic notes for your character), or on someone else's profile (the top field being tied to your current profile, the bottom field being common to all your profiles). These notes are obviously private, nobody else but you can see them.

{img:Interface\AddOns\totalRP3\resources\160-1.tga:480:480}

To access personal notes, simply click on the new Notes button on the target frame, or open a profile and click on the Notes tab.

{img:Interface\AddOns\totalRP3\resources\160-2.tga:240:120}

The register also received a checkbox to only display profiles on which you wrote notes.

{img:Interface\AddOns\totalRP3\resources\160-3.tga:480:120}

## Added

- Added HTML support for About templates 2 and 3. You can now use the full array of HTML tags while using those templates to format their fields, using the toolbar which is now visible for all templates.

{img:Interface\AddOns\totalRP3\resources\160-4.tga:480:480}

- Added compatibility with other RP addons for personality traits and HTML tags.

## Changed

- The "Report profile" buttons will now both link to the [support website's page on harassment via addons](https://battle.net/support/help/product/wow/197/1501/solution), as the in-game report feature previously added was an invalid method to report addon abuse. The popup will still show a timestamp for the profile's reception, which you can provide to Blizzard CS to help them track the offense.

## Fixed

- Fixed an error which could prevent the addon from loading.
- Fixed a compatibility issue for template 3 if the addon locale was not English.

## Removed

- Removed auto-highlighting of the full text when entering focus of a text area (About fields, Currently, OOC Info...)
- Removed April Fools' code (including the forgotten rainbow companion names).

]=],
	["WHATS_NEW_23_1"] = [=[
# Changelog version 1.6.1

## Music system rework

- Technical changes in patch 8.2 required us to change how music is handled by the addon. **This means the update is required for musics to work.** This change should be seamless and backwards compatible (music themes from profiles coming from outdated versions should still play fine).
- This allowed for the addition of musics previously unavailable (looking at you, void elf musics).
- The duration of all musics should now be visible in the music browser line tooltips.

## Changed

- Settings to increase color contrast in tooltips and chat have been consolidated in a single setting for both which can be found in the General settings. It also applies in more places, like the map scan tooltips.

## Fixed

- The anchor for the map scan button can now properly be set.
- Fixed a switch in Headers/Paragraph dropdown titles
- Fixed an error message that could be caused by other addons misusing official API functions.

]=],
	["WHATS_NEW_23_10"] = [=[
# Changelog version 1.6.10

## Added

- Added %xt and %xf chat tokens. These will automatically be replaced by the RP name of your target and focus respectively when sending a message.
- Added settings to adjust About font sizes.

]=],
	["WHATS_NEW_23_11"] = [=[
	# Changelog version 1.6.11
## Added
- Added new chat tokens for first and last names: %xtf (Target's first name), %xtl (Target's last name), %xff (Focus' first name), %xfl (Focus' last name).
## Fixed
- Fixed an issue when trying to add a chat link to an empty chatbox.
- Fixed a compatibility issue with PallyPower.
]=],
	["WHATS_NEW_23_12"] = [=[
# Changelog version 1.6.12

## Fixed

- Tentatively fixed an issue with tooltip lines.
- Fixed an issue with the residence button on Classic.

]=],
	["WHATS_NEW_23_2"] = [=[
# Changelog version 1.6.2

## Added

- Added 328 icons and 20 images from patch 8.2.
- Added an indicator to the music browser when the default name of a music differs from the one matching the current filter.

## Fixed

- Fixed issues in the music data transfer between TRP and MRP.
- Fixed an issue with duplicated lines on the map scan button tooltip.
- Further speculative fixes to the map issue on login.

]=],
	["WHATS_NEW_23_3"] = [=[
# Changelog version 1.6.3

## Changed

- Companion tooltips will now adjust contrast for the custom color if the setting is enabled.

## Fixed

- Fixed a companion tooltip error when the API fails to return the pet type.
- Fixed an issue which could make the toolbar appear above the world map.
- Fixed an anchoring error with the target frame.

]=],
	["WHATS_NEW_23_4"] = [=[
# Changelog version 1.6.4

We are aware of a current issue on Retail causing **quest item usage from the objective tracker** to sometimes fail. While we do not have a fix for it just yet, **typing /reload after getting the error message** temporarily fixes the issue. Sorry for the inconvenience.

## WoW: Classic support

- Total RP 3: Classic is now available as a separate download on CurseForge and WoWInterface! Be sure to install it instead of the retail version of Total RP 3 if you plan on roleplaying in WoW: Classic.
- Important points to be aware of for the Classic version:
  - A few icons have been changed across the addon to replace missing icons in Classic.
  - Companion profiles have been disabled for mounts and non-combat pets, as Blizzard did not provide us with beta access. We will work on implementing them back as soon as possible.
  - Total RP 3: Extended will not be ported to Classic at launch. We will be evaluating if a Classic port makes sense for us to do at a later date.

## Changed

- When using the character map scan, characters with which you have set a relationship will now appear on top of the others.

]=],
	["WHATS_NEW_23_5"] = [=[
# Changelog version 1.6.5

## Added

- Added Total RP 3: Extended version number alongside Total RP 3 version number at the bottom of the tooltip.

## Fixed

- Fixed an error when someone executes a scan in your zone. (Classic only)
- Fixed a potential error when saving a glance slot.

]=],
	["WHATS_NEW_23_6"] = [=[
# Changelog version 1.6.6

## Added

- Added slash commands to change your roleplay status, which you can use in macros. You can now use `/trp3 status ic` to get in character, `/trp3 status ooc` to get out of character, or `/trp3 status toggle` to switch status.
- Added a chat setting to display the OOC indicator next to the name in chat.
- Added a setting to hide the map scan button if no scan is available.
- Added a roleplay language field to the main dashboard.
  - This setting is profile-based, defaults to your addon language, and allows you to indicate the language you're roleplaying in.
  - If your addon language doesn't match a player's roleplaying language, you'll see a flag at the bottom of their tooltip indicating their roleplaying language.
  - This change is mainly aimed at Classic roleplayers, as only English RP realms were made.
- Added back buttons to toggle helmet and cloak display for Classic.

## Changed

- Renamed the war mode setting to PvP mode for Classic.

## Fixed

- Fixed issues when the target bar module was disabled.
- Fixed an issue causing duplicate Mary-Sue Protocol profiles to appear in the register when unchecking "This realm only".
- Fixed a few remaining missing icons for Classic (default template 3 icons and `/trp3 roll` icons)
- Fixed an issue when using the "Right-click to open profile" setting on Classic.

]=],
	["WHATS_NEW_23_7"] = [=[
# Changelog version 1.6.7

## Added

- Added a setting to detect speech in emotes and automatically color it.
- Added 7 icons and 1 music from patch 8.2.5.

## Changed

- The companion profiles list accessed through the target frame is now alphabetically sorted, and "Create new profile" has been moved out of it.

]=],
	["WHATS_NEW_23_8"] = [=[
# Changelog version 1.6.8

## Changed

- **Classic:** Due to 1.13.3 API changes, the map scan has been modified to find characters in yell range only. It will only show on the map you're in. **Only characters using Total RP 3 version 1.6.8 will be visible on the scan.**

*Reminder : You can disable your scan appearance by unchecking "Register settings > Location settings > Enable character location. Please don't hold on the update for visibility reasons.*

- Speech detection will now only apply to emotes (including NPC emotes).

## Fixed

- Fixed a rare issue where the addon loading process would be interrupted by a setting key unable to be read.

]=],
	["WHATS_NEW_23_9"] = [=[
# Changelog version 1.6.9

## Added

- Added 61 musics, 5 images and 223 icons on Retail from patch 8.3.
- Added 177 images on Retail from previous patches.
- Added 1 icon on Classic from patch 1.13.3.
- Added default icons for Vulperas and Mechagnomes.

## Changed

- Changed default Kul Tiran female icon.

## Fixed

- Added workaround to Classic map scan to handle Blizzard's lack of tests.
- Fixed an issue when trying to use icons with an apostrophe in their name.
- Image browser filter now correctly handles some special characters.

]=],
	["WHATS_NEW_24_1"] = [=[# Changelog version 2.0

## Added

- Added a default profile.
  - This profile cannot be modified and only contains basic character information (name, race, class).
  - New characters will now be bound to the default profile instead of creating a new one automatically.
  - A new profile is still required to add custom information.

- Added a search bar in the character and companion profiles lists.

## Fixed

- Fixed a conflict between OOC detection and Russian declensions.
- Fixed an issue related to Prat + WIM chat history.

## Changed

- Removed a personality trait preset.
- Improved communication protocol to reduce profile transfer size.
- Various compatibility changes related to 9.0 API modifications.

]=],
	["WHATS_NEW_24_10"] = [=[# Changelog version 2.3.7

This version is updated for TBC Classic 2.5.2.

# Fixed

- 9.1 icons and musics have been properly added for retail.
- Fixed an issue with TRP3: Extended creation exchange failing in very specific cases.

]=],
	["WHATS_NEW_24_13"] = [=[# Changelog version 2.3.12

Classic users: Companion profiles may have to be relinked due to API changes.

## Added

- Added settings to change the colors you see for other players' tooltips.
- Added 5 new music files from patch 9.2.7, as well as data for WotLK Classic.
- Added macro conditionals support for the "/trp3 profile" command.
- Added a tooltip to view settings texts in full even if they are too long.
- Added Evoker class color preset to the color picker.

## Fixed

- Fixed an issue with tooltip color rendering when using some Unicode characters.
- Fixed inconsistent linebreaks in Template 1.
- Removed some unwanted modifications in profiles.
- Fixed a potential crash when reordering miscellaneous information lines.
- Added a delay before joining the broadcast channel to reduce issues with chat channels swapping numbers/colors.
- Fixed dead links in "About Total RP 3".

]=],
	["WHATS_NEW_24_14"] = [=[# Changelog version 2.3.13

	## Fixed

		- Fixed missing death knight icons on Classic WotLK.
		- Fixed some more profile modifications.

]=],
	["WHATS_NEW_24_2"] = [=[# Changelog version 2.1

## Added

- Added 113 images, 1437 icons and 613 musics from patch 9.0.
- Added modifier to the dice roll output text.
- Added keybinding options for opening the target profile and toggling RP status.

## Fixed

- Fixed an issue with the default tooltip appearing sometimes despite "Hide original tooltip" setting being checked.
- Fixed an issue with the TRP3 tooltip being offset while the default tooltip is hidden.
- Fixed an issue with the TRP3 tooltip briefly overlapping the default tooltip if quickly hovering from a player to a spell/item.
- Fixed an issue when trying to open the Prat modules window while TRP3 is running.
- Fixed a display issue with the NPC speech frame background.
- Fixed alphabetical sorting when hovering a cluster of players in the map scan.
- Potential fix for the guide channel being swapped with the xtensionxtooltip2 channel.

]=],
	["WHATS_NEW_24_3"] = [=[# Changelog version 2.2

## Added

- Added Pronouns preset in Additional information. When using this preset, the pronouns will be shown on your tooltip.
- Added support for companion profiles on the secondary pet summoned with the hunter talent Animal Companion.
- Added a hunter pet browser when binding a companion profile through the profile list.

## Fixed

- Fixed chat link tooltips being invisible when first opening one.
- Fixed formatting issues with chat links.
- Fixed an issue causing the battle pet browser to show an incomplete list if the battle pet collection had search filters applied.
- Fixed invalid icons in the About tab when receiving a profile from other RP addons on Classic.
- Fixed incorrect information on the tooltip of the NPC speech prefix setting.
- Fixed an issue with Tukui chat history.

]=],
	["WHATS_NEW_24_4"] = [=[# Changelog version 2.3
## Added
- Added a module to customize nameplates with RP information. At present, **only default Blizzard nameplates and KuiNameplates** are supported.
*As it is now redundant, the TRP3: KuiNameplates module will now disable itself and should be uninstalled.*
- Added support for companion profiles in Classic.
- Added entries on unit frames right-click menu to open profile + change roleplay status.
- Added a window to copy character names linked to a profile when right-clicking it in the directory list.
- Added an option to disable profile tooltips in instances.
## Changed
- The URL copy window now closes after pressing the copy shortcut.
- The default profile no longer shows the amount of characters bound to it.
- Cropped characteristic fields will now show a tooltip on hover with the full content of the field.
- The description editor will now receive input focus after clicking any formatting tool button.
- Customized names in chat frames that have excessively large lengths will now be cropped.
- Custom colors for personality traits now apply to attribute names.
## Fixed
- Fixed an issue with chat customization not properly registering on login while using Prat.
- Fixed missing sound cue when opening/closing the main window.
- Fixed an issue that could cause PvP flagged players to show their location on map scans in Classic.
- Fixed missing vulpera language icon.
]=],
	["WHATS_NEW_24_5"] = [=[# Changelog version 2.3.2

## Added

- Added settings for right-click options on unit frames and chat names.

## Fixed

- Fixed incorrect names showing up on Blizzard NPC nameplates.
- Fixed display issue with KuiNameplates tank mode.
- Fixed a dependency issue preventing chat customization from working when using Prat and Listener.
- Fixed localization not being properly applied to various settings.

]=],
	["WHATS_NEW_24_6"] = [=[# Changelog version 2.3.3

## Added
- Added tooltip fields for character zone and health. These fields can be toggled in Tooltip settings.
  - The zone field will only show when the character is in another zone (if looking at a party member for instance).
  - The health field will only show if the character is not full health. It is disabled by default.

## Fixed
- Fixed a few issues with profile transfer.
- Fixed Kui name-only RP nameplates not updating when level text and health were both disabled.
- Fixed inability to set a pet profile when the pet is first summoned.
- Fixed TRP tooltip overlapping with the main tooltip if the profile has been caught by the mature filter.
- Fixed TRP chat links breaking from emote/OOC/speech detection.
- Fixed Currently/OOC fields not properly hiding on tooltips if they only contained whitespaces.

]=],
	["WHATS_NEW_24_8"] = [=[# Changelog version 2.3.5

## Added

- Added support for Burning Crusade Classic.

## Fixed

- Fixed several performance issues when requesting character profiles.

	]=],
	["WHATS_NEW_24_9"] = [=[# Changelog version 2.3.6

## Added

- Added 323 new icons, 7 images and 138 new music files from patch 9.1.0.

## Removed

- Removed the roleplay language flag.
- Fixed a bug with chat channels on Classic.

	]=]
}

TRP3_API.loc:RegisterNewLocale("enUS", "English", localeContent);

localeContent = {
	["ABOUT_TITLE"] = "Über",
	["BINDING_NAME_TRP3_TOGGLE"] = "Hauptfenster umschalten",
	["BINDING_NAME_TRP3_TOOLBAR_TOGGLE"] = "Werkzeugleiste umschalten",
	["BROADCAST_10"] = "|cffff9900Du bist bereits in zehn Channels. TRP3 wird nicht mehr versuchen sich mit dem Broadcast-Kanal zu verbinden, aber du wirst nicht in der LAge sein einige Funktionen, wie die Spielersuche auf der Karte, zu verwenden.",
	["BROADCAST_OFFLINE_DISABLED"] = "Broadcast wurde deaktiviert.",
	["BROADCAST_PASSWORD"] = [=[|cffff0000Der Übertragungs-Channel (%s) ist passwortgeschützt. 
|cffff9900TRP3 wird nicht versuchen, sich zu verbinden, kann jedoch auch keine Features wie die Standortbestimmung von Spielern auf der Karte für dich bereitstellen.
|cff00ff00Du kannst den Übertragungs-Channel in den Allgemeinen Einstellungen von TRP3 ausschalten oder ändern.]=],
	["BROADCAST_PASSWORDED"] = [=[|cffff0000Der Benutzer |r%s|cffff0000 hat gerade ein Passwort für den Übertragungs-Channel (%s) festgelegt.
|cffff9900Wenn du das Passwort nicht kennst, kannst du keine Funktionen nutzen, die in Zusammenhang mit dem Channel stehen, wie etwa der Standortbestimmung von Spielern auf der Karte.]=],
	["BW_COLOR_CODE"] = "Farbcode",
	["BW_COLOR_CODE_ALERT"] = "Falscher hexadezimaler Farbcode!",
	["BW_COLOR_CODE_TT"] = "Hier kannst du 6 Zeichen hexadezimalen Farbcode eintragen und mit ENTER bestätigen.",
	["BW_COLOR_PRESET_DELETE"] = "Voreinstellungen %s löschen.",
	["BW_COLOR_PRESET_RENAME"] = "Voreinstellungen %s umbenennen.",
	["BW_COLOR_PRESET_SAVE"] = "Aktuelle Farbe speichern",
	["BW_COLOR_PRESET_TITLE"] = "Farben Voreinstellungen",
	["BW_CUSTOM_NAME"] = "Eigener Farbname",
	["BW_CUSTOM_NAME_TITLE"] = "Name (Optional)",
	["BW_CUSTOM_NAME_TT"] = "Du kannst der eigenen Farbe, die du speicherst, einen Namen geben. Wenn du sie nicht benennst wird der hexadezimale Farbcode verwendet.",
	["CL_COMPANION_PROFILE"] = "Begleiterprofil",
	["CL_CONTENT_SIZE"] = "Größe: %s",
	["CL_DIRECTORY_COMPANION_PROFILE"] = "Begleiter Profil Verzeichnis",
	["CL_DIRECTORY_PLAYER_PROFILE"] = "Spieler Profil Verzeichnis",
	["CL_DOWNLOADING"] = "Lade Herunter: %0.1f %%",
	["CL_EXPIRED"] = "Dieser Link ist abgelaufen.",
	["CL_GLANCE"] = "Auf den ersten Blick",
	["CL_IMPORT_COMPANION"] = "Begleiterprofil importieren",
	["CL_IMPORT_GLANCE"] = "Importiere \"Auf den ersten Blick\"",
	["CL_IMPORT_PROFILE"] = "Profil importieren",
	["CL_MAKE_IMPORTABLE"] = [=[Du möchtest einen Link für %s generieren.

Möchtest du diesen Link für andere Spieler importierbar machen? Dann wären sie in der Lage den Inhalt dieses Links zu kopieren und zu nutzen.

Wenn du mit nein antwortest werden sie den Inhalt des Links nur anschauen können.]=],
	["CL_MAKE_IMPORTABLE_BUTTON_TEXT"] = "Importierbar machen",
	["CL_MAKE_IMPORTABLE_SIMPLER"] = [=[Diesen %s Link importierbar machen?

Andere Leute können den Inhalt des Links kopieren und nutzen.]=],
	["CL_MAKE_NON_IMPORTABLE"] = "Nur Ansehbar",
	["CL_OPEN_COMPANION"] = "Begleiterprofil öffnen",
	["CL_OPEN_PROFILE"] = "Profil öffnen",
	["CL_PLAYER_PROFILE"] = "Spielerprofil",
	["CL_REQUESTING_DATA"] = "Frage Datenverbindung von %s an.",
	["CL_SENDING_COMMAND"] = "Sende Befehl...",
	["CL_SENT_BY"] = "Link gesendet von: %s",
	["CL_TOOLTIP"] = "Erstelle einen Chat-Link",
	["CL_VERSIONS_DIFFER"] = [=[Dieser Link wurde mit einer anderen Version von Total RP 3 generiert.

Das Importieren des Inhaltes einer anderen Version könnte aufgrund von Inkompatibilitäten zu Problemen führen. Möchtest Du dennoch fortfahren?]=],
	["CM_ACTIONS"] = "Aktionen",
	["CM_ALT"] = "Alt",
	["CM_APPLY"] = "Übernehmen",
	["CM_BLACK"] = "Schwarz",
	["CM_BLUE"] = "Blau",
	["CM_CANCEL"] = "Abbrechen",
	["CM_CENTER"] = "Zentriert",
	["CM_CLASS_DEATHKNIGHT"] = "Todesritter",
	["CM_CLASS_DEMONHUNTER"] = "Dämonenjäger",
	["CM_CLASS_DRUID"] = "Druide",
	["CM_CLASS_HUNTER"] = "Jäger",
	["CM_CLASS_MAGE"] = "Magier",
	["CM_CLASS_MONK"] = "Mönch",
	["CM_CLASS_PALADIN"] = "Paladin",
	["CM_CLASS_PRIEST"] = "Priester",
	["CM_CLASS_ROGUE"] = "Schurke",
	["CM_CLASS_SHAMAN"] = "Schamane",
	["CM_CLASS_UNKNOWN"] = "Unbekannt",
	["CM_CLASS_WARLOCK"] = "Hexenmeister",
	["CM_CLASS_WARRIOR"] = "Krieger",
	["CM_CLICK"] = "Klicken",
	["CM_COLOR"] = "Farbe",
	["CM_CTRL"] = "Strg",
	["CM_CYAN"] = "Türkis",
	["CM_DELETE"] = "Löschen",
	["CM_DOUBLECLICK"] = "Doppelklick",
	["CM_DRAGDROP"] = "Drag & Drop",
	["CM_EDIT"] = "Bearbeiten",
	["CM_GREEN"] = "Grün",
	["CM_GREY"] = "Grau",
	["CM_IC"] = "IC",
	["CM_ICON"] = "Icon",
	["CM_IMAGE"] = "Bild",
	["CM_L_CLICK"] = "Links-Klick",
	["CM_LEFT"] = "Links",
	["CM_LINK"] = "Link",
	["CM_LOAD"] = "Laden",
	["CM_M_CLICK"] = "Mittel-Klick",
	["CM_MOVE_DOWN"] = "Nach unten",
	["CM_MOVE_UP"] = "Nach oben",
	["CM_NAME"] = "Name",
	["CM_OOC"] = "OOC",
	["CM_OPEN"] = "Öffnen",
	["CM_ORANGE"] = "Orange",
	["CM_PINK"] = "Pink",
	["CM_PLAY"] = "Abspielen",
	["CM_PURPLE"] = "Lila",
	["CM_R_CLICK"] = "Rechts-Klick",
	["CM_RED"] = "Rot",
	["CM_REMOVE"] = "Entfernen",
	["CM_RESET"] = "Zurücksetzen",
	["CM_RESIZE"] = "Größe ändern",
	["CM_RESIZE_TT"] = "Ziehen um die Rahmengröße zu ändern.",
	["CM_RIGHT"] = "Rechts",
	["CM_SAVE"] = "Speichern",
	["CM_SELECT"] = "Auswählen",
	["CM_SHIFT"] = "Umschalttaste",
	["CM_SHOW"] = "Anzeigen",
	["CM_STOP"] = "Anhalten",
	["CM_TWEET"] = "Einen Tweet senden",
	["CM_TWEET_PROFILE"] = "Profil-URL zeigen",
	["CM_UNKNOWN"] = "Unbekannt",
	["CM_VALUE"] = "Wert",
	["CM_WHITE"] = "Weiß",
	["CM_YELLOW"] = "Gelb",
	["CO_ADVANCED_BROADCAST"] = "Add-on Kommunikationen",
	["CO_ADVANCED_BROADCAST_CHANNEL_ALWAYS_LAST"] = "Broadcast-Kanal as Ende setzen",
	["CO_ADVANCED_BROADCAST_CHANNEL_ALWAYS_LAST_TT"] = "Durch diese Option bleibt dieser Kanal immer der letzte in Eurer Kanalliste.",
	["CO_ADVANCED_LANGUAGE_WORKAROUND"] = "Provisorische Lösung für das Rücksetzen der Sprache",
	["CO_ADVANCED_LANGUAGE_WORKAROUND_TT"] = "Seit Patch 8.0.1 setzt das Spiel die ausgewählte Sprache nach jedem Ladebildschirm zur Standardsprache Eurer Fraktion zurück. Diese Überbrückung sorgt dafür, dass Eure Sprache nach einem Ladebildschirm weiterhin ausgewählt bleibt.",
	["CO_ADVANCED_LANGUAGES"] = "Sprachen",
	["CO_ADVANCED_LANGUAGES_REMEMBER"] = "Letzte benutzte Sprache speichern",
	["CO_ADVANCED_LANGUAGES_REMEMBER_TT"] = "Total RP 3 wird die letzte Sprache, die du vor dem ausloggen benutzt hast speichern und beim nächsten Login automatisch wieder aktivieren.",
	["CO_ADVANCED_SETTINGS"] = "Erweiterte Einstellungen",
	["CO_ADVANCED_SETTINGS_MENU_NAME"] = "Erweitert",
	["CO_ADVANCED_SETTINGS_POPUP"] = "Ihr habt eine erweiterte Einstellung verändert. Bitte denkt daran, dass diese Einstellungen Eure Spielerfahrungen mit dem Add-on beeinflussen und diverse Funktionen daran hindern können korrekt zu funktionieren. Benutzung auf eigene Gefahr.",
	["CO_ADVANCED_SETTINGS_RESET"] = "Erweiterte Einstellungen zurücksetzen",
	["CO_ADVANCED_SETTINGS_RESET_TT"] = "Sämtliche erweiterte Einstellungen zurücksetzen. Nutzt dies falls Ihr Probleme habt, nachdem Ihr die Einstellungen verändert habt.",
	["CO_ANCHOR_BOTTOM"] = "Unten",
	["CO_ANCHOR_BOTTOM_LEFT"] = "Unten Links",
	["CO_ANCHOR_BOTTOM_RIGHT"] = "Unten Rechts",
	["CO_ANCHOR_CURSOR"] = "Am Mauszeiger anzeigen",
	["CO_ANCHOR_LEFT"] = "Links",
	["CO_ANCHOR_RIGHT"] = "Rechts",
	["CO_ANCHOR_TOP"] = "Oben",
	["CO_ANCHOR_TOP_LEFT"] = "Oben Links",
	["CO_ANCHOR_TOP_RIGHT"] = "Oben Rechts",
	["CO_CHAT"] = "Chat-Einstellungen",
	["CO_CHAT_DISABLE_OOC"] = "Deaktiviere Anpassungen wenn Ihr OOC seid",
	["CO_CHAT_DISABLE_OOC_TT"] = "Deaktiviere alle Total RP 3 Chatanpassungen (benutzerdefinierte Namen, Emote-Erkennung, NPC-Reden, etc.), wenn dein Charakter als \"Out Of Character\" markiert ist.",
	["CO_CHAT_INCREASE_CONTRAST"] = "Farbkontrast erhöhen",
	["CO_CHAT_INSERT_FULL_RP_NAME"] = "RP-Namen bei Shift-Klick einfügen",
	["CO_CHAT_INSERT_FULL_RP_NAME_TT"] = [=[Füge den kompletten RP namen eines Spielers in den Chat ein, wenn auf seinen Namen Shift-geklickt wird.

(Wenn diese Option eingeschaltet ist, kannst du mit Alt-Shift auf einen Namen klicken wenn du das ursprüngliche Verhalten verwenden möchtest und den Charakternamen statt den vollständigen RP-Namen einfügen möchtest.)]=],
	["CO_CHAT_MAIN"] = "Chat-Haupteinstellungen",
	["CO_CHAT_MAIN_COLOR"] = "Benutzerdefinierte Farben für Namen",
	["CO_CHAT_MAIN_EMOTE"] = "Emote-Erkennung",
	["CO_CHAT_MAIN_EMOTE_PATTERN"] = "Vorlage zur Emote-Erkennung",
	["CO_CHAT_MAIN_EMOTE_USE"] = "Brnütze Emote-Erkennung",
	["CO_CHAT_MAIN_EMOTE_YELL"] = "Keine geschriehenen Emotes",
	["CO_CHAT_MAIN_EMOTE_YELL_TT"] = "Im Schreien Channel *emote* oder <emote> nicht zeigen.",
	["CO_CHAT_MAIN_NAMING"] = "Benennungsmethode",
	["CO_CHAT_MAIN_NAMING_1"] = "Originalnamen beibehalten",
	["CO_CHAT_MAIN_NAMING_2"] = "Angepasste Namen verwenden",
	["CO_CHAT_MAIN_NAMING_3"] = "Vorname + Nachname",
	["CO_CHAT_MAIN_NAMING_4"] = "Kurztitel + Vorname + Nachname",
	["CO_CHAT_MAIN_NPC"] = "NSC-Spracherkennung",
	["CO_CHAT_MAIN_NPC_PREFIX"] = "Muster für NSC-Spracherkennung",
	["CO_CHAT_MAIN_NPC_PREFIX_TT"] = [=[Wenn eine Chatnachricht im Emotekanal mit diesem Zeichen startet, wird sie als NSC-Nachricht interpretiert.

|cff00ff00Voreingestellt : "|| "
(ohne die " und mit einem Leerzeichen nach dem Strich)]=],
	["CO_CHAT_MAIN_NPC_USE"] = "Nutze NSC-Spracherkennung",
	["CO_CHAT_MAIN_OOC"] = "OOC-Erkennung",
	["CO_CHAT_MAIN_OOC_COLOR"] = "OOC-Farbe",
	["CO_CHAT_MAIN_OOC_PATTERN"] = "Muster für OOC-Erkennung",
	["CO_CHAT_MAIN_OOC_USE"] = "Nutze OOC-Erkennung",
	["CO_CHAT_MAIN_SPEECH"] = "Spracherkennung",
	["CO_CHAT_MAIN_SPEECH_USE"] = "Spracherkennung benutzen",
	["CO_CHAT_MAIN_SPEECH_USE_TT"] = "Text in Anführungszeichen wird eingefärbt als wäre er im /say geschrieben.",
	["CO_CHAT_NPCSPEECH_REPLACEMENT"] = "Begleitername in NSC Sprache anpassen",
	["CO_CHAT_NPCSPEECH_REPLACEMENT_TT"] = "Wenn der Begleitername in der NSC Sprache in Klammern eingesetzt wird, wird er eingefärbt und es wird, je nach Einstellung, ein Icon angezeigt.",
	["CO_CHAT_REMOVE_REALM"] = "Spielernamen ohne Servernamen zeigen",
	["CO_CHAT_SHOW_OOC"] = "OOC Indikator anzeigen",
	["CO_CHAT_USE"] = "Benutze Chatkanäle",
	["CO_CHAT_USE_ICONS"] = "Spielersymbole anzeigen",
	["CO_CHAT_USE_SAY"] = "Sagen-Kanal",
	["CO_CONFIGURATION"] = "Einstellungen",
	["CO_CURSOR_DISABLE_OOC"] = "Während OOC deaktiviert",
	["CO_CURSOR_DISABLE_OOC_TT"] = "Deaktiviert Modifikationen vom Cursor während dein Rollenspielstatus |cffccccccOut Of Character|r ist.",
	["CO_CURSOR_MODIFIER_KEY"] = "Modifiziertaste",
	["CO_CURSOR_RIGHT_CLICK"] = "Rechtsklick um Profil zu öffnen",
	["CO_CURSOR_RIGHT_CLICK_TT"] = [=[Rechtsklick auf einen Spieler in der 3D Welt, wird sein Profil öffnen, falls er eines besitzt.

|TInterface\Cursor\WorkOrders:25|t Dieses Symbol wird an dem Mauszeiger angeheftet, wenn ein Spieler ein Profil hat und Ihr es rechtsklicken könnt.

|cffccccccNote: Diese Funktion wird während eines Kampfes deaktiviert. |r]=],
	["CO_CURSOR_TITLE"] = "Cursorinteraktionen",
	["CO_GENERAL"] = "Allgemeine Einstellungen",
	["CO_GENERAL_BROADCAST"] = "Broadcast-Kanal nutzen",
	["CO_GENERAL_BROADCAST_C"] = "Names des Broadcast-Kanals",
	["CO_GENERAL_BROADCAST_TT"] = "Der Broadcast-Kanal wird für viele Funktionen genutzt. Durch das Deaktivieren werden Funktionen wie die Charakterposition auf der Karte, Abspielen lokaler Klänge usw. deaktivert.",
	["CO_GENERAL_CHANGELOCALE_ALERT"] = [=[Interface neu laden, um die Sprache jetzt auf %s zu ändern?

Wenn nicht, wird die Sprache beim nächsten Login geändert.]=],
	["CO_GENERAL_COM"] = "Kommunikation",
	["CO_GENERAL_DEFAULT_COLOR_PICKER"] = "Standard Farbauswahl",
	["CO_GENERAL_DEFAULT_COLOR_PICKER_TT"] = "Aktivieren, um immer die Standard Farbauswahl zu nutzen. Nützlich, wenn du ein Farbauswahl-Addon benutzt.",
	["CO_GENERAL_HEAVY"] = "Warnung bei überlangem Profil",
	["CO_GENERAL_HEAVY_TT"] = "Gibt dir einen Warnhinweis, wenn dein Profil eine verträgliche Größe überschreitet.",
	["CO_GENERAL_LOCALE"] = "Sprache des Addons",
	["CO_GENERAL_MISC"] = "Verschiedenes",
	["CO_GENERAL_NEW_VERSION"] = "Aktualisierungshinweis",
	["CO_GENERAL_NEW_VERSION_TT"] = "Gibt dir einen Hinweis, sobald eine neue Version verfügbar ist.",
	["CO_GENERAL_RESET_CUSTOM_COLORS"] = "Benutzerdefinierte Farben zurücksetzen",
	["CO_GENERAL_RESET_CUSTOM_COLORS_TT"] = "Entfernt alle in der Farbauswahl gespeicherten benutzerdefinierten Farben.",
	["CO_GENERAL_RESET_CUSTOM_COLORS_WARNING"] = "Bist du sicher, dass du alle in der Farbauswahl gespeicherten benutzerdefinierten Farben entfernen möchtest?",
	["CO_GENERAL_TT_SIZE"] = "Textgröße des Informationstooltips",
	["CO_GENERAL_UI_ANIMATIONS"] = "Interface-Animationen",
	["CO_GENERAL_UI_ANIMATIONS_TT"] = "Aktiviert die Interface-Animationen.",
	["CO_GENERAL_UI_SOUNDS"] = "Interface-Klänge",
	["CO_GENERAL_UI_SOUNDS_TT"] = "Aktivert die Interface-Klänge (beim Öffnen von Fenstern, Wechseln zwischen Reitern und Klicken auf Schaltflächen).",
	["CO_GLANCE_LOCK"] = "Leiste fixieren",
	["CO_GLANCE_LOCK_TT"] = "Verhindert, dass die Leiste verschoben wird.",
	["CO_GLANCE_MAIN"] = "\"Auf den ersten Blick\"-Leiste",
	["CO_GLANCE_PRESET_TRP2"] = "Benutze Positionen im Total RP 2 Stil",
	["CO_GLANCE_PRESET_TRP2_BUTTON"] = "Benutzen",
	["CO_GLANCE_PRESET_TRP2_HELP"] = "Verknüpfung, um die Leiste im TRP2-Stil zu konfigurieren – am rechten Rand des WoW-Zielfensters.",
	["CO_GLANCE_PRESET_TRP3"] = "Benutze Positionen im Total RP 3 Stil",
	["CO_GLANCE_PRESET_TRP3_HELP"] = "Verknüpfung um die Zeile im TRP3 Stil aufzusetzen - Am unteren Rand des TRP3 Zielfensters.",
	["CO_GLANCE_RESET_TT"] = "Setze die Leiste auf die untere linke Position des Ankerfensters zurück.",
	["CO_GLANCE_TT_ANCHOR"] = "Ankerpunkt des Tooltips",
	["CO_HIDE_EMPTY_MAP_BUTTON"] = "Ausblenden wenn keine Scans verfügbar sind.",
	["CO_LOCATION"] = "Standorteinstellungen",
	["CO_LOCATION_ACTIVATE"] = "Charakterstandort aktivieren",
	["CO_LOCATION_ACTIVATE_TT"] = "Aktivieren das Charakterstandortsystem, welches erlaubt auf der Weltkarte nach anderen Total RP-Nutzern zu suchen und ihnen erlaubt dich zu finden.",
	["CO_LOCATION_DISABLE_CLASSIC_PVP"] = "Standort deaktivieren, wenn PvP an ist. ",
	["CO_LOCATION_DISABLE_CLASSIC_PVP_TT"] = "Solange PvP aktiv ist, wirst du bei Scans nicht auf der Karte angezeigt. Nützlich, wenn du Missbrauch des Systems um dich zu verfolgen vermeiden willst.",
	["CO_LOCATION_DISABLE_OOC"] = "Standort deaktivieren wenn OOC",
	["CO_LOCATION_DISABLE_OOC_TT"] = "Du wirst keine Antworten auf Standortanfragen anderer Spieler senden wenn dein RP Status auf Out Of Charakter gesetzt ist.",
	["CO_LOCATION_DISABLE_PVP"] = "Standort deaktivieren wenn für PVP geflaggt",
	["CO_LOCATION_DISABLE_PVP_TT"] = [=[Du wirst keine Antworten auf Standortanfragen anderer Spieler senden, wenn du für PvP geflaggt bist.

Diese Option is besonders auf PvP Realms nützlich, auf denen Spieler der anderen Fraktion das System ausnutzen können um dich zu verfolgen.]=],
	["CO_LOCATION_DISABLE_WAR_MODE"] = "Standort deaktivieren, wenn der Kriegsmodus an ist. ",
	["CO_LOCATION_DISABLE_WAR_MODE_TT"] = "Solange der Kriegsmodus aktiv ist und du dich nicht in einer Ruhe-Zone bist, wirst du bei Scans nicht auf der Karte angezeigt. Nützlich, wenn du Missbrauch des Systems um dich zu verfolgen vermeiden willst.",
	["CO_LOCATION_SHOW_DIFFERENT_WAR_MODES"] = "Zeige Spieler mit anderem Kriegsmodus.",
	["CO_LOCATION_SHOW_DIFFERENT_WAR_MODES_TT"] = "Spieler die zur Zeit in dem Gebiet sind, aber einen anderen Kriegsmodus-Status als Ihr haben, werden mit weniger Deckkraft auf der Karte angezeigt und bekommen ein spezielles Symbol im Tooltip.",
	["CO_MAP_BUTTON"] = "Kartenscan-Button",
	["CO_MAP_BUTTON_POS"] = "Position des Scan-Buttons auf der Karte",
	["CO_MINIMAP_BUTTON"] = "Minimap Button",
	["CO_MINIMAP_BUTTON_FRAME"] = "Ankerfenster",
	["CO_MINIMAP_BUTTON_RESET"] = "Position zurücksetzen",
	["CO_MINIMAP_BUTTON_RESET_BUTTON"] = "Zurücksetzen",
	["CO_MINIMAP_BUTTON_SHOW_HELP"] = "Wenn du ein anderes Add-On verwendest um Total RP 3's Minimap-Schaltfläche anzuzeigen (FuBar, Titan, Bazooka) kannst du die Schaltfläche von der Minimap entfernen.",
	["CO_MINIMAP_BUTTON_SHOW_TITLE"] = "Zeige Minimap-Button",
	["CO_MODULES"] = "Modulstatus",
	["CO_MODULES_DISABLE"] = "Deaktiviere Modul",
	["CO_MODULES_ENABLE"] = "Aktiviere Modul",
	["CO_MODULES_ID"] = "Modul ID: %s",
	["CO_MODULES_SHOWERROR"] = "Zeige Fehler",
	["CO_MODULES_STATUS"] = "Status: %s",
	["CO_MODULES_STATUS_0"] = "Fehlende Abhängigkeiten",
	["CO_MODULES_STATUS_1"] = "Geladen",
	["CO_MODULES_STATUS_2"] = "Deaktivert",
	["CO_MODULES_STATUS_3"] = "Total RP 3 Aktualisierung benötigt",
	["CO_MODULES_STATUS_4"] = "Fehler bei der Initialisierung",
	["CO_MODULES_STATUS_5"] = "Fehler beim Start",
	["CO_MODULES_TT_DEP"] = "%s- %s (version %s)|r",
	["CO_MODULES_TT_DEPS"] = "Abhängigkeiten",
	["CO_MODULES_TT_ERROR"] = [=[
|cffff0000Fehler:|r
%s]=],
	["CO_MODULES_TT_NONE"] = "Keine Abhängigkeiten",
	["CO_MODULES_TT_TRP"] = "%sFür Total RP 3 build %s minimum.|r",
	["CO_MODULES_TUTO"] = [=[Ein Modul ist eine unabhängige Funktion, die aktiviert oder deaktiviert werden kann.

Möglicher Status:
|cff00ff00Geladen:|r Modul aktiviert und geladen.
|cff999999Deaktiviert:|r Modul deaktiviert.
|cffff9900Fehlende Abhängigkeiten:|r Einige Abhängigkeiten sind nicht geladen/verfügbar.
|cffff9900TRP Update benötigt:|r Diese Modul benötigt eine aktueller Version von TRP3.
|cffff0000Fehler beim Inizialisieren oder Starten:|r Der Start des Moduls hat nicht funktioniert. Das Modul würde sicher Fehler verursachen!

|cffff9900Wenn ein Modul deaktivert wird muss das UI neu geladen werden!]=],
	["CO_MODULES_VERSION"] = "Version: %s",
	["CO_MSP"] = "Mary Sue Protocol",
	["CO_MSP_T3"] = "Benutze nur Template 3",
	["CO_MSP_T3_TT"] = "Selbst, wenn du ein anderes \"Über\"-Template auswählst, wird immer Template 3 genutzt, um MSP-Kompatibilität zu gewährleisten.",
	["CO_REGISTER"] = "Einstellungen registrieren",
	["CO_REGISTER_ABOUT_VOTE"] = "Benutze Bewertungssystem",
	["CO_REGISTER_ABOUT_VOTE_TT"] = "Aktiviert das Bewertungssystem, welches dir erlaubt, die Beschreibung von Charakteren als positiv oder negativ zu bewerten. Hierdurch kannt auch dein Charakter bewertet werden!",
	["CO_REGISTER_AUTO_ADD"] = "Neue Spieler automatisch hinzufügen",
	["CO_REGISTER_AUTO_ADD_TT"] = "Automatisch neue Spieler, denen du begegnest, zum Register hinzufügen.",
	["CO_REGISTER_AUTO_PURGE"] = "Verzeichnis automatisch bereinigen",
	["CO_REGISTER_AUTO_PURGE_0"] = "Bereinigung abschalten",
	["CO_REGISTER_AUTO_PURGE_1"] = "Nach %s Tag(en)",
	["CO_REGISTER_AUTO_PURGE_TT"] = [=[Entferne automatisch die Profile von Charakteren aus dem Verzeichnis, denen du seit einer bestimmten Zeit nicht mehr begegnet bist. Du eine Verzögerung vor der Löschung auswählen.
|cff00ff00Beachte dass Profile mit einem Verhältnis zu einem deiner Charaktere niemals bereinigt werden.
|cffff9900 Es gibt einen Bug in WoW bei dem alle gespeicherten Daten verloren gehen, wenn ein bestimmtes Limit überschritten wird. Wir raten eindringlich davon ab das Bereinigungssystem abzuschalten.

]=],
	["CO_SANITIZER"] = "Zensiere eingehende Profile",
	["CO_SANITIZER_TT"] = "Entfernt benutzerdefinierte Kommandos in Tooltips von neuen Profilen, wenn TRP diese nicht gestattet. ( Farben, Bilder ...)",
	["CO_TARGETFRAME"] = "Zielfenstereinstellungen",
	["CO_TARGETFRAME_ICON_SIZE"] = "Icongröße",
	["CO_TARGETFRAME_USE"] = "Anzeigebedingungen",
	["CO_TARGETFRAME_USE_1"] = "Immer",
	["CO_TARGETFRAME_USE_2"] = "Nur wenn IC",
	["CO_TARGETFRAME_USE_3"] = "Niemals (Deaktiviert)",
	["CO_TARGETFRAME_USE_TT"] = "Gibt an, unter welchen Bedingungen das Zielfenster am gewählten Ziel gezeigt werden soll.",
	["CO_TOOLBAR"] = "Fenstereinstellungen",
	["CO_TOOLBAR_CONTENT"] = "Toolbareinstellungen",
	["CO_TOOLBAR_CONTENT_CAPE"] = "Umhang an/aus",
	["CO_TOOLBAR_CONTENT_HELMET"] = "Helm an/aus",
	["CO_TOOLBAR_CONTENT_RPSTATUS"] = "Charakterstatus (IC/OOC)",
	["CO_TOOLBAR_CONTENT_STATUS"] = "Spielerstatus (AFK/DND)",
	["CO_TOOLBAR_HIDE_TITLE"] = "Verstecke Werkzeugleistentitel",
	["CO_TOOLBAR_HIDE_TITLE_HELP"] = "Versteckt den Titel, der über der Werkzeugleiste angezeigt wird.",
	["CO_TOOLBAR_ICON_SIZE"] = "Icongröße",
	["CO_TOOLBAR_MAX"] = "Maximale Icons pro Zeile",
	["CO_TOOLBAR_MAX_TT"] = "Auf 1 stellen wenn du die Leiste vertikal angezeigt haben möchtest!",
	["CO_TOOLBAR_SHOW_ON_LOGIN"] = "Zeige Toolbar beim Login",
	["CO_TOOLBAR_SHOW_ON_LOGIN_HELP"] = "Wenn du nicht möchtest, dass die Toolbar beim Login erscheint, deaktiviere diese Option.",
	["CO_TOOLTIP"] = "Tooltipeinstellungen",
	["CO_TOOLTIP_ANCHOR"] = "Ankerpunkt",
	["CO_TOOLTIP_ANCHORED"] = "Ankerfenster",
	["CO_TOOLTIP_CHARACTER"] = "Charaktertooltip",
	["CO_TOOLTIP_CLIENT"] = "Zeige Client",
	["CO_TOOLTIP_COLOR"] = "Benutzerdefinierte Farben anzeigen",
	["CO_TOOLTIP_COMBAT"] = "Während des Kampfs verbergen",
	["CO_TOOLTIP_COMMON"] = "Standardeinstellungen",
	["CO_TOOLTIP_CONTRAST"] = "Farbkontraste erhöhen",
	["CO_TOOLTIP_CONTRAST_TT"] = "Schalte diese Option ein um Total RP 3 zu erlauben die benutzerdefinierten Farben zu verändern, so dass Text in zu dunklen Farben leichter lesbar ist.",
	["CO_TOOLTIP_CROP_TEXT"] = "Ungerechtfertigt lange Texte kürzen",
	["CO_TOOLTIP_CROP_TEXT_TT"] = [=[Begrenze die Zeichenanzahl die im Tooltip für jedes Feld angezeigt werden kann um ungerechtfertigt lange Texte und mögliche Layoutprobleme zu verhindern.

|cfffff569Limit Details:
Name: 100 Zeichen
Titel: 150 Zeichen
Volk: 50 Zeichen
Klasse: 50 Zeichen|r]=],
	["CO_TOOLTIP_CURRENT"] = "Zeige \"aktuelle\" Informationen",
	["CO_TOOLTIP_CURRENT_LINES"] = "Maximale Zeilen unter \"Aktuelles\"",
	["CO_TOOLTIP_CURRENT_SIZE"] = "Maximale Länge von \"aktuellen\" Informationen",
	["CO_TOOLTIP_FT"] = "Zeige vollen Titel",
	["CO_TOOLTIP_GUILD"] = "Zeige Gildeninformationen",
	["CO_TOOLTIP_HIDE_ORIGINAL"] = "Verstecke Originaltooltip",
	["CO_TOOLTIP_ICONS"] = "Zeige Icons",
	["CO_TOOLTIP_IN_CHARACTER_ONLY"] = "Verbergen wenn Out Of Character",
	["CO_TOOLTIP_MAINSIZE"] = "Hauptschriftgröße",
	["CO_TOOLTIP_NO_FADE_OUT"] = "Sofort ausblenden anstatt verblassen",
	["CO_TOOLTIP_NOTIF"] = "Zeige Benachrichtigungen",
	["CO_TOOLTIP_NOTIF_TT"] = "Die Benachrichtigungszeile enthält die Clientversion, den Marker für ungelesene Beschreibungen und die \"Auf den Ersten Blick\" Leiste.",
	["CO_TOOLTIP_OWNER"] = "Zeige Besitzer",
	["CO_TOOLTIP_PETS"] = "Begleitertooltip",
	["CO_TOOLTIP_PETS_INFO"] = "Zeige Begleiterinformationen",
	["CO_TOOLTIP_PREFERRED_OOC_INDICATOR"] = "Bevorzugter OOC Indikator.",
	["CO_TOOLTIP_PREFERRED_OOC_INDICATOR_ICON"] = "Icon:",
	["CO_TOOLTIP_PREFERRED_OOC_INDICATOR_TEXT"] = "Text:",
	["CO_TOOLTIP_PROFILE_ONLY"] = "Nur benutzen, wenn das Ziel ein Profil hat",
	["CO_TOOLTIP_RACE"] = "Zeige Rasse, Klasse und Level",
	["CO_TOOLTIP_REALM"] = "Zeige Server",
	["CO_TOOLTIP_RELATION"] = "Zeige Beziehungsfarbe",
	["CO_TOOLTIP_RELATION_TT"] = "Fügt dem Rand des Charaktertooltips eine Farbe hinzu, um die Beziehung zu repräsentieren.",
	["CO_TOOLTIP_SPACING"] = "Zeige Leerzeile",
	["CO_TOOLTIP_SPACING_TT"] = "Zeigt Leerzeilen, um den Tooltip dem Tooltip von MyRoleplay ähnlich zu sehen.",
	["CO_TOOLTIP_SUBSIZE"] = "Sekundäre Schriftgöße",
	["CO_TOOLTIP_TARGET"] = "Zeige Ziel",
	["CO_TOOLTIP_TERSIZE"] = "Tertiäre Schriftgröße",
	["CO_TOOLTIP_TITLE"] = "Zeige Titel",
	["CO_TOOLTIP_USE"] = "Benutze die Tooltips für Charaktere/Begleiter",
	["CO_UI_RELOAD_WARNING"] = "Das Interface muss neu geladen werden, damit die Änderungen wirksam werden. Möchtest du das Interface jetzt neu laden?",
	["CO_WIM"] = "|cffff9900Flüsterkanäle deaktiviert.",
	["CO_WIM_TT"] = "Du nutzt |cff00ff00WIM|r, die Nutzung wurde aus Kompatibilitätsgründen deaktiviert",
	["COM_LIST"] = "Liste aller Befehle:",
	["COM_RESET_RESET"] = "Die Position des Fensters wurde zurückgesetzt.",
	["COM_RESET_USAGE"] = "Hinweis: |cff00ff00/trp3 reset frames|r, um alle Fensterpositionen zurückzusetzen.",
	["COM_STASH_DATA"] = [=[|cffff0000Bist du sicher, dass du deine Total RP 3 Daten auslagern möchtest?|r

Deine Profile, Begleiterprofile und Einstellungen werden temporär ausgelagert und dein UI wird mit leeren Daten neu geladen, als wäre es eine brandneue Installation von Total RP 3.
|cff00ff00Nutze den selben Befehl nochmal (|cff999999/trp3 stash|cff00ff00) um die Daten wiederherzustellen.|r]=],
	["COM_SWITCH_USAGE"] = "Hinweis: |cff00ff00/trp3 switch main|r, um das Hauptfenster umzuschalten oder |cff00ff00/trp3 switch toolbar|r, um die Werkzeugleiste umzuschalten.",
	["DB_ABOUT"] = "Über Total RP 3",
	["DB_HTML_GOTO"] = "Zum Öffnen klicken",
	["DB_MORE"] = "Mehr Module",
	["DB_NEW"] = "Was ist neu?",
	["DB_STATUS"] = "Status",
	["DB_STATUS_CURRENTLY"] = "Aktuelles (IC)",
	["DB_STATUS_CURRENTLY_COMMON"] = "Der Status wird im Tooltip deines Charakters angezeigt. Halte dich hier kurz, knapp und eindeutig, da |cffff9900standartmäßig alle TRP3 Nutzer nur die ersten 140 Zeichen sehen können!",
	["DB_STATUS_CURRENTLY_OOC"] = "Andere Informationen (OOC)",
	["DB_STATUS_CURRENTLY_OOC_TT"] = "Hier kannst du Wichtiges über dich als Spieler oder andere OOC Informationen eintragen.",
	["DB_STATUS_CURRENTLY_TT"] = "Hier kannst du Wichtiges über deinen Charakter angeben.",
	["DB_STATUS_LC"] = "Rollenspiel Sprache",
	["DB_STATUS_LC_TT"] = "Speichert deine bevorzugte Rollenspiel Sprache. Diese Einstellung wird mit anderen Benutzern mit kompatiblem RP Addon geteilt. |cffff9900Achtung:|r Diese Option ändert |cffff0000nicht|r die Menüsprache von Total RP 3. Diese Möglichkeit findest du unter |cfffff569Erweiterte Einstellungen|r.",
	["DB_STATUS_RP"] = "Charakterstatus",
	["DB_STATUS_RP_EXP"] = "Erfahrener Rollenspieler",
	["DB_STATUS_RP_EXP_TT"] = [=[Zeigt an, dass du ein erfahrener Rollenspieler bist.
Zeigt kein spezielles Icon auf deinem Tooltip an.]=],
	["DB_STATUS_RP_IC"] = "In Character (IC)",
	["DB_STATUS_RP_IC_TT"] = [=[Die spielst diesen Charakter aktuell aus.
Dein gesamtes Handeln wird bewertet, als ob dein Charakter diese Aktionen ausführt.]=],
	["DB_STATUS_RP_OOC"] = "Out of Character (OOC)",
	["DB_STATUS_RP_OOC_TT"] = [=[Du spielst diesen Charakter aktuell nicht aus.
Dein Handeln wird nicht mit dem Charakter in Verbindung gebracht.]=],
	["DB_STATUS_RP_VOLUNTEER"] = "Rollenspiellehrer",
	["DB_STATUS_RP_VOLUNTEER_TT"] = "Diese Auswahl zeigt mithilfe eines Icons auf deinem Tooltip an, dass du Rollenspielanfängern Hilfestellung gibst.",
	["DB_STATUS_XP"] = "Rollenspielerfahrung",
	["DB_STATUS_XP_BEGINNER"] = "Rollenspielanfänger",
	["DB_STATUS_XP_BEGINNER_TT"] = "Diese Auswahl zeigt mithilfe eines Icons auf deinem Tooltip an, dass du noch Rollenspielanfänger bist.",
	["DB_TUTO_1"] = [=[|cffffff00Der Charakter Status|r zeigt an, ob du deinen Charakter momentan ausspielst oder nicht.

|cffffff00Die Rollenspielerfahrung|r gibt an, ob du ein blutiger Anfänger oder ein erfahrener Rollenspieler bist, der gerne Neulingen hilft!

|cff00ff00Diese Informationen werden im Tooltip deines Charakters angezeigt.]=],
	["DICE_HELP"] = "Ein Würfelwurf oder mehrere Würfe durch Leerzeichen getrennt, z.B: 1d6, 2d12 3d20 ...",
	["DICE_ROLL"] = "%s rollt |cffff9900%sx d%s|r|cffcc6600%s|r und erziehlt |cff00ff00%s|r.",
	["DICE_ROLL_T"] = "%s %s würfelt |cffff9900%sx w%s|r|cffcc6600%s|r und erhält |cff00ff00%s|r.",
	["DICE_TOTAL"] = "%s Insgesamt |cff00ff00%s|r mit diesem Wurf.",
	["DICE_TOTAL_T"] = "%s %s hat insgesamt |cff00ff00%s|r mit diesem Wurf erzielt.",
	["DTBK_AFK"] = "Total RP 3 - AFK/DND",
	["DTBK_CLOAK"] = "Total RP 3 - Rücken",
	["DTBK_HELMET"] = "Total RP 3 - Helm",
	["DTBK_LANGUAGES"] = "Total RP 3 - Sprachen",
	["DTBK_RP"] = "Total RP 3 - IC/OOC",
	["GEN_VERSION"] = "Version: %s (Build %s)",
	["GEN_WELCOME_MESSAGE"] = "Danke, dass du Total RP 3 (v %s) verwendest! Viel Spaß!",
	["LANG_CHANGE_CAUSED_REVERT_TO_DEFAULT"] = "Deine aktuell gesprochene Sprache wurde auf %s zurückgesetzt, da du die vorherige Sprache %s nicht mehr verstehst. ",
	["MAP_BUTTON_NO_SCAN"] = "Kein Scan verfügbar",
	["MAP_BUTTON_SCANNING"] = "Scanne",
	["MAP_BUTTON_SUBTITLE"] = "Klicken um verfügbare Scans anzuzeigen",
	["MAP_BUTTON_SUBTITLE_80_DISABLED"] = [=[Aufgrund von 8.0 Änderungen sind Scans momentan nicht möglich.
]=],
	["MAP_BUTTON_SUBTITLE_CONNECTING"] = "Das Scannen der Karte wird eingerichtet. Bitte warten.",
	["MAP_BUTTON_SUBTITLE_OFFLINE"] = "Das Scannen der Karte ist momentan nicht verfügbar: %s",
	["MAP_BUTTON_TITLE"] = "Nach Rollenspiel scannen",
	["MAP_SCAN_CHAR"] = "Nach Charakteren scannen",
	["MAP_SCAN_CHAR_TITLE"] = "Charaktere",
	["MATURE_FILTER_ADD_TO_WHITELIST"] = "Dieses Profil der cffffffffErwachseneninhalte Whitelist|r hinzufügen",
	["MATURE_FILTER_ADD_TO_WHITELIST_OPTION"] = "Der |cffffffffErwachseneninhalte Whitelist|r hinzufügen",
	["MATURE_FILTER_ADD_TO_WHITELIST_TEXT"] = [=[Bestätige, dass du %s der |cffffffffErwachseneninhalte Whitelist|r hinzufügen willst.

Der Inhalt des Profils wird nicht länger versteckt sein.]=],
	["MATURE_FILTER_ADD_TO_WHITELIST_TT"] = "Dieses Profil der |cffffffffErwachseneninhalte Whitelist|r hinzufügen und die darin enthaltenen Inhalte für Erwachsene anzeigen.",
	["MATURE_FILTER_EDIT_DICTIONARY"] = "Benutzerdefiniertes Wörterbuch bearbeiten",
	["MATURE_FILTER_EDIT_DICTIONARY_ADD_BUTTON"] = "Hinzufügen",
	["MATURE_FILTER_EDIT_DICTIONARY_ADD_TEXT"] = "Dem Wörterbuch ein neues Wort hinzufügen",
	["MATURE_FILTER_EDIT_DICTIONARY_BUTTON"] = "Editieren",
	["MATURE_FILTER_EDIT_DICTIONARY_DELETE_WORD"] = "Das Wort aus dem benutzerdefinierten Wörterbuch entfernen",
	["MATURE_FILTER_EDIT_DICTIONARY_EDIT_WORD"] = "Dieses wort editieren",
	["MATURE_FILTER_EDIT_DICTIONARY_RESET_BUTTON"] = "Zurücksetzen",
	["MATURE_FILTER_EDIT_DICTIONARY_RESET_TITLE"] = "Wörterbuch zurücksetzen",
	["MATURE_FILTER_EDIT_DICTIONARY_RESET_WARNING"] = "Bist du sicher, dass du das Wörterbuch zurücksetzen möchtest? Alle Einträge werden entfernt und durch die Standard Wörter deiner Sprache ersetzt (falls vorhanden).",
	["MATURE_FILTER_EDIT_DICTIONARY_TITLE"] = "Benutzerdefiniertes Wörterbuch-Editor",
	["MATURE_FILTER_EDIT_DICTIONARY_TT"] = "Das benutzerdefinierte Wörterbuch editieren, welches zur Filterung von Profilen mit Erwachseneninhalten verwendet wird.",
	["MATURE_FILTER_FLAG_PLAYER"] = "Als Inhalt für Erwachsene markieren",
	["MATURE_FILTER_FLAG_PLAYER_OPTION"] = "Als Inhalt für Erwachsene markieren",
	["MATURE_FILTER_FLAG_PLAYER_TEXT"] = [=[Bestätige, dass du markieren willst, dass das Profil von %s Erwachseneninhalte enthält. Das Profil wird versteckt werden.

|cffffff00Optional:|r Gib das anstößige Wort an welches du im Profil gefunden hast (trenne mehrere Wörter mit Leerzeichen), um es dem Filter hinzuzufügen.]=],
	["MATURE_FILTER_FLAG_PLAYER_TT"] = "Markiere, dass dieses Profil Erwachseneninhalte enthält. Der Inhalt des Profils wird versteckt werden.",
	["MATURE_FILTER_OPTION"] = "Profile mit Erwachseneninhalten filtern",
	["MATURE_FILTER_OPTION_TT"] = [=[Wähle diese Option aus um die Filterung von Erwachseneninhalten zu aktivieren. Total RP 3 wird eintreffende Profile nach bestimmten Schlüsselworten durchsuchen die als Erwachseneninhalte festgelegt wurden und das Profil entsprechend markieren wenn ein solches Wort gefunden wird.

Ein Profil mit Erwachseneninhalten wird einen stummgeschalteten Tooltip haben und du wirst bestätigen müssen, dass du es dir ansehen willst, wenn du es zum ersten Mal aufrufst.]=],
	["MATURE_FILTER_REMOVE_FROM_WHITELIST"] = "Dieses Profil aus der |cffffffffErwachseneninhalte Whitelist|r entfernen",
	["MATURE_FILTER_REMOVE_FROM_WHITELIST_OPTION"] = "Aus der |cffffffffErwachseneninhalte Whitelist|r entfernen",
	["MATURE_FILTER_REMOVE_FROM_WHITELIST_TEXT"] = [=[Bestätige, dass du das Profil von %s aus der |cffffffffErwachseneninhalte Whitelist|r entfernen willst

Der Inhalt des Profils wird wieder versteckt werden.]=],
	["MATURE_FILTER_REMOVE_FROM_WHITELIST_TT"] = "Dieses Profil aus der |cffffffffErwachseneninhalte Whitelist|r entfernen und den Erwachseneninhalt darin wieder verstecken.",
	["MATURE_FILTER_STRENGTH"] = "Stärke des Schimpfwortfilters",
	["MATURE_FILTER_STRENGTH_TT"] = "Setzt die Stärke des Schimpfwort Filters. cffcccccc1 ist schwach (Sätze werden ab 10 Schimpfwörtern erkannt), 10 ist stark (Es reicht ein einzelnes Schimpfwort zur Erkennung).|r",
	["MATURE_FILTER_TITLE"] = "Filter für Profile mit Erwachseneninhalten",
	["MATURE_FILTER_TOOLTIP_WARNING"] = "Erwachseneninhalt",
	["MATURE_FILTER_TOOLTIP_WARNING_SUBTEXT"] = "Das Profil dieses Charakters enthält Inhalte für Erwachsene. Verwende die ",
	["MATURE_FILTER_WARNING_CONTINUE"] = "Weiter",
	["MATURE_FILTER_WARNING_GO_BACK"] = "Zurück",
	["MATURE_FILTER_WARNING_TEXT"] = [=[Du hast Total RP 3's Erwachseneninhalt Filtersystem angeschaltet.

Dieses Profil wurde als Profil mit Inhalt für Erwachsene markiert.

Bist du sicher, dass du dir das Profil ansehen willst?]=],
	["MATURE_FILTER_WARNING_TITLE"] = "Erwachseneninhalt",
	["MM_SHOW_HIDE_MAIN"] = "Zeige/verstecke das Hauptfenster",
	["MM_SHOW_HIDE_MOVE"] = "Icon bewegen",
	["MM_SHOW_HIDE_SHORTCUT"] = "Zeig/verstecke die Toolbar",
	["MO_ADDON_NOT_INSTALLED"] = "Das Addon %s ist nicht installiert, eigene Total RP 3 Integration deaktiviert.",
	["MO_CHAT_CUSTOMIZATIONS_DESCRIPTION"] = "Fügt angepasste Kompatibilität zu dem Addon %s, damit deine Chat Nachrichten und Spielernamen durch Total RP 3 angepasst werden können.",
	["MO_TOOLTIP_CUSTOMIZATIONS_DESCRIPTION"] = "Fügt angepasste Kompatibilität zu dem Addon %s, damit deine Tooltipeinstellungen für Total RP 3 übernommen werden.",
	["MORE_MODULES_2"] = [=[{h2:c}Optionale Module{/h2}
{h3}Total RP 3: Extended |cffF87431|r{/h3}
|cff9999ffTotal RP 3: Extended|r fügt die Möglichkeit hinzu neuen Inhalt in WoW zu erstellen. Kampagnen mit Aufträgen und Dialogen, Gegenstände, Dokumente (Bücher, Schilder, Kontrakte, ...) und vieles mehr!
{link*https://www.curseforge.com/wow/addons/total-rp-3-extended*Download on CurseForge}

{h3}TRP3 Currently Frame{/h3}
Adds a standalone frame to your UI that displays your "Currently" text and allows you to edit it easily.
{link*https://www.curseforge.com/wow/addons/trp3-currently-frame*Download on CurseForge}

{h3}TRP3 Location Toggle{/h3}
Adds a simple button to the toolbar to toggle on and off the map scan location feature.
{link*https://www.curseforge.com/wow/addons/trp3-location-toggle*Download on CurseForge}]=],
	["NEW_VERSION"] = [=[|cff00ff00Eine neue Version von Total RP 3 (v %s) ist verfügbar.

|cffffff00Wir empfehlen dringendst auf dem aktuellen Stand zu bleiben.|r

Diese Nachricht wird nur einmal pro Sitzung angezeigt und kann in den Einstellungen (Allgemeine Einstellungen => Verschiedenes) abgeschaltet werden.]=],
	["NEW_VERSION_BEHIND"] = "Du hinkst momentan %s Versionen hinterher und verpasst dadurch viele Bugfixes und neue Features. Anderen Spielern könnten zudem dein Profil nicht richtig angezeigt werden. Bitte ziehe in Erwägung dein Addon zu updaten.",
	["NEW_VERSION_TITLE"] = "Neues Update verfügbar",
	["NPC_TALK_BUTTON_TT"] = "Das NSC-Sprachfenster zu öffnen erlaubt dir NSC sprechen oder emoten zu lassen.",
	["NPC_TALK_CHANNEL"] = "Kanal:",
	["NPC_TALK_COMMAND_HELP"] = "NSC-Sprachfenster öffnen",
	["NPC_TALK_ERROR_EMPTY_MESSAGE"] = "Die Nachricht darf nicht leer sein.",
	["NPC_TALK_MESSAGE"] = "Nachricht",
	["NPC_TALK_NAME"] = "NSC Name",
	["NPC_TALK_NAME_TT"] = [=[Du kannst Standard-Chat-Tags wie %t um den Namen deines Ziels verwenden oder %f um den Namen deines Fokus einzufügen.

Du kannst dieses Feld auch leer lassen, um Emotes ohne einen NSC-Namen am Anfang zu erstellen.

Den Begleiternamen in [Klammern] einsetzen erlaubt es dir, die Farbe und das Icon anzupassen.]=],
	["NPC_TALK_SAY_PATTERN"] = "sagt:",
	["NPC_TALK_SEND"] = "Senden",
	["NPC_TALK_TITLE"] = "NSC Sprache",
	["NPC_TALK_WHISPER_PATTERN"] = "flüstert:",
	["NPC_TALK_YELL_PATTERN"] = "schreit:",
	["OPTION_DISABLED_TOAST"] = "Option deaktiviert",
	["OPTION_ENABLED_TOAST"] = "Option aktiviert",
	["PATTERN_ERROR"] = "Fehler im Eingabemuster",
	["PATTERN_ERROR_TAG"] = "Fehler im Eingabemuster: Nicht-geschlossener Text-Tag",
	["PR_CO_BATTLE"] = "Begleiter",
	["PR_CO_COUNT"] = "%s Haustiere/Reittiere an dieses Profil gebunden.",
	["PR_CO_EMPTY"] = "Kein Begleiterprofil",
	["PR_CO_MASTERS"] = "Meister",
	["PR_CO_MOUNT"] = "Reittier",
	["PR_CO_NEW_PROFILE"] = "Neues Begleiterprofil",
	["PR_CO_PET"] = "Tier",
	["PR_CO_PROFILE_DETAIL"] = "Dieses Profil ist aktuell gebunden an",
	["PR_CO_PROFILE_HELP"] = [=[Ein Profil enthält alle Informationen über ein |cffffff00"Haustier/Begleiter"|r als |cff00ff00Rollenspiel Charakter|r.

Ein Begleiterprofil kann an folgende Begleiterarten gebunden werden:
- Ein Kampfhaustier |cffff9900(nur wenn es umbennant wurde)|r
- Einen Jägerbegleiter
- Einen Diener eines Hexenmeisters
- Einen Magierelementar
- Einen Ghul eines Todesritters |cffff9900(siehe unten)|r

Genau wie bei einem Charakterprofil kann ein |cff00ff00Begleiterproful|r mit |cffffff00verschiedenen Haustieren|r verbunden werden. Genauso kannst du für dein |cffffff00Haustier|r einfach durch die verschiedenen Profile schalten.

|cffff9900Ghule:|r Für einen Ghul musst du das Profil bei jeder Beschwörung neu auswählen, da dessen Spielname zufällig vergeben wird!]=],
	["PR_CO_PROFILE_HELP2"] = [=[Hier klicken um eine neues Begleiterprofil anzulegen.

|cff00ff00Um ein Profil einem Haustier zu zuweisen, beschwöre einfach dein Haustier/Begleiter, wähle es aus und benutze das Zielfenster um es einem Profil zu zuweisen (oder ein neues Profil zu erstellen).|r]=],
	["PR_CO_PROFILEMANAGER_DELETE_WARNING"] = [=[Bist du sicher, dass du dieses Begleiterprofil %s löschen willst?
Diese Aktion kann nicht rückgängig gemacht werden und alle TRP3 Informationen, die damit zusammenhängen, werden unwiderruflich zerstört!]=],
	["PR_CO_PROFILEMANAGER_DUPP_POPUP"] = [=[Bitte gibt einen Namen für das neue Profil ein.
Der Name darf nicht leer sein.

Diese Kopie ändert nicht die Bindung deines Haustieres/Reittieres zu %s.]=],
	["PR_CO_PROFILEMANAGER_EDIT_POPUP"] = [=[Bitte gib einen Namen für das Profil %s ein.
Der Name darf nicht leer sein.

Das Ändern des Namens ändert nicht die Verbindung des Profils mit deinem Haustier/Reittier.]=],
	["PR_CO_PROFILEMANAGER_TITLE"] = "Begleiterprofile",
	["PR_CO_UNUSED_PROFILE"] = "Dieses Profil ist aktuell nicht an ein Haustier oder Reittier gebunden.",
	["PR_CO_WARNING_RENAME"] = [=[|cffff0000Warnung:|r Es wird dringend empfohlen, dein Haustier umzubenennen, bevor du es mit einem Profil verbindest.

Trotzdem verbinden?]=],
	["PR_CREATE_PROFILE"] = "Profil erstellen",
	["PR_DELETE_PROFILE"] = "Profil löschen",
	["PR_DUPLICATE_PROFILE"] = "Profil kopieren",
	["PR_EXPORT_IMPORT_HELP"] = [=[Du kannst Profile über die Option im Dropdownmenü exportieren und importieren.

Benutze die |cffffff00Profil exportieren|r Option um eine Textserie zu generieren der die Profildaten enthält. Du kannst den Text über Strg+C (Command+C auf einem Mac) kopieren und es woanders als Sicherung einfügen. (|cffff0000Bitte beachte, dass einige fortgeschrittene Textverarbeitungswerkzeuge wie Microsoft Word Sonderzeichen als Zitate ansehen und die Daten verändern. Verwende daher einfachere Werkzeuge wie Notepad.|r)

Benutze die |cffffff00Profil importieren|r Option um Daten aus einem früheren Export in ein existierendes Profil einzufügen. Die existierenden Daten des Profils werden durch das die neu eingefügten ersetzt. Du kannst die Daten nicht direkt in das derzeit ausgewählte Profil importieren.]=],
	["PR_EXPORT_IMPORT_TITLE"] = "Profil exportieren/importieren",
	["PR_EXPORT_NAME"] = "Text für Profil %s (Größe %0.2f kB)",
	["PR_EXPORT_PROFILE"] = "Profil exportieren",
	["PR_EXPORT_TOO_LARGE"] = [=[Dieses Profil ist zu groß und kann nicht exportiert werden.

Profilgröße: %0.2f kB
Max: 20 kB]=],
	["PR_EXPORT_WARNING_MAC"] = "Bitte achte darauf, dass manche Textverarbeitungsprogramme  wie Text Edit oder Discord manche Zeichen (wie z.B. Anführungszeichen) besonders behandeln und damit den Inhalt verändern. Wenn du vor hast den unteren Text in ein Dokument zu kopieren, benutze bitte ein einfaches Textverarbeitungsprogramme, das keine automatische Zeichenerkennung benutzt. (In Text Edit gehe zu  Format > Nur Text erstellen, vor dem Einfügen.)",
	["PR_EXPORT_WARNING_TITLE"] = "Warnung:",
	["PR_EXPORT_WARNING_WINDOWS"] = "Bitte achte darauf, dass manche Textverarbeitungsprogramme  wie Microsoft Word oder Discord manche Zeichen (wie z.B. Anführungszeichen) besonders behandeln und damit den Inhalt verändern. Wenn du vor hast den unteren Text in ein Dokument zu kopieren, benutze bitte ein einfaches Textverarbeitungsprogramme, das keine automatische Zeichenerkennung benutzt, wie zum Beispiel den normalen Windows Editor.",
	["PR_IMPORT"] = "Importieren",
	["PR_IMPORT_CHAR_TAB"] = "Charakterimporteur",
	["PR_IMPORT_EMPTY"] = "Kein importierbares Profil",
	["PR_IMPORT_IMPORT_ALL"] = "Alles importieren",
	["PR_IMPORT_PETS_TAB"] = "Begleiterimporteur",
	["PR_IMPORT_PROFILE"] = "Profil importieren",
	["PR_IMPORT_PROFILE_TT"] = "Hier einen Profiltext einfügen",
	["PR_IMPORT_WILL_BE_IMPORTED"] = "Wird importiert",
	["PR_PROFILE"] = "Profil",
	["PR_PROFILE_CREATED"] = "Profile %s erstellt.",
	["PR_PROFILE_DELETED"] = "Profile %s gelöscht.",
	["PR_PROFILE_DETAIL"] = "Dieses Profil ist aktuell an diese WoW Charaktere gebunden",
	["PR_PROFILE_HELP"] = [=[Ein Profil enthält alle Informationen über einen |cffffff00"Charakter"|r als |cff00ff00Rollenspielcharakter|r.

Ein realer |cffffff00"WoW Charakter"|r kann nur an ein Profil gleichzeitig gebunden sein, kann aber zwischen verschiedenen Profilen hin und her schalten.

Du kannst auch mehrere |cffffff00"WoW Charaktere"|r an dasselbe |cff00ff00Profil|r binden!]=],
	["PR_PROFILE_LOADED"] = "Das Profil %s ist geladen.",
	["PR_PROFILE_MANAGEMENT_TITLE"] = "Profilverwaltung",
	["PR_PROFILEMANAGER_ACTIONS"] = "Aktionen",
	["PR_PROFILEMANAGER_ALREADY_IN_USE"] = "Der Profilname %s ist nicht verfügbar.",
	["PR_PROFILEMANAGER_COUNT"] = "%s WoW Charakter/e an dieses Profil gebunden.",
	["PR_PROFILEMANAGER_CREATE_POPUP"] = [=[Gib bitte einen Namen für das neue Profil ein.
Die Namenszeile darf nicht leer sein.]=],
	["PR_PROFILEMANAGER_CURRENT"] = "Aktuelles Profil",
	["PR_PROFILEMANAGER_DELETE_WARNING"] = [=[Bist du sicher, dass du das Profil %s? löschen willst
Diese Aktion kann nicht rückgängig gemacht werden und alle TRP3 Informationen, die damit verbunden sind, werden unwiderruflich gelöscht!]=],
	["PR_PROFILEMANAGER_DUPP_POPUP"] = [=[Gib bitte einen Namen für das neue Profil ein.
Die Namenszeile darf nicht leer sein.

Diese Kopie ändert nicht die Bindung zu %s.]=],
	["PR_PROFILEMANAGER_EDIT_POPUP"] = [=[Gib bitte einen neuen Namen für das Profil %s ein.
Die Namenszeile darf nicht leer sein.

Die änderung des Namens verändert nicht die Verbindung zwischen dem Profil und den Charakteren.]=],
	["PR_PROFILEMANAGER_IMPORT_WARNING"] = "Den gesamten Inhalt des Profils %s mit den importierten Daten überschreiben?",
	["PR_PROFILEMANAGER_IMPORT_WARNING_2"] = [=[Warnung: dieser Profiltext wurde mit einer älteren Version von TRP3 erstellt.
Dies kann zu Inkompatibilitäten führen.

Den gesamten Inhalt des Profils %s mit den importierten Daten überschreiben?]=],
	["PR_PROFILEMANAGER_RENAME"] = "Profil umbenennen",
	["PR_PROFILEMANAGER_SWITCH"] = "Profil auswählen",
	["PR_PROFILEMANAGER_TITLE"] = "Charakterprofile",
	["PR_PROFILES"] = "Profile",
	["PR_SLASH_EXAMPLE"] = "|cffffff00Befehlnutzung:|r |cffcccccc/trp3 profile Millidan Foamrage|r |cffffff00wechselt zu Millidan Foamrages Profil.|r\"",
	["PR_SLASH_NOT_FOUND"] = "|cffff0000Das Profil Namens|r |cffffff00%s|r|cffff0000.|r wurde nicht gefunden.",
	["PR_SLASH_OPEN_ABORTING"] = "|cffffff00Profilabfrage abgebrochen.|r",
	["PR_SLASH_OPEN_EXAMPLE"] = "|cffffff00Befehlnutzung:|r |cffcccccc/trp3 open|r |cffffff00um das Charakterprofil des Ziels zu öffnen oder |cffcccccc/trp3 open CharakterName-RealmName|r |cffffff00um das Profil eines Charakters zu öffnen.|r",
	["PR_SLASH_OPEN_HELP"] = "Öffnet ein Charakterprofil anhand des Im-Spiel-Name oder anhand des Profile des Ziels, wenn kein Name angegeben wurde.",
	["PR_SLASH_OPEN_WAITING"] = "|cffffff00Frage Profile ab, bitte warten...|r",
	["PR_SLASH_SWITCH_HELP"] = [=[
Wechsel zu einem anderen Profil mit diesem Namen.]=],
	["PR_UNUSED_PROFILE"] = "Dieses Profil ist aktuell an keinen WoW Charakter gebunden.",
	["REG_CODE_INSERTION_WARNING"] = [=[|TInterface\AddOns\totalRP3\resources\policegar.tga:50:50|t
Moment mal!

Wir haben bemerkt, das Ihr manuell ungültige Codes in Euer Total RP 3 Profil eingegeben habt.
Dies wird nicht unterstützt und wir raten jedem dringend davon ab dieses zu tun.
Es kann zu Instabilität und Bugs im Add-on, beschädigten Daten und/oder Verlust von Profilen führen. Des weiteren können Kompatibilitätsprobleme mit anderen Add-ons (wie MRP) entstehen.

Die Codes, die Ihr in Euer Profil eingefügt habt, wurden entfernt um zu verhindern, dass Ihr das Add-on beschädigt.]=],
	["REG_COMPANION"] = "Begleiter",
	["REG_COMPANION_BOUND_TO"] = "Gebunden an ...",
	["REG_COMPANION_BOUND_TO_TARGET"] = "Ziel",
	["REG_COMPANION_BOUNDS"] = "Bindungen",
	["REG_COMPANION_BROWSER_BATTLE"] = "Wildtierbrowser",
	["REG_COMPANION_BROWSER_MOUNT"] = "Reittierbrowser",
	["REG_COMPANION_INFO"] = "Information",
	["REG_COMPANION_LINKED"] = "Der Begleiter %s ist nun verbunden mit dem Profil %s",
	["REG_COMPANION_LINKED_NO"] = "Der Begleiter %s ist nun nicht mehr mit einem Profil verbunden.",
	["REG_COMPANION_NAME"] = "Name",
	["REG_COMPANION_NAME_COLOR"] = "Namensfarbe",
	["REG_COMPANION_PAGE_TUTO_C_1"] = "Consult",
	["REG_COMPANION_PAGE_TUTO_E_1"] = [=[Das ist die|cff00ff00 Hauptinformation deines Begleiters|r.

All diese Informationen werden |cffff9900im Tooltip deines Begleiters angezeigt|r.]=],
	["REG_COMPANION_PAGE_TUTO_E_2"] = [=[Das ist die|cff00ff00 Beschreibung deines Charakters|r.

Es ist nicht auf eine |cffff9900Physische Beschreibung|r limitiert. Deute hier ruhig Teile seiner |cffff9900Hintergrundgeschichte|r oder Details über seine |cffff9900Persönlichkeit|r an.

Es gibt unzählige Wege, die Beschreibung zu personalisieren.
Du kannst eine |cffffff00Hintergrundtextur|r für die Beschreibung aussuchen. Du kannst ebenfalls die Formatierungstools verwenden, um Dinge wie |cffffff00Schriftgröße, Farbe und Textausrichtung|r anzupassen.
Diese Tools erlauben dir auch das Einfügen von |cffffff00Bildern, Icons oder Links zu externen Internetseiten|r.]=],
	["REG_COMPANION_PROFILES"] = "Begleiterprofile",
	["REG_COMPANION_TARGET_NO"] = "Dein Ziel ist kein gültiges Haustier, Diener, Ghul, Elementar oder umbenanntes Kampfhaustier.",
	["REG_COMPANION_TF_BOUND_TO"] = "Profil auswählen",
	["REG_COMPANION_TF_CREATE"] = "Neues Charakterprofil erstellen",
	["REG_COMPANION_TF_NO"] = "Kein Profil",
	["REG_COMPANION_TF_OPEN"] = "Seite öffnen",
	["REG_COMPANION_TF_OWNER"] = "Besitzer: %s",
	["REG_COMPANION_TF_PROFILE"] = "Begleiterprofil",
	["REG_COMPANION_TF_PROFILE_MOUNT"] = "Reittierprofil",
	["REG_COMPANION_TF_UNBOUND"] = "Profil abwählen",
	["REG_COMPANION_TITLE"] = "Titel",
	["REG_COMPANION_UNBOUND"] = "Entbinden von ...",
	["REG_COMPANIONS"] = "Begleiter",
	["REG_DELETE_WARNING"] = [=[Bist du sicher, dass du das Profil "%s" löschen möchtest?
]=],
	["REG_IGNORE_TOAST"] = "Charakter wird ignoriert",
	["REG_LIST_ACTIONS_MASS"] = "Aktion auf %s ausgewählte Profile",
	["REG_LIST_ACTIONS_MASS_IGNORE"] = "Profile ignorieren",
	["REG_LIST_ACTIONS_MASS_IGNORE_C"] = [=[Diese Aktion wird |cff00ff00%s Charaktere der Ignorieren Liste hinzufügen.

Optional kann hier ein Grund angegeben werden. Es handelt sich um eine persönliche Notiz, die nur zur Erinnerung dient.]=],
	["REG_LIST_ACTIONS_MASS_REMOVE"] = "Profile entfernen",
	["REG_LIST_ACTIONS_MASS_REMOVE_C"] = "Diese Aktion wird |cff00ff00%s ausgewählte/s Profil/e löschen|r.",
	["REG_LIST_ACTIONS_PURGE"] = "Register entfernen",
	["REG_LIST_ACTIONS_PURGE_ALL"] = "Alle Profile löschen",
	["REG_LIST_ACTIONS_PURGE_ALL_C"] = [=[Dies wird alle Profile und verlinkten Charaktere löschen.

|cff00ff00%s Charaktere.]=],
	["REG_LIST_ACTIONS_PURGE_ALL_COMP_C"] = [=[Dies wird alle deine Begleiter löschen.

|cff00ff00%s Begleiter.]=],
	["REG_LIST_ACTIONS_PURGE_COUNT"] = "%s Profile werden gelöscht.",
	["REG_LIST_ACTIONS_PURGE_EMPTY"] = "Keine Profile zum Löschen.",
	["REG_LIST_ACTIONS_PURGE_IGNORE"] = "Profile von ignorierten Charakteren",
	["REG_LIST_ACTIONS_PURGE_IGNORE_C"] = [=[Diese Aktion wird alle Profile, die mit ignorierten Charakteren verbunden sind, löschen.

|cff00ff00%s]=],
	["REG_LIST_ACTIONS_PURGE_TIME"] = "Seit 1 Monat nicht mehr gesehene Profile",
	["REG_LIST_ACTIONS_PURGE_TIME_C"] = [=[Dies wird alle Profile löschen, die seit einem Monat nicht gesehen wurden.

|cff00ff00%s]=],
	["REG_LIST_ACTIONS_PURGE_UNLINKED"] = "Profile ohne Charakter",
	["REG_LIST_ACTIONS_PURGE_UNLINKED_C"] = [=[Dies wird alle Profile, die nicht an einen WoW Charakter gebunden sind, löschen.

|cff00ff00%s]=],
	["REG_LIST_ADDON"] = "Profiltyp",
	["REG_LIST_CHAR_EMPTY"] = "Kein Charakter",
	["REG_LIST_CHAR_EMPTY2"] = "Kein Charakter passt zu deiner Auswahl",
	["REG_LIST_CHAR_FILTER"] = "Charaktere: %s / %s",
	["REG_LIST_CHAR_IGNORED"] = "Ignoriert",
	["REG_LIST_CHAR_SEL"] = "Charakter wählen",
	["REG_LIST_CHAR_TITLE"] = "Charakterliste",
	["REG_LIST_CHAR_TT"] = "Zum Anzeigen klicken",
	["REG_LIST_CHAR_TT_CHAR"] = "Gebundene WoW Charakter/e:",
	["REG_LIST_CHAR_TT_CHAR_NO"] = "Nicht an einen Charakter gebunden",
	["REG_LIST_CHAR_TT_DATE"] = [=[Zuletzt gesehen: |cff00ff00%s|r
Wo zuletzt gesehen: |cff00ff00%s|r]=],
	["REG_LIST_CHAR_TT_GLANCE"] = "Auf den ersten Blick",
	["REG_LIST_CHAR_TT_IGNORE"] = "Ignorierte Charakter/e",
	["REG_LIST_CHAR_TT_NEW_ABOUT"] = "Ungelesene Beschreibung",
	["REG_LIST_CHAR_TT_RELATION"] = [=[Beziehung:
|cff00ff00%s]=],
	["REG_LIST_CHAR_TUTO_ACTIONS"] = "Diese Spalte erlabt es dir, mehrere Charaktere auszuwählen, um die selbe Aktion auf diese auszuführen.",
	["REG_LIST_CHAR_TUTO_FILTER"] = [=[Du kannst nach verschiedenen Kriterien filtern.

Der |cff00ff00Namensfilter|r wird nach bestimmten Profilnamen suchen (Vorname + Nachname) sowie nach WoW Charakteren.

Der |cff00ff00Gildenfilter|r wird nach Charakteren einer bestimmten Gilde suchen.

Der |cff00ff00Realm Only Filter|r wird nur nach Charakteren auf dem aktuellen Realm suchen.]=],
	["REG_LIST_CHAR_TUTO_LIST"] = [=[Die erste Spalte zeigt den Charakternamen.

Die zweite Spalte zeigt die Beziehung zwischen den Charakteren und deinem Charakter.

Die letzte Spalte ist für diverse Angaben. (ignoriert ..etc.)]=],
	["REG_LIST_FILTERS"] = "Filter",
	["REG_LIST_FILTERS_TT"] = [=[|cffffff00Links-Klick:|r Filter anwenden
|cffffff00Rechts-Klicken:|r Filter zurücksetzen]=],
	["REG_LIST_FLAGS"] = "Flags",
	["REG_LIST_GUILD"] = "Gilde des Charakters",
	["REG_LIST_IGNORE_EMPTY"] = "Keine ignorierten Charaktere",
	["REG_LIST_IGNORE_TITLE"] = "Liste ignorierter Charaktere",
	["REG_LIST_IGNORE_TT"] = [=[Grund:
|cff00ff00%s

|cffffff00Klicken, um von der Liste zu streichen]=],
	["REG_LIST_NAME"] = "Name das Charakters",
	["REG_LIST_NOTIF_ADD"] = "Neues Profil gefunden für |cff00ff00%s",
	["REG_LIST_NOTIF_ADD_CONFIG"] = "Neues Profil gefunden",
	["REG_LIST_NOTIF_ADD_NOT"] = "Dieses Profil existiert nicht mehr.",
	["REG_LIST_PET_MASTER"] = "Name des Herren",
	["REG_LIST_PET_NAME"] = "Name des Begleiters",
	["REG_LIST_PET_TYPE"] = "Typ des Begleiters",
	["REG_LIST_PETS_EMPTY"] = "Kein/e Begleiter",
	["REG_LIST_PETS_EMPTY2"] = "Kein Begleiter passt zu deiner Auswahl",
	["REG_LIST_PETS_FILTER"] = "Begleiter: %s / %s",
	["REG_LIST_PETS_TITLE"] = "Begleiterliste",
	["REG_LIST_PETS_TOOLTIP"] = "Wurde gesehen bei",
	["REG_LIST_PETS_TOOLTIP2"] = "Wurde gesehen mit",
	["REG_LIST_REALMONLY"] = "Nur dieser Realm",
	["REG_LOCATION_DIFFERENT_WAR_MODE"] = "Anderer Kriegsmodus",
	["REG_MSP_ALERT"] = [=[|cffff0000WARNUNG

Du kannst nicht mehrere Addons nutzen, die das Mary Sue Protocol (MSP) nutzen, da das zu Fehlern führen kann!|r

Aktuell geladen: |cff00ff00%s

|cffff9900Deshalb wir der MSP Support für Total RP3 deaktiviert.|r

Wenn du TRP3 nicht als dein MSP Addon nutzen und diese Meldung nicht noch einmal sehen willst, kannst du das Mary Sue Protocol Modul in den TRP3 Einstellungen unter Modul Status deaktivieren.]=],
	["REG_NOTES_PROFILE"] = "Notizen",
	["REG_NOTES_PROFILE_TT"] = "Öffnet das Notizen Fenster für den anvisierten Charakter.",
	["REG_PLAYER"] = "Charakter",
	["REG_PLAYER_ABOUT"] = "Über",
	["REG_PLAYER_ABOUT_ADD_FRAME"] = "Fenster hinzufügen",
	["REG_PLAYER_ABOUT_EMPTY"] = "Keine Beschreibung",
	["REG_PLAYER_ABOUT_HEADER"] = "Titeltag",
	["REG_PLAYER_ABOUT_MUSIC"] = "Charaktersoundtrack",
	["REG_PLAYER_ABOUT_MUSIC_LISTEN"] = "Soundtrack abspielen",
	["REG_PLAYER_ABOUT_MUSIC_REMOVE"] = "Soundtrack abwählen",
	["REG_PLAYER_ABOUT_MUSIC_SELECT"] = "Charakter Soundtrack wählen",
	["REG_PLAYER_ABOUT_MUSIC_SELECT2"] = "Soundtrack wählen",
	["REG_PLAYER_ABOUT_MUSIC_STOP"] = "Soundtrack stoppen",
	["REG_PLAYER_ABOUT_MUSIC_THEME"] = "Charakter-Musikthema",
	["REG_PLAYER_ABOUT_NOMUSIC"] = "|cffff9900Kein Soundtrack",
	["REG_PLAYER_ABOUT_P"] = "Paragraph tag",
	["REG_PLAYER_ABOUT_REMOVE_FRAME"] = "Diese Fenster entfernen",
	["REG_PLAYER_ABOUT_SOME"] = "Irgendein Text ...",
	["REG_PLAYER_ABOUT_T1_YOURTEXT"] = "Dein Text hier",
	["REG_PLAYER_ABOUT_TAGS"] = "Formatierungstools",
	["REG_PLAYER_ABOUT_UNMUSIC"] = "|cffff9900Unbekannter Soundtrack",
	["REG_PLAYER_ABOUT_VOTE_DOWN"] = "Der Inhalt gefällt mir nicht.",
	["REG_PLAYER_ABOUT_VOTE_NO"] = [=[Kein Charakter der mit diesem Profil verbunden ist, scheint online zu sein.
Möchtest du das Profil trotzdem von Total RP 3 bewerten lassen?]=],
	["REG_PLAYER_ABOUT_VOTE_SENDING"] = "Sende deine Bewertung an %s ...",
	["REG_PLAYER_ABOUT_VOTE_SENDING_OK"] = "Deine Bewertung wurde an %s gesendet!",
	["REG_PLAYER_ABOUT_VOTE_TT"] = "Diese Bewertung ist komplett anonym und kann nur vom bewerteten Spieler eingesehen werden.",
	["REG_PLAYER_ABOUT_VOTE_TT2"] = "Du kannst nur bewerten, wenn der Charakter online ist .",
	["REG_PLAYER_ABOUT_VOTE_UP"] = "Ich mag den Inhalt",
	["REG_PLAYER_ABOUT_VOTES"] = "Statistiken",
	["REG_PLAYER_ABOUT_VOTES_R"] = [=[|cff00ff00%s Inhalt positiv bewerten
|cffff0000%s Inhalt negativ bewerten]=],
	["REG_PLAYER_ABOUTS"] = "Über %s",
	["REG_PLAYER_ADD_NEW"] = "Neues Profil erstellen",
	["REG_PLAYER_AGE"] = "Alter",
	["REG_PLAYER_AGE_TT"] = [=[Hier kannst du angeben, wie alt dein Charakter ist.

Hierfür gibt es mehrere Möglichkeiten:|c0000ff00
- Du kannst Jahre angeben,
- Oder ein Adjektiv (jung, ausgewachsen, erwachsen, steinalt, etc.).]=],
	["REG_PLAYER_ALERT_HEAVY_SMALL"] = [=[|cffff0000Dein Profil ist sehr lang.
|cffff9900Du solltest versuchen, die Länge reduzieren.]=],
	["REG_PLAYER_BIRTHPLACE"] = "Geburtsort",
	["REG_PLAYER_BIRTHPLACE_TT"] = [=[Hier kannst du den Geburtsort deines Charakters angeben. Das kann entweder ein Ort, eine Zone oder ein Kontinent sein. Es liegt ganz an dir, wie akkurat du es angeben möchtest.

|c00ffff00Du kannst den Button rechts verwenden, um ganz einfach den aktuellen Ort als deinen Geburtsort festzulegen.]=],
	["REG_PLAYER_BKG"] = "Hintergrundlayout",
	["REG_PLAYER_BKG_TT"] = "Dies repräsentiert den grafischen Hintergrund für dein Charakteristikfenster.",
	["REG_PLAYER_CARACT"] = "Charakteristiken",
	["REG_PLAYER_CHANGE_CONFIRM"] = [=[Du hast ungespeicherte Daten.
Möchtest du die Seite dennoch wechseln?
|cffff9900Alle änderungen gehen verloren.]=],
	["REG_PLAYER_CHARACTERISTICS"] = "Charakteristiken",
	["REG_PLAYER_CLASS"] = "Klasse",
	["REG_PLAYER_CLASS_TT"] = [=[Die Klasse deines Charakters.

|cff00ff00Zum Beispiel :|r
Ritter, Pyromane, Nekromant, Eliteschütze, Arkanwirker, Magd ...]=],
	["REG_PLAYER_COLOR_ALWAYS_DEFAULT_TT"] = [=[|cffffff00Linksklick:|r Wähle eine Farbe
|cffffff00Rechtsklick:|r Wähle Farbe ab]=],
	["REG_PLAYER_COLOR_CLASS"] = "Klassenfarbe",
	["REG_PLAYER_COLOR_CLASS_TT"] = [=[Dies bestimmt ebenfalls die Farbe des Charakternamens.

]=],
	["REG_PLAYER_COLOR_TT"] = [=[|cffffff00Linksklick:|r Wähle eine Farbe
|cffffff00Rechtsklick:|r Farbe abwählen]=],
	["REG_PLAYER_CURRENT"] = "Aktuelles",
	["REG_PLAYER_CURRENT_OOC"] = "Dies ist eine OOC Information.",
	["REG_PLAYER_CURRENTOOC"] = "Aktuelles (OOC)",
	["REG_COMPANIONS_SHORTDESCRIPTION"]= "Kurzbeschreibung",
	["REG_PLAYER_EDIT_MUSIC_THEME"] = "Musikthema",
	["REG_PLAYER_EYE"] = "Augenfarbe",
	["REG_PLAYER_EYE_TT"] = [=[Hier kannst du die Augenfarbe eintragen.

Bedenke bitte das, auch wenn dein Charakter ein komplett verhülltes Gesicht hat, es trotzdem sinvoll sein kann die Augenfarbe hier zu erwähnen.]=],
	["REG_PLAYER_FIRSTNAME"] = "Vorname",
	["REG_PLAYER_FIRSTNAME_TT"] = [=[Das ist der Vorname deines Charakters. Dies ist ein Freies Feld, wenn du nichts einträgst wird der Spielname (|cffffff00%s|r) deines Charakters benutzt.

Du kannst einen |c0000ff00Spitznamen|r verwenden!]=],
	["REG_PLAYER_FULLTITLE"] = "Voller Titel",
	["REG_PLAYER_FULLTITLE_TT"] = [=[Hier kannst du den Vollen Titel deines Charakter eintragen. Dies kann der komplette volle Titel deines Charakters oder weiter Titel sein.

Wie dem auch sei, versuche bitte Wiederholungen zu vermeinden falls es keine weiteren Informationen zu deinem Titel mehr gibt.]=],
	["REG_PLAYER_GLANCE"] = "Auf den ersten Blick",
	["REG_PLAYER_GLANCE_BAR_DELETED"] = "Gruppenvoreinstellung |cffff9900%s|r wurde gelöscht.",
	["REG_PLAYER_GLANCE_BAR_EMPTY"] = "Der Name einer Voreinstellung darf nicht leer sein.",
	["REG_PLAYER_GLANCE_BAR_LOAD"] = "Gruppenvoreinstellung",
	["REG_PLAYER_GLANCE_BAR_LOAD_SAVE"] = "Gruppenvoreinstellungen",
	["REG_PLAYER_GLANCE_BAR_NAME"] = [=[Bitte gibt einen Voreinstellungsnamen ein

|cff00ff00Hinweis: Wenn der Name bereits von einer anderen Voreinstellung genutzt wird, wird diese ersetzt.]=],
	["REG_PLAYER_GLANCE_BAR_SAVE"] = "Speichere diese Gruppe als Voreinstellung.",
	["REG_PLAYER_GLANCE_BAR_SAVED"] = "Gruppenvoreinstellung |cff00ff00%s|r wurde erstellt.",
	["REG_PLAYER_GLANCE_BAR_TARGET"] = "\"Auf den ersten Blick\"-Voreinstellungen",
	["REG_PLAYER_GLANCE_CONFIG"] = [=[
|cffffff00Links-Klick:|r Slot konfigurieren
|cffffff00Rechts-Klick:|r Slot aktivierung umschalten
|cffffff00Drag & drop:|r Slots neu anordnen]=],
	["REG_PLAYER_GLANCE_EDITOR"] = "Slot Editor",
	["REG_PLAYER_GLANCE_MENU_COPY"] = "Slot kopieren",
	["REG_PLAYER_GLANCE_MENU_PASTE"] = "Slot: %s einfügen",
	["REG_PLAYER_GLANCE_PRESET"] = "Voreinstellung laden",
	["REG_PLAYER_GLANCE_PRESET_ADD"] = "Die Vorlage |cff00ff00%s|r wurde erstellt.",
	["REG_PLAYER_GLANCE_PRESET_ALERT1"] = "Bitte eine Kategorie und einen Namen angeben",
	["REG_PLAYER_GLANCE_PRESET_CATEGORY"] = "Voreinstellungskategorie",
	["REG_PLAYER_GLANCE_PRESET_CREATE"] = "Vorlage erstellen",
	["REG_PLAYER_GLANCE_PRESET_GET_CAT"] = [=[%s

Bitte gib einen Kategoriennamen für diese Vorlage ein.]=],
	["REG_PLAYER_GLANCE_PRESET_NAME"] = "Voreinstellungsname",
	["REG_PLAYER_GLANCE_PRESET_REMOVE"] = "Vorlage |cff00ff00%s|r entfernt",
	["REG_PLAYER_GLANCE_PRESET_SAVE"] = "Informationen als Vorseinstellung speichern",
	["REG_PLAYER_GLANCE_PRESET_SAVE_SMALL"] = "Als Voreinstellung speichern",
	["REG_PLAYER_GLANCE_PRESET_SELECT"] = "Voreinstellung auswählen",
	["REG_PLAYER_GLANCE_TITLE"] = "Attributsname",
	["REG_PLAYER_GLANCE_UNUSED"] = "Unbenutzer Slot",
	["REG_PLAYER_GLANCE_USE"] = "Diesen Slot aktivieren",
	["REG_PLAYER_HEIGHT"] = "Größe",
	["REG_PLAYER_HEIGHT_TT"] = [=[Gibt die Größe deines Charakters an.
Hierfür gibt es mehrere Möglichkeiten:|c0000ff00
- Eine komplette Zahl: 170 cm, 1,45 m, 3 Fuß  ...
- Eine Beschreibung: großgewachsen, klein ...]=],
	["REG_PLAYER_HERE"] = "Position abfragen",
	["REG_PLAYER_HERE_HOME_PRE_TT"] = [=[Aktuelle Heimatort-Kartenkoordinaten:
|cff00ff00%s|r.]=],
	["REG_PLAYER_HERE_HOME_TT"] = [=[|cffffff00Klick|r: Verwende deine aktuellen Koordinaten als Heimatort-Position.
|cffffff00Rechtsklick|r: Entferne deine Heimatort-Position.]=],
	["REG_PLAYER_HERE_TT"] = "|cffffff00Click|r: Auf die aktuelle Position setzen",
	["REG_PLAYER_HISTORY"] = "Hintergrund",
	["REG_PLAYER_ICON"] = "Charaktericon",
	["REG_PLAYER_ICON_TT"] = "Wähle eine Grafik, die deinen Charakter symbolisiert.",
	["REG_PLAYER_IGNORE"] = "Ignoriere verlinkte Charaktere (%s)",
	["REG_PLAYER_IGNORE_WARNING"] = [=[Möchtest du diese Charaktere ignorieren?

|cffff9900%s

|rOptional kannst du einen Grund angeben. Dies ist eine persönliche Notiz und kann nur von dir eingesehen werden.]=],
	["REG_PLAYER_LASTNAME"] = "Nachname",
	["REG_PLAYER_LASTNAME_TT"] = "Dies ist der Familienname deines Charakters.",
	["REG_PLAYER_LEFTTRAIT"] = "Linkes Attribut",
	["REG_PLAYER_MISC_ADD"] = "Füge ein weiteres Feld hinzu.",
	["REG_PLAYER_MORE_INFO"] = "Zusätzliche Informationen",
	["REG_PLAYER_MSP_HOUSE"] = "Hausname",
	["REG_PLAYER_MSP_MOTTO"] = "Motto",
	["REG_PLAYER_MSP_NICK"] = "Spitzname",
	["REG_PLAYER_NAMESTITLES"] = "Namen und Titel",
	["REG_PLAYER_NO_CHAR"] = "Keine Charakterstik",
	["REG_PLAYER_NOTES"] = "Notizen",
	["REG_PLAYER_NOTES_ACCOUNT"] = "Gemeinsame Notizen",
	["REG_PLAYER_NOTES_ACCOUNT_HELP"] = "Diese privaten Notizen sind mit deinem Account verbunden und werden mit allen deinen Profile geteilt.",
	["REG_PLAYER_NOTES_PROFILE"] = "Notizen von %s",
	["REG_PLAYER_NOTES_PROFILE_HELP"] = "Diese privaten Notizen sind mit deinem aktuellen Profil verbunden und verändern sich, je nachdem welches Profil du benutzt. ",
	["REG_PLAYER_NOTES_PROFILE_NONAME"] = "Profil Notizen",
	["REG_PLAYER_PEEK"] = "Verschiedenes",
	["REG_PLAYER_PHYSICAL"] = "Aussehen",
	["REG_PLAYER_PSYCHO"] = "Persönliche Merkmale",
	["REG_PLAYER_PSYCHO_Acete"] = "Asketisch",
	["REG_PLAYER_PSYCHO_ADD"] = "Personliches Merkmal hinzufügen",
	["REG_PLAYER_PSYCHO_ATTIBUTENAME_TT"] = "Attributsname",
	["REG_PLAYER_PSYCHO_Bonvivant"] = "Lebemann",
	["REG_PLAYER_PSYCHO_CHAOTIC"] = "Chaotisch",
	["REG_PLAYER_PSYCHO_Chaste"] = "Keusch",
	["REG_PLAYER_PSYCHO_Conciliant"] = "Vorbildlich",
	["REG_PLAYER_PSYCHO_Couard"] = "Rückgratlos",
	["REG_PLAYER_PSYCHO_CREATENEW"] = "Erstelle einen Wert",
	["REG_PLAYER_PSYCHO_Cruel"] = "Brutal",
	["REG_PLAYER_PSYCHO_CUSTOM"] = "Benutzerdefinierter Wert",
	["REG_PLAYER_PSYCHO_CUSTOMCOLOR"] = "Attributsfarbe auswählen",
	["REG_PLAYER_PSYCHO_CUSTOMCOLOR_LEFT_TT"] = "Wähle eine Farbe, die das linke Merkmal benutzt. |cffffff00Klick:|r Farbe auswählen |cffffff00Rechts-Klick:|r Farbe zurücksetzen |cffffff00Shift-Klick:|r Die Standard Farbauswahl benutzen.",
	["REG_PLAYER_PSYCHO_CUSTOMCOLOR_RIGHT_TT"] = "Wähle eine Farbe, die das rechte Merkmal benutzt. |cffffff00Klick:|r Farbe auswählen |cffffff00Rechts-Klick:|r Farbe zurücksetzen |cffffff00Shift-Klick:|r Die Standard Farbauswahl benutzen.",
	["REG_PLAYER_PSYCHO_Egoiste"] = "Egoistisch",
	["REG_PLAYER_PSYCHO_Genereux"] = "Altruistisch",
	["REG_PLAYER_PSYCHO_Impulsif"] = "Impulsiv",
	["REG_PLAYER_PSYCHO_Indulgent"] = "Vergebend",
	["REG_PLAYER_PSYCHO_LEFTICON_TT"] = "Linkes Attributsicon auswählen.",
	["REG_PLAYER_PSYCHO_Loyal"] = "Rechtschaffen",
	["REG_PLAYER_PSYCHO_Luxurieux"] = "Lüstern",
	["REG_PLAYER_PSYCHO_Misericordieux"] = "Sanft",
	["REG_PLAYER_PSYCHO_MORE"] = "Punkt zu \"%s\" hinzufügen",
	["REG_PLAYER_PSYCHO_PERSONAL"] = "Persönliche Werte",
	["REG_PLAYER_PSYCHO_Pieux"] = "Abergläubisch",
	["REG_PLAYER_PSYCHO_POINT"] = "Punkt hinzufügen",
	["REG_PLAYER_PSYCHO_Pragmatique"] = "Abtrünnig",
	["REG_PLAYER_PSYCHO_Rationnel"] = "Rational",
	["REG_PLAYER_PSYCHO_Reflechi"] = "Vorsichtig",
	["REG_PLAYER_PSYCHO_Rencunier"] = "Rachsüchtig",
	["REG_PLAYER_PSYCHO_RIGHTICON_TT"] = "Rechtes Attributsicon auswählen.",
	["REG_PLAYER_PSYCHO_Sincere"] = "Ehrlich",
	["REG_PLAYER_PSYCHO_SOCIAL"] = "Soziale Werte",
	["REG_PLAYER_PSYCHO_Trompeur"] = "Unehrlich",
	["REG_PLAYER_PSYCHO_Valeureux"] = "Tapfer",
	["REG_PLAYER_RACE"] = "Rasse",
	["REG_PLAYER_RACE_TT"] = "Hier gehört die Rasse des Charakters hin. Die Rasse muss nicht der Spielrasse entsprechen. Es gibt im Warcraft-Universum genügend Kreaturen, die sich ähnlich sehen.",
	["REG_PLAYER_REGISTER"] = "Registerinformationen",
	["REG_PLAYER_RELATIONSHIP_STATUS"] = "Beziehungsstatus ",
	["REG_PLAYER_RELATIONSHIP_STATUS_DIVORCED"] = "Geschieden",
	["REG_PLAYER_RELATIONSHIP_STATUS_MARRIED"] = "Verheiratet",
	["REG_PLAYER_RELATIONSHIP_STATUS_SINGLE"] = "Ledig",
	["REG_PLAYER_RELATIONSHIP_STATUS_TAKEN"] = "Vergeben",
	["REG_PLAYER_RELATIONSHIP_STATUS_TT"] = "Zeigt den Beziehungsstatus deines Charakters. Benutze \"Nicht zeigen\" wenn diese Information geheim bleiben soll.",
	["REG_PLAYER_RELATIONSHIP_STATUS_UNKNOWN"] = "Nicht zeigen",
	["REG_PLAYER_RELATIONSHIP_STATUS_WIDOWED"] = "Verwitwet",
	["REG_PLAYER_RESIDENCE"] = "Heimat",
	["REG_PLAYER_RESIDENCE_SHOW"] = "Wohnort Koordinaten",
	["REG_PLAYER_RESIDENCE_SHOW_TT"] = [=[|cff00ff00%s

|rZum Anzeigen auf Karte klicken]=],
	["REG_PLAYER_RESIDENCE_TT"] = [=[Hier kannst du angeben, wo dein Charakter normalerweise lebt. Das kann eine genaue Adresse sein (dein Heim) oder einfach der Ort oder die Region, in der dein Charakter lebt.
Wenn dein Charakter obdachlos ist oder durch die Welt streift, dann denke daran, die Informationen anzupassen.

|c00ffff00Du kannst den rechten Button verwenden, um ganz einfach den aktuellen Ort als deinen Wohnort festzulegen.]=],
	["REG_PLAYER_RIGHTTRAIT"] = "Rechtes Attribut",
	["REG_PLAYER_SHOWMISC"] = "Zeige Sonstiges Frame",
	["REG_PLAYER_SHOWMISC_TT"] = [=[Anwählen, wenn du benutzerdefinierte Felder auf deinem Charakter anzeigen möchtest.

Wenn du die benutzerdefinierten Felder nicht angezeigt haben willst lasse das Häkchen weg und das Sonstiges Frame wird komplett deaktiviert.]=],
	["REG_PLAYER_SHOWPSYCHO"] = "Zeige Persönlichkeitsfenster",
	["REG_PLAYER_SHOWPSYCHO_TT"] = [=[Anwählen, wenn du die Persönlichkeitsbeschreibung nutzen möchtest.

Wenn du die Persönlichkeit deines Charakter auf diese Art nicht angeben möchtest, dann wähle die Option nicht aus und das Persönlichkeitsfenster wird nicht angezeigt werden.]=],
	["REG_PLAYER_STYLE_ASSIST"] = "Rollenspielassistenz",
	["REG_PLAYER_STYLE_BATTLE"] = "RP-Kampfstil",
	["REG_PLAYER_STYLE_BATTLE_1"] = "World of Warcraft PVP",
	["REG_PLAYER_STYLE_BATTLE_2"] = "TRP Würfelkampf",
	["REG_PLAYER_STYLE_BATTLE_3"] = "/würfeln Kampf",
	["REG_PLAYER_STYLE_BATTLE_4"] = "Emotekampf",
	["REG_PLAYER_STYLE_DEATH"] = "Akzeptiere Charaktertod",
	["REG_PLAYER_STYLE_EMPTY"] = "Kein Rollenspielattribut geteilt",
	["REG_PLAYER_STYLE_FREQ"] = "In-Charakter Häufigkeit",
	["REG_PLAYER_STYLE_FREQ_1"] = "Vollzeit, kein OOC",
	["REG_PLAYER_STYLE_FREQ_2"] = "Die meiste Zeit",
	["REG_PLAYER_STYLE_FREQ_3"] = "Gelegentlich",
	["REG_PLAYER_STYLE_FREQ_4"] = "Gewöhnlich",
	["REG_PLAYER_STYLE_FREQ_5"] = "Vollzeit OOC, kein RP Charakter",
	["REG_PLAYER_STYLE_GUILD"] = "Gildenmitgliedschaft",
	["REG_PLAYER_STYLE_GUILD_IC"] = "IC Mitglied",
	["REG_PLAYER_STYLE_GUILD_OOC"] = "OOC Mitglied",
	["REG_PLAYER_STYLE_HIDE"] = "Nicht anzeigen",
	["REG_PLAYER_STYLE_INJURY"] = "Akzeptiere Charakterverletzungen",
	["REG_PLAYER_STYLE_PERMI"] = "Mit Spielererlaubnis",
	["REG_PLAYER_STYLE_ROMANCE"] = "Akzeptiere Charakterromanze",
	["REG_PLAYER_STYLE_RPSTYLE"] = "Rollenspielstil",
	["REG_PLAYER_STYLE_RPSTYLE_SHORT"] = "RP Stil",
	["REG_PLAYER_STYLE_WOWXP"] = "World of Warcraft Erfahrung",
	["REG_PLAYER_TITLE"] = "Titel",
	["REG_PLAYER_TITLE_TT"] = [=[Der Titel deines Charakters ist der Titel, mit dem er angesprochen wird. Vermeide bitte lange Titel, für diesen Zweck kannst du das Feld "Kompletter Titel" verwenden.

Beispiele |c0000ff00passender Titel |r:
|c0000ff00- Graf,
- Vogt,
- Magier,
- Lord,
- etc.
|rBeispiele |cffff0000unpassender Titel|r:
|cffff0000- Graf der Nordmarschen,
- Erzmagier des Zirkels von Sturmwind,
- Diplomat der Draenei,
- etc.]=],
	["REG_PLAYER_TRP2_PIERCING"] = "Piercings",
	["REG_PLAYER_TRP2_TATTOO"] = "Tattoos",
	["REG_PLAYER_TRP2_TRAITS"] = "Aussehen",
	["REG_PLAYER_TUTO_ABOUT_COMMON"] = [=[|cff00ff00Charaktersoundtrack:|r
Du kannst einen |cffffff00Soundtrack|r für deinen Charakter aussuchen. Stell es dir als |cffffff00Hintergundmusik beim Lesen deiner Charakterbeschreibung vor|r.

|cff00ff00Hintergund:|r
Dies ist eine |cffffff00Hintergrundtextur|r für deine Charakterbeschreibung.

|cff00ff00Template:|r
Das gewählte Template gibt Auskunft über |cffffff00das generelle Aussehen und die Schriftmöglichkeiten|r deiner Beschreibung.
|cffff9900Nur das ausgewählte Template ist für andere sichtbar. Du musst also nicht alle ausfüllen.|r
Sobald ein Template ausgewählt ist, kannst du das Tutorial nochmals öffnen, um dir Hilfe zu jedem Template anzeigen zu lassen.]=],
	["REG_PLAYER_TUTO_ABOUT_MISC_1"] = [=[Dieser Teil stellt dir|cffffff005 Slots|r zur Verfügung, in denen du die |cff00ff00wichtigsten Informationen zu deinem Charakter|r beschreiben kannst.

Die Slots sind in |cffffff00"Auf den ersten Blick"|r ersichtlich wenn jemand deinen Charakter anwählt.

|cff00ff00Hinweis: Du kannst die Slots per Drag&Drop neu anordnen.|r
Das funktioniert auch in der Sektion |cffffff00"Auf den ersten Blick"|r!]=],
	["REG_PLAYER_TUTO_ABOUT_MISC_3"] = "Dieser Teil enthält |cffffff00eine Liste von Informationen|r, die eine Menge |cffffff00einfache Fragen zu der Art, wie du deinen Charakter spielst, beantwortet|r.",
	["REG_PLAYER_TUTO_ABOUT_T1"] = [=[Dieses Template erlaubt dir deine |cff00ff00Beschreibung frei zu gestalten|r.

Die Beschreibung muss nicht auf die |cffff9900physische Beschreibung|r deines Charakters beschränkt sein. Gibt ruhig Teile seines |cffff9900Hintergrundes|r oder Details zu seiner |cffff9900Persönlichkeit|r an.

Mit diesem Template hast du Zugriff auf die Formatierungstools, um beispielsweise |cffffff00Schriftgröße, Farben und Ausrichtung|r zu beeinflussen.
Diese Tools erlauben auch das Einfügen von |cffffff00Bildern, Icons oder Links zu externen Internetseiten|r.]=],
	["REG_PLAYER_TUTO_ABOUT_T2"] = [=[Dieses Template ist ein wenig strukturierter und besteht aus |cff00ff00einer Reihe unabhängiger Fenster|r.

Jedes Fenster wird von einem eigenen |cffffff00Icon, einem Hintergrund und eineem Text|r repräsentiert. Beachte das du hier Texttags in diesen Fenstern nutzen kannst, genauso kannst du auch Farb- oder Icon-Tags verwenden.

Die Beschreibung muss nicht auf die |cffff9900physische Beschreibung|r deines Charakters beschränkt sein. Gibt ruhig Teile seines |cffff9900Hintergrundes|r oder Details zu seiner |cffff9900Persönlichkeit|r an.]=],
	["REG_PLAYER_TUTO_ABOUT_T3"] = [=[Dieses Template ist in 3 Teile unterteilt: |cff00ff00Die Physische Beschreibung, Persönlichkeit und Hintergrundgeschichte|r.

Du musst nicht alle Fenster ausfüllen, |cffff9900wenn du eines frei läßt wird es in deiner Beschreibung einfach nicht angezeigt|r.

Jedes Fenster wird von einem eigenen |cffffff00Icon, einem Hintergrund und einem Text|r repräsentiert. Beachte das du hier Texttags in diesen Fenstern nutzen kannst, genauso kannst du auch Farb- oder Icon-Tags verwenden.]=],
	["REG_PLAYER_WEIGHT"] = "Körperform",
	["REG_PLAYER_WEIGHT_TT"] = [=[Dies ist die Körperform deines Charakters.
Zum Beispiel kann du folgendes angeben: |c0000ff00schlank, dick or muskulös...|r oder einfach durchschnittlich!]=],
	["REG_PLAYERS"] = "Spieler",
	["REG_REGISTER"] = "Register",
	["REG_REGISTER_CHAR_LIST"] = "Charakterliste",
	["REG_RELATION"] = "Beziehung",
	["REG_RELATION_BUSINESS"] = "Geschäftlich",
	["REG_RELATION_BUSINESS_TT"] = "%s und %s haben eine Geschäftsbeziehung.",
	["REG_RELATION_BUTTON_TT"] = [=[Beziehung: %s
|cff00ff00%s

|cffffff00Klicke, um mögliche Aktionen zu wählen]=],
	["REG_RELATION_FAMILY"] = "Familie",
	["REG_RELATION_FAMILY_TT"] = "%s hat Blutsbande mit %s.",
	["REG_RELATION_FRIEND"] = "Freundlich",
	["REG_RELATION_FRIEND_TT"] = "%s nennt %s einen Freund.",
	["REG_RELATION_LOVE"] = "Liebe",
	["REG_RELATION_LOVE_TT"] = "%s ist in %s verliebt!",
	["REG_RELATION_NEUTRAL"] = "Neutral",
	["REG_RELATION_NEUTRAL_TT"] = "%s hat keine spezielle Beziehung zu %s.",
	["REG_RELATION_NONE"] = "Keine",
	["REG_RELATION_NONE_TT"] = "%s kennt %s nicht.",
	["REG_RELATION_TARGET"] = "|cffffff00Klick: |rBeziehung ändern",
	["REG_RELATION_UNFRIENDLY"] = "Unfreundlich",
	["REG_RELATION_UNFRIENDLY_TT"] = "%s mag %s offensichtlich nicht.",
	["REG_REPORT_PLAYER_OPEN_URL"] = "Du kannst Spieler nur direkt im Spiel melden, wenn du sie anvisieren kannst (benutze dafür den Button im TRP3 Ankerfenster) Wenn du %s's Profil melden möchtest, aber nicht anvisieren kannst, musst du ein normales Kundendienstticket bei Blizzard über den folgenden Link öffnen.",
	["REG_REPORT_PLAYER_OPEN_URL_160"] = "Wenn du %s's Profil melden möchtest, musst du ein normales Kundendienstticket bei Blizzard über den folgenden Link öffnen.",
	["REG_REPORT_PLAYER_PROFILE"] = "Profil an |cff449fe0Blizzard|r melden.",
	["REG_REPORT_PLAYER_PROFILE_TT"] = "Du kannst ein Profil melden, welches die Nutzungsbedingungen von Blizzard verletzt. Dies können Belästigungen, Hasssprache, anstößige Inhalte, der Missbrauch persönlicher Daten oder andere Formen von störenden Inhalten sein.  |cffff0000Bitte beachte, dass diese Option NICHT dafür gedacht ist Profile von subjektiv schlechter Qualität oder Griefing zu melden.",
	["REG_REPORT_PLAYER_TEMPLATE"] = "Dieser Spieler benutzt das RP Profil Addon %s um Inhalte zu verbreiten, die die Nutzungsbedingungen verletzen.. ",
	["REG_REPORT_PLAYER_TEMPLATE_DATE"] = "Die Addon Daten wurden am %s über aufgezeichnete Addon Nachrichten übermittelt. ",
	["REG_REPORT_PLAYER_TEMPLATE_TRIAL_ACCOUNT"] = "Dieser Spieler benutze einen Starter Edition Account.",
	["REG_TIME"] = "Zuletzt gesehen",
	["REG_TRIAL_ACCOUNT"] = "Probeaccount",
	["REG_TT_GUILD"] = "%s von |cffff9900%s",
	["REG_TT_GUILD_IC"] = "IC Mitglied",
	["REG_TT_GUILD_OOC"] = "OOC Mitglied",
	["REG_TT_IGNORED"] = "< Charakter ist ignoriert >",
	["REG_TT_IGNORED_OWNER"] = "< Besitzer ist ignoriert >",
	["REG_TT_LEVEL"] = "Level %s %s",
	["REG_TT_NOTIF"] = "Ungelesene Beschreibung",
	["REG_TT_REALM"] = "Realm: |cffff9900%s",
	["REG_TT_TARGET"] = "Ziel: |cffff9900%s",
	["SCRIPT_ERROR"] = "Fehler im Script.",
	["SCRIPT_UNKNOWN_EFFECT"] = "Scriptfehler, unbekannte FX",
	["SLASH_CMD_STATUS_HELP"] = "Benutzung: |cff00ff00/trp3 status ic || ooc || toggle|r Wechselt deinen Charakter Status zu der entsprechenden Option: |cffff9900/trp3 status ic|r setzt deinen Status auf |cff00ff00in character|r. |cffff9900/trp3 status ooc|r setzt deinen Status auf  |cffff0000out of character|r. |cffff9900/trp3 status toggle|r wechselt deinen Status von ic zu ooc und vice versa.",
	["SLASH_CMD_STATUS_USAGE"] = "ic || ooc || toggle",
	["TB_AFK_MODE"] = "AFK",
	["TB_DND_MODE"] = "Nicht stören (DnD)",
	["TB_GO_TO_MODE"] = "Zu %s Modus wechseln",
	["TB_LANGUAGE"] = "Sprache",
	["TB_LANGUAGES_TT"] = "Sprache wechseln",
	["TB_NORMAL_MODE"] = "Normal",
	["TB_RPSTATUS_OFF"] = "Charakter: |cffff0000Out of Character (OOC) ",
	["TB_RPSTATUS_ON"] = "Charakter: |cff00ff00In Character (IC) ",
	["TB_RPSTATUS_TO_OFF"] = "Zu |cffff0000Out of Character|r wechseln.",
	["TB_RPSTATUS_TO_ON"] = "Zu |cff00ff00In Character|r wechseln.",
	["TB_STATUS"] = "Spieler",
	["TB_SWITCH_CAPE_1"] = "Zeige Umhang",
	["TB_SWITCH_CAPE_2"] = "Verstecke Umhang",
	["TB_SWITCH_CAPE_OFF"] = "Umhang: |cffff0000Versteckt",
	["TB_SWITCH_CAPE_ON"] = "Umhang: |cff00ff00Angezeigt",
	["TB_SWITCH_HELM_1"] = "Zeige Helm",
	["TB_SWITCH_HELM_2"] = "Verstecke Helm",
	["TB_SWITCH_HELM_OFF"] = "Helm: |cffff0000Versteckt",
	["TB_SWITCH_HELM_ON"] = "Helm: |cff00ff00Angezeigt",
	["TB_SWITCH_PROFILE"] = "Zu einem anderen Profil wechseln",
	["TB_SWITCH_TOOLBAR"] = "Toolbar umschalten",
	["TB_TOOLBAR"] = "Toolbar",
	["TF_IGNORE"] = "Spieler ignorieren",
	["TF_IGNORE_CONFIRM"] = [=[Bist du sicher das du die folgende ID ignorieren willst?

|cffffff00%s|r 

|cffff7700Du kannst optional angeben, warum die diesen Spieler ignorierst. Dies ist eine persönliche Notiz und kann nicht von anderen Spielern eingesehen werden.]=],
	["TF_IGNORE_NO_REASON"] = "Kein Grund",
	["TF_IGNORE_TT"] = "|cffffff00Klicken:|r Spieler ignorieren",
	["TF_OPEN_CHARACTER"] = "Charakterseite anzeigen",
	["TF_OPEN_COMPANION"] = "Begleiterseite anzeigen",
	["TF_OPEN_MOUNT"] = "Reittierseite anzeigen",
	["TF_PLAY_THEME"] = "Charaktersoundtrack abspielen",
	["TF_PLAY_THEME_TT"] = [=[|cffffff00Linksklick:|r Abspielen |cff00ff00%s
|cffffff00Rechtsklick:|r Anhalten]=],
	["THANK_YOU_1"] = [=[{h1:c}Total RP 3{/h1}
{p:c}{col:6eff51}Version %s (build %s){/col}{/p}
{p:c}{link*http://totalrp3.info*TotalRP3.info}{/p}

{h2}{icon:INV_Eng_gizmo1:20} Created by{/h2}
- Morgane "{twitter*EllypseCelwe*Ellypse}" Parize
- Sylvain "{twitter*Telkostrasz*Telkostrasz}" Cossement


{h2}{icon:THUMBUP:20} Danksagungen{/h2}
{col:ffffff}Logo and minimap button icon:{/col}
- {link*https://twitter.com/Kelandiir*@Kelandiir}

{col:ffffff}Unser Pre-Alpha QA Team:{/col}
- Saelora
- Erzan
- Calian
- Kharess
- Alnih
- 611

{col:ffffff}Danke an alle unsere Freunde für Ihre Unterstützung in all diesen Jahren:{/col}
- Für Telkos: Kharess, Kathryl, Marud, Solona, Stretcher, Lisma...
- Für Ellypse: The guilds Maison Celwë'Belore, Mercenaires Atal'ai, und ganz besonders Erzan, Elenna, Caleb, Siana and Adaeria

{col:ffffff}Danke für die Hilfe die "Total RP Gilde" auf Kirin Tor (EU) zu erstellen:{/col}
- Azane
- Hellclaw
- Leylou

{col:ffffff}Danke an Horionne für das zusend einer Ausgabe von dem Magazin "Gamer Culte Online #14" mit einem Artikel über Total RP.{/col}]=],
	["THANK_YOU_ROLE_AUTHOR"] = "Autor",
	["THANK_YOU_ROLE_COMMUNITY_MANAGER"] = "Community Manager",
	["THANK_YOU_ROLE_CONTRIBUTOR"] = "Mitwirkende(r)",
	["THANK_YOU_ROLE_GUILD_MEMBER"] = "Gildenmitglied",
	["THANK_YOU_ROLE_TESTER"] = "Qualitätssicherung",
	["TT_ELVUI_SKIN"] = "ElvUI Skin",
	["TT_ELVUI_SKIN_ENABLE_TARGET_FRAME"] = "Skin Zielfenster",
	["TT_ELVUI_SKIN_ENABLE_TOOLTIPS"] = "Skin Tooltips",
	["UI_BKG"] = "Hintergrund %s",
	["UI_CLOSE_ALL"] = "Alle schließen",
	["UI_COLOR_BROWSER"] = "Farbwähler",
	["UI_COLOR_BROWSER_PRESETS"] = "Voreinstellungen",
	["UI_COLOR_BROWSER_PRESETS_BASIC"] = "Basis",
	["UI_COLOR_BROWSER_PRESETS_CLASSES"] = "Klasse",
	["UI_COLOR_BROWSER_PRESETS_CUSTOM"] = "Eigene",
	["UI_COLOR_BROWSER_PRESETS_ITEMS"] = "Gegenstandsqualität",
	["UI_COLOR_BROWSER_PRESETS_RESOURCES"] = "Ressource",
	["UI_COLOR_BROWSER_SELECT"] = "Farbe auswählen",
	["UI_COMPANION_BROWSER_HELP"] = "Wähle ein Wildtier",
	["UI_COMPANION_BROWSER_HELP_TT"] = [=[|cffffff00Warnung: |rNur umbenannte Wildtiere dürfen mit einem Profil verbunden werden.

|cff00ff00Dieser Bereich enthält nur diese Wildtiere.]=],
	["UI_FILTER"] = "Filter",
	["UI_ICON_BROWSER"] = "Iconbrowser",
	["UI_ICON_BROWSER_HELP"] = "Icon kopieren",
	["UI_ICON_BROWSER_HELP_TT"] = [=[Während dieses Fenter geöffnet ist, kannst du mit |cffffff00ctrl + Klick|r auf ein Icon anwenden, um dessen Namen zu kopieren.

Das funktioniert:|cff00ff00
- Mit jedem Item in deinem Inventar
- Mit jeder Fähigkeit in deinem Zauberbuch|r]=],
	["UI_ICON_SELECT"] = "Icon auswählen",
	["UI_IMAGE_BROWSER"] = "Bildbrowser",
	["UI_IMAGE_SELECT"] = "Bild auswählen",
	["UI_LINK_SAFE"] = "Das ist die Link-URL.",
	["UI_LINK_TEXT"] = "Dein Text",
	["UI_LINK_URL"] = "http://deine.url.hier.de",
	["UI_LINK_WARNING"] = [=[Hier ist die Link URL.
Du kannst sie per Copy/Paste in deinen Browser kopieren.

|cffff0000!! Disclaimer !!|r
Total RP ist NICHT für Links verantwortlich, die auf schädlichen oder illegalen Inhalt verweisen!]=],
	["UI_MUSIC_ALTTITLE"] = "Alternativer Titel",
	["UI_MUSIC_BROWSER"] = "Musikbrowser",
	["UI_MUSIC_DURATION"] = "Dauer",
	["UI_MUSIC_SELECT"] = "Musik auswählen",
	["UI_TUTO_BUTTON"] = "Tutorialmodus",
	["UI_TUTO_BUTTON_TT"] = "Klicke, um den Tutorialmodus ein/aus zu schalten"
}

TRP3_API.loc:RegisterNewLocale("deDE", "Deutsch", localeContent);

localeContent = {
	["ABOUT_TITLE"] = "À propos",
	["BINDING_NAME_TRP3_OPEN_TARGET_PROFILE"] = "Ouvrir le profil de la cible",
	["BINDING_NAME_TRP3_TOGGLE"] = "Afficher/cacher la fenêtre principale",
	["BINDING_NAME_TRP3_TOGGLE_CHARACTER_STATUS"] = "Changer le statut RP",
	["BINDING_NAME_TRP3_TOOLBAR_TOGGLE"] = "Afficher/cacher la barre d'outils",
	["BLIZZARD_NAMEPLATES_MODULE_DESCRIPTION"] = "Active la personnalisation des barres d'info Blizzard.",
	["BLIZZARD_NAMEPLATES_MODULE_NAME"] = "Barres d'info Blizzard",
	["BROADCAST_10"] = "|cffff9900Vous avez déjà rejoint 10 canaux de discussion. Total RP 3 n'essaiera plus de se connecter au canal de diffusion mais vous ne serez pas en mesure d'utiliser certaines fonctionnalités, comme l'emplacement des autres utilisateurs sur la carte.",
	["BROADCAST_OFFLINE_DISABLED"] = "Le canal d'échanges a été désactivé.",
	["BROADCAST_PASSWORD"] = [=[|cffff0000Un mot de passe a été défini pour le canal de diffusion (%s).
|cffff9900Total RP 3 n'essaiera plus de se connecter mais vous ne serez pas en mesure d'utiliser certaines fonctionnalités, comme l'emplacement des autres utilisateurs sur la carte.
|cff00ff00Vous pouvez désactiver ou modifier le canal de diffusion dans les réglages de Total RP 3.]=],
	["BROADCAST_PASSWORDED"] = [=[|cffff0000L'utilisateur |r%s|cffff0000 vient de mettre un mot de passe sur le canal de diffusion (%s).
|cffff9900Si vous ne connaissez pas ce mot de passe vous ne serez pas en mesure d'utiliser certaines fonctionnalités, comme l'emplacement des autres utilisateurs sur la carte.
]=],
	["BW_COLOR_CODE"] = "Code couleur",
	["BW_COLOR_CODE_ALERT"] = "Mauvais code hexadécimal !",
	["BW_COLOR_CODE_TT"] = "Vous pouvez coller ici un code couleur hexadécimal à 6 caractères et appuyer sur Entrée pour valider.",
	["BW_COLOR_PRESET_DELETE"] = "Supprimer la couleur %s",
	["BW_COLOR_PRESET_RENAME"] = "Renommer la couleur %s",
	["BW_COLOR_PRESET_SAVE"] = "Enregistrer cette couleur",
	["BW_COLOR_PRESET_TITLE"] = "Couleurs enregistrées",
	["BW_CUSTOM_NAME"] = "Nom personnalisé",
	["BW_CUSTOM_NAME_TITLE"] = "Nom (optionnel)",
	["BW_CUSTOM_NAME_TT"] = "Vous pouvez indiquer un nom pour la couleur personnalisée que vous souhaitez enregistrer. Si le champ est laissé vide, le nom sera le code hexadécimal de la couleur.",
	["CL_COMPANION_PROFILE"] = "Profil de companion",
	["CL_CONTENT_SIZE"] = "Taille: %s",
	["CL_DIRECTORY_COMPANION_PROFILE"] = "Profil du registre de compagnons",
	["CL_DIRECTORY_PLAYER_PROFILE"] = "Profil du registre de personnages",
	["CL_DOWNLOADING"] = "Téléchargement: %0.1f %%",
	["CL_EXPIRED"] = "Ce lien a expiré.",
	["CL_GLANCE"] = "Coup d'œil",
	["CL_IMPORT_COMPANION"] = "Importer le profil de companion",
	["CL_IMPORT_GLANCE"] = "Importer le coup d'œil",
	["CL_IMPORT_PROFILE"] = "Importer le profil",
	["CL_MAKE_IMPORTABLE"] = [=[Vous êtes sur le point de créer un lien de %s.

Souhaitez vous rendre ce lien importable pour les autres joueurs ? Ils seront capable de copier et utiliser le contenu du lien envoyé.

Si vous choisissez non, ils pourront uniquement consulter le contenu du lien.]=],
	["CL_MAKE_IMPORTABLE_BUTTON_TEXT"] = "Lien importable",
	["CL_MAKE_IMPORTABLE_SIMPLER"] = [=[Faire un lien %s importable?

Les joueurs pourront copier et utiliser le contenu du lien.]=],
	["CL_MAKE_NON_IMPORTABLE"] = "Consultable uniquement",
	["CL_OPEN_COMPANION"] = "Ouvrir le profil de companion",
	["CL_OPEN_PROFILE"] = "Ouvrir le profil",
	["CL_PLAYER_PROFILE"] = "Profil de joueur",
	["CL_REQUESTING_DATA"] = "En train de récupérer les informations du lien de %s.",
	["CL_SENDING_COMMAND"] = "Envoi de la commande…",
	["CL_SENT_BY"] = "Lien envoyé par: %s",
	["CL_TOOLTIP"] = "Crée un lien de discussion",
	["CL_TYPE"] = "Type du lien TRP3: %s",
	["CL_VERSIONS_DIFFER"] = [=[Ce lien a été généré avec une autre version de Total RP 3.

Importer du contenu créé avec une version différente peut poser des soucis en cas d'incompatibilité entre les deux versions. Souhaitez-vous tout de même continuer ?]=],
	["CM_ACTIONS"] = "Actions",
	["CM_ALT"] = "Alt",
	["CM_APPLY"] = "Appliquer",
	["CM_BLACK"] = "Noir",
	["CM_BLUE"] = "Bleu",
	["CM_CANCEL"] = "Annuler",
	["CM_CENTER"] = "Centre",
	["CM_CLASS_DEATHKNIGHT"] = "Chevalier de la mort",
	["CM_CLASS_DEMONHUNTER"] = "Chasseur de démons",
	["CM_CLASS_DRUID"] = "Druide",
	["CM_CLASS_HUNTER"] = "Chasseur",
	["CM_CLASS_MAGE"] = "Mage",
	["CM_CLASS_MONK"] = "Moine",
	["CM_CLASS_PALADIN"] = "Paladin",
	["CM_CLASS_PRIEST"] = "Prêtre",
	["CM_CLASS_ROGUE"] = "Voleur",
	["CM_CLASS_SHAMAN"] = "Chaman",
	["CM_CLASS_UNKNOWN"] = "Inconnu",
	["CM_CLASS_WARLOCK"] = "Démoniste",
	["CM_CLASS_WARRIOR"] = "Guerrier",
	["CM_CLICK"] = "Clic",
	["CM_COLOR"] = "Couleur",
	["CM_CTRL"] = "Ctrl",
	["CM_CYAN"] = "Cyan",
	["CM_DELETE"] = "Supprimer",
	["CM_DOUBLECLICK"] = "Double-clic",
	["CM_DRAGDROP"] = "Glisser-déposer",
	["CM_EDIT"] = "Modifier",
	["CM_GREEN"] = "Vert",
	["CM_GREY"] = "Gris",
	["CM_IC"] = "RP",
	["CM_ICON"] = "Icône",
	["CM_IMAGE"] = "Image",
	["CM_L_CLICK"] = "Clic-gauche",
	["CM_LEFT"] = "Gauche",
	["CM_LINK"] = "Lien",
	["CM_LOAD"] = "Charger",
	["CM_M_CLICK"] = "Clic-milieu",
	["CM_MOVE_DOWN"] = "Déplacer vers le bas",
	["CM_MOVE_UP"] = "Déplacer vers le haut",
	["CM_NAME"] = "Nom",
	["CM_OOC"] = "HRP",
	["CM_OPEN"] = "Ouvrir",
	["CM_ORANGE"] = "Orange",
	["CM_PINK"] = "Rose",
	["CM_PLAY"] = "Jouer",
	["CM_PURPLE"] = "Violet",
	["CM_R_CLICK"] = "Clic-droit",
	["CM_RED"] = "Rouge",
	["CM_REMOVE"] = "Supprimer",
	["CM_RESET"] = "Réinitialiser",
	["CM_RESIZE"] = "Redimensionner",
	["CM_RESIZE_TT"] = "Tirer pour redimensionner la fenêtre",
	["CM_RIGHT"] = "Droite",
	["CM_SAVE"] = "Sauver",
	["CM_SELECT"] = "Choisir",
	["CM_SHIFT"] = "Maj",
	["CM_SHOW"] = "Afficher",
	["CM_STOP"] = "Arrêter",
	["CM_TWEET"] = "Envoyer un tweet",
	["CM_TWEET_PROFILE"] = "Afficher l'url du profil",
	["CM_UNKNOWN"] = "Inconnu",
	["CM_VALUE"] = "Valeur",
	["CM_WHITE"] = "Blanc",
	["CM_YELLOW"] = "Jaune",
	["CO_ADVANCED_BROADCAST"] = "Communications d'addon",
	["CO_ADVANCED_BROADCAST_CHANNEL_ALWAYS_LAST"] = "Garder le canal de diffusion en dernier",
	["CO_ADVANCED_BROADCAST_CHANNEL_ALWAYS_LAST_TT"] = "Cette option s'assure que le canal de diffusion soit toujours en dernier dans la liste des canaux de discussion.",
	["CO_ADVANCED_LANGUAGE_WORKAROUND"] = "Activer la correction du bug des langages",
	["CO_ADVANCED_LANGUAGE_WORKAROUND_TT"] = "Depuis le patch 8.0.1, le jeu réinitialise automatiquement la langue parlée pour utiliser celle par défaut après chaque écran de chargement. Cette correction s'assure que la langue précédemment sélectionnée est correctement ré-appliquée après un écran de chargement.",
	["CO_ADVANCED_LANGUAGES"] = "Langages",
	["CO_ADVANCED_LANGUAGES_REMEMBER"] = "Retenir le dernier langage utilisé",
	["CO_ADVANCED_LANGUAGES_REMEMBER_TT"] = "Total RP 3 se rappellera automatiquement du langage que vous avez utilisé avant de vous déconnecter et sélectionnera automatiquement ce langage à votre prochaine connexion.",
	["CO_ADVANCED_SETTINGS"] = "Paramètres avancés",
	["CO_ADVANCED_SETTINGS_MENU_NAME"] = "Avancé",
	["CO_ADVANCED_SETTINGS_POPUP"] = [=[Vous venez de modifier un paramètre avancé.

Gardez à l'esprit que changer ces paramètres peut altérer votre expérience avec l'addon et perturber l'exécution de certaines fonctions. Utilisez à votre propre risque.]=],
	["CO_ADVANCED_SETTINGS_RESET"] = "Réinitialiser les paramètres avancés",
	["CO_ADVANCED_SETTINGS_RESET_TT"] = "Réinitialise tous les paramètres avancés à leur valeur par défaut. Utilisez ceci si vous avez des problèmes après avoir modifié ces paramètres.",
	["CO_ANCHOR_BOTTOM"] = "Bas",
	["CO_ANCHOR_BOTTOM_LEFT"] = "Bas-gauche",
	["CO_ANCHOR_BOTTOM_RIGHT"] = "Bas-droite",
	["CO_ANCHOR_CURSOR"] = "Afficher sur le curseur",
	["CO_ANCHOR_LEFT"] = "Gauche",
	["CO_ANCHOR_RIGHT"] = "Droite",
	["CO_ANCHOR_TOP"] = "Haut",
	["CO_ANCHOR_TOP_LEFT"] = "Haut-gauche",
	["CO_ANCHOR_TOP_RIGHT"] = "Haut-droite",
	["CO_CHAT"] = "Discussions",
	["CO_CHAT_DISABLE_OOC"] = "Désactiver les modifications quand HRP",
	["CO_CHAT_DISABLE_OOC_TT"] = "Désactiver toutes les modifications de discussions de Total RP 3 (noms personnalisés, détection des émotes, dialogues de PNJ, etc.) quand votre personnage est défini comme étant en Hors RolePlay.",
	["CO_CHAT_INCREASE_CONTRAST"] = "Améliorer le contraste des couleurs",
	["CO_CHAT_INSERT_FULL_RP_NAME"] = "Insérer le nom RP avec MAJ-Clic",
	["CO_CHAT_INSERT_FULL_RP_NAME_TT"] = [=[Insérer le nom roleplay complet du joueur en MAJ-cliquant son nom dans la fenêtre de discussion.

(Quand cette option est activée, vous pouvez ALT-MAJ-Cliquer pour insérer le nom normal au lieu de la version RP.)]=],
	["CO_CHAT_MAIN"] = "Paramètres principaux de discussions",
	["CO_CHAT_MAIN_COLOR"] = "Utiliser les couleurs personnalisées pour les noms",
	["CO_CHAT_MAIN_EMOTE"] = "Détection des émotes",
	["CO_CHAT_MAIN_EMOTE_PATTERN"] = "Schéma de détection des émotes",
	["CO_CHAT_MAIN_EMOTE_USE"] = "Utiliser la détection des émotes",
	["CO_CHAT_MAIN_EMOTE_YELL"] = "Pas d'émotes criées",
	["CO_CHAT_MAIN_EMOTE_YELL_TT"] = "Ne pas afficher *emote* ou <emote> en /crier.",
	["CO_CHAT_MAIN_NAMING"] = "Méthode d'affichage des noms",
	["CO_CHAT_MAIN_NAMING_1"] = "Garder le nom original",
	["CO_CHAT_MAIN_NAMING_2"] = "Utiliser les noms personnalisés",
	["CO_CHAT_MAIN_NAMING_3"] = "Prénom + nom",
	["CO_CHAT_MAIN_NAMING_4"] = "Titre court + prénom + nom",
	["CO_CHAT_MAIN_NPC"] = "Détection des dialogues de PNJ",
	["CO_CHAT_MAIN_NPC_PREFIX"] = "Schéma de détection des dialogues de PNJ",
	["CO_CHAT_MAIN_NPC_PREFIX_TT"] = [=[Si un message envoyé sur le canal /emote commence par ce préfixe, il sera interprété comme dialogue de PNJ.

|cff00ff00Par défaut : "|| "
(sans les " et avec un espace après le | )]=],
	["CO_CHAT_MAIN_NPC_USE"] = "Utiliser la détection des dialogues de PNJ",
	["CO_CHAT_MAIN_OOC"] = "Détection du HRP",
	["CO_CHAT_MAIN_OOC_COLOR"] = "Couleur du HRP",
	["CO_CHAT_MAIN_OOC_PATTERN"] = "Schéma de détection du HRP",
	["CO_CHAT_MAIN_OOC_USE"] = "Utiliser la détection du HRP",
	["CO_CHAT_MAIN_SPEECH"] = "Détection de dialogue",
	["CO_CHAT_MAIN_SPEECH_USE"] = "Activer la détection de dialogue",
	["CO_CHAT_MAIN_SPEECH_USE_TT"] = "Les textes entourés de guillemets seront colorés comme s'ils étaient écrits en /dire.",
	["CO_CHAT_NPCSPEECH_REPLACEMENT"] = "Noms de companion dans les textes de PNJ",
	["CO_CHAT_NPCSPEECH_REPLACEMENT_TT"] = "Si un nom de companion est indiqué entre crochet dans un texte de PNJ, il sera formatté suivant les réglages de discussion (coloré, avec une icône, etc.).",
	["CO_CHAT_REMOVE_REALM"] = "Retirer le royaume du nom des joueurs",
	["CO_CHAT_SHOW_OOC"] = "Afficher indicateur HRP",
	["CO_CHAT_USE"] = "Canaux de discussion utilisés",
	["CO_CHAT_USE_ICONS"] = "Afficher les icônes",
	["CO_CHAT_USE_SAY"] = "Canal /dire",
	["CO_CONFIGURATION"] = "Paramètres",
	["CO_CURSOR_DISABLE_OOC"] = "Désactiver quand HRP",
	["CO_CURSOR_DISABLE_OOC_TT"] = "Désactiver les modifications du curseur quand votre status roleplay est |cffccccccHors RolePlay|r.",
	["CO_CURSOR_MODIFIER_KEY"] = "Touche de modification",
	["CO_CURSOR_MODIFIER_KEY_TT"] = "Necessite d'avoir la touche enfoncé au moment du clic-droit sur un joueur, pour éviter les clics accidentels.",
	["CO_CURSOR_RIGHT_CLICK"] = "Clic-droit pour ouvrir le profil",
	["CO_CURSOR_RIGHT_CLICK_TT"] = [=[Cliquez-droit sur un joueur dans le monde pour ouvrir leur profil s'ils en ont un.

|TInterface\Cursor\WorkOrders:25|t Cette icône sera attachée au curseur lorsqu'un joueur a un profil et que vous pouvez cliquer-droit dessus.

|cffccccccNote: Cette fonctionnalité est toujours désactivée durant un combat.|r]=],
	["CO_CURSOR_TITLE"] = "Interactions avec le curseur",
	["CO_GENERAL"] = "Général",
	["CO_GENERAL_BROADCAST"] = "Utiliser le canal de diffusion",
	["CO_GENERAL_BROADCAST_C"] = "Nom du canal de diffusion",
	["CO_GENERAL_BROADCAST_TT"] = "Le canal de diffusion est utilisé pour de nombreuses fonctionnalités. Le désactiver désactivera également les fonctionnalités comme l'emplacement sur la carte, les sons diffusés localement, l'accès aux planques et aux panneaux, etc.",
	["CO_GENERAL_CHANGELOCALE_ALERT"] = [=[Changer la langue pour %s ?
Cela provoquera un rechargement de l'interface.]=],
	["CO_GENERAL_COM"] = "Communication",
	["CO_GENERAL_DEFAULT_COLOR_PICKER"] = "Selecteur de couleur par défaut",
	["CO_GENERAL_DEFAULT_COLOR_PICKER_TT"] = "Activez cette option pour toujours utiliser le sélecteur de couleur par défaut du jeu. Utile si vous utilisez un add-on qui va remplacer le sélecteur par défaut.",
	["CO_GENERAL_HEAVY"] = "Alerte de profil lourd",
	["CO_GENERAL_HEAVY_TT"] = "Afficher une alerte lorsque la taille du profil dépasse une valeur raisonnable",
	["CO_GENERAL_LOCALE"] = "Langue de l'add-on",
	["CO_GENERAL_MISC"] = "Divers",
	["CO_GENERAL_NEW_VERSION"] = "Alerte de mise-à-jour",
	["CO_GENERAL_NEW_VERSION_TT"] = "Afficher une alerte lorsqu'une nouvelle version est disponible.",
	["CO_GENERAL_RESET_CUSTOM_COLORS"] = "Réinitialiser les couleurs personnalisées",
	["CO_GENERAL_RESET_CUSTOM_COLORS_TT"] = "Supprimer toutes les couleurs personnalisées enregistrées dans le sélecteur de couleur.",
	["CO_GENERAL_RESET_CUSTOM_COLORS_WARNING"] = "Êtes-vous certain de vouloir supprimer toutes les couleurs personnalisées sauvegardées dans le sélecteur de couleur ?",
	["CO_GENERAL_TT_SIZE"] = "Taille du texte de l'infobulle",
	["CO_GENERAL_UI_ANIMATIONS"] = "Animations d'interface",
	["CO_GENERAL_UI_ANIMATIONS_TT"] = "Activer les animations d'interface",
	["CO_GENERAL_UI_SOUNDS"] = "Effets sonores d'interface",
	["CO_GENERAL_UI_SOUNDS_TT"] = "Activer les effets sonores d'interface (à l'ouverture des fenêtres, aux changements d'onglets ou aux clics des boutons).",
	["CO_GLANCE_LOCK"] = "Verrouiller la barre",
	["CO_GLANCE_LOCK_TT"] = "Empêche la barre de pouvoir être déplacée",
	["CO_GLANCE_MAIN"] = "Barre \"Coup d’œil\"",
	["CO_GLANCE_PRESET_TRP2"] = "Utiliser les positions dans le style de Total RP 2",
	["CO_GLANCE_PRESET_TRP2_BUTTON"] = "Utiliser",
	["CO_GLANCE_PRESET_TRP2_HELP"] = "Raccourci pour configurer la barre dans le style de TRP2 : à droite du portrait de la cible.",
	["CO_GLANCE_PRESET_TRP3"] = "Utiliser les positions dans le style de Total RP 3",
	["CO_GLANCE_PRESET_TRP3_HELP"] = "Raccourci pour configurer la barre dans le style de TRP3 : en-dessous du portrait de la cible.",
	["CO_GLANCE_RESET_TT"] = "Réinitialiser la position de la barre en bas à gauche du cadre d'ancrage.",
	["CO_GLANCE_TT_ANCHOR"] = "Point d'ancrage des infobulles",
	["CO_HIDE_EMPTY_MAP_BUTTON"] = "Cacher si aucun scan disponible",
	["CO_LOCATION"] = "Paramètres de position",
	["CO_LOCATION_ACTIVATE"] = "Activer la position du personnage",
	["CO_LOCATION_ACTIVATE_TT"] = "Active la fonctionnalité de position du personnage, vous permettant de lancer un scan afin d'afficher sur la carte les autres utilisateurs de Total RP ayant activé cette fonctionnalité. Cela leur permet aussi de vous scanner.",
	["CO_LOCATION_DISABLE_CLASSIC_PVP"] = "Désactiver le scan si PvP",
	["CO_LOCATION_DISABLE_CLASSIC_PVP_TT"] = [=[Vous ne répondrez pas aux requêtes de positions de personnages si vous êtes en mode PvP.

Cette option est particulièrement utile pour éviter les abus du système pour vous traquer.]=],
	["CO_LOCATION_DISABLE_OOC"] = "Désactiver le scan si HRP",
	["CO_LOCATION_DISABLE_OOC_TT"] = "Vous ne répondrez pas aux requêtes de positions de personnages si vous êtes en statut HRP.",
	["CO_LOCATION_DISABLE_PVP"] = "Désactiver le scan si PvP",
	["CO_LOCATION_DISABLE_PVP_TT"] = [=[Vous ne répondrez pas aux requêtes de positions de personnages si vous êtes en mode PvP.

Cette option est particulièrement utile sur les royaumes PvP où les utilisateurs de la faction opposée pourraient abuser du système pour vous traquer.]=],
	["CO_LOCATION_DISABLE_WAR_MODE"] = "Désactiver la location en Mode Guerre",
	["CO_LOCATION_DISABLE_WAR_MODE_TT"] = [=[Vous ne réponderez plus aux demandes de localisation des autres joueurs quand vous avez le Mode Guerre activé et que vous n'êtes pas dans une zone |cff69CCF0Sanctuaire|r.

Cette option est particulièrement utile pour éviter les abus utilisant le système de localisation de Total RP 3 pour vous traquer en JcJ.]=],
	["CO_LOCATION_SHOW_DIFFERENT_WAR_MODES"] = "Afficher les joueurs dans un Mode Guerre différent",
	["CO_LOCATION_SHOW_DIFFERENT_WAR_MODES_TT"] = "Affiche les joueurs dans la zones même s'ils ne sont pas dans la même phase de Mode Guerre que vous, avec une légère transparence et une icône spéciale dans l'infobulle.",
	["CO_MAP_BUTTON"] = "Bouton des recherches sur la carte",
	["CO_MAP_BUTTON_POS"] = "Position du bouton sur la carte",
	["CO_MINIMAP_BUTTON"] = "Bouton de la minicarte",
	["CO_MINIMAP_BUTTON_FRAME"] = "Cadre d'ancrage",
	["CO_MINIMAP_BUTTON_RESET"] = "Réinitialiser la position",
	["CO_MINIMAP_BUTTON_RESET_BUTTON"] = "Réinitialiser",
	["CO_MINIMAP_BUTTON_SHOW_HELP"] = "Si vous utilisez un autre add-on pour afficher le bouton de la mini-carte de Total RP 3 (FuBar, Titan, Bazooka) vous pouvez cacher le bouton par défaut.",
	["CO_MINIMAP_BUTTON_SHOW_TITLE"] = "Afficher le bouton de la mini-carte",
	["CO_MODULES"] = "Statut des modules",
	["CO_MODULES_DISABLE"] = "Désactiver le module",
	["CO_MODULES_ENABLE"] = "Activer le module",
	["CO_MODULES_ID"] = "Identifiant du module: %s",
	["CO_MODULES_SHOWERROR"] = "Afficher l'erreur",
	["CO_MODULES_STATUS"] = "Statut: %s",
	["CO_MODULES_STATUS_0"] = "Dépendances manquantes",
	["CO_MODULES_STATUS_1"] = "Chargé",
	["CO_MODULES_STATUS_2"] = "Désactivé",
	["CO_MODULES_STATUS_3"] = "Mise à jour de Total RP 3 requise",
	["CO_MODULES_STATUS_4"] = "Erreur à l'initialisation",
	["CO_MODULES_STATUS_5"] = "Erreur au démarrage",
	["CO_MODULES_TT_DEP"] = "%s- %s (version %s)|r",
	["CO_MODULES_TT_DEPS"] = "Dépendances",
	["CO_MODULES_TT_ERROR"] = [=[|cffff0000Erreur:|r
%s]=],
	["CO_MODULES_TT_NONE"] = "Pas de dépendances",
	["CO_MODULES_TT_TRP"] = "%sPour Total RP 3 version %s minimum.|r",
	["CO_MODULES_TUTO"] = [=[Un module est une fonctionnalité indépendante qui peut être activé ou désactivé.

Statuts possibles:
|cff00ff00Chargé:|r Le module est activé et chargé.
|cff999999Désactivé:|r Le module est désactivé.
|cffff9900Dépendances manquantes:|r Certaines dépendances ne sont pas chargées.
|cffff9900Mise à jour de TRP requise:|r Le module requiert une version plus récente de TRP3.
|cffff0000Erreur à l'initialisation ou au démarrage:|r La séquence de chargement du module a échoué. Le module créera sans doute des erreurs !

|cffff9900Lorsque vous désactivez un module, il est nécessaire de recharger l'interface.]=],
	["CO_MODULES_VERSION"] = "Version: %s",
	["CO_MSP"] = "Mary Sue Protocol",
	["CO_MSP_T3"] = "Utiliser uniquement le modèle 3",
	["CO_MSP_T3_TT"] = "Même si vous choisissez un autre modèle \"À propos\", le modèle 3 sera toujours utilisé pour la compatibilité avec MSP.",
	["CO_REGISTER"] = "Registre",
	["CO_REGISTER_ABOUT_H1_SIZE"] = "Taille de texte d'en-tête 1",
	["CO_REGISTER_ABOUT_H1_SIZE_TT"] = "Taille du texte entre les balises {h1}. Valeur par défaut: %s",
	["CO_REGISTER_ABOUT_H2_SIZE"] = "Taille de texte d'en-tête 2",
	["CO_REGISTER_ABOUT_H2_SIZE_TT"] = "Taille du texte entre les balises {h2}. Valeur par défaut: %s",
	["CO_REGISTER_ABOUT_H3_SIZE"] = "Taille de texte d'en-tête 3",
	["CO_REGISTER_ABOUT_H3_SIZE_TT"] = "Taille du texte entre les balises {h3}. Valeur par défaut: %s",
	["CO_REGISTER_ABOUT_P_SIZE"] = "Taille de texte de paragraphe",
	["CO_REGISTER_ABOUT_P_SIZE_TT"] = "Taille du texte en dehors des balises. Valeur par défaut: %s",
	["CO_REGISTER_ABOUT_SETTINGS"] = "Paramètres d'à propos",
	["CO_REGISTER_ABOUT_VOTE"] = "Utiliser le système de vote",
	["CO_REGISTER_ABOUT_VOTE_TT"] = "Active le système de vote, vous permettant de voter (\"j'aime\" ou \"je n'aime pas\") pour les descriptions des autres et leur permettant de faire de même pour vous.",
	["CO_REGISTER_AUTO_ADD"] = "Ajouter automatiquement les nouveaux joueurs",
	["CO_REGISTER_AUTO_ADD_TT"] = [=[Ajouter automatiquement les nouveaux joueurs que vous rencontrez au registre.

|cffff0000Note: Désactiver cette option vous empêchera de recevoir de nouveaux profils de joueurs vous n'avez pas encore rencontrés ! Utilisez cette option si vous ne voulez pas recevoir de nouveaux profils d'autres joueurs, seulement des mises à jour de joueurs vous avez déjà rencontrés.]=],
	["CO_REGISTER_AUTO_PURGE"] = "Purge auto. du registre",
	["CO_REGISTER_AUTO_PURGE_0"] = "Désactiver la purge",
	["CO_REGISTER_AUTO_PURGE_1"] = "Après %s jours",
	["CO_REGISTER_AUTO_PURGE_TT"] = [=[Retire automatiquement du registre les profils de personnages que vous n'avez pas croisés depuis un certain temps. Vous pouvez choisir le délai avant la suppression.

|cff00ff00Notez qu'un profil envers lequel un de vos personnages possède une relation ne sera jamais supprimé.

|cffff9900Il existe un bug dans WoW supprimant toutes les données sauvegardées si le fichier de sauvegarde atteint une certaine taille. Nous déconseillons donc fortement de désactiver totalement la purge.]=],
	["CO_SANITIZER"] = "Nettoyer les profils",
	["CO_SANITIZER_TT"] = "Enlève les tags de couleur et d'image insérés dans les champs non-autorisés des profils de joueur et coupe les textes beaucoup trop longs.",
	["CO_TARGETFRAME"] = "Paramètres du cadre de la cible",
	["CO_TARGETFRAME_ICON_SIZE"] = "Taille des icônes",
	["CO_TARGETFRAME_USE"] = "Conditions d'affichage",
	["CO_TARGETFRAME_USE_1"] = "Toujours",
	["CO_TARGETFRAME_USE_2"] = "Uniquement quand le personnage est joué",
	["CO_TARGETFRAME_USE_3"] = "Jamais (Désactivé)",
	["CO_TARGETFRAME_USE_TT"] = "Détermine les conditions d'affichage du cadre de la cible lors de la sélection d'une cible.",
	["CO_TOOLBAR"] = "Cadres",
	["CO_TOOLBAR_CONTENT"] = "Paramètres de la barre d'outils",
	["CO_TOOLBAR_CONTENT_CAPE"] = "Affichage de la cape",
	["CO_TOOLBAR_CONTENT_HELMET"] = "Affichage du casque",
	["CO_TOOLBAR_CONTENT_RPSTATUS"] = "Statut du personnage (RP/HRP)",
	["CO_TOOLBAR_CONTENT_STATUS"] = "Statut du joueur (ABS/NPD)",
	["CO_TOOLBAR_HIDE_TITLE"] = "Cacher la barre de titre",
	["CO_TOOLBAR_HIDE_TITLE_HELP"] = "Cacher la barre de titre Total RP 3 affichée au dessus de la barre d'outils.",
	["CO_TOOLBAR_ICON_SIZE"] = "Taille des icônes",
	["CO_TOOLBAR_MAX"] = "Nombre maximum d'icônes par ligne",
	["CO_TOOLBAR_MAX_TT"] = "Réglez à 1 si vous désirez afficher la barre verticalement !",
	["CO_TOOLBAR_SHOW_ON_LOGIN"] = "Afficher la barre d'outils à la connexion",
	["CO_TOOLBAR_SHOW_ON_LOGIN_HELP"] = "Si vous ne souhaitez plus que la barre d'outils de Total RP 3 s'affiche automatiquement à la connexion, vous pouvez décocher cette option.",
	["CO_TOOLTIP"] = "Infobulles",
	["CO_TOOLTIP_ANCHOR"] = "Point d'ancrage",
	["CO_TOOLTIP_ANCHORED"] = "Cadre ancré",
	["CO_TOOLTIP_CHARACTER"] = "Infobulle de personnages",
	["CO_TOOLTIP_CLIENT"] = "Afficher le client",
	["CO_TOOLTIP_COLOR"] = "Afficher les couleurs personnalisées",
	["CO_TOOLTIP_COMBAT"] = "Cacher durant un combat",
	["CO_TOOLTIP_COMMON"] = "Paramètres généraux",
	["CO_TOOLTIP_CONTRAST"] = "Améliorer le contraste des couleurs",
	["CO_TOOLTIP_CONTRAST_TT"] = "Activez cette option pour que Total RP 3 modifie dynamiquement les couleurs utilisées dans l'infobulle pour que le texte soit plus facile à lire sur un fond sombre.",
	["CO_TOOLTIP_CROP_TEXT"] = "Couper les textes trop longs",
	["CO_TOOLTIP_CROP_TEXT_TT"] = [=[Limiter le nombre de caractères pouvant être utilisés pour les champs de l'infobulle, pour éviter des soucis d'affichage avec des textes trop longs.

|cfffff569Détails de la limitation:
Nom: 100 caractères
Titre: 150 caractères
Race: 50 caractères
Classe: 50 caractères |r]=],
	["CO_TOOLTIP_CURRENT"] = "Afficher l'information \"actuellement\"",
	["CO_TOOLTIP_CURRENT_LINES"] = "Sauts de ligne max pour \"Actuellement\"",
	["CO_TOOLTIP_CURRENT_SIZE"] = "Longueur maximale de l'information \"actuellement\"",
	["CO_TOOLTIP_FT"] = "Afficher le titre complet",
	["CO_TOOLTIP_GUILD"] = "Afficher l'information de la guilde",
	["CO_TOOLTIP_HEALTH"] = "Afficher les PV",
	["CO_TOOLTIP_HEALTH_BOTH"] = "Nombre + Pourcentage",
	["CO_TOOLTIP_HEALTH_DISABLED"] = "Désactivé",
	["CO_TOOLTIP_HEALTH_NUMBER"] = "Nombre",
	["CO_TOOLTIP_HEALTH_PERCENT"] = "Pourcentage",
	["CO_TOOLTIP_HEALTH_TT"] = "Ceci ne sera affiché que si la cible n'a pas tous ses PV.",
	["CO_TOOLTIP_HIDE_IN_INSTANCE"] = "Cacher en instance",
	["CO_TOOLTIP_HIDE_ORIGINAL"] = "Masquer l'infobulle originale",
	["CO_TOOLTIP_ICONS"] = "Afficher les icônes",
	["CO_TOOLTIP_IN_CHARACTER_ONLY"] = "Cacher quand HRP",
	["CO_TOOLTIP_MAINSIZE"] = "Taille de la police principale",
	["CO_TOOLTIP_NO_FADE_OUT"] = "Cacher immédiatement au lieu de disparaître",
	["CO_TOOLTIP_NOTIF"] = "Afficher les notifications",
	["CO_TOOLTIP_NOTIF_TT"] = "La ligne des notifications est la ligne comprenant la version du client, l'indication de description non lue et l'indication 'Coup d'œil'",
	["CO_TOOLTIP_OWNER"] = "Afficher le propriétaire",
	["CO_TOOLTIP_PETS"] = "Infobulle de compagnons",
	["CO_TOOLTIP_PETS_INFO"] = "Afficher l'information du compagnon",
	["CO_TOOLTIP_PREFERRED_OOC_INDICATOR"] = "Indicateur HRP préféré",
	["CO_TOOLTIP_PREFERRED_OOC_INDICATOR_ICON"] = "Icône: ",
	["CO_TOOLTIP_PREFERRED_OOC_INDICATOR_TEXT"] = "Texte: ",
	["CO_TOOLTIP_PROFILE_ONLY"] = "Utiliser uniquement si la cible a un profil",
	["CO_TOOLTIP_PRONOUNS"] = "Afficher les pronoms",
	["CO_TOOLTIP_RACE"] = "Afficher la race, la classe et le niveau",
	["CO_TOOLTIP_REALM"] = "Afficher le royaume",
	["CO_TOOLTIP_RELATION"] = "Afficher la couleur de la relation",
	["CO_TOOLTIP_RELATION_TT"] = "Colorer la bordure de l'infobulle en fonction de la relation",
	["CO_TOOLTIP_SPACING"] = "Afficher les espaces",
	["CO_TOOLTIP_SPACING_TT"] = "Ajoute des espaces pour aérer l'infobulle, dans le style de MyRolePlay.",
	["CO_TOOLTIP_SUBSIZE"] = "Taille de la police secondaire",
	["CO_TOOLTIP_TARGET"] = "Afficher la cible",
	["CO_TOOLTIP_TERSIZE"] = "Taille de la police tertiaire",
	["CO_TOOLTIP_TITLE"] = "Afficher le titre",
	["CO_TOOLTIP_USE"] = "Utiliser les infobulles de personnages/compagnons",
	["CO_TOOLTIP_ZONE"] = "Afficher la zone",
	["CO_TOOLTIP_ZONE_TT"] = "Ceci ne sera affiché que si la cible ne se trouve pas dans la même zone que vous.",
	["CO_UI_RELOAD_WARNING"] = [=[L'interface doit être rechargée afin d'appliquer les changements.

Souhaitez-vous recharger l'interface maintenant ?]=],
	["CO_WIM"] = "|cffff9900Les canaux de chuchotement sont désactivés.",
	["CO_WIM_TT"] = "Vous utilisez |cff00ff00WIM|r, le support des canaux de chuchotement est désactivé pour des raisons de compatibilité.",
	["COM_LIST"] = "Liste des commandes :",
	["COM_RESET_RESET"] = "La position des éléments de l'interface a été réinitialisée.",
	["COM_RESET_USAGE"] = "Utilisation : |cff00ff00/trp3 reset frames|r pour réinitialiser la position des éléments de l'interface.",
	["COM_STASH_DATA"] = [=[|cffff0000Êtes-vous certain de vouloir archiver vos données de Total RP 3?|r

Vos profils, les profils de vos compagnons et vos préférences seront temporairement archivés et l'interface sera rechargée avec des données vides, comme après une nouvelle installation de Total RP 3.
|cff00ff00Utilisez la même commande à nouveau (|cff999999/trp3 stash|cff00ff00) pour restaurer vos données.|r]=],
	["COM_SWITCH_USAGE"] = "Utilisation: |cff00ff00/trp3 switch main|r pour afficher ou masquer la fenêtre principale ou |cff00ff00/trp3 switch toolbar|r pour afficher ou masquer la barre d'outils.",
	["CONFIG_COMMS_SETTINGS_HEADER"] = "Paramètres de communication",
	["COPY_DROPDOWN_POPUP_TEXT"] = [=[Copiez avec %1$s. Collez avec %2$s.
Cette fenêtre sera fermée à la copie.]=],
	["COPY_SYSTEM_MESSAGE"] = "Copié dans le presse-papiers.",
	["CREDITS_DISCORD_LINK_TEXT"] = "Rejoignez-nous sur Discord (en anglais)",
	["CREDITS_GUILD_NAME"] = "<%1$s>",
	["CREDITS_NAME_WITH_ROLE"] = "%1$s (%2$s)",
	["CREDITS_THANK_YOU_ROLE_1"] = "Chef de projet",
	["CREDITS_THANK_YOU_ROLE_2"] = "Auteur",
	["CREDITS_THANK_YOU_ROLE_3"] = "Développeur",
	["CREDITS_THANK_YOU_ROLE_4"] = "Community Manager",
	["CREDITS_THANK_YOU_ROLE_5"] = "Mascotte",
	["CREDITS_THANK_YOU_SECTION_1"] = "{h1:c}Total RP 3{/h1}",
	["CREDITS_THANK_YOU_SECTION_10"] = "{col:ffffff}Merci aux membres actifs de notre communauté sur Discord:{/col}",
	["CREDITS_THANK_YOU_SECTION_11"] = "{col:ffffff}Merci à Bor Blasthammer pour son aide durant la phase de test de BfA.{/col}",
	["CREDITS_THANK_YOU_SECTION_2"] = "{h2}%1$s Créé par{/h2}",
	["CREDITS_THANK_YOU_SECTION_3"] = "{h2}%1$s Le reste de l'équipe{/h2}",
	["CREDITS_THANK_YOU_SECTION_4"] = "{h2}%1$s Remerciements{/h2}",
	["CREDITS_THANK_YOU_SECTION_5"] = "{col:ffffff}Les logos et icône de la carte ont été réalisés par:{/col} %1$s",
	["CREDITS_THANK_YOU_SECTION_6"] = "{col:ffffff}Notre équipe de test:{/col}",
	["CREDITS_THANK_YOU_SECTION_7"] = "{col:ffffff}Merci à tous nos amis pour leur soutien:{/col}",
	["CREDITS_THANK_YOU_SECTION_8"] = "{col:ffffff}Pour nous avoir aidés à créer la guilde Total RP sur Kirin Tor (EU):{/col}",
	["CREDITS_THANK_YOU_SECTION_9"] = "{col:ffffff}Merci à Horionne pour nous avoir envoyé son exemplaire du Gamer Culte Online #14 qui contient un article sur Total RP.{/col}",
	["CREDITS_VERSION_TEXT"] = "Version %s",
	["CREDITS_WEBSITE_LINK_TEXT"] = "Site internet",
	["DB_ABOUT"] = "A propos de Total RP 3",
	["DB_HTML_GOTO"] = "Cliquer pour ouvrir",
	["DB_MORE"] = "Plus de modules",
	["DB_NEW"] = "Quoi de neuf ?",
	["DB_STATUS"] = "Statut",
	["DB_STATUS_CURRENTLY"] = "Actuellement (RP)",
	["DB_STATUS_CURRENTLY_COMMON"] = "Ces statuts seront affichés dans l'infobulle de votre personnage. Restez clair et bref, |cffff9900par défaut les utilisateurs de Total RP 3 verront uniquement les 140 premiers caractères !",
	["DB_STATUS_CURRENTLY_OOC"] = "Autres informations (HRP)",
	["DB_STATUS_CURRENTLY_OOC_TT"] = "Vous pouvez indiquer ici quelque chose d'important sur vous, le joueur, ou autre chose hors de votre personnage.",
	["DB_STATUS_CURRENTLY_TT"] = "Vous pouvez indiquer ici quelque chose d'important sur votre personnage.",
	["DB_STATUS_ICON_ITEM"] = "%1$s %2$s",
	["DB_STATUS_LC"] = "Langage de jeu de rôle",
	["DB_STATUS_LC_DEFAULT"] = "Par défaut (%1$s)",
	["DB_STATUS_LC_TT"] = [=[Règle votre langage de jeu de rôle préféré. Ce réglage sera partagé avec les autres utilisateurs d'addons RP compatibles.

|cffff9900Note:|r Ceci ne change |cffff0000pas|r le langage de l'interface de Total RP 3. Cette option peut être trouvée dans la page de |cfffff569Paramètres avancés|r.]=],
	["DB_STATUS_RP"] = "Statut du personnage",
	["DB_STATUS_RP_EXP"] = "Rôliste confirmé",
	["DB_STATUS_RP_EXP_TT"] = [=[Montre que vous êtes un rôliste confirmé.
Cela n'affichera aucune icône spécifique sur votre bulle d'aide.]=],
	["DB_STATUS_RP_IC"] = "Personnage joué",
	["DB_STATUS_RP_IC_TT"] = [=[Cela signifie que vous jouez actuellement votre personnage.
Toutes vos actions seront interprétées comme si votre personnage les effectuait.]=],
	["DB_STATUS_RP_OOC"] = "Hors du personnage",
	["DB_STATUS_RP_OOC_TT"] = [=[Vous n'êtes pas dans votre personnage.
Vos actions ne lui seront pas associées.]=],
	["DB_STATUS_RP_VOLUNTEER"] = "Rôliste volontaire",
	["DB_STATUS_RP_VOLUNTEER_TT"] = [=[Ce choix affichera une icône dans votre infobulle, indiquant
aux joueurs débutants que vous êtes enclin à les aider.]=],
	["DB_STATUS_XP"] = "Statut roleplay",
	["DB_STATUS_XP_BEGINNER"] = "Rôliste débutant",
	["DB_STATUS_XP_BEGINNER_TT"] = [=[Ce choix affichera une icône dans votre infobulle, indiquant
aux autres que vous débutez dans le roleplay.]=],
	["DB_TUTO_1"] = [=[|cffffff00Le statut du personnage|r indique si vous jouez actuellement le rôle de votre personnage ou non.

|cffffff00Le statut roleplay|r vous permet d'indiquer que vous êtes un débutant ou un vétéran désireux d'aider les novices !

|cff00ff00Cette information sera placée dans la bulle d'aide de votre personnage.]=],
	["DICE_HELP"] = "Un ou des jets de dés, séparés par des espaces. Examples: 1d6, 2d12 3d20 ...",
	["DICE_ROLL"] = "%s Lancer de |cffff9900%sx d%s|r|cffcc6600%s|r et obtenu |cff00ff00%s|r.",
	["DICE_ROLL_T"] = "%s %s a lancé |cffff9900%sx d%s|r|cffcc6600%s|r et a obtenu |cff00ff00%s|r.",
	["DICE_TOTAL"] = "%s Total de |cff00ff00%s|r pour le jet.",
	["DICE_TOTAL_T"] = "%s %s a eu un total de |cff00ff00%s|r pour le jet.",
	["DTBK_AFK"] = "Total RP 3 - ABS/NPD",
	["DTBK_CLOAK"] = "Total RP 3 - Cape",
	["DTBK_HELMET"] = "Total RP 3 - Casque",
	["DTBK_LANGUAGES"] = "Total RP - Langages",
	["DTBK_RP"] = "Total RP 3 - RP/HRP",
	["GEN_VERSION"] = "Version: %s (Build %s)",
	["GEN_WELCOME_MESSAGE"] = "Merci d'utiliser Total RP 3 (v %s) ! Amusez-vous bien !",
	["KUI_NAMEPLATES_MODULE_DESCRIPTION"] = "Active la personnalisation des barres d'info Kui.",
	["KUI_NAMEPLATES_MODULE_NAME"] = "Barres d'info Kui",
	["KUI_NAMEPLATES_WARN_OUTDATED_MODULE"] = "Le module Kui |cff9966ffNameplates|r pour Total RP 3 a été intégré directement à l'addon principal.|n|nL'ancien plugin a été désactivé automatiquement, et |cffffcc00nous vous recommandons de le désinstaller|r parce qu'il n'est plus nécessaire.",
	["LANG_CHANGE_CAUSED_REVERT_TO_DEFAULT"] = "La langue parlée a été réinitialiser pour la langue par défaut %s car vous ne connaissez la langue précedemment sélectionnée %s.",
	["MAP_BUTTON_NO_SCAN"] = "Pas de scan disponible",
	["MAP_BUTTON_SCANNING"] = "Scan en cours",
	["MAP_BUTTON_SUBTITLE"] = "Clic pour afficher les scans disponibles",
	["MAP_BUTTON_SUBTITLE_80_DISABLED"] = "Scans temporairement indisponibles dû aux changements de la 8.0",
	["MAP_BUTTON_SUBTITLE_CONNECTING"] = "La recherche sur la carte est en cours d'initialisation. Veuillez patienter.",
	["MAP_BUTTON_SUBTITLE_OFFLINE"] = "Les recherches sur la carte ne sont pas disponibles pour le moment: %s",
	["MAP_BUTTON_TITLE"] = "Recherches roleplay",
	["MAP_SCAN_CHAR"] = "Afficher les personnages",
	["MAP_SCAN_CHAR_TITLE"] = "Personnages",
	["MATURE_FILTER_ADD_TO_SAFELIST"] = "Ajouter ce profil à la |cffffffffliste verte mature|r",
	["MATURE_FILTER_ADD_TO_SAFELIST_OPTION"] = "Ajouter à la |cffffffffliste verte mature|r",
	["MATURE_FILTER_ADD_TO_SAFELIST_TEXT"] = [=[Confirmez que vous souhaitez ajouter %s à la |cffffffffliste verte mature|r.

Le contenu de son profil ne sera plus caché.]=],
	["MATURE_FILTER_ADD_TO_SAFELIST_TT"] = "Ajouter ce profil à la |cffffffffliste verte mature|r et afficher le contenu mature.",
	["MATURE_FILTER_ADD_TO_WHITELIST"] = "Ajouter ce profil à la |cffffffffliste blanche mature|r",
	["MATURE_FILTER_ADD_TO_WHITELIST_OPTION"] = "Ajouter à la |cffffffffliste blanche mature|r",
	["MATURE_FILTER_ADD_TO_WHITELIST_TEXT"] = [=[Confirmez que vous souhaitez ajouter %s à la |cffffffffliste blanche mature|r.

Le contenu de son profil ne sera plus caché.]=],
	["MATURE_FILTER_ADD_TO_WHITELIST_TT"] = "Ajouter ce profil à la |cffffffffliste blanche mature|r et afficher le contenu mature.",
	["MATURE_FILTER_EDIT_DICTIONARY"] = "Éditer le dictionnaire",
	["MATURE_FILTER_EDIT_DICTIONARY_ADD_BUTTON"] = "Ajouter",
	["MATURE_FILTER_EDIT_DICTIONARY_ADD_TEXT"] = "Ajouter un nouveau mot au dictionnaire",
	["MATURE_FILTER_EDIT_DICTIONARY_BUTTON"] = "Éditer",
	["MATURE_FILTER_EDIT_DICTIONARY_DELETE_WORD"] = "Supprimer le mot du dictionnaire",
	["MATURE_FILTER_EDIT_DICTIONARY_EDIT_WORD"] = "Éditer ce mot",
	["MATURE_FILTER_EDIT_DICTIONARY_RESET_BUTTON"] = "Réinitialiser",
	["MATURE_FILTER_EDIT_DICTIONARY_RESET_TITLE"] = "Réinitialiser le dictionnaire",
	["MATURE_FILTER_EDIT_DICTIONARY_RESET_WARNING"] = "Êtes-vous certain de vouloir réinitialiser le dictionnaire ? Le dictionnaire actuel sera remplacé par celui par défaut pour la langue active (is disponible).",
	["MATURE_FILTER_EDIT_DICTIONARY_TITLE"] = "Éditeur de dictionnaire",
	["MATURE_FILTER_EDIT_DICTIONARY_TT"] = "Éditer le dictionnaire utilisé par le filtre de profils matures.",
	["MATURE_FILTER_FLAG_PLAYER"] = "Marquer comme mature",
	["MATURE_FILTER_FLAG_PLAYER_OPTION"] = "Marquer comme mature",
	["MATURE_FILTER_FLAG_PLAYER_TEXT"] = [=[Confirmez que vous souhaitez marquer le profil de %s comme contenant du contenu mature. Le contenu de ce profil sera masqué.

|cffffff00Optionnel:|r Indiquez ici les mots inappropriés (séparés par un espace) pour les ajouter au dictionnaire utilisé par le filtre de profils matures.]=],
	["MATURE_FILTER_FLAG_PLAYER_TT"] = "Marquer ce profil comme contenant du contenu mature. Le contenu sera masqué.",
	["MATURE_FILTER_OPTION"] = "Filtrer le contenu mature",
	["MATURE_FILTER_OPTION_TT"] = [=[Cochez cette option pour activer le filtre de contenu mature. Total RP 3 analysera les profils reçus à la réception à la recherche de mots clés considérés comme étant inappropriés et marquera les profils comme matures.

Un profil marqué comme contenant du contenu mature aura son infobulle censurée et vous devrez confirmer à l'ouverture du profil.]=],
	["MATURE_FILTER_REMOVE_FROM_SAFELIST"] = "Retirer ce profil de la |cffffffffliste verte mature|r",
	["MATURE_FILTER_REMOVE_FROM_SAFELIST_OPTION"] = "Retirer ce profil de la |cffffffffliste verte mature|r",
	["MATURE_FILTER_REMOVE_FROM_SAFELIST_TEXT"] = [=[Confirmez que vous souhaitez retirer %s de la |cffffffffliste verte mature|r.

Le contenu de son profile sera à nouveau masqué.]=],
	["MATURE_FILTER_REMOVE_FROM_SAFELIST_TT"] = "Retirer ce profil de la |cffffffffliste verte mature|r et masquer à nouveau le contenu.",
	["MATURE_FILTER_REMOVE_FROM_WHITELIST"] = "Retirer ce profil de la |cffffffffliste blanche mature|r",
	["MATURE_FILTER_REMOVE_FROM_WHITELIST_OPTION"] = "Retirer ce profil de la |cffffffffliste blanche mature|r",
	["MATURE_FILTER_REMOVE_FROM_WHITELIST_TEXT"] = [=[Confirmez que vous souhaitez retirer %s de la |cffffffffliste blanche mature|r.

Le contenu de son profile sera à nouveau masqué.]=],
	["MATURE_FILTER_REMOVE_FROM_WHITELIST_TT"] = "Retirer ce profil de la |cffffffffliste blanche mature|r et masquer à nouveau le contenu.",
	["MATURE_FILTER_STRENGTH"] = "Niveau du filtre mature",
	["MATURE_FILTER_STRENGTH_TT"] = [=[Défini le niveau du filtre mature.

|cffcccccc1 pour faible (10 mots nécessaires pour être censuré), 10 est fort (seulement 1 mot est nécessaire pour être censuré).|r]=],
	["MATURE_FILTER_TITLE"] = "Filtre de contenu mature",
	["MATURE_FILTER_TOOLTIP_WARNING"] = "Contenu mature",
	["MATURE_FILTER_TOOLTIP_WARNING_SUBTEXT"] = "Le profil de ce personnage contient du contenu inapproprié. Utilisez les boutons de la barre de cible pour afficher son profil si vous le souhaitez vraiment…",
	["MATURE_FILTER_WARNING_CONTINUE"] = "Continuer",
	["MATURE_FILTER_WARNING_GO_BACK"] = "Revenir en arrière",
	["MATURE_FILTER_WARNING_TEXT"] = [=[Vous avez activé le filtre de contenu mature de Total RP 3.

Ce profil a été marqué comme contenant du contenu mature.

Êtes-vous certain de vouloir consulter ce profil ?]=],
	["MATURE_FILTER_WARNING_TITLE"] = "Contenu mature",
	["MM_SHOW_HIDE_MAIN"] = "Afficher/cacher la fenêtre principale",
	["MM_SHOW_HIDE_MOVE"] = "Déplacer le bouton",
	["MM_SHOW_HIDE_SHORTCUT"] = "Afficher/cacher la barre d'outils",
	["MO_ADDON_NOT_INSTALLED"] = "L'add-on %s n'est pas installé, l'intégration avec Total RP 3 est désactivée.",
	["MO_CHAT_CUSTOMIZATIONS_DESCRIPTION"] = "Ajoute la compatibilité avec l'add-on %s, pour que les messages et les noms des joueurs soient modifiés par Total RP 3 dans cet add-on.",
	["MO_TOOLTIP_CUSTOMIZATIONS_DESCRIPTION"] = "Ajoute la compatibilité avec l'add-on %s, pour que les préférences d'infobulle de l'add-on soient également appliquées aux infobulles de Total RP 3.",
	["MORE_MODULES_2"] = [=[{h2:c}Modules complémentaires{/h2}
{h3}Total RP 3: Extended{/h3}
|cff9999ffTotal RP 3: Extended|r ajoute la création de campagnes avec des quêtes et des dialogues, des objets, des documents (livres, affiches, contrats) et encore bien plus!
{link*https://www.curseforge.com/wow/addons/total-rp-3-extended*Télécharger sur CurseForge}

{h3}TRP3 Currently Frame{/h3}
Ajoute une fenêtre à votre interface pour afficher et éditer facilement le texte de votre section "Actuellement (RP)".
{link*https://www.curseforge.com/wow/addons/trp3-currently-frame*Télécharger sur CurseForge}

{h3}TRP3 Location Toggle{/h3}
Ajoute un bouton à votre barre d'outils pour activer ou désactiver votre affichage sur le scan de la carte.
{link*https://www.curseforge.com/wow/addons/trp3-location-toggle*Télécharger sur CurseForge}]=],
	["NAMEPLATES_CONFIG_ACTIVE_QUERY"] = "Récupérer automatiquement les profils",
	["NAMEPLATES_CONFIG_ACTIVE_QUERY_HELP"] = "Si coché, récupère automatiquement les profils RP des unités avec des barres d'infos visibles.",
	["NAMEPLATES_CONFIG_BLIZZARD_NAME_ONLY"] = "Cacher les barres de vie |cff449fe0Blizzard|r",
	["NAMEPLATES_CONFIG_BLIZZARD_NAME_ONLY_HELP"] = "Si coché, ceci active le mode \"nom uniquement\" des barres d'info |cff449fe0Blizzard|r.|n|nDans ce mode, toutes les barres d'info ont les barres de vie cachées, y compris celles des unités ennemies et des autres joueurs avec ou sans profil RP.|n|nCette option requiert de recharger l'interface pour prendre effet.",
	["NAMEPLATES_CONFIG_CUSTOMIZE_FULL_TITLES"] = "Afficher les titres complets",
	["NAMEPLATES_CONFIG_CUSTOMIZE_FULL_TITLES_HELP"] = "Si coché, affiche le titre complet d'une unité sur sa barre d'info.|n|nPour les barres d'info |cff449fe0Blizzard|r et |cff9966ffKui|r, les titres complets ne sont affichés qu'en mode \"nom uniquement\".",
	["NAMEPLATES_CONFIG_CUSTOMIZE_HEALTH_COLORS"] = "Barres de vie avec couleur personnalisée",
	["NAMEPLATES_CONFIG_CUSTOMIZE_HEALTH_COLORS_HELP"] = "Si coché, remplace la couleur des barres de vie par la couleur de classe sélectionnée dans le profil.",
	["NAMEPLATES_CONFIG_CUSTOMIZE_ICONS"] = "Afficher icones",
	["NAMEPLATES_CONFIG_CUSTOMIZE_ICONS_HELP"] = "Si coché, affiche les icones de profil sur les barres d'info.",
	["NAMEPLATES_CONFIG_CUSTOMIZE_NAME_COLORS"] = "Nom avec couleur personnalisé",
	["NAMEPLATES_CONFIG_CUSTOMIZE_NAME_COLORS_HELP"] = "Si coché, remplace la couleur des noms par la couleur de classe sélectionnée dans le profil.",
	["NAMEPLATES_CONFIG_CUSTOMIZE_NAMES"] = "Afficher noms personnalisés",
	["NAMEPLATES_CONFIG_CUSTOMIZE_NAMES_HELP"] = "Si coché, remplace le nom affiché sur les barres d'info par le nom dans le profil.",
	["NAMEPLATES_CONFIG_CUSTOMIZE_ROLEPLAY_STATUS"] = "Afficher l'indicateur de statut RP",
	["NAMEPLATES_CONFIG_CUSTOMIZE_ROLEPLAY_STATUS_HELP"] = "Si coché, affiche un indicateur du statut de l'unité (RP ou HRP) sur les barres d'info.",
	["NAMEPLATES_CONFIG_CUSTOMIZE_TITLES"] = "Afficher les titres",
	["NAMEPLATES_CONFIG_CUSTOMIZE_TITLES_HELP"] = "Si coché, affiche le titre court d'une unité avant le nom sur les barres d'info.",
	["NAMEPLATES_CONFIG_DISABLE_IN_COMBAT"] = "Désactiver personnalisation en combat",
	["NAMEPLATES_CONFIG_DISABLE_IN_COMBAT_HELP"] = "Si coché, désactive la personnalisation des barres d'info en combat.",
	["NAMEPLATES_CONFIG_DISABLE_OUT_OF_CHARACTER"] = "Désactiver personnalisation en HRP",
	["NAMEPLATES_CONFIG_DISABLE_OUT_OF_CHARACTER_HELP"] = "Si coché, désactive la personnalisation des barres d'info quand vous êtes HRP.",
	["NAMEPLATES_CONFIG_DISABLE_OUT_OF_CHARACTER_UNITS"] = "Désactiver personnalisation des unités HRP",
	["NAMEPLATES_CONFIG_DISABLE_OUT_OF_CHARACTER_UNITS_HELP"] = "Si coché, désactive la personnalisation des barres d'info des unités HRP.",
	["NAMEPLATES_CONFIG_ELEMENT_HEADER"] = "Paramètres de personnalisation",
	["NAMEPLATES_CONFIG_ENABLE_CLASS_COLOR_FALLBACK"] = "Utiliser la couleur de classe par défaut",
	["NAMEPLATES_CONFIG_ENABLE_CLASS_COLOR_FALLBACK_HELP"] = "Si coché, la couleur de classe de base sera utilisée par défaut pour les noms et barres de vie (si applicable) des unités dans couleur personnalisée dans leur profil.|n|nLes unités sans profil ne sont pas affectées par ce paramètres et ne seront pas colorées.",
	["NAMEPLATES_CONFIG_HIDE_NON_ROLEPLAY_UNITS"] = "Cacher les unités non-RP",
	["NAMEPLATES_CONFIG_HIDE_NON_ROLEPLAY_UNITS_HELP"] = "Si coché, cache les barres d'infos des joueurs et compagnons sans profil.",
	["NAMEPLATES_CONFIG_HIDE_OUT_OF_CHARACTER_UNITS"] = "Cacher les unités HRP",
	["NAMEPLATES_CONFIG_HIDE_OUT_OF_CHARACTER_UNITS_HELP"] = "Si coché, cache les barres d'infos des unités HRP.",
	["NAMEPLATES_CONFIG_ICON_SIZE"] = "Taille d'icone",
	["NAMEPLATES_CONFIG_ICON_SIZE_HELP"] = "Configure la taille des icones affichées sur les barres d'infos si l'option |cffffff00Afficher icones|r est activée.",
	["NAMEPLATES_CONFIG_MENU_TITLE"] = "Barres d'info",
	["NAMEPLATES_CONFIG_PAGE_HELP"] = "Veuillez noter que seules les barres d'infos |cff449fe0Blizzard|r et |cff9966ffKui|r sont actuellement supportées. Réferez-vous aux bulles d'aide de chaque paramètre ci-dessous pour plus d'information.",
	["NAMEPLATES_CONFIG_PAGE_TEXT"] = "Paramètres de barres d'info",
	["NAMEPLATES_CONFIG_VISIBILITY_HEADER"] = "Paramètres de visibilité",
	["NAMEPLATES_MODULE_ACTIVE_STATUS"] = "Module |cff00ff00actif|r (%1$s|r)",
	["NAMEPLATES_MODULE_DESCRIPTION"] = "Active la personnalisation des barres d'info avec les informations contenues dans les profils RP.",
	["NAMEPLATES_MODULE_DISABLE_WARNING"] = "Désactiver le module de barres d'info bloquera toute personnalisation des barres d'info. L'interface devra être rechargée pour que ce changement prenne effet.|n|n|cffff0000Attention: |rUne fois désactivé, ce module ne peut être réactivé que via l'onglet de |cffffcc00Statut des modules|r.|n|nVoulez-vous vraiment désactiver ce module ?",
	["NAMEPLATES_MODULE_DISABLED_BY_DEPENDENCY"] = "Ce module a été automatiquement désactivé dû à une dépendance manquante.",
	["NAMEPLATES_MODULE_DISABLED_BY_EXTERNAL"] = "Ce module a été automatiquement désactivé dû à un conflit avec un autre module ou addon.",
	["NAMEPLATES_MODULE_INACTIVE_STATUS"] = "Module |cffff9900inactif|r (pas d'addon détecté)",
	["NAMEPLATES_MODULE_NAME"] = "Barres d'info",
	["NEW_VERSION"] = [=[|cff00ff00Une nouvelle version de Total RP 3 (v %s) est disponible.

|cffffff00Nous vous encourageons fortement à mettre à jour l'add-on pour profiter des dernières corrections de bugs.|r

Ce message n'apparaîtra qu'une seule fois par session et peut être désactivé dans les réglages (Général => Divers).]=],
	["NEW_VERSION_BEHIND"] = "Vous êtes actuellement en retard de %s versions et manquez beaucoup de corrections de bugs et nouvelles fonctionnalités. Les autres joueurs risquent de ne pas voir votre profil correctement. Pensez à mettre à jour l'add-on.",
	["NEW_VERSION_TITLE"] = "Nouvelle mise-à-jour disponible",
	["NPC_TALK_BUTTON_TT"] = "Ouvre la fenêtre de dialogues de PNJ.",
	["NPC_TALK_CHANNEL"] = "Canal:",
	["NPC_TALK_COMMAND_HELP"] = "Ouvre la fenêtre de dialogues de PNJ.",
	["NPC_TALK_ERROR_EMPTY_MESSAGE"] = "Le message ne peut pas être vide.",
	["NPC_TALK_MESSAGE"] = "Message",
	["NPC_TALK_NAME"] = "Nom du PNJ",
	["NPC_TALK_NAME_TT"] = [=[Vous pouvez utiliser les tags de chat %t pour insérer le nom de la cible ou %f pour insérer le nom du focus.

Vous pouvez également laisser le champ vide pour faire une émote sans nom de PNJ au début.]=],
	["NPC_TALK_SAY_PATTERN"] = "dit :",
	["NPC_TALK_SEND"] = "Envoyer",
	["NPC_TALK_TITLE"] = "Dialogues de PNJ",
	["NPC_TALK_WHISPER_PATTERN"] = "chuchote :",
	["NPC_TALK_YELL_PATTERN"] = "crie :",
	["OPTION_DISABLED_TOAST"] = "Option désactivée",
	["OPTION_ENABLED_TOAST"] = "Option activée",
	["PATTERN_ERROR"] = "Erreur dans le pattern",
	["PATTERN_ERROR_TAG"] = "Erreur dans le pattern: tag non fermé",
	["PR_CO_BATTLE"] = "Compagnon",
	["PR_CO_COUNT"] = "%s familiers/montures liés à ce profil.",
	["PR_CO_EMPTY"] = "Pas de profil compagnon",
	["PR_CO_MASTERS"] = "Maîtres",
	["PR_CO_MOUNT"] = "Monture",
	["PR_CO_NEW_PROFILE"] = "Nouveau profil compagnon",
	["PR_CO_PET"] = "Familier",
	["PR_CO_PROFILE_DETAIL"] = "Ce profil est actuellement lié à",
	["PR_CO_PROFILE_HELP"] = [=[Le profil contient toutes les informations sur un |cffffff00"familier"|r comme un |cff00ff00personnage roleplay|r.

Un profil de familier peut être lié à:
- Une mascotte de combat |cffff9900(uniquement si elle a été renommée)|r
- Un familier de chasseur
- Un serviteur de démoniste
- Un élémentaire de mage
- Une goule de chevalier de la mort |cffff9900(voir en-dessous)|r

À l'instar des profils de personnages, un |cff00ff00profil de compagnon|r peut être lié à |cffffff00plusieurs familiers|r, et un |cffffff00familier|r peut passer facilement d'un profil à un autre.

|cffff9900Goules:|r Les goules obtenant un nom différent à chaque invocation, il est nécessaire de lier le profil à la goule pour tous les noms générés.]=],
	["PR_CO_PROFILE_HELP2"] = [=[Cliquer ici pour créer un nouveau profil de compagnon.

|cff00ff00Pour lier un profil à un familier, invoquez juste le familier, sélectionnez-le et utilisez le cadre de cible pour le lier à un profil existant (ou en créer un nouveau).|r]=],
	["PR_CO_PROFILEMANAGER_DELETE_WARNING"] = [=[Êtes-vous sûr(e) de vouloir supprimer le profil compagnon %s ?
Cette action est irréversible et toutes les informations liées à ce profil seront détruites !]=],
	["PR_CO_PROFILEMANAGER_DUPP_POPUP"] = [=[Veuillez entrer le nom pour le nouveau profil.
Le nom ne peut pas être vide.

Cette duplication ne change pas les familiers/montures liés à %s.]=],
	["PR_CO_PROFILEMANAGER_EDIT_POPUP"] = [=[Veuillez entrer le nouveau nom pour ce profile %s.
Le nom ne peut pas être vide.

Changer le nom ne modifie pas les liens entre ce profil et vos familiers/montures.]=],
	["PR_CO_PROFILEMANAGER_TITLE"] = "Profils de compagnons",
	["PR_CO_UNUSED_PROFILE"] = "Ce profil n'est actuellement lié à aucun familier ou monture.",
	["PR_CO_WARNING_RENAME"] = [=[|cffff0000Attention:|r il est fortement recommandé que vous renommiez votre familier avant de le lier à un profil.

Le lier quand même ?]=],
	["PR_CREATE_PROFILE"] = "Créer un profil",
	["PR_DEFAULT_PROFILE_NAME"] = "Profil par défaut",
	["PR_DEFAULT_PROFILE_WARNING"] = [=[Créez un nouveau profil
ou liez un profil existant dans l'onglet Profils
pour modifier les informations de votre personnage.]=],
	["PR_DELETE_PROFILE"] = "Supprimer le profil",
	["PR_DUPLICATE_PROFILE"] = "Dupliquer le profil",
	["PR_EXPORT_IMPORT_HELP"] = [=[Vous pouvez exporter et importer vos profils en utilisant les options du menu.

Utilisez l'option |cffffff00Exporter le profil|r pour générer une version sérialisée de votre profil sous forme de texte. Vous pouvez copier le texte en utilisant Contrôle-C (ou Commande-C sur Mac) pour le copier autre part comme sauvegarde. (|cffff0000Veuillez noter que les éditeurs de texte avancés comme Microsoft Word reformattent les caractères comme les guillemets, modifiant ainsi le contenu. Il est recommandé d'utiliser un logiciel d'édition de texte plus simple, comme le Bloc Note.|r)

Utilisez l'option |cffffff00Importer un profil|r pour coller le texte d'un export précédent dans le profil. Les données du profil choisi seront écrasées par les données collées. Vous ne pouvez pas importer un profil directement dans celui actuellement utilisé.]=],
	["PR_EXPORT_IMPORT_TITLE"] = "Exporter/importer un profil",
	["PR_EXPORT_NAME"] = "Serial du profil %s (taille %0.2f Ko)",
	["PR_EXPORT_PROFILE"] = "Exporter le profil",
	["PR_EXPORT_TOO_LARGE"] = [=[Ce profil est trop gros et ne peut pas être exporté.

Taille du profil : %0.2f Ko
Taille maximale : 20 Ko]=],
	["PR_EXPORT_WARNING_MAC"] = [=[Attention: Certains logiciel de traitement de texte ou de messagerie comme Text Edit ou Discord reformattent les caractères spéciaux, comme les apostrophes, modifiant et corrompant le contenu des données.

Si vous comptiez copier ce texte dans un document, il est préférable d'utiliser des outils simples qui ne modifient pas le text (dans Text Edit utiliser le menu Format > Convertir au format Texte avant de coller le text).]=],
	["PR_EXPORT_WARNING_TITLE"] = "Attention: ",
	["PR_EXPORT_WARNING_WINDOWS"] = [=[Attention: Certains logiciel de traitement de texte ou de messagerie comme Microsoft Word ou Discord reformattent les caractères spéciaux, comme les apostrophes, modifiant et corrompant le contenu des données.

Si vous comptiez copier ce texte dans un document, il est préférable d'utiliser des outils simples qui ne modifient pas le text, comme le Bloc Note de Windows.]=],
	["PR_IMPORT"] = "Importer",
	["PR_IMPORT_CHAR_TAB"] = "Importateur de personnages",
	["PR_IMPORT_EMPTY"] = "Aucun profil disponible",
	["PR_IMPORT_IMPORT_ALL"] = "Tout importer",
	["PR_IMPORT_PETS_TAB"] = "Importateur de compagnons",
	["PR_IMPORT_PROFILE"] = "Importer le profil",
	["PR_IMPORT_PROFILE_TT"] = "Veuillez coller le serial d'un profil dans la boîte de texte",
	["PR_IMPORT_WILL_BE_IMPORTED"] = "Sera importé",
	["PR_PROFILE"] = "Profil",
	["PR_PROFILE_CREATED"] = "Profil %s créé.",
	["PR_PROFILE_DELETED"] = "Profil %s supprimé.",
	["PR_PROFILE_DETAIL"] = "Ce profil est actuellement lié à ces personnages WoW",
	["PR_PROFILE_HELP"] = [=[Un profil contient toutes les informations à propos d'un |cffffff00"personnage"|r en tant que |cff00ff00personnage roleplay|r.

Un |cffffff00"personnage WoW"|r réel ne peut être lié qu'à un seul profil à la fois, mais peut passer d'un profil à un autre à votre convenance.

Vous pouvez aussi lier plusieurs |cffffff00"personnages WoW"|r au même |cff00ff00profil|r !]=],
	["PR_PROFILE_LOADED"] = "Le profil %s est chargé.",
	["PR_PROFILE_MANAGEMENT_TITLE"] = "Gestion du profil",
	["PR_PROFILEMANAGER_ACTIONS"] = "Actions",
	["PR_PROFILEMANAGER_ALREADY_IN_USE"] = "Le nom de profil %s n'est pas disponible.",
	["PR_PROFILEMANAGER_COUNT"] = "%s personnage(s) WoW lié(s) à ce profil.",
	["PR_PROFILEMANAGER_CREATE_POPUP"] = [=[Veuillez entrer un nom pour le nouveau profil.
Ce nom ne peut pas être vide.]=],
	["PR_PROFILEMANAGER_CURRENT"] = "Profil actuel",
	["PR_PROFILEMANAGER_DELETE_WARNING"] = [=[Êtes-vous sûr de vouloir supprimer le profil %s?
Cette action est irréversible et toutes les informations TRP3 liées à ce profil (Informations du personnage, inventaire, journal de quêtes, états actifs ...) seront effacées !]=],
	["PR_PROFILEMANAGER_DUPP_POPUP"] = [=[Veuillez entrer un nom pour le nouveau profil.
Ce nom ne peut pas être vide.

Cette duplication ne changera pas les liens du personnage à %s.]=],
	["PR_PROFILEMANAGER_EDIT_POPUP"] = [=[Veuillez entrer un nom pour le nouveau profil.
Ce nom ne peut pas être vide.

Changer le nom ne changera aucun lien entre ce profil et vos personnages.]=],
	["PR_PROFILEMANAGER_EMPTY"] = "Pas de profil trouvé",
	["PR_PROFILEMANAGER_IMPORT_WARNING"] = "Remplacer le contenu du profil %s avec les données importées ?",
	["PR_PROFILEMANAGER_IMPORT_WARNING_2"] = [=[Attention : le profil que vous voulez importer a été exporté avec une version plus ancienne de Total RP 3.
Des soucis de compatibilité pourraient se présenter.

Remplacer le contenu du profil %s avec les données importées ?]=],
	["PR_PROFILEMANAGER_RENAME"] = "Renommer le profil",
	["PR_PROFILEMANAGER_SEARCH_PROFILE"] = "Chercher profil",
	["PR_PROFILEMANAGER_SWITCH"] = "Choisir le profil",
	["PR_PROFILEMANAGER_TITLE"] = "Profils de personnages",
	["PR_PROFILES"] = "Profils",
	["PR_SLASH_EXAMPLE"] = "|cffffff00Utilisation de la commande:|r |cffcccccc/trp3 profile Millidan Hurlefromage|r |cffffff00pour utiliser le profil Millidan Hurlefromage.|r",
	["PR_SLASH_NOT_FOUND"] = "|cffff0000IAucun profil nommé|r |cffffff00%s|r|cffff0000 trouvé.|r",
	["PR_SLASH_OPEN_ABORTING"] = "|cffffff00Demande de profil abandonnée.|r",
	["PR_SLASH_OPEN_EXAMPLE"] = "|cffffff00Utilisation de la commande:|r |cffcccccc/trp3 open|r |cffffff00pour ouvrir le profil de la cible ou |cffcccccc/trp3 open NomDuPersonnage-NomDuServeur|r |cffffff00pour ouvrir le profil d'un personnage précis.|r",
	["PR_SLASH_OPEN_HELP"] = "Ouvre le profil d'un personnage via son nom ou la cible si aucun nom n'est indiqué.",
	["PR_SLASH_OPEN_WAITING"] = "|cffffff00Demande de profil envoyé, veuillez patienter...|r",
	["PR_SLASH_SWITCH_HELP"] = "Passer à un autre profil via son nom.",
	["PR_UNUSED_PROFILE"] = "Ce profil n'est actuellement lié à aucun personnage WoW.",
	["REG_CODE_INSERTION_WARNING"] = [=[Hola, doucement!

Il semblerait que vous ayez essayé d'insérer manuellement des codes non supportés dans votre profil Total RP 3.
Ce genre de modification n'est pas du tout supporté et nous vous décourageons fortement de le faire.
Cela peut créer des soucis de stabilité au sein de l'add-on, la corruption de vos données et la perte de vos profils, ou encore des soucis de compatibilité avec les autres add-ons RP (comme MRP).

Les codes que vous aviez insérés dans votre profil ont été retirés pour éviter que vous ne cassiez l'add-on.]=],
	["REG_COMPANION"] = "Compagnon",
	["REG_COMPANION_BIND_TO_PET"] = "Familier",
	["REG_COMPANION_BOUND_TO"] = "Lier à ...",
	["REG_COMPANION_BOUND_TO_TARGET"] = "Cible",
	["REG_COMPANION_BOUNDS"] = "Liens",
	["REG_COMPANION_BROWSER_BATTLE"] = "Navigateur de mascottes",
	["REG_COMPANION_BROWSER_MOUNT"] = "Navigateur de montures",
	["REG_COMPANION_INFO"] = "Informations",
	["REG_COMPANION_LINKED"] = "Le compagnon %s est maintenant lié au profil %s.",
	["REG_COMPANION_LINKED_NO"] = "Le compagnon %s n'est plus lié à un profil.",
	["REG_COMPANION_NAME"] = "Nom",
	["REG_COMPANION_NAME_COLOR"] = "Couleur du nom",
	["REG_COMPANION_PAGE_TUTO_C_1"] = "Consulter",
	["REG_COMPANION_PAGE_TUTO_E_1"] = [=[Ce sont |cff00ff00les informations principales de votre compagnon|r.

Toutes ces informations s'afficheront dans |cffff9900l'infobulle de votre compagnon|r.]=],
	["REG_COMPANION_PAGE_TUTO_E_2"] = [=[Ceci est |cff00ff00la description de votre compagnon|r.

Elle n'est pas limitée à sa |cffff9900description physique|r. N'hésitez pas à indiquer des parties de son |cffff9900histoire|r ou des détails sur sa |cffff9900personnalité|r.

Il y a de nombreux moyens pour personnaliser la description.
Vous pouvez choisir une |cffffff00texture d'arrière-plan|r pour la description. Vous pouvez aussi utiliser les outils de formatage pour accéder à plusieurs paramètres de mise en page, tels que |cffffff00les tailles de texte, les couleurs et les alignements|r.
Ces outils vous permettent aussi d'insérer |cffffff00 des images, des icônes ou un lien vers un site web externe|r.]=],
	["REG_COMPANION_PROFILES"] = "Profils de compagnons",
	["REG_COMPANION_TARGET_NO"] = "Votre cible n'est pas un familier, un démon, une goule, un élémentaire de mage ou une mascotte renommée.",
	["REG_COMPANION_TF_BOUND_TO"] = "Sélectionner un profil",
	["REG_COMPANION_TF_CREATE"] = "Créer un nouveau profil",
	["REG_COMPANION_TF_NO"] = "Pas de profil",
	["REG_COMPANION_TF_OPEN"] = "Ouvrir la page",
	["REG_COMPANION_TF_OWNER"] = "Maître : %s",
	["REG_COMPANION_TF_PROFILE"] = "Profil de compagnon",
	["REG_COMPANION_TF_PROFILE_MOUNT"] = "Profil de monture",
	["REG_COMPANION_TF_UNBOUND"] = "Délier le profil",
	["REG_COMPANION_TITLE"] = "Titre",
	["REG_COMPANION_UNBOUND"] = "Délier ...",
	["REG_COMPANIONS"] = "Compagnons",
	["REG_DELETE_WARNING"] = [=[Êtes-vous sûr de vouloir supprimer le profil de %s?
]=],
	["REG_IGNORE_TOAST"] = "Personnage ignoré",
	["REG_LIST_ACTIONS_MASS"] = "Action sur les %s profils sélectionnés",
	["REG_LIST_ACTIONS_MASS_IGNORE"] = "Ignorer les profils",
	["REG_LIST_ACTIONS_MASS_IGNORE_C"] = [=[Cette action ajoutera |cff00ff00%s personnage(s)|r à la liste des ignorés.

Vous pouvez optionnellement entrer la raison ci-dessous. C'est une note personnelle, elle servira comme rappel.]=],
	["REG_LIST_ACTIONS_MASS_REMOVE"] = "Supprimer les profils",
	["REG_LIST_ACTIONS_MASS_REMOVE_C"] = "Cette action supprimera les |cff00ff00%s profils sélectionnés|r.",
	["REG_LIST_ACTIONS_PURGE"] = "Purger le registre",
	["REG_LIST_ACTIONS_PURGE_ALL"] = "Supprimer tous les profils",
	["REG_LIST_ACTIONS_PURGE_ALL_C"] = [=[Cette purge supprimera tous les profils et les personnages auxquels ils sont liés du registre.

|cff00ff00%s personnages.]=],
	["REG_LIST_ACTIONS_PURGE_ALL_COMP_C"] = [=[Cette purge supprimera tous les compagnons du registre.

|cff00ff00%s compagnons.]=],
	["REG_LIST_ACTIONS_PURGE_COUNT"] = "%s profils seront supprimés.",
	["REG_LIST_ACTIONS_PURGE_EMPTY"] = "Pas de profil à purger.",
	["REG_LIST_ACTIONS_PURGE_IGNORE"] = "Profils de personnages ignorés",
	["REG_LIST_ACTIONS_PURGE_IGNORE_C"] = [=[Cette purge supprimera tous les profils liés à un personnage WoW ignoré.

|cff00ff00%s]=],
	["REG_LIST_ACTIONS_PURGE_TIME"] = "Profils non vus depuis 1 mois",
	["REG_LIST_ACTIONS_PURGE_TIME_C"] = [=[Cette purge supprimera tous les profils qui n'ont pas été vus depuis un mois.

|cff00ff00%s]=],
	["REG_LIST_ACTIONS_PURGE_UNLINKED"] = "Profils non-liés à un personnage",
	["REG_LIST_ACTIONS_PURGE_UNLINKED_C"] = [=[Cette purge supprimera tous les profils qui ne sont pas liés à un personnage WoW.

|cff00ff00%s]=],
	["REG_LIST_ADDON"] = "Type de profil",
	["REG_LIST_CHAR_EMPTY"] = "Aucun personnage",
	["REG_LIST_CHAR_EMPTY2"] = "Aucun personnage ne correspond à votre sélection",
	["REG_LIST_CHAR_FILTER"] = "Personnages: %s / %s",
	["REG_LIST_CHAR_IGNORED"] = "Ignoré",
	["REG_LIST_CHAR_NAME_COPY"] = "Copier nom de personnage",
	["REG_LIST_CHAR_SEL"] = "Personnage sélectionné",
	["REG_LIST_CHAR_TITLE"] = "Liste de personnages",
	["REG_LIST_CHAR_TT"] = "Cliquer pour afficher la page",
	["REG_LIST_CHAR_TT_CHAR"] = "Personnage(s) WoW lié(s):",
	["REG_LIST_CHAR_TT_CHAR_NO"] = "Non lié à un personnage",
	["REG_LIST_CHAR_TT_DATE"] = [=[Vu pour la dernière fois le: |cff00ff00%s|r
Vu pour la dernière fois à: |cff00ff00%s|r]=],
	["REG_LIST_CHAR_TT_GLANCE"] = "Coup d'œil",
	["REG_LIST_CHAR_TT_IGNORE"] = "Personnage(s) ignoré(s)",
	["REG_LIST_CHAR_TT_NEW_ABOUT"] = "Description non lue",
	["REG_LIST_CHAR_TT_RELATION"] = [=[Relation:
|cff00ff00%s]=],
	["REG_LIST_CHAR_TUTO_ACTIONS"] = "Cette colonne vous permet de sélectionner plusieurs personnages afin d'effectuer une action sur tous les personnages sélectionnés.",
	["REG_LIST_CHAR_TUTO_FILTER"] = [=[Vous pouvez filtrer la liste de personnages.

Le |cff00ff00filtre de nom|r permet de rechercher un personnage à partir du nom complet du profil (prénom + nom) mais aussi des personnages WoW liés.

Le |cff00ff00filtre de guilde|r permet de rechercher à partir du nom de la guilde des personnages WoW liés.

Le |cff00ff00filtre de royaume|r vous montrera uniquement les profils liés à un personnage WoW de votre royaume actuel.]=],
	["REG_LIST_CHAR_TUTO_LIST"] = [=[La première colonne affiche le nom du personnage.

La deuxième colonne affiche la relation entre ces personnages et votre personnage actuel.

La dernière colonne correspond aux différents marqueurs. (ignoré ..etc.)]=],
	["REG_LIST_FILTERS"] = "Filtres",
	["REG_LIST_FILTERS_TT"] = [=[|cffffff00Clic gauche:|r Appliquer les filtres
|cffffff00Clic droit:|r Effacer les filtres]=],
	["REG_LIST_FLAGS"] = "Marqueurs",
	["REG_LIST_GUILD"] = "Guilde du personnage",
	["REG_LIST_IGNORE_EMPTY"] = "Pas de personnage ignoré",
	["REG_LIST_IGNORE_TITLE"] = "Liste des ignorés",
	["REG_LIST_IGNORE_TT"] = [=[Raison:
|cff00ff00%s

|cffffff00Cliquer pour supprimer de la liste des ignorés]=],
	["REG_LIST_NAME"] = "Nom du personnage",
	["REG_LIST_NOTESONLY"] = "Avec notes uniquement",
	["REG_LIST_NOTIF_ADD"] = "Nouveau profil découvert pour |cff00ff00%s",
	["REG_LIST_NOTIF_ADD_CONFIG"] = "Nouveau profil découvert",
	["REG_LIST_NOTIF_ADD_NOT"] = "Ce profil n'existe plus.",
	["REG_LIST_PET_MASTER"] = "Nom du maître",
	["REG_LIST_PET_NAME"] = "Nom du compagnon",
	["REG_LIST_PET_TYPE"] = "Type du compagnon",
	["REG_LIST_PETS_EMPTY"] = "Aucun compagnon",
	["REG_LIST_PETS_EMPTY2"] = "Aucun compagnon ne correspond à votre sélection",
	["REG_LIST_PETS_FILTER"] = "Compagnons: %s / %s",
	["REG_LIST_PETS_TITLE"] = "Liste des compagnons",
	["REG_LIST_PETS_TOOLTIP"] = "A été vu le",
	["REG_LIST_PETS_TOOLTIP2"] = "A été vu avec",
	["REG_LIST_REALMONLY"] = "Ce royaume uniquement",
	["REG_LOCATION_DIFFERENT_WAR_MODE"] = "Mode Guerre différent du votre",
	["REG_MSP_ALERT"] = [=[|cffff0000ATTENTION

Vous ne pouvez avoir simultanément plus d'un addon utilisant le Mary Sue Protocol, car cela créerait un conflit.|r

Actuellement chargé: |cff00ff00%s

|cffff9900En conséquence, le support MSP pour Total RP3 sera désactivé.|r

Si vous ne souhaitez pas que TRP3 soit votre addon MSP et ne voulez plus voir cette alerte à nouveau, vous pouvez désactiver le module Mary Sue Protocol dans les paramètres TRP3 -> Statut des modules.]=],
	["REG_NOTES_PROFILE"] = "Notes",
	["REG_NOTES_PROFILE_TT"] = "Ouvre l'onglet de notes pour le personnage ciblé.",
	["REG_PLAYER"] = "Personnage",
	["REG_PLAYER_ABOUT"] = "À propos",
	["REG_PLAYER_ABOUT_ADD_FRAME"] = "Ajouter un cadre",
	["REG_PLAYER_ABOUT_EMPTY"] = "Aucune description",
	["REG_PLAYER_ABOUT_HEADER"] = "Tag de titre",
	["REG_PLAYER_ABOUT_MUSIC"] = "Thème du personnage",
	["REG_PLAYER_ABOUT_MUSIC_LISTEN"] = "Jouer le thème",
	["REG_PLAYER_ABOUT_MUSIC_REMOVE"] = "Désélectionner le thème",
	["REG_PLAYER_ABOUT_MUSIC_SELECT"] = "Choisir le thème du personnage",
	["REG_PLAYER_ABOUT_MUSIC_SELECT2"] = "Choisir le thème",
	["REG_PLAYER_ABOUT_MUSIC_STOP"] = "Arrêter le thème",
	["REG_PLAYER_ABOUT_MUSIC_THEME"] = "Thème musical du personnage",
	["REG_PLAYER_ABOUT_NOMUSIC"] = "|cffff9900Aucun thème",
	["REG_PLAYER_ABOUT_P"] = "Tag de paragraphe",
	["REG_PLAYER_ABOUT_REMOVE_FRAME"] = "Supprimer ce cadre",
	["REG_PLAYER_ABOUT_SOME"] = "Du texte ...",
	["REG_PLAYER_ABOUT_T1_YOURTEXT"] = "Votre texte ici",
	["REG_PLAYER_ABOUT_TAGS"] = "Outils de mise en page",
	["REG_PLAYER_ABOUT_UNMUSIC"] = "|cffff9900Thème inconnu",
	["REG_PLAYER_ABOUT_VOTE_DOWN"] = "Je n'aime pas ce contenu",
	["REG_PLAYER_ABOUT_VOTE_NO"] = [=[Aucun personnage lié à ce profil ne semble être connecté.
Voulez-vous forcer Total RP 3 à envoyer tout de même votre vote ?]=],
	["REG_PLAYER_ABOUT_VOTE_SENDING"] = "Envoi de votre vote à %s ...",
	["REG_PLAYER_ABOUT_VOTE_SENDING_OK"] = "Votre vote à été envoyé à %s !",
	["REG_PLAYER_ABOUT_VOTE_TT"] = "Votre vote est totalement anonyme et ne peut être vu que par ce joueur.",
	["REG_PLAYER_ABOUT_VOTE_TT2"] = "Vous ne pouvez voter que si le joueur est connecté.",
	["REG_PLAYER_ABOUT_VOTE_UP"] = "J'aime ce contenu",
	["REG_PLAYER_ABOUT_VOTES"] = "Statistiques",
	["REG_PLAYER_ABOUT_VOTES_R"] = [=[|cff00ff00%s aiment ce contenu
|cffff0000%s n'aiment pas ce contenu]=],
	["REG_PLAYER_ABOUTS"] = "À propos de %s",
	["REG_PLAYER_ADD_NEW"] = "Créer nouveau",
	["REG_PLAYER_AGE"] = "Âge",
	["REG_PLAYER_AGE_TT"] = [=[Vous indiquez ici l'âge de votre personnage.

Il y a plusieurs moyens de le faire:|c0000ff00
- Utiliser un nombre d'années,
- Ou un adjectif (Jeune, Mature, Adulte, Vénérable, etc.).]=],
	["REG_PLAYER_ALERT_HEAVY_SMALL"] = [=[|cffff0000La taille de votre profil est plutôt importante.
|cffff9900Vous devriez la réduire.]=],
	["REG_PLAYER_BIRTHPLACE"] = "Lieu de naissance",
	["REG_PLAYER_BIRTHPLACE_TT"] = [=[Vous pouvez indiquer ici le lieu de naissance de votre personnage. Cela peut être une région, une zone, ou même un continent. C'est à vous de décider la précision avec laquelle vous souhaitez l'indiquer.

|c00ffff00Vous pouvez utiliser le bouton à droite pour régler facilement votre position actuelle comme Lieu de naissance.]=],
	["REG_PLAYER_BKG"] = "Format d'arrière-plan",
	["REG_PLAYER_BKG_TT"] = "Cela représente l'arrière-plan graphique à utiliser pour votre panneau Caractéristiques",
	["REG_PLAYER_CARACT"] = "Caractéristiques",
	["REG_PLAYER_CHANGE_CONFIRM"] = [=[Il se peut que vous ayez effectué des changements non sauvegardés.
Voulez-vous changer de page ?
|cffff9900Tout changement non-sauvegardé sera perdu.]=],
	["REG_PLAYER_CHARACTERISTICS"] = "Caractéristiques",
	["REG_PLAYER_CLASS"] = "Classe",
	["REG_PLAYER_CLASS_TT"] = [=[Ceci est la classe personnalisée de votre personnage.

|cff00ff00Par exemple :|r
Chevalier, Pyrotechnicien, Nécromant, Tireur d'élite, Arcaniste ...]=],
	["REG_PLAYER_COLOR_ALWAYS_DEFAULT_TT"] = [=[|cffffff00Clic:|r Choisir une couleur
|cffffff00Clic-droit:|r Supprimer la couleur]=],
	["REG_PLAYER_COLOR_CLASS"] = "Couleur de classe",
	["REG_PLAYER_COLOR_CLASS_TT"] = [=[Cela déterminera aussi la couleur de votre nom.

]=],
	["REG_PLAYER_COLOR_TT"] = [=[|cffffff00Clic gauche:|r Sélectionner une couleur
|cffffff00Clic droit:|r Effacer la couleur]=],
	["REG_PLAYER_CURRENT"] = "Actuellement",
	["REG_COMPANIONS_SHORTDESCRIPTION"]= "Brève description",
	["REG_PLAYER_CURRENT_OOC"] = "Ceci est une information hors du personnage",
	["REG_PLAYER_CURRENTOOC"] = "Actuellement (HRP)",
	["REG_PLAYER_EDIT_MUSIC_THEME"] = "Thème musical",
	["REG_PLAYER_EYE"] = "Couleur des yeux",
	["REG_PLAYER_EYE_TT"] = [=[Vous pouvez indiquer ici la couleur des yeux de votre personnage.

Pensez bien que, même si le visage de votre personnage est constamment caché, il peut être utile de le mentionner, au cas où.]=],
	["REG_PLAYER_FIRSTNAME"] = "Prénom",
	["REG_PLAYER_FIRSTNAME_TT"] = [=[C'est le prénom de votre personnage. Ce champ est obligatoire, donc si vous ne spécifiez aucun nom, le nom du personnage par défaut (|cffffff00%s|r) sera utilisé.

Vous pouvez utiliser un |c0000ff00surnom |r!]=],
	["REG_PLAYER_FULLTITLE"] = "Titre complet",
	["REG_PLAYER_FULLTITLE_TT"] = [=[Vous pouvez indiquer ici le titre complet de votre personnage. Cela peut être une version plus longue du Titre ou un tout autre titre.

Cependant, vous devriez éviter les répétitions, s'il n'y a aucune information supplémentaire à mentionner.]=],
	["REG_PLAYER_GLANCE"] = "Coup d'œil",
	["REG_PLAYER_GLANCE_BAR_DELETED"] = "Le groupe d'emplacements |cffff9900%s|r a été supprimé.",
	["REG_PLAYER_GLANCE_BAR_EMPTY"] = "Le nom du groupe ne peut pas être vide.",
	["REG_PLAYER_GLANCE_BAR_LOAD"] = "Groupe d'emplacements",
	["REG_PLAYER_GLANCE_BAR_LOAD_SAVE"] = "Groupe d'emplacements",
	["REG_PLAYER_GLANCE_BAR_NAME"] = [=[Merci d'entrer le nom du groupe.

|cff00ff00Note: Si ce nom est déjà utilisé par un autre groupe, ce dernier sera remplacé.]=],
	["REG_PLAYER_GLANCE_BAR_SAVE"] = "Sauvegarder comme groupe",
	["REG_PLAYER_GLANCE_BAR_SAVED"] = "Le groupe d'emplacements |cff00ff00%s|r a été supprimé.",
	["REG_PLAYER_GLANCE_BAR_TARGET"] = "Groupe de \"Coup d’œil\"",
	["REG_PLAYER_GLANCE_CONFIG"] = [=[|cff00ff00"Coup d'œil"|r est un ensemble d'emplacements que vous pouvez utiliser pour définir des informations importantes à propos de ce personnage.

Vous pouvez utiliser ces actions sur les emplacements :
|cffffff00Clic gauche:|r Configurer l'emplacement
|cffffff00Clic droit:|r Charger/enregistrer un coup d'œil
|cffffff00Double-clic:|r Activer/Désactiver l'emplacement
|cffffff00Glisser-déposer:|r Réorganiser les emplacements]=],
	["REG_PLAYER_GLANCE_EDITOR"] = "Coup d'œil : Emplacement %s",
	["REG_PLAYER_GLANCE_MENU_COPY"] = "Copier le coup-d'œil",
	["REG_PLAYER_GLANCE_MENU_PASTE"] = "Coller le coup-d'œil: %s",
	["REG_PLAYER_GLANCE_PRESET"] = "Charger depuis ...",
	["REG_PLAYER_GLANCE_PRESET_ADD"] = "Modèle |cff00ff00%s|r créé.",
	["REG_PLAYER_GLANCE_PRESET_ALERT1"] = "Veuillez entrer une catégorie et un nom",
	["REG_PLAYER_GLANCE_PRESET_CATEGORY"] = "Catégorie",
	["REG_PLAYER_GLANCE_PRESET_CREATE"] = "Créer modèle",
	["REG_PLAYER_GLANCE_PRESET_GET_CAT"] = [=[%s

Merci d'entrer le nom de la catégorie pour ce modèle]=],
	["REG_PLAYER_GLANCE_PRESET_NAME"] = "Coup d'œil",
	["REG_PLAYER_GLANCE_PRESET_REMOVE"] = "Modèle |cff00ff00%s|r supprimé.",
	["REG_PLAYER_GLANCE_PRESET_SAVE"] = "Enregistrer le coup d'œil sous ...",
	["REG_PLAYER_GLANCE_PRESET_SAVE_SMALL"] = "Enregistrer",
	["REG_PLAYER_GLANCE_PRESET_SELECT"] = "Choisir un coup d'œil",
	["REG_PLAYER_GLANCE_TITLE"] = "Nom de l'attribut",
	["REG_PLAYER_GLANCE_UNUSED"] = "Emplacement inutilisé",
	["REG_PLAYER_GLANCE_USE"] = "Activer cet emplacement",
	["REG_PLAYER_HEIGHT"] = "Taille",
	["REG_PLAYER_HEIGHT_TT"] = [=[Il s'agit de la taille de votre personnage.
Il y a plusieurs manières de l'indiquer:|c0000ff00
- Un nombre précis: 170 cm, 6'5" ...
- Un qualificatif: Grand, petit ...]=],
	["REG_PLAYER_HERE"] = "Obtenir la position",
	["REG_PLAYER_HERE_HOME_PRE_TT"] = [=[Coordonnées actuelles:
|cff00ff00%s|r.]=],
	["REG_PLAYER_HERE_HOME_TT"] = [=[|cffffff00Clic|r: Utiliser la position actuelle comme coordonnées de résidence.
|cffffff00Clic-droit|r: Effacer les coordonnées de la résidence.]=],
	["REG_PLAYER_HERE_TT"] = "|cffffff00Clic|r: Obtenir votre position actuelle",
	["REG_PLAYER_HISTORY"] = "Histoire",
	["REG_PLAYER_ICON"] = "Icône du personnage",
	["REG_PLAYER_ICON_TT"] = "Sélectionne une représentation graphique pour votre personnage.",
	["REG_PLAYER_IGNORE"] = "Ignorer les personnages liés (%s)",
	["REG_PLAYER_IGNORE_WARNING"] = [=[Voulez-vous ignorer ces personnages ?

|cffff9900%s

|rVous pouvez optionnellement entrer la raison de cette action. Cette note est personnelle et vous servira de rappel.]=],
	["REG_PLAYER_LASTNAME"] = "Nom",
	["REG_PLAYER_LASTNAME_TT"] = "C'est le nom de famille de votre personnage.",
	["REG_PLAYER_LEFTTRAIT"] = "Attribut de gauche",
	["REG_PLAYER_MISC_ADD"] = "Ajouter un champ additionnel",
	["REG_PLAYER_MISC_PRESET_PRONOUNS"] = "Pronoms",
	["REG_PLAYER_MORE_INFO"] = "Informations additionnelles",
	["REG_PLAYER_MSP_HOUSE"] = "Maison",
	["REG_PLAYER_MSP_MOTTO"] = "Devise",
	["REG_PLAYER_MSP_NICK"] = "Surnom",
	["REG_PLAYER_NAMESTITLES"] = "Noms et titres",
	["REG_PLAYER_NO_CHAR"] = "Pas de caractéristiques",
	["REG_PLAYER_NOTES"] = "Notes",
	["REG_PLAYER_NOTES_ACCOUNT"] = "Notes communes",
	["REG_PLAYER_NOTES_ACCOUNT_HELP"] = "Ces notes privées sont liées à votre compte et seront partagées avec tous vos profils.",
	["REG_PLAYER_NOTES_PROFILE"] = "Notes de %s",
	["REG_PLAYER_NOTES_PROFILE_HELP"] = "Ces notes privées sont liées à votre profil actuel et changeront en fonction de votre profil actuel.",
	["REG_PLAYER_NOTES_PROFILE_NONAME"] = "Notes du profil",
	["REG_PLAYER_PEEK"] = "Divers",
	["REG_PLAYER_PHYSICAL"] = "Physique",
	["REG_PLAYER_PSYCHO"] = "Personnalité",
	["REG_PLAYER_PSYCHO_Acete"] = "Ascète",
	["REG_PLAYER_PSYCHO_ADD"] = "Ajouter un trait de personnalité",
	["REG_PLAYER_PSYCHO_ATTIBUTENAME_TT"] = "Nom de l'attribut",
	["REG_PLAYER_PSYCHO_Bonvivant"] = "Bon vivant",
	["REG_PLAYER_PSYCHO_CHAOTIC"] = "Chaotique",
	["REG_PLAYER_PSYCHO_Chaste"] = "Chaste",
	["REG_PLAYER_PSYCHO_Conciliant"] = "Parangon",
	["REG_PLAYER_PSYCHO_Couard"] = "Couard",
	["REG_PLAYER_PSYCHO_CREATENEW"] = "Créer un trait",
	["REG_PLAYER_PSYCHO_Cruel"] = "Brutal",
	["REG_PLAYER_PSYCHO_CUSTOM"] = "Trait personnalisé",
	["REG_PLAYER_PSYCHO_CUSTOMCOLOR"] = "Choisir une couleur pour l'attribut",
	["REG_PLAYER_PSYCHO_CUSTOMCOLOR_LEFT_TT"] = [=[Choisir une couleur à utiliser pour la barre de l'attribut de gauche.

|cffffff00Clic:|r Chosir une couleur
|cffffff00Clic droit:|r Supprimer la couleur
|cffffff00Maj-Clic:|r Utiliser le sélecteur de couleur du jeu]=],
	["REG_PLAYER_PSYCHO_CUSTOMCOLOR_RIGHT_TT"] = [=[Choisir une couleur à utiliser pour la barre de l'attribut de droite.

|cffffff00Clic:|r Chosir une couleur
|cffffff00Clic droit:|r Supprimer la couleur
|cffffff00Maj-Clic:|r Utiliser le sélecteur de couleur du jeu]=],
	["REG_PLAYER_PSYCHO_Egoiste"] = "Egoïste",
	["REG_PLAYER_PSYCHO_Genereux"] = "Altruiste",
	["REG_PLAYER_PSYCHO_Impulsif"] = "Impulsif",
	["REG_PLAYER_PSYCHO_Indulgent"] = "Indulgent",
	["REG_PLAYER_PSYCHO_LEFTICON_TT"] = "Régler l'icône d'attribut de gauche",
	["REG_PLAYER_PSYCHO_Loyal"] = "Loyal",
	["REG_PLAYER_PSYCHO_Luxurieux"] = "Luxurieux",
	["REG_PLAYER_PSYCHO_Misericordieux"] = "Miséricordieux",
	["REG_PLAYER_PSYCHO_MORE"] = "Ajouter un point à \"%s\"",
	["REG_PLAYER_PSYCHO_PERSONAL"] = "Traits personnels",
	["REG_PLAYER_PSYCHO_Pieux"] = "Pieux",
	["REG_PLAYER_PSYCHO_POINT"] = "Ajouter un point",
	["REG_PLAYER_PSYCHO_Pragmatique"] = "Pragmatique",
	["REG_PLAYER_PSYCHO_Rationnel"] = "Rationnel",
	["REG_PLAYER_PSYCHO_Reflechi"] = "Réfléchi",
	["REG_PLAYER_PSYCHO_Rencunier"] = "Rancunier",
	["REG_PLAYER_PSYCHO_RIGHTICON_TT"] = "Régler l'icône de l'attribut de droite.",
	["REG_PLAYER_PSYCHO_Sincere"] = "Sincère",
	["REG_PLAYER_PSYCHO_SOCIAL"] = "Traits sociaux",
	["REG_PLAYER_PSYCHO_Trompeur"] = "Trompeur",
	["REG_PLAYER_PSYCHO_Valeureux"] = "Valeureux",
	["REG_PLAYER_RACE"] = "Race",
	["REG_PLAYER_RACE_TT"] = "Il s'agit de la race de votre personnage. Il n'est pas nécessaire de se restreindre aux races jouables. Il y a de nombreuses races de Warcraft qui peuvent posséder des formes communes ...",
	["REG_PLAYER_REGISTER"] = "Informations du registre",
	["REG_PLAYER_RELATIONSHIP_STATUS"] = "Situation amoureuse",
	["REG_PLAYER_RELATIONSHIP_STATUS_DIVORCED"] = "Divorcé(e)",
	["REG_PLAYER_RELATIONSHIP_STATUS_MARRIED"] = "Marié(e)",
	["REG_PLAYER_RELATIONSHIP_STATUS_SINGLE"] = "Célibataire",
	["REG_PLAYER_RELATIONSHIP_STATUS_TAKEN"] = "En couple",
	["REG_PLAYER_RELATIONSHIP_STATUS_TT"] = "Indique la situation amoureuse de votre personnage. Sélectionnez \"Ne pas afficher\" si vous désirez garder cette information confidentielle.",
	["REG_PLAYER_RELATIONSHIP_STATUS_UNKNOWN"] = "Ne pas afficher",
	["REG_PLAYER_RELATIONSHIP_STATUS_WIDOWED"] = "Veuf/Veuve",
	["REG_PLAYER_RESIDENCE"] = "Lieu de résidence",
	["REG_PLAYER_RESIDENCE_SHOW"] = "Coordonnées de résidence",
	["REG_PLAYER_RESIDENCE_SHOW_TT"] = [=[|cff00ff00%s

|rClic pour afficher sur la carte]=],
	["REG_PLAYER_RESIDENCE_TT"] = [=[Vous pouvez indiquer ici où votre personnage vit en temps normal. Il peut s'agir de son adresse personnelle (sa maison) ou un endroit où il séjourne.
Notez que si votre personnage est un voyageur ou encore un sans-domicile, vous devrez changer l'information en accord avec cela.

|c00ffff00Vous pouvez utiliser le bouton à droite pour définir facilement votre position actuelle comme Lieu de résidence.]=],
	["REG_PLAYER_RIGHTTRAIT"] = "Attribut de droite",
	["REG_PLAYER_SHOWMISC"] = "Afficher le panneau \"Divers\"",
	["REG_PLAYER_SHOWMISC_TT"] = [=[Cochez si vous désirez afficher des champs personnalisés pour votre personnage.

Si vous ne désirez pas afficher de champs personnalisés, laissez ce bouton décoché et le panneau "Divers" restera complètement caché.]=],
	["REG_PLAYER_SHOWPSYCHO"] = "Afficher le panneau de personnalité",
	["REG_PLAYER_SHOWPSYCHO_TT"] = [=[Cochez si vous désirez utiliser la description de personnalité.

Si vous ne voulez pas indiquer la personnalité de votre personnage ainsi, laissez ce bouton décoché et le panneau de personnalité restera complètement caché.]=],
	["REG_PLAYER_STYLE_ASSIST"] = "Aide au jeu de rôle",
	["REG_PLAYER_STYLE_BATTLE"] = "Résolution de combats RP",
	["REG_PLAYER_STYLE_BATTLE_1"] = "JcJ World of Warcraft",
	["REG_PLAYER_STYLE_BATTLE_2"] = "Bataille de jets de dés TRP",
	["REG_PLAYER_STYLE_BATTLE_3"] = "Bataille de /rand",
	["REG_PLAYER_STYLE_BATTLE_4"] = "Bataille d'émotes",
	["REG_PLAYER_STYLE_DEATH"] = "Accepte la mort",
	["REG_PLAYER_STYLE_EMPTY"] = "Pas d'attribut de jeu de rôle partagé",
	["REG_PLAYER_STYLE_FREQ"] = "Fréquence de jeu en RP",
	["REG_PLAYER_STYLE_FREQ_1"] = "Plein temps",
	["REG_PLAYER_STYLE_FREQ_2"] = "La plupart du temps",
	["REG_PLAYER_STYLE_FREQ_3"] = "La moitié du temps",
	["REG_PLAYER_STYLE_FREQ_4"] = "De temps en temps",
	["REG_PLAYER_STYLE_FREQ_5"] = "Pas un personnage RP",
	["REG_PLAYER_STYLE_GUILD"] = "Appartenance à la guilde",
	["REG_PLAYER_STYLE_GUILD_IC"] = "Membre RP",
	["REG_PLAYER_STYLE_GUILD_OOC"] = "Membre HRP",
	["REG_PLAYER_STYLE_HIDE"] = "Ne pas afficher",
	["REG_PLAYER_STYLE_INJURY"] = "Accepte les blessures",
	["REG_PLAYER_STYLE_PERMI"] = "Avec permission du joueur",
	["REG_PLAYER_STYLE_ROMANCE"] = "Accepte la romance",
	["REG_PLAYER_STYLE_RPSTYLE"] = "Style de roleplay",
	["REG_PLAYER_STYLE_RPSTYLE_SHORT"] = "Style de RP",
	["REG_PLAYER_STYLE_WOWXP"] = "Expérience de World of Warcraft",
	["REG_PLAYER_TITLE"] = "Titre",
	["REG_PLAYER_TITLE_TT"] = [=[Le titre de votre personnage est le titre par lequel votre personnage est habituellement appelé. Evitez les titres longs, l'attribut de Titre complet y est consacré.

Exemple de |c0000ff00titres appropriés |r:
|c0000ff00- Comtesse,
- Marquis,
- Magus,
- Seigneur,
- etc.
|rExemple of |cffff0000titres inappropriés|r:
|cffff0000- Comtesse des Marches du Nord,
- Magus de la Tour de Hurlevent,
- Diplomate pour le Gouvernement Draenei,
- etc.]=],
	["REG_PLAYER_TRP2_PIERCING"] = "Piercings",
	["REG_PLAYER_TRP2_TATTOO"] = "Tatouages",
	["REG_PLAYER_TRP2_TRAITS"] = "Traits du visage",
	["REG_PLAYER_TUTO_ABOUT_COMMON"] = [=[|cff00ff00Thème de personnage:|r
Vous pouvez choisir un |cffffff00thème|r pour votre personnage. Pensez-y comme une |cffffff00musique d'ambiance pour lire la description de votre personnage|r.

|cff00ff00Arrière-plan:|r
Ceci est une |cffffff00texture d'arrière-plan|r pour la description de votre personnage.

|cff00ff00Modèle:|r
Le modèle choisi définit |cffffff00le format général et les possibilités d'écriture|r de votre description.
|cffff9900Seul le modèle sélectionné est visible par les autres, vous n'avez donc pas à tous les remplir.|r
Une fois qu'un modèle est choisi, vous pouvez rouvrir ce tutoriel pour avoir plus d'aide à propos de chaque modèle.]=],
	["REG_PLAYER_TUTO_ABOUT_MISC_1"] = [=[Cette section vous fournit des |cffffff005 emplacements|r dans lesquels vous pouvez décrire |cff00ff00les informations les plus importantes à propos de votre personnage|r.

Ces informations seront visibles sur la |cffffff00barre "Coup d'œil"|r lorsque quelqu'un sélectionne votre personnage.

|cff00ff00Astuce: Vous pouvez glisser et déposer les emplacements pour les réorganiser.|r
Cela marche aussi sur la |cffffff00barre "Coup d'œil"|r!]=],
	["REG_PLAYER_TUTO_ABOUT_MISC_3"] = "Cette section fournit |cffffff00une liste d'indicateurs|r pour répondre à beaucoup de |cffffff00questions usuelles que les joueurs peuvent vous demander à propos de vous, votre personnage, et la manière dont vous souhaitez le jouer|r.",
	["REG_PLAYER_TUTO_ABOUT_T1"] = [=[Ce modèle vous permet de |cff00ff00structurer librement votre description|r.

La description n'a pas besoin d'être limitée uniquement à la |cffff9900description physique|r de votre personnage. N'hésitez pas à indiquer des parties de son |cffff9900histoire|r ou des détails sur sa |cffff9900personnalité|r.

Avec ce modèle vous pouvez aussi utiliser les outils de formatage pour accéder à plusieurs paramètres de mise en page tels que |cffffff00les tailles de texte, les couleurs, ou les alignements|r.
Ces outils vous permettent aussi d'insérer |cffffff00des images, des icônes ou des liens vers des sites web externes|r.]=],
	["REG_PLAYER_TUTO_ABOUT_T2"] = [=[Ce modèle est plus structuré et consiste en |cff00ff00une liste de cadres indépendants|r.

Chaque cadre est caractérisé par une |cffffff00icône, un arrière-plan et un texte|r. Notez que vous pouvez utiliser quelques balises de texte dans ces cadres, comme celles de couleur, ou d'icônes.

La description n'a pas besoin d'être limitée uniquement à la |cffff9900description physique|r de votre personnage. N'hésitez pas à indiquer des parties de son |cffff9900histoire|r ou des détails sur sa |cffff9900personnalité|r.]=],
	["REG_PLAYER_TUTO_ABOUT_T3"] = [=[Ce modèle est découpé en 3 sections: |cff00ff00Description physique, personnalité et histoire|r.

Vous n'avez pas à remplir tous les cadres, |cffff9900Si vous laissez un cadre vide, il ne sera pas affiché sur votre description|r.

Chaque cadre est caractérisé par une |cffffff00icône, un arrière-plan et un texte|r. Notez que vous pouvez utiliser quelques balises de texte dans ces cadres, comme celles de couleur, ou d'icônes.]=],
	["REG_PLAYER_WEIGHT"] = "Stature",
	["REG_PLAYER_WEIGHT_TT"] = [=[Il s'agit de la stature de votre personnage.
Il pourrait par exemple être |c0000ff00mince, gros ou musclé...|r Ou tout simplement être dans la norme !]=],
	["REG_PLAYERS"] = "Joueurs",
	["REG_REGISTER"] = "Registre",
	["REG_REGISTER_CHAR_LIST"] = "Liste de personnages",
	["REG_RELATION"] = "Relation",
	["REG_RELATION_BUSINESS"] = "Commerce",
	["REG_RELATION_BUSINESS_TT"] = "%s et %s sont dans une relation d'affaires.",
	["REG_RELATION_BUTTON_TT"] = [=[Relation: %s
|cff00ff00%s

|cffffff00Cliquer pour afficher les actions possibles]=],
	["REG_RELATION_FAMILY"] = "Famille",
	["REG_RELATION_FAMILY_TT"] = "%s partage des liens du sang avec %s.",
	["REG_RELATION_FRIEND"] = "Amical",
	["REG_RELATION_FRIEND_TT"] = "%s considère %s comme un ami.",
	["REG_RELATION_LOVE"] = "Amour",
	["REG_RELATION_LOVE_TT"] = "%s est amoureux de %s !",
	["REG_RELATION_NEUTRAL"] = "Neutre",
	["REG_RELATION_NEUTRAL_TT"] = "%s n'a pas d'affection particulière pour %s.",
	["REG_RELATION_NONE"] = "Aucune",
	["REG_RELATION_NONE_TT"] = "%s ne connaît pas %s.",
	["REG_RELATION_TARGET"] = "|cffffff00Clic gauche: |rChanger la relation",
	["REG_RELATION_UNFRIENDLY"] = "Hostile",
	["REG_RELATION_UNFRIENDLY_TT"] = "%s n'aime vraiment pas %s.",
	["REG_REPORT_PLAYER_OPEN_URL"] = [=[Vous pouvez uniquement signaler les joueurs en jeu depuis la barre de ciblage de Total RP 3, via le bouton de signalement.

Si vous souhaitez signaler le profil de %s comme enfreignant le Code de Conduite et ne pouvez pas cibler ce joueur, vous devez ouvrir un ticket avec l'assistance de Blizzard en utilisant le lien ci-dessous.]=],
	["REG_REPORT_PLAYER_OPEN_URL_160"] = "Si vous souhaitez signaler le profil de %s comme enfreignant le Code de Conduite, vous devez ouvrir un ticket avec l'assistance de Blizzard en utilisant le lien ci-dessous.",
	["REG_REPORT_PLAYER_PROFILE"] = "Signaler ce profil à |cff449fe0Blizzard|r",
	["REG_REPORT_PLAYER_PROFILE_TT"] = [=[Vous pouvez signaler un profil qui enfreint les conditions d'utilisation de Blizzard. Cela inclut le harcèlement, partage de données privées, incitation à la haine, contenu obscène ou autre forme de contenu perturbant.

|cffff0000Veuillez noter que cette fonctionnalité n'est PAS pour signaler des profils RP qui vous semblent de faible qualité ou pour chercher à nuire à un joueur. Tout abus de cette fonctionnalité pourrait entraîner des sanctions.]=],
	["REG_REPORT_PLAYER_TEMPLATE"] = "Ce joueur utilise l'addon RP %s pour partager du contenu allant à l'encontre du Code de Conduite.",
	["REG_REPORT_PLAYER_TEMPLATE_DATE"] = "Les données de l'addon ont été transférées via messages loggés le %s.",
	["REG_REPORT_PLAYER_TEMPLATE_TRIAL_ACCOUNT"] = "Ce joueur utilisait un compte d'essai.",
	["REG_TIME"] = "Vu pour la dernière fois",
	["REG_TRIAL_ACCOUNT"] = "Compte d'essai",
	["REG_TT_GUILD"] = "%s de |cffff9900%s",
	["REG_TT_GUILD_IC"] = "membre RP",
	["REG_TT_GUILD_OOC"] = "membre HRP",
	["REG_TT_IGNORED"] = "< Le personnage est ignoré >",
	["REG_TT_IGNORED_OWNER"] = "< Le propriétaire est ignoré >",
	["REG_TT_LEVEL"] = "Niveau %s %s",
	["REG_TT_NOTIF"] = "Description non-lue",
	["REG_TT_REALM"] = "Royaume: |cffff9900%s",
	["REG_TT_TARGET"] = "Cible: |cffff9900%s",
	["REG_TT_ZONE"] = "Zone",
	["SCRIPT_ERROR"] = "Erreur dans le script.",
	["SCRIPT_UNKNOWN_EFFECT"] = "Erreur dans le script, effet inconnu.",
	["SLASH_CMD_STATUS_HELP"] = [=[Usage: |cff00ff00/trp3 status ic || ooc || toggle|r
Change le statut de votre personnage en fonction de l'option spécifiée:

|cffff9900/trp3 status ic|r met votre personnage en |cff00ff00RP|r.
|cffff9900/trp3 status ooc|r met votre personnage en |cffff0000HRP|r.
|cffff9900/trp3 status toggle|r change votre statut pour le statut opposé.]=],
	["SLASH_CMD_STATUS_USAGE"] = "ic || ooc || toggle",
	["TB_AFK_MODE"] = "Absent",
	["TB_DND_MODE"] = "Ne pas déranger",
	["TB_GO_TO_MODE"] = "Passer en mode %s",
	["TB_LANGUAGE"] = "Langage",
	["TB_LANGUAGES_TT"] = "Changer de langage",
	["TB_NORMAL_MODE"] = "Normal",
	["TB_RPSTATUS_OFF"] = "Personnage: |cffff0000Hors du personnage",
	["TB_RPSTATUS_ON"] = "Personnage: |cff00ff00Dans le personnage",
	["TB_RPSTATUS_TO_OFF"] = "Passer |cffff0000hors du personnage",
	["TB_RPSTATUS_TO_ON"] = "Passer |cff00ff00dans le personnage",
	["TB_STATUS"] = "Joueur",
	["TB_SWITCH_CAPE_1"] = "Afficher la cape",
	["TB_SWITCH_CAPE_2"] = "Masquer la cape",
	["TB_SWITCH_CAPE_OFF"] = "Cape: |cffff0000Masquée",
	["TB_SWITCH_CAPE_ON"] = "Cape: |cffff0000Affichée",
	["TB_SWITCH_HELM_1"] = "Afficher le casque",
	["TB_SWITCH_HELM_2"] = "Masquer le casque",
	["TB_SWITCH_HELM_OFF"] = "Casque: |cffff0000Masqué",
	["TB_SWITCH_HELM_ON"] = "Casque: |cffff0000Affiché",
	["TB_SWITCH_PROFILE"] = "Passer à un autre profil",
	["TB_SWITCH_TOOLBAR"] = "Afficher/masquer la barre d'outils",
	["TB_TOOLBAR"] = "Barre d'outils",
	["TF_IGNORE"] = "Ignorer le joueur",
	["TF_IGNORE_CONFIRM"] = [=[Êtes-vous sûr de vouloir ignorer ce joueur ?

|cffffff00%s|r

|cffff7700Vous pouvez entrer optionnellement la raison d'ignorer le joueur ci-dessous. C'est une note personnelle, elle ne sera vue par personne d'autre et servira de rappel.]=],
	["TF_IGNORE_NO_REASON"] = "Aucune raison",
	["TF_IGNORE_TT"] = "|cffffff00Clic gauche:|r Ignorer le joueur",
	["TF_OPEN_CHARACTER"] = "Afficher la fiche du personnage",
	["TF_OPEN_COMPANION"] = "Afficher la fiche du familier",
	["TF_OPEN_MOUNT"] = "Afficher la fiche de la monture",
	["TF_PLAY_THEME"] = "Jouer le thème du personnage",
	["TF_PLAY_THEME_TT"] = [=[|cffffff00Clic gauche:|r Jouer |cff00ff00%s
|cffffff00Clic droit:|r Arrêter le thème]=],
	["THANK_YOU_1"] = [=[{h1:c}Total RP 3{/h1}
{p:c}{col:6eff51}Version %s (build %s){/col}{/p}
{p:c}{link*http://totalrp3.info*TotalRP3.info} — {twitter*TotalRP3*@TotalRP3} {/p}

{h2}{icon:INV_Eng_gizmo1:20} Créé par{/h2}
- Morgane "{twitter*EllypseCelwe*Ellypse}" Parize
- Sylvain "{twitter*Telkostrasz*Telkostrasz}" Cossement

{h2}{icon:QUEST_KHADGAR:20} Le reste de l'équipe{/h2}
- Connor "{twitter*Saelorable*Sælorable}" Macleod (Contributeur)
- {twitter*Solanya_*Solanya} (Community Manager)

{h2}{icon:THUMBUP:20} Remerciements{/h2}
{col:ffffff}Les logos et icône de la carte ont été réalisés par:{/col}
- {link*https://twitter.com/Kelandiir*@Kelandiir}

{col:ffffff}Notre équipe de test:{/col}
- Erzan
- Calian
- Kharess
- Alnih
- 611

{col:ffffff}Merci à tous nos amis pour leur soutien:{/col}
- Pour Telkos: Kharess, Kathryl, Marud, Solona, Stretcher, Lisma...
- Pour Ellypse: Les guildes Église du Saint Gamon, Maison Celwë'Belore, Mercenaires Atal'ai, et plus particulièrement Erzan, Elenna, Caleb, Siana and Adaeria

{col:ffffff}Pour nous avoir aidés à créer la guilde Total RP sur Kirin Tor (EU):{/col}
- Azane
- Hellclaw
- Leylou

{col:ffffff}Merci à Horionne pour nous avoir envoyé son exemplaire du Gamer Culte Online #14 qui contient un article sur Total RP.{/col}]=],
	["THANK_YOU_ROLE_AUTHOR"] = "Créateur",
	["THANK_YOU_ROLE_COMMUNITY_MANAGER"] = "Community Manager",
	["THANK_YOU_ROLE_CONTRIBUTOR"] = "Contributeur",
	["THANK_YOU_ROLE_GUILD_MEMBER"] = "Membre de guilde",
	["THANK_YOU_ROLE_TESTER"] = "Testeurs",
	["TT_ELVUI_SKIN"] = "Apparence ElvUI",
	["TT_ELVUI_SKIN_ENABLE_TARGET_FRAME"] = "Apparence du cadre de cible",
	["TT_ELVUI_SKIN_ENABLE_TOOLTIPS"] = "Apparence des infobulles",
	["UI_BKG"] = "Arrière-plan %s",
	["UI_CLOSE_ALL"] = "Fermer tout",
	["UI_COLOR_BROWSER"] = "Sélecteur de couleur",
	["UI_COLOR_BROWSER_PRESETS"] = "Prédéfinies",
	["UI_COLOR_BROWSER_PRESETS_BASIC"] = "Couleurs de base",
	["UI_COLOR_BROWSER_PRESETS_CLASSES"] = "Classes",
	["UI_COLOR_BROWSER_PRESETS_CUSTOM"] = "Personnalisées",
	["UI_COLOR_BROWSER_PRESETS_ITEMS"] = "Qualités d'objet",
	["UI_COLOR_BROWSER_PRESETS_RESOURCES"] = "Ressources",
	["UI_COLOR_BROWSER_SELECT"] = "Choisir une couleur",
	["UI_COMPANION_BROWSER_HELP"] = "Sélectionner une mascotte",
	["UI_COMPANION_BROWSER_HELP_TT"] = [=[|cffffff00Attention: |rSeules les mascottes renommées peuvent être associées à un profil.

|cff00ff00Cette section ne liste que ces mascottes.]=],
	["UI_FILTER"] = "Filtre",
	["UI_ICON_BROWSER"] = "Navigateur d'icônes",
	["UI_ICON_BROWSER_HELP"] = "Copier l'icône",
	["UI_ICON_BROWSER_HELP_TT"] = [=[Tant que cette fenêtre est ouverte, vous pouvez |cffffff00CTRL + cliquer|r sur une icône pour copier son nom.

Disponible pour:|cff00ff00
- Un objet de votre sac
- Un sort du grimoire|r]=],
	["UI_ICON_SELECT"] = "Choisir une icône",
	["UI_IMAGE_BROWSER"] = "Navigateur d'images",
	["UI_IMAGE_SELECT"] = "Choisir une image",
	["UI_LINK_SAFE"] = "Voici l'URL du lien.",
	["UI_LINK_TEXT"] = "Votre texte ici",
	["UI_LINK_URL"] = "http://votre.url.ici",
	["UI_LINK_WARNING"] = [=[Voici l'URL du lien.
Vous pouvez le copier-coller dans votre navigateur web.

|cffff0000!! Attention !!|r
Total RP n'est pas responsable du contenu des liens partagés.]=],
	["UI_MUSIC_ALTTITLE"] = "Titre alternatif",
	["UI_MUSIC_BROWSER"] = "Navigateur de musiques",
	["UI_MUSIC_DURATION"] = "Durée",
	["UI_MUSIC_SELECT"] = "Choisir une musique",
	["UI_PET_BROWSER_ACCEPT"] = "Assigner",
	["UI_PET_BROWSER_BOUND_WARNING"] = "|cffff0000Attention: |rCe familier est actuellement assigné au profil |cff00ff00%1$s|r. Assigner un profil à ce familier remplacera le profil actuel.",
	["UI_PET_BROWSER_EMPTY_TEXT"] = "Vous n'avez pas de familier pouvant être associé à ce profil.",
	["UI_PET_BROWSER_INTRO_TEXT"] = "Sélectionnez un familier avec les boutons ci-dessous et cliquez |cffffff00Assigner|r pour le lier au profil.",
	["UI_PET_BROWSER_NAME_WARNING"] = "|cffff0000Attention: |rCe familier n'a pas été renommé. Il est recommandé de renommer le familier pour éviter d'afficher ce profil sur les autres familiers que vous possédez partageant le même nom.",
	["UI_TUTO_BUTTON"] = "Mode tutoriel",
	["UI_TUTO_BUTTON_TT"] = "Cliquer pour afficher ou masquer le mode tutoriel",
	["UNIT_POPUPS_CHARACTER_STATUS"] = "Statut de personnage",
	["UNIT_POPUPS_CONFIG_DISABLE_IN_COMBAT"] = "Désactiver les éléments de menu en combat",
	["UNIT_POPUPS_CONFIG_DISABLE_IN_COMBAT_HELP"] = "Si coché, les éléments de menu additionnels ne seront pas affichés en combat.",
	["UNIT_POPUPS_CONFIG_DISABLE_IN_INSTANCES"] = "Désactiver les éléments de menu en instance",
	["UNIT_POPUPS_CONFIG_DISABLE_IN_INSTANCES_HELP"] = "Si coché, les éléments de menu additionnels ne seront pas affichés en instance.",
	["UNIT_POPUPS_CONFIG_DISABLE_ON_UNIT_FRAMES"] = "Désactiver les éléments de menu sur les portraits d'unités",
	["UNIT_POPUPS_CONFIG_DISABLE_ON_UNIT_FRAMES_HELP"] = "Si coché, les éléments de menu additionnels ne seront pas affichés dans les menus activés au clic-droit sur les portraits d'unités.",
	["UNIT_POPUPS_CONFIG_DISABLE_OUT_OF_CHARACTER"] = "Désactiver les éléments de menu quand HRP",
	["UNIT_POPUPS_CONFIG_DISABLE_OUT_OF_CHARACTER_HELP"] = "Si coché, les éléments de menu additionnels ne seront pas affichés quand vous êtes HRP.",
	["UNIT_POPUPS_CONFIG_ENABLE_MODULE"] = "Module |cff00ff00activé|r",
	["UNIT_POPUPS_CONFIG_ENTRIES_HEADER"] = "Eléments de menu",
	["UNIT_POPUPS_CONFIG_MENU_TITLE"] = "Paramètres de menu",
	["UNIT_POPUPS_CONFIG_PAGE_HELP"] = "Le module de menus d'unités ajoute des éléments additionnels aux menus de clic-droit sur les portraits d'unités et les noms dans la fenêtre de discussion.",
	["UNIT_POPUPS_CONFIG_PAGE_TEXT"] = "Paramètres de menu",
	["UNIT_POPUPS_CONFIG_SHOW_CHARACTER_STATUS"] = "Afficher le bouton de statut de personnage",
	["UNIT_POPUPS_CONFIG_SHOW_CHARACTER_STATUS_HELP"] = "Si coché, ajoute une case à cocher au menu de votre propre portrait d'unité vous permettant de changer votre statut RP/HRP.",
	["UNIT_POPUPS_CONFIG_SHOW_HEADER_TEXT"] = "Afficher l'entête",
	["UNIT_POPUPS_CONFIG_SHOW_HEADER_TEXT_HELP"] = "Si coché, affiche un entête \"Options roleplay\" au-dessus des éléments de menu ajoutés.",
	["UNIT_POPUPS_CONFIG_SHOW_OPEN_PROFILE"] = "Afficher bouton ouverture de profil",
	["UNIT_POPUPS_CONFIG_SHOW_OPEN_PROFILE_HELP"] = "Si coché, ajoute un bouton qui ouvre le profil RP de l'unité sélectionnée.|n|nCette option sera visible sur tous les menus de portraits d'unités et de fenêtre de discussion.",
	["UNIT_POPUPS_CONFIG_SHOW_SEPARATOR"] = "Afficher séparateur",
	["UNIT_POPUPS_CONFIG_SHOW_SEPARATOR_HELP"] = "Si coché, affiche une barre de séparation au dessus des éléments de menu ajoutés.",
	["UNIT_POPUPS_CONFIG_VISIBILITY_HEADER"] = "Options de visibilité",
	["UNIT_POPUPS_CURRENT_PROFILE"] = "Profil actuel",
	["UNIT_POPUPS_CURRENT_PROFILE_NAME"] = "Profil actuel: %1$s",
	["UNIT_POPUPS_MODULE_DESCRIPTION"] = "Ajoute l'intégration aux menus de clic-droit sur les portraits d'unités et les noms de joueurs dans les fenêtres de discussion.",
	["UNIT_POPUPS_MODULE_DISABLE_WARNING"] = "L'interface devra être rechargée pour désactiver le module de menus d'unités.|n|n|cffff0000Attention: |rUne fois désactivé, ce module ne peut être réactivé que via l'onglet de |cffffcc00Statut des modules|r.|n|nVoulez-vous vraiment désactiver ce module ?",
	["UNIT_POPUPS_MODULE_NAME"] = "Menus d'unités",
	["UNIT_POPUPS_OPEN_PROFILE"] = "Ouvrir profil",
	["UNIT_POPUPS_ASSIGN_FLAG"] = "Attribuer un profil",
	["UNIT_POPUPS_ROLEPLAY_OPTIONS_HEADER"] = "Options roleplay",
	["WHATS_NEW_23"] = [=[# Liste des changements de la version 1.6.0

## Notes personnelles

Vous pouvez désormais prendre des notes personnelles depuis l'addon !

Ces notes peuvent être écrites sur votre propre profil (si vous désirez prendre des notes génériques pour votre personnage), ou sur le profil de quelqu'un d'autre (le champ supérieur étant lié à votre profil actuel, le champ inférieur étant commun à tous vos profils). Ces notes sont privées, personne d'autre que vous ne peut les voir.

{img:Interface\AddOns\totalRP3\resources\160-1.tga:480:480}

Pour accéder aux notes personnelles, cliquez simplement sur le nouveau bouton Notes sur la fenêtre de cible, ou ouvrez un profil et cliquez sur l'onglet Notes.

{img:Interface\AddOns\totalRP3\resources\160-2.tga:240:120}

Le registre a aussi reçu une option pour n'afficher que les profils pour lesquels vous avez écrit des notes.

{img:Interface\AddOns\totalRP3\resources\160-3.tga:480:120}

## Ajouté

- Ajout du format HTML pour les modèles 2 et 3 de l'onglet À propos. Vous pouvez désormais utiliser l'ensemble des balises lorsque vous utilisez ces modèles pour formatter leurs champs, en utilisant la barre d'outils désormais visible pour tous les modèles.

{img:Interface\AddOns\totalRP3\resources\160-4.tga:480:480}

- Ajout de la compatibilité avec d'autres addons RP pour les traits de personnalité et les balises HTML.

## Modifié

- Les boutons "Signaler un profil" renvoient désormais tous vers le [site d'assistance de Blizzard](https://battle.net/support/help/product/wow/197/1501/solution), la fonctionnalité de signalement en jeu précédemment ajoutée n'étant pas une méthode valide pour signaler l'abus par addon. La fenêtre affiche toujours une date et heure de réception du profil que vous pouvez fournir au service client de Blizzard afin de les aider à identifier l'offense.

## Corrigé

- Correction d'une erreur pouvant empêcher l'addon de charger.
- Correction d'une erreur de compatibilité pour le modèle 3 si la langue de l'addon n'était pas anglaise.

## Supprimé

- Suppression de la sélection automatique du texte complet après un clic dans une zone de texte (champs À propos, Actuellement, Informations HRP...)
- Suppression du code pour le poisson d'avril (RP.IO ainsi que les noms arc-en-ciel de compagnons accidentellement oubliés l'an dernier).]=],
	["WHATS_NEW_23_1"] = [=[# Liste des changements de la version 1.6.1

## Refonte du système de musiques

- Des changements techniques du patch 8.2 ont requis de modifier la manière de gérer la musique dans l'addon. **Ceci signifie que la mise à jour est nécessaire pour pouvoir jouer des musiques dans l'addon.** Ce changement devrait être invisible et rétrocompatible (les thèmes musicaux de profils provenant de versions antérieures devraient pouvoir être jouer sans problème).
- Ceci a permis l'ajout de musiques précédemment indisponibles (*fait signe aux musiques des elfes du vide*).
- La durée de toutes les musiques est désormais visible dans l'infobulle au survol d'une musique dans la liste.

## Modifié

- Les réglages pour augmenter le contraste des couleurs dans les infobulles et la fenêtre de discussion ont été consolidés en un seul réglage dans les paramètres généraux. Ce réglage s'applique dans des endroits supplémentaires, comme les infobulles du scan sur la carte.

## Corrigé

- L'ancrage pour le bouton de scan de la carte peut désormais être réglé correctement.
- Correction d'un échange de titres de menu déroulants pour les titres/paragraphes.
- Correction d'un message d'erreur pouvant être causé par d'autres addons utilisant mal certains fonctions de l'API de WoW.]=],
	["WHATS_NEW_23_10"] = [=[# Liste des changements de la version 1.6.10

## Ajouté

- Ajout de balises de discussion %xt and %xf. Ceux-ci seront automatiquement remplacés par le nom RP de votre cible et focalisation respectivement lorsque vous envoyez un message.
- Ajout de paramètres pour ajuster la taille des textes dans l'onglet A propos.

]=],
	["WHATS_NEW_23_2"] = [=[# Liste des changements de la version 1.6.2

## Ajouté

- Ajout de 328 icônes et 20 images du patch 8.2.
- Ajout d'un indicateur au navigateur de musiques lorsque le nom par défaut d'une musique diffère du nom correspondant au filtre actuel.

## Corrigé

- Correction de problèmes dans l'échange de données de musique entre TRP3 et MRP.=
- Correction d'une duplication de lines dans l'infobulle du bouton de scan de la carte.
- Corrections additionnelles potentielles au problème lié à la carte du monde à la connexion.]=],
	["WHATS_NEW_23_4"] = [=[# Liste des changements de la version 1.6.4

Nous sommes au courant d'un bug depuis le patch 8.2 bloquant parfois **l'utilisation des objets de quête depuis la liste d'objectifs**. Nous n'avons pas encore de correctif, mais **vous pouvez taper /reload lorsque le message d'erreur apparaît** pour corriger temporairement le problème. Nos excuses pour le désagrément.

## Support pour WoW: Classic

- Total RP 3: Classic est désormais disponible en téléchargement séparé sur CurseForge et WoWInterface ! Assurez-vous d'installer cette version à la place de la version standard de Total RP 3 si vous prévoyez de faire du jeu de rôle sur WoW: Classic.
- Les points importants à noter pour la version Classic :
  - Quelques icônes ont été changées dans l'addon pour remplacer des icônes manquantes dans Classic.
  - Les profils pour montures et familiers pacifiques ont été désactivés, Blizzard ne nous ayant pas fourni d'accès à la beta. Nous les réimplémenterons dès que possible.
  - Total RP 3: Extended ne sera pas porté pour Classic à sa sortie. Nous évaluerons à l'avenir l'intérêt d'un portage.

## Modifié

- Lors d'un scan de personnages sur la carte, les personnages avec lesquels vous avez une relation apparaîtront désormais au-dessus des autres.]=],
	["WHATS_NEW_23_6"] = [=[
# Liste des changements de la version 1.6.6

## Ajouté

- Ajout de commandes pour changer votre statut roleplay, utilisables dans des macros. Vous pouvez désormais utiliser `/trp3 status ic` pour passer RP, `/trp3 status ooc` pour passer HRP, ou `/trp3 status toggle` pour inverser votre statut.
- Ajout d'un paramètre de discussion pour afficher un indicateur HRP à côté du nom dans la fenêtre de discussion.
- Ajout d'un paramètre pour cacher de bouton de scan de la carte si aucun scan n'est disponible.
- Ajout d'un champ de langage de jeu de rôle sur la fenêtre principale.
  - Ce paramètre est défini par profil, choisit le langage de l'addon par défaut, et vous permet d'indiquer la langage dans lequel vous effectuez du jeu de rôle.
  - Si le langage de votre addon ne correspond pas au langage de jeu de rôle d'un autre joueur, un drapeau en bas de l'infobulle indique leur langage de jeu de rôle.
  - Ce changement est principalement destiné aux rôlistes sur Classic, du fait de l'absence de serveurs RP non-anglais.
- Ajout de boutons pour changer l'affichage des casques et capes pour Classic.

## Modifié

- Le paramètre de mode de guerre a été renommé pour Classic pour référencer le mode PvP.

## Corrigé

- Correction de problèmes lorsque le module de fenêtre de cible était désactivé.
- Correction d'un bug causant l'apparition de profils Mary-Sue Protocol en double dans le registre en désélectionnant "Ce royaume uniquement".
- Correction de quelques icônes manquantes sur Classic (icônes par défaut du modèle 3, icônes pour `/trp3 roll`)
- Correction d'un bug avec l'utilisation du paramètre "Clic droit pour ouvrir un profil" sur Classic.

]=],
	["WHATS_NEW_23_7"] = [=[# Liste des changements de la version 1.6.7

## Ajouté

- Ajout d'un paramètre de détection de dialogue dans les emotes pour les colorer automatiquement.
- Ajout de 7 icones et 1 musique du patch 8.2.5.

## Modifié

- La liste de profils de compagnons accessible via la fenêtre de cible est désormais triée par ordre alphabétique, et "Créer nouveau profil" a été déplacé hors de cette liste.]=],
	["WHATS_NEW_23_9"] = [=[# Liste des changements de la version 1.6.9

## Ajouté

- Ajout de 61 musiques, 5 images et 223 icones sur Retail du patch 8.3.
- Ajout de 177 images sur Retail de patchs précédents.
- Ajout d'une icone sur Classic du patch 1.13.3.
- Ajout des icones par défaut pour Vulpérins et Mécagnomes.

## Modifié

- L'icone par défaut pour les Kul Tirans femelles a été modifiée.

## Corrigé

- Le scan de personnages sur Classic a été modifié pour pallier au manque de tests de Blizzard.
- Correction d'un souci lors de l'utilisation d'une icone avec une apostrophe dans le nom.
- Le filtre du navigateur d'images gère désormais correctement certains caractères spéciaux.]=]
}

TRP3_API.loc:RegisterNewLocale("frFR", "Français", localeContent);

localeContent = {
	["ABOUT_TITLE"] = "Acerca de",
	["BINDING_NAME_TRP3_OPEN_TARGET_PROFILE"] = "Abrir perfil del objetivo",
	["BINDING_NAME_TRP3_TOGGLE"] = "Mostrar/ocultar la ventana principal",
	["BINDING_NAME_TRP3_TOGGLE_CHARACTER_STATUS"] = "Mostrar/ocultar estado del personaje",
	["BINDING_NAME_TRP3_TOOLBAR_TOGGLE"] = "Mostrar/ocultar barra de herramientas",
	["BLIZZARD_NAMEPLATES_MODULE_DESCRIPTION"] = "Habilitar la personalización de las placas de nombres por defecto de Blizzard.",
	["BLIZZARD_NAMEPLATES_MODULE_NAME"] = "Placa de nombres de Blizzard",
	["BROADCAST_10"] = "|cffff9900Ya estás en 10 canales. TRP3 no intentará conectar de nuevo con el canal de emisión pero no podrás usar algunas características como la localización de jugadores en el mapa.",
	["BROADCAST_OFFLINE_DISABLED"] = "La emisión ha sido deshabilitada.",
	["BROADCAST_PASSWORD"] = [=[|cffff0000Hay una contraseña para el canal de emisión (%s).
|cffff9900TRP3 no intentará conectarse de nuevo pero no podrás usar algunas características como la localización de jugadores en el mapa.
|cff00ff00Puedes deshabilitar o cambiar de canal de emisión en la configuración general de TRP3.]=],
	["BROADCAST_PASSWORDED"] = [=[|cffff0000El usuario |r%s|cffff0000 ha puesto contraseña para el canal de emisión (%s).
|cffff9900Si no conoces la contraseña, no podrás usar algunas características como la localización de personajes en el mapa.]=],
	["BW_COLOR_CODE"] = "Código de color",
	["BW_COLOR_CODE_ALERT"] = "¡Código hexadecimal erróneo!",
	["BW_COLOR_CODE_TT"] = "Pega un código hexadecimal de 6 cifras aquí y presiona Enter.",
	["BW_COLOR_PRESET_DELETE"] = "Borrar %s preestablecido",
	["BW_COLOR_PRESET_RENAME"] = "Renombrar %s preestablecido",
	["BW_COLOR_PRESET_SAVE"] = "Guardar color actual",
	["BW_COLOR_PRESET_TITLE"] = "Colores preestablecidos",
	["BW_CUSTOM_NAME"] = "Color del nombre personalizado",
	["BW_CUSTOM_NAME_TITLE"] = "Nombre (Opcional)",
	["BW_CUSTOM_NAME_TT"] = "Puedes poner un nombre para el color personalizado que vas a guardar. Si se deja vacío, se usará el código hexadecimal para el color.",
	["CL_COMPANION_PROFILE"] = "Perfil del compañero",
	["CL_CONTENT_SIZE"] = "Tamaño: %s",
	["CL_DIRECTORY_COMPANION_PROFILE"] = "Directorio de perfiles de compañero",
	["CL_DIRECTORY_PLAYER_PROFILE"] = "Directorio de perfiles de jugador",
	["CL_DOWNLOADING"] = "Descargando: %0.1f %%",
	["CL_EXPIRED"] = "Este enlace ha caducado.",
	["CL_GLANCE"] = "A primera vista",
	["CL_IMPORT_COMPANION"] = "Importar perfil de compañero",
	["CL_IMPORT_GLANCE"] = "Importar a primera vista",
	["CL_IMPORT_PROFILE"] = "Importar perfil",
	["CL_MAKE_IMPORTABLE"] = [=[Estás a punto de crear un link a un/a %s.

¿Quieres hacer este link importable por otros jugadores? Serán capaces de copiar y usar el contenido del link.

Si respondes no, sólo serán capaces de consultar el contenido del link.]=],
	["CL_MAKE_IMPORTABLE_BUTTON_TEXT"] = "Hacer importable",
	["CL_MAKE_IMPORTABLE_SIMPLER"] = [=[¿Hacer el enlace %s importable?

Otros podrán copiar y usar el contenido del enlace.]=],
	["CL_MAKE_NON_IMPORTABLE"] = "Ver solo",
	["CL_OPEN_COMPANION"] = "Abrir perfil del compañero.",
	["CL_OPEN_PROFILE"] = "Abrir perfil",
	["CL_PLAYER_PROFILE"] = "Perfil de jugador",
	["CL_REQUESTING_DATA"] = "Solicitando datos del link de %s.",
	["CL_SENDING_COMMAND"] = "Enviando comando...",
	["CL_SENT_BY"] = "Enlace enviado por: %s",
	["CL_TOOLTIP"] = "Crear un enlace de chat",
	["CL_TYPE"] = "Tipo de enlace TRP3: %s",
	["CL_VERSIONS_DIFFER"] = [=[Este link se ha generado usando una versión diferente de Total RP 3.

Importar contenido de otra versión puede causar problemas en caso de incompatibilidaes. ¿Quieres proceder aún así?]=],
	["CM_ACTIONS"] = "Acciones",
	["CM_ALT"] = "Alt",
	["CM_APPLY"] = "Aplicar",
	["CM_BLACK"] = "Negro",
	["CM_BLUE"] = "Azul",
	["CM_CANCEL"] = "Cancelar",
	["CM_CENTER"] = "Centro",
	["CM_CLASS_DEATHKNIGHT"] = "Caballero de la muerte",
	["CM_CLASS_DEMONHUNTER"] = "Cazador de demonios",
	["CM_CLASS_DRUID"] = "Druida",
	["CM_CLASS_HUNTER"] = "Cazador",
	["CM_CLASS_MAGE"] = "Mago",
	["CM_CLASS_MONK"] = "Monje",
	["CM_CLASS_PALADIN"] = "Paladín",
	["CM_CLASS_PRIEST"] = "Sacerdote",
	["CM_CLASS_ROGUE"] = "Pícaro",
	["CM_CLASS_SHAMAN"] = "Chamán",
	["CM_CLASS_UNKNOWN"] = "Desconocido",
	["CM_CLASS_WARLOCK"] = "Brujo",
	["CM_CLASS_WARRIOR"] = "Guerrero",
	["CM_CLICK"] = "Click",
	["CM_COLOR"] = "Color",
	["CM_CTRL"] = "Ctrl",
	["CM_CYAN"] = "Cian",
	["CM_DELETE"] = "Borrar",
	["CM_DOUBLECLICK"] = "Doble click",
	["CM_DRAGDROP"] = "Arrastrar y soltar",
	["CM_EDIT"] = "Editar",
	["CM_GREEN"] = "Verde",
	["CM_GREY"] = "Gris",
	["CM_IC"] = "IC",
	["CM_ICON"] = "Icono",
	["CM_IMAGE"] = "Imagen",
	["CM_L_CLICK"] = "Click izquierdo",
	["CM_LEFT"] = "Izquierda",
	["CM_LINK"] = "Enlace",
	["CM_LOAD"] = "Cargar",
	["CM_M_CLICK"] = "Click botón central",
	["CM_MOVE_DOWN"] = "Mover hacia abajo",
	["CM_MOVE_UP"] = "Mover hacia arriba",
	["CM_NAME"] = "Nombre",
	["CM_OOC"] = "FdR",
	["CM_OPEN"] = "Abrir",
	["CM_ORANGE"] = "Naranja",
	["CM_PINK"] = "Rosa",
	["CM_PLAY"] = "Reproducir",
	["CM_PURPLE"] = "Morado",
	["CM_R_CLICK"] = "Click derecho",
	["CM_RED"] = "Rojo",
	["CM_REMOVE"] = "Suprimir",
	["CM_RESET"] = "Reiniciar",
	["CM_RESIZE"] = "Redimensionar",
	["CM_RESIZE_TT"] = "Arrastra para redimensionar la ventana.",
	["CM_RIGHT"] = "Derecha",
	["CM_SAVE"] = "Guardar",
	["CM_SELECT"] = "Seleccionar",
	["CM_SHIFT"] = "Shift",
	["CM_SHOW"] = "Mostrar",
	["CM_STOP"] = "Parar",
	["CM_TWEET"] = "Enviar un tweet",
	["CM_TWEET_PROFILE"] = "Mostrar url del perfil",
	["CM_UNKNOWN"] = "Desconocido",
	["CM_VALUE"] = "Valor",
	["CM_WHITE"] = "Blanco",
	["CM_YELLOW"] = "Amarillo",
	["CO_ADVANCED_BROADCAST"] = "Comunicaciones del add-on",
	["CO_ADVANCED_BROADCAST_CHANNEL_ALWAYS_LAST"] = "Mantener el canal de emisión al final",
	["CO_ADVANCED_BROADCAST_CHANNEL_ALWAYS_LAST_TT"] = "Esta opción hará que el canal de emisión siempre sea el último en tu lista de canales.",
	["CO_ADVANCED_LANGUAGE_WORKAROUND"] = "Habilitar solución al reinicio de idiomas",
	["CO_ADVANCED_LANGUAGE_WORKAROUND_TT"] = "Desde el parche 8.0.1, el juego reiniciará el idioma seleccionado al idioma por defecto de tu facción durante cada pantalla de carga. Esta solución se asegura de restaurar el idioma seleccionado tras cada pantalla de carga.",
	["CO_ADVANCED_LANGUAGES"] = "Idiomas",
	["CO_ADVANCED_LANGUAGES_REMEMBER"] = "Recordar último idioma usado",
	["CO_ADVANCED_LANGUAGES_REMEMBER_TT"] = "Total RP 3 recordará el último idioma que estabas usando antes de desconectar y lo seleccionará automáticamente en tu próxima conexión.",
	["CO_ADVANCED_SETTINGS"] = "Configuración avanzada",
	["CO_ADVANCED_SETTINGS_MENU_NAME"] = "Avanzado",
	["CO_ADVANCED_SETTINGS_POPUP"] = [=[Acabas de modificar una configuración avanzada.

Por favor, ten en cuenta que cambiar esta configuración puede alterar tu experiencia con el add-on y podría hacer que algunas características no funcionen del todo bien. Úsalo bajo tu responsabilidad.]=],
	["CO_ADVANCED_SETTINGS_RESET"] = "Reiniciar configuración avanzada",
	["CO_ADVANCED_SETTINGS_RESET_TT"] = "Reinicia toda la configuración avanzada a sus valores por defecto. Usa esto si tienes problemas tras modificar la configuración.",
	["CO_ANCHOR_BOTTOM"] = "Abajo",
	["CO_ANCHOR_BOTTOM_LEFT"] = "Abajo a la izquierda",
	["CO_ANCHOR_BOTTOM_RIGHT"] = "Abajo a la derecha",
	["CO_ANCHOR_CURSOR"] = "Mostrar en el cursor",
	["CO_ANCHOR_LEFT"] = "Izquierda",
	["CO_ANCHOR_RIGHT"] = "Derecha",
	["CO_ANCHOR_TOP"] = "Parte superior",
	["CO_ANCHOR_TOP_LEFT"] = "Parte superior izquierda",
	["CO_ANCHOR_TOP_RIGHT"] = "Parte superior derecha",
	["CO_CHAT"] = "Ajustes del chat",
	["CO_CHAT_DISABLE_OOC"] = "Deshabilitar personalizaciones cuando se está FDP",
	["CO_CHAT_DISABLE_OOC_TT"] = "Deshabilita todas las personalizaciones de chat del Total RP 3 (nombres personalizados, detección de emotes, diálogos de NPC, etc.) cuando tu personaje está puesto como Fuera de Personaje.",
	["CO_CHAT_INCREASE_CONTRAST"] = "Aumentar contraste de color",
	["CO_CHAT_INSERT_FULL_RP_NAME"] = "Insertar nombres de rol con shift+clic",
	["CO_CHAT_INSERT_FULL_RP_NAME_TT"] = [=[Insertar el nombre completo de rol de un jugador cuando se haga shift+clic en su nombre en la ventana de chat.

(Cuando se habilita esta opción, puedes hacer alt-shift-clic en un nombre cuando quieras que haga lo habitual e inserte el nombre del personaje en lugar del nombre completo de rol.)]=],
	["CO_CHAT_MAIN"] = "Ajustes de chat principal",
	["CO_CHAT_MAIN_COLOR"] = "Usar colores personalizados para los nombres",
	["CO_CHAT_MAIN_EMOTE"] = "Detección de emociones",
	["CO_CHAT_MAIN_EMOTE_PATTERN"] = "Patrón de detección de emociones",
	["CO_CHAT_MAIN_EMOTE_USE"] = "Usar detección de emociones",
	["CO_CHAT_MAIN_EMOTE_YELL"] = "Emoción sin gritos",
	["CO_CHAT_MAIN_EMOTE_YELL_TT"] = "No mostrar *emote* o <emote> en los gitos",
	["CO_CHAT_MAIN_NAMING"] = "Método de nomenclatura",
	["CO_CHAT_MAIN_NAMING_1"] = "Mantener nombres originales",
	["CO_CHAT_MAIN_NAMING_2"] = "Usar nombres originales",
	["CO_CHAT_MAIN_NAMING_3"] = "Nombre + apellido",
	["CO_CHAT_MAIN_NAMING_4"] = "Título corto + nombre + apellido",
	["CO_CHAT_MAIN_NPC"] = "Detección de diálogo de NPC",
	["CO_CHAT_MAIN_NPC_PREFIX"] = "Patrón de detección de diálogo de NPC",
	["CO_CHAT_MAIN_NPC_PREFIX_TT"] = [=[Si un mensaje enviado por el canal /EMOTE comienza con este prefijo, se interpretará como un diálogo de NPC.

|cff00ff00Por defecto: "|| "
(Sin el " y con un espacio después del I)]=],
	["CO_CHAT_MAIN_NPC_USE"] = "Usar detección de diálogo de NPC",
	["CO_CHAT_MAIN_OOC"] = "Detección OOC",
	["CO_CHAT_MAIN_OOC_COLOR"] = "Color OOC",
	["CO_CHAT_MAIN_OOC_PATTERN"] = "Patrón de detección OOC",
	["CO_CHAT_MAIN_OOC_USE"] = "Usar detección OOC",
	["CO_CHAT_MAIN_SPEECH"] = "Detección de voz",
	["CO_CHAT_MAIN_SPEECH_USE"] = "Usar detección de voz",
	["CO_CHAT_MAIN_SPEECH_USE_TT"] = "El texto entre comillas se mostrará con el color como si se hubiera escrito con /decir.",
	["CO_CHAT_NPCSPEECH_REPLACEMENT"] = "Personalizar nombres de compañero en conversaciones de NPC",
	["CO_CHAT_NPCSPEECH_REPLACEMENT_TT"] = "Si el nombre de un compañero está entre paréntesis en la conversación de un NPC se coloreará, y su icono se mostrará dependiendo de los ajustes anteriores.",
	["CO_CHAT_REMOVE_REALM"] = "Quitar reino de los nombres de los jugadores",
	["CO_CHAT_SHOW_OOC"] = "Mostrar el indicador FDP",
	["CO_CHAT_USE"] = "Canales de chat usados",
	["CO_CHAT_USE_ICONS"] = "Mostrar iconos de los jugadores",
	["CO_CHAT_USE_SAY"] = "Canal /decir",
	["CO_CONFIGURATION"] = "Ajustes",
	["CO_CURSOR_DISABLE_OOC"] = "Desactivado mientras se esta OOC",
	["CO_CURSOR_DISABLE_OOC_TT"] = "Deshabilitar modificaciones de cursor cuando tu status de rol está |cffccccccOut Of Character|r.",
	["CO_CURSOR_MODIFIER_KEY"] = "Tecla modificar",
	["CO_CURSOR_MODIFIER_KEY_TT"] = "Requiere mantener presionada una tecla modificar mientras se hace clic derecho a un jugador, para prevenir clics accidentales.",
	["CO_CURSOR_RIGHT_CLICK"] = "Clic derecho para abrir el perfil",
	["CO_CURSOR_RIGHT_CLICK_TT"] = [=[Clic derecho en un jugador en el mundo 3D para abrir su perfil, si tiene uno.

|TInterface\Cursor\WorkOrders:25|t Este icono se añadirá al cursor cuando un jugador tiene un perfil y puedes hacer clic derecho sobre él.

|cffccccccNota: Esta característica está deshabilitada durante el combate.|r]=],
	["CO_CURSOR_TITLE"] = "Interacciones del cursor",
	["CO_GENERAL"] = "Ajustes generales",
	["CO_GENERAL_BROADCAST"] = "Usar canal de emisión",
	["CO_GENERAL_BROADCAST_C"] = "Nombre del canal de emisión",
	["CO_GENERAL_BROADCAST_TT"] = "El canal de emisión se usa para una serie de características. Desactivarlo deshabilita características como la ubicación en el mapa, sonidos difundidos a nivel local, el acceso a escondrijos y carteles...",
	["CO_GENERAL_CHANGELOCALE_ALERT"] = [=[¿Quieres volver a cargar la interfaz para cambiar el idioma a %s ahora?

Si no, el idioma será cambiado en la próxima conexión.]=],
	["CO_GENERAL_COM"] = "Comunicación",
	["CO_GENERAL_DEFAULT_COLOR_PICKER"] = "Selector de color por defecto",
	["CO_GENERAL_DEFAULT_COLOR_PICKER_TT"] = "Activar para usar siempre el selector de color por defecto. Útil si estás usando un addon selector de color.",
	["CO_GENERAL_HEAVY"] = "Alerta de perfil sobrecargado",
	["CO_GENERAL_HEAVY_TT"] = "Ser avisado cuando el tamaño del perfil exceda un valor razonable.",
	["CO_GENERAL_LOCALE"] = "Idioma",
	["CO_GENERAL_MISC"] = "Miscelánea",
	["CO_GENERAL_NEW_VERSION"] = "Alerta de actualización",
	["CO_GENERAL_NEW_VERSION_TT"] = "Ser avisado cuando haya una nueva versión disponible.",
	["CO_GENERAL_RESET_CUSTOM_COLORS"] = "Resetear colores personalizados",
	["CO_GENERAL_RESET_CUSTOM_COLORS_TT"] = "Elimina todos los colores personalizados en el selector de color.",
	["CO_GENERAL_RESET_CUSTOM_COLORS_WARNING"] = "¿Seguro que quieres eliminar todos los colores personalizados en el selector de color?",
	["CO_GENERAL_TT_SIZE"] = "Información sobre herramientas del tamaño del texto",
	["CO_GENERAL_UI_ANIMATIONS"] = "Animaciones de la IU",
	["CO_GENERAL_UI_ANIMATIONS_TT"] = "Activar las animaciones de la IU.",
	["CO_GENERAL_UI_SOUNDS"] = "Sonidos de la IU.",
	["CO_GENERAL_UI_SOUNDS_TT"] = "Activar sonidos de la IU (al abrir ventanas, cambiar de pestañas, pulsar botones).",
	["CO_GLANCE_LOCK"] = "Anclar barra",
	["CO_GLANCE_LOCK_TT"] = "Ancla la barra para evitar que sea arrastrada.",
	["CO_GLANCE_MAIN"] = "Barra \"a primera vista\"",
	["CO_GLANCE_PRESET_TRP2"] = "Usar el estilo de posiciones del Total RP 2",
	["CO_GLANCE_PRESET_TRP2_BUTTON"] = "Usar",
	["CO_GLANCE_PRESET_TRP2_HELP"] = "Acceso directo de configuración en el estilo TRP2: a la derecha del marco de objetivo del WoW.",
	["CO_GLANCE_PRESET_TRP3"] = "Usar el estilo de posiciones del Total RP 3",
	["CO_GLANCE_PRESET_TRP3_HELP"] = "Acceso directo a la configuración del estilo TRP3: a la parte inferior del marco de objetivo del TRP3.",
	["CO_GLANCE_RESET_TT"] = "Cambiar la posición a la parte inferior izquierda de la barra del marco de anclaje.",
	["CO_GLANCE_TT_ANCHOR"] = "Punto de anclaje",
	["CO_HIDE_EMPTY_MAP_BUTTON"] = "Ocultar cuando no haya escaneos disponibles",
	["CO_LOCATION"] = "Ajustes de rastreo",
	["CO_LOCATION_ACTIVATE"] = "Habilitar la localización de personaje",
	["CO_LOCATION_ACTIVATE_TT"] = "Habilitar el sistema de localización de personaje te permite buscar a otros usuarios de Total RP en el mapa del mundo, permitiéndote localizarles.",
	["CO_LOCATION_DISABLE_CLASSIC_PVP"] = "Deshabilitar la localización cuando estás marcado para JcJ",
	["CO_LOCATION_DISABLE_CLASSIC_PVP_TT"] = "No vas a poder ser localizado por otros jugadores cuando estás marcado para JcJ. Esta opción es particularmente útil para evadir abusos del sistema de localización para perseguirte.",
	["CO_LOCATION_DISABLE_OOC"] = "Desactivar rastreo en modo FdR",
	["CO_LOCATION_DISABLE_OOC_TT"] = "No aparecerás en la solicitud de localización de otros personajes cuando estés Fuera de Personaje.",
	["CO_LOCATION_DISABLE_PVP"] = "Desactivar rastreo en modo JcJ",
	["CO_LOCATION_DISABLE_PVP_TT"] = [=[No aparecerás en la solicitud de localización de otros personajes cuando estés con el JcJ activado.

Esta opción es útil en los reinos JcJ donde los jugadores de la facción contraria pueden usar este sistema para localizarte.]=],
	["CO_LOCATION_DISABLE_WAR_MODE"] = "Deshabilitar ubicación en Modo de Guerra",
	["CO_LOCATION_DISABLE_WAR_MODE_TT"] = [=[No aparecerás en la solicitud de localización de otros personajes cuando hayas activado el Modo Guerra y estés fuera de un |cff69CCF0santuario|r.

Esta opción es útil para evitar abusos del sistema por parte de otros jugadores para rastrearte.]=],
	["CO_LOCATION_SHOW_DIFFERENT_WAR_MODES"] = "Mostrar jugadores en diferente Modo de Guerra",
	["CO_LOCATION_SHOW_DIFFERENT_WAR_MODES_TT"] = "Los jugadores que están en la zona pero tienen un estado diferente del Modo de Guerra aparecerán en el mapa, con menos opacidad y un icono especial en la herramienta.",
	["CO_MAP_BUTTON"] = "Botón de escaneo de mapa",
	["CO_MAP_BUTTON_POS"] = "Anclar el botón de escaneo en el mapa",
	["CO_MINIMAP_BUTTON"] = "Botón del minimapa",
	["CO_MINIMAP_BUTTON_FRAME"] = "Marco de anclaje",
	["CO_MINIMAP_BUTTON_RESET"] = "Restablecer la posición",
	["CO_MINIMAP_BUTTON_RESET_BUTTON"] = "Restablecer",
	["CO_MINIMAP_BUTTON_SHOW_HELP"] = [=[Si estás usando otro addon para mostrar el icono en el minimapa del Total RP 3 (FuBar, Titan, Bazooka) puedes quitar el botón del minimapa.

|cff00ff00Recordatorio : Puedes abrir Total RP 3 usando /trp3 switch main|r]=],
	["CO_MINIMAP_BUTTON_SHOW_TITLE"] = "Mostrar botón en el minimapa",
	["CO_MODULES"] = "Estado de los módulos",
	["CO_MODULES_DISABLE"] = "Deshabilitar módulos",
	["CO_MODULES_ENABLE"] = "Habilitar módulo",
	["CO_MODULES_ID"] = "ID del módulo: %s",
	["CO_MODULES_SHOWERROR"] = "Mostrar error",
	["CO_MODULES_STATUS"] = "Estado: %s",
	["CO_MODULES_STATUS_0"] = "Dependencias faltantes",
	["CO_MODULES_STATUS_1"] = "Cargado",
	["CO_MODULES_STATUS_2"] = "Deshabilitado",
	["CO_MODULES_STATUS_3"] = "Se requiere actualización de Total RP 3",
	["CO_MODULES_STATUS_4"] = "Error en la inicialización",
	["CO_MODULES_STATUS_5"] = "Error en el inicio%sPara Total RP 3 build %s mínima.|r",
	["CO_MODULES_TT_DEP"] = "%s-%s (versión %s)|r",
	["CO_MODULES_TT_DEPS"] = "Dependencias",
	["CO_MODULES_TT_ERROR"] = [=[|cffff0000Error:|r
%s]=],
	["CO_MODULES_TT_NONE"] = "No hay dependencias",
	["CO_MODULES_TT_TRP"] = "%sPara Total RP 3 build %s mínima.|r",
	["CO_MODULES_TUTO"] = [=[Un módulo es una característica independiente que puede habilitarse o deshabilitarse.

Posibles estados:
|cff00ff00Cargado:|r El módulo está habilitado y cargado.
|cff999999Deshabilitado:|r El módulo está deshabilitado.
|cffff9900Faltan dependencias:|r Algunas dependencias no se cargaron.
|cffff9900Actualización de TRP necesaria:|r El módulo necesita una versión más reciente de TRP3.
|cffff0000Error en la inicialización o en el inicio:|r La secuencia de carga del módulo ha fallado. ¡Es probable que el módulo crea errores!

|cffff9900Al desactivar un módulo, es necesario un reinicio de interfaz de usuario.]=],
	["CO_MODULES_VERSION"] = "Versión: %s",
	["CO_MSP"] = "Protocolo Mary Sue",
	["CO_MSP_T3"] = "Usar sólo la plantilla 3",
	["CO_MSP_T3_TT"] = "Incluso si usted elige una diferente plantilla para \"acerca de\", la plantilla 3 siempre se utilizará para la compatibilidad con PMS.",
	["CO_REGISTER"] = "Configuración de registro",
	["CO_REGISTER_ABOUT_H1_SIZE"] = "Tamaño del texto del encabezado 1",
	["CO_REGISTER_ABOUT_H1_SIZE_TT"] = "Tamaño del texto entre las etiquetas {h1}. Por defecto: %s",
	["CO_REGISTER_ABOUT_H2_SIZE"] = "Tamaño del texto del encabezado 2",
	["CO_REGISTER_ABOUT_H2_SIZE_TT"] = "Tamaño del texto entre las etiquetas {h2}. Por defecto: %s",
	["CO_REGISTER_ABOUT_H3_SIZE"] = "Tamaño del texto del encabezado 3",
	["CO_REGISTER_ABOUT_H3_SIZE_TT"] = "Tamaño del texto entre las etiquetas {h3}. Por defecto: %s",
	["CO_REGISTER_ABOUT_P_SIZE"] = "Tamaño del texto del párrafo",
	["CO_REGISTER_ABOUT_P_SIZE_TT"] = "Tamaño del texto fuera de las etiquetas de encabezado. Por defecto: %s",
	["CO_REGISTER_ABOUT_SETTINGS"] = "Configuraciones de \"Acerca de\"",
	["CO_REGISTER_ABOUT_VOTE"] = "Usar sistema de votos",
	["CO_REGISTER_ABOUT_VOTE_TT"] = "Activar el sistema de votación permitirá que votes (\"me gusta\" o \"no me gusta\") en las descripciones de los jugadores y que puedan votar en la tuya propia.",
	["CO_REGISTER_AUTO_ADD"] = "Añadir nuevos jugadores automáticamente",
	["CO_REGISTER_AUTO_ADD_TT"] = "Automáticamente añade nuevos jugadores que encuentres al registro.",
	["CO_REGISTER_AUTO_PURGE"] = "Purgar directorio automáticamente",
	["CO_REGISTER_AUTO_PURGE_0"] = "Deshabilitar purga",
	["CO_REGISTER_AUTO_PURGE_1"] = "Después de %s día(s)",
	["CO_REGISTER_AUTO_PURGE_TT"] = [=[Eliminar automáticamente del directorio los perfiles de personajes con los que no te has cruzado en determinado tiempo. Puedes aplazarlo antes de eliminar.

|cff00ff00Ten en cuenta que los perfiles que tengan alguna relación con tus personajes no serán eliminados.

|cffff9900Hay un error en WoW que pierde toda la información guardada al llegar a cierto límite. Recomendamos encarecidamente evitar deshabilitar el sistema de purga.]=],
	["CO_SANITIZER"] = "Sanear perfiles entrantes",
	["CO_SANITIZER_TT"] = "Eliminar secuencias de escape en campos de información de herramientas de los perfiles entrantes cuando TRP no lo permite (color, imágenes...).",
	["CO_TARGETFRAME"] = "Ajustes del marco de objetivo",
	["CO_TARGETFRAME_ICON_SIZE"] = "Tamaño de iconos",
	["CO_TARGETFRAME_USE"] = "Mostrar condiciones",
	["CO_TARGETFRAME_USE_1"] = "Siempre",
	["CO_TARGETFRAME_USE_2"] = "Sólo en ER",
	["CO_TARGETFRAME_USE_3"] = "Nunca (deshabilitado)",
	["CO_TARGETFRAME_USE_TT"] = "Determina en que condiciones se mostrará el marco de objetivo.",
	["CO_TOOLBAR"] = "Ajustes del marco",
	["CO_TOOLBAR_CONTENT"] = "Ajustes de la barra de herramientas",
	["CO_TOOLBAR_CONTENT_CAPE"] = "Botón de capa",
	["CO_TOOLBAR_CONTENT_HELMET"] = "Botón de yelmo",
	["CO_TOOLBAR_CONTENT_RPSTATUS"] = "Estado del personaje (ER/FdR)",
	["CO_TOOLBAR_CONTENT_STATUS"] = "Estado del jugador (AUS/NM)",
	["CO_TOOLBAR_HIDE_TITLE"] = "Ocultar título de la barra de herramientas",
	["CO_TOOLBAR_HIDE_TITLE_HELP"] = "Oculta el título mostrado encima de la barra de herramientas.",
	["CO_TOOLBAR_ICON_SIZE"] = "Tamaño de iconos",
	["CO_TOOLBAR_MAX"] = "Iconos máximos por línea",
	["CO_TOOLBAR_MAX_TT"] = "¡Se establece en 1 si deseas la barra en posición vertical!",
	["CO_TOOLBAR_SHOW_ON_LOGIN"] = "Mostrar barra de herramientas al iniciar sesión",
	["CO_TOOLBAR_SHOW_ON_LOGIN_HELP"] = "Si no quieres que la barra de herramientas se muestre al iniciar sesión, desactiva esta opción.",
	["CO_TOOLTIP"] = "Herramientas",
	["CO_TOOLTIP_ANCHOR"] = "Punto de anclaje",
	["CO_TOOLTIP_ANCHORED"] = "Marco anclado",
	["CO_TOOLTIP_CHARACTER"] = "Herramientas del personaje",
	["CO_TOOLTIP_CLIENT"] = "Mostrar cliente",
	["CO_TOOLTIP_COLOR"] = "Mostrar colores personalizados",
	["CO_TOOLTIP_COMBAT"] = "Ocultar durante el combate",
	["CO_TOOLTIP_COMMON"] = "Ajustes comunes",
	["CO_TOOLTIP_CONTRAST"] = "Aumentar el contraste de color",
	["CO_TOOLTIP_CONTRAST_TT"] = "Habilitar esta opción permitirá a Total RP 3 modificar los colores personalizados para hacer el texto más legible si el color es demasiado oscuro.",
	["CO_TOOLTIP_CROP_TEXT"] = "Trunca textos excesivamente largos",
	["CO_TOOLTIP_CROP_TEXT_TT"] = [=[Limita el número de caracteres que pueden ser expuestos por cada campo en información para prevenir textos excesivamente largos y posibles problemas en el diseño.

|cfffff569Detalles de límites: 
Nombre: 100 caracteres 
Título: 150 caracteres 
Raza: 50 caracteres 
Clase: 50 caracteres|r]=],
	["CO_TOOLTIP_CURRENT"] = "Mostrar información \"actual\"",
	["CO_TOOLTIP_CURRENT_LINES"] = "Saltos de línea máximos en información \"Actualmente\"",
	["CO_TOOLTIP_CURRENT_SIZE"] = "Longitud máxima de información \"actual\"",
	["CO_TOOLTIP_FT"] = "Mostrar título completo",
	["CO_TOOLTIP_GUILD"] = "Mostrar información de hermandad",
	["CO_TOOLTIP_HEALTH"] = "Mostrar salud",
	["CO_TOOLTIP_HEALTH_BOTH"] = "Número + Porcentaje",
	["CO_TOOLTIP_HEALTH_DISABLED"] = "Desactivado",
	["CO_TOOLTIP_HEALTH_NUMBER"] = "Número",
	["CO_TOOLTIP_HEALTH_PERCENT"] = "Porcentaje",
	["CO_TOOLTIP_HEALTH_TT"] = "Esto sólo se va a mostrar si el objetivo no tiene la vida completa",
	["CO_TOOLTIP_HIDE_IN_INSTANCE"] = "Ocultar en estancias",
	["CO_TOOLTIP_HIDE_ORIGINAL"] = "Ocultar marco original",
	["CO_TOOLTIP_ICONS"] = "Mostrar iconos",
	["CO_TOOLTIP_IN_CHARACTER_ONLY"] = "Ocultar cuando estés Fuera de Personaje",
	["CO_TOOLTIP_MAINSIZE"] = "Tamaño del texto principal",
	["CO_TOOLTIP_NO_FADE_OUT"] = "Ocultar inmediatamente en lugar de desvanecer",
	["CO_TOOLTIP_NOTIF"] = "Mostrar notificaciones",
	["CO_TOOLTIP_NOTIF_TT"] = "La línea de notificaciones es la línea que contiene la versión del cliente, el marcador de descripción no leída y el marcador de \"a primera vista\".",
	["CO_TOOLTIP_OWNER"] = "Mostrar propietario",
	["CO_TOOLTIP_PETS"] = "Herramienta de compañeros",
	["CO_TOOLTIP_PETS_INFO"] = "Mostrar información de compañero",
	["CO_TOOLTIP_PREFERRED_OOC_INDICATOR"] = "Indicador de FDP principal",
	["CO_TOOLTIP_PREFERRED_OOC_INDICATOR_ICON"] = "Icono:",
	["CO_TOOLTIP_PREFERRED_OOC_INDICATOR_TEXT"] = "Texto:",
	["CO_TOOLTIP_PROFILE_ONLY"] = "Utilizar sólo si el objetivo tiene un perfil",
	["CO_TOOLTIP_PRONOUNS"] = "Mostrar pronombres",
	["CO_TOOLTIP_RACE"] = "Mostrar raza, clase y nivel",
	["CO_TOOLTIP_REALM"] = "Mostrar reino",
	["CO_TOOLTIP_RELATION"] = "Mostrar el color de la relación",
	["CO_TOOLTIP_RELATION_TT"] = "Establece el color del borde del personaje según su relación contigo.",
	["CO_TOOLTIP_SPACING"] = "Mostrar espacios",
	["CO_TOOLTIP_SPACING_TT"] = "Coloca espacios entre la información del personaje para diferenciar mejor los apartados.",
	["CO_TOOLTIP_SUBSIZE"] = "Tamaño del texto secundario",
	["CO_TOOLTIP_TARGET"] = "Mostrar objetivo",
	["CO_TOOLTIP_TERSIZE"] = "Tamaño del texto terciario",
	["CO_TOOLTIP_TITLE"] = "Mostrar título",
	["CO_TOOLTIP_USE"] = "Usar herramientas de personajes/compañeros",
	["CO_TOOLTIP_ZONE"] = "Mostrar zona",
	["CO_TOOLTIP_ZONE_TT"] = "Esto sólo se mostrará si el objetivo no está en al misma zona que tú.",
	["CO_UI_RELOAD_WARNING"] = [=[La interfaz necesita ser reiniciada para que se apliquen los cambios.

¿Te gustaría reiniciar la interfaz ahora?]=],
	["CO_WIM"] = "|cffff9900Canales de susurros desactivados.",
	["CO_WIM_TT"] = "Estás usando |cff00ff00WIM|r, el administrador de canales de susurro está desactivado para propósitos de compatibilidad.",
	["COM_LIST"] = "Lista de comandos:",
	["COM_RESET_RESET"] = "¡La posición de los elementos de interfaz han sido restablecidos!",
	["COM_RESET_USAGE"] = "Uso: |cff00ff00/trp3 reset frames|r para restablecer todas las posiciones de los elementos de la interfaz.",
	["COM_STASH_DATA"] = [=[|cffff0000¿Estás seguro de que quieres ir acumulando tu información del Total RP 3?|r

Tus perfiles, los de tus compañeros y configuración se acumulará temporalmente y tu interfaz se cargará sin información, como si hubieras instalado Total RP 3 de nuevo.
|cff00ff00Utiliza el mismo comando de nuevo (|cff999999/trp3 stash|cff00ff00) para restaurar la información.|r]=],
	["COM_SWITCH_USAGE"] = "Uso: |cff00ff00/trp3 switch main|r para mostrar u ocultar la ventana principal o |cff00ff00/trp3 switch toolbar|r para mostrar u ocultar la barra de herramientas.",
	["CONFIG_COMMS_SETTINGS_HEADER"] = "Configuración de comunicaciones",
	["COPY_DROPDOWN_POPUP_TEXT"] = "Copiar con %1$s. Pegar con %2$s. Este marco se cerrará al copiarse.",
	["COPY_SYSTEM_MESSAGE"] = "Copiado al portapapeles.",
	["CREDITS_DISCORD_LINK_TEXT"] = "Únete a nuestro Discord",
	["CREDITS_THANK_YOU_ROLE_1"] = "Líder de Proyecto",
	["CREDITS_THANK_YOU_ROLE_2"] = "Autor",
	["CREDITS_THANK_YOU_ROLE_3"] = "Desarrollador",
	["CREDITS_THANK_YOU_ROLE_4"] = "Mánager de la comunidad",
	["CREDITS_THANK_YOU_ROLE_5"] = "Mascota",
	["CREDITS_THANK_YOU_SECTION_1"] = "{h1:c}Total RP 3{/h1}",
	["CREDITS_THANK_YOU_SECTION_10"] = "{col:ffffff}Gracias a nuestros miembros activos de la comunidad en Discord:{/col}",
	["CREDITS_THANK_YOU_SECTION_11"] = "{col:ffffff}Gracias a Bor Blasthammer por su ayuda durante las pruebas en BfA.{/col}",
	["CREDITS_THANK_YOU_SECTION_2"] = "{h2}%1$s Creado por{/h2}",
	["CREDITS_THANK_YOU_SECTION_3"] = "{h2}%1$s El Resto del Equipo{/h2}",
	["CREDITS_THANK_YOU_SECTION_4"] = "{h2}%1$s Agradecimientos{/h2}",
	["CREDITS_THANK_YOU_SECTION_5"] = "{col:ffffff}Logo e ícono del minimapa:{/col} %1$s",
	["CREDITS_THANK_YOU_SECTION_7"] = "{col:ffffff}Gracias a todos nuestros amigos por su apoyo todos estos años:{/col}",
	["CREDITS_THANK_YOU_SECTION_8"] = "{col:ffffff}Por ayudarnos a crear la guild Total RP en el reino Kirin Tor (EU):{/col}",
	["CREDITS_THANK_YOU_SECTION_9"] = "{col:ffffff}Gracias a Horionne por enviarnos el Magazine Gamer Culte Online #14 con un artículo sobre el Total RP.{/col}",
	["CREDITS_VERSION_TEXT"] = "Versión %s",
	["CREDITS_WEBSITE_LINK_TEXT"] = "Página Web",
	["DB_ABOUT"] = "Acerca de Total RP 3",
	["DB_HTML_GOTO"] = "Click para abrir",
	["DB_MORE"] = "Más módulos",
	["DB_NEW"] = "¿Qué hay nuevo?",
	["DB_STATUS"] = "Estado",
	["DB_STATUS_CURRENTLY"] = "Actualmente (ER)",
	["DB_STATUS_CURRENTLY_COMMON"] = "Estos estados serán mostrados en la descripción de tu personaje. Mantenlo claro y corto ya que |cffff9900 por defecto los jugadores con TRP3 solo verán los primeros 140 caracteres.",
	["DB_STATUS_CURRENTLY_OOC"] = "Otra información (FdR)",
	["DB_STATUS_CURRENTLY_OOC_TT"] = "Aquí puedes indicar algo importante sobre ti como jugador o cualquier cosa fuera de personaje.",
	["DB_STATUS_CURRENTLY_TT"] = "Aquí puedes indicar algo importante sobre tu personaje.",
	["DB_STATUS_ICON_ITEM"] = "%1$s %2$s",
	["DB_STATUS_LC"] = "Idioma de roleo",
	["DB_STATUS_LC_DEFAULT"] = "Por defecto (%1$s)",
	["DB_STATUS_RP"] = "Estado de personaje",
	["DB_STATUS_RP_EXP"] = "Rolero experimentado",
	["DB_STATUS_RP_EXP_TT"] = [=[Muestra que eres un jugador de rol experimentado.
No se mostrará ningún icono en la descripción.]=],
	["DB_STATUS_RP_IC"] = "En rol",
	["DB_STATUS_RP_IC_TT"] = [=[Significa que actualmente estás interpretando tu personaje.
Todas tus acciones serán interpretadas como si tu personaje las realizara.]=],
	["DB_STATUS_RP_OOC"] = "Fuera de rol",
	["DB_STATUS_RP_OOC_TT"] = [=[Estás fuera de rol.
Tus acciones no se asociarán a tu personaje.]=],
	["DB_STATUS_RP_VOLUNTEER"] = "Rolero voluntario",
	["DB_STATUS_RP_VOLUNTEER_TT"] = [=[Esta selección mostrará un icono, indicando
a roleros novatos que estás dispuesto a ayudarles.]=],
	["DB_STATUS_XP"] = "Estado de rol",
	["DB_STATUS_XP_BEGINNER"] = "Rolero novato",
	["DB_STATUS_XP_BEGINNER_TT"] = [=[Esta selección mostrará un icono que indicará
a otros que eres recién iniciado en el rol.]=],
	["DB_TUTO_1"] = [=[|cffffff00El estado del personaje|r indica si actualmente estás interpretando a tu personaje.

|cffffff00El estado del jugador|r indica si eres un jugador de rol principiante o un veterano dispuesto a ayudar.

|cff00ff00Esta información se colocará en la descripción de tu personaje.]=],
	["DICE_HELP"] = "Tira un dado o varios dados separados por espacios, ejemplo: 1d6, 2d12 3d20 ...",
	["DICE_ROLL"] = "%s tira |cffff9900%sx d%s|r|cffcc6600%s|r y obtiene |cff00ff00%s|r.",
	["DICE_ROLL_T"] = "%s %s tira |cffff9900%sx d%s|r|cffcc6600%s|r y obtiene |cff00ff00%s|r.",
	["DICE_TOTAL"] = "%s Total de |cff00ff00%s|r de la tirada.",
	["DICE_TOTAL_T"] = "%s %s tuvo un total de |cff00ff00%s|r de la tirada.",
	["DTBK_AFK"] = "Total RP 3 - AUS/NM",
	["DTBK_CLOAK"] = "Total RP 3 - Capa",
	["DTBK_HELMET"] = "Total RP 3 - Yelmo",
	["DTBK_LANGUAGES"] = "Total RP 3 - Idiomas",
	["DTBK_RP"] = "Total RP 3 - ER/FdR",
	["GEN_VERSION"] = "Versión: %s (Build %s)",
	["GEN_WELCOME_MESSAGE"] = "¡Gracias por usar Total RP 3 (v %s)! ¡Diviértase!",
	["LANG_CHANGE_CAUSED_REVERT_TO_DEFAULT"] = "El idioma actual ha vuelto al %s por defecto %s porque ya no conoces el idioma %s seleccionado anteriormente.",
	["MAP_BUTTON_NO_SCAN"] = "Rastreo no disponible",
	["MAP_BUTTON_SCANNING"] = "Rastreando",
	["MAP_BUTTON_SUBTITLE"] = "Haz clic para mostrar los rastreos disponibles",
	["MAP_BUTTON_SUBTITLE_80_DISABLED"] = "El escaneo no está disponible debido a los cambios del 8.0",
	["MAP_BUTTON_SUBTITLE_CONNECTING"] = "El escaneado del mapa está configurándose. Por favor, espera.",
	["MAP_BUTTON_SUBTITLE_OFFLINE"] = "El escaneo del mapa no está disponible en estos momentos: %s",
	["MAP_BUTTON_TITLE"] = "Rastrear",
	["MAP_SCAN_CHAR"] = "Rastrear personajes",
	["MAP_SCAN_CHAR_TITLE"] = "Personajes",
	["MATURE_FILTER_ADD_TO_WHITELIST"] = "Añadir este perfil a la |cfffffffflista blanca adulta|r",
	["MATURE_FILTER_ADD_TO_WHITELIST_OPTION"] = "Añadir a la |cfffffffflista blanca adulta|r",
	["MATURE_FILTER_ADD_TO_WHITELIST_TEXT"] = [=[Confirma que quieres añadir %s a la |cfffffffflista blanca adulta|r.

El contenido de estos perfiles ya no permanecerá oculto.]=],
	["MATURE_FILTER_ADD_TO_WHITELIST_TT"] = "Añadir este perfil a la |cfffffffflista blanca adulta|r y revelar su contenido adulto.",
	["MATURE_FILTER_EDIT_DICTIONARY"] = "Editar diccionario personalizado",
	["MATURE_FILTER_EDIT_DICTIONARY_ADD_BUTTON"] = "Añadir",
	["MATURE_FILTER_EDIT_DICTIONARY_ADD_TEXT"] = "Añadir nueva palabra al diccionario",
	["MATURE_FILTER_EDIT_DICTIONARY_BUTTON"] = "Editar",
	["MATURE_FILTER_EDIT_DICTIONARY_DELETE_WORD"] = "Eliminar palabra del diccionario personalizado",
	["MATURE_FILTER_EDIT_DICTIONARY_EDIT_WORD"] = "Editar palabra",
	["MATURE_FILTER_EDIT_DICTIONARY_RESET_BUTTON"] = "Resetear",
	["MATURE_FILTER_EDIT_DICTIONARY_RESET_TITLE"] = "Resetear diccionario",
	["MATURE_FILTER_EDIT_DICTIONARY_RESET_WARNING"] = "¿Seguro que quieres resetear el diccionario? Esto vaciará el diccionario y lo llenará con palabras por defecto de tu idioma actual (si está disponible).",
	["MATURE_FILTER_EDIT_DICTIONARY_TITLE"] = "Editor del diccionario personalizado",
	["MATURE_FILTER_EDIT_DICTIONARY_TT"] = "Editar el diccionario personalizado usado para el filtro de perfiles adultos.",
	["MATURE_FILTER_FLAG_PLAYER"] = "Marcar como adulto",
	["MATURE_FILTER_FLAG_PLAYER_OPTION"] = "Marcar como adulto",
	["MATURE_FILTER_FLAG_PLAYER_TEXT"] = [=[Confirma que quieres marcar el perfil de %s como contenido adulto. El contenido de este perfil quedará oculto.

|cffffff00Opcional:|r Indica las palabras ofensivas que encontraste en este perfil (separadas por un espacio) para añadirlas al filtro.]=],
	["MATURE_FILTER_FLAG_PLAYER_TT"] = "Marcar este perfil como contenido adulto. El contenido del perfil quedará oculto.",
	["MATURE_FILTER_OPTION"] = "Filtrar perfiles adultos",
	["MATURE_FILTER_OPTION_TT"] = [=[Marca esta opción para habilitar el filtrado de perfiles adultos. Total RP 3 escaneará nuevos perfiles cuando se reciban a través de palabras clave reportadas como adultas y marcará el perfil como adulto si encuentra dicha palabra.

Un perfil adulto tendrá la información oculta y tendrás que confirmar que deseas ver el perfil la primera vez que lo abras.]=],
	["MATURE_FILTER_REMOVE_FROM_WHITELIST"] = "Eliminar este perfil de la |cfffffffflista blanca adulta|r",
	["MATURE_FILTER_REMOVE_FROM_WHITELIST_OPTION"] = "Eliminar de la |cfffffffflista blanca adulta|r",
	["MATURE_FILTER_REMOVE_FROM_WHITELIST_TEXT"] = [=[Confirma que quieres eliminar a %s de la |cfffffffflista blanca adulta|r.

El contenido de los perfiles volverá a ocultarse.]=],
	["MATURE_FILTER_REMOVE_FROM_WHITELIST_TT"] = "Eliminar este perfil de la |cfffffffflista blanca adulta|r y ocultar de nuevo su contenido adulto.",
	["MATURE_FILTER_STRENGTH"] = "Nivel de filtro adulto",
	["MATURE_FILTER_STRENGTH_TT"] = [=[Ajusta el nivel del filtro adulto.

|cffcccccc1 es bajo (10 palabrotas para marcar), 10 es alto (sólo 1 palabrota es necesaria para marcar).|r]=],
	["MATURE_FILTER_TITLE"] = "Filtro de perfiles adultos",
	["MATURE_FILTER_TOOLTIP_WARNING"] = "Contenido adulto",
	["MATURE_FILTER_TOOLTIP_WARNING_SUBTEXT"] = "Este perfil de personaje contiene contenido adulto. Usa el botón de la barra de acciones para mostrar si realmente deseas...",
	["MATURE_FILTER_WARNING_CONTINUE"] = "Continuar",
	["MATURE_FILTER_WARNING_GO_BACK"] = "Atrás",
	["MATURE_FILTER_WARNING_TEXT"] = [=[Tienes el filtro de contenido adulto de Total RP 3 habilitado.

Este perfil se ha marcado como contenido adulto.

¿Estás seguro de querer ver este perfil?]=],
	["MATURE_FILTER_WARNING_TITLE"] = "Contenido adulto",
	["MM_SHOW_HIDE_MAIN"] = "Mostrar/ocultar marco principal",
	["MM_SHOW_HIDE_MOVE"] = "Mover botón",
	["MM_SHOW_HIDE_SHORTCUT"] = "Mostrar/ocultar barra de herramientas",
	["MO_ADDON_NOT_INSTALLED"] = "El add-on %s no está instalado, integracion personalizada de Total RP 3 deshabilitada.",
	["MO_CHAT_CUSTOMIZATIONS_DESCRIPTION"] = "Añade compatibilidad personalizada para el add-on %s, asi que Total RP 3 cambia los mensajes de chat y los nombres de los jugadores en ese add-on.",
	["MO_TOOLTIP_CUSTOMIZATIONS_DESCRIPTION"] = "Añade compatibilidad personalizada para el add-on %s, asi que tus preferencias de ventana de información se aplicarán sobre las ventanas de Total RP 3.",
	["MORE_MODULES_2"] = [=[{h2:c}Módulos opcionales{/h2}
{h3}Total RP 3: Extended |cffF87431|r{/h3}
|cff9999ffTotal RP 3: Extended|r añade la posibilidad de crear nuevo contenido en WoW: campañas con misiones y diálogos, objetos, documentos (libros, señales, contratos...), ¡y mucho más!
{link*https://www.curseforge.com/wow/addons/total-rp-3-extended*Descargar en CurseForge}

{h3}TRP3 Currently Frame{/h3}
Adds a standalone frame to your UI that displays your "Currently" text and allows you to edit it easily.
{link*https://www.curseforge.com/wow/addons/trp3-currently-frame*Descargar en CurseForge}

{h3}TRP3 Location Toggle{/h3}
Adds a simple button to the toolbar to toggle on and off the map scan location feature.
{link*https://www.curseforge.com/wow/addons/trp3-location-toggle*Descargar en CurseForge}]=],
	["NAMEPLATES_CONFIG_CUSTOMIZE_FULL_TITLES"] = "Mostrar títulos completos",
	["NAMEPLATES_CONFIG_CUSTOMIZE_HEALTH_COLORS"] = "Mostrar los colores personalizados de salud",
	["NAMEPLATES_CONFIG_CUSTOMIZE_HEALTH_COLORS_HELP"] = "Si está activo, cambiará el color de la barra de salud por el color personalizado del perfil.",
	["NAMEPLATES_CONFIG_CUSTOMIZE_ICONS"] = "Mostrar íconos",
	["NAMEPLATES_CONFIG_CUSTOMIZE_ICONS_HELP"] = "Si está activo, mostrará los íconos del perfil en la placa de nombre.",
	["NAMEPLATES_CONFIG_CUSTOMIZE_NAME_COLORS"] = "Mostrar los nombres con el color del perfil",
	["NAMEPLATES_CONFIG_CUSTOMIZE_NAME_COLORS_HELP"] = "Si está activo, se cambiará el color de los nombres por el color personalizado del perfil.",
	["NAMEPLATES_CONFIG_CUSTOMIZE_NAMES"] = "Mostrar nombres personalizados",
	["NAMEPLATES_CONFIG_CUSTOMIZE_NAMES_HELP"] = "Si está activo, reemplaza el nombre del personaje en la placa de nombre.",
	["NAMEPLATES_CONFIG_CUSTOMIZE_ROLEPLAY_STATUS"] = "Mostrar el indicador de estado de roleplay",
	["NAMEPLATES_CONFIG_CUSTOMIZE_ROLEPLAY_STATUS_HELP"] = "Si está activo, mostrará el indicador En Personaje o Fuera de Personaje en la placa de nombres.",
	["NAMEPLATES_CONFIG_DISABLE_IN_COMBAT"] = "Deshabilitar las personalizaciones en combate",
	["NAMEPLATES_CONFIG_DISABLE_IN_COMBAT_HELP"] = "Si está activo, se desactivarán los nombres y colores personalizados cuando estás en combate.",
	["NAMEPLATES_CONFIG_DISABLE_OUT_OF_CHARACTER"] = "Deshabilitar las personalizaciones en modo FdP",
	["NAMEPLATES_CONFIG_DISABLE_OUT_OF_CHARACTER_HELP"] = "Si está activo, deshabilita todas las personalizaciones de la placa de nombres cuando estás en modo Fuera de Personaje.",
	["NAMEPLATES_CONFIG_DISABLE_OUT_OF_CHARACTER_UNITS"] = "Deshabilitar las personalizaciones en unidades que estén FdP",
	["NAMEPLATES_CONFIG_DISABLE_OUT_OF_CHARACTER_UNITS_HELP"] = "Si está activo, deshabilita las personalizaciones en la placa de nombres de las unidades que estén en modo Fuera de Personaje.",
	["NAMEPLATES_CONFIG_ELEMENT_HEADER"] = "Configuraciones de personalización",
	["NAMEPLATES_CONFIG_ENABLE_CLASS_COLOR_FALLBACK"] = "Usar el color de clase por defecto",
	["NAMEPLATES_CONFIG_ENABLE_CLASS_COLOR_FALLBACK_HELP"] = "Si está activo, habilita el uso de los colores de clase para los nombres y las barras de vida de aquellas unidades que no tengan un color personalizado en sus perfiles.|n|nLas unidades que no tengan un perfil de rol no serán afectadas por esta opción.",
	["NAMEPLATES_CONFIG_ICON_SIZE"] = "Tamaño de ícono",
	["NAMEPLATES_CONFIG_ICON_SIZE_HELP"] = "Configura el tamaño de los íconos mostrados en la placa de nombres si la opción |cffffff00Mostrar íconos|r está habilitada.",
	["NAMEPLATES_CONFIG_MENU_TITLE"] = "Placa de nombres",
	["NAMEPLATES_CONFIG_PAGE_TEXT"] = "Configuraciones de placa de nombre",
	["NAMEPLATES_CONFIG_VISIBILITY_HEADER"] = "Configuraciones de visibilidad",
	["NAMEPLATES_MODULE_NAME"] = "Placa de nombres",
	["NEW_VERSION"] = [=[|cff00ff00Hay una nueva versión de Total RP 3 (v %s) disponible.

|cffffff00Recomendamos encarecidamente mantenerlo actualizado.|r

Este mensaje sólo aparecerá una vez por sesión y puede ser deshabilitado en los ajustes (Ajustes generales => Varios).]=],
	["NEW_VERSION_BEHIND"] = "Actualmente estás %s versiones atrasado y te faltan bugs arreglados y nuevas características. Puede que otros jugadores no vean tu perfil correctamente. Por favor, considera actualizar tu add-on.",
	["NEW_VERSION_TITLE"] = "Nueva actualización disponible",
	["NPC_TALK_BUTTON_TT"] = "Abre el marco de diálogos de PNJ el cual permite realizar diálogos y emociones de PNJ.",
	["NPC_TALK_CHANNEL"] = "Canal:",
	["NPC_TALK_COMMAND_HELP"] = "Abre el cuadro de diálogo de PNJ.",
	["NPC_TALK_ERROR_EMPTY_MESSAGE"] = "El mensaje no puede estar vacío.",
	["NPC_TALK_MESSAGE"] = "Mensaje",
	["NPC_TALK_NAME"] = "Nombre de PNJ",
	["NPC_TALK_NAME_TT"] = [=[Puedes usar etiquetas de chat estándar como %t para introducir el nombre de tu objetivo o %f para introducir el nombre de tu foco.

Puedes dejar este campo en blanco para crear emotes sin el nombre de un PNJ al principio.]=],
	["NPC_TALK_SAY_PATTERN"] = "dice:",
	["NPC_TALK_SEND"] = "Enviar",
	["NPC_TALK_TITLE"] = "Diálogos de PNJ",
	["NPC_TALK_WHISPER_PATTERN"] = "susurra:",
	["NPC_TALK_YELL_PATTERN"] = "grita:",
	["OPTION_DISABLED_TOAST"] = "Opciones deshabilitadas",
	["OPTION_ENABLED_TOAST"] = "Opción habilitada",
	["PATTERN_ERROR"] = "Error en el patrón",
	["PATTERN_ERROR_TAG"] = "Error en patrón : etiqueta de texto sin cerrar.",
	["PR_CO_BATTLE"] = "Compañero",
	["PR_CO_COUNT"] = "%s mascota/montura ligada a este perfil.",
	["PR_CO_EMPTY"] = "Sin compañeros",
	["PR_CO_MASTERS"] = "Dueños",
	["PR_CO_MOUNT"] = "Montura",
	["PR_CO_NEW_PROFILE"] = "Nuevo perfil de compañero",
	["PR_CO_PET"] = "Mascota",
	["PR_CO_PROFILE_DETAIL"] = "Este perfil está actualmente vinculado a",
	["PR_CO_PROFILE_HELP"] = [=[Un perfil contiene toda la información acerca de una |cffffff00"mascota"|r como un |cff00ff00personaje de rol|r.

Un perfil de compañero puede estar vinculado a:
-Los compañeros |cffff9900(sólo si se ha cambiado el nombre)|r
-Las mascotas del cazador
-Los demonios del brujo
-Los elementales del mago
-Los no-muertos del caballero de la muerte |cffff9900(Ver abajo)|r

Al igual que los perfiles de los personajes, un |cff00ff00perfil de compañero|r puede estar vinculado a |cffffff00várias mascotas|r, y una |cffffff00mascota|r puede cambiar fácilmente de un perfil a otro.

|cffff9900No-muertos:|r como los no-muertos obtienen un nombre diferente cada vez que son invocados, se tendrá que vincular el perfil para todos los nombres posibles del no-muerto.]=],
	["PR_CO_PROFILE_HELP2"] = [=[Haz clic aquí para crear un nuevo perfil de compañero.

|cff00ff00Para vincular un perfil con una mascota, invoca a la mascota, selecciónala y utiliza el marco de destino para vincularlo al perfil existente (o crear uno nuevo):|r]=],
	["PR_CO_PROFILEMANAGER_DELETE_WARNING"] = [=[¿Estás seguro de que deseas eliminar el perfil del compañero %s?
¡Esta acción no se podrá deshacer y toda la información del perfil TRP3 será destruida!]=],
	["PR_CO_PROFILEMANAGER_DUPP_POPUP"] = [=[Por favor, introduce un nombre para el nuevo perfil.
El nombre no puede estar vacío.

El duplicado no cambiará tus mascotas/monturas vinculadas a %s.]=],
	["PR_CO_PROFILEMANAGER_EDIT_POPUP"] = [=[Por favor, introduce un nuevo nombre para este perfil.
El nombre no puede estar vacío.

Cambiar el nombre no cambiará ningún vínculo entre este perfil y tus mascotas/monturas.]=],
	["PR_CO_PROFILEMANAGER_TITLE"] = "Perfiles de compañeros",
	["PR_CO_UNUSED_PROFILE"] = "Este perfil no está actualmente vinculado a ninguna mascota o montura.",
	["PR_CO_WARNING_RENAME"] = [=[|cffff0000Advertencia;|r se recomienda encarecidamente renombrar a la mascota antes de vincularla a un perfil.|r

¿Quieres enlazarla de todas formas?]=],
	["PR_CREATE_PROFILE"] = "Crear perfil",
	["PR_DEFAULT_PROFILE_NAME"] = "Perfil por defecto",
	["PR_DEFAULT_PROFILE_WARNING"] = "Crea un nuevo perfil o enlaza con uno ya existente en Perfiles para editar la información de tu personaje.",
	["PR_DELETE_PROFILE"] = "Eliminar perfil",
	["PR_DUPLICATE_PROFILE"] = "Duplicar perfil",
	["PR_EXPORT_IMPORT_HELP"] = [=[Puedes exportar e importar perfiles usando las opciones en el menú desplegable.

Usa la opción |cffffff00Exportar perfil|r para generar un texto conteniendo la información serializada del perfil. Puedes copiar el texto usando Control+C (o Comando+C en un Mac) y pegarlo en otra parte como seguridad. cffff0000Por favor, ten en cuenta que algunas herramientas de texto avanzadas como Microsoft Word reformateará algunos caracteres especiales como comillas, alterando la información. Utiliza herramientas de texto simples como Notepad.|r)

Usa la opción |cffffff00Importar perfil|r para pegar la información de una exportación previa dentro de un perfil existente. La información existente será reemplazada por las que pegues. No puedes importar información directamente de tu perfil seleccionado.]=],
	["PR_EXPORT_IMPORT_TITLE"] = "Exportar/importar perfil",
	["PR_EXPORT_NAME"] = "Serie para el perfil %s (tamaño %0.2f kB)",
	["PR_EXPORT_PROFILE"] = "Exportar perfil",
	["PR_EXPORT_TOO_LARGE"] = [=[El perfil es demasiado grande y no puede ser exportado.

Tamaño del perfil: %0.2f kB
Máx.: 20 kB]=],
	["PR_EXPORT_WARNING_MAC"] = [=[Algunas herramientas de edición de texto avanzada como Text Edit o Discord formatearán caracteres especiales como citas, alterando el contenido de los datos.

Si planeas copiar el texto de abajo en un documento, usa herramientas de edición más sencillas que no cambien caracteres automáticamente (en Text Edit ve a "Formato > Convertir en texto normal" antes de pegar)]=],
	["PR_EXPORT_WARNING_TITLE"] = "Atención:",
	["PR_EXPORT_WARNING_WINDOWS"] = [=[Ten en cuenta que algunas herramientas de edición de texto avanzadas como Microsoft Word o Discord reformarán caracteres especiales como citas, alterando el contenido de la información.

Si planeas copiar el texto de abajo en un documento, usa herramientas de edición más sencillas que no cambien caracteres automáticamente, como Notepad.]=],
	["PR_IMPORT"] = "Importar",
	["PR_IMPORT_CHAR_TAB"] = "Importar personajes",
	["PR_IMPORT_EMPTY"] = "Sin perfiles importables",
	["PR_IMPORT_IMPORT_ALL"] = "Importar todo",
	["PR_IMPORT_PETS_TAB"] = "Importar compañeros",
	["PR_IMPORT_PROFILE"] = "Importar perfil",
	["PR_IMPORT_PROFILE_TT"] = "Pegar aquí serie de perfil",
	["PR_IMPORT_WILL_BE_IMPORTED"] = "Se importarán",
	["PR_PROFILE"] = "Perfil",
	["PR_PROFILE_CREATED"] = "Perfil %s creado.",
	["PR_PROFILE_DELETED"] = "Perfil %s eliminado.",
	["PR_PROFILE_DETAIL"] = "Este perfil actualmente no está vinculado a ningún personaje de WoW.",
	["PR_PROFILE_HELP"] = [=[Un perfil contiene toda la información de un |cffffff00"personaje"|r como un |cff00ff00personaje de rol|r.

Un |cffffff00"personaje del WoW"|r sólo puede ser vinculado a un solo perfil a la vez, pero puedes cambiar de uno a otro en cualquier momento.

¡También puedes vincular varios |cffffff00"personajes"|r al mismo |cff00ff00perfil|r!]=],
	["PR_PROFILE_LOADED"] = "El perfil %s ha sido cargado.",
	["PR_PROFILE_MANAGEMENT_TITLE"] = "Administración de perfiles",
	["PR_PROFILEMANAGER_ACTIONS"] = "Acciones",
	["PR_PROFILEMANAGER_ALREADY_IN_USE"] = "El nombre del perfil %s no está disponible.",
	["PR_PROFILEMANAGER_COUNT"] = "%s personaje vinculado a este perfil.",
	["PR_PROFILEMANAGER_CREATE_POPUP"] = [=[Por favor, introduce un nombre para el nuevo perfil.
El nombre no puede estar vacío.]=],
	["PR_PROFILEMANAGER_CURRENT"] = "Perfil actual",
	["PR_PROFILEMANAGER_DELETE_WARNING"] = [=[¿Seguro que deseas eliminar el perfil %s?
¡Esta acción no se podrá deshacer y toda la información del perfil TRP3 (información del personaje, inventario, registro de misiones, estados aplicados...) será destruida!]=],
	["PR_PROFILEMANAGER_DUPP_POPUP"] = [=[Por favor introduce el nombre para el nuevo perfil.
El nombre no puede mostrarse vacío.

Este duplicado no cambiará las vinculaciones del personaje a %s.]=],
	["PR_PROFILEMANAGER_EDIT_POPUP"] = [=[Por favor, introduce un nuevo nombre para el perfil %s.
El nombre no puede mostrarse vacío.

Cambiar el nombre no afectará al vinculo entre este perfil y tus personajes.]=],
	["PR_PROFILEMANAGER_EMPTY"] = "No se ha encontrado ningún perfil",
	["PR_PROFILEMANAGER_IMPORT_WARNING"] = "¿Reemplazar todo el contenido del perfil %s con la información importada?",
	["PR_PROFILEMANAGER_IMPORT_WARNING_2"] = [=[Aviso: la serie de este perfil se ha hecho de una versión antigua de TRP3.
Puede causar incompatibilidades.

¿Deseas reemplazar todo el contenido del perfil %s con la información importada?]=],
	["PR_PROFILEMANAGER_RENAME"] = "Renombrar perfil",
	["PR_PROFILEMANAGER_SEARCH_PROFILE"] = "Buscar perfil",
	["PR_PROFILEMANAGER_SWITCH"] = "Seleccionar perfil",
	["PR_PROFILEMANAGER_TITLE"] = "Perfiles de personaje",
	["PR_PROFILES"] = "Perfiles",
	["PR_SLASH_EXAMPLE"] = "|cffffff00Uso del comando:|r |cffcccccc/perfil trp3 profile Millidan Iraspuma|r |cffffff00to cambiar al perfil de Millidan Iraspuma.|r",
	["PR_SLASH_NOT_FOUND"] = "|cffff0000No se pudo encontrar ningún perfil llamado|r |cffffff00%s|r|cffff0000.|r",
	["PR_SLASH_OPEN_ABORTING"] = "|cffffff00Petición de perfil abortada.|r",
	["PR_SLASH_OPEN_EXAMPLE"] = "|cffffff00Uso del comando:|r |cffcccccc/trp3 open|r |cffffff00para abrir el perfil de tu objetivo o |cffcccccc/trp3 open CharacterName-RealmName|r |cffffff00para abrir el perfil de ese personaje.|r",
	["PR_SLASH_OPEN_HELP"] = "Abrir el perfil de un personaje usando su nombre en el juego, o el perfil de tu objetivo si no se introduce ningún nombre.",
	["PR_SLASH_OPEN_WAITING"] = "|cffffff00Solicitando perfil, por favor espera...|r",
	["PR_SLASH_SWITCH_HELP"] = "Cambiar a otro perfil usando su nombre.",
	["PR_UNUSED_PROFILE"] = "Este perfil actualmente no está vinculado a ningún personaje de WoW.",
	["REG_CODE_INSERTION_WARNING"] = [=[|TInterface\AddOns\totalRP3\resources\policegar.tga:50:50|t ¡Espera un momento! 

Hemos descubierto que has insertado códigos inválidos en tu perfil de Total RP 3. 
No compartimos este comportamiento y desaconsejamos hacerlo.
Puede conducir a inestabilidades y bugs en el add-on, corrupción de datos/pérdia de perfiles y también crea problemas de compatibilidad con otros add-ons (como MRP). 

Los códigos que has introducido en tu perfil han sido eliminados para prevenir mal funcionamiento del add-on.]=],
	["REG_COMPANION"] = "Compañero",
	["REG_COMPANION_BIND_TO_PET"] = "Mascota",
	["REG_COMPANION_BOUND_TO"] = "Vinculado a ...",
	["REG_COMPANION_BOUND_TO_TARGET"] = "Objetivo",
	["REG_COMPANION_BOUNDS"] = "Vínculos",
	["REG_COMPANION_BROWSER_BATTLE"] = "Buscador de compañeros",
	["REG_COMPANION_BROWSER_MOUNT"] = "Buscador de monturas",
	["REG_COMPANION_INFO"] = "Información",
	["REG_COMPANION_LINKED"] = "El compañero %s ahora está ligado al perfil %s.",
	["REG_COMPANION_LINKED_NO"] = "El compañero %s ya no está ligado a ningún perfil.",
	["REG_COMPANION_NAME"] = "Nombre",
	["REG_COMPANION_NAME_COLOR"] = "Color del nombre",
	["REG_COMPANION_PAGE_TUTO_C_1"] = "Consultar",
	["REG_COMPANION_PAGE_TUTO_E_1"] = [=[Esta es la |cff00ff00información principal del compañero|r.

Toda esta información aparecerá en la |cffff9900descripción de compañero|r.]=],
	["REG_COMPANION_PAGE_TUTO_E_2"] = [=[Esta es la |cff00ff00descripción del compañero|r.

No se limita a la |cffff9900descripción física|r. Siéntete libre de indicar parte de su |cffff9900trasfondo|r o detalles de su |cffff9900carácter|r.

Hay muchas maneras de personalizar la descripción.
Puedes elegir el |cffffff00fondo del texto|r para la descripción. También puedes utilizar las herramientas de formato para acceder a varios parámetros de diseño como el |cffffff00tamaño del texto, color y posicionamiento|r.
Esta herramienta también permite insertar |cffffff00imágenes, iconos o enlaces externos de sitios web|r.]=],
	["REG_COMPANION_PROFILES"] = "Perfiles de compañeros",
	["REG_COMPANION_TARGET_NO"] = "To objetivo no es una mascota, necrófago, elemental de mago o compañero renombrado válido.",
	["REG_COMPANION_TF_BOUND_TO"] = "Seleccionar perfil",
	["REG_COMPANION_TF_CREATE"] = "Crear nuevo perfil",
	["REG_COMPANION_TF_NO"] = "No hay perfil",
	["REG_COMPANION_TF_OPEN"] = "Abrir página",
	["REG_COMPANION_TF_OWNER"] = "Dueño: %s",
	["REG_COMPANION_TF_PROFILE"] = "Perfil de compañero",
	["REG_COMPANION_TF_PROFILE_MOUNT"] = "Perfil de montura",
	["REG_COMPANION_TF_UNBOUND"] = "Desvincular del perfil",
	["REG_COMPANION_TITLE"] = "Título",
	["REG_COMPANION_UNBOUND"] = "Desvincular de...",
	["REG_COMPANIONS"] = "Compañeros",
	["REG_DELETE_WARNING"] = "¿Seguro que quieres eliminar el perfil %s?",
	["REG_IGNORE_TOAST"] = "Personaje ignorado",
	["REG_LIST_ACTIONS_MASS"] = "Acción sobre los %s perfiles seleccionados.",
	["REG_LIST_ACTIONS_MASS_IGNORE"] = "Ignorar perfiles",
	["REG_LIST_ACTIONS_MASS_IGNORE_C"] = [=[Esta acción añadirá al |cff00ff00%s personaje|r a la lista de ignorados.

Opcionalmente, puede rellenar la razón de ser ignorado abajo. Esta nota es personal, servirá como recordatorio.]=],
	["REG_LIST_ACTIONS_MASS_REMOVE"] = "Eliminar perfiles",
	["REG_LIST_ACTIONS_MASS_REMOVE_C"] = "Esta acción eliminará los |cff00ff00%s perfiles seleccionados|r.",
	["REG_LIST_ACTIONS_PURGE"] = "Purgar registro",
	["REG_LIST_ACTIONS_PURGE_ALL"] = "Eliminar todos los perfiles",
	["REG_LIST_ACTIONS_PURGE_ALL_C"] = [=[Esta purga eliminará todos los perfiles vinculados desde el directorio.

|cff00ff00%s personajes.]=],
	["REG_LIST_ACTIONS_PURGE_ALL_COMP_C"] = [=[Esta purga eliminará todos los compañeros del directorio.

|cff00ff00%s compañeros.]=],
	["REG_LIST_ACTIONS_PURGE_COUNT"] = "%s perfiles serán eliminados.",
	["REG_LIST_ACTIONS_PURGE_EMPTY"] = "No hay perfiles que purgar.",
	["REG_LIST_ACTIONS_PURGE_IGNORE"] = "Perfiles de personajes ignorados.",
	["REG_LIST_ACTIONS_PURGE_IGNORE_C"] = [=[Esta purga eliminará a todos los perfiles vinculados a un personaje de WoW ignorado.

|cff00ff00%s]=],
	["REG_LIST_ACTIONS_PURGE_TIME"] = "Perfiles no vistos desde hace 1 mes",
	["REG_LIST_ACTIONS_PURGE_TIME_C"] = [=[Esta purga eliminará a todos los personajes no vistos desde hace un mes.

|cff00ff00%s]=],
	["REG_LIST_ACTIONS_PURGE_UNLINKED"] = "Perfiles no vinculados a un personaje",
	["REG_LIST_ACTIONS_PURGE_UNLINKED_C"] = [=[Esta purga eliminará todos los perfiles no vinculados a un personaje de WoW.

|cff00ff00%s]=],
	["REG_LIST_ADDON"] = "Tipo de perfil",
	["REG_LIST_CHAR_EMPTY"] = "Sin personajes",
	["REG_LIST_CHAR_EMPTY2"] = "Ningún personaje encaja con tu selección",
	["REG_LIST_CHAR_FILTER"] = "Personajes: %s / %s",
	["REG_LIST_CHAR_IGNORED"] = "Ignorado",
	["REG_LIST_CHAR_NAME_COPY"] = "Copiar nombre de personaje",
	["REG_LIST_CHAR_SEL"] = "Seleccionar personaje",
	["REG_LIST_CHAR_TITLE"] = "Lista de personajes",
	["REG_LIST_CHAR_TT"] = "Click para mostrar página",
	["REG_LIST_CHAR_TT_CHAR"] = "Personaje(s) de WoW ligado(s):",
	["REG_LIST_CHAR_TT_CHAR_NO"] = "No está vinculado a ningún personaje",
	["REG_LIST_CHAR_TT_DATE"] = [=[Última vez que fue visto: |cff00ff00%s|r
Último lugar donde fue visto: |cff00ff00%s|r]=],
	["REG_LIST_CHAR_TT_GLANCE"] = "A primera vista",
	["REG_LIST_CHAR_TT_IGNORE"] = "Personaje(s) ignorado(s)",
	["REG_LIST_CHAR_TT_NEW_ABOUT"] = "Descripción no leída",
	["REG_LIST_CHAR_TT_RELATION"] = [=[Relación:
|cff00ff00%s]=],
	["REG_LIST_CHAR_TUTO_ACTIONS"] = "Esta columna te permite seleccionar múltiples personajes y realizar una acción en conjunto",
	["REG_LIST_CHAR_TUTO_FILTER"] = [=[Puedes filtrar la lista de personajes.

El |cff00ff00filtro de nombre|r realizará una búsqueda del nombre completo del perfil (nombre + apellido) y de cualquier personaje de WoW vinculado.

El |cff00ff00filtro de hermandad|r buscará a los personajes de WoW vinculados a la hermandad.

El |cff00ff00filtro de sólo del este reino|r mostrará sólo los perfiles de los personajes del reino actual.]=],
	["REG_LIST_CHAR_TUTO_LIST"] = [=[La primera columna muestra el nombre del personaje.

La segunda columna muestra la relación entre esos personajes y el tuyo.

La última columna es para varias señales. (ignorados, etc...)]=],
	["REG_LIST_FILTERS"] = "Filtros",
	["REG_LIST_FILTERS_TT"] = [=[|cffffff00Click:|r Aplicar filtros
|cffffff00Click derecho:|r Limpiar filtros]=],
	["REG_LIST_FLAGS"] = "Banderas",
	["REG_LIST_GUILD"] = "Hermandad",
	["REG_LIST_IGNORE_EMPTY"] = "Personaje no ignorado",
	["REG_LIST_IGNORE_TITLE"] = "Lista de ignorados",
	["REG_LIST_IGNORE_TT"] = [=[Razón:
|cff00ff00%s

|cffffff00Click para eliminar de la lista de ignorados]=],
	["REG_LIST_NAME"] = "Nombre del personaje",
	["REG_LIST_NOTESONLY"] = "Solo hay notas",
	["REG_LIST_NOTIF_ADD"] = "Nuevo perfil descubierto: |cff00ff00%s",
	["REG_LIST_NOTIF_ADD_CONFIG"] = "Nuevo perfil descubierto",
	["REG_LIST_NOTIF_ADD_NOT"] = "Este perfil ya no existe.",
	["REG_LIST_PET_MASTER"] = "Nombre del dueño",
	["REG_LIST_PET_NAME"] = "Nombre del compañero",
	["REG_LIST_PET_TYPE"] = "Tipo de compañero",
	["REG_LIST_PETS_EMPTY"] = "No hay compañero",
	["REG_LIST_PETS_EMPTY2"] = "Ningún compañero encaja con tu selección",
	["REG_LIST_PETS_FILTER"] = "Compañeros: %s / %s",
	["REG_LIST_PETS_TITLE"] = "Lista de compañeros",
	["REG_LIST_PETS_TOOLTIP"] = "Se ha visto en",
	["REG_LIST_PETS_TOOLTIP2"] = "Se ha visto con",
	["REG_LIST_REALMONLY"] = "Sólo en este reino",
	["REG_LOCATION_DIFFERENT_WAR_MODE"] = "Modo de Guerra distinto",
	["REG_MSP_ALERT"] = [=[|cffff0000ADVERTENCIA

No se puede tener más de un addon utilizando el Protocolo Mary Sue, ya que podrían entrar en conflicto.|r

Actualmente cargado: |cff00ff00%s

|cffff9900Por lo tanto, se desactivará el apoyo PMS para el Total RP3|r

Si no quieres que el TRP3 sea tu PMS y no quieres ver esta alerta de nuevo, puedes desactivarlo en el módulo Protocolo Mary Sue en ajustes de Total RP3 en -> Estado del módulo.]=],
	["REG_NOTES_PROFILE"] = "Notas",
	["REG_NOTES_PROFILE_TT"] = "Abre la ventana de notas para el personaje objetivo.",
	["REG_PLAYER"] = "Personaje",
	["REG_PLAYER_ABOUT"] = "Acerca de",
	["REG_PLAYER_ABOUT_ADD_FRAME"] = "Añadir un marco",
	["REG_PLAYER_ABOUT_EMPTY"] = "Sin descripción",
	["REG_PLAYER_ABOUT_HEADER"] = "Etiqueta del título",
	["REG_PLAYER_ABOUT_MUSIC"] = "Tema del personaje",
	["REG_PLAYER_ABOUT_MUSIC_LISTEN"] = "Tocar tema",
	["REG_PLAYER_ABOUT_MUSIC_REMOVE"] = "Deseleccionar tema",
	["REG_PLAYER_ABOUT_MUSIC_SELECT"] = "Selecciona un tema para el personaje",
	["REG_PLAYER_ABOUT_MUSIC_SELECT2"] = "Seleccionar tema",
	["REG_PLAYER_ABOUT_MUSIC_STOP"] = "Parar tema",
	["REG_PLAYER_ABOUT_MUSIC_THEME"] = "Tema musical del personaje",
	["REG_PLAYER_ABOUT_NOMUSIC"] = "|cffff9900Sin tema",
	["REG_PLAYER_ABOUT_P"] = "Etiqueta del parágrafo",
	["REG_PLAYER_ABOUT_REMOVE_FRAME"] = "Eliminar este marco",
	["REG_PLAYER_ABOUT_SOME"] = "Escribir texto aquí...",
	["REG_PLAYER_ABOUT_T1_YOURTEXT"] = "Tu texto aquí",
	["REG_PLAYER_ABOUT_TAGS"] = "Herramientas de formato",
	["REG_PLAYER_ABOUT_UNMUSIC"] = "|cffff9900Tema desconocido",
	["REG_PLAYER_ABOUT_VOTE_DOWN"] = "No me gusta",
	["REG_PLAYER_ABOUT_VOTE_NO"] = [=[No hay personajes conectados vinculados a este perfil.
¿Deseas mandar el voto de todas formas?]=],
	["REG_PLAYER_ABOUT_VOTE_SENDING"] = "Enviando tu voto a %s ...",
	["REG_PLAYER_ABOUT_VOTE_SENDING_OK"] = "¡Tu voto ha sido enviado a %s !",
	["REG_PLAYER_ABOUT_VOTE_TT"] = "Tu voto es totalmente anónimo y sólo puede ser visto por este jugador.",
	["REG_PLAYER_ABOUT_VOTE_TT2"] = "Sólo puedes votar si el jugador está conectado.",
	["REG_PLAYER_ABOUT_VOTE_UP"] = "Me gusta",
	["REG_PLAYER_ABOUT_VOTES"] = "Estadísticas",
	["REG_PLAYER_ABOUT_VOTES_R"] = [=[|cff00ff00%s Me gusta
|cffff0000%s No me gusta]=],
	["REG_PLAYER_ABOUTS"] = "Acerca de %s",
	["REG_PLAYER_ADD_NEW"] = "Crear nuevo",
	["REG_PLAYER_AGE"] = "Edad",
	["REG_PLAYER_AGE_TT"] = [=[Aquí puedes indicar la edad de tu personaje.

Puedes hacerlo de distintas maneras:|c0000ff00
- Usa años,
- O un adjetivo (joven, maduro, adulto, venerable, etc.).]=],
	["REG_PLAYER_ALERT_HEAVY_SMALL"] = [=[|cffff0000El tamaño total de tu perfil es demasiado extenso.
|cffff9900Debes reducirlo.]=],
	["REG_PLAYER_BIRTHPLACE"] = "Lugar de nacimiento",
	["REG_PLAYER_BIRTHPLACE_TT"] = [=[Aquí puedes indicar el lugar de nacimiento tu personaje. Puede ser una región, zona o incluso un continente. Tú eres quien decide cuán preciso quieres que sea.

|c00ffff00Puedes usar el botón de la derecha para seleccionar tu ubicación actual como lugar de nacimiento.]=],
	["REG_PLAYER_BKG"] = "Diseño de fondo",
	["REG_PLAYER_BKG_TT"] = "Representa el fondo visual a elegir para tu diseño de Características.",
	["REG_PLAYER_CARACT"] = "Características",
	["REG_PLAYER_CHANGE_CONFIRM"] = [=[Puede que tengas algunos cambios sin guardar.
¿Deseas cambiar la página de todos modos?
|cffff9900Cualquier cambio se perderá.]=],
	["REG_PLAYER_CHARACTERISTICS"] = "Características",
	["REG_PLAYER_CLASS"] = "Clase",
	["REG_PLAYER_CLASS_TT"] = [=[Esta es la clase por defecto de tu personaje.

|cff00ff00Por ejemplo :|r
Caballero, pirotécnico, nigromante, arcanista...]=],
	["REG_PLAYER_COLOR_ALWAYS_DEFAULT_TT"] = [=[|cffffff00Clic:|r Selecciona un color 
|cffffff00Clic derecho:|r Descarta un color]=],
	["REG_PLAYER_COLOR_CLASS"] = "Color de clase",
	["REG_PLAYER_COLOR_CLASS_TT"] = [=[Esto determina el color en que se visualizará la clase.
]=],
	["REG_PLAYER_COLOR_TT"] = [=[|cffffff00Clic:|r Seleccionar color
|cffffff00Clic derecho:|r Descartar color]=],
	["REG_PLAYER_CURRENT"] = "Actualmente",
	["REG_COMPANIONS_SHORTDESCRIPTION"]= "Breve descripción",
	["REG_PLAYER_CURRENT_OOC"] = "Esta es información Fuera de Rol",
	["REG_PLAYER_CURRENTOOC"] = "Actualmente (FdR)",
	["REG_PLAYER_EDIT_MUSIC_THEME"] = "Tema musical",
	["REG_PLAYER_EYE"] = "Color de ojos",
	["REG_PLAYER_EYE_TT"] = [=[Aquí puedes indicar el color de ojos de tu personaje.

Ten en cuenta que, aunque tu rostro esté constantemente oculto, vale la pena mencionarlo, por si acaso.]=],
	["REG_PLAYER_FIRSTNAME"] = "Nombre",
	["REG_PLAYER_FIRSTNAME_TT"] = [=[Este es el nombre de tu personaje. Este es un campo obligatorio a rellenar, por lo que si no se especifica un nombre se usará el nombre por defecto (|cffffff00%s|r).

¡Puedes utilizar un |c0000ff00apodo|r!]=],
	["REG_PLAYER_FULLTITLE"] = "Título completo",
	["REG_PLAYER_FULLTITLE_TT"] = [=[Aquí puedes escribir el título completo de tu personaje. Puede ser una versión más larga del título u otro título completo.

Sin embargo, es posible que quieras evitar repeticiones, en caso de que no haya información adicional que mencionar.]=],
	["REG_PLAYER_GLANCE"] = "A primera vista",
	["REG_PLAYER_GLANCE_BAR_DELETED"] = "Grupo prestablecido |cffff9900%s|r eliminado.",
	["REG_PLAYER_GLANCE_BAR_EMPTY"] = "El nombre del predeterminado no puede estar vacío.",
	["REG_PLAYER_GLANCE_BAR_LOAD"] = "Grupo restablecido",
	["REG_PLAYER_GLANCE_BAR_LOAD_SAVE"] = "Grupo predeterminado",
	["REG_PLAYER_GLANCE_BAR_NAME"] = [=[Por favor introduce el nombre del predeterminado.

|cff00ff00Nota: Si el nombre ya está siendo usado por otro grupo, será remplazado por este grupo. ]=],
	["REG_PLAYER_GLANCE_BAR_SAVE"] = "Guardar grupo como predeterminado.",
	["REG_PLAYER_GLANCE_BAR_SAVED"] = "Grupo predeterminado |cff00ff00%s|r ha sido creado",
	["REG_PLAYER_GLANCE_BAR_TARGET"] = "\"A primera vista\" predeterminado",
	["REG_PLAYER_GLANCE_CONFIG"] = [=[|cff00ff00"A primera vista"|r es una serie de ranuras que puedes usar para añadir información importante sobre este personaje.

Puedes usar estas acciones en dichas ranuras:
|cffffff00Clic:|r configurar ranura
|cffffff00Doble clic:|r activar/desactivar ranura
|cffffff00Clic derecho:|r ranuras prestablecidas
|cffffff00Arrastrar y soltar:|r reordenar ranuras]=],
	["REG_PLAYER_GLANCE_EDITOR"] = "Editor de A primera vista : Ranura %s",
	["REG_PLAYER_GLANCE_MENU_COPY"] = "Copiar ranura",
	["REG_PLAYER_GLANCE_MENU_PASTE"] = "Pegar ranura: %s",
	["REG_PLAYER_GLANCE_PRESET"] = "Cargar",
	["REG_PLAYER_GLANCE_PRESET_ADD"] = "Creado prestablecido |cff00ff00%s|r.",
	["REG_PLAYER_GLANCE_PRESET_ALERT1"] = "Por favor, introduce una categoría y un nombre",
	["REG_PLAYER_GLANCE_PRESET_CATEGORY"] = "Categoría prestablecida",
	["REG_PLAYER_GLANCE_PRESET_CREATE"] = "Crear prestablecido",
	["REG_PLAYER_GLANCE_PRESET_GET_CAT"] = [=[%s

]=],
	["REG_PLAYER_GLANCE_PRESET_NAME"] = "Nombre",
	["REG_PLAYER_GLANCE_PRESET_REMOVE"] = "Eliminar prestablecido |cff00ff00%s|r.",
	["REG_PLAYER_GLANCE_PRESET_SAVE"] = "Guardar información como prestablecida",
	["REG_PLAYER_GLANCE_PRESET_SAVE_SMALL"] = "Guardar como prestablecido",
	["REG_PLAYER_GLANCE_PRESET_SELECT"] = "Seleccionar prestablecido",
	["REG_PLAYER_GLANCE_TITLE"] = "Nombre de atributo",
	["REG_PLAYER_GLANCE_UNUSED"] = "Ranura no utilizada",
	["REG_PLAYER_GLANCE_USE"] = "Activar esta ranura",
	["REG_PLAYER_HEIGHT"] = "Altura",
	["REG_PLAYER_HEIGHT_TT"] = [=[Esta es la altura de tu personaje.
Tienes varias formas de hacerlo:|c0000ff00
- Numérico: 170 cm, 6'5" ...
- Cualificativo: Alto, bajo ...]=],
	["REG_PLAYER_HERE"] = "Seleccionar posición",
	["REG_PLAYER_HERE_HOME_PRE_TT"] = [=[Actual posición de la residencia:
|cff00ff00%s|r.]=],
	["REG_PLAYER_HERE_HOME_TT"] = [=[|cffffff00Clic|r: Usar la posición actual como tu residencia.
|cffffff00Clic-derecho|r: Elimina la posición de la residencia.]=],
	["REG_PLAYER_HERE_TT"] = "|cffffff00Click|r: Seleccionar tu posición actual",
	["REG_PLAYER_HISTORY"] = "Historia",
	["REG_PLAYER_ICON"] = "Icono del personaje",
	["REG_PLAYER_ICON_TT"] = "Selecciona una representación gráfica para tu personaje.",
	["REG_PLAYER_IGNORE"] = "Ignorar personajes vinculados (%s)",
	["REG_PLAYER_IGNORE_WARNING"] = [=[¿Quieres ignorar a estos personajes?

|cffff9900%s

|rOpcionalmente puedes escribir la razón a continuación. Esta nota personal servirá como recordatorio.]=],
	["REG_PLAYER_LASTNAME"] = "Apellido",
	["REG_PLAYER_LASTNAME_TT"] = "Es el apellido de tu personaje.",
	["REG_PLAYER_LEFTTRAIT"] = "Atributo izquierdo",
	["REG_PLAYER_MISC_ADD"] = "Añadir campo adicional",
	["REG_PLAYER_MISC_PRESET_PRONOUNS"] = "Pronombres",
	["REG_PLAYER_MORE_INFO"] = "Información adicional",
	["REG_PLAYER_MSP_HOUSE"] = "Nombre de la Casa",
	["REG_PLAYER_MSP_MOTTO"] = "Lema",
	["REG_PLAYER_MSP_NICK"] = "Apodo",
	["REG_PLAYER_NAMESTITLES"] = "Nombre y títulos",
	["REG_PLAYER_NO_CHAR"] = "Sin características",
	["REG_PLAYER_NOTES"] = "Notas",
	["REG_PLAYER_NOTES_ACCOUNT"] = "Notas comunes",
	["REG_PLAYER_NOTES_ACCOUNT_HELP"] = "Estas notas privadas están ligadas a tu cuenta y se compartirán con todos tus perfiles.",
	["REG_PLAYER_NOTES_PROFILE"] = "Notas de %s",
	["REG_PLAYER_NOTES_PROFILE_HELP"] = "Estas notas privadas están ligadas a tu perfil actual y cambiarán según el perfil que tengas activado.",
	["REG_PLAYER_NOTES_PROFILE_NONAME"] = "Notas del perfil",
	["REG_PLAYER_PEEK"] = "Varios",
	["REG_PLAYER_PHYSICAL"] = "Descripción física",
	["REG_PLAYER_PSYCHO"] = "Rasgos de personalidad",
	["REG_PLAYER_PSYCHO_Acete"] = "Asceta",
	["REG_PLAYER_PSYCHO_ADD"] = "Añadir un rasgo de personalidad",
	["REG_PLAYER_PSYCHO_ATTIBUTENAME_TT"] = "Nombre del atributo",
	["REG_PLAYER_PSYCHO_Bonvivant"] = "Vividor",
	["REG_PLAYER_PSYCHO_CHAOTIC"] = "Caótico",
	["REG_PLAYER_PSYCHO_Chaste"] = "Casto",
	["REG_PLAYER_PSYCHO_Conciliant"] = "Ejemplar",
	["REG_PLAYER_PSYCHO_Couard"] = "Cobarde",
	["REG_PLAYER_PSYCHO_CREATENEW"] = "Crear rasgo",
	["REG_PLAYER_PSYCHO_Cruel"] = "Brutal",
	["REG_PLAYER_PSYCHO_CUSTOM"] = "Rasgo personalizado",
	["REG_PLAYER_PSYCHO_CUSTOMCOLOR"] = "Seleccionar color de atributo",
	["REG_PLAYER_PSYCHO_CUSTOMCOLOR_LEFT_TT"] = [=[Selecciona un color para la barra del atributo de la izquierda

|cffffff00Click:|r Seleccionar color
|cffffff00Click derecho:|r Descartar color
|cffffff00Mayus + click:|r Usar seleccionador de color por defecto]=],
	["REG_PLAYER_PSYCHO_CUSTOMCOLOR_RIGHT_TT"] = [=[Selecciona un color para la barra del atributo de la derecha.

|cffffff00Clic:|r Seleccionar color
|cffffff00Clic derecho:|r Descartar color
|cffffff00Shift+click:|r Usar el seleccionador de color por defecto]=],
	["REG_PLAYER_PSYCHO_Egoiste"] = "Egoísta",
	["REG_PLAYER_PSYCHO_Genereux"] = "Altruista",
	["REG_PLAYER_PSYCHO_Impulsif"] = "Impulsivo",
	["REG_PLAYER_PSYCHO_Indulgent"] = "Indulgente",
	["REG_PLAYER_PSYCHO_LEFTICON_TT"] = "Establece el icono del atributo de la izquierda",
	["REG_PLAYER_PSYCHO_Loyal"] = "Legal",
	["REG_PLAYER_PSYCHO_Luxurieux"] = "Lujurioso",
	["REG_PLAYER_PSYCHO_Misericordieux"] = "Pacífico",
	["REG_PLAYER_PSYCHO_MORE"] = "Añadir un punto a \"%s\"",
	["REG_PLAYER_PSYCHO_PERSONAL"] = "Características personales",
	["REG_PLAYER_PSYCHO_Pieux"] = "Supersticioso",
	["REG_PLAYER_PSYCHO_POINT"] = "Añadir un punto",
	["REG_PLAYER_PSYCHO_Pragmatique"] = "Renegado",
	["REG_PLAYER_PSYCHO_Rationnel"] = "Racional",
	["REG_PLAYER_PSYCHO_Reflechi"] = "Cauteloso",
	["REG_PLAYER_PSYCHO_Rencunier"] = "Vengativo",
	["REG_PLAYER_PSYCHO_RIGHTICON_TT"] = "Establece el icono del atributo de la derecha.",
	["REG_PLAYER_PSYCHO_Sincere"] = "Sincero",
	["REG_PLAYER_PSYCHO_SOCIAL"] = "Rasgos personales",
	["REG_PLAYER_PSYCHO_Trompeur"] = "Embustero",
	["REG_PLAYER_PSYCHO_Valeureux"] = "Valeroso",
	["REG_PLAYER_RACE"] = "Raza",
	["REG_PLAYER_RACE_TT"] = "Aquí va la raza de tu personaje. No está restringido a las razas jugables. Hay muchas razas del Warcraft que pueden asumir formas comunes...",
	["REG_PLAYER_REGISTER"] = "Información del directorio",
	["REG_PLAYER_RELATIONSHIP_STATUS"] = "Estado de relación",
	["REG_PLAYER_RELATIONSHIP_STATUS_DIVORCED"] = "Divorciado",
	["REG_PLAYER_RELATIONSHIP_STATUS_MARRIED"] = "Casado",
	["REG_PLAYER_RELATIONSHIP_STATUS_SINGLE"] = "Soltero",
	["REG_PLAYER_RELATIONSHIP_STATUS_TAKEN"] = "En pareja",
	["REG_PLAYER_RELATIONSHIP_STATUS_TT"] = "Indica el estado de relación de tu personaje. Selecciona \"No mostrar\" si quieres mantener esta información oculta.",
	["REG_PLAYER_RELATIONSHIP_STATUS_UNKNOWN"] = "No mostrar",
	["REG_PLAYER_RELATIONSHIP_STATUS_WIDOWED"] = "Viudo",
	["REG_PLAYER_RESIDENCE"] = "Residencia",
	["REG_PLAYER_RESIDENCE_SHOW"] = "Coordenadas de residencia",
	["REG_PLAYER_RESIDENCE_SHOW_TT"] = [=[|cff00ff00%s

|rClick para que aparezca en el mapa]=],
	["REG_PLAYER_RESIDENCE_TT"] = [=[Aquí puedes indicar donde vive el personaje normalmente. Esta podría ser su dirección personal (su casa) o el lugar donde se hospeda.
Ten en cuenta que si tu personaje es un vagabundo, tendrás que cambiar la información.

|c00ffff00Puedes utilizar el botón de la derecha para fijar la posición actual como residencia.]=],
	["REG_PLAYER_RIGHTTRAIT"] = "Atributo derecho",
	["REG_PLAYER_SHOWMISC"] = "Mostrar marco de varios",
	["REG_PLAYER_SHOWMISC_TT"] = [=[Márcalo si quieres mostrar los campos personalizados para tu personaje.

Si no quieres mostrar los campos personalizados, mantén esta casilla sin marcar y se mantendrá totalmente oculta.]=],
	["REG_PLAYER_SHOWPSYCHO"] = "Mostrar el marco de personalidad",
	["REG_PLAYER_SHOWPSYCHO_TT"] = [=[Marca si quieres utilizar la descripción del personaje.

Si no quieres mostrar la personalidad del personaje mediante este método, mantén esta casilla sin marcar y se mantendrá totalmente oculta.]=],
	["REG_PLAYER_STYLE_ASSIST"] = "Asistencia de rol",
	["REG_PLAYER_STYLE_BATTLE"] = "Resolución de batallas de rol",
	["REG_PLAYER_STYLE_BATTLE_1"] = "World of Warcraft PVP",
	["REG_PLAYER_STYLE_BATTLE_2"] = "Batalla a dados TRP",
	["REG_PLAYER_STYLE_BATTLE_3"] = "Batalla a dados",
	["REG_PLAYER_STYLE_BATTLE_4"] = "Batalla a emotes",
	["REG_PLAYER_STYLE_DEATH"] = "Aceptación de muerte",
	["REG_PLAYER_STYLE_EMPTY"] = "Sin atributos de rol compartidos",
	["REG_PLAYER_STYLE_FREQ"] = "Frecuencia de rol",
	["REG_PLAYER_STYLE_FREQ_1"] = "Todo el tiempo",
	["REG_PLAYER_STYLE_FREQ_2"] = "La mayoría de las veces",
	["REG_PLAYER_STYLE_FREQ_3"] = "La mitad del tiempo",
	["REG_PLAYER_STYLE_FREQ_4"] = "A veces",
	["REG_PLAYER_STYLE_FREQ_5"] = "No es un personaje de rol",
	["REG_PLAYER_STYLE_GUILD"] = "Miembro de hermandad",
	["REG_PLAYER_STYLE_GUILD_IC"] = "Miembro ER",
	["REG_PLAYER_STYLE_GUILD_OOC"] = "Miembro FdR",
	["REG_PLAYER_STYLE_HIDE"] = "No mostrar",
	["REG_PLAYER_STYLE_INJURY"] = "Aceptación de heridas",
	["REG_PLAYER_STYLE_PERMI"] = "Con el permiso del jugador",
	["REG_PLAYER_STYLE_ROMANCE"] = "Aceptación de romances",
	["REG_PLAYER_STYLE_RPSTYLE"] = "Estilo de rol",
	["REG_PLAYER_STYLE_RPSTYLE_SHORT"] = "Estilo ER",
	["REG_PLAYER_STYLE_WOWXP"] = "Experiencia en World of Warcraft",
	["REG_PLAYER_TITLE"] = "Título",
	["REG_PLAYER_TITLE_TT"] = [=[El título de tu personaje es el título con el que tu personaje es llamado normalmente. Evita colocar títulos largos, para ello se ha de utilizar el título completo.

Ejemplos de |c0000ff00títulos apropiados|r:
|c0000ff00- Condesa,
- Marqués,
- Mago,
- Señor,
- etc.
|rEjemplo de |cffff0000títulos inapropiados|r:
|cffff0000- Condesa de las Marismas del Norte,
- Mago de la Torre de Ventormenta,
- Diplomático de los draenei,
- etc.]=],
	["REG_PLAYER_TRP2_PIERCING"] = "Piercings",
	["REG_PLAYER_TRP2_TATTOO"] = "Tatuajes",
	["REG_PLAYER_TRP2_TRAITS"] = "Fisionomía",
	["REG_PLAYER_TUTO_ABOUT_COMMON"] = [=[|cff00ff00Tema del personaje:|r
Puedes elegir un |cffffff00tema|r para tu personaje. Piensa en ello como una |cffffff00música de ambientación para la lectura de la descripción de tu personaje.

|cff00ff00Fondo:|r
Este es el |cffffff00tipo de fondo|r para la descripción de tu personaje.

|cff00ff00Plantilla:|r
La plantilla elegida define |cffffff00las posibilidades del diseño y escritura generales|r para tu descripción.
|cffff9900Sólo la plantilla seleccionada se verá, no hace falta rellenar todas.|r
Una vez elegida la plantilla puedes volver a abrir este tutorial para tener más ayuda sobre cada plantilla.]=],
	["REG_PLAYER_TUTO_ABOUT_MISC_1"] = [=[Esta selección te ofrece |cffffff005 ranuras|r con las que se puede describir |cff00ff00las piezas más importantes de tu personaje|r.

Estas ranuras serán visibles en |cffffff00"A primera vista"|r cuando alguien seleccione a tu personaje.

|cff00ff00Sugerencia: Puedes arrastrar y soltar ranuras para reorganizarlas.|r
¡Esto también funciona en la |cffffff00barra de "A primera vista"|r!]=],
	["REG_PLAYER_TUTO_ABOUT_MISC_3"] = "Esta sección contiene |cffffff00una lista de notas|r para responder muchas |cffffff00preguntas comunes que la gente podría preguntarse acerca de ti, sobre tu personaje y la forma en que deseas interpretarlo|r.",
	["REG_PLAYER_TUTO_ABOUT_T1"] = [=[Esta plantilla te permite |cff00ff00estructurar libremente tu descripción|r.

La descripción no tiene que limitarse a la |cffff9900descripción física|r de tu personaje. Siéntete libre para indicar parte de su |cffff9900trasfondo|r o detalles sobre su |cffff9900personalidad|r.

Con esta plantilla se pueden utilizar las herramientas de formato para acceder a varios parámetros de diseño como el |cffffff00tamaño del texto, color o alineacioness|r.
Esta herramienta también permite insertar |cffffff00imágenes, iconos o links externos de sitios webs|r.]=],
	["REG_PLAYER_TUTO_ABOUT_T2"] = [=[Esta plantilla es más estructurada y consiste en |cff00ff00una lista de marcos independientes|r.

Cada marco se caracteriza por un |cffffff00icono, un fondo y un texto|r. Ten en cuenta que puedes utilizar algunas etiquetas de texto en estos recuadros, como el color y las etiquetas de icono de texto.

La descripción no tiene que limitarse a la descripción física|r de tu personaje. Siéntete libre para indicar parte de tu |cffff9900trasfondo|r o detalles sobre tu |cffff9900personalidad|r.]=],
	["REG_PLAYER_TUTO_ABOUT_T3"] = [=[Esta plantilla está separada en 3 secciones: |cff00ff00Descripción física, personalidad y trasfondo|r.

No hace falta llenar todos los cuadros, |cffff9900si dejas un cuadro vacío no se mostrará en tu descripción|r.

Cada cuadro se caracteriza por un |cffffff00icono, un fondo y un texto|r. Ten en cuenta que puedes utilizar algunas etiquetas de texto en estos cuadros, como el color y las etiquetas de iconos de texto.]=],
	["REG_PLAYER_WEIGHT"] = "Complexión",
	["REG_PLAYER_WEIGHT_TT"] = [=[Esta es la complexión de tu personaje.
Por ejemplo podría ser |c0000ff00delgado, gordo o musculoso...|r ¡O simplemente podría ser normal!]=],
	["REG_PLAYERS"] = "Jugadores",
	["REG_REGISTER"] = "Directorio",
	["REG_REGISTER_CHAR_LIST"] = "Lista de personajes",
	["REG_RELATION"] = "Relación",
	["REG_RELATION_BUSINESS"] = "Negocios",
	["REG_RELATION_BUSINESS_TT"] = "%s y %s tienen una relación de negocios",
	["REG_RELATION_BUTTON_TT"] = [=[Relación: %s
|cff00ff00%s

|cffffff00Haz clic para mostrar las acciones posibles]=],
	["REG_RELATION_FAMILY"] = "Familia",
	["REG_RELATION_FAMILY_TT"] = "%s comparte un vínculo de sangre con %s.",
	["REG_RELATION_FRIEND"] = "Amistoso",
	["REG_RELATION_FRIEND_TT"] = "%s considera a %s amigo.",
	["REG_RELATION_LOVE"] = "Amor",
	["REG_RELATION_LOVE_TT"] = "%s está enamorado de %s",
	["REG_RELATION_NEUTRAL"] = "Neutral",
	["REG_RELATION_NEUTRAL_TT"] = "%s conoce a %s.",
	["REG_RELATION_NONE"] = "Ninguna",
	["REG_RELATION_NONE_TT"] = "%s no conoce a %s.",
	["REG_RELATION_TARGET"] = "|cffffff00Clic: |rCambiar relación",
	["REG_RELATION_UNFRIENDLY"] = "Enemigo",
	["REG_RELATION_UNFRIENDLY_TT"] = "%s está enemistado con %s.",
	["REG_REPORT_PLAYER_OPEN_URL"] = [=[Solo puedes denunciar a jugadores desde el juego si los marcas como objetivo (usa el botón de marco de objetivo de TRP3).

Si quieres denunciar el perfil de %s y no puedes marcarlo como objetivo tendrás que enviar un ticket al soporte de Blizzard usando el link a continuación.]=],
	["REG_REPORT_PLAYER_OPEN_URL_160"] = "Si quieres denunciar el perfil de %s tendrás que enviar un ticket al soporte de Blizzard usando el link a continuación.",
	["REG_REPORT_PLAYER_PROFILE"] = "Denunciar perfil a |cff449fe0Blizzard|r",
	["REG_REPORT_PLAYER_PROFILE_TT"] = [=[Puedes denunciar un perfil que infrinja los Términos de Servicio de Blizzard. Esto puede incluir acoso, publicación de información privada, lenguaje de odio, contenido obsceno u otras formas de contenido inadecuado.

|cffff0000Recuerda que esta opción no es para denunciar perfiles de rol de baja calidad. ¡Los abusos de esta función serán sancionados!]=],
	["REG_REPORT_PLAYER_TEMPLATE"] = "Este jugador está usando el perfil de rol %s del addon para compartir contenido en contra de los Términos de Servicio.",
	["REG_REPORT_PLAYER_TEMPLATE_DATE"] = "La información del addon fue transferida a través del historial de mensajes del addon en %s.",
	["REG_REPORT_PLAYER_TEMPLATE_TRIAL_ACCOUNT"] = "Este jugador tiene una cuenta de prueba.",
	["REG_TIME"] = "Última vez visto",
	["REG_TRIAL_ACCOUNT"] = "Cuenta de prueba",
	["REG_TT_GUILD"] = "%s de |cffff9900%s",
	["REG_TT_GUILD_IC"] = "Miembro ER",
	["REG_TT_GUILD_OOC"] = "Miembro FdR",
	["REG_TT_IGNORED"] = "<Personaje ignorado>",
	["REG_TT_IGNORED_OWNER"] = "<Propietario ignorado>",
	["REG_TT_LEVEL"] = "Nivel %s %s",
	["REG_TT_NOTIF"] = "Descripción sin leer",
	["REG_TT_REALM"] = "Reino: |cffff9900%s",
	["REG_TT_TARGET"] = "Objetivo: |cffff9900%s",
	["REG_TT_ZONE"] = "Zona",
	["SCRIPT_ERROR"] = "Error en el script.",
	["SCRIPT_UNKNOWN_EFFECT"] = "Error de script, FX desconocido",
	["SLASH_CMD_STATUS_USAGE"] = "ep || fdp || mostrar/ocultar",
	["TB_AFK_MODE"] = "Ausente",
	["TB_DND_MODE"] = "No molestar",
	["TB_GO_TO_MODE"] = "Cambiar a %s",
	["TB_LANGUAGE"] = "Idioma",
	["TB_LANGUAGES_TT"] = "Cambiar idioma",
	["TB_NORMAL_MODE"] = "Normal",
	["TB_RPSTATUS_OFF"] = "Personaje: |cffff0000Fuera de rol",
	["TB_RPSTATUS_ON"] = "Personaje: |cff00ff00En rol",
	["TB_RPSTATUS_TO_OFF"] = "Cambiar a |cffff0000Fuera de rol",
	["TB_RPSTATUS_TO_ON"] = "Cambiar a |cff00ff00En rol",
	["TB_STATUS"] = "Jugador",
	["TB_SWITCH_CAPE_1"] = "Mostrar capa",
	["TB_SWITCH_CAPE_2"] = "Ocultar capa",
	["TB_SWITCH_CAPE_OFF"] = "Capa: |cffff0000Oculta",
	["TB_SWITCH_CAPE_ON"] = "Capa: |cffff0000Mostrada",
	["TB_SWITCH_HELM_1"] = "Mostrar yelmo",
	["TB_SWITCH_HELM_2"] = "Ocultar yelmo",
	["TB_SWITCH_HELM_OFF"] = "Yelmo: |cffff0000Oculto",
	["TB_SWITCH_HELM_ON"] = "Yelmo: |cffff0000Mostrado",
	["TB_SWITCH_PROFILE"] = "Cambiar a otro perfil",
	["TB_SWITCH_TOOLBAR"] = "Cambiar barra de herramientas",
	["TB_TOOLBAR"] = "Barra de herramientas",
	["TF_IGNORE"] = "Ignorar jugador",
	["TF_IGNORE_CONFIRM"] = [=[¿Estás seguro que deseas ignorar esta ID?

|cffffff00%s|r

|cffff7700Opcionalmente puedes escribir debajo la razón por la que le quieres ignorar. Esta es una nota personal, no será visible por otros y servirá como recordatorio.]=],
	["TF_IGNORE_NO_REASON"] = "Sin razón",
	["TF_IGNORE_TT"] = "|cffffff00Click:|r Ignorar jugador",
	["TF_OPEN_CHARACTER"] = "Mostrar página del personaje",
	["TF_OPEN_COMPANION"] = "Mostrar página del compañero",
	["TF_OPEN_MOUNT"] = "Mostrar página de montura",
	["TF_PLAY_THEME"] = "Sonar tema del personaje",
	["TF_PLAY_THEME_TT"] = [=[|cffffff00Clic:|r Tocar |cff00ff00%s
|cffffff00Clic-derecho:|r Parar tema]=],
	["THANK_YOU_1"] = [=[{h1:c}Total RP 3{/h1}
{p:c}{col:6eff51}Versión %s (build %s){/col}{/p}
{p:c}{link*http://totalrp3.info*TotalRP3.info}{/p}

{h2}{icon:INV_Eng_gizmo1:20} Creado por{/h2}
- Morgane "{twitter*EllypseCelwe*Ellypse}" Parize
- Sylvain "{twitter*Telkostrasz*Telkostrasz}" Cossement


{h2}{icon:THUMBUP:20} Reconocimientos{/h2}
{col:ffffff}Logo e icono del botón del minimapa:{/col}
- {link*https://twitter.com/Kelandiir*@Kelandiir}

{col:ffffff}Nuestro equipo PR pre-alpha:{/col}
- Saelora
- Erzan
- Calian
- Kharess
- Alnih
- 611

{col:ffffff}Gracias a todos nuestros amigos por su apoyo todos estos años:{/col}
- Para Telkos: Kharess, Kathryl, Marud, Solona, Stretcher, Lisma...
- Para Ellypse: Las hermandades Maison Celwë'Belore, Mercenaires Atal'ai, y más particularmente Erzan, Elenna, Caleb, Siana and Adaeria

{col:ffffff}Por ayudarnos a crear la hermandad Total RP en Kirin Tor (EU):{/col}
- Azane
- Hellclaw
- Leylou]=],
	["THANK_YOU_ROLE_AUTHOR"] = "Autor",
	["THANK_YOU_ROLE_COMMUNITY_MANAGER"] = "Administrador de la comunidad",
	["THANK_YOU_ROLE_CONTRIBUTOR"] = "Colaborador",
	["THANK_YOU_ROLE_GUILD_MEMBER"] = "Miembro de hermandad",
	["THANK_YOU_ROLE_TESTER"] = "Control de Calidad",
	["TT_ELVUI_SKIN"] = "Skin ElvUI",
	["TT_ELVUI_SKIN_ENABLE_TARGET_FRAME"] = "Aspecto del marco de objetivo",
	["TT_ELVUI_SKIN_ENABLE_TOOLTIPS"] = "Herramientas de aspecto",
	["UI_BKG"] = "Trasfondo %s",
	["UI_CLOSE_ALL"] = "Cerrar todo",
	["UI_COLOR_BROWSER"] = "Buscador de color",
	["UI_COLOR_BROWSER_PRESETS"] = "Preselección",
	["UI_COLOR_BROWSER_PRESETS_BASIC"] = "Básico",
	["UI_COLOR_BROWSER_PRESETS_CLASSES"] = "Clase",
	["UI_COLOR_BROWSER_PRESETS_CUSTOM"] = "Personalizado",
	["UI_COLOR_BROWSER_PRESETS_ITEMS"] = "Calidad de objeto",
	["UI_COLOR_BROWSER_PRESETS_RESOURCES"] = "Recursos",
	["UI_COLOR_BROWSER_SELECT"] = "Seleccionar color",
	["UI_COMPANION_BROWSER_HELP"] = "Seleccionar compañero",
	["UI_COMPANION_BROWSER_HELP_TT"] = [=[|cffffff00Advertencia: |rSólo los compañeros renombrados pueden vincularse a un perfil..

|cff00ff00Esta sección sólo muestra a estos compañeros.]=],
	["UI_FILTER"] = "Filtro",
	["UI_ICON_BROWSER"] = "Buscador de icono",
	["UI_ICON_BROWSER_HELP"] = "Copiar icono",
	["UI_ICON_BROWSER_HELP_TT"] = [=[Mientras este marco esté abierto puedes hacer |cffffff00ctrl + clic|r en un icono para copiar su nombre.

Esto funcionará en:|cff00ff00
- Cualquier objeto de tu mochila
- Cualquier icono del libro de hechizos|r]=],
	["UI_ICON_SELECT"] = "Seleccionar icono",
	["UI_IMAGE_BROWSER"] = "Buscador de imagen",
	["UI_IMAGE_SELECT"] = "Seleccionar imagen",
	["UI_LINK_SAFE"] = "Aquí está el link URL.",
	["UI_LINK_TEXT"] = "Escribe aquí",
	["UI_LINK_URL"] = "http://tu.url.aqui",
	["UI_LINK_WARNING"] = [=[Aquí está el enlace URL.
Puedes copiar/pegar desde tu navegador web.

|cffff0000¡¡Atención!!|r
Total RP no es responsable de los enlaces que conducen a contenidos nocivos.]=],
	["UI_MUSIC_BROWSER"] = "Buscador de tema",
	["UI_MUSIC_DURATION"] = "Duración",
	["UI_MUSIC_SELECT"] = "Seleccionar música",
	["UI_TUTO_BUTTON"] = "Modo tutorial",
	["UI_TUTO_BUTTON_TT"] = "Haz clic para activar/desactivar el modo tutorial",
	["UNIT_POPUPS_CONFIG_SHOW_OPEN_PROFILE"] = "Mostrar el botón de Abrir Perfil",
	["UNIT_POPUPS_CONFIG_VISIBILITY_HEADER"] = "Opciones de visibilidad",
	["UNIT_POPUPS_CURRENT_PROFILE"] = "Perfil Actual",
	["UNIT_POPUPS_CURRENT_PROFILE_NAME"] = "Perfil Actual: %1$s",
	["UNIT_POPUPS_OPEN_PROFILE"] = "Abrir Perfil",
	["UNIT_POPUPS_ASSIGN_FLAG"] = "Asignar Perfil",
	["UNIT_POPUPS_ROLEPLAY_OPTIONS_HEADER"] = "Opciones de Roleplay",
	["WHATS_NEW_23"] = [=[# Historial de cambios de la versión 1.6.0

## Notas personales

¡Ahora puedes escribir notas personales en el addon!

Estas notas podrán ser escritas tanto en tu propio perfil (si quieres tomar notas genéricas para tu personaje) o en el de otra persona (el campo superior ligado a tu perfil actual, el campo inferior es el común a todos tus perfiles). Estas notas son obviamente privadas, por lo que solo tú podrás verlas.

{img:Interface\AddOns\totalRP3\resources\160-1.tga:480:480}

Para acceder a las notas personales, haz clic en el nuevo botón Notas del marco del objetivo, o abre un perfil y haz clic en la pestaña de Notas.

{img:Interface\AddOns\totalRP3\resources\160-2.tga:240:120}

El registro también tiene una casilla de verificación para solo mostrar aquellos perfiles en los que hayas escrito notas.

{img:Interface\AddOns\totalRP3\resources\160-3.tga:480:120}

## Añadido

- Se ha añadido soporte HTML para los modelos 2 y 3 de Acerca de. Puedes formar etiquetas HTML mientras usas dichos modelos para dar formato a los campos, usando la barra de herramientas que ahora es visible para todos los modelos.

{img:Interface\AddOns\totalRP3\resources\160-4.tga:480:480}

- Se ha agregado compatibilidad con otros addons de rol para los rasgos de personalidad y etiquetas HTML.

## Cambios

- Los botones de "Reportar perfil" ahora llevarán a [la página de soporte de acoso a través de addons] (https://battle.net/support/help/product/wow/197/1501/solution), puesto que la herramienta de reporte del juego anteriormente añadido era un método inválido para reportar el abuso del addon. El popup mostrará la hora en la recepción del perfil, lo cual puedes proporcionar al soporte de Blizzard para ayudarles a rastrear la ofensa.

## Arreglado

- Se ha arreglado un error que provocaba que el addon no cargara.
- Se ha solventado un problema de compatibilidad con el modelo 3 si el idioma del addon no era el inglés.

## Eliminado

- Se ha eliminado el resaltado automático del texto al ingresar el foco de un área de texto (campos Acerca de, Actualmente, Fuera de personaje, Información...)
- Se ha eliminado el código de April Fool's (incluido el olvidado arcoíris en los nombres de compañero).]=],
	["WHATS_NEW_24_9"] = "# Cambios en la versión 2.3.6 ## Agregado - Agregados 323 nuevos íconos, 7 imágenes y 138 nuevos archivos de música del parche 9.1.0. ## Removido - Se ha removido la bandera del lenguaje de roleplay. - Se ha corregido un error con los canales de chat de Classic."
}

TRP3_API.loc:RegisterNewLocale("esES", "Español (EU)", localeContent);

localeContent = {
	["ABOUT_TITLE"] = "Acerca de",
	["BINDING_NAME_TRP3_OPEN_TARGET_PROFILE"] = "Abrir perfil del objetivo",
	["BINDING_NAME_TRP3_TOGGLE"] = "Mostrar/ocultar la ventana principal",
	["BINDING_NAME_TRP3_TOOLBAR_TOGGLE"] = "Mostrar/ocultar barra de herramientas",
	["BLIZZARD_NAMEPLATES_MODULE_NAME"] = "Placa de nombres de Blizzard",
	["BW_COLOR_CODE"] = "Código de color",
	["BW_COLOR_CODE_ALERT"] = "¡Código hexadecimal erróneo!",
	["BW_COLOR_CODE_TT"] = "Pega un código hexadecimal de 6 cifras aquí y presiona Enter.",
	["BW_COLOR_PRESET_SAVE"] = "Guardar color actual",
	["BW_CUSTOM_NAME"] = "Color del nombre personalizado",
	["BW_CUSTOM_NAME_TITLE"] = "Nombre (Opcional)",
	["CL_COMPANION_PROFILE"] = "Perfil de mascota",
	["CL_CONTENT_SIZE"] = "Tamaño: %s",
	["CL_EXPIRED"] = "Este enlace ha caducado.",
	["CL_IMPORT_COMPANION"] = "Importar perfil de mascota",
	["CL_IMPORT_PROFILE"] = "Importar perfil",
	["CL_MAKE_NON_IMPORTABLE"] = "Sólo visible",
	["CL_OPEN_COMPANION"] = "Abrir perfil de mascota",
	["CL_OPEN_PROFILE"] = "Abrir perfil",
	["CL_PLAYER_PROFILE"] = "Perfil de jugador",
	["CL_SENDING_COMMAND"] = "Enviando comando...",
	["CL_SENT_BY"] = "Enlace enviado por: %s",
	["CL_TOOLTIP"] = "Crear un link de chat",
	["CL_VERSIONS_DIFFER"] = "Este link ha sido generado a través de una versión diferente de Total RP 3. Importar contenido desde otra versión puede causar problemas de compatibilidad. ¿Quieres proceder de todos modos?",
	["CM_ACTIONS"] = "Acciones",
	["CM_ALT"] = "Alt",
	["CM_APPLY"] = "Aplicar",
	["CM_BLACK"] = "Negro",
	["CM_BLUE"] = "Azúl",
	["CM_CANCEL"] = "Cancelar",
	["CM_CENTER"] = "Centro",
	["CM_CLASS_DEATHKNIGHT"] = "Caballero de la muerte",
	["CM_CLASS_DEMONHUNTER"] = "Cazador de demonios",
	["CM_CLASS_DRUID"] = "Druida",
	["CM_CLASS_HUNTER"] = "Cazador",
	["CM_CLASS_MAGE"] = "Mago",
	["CM_CLASS_MONK"] = "Monje",
	["CM_CLASS_PALADIN"] = "Paladín",
	["CM_CLASS_PRIEST"] = "Sacerdote",
	["CM_CLASS_ROGUE"] = "Pícaro",
	["CM_CLASS_SHAMAN"] = "Chamán",
	["CM_CLASS_UNKNOWN"] = "Desconocido",
	["CM_CLASS_WARLOCK"] = "Brujo",
	["CM_CLASS_WARRIOR"] = "Guerrero",
	["CM_CLICK"] = "Clic",
	["CM_COLOR"] = "Color",
	["CM_CTRL"] = "Ctrl",
	["CM_CYAN"] = "Celeste",
	["CM_DELETE"] = "Borrar",
	["CM_DOUBLECLICK"] = "Doble click",
	["CM_DRAGDROP"] = "Arrastrar y soltar",
	["CM_EDIT"] = "Editar",
	["CM_GREEN"] = "Verde",
	["CM_GREY"] = "Gris",
	["CM_IC"] = "IC",
	["CM_ICON"] = "Icono",
	["CM_IMAGE"] = "Imagen",
	["CM_L_CLICK"] = "Clic izquierdo",
	["CM_LEFT"] = "Izquierda",
	["CM_LINK"] = "Enlace",
	["CM_LOAD"] = "Cargar",
	["CM_M_CLICK"] = "Clic medio",
	["CM_MOVE_DOWN"] = "Mover hacia abajo",
	["CM_MOVE_UP"] = "Mover hacia arriba",
	["CM_NAME"] = "Nombre",
	["CM_OOC"] = "FdP",
	["CM_OPEN"] = "Abrir",
	["CM_ORANGE"] = "Naranja",
	["CM_PINK"] = "Rosa",
	["CM_PLAY"] = "Reproducir",
	["CM_PURPLE"] = "Morado",
	["CM_R_CLICK"] = "Clic derecho",
	["CM_RED"] = "Rojo",
	["CM_REMOVE"] = "Suprimir",
	["CM_RESET"] = "Reiniciar",
	["CM_RESIZE"] = "Redimensionar",
	["CM_RESIZE_TT"] = "Arrastra para redimensionar la ventana.",
	["CM_RIGHT"] = "Derecha",
	["CM_SAVE"] = "Guardar",
	["CM_SELECT"] = "Seleccionar",
	["CM_SHIFT"] = "Shift",
	["CM_SHOW"] = "Mostrar",
	["CM_STOP"] = "Parar",
	["CM_TWEET"] = "Enviar un tweet",
	["CM_TWEET_PROFILE"] = "Mostrar url del perfil",
	["CM_UNKNOWN"] = "Desconocido",
	["CM_VALUE"] = "Valor",
	["CM_WHITE"] = "Blanco",
	["CM_YELLOW"] = "Amarillo",
	["CO_ADVANCED_LANGUAGES"] = "Lenguajes",
	["CO_ADVANCED_LANGUAGES_REMEMBER"] = "Recordar el último lenguaje usado",
	["CO_ADVANCED_LANGUAGES_REMEMBER_TT"] = "Total RP 3 recordará el lenguaje que usaste la última vez que iniciaste sesión y automáticamente seleccionará ese lenguaje cuando vuelvas a iniciar.",
	["CO_ADVANCED_SETTINGS"] = "Configuraciones avanzadas",
	["CO_ADVANCED_SETTINGS_MENU_NAME"] = "Avanzado",
	["CO_ADVANCED_SETTINGS_RESET"] = "Reiniciar configuraciones avanzadas",
	["CO_ANCHOR_BOTTOM"] = "Botón",
	["CO_ANCHOR_BOTTOM_LEFT"] = "Botón izquierdo",
	["CO_ANCHOR_BOTTOM_RIGHT"] = "Botón derecho",
	["CO_ANCHOR_CURSOR"] = "Mostrar sobre cursor",
	["CO_ANCHOR_LEFT"] = "Izquierda",
	["CO_ANCHOR_RIGHT"] = "Derecha",
	["CO_ANCHOR_TOP"] = "Arriba",
	["CO_ANCHOR_TOP_LEFT"] = "Arriba a la izquierda",
	["CO_ANCHOR_TOP_RIGHT"] = "Arriba a la derecha",
	["CO_CHAT"] = "Ajustes del chat",
	["CO_CHAT_DISABLE_OOC"] = "Desactivar las personalizaciones cuando esté FdP",
	["CO_CHAT_INSERT_FULL_RP_NAME"] = "Insertar nombres de rol con shift+clic",
	["CO_CHAT_MAIN"] = "Ajustes de chat principal",
	["CO_CHAT_MAIN_COLOR"] = "Usar colores personalizados para los nombres",
	["CO_CHAT_MAIN_EMOTE"] = "Detección de emociones",
	["CO_CHAT_MAIN_EMOTE_PATTERN"] = "Patrón de detección de emociones",
	["CO_CHAT_MAIN_EMOTE_USE"] = "Usar detección de emociones",
	["CO_CHAT_MAIN_EMOTE_YELL"] = "Emoción sin gritos",
	["CO_CHAT_MAIN_EMOTE_YELL_TT"] = "No mostrar *emote* o <emote> en los gitos",
	["CO_CHAT_MAIN_NAMING"] = "Método de nomenclatura",
	["CO_CHAT_MAIN_NAMING_1"] = "Mantener nombres originales",
	["CO_CHAT_MAIN_NAMING_2"] = "Usar nombres originales",
	["CO_CHAT_MAIN_NAMING_3"] = "Nombre + apellido",
	["CO_CHAT_MAIN_NAMING_4"] = "Título corto + nombre + apellido",
	["CO_CHAT_MAIN_NPC"] = "Detección de diálogo de NPC",
	["CO_CHAT_MAIN_NPC_PREFIX"] = "Patrón de detección de diálogo de NPC",
	["CO_CHAT_MAIN_NPC_USE"] = "Usar detección de diálogo de NPC",
	["CO_CHAT_MAIN_OOC"] = "Detección OOC",
	["CO_CHAT_MAIN_OOC_COLOR"] = "Color OOC",
	["CO_CHAT_MAIN_OOC_PATTERN"] = "Patrón de detección OOC",
	["CO_CHAT_MAIN_OOC_USE"] = "Usar detección OOC",
	["CO_CHAT_REMOVE_REALM"] = "Remover reino del nombre de los jugadores",
	["CO_CHAT_SHOW_OOC"] = "Mostrar indicador FdP",
	["CO_CHAT_USE"] = "Canales de chat usados",
	["CO_CHAT_USE_ICONS"] = "Mostrar íconos del jugador",
	["CO_CHAT_USE_SAY"] = "Canal /decir",
	["CO_CONFIGURATION"] = "Ajustes",
	["CO_CURSOR_DISABLE_OOC"] = "Deshabilitar en modo FdP",
	["CO_CURSOR_DISABLE_OOC_TT"] = "Deshabilita las modificaciones del cursor cuando estás en modo |cffccccccFuera de Personaje|r.",
	["CO_CURSOR_RIGHT_CLICK"] = "Clic derecho para abrir el perfil",
	["CO_CURSOR_TITLE"] = "Interacciones del cursor",
	["CO_GENERAL"] = "Ajustes generales",
	["CO_GENERAL_BROADCAST"] = "Usar canal de emisión",
	["CO_GENERAL_BROADCAST_C"] = "Nombre del canal de emisión",
	["CO_GENERAL_COM"] = "Comunicación",
	["CO_GENERAL_HEAVY"] = "Alerta de perfil sobrecargado",
	["CO_GENERAL_HEAVY_TT"] = "Ser avisado cuando el tamaño del perfil exceda un valor razonable.",
	["CO_GENERAL_LOCALE"] = "Idioma",
	["CO_GENERAL_MISC"] = "Miscelánea",
	["CO_GENERAL_NEW_VERSION"] = "Alerta de actualización",
	["CO_GENERAL_NEW_VERSION_TT"] = "Ser avisado cuando haya una nueva versión disponible.",
	["CO_GENERAL_TT_SIZE"] = "Información sobre herramientas del tamaño del texto",
	["CO_GENERAL_UI_ANIMATIONS"] = "Animaciones de la IU",
	["CO_GENERAL_UI_ANIMATIONS_TT"] = "Activar las animaciones de la IU.",
	["CO_GENERAL_UI_SOUNDS"] = "Sonidos de la IU.",
	["CO_GENERAL_UI_SOUNDS_TT"] = "Activar sonidos de la IU (al abrir ventanas, cambiar de pestañas, pulsar botones).",
	["CO_GLANCE_LOCK"] = "Bloquear barra",
	["CO_GLANCE_LOCK_TT"] = "Previene que la barra sea desplazada.",
	["CO_GLANCE_MAIN"] = "Barra \"a primera vista\"",
	["CO_GLANCE_PRESET_TRP2"] = "Usar el estilo de posiciones de Total RP 2",
	["CO_GLANCE_PRESET_TRP2_BUTTON"] = "Usar",
	["CO_GLANCE_PRESET_TRP3"] = "Usar el estilo de posiciones de Total RP 3",
	["CO_HIDE_EMPTY_MAP_BUTTON"] = "Ocultar cuando no haya escaneo disponible",
	["CO_LOCATION"] = "Ajustes de rastreo",
	["CO_LOCATION_ACTIVATE"] = "Habilitar la localización de personaje",
	["CO_LOCATION_ACTIVATE_TT"] = "Habilita el sistema de localización de personaje, permite escanear y localizar en el mapa a otros usuarios del Total RP, y permite que ellos te localicen a ti.",
	["CO_LOCATION_DISABLE_CLASSIC_PVP"] = "Deshabilitar la localización cuando esté marcado para JcJ",
	["CO_LOCATION_DISABLE_OOC"] = "Desactivar rastreo en modo FdR",
	["CO_LOCATION_DISABLE_PVP"] = "Desactivar rastreo en modo JcJ",
	["CO_LOCATION_SHOW_DIFFERENT_WAR_MODES"] = "Mostrar jugadores en diferente modo de guerra",
	["CO_MAP_BUTTON"] = "Botón de escaneo de mapa",
	["CO_MINIMAP_BUTTON"] = "Botón del minimapa",
	["CO_MINIMAP_BUTTON_RESET"] = "Reiniciar posición",
	["CO_MINIMAP_BUTTON_RESET_BUTTON"] = "Reiniciar",
	["CO_MINIMAP_BUTTON_SHOW_TITLE"] = "Mostrar botón en el minimapa",
	["CO_MODULES"] = "Estado de los módulos",
	["CO_MODULES_DISABLE"] = "Deshabilitar módulos",
	["CO_MODULES_ENABLE"] = "Habilitar módulo",
	["CO_MODULES_ID"] = "ID del módulo: %s",
	["CO_MODULES_SHOWERROR"] = "Mostrar error",
	["CO_MODULES_STATUS"] = "Estado: %s",
	["CO_MODULES_STATUS_0"] = "Dependencias faltantes",
	["CO_MODULES_STATUS_1"] = "Cargado",
	["CO_MODULES_STATUS_2"] = "Deshabilitado",
	["CO_MODULES_STATUS_3"] = "Actualización de Total RP 3 requerida",
	["CO_MODULES_STATUS_4"] = "Error en la inicialización",
	["CO_MODULES_STATUS_5"] = "Error en el inicio%sPara Total RP 3 build %s mínima.|r",
	["CO_MODULES_TT_DEP"] = "%s- %s (versión %s)|r",
	["CO_MODULES_TT_DEPS"] = "Dependencias",
	["CO_MODULES_TT_ERROR"] = "|cffff0000Error:|r %s",
	["CO_MODULES_TT_NONE"] = "Sin dependencias",
	["CO_MODULES_VERSION"] = "Version: %s",
	["CO_MSP"] = "Protocolo Mary Sue",
	["CO_MSP_T3"] = "Usar sólo la plantilla 3",
	["CO_REGISTER"] = "Configuración de registro",
	["CO_REGISTER_ABOUT_H1_SIZE"] = "Tamaño del texto de encabezado 1",
	["CO_REGISTER_ABOUT_H1_SIZE_TT"] = "Tamaño del texto entre las etiquetas {h1}. Por defecto: %s",
	["CO_REGISTER_ABOUT_H2_SIZE"] = "Tamaño del texto de encabezado 2",
	["CO_REGISTER_ABOUT_H2_SIZE_TT"] = "Tamaño del texto entre las etiquetas {h2}. Por defecto: %s",
	["CO_REGISTER_ABOUT_H3_SIZE"] = "Tamaño del texto de encabezado 3",
	["CO_REGISTER_ABOUT_H3_SIZE_TT"] = "Tamaño del texto entre las etiquetas {h3}. Por defecto: %s",
	["CO_REGISTER_ABOUT_P_SIZE"] = "Tamaño del texto del párrafo",
	["CO_REGISTER_ABOUT_SETTINGS"] = "Configuraciones de \"Acerca de\"",
	["CO_REGISTER_ABOUT_VOTE"] = "Usar sistema de votos",
	["CO_REGISTER_AUTO_ADD"] = "Añadir nuevos jugadores automáticamente",
	["CO_REGISTER_AUTO_PURGE"] = "Purgar directorio automáticamente",
	["CO_REGISTER_AUTO_PURGE_0"] = "Deshabilitar purga",
	["CO_REGISTER_AUTO_PURGE_1"] = "Después de %s día(s)",
	["CO_TARGETFRAME_ICON_SIZE"] = "Tamaño de iconos",
	["CO_TARGETFRAME_USE"] = "Mostrar condiciones",
	["CO_TARGETFRAME_USE_1"] = "Siempre",
	["CO_TARGETFRAME_USE_2"] = "Sólo Dentro del Personaje",
	["CO_TARGETFRAME_USE_3"] = "Nunca (deshabilitado)",
	["CO_TOOLBAR"] = "Ajustes del marco",
	["CO_TOOLBAR_CONTENT"] = "Ajustes de la barra de herramientas",
	["CO_TOOLBAR_CONTENT_RPSTATUS"] = "Estado del personaje (ER/FdR)",
	["CO_TOOLBAR_CONTENT_STATUS"] = "Estado del jugador (AUS/NM)",
	["CO_TOOLBAR_ICON_SIZE"] = "Tamaño de iconos",
	["CO_TOOLBAR_MAX"] = "Iconos máximos por línea",
	["CO_TOOLBAR_SHOW_ON_LOGIN"] = "Mostrar barra de herramientas al iniciar sesión",
	["CO_TOOLTIP"] = "Herramientas",
	["CO_TOOLTIP_CLIENT"] = "Mostrar cliente",
	["CO_TOOLTIP_COLOR"] = "Mostrar colores personalizados",
	["CO_TOOLTIP_COMBAT"] = "Ocultar durante el combate",
	["CO_TOOLTIP_COMMON"] = "Configuraciones comunes",
	["CO_TOOLTIP_CONTRAST"] = "Aumentar el contraste de color",
	["CO_TOOLTIP_CURRENT"] = "Mostrar información \"actual\"",
	["CO_TOOLTIP_FT"] = "Mostrar título completo",
	["CO_TOOLTIP_GUILD"] = "Mostrar información de guild",
	["CO_TOOLTIP_HEALTH"] = "Mostrar salud",
	["CO_TOOLTIP_HEALTH_BOTH"] = "Número + Porcentaje",
	["CO_TOOLTIP_HEALTH_DISABLED"] = "Desactivado",
	["CO_TOOLTIP_HEALTH_NUMBER"] = "Número",
	["CO_TOOLTIP_HEALTH_PERCENT"] = "Porcentaje",
	["CO_TOOLTIP_HEALTH_TT"] = "Se mostrará si el objetivo no tiene la salud completa",
	["CO_TOOLTIP_HIDE_IN_INSTANCE"] = "Ocultar en estancia",
	["CO_TOOLTIP_ICONS"] = "Mostrar íconos",
	["CO_TOOLTIP_IN_CHARACTER_ONLY"] = "Ocultar en modo fuera de personaje",
	["CO_TOOLTIP_MAINSIZE"] = "Tamaño de fuente principal",
	["CO_TOOLTIP_NOTIF"] = "Mostrar notificaciones",
	["CO_TOOLTIP_OWNER"] = "Mostrar propietario",
	["CO_TOOLTIP_PREFERRED_OOC_INDICATOR"] = "Indicador FdP preferido",
	["CO_TOOLTIP_PREFERRED_OOC_INDICATOR_ICON"] = "Ícono:",
	["CO_TOOLTIP_PREFERRED_OOC_INDICATOR_TEXT"] = "Texto:",
	["CO_TOOLTIP_PROFILE_ONLY"] = "Usar sólo si el objetivo tiene un perfil",
	["CO_TOOLTIP_PRONOUNS"] = "Mostrar pronombres",
	["CO_TOOLTIP_RACE"] = "Mostrar raza, clase y nivel",
	["CO_TOOLTIP_REALM"] = "Mostrar reino",
	["CO_TOOLTIP_RELATION"] = "Mostrar color de la relación",
	["CO_TOOLTIP_SPACING"] = "Mostrar espaciado",
	["CO_TOOLTIP_SUBSIZE"] = "Tamaño de fuente secundario",
	["CO_TOOLTIP_TARGET"] = "Mostrar objetivo",
	["CO_TOOLTIP_TERSIZE"] = "Tamaño de fuente terciario",
	["CO_TOOLTIP_TITLE"] = "Mostrar título",
	["CO_TOOLTIP_USE"] = "Usar herramientas de personajes/compañeros",
	["CO_TOOLTIP_ZONE"] = "Mostrar zona",
	["CO_TOOLTIP_ZONE_TT"] = "Se mostrara sólo si el objetivo no está en la misma zona que tú.",
	["CO_UI_RELOAD_WARNING"] = "La interfaz debe ser recargada para aplicar los cambios. ¿Te gustaría recargar ahora?",
	["COM_LIST"] = "Lista de comandos:",
	["COM_RESET_RESET"] = "¡Las posiciones de los cuadros se han restablecido!",
	["COM_STASH_DATA"] = [=[|cffff0000¿Estás seguro de que quieres ir acumulando tu información del Total RP 3?|r

Tus perfiles, los de tus compañeros y configuración se acumulará temporalmente y tu interfaz se cargará sin información, como si hubieras instalado Total RP 3 de nuevo.
|cff00ff00Utiliza el mismo comando de nuevo (|cff999999/trp3 stash|cff00ff00) para restaurar la información.|r]=],
	["CONFIG_COMMS_SETTINGS_HEADER"] = "Configuración de comunicaciones",
	["COPY_SYSTEM_MESSAGE"] = "Copiado al portapapeles.",
	["CREDITS_DISCORD_LINK_TEXT"] = "Únetenos en Discord",
	["CREDITS_GUILD_NAME"] = "<%1$s>",
	["CREDITS_NAME_WITH_ROLE"] = "%1$s (%2$s)",
	["CREDITS_THANK_YOU_ROLE_2"] = "Autor",
	["CREDITS_THANK_YOU_ROLE_3"] = "Desarrollador",
	["CREDITS_THANK_YOU_ROLE_5"] = "Mascota",
	["DB_ABOUT"] = "Acerca de Total RP 3",
	["DB_HTML_GOTO"] = "Click para abrir",
	["DB_MORE"] = "Más módulos",
	["DB_NEW"] = "¿Qué hay nuevo?",
	["DB_STATUS"] = "Estado",
	["DB_STATUS_CURRENTLY"] = "Actualmente (EP)",
	["DB_STATUS_CURRENTLY_OOC"] = "Otra información (FdP)",
	["DB_STATUS_RP"] = "Estado de personaje",
	["DB_STATUS_RP_EXP"] = "Rolero experimentado",
	["DB_STATUS_RP_IC"] = "En personaje",
	["DB_STATUS_RP_OOC"] = "Fuera de personaje.",
	["DB_STATUS_RP_VOLUNTEER"] = "Rolero voluntario",
	["DB_STATUS_XP"] = "Estado de rol",
	["DB_STATUS_XP_BEGINNER"] = "Rolero novato",
	["DTBK_AFK"] = "Total RP 3 - AUS/NM",
	["DTBK_CLOAK"] = "Total RP 3 - Capa",
	["DTBK_HELMET"] = "Total RP 3 - Yelmo",
	["DTBK_LANGUAGES"] = "Total RP 3 - Idiomas",
	["DTBK_RP"] = "Total RP 3 - ER/FdR",
	["GEN_VERSION"] = "Versión: %s (Build %s)",
	["GEN_WELCOME_MESSAGE"] = "¡Gracias por usar Total RP 3 (v %s)! ¡Diviértase!",
	["MAP_BUTTON_NO_SCAN"] = "Búsqueda no disponible",
	["MAP_BUTTON_SCANNING"] = "Buscando",
	["MAP_BUTTON_SUBTITLE"] = "Haz clic para mostrar los rastreos disponibles",
	["MAP_SCAN_CHAR"] = "Buscar personajes",
	["MAP_SCAN_CHAR_TITLE"] = "Personajes",
	["MATURE_FILTER_EDIT_DICTIONARY"] = "Editar diccionario personalizado",
	["MATURE_FILTER_EDIT_DICTIONARY_BUTTON"] = "Editar",
	["MATURE_FILTER_EDIT_DICTIONARY_TITLE"] = "Editor del diccionario personalizado",
	["MATURE_FILTER_OPTION"] = "Filtrar perfiles adultos",
	["MATURE_FILTER_TITLE"] = "Filtro de perfiles adultos",
	["MATURE_FILTER_WARNING_CONTINUE"] = "Continuar",
	["MATURE_FILTER_WARNING_GO_BACK"] = "Atrás",
	["MM_SHOW_HIDE_MAIN"] = "Mostrar/ocultar marco principal",
	["MM_SHOW_HIDE_MOVE"] = "Mover botón",
	["MM_SHOW_HIDE_SHORTCUT"] = "Mostrar/ocultar barra de herramientas",
	["NPC_TALK_SAY_PATTERN"] = "dice:",
	["NPC_TALK_WHISPER_PATTERN"] = "susurra:",
	["NPC_TALK_YELL_PATTERN"] = "grita:",
	["PR_CO_BATTLE"] = "Compañero",
	["PR_CO_MOUNT"] = "Montura",
	["PR_CO_PET"] = "Mascota",
	["PR_CO_PROFILEMANAGER_TITLE"] = "Perfiles de compañeros",
	["PR_CREATE_PROFILE"] = "Crear perfil",
	["PR_PROFILE"] = "Perfil",
	["PR_PROFILE_CREATED"] = "Perfil %s creado.",
	["PR_PROFILE_DELETED"] = "Perfil %s eliminado.",
	["PR_PROFILEMANAGER_TITLE"] = "Perfiles de personaje",
	["PR_PROFILES"] = "Perfiles",
	["REG_COMPANION"] = "Compañero",
	["REG_COMPANION_BOUND_TO"] = "Vinculado a ...",
	["REG_COMPANION_BOUND_TO_TARGET"] = "Objetivo",
	["REG_COMPANION_BOUNDS"] = "Vínculos",
	["REG_COMPANION_BROWSER_BATTLE"] = "Buscador de compañeros",
	["REG_COMPANION_BROWSER_MOUNT"] = "Buscador de monturas",
	["REG_COMPANION_INFO"] = "Información",
	["REG_COMPANION_NAME"] = "Nombre",
	["REG_COMPANION_NAME_COLOR"] = "Color del nombre",
	["REG_COMPANION_PROFILES"] = "Perfiles de compañeros",
	["REG_COMPANION_TARGET_NO"] = "To objetivo no es una mascota, necrófago, elemental de mago o compañero renombrado válido.",
	["REG_COMPANION_TF_BOUND_TO"] = "Seleccionar perfil",
	["REG_COMPANION_TF_CREATE"] = "Crear nuevo perfil",
	["REG_COMPANION_TF_NO"] = "No hay perfil",
	["REG_COMPANION_TF_OPEN"] = "Abrir página",
	["REG_COMPANION_TF_OWNER"] = "Dueño: %s",
	["REG_COMPANION_TF_PROFILE"] = "Perfil de compañero",
	["REG_COMPANION_TF_PROFILE_MOUNT"] = "Perfil de montura",
	["REG_COMPANION_TF_UNBOUND"] = "Desvincular del perfil",
	["REG_COMPANION_TITLE"] = "Título",
	["REG_COMPANIONS"] = "Compañeros",
	["REG_DELETE_WARNING"] = "¿Seguro que quieres eliminar el perfil %s?",
	["REG_IGNORE_TOAST"] = "Personaje ignorado",
	["REG_LIST_ACTIONS_MASS_REMOVE"] = "Eliminar perfiles",
	["REG_LIST_ACTIONS_PURGE"] = "Purgar registro",
	["REG_LIST_ACTIONS_PURGE_ALL"] = "Eliminar todos los perfiles",
	["REG_LIST_ACTIONS_PURGE_ALL_C"] = [=[Esta purga eliminará todos los perfiles vinculados desde el directorio.

|cff00ff00%s personajes.]=],
	["REG_LIST_ACTIONS_PURGE_ALL_COMP_C"] = [=[Esta purga eliminará todos los compañeros del directorio.

|cff00ff00%s compañeros.]=],
	["REG_LIST_ACTIONS_PURGE_COUNT"] = "%s perfiles serán eliminados.",
	["REG_LIST_ACTIONS_PURGE_EMPTY"] = "No hay perfiles que purgar.",
	["REG_LIST_ACTIONS_PURGE_IGNORE"] = "Perfiles de personajes ignorados.",
	["REG_LIST_ACTIONS_PURGE_IGNORE_C"] = [=[Esta purga eliminará a todos los perfiles vinculados a un personaje de WoW ignorado.

|cff00ff00%s]=],
	["REG_LIST_ACTIONS_PURGE_TIME"] = "Perfiles no vistos desde hace 1 mes",
	["REG_LIST_ACTIONS_PURGE_TIME_C"] = [=[Esta purga eliminará a todos los personajes no vistos desde hace un mes.

|cff00ff00%s]=],
	["REG_LIST_ACTIONS_PURGE_UNLINKED"] = "Perfiles no vinculados a un personaje",
	["REG_LIST_ACTIONS_PURGE_UNLINKED_C"] = [=[Esta purga eliminará todos los perfiles no vinculados a un personaje de WoW.

|cff00ff00%s]=],
	["REG_LIST_ADDON"] = "Tipo de perfil",
	["REG_LIST_CHAR_EMPTY"] = "Sin personajes",
	["REG_LIST_CHAR_EMPTY2"] = "Ningún personaje encaja con tu selección",
	["REG_LIST_CHAR_FILTER"] = "Personajes: %s / %s",
	["REG_LIST_CHAR_IGNORED"] = "Ignorado",
	["REG_LIST_CHAR_SEL"] = "Seleccionar personaje",
	["REG_LIST_CHAR_TITLE"] = "Lista de personajes",
	["REG_LIST_CHAR_TT"] = "Click para mostrar página",
	["REG_LIST_CHAR_TT_CHAR"] = "Personaje(s) de WoW ligado(s):",
	["REG_LIST_CHAR_TT_CHAR_NO"] = "No está vinculado a ningún personaje",
	["REG_LIST_CHAR_TT_DATE"] = [=[Última vez que fue visto: |cff00ff00%s|r
Último lugar donde fue visto: |cff00ff00%s|r]=],
	["REG_LIST_CHAR_TT_GLANCE"] = "A primera vista",
	["REG_LIST_CHAR_TT_IGNORE"] = "Personaje(s) ignorado(s)",
	["REG_LIST_CHAR_TT_NEW_ABOUT"] = "Descripción no leída",
	["REG_LIST_CHAR_TT_RELATION"] = [=[Relación:
|cff00ff00%s]=],
	["REG_LIST_FILTERS"] = "Filtros",
	["REG_LIST_FILTERS_TT"] = [=[|cffffff00Click:|r Aplicar filtros
|cffffff00Click derecho:|r Limpiar filtros]=],
	["REG_LIST_FLAGS"] = "Banderas",
	["REG_LIST_GUILD"] = "Hermandad del personaje",
	["REG_LIST_IGNORE_EMPTY"] = "Personaje no ignorado",
	["REG_LIST_IGNORE_TITLE"] = "Lista de ignorados",
	["REG_LIST_IGNORE_TT"] = [=[Razón:
|cff00ff00%s

|cffffff00Click para eliminar de la lista de ignorados]=],
	["REG_LIST_NAME"] = "Nombre del personaje",
	["REG_LIST_NOTIF_ADD"] = "Nuevo perfil descubierto: |cff00ff00%s",
	["REG_LIST_NOTIF_ADD_CONFIG"] = "Nuevo perfil descubierto",
	["REG_LIST_NOTIF_ADD_NOT"] = "Este perfil ya no existe.",
	["REG_LIST_PET_MASTER"] = "Nombre del dueño",
	["REG_LIST_PET_NAME"] = "Nombre del compañero",
	["REG_LIST_PET_TYPE"] = "Tipo de compañero",
	["REG_LIST_PETS_EMPTY"] = "No hay compañero",
	["REG_LIST_PETS_EMPTY2"] = "Ningún compañero encaja con tu selección",
	["REG_LIST_PETS_FILTER"] = "Compañeros: %s / %s",
	["REG_LIST_PETS_TITLE"] = "Lista de compañeros",
	["REG_LIST_PETS_TOOLTIP"] = "Se ha visto en",
	["REG_LIST_PETS_TOOLTIP2"] = "Se ha visto con",
	["REG_LIST_REALMONLY"] = "Sólo en este reino",
	["REG_MSP_ALERT"] = [=[|cffff0000ADVERTENCIA

No se puede tener más de un addon utilizando el Protocolo Mary Sue, ya que podrían entrar en conflicto.|r

Actualmente cargado: |cff00ff00%s

|cffff9900Por lo tanto, se desactivará el apoyo PMS para el Total RP3|r

Si no quieres que el TRP3 sea tu PMS y no quieres ver esta alerta de nuevo, puedes desactivarlo en el módulo Protocolo Mary Sue en ajustes de Total RP3 en -> Estado del módulo.]=],
	["REG_PLAYER"] = "Personaje",
	["REG_PLAYER_ABOUT"] = "Acerca de",
	["REG_PLAYER_ABOUT_ADD_FRAME"] = "Añadir un marco",
	["REG_PLAYER_ABOUT_EMPTY"] = "Sin descripción",
	["REG_PLAYER_ABOUT_HEADER"] = "Etiqueta del título",
	["REG_PLAYER_ABOUT_MUSIC"] = "Tema del personaje",
	["REG_PLAYER_ABOUT_MUSIC_LISTEN"] = "Tocar tema",
	["REG_PLAYER_ABOUT_MUSIC_REMOVE"] = "Deseleccionar tema",
	["REG_PLAYER_ABOUT_MUSIC_SELECT"] = "Selecciona un tema para el personaje",
	["REG_PLAYER_ABOUT_MUSIC_SELECT2"] = "Seleccionar tema",
	["REG_PLAYER_ABOUT_MUSIC_STOP"] = "Parar tema",
	["REG_PLAYER_ABOUT_NOMUSIC"] = "|cffff9900Sin tema",
	["REG_PLAYER_ABOUT_P"] = "Etiqueta del parágrafo",
	["REG_PLAYER_ABOUT_REMOVE_FRAME"] = "Eliminar este marco",
	["REG_PLAYER_ABOUT_SOME"] = "Escribir texto aquí...",
	["REG_PLAYER_ABOUT_T1_YOURTEXT"] = "Tu texto aquí",
	["REG_PLAYER_ABOUT_TAGS"] = "Herramientas de formato",
	["REG_PLAYER_ABOUT_UNMUSIC"] = "|cffff9900Tema desconocido",
	["REG_PLAYER_ABOUT_VOTE_DOWN"] = "No me gusta",
	["REG_PLAYER_ABOUT_VOTE_NO"] = [=[No hay personajes conectados vinculados a este perfil.
¿Deseas mandar el voto de todas formas?]=],
	["REG_PLAYER_ABOUT_VOTE_SENDING"] = "Enviando tu voto a %s ...",
	["REG_PLAYER_ABOUT_VOTE_SENDING_OK"] = "¡Tu voto ha sido enviado a %s !",
	["REG_PLAYER_ABOUT_VOTE_TT"] = "Tu voto es totalmente anónimo y sólo puede ser visto por este jugador.",
	["REG_PLAYER_ABOUT_VOTE_TT2"] = "Sólo puedes votar si el jugador está conectado.",
	["REG_PLAYER_ABOUT_VOTE_UP"] = "Me gusta",
	["REG_PLAYER_ABOUT_VOTES"] = "Estadísticas",
	["REG_PLAYER_ABOUT_VOTES_R"] = [=[|cff00ff00%s Me gusta
|cffff0000%s No me gusta]=],
	["REG_PLAYER_ABOUTS"] = "Acerca de %s",
	["REG_PLAYER_ADD_NEW"] = "Crear nuevo",
	["REG_PLAYER_AGE"] = "Edad",
	["REG_PLAYER_AGE_TT"] = [=[Aquí puedes indicar la edad de tu personaje.

Puedes hacerlo de distintas maneras:|c0000ff00
- Usa años,
- O un adjetivo (joven, maduro, adulto, venerable, etc.).]=],
	["REG_PLAYER_ALERT_HEAVY_SMALL"] = [=[|cffff0000El tamaño total de tu perfil es demasiado extenso.
|cffff9900Debes reducirlo.]=],
	["REG_PLAYER_BIRTHPLACE"] = "Lugar de nacimiento",
	["REG_PLAYER_BIRTHPLACE_TT"] = [=[Aquí puedes indicar el lugar de nacimiento tu personaje. Puede ser una región, zona o incluso un continente. Tú eres quien decide cuán preciso quieres que sea.

|c00ffff00Puedes usar el botón de la derecha para seleccionar tu ubicación actual como lugar de nacimiento.]=],
	["REG_PLAYER_BKG"] = "Diseño de fondo",
	["REG_PLAYER_CARACT"] = "Características",
	["REG_PLAYER_CHANGE_CONFIRM"] = [=[Puede que tengas algunos cambios sin guardar.
¿Deseas cambiar la página de todos modos?
|cffff9900Cualquier cambio se perderá.]=],
	["REG_PLAYER_CHARACTERISTICS"] = "Características",
	["REG_PLAYER_CLASS"] = "Clase",
	["REG_PLAYER_CLASS_TT"] = [=[Esta es la clase por defecto de tu personaje.

|cff00ff00Por ejemplo :|r
Caballero, pirotécnico, nigromante, arcanista...]=],
	["REG_PLAYER_COLOR_CLASS"] = "Color de clase",
	["REG_PLAYER_COLOR_CLASS_TT"] = [=[Esto determina el color en que se visualizará la clase.
]=],
	["REG_PLAYER_COLOR_TT"] = [=[|cffffff00Clic:|r Seleccionar color
|cffffff00Clic derecho:|r Descartar color]=],
	["REG_PLAYER_CURRENT"] = "Actualmente",
	["REG_COMPANIONS_SHORTDESCRIPTION"]= "Breve descripción",
	["REG_PLAYER_CURRENT_OOC"] = "Esta es información Fuera de Rol",
	["REG_PLAYER_CURRENTOOC"] = "Actualmente (FdR)",
	["REG_PLAYER_EYE"] = "Color de ojos",
	["REG_PLAYER_EYE_TT"] = [=[Aquí puedes indicar el color de ojos de tu personaje.

Ten en cuenta que, aunque tu rostro esté constantemente oculto, vale la pena mencionarlo, por si acaso.]=],
	["REG_PLAYER_FIRSTNAME"] = "Nombre",
	["REG_PLAYER_FIRSTNAME_TT"] = [=[Este es el nombre de tu personaje. Este es un campo obligatorio a rellenar, por lo que si no se especifica un nombre se usará el nombre por defecto (|cffffff00%s|r).

¡Puedes utilizar un |c0000ff00apodo|r!]=],
	["REG_PLAYER_FULLTITLE"] = "Título completo",
	["REG_PLAYER_FULLTITLE_TT"] = [=[Aquí puedes escribir el título completo de tu personaje. Puede ser una versión más larga del título u otro título completo.

Sin embargo, es posible que quieras evitar repeticiones, en caso de que no haya información adicional que mencionar.]=],
	["REG_PLAYER_GLANCE"] = "A primera vista",
	["REG_PLAYER_GLANCE_BAR_DELETED"] = "Grupo prestablecido |cffff9900%s|r eliminado.",
	["REG_PLAYER_GLANCE_BAR_EMPTY"] = "El nombre del predeterminado no puede estar vacío.",
	["REG_PLAYER_GLANCE_BAR_LOAD"] = "Grupo restablecido",
	["REG_PLAYER_GLANCE_BAR_LOAD_SAVE"] = "Grupo predeterminado",
	["REG_PLAYER_GLANCE_BAR_NAME"] = [=[Por favor introduce el nombre del predeterminado.

|cff00ff00Nota: Si el nombre ya está siendo usado por otro grupo, será remplazado por este grupo. ]=],
	["REG_PLAYER_GLANCE_BAR_SAVE"] = "Guardar grupo como predeterminado.",
	["REG_PLAYER_GLANCE_BAR_SAVED"] = "Grupo predeterminado |cff00ff00%s|r ha sido creado",
	["REG_PLAYER_GLANCE_BAR_TARGET"] = "\"A primera vista\" predeterminado",
	["REG_PLAYER_GLANCE_EDITOR"] = "Editor de A primera vista : Ranura %s",
	["REG_PLAYER_GLANCE_PRESET"] = "Cargar",
	["REG_PLAYER_GLANCE_PRESET_ADD"] = "Creado prestablecido |cff00ff00%s|r.",
	["REG_PLAYER_GLANCE_PRESET_ALERT1"] = "Por favor, introduce una categoría y un nombre",
	["REG_PLAYER_GLANCE_PRESET_CATEGORY"] = "Categoría prestablecida",
	["REG_PLAYER_GLANCE_PRESET_CREATE"] = "Crear prestablecido",
	["REG_PLAYER_GLANCE_PRESET_GET_CAT"] = [=[%s

]=],
	["REG_PLAYER_GLANCE_PRESET_NAME"] = "Nombre",
	["REG_PLAYER_GLANCE_PRESET_REMOVE"] = "Eliminar prestablecido |cff00ff00%s|r.",
	["REG_PLAYER_GLANCE_PRESET_SAVE"] = "Guardar información como prestablecida",
	["REG_PLAYER_GLANCE_PRESET_SAVE_SMALL"] = "Guardar como prestablecido",
	["REG_PLAYER_GLANCE_PRESET_SELECT"] = "Seleccionar prestablecido",
	["REG_PLAYER_GLANCE_TITLE"] = "Nombre de atributo",
	["REG_PLAYER_GLANCE_USE"] = "Activar esta ranura",
	["REG_PLAYER_HEIGHT"] = "Altura",
	["REG_PLAYER_HEIGHT_TT"] = [=[Esta es la altura de tu personaje.
Tienes varias formas de hacerlo:|c0000ff00
- Numérico: 170 cm, 6'5" ...
- Cualificativo: Alto, bajo ...]=],
	["REG_PLAYER_HERE"] = "Seleccionar posición",
	["REG_PLAYER_HERE_HOME_PRE_TT"] = [=[Actual posición de la residencia:
|cff00ff00%s|r.]=],
	["REG_PLAYER_HERE_HOME_TT"] = [=[|cffffff00Clic|r: Usar la posición actual como tu residencia.
|cffffff00Clic-derecho|r: Elimina la posición de la residencia.]=],
	["REG_PLAYER_HERE_TT"] = "|cffffff00Click|r: Seleccionar tu posición actual",
	["REG_PLAYER_HISTORY"] = "Historia",
	["REG_PLAYER_ICON"] = "Icono del personaje",
	["REG_PLAYER_ICON_TT"] = "Selecciona una representación gráfica para tu personaje.",
	["REG_PLAYER_IGNORE"] = "Ignorar personajes vinculados (%s)",
	["REG_PLAYER_LASTNAME"] = "Apellido",
	["REG_PLAYER_LASTNAME_TT"] = "Es el apellido de tu personaje.",
	["REG_PLAYER_LEFTTRAIT"] = "Atributo izquierdo",
	["REG_PLAYER_MISC_ADD"] = "Añadir campo adicional",
	["REG_PLAYER_MORE_INFO"] = "Información adicional",
	["REG_PLAYER_MSP_HOUSE"] = "Nombre de la Casa",
	["REG_PLAYER_MSP_MOTTO"] = "Lema",
	["REG_PLAYER_MSP_NICK"] = "Apodo",
	["REG_PLAYER_NAMESTITLES"] = "Nombres y títulos",
	["REG_PLAYER_NO_CHAR"] = "Sin características",
	["REG_PLAYER_PEEK"] = "Varios",
	["REG_PLAYER_PHYSICAL"] = "Descripción física",
	["REG_PLAYER_PSYCHO"] = "Rasgos de personalidad",
	["REG_PLAYER_PSYCHO_Acete"] = "Ascético",
	["REG_PLAYER_PSYCHO_ADD"] = "Añadir un rasgo de personalidad",
	["REG_PLAYER_PSYCHO_ATTIBUTENAME_TT"] = "Nombre del atributo",
	["REG_PLAYER_PSYCHO_CHAOTIC"] = "Caótico",
	["REG_PLAYER_PSYCHO_Chaste"] = "Casto",
	["REG_PLAYER_PSYCHO_Conciliant"] = "Conciliador",
	["REG_PLAYER_PSYCHO_CREATENEW"] = "Crear rasgo",
	["REG_PLAYER_PSYCHO_Cruel"] = "Cruel",
	["REG_PLAYER_PSYCHO_CUSTOM"] = "Rasgo personalizado",
	["REG_PLAYER_PSYCHO_Egoiste"] = "Egoísta",
	["REG_PLAYER_PSYCHO_Genereux"] = "Generoso",
	["REG_PLAYER_PSYCHO_Impulsif"] = "Impulsivo",
	["REG_PLAYER_PSYCHO_Indulgent"] = "Indulgente",
	["REG_PLAYER_PSYCHO_LEFTICON_TT"] = "Establece el icono del atributo de la izquierda",
	["REG_PLAYER_PSYCHO_Loyal"] = "Leal",
	["REG_PLAYER_PSYCHO_Luxurieux"] = "Lujuria",
	["REG_PLAYER_PSYCHO_Misericordieux"] = "Amable",
	["REG_PLAYER_PSYCHO_MORE"] = "Añadir un punto a \"%s\"",
	["REG_PLAYER_PSYCHO_PERSONAL"] = "Características personales",
	["REG_PLAYER_PSYCHO_Pieux"] = "Supersticioso",
	["REG_PLAYER_PSYCHO_POINT"] = "Añadir un punto",
	["REG_PLAYER_PSYCHO_Pragmatique"] = "Renegado",
	["REG_PLAYER_PSYCHO_Rationnel"] = "Racional",
	["REG_PLAYER_PSYCHO_Reflechi"] = "Cauto",
	["REG_PLAYER_PSYCHO_Rencunier"] = "Vengativo",
	["REG_PLAYER_PSYCHO_RIGHTICON_TT"] = "Establece el icono del atributo de la derecha.",
	["REG_PLAYER_PSYCHO_SOCIAL"] = "Rasgos personales",
	["REG_PLAYER_RACE"] = "Raza",
	["REG_PLAYER_RACE_TT"] = "Aquí va la raza de tu personaje. No está restringido a las razas jugables. Hay muchas razas del Warcraft que pueden asumir formas comunes...",
	["REG_PLAYER_REGISTER"] = "Información del directorio",
	["REG_PLAYER_RESIDENCE"] = "Residencia",
	["REG_PLAYER_RESIDENCE_SHOW"] = "Coordenadas de residencia",
	["REG_PLAYER_RESIDENCE_SHOW_TT"] = [=[|cff00ff00%s

|rClick para que aparezca en el mapa]=],
	["REG_PLAYER_RESIDENCE_TT"] = [=[Aquí puedes indicar donde vive el personaje normalmente. Esta podría ser su dirección personal (su casa) o el lugar donde se hospeda.
Ten en cuenta que si tu personaje es un vagabundo, tendrás que cambiar la información.

|c00ffff00Puedes utilizar el botón de la derecha para fijar la posición actual como residencia.]=],
	["REG_PLAYER_RIGHTTRAIT"] = "Atributo derecho",
	["REG_PLAYER_SHOWMISC"] = "Mostrar marco de varios",
	["REG_PLAYER_SHOWPSYCHO"] = "Mostrar el marco de personalidad",
	["REG_PLAYER_STYLE_ASSIST"] = "Asistencia de rol",
	["REG_PLAYER_STYLE_BATTLE"] = "Resolución de batallas de rol",
	["REG_PLAYER_STYLE_BATTLE_1"] = "World of Warcraft PVP",
	["REG_PLAYER_STYLE_BATTLE_2"] = "Batalla a dados TRP",
	["REG_PLAYER_STYLE_BATTLE_3"] = "Batalla a dados",
	["REG_PLAYER_STYLE_BATTLE_4"] = "Batalla a emotes",
	["REG_PLAYER_STYLE_DEATH"] = "Aceptación de muerte",
	["REG_PLAYER_STYLE_EMPTY"] = "Sin atributos de rol compartidos",
	["REG_PLAYER_STYLE_FREQ"] = "Frecuencia de rol",
	["REG_PLAYER_STYLE_FREQ_1"] = "Todo el tiempo",
	["REG_PLAYER_STYLE_FREQ_2"] = "La mayoría de las veces",
	["REG_PLAYER_STYLE_FREQ_3"] = "La mitad del tiempo",
	["REG_PLAYER_STYLE_FREQ_4"] = "A veces",
	["REG_PLAYER_STYLE_FREQ_5"] = "No es un personaje de rol",
	["REG_PLAYER_STYLE_GUILD"] = "Miembro de hermandad",
	["REG_PLAYER_STYLE_GUILD_IC"] = "Miembro ER",
	["REG_PLAYER_STYLE_GUILD_OOC"] = "Miembro FdR",
	["REG_PLAYER_STYLE_HIDE"] = "No mostrar",
	["REG_PLAYER_STYLE_INJURY"] = "Aceptación de heridas",
	["REG_PLAYER_STYLE_PERMI"] = "Con el permiso del jugador",
	["REG_PLAYER_STYLE_ROMANCE"] = "Aceptación de romances",
	["REG_PLAYER_STYLE_RPSTYLE"] = "Estilo de rol",
	["REG_PLAYER_STYLE_RPSTYLE_SHORT"] = "Estilo ER",
	["REG_PLAYER_TITLE"] = "Título",
	["REG_PLAYER_TITLE_TT"] = [=[El título de tu personaje es el título con el que tu personaje es llamado normalmente. Evita colocar títulos largos, para ello se ha de utilizar el título completo.

Ejemplos de |c0000ff00títulos apropiados|r:
|c0000ff00- Condesa,
- Marqués,
- Mago,
- Señor,
- etc.
|rEjemplo de |cffff0000títulos inapropiados|r:
|cffff0000- Condesa de las Marismas del Norte,
- Mago de la Torre de Ventormenta,
- Diplomático de los draenei,
- etc.]=],
	["REG_PLAYER_TRP2_PIERCING"] = "Piercings",
	["REG_PLAYER_TRP2_TATTOO"] = "Tatuajes",
	["REG_PLAYER_TRP2_TRAITS"] = "Fisionomía",
	["REG_PLAYER_TUTO_ABOUT_COMMON"] = [=[|cff00ff00Tema del personaje:|r
Puedes elegir un |cffffff00tema|r para tu personaje. Piensa en ello como una |cffffff00música de ambientación para la lectura de la descripción de tu personaje.

|cff00ff00Fondo:|r
Este es el |cffffff00tipo de fondo|r para la descripción de tu personaje.

|cff00ff00Plantilla:|r
La plantilla elegida define |cffffff00las posibilidades del diseño y escritura generales|r para tu descripción.
|cffff9900Sólo la plantilla seleccionada se verá, no hace falta rellenar todas.|r
Una vez elegida la plantilla puedes volver a abrir este tutorial para tener más ayuda sobre cada plantilla.]=],
	["REG_PLAYER_WEIGHT"] = "Complexión",
	["REG_PLAYER_WEIGHT_TT"] = [=[Esta es la complexión de tu personaje.
Por ejemplo podría ser |c0000ff00delgado, gordo o musculoso...|r ¡O simplemente podría ser normal!]=],
	["REG_REGISTER"] = "Directorio",
	["REG_REGISTER_CHAR_LIST"] = "Lista de personajes",
	["REG_RELATION"] = "Relación",
	["REG_RELATION_BUSINESS"] = "Negocios",
	["REG_RELATION_BUSINESS_TT"] = "%s y %s tienen una relación de negocios",
	["REG_RELATION_BUTTON_TT"] = [=[Relación: %s
|cff00ff00%s

|cffffff00Haz clic para mostrar las acciones posibles]=],
	["REG_RELATION_FAMILY"] = "Familia",
	["REG_RELATION_FAMILY_TT"] = "%s comparte un vínculo de sangre con %s.",
	["REG_RELATION_FRIEND"] = "Amistoso",
	["REG_RELATION_FRIEND_TT"] = "%s considera a %s amigo.",
	["REG_RELATION_LOVE"] = "Amor",
	["REG_RELATION_LOVE_TT"] = "%s está enamorado de %s",
	["REG_RELATION_NEUTRAL"] = "Neutral",
	["REG_RELATION_NEUTRAL_TT"] = "%s conoce a %s.",
	["REG_RELATION_NONE"] = "Ninguna",
	["REG_RELATION_NONE_TT"] = "%s no conoce a %s.",
	["REG_RELATION_TARGET"] = "|cffffff00Clic: |rCambiar relación",
	["REG_RELATION_UNFRIENDLY"] = "Enemigo",
	["REG_RELATION_UNFRIENDLY_TT"] = "%s está enemistado con %s.",
	["REG_TT_GUILD"] = "%s de |cffff9900%s",
	["REG_TT_GUILD_IC"] = "Miembro ER",
	["REG_TT_GUILD_OOC"] = "Miembro FdR",
	["REG_TT_IGNORED"] = "<Personaje ignorado>",
	["REG_TT_IGNORED_OWNER"] = "<Propietario ignorado>",
	["REG_TT_NOTIF"] = "Descripción sin leer",
	["REG_TT_REALM"] = "Reino: |cffff9900%s",
	["REG_TT_TARGET"] = "Objetivo: |cffff9900%s",
	["TB_LANGUAGE"] = "Idioma",
	["TB_LANGUAGES_TT"] = "Cambiar idioma",
	["TB_SWITCH_PROFILE"] = "Cambiar a otro perfil",
	["TF_IGNORE"] = "Ignorar jugador",
	["TF_IGNORE_NO_REASON"] = "Sin razón",
	["TF_IGNORE_TT"] = "|cffffff00Click:|r Ignorar jugador",
	["UI_TUTO_BUTTON"] = "Modo tutorial",
	["UI_TUTO_BUTTON_TT"] = "Haz clic para activar/desactivar el modo tutorial"
}

TRP3_API.loc:RegisterNewLocale("esMX", "Español (AL)", localeContent);

localeContent = {
	["ABOUT_TITLE"] = "Di",
	["BINDING_NAME_TRP3_TOGGLE"] = "dis/attivare sezione principale",
	["BINDING_NAME_TRP3_TOOLBAR_TOGGLE"] = "dis/attivare barra degli strumenti",
	["BROADCAST_10"] = "|cffff9900 Sei già in 10 canali. TRP3 non proverà più a collegarsi al canale di trasmissione, ma non potrai usare alcune funzionalità come vedere la posizione dei giocatori sulla mappa.",
	["BROADCAST_OFFLINE_DISABLED"] = "Trasmissione disabilitata",
	["BROADCAST_PASSWORD"] = [=[|cffff0000 C'è una password messa nel canale di trasmissione (%s).
|cffff9900 TRP3 non proverà più a collegarsi ma non potrai usarealcune funzionalità come vedere la posizione dei giocatori sulla mappa
|cff00ff00 Puoi disattivare o cambiare il canale di trasmissione nelle impostazioni generali di TRP3]=],
	["BROADCAST_PASSWORDED"] = [=[|cffff0000L'utente |r%s| cffff0000 ha appena inserito una password sul canale di trasmissione (%s).
|cffff9900 Se non sai qual'è la password, non potrai usare alcune funzionalità come vedere la posizione dei giocatori sulla mappa]=],
	["BW_COLOR_CODE"] = "Codice colore",
	["BW_COLOR_CODE_ALERT"] = "Codice esadecimale sbagliato!",
	["BW_COLOR_CODE_TT"] = "Si può incollare un codice esadecimale del colore a 6 cifre qui e poi premere Invio.",
	["BW_COLOR_PRESET_DELETE"] = "Cancella le impostazioni di %s",
	["BW_COLOR_PRESET_RENAME"] = "Rinomina le impostazioni di %s",
	["BW_COLOR_PRESET_SAVE"] = "Salva il colore corrente",
	["BW_COLOR_PRESET_TITLE"] = "Impostazioni colore",
	["BW_CUSTOM_NAME"] = "Nome personalizzato del colore",
	["BW_CUSTOM_NAME_TITLE"] = "Nome (Opzionale)",
	["BW_CUSTOM_NAME_TT"] = "Poi impostare un nome per il tuo colore personalizzato che stai salvando. Se lasciato vuoto, verrà utilizzato il codice esadecimale del colore.",
	["CL_COMPANION_PROFILE"] = "Profilo personaggio",
	["CL_CONTENT_SIZE"] = "Taglia: %s",
	["CL_DIRECTORY_COMPANION_PROFILE"] = "Directory profilo personaggio",
	["CL_DIRECTORY_PLAYER_PROFILE"] = "Directory profilo giocatore",
	["CL_DOWNLOADING"] = "Scaricamento: %0.1f %%",
	["CL_EXPIRED"] = "Questo link è scaduto.",
	["CL_GLANCE"] = "Prima-impressione",
	["CL_IMPORT_COMPANION"] = "Importa profilo personaggio",
	["CL_IMPORT_GLANCE"] = "Importa Prima-impressione",
	["CL_IMPORT_PROFILE"] = "Importa profilo",
	["CL_MAKE_IMPORTABLE"] = "Rendi non importabile",
	["CL_MAKE_IMPORTABLE_BUTTON_TEXT"] = "Rendi non importabile",
	["CL_MAKE_IMPORTABLE_SIMPLER"] = [=[Rendere questo %s link importabile?

Le persone potranno copiare ed usare il contenuto di questo link.]=],
	["CL_MAKE_NON_IMPORTABLE"] = "Solo visualizzazione",
	["CL_OPEN_COMPANION"] = "Apri profilo personaggio",
	["CL_OPEN_PROFILE"] = "Apri profilo",
	["CL_PLAYER_PROFILE"] = "Profilo giocatore",
	["CL_REQUESTING_DATA"] = "Richiesta informazioni del link da %s",
	["CL_SENDING_COMMAND"] = "Inviando comandi...",
	["CL_SENT_BY"] = "Link inviato da: %s",
	["CL_TOOLTIP"] = "Crea link di chat",
	["CL_TYPE"] = "Tipo di link TRP3: %s",
	["CL_VERSIONS_DIFFER"] = [=[Questo link è stato generato utilizzando una versione differente di Total RP 3.

Importare contenuto derivato da una versione differente può causare problematiche in caso di incompatibilità. Vuoi procedere comunque?]=],
	["CM_ACTIONS"] = "Azioni",
	["CM_ALT"] = "Alt",
	["CM_APPLY"] = "Applicare",
	["CM_BLACK"] = "Nero",
	["CM_BLUE"] = "Blu",
	["CM_CANCEL"] = "Annullare",
	["CM_CENTER"] = "Centrare",
	["CM_CLASS_DEATHKNIGHT"] = "Cavalliere della Morte",
	["CM_CLASS_DRUID"] = "Druido",
	["CM_CLASS_HUNTER"] = "Cacciatore",
	["CM_CLASS_MAGE"] = "Mago",
	["CM_CLASS_MONK"] = "Monaco",
	["CM_CLASS_PALADIN"] = "Paladino",
	["CM_CLASS_PRIEST"] = "Sacerdote",
	["CM_CLASS_ROGUE"] = "Ladro",
	["CM_CLASS_SHAMAN"] = "Sciamano",
	["CM_CLASS_UNKNOWN"] = "Sconosciuto",
	["CM_CLASS_WARLOCK"] = "Stregone",
	["CM_CLASS_WARRIOR"] = "Guerriero",
	["CM_CLICK"] = "Clic",
	["CM_COLOR"] = "Colore",
	["CM_CTRL"] = "Ctrl",
	["CM_CYAN"] = "Ciano",
	["CM_DELETE"] = "Cancellare",
	["CM_DOUBLECLICK"] = "Doppio-clic",
	["CM_DRAGDROP"] = "Trascinare e rilasciare",
	["CM_EDIT"] = "Modifica",
	["CM_GREEN"] = "Verde",
	["CM_GREY"] = "Grigio",
	["CM_IC"] = "IP/IC",
	["CM_ICON"] = "Icona",
	["CM_IMAGE"] = "Immagine",
	["CM_L_CLICK"] = "Clic-sinistro",
	["CM_LEFT"] = "Sinistra",
	["CM_LINK"] = "Link",
	["CM_LOAD"] = "Carico",
	["CM_M_CLICK"] = "Clic centrale",
	["CM_MOVE_DOWN"] = "Sposta giù",
	["CM_MOVE_UP"] = "Sposta su",
	["CM_NAME"] = "Nome",
	["CM_OOC"] = "FDP/OOC",
	["CM_OPEN"] = "Aprire",
	["CM_ORANGE"] = "Arancio",
	["CM_PINK"] = "Rosa",
	["CM_PLAY"] = "Giocare",
	["CM_PURPLE"] = "Viola",
	["CM_R_CLICK"] = "Clic-destro",
	["CM_RED"] = "Rosso",
	["CM_REMOVE"] = "Rimuovere",
	["CM_RESET"] = "Resettare",
	["CM_RESIZE"] = "Ridimensiona",
	["CM_RESIZE_TT"] = "Trascina per ridimensionare la cornice",
	["CM_RIGHT"] = "Destra",
	["CM_SAVE"] = "Salva",
	["CM_SELECT"] = "Selezionare",
	["CM_SHIFT"] = "Shift",
	["CM_SHOW"] = "Mostrare",
	["CM_STOP"] = "Ferma",
	["CM_TWEET"] = "Invia un tweet",
	["CM_TWEET_PROFILE"] = "Mostra url profilo",
	["CM_UNKNOWN"] = "Sconosciuto",
	["CM_VALUE"] = "Valore",
	["CM_WHITE"] = "Bianco",
	["CM_YELLOW"] = "Giallo",
	["CO_ADVANCED_BROADCAST"] = "Comunicazioni add-on",
	["CO_ADVANCED_BROADCAST_CHANNEL_ALWAYS_LAST"] = "Tieni il canale di trasmissione per ultimo",
	["CO_ADVANCED_BROADCAST_CHANNEL_ALWAYS_LAST_TT"] = "Questa opzione farà sì che il canale di trasmissione sia sempre l'ultimo canale nella tua lista canali.",
	["CO_ADVANCED_LANGUAGE_WORKAROUND"] = "Abilita workaround contro reset di lingua",
	["CO_ADVANCED_LANGUAGE_WORKAROUND_TT"] = "Dalla patch 8.0.1, il gioco resetterà la lingua scelta alla lingua comune della tua fazione ad ogni caricamento. Questo workaround farà sì di ripristinare la lingua scelta dopo ogni caricamento.",
	["CO_ADVANCED_LANGUAGES"] = "Linguaggi",
	["CO_ADVANCED_LANGUAGES_REMEMBER"] = "Ricorda ultima lingua usata",
	["CO_ADVANCED_LANGUAGES_REMEMBER_TT"] = "Total RP 3 si ricorderà quale linguaggio stavi usando prima di sloggare, ed automaticamente sceglierà quel linguaggio al prossimo login.",
	["CO_ADVANCED_SETTINGS"] = "Impostazioni avanzate",
	["CO_ADVANCED_SETTINGS_MENU_NAME"] = "Avanzate",
	["CO_ADVANCED_SETTINGS_POPUP"] = [=[Hai appena modificato una impostazione avanzata.

Per favore ricorda che cambiare queste impostazioni potrebbero alterare la tua esperienza con questo add-on e potrebbe causare un problema in alcune funzionalità. Cambiala a tuo rischio.]=],
	["CO_ADVANCED_SETTINGS_RESET"] = "Ripristina impostazioni avanzate",
	["CO_ADVANCED_SETTINGS_RESET_TT"] = "Ripristina tutte le impostazioni avanzate al valore iniziale. Utilizza questa funzionalità se hai problemi dopo aver modificato le impostazioni.",
	["CO_ANCHOR_BOTTOM"] = "In fondo",
	["CO_ANCHOR_BOTTOM_LEFT"] = "In basso a sinistra",
	["CO_ANCHOR_BOTTOM_RIGHT"] = "In basso a destra",
	["CO_ANCHOR_CURSOR"] = "Mostrare sul cursore",
	["CO_ANCHOR_LEFT"] = "Sinistra",
	["CO_ANCHOR_RIGHT"] = "Destra",
	["CO_ANCHOR_TOP"] = "In alto",
	["CO_ANCHOR_TOP_LEFT"] = "In alto a sinistra",
	["CO_ANCHOR_TOP_RIGHT"] = "In alto a destra",
	["CO_CHAT"] = "Impostazioni della chiacchierata",
	["CO_CHAT_INCREASE_CONTRAST"] = "Aumentare contrasto dei colori",
	["CO_CHAT_INSERT_FULL_RP_NAME"] = "Inserire i nomi RP con maiusc-clic",
	["CO_CHAT_INSERT_FULL_RP_NAME_TT"] = [=[Inserire il nome RP intero di un giocatore quando si maiusc-clicca il loro nome nella cornice della chiacchierata.

(Quando è attivata questa impostazione, si può alt-maiusc-cliccare su un nome quando vuoi il comportamento predefinito e inserire il nome del personaggio invece del nome RP intero)]=],
	["CO_CHAT_MAIN"] = "Impostazioni principali della chiacchierata",
	["CO_CHAT_MAIN_COLOR"] = "Usa colori personalizzati per i nomi",
	["CO_CHAT_MAIN_EMOTE"] = "Rivelazione dell'azione",
	["CO_CHAT_MAIN_EMOTE_PATTERN"] = "Modello della rivelazione dell'azione",
	["CO_CHAT_MAIN_EMOTE_USE"] = "Usare la rivelazione dell'azione",
	["CO_CHAT_MAIN_EMOTE_YELL"] = "Nessuna azione urlata ",
	["CO_CHAT_MAIN_EMOTE_YELL_TT"] = "Non mostrare *emote* o <emote> quando urli.",
	["CO_CHAT_MAIN_NAMING"] = "Metodo della denominazione",
	["CO_CHAT_MAIN_NAMING_1"] = "Mantenere nomi originali",
	["CO_CHAT_MAIN_NAMING_2"] = "Utilizzare nomi personalizzati",
	["CO_CHAT_MAIN_NAMING_3"] = "Nome + cognome",
	["CO_CHAT_MAIN_NAMING_4"] = "Titolo breve + nome + cognome",
	["CO_CHAT_MAIN_NPC"] = "Rivelazione del parlare di NPC",
	["CO_CHAT_MAIN_NPC_PREFIX"] = "Modello della rivelazione del parlare NPC",
	["CO_CHAT_MAIN_NPC_PREFIX_TT"] = [=[Se comincia una linea chiacchierata nel canale EMOTE con questo prefisso, verrà interpretato come una chiacchierata NPC.
|cff00ff00Per impostazione predefinita : "|| "
(senza gli " e con uno spazio dopo la pipa)]=],
	["CO_CHAT_MAIN_NPC_USE"] = "Usare rivelazione del parlare di NPC",
	["CO_CHAT_MAIN_OOC"] = "Rivelazione OOC (fuori dal personaggio)",
	["CO_CHAT_MAIN_OOC_COLOR"] = "Colore OOC",
	["CO_CHAT_MAIN_OOC_PATTERN"] = "Modello della rivelazione OOC",
	["CO_CHAT_REMOVE_REALM"] = "Rimuovere regno dai nomi dei giocatori",
	["CO_CONFIGURATION"] = "Impostazioni",
	["CO_GENERAL"] = "Impostazioni generali",
	["CO_GENERAL_CHANGELOCALE_ALERT"] = [=[Ricarica l'interfaccia in modo da cambiare la lingua a %s ora?

In caso contrario, la lingua verrà cambiata sul prossima connessione.]=],
	["CO_GENERAL_COM"] = "Comunicazione",
	["CO_GENERAL_MISC"] = "Miscellaneo",
	["CO_GENERAL_NEW_VERSION"] = "Avviso di aggiornamento",
	["CO_GENERAL_NEW_VERSION_TT"] = "Ricevi un avviso quando una nuova versione è disponibile.",
	["CO_GENERAL_UI_ANIMATIONS"] = "Animazioni UI",
	["CO_GLANCE_PRESET_TRP2"] = "Usa lo stile di posizionamento di Total RP 2",
	["CO_GLANCE_PRESET_TRP2_BUTTON"] = "Usa",
	["CO_GLANCE_PRESET_TRP3"] = "Usa lo stile di posizionamento di Total RP 3",
	["CO_MINIMAP_BUTTON_RESET"] = "Resetta posizione",
	["CO_MINIMAP_BUTTON_RESET_BUTTON"] = "Resetta",
	["CO_MODULES_SHOWERROR"] = "Visualizza errore",
	["CO_MODULES_STATUS_0"] = "Dipendenze mancanti",
	["CO_MODULES_STATUS_1"] = "Caricato",
	["CO_MODULES_STATUS_2"] = "Disabilitato",
	["CO_MODULES_STATUS_3"] = "Richiesto l'aggiornamento di Total RP 3",
	["CO_MODULES_STATUS_4"] = "Errore di inizializzazione",
	["CO_MODULES_STATUS_5"] = "Errore all'avvio",
	["CO_MODULES_TT_DEP"] = [=[
%s- %s (versione %s)|r]=],
	["CO_MODULES_TT_DEPS"] = "Dipendenze",
	["CO_MODULES_TT_ERROR"] = [=[

|cffff0000Errore:|r
%s]=],
	["CO_MODULES_TT_NONE"] = "Nessuna dipendenza",
	["CO_MODULES_VERSION"] = "Versione: %s",
	["CO_MSP_T3"] = "Usa solo il modello 3",
	["CO_REGISTER"] = "Registra impostazioni",
	["CO_REGISTER_ABOUT_VOTE"] = "Usa sistema di voto",
	["CO_REGISTER_AUTO_ADD"] = "Aggiungi nuovi giocatori automaticamente",
	["CO_REGISTER_AUTO_PURGE_1"] = "Dopo %s giorno/i",
	["CO_TARGETFRAME_ICON_SIZE"] = "Formato icone",
	["CO_TARGETFRAME_USE_1"] = "Sempre",
	["CO_TARGETFRAME_USE_3"] = "Mai (Disabilitato)",
	["CO_TOOLBAR_CONTENT_STATUS"] = "Stato giocatore (AFK/DND)",
	["CO_TOOLTIP_COLOR"] = "Mostra colori personalizzati",
	["CO_TOOLTIP_CONTRAST"] = "Incrementa contrasto colore",
	["CO_TOOLTIP_FT"] = "Mostra titolo intero",
	["CO_TOOLTIP_GUILD"] = "Mostra informazioni gilda",
	["CO_TOOLTIP_ICONS"] = "Mostra icone",
	["CO_TOOLTIP_NOTIF"] = "Mostra notifiche",
	["CO_TOOLTIP_PETS_INFO"] = "Mostra informazioni compagno",
	["CO_TOOLTIP_RACE"] = "Mostra razza, classe e livello",
	["CO_TOOLTIP_REALM"] = "Mostra reame",
	["CO_TOOLTIP_RELATION"] = "Mostra colore relazione",
	["CO_TOOLTIP_SPACING"] = "Mostra spaziatura",
	["CO_TOOLTIP_TITLE"] = "Mostra titolo",
	["COM_LIST"] = "Lista di comandi:",
	["DB_HTML_GOTO"] = "Clicca per aprire",
	["DB_MORE"] = "Altri moduli",
	["DB_NEW"] = "Cosa c'è di nuovo?",
	["DB_STATUS"] = "Stato",
	["DB_STATUS_RP"] = "Stato personaggio",
	["DB_STATUS_RP_IC"] = "Nel personaggio",
	["DB_STATUS_RP_OOC"] = "Fuori dal personaggio",
	["DTBK_AFK"] = "Total RP 3 - AFK/DND",
	["DTBK_CLOAK"] = "Total RP 3 - Mantello",
	["DTBK_HELMET"] = "Total RP 3 - Elmo",
	["DTBK_LANGUAGES"] = "Total RP 3 - Linguaggi",
	["DTBK_RP"] = "Total RP 3 - IC/OOC",
	["GEN_WELCOME_MESSAGE"] = "Grazie per aver scelto Total RP 3 (v% s)! Divertiti!",
	["MAP_BUTTON_NO_SCAN"] = "La scansione non è disponibile",
	["MAP_BUTTON_SCANNING"] = "Scansione",
	["MAP_SCAN_CHAR_TITLE"] = "Personaggi",
	["MATURE_FILTER_EDIT_DICTIONARY_BUTTON"] = "Modifica",
	["MATURE_FILTER_EDIT_DICTIONARY_EDIT_WORD"] = "Modifica questa parola",
	["MATURE_FILTER_FLAG_PLAYER"] = "Segnala come maturo",
	["MATURE_FILTER_FLAG_PLAYER_OPTION"] = "Segnala come maturo",
	["MATURE_FILTER_TOOLTIP_WARNING"] = "Contenuto per adulti",
	["MATURE_FILTER_WARNING_CONTINUE"] = "Proseguire",
	["MATURE_FILTER_WARNING_GO_BACK"] = "Tornare",
	["MATURE_FILTER_WARNING_TITLE"] = "Contenuto per adulti",
	["NEW_VERSION"] = [=[|cff00ff00Una versione nuova del TRP3 (v %s) è disponibile.

|cffffff00Noi ti incoraggiamo di rimanere aggiornato.|r

Questo messaggio apparirà solo una volta per sessione, e si può disattivarlo nell'impostazioni. (Impostazioni generali => Miscellaneo).]=],
	["NEW_VERSION_TITLE"] = "Nuovo aggiornamento disponibile",
	["NPC_TALK_SAY_PATTERN"] = "dici:",
	["NPC_TALK_WHISPER_PATTERN"] = "sussurra:",
	["NPC_TALK_YELL_PATTERN"] = "urla:",
	["PR_CO_EMPTY"] = "Nessun profilo compagno",
	["PR_CO_MOUNT"] = "Cavalcatura",
	["PR_CO_NEW_PROFILE"] = "Nuovo profilo compagno",
	["PR_CO_PROFILEMANAGER_TITLE"] = "Profili compagni",
	["PR_CREATE_PROFILE"] = "Crea profilo",
	["PR_DELETE_PROFILE"] = "Cancella profilo",
	["PR_DUPLICATE_PROFILE"] = "Duplica profilo",
	["PR_EXPORT_IMPORT_TITLE"] = "Esportazione/importazione dei profili",
	["PR_EXPORT_TOO_LARGE"] = [=[Questo profilo è troppo grande e non può essere esportato.

Grandezza del profilo: %0.2f kB
Max: 20 kB]=],
	["PR_IMPORT"] = "Importare",
	["PR_IMPORT_CHAR_TAB"] = "importa personaggi",
	["PR_IMPORT_IMPORT_ALL"] = "Importa tutto",
	["PR_PROFILE"] = "Profilo",
	["PR_PROFILE_CREATED"] = "Profilo %s creato.",
	["PR_PROFILE_DELETED"] = "Profilo %s cancellato.",
	["PR_PROFILE_LOADED"] = "Il profilo %s è stato caricato.",
	["PR_PROFILE_MANAGEMENT_TITLE"] = "Gestione profilo",
	["PR_PROFILEMANAGER_ACTIONS"] = "Azioni",
	["PR_PROFILEMANAGER_ALREADY_IN_USE"] = "Il nome profilo %s non è disponibile.",
	["PR_PROFILEMANAGER_CURRENT"] = "Profilo corrente",
	["PR_PROFILEMANAGER_RENAME"] = "Rinomina profilo",
	["PR_PROFILEMANAGER_SWITCH"] = "Seleziona profilo",
	["PR_PROFILEMANAGER_TITLE"] = "Profili personaggi",
	["PR_PROFILES"] = "Profili",
	["REG_COMPANION"] = "Compagno",
	["REG_COMPANION_INFO"] = "Informazioni",
	["REG_COMPANION_NAME"] = "Nome",
	["REG_COMPANION_NAME_COLOR"] = "Nome colore",
	["REG_COMPANION_PAGE_TUTO_C_1"] = "Consulta",
	["REG_COMPANION_PROFILES"] = "Profili compagni",
	["REG_COMPANION_TF_BOUND_TO"] = "Seleziona profilo",
	["REG_COMPANION_TF_CREATE"] = "Crea nuovo profilo",
	["REG_COMPANION_TF_OPEN"] = "Apri pagina",
	["REG_COMPANION_TF_OWNER"] = "Proprietario: %s",
	["REG_COMPANION_TF_PROFILE"] = "Profilo compagno",
	["REG_COMPANION_TF_PROFILE_MOUNT"] = "Profilo cavalcatura",
	["REG_COMPANION_TITLE"] = "Titolo",
	["REG_COMPANIONS"] = "Compagni",
	["REG_DELETE_WARNING"] = [=[Sei sicuro di voler eliminare il profilo di %s?
]=],
	["REG_IGNORE_TOAST"] = "Personaggio ignorato",
	["REG_LIST_ACTIONS_MASS_IGNORE"] = "Ignora profili",
	["REG_LIST_ACTIONS_MASS_REMOVE"] = "Rimuovi profili",
	["REG_LIST_ACTIONS_PURGE_ALL"] = "Rimuovi tutti i profili",
	["REG_LIST_ACTIONS_PURGE_COUNT"] = "%s profili saranno rimossi.",
	["REG_LIST_ADDON"] = "Tipo profilo",
	["REG_LIST_CHAR_EMPTY"] = "Nessun personaggio",
	["REG_LIST_CHAR_FILTER"] = "Personaggi: %s / %s",
	["REG_LIST_CHAR_IGNORED"] = "Ignorato",
	["REG_LIST_CHAR_SEL"] = "Seleziona personaggio",
	["REG_LIST_CHAR_TITLE"] = "Lista personaggio",
	["REG_LIST_CHAR_TT"] = "Clicca per vedere la pagina",
	["REG_LIST_CHAR_TT_IGNORE"] = "Personaggi ignorati",
	["REG_LIST_CHAR_TT_NEW_ABOUT"] = "Descrizione non letta",
	["REG_LIST_CHAR_TT_RELATION"] = [=[Relazione:
|cff00ff00%s]=],
	["REG_LIST_FILTERS"] = "Filtri",
	["REG_LIST_FILTERS_TT"] = [=[|cffffff00Click:|r Applica filtri
|cffffff00Right-Click:|r Pulisci filtri]=],
	["REG_LIST_FLAGS"] = "Bandiere",
	["REG_LIST_GUILD"] = "Personaggi della gilda",
	["REG_LIST_IGNORE_EMPTY"] = "Nessun personaggio ignorato",
	["REG_LIST_IGNORE_TITLE"] = "Lista degli ignorati",
	["REG_LIST_NAME"] = "Nome personaggi",
	["REG_LIST_NOTIF_ADD"] = "Nuovo profilo scoperto per |cff00ff00%s",
	["REG_LIST_NOTIF_ADD_CONFIG"] = "Nuovo profilo scoperto",
	["REG_LIST_NOTIF_ADD_NOT"] = "Questo profilo non esiste più.",
	["REG_LIST_PETS_EMPTY"] = "Nessun compagno",
	["REG_LIST_PETS_FILTER"] = "Compagni: %s / %s",
	["REG_LIST_PETS_TITLE"] = "Lista compagni",
	["REG_PLAYER"] = "Personaggio",
	["REG_PLAYER_ABOUT"] = "Di",
	["REG_PLAYER_ABOUT_EMPTY"] = "Nessuna descrizione",
	["REG_PLAYER_ABOUT_MUSIC"] = "Tema personaggio",
	["REG_PLAYER_ABOUT_MUSIC_LISTEN"] = "Avvia tema",
	["REG_PLAYER_ABOUT_MUSIC_REMOVE"] = "Deseleziona tema",
	["REG_PLAYER_ABOUT_MUSIC_SELECT"] = "Seleziona tema personaggio",
	["REG_PLAYER_ABOUT_MUSIC_SELECT2"] = "Seleziona tema",
	["REG_PLAYER_ABOUT_MUSIC_STOP"] = "Ferma tema",
	["REG_PLAYER_ABOUT_NOMUSIC"] = "|cffff9900Nessun tema",
	["REG_PLAYER_ABOUT_T1_YOURTEXT"] = "Il tuo testo qui...",
	["REG_PLAYER_ABOUT_UNMUSIC"] = "|cffff9900Tema sconosciuto",
	["REG_PLAYER_ABOUT_VOTE_DOWN"] = "Non mi piace questo contenuto",
	["REG_PLAYER_ABOUT_VOTE_SENDING"] = "Invio il tuo voto a %s ...",
	["REG_PLAYER_ABOUT_VOTE_UP"] = "Mi piace questo contenuto",
	["REG_PLAYER_ABOUT_VOTES"] = "Statistica",
	["REG_PLAYER_ABOUTS"] = "Di %s",
	["REG_PLAYER_ADD_NEW"] = "Crea nuovo",
	["REG_PLAYER_AGE"] = "Età",
	["REG_PLAYER_BIRTHPLACE"] = "Luogo di nascita",
	["REG_PLAYER_CARACT"] = "Caratteristiche",
	["REG_PLAYER_CHARACTERISTICS"] = "Caratteristiche",
	["REG_PLAYER_CLASS"] = "Classe",
	["REG_PLAYER_COLOR_CLASS"] = "Colore classe",
	["REG_PLAYER_CURRENT"] = "Attualmente",
	["REG_COMPANIONS_SHORTDESCRIPTION"]= "Breve descrizione",
	["REG_PLAYER_CURRENT_OOC"] = "Questa informazione è OOC",
	["REG_PLAYER_CURRENTOOC"] = "Attualmente (OOC)",
	["REG_PLAYER_EYE"] = "Colore degli occhi",
	["REG_PLAYER_EYE_TT"] = [=[Qui è possibile indicare il colore degli occhi del tuo personaggio.

Tenete presente che, anche se il viso del personaggio è costantemente nascosto, che potrebbe ancora essere degni di nota, per ogni evenienza.]=],
	["REG_PLAYER_FIRSTNAME"] = "Nome",
	["REG_PLAYER_FIRSTNAME_TT"] = [=[Questo è il nome del vostro personaggio. Questo è un campo obbligatorio, quindi se non si specifica un nome, verrà utilizzato il nome del personaggio di default (|cffffff00%s|r).

È possibile utilizzare un |c0000ff00soprannome |r!]=],
	["REG_PLAYER_FULLTITLE"] = "Titolo completo",
	["REG_PLAYER_GLANCE"] = "A prima vista",
	["REG_PLAYER_GLANCE_TITLE"] = "Nome attributo",
	["REG_PLAYER_HEIGHT"] = "Altezza",
	["REG_PLAYER_HEIGHT_TT"] = [=[Questa è l'altezza del tuo personaggio.
Ci sono diverse maniere per farlo:|c0000ff00
- Un numero preciso: 170 cm, 6'5"...
- Una qualifica: alto, basso...]=],
	["REG_PLAYER_HISTORY"] = "Storia",
	["REG_PLAYER_ICON"] = "Icona del personaggio",
	["REG_PLAYER_IGNORE_WARNING"] = [=[Vuoi ignorare quei personaggi?

|cffff990%s

È possibile inserire la ragione di seguito. Questa è una nota personale che servirà da promemoria.]=],
	["REG_PLAYER_LASTNAME"] = "Cognome",
	["REG_PLAYER_LASTNAME_TT"] = "Questo è il nome di famiglia del tuo personaggio.",
	["REG_PLAYER_MORE_INFO"] = "Informazioni aggiuntive",
	["REG_PLAYER_MSP_HOUSE"] = "Nome della casa",
	["REG_PLAYER_MSP_MOTTO"] = "Motto",
	["REG_PLAYER_MSP_NICK"] = "Soprannome",
	["REG_PLAYER_NAMESTITLES"] = "Nomi e titoli",
	["REG_PLAYER_NO_CHAR"] = "Nessuna caratteristica",
	["REG_PLAYER_PEEK"] = "Miscellaneo",
	["REG_PLAYER_PHYSICAL"] = "Descrizione fisica",
	["REG_PLAYER_PSYCHO"] = "Caratteristiche di personalità",
	["REG_PLAYER_PSYCHO_Acete"] = "Asceta",
	["REG_PLAYER_PSYCHO_ADD"] = "Aggiungi tratto della personalità",
	["REG_PLAYER_PSYCHO_ATTIBUTENAME_TT"] = "Nome attributo",
	["REG_PLAYER_PSYCHO_Bonvivant"] = "Conviviale",
	["REG_PLAYER_PSYCHO_CHAOTIC"] = "Caotico",
	["REG_PLAYER_PSYCHO_Chaste"] = "Casto",
	["REG_PLAYER_PSYCHO_Conciliant"] = "Paragone",
	["REG_PLAYER_PSYCHO_Couard"] = "Smidollato",
	["REG_PLAYER_PSYCHO_CREATENEW"] = "Crea un tratto",
	["REG_PLAYER_PSYCHO_Cruel"] = "Brutale",
	["REG_PLAYER_PSYCHO_CUSTOM"] = "Tratto personalizzato",
	["REG_PLAYER_PSYCHO_Egoiste"] = "Egoista",
	["REG_PLAYER_PSYCHO_Genereux"] = "Altruistico",
	["REG_PLAYER_PSYCHO_Impulsif"] = "Impulsivo",
	["REG_PLAYER_PSYCHO_Indulgent"] = "Indulgente",
	["REG_PLAYER_PSYCHO_Loyal"] = "Legale",
	["REG_PLAYER_PSYCHO_Luxurieux"] = "Lascivo",
	["REG_PLAYER_PSYCHO_Misericordieux"] = "Amichevole",
	["REG_PLAYER_PSYCHO_MORE"] = "Aggiungere un punto di %s",
	["REG_PLAYER_PSYCHO_PERSONAL"] = "Tratti personali",
	["REG_PLAYER_PSYCHO_Pieux"] = "Superstizioso",
	["REG_PLAYER_PSYCHO_POINT"] = "Aggiungere un punto",
	["REG_PLAYER_PSYCHO_Pragmatique"] = "Rinnegato",
	["REG_PLAYER_PSYCHO_Rationnel"] = "Razionale",
	["REG_PLAYER_PSYCHO_Reflechi"] = "Prudente",
	["REG_PLAYER_PSYCHO_Rencunier"] = "Vendicativo",
	["REG_PLAYER_PSYCHO_Sincere"] = "Veritiero",
	["REG_PLAYER_PSYCHO_SOCIAL"] = "Caratteristiche sociali",
	["REG_PLAYER_PSYCHO_Trompeur"] = "Ingannevole",
	["REG_PLAYER_PSYCHO_Valeureux"] = "Valoroso",
	["REG_PLAYER_RACE"] = "Razza",
	["REG_PLAYER_RACE_TT"] = "Qui va la razza del tuo personaggio. Non deve essere limitato a razze giocabili. Ci sono molte razze in Warcraft che possono assumere le forme più comuni...",
	["REG_PLAYER_RESIDENCE"] = "Residenza",
	["REG_PLAYER_RESIDENCE_SHOW"] = "Coordinate residenza",
	["REG_PLAYER_RESIDENCE_SHOW_TT"] = [=[|cff00ff00%s

|rClicca per vedere sulla mappa]=],
	["REG_PLAYER_STYLE_BATTLE"] = "Risoluzione battaglia nel Roleplay",
	["REG_PLAYER_STYLE_BATTLE_1"] = "World of warcraft PVP",
	["REG_PLAYER_STYLE_BATTLE_3"] = "Battaglia in /roll",
	["REG_PLAYER_STYLE_BATTLE_4"] = "Battaglia in emote",
	["REG_PLAYER_STYLE_DEATH"] = "Accetto la morte del personaggio",
	["REG_PLAYER_STYLE_FREQ"] = "Frequenza in cui si interpreta il personaggio",
	["REG_PLAYER_STYLE_FREQ_1"] = "Tempo pieno, no OOC",
	["REG_PLAYER_STYLE_FREQ_2"] = "La maggior parte del tempo",
	["REG_PLAYER_STYLE_FREQ_4"] = "Casuale",
	["REG_PLAYER_STYLE_FREQ_5"] = "Tempo pieno OOC, non è un personaggio RP",
	["REG_PLAYER_STYLE_HIDE"] = "Non mostrare",
	["REG_PLAYER_STYLE_INJURY"] = "Accetto lesioni al personaggio",
	["REG_PLAYER_STYLE_PERMI"] = "Con il permesso del giocatore",
	["REG_PLAYER_STYLE_ROMANCE"] = "Accetto romanticismo con il personaggio",
	["REG_PLAYER_STYLE_RPSTYLE"] = "Stile di Roleplay",
	["REG_PLAYER_STYLE_RPSTYLE_SHORT"] = "Stile RP",
	["REG_PLAYER_STYLE_WOWXP"] = "Esperienza World of Warcraft",
	["REG_PLAYER_TITLE"] = "Titolo",
	["REG_PLAYER_TRP2_PIERCING"] = "Piercings",
	["REG_PLAYER_TRP2_TATTOO"] = "Tatuaggi",
	["REG_PLAYER_TRP2_TRAITS"] = "Fisionomia",
	["REG_REGISTER_CHAR_LIST"] = "Lista personaggi",
	["REG_RELATION"] = "Relazione",
	["REG_RELATION_BUSINESS"] = "Commerciale",
	["REG_RELATION_BUSINESS_TT"] = "%s e %s sono in relazione commerciale.",
	["REG_RELATION_FAMILY"] = "Famiglia",
	["REG_RELATION_FAMILY_TT"] = "%s è un consanguineo di %s.",
	["REG_RELATION_FRIEND"] = "Amichevole",
	["REG_RELATION_FRIEND_TT"] = "%s considera %s un amico.",
	["REG_RELATION_LOVE"] = "Amore",
	["REG_RELATION_LOVE_TT"] = "%s è innamorato di %s!",
	["REG_RELATION_NEUTRAL"] = "Neutrale",
	["REG_RELATION_NONE"] = "Nessuna",
	["REG_RELATION_UNFRIENDLY"] = "Ostile",
	["REG_RELATION_UNFRIENDLY_TT"] = "A %s non piace chiaramente %s.",
	["REG_TT_GUILD"] = "%s di |cffff9900%s",
	["REG_TT_IGNORED"] = "< Il personaggio viene ignorato >",
	["REG_TT_IGNORED_OWNER"] = "< Il proprietario viene ignorato >",
	["REG_TT_LEVEL"] = "Livello %s %s",
	["REG_TT_NOTIF"] = "Descrizione non letta",
	["REG_TT_REALM"] = "Reame: |cffff9900%s",
	["SCRIPT_ERROR"] = "Errore nello script.",
	["TB_AFK_MODE"] = "Assente",
	["TB_DND_MODE"] = "Non disturbare",
	["TB_LANGUAGE"] = "Lingua",
	["TB_LANGUAGES_TT"] = "Cambia lingua",
	["TB_NORMAL_MODE"] = "Normale",
	["TB_RPSTATUS_OFF"] = "Personaggio: |cffff0000Fuori dal personaggio",
	["TB_RPSTATUS_ON"] = "Personaggio: |cff00ff00Nel personaggio",
	["TB_RPSTATUS_TO_OFF"] = "Vai |cffff0000fuori dal personaggio",
	["TB_RPSTATUS_TO_ON"] = "Vai |cff00ff00nel personaggio",
	["TB_STATUS"] = "Giocatore",
	["TB_SWITCH_CAPE_1"] = "Mostra mantello",
	["TB_SWITCH_CAPE_2"] = "Nascondi mantello",
	["TB_SWITCH_CAPE_OFF"] = "Mantello: |cffff0000Nascosto",
	["TB_SWITCH_CAPE_ON"] = "Mantello: |cff00ff00In mostra",
	["TB_SWITCH_HELM_1"] = "Mostra elmo",
	["TB_SWITCH_HELM_2"] = "Nascondi elmo",
	["TB_SWITCH_HELM_OFF"] = "Elmo: |cffff0000Nascosto",
	["TB_SWITCH_HELM_ON"] = "Elmo: |cff00ff00In mostra",
	["TB_SWITCH_PROFILE"] = "Passa a un'altro profilo",
	["TF_IGNORE"] = "Ignora giocatore",
	["TF_OPEN_CHARACTER"] = "Mostra pagina personaggio",
	["TF_OPEN_COMPANION"] = "Mostra pagina compagno",
	["TF_OPEN_MOUNT"] = "Mostra pagina cavalcatura",
	["TF_PLAY_THEME"] = "Avvia tema personaggio",
	["TF_PLAY_THEME_TT"] = [=[|cffffff00Clicca:|r Avvia |cff00ff00%s
|cffffff00Clic-destro:|r Ferma tema]=],
	["UI_CLOSE_ALL"] = "Chiudi tutto",
	["UI_COLOR_BROWSER_SELECT"] = "Seleziona colore",
	["UI_COMPANION_BROWSER_HELP"] = "Seleziona un animale per la battaglia",
	["UI_ICON_BROWSER_HELP"] = "Copia icona",
	["UI_ICON_SELECT"] = "Seleziona icona",
	["UI_IMAGE_SELECT"] = "Seleziona immagine",
	["UI_LINK_TEXT"] = "Il tuo testo quì",
	["UI_LINK_URL"] = "http://ilTuo.url.quì",
	["UI_MUSIC_SELECT"] = "Seleziona musica"
}

TRP3_API.loc:RegisterNewLocale("itIT", "Italiano", localeContent);

localeContent = {
	["ABOUT_TITLE"] = "약",
	["BW_COLOR_CODE"] = "색상 코드",
	["BW_COLOR_CODE_ALERT"] = "잘못된 16 진수 코드!",
	["BW_COLOR_PRESET_SAVE"] = "현재 색상 저장",
	["BW_COLOR_PRESET_TITLE"] = "색상 사전 설정",
	["CL_EXPIRED"] = "이 링크가 만료되었습니다.",
	["CL_IMPORT_PROFILE"] = "프로필 가져 오기",
	["CM_ACTIONS"] = "행위",
	["CM_APPLY"] = "적용",
	["CM_CANCEL"] = "취소",
	["CM_CENTER"] = "센터",
	["CM_CLASS_DEATHKNIGHT"] = "죽음의 기사 ",
	["CM_CLASS_DRUID"] = "드루이드 ",
	["CM_CLASS_HUNTER"] = "사냥꾼",
	["CM_CLASS_MAGE"] = "마법사 ",
	["CM_CLASS_MONK"] = "수도사",
	["CM_CLASS_PALADIN"] = "성기사",
	["CM_CLASS_PRIEST"] = "사제",
	["CM_CLASS_ROGUE"] = "도적",
	["CM_CLASS_SHAMAN"] = "주술사 ",
	["CM_CLASS_UNKNOWN"] = "알 수없는",
	["CM_CLASS_WARLOCK"] = "흑마법사",
	["CM_CLASS_WARRIOR"] = "전사 ",
	["CM_CLICK"] = "클릭",
	["CM_COLOR"] = "색",
	["CM_DRAGDROP"] = "끌어서 놓기",
	["CM_ICON"] = "아이콘",
	["CM_IMAGE"] = "영상",
	["CM_LEFT"] = "왼쪽",
	["CM_LINK"] = "링크",
	["CM_NAME"] = "이름",
	["CM_RIGHT"] = "권리",
	["CM_UNKNOWN"] = "알 수없는",
	["CO_ANCHOR_LEFT"] = "왼쪽",
	["CO_ANCHOR_RIGHT"] = "권리",
	["COM_LIST"] = "명령의 목록:",
	["GEN_WELCOME_MESSAGE"] = "Total RP 3 (v %s)를 사용하여 주셔서 감사합니다! 재미를!"
}

TRP3_API.loc:RegisterNewLocale("koKR", "한국어", localeContent);

localeContent = {
	["ABOUT_TITLE"] = "Sobre",
	["BINDING_NAME_TRP3_OPEN_TARGET_PROFILE"] = "Abrir perfil do alvo ",
	["BINDING_NAME_TRP3_TOGGLE"] = "Mostrar/ocultar tela principal",
	["BINDING_NAME_TRP3_TOGGLE_CHARACTER_STATUS"] = "Mudar status do personagem ",
	["BINDING_NAME_TRP3_TOOLBAR_TOGGLE"] = "Mostrar/ocultar barra de ferramentas",
	["BLIZZARD_NAMEPLATES_MODULE_DESCRIPTION"] = "Ativar a customização das placas de nomes da Blizzard",
	["BLIZZARD_NAMEPLATES_MODULE_NAME"] = "Placas de nomes da blizzard",
	["BROADCAST_10"] = "|cffff9900Você já está em 10 canais. O TRP3 não tentará se conectar novamente ao canal de transmissão e você não poderá usar algumas opções como localização de jogadores no mapa.",
	["BROADCAST_OFFLINE_DISABLED"] = "Transmissão Offline foi desativada.",
	["BROADCAST_PASSWORD"] = [=[|cffff0000O canal de transmissão (%s) está protegido por senha.
|cffff9900O TRP3 não tentará mais conectar-se ao canal de transmissão, mas você não poderá usar algumas opções como localização de jogadores no mapa.
|cff00ff00Você pode desativar ou trocar o canal de transmissão nas opções gerais do TRP3.]=],
	["BROADCAST_PASSWORDED"] = [=[|cffff0000O usuário |r%s|cffff0000 acabou de colocar uma senha no canal de transmissão (%s).
|cffff9900Se você não sabe a senha, você não poderá usar opções como localização de jogadores no mapa.]=],
	["BW_COLOR_CODE"] = "Código de cor",
	["BW_COLOR_CODE_ALERT"] = "Código hexadecimal incorreto!",
	["BW_COLOR_CODE_TT"] = "Você pode colar um código de cor hexadecimal de 6 caracteres aqui e pressionar Enter.",
	["BW_COLOR_PRESET_DELETE"] = "Deletar %s predefinidos ",
	["BW_COLOR_PRESET_RENAME"] = "Renomear %s predefinidos ",
	["BW_COLOR_PRESET_SAVE"] = "Salvar cor atual ",
	["BW_COLOR_PRESET_TITLE"] = "Cores predefinidas ",
	["BW_CUSTOM_NAME"] = "Nome de cor personalizada",
	["BW_CUSTOM_NAME_TITLE"] = "Nome (Opcional)",
	["BW_CUSTOM_NAME_TT"] = "\" Você pode nomear a cor personalizada que está salvando. Se deixar vazio, será usado o código de cor.",
	["CL_COMPANION_PROFILE"] = "Perfil do Companheiro",
	["CL_CONTENT_SIZE"] = "Tamanho: %s",
	["CL_DIRECTORY_COMPANION_PROFILE"] = "Diretório do perfil do Companheiro",
	["CL_DIRECTORY_PLAYER_PROFILE"] = "Diretório do perfil do jogador ",
	["CL_DOWNLOADING"] = "Baixando: %0.1f %% ",
	["CL_EXPIRED"] = "O link Expirou. ",
	["CL_GLANCE"] = "Á primeira vista",
	["CL_IMPORT_COMPANION"] = "Importar perfil do companion.",
	["CL_IMPORT_GLANCE"] = "Importar na primeira vista ",
	["CL_IMPORT_PROFILE"] = "Importar perfil.",
	["CL_MAKE_IMPORTABLE"] = "Tornar Importável.",
	["CL_MAKE_IMPORTABLE_BUTTON_TEXT"] = "Tornar Importável",
	["CL_MAKE_IMPORTABLE_SIMPLER"] = "Tornar este %s link importável? pessoas poderão ver, copiar e usar o conteúdo deste link.",
	["CL_MAKE_NON_IMPORTABLE"] = "Ver Somente ",
	["CL_OPEN_COMPANION"] = "Abrir perfil do companion ",
	["CL_OPEN_PROFILE"] = "Abrir perfil ",
	["CL_PLAYER_PROFILE"] = "Perfil do Jogador ",
	["CL_REQUESTING_DATA"] = "Requisitando Link de Arquivos de %s ",
	["CL_SENDING_COMMAND"] = "Enviando comando... ",
	["CL_SENT_BY"] = "Link enviado por: %s",
	["CL_TOOLTIP"] = "Criar link de chat ",
	["CL_TYPE"] = "Tipo de link TRP3: %s ",
	["CL_VERSIONS_DIFFER"] = [=[Este link foi gerado usando uma versão diferente o Total RP 3.

Importar conteúdo vindo de uma versão diferente pode causar problemas em casos de incompatibilidade. Deseja prosseguir mesmo assim? ]=],
	["CM_ACTIONS"] = "Ações",
	["CM_ALT"] = "Alt",
	["CM_APPLY"] = "Aplicar",
	["CM_BLACK"] = "Preto",
	["CM_BLUE"] = "Azul",
	["CM_CANCEL"] = "Cancelar",
	["CM_CENTER"] = "Centro",
	["CM_CLASS_DEATHKNIGHT"] = "Cavaleiro da Morte",
	["CM_CLASS_DEMONHUNTER"] = "Caçador de demônios ",
	["CM_CLASS_DRUID"] = "Druida",
	["CM_CLASS_HUNTER"] = "Caçador",
	["CM_CLASS_MAGE"] = "Mago",
	["CM_CLASS_MONK"] = "Monge",
	["CM_CLASS_PALADIN"] = "Paladino",
	["CM_CLASS_PRIEST"] = "Sacerdote",
	["CM_CLASS_ROGUE"] = "Ladino",
	["CM_CLASS_SHAMAN"] = "Xamã",
	["CM_CLASS_UNKNOWN"] = "Desconhecido",
	["CM_CLASS_WARLOCK"] = "Bruxo",
	["CM_CLASS_WARRIOR"] = "Guerreiro",
	["CM_CLICK"] = "Clique",
	["CM_COLOR"] = "Cor",
	["CM_CTRL"] = "Ctrl",
	["CM_CYAN"] = "Ciano",
	["CM_DELETE"] = "Deletar",
	["CM_DOUBLECLICK"] = "Duplo-click",
	["CM_DRAGDROP"] = "Arrastar & soltar",
	["CM_EDIT"] = "Editar",
	["CM_GREEN"] = "Verde",
	["CM_GREY"] = "Cinza",
	["CM_IC"] = "IC",
	["CM_ICON"] = "Ícone",
	["CM_IMAGE"] = "Imagem",
	["CM_L_CLICK"] = "Clique-esquerdo",
	["CM_LEFT"] = "Esquerda",
	["CM_LINK"] = "Link",
	["CM_LOAD"] = "Carregar",
	["CM_M_CLICK"] = "Clique com botão do meio",
	["CM_MOVE_DOWN"] = "Mover para baixo",
	["CM_MOVE_UP"] = "Mover para cima",
	["CM_NAME"] = "Nome",
	["CM_OOC"] = "OOC",
	["CM_OPEN"] = "Aberto",
	["CM_ORANGE"] = "Laranja",
	["CM_PINK"] = "Rosa",
	["CM_PLAY"] = "Reproduzir",
	["CM_PURPLE"] = "Roxo",
	["CM_R_CLICK"] = "Clique-direito",
	["CM_RED"] = "Vermelho",
	["CM_REMOVE"] = "Remover",
	["CM_RESET"] = "Resetar",
	["CM_RESIZE"] = "Redimensionar",
	["CM_RESIZE_TT"] = "Arraste para redimensionar a janela.",
	["CM_RIGHT"] = "Direita",
	["CM_SAVE"] = "Salvar",
	["CM_SELECT"] = "Selecionar",
	["CM_SHIFT"] = "Shift",
	["CM_SHOW"] = "Exibir",
	["CM_STOP"] = "Parar",
	["CM_TWEET"] = "Enviar um tweet",
	["CM_TWEET_PROFILE"] = "Mostrar url do perfil",
	["CM_UNKNOWN"] = "Desconhecido",
	["CM_VALUE"] = "Valor",
	["CM_WHITE"] = "Branco",
	["CM_YELLOW"] = "Amarelo",
	["CO_ADVANCED_BROADCAST"] = "Comunicações adicionais ",
	["CO_ADVANCED_BROADCAST_CHANNEL_ALWAYS_LAST"] = "Manter último canal de transmissão ",
	["CO_ADVANCED_BROADCAST_CHANNEL_ALWAYS_LAST_TT"] = "Esta opção garantirá que o canal de  transmissão seja sempre o ultimo canal em sua lista de canais. ",
	["CO_ADVANCED_LANGUAGE_WORKAROUND"] = "Ativa Alternativas contra resets de idioma ",
	["CO_ADVANCED_LANGUAGE_WORKAROUND_TT"] = "Desde o patch 8.0.1, o jogo irá repor a língua selecionada para a língua predefinida da sua facção durante cada tela de carregamento. Esta solução garante o restabelecimento da língua selecionada após uma tela de carregamento. ",
	["CO_ADVANCED_LANGUAGES"] = "Idiomas",
	["CO_ADVANCED_LANGUAGES_REMEMBER"] = "Lembrar do último idioma utilizado",
	["CO_ADVANCED_LANGUAGES_REMEMBER_TT"] = "Total RP 3 lembrará qual idioma você estava usando quando saiu do jogo e automaticamente selecionará esse idioma no seu próximo login.",
	["CO_ADVANCED_SETTINGS"] = "Configurações avançadas ",
	["CO_ADVANCED_SETTINGS_MENU_NAME"] = "Avançado ",
	["CO_ADVANCED_SETTINGS_POPUP"] = "Se você modificou uma configuração avançada. Tenha em mente que a alteração dessas configurações pode alterar a sua experiência com o add-on e pode impedir algumas funcionalidades de funcionar corretamente. Utilize por sua conta e risco. ",
	["CO_ADVANCED_SETTINGS_RESET"] = "Resetar configurações avançadas ",
	["CO_ADVANCED_SETTINGS_RESET_TT"] = "Resete todas configurações para o valor padrão. Use isto caso tenha problemas depois de modificar as configurações ",
	["CO_ANCHOR_BOTTOM"] = "Baixo",
	["CO_ANCHOR_BOTTOM_LEFT"] = "Baixo-esquerda",
	["CO_ANCHOR_BOTTOM_RIGHT"] = "Baixo-direita",
	["CO_ANCHOR_CURSOR"] = "Exibir no cursor",
	["CO_ANCHOR_LEFT"] = "Esquerda",
	["CO_ANCHOR_RIGHT"] = "Direita",
	["CO_ANCHOR_TOP"] = "Cima",
	["CO_ANCHOR_TOP_LEFT"] = "Cima-esquerda",
	["CO_ANCHOR_TOP_RIGHT"] = "Cima-direita",
	["CO_CHAT"] = "Configurações de conversa",
	["CO_CHAT_DISABLE_OOC"] = "Desativar Configurações quando OOC (Fora do personagem)",
	["CO_CHAT_DISABLE_OOC_TT"] = "Desativar todas as personalizações de chat do Total RP 3 (nomes personalizados, detecção de emoções, discursos NPC, etc.) quando o seu personagem é definido como \"Fora Do Personagem\" ",
	["CO_CHAT_INCREASE_CONTRAST"] = "Aumentar contraste de cores ",
	["CO_CHAT_INSERT_FULL_RP_NAME"] = "Insira nomes de RP sobre Shift+clique",
	["CO_CHAT_INSERT_FULL_RP_NAME_TT"] = [=[Inserir o nome completo de RP do(a) jogador(a) ao dar SHIFT-Clique no nome dele(a) na janela de chat.

(Quando esta opção estiver ativa, você pode dar ALT-SHIFT-Clique em um nome quando quiser o resultado padrão de inserir o nome do personagem ao invés do nome de RP completo.)]=],
	["CO_CHAT_MAIN"] = "Configurações principais de conversa",
	["CO_CHAT_MAIN_COLOR"] = "Usar cores personalizadas para nomes",
	["CO_CHAT_MAIN_EMOTE"] = "Detectar emotes",
	["CO_CHAT_MAIN_EMOTE_PATTERN"] = "Padrão de detecção de emote",
	["CO_CHAT_MAIN_EMOTE_USE"] = "Usar detecção de emote",
	["CO_CHAT_MAIN_EMOTE_YELL"] = "Sem emote em grito",
	["CO_CHAT_MAIN_EMOTE_YELL_TT"] = "Não mostrar *emote* ou <emote> em gritos.",
	["CO_CHAT_MAIN_NAMING"] = "Método de nomes",
	["CO_CHAT_MAIN_NAMING_1"] = "Manter nomes originais",
	["CO_CHAT_MAIN_NAMING_2"] = "Usar nomes personalizados",
	["CO_CHAT_MAIN_NAMING_3"] = "Nome + sobrenome",
	["CO_CHAT_MAIN_NAMING_4"] = "Título curto + Nome + Apelido",
	["CO_CHAT_MAIN_NPC"] = "Detectar fala de PnJ",
	["CO_CHAT_MAIN_NPC_PREFIX"] = "Padrão de detecção de fala de PnJ",
	["CO_CHAT_MAIN_NPC_PREFIX_TT"] = [=[Se uma conversa no canal EMOTE começar com este prefixo, será interpretado como uma fala de PnJ.

|cff00ff00Padrão : "|| "
(sem aspas e com espaço após a barra)]=],
	["CO_CHAT_MAIN_NPC_USE"] = "Usar detecção de conversa de PnJ",
	["CO_CHAT_MAIN_OOC"] = "Detecção de OOC",
	["CO_CHAT_MAIN_OOC_COLOR"] = "Cor de OOC",
	["CO_CHAT_MAIN_OOC_PATTERN"] = "Padrão de detecção de OOC",
	["CO_CHAT_MAIN_OOC_USE"] = "Detecção de OOC",
	["CO_CHAT_MAIN_SPEECH"] = "Detecção de fala ",
	["CO_CHAT_MAIN_SPEECH_USE"] = "Usar detecção de fala ",
	["CO_CHAT_MAIN_SPEECH_USE_TT"] = "O texto rodeado de aspas será colorido como se fosse escrito em /say. ",
	["CO_CHAT_NPCSPEECH_REPLACEMENT"] = "Customize nomes de Companheiros em falas dos NPC'S ",
	["CO_CHAT_NPCSPEECH_REPLACEMENT_TT"] = [=[Se um nome do Companheiro estiver entre parênteses em uma fala de NPC, será colorido e o seu ícone será mostrado dependendo das suas configurações acima.
]=],
	["CO_CHAT_REMOVE_REALM"] = "Remover reino dos nomes dos jogadores ",
	["CO_CHAT_SHOW_OOC"] = "Mostrar indicador de OOC (Fora do Personagem)",
	["CO_CHAT_USE"] = "Canais de conversa usados",
	["CO_CHAT_USE_ICONS"] = "Mostrar ícones do jogador ",
	["CO_CHAT_USE_SAY"] = "Canal Say",
	["CO_CONFIGURATION"] = "Configurações",
	["CO_CURSOR_DISABLE_OOC"] = "Desativado enquanto estiver OOC (Fora do Personagem)",
	["CO_CURSOR_DISABLE_OOC_TT"] = "Desativar as modificações do cursor quando o seu status de Roleplay estiver definido para Fora do Personagem.",
	["CO_CURSOR_MODIFIER_KEY"] = "Tecla de modificação ",
	["CO_CURSOR_MODIFIER_KEY_TT"] = "Uma tecla de modificação precisar estar pressionada enquanto se clica com o botão direito do mouse, para evitar cliques acidentais. ",
	["CO_CURSOR_RIGHT_CLICK"] = "Clique com o botão direito do mouse para abrir o perfil ",
	["CO_CURSOR_RIGHT_CLICK_TT"] = "Clique com o botão direito do mouse em um jogador no mundo 3D para abrir o seu perfil, se o tiver. |TInterface\\Cursor\\WorkOrders:25|t Este ícone será anexado ao cursor quando um jogador tem um perfil e poderá clicar com o botão direito do mouse sobre eles. Note: Esta função é desativada durante o combate. ",
	["CO_CURSOR_TITLE"] = "Interações do cursor ",
	["CO_GENERAL"] = "Configurações gerais",
	["CO_GENERAL_BROADCAST"] = "Usar canal de anúncio",
	["CO_GENERAL_BROADCAST_C"] = "Nome do canal de anúncio",
	["CO_GENERAL_BROADCAST_TT"] = "O canal de anúncio é usado para muitas funções. Desabilitá-lo irá desabilitar todas as funções como posição de personagens no mapa, sons locais, acesso a sinalizações...",
	["CO_GENERAL_CHANGELOCALE_ALERT"] = [=[Recarregar a interface para mudar a linguagem para %s agora?

Se não recarregar, a linguagem será alterada na próxima vez que conectar.]=],
	["CO_GENERAL_COM"] = "Comunicação",
	["CO_GENERAL_DEFAULT_COLOR_PICKER"] = "Selecionador de cores padrão ",
	["CO_GENERAL_DEFAULT_COLOR_PICKER_TT"] = "Ative para sempre usar o selecionador de cores padrão. Útil caso use um Addon de selecionador de cores. ",
	["CO_GENERAL_HEAVY"] = "Alerta de perfil pesado",
	["CO_GENERAL_HEAVY_TT"] = "Receber alerta quando o tamanho total de seu perfil exceder um valor aceitável.",
	["CO_GENERAL_LOCALE"] = "Local do addon",
	["CO_GENERAL_MISC"] = "Diversos",
	["CO_GENERAL_NEW_VERSION"] = "Alerta de atualização",
	["CO_GENERAL_NEW_VERSION_TT"] = "Receber alerta quando uma nova versão estiver disponível.",
	["CO_GENERAL_RESET_CUSTOM_COLORS"] = "Resetar cores Customizadas ",
	["CO_GENERAL_RESET_CUSTOM_COLORS_TT"] = "Remove todas cores salvas no selecionador de cores ",
	["CO_GENERAL_RESET_CUSTOM_COLORS_WARNING"] = "Tem certeza que quer remover todas cores customizadas salvas no selecionador de cores? ",
	["CO_GENERAL_TT_SIZE"] = "Tamanho do texto da tela de informações",
	["CO_GENERAL_UI_ANIMATIONS"] = "Animações de interface",
	["CO_GENERAL_UI_ANIMATIONS_TT"] = "Ativar animações de interface",
	["CO_GENERAL_UI_SOUNDS"] = "Sons de interface",
	["CO_GENERAL_UI_SOUNDS_TT"] = "Ativar sons da interface (quando abrir janelas, mudar abas, clicar em botões).",
	["CO_GLANCE_LOCK"] = "Travar barra",
	["CO_GLANCE_LOCK_TT"] = "Evita arrastar a barra",
	["CO_GLANCE_MAIN"] = "Barra de \"à primeira vista\"",
	["CO_GLANCE_PRESET_TRP2"] = "Usar posições ao estilo do Total RP 2",
	["CO_GLANCE_PRESET_TRP2_BUTTON"] = "Usar",
	["CO_GLANCE_PRESET_TRP2_HELP"] = "Atalho para a barra de configuração no estilo TRP2: à direita da janela alvo.",
	["CO_GLANCE_PRESET_TRP3"] = "Usar posições estilo Total RP 3",
	["CO_GLANCE_PRESET_TRP3_HELP"] = "Atalho para barra de configuração no estilo TRP3: abaixo da janela alvo.",
	["CO_GLANCE_RESET_TT"] = "Recolocar a barra de posição para baixo-esquerda da tela guia.",
	["CO_GLANCE_TT_ANCHOR"] = "Ponto de referência para janela de informações",
	["CO_HIDE_EMPTY_MAP_BUTTON"] = "Esconder quando nenhum Scan está disponível ",
	["CO_LOCATION"] = "Configurações de localização",
	["CO_LOCATION_ACTIVATE"] = "Habilitar localização de personagens",
	["CO_LOCATION_ACTIVATE_TT"] = "Habilita o sistema de localização de personagens, permitindo que você busque por outros usuários do Total RP no mapa do mundo e permitindo que eles o encontrem.",
	["CO_LOCATION_DISABLE_CLASSIC_PVP"] = "Desativar local quando estiver marcado PvP ",
	["CO_LOCATION_DISABLE_CLASSIC_PVP_TT"] = "Você não irá responder a pedidos de localização de outros jogadores quando estiver marcado para PvP. Esta opção é particularmente útil para evitar abusos do sistema de localização para o localizar você. ",
	["CO_LOCATION_DISABLE_OOC"] = "Desabilitar localização quando OOC",
	["CO_LOCATION_DISABLE_OOC_TT"] = "Você não irá responder a pedidos de localização de outros jogadores quando seu status de RP estiver em Não Interpretando",
	["CO_LOCATION_DISABLE_PVP"] = "Desabilitar localização quando marcado para JvJ",
	["CO_LOCATION_DISABLE_PVP_TT"] = [=[Você não irá responder a pedidos de localização de outros jogadores quando estiver marcado para JvJ.

Esta opção é particularmente útil em reinos de JvJ onde jogadores da outra facção podem abusar o sistema de localização para rastreá-lo.]=],
	["CO_LOCATION_DISABLE_WAR_MODE"] = "Desativar local enquanto estiver no Modo de Guerra ",
	["CO_LOCATION_DISABLE_WAR_MODE_TT"] = "Você não irá responder pedidos de localização de outros jogadores quando tiver o Modo de Guerra ativado e estiver fora de um |cff69CCF0Santuário|r.  Esta opção é particularmente útil para evitar abusos do sistema de localização para localizar você.",
	["CO_LOCATION_SHOW_DIFFERENT_WAR_MODES"] = "Mostrar Jogadores em diferentes Modos de Guerra ",
	["CO_LOCATION_SHOW_DIFFERENT_WAR_MODES_TT"] = "Os jogadores que se encontram atualmente na àrea mas que têm um status de Modo de Guerra diferente do que  será mostrado a você no mapa, com uma opacidade inferior e um ícone especial na ponta da ferramenta. ",
	["CO_MAP_BUTTON"] = "Botão de escaneamento de mapa ",
	["CO_MAP_BUTTON_POS"] = "Botão de trava de escaneamento no mapa",
	["CO_MINIMAP_BUTTON"] = "Botão no minimapa",
	["CO_MINIMAP_BUTTON_FRAME"] = "Janela de referência",
	["CO_MINIMAP_BUTTON_RESET"] = "Reiniciar posições",
	["CO_MINIMAP_BUTTON_RESET_BUTTON"] = "Reiniciar",
	["CO_MINIMAP_BUTTON_SHOW_HELP"] = [=[Se você está usando outro addon para exibir o botão do minimapa do Total RP 3 (FuBar, Titan, Bazooka) você pode remover o botão do minimapa.

|cff00ff00Lembrete: Você pode abrir o Total RP 3 usando /trp3 switch main|r]=],
	["CO_MINIMAP_BUTTON_SHOW_TITLE"] = "Exibir botão do minimapa",
	["CO_MODULES"] = "Status dos módulos",
	["CO_MODULES_DISABLE"] = "Desativar módulo",
	["CO_MODULES_ENABLE"] = "Ativar módulo",
	["CO_MODULES_ID"] = "ID do módulo: %s",
	["CO_MODULES_SHOWERROR"] = "Exibir erros",
	["CO_MODULES_STATUS"] = "Status: %s",
	["CO_MODULES_STATUS_0"] = "Dependências ausentes",
	["CO_MODULES_STATUS_1"] = "Carregado",
	["CO_MODULES_STATUS_2"] = "Desabilitado",
	["CO_MODULES_STATUS_3"] = "Requer atualização do Total RP 3",
	["CO_MODULES_STATUS_4"] = "Erro na inicialização",
	["CO_MODULES_STATUS_5"] = "Erro no carregamento",
	["CO_MODULES_TT_DEP"] = "%s- %s (versão %s)|r",
	["CO_MODULES_TT_DEPS"] = "Dependências",
	["CO_MODULES_TT_ERROR"] = [=[|cffff0000Erro:|r
%s]=],
	["CO_MODULES_TT_NONE"] = "Sem dependências",
	["CO_MODULES_TT_TRP"] = "%sPara Total RP 3 versão mínima %s.|r",
	["CO_MODULES_TUTO"] = [=[Um módulo é uma característica independente que pode ser ativada ou desativada.

Status possíveis:
|cff00ff00Carregado:|r O módulo está disponível e carregado.
|cff999999Desabilitado:|r O módulo está desabilitado.
|cffff9900Dependências em falta:|r Alguns itens essenciais não foram carregados.
|cffff9900Atualização do TRP necessária:|r O módulo precisa da versão mais recente do TRP3.
|cffff0000Erro ao carregar ou iniciar:|r O carregamento do módulo apresentou problemas. O módulo possivelmente gerará erros.!

|cffff9900Quando um módulo é desabilitado, é necessário recarregar a interface.]=],
	["CO_MODULES_VERSION"] = "Versão: %s",
	["CO_MSP"] = "Protocolo Mary Sue",
	["CO_MSP_T3"] = "Usar apenas modelo 3",
	["CO_MSP_T3_TT"] = "Mesmo se escolher outro modelo \"sobre\", o modelo 3 será sempre usado para compatibilidade MSP.",
	["CO_REGISTER"] = "Configuração de registros",
	["CO_REGISTER_ABOUT_H1_SIZE"] = "Tamanho de texto do cabeçalho 1",
	["CO_REGISTER_ABOUT_H1_SIZE_TT"] = "Tamanho do texto entre marcadores {h1}. Padrão: %s ",
	["CO_REGISTER_ABOUT_H2_SIZE"] = "Tamanho de texto do cabeçalho 2",
	["CO_REGISTER_ABOUT_H2_SIZE_TT"] = "Tamanho do texto entre marcadores {h2}. Padrão: %s ",
	["CO_REGISTER_ABOUT_H3_SIZE"] = "Tamanho de texto do cabeçalho 3",
	["CO_REGISTER_ABOUT_H3_SIZE_TT"] = "Tamanho do texto entre marcadores {h3}. Padrão: %s ",
	["CO_REGISTER_ABOUT_P_SIZE"] = "Tamanho do parágrafo no texto ",
	["CO_REGISTER_ABOUT_P_SIZE_TT"] = [=[Tamanho do texto fora dos marcadores do cabeçalho. Padrão: %s 
]=],
	["CO_REGISTER_ABOUT_SETTINGS"] = "Configurações \"Sobre\"",
	["CO_REGISTER_ABOUT_VOTE"] = "Habilitar sistema de votação",
	["CO_REGISTER_ABOUT_VOTE_TT"] = "Ativa o sistema de votação, permitindo votar (\"curtir\" ou \"não curtir\") outras descrições, e permitir o mesmo para seu perfil.",
	["CO_REGISTER_AUTO_ADD"] = "Adicionar novos jogadores automaticamente",
	["CO_REGISTER_AUTO_ADD_TT"] = "Adiciona automaticamente novos jogadores ao registro.",
	["CO_REGISTER_AUTO_PURGE"] = "Expurgar diretório automaticamente",
	["CO_REGISTER_AUTO_PURGE_0"] = "Desativar expurgo",
	["CO_REGISTER_AUTO_PURGE_1"] = "Depois de %s dia(s)",
	["CO_REGISTER_AUTO_PURGE_TT"] = [=[Automaticamente remover do diretório os perfis de personagens que você não encontrou por um certo tempo. Você pode escolher o tempo até a exclusão.

|cff00ff00Note que perfis com uma relação com um dos seus personagens jamais serão expurgados.

|cffff9900Há um bug no WoW que perde todos os dados salvos quando atinge um certo limite. Recomendamos evitar desativar o sistema de expurgo.]=],
	["CO_SANITIZER"] = "Limpar perfis recebidos",
	["CO_SANITIZER_TT"] = "Remover sequências em campos de telas de informações de perfis recebidos quando o TRP não os permitir (cores, imagens...)",
	["CO_TARGETFRAME"] = "Configurações do frame alvo",
	["CO_TARGETFRAME_ICON_SIZE"] = "Tamanho dos ícones",
	["CO_TARGETFRAME_USE"] = "Mostrar condições",
	["CO_TARGETFRAME_USE_1"] = "Sempre",
	["CO_TARGETFRAME_USE_2"] = "Apenas quando IC",
	["CO_TARGETFRAME_USE_3"] = "Nunca (desabilitado)",
	["CO_TARGETFRAME_USE_TT"] = "Determina em quais condições o frame alvo deve ser mostrado quando selecionado.",
	["CO_TOOLBAR"] = "Configurações de frame",
	["CO_TOOLBAR_CONTENT"] = "Configurações de barra de ferramentas",
	["CO_TOOLBAR_CONTENT_CAPE"] = "Alternar visualização de capa",
	["CO_TOOLBAR_CONTENT_HELMET"] = "Alternar visualização de elmo",
	["CO_TOOLBAR_CONTENT_RPSTATUS"] = "Status do personagem (IC/OOC)",
	["CO_TOOLBAR_CONTENT_STATUS"] = "Status do jogador (AFK/DND)",
	["CO_TOOLBAR_HIDE_TITLE"] = "Esconder título da barra de ferramentas ",
	["CO_TOOLBAR_HIDE_TITLE_HELP"] = "Esconde o Título em cima da barra de ferramentas ",
	["CO_TOOLBAR_ICON_SIZE"] = "Tamanho dos ícones",
	["CO_TOOLBAR_MAX"] = "Número máximo de ícones por linha",
	["CO_TOOLBAR_MAX_TT"] = "Use o valor 1 para mostrar a barra verticalmente!",
	["CO_TOOLBAR_SHOW_ON_LOGIN"] = "Exibir barra de ferramentas no login",
	["CO_TOOLBAR_SHOW_ON_LOGIN_HELP"] = "Se você não quer que a barra de ferramentas seja exibida no login, você pode desativar esta opção.",
	["CO_TOOLTIP"] = "Configurações de tooltip",
	["CO_TOOLTIP_ANCHOR"] = "Ponto âncora",
	["CO_TOOLTIP_ANCHORED"] = "Tela ancorada",
	["CO_TOOLTIP_CHARACTER"] = "Tooltip de personagens",
	["CO_TOOLTIP_CLIENT"] = "Mostrar cliente",
	["CO_TOOLTIP_COLOR"] = "Mostrar cores personalizadas",
	["CO_TOOLTIP_COMBAT"] = "Esconder durante combate",
	["CO_TOOLTIP_COMMON"] = "Configurações comuns",
	["CO_TOOLTIP_CONTRAST"] = "Aumentar o contraste de cor",
	["CO_TOOLTIP_CONTRAST_TT"] = "Ative esta opção para permitir que o Total RP 3 modifique as cores personalizadas para tornar o texto mais legível se a cor for muito escura.",
	["CO_TOOLTIP_CROP_TEXT"] = "Cortar textos excessivamente longos ",
	["CO_TOOLTIP_CROP_TEXT_TT"] = "Limite o número de caracteres que podem ser exibidos por cada campo na Tooltip para evitar textos excessivamente longos e possíveis problemas de exibição. |cfffff569Detalhes dos limites: Nome: 100 caracteres Título: 150 caracteres Raça: 50 caracteres Classe: 50 caracteres| ",
	["CO_TOOLTIP_CURRENT"] = "Mostrar informação \"atual\"",
	["CO_TOOLTIP_CURRENT_LINES"] = "Máxima \"Atuais\" quebras de linhas ",
	["CO_TOOLTIP_CURRENT_SIZE"] = "Tamanho da informação \"atual\"",
	["CO_TOOLTIP_FT"] = "Mostrar título completo",
	["CO_TOOLTIP_GUILD"] = "Mostrar informações da guilda",
	["CO_TOOLTIP_HEALTH"] = "Mostrar saúde ",
	["CO_TOOLTIP_HEALTH_BOTH"] = "Número + Porcentagem ",
	["CO_TOOLTIP_HEALTH_DISABLED"] = "Desativado ",
	["CO_TOOLTIP_HEALTH_NUMBER"] = "Número ",
	["CO_TOOLTIP_HEALTH_PERCENT"] = "Porcentagem ",
	["CO_TOOLTIP_HEALTH_TT"] = "Isto apenas mostrará caso o alvo não esteja com saúde cheia. ",
	["CO_TOOLTIP_HIDE_IN_INSTANCE"] = "Esconder quando estiver instanciado ",
	["CO_TOOLTIP_HIDE_ORIGINAL"] = "Esconder tooltip original",
	["CO_TOOLTIP_ICONS"] = "Mostrar ícones",
	["CO_TOOLTIP_IN_CHARACTER_ONLY"] = "Ocultar quando fora do personagem",
	["CO_TOOLTIP_MAINSIZE"] = "Tamanho da fonte principal",
	["CO_TOOLTIP_NO_FADE_OUT"] = "Ocultar imediatamente ao invés de esvanecer",
	["CO_TOOLTIP_NOTIF"] = "Mostrar notificações",
	["CO_TOOLTIP_NOTIF_TT"] = "A linha de notificações é a linha contendo a versão do client, o marcador de não lido e o marcador de \"À primeira vista\".",
	["CO_TOOLTIP_OWNER"] = "Mostrar dono",
	["CO_TOOLTIP_PETS"] = "Janela de informações de companheiros",
	["CO_TOOLTIP_PETS_INFO"] = "Mostrar informações de companheiros",
	["CO_TOOLTIP_PREFERRED_OOC_INDICATOR"] = "Indicador OOC preferido ",
	["CO_TOOLTIP_PREFERRED_OOC_INDICATOR_ICON"] = "ícone: ",
	["CO_TOOLTIP_PREFERRED_OOC_INDICATOR_TEXT"] = "Texto: ",
	["CO_TOOLTIP_PROFILE_ONLY"] = "Usar apenas se o alvo possuir um perfil",
	["CO_TOOLTIP_PRONOUNS"] = "Mostrar Pronomes ",
	["CO_TOOLTIP_RACE"] = "Mostrar raça, classe e nível",
	["CO_TOOLTIP_REALM"] = "Mostrar reino",
	["CO_TOOLTIP_RELATION"] = "Mostrar cor de relacionamento",
	["CO_TOOLTIP_RELATION_TT"] = "Ajustar a borda da tela de informações do personagem para a cor do relacionamento",
	["CO_TOOLTIP_SPACING"] = "Mostrar espaçamento",
	["CO_TOOLTIP_SPACING_TT"] = "Coloca espaços para deixar a tela de informações mais leve, no estilo do MyRoleplay",
	["CO_TOOLTIP_SUBSIZE"] = "Tamanho de fonte secundária",
	["CO_TOOLTIP_TARGET"] = "Mostrar alvo",
	["CO_TOOLTIP_TERSIZE"] = "Tamanho de fonte terciária",
	["CO_TOOLTIP_TITLE"] = "Mostrar título",
	["CO_TOOLTIP_USE"] = "Usar tela de informações de personagens/companheiros",
	["CO_TOOLTIP_ZONE"] = "Mostrar Área ",
	["CO_TOOLTIP_ZONE_TT"] = "Isto irá mostrar apenas se o alvo não estiver na mesma área que você. ",
	["CO_UI_RELOAD_WARNING"] = "A interface precisa ser recarregada para as mudanças serem aplicadas. Você gostaria de reiniciar a interface agora? ",
	["CO_WIM"] = "Canais de |cffff9900sussurro estão desativados.",
	["CO_WIM_TT"] = "Você está usando |cff00ff00WIM|r, a manipulação de canais de sussurro está desativada para fins de compatibilidade",
	["COM_LIST"] = "Lista de comandos:",
	["COM_RESET_RESET"] = "A posição das telas foi reiniciada!",
	["COM_RESET_USAGE"] = "Uso: |cff00ff00/trp3 reset frames|r para reiniciar todas as posições das telas.",
	["COM_STASH_DATA"] = [=[|cffff0000Tem certeza que quer depositar seus dados do Total RP 3? |r

Seus perfis, perfis de companheiro e configurações serão temporariamente depositados e sua interface irá se reiniciar sem dados, como numa instalação nova do Total RP 3.
|cff00ff00Use o mesmo comando novamente (|cff999999/trp3 stash|cff00ff00) para restaurar seus dados.|r]=],
	["COM_SWITCH_USAGE"] = "Uso: |cff00ff00/trp3 switch main|r para mudar para tela principal ou |cff00ff00/trp3 switch toolbar|r para mudar a barra de ferramentas.",
	["CONFIG_COMMS_QUEUE_POOL_COUNT"] = "Tamanho da fila de espera ",
	["CONFIG_COMMS_QUEUE_POOL_COUNT_DESCRIPTION"] = "Controla o tamanho da fila de espera utilizada para as comunicações de perfil.|n|n Valores mais baixos reduzirão a latência de comunicações adicionais para dados de perfil não-RP, mas podem aumentar o tempo antes de outros jogadores começarem a receber quaisquer dados de perfil em cenários de carga elevada. ",
	["CONFIG_COMMS_QUEUE_POOL_WEIGHT_THRESHOLD"] = "Limiar de peso dos dados da fila de espera ",
	["CONFIG_COMMS_QUEUE_POOL_WEIGHT_THRESHOLD_DESCRIPTION"] = "Controla o peso mínimo que os dados do seu perfil RP devem ter antes de se utilizarem as filas de espera.|n|nPara perfis maiores, o aumento deste valor pode |cffff0000severamente deteriorar| o desempenho de todos addons. ",
	["CONFIG_COMMS_SETTINGS_HEADER"] = "Configuração de comunicações ",
	["COPY_DROPDOWN_POPUP_TEXT"] = "copie com %1$s. cole com %2$s. Este frame irá fechar depois da cópia ",
	["COPY_SYSTEM_MESSAGE"] = "Copiado para área de Transferência.  ",
	["CREDITS_DISCORD_LINK_TEXT"] = "Junte-se ao nosso Discord ",
	["CREDITS_GUILD_NAME"] = "<%1$s>",
	["CREDITS_NAME_WITH_ROLE"] = "%1$s (%2$s)",
	["CREDITS_THANK_YOU_ROLE_1"] = "Líder do projeto ",
	["CREDITS_THANK_YOU_ROLE_2"] = "Autor",
	["CREDITS_THANK_YOU_ROLE_3"] = "Desenvolvedor",
	["CREDITS_THANK_YOU_ROLE_4"] = "Gerente da Comunidade",
	["CREDITS_THANK_YOU_ROLE_5"] = "Mascote",
	["CREDITS_THANK_YOU_SECTION_1"] = "{h1:c}Total RP 3{/h1}",
	["CREDITS_THANK_YOU_SECTION_10"] = "{col:ffffff}Agradecimentos a nossa comunidade ativa no Discord:{/col}",
	["CREDITS_THANK_YOU_SECTION_11"] = "{col:ffffff}Agradecimentos ao Bor Blasthammer por sua ajuda nos testes em Bfa.{/col}",
	["CREDITS_THANK_YOU_SECTION_2"] = "{h2}%1$s Criado por{/h2}",
	["CREDITS_THANK_YOU_SECTION_3"] = "{h2}%1$s Outros da equipe{/h2}",
	["CREDITS_THANK_YOU_SECTION_4"] = "{h2}%1$s Agradecimentos{/h2}",
	["CREDITS_THANK_YOU_SECTION_5"] = "{col:ffffff}Logo e ícone do botão do mini mapa:{/col} %1$s",
	["CREDITS_THANK_YOU_SECTION_6"] = "{col:ffffff}Nosso time pré-alpha de perguntas e respostas:{/col}",
	["CREDITS_THANK_YOU_SECTION_7"] = "{col:ffffff}Agradecimentos a todos nossos amigos por seus suportes todos esses anos:{/col}",
	["CREDITS_THANK_YOU_SECTION_8"] = "{col:ffffff}Por nos ajudar na criação  da guilda do Total RP no Kirin Tor (EU):{/col}",
	["CREDITS_THANK_YOU_SECTION_9"] = "{col:ffffff}agradecimentos a Horionne por nos enviar revistas Gamer Culte Online #14 com uma máteria sobre o Total RP.{/col}",
	["CREDITS_VERSION_TEXT"] = "Versão %s",
	["CREDITS_WEBSITE_LINK_TEXT"] = "Website",
	["DB_ABOUT"] = "Sobre o Total RP 3",
	["DB_HTML_GOTO"] = "Clique para abrir",
	["DB_MORE"] = "Mais módulos",
	["DB_NEW"] = "O que há de novo?",
	["DB_STATUS"] = "Estados",
	["DB_STATUS_CURRENTLY"] = "Atualmente (IC)",
	["DB_STATUS_CURRENTLY_COMMON"] = "Esses estados vão ser mostrados na tela de informações do seu personagem. Mantenha-os claros e breves uma vez que |cffff9900 por padrão usuários do TRP3 só verão os primeiros 140 caracteres!",
	["DB_STATUS_CURRENTLY_OOC"] = "Outras informações (OOC)",
	["DB_STATUS_CURRENTLY_OOC_TT"] = "Aqui você pode indicar algo importante sobre você, como um jogador, ou qualquer coisa fora do seu personagem.",
	["DB_STATUS_CURRENTLY_TT"] = "Aqui você pode indicar algo importante sobre seu personagem.",
	["DB_STATUS_ICON_ITEM"] = "%1$s %2$s",
	["DB_STATUS_LC"] = "Idioma do Roleplay ",
	["DB_STATUS_LC_DEFAULT"] = "Padrão (%1$s)",
	["DB_STATUS_LC_TT"] = "Define a sua linguagem de encenação preferida. Esta será partilhada com outros utilizadores de addon's de RP compatíveis. |cffff9900Note:|r Isto faz |cffffff0000não|r alterar o idioma da interface de utilizador do Total RP 3. Esta opção pode ser encontrada na página. |cfffff569Configurações Avançadas|r. ",
	["DB_STATUS_RP"] = "Estado do personagem",
	["DB_STATUS_RP_EXP"] = "Roleplayer experiente",
	["DB_STATUS_RP_EXP_TT"] = [=[Mostra que você é um roleplayer experiente.
Não mostrará nenhum ícone específico na sua tela de informações.]=],
	["DB_STATUS_RP_IC"] = "Interpretando",
	["DB_STATUS_RP_IC_TT"] = [=[Isso significa que você está atualmente interpretando seu personagem.
Todas as suas ações vão ser vistas como sendo o seu personagem a fazê-las.]=],
	["DB_STATUS_RP_OOC"] = "Não interpretando",
	["DB_STATUS_RP_OOC_TT"] = [=[Você não está interpretando seu personagem.
Suas ações não podem ser associadas a ele/ela.]=],
	["DB_STATUS_RP_VOLUNTEER"] = "Roleplayer voluntário",
	["DB_STATUS_RP_VOLUNTEER_TT"] = [=[Esta seleção mostrará um ícone na sua tela de informações, indicando
a roleplayers iniciantes que você está disposto a ajudá-los.]=],
	["DB_STATUS_XP"] = "Estado de roleplayer",
	["DB_STATUS_XP_BEGINNER"] = "Roleplayer novato",
	["DB_STATUS_XP_BEGINNER_TT"] = [=[Esta seleção mostrará um ícone na sua tela de informações, indicando
aos outros que você é um roleplayer iniciante.]=],
	["DB_TUTO_1"] = [=[|cffffff00O estado do personagem|r indica se você está atualmente interpretando seu personagem ou não.

|cffffff00O estado do roleplayer|r permite que você mostre que é um iniciante ou um veterano disposto a ajudar novatos.

|cff00ff00Essas informações serão exibidas na tela de informações do seu personagem.]=],
	["DICE_HELP"] = "Uma ou mais rolagens separadas por espaços, por exemplo: 1d6, 2d12 3d20...",
	["DICE_ROLL"] = "%s rolou |cffff9900%sx d%s|r|cffcc6600%s|r e tirou |cff00ff00%s|r. ",
	["DICE_ROLL_T"] = "%s %s rolou |cffff9900%sx d%s|r|cffcc6600%s|r e tirou |cff00ff00%s|r. ",
	["DICE_TOTAL"] = "%s total de |cff00ff00%s|r na rolagem.",
	["DICE_TOTAL_T"] = "%s %s tirou um total de |cff00ff00%s|r na rolagem.",
	["DTBK_AFK"] = "Total RP 3 - LDT/NI",
	["DTBK_CLOAK"] = "Total RP 3 - Capa",
	["DTBK_HELMET"] = "Total RP 3 - Elmo",
	["DTBK_LANGUAGES"] = "Total RP 3 - Linguagens",
	["DTBK_RP"] = "Total RP 3 - IC/OOC",
	["GEN_VERSION"] = "Versão: %s (Build %s)",
	["GEN_WELCOME_MESSAGE"] = "Obrigado por usar o Total RP 3 (v %s) ! Divirta-se !",
	["KUI_NAMEPLATES_MODULE_DESCRIPTION"] = "Ativa a customização de placas de nomes Kui.",
	["KUI_NAMEPLATES_MODULE_NAME"] = "Placas de nomes Kui",
	["KUI_NAMEPLATES_WARN_OUTDATED_MODULE"] = "Os plugins das |cff9966ffPlaquetas|r Kui para Total RP 3 foi integrado diretamente no addon principal.|n|n O antigo plugin foi desativado automaticamente, e |cffffcc00 recomendamos que o desinstale|r uma vez que já não é necessário. ",
	["LANG_CHANGE_CAUSED_REVERT_TO_DEFAULT"] = "A linguagem falada foi revertida ao padrão %s porque você não sabe a linguagem predefinida anteriormente %s.",
	["MAP_BUTTON_NO_SCAN"] = "Escaneamento não disponível",
	["MAP_BUTTON_SCANNING"] = "Escaneando",
	["MAP_BUTTON_SUBTITLE"] = "Clique para mostrar escaneamentos disponíveis",
	["MAP_BUTTON_SUBTITLE_80_DISABLED"] = "Scans temporariamente desativados por causa das mudanças no 8.0 ",
	["MAP_BUTTON_SUBTITLE_CONNECTING"] = "O escaneamento do mapa está sendo preparada. Espere por favor. ",
	["MAP_BUTTON_SUBTITLE_OFFLINE"] = "Escaneamento do mapa não está disponível no momento: %s ",
	["MAP_BUTTON_TITLE"] = "Escanear por roleplay ",
	["MAP_SCAN_CHAR"] = "Escanear por personagens",
	["MAP_SCAN_CHAR_TITLE"] = "Personagens",
	["MATURE_FILTER_ADD_TO_SAFELIST"] = "Add este perfil para o |cffffffffLista segura Adulta|r ",
	["MATURE_FILTER_ADD_TO_SAFELIST_OPTION"] = "add para o o |cffffffffLista segura Adulta|r ",
	["MATURE_FILTER_ADD_TO_SAFELIST_TEXT"] = "confirme que você quer add %s para o o |cffffffffLista segura Adulta|r. O conteúdo destes perfis não irá mais ser escondido. ",
	["MATURE_FILTER_ADD_TO_SAFELIST_TT"] = "Adicionar este perfil para a |cffffffffLista segura Adulta|r e revele o conteúdo adulto encontrado nele.",
	["MATURE_FILTER_ADD_TO_WHITELIST"] = "Adicionar este perfil à |cfffffffflista branca de conteúdo adulto|r",
	["MATURE_FILTER_ADD_TO_WHITELIST_OPTION"] = "Adicionar à |cfffffffflista branca de conteúdo adulto|r",
	["MATURE_FILTER_ADD_TO_WHITELIST_TEXT"] = [=[Confirme que você quer adicionar %s à |cfffffffflista branca de conteúdo adulto|r.

O conteúdo dos seus perfis não será mais ocultado.]=],
	["MATURE_FILTER_ADD_TO_WHITELIST_TT"] = "Adicionar este perfil à |cfffffffflista branca de conteúdo adulto|r e revelar o conteúdo adulto contido.",
	["MATURE_FILTER_EDIT_DICTIONARY"] = "Editar dicionário personalizado",
	["MATURE_FILTER_EDIT_DICTIONARY_ADD_BUTTON"] = "Adicionar",
	["MATURE_FILTER_EDIT_DICTIONARY_ADD_TEXT"] = "Adicionar uma nova palavra ao dicionário",
	["MATURE_FILTER_EDIT_DICTIONARY_BUTTON"] = "Editar",
	["MATURE_FILTER_EDIT_DICTIONARY_DELETE_WORD"] = "Suprimir a palavra do dicionário personalizado",
	["MATURE_FILTER_EDIT_DICTIONARY_EDIT_WORD"] = "Editar esta palavra",
	["MATURE_FILTER_EDIT_DICTIONARY_RESET_BUTTON"] = "Resetar ",
	["MATURE_FILTER_EDIT_DICTIONARY_RESET_TITLE"] = "Resetar dicionário ",
	["MATURE_FILTER_EDIT_DICTIONARY_RESET_WARNING"] = "Você tem certeza que quer resetar o dicionário atual? isto irá esvaziar  e preencher ele com palavras padrão providas pela sua atual linguagem ( Se estiver Disponível)",
	["MATURE_FILTER_EDIT_DICTIONARY_TITLE"] = "Editor dicionário personalizado",
	["MATURE_FILTER_EDIT_DICTIONARY_TT"] = "Editar o dicionário personalizado utilizado para filtrar perfis adultos.",
	["MATURE_FILTER_FLAG_PLAYER"] = "Sinalizar como adulto",
	["MATURE_FILTER_FLAG_PLAYER_OPTION"] = "Sinalizar como adulto",
	["MATURE_FILTER_FLAG_PLAYER_TEXT"] = [=[Confirme que quer sinalizar o perfil de %s como contendo conteúdo adulto. O conteúdo deste perfil será ocultado.

|cffffff00Opcional:|r Indique as palavras ofensivas que encontrar neste perfil (separadas por um espaço) para adicioná-las no filtro.]=],
	["MATURE_FILTER_FLAG_PLAYER_TT"] = "Sinalizar este perfil como contendo conteúdo adulto. O conteúdo do perfil será ocultado.",
	["MATURE_FILTER_OPTION"] = "Filtrar perfis adultos",
	["MATURE_FILTER_OPTION_TT"] = [=[Marque esta opção para ativar a filtragem de perfis adultos. O Total RP 3 irá analisar perfis recebidos por palavras-chave específicas que tenham sido sinalizadas como sendo direcionadas a um público adulto e irá marcar o perfil como adulto se encontrar tais palavras.

Um perfil adulto terá uma tela de informações simplificada e você terá que confirmar que quer visualizar o perfil na primeira vez que o abrir.]=],
	["MATURE_FILTER_REMOVE_FROM_SAFELIST"] = "Remover este perfil da |cffffffffLista segura Adulta|r ",
	["MATURE_FILTER_REMOVE_FROM_SAFELIST_OPTION"] = "Remover da |cffffffffLista segura Adulta|r",
	["MATURE_FILTER_REMOVE_FROM_SAFELIST_TEXT"] = "Confirme que você quer remover %s da |cffffffffLista segura Adulta|r. O conteúdo destes perfis irão ser escondidos novamente. ",
	["MATURE_FILTER_REMOVE_FROM_SAFELIST_TT"] = "Remover este perfil da |cffffffffLista segura Adulta|r e esconder novamente o conteúdo Adulto encontrado nele. ",
	["MATURE_FILTER_REMOVE_FROM_WHITELIST"] = "Remover este perfil da |cfffffffflista branca de conteúdo adulto|r",
	["MATURE_FILTER_REMOVE_FROM_WHITELIST_OPTION"] = "Remover da |cfffffffflista branca de conteúdo adulto|r",
	["MATURE_FILTER_REMOVE_FROM_WHITELIST_TEXT"] = [=[Confirme que quer remover %s da |cfffffffflista branca de conteúdo adulto|r.

O conteúdo dos seus perfis será ocultado novamente.]=],
	["MATURE_FILTER_REMOVE_FROM_WHITELIST_TT"] = "Remover este perfil da |cfffffffflista branca de conteúdo adulto|r e ocultar novamente o conteúdo adulto que o mesmo contém.",
	["MATURE_FILTER_STRENGTH"] = "Força do Filtro Adulto ",
	["MATURE_FILTER_STRENGTH_TT"] = "Marque a força do filtro de conteúdo adulto.  |cffcccccc1 é FRACO (10 palavrões são necessárias para marcar), 10 é FORTE ( somente 1 palavrão é necessário para marcar).|r ",
	["MATURE_FILTER_TITLE"] = "Filtro de perfis adultos",
	["MATURE_FILTER_TOOLTIP_WARNING"] = "Conteúdo adulto",
	["MATURE_FILTER_TOOLTIP_WARNING_SUBTEXT"] = "O perfil deste personagem contém conteúdo adulto. Use o botão na barra de alvo para revelar o conteúdo se quiser...",
	["MATURE_FILTER_WARNING_CONTINUE"] = "Continuar",
	["MATURE_FILTER_WARNING_GO_BACK"] = "Voltar",
	["MATURE_FILTER_WARNING_TEXT"] = [=[Você está com o sistema de filtro de conteúdo adulto do Total RP 3 ativado.

Este perfil foi sinalizado como contendo conteúdo adulto.

Tem certeza que quer visualizar este perfil?]=],
	["MATURE_FILTER_WARNING_TITLE"] = "Conteúdo adulto",
	["MM_SHOW_HIDE_MAIN"] = "Exibir/esconder a janela principal",
	["MM_SHOW_HIDE_MOVE"] = "Mover botão",
	["MM_SHOW_HIDE_SHORTCUT"] = "Exibir/esconder a barra de ferramentas",
	["MO_ADDON_NOT_INSTALLED"] = "O Addon %s não foi instalado. A integração customizada do Total RP3 foi desativada.",
	["MO_CHAT_CUSTOMIZATIONS_DESCRIPTION"] = "Adicione compatibilidade customizada para o Addon %s, Então as mensagens e nomes de jogadores serão modificadas pelo Total RP 3 naquele Addon. ",
	["MO_TOOLTIP_CUSTOMIZATIONS_DESCRIPTION"] = "Adicione customização  de compatibilidade para o Addon %s, então as preferências serão aplicadas para barra de ferramentas do Total RP 3",
	["MORE_MODULES_2"] = [=[{h2:c}Módulos opcionais{/h2}
{h3}Total RP 3: Extendido |cffF87431|r{/h3}
|cff9999ffTotal RP 3: Extendido|r adiciona a possibilidade de criar novo conteúdo no WoW: campanhas com missões e diálogos, itens, documentos (livros, placas, contratos...) e muito mais!
{link*https://www.curseforge.com/wow/addons/total-rp-3-extended*Faça download no CurseForge}

{h3}TRP3 Currently Frame{/h3}
Adds a standalone frame to your UI that displays your "Currently" text and allows you to edit it easily.
{link*https://www.curseforge.com/wow/addons/trp3-currently-frame*Faça download no CurseForge}

{h3}TRP3 Location Toggle{/h3}
Adds a simple button to the toolbar to toggle on and off the map scan location feature.
{link*https://www.curseforge.com/wow/addons/trp3-location-toggle*Faça download no CurseForge}]=],
	["NAMEPLATES_CONFIG_ACTIVE_QUERY"] = "Busca automática de perfis ",
	["NAMEPLATES_CONFIG_ACTIVE_QUERY_HELP"] = "Se marcado, procura automaticamente perfis de roleplay  com placas de nome anexadas.",
	["NAMEPLATES_CONFIG_BLIZZARD_NAME_ONLY"] = "Esconder barras em placas de nome da  |cff449fe0Blizzard|r ",
	["NAMEPLATES_CONFIG_BLIZZARD_NAME_ONLY_HELP"] = "Se Marcado, isto permite o uso do modo só de nome para as placas da  |cff449fe0Blizzard|r .|n|n|n Deste modo, todas as placas de nome terão as suas barras de saúde escondidas, incluindo os de personagens inimigos e outros jogadores com ou sem perfis de roleplay.|n|n Esta opção requer uma recarga UI para ter efeito.",
	["NAMEPLATES_CONFIG_CUSTOMIZE_FULL_TITLES"] = "Mostrar títulos Completos ",
	["NAMEPLATES_CONFIG_CUSTOMIZE_FULL_TITLES_HELP"] = "Se marcado mostrará o título inteiro das placas de nome da |n|nFor |cff449fe0Blizzard| e placas |cff9966ffKui|r, Títulos completos apenas serão mostrados no modo \"somente nome\".",
	["NAMEPLATES_CONFIG_CUSTOMIZE_HEALTH_COLORS"] = "Mostrar cores customizadas da saúde.",
	["NAMEPLATES_CONFIG_CUSTOMIZE_HEALTH_COLORS_HELP"] = "Se marcado Sobrepõe a cor das barras de saúde com a cor de classe do perfil. ",
	["NAMEPLATES_CONFIG_CUSTOMIZE_ICONS"] = "Mostrar ícones",
	["NAMEPLATES_CONFIG_CUSTOMIZE_ICONS_HELP"] = "Se marcado, mostra os ícones do perfil nas placas de nomes",
	["NAMEPLATES_CONFIG_CUSTOMIZE_NAME_COLORS"] = "Mostrar cores personalizadas de nome ",
	["NAMEPLATES_CONFIG_CUSTOMIZE_NAME_COLORS_HELP"] = "Se marcado, sobrepõe a cor do texto dos nomes com a cor de classe do perfil",
	["NAMEPLATES_CONFIG_CUSTOMIZE_NAMES"] = "Mostrar nomes customizados ",
	["NAMEPLATES_CONFIG_CUSTOMIZE_NAMES_HELP"] = "se marcado, substitui o nome mostrado nas placas de nome.",
	["NAMEPLATES_CONFIG_CUSTOMIZE_ROLEPLAY_STATUS"] = "Mostrar o indicador de status de roleplay",
	["NAMEPLATES_CONFIG_CUSTOMIZE_ROLEPLAY_STATUS_HELP"] = "Se marcado, mostra um indicador de status de roleplay (IC ou OOC) nas placas de nome ",
	["NAMEPLATES_CONFIG_CUSTOMIZE_TITLES"] = "Mostrar prefixo de títulos",
	["NAMEPLATES_CONFIG_CUSTOMIZE_TITLES_HELP"] = " Se marcado, Mostra o título curto em uma placa de nome antes de seu nome.",
	["NAMEPLATES_CONFIG_DISABLE_IN_COMBAT"] = "Desativar customização quando estiver em combate",
	["NAMEPLATES_CONFIG_DISABLE_IN_COMBAT_HELP"] = "Se marcado, desativa a customização das placas de nomes enquanto estiver em combate. ",
	["NAMEPLATES_CONFIG_DISABLE_OUT_OF_CHARACTER"] = [=[Desativar customizações enquanto estiver OOC (fora do personagem)
]=],
	["NAMEPLATES_CONFIG_DISABLE_OUT_OF_CHARACTER_HELP"] = "Se marcado desativa todas customizações nas placas de nome enquanto você estiver fora do personagem (OOC).",
	["NAMEPLATES_CONFIG_DISABLE_OUT_OF_CHARACTER_UNITS"] = "desative customizações nos personagens em OOC",
	["NAMEPLATES_CONFIG_DISABLE_OUT_OF_CHARACTER_UNITS_HELP"] = "Se marcado, desativa customizações nas placa de nomes em personagens que estão em OOC (fora do personagem).",
	["NAMEPLATES_CONFIG_ELEMENT_HEADER"] = "Configurações de customização.",
	["NAMEPLATES_CONFIG_ENABLE_CLASS_COLOR_FALLBACK"] = "Usar cor de classe por padrão",
	["NAMEPLATES_CONFIG_ENABLE_CLASS_COLOR_FALLBACK_HELP"] = "Se marcado, isto permite a utilização de cores de classe para os nomes e barras de saúde como uma alternativa para as unidades que não têm uma cor de classe personalizada em seu perfil.|n|npersonagens que não têm perfis de roleplay não são afetadas por esta configuração e não serão de cor de classe.",
	["NAMEPLATES_CONFIG_HIDE_NON_ROLEPLAY_UNITS"] = "Esconder personagens não roleplay.",
	["NAMEPLATES_CONFIG_HIDE_NON_ROLEPLAY_UNITS_HELP"] = "Se marcado. esconde placas de nome do jogador e companion que não tem perfis de roleplay",
	["NAMEPLATES_CONFIG_HIDE_OUT_OF_CHARACTER_UNITS"] = "Esconder personagens \"Fora do personagem\" (OOC)",
	["NAMEPLATES_CONFIG_HIDE_OUT_OF_CHARACTER_UNITS_HELP"] = "Se marcado, esconde as placas de nome de personagens que estão fora do personagem",
	["NAMEPLATES_CONFIG_ICON_SIZE"] = "Tamanho de ícone",
	["NAMEPLATES_CONFIG_ICON_SIZE_HELP"] = "Configura o tamanho dos ícones exibidos nas placas de nome se  a opção |cffffff00Mostrar ícones|r estiver ativo.",
	["NAMEPLATES_CONFIG_MENU_TITLE"] = "placa de nome",
	["NAMEPLATES_CONFIG_PAGE_HELP"] = "Por favor note que apenas as placas de nome da |cff449fe0Blizzard|r e |cff9966ffKui|r são atualmente suportadas. Consulte a dica de ajuda em cada configuração abaixo para informações adicionais.",
	["NAMEPLATES_CONFIG_PAGE_TEXT"] = "Configurações das placas de nome",
	["NAMEPLATES_CONFIG_VISIBILITY_HEADER"] = "Configurações de exibição",
	["NAMEPLATES_MODULE_ACTIVE_STATUS"] = "Módulo |cff00ff00Ativo|r (%1$s|r)",
	["NAMEPLATES_MODULE_DESCRIPTION"] = "Ativa a customização das placas de nome com informação obtida nos perfis de roleplay",
	["NAMEPLATES_MODULE_DISABLE_WARNING"] = "A desativação do módulo de placas de nome impedirá a realização de qualquer personalização de placas de nome. É necessário fazer a recarga da interface do jogador para que isto tenha efeito.|n|n|cffff0000Aviso: |r uma vez desativado, este módulo só pode ser reativado a partir da página |cffffcc00status do módulo|r.|n|n Tem certeza que quer desativar este módulo??",
	["NAMEPLATES_MODULE_DISABLED_BY_DEPENDENCY"] = "Este módulo foi desativado automaticamente devido a falta de alguma dependência.",
	["NAMEPLATES_MODULE_DISABLED_BY_EXTERNAL"] = "Este módulo foi desativado automaticamente devido a um conflito com outro módulo ou Addon!!",
	["NAMEPLATES_MODULE_INACTIVE_STATUS"] = "módulo |cffff9900Inativo|r (Addon não encontrado)",
	["NAMEPLATES_MODULE_NAME"] = "Placas de nome",
	["NEW_VERSION"] = [=[|cff00ff00Uma nova versão do Total RP 3 (v %s) está disponível.

|cffffff00Nós fortemente o(a) encorajamos a ficar atualizado(a).|r

Esta mensagem só vai aparecer uma vez por sessão e pode ser desativada nas opções
(Opções gerais => Diversos).]=],
	["NEW_VERSION_BEHIND"] = "Você está atualmente com a versão %s atrasada e te falta muitas correções de bugs e novas funcionalidades. Outros jogadores poderão não conseguir ver corretamente o seu perfil. Por favor, considere a atualização do addon.",
	["NEW_VERSION_TITLE"] = "Nova atualização disponível",
	["NPC_TALK_BUTTON_TT"] = "Abre a tela de fala de NPC, permitindo fazer falas ou emotes de NPC.",
	["NPC_TALK_CHANNEL"] = "Canal:",
	["NPC_TALK_COMMAND_HELP"] = "Abre a tela de fala de NPC.",
	["NPC_TALK_ERROR_EMPTY_MESSAGE"] = "A mensagem não pode estar vazia.",
	["NPC_TALK_MESSAGE"] = "Mensagem",
	["NPC_TALK_NAME"] = "Nome do NPC",
	["NPC_TALK_NAME_TT"] = [=[Você pode usar tags do chat como %t para inserir o nome do seu alvo ou %f para inserir o nome de quem estiver no seu foco.

Você também pode deixar este campo vazio para criar emotes sem um nome de NPC.]=],
	["NPC_TALK_SAY_PATTERN"] = "diz:",
	["NPC_TALK_SEND"] = "Enviar",
	["NPC_TALK_TITLE"] = "Falas de NPC",
	["NPC_TALK_WHISPER_PATTERN"] = "sussurra:",
	["NPC_TALK_YELL_PATTERN"] = "grita:",
	["OPTION_DISABLED_TOAST"] = "Opção desativada",
	["OPTION_ENABLED_TOAST"] = "Opção ativada",
	["PATTERN_ERROR"] = "Erro no padrão",
	["PATTERN_ERROR_TAG"] = "Erro no padrão : tag texto não fechada",
	["PR_CO_BATTLE"] = "Mascote de batalha",
	["PR_CO_COUNT"] = "%s mascotes/montarias vinculadas a este perfil.",
	["PR_CO_EMPTY"] = "Sem perfil de companheiro",
	["PR_CO_MASTERS"] = "Mestres",
	["PR_CO_MOUNT"] = "Montaria",
	["PR_CO_NEW_PROFILE"] = "Novo perfil de companheiro",
	["PR_CO_PET"] = "Mascote",
	["PR_CO_PROFILE_DETAIL"] = "Este perfil está atualmente vinculado a",
	["PR_CO_PROFILE_HELP"] = [=[Um perfil contém toda informação sobre uma |cffffff00"mascote"|r como um |cff00ff00personagem de roleplay|r.

Um perfil de companheiro pode ser conectado a:
- Uma mascote de batalha |cffff9900(apenas se houver sido renomeado)|r
- Um ajudante de caçador
- Um lacaio de bruxo
- Um elemental de mago
- Um carniçal de cavaleiro da morte |cffff9900(ver abaixo)|r

Assim como perfis de personagens, um |cff00ff00perfil de companheiro|r pode ser conectado a |cffffff00várias mascotes|r, e uma |cffffff00mascote|r pode trocar facilmente de um perfil para outro.

|cffff9900Carniçais:|r Como carniçais recebem um novo nome cada vez que são conjurados, você terá que reconectar o perfil ao carniçal para todos os nomes possíveis.]=],
	["PR_CO_PROFILE_HELP2"] = [=[Clique aqui para criar um novo perfil de companheiro.

|cff00ff00Para conectar um perfil a uma mascote (ajudante de caçador, lacaio de bruxo ...), simplesmente conjure a mascote, selecione-a e use a tela de seleção para conectá-la a um perfil existente (ou crie um novo).|r]=],
	["PR_CO_PROFILEMANAGER_DELETE_WARNING"] = [=[Você tem certeza que quer deletar o perfil de companheiro %s?
Esta ação não pode ser desfeita e toda informação do TRP3 conectada a este perfil será destruída!]=],
	["PR_CO_PROFILEMANAGER_DUPP_POPUP"] = [=[Por favor insira um nome para o novo perfil.
O nome não pode estar vazio.

Esta duplicação não mudará suas mascotes/montarias vinculadas a %s.]=],
	["PR_CO_PROFILEMANAGER_EDIT_POPUP"] = [=[Por favor insira um novo nome para este perfil.
O nome não pode estar vazio.

Mudar o nome não afetará qualquer conexão entre este perfil e suas mascotes/montarias.]=],
	["PR_CO_PROFILEMANAGER_TITLE"] = "Perfis de companheiros",
	["PR_CO_UNUSED_PROFILE"] = "Este perfil não está atualmente vinculado a nenhuma mascote ou montaria.",
	["PR_CO_WARNING_RENAME"] = [=[|cffff0000Aviso:|r é altamente recomendado que você renomeie sua mascote antes de conectá-la a um perfil.

Conectá-la assim mesmo?]=],
	["PR_CREATE_PROFILE"] = "Criar perfil",
	["PR_DEFAULT_PROFILE_NAME"] = "Perfil padrão",
	["PR_DEFAULT_PROFILE_WARNING"] = [=[Criar um novo perfil ou link para um que já existe nos perfis para editar as informações do 
 seu personagem.]=],
	["PR_DELETE_PROFILE"] = "Deletar perfil",
	["PR_DUPLICATE_PROFILE"] = "Duplicar perfil",
	["PR_EXPORT_IMPORT_HELP"] = [=[Você pode exportar e importar perfis usando as opções na lista de opções.

Use a opção |cffffff00Exportar perfil|r para gerar um de texto contendo os dados serializados do perfil. Você pode copiar o texto usando Control-C (ou Command-C em um Mac) e colar em outro lugar como cópia de segurança.
(|cffff0000Note que algumas ferramentas de edição de texto avançadas como Microsoft Word irão reformatar caracteres especiais como aspas, alterando os dados. Use ferramentas de edição de texto mais simples como o Bloco de Notas.|r)

Use a opção |cffffff00Importar perfil|r para colar dados de uma exportação passada em um perfil existente. Os dados existentes nesse perfil serão substituídos pelos que você colou. Você não pode importar dados diretamente no perfil atualmente selecionado.]=],
	["PR_EXPORT_IMPORT_TITLE"] = "Exportação/importação de perfil",
	["PR_EXPORT_NAME"] = "Código de série para o perfil %s (tamanho %0.2f kB)",
	["PR_EXPORT_PROFILE"] = "Exportação de perfil",
	["PR_EXPORT_TOO_LARGE"] = [=[Este perfil é muito grande e não pode ser exportado.

Tamanho do perfil: %0.2f kB
Máximo: 20 kB]=],
	["PR_EXPORT_WARNING_MAC"] = "Note por favor que algumas ferramentas avançadas de edição de texto como Text Edit ou Discord reformatarão caracteres especiais como citações, alterando o conteúdo dos dados. Se estiver planejando copiar o texto abaixo dentro de um documento, utilize ferramentas de edição de texto mais simples que não alterem automaticamente os caracteres (em Text Edit vá para Format > Fazer texto simples antes de colar).",
	["PR_EXPORT_WARNING_TITLE"] = "Aviso!! :",
	["PR_EXPORT_WARNING_WINDOWS"] = "Note que algumas ferramentas avançadas de edição de texto como o Microsoft Word ou Discord reformatarão caracteres especiais como citações, alterando o conteúdo dos dados. Se estiver planejando copiar o texto abaixo dentro de um documento, utilize por favor ferramentas de edição de texto mais simples que não alterem automaticamente os caracteres, como o Bloco de Notas.",
	["PR_IMPORT"] = "Importar",
	["PR_IMPORT_CHAR_TAB"] = "Importador de personagens",
	["PR_IMPORT_EMPTY"] = "Nenhum perfil importável",
	["PR_IMPORT_IMPORT_ALL"] = "Importar todos",
	["PR_IMPORT_PETS_TAB"] = "Importador de companions",
	["PR_IMPORT_PROFILE"] = "Importaçao de perfil",
	["PR_IMPORT_PROFILE_TT"] = "Cole aqui o código de série de um perfil",
	["PR_IMPORT_WILL_BE_IMPORTED"] = "Serão importados",
	["PR_PROFILE"] = "Perfil",
	["PR_PROFILE_CREATED"] = "Perfil %s criado.",
	["PR_PROFILE_DELETED"] = "Perfil %s deletado.",
	["PR_PROFILE_DETAIL"] = "Este perfil está atualmente vinculado a estes personagens do WoW.",
	["PR_PROFILE_HELP"] = [=[Um perfil contém toda informação sobre um |cffffff00"personagem"|r como um |cff00ff00personagem de roleplay|r.

Um |cffffff00"personagem do WoW"|r real pode ser vinculado a apenas um perfil de cada vez, mas pode trocar de um para outro quando quiser.

Você também pode vincular vários |cffffff00"personagens do WoW"|r ao mesmo |cff00ff00perfil|r !]=],
	["PR_PROFILE_LOADED"] = "O perfil %s está carregado.",
	["PR_PROFILE_MANAGEMENT_TITLE"] = "Gerenciamento de perfil",
	["PR_PROFILEMANAGER_ACTIONS"] = "Ações",
	["PR_PROFILEMANAGER_ALREADY_IN_USE"] = "O nome de perfil %s não está disponível.",
	["PR_PROFILEMANAGER_COUNT"] = "%s personagem(s) do WoW vinculados a este perfil.",
	["PR_PROFILEMANAGER_CREATE_POPUP"] = [=[Por favor insira um nome para o novo perfil.
O nome não pode estar vazio.]=],
	["PR_PROFILEMANAGER_CURRENT"] = "Perfil atual",
	["PR_PROFILEMANAGER_DELETE_WARNING"] = [=[Você tem certeza que quer deletar o perfil %s?
Esta ação não pode ser desfeita e toda informação do TRP3 conectada a este perfil (Informações de personagem, inventário, diário de missões, estados aplicados ...) será destruída !]=],
	["PR_PROFILEMANAGER_DUPP_POPUP"] = [=[Por favor insira um nome para o novo perfil.
O nome não pode estar vazio.

Esta duplicação não mudará a conexão ao personagem %s.]=],
	["PR_PROFILEMANAGER_EDIT_POPUP"] = [=[Por favor insira um novo nome para este perfil %s.
Este nome não pode estar vazio.

Mudar o nome não vai mudar nenhuma conexão entre este perfil e seus personagens.]=],
	["PR_PROFILEMANAGER_EMPTY"] = "Nenhum perfil encontrado",
	["PR_PROFILEMANAGER_IMPORT_WARNING"] = "Substituir todo o conteúdo do perfil %s por estes dados importados?",
	["PR_PROFILEMANAGER_IMPORT_WARNING_2"] = [=[Aviso: este código de série de perfil foi feito em uma versão antiga do TRP3.
Isso pode causar incompatibilidades.

Substituir todo o conteúdo do perfil %s por estes dados importados?]=],
	["PR_PROFILEMANAGER_RENAME"] = "Renomear perfil",
	["PR_PROFILEMANAGER_SEARCH_PROFILE"] = "Procurar perfil",
	["PR_PROFILEMANAGER_SWITCH"] = "Selecionar perfil",
	["PR_PROFILEMANAGER_TITLE"] = "Perfis de personagens",
	["PR_PROFILES"] = "Perfis",
	["PR_SLASH_EXAMPLE"] = "|cffffff00Uso do comando:|r |cffcccccc/trp3 profile Millidan Foamrage|r |cffffff00para ativar o perfil de Millidan Foamrage.|r",
	["PR_SLASH_NOT_FOUND"] = "|cffff0000Não foi encontrado nenhum perfil chamado|r |cffffff00%s|r|cffff0000.|r",
	["PR_SLASH_OPEN_ABORTING"] = "|cffffff00requisição de perfil cancelado.|r",
	["PR_SLASH_OPEN_EXAMPLE"] = "|cffffff00Utilização de comando:|r |cffcccccc/Abrir TRP3|r |cffffff00para abrir o perfil dos eu alvo ou |cffcccccc/trp3 Abrir nome do Personagem/Nome do Reino|r |cffffff00Para abrir o perfil daquele Personagem.|r ",
	["PR_SLASH_OPEN_HELP"] = "Abrir um perfil de personagem usando o nome dele dentro do jogo, ou o perfil do seu alvo se o nome dele não for fornecido.",
	["PR_SLASH_OPEN_WAITING"] = "|cffffff00Requisitando perfil, Espere por favor...|r",
	["PR_SLASH_SWITCH_HELP"] = "Trocar para outro perfil usando seu nome.",
	["PR_UNUSED_PROFILE"] = "Este perfil não está atualmente conectado a nenhum personagem do WoW.",
	["REG_CODE_INSERTION_WARNING"] = "|Typolicegar.tga:50:50|t Espere um minuto! Descobrimos que você inseriu manualmente códigos inválidos dentro do seu perfil do Total RP 3. Este comportamento não é de todo apoiado e desencorajamos fortemente qualquer pessoa fazer. Pode levar a instabilidades e bugs dentro do addon, corrupção/perda de dados de perfis e também cria problemas de incompatibilidade com outros addons (tais como MRP). Os códigos que inseriu no seu perfil foram removidos para o impedir o addon de parar de funcionar.",
	["REG_COMPANION"] = "Companheiro",
	["REG_COMPANION_BIND_TO_PET"] = "Mascote",
	["REG_COMPANION_BOUND_TO"] = "Vinculado a ...",
	["REG_COMPANION_BOUND_TO_TARGET"] = "Alvo",
	["REG_COMPANION_BOUNDS"] = "Vínculos",
	["REG_COMPANION_BROWSER_BATTLE"] = "Navegador de mascote de batalha",
	["REG_COMPANION_BROWSER_MOUNT"] = "Navegador de montarias",
	["REG_COMPANION_INFO"] = "Informação",
	["REG_COMPANION_LINKED"] = "O(a) companheiro(a) %s está agora conectado(a) ao perfil %s.",
	["REG_COMPANION_LINKED_NO"] = "O(a) companheiro(a) %s não está mais conectado(a) a nenhum perfil.",
	["REG_COMPANION_NAME"] = "Nome",
	["REG_COMPANION_NAME_COLOR"] = "Cor do nome",
	["REG_COMPANION_PAGE_TUTO_C_1"] = "Consultar",
	["REG_COMPANION_PAGE_TUTO_E_1"] = [=[Esta é a |cff00ff00informação principal do seu companheiro|r.

Toda essa informação vai aparecer na |cffff9900tela de informações do seu companheiro|r.]=],
	["REG_COMPANION_PAGE_TUTO_E_2"] = [=[Esta é a |cff00ff00descrição do seu companheiro|r.

Ela não é limitada a uma |cffff9900descrição física|r. Sinta-se livre para indicar partes da sua |cffff9900história|r ou detalhes sobre sua |cffff9900personalidade|r.

Há muitas maneiras de personalizar a descrição.
Você pode escolher uma |cffffff00textura de fundo|r para a descrição. Você também pode usar as ferramentas de formatação para acessar vários parâmetros de layout como |cffffff00tamanhos, cores e alinhamentos de texto|r.
Estas ferramentas também permitem que você insira |cffffff00imagens, ícones ou links para websites externos|r.]=],
	["REG_COMPANION_PROFILES"] = "Perfis de companheiros",
	["REG_COMPANION_TARGET_NO"] = "Seu alvo não é um ajudante, lacaio, carniçal, elemental de mago ou mascote de batalha renomeado válido.",
	["REG_COMPANION_TF_BOUND_TO"] = "Selecione um perfil",
	["REG_COMPANION_TF_CREATE"] = "Criar novo perfil",
	["REG_COMPANION_TF_NO"] = "Sem perfil",
	["REG_COMPANION_TF_OPEN"] = "Abrir página",
	["REG_COMPANION_TF_OWNER"] = "Dono: %s",
	["REG_COMPANION_TF_PROFILE"] = "Perfil de companheiro",
	["REG_COMPANION_TF_PROFILE_MOUNT"] = "Perfil de montaria",
	["REG_COMPANION_TF_UNBOUND"] = "Desconectar de perfil",
	["REG_COMPANION_TITLE"] = "Título",
	["REG_COMPANION_UNBOUND"] = "Desvincular de ...",
	["REG_COMPANIONS"] = "Companheiros",
	["REG_DELETE_WARNING"] = "Você tem certeza que quer deletar o perfil de %s?",
	["REG_IGNORE_TOAST"] = "Personagem ignorado",
	["REG_LIST_ACTIONS_MASS"] = "Ação nos %s perfis selecionados",
	["REG_LIST_ACTIONS_MASS_IGNORE"] = "Ignorar perfis",
	["REG_LIST_ACTIONS_MASS_IGNORE_C"] = [=[Esta ação irá adicionar |cff00ff00%s personagem(s)|r à lista de ignorados.

Você pode opcionalmente inserir o motivo abaixo. Essa é uma nota pessoal, que servirá como um lembrete.]=],
	["REG_LIST_ACTIONS_MASS_REMOVE"] = "Remover perfis",
	["REG_LIST_ACTIONS_MASS_REMOVE_C"] = "Esta ação removerá |cff00ff00%s perfis selecionados|r.",
	["REG_LIST_ACTIONS_PURGE"] = "Expurgar registro",
	["REG_LIST_ACTIONS_PURGE_ALL"] = "Remover todos os perfis",
	["REG_LIST_ACTIONS_PURGE_ALL_C"] = [=[Este expurgo irá remover todos os perfis e personagens conectados do diretório.

|cff00ff00%s personagens.]=],
	["REG_LIST_ACTIONS_PURGE_ALL_COMP_C"] = [=[Este expurgo irá remover todos os companheiros do diretório.

|cff00ff00%s companheiros.]=],
	["REG_LIST_ACTIONS_PURGE_COUNT"] = "%s perfis serão removidos.",
	["REG_LIST_ACTIONS_PURGE_EMPTY"] = "Sem perfis para expurgar.",
	["REG_LIST_ACTIONS_PURGE_IGNORE"] = "Perfis de personagens ignorados.",
	["REG_LIST_ACTIONS_PURGE_IGNORE_C"] = [=[Este expurgo irá remover todos os perfis conectados a um personagem do WoW ignorado.

|cff00ff00%s]=],
	["REG_LIST_ACTIONS_PURGE_TIME"] = "Perfis não vistos por 1 mês",
	["REG_LIST_ACTIONS_PURGE_TIME_C"] = [=[Este expurgo irá remover todos os perfis que não foram vistos por um mês.

|cff00ff00%s]=],
	["REG_LIST_ACTIONS_PURGE_UNLINKED"] = "Perfis não vinculados a um personagem",
	["REG_LIST_ACTIONS_PURGE_UNLINKED_C"] = [=[Este expurgo irá remover todos os perfis que não estão conectados a um personagem do WoW.

|cff00ff00%s]=],
	["REG_LIST_ADDON"] = "Tipo de perfil",
	["REG_LIST_CHAR_EMPTY"] = "Sem personagem",
	["REG_LIST_CHAR_EMPTY2"] = "Nenhum personagem se encaixa na sua seleção",
	["REG_LIST_CHAR_FILTER"] = "Personagens: %s / %s",
	["REG_LIST_CHAR_IGNORED"] = "Ignorado",
	["REG_LIST_CHAR_NAME_COPY"] = "Copiar nome do personagem",
	["REG_LIST_CHAR_SEL"] = "Personagem selecionado",
	["REG_LIST_CHAR_TITLE"] = "Lista de personagens",
	["REG_LIST_CHAR_TT"] = "Clique para mostrar página",
	["REG_LIST_CHAR_TT_CHAR"] = "Personagens do WoW vinculados:",
	["REG_LIST_CHAR_TT_CHAR_NO"] = "Não vinculado a nenhum personagem",
	["REG_LIST_CHAR_TT_DATE"] = [=[Data visto pela última vez: |cff00ff00%s|r
Local visto pela última vez: |cff00ff00%s|r]=],
	["REG_LIST_CHAR_TT_GLANCE"] = "À primeira vista",
	["REG_LIST_CHAR_TT_IGNORE"] = "Personagens ignorados",
	["REG_LIST_CHAR_TT_NEW_ABOUT"] = "Descrição não lida",
	["REG_LIST_CHAR_TT_RELATION"] = [=[Relação:
|cff00ff00%s]=],
	["REG_LIST_CHAR_TUTO_ACTIONS"] = "Esta coluna permite que você selecione múltiplos personagens e faça uma ação em todos eles.",
	["REG_LIST_CHAR_TUTO_FILTER"] = [=[Você pode filtrar a lista de personagens.

O |cff00ff00filtro de nome|r irá realizar uma busca nos nomes completos dos perfis (nome + sobrenome) mas também em quaisquer personagens do WoW vinculados.

O |cff00ff00filtro de guilda|r irá buscar por nomes de guilda em personagens do WoW vinculados.

O |cff00ff00filtro de apenas no reino|r mostrará apenas perfis vinculados a um personagem do WoW no seu reino atual.]=],
	["REG_LIST_CHAR_TUTO_LIST"] = [=[A primeira coluna mostra o nome do personagem.

A segunda coluna mostra a relação entre estes personagens e seu personagem atual.

A última coluna é para vários marcadores. (ignorado ..etc.)]=],
	["REG_LIST_FILTERS"] = "Filtros",
	["REG_LIST_FILTERS_TT"] = [=[|cffffff00Clique:|r Aplicar filtros
|cffffff00Clique direito:|r Limpar filtros]=],
	["REG_LIST_FLAGS"] = "Marcadores",
	["REG_LIST_GUILD"] = "Guilda do personagem",
	["REG_LIST_IGNORE_EMPTY"] = "Sem personagens ignorados",
	["REG_LIST_IGNORE_TITLE"] = "Lista de ignorados",
	["REG_LIST_IGNORE_TT"] = [=[Motivo:
|cff00ff00%s

|cffffff00Clique para remover da lista de ignorados]=],
	["REG_LIST_NAME"] = "Nome do personagem",
	["REG_LIST_NOTESONLY"] = "Tem somente anotações",
	["REG_LIST_NOTIF_ADD"] = "Novo perfil descoberto para |cff00ff00%s",
	["REG_LIST_NOTIF_ADD_CONFIG"] = "Novo perfil descoberto",
	["REG_LIST_NOTIF_ADD_NOT"] = "Este perfil não existe mais.",
	["REG_LIST_PET_MASTER"] = "Nome do mestre",
	["REG_LIST_PET_NAME"] = "Nome do companheiro",
	["REG_LIST_PET_TYPE"] = "Tipo do companheiro",
	["REG_LIST_PETS_EMPTY"] = "Sem companheiro",
	["REG_LIST_PETS_EMPTY2"] = "Nenhum companheiro se encaixa na sua seleção",
	["REG_LIST_PETS_FILTER"] = "Companheiros: %s / %s",
	["REG_LIST_PETS_TITLE"] = "Lista de companheiros",
	["REG_LIST_PETS_TOOLTIP"] = "Foi visto em",
	["REG_LIST_PETS_TOOLTIP2"] = "Foi visto com",
	["REG_LIST_REALMONLY"] = "Apenas neste reino",
	["REG_LOCATION_DIFFERENT_WAR_MODE"] = "Modo de guerra diferente",
	["REG_MSP_ALERT"] = [=[|cffff0000AVISO

Você não pode ter simultaneamente mais de um addon usando o Protocolo Mary Sue, pois entrariam em conflito.|r

Atualmente carregado: |cff00ff00%s

|cffff9900Logo o suporte a PMS para o Total RP3 será desativado.|r

Se você não quer que TRP3 seja seu addon de PMS e não quer mais ver este alerta, você pode desativar o módulo de Protocolo Mary Sue nas Opções do TRP3 -> Status de módulo.]=],
	["REG_NOTES_PROFILE"] = "Anotações",
	["REG_NOTES_PROFILE_TT"] = "Abra a janela de anotações para o personagem alvo.",
	["REG_PLAYER"] = "Personagem",
	["REG_PLAYER_ABOUT"] = "Sobre",
	["REG_PLAYER_ABOUT_ADD_FRAME"] = "Adicionar uma janela",
	["REG_PLAYER_ABOUT_EMPTY"] = "Sem descrição",
	["REG_PLAYER_ABOUT_HEADER"] = "Nota título",
	["REG_PLAYER_ABOUT_MUSIC"] = "Tema do personagem",
	["REG_PLAYER_ABOUT_MUSIC_LISTEN"] = "Tocar tema",
	["REG_PLAYER_ABOUT_MUSIC_REMOVE"] = "De-selecionar tema",
	["REG_PLAYER_ABOUT_MUSIC_SELECT"] = "Selecionar tema do personagem",
	["REG_PLAYER_ABOUT_MUSIC_SELECT2"] = "Selecionar tema",
	["REG_PLAYER_ABOUT_MUSIC_STOP"] = "Parar tema",
	["REG_PLAYER_ABOUT_MUSIC_THEME"] = "Música tema do personagem",
	["REG_PLAYER_ABOUT_NOMUSIC"] = "|cffff9900Sem tema",
	["REG_PLAYER_ABOUT_P"] = "Marcação de parágrafo",
	["REG_PLAYER_ABOUT_REMOVE_FRAME"] = "Remover esta janela",
	["REG_PLAYER_ABOUT_SOME"] = "Algum texto ...",
	["REG_PLAYER_ABOUT_T1_YOURTEXT"] = "Seu texto aqui",
	["REG_PLAYER_ABOUT_TAGS"] = "Ferramentas de formatação",
	["REG_PLAYER_ABOUT_UNMUSIC"] = "|cffff9900Tema desconhecido",
	["REG_PLAYER_ABOUT_VOTE_DOWN"] = "Eu não gosto deste conteúdo",
	["REG_PLAYER_ABOUT_VOTE_NO"] = [=[Nenhum personagem conectado a este perfil parece estar online.
Você quer forçar o Total RP 3 a enviar seu voto assim mesmo ?]=],
	["REG_PLAYER_ABOUT_VOTE_SENDING"] = "Enviando seu voto a %s ...",
	["REG_PLAYER_ABOUT_VOTE_SENDING_OK"] = "Seu voto foi enviado a %s !",
	["REG_PLAYER_ABOUT_VOTE_TT"] = "Seu voto é totalmente anônimo e só pode ser visto por este jogador.",
	["REG_PLAYER_ABOUT_VOTE_TT2"] = "Você só pode votar se o jogador estiver online.",
	["REG_PLAYER_ABOUT_VOTE_UP"] = "Eu gosto deste conteúdo.",
	["REG_PLAYER_ABOUT_VOTES"] = "Estatísticas",
	["REG_PLAYER_ABOUT_VOTES_R"] = [=[|cff00ff00%s curtir este conteúdo
|cffff0000%s descurtir este conteúdo]=],
	["REG_PLAYER_ABOUTS"] = "Sobre %s",
	["REG_PLAYER_ADD_NEW"] = "Criar novo",
	["REG_PLAYER_AGE"] = "Idade",
	["REG_PLAYER_AGE_TT"] = [=[Aqui você pode indicar quão velho seu personagem é.

Há várias formas de fazer isso:|c0000ff00
- Ou usar anos
- Ou um adjetivo (Jovem, Maduro, Adulto, Venerável, etc.)]=],
	["REG_PLAYER_ALERT_HEAVY_SMALL"] = [=[|cffff0000O tamanho total do seu perfil é bem grande.
|cffff9900Você devia reduzi-lo.]=],
	["REG_PLAYER_BIRTHPLACE"] = "Local de nascimento",
	["REG_PLAYER_BIRTHPLACE_TT"] = [=[Aqui você pode indicar o local de nascimento do seu personagem. Isso pode ser uma região, uma zona ou até mesmo um continente. Você decide o quão preciso quer ser.

|c00ffff00Você pode usar o botão à direita para facilmente colocar sua localidade atual como local de nascimento.]=],
	["REG_PLAYER_BKG"] = "Layout de fundo",
	["REG_PLAYER_BKG_TT"] = "Isso representa o fundo gráfico para usar para seu layout de Características.",
	["REG_PLAYER_CARACT"] = "Características",
	["REG_PLAYER_CHANGE_CONFIRM"] = [=[Você pode ter mudanças não-salvas.
Você quer mudar de página assim mesmo ?
|cffff9900Todas as mudanças serão perdidas.]=],
	["REG_PLAYER_CHARACTERISTICS"] = "Características",
	["REG_PLAYER_CLASS"] = "Classe",
	["REG_PLAYER_CLASS_TT"] = [=[Esta é a classe personalizada do seu personagem.

|cff00ff00Por exemplo :|r
Cavaleiro, Pirotecnista, Necromante, Atirador de elite, Arcanista ...]=],
	["REG_PLAYER_COLOR_ALWAYS_DEFAULT_TT"] = "|cffffff00Clique:|r Selecionar uma cor |cffffff00Botão direito:|r Descartar a cor",
	["REG_PLAYER_COLOR_CLASS"] = "Cor da classe",
	["REG_PLAYER_COLOR_CLASS_TT"] = [=[Isso também determina a cor do nome.

]=],
	["REG_PLAYER_COLOR_TT"] = [=[|cffffff00Clique:|r Selecionar uma cor
|cffffff00Clique-direito:|r Descartar cor]=],
	["REG_PLAYER_CURRENT"] = "Atualmente",
	["REG_COMPANIONS_SHORTDESCRIPTION"]= "Breve descrição",
	["REG_PLAYER_CURRENT_OOC"] = "Esta é uma informação OOC",
	["REG_PLAYER_CURRENTOOC"] = "Atualmente (OOC)",
	["REG_PLAYER_EDIT_MUSIC_THEME"] = "Música tema",
	["REG_PLAYER_EYE"] = "Cor dos olhos",
	["REG_PLAYER_EYE_TT"] = [=[Aqui você pode indicar a cor dos olhos do seu personagem.

Pense que, mesmo que o rosto do seu personagem esteja sempre escondido, vale a pena mencionar, só por garantia.]=],
	["REG_PLAYER_FIRSTNAME"] = "Nome",
	["REG_PLAYER_FIRSTNAME_TT"] = [=[Este é o nome do seu personagem. Este é um campo obrigatório, então se você não especificar um nome, o nome padrão do personagem (|cffffff00%s|r)  será utilizado.

Você pode usar um |c0000ff00apelido |r!]=],
	["REG_PLAYER_FULLTITLE"] = "Título completo",
	["REG_PLAYER_FULLTITLE_TT"] = [=[Aqui você pode escrever o título completo do seu personagem. Ele pode ser uma versão maior do Título ou um título completamente diferente.

Porém, você pode querer evitar repetições, no caso de não haver informação adicional para mencionar.]=],
	["REG_PLAYER_GLANCE"] = "À primeira vista",
	["REG_PLAYER_GLANCE_BAR_DELETED"] = "Preset de grupo |cffff9900%s|r deletado.",
	["REG_PLAYER_GLANCE_BAR_EMPTY"] = "O nome da predefinição não pode estar vazio.",
	["REG_PLAYER_GLANCE_BAR_LOAD"] = "Predefinição de grupo",
	["REG_PLAYER_GLANCE_BAR_LOAD_SAVE"] = "Predefinições de grupo",
	["REG_PLAYER_GLANCE_BAR_NAME"] = [=[Insira o nome da predefinição.

|cff00ff00Nota: Se o nome já estiver em uso por outra predefinição de grupo, este outro grupo será substituído.]=],
	["REG_PLAYER_GLANCE_BAR_SAVE"] = "Salvar grupo como predefinição",
	["REG_PLAYER_GLANCE_BAR_SAVED"] = "Predefinição de grupo |cff00ff00%s|r foi criada.",
	["REG_PLAYER_GLANCE_BAR_TARGET"] = "Predefinições de \"À primeira vista\"",
	["REG_PLAYER_GLANCE_CONFIG"] = [=[|cff00ff00"À primeira vista"|r é um conjunto de slots que você pode usar para definir informações importantes sobre este personagem.

Você pode usar estas ações nos slots:
|cffffff00Clique:|r configurar slot
|cffffff00Duplo-clique:|r alternar ativação do slot
|cffffff00Clique-direito:|r presets de slot
|cffffff00Arrastar e soltar:|r reordenar slots]=],
	["REG_PLAYER_GLANCE_EDITOR"] = "Editor de vista: Slot %s",
	["REG_PLAYER_GLANCE_MENU_COPY"] = "Copiar slot",
	["REG_PLAYER_GLANCE_MENU_PASTE"] = "colar slot: %s",
	["REG_PLAYER_GLANCE_PRESET"] = "Carregar uma predefinição",
	["REG_PLAYER_GLANCE_PRESET_ADD"] = "Criada predefinição |cff00ff00%s|r.",
	["REG_PLAYER_GLANCE_PRESET_ALERT1"] = "Você deve inserir uma categoria de predefinição.",
	["REG_PLAYER_GLANCE_PRESET_CATEGORY"] = "Categoria de predefinição",
	["REG_PLAYER_GLANCE_PRESET_CREATE"] = "Criar predefinição",
	["REG_PLAYER_GLANCE_PRESET_GET_CAT"] = [=[%s

Por favor insira o nome da categoria para essa predefinição.]=],
	["REG_PLAYER_GLANCE_PRESET_NAME"] = "Nome da predefinição",
	["REG_PLAYER_GLANCE_PRESET_REMOVE"] = "Removida predefinição |cff00ff00%s|r.",
	["REG_PLAYER_GLANCE_PRESET_SAVE"] = "Salvar informação como predefinição",
	["REG_PLAYER_GLANCE_PRESET_SAVE_SMALL"] = "Salvar como predefinição",
	["REG_PLAYER_GLANCE_PRESET_SELECT"] = "Selecionar uma predefinição",
	["REG_PLAYER_GLANCE_TITLE"] = "Atribuir nome",
	["REG_PLAYER_GLANCE_UNUSED"] = "Slot não-utilizado",
	["REG_PLAYER_GLANCE_USE"] = "Ativar este slot",
	["REG_PLAYER_HEIGHT"] = "Altura",
	["REG_PLAYER_HEIGHT_TT"] = [=[Esta é a altura do seu personagem.
Há várias maneiras de mostrar isso:|c0000ff00
- Um número preciso: 170 cm, 6'5" ...
- Um qualificativo: Alto, baixo ...]=],
	["REG_PLAYER_HERE"] = "Designar posição",
	["REG_PLAYER_HERE_HOME_PRE_TT"] = [=[Coordenadas do mapa de moradia atuais:
|cff00ff00%s|r.]=],
	["REG_PLAYER_HERE_HOME_TT"] = [=[|cffffff00Clique|r: Usar as coordenadas atuais como a posição de moradia.
|cffffff00Clique-direito|r: Descartar sua posição de moradia.]=],
	["REG_PLAYER_HERE_TT"] = "|cffffff00Clique|r: Designar para sua posição atual",
	["REG_PLAYER_HISTORY"] = "História",
	["REG_PLAYER_ICON"] = "Ícone do personagem",
	["REG_PLAYER_ICON_TT"] = "Selecione uma representação gráfica para seu personagem.",
	["REG_PLAYER_IGNORE"] = "Ignorar personagens conectados (%s)",
	["REG_PLAYER_IGNORE_WARNING"] = [=[Você quer ignorar estes personagens ?

|cffff9900%s

|rVocê pode inserir o motivo abaixo. Isto é uma nota pessoal e servirá como lembrete.]=],
	["REG_PLAYER_LASTNAME"] = "Sobrenome",
	["REG_PLAYER_LASTNAME_TT"] = "Este é o nome de família do seu personagem.",
	["REG_PLAYER_LEFTTRAIT"] = "Atributo da esquerda",
	["REG_PLAYER_MISC_ADD"] = "Adicionar um campo adicional",
	["REG_PLAYER_MISC_PRESET_PRONOUNS"] = "Pronomes",
	["REG_PLAYER_MORE_INFO"] = "Informação adicional",
	["REG_PLAYER_MSP_HOUSE"] = "Nome de Casa",
	["REG_PLAYER_MSP_MOTTO"] = "Lema",
	["REG_PLAYER_MSP_NICK"] = "Apelido",
	["REG_PLAYER_NAMESTITLES"] = "Nomes e títulos",
	["REG_PLAYER_NO_CHAR"] = "Sem características",
	["REG_PLAYER_NOTES"] = "Anotações",
	["REG_PLAYER_NOTES_ACCOUNT"] = "Anotações comuns",
	["REG_PLAYER_NOTES_ACCOUNT_HELP"] = "Estas anotações privadas estão vinculadas a sua conta e serão compartilhadas com todos seus perfis.",
	["REG_PLAYER_NOTES_PROFILE"] = "Anotações de %s",
	["REG_PLAYER_NOTES_PROFILE_HELP"] = "Estar anotações privadas estão vinculadas ao seu perfil atual e irão mudar baseado em qual perfil você tem atualmente ativo.",
	["REG_PLAYER_NOTES_PROFILE_NONAME"] = "Anotações do perfil",
	["REG_PLAYER_PEEK"] = "Diversos",
	["REG_PLAYER_PHYSICAL"] = "Descrição Física",
	["REG_PLAYER_PSYCHO"] = "Traços de personalidade",
	["REG_PLAYER_PSYCHO_Acete"] = "Ascético",
	["REG_PLAYER_PSYCHO_ADD"] = "Adicionar um traço de personalidade",
	["REG_PLAYER_PSYCHO_ATTIBUTENAME_TT"] = "Nome do atributo",
	["REG_PLAYER_PSYCHO_Bonvivant"] = "Bon vivant",
	["REG_PLAYER_PSYCHO_CHAOTIC"] = "Caótico",
	["REG_PLAYER_PSYCHO_Chaste"] = "Casto",
	["REG_PLAYER_PSYCHO_Conciliant"] = "Parágono",
	["REG_PLAYER_PSYCHO_Couard"] = "Covarde",
	["REG_PLAYER_PSYCHO_CREATENEW"] = "Criar um traço",
	["REG_PLAYER_PSYCHO_Cruel"] = "Brutal",
	["REG_PLAYER_PSYCHO_CUSTOM"] = "Traço personalizado",
	["REG_PLAYER_PSYCHO_CUSTOMCOLOR"] = "Selecione a cor do atributo",
	["REG_PLAYER_PSYCHO_CUSTOMCOLOR_LEFT_TT"] = "Selecione uma cor utilizada pela barra para o atributo esquerdo. |cffffff00clique:|r Seleciona uma cor |cffffffff00Botão direito:|r Descarte a cor |cffffffff00Shift+clique:|r Usa o seletor de cor predefinido",
	["REG_PLAYER_PSYCHO_CUSTOMCOLOR_RIGHT_TT"] = "Selecione uma cor utilizada pela barra para o atributo certo. |cffffff00Clique:|r Seleciona uma cor |cffffffff00botão direito:|r Descartar cor |cffffffff00Shift-Clique:|r Utiliza o seletor de cor predefinido",
	["REG_PLAYER_PSYCHO_Egoiste"] = "Egoísta",
	["REG_PLAYER_PSYCHO_Genereux"] = "Altruísta",
	["REG_PLAYER_PSYCHO_Impulsif"] = "Impulsivo",
	["REG_PLAYER_PSYCHO_Indulgent"] = "Clemente",
	["REG_PLAYER_PSYCHO_LEFTICON_TT"] = "Determinar o ícone do atributo esquerdo.",
	["REG_PLAYER_PSYCHO_Loyal"] = "Leal",
	["REG_PLAYER_PSYCHO_Luxurieux"] = "Luxurioso",
	["REG_PLAYER_PSYCHO_Misericordieux"] = "Gentil",
	["REG_PLAYER_PSYCHO_MORE"] = "Adicionar um ponto a \"%s\"",
	["REG_PLAYER_PSYCHO_PERSONAL"] = "Traços pessoais",
	["REG_PLAYER_PSYCHO_Pieux"] = "Supersticioso",
	["REG_PLAYER_PSYCHO_POINT"] = "Adicionar um ponto",
	["REG_PLAYER_PSYCHO_Pragmatique"] = "Renegado",
	["REG_PLAYER_PSYCHO_Rationnel"] = "Racional",
	["REG_PLAYER_PSYCHO_Reflechi"] = "Cauteloso",
	["REG_PLAYER_PSYCHO_Rencunier"] = "Vingativo",
	["REG_PLAYER_PSYCHO_RIGHTICON_TT"] = "Determinar o ícone do atributo da direita",
	["REG_PLAYER_PSYCHO_Sincere"] = "Verdadeiro",
	["REG_PLAYER_PSYCHO_SOCIAL"] = "Traços sociais",
	["REG_PLAYER_PSYCHO_Trompeur"] = "Enganoso",
	["REG_PLAYER_PSYCHO_Valeureux"] = "Valoroso",
	["REG_PLAYER_RACE"] = "Raça",
	["REG_PLAYER_RACE_TT"] = "Aqui vai a raça do seu personagem. Não tem que ser restrita às raças jogáveis. Há muitas raças em Warcraft que podem assumir formas comuns...",
	["REG_PLAYER_REGISTER"] = "Informação de diretório",
	["REG_PLAYER_RELATIONSHIP_STATUS"] = "Status de relacionamento",
	["REG_PLAYER_RELATIONSHIP_STATUS_DIVORCED"] = "Divorciado",
	["REG_PLAYER_RELATIONSHIP_STATUS_MARRIED"] = "Casado",
	["REG_PLAYER_RELATIONSHIP_STATUS_SINGLE"] = "Solteiro",
	["REG_PLAYER_RELATIONSHIP_STATUS_TAKEN"] = "Tomado",
	["REG_PLAYER_RELATIONSHIP_STATUS_TT"] = "Indique o estado da relação da sua personagem. Selecione \"Não mostrar\" se desejar manter essa informação escondida.",
	["REG_PLAYER_RELATIONSHIP_STATUS_UNKNOWN"] = "Não mostrar",
	["REG_PLAYER_RELATIONSHIP_STATUS_WIDOWED"] = "Viúva",
	["REG_PLAYER_RESIDENCE"] = "Residência",
	["REG_PLAYER_RESIDENCE_SHOW"] = "Coordenadas de residência",
	["REG_PLAYER_RESIDENCE_SHOW_TT"] = [=[|cff00ff00%s

|rClique para mostrar no mapa]=],
	["REG_PLAYER_RESIDENCE_TT"] = [=[Aqui você pode indicar onde seu personagem normalmente vive. Pode ser seu endereço residencial ou um lugar onde ele pode ser encontrado.
Note que se seu personagem é um errante ou até mesmo sem-teto, você terá que mudar a informação de acordo.

|c00ffff00Você pode usar o botão à direita para facilmente registrar sua localidade atual como sua Residência]=],
	["REG_PLAYER_RIGHTTRAIT"] = "Atributo da direita",
	["REG_PLAYER_SHOWMISC"] = "Exibir janela de Outros",
	["REG_PLAYER_SHOWMISC_TT"] = [=[Marque se quiser exibir campos personalizados para seu personagem.

Se não quiser mostrar campos personalizados, mantenha essa caixa desmarcada e a janela de miscelânea ficará completamente escondida.]=],
	["REG_PLAYER_SHOWPSYCHO"] = "Exibir janela de personalidade",
	["REG_PLAYER_SHOWPSYCHO_TT"] = [=[Marque se quiser usar a descrição de personalidade.

Se não quiser indicar a personalidade do seu personagem desta forma, mantenha esta caixa desmarcada e a janela de personalidade ficará completamente escondida.]=],
	["REG_PLAYER_STYLE_ASSIST"] = "Assistência de roleplay",
	["REG_PLAYER_STYLE_BATTLE"] = "Resolução de batalha roleplay",
	["REG_PLAYER_STYLE_BATTLE_1"] = "PVP do World of Warcraft",
	["REG_PLAYER_STYLE_BATTLE_2"] = "Batalha de dados do TRP",
	["REG_PLAYER_STYLE_BATTLE_3"] = "Batalha por /roll",
	["REG_PLAYER_STYLE_BATTLE_4"] = "Batalha por emotes",
	["REG_PLAYER_STYLE_DEATH"] = "Aceitar morte do personagem",
	["REG_PLAYER_STYLE_EMPTY"] = "Nenhum atributo de roleplay compartilhado",
	["REG_PLAYER_STYLE_FREQ"] = "Frequência de RolePlay",
	["REG_PLAYER_STYLE_FREQ_1"] = "O tempo todo, sem OOC",
	["REG_PLAYER_STYLE_FREQ_2"] = "A maior parte do tempo",
	["REG_PLAYER_STYLE_FREQ_3"] = "Média",
	["REG_PLAYER_STYLE_FREQ_4"] = "Casual",
	["REG_PLAYER_STYLE_FREQ_5"] = "OOC o tempo todo, não é um personagem de RP",
	["REG_PLAYER_STYLE_GUILD"] = "Filiação à guilda",
	["REG_PLAYER_STYLE_GUILD_IC"] = "Filiação IC",
	["REG_PLAYER_STYLE_GUILD_OOC"] = "Filiação OOC",
	["REG_PLAYER_STYLE_HIDE"] = "Não mostrar",
	["REG_PLAYER_STYLE_INJURY"] = "Aceitar ferimento do personagem",
	["REG_PLAYER_STYLE_PERMI"] = "Com permissão do jogador",
	["REG_PLAYER_STYLE_ROMANCE"] = "Aceitar romance com personagem",
	["REG_PLAYER_STYLE_RPSTYLE"] = "Estilo de roleplay",
	["REG_PLAYER_STYLE_RPSTYLE_SHORT"] = "Estilo de RP",
	["REG_PLAYER_STYLE_WOWXP"] = "Experiência de World of Warcraft",
	["REG_PLAYER_TITLE"] = "Título",
	["REG_PLAYER_TITLE_TT"] = [=[O título do seu personagem é o título pelo qual seu personagem normalmente é chamado. Evite títulos longos, os quais você deve colocar em "título completo" logo abaixo.

Exemplos de |c0000ff00títulos apropriados |r:
|c0000ff00- Condessa,
- Marquês,
- Magus,
- Lorde,
- etc.
|rExemplos de |cffff0000títulos inapropriados|r:
|cffff0000- Condessa dos Pântanos do Norte,
- Magus da Torre de Ventobravo,
- Diplomata do Governo Draenei,
- etc.]=],
	["REG_PLAYER_TRP2_PIERCING"] = "Piercings",
	["REG_PLAYER_TRP2_TATTOO"] = "Tatuagens",
	["REG_PLAYER_TRP2_TRAITS"] = "Fisionomia",
	["REG_PLAYER_TUTO_ABOUT_COMMON"] = [=[|cff00ff00Tema do personagem:|r
Você pode escolher um |cffffff00tema|r para seu personagem. Pense nele como uma |cffffff00música ambiente para ler a descrição do seu personagem|r.

|cff00ff00Fundo:|r
Isto é uma |cffffff00textura de fundo|r para a descrição do seu personagem.

|cff00ff00Modelo:|r
O modelo escolhido define o |cffffff00layout geral e possibilidades de escrita|r para sua descrição.
|cffff9900Apenas o modelo escolhido é visível aos outros, então você não precisa preencher todos.|r
Uma vez que um modelo for escolhido, você pode abrir este tutorial novamente para mais ajuda sobre cada modelo.]=],
	["REG_PLAYER_TUTO_ABOUT_MISC_1"] = [=[Esta seção possui |cffffff005 slots|r onde você pode descrever |cff00ff00as mais importantes informações sobre seu personagem|r.

Esses slots estarão visíveis na sua |cffffff00"barra de À primeira vista"|r quando alguém selecionar seu personagem.

|cff00ff00Dica: Você pode arrastar e soltar os slots para reordená-los.|r
Também funciona na |cffffff00"barra À primeira vista"|r!]=],
	["REG_PLAYER_TUTO_ABOUT_MISC_3"] = "Esta seção contém |cffffff00uma lista de marcadores|r para responder muitas |cffffff00perguntas comuns que as pessoas poderiam fazer a respeito de você, seu personagem e a maneira como você o interpreta|r.",
	["REG_PLAYER_TUTO_ABOUT_T1"] = [=[Este molde permite que você |cff00ff00estruture livremente sua descrição|r.

A descrição não precisa se limitar à |cffff9900descrição física|r do seu personagem. Sinta-se livre para indicar partes da sua |cffff9900história|r ou detalhes sobre sua |cffff9900personalidade|r.

Com este molde você pode usar as ferramentas de formatação para acessar vários parâmetros de molde como |cffffff00tamanhos, cores e alinhamentos de texto|r.

Essas ferramentas também o permitem inserir |cffffff0imagens, ícones ou links para websites externos|r.]=],
	["REG_PLAYER_TUTO_ABOUT_T2"] = [=[Este molde é mais estruturado e consiste de |cff00ff00uma lista de janelas independentes|r.

Cada janela é caracterizada por um |cffffff00ícone, um fundo e um texto|r. Note que você pode usar marcadores de texto nessas janelas, como os marcadores de texto colorido e ícones.

A descrição não precisa ser limitada à |cffff9900descrição física|r do seu personagem. Sinta-se livre para indicar partes da sua |cffff9900história|r ou detalhes sobre a sua |cffff9900personalidade|r.]=],
	["REG_PLAYER_TUTO_ABOUT_T3"] = [=[Este molde é cortado em 3 seções: |cff00ff00Descrição física, personalidade e história|r.

Você não precisa preencher todas as janelas, |cffff9900se você deixar uma janela vazia ela não será exibida na sua descrição|r.

Cada janela é caracterizada por um |cffffff00ícone, um fundo e um texto|r. Note que você pode usar marcadores de texto nessas janelas, como os marcadores de texto colorido e ícones.]=],
	["REG_PLAYER_WEIGHT"] = "Forma do corpo",
	["REG_PLAYER_WEIGHT_TT"] = [=[Esta é a forma do corpo do seu personagem.
Por exemplo, ele pode ser |c0000ff00esbelto, gordo ou musculoso...|r. Ou ele pode simplesmente ser comum !]=],
	["REG_PLAYERS"] = "Jogadores",
	["REG_REGISTER"] = "Diretório",
	["REG_REGISTER_CHAR_LIST"] = "Lista de personagens",
	["REG_RELATION"] = "Relação",
	["REG_RELATION_BUSINESS"] = "Negócios",
	["REG_RELATION_BUSINESS_TT"] = "%s e %s estão em uma relação de negócios.",
	["REG_RELATION_BUTTON_TT"] = [=[Relação: %s
|cff00ff00%s

|cffffff00Clique para exibir todas as ações possíveis]=],
	["REG_RELATION_FAMILY"] = "Família",
	["REG_RELATION_FAMILY_TT"] = "%s possui laços de sangue com %s.",
	["REG_RELATION_FRIEND"] = "Amigável",
	["REG_RELATION_FRIEND_TT"] = "%s considera %s um(a) amigo(a).",
	["REG_RELATION_LOVE"] = "Amor",
	["REG_RELATION_LOVE_TT"] = "%s está apaixonado(a) por %s !",
	["REG_RELATION_NEUTRAL"] = "Neutro",
	["REG_RELATION_NEUTRAL_TT"] = "%s não sente nada em particular em relação a %s.",
	["REG_RELATION_NONE"] = "Nenhuma",
	["REG_RELATION_NONE_TT"] = "%s não conhece %s.",
	["REG_RELATION_TARGET"] = "|cffffff00Clique: |rMudar relação",
	["REG_RELATION_UNFRIENDLY"] = "Antipático",
	["REG_RELATION_UNFRIENDLY_TT"] = "%s claramente não gosta de %s.",
	["REG_REPORT_PLAYER_OPEN_URL"] = "Você somente pode reportar jogadores diretamente de dentro do jogo se os puder Marcar (usando o botão de frame alvo do TRP3). Se desejar reportar o perfil do %s e você não puder os marcar, terá de abrir um ticket com o apoio da Blizzard, utilizando o link abaixo.",
	["REG_REPORT_PLAYER_OPEN_URL_160"] = "Se você deseja reportar o perfil %s, você precisar abrir um ticket com o suporte da blizzard usando o link abaixo:",
	["REG_REPORT_PLAYER_PROFILE"] = "Reportar perfil para |cff449fe0Blizzard|r",
	["REG_REPORT_PLAYER_PROFILE_TT"] = "Você pode denunciar um perfil que infrinja os Termos de Serviço da Blizzard. Isto pode incluir assédio, doxxing, discurso de ódio, conteúdo obsceno ou outra forma de conteúdo perturbador. |cffff0000Por favor note que esta opção NÃO é denunciar perfis RP de qualidade contestável ou de luto. Os abusos desta característica são puníveis!",
	["REG_REPORT_PLAYER_TEMPLATE"] = "Este jogador esta usando o Addon de perfil RP %s para compartilhar conteúdo que vai contra os termos de serviço",
	["REG_REPORT_PLAYER_TEMPLATE_DATE"] = "Os Arquivos do addon foi transferido através do addon de mensagem logado em %s",
	["REG_REPORT_PLAYER_TEMPLATE_TRIAL_ACCOUNT"] = "Este jogador está em uma conta de teste.",
	["REG_TIME"] = "Última vez visto",
	["REG_TRIAL_ACCOUNT"] = "Conta de teste",
	["REG_TT_GUILD"] = "%s de |cffff9900%s",
	["REG_TT_GUILD_IC"] = "Membro IC",
	["REG_TT_GUILD_OOC"] = "Membro OOC",
	["REG_TT_IGNORED"] = "< Personagem está ignorado >",
	["REG_TT_IGNORED_OWNER"] = "< Dono está ignorado >",
	["REG_TT_LEVEL"] = "Nível %s %s",
	["REG_TT_NOTIF"] = "Descrição não-lida",
	["REG_TT_REALM"] = "Reino: |cffff9900%s",
	["REG_TT_TARGET"] = "Alvo: |cffff9900%s",
	["REG_TT_ZONE"] = "Área",
	["SCRIPT_ERROR"] = "Error no script.",
	["SCRIPT_UNKNOWN_EFFECT"] = "Erro de script, FX desconhecido",
	["SLASH_CMD_STATUS_HELP"] = "Utilização: |cff00ff00/trp3 Status ic ||| ooc ||| trocar|r Altera o seu status de personagem para a opção especificada: |cffff9900/trp3 status Ic|r definirá o seu estado para |cff00ff00 No Personagem |r. |cffff9900/trp3 status ooc|r definirá o seu status para |cffffff0000Fora do Personagem|r. |cffff9900/trp3 status Alterar|r irá mudar o seu estado para o estado oposto.",
	["SLASH_CMD_STATUS_USAGE"] = "ic || ooc || Alterar",
	["TB_AFK_MODE"] = "Ausente",
	["TB_DND_MODE"] = "Não perturbe",
	["TB_GO_TO_MODE"] = "Mudar para modo %s",
	["TB_LANGUAGE"] = "Linguagem",
	["TB_LANGUAGES_TT"] = "Mudar linguagem",
	["TB_NORMAL_MODE"] = "Normal",
	["TB_RPSTATUS_OFF"] = "Personagem: |cffff0000Não interpretando",
	["TB_RPSTATUS_ON"] = "Personagem: |cff00ff00Interpretando",
	["TB_RPSTATUS_TO_OFF"] = "Alternar para |cffff0000não interpretando",
	["TB_RPSTATUS_TO_ON"] = "Alternar para |cff00ff00interpretando",
	["TB_STATUS"] = "Jogador",
	["TB_SWITCH_CAPE_1"] = "Exibir capa",
	["TB_SWITCH_CAPE_2"] = "Esconder capa",
	["TB_SWITCH_CAPE_OFF"] = "Capa: |cffff0000Escondida",
	["TB_SWITCH_CAPE_ON"] = "Capa: |cff00ff00Exibida",
	["TB_SWITCH_HELM_1"] = "Exibir elmo",
	["TB_SWITCH_HELM_2"] = "Esconder elmo",
	["TB_SWITCH_HELM_OFF"] = "Elmo: |cffff0000Escondido",
	["TB_SWITCH_HELM_ON"] = "Elmo: |cff00ff00Exibido",
	["TB_SWITCH_PROFILE"] = "Mudar para outro perfil",
	["TB_SWITCH_TOOLBAR"] = "Mudar barra de ferramentas",
	["TB_TOOLBAR"] = "Barra de ferramentas",
	["TF_IGNORE"] = "Ignorar jogador",
	["TF_IGNORE_CONFIRM"] = [=[Você tem certeza que quer ignorar esta ID ?

|cffffff00%s|r

|cffff7700Você pode inserir abaixo o motivo. Isso é uma nota pessoal, não será visível aos outros e servirá como lembrete.]=],
	["TF_IGNORE_NO_REASON"] = "Sem motivo",
	["TF_IGNORE_TT"] = "|cffffff00Clique:|r Ignorar jogador",
	["TF_OPEN_CHARACTER"] = "Mostrar página do personagem",
	["TF_OPEN_COMPANION"] = "Mostrar página do companheiro",
	["TF_OPEN_MOUNT"] = "Exibir página de montarias",
	["TF_PLAY_THEME"] = "Tocar tema do personagem",
	["TF_PLAY_THEME_TT"] = [=[|cffffff00Clique:|r Tocar |cff00ff00%s
|cffffff00Duplo-clique:|r Parar tema]=],
	["THANK_YOU_1"] = [=[{h1:c}Total RP 3{/h1}
{p:c}{col:6eff51}Versão %s (build %s){/col}{/p}
{p:c}{link*http://totalrp3.info*TotalRP3.info} — {twitter*TotalRP3*@TotalRP3} {/p}
{p:c}{link*http://discord.totalrp3.info*Junte-se a nós no Discord}{/p}

{h2}{icon:INV_Eng_gizmo1:20} Criado por{/h2}
- Morgane "{twitter*EllypseCelwe*Ellypse}" Parize
- Sylvain "{twitter*Telkostrasz*Telkostrasz}" Cossement


{h2}{icon:THUMBUP:20} Reconhecimentos{/h2}
{col:ffffff}Logo and minimap button icon:{/col}
- {link*https://twitter.com/Kelandiir*@Kelandiir}

{col:ffffff}Nossa equipe de QA do pré-alpha:{/col}
- Saelora
- Erzan
- Calian
- Kharess
- Alnih
- 611

{col:ffffff}Obrigado a todos os nossos amigos por seus suporte por todos esses anos:{/col}
- Por Telkos: Kharess, Kathryl, Marud, Solona, Stretcher, Lisma...
- Por Ellypse: As guildas Église du Saint Gamon, Maison Celwë'Belore, Mercenaires Atal'ai, e mais particularmente Erzan, Elenna, Caleb, Siana e Adaeria

{col:ffffff}Por nos ajudar a criar a guilda Total RP no Kirin Tor (EU):{/col}
- Azane
- Hellclaw
- Leylou

{col:ffffff}Agradecimentos a Horionne por nos enviar a revista Gamer Culte Online #14 com um artigo sobre o Total RP.{/col}]=],
	["THANK_YOU_ROLE_AUTHOR"] = "Autor",
	["THANK_YOU_ROLE_COMMUNITY_MANAGER"] = "Gerente da comunidade",
	["THANK_YOU_ROLE_CONTRIBUTOR"] = "Contribuidor",
	["THANK_YOU_ROLE_GUILD_MEMBER"] = "Membro da Guilda",
	["THANK_YOU_ROLE_TESTER"] = "Equipe de perguntas e respostas",
	["TT_ELVUI_SKIN"] = "ElvUI skin ",
	["TT_ELVUI_SKIN_ENABLE_TARGET_FRAME"] = "Moldura do alvo de skin",
	["TT_ELVUI_SKIN_ENABLE_TOOLTIPS"] = "Ferramentas de skin",
	["UI_BKG"] = "Fundo %s",
	["UI_CLOSE_ALL"] = "Fechar tudo",
	["UI_COLOR_BROWSER"] = "Navegador de cores",
	["UI_COLOR_BROWSER_PRESETS"] = "Predefinidos",
	["UI_COLOR_BROWSER_PRESETS_BASIC"] = "Básico ",
	["UI_COLOR_BROWSER_PRESETS_CLASSES"] = "Classe",
	["UI_COLOR_BROWSER_PRESETS_CUSTOM"] = "Customizado",
	["UI_COLOR_BROWSER_PRESETS_ITEMS"] = "Qualidade de item",
	["UI_COLOR_BROWSER_PRESETS_RESOURCES"] = "Recurso",
	["UI_COLOR_BROWSER_SELECT"] = "Selecionar cor",
	["UI_COMPANION_BROWSER_HELP"] = "Selecionar uma mascote de batalha",
	["UI_COMPANION_BROWSER_HELP_TT"] = [=[|cffffff00Aviso: |rApenas mascotes de batalha nomeadas podem ser vinculadas a um perfil.

|cff00ff00Esta seção lista apenas estas mascotes.]=],
	["UI_FILTER"] = "Filtrar",
	["UI_ICON_BROWSER"] = "Navegador de ícones",
	["UI_ICON_BROWSER_HELP"] = "Copiar ícone",
	["UI_ICON_BROWSER_HELP_TT"] = [=[Enquanto esta janela estiver aberta você pode usar |cffffff00ctrl + clique|r em um ícone para copiar seu nome.

Isso funciona:|cff00ff00
- Em qualquer item nas suas bolsas
- Em qualquer ícone no livro de habilidades]=],
	["UI_ICON_SELECT"] = "Selecionar ícone",
	["UI_IMAGE_BROWSER"] = "Navegador de imagens",
	["UI_IMAGE_SELECT"] = "Selecionar imagem",
	["UI_LINK_SAFE"] = "Aqui está o link URL,",
	["UI_LINK_TEXT"] = "Seu texto aqui",
	["UI_LINK_URL"] = "http://sua.url.aqui",
	["UI_LINK_WARNING"] = [=[Aqui está a URL do link.
Você pode copiar/colar no seu navegador da web.
|cffff0000!! Aviso !!|r
O Total RP não é responsável por links que levem a conteúdo nocivo.
]=],
	["UI_MUSIC_ALTTITLE"] = "Título alternativo",
	["UI_MUSIC_BROWSER"] = "Navegador de músicas",
	["UI_MUSIC_DURATION"] = "Duração",
	["UI_MUSIC_SELECT"] = "Selecionar música",
	["UI_PET_BROWSER_ACCEPT"] = "Assinar",
	["UI_PET_BROWSER_BOUND_WARNING"] = "|cffff0000Aviso: |r Este animal de estimação está atualmente atribuído ao perfil |cff00ff00%1$s|r. A atribuição de um perfil a este animal de estimação irá substituir o perfil atual.",
	["UI_PET_BROWSER_EMPTY_TEXT"] = "Você não tem animais de estimação a quem possa ser atribuído um perfil.",
	["UI_PET_BROWSER_INTRO_TEXT"] = "Selecione um pet com os botões abaixo e clique  |cffffff00Assinar|r para vincular ao perfil.",
	["UI_PET_BROWSER_NAME_WARNING"] = "|cffff0000Aviso: |r Este animal de estimação não foi renomeado. Recomendamos que se renomeie o animal de estimação para evitar mostrar este perfil em outros animais de estimação com o mesmo nome.",
	["UI_TUTO_BUTTON"] = "Modo tutorial",
	["UI_TUTO_BUTTON_TT"] = "Clique para ativar/desativar o modo tutorial",
	["UNIT_POPUPS_CHARACTER_STATUS"] = "Status do personagem",
	["UNIT_POPUPS_CONFIG_DISABLE_IN_COMBAT"] = "Esconder menu de entradas no combate",
	["UNIT_POPUPS_CONFIG_DISABLE_IN_COMBAT_HELP"] = "Se marcado, entradas adicionais no menu  não serão mostradas em combate.",
	["UNIT_POPUPS_CONFIG_DISABLE_IN_INSTANCES"] = "Esconder entradas do menu enquanto estiver em instância",
	["UNIT_POPUPS_CONFIG_DISABLE_IN_INSTANCES_HELP"] = "Se marcado, entradas adicionais no menu não irão ser mostradas enquanto estiver em conteúdo instanciado",
	["UNIT_POPUPS_CONFIG_DISABLE_ON_UNIT_FRAMES"] = "Esconder entradas no menu dos frames dos personagens ",
	["UNIT_POPUPS_CONFIG_DISABLE_ON_UNIT_FRAMES_HELP"] = "Se marcado, as entradas adicionais do menu não serão mostradas nos menus ativados por molduras de unidades com um clique no botão direito do mouse.",
	["UNIT_POPUPS_CONFIG_DISABLE_OUT_OF_CHARACTER"] = "Esconder entradas do menu enquanto estiver Fora do Personagem",
	["UNIT_POPUPS_CONFIG_DISABLE_OUT_OF_CHARACTER_HELP"] = "Se marcado. entradas adicionais no menu não serão mostradas enquanto estiver Fora do Personagem",
	["UNIT_POPUPS_CONFIG_ENABLE_MODULE"] = "Módulo |cff00ff00Ativado|r",
	["UNIT_POPUPS_CONFIG_ENTRIES_HEADER"] = "Entradas do menu",
	["UNIT_POPUPS_CONFIG_MENU_TITLE"] = "Configurações do menu",
	["UNIT_POPUPS_CONFIG_PAGE_HELP"] = "O módulo de pop-ups de personagens adiciona entradas adicionais aos menus de clique do botão direito do mouse encontrados nas molduras dos personagens e nomes na moldura do chat.",
	["UNIT_POPUPS_CONFIG_PAGE_TEXT"] = "Configurações do menu",
	["UNIT_POPUPS_CONFIG_SHOW_CHARACTER_STATUS"] = "Mostrar alternador de status do personagem",
	["UNIT_POPUPS_CONFIG_SHOW_CHARACTER_STATUS_HELP"] = "Se marcado, adiciona uma caixa de verificação ao seu próprio menu de moldura do personagem que lhe permite alternar o seu estado dentro do personagem/fora do personagem.",
	["UNIT_POPUPS_CONFIG_SHOW_HEADER_TEXT"] = "Mostrar texto do cabeçalho",
	["UNIT_POPUPS_CONFIG_SHOW_HEADER_TEXT_HELP"] = "Se marcado, mostra um cabeçalho \"Opções de Roleplay\" acima de quaisquer entradas de menu adicionadas.",
	["UNIT_POPUPS_CONFIG_SHOW_OPEN_PROFILE"] = "Mostrar botão Abrir perfil",
	["UNIT_POPUPS_CONFIG_SHOW_OPEN_PROFILE_HELP"] = "Se marcado, adiciona um botão que abre o perfil RP dos personagens selecionados quando clicado.|n|nEsta opção será visível em todos os menus de frame e chat dos personagens.",
	["UNIT_POPUPS_CONFIG_SHOW_SEPARATOR"] = "Mostrar separador",
	["UNIT_POPUPS_CONFIG_SHOW_SEPARATOR_HELP"] = "Se marcado, mostra uma barra separadora acima de qualquer entrada de menu.",
	["UNIT_POPUPS_CONFIG_VISIBILITY_HEADER"] = "Opções de visibilidade",
	["UNIT_POPUPS_CURRENT_PROFILE"] = "Perfil atual",
	["UNIT_POPUPS_CURRENT_PROFILE_NAME"] = "Perfil atual: %1$s",
	["UNIT_POPUPS_MODULE_DESCRIPTION"] = "Adiciona integração com o botão direito nos menus dos personagens e nomes de jogadores nas molduras do chat.",
	["UNIT_POPUPS_MODULE_DISABLE_WARNING"] = "É necessário recarregar a interface do jogador para desativar o módulo de pop-ups do personagem.|n|n|cffff0000Aviso: |ruma vez desativado, este módulo só pode ser reativado a partir da página |cffffcc00 Status do Módulo|r. Tem certeza de que quer desativar este módulo?",
	["UNIT_POPUPS_MODULE_NAME"] = "Pop-ups dos personagens",
	["UNIT_POPUPS_OPEN_PROFILE"] = "Abrir perfil",
	["UNIT_POPUPS_ASSIGN_FLAG"] = "Atribuir perfil",
	["UNIT_POPUPS_ROLEPLAY_OPTIONS_HEADER"] = "Opções de Roleplay",
	["WHATS_NEW_23"] = "# Changelog versão 1.6.0 ## Notas pessoais, você Pode agora escrever notas pessoais dentro do addon ! Estas notas podem ser escritas ou no seu próprio perfil (se desejar tomar notas genéricas para o seu personagem), ou no perfil de outra pessoa (o campo superior sendo ligado ao seu perfil atual, sendo o campo inferior comum a todos os seus perfis). Estas notas são obviamente privadas, ninguém mais, a não ser você, pode vê-las. {img:Interface\\AddOns\\totalRP3\\resources\\160-1.tga:480:480} Para acessar as notas pessoais, basta clicar no novo botão de Notas na moldura do personagem, ou abrir um perfil e clicar no separador Notas. {img:Interface\\AddOns\\totalRP3\\resources\\160-2.tga:240:120} O registo também recebeu uma caixa de verificação para exibir apenas perfis nos quais escreveu notas. {img:Interface\\AddOns\\totalRP3\\resources\\160-3.tga:480:120} ## Adicionado - Adicionado suporte HTML para About templates 2 e 3. Pode agora usar a gama completa de etiquetas HTML enquanto usa esses templates para formatar os seus campos, usando a barra de ferramentas que é agora visível para todos os templates. Adicionado compatibilidade com outros addons de RP para traços de personalidade e tags HTML. ## Alterado - Os botões \"Reportar perfil\" irão agora ambos ligar-se à página [de suporte do website sobre assédio via addons](https://battle.net/support/help/product/wow/197/1501/solution), uma vez que a funcionalidade de relatório no jogo anteriormente adicionada era um método inválido para reportar abuso de addons. O popup mostrará ainda um carimbo de data/hora para a recepção do perfil, que poderá fornecer ao CS da Blizzard para os ajudar a localizar a ofensa. ## Corrigido - Corrigido um erro que poderia impedir o carregamento do addon. - Corrigido um problema de compatibilidade para o modelo 3, se o local do addon não fosse inglês. ## Removido - Removida a iluminação automática do texto completo ao entrar no foco de uma área de texto (Sobre campos, Atualmente, OOC Info...) - Removido o código dos tolos de Abril (incluindo os nomes esquecidos do companheiro arco-íris).",
	["WHATS_NEW_23_1"] = "# versão Changelog 1.6.1 ## retrabalho do sistema musical - Alterações técnicas no patch 8.2 obrigaram-nos a alterar a forma como a música é tratada pelo addon. ## Isto significa que a actualização é necessária para que as músicas funcionem.** Esta alteração deve ser sem problemas e compatível com o passado (temas musicais de perfis provenientes de versões desactualizadas devem continuar a tocar bem). - Isto permitiu a adição de músicas anteriormente indisponíveis (olhando para si, músicas de elfos vazias). - A duração de todas as músicas deve agora ser visível nas pontas de ferramentas da linha do navegador de música. ## Alterado - As definições para aumentar o contraste de cor nas pontas de ferramentas e no chat foram consolidadas numa única definição para ambas, que pode ser encontrada nas definições Gerais. Também se aplica em mais lugares, como as dicas de ferramentas de digitalização de mapas. ## Fixo - A âncora para o botão de digitalização do mapa pode agora ser devidamente definida. - Corrigida uma mudança nos títulos de cabeçalhos/parágrafos - Corrigida uma mensagem de erro que podia ser causada por outros addons que utilizavam indevidamente funções API oficiais.",
	["WHATS_NEW_23_10"] = "# Changelog versão 1.6.10 ## Adicionado - Adicionado %xt e %xf fichas de chat. Estes serão automaticamente substituídos pelo nome RP do seu alvo e foco, respectivamente, quando enviar uma mensagem. - Adicionadas definições para ajustar os tamanhos das fontes About font.",
	["WHATS_NEW_23_11"] = "# Versão Changelog 1.6.11 ## Adicionada - Adicionadas novas fichas de chat para primeiro e último nomes: %xtf (primeiro nome do Alvo), %xtl (último nome do Alvo), %xff (primeiro nome do Focus), %xfl (último nome do Focus). ## Corrigido - Corrigido um problema ao tentar adicionar um link de chat a uma caixa de chat vazia. - Corrigido um problema de compatibilidade com o PallyPower.",
	["WHATS_NEW_23_12"] = "# Versão Changelog 1.6.12 ## Corrigido - Tentativamente corrigido um problema com linhas de ponta de ferramenta. - Corrigido um problema com o botão de residência em Classic.",
	["WHATS_NEW_23_2"] = "# versão Changelog 1.6.2 ## Adicionado - Adicionados 328 ícones e 20 imagens do patch 8.2. - Adicionado um indicador ao navegador de música quando o nome por defeito de uma música difere do que corresponde ao filtro atual. ## Corrigido - Fixados os problemas na transferência de dados musicais entre o TRP e o MRP. - Corrigido um problema com linhas duplicadas na ponta do botão de digitalização do mapa. - Mais correções especulativas para o problema do mapa no início de sessão.",
	["WHATS_NEW_23_3"] = "# Versão Changelog 1.6.3 ## Alterada - As pontas de ferramentas do companheiro irão agora ajustar o contraste para a cor personalizada se a configuração estiver ativada. ## Corrigido - Corrigido um erro de dica de ferramenta de companhia quando o API não devolve o tipo de animal de estimação. - Corrigido um problema que podia fazer aparecer a barra de ferramentas acima do mapa mundial. - Corrigido um erro de ancoragem com a moldura de destino.",
	["WHATS_NEW_23_4"] = "# versão Changelog 1.6.4 Estamos cientes de um problema atual no Comércio a Retalho que faz com que ** o uso do item do rastreador objetivo** falhe por vezes. Embora ainda não tenhamos uma solução para o problema, **tipagem/recarga após a recepção da mensagem de erro** corrige temporariamente o problema. Lamentamos o inconveniente. ## WoW: Suporte clássico - Total RP 3: Clássico está agora disponível como um download separado em CurseForge e WoWInterface! Não se esqueça de o instalar em vez da versão de retalho do Total RP 3 se planeia jogar na WoW: Clássico. - Pontos importantes a ter em conta para a versão Classic: - Alguns ícones foram alterados em todo o addon para substituir ícones em falta no Classic. - Os perfis dos companheiros foram desativados para montagens e animais de estimação não-combatentes, uma vez que a Blizzard não nos forneceu acesso beta. Trabalharemos na sua implementação de volta o mais rapidamente possível. - Total RP 3: Extensão não será portada para Classic no lançamento. Estaremos a avaliar se um porto Clássico faz sentido para nós fazer mais tarde. ## Alterado - Ao utilizar o scaneamento do mapa de caracteres, os caracteres com os quais estabeleceu uma relação aparecerão agora em cima dos outros.",
	["WHATS_NEW_23_5"] = "# Changelog versão 1.6.5 ## Adicionado - Adicionado Total RP 3: Número da versão ampliada ao lado do número da versão Total RP 3 na parte inferior da ponta da ferramenta. ## Corrigido - Corrigido um erro quando alguém executa um scaneamento na sua zona. (Apenas clássico) - Corrigido um erro potencial quando se guarda um slot de visualização. ",
	["WHATS_NEW_23_6"] = "# Changeelog version 1.6.6 ## Adicionado - Adicionados comandos slash para alterar o seu estado de roleplay, que pode usar em macros. Agora pode utilizar `/trp3 status ic` para entrar no personagem, `/trp3 status ooc` para sair do personagem, ou `/trp3 alternar status` para mudar de status. - Foi adicionada uma configuração de chat para exibir o indicador OOC ao lado do nome no chat. - Adicionada uma configuração para ocultar o botão de scan do mapa se não houver scan disponível. - Adicionado um campo de linguagem de roleplay no painel de instrumentos principal. - Esta configuração é baseada no perfil, por defeito na língua do seu addon, e permite-lhe indicar a língua em que está a desempenhar as suas funções. - Se a linguagem do seu addon não corresponder à linguagem de roleplaying de um jogador, verá uma bandeira na parte inferior da sua ponta de ferramentas indicando a sua linguagem de roleplaying. - Esta alteração destina-se principalmente aos RPs clássicos, uma vez que apenas foram feitos os reinos de RP em inglês. - Foram adicionados botões para trás para alternar a exibição de capacete e capacete de Clássico. ## Alterado - Renomeado o modo de guerra para modo PvP para Clássico. ## Corrigido - Corrigido problemas quando o módulo de barra de alvo foi desativado. - Corrigido - Corrigido um problema que fazia com que perfis duplicados do Protocolo Mary-Sue aparecessem no registo ao desmarcar \"Este reino apenas\". - Corrigido alguns ícones em falta para Clássico (ícones padrão de modelo 3 e ícones `/trp3 roll`) - Corrigido um problema ao utilizar a definição \"Clique com o botão direito do rato para abrir perfil\" em Clássico.",
	["WHATS_NEW_23_7"] = "# Versão Changelog 1.6.7 ## Adicionada - Adicionada uma configuração para detectar a fala em notas e colori-la automaticamente. - Adicionados 7 ícones e 1 música do patch 8.2.5. ## Alterado - A lista de perfis complementares acedidos através da moldura alvo está agora ordenada alfabeticamente, e \"Criar novo perfil\" foi movido para fora dela.",
	["WHATS_NEW_23_8"] = "# Changeelog version 1.6.8 ## Changeed - **Classic:** Devido a 1.13.3 mudanças de API, o escaneamento do mapa foi modificado para encontrar caracteres apenas no intervalo de gritos. Só será mostrado no mapa em que se encontra. **Apenas os caracteres que utilizem o Total RP 3 versão 1.6.8 serão visíveis no scaneamento.** *Lembrete : Pode desativar a sua aparência de escaneamento desmarcando \"Configurações de registro > Configurações locais > Ativar localização do personagem. Por favor, não se detenha na atualização por razões de visibilidade.* - A detecção de voz só se aplicará agora às emotes (incluindo as emotes NPC). ## Corrigido - Corrigido um problema raro em que o processo de carregamento do addon seria interrompido por uma chave de definição que não podia ser lida.",
	["WHATS_NEW_23_9"] = "# Versão Changelog 1.6.9 ## Adicionada - Adicionadas 61 músicas, 5 imagens e 223 ícones no retalho a partir do patch 8.3. - Adicionadas 177 imagens sobre Retalho a partir de adesivos anteriores. - Adicionado 1 ícone em Clássico a partir do patch 1.13.3. - Adicionados ícones padrão para Vulperas e Mechagnomes. ## Alterado - Alterado ícone Kul Tiran padrão feminino. ## Corrigido - Adicionado o trabalho de scan de mapa clássico para lidar com a falta de testes da Blizzard. - Corrigido um problema ao tentar usar ícones com um apóstrofo no seu nome. - O filtro do navegador de imagens agora lida corretamente com alguns caracteres especiais.",
	["WHATS_NEW_24_1"] = "# Changelog versão 2.0 ### Adicionado - Adicionado um perfil padrão. - Este perfil não pode ser modificado e contém apenas informação básica de carácter (nome, raça, classe). - Novos caracteres serão agora vinculados ao perfil padrão em vez de criar automaticamente um novo perfil. - Um novo perfil é ainda necessário para adicionar informação personalizada. - Adicionada uma barra de pesquisa nas listas de perfis de caracteres e de acompanhantes. ## Fixo - Corrigido um conflito entre a detecção de OOC e as declinações russas. - Corrigido um problema relacionado com o histórico de chat Prat + WIM. ## Alterado - Removido um traço de personalidade pré-definido. - Melhorado o protocolo de comunicação para reduzir o tamanho da transferência de perfil. - Várias alterações de compatibilidade relacionadas com as modificações da API 9.0.",
	["WHATS_NEW_24_10"] = "# versão Changelog 2.3.7 Esta versão é atualizada para TBC Classic 2.5.2. # Fixo - 9.1 ícones e músicas foram devidamente adicionados para o retalho. - Corrigido um problema com o TRP3: Falha na troca de criação extensiva em casos muito específicos.",
	["WHATS_NEW_24_2"] = "# Versão Changelog 2.1 ## Adicionada - Adicionadas 113 imagens, 1437 ícones e 613 músicas do patch 9.0. - Adicionado o modificador ao texto de saída do rolo de dados. - Adicionadas opções de encadernação de teclas para abrir o perfil alvo e alternar o estado de RP. ## Corrigido - Corrigido um problema com a dica de ferramenta padrão aparecendo por vezes apesar da definição de \"Esconder dica de ferramenta original\" ter sido verificada. - Corrigido um problema com a dica de ferramenta TRP3 a ser deslocada enquanto a dica de ferramenta padrão está oculta. - Corrigido um problema com a dica de ferramenta TRP3 sobrepondo-se brevemente à dica de ferramenta predefinida se rapidamente passar de um jogador para um feitiço/item. - Corrigido um problema quando se tentava abrir a janela de módulos Prat enquanto o TRP3 estava a correr. - Corrigido um problema de visualização com o fundo da moldura de fala NPC. - Corrigida a ordenação alfabética ao pairar um grupo de jogadores no scaneamento do mapa. - Correção potencial para o canal guia ser trocado com o canal xtensionxtooltip2.",
	["WHATS_NEW_24_3"] = "# Versão Changelog 2.2 ## Adicionado - Adicionado Pronouns pré-definidos em Informação adicional. Ao utilizar esta predefinição, os pronomes serão mostrados na sua ponta de ferramenta. - Adicionado suporte para perfis de companheiros no animal de estimação secundário convocado com o talento de caçador Animal Companheiro. - Adicionado um browser de caçador de animais de estimação quando se liga um perfil de companheiro através da lista de perfis. ## Fixo - Dicas de ligação de chat fixas sendo invisíveis quando se abre um pela primeira vez. - Corrigidos os problemas de formatação com ligações de chat. - Corrigido um problema que fazia com que o browser de batalha de animais de estimação mostrasse uma lista incompleta se a colecção de animais de batalha tivesse filtros de pesquisa aplicados. - Corrigidos os ícones inválidos no separador Sobre ao receber um perfil de outros addons de RP no Classic. - Corrigida a informação incorrecta na dica de ferramenta da definição do prefixo de discurso NPC. - Corrigido um problema com o histórico do chat Tukui.",
	["WHATS_NEW_24_4"] = "# Changelog versão 2.3 ## Adicionado - Adicionado um módulo para personalizar placas de nome com informação RP. Atualmente, **só são suportadas placas de identificação padrão da Blizzard e placas de nome Kui**. *Como agora é redundante, o módulo TRP3: As placas de nome Kui irão agora desativar-se e deverá ser desinstalado.* - Adicionado suporte para perfis de companheiros em Classic. - Adicionadas entradas nas molduras das unidades, clicando no menu do botão direito do rato para abrir o perfil + alterar o estado do roleplay. - Adicionada uma janela para copiar nomes de caracteres ligados a um perfil quando se clica com o botão direito do rato na lista de diretórios. - Adicionada uma opção para desativar as pontas de ferramentas do perfil em instâncias. ## Alterado - A janela de cópia URL fecha-se agora depois de premir o atalho de cópia. - O perfil padrão já não mostra a quantidade de caracteres a ele vinculados. - Os campos de características cortados irão agora mostrar uma dica de ferramenta em pairar com o conteúdo completo do campo. - O editor de descrição irá agora receber o foco de entrada após clicar em qualquer botão de ferramenta de formatação. - Nomes personalizados em quadros de chat com comprimentos excessivamente grandes serão agora recortados. - As cores personalizadas para traços de personalidade aplicam-se agora aos nomes de atributos. ## Corrigido - Corrigido um problema com a personalização do chat que não se registava corretamente no início de sessão enquanto se usava o Prat. - Corrigido o sinal sonoro em falta ao abrir/fechar a janela principal. - Corrigido um problema que podia fazer com que os jogadores marcados com PvP mostrassem a sua localização nas varreduras de mapa em Classic. - Corrigido o ícone de língua vulpera em falta.",
	["WHATS_NEW_24_5"] = "# Versão Changelog 2.3.2 ## Adicionada - Adicionadas configurações para opções de clique com o botão direito do rato em molduras de unidades e nomes de chat. ## Corrigido - Corrigido nomes incorretos que aparecem nas placas de nomes NPC da Blizzard. - Corrigido o problema de exibição com o modo de tanque  nas placas de nome Kui . - Corrigido um problema de dependência que impedia a personalização do chat de funcionar quando se usava Prat e Listener. - Corrigida a localização não sendo devidamente aplicada a várias configurações.",
	["WHATS_NEW_24_6"] = "# Versão Changelog 2.3.3 ## Adicionada - Adicionados campos de dica de ferramentas para zona de caracteres e saúde. Estes campos podem ser alternados em definições de dica de ferramenta. - O campo de zona só será mostrado quando o carácter estiver noutra zona (se olhar para um membro do partido, por exemplo). - O campo de saúde só será mostrado se o carácter não for de saúde total. É desativado por defeito. ## Fixado - Fixou alguns problemas com transferência de perfil. - Fixo - Corrigido as placas de nome RP apenas com o nome Kui que não eram atualizadas quando o texto do nível e a saúde estavam ambos desativados. - Corrigida a incapacidade de definir um perfil de animal de estimação quando o animal é convocado pela primeira vez. - Fixada a sobreposição da ponta de ferramenta TRP com a ponta de ferramenta principal, se o perfil tiver sido apanhado pelo filtro Adulto. - Fixada a quebra de ligações de chat TRP a partir da detecção de emoções/OOC/speech. - Corrigidos os campos atualmente/OOC que não se escondem corretamente nas pontas das ferramentas se contiverem apenas espaços em branco.",
	["WHATS_NEW_24_8"] = "# Versão Changelog 2.3.5 ## Adicionado - Adicionado suporte para Burning Crusade Classic. ## Corrigido - Corrigido vários problemas de desempenho ao solicitar perfis de caracteres.",
	["WHATS_NEW_24_9"] = "# Changelog versão 2.3.6 ## Adicionado - Adicionados 323 novos ícones, 7 imagens e 138 novos ficheiros de música do patch 9.1.0. ## Removido - Removida a bandeira da linguagem do roleplay. - Corrigido um bug com canais de chat no Classic."
}

TRP3_API.loc:RegisterNewLocale("ptBR", "Português", localeContent);

localeContent = {
	["ABOUT_TITLE"] = [=[О персонаже
]=],
	["BINDING_NAME_TRP3_OPEN_TARGET_PROFILE"] = "Открыть профиль цели",
	["BINDING_NAME_TRP3_TOGGLE"] = "Показать/спрятать главное окно",
	["BINDING_NAME_TRP3_TOGGLE_CHARACTER_STATUS"] = "Переключить статус персонажа",
	["BINDING_NAME_TRP3_TOOLBAR_TOGGLE"] = "Отображение панели инструментов",
	["BLIZZARD_NAMEPLATES_MODULE_DESCRIPTION"] = "Позволяет кастомизацию стандартного отображения имён Близзард.",
	["BLIZZARD_NAMEPLATES_MODULE_NAME"] = "Отображение имён Близзард",
	["BROADCAST_10"] = "Вы уже находитесь больше, чем в 10 каналах. TRP3 не будет пытаться присоединиться к техническому каналу, но вы не сможете больше использовать некоторые функции аддона, к примеру поиск игроков на карте. ",
	["BROADCAST_OFFLINE_DISABLED"] = "Передача была отключена.",
	["BW_COLOR_CODE"] = "Цветовой код",
	["BW_COLOR_CODE_ALERT"] = "Некорректный 16-ричный код!",
	["BW_COLOR_CODE_TT"] = "Здесь можно вставить 6 цифр 16-ричного цветового кода и нажать Enter.",
	["BW_COLOR_PRESET_DELETE"] = "Удалить заготовку %s ",
	["BW_COLOR_PRESET_RENAME"] = "Переименовать заготовку %s",
	["BW_COLOR_PRESET_SAVE"] = "Сохранить текущий цвет",
	["BW_COLOR_PRESET_TITLE"] = "Заготовленные цвета",
	["BW_CUSTOM_NAME"] = "Пользовательский цвет имени",
	["BW_CUSTOM_NAME_TITLE"] = "Имя (Опционально)",
	["BW_CUSTOM_NAME_TT"] = "Вы можете дать имя пользовательскому цвету при сохранении. Если оставить поле пустым, вместо имени будет использован соответствующий шестидесятеричный цветовой код.",
	["CL_COMPANION_PROFILE"] = "Профиль спутника",
	["CL_CONTENT_SIZE"] = "Размер: %s",
	["CL_DIRECTORY_COMPANION_PROFILE"] = "Каталог профилей спутников",
	["CL_DIRECTORY_PLAYER_PROFILE"] = "Каталог профилей персонажей",
	["CL_DOWNLOADING"] = "Загрузка:",
	["CL_EXPIRED"] = "Время действия ссылки истекло.",
	["CL_GLANCE"] = "На первый взгляд",
	["CL_IMPORT_COMPANION"] = "Импорт профиля спутника.",
	["CL_IMPORT_GLANCE"] = "Импорт \"на первый взгляд\"",
	["CL_IMPORT_PROFILE"] = "Импорт профиля",
	["CL_MAKE_IMPORTABLE"] = "Сделать импортируемым",
	["CL_MAKE_IMPORTABLE_BUTTON_TEXT"] = "Сделать импортируемым",
	["CL_MAKE_IMPORTABLE_SIMPLER"] = [=[Сделать ссылку на %s импортируемой?

Остальные могут скопировать это и использовать.]=],
	["CL_MAKE_NON_IMPORTABLE"] = "Только для чтения",
	["CL_OPEN_COMPANION"] = "Открыть профиль спутника",
	["CL_OPEN_PROFILE"] = "Открыть профиль",
	["CL_PLAYER_PROFILE"] = "Профиль игрока",
	["CL_REQUESTING_DATA"] = "Запрос информации из %s",
	["CL_SENDING_COMMAND"] = "Отправка команды...",
	["CL_SENT_BY"] = "Ссылка отправлена: %s",
	["CL_TOOLTIP"] = "Создать ссылку для чата",
	["CL_TYPE"] = "TRP3 ссылка: %s",
	["CL_VERSIONS_DIFFER"] = [=[Эта ссылка сгенерирована в другой версии Total RP 3.

Импорт содержимого из другой версии может вызвать проблемы в случае несовместимости. Вы желаете продолжить?]=],
	["CM_ACTIONS"] = "Действия",
	["CM_ALT"] = "Alt",
	["CM_APPLY"] = "Применить",
	["CM_BLACK"] = "Черный",
	["CM_BLUE"] = "Синий",
	["CM_CANCEL"] = "Отмена",
	["CM_CENTER"] = "Центр",
	["CM_CLASS_DEATHKNIGHT"] = "Рыцарь Смерти",
	["CM_CLASS_DEMONHUNTER"] = "Охотник на Демонов",
	["CM_CLASS_DRUID"] = "Друид",
	["CM_CLASS_EVOKER"] = "Пробудитель",
	["CM_CLASS_HUNTER"] = "Охотник",
	["CM_CLASS_MAGE"] = "Маг",
	["CM_CLASS_MONK"] = "Монах",
	["CM_CLASS_PALADIN"] = "Паладин",
	["CM_CLASS_PRIEST"] = "Жрец",
	["CM_CLASS_ROGUE"] = "Разбойник",
	["CM_CLASS_SHAMAN"] = "Шаман",
	["CM_CLASS_UNKNOWN"] = "Неизвестно",
	["CM_CLASS_WARLOCK"] = "Чернокнижник",
	["CM_CLASS_WARRIOR"] = "Воин",
	["CM_CLICK"] = "Клик",
	["CM_COLOR"] = "Цвет",
	["CM_CTRL"] = "Ctrl",
	["CM_CYAN"] = "Бирюзовый",
	["CM_DELETE"] = "Удалить",
	["CM_DOUBLECLICK"] = "Двойной клик",
	["CM_DRAGDROP"] = "Перетащить",
	["CM_EDIT"] = "Редактировать",
	["CM_GREEN"] = "Зелёный",
	["CM_GREY"] = "Серый",
	["CM_IC"] = "IC (в роли)",
	["CM_ICON"] = "Значок",
	["CM_IMAGE"] = "Изображение",
	["CM_L_CLICK"] = "ЛКМ",
	["CM_LEFT"] = "Влево",
	["CM_LINK"] = "Ссылка",
	["CM_LOAD"] = "Загрузить",
	["CM_M_CLICK"] = "СКМ",
	["CM_MOVE_DOWN"] = "Сдвинуть вниз",
	["CM_MOVE_UP"] = "Сдвинуть вверх",
	["CM_NAME"] = "Имя",
	["CM_OOC"] = "OOC (вне роли)",
	["CM_OPEN"] = "Открыть",
	["CM_ORANGE"] = "Оранжевый",
	["CM_PINK"] = "Розовый",
	["CM_PLAY"] = "Играть",
	["CM_PURPLE"] = "Фиолетовый",
	["CM_R_CLICK"] = "ПКМ",
	["CM_RED"] = "Красный",
	["CM_REMOVE"] = "Убрать",
	["CM_RESET"] = "Сбросить",
	["CM_RESIZE"] = "Изменить размер",
	["CM_RESIZE_TT"] = "Потяните для изменения размера окна.",
	["CM_RIGHT"] = "Вправо",
	["CM_SAVE"] = "Сохранить",
	["CM_SELECT"] = "Выбрать",
	["CM_SHIFT"] = "Shift",
	["CM_SHOW"] = "Показать",
	["CM_STOP"] = "Остановить",
	["CM_TWEET"] = "Отправить твит",
	["CM_TWEET_PROFILE"] = "Показать ссылку профиля",
	["CM_UNKNOWN"] = "Неизвестно",
	["CM_VALUE"] = "Значение",
	["CM_WHITE"] = "Белый",
	["CM_YELLOW"] = "Жёлтый",
	["CO_ADVANCED_BROADCAST"] = "Канал чата",
	["CO_ADVANCED_BROADCAST_CHANNEL_ALWAYS_LAST"] = "Переносить канал в конец списка",
	["CO_ADVANCED_BROADCAST_CHANNEL_ALWAYS_LAST_TT"] = "Данная опция удостоверит то что общий канал чата всегда будет последним каналом в вашем списке каналов.",
	["CO_ADVANCED_LANGUAGE_WORKAROUND"] = "Разрешить обход сброса языка.",
	["CO_ADVANCED_LANGUAGE_WORKAROUND_TT"] = "С патча 8.0.1 игра меняет ваш выбранный язык на язык вашей фракции после каждого загрузочного экрана. Это решение позволит восстанавливать выбранный язык обратно после экрана загрузки.",
	["CO_ADVANCED_LANGUAGES"] = "Языки",
	["CO_ADVANCED_LANGUAGES_REMEMBER"] = "Запомнить последний используемый язык",
	["CO_ADVANCED_LANGUAGES_REMEMBER_TT"] = "Total RP 3 запомнит, какой язык вы использовали перед выходом из игры и автоматически будет использовать его при следующем заходе в игру. ",
	["CO_ADVANCED_SETTINGS"] = "Расширенные настройки",
	["CO_ADVANCED_SETTINGS_MENU_NAME"] = "Расширенные",
	["CO_ADVANCED_SETTINGS_POPUP"] = [=[Вы вошли в раздел расширенных настроек.

Пожалуйста, помните о том, что изменение любых параметров может нарушить правильную работу аддона. Используйте это меню на свой страх и риск.]=],
	["CO_ADVANCED_SETTINGS_RESET"] = "Сбросить расширенные настройки",
	["CO_ADVANCED_SETTINGS_RESET_TT"] = "Сбросить все расширенные настройки до умолчания. Используйте эту функцию, если у вас появились какие-либо затруднения после внесения изменений в настройки.",
	["CO_ANCHOR_BOTTOM"] = "Внизу",
	["CO_ANCHOR_BOTTOM_LEFT"] = "Внизу слева",
	["CO_ANCHOR_BOTTOM_RIGHT"] = "Внизу справа",
	["CO_ANCHOR_CURSOR"] = "Показывать на курсоре",
	["CO_ANCHOR_LEFT"] = "Слева",
	["CO_ANCHOR_RIGHT"] = "Справа",
	["CO_ANCHOR_TOP"] = "Вверху",
	["CO_ANCHOR_TOP_LEFT"] = "Слева вверху",
	["CO_ANCHOR_TOP_RIGHT"] = "Справа вверху",
	["CO_CHAT"] = "Настройки чата",
	["CO_CHAT_DISABLE_OOC"] = "Отключить кастомизацию вне отыгрыша",
	["CO_CHAT_DISABLE_OOC_TT"] = "Отключить всю кастомизацию чата Total RP 3 (имена, обнаружение эмоций, речь НИП и прочее) когда персонаж находится вне отыгрыша.",
	["CO_CHAT_INCREASE_CONTRAST"] = "Увеличить цветовой контраст",
	["CO_CHAT_INSERT_FULL_RP_NAME"] = "Вставить ролевые имена при шифт+клик",
	["CO_CHAT_INSERT_FULL_RP_NAME_TT"] = [=[Вставка полного ролевого имени персонажа при нажатии shift+клик на его имени в чате. 

(Когда эта функция включена, вы можете нажать alt+shift+клик на имени персонажа и вставить его стандартное имя вместо ролевого.)]=],
	["CO_CHAT_MAIN"] = "Основные настройки чата",
	["CO_CHAT_MAIN_COLOR"] = "Использовать нестандартные цвета имен",
	["CO_CHAT_MAIN_EMOTE"] = "Обнаружение эмоций",
	["CO_CHAT_MAIN_EMOTE_PATTERN"] = "Шаблон обнаружения эмоций",
	["CO_CHAT_MAIN_EMOTE_USE"] = "Использовать обнаружение эмоций",
	["CO_CHAT_MAIN_EMOTE_YELL"] = "Скрыть эмоции /крик",
	["CO_CHAT_MAIN_EMOTE_YELL_TT"] = "Не показывать *эмоция* или <эмоция> в канале /крик",
	["CO_CHAT_MAIN_NAMING"] = "Метод именования",
	["CO_CHAT_MAIN_NAMING_1"] = "Оставить первоначальные имена",
	["CO_CHAT_MAIN_NAMING_2"] = "Использовать свои имена",
	["CO_CHAT_MAIN_NAMING_3"] = "Имя + Фамилия",
	["CO_CHAT_MAIN_NAMING_4"] = "Короткий титул + имя + фамилия",
	["CO_CHAT_MAIN_NPC"] = "Обнаружение речи НИПов",
	["CO_CHAT_MAIN_NPC_PREFIX"] = "Шаблон обнаружения речи НИПов",
	["CO_CHAT_MAIN_NPC_PREFIX_TT"] = [=[Если фраза в чате с этим префиксом будет сказана в канале /эмоция, она будет распознана как фраза НИПа.

|cff00ff00By default : "|| "
(без кавычек" и с пробелом после разделительной линии)]=],
	["CO_CHAT_MAIN_NPC_USE"] = "Использовать обнаружение речи НИПов.",
	["CO_CHAT_MAIN_OOC"] = "Обнаружение персонажей вне отыгрыша",
	["CO_CHAT_MAIN_OOC_COLOR"] = "Цвет \"вне отыгрыша\"",
	["CO_CHAT_MAIN_OOC_PATTERN"] = "Шаблон обнаружения \"вне отыгрыша\"",
	["CO_CHAT_MAIN_OOC_USE"] = "Использовать обнаружение \"вне отыгрыша\"",
	["CO_CHAT_MAIN_SPEECH"] = "Обнаружение речи",
	["CO_CHAT_MAIN_SPEECH_USE"] = "Использовать обнаружение речи",
	["CO_CHAT_MAIN_SPEECH_USE_TT"] = "Текст в кавычках будет иметь тот же цвет какой был бы при использовании /сказать.",
	["CO_CHAT_NPCSPEECH_REPLACEMENT"] = "Кастомизировать имя компаньона в речи НИП",
	["CO_CHAT_NPCSPEECH_REPLACEMENT_TT"] = "Если имя компаньона есть в речи НИП, оно будет окрашено и его иконка будет отображаться согласно от ваших настроек выше.",
	["CO_CHAT_REMOVE_REALM"] = "Не отображать название мира в именах персонажей",
	["CO_CHAT_SHOW_OOC"] = "Показать индикатор Вне Роли",
	["CO_CHAT_USE"] = "Используемые каналы чата",
	["CO_CHAT_USE_ICONS"] = "Отображать значки игроков",
	["CO_CHAT_USE_SAY"] = "Канал /сказать",
	["CO_CONFIGURATION"] = "Настройки",
	["CO_CURSOR_DISABLE_OOC"] = "Отключить, пока статус \"Вне отыгрыша\" активен",
	["CO_CURSOR_DISABLE_OOC_TT"] = "Отключить модификации курсора, пока установлен статус персонажа | cffccccccВне отыгрыша | r.",
	["CO_CURSOR_MODIFIER_KEY"] = "Клавиша-модификатор",
	["CO_CURSOR_MODIFIER_KEY_TT"] = "Требует зажатия клавиши-модификатора при правом клике по игроку для избежания случайных кликов.",
	["CO_CURSOR_RIGHT_CLICK"] = "ПКМ чтобы открыть профиль.",
	["CO_CURSOR_RIGHT_CLICK_TT"] = [=[ПКМ на игрока в мире, чтобы открыть профиль, если он создан им.

|TInterface\Cursor\WorkOrders:25|t Эта иконка будет прикреплена к курсору, если у игрока есть профиль, и вы можете щелкнуть на нем ПКМ.

|cffccccccNote: Эта функция отключена во время боя.|r]=],
	["CO_CURSOR_TITLE"] = "Взаимодействие с курсором",
	["CO_GENERAL"] = "Основное",
	["CO_GENERAL_BROADCAST"] = "Использовать общий канал чата",
	["CO_GENERAL_BROADCAST_C"] = "Название общего канала чата",
	["CO_GENERAL_BROADCAST_TT"] = "Общий канал чата нужен для многих вещей. Отключив его, вы отключите такие опции как нахождение на карте, локальные звуки, тайники и доступ к указателям...",
	["CO_GENERAL_CHANGELOCALE_ALERT"] = [=[Для смены языка на %s необходимо перезагрузить интерфейс.

В случае отказа язык будет изменен при следующем входе в игру.]=],
	["CO_GENERAL_COM"] = "Общение",
	["CO_GENERAL_DEFAULT_COLOR_PICKER"] = "Выбор цвета по умолчанию",
	["CO_GENERAL_DEFAULT_COLOR_PICKER_TT"] = "Активируйте, чтобы всегда использовать набор цветов по умолчанию. Полезно, если вы используете аддон выбора цвета.",
	["CO_GENERAL_HEAVY"] = "Предупреждать о перегруженном профиле",
	["CO_GENERAL_HEAVY_TT"] = "Оповестить, когда общий объем вашего профиля превысит разумное значение.",
	["CO_GENERAL_LOCALE"] = "Язык аддона",
	["CO_GENERAL_MISC"] = "Разное",
	["CO_GENERAL_NEW_VERSION"] = "Оповещение об обновлениях",
	["CO_GENERAL_NEW_VERSION_TT"] = "Оповестить, когда будет доступна новая версия аддона.",
	["CO_GENERAL_RESET_CUSTOM_COLORS"] = "Сбросить пользовательские цвета",
	["CO_GENERAL_RESET_CUSTOM_COLORS_TT"] = "Удаляет все пользовательские цвета, сохраненные в наборе.",
	["CO_GENERAL_RESET_CUSTOM_COLORS_WARNING"] = "Вы уверены, что делаете удалить все сохраненные в наборе пользовательские цвета?",
	["CO_GENERAL_TT_SIZE"] = "Размер текста подсказок",
	["CO_GENERAL_UI_ANIMATIONS"] = "Анимация интерфейса",
	["CO_GENERAL_UI_ANIMATIONS_TT"] = "Включить анимацию интерфейса.",
	["CO_GENERAL_UI_SOUNDS"] = "Звуки интерфейса",
	["CO_GENERAL_UI_SOUNDS_TT"] = "Включить звуки интерфейса (при открытии окон, переключении вкладок, нажатии кнопок).",
	["CO_GLANCE_LOCK"] = "Закрепить панель",
	["CO_GLANCE_LOCK_TT"] = "Запретить перемещение панели",
	["CO_GLANCE_MAIN"] = "Панель \"На первый взгляд\"",
	["CO_GLANCE_PRESET_TRP2"] = "Использовать позиционирование в стиле Total RP 2",
	["CO_GLANCE_PRESET_TRP2_BUTTON"] = "Использовать",
	["CO_GLANCE_PRESET_TRP2_HELP"] = "Ярлык для установки панели в стиле TRP2: справа от рамки цели WoW.",
	["CO_GLANCE_PRESET_TRP3"] = "Использовать позиционирование в стиле Total RP 3",
	["CO_GLANCE_PRESET_TRP3_HELP"] = "Ярлык для установки панели в стиле TRP3: снизу от рамки цели TRP3.",
	["CO_GLANCE_RESET_TT"] = "Сбросить позиционирование панели вниз влево от закрепленной рамки.",
	["CO_GLANCE_TT_ANCHOR"] = "Точка закрепления подсказок",
	["CO_HIDE_EMPTY_MAP_BUTTON"] = "Скрыть когда нет доступных сканов",
	["CO_LOCATION"] = "Настройки местоположения",
	["CO_LOCATION_ACTIVATE"] = "Активировать местоположение персонажа",
	["CO_LOCATION_ACTIVATE_TT"] = "Активирование местоположение персонажа позволит Вам сканировать и обнаруживать на карте других пользователей Total RP, и так же позволит другим пользователям найти Вас.",
	["CO_LOCATION_DISABLE_CLASSIC_PVP"] = "Отключить локацию когда включен PvP режим",
	["CO_LOCATION_DISABLE_CLASSIC_PVP_TT"] = "Вы не будете реагировать на запросы локации от других игроков когда вы отмечены для PvP. Эта опция частично полезна для избежания злоупотребления системы локации для вашего отслеживания.",
	["CO_LOCATION_DISABLE_OOC"] = "Отключить местоположение персонажа вне отыгрыша",
	["CO_LOCATION_DISABLE_OOC_TT"] = "Другие игроки не смогут отследить Ваше местоположение с помощью сканирования карты, пока активен статус \"Вне отыгрыша\".",
	["CO_LOCATION_DISABLE_PVP"] = "Отключить местоположение персонажа пока активен режим PvP",
	["CO_LOCATION_DISABLE_PVP_TT"] = [=[Другие игроки не смогут отследить Ваше местоположение с помощью сканирования карты, пока активен режим PvP. 

Эта опция будет полезна для PvP-серверов, где игроки из другой фракции могут злоупотреблять системой определения местоположения, чтобы отслеживать Вас.]=],
	["CO_LOCATION_DISABLE_WAR_MODE"] = "Не делиться местоположением в Режиме Войны",
	["CO_LOCATION_DISABLE_WAR_MODE_TT"] = [=[Вы не будете отвечать на запросы местоположения от других игроков когда у вас включен Режим Войны и вы не находитесь в |cff69CCF0Святилище|r.

Данная опция отчасти полезна для избежания злоупотребления системой местоположения для вашего отслеживания.]=],
	["CO_LOCATION_SHOW_DIFFERENT_WAR_MODES"] = "Отображать игроков в другом Режиме Войны",
	["CO_LOCATION_SHOW_DIFFERENT_WAR_MODES_TT"] = "Игроки, находящиеся в данный момент в локации, но с Режимом Войны, отличным от вашего будут показываться на карте с пониженной прозрачностью и особой иконкой во всплывающем окне.",
	["CO_MAP_BUTTON"] = "Кнопка сканирования карты",
	["CO_MAP_BUTTON_POS"] = "Сканирование кнопки якоря у карты",
	["CO_MINIMAP_BUTTON"] = "Кнопка у миникарты",
	["CO_MINIMAP_BUTTON_FRAME"] = "Рамка для закрепления",
	["CO_MINIMAP_BUTTON_RESET"] = "Сбросить позицию",
	["CO_MINIMAP_BUTTON_RESET_BUTTON"] = "Сбросить",
	["CO_MINIMAP_BUTTON_SHOW_HELP"] = [=[Если вы используете другой аддон для того, чтобы выводить кнопку Total RP3 на миникарту (например, FuBar, Titan, Bazooka), вы можете убрать кнопку с миникарты. 

|cff00ff00Помните: Вы всегда можете открыть Total RP3 используя /trp3 |r]=],
	["CO_MINIMAP_BUTTON_SHOW_TITLE"] = "Показать кнопку на мини-карте",
	["CO_MODULES"] = "Статус модулей",
	["CO_MODULES_DISABLE"] = "Отключить модуль",
	["CO_MODULES_ENABLE"] = "Включить модуль",
	["CO_MODULES_ID"] = "ID модуля: %s",
	["CO_MODULES_SHOWERROR"] = "Показать ошибку",
	["CO_MODULES_STATUS"] = "Статус: %s",
	["CO_MODULES_STATUS_0"] = "Отключены зависимости",
	["CO_MODULES_STATUS_1"] = "Загружен",
	["CO_MODULES_STATUS_2"] = "Отключен",
	["CO_MODULES_STATUS_3"] = "Требуется обновить Total RP 3",
	["CO_MODULES_STATUS_4"] = "Ошибка инициализации",
	["CO_MODULES_STATUS_5"] = "Ошибка запуска",
	["CO_MODULES_TT_DEP"] = "%s- %s (версия %s)|r",
	["CO_MODULES_TT_DEPS"] = "Зависимости",
	["CO_MODULES_TT_ERROR"] = [=[ 	

|cffff0000Ошибка:|r
%s]=],
	["CO_MODULES_TT_NONE"] = "Нет зависимостей",
	["CO_MODULES_TT_TRP"] = "%sДля Total RP 3 версии %s и выше.|r",
	["CO_MODULES_TUTO"] = [=[Модуль — независимая опция, которую можно включить или отключить.

Возможные статусы:
|cff00ff00Загружен:|r Модуль включен и загружен.
|cff999999Отключен:|r Модуль отключен.
|cffff9900Отключены зависимости:|r Некоторые зависимости не загружены.
|cffff9900TRP требуется обновление:|r Модулю требуется последняя версия TRP3.
|cffff0000Ошибка инициализации или запуска:|r Порядок загрузки модуля нарушен. Модуль может создавать ошибки!

|cffff9900При отключении модуля необходима перегрузка интерфейса.]=],
	["CO_MODULES_VERSION"] = "Версия: %s",
	["CO_MSP"] = "Протокол Mary Sue",
	["CO_MSP_T3"] = "Использовать только шаблон 3",
	["CO_MSP_T3_TT"] = "Шаблон 3 всегда будет использоваться для совместимости с протоколом, даже если вы выберите другой шаблон \"Описание\".",
	["CO_REGISTER"] = "Настройки реестра",
	["CO_REGISTER_ABOUT_H1_SIZE"] = "Размер текста заголовка 1",
	["CO_REGISTER_ABOUT_H1_SIZE_TT"] = "Размер текста между метками {h1}. По умолчанию: %s",
	["CO_REGISTER_ABOUT_H2_SIZE"] = "Размер текста заголовка 2",
	["CO_REGISTER_ABOUT_H2_SIZE_TT"] = "Размер текста между метками {h2}. По умолчанию: %s",
	["CO_REGISTER_ABOUT_H3_SIZE"] = "Размер текста заголовка 3",
	["CO_REGISTER_ABOUT_H3_SIZE_TT"] = "Размер текста между метками {h3}. По умолчанию: %s",
	["CO_REGISTER_ABOUT_P_SIZE"] = "Размер текста параграфа",
	["CO_REGISTER_ABOUT_P_SIZE_TT"] = "Размер текста вне меток заголовков. По умолчанию: %s",
	["CO_REGISTER_ABOUT_SETTINGS"] = "Настройки \"О персонаже\"",
	["CO_REGISTER_ABOUT_VOTE"] = "Использовать систему голосования",
	["CO_REGISTER_ABOUT_VOTE_TT"] = "Включает систему голосования, которая позволяет оценивать (\"нравится\" или \"не нравится\") описания других игроков и разрешает оценивать ваше описание другим.",
	["CO_REGISTER_AUTO_ADD"] = "Автоматически добавлять новых игроков",
	["CO_REGISTER_AUTO_ADD_TT"] = "Автоматически добавлять новых игроков в реестр.",
	["CO_REGISTER_AUTO_PURGE"] = "Автоматическая очистка профилей",
	["CO_REGISTER_AUTO_PURGE_0"] = "Отключить систему очистки",
	["CO_REGISTER_AUTO_PURGE_1"] = "Через %s дней",
	["CO_REGISTER_AUTO_PURGE_TT"] = [=[Автоматическая очистка списка профилей персонажей, которых Вы не встречали в течение определенного времени. Вы можете настроить время хранения профилей в списках перед удалением.

| cff00ff00 Обратите внимание, что профили персонажей, имеющие обозначенные в модификации отношения с Вашим персонажем, никогда не будут удалены.

| cffff9900 В WoW есть ошибка, из-за которой теряются все сохраненные профили, когда те достигают определенного порога. Мы настоятельно рекомендуем избегать отключения системы очистки.]=],
	["CO_SANITIZER"] = "Очищать входящие профили",
	["CO_TARGETFRAME"] = "Настройки рамки цели",
	["CO_TARGETFRAME_ICON_SIZE"] = "Размер значков",
	["CO_TARGETFRAME_USE"] = "Показать условия",
	["CO_TARGETFRAME_USE_1"] = "Всегда",
	["CO_TARGETFRAME_USE_2"] = "Только когда \"в отыгрыше\"",
	["CO_TARGETFRAME_USE_3"] = "Никогда (Отключено)",
	["CO_TARGETFRAME_USE_TT"] = "Определяет при каких условиях будет показана рамка цели при выборе цели.",
	["CO_TOOLBAR"] = "Настройки рамок",
	["CO_TOOLBAR_CONTENT"] = "Настройки панели инструментов",
	["CO_TOOLBAR_CONTENT_CAPE"] = "Отображение плаща",
	["CO_TOOLBAR_CONTENT_HELMET"] = "Отображение шлема",
	["CO_TOOLBAR_CONTENT_RPSTATUS"] = "Статус персонажа (Отыгрываю/Не отыгрываю)",
	["CO_TOOLBAR_CONTENT_STATUS"] = "Статус игрока (Отсутствует/Не беспокоить)",
	["CO_TOOLBAR_HIDE_TITLE"] = "Скрыть заголовок панели инструментов",
	["CO_TOOLBAR_HIDE_TITLE_HELP"] = "Скрывает заголовок, показанный над панелью инструментов.",
	["CO_TOOLBAR_ICON_SIZE"] = "Размер значков",
	["CO_TOOLBAR_MAX"] = "Максимум иконок в строке",
	["CO_TOOLBAR_MAX_TT"] = "Чтобы панель отображалась вертикально, задайте значение 1!",
	["CO_TOOLBAR_SHOW_ON_LOGIN"] = "Показать панель инструментов при входе",
	["CO_TOOLBAR_SHOW_ON_LOGIN_HELP"] = "Если вы не хотите, чтобы панель инструментов отображалась при входе, вы можете отключить эту опцию.",
	["CO_TOOLTIP"] = "Настройки подсказок",
	["CO_TOOLTIP_ANCHOR"] = "Точка закрепления",
	["CO_TOOLTIP_ANCHORED"] = "Закрепленная рамка",
	["CO_TOOLTIP_CHARACTER"] = "Описание персонажей",
	["CO_TOOLTIP_CLIENT"] = "Показать клиент",
	["CO_TOOLTIP_COLOR"] = "Показать пользовательские цвета",
	["CO_TOOLTIP_COMBAT"] = "Скрывать в бою",
	["CO_TOOLTIP_COMMON"] = "Общие настройки",
	["CO_TOOLTIP_CONTRAST"] = "Увеличить цветовой контраст",
	["CO_TOOLTIP_CONTRAST_TT"] = "Включите эту опцию, чтобы Total RP 3 мог изменять пользовательские цвета, чтобы сделать текст более читаемым, если цвет слишком темный.",
	["CO_TOOLTIP_CROP_TEXT"] = "Обрезать необоснованно длинные тексты",
	["CO_TOOLTIP_CROP_TEXT_TT"] = [=[Ограничивает количество символов в каждом поле всплывающего окна, дабы избежать излишне длинных текстов и возможных неполадок при отображении.

|cfffff569Детали ограничения: 
Имя: 100 символов 
Звание: 150 символов 
Раса: 50 символов 
Класс: 50 символов|r]=],
	["CO_TOOLTIP_CURRENT"] = "Показывать текст \"текущее\"",
	["CO_TOOLTIP_CURRENT_LINES"] = "Максимальное количество разрывов строки в \"Текущее\"",
	["CO_TOOLTIP_CURRENT_SIZE"] = "Максимальная длина текста \"текущее\"",
	["CO_TOOLTIP_FT"] = "Показывать полный титул",
	["CO_TOOLTIP_GUILD"] = "Показывать информацию о гильдии",
	["CO_TOOLTIP_HEALTH"] = "Показывать здоровье",
	["CO_TOOLTIP_HEALTH_BOTH"] = "Число + Процент",
	["CO_TOOLTIP_HEALTH_DISABLED"] = "Отключено",
	["CO_TOOLTIP_HEALTH_NUMBER"] = "Число",
	["CO_TOOLTIP_HEALTH_PERCENT"] = "Процент",
	["CO_TOOLTIP_HIDE_IN_INSTANCE"] = "Скрывать в подземельях",
	["CO_TOOLTIP_HIDE_ORIGINAL"] = "Скрывать подсказки игры",
	["CO_TOOLTIP_ICONS"] = "Показывать иконки",
	["CO_TOOLTIP_IN_CHARACTER_ONLY"] = "Скрвать когда вне роли",
	["CO_TOOLTIP_MAINSIZE"] = "Размер основного шрифта",
	["CO_TOOLTIP_NO_FADE_OUT"] = "Спрятать мгновенно вместо затухания",
	["CO_TOOLTIP_NOTIF"] = "Показывать уведомления",
	["CO_TOOLTIP_NOTIF_TT"] = "Строка уведомлений — строка, содержащая версию клиента, метку непрочитанного описания и метку \"На первый взгляд\".",
	["CO_TOOLTIP_OWNER"] = "Показать владельца",
	["CO_TOOLTIP_PETS"] = "Подсказки спутников",
	["CO_TOOLTIP_PETS_INFO"] = "Показать информацию о спутнике",
	["CO_TOOLTIP_PREFERRED_OOC_INDICATOR"] = "Предпочитаемый индикатор \"Вне Роли\"",
	["CO_TOOLTIP_PREFERRED_OOC_INDICATOR_ICON"] = "Значок:",
	["CO_TOOLTIP_PREFERRED_OOC_INDICATOR_TEXT"] = "Текст:",
	["CO_TOOLTIP_PROFILE_ONLY"] = "Использовать, только если у цели есть профиль",
	["CO_TOOLTIP_PRONOUNS"] = "Показывать местоимения",
	["CO_TOOLTIP_RACE"] = "Показывать расу, класс и уровень",
	["CO_TOOLTIP_REALM"] = "Показывать игровой мир",
	["CO_TOOLTIP_RELATION"] = "Показывать цвет отношений",
	["CO_TOOLTIP_RELATION_TT"] = "Окрасить рамку подсказки персонажа в цвет, характеризующий отношение.",
	["CO_TOOLTIP_SPACING"] = "Показывать интервалы",
	["CO_TOOLTIP_SPACING_TT"] = "Располагает интервалы для облегчения подсказки, в стиле MyRolePlay.",
	["CO_TOOLTIP_SUBSIZE"] = "Размер вторичного шрифта",
	["CO_TOOLTIP_TARGET"] = "Показать цель",
	["CO_TOOLTIP_TERSIZE"] = "Размер третичного шрифта",
	["CO_TOOLTIP_TITLE"] = "Показывать заголовок",
	["CO_TOOLTIP_USE"] = "Использовать подсказку персонажей/спутников",
	["CO_TOOLTIP_ZONE"] = "Показывать игровую зону",
	["CO_TOOLTIP_ZONE_TT"] = "Будет отображаться только если цель не в той же игровой зоне что и вы.",
	["CO_UI_RELOAD_WARNING"] = [=[Необходимо перезагрузить интерфейс, чтобы изменения вступили в силу.

Вы хотите сделать это сейчас?]=],
	["CO_WIM"] = "|cffff9900Каналы шепота отключены.",
	["CO_WIM_TT"] = "Вы используете аддон |cff00ff00WIM|r, для совместимости отключена обработка каналов шепота отключена.",
	["COM_LIST"] = "Список команд",
	["COM_RESET_RESET"] = "Расположение окон сброшено!",
	["COM_RESET_USAGE"] = "Использование: |cff00ff00/trp3 сброс фреймов|r сбросить расположение окон.",
	["COM_SWITCH_USAGE"] = "Использование: |cff00ff00/trp3 вкл/выкл главное окно|r чтобы показать/скрыть главное окно или |cff00ff00/trp3 вкл/выкл панель инструментов|r чтобы показать/скрыть панель инструментов",
	["COPY_SYSTEM_MESSAGE"] = "Скопировано в буфер обмена.",
	["CREDITS_DISCORD_LINK_TEXT"] = "Присоединяйтесь к нам в Discord",
	["CREDITS_GUILD_NAME"] = "<%1$s>",
	["CREDITS_THANK_YOU_ROLE_1"] = "Лидер Проекта",
	["CREDITS_THANK_YOU_ROLE_2"] = "Автор",
	["CREDITS_THANK_YOU_ROLE_3"] = "Разработчик",
	["CREDITS_THANK_YOU_ROLE_4"] = "Руководитель Сообщества",
	["CREDITS_THANK_YOU_ROLE_5"] = "Талисман",
	["CREDITS_THANK_YOU_SECTION_1"] = "{h1:c}Total RP 3{/h1}",
	["CREDITS_THANK_YOU_SECTION_10"] = [=[{col:ffffff}Спасибо нашим активным участникам сообщества в Discord:{/col}
]=],
	["CREDITS_THANK_YOU_SECTION_2"] = [=[{h2}%1$s Создатели{/h2}

]=],
	["CREDITS_THANK_YOU_SECTION_3"] = [=[{h2}%1$s Остальная Команда{/h2}

]=],
	["CREDITS_THANK_YOU_SECTION_4"] = [=[{h2}%1$s Упоминания{/h2}

]=],
	["CREDITS_THANK_YOU_SECTION_5"] = [=[{col:ffffff}Логотип и иконка кнопки на миникарте:{/col} %1$s

]=],
	["CREDITS_VERSION_TEXT"] = "Версия %s",
	["CREDITS_WEBSITE_LINK_TEXT"] = "Вебсайт",
	["DB_ABOUT"] = "О Total RP 3",
	["DB_HTML_GOTO"] = "Кликните, чтобы открыть",
	["DB_MORE"] = "Больше дополнений",
	["DB_NEW"] = "Что нового?",
	["DB_STATUS"] = "Статус",
	["DB_STATUS_CURRENTLY"] = "Текущее (Отыгрываю)",
	["DB_STATUS_CURRENTLY_COMMON"] = "Эти статусы будут показаны в подсказке вашего персонажа. Делайте их краткими, так как |cffff9900по умолчанию игроки с TRP3 будут видеть только первые 140 символов!",
	["DB_STATUS_CURRENTLY_OOC"] = "Другая информация (Вне отыгрыша)",
	["DB_STATUS_CURRENTLY_OOC_TT"] = "Здесь вы можете указать что-то важное о вас, как игроке, или что-нибудь еще вне отыгрыша.",
	["DB_STATUS_CURRENTLY_TT"] = "Здесь вы можете указать что-нибудь важное о вашем персонаже.",
	["DB_STATUS_ICON_ITEM"] = "%1$s %2$s",
	["DB_STATUS_LC"] = "Язык ролевой игры",
	["DB_STATUS_LC_DEFAULT"] = "По умолчанию (%1$s)",
	["DB_STATUS_LC_TT"] = "Устанавливает ваш предпочитаемый язык ролевой игры. Эта информация будет доступна другим пользователям совместимых ролевых аддонов.  |cffff9900Заметка:|r Это |cffff0000не|r меняет язык интерфейса Total RP 3. Данная опция может быть найдена на странице |cfffff569Расширенных Настроек|r.",
	["DB_STATUS_RP"] = "Статус персонажа",
	["DB_STATUS_RP_EXP"] = "Опытный ролевик",
	["DB_STATUS_RP_EXP_TT"] = [=[Показывает, что вы опытный ролевик.
Не добавляет никаких специальных иконок в вашу подсказку.]=],
	["DB_STATUS_RP_IC"] = "Отыгрываю",
	["DB_STATUS_RP_IC_TT"] = [=[Это значит, что сейчас вы отыгрываете своего персонажа.
Все ваши действия рассматриваются как выполненные вашим персонажем.]=],
	["DB_STATUS_RP_OOC"] = "Вне роли",
	["DB_STATUS_RP_OOC_TT"] = [=[Вы вне роли.
Ваши действия не могут быть связаны с вашим персонажем.]=],
	["DB_STATUS_RP_VOLUNTEER"] = "Волонтёр",
	["DB_STATUS_RP_VOLUNTEER_TT"] = "Если выбрать этот статус, в вашей подсказке отобразится специальная иконка, показывающая ролевикам-новичкам, что Вы хотите помочь им.",
	["DB_STATUS_XP"] = "Статус ролевика",
	["DB_STATUS_XP_BEGINNER"] = "Новичок",
	["DB_STATUS_XP_BEGINNER_TT"] = "Если выбрать этот статус, в вашей подсказке отобразится специальная иконка, показывающая остальным ролевикам, что Вы - новичок.",
	["DB_TUTO_1"] = [=[|cffffff00Статус персонажа|r отображает, находитесь ли Вы в данный момент в отыгрыше.

|cffffff00Статус персонажа|r позволяет указать Ваш опыт в ролевых играх: будь то новичок или ветеран, желающий помочь новобранцам.

|cff00ff00Эта информация будет указана в описании вашего персонажа.]=],
	["DICE_HELP"] = "Бросок или броски кубика, разделенные пробелом. Пример: 1d6, 2d12 3d20 ...",
	["DICE_ROLL"] = "%s Выбрасывает |cffff9900%sx d%s|r|cffcc6600%s|r И получает |cff00ff00%s|r.",
	["DICE_ROLL_T"] = "%s %s бросил |cffff9900%sx d%s|r|cffcc6600%s|r и ему выпало |cff00ff00%s|r.",
	["DICE_TOTAL"] = "%s Итого |cff00ff00%s|r за бросок.",
	["DICE_TOTAL_T"] = "%s %s получил в общей сложности |cff00ff00%s|r за бросок.",
	["DTBK_AFK"] = "Total RP 3 - Отсутствует/DND",
	["DTBK_CLOAK"] = "Total RP 3 - Плащ",
	["DTBK_HELMET"] = "Total RP 3 - Шлем",
	["DTBK_LANGUAGES"] = "Total RP 3 - Языки",
	["DTBK_RP"] = "Total RP 3 - В Роли/Вне Роли",
	["GEN_VERSION"] = "Версия: %s (Сборка %s)",
	["GEN_WELCOME_MESSAGE"] = "Благодарим за использование TotalRP3 (версии %s)! Приятной игры!",
	["KUI_NAMEPLATES_MODULE_DESCRIPTION"] = "Позволяет кастомизацию отображения имён Kui.",
	["KUI_NAMEPLATES_MODULE_NAME"] = "Отображение имён Kui",
	["LANG_CHANGE_CAUSED_REVERT_TO_DEFAULT"] = "Используемый в настоящий моммент язык сменен на язык по умолчанию %s так как вам более не известен выбранный ранее язык %s.",
	["MAP_BUTTON_NO_SCAN"] = "Сканирование недоступно",
	["MAP_BUTTON_SCANNING"] = "Сканирование",
	["MAP_BUTTON_SUBTITLE"] = "Нажмите чтобы показать доступные варианты сканирования",
	["MAP_BUTTON_SUBTITLE_80_DISABLED"] = "Сканирование временно недоступно в виду изменений 8.0.",
	["MAP_BUTTON_SUBTITLE_CONNECTING"] = "Сканирование карты настраивается. Пожалуйста подождите.",
	["MAP_BUTTON_SUBTITLE_OFFLINE"] = "Сканирование карты недоступно в данный момент: %s",
	["MAP_BUTTON_TITLE"] = "Поиск ролевиков на карте",
	["MAP_SCAN_CHAR"] = "Поиск персонажей",
	["MAP_SCAN_CHAR_TITLE"] = "Персонажи",
	["MATURE_FILTER_ADD_TO_WHITELIST"] = "Добавить этот профиль в |cffffffffбелый список взрослых профилей|r",
	["MATURE_FILTER_ADD_TO_WHITELIST_OPTION"] = "Добавить в |cffffffffбелый список взрослых профилей|r",
	["MATURE_FILTER_ADD_TO_WHITELIST_TT"] = "Добавить этот профиль в |cffffffffбелый список взрослых профилей|r и раскрыть взрослый контент находящийся внутри него.",
	["MATURE_FILTER_EDIT_DICTIONARY"] = "Редактировать пользовательский словарь",
	["MATURE_FILTER_EDIT_DICTIONARY_ADD_BUTTON"] = "Добавить",
	["MATURE_FILTER_EDIT_DICTIONARY_ADD_TEXT"] = "Добавить новое слово в словарь",
	["MATURE_FILTER_EDIT_DICTIONARY_BUTTON"] = "Редактировать",
	["MATURE_FILTER_EDIT_DICTIONARY_DELETE_WORD"] = "Удалить это слово из пользовательского словаря",
	["MATURE_FILTER_EDIT_DICTIONARY_EDIT_WORD"] = "Редактировать это слово",
	["MATURE_FILTER_EDIT_DICTIONARY_RESET_BUTTON"] = "Сбросить",
	["MATURE_FILTER_EDIT_DICTIONARY_RESET_TITLE"] = "Сбросить словарь",
	["MATURE_FILTER_EDIT_DICTIONARY_RESET_WARNING"] = "Вы уверены что хотите сбросить словарь? Это опустошит словарь и заполнит его стандартными словами для вашего текущего языка (если доступно).",
	["MATURE_FILTER_EDIT_DICTIONARY_TITLE"] = "Редактор пользовательского словаря",
	["MATURE_FILTER_FLAG_PLAYER"] = "Пометить как взрослый",
	["MATURE_FILTER_FLAG_PLAYER_OPTION"] = "Пометить как контент для взрослых",
	["MATURE_FILTER_OPTION"] = "Фильтровать взрослые профили",
	["MATURE_FILTER_STRENGTH"] = "Степень взрослого фильтра",
	["MATURE_FILTER_TITLE"] = "Фильтр взрослых профилей",
	["MATURE_FILTER_TOOLTIP_WARNING"] = "Взрослый контент",
	["MATURE_FILTER_WARNING_CONTINUE"] = "Продолжить",
	["MATURE_FILTER_WARNING_GO_BACK"] = "Назад",
	["MATURE_FILTER_WARNING_TEXT"] = "Ваша система фильтровки взрослых профилей Total RP 3 включена. Этот профиль был отмечен как содержащий взрослый контент. Вы уверены что вы желаете посмотреть данный профиль?",
	["MATURE_FILTER_WARNING_TITLE"] = "Взрослый контент",
	["MM_SHOW_HIDE_MAIN"] = "Отображение основной рамки",
	["MM_SHOW_HIDE_MOVE"] = "Переместить кнопку",
	["MM_SHOW_HIDE_SHORTCUT"] = "Отображение панели инструментов",
	["MO_ADDON_NOT_INSTALLED"] = "Дополнение %s не установлено, встраивание в Total RP 3 отключено.",
	["MO_CHAT_CUSTOMIZATIONS_DESCRIPTION"] = "Добавить пользовательскую совместимость с аддоном %s, таким образом чтобы сообщения в чате и отображение имён игрока модифицировались аддоном Total RP 3.",
	["MO_TOOLTIP_CUSTOMIZATIONS_DESCRIPTION"] = "Добавить пользовательскую совместимость с аддоном %s, таким образом чтобы предпочтения всплывающих подсказок применялись к всплывающим подсказкам Total RP 3.",
	["NAMEPLATES_CONFIG_ACTIVE_QUERY"] = "Автоматически загружать профили",
	["NAMEPLATES_CONFIG_BLIZZARD_NAME_ONLY"] = "Скрыть полосы в именах |cff449fe0Blizzard|r.",
	["NAMEPLATES_CONFIG_CUSTOMIZE_FULL_TITLES"] = "Показывать полный титул",
	["NAMEPLATES_CONFIG_CUSTOMIZE_HEALTH_COLORS"] = "Показывать пользоватеьские цвета здоровья",
	["NAMEPLATES_CONFIG_CUSTOMIZE_ICONS"] = "Показывать значки",
	["NAMEPLATES_CONFIG_CUSTOMIZE_NAME_COLORS"] = "Показывать пользовательские цвета имени",
	["NAMEPLATES_CONFIG_CUSTOMIZE_NAMES"] = "Показывать пользовательские имена",
	["NAMEPLATES_CONFIG_CUSTOMIZE_ROLEPLAY_STATUS"] = "Показывать индикатор ролевого статуса",
	["NAMEPLATES_CONFIG_CUSTOMIZE_TITLES"] = "Показывать звания",
	["NAMEPLATES_CONFIG_ENABLE_CLASS_COLOR_FALLBACK"] = "Использовать цвет класса по умолчанию",
	["NAMEPLATES_CONFIG_HIDE_NON_ROLEPLAY_UNITS"] = "Скрывать неролевые единицы",
	["NAMEPLATES_CONFIG_ICON_SIZE"] = "Размер иконки",
	["NAMEPLATES_CONFIG_MENU_TITLE"] = "Имена",
	["NAMEPLATES_CONFIG_PAGE_TEXT"] = "Настройки имён",
	["NAMEPLATES_CONFIG_VISIBILITY_HEADER"] = "Настройки отображения",
	["NAMEPLATES_MODULE_NAME"] = "Отображение имён",
	["NEW_VERSION"] = [=[| cff00ff00A доступна новая версия Total RP 3 (v %s).

| cffffff00 Мы настоятельно рекомендуем вам использовать актуальную версию.

Это сообщение будет появляться только один раз за сеанс, его можно отключить в настройках (Общие настройки => Разное).]=],
	["NEW_VERSION_BEHIND"] = "Вы на данный момент отстаёте на %s версия и пропускаете множество исправлений багов и новых возможностей. Другие игроки могут не видеть ваш профиль корректно. Пожалуйста, подумайте обновить аддон.",
	["NEW_VERSION_TITLE"] = "Доступно новое обновление",
	["NPC_TALK_BUTTON_TT"] = "Открыт окно речи НИП позволяющее вам использовать речь и эмоции НИП.",
	["NPC_TALK_CHANNEL"] = "Канал:",
	["NPC_TALK_COMMAND_HELP"] = "Открыть окно речи НИП.",
	["NPC_TALK_ERROR_EMPTY_MESSAGE"] = "Сообщение не может быть пустым.",
	["NPC_TALK_MESSAGE"] = "Сообщение",
	["NPC_TALK_NAME"] = "Имя НИП",
	["NPC_TALK_NAME_TT"] = [=[Вы можете использовать стандартные метки в чате как например %t чтобы вставить имя вашей цели или %f чтобы вставить имя вашей запомненной цели.

Так же вы можете оставить это поле пустым чтобы создавать эмоции без имени НИП в начале.

Добавление имени вашего спутника в [скобках] позволит использовать модифицированные цвет и иконку.]=],
	["NPC_TALK_SAY_PATTERN"] = "говорит:",
	["NPC_TALK_SEND"] = "Отправить",
	["NPC_TALK_TITLE"] = "Речи НИП",
	["NPC_TALK_WHISPER_PATTERN"] = "шепчет:",
	["NPC_TALK_YELL_PATTERN"] = "кричит:",
	["OPTION_DISABLED_TOAST"] = "Опция отключена",
	["OPTION_ENABLED_TOAST"] = "Опция включена",
	["PR_CO_BATTLE"] = "Боевой питомец",
	["PR_CO_COUNT"] = "%s питомцев/средств передвижения привязано к данному профилю.",
	["PR_CO_EMPTY"] = "Профиль спутника отсутствует",
	["PR_CO_MASTERS"] = "Хозяева",
	["PR_CO_MOUNT"] = "Средство Передвижения",
	["PR_CO_NEW_PROFILE"] = "Профиль нового спутника",
	["PR_CO_PET"] = "Питомец",
	["PR_CO_PROFILE_DETAIL"] = "Данный профиль связан с",
	["PR_CO_PROFILE_HELP"] = [=[Профиль содержит всю информацию о |cffffff00"питомце"|r как |cff00ff00персонаже отыгрыша|r.

Профиль спутника может быть привязан к:
- Боевому питомцу |cffff9900(только если он назван)|r
- Питомцу охотника
- Демону чернокнижника
- Элементалю мага
- Вурдалаку рыцаря смерти |cffff9900(см. ниже)|r

Как и профиль персонажа, |cff00ff00профиль спутника|r можно привязать к |cffffff00нескольким питомцам|r, |cffffff00питомца|r можно легко переключать между профилями.


|cffff9900Вурдалаки:|r Так как вурдалак получает новое имя при каждом призывании, Вам необходимо привязать профиль ко всем вариациям имени.]=],
	["PR_CO_PROFILE_HELP2"] = [=[Нажмите, чтобы создать новый профиль спутника.

|cff00ff00Чтобы привязать профиль к питомцу (демону/элементалю/вурдалаку), призовите его, выделите и привяжите к существующему профилю (или создайте новый профиль).|r]=],
	["PR_CO_PROFILEMANAGER_DELETE_WARNING"] = [=[Вы уверены, что хотите удалить профиль спутника %s?
Данное действие нельзя отменить, вся информация TRP3, связанная с данным профилем будет удалена!]=],
	["PR_CO_PROFILEMANAGER_DUPP_POPUP"] = [=[Введите название для нового профиля.
Название не может быть пустым.

Эта копия не изменит список питомцев/транспорта, привязанный к профилю %s.]=],
	["PR_CO_PROFILEMANAGER_EDIT_POPUP"] = [=[Введите новое название для профиля %s.
Название не может быть пустым.

Изменение названия не изменит связей между профилем и питомцами/транспортом.]=],
	["PR_CO_PROFILEMANAGER_TITLE"] = "Профили спутников",
	["PR_CO_UNUSED_PROFILE"] = "К данному профилю не привязан ни один питомец или вид транспорта.",
	["PR_CO_WARNING_RENAME"] = [=[|cffff0000Внимание:|r настоятельно рекомендуется сменить имя питомца перед тем, как привязывать его к профилю.

Link it anyway ?]=],
	["PR_CREATE_PROFILE"] = "Создать профиль",
	["PR_DEFAULT_PROFILE_NAME"] = "Профиль по умолчанию",
	["PR_DEFAULT_PROFILE_WARNING"] = "Создайте новый профиль или свяжите со существующим во вкладке Профили чтобы редактировать информацию персонажа.",
	["PR_DELETE_PROFILE"] = "Удалить профиль",
	["PR_DUPLICATE_PROFILE"] = "Копировать профиль",
	["PR_EXPORT_IMPORT_TITLE"] = "Экспортировать/импортировать профиль",
	["PR_EXPORT_NAME"] = "Серийный номер для профиля %s (размер %0.2f кб)",
	["PR_EXPORT_PROFILE"] = "Экспортировать профиль",
	["PR_EXPORT_TOO_LARGE"] = [=[Данный профиль слишком большой и не может быть экспортирован.

Размер профиля: %0.2f кб
Максимальный размер: 20 кб]=],
	["PR_EXPORT_WARNING_TITLE"] = "Предупреждение:",
	["PR_EXPORT_WARNING_WINDOWS"] = "Пожалуйста, обратите внимание что некоторые продвинутые инструменты редактирования текста вроде Microsoft Word или Discord реформатируют особые символы вроде цитат, изменяя контент информации. Если вы планируете скопировать текст внизу в документб пожалуйста используйте более простые инструменты редактирования текста которые не заменяют символы автоматически, вроде Блокнота.",
	["PR_IMPORT"] = "Импортировать",
	["PR_IMPORT_CHAR_TAB"] = "Импорт персонажей",
	["PR_IMPORT_EMPTY"] = "Нет импортируемых профилей",
	["PR_IMPORT_IMPORT_ALL"] = "Импортировать все",
	["PR_IMPORT_PETS_TAB"] = "Импортирование спутников",
	["PR_IMPORT_PROFILE"] = "Импортировать профиль",
	["PR_IMPORT_PROFILE_TT"] = "Вставьте серийный номер профиля сюда",
	["PR_IMPORT_WILL_BE_IMPORTED"] = "Будет импортировано",
	["PR_PROFILE"] = "Профиль",
	["PR_PROFILE_CREATED"] = "Профиль \"%s\" создан.",
	["PR_PROFILE_DELETED"] = "Профиль \"%s\" удален.",
	["PR_PROFILE_DETAIL"] = "Этот профиль на данный момент привязан к следующим персонажам WoW",
	["PR_PROFILE_HELP"] = [=[Профиль содержит информацию о |cffffff00"персонаже"|r как о |cff00ff00персонаже отыгрыша|r.

Настоящий |cffffff00"персонаж WoW"|r может быть связан только с одним профилем одновременно, но в любой момент можно переключить его на другой.

Так же можно связать нескольких |cffffff00"персонажей WoW"|r к одному |cff00ff00профилю|r!]=],
	["PR_PROFILE_LOADED"] = "Загружен профиль %s.",
	["PR_PROFILE_MANAGEMENT_TITLE"] = "Управление профилем",
	["PR_PROFILEMANAGER_ACTIONS"] = "Действия",
	["PR_PROFILEMANAGER_ALREADY_IN_USE"] = "Профиль %s недоступен.",
	["PR_PROFILEMANAGER_COUNT"] = "%s персонаж(ей) WoW связаны с профилем.",
	["PR_PROFILEMANAGER_CREATE_POPUP"] = [=[Введите название для нового профиля.
Название не может быть пустым.]=],
	["PR_PROFILEMANAGER_CURRENT"] = "Текущий профиль",
	["PR_PROFILEMANAGER_DELETE_WARNING"] = [=[Вы уверены, что хотите удалить профиль %s?
Данное действие невозможно отменить, вся информация TRP3, связанная с профилем (информация о персонаже, инвентарь, список заданий и др.) будет удалена!]=],
	["PR_PROFILEMANAGER_DUPP_POPUP"] = [=[Введите название для нового профиля.
Название не может быть пустым.

Эта копия не изменит связи персонажа с профилем %s.]=],
	["PR_PROFILEMANAGER_EDIT_POPUP"] = [=[Введите новое название профиля.
Название не может быть пустым.

Переименование профиля не изменит связей между профилем и персонажами.]=],
	["PR_PROFILEMANAGER_EMPTY"] = "Профили не найдены",
	["PR_PROFILEMANAGER_IMPORT_WARNING"] = "Заменить всё содержание профиля %s этими импортированными данными?",
	["PR_PROFILEMANAGER_IMPORT_WARNING_2"] = [=[Предупреждение: этот профиль создан в старой версии TRP3.
Это может привести к несовместимости.

Заменить всё содержимое профиля %s на импортируемые данные?]=],
	["PR_PROFILEMANAGER_RENAME"] = "Переименовать профиль",
	["PR_PROFILEMANAGER_SEARCH_PROFILE"] = "Поиск профиля",
	["PR_PROFILEMANAGER_SWITCH"] = "Выбрать профиль",
	["PR_PROFILEMANAGER_TITLE"] = "Профили персонажей",
	["PR_PROFILES"] = "Профили",
	["PR_SLASH_EXAMPLE"] = "|cffffff00Использование команды:|r |cffcccccc/trp3 profile Миллидан Ясность Хмури|r |cffffff00Чтобы переключиться на профиль Миллидана Ясности Хмури.|r",
	["PR_SLASH_NOT_FOUND"] = "|cffff0000Не удалось найти профиль с именем|r |cffffff00%s|r|cffff0000.|r",
	["PR_SLASH_OPEN_ABORTING"] = "|cffffff00Запрос профиля отклонён.|r",
	["PR_SLASH_OPEN_EXAMPLE"] = "|cffffff00Использование команды:|r |cffcccccc/trp3 open|r |cffffff00чтобы открыть профиль цели или|cffcccccc/trp3 open ИмяПерсонажа-ИгровойМир|r |cffffff00to открывает профиль этого персонажа.|r",
	["PR_SLASH_OPEN_HELP"] = "Открыть профиль персонажа используя его внутреигровое имя, или же профиль вашей цели если имя не предоставленно.",
	["PR_SLASH_OPEN_WAITING"] = "|cffffff00Запрашиваем профиль, пожалуйста подождите...|r",
	["PR_SLASH_SWITCH_HELP"] = "Сменить на другой профиль используя его имя.",
	["PR_UNUSED_PROFILE"] = "Этот профиль на данный момент не привязан к какому-либо персонажу WoW.",
	["REG_COMPANION"] = "Спутник",
	["REG_COMPANION_BIND_TO_PET"] = "Питомец",
	["REG_COMPANION_BOUND_TO"] = "Привязать к ...",
	["REG_COMPANION_BOUND_TO_TARGET"] = "Цель",
	["REG_COMPANION_BOUNDS"] = "Привязки",
	["REG_COMPANION_BROWSER_BATTLE"] = "Коллекция боевых питомцев",
	["REG_COMPANION_BROWSER_MOUNT"] = "Коллекция средств передвижения",
	["REG_COMPANION_INFO"] = "Информация",
	["REG_COMPANION_LINKED"] = "Спутник %s теперь привязан к профилю %s.",
	["REG_COMPANION_LINKED_NO"] = "Спутник %s более не привязан к никакому профилю.",
	["REG_COMPANION_NAME"] = "Имя",
	["REG_COMPANION_NAME_COLOR"] = "Цвет имени",
	["REG_COMPANION_PAGE_TUTO_C_1"] = "Совет",
	["REG_COMPANION_PAGE_TUTO_E_1"] = [=[Это |cff00ff00основная информация о вашем спутнике|r.

Эта информация будет отображаться |cffff9900в описании спутника|r.]=],
	["REG_COMPANION_PAGE_TUTO_E_2"] = [=[Это |cff00ff00описание вашего спутника|r.

Оно не связано с |cffff9900физическим описанием|r. Здесь можно описать |cffff9900историю|r спутника или его |cffff9900характер|r.

Описание можно настроить под себя различными способами.
Вы можете выбрать |cffffff00текстуру фона|r для описания. Доступны инструменты форматирования, такие как |cffffff00размер шрифта, цвет и выравнивание|r.
Эти инструменты позволяют так же вставить |cffffff00изображения, иконки или ссылки на сайты|r.]=],
	["REG_COMPANION_PROFILES"] = "Профили спутников",
	["REG_COMPANION_TARGET_NO"] = "Ваша цель не является приемлемым питомцем, прислужником, элементалем мага или переименованным боевым питомцем.",
	["REG_COMPANION_TF_BOUND_TO"] = "Выбрать профиль",
	["REG_COMPANION_TF_CREATE"] = "Создать новый профиль",
	["REG_COMPANION_TF_NO"] = "Нет профиля",
	["REG_COMPANION_TF_OPEN"] = "Открыть страницу",
	["REG_COMPANION_TF_OWNER"] = "Владелец: %s",
	["REG_COMPANION_TF_PROFILE"] = "Профиль спутника",
	["REG_COMPANION_TF_PROFILE_MOUNT"] = "Профиль ездового животного",
	["REG_COMPANION_TF_UNBOUND"] = "Отвязать от профиля",
	["REG_COMPANION_TITLE"] = "Название",
	["REG_COMPANION_UNBOUND"] = "Отвязать от ...",
	["REG_COMPANIONS"] = "Спутники",
	["REG_DELETE_WARNING"] = [=[Вы уверены, что хотите удалить профиль "%s"?
]=],
	["REG_IGNORE_TOAST"] = "Персонаж игнорируется",
	["REG_LIST_ACTIONS_MASS"] = "Действие над %s выбранными профилями",
	["REG_LIST_ACTIONS_MASS_IGNORE"] = "Игнорировать профили",
	["REG_LIST_ACTIONS_MASS_IGNORE_C"] = [=[Данное действие добавит |cff00ff00%s персонажей|r в черный список.

Можете написать причину добавления ниже. Эту заметку сможете увидеть только Вы.]=],
	["REG_LIST_ACTIONS_MASS_REMOVE"] = "Удалить профили",
	["REG_LIST_ACTIONS_MASS_REMOVE_C"] = "Это действие удалит |cff00ff00%s выбранный(е) профиль(и)|r.",
	["REG_LIST_ACTIONS_PURGE"] = "Очистить регистр",
	["REG_LIST_ACTIONS_PURGE_ALL"] = "Удалить все профили",
	["REG_LIST_ACTIONS_PURGE_ALL_C"] = [=[Очистка удалит все профили и связанных персонажей из директории.

|cff00ff00%s персонажей.]=],
	["REG_LIST_ACTIONS_PURGE_ALL_COMP_C"] = [=[Очистка удалит всех спутников из директории.

|cff00ff00%s спутников.]=],
	["REG_LIST_ACTIONS_PURGE_COUNT"] = "%s профилей будет удалено.",
	["REG_LIST_ACTIONS_PURGE_EMPTY"] = "Нет профилей для удаления.",
	["REG_LIST_ACTIONS_PURGE_IGNORE"] = "Профили персонажей из черного списка",
	["REG_LIST_ACTIONS_PURGE_IGNORE_C"] = [=[Очистка удалит все профили, связанные с персонажами WoW из черного списка.

|cff00ff00%s]=],
	["REG_LIST_ACTIONS_PURGE_TIME"] = "Профиль не появлялся более месяца",
	["REG_LIST_ACTIONS_PURGE_TIME_C"] = [=[Очистка удалит все профили, которые не появлялись больше месяца.

|cff00ff00%s]=],
	["REG_LIST_ACTIONS_PURGE_UNLINKED"] = "Профиль не привязан к персонажу",
	["REG_LIST_ACTIONS_PURGE_UNLINKED_C"] = [=[Очистка удалит все профили, не связанные с персонажами WoW.

|cff00ff00%s]=],
	["REG_LIST_ADDON"] = "Тип профиля",
	["REG_LIST_CHAR_EMPTY"] = "Нет персонажей",
	["REG_LIST_CHAR_EMPTY2"] = "Ни один персонаж не подходит под описание",
	["REG_LIST_CHAR_FILTER"] = "Персонажей: %s / %s",
	["REG_LIST_CHAR_IGNORED"] = "Черный список",
	["REG_LIST_CHAR_NAME_COPY"] = "Скопировать имя персонажа",
	["REG_LIST_CHAR_SEL"] = "Выбранный персонаж",
	["REG_LIST_CHAR_TITLE"] = "Список персонажей",
	["REG_LIST_CHAR_TT"] = "Просмотреть страницу",
	["REG_LIST_CHAR_TT_CHAR"] = "Связанные персонажи WoW:",
	["REG_LIST_CHAR_TT_CHAR_NO"] = "Не привязан ни к одному персонажу",
	["REG_LIST_CHAR_TT_DATE"] = [=[Последнее появление: |cff00ff00%s|r
Последняя локация: |cff00ff00%s|r]=],
	["REG_LIST_CHAR_TT_GLANCE"] = "На первый взгляд",
	["REG_LIST_CHAR_TT_IGNORE"] = "Черный список",
	["REG_LIST_CHAR_TT_NEW_ABOUT"] = "Непрочитанное описание",
	["REG_LIST_CHAR_TT_RELATION"] = [=[Отношение:
|cff00ff00%s]=],
	["REG_LIST_CHAR_TUTO_ACTIONS"] = "Этот столбец позволяет выбрать несколько персонажей для проведения действий над всеми.",
	["REG_LIST_CHAR_TUTO_FILTER"] = [=[Можно применять фильтры к списку персонажей.

|cff00ff00Фильтр имени|r производит поиск по полному имени (имя + фамилия), а так же по привязанным персонажам.

|cff00ff00Фильтр гильдий|r производит поиск по названию гильдии привязанных персонажей.

|cff00ff00Фильтр игровых миров|r отображает только профили связанных персонажей из вашего мира.]=],
	["REG_LIST_CHAR_TUTO_LIST"] = [=[Первый столбец отображает имя персонажа.

Второй столбей отображает отношения между Вашим персонажем и прочими.

Последний столбец используется для различных меток (черный список и др.).]=],
	["REG_LIST_FILTERS"] = "Фильтры",
	["REG_LIST_FILTERS_TT"] = [=[|cffffff00ЛКМ:|r Применить фильтр
|cffffff00ПКМ:|r Сбросить фильтр]=],
	["REG_LIST_FLAGS"] = "Метки",
	["REG_LIST_GUILD"] = "Гильдия персонажа",
	["REG_LIST_IGNORE_EMPTY"] = "Черный список пуст",
	["REG_LIST_IGNORE_TITLE"] = "Черный список",
	["REG_LIST_IGNORE_TT"] = [=[Причина:
|cff00ff00%s

|cffffff00Удалить из черного списка]=],
	["REG_LIST_NAME"] = "Имя персонажа",
	["REG_LIST_NOTESONLY"] = "Только с заметками",
	["REG_LIST_NOTIF_ADD"] = "Обнаружен новый профиль для |cff00ff00%s",
	["REG_LIST_NOTIF_ADD_CONFIG"] = "Обнаружен новый профиль",
	["REG_LIST_NOTIF_ADD_NOT"] = "Данный профиль не существует.",
	["REG_LIST_PET_MASTER"] = "Имя хозяина",
	["REG_LIST_PET_NAME"] = "Имя спутника",
	["REG_LIST_PET_TYPE"] = "Тип спутника",
	["REG_LIST_PETS_EMPTY"] = "Нет спутника",
	["REG_LIST_PETS_EMPTY2"] = "Ни один спутник не подходит под ваш выбор",
	["REG_LIST_PETS_FILTER"] = "Спутники: %s / %s",
	["REG_LIST_PETS_TITLE"] = "Список спутников",
	["REG_LIST_PETS_TOOLTIP"] = "Последнее появление",
	["REG_LIST_PETS_TOOLTIP2"] = "Был вместе с",
	["REG_LIST_REALMONLY"] = "Только текущий игровой мир",
	["REG_LOCATION_DIFFERENT_WAR_MODE"] = "Другой Режим Войны",
	["REG_MSP_ALERT"] = [=[|cffff0000ВНИМАНИЕ

Настоятельно не рекомендуется пользоваться несколькими аддонами, использующими протокол Mary Sue, так как это вызывает ошибки.|r

Сейчас используются: |cff00ff00%s

|cffff9900Поддержка протокола для Total RP3 будет отключена.|r

Если вы не хотите использовать TRP3 по этому протоколу и не хотите снова видеть это сообщение, можно его отключить в настойках.]=],
	["REG_NOTES_PROFILE"] = "Заметки",
	["REG_NOTES_PROFILE_TT"] = "Открыть окно заметок для выбранного в цель персонажа.",
	["REG_PLAYER"] = "Персонаж",
	["REG_PLAYER_ABOUT"] = "О персонаже",
	["REG_PLAYER_ABOUT_ADD_FRAME"] = "Добавить окно",
	["REG_PLAYER_ABOUT_EMPTY"] = "Нет описания",
	["REG_PLAYER_ABOUT_HEADER"] = "Метка заголовка",
	["REG_PLAYER_ABOUT_MUSIC"] = "Тема персонажа",
	["REG_PLAYER_ABOUT_MUSIC_LISTEN"] = "Играть тему",
	["REG_PLAYER_ABOUT_MUSIC_REMOVE"] = "Отключить тему",
	["REG_PLAYER_ABOUT_MUSIC_SELECT"] = "Выбрать музыкальную тему персонажа",
	["REG_PLAYER_ABOUT_MUSIC_SELECT2"] = "Выбрать тему",
	["REG_PLAYER_ABOUT_MUSIC_STOP"] = "Остановить тему",
	["REG_PLAYER_ABOUT_MUSIC_THEME"] = "Музыкальная тема персонажа",
	["REG_PLAYER_ABOUT_NOMUSIC"] = "|cffff9900Тема не выбрана",
	["REG_PLAYER_ABOUT_P"] = "Метка абзаца",
	["REG_PLAYER_ABOUT_REMOVE_FRAME"] = "Удалить окно",
	["REG_PLAYER_ABOUT_SOME"] = "Текст ...",
	["REG_PLAYER_ABOUT_T1_YOURTEXT"] = "Вставьте Ваш текст",
	["REG_PLAYER_ABOUT_TAGS"] = "Инструменты форматирования",
	["REG_PLAYER_ABOUT_UNMUSIC"] = "|cffff9900Неизвестная тема",
	["REG_PLAYER_ABOUT_VOTE_DOWN"] = "Мне не нравится описание",
	["REG_PLAYER_ABOUT_VOTE_NO"] = [=[Персонажи, связанные с профилем, не в сети.
Хотите, чтобы Total RP 3 все равно отправил голос?]=],
	["REG_PLAYER_ABOUT_VOTE_SENDING"] = "Посылка голоса профилю %s ...",
	["REG_PLAYER_ABOUT_VOTE_SENDING_OK"] = "Ваш голос успешно отправлен профилю %s!",
	["REG_PLAYER_ABOUT_VOTE_TT"] = "Ваш голос является анонимным. Другой игрок не увидит отправителя.",
	["REG_PLAYER_ABOUT_VOTE_TT2"] = "Вы можете голосовать, только если игрок в сети.",
	["REG_PLAYER_ABOUT_VOTE_UP"] = "Мне нравится описание",
	["REG_PLAYER_ABOUT_VOTES"] = "Статистика",
	["REG_PLAYER_ABOUT_VOTES_R"] = [=[|cff00ff00%s игрокам нравится описание
|cffff0000%s игрокам не нравится описание]=],
	["REG_PLAYER_ABOUTS"] = "О %s",
	["REG_PLAYER_ADD_NEW"] = "Создать новый",
	["REG_PLAYER_AGE"] = "Возраст",
	["REG_PLAYER_AGE_TT"] = [=[Здест Вы можете указать возраст вашего персонажа.

Это можно сделать следующими способами:|c0000ff00
- Возраст в годах (число),
- Прилагательное (Молодой, Взрослый, Престарелый и др.).]=],
	["REG_PLAYER_ALERT_HEAVY_SMALL"] = [=[|cffff0000Общий размер профиля слишком велик.
|cffff9900Уменьшите его.]=],
	["REG_PLAYER_BIRTHPLACE"] = "Место рождения",
	["REG_PLAYER_BIRTHPLACE_TT"] = [=[Здесь Вы можете написать место рождения персонажа: это может быть регион, локация или континент. Все зависит от того, насколько точно Вы хотите его описать.

|c00ffff00Используйте кнопку справа, чтобы установить Ваше текущее положение как место рождения.]=],
	["REG_PLAYER_BKG"] = "Стиль фона",
	["REG_PLAYER_BKG_TT"] = "Это графический фон используемый в вашем окне характеристик.",
	["REG_PLAYER_CARACT"] = "Характеристики",
	["REG_PLAYER_CHANGE_CONFIRM"] = [=[Возможно, Вы не сохранили изменения.
Вы действительно хотите изменить страницу?
|cffff9900Все изменения будут утеряны.]=],
	["REG_PLAYER_CHARACTERISTICS"] = "Характеристики",
	["REG_PLAYER_CLASS"] = "Класс",
	["REG_PLAYER_CLASS_TT"] = [=[Это нестандартный класс вашего персонажа.

|cff00ff00Например:|r
Рыцарь, Пиротехник, Некромант, Элитный стрелок, Чародей, ...]=],
	["REG_PLAYER_COLOR_ALWAYS_DEFAULT_TT"] = [=[|cffffff00ЛКМ:|r Выбрать цвет
|cffffff00ПКМ:|r Сбросить цвет]=],
	["REG_PLAYER_COLOR_CLASS"] = "Цвет класса",
	["REG_PLAYER_COLOR_CLASS_TT"] = "Он так же определит цвет имени.",
	["REG_PLAYER_COLOR_TT"] = [=[
|cffffff00ЛКМ:|r Выбрать цвет
|cffffff00ПКМ:|r Сбросить цвет
|cffffff00Shift+ПКМ:|r Использовать стандартный выбор цвета
]=],
	["REG_PLAYER_CURRENT"] = "На данный момент",
	["REG_COMPANIONS_SHORTDESCRIPTION"]= "Краткое описание",
	["REG_PLAYER_CURRENT_OOC"] = "Это информация вне отыгрыша",
	["REG_PLAYER_CURRENTOOC"] = "На данный момент (Вне отыгрыша)",
	["REG_PLAYER_EDIT_MUSIC_THEME"] = "Музыкальная тема",
	["REG_PLAYER_EYE"] = "Цвет глаз",
	["REG_PLAYER_EYE_TT"] = [=[Здесь Вы можете указать цвет глаз персонажа.

Учтите, что даже если лицо персонажа постоянно скрыто, цвет глаз стоит указать на всякий случай.]=],
	["REG_PLAYER_FIRSTNAME"] = "Имя",
	["REG_PLAYER_FIRSTNAME_TT"] = [=[Это имя Вашего персонажа. Это поле является обязательным, по умолчанию будет использовано имя персонажа WoW (|cffffff00%s|r).

Так же можно использовать |c0000ff00прозвище|r!]=],
	["REG_PLAYER_FULLTITLE"] = "Полный титул",
	["REG_PLAYER_FULLTITLE_TT"] = [=[Здесь вы можете написать полный титул вашего персонажа. Оно может быть как более длинной версией титула или совершенно другим титулом.

Впрочем, вы можете захотеть избежать повторений, в случае если нет дополнительной информации которую вы хотели бы добавить.]=],
	["REG_PLAYER_GLANCE"] = "На первый взгляд",
	["REG_PLAYER_GLANCE_BAR_DELETED"] = "Заготовка группы |cffff9900%s|r удалена.",
	["REG_PLAYER_GLANCE_BAR_EMPTY"] = "Имя образца не может быть пустым.",
	["REG_PLAYER_GLANCE_BAR_LOAD"] = "Групповая заготовка",
	["REG_PLAYER_GLANCE_BAR_LOAD_SAVE"] = "Групповые заготовки",
	["REG_PLAYER_GLANCE_BAR_NAME"] = [=[Пожалуйста введите название заготовки.

|cff00ff00Заметка: Если название уже используется другой групповой заготовкой, эта группа будет заменена.]=],
	["REG_PLAYER_GLANCE_BAR_SAVE"] = "Сохранить группу в качестве заготовки",
	["REG_PLAYER_GLANCE_BAR_SAVED"] = "Заготовка группы |cff00ff00%s| была создана.",
	["REG_PLAYER_GLANCE_BAR_TARGET"] = "Заготовки \"На первый взгляд\"",
	["REG_PLAYER_GLANCE_CONFIG"] = [=[|cff00ff00"На первый взгляд"|r это набор слотов где вы можете обозначить важную информацию про этого персонажа. Вы можете применить следующие действия со слотами:
|cffffff00ЛКМ:|r настроить слот |cffffff00Двойное нажатие:|r включить/выключить слот
|cffffff00ПКМ:|r предустановки слотов |cffffff00Перетянуть:|r изменить порядок слотов.]=],
	["REG_PLAYER_GLANCE_EDITOR"] = "На первый взгляд : Слот %s",
	["REG_PLAYER_GLANCE_MENU_COPY"] = "Копировать слот",
	["REG_PLAYER_GLANCE_MENU_PASTE"] = "Вставить слот: %s",
	["REG_PLAYER_GLANCE_PRESET"] = "Загрузить заготовку",
	["REG_PLAYER_GLANCE_PRESET_ADD"] = "Создана заготовка |cff00ff00%s|r.",
	["REG_PLAYER_GLANCE_PRESET_ALERT1"] = "Вы должны ввести название для категории заготовок.",
	["REG_PLAYER_GLANCE_PRESET_CATEGORY"] = "Категория заготовки",
	["REG_PLAYER_GLANCE_PRESET_CREATE"] = "Создать заготовку",
	["REG_PLAYER_GLANCE_PRESET_GET_CAT"] = [=[%s

Пожалуйста, введите название категории для этой заготовки.]=],
	["REG_PLAYER_GLANCE_PRESET_NAME"] = "Название заготовки",
	["REG_PLAYER_GLANCE_PRESET_REMOVE"] = "Удалена заготовка |cff00ff00%s|r.",
	["REG_PLAYER_GLANCE_PRESET_SAVE"] = "Сохранить информацию как заготовку",
	["REG_PLAYER_GLANCE_PRESET_SAVE_SMALL"] = "Сохранить как заготовку",
	["REG_PLAYER_GLANCE_PRESET_SELECT"] = "Выбрать заготовку",
	["REG_PLAYER_GLANCE_TITLE"] = "Название аттрибута",
	["REG_PLAYER_GLANCE_UNUSED"] = "Неиспользуемый слот",
	["REG_PLAYER_GLANCE_USE"] = "Активировать слот",
	["REG_PLAYER_HEIGHT"] = "Рост",
	["REG_PLAYER_HEIGHT_TT"] = [=[Здесь вы можете указать рост Вашего персонажа.

Это можно сделать следующими способами:|c0000ff00
- Точное значение (170 см, 6'5"),
- Прилагательное (высокий, низкий).]=],
	["REG_PLAYER_HERE"] = "Установить позицию",
	["REG_PLAYER_HERE_HOME_PRE_TT"] = [=[Текущее координаты дома:
|cff00ff00%s|r.]=],
	["REG_PLAYER_HERE_HOME_TT"] = [=[|cffffff00Click|r: Использовать текущие координаты как место размещения вашего дома.
|cffffff00Right-click|r: Сбросить размещение дома.]=],
	["REG_PLAYER_HERE_TT"] = "|cffffff00ЛКМ|r: Установить на текущее положение",
	["REG_PLAYER_HISTORY"] = "История",
	["REG_PLAYER_ICON"] = "Значок персонажа",
	["REG_PLAYER_ICON_TT"] = "Выберите изображение, представляющее вашего персонажа",
	["REG_PLAYER_IGNORE"] = "Добавить в черный список связанных персонажей (%s)",
	["REG_PLAYER_IGNORE_WARNING"] = [=[Вы хотите добавить в черный список выбранных персонажей?

|cffff9900%s

|rВы можете указать причину ниже. Другие игроки не смогут ее увидеть.]=],
	["REG_PLAYER_LASTNAME"] = "Фамилия",
	["REG_PLAYER_LASTNAME_TT"] = "Это фамилия вашего персонажа.",
	["REG_PLAYER_LEFTTRAIT"] = "Левая черта",
	["REG_PLAYER_MISC_ADD"] = "Добавить поле",
	["REG_PLAYER_MISC_PRESET_PRONOUNS"] = "Местоимения",
	["REG_PLAYER_MORE_INFO"] = "Дополнительная информация",
	["REG_PLAYER_MSP_HOUSE"] = "Название дома",
	["REG_PLAYER_MSP_MOTTO"] = "Девиз",
	["REG_PLAYER_MSP_NICK"] = "Кличка",
	["REG_PLAYER_NAMESTITLES"] = "Имена и звания",
	["REG_PLAYER_NO_CHAR"] = "Нет характеристик",
	["REG_PLAYER_NOTES"] = "Заметки",
	["REG_PLAYER_NOTES_ACCOUNT"] = "Общие заметки",
	["REG_PLAYER_NOTES_ACCOUNT_HELP"] = "Эти частные заметки привязаны к вашему аккаунту и являются общими для всех ваших профилей.",
	["REG_PLAYER_NOTES_PROFILE"] = "Заметки от %s",
	["REG_PLAYER_NOTES_PROFILE_HELP"] = "Эти частные заметки привязаны к текущему профилю и будут изменены в зависимости от активного профиля на данный момент.",
	["REG_PLAYER_NOTES_PROFILE_NONAME"] = "Заметки профиля",
	["REG_PLAYER_PEEK"] = "Разное",
	["REG_PLAYER_PHYSICAL"] = "Физическое описание",
	["REG_PLAYER_PSYCHO"] = "Черты характера",
	["REG_PLAYER_PSYCHO_Acete"] = "Аскет",
	["REG_PLAYER_PSYCHO_ADD"] = "Добавить черту характера",
	["REG_PLAYER_PSYCHO_ATTIBUTENAME_TT"] = "Название черты",
	["REG_PLAYER_PSYCHO_Bonvivant"] = "Душа компании",
	["REG_PLAYER_PSYCHO_CHAOTIC"] = "Хаотичный",
	["REG_PLAYER_PSYCHO_Chaste"] = "Строгий",
	["REG_PLAYER_PSYCHO_Conciliant"] = "Идеал",
	["REG_PLAYER_PSYCHO_Couard"] = "Бесхребетный",
	["REG_PLAYER_PSYCHO_CREATENEW"] = "Создать черту",
	["REG_PLAYER_PSYCHO_Cruel"] = "Жестокий",
	["REG_PLAYER_PSYCHO_CUSTOM"] = "Своя черта",
	["REG_PLAYER_PSYCHO_CUSTOMCOLOR"] = "Выберите цвет черты",
	["REG_PLAYER_PSYCHO_CUSTOMCOLOR_LEFT_TT"] = [=[Выберите цвет полосы для левой черты.

|cffffff00ЛКМ:|r Выбрать цвет
|cffffff00ПКМ:|r Сбросить цвет
|cffffff00Shift+ЛКМ|r Использовать стандартный интерфейс выбора цвета]=],
	["REG_PLAYER_PSYCHO_CUSTOMCOLOR_RIGHT_TT"] = [=[Выберите цвет полосы для правой черты.

|cffffff00ЛКМ:|r Выбрать цвет
|cffffff00ПКМ:|r Сбросить цвет
|cffffff00Shift+ЛКМ|r Использовать стандартный интерфейс выбора цвета]=],
	["REG_PLAYER_PSYCHO_Egoiste"] = "Эгоист",
	["REG_PLAYER_PSYCHO_Genereux"] = "Альтруист",
	["REG_PLAYER_PSYCHO_Impulsif"] = "Импульсивный",
	["REG_PLAYER_PSYCHO_Indulgent"] = "Великодушный",
	["REG_PLAYER_PSYCHO_LEFTICON_TT"] = "Выберите значок для левой черты.",
	["REG_PLAYER_PSYCHO_Loyal"] = "Законопослушный",
	["REG_PLAYER_PSYCHO_Luxurieux"] = "Похотливый",
	["REG_PLAYER_PSYCHO_Misericordieux"] = "Вежливый",
	["REG_PLAYER_PSYCHO_MORE"] = "Добавить точку к \"%s\"",
	["REG_PLAYER_PSYCHO_PERSONAL"] = "Черты характера",
	["REG_PLAYER_PSYCHO_Pieux"] = "Суеверный",
	["REG_PLAYER_PSYCHO_POINT"] = "Добавить точку",
	["REG_PLAYER_PSYCHO_Pragmatique"] = "Отступник",
	["REG_PLAYER_PSYCHO_Rationnel"] = "Рациональный",
	["REG_PLAYER_PSYCHO_Reflechi"] = "Осторожный",
	["REG_PLAYER_PSYCHO_Rencunier"] = "Мстительный",
	["REG_PLAYER_PSYCHO_RIGHTICON_TT"] = "Выберите значок для правой черты.",
	["REG_PLAYER_PSYCHO_Sincere"] = "Правдивый",
	["REG_PLAYER_PSYCHO_SOCIAL"] = "Социальные черты",
	["REG_PLAYER_PSYCHO_Trompeur"] = "Лживый",
	["REG_PLAYER_PSYCHO_Valeureux"] = "Доблестный",
	["REG_PLAYER_RACE"] = "Раса",
	["REG_PLAYER_RACE_TT"] = "Здесь указывается раса персонажа. Не обязательно ограничиваться играбельными расами. В мире Warcraft есть много рас, обладающих схожими чертами.",
	["REG_PLAYER_REGISTER"] = "Общая информация",
	["REG_PLAYER_RELATIONSHIP_STATUS"] = "Статус отношений",
	["REG_PLAYER_RELATIONSHIP_STATUS_DIVORCED"] = "В разводе",
	["REG_PLAYER_RELATIONSHIP_STATUS_MARRIED"] = "В браке",
	["REG_PLAYER_RELATIONSHIP_STATUS_SINGLE"] = "Одиночка",
	["REG_PLAYER_RELATIONSHIP_STATUS_TAKEN"] = "В отношениях",
	["REG_PLAYER_RELATIONSHIP_STATUS_TT"] = "Отметьте статус отношений вашего персонажа. Если вы желаете оставить эту информацию скрытой, выберите опцию \"Не показывать\".",
	["REG_PLAYER_RELATIONSHIP_STATUS_UNKNOWN"] = "Не показывать",
	["REG_PLAYER_RELATIONSHIP_STATUS_WIDOWED"] = "Вдовствует",
	["REG_PLAYER_RESIDENCE"] = "Место жительства",
	["REG_PLAYER_RESIDENCE_SHOW"] = "Координаты места жительства",
	["REG_PLAYER_RESIDENCE_SHOW_TT"] = [=[|cff00ff00%s

|rКлик для показа на карте]=],
	["REG_PLAYER_RESIDENCE_TT"] = [=[Здесь вы можете указать, где проживает персонаж. Это может быть личный адрес его дома или место, где он может быть найден.
Обратите внимание, что если ваш персонаж является странником или даже бездомным, вам нужно будет указать информацию соответствующим образом.

| C00ffff00Правым кликом мыши, вы можете легко установить текущее местоположение на карте в качестве резиденции.]=],
	["REG_PLAYER_RIGHTTRAIT"] = "Правая черта",
	["REG_PLAYER_SHOWMISC"] = "Показывать рамку разного",
	["REG_PLAYER_SHOWMISC_TT"] = "Пометьте если вы хотите отображать пользовательские поля для вашего персонажа. Если вы не хотите отображать пользовательские поля, оставьте коробочку непомеченой и рамка разного останется абсолютно скрытой.",
	["REG_PLAYER_SHOWPSYCHO"] = "Отображать рамку характера",
	["REG_PLAYER_SHOWPSYCHO_TT"] = [=[Выберите если вы хотите использовать описание характера.

Если вы не хотите показывать характер вашего персонажа данным образом, оставьте флажок непомеченным и окно характера будет автоматически скрыто.]=],
	["REG_PLAYER_STYLE_ASSIST"] = "Помощь в отыгрыше",
	["REG_PLAYER_STYLE_BATTLE"] = "Предпочитаемый вид боя",
	["REG_PLAYER_STYLE_BATTLE_1"] = "World of warcraft PVP",
	["REG_PLAYER_STYLE_BATTLE_2"] = "TRP roll battle",
	["REG_PLAYER_STYLE_BATTLE_3"] = "/roll бой",
	["REG_PLAYER_STYLE_BATTLE_4"] = "Логик бой",
	["REG_PLAYER_STYLE_DEATH"] = "Принимать смерть персонажа",
	["REG_PLAYER_STYLE_FREQ"] = "Частота нахождения в роли",
	["REG_PLAYER_STYLE_FREQ_1"] = "Всегда в роли",
	["REG_PLAYER_STYLE_FREQ_2"] = "Время от времени",
	["REG_PLAYER_STYLE_FREQ_3"] = "Среднее время",
	["REG_PLAYER_STYLE_FREQ_4"] = "Начинающий",
	["REG_PLAYER_STYLE_FREQ_5"] = "Всегда вне роли, этот персонаж не для отыгрыша",
	["REG_PLAYER_STYLE_GUILD"] = "Членство в гильдии",
	["REG_PLAYER_STYLE_GUILD_IC"] = "Членство в роли",
	["REG_PLAYER_STYLE_GUILD_OOC"] = "Членство вне роли",
	["REG_PLAYER_STYLE_HIDE"] = "Не показывать",
	["REG_PLAYER_STYLE_INJURY"] = "Принимать травмирование персонажа",
	["REG_PLAYER_STYLE_PERMI"] = "С согласия игрока",
	["REG_PLAYER_STYLE_ROMANCE"] = "Принимать роман с персонажем",
	["REG_PLAYER_STYLE_RPSTYLE"] = "Стиль отыгрыша",
	["REG_PLAYER_STYLE_RPSTYLE_SHORT"] = "Стиль ролевой игры",
	["REG_PLAYER_STYLE_WOWXP"] = "Опыт в World of Warcraft",
	["REG_PLAYER_TITLE"] = "Звание",
	["REG_PLAYER_TITLE_TT"] = [=[Звание вашего персонажа часто используется для именования вашего персонажа другими. Для длинных званий используете пожалуйста "Полное звание".

Примеры |c0000ff00подходящих званий |r:
|c0000ff00- Графиня,
- Маркиз,
- Маг,
- Лорд,
- итд.
|rПримеры |cffff0000неуместных званий |r:
|cffff0000- Графиня Северных Болот,
- Маг из Штормградской Башни,
- Дипломат правительства Дренеев,
- и тд.]=],
	["REG_PLAYER_TRP2_PIERCING"] = "Пирсинг",
	["REG_PLAYER_TRP2_TATTOO"] = "Татуировки",
	["REG_PLAYER_TRP2_TRAITS"] = "Лицо",
	["REG_PLAYER_TUTO_ABOUT_COMMON"] = [=[|cff00ff00Тема персонажа:|r
Вы можете выбрать |cffffff00тему|r вашего персонажа. Подберите |cffffff00музыкальное настроение для чтения описания вашего персонажа|r.

|cff00ff00Фон:|r
Это |cffffff00фоновая текстура|r описания вашего персонажа.

|cff00ff00Шаблон:|r
Выбраный шаблон определяет |cffffff00общий вид и стилевые возможности |r для вашего описания.
|cffff9900Только выбраный шаблон доступен для просмотра другим, Нет необходимости заполнять все шаблоны.|r
Как только вы выберете шаблон, вы опять сможете открыть это обучение, чтотбы получить больше помощи для любого шаблона.]=],
	["REG_PLAYER_TUTO_ABOUT_MISC_1"] = [=[Этот раздел предлагает |cffffff005 позиций,|r с помощью которых вы можете описать |cff00ff00самую важную информацию о вашем персонаже|r.

Эта информация будет видна в |cffffff00"На первый взгляд" блоке|r когда кто-нибудь выберет вашего персонажа.

|cff00ff00Совет: Вы можете drag & drop позиции для изменения сортировки.|r
Так же работает в |cffffff00"На первый взгляд" блоке|r!]=],
	["REG_PLAYER_TUTO_ABOUT_MISC_3"] = "Эта секция содержит |cffffff00список переключателей,|r чтобы ответить на |cffffff00часто задаваемые вопросы о вас, вашем персонаже иособенностях игры за него/нее|r.",
	["REG_PLAYER_TUTO_ABOUT_T1"] = "Данный шаблон позволяет вам |cff00ff00свободно обустраивать своё описание|r. Описание не обязано быть ограниченным |cffff9900физическим описанием|r вашего персонажа. Не стесняйтесь отмечать части его |cffff9900биографии|r или детали его |cffff9900характера|r. С этим шаблоном вы можете использовать инструменты форматирования для доступка к некоторым параметрам отображения вроде |cffffff00размеов текста, цветов и выравнивания|r. Эти инструменты так же позволяет вам вставлять |cffffff00изображения, иконки или ссылки на внешние веб сайты|r.",
	["REG_PLAYER_TUTO_ABOUT_T2"] = "Этот шаблон более структурированный и состоит из |cff00ff00списка независимых окон|r. Каждое окно характеризуется |cffffff00иконкой, фоном и текстом|r. Заметьте что вы можете использовать некоторые текстовые ярлыки в этих окнах, вроде текстовых ярлыков цвета и иконок. Описание не должно быть ограниченным |cffff9900физическим описанием|r вашего персонажа. Не стесняйтесь отмечать части его |cffff9900биографии|r или детали про его |cffff9900характер|r.",
	["REG_PLAYER_TUTO_ABOUT_T3"] = "Этот шаблон разделён на 3 секции:  |cff00ff00Физическое описание, характер и история|r. Вы не обязаны заполнять все окна, |cffff9900если вы оставите окно пустым оно не будет отображаться в вашем описании|r. Каждое окно характеризуется |cffffff00иконкой, фоном и текстом|r. Заметьте что вы можете использовать некоторые текстовые ярлыки в этих окнах, вроде текстовых ярлыков цвета и иконок.",
	["REG_PLAYER_WEIGHT"] = "Телосложение",
	["REG_PLAYER_WEIGHT_TT"] = [=[Это форма тела вашего персонажа.
К примеру, она может быть |c0000ff00slim, толстый или мускулистый...|r Или она просто может быть обычной!]=],
	["REG_PLAYERS"] = "Игроки",
	["REG_REGISTER"] = "Архив",
	["REG_REGISTER_CHAR_LIST"] = "Список персонажей",
	["REG_RELATION"] = "Отношение",
	["REG_RELATION_BUSINESS"] = "Деловые",
	["REG_RELATION_BUSINESS_TT"] = "%s и %s связаны деловыми отношениями.",
	["REG_RELATION_BUTTON_TT"] = [=[Отношение: %s
|cff00ff00%s

|cffffff00Click, чтобы показать возможные действия]=],
	["REG_RELATION_FAMILY"] = "Родственник",
	["REG_RELATION_FAMILY_TT"] = "%s связан кровными узами с %s.",
	["REG_RELATION_FRIEND"] = "Друг",
	["REG_RELATION_FRIEND_TT"] = "%s воспринимает %s как друга.",
	["REG_RELATION_LOVE"] = "Любовь",
	["REG_RELATION_LOVE_TT"] = "%s влюблен в %s !",
	["REG_RELATION_NEUTRAL"] = "Нейтральный",
	["REG_RELATION_NEUTRAL_TT"] = "%s абсолютно безразлично относится к %s.",
	["REG_RELATION_NONE"] = "Нет",
	["REG_RELATION_NONE_TT"] = "%s не знает %s",
	["REG_RELATION_TARGET"] = "|cffffff00ПКМ: |rИзменить отношение",
	["REG_RELATION_UNFRIENDLY"] = "Недружественный",
	["REG_RELATION_UNFRIENDLY_TT"] = "%s определенно не нравится %s",
	["REG_REPORT_PLAYER_PROFILE"] = "Пожаловаться на профиль |cff449fe0Blizzard|r",
	["REG_REPORT_PLAYER_TEMPLATE_TRIAL_ACCOUNT"] = "Данный игрок был на пробном аккаунте.",
	["REG_TIME"] = "Время последней встречи",
	["REG_TRIAL_ACCOUNT"] = "Пробный аккаунт",
	["REG_TT_GUILD"] = "%s из |cffff9900%s",
	["REG_TT_GUILD_IC"] = "Членство IC",
	["REG_TT_GUILD_OOC"] = "Членство ООС",
	["REG_TT_IGNORED"] = "< Персонаж игнорируется >",
	["REG_TT_IGNORED_OWNER"] = "< Владелец игнорируется >",
	["REG_TT_LEVEL"] = "Уровень %s %s",
	["REG_TT_NOTIF"] = "Непрочитанное описание",
	["REG_TT_REALM"] = "Игровой мир: |cffff9900%s",
	["REG_TT_TARGET"] = "Цель: |cffff9900%s",
	["REG_TT_ZONE"] = "Игровая зона",
	["SCRIPT_ERROR"] = "Ошибка в скрипте.",
	["SCRIPT_UNKNOWN_EFFECT"] = "Ошибка скрипта, неизвестный FX",
	["SLASH_CMD_STATUS_HELP"] = "Использование:  |cff00ff00/trp3 status ic || ooc || toggle|r Меняет ваш статус персонажа на выбранную опцию:  |cffff9900/trp3 status ic|r установит ваш статус на |cff00ff00в роли|r.  |cffff9900/trp3 status ooc|r установит ваш статус на |cffff0000вне роли|r. |cffff9900/trp3 status toggle|r поменяет ваш статус на противоположное состояние.",
	["SLASH_CMD_STATUS_USAGE"] = "ic || ooc || toggle",
	["TB_AFK_MODE"] = "Отсутствует",
	["TB_DND_MODE"] = "Не беспокоить",
	["TB_GO_TO_MODE"] = "Переключить в статус %s ",
	["TB_LANGUAGE"] = "Язык",
	["TB_LANGUAGES_TT"] = "Сменить язык",
	["TB_NORMAL_MODE"] = "Обычный",
	["TB_RPSTATUS_OFF"] = "Персонаж: |cffff0000Вне роли",
	["TB_RPSTATUS_ON"] = "Персонаж: |cff00ff00В роли",
	["TB_RPSTATUS_TO_OFF"] = "Выйти |cffff0000out из роли",
	["TB_RPSTATUS_TO_ON"] = "Войти |cff00ff00в роль",
	["TB_STATUS"] = "Игрок",
	["TB_SWITCH_CAPE_1"] = "Показать плащ",
	["TB_SWITCH_CAPE_2"] = "Скрыть плащ",
	["TB_SWITCH_CAPE_OFF"] = "Плащ: |cffff0000Скрыт",
	["TB_SWITCH_CAPE_ON"] = "Плащ: |cff00ff00Виден",
	["TB_SWITCH_HELM_1"] = "Отображать шлем",
	["TB_SWITCH_HELM_2"] = "Скрыть шлем",
	["TB_SWITCH_HELM_OFF"] = "Шлем: |cffff0000Скрыт",
	["TB_SWITCH_HELM_ON"] = "Шлем: |cffff0000Показан",
	["TB_SWITCH_PROFILE"] = "Переключиться на другой профиль",
	["TB_SWITCH_TOOLBAR"] = "Переключить панель",
	["TB_TOOLBAR"] = "Панель",
	["TF_IGNORE"] = "Игнорировать игрока",
	["TF_IGNORE_CONFIRM"] = [=[Вы уверены что хотите игнорировать этот ID?

|cffffff00%s|r

|cffff7700При желании ниже можно ввести причины игнорирования. Это персональная заметка, она не видна другим и служит лишь напоминанием.]=],
	["TF_IGNORE_NO_REASON"] = "Причина не указана",
	["TF_IGNORE_TT"] = "|cffffff00Клик:|r Игнорировать игрока",
	["TF_OPEN_CHARACTER"] = "Показать лист персонажа",
	["TF_OPEN_COMPANION"] = "Показать страницу спутника",
	["TF_OPEN_MOUNT"] = "Показать каталог транспортных средств",
	["TF_PLAY_THEME"] = "Проиграть тему персонажа",
	["TF_PLAY_THEME_TT"] = [=[|cffffff00Click:|r Играть |cff00ff00%s
|cffffff00Right-click:|r Остановить тему]=],
	["THANK_YOU_ROLE_AUTHOR"] = "Автор",
	["THANK_YOU_ROLE_GUILD_MEMBER"] = "Член Гильдии",
	["TT_ELVUI_SKIN"] = "Скин ElvUI",
	["UI_BKG"] = "Фон %s",
	["UI_CLOSE_ALL"] = "Закрыть все",
	["UI_COLOR_BROWSER"] = "Просмотр цветов",
	["UI_COLOR_BROWSER_PRESETS"] = "Заготовки",
	["UI_COLOR_BROWSER_PRESETS_BASIC"] = "Базовые",
	["UI_COLOR_BROWSER_PRESETS_CLASSES"] = "Класс",
	["UI_COLOR_BROWSER_PRESETS_CUSTOM"] = "Пользовательские",
	["UI_COLOR_BROWSER_PRESETS_ITEMS"] = "Качество предмета",
	["UI_COLOR_BROWSER_PRESETS_RESOURCES"] = "Ресурс",
	["UI_COLOR_BROWSER_SELECT"] = "Выбрать цвет",
	["UI_COMPANION_BROWSER_HELP"] = "Выберите боевого питомца",
	["UI_COMPANION_BROWSER_HELP_TT"] = [=[|cffffff00Внимание: |rТолько переименованые боевые питомцы могут быть привязаны к профилю.

|cff00ff00В этом разделе перечислены только боевые питомцы.]=],
	["UI_FILTER"] = "Фильтер",
	["UI_ICON_BROWSER"] = "Просмотр значков",
	["UI_ICON_BROWSER_HELP"] = "Скопировать значок",
	["UI_ICON_BROWSER_HELP_TT"] = [=[Пока это окно открыто вы можете нажать |cffffff00ctrl+ПКМ|r на значке, чтобы скопировать его название.

Работает:|cff00ff00
- С любой вещью в ваших сумках
- С любым элементом в книге заклинаний|r]=],
	["UI_ICON_SELECT"] = "Выбрать значок",
	["UI_IMAGE_BROWSER"] = "Просмотр изображений",
	["UI_IMAGE_SELECT"] = "Выбрать изображение",
	["UI_LINK_SAFE"] = "Вот URL ссылки.",
	["UI_LINK_TEXT"] = "Введите текст",
	["UI_LINK_URL"] = "http://адрес_вашего_сайта",
	["UI_LINK_WARNING"] = [=[А вот и ссылка.
Вы можете скопировать/вставить ее в адресную строку вашего браузера.

|cffff0000!! Внимание!!|r
Total RP не несет ответственности, если ссылка окажется вредоносной.]=],
	["UI_MUSIC_ALTTITLE"] = "Альтернативный заголовок",
	["UI_MUSIC_BROWSER"] = "Обозреватель музыки",
	["UI_MUSIC_DURATION"] = "Длительность",
	["UI_MUSIC_SELECT"] = "Выбрать музыку",
	["UI_PET_BROWSER_ACCEPT"] = "Назначить",
	["UI_TUTO_BUTTON"] = "Обучающий режим",
	["UI_TUTO_BUTTON_TT"] = "Нажмите, чтобы включить/выключить режим обучения",
	["UNIT_POPUPS_CHARACTER_STATUS"] = "Статус Персонажа",
	["UNIT_POPUPS_CONFIG_DISABLE_OUT_OF_CHARACTER"] = "Скрывать записи в меню вне роли",
	["UNIT_POPUPS_CONFIG_ENTRIES_HEADER"] = "Записи меню",
	["UNIT_POPUPS_CONFIG_MENU_TITLE"] = "Настройки меню",
	["UNIT_POPUPS_CONFIG_PAGE_TEXT"] = "Настройки меню",
	["UNIT_POPUPS_CONFIG_SHOW_CHARACTER_STATUS"] = "Показывать переключатель статуса персонажа",
	["UNIT_POPUPS_CONFIG_SHOW_HEADER_TEXT"] = "Показать заголовочный текст",
	["UNIT_POPUPS_CONFIG_SHOW_HEADER_TEXT_HELP"] = "Если помечено, показывает заголовок \"Ролевые настройки\" над любыми добавленными записями в меню.",
	["UNIT_POPUPS_CONFIG_SHOW_OPEN_PROFILE"] = "Показать кнопку открытия профиля",
	["UNIT_POPUPS_CONFIG_SHOW_SEPARATOR"] = "Показывать разделяющую линию",
	["UNIT_POPUPS_CONFIG_VISIBILITY_HEADER"] = "Настройки отображения",
	["UNIT_POPUPS_CURRENT_PROFILE"] = "Текущий Профиль",
	["UNIT_POPUPS_CURRENT_PROFILE_NAME"] = "Текущий профиль: %1$s",
	["UNIT_POPUPS_MODULE_NAME"] = "Всплывающее окно единицы",
	["UNIT_POPUPS_OPEN_PROFILE"] = "Открыть Профиль",
	["UNIT_POPUPS_ASSIGN_FLAG"] = "Назначить профиль",
	["UNIT_POPUPS_ROLEPLAY_OPTIONS_HEADER"] = "Настройки Ролевой Игры"
}

TRP3_API.loc:RegisterNewLocale("ruRU", "Pусский", localeContent);

localeContent = {
	["ABOUT_TITLE"] = "关于",
	["BINDING_NAME_TRP3_OPEN_TARGET_PROFILE"] = "打开目标资料",
	["BINDING_NAME_TRP3_TOGGLE"] = "切换主界面",
	["BINDING_NAME_TRP3_TOGGLE_CHARACTER_STATUS"] = "切换角色状态",
	["BINDING_NAME_TRP3_TOOLBAR_TOGGLE"] = "切换工具栏",
	["BLIZZARD_NAMEPLATES_MODULE_DESCRIPTION"] = "启动对暴雪默认姓名版的自定义功能。",
	["BLIZZARD_NAMEPLATES_MODULE_NAME"] = "暴雪姓名版",
	["BROADCAST_10"] = "|cffff9900 你已经拥有10个频道。TRP3 不会再次试图连接广播频道，但你将无法使用类似搜索玩家位置这样的功能。",
	["BROADCAST_OFFLINE_DISABLED"] = "广播频道已经被禁用。",
	["BROADCAST_PASSWORD"] = [=[|cffff0000 这是一个带密码的广播频道(%s). 
|cffff9900 TRP3 不会再次试图连接广播频道，但你将无法使用类似搜索玩家位置这样的功能。
|cff00ff00 您可以在TRP3常规设置中禁用或更改广播频道。]=],
	["BROADCAST_PASSWORDED"] = "|cffff0000用户|r%s|cffff0000 给频道加了密 (%s). |cffff9900 如果你不知道密码,您将无法使用类似搜索玩家位置这样的功能。",
	["BW_COLOR_CODE"] = "颜色代码",
	["BW_COLOR_CODE_ALERT"] = "错误的十六进制代码！",
	["BW_COLOR_CODE_TT"] = "你可以在这里粘贴6个十六进制颜色代码并按Enter键.",
	["BW_COLOR_PRESET_DELETE"] = "删除%s预设",
	["BW_COLOR_PRESET_RENAME"] = "重命名%s预设",
	["BW_COLOR_PRESET_SAVE"] = "保存当前颜色",
	["BW_COLOR_PRESET_TITLE"] = "预设颜色",
	["BW_CUSTOM_NAME"] = "自定义颜色名称",
	["BW_CUSTOM_NAME_TITLE"] = "名称(可选)",
	["BW_CUSTOM_NAME_TT"] = "您可以为保存的自定义颜色设置名称。如果是空的，它将使用十六进制颜色代码。",
	["CL_COMPANION_PROFILE"] = "同伴介绍",
	["CL_CONTENT_SIZE"] = "大小：%s",
	["CL_DIRECTORY_COMPANION_PROFILE"] = "同伴介绍的目录",
	["CL_DIRECTORY_PLAYER_PROFILE"] = "角色配置目录",
	["CL_DOWNLOADING"] = "下载：%0.1f %%",
	["CL_EXPIRED"] = "这个链接已经过期。",
	["CL_GLANCE"] = "第一印象",
	["CL_IMPORT_COMPANION"] = "导入同伴介绍",
	["CL_IMPORT_GLANCE"] = "导入第一印象",
	["CL_IMPORT_PROFILE"] = "导入配置文件",
	["CL_MAKE_IMPORTABLE"] = "使其可导入",
	["CL_MAKE_IMPORTABLE_BUTTON_TEXT"] = "使其可导入",
	["CL_MAKE_IMPORTABLE_SIMPLER"] = [=[使这个%s链接可导入?

人们可以复制和使用链接指向的内容。]=],
	["CL_MAKE_NON_IMPORTABLE"] = "仅可见",
	["CL_OPEN_COMPANION"] = "打开同伴介绍",
	["CL_OPEN_PROFILE"] = "打开简介",
	["CL_PLAYER_PROFILE"] = "角色简介",
	["CL_REQUESTING_DATA"] = "从%s请求链接数据。",
	["CL_SENDING_COMMAND"] = "发送命令……",
	["CL_SENT_BY"] = "由%s发送的链接",
	["CL_TOOLTIP"] = "创建一个聊天链接",
	["CL_TYPE"] = "TRP3链接类型:%s",
	["CL_VERSIONS_DIFFER"] = [=[此链接是使用不同版本的Total rp3生成的。

可能不兼容，从不同版本导入内容可能会导致问题。你想继续吗?]=],
	["CM_ACTIONS"] = "动作",
	["CM_ALT"] = "Alt键",
	["CM_APPLY"] = "应用",
	["CM_BLACK"] = "黑色",
	["CM_BLUE"] = "蓝色",
	["CM_CANCEL"] = "取消",
	["CM_CENTER"] = "中央",
	["CM_CLASS_DEATHKNIGHT"] = "死亡骑士",
	["CM_CLASS_DEMONHUNTER"] = "恶魔猎手",
	["CM_CLASS_DRUID"] = "德鲁伊",
	["CM_CLASS_HUNTER"] = "猎人",
	["CM_CLASS_MAGE"] = "法师",
	["CM_CLASS_MONK"] = "武僧",
	["CM_CLASS_PALADIN"] = "圣骑士",
	["CM_CLASS_PRIEST"] = "牧师",
	["CM_CLASS_ROGUE"] = "潜行者",
	["CM_CLASS_SHAMAN"] = "萨满",
	["CM_CLASS_UNKNOWN"] = "未知",
	["CM_CLASS_WARLOCK"] = "术士",
	["CM_CLASS_WARRIOR"] = "战士",
	["CM_CLICK"] = "点击",
	["CM_COLOR"] = "颜色",
	["CM_CTRL"] = "Ctrl键",
	["CM_CYAN"] = "青色",
	["CM_DELETE"] = "删除",
	["CM_DOUBLECLICK"] = "双击",
	["CM_DRAGDROP"] = "拖放",
	["CM_EDIT"] = "编辑",
	["CM_GREEN"] = "绿色",
	["CM_GREY"] = "灰色",
	["CM_IC"] = "扮演中(IC)",
	["CM_ICON"] = "图标",
	["CM_IMAGE"] = "图片",
	["CM_L_CLICK"] = "鼠标左键点击",
	["CM_LEFT"] = "左边",
	["CM_LINK"] = "链接",
	["CM_LOAD"] = "载入",
	["CM_M_CLICK"] = "鼠标中键",
	["CM_MOVE_DOWN"] = "下移",
	["CM_MOVE_UP"] = "上移",
	["CM_NAME"] = "名字",
	["CM_OOC"] = "非扮演中(OOC)",
	["CM_OPEN"] = "打开",
	["CM_ORANGE"] = "橙色",
	["CM_PINK"] = "粉色",
	["CM_PLAY"] = "播放",
	["CM_PURPLE"] = "紫色",
	["CM_R_CLICK"] = "鼠标右键点击",
	["CM_RED"] = "红色",
	["CM_REMOVE"] = "删除",
	["CM_RESET"] = "重置",
	["CM_RESIZE"] = "调整尺寸",
	["CM_RESIZE_TT"] = "拖动来调整窗口的大小.",
	["CM_RIGHT"] = "右边",
	["CM_SAVE"] = "保存",
	["CM_SELECT"] = "选择",
	["CM_SHIFT"] = "Shift键",
	["CM_SHOW"] = "显示",
	["CM_STOP"] = "停止",
	["CM_TWEET"] = "发送一条推特",
	["CM_TWEET_PROFILE"] = "显示配置文件的url",
	["CM_UNKNOWN"] = "未知",
	["CM_VALUE"] = "值",
	["CM_WHITE"] = "白色",
	["CM_YELLOW"] = "黄色",
	["CO_ADVANCED_BROADCAST"] = "插件通讯",
	["CO_ADVANCED_BROADCAST_CHANNEL_ALWAYS_LAST"] = "保持插件通讯频道位于最后",
	["CO_ADVANCED_BROADCAST_CHANNEL_ALWAYS_LAST_TT"] = "启用该选项将保持你的TRP3插件通讯频道位于通讯频道列表的最后一个。",
	["CO_ADVANCED_LANGUAGE_WORKAROUND"] = "启动语言重置反制机制",
	["CO_ADVANCED_LANGUAGE_WORKAROUND_TT"] = "自8.0.1版本以来，在每次进行加载（蓝条）时都会重置玩家当前语言。该功能将确保你使用的语言保持不变。",
	["CO_ADVANCED_LANGUAGES"] = "语言",
	["CO_ADVANCED_LANGUAGES_REMEMBER"] = "记录最近使用的语言",
	["CO_ADVANCED_LANGUAGES_REMEMBER_TT"] = "Total rp3将记录您在注销之前使用的语言，并在下一次登录时自动选择该语言。",
	["CO_ADVANCED_SETTINGS"] = "高级设置",
	["CO_ADVANCED_SETTINGS_MENU_NAME"] = "高级",
	["CO_ADVANCED_SETTINGS_POPUP"] = [=[您刚刚修改了一个高级设置。

请记住，更改这些设置可能会改变您使用附加组件的体验，并可能会阻止某些功能正常工作。后果自负。]=],
	["CO_ADVANCED_SETTINGS_RESET"] = "重置高级设置",
	["CO_ADVANCED_SETTINGS_RESET_TT"] = "将所有高级设置重置为默认值。如果在修改设置后出现问题，请使用此选项。",
	["CO_ANCHOR_BOTTOM"] = "下方",
	["CO_ANCHOR_BOTTOM_LEFT"] = "左下方",
	["CO_ANCHOR_BOTTOM_RIGHT"] = "右下方",
	["CO_ANCHOR_CURSOR"] = "在光标显示",
	["CO_ANCHOR_LEFT"] = "左边",
	["CO_ANCHOR_RIGHT"] = "右边",
	["CO_ANCHOR_TOP"] = "上方",
	["CO_ANCHOR_TOP_LEFT"] = "左上方",
	["CO_ANCHOR_TOP_RIGHT"] = "右上方",
	["CO_CHAT"] = "聊天设置",
	["CO_CHAT_DISABLE_OOC"] = "当ooc状态禁用自定义设置",
	["CO_CHAT_DISABLE_OOC_TT"] = "当你的角色被设置为非角色扮演（OOC）状态，禁用所有rp3的聊天自定义(自定义名称、emote检测、NPC发言等)。",
	["CO_CHAT_INCREASE_CONTRAST"] = "增加颜色对比",
	["CO_CHAT_INSERT_FULL_RP_NAME"] = "使用shift-click插入 RP 姓名 ",
	["CO_CHAT_INSERT_FULL_RP_NAME_TT"] = [=[当你shift-单击他们的聊天对话框时，插入完整的RP角色名称。

(当启用此选项时，您可以在需要正常插入姓名时对一个名称进行alt - shift -单击，以此插入角色名而不是完整的RP名称。)]=],
	["CO_CHAT_MAIN"] = "聊天主设置",
	["CO_CHAT_MAIN_COLOR"] = "名字使用自定义颜色",
	["CO_CHAT_MAIN_EMOTE"] = "表情检测",
	["CO_CHAT_MAIN_EMOTE_PATTERN"] = "表情检测模式",
	["CO_CHAT_MAIN_EMOTE_USE"] = "使用表情检测",
	["CO_CHAT_MAIN_EMOTE_YELL"] = "不允许喊叫表情",
	["CO_CHAT_MAIN_EMOTE_YELL_TT"] = "不在喊叫时显示*表情*或<表情>",
	["CO_CHAT_MAIN_NAMING"] = "命名方法",
	["CO_CHAT_MAIN_NAMING_1"] = "使用原名",
	["CO_CHAT_MAIN_NAMING_2"] = "使用自定义名称",
	["CO_CHAT_MAIN_NAMING_3"] = "名 + 姓",
	["CO_CHAT_MAIN_NAMING_4"] = "简称/代号 + 名 + 姓",
	["CO_CHAT_MAIN_NPC"] = "NPC 发言检测",
	["CO_CHAT_MAIN_NPC_PREFIX"] = "NPC 发言检测模式",
	["CO_CHAT_MAIN_NPC_PREFIX_TT"] = "如果在说、表情、小队或团队频道的话有这个前缀，它会被认为是NPC谈话。默认：\"|| \"（请去掉“但是保留||后面的空格）",
	["CO_CHAT_MAIN_NPC_USE"] = "使用 NPC 发言检测",
	["CO_CHAT_MAIN_OOC"] = "OOC 检测",
	["CO_CHAT_MAIN_OOC_COLOR"] = "OOC 检测",
	["CO_CHAT_MAIN_OOC_PATTERN"] = "OOC 检测方式",
	["CO_CHAT_MAIN_OOC_USE"] = "开启OOC检测",
	["CO_CHAT_MAIN_SPEECH"] = "发言检测",
	["CO_CHAT_MAIN_SPEECH_USE"] = "开启发言检测",
	["CO_CHAT_MAIN_SPEECH_USE_TT"] = "在/e表情动作当中以半角英文引号圈出的部分将被显示为像/说一样的白字。",
	["CO_CHAT_NPCSPEECH_REPLACEMENT"] = "在NPC发言中使用自定义的同伴名字",
	["CO_CHAT_NPCSPEECH_REPLACEMENT_TT"] = "如果一个同伴的名字出现在NPC演讲的对话框里，它将被上色，它的图标颜色将根据你给的设定显示。",
	["CO_CHAT_REMOVE_REALM"] = "从姓名版中移除角色服务器",
	["CO_CHAT_SHOW_OOC"] = "显示OOC标识",
	["CO_CHAT_USE"] = "使用聊天频道",
	["CO_CHAT_USE_ICONS"] = "显示玩家图标",
	["CO_CHAT_USE_SAY"] = "说话频道",
	["CO_CONFIGURATION"] = "设置",
	["CO_CURSOR_DISABLE_OOC"] = "OOC时禁用",
	["CO_CURSOR_DISABLE_OOC_TT"] = "当角色|r的角色扮演状态设置为|cffccccccOOC|r.时，禁用光标修改。",
	["CO_CURSOR_MODIFIER_KEY"] = "修改按键",
	["CO_CURSOR_MODIFIER_KEY_TT"] = "需要一个修改按键，用来按住并右键单击一个玩家，以防止意外的点击。",
	["CO_CURSOR_RIGHT_CLICK"] = "右击打开配置文件",
	["CO_CURSOR_RIGHT_CLICK_TT"] = [=[右键单击一个玩家来打开他的简介，如果他有的话。

|TInterface\Cursor\WorkOrders:25|t 当玩家有一个配置文件时，这个图标将被附加到游标上，你可以右键单击它们。

|cffcccccc注意:此功能在战斗中禁用。|r]=],
	["CO_CURSOR_TITLE"] = "光标互动",
	["CO_GENERAL"] = "常规设置",
	["CO_GENERAL_BROADCAST"] = "使用广播频道",
	["CO_GENERAL_BROADCAST_C"] = "广播频道名",
	["CO_GENERAL_BROADCAST_TT"] = "广播频道有很多功能。禁用它将禁用所有功能，如角色位置信息，播放环境声音，宝藏和路标访问...",
	["CO_GENERAL_CHANGELOCALE_ALERT"] = [=[是否现在重新加载以改变界面语言为%s？

 如果选择不重新加载，界面语言将在下次登录时改变。]=],
	["CO_GENERAL_COM"] = " 交流",
	["CO_GENERAL_DEFAULT_COLOR_PICKER"] = "默认的颜色选择器",
	["CO_GENERAL_DEFAULT_COLOR_PICKER_TT"] = "激活总是使用默认的颜色选择器。如果你正在使用一个颜色选择插件，这是很有用的。",
	["CO_GENERAL_HEAVY"] = "警告：文件太多.",
	["CO_GENERAL_HEAVY_TT"] = "当您的文件的总大小超过一个合理的值时，会发出警告.",
	["CO_GENERAL_LOCALE"] = "插件语言环境",
	["CO_GENERAL_MISC"] = "其他",
	["CO_GENERAL_NEW_VERSION"] = "更新提醒",
	["CO_GENERAL_NEW_VERSION_TT"] = "当有新版本可用时，接收提醒。",
	["CO_GENERAL_RESET_CUSTOM_COLORS"] = "重设自定义颜色",
	["CO_GENERAL_RESET_CUSTOM_COLORS_TT"] = "删除保存在颜色选择器中的所有自定义颜色。",
	["CO_GENERAL_RESET_CUSTOM_COLORS_WARNING"] = "您确定要删除保存在颜色选择器中的所有自定义颜色吗?",
	["CO_GENERAL_TT_SIZE"] = "信息提示文本大小",
	["CO_GENERAL_UI_ANIMATIONS"] = "UI 动画",
	["CO_GENERAL_UI_ANIMATIONS_TT"] = "激活UI动画。",
	["CO_GENERAL_UI_SOUNDS"] = "UI 声音",
	["CO_GENERAL_UI_SOUNDS_TT"] = "激活UI音效(打开窗口，切换选项卡，点击按钮)。",
	["CO_GLANCE_LOCK"] = "锁定栏",
	["CO_GLANCE_LOCK_TT"] = "防止栏被拖动",
	["CO_GLANCE_MAIN"] = "\"第一印象\" 条",
	["CO_GLANCE_PRESET_TRP2"] = "使用 Total RP 2 风格的位置",
	["CO_GLANCE_PRESET_TRP2_BUTTON"] = "使用",
	["CO_GLANCE_PRESET_TRP2_HELP"] = "使用快捷方式将栏位显示为TRP2风格：在目标框架的右边。",
	["CO_GLANCE_PRESET_TRP3"] = "总是使用TRP3样式的位置",
	["CO_GLANCE_PRESET_TRP3_HELP"] = "使用快捷方式将栏位显示为TRP3风格：在TRP3框架的底部。",
	["CO_GLANCE_RESET_TT"] = "将栏位复位到框架的左下角.",
	["CO_GLANCE_TT_ANCHOR"] = "工具提示锚点",
	["CO_HIDE_EMPTY_MAP_BUTTON"] = "在没有可用搜索时隐藏",
	["CO_LOCATION"] = "定位设置",
	["CO_LOCATION_ACTIVATE"] = "使用角色位置",
	["CO_LOCATION_ACTIVATE_TT"] = "启用角色定位系统，允许您扫描世界地图上的其他totalRP用户，并允许他们找到您。",
	["CO_LOCATION_DISABLE_CLASSIC_PVP"] = "当PVP状态开启时关闭定位功能",
	["CO_LOCATION_DISABLE_CLASSIC_PVP_TT"] = "当你处于PVP状态时不再反馈其他玩家的定位请求，这可以防止其他玩家用定位系统追踪你。",
	["CO_LOCATION_DISABLE_OOC"] = "当OOC时，禁用角色位置",
	["CO_LOCATION_DISABLE_OOC_TT"] = "当您将RP状态设置为非角色扮演状态OOC时，您将不会响应来自其他玩家的位置请求。",
	["CO_LOCATION_DISABLE_PVP"] = "角色标记为PVP状态时，禁用角色位置",
	["CO_LOCATION_DISABLE_PVP_TT"] = [=[当您被标记为PvP时，您将不会响应来自其他玩家的位置请求。

这个选项在PvP领域特别有用，其他阵营的玩家可以滥用位置系统来跟踪你。]=],
	["CO_LOCATION_DISABLE_WAR_MODE"] = "战争模式禁用位置系统",
	["CO_LOCATION_DISABLE_WAR_MODE_TT"] = [=[在启动战争模式并位于|cff69CCF0安全区|r外时，你不会对其他玩家的位置搜索发出回应。

这可以防止恶意玩家搜索并击杀你。]=],
	["CO_LOCATION_SHOW_DIFFERENT_WAR_MODES"] = "显示不同战争位面下的玩家",
	["CO_LOCATION_SHOW_DIFFERENT_WAR_MODES_TT"] = "和你在同一区域，但位于不同战争位面的玩家将仍然显示在地图上，但他们的图标透明度较高且有着一个特殊的标志。",
	["CO_MAP_BUTTON"] = "地图搜索按钮",
	["CO_MAP_BUTTON_POS"] = "搜索按钮在地图上位置",
	["CO_MINIMAP_BUTTON"] = "小地图按钮",
	["CO_MINIMAP_BUTTON_FRAME"] = "框架锚点",
	["CO_MINIMAP_BUTTON_RESET"] = "重置位置",
	["CO_MINIMAP_BUTTON_RESET_BUTTON"] = "重置",
	["CO_MINIMAP_BUTTON_SHOW_HELP"] = [=[如果您正在使用另一个插件来显示Total rp3的小地图按钮(FuBar, Titan, Bazooka)，您可以从小地图中删除该按钮。

| cff00ff00 提醒:您可以使用 /trp3 switch main |r打开trp3]=],
	["CO_MINIMAP_BUTTON_SHOW_TITLE"] = "显示小地图按钮",
	["CO_MODULES"] = "模块状态",
	["CO_MODULES_DISABLE"] = "禁用模块",
	["CO_MODULES_ENABLE"] = "启用模块",
	["CO_MODULES_ID"] = "模块ID: %s",
	["CO_MODULES_SHOWERROR"] = "显示错误",
	["CO_MODULES_STATUS"] = "状态: %s",
	["CO_MODULES_STATUS_0"] = "缺少依赖组件",
	["CO_MODULES_STATUS_1"] = "已载入",
	["CO_MODULES_STATUS_2"] = "已禁用",
	["CO_MODULES_STATUS_3"] = [=[Total RP 3 需要更新
]=],
	["CO_MODULES_STATUS_4"] = "初始化错误",
	["CO_MODULES_STATUS_5"] = "启动错误",
	["CO_MODULES_TT_DEP"] = "%s- %s (版本 %s)|r",
	["CO_MODULES_TT_DEPS"] = "依赖关系",
	["CO_MODULES_TT_ERROR"] = [=[|cffff0000错误:|r
%s]=],
	["CO_MODULES_TT_NONE"] = "没有依赖关系",
	["CO_MODULES_TT_TRP"] = "%s Total RP 3 版本 %s 最小值.|r",
	["CO_MODULES_TUTO"] = [=[模块是独立的，并可以启用或禁用.

可能的状态:
|cff00ff00加载:|r 模块启用并加载.
|cff999999关闭:|r 模块已关闭.
|cffff9900缺少的依赖关系:|r 一些依赖项没有加载.
|cffff9900TRP 需要更新:|r 这个模块需要一个更新版本的 TRP3.
|cffff0000初始化或启动时的错误:|r 模块加载失败。这个模块很可能会产生错误！
|cffff9900当禁用模块时，需要重新加载UI.]=],
	["CO_MODULES_VERSION"] = "版本: %s",
	["CO_MSP"] = "玛丽苏协议",
	["CO_MSP_T3"] = "只使用模板3",
	["CO_MSP_T3_TT"] = "遵循玛丽苏协议，\\\"人物卡\\\" 模板只能使用三个模板式样.一些人物卡配置文件可以用其他RP插件打开（但是这些插件不能共存）",
	["CO_REGISTER"] = "登记设置",
	["CO_REGISTER_ABOUT_H1_SIZE"] = "一级标题字号",
	["CO_REGISTER_ABOUT_H1_SIZE_TT"] = "{h1}标题的字号，当前：%s",
	["CO_REGISTER_ABOUT_H2_SIZE"] = "二级标题字号",
	["CO_REGISTER_ABOUT_H2_SIZE_TT"] = "{h2}标题的字号，当前：%s",
	["CO_REGISTER_ABOUT_H3_SIZE"] = "三级标题字号",
	["CO_REGISTER_ABOUT_H3_SIZE_TT"] = "{h3}标题的字号，当前：%s",
	["CO_REGISTER_ABOUT_P_SIZE"] = "文本字号",
	["CO_REGISTER_ABOUT_P_SIZE_TT"] = "不属于标题的文本的字号，当前：%s",
	["CO_REGISTER_ABOUT_SETTINGS"] = "\"关于\"设定",
	["CO_REGISTER_ABOUT_VOTE"] = "使用投票系统",
	["CO_REGISTER_ABOUT_VOTE_TT"] = "启用投票系统，允许你对其他人的描述进行投票(“喜欢”或“不喜欢”)，并允许他们对你做同样的事情。",
	["CO_REGISTER_AUTO_ADD"] = "自动添加新玩家",
	["CO_REGISTER_AUTO_ADD_TT"] = [=[自动添加你遇到的新玩家.

|cffff0000注意:禁用此选项将阻止您从尚未遇到的玩家获得任何新的配置文件！如果你不想收到其他玩家的新资料，只需要更新你已经看过的玩家，就可以使用这个选项。]=],
	["CO_REGISTER_AUTO_PURGE"] = "自动清理玩家目录",
	["CO_REGISTER_AUTO_PURGE_0"] = "禁用自动清理",
	["CO_REGISTER_AUTO_PURGE_1"] = "在 %s 天后",
	["CO_REGISTER_AUTO_PURGE_TT"] = [=[自动从目录中删除你在一定时间内没有遇到的角色。你可以设定这个时间跨度

|cff00ff00请注意，与您的一个角色有关系的玩家数据永远不会被清除。

|cffff9900但这有一个bug，当它到达某个特定的值时，它会丢失所有被保存的数据。我们强烈建议保持这个系统以免整体失效。]=],
	["CO_SANITIZER"] = "过滤传入的文件",
	["CO_SANITIZER_TT"] = "当接收TRP不支持的颜色、图片等信息时对其进行自动过滤。",
	["CO_TARGETFRAME"] = "目标框架设置",
	["CO_TARGETFRAME_ICON_SIZE"] = "图标尺寸",
	["CO_TARGETFRAME_USE"] = "显示条件",
	["CO_TARGETFRAME_USE_1"] = "总是",
	["CO_TARGETFRAME_USE_2"] = "只有在 IC时",
	["CO_TARGETFRAME_USE_3"] = "从不 (关闭)",
	["CO_TARGETFRAME_USE_TT"] = "确定选定目标时显示目标框架的条件。",
	["CO_TOOLBAR"] = "框架设置",
	["CO_TOOLBAR_CONTENT"] = "工具栏设置",
	["CO_TOOLBAR_CONTENT_CAPE"] = "披风开关",
	["CO_TOOLBAR_CONTENT_HELMET"] = "头盔开关",
	["CO_TOOLBAR_CONTENT_RPSTATUS"] = "角色状态 (IC/OOC)",
	["CO_TOOLBAR_CONTENT_STATUS"] = "玩家状态 (AFK/DND)",
	["CO_TOOLBAR_HIDE_TITLE"] = "隐藏工具栏标题",
	["CO_TOOLBAR_HIDE_TITLE_HELP"] = "隐藏工具栏上方显示的标题。",
	["CO_TOOLBAR_ICON_SIZE"] = "图标设置",
	["CO_TOOLBAR_MAX"] = "每一行最多图标数",
	["CO_TOOLBAR_MAX_TT"] = "如果你想垂直显示工具条，请设置为1",
	["CO_TOOLBAR_SHOW_ON_LOGIN"] = "在登录时显示工具栏",
	["CO_TOOLBAR_SHOW_ON_LOGIN_HELP"] = "如果您不想在登录时显示工具栏，您可以禁用该选项.",
	["CO_TOOLTIP"] = "工具栏设置",
	["CO_TOOLTIP_ANCHOR"] = "固定点/锚点",
	["CO_TOOLTIP_ANCHORED"] = "固定框架",
	["CO_TOOLTIP_CHARACTER"] = "角色工具栏",
	["CO_TOOLTIP_CLIENT"] = "显示客户端",
	["CO_TOOLTIP_COLOR"] = "显示自定义颜色",
	["CO_TOOLTIP_COMBAT"] = "战斗时隐藏",
	["CO_TOOLTIP_COMMON"] = "普通设置",
	["CO_TOOLTIP_CONTRAST"] = "增加颜色对比",
	["CO_TOOLTIP_CONTRAST_TT"] = "启用这个选项允许Total RP 3自动修改自定义颜色，使文本在颜色太暗时更易读。",
	["CO_TOOLTIP_CROP_TEXT"] = "裁剪不合理的长文本",
	["CO_TOOLTIP_CROP_TEXT_TT"] = [=[限制框架中每个字段可以显示的字符数量，以防止不合理的长文本和可能的布局问题。

|cfffff569限制细节:
名字: 100 字符
标题: 150 字符
种族:  50 字符
职业:  50 字符|r]=],
	["CO_TOOLTIP_CURRENT"] = "显示“当前”的信息",
	["CO_TOOLTIP_CURRENT_LINES"] = "“当前”信息的最大行数",
	["CO_TOOLTIP_CURRENT_SIZE"] = "“当前”信息的最大长度",
	["CO_TOOLTIP_FT"] = "显示完整称号",
	["CO_TOOLTIP_GUILD"] = "显示公会信息",
	["CO_TOOLTIP_HEALTH"] = "显示生命值",
	["CO_TOOLTIP_HEALTH_BOTH"] = "数字+百分比",
	["CO_TOOLTIP_HEALTH_DISABLED"] = "禁用",
	["CO_TOOLTIP_HEALTH_NUMBER"] = "数字",
	["CO_TOOLTIP_HEALTH_PERCENT"] = "百分比",
	["CO_TOOLTIP_HEALTH_TT"] = "仅在目标生命值不满时显示。",
	["CO_TOOLTIP_HIDE_IN_INSTANCE"] = "在副本中隐藏",
	["CO_TOOLTIP_HIDE_ORIGINAL"] = "隐藏原始工具栏",
	["CO_TOOLTIP_ICONS"] = "显示图标",
	["CO_TOOLTIP_IN_CHARACTER_ONLY"] = "OOC状态时隐藏描述",
	["CO_TOOLTIP_MAINSIZE"] = "主字体大小",
	["CO_TOOLTIP_NO_FADE_OUT"] = "立即隐藏而不是淡出",
	["CO_TOOLTIP_NOTIF"] = "显示通知",
	["CO_TOOLTIP_NOTIF_TT"] = "通知栏显示的是客户端版本，未读描述标志和第一印象”标志。",
	["CO_TOOLTIP_OWNER"] = "显示所有者",
	["CO_TOOLTIP_PETS"] = "同伴工具栏",
	["CO_TOOLTIP_PETS_INFO"] = "显示同伴信息",
	["CO_TOOLTIP_PREFERRED_OOC_INDICATOR"] = "首选OOC指示器",
	["CO_TOOLTIP_PREFERRED_OOC_INDICATOR_ICON"] = "图标：",
	["CO_TOOLTIP_PREFERRED_OOC_INDICATOR_TEXT"] = "文本：",
	["CO_TOOLTIP_PROFILE_ONLY"] = "仅当目标具有配置文件时才使用。",
	["CO_TOOLTIP_PRONOUNS"] = "显示人称代词",
	["CO_TOOLTIP_RACE"] = "显示种族, 职业和等级",
	["CO_TOOLTIP_REALM"] = "显示服务器",
	["CO_TOOLTIP_RELATION"] = "显示关系颜色",
	["CO_TOOLTIP_RELATION_TT"] = "设置一个颜色来表示角色间的关系.",
	["CO_TOOLTIP_SPACING"] = "显示间距",
	["CO_TOOLTIP_SPACING_TT"] = "MyRoleplay 工具栏风格，用额外空间使显示间距更明显。",
	["CO_TOOLTIP_SUBSIZE"] = "二级字体大小",
	["CO_TOOLTIP_TARGET"] = "显示目标",
	["CO_TOOLTIP_TERSIZE"] = "三级字体大小",
	["CO_TOOLTIP_TITLE"] = "显示标题",
	["CO_TOOLTIP_USE"] = "使用字符/同伴工具提示",
	["CO_TOOLTIP_ZONE"] = "显示地区",
	["CO_TOOLTIP_ZONE_TT"] = "仅在目标与你不在同一区域时显示。",
	["CO_UI_RELOAD_WARNING"] = [=[需要重新加载界面，以便应用更改。
您现在要重新加载界面吗?]=],
	["CO_WIM"] = "|cffff9900 悄悄话频道是禁用的。",
	["CO_WIM_TT"] = "您正在使用| cff00密语 |r，悄悄话频道的处理出于兼容性的目的被禁用",
	["COM_LIST"] = "命令列表：",
	["COM_RESET_RESET"] = "界面位置已经被重置！",
	["COM_RESET_USAGE"] = "使用：重置你的所有界面位置。",
	["COM_STASH_DATA"] = [=[|cffff0000你确定你想要隐藏你的 Total RP 3 数据?|r

你的个人资料、伙伴档案和设置会暂时被隐藏起来，你的UI会重新载入临时的空数据，就像你刚安装TRP3时一样。
|cff00ff00U再次使用相同命令 (|cff999999/trp3 stash|cff00ff00) 恢复您的数据。|r]=],
	["COM_SWITCH_USAGE"] = "使用：重置界面或者切换工具栏。",
	["CONFIG_COMMS_QUEUE_POOL_COUNT"] = "排队池大小",
	["CONFIG_COMMS_QUEUE_POOL_COUNT_DESCRIPTION"] = "控制资料传输时的排队池大小。|n|n较低的值会降低非RP资料传输的延迟，但会在人员密集场合影响向其他玩家传输RP资料的速度。",
	["CONFIG_COMMS_QUEUE_POOL_WEIGHT_THRESHOLD"] = "排队池权重阈值",
	["CONFIG_COMMS_QUEUE_POOL_WEIGHT_THRESHOLD_DESCRIPTION"] = "控制在使用排队池前RP资料的大小阈值。|n|n对于大数据资料，增加这个值将|cffff0000严重降低|r 插件数据传输的效率。",
	["CONFIG_COMMS_SETTINGS_HEADER"] = "通信设置",
	["COPY_DROPDOWN_POPUP_TEXT"] = [=[以%1$s复制。以%2$s粘贴。
	本窗口会在复制后关闭]=],
	["COPY_SYSTEM_MESSAGE"] = "已复制到剪切板。",
	["CREDITS_DISCORD_LINK_TEXT"] = "加入我们的Discord",
	["CREDITS_GUILD_NAME"] = "<%1$s>",
	["CREDITS_NAME_WITH_ROLE"] = "%1$s (%2$s)",
	["CREDITS_VERSION_TEXT"] = "版本 %s",
	["CREDITS_WEBSITE_LINK_TEXT"] = "网站",
	["DB_ABOUT"] = "关于 Total RP 3",
	["DB_HTML_GOTO"] = "单击打开",
	["DB_MORE"] = "更多模组",
	["DB_NEW"] = "更新了什么?",
	["DB_STATUS"] = "状态",
	["DB_STATUS_CURRENTLY"] = "当前 (IC)",
	["DB_STATUS_CURRENTLY_COMMON"] = "这些状态将显示在您的角色的工具提示上。请尽量保持简洁因为|cffff9900 默认状态下TRP3使用者只能看到前140个字符。",
	["DB_STATUS_CURRENTLY_OOC"] = "其它信息 (OOC)",
	["DB_STATUS_CURRENTLY_OOC_TT"] = "在这里你可以列出你的一些重要的东西，无论是IC的还是OOC的。",
	["DB_STATUS_CURRENTLY_TT"] = "在这里你可以列出你的一些重要的东西。",
	["DB_STATUS_ICON_ITEM"] = "%1$s %2$s",
	["DB_STATUS_LC"] = "角色扮演语言",
	["DB_STATUS_LC_DEFAULT"] = "默认(%1$s)",
	["DB_STATUS_LC_TT"] = "设置你扮演时使用的语言，本状态将与其他兼容的RP插件使用者同步。 |cffff9900注意：|r 该选项|cffff0000不会|r改变TRP3的界面语言，修改界面语言的设置位于 |cfffff569高级设置|r页面。",
	["DB_STATUS_RP"] = "角色状态",
	["DB_STATUS_RP_EXP"] = "严谨RP玩家",
	["DB_STATUS_RP_EXP_TT"] = "表明你是一个经验丰富的RP玩家.\\n不会在你的工具提示中显示任何特定的图标.",
	["DB_STATUS_RP_IC"] = "IC",
	["DB_STATUS_RP_IC_TT"] = [=[这说明你正在扮演你的角色.
你所有的动作行为将被解释为你角色的行为.]=],
	["DB_STATUS_RP_OOC"] = "OOC，不在RP",
	["DB_STATUS_RP_OOC_TT"] = [=[你不在扮演你的角色.
你的言行和你的角色没有必然联系.]=],
	["DB_STATUS_RP_VOLUNTEER"] = "RP玩家志愿者",
	["DB_STATUS_RP_VOLUNTEER_TT"] = [=[这个选择将在你的工具提示上显示一个图标, 
表示你愿意帮助他们中的角色扮演新手.]=],
	["DB_STATUS_XP"] = "玩家状态",
	["DB_STATUS_XP_BEGINNER"] = "RP新人",
	["DB_STATUS_XP_BEGINNER_TT"] = [=[这个选择将在你的工具提示上显示一个图标，
表示你是新手玩家.]=],
	["DB_TUTO_1"] = [=[|cffffff00角色状态|r 表示您当前是否在扮演角色.

|cffffff00角色状态|r 允许你说明你是一个初学者或者是一个愿意帮助新手的老手!

|cff00ff00这些信息将被放置在你的角色的工具栏中.]=],
	["DICE_HELP"] = "摇一个或者多个色子，定义几个面，例如: 1d6, 2d12 3d20 ...",
	["DICE_ROLL"] = "%s roll点 |cffff9900%sx d%s|r 得到了 |cff00ff00%s|r.",
	["DICE_ROLL_T"] = "%s %s roll点 |cffff9900%sx d%s|r 得到了 |cff00ff00%s|r.",
	["DICE_TOTAL"] = "%s 总共roll到了 |cff00ff00%s|r .",
	["DICE_TOTAL_T"] = "%s %s 总共roll到了 |cff00ff00%s|r .",
	["DTBK_AFK"] = "Total RP 3 - AFK/DND",
	["DTBK_CLOAK"] = "Total RP 3 - 披风",
	["DTBK_HELMET"] = "Total RP 3 - 头盔",
	["DTBK_LANGUAGES"] = "Total RP 3 - 语言",
	["DTBK_RP"] = "Total RP 3 - IC/OOC",
	["GEN_VERSION"] = "版本: %s (Build %s)",
	["GEN_WELCOME_MESSAGE"] = "感谢使用 Total RP 3 (v %s) ! Have fun !",
	["KUI_NAMEPLATES_MODULE_DESCRIPTION"] = "启动对Kui姓名版的自定义功能",
	["KUI_NAMEPLATES_MODULE_NAME"] = "Kui姓名版",
	["KUI_NAMEPLATES_WARN_OUTDATED_MODULE"] = "TRP3的Kui|cff9966ff姓名版|r功能已经被整合进插件本体。|n|n旧插件已自动被禁用。|cffffcc00我们推荐将其卸载|r。",
	["LANG_CHANGE_CAUSED_REVERT_TO_DEFAULT"] = "当前语言恢复到默认的%s，因为您不再了解先前选择的语言%s。",
	["MAP_BUTTON_NO_SCAN"] = "没有搜到",
	["MAP_BUTTON_SCANNING"] = "搜索",
	["MAP_BUTTON_SUBTITLE"] = "点击显示可用的搜索",
	["MAP_BUTTON_SUBTITLE_80_DISABLED"] = "由于8.0更改，扫描暂时不可用",
	["MAP_BUTTON_SUBTITLE_CONNECTING"] = "地图扫描正在建立。请稍等。",
	["MAP_BUTTON_SUBTITLE_OFFLINE"] = "地图扫描现在不可用:%s",
	["MAP_BUTTON_TITLE"] = "搜索RP",
	["MAP_SCAN_CHAR"] = "搜索角色",
	["MAP_SCAN_CHAR_TITLE"] = "角色",
	["MATURE_FILTER_ADD_TO_SAFELIST"] = "将这个资料卡加入|cffffffff成人信息白名单|r",
	["MATURE_FILTER_ADD_TO_SAFELIST_OPTION"] = "添加到|cffffffff成人信息白名单|r",
	["MATURE_FILTER_ADD_TO_SAFELIST_TEXT"] = "请确认将%s加入|cffffffff成人信息白名单|r，他们资料卡的信息将不再被隐藏。",
	["MATURE_FILTER_ADD_TO_SAFELIST_TT"] = "将这个资料卡加入|cffffffff成人信息白名单|r并显示其中的成人内容。",
	["MATURE_FILTER_ADD_TO_WHITELIST"] = "将这个玩家文件添加到 |cffffffff白名单|r",
	["MATURE_FILTER_ADD_TO_WHITELIST_OPTION"] = "添加到 |cffffffff白名单|r",
	["MATURE_FILTER_ADD_TO_WHITELIST_TEXT"] = [=[确认你想要添加 %s 到 |cffffffff白名单|r.

他们个人资料的内容将不再被隐藏。]=],
	["MATURE_FILTER_ADD_TO_WHITELIST_TT"] = "将这个玩家文件添加到| cffffffff白名单| r并显示里面的成年人的内容。",
	["MATURE_FILTER_EDIT_DICTIONARY"] = "编辑自定义字典",
	["MATURE_FILTER_EDIT_DICTIONARY_ADD_BUTTON"] = "添加",
	["MATURE_FILTER_EDIT_DICTIONARY_ADD_TEXT"] = "在字典中添加一个新单词",
	["MATURE_FILTER_EDIT_DICTIONARY_BUTTON"] = "编辑",
	["MATURE_FILTER_EDIT_DICTIONARY_DELETE_WORD"] = "从自定义字典中删除单词",
	["MATURE_FILTER_EDIT_DICTIONARY_EDIT_WORD"] = "编辑这个词",
	["MATURE_FILTER_EDIT_DICTIONARY_RESET_BUTTON"] = "重置",
	["MATURE_FILTER_EDIT_DICTIONARY_RESET_TITLE"] = "重置字典",
	["MATURE_FILTER_EDIT_DICTIONARY_RESET_WARNING"] = "你确定要重新设置字典吗?这将清空字典，并在字典中填充为当前语言提供的默认单词(如果可用)。",
	["MATURE_FILTER_EDIT_DICTIONARY_TITLE"] = "自定义字典编辑器",
	["MATURE_FILTER_EDIT_DICTIONARY_TT"] = "编辑用于筛选成年人配置文件的自定义字典.",
	["MATURE_FILTER_FLAG_PLAYER"] = "标记为成年人玩家",
	["MATURE_FILTER_FLAG_PLAYER_OPTION"] = "标记成年人内容",
	["MATURE_FILTER_FLAG_PLAYER_TEXT"] = [=[确认您想要标记 %s的资料含有不适内容. 文本内容会被隐藏.

|cffffff00可选择的:|r 指出在这个玩家文件中找到的攻击性词(由空格分隔开)并将它们添加到过滤器中.]=],
	["MATURE_FILTER_FLAG_PLAYER_TT"] = "标记这个角色会发布不适内容。标记后该角色发言会被隐藏.",
	["MATURE_FILTER_OPTION"] = "启动关键字过滤",
	["MATURE_FILTER_OPTION_TT"] = [=[检查该选项,以过滤玩家信息当中的成人内容。Total RP 3将在扫描玩家信息时检测特定的关键词，并在找到这些词的情况下将玩家数据标记为成年人。

成人信息文件将有一个“消音”的提示，当你首次打开这种文件时，你需要确认是否要打开它。

|cffcccccc注意:成年人的过滤器字典预先填充了来自大众词库的单词列表。您可以使用下面的选项编辑词典|r]=],
	["MATURE_FILTER_REMOVE_FROM_SAFELIST"] = "将这个资料卡移出|cffffffff成人信息白名单|r",
	["MATURE_FILTER_REMOVE_FROM_SAFELIST_OPTION"] = "从|cffffffff成人信息白名单|r移除",
	["MATURE_FILTER_REMOVE_FROM_SAFELIST_TEXT"] = "请确认将%s移出|cffffffff成人信息白名单|r，他们资料卡的信息将再次被隐藏。",
	["MATURE_FILTER_REMOVE_FROM_SAFELIST_TT"] = "将这个资料卡加入|cffffffff成人信息白名单|r并隐藏其中的成人内容。",
	["MATURE_FILTER_REMOVE_FROM_WHITELIST"] = "从 |cffffffff白名单|r 当中删除这个文件并隐藏在里面的成人内容。",
	["MATURE_FILTER_REMOVE_FROM_WHITELIST_OPTION"] = "从 |cffffffff白名单|r当中移除",
	["MATURE_FILTER_REMOVE_FROM_WHITELIST_TEXT"] = [=[确认你想从 |cffffffff白名单|r中移除 %s 。

他的玩家文件的内容将再次被隐藏.]=],
	["MATURE_FILTER_REMOVE_FROM_WHITELIST_TT"] = "从 |cffffffff白名单|r 当中移除这个玩家并再次隐藏他的成人内容。",
	["MATURE_FILTER_STRENGTH"] = "分级过滤器强度",
	["MATURE_FILTER_STRENGTH_TT"] = [=[设置分级过滤器的强度。
| cffcccccccc1是最弱的(表示需要10个成人词汇)，10个是最强的(表示需要1个成人词汇)]=],
	["MATURE_FILTER_TITLE"] = "关键字过滤",
	["MATURE_FILTER_TOOLTIP_WARNING"] = "成年人的内容",
	["MATURE_FILTER_TOOLTIP_WARNING_SUBTEXT"] = "这个玩家文件包含成年人的内容。你可以使用工具栏的按钮来显示这些内容。",
	["MATURE_FILTER_WARNING_CONTINUE"] = "继续",
	["MATURE_FILTER_WARNING_GO_BACK"] = "返回",
	["MATURE_FILTER_WARNING_TEXT"] = [=[TRP 3 内容过滤系统启用。


这个玩家文件包含被过滤的关键字内容。


你确定你想显示这个文件吗？]=],
	["MATURE_FILTER_WARNING_TITLE"] = "分级",
	["MM_SHOW_HIDE_MAIN"] = "显示/隐藏主要框架",
	["MM_SHOW_HIDE_MOVE"] = "移动按钮",
	["MM_SHOW_HIDE_SHORTCUT"] = "显示/隐藏工具栏",
	["MO_ADDON_NOT_INSTALLED"] = "没有安装%s附加组件，自定义Total rp3集成被禁用。",
	["MO_CHAT_CUSTOMIZATIONS_DESCRIPTION"] = "为%s插件添加自定义兼容性，以便Total rp3可以修改那个插件产生的聊天信息和玩家姓名。",
	["MO_TOOLTIP_CUSTOMIZATIONS_DESCRIPTION"] = "为%s加载项添加自定义兼容性，以便您的工具提示首选项应用于Total rp3的工具提示。",
	["MORE_MODULES_2"] = [=[{h2:c}Optional modules{/h2}
{h3}Total RP 3: Extended{/h3}
|cff9999ffTotal RP 3: Extended|r 让你在魔兽世界当中可以自定义内容: 包含任务和对话的剧情，物品，文件 (书本，标志，协议…)以及更多！
Total RP3扩展包 包括任务 对话 物品 文档等
{link*https://www.curseforge.com/wow/addons/total-rp-3-extended*Download on CurseForge}

{h3}TRP3 Currently Frame{/h3}
Adds a standalone frame to your UI that displays your "Currently" text and allows you to edit it easily.
{link*https://www.curseforge.com/wow/addons/trp3-currently-frame*Download on CurseForge}

{h3}TRP3 Location Toggle{/h3}
Adds a simple button to the toolbar to toggle on and off the map scan location feature.
{link*https://www.curseforge.com/wow/addons/trp3-location-toggle*Download on CurseForge}]=],
	["NAMEPLATES_CONFIG_ACTIVE_QUERY"] = "自动获取人物卡",
	["NAMEPLATES_CONFIG_ACTIVE_QUERY_HELP"] = "如果勾选，自动获取有姓名版的单位的人物卡。",
	["NAMEPLATES_CONFIG_BLIZZARD_NAME_ONLY"] = "隐藏|cff449fe0暴雪|r姓名版",
	["NAMEPLATES_CONFIG_BLIZZARD_NAME_ONLY_HELP"] = "如果勾选，将启动|cff449fe0暴雪|r姓名版的仅显示姓名模式。|n|n在该模式下，所有血条会被隐藏，包括敌方单位的和其他玩家的，不论他们是否有人物卡。|n|n本选项需要重载界面生效。",
	["NAMEPLATES_CONFIG_CUSTOMIZE_FULL_TITLES"] = "显示全名",
	["NAMEPLATES_CONFIG_CUSTOMIZE_FULL_TITLES_HELP"] = "如果勾选，将在姓名版显示单位的全名。|n|n对于|cff449fe0暴雪|r和|cff9966ffKui|r姓名版来说，只有在隐藏姓名版模式下才会显示全名。",
	["NAMEPLATES_CONFIG_CUSTOMIZE_HEALTH_COLORS"] = "显示自定义血条颜色",
	["NAMEPLATES_CONFIG_CUSTOMIZE_HEALTH_COLORS_HELP"] = "如果勾选，将用人物卡的职业颜色代替目标血条的颜色。",
	["NAMEPLATES_CONFIG_CUSTOMIZE_ICONS"] = "显示图标",
	["NAMEPLATES_CONFIG_CUSTOMIZE_ICONS_HELP"] = "如果勾选，将在姓名版上显示人物卡图标。",
	["NAMEPLATES_CONFIG_CUSTOMIZE_NAME_COLORS"] = "显示自定义姓名颜色",
	["NAMEPLATES_CONFIG_CUSTOMIZE_NAME_COLORS_HELP"] = "如果勾选，将用人物卡的姓名颜色代替姓名版的颜色",
	["NAMEPLATES_CONFIG_CUSTOMIZE_NAMES"] = "显示自定义姓名",
	["NAMEPLATES_CONFIG_CUSTOMIZE_NAMES_HELP"] = "如果勾选，将用人物卡姓名代替姓名版的姓名",
	["NAMEPLATES_CONFIG_CUSTOMIZE_ROLEPLAY_STATUS"] = "显示RP状态",
	["NAMEPLATES_CONFIG_CUSTOMIZE_ROLEPLAY_STATUS_HELP"] = "如果勾选，将在RP姓名版上显示当前RP状态（IC或OOC）。",
	["NAMEPLATES_CONFIG_CUSTOMIZE_TITLES"] = "显示头衔",
	["NAMEPLATES_CONFIG_CUSTOMIZE_TITLES_HELP"] = "如果勾选，将在姓名版上显示人物卡中的头衔。",
	["NAMEPLATES_CONFIG_DISABLE_IN_COMBAT"] = "战斗中关闭姓名版配置",
	["NAMEPLATES_CONFIG_DISABLE_IN_COMBAT_HELP"] = "如果勾选，将在战斗中还原姓名版设置。",
	["NAMEPLATES_CONFIG_DISABLE_OUT_OF_CHARACTER"] = "OOC时关闭姓名版配置",
	["NAMEPLATES_CONFIG_DISABLE_OUT_OF_CHARACTER_HELP"] = "如果勾选，将在OOC状态时还原姓名版设置。",
	["NAMEPLATES_CONFIG_DISABLE_OUT_OF_CHARACTER_UNITS"] = "关闭OOC目标的姓名版配置",
	["NAMEPLATES_CONFIG_DISABLE_OUT_OF_CHARACTER_UNITS_HELP"] = "如果勾选，将还原OOC目标的姓名版配置",
	["NAMEPLATES_CONFIG_ELEMENT_HEADER"] = "姓名版配置",
	["NAMEPLATES_CONFIG_ENABLE_CLASS_COLOR_FALLBACK"] = "使用默认职业颜色",
	["NAMEPLATES_CONFIG_ENABLE_CLASS_COLOR_FALLBACK_HELP"] = "如果勾选，将在姓名版上用职业颜色代替没有设置职业颜色的角色颜色。|n|n没有RP人物卡的目标不会被此效果影响，会使用默认颜色。",
	["NAMEPLATES_CONFIG_HIDE_NON_ROLEPLAY_UNITS"] = "隐藏非RP目标姓名版",
	["NAMEPLATES_CONFIG_HIDE_NON_ROLEPLAY_UNITS_HELP"] = "如果勾选，将隐藏没有人物卡的目标（包括玩家和宠物）的姓名版。",
	["NAMEPLATES_CONFIG_HIDE_OUT_OF_CHARACTER_UNITS"] = "隐藏OOC目标姓名版",
	["NAMEPLATES_CONFIG_HIDE_OUT_OF_CHARACTER_UNITS_HELP"] = "如果勾选，将隐藏OOC状态目标的姓名版。",
	["NAMEPLATES_CONFIG_ICON_SIZE"] = "图标大小",
	["NAMEPLATES_CONFIG_ICON_SIZE_HELP"] = "如果|cffffff00显示图标|r功能启动，调整姓名版上图标的大小。",
	["NAMEPLATES_CONFIG_MENU_TITLE"] = "姓名版",
	["NAMEPLATES_CONFIG_PAGE_HELP"] = "请注意目前只支持|cff449fe0暴雪|r和|cff9966ffKui|r姓名版。请阅读设置选项下方的说明来了解如何设置。",
	["NAMEPLATES_CONFIG_PAGE_TEXT"] = "姓名版设置",
	["NAMEPLATES_CONFIG_VISIBILITY_HEADER"] = "可见度设置",
	["NAMEPLATES_MODULE_ACTIVE_STATUS"] = "模块|cff00ff00启动|r (%1$s|r)",
	["NAMEPLATES_MODULE_DESCRIPTION"] = "启动基于人物卡信息的姓名版功能。",
	["NAMEPLATES_MODULE_DISABLE_WARNING"] = "关闭姓名版模块将关闭所有的自定义姓名版功能，本选项需要重载界面生效。|n|n|cffff0000警告|r一旦关闭，本模组只能从|cffffcc00模组状态|r窗口重新启动。|n|n你确定要关闭这个模组吗？",
	["NAMEPLATES_MODULE_DISABLED_BY_DEPENDENCY"] = "由于缺少关联文件，本模组已自动关闭。",
	["NAMEPLATES_MODULE_DISABLED_BY_EXTERNAL"] = "由于与其他模组或插件冲突，本模组已自动关闭。",
	["NAMEPLATES_MODULE_INACTIVE_STATUS"] = "模组|cffff9900未生效|r（未找到插件）",
	["NAMEPLATES_MODULE_NAME"] = "姓名版",
	["NEW_VERSION"] = [=[|cff00ff00TRP3的一个新版本(v %s)已可用。

	|cffffff00我们强烈建议你升级插件。|r
	
	本消息每次游戏只会显示一次并可在设置中关闭(通用设置=>杂项)。]=],
	["NEW_VERSION_BEHIND"] = "你当前落后%s个版本因而缺少bug修复和新功能，其他玩家可能无法正确看到你的人物卡。请考虑升级插件。",
	["NEW_VERSION_TITLE"] = "新的更新可用",
	["NPC_TALK_BUTTON_TT"] = "打开NPC发言界面，允许你让 NPC 说话或做表情。",
	["NPC_TALK_CHANNEL"] = "频道: ",
	["NPC_TALK_COMMAND_HELP"] = "打开 NPC 发言界面.",
	["NPC_TALK_ERROR_EMPTY_MESSAGE"] = "消息不能为空.",
	["NPC_TALK_MESSAGE"] = "消息",
	["NPC_TALK_NAME"] = "NPC 名字",
	["NPC_TALK_NAME_TT"] = [=[你可以使用像 %t 这样的标准聊天标签插入你的目标名或 %f 来插入你的焦点的名字.

您还可以在不使用NPC名字的情况下，将这个字段清空以创建表情。
]=],
	["NPC_TALK_SAY_PATTERN"] = "说:",
	["NPC_TALK_SEND"] = "发送",
	["NPC_TALK_TITLE"] = "NPC 发言",
	["NPC_TALK_WHISPER_PATTERN"] = "悄悄说：",
	["NPC_TALK_YELL_PATTERN"] = "喊:",
	["OPTION_DISABLED_TOAST"] = "禁用选项",
	["OPTION_ENABLED_TOAST"] = "启用选项",
	["PATTERN_ERROR"] = "模式错误",
	["PATTERN_ERROR_TAG"] = "格式错误:未完成的文本标记",
	["PR_CO_BATTLE"] = "战斗宠物",
	["PR_CO_COUNT"] = "%s 绑定到人物卡的宠物/坐骑。",
	["PR_CO_EMPTY"] = "没有同伴卡",
	["PR_CO_MASTERS"] = "主人",
	["PR_CO_MOUNT"] = "坐骑",
	["PR_CO_NEW_PROFILE"] = "新建同伴卡",
	["PR_CO_PET"] = "宠物",
	["PR_CO_PROFILE_DETAIL"] = "这张同伴卡已被绑定到",
	["PR_CO_PROFILE_HELP"] = [=[一个同伴卡包括 |cffffff00"宠物"|r 作为 |cff00ff00一个RP角色|r的所有信息。

同伴卡可以绑定到:
- 一只战斗宠物 |cffff9900(在它已经被命名的情况下)|r
- 一个猎人的宠物
- 一个术士的恶魔
- 一个法师元素
- 一个死亡骑士食尸鬼 |cffff9900(见下文)|r

就像人物卡一样 |cff00ff00同伴卡|r 可以绑定到任意 |cffffff00随从|r和 |cffffff00宠物|r 并可以像玩家一样轻松的从一个卡切换到另一个卡.

|cffff9900Ghouls:|r 由于食尸鬼每次都有新的名字，每次召唤都需要重新绑定同伴卡]=],
	["PR_CO_PROFILE_HELP2"] = [=[单击这里创建新的同伴卡。

|cff00ff00要绑定同伴卡到一个随从 (猎人宠物、水元素 ...)、召唤物，只需选中他们并且绑定到现有的同伴卡 (或者创建一个新的).|r]=],
	["PR_CO_PROFILEMANAGER_DELETE_WARNING"] = [=[您确定要删除同伴卡%s吗?
此操作无法撤消，与此概要链接的所有TRP3信息将被销毁!]=],
	["PR_CO_PROFILEMANAGER_DUPP_POPUP"] = [=[请输入新同伴卡的名称。
名称不能为空。

这种复制不会改变您绑定到%s的宠物/坐骑。]=],
	["PR_CO_PROFILEMANAGER_EDIT_POPUP"] = [=[请为这个同伴卡%s输入一个新名称。
名称不能为空。

更改名称不会改变您绑定到%s的宠物/坐骑。]=],
	["PR_CO_PROFILEMANAGER_TITLE"] = "同伴卡",
	["PR_CO_UNUSED_PROFILE"] = "此同伴卡目前没有绑定到任何宠物或坐骑。",
	["PR_CO_WARNING_RENAME"] = [=[|cff0000警告:|r强烈建议您在将您的宠物链接到一个同伴卡之前重命名你的宠物。

现在链接吗？]=],
	["PR_CREATE_PROFILE"] = "创建一个人物卡",
	["PR_DEFAULT_PROFILE_NAME"] = "默认人物卡",
	["PR_DEFAULT_PROFILE_WARNING"] = [=[建立一个新人物卡
	或链接到一个已有的人物卡
	以编辑你的角色信息]=],
	["PR_DELETE_PROFILE"] = "删除人物卡",
	["PR_DUPLICATE_PROFILE"] = "复制人物卡",
	["PR_EXPORT_IMPORT_HELP"] = [=[您可以使用下拉菜单中的选项导出和导入配置文件.

使用  |cffffff00输出资料|r 选择生成包含概要文件序列化数据的一大块文本。您可以使用Ctrl-c(或Mac上的Command-c)复制文本，并将其粘贴到其他地方作为备份。(|cffff0000请注意，一些高级的文本编辑工具，如Microsoft Word，将重新格式化特殊的字符串，例如引号并改变数据。请使用像记事本这样的简单的文本编辑工具|r)

使用 |cffffff00输入资料|r 将之前导出的数据粘贴到现有的文件中. 这个文件中的现有数据将被您所粘贴的数据所替代。您不能直接将数据导入您当前选择的文件。]=],
	["PR_EXPORT_IMPORT_TITLE"] = "导出/导入数据",
	["PR_EXPORT_NAME"] = "资料 %s (大小 %0.2f kB)",
	["PR_EXPORT_PROFILE"] = "导出数据",
	["PR_EXPORT_TOO_LARGE"] = [=[这个配置文件太大，不能导出.

配置文件的大小: %0.2f kB
最大: 20 kB]=],
	["PR_EXPORT_WARNING_MAC"] = [=[请注意，一些例如Text Edit or Discord这样的高级文本编辑工具，将重新格式化的特殊字符，如引号，并改变数据内容。

如果您打算在文档中复制下面的文本，请使用更简单的文本编辑工具，这些工具不会自动更改字符(在文本编辑中，请在粘贴前将格式化为纯文本)]=],
	["PR_EXPORT_WARNING_TITLE"] = "警告：",
	["PR_EXPORT_WARNING_WINDOWS"] = [=[请注意，一些高级的文本编辑工具，如Microsoft Word或将重新格式化特殊字符，如引号，并改变数据的内容。

如果您打算在文档中复制下面的文本，请使用更简单的文本编辑工具，这些工具不会自动修改字符，比如记事本。]=],
	["PR_IMPORT"] = "导入",
	["PR_IMPORT_CHAR_TAB"] = "导入人物",
	["PR_IMPORT_EMPTY"] = "没有可导入的资料",
	["PR_IMPORT_IMPORT_ALL"] = "导入所有",
	["PR_IMPORT_PETS_TAB"] = "导入同伴",
	["PR_IMPORT_PROFILE"] = "导入数据",
	["PR_IMPORT_PROFILE_TT"] = "在这里粘贴要导入的数据",
	["PR_IMPORT_WILL_BE_IMPORTED"] = "将导入",
	["PR_PROFILE"] = "个人档案",
	["PR_PROFILE_CREATED"] = "档案 %s 已建立.",
	["PR_PROFILE_DELETED"] = "档案 %s 已删除.",
	["PR_PROFILE_DETAIL"] = "这张人物卡已绑定到以下角色：",
	["PR_PROFILE_HELP"] = [=[人物卡包含一个 |cffffff00\"角色\"|r 作为 |cff00ff00角色扮演玩家|r的所有人物信息。

一个 |cffffff00\"魔兽世界角色\"|r 一次只能绑定一个人物卡，但也可以在需要的时候在切换多个人物卡之间切换。

你也可以将多个 |cffffff00\"魔兽世界角色\"|r 绑定到同一张 |cff00ff00人物卡|r]=],
	["PR_PROFILE_LOADED"] = "人物卡 %s 已载入",
	["PR_PROFILE_MANAGEMENT_TITLE"] = "人物卡管理",
	["PR_PROFILEMANAGER_ACTIONS"] = "动作",
	["PR_PROFILEMANAGER_ALREADY_IN_USE"] = "这个人物卡名字 %s 无效.",
	["PR_PROFILEMANAGER_COUNT"] = "%s 个魔兽世界角色绑定到了这张人物卡。",
	["PR_PROFILEMANAGER_CREATE_POPUP"] = [=[为新人物卡建个名字.
名字不能为空.]=],
	["PR_PROFILEMANAGER_CURRENT"] = "配置资料",
	["PR_PROFILEMANAGER_DELETE_WARNING"] = [=[您确定要删除人物卡 %s?
此操作无法撤销，所有与此人物卡相关的TRP3信息(角色信息、玩家目录、任务日志、应用状态)将被销毁。!]=],
	["PR_PROFILEMANAGER_DUPP_POPUP"] = [=[请输入新人物卡的名称。
名称不能为空。

此复制不会改变角色对%s的绑定。]=],
	["PR_PROFILEMANAGER_EDIT_POPUP"] = [=[请为这个人物卡%s输入一个新名称。
名称不能为空。

更改名称不会更改此人物卡与您的角色之间的任何绑定关系。]=],
	["PR_PROFILEMANAGER_EMPTY"] = "没有找到人物卡",
	["PR_PROFILEMANAGER_IMPORT_WARNING"] = "用导入的数据替换人物卡 %s的所有内容?",
	["PR_PROFILEMANAGER_IMPORT_WARNING_2"] = [=[警告:本人物卡是从TRP3的旧版本中制作的。
这可能会导致不兼容。

用导入的数据替换人物卡%s的所有内容?]=],
	["PR_PROFILEMANAGER_RENAME"] = "重命名人物卡",
	["PR_PROFILEMANAGER_SEARCH_PROFILE"] = "搜索人物卡",
	["PR_PROFILEMANAGER_SWITCH"] = "选择人物卡",
	["PR_PROFILEMANAGER_TITLE"] = "所有人物卡",
	["PR_PROFILES"] = "人物卡",
	["PR_SLASH_EXAMPLE"] = "|cffffff00使用命令:|r |cffcccccc/trp3 profile Millidan Foamrage|r |cffffff00来切换到 Millidan Foamrage的人物卡.|r",
	["PR_SLASH_NOT_FOUND"] = "|cffff0000找不到名为|r |cffffff00%s|r|cffff0000.|r的人物卡。",
	["PR_SLASH_OPEN_ABORTING"] = "|cffffff00中止人物卡导入。|r",
	["PR_SLASH_OPEN_EXAMPLE"] = "|cffffff00使用命令:|r |cffcccccc/trp3 open|r |cffffff00打开你目标的人物卡，或者 |cffcccccc/trp3 open 角色名-服务器名|r |cffffff00打开某角色的人物卡。|r",
	["PR_SLASH_OPEN_HELP"] = "使用游戏内的名称打开一个人物的人物卡，如果没有提供名字，则打开目标的人物卡。",
	["PR_SLASH_OPEN_WAITING"] = "|cffffff00请求人物卡,请等待…|r",
	["PR_SLASH_SWITCH_HELP"] = "使用它的名称切换到另一个人物卡。",
	["PR_UNUSED_PROFILE"] = "这个人物卡目前没有绑定到任何WoW角色。",
	["REG_CODE_INSERTION_WARNING"] = [=[|TInterface\AddOns\totalRP3\resources\policegar.tga:50:50|t
请等一下。


我们发现您已经在trp3人物卡中手动插入了无效代码。
这种行为根本不被支持，我们强烈反对任何人这样做。
它可能导致附加组件内的不稳定和错误，数据损坏/配置文件丢失，还会导致与其他附加组件(如MRP)的不兼容性问题。

您在人物卡中插入的代码已被删除，以防止您破坏插件。]=],
	["REG_COMPANION"] = "同伴",
	["REG_COMPANION_BIND_TO_PET"] = "宠物",
	["REG_COMPANION_BOUND_TO"] = "绑定到 ...",
	["REG_COMPANION_BOUND_TO_TARGET"] = "目标",
	["REG_COMPANION_BOUNDS"] = "绑定",
	["REG_COMPANION_BROWSER_BATTLE"] = "浏览战斗宠物",
	["REG_COMPANION_BROWSER_MOUNT"] = "坐骑浏览",
	["REG_COMPANION_INFO"] = "信息",
	["REG_COMPANION_LINKED"] = "同伴 %s 现在已和同伴卡 %s绑定",
	["REG_COMPANION_LINKED_NO"] = "同伴 %s 现在不再与任何同伴卡相关联.",
	["REG_COMPANION_NAME"] = "名字",
	["REG_COMPANION_NAME_COLOR"] = "名字颜色",
	["REG_COMPANION_PAGE_TUTO_C_1"] = "查阅",
	["REG_COMPANION_PAGE_TUTO_E_1"] = "这是 |cff00ff00你同伴的主要信息|r.\\n\\n所有这些信息将会出现在 |cffff9900同伴工具栏上|r.",
	["REG_COMPANION_PAGE_TUTO_E_2"] = [=[这是 |cff00ff00你同伴的描述|r.

这不限于 |cffff9900外貌描述|r.可以随意描述它的 |cffff9900背景|r 或者相关 |cffff9900信息|r.

有很多自定义描述的方法。
你可以讲述一个关于它的 |cffffff00故事|r . 你也可以介绍它的信息，如 |cffffff00大小, 颜色和性格|r.
你可以在描述中加入 |cffffff00图片，图标或者外部网页链接|r.]=],
	["REG_COMPANION_PROFILES"] = "同伴卡",
	["REG_COMPANION_TARGET_NO"] = "你的目标不是一个有效的宠物，小宠物，食尸鬼，法师元素或者一个重命名的战斗宠物.",
	["REG_COMPANION_TF_BOUND_TO"] = "选择一个同伴卡",
	["REG_COMPANION_TF_CREATE"] = "创建一个同伴卡",
	["REG_COMPANION_TF_NO"] = "没有同伴卡",
	["REG_COMPANION_TF_OPEN"] = "打开页面",
	["REG_COMPANION_TF_OWNER"] = "所有者: %s",
	["REG_COMPANION_TF_PROFILE"] = "同伴资料",
	["REG_COMPANION_TF_PROFILE_MOUNT"] = "坐骑资料",
	["REG_COMPANION_TF_UNBOUND"] = "从同伴卡分离",
	["REG_COMPANION_TITLE"] = "头衔",
	["REG_COMPANION_UNBOUND"] = "从……解除绑定",
	["REG_COMPANIONS"] = "同伴",
	["REG_DELETE_WARNING"] = [=[你确定你要删除这个 %s'的同伴卡?
]=],
	["REG_IGNORE_TOAST"] = "忽略的角色",
	["REG_LIST_ACTIONS_MASS"] = "对 %s 选定配置文件的操作",
	["REG_LIST_ACTIONS_MASS_IGNORE"] = "忽略同伴卡",
	["REG_LIST_ACTIONS_MASS_IGNORE_C"] = [=[该操作将把 |cff00ff00%s 角色（们）|r 添加到忽略列表中。

您可以选择输入下面的原因。这是一个个人标记，它将作为一个提醒。]=],
	["REG_LIST_ACTIONS_MASS_REMOVE"] = "删除同伴卡",
	["REG_LIST_ACTIONS_MASS_REMOVE_C"] = "该操作将删除 |cff00ff00%s 选定的同伴卡|r.",
	["REG_LIST_ACTIONS_PURGE"] = "清除档案",
	["REG_LIST_ACTIONS_PURGE_ALL"] = "删除所有同伴卡",
	["REG_LIST_ACTIONS_PURGE_ALL_C"] = [=[这将从目录中删除所有同伴卡和角色链接.

|cff00ff00%s .]=],
	["REG_LIST_ACTIONS_PURGE_ALL_COMP_C"] = [=[这将删除目录中所有同伴.

|cff00ff00%s 同伴.]=],
	["REG_LIST_ACTIONS_PURGE_COUNT"] = "%s 同伴卡将被删除.",
	["REG_LIST_ACTIONS_PURGE_EMPTY"] = "没有同伴卡被清除.",
	["REG_LIST_ACTIONS_PURGE_IGNORE"] = "已忽略的角色的同伴卡",
	["REG_LIST_ACTIONS_PURGE_IGNORE_C"] = [=[这将清除所有链接魔兽世界的同伴卡。

|cff00ff00%s]=],
	["REG_LIST_ACTIONS_PURGE_TIME"] = "超过一个月没见到的同伴卡",
	["REG_LIST_ACTIONS_PURGE_TIME_C"] = [=[这将移除所有一个月未见的同伴卡。

|cff00ff00%s]=],
	["REG_LIST_ACTIONS_PURGE_UNLINKED"] = "没有和角色绑定的同伴卡",
	["REG_LIST_ACTIONS_PURGE_UNLINKED_C"] = [=[这个清除将删除所有没有绑定到魔兽世界角色的同伴卡。

|cff00ff00%s]=],
	["REG_LIST_ADDON"] = "档案种类",
	["REG_LIST_CHAR_EMPTY"] = "没有角色",
	["REG_LIST_CHAR_EMPTY2"] = "没有匹配的角色",
	["REG_LIST_CHAR_FILTER"] = "角色: %s / %s",
	["REG_LIST_CHAR_IGNORED"] = "已忽略",
	["REG_LIST_CHAR_NAME_COPY"] = "复制角色名字",
	["REG_LIST_CHAR_SEL"] = "选择一个角色",
	["REG_LIST_CHAR_TITLE"] = "角色列表",
	["REG_LIST_CHAR_TT"] = "点击显示页面",
	["REG_LIST_CHAR_TT_CHAR"] = "绑定wow里的角色(s):",
	["REG_LIST_CHAR_TT_CHAR_NO"] = "没有绑定任何角色",
	["REG_LIST_CHAR_TT_DATE"] = [=[上一次看到的日期: |cff00ff00%s|r
上一次看到的位置: |cff00ff00%s|r]=],
	["REG_LIST_CHAR_TT_GLANCE"] = "第一印象",
	["REG_LIST_CHAR_TT_IGNORE"] = "忽略的角色(s)",
	["REG_LIST_CHAR_TT_NEW_ABOUT"] = "未读的描述",
	["REG_LIST_CHAR_TT_RELATION"] = [=[关系:
|cff00ff00%s]=],
	["REG_LIST_CHAR_TUTO_ACTIONS"] = "本专栏允许您选择多个角色，并对所有这些角色执行操作.",
	["REG_LIST_CHAR_TUTO_FILTER"] = [=[你可以在这搜索.

这将对 |cff00ff00姓名搜索|r 包括已知游戏角色的全称 (姓 + 名)。

这将对 |cff00ff00公会搜索|r 包括已知游戏角色的公会名。

这将对 |cff00ff00范围搜索|r 这将只搜索绑定到属于你当前服务器的角色的数据]=],
	["REG_LIST_CHAR_TUTO_LIST"] = [=[第列显示角色的名称.

第二列显示了其他玩家角色与当前你的角色之间的关系.

最后一列是各种标记. (忽略的 ..等等.)]=],
	["REG_LIST_FILTERS"] = "过滤",
	["REG_LIST_FILTERS_TT"] = [=[|cffffff00左击:|r 应用过滤器
|cffffff00右击:|r 清除过滤器]=],
	["REG_LIST_FLAGS"] = "标记",
	["REG_LIST_GUILD"] = "角色公会",
	["REG_LIST_IGNORE_EMPTY"] = "没有忽略的角色",
	["REG_LIST_IGNORE_TITLE"] = "忽略列表",
	["REG_LIST_IGNORE_TT"] = [=[理由:
|cff00ff00%s

|cffffff00单击从忽略列表中删除]=],
	["REG_LIST_NAME"] = "角色名",
	["REG_LIST_NOTESONLY"] = "只有笔记",
	["REG_LIST_NOTIF_ADD"] = "发现了|cff00ff00%s的新人物卡",
	["REG_LIST_NOTIF_ADD_CONFIG"] = "新人物卡被发现",
	["REG_LIST_NOTIF_ADD_NOT"] = "这个人物卡已经不存在了.",
	["REG_LIST_PET_MASTER"] = "主人名字",
	["REG_LIST_PET_NAME"] = "同伴的名字",
	["REG_LIST_PET_TYPE"] = "同伴的种类",
	["REG_LIST_PETS_EMPTY"] = "没有同伴",
	["REG_LIST_PETS_EMPTY2"] = "没有匹配的同伴",
	["REG_LIST_PETS_FILTER"] = "同伴: %s / %s",
	["REG_LIST_PETS_TITLE"] = "同伴列表",
	["REG_LIST_PETS_TOOLTIP"] = "已经被发现在……",
	["REG_LIST_PETS_TOOLTIP2"] = "已经被发现和……在一起",
	["REG_LIST_REALMONLY"] = "仅限本服务器",
	["REG_LOCATION_DIFFERENT_WAR_MODE"] = "不同的战争模式",
	["REG_MSP_ALERT"] = [=[|cffff0000警告

在玛丽苏协议（MSP）下，你不能同时拥有多于一个插件，因为他们会互相冲突。|r

当前已载入：|cff00ff00%s

|cffff9900因此，TRP3的MSP支持将被禁用。|r

如果你不想让TRP3作为你的MSP插件并不想再次看到这类警告，你可以禁用TRP3设置当中的玛丽苏协议。]=],
	["REG_NOTES_PROFILE"] = "笔记",
	["REG_NOTES_PROFILE_TT"] = "打开对目标角色的笔记窗口。",
	["REG_PLAYER"] = "角色",
	["REG_PLAYER_ABOUT"] = "关于",
	["REG_PLAYER_ABOUT_ADD_FRAME"] = "添加一个框架",
	["REG_PLAYER_ABOUT_EMPTY"] = "没有说明",
	["REG_PLAYER_ABOUT_HEADER"] = "页面标签",
	["REG_PLAYER_ABOUT_MUSIC"] = "角色主题音乐",
	["REG_PLAYER_ABOUT_MUSIC_LISTEN"] = "播放角色主题音乐",
	["REG_PLAYER_ABOUT_MUSIC_REMOVE"] = "移除角色主题音乐",
	["REG_PLAYER_ABOUT_MUSIC_SELECT"] = "选择角色主题音乐",
	["REG_PLAYER_ABOUT_MUSIC_SELECT2"] = "选择角色主题音乐",
	["REG_PLAYER_ABOUT_MUSIC_STOP"] = "停止角色主题音乐",
	["REG_PLAYER_ABOUT_MUSIC_THEME"] = "角色主题音乐",
	["REG_PLAYER_ABOUT_NOMUSIC"] = "|cffff9900没有角色主题音乐",
	["REG_PLAYER_ABOUT_P"] = "段落标记",
	["REG_PLAYER_ABOUT_REMOVE_FRAME"] = "删除这个框架",
	["REG_PLAYER_ABOUT_SOME"] = "一些文字 ...",
	["REG_PLAYER_ABOUT_T1_YOURTEXT"] = "您在此处输入的文字",
	["REG_PLAYER_ABOUT_TAGS"] = "格式化工具",
	["REG_PLAYER_ABOUT_UNMUSIC"] = "|cffff9900未知主题",
	["REG_PLAYER_ABOUT_VOTE_DOWN"] = "我不喜欢这个内容",
	["REG_PLAYER_ABOUT_VOTE_NO"] = [=[与此人物卡相关的人物并不在线
你想强制Total RP 3 发送你的投票结果吗 ?]=],
	["REG_PLAYER_ABOUT_VOTE_SENDING"] = "正在发送你的投票 %s ...",
	["REG_PLAYER_ABOUT_VOTE_SENDING_OK"] = "你的投票已经被送到了 %s !",
	["REG_PLAYER_ABOUT_VOTE_TT"] = "你的投票完全是匿名的，只有这个玩家才能看到.",
	["REG_PLAYER_ABOUT_VOTE_TT2"] = "只有这个玩家在线时才可以投票.",
	["REG_PLAYER_ABOUT_VOTE_UP"] = "我喜欢这个内容",
	["REG_PLAYER_ABOUT_VOTES"] = "统计资料",
	["REG_PLAYER_ABOUT_VOTES_R"] = [=[|cff00ff00%s 喜欢这个内容
|cffff0000%s 不喜欢这个内容]=],
	["REG_PLAYER_ABOUTS"] = "关于 %s",
	["REG_PLAYER_ADD_NEW"] = "创建新的",
	["REG_PLAYER_AGE"] = "年龄",
	["REG_PLAYER_AGE_TT"] = [=[在这里你可以指出你的角色有多老.

有几种方法可以做到这一点:|c0000ff00
- 要么使用年份,
- 或形容词(年轻、成熟、成熟、可敬等)。]=],
	["REG_PLAYER_ALERT_HEAVY_SMALL"] = [=[|cffff0000T你的个人资料的总规模相当大.
|cffff9900你应该减少它.]=],
	["REG_PLAYER_BIRTHPLACE"] = "出生地",
	["REG_PLAYER_BIRTHPLACE_TT"] = [=[在这里你可以指出你角色的出生地. 这可以是一个地点，一个区域，甚至是一个大陆。 你可以决定你想要多精确。

|c00ffff00你可以使用这个按钮来方便地设置你当前的位置为出生地.]=],
	["REG_PLAYER_BKG"] = "布置背景",
	["REG_PLAYER_BKG_TT"] = "这会改变你角色的图像背景.",
	["REG_PLAYER_CARACT"] = "特征",
	["REG_PLAYER_CHANGE_CONFIRM"] = [=[您可能有未保存的数据更改.
你想改变页面吗?
|cffff9900任何更改都将丢失.]=],
	["REG_PLAYER_CHARACTERISTICS"] = "特征",
	["REG_PLAYER_CLASS"] = "职业",
	["REG_PLAYER_CLASS_TT"] = [=[T这是您的角色的自定义类.

|cff00ff00比如 :|r
骑士, 烟火生产者, 死灵法师, 游侠, 秘术师 ...]=],
	["REG_PLAYER_COLOR_ALWAYS_DEFAULT_TT"] = [=[|cffffff00左键:|r 选择一个颜色
|cffffff00右键:|r 放弃颜色]=],
	["REG_PLAYER_COLOR_CLASS"] = "职业颜色ABOUT_TITLE",
	["REG_PLAYER_COLOR_CLASS_TT"] = [=[这也决定了名字的颜色.

]=],
	["REG_PLAYER_COLOR_TT"] = [=[|cffffff00Click:|r 选择一种颜色
|cffffff00Right-click:|r 放弃颜色]=],
	["REG_PLAYER_CURRENT"] = "目前",
	["REG_COMPANIONS_SHORTDESCRIPTION"]= "简要说明",
	["REG_PLAYER_CURRENT_OOC"] = "这是一个 OOC 信息",
	["REG_PLAYER_CURRENTOOC"] = "目前 (OOC)",
	["REG_PLAYER_EDIT_MUSIC_THEME"] = "主题音乐",
	["REG_PLAYER_EYE"] = "眼睛颜色",
	["REG_PLAYER_EYE_TT"] = [=[在这里，你可以看到你的眼睛的颜色。

记住，即使你的角色的脸总是被隐藏起来，这可能还是值得一提的，以防万一。]=],
	["REG_PLAYER_FIRSTNAME"] = "名",
	["REG_PLAYER_FIRSTNAME_TT"] = [=[这是你角色的名字。这是一个必填项，如果你不输入名字，会使用默认的角色名字(|cffffff00%s|r)。

你也可以使用一个|c0000ff0绰号|r!]=],
	["REG_PLAYER_FULLTITLE"] = "全称",
	["REG_PLAYER_FULLTITLE_TT"] = "你可以在这里写下你的角色全称。它可以是一个更长的头衔，也可以完全是另一个头衔。为了避免重复，请尽量不要输入相同的信息。",
	["REG_PLAYER_GLANCE"] = "第一印象",
	["REG_PLAYER_GLANCE_BAR_DELETED"] = "组预设 |cffff9900%s|r 被删除.",
	["REG_PLAYER_GLANCE_BAR_EMPTY"] = "预设名不能是空的.",
	["REG_PLAYER_GLANCE_BAR_LOAD"] = "组预设",
	["REG_PLAYER_GLANCE_BAR_LOAD_SAVE"] = "组预设",
	["REG_PLAYER_GLANCE_BAR_NAME"] = [=[请输入预设名.

|cff00ff00注意:如果该名称已经被另一个组预先设置，那么另一个组将被替换.]=],
	["REG_PLAYER_GLANCE_BAR_SAVE"] = "保存组预设",
	["REG_PLAYER_GLANCE_BAR_SAVED"] = "组预设 |cff00ff00%s|r 被创建.",
	["REG_PLAYER_GLANCE_BAR_TARGET"] = "\"第一印象\" 预设",
	["REG_PLAYER_GLANCE_CONFIG"] = [=[|cff00ff00\"第一印象\"|r 是一组可以用来定义关于这个角色的重要信息的栏位。

可以在槽中使用这些操作:
|cffffff00单击:|r 配置栏位
|cffffff00双击:|r 隐藏栏位
|cffffff00右击:|r 添加栏位
|cffffff00拖动:|r 移动栏位]=],
	["REG_PLAYER_GLANCE_EDITOR"] = "编辑印象: 栏位 %s",
	["REG_PLAYER_GLANCE_MENU_COPY"] = "复制栏位",
	["REG_PLAYER_GLANCE_MENU_PASTE"] = "粘贴栏位:%s",
	["REG_PLAYER_GLANCE_PRESET"] = "读取一个预设",
	["REG_PLAYER_GLANCE_PRESET_ADD"] = "创建预设 |cff00ff00%s|r.",
	["REG_PLAYER_GLANCE_PRESET_ALERT1"] = "你必须进入一个预设的类别.",
	["REG_PLAYER_GLANCE_PRESET_CATEGORY"] = "预置种类",
	["REG_PLAYER_GLANCE_PRESET_CREATE"] = "创建预设",
	["REG_PLAYER_GLANCE_PRESET_GET_CAT"] = [=[%s

请输入这个预设的类别名称.]=],
	["REG_PLAYER_GLANCE_PRESET_NAME"] = "预设名称",
	["REG_PLAYER_GLANCE_PRESET_REMOVE"] = "删除预设 |cff00ff00%s|r.",
	["REG_PLAYER_GLANCE_PRESET_SAVE"] = "将信息保存为预设值.",
	["REG_PLAYER_GLANCE_PRESET_SAVE_SMALL"] = "保存为预设的",
	["REG_PLAYER_GLANCE_PRESET_SELECT"] = "选择一个预设.",
	["REG_PLAYER_GLANCE_TITLE"] = "特征名称",
	["REG_PLAYER_GLANCE_UNUSED"] = "未使用的栏位",
	["REG_PLAYER_GLANCE_USE"] = "激活这个栏位",
	["REG_PLAYER_HEIGHT"] = "身高",
	["REG_PLAYER_HEIGHT_TT"] = [=[这是你的角色的身高.
有几种方法可以做到:|c0000ff00
- 一个精确的数字: 170 cm, 6呎5吋"…
-  或者简单的高或矮…]=],
	["REG_PLAYER_HERE"] = "设置位置",
	["REG_PLAYER_HERE_HOME_PRE_TT"] = [=[现在的住所地图坐标:
|cff00ff00%s|r.]=],
	["REG_PLAYER_HERE_HOME_TT"] = [=[|cffffff00点击|r: 用你当前的坐标作为你的住所的位置。
|cffffff00Right-click|r: 删除你的住所的位置。]=],
	["REG_PLAYER_HERE_TT"] = "|cffffff00点击|r: 设定到你目前的位置",
	["REG_PLAYER_HISTORY"] = "历史",
	["REG_PLAYER_ICON"] = "角色图标",
	["REG_PLAYER_ICON_TT"] = "为你的角色选一个图标.",
	["REG_PLAYER_IGNORE"] = "忽略相关特征 (%s)",
	["REG_PLAYER_IGNORE_WARNING"] = [=[你想忽略这些角色吗?
| cffff9900%s
可以选择输入以下原因。这是一个个人笔记，可以作为提醒。]=],
	["REG_PLAYER_LASTNAME"] = "姓",
	["REG_PLAYER_LASTNAME_TT"] = "这是你的角色的姓.",
	["REG_PLAYER_LEFTTRAIT"] = "左倾",
	["REG_PLAYER_MISC_ADD"] = "添加一个额外的字段",
	["REG_PLAYER_MISC_PRESET_PRONOUNS"] = "人称代词",
	["REG_PLAYER_MORE_INFO"] = "附加说明",
	["REG_PLAYER_MSP_HOUSE"] = "住所的名字",
	["REG_PLAYER_MSP_MOTTO"] = "座右铭",
	["REG_PLAYER_MSP_NICK"] = "昵称",
	["REG_PLAYER_NAMESTITLES"] = "名字与称呼",
	["REG_PLAYER_NO_CHAR"] = "没有特征",
	["REG_PLAYER_NOTES"] = "笔记",
	["REG_PLAYER_NOTES_ACCOUNT"] = "通用笔记",
	["REG_PLAYER_NOTES_ACCOUNT_HELP"] = "这些笔记和你的子账号绑定，会在你使用的所有人物卡之间共享。",
	["REG_PLAYER_NOTES_PROFILE"] = "%s的笔记",
	["REG_PLAYER_NOTES_PROFILE_HELP"] = "这些笔记和你当前使用的人物卡绑定，并会随着你切换人物卡而改变。",
	["REG_PLAYER_NOTES_PROFILE_NONAME"] = "人物笔记",
	["REG_PLAYER_PEEK"] = "杂项",
	["REG_PLAYER_PHYSICAL"] = "物理描述",
	["REG_PLAYER_PSYCHO"] = "个性",
	["REG_PLAYER_PSYCHO_Acete"] = "禁欲主义",
	["REG_PLAYER_PSYCHO_ADD"] = "添加一种性格",
	["REG_PLAYER_PSYCHO_ATTIBUTENAME_TT"] = "属性名称",
	["REG_PLAYER_PSYCHO_Bonvivant"] = "享乐主义",
	["REG_PLAYER_PSYCHO_CHAOTIC"] = "混乱",
	["REG_PLAYER_PSYCHO_Chaste"] = "高尚",
	["REG_PLAYER_PSYCHO_Conciliant"] = "正派",
	["REG_PLAYER_PSYCHO_Couard"] = "懦弱",
	["REG_PLAYER_PSYCHO_CREATENEW"] = "自建特征",
	["REG_PLAYER_PSYCHO_Cruel"] = "野蛮",
	["REG_PLAYER_PSYCHO_CUSTOM"] = "定制性格",
	["REG_PLAYER_PSYCHO_CUSTOMCOLOR"] = "选择属性颜色",
	["REG_PLAYER_PSYCHO_CUSTOMCOLOR_LEFT_TT"] = [=[选择使用一个颜色来表示左倾属性。

|cffffff00左健:| r选择一个颜色
|cffffff00右键:| r放弃颜色
|cffffff00Shift-左键:|r使用默认的颜色]=],
	["REG_PLAYER_PSYCHO_CUSTOMCOLOR_RIGHT_TT"] = [=[选择使用一个颜色来表示右倾属性。

|cffffff00左健:| r选择一个颜色
|cffffff00右键:| r放弃颜色
|cffffff00Shift-左键:|r使用默认的颜色]=],
	["REG_PLAYER_PSYCHO_Egoiste"] = "自私",
	["REG_PLAYER_PSYCHO_Genereux"] = "无私",
	["REG_PLAYER_PSYCHO_Impulsif"] = "莽撞",
	["REG_PLAYER_PSYCHO_Indulgent"] = "宽容",
	["REG_PLAYER_PSYCHO_LEFTICON_TT"] = "设置左倾图标.",
	["REG_PLAYER_PSYCHO_Loyal"] = "正义",
	["REG_PLAYER_PSYCHO_Luxurieux"] = "下流",
	["REG_PLAYER_PSYCHO_Misericordieux"] = "文雅",
	["REG_PLAYER_PSYCHO_MORE"] = "增加 \"%s\"",
	["REG_PLAYER_PSYCHO_PERSONAL"] = "人格特质",
	["REG_PLAYER_PSYCHO_Pieux"] = "感性",
	["REG_PLAYER_PSYCHO_POINT"] = "增加",
	["REG_PLAYER_PSYCHO_Pragmatique"] = "叛逆",
	["REG_PLAYER_PSYCHO_Rationnel"] = "理性",
	["REG_PLAYER_PSYCHO_Reflechi"] = "谨慎",
	["REG_PLAYER_PSYCHO_Rencunier"] = "记仇",
	["REG_PLAYER_PSYCHO_RIGHTICON_TT"] = "设置右倾图标.",
	["REG_PLAYER_PSYCHO_Sincere"] = "诚实",
	["REG_PLAYER_PSYCHO_SOCIAL"] = "社会特征",
	["REG_PLAYER_PSYCHO_Trompeur"] = "欺诈",
	["REG_PLAYER_PSYCHO_Valeureux"] = "勇敢",
	["REG_PLAYER_RACE"] = "种族",
	["REG_PLAYER_RACE_TT"] = "这是你的角色的种族。它不需要被限制在玩家可选的种族中。魔兽争霸和魔兽世界有很多种族可以使用。",
	["REG_PLAYER_REGISTER"] = "目录信息",
	["REG_PLAYER_RELATIONSHIP_STATUS"] = "感情关系",
	["REG_PLAYER_RELATIONSHIP_STATUS_DIVORCED"] = "离婚",
	["REG_PLAYER_RELATIONSHIP_STATUS_MARRIED"] = "已婚",
	["REG_PLAYER_RELATIONSHIP_STATUS_SINGLE"] = "单身",
	["REG_PLAYER_RELATIONSHIP_STATUS_TAKEN"] = "恋爱中",
	["REG_PLAYER_RELATIONSHIP_STATUS_TT"] = "显示你角色的感情关系。选择\"不显示\" 可以将其隐藏。",
	["REG_PLAYER_RELATIONSHIP_STATUS_UNKNOWN"] = "不显示",
	["REG_PLAYER_RELATIONSHIP_STATUS_WIDOWED"] = "丧偶",
	["REG_PLAYER_RESIDENCE"] = "住所",
	["REG_PLAYER_RESIDENCE_SHOW"] = "住所位置",
	["REG_PLAYER_RESIDENCE_SHOW_TT"] = [=[|cff00ff00%s

|r点击在地图上显示]=],
	["REG_PLAYER_RESIDENCE_TT"] = [=[在这里你可以指出你的角色通常生活在哪里. 这可能是他们的个人地址(他们的家)或者是可以遇见他们的地方。
注意，如果你的角色是一个流浪者，甚至是无家可归者，你需要相应地改变信息。

|c00ffff00你可以使用这个按钮来方便地设置你当前的位置。]=],
	["REG_PLAYER_RIGHTTRAIT"] = "右倾",
	["REG_PLAYER_SHOWMISC"] = "显示杂项框架",
	["REG_PLAYER_SHOWMISC_TT"] = [=[检查您是否希望为您的角色显示自定义信息。

如果您不想显示自定义信息，请不要勾选该项，如此这些信息将保持完全隐藏。]=],
	["REG_PLAYER_SHOWPSYCHO"] = "显示人物性格",
	["REG_PLAYER_SHOWPSYCHO_TT"] = [=[检查你是否想要使用人物性格描述.

如果你不想用这种方式来表示你的角色的性格, 请不要勾选该项，这些信息将保持隐藏.]=],
	["REG_PLAYER_STYLE_ASSIST"] = "RP扮演帮助",
	["REG_PLAYER_STYLE_BATTLE"] = "RP战斗",
	["REG_PLAYER_STYLE_BATTLE_1"] = "魔兽世界PVP",
	["REG_PLAYER_STYLE_BATTLE_2"] = "TRPRoll点战斗",
	["REG_PLAYER_STYLE_BATTLE_3"] = "roll点战斗",
	["REG_PLAYER_STYLE_BATTLE_4"] = "表情动作战斗",
	["REG_PLAYER_STYLE_DEATH"] = "接受角色死亡",
	["REG_PLAYER_STYLE_EMPTY"] = "没有扮演游戏属性共享",
	["REG_PLAYER_STYLE_FREQ"] = "RP频率",
	["REG_PLAYER_STYLE_FREQ_1"] = "全部时间, 不会OOC",
	["REG_PLAYER_STYLE_FREQ_2"] = "大多数时间",
	["REG_PLAYER_STYLE_FREQ_3"] = "一部分时间",
	["REG_PLAYER_STYLE_FREQ_4"] = "我是临时工",
	["REG_PLAYER_STYLE_FREQ_5"] = "大部分时间都在OOC,我不是RP玩家",
	["REG_PLAYER_STYLE_GUILD"] = " 公会成员",
	["REG_PLAYER_STYLE_GUILD_IC"] = "RP 成员",
	["REG_PLAYER_STYLE_GUILD_OOC"] = "OOC 成员",
	["REG_PLAYER_STYLE_HIDE"] = "不显示",
	["REG_PLAYER_STYLE_INJURY"] = "接受角色受伤",
	["REG_PLAYER_STYLE_PERMI"] = "角色许可",
	["REG_PLAYER_STYLE_ROMANCE"] = "接受角色浪漫史",
	["REG_PLAYER_STYLE_RPSTYLE"] = "角色扮演风格",
	["REG_PLAYER_STYLE_RPSTYLE_SHORT"] = "RP 风格",
	["REG_PLAYER_STYLE_WOWXP"] = "魔兽世界经验",
	["REG_PLAYER_TITLE"] = "头衔",
	["REG_PLAYER_TITLE_TT"] = [=[你的角色的头衔是你的角色通常的称呼。请避免长头衔，你可以在下方输入完整的头衔。

例如 |c0000ff00合适的头衔 |r:
|c0000ff00- 女伯爵,
- 侯爵,
- 占星师,
- 贵族,
- 游学者.
|r例如 |cffff0000in不当的头衔|r:
|cffff0000- 米奈希尔的女伯爵,
- 暴风城法师塔的占星师,
- 德莱尼的外交官,
- etc.]=],
	["REG_PLAYER_TRP2_PIERCING"] = "刺环",
	["REG_PLAYER_TRP2_TATTOO"] = "刺青",
	["REG_PLAYER_TRP2_TRAITS"] = "面相",
	["REG_PLAYER_TUTO_ABOUT_COMMON"] = [=[|cff00ff00角色主题音乐:|r
你可以为你的角色选择一个 |cffffff00主题音乐|r . 可以把它作为其他人|cffffff00阅读你角色信息时的背景音乐|r。

|cff00ff00Background:|r
这是一个人物卡的 |cffffff00背景贴图|r .

|cff00ff00模板:|r
模板决定了你的人物信息的|cffffff00总体格式和叙述方法|r。
|cffff9900只有选定的模板可以被其他玩家看到，因此不必完全填写。|r
选择模板之后，你可以再次打开模板教学并获取关于各种模板的帮助。]=],
	["REG_PLAYER_TUTO_ABOUT_MISC_1"] = [=[这个部分提供了 |cffffff00 5个栏位|r 来描述 |cff00ff00关于您的角色的最重要的信息|r。

这些槽会在其他人点击你的头像时显示在 |cffffff00"第一印象"|r 当中。

|cff00ff00提示:您可以拖动栏位来重新排序.|r
这也会显示在 |cffffff00"第一印象"|r!]=],
	["REG_PLAYER_TUTO_ABOUT_MISC_3"] = "这部分包含用来回答 |cffffff00许多人们可能问你的常见问题，关于你、你的角色、以及你希望和他/她的互动方式|r 的|cffffff00一些信息|r 。",
	["REG_PLAYER_TUTO_ABOUT_T1"] = [=[这个模板允许您 |cff00ff00自由地组织您的描述|r。

描述不必局限于您的角色 |cffff9900外貌|r. 可以自由描述他的 |cffff9900背景|r 或有关他的 |cffff9900人品/性格|r。

使用这个模板，您可以使用格式化工具修改几个布局参数，如 |cffffff00文字大小、颜色和对齐|r.
这些工具还允许你插入 |cffffff00图像,图标或链接到外部网站|r。]=],
	["REG_PLAYER_TUTO_ABOUT_T2"] = [=[该模板结构更结构化,包含|cff00ff00一系列独立的框架|r。

每一栏位都有一个 |cffffff00图标,背景和文档|r. 注意，您可以在这些栏位中使用格式化工具，比如彩色文字和图标文本标记。

描述不必局限于您的角色 |cffff9900外貌|r. 可以自由的描写他的 |cffff9900人物背景|r 或者 |cffff9900人物个性|r.]=],
	["REG_PLAYER_TUTO_ABOUT_T3"] = [=[这个模板被分为三个部分: |cff00ff00外貌, 性格和经历|r.

你不需要把所有的栏位都填满, |cffff9900如果你什么都不填，那栏就不会显示|r.

每一栏位都有一个|cffffff00图标,背景和文档|r. 注意，您可以在这些栏位中使用格式化工具，比如彩色文字和图标文本标记。		]=],
	["REG_PLAYER_WEIGHT"] = "体型",
	["REG_PLAYER_WEIGHT_TT"] = [=[这里描述你的体型.
比如他们可以 |c0000ff00苗条、肥胖和壮硕，也可以只是正常|r]=],
	["REG_PLAYERS"] = "玩家",
	["REG_REGISTER"] = "玩家目录",
	["REG_REGISTER_CHAR_LIST"] = "角色列表",
	["REG_RELATION"] = "人物关系",
	["REG_RELATION_BUSINESS"] = "商业上的",
	["REG_RELATION_BUSINESS_TT"] = "%s 和 %s 有着商业合作关系。",
	["REG_RELATION_BUTTON_TT"] = [=[关系: %s
|cff00ff00%s

|cffffff00单击以显示可能的操作]=],
	["REG_RELATION_FAMILY"] = "家人",
	["REG_RELATION_FAMILY_TT"] = "%s 和 %s有着血缘关系。",
	["REG_RELATION_FRIEND"] = "朋友",
	["REG_RELATION_FRIEND_TT"] = "%s 认为 %s 是朋友。",
	["REG_RELATION_LOVE"] = "喜爱",
	["REG_RELATION_LOVE_TT"] = "%s 爱上了 %s !",
	["REG_RELATION_NEUTRAL"] = "中立的",
	["REG_RELATION_NEUTRAL_TT"] = "%s 对 %s没有什么特别的感觉。",
	["REG_RELATION_NONE"] = "无",
	["REG_RELATION_NONE_TT"] = "%s 不认识 %s.",
	["REG_RELATION_TARGET"] = "|cffffff00Click: |r改变关系",
	["REG_RELATION_UNFRIENDLY"] = "不友善",
	["REG_RELATION_UNFRIENDLY_TT"] = "%s 明显不喜欢 %s。",
	["REG_REPORT_PLAYER_OPEN_URL"] = [=[你只能在能将其选定为目标的情况下直接举报一个玩家（使用TRP3框架的举报按钮）。

	如果你希望举报 %s 但无法选定他，你必须用下方的链接向暴雪提交表单。]=],
	["REG_REPORT_PLAYER_OPEN_URL_160"] = "如果你想举报%s的人物卡，你需要你通过下面的链接向暴雪提交表单。",
	["REG_REPORT_PLAYER_PROFILE"] = "向 |cff449fe0暴雪|r举报玩家",
	["REG_REPORT_PLAYER_PROFILE_TT"] = [=[你可以举报违反暴雪游戏条款的行为，包括但不限于骚扰，不当言论, 淫秽内容等。
	
	|cffff0000请注意，本功能并非是用来举报不严谨的RP设定，滥用此功能将遭到惩罚！]=],
	["REG_REPORT_PLAYER_TEMPLATE"] = "此玩家通过分享 %s 的RP插件信息违反了暴雪的游戏条款。",
	["REG_REPORT_PLAYER_TEMPLATE_DATE"] = "插件数据是通过 %s 的信息传输的。",
	["REG_REPORT_PLAYER_TEMPLATE_TRIAL_ACCOUNT"] = "这个玩家使用试玩账号。",
	["REG_TIME"] = "最后一次露面的时间",
	["REG_TRIAL_ACCOUNT"] = "试玩帐号",
	["REG_TT_GUILD"] = "%s 属于 |cffff9900%s",
	["REG_TT_GUILD_IC"] = "RP 成员",
	["REG_TT_GUILD_OOC"] = "OOC 成员",
	["REG_TT_IGNORED"] = "< 角色被忽略 >",
	["REG_TT_IGNORED_OWNER"] = "< 所有者被忽略 >",
	["REG_TT_LEVEL"] = [=[等级 %s %s
]=],
	["REG_TT_NOTIF"] = "未读的描述",
	["REG_TT_REALM"] = "服务器: |cffff9900%s",
	["REG_TT_TARGET"] = "目标: |cffff9900%s",
	["REG_TT_ZONE"] = "区域",
	["SCRIPT_ERROR"] = "脚本错误。",
	["SCRIPT_UNKNOWN_EFFECT"] = "脚本错误,未知的效果",
	["SLASH_CMD_STATUS_HELP"] = "使用： |cff00ff00/trp3 status ic || ooc || toggle|r 将你的角色状态改变为以下几种： |cffff9900/trp3 status ic|r将改变你的角色状态为|cff00ff00扮演中|r。 |cffff9900/trp3 status ooc|r将改变你的角色状态为|cffff0000OOC|r。 |cffff9900/trp3 status toggle|r将直接将你的状态改为另一种。",
	["SLASH_CMD_STATUS_USAGE"] = "IC || OOC || 转换",
	["TB_AFK_MODE"] = "离开",
	["TB_DND_MODE"] = "请勿打扰",
	["TB_GO_TO_MODE"] = "切换到 %s 模式",
	["TB_LANGUAGE"] = "语言",
	["TB_LANGUAGES_TT"] = "改变语言",
	["TB_NORMAL_MODE"] = "在线",
	["TB_RPSTATUS_OFF"] = "角色: |cffff0000OOC中",
	["TB_RPSTATUS_ON"] = "角色: |cff00ff00RP中",
	["TB_RPSTATUS_TO_OFF"] = "进入 |cffff0000OOC状态",
	["TB_RPSTATUS_TO_ON"] = "进入 |cffff0000RP状态",
	["TB_STATUS"] = "玩家",
	["TB_SWITCH_CAPE_1"] = "显示披风",
	["TB_SWITCH_CAPE_2"] = "隐藏披风",
	["TB_SWITCH_CAPE_OFF"] = "披风: |cffff0000已隐藏",
	["TB_SWITCH_CAPE_ON"] = "披风: |cff00ff00已显示",
	["TB_SWITCH_HELM_1"] = "显示头盔",
	["TB_SWITCH_HELM_2"] = "隐藏头盔",
	["TB_SWITCH_HELM_OFF"] = "头盔: |cff00ff00已显示",
	["TB_SWITCH_HELM_ON"] = "头盔: |cff00ff00已显示",
	["TB_SWITCH_PROFILE"] = "切换到另一个人物卡",
	["TB_SWITCH_TOOLBAR"] = "切换工具条",
	["TB_TOOLBAR"] = "工具条",
	["TF_IGNORE"] = "忽略玩家",
	["TF_IGNORE_CONFIRM"] = "你确定要忽略这个ID ?\\n\\n|cffffff00%s|r\\n\\n|cffff7700你可以进步一写下忽略原因，这是一个私人的笔记，它不会被别人看到，只是会作为一个提醒。",
	["TF_IGNORE_NO_REASON"] = "没有理由",
	["TF_IGNORE_TT"] = "|cffffff00Click:|r 忽略角色",
	["TF_OPEN_CHARACTER"] = "显示角色页面",
	["TF_OPEN_COMPANION"] = "显示同伴页面",
	["TF_OPEN_MOUNT"] = "显示坐骑页面",
	["TF_PLAY_THEME"] = "播放角色主题音乐",
	["TF_PLAY_THEME_TT"] = [=[|cffffff00点击：|r 播放音乐 |cff00ff00%s
	|cffffff00右击：|r 停止音乐]=],
	["THANK_YOU_ROLE_AUTHOR"] = "作者",
	["THANK_YOU_ROLE_COMMUNITY_MANAGER"] = "社区经理",
	["THANK_YOU_ROLE_CONTRIBUTOR"] = "贡献者",
	["THANK_YOU_ROLE_GUILD_MEMBER"] = "公会成员",
	["THANK_YOU_ROLE_TESTER"] = "QA团队",
	["TT_ELVUI_SKIN"] = "ElvUI（EUI） 皮肤",
	["TT_ELVUI_SKIN_ENABLE_TARGET_FRAME"] = "目标框架皮肤",
	["TT_ELVUI_SKIN_ENABLE_TOOLTIPS"] = "工具提示皮肤",
	["UI_BKG"] = "背景 %s",
	["UI_CLOSE_ALL"] = "关闭所有",
	["UI_COLOR_BROWSER"] = "颜色浏览器",
	["UI_COLOR_BROWSER_PRESETS"] = "预设",
	["UI_COLOR_BROWSER_PRESETS_BASIC"] = "基本",
	["UI_COLOR_BROWSER_PRESETS_CLASSES"] = "职业",
	["UI_COLOR_BROWSER_PRESETS_CUSTOM"] = "自定义",
	["UI_COLOR_BROWSER_PRESETS_ITEMS"] = "物品品质",
	["UI_COLOR_BROWSER_PRESETS_RESOURCES"] = "资源",
	["UI_COLOR_BROWSER_SELECT"] = "选择颜色",
	["UI_COMPANION_BROWSER_HELP"] = "选择一个战斗的宠物",
	["UI_COMPANION_BROWSER_HELP_TT"] = [=[|cffffff00警告: |r只有重命名过的战斗宠物可以绑定到同伴卡。

|cff00ff00此处仅列出符合条件的战斗宠物。]=],
	["UI_FILTER"] = "筛选",
	["UI_ICON_BROWSER"] = "图标浏览器",
	["UI_ICON_BROWSER_HELP"] = "复制图标",
	["UI_ICON_BROWSER_HELP_TT"] = [=[当这个框架打开时，您可以在图标上单击 |cffffff00ctrl + 单击|r 来复制它的名称。

这对以下内容有效:|cff00ff00
- 在你包里的任何东西上
- 在任何法术图标上|r]=],
	["UI_ICON_SELECT"] = "选择图标",
	["UI_IMAGE_BROWSER"] = "图片浏览器",
	["UI_IMAGE_SELECT"] = "选择图片",
	["UI_LINK_SAFE"] = "这是链接URL。",
	["UI_LINK_TEXT"] = "你的文本",
	["UI_LINK_URL"] = [=[http://你.的.链.接
]=],
	["UI_LINK_WARNING"] = [=[这是链接URL。
您可以在web浏览器中复制/粘贴它。

| cffff0000 ! !免责声明! ! | r
Total RP不对导致有害内容的链接负责。]=],
	["UI_MUSIC_ALTTITLE"] = "其他标题",
	["UI_MUSIC_BROWSER"] = "浏览音乐",
	["UI_MUSIC_DURATION"] = "时长",
	["UI_MUSIC_SELECT"] = "选择音乐",
	["UI_PET_BROWSER_ACCEPT"] = "绑定",
	["UI_PET_BROWSER_BOUND_WARNING"] = "|cffff0000警告：|r该宠物已经绑定了宠物卡|cff00ff00%1$s|r。绑定一张新的宠物卡将覆盖当前宠物卡。",
	["UI_PET_BROWSER_EMPTY_TEXT"] = "你没有可以绑定宠物卡的宠物",
	["UI_PET_BROWSER_INTRO_TEXT"] = "用下方按钮选择一个宠物并点击|cffffff00绑定|r来将其绑定到宠物卡",
	["UI_PET_BROWSER_NAME_WARNING"] = "|cffff0000警告：|r该宠物没有命名，我们推荐对其命名以防它与你的其他同名宠物重复。",
	["UI_TUTO_BUTTON"] = "教学模式",
	["UI_TUTO_BUTTON_TT"] = "点击打开/关闭教程模式",
	["UNIT_POPUPS_CHARACTER_STATUS"] = "角色状态",
	["UNIT_POPUPS_CONFIG_DISABLE_IN_COMBAT"] = "战斗中隐藏菜单",
	["UNIT_POPUPS_CONFIG_DISABLE_IN_COMBAT_HELP"] = "勾选后，将在战斗中隐藏额外的菜单选项。",
	["UNIT_POPUPS_CONFIG_DISABLE_IN_INSTANCES"] = "在副本中隐藏菜单。",
	["UNIT_POPUPS_CONFIG_DISABLE_IN_INSTANCES_HELP"] = "勾选后，将在副本中隐藏菜单选项。",
	["UNIT_POPUPS_CONFIG_DISABLE_ON_UNIT_FRAMES"] = "隐藏单位框体上的菜单",
	["UNIT_POPUPS_CONFIG_DISABLE_ON_UNIT_FRAMES_HELP"] = "勾选后，将隐藏右击单位框体时显示的额外菜单选项。",
	["UNIT_POPUPS_CONFIG_DISABLE_OUT_OF_CHARACTER"] = "OOC状态时隐藏菜单。",
	["UNIT_POPUPS_CONFIG_DISABLE_OUT_OF_CHARACTER_HELP"] = "勾选后，将在OOC状态下隐藏额外的菜单选项。",
	["UNIT_POPUPS_CONFIG_ENABLE_MODULE"] = "模块|cff00ff00已启用|r",
	["UNIT_POPUPS_CONFIG_ENTRIES_HEADER"] = "菜单项",
	["UNIT_POPUPS_CONFIG_MENU_TITLE"] = "菜单设置",
	["UNIT_POPUPS_CONFIG_PAGE_HELP"] = "单位框体模块会对团队框体和聊天框内右击玩家的动作产生一个右键菜单。",
	["UNIT_POPUPS_CONFIG_PAGE_TEXT"] = "菜单设置",
	["UNIT_POPUPS_CONFIG_SHOW_CHARACTER_STATUS"] = "显示角色状态按钮",
	["UNIT_POPUPS_CONFIG_SHOW_CHARACTER_STATUS_HELP"] = "如果勾选，将为你自己的角色头像添加一个可以修改IC/OOC状态的右键菜单。",
	["UNIT_POPUPS_CONFIG_SHOW_HEADER_TEXT"] = "菜单项置顶",
	["UNIT_POPUPS_CONFIG_SHOW_HEADER_TEXT_HELP"] = "如果勾选，将“角色扮演选项”菜单项置于任何菜单项之上。",
	["UNIT_POPUPS_CONFIG_SHOW_OPEN_PROFILE"] = "显示打开资料按钮",
	["UNIT_POPUPS_CONFIG_SHOW_OPEN_PROFILE_HELP"] = "如果勾选，添加一个能打开选定单位的RP资料的按钮。|n|n该按钮在团队框体和聊天框可用。",
	["UNIT_POPUPS_CONFIG_SHOW_SEPARATOR"] = "显示分割线",
	["UNIT_POPUPS_CONFIG_SHOW_SEPARATOR_HELP"] = "如果勾选，在其他菜单项之上显示一条分割线。",
	["UNIT_POPUPS_CONFIG_VISIBILITY_HEADER"] = "可视程度设置",
	["UNIT_POPUPS_CURRENT_PROFILE"] = "当前人物卡",
	["UNIT_POPUPS_CURRENT_PROFILE_NAME"] = "当前人物卡：%1$s",
	["UNIT_POPUPS_MODULE_DESCRIPTION"] = "添加团队框架和聊天框中的右键点击菜单。",
	["UNIT_POPUPS_MODULE_DISABLE_WARNING"] = "关闭框体模块需要重载界面。.|n|n|cffff0000警告： |r一旦关闭，该模块只能从|cffffcc00模块状态|r 页面重新启动。|n|n你确定要关闭该模块吗？",
	["UNIT_POPUPS_MODULE_NAME"] = "单位弹窗",
	["UNIT_POPUPS_OPEN_PROFILE"] = "打开人物卡",
	["UNIT_POPUPS_ASSIGN_FLAG"] = "指定简介",
	["UNIT_POPUPS_ROLEPLAY_OPTIONS_HEADER"] = "角色扮演状态"
}

TRP3_API.loc:RegisterNewLocale("zhCN", "简体中文", localeContent);

localeContent = {
	["ABOUT_TITLE"] = "關於",
	["BINDING_NAME_TRP3_TOGGLE"] = "開啟主頁面",
	["BINDING_NAME_TRP3_TOOLBAR_TOGGLE"] = "開啟工具欄",
	["BROADCAST_10"] = "|cffff9900你已經加入了十個頻道，Total RP 3 無法將您連接到廣播頻道，且無法使用地圖上顯示玩家位置的功能。",
	["BROADCAST_OFFLINE_DISABLED"] = "廣播頻道無法使用。",
	["BROADCAST_PASSWORD"] = [=[|cffff0000廣播頻道被設置了密碼 (%s).
|cffff9900Total RP 3不會繼續嘗試連結到廣播頻道，你將無法使用地圖顯示玩家位置的功能。
|cff00ff00你可以在一般設定中關閉或修改廣播頻道。]=],
	["BROADCAST_PASSWORDED"] = [=[|cffff0000玩家 |r%s|cffff0000 剛剛修改了廣播頻道的密碼 (%s).
|cffff9900如果你不知道密碼，你將無法使用顯示地圖上玩家的功能。]=],
	["BW_COLOR_CODE"] = "顏色代碼",
	["BW_COLOR_CODE_ALERT"] = "十六進制碼錯誤",
	["BW_COLOR_CODE_TT"] = "您可以在這裡貼上6位數的十六進制顏色代碼，然後按Enter。",
	["BW_COLOR_PRESET_SAVE"] = "儲存目前顏色",
	["BW_COLOR_PRESET_TITLE"] = "顏色預覽",
	["BW_CUSTOM_NAME"] = "設計名稱的顏色",
	["CL_DOWNLOADING"] = "下載中： %0.1f %%",
	["CL_GLANCE"] = "第一印象",
	["CL_IMPORT_COMPANION"] = "匯入夥伴檔案",
	["CL_IMPORT_GLANCE"] = "匯入第一印象",
	["CL_IMPORT_PROFILE"] = "匯入角色檔案",
	["CL_MAKE_IMPORTABLE"] = "可傳輸的連結",
	["CL_MAKE_IMPORTABLE_BUTTON_TEXT"] = "可傳輸的連結",
	["CL_MAKE_IMPORTABLE_SIMPLER"] = [=[您確定要傳輸 %s 的檔案？
其他玩家將可以複製並使用此連結的內容。]=],
	["CL_MAKE_NON_IMPORTABLE"] = "僅可觀看",
	["CL_OPEN_COMPANION"] = "開啟夥伴檔案",
	["CL_OPEN_PROFILE"] = "開啟檔案",
	["CL_PLAYER_PROFILE"] = "玩家檔案",
	["CL_TOOLTIP"] = "於對話欄產生連結",
	["CM_ACTIONS"] = "動作",
	["CM_ALT"] = "Alt",
	["CM_APPLY"] = "套用",
	["CM_BLACK"] = "黑色",
	["CM_BLUE"] = "藍色",
	["CM_CANCEL"] = "取消",
	["CM_CENTER"] = "中心",
	["CM_CLASS_DEATHKNIGHT"] = "死亡騎士",
	["CM_CLASS_DRUID"] = "德魯伊",
	["CM_CLASS_HUNTER"] = "獵人",
	["CM_CLASS_MAGE"] = "法師",
	["CM_CLASS_MONK"] = "武僧",
	["CM_CLASS_PALADIN"] = "聖騎士",
	["CM_CLASS_PRIEST"] = "牧師",
	["CM_CLASS_ROGUE"] = "盜賊",
	["CM_CLASS_SHAMAN"] = "薩滿",
	["CM_CLASS_UNKNOWN"] = "未知",
	["CM_CLASS_WARLOCK"] = "術士",
	["CM_CLASS_WARRIOR"] = "戰士",
	["CM_CLICK"] = "點擊",
	["CM_COLOR"] = "顏色",
	["CM_CTRL"] = "Ctrl",
	["CM_CYAN"] = "青色",
	["CM_DELETE"] = "刪除",
	["CM_DOUBLECLICK"] = "雙擊",
	["CM_DRAGDROP"] = "拖曳＆丟棄",
	["CM_EDIT"] = "編輯",
	["CM_GREEN"] = "綠色",
	["CM_GREY"] = "灰色",
	["CM_IC"] = "IC（進入角色）",
	["CM_ICON"] = "圖標",
	["CM_IMAGE"] = "圖像",
	["CM_L_CLICK"] = "左鍵點擊",
	["CM_LEFT"] = "左",
	["CM_LINK"] = "連結",
	["CM_LOAD"] = "載入",
	["CM_M_CLICK"] = "中鍵點擊",
	["CM_MOVE_DOWN"] = "下移",
	["CM_MOVE_UP"] = "上移",
	["CM_NAME"] = "名稱",
	["CM_OOC"] = "OOC（脫離角色）",
	["CM_OPEN"] = "打開",
	["CM_ORANGE"] = "橘色",
	["CM_PINK"] = "粉紅色",
	["CM_PLAY"] = "播放",
	["CM_PURPLE"] = "紫色",
	["CM_R_CLICK"] = "右鍵點擊",
	["CM_RED"] = "紅色",
	["CM_REMOVE"] = "清除",
	["CM_RESET"] = "重置",
	["CM_RESIZE"] = "調整尺寸",
	["CM_RESIZE_TT"] = "拖曳以縮放視窗大小。",
	["CM_RIGHT"] = "右",
	["CM_SAVE"] = "儲存",
	["CM_SELECT"] = "選擇",
	["CM_SHIFT"] = "Shift",
	["CM_SHOW"] = "顯示",
	["CM_STOP"] = "停止",
	["CM_TWEET"] = "發送推特",
	["CM_TWEET_PROFILE"] = "顯示推特資料網址",
	["CM_UNKNOWN"] = "不明",
	["CM_VALUE"] = "值",
	["CM_WHITE"] = "白色",
	["CM_YELLOW"] = "黃色",
	["CO_ADVANCED_SETTINGS"] = "進階設定",
	["CO_ADVANCED_SETTINGS_RESET"] = "重設進階設定",
	["CO_ADVANCED_SETTINGS_RESET_TT"] = "當調整後出現問題時，使用重設，回到默認設定。",
	["CO_ANCHOR_BOTTOM"] = "下方",
	["CO_ANCHOR_BOTTOM_LEFT"] = "左下方",
	["CO_ANCHOR_BOTTOM_RIGHT"] = "右下方",
	["CO_ANCHOR_CURSOR"] = "顯示游標",
	["CO_ANCHOR_LEFT"] = "左側",
	["CO_ANCHOR_RIGHT"] = "右側",
	["CO_ANCHOR_TOP"] = "上方",
	["CO_ANCHOR_TOP_LEFT"] = "左上方",
	["CO_ANCHOR_TOP_RIGHT"] = "右上方",
	["CO_CHAT"] = "聊天設定",
	["CO_CHAT_DISABLE_OOC"] = "當OOC時停止適用",
	["CO_CHAT_DISABLE_OOC_TT"] = "當你設定為「脫離角色」，Total RP 3 的設定（包括角色名稱、情感偵測、NPC對話等）將不再適用。",
	["CO_CHAT_INCREASE_CONTRAST"] = "增強顏色對比",
	["CO_CHAT_INSERT_FULL_RP_NAME"] = "按下「shift - 左鍵」插入RP名字",
	["CO_CHAT_INSERT_FULL_RP_NAME_TT"] = [=[當你使用SHIFT + 點擊聊天欄的名字時，於輸入列出現完整角色名稱。

（啟用此選項時，您仍然可以使用ALT + SHIFT + 點擊來輸入原始角色名稱。）]=],
	["CO_CHAT_MAIN"] = "聊天室主設定",
	["CO_CHAT_MAIN_COLOR"] = "顯示角色名稱客制化顏色",
	["CO_CHAT_MAIN_EMOTE"] = "表情偵測",
	["CO_CHAT_MAIN_EMOTE_PATTERN"] = "表情偵測模式",
	["CO_CHAT_MAIN_EMOTE_USE"] = "使用表情偵測",
	["CO_CHAT_MAIN_EMOTE_YELL"] = "不允許大喊表情",
	["CO_CHAT_MAIN_EMOTE_YELL_TT"] = "大喊時，不顯示*表情* 或 <表情>",
	["CO_CHAT_MAIN_NAMING"] = "名稱顯示方式",
	["CO_CHAT_MAIN_NAMING_1"] = "沿用原始名稱",
	["CO_CHAT_MAIN_NAMING_2"] = "使用角色扮演名稱",
	["CO_CHAT_MAIN_NAMING_3"] = "名字＋姓氏",
	["CO_CHAT_MAIN_NAMING_4"] = "短稱號＋名字＋姓氏",
	["CO_CHAT_MAIN_NPC"] = "ＮＰＣ對話偵測",
	["CO_CHAT_MAIN_NPC_PREFIX"] = "ＮＰＣ對話偵測模式",
	["CO_CHAT_MAIN_NPC_PREFIX_TT"] = [=[如果對話以EMOTE為字首頻道時，將被解讀為ＮＰＣ對話。

|cff00ff00By default : "|| "
（除了 " 符號，並在管狀符號後方加上空格。）]=],
	["CO_CHAT_MAIN_NPC_USE"] = "使用ＮＰＣ對話判讀",
	["CO_CHAT_MAIN_OOC"] = "ＯＯＣ判讀",
	["CO_CHAT_MAIN_OOC_COLOR"] = "ＯＯＣ顏色",
	["CO_CHAT_MAIN_OOC_PATTERN"] = "ＯＯＣ判讀模式",
	["CO_CHAT_MAIN_OOC_USE"] = "使用ＯＯＣ判讀",
	["CO_CHAT_REMOVE_REALM"] = "移除角色名稱當中的伺服器名稱",
	["CO_CHAT_USE"] = "使用聊天頻道",
	["CO_CHAT_USE_ICONS"] = "顯示玩家圖示",
	["CO_CHAT_USE_SAY"] = "對話頻道",
	["CO_CONFIGURATION"] = "設定",
	["CO_CURSOR_RIGHT_CLICK"] = "右鍵點擊開啟",
	["CO_GENERAL"] = "一般設定",
	["CO_GENERAL_BROADCAST"] = "使用廣播頻道",
	["CO_GENERAL_BROADCAST_C"] = "廣播頻道名稱",
	["CO_GENERAL_BROADCAST_TT"] = "廣播頻道和許多功能連結。禁用廣播功能將連帶禁用所有功能，例如顯示玩家在地圖上的位置、播放範圍音效、藏物處等…",
	["CO_GENERAL_CHANGELOCALE_ALERT"] = [=[立即重新登入介面來切換為 %S 語言選項嗎？

如果不要，語言選項將會在下次登入時變更。]=],
	["CO_GENERAL_COM"] = "訊息",
	["CO_GENERAL_HEAVY"] = "檔案容量警告",
	["CO_GENERAL_HEAVY_TT"] = "當你的檔案容量大小超過合理值時給予警示。",
	["CO_GENERAL_LOCALE"] = "插件本地化選擇",
	["CO_GENERAL_MISC"] = "雜項",
	["CO_GENERAL_NEW_VERSION"] = "版本昇級提示",
	["CO_GENERAL_NEW_VERSION_TT"] = "當有新版本釋出時提醒我",
	["CO_GENERAL_TT_SIZE"] = "工具列字型大小",
	["CO_GENERAL_UI_ANIMATIONS"] = "插件動畫",
	["CO_GENERAL_UI_ANIMATIONS_TT"] = "啟用插件動畫",
	["CO_GENERAL_UI_SOUNDS"] = "插件音效",
	["CO_GENERAL_UI_SOUNDS_TT"] = "啟用插件音效（當開啟視窗、切換標籤或點擊按鍵時。）。",
	["CO_GLANCE_LOCK"] = "鎖定第一印象欄",
	["CO_GLANCE_LOCK_TT"] = "避免第一印象欄被拖曳",
	["CO_GLANCE_MAIN"] = "\"第一印象\"欄",
	["CO_GLANCE_PRESET_TRP2"] = "使用Total RP 2 風格的介面設置",
	["CO_GLANCE_PRESET_TRP2_BUTTON"] = "套用",
	["CO_GLANCE_PRESET_TRP2_HELP"] = "使你能快速套用ＴＲＰ２風格的設定。",
	["CO_GLANCE_PRESET_TRP3"] = "使用Total RP 3 風格的介面設置",
	["CO_GLANCE_PRESET_TRP3_HELP"] = "快速更改你的工具列為TRP3的風格。",
	["CO_GLANCE_RESET_TT"] = "將工具列的位置重置回左側錨點。",
	["CO_GLANCE_TT_ANCHOR"] = "工具欄錨點",
	["CO_LOCATION"] = "位置設定",
	["CO_LOCATION_ACTIVATE"] = "允許公開角色位置",
	["CO_LOCATION_ACTIVATE_TT"] = "啟動腳色位置系統，允許你在小地圖上掃描其他玩家、並讓他們也能找到你。",
	["CO_LOCATION_DISABLE_OOC"] = "脫離腳色（ＯＯＣ）時不顯示位置",
	["CO_LOCATION_DISABLE_OOC_TT"] = "當你將角色狀態設定為脫離角色（ＯＯＣ）時，將不會響應您的角色位置搜索功能。",
	["CO_LOCATION_DISABLE_PVP"] = "ＰＶＰ狀態時關閉地圖追蹤",
	["CO_LOCATION_DISABLE_PVP_TT"] = "當你處於ＰＶＰ狀態時，其他玩家將無法使用小地圖位置來跟蹤你的位置。這個選項對於ＰＶＰ服來說特別有用，因為他們可能使用此功能來埋伏您。",
	["CO_LOCATION_DISABLE_WAR_MODE"] = "戰爭模式中不顯示角色位置",
	["CO_MAP_BUTTON"] = "地圖掃描鍵",
	["CO_MAP_BUTTON_POS"] = "地圖掃描鍵錨點",
	["CO_MINIMAP_BUTTON"] = "小地圖鍵",
	["CO_MINIMAP_BUTTON_FRAME"] = "框架錨點",
	["CO_MINIMAP_BUTTON_RESET"] = "重置座標",
	["CO_MINIMAP_BUTTON_RESET_BUTTON"] = "重置",
	["CO_MINIMAP_BUTTON_SHOW_HELP"] = [=[如果您正使用其他插件來展示Total RP 3的小地圖按鍵，例如（FuBar, Titan, Bazooka）你可以關閉原始小地圖上的按鍵。

|cff00ff00Reminder : 你可以使用指令 /trp3 來開啟Total RP 3的切換|r]=],
	["CO_MINIMAP_BUTTON_SHOW_TITLE"] = "顯示小地圖按鈕",
	["CO_MODULES"] = "插件狀態",
	["CO_MODULES_DISABLE"] = "停用插件",
	["CO_MODULES_ENABLE"] = "運行插件",
	["CO_MODULES_ID"] = "插件ID：%s",
	["CO_MODULES_SHOWERROR"] = "錯誤顯示",
	["CO_MODULES_STATUS"] = "狀態：%s",
	["CO_MODULES_STATUS_0"] = "關聯插件遺失",
	["CO_MODULES_STATUS_1"] = "載入中",
	["CO_MODULES_STATUS_2"] = "無法運作",
	["CO_MODULES_STATUS_3"] = "需要更新 Total RP 3",
	["CO_MODULES_STATUS_4"] = "初始化時發生錯誤",
	["CO_MODULES_STATUS_5"] = "啟動時發生錯誤",
	["CO_MODULES_TT_DEP"] = "%s- %s (版本 %s)|r",
	["CO_MODULES_TT_DEPS"] = "關聯插件",
	["CO_MODULES_TT_ERROR"] = [=[|cffff0000錯誤:|r
%s]=],
	["CO_MODULES_TT_NONE"] = "無關聯性插件",
	["CO_MODULES_TUTO"] = [=[插件可以獨立開啟或關閉，以下是常見的狀況：

|cff00ff00載入中:|r 插件已經載入並且正常執行。
|cff999999無法運作:|r 插件已經停用。
|cffff9900關聯插件遺失:|r 某些具關聯性的插件還沒運作。
|cffff9900需要更新 Total RP 3:|r 此插件需要更高版本的Total RP 3支援。
|cffff0000啟動時或初始化時發生錯誤:|r 此插件在初始化時出現錯誤，有可能造成更多問題。

|cffff9900停用插件後，必須重新啟動遊戲。]=],
	["CO_MODULES_VERSION"] = "版本: %s",
	["CO_MSP"] = "Mary Sue 協議",
	["CO_MSP_T3"] = "僅使用３號版面",
	["CO_MSP_T3_TT"] = "即使您選擇了其他的「關於」版面，３號版面依然享有Mary Sue 協議的相容性。",
	["CO_REGISTER"] = "資訊設定",
	["CO_REGISTER_ABOUT_VOTE"] = "開啟投票系統",
	["CO_REGISTER_ABOUT_VOTE_TT"] = "允許使用民意調查系統，讓你能夠對其他人的角色敘述投下「喜歡」或「不喜歡」，當然其他人也可以對你這麼做哦！",
	["CO_REGISTER_AUTO_ADD"] = "自動接收來自新玩家的資訊",
	["CO_REGISTER_AUTO_ADD_TT"] = [=[當你遭遇到新玩家時自動接收對方的資訊。

|cffff0000備註：停用這個選項會讓你無法接收任何你還沒瀏覽過的玩家資訊！如果你不希望自動接收角色的新資訊，只要關閉這個選項就可以避免。]=],
	["CO_REGISTER_AUTO_PURGE"] = "自動清理目錄",
	["CO_REGISTER_AUTO_PURGE_0"] = "不清除",
	["CO_REGISTER_AUTO_PURGE_1"] = "%s 天之後清除",
	["CO_REGISTER_AUTO_PURGE_TT"] = [=[自動清除目錄中特定時間內的角色檔案，你可以選擇該時間的長短。

|cff00ff00備註：跟你有特殊關係的角色將永遠不會被清除。

|cffff9900當你的資料數量達到一定的極限值時，魔獸世界會自動清除所有資料，所以我們強烈建議你不要關閉此選項。]=],
	["CO_SANITIZER"] = "整理接收的角色資訊",
	["CO_SANITIZER_TT"] = "清除接收的資訊中不被你的設定所允許的部分。（色彩、圖像等…）",
	["CO_TARGETFRAME"] = "目標欄位設定",
	["CO_TARGETFRAME_ICON_SIZE"] = "圖示大小",
	["CO_TARGETFRAME_USE"] = "顯示條件",
	["CO_TARGETFRAME_USE_1"] = "總是顯示",
	["CO_TARGETFRAME_USE_2"] = "只有進入角色（IC）時顯示",
	["CO_TARGETFRAME_USE_3"] = "永不顯示（停用）",
	["CO_TARGETFRAME_USE_TT"] = "選擇你想在什麼情況下顯示對方的角色卡。",
	["CO_TOOLBAR"] = "各項欄位設定",
	["CO_TOOLBAR_CONTENT"] = "工具列設定",
	["CO_TOOLBAR_CONTENT_RPSTATUS"] = "角色狀態（IC／OOC）",
	["CO_TOOLBAR_CONTENT_STATUS"] = "玩家狀態（離開／請勿打擾）",
	["CO_TOOLBAR_ICON_SIZE"] = "圖示尺寸",
	["CO_TOOLBAR_MAX"] = "單行圖示最大數量",
	["CO_TOOLBAR_MAX_TT"] = "如果你希望工具列是垂直的，將本數值設定為１！",
	["CO_TOOLBAR_SHOW_ON_LOGIN"] = "登入時顯示工具欄。",
	["CO_TOOLBAR_SHOW_ON_LOGIN_HELP"] = "如果你不希望登入時就顯示工具欄，可以取消此選項。",
	["CO_TOOLTIP"] = "提示欄設定",
	["CO_TOOLTIP_ANCHOR"] = "顯示位置",
	["CO_TOOLTIP_ANCHORED"] = "提示欄座標對應欄位",
	["CO_TOOLTIP_CHARACTER"] = "角色卡提示欄",
	["CO_TOOLTIP_CLIENT"] = "顯示伺服器",
	["CO_TOOLTIP_COLOR"] = "顯示自訂顏色",
	["CO_TOOLTIP_COMBAT"] = "戰鬥中隱藏欄位",
	["CO_TOOLTIP_COMMON"] = "共通設定",
	["CO_TOOLTIP_CONTRAST"] = "增加顏色對比",
	["CO_TOOLTIP_CONTRAST_TT"] = "當你使用自訂顏色時，增加顏色對比可以避免選擇了太暗的顏色。",
	["CO_TOOLTIP_CROP_TEXT"] = "剪裁不合理的過長文本",
	["CO_TOOLTIP_CROP_TEXT_TT"] = [=[角色卡提示欄中各欄位的字數有限，避免產生過長的情況。

|cfffff569各欄位限制：
名稱：100單位
稱號：150單位
種族：50單位
職業：50單位|r]=],
	["CO_TOOLTIP_CURRENT"] = "顯示其他資訊",
	["CO_TOOLTIP_CURRENT_SIZE"] = "其他資訊的最大長度",
	["CO_TOOLTIP_FT"] = "顯示完整稱號",
	["CO_TOOLTIP_GUILD"] = "顯示公會內容",
	["CO_TOOLTIP_HIDE_ORIGINAL"] = "隱藏遊戲內建提示欄",
	["CO_TOOLTIP_ICONS"] = "顯示圖示",
	["CO_TOOLTIP_IN_CHARACTER_ONLY"] = "脫離角色（OOC）時隱藏",
	["CO_TOOLTIP_MAINSIZE"] = "主要文字尺寸",
	["CO_TOOLTIP_NO_FADE_OUT"] = "立即隱藏取代淡出效果",
	["CO_TOOLTIP_NOTIF"] = "顯示提示",
	["CO_TOOLTIP_NOTIF_TT"] = "當同伺服器的對象玩家有未讀的資訊時，顯示驚嘆號通知圖示。",
	["CO_TOOLTIP_OWNER"] = "顯示主人",
	["CO_TOOLTIP_PETS"] = "夥伴提示欄",
	["CO_TOOLTIP_PETS_INFO"] = "顯示夥伴資訊",
	["CO_TOOLTIP_PROFILE_ONLY"] = "只有目標有檔案時才顯示",
	["CO_TOOLTIP_RACE"] = "顯示種族、職業及等級",
	["CO_TOOLTIP_REALM"] = "顯示伺服器",
	["CO_TOOLTIP_RELATION"] = "顯示關係對應顏色",
	["CO_TOOLTIP_RELATION_TT"] = "將角色卡欄位的邊框設定為關係對應顏色",
	["CO_TOOLTIP_SPACING"] = "保持空隙",
	["CO_TOOLTIP_SPACING_TT"] = "提示欄中的文句之間保持空隙，以便閱讀。",
	["CO_TOOLTIP_SUBSIZE"] = "二級字體尺寸",
	["CO_TOOLTIP_TARGET"] = "顯示目標",
	["CO_TOOLTIP_TERSIZE"] = "三級字體尺寸",
	["CO_TOOLTIP_TITLE"] = "顯示頭銜",
	["CO_TOOLTIP_USE"] = "使用角色／夥伴欄位",
	["CO_WIM"] = "|cffff9900停用悄悄話頻道。",
	["COM_LIST"] = "指令表",
	["COM_RESET_RESET"] = "欄位的座標已經重置！",
	["DB_ABOUT"] = "關於 Total RP 3",
	["DB_HTML_GOTO"] = "點擊開啟",
	["DB_MORE"] = "更多相關插件",
	["DB_NEW"] = "最新消息",
	["DB_STATUS"] = "狀態列",
	["DB_STATUS_CURRENTLY"] = "當前活動（IC）",
	["DB_STATUS_CURRENTLY_COMMON"] = "這些狀態也會顯示在你的角色卡欄位，Keep it clear and brief as |cffff9900by default TRP3 players will only see the first 140 characters of them!",
	["DB_STATUS_CURRENTLY_OOC"] = "其他資訊（OOC）",
	["DB_STATUS_CURRENTLY_OOC_TT"] = "這裡可以輸入任何對角色還是玩家來說重要的資訊。",
	["DB_STATUS_CURRENTLY_TT"] = "此欄位搭配「TRP3 Currently frame」使用可以達到不必開啟視窗，即時於畫面上變更的效果。",
	["DB_STATUS_RP"] = "角色狀態",
	["DB_STATUS_RP_EXP"] = "老手",
	["DB_STATUS_RP_EXP_TT"] = "如果您已經是一位經驗豐富的玩家了，那您的角色欄位上將不會顯示任何特別的圖示。",
	["DB_STATUS_RP_IC"] = "進入角色（IC）",
	["DB_STATUS_RP_IC_TT"] = "這表示你正在扮演你的角色，所有你的行動都不再依據你本人的好惡抉擇，而是衷於你所設定的角色性格來起心動念。",
	["DB_STATUS_RP_OOC"] = "脫離角色（OOC）",
	["DB_STATUS_RP_OOC_TT"] = "你已經脫離你的角色狀態了，你的行為不再依據他／她的性格和行事風格。",
	["DB_STATUS_RP_VOLUNTEER"] = "新手教學志願者",
	["DB_STATUS_RP_VOLUNTEER_TT"] = "選擇此項會在你的角色卡欄位顯示黃色的驚嘆號，代表你願意協助任何角色扮演玩家解決他們的問題。",
	["DB_STATUS_XP"] = "扮演程度",
	["DB_STATUS_XP_BEGINNER"] = "菜鳥玩家",
	["DB_STATUS_XP_BEGINNER_TT"] = "選擇此項會在你的角色卡欄位上顯示一隻白色的可愛小海豹，代表你是個初學者，如果有犯錯的地方請不吝賜教哦！",
	["DB_TUTO_1"] = [=[|cffffff00角色狀態|r 指示你是進入角色還是脫離角色扮演的狀態。

|cffffff00扮演程度|r 顯示你是菜鳥、老鳥還是志願的教學者。

|cff00ff00這些資訊都會在你的角色卡欄位中顯示。]=],
	["DICE_HELP"] = "骰子可以藉由代數（xdy）來進行設定，例如：1d6／2d12／3d20…等等。代表擲x次有y面的骰子，像是1d20就是丟1次20面骰。",
	["DICE_ROLL"] = "%s 擲出了 |cffff9900%sx d%s|r|cffcc6600%s|r 並得到 |cff00ff00%s|r。",
	["DICE_ROLL_T"] = "%s %s 擲出了 |cffff9900%sx d%s|r|cffcc6600%s|r 並得到 |cff00ff00%s|r。",
	["DICE_TOTAL"] = "%s 在這次擲骰中得到 |cff00ff00%s|r 的總數。",
	["DICE_TOTAL_T"] = "%s %s 在這次擲骰中得到 |cff00ff00%s|r 的總數。",
	["DTBK_AFK"] = "Total RP 3 - 離開／請勿打擾",
	["DTBK_CLOAK"] = "Total RP 3 - 斗篷",
	["DTBK_HELMET"] = "Total RP 3 - 頭盔",
	["DTBK_LANGUAGES"] = "Total RP 3 - 語言",
	["DTBK_RP"] = "Total RP 3 - IC／OOC",
	["GEN_VERSION"] = "版本：%s（第%s次更新）",
	["GEN_WELCOME_MESSAGE"] = "感謝您使用Total RP 3  (v %s) ! 祝您玩得開心!",
	["MAP_BUTTON_NO_SCAN"] = "無可用掃描",
	["MAP_BUTTON_SCANNING"] = "掃描中",
	["MAP_BUTTON_SUBTITLE"] = "點擊以顯示可用搜尋",
	["MAP_BUTTON_TITLE"] = "角色扮演搜尋器",
	["MAP_SCAN_CHAR"] = "搜尋本地角色",
	["MAP_SCAN_CHAR_TITLE"] = "角色",
	["MM_SHOW_HIDE_MAIN"] = "顯示／隱藏主視窗",
	["MM_SHOW_HIDE_MOVE"] = "移動此圖示",
	["MM_SHOW_HIDE_SHORTCUT"] = "顯示／隱藏插件工具列",
	["NPC_TALK_BUTTON_TT"] = "開啟NPC speeches欄位來允許你使用NPC對話或表情的功能。",
	["NPC_TALK_CHANNEL"] = "頻道:",
	["NPC_TALK_COMMAND_HELP"] = "開啟NPC speeches欄。",
	["NPC_TALK_ERROR_EMPTY_MESSAGE"] = "訊息不能為空白。",
	["NPC_TALK_MESSAGE"] = "訊息",
	["NPC_TALK_NAME"] = "NPC名稱",
	["NPC_TALK_NAME_TT"] = "你可以直接用指令 %t 來顯示目標名稱，也可以留白來書寫無名稱的旁白。",
	["NPC_TALK_SAY_PATTERN"] = "說：",
	["NPC_TALK_SEND"] = "送出",
	["NPC_TALK_TITLE"] = "NPC發話（NPC speeches）",
	["NPC_TALK_WHISPER_PATTERN"] = "悄悄地說：",
	["NPC_TALK_YELL_PATTERN"] = "大喊：",
	["PATTERN_ERROR"] = "模組錯誤。",
	["PR_CO_BATTLE"] = "戰寵",
	["PR_CO_COUNT"] = "%s 寵物／坐騎綁定此角色檔案。",
	["PR_CO_EMPTY"] = "無夥伴角色檔",
	["PR_CO_MASTERS"] = "主人",
	["PR_CO_MOUNT"] = "坐騎",
	["PR_CO_NEW_PROFILE"] = "新夥伴檔案",
	["PR_CO_PET"] = "寵物",
	["PR_CO_PROFILE_DETAIL"] = "此檔案目前綁定在",
	["PR_CO_PROFILEMANAGER_TITLE"] = "夥伴檔案",
	["PR_CO_UNUSED_PROFILE"] = "此角色檔目前並無綁定在任何寵物和坐騎上。",
	["PR_CREATE_PROFILE"] = "創作角色檔",
	["PR_DELETE_PROFILE"] = "刪除角色檔",
	["PR_DUPLICATE_PROFILE"] = "複製角色檔",
	["PR_EXPORT_IMPORT_TITLE"] = "匯入／匯出檔案",
	["PR_EXPORT_PROFILE"] = "輸出角色檔",
	["PR_EXPORT_TOO_LARGE"] = [=[此角色檔容量太大以致於無法輸出。

角色檔容量: %0.2f kB
最大: 20 kB]=],
	["PR_IMPORT"] = "匯入",
	["PR_IMPORT_CHAR_TAB"] = "角色輸入器",
	["PR_IMPORT_EMPTY"] = "無法輸入角色檔",
	["PR_IMPORT_IMPORT_ALL"] = "輸入全部",
	["PR_IMPORT_PETS_TAB"] = "夥伴輸入器",
	["PR_IMPORT_PROFILE"] = "輸入角色檔",
	["PR_PROFILE"] = "角色檔",
	["PR_PROFILE_CREATED"] = "角色檔 %s 已經建立。",
	["PR_PROFILE_DELETED"] = "角色檔 %s 已經刪除。",
	["PR_PROFILE_DETAIL"] = "此角色檔目前被綁定在這些角色上",
	["PR_PROFILE_LOADED"] = "檔案%s已載入。",
	["PR_PROFILE_MANAGEMENT_TITLE"] = "檔案管理",
	["PR_PROFILEMANAGER_ACTIONS"] = "動作",
	["PR_PROFILEMANAGER_ALREADY_IN_USE"] = "檔案名稱%s不被允許。",
	["PR_PROFILEMANAGER_COUNT"] = "%s個遊戲角色綁定於此檔案。",
	["PR_PROFILEMANAGER_CREATE_POPUP"] = "請替你的新角色檔案命名，檔案名稱不能為空白。",
	["PR_PROFILEMANAGER_CURRENT"] = "當前使用檔案",
	["PR_PROFILEMANAGER_DELETE_WARNING"] = [=[你確定你要刪除檔案%s嗎？

此動作無法被返回！而且所有跟此檔案有關聯的資訊都會被銷毀！（設定內容、道具等等任何與此檔案綁定的資訊。）]=],
	["PR_PROFILEMANAGER_DUPP_POPUP"] = [=[請替您要複製的新檔案命名，
此名稱不可為空白。

此檔案不會影響已綁定原檔 %s 的角色。]=],
	["PR_PROFILEMANAGER_EDIT_POPUP"] = [=[請替您要複製的新檔案命名，
此名稱不可為空白。

改變名稱並不會連動改變角色與檔案之間的綁定關係。]=],
	["PR_PROFILEMANAGER_IMPORT_WARNING"] = "使用匯入的檔案來取代 %s 原有的內容嗎？",
	["PR_PROFILEMANAGER_IMPORT_WARNING_2"] = [=[警告：此檔案來自較舊版的TRP3，可能會有不相容的情況。

仍然要以匯入的檔案來取代 %s 的內容嗎？]=],
	["PR_PROFILEMANAGER_RENAME"] = "重新命名",
	["PR_PROFILEMANAGER_SWITCH"] = "選擇檔案",
	["PR_PROFILEMANAGER_TITLE"] = "角色檔案",
	["PR_PROFILES"] = "檔案",
	["PR_UNUSED_PROFILE"] = "此檔案當前並未綁定至任何角色。",
	["REG_COMPANION_BOUND_TO"] = "連結至…",
	["REG_COMPANION_BOUND_TO_TARGET"] = "目標",
	["REG_COMPANION_BOUNDS"] = "連結",
	["REG_COMPANION_BROWSER_BATTLE"] = "戰寵瀏覽器",
	["REG_COMPANION_BROWSER_MOUNT"] = "坐騎瀏覽器",
	["REG_COMPANION_INFO"] = "資訊",
	["REG_COMPANION_LINKED"] = "夥伴 %s 現在已經連結到檔案 %s。",
	["REG_COMPANION_LINKED_NO"] = "夥伴 %s 目前沒有和任何檔案連結。",
	["REG_COMPANION_NAME"] = "名稱",
	["REG_COMPANION_NAME_COLOR"] = "名稱顏色",
	["REG_COMPANION_TF_CREATE"] = "創建新角色擋",
	["REG_COMPANION_TF_OWNER"] = "擁有者：%s",
	["REG_COMPANION_TITLE"] = "標題",
	["REG_COMPANIONS"] = "夥伴",
	["REG_DELETE_WARNING"] = [=[你確定你要刪除 %s 的角色檔？
]=],
	["REG_IGNORE_TOAST"] = "角色已被屏蔽",
	["REG_LIST_CHAR_EMPTY"] = "無角色",
	["REG_LIST_CHAR_EMPTY2"] = "沒有角色符合搜尋結果",
	["REG_LIST_CHAR_IGNORED"] = "忽略",
	["REG_LIST_CHAR_SEL"] = "選擇角色",
	["REG_LIST_CHAR_TITLE"] = "角色列表",
	["REG_LIST_CHAR_TT_GLANCE"] = "第一印象",
	["REG_LIST_CHAR_TT_IGNORE"] = "已忽略的角色",
	["REG_LIST_CHAR_TT_NEW_ABOUT"] = "資訊未讀",
	["REG_LIST_GUILD"] = "角色公會",
	["REG_LIST_IGNORE_EMPTY"] = "無已忽略的角色",
	["REG_LIST_IGNORE_TITLE"] = "忽略名單",
	["REG_LIST_NAME"] = "角色名稱",
	["REG_LIST_PET_MASTER"] = "主人名稱",
	["REG_LIST_PET_NAME"] = "夥伴名稱",
	["REG_LIST_PET_TYPE"] = "夥伴類型",
	["REG_LIST_PETS_EMPTY"] = "沒有夥伴",
	["REG_LIST_PETS_EMPTY2"] = "沒有夥伴符合搜尋結果",
	["REG_LIST_PETS_TITLE"] = "夥伴列表",
	["REG_LIST_REALMONLY"] = "僅顯示同伺服器",
	["REG_PLAYER"] = "角色",
	["REG_PLAYER_ABOUT"] = "關於",
	["REG_PLAYER_ABOUT_ADD_FRAME"] = "新增欄位",
	["REG_PLAYER_ABOUT_EMPTY"] = "無敘述",
	["REG_PLAYER_ABOUT_MUSIC"] = "角色主題曲",
	["REG_PLAYER_ABOUT_MUSIC_LISTEN"] = "播放主題曲",
	["REG_PLAYER_ABOUT_MUSIC_REMOVE"] = "取消已選擇的主題曲",
	["REG_PLAYER_ABOUT_MUSIC_SELECT"] = "選擇角色主題曲",
	["REG_PLAYER_ABOUT_MUSIC_SELECT2"] = "選擇主題曲",
	["REG_PLAYER_ABOUT_MUSIC_STOP"] = "停止播放主題曲",
	["REG_PLAYER_ABOUT_MUSIC_THEME"] = "角色主題曲",
	["REG_PLAYER_ABOUT_NOMUSIC"] = "|cffff9900沒有主題曲",
	["REG_PLAYER_ABOUT_P"] = "文字錨點",
	["REG_PLAYER_ABOUT_REMOVE_FRAME"] = "移除此欄位",
	["REG_PLAYER_ABOUT_T1_YOURTEXT"] = "由此鍵入文字",
	["REG_PLAYER_ABOUT_TAGS"] = "內容編輯工具",
	["REG_PLAYER_ABOUT_UNMUSIC"] = "|cffff9900未知的主題曲",
	["REG_PLAYER_ABOUT_VOTE_DOWN"] = "我不喜歡這個內容",
	["REG_PLAYER_ABOUT_VOTE_NO"] = "目前沒有任何連結到此檔案的角色在線上。是否依然要讓系統送出您的看法？",
	["REG_PLAYER_ABOUT_VOTE_SENDING"] = "正在將您的意見傳送給 %s ...",
	["REG_PLAYER_ABOUT_VOTE_SENDING_OK"] = "您的意見已經讓 %s 知道了！",
	["REG_PLAYER_ABOUT_VOTE_TT"] = "您的意見會以不具名且只有對方可觀察的方式讓對方知道。",
	["REG_PLAYER_ABOUT_VOTE_TT2"] = "只有對方在線的時候您才可以提交進行投票。",
	["REG_PLAYER_ABOUT_VOTE_UP"] = "我喜歡這個內容",
	["REG_PLAYER_ABOUT_VOTES"] = "統計",
	["REG_PLAYER_ABOUT_VOTES_R"] = [=[|cff00ff00%s 喜歡這個內容！
|cffff0000%s 不是很喜歡這個內容。]=],
	["REG_PLAYER_ABOUTS"] = "關於%s",
	["REG_PLAYER_ADD_NEW"] = "新建",
	["REG_PLAYER_AGE"] = "年齡",
	["REG_PLAYER_AGE_TT"] = [=[這裡你可以描述你的腳色年紀。

有幾種做法建議:|c0000ff00
- 撰寫確切年齡
- 使用模糊的描述（幼年／少年／青年／中年…等等。）]=],
	["REG_PLAYER_BIRTHPLACE"] = "出生地",
	["REG_PLAYER_BIRTHPLACE_TT"] = [=[這裡指的是您的角色的出生地。可以是區里鄉鎮市、也可以是一塊大陸或一個國家的名字，看您想怎麼使用。

|c00ffff00您也可以點擊按鈕，直接在地圖上選擇您的出生地。]=],
	["REG_PLAYER_BKG"] = "背景設計",
	["REG_PLAYER_CARACT"] = "特徵",
	["REG_PLAYER_CHANGE_CONFIRM"] = [=[您似乎還沒儲存此檔案的變更，
確定要切換頁面嗎？
|cffff9900所做的變更將會遺失]=],
	["REG_PLAYER_CHARACTERISTICS"] = "角色資訊",
	["REG_PLAYER_CLASS"] = "職業",
	["REG_PLAYER_CLASS_TT"] = [=[這裡可以自行填寫你的職業。

|cff00ff00範例 :|r
騎士、乳酪商、礦工、軍人、奧術師…]=],
	["REG_PLAYER_COLOR_ALWAYS_DEFAULT_TT"] = [=[|cffffff00Click:|r 選擇顏色
|cffffff00Right-click:|r 放棄顏色]=],
	["REG_PLAYER_COLOR_CLASS"] = "職業欄顏色",
	["REG_PLAYER_COLOR_CLASS_TT"] = "此選項同時將會更改名字的顏色。",
	["REG_PLAYER_COLOR_TT"] = [=[|cffffff00Click:|r 選擇顏色
|cffffff00Right-click:|r 放棄顏色
|cffffff00Shift-Click:|r 直接使用調色盤]=],
	["REG_PLAYER_CURRENT"] = "目前狀況",
	["REG_COMPANIONS_SHORTDESCRIPTION"]= "简要说明",
	["REG_PLAYER_CURRENT_OOC"] = "這裡是ＯＯＣ資訊",
	["REG_PLAYER_CURRENTOOC"] = "當前狀況（ＯＯＣ）",
	["REG_PLAYER_EDIT_MUSIC_THEME"] = "主題音樂",
	["REG_PLAYER_EYE"] = "眼睛顏色",
	["REG_PLAYER_EYE_TT"] = [=[這裡可以描述你的腳色眼睛的顏色。

小提醒，就算你的腳色常常把臉遮住，這一點仍然相當重要。]=],
	["REG_PLAYER_FIRSTNAME"] = "名字",
	["REG_PLAYER_FIRSTNAME_TT"] = [=[這裡可以書寫角色的名字。這是必填的，如果你不做任何改變，將會直接使用角色ＩＤ(|cffffff00%s|r)

你也可以使用 |c0000ff00綽號 |r！]=],
	["REG_PLAYER_FULLTITLE"] = "全稱頭銜",
	["REG_PLAYER_FULLTITLE_TT"] = [=[這裡可以讓你寫下你的角色的全稱頭銜。這會比短頭銜來得更長且完整。

然而，重複的頭銜就可以不用再提了，以防空間有限。]=],
	["REG_PLAYER_GLANCE"] = "第一印象",
	["REG_PLAYER_GLANCE_BAR_TARGET"] = "「第一印象欄」預設欄位",
	["REG_PLAYER_GLANCE_CONFIG"] = [=[|cff00ff00「第一印象欄」|r 可以快速地將五個關於此角色重要且明顯的資訊傳達給其他玩家知道，目的是讓其他玩家只要短暫地看一眼就能對角色有「快速」、「精準」且「合理」的認識。因此建議不要有過於冗長、上帝視角的不合理資訊。

您可以這樣使用欄位：
|cffffff00左鍵點擊：|r 設定欄位內容
|cffffff00左鍵雙擊：|r 開啟／關閉欄位
|cffffff00右鍵點擊：|r 預設欄位選項
|cffffff00拖曳／放置：|r 變更位置]=],
	["REG_PLAYER_GLANCE_EDITOR"] = "編輯器 : 欄位 %s",
	["REG_PLAYER_GLANCE_MENU_COPY"] = "複製此欄位",
	["REG_PLAYER_GLANCE_MENU_PASTE"] = "貼上欄位： %s",
	["REG_PLAYER_GLANCE_PRESET"] = "載入預設欄位",
	["REG_PLAYER_GLANCE_PRESET_ADD"] = "預設欄位 |cff00ff00%s|r 已建立。",
	["REG_PLAYER_GLANCE_PRESET_ALERT1"] = "您必須輸入一個類別名稱",
	["REG_PLAYER_GLANCE_PRESET_CATEGORY"] = "預設欄位類別",
	["REG_PLAYER_GLANCE_PRESET_CREATE"] = "建立預設欄位",
	["REG_PLAYER_GLANCE_PRESET_GET_CAT"] = [=[%s

請輸入此預設欄位的類別。]=],
	["REG_PLAYER_GLANCE_PRESET_NAME"] = "預設欄位名稱",
	["REG_PLAYER_GLANCE_PRESET_REMOVE"] = "已刪除了預設欄位 |cff00ff00%s|r 與其內容。",
	["REG_PLAYER_GLANCE_PRESET_SAVE_SMALL"] = "以預設欄位的方式儲存",
	["REG_PLAYER_GLANCE_PRESET_SELECT"] = "選擇預設欄位",
	["REG_PLAYER_GLANCE_TITLE"] = "欄位名稱",
	["REG_PLAYER_GLANCE_UNUSED"] = "未使用的欄位",
	["REG_PLAYER_GLANCE_USE"] = "開啟此欄位",
	["REG_PLAYER_HEIGHT"] = "身高",
	["REG_PLAYER_HERE"] = "選擇位置",
	["REG_PLAYER_HERE_HOME_PRE_TT"] = [=[目前居住地設定為：
|cff00ff00%s|r.]=],
	["REG_PLAYER_HERE_HOME_TT"] = [=[|cffffff00Click|r：使用角色當前的位置來作為居住地
|cffffff00Right-click|r：清除欄位內容]=],
	["REG_PLAYER_HERE_TT"] = "|cffffff00Click|r：以角色當前的位置設定",
	["REG_PLAYER_ICON"] = "角色圖案",
	["REG_PLAYER_ICON_TT"] = "選擇一個合適的圖案來代表您的角色。",
	["REG_PLAYER_LASTNAME"] = "姓氏",
	["REG_PLAYER_LASTNAME_TT"] = "你的家族姓氏。",
	["REG_PLAYER_LEFTTRAIT"] = "左側屬性",
	["REG_PLAYER_MISC_ADD"] = "新增一個資訊欄位",
	["REG_PLAYER_MORE_INFO"] = "額外資訊",
	["REG_PLAYER_MSP_HOUSE"] = "家族名稱",
	["REG_PLAYER_MSP_MOTTO"] = "座右銘",
	["REG_PLAYER_MSP_NICK"] = "綽號",
	["REG_PLAYER_NAMESTITLES"] = "稱號及姓名",
	["REG_PLAYER_NOTES"] = "記事本",
	["REG_PLAYER_NOTES_ACCOUNT_HELP"] = "記事本是僅供私人使用的，只有你的帳號才能瀏覽其中的資訊。",
	["REG_PLAYER_NOTES_PROFILE"] = "關於 %s 的紀錄",
	["REG_PLAYER_NOTES_PROFILE_HELP"] = "這些私人的筆記和您當前的角色綁定，當您切換角色的時候筆記內容也會跟著切換。",
	["REG_PLAYER_PEEK"] = "雜項",
	["REG_PLAYER_PHYSICAL"] = "生理外觀描述",
	["REG_PLAYER_PSYCHO"] = "人格特質",
	["REG_PLAYER_PSYCHO_Acete"] = "禁慾",
	["REG_PLAYER_PSYCHO_ADD"] = "新增一個人格特質",
	["REG_PLAYER_PSYCHO_Bonvivant"] = "樂天",
	["REG_PLAYER_PSYCHO_CHAOTIC"] = "混亂",
	["REG_PLAYER_PSYCHO_Chaste"] = "純潔",
	["REG_PLAYER_PSYCHO_Conciliant"] = "典範人物",
	["REG_PLAYER_PSYCHO_Couard"] = "懦弱",
	["REG_PLAYER_PSYCHO_CREATENEW"] = "創建新的特徵",
	["REG_PLAYER_PSYCHO_Cruel"] = "粗暴",
	["REG_PLAYER_PSYCHO_CUSTOM"] = "自訂特徵",
	["REG_PLAYER_PSYCHO_CUSTOMCOLOR_LEFT_TT"] = [=[選擇一個顏色來代表左側屬性欄。

|cffffff00Click:|r 選擇顏色
|cffffff00Right-click:|r 放棄顏色
|cffffff00Shift-Click:|r 使用調色盤]=],
	["REG_PLAYER_PSYCHO_CUSTOMCOLOR_RIGHT_TT"] = [=[選擇一個顏色來代表右側屬性條。

|cffffff00Click:|r 選擇顏色
|cffffff00Right-click:|r 放棄顏色
|cffffff00Shift-Click:|r 開起調色盤]=],
	["REG_PLAYER_PSYCHO_Egoiste"] = "自私",
	["REG_PLAYER_PSYCHO_Genereux"] = "無私",
	["REG_PLAYER_PSYCHO_Impulsif"] = "衝動",
	["REG_PLAYER_PSYCHO_Indulgent"] = "寬容",
	["REG_PLAYER_PSYCHO_LEFTICON_TT"] = "設定左側圖示。",
	["REG_PLAYER_PSYCHO_Loyal"] = "守序",
	["REG_PLAYER_PSYCHO_Luxurieux"] = "淫蕩",
	["REG_PLAYER_PSYCHO_Misericordieux"] = "溫和",
	["REG_PLAYER_PSYCHO_PERSONAL"] = "人格特質",
	["REG_PLAYER_PSYCHO_Pieux"] = "迷信",
	["REG_PLAYER_PSYCHO_Pragmatique"] = "叛逆者",
	["REG_PLAYER_PSYCHO_Rationnel"] = "理性",
	["REG_PLAYER_PSYCHO_Reflechi"] = "謹慎",
	["REG_PLAYER_PSYCHO_Rencunier"] = "有仇必報",
	["REG_PLAYER_PSYCHO_RIGHTICON_TT"] = "設定右側圖示",
	["REG_PLAYER_PSYCHO_Sincere"] = "誠實",
	["REG_PLAYER_PSYCHO_SOCIAL"] = "社交特質",
	["REG_PLAYER_PSYCHO_Trompeur"] = "虛偽",
	["REG_PLAYER_PSYCHO_Valeureux"] = "勇敢",
	["REG_PLAYER_RACE"] = "種族",
	["REG_PLAYER_RACE_TT"] = "意即角色所屬的種族。不限於遊戲中可玩的種族，魔獸世界裡還有許多外型相仿但並未釋出給一般玩家使用的種族。",
	["REG_PLAYER_REGISTER"] = "基本資料",
	["REG_PLAYER_RELATIONSHIP_STATUS"] = "感情狀態",
	["REG_PLAYER_RELATIONSHIP_STATUS_DIVORCED"] = "離異",
	["REG_PLAYER_RELATIONSHIP_STATUS_MARRIED"] = "已婚",
	["REG_PLAYER_RELATIONSHIP_STATUS_SINGLE"] = "單身",
	["REG_PLAYER_RELATIONSHIP_STATUS_TAKEN"] = "已有對象",
	["REG_PLAYER_RELATIONSHIP_STATUS_TT"] = "標示角色現在的感情狀態，如果不想顯示，選擇「不顯示」就可以將此資訊欄隱藏。",
	["REG_PLAYER_RELATIONSHIP_STATUS_UNKNOWN"] = "不顯示",
	["REG_PLAYER_RELATIONSHIP_STATUS_WIDOWED"] = "喪偶",
	["REG_PLAYER_RESIDENCE"] = "居住地",
	["REG_PLAYER_RESIDENCE_SHOW"] = "居住地地圖座標",
	["REG_PLAYER_RESIDENCE_SHOW_TT"] = [=[|cff00ff00%s 

|r點擊以在地圖上顯示]=],
	["REG_PLAYER_RIGHTTRAIT"] = "右側屬性",
	["REG_PLAYER_SHOWMISC"] = "顯示雜項欄",
	["REG_PLAYER_SHOWPSYCHO"] = "顯示個性資料欄",
	["REG_PLAYER_SHOWPSYCHO_TT"] = [=[如果你想使用角色個性描述，請勾選。

如果你不想以這種方式來向其他玩家展示您的角色，請不要勾選此欄，描述框將會完全隱藏。]=],
	["REG_PLAYER_STYLE_ASSIST"] = "角色扮演協助",
	["REG_PLAYER_STYLE_BATTLE"] = "角色扮演戰鬥解決方式",
	["REG_PLAYER_STYLE_BATTLE_1"] = "使用遊戲ＰＶＰ戰鬥",
	["REG_PLAYER_STYLE_BATTLE_3"] = "使用擲骰戰鬥",
	["REG_PLAYER_STYLE_BATTLE_4"] = "使用表情戰鬥",
	["REG_PLAYER_STYLE_DEATH"] = "允許角色死亡",
	["REG_PLAYER_STYLE_FREQ"] = "ＩＣ頻率",
	["REG_PLAYER_STYLE_FREQ_1"] = "全時間角色扮演狀態",
	["REG_PLAYER_STYLE_FREQ_2"] = "大部分時間",
	["REG_PLAYER_STYLE_FREQ_3"] = "半數時間",
	["REG_PLAYER_STYLE_FREQ_4"] = "不規律",
	["REG_PLAYER_STYLE_FREQ_5"] = "全時間狀況外，非角色扮演玩家。",
	["REG_PLAYER_STYLE_GUILD"] = "公會成員",
	["REG_PLAYER_STYLE_GUILD_IC"] = "成員皆為角色扮演玩家",
	["REG_PLAYER_STYLE_GUILD_OOC"] = "成員皆為非角色扮演玩家",
	["REG_PLAYER_STYLE_HIDE"] = "不予顯示",
	["REG_PLAYER_STYLE_INJURY"] = "允許角色受到傷害的狀況",
	["REG_PLAYER_STYLE_PERMI"] = "需要經過玩家許可",
	["REG_PLAYER_STYLE_ROMANCE"] = "允許角色之間發展戀愛關係",
	["REG_PLAYER_STYLE_RPSTYLE"] = "喜好遊戲方式",
	["REG_PLAYER_STYLE_RPSTYLE_SHORT"] = "RP style",
	["REG_PLAYER_TITLE"] = "稱號",
	["REG_PLAYER_TITLE_TT"] = [=[你的角色稱號代表他經常被稱呼的頭銜，避免使用過長的稱號，過長的稱號應該輸入在長稱號區而非此處。

以下為範例的 |c0000ff00合適稱號 |r:
|c0000ff00- 伯爵夫人
- 侯爵
- 法師
- 領主
- 諸如此類…
|r以下為範例的 |cffff0000不合適稱號|r:
|cffff0000- 北方沼澤的伯爵夫人
- 暴風塔的法師
- 德萊尼行政外交官
- 諸如此類…]=],
	["REG_PLAYER_TRP2_PIERCING"] = "穿環打孔",
	["REG_PLAYER_TRP2_TATTOO"] = "刺青",
	["REG_PLAYER_TRP2_TRAITS"] = "面相",
	["REG_PLAYER_TUTO_ABOUT_T1"] = [=[這個版面可以讓你 |cff00ff00自由發揮|r你的創意。

描述不必局限於角色的|cffff9900生理狀態|r。自由地揮灑他的|cffff9900背景故事 |r或|cffff9900個性上|r的細節。

使用此版面，您可以使用工具列來插入許多裝飾和變化，如|cffffff00texts尺寸，顏色和粗體字|r。
甚至還有|cffffff00圖片，圖標或超連結|r。]=],
	["REG_PLAYER_TUTO_ABOUT_T2"] = [=[這個版面更加結構化，由| cff00ff00a各自獨立的框架列表| r所組成。

每個框架又由| cffffff00icon背景和文本| r組成。注意，您可以在這些框架中使用一些文字標籤：如顏色和圖標等。

敘述時不必局限於| cffff9900生理狀態| r。也可以撰寫他的| cffff9900背景故事 | r或他| cffff9900個性| r上的細節。]=],
	["REG_PLAYER_TUTO_ABOUT_T3"] = [=[此樣板被分割為三個部分： |cff00ff00生理描述、個性和歷史。

不一定要填滿所有欄位， |cffff9900if 空白的欄位將不會顯示|r。

每一個欄位都由 |cffffff00icon背景和文本|r呈現。你可以在這些欄位中使用特殊文本功能，例如：顏色、圖示、標籤等等…]=],
	["REG_PLAYER_WEIGHT"] = "體態",
	["REG_PLAYER_WEIGHT_TT"] = [=[此處代表你的角色身形。
例如 |c0000ff00瘦、胖或強壯…|r 或只是一般的身形。]=],
	["REG_PLAYERS"] = "玩家",
	["REG_REGISTER"] = "目錄",
	["REG_REGISTER_CHAR_LIST"] = "角色名單",
	["REG_RELATION"] = "人際關係",
	["REG_RELATION_BUSINESS"] = "工作",
	["REG_RELATION_BUSINESS_TT"] = "%s 和 %s 之間是生意上的關係。",
	["REG_RELATION_BUTTON_TT"] = [=[關係： %s
|cff00ff00%s

|cffffff00點擊以顯示可執行的動作]=],
	["REG_RELATION_FAMILY"] = "家人",
	["REG_RELATION_FAMILY_TT"] = "%s 與 %s 的關係血濃於水。",
	["REG_RELATION_FRIEND"] = "友善",
	["REG_RELATION_FRIEND_TT"] = "%s 將 %s 視為朋友。",
	["REG_RELATION_LOVE"] = "愛戀",
	["REG_RELATION_LOVE_TT"] = "%s正與%s陷入愛河！",
	["REG_RELATION_NEUTRAL"] = "中立",
	["REG_RELATION_NEUTRAL_TT"] = "%s 對 %s 沒什麼特別的感覺。",
	["REG_RELATION_NONE"] = "無",
	["REG_RELATION_NONE_TT"] = "%s 不認識 %s。",
	["REG_RELATION_TARGET"] = "|cffffff00Click: |r變更關係",
	["REG_RELATION_UNFRIENDLY"] = "不友善",
	["REG_RELATION_UNFRIENDLY_TT"] = "看來 %s 不太喜歡 %s。",
	["REG_REPORT_PLAYER_TEMPLATE_TRIAL_ACCOUNT"] = "此玩家為試玩帳號。",
	["REG_TRIAL_ACCOUNT"] = "試玩帳號",
	["REG_TT_GUILD_IC"] = "ＩＣ成員",
	["REG_TT_GUILD_OOC"] = "ＯＯＣ成員",
	["REG_TT_IGNORED"] = "＜角色已忽略＞",
	["REG_TT_IGNORED_OWNER"] = "＜使用者已忽略＞",
	["REG_TT_LEVEL"] = "等級 %s %s",
	["REG_TT_NOTIF"] = "未讀的文本",
	["REG_TT_REALM"] = "區域: |cffff9900%s",
	["REG_TT_TARGET"] = "目標： |cffff9900%s",
	["SCRIPT_ERROR"] = "腳本錯誤",
	["SCRIPT_UNKNOWN_EFFECT"] = "腳本錯誤，無法辨識的效果",
	["TB_AFK_MODE"] = "離開",
	["TB_DND_MODE"] = "請勿打擾",
	["TB_GO_TO_MODE"] = "切換至 %s 模式",
	["TB_LANGUAGE"] = "語言",
	["TB_LANGUAGES_TT"] = "變更語言",
	["TB_NORMAL_MODE"] = "有空",
	["TB_RPSTATUS_OFF"] = "角色狀態：|cffff0000脫離角色",
	["TB_RPSTATUS_ON"] = "角色狀態：|cff00ff00進入角色（IC）",
	["TB_RPSTATUS_TO_OFF"] = "切換至|cffff0000脫離角色（OOC）",
	["TB_RPSTATUS_TO_ON"] = "切換至|cff00ff00進入角色（IC）",
	["TB_STATUS"] = "玩家",
	["TB_SWITCH_CAPE_1"] = "顯示斗篷",
	["TB_SWITCH_CAPE_2"] = "隱藏斗篷",
	["TB_SWITCH_CAPE_OFF"] = "斗篷：|cffff0000隱藏",
	["TB_SWITCH_CAPE_ON"] = "斗篷：|cff00ff00已顯示",
	["TB_SWITCH_HELM_1"] = "顯示頭盔",
	["TB_SWITCH_HELM_2"] = "隱藏頭盔",
	["TB_SWITCH_HELM_OFF"] = "頭盔：|cffff0000隱藏",
	["TB_SWITCH_HELM_ON"] = "頭盔：|cff00ff00已顯示",
	["TB_SWITCH_PROFILE"] = "切換至其他角色資料",
	["TB_SWITCH_TOOLBAR"] = "切換工具欄",
	["TB_TOOLBAR"] = "工具列",
	["TF_IGNORE"] = "忽略玩家",
	["TF_IGNORE_CONFIRM"] = [=[你確定要忽略這個ＩＤ嗎？

|cffffff00%s|r

|cffff7700你可以選擇輸入自己忽略對方的原因，這是私人記錄，不會被其他玩家看到。]=],
	["TF_IGNORE_NO_REASON"] = "沒有原因",
	["TF_IGNORE_TT"] = "|cffffff00Click:|r 忽略玩家",
	["TF_OPEN_CHARACTER"] = "顯示角色頁面",
	["TF_OPEN_COMPANION"] = "顯示夥伴頁面",
	["TF_OPEN_MOUNT"] = "顯示坐騎頁面",
	["TF_PLAY_THEME"] = "播放角色主題曲",
	["TF_PLAY_THEME_TT"] = [=[|cffffff00Click:|r 播放 |cff00ff00%s
|cffffff00Right-click:|r 停止播放]=],
	["THANK_YOU_1"] = [=[{h1:c}Total RP 3{/h1}
{p:c}{col:6eff51}版本 %s (build %s){/col}{/p}
{p:c}{link*http://totalrp3.info*TotalRP3.info} — {twitter*TotalRP3*@TotalRP3} {/p}
{p:c}{link*http://discord.totalrp3.info* 加入我們的Discord}{/p}

{h2}{icon:INV_Eng_gizmo1:20} 作者：{/h2}
%AUTHORS$s

{h2}{icon:QUEST_KHADGAR:20} 其他工作人員：{/h2}
%CONTRIBUTORS$s

{h2}{icon:THUMBUP:20} 感謝{/h2}
{col:ffffff}Logo 與小地圖按鈕:{/col}
- {link*https://twitter.com/Kelandiir*@Kelandiir}

{col:ffffff}準預覽版本測試團隊：{/col}
%TESTERS$s

{col:ffffff}感謝所有朋友這些年的支持：{/col}
- For Telkos: Kharess, Kathryl, Marud, Solona, Stretcher, Lisma...
- For Ellypse: The guilds Eglise du Saint Gamon, Maison Celwë'Belore, Mercenaires Atal'ai, and more particularly Erzan, Elenna, Caleb, Siana and Adaeria

{col:ffffff}感謝EU Kirin Tor 在我們製作Total RP期間所提供的幫助：{/col}
%GUILD_MEMBERS$s

{col:ffffff}感謝 Horionne 寄給我們那本雜誌《Gamer Culte Online #14中有關角色扮演的文章。{/col}
]=],
	["THANK_YOU_ROLE_AUTHOR"] = "作者",
	["THANK_YOU_ROLE_GUILD_MEMBER"] = "公會成員",
	["THANK_YOU_ROLE_TESTER"] = "測試團隊",
	["UI_BKG"] = "背景 %s",
	["UI_CLOSE_ALL"] = "全部關閉",
	["UI_COLOR_BROWSER"] = "顏色瀏覽器",
	["UI_COLOR_BROWSER_PRESETS"] = "預設",
	["UI_COLOR_BROWSER_PRESETS_BASIC"] = "基本",
	["UI_COLOR_BROWSER_PRESETS_CLASSES"] = "類別",
	["UI_COLOR_BROWSER_PRESETS_CUSTOM"] = "自訂",
	["UI_COLOR_BROWSER_SELECT"] = "選擇顏色",
	["UI_COMPANION_BROWSER_HELP"] = "請選擇一隻戰寵",
	["UI_COMPANION_BROWSER_HELP_TT"] = [=[|cffffff00警告: |r只有已經被重新命名的戰寵才能與簡介連結。 
|cff00ff00此處僅列出符合此條件的戰寵。]=],
	["UI_FILTER"] = "過濾器",
	["UI_ICON_BROWSER"] = "圖示瀏覽器",
	["UI_ICON_BROWSER_HELP"] = "複製圖示",
	["UI_ICON_BROWSER_HELP_TT"] = [=[當此欄開啟時，你可以使用 |cffffff00ctrl + click|r 來複製圖示的名稱。

這會作用於:|cff00ff00
- 任何你背包中的物品。
- 任何法術書中的圖示。]=],
	["UI_ICON_SELECT"] = "選擇圖示",
	["UI_IMAGE_BROWSER"] = "圖片瀏覽器",
	["UI_IMAGE_SELECT"] = "選擇圖片",
	["UI_LINK_SAFE"] = "這是連結網址。",
	["UI_LINK_TEXT"] = "於此處輸入文字",
	["UI_LINK_URL"] = "http://your.url.here",
	["UI_LINK_WARNING"] = [=[這是連結網址。
你可以複製、貼上到瀏覽器上。

|cffff0000!! Disclaimer !!|r
若網址導向有危險性的網站，Total RP 將不為此負責。]=],
	["UI_MUSIC_BROWSER"] = "音樂瀏覽器",
	["UI_MUSIC_SELECT"] = "選擇音樂",
	["UI_TUTO_BUTTON"] = "教學模式",
	["UI_TUTO_BUTTON_TT"] = "點擊以開啟／關閉教學模式"
}

TRP3_API.loc:RegisterNewLocale("zhTW", "繁體中文", localeContent);

local Locale = {};
TRP3_API.Locale = Locale;

--- Initialize a locale for the addon.
function Locale.init()
	-- Register config
	TRP3_API.configuration.registerConfigKey("AddonLocale", GetLocale());
	TRP3_API.loc:SetCurrentLocale(TRP3_API.configuration.getValue("AddonLocale"), true);
end

-- Backward compatibility with older use of Total RP 3's Locale module
Locale.getText = Ellyb.Functions.bind(TRP3_API.loc.GetText, TRP3_API.loc);

---generateFrenchDeterminerForText
---@param text string @ The text containing the |2 tag to replace with the appropriate determiner
---@param followingText string @ The text that immediately follows the determiner, used to know which determiner to use
---@return string generatedText @ Text where the |2 tag is replaced by the correct determiner for what's following
function Locale.generateFrenchDeterminerForText(text, followingText)
	-- This function only applies to the French locale. If we were to call it on a different locale, do nothing
	if not IS_FRENCH_LOCALE then return text end

	if Ellyb.Strings.isAVowel(Ellyb.Strings.getFirstLetter(followingText)) then
		text = text:gsub("|2", "de");
	else
		text = text:gsub("|2 ", "d'");
	end

	return text;
end

---Generate two string with the two possible French determiners "de" and "d'" using a string that contains the |2 tag
---used by Blizzard for this purpose.
---@param text string @ A text with a |2 tag inside it
---@return string, string textWithDe, textWidthD @ Two string, one with "de" and one with "d'"
function Locale.generateFrenchDeterminersVersions(text)
	return Locale.generateFrenchDeterminerForText(text, "a"), Locale.generateFrenchDeterminerForText(text, "b");
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Companion utils
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local function isColorBlindModeEnabled()
	return ENABLE_COLORBLIND_MODE == "1";
end

local REPLACE_PATTERN, NAME_PATTERN = "%%s", "([%%S%%-%%P]+)";
local PET_OWNER_MATCHING_LINES = {
	UNITNAME_TITLE_CHARM,
	UNITNAME_TITLE_CREATION,
	UNITNAME_TITLE_GUARDIAN,
	UNITNAME_TITLE_MINION,
	UNITNAME_TITLE_PET,
}
local BATTLE_PET_OWNER_MATCHING_LINES = {
	UNITNAME_TITLE_COMPANION,
}

-- Insert the search pattern inside the strings
for key, pattern in pairs(PET_OWNER_MATCHING_LINES) do
	PET_OWNER_MATCHING_LINES[key] = pattern:gsub(REPLACE_PATTERN, NAME_PATTERN);
end
for key, pattern in pairs(BATTLE_PET_OWNER_MATCHING_LINES) do
	BATTLE_PET_OWNER_MATCHING_LINES[key] = pattern:gsub(REPLACE_PATTERN, NAME_PATTERN);
end

-- French is a funny language.
-- The possessive attribute "de" changes to "d'" if the owner's name starts with a vowel.
-- Blizzard is using the |2 tag in the global strings (like UNITNAME_TITLE_PET) for this special replacement.
-- We need to replace that tag in the strings with the two versions possible if the user is using the French client.
if IS_FRENCH_LOCALE then
	local newPetOwnerMatchingLines = {};
	for _, pattern in pairs(PET_OWNER_MATCHING_LINES) do
		local textWithDe, textWithD = Locale.generateFrenchDeterminersVersions(pattern);
		tinsert(newPetOwnerMatchingLines, textWithDe);
		tinsert(newPetOwnerMatchingLines, textWithD);
	end
	PET_OWNER_MATCHING_LINES = newPetOwnerMatchingLines;
	local newBattlePetOwnerMatchingLines = {};
	for _, pattern in pairs(BATTLE_PET_OWNER_MATCHING_LINES) do
		local textWithDe, textWithD = Locale.generateFrenchDeterminersVersions(pattern);
		tinsert(newBattlePetOwnerMatchingLines, textWithDe);
		tinsert(newBattlePetOwnerMatchingLines, textWithD);
	end
	BATTLE_PET_OWNER_MATCHING_LINES = newBattlePetOwnerMatchingLines;
end

---@param tooltipLines string[] @ A table corresponding to the tooltip lines in which we should search for a pet owner
---@return string|void owner @ The name of the owner, if found
function Locale.findPetOwner(tooltipLines)
	local masterLine = isColorBlindModeEnabled() and tooltipLines[3] or tooltipLines[2];
	if masterLine then
		local master;
		for _, matchingPattern in pairs(PET_OWNER_MATCHING_LINES) do
			master = masterLine:match(matchingPattern);
			if master then break end
		end
		return master;
	end
end

function Locale.findBattlePetOwner(lines)
	local lineNumber = 3;

	if not TRP3_DUMMY_TOOLTIP.SetCompanionPet then
		-- GameTooltip API doesn't support companion pets so this is likely
		-- a Classic client, which uses the previous line.
		lineNumber = lineNumber - 1;
	end

	if isColorBlindModeEnabled() then
		-- Colorblind mode shifts the line down by one.
		lineNumber = lineNumber + 1;
	end

	local masterLine = lines[lineNumber];
	if masterLine then
		local master;
		for _, matchingPattern in pairs(BATTLE_PET_OWNER_MATCHING_LINES) do
			master = masterLine:match(matchingPattern);
			if master then
				-- Hack for "Mascotte de niveau xxx" in French ...
				if IS_FRENCH_LOCALE and master:find("%s") then
					master = nil;
				else
					break
				end
			end
		end
		return master;
	end
end

-- Backward compatibility locale = Locale
TRP3_API.locale = TRP3_API.Locale;

--- Backward compatibility layer for third party mods
--- This will create a proxy meta table that third party mods can use
--- to insert new localization keys inside a locale.
function TRP3_API.locale.getLocale(localeID)
	---@type Locale
	local locale = TRP3_API.loc:GetLocale(localeID);

	TRP3_API.utils.log.log([[DEPRECATED USAGE OF TRP3_API.locale.getLocale(localeID) TO ADD LOCALIZATION KEYS.
Please use TRP3_API.loc:GetLocale(localeID) and locale:AddText(key, value) to insert localization strings.]], TRP3_API.utils.log.level.WARNING)

	return {
		localeContent = setmetatable({}, {
			__newindex = function(_, key, value)
				locale:AddText(key, value);
			end,
		})
	}
end

-- The default locale for any lookups in script bodies is based on the client
-- locale; this may change later based on the "addon locale" setting and cause
-- differences, but for the majority of users it should go unnoticed.
--
-- Long term we should look at fixing those things; primary area being module
-- names and descriptions which are looked up in script bodies.

TRP3_API.loc:SetCurrentLocale(GetLocale(), true);
