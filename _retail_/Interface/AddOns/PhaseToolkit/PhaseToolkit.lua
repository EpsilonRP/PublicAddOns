--[[
Define the Addon NameSpace
--]]
---@diagnostic disable: codestyle-check
---@format disable

local addonName, ns = ...
PhaseToolkit = {}

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
PhaseToolkit.itemCreatorData.additemOption={
	{text="Anyone",value=false},
	{text="Character",value=false},
	{text="Member",value=false},
	{text="Officer",value=false},
}
PhaseToolkit.currentWhitelistType=""

PhaseToolkit.ModifyItemData=false


PhaseToolkit.itemCreatorData.whitelistedChar={}
PhaseToolkit.itemCreatorData.whitelistedPhaseForMember={}
PhaseToolkit.itemCreatorData.whitelistedPhaseForOfficer={}
PhaseToolkit.GeneralStat = {
	["Makeup"] = 1,
	["Arm(left)"] = 1,
	["Arm(right"] = 1,
	["Beard"] = 1,
	["Blindfold"] = 1,
	["Body"] = 1,
	["Bodyshape"] = 1,
	["BodyTattoo"] = 1,
	["Bodytype"] = 1,
	["Complexion"] = 1,
	["Earrings"] = 1,
	["Ears"] = 1,
	["Eyebrows"] = 1,
	["Eyecolor"] = 1,
	["Eyetype"] = 1,
	["Face"] = 11,
	["Faceshape"] = 1,
	["Facefeatures"] = 1,
	["FaceTattoo"] = 1,
	["Furcolor"] = 1,
	["Feather"] = 1,
	["FeatherColor"] = 1,
	["Garment"] = 1,
	["GemColor"] = 1,
	["Grime"] = 1,
	["HairColor"] = 1,
	["Hairstyle"] = 1,
	["Hairgradient"] = 1,
	["Hand(left)"] = 1,
	["Hand(right)"] = 1,
	["Handjewelry"] = 1,
	["Headdress"] = 1,
	["Horns"] = 1,
	["JewelryColor"] = 1,
	["leg(left)"] = 1,
	["leg(right)"] = 1,
	["Mustache"] = 1,
	["Necklace"] = 1,
	["Runes"] = 1,
	["RunesColor"] = 1,
	["Ribs"] = 1,
	["Piercings"] = 1,
	["Scars"] = 1,
	["SecondaryEyeColor"] = 1,
	["Sideburns"] = 1,
	["SkinColor"] = 1,
	["Stubble"] = 1,
	["Spine"] = 1,
	["TattooColor"] = 1,
	["Tusks"] = 1,
	["Vines"] = 1,
	["VinesColor"] = 1,
	["Accentcolor"] = 1,
	["Goggles"] = 1,
	["Haircolor"] = 1,
	["Hairgradients"] = 1,
	["Hairstreaks"] = 1,
	["Jewelrycolor"] = 1,
	["Secondaryeyecolor"] = 1,
	["Skincolor"] = 1,
	["Wristjewelry"] = 1,
	["Bodypaint"] = 1,
	["facepaint"] = 1,
	["Flower"] = 1,
	["Foremane"] = 1,
	["Gemcolor"] = 1,
	["Goatee"] = 1,
	["Hair"] = 1,
	["Horncolor"] = 1,
	["Mane"] = 1,
	["Nosering"] = 1,
	["PaintColor"] = 1,
	["Tail"] = 1,
	["TailDecoration"] = 1,
	["HairDecoration"] = 1,
	["Hornstyle"] = 1,
	["Hornmarkings"] = 1,
	["HairAccessory"] = 1,
	["HairGradient"] = 1,
	["HairStreaks"] = 1,
	["Bandages"] = 1,
	["Browpiercing"] = 1,
	["Hairhighlight"] = 1,
	["Leg(left)"] = 1,
	["Leg(right)"] = 1,
	["Mouthpiercing"] = 1,
	["Nosepiercing"] = 1,
	["TattooStyle"] = 1,
	["Chin"] = 1,
	["Nose"] = 1,
	["Posture"] = 1,
	["Skintype"] = 1,
	["Tuskdecoration"] = 1,
	["Armbands"] = 1,
	["Runecolor"] = 1,
	["Bracelets"] = 1,
	["Facetendrils"] = 1,
	["HornAccessories"] = 1,
	["Tendrils"] = 1,
	["Trims"] = 1,
	["Horndecoration"] = 1,
	["Hairaccents"] = 1,
	["SecondaryEarStyle"] = 1,
	["Bodyfur"] = 1,
	["Claws"] = 1,
	["Earstyle"] = 1,
	["Fangs"] = 1,
	["FacialHair"] = 1,
	["Chinjewelry"] = 1,
	["Eyeshape"] = 1,
	["Facejewelry"] = 1,
	["Jawjewelry"] = 1,
	["LuminousHands"] = 1,
	["Bodypaintcolor"] = 1,
	["Hornwrap"] = 1,
	["Bodymarkings"] = 1,
	["Facemarkings"] = 1,
	["Tentacles"] = 1,
	["Facerune"] = 1,
	["Bodyrune"] = 1,
	["Tattoo"] = 1,
	["Pattern"] = 1,
	["Patterncolor"] = 1,
	["Snout"] = 1,
	["BodyPiercings"] = 1,
	["Chestmod"] = 1,
	["Chinmod"] = 1,
	["Earmod"] = 1,
	["Facemod"] = 1,
	["Optics"] = 1,
	["Paintcolor"] = 1,
	["Eargauge"] = 1,
	["Facetype"] = 1
}
PhaseToolkit.ModeFR = false

