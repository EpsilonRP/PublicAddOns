--[[
Define the Addon NameSpace
--]]
---@diagnostic disable: codestyle-check
---@format disable

local addonName, ns = ...
local LibDeflate = LibStub:GetLibrary("LibDeflate");
local AceSerializer = LibStub:GetLibrary("AceSerializer-3.0");
PhaseToolkit = {}
PhaseToolkit.NPCcategoryList={}
PhaseToolkit.TELEcategoryList={}
local PTK_NPC_CATEGORY_LIST="PTK_NPC_CATEGORY_LIST";
local PTK_TELE_CATEGORY_LIST="PTK_TELE_CATEGORY_LIST";
local PTK_LAST_MAX_ID_CATEGORY_NPC="PTK_LAST_MAX_ID_CATEGORY";
local PTK_LAST_MAX_ID_CATEGORY_TELE="PTK_LAST_MAX_ID_CATEGORY_TELE";

local function dump(obj, indent)
    indent = indent or 0
    local formatting = string.rep("  ", indent)

    if type(obj) == "table" then
        print(formatting .. "{")
        for k, v in pairs(obj) do
            local key = type(k) == "string" and string.format("%q", k) or k
            print(formatting .. "  [" .. tostring(key) .. "] = ")
            dump(v, indent + 1)
        end
        print(formatting .. "}")
    else
        print(formatting .. tostring(obj))
    end
end

local minItemLink = "|item:%d|h[%s]|h|r"
local function getShortLink(link)
	local preString, hyperlinkStr, postStr = ExtractHyperlinkString(link)
	local itemID = GetItemInfoFromHyperlink(link)
	local itemName = hyperlinkStr:match("|h%[(.*)%]|h")

	return minItemLink:format(itemID, itemName)
end

local function updateContainers()
	ContainerFrame_UpdateAll()
	C_Timer.After(0.25,ContainerFrame_UpdateAll)
end

local function RGBAToNormalized(r, g, b,a)
    return r / 255, g / 255, b / 255, a / 255
end

function PhaseToolkit.getCategoryByIdGENERIC(categoryId,type)
	if(type =="NPC") then

		for _, category in ipairs(PhaseToolkit.NPCcategoryList) do
			if category.id == categoryId then
				return category
			end
		end
		return nil
	end
	if(type =="TELE") then
		for _, category in ipairs(PhaseToolkit.TELEcategoryList) do
			if category.id == categoryId then
				return category
			end
		end
		return nil
	end
end

-- ============================== VARIABLES GLOBALES ============================== --
PhaseToolkit.LargeurMax = 170
PhaseToolkit.HauteurMax = 220
PhaseToolkit.OpenedCustomFrame = nil
PhaseToolkit.SelectedRace = 1
PhaseToolkit.SelectedGender = "male"
PhaseToolkit.SelectedMeteo = "normal"
PhaseToolkit.IsPhaseWhitelist = nil
PhaseToolkit.MapIconInfo = {
	["MinimapButtonPos"] = {
		["minimapPos"] = 207
	},
}
PhaseToolkit.itemCreatorData={}
PhaseToolkit.CommandToSend={}
PhaseToolkit.additemOption={
	{text="Anyone",value=false},
	{text="Character",value=false},
	{text="Member",value=false},
	{text="Officer",value=false},
}
PhaseToolkit.currentWhitelistType=""

PhaseToolkit.ModifyItemData=false
PhaseToolkit.npcCurrentPage=nil

PhaseToolkit.itemCreatorData.whitelistedChar={}
PhaseToolkit.itemCreatorData.whitelistedPhaseForMember={}
PhaseToolkit.itemCreatorData.whitelistedPhaseForOfficer={}
PhaseToolkit.GeneralStat = {
	["complexion"] = 1,
	["face"] = 1,
	["haircolor"] = 1,
	["eyecolor"] = 1,
	["jewelrycolor"] = 1,
	["faceshape"] = 1,
	["mustache"] = 1,
	["earrings"] = 1,
	["piercings"] = 1,
	["eyebrows"] = 1,
	["skincolor"] = 1,
	["gemcolor"] = 1,
	["scars"] = 1,
	["ears"] = 1,
	["necklace"] = 1,
	["sideburns"] = 1,
	["secondaryeyecolor"] = 1,
	["eyetype"] = 1,
	["stubble"] = 1,
	["hairstyle"] = 1,
	["beard"] = 1,
	["makeup"] = 1,
	["tattoocolor"] = 1,
	["bodytattoo"] = 1,
	["hand(left)"] = 1,
	["hand(right)"] = 1,
	["leg(left)"]=1,
	["leg(right)"]=1,
	["arm(left)"]=1,
	["arm(right)"]=1,
	["tusks"] = 1,
	["grime"] = 1,
	["posture"] = 1,
	["body"] = 1,
	["garment"] = 1,
	["bodyshape"] = 1,
	["feathercolor"] = 1,
	["feather"] = 1,
	["facetattoo"] = 1,
	["handjewelry"] = 1,
	["runes"] = 1,
	["runescolor"] = 1,
	["blindfold"] = 1,
	["vines"] = 1,
	["vinecolor"] = 1,
	["horns"] = 1,
	["bodytype"] = 1,
	["headdress"] = 1,
	["furcolor"] = 1,
	["facefeatures"] = 1,
	["hairgradient"] = 1,
	["facetype"] = 1,
	["spine"] = 1,
	["skintype"] = 1,
	["ribs"] = 1,
	["hips"] = 1,
	["mane"] = 1,
	["accentcolor"] = 1,
	["facepaint"] = 1,
	["wristjewelry"]=1,
	["hornmarkings"]=1,
	["tail"]=1,
	["flower"]=1,
	["paintcolor"]=1,
	["hornstyle"]=1,
	["bodypaint"]=1,
	["foremane"]=1,
	["nosering"]=1,
	["hair"]=1,
	["horncolor"]=1,
	["taildecoration"]=1,
	["horndecoration"]=1,
	["goatee"]=1,
	["legjewelry"]=1,
	["armjewelry"]=1,
	["earjewelry"]=1,
	["hairdecoration"]=1,
	["goggles"]=1,
	["hairstreaks"]=1,
	["hairaccessory"]=1,
	["tattoostyle"]=1,
	["nosepiercing"]=1,
	["bandages"]=1,
	["tuskdecoration"]=1,
	["mouthpiercing"]=1,
	["hairhighlight"]=1,
	["browpiercing"]=1,
	["nose"]=1,
	["chin"]=1,
	["runecolor"]=1,
	["armbands"]=1,
	["bracelets"]=1,
	["tendrils"]=1,
	["trims"]=1,
	["facetendrils"]=1,
	["hornaccessories"]=1,
	["facialhair"]=1,
	["fangs"] = 1,
	["hairaccents"] = 1,
	["secondaryearstyle"] = 1,
	["jawjewelry"] = 1,
	["facejewelry"] = 1,
	["eyeshape"] = 1,
	["luminoushands"] = 1,
	["chinjewelry"] = 1,
	["hornwraps"] = 1,
	["bodypaintcolor"] = 1,
	["bodymarkings"] = 1,
	["tentacles"] = 1,
	["facemarkings"] = 1,
	["facerune"] = 1,
	["bodyrune"] = 1,
	["jawdecoration"] = 1,
	["eargauge"] = 1,
	["tattoo"] = 1,
	["pattern"] = 1,
	["patterncolor"] = 1,
	["snout"] = 1,
	["bodypiercings"] = 1,
	["chestmodification"] = 1,
	["arm(right"] = 1,
	["facemodification"] = 1,
	["optics"] = 1,
	["chinmodification"] = 1,
	["earmodification"] = 1,
	["bodyfur"]=1,
	["claws"] = 1,
	["earstyle"] = 1,
}
PhaseToolkit.ModeFR = false

PhaseToolkit.IntensiteMeteo = 1
PhaseToolkit.IntensiteMeteoMin, IntensiteMeteoMax = 1, 100

--Pool of category used for filtering no max size
PhaseToolkit.NPCcategoryToFilterPool={}
PhaseToolkit.TELEcategoryToFilterPool={}

PhaseToolkit.Meteo = {
	{ text = "Normal",           value = "normal" },
	{ text = "Fog",              value = "fog" },
	{ text = "Rain",             value = "rain" },
	{ text = "Snow",             value = "snow" },
	{ text = "Sandstorm",        value = "sandstorm" },
	{ text = "Thunderstorm",     value = "thunderstorm" },
	{ text = "Black Rain",       value = "blackrain" },
	{ text = "Blood Rain",       value = "bloodrain" },
	{ text = "Black Snow",       value = "blacksnow" },
	{ text = "Mist Grain",       value = "mistgrain" },
	{ text = "Fireball",         value = "fireball" },
	{ text = "Deathwing",        value = "deathwing" },
	{ text = "Fire Spark",       value = "firespark" },
	{ text = "Arcane Spark",     value = "arcanespark" },
	{ text = "Thunder",          value = "thunder" },
	{ text = "Ash",              value = "ash" },
	{ text = "Embers",           value = "embers" },
	{ text = "Mist White",       value = "mistwhite" },
	{ text = "Mist Yellow",      value = "mistyellow" },
	{ text = "Mist Black",       value = "mistblack" },
	{ text = "Burning",          value = "burning" },
	{ text = "Red Spark",        value = "redspark" },
	{ text = "Petals",           value = "petals" },
	{ text = "Gale",             value = "gale" },
	{ text = "Arcane Lightning", value = "arcanelightning" },
	{ text = "Blue Fissure",     value = "bluefissure" },
	{ text = "Smog",             value = "smog" },
	{ text = "Arcane Rain",      value = "arcanerain" },
	{ text = "Soot",             value = "soot" },
	{ text = "Star Rain",        value = "starrain" },
	{ text = "Arcane Fissure",   value = "arcanefissure" },
	{ text = "Fire Rain",        value = "firerain" },
	{ text = "Spirit Tower",     value = "spirittower" },
	{ text = "Spirits",          value = "spirits" },
	{ text = "Pollen",           value = "pollen" },
	{ text = "Red Bolt Rain",    value = "redboltrain" },
	{ text = "Wind",             value = "wind" },
	{ text = "Wisps",            value = "wisps" },
	{ text = "Firestreak Rain",  value = "firestreakrain" },
	{ text = "Starfall",         value = "starfall" },
	{ text = "Twinkle",          value = "twinkle" },
	{ text = "Pulsars",          value = "pulsars" },
}
PhaseToolkit.Races = {
	["Human"] = 1,
	["Orc"] = 2,
	["Dwarf"] = 3,
	["NightElf"] = 4,
	["Undead"] = 5,
	["Tauren"] = 6,
	["Gnome"] = 7,
	["Troll"] = 8,
	["Goblin"] = 9,
	["BloodElf"] = 10,
	["Draenei"] = 11,
	["Worgen"] = 22,
	["Pandaren"] = 24,
	["Nightborne"] = 27,
	["Highmountain"] = 28,
	["VoidElf"] = 29,
	["Lightforged"] = 30,
	["Zandalari"] = 31,
	["Kul tiran"] = 32,
	["Thin Human"] = 33,
	["DarkIron"] = 34,
	["Vulpera"] = 35,
	["Mag'har"] = 36,
	["Mechagnome"] = 37,
	["Fel Orc"] = 12,
	["Naga"] = 13,
	["Broken"] = 14,
	["Skeleton"] = 15,
	["Vrykul"] = 16,
	["Tuskarr"] = 17,
	["Forest Troll"] = 18,
	["Taunka"] = 19,
	["Northrend Skeleton"] = 20,
	["Ice troll"] = 21,
}
PhaseToolkit.InfoCustom = {
	["Human"] = {
		["male"] = {
			["complexion"] = 5,
			["face"] = 24,
			["haircolor"] = 48,
			["eyecolor"] = 89,
			["jewelrycolor"] = 5,
			["faceshape"] = 4,
			["mustache"] = 12,
			["earrings"] = 9,
			["piercings"] = 4,
			["eyebrows"] = 17,
			["skincolor"] = 30,
			["gemcolor"] = 10,
			["scars"] = 12,
			["ears"] = 4,
			["necklace"] = 3,
			["sideburns"] = 8,
			["secondaryeyecolor"] = 88,
			["eyetype"] = 4,
			["stubble"] = 13,
			["hairstyle"] = 74,
			["beard"] = 21,
		},
		["female"] = {
			["complexion"] = 5,
			["face"] = 30,
			["haircolor"] = 48,
			["eyecolor"] = 89,
			["jewelrycolor"] = 5,
			["faceshape"] = 3,
			["earrings"] = 11,
			["piercings"] = 7,
			["eyebrows"] = 22,
			["skincolor"] = 30,
			["gemcolor"] = 10,
			["ears"] = 4,
			["necklace"] = 6,
			["makeup"] = 10,
			["eyetype"] = 4,
			["secondaryeyecolor"] = 88,
			["scars"] = 12,
			["hairstyle"] = 70,
		}
	},
	["Orc"] = {
		["male"] = {
			["secondaryeyecolor"] = 22,
			["tattoocolor"] = 11,
			["face"] = 9,
			["bodytattoo"] = 13,
			["eyecolor"] = 23,
			["hand(left)"] = 9,
			["faceshape"] = 3,
			["mustache"] = 5,
			["earrings"] = 8,
			["tusks"] = 7,
			["piercings"] = 7,
			["eyebrows"] = 5,
			["haircolor"] = 36,
			["facetattoo"] = 18,
			["skincolor"] = 40,
			["grime"] = 4,
			["sideburns"] = 12,
			["scars"] = 5,
			["ears"] = 2,
			["necklace"] = 8,
			["posture"] = 2,
			["body"] = 7,
			["hand(right)"] = 9,
			["stubble"] = 2,
			["hairstyle"] = 33,
			["beard"] = 18,
		},
		["female"] = {
			["secondaryeyecolor"] = 22,
			["tattoocolor"] = 11,
			["face"] = 9,
			["haircolor"] = 36,
			["eyecolor"] = 23,
			["hand(left)"] = 6,
			["faceshape"] = 2,
			["earrings"] = 17,
			["piercings"] = 5,
			["facetattoo"] = 17,
			["ears"] = 2,
			["necklace"] = 5,
			["skincolor"] = 40,
			["scars"] = 5,
			["hand(right)"] = 6,
			["bodytattoo"] = 13,
			["body"] = 7,
			["hairstyle"] = 45,
		}
	},
	["Dwarf"] = {
		["male"] = {
			["secondaryeyecolor"] = 25,
			["tattoocolor"] = 8,
			["garment"] = 3,
			["haircolor"] = 20,
			["eyecolor"] = 26,
			["bodyshape"] = 2,
			["feathercolor"] = 9,
			["faceshape"] = 2,
			["mustache"] = 15,
			["earrings"] = 5,
			["piercings"] = 6,
			["eyebrows"] = 4,
			["feather"] = 7,
			["facetattoo"] = 13,
			["skincolor"] = 29,
			["jewelrycolor"] = 7,
			["face"] = 20,
			["handjewelry"] = 4,
			["bodytattoo"] = 9,
			["hairstyle"] = 27,
			["beard"] = 28,
		},
		["female"] = {
			["piercings"] = 9,
			["eyebrows"] = 18,
			["feather"] = 7,
			["facetattoo"] = 11,
			["tattoocolor"] = 8,
			["face"] = 10,
			["bodytattoo"] = 10,
			["eyecolor"] = 26,
			["skincolor"] = 23,
			["secondaryeyecolor"] = 25,
			["feathercolor"] = 9,
			["jewelrycolor"] = 7,
			["hairstyle"] = 45,
			["haircolor"] = 20,
			["earrings"] = 14,
			["garment"] = 3,
		}
	},
	["NightElf"] = {
		["male"] = {
			["secondaryeyecolor"] = 40,
			["scars"] = 7,
			["haircolor"] = 30,
			["eyecolor"] = 41,
			["blindfold"] = 12,
			["jewelrycolor"] = 14,
			["runes"] = 7,
			["eyebrows"] = 10,
			["gemcolor"] = 14,
			["vinecolor"] = 20,
			["sideburns"] = 7,
			["runescolor"] = 6,
			["beard"] = 17,
			["horns"] = 16,
			["bodyshape"] = 2,
			["vines"] = 2,
			["faceshape"] = 2,
			["mustache"] = 7,
			["hairstyle"] = 45,
			["tattoocolor"] = 11,
			["skincolor"] = 35,
			["headdress"] = 3,
			["face"] = 12,
			["bodytattoo"] = 14,
			["furcolor"] = 30,
			["ears"] = 5,
			["necklace"] = 4,
			["earrings"] = 6,
			["eyetype"] = 2,
			["facetattoo"] = 16,
			["bodytype"] = 2,
		},
		["female"] = {
			["secondaryeyecolor"] = 40,
			["scars"] = 7,
			["haircolor"] = 30,
			["eyecolor"] = 41,
			["blindfold"] = 12,
			["jewelrycolor"] = 14,
			["piercings"] = 8,
			["eyebrows"] = 5,
			["gemcolor"] = 14,
			["vinecolor"] = 20,
			["runescolor"] = 6,
			["horns"] = 16,
			["vines"] = 2,
			["faceshape"] = 2,
			["hairstyle"] = 57,
			["tattoocolor"] = 21,
			["skincolor"] = 35,
			["face"] = 9,
			["facetattoo"] = 20,
			["bodytattoo"] = 12,
			["furcolor"] = 30,
			["runes"] = 7,
			["ears"] = 5,
			["necklace"] = 4,
			["earrings"] = 11,
			["headdress"] = 4,
			["eyetype"] = 2,
			["bodytype"] = 2,
		}
	},
	["Undead"] = {
		["male"] = {
			["leg(left)"] = 2,
			["secondaryeyecolor"] = 20,
			["hairgradient"] = 13,
			["facetype"] = 11,
			["eyecolor"] = 20,
			["facefeatures"] = 5,
			["mustache"] = 6,
			["hairstyle"] = 41,
			["arm(right)"] = 2,
			["skincolor"] = 12,
			["arm(left)"] = 2,
			["ribs"] = 4,
			["spine"] = 2,
			["ears"] = 2,
			["sideburns"] = 6,
			["skintype"] = 3,
			["eyebrows"] = 3,
			["leg(right)"] = 2,
			["haircolor"] = 17,
			["face"] = 11,
			["beard"] = 8,
		},
		["female"] = {
			["leg(left)"] = 2,
			["hips"] = 4,
			["hairgradient"] = 13,
			["haircolor"] = 17,
			["eyecolor"] = 20,
			["facefeatures"] = 4,
			["earrings"] = 2,
			["piercings"] = 15,
			["arm(right)"] = 2,
			["skincolor"] = 12,
			["arm(left)"] = 2,
			["spine"] = 2,
			["ears"] = 2,
			["necklace"] = 7,
			["skintype"] = 3,
			["secondaryeyecolor"] = 20,
			["leg(right)"] = 2,
			["face"] = 10,
			["facetype"] = 5,
			["hairstyle"] = 47,
		}
	},
	["Tauren"] = {
		["male"] = {
			["mane"] = 5,
			["secondaryeyecolor"] = 17,
			["tail"] = 4,
			["eyecolor"] = 18,
			["jewelrycolor"] = 8,
			["accentcolor"] = 18,
			["gemcolor"] = 8,
			["sideburns"] = 6,
			["facepaint"] = 9,
			["beard"] = 12,
			["hornmarkings"] = 3,
			["goatee"] = 9,
			["nosering"] = 9,
			["flower"] = 2,
			["paintcolor"] = 21,
			["hornstyle"] = 20,
			["earrings"] = 12,
			["headdress"] = 3,
			["taildecoration"] = 4,
			["horncolor"] = 16,
			["face"] = 5,
			["skincolor"] = 35,
			["necklace"] = 3,
			["hair"] = 12,
			["horndecoration"] = 8,
			["foremane"] = 12,
			["bodypaint"] = 8,
		},
		["female"] = {
			["mane"] = 2,
			["hornmarkings"] = 3,
			["secondaryeyecolor"] = 17,
			["face"] = 4,
			["eyecolor"] = 18,
			["flower"] = 2,
			["paintcolor"] = 21,
			["jewelrycolor"] = 8,
			["accentcolor"] = 18,
			["hornstyle"] = 20,
			["earrings"] = 8,
			["taildecoration"] = 5,
			["tail"] = 3,
			["skincolor"] = 27,
			["nosering"] = 12,
			["headdress"] = 3,
			["hairdecoration"] = 6,
			["gemcolor"] = 8,
			["horncolor"] = 16,
			["necklace"] = 8,
			["hair"] = 24,
			["foremane"] = 11,
			["facepaint"] = 9,
			["bodypaint"] = 8,
		}
	},
	["Gnome"] = {
		["male"] = {
			["wristjewelry"] = 2,
			["goggles"] = 2,
			["face"] = 7,
			["haircolor"] = 74,
			["eyecolor"] = 32,
			["jewelrycolor"] = 5,
			["accentcolor"] = 7,
			["mustache"] = 24,
			["earrings"] = 12,
			["piercings"] = 5,
			["eyebrows"] = 13,
			["skincolor"] = 23,
			["ears"] = 3,
			["sideburns"] = 6,
			["secondaryeyecolor"] = 31,
			["scars"] = 7,
			["hairgradient"] = 20,
			["hairstyle"] = 63,
			["hairstreaks"] = 75,
			["beard"] = 13,
		},
		["female"] = {
			["wristjewelry"] = 2,
			["goggles"] = 2,
			["hairgradient"] = 20,
			["haircolor"] = 74,
			["eyecolor"] = 32,
			["jewelrycolor"] = 5,
			["accentcolor"] = 7,
			["earrings"] = 22,
			["piercings"] = 8,
			["eyebrows"] = 19,
			["skincolor"] = 23,
			["ears"] = 3,
			["secondaryeyecolor"] = 31,
			["scars"] = 7,
			["face"] = 7,
			["hairaccessory"] = 2,
			["hairstyle"] = 59,
			["hairstreaks"] = 75,
		}
	},
	["Troll"] = {
		["male"] = {
			["nosepiercing"] = 7,
			["secondaryeyecolor"] = 23,
			["hairgradient"] = 11,
			["haircolor"] = 43,
			["eyecolor"] = 24,
			["jewelrycolor"] = 12,
			["accentcolor"] = 27,
			["bandages"] = 9,
			["eyebrows"] = 2,
			["sideburns"] = 7,
			["mouthpiercing"] = 4,
			["leg(right)"] = 18,
			["beard"] = 18,
			["hairhighlight"] = 36,
			["tattoostyle"] = 3,
			["mustache"] = 4,
			["hairstyle"] = 39,
			["arm(right)"] = 20,
			["tusks"] = 17,
			["facetattoo"] = 14,
			["arm(left)"] = 20,
			["tuskdecoration"] = 11,
			["leg(left)"] = 18,
			["necklace"] = 5,
			["tattoocolor"] = 43,
			["face"] = 5,
			["bodytattoo"] = 9,
			["skincolor"] = 36,
			["earrings"] = 11,
		},
		["female"] = {
			["leg(left)"] = 25,
			["tusks"] = 10,
			["secondaryeyecolor"] = 23,
			["face"] = 6,
			["bodytattoo"] = 10,
			["eyecolor"] = 24,
			["tattoocolor"] = 43,
			["tattoostyle"] = 3,
			["jewelrycolor"] = 12,
			["accentcolor"] = 27,
			["skincolor"] = 36,
			["nosepiercing"] = 5,
			["bandages"] = 9,
			["hairstyle"] = 54,
			["hairhighlight"] = 33,
			["arm(right)"] = 24,
			["facetattoo"] = 11,
			["arm(left)"] = 24,
			["haircolor"] = 43,
			["browpiercing"] = 4,
			["headdress"] = 3,
			["necklace"] = 9,
			["mouthpiercing"] = 4,
			["hairgradient"] = 11,
			["leg(right)"] = 25,
			["earrings"] = 12,
		}
	},
	["Goblin"] = {
		["male"] = {
			["secondaryeyecolor"] = 24,
			["face"] = 7,
			["haircolor"] = 68,
			["eyecolor"] = 25,
			["jewelrycolor"] = 8,
			["nose"] = 11,
			["mustache"] = 9,
			["earrings"] = 9,
			["eyebrows"] = 2,
			["skincolor"] = 20,
			["ears"] = 10,
			["sideburns"] = 8,
			["chin"] = 6,
			["nosering"] = 5,
			["hairgradient"] = 20,
			["hairstyle"] = 50,
			["beard"] = 12,
		},
		["female"] = {
			["skincolor"] = 16,
			["eyebrows"] = 20,
			["nosering"] = 9,
			["secondaryeyecolor"] = 24,
			["hairgradient"] = 20,
			["face"] = 10,
			["haircolor"] = 68,
			["eyecolor"] = 25,
			["bodyshape"] = 2,
			["necklace"] = 7,
			["jewelrycolor"] = 8,
			["hairstyle"] = 48,
			["nose"] = 9,
			["ears"] = 7,
			["earrings"] = 13,
			["chin"] = 7,
		}
	},
	["BloodElf"] = {
		["male"] = {
			["secondaryeyecolor"] = 40,
			["tattoocolor"] = 10,
			["face"] = 12,
			["bodytattoo"] = 17,
			["eyecolor"] = 41,
			["blindfold"] = 12,
			["jewelrycolor"] = 3,
			["accentcolor"] = 5,
			["faceshape"] = 2,
			["mustache"] = 7,
			["earrings"] = 6,
			["runes"] = 12,
			["eyebrows"] = 4,
			["hairgradient"] = 18,
			["facetattoo"] = 22,
			["skincolor"] = 34,
			["gemcolor"] = 6,
			["sideburns"] = 5,
			["horns"] = 7,
			["ears"] = 4,
			["runecolor"] = 6,
			["headdress"] = 3,
			["hairstyle"] = 54,
			["eyetype"] = 2,
			["stubble"] = 2,
			["haircolor"] = 40,
			["beard"] = 23,
		},
		["female"] = {
			["armbands"] = 4,
			["secondaryeyecolor"] = 40,
			["tattoocolor"] = 10,
			["face"] = 12,
			["bodytattoo"] = 17,
			["eyecolor"] = 41,
			["blindfold"] = 12,
			["jewelrycolor"] = 3,
			["accentcolor"] = 5,
			["faceshape"] = 2,
			["earrings"] = 14,
			["runes"] = 12,
			["headdress"] = 3,
			["gemcolor"] = 6,
			["skincolor"] = 33,
			["hairgradient"] = 18,
			["ears"] = 4,
			["necklace"] = 5,
			["horns"] = 7,
			["bracelets"] = 6,
			["eyetype"] = 2,
			["runescolor"] = 6,
			["hairstyle"] = 63,
			["haircolor"] = 40,
		}
	},
	["Draenei"] = {
		["male"] = {
			["secondaryeyecolor"] = 28,
			["face"] = 10,
			["haircolor"] = 52,
			["eyecolor"] = 28,
			["bodyshape"] = 3,
			["jewelrycolor"] = 10,
			["faceshape"] = 2,
			["mustache"] = 10,
			["earrings"] = 12,
			["eyebrows"] = 3,
			["headdress"] = 7,
			["trims"] = 2,
			["gemcolor"] = 6,
			["skincolor"] = 24,
			["tail"] = 2,
			["horns"] = 28,
			["necklace"] = 2,
			["tendrils"] = 11,
			["sideburns"] = 12,
			["horndecoration"] = 6,
			["stubble"] = 5,
			["hairstyle"] = 34,
			["beard"] = 17,
		},
		["female"] = {
			["secondaryeyecolor"] = 28,
			["horns"] = 19,
			["haircolor"] = 52,
			["eyecolor"] = 28,
			["facetendrils"] = 4,
			["hairdecoration"] = 2,
			["earrings"] = 6,
			["hornaccessories"] = 28,
			["headdress"] = 12,
			["gemcolor"] = 6,
			["face"] = 10,
			["necklace"] = 3,
			["tendrils"] = 4,
			["tail"] = 6,
			["skincolor"] = 22,
			["trims"] = 2,
			["jewelrycolor"] = 10,
			["hairstyle"] = 36,
		}
	},
	["Worgen"] = {
		["male"] = {
			["mane"] = 4,
			["secondaryeyecolor"] = 22,
			["face"] = 7,
			["eyecolor"] = 23,
			["claws"] = 2,
			["faceshape"] = 2,
			["earstyle"] = 18,
			["bodyfur"] = 4,
			["secondaryearstyle"] = 19,
			["tail"] = 5,
			["hairstyle"] = 11,
			["sideburns"] = 12,
			["furcolor"] = 15,
			["fangs"] = 2,
			["foremane"] = 10,
			["beard"] = 12,
		},
		["female"] = {
			["mane"] = 3,
			["secondaryeyecolor"] = 22,
			["face"] = 16,
			["eyecolor"] = 23,
			["claws"] = 2,
			["faceshape"] = 2,
			["earstyle"] = 20,
			["hairaccents"] = 3,
			["secondaryearstyle"] = 21,
			["tail"] = 6,
			["hairstyle"] = 16,
			["bodyfur"] = 4,
			["fangs"] = 2,
			["furcolor"] = 19,
			["foremane"] = 11,
		}
	},
	["Gilnean"] = {
		["male"] = {
			["Face"] = 19,
			["FacialHair"] = 9,
			["Haircolor"] = 6,
			["Hairstyle"] = 17,
			["Skincolor"] = 9,
		},
		["female"] = {
			["Face"] = 32,
			["Haircolor"] = 6,
			["Hairstyle"] = 28,
			["Piercings"] = 7,
			["Skincolor"] = 13,
		}
	},
	["Pandaren"] = {
		["male"] = {
			["skincolor"] = 18,
			["eyebrows"] = 5,
			["mustache"] = 7,
			["secondaryeyecolor"] = 19,
			["eyecolor"] = 20,
			["face"] = 21,
			["hairstyle"] = 22,
			["beard"] = 20,
		},
		["female"] = {
			["tail"] = 2,
			["skincolor"] = 18,
			["hairstyle"] = 20,
			["secondaryeyecolor"] = 19,
			["haircolor"] = 16,
			["face"] = 20,
			["earrings"] = 6,
			["eyecolor"] = 19,
		}
	},
	["Nightborne"] = {
		["male"] = {
			["jawjewelry"] = 5,
			["secondaryeyecolor"] = 21,
			["facejewelry"] = 4,
			["bodytattoo"] = 7,
			["eyecolor"] = 22,
			["jewelrycolor"] = 3,
			["eyeshape"] = 2,
			["mustache"] = 4,
			["earrings"] = 7,
			["eyebrows"] = 3,
			["headdress"] = 2,
			["skincolor"] = 11,
			["face"] = 14,
			["facetattoo"] = 9,
			["haircolor"] = 11,
			["luminoushands"] = 2,
			["hairstyle"] = 16,
			["chinjewelry"] = 5,
			["beard"] = 4,
		},
		["female"] = {
			["jawjewelry"] = 2,
			["secondaryeyecolor"] = 21,
			["facejewelry"] = 5,
			["bodytattoo"] = 7,
			["eyecolor"] = 22,
			["jewelrycolor"] = 3,
			["hairdecoration"] = 2,
			["eyeshape"] = 2,
			["earrings"] = 8,
			["eyebrows"] = 3,
			["headdress"] = 2,
			["skincolor"] = 11,
			["necklace"] = 4,
			["haircolor"] = 11,
			["facetattoo"] = 9,
			["luminoushands"] = 2,
			["face"] = 12,
			["hairstyle"] = 16,
			["chinjewelry"] = 4,
		}
	},
	["Highmountain"] = {
		["male"] = {
			["nosepiercing"] = 5,
			["hornmarkings"] = 2,
			["secondaryeyecolor"] = 17,
			["face"] = 5,
			["eyecolor"] = 18,
			["hornwraps"] = 3,
			["hornstyle"] = 9,
			["taildecoration"] = 4,
			["tail"] = 3,
			["skincolor"] = 10,
			["feather"] = 3,
			["headdress"] = 3,
			["bodypaint"] = 4,
			["horncolor"] = 4,
			["bodypaintcolor"] = 3,
			["hair"] = 9,
			["foremane"] = 8,
			["facepaint"] = 4,
			["horndecoration"] = 8,
			["beard"] = 9,
		},
		["female"] = {
			["nosepiercing"] = 4,
			["hornmarkings"] = 2,
			["secondaryeyecolor"] = 17,
			["face"] = 4,
			["eyecolor"] = 18,
			["hornwraps"] = 2,
			["hairdecoration"] = 4,
			["hornstyle"] = 8,
			["earrings"] = 5,
			["taildecoration"] = 5,
			["tail"] = 2,
			["skincolor"] = 10,
			["feather"] = 2,
			["headdress"] = 3,
			["facepaint"] = 4,
			["foremane"] = 7,
			["horncolor"] = 4,
			["necklace"] = 4,
			["bodypaintcolor"] = 3,
			["hair"] = 9,
			["horndecoration"] = 2,
			["bodypaint"] = 4,
		}
	},
	["VoidElf"] = {
		["male"] = {
			["secondaryeyecolor"] = 19,
			["bodymarkings"] = 3,
			["face"] = 12,
			["haircolor"] = 40,
			["eyecolor"] = 20,
			["ears"] = 3,
			["facialhair"] = 8,
			["tentacles"] = 2,
			["skincolor"] = 29,
			["stubble"] = 2,
			["hairstyle"] = 13,
			["facemarkings"] = 11,
		},
		["female"] = {
			["secondaryeyecolor"] = 19,
			["bodymarkings"] = 3,
			["face"] = 12,
			["haircolor"] = 40,
			["eyecolor"] = 20,
			["ears"] = 3,
			["facemarkings"] = 11,
			["tentacles"] = 2,
			["skincolor"] = 29,
			["earrings"] = 5,
			["hairstyle"] = 11,
		}
	},
	["Lightforged"] = {
		["male"] = {
			["facerune"] = 6,
			["eyebrows"] = 2,
			["skincolor"] = 7,
			["face"] = 10,
			["haircolor"] = 10,
			["eyecolor"] = 4,
			["facialhair"] = 12,
			["jewelrycolor"] = 13,
			["bodyrune"] = 4,
			["horndecoration"] = 4,
			["tendrils"] = 7,
			["hairstyle"] = 13,
			["tail"] = 2,
		},
		["female"] = {
			["horns"] = 13,
			["haircolor"] = 10,
			["eyecolor"] = 4,
			["jewelrycolor"] = 13,
			["hairdecoration"] = 4,
			["earrings"] = 3,
			["facerune"] = 6,
			["headdress"] = 5,
			["skincolor"] = 7,
			["tail"] = 6,
			["jawdecoration"] = 2,
			["tendrils"] = 2,
			["bodyrune"] = 4,
			["horndecoration"] = 7,
			["necklace"] = 2,
			["face"] = 10,
			["hairstyle"] = 13,
		}
	},
	["Zandalari"] = {
		["male"] = {
			["secondaryeyecolor"] = 7,
			["haircolor"] = 6,
			["eyecolor"] = 9,
			["hairstyle"] = 12,
			["piercings"] = 6,
			["skincolor"] = 6,
			["tusks"] = 7,
			["tattoocolor"] = 8,
			["eargauge"] = 3,
			["face"] = 6,
			["tattoo"] = 4,

		},
		["female"] = {
			["secondaryeyecolor"] = 7,
			["haircolor"] = 6,
			["eyecolor"] = 9,
			["earrings"] = 2,
			["piercings"] = 4,
			["skincolor"] = 6,
			["tusks"] = 7,
			["tattoocolor"] = 8,
			["necklace"] = 2,
			["tattoo"] = 5,
			["eargauge"] = 3,
			["face"] = 6,
			["hairstyle"] = 10,
		}
	},
	["Kul tiran"] = {
		["male"] = {
			["secondaryeyecolor"] = 28,
			["face"] = 7,
			["bodytattoo"] = 6,
			["eyecolor"] = 29,
			["mustache"] = 4,
			["hairstyle"] = 6,
			["skincolor"] = 20,
			["sideburns"] = 2,
			["tattoocolor"] = 8,
			["haircolor"] = 48,
			["beard"] = 4,
		},
		["female"] = {
			["secondaryeyecolor"] = 28,
			["haircolor"] = 49,
			["eyecolor"] = 29,
			["earrings"] = 7,
			["eyebrows"] = 2,
			["skincolor"] = 20,
			["necklace"] = 7,
			["tattoocolor"] = 8,
			["face"] = 7,
			["bodytattoo"] = 6,
			["hairstyle"] = 10,
		}
	},
	["Thin Human"] = {
		["male"] = {
			["hairstyle"] = 4,
			["facialhair"] = 7,
			["haircolor"] = 4,
			["skincolor"] = 4,
		},
		["female"] = {

		}
	},
	["DarkIron"] = {
		["male"] = {
			["piercings"] = 6,
			["facialhair"] = 7,
			["tattoo"] = 6,
			["skincolor"] = 5,
			["hairstyle"] = 8,
			["face"] = 10,
			["haircolor"] = 6,
			["eyecolor"] = 4,
		},
		["female"] = {
			["piercings"] = 7,
			["tattoo"] = 6,
			["skincolor"] = 5,
			["hairstyle"] = 11,
			["face"] = 10,
			["haircolor"] = 6,
			["eyecolor"] = 4,
		}
	},
	["Vulpera"] = {
		["male"] = {
			["pattern"] = 3,
			["secondaryeyecolor"] = 23,
			["face"] = 6,
			["patterncolor"] = 8,
			["eyecolor"] = 24,
			["ears"] = 6,
			["furcolor"] = 9,
			["snout"] = 6,
			["earrings"] = 2,
		},
		["female"] = {
			["pattern"] = 3,
			["secondaryeyecolor"] = 23,
			["face"] = 6,
			["patterncolor"] = 8,
			["eyecolor"] = 24,
			["ears"] = 8,
			["furcolor"] = 9,
			["snout"] = 6,
			["earrings"] = 2,
		}
	},
	["Mag'har"] = {
		["male"] = {
			["secondaryeyecolor"] = 19,
			["tattoocolor"] = 11,
			["face"] = 9,
			["haircolor"] = 36,
			["eyecolor"] = 20,
			["hand(left)"] = 8,
			["faceshape"] = 3,
			["mustache"] = 5,
			["earrings"] = 6,
			["piercings"] = 7,
			["eyebrows"] = 5,
			["facetattoo"] = 18,
			["bodypiercings"] = 2,
			["grime"] = 4,
			["tusks"] = 5,
			["skincolor"] = 15,
			["sideburns"] = 12,
			["necklace"] = 7,
			["scars"] = 5,
			["posture"] = 2,
			["hand(right)"] = 8,
			["hairstyle"] = 33,
			["bodytattoo"] = 13,
			["beard"] = 18,
		},
		["female"] = {
			["piercings"] = 4,
			["tattoocolor"] = 11,
			["skincolor"] = 15,
			["facetattoo"] = 17,
			["bodypiercings"] = 2,
			["face"] = 9,
			["bodytattoo"] = 13,
			["eyecolor"] = 20,
			["secondaryeyecolor"] = 19,
			["necklace"] = 5,
			["hand(left)"] = 6,
			["hand(right)"] = 6,
			["faceshape"] = 2,
			["hairstyle"] = 46,
			["earrings"] = 17,
			["haircolor"] = 36,
		}
	},
	["Mechagnome"] = {
		["male"] = {
			["leg(left)"] = 4,
			["secondaryeyecolor"] = 32,
			["chestmodification"] = 4,
			["hairgradient"] = 20,
			["haircolor"] = 74,
			["eyecolor"] = 32,
			["paintcolor"] = 45,
			["arm(right"] = 9,
			["mustache"] = 24,
			["hairstreaks"] = 75,
			["facemodification"] = 17,
			["optics"] = 9,
			["eyebrows"] = 13,
			["chinmodification"] = 2,
			["skincolor"] = 23,
			["arm(left)"] = 9,
			["sideburns"] = 6,
			["scars"] = 10,
			["face"] = 7,
			["leg(right)"] = 4,
			["earmodification"] = 8,
			["hairstyle"] = 62,
			["beard"] = 13,
		},
		["female"] = {
			["leg(left)"] = 4,
			["secondaryeyecolor"] = 32,
			["chestmodification"] = 4,
			["hairgradient"] = 20,
			["haircolor"] = 74,
			["eyecolor"] = 32,
			["paintcolor"] = 45,
			["hairstreaks"] = 75,
			["facemodification"] = 18,
			["optics"] = 9,
			["arm(right)"] = 9,
			["chinmodification"] = 2,
			["skincolor"] = 23,
			["arm(left)"] = 9,
			["scars"] = 10,
			["eyebrows"] = 19,
			["leg(right)"] = 4,
			["earmodification"] = 8,
			["face"] = 7,
			["hairstyle"] = 59,
		}
	},
	["Fel Orc"] = {
		["male"] = {
			["skincolor"] = 3,
		},
		["female"] = {}
	},
	["Naga"] = {
		["male"] = {
			["skincolor"] = 6
		},
		["female"] = {
			["skincolor"] = 6
		}
	},
	["Broken"] = {
		["male"] = {
			["haircolor"] = 10,
			["hairstyle"] = 3,
			["skincolor"] = 6,
		},
		["female"] = {

		}
	},
	["Skeleton"] = {
		["male"] = {

		},
		["female"] = {

		}
	},
	["Vrykul"] = {
		["male"] = {
			["facialhair"] = 6,
			["haircolor"] = 5,
			["hairstyle"] = 6,
			["skincolor"] = 6
		},
		["female"] = {

		}
	},
	["Tuskarr"] = {
		["male"] = {
			["facialhair"] = 7,
			["haircolor"] = 7,
			["hairstyle"] = 7,
			["skincolor"] = 7,
		},
		["female"] = {

		}
	},
	["Forest Troll"] = {
		["male"] = {
			["face"] = 5,
			["facialhair"] = 11,
			["haircolor"] = 10,
			["hairstyle"] = 6,
			["skincolor"] = 15
		},
		["female"] = {

		}
	},
	["Taunka"] = {
		["male"] = {
			["facialhair"] = 3,
			["skincolor"] = 4
		},
		["female"] = {

		}
	},
	["Northrend Skeleton"] = {
		["male"] = {
			["facialhair"] = 5,
			["haircolor"] = 4,
			["skincolor"] = 4
		},
		["female"] = {

		}
	},
	["Ice troll"] = {
		["male"] = {
			["facialhair"] = 5,
			["haircolor"] = 6,
			["hairstyle"] = 6,
			["skincolor"] = 8
		},
		["female"] = {

		}
	},
}
PhaseToolkit.Genre = {
	"male",
	"female"
}
PhaseToolkit.itemClass={
	{name="Item Class",classId=-1,subclass={}},
	{name="Weapon",classId=2,subclass={
		{name="Axe 1h",subclassId=0},
		{name="Axe 2h",subclassId=1},
		{name="Bows",subclassId=2},
		{name="Guns",subclassId=3},
		{name="Mace 1h",subclassId=4},
		{name="Mace 2h",subclassId=5},
		{name="Polearm",subclassId=6},
		{name="Sword 1h",subclassId=7},
		{name="Sword 2h",subclassId=8},
		{name="Warglaives",subclassId=9},
		{name="Staff",subclassId=10},
		{name="Bearclaw",subclassId=11},
		{name="Catclaw",subclassId=12},
		{name="Unarmed",subclassId=13},
		{name="Generic",subclassId=14},
		{name="Dagger",subclassId=15},
		{name="Thrown",subclassId=16},
		{name="Crossbow",subclassId=18},
		{name="Wand",subclassId=19},
		{name="Fishing pole",subclassId=20},
	}},
	{name="Armor",classId=4,subclass={
		{name="Generic",subclassId=0},
		{name="Cloth",subclassId=1},
		{name="Leather",subclassId=2},
		{name="Mail",subclassId=3},
		{name="Plate",subclassId=4},
		{name="Cosmetic",subclassId=5},
		{name="Shield",subclassId=6},
		{name="Relic",subclassId=11},
	}},
	{name="Key",classId=13,subclass={
		{name="Key",subclassId=0},
		{name="Lockpick",subclassId=1},
	}},
	{name="Miscellaneous",classId=15,subclass={
		{name="Book",subclassId=0},
		{name="Leatherworking",subclassId=1},
		{name="Engineering",subclassId=3},
		{name="Blacksmithing",subclassId=4},
	}},
}

local function filterInventoryTypeByClass(ClassId)
    local filtered = {}
    for _, item in ipairs(PhaseToolkit.itemInventoryType) do
        if item.usableFor==ClassId or item.usableFor==-1 then
            table.insert(filtered, item)
        end
    end
    return filtered
end

PhaseToolkit.itemInventoryType={
	{name="Inventory type",inventoryTypeId=-1,usableFor=-1},
	{name="Non equippable",inventoryTypeId=0,usableFor=-1},
	{name="Head",inventoryTypeId=1,usableFor=4},
	{name="Neck",inventoryTypeId=2,usableFor=4},
	{name="Shoulder",inventoryTypeId=3,usableFor=4},
	{name="Shirt",inventoryTypeId=4,usableFor=4},
	{name="Chest",inventoryTypeId=5,usableFor=4},
	{name="Waist",inventoryTypeId=6,usableFor=4},
	{name="Legs",inventoryTypeId=7,usableFor=4},
	{name="Feet",inventoryTypeId=8,usableFor=4},
	{name="Wrist",inventoryTypeId=9,usableFor=4},
	{name="Hands",inventoryTypeId=10,usableFor=4},
	{name="Back (Cloak)",inventoryTypeId=16,usableFor=4},
	{name="Finger",inventoryTypeId=11,usableFor=4},
	{name="Trinket",inventoryTypeId=12,usableFor=4},
	{name="Tabard",inventoryTypeId=19,usableFor=4},
	{name="Robe",inventoryTypeId=20,usableFor=4},
	{name="Holdable",inventoryTypeId=23,usableFor=4},
	{name="Quiver",inventoryTypeId=27,usableFor=4},
	{name="Relic",inventoryTypeId=28,usableFor=4},
	{name="One-hand",inventoryTypeId=13,usableFor=2},
	{name="Two-hand",inventoryTypeId=17,usableFor=2},
	{name="Off hand (Shield)",inventoryTypeId=14,usableFor=2},
	{name="Ranged",inventoryTypeId=15,usableFor=2},
	{name="Main hand",inventoryTypeId=21,usableFor=2},
	{name="Off hand (Weapon)",inventoryTypeId=22,usableFor=2},
	{name="Thrown",inventoryTypeId=25,usableFor=2},
	{name="Ranged Right",inventoryTypeId=26,usableFor=2},
	{name="Shield",inventoryTypeId=14,usableFor=4},
}

PhaseToolkit.itemBonding={
	{name="Bonding",bondingId=  -1},
	{name="No bonding",bondingId=0},
	{name="When picked up",bondingId=1},
	{name="When equipped",bondingId=2},
	{name="When used",bondingId=3},
	{name="Quest Item",bondingId=4},
}

PhaseToolkit.itemQuality={
	{name="Quality",qualityId=-1},
	{name="Poor",qualityId=0},
	{name="Common",qualityId=1},
	{name="Uncommon",qualityId=2},
	{name="Rare",qualityId=3},
	{name="Epic",qualityId=4},
	{name="Legendary",qualityId=5},
	{name="Artifact",qualityId=6},
	{name="Heirloom",qualityId=7},
	{name="Wow Token",qualityId=8},
}

PhaseToolkit.itemSheath={
	{name="Sheath",sheathId=-1},
	{name="Invisible",sheathId=0},
	{name="Back right",sheathId=1},
	{name="Back left",sheathId=2},
	{name="Waist",sheathId=3},
	{name="Back center",sheathId=4},
	{name="Rifle",sheathId=5},
}

PhaseToolkit.infoPerDisplay = {
	["57899"] = { race = "Human", sexe = "male" },
	["56658"] = { race = "Human", sexe = "female" },
	["51894"] = { race = "Orc", sexe = "male" },
	["53762"] = { race = "Orc", sexe = "female" },
	["49242"] = { race = "Dwarf", sexe = "male" },
	["53768"] = { race = "Dwarf", sexe = "female" },
	["54918"] = { race = "NightElf", sexe = "male" },
	["54439"] = { race = "NightElf", sexe = "female" },
	["54041"] = { race = "Undead", sexe = "male" },
	["56327"] = { race = "Undead", sexe = "female" },
	["55077"] = { race = "Tauren", sexe = "male" },
	["56316"] = { race = "Tauren", sexe = "female" },
	["51877"] = { race = "Gnome", sexe = "male" },
	["53291"] = { race = "Gnome", sexe = "female" },
	["59071"] = { race = "Troll", sexe = "male" },
	["59223"] = { race = "Troll", sexe = "female" },
	["6894"] = { race = "Goblin", sexe = "male" },
	["6895"] = { race = "Goblin", sexe = "female" },
	["62127"] = { race = "BloodElf", sexe = "male" },
	["62128"] = { race = "BloodElf", sexe = "female" },
	["57027"] = { race = "Draenei", sexe = "male" },
	["58232"] = { race = "Draenei", sexe = "female" },
	["16981"] = { race = "Fel Orc", sexe = "male" },
	["17402"] = { race = "Naga", sexe = "male" },
	["17403"] = { race = "Naga", sexe = "female" },
	["17576"] = { race = "Broken", sexe = "male" },
	["17578"] = { race = "Skeleton", sexe = "male" },
	["21685"] = { race = "Vrykul", sexe = "male" },
	["21780"] = { race = "Tuskarr", sexe = "male" },
	["21963"] = { race = "Forest Troll", sexe = "male" },
	["26316"] = { race = "Taunka", sexe = "male" },
	["26871"] = { race = "Northrend Skeleton", sexe = "male" },
	["26873"] = { race = "Ice troll", sexe = "male" },
	["29422"] = { race = "Worgen", sexe = "male" },
	["29423"] = { race = "Worgen", sexe = "female" },
	["38551"] = { race = "Pandaren", sexe = "male" },
	["38552"] = { race = "Pandaren", sexe = "female" },
	["75078"] = { race = "Nightborne", sexe = "male" },
	["75079"] = { race = "Nightborne", sexe = "female" },
	["75080"] = { race = "Highmountain", sexe = "male" },
	["75081"] = { race = "Highmountain", sexe = "female" },
	["75082"] = { race = "VoidElf", sexe = "male" },
	["75083"] = { race = "VoidElf", sexe = "female" },
	["75084"] = { race = "Lightforged", sexe = "male" },
	["75085"] = { race = "Lightforged", sexe = "female" },
	["79100"] = { race = "Zandalari", sexe = "male" },
	["79101"] = { race = "Zandalari", sexe = "female" },
	["80387"] = { race = "Kul tiran", sexe = "male" },
	["80388"] = { race = "Kul tiran", sexe = "female" },
	["82317"] = { race = "Thin Human", sexe = "male" },
	["83910"] = { race = "DarkIron", sexe = "male" },
	["83911"] = { race = "DarkIron", sexe = "female" },
	["83913"] = { race = "Vulpera", sexe = "male" },
	["83914"] = { race = "Vulpera", sexe = "female" },
	["84558"] = { race = "Mag'har", sexe = "male" },
	["84560"] = { race = "Mag'har", sexe = "female" },
	["90786"] = { race = "Mechagnome", sexe = "male" },
	["90787"] = { race = "Mechagnome", sexe = "female" },
}
PhaseToolkit.Toggleslist = {
	{ "Cheats" },
	{ "Flight" },
	{ "Knockback" },
	{ "Listed" },
	{ "Modify" },
	{ "Mounting" },
	{ "Objects" },
	{ "Silence" },
	{ "Teleport" },
}
PhaseToolkit.Toggleslist_checked = {
}

PhaseToolkit.PhaseId = 0
PhaseToolkit.creatureList = {}
PhaseToolkit.filteredCreatureList = {}

PhaseToolkit.IsCurrentlyFilteringNpcViaText = false
PhaseToolkit.IsCurrentlyFilteringNpcViaCategory = false
PhaseToolkit.IsCurrentlyFilteringTeleViaText = false
PhaseToolkit.IsCurrentlyFilteringTeleViaCategory = false

PhaseToolkit.teleList = {}
PhaseToolkit.filteredTeleList = {}
PhaseToolkit.IsCurrentlyFilteringTeleViaText = false

PhaseToolkit.tempChatFrame = nil

PhaseToolkit.npcToDeletePrompt=""
PhaseToolkit.teleToDelete=nil

-- // EpsilonLib for AddOnCommands:
local sendAddonCmd

if EpsilonLib and EpsilonLib.AddonCommands then
	sendAddonCmd = EpsilonLib.AddonCommands.Register("PhaseToolkit")
else
	-- command, callbackFn, forceShowMessages
	function sendAddonCmd(command, callbackFn, forceShowMessages)
		if EpsilonLib and EpsilonLib.AddonCommands then
			-- Reassign it.
			sendAddonCmd = EpsilonLib.AddonCommands.Register("PhaseToolkit")
			sendAddonCmd(command, callbackFn, forceShowMessages)
			return
		end

		-- Fallback ...
		print("Something went wrong with epsilib... report this please")
		SendChatMessage("." .. command, "GUILD")
	end
end

function PhaseToolkit.PTK_DEBUG_NPC_CUSTOM()
	if UnitExists("target") and not UnitIsPlayer("target") then
		sendAddonCmd("phase forge npc outfit custom",function(isSuccessful,response)
			if isSuccessful then
				-- Parse the response to extract the list after "ways:"
				local customList = {}
				response=response[1]
				response = response:gsub("|cff%x%x%x%x%x%x", ""):gsub("|r", "")
				local match = string.match(response, "ways:%s*(.+)")
				if match then
					for word in string.gmatch(match, "[^,%s]+") do
						local cleanword = string.gsub(word, ";", "")
						table.insert(customList, cleanword)
					end
				end

				-- Table to store the results for each customList item
				PhaseToolkit.NPCCustomOutfitResults = {}

				local function processCustomList(index)
					if customList[index] then
						local customItem = customList[index]

						sendAddonCmd("ph f n out custom " .. customItem, function(success, response)
							if success and response and #response > 0 then
								response=response[1]
								response= response:gsub("|cff%x%x%x%x%x%x", ""):gsub("|r", "")
								local maxId = string.match(response, "between%s+%d+%s+and%s+(%d+)")
								if(tonumber(maxId)>1) then
									PhaseToolkit.NPCCustomOutfitResults[customItem] = tonumber(maxId)
								end
							end
							processCustomList(index + 1)
						end)
					end
					if not customList[index] then
						local output = {}
						for k, v in pairs(PhaseToolkit.NPCCustomOutfitResults) do
							table.insert(output, string.format('["%s"] = %s,', k, tostring(v)))
						end
						local result = table.concat(output, "\n")
						print(result)
					end
				end

				processCustomList(1)
			end
		end);
	end

end
-- ============================== FUNCTION PRINCIPALES ============================== --
local function isKeyInTable(key)
	if PhaseToolkit.infoPerDisplay[key] then
		return true
	else
		return false
	end
end

function PhaseToolkit.ToggleMainFrame()
	if PhaseToolkit.NPCCustomiserMainFrame ~= nil then
		if PhaseToolkit.NPCCustomiserMainFrame:IsShown() then
			PhaseToolkit.NPCCustomiserMainFrame:Hide()
		else
			PhaseToolkit.NPCCustomiserMainFrame:Show()
		end
	end
end

function PhaseToolkit.ChangeNpcRace(RaceId)
	sendAddonCmd("phase forge npc outfit race " .. RaceId, nil)
end

function PhaseToolkit.ChangeNpcGender(GenderString)
	sendAddonCmd("phase forge npc outfit gender " .. GenderString, nil)
end

function PhaseToolkit.CountElements(tbl)
	local count = 0
	for i, v in pairs(tbl) do
		if v ~= 0 then
			count = count + 1
		end
	end
	return count
end

local function containsAll(text, substrings)
	if( not PhaseToolkit.IsTableEmpty(substrings))then
		for _, substring in ipairs(substrings) do
			if not string.find(string.lower(text), string.lower(substring)) then
				return false
			end
		end
	else
		return false
	end
    return true
end

local function getInventoryTypePosition(label)
	for _,inventoryType in ipairs(PhaseToolkit.itemInventoryType) do
		if(string.lower(inventoryType.name)==string.lower(label)) then
			return inventoryType.inventoryTypeId
		end
	end
end

local function getQualityObject(qualityId)
	for _,quality in ipairs(PhaseToolkit.itemQuality) do
		if(quality.qualityId==qualityId) then
			return quality
		end
	end
end

local function getClassByClassID(classID)
	for _,class in ipairs(PhaseToolkit.itemClass)do
		if(class.classId==classID) then
			return class
		end
	end
end

local function getBindingObject(bindingID)
	for _,binding in ipairs(PhaseToolkit.itemBonding) do
		if(binding.bondingId==bindingID) then
			return binding
		end
	end
end

local function getWeaponTypeId(weapontypeSTR,inventoryType)
	local returnObj=nil
	local subString={}
	if(string.lower(inventoryType):find("two")~=nil) then
		tinsert(subString,"2h")
	elseif(string.lower(inventoryType):find("one")~=nil) then
		tinsert(subString,"1h")
	end
	weapontypeSTR=string.trim(weapontypeSTR)

	--for this we make two pass,one with looking only for the weaponTypeSTR wich is for example "warglaives"
	-- if we don't find it,we search for 1h and 2h version
	for _,weapontypeOBJ in ipairs(PhaseToolkit.itemClass[PhaseToolkit.itemCreatorData.itemClass].subclass) do
		if(string.lower(weapontypeOBJ.name)==string.lower(weapontypeSTR)) then
			returnObj= weapontypeOBJ
		end
		if(PhaseToolkit.IsTableEmpty(subString) and string.lower(weapontypeOBJ.name):find(string.lower(weapontypeSTR)) ) then
			returnObj= weapontypeOBJ
		end
	end

	--Second pass looking for 1h or 2h u know only if we didn't got it the first time
	if(returnObj==nil or returnObj=={}) then
		for _,weapontypeOBJ in ipairs(PhaseToolkit.itemClass[PhaseToolkit.itemCreatorData.itemClass].subclass) do
			weapontypeSTR=string.trim(weapontypeSTR)
			if(containsAll(weapontypeOBJ.name,subString)) then
				returnObj= weapontypeOBJ
			end
		end
	end
	return returnObj
end

function PhaseToolkit.SelectRaceFrame()
	if (PhaseToolkit.CustomFrame == nil) then
		PhaseToolkit.CreateCustomFrame()
	end

	PhaseToolkit.NombreDeLigne = math.ceil(((PhaseToolkit.CountElements(PhaseToolkit.InfoCustom[PhaseToolkit.GetRaceNameByID(PhaseToolkit.SelectedRace)][PhaseToolkit.SelectedGender]) / 3)))
	PhaseToolkit.ToggleCustomFrame(PhaseToolkit.GetRaceNameByID(PhaseToolkit.SelectedRace))
	if PhaseToolkit.CustomFrame:IsShown() and PhaseToolkit.showCustomButton.currentIcon == "450905" then
		PhaseToolkit.switchOpenCustomGridButton(PhaseToolkit.showCustomButton)
	end
end

function PhaseToolkit.GetRaceNameByID(id)
	for race, raceID in pairs(PhaseToolkit.Races) do
		if raceID == id then
			return race
		end
	end
	return nil
end

function PhaseToolkit.ChangePhaseWeather()
	sendAddonCmd("phase set weather " .. PhaseToolkit.SelectedMeteo .. " " .. PhaseToolkit.IntensiteMeteo, nil)
end

function PhaseToolkit.GetMaxStringLength(stringTable)
	local maxLength = 0
	local tempFontString = UIParent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	for _, str in ipairs(stringTable) do
		tempFontString:SetText(str)
		local strLength = tempFontString:GetStringWidth()
		if strLength > maxLength then
			maxLength = strLength
		end
	end
	return maxLength
end

function PhaseToolkit.GetMaxNameWidth(creatureTable)
	-- Créer un objet FontString temporaire pour mesurer les tailles de texte
	local tempFontString = UIParent:CreateFontString(nil, "OVERLAY", "GameFontNormal")

	-- Variable pour stocker la largeur maximale trouvée
	local maxWidth = 0

	-- Parcourir le tableau des créatures
	for _, creature in ipairs(creatureTable) do
		-- Assigner le nom de la créature au FontString
		tempFontString:SetText(creature["NomCreature"])

		-- Obtenir la largeur en pixels du nom et comparer avec la largeur maximale actuelle
		local nameWidth = tempFontString:GetStringWidth()
		if nameWidth > maxWidth then
			maxWidth = nameWidth
		end
	end

	-- Retourner la largeur maximale
	return maxWidth
end

function PhaseToolkit.GetMaxStringWidth(stringTable)
	-- Créer un objet FontString temporaire pour mesurer les tailles de texte
	local tempFontString = UIParent:CreateFontString(nil, "OVERLAY", "GameFontNormal")

	-- Variable pour stocker la largeur maximale trouvée
	local maxWidth = 0

	-- Parcourir le tableau de strings
	for _, str in ipairs(stringTable) do
		-- Assigner le texte au FontString
		tempFontString:SetText(str)

		-- Obtenir la largeur en pixels du string et comparer avec la largeur maximale actuelle
		local stringWidth = tempFontString:GetStringWidth()
		if stringWidth > maxWidth then
			maxWidth = stringWidth
		end
	end

	-- Retourner la largeur maximale
	return maxWidth
end

function PhaseToolkit.RemoveDuplicates(creatureList)
	local uniqueCreatures = {}
	local seenIds = {}

	for _, creature in ipairs(creatureList) do
		if not seenIds[creature.IdCreature] then
			-- Ajoute la créature à la nouvelle liste si son ID n'a pas encore été vue
			table.insert(uniqueCreatures, creature)
			seenIds[creature.IdCreature] = true -- Marque l'ID comme déjà vue
		end
	end

	return uniqueCreatures
end

function PhaseToolkit.ShowTooltip(self, tooltip)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT") -- Positionne le tooltip à droite du bouton
	GameTooltip:SetText(tooltip, 1, 1, 1, 1, true)   -- Définit le texte du tooltip
	GameTooltip:Show()                      -- Affiche le tooltip
end

function PhaseToolkit.DisableComponent(self)
	self:SetAlpha(0.5);
	self:EnableMouse(false);
end

function PhaseToolkit.EnableCompoment(self)
	self:SetAlpha(1);
	self:EnableMouse(true);
end

function PhaseToolkit.HideTooltip()
	GameTooltip:Hide() -- Cache le tooltip
end

local function genericTooltipOnEnter(self)
	PhaseToolkit.ShowTooltip(self, PhaseToolkit.CurrentLang[self.tooltipText] or self.tooltipText)
end

function PhaseToolkit.RegisterTooltip(frame, tooltip)
	frame.tooltipText = tooltip
	frame:HookScript("OnEnter", genericTooltipOnEnter)
	frame:HookScript("OnLeave", PhaseToolkit.HideTooltip)
end

function PhaseToolkit.RemoveStringFromTable(t, strToRemove)
	for i = #t, 1, -1 do -- Parcours la table en sens inverse
		if t[i] == strToRemove then
			table.remove(t, i)
		end
	end
end

function PhaseToolkit.RemoveCreatureById(creatureList, creatureId)
	for i = #creatureList, 1, -1 do
		if creatureList[i]["IdCreature"] == creatureId then
			table.remove(creatureList, i)
			break -- On peut sortir de la boucle après suppression car l'ID est unique
		end
	end
end

function PhaseToolkit.RandomiseNpc()
	for attribute, value in pairs(PhaseToolkit.InfoCustom[PhaseToolkit.GetRaceNameByID(PhaseToolkit.SelectedRace)][PhaseToolkit.SelectedGender]) do
		local randomValue = math.random(1, value)
		PhaseToolkit.GeneralStat[attribute] = randomValue
		sendAddonCmd("phase forge npc outfit custom " .. attribute .. " " .. randomValue, nil)
	end
	if (PhaseToolkit.CustomFrame ~= nil) then
		if PhaseToolkit.CustomFrame:IsShown() then
			PhaseToolkit.CustomFrame:Hide()
			PhaseToolkit.CustomFrame = nil
			PhaseToolkit.CreateCustomFrame()
			PhaseToolkit.CreateCustomGrid(PhaseToolkit.InfoCustom[PhaseToolkit.GetRaceNameByID(PhaseToolkit.SelectedRace)][PhaseToolkit.SelectedGender])
			PhaseToolkit.CustomFrame:Show()
		end
	end
end

function PhaseToolkit.IsTableEmpty(t)
	return next(t) == nil
end

function PhaseToolkit.UserHasPermission()
	return C_Epsilon.IsOfficer() or C_Epsilon.IsOwner()
end



-- ============================== FONCTIONS ² ============================== --

function PhaseToolkit.ShowRaceDropDown(DropDown)
	local function OnClick(self)
		UIDropDownMenu_SetSelectedValue(DropDown, self.value)
		PhaseToolkit.SelectedRace = self.value
		PhaseToolkit.ChangeNpcRace(self.value)
		PhaseToolkit.SelectRaceFrame()
	end

	local racesList = {}
	for name, value in pairs(PhaseToolkit.Races) do
		table.insert(racesList, { name = name, value = value })
	end

	table.sort(racesList, function(a, b) return a.value < b.value end)

	UIDropDownMenu_Initialize(DropDown, function()
		for _, race in ipairs(racesList) do
			local info = UIDropDownMenu_CreateInfo()
			info.text = PhaseToolkit.CurrentLang[race.name]
			info.value = race.value

			info.func = OnClick
			UIDropDownMenu_AddButton(info)
		end
	end)


	UIDropDownMenu_SetWidth(DropDown, 120)
	UIDropDownMenu_SetButtonWidth(DropDown, 124)
	if PhaseToolkit.SelectedNpcInfo ~= nil then
		UIDropDownMenu_SetSelectedValue(DropDown, PhaseToolkit.Races[PhaseToolkit.SelectedNpcInfo.race])
	else
		UIDropDownMenu_SetSelectedValue(DropDown, 1)
	end
end

function PhaseToolkit.ShowGenderDropDown(DropDown)
	local function OnClick(self)
		UIDropDownMenu_SetSelectedValue(DropDown, self.value)
		PhaseToolkit.SelectedGender = self.value
		PhaseToolkit.ChangeNpcGender(self.value)
		PhaseToolkit.SelectRaceFrame()
	end

	UIDropDownMenu_Initialize(DropDown, function()
		for i = 1, #PhaseToolkit.Genre do
			local info = UIDropDownMenu_CreateInfo()

			if not PhaseToolkit.ModeFR then
				info.text = PhaseToolkit.CurrentLang[PhaseToolkit.Genre[i]]
			else
				info.text = PhaseToolkit.Genre[i]
			end

			info.value = PhaseToolkit.Genre[i]
			info.func = OnClick
			UIDropDownMenu_AddButton(info)
		end
	end)

	UIDropDownMenu_SetWidth(DropDown, 120)
	UIDropDownMenu_SetButtonWidth(DropDown, 124)

	if PhaseToolkit.SelectedNpcInfo ~= nil then
		UIDropDownMenu_SetSelectedValue(DropDown, PhaseToolkit.SelectedNpcInfo.sexe)
	else
		UIDropDownMenu_SetSelectedValue(DropDown, "male")
	end
end

function PhaseToolkit.ResizeAdditionalButtonFrame()
	if (not PhaseToolkit.ModeFR) then
		PhaseToolkit.AdditionalButtonFrame:SetSize(145, 65)
		PhaseToolkit.AdditionalButtonFrame:SetPoint("BOTTOMLEFT", PhaseToolkit.LangageTogMainFrame, "TOPLEFT", -5, 0)
	else
		PhaseToolkit.AdditionalButtonFrame:SetSize(135, 65)
		PhaseToolkit.AdditionalButtonFrame:SetPoint("BOTTOMLEFT", PhaseToolkit.LangageTogMainFrame, "TOPLEFT", 0, 0)
	end

	PhaseOptionLabel:SetText(PhaseToolkit.CurrentLang["Phase Option"] or "Phase Options")
end

local function getItemInfoFromHyperlink(link)
	local strippedItemLink, itemID = link:match("|Hitem:((%d+).-)|h");
	if itemID then
		return tonumber(itemID), strippedItemLink;
	end
end

function PhaseToolkit.TranslateWeatherIntensity()
	if (GlobalNPCCUSTOMISER_SliderFrame ~= nil) then
		_G[GlobalNPCCUSTOMISER_SliderFrame:GetName() .. 'Low']:SetText(PhaseToolkit.IntensiteMeteoMin)
		_G[GlobalNPCCUSTOMISER_SliderFrame:GetName() .. 'High']:SetText(IntensiteMeteoMax)
		_G[GlobalNPCCUSTOMISER_SliderFrame:GetName() .. 'Text']:SetText(PhaseToolkit.CurrentLang['Intensity'] or 'Intensity')
	end
end

function PhaseToolkit.ShowMeteoDropDown(DropDown)
	local function OnClick(self)
		UIDropDownMenu_SetSelectedValue(DropDown, self.value)
		PhaseToolkit.SelectedMeteo = self.value
		PhaseToolkit.ChangePhaseWeather()
	end

	UIDropDownMenu_Initialize(DropDown, function()
		for _, meteo in ipairs(PhaseToolkit.Meteo) do
			local info = UIDropDownMenu_CreateInfo()

			if not PhaseToolkit.ModeFR then
				info.text = PhaseToolkit.CurrentLang[meteo.text]
			else
				info.text = meteo.text
			end

			info.value = meteo.value
			info.func = OnClick
			UIDropDownMenu_AddButton(info)
		end
	end)

	UIDropDownMenu_SetWidth(DropDown, 120)
	UIDropDownMenu_SetButtonWidth(DropDown, 124)

	if not PhaseToolkit.ModeFR then
		UIDropDownMenu_SetSelectedValue(DropDown, PhaseToolkit.SelectedMeteo)
	else
		UIDropDownMenu_SetSelectedValue(DropDown, PhaseToolkit.SelectedMeteo)
	end
end

function PhaseToolkit.ShowToggleDropDown(DropDown)
	UIDropDownMenu_Initialize(DropDown, function(self)
		local info = UIDropDownMenu_CreateInfo()

		for i = 1, #PhaseToolkit.Toggleslist do
			info.text = PhaseToolkit.CurrentLang[PhaseToolkit.Toggleslist[i][1]]
			info.value = PhaseToolkit.Toggleslist[i][1]
			info.func = function(self)
				PhaseToolkit.Toggleslist[i][2] = not PhaseToolkit.Toggleslist[i][2]
				if PhaseToolkit.Toggleslist[i][2] == true then
					PhaseToolkit.Toggleslist_checked[i] = 1;
				else
					PhaseToolkit.Toggleslist_checked[i] = 0;
				end
				sendAddonCmd('phase toggle ' .. self.value, nil)
			end

			local check = false;

			if PhaseToolkit.Toggleslist_checked[i] and PhaseToolkit.Toggleslist_checked[i] > 0 then
				check = true;
			end

			info.keepShownOnClick = true
			info.checked = check;
			UIDropDownMenu_AddButton(info)
		end
	end);

	UIDropDownMenu_SetWidth(DropDown, 120)
	UIDropDownMenu_SetText(DropDown, "Toggles");
end


-- ============================== FRAME PRINCIPALE ============================== --
PhaseToolkit.NombreDeLigne = math.ceil(((PhaseToolkit.CountElements(PhaseToolkit.InfoCustom[PhaseToolkit.GetRaceNameByID(PhaseToolkit.SelectedRace)][PhaseToolkit.SelectedGender]) / 3)))
PhaseToolkit.HauteurDispoCustomFrame = ((PhaseToolkit.NombreDeLigne - 1) * 65)
PhaseToolkit.NPCCustomiserMainFrame = CreateFrame("Frame", "NPCCustomiserMainFrame", UIParent, "PortraitFrameTemplate")
ButtonFrameTemplateMinimizable_HidePortrait(PhaseToolkit.NPCCustomiserMainFrame)
NineSliceUtil.ApplyLayoutByName(PhaseToolkit.NPCCustomiserMainFrame.NineSlice, "EpsilonGoldBorderFrameTemplateNoPortrait")
EpsilonLib.Utils.NineSlice.CropNineSliceCorners(PhaseToolkit.NPCCustomiserMainFrame.NineSlice, 0.8, true)
EpsilonLib.Utils.NineSlice.CropNineSliceCorners(PhaseToolkit.NPCCustomiserMainFrame.NineSlice, 0.4)
EpsilonLib.Utils.NineSlice.SetBackgroundAsViewport(PhaseToolkit.NPCCustomiserMainFrame, PhaseToolkit.NPCCustomiserMainFrame.Bg)
PhaseToolkit.NPCCustomiserMainFrame.Bg:SetAlpha(0.975)
PhaseToolkit.NPCCustomiserMainFrame:SetToplevel(true)

PhaseToolkit.NPCCustomiserMainFrame:SetSize(PhaseToolkit.LargeurMax, PhaseToolkit.HauteurMax)
PhaseToolkit.NPCCustomiserMainFrame:SetPoint("CENTER")
PhaseToolkit.NPCCustomiserMainFrame:SetMovable(true)
PhaseToolkit.NPCCustomiserMainFrame:EnableMouse(true)
PhaseToolkit.NPCCustomiserMainFrame:RegisterForDrag("LeftButton")
PhaseToolkit.NPCCustomiserMainFrame:SetScript("OnDragStart", PhaseToolkit.NPCCustomiserMainFrame.StartMoving)
PhaseToolkit.NPCCustomiserMainFrame:SetScript("OnDragStop", PhaseToolkit.NPCCustomiserMainFrame.StopMovingOrSizing)
PhaseToolkit.NPCCustomiserMainFrame:SetClampedToScreen(true)
PhaseToolkit.NPCCustomiserMainFrame:Hide()

PhaseToolkit.NPCCustomMainFrameSettingsButton = CreateFrame("BUTTON", nil, PhaseToolkit.NPCCustomiserMainFrame, "IconButtonTemplate")
PhaseToolkit.NPCCustomMainFrameSettingsButton:SetSize(16, 16)
PhaseToolkit.NPCCustomMainFrameSettingsButton:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight")
PhaseToolkit.NPCCustomMainFrameSettingsButton.Icon = PhaseToolkit.NPCCustomMainFrameSettingsButton:CreateTexture(nil, "OVERLAY")
PhaseToolkit.NPCCustomMainFrameSettingsButton.Icon:SetPoint("CENTER", -1, 0)
PhaseToolkit.NPCCustomMainFrameSettingsButton.Icon:SetSize(PhaseToolkit.NPCCustomMainFrameSettingsButton:GetSize())
PhaseToolkit.NPCCustomMainFrameSettingsButton.Icon:SetTexture("interface/buttons/ui-optionsbutton")
PhaseToolkit.NPCCustomMainFrameSettingsButton:SetPoint("RIGHT", PhaseToolkit.NPCCustomiserMainFrame.CloseButton, "LEFT", 2, 0)
PhaseToolkit.NPCCustomMainFrameSettingsButton:SetScript("OnClick", function()
	-- Needs to be called twice because of a bug in Blizzard's frame - the first call will initialize the frame if it's not initialized
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	InterfaceOptionsFrame_OpenToCategory("PhaseToolkitConfig")
	InterfaceOptionsFrame_OpenToCategory("PhaseToolkitConfig")
end)

do
	local f = PhaseToolkit.NPCCustomiserMainFrame
	local titleBgColor = f:CreateTexture(nil, "BACKGROUND")
	local color = CreateColorFromHexString("80FF7100")
	titleBgColor:SetPoint("TOPLEFT", f.TitleBg)
	titleBgColor:SetPoint("BOTTOMRIGHT", f.TitleBg, -0, 0)
	titleBgColor:SetColorTexture(color:GetRGBA())
	f.TitleBgColor = titleBgColor
	local r,g,b = color:GetRGB()
	f.TitleBg:SetVertexColor(r,g,b, 1)

	f.TitleText:SetText("Phase Toolkit")
	f.TitleText:SetPoint("LEFT", 15, 0) -- Fix title text position with no portrait
end

--[[
PhaseToolkit.NPCCustomMainFrameTitle = PhaseToolkit.NPCCustomiserMainFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
PhaseToolkit.NPCCustomMainFrameTitle:SetPoint("TOPLEFT", PhaseToolkit.NPCCustomiserMainFrame, "TOPLEFT", 10, -5)
PhaseToolkit.NPCCustomMainFrameTitle:SetText("Phase Toolkit")
--]]

PhaseToolkit.NPCCustomiserMainFrame:RegisterEvent("ADDON_LOADED")

---Sends a command by the standard chat message instead of the addon command system, allowing it to split into chunks like UCM if multi-line.
---@param message string
local function sendMessageInChunks(message)
    local maxLength = 254  -- Max bytes per message chunk
    local messageLength = #message  -- Get the length of the message in bytes

    -- If message length is less than or equal to maxLength, send it as is
    if messageLength <= maxLength then
        SendChatMessage("." .. message, "GUILD")
        return
    end

    -- Split the message into chunks of maxLength bytes
    for i = 1, messageLength, maxLength do
        local chunk = string.sub(message, i, i + maxLength - 1)
        SendChatMessage((i==1 and "." or "") .. chunk:trim(), "GUILD") -- Send chunks, adding . to first one
    end
end



function PhaseToolkit.recreateFrameModule()
	if (PhaseToolkit.moduleForPhaseAccessFrame ~= nil) then
		PhaseToolkit.moduleForPhaseAccessFrame:Hide()
		PhaseToolkit.moduleForPhaseAccessFrame = nil
	end
	PhaseToolkit.createPhaseAccessFrame()
	if (PhaseToolkit.moduleForMetteoSettingsFrame ~= nil) then PhaseToolkit.moduleForMetteoSettingsFrame:Hide() end
	PhaseToolkit.createMeteoSettingsFrame()
	if (PhaseToolkit.moduleForTimeSliderFrame ~= nil) then PhaseToolkit.moduleForTimeSliderFrame:Hide() end
	PhaseToolkit.createTimeSettingsFrame()
	if (PhaseToolkit.moduleForSetStartingFrame ~= nil) then PhaseToolkit.moduleForSetStartingFrame:Hide() end
	PhaseToolkit.createSetStartingFrame()
	if (PhaseToolkit.moduleForTogglesFrame ~= nil) then PhaseToolkit.moduleForTogglesFrame:Hide() end
	PhaseToolkit.createTogglesFrame()
	if (PhaseToolkit.moduleForPhaseSetNameFrame ~= nil) then PhaseToolkit.moduleForPhaseSetNameFrame:Hide() end
	PhaseToolkit.createPhaseSetNameFrame()
	if (PhaseToolkit.moduleForPhaseSetDescriptionFrame ~= nil) then PhaseToolkit.moduleForPhaseSetDescriptionFrame:Hide() end
	PhaseToolkit.createPhaseSetDescriptionFrame()
	if (PhaseToolkit.moduleforMotdFrame ~= nil) then PhaseToolkit.moduleforMotdFrame:Hide() end
	PhaseToolkit.createMotdFrame()
end

function PhaseToolkit.switchOpenCustomGridButton(button)
	if (PhaseToolkit.showCustomButton.currentIcon == "450905") then
		PhaseToolkit.showCustomButton.icon:SetTexture("Interface\\Icons\\misc_arrowlup")
		PhaseToolkit.showCustomButton.icon:SetAllPoints()
		PhaseToolkit.showCustomButton.currentIcon = "450907"
		if (PhaseToolkit.CustomFrame ~= nil) then
			PhaseToolkit.ToggleCustomFrame(PhaseToolkit.GetRaceNameByID(PhaseToolkit.SelectedRace))
		else
			PhaseToolkit.CreateCustomFrame()
			PhaseToolkit.ToggleCustomFrame(PhaseToolkit.GetRaceNameByID(PhaseToolkit.SelectedRace))
		end
	else
		PhaseToolkit.showCustomButton.icon:SetTexture("Interface\\Icons\\misc_arrowdown")
		PhaseToolkit.showCustomButton.icon:SetAllPoints()
		PhaseToolkit.showCustomButton.currentIcon = "450905"
		PhaseToolkit.CustomFrame:Hide()
		PhaseToolkit.CustomFrame = nil
	end
end

function PhaseToolkit.createCustomParamFrame()
	if (PhaseToolkit.PhaseOptionFrame ~= nil) then
		if (PhaseToolkit.PhaseOptionFrame:IsShown()) then
			PhaseToolkit.PhaseOptionFrame:Hide()
			PhaseToolkit.PhaseOptionFrame = nil
		end
	end
	if (PhaseToolkit.TELEFrame ~= nil) then
		if PhaseToolkit.TELEFrame:IsShown() then
			PhaseToolkit.TELEFrame:Hide()
		end
	end
	if (PhaseToolkit.PNJFrame ~= nil) then
		if (PhaseToolkit.PNJFrame:IsShown()) then
			PhaseToolkit.PNJFrame:Hide()
		end
	end
	if (PhaseToolkit.CustomMainFrame ~= nil) then
		if (PhaseToolkit.CustomMainFrame:IsShown()) then
			PhaseToolkit.CustomMainFrame:Hide()
			PhaseToolkit.CustomMainFrame = nil
		else
			PhaseToolkit.CustomMainFrame:Show()
		end
	else
		PhaseToolkit.CustomMainFrame = CreateFrame("Frame", nil, PhaseToolkit.NPCCustomiserMainFrame, "BackdropTemplate")
		PhaseToolkit.CustomMainFrame:SetBackdrop({
			bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
			edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
			edgeSize = 16,
			insets = { left = 5, right = 5, top = 5, bottom = 5 },
		})
		PhaseToolkit.CustomMainFrame:SetSize(160, 130)
		PhaseToolkit.CustomMainFrame:SetPoint("TOPLEFT", PhaseToolkit.NPCCustomiserMainFrame, "TOPRIGHT", 5, 0)


		PhaseToolkit.CustomMainFrame:SetScript("OnShow", function()
			if (PhaseToolkit.AutoRefreshNPC) then
				PhaseToolkit.CustomMainFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
			end
		end)

		PhaseToolkit.CustomMainFrame:SetScript("OnHide", function()
			PhaseToolkit.CustomMainFrame:UnregisterEvent("PLAYER_TARGET_CHANGED")
		end)

		PhaseToolkit.CustomMainFrame:SetScript("OnEvent", function(self, event)
			-- If we change target while Phase toolkit is opened, and it's a npc we take data
			if (event == "PLAYER_TARGET_CHANGED" and not UnitIsPlayer("target") and UnitExists("target")) then
				sendAddonCmd("npc info", PhaseToolkit.parseForDisplayId, false)
			end
		end)

		PhaseToolkit.RaceDropDown = CreateFrame("Frame", "RaceDropDown", PhaseToolkit.CustomMainFrame, "UIDropDownMenuTemplate")
		PhaseToolkit.RaceDropDown:SetSize(200, 30)
		PhaseToolkit.RaceDropDown:SetPoint("TOPLEFT", PhaseToolkit.CustomMainFrame, "TOPLEFT", -5, -5)

		PhaseToolkit.ShowRaceDropDown(PhaseToolkit.RaceDropDown)

		PhaseToolkit.GenreDropDown = CreateFrame("Frame", "GenreDropDown", PhaseToolkit.CustomMainFrame, "UIDropDownMenuTemplate")
		PhaseToolkit.GenreDropDown:SetSize(200, 30)
		PhaseToolkit.GenreDropDown:SetPoint("TOPLEFT", PhaseToolkit.RaceDropDown, "BOTTOMLEFT", 0, 5)

		PhaseToolkit.ShowGenderDropDown(PhaseToolkit.GenreDropDown)

		local autoUpdateNpcInfoCheckbox = CreateFrame("CheckButton", nil, PhaseToolkit.GenreDropDown, "InterfaceOptionsCheckButtonTemplate")
		autoUpdateNpcInfoCheckbox:SetPoint("TOPLEFT", PhaseToolkit.GenreDropDown, "BOTTOMLEFT", 15, 0)

		autoUpdateNpcInfoCheckbox.Text:SetText(PhaseToolkit.CurrentLang["auto update Npc"] or "Auto Update NPC")
		autoUpdateNpcInfoCheckbox.tooltipText = PhaseToolkit.CurrentLang["AutoRefreshNPCTooltip"] or "Automatically refresh race & gender to match the selected NPC when changing target"

		autoUpdateNpcInfoCheckbox:SetScript("OnClick", function(self)
			PhaseToolkit.AutoRefreshNPC = self:GetChecked()
			PhaseToolKitConfig["AutoRefreshNPC"] = PhaseToolkit.AutoRefreshNPC
			if (not PhaseToolkit.AutoRefreshNPC and PhaseToolkit.CustomMainFrame ~= nil) then
				PhaseToolkit.CustomMainFrame:UnregisterEvent("PLAYER_TARGET_CHANGED")
			end
			if (PhaseToolkit.AutoRefreshNPC and PhaseToolkit.CustomMainFrame ~= nil) then
				PhaseToolkit.CustomMainFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
			end
		end)

		autoUpdateNpcInfoCheckbox:SetChecked(false)


		PhaseToolkit.showCustomButton = CreateFrame("Button", nil, PhaseToolkit.CustomMainFrame, "UIPanelButtonTemplate")
		PhaseToolkit.showCustomButton:SetSize(25, 25)
		PhaseToolkit.showCustomButton:SetPoint("BOTTOMLEFT", PhaseToolkit.CustomMainFrame, "BOTTOMLEFT", 7.5, 7.5)
		PhaseToolkit.showCustomButton.icon = PhaseToolkit.showCustomButton:CreateTexture(nil, "OVERLAY")
		PhaseToolkit.showCustomButton.icon:SetTexture("Interface\\Icons\\misc_arrowdown")
		PhaseToolkit.showCustomButton.icon:SetAllPoints()
		PhaseToolkit.showCustomButton.currentIcon = "450905"
		PhaseToolkit.showCustomButton:SetScript("OnClick", PhaseToolkit.switchOpenCustomGridButton)
		PhaseToolkit.RegisterTooltip(PhaseToolkit.showCustomButton, "Show Custom Option")

		local AllRandomButton = CreateFrame("Button", nil, PhaseToolkit.CustomMainFrame, "UIPanelButtonTemplate")
		AllRandomButton:SetSize(25, 25)
		AllRandomButton:SetPoint("LEFT", PhaseToolkit.showCustomButton, "RIGHT", 5, 0)
		AllRandomButton.icon = AllRandomButton:CreateTexture(nil, "OVERLAY")
		AllRandomButton.icon:SetTexture("Interface\\Icons\\inv_misc_dice_01")
		AllRandomButton.icon:SetAllPoints()
		AllRandomButton:SetScript("OnClick", function()
			PhaseToolkit.RandomiseNpc()
		end)
		PhaseToolkit.RegisterTooltip(AllRandomButton, "Randomise customisations")


		local SetNpcName = CreateFrame("Button", nil, PhaseToolkit.CustomMainFrame, "UIPanelButtonTemplate")
		SetNpcName:SetSize(25, 25)
		SetNpcName:SetPoint("LEFT", AllRandomButton, "RIGHT", 5, 0)
		SetNpcName.icon = SetNpcName:CreateTexture(nil, "OVERLAY")
		SetNpcName.icon:SetTexture("Interface\\Icons\\inv_inscriptionlanathelquill")
		SetNpcName.icon:SetAllPoints()
		SetNpcName:SetScript("OnClick", function()
			PhaseToolkit.PromptForNPCName()
		end)
		PhaseToolkit.RegisterTooltip(SetNpcName, "Set NPC name")


		local SetNpcSubName = CreateFrame("Button", nil, PhaseToolkit.CustomMainFrame, "UIPanelButtonTemplate")
		SetNpcSubName:SetSize(25, 25)
		SetNpcSubName:SetPoint("LEFT", SetNpcName, "RIGHT", 5, 0)
		SetNpcSubName.icon = SetNpcSubName:CreateTexture(nil, "OVERLAY")
		SetNpcSubName.icon:SetTexture("Interface\\Icons\\inv_inscription_82_contract_ankoan")
		SetNpcSubName.icon:SetAllPoints()
		SetNpcSubName:SetScript("OnClick", function()
			PhaseToolkit.PromptForNPCSubName()
		end)
		PhaseToolkit.RegisterTooltip(SetNpcSubName, "Set NPC Subname")


		PhaseToolkit.CustomMainFrame:Hide()
		PhaseToolkit.CustomMainFrame:Show()
	end
end

function PhaseToolkit.ShowItemBondingDropdown(_dropdown)
	local function OnClick(self)
		UIDropDownMenu_SetSelectedValue(_dropdown, self.value)
		PhaseToolkit.itemCreatorData.bonding=self.value
		if(PhaseToolkit.itemCreatorData.itemLink~=nil) then
			local itemLink=" "..PhaseToolkit.itemCreatorData.itemLink.." "
			sendAddonCmd("forge item set bonding "..itemLink..self.value,nil,false)
		end
	end

	UIDropDownMenu_Initialize(_dropdown, function()
		for _, itemBonding in ipairs(PhaseToolkit.itemBonding) do
			local info = UIDropDownMenu_CreateInfo()
			info.text=itemBonding.name
			info.value = itemBonding.bondingId

			info.func = OnClick
			UIDropDownMenu_AddButton(info)
		end
	end)

	UIDropDownMenu_SetWidth(_dropdown, 120)
	UIDropDownMenu_SetButtonWidth(_dropdown, 124)
	UIDropDownMenu_SetSelectedValue(_dropdown,-1)

end

function PhaseToolkit.ShowItemQualityDropdown(_dropdown)
	local function OnClick(self)
		UIDropDownMenu_SetSelectedValue(_dropdown, self.value)
		PhaseToolkit.itemCreatorData.quality=self.value
		if(PhaseToolkit.itemCreatorData.itemLink~=nil) then
			local itemLink=" "..PhaseToolkit.itemCreatorData.itemLink.." "
			sendAddonCmd("forge item set quality "..itemLink..self.value,nil,false)
		end
	end

	UIDropDownMenu_Initialize(_dropdown, function()
		for _, quality in ipairs(PhaseToolkit.itemQuality) do
			local info = UIDropDownMenu_CreateInfo()

			info.text=quality.name
			info.value = quality.qualityId

			info.func = OnClick
			UIDropDownMenu_AddButton(info)
		end
	end)

	UIDropDownMenu_SetWidth(_dropdown, 120)
	UIDropDownMenu_SetButtonWidth(_dropdown, 124)
	UIDropDownMenu_SetSelectedValue(_dropdown,-1)
end

function PhaseToolkit.ShowItemSheathDropdown(_dropdown)
	local function OnClick(self)
		UIDropDownMenu_SetSelectedValue(_dropdown, self.value)
		PhaseToolkit.itemCreatorData.sheath=self.value
		if(PhaseToolkit.itemCreatorData.itemLink~=nil) then
			local itemLink=" "..PhaseToolkit.itemCreatorData.itemLink.." "
			sendAddonCmd("forge item set sheath "..itemLink..self.value,nil,false)
		end
	end

	UIDropDownMenu_Initialize(_dropdown, function()
		for _, sheath in ipairs(PhaseToolkit.itemSheath) do
			local info = UIDropDownMenu_CreateInfo()

			info.text=sheath.name
			info.value = sheath.sheathId

			info.func = OnClick
			UIDropDownMenu_AddButton(info)
		end
	end)

	UIDropDownMenu_SetWidth(_dropdown, 120)
	UIDropDownMenu_SetButtonWidth(_dropdown, 124)
	UIDropDownMenu_SetSelectedValue(_dropdown,-1)
end

function PhaseToolkit.ShowItemInventoryDropdown(_dropdown)
	local function OnClick(self)
		UIDropDownMenu_SetSelectedValue(_dropdown, self.value)
		PhaseToolkit.itemCreatorData.inventoryType=self.value

		if(PhaseToolkit.itemCreatorData.itemLink~=nil) then
			local itemLink=" "..PhaseToolkit.itemCreatorData.itemLink.." "
			sendAddonCmd("forge item set inventory "..itemLink..self.value,nil,false)
		end
	end

	UIDropDownMenu_Initialize(_dropdown, function()
		local tableau={}
		if(PhaseToolkit.itemCreatorData.itemClass==-1) then
			tableau=PhaseToolkit.itemInventoryType
		else
			tableau = filterInventoryTypeByClass(PhaseToolkit.itemCreatorData.itemClass)
		end

		for _, inventoryType in ipairs(tableau) do
			local info = UIDropDownMenu_CreateInfo()

			info.text=inventoryType.name
			info.value = inventoryType.inventoryTypeId

			info.func = OnClick
			UIDropDownMenu_AddButton(info)
		end
	end)

	UIDropDownMenu_SetWidth(_dropdown, 120)
	UIDropDownMenu_SetButtonWidth(_dropdown, 124)
	UIDropDownMenu_SetSelectedValue(_dropdown,-1)
end

function PhaseToolkit.ShowItemClassDropdown(_dropdown,_subDropdown)
	local function OnClick(self,realvalue,subClass)
		UIDropDownMenu_SetSelectedValue(_dropdown, self.value)
		PhaseToolkit.EnableCompoment(_subDropdown)
		PhaseToolkit.ShowItemSubClassDropdown(_subDropdown,subClass)
		PhaseToolkit.itemCreatorData.itemClass=realvalue
		-- For certain class we disable sheath and stackable itemcreator buttons
		--and we get rid of the inventoryType dropdown if we are not in those two option,cause yes.
		-- and why bother with giving a displayID cause It's not equippable
		if(PhaseToolkit.itemCreatorData.itemClass==2 or PhaseToolkit.itemCreatorData.itemClass==4) then
			PhaseToolkit.DisableComponent(PhaseToolkit.itemCreatorCheckboxStackable)
			UIDropDownMenu_EnableDropDown(PhaseToolkit.ItemInventoryTypeDropdown)
			PhaseToolkit.EnableCompoment(PhaseToolkit.itemdisplayIdEditBox)

		else
			PhaseToolkit.EnableCompoment(PhaseToolkit.itemCreatorCheckboxStackable)
			UIDropDownMenu_DisableDropDown(PhaseToolkit.ItemInventoryTypeDropdown)
			PhaseToolkit.DisableComponent(PhaseToolkit.itemdisplayIdEditBox)
		end
		-- if we reset to default data ,wich would be ignorer but hey..you know why im doing this è_é
		if(PhaseToolkit.itemCreatorData.itemClass==-1) then
			UIDropDownMenu_DisableDropDown(_subDropdown)
		else
			UIDropDownMenu_EnableDropDown(_subDropdown)
		end
		-- in case we are not making a weapon, we don't care about sheath,so now it's gone :)
		if(PhaseToolkit.itemCreatorData.itemClass~=2) then
			UIDropDownMenu_DisableDropDown(PhaseToolkit.ItemSheathDropdown)
		else
			UIDropDownMenu_EnableDropDown(PhaseToolkit.ItemSheathDropdown)
		end
		-- if we have a link already,we send the command right away cause..Mindscape asked nicely
		if(PhaseToolkit.itemCreatorData.itemLink~=nil and PhaseToolkit.itemCreatorData.itemClass~=-1) then
			local itemLink=" "..PhaseToolkit.itemCreatorData.itemLink.." "
			sendAddonCmd("forge item set class "..itemLink..PhaseToolkit.itemCreatorData.itemClass,nil,false)
		end
	end

	UIDropDownMenu_Initialize(_dropdown, function()
		for _, itemClass in ipairs(PhaseToolkit.itemClass) do
			local info = UIDropDownMenu_CreateInfo()

			info.text=itemClass.name
			info.value = itemClass.classId

			info.func = function(self)OnClick(self,info.value,itemClass.subclass) end
			UIDropDownMenu_AddButton(info)
		end
	end)

	UIDropDownMenu_SetWidth(_dropdown, 120)
	UIDropDownMenu_SetButtonWidth(_dropdown, 124)
	UIDropDownMenu_SetSelectedValue(_dropdown,-1)
end

function PhaseToolkit.ShowItemSubClassDropdown(_subclass,subclass)
	local function OnClick(self,realvalue)
		UIDropDownMenu_SetSelectedValue(_subclass, self.value)
		PhaseToolkit.itemCreatorData.itemSubClass=realvalue
		if(PhaseToolkit.itemCreatorData.itemLink~=nil and PhaseToolkit.itemCreatorData.itemSubClass~=-1) then
			local itemLink=" "..PhaseToolkit.itemCreatorData.itemLink.." "
			sendAddonCmd("forge item set subclass "..itemLink..PhaseToolkit.itemCreatorData.itemSubClass,nil,false)
		end
	end

	UIDropDownMenu_Initialize(_subclass, function()
		for _, subclass in ipairs(subclass) do
			local info = UIDropDownMenu_CreateInfo()

			info.text=subclass.name
			info.value = subclass.subclassId

			info.func =  function(self) OnClick(self,info.value) end
			UIDropDownMenu_AddButton(info)
		end
	end)

	UIDropDownMenu_SetWidth(_subclass, 120)
	UIDropDownMenu_SetButtonWidth(_subclass, 124)
	UIDropDownMenu_SetSelectedValue(_subclass,0)
end

local function updateBagContents()
    local currentItems = {}
    for bagID = 0, NUM_BAG_SLOTS do
        for slot = 1, GetContainerNumSlots(bagID) do
            local itemID = GetContainerItemID(bagID, slot)
            if itemID then
                table.insert(currentItems, itemID)
            end
        end
    end
    return currentItems
end

local function resetItemCreatorData()
	for key in pairs(PhaseToolkit.itemCreatorData) do
		PhaseToolkit.itemCreatorData[key] = nil
	end
end

local function resetForgeUI()
	local editboxes = {
		"itemIdField", "nameInputBox", "DescriptionInputBox", "itemdisplayIdEditBox", "iconIdEditBox",
	}
	for _, box in ipairs(editboxes) do
		box = PhaseToolkit[box]
		box:SetText("")
	end


	do
		-- Item Class
		local classObj=getClassByClassID(-1)
		UIDropDownMenu_SetSelectedValue(PhaseToolkit.ItemClassDropdown,classObj.classId)
		UIDropDownMenu_SetText(PhaseToolkit.ItemClassDropdown,classObj.name)

		-- Subclass
		UIDropDownMenu_SetSelectedValue(PhaseToolkit.ItemSubClassDropdown,0)
		UIDropDownMenu_SetText(PhaseToolkit.ItemSubClassDropdown,"")
		UIDropDownMenu_DisableDropDown(PhaseToolkit.ItemSubClassDropdown)

		-- Inv Type
		local position =getInventoryTypePosition("Inventory type");
		if(position~=nil) then
			UIDropDownMenu_SetSelectedValue(PhaseToolkit.ItemInventoryTypeDropdown,position)
			UIDropDownMenu_SetText(PhaseToolkit.ItemInventoryTypeDropdown,"Inventory type")
			UIDropDownMenu_DisableDropDown(PhaseToolkit.ItemInventoryTypeDropdown)
		end

		-- Quality
		local quality = getQualityObject(-1)
		if(quality~=nil) then
			UIDropDownMenu_SetSelectedValue(PhaseToolkit.ItemQualityDropdown,quality.qualityId)
			UIDropDownMenu_SetText(PhaseToolkit.ItemQualityDropdown,quality.name)
		end

		-- Binding
		local binding = getBindingObject(-1)
		if(binding~=nil) then
			UIDropDownMenu_SetSelectedValue(PhaseToolkit.ItemBondingDropdown,binding.bondingId)
			UIDropDownMenu_SetText(PhaseToolkit.ItemBondingDropdown,binding.name)
		end

		-- Sheath
		UIDropDownMenu_SetSelectedValue(PhaseToolkit.ItemSheathDropdown,-1)
		UIDropDownMenu_SetText(PhaseToolkit.ItemSheathDropdown,"Sheath")
		UIDropDownMenu_DisableDropDown(PhaseToolkit.ItemSheathDropdown)

		-- Adder
		UIDropDownMenu_SetSelectedValue(PhaseToolkit.adderOptionDropdown,-1)
		UIDropDownMenu_SetText(PhaseToolkit.adderOptionDropdown,"Adder")

		-- Additem
		UIDropDownMenu_SetSelectedValue(PhaseToolkit.addItemOptionDropdownButton,-1)
		UIDropDownMenu_SetText(PhaseToolkit.addItemOptionDropdownButton,"Additem")

		-- Copy
		UIDropDownMenu_SetSelectedValue(PhaseToolkit.copyOptionDropdown,-1)
		UIDropDownMenu_SetText(PhaseToolkit.copyOptionDropdown,"Copy")

		-- Copy
		UIDropDownMenu_SetSelectedValue(PhaseToolkit.creatorOptionDropdown,-1)
		UIDropDownMenu_SetText(PhaseToolkit.creatorOptionDropdown,"Creator")

		-- Info
		UIDropDownMenu_SetSelectedValue(PhaseToolkit.infoOptionDropdown,-1)
		UIDropDownMenu_SetText(PhaseToolkit.infoOptionDropdown,"Info")

		-- Lookup
		UIDropDownMenu_SetSelectedValue(PhaseToolkit.lookupOptionDropdown,-1)
		UIDropDownMenu_SetText(PhaseToolkit.lookupOptionDropdown,"Lookup")
	end

end

local function resetForge()
	resetItemCreatorData()
	resetForgeUI()
end

-- Function to forge the item with all the data needed
function PhaseToolkit.BLOODFORTHEITEMFORGEGOD()
	local itemLink=" "..PhaseToolkit.itemCreatorData.itemLink.." "
	C_Timer.After(0.5, function()
		if(PhaseToolkit.itemCreatorData.itemName~=nil) then
			sendAddonCmd("forge item set name "..itemLink..PhaseToolkit.itemCreatorData.itemName,nil,false)
		end
	 end)

	C_Timer.After(0.5, function()
		if(PhaseToolkit.itemCreatorData.itemDescription~=nil) then
			local maxDescriptionSize=240-(string.len("f i s de ")+string.len(itemLink))
			if(string.len(PhaseToolkit.itemCreatorData.itemDescription)>maxDescriptionSize) then
				sendMessageInChunks("f i s de "..itemLink..PhaseToolkit.itemCreatorData.itemDescription)
			else
				sendAddonCmd("f i s de "..itemLink..PhaseToolkit.itemCreatorData.itemDescription,nil,false)
			end
		end
	end)
	C_Timer.After(0.5, function()
		if(PhaseToolkit.itemCreatorData.itemClass~=nil and PhaseToolkit.itemCreatorData.itemClass~=-1) then
			sendAddonCmd("forge item set class "..itemLink..PhaseToolkit.itemCreatorData.itemClass,nil,false)
		end
	end)
	C_Timer.After(0.5, function()
		if(PhaseToolkit.itemCreatorData.itemSubClass~=nil and PhaseToolkit.itemCreatorData.itemSubClass~=-1) then
			sendAddonCmd("forge item set subclass "..itemLink..PhaseToolkit.itemCreatorData.itemSubClass,nil,false)
		end
	end)
	C_Timer.After(0.5, function()
		if(PhaseToolkit.itemCreatorData.inventoryType~=nil and PhaseToolkit.itemCreatorData.inventoryType~=-1) then
			sendAddonCmd("forge item set inventorytype "..itemLink..PhaseToolkit.itemCreatorData.inventoryType,nil,false)
		end
	end)
	C_Timer.After(0.6, function()
		if(PhaseToolkit.itemCreatorData.itemDisplayLink~=nil and PhaseToolkit.itemCreatorData.itemDisplayLink~=-1) then
			sendAddonCmd("forge item set display "..itemLink..PhaseToolkit.itemCreatorData.itemDisplayLink,nil,false)
		end
	end)
	C_Timer.After(0.7, function()
		if(PhaseToolkit.itemCreatorData.bonding~=nil and PhaseToolkit.itemCreatorData.bonding~=-1) then
			sendAddonCmd("forge item set bonding "..itemLink..PhaseToolkit.itemCreatorData.bonding,nil,false)
		end
	end)
	C_Timer.After(0.8, function()
		if(PhaseToolkit.itemCreatorData.quality~=nil and PhaseToolkit.itemCreatorData.quality~=-1) then
			sendAddonCmd("forge item set quality "..itemLink..PhaseToolkit.itemCreatorData.quality,nil,false)
		end
	end)
	C_Timer.After(0.9, function()
		if(PhaseToolkit.itemCreatorData.sheath~=nil and PhaseToolkit.itemCreatorData.sheath~=-1) then
			sendAddonCmd("forge item set sheath "..itemLink..PhaseToolkit.itemCreatorData.sheath,nil,false)
		end
	end)
	C_Timer.After(1, function()
		if(PhaseToolkit.itemCreatorData.itemIconIdOrLink~=nil and PhaseToolkit.itemCreatorData.itemIconIdOrLink~=-1) then
			sendAddonCmd("forge item set icon "..itemLink..PhaseToolkit.itemCreatorData.itemIconIdOrLink,nil,false)
		end
	end)
	C_Timer.After(1.1, function()
		if(PhaseToolkit.itemCreatorData.stackable~=nil and PhaseToolkit.itemCreatorData.stackable~=-1) then
			local value=1
			if(PhaseToolkit.itemCreatorData.stackable==true) then
				if( PhaseToolkit.itemCreatorData.stackablecount and PhaseToolkit.itemCreatorData.stackablecount>0) then
					value=PhaseToolkit.itemCreatorData.stackablecount
				end
			end
			sendAddonCmd("forge item set stackable "..itemLink..value,nil,false)
		end
	end)
	C_Timer.After(1.2, function()
		if(PhaseToolkit.itemCreatorData.adder~=nil and PhaseToolkit.itemCreatorData.adder~=-1) then
			sendAddonCmd("forge item set property adder"..itemLink..PhaseToolkit.itemCreatorData.adder,nil,false)
		end
	end)
	if(PhaseToolkit.additemOption~=nil) then
		for _,option in ipairs(PhaseToolkit.additemOption) do
			local value=""
			if option.value==false then  value="off" else value="on" end
			C_Timer.After(0.2, function()
				sendAddonCmd("forge item set property additem "..option.text..itemLink..value,nil,false)
			end)
		end
	end
	C_Timer.After(0.2, function()
		if(PhaseToolkit.itemCreatorData.copy~=nil and PhaseToolkit.itemCreatorData.copy~=-1) then
			sendAddonCmd("forge item set property copy"..itemLink..PhaseToolkit.itemCreatorData.copy,nil,false)
		end
	end)
	C_Timer.After(0.2, function()
		if(PhaseToolkit.itemCreatorData.creator~=nil and PhaseToolkit.itemCreatorData.creator~=-1) then
			sendAddonCmd("forge item set property creator"..itemLink..PhaseToolkit.itemCreatorData.creator,nil,false)
		end
	end)
	C_Timer.After(0.2, function()
		if(PhaseToolkit.itemCreatorData.info~=nil and PhaseToolkit.itemCreatorData.info~=-1) then
			sendAddonCmd("forge item set property info"..itemLink..PhaseToolkit.itemCreatorData.info,nil,false)
		end
	end)
	C_Timer.After(0.2, function()
		if(PhaseToolkit.itemCreatorData.lookup~=nil and PhaseToolkit.itemCreatorData.lookup~=-1) then
			sendAddonCmd("forge item set property lookup"..itemLink..PhaseToolkit.itemCreatorData.lookup,nil,false)
		end
	end)
	if(PhaseToolkit.itemCreatorData.whitelistedChar~=nil and #PhaseToolkit.itemCreatorData.whitelistedChar>0) then
		for  i=1 , #PhaseToolkit.itemCreatorData.whitelistedChar do
			C_Timer.After(0.2, function()
				sendAddonCmd("forge item set whitelist character add"..itemLink..PhaseToolkit.itemCreatorData.whitelistedChar[i],nil,false)
			end)
		end
	end
	if(PhaseToolkit.itemCreatorData.whitelistedPhaseForMember~=nil and #PhaseToolkit.itemCreatorData.whitelistedPhaseForMember>0) then
		for  i=1 , #PhaseToolkit.itemCreatorData.whitelistedPhaseForMember do

			C_Timer.After(0.2, function()
				sendAddonCmd("forge item set whitelist member add"..itemLink..PhaseToolkit.itemCreatorData.whitelistedPhaseForMember[i],nil,false)
			end)
		end
	end
	if(PhaseToolkit.itemCreatorData.whitelistedPhaseForOfficer~=nil and #PhaseToolkit.itemCreatorData.whitelistedPhaseForOfficer>0) then
		for  i=1 , #PhaseToolkit.itemCreatorData.whitelistedPhaseForOfficer do
			C_Timer.After(0.2, function()
				sendAddonCmd("forge item set whitelist officer add"..itemLink..PhaseToolkit.itemCreatorData.whitelistedPhaseForOfficer[i],nil,false)
			end)
		end
	end

	PhaseToolkit.itemCreatorData.itemLink=nil
	-- we reset everything now
	-- Need a delay  wtf was I thinking?
	C_Timer.After(1.5, function()
		for key in pairs(PhaseToolkit.itemCreatorData) do
			PhaseToolkit.itemCreatorData[key] = nil
		end
		print("Item Forging done !\nyou can use your item !")
		sendAddonCmd("forge item request"..itemLink) -- Just in case!
		ContainerFrame_UpdateAll()
	end)

end

function GetItemIDFromLink(itemLink)
    if not itemLink then return nil end
    -- Extrait l'ID de l'objet depuis le lien
    local itemID = itemLink:match("item:(%d+)")
    return  itemID
end

function PhaseToolkit.updateItemLink()
	C_Timer.After(0.2, function()
		local itemId=GetItemIDFromLink(PhaseToolkit.itemCreatorData.itemLink)
		local itemName, itemLink = GetItemInfo(itemId)
		PhaseToolkit.itemIdField:SetText(itemLink)
	end)
end



function PhaseToolkit.insertSpaces(inputString)
    local result = {}
    local length = #inputString

    for i = 1, length, 27 do
        table.insert(result, inputString:sub(i, i + 26)) -- Prend 27 caractères à chaque itération
    end

    return table.concat(result, " ") -- Combine les segments avec un espace
end

local function updateFields(itemLink)
	local itemId=GetItemIDFromLink(itemLink)
	local itemName, itemLink, itemQuality, itemLevel, itemMinLevel, itemType, itemSubType,
	itemStackCount, itemEquipLoc, itemTexture, sellPrice, classID, subclassID, bindType,
	expacID, setID, isCraftingReagent= GetItemInfo(itemId)

	local isBindingDetected=false
	local isWeaponDetected=false
	local inventoryTypeLabel=""
	local weapontype=""
	local description=""
	local content = {}
	local isApparenceCollectedtest=false
	local isDamagePerSecond=false


	local tooltipScanner = CreateFrame("GameTooltip", "TooltipScanner", nil, "GameTooltipTemplate")
	tooltipScanner:SetOwner(WorldFrame, "ANCHOR_NONE") -- On le rend invisible
	tooltipScanner:SetHyperlink("item:" .. itemId) -- Charge l'objet par son ID
	PhaseToolkit.ModifyItemData=false

    for i = 1, tooltipScanner:NumLines() do
        local leftText = _G["TooltipScannerTextLeft" .. i]
        local rightText = _G["TooltipScannerTextRight" .. i]

        -- Ajouter le texte de gauche
        if leftText and leftText:GetText() then
            table.insert(content, leftText:GetText())
        end

        -- Ajouter le texte de droite
        if rightText and rightText:GetText() then
            table.insert(content, rightText:GetText())
        end
    end

	--InventoryClass is primordial cause used after, and technically first in the workflow
	if(classID~=nil) then
		PhaseToolkit.itemCreatorData.itemClass=classID
		--now that we have this,we get the correct value and correct text
		local classObj=getClassByClassID(classID)
		if(classObj~=nil) then
			UIDropDownMenu_SetSelectedValue(PhaseToolkit.ItemClassDropdown,classObj.classId)
			UIDropDownMenu_SetText(PhaseToolkit.ItemClassDropdown,classObj.name)
			PhaseToolkit.ShowItemSubClassDropdown(PhaseToolkit.ItemSubClassDropdown,classObj.subclass)
			PhaseToolkit.EnableCompoment(PhaseToolkit.ItemSubClassDropdown)

			if(classObj.classId==2 or classObj.classId==4) then
				PhaseToolkit.DisableComponent(PhaseToolkit.itemCreatorCheckboxStackable)
			else
				PhaseToolkit.EnableCompoment(PhaseToolkit.itemCreatorCheckboxStackable)
			end
		end
	end
	if(content[3]~=nil) then
		if(string.find(string.lower(content[3]),"bind") or string.find(string.lower(content[3]),"quest")) then
			isBindingDetected=true
		end
	end
	if(content[4]~=nil) then
		if(string.find(string.lower(content[4]),"one") or string.find(string.lower(content[4]),"two")) then
			isWeaponDetected=true
		end
	end
	if(content[8]~=nil) then
		if(string.find(string.lower(content[8]),"appearance")) then
			isApparenceCollectedtest=true
		end
		if(string.find(string.lower(content[8]),"per second")) then
			isDamagePerSecond=true
		end
	end

	if(not isBindingDetected) then
		inventoryTypeLabel=content[3]
		weapontype=content[4]
	else
		inventoryTypeLabel=content[4]
		weapontype=content[4]
	end
	if(not isApparenceCollectedtest and not isDamagePerSecond) then
		description=content[8]
	else
		description=""
	end
	if(classID==4) then
		description=content[6]
	end

	-- IN CASE WE REAAAALLLY didn't find the description..we try it all.
	if(description==nil or description=="") then
		for key in pairs(content) do
			if(content[key]:find('"')) then
				description=content[key]
			end
		end
	end

	if(description~=nil and description~="") then
		description=description:match('^"(.*)"$') or description
		PhaseToolkit.DescriptionInputBox.ScrollFrame.EditBox:SetText(description)
	end

	--subclass thing
	if(weapontype~=nil and weapontype~="") then
		local weaponTypeObj=getWeaponTypeId(weapontype,inventoryTypeLabel)
		if(weaponTypeObj~=nil)then
			UIDropDownMenu_SetSelectedValue(PhaseToolkit.ItemSubClassDropdown,weaponTypeObj.subclassId)
			UIDropDownMenu_SetText(PhaseToolkit.ItemSubClassDropdown,weaponTypeObj.name)
		end
	end

	if(inventoryTypeLabel~=nil and inventoryTypeLabel~="") then
		if(string.lower(inventoryTypeLabel):find("one")~=nil) then
			inventoryTypeLabel="Weapon"
		end
		local position =getInventoryTypePosition(inventoryTypeLabel);
		if(position~=nil) then
			UIDropDownMenu_SetSelectedValue(PhaseToolkit.ItemInventoryTypeDropdown,position)
			UIDropDownMenu_SetText(PhaseToolkit.ItemInventoryTypeDropdown,inventoryTypeLabel)
		end
	end

	if(itemQuality~=nil and itemQuality~="") then
		local quality = getQualityObject(itemQuality)
		if(quality~=nil) then
			UIDropDownMenu_SetSelectedValue(PhaseToolkit.ItemQualityDropdown,quality.qualityId)
			UIDropDownMenu_SetText(PhaseToolkit.ItemQualityDropdown,quality.name)
		end
	end

	if(bindType~=nil and bindType~="") then
		local binding = getBindingObject(bindType)
		if(binding~=nil) then
			UIDropDownMenu_SetSelectedValue(PhaseToolkit.ItemBondingDropdown,binding.bondingId)
			UIDropDownMenu_SetText(PhaseToolkit.ItemBondingDropdown,binding.name)
		end
	end

	PhaseToolkit.nameInputBox:SetText(itemName)

	C_Timer.After(1, function()
		PhaseToolkit.ModifyItemData=true
	  end)

end

function PhaseToolkit.createItemCreatorFrame()
	if (PhaseToolkit.ItemCreatorFrame ~= nil) then
		if (PhaseToolkit.ItemCreatorFrame:IsShown()) then
			PhaseToolkit.ItemCreatorFrame:Hide()
		else
			PhaseToolkit.ItemCreatorFrame:Show()
		end
		return
	end

	PhaseToolkit.ItemCreatorFrame = CreateFrame("Frame", "ItemCreatorFrame", PhaseToolkit.NPCCustomiserMainFrame, "BackdropTemplate")
	PhaseToolkit.ItemCreatorFrame:SetSize(350,515)
	PhaseToolkit.ItemCreatorFrame:SetPoint("TOPRIGHT", PhaseToolkit.NPCCustomiserMainFrame, "TOPLEFT", -5, 0)
	PhaseToolkit.ItemCreatorFrame:EnableMouse(true);

	PhaseToolkit.ItemCreatorFrame:SetBackdrop({
		bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
		edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
		edgeSize = 16,
		insets = { left = 5, right = 5, top = 5, bottom = 5 },
	})


	-- Creation of the Utility belt

	local utilityBelt=CreateFrame("Frame",nil,PhaseToolkit.ItemCreatorFrame,"BackdropTemplate")
	utilityBelt:SetSize(340,35)
	utilityBelt:SetPoint("TOP", PhaseToolkit.ItemCreatorFrame, "TOP", 0,-5)

	utilityBelt:SetBackdrop({
		bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
		edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
		edgeSize = 16,
		insets = { left = 5, right = 5, top = 5, bottom = 5 },
	})

	--field for the itemID

	PhaseToolkit.itemIdField = CreateFrame("EditBox", "ItemIdField", utilityBelt, "InputBoxTemplate")
	PhaseToolkit.itemIdField:SetSize(150, 30)
	PhaseToolkit.itemIdField:SetPoint("BOTTOMLEFT",utilityBelt,"BOTTOMLEFT",12.5,2.5)
	PhaseToolkit.itemIdField:SetAutoFocus(false)
	PhaseToolkit.itemIdField:SetScript("OnEnterPressed",function(self)
		PhaseToolkit.itemCreatorData.itemLink=self:GetText()
		self:ClearFocus()
	end)

	PhaseToolkit.itemIdField:SetScript("OnTextChanged",function()
		if(PhaseToolkit.itemIdField:GetText()=="") then
			PhaseToolkit.EnableCompoment(PhaseToolkit.GIVEBLOODTOTHEFORGINGGODBUTTON)
			PhaseToolkit.DisableComponent(PhaseToolkit.ApplyDescriptionButton)
			PhaseToolkit.itemCreatorData.itemLink=nil
		end
	end)

	local orig_ChatEdit_InsertLink = ChatEdit_InsertLink

	ChatEdit_InsertLink = function(link)
		if PhaseToolkit.itemIdField:HasFocus() then
			PhaseToolkit.itemIdField:Insert(link)
			PhaseToolkit.itemCreatorData.itemLink=PhaseToolkit.itemIdField:GetText()
			PhaseToolkit.DisableComponent(PhaseToolkit.GIVEBLOODTOTHEFORGINGGODBUTTON)
			PhaseToolkit.EnableCompoment(PhaseToolkit.ApplyDescriptionButton)
			updateFields(PhaseToolkit.itemCreatorData.itemLink)
		else
			orig_ChatEdit_InsertLink(link)
		end
	end

	local labelforItem=utilityBelt:CreateFontString(nil,"OVERLAY","GameFontNormal")
	labelforItem:SetText("Edit Item Link")
	labelforItem:SetPoint("LEFT",PhaseToolkit.itemIdField,"RIGHT",5,0)


	PhaseToolkit.GIVEBLOODTOTHEFORGINGGODBUTTON=CreateFrame("Button",nil,utilityBelt,"UIPanelButtonTemplate");
	PhaseToolkit.GIVEBLOODTOTHEFORGINGGODBUTTON:SetSize(25, 25)
	PhaseToolkit.GIVEBLOODTOTHEFORGINGGODBUTTON:SetPoint("RIGHT", utilityBelt, "RIGHT", -20, 0)
	PhaseToolkit.GIVEBLOODTOTHEFORGINGGODBUTTON.icon = PhaseToolkit.GIVEBLOODTOTHEFORGINGGODBUTTON:CreateTexture(nil, "OVERLAY")
	PhaseToolkit.GIVEBLOODTOTHEFORGINGGODBUTTON.icon:SetTexture("Interface\\Icons\\trade_blacksmithing")
	PhaseToolkit.GIVEBLOODTOTHEFORGINGGODBUTTON.icon:SetAllPoints()

	PhaseToolkit.GIVEBLOODTOTHEFORGINGGODBUTTON:SetScript("OnClick", function()
		if(PhaseToolkit.itemCreatorData.itemLink==nil) then
			PhaseToolkit.previousItems = updateBagContents()
			PhaseToolkit.ItemCreatorFrame:RegisterEvent("BAG_UPDATE")


			PhaseToolkit.ItemCreatorFrame:SetScript("OnEvent",function() C_Timer.After(1, function()
					for _, itemID in ipairs(PhaseToolkit.currentItems) do
						if not tContains(PhaseToolkit.previousItems, itemID) then
							local itemName, itemLink = GetItemInfo(itemID)

							if itemLink == nil then
								-- ItemLink failed. Let's generate a fake link.
								itemLink = minItemLink:format(tonumber(itemID), "TempLink")
							end

							PhaseToolkit.itemCreatorData.itemLink=itemLink
							PhaseToolkit.BLOODFORTHEITEMFORGEGOD()
						end
					end
					PhaseToolkit.previousItems = PhaseToolkit.currentItems
				end)
			end);

			SendChatMessage(".forge item create")
			C_Timer.After(0.5, function()
				PhaseToolkit.currentItems=updateBagContents()
			end)
		end

	end)


	PhaseToolkit.RegisterTooltip(PhaseToolkit.GIVEBLOODTOTHEFORGINGGODBUTTON, "FORGE ! (may take some time)")

	-- Reset Button
	PhaseToolkit.ResetForgeButton=CreateFrame("Button",nil,utilityBelt,"UIPanelButtonTemplate");
	PhaseToolkit.ResetForgeButton:SetSize(25, 25)
	PhaseToolkit.ResetForgeButton:SetPoint("RIGHT", utilityBelt, "RIGHT", -20-25-10, 0)
	PhaseToolkit.ResetForgeButton.icon = PhaseToolkit.ResetForgeButton:CreateTexture(nil, "OVERLAY")
	PhaseToolkit.ResetForgeButton.icon:SetTexture("Interface\\Icons\\trade_blacksmithing")
	PhaseToolkit.ResetForgeButton.icon:SetAllPoints()
	PhaseToolkit.ResetForgeButton.icon2 = PhaseToolkit.ResetForgeButton:CreateTexture(nil, "OVERLAY", nil, select(2,PhaseToolkit.ResetForgeButton.icon:GetDrawLayer())+1)
	PhaseToolkit.ResetForgeButton.icon2:SetAtlas("common-icon-redx")
	PhaseToolkit.ResetForgeButton.icon2:SetAllPoints()

	PhaseToolkit.RegisterTooltip(PhaseToolkit.ResetForgeButton, "Reset Forge")
	PhaseToolkit.ResetForgeButton:SetScript("OnClick", function()
		resetForge()
		--updateFields()
	end)



	-- Information Name

	local informationFrame=CreateFrame("Frame",nil,PhaseToolkit.ItemCreatorFrame,"BackdropTemplate")
	informationFrame:SetSize(340,150)
	informationFrame:SetPoint("TOP", utilityBelt, "BOTTOM", 0,0)

	informationFrame:SetBackdrop({
		bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
		edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
		edgeSize = 16,
		insets = { left = 5, right = 5, top = 5, bottom = 5 },
	})

	PhaseToolkit.nameInputBox = CreateFrame("EditBox", "itemNameField", informationFrame, "InputBoxTemplate")
	PhaseToolkit.nameInputBox:SetSize(310, 30)
	PhaseToolkit.nameInputBox:SetPoint("TOP",informationFrame,"TOP",0,-15)
	PhaseToolkit.nameInputBox:SetAutoFocus(false)

	PhaseToolkit.nameInputBox:SetScript("OnTextChanged", function(self)
		PhaseToolkit.itemCreatorData.itemName=self:GetText();
		if(PhaseToolkit.itemCreatorData.itemLink~=nil and PhaseToolkit.ModifyItemData) then
			local itemLink=" "..PhaseToolkit.itemCreatorData.itemLink.." "
			PhaseToolkit.updateItemLink()
			sendAddonCmd("forge item set name "..itemLink..self:GetText(),nil,false)
		end
	end)
	local maxDescriptionSize=254

	local labelfornameInputBox = informationFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	labelfornameInputBox:SetPoint("TOP", PhaseToolkit.nameInputBox, "TOP", 0, 10)
	labelfornameInputBox:SetText("Item Name")

	local DescriptionFrame  = CreateFrame("FRAME", nil, informationFrame, "BackdropTemplate")
	DescriptionFrame:SetPoint("TOP", PhaseToolkit.nameInputBox, "BOTTOM", 0, -15)
	DescriptionFrame:SetSize(330, 85)

	PhaseToolkit.DescriptionInputBox  = CreateFrame("FRAME", "$parentEdit", DescriptionFrame, "EpsilonInputScrollTemplate")
	PhaseToolkit.DescriptionInputBox:SetPoint("TOP", PhaseToolkit.nameInputBox, "BOTTOM", 0, -15)
	PhaseToolkit.DescriptionInputBox:SetSize(330, 85)
	PhaseToolkit.DescriptionInputBox.SetText = function(self, ...)
		PhaseToolkit.DescriptionInputBox.ScrollFrame.EditBox:SetText(...)
	end

	PhaseToolkit.DescriptionInputBox.ScrollFrame.EditBox:SetScript("OnEnterPressed", function(self)
		self:ClearFocus()
	end)
	PhaseToolkit.DescriptionInputBox.ScrollFrame.EditBox:SetScript("OnEditFocusLost", function(self)
		PhaseToolkit.itemCreatorData.itemDescription=self:GetText();
		if(PhaseToolkit.itemCreatorData.itemLink~=nil and PhaseToolkit.ModifyItemData) then
			if(PhaseToolkit.itemCreatorData.itemLink~=nil) then
				maxDescriptionSize=254-(string.len("f i s de ")+string.len(" "..PhaseToolkit.itemCreatorData.itemLink.." "))
			end
			local itemLink=" "..PhaseToolkit.itemCreatorData.itemLink.." "
			if((string.len(self:GetText())<maxDescriptionSize)) then
				sendAddonCmd("f i s de "..itemLink..PhaseToolkit.itemCreatorData.itemDescription,nil,false)
				PhaseToolkit.HideTooltip()
				self:SetScript("OnEnter",nil)
				self:SetScript("OnLeave",nil)
			else
				local border = DescriptionFrame:CreateTexture(nil, "BACKGROUND")
				border:SetColorTexture(1, 0, 0, 1) -- red (R, G, B, Alpha)
				border:SetPoint("TOPLEFT", -2, 2)
				border:SetPoint("BOTTOMRIGHT", 2, -2)
				PhaseToolkit.ShowTooltip(self,"Your description is too big and will be send in multiple part\nclick the Apply description button on the top-right")
				self:SetScript("OnEnter",function(self)
					PhaseToolkit.ShowTooltip(self,"Your description is too big and will be send in multiple part\nclick the Apply description button on the top-right")
				end)
				self:SetScript("OnLeave",function() PhaseToolkit.HideTooltip() end)

				C_Timer.After(1.5, function()
					border:SetColorTexture(1, 0, 0, 0)
				 end)
			end

		end
	end)

	local labelDescriptionInputBox = informationFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	labelDescriptionInputBox:SetPoint("TOP", PhaseToolkit.DescriptionInputBox, "TOP", 0, 15)
	labelDescriptionInputBox:SetText("Item Description")

	PhaseToolkit.ApplyDescriptionButton=CreateFrame("Button",nil,DescriptionFrame,"UIPanelButtonTemplate")
	PhaseToolkit.ApplyDescriptionButton:SetSize(20,20)
	PhaseToolkit.ApplyDescriptionButton:SetPoint("LEFT", labelDescriptionInputBox, "RIGHT", 80, 0)
	PhaseToolkit.ApplyDescriptionButton.icon = PhaseToolkit.ApplyDescriptionButton:CreateTexture(nil, "OVERLAY")
	PhaseToolkit.ApplyDescriptionButton.icon:SetTexture("Interface\\Icons\\achievement_quests_completed_twilighthighlands")
	PhaseToolkit.ApplyDescriptionButton.icon:SetAllPoints()

	PhaseToolkit.RegisterTooltip(PhaseToolkit.ApplyDescriptionButton, "Apply the description !\nusefull if you copy/pasted\n or if your description is BIG")

	PhaseToolkit.ApplyDescriptionButton:SetScript("OnClick",function(self)
		PhaseToolkit.itemCreatorData.itemDescription=PhaseToolkit.DescriptionInputBox.ScrollFrame.EditBox:GetText();
		if(PhaseToolkit.itemCreatorData.itemLink~=nil) then
			local itemLink=" "..PhaseToolkit.itemCreatorData.itemLink.." "
			if(string.len(PhaseToolkit.itemCreatorData.itemDescription)>maxDescriptionSize) then
				sendMessageInChunks("f i s de "..itemLink..PhaseToolkit.itemCreatorData.itemDescription)
			else
				sendAddonCmd("forge item set description "..itemLink..PhaseToolkit.itemCreatorData.itemDescription,nil,false)
			end
		end
	end)




	-- Main property Frame

	local mainProperty=CreateFrame("Frame",nil,PhaseToolkit.ItemCreatorFrame,"BackdropTemplate")
	mainProperty:SetSize(170,150)
	mainProperty:SetPoint("TOPLEFT", informationFrame, "BOTTOMLEFT", 0,0)

	mainProperty:SetBackdrop({
		bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
		edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
		edgeSize = 16,
		insets = { left = 5, right = 5, top = 5, bottom = 5 },
	})

	PhaseToolkit.ItemClassDropdown = CreateFrame("Frame", nil, mainProperty, "UIDropDownMenuTemplate")
	PhaseToolkit.ItemClassDropdown:SetSize(160, 30)
	PhaseToolkit.ItemClassDropdown:SetPoint("TOPLEFT", mainProperty, "TOPLEFT", -10,-5)

	PhaseToolkit.ItemSubClassDropdown = CreateFrame("Frame", nil, mainProperty, "UIDropDownMenuTemplate")
	PhaseToolkit.ItemSubClassDropdown:SetSize(160, 30)
	PhaseToolkit.ItemSubClassDropdown:SetPoint("TOPLEFT", mainProperty, "TOPLEFT", -10,-30)
	PhaseToolkit.DisableComponent(PhaseToolkit.ItemSubClassDropdown);

	PhaseToolkit.ShowItemClassDropdown(PhaseToolkit.ItemClassDropdown,PhaseToolkit.ItemSubClassDropdown)

	PhaseToolkit.ItemInventoryTypeDropdown = CreateFrame("Frame", nil, mainProperty, "UIDropDownMenuTemplate")
	PhaseToolkit.ItemInventoryTypeDropdown:SetSize(160, 30)
	PhaseToolkit.ItemInventoryTypeDropdown:SetPoint("TOPLEFT", mainProperty, "TOPLEFT", -10,-55)

	PhaseToolkit.ShowItemInventoryDropdown(PhaseToolkit.ItemInventoryTypeDropdown)

	PhaseToolkit.itemdisplayIdEditBox = CreateFrame("EditBox", "displayIdEditBox", mainProperty, "InputBoxTemplate")
	PhaseToolkit.itemdisplayIdEditBox:SetSize(150, 30)
	PhaseToolkit.itemdisplayIdEditBox:SetPoint("TOPLEFT",PhaseToolkit.ItemInventoryTypeDropdown,"BOTTOMLEFT",20,-10)
	PhaseToolkit.itemdisplayIdEditBox:SetAutoFocus(false)

	PhaseToolkit.itemdisplayIdEditBox:SetScript("OnTextChanged",function()
		if(PhaseToolkit.itemdisplayIdEditBox:GetText()=="") then
			PhaseToolkit.itemCreatorData.itemDisplayLink=nil
		end
	end)

	local orig_ChatEdit_InsertLink = ChatEdit_InsertLink

	ChatEdit_InsertLink = function(link)
		if PhaseToolkit.itemdisplayIdEditBox:HasFocus() then
			PhaseToolkit.itemdisplayIdEditBox:Insert(link)
			PhaseToolkit.itemCreatorData.itemDisplayLink=PhaseToolkit.itemdisplayIdEditBox:GetText()
			if(PhaseToolkit.itemCreatorData.itemLink~=nil) then
				local itemLink=" "..PhaseToolkit.itemCreatorData.itemLink.." "
				sendAddonCmd("forge item set display "..itemLink..PhaseToolkit.itemCreatorData.itemDisplayLink,nil,false)
			end
		else
			orig_ChatEdit_InsertLink(link)
		end
	end
	local LabeldisplayEditBox=mainProperty:CreateFontString(nil,"OVERLAY","GameFontNormal")
	LabeldisplayEditBox:SetText(PhaseToolkit.CurrentLang["Display ID from:"])
	LabeldisplayEditBox:SetPoint("BOTTOMLEFT", PhaseToolkit.itemdisplayIdEditBox, "TOPLEFT", 5, 0)

	PhaseToolkit.RegisterTooltip(PhaseToolkit.itemdisplayIdEditBox, "Item Link")

	PhaseToolkit.itemdisplayIdEditBox:SetScript("OnEnterPressed",function(self)
		self:ClearFocus()
	end)
	PhaseToolkit.itemdisplayIdEditBox:SetScript("OnEditFocusLost",function(self)
		if(self:GetText()~=nil) then
			local itemName,itemLink =GetItemInfo(self:GetText())
			PhaseToolkit.itemCreatorData.DisplayLink=itemLink
		end
	end)

	-- display property Frame

	local displayProperty=CreateFrame("Frame",nil,PhaseToolkit.ItemCreatorFrame,"BackdropTemplate")
	displayProperty:SetSize(170,150)
	displayProperty:SetPoint("TOPLEFT", mainProperty, "TOPRIGHT",0,0)

	displayProperty:SetBackdrop({
		bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
		edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
		edgeSize = 16,
		insets = { left = 5, right = 5, top = 5, bottom = 5 },
	})

	PhaseToolkit.ItemBondingDropdown = CreateFrame("Frame", nil, displayProperty, "UIDropDownMenuTemplate")
	PhaseToolkit.ItemBondingDropdown:SetSize(160, 30)
	PhaseToolkit.ItemBondingDropdown:SetPoint("TOPLEFT", displayProperty, "TOPLEFT", -10,-5)

	PhaseToolkit.ShowItemBondingDropdown(PhaseToolkit.ItemBondingDropdown)

	PhaseToolkit.ItemQualityDropdown = CreateFrame("Frame", nil, displayProperty, "UIDropDownMenuTemplate")
	PhaseToolkit.ItemQualityDropdown:SetSize(160, 30)
	PhaseToolkit.ItemQualityDropdown:SetPoint("TOPLEFT", displayProperty, "TOPLEFT", -10,-30)

	PhaseToolkit.ShowItemQualityDropdown(PhaseToolkit.ItemQualityDropdown)

	PhaseToolkit.ItemSheathDropdown = CreateFrame("Frame", nil, displayProperty, "UIDropDownMenuTemplate")
	PhaseToolkit.ItemSheathDropdown:SetSize(160, 30)
	PhaseToolkit.ItemSheathDropdown:SetPoint("TOPLEFT", displayProperty, "TOPLEFT", -10,-55)

	PhaseToolkit.ShowItemSheathDropdown(PhaseToolkit.ItemSheathDropdown)


	PhaseToolkit.itemCreatorCheckboxStackable = CreateFrame("CheckButton", "CheckboxStackable", displayProperty, "ChatConfigCheckButtonTemplate")
	PhaseToolkit.itemCreatorCheckboxStackable:SetPoint("BOTTOMLEFT",displayProperty,"BOTTOMLEFT",5,5)
	PhaseToolkit.itemCreatorCheckboxStackable:SetSize(26, 26)

	PhaseToolkit.iteeCreatorEditBoxStackable=CreateFrame("EditBox", "itemCreatorEditBoxStackable", PhaseToolkit.itemCreatorCheckboxStackable, "InputBoxTemplate")
	PhaseToolkit.iteeCreatorEditBoxStackable:SetSize(50, 30)
	PhaseToolkit.iteeCreatorEditBoxStackable:SetPoint("LEFT", PhaseToolkit.itemCreatorCheckboxStackable, "RIGHT", 80, 0)
	PhaseToolkit.iteeCreatorEditBoxStackable:SetAutoFocus(false)
	PhaseToolkit.iteeCreatorEditBoxStackable:SetNumeric(true)
	PhaseToolkit.iteeCreatorEditBoxStackable:Hide()

	PhaseToolkit.iteeCreatorEditBoxStackable:SetScript("OnEnterPressed",function(self)
		if(self:GetText()~="") then
			local valeur=self:GetText()
			if(tonumber(self:GetText())>10000) then
				PhaseToolkit.iteeCreatorEditBoxStackable:SetText("10000")
				valeur="10000"
			end
			PhaseToolkit.itemCreatorData.stackablecount=tonumber(valeur)
			if(PhaseToolkit.itemCreatorData.itemLink~=nil) then
				local itemLink=" "..PhaseToolkit.itemCreatorData.itemLink.." "
				sendAddonCmd("forge item set stackable "..itemLink..valeur,nil,false)
			end
		else
			PhaseToolkit.itemCreatorData.stackablecount=nil
		end
		self:ClearFocus()
	end)

	PhaseToolkit.iteeCreatorEditBoxStackable:SetScript("OnEscapePressed",function(self)
		self:ClearFocus()
	end)

	PhaseToolkit.itemCreatorCheckboxStackable.Text:SetText("Stackable")
	PhaseToolkit.itemCreatorCheckboxStackable.Text:SetPoint("LEFT", PhaseToolkit.itemCreatorCheckboxStackable, "RIGHT", 5, 0)

	PhaseToolkit.itemCreatorCheckboxStackable:SetScript("OnClick", function(self)
		if self:GetChecked() then
			PhaseToolkit.itemCreatorData.stackable=true
			PhaseToolkit.iteeCreatorEditBoxStackable:Show()
		else
			PhaseToolkit.itemCreatorData.stackable=false
			PhaseToolkit.iteeCreatorEditBoxStackable:Hide()
		end
	end)


	PhaseToolkit.iconIdEditBox = CreateFrame("EditBox", "iconIdEditBox", displayProperty, "InputBoxTemplate")
	PhaseToolkit.iconIdEditBox:SetSize(150, 30)
	PhaseToolkit.iconIdEditBox:SetPoint("TOPLEFT",PhaseToolkit.ItemSheathDropdown,"BOTTOMLEFT",20,-10)
	PhaseToolkit.iconIdEditBox:SetAutoFocus(false)


    PhaseToolkit.iconIdPickerButton = CreateFrame("Button", nil, displayProperty, "UIPanelButtonTemplate")
    PhaseToolkit.iconIdPickerButton:SetSize(40,20)
    PhaseToolkit.iconIdPickerButton:SetFrameLevel(PhaseToolkit.iconIdEditBox:GetFrameLevel()+1)
    PhaseToolkit.iconIdPickerButton.Text:SetText("Select")
    PhaseToolkit.iconIdPickerButton:SetNormalFontObject("GameFontNormalSmall")
    PhaseToolkit.iconIdPickerButton:SetDisabledFontObject("GameFontDisableSmall")
    PhaseToolkit.iconIdPickerButton:SetHighlightFontObject("GameFontHighlightSmall")
    PhaseToolkit.iconIdPickerButton:SetPoint("BOTTOMRIGHT", PhaseToolkit.iconIdEditBox, "TOPRIGHT", 0, -4)
    PhaseToolkit.iconIdPickerButton:SetScript("OnClick", function(self)
        --EpsilonLibIconPicker_Open(returnFunc, closeOnClick, playSound, attachFrame, hidePortrait)
        EpsilonLibIconPicker_Open(function(path, name, id)
            if id then
				PhaseToolkit.iconIdEditBox:SetText(id)
				PhaseToolkit.itemCreatorData.itemIconIdOrLink=id
				-- if we are live editing, we save and apply the new icon
				if(PhaseToolkit.itemCreatorData.itemLink~=nil) then
					local itemLink=" "..PhaseToolkit.itemCreatorData.itemLink.." "
					sendAddonCmd("forge item set icon "..itemLink..PhaseToolkit.itemCreatorData.itemIconIdOrLink,updateContainers,false)
				end
			end
        end, true, true, false, true):SetPoint("LEFT", PhaseToolkit.iconIdPickerButton, "RIGHT", 20, 0)
    end)

	local function saveItemIconIdOrLink(idOrLink)
		if idOrLink and idOrLink ~= "" then
			if not tonumber(idOrLink) then
				-- It's not an number ID, probably. Try it as a Link
				local itemName, itemLink = GetItemInfo(idOrLink)
				if itemLink then
					-- Valid link, use it
					PhaseToolkit.itemCreatorData.itemIconIdOrLink=itemLink
					return
				end
			else
				-- Just save the ID or possibly weird link to try it lol
				PhaseToolkit.itemCreatorData.itemIconIdOrLink = idOrLink
			end
		else
			-- Link was blank, nil it to be sure
			PhaseToolkit.itemCreatorData.itemIconIdOrLink=nil
		end
	end

	PhaseToolkit.iconIdEditBox:SetScript("OnTextChanged",function(self)
		saveItemIconIdOrLink(self:GetText())
	end)

	PhaseToolkit.iconIdEditBox:SetScript("OnEditFocusLost",function(self)
		local idOrLink = self:GetText()
		if(idOrLink and idOrLink~="") then
			saveItemIconIdOrLink(idOrLink)
			if(PhaseToolkit.itemCreatorData.itemLink~=nil) then
				local itemLink=" "..PhaseToolkit.itemCreatorData.itemLink.." "
				sendAddonCmd("forge item set icon "..itemLink..PhaseToolkit.itemCreatorData.itemIconIdOrLink,updateContainers,false)
			end
		end
	end)
	PhaseToolkit.iconIdEditBox:SetScript("OnEnterPressed",function(self)
		self:ClearFocus()
	end)

	local orig_ChatEdit_InsertLink = ChatEdit_InsertLink

	ChatEdit_InsertLink = function(link)
		if PhaseToolkit.iconIdEditBox:HasFocus() then
			PhaseToolkit.iconIdEditBox:Insert(link)
		else
			orig_ChatEdit_InsertLink(link)
		end
	end
	local LabeldisplayEditBox=displayProperty:CreateFontString(nil,"OVERLAY","GameFontNormal")
	LabeldisplayEditBox:SetText(PhaseToolkit.CurrentLang["Icon from:"])
	LabeldisplayEditBox:SetPoint("BOTTOMLEFT", PhaseToolkit.iconIdEditBox, "TOPLEFT", 5, 0)

	PhaseToolkit.RegisterTooltip(PhaseToolkit.iconIdEditBox, "Item Link or ID")

	-- item property Frame

	local itemProperty=CreateFrame("Frame",nil,PhaseToolkit.ItemCreatorFrame,"BackdropTemplate")
	itemProperty:SetSize(170,170)
	itemProperty:SetPoint("TOPLEFT", mainProperty, "BOTTOMLEFT", 0,0)

	itemProperty:SetBackdrop({
		bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
		edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
		edgeSize = 16,
		insets = { left = 5, right = 5, top = 5, bottom = 5 },
	})

	local adderOptionDropdown = CreateFrame("Frame", nil, itemProperty, "UIDropDownMenuTemplate")
	adderOptionDropdown:SetSize(100, 30)
	adderOptionDropdown:SetPoint("TOPLEFT", itemProperty, "TOPLEFT", -10,-5)
	PhaseToolkit.adderOptionDropdown = adderOptionDropdown
	PhaseToolkit.ShowadderOptionDropdown(adderOptionDropdown)
	PhaseToolkit.RegisterTooltip(adderOptionDropdown, "Controls if the item contains a '<Made by Character>' tag when added.\n\nEnabling this will disable the Creator tag property.")

	local addItemOptionDropdown = CreateFrame("Frame", nil, itemProperty, "UIDropDownMenuTemplate")
	addItemOptionDropdown:SetSize(100, 30)
	addItemOptionDropdown:SetPoint("TOPLEFT", itemProperty, "TOPLEFT", -10,-30)
	PhaseToolkit.addItemOptionDropdownButton = addItemOptionDropdown
	PhaseToolkit.addItemOptionDropdown(addItemOptionDropdown)
	PhaseToolkit.RegisterTooltip(addItemOptionDropdown, "Controls who is allowed to add this item.\n\nIf Member / Officer is enabled, will only work for Phases specifically added to the Member / Officer whitelist (use the buttons to the right!)")

	local copyOptionDropdown = CreateFrame("Frame", nil, itemProperty, "UIDropDownMenuTemplate")
	copyOptionDropdown:SetSize(100, 30)
	copyOptionDropdown:SetPoint("TOPLEFT", itemProperty, "TOPLEFT", -10,-55)
	PhaseToolkit.copyOptionDropdown = copyOptionDropdown
	PhaseToolkit.copyItemOptionDropdown(copyOptionDropdown)
	PhaseToolkit.RegisterTooltip(copyOptionDropdown, "Controls who is allowed to copy or clone this item via 'forge item copy/clone'.")

	local creatorOptionDropdown = CreateFrame("Frame", nil, itemProperty, "UIDropDownMenuTemplate")
	creatorOptionDropdown:SetSize(100, 30)
	creatorOptionDropdown:SetPoint("TOPLEFT", itemProperty, "TOPLEFT", -10,-80)
	PhaseToolkit.creatorOptionDropdown = creatorOptionDropdown
	PhaseToolkit.creatorItemOptionDropdown(creatorOptionDropdown)
	PhaseToolkit.RegisterTooltip(creatorOptionDropdown, "When enabled, adds a <Made by $CreatorCharacterName> to the item.\n\nEnabling this will disable the Adder tag property.")

	local infoOptionDropdown = CreateFrame("Frame", nil, itemProperty, "UIDropDownMenuTemplate")
	infoOptionDropdown:SetSize(100, 30)
	infoOptionDropdown:SetPoint("TOPLEFT", itemProperty, "TOPLEFT", -10,-105)
	PhaseToolkit.infoOptionDropdown = infoOptionDropdown
	PhaseToolkit.infoItemOptionDropdown(infoOptionDropdown)
	PhaseToolkit.RegisterTooltip(infoOptionDropdown, "Sets if information for this item is visible to others.")

	local lookupOptionDropdown = CreateFrame("Frame", nil, itemProperty, "UIDropDownMenuTemplate")
	lookupOptionDropdown:SetSize(100, 30)
	lookupOptionDropdown:SetPoint("TOPLEFT", itemProperty, "TOPLEFT", -10,-130)
	PhaseToolkit.lookupOptionDropdown = lookupOptionDropdown
	PhaseToolkit.lookupItemOptionDropdown(lookupOptionDropdown)
	PhaseToolkit.RegisterTooltip(lookupOptionDropdown, "Sets if the item shows in '.lookup itemforge' for others. Will always show for the creator of the item.")

	-- Whitelist Frame

	local Whitelist=CreateFrame("Frame",nil,PhaseToolkit.ItemCreatorFrame,"BackdropTemplate")
	Whitelist:SetSize(170,170)
	Whitelist:SetPoint("TOPLEFT", itemProperty, "TOPRIGHT",0,0)

	Whitelist:SetBackdrop({
		bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
		edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
		edgeSize = 16,
		insets = { left = 5, right = 5, top = 5, bottom = 5 },
	})

	local addCharToWhitelist=CreateFrame("Button",nil,Whitelist,"UIPanelButtonTemplate");
	addCharToWhitelist:SetSize(40, 40)
	addCharToWhitelist:SetPoint("TOPLEFT", Whitelist, "TOPLEFT", 20, -10)
	addCharToWhitelist.icon = addCharToWhitelist:CreateTexture(nil, "OVERLAY")
	addCharToWhitelist.icon:SetTexture("Interface\\Icons\\inv_misc_grouplooking")
	addCharToWhitelist.icon:SetAllPoints()
	addCharToWhitelist:SetScript("OnClick", function()
		PhaseToolkit.openAddCharToWhitelistFrame()
	end)

	PhaseToolkit.RegisterTooltip(addCharToWhitelist, "Add a character to the item's whitelist, so they can add the item.")

	local seeCharAddedToListButton=CreateFrame("Button",nil,Whitelist,"UIPanelButtonTemplate");
	seeCharAddedToListButton:SetSize(35, 35)
	seeCharAddedToListButton:SetPoint("LEFT", addCharToWhitelist, "RIGHT", 20, 0)
	seeCharAddedToListButton.icon = seeCharAddedToListButton:CreateTexture(nil, "OVERLAY")
	seeCharAddedToListButton.icon:SetTexture("Interface\\Icons\\inv_misc_paperbundle04c")
	seeCharAddedToListButton.icon:SetAllPoints()
	seeCharAddedToListButton:SetScript("OnClick", function()
		PhaseToolkit.openWhitelistFor("character",false)
	end)
	PhaseToolkit.RegisterTooltip(seeCharAddedToListButton, "Show a list of currently whitelisted characters.")

	local addMemberToWhitelist=CreateFrame("Button",nil,Whitelist,"UIPanelButtonTemplate");
	addMemberToWhitelist:SetSize(40, 40)
	addMemberToWhitelist:SetPoint("TOP", addCharToWhitelist, "BOTTOM", 0, -10)
	addMemberToWhitelist.icon = addMemberToWhitelist:CreateTexture(nil, "OVERLAY")
	addMemberToWhitelist.icon:SetTexture("Interface\\Icons\\inv_misc_groupneedmore")
	addMemberToWhitelist.icon:SetAllPoints()
	addMemberToWhitelist:SetScript("OnClick", function()
		PhaseToolkit.openAddMemberToWhitelistFrame()
	end)
	PhaseToolkit.RegisterTooltip(addMemberToWhitelist, "Add a Phase to the 'Members' Whitelist, allowing that Phases' members to add the item.")

	local seeMemberAddedToListButton=CreateFrame("Button",nil,Whitelist,"UIPanelButtonTemplate");
	seeMemberAddedToListButton:SetSize(35, 35)
	seeMemberAddedToListButton:SetPoint("LEFT", addMemberToWhitelist, "RIGHT", 20, 0)
	seeMemberAddedToListButton.icon = seeMemberAddedToListButton:CreateTexture(nil, "OVERLAY")
	seeMemberAddedToListButton.icon:SetTexture("Interface\\Icons\\inv_misc_paperbundle04c")
	seeMemberAddedToListButton.icon:SetAllPoints()
	seeMemberAddedToListButton:SetScript("OnClick", function()
		PhaseToolkit.openWhitelistFor("member",false)
	end)
	PhaseToolkit.RegisterTooltip(seeMemberAddedToListButton, "Show a list of Phases currently on the 'Members' Whitelist.")


	local addOfficerToWhitelist=CreateFrame("Button",nil,Whitelist,"UIPanelButtonTemplate");
	addOfficerToWhitelist:SetSize(40, 40)
	addOfficerToWhitelist:SetPoint("TOP", addMemberToWhitelist, "BOTTOM", 0, -10)
	addOfficerToWhitelist.icon = addOfficerToWhitelist:CreateTexture(nil, "OVERLAY")
	addOfficerToWhitelist.icon:SetTexture("Interface\\Icons\\ability_pvp_gladiatormedallion")
	addOfficerToWhitelist.icon:SetAllPoints()
	addOfficerToWhitelist:SetScript("OnClick", function()
		PhaseToolkit.openAddOfficerToWhitelistFrame()
	end)
	PhaseToolkit.RegisterTooltip(addOfficerToWhitelist, "Add a Phase to the 'Officers' Whitelist, allowing that Phases' officers to add the item.")

	local seeOfficerAddedToListButton=CreateFrame("Button",nil,Whitelist,"UIPanelButtonTemplate");
	seeOfficerAddedToListButton:SetSize(35, 35)
	seeOfficerAddedToListButton:SetPoint("LEFT", addOfficerToWhitelist, "RIGHT", 20, 0)
	seeOfficerAddedToListButton.icon = seeOfficerAddedToListButton:CreateTexture(nil, "OVERLAY")
	seeOfficerAddedToListButton.icon:SetTexture("Interface\\Icons\\inv_misc_paperbundle04c")
	seeOfficerAddedToListButton.icon:SetAllPoints()
	seeOfficerAddedToListButton:SetScript("OnClick", function()
		PhaseToolkit.openWhitelistFor("officer",false)
	end)
	PhaseToolkit.RegisterTooltip(seeOfficerAddedToListButton, "Show a list of Phases currently on the 'Officers' Whitelist.")

end

local function updateWhitelistDisplay(typeOfWhitelist, data)
    -- Nettoyer le contenu existant
    if PhaseToolkit.listFrame.content then
        PhaseToolkit.listFrame.content:Hide()
        PhaseToolkit.listFrame.content = nil
    end

    -- Contenu à scroller
    local content = CreateFrame("Frame", nil, PhaseToolkit.listFrame.scrollFrame)
    content:SetSize(100, 30 * (#data or 1)) -- Ajuste la hauteur en fonction du nombre d'éléments
    PhaseToolkit.listFrame.content = content
	local tableau={}

    local maxTextWidth = 0 -- Pour déterminer la largeur maximale

    for i, value in ipairs(data) do
        -- Texte pour l'élément
        local text = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        text:SetPoint("TOPLEFT", 10, -30 * (i - 1) - 10)
        text:SetText(value)

		 -- Calculer la largeur du texte
		 local textWidth = text:GetStringWidth()
		 if textWidth > maxTextWidth then
			 maxTextWidth = textWidth+30
		 end

        -- Bouton de suppression
        local deleteButton = CreateFrame("Button", nil, content, "UIPanelCloseButton")
        deleteButton:SetSize(30, 30)
        deleteButton:SetPoint("LEFT",text,"RIGHT", 10,0)

        -- Icône croix et suppression
        deleteButton:SetScript("OnClick", function()
            table.remove(data, i) -- Supprime l'élément du tableau
            updateWhitelistDisplay(typeOfWhitelist, data) -- Actualise la liste
        end)
    end

    -- Lier le contenu au ScrollFrame
    PhaseToolkit.listFrame.scrollFrame:SetScrollChild(content)

	-- Ajuster la taille de PhaseToolkit.listFrame si nécessaire
    local newWidth = math.max(150, maxTextWidth + 50) -- Largeur minimum + marge
    PhaseToolkit.listFrame:SetWidth(newWidth)
end

local function getDataFromWhitelistType(typeOfWhitelist)
	local data={}
		if(typeOfWhitelist=="character") then
			data=PhaseToolkit.itemCreatorData.whitelistedChar
		elseif typeOfWhitelist=="member" then
			data=PhaseToolkit.itemCreatorData.whitelistedPhaseForMember
		elseif typeOfWhitelist=="officer" then
			data=PhaseToolkit.itemCreatorData.whitelistedPhaseForOfficer
		end
		return data
end

function PhaseToolkit.openWhitelistFor(typeOfWhitelist,updating)
	if (PhaseToolkit.listFrame ~= nil) then
			updateWhitelistDisplay(typeOfWhitelist,getDataFromWhitelistType(typeOfWhitelist))
			PhaseToolkit.listFrame:Show()
	else
		-- Frame principale
		PhaseToolkit.listFrame = CreateFrame("Frame", "MyScrollableFrame", PhaseToolkit.ItemCreatorFrame, "BasicFrameTemplateWithInset")
		PhaseToolkit.listFrame:SetSize(150, 200)
		PhaseToolkit.listFrame:SetPoint("BOTTOMLEFT", PhaseToolkit.ItemCreatorFrame, "BOTTOMRIGHT", 5, 0)

		-- ScrollFrame
		local scrollFrame = CreateFrame("ScrollFrame", nil, PhaseToolkit.listFrame, "UIPanelScrollFrameTemplate")
		scrollFrame:SetPoint("TOPLEFT", 10, -30)
		scrollFrame:SetPoint("BOTTOMRIGHT", -30, 10)
		PhaseToolkit.listFrame.scrollFrame = scrollFrame

		PhaseToolkit.currentWhitelistType=typeOfWhitelist
		-- Initialiser l'affichage
		updateWhitelistDisplay(typeOfWhitelist, getDataFromWhitelistType(typeOfWhitelist))
	end
end

function PhaseToolkit.ShowadderOptionDropdown(_dropdown)
	local function OnClick(self)
		UIDropDownMenu_SetSelectedValue(_dropdown, self.value)
		PhaseToolkit.itemCreatorData.adder=self.value
		if(PhaseToolkit.itemCreatorData.itemLink~=nil) then
			local itemLink=" "..PhaseToolkit.itemCreatorData.itemLink.." "
			sendAddonCmd("forge item set property adder "..itemLink..self.value,nil,false)
		end
	end

	UIDropDownMenu_Initialize(_dropdown, function()
		local info = UIDropDownMenu_CreateInfo()
		local info2=UIDropDownMenu_CreateInfo()
		local info3=UIDropDownMenu_CreateInfo()

		info.text="Adder"
		info2.text="On"
		info3.text="Off"

		info.value = -1
		info2.value = "on"
		info3.value="off"

		info.func = OnClick
		info2.func = OnClick
		info3.func = OnClick

		UIDropDownMenu_AddButton(info)
		UIDropDownMenu_AddButton(info2)
		UIDropDownMenu_AddButton(info3)
	end)

	UIDropDownMenu_SetWidth(_dropdown, 140)
	UIDropDownMenu_SetButtonWidth(_dropdown, 124)
	UIDropDownMenu_SetSelectedValue(_dropdown,-1)
end

function PhaseToolkit.addItemOptionDropdown(_dropdown)

	UIDropDownMenu_Initialize(_dropdown, function(self)
		local info = UIDropDownMenu_CreateInfo()

		for _,additemOption in ipairs(PhaseToolkit.additemOption) do
			info.text = additemOption.text
			info.arg1 = strlower(additemOption.text)
			info.value = additemOption.value
			info.func = function(self, arg1, arg2)
				additemOption.value = not additemOption.value
				if(PhaseToolkit.itemCreatorData.itemLink~=nil) then
					local itemLink=" "..PhaseToolkit.itemCreatorData.itemLink.." "
					local realValue= (self.checked==true and "on") or "off"
					sendAddonCmd("forge item set property additem "..arg1.." "..itemLink..realValue,nil,true)
				end
			end

			local check = false;

			if additemOption.value then
				check = true;
			end
			info.isNotRadio = true
			info.keepShownOnClick = true
			info.checked = check;
			UIDropDownMenu_AddButton(info)
		end
	end)

	UIDropDownMenu_SetWidth(_dropdown, 140)
	UIDropDownMenu_SetText(_dropdown, "Additem");
end

function PhaseToolkit.copyItemOptionDropdown(_dropdown)
	local function OnClick(self)
		UIDropDownMenu_SetSelectedValue(_dropdown, self.value)
		PhaseToolkit.itemCreatorData.copy=self.value
		if(PhaseToolkit.itemCreatorData.itemLink~=nil) then
			local itemLink=" "..PhaseToolkit.itemCreatorData.itemLink.." "
			sendAddonCmd("forge item set property copy "..itemLink..self.value,nil,false)
		end

	end

	UIDropDownMenu_Initialize(_dropdown, function()
		local info = UIDropDownMenu_CreateInfo()
		local info2=UIDropDownMenu_CreateInfo()
		local info3=UIDropDownMenu_CreateInfo()

		info.text="Copy"
		info2.text="On"
		info3.text="Off"

		info.value = -1
		info2.value = "on"
		info3.value="off"

		info.func = OnClick
		info2.func = OnClick
		info3.func = OnClick

		UIDropDownMenu_AddButton(info)
		UIDropDownMenu_AddButton(info2)
		UIDropDownMenu_AddButton(info3)
	end)

	UIDropDownMenu_SetWidth(_dropdown, 140)
	UIDropDownMenu_SetButtonWidth(_dropdown, 124)
	UIDropDownMenu_SetSelectedValue(_dropdown,-1)

end

function PhaseToolkit.creatorItemOptionDropdown(_dropdown)
	local function OnClick(self)
		UIDropDownMenu_SetSelectedValue(_dropdown, self.value)
		PhaseToolkit.itemCreatorData.creator=self.value
		if(PhaseToolkit.itemCreatorData.itemLink~=nil) then
			local itemLink=" "..PhaseToolkit.itemCreatorData.itemLink.." "
			sendAddonCmd("forge item set property creator "..itemLink..self.value,nil,false)
		end
	end

	UIDropDownMenu_Initialize(_dropdown, function()
		local info = UIDropDownMenu_CreateInfo()
		local info2=UIDropDownMenu_CreateInfo()
		local info3=UIDropDownMenu_CreateInfo()

		info.text="Creator"
		info2.text="On"
		info3.text="Off"

		info.value = -1
		info2.value = "on"
		info3.value="off"

		info.func = OnClick
		info2.func = OnClick
		info3.func = OnClick

		UIDropDownMenu_AddButton(info)
		UIDropDownMenu_AddButton(info2)
		UIDropDownMenu_AddButton(info3)
	end)

	UIDropDownMenu_SetWidth(_dropdown, 140)
	UIDropDownMenu_SetButtonWidth(_dropdown, 124)
	UIDropDownMenu_SetSelectedValue(_dropdown,-1)

end

function PhaseToolkit.infoItemOptionDropdown(_dropdown)
	local function OnClick(self)
		UIDropDownMenu_SetSelectedValue(_dropdown, self.value)
		PhaseToolkit.itemCreatorData.info=self.value
		if(PhaseToolkit.itemCreatorData.itemLink~=nil) then
			local itemLink=" "..PhaseToolkit.itemCreatorData.itemLink.." "
			sendAddonCmd("forge item set property info "..itemLink..self.value,nil,false)
		end
	end

	UIDropDownMenu_Initialize(_dropdown, function()
		local info = UIDropDownMenu_CreateInfo()
		local info2=UIDropDownMenu_CreateInfo()
		local info3=UIDropDownMenu_CreateInfo()

		info.text="Info"
		info2.text="On"
		info3.text="Off"

		info.value = -1
		info2.value = "on"
		info3.value="off"

		info.func = OnClick
		info2.func = OnClick
		info3.func = OnClick

		UIDropDownMenu_AddButton(info)
		UIDropDownMenu_AddButton(info2)
		UIDropDownMenu_AddButton(info3)
	end)

	UIDropDownMenu_SetWidth(_dropdown, 140)
	UIDropDownMenu_SetButtonWidth(_dropdown, 124)
	UIDropDownMenu_SetSelectedValue(_dropdown,-1)

end

function PhaseToolkit.lookupItemOptionDropdown(_dropdown)
	local function OnClick(self)
		UIDropDownMenu_SetSelectedValue(_dropdown, self.value)
		PhaseToolkit.itemCreatorData.lookup=self.value
		if(PhaseToolkit.itemCreatorData.itemLink~=nil) then
			local itemLink=" "..PhaseToolkit.itemCreatorData.itemLink.." "
			sendAddonCmd("forge item set property lookup "..itemLink..self.value,nil,false)
		end
	end

	UIDropDownMenu_Initialize(_dropdown, function()
		local info = UIDropDownMenu_CreateInfo()
		local info2=UIDropDownMenu_CreateInfo()
		local info3=UIDropDownMenu_CreateInfo()

		info.text="Lookup"
		info2.text="On"
		info3.text="Off"

		info.value = -1
		info2.value = "on"
		info3.value="off"

		info.func = OnClick
		info2.func = OnClick
		info3.func = OnClick

		UIDropDownMenu_AddButton(info)
		UIDropDownMenu_AddButton(info2)
		UIDropDownMenu_AddButton(info3)
	end)

	UIDropDownMenu_SetWidth(_dropdown, 140)
	UIDropDownMenu_SetButtonWidth(_dropdown, 124)
	UIDropDownMenu_SetSelectedValue(_dropdown,-1)

end

function PhaseToolkit.CreateAdditionalButtonFrame()
	if (PhaseToolkit.AdditionalButtonFrame ~= nil) then
		if (PhaseToolkit.AdditionalButtonFrame:IsShown()) then
			PhaseToolkit.AdditionalButtonFrame:Hide()
		else
			PhaseToolkit.AdditionalButtonFrame:Show()
		end
	end
	PhaseToolkit.AdditionalButtonFrame = CreateFrame("Frame", nil, PhaseToolkit.NPCCustomiserMainFrame, "BackdropTemplate")
	PhaseToolkit.AdditionalButtonFrame:SetBackdrop({
		bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
		edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
		edgeSize = 16,
		insets = { left = 5, right = 5, top = 5, bottom = 5 },
	})

	if (not PhaseToolkit.ModeFR) then
		PhaseToolkit.AdditionalButtonFrame:SetSize(145, 160)
		PhaseToolkit.AdditionalButtonFrame:SetPoint("TOP", PhaseToolkit.NPCCustomiserMainFrame, "TOP", 0, -30)
	else
		PhaseToolkit.AdditionalButtonFrame:SetSize(135, 160)
		PhaseToolkit.AdditionalButtonFrame:SetPoint("TOP", PhaseToolkit.NPCCustomiserMainFrame, "TOP", 0, -30)
	end

	local NpcCustomPanelButton = CreateFrame("Button", nil, PhaseToolkit.AdditionalButtonFrame, "UIPanelButtonTemplate")
	NpcCustomPanelButton:SetSize(25, 25)
	NpcCustomPanelButton:SetPoint("TOPRIGHT", PhaseToolkit.AdditionalButtonFrame, "TOPRIGHT", -7.5, -7.5)
	NpcCustomPanelButton.icon = NpcCustomPanelButton:CreateTexture(nil, "OVERLAY")
	NpcCustomPanelButton.icon:SetTexture("Interface\\Icons\\inv_helm_mask_fittedalpha_b_01_nightborne_02")
	NpcCustomPanelButton.icon:SetAllPoints()
	NpcCustomPanelButton:SetScript("OnClick", function()
		PhaseToolkit.createCustomParamFrame()
	end)

	NpcCustomLabel = PhaseToolkit.AdditionalButtonFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	NpcCustomLabel:SetPoint("RIGHT", NpcCustomPanelButton, "LEFT", -2.5, 2.5)
	NpcCustomLabel:SetText(PhaseToolkit.CurrentLang["Npc custom"] or "NPC Customize")

	local PhaseOptionButton = CreateFrame("Button", nil, PhaseToolkit.AdditionalButtonFrame, "UIPanelButtonTemplate")
	PhaseOptionButton:SetSize(25, 25)
	PhaseOptionButton:SetPoint("TOP", NpcCustomPanelButton, "BOTTOM", 0, -5)
	PhaseOptionButton.icon = PhaseOptionButton:CreateTexture(nil, "OVERLAY")
	PhaseOptionButton.icon:SetTexture("Interface\\Icons\\INV_MISC_GEAR_01")
	PhaseOptionButton.icon:SetAllPoints()
	PhaseOptionButton:SetScript("OnClick", function()
		PhaseToolkit.CreatePhaseOptionFrame()
	end)

	PhaseOptionLabel = PhaseToolkit.AdditionalButtonFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	PhaseOptionLabel:SetPoint("RIGHT", PhaseOptionButton, "LEFT", -2.5, 2.5)
	PhaseOptionLabel:SetText(PhaseToolkit.CurrentLang["Phase Option"] or "Phase Options")

	local PhaseNpcList = CreateFrame("Button", nil, PhaseToolkit.AdditionalButtonFrame, "UIPanelButtonTemplate")
	PhaseNpcList:SetSize(25, 25)
	PhaseNpcList:SetPoint("TOP", PhaseOptionButton, "BOTTOM", 0, -5)
	PhaseNpcList.icon = PhaseNpcList:CreateTexture(nil, "OVERLAY")
	PhaseNpcList.icon:SetTexture("Interface\\Icons\\INV_SCROLL_08")
	PhaseNpcList.icon:SetAllPoints()
	PhaseNpcList:SetScript("OnClick", function()
		PhaseToolkit.CreateNpcListFrame(PhaseToolkit.creatureList)
	end)

	PhaseOptionLabel = PhaseToolkit.AdditionalButtonFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	PhaseOptionLabel:SetPoint("RIGHT", PhaseNpcList, "LEFT", -2.5, 2.5)
	PhaseOptionLabel:SetText(PhaseToolkit.CurrentLang["NPC List"] or "NPC List")

	local PhaseTeleList = CreateFrame("Button", nil, PhaseToolkit.AdditionalButtonFrame, "UIPanelButtonTemplate")
	PhaseTeleList:SetSize(25, 25)
	PhaseTeleList:SetPoint("TOP", PhaseNpcList, "BOTTOM", 0, -5)
	PhaseTeleList.icon = PhaseTeleList:CreateTexture(nil, "OVERLAY")
	PhaseTeleList.icon:SetTexture("Interface\\Icons\\INV_ARCHAEOLOGY_80_WITCH_BOOK")
	PhaseTeleList.icon:SetAllPoints()
	PhaseTeleList:SetScript("OnClick", function()
		PhaseToolkit.CreateTeleListFrame(PhaseToolkit.teleList)
	end)

	PhaseOptionTeleLabel = PhaseToolkit.AdditionalButtonFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	PhaseOptionTeleLabel:SetPoint("RIGHT", PhaseTeleList, "LEFT", -2.5, 2.5)
	PhaseOptionTeleLabel:SetText(PhaseToolkit.CurrentLang["Tele List"] or "Tele List")


	local ItemCreatorButton = CreateFrame("Button", nil, PhaseToolkit.AdditionalButtonFrame, "UIPanelButtonTemplate")
	ItemCreatorButton:SetSize(25, 25)
	ItemCreatorButton:SetPoint("TOP", PhaseTeleList, "BOTTOM", 0, -5)
	ItemCreatorButton.icon = ItemCreatorButton:CreateTexture(nil, "OVERLAY")
	ItemCreatorButton.icon:SetTexture("Interface\\Icons\\inv_blacksmithing_modifiedcraftingreagent_silver")
	ItemCreatorButton.icon:SetAllPoints()
	ItemCreatorButton:SetScript("OnClick", function()
		PhaseToolkit.createItemCreatorFrame()
	end)

	ItemCreatorButtonLabel = PhaseToolkit.AdditionalButtonFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	ItemCreatorButtonLabel:SetPoint("RIGHT", ItemCreatorButton, "LEFT", -2.5, 2.5)
	ItemCreatorButtonLabel:SetText(PhaseToolkit.CurrentLang["Item Creator"] or "Item Creator")

end

function PhaseToolkit.openAddCharToWhitelistFrame()
	if (PhaseToolkit.AddCharToWhitelistFrame ~= nil) then
		if (PhaseToolkit.AddCharToWhitelistFrame:IsShown()) then
			PhaseToolkit.AddCharToWhitelistFrame:Hide()
		else
			PhaseToolkit.AddCharToWhitelistFrame:Show()
		end
		return
	end

	PhaseToolkit.AddCharToWhitelistFrame=CreateFrame("Frame",nil,PhaseToolkit.ItemCreatorFrame,"BackdropTemplate")
	PhaseToolkit.AddCharToWhitelistFrame:SetSize(170, 80)
	PhaseToolkit.AddCharToWhitelistFrame:SetPoint("TOPLEFT", PhaseToolkit.NPCCustomiserMainFrame, "BOTTOMLEFT", 0, -0.5)
	PhaseToolkit.AddCharToWhitelistFrame:SetBackdrop({
		bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
		edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
		edgeSize = 16
	})

	local labelForCharAdding=PhaseToolkit.AddCharToWhitelistFrame:CreateFontString(nil,"OVERLAY","GameFontNormal")
	labelForCharAdding:SetText("Add character named :\n(Case Sensitive)")
	labelForCharAdding:SetPoint("TOP",PhaseToolkit.AddCharToWhitelistFrame,"TOP",0,-5)

	local editBoxForName=CreateFrame("EditBox",nil,PhaseToolkit.AddCharToWhitelistFrame,"InputBoxTemplate")
	editBoxForName:SetSize(150,30)
	editBoxForName:SetPoint("TOPLEFT",PhaseToolkit.AddCharToWhitelistFrame,"TOPLEFT",15,-30)
	editBoxForName:SetAutoFocus(true)
	editBoxForName:SetScript("OnEscapePressed",function(self)
		self:ClearFocus()
		self:SetText("")
		PhaseToolkit.openAddCharToWhitelistFrame()
	end)
	editBoxForName:SetScript("OnEnterPressed",function(self)
		if(self:GetText()~=nil and self:GetText()~="") then
			if(PhaseToolkit.itemCreatorData.itemLink~=nil and PhaseToolkit.itemCreatorData.itemLink~="") then
				local itemLink=" "..PhaseToolkit.itemCreatorData.itemLink.." "
				sendAddonCmd("forge item set whitelist character add"..itemLink..self:GetText())
			else
				tinsert(PhaseToolkit.itemCreatorData.whitelistedChar,self:GetText())
				PhaseToolkit.openWhitelistFor("character",true)
			end
			self:ClearFocus()
		end
		self:ClearFocus()
		self:SetText("")
		PhaseToolkit.openAddCharToWhitelistFrame()
	end)


end

function PhaseToolkit.openAddMemberToWhitelistFrame()
	if (PhaseToolkit.AddMemberToWhitelistFrame ~= nil) then
		if (PhaseToolkit.AddMemberToWhitelistFrame:IsShown()) then
			PhaseToolkit.AddMemberToWhitelistFrame:Hide()
		else
			PhaseToolkit.AddMemberToWhitelistFrame:Show()
		end
		return
	end

	PhaseToolkit.AddMemberToWhitelistFrame=CreateFrame("Frame",nil,PhaseToolkit.ItemCreatorFrame,"BackdropTemplate")
	PhaseToolkit.AddMemberToWhitelistFrame:SetSize(170, 80)
	PhaseToolkit.AddMemberToWhitelistFrame:SetPoint("TOPLEFT", PhaseToolkit.NPCCustomiserMainFrame, "BOTTOMLEFT", 0, -0.5)
	PhaseToolkit.AddMemberToWhitelistFrame:SetBackdrop({
		bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
		edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
		edgeSize = 16
	})

	local labelForPhaseMemberID=PhaseToolkit.AddMemberToWhitelistFrame:CreateFontString(nil,"OVERLAY","GameFontNormal")
	labelForPhaseMemberID:SetText("Phase ID\nMembers of this phase\nWill be whitelisted")
	labelForPhaseMemberID:SetPoint("TOP",PhaseToolkit.AddMemberToWhitelistFrame,"TOP",0,-5)

	local editBoxForPhaseId=CreateFrame("EditBox",nil,PhaseToolkit.AddMemberToWhitelistFrame,"InputBoxTemplate")
	editBoxForPhaseId:SetSize(150,30)
	editBoxForPhaseId:SetPoint("TOPLEFT",PhaseToolkit.AddMemberToWhitelistFrame,"TOPLEFT",15,-40)
	editBoxForPhaseId:SetAutoFocus(true)
	editBoxForPhaseId:SetNumeric(true)
	editBoxForPhaseId:SetScript("OnEscapePressed",function(self)
		self:ClearFocus()
		self:SetText("")
		PhaseToolkit.openAddMemberToWhitelistFrame()
	end)
	editBoxForPhaseId:SetScript("OnEnterPressed",function(self)
		if(self:GetNumber()~=nil and self:GetNumber()~=0) then

			if(PhaseToolkit.itemCreatorData.itemLink~=nil and PhaseToolkit.itemCreatorData.itemLink~="") then
				local itemLink=" "..PhaseToolkit.itemCreatorData.itemLink.." "
				sendAddonCmd("forge item set whitelist member add"..itemLink..self:GetText())
			else
				tinsert(PhaseToolkit.itemCreatorData.whitelistedPhaseForMember,self:GetText())
				PhaseToolkit.openWhitelistFor("member",true)
			end
			self:ClearFocus()
		end
		self:ClearFocus()
		self:SetText("")
		PhaseToolkit.openAddMemberToWhitelistFrame()
	end)


end

function PhaseToolkit.openAddOfficerToWhitelistFrame()
	if (PhaseToolkit.AddOfficerToWhitelistFrame ~= nil) then
		if (PhaseToolkit.AddOfficerToWhitelistFrame:IsShown()) then
			PhaseToolkit.AddOfficerToWhitelistFrame:Hide()
		else
			PhaseToolkit.AddOfficerToWhitelistFrame:Show()
		end
		return
	end

	PhaseToolkit.AddOfficerToWhitelistFrame=CreateFrame("Frame",nil,PhaseToolkit.ItemCreatorFrame,"BackdropTemplate")
	PhaseToolkit.AddOfficerToWhitelistFrame:SetSize(170, 80)
	PhaseToolkit.AddOfficerToWhitelistFrame:SetPoint("TOPLEFT", PhaseToolkit.NPCCustomiserMainFrame, "BOTTOMLEFT", 0, -0.5)
	PhaseToolkit.AddOfficerToWhitelistFrame:SetBackdrop({
		bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
		edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
		edgeSize = 16
	})

	local labelAddOfficerToWhitelistFrame=PhaseToolkit.AddOfficerToWhitelistFrame:CreateFontString(nil,"OVERLAY","GameFontNormal")
	labelAddOfficerToWhitelistFrame:SetText("Phase ID\nOfficer of this phase\nWill be whitelisted")
	labelAddOfficerToWhitelistFrame:SetPoint("TOP",PhaseToolkit.AddOfficerToWhitelistFrame,"TOP",0,-5)

	local editBoxForPhaseId=CreateFrame("EditBox",nil,PhaseToolkit.AddOfficerToWhitelistFrame,"InputBoxTemplate")
	editBoxForPhaseId:SetSize(150,30)
	editBoxForPhaseId:SetPoint("TOPLEFT",PhaseToolkit.AddOfficerToWhitelistFrame,"TOPLEFT",15,-40)
	editBoxForPhaseId:SetAutoFocus(true)
	editBoxForPhaseId:SetNumeric(true)
	editBoxForPhaseId:SetScript("OnEscapePressed",function(self)
		self:ClearFocus()
		self:SetText("")
		PhaseToolkit.openAddOfficerToWhitelistFrame()
	end)
	editBoxForPhaseId:SetScript("OnEnterPressed",function(self)
		if(self:GetNumber()~=nil and self:GetNumber()~=0) then
			if(PhaseToolkit.itemCreatorData.itemLink~=nil and PhaseToolkit.itemCreatorData.itemLink~="") then
				local itemLink=" "..PhaseToolkit.itemCreatorData.itemLink.." "
				sendAddonCmd("forge item set whitelist officer add"..itemLink..self:GetText(),nil,false)
			else
				tinsert(PhaseToolkit.itemCreatorData.whitelistedPhaseForOfficer,self:GetText())
				PhaseToolkit.openWhitelistFor("officer",true)
			end
			self:ClearFocus()
		end
		self:ClearFocus()
		self:SetText("")
		PhaseToolkit.openAddOfficerToWhitelistFrame()
	end)

end

---@param newLang string The name of the language from LangList
function PhaseToolkit.changeLang(newLang)
	--PhaseToolkit.CurrentLang = newLang
	PhaseToolkit.CurrentLang = ns.getLangTabByString(newLang) -- Since we now only pass the language name, pull the table instead
	PhaseToolkit:CreateAdditionalButtonFrame()
	PhaseToolkit:TranslateWeatherIntensity()
	if (PhaseToolkit.CustomFrame ~= nil) then
		if (PhaseToolkit.CustomFrame:IsShown()) then
			PhaseToolkit.CustomFrame:Hide()
			PhaseToolkit.CustomFrame = nil
			PhaseToolkit:CreateCustomFrame()
			PhaseToolkit.CreateCustomGrid(PhaseToolkit.InfoCustom[PhaseToolkit.GetRaceNameByID(PhaseToolkit.SelectedRace)][PhaseToolkit.SelectedGender])
			PhaseToolkit.CustomFrame:Show()
		end
	end

	if (PhaseToolkit.PhaseOptionFrame ~= nil) then
		if (PhaseToolkit.PhaseOptionFrame:IsShown()) then
			PhaseToolkit.PhaseOptionFrame:Hide()
			PhaseToolkit.PhaseOptionFrame = nil
			PhaseToolkit.CreatePhaseOptionFrame()
			PhaseToolkit.PhaseOptionFrame:Show()
		end
	end

	if (PhaseToolkit.GenreDropDown ~= nil) then
		PhaseToolkit.ShowGenderDropDown(PhaseToolkit.GenreDropDown)
	end
	if (PhaseToolkit.RaceDropDown ~= nil) then
		PhaseToolkit.ShowRaceDropDown(PhaseToolkit.RaceDropDown)
	end
	if (PhaseToolkit.MeteoDropDown ~= nil) then
		PhaseToolkit.ShowMeteoDropDown(PhaseToolkit.MeteoDropDown)
	end
	if (PhaseToolkit.PNJFrame ~= nil) then
		if (PhaseToolkit.PNJFrame:IsShown()) then
			PhaseToolkit.PNJFrame:Hide()
			PhaseToolkit.PNJFrame = nil
			PhaseToolkit.CreateNpcListFrame(PhaseToolkit.creatureList)
			PhaseToolkit.PNJFrame:Show()
		end
	end
	if (PhaseToolkit.TELEFrame ~= nil) then
		if (PhaseToolkit.TELEFrame:IsShown()) then
			PhaseToolkit.TELEFrame:Hide()
			PhaseToolkit.TELEFrame = nil
			PhaseToolkit.CreateTeleListFrame(PhaseToolkit.teleList)
			PhaseToolkit.TELEFrame:Show()
		end
	end
end

-- -- -- -- -- -- -- -- -- -- -- --
--#region Listes
-- -- -- -- -- -- -- -- -- -- -- --
local function checkIfCreatureInSelectedCategory(creature)
	if(creature) then
		if(PhaseToolkit.NPCselectedCategory) then
			for _, member in ipairs(PhaseToolkit.NPCselectedCategory.members) do
				if member == creature.IdCreature then
					return true
				end
			end
			return false
		else
			return false
		end
	else
		return false
	end
end

local function checkIfTeleInSelectedCategory(tele)
	if tele then
		if PhaseToolkit.TELEselectedCategory then
			for _, member in ipairs(PhaseToolkit.TELEselectedCategory.members) do
				if member == tele then
					return true
				end
			end
			return false
		else
			return false
		end
	else
		return false
	end
end

--- Retrieves the index of a specific member in a list of category members.
---
--- @param categoryMembersList table A list of category members to search through.
--- @param memberId any The ID of the member to find in the list.
--- @return number|nil The index of the member in the list if found, or nil if not found.
local function getIndexOfMembers(categoryMembersList,memberId)
	for index, member in ipairs(categoryMembersList) do
		if member == memberId then
			return index
		end
	end
	return -1
end
--- Checks if a string is present in an array.
---@param array table The array to search through.
---@param searchString string The string to search for.
---@return integer True if the string is found, false otherwise.
local function isStringInArray(array, searchString)
	for index, value in ipairs(array) do
		if value == searchString then
			return index;
		end
	end
	return -1;
end

--- Retrieves a creature from the creature list by its ID.
---@param npcId number The ID of the creature to retrieve.
---@return table|nil The creature object if found, or nil if not found.
function PhaseToolkit.GetCreatureById(npcId)
	for _, creature in ipairs(PhaseToolkit.creatureList) do
		if creature.IdCreature == npcId then
			return creature
		end
	end
	return nil
end
--================================= Frame pour Listes ===============================--
function PhaseToolkit.CreateNpcListFrame(_creatureList)
	if (PhaseToolkit.TELEFrame ~= nil) then
		if (PhaseToolkit.TELEFrame:IsShown()) then
			PhaseToolkit.TELEFrame:Hide()
		end
	end
	if (PhaseToolkit.PhaseOptionFrame ~= nil and PhaseToolkit.PhaseOptionFrame:IsShown()) then
		PhaseToolkit.PhaseOptionFrame:Hide()
	end
	if (PhaseToolkit.CustomFrame ~= nil and PhaseToolkit.CustomFrame:IsShown()) then
		PhaseToolkit.CustomFrame:Hide()
	end
	if (PhaseToolkit.CustomMainFrame ~= nil) then
		if (PhaseToolkit.CustomMainFrame:IsShown()) then
			PhaseToolkit.CustomMainFrame:Hide()
		end
	end
	if (PhaseToolkit.PNJFrame ~= nil) then
		if (PhaseToolkit.PNJFrame:IsShown()) then
			PhaseToolkit.PNJFrame:Hide()
			if PhaseToolkit.categoryPanelNPC ~= nil then
				PhaseToolkit.categoryPanelNPC:Hide()
				PhaseToolkit.categoryPanelNPC = nil
				for i = 1, 7 do
					local blueprintFrame = _G["PTK_CATEGORY_FRAME"..i]
					if blueprintFrame then
						blueprintFrame:Hide()
						_G["PTK_CATEGORY_FRAME"..i] = nil
					end
				end
			end
		else
			PhaseToolkit.PNJFrame:Show()
		end
		return
	end


	-- Fonction qui retourne la largeur maximale d'un nom de créature en pixels
	function PhaseToolkit.GetMaxNameWidth(creatureTable)
		-- Créer un objet FontString temporaire pour mesurer les tailles de texte
		local tempFontString = PhaseToolkit.NPCCustomiserMainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")

		-- Variable pour stocker la largeur maximale trouvée
		local maxWidth = 0

		-- Parcourir le tableau des créatures
		for _, creature in ipairs(creatureTable) do
			-- Assigner le nom de la créature au FontString
			tempFontString:SetText(creature["NomCreature"])

			-- Obtenir la largeur en pixels du nom et comparer avec la largeur maximale actuelle
			local nameWidth = tempFontString:GetStringWidth()
			if nameWidth > maxWidth then
				maxWidth = nameWidth
			end
		end

		-- Retourner la largeur maximale
		return maxWidth
	end

	local currentPage=1
	if(PhaseToolkit.NPCListCurrentPage) then
		currentPage=PhaseToolkit.NPCListCurrentPage
	end



	local totalPages = math.ceil(#PhaseToolkit.creatureList / PhaseToolkit.itemsPerPageNPC)
	if(PhaseToolkit.NPCListCurrentPage) then
		if PhaseToolkit.NPCListCurrentPage<=totalPages then
			currentPage=PhaseToolkit.NPCListCurrentPage
		else
			currentPage=totalPages
		end
	end

	function PhaseToolkit.CreerFenetreLignesParPage()
		if NewNumberOfLineframe ~= nil then
			if NewNumberOfLineframe:IsShown() then
				NewNumberOfLineframe:Hide()
				NewNumberOfLineframe = nil
			end
		end

		NewNumberOfLineframe = CreateFrame("Frame", "LignesParPageFrame", PhaseToolkit.PNJFrame, "BackdropTemplate")
		NewNumberOfLineframe:SetSize(315, 80)
		NewNumberOfLineframe:SetPoint("BOTTOM", PhaseToolkit.PNJFrame, "TOP", 0, 10)
		NewNumberOfLineframe:SetBackdrop({
			bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
			edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
			edgeSize = 16
		})

		local title = NewNumberOfLineframe:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
		title:SetPoint("TOP", 0, -10)
		title:SetText(PhaseToolkit.CurrentLang["How many lines per pages ?"] or "How many lines per pages ?")

		local editBox = CreateFrame("EditBox", nil, NewNumberOfLineframe, "InputBoxTemplate")
		editBox:SetSize(100, 30)
		editBox:SetPoint("TOP", title, "BOTTOM", 0, -10)
		editBox:SetNumeric(true)
		editBox:SetMaxLetters(2)
		editBox:SetAutoFocus(true)

		editBox:SetScript("OnEscapePressed", function()
			editBox:SetAutoFocus(false)
			editBox:ClearFocus()
		end)

		local function validerNouveauLineNumber()
			editBox:ClearFocus()
			local nombreLignes = tonumber(editBox:GetText())

			if nombreLignes and nombreLignes > 0 then
				PhaseToolkit.itemsPerPageNPC = nombreLignes
				NewNumberOfLineframe:Hide()
				PhaseToolkit.PNJFrame:Hide()
				PhaseToolkit.PNJFrame = nil
				if (PhaseToolkit.IsCurrentlyFilteringNpcViaText) then
					PhaseToolkit.CreateNpcListFrame(PhaseToolkit.filteredCreatureList)
				else
					PhaseToolkit.CreateNpcListFrame(PhaseToolkit.creatureList)
				end
			else
				print(PhaseToolkit.CurrentLang["Enter a valid number"] or "Enter a valid number")
			end
		end

		editBox:SetScript("OnEnterPressed", validerNouveauLineNumber)


		local validerButton = CreateFrame("Button", nil, NewNumberOfLineframe, "UIPanelButtonTemplate")
		validerButton:SetSize(80, 30)
		validerButton:SetPoint("LEFT", editBox, "RIGHT", 10, 0)
		validerButton:SetText(PhaseToolkit.CurrentLang["Confirm"] or "Confirm")


		validerButton:SetScript("OnClick", validerNouveauLineNumber)

		NewNumberOfLineframe:Show()
	end

	PhaseToolkit.PNJFrame = CreateFrame("Frame", "PNJListFrame", PhaseToolkit.NPCCustomiserMainFrame, "BasicFrameTemplateWithInset")
	PhaseToolkit.PNJFrame:SetSize(620, (PhaseToolkit.itemsPerPageNPC * 30) + 80)
	PhaseToolkit.PNJFrame:SetPoint("TOPLEFT", PhaseToolkit.NPCCustomiserMainFrame, "TOPRIGHT", 5, 0)
	PhaseToolkit.PNJFrame:EnableMouse(true);

	PhaseToolkit.PNJFrame:SetScript("OnHide", function()
		if PhaseToolkit.categoryPanelNPC ~= nil then
			if PhaseToolkit.categoryPanelNPC:IsShown() then
				PhaseToolkit.categoryPanelNPC:Hide()
			end
			for i = 1, 7 do
				local blueprintFrame = _G["PTK_CATEGORY_FRAME"..i]
				if blueprintFrame then
					blueprintFrame:Hide()
					_G["PTK_CATEGORY_FRAME"..i] = nil
				end
			end
		end
	end)

	local ButtonToFetch = CreateFrame("Button", nil, PhaseToolkit.PNJFrame, "UIPanelButtonTemplate")
	ButtonToFetch:SetSize(15, 15)
	ButtonToFetch:SetPoint("TOPRIGHT", PhaseToolkit.PNJFrame, "TOPRIGHT", -30, -3.5)
	ButtonToFetch.icon = ButtonToFetch:CreateTexture(nil, "OVERLAY")
	ButtonToFetch.icon:SetAtlas("poi-door-arrow-down")
	ButtonToFetch.icon:SetSize(14, 14)
	ButtonToFetch.icon:SetPoint("CENTER", ButtonToFetch, "CENTER", 0, 0)
	ButtonToFetch:SetScript("OnClick", function()
		PhaseToolkit.IsCurrentlyFilteringNpcViaText = false
		PhaseToolkit.filteredCreatureList = {}
		PhaseToolkit.NPCListCurrentPage=currentPage
		if PhaseToolkit.categoryPanelNPC then
			PhaseToolkit.categoryPanelNPC:Hide()
			for i = 1, 7 do
				local blueprintFrame = _G["PTK_CATEGORY_FRAME"..i]
				if blueprintFrame then
					blueprintFrame:Hide()
					_G["PTK_CATEGORY_FRAME"..i] = nil
				end
			end
		end
		PhaseToolkit.PhaseNpcListSystemMessageCounter()
	end)
	PhaseToolkit.RegisterTooltip(ButtonToFetch, "Fetch Npc List info")

	local CategoryButton=CreateFrame("Button", nil, PhaseToolkit.PNJFrame, "UIPanelButtonTemplate")
	CategoryButton:SetSize(15, 15)
	CategoryButton:SetPoint("LEFT", ButtonToFetch, "LEFT", -20, 0)
	CategoryButton.icon = CategoryButton:CreateTexture(nil, "OVERLAY")
	CategoryButton.icon:SetAtlas("adventureguide-icon-whatsnew")
	CategoryButton.icon:SetSize(14, 14)
	CategoryButton.icon:SetPoint("CENTER", CategoryButton, "CENTER", 0, 0)
	CategoryButton:SetScript("OnClick", function()
		PhaseToolkit.openNpcCategoryPanel()
	end)
	PhaseToolkit.RegisterTooltip(CategoryButton, "Open the Category Panel")

	local ButtonToChangeNumberOfLine = CreateFrame("Button", nil, PhaseToolkit.PNJFrame, "UIPanelButtonTemplate")
	ButtonToChangeNumberOfLine:SetSize(15, 15)
	ButtonToChangeNumberOfLine:SetPoint("TOPLEFT", PhaseToolkit.PNJFrame, "TOPLEFT", 5, -3.5)
	ButtonToChangeNumberOfLine.icon = ButtonToChangeNumberOfLine:CreateTexture(nil, "OVERLAY")
	ButtonToChangeNumberOfLine.icon:SetTexture("Interface\\Icons\\trade_engineering")
	ButtonToChangeNumberOfLine.icon:SetAllPoints()
	ButtonToChangeNumberOfLine:SetScript("OnClick", PhaseToolkit.CreerFenetreLignesParPage)

	local function collectAllNpcsFromCategories()
		local allNpcs = {}
		if PhaseToolkit.NPCcategoryToFilterPool and #PhaseToolkit.NPCcategoryToFilterPool > 0 then
			for _,categoryID in ipairs(PhaseToolkit.NPCcategoryToFilterPool) do
				local category = PhaseToolkit.getCategoryByIdGENERIC(categoryID,"NPC")
				if category and category.members then
					for _,npcId in ipairs(category.members) do
						local npc = PhaseToolkit.GetCreatureById(npcId)
						if npc then
							-- Check if the NPC is already in the list
							local isAlreadyInList = false
							for _,existingNpc in ipairs(allNpcs) do
								if existingNpc.IdCreature == npc.IdCreature then
									isAlreadyInList = true
									break
								end
							end
							-- If not, add it to the list
							if not isAlreadyInList then
								table.insert(allNpcs, npc)
							end
						end
					end
				end
			end

		end
		return allNpcs
	end

	local function SearchAndFindNpcByText(self)
		if self:GetText() ~= nil and self:GetText() ~= "" then
			local sourceList = PhaseToolkit.creatureList
			if(PhaseToolkit.categoryPanelNPC and PhaseToolkit.NPCcategoryToFilterPool and #PhaseToolkit.NPCcategoryToFilterPool>0) then
				sourceList=collectAllNpcsFromCategories()
			end
			PhaseToolkit.filteredCreatureList = {}
			PhaseToolkit.CurrenttextToLookForNpc = self:GetText()
			PhaseToolkit.IsCurrentlyFilteringNpcViaText = true

			for _, creature in ipairs(sourceList) do
				if string.find(string.lower(creature["NomCreature"]), string.lower(PhaseToolkit.CurrenttextToLookForNpc)) then
					table.insert(PhaseToolkit.filteredCreatureList, creature)
				end
			end
			PhaseToolkit.PNJFrame:Hide()
			PhaseToolkit.PNJFrame = nil
			PhaseToolkit.CreateNpcListFrame(PhaseToolkit.filteredCreatureList)
		elseif self:GetText() == "" and PhaseToolkit.IsCurrentlyFilteringNpcViaText == true then
			local sourceList = PhaseToolkit.creatureList
			if(PhaseToolkit.categoryPanelNPC and PhaseToolkit.NPCcategoryToFilterPool and #PhaseToolkit.NPCcategoryToFilterPool>0) then
				sourceList=collectAllNpcsFromCategories()
			end
			PhaseToolkit.PNJFrame:Hide()
			PhaseToolkit.PNJFrame = nil
			PhaseToolkit.CurrenttextToLookForNpc = ""
			PhaseToolkit.IsCurrentlyFilteringNpcViaText = false
			PhaseToolkit.CreateNpcListFrame(sourceList)
		end
	end

	if (PhaseToolkit.creatureList ~= nil and PhaseToolkit.IsTableEmpty(PhaseToolkit.creatureList) == false) then
		PhaseToolkit.LookupInNpcListEditBox = CreateFrame("EditBox", nil, PhaseToolkit.PNJFrame, "InputBoxTemplate")

		if (PhaseToolkit.GetMaxNameWidth(PhaseToolkit.creatureList) < 190) then
			PhaseToolkit.LookupInNpcListEditBox:SetSize(190, 20)
		else

			PhaseToolkit.LookupInNpcListEditBox:SetSize(PhaseToolkit.GetMaxNameWidth(PhaseToolkit.creatureList) - 50, 20)
		end

		PhaseToolkit.LookupInNpcListEditBox:SetPoint("LEFT", ButtonToChangeNumberOfLine, "RIGHT", 10, -0.5)
		PhaseToolkit.LookupInNpcListEditBox:SetAutoFocus(false)
		if (PhaseToolkit.CurrenttextToLookForNpc ~= nil and PhaseToolkit.CurrenttextToLookForNpc ~= "") then
			PhaseToolkit.LookupInNpcListEditBox:SetText(PhaseToolkit.CurrenttextToLookForNpc)
			PhaseToolkit.LookupInNpcListEditBox:SetFocus()
		end

		PhaseToolkit.LookupInNpcListEditBox:SetScript("OnEnterPressed", SearchAndFindNpcByText)
	end

	local PNJRows = {}

	local function OnSpawnClick(pnjId)
		sendAddonCmd("n spawn " .. pnjId, nil)
	end

	local function GetNpcById( npcId)
		for _, npc in ipairs(PhaseToolkit.creatureList) do
			if npc["IdCreature"] == npcId then
				return npc
			end
		end
		return nil
	end

	local function OnDeleteClick(pnjId)
		local creature = GetNpcById(pnjId)
		StaticPopupDialogs["CONFIRM_DELETE_NPC"] = {
			text = "Are you sure you want to delete "..creature["NomCreature"] .. "?",
			button1 = "Yes",
			button2 = "No",
			OnAccept = function(self, data)
				sendAddonCmd("ph forge npc delete " .. data.pnjId, nil, false)
				PhaseToolkit.RemoveCreatureById(PhaseToolkit.creatureList, data.pnjId)
				if(PhaseToolkit.IsCurrentlyFilteringNpcViaText or PhaseToolkit.IsCurrentlyFilteringNpcViaCategory) then
					PhaseToolkit.UpdatePNJPagination(PhaseToolkit.filteredCreatureList)
				else
					PhaseToolkit.UpdatePNJPagination(PhaseToolkit.creatureList)
				end
			end,
			timeout = 0,
			whileDead = true,
			hideOnEscape = true,
			preferredIndex = 3,
		}
		StaticPopup_Show("CONFIRM_DELETE_NPC", nil, nil, { pnjId = pnjId, creature = creature })
	end

	for i = 1, PhaseToolkit.itemsPerPageNPC do
		local row = CreateFrame("Frame", nil, PhaseToolkit.PNJFrame)
		row:SetSize(500, 30)
		row:SetPoint("TOPLEFT", PhaseToolkit.PNJFrame, "TOPLEFT", 10, -15 * i - (i * 15))

		row.name = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
		row.name:SetPoint("LEFT", row, "LEFT", 10, 0)

		row.spawnButton = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
		row.spawnButton:SetSize(80, 30)
		row.spawnButton:SetPoint("TOPRIGHT", PhaseToolkit.PNJFrame, "TOPRIGHT", -100, -15 * i - (i * 15))

		row.spawnButton:SetText("Spawn")

		row.deleteButton = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
		row.deleteButton:SetSize(80, 30)
		row.deleteButton:SetPoint("LEFT", row.spawnButton, "RIGHT", 10, 0)
		row.deleteButton:SetText(PhaseToolkit.CurrentLang["Delete"] or "Delete")

		row.addToCategoryButton = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
		row.addToCategoryButton:SetSize(30, 30)
		row.addToCategoryButton:SetPoint("LEFT", row.deleteButton, "RIGHT", 10, 0)

		row.addToCategoryButton.icon = row.addToCategoryButton:CreateTexture(nil, "OVERLAY")
		row.addToCategoryButton.icon:SetAtlas("GarrMission_CurrencyIcon-Material")
		row.addToCategoryButton.icon:SetSize(28, 28)
		row.addToCategoryButton.icon:SetPoint("CENTER", row.addToCategoryButton, "CENTER", 0, 0)
		row.addToCategoryButton:Hide()

		row.getOutOfCategoryButton=CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
		row.getOutOfCategoryButton:SetSize(30, 30)
		row.getOutOfCategoryButton:SetPoint("LEFT", row.addToCategoryButton, "RIGHT", 10, 0)
		row.getOutOfCategoryButton.icon = row.getOutOfCategoryButton:CreateTexture(nil, "OVERLAY")
		row.getOutOfCategoryButton.icon:SetAtlas("poi-traveldirections-arrow2")
		row.getOutOfCategoryButton.icon:SetTexCoord(1, 0, 0, 1)
		row.getOutOfCategoryButton.icon:SetSize(28, 28)
		row.getOutOfCategoryButton.icon:SetPoint("CENTER", row.getOutOfCategoryButton, "CENTER", 0, 0)
		row.getOutOfCategoryButton:Hide()
		row.addToCategoryButton:Disable()
		row.getOutOfCategoryButton:Disable()

		PhaseToolkit.RegisterTooltip(row.addToCategoryButton,"add to selected category")
		PhaseToolkit.RegisterTooltip(row.getOutOfCategoryButton,"remove from selected category")

		PNJRows[i] = row
	end

	function PhaseToolkit.DisplayNpcPage(creatureList)
		-- Calcul des indices de la page actuelle
		local startIndex = (currentPage - 1) * PhaseToolkit.itemsPerPageNPC + 1
		local endIndex = math.min(currentPage * PhaseToolkit.itemsPerPageNPC, #creatureList)

		local isAlreadyBiggerForAddToCategory=false
		local isAlreadyBiggerForGetOutOfCategory=false

		-- Calculer la largeur maximale des noms pour la page actuelle
		local pageCreatureList = {}
		for i = startIndex, endIndex do
			table.insert(pageCreatureList, creatureList[i])
		end

		local maxNameWidth = PhaseToolkit.GetMaxNameWidth(pageCreatureList)

		-- Ajuster la largeur de la GlobalNPCCUSTOMISER_PNJFrame en fonction de la largeur maximale des noms
		local frameWidth = maxNameWidth + 190 -- 180 pour les boutons et marges
		if PhaseToolkit.LookupInNpcListEditBox then
			PhaseToolkit.LookupInNpcListEditBox:SetWidth(maxNameWidth - 10) -- Ajuster la largeur de la zone de recherche
		end
		PhaseToolkit.PNJFrame:SetWidth(frameWidth + 30 * 2)
		if PhaseToolkit.categoryPanelNPC and PhaseToolkit.NPCselectedCategory then
			PhaseToolkit.categoryPanelNPC:SetPoint("TOPLEFT", PhaseToolkit.PNJFrame, "TOPRIGHT", 5, 0)
		end

		local generaloffset =-100
		for _, creature in ipairs(pageCreatureList) do
			if checkIfCreatureInSelectedCategory(creature) then
				generaloffset = -190
				break
			end
		end

		if PhaseToolkit.categoryPanelNPC and PhaseToolkit.NPCselectedCategory  and generaloffset>(-190) then
			generaloffset = -145
		end
		-- Affichage des PNJ sur la page
		for i = 1, PhaseToolkit.itemsPerPageNPC do
			local idx = startIndex + i - 1
			local row = PNJRows[i]
			if idx <= endIndex then
				local creature = creatureList[idx]
				row.name:SetText(creature["NomCreature"]) -- Affiche le nom de la créature
				row:Show()

				-- Associe l'ID de la créature aux boutons "Spawn" et "Delete"
				row.spawnButton:SetScript("OnClick", function() OnSpawnClick(creature["IdCreature"]) end)
				row.deleteButton:SetScript("OnClick", function() OnDeleteClick(creature["IdCreature"]) end)

				if PhaseToolkit.categoryPanelNPC and PhaseToolkit.NPCselectedCategory and PhaseToolkit.UserHasPermission() then

					row.addToCategoryButton:Show()
					row.addToCategoryButton:Enable()
					row.addToCategoryButton:SetScript("OnClick", function()
						if(PhaseToolkit.categoryPanelNPC and PhaseToolkit.NPCselectedCategory) then
							if isStringInArray(PhaseToolkit.NPCselectedCategory.members, creature["IdCreature"]) <0 then
								tinsert(PhaseToolkit.NPCselectedCategory.members, creature["IdCreature"])
								PhaseToolkit.updateNPCCategoryList()
								if(PhaseToolkit.IsCurrentlyFilteringNpcViaText) then
									PhaseToolkit.UpdatePNJPagination(PhaseToolkit.filteredCreatureList)
								else
									PhaseToolkit.UpdatePNJPagination(PhaseToolkit.creatureList)
								end
								PhaseToolkit.saveNpcCategoryDataToServer()
							end
						end
					end)
					if(not isAlreadyBiggerForAddToCategory) then
						PhaseToolkit.PNJFrame:SetWidth(PhaseToolkit.PNJFrame:GetWidth()+45)
						isAlreadyBiggerForAddToCategory=true
					end
				else
					row.spawnButton:SetPoint("TOPRIGHT", PhaseToolkit.PNJFrame, "TOPRIGHT", generaloffset, -15 * i - (i * 15))
					row.addToCategoryButton:Hide()
				end

				if(PhaseToolkit.categoryPanelNPC and PhaseToolkit.NPCselectedCategory and PhaseToolkit.UserHasPermission() and checkIfCreatureInSelectedCategory(creature)) then
					row.getOutOfCategoryButton:Show()
					row.getOutOfCategoryButton:Enable()
					row.getOutOfCategoryButton:SetScript("OnClick", function()
					if(PhaseToolkit.categoryPanelNPC and PhaseToolkit.NPCselectedCategory) then
						local indexToDelete=getIndexOfMembers(PhaseToolkit.NPCselectedCategory.members, creature["IdCreature"])
						if(indexToDelete >0) then
							table.remove(PhaseToolkit.NPCselectedCategory.members,indexToDelete)
							PhaseToolkit.updateNPCCategoryList()
							if(PhaseToolkit.IsCurrentlyFilteringNpcViaText) then
								PhaseToolkit.UpdatePNJPagination(PhaseToolkit.filteredCreatureList)
							else
								PhaseToolkit.UpdatePNJPagination(PhaseToolkit.creatureList)
							end
							PhaseToolkit.saveNpcCategoryDataToServer()
						end
					end
					end)
					if(not isAlreadyBiggerForGetOutOfCategory) then
						PhaseToolkit.PNJFrame:SetWidth(PhaseToolkit.PNJFrame:GetWidth() + 90)
						isAlreadyBiggerForGetOutOfCategory=true
					end
					--row.spawnButton:SetPoint("TOPRIGHT", PhaseToolkit.PNJFrame, "TOPRIGHT", -190, -15 * i - (i * 15))
				else
					--row.spawnButton:SetPoint("TOPRIGHT", PhaseToolkit.PNJFrame, "TOPRIGHT", -100, -15 * i - (i * 15))
					row.getOutOfCategoryButton:Hide()

				end
				row.spawnButton:SetPoint("TOPRIGHT", PhaseToolkit.PNJFrame, "TOPRIGHT", generaloffset, -15 * i - (i * 15))
			else
				row:Hide()
			end
		end
		isAlreadyBiggerForGetOutOfCategory=false
		isAlreadyBiggerForAddToCategory=false

		if totalPages >0 and currentPage > totalPages and PhaseToolkit.categoryPanelNPC and PhaseToolkit.NPCcategoryToFilterPool and #PhaseToolkit.NPCcategoryToFilterPool > 0 then
			currentPage = 1
			NpcCurrentPageeditBox:SetText(currentPage)
			PhaseToolkit.NPCListCurrentPage = currentPage
			PhaseToolkit.UpdatePNJPagination(collectAllNpcsFromCategories())
		end
	end



	local prevButton = CreateFrame("Button", nil, PhaseToolkit.PNJFrame, "UIPanelButtonTemplate")
	prevButton:SetSize(80, 30)
	prevButton:SetPoint("BOTTOMLEFT", PhaseToolkit.PNJFrame, "BOTTOMLEFT", 10, 10)
	prevButton:SetText(PhaseToolkit.CurrentLang["Prev"])

	NpcCurrentPageeditBox = CreateFrame("EditBox", nil, PhaseToolkit.PNJFrame, "InputBoxTemplate")
	NpcCurrentPageeditBox:SetSize(30, 30)
	NpcCurrentPageeditBox:SetPoint("LEFT", prevButton, "RIGHT", 10, 0)
	NpcCurrentPageeditBox:SetNumeric(true)
	NpcCurrentPageeditBox:SetAutoFocus(false)
	NpcCurrentPageeditBox:SetNumber(currentPage)


	NumberOfPageMaxLabelNPC = PhaseToolkit.PNJFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	NumberOfPageMaxLabelNPC:SetText("/ " .. totalPages)
	NumberOfPageMaxLabelNPC:SetPoint("LEFT", NpcCurrentPageeditBox, "RIGHT", 0, 0)

	NpcCurrentPageeditBox:SetScript("OnEscapePressed", function()
		NpcCurrentPageeditBox:SetAutoFocus(false)
		NpcCurrentPageeditBox:ClearFocus()
	end)

	NpcCurrentPageeditBox:SetScript("OnEnterPressed", function()
		if NpcCurrentPageeditBox:GetText() ~= "" and tonumber(NpcCurrentPageeditBox:GetText()) ~= 0 and tonumber(NpcCurrentPageeditBox:GetText()) <= totalPages then
			currentPage = NpcCurrentPageeditBox:GetNumber()
			NpcCurrentPageeditBox:SetNumber(currentPage)
			PhaseToolkit.NPCListCurrentPage=currentPage
			if (PhaseToolkit.IsCurrentlyFilteringNpcViaText) then
				PhaseToolkit.UpdatePNJPagination(PhaseToolkit.filteredCreatureList)
			else
				PhaseToolkit.UpdatePNJPagination(PhaseToolkit.creatureList)
			end
			NpcCurrentPageeditBox:ClearFocus()
		end
	end)

	local nextButton = CreateFrame("Button", nil, PhaseToolkit.PNJFrame, "UIPanelButtonTemplate")
	nextButton:SetSize(80, 30)
	nextButton:SetPoint("LEFT", prevButton, "RIGHT", 70, 0)
	nextButton:SetText(PhaseToolkit.CurrentLang["Next"])

	function PhaseToolkit.UpdatePNJPagination(creatureList)
		totalPages = math.ceil(#creatureList / PhaseToolkit.itemsPerPageNPC)

		-- Mise à jour de l'état des boutons de navigation
		if currentPage <= 1 then
			prevButton:Disable()
		else
			prevButton:Enable()
		end

		if currentPage >= totalPages then
			nextButton:Disable()
		else
			nextButton:Enable()
		end

		-- Affichage de la page actuelle
		PhaseToolkit.DisplayNpcPage(creatureList)
		NumberOfPageMaxLabelNPC:SetText("/ " .. totalPages)
	end

	nextButton:SetScript("OnClick", function()
		if currentPage < totalPages then
			currentPage = currentPage + 1
			NpcCurrentPageeditBox:SetText(currentPage)
			PhaseToolkit.NPCListCurrentPage=currentPage
			if PhaseToolkit.categoryPanelNPC and PhaseToolkit.NPCcategoryToFilterPool and #PhaseToolkit.NPCcategoryToFilterPool > 0 then
				PhaseToolkit.UpdatePNJPagination(collectAllNpcsFromCategories())
			else
				PhaseToolkit.UpdatePNJPagination(_creatureList)
			end
		end
	end)

	prevButton:SetScript("OnClick", function()
		if currentPage > 1 then
			currentPage = currentPage - 1
			NpcCurrentPageeditBox:SetText(currentPage)
			PhaseToolkit.NPCListCurrentPage=currentPage
			if PhaseToolkit.categoryPanelNPC and PhaseToolkit.NPCcategoryToFilterPool and #PhaseToolkit.NPCcategoryToFilterPool > 0 then
				PhaseToolkit.UpdatePNJPagination(collectAllNpcsFromCategories())
			else
				PhaseToolkit.UpdatePNJPagination(_creatureList)
			end
		end
	end)

	PhaseToolkit.PNJFrame:SetScript("OnShow", function()
		currentPage = 1
		if(PhaseToolkit.NPCListCurrentPage) then
			currentPage=PhaseToolkit.NPCListCurrentPage
		end
		PhaseToolkit.UpdatePNJPagination(_creatureList)
	end)

	if PhaseToolkit.categoryPanelNPC and PhaseToolkit.NPCcategoryToFilterPool and #PhaseToolkit.NPCcategoryToFilterPool > 0 then
		PhaseToolkit.UpdatePNJPagination(collectAllNpcsFromCategories())
	else
		PhaseToolkit.UpdatePNJPagination(_creatureList)
	end
end

local function parseReplies(isCommandSuccessful, repliesList)
	-- Only do the job if the command is successful
	if (isCommandSuccessful) then
		local isCallingAgainNeeded = false
		for i = 1, #repliesList do
			message = repliesList[i]
			message = message:gsub("|cff%x%x%x%x%x%x", ""):gsub("|r", "")

			isCallingAgainNeeded = string.find(message, ".phase forge npc list") ~= nil
			local isPhaseNameAndPhaseId = string.find(message, "Forged NPCs for") ~= nil
			local pos = string.find(message, "-")
			if pos and not isPhaseNameAndPhaseId then
				-- get the creature ID
				local id = string.sub(message, 1, pos - 1)

				-- get the Creature Name
				local Name = string.sub(message, pos + 1)
				Name = Name:gsub("%[", ""):gsub("%]", "")

				table.insert(PhaseToolkit.creatureList, { ["IdCreature"] = id, ["NomCreature"] = Name })
			end
		end
		-- if there is more than 1 page (of course) we call the same func with the next replies
		if isCallingAgainNeeded then
			sendAddonCmd("ph f n list next", function(success, replies) parseReplies(success, replies) end, false)
		else
			-- if it's finished, we remove potential duplicate (by ID) and then we "regenerates" the frame for the list
			PhaseToolkit.creatureList = PhaseToolkit.RemoveDuplicates(PhaseToolkit.creatureList)
			if (PhaseToolkit.PNJFrame ~= nil) then
				if PhaseToolkit.PNJFrame:IsShown() then
					PhaseToolkit.PNJFrame:Hide()
					PhaseToolkit.PNJFrame = nil
					PhaseToolkit.CreateNpcListFrame(PhaseToolkit.creatureList)
				else
					PhaseToolkit.PNJFrame = nil
					PhaseToolkit.CreateNpcListFrame(PhaseToolkit.creatureList)
				end
			end
		end
	end
end

function PhaseToolkit.PhaseNpcListSystemMessageCounter()
	PhaseToolkit.creatureList = {}
	-- Use Epsilib to fetch the replies
	sendAddonCmd("ph f n list", parseReplies, false)
end
-- -- -- -- -- -- -- -- -- --
	--#endregion
-- -- -- -- -- -- -- -- -- --

-- -- -- -- -- -- -- -- -- --
	--#region TeleList
-- -- -- -- -- -- -- -- -- --

function PhaseToolkit.CreateTeleListFrame(_teleList)
	if (PhaseToolkit.PNJFrame ~= nil) then
		if (PhaseToolkit.PNJFrame:IsShown()) then
			PhaseToolkit.PNJFrame:Hide()
		end
	end
	if (PhaseToolkit.PhaseOptionFrame ~= nil and PhaseToolkit.PhaseOptionFrame:IsShown()) then
		PhaseToolkit.PhaseOptionFrame:Hide()
	end
	if (PhaseToolkit.CustomFrame ~= nil and PhaseToolkit.CustomFrame:IsShown()) then
		PhaseToolkit.CustomFrame:Hide()
	end
	if (PhaseToolkit.CustomMainFrame ~= nil) then
		if (PhaseToolkit.CustomMainFrame:IsShown()) then
			PhaseToolkit.CustomMainFrame:Hide()
		end
	end
	if (PhaseToolkit.TELEFrame ~= nil) then
		if (PhaseToolkit.TELEFrame:IsShown()) then
			PhaseToolkit.TELEFrame:Hide()
			if PhaseToolkit.categoryPanelTELE ~= nil then
				PhaseToolkit.categoryPanelTELE:Hide()
				PhaseToolkit.categoryPanelTELE = nil
				for i = 1, 7 do
					local blueprintFrame = _G["PTK_CATEGORY_FRAME"..i]
					if blueprintFrame then
						blueprintFrame:Hide()
						_G["PTK_CATEGORY_FRAME"..i] = nil
					end
				end
			end
		else
			PhaseToolkit.TELEFrame:SetSize(PhaseToolkit.GetMaxStringWidth(PhaseToolkit.teleList), 400)
			PhaseToolkit.TELEFrame:Show()
		end
		return
	end

	local currentPage=1
	if(PhaseToolkit.TELEListcurrentPage) then
		currentPage=PhaseToolkit.TELEListcurrentPage
	end

	local totalPages = math.ceil(#PhaseToolkit.teleList / PhaseToolkit.itemsPerPageTELE)
	if(PhaseToolkit.TELEListcurrentPage) then
		if PhaseToolkit.TELEListcurrentPage<=totalPages then
			currentPage=PhaseToolkit.TELEListcurrentPage
		else
			currentPage=totalPages
		end
	end

	function PhaseToolkit.CreerFenetreLignesParPage()
		if NewNumberOfLineframe ~= nil then
			if NewNumberOfLineframe:IsShown() then
				NewNumberOfLineframe:Hide()
				NewNumberOfLineframe = nil
			end
		end

		NewNumberOfLineframe = CreateFrame("Frame", "LignesParPageFrame", PhaseToolkit.TELEFrame, "BackdropTemplate")
		NewNumberOfLineframe:SetSize(315, 80)
		NewNumberOfLineframe:SetPoint("BOTTOM", PhaseToolkit.TELEFrame, "TOP", 0, 10)
		NewNumberOfLineframe:SetBackdrop({
			bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
			edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
			edgeSize = 16
		})

		local title = NewNumberOfLineframe:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
		title:SetPoint("TOP", 0, -10)
		title:SetText(PhaseToolkit.CurrentLang["How many lines per pages ?"] or "How many lines per pages ?")

		local editBox = CreateFrame("EditBox", nil, NewNumberOfLineframe, "InputBoxTemplate")
		editBox:SetSize(100, 30)
		editBox:SetPoint("TOP", title, "BOTTOM", 0, -10)
		editBox:SetNumeric(true)
		editBox:SetMaxLetters(2)
		editBox:SetAutoFocus(true)

		editBox:SetScript("OnEscapePressed", function()
			editBox:SetAutoFocus(false)
			editBox:ClearFocus()
		end)

		local function validerNouveauLineNumber()
			editBox:ClearFocus()
			local nombreLignes = tonumber(editBox:GetText())

			if nombreLignes and nombreLignes > 0 then
				PhaseToolkit.itemsPerPageTELE = nombreLignes
				NewNumberOfLineframe:Hide()
				PhaseToolkit.TELEFrame:Hide()
				PhaseToolkit.TELEFrame = nil

				if (PhaseToolkit.IsCurrentlyFilteringTeleViaText) then
					PhaseToolkit.CreateTeleListFrame(PhaseToolkit.filteredTeleList)
				else
					PhaseToolkit.CreateTeleListFrame(PhaseToolkit.teleList)
				end
			else
				print(PhaseToolkit.CurrentLang["Enter a valid number"] or "Enter a valid number")
			end
		end

		editBox:SetScript("OnEnterPressed", validerNouveauLineNumber)


		local validerButton = CreateFrame("Button", nil, NewNumberOfLineframe, "UIPanelButtonTemplate")
		validerButton:SetSize(80, 30)
		validerButton:SetPoint("LEFT", editBox, "RIGHT", 10, 0)
		validerButton:SetText(PhaseToolkit.CurrentLang["Confirm"] or "Confirm")


		validerButton:SetScript("OnClick", validerNouveauLineNumber)

		NewNumberOfLineframe:Show()
	end


	-- Création de la frame principale pour afficher la liste des PNJ
	PhaseToolkit.TELEFrame = CreateFrame("Frame", nil, PhaseToolkit.NPCCustomiserMainFrame, "BasicFrameTemplateWithInset")
	PhaseToolkit.TELEFrame:SetSize(600, (PhaseToolkit.itemsPerPageTELE * 30) + 80)
	PhaseToolkit.TELEFrame:SetPoint("TOPLEFT", PhaseToolkit.NPCCustomiserMainFrame, "TOPRIGHT", 5, 0)
	PhaseToolkit.TELEFrame:EnableMouse(true)

	PhaseToolkit.TELEFrame:SetScript("OnHide", function()
		if PhaseToolkit.categoryPanelTELE ~= nil then
			if PhaseToolkit.categoryPanelTELE:IsShown() then
				PhaseToolkit.categoryPanelTELE:Hide()
			end
			for i = 1, 7 do
				local blueprintFrame = _G["PTK_CATEGORY_FRAME"..i]
				if blueprintFrame then
					blueprintFrame:Hide()
					_G["PTK_CATEGORY_FRAME"..i] = nil
				end
			end
		end
	end)

	local ButtonToFetch = CreateFrame("Button", nil, PhaseToolkit.TELEFrame, "UIPanelButtonTemplate")
	ButtonToFetch:SetSize(15, 15)
	ButtonToFetch:SetPoint("TOPRIGHT", PhaseToolkit.TELEFrame, "TOPRIGHT", -30, -3.5)
	ButtonToFetch.icon = ButtonToFetch:CreateTexture(nil, "OVERLAY")
	ButtonToFetch.icon:SetAtlas("poi-door-arrow-down")
	ButtonToFetch.icon:SetSize(14, 14);
	ButtonToFetch.icon:SetPoint("CENTER", ButtonToFetch, "CENTER", 0, 0);
	ButtonToFetch:SetScript("OnClick", function()
		PhaseToolkit.IsCurrentlyFilteringTeleViaText = false;
		PhaseToolkit.filteredTeleList = {};
		PhaseToolkit.TELEListcurrentPage=currentPage;
		if PhaseToolkit.categoryPanelTELE then
			PhaseToolkit.categoryPanelTELE:Hide();
			for i = 1, 7 do
				local blueprintFrame = _G["PTK_CATEGORY_FRAME"..i];
				if blueprintFrame then
					blueprintFrame:Hide();
					_G["PTK_CATEGORY_FRAME"..i] = nil;
				end
			end
		end
		PhaseToolkit.PhaseTeleListSystemMessageCounter();
	end)
	PhaseToolkit.RegisterTooltip(ButtonToFetch, "Fetch Tele list");

	local CategoryButton=CreateFrame("Button", nil, PhaseToolkit.TELEFrame, "UIPanelButtonTemplate");
	CategoryButton:SetSize(15, 15);
	CategoryButton:SetPoint("LEFT", ButtonToFetch, "LEFT", -20, 0);
	CategoryButton.icon = CategoryButton:CreateTexture(nil, "OVERLAY");
	CategoryButton.icon:SetAtlas("adventureguide-icon-whatsnew");
	CategoryButton.icon:SetSize(14, 14);
	CategoryButton.icon:SetPoint("CENTER", CategoryButton, "CENTER", 0, 0);
	CategoryButton:SetScript("OnClick", function()
		PhaseToolkit.openTeleCategoryPanel();
	end);
	PhaseToolkit.RegisterTooltip(CategoryButton, "Open the Category Panel")

	local ButtonToChangeNumberOfLine = CreateFrame("Button", nil, PhaseToolkit.TELEFrame, "UIPanelButtonTemplate")
	ButtonToChangeNumberOfLine:SetSize(15, 15)
	ButtonToChangeNumberOfLine:SetPoint("TOPLEFT", PhaseToolkit.TELEFrame, "TOPLEFT", 5, -5)
	ButtonToChangeNumberOfLine.icon = ButtonToChangeNumberOfLine:CreateTexture(nil, "OVERLAY")
	ButtonToChangeNumberOfLine.icon:SetTexture("Interface\\Icons\\trade_engineering")
	ButtonToChangeNumberOfLine.icon:SetAllPoints()
	ButtonToChangeNumberOfLine:SetScript("OnClick", PhaseToolkit.CreerFenetreLignesParPage)
	PhaseToolkit.RegisterTooltip(ButtonToChangeNumberOfLine, "Change list size")


	local function mergeAllTeleMembers()
		local mergedTeleList = {}
		for _, categoryID in ipairs(PhaseToolkit.TELEcategoryToFilterPool) do
			local category = PhaseToolkit.getCategoryByIdGENERIC(categoryID,"TELE")
			if category then
				for _, member in ipairs(category.members) do
					if isStringInArray(mergedTeleList, member)<0 then
						table.insert(mergedTeleList, member)
					end
				end
			end
		end
		return mergedTeleList
	end

	local function SearchAndFindTeleByText(self)
		if self:GetText() ~= nil and self:GetText() ~= "" then
			local sourceList = PhaseToolkit.creatureList
			if(PhaseToolkit.categoryPanelTELE and PhaseToolkit.TELEcategoryToFilterPool and #PhaseToolkit.TELEcategoryToFilterPool>0) then
				sourceList=mergeAllTeleMembers()
			end
			PhaseToolkit.filteredTeleList = {}
			CurrenttextToLookForTele = self:GetText()
			PhaseToolkit.IsCurrentlyFilteringTeleViaText = true

			for i = 1, #sourceList do
				if string.find(sourceList[i], CurrenttextToLookForTele) then
					table.insert(PhaseToolkit.filteredTeleList, sourceList[i])
				end
			end

			PhaseToolkit.TELEFrame:Hide()
			PhaseToolkit.TELEFrame = nil
			PhaseToolkit.CreateTeleListFrame(PhaseToolkit.filteredTeleList)
		elseif self:GetText() == "" and PhaseToolkit.IsCurrentlyFilteringTeleViaText == true then
			local sourceList = PhaseToolkit.teleList
			if(PhaseToolkit.categoryPanelTELE and PhaseToolkit.TELEcategoryToFilterPool and #PhaseToolkit.TELEcategoryToFilterPool>0) then
				sourceList=mergeAllTeleMembers()
			end
			PhaseToolkit.TELEFrame:Hide()
			PhaseToolkit.TELEFrame = nil
			CurrenttextToLookForTele = ""
			PhaseToolkit.IsCurrentlyFilteringTeleViaText = false
			PhaseToolkit.CreateTeleListFrame(sourceList)
		end
	end

	if (PhaseToolkit.teleList ~= nil and PhaseToolkit.IsTableEmpty(PhaseToolkit.teleList) == false) then
		PhaseToolkit.LookupInTeleListEditBox = CreateFrame("EditBox", nil, PhaseToolkit.TELEFrame, "InputBoxTemplate")

		if (PhaseToolkit.GetMaxStringWidth(PhaseToolkit.teleList) < 80) then
			PhaseToolkit.LookupInTeleListEditBox:SetSize(90, 20)
		else
			PhaseToolkit.LookupInTeleListEditBox:SetSize(PhaseToolkit.GetMaxStringWidth(PhaseToolkit.teleList), 20)
		end
		PhaseToolkit.LookupInTeleListEditBox:SetPoint("LEFT", ButtonToChangeNumberOfLine, "RIGHT", 10, -0.5)
		PhaseToolkit.LookupInTeleListEditBox:SetAutoFocus(false)
		if (CurrenttextToLookForTele ~= nil and CurrenttextToLookForTele ~= "") then
			PhaseToolkit.LookupInTeleListEditBox:SetText(CurrenttextToLookForTele)
			PhaseToolkit.LookupInTeleListEditBox:SetFocus()
		end

		PhaseToolkit.LookupInTeleListEditBox:SetScript("OnEnterPressed", SearchAndFindTeleByText)
	end
	-- Tableaux pour les boutons et noms des PNJ
	local PNJRows = {}

	-- Fonction appelée lors du clic sur le bouton "Spawn"
	local function OnSpawnClick(teleId)
		sendAddonCmd("phase tele " .. teleId .. " ", nil)
		-- Logique d'apparition (spawn) de la créature
	end

	-- Fonction appelée lors du clic sur le bouton "Delete"
	local function OnDeleteClick(teleId)
		StaticPopup_Show("CONFIRM_DELETE_TELE", nil, nil, { teleId = teleId })
	end

	-- Création des lignes (Nom, Spawn, Delete) pour chaque PNJ
	for i = 1, PhaseToolkit.itemsPerPageTELE do
		local row = CreateFrame("Frame", nil, PhaseToolkit.TELEFrame)
		row:SetSize(500, 30)
		row:SetPoint("TOPLEFT", PhaseToolkit.TELEFrame, "TOPLEFT", 10, -15 * i - (i * 15))

		-- Texte pour le nom du PNJ
		row.name = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
		row.name:SetPoint("LEFT", row, "LEFT", 10, 0)

		-- Bouton "Spawn"
		row.spawnButton = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
		row.spawnButton:SetSize(80, 30)
		row.spawnButton:SetPoint("TOPRIGHT", PhaseToolkit.TELEFrame, "TOPRIGHT", -100, -15 * i - (i * 15))
		row.spawnButton:SetText("Goto")

		-- Bouton "Delete"
		row.deleteButton = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
		row.deleteButton:SetSize(80, 30)
		row.deleteButton:SetPoint("LEFT", row.spawnButton, "RIGHT", 10, 0)
		row.deleteButton:SetText(PhaseToolkit.CurrentLang["Delete"] or "Delete")

		row.addToCategoryButton = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
		row.addToCategoryButton:SetSize(30, 30)
		row.addToCategoryButton:SetPoint("LEFT", row.deleteButton, "RIGHT", 10, 0)

		row.addToCategoryButton.icon = row.addToCategoryButton:CreateTexture(nil, "OVERLAY")
		row.addToCategoryButton.icon:SetAtlas("GarrMission_CurrencyIcon-Material")
		row.addToCategoryButton.icon:SetSize(28, 28)
		row.addToCategoryButton.icon:SetPoint("CENTER", row.addToCategoryButton, "CENTER", 0, 0)
		row.addToCategoryButton:Hide()

		row.getOutOfCategoryButton=CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
		row.getOutOfCategoryButton:SetSize(30, 30)
		row.getOutOfCategoryButton:SetPoint("LEFT", row.addToCategoryButton, "RIGHT", 10, 0)
		row.getOutOfCategoryButton.icon = row.getOutOfCategoryButton:CreateTexture(nil, "OVERLAY")
		row.getOutOfCategoryButton.icon:SetAtlas("poi-traveldirections-arrow2")
		row.getOutOfCategoryButton.icon:SetTexCoord(1, 0, 0, 1)
		row.getOutOfCategoryButton.icon:SetSize(28, 28)
		row.getOutOfCategoryButton.icon:SetPoint("CENTER", row.getOutOfCategoryButton, "CENTER", 0, 0)
		row.getOutOfCategoryButton:Hide()

		PhaseToolkit.RegisterTooltip(row.addToCategoryButton,"add to selected category")
		PhaseToolkit.RegisterTooltip(row.getOutOfCategoryButton,"remove from selected category")
		-- Ajouter la ligne au tableau pour gestion
		PNJRows[i] = row
	end



	-- Fonction pour afficher les PNJ sur la page actuelle
	local function DisplayPage(teleList)
		-- Calcul des indices de la page actuelle
		local startIndex = (currentPage - 1) * PhaseToolkit.itemsPerPageTELE + 1
		local endIndex = math.min(currentPage * PhaseToolkit.itemsPerPageTELE, #teleList)

		local isAlreadyBiggerForAddToCategory=false
		local isAlreadyBiggerForGetOutOfCategory=false

		-- Calculer la largeur maximale des noms pour la page actuelle
		local pageteleList = {}
		for i = startIndex, endIndex do
			table.insert(pageteleList, teleList[i])
		end

		local maxNameWidth = PhaseToolkit.GetMaxStringWidth(pageteleList)

		-- Ajuster la largeur de la GlobalNPCCUSTOMISER_TELEFrame en fonction de la largeur maximale des noms
		local frameWidth = maxNameWidth + 180 -- 180 pour les boutons et marges
		if PhaseToolkit.LookupInTeleListEditBox then
			PhaseToolkit.LookupInTeleListEditBox:SetWidth(maxNameWidth - 10) -- Ajuster la largeur de la zone de recherche
		end
		PhaseToolkit.TELEFrame:SetWidth(frameWidth + 30 * 2)
		if PhaseToolkit.categoryPanelTELE and PhaseToolkit.TELEselectedCategory then
			PhaseToolkit.categoryPanelTELE:ClearAllPoints()
			PhaseToolkit.categoryPanelTELE:SetPoint("TOPLEFT", PhaseToolkit.TELEFrame, "TOPRIGHT", 5, 0)
		end

		local generaloffset =-100
		for _, tele in ipairs(pageteleList) do
			if checkIfTeleInSelectedCategory(tele) then
				generaloffset = -190
				break
			end
		end
		if PhaseToolkit.categoryPanelTELE and PhaseToolkit.TELEselectedCategory  and generaloffset>(-190) then
			generaloffset = -145
		end

		-- Affichage des PNJ sur la page
		for i = 1, PhaseToolkit.itemsPerPageTELE do
			local idx = startIndex + i - 1
			local row = PNJRows[i]
			if idx <= endIndex then
				local tele = teleList[idx]
				row.name:SetText(tele) -- Affiche le nom de la créature
				row:Show()

				-- Associe l'ID de la créature aux boutons "Spawn" et "Delete"
				row.spawnButton:SetScript("OnClick", function() OnSpawnClick(tele) end)
				row.deleteButton:SetScript("OnClick", function() OnDeleteClick(tele) end)

				if PhaseToolkit.categoryPanelTELE and PhaseToolkit.TELEselectedCategory and PhaseToolkit.UserHasPermission()then

					row.addToCategoryButton:Show()
					row.addToCategoryButton:SetScript("OnClick", function()
						if(PhaseToolkit.categoryPanelTELE and PhaseToolkit.TELEselectedCategory) then
							if (isStringInArray(PhaseToolkit.TELEselectedCategory.members,tele)<0) then
								tinsert(PhaseToolkit.TELEselectedCategory.members, tele)
								PhaseToolkit.updateTELECategoryList()
								if(PhaseToolkit.IsCurrentlyFilteringTeleViaText) then
									PhaseToolkit.TeleUpdatePagination(PhaseToolkit.filteredTeleList)
								else
									PhaseToolkit.TeleUpdatePagination(PhaseToolkit.teleList)
								end
								PhaseToolkit.saveTELECategoryDataToServer()
							end
						end
					end)
					if(not isAlreadyBiggerForAddToCategory) then
						PhaseToolkit.TELEFrame:SetWidth(PhaseToolkit.TELEFrame:GetWidth() + 45)
						isAlreadyBiggerForAddToCategory=true
					end
				else
					row.spawnButton:SetPoint("TOPRIGHT", PhaseToolkit.TELEFrame, "TOPRIGHT", generaloffset, -15 * i - (i * 15))
					row.addToCategoryButton:Hide()

				end

				if(PhaseToolkit.categoryPanelTELE and PhaseToolkit.TELEselectedCategory and PhaseToolkit.UserHasPermission() and checkIfTeleInSelectedCategory(tele)) then

					row.getOutOfCategoryButton:Show()
					row.getOutOfCategoryButton:SetScript("OnClick", function()
					if(PhaseToolkit.categoryPanelTELE and PhaseToolkit.TELEselectedCategory) then
						local indexToDelete=getIndexOfMembers(PhaseToolkit.TELEselectedCategory.members, tele)
						if(indexToDelete >0) then
							table.remove(PhaseToolkit.TELEselectedCategory.members,indexToDelete)
							PhaseToolkit.updateTELECategoryList()
							if(PhaseToolkit.IsCurrentlyFilteringTeleViaText) then
								PhaseToolkit.TeleUpdatePagination(PhaseToolkit.filteredTeleList)
							else
								PhaseToolkit.TeleUpdatePagination(PhaseToolkit.teleList)
							end
							PhaseToolkit.saveTELECategoryDataToServer()
						end
					end
					end)
					if(not isAlreadyBiggerForGetOutOfCategory) then
						PhaseToolkit.TELEFrame:SetWidth(PhaseToolkit.TELEFrame:GetWidth() + 45)
						isAlreadyBiggerForGetOutOfCategory=true
					end

				else
					row.getOutOfCategoryButton:Hide()
				end
				row.spawnButton:SetPoint("TOPRIGHT", PhaseToolkit.TELEFrame, "TOPRIGHT", generaloffset, -15 * i - (i * 15))
			else
				row:Hide()
			end
		end
		isAlreadyBiggerForGetOutOfCategory=false
		isAlreadyBiggerForAddToCategory=false
	end



	local prevButton = CreateFrame("Button", nil, PhaseToolkit.TELEFrame, "UIPanelButtonTemplate")
	prevButton:SetSize(80, 30)
	prevButton:SetPoint("BOTTOMLEFT", PhaseToolkit.TELEFrame, "BOTTOMLEFT", 10, 10)
	prevButton:SetText(PhaseToolkit.CurrentLang["Prev"])

	TeleCurrentPageeditBox = CreateFrame("EditBox", nil, PhaseToolkit.TELEFrame, "InputBoxTemplate")
	TeleCurrentPageeditBox:SetSize(30, 30)
	TeleCurrentPageeditBox:SetPoint("LEFT", prevButton, "RIGHT", 10, 0)
	TeleCurrentPageeditBox:SetNumeric(true)
	TeleCurrentPageeditBox:SetAutoFocus(false)
	TeleCurrentPageeditBox:SetText(currentPage)

	NumberOfPageMaxLabelTele = PhaseToolkit.TELEFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	NumberOfPageMaxLabelTele:SetText("/ " .. totalPages)
	NumberOfPageMaxLabelTele:SetPoint("LEFT", TeleCurrentPageeditBox, "RIGHT", 0, 0)

	TeleCurrentPageeditBox:SetScript("OnEscapePressed", function()
		TeleCurrentPageeditBox:SetAutoFocus(false)
		TeleCurrentPageeditBox:ClearFocus()
	end)

	TeleCurrentPageeditBox:SetScript("OnEnterPressed", function()
		if TeleCurrentPageeditBox:GetText() ~= "" and tonumber(TeleCurrentPageeditBox:GetText()) ~= 0 and tonumber(TeleCurrentPageeditBox:GetText()) <= totalPages then
			currentPage = TeleCurrentPageeditBox:GetNumber()
			TeleCurrentPageeditBox:SetText(currentPage)
			if (PhaseToolkit.IsCurrentlyFilteringTeleViaText) then
				PhaseToolkit.TeleUpdatePagination(PhaseToolkit.filteredTeleList)
			else
				PhaseToolkit.TeleUpdatePagination(PhaseToolkit.teleList)
			end
			TeleCurrentPageeditBox:ClearFocus()
		end
	end)


	-- Création des boutons de navigation
	local nextButton = CreateFrame("Button", nil, PhaseToolkit.TELEFrame, "UIPanelButtonTemplate")
	nextButton:SetSize(80, 30)
	nextButton:SetPoint("LEFT", prevButton, "RIGHT", 70, 0)
	nextButton:SetText(PhaseToolkit.CurrentLang["Next"])

	-- Fonction pour mettre à jour les boutons et afficher la page
	function PhaseToolkit.TeleUpdatePagination(teleList)
		totalPages = math.ceil(#teleList / PhaseToolkit.itemsPerPageTELE)

		-- Mise à jour de l'état des boutons de navigation
		if currentPage <= 1 then
			prevButton:Disable()
		else
			prevButton:Enable()
		end

		if currentPage >= totalPages then
			nextButton:Disable()
		else
			nextButton:Enable()
		end

		-- Affichage de la page actuelle
		NumberOfPageMaxLabelTele:SetText("/ " .. totalPages)
		DisplayPage(teleList)
	end

	-- Gestion des événements des boutons de pagination
	nextButton:SetScript("OnClick", function()
		if currentPage < totalPages then
			currentPage = currentPage + 1
			TeleCurrentPageeditBox:SetText(currentPage)
			PhaseToolkit.TeleUpdatePagination(_teleList) -- Mise à jour avec la liste de PNJ fournie
		end
	end)

	prevButton:SetScript("OnClick", function()
		if currentPage > 1 then
			currentPage = currentPage - 1
			TeleCurrentPageeditBox:SetText(currentPage)
			PhaseToolkit.TeleUpdatePagination(_teleList)
		end
	end)

	-- Affichage initial des PNJ à la première page
	PhaseToolkit.TELEFrame:SetScript("OnShow", function()
		currentPage = 1
		PhaseToolkit.TeleUpdatePagination(_teleList)
	end)

	PhaseToolkit.TeleUpdatePagination(_teleList)
end
--=============================== Recuperation de Tele ===========================--

PhaseToolkit.MaxNumberOfTP = nil
PhaseToolkit.NumberofTp = 0
local function parseTeleReplies(isCommandSuccessful, repliesList)
	-- Only do the job if the command is successful
	if (isCommandSuccessful) then
		for i = 1, #repliesList do
			message = repliesList[i]
			message = message:gsub("|cff%x%x%x%x%x%x", ""):gsub("|r", "")
			-- get if the message is the header 'we have found blabla'
			local isHeader = string.find(message, 'We have found ') ~= nil
			-- get the Tele Name
			local teleName = string.match(message, "%[(.+)%]")

			teleName = teleName:gsub("%[", ""):gsub("%]", "")

			if not isHeader then
				table.insert(PhaseToolkit.teleList, teleName)
			end
		end
		-- if it's finished, we remove potential duplicate (by ID) and then we "regenerates" the frame for the list
		if (PhaseToolkit.TELEFrame ~= nil) then
			if PhaseToolkit.TELEFrame:IsShown() then
				PhaseToolkit.TELEFrame:Hide()
				PhaseToolkit.TELEFrame = nil
				PhaseToolkit.CreateTeleListFrame(PhaseToolkit.teleList)
			else
				PhaseToolkit.TELEFrame = nil
				PhaseToolkit.CreateTeleListFrame(PhaseToolkit.teleList)
			end
		end
	end
end

function PhaseToolkit.PhaseTeleListSystemMessageCounter()
	PhaseToolkit.teleList = {}
	-- Use Epsilib to get the tele list (first page)
	sendAddonCmd("ph tele list", parseTeleReplies, false)
end
-- -- -- -- -- -- -- -- -- -- -- --
--#endregion
-- -- -- -- -- -- -- -- -- -- -- --
-- -- -- -- -- -- -- -- -- -- -- --
--#region Phase Options
-- -- -- -- -- -- -- -- -- -- -- --
-- ============================== Frame pour Phase Option ============================== --

function PhaseToolkit.CreatePhaseOptionFrame()
	if (PhaseToolkit.CustomFrame ~= nil) then
		if (PhaseToolkit.CustomFrame:IsShown()) then
			PhaseToolkit.CustomFrame:Hide()
			PhaseToolkit.CustomFrame = nil
		end
	end
	if (PhaseToolkit.TELEFrame ~= nil) then
		if PhaseToolkit.TELEFrame:IsShown() then
			PhaseToolkit.TELEFrame:Hide()
		end
	end
	if (PhaseToolkit.PNJFrame ~= nil) then
		if (PhaseToolkit.PNJFrame:IsShown()) then
			PhaseToolkit.PNJFrame:Hide()
		end
	end
	if (PhaseToolkit.CustomMainFrame ~= nil) then
		if (PhaseToolkit.CustomMainFrame:IsShown()) then
			PhaseToolkit.CustomMainFrame:Hide()
			PhaseToolkit.CustomMainFrame = nil
		end
	end
	if (PhaseToolkit.PhaseOptionFrame ~= nil) then
		if (PhaseToolkit.PhaseOptionFrame:IsShown()) then
			PhaseToolkit.PhaseOptionFrame:Hide()
		else
			PhaseToolkit.PhaseOptionFrame:Show()
			if (PhaseToolkit.IsPhaseWhitelist == nil) then
				PhaseToolkit.IsPhaseWhitelist = false
				sendAddonCmd("phase info ", PhaseToolkit.gatherPhaseInfo, false)
			end
		end
		return
	end


	PhaseToolkit.PhaseOptionFrame = CreateFrame("Frame", nil, PhaseToolkit.NPCCustomiserMainFrame, "BackdropTemplate")
	PhaseToolkit.PhaseOptionFrame:SetBackdrop({
		bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
		edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
		edgeSize = 16,
		insets = { left = 5, right = 5, top = 5, bottom = 5 },
	})
	PhaseToolkit.PhaseOptionFrame:EnableMouse(true)
	PhaseToolkit.PhaseOptionFrame:SetSize(350, 450)
	PhaseToolkit.PhaseOptionFrame:SetPoint("TOPLEFT", PhaseToolkit.NPCCustomiserMainFrame, "TOPRIGHT", 0, 0)

	function PhaseToolkit.gatherPhaseInfo(isCommandSuccessful, replies)
		if isCommandSuccessful then
			for i = 1, #replies do
				message = replies[i]
				message = message:gsub("|cff%x%x%x%x%x%x", ""):gsub("|r", "")
				local listType = string.match(message, "List%s+Type:%s*(%S+)")

				if listType == "BlackList" then
					PhaseToolkit.IsPhaseWhitelist = false
					PhaseToolkit.RadioWhitelist:SetChecked(false)
					PhaseToolkit.RadioBlacklist:SetChecked(true)
				elseif listType == "Whitelist" then
					PhaseToolkit.IsPhaseWhitelist = true
					PhaseToolkit.RadioBlacklist:SetChecked(false)
					PhaseToolkit.RadioWhitelist:SetChecked(true)
				end

				local phaseName = string.match(message, "Phase%s+%[(.*)-")
				if (phaseName ~= nil) then
					PhaseToolkit.nameTextEdit:SetText(phaseName)
				end
			end
		end
	end

	if (PhaseToolkit.IsPhaseWhitelist == nil) then
		PhaseToolkit.IsPhaseWhitelist = false
		sendAddonCmd("phase info", PhaseToolkit.gatherPhaseInfo, false)
	end

	PhaseToolkit.recreateFrameModule()
end

--==== Module d'accès de phase ====--
function PhaseToolkit.createPhaseAccessFrame()
	PhaseToolkit.moduleForPhaseAccessFrame = CreateFrame("Frame", nil, PhaseToolkit.PhaseOptionFrame, "BackdropTemplate")
	PhaseToolkit.moduleForPhaseAccessFrame:SetBackdrop({
		bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
		edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
		edgeSize = 16,
		insets = { left = 5, right = 5, top = 5, bottom = 5 },
	})
	PhaseToolkit.moduleForPhaseAccessFrame:SetSize(165, 80)
	PhaseToolkit.moduleForPhaseAccessFrame:SetPoint("TOPLEFT", PhaseToolkit.PhaseOptionFrame, "TOPLEFT", 5, -5)



	PhaseToolkit.RadioBlacklist = CreateFrame("CheckButton", "RadioBlacklist", PhaseToolkit.moduleForPhaseAccessFrame, "UIRadioButtonTemplate")
	PhaseToolkit.RadioBlacklist:SetPoint("BOTTOMLEFT", PhaseToolkit.moduleForPhaseAccessFrame, "BOTTOMLEFT", 10, 10)
	local labelForBlacklist = PhaseToolkit.moduleForPhaseAccessFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	labelForBlacklist:SetPoint("LEFT", PhaseToolkit.RadioBlacklist, "RIGHT", 0, 1)
	labelForBlacklist:SetText("Blacklist")


	PhaseToolkit.RadioWhitelist = CreateFrame("CheckButton", "RadioWhitelist", PhaseToolkit.moduleForPhaseAccessFrame, "UIRadioButtonTemplate")
	PhaseToolkit.RadioWhitelist:SetPoint("LEFT", PhaseToolkit.RadioBlacklist, "RIGHT", 60, 0)

	local labelForWhitelist = PhaseToolkit.moduleForPhaseAccessFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	labelForWhitelist:SetPoint("LEFT", PhaseToolkit.RadioWhitelist, "RIGHT", 0, 1)
	labelForWhitelist:SetText("Whitelist")



	GlobalNPCCUSTOMISER_phaseAccessLabel = PhaseToolkit.moduleForPhaseAccessFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	GlobalNPCCUSTOMISER_phaseAccessLabel:SetPoint("TOP", PhaseToolkit.moduleForPhaseAccessFrame, "TOP", 0, -7.5)
	GlobalNPCCUSTOMISER_phaseAccessLabel:SetText(PhaseToolkit.CurrentLang["Phase Access"] or "Phase Access")


	local function RadioButton_OnClick(self)
		PhaseToolkit.RadioBlacklist:SetChecked(false)
		PhaseToolkit.RadioWhitelist:SetChecked(false)
		self:SetChecked(true)

		if (PhaseToolkit.IsPhaseWhitelist) then
			if self:GetName() == "RadioWhitelist" then
				return
			elseif self:GetName() == "RadioBlacklist" then
				sendAddonCmd("phase toggle private", nil)
				PhaseToolkit.IsPhaseWhitelist = false
			end
		elseif not PhaseToolkit.IsPhaseWhitelist then
			if self:GetName() == "RadioWhitelist" then
				sendAddonCmd("phase toggle private", nil)
				PhaseToolkit.IsPhaseWhitelist = true
			elseif self:GetName() == "RadioBlacklist" then
				return
			end
		end
	end

	PhaseToolkit.RadioBlacklist:SetScript("OnClick", RadioButton_OnClick)
	PhaseToolkit.RadioWhitelist:SetScript("OnClick", RadioButton_OnClick)

	if (PhaseToolkit.IsPhaseWhitelist) then
		PhaseToolkit.RadioWhitelist:SetChecked(true)
	elseif not PhaseToolkit.IsPhaseWhitelist then
		PhaseToolkit.RadioBlacklist:SetChecked(true)
	end
end

--==== Module de météo ====--
function PhaseToolkit.createMeteoSettingsFrame()
	PhaseToolkit.moduleForMetteoSettingsFrame = CreateFrame("Frame", nil, PhaseToolkit.PhaseOptionFrame, "BackdropTemplate")
	PhaseToolkit.moduleForMetteoSettingsFrame:SetBackdrop({
		bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
		edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
		edgeSize = 16,
		insets = { left = 5, right = 5, top = 5, bottom = 5 },
	})
	PhaseToolkit.moduleForMetteoSettingsFrame:SetSize(165, 80)
	PhaseToolkit.moduleForMetteoSettingsFrame:SetPoint("TOPRIGHT", PhaseToolkit.PhaseOptionFrame, "TOPRIGHT", -5, -5)
	-- --=== Dropdown ===--
	PhaseToolkit.MeteoDropDown = CreateFrame("Frame", "MeteoDropDown", PhaseToolkit.moduleForMetteoSettingsFrame, "UIDropDownMenuTemplate")
	PhaseToolkit.MeteoDropDown:SetSize(200, 30)
	PhaseToolkit.MeteoDropDown:SetPoint("TOP", PhaseToolkit.moduleForMetteoSettingsFrame, "TOP", 0, -2.5)

	PhaseToolkit.ShowMeteoDropDown(PhaseToolkit.MeteoDropDown)

	--=== Slider ===--
	GlobalNPCCUSTOMISER_SliderFrame = CreateFrame("Slider", "MyCustomSlider", PhaseToolkit.moduleForMetteoSettingsFrame, "OptionsSliderTemplate")
	GlobalNPCCUSTOMISER_SliderFrame:SetSize(150, 20)

	GlobalNPCCUSTOMISER_SliderFrame:SetPoint("TOP", PhaseToolkit.moduleForMetteoSettingsFrame, "CENTER", 0, 0)
	GlobalNPCCUSTOMISER_SliderFrame:SetMinMaxValues(PhaseToolkit.IntensiteMeteoMin, IntensiteMeteoMax)
	GlobalNPCCUSTOMISER_SliderFrame:SetValue(PhaseToolkit.IntensiteMeteoMin)
	GlobalNPCCUSTOMISER_SliderFrame:SetValueStep(1)
	GlobalNPCCUSTOMISER_SliderFrame:SetObeyStepOnDrag(true)

	_G[GlobalNPCCUSTOMISER_SliderFrame:GetName() .. 'Low']:SetText(PhaseToolkit.IntensiteMeteoMin)
	_G[GlobalNPCCUSTOMISER_SliderFrame:GetName() .. 'High']:SetText(IntensiteMeteoMax)
	_G[GlobalNPCCUSTOMISER_SliderFrame:GetName() .. 'Text']:SetText(PhaseToolkit.CurrentLang['Intensity'] or 'Intensity')

	local function OnValueChanged(self)
		PhaseToolkit.IntensiteMeteo = self:GetValue()
	end

	GlobalNPCCUSTOMISER_SliderFrame:SetScript("OnMouseDown", function(self)
		OnValueChanged(self)
	end)


	GlobalNPCCUSTOMISER_SliderFrame:SetScript("OnMouseUp", function(self)
		OnValueChanged(self)
		PhaseToolkit.ChangePhaseWeather()
	end)
end

--==== Module pour l'heure====--
function PhaseToolkit.createTimeSettingsFrame()
	-- need une frame module
	PhaseToolkit.moduleForTimeSliderFrame = CreateFrame("Frame", nil, PhaseToolkit.PhaseOptionFrame, "BackdropTemplate")
	PhaseToolkit.moduleForTimeSliderFrame:SetBackdrop({
		bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
		edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
		edgeSize = 16,
		insets = { left = 5, right = 5, top = 5, bottom = 5 },
	})
	PhaseToolkit.moduleForTimeSliderFrame:SetSize(340, 80)
	PhaseToolkit.moduleForTimeSliderFrame:SetPoint("TOPLEFT", PhaseToolkit.PhaseOptionFrame, "TOPLEFT", 5, -85)

	local timeSliderLabel = PhaseToolkit.moduleForTimeSliderFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	timeSliderLabel:SetPoint("TOP", PhaseToolkit.moduleForTimeSliderFrame, "TOP", 0, -10)
	timeSliderLabel:SetText(PhaseToolkit.CurrentLang["Set the time"] or "Set the time")


	local slider = CreateFrame("Slider", "$parentSlider", PhaseToolkit.moduleForTimeSliderFrame, "OptionsSliderTemplate")
	slider:SetPoint("LEFT", PhaseToolkit.moduleForTimeSliderFrame, 15, 0)

	slider.Text:ClearAllPoints()
	slider.Text:SetPoint("TOP", slider, "BOTTOM", 0, 0)

	slider:SetPoint("RIGHT", -slider.Text:GetWidth() - 15, 0)
	slider:SetMinMaxValues(0, 1439)
	slider:SetValueStep(1)
	slider:SetObeyStepOnDrag(true)

	slider.Low:Hide()
	slider.High:Hide()

	local hour, min = GetGameTime()
	local timeInMin = (hour * 60) + min

	slider.Text:SetText(string.format("%.2d", hour) .. ":" .. string.format("%.2d", min))

	function slider.getTime(value)
		local hours = string.format("%.2d", math.floor(value / 60))
		local minutes = string.format("%.2d", value % 60)
		return hours .. ":" .. minutes
	end

	slider:SetValue(timeInMin)

	slider:SetScript("OnValueChanged", function(self, value)
		if self.last == value then return end
		local time = self.getTime(value)
		sendAddonCmd("phase set time " .. time, nil)
		self.Text:SetText(time)
		self.last = value
	end)
end

--==== Module pour le starting ====--
function PhaseToolkit.createSetStartingFrame()
	-- need une frame module
	PhaseToolkit.moduleForSetStartingFrame = CreateFrame("Frame", nil, PhaseToolkit.PhaseOptionFrame, "BackdropTemplate")
	PhaseToolkit.moduleForSetStartingFrame:SetBackdrop({
		bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
		edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
		edgeSize = 16,
		insets = { left = 5, right = 5, top = 5, bottom = 5 },
	})
	PhaseToolkit.moduleForSetStartingFrame:SetSize(165, 80)
	PhaseToolkit.moduleForSetStartingFrame:SetPoint("TOPLEFT", PhaseToolkit.PhaseOptionFrame, "TOPLEFT", 5, -80 * 2 - 5)

	local startingLabel = PhaseToolkit.moduleForSetStartingFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	startingLabel:SetPoint("TOP", PhaseToolkit.moduleForSetStartingFrame, "TOP", 0, -10)
	startingLabel:SetText(PhaseToolkit.CurrentLang["Starting point"] or 'Starting point')

	local ButtonSetStarting = CreateFrame("Button", nil, PhaseToolkit.moduleForSetStartingFrame, "UIPanelButtonTemplate")
	ButtonSetStarting:SetPoint("CENTER", PhaseToolkit.moduleForSetStartingFrame, "CENTER", 0, -10)
	ButtonSetStarting:SetPoint("LEFT", 5, 0)
	ButtonSetStarting:SetPoint("RIGHT", -5, 0)
	ButtonSetStarting:SetText(PhaseToolkit.CurrentLang["Set Current Location"] or "Set Current Location")
	ButtonSetStarting:SetScript("OnClick", function()
		sendAddonCmd("phase set starting ", nil)
	end
	)

	local ButtonDisableStart = CreateFrame("Button", nil, PhaseToolkit.moduleForSetStartingFrame, "UIPanelButtonTemplate")
	ButtonDisableStart:SetPoint("BOTTOM", PhaseToolkit.moduleForSetStartingFrame, "BOTTOM", 0, 5)
	ButtonDisableStart:SetPoint("LEFT", 15, 0)
	ButtonDisableStart:SetPoint("RIGHT", -15, 0)
	ButtonDisableStart:SetText(PhaseToolkit.CurrentLang["Disable Starting"] or "Disable Starting")
	ButtonDisableStart:SetScript("OnClick", function()
		sendAddonCmd("phase set starting disable ", nil)
	end
	)
end

--==== Module pour les toggles ====--
function PhaseToolkit.createTogglesFrame()
	-- need une frame module
	PhaseToolkit.moduleForTogglesFrame = CreateFrame("Frame", nil, PhaseToolkit.PhaseOptionFrame, "BackdropTemplate")
	PhaseToolkit.moduleForTogglesFrame:SetBackdrop({
		bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
		edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
		edgeSize = 16,
		insets = { left = 5, right = 5, top = 5, bottom = 5 },
	})
	PhaseToolkit.moduleForTogglesFrame:SetSize(165, 80)
	PhaseToolkit.moduleForTogglesFrame:SetPoint("TOPLEFT", PhaseToolkit.PhaseOptionFrame, "TOPLEFT", 15 + 165, -80 * 2 - 5)

	local startingLabel = PhaseToolkit.moduleForTogglesFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	startingLabel:SetPoint("TOP", PhaseToolkit.moduleForTogglesFrame, "TOP", 0, -10)
	startingLabel:SetText(PhaseToolkit.CurrentLang["Permission disabling"] or 'Permission disabling')

	Togglesdropdown = CreateFrame("FRAME", "$parentDropDown", PhaseToolkit.moduleForTogglesFrame, "UIDropDownMenuTemplate")
	Togglesdropdown:SetSize(200, 30)
	Togglesdropdown:SetPoint("CENTER", PhaseToolkit.moduleForTogglesFrame, "CENTER", 0, -10)

	PhaseToolkit.ShowToggleDropDown(Togglesdropdown)
end

--==== Module pour le nom ====--
function PhaseToolkit.createPhaseSetNameFrame()
	PhaseToolkit.moduleForPhaseSetNameFrame = CreateFrame("Frame", nil, PhaseToolkit.PhaseOptionFrame, "BackdropTemplate")
	PhaseToolkit.moduleForPhaseSetNameFrame:SetBackdrop({
		bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
		edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
		edgeSize = 16,
		insets = { left = 5, right = 5, top = 5, bottom = 5 },
	})
	PhaseToolkit.moduleForPhaseSetNameFrame:SetSize(165, 80)
	PhaseToolkit.moduleForPhaseSetNameFrame:SetPoint("TOPLEFT", PhaseToolkit.PhaseOptionFrame, "TOPLEFT", 5, -5 - 80 * 3)


	PhaseToolkit.nameTextEdit = CreateFrame("EDITBOX", nil, PhaseToolkit.moduleForPhaseSetNameFrame, "InputBoxTemplate")
	PhaseToolkit.nameTextEdit:SetSize(130, 20)
	PhaseToolkit.nameTextEdit:SetPoint("CENTER", PhaseToolkit.moduleForPhaseSetNameFrame, "CENTER", 2.5, 0)
	PhaseToolkit.nameTextEdit:SetAutoFocus(false)
	PhaseToolkit.nameTextEdit:SetScript("OnEnterPressed", function(self)
		sendAddonCmd("phase rename " .. self:GetText(), nil)
	end)

	local labelForNameTextEdit = PhaseToolkit.moduleForPhaseSetNameFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	labelForNameTextEdit:SetPoint("TOP", PhaseToolkit.moduleForPhaseSetNameFrame, "TOP", 0, -15)
	labelForNameTextEdit:SetText(PhaseToolkit.CurrentLang["Phase Name"] or "Phase Name")
end

--==== Module pour la description ====--
function PhaseToolkit.createPhaseSetDescriptionFrame()
	PhaseToolkit.moduleForPhaseSetDescriptionFrame = CreateFrame("Frame", nil, PhaseToolkit.PhaseOptionFrame, "BackdropTemplate")
	PhaseToolkit.moduleForPhaseSetDescriptionFrame:SetBackdrop({
		bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
		edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
		edgeSize = 16,
		insets = { left = 5, right = 5, top = 5, bottom = 5 },
	})
	PhaseToolkit.moduleForPhaseSetDescriptionFrame:SetSize(165, 80)
	PhaseToolkit.moduleForPhaseSetDescriptionFrame:SetPoint("TOPRIGHT", PhaseToolkit.PhaseOptionFrame, "TOPRIGHT", -5, -5 - 80 * 3)

	GlobalNPCCUSTOMISER_DescTextEdit = CreateFrame("EDITBOX", nil, PhaseToolkit.moduleForPhaseSetDescriptionFrame, "InputBoxTemplate")
	GlobalNPCCUSTOMISER_DescTextEdit:SetSize(130, 20)
	GlobalNPCCUSTOMISER_DescTextEdit:SetPoint("CENTER", PhaseToolkit.moduleForPhaseSetDescriptionFrame, "CENTER", 2.5, 0)
	GlobalNPCCUSTOMISER_DescTextEdit:SetAutoFocus(false)
	GlobalNPCCUSTOMISER_DescTextEdit:SetScript("OnEnterPressed", function(self)
		sendAddonCmd("phase set description " .. self:GetText(), nil)
	end)

	local labelForNameTextEdit = PhaseToolkit.moduleForPhaseSetDescriptionFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	labelForNameTextEdit:SetPoint("TOP", PhaseToolkit.moduleForPhaseSetDescriptionFrame, "TOP", 0, -15)
	labelForNameTextEdit:SetText(PhaseToolkit.CurrentLang["Phase Description"] or "Phase Description")
end

function PhaseToolkit.createMotdFrame()
	PhaseToolkit.moduleforMotdFrame = CreateFrame("Frame", nil, PhaseToolkit.PhaseOptionFrame, "BackdropTemplate")
	PhaseToolkit.moduleforMotdFrame:SetBackdrop({
		bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
		edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
		edgeSize = 16,
		insets = { left = 5, right = 5, top = 5, bottom = 5 },
	})
	PhaseToolkit.moduleforMotdFrame:SetSize(340, 120)
	PhaseToolkit.moduleforMotdFrame:SetPoint("BOTTOM", PhaseToolkit.PhaseOptionFrame, "BOTTOM", 0, 5)

	local textForMotd = ""
	GlobalNPCCUSTOMISER_editBoxForMotd = CreateFrame("FRAME", "$parentEdit", PhaseToolkit.moduleforMotdFrame, "EpsilonInputScrollTemplate")
	GlobalNPCCUSTOMISER_editBoxForMotd:SetPoint("BOTTOMLEFT", PhaseToolkit.moduleforMotdFrame, "BOTTOMLEFT", 5, 5)
	GlobalNPCCUSTOMISER_editBoxForMotd:SetSize(330, 95)
	GlobalNPCCUSTOMISER_editBoxForMotd.ScrollFrame.EditBox:SetScript("OnTextChanged", function(self)
		textForMotd = self:GetText()
	end)

	local labelForMotdTextEdit = PhaseToolkit.moduleforMotdFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	labelForMotdTextEdit:SetPoint("TOP", PhaseToolkit.moduleforMotdFrame, "TOP", 0, -5)
	labelForMotdTextEdit:SetText(PhaseToolkit.CurrentLang["Message of the day"] or "Message of the day")


	local buttonToSendMotd = CreateFrame("Button", nil, PhaseToolkit.moduleforMotdFrame, "UIPanelButtonTemplate")
	buttonToSendMotd:SetPoint("TOPRIGHT", PhaseToolkit.moduleforMotdFrame, "TOPRIGHT", 0, 0)
	buttonToSendMotd:SetSize(80, 20)
	buttonToSendMotd:SetText(PhaseToolkit.CurrentLang["SetMotd"] or "SetMotd")
	buttonToSendMotd:SetScript("OnClick", function(self)
		sendAddonCmd("phase set message " .. textForMotd, nil)
	end
	)
end

-- -- -- -- -- -- -- -- -- -- -- --
--#endregion
-- -- -- -- -- -- -- -- -- -- -- --

-- -- -- -- -- -- -- -- -- -- -- --
--#region Npc Custom Options
-- -- -- -- -- -- -- -- -- -- -- --

function PhaseToolkit.PromptForNPCName()
	-- Création de l'EditBox
	local editBox = CreateFrame("EditBox", nil, PhaseToolkit.CustomMainFrame, "InputBoxTemplate")
	editBox:SetSize(180, 30)
	editBox:SetPoint("BOTTOMRIGHT", PhaseToolkit.CustomMainFrame, "TOPRIGHT", 0, 0)
	editBox:SetAutoFocus(true)

	-- Fonction de validation de la saisie
	local function OnEnterPressed(self)
		local npcName = self:GetText()
		if npcName and npcName ~= "" then
			-- Envoi de la commande
			sendAddonCmd("phase forge npc name " .. npcName, nil)
		end
		self:ClearFocus()
		self:Hide() -- Ferme l'EditBox après la saisie
	end

	-- Ajout de l'événement pour le bouton "Entrée"
	editBox:SetScript("OnEnterPressed", OnEnterPressed)
	editBox:SetScript("OnEscapePressed", function()
		editBox:ClearFocus()
		editBox:Hide()
	end)

	-- Afficher l'EditBox
	editBox:Show()
	editBox:SetFocus() -- Focaliser l'EditBox pour que l'utilisateur puisse commencer à taper
end

function PhaseToolkit.PromptForNPCSubName()
	-- Création de l'EditBox
	local editBox = CreateFrame("EditBox", nil, PhaseToolkit.CustomMainFrame, "InputBoxTemplate")
	editBox:SetSize(180, 30)
	editBox:SetPoint("BOTTOMRIGHT", PhaseToolkit.CustomMainFrame, "TOPRIGHT", 0, -10)
	editBox:SetAutoFocus(true)

	-- Fonction de validation de la saisie
	local function OnEnterPressed(self)
		local npcName = self:GetText()
		if npcName and npcName ~= "" then
			sendAddonCmd("phase forge npc subname " .. npcName, nil)
		end
		self:ClearFocus()
		self:Hide() -- Ferme l'EditBox après la saisie
	end

	-- Ajout de l'événement pour le bouton "Entrée"
	editBox:SetScript("OnEnterPressed", OnEnterPressed)
	editBox:SetScript("OnEscapePressed", function()
		editBox:ClearFocus()
		editBox:Hide()
	end)

	-- Afficher l'EditBox
	editBox:Show()
	editBox:SetFocus() -- Focaliser l'EditBox pour que l'utilisateur puisse commencer à taper
end

-- ============================== Frame pour Custom ============================== --
function PhaseToolkit.CreateCustomFrame()
	if (PhaseToolkit.PhaseOptionFrame ~= nil) then
		if (PhaseToolkit.PhaseOptionFrame:IsShown()) then
			PhaseToolkit.PhaseOptionFrame:Hide()
			PhaseToolkit.PhaseOptionFrame = nil
		end
	end
	if (PhaseToolkit.TELEFrame ~= nil) then
		if PhaseToolkit.TELEFrame:IsShown() then
			PhaseToolkit.TELEFrame:Hide()
		end
	end
	if (PhaseToolkit.PNJFrame ~= nil) then
		if (PhaseToolkit.PNJFrame:IsShown()) then
			PhaseToolkit.PNJFrame:Hide()
		end
	end

	PhaseToolkit.CustomFrame = CreateFrame("Frame", "CustomFrame", PhaseToolkit.CustomMainFrame, "BackdropTemplate")
	PhaseToolkit.CustomFrame:SetBackdrop({
		bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
		edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
		edgeSize = 16,
		insets = { left = 5, right = 5, top = 5, bottom = 5 },
	})

	PhaseToolkit.CustomFrame:EnableMouse(true);

	if (PhaseToolkit.NombreDeLigne ~= nil) then
		PhaseToolkit.HauteurDispoCustomFrame = ((PhaseToolkit.NombreDeLigne - 1) * 50)
		PhaseToolkit.CustomFrame:SetSize(562.5, PhaseToolkit.HauteurDispoCustomFrame)
	else
		PhaseToolkit.CustomFrame:SetSize(562.5, 630)
	end
	PhaseToolkit.CustomFrame:SetPoint("TOPLEFT", PhaseToolkit.CustomMainFrame, "BOTTOMLEFT", 0, 0)
	PhaseToolkit.CustomFrame:Hide()
end

function PhaseToolkit.ToggleCustomFrame(Race)
	if PhaseToolkit.CustomFrame ~= nil then
		if PhaseToolkit.CustomFrame:IsShown() then
			PhaseToolkit.CustomFrame:Hide()
			PhaseToolkit.CustomFrame = nil
			PhaseToolkit.CreateCustomFrame()
			PhaseToolkit.CreateCustomGrid(PhaseToolkit.InfoCustom[Race][PhaseToolkit.SelectedGender])
			PhaseToolkit.CustomFrame:Show()
		else
			PhaseToolkit.CustomFrame:Show()
			PhaseToolkit.CreateCustomGrid(PhaseToolkit.InfoCustom[Race][PhaseToolkit.SelectedGender])
		end
	end
end

local frameWidth, frameHeight = 550, PhaseToolkit.HauteurDispoCustomFrame

function PhaseToolkit.CreateCustomGrid(data)
	local row = 0
	local col = 0
	local nbcol = 3
	local rowHeight = 50
	local spacing = 5
	local totalItems = 0


	for _, value in pairs(data) do
		if value ~= 0 then
			totalItems = totalItems + 1
		end
	end

	local nbrow = math.ceil(totalItems / nbcol)

	local frameHeight = nbrow * (rowHeight + spacing) - spacing
	PhaseToolkit.HauteurDispoCustomFrame = frameHeight
	if (totalItems < 1) then
		PhaseToolkit.CustomFrame:SetHeight(105)
		PhaseToolkit.CustomFrame:SetWidth(30)
	else
		PhaseToolkit.CustomFrame:SetHeight(frameHeight + 10)
	end

	for attribute, value in pairs(data) do
		if value ~= 0 then
			local frame = CreateFrame("Frame", "customframe" .. attribute, PhaseToolkit.CustomFrame, "BackdropTemplate")
			frame:SetSize(frameWidth / nbcol - 5, rowHeight)
			frame:SetPoint("TOPLEFT", PhaseToolkit.CustomFrame, "TOPLEFT", 6.5 + col * (frameWidth + spacing) / nbcol, -5 - row * (rowHeight + spacing))
			frame:SetBackdrop({
				bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
				edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
				edgeSize = 16,
				insets = { left = 5, right = 5, top = 5, bottom = 5 },
			})


			local text = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
			text:SetPoint("BOTTOM", frame, "CENTER", 0, 5)
			text:SetText(PhaseToolkit.CurrentLang[attribute] or attribute)
			text:SetFont("fonts/arialn.ttf", 15)



			local AttributeValueEditBox = CreateFrame("EditBox", nil, frame, "InputBoxTemplate")
			AttributeValueEditBox:SetSize(30, 30)
			AttributeValueEditBox:SetPoint("TOP", frame, "CENTER", -15, 10)
			AttributeValueEditBox:SetNumeric(true)
			AttributeValueEditBox:SetMaxLetters(2)
			AttributeValueEditBox:SetAutoFocus(false)
			AttributeValueEditBox:SetText(PhaseToolkit.GeneralStat[attribute])

			local MaxValueOfAttributeLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
			MaxValueOfAttributeLabel:SetText(" / " .. value)
			MaxValueOfAttributeLabel:SetPoint("LEFT", AttributeValueEditBox, "RIGHT", 0, 0)

			AttributeValueEditBox:SetScript("OnEscapePressed", function()
				AttributeValueEditBox:SetAutoFocus(false)
				AttributeValueEditBox:ClearFocus()
			end)

			AttributeValueEditBox:SetScript("OnEnterPressed", function()
				if AttributeValueEditBox:GetText() ~= "" then
					if (AttributeValueEditBox:GetNumber() > value) then
						AttributeValueEditBox:SetNumber(value)
					end
					if (AttributeValueEditBox:GetNumber() < 1) then
						AttributeValueEditBox:SetNumber(1)
					end
					PhaseToolkit.GeneralStat[attribute] = AttributeValueEditBox:GetNumber()

					sendAddonCmd("phase forge npc outfit custom " .. attribute .. " " .. PhaseToolkit.GeneralStat[attribute], nil)
					AttributeValueEditBox:ClearFocus()
				end
			end)

			local randomValueButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
			randomValueButton:SetSize(20, 20)
			randomValueButton:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -7, -7)
			randomValueButton.icon = randomValueButton:CreateTexture(nil, "OVERLAY")
			randomValueButton.icon:SetTexture("Interface\\Icons\\inv_misc_dice_02")
			randomValueButton.icon:SetAllPoints()
			randomValueButton:SetScript("OnClick", function()
				local randomNumber = math.random(1, value)
				PhaseToolkit.GeneralStat[attribute] = randomNumber
				sendAddonCmd("phase forge npc outfit custom " .. attribute .. " " .. PhaseToolkit.GeneralStat[attribute], nil)
				AttributeValueEditBox:SetNumber(PhaseToolkit.GeneralStat[attribute])
				return
			end)

			local buttonMoins = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
			buttonMoins:SetSize(18, 18)
			buttonMoins:SetPoint("RIGHT", AttributeValueEditBox, "LEFT", -7.5, 0)
			buttonMoins.icon = buttonMoins:CreateTexture(nil, "OVERLAY")
			buttonMoins.icon:SetTexture("Interface\\Icons\\MISC_ARROWLEFT")
			buttonMoins.icon:SetAllPoints()
			buttonMoins:SetScript("OnClick", function()
				if (PhaseToolkit.GeneralStat[attribute] == 1) then
					-- si on est a 1 et qu'on fais -1 on arrive au max
					PhaseToolkit.GeneralStat[attribute] = value
					sendAddonCmd("phase forge npc outfit custom " .. attribute .. " " .. PhaseToolkit.GeneralStat[attribute], nil)
					AttributeValueEditBox:SetNumber(PhaseToolkit.GeneralStat[attribute])
					return
				end
				if PhaseToolkit.GeneralStat[attribute] - 1 >= 1 then
					PhaseToolkit.GeneralStat[attribute] = PhaseToolkit.GeneralStat[attribute] - 1
					sendAddonCmd("phase forge npc outfit custom " .. attribute .. " " .. PhaseToolkit.GeneralStat[attribute], nil)
					AttributeValueEditBox:SetNumber(PhaseToolkit.GeneralStat[attribute])
					return
				end
			end)


			local buttonPlus = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
			buttonPlus:SetSize(18, 18)
			buttonPlus:SetPoint("LEFT", MaxValueOfAttributeLabel, "RIGHT", 7.5, 0)
			buttonPlus.icon = buttonPlus:CreateTexture(nil, "OVERLAY")
			buttonPlus.icon:SetTexture("Interface\\Icons\\MISC_ARROWRIGHT")
			buttonPlus.icon:SetAllPoints()
			buttonPlus:SetScript("OnClick", function()
				if (PhaseToolkit.GeneralStat[attribute] == value) then
					-- si on est a 1 et qu'on fais -1 on arrive au max
					PhaseToolkit.GeneralStat[attribute] = 1
					sendAddonCmd("phase forge npc outfit custom " .. attribute .. " " .. PhaseToolkit.GeneralStat[attribute], nil)
					AttributeValueEditBox:SetNumber(PhaseToolkit.GeneralStat[attribute])
					return
				end
				if PhaseToolkit.GeneralStat[attribute] + 1 <= value then
					PhaseToolkit.GeneralStat[attribute] = PhaseToolkit.GeneralStat[attribute] + 1
					sendAddonCmd("phase forge npc outfit custom " .. attribute .. " " .. PhaseToolkit.GeneralStat[attribute], nil)
					AttributeValueEditBox:SetNumber(PhaseToolkit.GeneralStat[attribute])
					return
				end
			end)

			col = col + 1
			if col >= nbcol then
				col = 0
				row = row + 1
			end
		end
	end
end

SLASH_PTK1 = "/phasetoolkit"
SLASH_PTK2 = "/ptk"
SlashCmdList["PTK"] = function(msg)
	PhaseToolkit.ToggleMainFrame()
end

function PhaseToolkit.parseForDisplayId(isCommandSuccessful, repliesList)
	local message = repliesList[1];
	message = message:gsub("|cff%x%x%x%x%x%x", ""):gsub("|r", "")

	local displayId = string.match(message, "DisplayID: (.+) %(")
	if displayId ~= nil then
		displayId = displayId:gsub("|.+|", ""):gsub("h", "")
		if (displayId ~= "" and isKeyInTable(displayId)) then
			local identity = PhaseToolkit.infoPerDisplay[displayId]
			PhaseToolkit.SelectedNpcInfo = identity
			PhaseToolkit.SelectedRace = PhaseToolkit.Races[identity.race]
			PhaseToolkit.SelectedGender = identity.sexe
			PhaseToolkit.ShowRaceDropDown(PhaseToolkit.RaceDropDown)
			PhaseToolkit.ShowGenderDropDown(PhaseToolkit.GenreDropDown)
			if (PhaseToolkit.CustomFrame ~= nil and PhaseToolkit.CustomFrame:IsShown()) then
				PhaseToolkit.ToggleCustomFrame(identity.race)
			end
		end
	end
end

-- -- -- -- -- -- -- -- -- -- -- --
--#endregion
-- -- -- -- -- -- -- -- -- -- -- --

-- -- -- -- -- -- -- -- -- -- -- --
--#region Category Common
-- -- -- -- -- -- -- -- -- -- -- --

function PhaseToolkit.CompressForUpload(categoryList)
	local compressedValue=""
	compressedValue = AceSerializer:Serialize(categoryList)
	compressedValue= LibDeflate:CompressDeflate(compressedValue, {level = 9})
	compressedValue = LibDeflate:EncodeForWoWChatChannel(compressedValue)
	return compressedValue;
end

-- -- -- -- -- -- -- -- -- -- -- --
--#endregion
-- -- -- -- -- -- -- -- -- -- -- --
-- -- -- -- -- -- -- -- -- -- -- --
--#region Category System NPC
-- -- -- -- -- -- -- -- -- -- -- --

function PhaseToolkit.CreateNewNpcCategory(name,funcToCall)
    -- Fetch the last max ID from the server
    EpsilonLib.PhaseAddonData.Get(PTK_LAST_MAX_ID_CATEGORY_NPC, function(data)
        local lastMaxId = tonumber(data) or 0
        local newCategoryId = lastMaxId + 1

        -- Create the new category
        local newCategory = {
            id = newCategoryId,
            name = name,
            members = {}
        }

        -- Add the new category to the local category list
        table.insert(PhaseToolkit.NPCcategoryList, newCategory)

        -- Update the server with the new max ID
        EpsilonLib.PhaseAddonData.Set(PTK_LAST_MAX_ID_CATEGORY_NPC, tostring(newCategoryId))
		PhaseToolkit.saveNpcCategoryDataToServer()
		funcToCall()
    end)
end

function PhaseToolkit.getNpcCategoryFromPhaseData(functionToCall)
	EpsilonLib.PhaseAddonData.Get(PTK_NPC_CATEGORY_LIST, function(data)
		if data then
			local decoded = LibDeflate:DecodeForWoWChatChannel(data)
			if decoded then
				local decompressed = LibDeflate:DecompressDeflate(decoded)
				if decompressed then
					local success, result = AceSerializer:Deserialize(decompressed)
					if success then
						PhaseToolkit.NPCcategoryList = result
						functionToCall()
					else
						print("An error occured or no NPC category is saved to Phase")
						PhaseToolkit.NPCcategoryList = {}
					end
				else
					print("An error occured or no NPC category is saved to Phase")
					PhaseToolkit.NPCcategoryList = {}
				end
			else
				print("An error occured or no NPC category is saved to Phase")
				PhaseToolkit.NPCcategoryList = {}
			end
		else
			PhaseToolkit.NPCcategoryList = {}
		end

		PhaseToolkit.categoryPanelNPC:Hide()
		PhaseToolkit.categoryPanelNPC = nil
		for i = 1, 7 do
            local categoryFrame = _G["PTK_CATEGORY_FRAME"..i]
            if categoryFrame then
                categoryFrame:Hide()
                _G["PTK_CATEGORY_FRAME"..i] = nil
            end
        end
		PhaseToolkit.openNpcCategoryPanel()

	end)

end

function PhaseToolkit.saveNpcCategoryDataToServer()
	local serializedData = PhaseToolkit.CompressForUpload(PhaseToolkit.NPCcategoryList)
	EpsilonLib.PhaseAddonData.Set(PTK_NPC_CATEGORY_LIST, serializedData, function(success)
		if success then
			print("Category data successfully saved to the server.")
		else
			print("Failed to save category data to the server.")
		end
	end)
end

function PhaseToolkit.resetNPCFrame()
-- Reset editing state when panel is closed
	PhaseToolkit.NPCselectedCategory = nil
	PhaseToolkit.NPCselectedCategoryIndex = nil
	if PhaseToolkit.categoryPanelNPC and PhaseToolkit.categoryPanelNPC.editingLabel then
		PhaseToolkit.categoryPanelNPC.editingLabel:Hide()
	end
	if(PhaseToolkit.IsCurrentlyFilteringNpcViaText) then
		PhaseToolkit.UpdatePNJPagination(PhaseToolkit.filteredCreatureList)
	else
		PhaseToolkit.UpdatePNJPagination(PhaseToolkit.creatureList)
	end
end

function PhaseToolkit.openNpcCategoryPanel()
	local baseWidth=200
	local minWidth = 220
	if PhaseToolkit.categoryPanelNPC and PhaseToolkit.categoryPanelNPC:IsShown() then
		PhaseToolkit.categoryPanelNPC:Hide()
		PhaseToolkit.categoryPanelNPC = nil
		for i = 1, 7 do
            local categoryFrame = _G["PTK_CATEGORY_FRAME"..i]
            if categoryFrame then
                categoryFrame:Hide()
                _G["PTK_CATEGORY_FRAME"..i] = nil
            end
        end
		PhaseToolkit.resetNPCFrame()
		return
	end
	PhaseToolkit.categoryPanelNPC = CreateFrame("Frame", "CategoryPanel", PhaseToolkit.NPCCustomiserMainFrame, "BasicFrameTemplateWithInset")
	PhaseToolkit.categoryPanelNPC:SetSize(minWidth, 320)
	PhaseToolkit.categoryPanelNPC:SetPoint("TOPLEFT", PhaseToolkit.PNJFrame, "TOPRIGHT", 5, 0)
	PhaseToolkit.categoryPanelNPC:EnableMouse(true)

	PhaseToolkit.categoryPanelNPC:SetScript("OnHide",PhaseToolkit.resetNPCFrame)


	local scrollFrame = CreateFrame("ScrollFrame", "CategoryScrollFrame", PhaseToolkit.categoryPanelNPC, "FauxScrollFrameTemplate")
	scrollFrame:SetSize(PhaseToolkit.categoryPanelNPC:GetWidth() - 20, PhaseToolkit.categoryPanelNPC:GetHeight() - 50)
	scrollFrame:SetPoint("TOPLEFT", PhaseToolkit.categoryPanelNPC, "TOPLEFT", 10, -40)
	scrollFrame.ScrollBar:Hide()

	scrollFrame.ScrollBar = CreateFrame("Slider", nil, scrollFrame, "UIPanelScrollBarTemplate")
	scrollFrame.ScrollBar:SetPoint("TOPLEFT", scrollFrame, "TOPRIGHT", 20, -16)
	scrollFrame.ScrollBar:SetPoint("BOTTOMLEFT", scrollFrame, "BOTTOMRIGHT", 4, 16)
	scrollFrame.ScrollBar:SetMinMaxValues(0, math.floor(#PhaseToolkit.NPCcategoryList/7))
	scrollFrame.ScrollBar:SetValueStep(1)
	scrollFrame.ScrollBar.scrollStep = 1
	scrollFrame.ScrollBar:SetValue(0)
	scrollFrame.ScrollBar:SetWidth(16)
	scrollFrame.ScrollBar:SetScript("OnValueChanged", function(self, value)
		self:GetParent():SetVerticalScroll(value)
	end)



	local content = CreateFrame("Frame", nil, PhaseToolkit.categoryPanelNPC)
	content:SetSize(180, 300) -- Adjust size as needed
	content:SetPoint("TOPLEFT", 5, -5)
	content:Show()

	local categoryFrameHeight = 40
	local categoryFrameSpacing = 5


	local function handleRightClickBehaviour(self,category,categoryFrame,index)
		if(PhaseToolkit.NPCselectedCategoryIndex) then
			if(PhaseToolkit.NPCselectedCategory.id ~= category.id) then
				local reducedIndex = ((PhaseToolkit.NPCselectedCategoryIndex - 1) % 7) + 1
				local lastCategoryFrame = _G["PTK_CATEGORY_FRAME" .. reducedIndex]
				if(lastCategoryFrame) then
					lastCategoryFrame:SetBackdropBorderColor(1, 1, 1, 1)
				end
				PhaseToolkit.NPCselectedCategory = nil
				PhaseToolkit.NPCselectedCategoryIndex = nil

				if(PhaseToolkit.IsCurrentlyFilteringNpcViaText) then
					PhaseToolkit.UpdatePNJPagination(PhaseToolkit.filteredCreatureList)
				else
					PhaseToolkit.UpdatePNJPagination(PhaseToolkit.creatureList)
				end
				PhaseToolkit.categoryPanelNPC.editingLabel:Show()
			else
				categoryFrame:SetBackdropBorderColor(1, 1, 1, 1)
				PhaseToolkit.NPCselectedCategory = nil
				PhaseToolkit.NPCselectedCategoryIndex = nil
				if(PhaseToolkit.IsCurrentlyFilteringNpcViaText) then
					PhaseToolkit.UpdatePNJPagination(PhaseToolkit.filteredCreatureList)
				else
					PhaseToolkit.UpdatePNJPagination(PhaseToolkit.creatureList)
				end
				PhaseToolkit.categoryPanelNPC.editingLabel:Hide()
				return
			end
		end
		categoryFrame:SetBackdropBorderColor(0, 1, 1, 1)
		PhaseToolkit.NPCselectedCategory = category
		PhaseToolkit.NPCselectedCategoryIndex = index
		if(PhaseToolkit.IsCurrentlyFilteringNpcViaText) then
			PhaseToolkit.UpdatePNJPagination(PhaseToolkit.filteredCreatureList)
		else
			PhaseToolkit.UpdatePNJPagination(PhaseToolkit.creatureList)
		end
		PhaseToolkit.categoryPanelNPC.editingLabel:Show()
	end

	local function getCategoryById(categoryId)
		for _, category in ipairs(PhaseToolkit.NPCcategoryList) do
			if category.id == categoryId then
				return category
			end
		end
		return nil
	end

	local function handleCategoryPoolChange()
		if #PhaseToolkit.NPCcategoryToFilterPool == 0 then
			-- No category selected, revert to casual listing
			if PhaseToolkit.IsCurrentlyFilteringNpcViaText then
				-- Filter by NPC name only
				PhaseToolkit.filteredCreatureList = {}
				for _, npc in ipairs(PhaseToolkit.creatureList) do
					if string.find(npc.NomCreature:lower(), PhaseToolkit.CurrenttextToLookForNpc:lower()) then
						table.insert(PhaseToolkit.filteredCreatureList, npc)
					end
				end
				PhaseToolkit.UpdatePNJPagination(PhaseToolkit.filteredCreatureList)
			else
				-- Revert to full list
				PhaseToolkit.UpdatePNJPagination(PhaseToolkit.creatureList)
			end
			return
		end

		if PhaseToolkit.IsCurrentlyFilteringNpcViaText then
			-- Merge filtering by NPC name and category pool
			PhaseToolkit.filteredCreatureList = {}
			for _, npc in ipairs(PhaseToolkit.creatureList) do
				local isInCategoryPool = false
				for _, categoryId in ipairs(PhaseToolkit.NPCcategoryToFilterPool) do
					local category = getCategoryById(categoryId)
					if category and isStringInArray(category.members, npc.IdCreature) > 0 then
						isInCategoryPool = true
						break
					end
				end
				if isInCategoryPool and string.find(npc.NomCreature:lower(), PhaseToolkit.CurrenttextToLookForNpc:lower()) then
					table.insert(PhaseToolkit.filteredCreatureList, npc)
				end
			end
		else
			-- Filter only by category pool
			PhaseToolkit.filteredCreatureList = {}
			for _, npc in ipairs(PhaseToolkit.creatureList) do
				local isInCategoryPool = false
				for _, categoryId in ipairs(PhaseToolkit.NPCcategoryToFilterPool) do
					local category = getCategoryById(categoryId)
					if category and isStringInArray(category.members, npc.IdCreature) > 0 then
						isInCategoryPool = true
						break
					end
				end
				if isInCategoryPool then
					table.insert(PhaseToolkit.filteredCreatureList, npc)
				end
			end
		end
		PhaseToolkit.UpdatePNJPagination(PhaseToolkit.filteredCreatureList)
	end


	local function handleLeftClickBehaviour(self,category,categoryFrame,index)
		if PhaseToolkit.categoryPanelNPC.editingLabel:IsShown() then
			PhaseToolkit.categoryPanelNPC.editingLabel:Hide()
		end
		if(PhaseToolkit.NPCselectedCategoryIndex) then
			local lastCategoryFrame = _G["PTK_CATEGORY_FRAME"..PhaseToolkit.NPCselectedCategoryIndex]
			if(lastCategoryFrame) then
				lastCategoryFrame:SetBackdropBorderColor(1, 1, 1, 1)
			end
			PhaseToolkit.NPCselectedCategory = nil
			PhaseToolkit.NPCselectedCategoryIndex = nil
		end
		-- if already in the pool we take it out
		local indexInPool = isStringInArray(PhaseToolkit.NPCcategoryToFilterPool,category.id)
		-- if in the pool we delete it
		if(indexInPool>0) then
			tremove(PhaseToolkit.NPCcategoryToFilterPool,indexInPool);
			categoryFrame:SetBackdropBorderColor(1, 1, 1, 1)
			handleCategoryPoolChange()
		else
			local r,g,b,a = RGBAToNormalized(249,226,0,255)
			categoryFrame:SetBackdropBorderColor(r,g,b,a)
			tinsert(PhaseToolkit.NPCcategoryToFilterPool,category.id);
			handleCategoryPoolChange()
		end
	end

	function  PhaseToolkit.updateNPCCategoryList()
		local scrollOffset = scrollFrame.ScrollBar:GetValue();
		local categoryNameForResize={};
		for i = 1, 7 do
			local index = scrollOffset*7+i;
			local categoryFrame = _G["PTK_CATEGORY_FRAME"..i];
			if not categoryFrame then
				categoryFrame = CreateFrame("Frame", "PTK_CATEGORY_FRAME"..i, content, "BackdropTemplate");
				categoryFrame:SetBackdrop({
					bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
					edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
					edgeSize = 16,
					insets = { left = 5, right = 5, top = 5, bottom = 5 },
				});
				categoryFrame:SetSize(content:GetWidth(), categoryFrameHeight);
				categoryFrame:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -20-((i - 1)*40));

				categoryFrame.categoryName = categoryFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal");
				categoryFrame.categoryName:SetPoint("LEFT", categoryFrame, "LEFT", 10, 0);

				categoryFrame.npcCountText = categoryFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall");
				categoryFrame.npcCountText:SetPoint("RIGHT", categoryFrame, "RIGHT", -50, 0);

				categoryFrame.deleteButton = CreateFrame("Button", nil, categoryFrame, "UIPanelButtonTemplate");
				categoryFrame.deleteButton:SetSize(20, 20);
				categoryFrame.deleteButton:SetPoint("RIGHT", categoryFrame, "RIGHT", -10, 0);
				categoryFrame.deleteButton:SetText("X");
			end

			if index <= #PhaseToolkit.NPCcategoryList then
				local category = PhaseToolkit.NPCcategoryList[index];
				tinsert(categoryNameForResize,category.name);
				categoryFrame.categoryName:SetText(category.name);
				categoryFrame.npcCountText:SetText(#category.members .. " NPCs");
				-- If the category is not in the filtering pool, set border color to default
				if isStringInArray(PhaseToolkit.NPCcategoryToFilterPool, category.id) < 1 then
					categoryFrame:SetBackdropBorderColor(1, 1, 1, 1)
				else
					local r,g,b,a = RGBAToNormalized(249,226,0,255)
					categoryFrame:SetBackdropBorderColor(r,g,b,a)
				end
				if PhaseToolkit.NPCselectedCategory and PhaseToolkit.NPCselectedCategory.id == category.id then
					categoryFrame:SetBackdropBorderColor(0, 1, 1, 1)
				end

				categoryFrame.deleteButton:SetScript("OnClick", function()
					StaticPopup_Show("CONFIRM_DELETE_CATEGORY_NPC", nil, nil, { deleteIndex = index, funcOnYes = PhaseToolkit.updateNPCCategoryList })
				end);

				if(#category.members>200) then
					PhaseToolkit.RegisterTooltip(categoryFrame, "This category is big (>200 Npcs), add and delete npc from it with care, it can cause crashes if done too fast.")

				end


				categoryFrame:SetScript("OnMouseDown", function(self, button)
					if button == "RightButton"  and PhaseToolkit.UserHasPermission() then
						handleRightClickBehaviour(self, category, categoryFrame, index)

					else
						handleLeftClickBehaviour(self, category, categoryFrame, index)
					end
				end);
				categoryFrame:Show();
			else
				categoryFrame:Hide();
			end
		end
		if(PhaseToolkit.NPCcategoryList and #PhaseToolkit.NPCcategoryList > 0) then
			local size = (#categoryNameForResize > 0) and (PhaseToolkit.GetMaxStringLength(categoryNameForResize)>180+50) and PhaseToolkit.GetMaxStringLength(categoryNameForResize) or minWidth+20
			PhaseToolkit.categoryPanelNPC:SetWidth(size+50+20);
			for i = 1, 7 do
				local categoryFrame = _G["PTK_CATEGORY_FRAME"..i]
				if categoryFrame then
					categoryFrame:SetWidth(size+50);
				end
			end
		end

		FauxScrollFrame_Update(scrollFrame, #PhaseToolkit.NPCcategoryList, 7, categoryFrameHeight)
	end

	scrollFrame:SetScript("OnVerticalScroll", function(self, offset)
		FauxScrollFrame_OnVerticalScroll(self, offset, 40, PhaseToolkit.updateNPCCategoryList)
	end)

	PhaseToolkit.updateNPCCategoryList()

	scrollFrame.ScrollBar:ClearAllPoints()
	scrollFrame.ScrollBar:SetPoint("TOPRIGHT", PhaseToolkit.categoryPanelNPC, "TOPRIGHT", -10, -45)
	scrollFrame.ScrollBar:SetPoint("BOTTOMRIGHT", PhaseToolkit.categoryPanelNPC, "BOTTOMRIGHT",-10, 25)

	local createCategoryButton = CreateFrame("Button", nil, PhaseToolkit.categoryPanelNPC, "UIPanelButtonTemplate")
	createCategoryButton:SetSize(20, 20)
	createCategoryButton:SetPoint("TOPLEFT", PhaseToolkit.categoryPanelNPC, "TOPLEFT", 0, 0)
	createCategoryButton.icon = createCategoryButton:CreateTexture(nil, "OVERLAY")
	createCategoryButton.icon:SetAtlas("GreenCross")
	createCategoryButton.icon:SetAllPoints()
	local inputFrame=nil

	createCategoryButton:SetScript("OnClick", function()
		-- Create a small frame for entering the category name
		if(not inputFrame) then
			inputFrame = CreateFrame("Frame", "CategoryInputFrame", PhaseToolkit.categoryPanelNPC, "BackdropTemplate")
			inputFrame:SetSize(200, 50)
			inputFrame:SetPoint("BOTTOM", PhaseToolkit.categoryPanelNPC, "TOP", 0, 2.5)
			inputFrame:SetBackdrop({
				bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
				edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
				edgeSize = 16,
				insets = { left = 5, right = 5, top = 5, bottom = 5 },
			})

			-- Create an editbox for entering the category name
			inputFrame.editBox = CreateFrame("EditBox", nil, inputFrame, "InputBoxTemplate")
			inputFrame.editBox:SetSize(180, 30)
			inputFrame.editBox:SetPoint("CENTER", inputFrame, "CENTER", 0, 0)
			inputFrame.editBox:SetAutoFocus(true)

			-- Create a label for the editbox
			local label = inputFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
			label:SetPoint("TOP", inputFrame.editBox, "TOP", 0, 20)
			label:SetText("Enter Category Name:")

			-- Handle the input when the user presses Enter
			inputFrame.editBox:SetScript("OnEnterPressed", function(self)
				local categoryName = self:GetText()
				if categoryName and categoryName ~= "" then
					PhaseToolkit.CreateNewNpcCategory(categoryName,PhaseToolkit.updateNPCCategoryList)

				end
				self:ClearFocus()
				inputFrame:Hide()
			end)

			-- Close the frame when the user presses Escape
			inputFrame.editBox:SetScript("OnEscapePressed", function(self)
				self:ClearFocus()
				inputFrame:Hide()
			end)
		else if (inputFrame:IsShown()) then
			inputFrame:Hide()
			inputFrame.editBox:SetText("") -- Clear the input box
		else
			inputFrame:Show()
			inputFrame.editBox:SetText("") -- Clear the input box
		end
	end
	end)

	PhaseToolkit.RegisterTooltip(createCategoryButton, "Create Category")

	local fetchCategoryButton = CreateFrame("Button", nil, PhaseToolkit.categoryPanelNPC, "UIPanelButtonTemplate")
	fetchCategoryButton:SetSize(20, 20)
	fetchCategoryButton:SetPoint("LEFT", createCategoryButton, "RIGHT", 5, 0)
	fetchCategoryButton.icon = fetchCategoryButton:CreateTexture(nil, "OVERLAY")
	fetchCategoryButton.icon:SetAtlas("poi-door-arrow-down")
	fetchCategoryButton.icon:SetPoint("CENTER", fetchCategoryButton,"CENTER", 0, 0)
	fetchCategoryButton.icon:SetSize(16, 16)
	fetchCategoryButton:SetScript("OnClick", function()
		-- Fetch the category list from the server
		PhaseToolkit.getNpcCategoryFromPhaseData(PhaseToolkit.updateNPCCategoryList)
	end)
	PhaseToolkit.RegisterTooltip(fetchCategoryButton, "Fetch Categories")

	-- Create the button
	local roundButton = CreateFrame("Button", nil, PhaseToolkit.categoryPanelNPC, "UIPanelButtonTemplate")
	roundButton:SetSize(20, 20) -- Set the size of the button
	roundButton:SetPoint("LEFT", fetchCategoryButton, "RIGHT", 5, 0) -- Position it in the center of the screen

	-- Add the icon texture
	roundButton.icon = roundButton:CreateTexture(nil, "ARTWORK")
	roundButton.icon:SetAtlas("NPE_TurnIn") -- Use the desired atlas texture
	roundButton.icon:SetAllPoints(roundButton) -- Make the texture fill the button

	-- Create a circular mask
	local mask = roundButton:CreateMaskTexture()
	mask:SetTexture("Interface\\CHARACTERFRAME\\TempPortraitAlphaMask", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
	mask:SetAllPoints(roundButton) -- Match the button's size and position

	-- Apply the mask to the icon
	roundButton.icon:AddMaskTexture(mask)

	roundButton:SetScript("OnEnter",PhaseToolkit.ShowCategoryCustomTooltip)
	roundButton:SetScript("OnLeave", function(self)
		GameTooltip:Hide()
	end)

	local editingLabel = PhaseToolkit.categoryPanelNPC:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	editingLabel:SetPoint("TOPRIGHT", PhaseToolkit.categoryPanelNPC, "TOPRIGHT", -30, -5)
	editingLabel:SetText("EDITING")
	editingLabel:SetTextColor(1, 0, 0) -- Bright red
	editingLabel:Hide()

	PhaseToolkit.categoryPanelNPC.editingLabel = editingLabel


end
-- -- -- -- -- -- -- -- -- -- -- --
--#endregion
-- -- -- -- -- -- -- -- -- -- -- --

-- -- -- -- -- -- -- -- -- -- -- --
--#region Category System TELE
-- -- -- -- -- -- -- -- -- -- -- --
function PhaseToolkit.CreateNewTELECategory(name,funcToCall)
    -- Fetch the last max ID from the server
    EpsilonLib.PhaseAddonData.Get(PTK_LAST_MAX_ID_CATEGORY_TELE, function(data)
        local lastMaxId = tonumber(data) or 0
        local newCategoryId = lastMaxId + 1

        -- Create the new category
        local newCategory = {
            id = newCategoryId,
            name = name,
            members = {}
        }

        -- Add the new category to the local category list
        table.insert(PhaseToolkit.TELEcategoryList, newCategory)

        -- Update the server with the new max ID
        EpsilonLib.PhaseAddonData.Set(PTK_LAST_MAX_ID_CATEGORY_TELE, tostring(newCategoryId))
		PhaseToolkit.saveTELECategoryDataToServer()
		funcToCall()
    end)
end

function PhaseToolkit.getTeleCategoryFromPhaseData(functionToCall)
	EpsilonLib.PhaseAddonData.Get(PTK_TELE_CATEGORY_LIST, function(data)
		if data then
			local decoded = LibDeflate:DecodeForWoWChatChannel(data)
			if decoded then
				local decompressed = LibDeflate:DecompressDeflate(decoded)
				if decompressed then
					local success, result = AceSerializer:Deserialize(decompressed)
					if success then
						PhaseToolkit.TELEcategoryList = result
						functionToCall()
					else
						print("An error occured or no Tele category is saved to Phase")
						PhaseToolkit.TELEcategoryList = {}
					end
				else
					print("An error occured or no Tele category is saved to Phase")
					PhaseToolkit.TELEcategoryList = {}
				end
			else
				print("An error occured or no Tele category is saved to Phase")
				PhaseToolkit.TELEcategoryList = {}
			end
		else
			PhaseToolkit.TELEcategoryList = {}
		end

		PhaseToolkit.categoryPanelTELE:Hide()
		PhaseToolkit.categoryPanelTELE = nil
		for i = 1, 7 do
            local categoryFrame = _G["PTK_CATEGORY_FRAME"..i]
            if categoryFrame then
                categoryFrame:Hide()
                _G["PTK_CATEGORY_FRAME"..i] = nil
            end
        end
		PhaseToolkit.openTeleCategoryPanel()
	end)
end

function PhaseToolkit.saveTELECategoryDataToServer()
	local serializedData = PhaseToolkit.CompressForUpload(PhaseToolkit.TELEcategoryList)
	EpsilonLib.PhaseAddonData.Set(PTK_TELE_CATEGORY_LIST, serializedData, function(success)
		if not success then
			print("Something failed while sending data to server. Please retry later and report the bug if the problem persists.")
		end
	end)
end

function PhaseToolkit.resetTELEFrame()
	-- Reset editing state when panel is closed
	PhaseToolkit.TELEselectedCategory = nil
	PhaseToolkit.TELEselectedCategoryIndex = nil
	if PhaseToolkit.categoryPanelTELE and PhaseToolkit.categoryPanelTELE.editingLabel then
		PhaseToolkit.categoryPanelTELE.editingLabel:Hide()
	end
	if(PhaseToolkit.IsCurrentlyFilteringTeleViaText) then
		PhaseToolkit.TeleUpdatePagination(PhaseToolkit.filteredTeleList)
	else
		PhaseToolkit.TeleUpdatePagination(PhaseToolkit.teleList)
	end
end

function PhaseToolkit.openTeleCategoryPanel()
	local baseWidth=200
	local minWidth = 220
	if PhaseToolkit.categoryPanelTELE and PhaseToolkit.categoryPanelTELE:IsShown() then
		PhaseToolkit.categoryPanelTELE:Hide()
		PhaseToolkit.categoryPanelTELE = nil
		for i = 1, 7 do
            local categoryFrame = _G["PTK_CATEGORY_FRAME"..i]
            if categoryFrame then
                categoryFrame:Hide()
                _G["PTK_CATEGORY_FRAME"..i] = nil
            end
        end
		PhaseToolkit.resetTELEFrame();
		return
	end
	PhaseToolkit.categoryPanelTELE = CreateFrame("Frame", "CategoryPanel", PhaseToolkit.NPCCustomiserMainFrame, "BasicFrameTemplateWithInset")
	PhaseToolkit.categoryPanelTELE:SetSize(minWidth, 320)
	PhaseToolkit.categoryPanelTELE:SetPoint("TOPLEFT", PhaseToolkit.TELEFrame, "TOPRIGHT", 5, 0)
	PhaseToolkit.categoryPanelTELE:EnableMouse(true)

	PhaseToolkit.categoryPanelTELE:SetScript("OnHide",PhaseToolkit.resetTELEFrame)

	local scrollFrame = CreateFrame("ScrollFrame", "CategoryScrollFrame", PhaseToolkit.categoryPanelTELE, "FauxScrollFrameTemplate")
	scrollFrame:SetSize(PhaseToolkit.categoryPanelTELE:GetWidth() - 20, PhaseToolkit.categoryPanelTELE:GetHeight() - 50)
	scrollFrame:SetPoint("TOPLEFT", PhaseToolkit.categoryPanelTELE, "TOPLEFT", 10, -40)
	scrollFrame.ScrollBar:Hide()

	scrollFrame.ScrollBar = CreateFrame("Slider", nil, scrollFrame, "UIPanelScrollBarTemplate")
	scrollFrame.ScrollBar:SetPoint("TOPLEFT", scrollFrame, "TOPRIGHT", 20, -16)
	scrollFrame.ScrollBar:SetPoint("BOTTOMLEFT", scrollFrame, "BOTTOMRIGHT", 4, 16)
	scrollFrame.ScrollBar:SetMinMaxValues(0, math.floor(#PhaseToolkit.TELEcategoryList/7))
	scrollFrame.ScrollBar:SetValueStep(1)
	scrollFrame.ScrollBar.scrollStep = 1
	scrollFrame.ScrollBar:SetValue(0)
	scrollFrame.ScrollBar:SetWidth(16)
	scrollFrame.ScrollBar:SetScript("OnValueChanged", function(self, value)
		self:GetParent():SetVerticalScroll(value)
	end)

	local content = CreateFrame("Frame", nil, PhaseToolkit.categoryPanelTELE)
	content:SetSize(180, 300) -- Adjust size as needed
	content:SetPoint("TOPLEFT", 5, -5)
	content:Show()

	local categoryFrameHeight = 40
	local categoryFrameSpacing = 5


	local function handleRightClickBehaviour(self,category,categoryFrame,index)
		if(PhaseToolkit.TELEselectedCategoryIndex) then
			if(PhaseToolkit.TELEselectedCategory.id ~= category.id) then
				local lastCategoryFrame = _G["PTK_CATEGORY_FRAME"..PhaseToolkit.TELEselectedCategoryIndex]
				if(lastCategoryFrame) then
					lastCategoryFrame:SetBackdropBorderColor(1, 1, 1, 1)
				end
				PhaseToolkit.TELEselectedCategory = nil
				PhaseToolkit.TELEselectedCategoryIndex = nil

				if(PhaseToolkit.IsCurrentlyFilteringTeleViaText) then
					PhaseToolkit.TeleUpdatePagination(PhaseToolkit.filteredTeleList)
				else
					PhaseToolkit.TeleUpdatePagination(PhaseToolkit.teleList)
				end
				PhaseToolkit.categoryPanelTELE.editingLabel:Show()
			else
				categoryFrame:SetBackdropBorderColor(1, 1, 1, 1)
				PhaseToolkit.TELEselectedCategory = nil
				PhaseToolkit.TELEselectedCategoryIndex = nil
				if(PhaseToolkit.IsCurrentlyFilteringTeleViaText) then
					PhaseToolkit.TeleUpdatePagination(PhaseToolkit.filteredTeleList)
				else
					PhaseToolkit.TeleUpdatePagination(PhaseToolkit.teleList)
				end
				PhaseToolkit.categoryPanelTELE.editingLabel:Hide()
				return
			end
		end
		categoryFrame:SetBackdropBorderColor(0, 1, 1, 1)
		PhaseToolkit.TELEselectedCategory = category
		PhaseToolkit.TELEselectedCategoryIndex = index
		if(PhaseToolkit.IsCurrentlyFilteringTeleViaText) then
			PhaseToolkit.TeleUpdatePagination(PhaseToolkit.filteredTeleList)
		else
			PhaseToolkit.TeleUpdatePagination(PhaseToolkit.teleList)
		end
		PhaseToolkit.categoryPanelTELE.editingLabel:Show()
	end

	local function getCategoryById(categoryId)
		for _, category in ipairs(PhaseToolkit.TELEcategoryList) do
			if category.id == categoryId then
				return category
			end
		end
		return nil
	end

	local function handleCategoryPoolChange()
		if #PhaseToolkit.TELEcategoryToFilterPool == 0 then
			-- No category selected, revert to casual listing
			if PhaseToolkit.IsCurrentlyFilteringTeleViaText then
				-- Filter by NPC name only
				PhaseToolkit.filteredTeleList = {}
				for _, tele in ipairs(PhaseToolkit.teleList) do
					if string.find(tele:lower(), PhaseToolkit.CurrenttextToLookForTele:lower()) then
						table.insert(PhaseToolkit.filteredTeleList, tele)
					end
				end
				PhaseToolkit.TeleUpdatePagination(PhaseToolkit.filteredTeleList)
			else
				-- Revert to full list
				PhaseToolkit.TeleUpdatePagination(PhaseToolkit.teleList)
			end
			return
		end

		if PhaseToolkit.IsCurrentlyFilteringTeleViaText then
			-- Merge filtering by NPC name and category pool
			PhaseToolkit.filteredTeleList = {}
			for _, tele in ipairs(PhaseToolkit.teleList) do
				local isInCategoryPool = false
				for _, categoryId in ipairs(PhaseToolkit.TELEcategoryToFilterPool) do
					local category = getCategoryById(categoryId)
					if category and isStringInArray(category.members, tele) > 0 then
						isInCategoryPool = true
						break
					end
				end
				if isInCategoryPool and string.find(tele:lower(), PhaseToolkit.CurrenttextToLookForTele:lower()) then
					table.insert(PhaseToolkit.filteredTeleList, tele)
				end
			end
		elseif #PhaseToolkit.TELEcategoryToFilterPool > 0 then
			-- Filter only by category pool
			PhaseToolkit.filteredTeleList = {}
			for _, tele in ipairs(PhaseToolkit.teleList) do
				for _, categoryId in ipairs(PhaseToolkit.TELEcategoryToFilterPool) do
					local category = getCategoryById(categoryId)
					if category and isStringInArray(category.members, tele) > 0 then
						table.insert(PhaseToolkit.filteredTeleList, tele)
						break
					end
				end
			end
		else
			-- Filter only by category pool
			PhaseToolkit.filteredTeleList = {}
			for _, tele in ipairs(PhaseToolkit.teleList) do
				local isInCategoryPool = false
				for _, categoryId in ipairs(PhaseToolkit.TELEcategoryToFilterPool) do
					local category = getCategoryById(categoryId)
					if category and isStringInArray(category.members, tele) > 0 then
						isInCategoryPool = true
						break
					end
				end
				if isInCategoryPool then
					table.insert(PhaseToolkit.filteredTeleList, tele)
				end
			end
		end
		PhaseToolkit.TeleUpdatePagination(PhaseToolkit.filteredTeleList)
	end


	local function handleLeftClickBehaviour(self,category,categoryFrame,index)
		if(PhaseToolkit.TELEselectedCategoryIndex) then
			local lastCategoryFrame = _G["PTK_CATEGORY_FRAME"..PhaseToolkit.TELEselectedCategoryIndex]
			if(lastCategoryFrame) then
				lastCategoryFrame:SetBackdropBorderColor(1, 1, 1, 1)
			end
			PhaseToolkit.TELEselectedCategory = nil
			PhaseToolkit.TELEselectedCategoryIndex = nil
		end
		-- if already in the pool we take it out
		local indexInPool = isStringInArray(PhaseToolkit.TELEcategoryToFilterPool,category.id)
		-- if in the pool we delete it
		if(indexInPool>0) then
			tremove(PhaseToolkit.TELEcategoryToFilterPool,indexInPool);
			categoryFrame:SetBackdropBorderColor(1, 1, 1, 1)
			handleCategoryPoolChange()
		else
			local r,g,b,a = RGBAToNormalized(249,226,0,255)
			categoryFrame:SetBackdropBorderColor(r,g,b,a)
			tinsert(PhaseToolkit.TELEcategoryToFilterPool,category.id);
			handleCategoryPoolChange()
		end
	end

	function  PhaseToolkit.updateTELECategoryList()

		local scrollOffset = scrollFrame.ScrollBar:GetValue();
		local categoryNameForResize={};
		for i = 1, 7 do
			local index = scrollOffset*7+i;
			local categoryFrame = _G["PTK_CATEGORY_FRAME"..i];
			if not categoryFrame then
				categoryFrame = CreateFrame("Frame", "PTK_CATEGORY_FRAME"..i, content, "BackdropTemplate");
				categoryFrame:SetBackdrop({
					bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
					edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
					edgeSize = 16,
					insets = { left = 5, right = 5, top = 5, bottom = 5 },
				});
				categoryFrame:SetSize(content:GetWidth(), categoryFrameHeight);
				categoryFrame:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -20-((i - 1)*40));

				categoryFrame.categoryName = categoryFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal");
				categoryFrame.categoryName:SetPoint("LEFT", categoryFrame, "LEFT", 10, 0);

				categoryFrame.npcCountText = categoryFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall");
				categoryFrame.npcCountText:SetPoint("RIGHT", categoryFrame, "RIGHT", -50, 0);

				categoryFrame.deleteButton = CreateFrame("Button", nil, categoryFrame, "UIPanelButtonTemplate");
				categoryFrame.deleteButton:SetSize(20, 20);
				categoryFrame.deleteButton:SetPoint("RIGHT", categoryFrame, "RIGHT", -10, 0);
				categoryFrame.deleteButton:SetText("X");
			end

			if index <= #PhaseToolkit.TELEcategoryList then
				local category = PhaseToolkit.TELEcategoryList[index];
				tinsert(categoryNameForResize,category.name);
				categoryFrame.categoryName:SetText(category.name);
				categoryFrame.npcCountText:SetText(#category.members .. " Teles");
				-- If the category is not in the filtering pool, set border color to default
				if isStringInArray(PhaseToolkit.TELEcategoryToFilterPool, category.id) < 1 then
					categoryFrame:SetBackdropBorderColor(1, 1, 1, 1)
				else
					local r,g,b,a = RGBAToNormalized(249,226,0,255)
					categoryFrame:SetBackdropBorderColor(r,g,b,a)
				end
				if PhaseToolkit.TELEselectedCategory and PhaseToolkit.TELEselectedCategory.id == category.id then
					categoryFrame:SetBackdropBorderColor(0, 1, 1, 1)
				end
				categoryFrame.deleteButton:SetScript("OnClick", function()
					StaticPopup_Show("CONFIRM_DELETE_CATEGORY_TELE", nil, nil, { deleteIndex = index, funcOnYes = PhaseToolkit.updateTELECategoryList })
				end);

				if(#category.members>200) then
					PhaseToolkit.RegisterTooltip(categoryFrame, "This category is big (>200 Tele), add and delete tele from it with care, it can cause crashes if done too fast.")
				end

				categoryFrame:SetScript("OnMouseDown", function(self, button)
					if button == "RightButton" and PhaseToolkit.UserHasPermission() then
						handleRightClickBehaviour(self, category, categoryFrame, index)
					else
						handleLeftClickBehaviour(self, category, categoryFrame, index)
					end
				end);
				categoryFrame:Show();
			else
				categoryFrame:Hide();
			end
		end
		if(PhaseToolkit.TELEcategoryList and #PhaseToolkit.TELEcategoryList > 0) then
			local size = (#categoryNameForResize > 0) and ( PhaseToolkit.GetMaxStringLength(categoryNameForResize)>180+50) and  PhaseToolkit.GetMaxStringLength(categoryNameForResize) or minWidth+20
			PhaseToolkit.categoryPanelTELE:SetWidth(size+50+20);
			for i = 1, 7 do
				local categoryFrame = _G["PTK_CATEGORY_FRAME"..i]
				if categoryFrame then
					categoryFrame:SetWidth(size+50);
				end
			end
		end

		FauxScrollFrame_Update(scrollFrame, #PhaseToolkit.TELEcategoryList, 7, categoryFrameHeight)
	end

	scrollFrame:SetScript("OnVerticalScroll", function(self, offset)
		FauxScrollFrame_OnVerticalScroll(self, offset, 40, PhaseToolkit.updateTELECategoryList)
	end)

	PhaseToolkit.updateTELECategoryList()

	scrollFrame.ScrollBar:ClearAllPoints()
	scrollFrame.ScrollBar:SetPoint("TOPRIGHT", PhaseToolkit.categoryPanelTELE, "TOPRIGHT", -10, -45)
	scrollFrame.ScrollBar:SetPoint("BOTTOMRIGHT", PhaseToolkit.categoryPanelTELE, "BOTTOMRIGHT",-10, 25)

	local createCategoryButton = CreateFrame("Button", nil, PhaseToolkit.categoryPanelTELE, "UIPanelButtonTemplate")
	createCategoryButton:SetSize(20, 20)
	createCategoryButton:SetPoint("TOPLEFT", PhaseToolkit.categoryPanelTELE, "TOPLEFT", 0, 0)
	createCategoryButton.icon = createCategoryButton:CreateTexture(nil, "OVERLAY")
	createCategoryButton.icon:SetAtlas("GreenCross")
	createCategoryButton.icon:SetAllPoints()
	createCategoryButton:SetScript("OnClick", function()
		-- Create a small frame for entering the category name
		local inputFrame = CreateFrame("Frame", "CategoryInputFrame", PhaseToolkit.categoryPanelTELE, "BackdropTemplate")
		inputFrame:SetSize(200, 50)
		inputFrame:SetPoint("BOTTOM", PhaseToolkit.categoryPanelTELE, "TOP", 0, 2.5)
		inputFrame:SetBackdrop({
			bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
			edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
			edgeSize = 16,
			insets = { left = 5, right = 5, top = 5, bottom = 5 },
		})

		-- Create an editbox for entering the category name
		local editBox = CreateFrame("EditBox", nil, inputFrame, "InputBoxTemplate")
		editBox:SetSize(180, 30)
		editBox:SetPoint("CENTER", inputFrame, "CENTER", 0, 0)
		editBox:SetAutoFocus(true)

		-- Create a label for the editbox
		local label = inputFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
		label:SetPoint("TOP", editBox, "TOP", 0, 20)
		label:SetText("Enter Category Name:")

		-- Handle the input when the user presses Enter
		editBox:SetScript("OnEnterPressed", function(self)
			local categoryName = self:GetText()
			if categoryName and categoryName ~= "" then
				PhaseToolkit.CreateNewTELECategory(categoryName,PhaseToolkit.updateTELECategoryList)

			end
			self:ClearFocus()
			inputFrame:Hide()
		end)

		-- Close the frame when the user presses Escape
		editBox:SetScript("OnEscapePressed", function(self)
			self:ClearFocus()
			inputFrame:Hide()
		end)
	end)
	PhaseToolkit.RegisterTooltip(createCategoryButton, "Create Category")

	local fetchCategoryButton = CreateFrame("Button", nil, PhaseToolkit.categoryPanelTELE, "UIPanelButtonTemplate")
	fetchCategoryButton:SetSize(20, 20)
	fetchCategoryButton:SetPoint("LEFT", createCategoryButton, "RIGHT", 5, 0)
	fetchCategoryButton.icon = fetchCategoryButton:CreateTexture(nil, "OVERLAY")
	fetchCategoryButton.icon:SetAtlas("poi-door-arrow-down")
	fetchCategoryButton.icon:SetPoint("CENTER", fetchCategoryButton,"CENTER", 0, 0)
	fetchCategoryButton.icon:SetSize(16, 16)
	fetchCategoryButton:SetScript("OnClick", function()
		-- Fetch the category list from the server
		PhaseToolkit.getTeleCategoryFromPhaseData(PhaseToolkit.updateTELECategoryList)
	end)
	PhaseToolkit.RegisterTooltip(fetchCategoryButton, "Fetch Categories")

	-- Create the button
	local roundButton = CreateFrame("Button", nil, PhaseToolkit.categoryPanelTELE, "UIPanelButtonTemplate")
	roundButton:SetSize(20, 20) -- Set the size of the button
	roundButton:SetPoint("LEFT", fetchCategoryButton, "RIGHT", 5, 0) -- Position it in the center of the screen

	-- Add the icon texture
	roundButton.icon = roundButton:CreateTexture(nil, "ARTWORK")
	roundButton.icon:SetAtlas("NPE_TurnIn") -- Use the desired atlas texture
	roundButton.icon:SetAllPoints(roundButton) -- Make the texture fill the button

	-- Create a circular mask
	local mask = roundButton:CreateMaskTexture()
	mask:SetTexture("Interface\\CHARACTERFRAME\\TempPortraitAlphaMask", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
	mask:SetAllPoints(roundButton) -- Match the button's size and position

	-- Apply the mask to the icon
	roundButton.icon:AddMaskTexture(mask)

	roundButton:SetScript("OnEnter",PhaseToolkit.ShowCategoryCustomTooltip)
	roundButton:SetScript("OnLeave", function(self)
		GameTooltip:Hide()
	end)

	local editingLabel = PhaseToolkit.categoryPanelTELE:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	editingLabel:SetPoint("TOPRIGHT", PhaseToolkit.categoryPanelTELE, "TOPRIGHT", -10, -10)
	editingLabel:SetText("EDITING")
	editingLabel:SetTextColor(1, 0, 0) -- Bright red
	editingLabel:Hide()

	PhaseToolkit.categoryPanelTELE.editingLabel = editingLabel

end

function PhaseToolkit.ShowCategoryCustomTooltip(frame)
    -- Clear the tooltip to avoid overlapping content
    GameTooltip:ClearLines()
    GameTooltip:SetOwner(frame, "ANCHOR_RIGHT")

    -- Add a title to the tooltip
    GameTooltip:AddLine("How in the Phase Hell do I use this ?", 1, 1, 0) -- Yellow text

    -- Add a line with an icon for the left mouse button
    GameTooltip:AddLine(CreateAtlasMarkup("NPE_LeftClick").. " |cFFFFA500Left-click|r to filter the list with this category (you can select multiple)", 1, 1, 1) -- White text

    -- Add a line with an icon for the right mouse button
	GameTooltip:AddLine(CreateAtlasMarkup("NPE_RightClick") .. " |cFFFFA500Right-click|r to select / deselect a category to modify (Only one category at a time)", 1, 1, 1) -- White text
	GameTooltip:AddLine("Modifying a category will bring up buttons to add element into the selected category",1,1,1)
	GameTooltip:AddLine("and to take it out of the selected category",1,1,1)

    -- Add a blank line for spacing
    GameTooltip:AddLine(" ")
	GameTooltip:AddLine("Can't use the right click ? you need to be Officer or Owner of this phase to modify the categories",1,1,1)
	GameTooltip:AddLine(" ")
	GameTooltip:AddLine(CreateAtlasMarkup("services-icon-warning").." Be advised that if multiple people are creating / deleting / modifying categories at the same time, it can lead to some issues.", 1, 0.5, 0.5) -- Orange text
	GameTooltip:AddLine(" It is greatly advised to have only one person handle those kind of modifications. |cFFFFA500(Using the category for filtering,aka left click isn't affected.)|r", 1, 0.5, 0.5) -- Orange text
	-- Add a blank line for spacing
	GameTooltip:AddLine(" ")

    -- Add additional instructions or information
    GameTooltip:AddLine("Use the scroll bar to navigate through the list.", 0.5, 0.8, 1) -- Light blue text

    -- Show the tooltip
    GameTooltip:Show()
end

-- -- -- -- -- -- -- -- -- -- -- --
--#endregion
-- -- -- -- -- -- -- -- -- -- -- --

-- ============================== ICONE AUTOUR MAP ============================== --

---Loads a settings table into a master table, but does not over-write if data is already present
---@param settings table The Default Settings to Copy
---@param master table The Actual Table to hold the settings (aka: your global table saved)
local function loadDefaultsIntoMaster(settings, master)
	for k, v in pairs(settings) do
		if (type(v) == "table") then
			if (master[k] == nil or type(master[k]) ~= "table") then master[k] = {} end
			loadDefaultsIntoMaster(v, master[k]);
		else
			if master and master[k] == nil then
				master[k] = v;
			end
		end
	end
end

PhaseToolkit.NPCCustomiserMainFrame:SetScript("OnEvent", function(self, event, arg1)
	if event == "ADDON_LOADED" and arg1 == addonName then
		if PhaseToolKitConfig == nil then
			PhaseToolKitConfig = {}

			--[[ -- Moved below to dynamic loading
			PhaseToolKitConfig["ModeFR"] = false
			PhaseToolKitConfig["itemsPerPageNPC"] = 15
			PhaseToolKitConfig["itemsPerPageTELE"] = 15
			PhaseToolKitConfig["CurrentLang"] = PhaseToolkitPanel.getBaseLang()
			PhaseToolKitConfig["AutoRefreshNPC"] = false
			--]]
		end

		-- Dynamic default loading so that when new settings are added, they are still added at the default value instead of nil
		local defaultSettings = {
			itemsPerPageNPC = 15,
			itemsPerPageTELE = 15,
			CurrentLang = PhaseToolkitPanel.getBaseLang(),
			AutoRefreshNPC = false,
		}
		loadDefaultsIntoMaster(defaultSettings, PhaseToolKitConfig)

		-- Force fix for any that are currently saved as the full lang table
		if type(PhaseToolKitConfig["CurrentLang"]) == "table" then
			local prevLangCode = PhaseToolKitConfig["CurrentLang"]['lang']
			if prevLangCode then
				PhaseToolKitConfig["CurrentLang"] = ns.getLangNameByCode(prevLangCode)
			else
				PhaseToolKitConfig["CurrentLang"] = PhaseToolkitPanel.getBaseLang()
			end
		end

		PhaseToolkit.NPCCustomiserMainFrame:UnregisterEvent("ADDON_LOADED")
		PhaseToolkitPanel.createConfigPanel()
		PhaseToolkit.itemsPerPageNPC = PhaseToolKitConfig["itemsPerPageNPC"]
		PhaseToolkit.itemsPerPageTELE = PhaseToolKitConfig["itemsPerPageTELE"]
		PhaseToolkit.CurrentLang = ns.getLangTabByString(PhaseToolKitConfig["CurrentLang"]) -- pull the language table
		PhaseToolkit.AutoRefreshNPC = PhaseToolKitConfig["AutoRefreshNPC"]
		PhaseToolkit:CreateAdditionalButtonFrame()
	end
end)
-- -- -- -- -- -- -- -- -- -- -- --
--#endregion
-- -- -- -- -- -- -- -- -- -- -- --
StaticPopupDialogs["CONFIRM_DELETE_CATEGORY_NPC"] = {
    text = "Are you sure you want to delete this category ?",
    button1 = "Yes",
    button2 = "No",
    OnAccept = function(self, data)
        table.remove(PhaseToolkit.NPCcategoryList, data.deleteIndex)
		PhaseToolkit.saveNpcCategoryDataToServer()
		if data.funcOnYes then
			data.funcOnYes()
		end

    end,
    OnCancel = function(self, data) end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}

StaticPopupDialogs["CONFIRM_DELETE_CATEGORY_TELE"] = {
    text = "Are you sure you want to delete this category ?",
    button1 = "Yes",
    button2 = "No",
    OnAccept = function(self, data)
        table.remove(PhaseToolkit.TELEcategoryList, data.deleteIndex)
		PhaseToolkit.saveTELECategoryDataToServer()
		if data.funcOnYes then
			data.funcOnYes()
		end

    end,
    OnCancel = function(self, data) end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}



StaticPopupDialogs["CONFIRM_DELETE_TELE"] = {
	text = "Are you sure you want to delete this teleport?",
	button1 = "Yes",
	button2 = "No",
	OnAccept = function(self, data)
		sendAddonCmd("phase tele delete " .. data, nil, false)
		PhaseToolkit.RemoveStringFromTable(PhaseToolkit.teleList, data)
		if(PhaseToolkit.IsCurrentlyFilteringTeleViaText or PhaseToolkit.IsCurrentlyFilteringTeleViaCategory) then
			PhaseToolkit.TeleUpdatePagination(PhaseToolkit.filteredTeleList)
		else
			PhaseToolkit.TeleUpdatePagination(PhaseToolkit.teleList)
		end
	end,
	timeout = 0,
	whileDead = true,
	hideOnEscape = true,
	preferredIndex = 3,
}
