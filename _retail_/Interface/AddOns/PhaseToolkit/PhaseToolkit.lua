--[[
Define the Addon NameSpace
--]]

local addonName, ns = ...
PhaseToolkit = {}



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
	GameTooltip:SetText(tooltip, 1, 1, 1)   -- Définit le texte du tooltip
	GameTooltip:Show()                      -- Affiche le tooltip
end

-- Fonction pour cacher le tooltip
function PhaseToolkit.HideTooltip()
	GameTooltip:Hide() -- Cache le tooltip
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

function PhaseToolkit.DisableSystemMessagesInChatFrame1()
	-- Désactiver les messages système dans la ChatFrame1 (fenêtre de chat principale)
	ChatFrame_RemoveMessageGroup(ChatFrame1, "SYSTEM")
end

function PhaseToolkit.EnableSystemMessagesInChatFrame1()
	-- Réactiver les messages système dans la ChatFrame1
	ChatFrame_AddMessageGroup(ChatFrame1, "SYSTEM")
end

function PhaseToolkit.CreateTempChatFrame()
	-- Créer une nouvelle fenêtre de chat temporaire
	tempChatFrame = FCF_OpenNewWindow("TempSystemMessages")

	-- Désactiver tous les autres types de messages sauf SYSTEM
	ChatFrame_RemoveAllMessageGroups(tempChatFrame)
	ChatFrame_AddMessageGroup(tempChatFrame, "SYSTEM")
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
		PhaseToolkit.showCustomButton:SetScript("OnEnter", function(self)
			PhaseToolkit.ShowTooltip(self, PhaseToolkit.CurrentLang["Show Custom Option"])
		end)

		PhaseToolkit.showCustomButton:SetScript("OnLeave", function(self)
			PhaseToolkit.HideTooltip()
		end)


		local AllRandomButton = CreateFrame("Button", nil, PhaseToolkit.CustomMainFrame, "UIPanelButtonTemplate")
		AllRandomButton:SetSize(25, 25)
		AllRandomButton:SetPoint("LEFT", PhaseToolkit.showCustomButton, "RIGHT", 5, 0)
		AllRandomButton.icon = AllRandomButton:CreateTexture(nil, "OVERLAY")
		AllRandomButton.icon:SetTexture("Interface\\Icons\\inv_misc_dice_01")
		AllRandomButton.icon:SetAllPoints()
		AllRandomButton:SetScript("OnClick", function()
			PhaseToolkit.RandomiseNpc()
		end)

		AllRandomButton:SetScript("OnEnter", function(self)
			PhaseToolkit.ShowTooltip(self, PhaseToolkit.CurrentLang["Randomise customisations"] or "Randomise customisations")
		end)

		AllRandomButton:SetScript("OnLeave", function(self)
			PhaseToolkit.HideTooltip()
		end)

		local SetNpcName = CreateFrame("Button", nil, PhaseToolkit.CustomMainFrame, "UIPanelButtonTemplate")
		SetNpcName:SetSize(25, 25)
		SetNpcName:SetPoint("LEFT", AllRandomButton, "RIGHT", 5, 0)
		SetNpcName.icon = SetNpcName:CreateTexture(nil, "OVERLAY")
		SetNpcName.icon:SetTexture("Interface\\Icons\\inv_inscriptionlanathelquill")
		SetNpcName.icon:SetAllPoints()
		SetNpcName:SetScript("OnClick", function()
			PhaseToolkit.PromptForNPCName()
		end)

		SetNpcName:SetScript("OnEnter", function(self)
			PhaseToolkit.ShowTooltip(self, PhaseToolkit.CurrentLang["Set NPC name"] or "Set NPC name")
		end)

		SetNpcName:SetScript("OnLeave", function(self)
			PhaseToolkit.HideTooltip()
		end)



		local SetNpcSubName = CreateFrame("Button", nil, PhaseToolkit.CustomMainFrame, "UIPanelButtonTemplate")
		SetNpcSubName:SetSize(25, 25)
		SetNpcSubName:SetPoint("LEFT", SetNpcName, "RIGHT", 5, 0)
		SetNpcSubName.icon = SetNpcSubName:CreateTexture(nil, "OVERLAY")
		SetNpcSubName.icon:SetTexture("Interface\\Icons\\inv_inscription_82_contract_ankoan")
		SetNpcSubName.icon:SetAllPoints()
		SetNpcSubName:SetScript("OnClick", function()
			PhaseToolkit.PromptForNPCSubName()
		end)

		SetNpcSubName:SetScript("OnEnter", function(self)
			PhaseToolkit.ShowTooltip(self, PhaseToolkit.CurrentLang["Set NPC Subname"] or "Set NPC Subname")
		end)

		SetNpcSubName:SetScript("OnLeave", function(self)
			PhaseToolkit.HideTooltip()
		end)
		PhaseToolkit.CustomMainFrame:Hide()
		PhaseToolkit.CustomMainFrame:Show()
	end
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
		PhaseToolkit.AdditionalButtonFrame:SetSize(145, 130)
		PhaseToolkit.AdditionalButtonFrame:SetPoint("TOP", PhaseToolkit.NPCCustomiserMainFrame, "TOP", 0, -30)
	else
		PhaseToolkit.AdditionalButtonFrame:SetSize(135, 130)
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

	local currentPage = 1
	local totalPages = 1

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
		PhaseToolkit.filteredTeleList = {}
		PhaseToolkit.PhaseNpcListSystemMessageCounter()
	end)


	ButtonToFetch:SetScript("OnEnter", function(self) PhaseToolkit.ShowTooltip(self, PhaseToolkit.CurrentLang["This can take a few seconds"] or "This can take a few seconds") end)
	ButtonToFetch:SetScript("OnLeave", PhaseToolkit.HideTooltip)


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

	local currentPage = 1
	local totalPages = 1

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
		PhaseToolkit.PhaseTeleListSystemMessageCounter()
	end)

	ButtonToFetch:SetScript("OnEnter", function(self) PhaseToolkit.ShowTooltip(self, PhaseToolkit.CurrentLang["This can take a few seconds"] or "This can take a few seconds") end)
	ButtonToFetch:SetScript("OnLeave", PhaseToolkit.HideTooltip)


	local ButtonToChangeNumberOfLine = CreateFrame("Button", nil, PhaseToolkit.TELEFrame, "UIPanelButtonTemplate")
	ButtonToChangeNumberOfLine:SetSize(15, 15)
	ButtonToChangeNumberOfLine:SetPoint("TOPLEFT", PhaseToolkit.TELEFrame, "TOPLEFT", 5, -5)
	ButtonToChangeNumberOfLine.icon = ButtonToChangeNumberOfLine:CreateTexture(nil, "OVERLAY")
	ButtonToChangeNumberOfLine.icon:SetTexture("Interface\\Icons\\trade_engineering")
	ButtonToChangeNumberOfLine.icon:SetAllPoints()
	ButtonToChangeNumberOfLine:SetScript("OnClick", PhaseToolkit.CreerFenetreLignesParPage)

	ButtonToChangeNumberOfLine:SetScript("OnEnter", function(self) PhaseToolkit.ShowTooltip(self, PhaseToolkit.CurrentLang["Change list size"] or "Change list size") end)
	ButtonToChangeNumberOfLine:SetScript("OnLeave", PhaseToolkit.HideTooltip)

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
