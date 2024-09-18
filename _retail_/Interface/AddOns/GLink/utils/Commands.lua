addonName, GLink = ...;

--/run print((select(8,GetInstanceInfo())))
-- GLink.commands = {

--     ["lookup"] = {
--         ["Item"] = {
--             ["PATTERN"] = "Hitem:(%d%)",
--         },
--         ["GameObject"] = {
--             ["PATTERN"] = "Hgobject_entry:(%d*)",
--         },
--     }

-- }
--Keep all command syntaxes here
GLink.hyperlinks = {
	["gameobject_entry"] = {
		["PATTERN"] = { "gameobject_entry:(%d*)" },
		["RETURNS"] = { "[Spawn]", "[Copy Entry]" },
		["COMMAND"] = { "gobject spawn #gameobject_entry", "GCENTRY #gameobject_entry" },
		["TOOLTIP_TEXT"] = { "Click to spawn object with ID: #gameobject_entry", "Click to copy #gameobject_entry to chat" },
	},
	["item"] = {
		["PATTERN"] = { "item:(%d*)" },
		["RETURNS"] = { "[Add]", --[["[Virtual Equip]"--]] },
		["COMMAND"] = { "additem #item", --[=[ function(itemEntry) --[[print("Virtual Equipping: " .. itemEntry);--]] C_Epsilon.VirtualEquip(itemEntry) end --]=] },
		["TOOLTIP_TEXT"] = { "Click to add item with ID: #item", --[[ "Click to equip the item (#item) virtually, allowing you to stack equipped items."  --]] },
	},
	["creature_entry"] = {
		["PATTERN"] = { "creature_entry:(%d*)" },
		["RETURNS"] = { "[Spawn]" },
		["COMMAND"] = { "npc spawn #creature_entry" },
		["TOOLTIP_TEXT"] = { "Click to spawn creature with ID: #creature_entry" },
	},
	["phaseport"] = {
		["PATTERN"] = { "Hphaseport:(.*)|h%[", "phaseport:(.*)" }, --, "phaseport:(.*)
		["RETURNS"] = { "[Teleport]" },
		["COMMAND"] = { "phase tele #phaseport" },
		["TOOLTIP_TEXT"] = { "Click to teleport to: #phaseport" },
	},
	["tele"] = {
		["PATTERN"] = { "Htele:(%d*)", "tele:(%d*)" },
		["RETURNS"] = { "[Tele]" },
		["COMMAND"] = { "tele #tele" },
		["TOOLTIP_TEXT"] = { "Click to teleport to: #tele" },
	},
	["spell"] = {

		["PATTERN"] = { "Hspell:(%d*)", "spell:(%d*)" },
		["RETURNS"] = { "[Learn]", "[Cast]", "[Aura]", "[Gobject]" },
		["COMMAND"] = { "learn #spell", "cast #spell", "aura #spell", "gobject spell #spell" },
		["TOOLTIP_TEXT"] = { "Click to learn spell with ID: #spell", "Click to cast spell with ID: #spell", "Click to apply spell aura with ID: #spell", "Apply #spell to selected gameobject." },
	},
	["enchantID"] = {

		["PATTERN"] = { "HenchantID:(%d*)", "enchantID:(%d*)" },
		["RETURNS"] = { "[Mainhand]", "[Off-Hand]" },
		["COMMAND"] = { "enchant mainhand #enchantID", "enchant offhand #enchantID" },
		["TOOLTIP_TEXT"] = { "Click to enchant Mainhand with ID: #enchantID", "Click to enchant Offhand with ID: #enchantID" },
	},
	["lookup next"] = {
		["PATTERN"] = { "Enter .lookup next to view the next (%d*) results" },
		["RETURNS"] = { "[Next]" },
		["COMMAND"] = { "lookup next" },
		["TOOLTIP_TEXT"] = { "Click to view the next 50 results." },
	},
	["NPC_GUID"] = {
		["PATTERN"] = { "%Selected NPC: GUID: |cff00CCFF(%d*)|r,", "NPC_GUID:(%d*)" },
		["RETURNS"] = { "[Go]", "[Delete]", "[Copy GUID]" },
		["COMMAND"] = { "npc go #NPC_GUID", "npc delete #NPC_GUID", "GCGUID $NPC_GUID" },
		["TOOLTIP_TEXT"] = { "Click to teleport to NPC: #NPC_GUID", "Click to delete NPC: #NPC_GUID", "Click to copy NPC: #NPC_GUID GUID" },
	},
	-- ["NPC_DISPLAYID"] = {
	--     ["PATTERN"] = {", DisplayID: |cff00CCFF(%d*)|r,", "NPC_DISPLAYID:(%d*)"},
	--     ["RETURNS"] = {"[Morph]", "[Native]", "[Mount]"},
	--     ["COMMAND"] = {"morph #NPC_DISPLAYID", "mod native #NPC_DISPLAYID", "mod mount #NPC_DISPLAYID"},
	--     ["TOOLTIP_TEXT"] = {"Click to morph into DisplayID: #NPC_DISPLAYID", "Click to native into DisplayID: #NPC_DISPLAYID", "Click to mount DisplayID: #NPC_DISPLAYID"},
	-- },
	-- ["CREATURE_DISPLAYID"] = {
	--     ["PATTERN"] = {"%[|cff00CCFF(%d*)|r.*%.m2", "CREATURE_DISPLAYID:(%d*)"},
	--     ["RETURNS"] = {"[Morph]", "[Native]", "[Mount]"},
	--     ["COMMAND"] = {"morph #CREATURE_DISPLAYID", "mod native #CREATURE_DISPLAYID", "mod mount #CREATURE_DISPLAYID"},
	--     ["TOOLTIP_TEXT"] = {"Click to morph into DisplayID: #CREATURE_DISPLAYID", "Click to native into DisplayID: #CREATURE_DISPLAYID", "Click to mount DisplayID: #CREATURE_DISPLAYID"},
	-- },
	["gameobject_GPS"] = {
		--x:(-?%d*\.?%d*)y:(-?%d*\.?%d*)z:(-?%d*\.?%d*)m:(%d*)o:(-?%d*\.?%d*)
		["PATTERN"] = { "%(?X: |cff00CCFF(-?%d*\.?%d*)|r,", "Y: |cff00CCFF(-?%d*\.?%d*)|r,", "Z: |cff00CCFF(-?%d*\.?%d*)|r:?,", "Yaw/Turn: |cff00CCFF(-?%d*\.?%d*)|r", "O: |cff00CCFF(-?%d*\.?%d*)|r", "Map: |cff00CCFF(%d*)|r", ":(-?%d*\.?%d*):(-?%d*\.?%d*):(-?%d*\.?%d*):(-?%d*\.?%d*):(%d*):(%d*)" },
		["RETURNS"] = { "[Teleport]", "[Copy Coordinates]" },
		["COMMAND"] = { "worldport #X #Y #Z #ORI #MAP", "Copy Coordinates #X #Y #Z #ORI #MAP" },
		["TOOLTIP_TEXT"] = { "Click to teleport to coordinates", "No" },
	},
	["lnkfer"] = {
		["PATTERN"] = { "lnkfer:(.+)" },
		["RETURNS"] = { "[Copy URL]" },
		["COMMAND"] = { "#lnkfer" },
		["TOOLTIP_TEXT"] = { "Click to copy URL: #lnkfer" },
	},
	--735.5 changes
	["gameobject_GUID"] = {
		["PATTERN"] = { "gameobject_GUID:(%d*)" },
		["RETURNS"] = { "[Select]", "[Go]", "[Delete]", "[Copy GUID]", "[Group]" },
		["COMMAND"] = { "gobject select #gameobject_GUID", "gobject go #gameobject_GUID", "gobject delete #gameobject_GUID", "GCGUID $gameobject_GUID", "gobj group add #gameobject_GUID" },
		["TOOLTIP_TEXT"] = { "Click to select gobject GUID: #gameobject_GUID", "Click to teleport to gobject GUID: #gameobject_GUID", "Click to delete gobject GUID: #gameobject_GUID", "Click to copy gobject GUID to chat.", "Click to add gobject GUID: #gameobject_GUID to Group" },
	},
	--creaturedisplayID
	["creatureDisplayID"] = {
		["PATTERN"] = { "creatureDisplayID:(%d*)" },
		["RETURNS"] = { "[Native]", "[Morph]", "[Mount]" },
		["COMMAND"] = { "mod native #creatureDisplayID", "morph #creatureDisplayID", "mod mount #creatureDisplayID" },
		["TOOLTIP_TEXT"] = { "Click to native into DisplayID: #creatureDisplayID", "Click to morph into DisplayID: #creatureDisplayID", "Click to mount DisplayID: #creatureDisplayID" },
	},
	["displayID"] = {
		["PATTERN"] = { "displayID:(%d*)" },
		["RETURNS"] = { "[Morph]", "[Mount]" },
		["COMMAND"] = { "morph #displayID", "mod mount #displayID" },
		["TOOLTIP_TEXT"] = { "Click to morph into DisplayID: #displayID", "Click to mount DisplayID: #displayID" },
	},
	["nativeID"] = {
		["PATTERN"] = { "nativeID:(%d*)" },
		["RETURNS"] = { "[Native]" },
		["COMMAND"] = { "mod native #nativeID" },
		["TOOLTIP_TEXT"] = { "Click to native into DisplayID: #nativeID" },
	},
	["emoteID"] = {
		["PATTERN"] = { "emoteID:(%d*)" },
		["RETURNS"] = { "[Emote]", "[Anim]" },
		["COMMAND"] = { "mod stand #emoteID", "mod anim #emoteID" },
		["TOOLTIP_TEXT"] = { "Click to mod stand emote: #emoteID", "Click to mod anim emote: #emoteID" },
	},
	["phaseID"] = {
		["PATTERN"] = { "phaseID:(%d*)" },
		["RETURNS"] = { "[Join]" },
		["COMMAND"] = { "phase enter #phaseID" },
		["TOOLTIP_TEXT"] = { "Click to enter phase: #phaseID" },
	},
	["blueprint_name"] = {
		["PATTERN"] = { "Hblueprint_name:(.+)|h%[", "blueprint_name:(.+)" },
		["RETURNS"] = { "[Spawn Blueprint]" },
		["COMMAND"] = { "gobj blue spawn #blueprint_name" },
		["TOOLTIP_TEXT"] = { "Click to spawn blueprint: #blueprint_name" },
	},
	["skyboxID"] = {
		["PATTERN"] = { "skyboxID:(%d*)" },
		["RETURNS"] = { "[Here]", "[Map]", "[Default]" },
		["COMMAND"] = { "phase set skybox here #skyboxID", "phase set skybox map #skyboxID", "phase set skybox default #skyboxID" },
		["TOOLTIP_TEXT"] = { "Click to set skybox ID here", "Click to set the maps skybox", "Click to set skybox default skybox" },
	},
	["phase_npc"] = {
		["PATTERN"] = { "phase_npc:(%d*)", "phase_npc:(%d*)" },
		["RETURNS"] = { "[Spawn]", "[Delete]" },
		["COMMAND"] = { "npc spawn #phase_npc", "ph forge npc delete #phase_npc" },
		["TOOLTIP_TEXT"] = { "Click to spawn creature with ID: #phase_npc", "Click to delete forged NPC: #phase_npc" },
	},
	["filepath"] = {
		["PATTERN"] = { "filepath:(.*)" },
		["RETURNS"] = { "" },
		["COMMAND"] = { "" },
		["TOOLTIP_TEXT"] = { "Texture filepath: #filepath" },
	},
	---927, doodad
	["doodad_uid"] = {
		["PATTERN"] = { "doodad_uid:(%d*)" },
		["RETURNS"] = { "[Select]", "[Go]", "[Delete]", "[Import]", "[Copy GUID]" },
		["COMMAND"] = { "doodad select #doodad_uid", "doodad go #doodad_uid", "doodad delete #doodad_uid", "doodad import #doodad_uid", "GCGUID $doodad_uid" },
		["TOOLTIP_TEXT"] = { "Click to select doodad GUID: #doodad_uid", "Click to teleport to doodad GUID: #doodad_uid", "Click to delete doodad GUID: #doodad_uid", "Click to import doodad GUID as an editable GObject: #doodad_uid.", "Click to copy doodad GUID to chat." },
	},
	["deleted_doodad_uid"] = {
		["PATTERN"] = { "deleted_doodad_uid:(%d*)" },
		["RETURNS"] = { "[Select]", "[Go]", "[Restore]", "[Import]", "[Copy GUID]" },
		["COMMAND"] = { "doodad select #deleted_doodad_uid", "doodad go #deleted_doodad_uid", "doodad restore #deleted_doodad_uid", "doodad import #deleted_doodad_uid", "GCGUID $deleted_doodad_uid" },
		["TOOLTIP_TEXT"] = { "Click to restore doodad GUID: #deleted_doodad_uid", "Click to teleport to doodad GUID: #deleted_doodad_uid", "Click to restore doodad GUID: #deleted_doodad_uid", "Click to import doodad GUID as an editable GObject: #deleted_doodad_uid to Group", "Click to copy doodad GUID to chat." },
	},
}