PhaseToolkit.IntensiteMeteo = 1
PhaseToolkit.IntensiteMeteoMin, IntensiteMeteoMax = 1, 100

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
			["Beard"] = 21,
			["Complexion"] = 5,
			["Earrings"] = 9,
			["Ears"] = 4,
			["Eyebrows"] = 16,
			["Eyecolor"] = 90,
			["Eyetype"] = 4,
			["Face"] = 24,
			["Faceshape"] = 4,
			["GemColor"] = 10,
			["HairColor"] = 48,
			["Hairstyle"] = 74,
			["JewelryColor"] = 5,
			["Mustache"] = 12,
			["Necklace"] = 3,
			["Piercings"] = 4,
			["Scars"] = 12,
			["SecondaryEyeColor"] = 88,
			["Sideburns"] = 8,
			["SkinColor"] = 30,
			["Stubble"] = 13
		},
		["female"] = {
			["Complexion"] = 5,
			["Earrings"] = 10,
			["Ears"] = 4,
			["Eyebrows"] = 22,
			["Eyecolor"] = 89,
			["Eyetype"] = 4,
			["Face"] = 30,
			["Faceshape"] = 3,
			["GemColor"] = 10,
			["HairColor"] = 48,
			["Hairstyle"] = 71,
			["JewelryColor"] = 5,
			["Makeup"] = 10,
			["Necklace"] = 6,
			["Piercings"] = 7,
			["Scars"] = 12,
			["SecondaryEyeColor"] = 88,
			["SkinColor"] = 30,
		}
	},
	["Orc"] = {
		["male"] = {
			["Beard"] = 18,
			["Body"] = 7,
			["BodyTattoo"] = 13,
			["Earrings"] = 8,
			["Ears"] = 2,
			["Eyebrows"] = 5,
			["Eyecolor"] = 31,
			["Face"] = 9,
			["Faceshape"] = 3,
			["FaceTattoo"] = 18,
			["GemColor"] = 0,
			["Grime"] = 4,
			["HairColor"] = 37,
			["Hairstyle"] = 33,
			["Hand(left)"] = 9,
			["Hand(right)"] = 9,
			["Mustache"] = 5,
			["Necklace"] = 8,
			["Piercings"] = 7,
			["Posture"] = 2,
			["Scars"] = 5,
			["SecondaryEyeColor"] = 30,
			["Sideburns"] = 12,
			["SkinColor"] = 35,
			["Stubble"] = 2,
			["TattooColor"] = 11,
			["Tusks"] = 7
		},
		["female"] = {
			["Body"] = 7,
			["BodyTattoo"] = 13,
			["Earrings"] = 17,
			["Ears"] = 2,
			["Eyecolor"] = 31,
			["Face"] = 9,
			["Faceshape"] = 2,
			["FaceTattoo"] = 17,
			["HairColor"] = 36,
			["Hairstyle"] = 45,
			["Hand(left)"] = 6,
			["Hand(right)"] = 6,
			["Necklace"] = 5,
			["Piercings"] = 5,
			["Scars"] = 5,
			["SecondaryEyeColor"] = 29,
			["SkinColor"] = 35,
			["TattooColor"] = 11,
		}
	},
	["Dwarf"] = {
		["male"] = {
			["Beard"] = 28,
			["Body"] = 7,
			["Bodyshape"] = 2,
			["BodyTattoo"] = 9,
			["Earrings"] = 5,
			["Eyebrows"] = 4,
			["Eyecolor"] = 26,
			["Face"] = 20,
			["Faceshape"] = 2,
			["FaceTattoo"] = 13,
			["Feather"] = 7,
			["FeatherColor"] = 9,
			["Garment"] = 3,
			["Grime"] = 4,
			["HairColor"] = 20,
			["Hairstyle"] = 27,
			["Handjewelry"] = 7,
			["JewelryColor"] = 7,
			["Mustache"] = 15,
			["Piercings"] = 6,
			["SecondaryEyeColor"] = 25,
			["SkinColor"] = 29,
			["TattooColor"] = 7,
		},
		["female"] = {
			["BodyTattoo"] = 10,
			["Earrings"] = 14,
			["Eyebrows"] = 18,
			["Eyecolor"] = 26,
			["Face"] = 10,
			["FaceTattoo"] = 11,
			["Feather"] = 7,
			["FeatherColor"] = 9,
			["Garment"] = 3,
			["HairColor"] = 20,
			["Hairstyle"] = 45,
			["JewelryColor"] = 7,
			["Piercings"] = 9,
			["SecondaryEyeColor"] = 25,
			["SkinColor"] = 23,
			["TattooColor"] = 7,
		}
	},
	["NightElf"] = {
		["male"] = {
			["Beard"] = 17,
			["Blindfold"] = 12,
			["Bodyshape"] = 2,
			["BodyTattoo"] = 14,
			["Bodytype"] = 2,
			["Earrings"] = 6,
			["Ears"] = 5,
			["Eyebrows"] = 10,
			["Eyecolor"] = 41,
			["Eyetype"] = 2,
			["Face"] = 12,
			["Faceshape"] = 2,
			["FaceTattoo"] = 16,
			["Furcolor"] = 31,
			["GemColor"] = 14,
			["HairColor"] = 30,
			["Hairstyle"] = 45,
			["Headdress"] = 3,
			["Horns"] = 16,
			["JewelryColor"] = 14,
			["Mustache"] = 7,
			["Necklace"] = 4,
			["Runes"] = 7,
			["RunesColor"] = 7,
			["Scars"] = 7,
			["SecondaryEyeColor"] = 40,
			["Sideburns"] = 7,
			["SkinColor"] = 35,
			["TattooColor"] = 11,
			["Vines"] = 2,
			["VinesColor"] = 20
		},
		["female"] = {
			["Blindfold"] = 12,
			["BodyTattoo"] = 12,
			["Bodytype"] = 2,
			["Earrings"] = 11,
			["Ears"] = 5,
			["Eyebrows"] = 4,
			["Eyecolor"] = 41,
			["Eyetype"] = 2,
			["Face"] = 9,
			["Faceshape"] = 2,
			["FaceTattoo"] = 20,
			["Furcolor"] = 31,
			["GemColor"] = 14,
			["HairColor"] = 31,
			["Hairstyle"] = 57,
			["Headdress"] = 4,
			["Horns"] = 16,
			["JewelryColor"] = 14,
			["Necklace"] = 4,
			["Runes"] = 7,
			["RunesColor"] = 7,
			["Piercings"] = 8,
			["Scars"] = 7,
			["SecondaryEyeColor"] = 40,
			["SkinColor"] = 35,
			["Stubble"] = 0,
			["TattooColor"] = 21,
			["Vines"] = 2,
			["VinesColor"] = 20
		}
	},
	["Undead"] = {
		["male"] = {
			["Arm(left)"] = 2,
			["Arm(right"] = 2,
			["Beard"] = 8,
			["Ears"] = 2,
			["Eyebrows"] = 3,
			["Eyecolor"] = 20,
			["Face"] = 11,
			["Facefeatures"] = 5,
			["HairColor"] = 18,
			["Hairstyle"] = 41,
			["Hairgradient"] = 13,
			["Facetype"] = 14,
			["leg(left)"] = 2,
			["leg(right)"] = 2,
			["Mustache"] = 6,
			["Ribs"] = 4,
			["SecondaryEyeColor"] = 20,
			["Sideburns"] = 6,
			["SkinColor"] = 12,
			["Spine"] = 2,
		},
		["female"] = {
			["Arm(left)"] = 2,
			["Arm(right"] = 2,
			["Earrings"] = 2,
			["Ears"] = 2,
			["Eyecolor"] = 20,
			["Face"] = 10,
			["Facefeatures"] = 4,
			["HairColor"] = 17,
			["Hairstyle"] = 47,
			["Hairgradient"] = 13,
			["leg(left)"] = 2,
			["leg(right)"] = 2,
			["Necklace"] = 7,
			["Piercings"] = 15,
			["SecondaryEyeColor"] = 20,
			["SkinColor"] = 12,
			["Skintype"] = 3,
			["Spine"] = 2,
		}
	},
	["Tauren"] = {
		["male"] = {
			["Accentcolor"] = 18,
			["Beard"] = 12,
			["Bodypaint"] = 8,
			["Earrings"] = 12,
			["Eyecolor"] = 18,
			["Face"] = 5,
			["facepaint"] = 9,
			["Flower"] = 2,
			["Foremane"] = 12,
			["Gemcolor"] = 8,
			["Goatee"] = 9,
			["Hair"] = 12,
			["Headdress"] = 3,
			["Hornstyle"] = 20,
			["Horncolor"] = 16,
			["JewelryColor"] = 8,
			["Mane"] = 5,
			["Necklace"] = 3,
			["Nosering"] = 9,
			["PaintColor"] = 21,
			["Tail"] = 4,
			["TailDecoration"] = 4,
			["SecondaryEyeColor"] = 17,
			["Sideburns"] = 6,
			["SkinColor"] = 35,
		},
		["female"] = {
			['Accentcolor'] = 18,
			["Bodypaint"] = 8,
			["Earrings"] = 8,
			["Eyecolor"] = 18,
			["Face"] = 4,
			["facepaint"] = 9,
			['Flower'] = 2,
			["Foremane"] = 11,
			["Gemcolor"] = 8,
			["Hair"] = 24,
			["HairDecoration"] = 6,
			["Headdress"] = 3,
			["Hornstyle"] = 20,
			["Hornmarkings"] = 3,
			["Horncolor"] = 16,
			["JewelryColor"] = 8,
			["Necklace"] = 8,
			["Nosering"] = 12,
			["PaintColor"] = 21,
			["Tail"] = 3,
			["TailDecoration"] = 5,
			["SecondaryEyeColor"] = 17,
			["SkinColor"] = 27,
			["Mane"] = 2
		}
	},
	["Gnome"] = {
		["male"] = {
			["Accentcolor"] = 7,
			["Beard"] = 13,
			["Earrings"] = 12,
			["Ears"] = 3,
			["Eyebrows"] = 13,
			["Eyecolor"] = 32,
			["Face"] = 7,
			["Goggles"] = 2,
			["Haircolor"] = 74,
			["Hairgradients"] = 20,
			["Hairstreaks"] = 75,
			["Hairstyle"] = 63,
			["Jewelrycolor"] = 5,
			["Mustache"] = 24,
			["Piercings"] = 5,
			["Scars"] = 7,
			["Secondaryeyecolor"] = 31,
			["Sideburns"] = 6,
			["Skincolor"] = 6,
			["Wristjewelry"] = 2,
		},
		["female"] = {
			["Accentcolor"] = 7,
			["Earrings"] = 22,
			["Ears"] = 3,
			["Eyebrows"] = 19,
			["Eyecolor"] = 32,
			["Face"] = 7,
			["Goggles"] = 2,
			["HairAccessory"] = 2,
			["HairColor"] = 74,
			["HairGradient"] = 20,
			["HairStreaks"] = 75,
			["Hairstyle"] = 59,
			["JewelryColor"] = 5,
			["Piercings"] = 8,
			["Scars"] = 7,
			["SecondaryEyeColor"] = 31,
			["SkinColor"] = 23,
			["Wristjewelry"] = 2
		}
	},
	["Troll"] = {
		["male"] = {
			["Accentcolor"] = 27,
			["Arm(left)"] = 20,
			["Arm(right"] = 20,
			["Bandages"] = 9,
			["Beard"] = 18,
			["BodyTattoo"] = 9,
			["Earrings"] = 11,
			["Eyebrows"] = 2,
			["Eyecolor"] = 24,
			["Face"] = 5,
			["FaceTattoo"] = 14,
			["HairColor"] = 43,
			["Hairgradient"] = 11,
			["Hairhighlight"] = 48,
			["Hairstyle"] = 39,
			["JewelryColor"] = 12,
			["Leg(left)"] = 18,
			["Leg(right)"] = 18,
			["Mouthpiercing"] = 4,
			["Mustache"] = 4,
			["Necklace"] = 5,
			["Nosepiercing"] = 7,
			["SecondaryEyeColor"] = 23,
			["Sideburns"] = 7,
			["SkinColor"] = 36,
			["TattooColor"] = 43,
			["TattooStyle"] = 3,
			["Tuskdecoration"] = 11,
			["Tusks"] = 17
		},
		["female"] = {
			["Accentcolor"] = 27,
			["Arm(left)"] = 24,
			["Arm(right"] = 24,
			["Bandages"] = 9,
			["BodyTattoo"] = 10,
			["Browpiercing"] = 4,
			["Earrings"] = 12,
			["Eyecolor"] = 24,
			["Face"] = 6,
			["FaceTattoo"] = 11,
			["HairColor"] = 43,
			["Hairgradient"] = 11,
			["Hairhighlight"] = 48,
			["Hairstyle"] = 54,
			["JewelryColor"] = 12,
			["Leg(left)"] = 22,
			["Leg(right)"] = 25,
			["Mouthpiercing"] = 4,
			["Necklace"] = 9,
			["Nosepiercing"] = 5,
			["SecondaryEyeColor"] = 23,
			["SkinColor"] = 36,
			["TattooColor"] = 43,
			["TattooStyle"] = 3,
			["Tusks"] = 10,
		}
	},
	["Goblin"] = {
		["male"] = {
			["Beard"] = 12,
			["Chin"] = 6,
			["Earrings"] = 9,
			["Ears"] = 10,
			["Eyebrows"] = 2,
			["Eyecolor"] = 25,
			["Face"] = 7,
			["HairColor"] = 68,
			["Hairgradient"] = 20,
			["Hairstyle"] = 50,
			["JewelryColor"] = 8,
			["Mustache"] = 9,
			["Nose"] = 11,
			["Nosering"] = 5,
			["SecondaryEyeColor"] = 24,
			["Sideburns"] = 8,
			["SkinColor"] = 20,
		},
		["female"] = {
			["Bodyshape"] = 2,
			["Chin"] = 7,
			["Earrings"] = 13,
			["Ears"] = 7,
			["Eyebrows"] = 20,
			["Eyecolor"] = 25,
			["SecondaryEyeColor"] = 24,
			["Face"] = 10,
			["HairColor"] = 68,
			["HairGradient"] = 20,
			["Hairstyle"] = 48,
			["JewelryColor"] = 8,
			["Necklace"] = 7,
			["Nose"] = 9,
			["Nosering"] = 9,
			["SkinColor"] = 16,
		}
	},
	["BloodElf"] = {
		["male"] = {
			["Accentcolor"] = 5,
			["Beard"] = 23,
			["Blindfold"] = 12,
			["BodyTattoo"] = 17,
			["Earrings"] = 6,
			["Ears"] = 4,
			["Eyebrows"] = 4,
			["Eyecolor"] = 41,
			["Eyetype"] = 2,
			["Face"] = 12,
			["Faceshape"] = 2,
			["FaceTattoo"] = 22,
			["Gemcolor"] = 6,
			["Haircolor"] = 40,
			["Hairgradient"] = 18,
			["Hairstyle"] = 54,
			["Headdress"] = 3,
			["Horns"] = 7,
			["Jewelrycolor"] = 3,
			["Mustache"] = 7,
			["Runecolor"] = 6,
			["Runes"] = 12,
			["Secondaryeyecolor"] = 40,
			["Sideburns"] = 5,
			["Skincolor"] = 33,
			["Stubble"] = 2,
			["TattooColor"] = 10,
		},
		["female"] = {
			["Accentcolor"] = 5,
			["Armbands"] = 4,
			["Blindfold"] = 12,
			["BodyTattoo"] = 17,
			["Bracelets"] = 6,
			["Earrings"] = 14,
			["Ears"] = 4,
			["Eyecolor"] = 41,
			["Eyetype"] = 2,
			["Face"] = 12,
			["Faceshape"] = 2,
			["Gemcolor"] = 6,
			["HairColor"] = 40,
			["HairGradient"] = 18,
			["Hairstyle"] = 63,
			["Headdress"] = 3,
			["JewelryColor"] = 3,
			["Necklace"] = 5,
			["Runes"] = 12,
			["RunesColor"] = 6,
			["SecondaryEyeColor"] = 40,
			["SkinColor"] = 33,
			["TattooColor"] = 10,
			["Horns"] = 7
		}
	},
	["Draenei"] = {
		["male"] = {
			["Beard"] = 17,
			["Bodyshape"] = 3,
			["Earrings"] = 12,
			["Eyebrows"] = 3,
			["Eyecolor"] = 28,
			["Face"] = 10,
			["Faceshape"] = 2,
			["Gemcolor"] = 6,
			["Haircolor"] = 52,
			["Hairstyle"] = 34,
			["Headdress"] = 7,
			["Horndecoration"] = 6,
			["Horns"] = 28,
			["Jewelrycolor"] = 10,
			["Mustache"] = 10,
			["Necklace"] = 2,
			["Secondaryeyecolor"] = 28,
			["Sideburns"] = 12,
			["Skincolor"] = 24,
			["Stubble"] = 5,
			["Tail"] = 2,
			["Tendrils"] = 11,
			["Trims"] = 2,
		},
		["female"] = {
			["Earrings"] = 6,
			["Eyecolor"] = 28,
			["Face"] = 10,
			["Facetendrils"] = 4,
			["Gemcolor"] = 6,
			["Haircolor"] = 52,
			["HairDecoration"] = 2,
			["Hairstyle"] = 36,
			["Headdress"] = 12,
			["HornAccessories"] = 28,
			["Horns"] = 19,
			["Jewelrycolor"] = 10,
			["Necklace"] = 3,
			["Secondaryeyecolor"] = 28,
			["Skincolor"] = 22,
			["Tail"] = 6,
			["Tendrils"] = 4,
			["Trims"] = 2,
		}
	},
	["Worgen"] = {
		["male"] = {
			["Beard"] = 12,
			["Bodyfur"] = 4,
			["Claws"] = 2,
			["Earstyle"] = 18,
			["Eyecolor"] = 23,
			["Face"] = 7,
			["Faceshape"] = 2,
			["Fangs"] = 2,
			["Foremane"] = 10,
			["Furcolor"] = 15,
			["Hairstyle"] = 11,
			["Mane"] = 4,
			["SecondaryEarStyle"] = 19,
			["SecondaryEyeColor"] = 22,
			["Tail"] = 5,
			["Sideburns"] = 12,
		},
		["female"] = {
			["Bodyfur"] = 4,
			["Claws"] = 2,
			["Earstyle"] = 20,
			["Eyecolor"] = 23,
			["Face"] = 16,
			["Faceshape"] = 2,
			["Fangs"] = 2,
			["Foremane"] = 11,
			["Furcolor"] = 19,
			["Hairaccents"] = 3,
			["Hairstyle"] = 16,
			["Mane"] = 3,
			["SecondaryEarStyle"] = 21,
			["SecondaryEyeColor"] = 22,
			["Tail"] = 6,
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
			["Beard"] = 20,
			["Eyebrows"] = 5,
			["Eyecolor"] = 20,
			["Face"] = 21,
			["Hairstyle"] = 22,
			["Mustache"] = 7,
			["SecondaryEyeColor"] = 19,
			["SkinColor"] = 18,
		},
		["female"] = {
			["Earrings"] = 6,
			["Eyecolor"] = 19,
			["Face"] = 20,
			["Haircolor"] = 16,
			["Hairstyle"] = 20,
			["SecondaryEyeColor"] = 19,
			["SkinColor"] = 18,
			["Tail"] = 2
		}
	},
	["Nightborne"] = {
		["male"] = {
			["Beard"] = 4,
			["BodyTattoo"] = 7,
			["Chinjewelry"] = 5,
			["Earrings"] = 7,
			["Eyebrows"] = 3,
			["Eyecolor"] = 22,
			["Eyeshape"] = 2,
			["Face"] = 14,
			["Facejewelry"] = 4,
			["FaceTattoo"] = 9,
			["HairColor"] = 12,
			["Hairstyle"] = 16,
			["Headdress"] = 2,
			["Jawjewelry"] = 5,
			["Jewelrycolor"] = 3,
			["LuminousHands"] = 2,
			["Mustache"] = 4,
			["SecondaryEyeColor"] = 21,
			["SkinColor"] = 11,
		},
		["female"] = {
			["BodyTattoo"] = 7,
			["Chinjewelry"] = 4,
			["Earrings"] = 8,
			["Eyebrows"] = 3,
			["Eyecolor"] = 22,
			["Eyeshape"] = 2,
			["Face"] = 12,
			["Facejewelry"] = 5,
			["FaceTattoo"] = 9,
			["HairColor"] = 12,
			["HairDecoration"] = 2,
			["Hairstyle"] = 16,
			["Headdress"] = 2,
			["Jawjewelry"] = 2,
			["Jewelrycolor"] = 3,
			["LuminousHands"] = 2,
			["SecondaryEyeColor"] = 21,
			["SkinColor"] = 11,
		}
	},
	["Highmountain"] = {
		["male"] = {
			["Beard"] = 9,
			["Bodypaint"] = 4,
			["Bodypaintcolor"] = 3,
			["Eyecolor"] = 18,
			["Face"] = 5,
			["facepaint"] = 4,
			['Feather'] = 3,
			["Foremane"] = 8,
			["Hair"] = 9,
			["Headdress"] = 3,
			["Horncolor"] = 4,
			["Horndecoration"] = 8,
			["Hornmarkings"] = 3,
			["Hornstyle"] = 9,
			["Hornwrap"] = 3,
			["Nosepiercing"] = 5,
			["SecondaryEyeColor"] = 17,
			["SkinColor"] = 10,
			["Tail"] = 3,
			["TailDecoration"] = 4,
		},
		["female"] = {
			["Bodypaint"] = 4,
			["Bodypaintcolor"] = 3,
			["Earrings"] = 5,
			["Eyecolor"] = 18,
			["Face"] = 4,
			["facepaint"] = 4,
			['Feather'] = 2,
			["Foremane"] = 7,
			["Hair"] = 9,
			["HairDecoration"] = 4,
			["Headdress"] = 3,
			["Horncolor"] = 4,
			["Horndecoration"] = 2,
			["Hornmarkings"] = 3,
			["Hornstyle"] = 8,
			["Hornwrap"] = 2,
			["Necklace"] = 4,
			["Nosepiercing"] = 4,
			["SecondaryEyeColor"] = 17,
			["SkinColor"] = 10,
			["Tail"] = 2,
			["TailDecoration"] = 5,


		}
	},
	["VoidElf"] = {
		["male"] = {
			["Bodymarkings"] = 3,
			["Ears"] = 3,
			["Eyecolor"] = 20,
			["Face"] = 28,
			["Facemarkings"] = 11,
			["FacialHair"] = 8,
			["HairColor"] = 40,
			["Hairstyle"] = 13,
			["SecondaryEyeColor"] = 19,
			["SkinColor"] = 33,
			["Stubble"] = 2,
			["Tentacles"] = 2
		},
		["female"] = {
			["Bodymarkings"] = 3,
			["Earrings"] = 5,
			["Ears"] = 3,
			["Eyecolor"] = 20,
			["Face"] = 28,
			["Facemarkings"] = 11,
			["HairColor"] = 40,
			["Hairstyle"] = 11,
			["SecondaryEyeColor"] = 19,
			["SkinColor"] = 33,
			["Tentacles"] = 2
		}
	},
	["Lightforged"] = {
		["male"] = {
			["Bodyrune"] = 4,
			["Eyebrows"] = 2,
			["Eyecolor"] = 4,
			["Face"] = 10,
			["Facerune"] = 6,
			["FacialHair"] = 12,
			["Haircolor"] = 11,
			["Hairstyle"] = 13,
			["Horndecoration"] = 4,
			["Jewelrycolor"] = 13,
			["Skincolor"] = 8,
			["Tail"] = 2,
			["Tendrils"] = 7,
		},
		["female"] = {
			["Bodyrune"] = 4,
			["Earrings"] = 3,
			["Eyecolor"] = 4,
			["Face"] = 10,
			["Facerune"] = 6,
			["Haircolor"] = 11,
			["HairDecoration"] = 4,
			["Hairstyle"] = 13,
			["Headdress"] = 5,
			["Horndecoration"] = 7,
			["Horns"] = 13,
			["Jewelrycolor"] = 13,
			["Necklace"] = 2,
			["Skincolor"] = 8,
			["Tail"] = 6,
			["Tendrils"] = 2,
		}
	},
	["Zandalari"] = {
		["male"] = {
			["Eargauge"] = 3,
			["Eyecolor"] = 9,
			["Face"] = 6,
			["Haircolor"] = 7,
			["Hairstyle"] = 12,
			["Piercings"] = 6,
			["SecondaryEyeColor"] = 7,
			["SkinColor"] = 8,
			["Tattoo"] = 4,
			["TattooColor"] = 8,
			["Tusks"] = 7,

		},
		["female"] = {
			["Eargauge"] = 3,
			["Earrings"] = 2,
			["Eyecolor"] = 9,
			["Face"] = 6,
			["Haircolor"] = 7,
			["Hairstyle"] = 11,
			["Necklace"] = 2,
			["Piercings"] = 4,
			["SecondaryEyeColor"] = 7,
			["SkinColor"] = 8,
			["Tattoo"] = 5,
			["TattooColor"] = 8,
			["Tusks"] = 7,
		}
	},
	["Kul tiran"] = {
		["male"] = {
			["Beard"] = 4,
			["BodyTattoo"] = 6,
			["Eyecolor"] = 29,
			["Face"] = 7,
			["HairColor"] = 48,
			["Hairstyle"] = 6,
			["Mustache"] = 4,
			["SecondaryEyeColor"] = 28,
			["Sideburns"] = 2,
			["SkinColor"] = 20,
			["TattooColor"] = 8
		},
		["female"] = {
			["BodyTattoo"] = 6,
			["Earrings"] = 7,
			["Eyebrows"] = 2,
			["Eyecolor"] = 29,
			["Face"] = 7,
			["HairColor"] = 50,
			["Hairstyle"] = 10,
			["Necklace"] = 7,
			["SecondaryEyeColor"] = 28,
			["SkinColor"] = 20,
			["TattooColor"] = 8
		}
	},
	["Thin Human"] = {
		["male"] = {
			["FacialHair"] = 7,
			["HairColor"] = 4,
			["Hairstyle"] = 4,
			["SkinColor"] = 4,
		},
		["female"] = {

		}
	},
	["DarkIron"] = {
		["male"] = {
			["Eyecolor"] = 4,
			["Face"] = 10,
			["FacialHair"] = 7,
			["Haircolor"] = 7,
			["Hairstyle"] = 8,
			["Piercings"] = 6,
			["SkinColor"] = 5,
			["TattooColor"] = 6,
		},
		["female"] = {
			["Eyecolor"] = 4,
			["Face"] = 10,
			["Haircolor"] = 11,
			["Hairstyle"] = 7,
			["Piercings"] = 5,
			["SkinColor"] = 6,
			["Tattoo"] = 6,
		}
	},
	["Vulpera"] = {
		["male"] = {
			["Earrings"] = 2,
			["Ears"] = 6,
			["Eyecolor"] = 24,
			["Face"] = 6,
			["Furcolor"] = 9,
			["Pattern"] = 3,
			["Patterncolor"] = 8,
			["SecondaryEyeColor"] = 23,
			["Snout"] = 6,
		},
		["female"] = {
			["Earrings"] = 2,
			["Ears"] = 8,
			["Eyecolor"] = 24,
			["Face"] = 6,
			["Furcolor"] = 9,
			["Pattern"] = 3,
			["Patterncolor"] = 8,
			["SecondaryEyeColor"] = 23,
			["Snout"] = 6,
		}
	},
	["Mag'har"] = {
		["male"] = {
			["Beard"] = 18,
			["BodyPiercings"] = 2,
			["BodyTattoo"] = 13,
			["Earrings"] = 6,
			["Eyebrows"] = 5,
			["Eyecolor"] = 20,
			["Face"] = 9,
			["Faceshape"] = 3,
			["FaceTattoo"] = 18,
			["Grime"] = 4,
			["HairColor"] = 36,
			["Hairstyle"] = 33,
			["Hand(left)"] = 8,
			["Hand(right)"] = 8,
			["Mustache"] = 5,
			["Necklace"] = 7,
			["Piercings"] = 7,
			["Posture"] = 2,
			["Scars"] = 5,
			["SecondaryEyeColor"] = 19,
			["Sideburns"] = 12,
			["SkinColor"] = 11,
			["TattooColor"] = 11,
			["Tusks"] = 5
		},
		["female"] = {
			["BodyPiercings"] = 2,
			["BodyTattoo"] = 13,
			["Earrings"] = 17,
			["Eyecolor"] = 20,
			["Face"] = 9,
			["Faceshape"] = 2,
			["FaceTattoo"] = 17,
			["HairColor"] = 36,
			["Hairstyle"] = 46,
			["Hand(left)"] = 6,
			["Hand(right)"] = 6,
			["Necklace"] = 5,
			["Piercings"] = 4,
			["SecondaryEyeColor"] = 19,
			["SkinColor"] = 15,
			["TattooColor"] = 11,
		}
	},
	["Mechagnome"] = {
		["male"] = {
			["Arm(left)"] = 9,
			["Arm(right"] = 9,
			["Beard"] = 13,
			["Chestmod"] = 4,
			["Chinmod"] = 2,
			["Earmod"] = 8,
			["Eyebrows"] = 13,
			["Eyecolor"] = 32,
			["Face"] = 7,
			["Facemod"] = 17,
			["Haircolor"] = 74,
			["Hairgradient"] = 20,
			["Hairstreaks"] = 75,
			["Hairstyle"] = 62,
			["Leg(left)"] = 4,
			["Leg(right)"] = 4,
			["Mustache"] = 24,
			["Optics"] = 9,
			["Paintcolor"] = 45,
			["Scars"] = 10,
			["SecondaryEyeColor"] = 32,
			["Sideburns"] = 6,
			["Skincolor"] = 23,
		},
		["female"] = {
			["Arm(left)"] = 13,
			["Arm(right"] = 9,
			["Chestmod"] = 4,
			["Chinmod"] = 2,
			["Earmod"] = 8,
			["Eyebrows"] = 19,
			["Eyecolor"] = 32,
			["Face"] = 7,
			["Facemod"] = 18,
			["Haircolor"] = 74,
			["Hairgradient"] = 20,
			["Hairstreaks"] = 75,
			["Hairstyle"] = 59,
			["Leg(left)"] = 6,
			["Leg(right)"] = 4,
			["Optics"] = 9,
			["Paintcolor"] = 45,
			["Scars"] = 10,
			["SecondaryEyeColor"] = 32,
			["Skincolor"] = 24,
		}
	},
	["Fel Orc"] = {
		["male"] = {
			["SkinColor"] = 3,
		},
		["female"] = {}
	},
	["Naga"] = {
		["male"] = {
			["SkinColor"] = 6
		},
		["female"] = {
			["SkinColor"] = 6
		}
	},
	["Broken"] = {
		["male"] = {
			["HairColor"] = 10,
			["Hairstyle"] = 3,
			["SkinColor"] = 6,
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
			["FacialHair"] = 6,
			["HairColor"] = 5,
			["Hairstyle"] = 6,
			["SkinColor"] = 6
		},
		["female"] = {

		}
	},
	["Tuskarr"] = {
		["male"] = {
			["FacialHair"] = 7,
			["HairColor"] = 7,
			["Hairstyle"] = 7,
			["SkinColor"] = 7,
		},
		["female"] = {

		}
	},
	["Forest Troll"] = {
		["male"] = {
			["Face"] = 5,
			["FacialHair"] = 11,
			["HairColor"] = 10,
			["Hairstyle"] = 6,
			["SkinColor"] = 15
		},
		["female"] = {

		}
	},
	["Taunka"] = {
		["male"] = {
			["FacialHair"] = 3,
			["SkinColor"] = 4
		},
		["female"] = {

		}
	},
	["Northrend Skeleton"] = {
		["male"] = {
			["FacialHair"] = 5,
			["HairColor"] = 4,
			["SkinColor"] = 4
		},
		["female"] = {

		}
	},
	["Ice troll"] = {
		["male"] = {
			["FacialHair"] = 5,
			["HairColor"] = 6,
			["Hairstyle"] = 6,
			["SkinColor"] = 8
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
PhaseToolkit.IsCurrentlyFilteringNpc = false

PhaseToolkit.teleList = {}
PhaseToolkit.filteredTeleList = {}
PhaseToolkit.IsCurrentlyFilteringTele = false

PhaseToolkit.tempChatFrame = nil

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
	sendAddonCmd("phase forge npc outfit race " .. RaceId, nil, false)
end

function PhaseToolkit.ChangeNpcGender(GenderString)
	sendAddonCmd("phase forge npc outfit gender " .. GenderString, nil, false)
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
	sendAddonCmd("phase set weather " .. PhaseToolkit.SelectedMeteo .. " " .. PhaseToolkit.IntensiteMeteo, nil, false)
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
		sendAddonCmd("phase forge npc outfit custom " .. attribute .. " " .. randomValue, nil, false)
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
				sendAddonCmd('phase toggle ' .. self.value, nil, false)
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
PhaseToolkit.NPCCustomiserMainFrame = CreateFrame("Frame", "NPCCustomiserMainFrame", UIParent, "BasicFrameTemplateWithInset")

PhaseToolkit.NPCCustomiserMainFrame:SetSize(PhaseToolkit.LargeurMax, PhaseToolkit.HauteurMax)
PhaseToolkit.NPCCustomiserMainFrame:SetPoint("CENTER")
PhaseToolkit.NPCCustomiserMainFrame:SetMovable(true)
PhaseToolkit.NPCCustomiserMainFrame:EnableMouse(true)
PhaseToolkit.NPCCustomiserMainFrame:RegisterForDrag("LeftButton")
PhaseToolkit.NPCCustomiserMainFrame:SetScript("OnDragStart", PhaseToolkit.NPCCustomiserMainFrame.StartMoving)
PhaseToolkit.NPCCustomiserMainFrame:SetScript("OnDragStop", PhaseToolkit.NPCCustomiserMainFrame.StopMovingOrSizing)
PhaseToolkit.NPCCustomiserMainFrame:SetClampedToScreen(true)
PhaseToolkit.NPCCustomiserMainFrame:Hide()

PhaseToolkit.NPCCustomMainFrameSettingsButton = CreateFrame("BUTTON", nil, PhaseToolkit.NPCCustomiserMainFrame, "UIPanelButtonNoTooltipTemplate")
PhaseToolkit.NPCCustomMainFrameSettingsButton:SetSize(24, 20)
PhaseToolkit.NPCCustomMainFrameSettingsButton:SetPoint("RIGHT", PhaseToolkit.NPCCustomiserMainFrame.CloseButton, "LEFT", 4, 1)
PhaseToolkit.NPCCustomMainFrameSettingsButton.icon = PhaseToolkit.NPCCustomMainFrameSettingsButton:CreateTexture(nil, "ARTWORK")
PhaseToolkit.NPCCustomMainFrameSettingsButton.icon:SetTexture("interface/buttons/ui-optionsbutton")
PhaseToolkit.NPCCustomMainFrameSettingsButton.icon:SetSize(16, 16)
PhaseToolkit.NPCCustomMainFrameSettingsButton.icon:SetPoint("CENTER")
PhaseToolkit.NPCCustomMainFrameSettingsButton:SetScript("OnClick", function()
	-- Needs to be called twice because of a bug in Blizzard's frame - the first call will initialize the frame if it's not initialized
	InterfaceOptionsFrame_OpenToCategory("PhaseToolkitConfig")
	InterfaceOptionsFrame_OpenToCategory("PhaseToolkitConfig")
end)
PhaseToolkit.NPCCustomMainFrameSettingsButton:SetScript("OnMouseDown", function(self)
	local point, relativeTo, relativePoint, xOfs, yOfs = self.icon:GetPoint(1)
	self.icon:SetPoint(point, relativeTo, relativePoint, xOfs - 1, yOfs - 2)
end)
PhaseToolkit.NPCCustomMainFrameSettingsButton:SetScript("OnMouseUp", function(self)
	local point, relativeTo, relativePoint, xOfs, yOfs = self.icon:GetPoint(1)
	self.icon:SetPoint(point, relativeTo, relativePoint, xOfs + 1, yOfs + 2)
end)

PhaseToolkit.NPCCustomMainFrameTitle = PhaseToolkit.NPCCustomiserMainFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
PhaseToolkit.NPCCustomMainFrameTitle:SetPoint("TOPLEFT", PhaseToolkit.NPCCustomiserMainFrame, "TOPLEFT", 10, -5)
PhaseToolkit.NPCCustomMainFrameTitle:SetText("Phase Toolkit")

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
	if (GlobalNPCCUSTOMISER_moduleForPhaseAccessFrame ~= nil) then
		GlobalNPCCUSTOMISER_moduleForPhaseAccessFrame:Hide()
		GlobalNPCCUSTOMISER_moduleForPhaseAccessFrame = nil
	end
	PhaseToolkit.createPhaseAccessFrame()
	if (GlobalNPCCUSTOMISER_moduleForMetteoSettingsFrame ~= nil) then GlobalNPCCUSTOMISER_moduleForMetteoSettingsFrame:Hide() end
	PhaseToolkit.createMeteoSettingsFrame()
	if (GlobalNPCCUSTOMISER_moduleForTimeSliderFrame ~= nil) then GlobalNPCCUSTOMISER_moduleForTimeSliderFrame:Hide() end
	PhaseToolkit.createTimeSettingsFrame()
	if (GlobalNPCCUSTOMISER_moduleForSetStartingFrame ~= nil) then GlobalNPCCUSTOMISER_moduleForSetStartingFrame:Hide() end
	PhaseToolkit.createSetStartingFrame()
	if (GlobalNPCCUSTOMISER_moduleForTogglesFrame ~= nil) then GlobalNPCCUSTOMISER_moduleForTogglesFrame:Hide() end
	PhaseToolkit.createTogglesFrame()
	if (GlobalNPCCUSTOMISER_moduleForPhaseSetNameFrame ~= nil) then GlobalNPCCUSTOMISER_moduleForPhaseSetNameFrame:Hide() end
	PhaseToolkit.createPhaseSetNameFrame()
	if (GlobalNPCCUSTOMISER_moduleForPhaseSetDescriptionFrame ~= nil) then GlobalNPCCUSTOMISER_moduleForPhaseSetDescriptionFrame:Hide() end
	PhaseToolkit.createPhaseSetDescriptionFrame()
	if (GlobalNPCCUSTOMISER_moduleforMotdFrame ~= nil) then GlobalNPCCUSTOMISER_moduleforMotdFrame:Hide() end
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
			local maxDescriptionSize=254-(string.len("f i s de ")+string.len(itemLink))
			if(string.len(PhaseToolkit.itemCreatorData.itemDescription)>maxDescriptionSize) then
				sendMessageInChunks("f i s de "..itemLink..PhaseToolkit.itemCreatorData.itemDescription)
			else
				sendAddonCmd("forge item set description "..itemLink..PhaseToolkit.itemCreatorData.itemDescription,nil,false)
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
			local value=""
			if(PhaseToolkit.itemCreatorData.stackable==true) then
				value="on"
			end
			sendAddonCmd("forge item set stackable "..itemLink..value,nil,false)
		end
	end)
	C_Timer.After(1.2, function()
		if(PhaseToolkit.itemCreatorData.sheath~=nil and PhaseToolkit.itemCreatorData.sheath~=-1) then
			sendAddonCmd("forge item set sheath "..itemLink..PhaseToolkit.itemCreatorData.sheath,nil,false)
		end
	end)
	C_Timer.After(1.3, function()
		if(PhaseToolkit.itemCreatorData.adder~=nil and PhaseToolkit.itemCreatorData.adder~=-1) then
			sendAddonCmd("forge item set property adder"..itemLink..PhaseToolkit.itemCreatorData.adder,nil,false)
		end
	end)
	if(PhaseToolkit.itemCreatorData.additemOption~=nil) then
		for _,option in ipairs(PhaseToolkit.itemCreatorData.additemOption) do
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
	end)

end

function GetItemIDFromLink(itemLink)
    if not itemLink then return nil end
    -- Extrait l'ID de l'objet depuis le lien
    local itemID = itemLink:match("item:(%d+)")
    return  itemID
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
		description=description:gsub('"',"")
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
			UIDropDownMenu_SetSelectedValue(PhaseToolkit.ItemQualityDropdown,quality.bondingId)
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
	labelforItem:SetText("Object Link")
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

	PhaseToolkit.DescriptionInputBox.ScrollFrame.EditBox:SetScript("OnEnterPressed", function(self)
		self:ClearFocus()
		PhaseToolkit.itemCreatorData.itemDescription=self:GetText();
		if(PhaseToolkit.itemCreatorData.itemLink~=nil and PhaseToolkit.ModifyItemData) then
			if(PhaseToolkit.itemCreatorData.itemLink~=nil) then
				maxDescriptionSize=254-(string.len("f i s de ")+string.len(" "..PhaseToolkit.itemCreatorData.itemLink.." "))
			end
			local itemLink=" "..PhaseToolkit.itemCreatorData.itemLink.." "
			if((string.len(self:GetText())<maxDescriptionSize)) then
				sendAddonCmd("f i s de "..itemLink..PhaseToolkit.itemCreatorData.itemDescription,nil,false)
				PhaseToolkit.HideTooltip()
				PhaseToolkit.DescriptionInputBox.ScrollFrame.EditBox:SetScript("OnEnter",nil)
				PhaseToolkit.DescriptionInputBox.ScrollFrame.EditBox:SetScript("OnLeave",nil)
			else
				local border = DescriptionFrame:CreateTexture(nil, "BACKGROUND")
				border:SetColorTexture(1, 0, 0, 1) -- red (R, G, B, Alpha)
				border:SetPoint("TOPLEFT", -2, 2)
				border:SetPoint("BOTTOMRIGHT", 2, -2)
				PhaseToolkit.ShowTooltip(self,"Your description is too big and will be send in multiple part\nclick the Apply description button on the top-right")
				PhaseToolkit.DescriptionInputBox.ScrollFrame.EditBox:SetScript("OnEnter",function(self)
					PhaseToolkit.ShowTooltip(self,"Your description is too big and will be send in multiple part\nclick the Apply description button on the top-right")
				end)
				PhaseToolkit.DescriptionInputBox.ScrollFrame.EditBox:SetScript("OnLeave",function() PhaseToolkit.HideTooltip() end)

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

	PhaseToolkit.itemCreatorCheckboxStackable.Text:SetText("Stackable")
	PhaseToolkit.itemCreatorCheckboxStackable.Text:SetPoint("LEFT", PhaseToolkit.itemCreatorCheckboxStackable, "RIGHT", 5, 0)

	PhaseToolkit.itemCreatorCheckboxStackable:SetScript("OnClick", function(self)
		if self:GetChecked() then
			PhaseToolkit.itemCreatorData.stackable=true
		else
			PhaseToolkit.itemCreatorData.stackable=false
		end
	end)

	PhaseToolkit.iconIdEditBox = CreateFrame("EditBox", "iconIdEditBox", displayProperty, "InputBoxTemplate")
	PhaseToolkit.iconIdEditBox:SetSize(150, 30)
	PhaseToolkit.iconIdEditBox:SetPoint("TOPLEFT",PhaseToolkit.ItemSheathDropdown,"BOTTOMLEFT",20,-10)
	PhaseToolkit.iconIdEditBox:SetAutoFocus(false)

	PhaseToolkit.iconIdEditBox:SetScript("OnTextChanged",function()
		if(PhaseToolkit.iconIdEditBox:GetText()=="") then
			PhaseToolkit.itemCreatorData.IconLink=nil
		end
	end)

	PhaseToolkit.iconIdEditBox:SetScript("OnEnterPressed",function()
		if(PhaseToolkit.iconIdEditBox:GetText()~="") then
			PhaseToolkit.itemCreatorData.IconLink=PhaseToolkit.iconIdEditBox:GetText()
			if(PhaseToolkit.itemCreatorData.itemLink~=nil) then
				local itemLink=" "..PhaseToolkit.itemCreatorData.itemLink.." "
				sendAddonCmd("forge item set icon "..itemLink..PhaseToolkit.itemCreatorData.itemIconIdOrLink,nil,false)
			end
		end
	end)

	local orig_ChatEdit_InsertLink = ChatEdit_InsertLink

	ChatEdit_InsertLink = function(link)
		if PhaseToolkit.iconIdEditBox:HasFocus() then
			PhaseToolkit.iconIdEditBox:Insert(link)
			PhaseToolkit.itemCreatorData.itemIconIdOrLink=PhaseToolkit.iconIdEditBox:GetText()
			if(PhaseToolkit.itemCreatorData.itemLink~=nil) then
				local itemLink=" "..PhaseToolkit.itemCreatorData.itemLink.." "
				sendAddonCmd("forge item set icon "..itemLink..PhaseToolkit.itemCreatorData.itemIconIdOrLink,nil,false)
			end
		else
			orig_ChatEdit_InsertLink(link)
		end
	end
	local LabeldisplayEditBox=displayProperty:CreateFontString(nil,"OVERLAY","GameFontNormal")
	LabeldisplayEditBox:SetText(PhaseToolkit.CurrentLang["Icon from:"])
	LabeldisplayEditBox:SetPoint("BOTTOMLEFT", PhaseToolkit.iconIdEditBox, "TOPLEFT", 5, 0)

	PhaseToolkit.RegisterTooltip(PhaseToolkit.iconIdEditBox, "Item Link or ID")

	PhaseToolkit.iconIdEditBox:SetScript("OnEnterPressed",function(self)
		if(self:GetText()~=nil) then
			local itemName,itemLink =GetItemInfo(self:GetText())
			PhaseToolkit.itemCreatorData.IconLink=itemLink
		end
	end)


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
	PhaseToolkit.ShowadderOptionDropdown(adderOptionDropdown)
	PhaseToolkit.RegisterTooltip(adderOptionDropdown, "Controls if the item contains a '<Made by Character>' tag when added.\n\nEnabling this will disable the Creator tag property.")

	local addItemOptionDropdown = CreateFrame("Frame", nil, itemProperty, "UIDropDownMenuTemplate")
	addItemOptionDropdown:SetSize(100, 30)
	addItemOptionDropdown:SetPoint("TOPLEFT", itemProperty, "TOPLEFT", -10,-30)
	PhaseToolkit.addItemOptionDropdown(addItemOptionDropdown)
	PhaseToolkit.RegisterTooltip(addItemOptionDropdown, "Controls who is allowed to add this item.\n\nIf Member / Officer is enabled, will only work for Phases specifically added to the Member / Officer whitelist (use the buttons to the right!)")

	local copyOptionDropdown = CreateFrame("Frame", nil, itemProperty, "UIDropDownMenuTemplate")
	copyOptionDropdown:SetSize(100, 30)
	copyOptionDropdown:SetPoint("TOPLEFT", itemProperty, "TOPLEFT", -10,-55)
	PhaseToolkit.copyItemOptionDropdown(copyOptionDropdown)
	PhaseToolkit.RegisterTooltip(copyOptionDropdown, "Controls who is allowed to copy or clone this item via 'forge item copy/clone'.")

	local creatorOptionDropdown = CreateFrame("Frame", nil, itemProperty, "UIDropDownMenuTemplate")
	creatorOptionDropdown:SetSize(100, 30)
	creatorOptionDropdown:SetPoint("TOPLEFT", itemProperty, "TOPLEFT", -10,-80)
	PhaseToolkit.creatorItemOptionDropdown(creatorOptionDropdown)
	PhaseToolkit.RegisterTooltip(creatorOptionDropdown, "When enabled, adds a <Made by $CreatorCharacterName> to the item.\n\nEnabling this will disable the Adder tag property.")

	local infoOptionDropdown = CreateFrame("Frame", nil, itemProperty, "UIDropDownMenuTemplate")
	infoOptionDropdown:SetSize(100, 30)
	infoOptionDropdown:SetPoint("TOPLEFT", itemProperty, "TOPLEFT", -10,-105)
	PhaseToolkit.infoItemOptionDropdown(infoOptionDropdown)
	PhaseToolkit.RegisterTooltip(infoOptionDropdown, "Sets if information for this item is visible to others.")

	local lookupOptionDropdown = CreateFrame("Frame", nil, itemProperty, "UIDropDownMenuTemplate")
	lookupOptionDropdown:SetSize(100, 30)
	lookupOptionDropdown:SetPoint("TOPLEFT", itemProperty, "TOPLEFT", -10,-130)
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
    content:SetSize(100, 30 * #data) -- Ajuste la hauteur en fonction du nombre d'éléments
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

		for _,additemOption in ipairs(PhaseToolkit.itemCreatorData.additemOption) do
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
				if (PhaseToolkit.IsCurrentlyFilteringNpc) then
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


	local ButtonToFetch = CreateFrame("Button", nil, PhaseToolkit.PNJFrame, "UIPanelButtonTemplate")
	ButtonToFetch:SetSize(120, 15)
	ButtonToFetch:SetPoint("TOPRIGHT", PhaseToolkit.PNJFrame, "TOPRIGHT", -30, -3.5)
	ButtonToFetch:SetText(PhaseToolkit.CurrentLang["Fetch Npcs"] or "Fetch Npcs")
	ButtonToFetch:SetScript("OnClick", function()
		PhaseToolkit.IsCurrentlyFilteringNpc = false
		PhaseToolkit.filteredCreatureList = {}
		PhaseToolkit.NPCListCurrentPage=currentPage
		PhaseToolkit.PhaseNpcListSystemMessageCounter()
	end)
	PhaseToolkit.RegisterTooltip(ButtonToFetch, "This can take a few seconds.")

	local ButtonToChangeNumberOfLine = CreateFrame("Button", nil, PhaseToolkit.PNJFrame, "UIPanelButtonTemplate")
	ButtonToChangeNumberOfLine:SetSize(15, 15)
	ButtonToChangeNumberOfLine:SetPoint("TOPLEFT", PhaseToolkit.PNJFrame, "TOPLEFT", 5, -3.5)
	ButtonToChangeNumberOfLine.icon = ButtonToChangeNumberOfLine:CreateTexture(nil, "OVERLAY")
	ButtonToChangeNumberOfLine.icon:SetTexture("Interface\\Icons\\trade_engineering")
	ButtonToChangeNumberOfLine.icon:SetAllPoints()
	ButtonToChangeNumberOfLine:SetScript("OnClick", PhaseToolkit.CreerFenetreLignesParPage)

	local function SearchAndFindNpcByText(self)
		if self:GetText() ~= nil and self:GetText() ~= "" then
			PhaseToolkit.filteredCreatureList = {}
			PhaseToolkit.CurrenttextToLookForNpc = self:GetText()
			PhaseToolkit.IsCurrentlyFilteringNpc = true

			for _, creature in ipairs(PhaseToolkit.creatureList) do
				if string.find(creature["NomCreature"], PhaseToolkit.CurrenttextToLookForNpc) then
					table.insert(PhaseToolkit.filteredCreatureList, creature)
				end
			end
			PhaseToolkit.PNJFrame:Hide()
			PhaseToolkit.PNJFrame = nil
			PhaseToolkit.CreateNpcListFrame(PhaseToolkit.filteredCreatureList)
		elseif self:GetText() == "" and PhaseToolkit.IsCurrentlyFilteringNpc == true then
			PhaseToolkit.PNJFrame:Hide()
			PhaseToolkit.PNJFrame = nil
			PhaseToolkit.CurrenttextToLookForNpc = ""
			PhaseToolkit.IsCurrentlyFilteringNpc = false
			PhaseToolkit.CreateNpcListFrame(PhaseToolkit.creatureList)
		end
	end

	if (PhaseToolkit.creatureList ~= nil and PhaseToolkit.IsTableEmpty(PhaseToolkit.creatureList) == false) then
		PhaseToolkit.LookupInNpcListEditBox = CreateFrame("EditBox", nil, PhaseToolkit.PNJFrame, "InputBoxTemplate")

		if (PhaseToolkit.GetMaxNameWidth(PhaseToolkit.creatureList) < 80) then
			PhaseToolkit.LookupInNpcListEditBox:SetSize(130, 20)
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
		sendAddonCmd("n spawn " .. pnjId, nil, false)
	end

	local function OnDeleteClick(pnjId)
		sendAddonCmd("ph forge npc delete " .. pnjId, nil, false)
		PhaseToolkit.RemoveCreatureById(PhaseToolkit.creatureList, pnjId)
		PhaseToolkit.UpdatePNJPagination(PhaseToolkit.creatureList)
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

		PNJRows[i] = row
	end

	local function DisplayPage(creatureList)
		-- Calcul des indices de la page actuelle
		local startIndex = (currentPage - 1) * PhaseToolkit.itemsPerPageNPC + 1
		local endIndex = math.min(currentPage * PhaseToolkit.itemsPerPageNPC, #creatureList)

		-- Calculer la largeur maximale des noms pour la page actuelle
		local pageCreatureList = {}
		for i = startIndex, endIndex do
			table.insert(pageCreatureList, creatureList[i])
		end

		local maxNameWidth = PhaseToolkit.GetMaxNameWidth(pageCreatureList)

		-- Ajuster la largeur de la GlobalNPCCUSTOMISER_PNJFrame en fonction de la largeur maximale des noms
		local frameWidth = maxNameWidth + 190 -- 180 pour les boutons et marges
		PhaseToolkit.PNJFrame:SetWidth(frameWidth + 30 * 2)

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
			else
				row:Hide()
			end
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
	NpcCurrentPageeditBox:SetText(currentPage)

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
			NpcCurrentPageeditBox:SetText(currentPage)
			if (PhaseToolkit.IsCurrentlyFilteringNpc) then
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
		DisplayPage(creatureList)
		NumberOfPageMaxLabelNPC:SetText("/ " .. totalPages)
	end

	nextButton:SetScript("OnClick", function()
		if currentPage < totalPages then
			currentPage = currentPage + 1
			NpcCurrentPageeditBox:SetText(currentPage)
			PhaseToolkit.UpdatePNJPagination(_creatureList) -- Mise à jour avec la liste de PNJ fournie
		end
	end)

	prevButton:SetScript("OnClick", function()
		if currentPage > 1 then
			currentPage = currentPage - 1
			NpcCurrentPageeditBox:SetText(currentPage)
			PhaseToolkit.UpdatePNJPagination(_creatureList)
		end
	end)

	PhaseToolkit.PNJFrame:SetScript("OnShow", function()
		currentPage = 1
		PhaseToolkit.UpdatePNJPagination(_creatureList)
	end)

	PhaseToolkit.UpdatePNJPagination(_creatureList)
end

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
		else
			PhaseToolkit.TELEFrame:SetSize(PhaseToolkit.GetMaxStringWidth(PhaseToolkit.teleList), 400)
			PhaseToolkit.TELEFrame:Show()
		end
		return
	end

	local currentPage=1

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

				if (PhaseToolkit.IsCurrentlyFilteringTele) then
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


	local ButtonToFetch = CreateFrame("Button", nil, PhaseToolkit.TELEFrame, "UIPanelButtonTemplate")
	ButtonToFetch:SetSize(120, 15)
	ButtonToFetch:SetPoint("TOPRIGHT", PhaseToolkit.TELEFrame, "TOPRIGHT", -30, -3.5)
	ButtonToFetch:SetText(PhaseToolkit.CurrentLang["Fetch Tele"] or "Fetch Tele")
	ButtonToFetch:SetScript("OnClick", function()
		PhaseToolkit.IsCurrentlyFilteringTele = false
		PhaseToolkit.filteredTeleList = {}
		PhaseToolkit.TELEListcurrentPage=currentPage
		PhaseToolkit.PhaseTeleListSystemMessageCounter()
	end)
	PhaseToolkit.RegisterTooltip(ButtonToFetch, "This can take a few seconds.")

	local ButtonToChangeNumberOfLine = CreateFrame("Button", nil, PhaseToolkit.TELEFrame, "UIPanelButtonTemplate")
	ButtonToChangeNumberOfLine:SetSize(15, 15)
	ButtonToChangeNumberOfLine:SetPoint("TOPLEFT", PhaseToolkit.TELEFrame, "TOPLEFT", 5, -5)
	ButtonToChangeNumberOfLine.icon = ButtonToChangeNumberOfLine:CreateTexture(nil, "OVERLAY")
	ButtonToChangeNumberOfLine.icon:SetTexture("Interface\\Icons\\trade_engineering")
	ButtonToChangeNumberOfLine.icon:SetAllPoints()
	ButtonToChangeNumberOfLine:SetScript("OnClick", PhaseToolkit.CreerFenetreLignesParPage)
	PhaseToolkit.RegisterTooltip(ButtonToChangeNumberOfLine, "Change list size")

	local function SearchAndFindTeleByText(self)
		if self:GetText() ~= nil and self:GetText() ~= "" then
			PhaseToolkit.filteredTeleList = {}
			CurrenttextToLookForTele = self:GetText()
			PhaseToolkit.IsCurrentlyFilteringTele = true

			for i = 1, #PhaseToolkit.teleList do
				if string.find(PhaseToolkit.teleList[i], CurrenttextToLookForTele) then
					table.insert(PhaseToolkit.filteredTeleList, PhaseToolkit.teleList[i])
				end
			end
			PhaseToolkit.TELEFrame:Hide()
			PhaseToolkit.TELEFrame = nil
			PhaseToolkit.CreateTeleListFrame(PhaseToolkit.filteredTeleList)
		elseif self:GetText() == "" and PhaseToolkit.IsCurrentlyFilteringTele == true then
			PhaseToolkit.TELEFrame:Hide()
			PhaseToolkit.TELEFrame = nil
			CurrenttextToLookForTele = ""
			PhaseToolkit.IsCurrentlyFilteringTele = false
			PhaseToolkit.CreateTeleListFrame(PhaseToolkit.teleList)
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
		sendAddonCmd("phase tele " .. teleId .. " ", nil, false)
		-- Logique d'apparition (spawn) de la créature
	end

	-- Fonction appelée lors du clic sur le bouton "Delete"
	local function OnDeleteClick(teleId)
		sendAddonCmd("phase tele delete " .. teleId .. " ", nil, false)
		PhaseToolkit.RemoveStringFromTable(PhaseToolkit.teleList, teleId)
		TeleUpdatePagination(PhaseToolkit.teleList)

		-- Logique de suppression de la créature
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

		-- Ajouter la ligne au tableau pour gestion
		PNJRows[i] = row
	end



	-- Fonction pour afficher les PNJ sur la page actuelle
	local function DisplayPage(teleList)
		-- Calcul des indices de la page actuelle
		local startIndex = (currentPage - 1) * PhaseToolkit.itemsPerPageTELE + 1
		local endIndex = math.min(currentPage * PhaseToolkit.itemsPerPageTELE, #teleList)

		-- Calculer la largeur maximale des noms pour la page actuelle
		local pageteleList = {}
		for i = startIndex, endIndex do
			table.insert(pageteleList, teleList[i])
		end

		local maxNameWidth = PhaseToolkit.GetMaxStringWidth(pageteleList)

		-- Ajuster la largeur de la GlobalNPCCUSTOMISER_TELEFrame en fonction de la largeur maximale des noms
		local frameWidth = maxNameWidth + 180 -- 180 pour les boutons et marges
		PhaseToolkit.TELEFrame:SetWidth(frameWidth + 30 * 2)

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
			else
				row:Hide()
			end
		end
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
			if (PhaseToolkit.IsCurrentlyFilteringTele) then
				TeleUpdatePagination(PhaseToolkit.filteredTeleList)
			else
				TeleUpdatePagination(PhaseToolkit.teleList)
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
	function TeleUpdatePagination(teleList)
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
			TeleUpdatePagination(_teleList) -- Mise à jour avec la liste de PNJ fournie
		end
	end)

	prevButton:SetScript("OnClick", function()
		if currentPage > 1 then
			currentPage = currentPage - 1
			TeleCurrentPageeditBox:SetText(currentPage)
			TeleUpdatePagination(_teleList)
		end
	end)

	-- Affichage initial des PNJ à la première page
	PhaseToolkit.TELEFrame:SetScript("OnShow", function()
		currentPage = 1
		TeleUpdatePagination(_teleList)
	end)

	TeleUpdatePagination(_teleList)
end

--=============================== Recuperation de PNJ ===========================--
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
					GlobalNPCCUSTOMISER_RadioWhitelist:SetChecked(false)
					GlobalNPCCUSTOMISER_RadioBlacklist:SetChecked(true)
				elseif listType == "Whitelist" then
					PhaseToolkit.IsPhaseWhitelist = true
					GlobalNPCCUSTOMISER_RadioBlacklist:SetChecked(false)
					GlobalNPCCUSTOMISER_RadioWhitelist:SetChecked(true)
				end

				local phaseName = string.match(message, "Phase%s+%[(.*)-")
				if (phaseName ~= nil) then
					GlobalNPCCUSTOMISERnameTextEdit:SetText(phaseName)
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
	GlobalNPCCUSTOMISER_moduleForPhaseAccessFrame = CreateFrame("Frame", nil, PhaseToolkit.PhaseOptionFrame, "BackdropTemplate")
	GlobalNPCCUSTOMISER_moduleForPhaseAccessFrame:SetBackdrop({
		bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
		edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
		edgeSize = 16,
		insets = { left = 5, right = 5, top = 5, bottom = 5 },
	})
	GlobalNPCCUSTOMISER_moduleForPhaseAccessFrame:SetSize(165, 80)
	GlobalNPCCUSTOMISER_moduleForPhaseAccessFrame:SetPoint("TOPLEFT", PhaseToolkit.PhaseOptionFrame, "TOPLEFT", 5, -5)



	GlobalNPCCUSTOMISER_RadioBlacklist = CreateFrame("CheckButton", "RadioBlacklist", GlobalNPCCUSTOMISER_moduleForPhaseAccessFrame, "UIRadioButtonTemplate")
	GlobalNPCCUSTOMISER_RadioBlacklist:SetPoint("BOTTOMLEFT", GlobalNPCCUSTOMISER_moduleForPhaseAccessFrame, "BOTTOMLEFT", 10, 10)
	local labelForBlacklist = GlobalNPCCUSTOMISER_moduleForPhaseAccessFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	labelForBlacklist:SetPoint("LEFT", GlobalNPCCUSTOMISER_RadioBlacklist, "RIGHT", 0, 1)
	labelForBlacklist:SetText("Blacklist")


	GlobalNPCCUSTOMISER_RadioWhitelist = CreateFrame("CheckButton", "RadioWhitelist", GlobalNPCCUSTOMISER_moduleForPhaseAccessFrame, "UIRadioButtonTemplate")
	GlobalNPCCUSTOMISER_RadioWhitelist:SetPoint("LEFT", GlobalNPCCUSTOMISER_RadioBlacklist, "RIGHT", 60, 0)

	local labelForWhitelist = GlobalNPCCUSTOMISER_moduleForPhaseAccessFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	labelForWhitelist:SetPoint("LEFT", GlobalNPCCUSTOMISER_RadioWhitelist, "RIGHT", 0, 1)
	labelForWhitelist:SetText("Whitelist")



	GlobalNPCCUSTOMISER_phaseAccessLabel = GlobalNPCCUSTOMISER_moduleForPhaseAccessFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	GlobalNPCCUSTOMISER_phaseAccessLabel:SetPoint("TOP", GlobalNPCCUSTOMISER_moduleForPhaseAccessFrame, "TOP", 0, -7.5)
	GlobalNPCCUSTOMISER_phaseAccessLabel:SetText(PhaseToolkit.CurrentLang["Phase Access"] or "Phase Access")


	local function RadioButton_OnClick(self)
		GlobalNPCCUSTOMISER_RadioBlacklist:SetChecked(false)
		GlobalNPCCUSTOMISER_RadioWhitelist:SetChecked(false)
		self:SetChecked(true)

		if (PhaseToolkit.IsPhaseWhitelist) then
			if self:GetName() == "RadioWhitelist" then
				return
			elseif self:GetName() == "RadioBlacklist" then
				sendAddonCmd("phase toggle private", nil, false)
				PhaseToolkit.IsPhaseWhitelist = false
			end
		elseif not PhaseToolkit.IsPhaseWhitelist then
			if self:GetName() == "RadioWhitelist" then
				sendAddonCmd("phase toggle private", nil, false)
				PhaseToolkit.IsPhaseWhitelist = true
			elseif self:GetName() == "RadioBlacklist" then
				return
			end
		end
	end

	GlobalNPCCUSTOMISER_RadioBlacklist:SetScript("OnClick", RadioButton_OnClick)
	GlobalNPCCUSTOMISER_RadioWhitelist:SetScript("OnClick", RadioButton_OnClick)

	if (PhaseToolkit.IsPhaseWhitelist) then
		GlobalNPCCUSTOMISER_RadioWhitelist:SetChecked(true)
	elseif not PhaseToolkit.IsPhaseWhitelist then
		GlobalNPCCUSTOMISER_RadioBlacklist:SetChecked(true)
	end
end

--==== Module de météo ====--
function PhaseToolkit.createMeteoSettingsFrame()
	GlobalNPCCUSTOMISER_moduleForMetteoSettingsFrame = CreateFrame("Frame", nil, PhaseToolkit.PhaseOptionFrame, "BackdropTemplate")
	GlobalNPCCUSTOMISER_moduleForMetteoSettingsFrame:SetBackdrop({
		bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
		edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
		edgeSize = 16,
		insets = { left = 5, right = 5, top = 5, bottom = 5 },
	})
	GlobalNPCCUSTOMISER_moduleForMetteoSettingsFrame:SetSize(165, 80)
	GlobalNPCCUSTOMISER_moduleForMetteoSettingsFrame:SetPoint("TOPRIGHT", PhaseToolkit.PhaseOptionFrame, "TOPRIGHT", -5, -5)
	-- --=== Dropdown ===--
	PhaseToolkit.MeteoDropDown = CreateFrame("Frame", "MeteoDropDown", GlobalNPCCUSTOMISER_moduleForMetteoSettingsFrame, "UIDropDownMenuTemplate")
	PhaseToolkit.MeteoDropDown:SetSize(200, 30)
	PhaseToolkit.MeteoDropDown:SetPoint("TOP", GlobalNPCCUSTOMISER_moduleForMetteoSettingsFrame, "TOP", 0, -2.5)

	PhaseToolkit.ShowMeteoDropDown(PhaseToolkit.MeteoDropDown)

	--=== Slider ===--
	GlobalNPCCUSTOMISER_SliderFrame = CreateFrame("Slider", "MyCustomSlider", GlobalNPCCUSTOMISER_moduleForMetteoSettingsFrame, "OptionsSliderTemplate")
	GlobalNPCCUSTOMISER_SliderFrame:SetSize(150, 20)

	GlobalNPCCUSTOMISER_SliderFrame:SetPoint("TOP", GlobalNPCCUSTOMISER_moduleForMetteoSettingsFrame, "CENTER", 0, 0)
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
	GlobalNPCCUSTOMISER_moduleForTimeSliderFrame = CreateFrame("Frame", nil, PhaseToolkit.PhaseOptionFrame, "BackdropTemplate")
	GlobalNPCCUSTOMISER_moduleForTimeSliderFrame:SetBackdrop({
		bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
		edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
		edgeSize = 16,
		insets = { left = 5, right = 5, top = 5, bottom = 5 },
	})
	GlobalNPCCUSTOMISER_moduleForTimeSliderFrame:SetSize(340, 80)
	GlobalNPCCUSTOMISER_moduleForTimeSliderFrame:SetPoint("TOPLEFT", PhaseToolkit.PhaseOptionFrame, "TOPLEFT", 5, -85)

	local timeSliderLabel = GlobalNPCCUSTOMISER_moduleForTimeSliderFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	timeSliderLabel:SetPoint("TOP", GlobalNPCCUSTOMISER_moduleForTimeSliderFrame, "TOP", 0, -10)
	timeSliderLabel:SetText(PhaseToolkit.CurrentLang["Set the time"] or "Set the time")


	local slider = CreateFrame("Slider", "$parentSlider", GlobalNPCCUSTOMISER_moduleForTimeSliderFrame, "OptionsSliderTemplate")
	slider:SetPoint("LEFT", GlobalNPCCUSTOMISER_moduleForTimeSliderFrame, 15, 0)

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
		sendAddonCmd("phase set time " .. time, nil, false)
		self.Text:SetText(time)
		self.last = value
	end)
end

--==== Module pour le starting ====--
function PhaseToolkit.createSetStartingFrame()
	-- need une frame module
	GlobalNPCCUSTOMISER_moduleForSetStartingFrame = CreateFrame("Frame", nil, PhaseToolkit.PhaseOptionFrame, "BackdropTemplate")
	GlobalNPCCUSTOMISER_moduleForSetStartingFrame:SetBackdrop({
		bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
		edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
		edgeSize = 16,
		insets = { left = 5, right = 5, top = 5, bottom = 5 },
	})
	GlobalNPCCUSTOMISER_moduleForSetStartingFrame:SetSize(165, 80)
	GlobalNPCCUSTOMISER_moduleForSetStartingFrame:SetPoint("TOPLEFT", PhaseToolkit.PhaseOptionFrame, "TOPLEFT", 5, -80 * 2 - 5)

	local startingLabel = GlobalNPCCUSTOMISER_moduleForSetStartingFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	startingLabel:SetPoint("TOP", GlobalNPCCUSTOMISER_moduleForSetStartingFrame, "TOP", 0, -10)
	startingLabel:SetText(PhaseToolkit.CurrentLang["Starting point"] or 'Starting point')

	local ButtonSetStarting = CreateFrame("Button", nil, GlobalNPCCUSTOMISER_moduleForSetStartingFrame, "UIPanelButtonTemplate")
	ButtonSetStarting:SetPoint("CENTER", GlobalNPCCUSTOMISER_moduleForSetStartingFrame, "CENTER", 0, -10)
	ButtonSetStarting:SetPoint("LEFT", 5, 0)
	ButtonSetStarting:SetPoint("RIGHT", -5, 0)
	ButtonSetStarting:SetText(PhaseToolkit.CurrentLang["Set Current Location"] or "Set Current Location")
	ButtonSetStarting:SetScript("OnClick", function()
		sendAddonCmd("phase set starting ", nil, false)
	end
	)

	local ButtonDisableStart = CreateFrame("Button", nil, GlobalNPCCUSTOMISER_moduleForSetStartingFrame, "UIPanelButtonTemplate")
	ButtonDisableStart:SetPoint("BOTTOM", GlobalNPCCUSTOMISER_moduleForSetStartingFrame, "BOTTOM", 0, 5)
	ButtonDisableStart:SetPoint("LEFT", 15, 0)
	ButtonDisableStart:SetPoint("RIGHT", -15, 0)
	ButtonDisableStart:SetText(PhaseToolkit.CurrentLang["Disable Starting"] or "Disable Starting")
	ButtonDisableStart:SetScript("OnClick", function()
		sendAddonCmd("phase set starting disable ", nil, false)
	end
	)
end

--==== Module pour les toggles ====--
function PhaseToolkit.createTogglesFrame()
	-- need une frame module
	GlobalNPCCUSTOMISER_moduleForTogglesFrame = CreateFrame("Frame", nil, PhaseToolkit.PhaseOptionFrame, "BackdropTemplate")
	GlobalNPCCUSTOMISER_moduleForTogglesFrame:SetBackdrop({
		bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
		edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
		edgeSize = 16,
		insets = { left = 5, right = 5, top = 5, bottom = 5 },
	})
	GlobalNPCCUSTOMISER_moduleForTogglesFrame:SetSize(165, 80)
	GlobalNPCCUSTOMISER_moduleForTogglesFrame:SetPoint("TOPLEFT", PhaseToolkit.PhaseOptionFrame, "TOPLEFT", 15 + 165, -80 * 2 - 5)

	local startingLabel = GlobalNPCCUSTOMISER_moduleForTogglesFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	startingLabel:SetPoint("TOP", GlobalNPCCUSTOMISER_moduleForTogglesFrame, "TOP", 0, -10)
	startingLabel:SetText(PhaseToolkit.CurrentLang["Permission disabling"] or 'Permission disabling')

	Togglesdropdown = CreateFrame("FRAME", "$parentDropDown", GlobalNPCCUSTOMISER_moduleForTogglesFrame, "UIDropDownMenuTemplate")
	Togglesdropdown:SetSize(200, 30)
	Togglesdropdown:SetPoint("CENTER", GlobalNPCCUSTOMISER_moduleForTogglesFrame, "CENTER", 0, -10)

	PhaseToolkit.ShowToggleDropDown(Togglesdropdown)
end

--==== Module pour le nom ====--
function PhaseToolkit.createPhaseSetNameFrame()
	GlobalNPCCUSTOMISER_moduleForPhaseSetNameFrame = CreateFrame("Frame", nil, PhaseToolkit.PhaseOptionFrame, "BackdropTemplate")
	GlobalNPCCUSTOMISER_moduleForPhaseSetNameFrame:SetBackdrop({
		bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
		edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
		edgeSize = 16,
		insets = { left = 5, right = 5, top = 5, bottom = 5 },
	})
	GlobalNPCCUSTOMISER_moduleForPhaseSetNameFrame:SetSize(165, 80)
	GlobalNPCCUSTOMISER_moduleForPhaseSetNameFrame:SetPoint("TOPLEFT", PhaseToolkit.PhaseOptionFrame, "TOPLEFT", 5, -5 - 80 * 3)


	GlobalNPCCUSTOMISERnameTextEdit = CreateFrame("EDITBOX", nil, GlobalNPCCUSTOMISER_moduleForPhaseSetNameFrame, "InputBoxTemplate")
	GlobalNPCCUSTOMISERnameTextEdit:SetSize(130, 20)
	GlobalNPCCUSTOMISERnameTextEdit:SetPoint("CENTER", GlobalNPCCUSTOMISER_moduleForPhaseSetNameFrame, "CENTER", 2.5, 0)
	GlobalNPCCUSTOMISERnameTextEdit:SetAutoFocus(false)
	GlobalNPCCUSTOMISERnameTextEdit:SetScript("OnEnterPressed", function(self)
		sendAddonCmd("phase rename " .. self:GetText(), nil, false)
	end)

	local labelForNameTextEdit = GlobalNPCCUSTOMISER_moduleForPhaseSetNameFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	labelForNameTextEdit:SetPoint("TOP", GlobalNPCCUSTOMISER_moduleForPhaseSetNameFrame, "TOP", 0, -15)
	labelForNameTextEdit:SetText(PhaseToolkit.CurrentLang["Phase Name"] or "Phase Name")
end

--==== Module pour la description ====--
function PhaseToolkit.createPhaseSetDescriptionFrame()
	GlobalNPCCUSTOMISER_moduleForPhaseSetDescriptionFrame = CreateFrame("Frame", nil, PhaseToolkit.PhaseOptionFrame, "BackdropTemplate")
	GlobalNPCCUSTOMISER_moduleForPhaseSetDescriptionFrame:SetBackdrop({
		bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
		edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
		edgeSize = 16,
		insets = { left = 5, right = 5, top = 5, bottom = 5 },
	})
	GlobalNPCCUSTOMISER_moduleForPhaseSetDescriptionFrame:SetSize(165, 80)
	GlobalNPCCUSTOMISER_moduleForPhaseSetDescriptionFrame:SetPoint("TOPRIGHT", PhaseToolkit.PhaseOptionFrame, "TOPRIGHT", -5, -5 - 80 * 3)

	GlobalNPCCUSTOMISER_DescTextEdit = CreateFrame("EDITBOX", nil, GlobalNPCCUSTOMISER_moduleForPhaseSetDescriptionFrame, "InputBoxTemplate")
	GlobalNPCCUSTOMISER_DescTextEdit:SetSize(130, 20)
	GlobalNPCCUSTOMISER_DescTextEdit:SetPoint("CENTER", GlobalNPCCUSTOMISER_moduleForPhaseSetDescriptionFrame, "CENTER", 2.5, 0)
	GlobalNPCCUSTOMISER_DescTextEdit:SetAutoFocus(false)
	GlobalNPCCUSTOMISER_DescTextEdit:SetScript("OnEnterPressed", function(self)
		sendAddonCmd("phase set description " .. self:GetText(), nil, false)
	end)

	local labelForNameTextEdit = GlobalNPCCUSTOMISER_moduleForPhaseSetDescriptionFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	labelForNameTextEdit:SetPoint("TOP", GlobalNPCCUSTOMISER_moduleForPhaseSetDescriptionFrame, "TOP", 0, -15)
	labelForNameTextEdit:SetText(PhaseToolkit.CurrentLang["Phase Description"] or "Phase Description")
end

function PhaseToolkit.createMotdFrame()
	GlobalNPCCUSTOMISER_moduleforMotdFrame = CreateFrame("Frame", nil, PhaseToolkit.PhaseOptionFrame, "BackdropTemplate")
	GlobalNPCCUSTOMISER_moduleforMotdFrame:SetBackdrop({
		bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
		edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
		edgeSize = 16,
		insets = { left = 5, right = 5, top = 5, bottom = 5 },
	})
	GlobalNPCCUSTOMISER_moduleforMotdFrame:SetSize(340, 120)
	GlobalNPCCUSTOMISER_moduleforMotdFrame:SetPoint("BOTTOM", PhaseToolkit.PhaseOptionFrame, "BOTTOM", 0, 5)

	local textForMotd = ""
	GlobalNPCCUSTOMISER_editBoxForMotd = CreateFrame("FRAME", "$parentEdit", GlobalNPCCUSTOMISER_moduleforMotdFrame, "EpsilonInputScrollTemplate")
	GlobalNPCCUSTOMISER_editBoxForMotd:SetPoint("BOTTOMLEFT", GlobalNPCCUSTOMISER_moduleforMotdFrame, "BOTTOMLEFT", 5, 5)
	GlobalNPCCUSTOMISER_editBoxForMotd:SetSize(330, 95)
	GlobalNPCCUSTOMISER_editBoxForMotd.ScrollFrame.EditBox:SetScript("OnTextChanged", function(self)
		textForMotd = self:GetText()
	end)

	local labelForMotdTextEdit = GlobalNPCCUSTOMISER_moduleforMotdFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	labelForMotdTextEdit:SetPoint("TOP", GlobalNPCCUSTOMISER_moduleforMotdFrame, "TOP", 0, -5)
	labelForMotdTextEdit:SetText(PhaseToolkit.CurrentLang["Message of the day"] or "Message of the day")


	local buttonToSendMotd = CreateFrame("Button", nil, GlobalNPCCUSTOMISER_moduleforMotdFrame, "UIPanelButtonTemplate")
	buttonToSendMotd:SetPoint("TOPRIGHT", GlobalNPCCUSTOMISER_moduleforMotdFrame, "TOPRIGHT", 0, 0)
	buttonToSendMotd:SetSize(80, 20)
	buttonToSendMotd:SetText(PhaseToolkit.CurrentLang["SetMotd"] or "SetMotd")
	buttonToSendMotd:SetScript("OnClick", function(self)
		sendAddonCmd("phase set message " .. textForMotd, nil, false)
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
			sendAddonCmd("phase forge npc name " .. npcName, nil, false)
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
			sendAddonCmd("phase forge npc subname " .. npcName, nil, false)
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

					sendAddonCmd("phase forge npc outfit custom " .. attribute .. " " .. PhaseToolkit.GeneralStat[attribute], nil, false)
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
				sendAddonCmd("phase forge npc outfit custom " .. attribute .. " " .. PhaseToolkit.GeneralStat[attribute], nil, false)
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
					sendAddonCmd("phase forge npc outfit custom " .. attribute .. " " .. PhaseToolkit.GeneralStat[attribute], nil, false)
					AttributeValueEditBox:SetNumber(PhaseToolkit.GeneralStat[attribute])
					return
				end
				if PhaseToolkit.GeneralStat[attribute] - 1 >= 1 then
					PhaseToolkit.GeneralStat[attribute] = PhaseToolkit.GeneralStat[attribute] - 1
					sendAddonCmd("phase forge npc outfit custom " .. attribute .. " " .. PhaseToolkit.GeneralStat[attribute], nil, false)
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
					sendAddonCmd("phase forge npc outfit custom " .. attribute .. " " .. PhaseToolkit.GeneralStat[attribute], nil, false)
					AttributeValueEditBox:SetNumber(PhaseToolkit.GeneralStat[attribute])
					return
				end
				if PhaseToolkit.GeneralStat[attribute] + 1 <= value then
					PhaseToolkit.GeneralStat[attribute] = PhaseToolkit.GeneralStat[attribute] + 1
					sendAddonCmd("phase forge npc outfit custom " .. attribute .. " " .. PhaseToolkit.GeneralStat[attribute], nil, false)
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
--#region Map Icon
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
