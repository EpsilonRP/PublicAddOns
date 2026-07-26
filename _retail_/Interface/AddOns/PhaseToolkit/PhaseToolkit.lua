--[[
Define the Addon NameSpace
--]]
---@diagnostic disable: codestyle-check
---@format disable

local addonName, ns = ...
local LibDeflate = LibStub:GetLibrary("LibDeflate");
local AceSerializer = LibStub:GetLibrary("AceSerializer-3.0");
PhaseToolkit = {}

--DATA STRUCTURE TIME
--[[
categoryLIST={

	{
		id=1, 						<= valorised by PTK_LAST_MAX_ID_CATEGORY_NPC + 1
		name="Category Name", 		<= user input
		members={1,2,3,4,5} 		<= list of creatureId for unique properties
	},
	{
		id=2,
		name="Category Name",
		members={1,2,3,4,5}
	},
	...
]]

PhaseToolkit.NPCcategoryList={}
PhaseToolkit.TELEcategoryList={}
PhaseToolkit.CopyNpcNameEnabled=false
PhaseToolkit.CopyNpcCustomisationEnabled=false
PhaseToolkit.CopyNpcGearEnabled=false
PhaseToolkit.CopyNpcWeaponsEnabled=false
PhaseToolkit.SelectedCategory=nil
PhaseToolkit.lastPhaseID=169
PhaseToolkit.deployingFrameBaseSize=300
PhaseToolkit.npcListView = PhaseToolkit.npcListView or {}
PhaseToolkit.CurrenttextToLookForNpc = PhaseToolkit.CurrenttextToLookForNpc or ""

local deployingFrameContext={
	["NPCFORGE"]={},
	["PHASEOPTION"]={},
	["NPCLIST"]={},
	["TELELIST"]={},
	["ITEMFORGE"]={},
	["NONE"]={id="NONE"},
}

PhaseToolkit.context=deployingFrameContext.NONE

function PhaseToolkit.SetDeployingContext(context)
	PhaseToolkit.context=context
end

function PhaseToolkit.GetDeployingContext()
	return PhaseToolkit.context
end

function PhaseToolkit.hideContext()
	for _,object in pairs(PhaseToolkit.context) do
		if object and object.Hide then
			object:Hide()
		end
	end
	PhaseToolkit.context = deployingFrameContext.NONE
end

local function hideContext(context)
	if context and #context>0 then
		for _,object in pairs(context) do
			if object and object.Hide then
				object:Hide()
			end
		end
	end
end

local function showContext(context)
	if context and #context>0 then
		for _,object in pairs(context) do
			if object and object.Show then
				if not object.isHiddenByDefault then
					object:Show()
				end
			end
		end
	end
end

function PhaseToolkit.changeContext(newcontext)
	PhaseToolkit.context = newcontext
	hideContext(PhaseToolkit.context)
	PhaseToolkit.DeployingFrame:handleDeployingFrameState()
end



function PhaseToolkit.extendDeployingFrame(newSize)
	if newSize and newSize > PhaseToolkit.deployingFrameBaseSize then
		PhaseToolkit.DeployingFrame:SetHeight(newSize)
	else
		PhaseToolkit.DeployingFrame:SetHeight(PhaseToolkit.deployingFrameBaseSize)
	end
end



local PTK_NPC_CATEGORY_LIST="PTK_NPC_CATEGORY_LIST";
local PTK_TELE_CATEGORY_LIST="PTK_TELE_CATEGORY_LIST";
local PTK_LAST_MAX_ID_CATEGORY_NPC="PTK_LAST_MAX_ID_CATEGORY";
local PTK_LAST_MAX_ID_CATEGORY_TELE="PTK_LAST_MAX_ID_CATEGORY_TELE";


function PhaseToolkit.CompressForUpload(categoryList)
	local compressedValue=""
	compressedValue = AceSerializer:Serialize(categoryList)
	compressedValue= LibDeflate:CompressDeflate(compressedValue, {level = 9})
	compressedValue = LibDeflate:EncodeForWoWChatChannel(compressedValue)
	return compressedValue;
end

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

local function checkIfCreatureInSelectedCategory(creature)
	if(creature) then
		if(PhaseToolkit.SelectedCategory) then
			for _, id in ipairs(PhaseToolkit.SelectedCategory.members) do
				if id == creature.IdCreature then
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

local function showContent(content)
	content = content or {}
	for _, frame in ipairs(content) do
		if frame and frame.Show then
			frame:Show()
		end
	end
end

local function hideContent(content)
	content = content or {}
	for _, frame in ipairs(content) do
		if frame and frame.Hide then
			frame:Hide()
		end
	end
end

function PhaseToolkit.getNpcCategoryFromPhaseData(funcToCall)
	EpsilonLib.PhaseAddonData.Get(PTK_NPC_CATEGORY_LIST, function(data)
		if data then
			local decoded = LibDeflate:DecodeForWoWChatChannel(data)
			if decoded then
				local decompressed = LibDeflate:DecompressDeflate(decoded)
				if decompressed then
					local success, result = AceSerializer:Deserialize(decompressed)
					if success then
						PhaseToolkit.NPCcategoryList = result
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
		funcToCall()
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


local function SetCroppedTextWithTooltip(ownerFrame, fontString, fullText, maxWidth)
    fullText = tostring(fullText or "")
    maxWidth = tonumber(maxWidth) or 0

    fontString:SetWordWrap(false)
    fontString:SetNonSpaceWrap(true)
    fontString:SetText(fullText)

    if maxWidth <= 0 or fontString:GetStringWidth() <= maxWidth then
        ownerFrame.fullText = nil
        return
    end

    local ellipsis = "..."
    local left, right = 0, #fullText
    local best = ellipsis

    while left <= right do
        local mid = math.floor((left + right) / 2)
        local candidate = string.sub(fullText, 1, mid) .. ellipsis
        fontString:SetText(candidate)

        if fontString:GetStringWidth() <= maxWidth then
            best = candidate
            left = mid + 1
        else
            right = mid - 1
        end
    end

    fontString:SetText(best)
    ownerFrame.fullText = fullText
end

local function isKeyInArray(array, key)
	for _, value in ipairs(array) do
		if value == key then
			return true
		end
	end
	return false
end

local function deleteKeyFromArray(array, key)
	for index, value in ipairs(array) do
		if value == key then
			table.remove(array, index)
		end
	end
	return array
end
--- Builds a command string for the item forge action.
--- @param action string The action to perform (e.g., class, bonding,name).
--- @param itemLinkList table<itemLink> The item link  list to be used in the command.
--- @param value? string The value associated with the action.
local function buildItemForgeCommand(action,itemLinkList,value)
	--itemLinkList can be empty if the action is create
	if not itemLinkList or (#itemLinkList ==0 and action~="create") or not action then
		print("Error, buildItemForgeCommand missing parameters " .. (not itemLinkList and "itemLink " or "").. (#itemLinkList == 0 and "itemLinkList is empty " or "") .. (not action and "action " or ""))
		return nil
	end

	local baseCommand = "f i s "
	value = value or ""

	return baseCommand .. action .. " " .. table.concat(itemLinkList, " ") .. " " .. value
end

--- take bool, return on or off
--- @param value boolean The boolean value to transform.
--- @return string Returns "on" if the value is true, "off" if the value is false.
local function transformBoolToOnOff(value)
	if value then
		return "on"
	else
		return "off"
	end
end

---comment send the command via SendChatMessage to go trough the limitation of  sendAddonCmd size limit
---@param message string The message to be sent in chunks.
local function sendItemDescriptionInChunk(message)
    local maxLength = 240 - (string.len("f i s de ") + string.len(PhaseToolkit.itemCreatorData.itemLink))
    local messageLength = #message

    -- Si le message tient dans un seul chunk, on l'envoie tel quel
    if messageLength <= maxLength then
        SendChatMessage("." .. message, "GUILD")
        return
    end

    local isFirst = true
    local currentChunk = ""

    for word in message:gmatch("%S+") do
        -- Cas limite : un mot seul dépasse déjà maxLength, on doit le forcer à passer
        if #word > maxLength then
            -- On envoie d'abord ce qu'on a accumulé
            if #currentChunk > 0 then
                SendChatMessage((isFirst and "." or "") .. currentChunk, "GUILD")
                isFirst = false
                currentChunk = ""
            end
            -- Puis on découpe le mot trop long brutalement (dernier recours)
            local pos = 1
            while pos <= #word do
                local piece = string.sub(word, pos, pos + maxLength - 1)
                SendChatMessage((isFirst and "." or "") .. piece, "GUILD")
                isFirst = false
                pos = pos + maxLength
            end
        else
            local candidate = (#currentChunk > 0) and (currentChunk .. " " .. word) or word

            if #candidate > maxLength then
                -- Le mot ne rentre pas dans le chunk courant : on envoie le chunk et on repart
                SendChatMessage((isFirst and "." or "") .. currentChunk, "GUILD")
                isFirst = false
                currentChunk = word
            else
                currentChunk = candidate
            end
        end
    end

    -- Envoyer ce qu'il reste
    if #currentChunk > 0 then
        SendChatMessage((isFirst and "." or "") .. currentChunk, "GUILD")
    end
end

-- ============================== GLOBAL VARIABLES ============================== --
PhaseToolkit.LargeurMax = 170
PhaseToolkit.HauteurMax = 220
PhaseToolkit.OpenedCustomFrame = nil
PhaseToolkit.SelectedRace = nil
PhaseToolkit.SelectedGender = "male"
PhaseToolkit.SelectedMeteo = { text = "Normal",           value = "normal" }
PhaseToolkit.IsPhaseWhitelist = nil
PhaseToolkit.MapIconInfo = {
	["MinimapButtonPos"] = {
		["minimapPos"] = 207
	},
}
PhaseToolkit.AutoRefreshNPC = false
PhaseToolkit.itemCreatorData={
	itemLink=nil,
	itemDisplaySourceLink = nil,
	itemAppearanceID= nil,
	selectedItemSubClass=nil,
	selectedInventoryType=nil,
	selectedItemClass=nil,
	selectedItemSheath=nil,
	selectedItemQuality=nil,
	selectedItemBonding=nil,
	itemName=nil,
	itemDescription=nil,
	selectedIcon=nil,
	characterWhitelist = {},
	phaseWhitelistForMember = {},
	phaseWhitelistForOfficer = {},
	itemProperty={
		["adder"]=false,
		["additem"]={
			["anyone"]=false,
			["character"]=false,
			["member"]=false,
			["officer"]=false
		},
		["copy"]=false,
		["creator"]=false,
		["info"]=false,
		["lookup"]=false
	}
}

PhaseToolkit.itemCreatorData.selectedRows = {}


PhaseToolkit.CommandToSend={}
PhaseToolkit.CustomFieldLocks={}

PhaseToolkit.additemOption={
	{text="Anyone",value=false},
	{text="Character",value=false},
	{text="Member",value=false},
	{text="Officer",value=false},
}
PhaseToolkit.currentWhitelistType=""

PhaseToolkit.ModifyItemData=false
PhaseToolkit.npcCurrentPage=nil

-- Variables pour sauvegarder la taille des frames
PhaseToolkit.TELEFrameWidth=nil
PhaseToolkit.TELEFrameHeight=nil

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

local raceGenderCategory = {
    ["Human"] = {
        ["MALE"] = {
            ["CATEGORY"] = {
                ["Head"] = {
                    "Skin Color",
                    "Face",
                    "Face Shape",
                    "Eye Type",
                    "Eye Color",
                    "Secondary Eye Color",
                    "Ears"
                },
                ["Hair"] = {
                    "Hair Style",
                    "Hair Color",
                    "Eyebrows",
                    "Stubble",
                    "Mustache",
                    "Sideburns",
                    "Beard"
                },
                ["Jewelry"] = {
                    "Necklace",
                    "Earrings",
                    "Piercings",
                    "Jewelry Color",
                    "Gem Color"
                },
                ["BodyMark"] = {
                    "Scars",
                    "Complexion"
                }
            }
        },
        ["FEMALE"] = {
            ["CATEGORY"] = {
                ["Head"] = {
                    "Skin Color",
                    "Face",
                    "Face Shape",
                    "Eye Type",
                    "Eye Color",
                    "Secondary Eye Color",
                    "Ears"
                },
                ["Hair"] = {
                    "Hair Style",
                    "Hair Color",
                    "Eyebrows"
                },
                ["Jewelry"] = {
                    "Necklace",
                    "Earrings",
                    "Piercings",
                    "Jewelry Color",
                    "Gem Color"
                },
                ["BodyMark"] = {
                    "Complexion",
                    "Makeup",
                    "Scars"
                }
            }
        }
    },
    ["Orc"] = {
        ["MALE"] = {
            ["CATEGORY"] = {
                ["Head"] = {
                    "Skin Color",
                    "Face",
                    "Face Shape",
                    "Eye Type",
                    "Eye Color",
                    "Secondary Eye Color",
                    "Tusks",
                    "Ears"
                },
                ["Hair"] = {
                    "Hair Style",
                    "Hair Color",
                    "Eyebrows",
                    "Stubble",
                    "Mustache",
                    "Sideburns",
                    "Beard"
                },
                ["Jewelry"] = {
                    "Necklace",
                    "Earrings",
                    "Piercings"
                },
                ["Body"] = {
                    "Body",
                    "Hand (Left)",
                    "Hand (Right)",
                    "Posture"
                },
                ["BodyMark"] = {
                    "Grime",
                    "Scars",
                    "Face Tattoo",
                    "Body Tattoo",
                    "Tattoo Color"
                }
            }
        },
        ["FEMALE"] = {
            ["CATEGORY"] = {
                ["Head"] = {
                    "Skin Color",
                    "Face",
                    "Face Shape",
                    "Eye Type",
                    "Eye Color",
                    "Secondary Eye Color",
                    "Ears"
                },
                ["Hair"] = {
                    "Hair Style",
                    "Hair Color"
                },
                ["Jewelry"] = {
                    "Necklace",
                    "Earrings",
                    "Piercings"
                },
                ["Body"] = {
                    "Body",
                    "Hand (Left)",
                    "Hand (Right)"
                },
                ["BodyMark"] = {
                    "Scars",
                    "Face Tattoo",
                    "Body Tattoo",
                    "Tattoo Color"
                }
            }
        }
    },
    ["Dwarf"] = {
        ["MALE"] = {
            ["CATEGORY"] = {
                ["Head"] = {
                    "Skin Color",
                    "Face",
                    "Face Shape",
                    "Eye Type",
                    "Eye Color",
                    "Secondary Eye Color"
                },
                ["Hair"] = {
                    "Hair Style",
                    "Hair Color",
                    "Eyebrows",
                    "Mustache",
                    "Beard"
                },
                ["Jewelry"] = {
                    "Feather",
                    "Earrings",
                    "Piercings",
                    "Hand Jewelry",
                    "Jewelry Color",
                    "Feather Color"
                },
                ["Body"] = {
                    "Body Shape"
                },
                ["BodyMark"] = {
                    "Garment",
                    "Face Tattoo",
                    "Body Tattoo",
                    "Tattoo Color"
                }
            }
        },
        ["FEMALE"] = {
            ["CATEGORY"] = {
                ["Head"] = {
                    "Skin Color",
                    "Face",
                    "Eye Type",
                    "Eye Color",
                    "Secondary Eye Color"
                },
                ["Hair"] = {
                    "Hair Style",
                    "Hair Color",
                    "Eyebrows"
                },
                ["Jewelry"] = {
                    "Feather",
                    "Earrings",
                    "Piercings",
                    "Jewelry Color",
                    "Feather Color"
                },
                ["BodyMark"] = {
                    "Garment",
                    "Face Tattoo",
                    "Body Tattoo",
                    "Tattoo Color"
                }
            }
        }
    },
    ["NightElf"] = {
        ["MALE"] = {
            ["CATEGORY"] = {
                ["Head"] = {
                    "Skin Color",
                    "Face",
                    "Face Shape",
                    "Eye Type",
                    "Eye Color",
                    "Secondary Eye Color",
                    "Ears"
                },
                ["Hair"] = {
                    "Hair Style",
                    "Hair Color",
                    "Eyebrows",
                    "Mustache",
                    "Sideburns",
                    "Beard",
                    "Vines",
                    "Vine Color"
                },
                ["Jewelry"] = {
                    "Horns",
                    "Blindfold",
                    "Headdress",
                    "Earrings",
                    "Necklace",
                    "Jewelry Color",
                    "Gem Color"
                },
                ["Body"] = {
                    "Body Shape",
                    "Body Type",
                    "Fur Color"
                },
                ["BodyMark"] = {
                    "Scars",
                    "Face Tattoo",
                    "Body Tattoo",
                    "Tattoo Color",
                    "Runes",
                    "Runes Color"
                }
            }
        },
        ["FEMALE"] = {
            ["CATEGORY"] = {
                ["Head"] = {
                    "Skin Color",
                    "Face",
                    "Face Shape",
                    "Eye Type",
                    "Eye Color",
                    "Secondary Eye Color",
                    "Ears"
                },
                ["Hair"] = {
                    "Hair Style",
                    "Hair Color",
                    "Eyebrows",
                    "Vines",
                    "Vine Color"
                },
                ["Jewelry"] = {
                    "Horns",
                    "Blindfold",
                    "Headdress",
                    "Necklace",
                    "Earrings",
                    "Piercings",
                    "Jewelry Color",
                    "Gem Color"
                },
                ["Body"] = {
                    "Body Type",
                    "Fur Color"
                },
                ["BodyMark"] = {
                    "Scars",
                    "Face Tattoo",
                    "Body Tattoo",
                    "Tattoo Color",
                    "Runes",
                    "Runes Color"
                }
            }
        }
    },
    ["Undead"] = {
        ["MALE"] = {
            ["CATEGORY"] = {
                ["Head"] = {
                    "Skin Color",
                    "Face",
                    "Face Type",
                    "Eye Type",
                    "Eye Color",
                    "Secondary Eye Color",
                    "Ears"
                },
                ["Hair"] = {
                    "Hair Style",
                    "Hair Color",
                    "Hair Gradient",
                    "Eyebrows",
                    "Mustache",
                    "Sideburns",
                    "Beard"
                },
                ["Jewelry"] = {
                    "Face Features"
                },
                ["Body"] = {
                    "Skin Type",
                    "Spine",
                    "Ribs",
                    "Arm (Left)",
                    "Arm (Right)",
                    "Leg (Left)",
                    "Leg (Right)"
                }
            }
        },
        ["FEMALE"] = {
            ["CATEGORY"] = {
                ["Head"] = {
                    "Skin Color",
                    "Face",
                    "Face Type",
                    "Eye Type",
                    "Eye Color",
                    "Secondary Eye Color",
                    "Ears"
                },
                ["Hair"] = {
                    "Hair Style",
                    "Hair Color",
                    "Hair Gradient"
                },
                ["Jewelry"] = {
                    "Face Features",
                    "Necklace",
                    "Earrings",
                    "Piercings"
                },
                ["Body"] = {
                    "Skin Type",
                    "Spine",
                    "Hips",
                    "Arm (Left)",
                    "Arm (Right)",
                    "Leg (Left)",
                    "Leg (Right)"
                }
            }
        }
    },
    ["Tauren"] = {
        ["MALE"] = {
            ["CATEGORY"] = {
                ["Head"] = {
                    "Skin Color",
                    "Face",
                    "Eye Type",
                    "Eye Color",
                    "Secondary Eye Color",
                    "Horn Style",
                    "Horn Color",
                    "Horn Decoration",
                    "Grime",
                    "Scars"
                },
                ["Hair"] = {
                    "Mane",
                    "Foremane",
                    "Hair",
                    "Sideburns",
                    "Goatee",
                    "Beard"
                },
                ["Jewelry"] = {
                    "Headdress",
                    "Necklace",
                    "Earrings",
                    "Nose Ring",
                    "Jewelry Color",
                    "Accent Color",
                    "Gem Color",
                    "Flower"
                },
                ["Body"] = {
                    "Tail",
                    "Tail Decoration"
                },
                ["BodyMark"] = {
                    "Horn Markings",
                    "Face Paint",
                    "Body Paint",
                    "Paint Color"
                }
            }
        },
        ["FEMALE"] = {
            ["CATEGORY"] = {
                ["Head"] = {
                    "Skin Color",
                    "Face",
                    "Eye Type",
                    "Eye Color",
                    "Secondary Eye Color",
                    "Horn Style",
                    "Horn Color",
                    "Grime",
                    "Scars"
                },
                ["Hair"] = {
                    "Mane",
                    "Foremane",
                    "Hair",
                    "Hair Decoration"
                },
                ["Jewelry"] = {
                    "Headdress",
                    "Necklace",
                    "Earrings",
                    "Nose Ring",
                    "Jewelry Color",
                    "Accent Color",
                    "Gem Color",
                    "Flower"
                },
                ["Body"] = {
                    "Tail",
                    "Tail Decoration"
                },
                ["BodyMark"] = {
                    "Horn Markings",
                    "Face Paint",
                    "Body Paint",
                    "Paint Color"
                }
            }
        }
    },
    ["Gnome"] = {
        ["MALE"] = {
            ["CATEGORY"] = {
                ["Head"] = {
                    "Skin Color",
                    "Face",
                    "Eye Type",
                    "Eye Color",
                    "Secondary Eye Color",
                    "Ears",
                    "Scars"
                },
                ["Hair"] = {
                    "Hair Style",
                    "Hair Color",
                    "Hair Streaks",
                    "Hair Gradient",
                    "Eyebrows",
                    "Mustache",
                    "Sideburns",
                    "Beard"
                },
                ["Jewelry"] = {
                    "Goggles",
                    "Earrings",
                    "Piercings",
                    "Wrist Jewelry",
                    "Jewelry Color",
                    "Accent Color"
                }
            }
        },
        ["FEMALE"] = {
            ["CATEGORY"] = {
                ["Head"] = {
                    "Skin Color",
                    "Face",
                    "Eye Type",
                    "Eye Color",
                    "Secondary Eye Color",
                    "Scars",
                    "Ears"
                },
                ["Hair"] = {
                    "Hair Style",
                    "Hair Color",
                    "Hair Streaks",
                    "Hair Gradient",
                    "Eyebrows",
                    "Hair Accessory"
                },
                ["Jewelry"] = {
                    "Goggles",
                    "Earrings",
                    "Piercings",
                    "Wrist Jewelry",
                    "Jewelry Color",
                    "Accent Color"
                }
            }
        }
    },
    ["Troll"] = {
        ["MALE"] = {
            ["CATEGORY"] = {
                ["Head"] = {
                    "Skin Color",
                    "Face",
                    "Eye Type",
                    "Eye Color",
                    "Secondary Eye Color",
                    "Tusks",
                    "Tusk Decoration",
                    "Eyebrows"
                },
                ["Hair"] = {
                    "Hair Style",
                    "Hair Color",
                    "Hair Highlight",
                    "Hair Gradient",
                    "Mustache",
                    "Sideburns",
                    "Beard"
                },
                ["Jewelry"] = {
                    "Necklace",
                    "Earrings",
                    "Nose Piercing",
                    "Mouth Piercing"
                },
                ["Body"] = {
                    "Arm (Left)",
                    "Arm (Right)",
                    "Leg (Right)",
                    "Leg (Left)",
                    "Jewelry Color",
                    "Accent Color"
                },
                ["BodyMark"] = {
                    "Bandages",
                    "Tattoo Style",
                    "Face Tattoo",
                    "Body Tattoo",
                    "Tattoo Color"
                }
            }
        },
        ["FEMALE"] = {
            ["CATEGORY"] = {
                ["Head"] = {
                    "Skin Color",
                    "Face",
                    "Eye Type",
                    "Eye Color",
                    "Secondary Eye Color",
                    "Tusks"
                },
                ["Hair"] = {
                    "Hair Style",
                    "Hair Color",
                    "Hair Highlight",
                    "Hair Gradient"
                },
                ["Jewelry"] = {
                    "Headdress",
                    "Necklace",
                    "Earrings",
                    "Brow Piercing",
                    "Nose Piercing",
                    "Mouth Piercing"
                },
                ["Body"] = {
                    "Arm (Left)",
                    "Arm (Right)",
                    "Leg (Left)",
                    "Leg (Right)",
                    "Jewelry Color",
                    "Accent Color"
                },
                ["BodyMark"] = {
                    "Bandages",
                    "Tattoo Style",
                    "Face Tattoo",
                    "Body Tattoo",
                    "Tattoo Color"
                }
            }
        }
    },
    ["Goblin"] = {
        ["MALE"] = {
            ["CATEGORY"] = {
                ["Head"] = {
                    "Skin Color",
                    "Face",
                    "Face Markings",
                    "Nose",
                    "Chin",
                    "Eye Type",
                    "Eye Color",
                    "Secondary Eye Color",
                    "Ears",
                    "Grime",
                    "Stubble"
                },
                ["Hair"] = {
                    "Hair Style",
                    "Hair Color",
                    "Hair Gradient",
                    "Hair Streaks",
                    "Eyebrows",
                    "Mustache",
                    "Sideburns",
                    "Beard"
                },
                ["Jewelry"] = {
                    "Earrings",
                    "Nose Ring",
                    "Jewelry Color",
                    "Leg Jewelry",
                    "Wrist Jewelry",
                    "Necklace"
                },
                ["Body"]={
                    "Body Type"
                }
            }
        },
        ["FEMALE"] = {
            ["CATEGORY"] = {
                ["Head"] = {
                    "Skin Color",
                    "Face",
                    "Face Markings",
                    "Nose",
                    "Chin",
                    "Eye Type",
                    "Eye Color",
                    "Secondary Eye Color",
                    "Ears",
                    "Grime"
                },
                ["Hair"] = {
                    "Hair Style",
                    "Hair Color",
                    "Hair Gradient",
                    "Hair Streaks",
                    "Eyebrows"
                },
                ["Jewelry"] = {
                    "Necklace",
                    "Earrings",
                    "Nose Ring",
                    "Jewelry Color",
                    "Wrist Jewelry",
                    "Leg Jewelry",

                },
                ["Body"] = {
                    "Body Shape",
                    "Body Type"
                }
            }
        }
    },
    ["BloodElf"] = {
        ["MALE"] = {
            ["CATEGORY"] = {
                ["Head"] = {
                    "Skin Color",
                    "Face",
                    "Face Shape",
                    "Eye Type",
                    "Eye Color",
                    "Secondary Eye Color",
                    "Ears"
                },
                ["Hair"] = {
                    "Hair Style",
                    "Hair Color",
                    "Hair Gradient",
                    "Eyebrows",
                    "Mustache",
                    "Sideburns",
                    "Beard",
                    "Stubble"
                },
                ["Jewelry"] = {
                    "Horns",
                    "Blindfold",
                    "Headdress",
                    "Earrings",
                    "Jewelry Color",
                    "Accent Color",
                    "Gem Color"
                },
                ["BodyMark"] = {
                    "Face Tattoo",
                    "Body Tattoo",
                    "Tattoo Color",
                    "Runes",
                    "Rune Color"
                }
            }
        },
        ["FEMALE"] = {
            ["CATEGORY"] = {
                ["Head"] = {
                    "Skin Color",
                    "Face",
                    "Face Shape",
                    "Eye Type",
                    "Eye Color",
                    "Secondary Eye Color",
                    "Ears"
                },
                ["Hair"] = {
                    "Hair Style",
                    "Hair Color",
                    "Hair Gradient"
                },
                ["Jewelry"] = {
                    "Horns",
                    "Blindfold",
                    "Headdress",
                    "Necklace",
                    "Earrings",
                    "Jewelry Color",
                    "Accent Color",
                    "Gem Color"
                },
                ["Body"] = {
                    "Armbands",
                    "Bracelets"
                },
                ["BodyMark"] = {
                    "Body Tattoo",
                    "Tattoo Color",
                    "Runes",
                    "Runes Color"
                }
            }
        }
    },
    ["Draenei"] = {
        ["MALE"] = {
            ["CATEGORY"] = {
                ["Head"] = {
                    "Skin Color",
                    "Face",
                    "Face Shape",
                    "Eye Type",
                    "Eye Color",
                    "Secondary Eye Color",
                    "Tendrils"
                },
                ["Hair"] = {
                    "Hair Style",
                    "Hair Color",
                    "Eyebrows",
                    "Stubble",
                    "Mustache",
                    "Sideburns",
                    "Beard"
                },
                ["Jewelry"] = {
                    "Horns",
                    "Horn Decoration",
                    "Headdress",
                    "Necklace",
                    "Earrings",
                    "Jewelry Color",
                    "Gem Color"
                },
                ["Body"] = {
                    "Body Shape",
                    "Tail",
                    "Trims"
                }
            }
        },
        ["FEMALE"] = {
            ["CATEGORY"] = {
                ["Head"] = {
                    "Skin Color",
                    "Face",
                    "Eye Type",
                    "Eye Color",
                    "Secondary Eye Color",
                    "Tendrils",
                    "Face Tendrils"
                },
                ["Hair"] = {
                    "Hair Style",
                    "Hair Color",
                    "Headdress",
                    "Hair Decoration"
                },
                ["Jewelry"] = {
                    "Horns",
                    "Horn Accessories",
                    "Necklace",
                    "Earrings",
                    "Jewelry Color",
                    "Gem Color"
                },
                ["Body"] = {
                    "Tail",
                    "Trims"
                }
            }
        }
    },
    ["Worgen"] = {
        ["MALE"] = {
            ["CATEGORY"] = {
                ["Head"] = {
                    "Fur Color",
                    "Face",
                    "Face Shape",
                    "Eye Type",
                    "Eye Color",
                    "Secondary Eye Color",
                    "Ear Style",
                    "Secondary Ear Style",
                    "Fangs"
                },
                ["Hair"] = {
                    "Hair Style",
                    "Mane",
                    "Foremane",
                    "Sideburns",
                    "Beard"
                },
                ["Body"] = {
                    "Body Fur",
                    "Claws",
                    "Tail"
                }
            }
        },
        ["FEMALE"] = {
            ["CATEGORY"] = {
                ["Head"] = {
                    "Fur Color",
                    "Face",
                    "Face Shape",
                    "Eye Type",
                    "Eye Color",
                    "Secondary Eye Color",
                    "Ear Style",
                    "Secondary Ear Style",
                    "Fangs"
                },
                ["Hair"] = {
                    "Hair Style",
                    "Hair Accents",
                    "Mane",
                    "Foremane"
                },
                ["Body"] = {
                    "Body Fur",
                    "Claws",
                    "Tail"
                }
            }
        }
    },
    ["Pandaren"] = {
        ["MALE"] = {
            ["CATEGORY"] = {
                ["Head"] = {
                    "Skin Color",
                    "Face",
                    "Eye Type",
                    "Eye Color",
                    "Secondary Eye Color"
                },
                ["Hair"] = {
                    "Hair Style",
                    "Accent Color",
                    "Eyebrows",
                    "Mustache",
                    "Beard",
                    "Sideburns"
                }
            }
        },
        ["FEMALE"] = {
            ["CATEGORY"] = {
                ["Head"] = {
                    "Skin Color",
                    "Face",
                    "Eye Type",
                    "Eye Color",
                    "Secondary Eye Color",
                    "Earrings"
                },
                ["Hair"] = {
                    "Hair Style",
                    "Accent Color",
                    "Hair Color"
                },
                ["Body"] = {
                    "Tail"
                }
            }
        }
    },
    ["Nightborne"] = {
        ["MALE"] = {
            ["CATEGORY"] = {
                ["Head"] = {
                    "Skin Color",
                    "Face",
                    "Eye Shape",
                    "Eye Type",
                    "Eye Color",
                    "Secondary Eye Color"
                },
                ["Hair"] = {
                    "Hair Style",
                    "Hair Color",
                    "Eyebrows",
                    "Mustache",
                    "Beard"
                },
                ["Jewelry"] = {
                    "Headdress",
                    "Earrings",
                    "Face Jewelry",
                    "Jaw Jewelry",
                    "Chin Jewelry",
                    "Jewelry Color"
                },
                ["BodyMark"] = {
                    "Face Tattoo",
                    "Body Tattoo",
                    "Luminous Hands"
                }
            }
        },
        ["FEMALE"] = {
            ["CATEGORY"] = {
                ["Head"] = {
                    "Skin Color",
                    "Face",
                    "Eye Shape",
                    "Eye Type",
                    "Eye Color",
                    "Secondary Eye Color"
                },
                ["Hair"] = {
                    "Hair Style",
                    "Hair Color",
                    "Eyebrows",
                    "Hair Decoration"
                },
                ["Jewelry"] = {
                    "Headdress",
                    "Necklace",
                    "Earrings",
                    "Face Jewelry",
                    "Jaw Jewelry",
                    "Chin Jewelry",
                    "Jewelry Color"
                },
                ["BodyMark"] = {
                    "Face Tattoo",
                    "Body Tattoo",
                    "Luminous Hands"
                }
            }
        }
    },
    ["Highmountain"] = {
        ["MALE"] = {
            ["CATEGORY"] = {
                ["Head"] = {
                    "Skin Color",
                    "Face",
                    "Eye Type",
                    "Eye Color",
                    "Secondary Eye Color",
                    "Horn Style",
                    "Horn Color",
                    "Horn Wraps",
                    "Horn Decoration",
                    "Horn Markings"
                },
                ["Hair"] = {
                    "Foremane",
                    "Hair",
                    "Beard"
                },
                ["Jewelry"] = {
                    "Headdress",
                    "Nose Piercing",
                    "Feather"
                },
                ["Body"] = {
                    "Tail",
                    "Tail Decoration"
                },
                ["BodyMark"] = {
                    "Face Paint",
                    "Body Paint",
                    "Body Paint Color"
                }
            }
        },
        ["FEMALE"] = {
            ["CATEGORY"] = {
                ["Head"] = {
                    "Skin Color",
                    "Face",
                    "Eye Type",
                    "Eye Color",
                    "Secondary Eye Color",
                    "Horn Style",
                    "Horn Color",
                    "Horn Wraps",
                    "Horn Decoration",
                    "Horn Markings"
                },
                ["Hair"] = {
                    "Foremane",
                    "Hair",
                    "Hair Decoration"
                },
                ["Jewelry"] = {
                    "Headdress",
                    "Necklace",
                    "Earrings",
                    "Nose Piercing",
                    "Feather"
                },
                ["Body"] = {
                    "Tail",
                    "Tail Decoration"
                },
                ["BodyMark"] = {
                    "Body Paint",
                    "Face Paint",
                    "Body Paint Color"
                }
            }
        }
    },
    ["VoidElf"] = {
        ["MALE"] = {
            ["CATEGORY"] = {
                ["Head"] = {
                    "Skin Color",
                    "Face",
                    "Eye Type",
                    "Eye Color",
                    "Secondary Eye Color",
                    "Ears",
                    "Tentacles"
                },
                ["Hair"] = {
                    "Hair Style",
                    "Hair Color",
                    "Stubble",
                    "Facial Hair"
                },
                ["BodyMark"] = {
                    "Face Markings",
                    "Body Markings"
                }
            }
        },
        ["FEMALE"] = {
            ["CATEGORY"] = {
                ["Head"] = {
                    "Skin Color",
                    "Face",
                    "Eye Type",
                    "Eye Color",
                    "Secondary Eye Color",
                    "Ears",
                    "Tentacles"
                },
                ["Hair"] = {
                    "Hair Style",
                    "Hair Color"
                },
                ["Jewelry"] = {
                    "Earrings"
                },
                ["BodyMark"] = {
                    "Face Markings",
                    "Body Markings"
                }
            }
        }
    },
    ["Lightforged"] = {
        ["MALE"] = {
            ["CATEGORY"] = {
                ["Head"] = {
                    "Skin Color",
                    "Face",
                    "Eye Color",
                    "Secondary Eye Color",
                    "Eye Type",
                    "Tendrils"
                },
                ["Hair"] = {
                    "Hair Style",
                    "Hair Color",
                    "Hair Decoration",
                    "Eyebrows",
                    "Facial Hair"
                },
                ["Jewelry"] = {
                    "Jewelry Color"
                },
                ["BodyMark"] = {
                    "Face Rune",
                    "Body Rune",
                    "Horn Decoration",
                    "Tail"
                }
            }
        },
        ["FEMALE"] = {
            ["CATEGORY"] = {
                ["Head"] = {
                    "Skin Color",
                    "Face",
                    "Eye Color",
                    "Secondary Eye Color",
                    "Eye Type",
                    "Tendrils"
                },
                ["Hair"] = {
                    "Hair Style",
                    "Hair Color",
                    "Hair Decoration",
                    "Headdress"
                },
                ["Jewelry"] = {
                    "Horns",
                    "Horn Decoration",
                    "Necklace",
                    "Earrings",
                    "Jaw Decoration",
                    "Jewelry Color"
                },
                ["BodyMark"] = {
                    "Face Rune",
                    "Body Rune",
                    "Tail"
                }
            }
        }
    },
    ["Zandalari"] = {
        ["MALE"] = {
            ["CATEGORY"] = {
                ["Head"] = {
                    "Skin Color",
                    "Face",
                    "Eye Type",
                    "Eye Color",
                    "Secondary Eye Color",
                    "Tusks",
                    "Bandages",
                    "Eyebrows",
                    "Face Tattoo"
                },
                ["Hair"] = {
                    "Hair Style",
                    "Hair Color",
                    "Hair Gradient",
                    "Hair Highlight",
                    "Accent Color",
                    "Beard",
                    "Sideburns",
                    "Mustache",
                },
                ["Jewelry"] = {
                    "Jewelry Color",
                    "Ear Gauge",
                    "Piercings"
                },
                ["BodyMark"] = {
                    "Tattoo",
                    "Tattoo Style",
                    "Tattoo Color"
                }
            }
        },
        ["FEMALE"] = {
            ["CATEGORY"] = {
                ["Head"] = {
                    "Skin Color",
                    "Face",
                    "Eye Type",
                    "Eye Color",
                    "Secondary Eye Color",
                    "Tusks",
                    "Bandages",
                    "Face Tattoo"
                },
                ["Hair"] = {
                    "Hair Style",
                    "Hair Color",
                    "Hair Gradient",
                    "Hair Highlight",
                    "Accent Color",
                },
                ["Jewelry"] = {
                    "Jewelry Color",
                    "Necklace",
                    "Earrings",
                    "Ear Gauge",
                    "Piercings"
                },
                ["BodyMark"] = {
                    "Body Tattoo",
                    "Tattoo",
                    "Tattoo Style",
                    "Tattoo Color"
                }
            }
        }
    },
    ["Kul tiran"] = {
        ["MALE"] = {
            ["CATEGORY"] = {
                ["Head"] = {
                    "Skin Color",
                    "Face",
                    "Eye Type",
                    "Eye Color",
                    "Eyebrows",
                    "Secondary Eye Color",
                    "Ears"
                },
                ["Hair"] = {
                    "Hair Style",
                    "Hair Color",
                    "Mustache",
                    "Sideburns",
                    "Beard",
                    "Stubble"
                },
                ["BodyMark"] = {
                    "Body Tattoo",
                    "Tattoo Color"
                }
            }
        },
        ["FEMALE"] = {
            ["CATEGORY"] = {
                ["Head"] = {
                    "Skin Color",
                    "Face",
                    "Eye Type",
                    "Eye Color",
                    "Secondary Eye Color",
                    "Ears"
                },
                ["Hair"] = {
                    "Hair Style",
                    "Hair Color",
                    "Eyebrows"
                },
                ["Jewelry"] = {
                    "Necklace",
                    "Earrings"
                },
                ["BodyMark"] = {
                    "Body Tattoo",
                    "Tattoo Color"
                }
            }
        }
    },
    ["DarkIron"] = {
        ["MALE"] = {
            ["CATEGORY"] = {
                ["Head"] = {
                    "Skin Color",
                    "Eye Color",
                    "Eye Type",
                    "Secondary Eye Color",
                    "Face"
                },
                ["Hair"] = {
                    "Hair Style",
                    "Hair Color",
                    "Facial Hair"
                },
                ["Jewelry"] = {
                    "Piercings"
                },
                ["BodyMark"] = {
                    "Tattoo"
                }
            }
        },
        ["FEMALE"] = {
            ["CATEGORY"] = {
                ["Head"] = {
                    "Skin Color",
                    "Eye Color",
                    "Eye Type",
                    "Secondary Eye Color",
                    "Face"
                },
                ["Hair"] = {
                    "Hair Style",
                    "Hair Color"
                },
                ["Jewelry"] = {
                    "Piercings"
                },
                ["BodyMark"] = {
                    "Tattoo"
                }
            }
        }
    },
    ["Vulpera"] = {
        ["MALE"] = {
            ["CATEGORY"] = {
                ["Head"] = {
                    "Fur Color",
                    "Face",
                    "Eye Type",
                    "Eye Color",
                    "Secondary Eye Color",
                    "Ears",
                    "Snout"
                },
                ["Jewelry"] = {
                    "Earrings"
                },
                ["BodyMark"] = {
                    "Pattern",
                    "Pattern Color"
                }
            }
        },
        ["FEMALE"] = {
            ["CATEGORY"] = {
                ["Head"] = {
                    "Fur Color",
                    "Face",
                    "Eye Type",
                    "Eye Color",
                    "Secondary Eye Color",
                    "Ears",
                    "Snout"
                },
                ["Jewelry"] = {
                    "Earrings"
                },
                ["BodyMark"] = {
                    "Pattern",
                    "Pattern Color"
                }
            }
        }
    },
    ["Mag'har"] = {
        ["MALE"] = {
            ["CATEGORY"] = {
                ["Head"] = {
                    "Skin Color",
                    "Face",
                    "Face Shape",
                    "Eye Color",
                    "Secondary Eye Color",
                    "Tusks"
                },
                ["Hair"] = {
                    "Hair Style",
                    "Hair Color",
                    "Eyebrows",
                    "Mustache",
                    "Sideburns",
                    "Beard"
                },
                ["Jewelry"] = {
                    "Necklace",
                    "Earrings",
                    "Piercings"
                },
                ["Body"] = {
                    "Body Piercings",
                    "Hand (Left)",
                    "Hand (Right)",
                    "Posture"
                },
                ["BodyMark"] = {
                    "Grime",
                    "Scars",
                    "Face Tattoo",
                    "Body Tattoo",
                    "Tattoo Color"
                }
            }
        },
        ["FEMALE"] = {
            ["CATEGORY"] = {
                ["Head"] = {
                    "Skin Color",
                    "Face",
                    "Face Shape",
                    "Eye Color",
                    "Secondary Eye Color"
                },
                ["Hair"] = {
                    "Hair Style",
                    "Hair Color"
                },
                ["Jewelry"] = {
                    "Necklace",
                    "Earrings",
                    "Piercings"
                },
                ["Body"] = {
                    "Body Piercings",
                    "Hand (Left)",
                    "Hand (Right)"
                },
                ["BodyMark"] = {
                    "Face Tattoo",
                    "Body Tattoo",
                    "Tattoo Color"
                }
            }
        }
    },
    ["Mechagnome"] = {
        ["MALE"] = {
            ["CATEGORY"] = {
                ["Head"] = {
                    "Skin Color",
                    "Face",
                    "Eye Color",
                    "Secondary Eye Color",
                    "Scars"
                },
                ["Hair"] = {
                    "Hair Style",
                    "Hair Color",
                    "Hair Streaks",
                    "Hair Gradient",
                    "Eyebrows",
                    "Mustache",
                    "Sideburns",
                    "Beard"
                },
                ["Jewelry"] = {
                    "Face Modification",
                    "Ear Modification",
                    "Chin Modification",
                    "Chest Modification",
                    "Optics"
                },
                ["Body"] = {
                    "Arm (Left)",
                    "Arm (Right)",
                    "Leg (Left)",
                    "Leg (Right)",
                    "Paint Color"
                }
            },
        },
        ["FEMALE"] = {
            ["CATEGORY"] = {
                ["Head"] = {
                    "Skin Color",
                    "Face",
                    "Eye Color",
                    "Secondary Eye Color",
                    "Scars"
                },
                ["Hair"] = {
                    "Hair Style",
                    "Hair Color",
                    "Hair Streaks",
                    "Hair Gradient",
                    "Eyebrows"
                },
                ["Jewelry"] = {
                    "Face Modification",
                    "Ear Modification",
                    "Chin Modification",
                    "Chest Modification",
                    "Optics"
                },
                ["Body"] = {
                    "Arm (Left)",
                    "Arm (Right)",
                    "Leg (Left)",
                    "Leg (Right)",
                    "Paint Color"
                }
            }
        }
    },

    ["Naga"] = {
        ["MALE"] = {
            ["CATEGORY"] = {
                ["Head"] = {
                    "Skin Color"
                }
            }
        },
        ["FEMALE"] = {
            ["CATEGORY"] = {
                ["Head"] = {
                    "Skin Color"
                }
            }
        }
    },
    ["Thin Human"] = {
        ["MALE"] = {
            ["CATEGORY"] = {
                ["Head"] = {
                    "Hairstyle",
                    "Facialhair",
                    "Haircolor",
                    "Skincolor"
                }
            }
        },
        ["FEMALE"] = {
            ["CATEGORY"] = {
                ["Head"] = {
                }
            }
        }
    },

    ["Fel Orc"] = {
        ["MALE"] = {
            ["CATEGORY"] = {
                ["Head"] = {
                    "Skincolor"
                }
            }
        },
        ["FEMALE"] = {
            ["CATEGORY"] = {
                ["Head"] = {
                }
            }
        }
    },

    ["Broken"] = {
        ["MALE"] = {
            ["CATEGORY"] = {
                ["Head"] = {
                    "Haircolor",
                    "Hairstyle",
                    "Skincolor"
                }
            }
        },
        ["FEMALE"] = {
            ["CATEGORY"] = {
                ["Head"] = {
                }
            }
        }
    },

    ["Skeleton"] = {
        ["MALE"] = {
            ["CATEGORY"] = {
                ["Head"] = {
                }
            }
        },
        ["FEMALE"] = {
            ["CATEGORY"] = {
                ["Head"] = {
                }
            }
        }
    },

    ["Vrykul"] = {
        ["MALE"] = {
            ["CATEGORY"] = {
                ["Head"] = {
                    "Facialhair",
                    "Haircolor",
                    "Hairstyle",
                    "Skincolor"
                }
            }
        },
        ["FEMALE"] = {
            ["CATEGORY"] = {
                ["Head"] = {
                }
            }
        }
    },

    ["Tuskarr"] = {
        ["MALE"] = {
            ["CATEGORY"] = {
                ["Head"] = {
                    "Facialhair",
                    "Haircolor",
                    "Hairstyle",
                    "Skincolor"
                }
            }
        },
        ["FEMALE"] = {
            ["CATEGORY"] = {
                ["Head"] = {
                }
            }
        }
    },

    ["Forest Troll"] = {
        ["MALE"] = {
            ["CATEGORY"] = {
                ["Head"] = {
                    "Face",
                    "Facialhair",
                    "Haircolor",
                    "Hairstyle",
                    "Skincolor"
                }
            }
        },
        ["FEMALE"] = {
            ["CATEGORY"] = {
                ["Head"] = {
                }
            }
        }
    },

    ["Taunka"] = {
        ["MALE"] = {
            ["CATEGORY"] = {
                ["Head"] = {
                    "Facialhair",
                    "Skincolor"
                }
            }
        },
        ["FEMALE"] = {
            ["CATEGORY"] = {
                ["Head"] = {
                }
            }
        }
    },

    ["Northrend Skeleton"] = {
        ["MALE"] = {
            ["CATEGORY"] = {
                ["Head"] = {
                    "Facialhair",
                    "Haircolor",
                    "Skincolor"
                }
            }
        },
        ["FEMALE"] = {
            ["CATEGORY"] = {
                ["Head"] = {
                }
            }
        }
    },

    ["Ice troll"] = {
        ["MALE"] = {
            ["CATEGORY"] = {
                ["Head"] = {
                    "Facialhair",
                    "Haircolor",
                    "Hairstyle",
                    "Skincolor"
                }
            }
        },
        ["FEMALE"] = {
            ["CATEGORY"] = {
                ["Head"] = {
                }
            }
        }
    }
}

PhaseToolkit.InfoCustom = {
	["Human"] = {
		["male"] = {
			["complexion"] = 5,
			["face"] = 24,
			["haircolor"] = 48,
			["eyecolor"] = 135,
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
			["eyetype"] = 5,
			["stubble"] = 13,
			["hairstyle"] = 74,
			["beard"] = 21,
		},
		["female"] = {
			["complexion"] = 5,
			["face"] = 30,
			["haircolor"] = 48,
			["eyecolor"] = 135,
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
			["eyetype"] = 5,
			["secondaryeyecolor"] = 88,
			["scars"] = 12,
			["hairstyle"] = 70,
		}
	},
	["Orc"] = {
		["male"] = {
			["secondaryeyecolor"] = 30,
			["tattoocolor"] = 11,
			["face"] = 9,
			["bodytattoo"] = 13,
			["eyecolor"] = 77,
			["hand(left)"] = 9,
			["faceshape"] = 4,
			["mustache"] = 5,
			["earrings"] = 8,
			["tusks"] = 7,
			["piercings"] = 7,
			["eyebrows"] = 5,
			["haircolor"] = 36,
			["facetattoo"] = 18,
			["skincolor"] = 45,
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
			["eyetype"] = 3,
		},
		["female"] = {
			["secondaryeyecolor"] = 30,
			["tattoocolor"] = 11,
			["face"] = 9,
			["haircolor"] = 36,
			["eyecolor"] = 77,
			["hand(left)"] = 6,
			["faceshape"] = 3,
			["earrings"] = 17,
			["piercings"] = 5,
			["facetattoo"] = 17,
			["ears"] = 2,
			["necklace"] = 5,
			["skincolor"] = 45,
			["scars"] = 5,
			["hand(right)"] = 6,
			["bodytattoo"] = 13,
			["body"] = 7,
			["hairstyle"] = 45,
			["eyetype"] = 3,
		}
	},
	["Dwarf"] = {
		["male"] = {
			["secondaryeyecolor"] = 33,
			["tattoocolor"] = 8,
			["garment"] = 3,
			["haircolor"] = 20,
			["eyecolor"] = 80,
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
			["eyetype"] = 3,
		},
		["female"] = {
			["piercings"] = 9,
			["eyebrows"] = 18,
			["feather"] = 7,
			["facetattoo"] = 11,
			["tattoocolor"] = 8,
			["face"] = 10,
			["bodytattoo"] = 10,
			["eyecolor"] = 80,
			["skincolor"] = 23,
			["secondaryeyecolor"] = 33,
			["feathercolor"] = 9,
			["jewelrycolor"] = 7,
			["hairstyle"] = 45,
			["haircolor"] = 20,
			["earrings"] = 14,
			["garment"] = 3,
			["eyetype"] = 3,
		}
	},
	["NightElf"] = {
		["male"] = {
			["secondaryeyecolor"] = 40,
			["scars"] = 7,
			["haircolor"] = 30,
			["eyecolor"] = 87,
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
			["eyetype"] = 3,
			["facetattoo"] = 16,
			["bodytype"] = 2,
		},
		["female"] = {
			["secondaryeyecolor"] = 40,
			["scars"] = 7,
			["haircolor"] = 30,
			["eyecolor"] = 87,
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
			["eyetype"] = 3,
			["bodytype"] = 2,
		}
	},
	["Undead"] = {
		["male"] = {
			["leg(left)"] = 2,
			["secondaryeyecolor"] = 28,
			["hairgradient"] = 13,
			["facetype"] = 11,
			["eyecolor"] = 74,
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
			["eyetype"] = 3,
		},
		["female"] = {
			["leg(left)"] = 2,
			["hips"] = 4,
			["hairgradient"] = 13,
			["haircolor"] = 17,
			["eyecolor"] = 74,
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
			["secondaryeyecolor"] = 28,
			["leg(right)"] = 2,
			["face"] = 10,
			["facetype"] = 5,
			["hairstyle"] = 47,
			["eyetype"] = 3,
		}
	},
	["Tauren"] = {
		["male"] = {
			["mane"] = 5,
			["secondaryeyecolor"] = 25,
			["tail"] = 4,
			["eyecolor"] = 72,
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
			["eyetype"] = 3,
			["grime"] = 4,
			["scars"] = 9,
		},
		["female"] = {
			["mane"] = 2,
			["hornmarkings"] = 3,
			["secondaryeyecolor"] = 25,
			["face"] = 4,
			["eyecolor"] = 72,
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
			["eyetype"] = 3,
			["grime"] = 4,
			["scars"] = 9,
		}
	},
	["Gnome"] = {
		["male"] = {
			["wristjewelry"] = 2,
			["goggles"] = 2,
			["face"] = 7,
			["haircolor"] = 74,
			["eyecolor"] = 86,
			["jewelrycolor"] = 5,
			["accentcolor"] = 7,
			["mustache"] = 24,
			["earrings"] = 12,
			["piercings"] = 5,
			["eyebrows"] = 13,
			["skincolor"] = 23,
			["ears"] = 3,
			["sideburns"] = 6,
			["secondaryeyecolor"] = 39,
			["scars"] = 7,
			["hairgradient"] = 20,
			["hairstyle"] = 63,
			["hairstreaks"] = 75,
			["beard"] = 13,
			["eyetype"] = 3,
		},
		["female"] = {
			["wristjewelry"] = 2,
			["goggles"] = 2,
			["hairgradient"] = 20,
			["haircolor"] = 74,
			["eyecolor"] = 86,
			["jewelrycolor"] = 5,
			["accentcolor"] = 7,
			["earrings"] = 22,
			["piercings"] = 8,
			["eyebrows"] = 19,
			["skincolor"] = 23,
			["ears"] = 3,
			["secondaryeyecolor"] = 39,
			["scars"] = 7,
			["face"] = 7,
			["hairaccessory"] = 2,
			["hairstyle"] = 59,
			["hairstreaks"] = 75,
			["eyetype"] = 3,
		}
	},
	["Troll"] = {
		["male"] = {
			["nosepiercing"] = 7,
			["secondaryeyecolor"] = 31,
			["hairgradient"] = 11,
			["haircolor"] = 43,
			["eyecolor"] = 78,
			["jewelrycolor"] = 12,
			["accentcolor"] = 27,
			["bandages"] = 9,
			["eyebrows"] = 2,
			["sideburns"] = 14,
			["mouthpiercing"] = 4,
			["leg(right)"] = 18,
			["beard"] = 17,
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
			["eyetype"] = 3,
		},
		["female"] = {
			["leg(left)"] = 25,
			["tusks"] = 10,
			["secondaryeyecolor"] = 31,
			["face"] = 6,
			["bodytattoo"] = 10,
			["eyecolor"] = 78,
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
			["eyetype"] = 3,
		}
	},
	["Goblin"] = {
		["male"] = {
			["secondaryeyecolor"] = 43,
			["face"] = 12,
			["haircolor"] = 68,
			["eyecolor"] = 91,
			["jewelrycolor"] = 8,
			["nose"] = 11,
			["mustache"] = 9,
			["earrings"] = 9,
			["eyebrows"] = 2,
			["skincolor"] = 28,
			["ears"] = 10,
			["sideburns"] = 8,
			["chin"] = 6,
			["nosering"] = 5,
			["hairgradient"] = 20,
			["hairstyle"] = 58,
			["beard"] = 12,
			["hairstreaks"] = 75,
			["eyetype"] = 4,
			["bodytype"] = 2,
			["grime"] = 5,
			["facemarkings"] = 6,
			["necklace"] = 5,
			["wristjewelry"] = 2,
			["legjewelry"] = 2,
			["stubble"] = 2,
		},
		["female"] = {
			["skincolor"] = 24,
			["eyebrows"] = 20,
			["nosering"] = 9,
			["secondaryeyecolor"] = 43,
			["hairgradient"] = 20,
			["face"] = 10,
			["haircolor"] = 68,
			["eyecolor"] = 91,
			["bodyshape"] = 2,
			["necklace"] = 11,
			["jewelrycolor"] = 8,
			["hairstyle"] = 52,
			["nose"] = 9,
			["ears"] = 10,
			["earrings"] = 13,
			["chin"] = 7,
			["hairstreaks"] = 75,
			["eyetype"] = 4,
			["bodytype"] = 2,
			["grime"] = 4,
			["facemarkings"] = 10,
			["wristjewelry"] = 2,
			["legjewelry"] = 2,
		}
	},
	["BloodElf"] = {
		["male"] = {
			["secondaryeyecolor"] = 40,
			["tattoocolor"] = 10,
			["face"] = 12,
			["bodytattoo"] = 17,
			["eyecolor"] = 87,
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
			["skincolor"] = 35,
			["gemcolor"] = 6,
			["sideburns"] = 5,
			["horns"] = 7,
			["ears"] = 4,
			["runecolor"] = 6,
			["headdress"] = 3,
			["hairstyle"] = 54,
			["eyetype"] = 3,
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
			["eyecolor"] = 87,
			["blindfold"] = 12,
			["jewelrycolor"] = 3,
			["accentcolor"] = 5,
			["faceshape"] = 2,
			["earrings"] = 14,
			["runes"] = 12,
			["headdress"] = 3,
			["gemcolor"] = 6,
			["skincolor"] = 34,
			["hairgradient"] = 18,
			["ears"] = 4,
			["necklace"] = 5,
			["horns"] = 7,
			["bracelets"] = 6,
			["eyetype"] = 3,
			["runescolor"] = 6,
			["hairstyle"] = 63,
			["haircolor"] = 40,
		}
	},
	["Draenei"] = {
		["male"] = {
			["secondaryeyecolor"] = 36,
			["face"] = 10,
			["haircolor"] = 52,
			["eyecolor"] = 82,
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
			["eyetype"] = 3,
		},
		["female"] = {
			["secondaryeyecolor"] = 36,
			["horns"] = 19,
			["haircolor"] = 52,
			["eyecolor"] = 82,
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
			["eyetype"] = 3,
		}
	},
	["Worgen"] = {
		["male"] = {
			["mane"] = 4,
			["secondaryeyecolor"] = 30,
			["face"] = 7,
			["eyecolor"] = 77,
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
			["eyetype"] = 3,
		},
		["female"] = {
			["mane"] = 3,
			["secondaryeyecolor"] = 30,
			["face"] = 16,
			["eyecolor"] = 77,
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
			["eyetype"] = 3,
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
			["mustache"] = 8,
			["secondaryeyecolor"] = 27,
			["eyecolor"] = 74,
			["face"] = 21,
			["hairstyle"] = 25,
			["beard"] = 21,
			["eyetype"] = 3,
			["sideburns"] = 9,
			["accentcolor"] = 6,
		},
		["female"] = {
			["tail"] = 2,
			["skincolor"] = 18,
			["hairstyle"] = 23,
			["secondaryeyecolor"] = 27,
			["haircolor"] = 16,
			["face"] = 20,
			["earrings"] = 6,
			["eyecolor"] = 74,
			["eyetype"] = 3,
			["accentcolor"] = 6,
		}
	},
	["Nightborne"] = {
		["male"] = {
			["jawjewelry"] = 5,
			["secondaryeyecolor"] = 29,
			["facejewelry"] = 4,
			["bodytattoo"] = 7,
			["eyecolor"] = 76,
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
			["eyetype"] = 3,
		},
		["female"] = {
			["jawjewelry"] = 2,
			["secondaryeyecolor"] = 29,
			["facejewelry"] = 5,
			["bodytattoo"] = 7,
			["eyecolor"] = 76,
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
			["eyetype"] = 3,
		}
	},
	["Highmountain"] = {
		["male"] = {
			["nosepiercing"] = 5,
			["hornmarkings"] = 2,
			["secondaryeyecolor"] = 25,
			["face"] = 5,
			["eyecolor"] = 72,
			["hornwraps"] = 3,
			["hornstyle"] = 10,
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
			["eyetype"] = 3,
		},
		["female"] = {
			["nosepiercing"] = 4,
			["hornmarkings"] = 2,
			["secondaryeyecolor"] = 25,
			["face"] = 4,
			["eyecolor"] = 72,
			["hornwraps"] = 2,
			["hairdecoration"] = 4,
			["hornstyle"] = 9,
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
			["eyetype"] = 3,
		}
	},
	["VoidElf"] = {
		["male"] = {
			["secondaryeyecolor"] = 33,
			["bodymarkings"] = 3,
			["face"] = 12,
			["haircolor"] = 40,
			["eyecolor"] = 80,
			["ears"] = 3,
			["facialhair"] = 8,
			["tentacles"] = 2,
			["skincolor"] = 29,
			["stubble"] = 2,
			["hairstyle"] = 13,
			["facemarkings"] = 11,
			["eyetype"] = 3,
		},
		["female"] = {
			["secondaryeyecolor"] = 33,
			["bodymarkings"] = 3,
			["face"] = 12,
			["haircolor"] = 40,
			["eyecolor"] = 80,
			["ears"] = 3,
			["facemarkings"] = 11,
			["tentacles"] = 2,
			["skincolor"] = 29,
			["earrings"] = 5,
			["hairstyle"] = 11,
			["eyetype"] = 3,
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
			["eyetype"] = 3,
			["secondaryeyecolor"] = 8,
			["eyecolor"] = 62,
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
			["eyetype"] = 3,
			["secondaryeyecolor"] = 8,
			["eyecolor"] = 62,
		}
	},
	["Zandalari"] = {
		["male"] = {
			["secondaryeyecolor"] = 31,
			["haircolor"] = 49,
			["eyecolor"] = 76,
			["hairstyle"] = 12,
			["piercings"] = 6,
			["skincolor"] = 36,
			["tusks"] = 7,
			["tattoocolor"] = 8,
			["eargauge"] = 3,
			["face"] = 6,
			["tattoo"] = 4,
			["eyetype"] = 3,
			["jewelrycolor"] = 12,
			["accentcolor"] = 27,
			["bandages"] = 9,
			["eyebrows"] = 2,
			["sideburns"] = 14,
			["hairgradient"] = 11,
			["beard"] = 17,
			["hairhighlight"] = 36,
			["tattoostyle"] = 3,
			["mustache"] = 4,
			["facetattoo"] = 14,
			["tattoocolor"] = 43,

		},
		["female"] = {
			["secondaryeyecolor"] = 31,
			["haircolor"] = 49,
			["eyecolor"] = 76,
			["earrings"] = 2,
			["piercings"] = 4,
			["skincolor"] = 36,
			["tusks"] = 7,
			["tattoocolor"] = 8,
			["necklace"] = 2,
			["tattoo"] = 5,
			["eargauge"] = 3,
			["face"] = 6,
			["hairstyle"] = 10,
			["eyetype"] = 3,
			["bodytattoo"] = 9,
			["hairgradient"] = 11,
			["jewelrycolor"] = 12,
			["accentcolor"] = 27,
			["bandages"] = 9,
			["hairhighlight"] = 36,
			["tattoostyle"] = 3,
			["facetattoo"] = 14,
			["tattoocolor"] = 43,
		}
	},
	["Kul tiran"] = {
		["male"] = {
			["secondaryeyecolor"] = 85,
			["face"] = 7,
			["bodytattoo"] = 6,
			["eyecolor"] = 103,
			["mustache"] = 13,
			["hairstyle"] = 34,
			["skincolor"] = 21,
			["sideburns"] = 8,
			["tattoocolor"] = 8,
			["haircolor"] = 48,
			["beard"] = 24,
			["eyetype"] = 5,
			["ears"] = 2,
			["eyebrows"] = 19,
			["stubble"] = 13,
		},
		["female"] = {
			["secondaryeyecolor"] = 85,
			["haircolor"] = 49,
			["eyecolor"] = 103,
			["earrings"] = 7,
			["eyebrows"] = 2,
			["skincolor"] = 21,
			["necklace"] = 7,
			["tattoocolor"] = 8,
			["face"] = 7,
			["bodytattoo"] = 6,
			["hairstyle"] = 10,
			["eyetype"] = 5,
			["ears"] = 2,
			["eyebrows"] = 25,
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
			["eyecolor"] = 58,
			["eyetype"] = 3,
			["secondaryeyecolor"] = 8,
		},
		["female"] = {
			["piercings"] = 7,
			["tattoo"] = 6,
			["skincolor"] = 5,
			["hairstyle"] = 11,
			["face"] = 10,
			["haircolor"] = 6,
			["eyecolor"] = 58,
			["eyetype"] = 3,
			["secondaryeyecolor"] = 8,
		}
	},
	["Vulpera"] = {
		["male"] = {
			["pattern"] = 3,
			["secondaryeyecolor"] = 31,
			["face"] = 6,
			["patterncolor"] = 8,
			["eyecolor"] = 78,
			["ears"] = 6,
			["furcolor"] = 9,
			["snout"] = 6,
			["earrings"] = 2,
			["eyetype"] = 3,
		},
		["female"] = {
			["pattern"] = 3,
			["secondaryeyecolor"] = 31,
			["face"] = 6,
			["patterncolor"] = 8,
			["eyecolor"] = 78,
			["ears"] = 8,
			["furcolor"] = 9,
			["snout"] = 6,
			["earrings"] = 2,
			["eyetype"] = 3,
		}
	},
	["Mag'har"] = {
		["male"] = {
			["secondaryeyecolor"] = 27,
			["tattoocolor"] = 11,
			["face"] = 9,
			["haircolor"] = 36,
			["eyecolor"] = 74,
			["hand(left)"] = 8,
			["faceshape"] = 4,
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
			["eyecolor"] = 74,
			["secondaryeyecolor"] = 27,
			["necklace"] = 5,
			["hand(left)"] = 6,
			["hand(right)"] = 6,
			["faceshape"] = 3,
			["hairstyle"] = 46,
			["earrings"] = 17,
			["haircolor"] = 36,
		}
	},
	["Mechagnome"] = {
		["male"] = {
			["leg(left)"] = 4,
			["secondaryeyecolor"] = 40,
			["chestmodification"] = 4,
			["hairgradient"] = 20,
			["haircolor"] = 74,
			["eyecolor"] = 86,
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
			["secondaryeyecolor"] = 40,
			["chestmodification"] = 4,
			["hairgradient"] = 20,
			["haircolor"] = 74,
			["eyecolor"] = 86,
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


PhaseToolkit.itemSubtypeToSubclassIdWeapon = {
    ["One-Handed Axes"]    = 0,
    ["Two-Handed Axes"]    = 1,
    ["Bows"]               = 2,
    ["Guns"]               = 3,
    ["One-Handed Maces"]   = 4,
    ["Two-Handed Maces"]   = 5,
    ["Polearms"]           = 6,
    ["One-Handed Swords"]  = 7,
    ["Two-Handed Swords"]  = 8,
    ["Warglaives"]         = 9,
    ["Staves"]             = 10,
    ["Bear Claws"]         = 11,
    ["CatClaws"]           = 12,
    ["Fist Weapons"]       = 13,
    ["Miscellaneous"]      = 14,
    ["Daggers"]            = 15,
    ["Thrown"]             = 16,
    ["Crossbows"]          = 18,
    ["Wands"]              = 19,
    ["Fishing Poles"]      = 20,
}

PhaseToolkit.itemSubtypeToSubclassIdArmor = {
    ["Miscellaneous"] = 0,
    ["Cloth"]         = 1,
    ["Leather"]       = 2,
    ["Mail"]          = 3,
    ["Plate"]         = 4,
    ["Cosmetic"]      = 5,
    ["Shields"]       = 6,
    ["Relic"]         = 11,
}

PhaseToolkit.itemSubtypeToSubclassIdKey = {
    ["Key"]      = 0,
    ["Lockpick"] = 1,
}

PhaseToolkit.itemSubtypeToSubclassIdMisc = {
    ["Junk"]           = 0,
    ["Reagent"] 	   = 1,
	["Companion Pet"]  = 2,
	["Holiday"]        = 3,
	["Other"]          = 4,
	["Mount"]          = 5,
	["Mount Equipment"]= 6,
}

PhaseToolkit.itemClass={
	{name="None",classId=-1,subclass={}},
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
		{name="Junk",subclassId=0},
		{name="Reagent",subclassId=1},
		{name="Companion Pet",subclassId=2},
		{name="Holiday",subclassId=3},
		{name="Other",subclassId=4},
		{name="Mount",subclassId=5},
		{name="Mount Equipment",subclassId=6},
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
	{name="No bonding",bondingId=0},
	{name="When picked up",bondingId=1},
	{name="When equipped",bondingId=2},
	{name="When used",bondingId=3},
	{name="Quest Item",bondingId=4},
}

PhaseToolkit.itemQuality={
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
	 "Cheats",
	"Flight" ,
	 "Knockback",
	 "Listed",
	 "Modify",
	 "Mounting",
	 "Objects",
	 "Silence",
	 "Teleport",
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

local textureBasePath = "Interface\\AddOns\\"..addonName.."\\assets\\customPortrait\\"
local firstColumnIcon = {
	{name="Human",raceid="1",texturemale="",atlasmale="raceicon128-human-male",atlasfemale="raceicon128-human-female"},
	{name="Orc",raceid="2",texturemale="",atlasmale="raceicon128-orc-male",atlasfemale="raceicon128-orc-female"},
	{name="Dwarf",raceid="3",texturemale="",atlasmale="raceicon128-dwarf-male",atlasfemale="raceicon128-dwarf-female"},
	{name="NightElf",raceid="4",texturemale="",atlasmale="raceicon128-nightelf-male",atlasfemale="raceicon128-nightelf-female"},
	{name="Undead",raceid="5",texturemale="",atlasmale="raceicon128-undead-male",atlasfemale="raceicon128-undead-female"},
	{name="Tauren",raceid="6",texturemale="",atlasmale="raceicon128-tauren-male",atlasfemale="raceicon128-tauren-female"},
	{name="Gnome",raceid="7",texturemale="",atlasmale="raceicon128-gnome-male",atlasfemale="raceicon128-gnome-female"},
	{name="Troll",raceid="8",texturemale="",atlasmale="raceicon128-troll-male",atlasfemale="raceicon128-troll-female"},
	{name="Goblin",raceid="9",texturemale="",atlasmale="raceicon128-goblin-male",atlasfemale="raceicon128-goblin-female"},
	{name="BloodElf",raceid="10",texturemale="",atlasmale="raceicon128-bloodelf-male",atlasfemale="raceicon128-bloodelf-female"},
	{name="Draenei",raceid="11",texturemale="",atlasmale="raceicon128-draenei-male",atlasfemale="raceicon128-draenei-female"},
}

local secondColumnIcon = {

	{name="Worgen",raceid="22",texturemale="",atlasmale="raceicon128-worgen-male",atlasfemale="raceicon128-worgen-female"},
	{name="Pandaren",raceid="24",texturemale="",atlasmale="raceicon128-pandaren-male",atlasfemale="raceicon128-pandaren-female"},
	{name="Nightborne",raceid="27",texturemale="",atlasmale="raceicon128-nightborne-male",atlasfemale="raceicon128-nightborne-female"},
	{name="Lightforged",raceid="30",texturemale="",atlasmale="raceicon128-lightforged-male",atlasfemale="raceicon128-lightforged-female"},
	{name="Zandalari",raceid="31",texturemale="",atlasmale="raceicon128-zandalari-male",atlasfemale="raceicon128-zandalari-female"},
	{name="Kul tiran",raceid="32",texturemale="",atlasmale="raceicon128-kultiran-male",atlasfemale="raceicon128-kultiran-female"},
	{name="DarkIron",raceid="34",texturemale="",atlasmale="raceicon128-darkirondwarf-male",atlasfemale="raceicon128-darkirondwarf-female"},
}

local thirdColumnIcon = {
	{name="Mag'har",raceid="36",texturemale="",atlasmale="raceicon128-magharorc-male",atlasfemale="raceicon128-magharorc-female"},
	{name="Mechagnome",raceid="37",texturemale="",atlasmale="raceicon128-mechagnome-male",atlasfemale="raceicon128-mechagnome-female"},
	{name="Highmountain",raceid="28",texturemale="",atlasmale="raceicon128-highmountain-male",atlasfemale="raceicon128-highmountain-female"},
	{name="VoidElf",raceid="29",texturemale="",atlasmale="raceicon128-voidelf-male",atlasfemale="raceicon128-voidelf-female"},
	{name="Vulpera",raceid="35",texturemale="",atlasmale="raceicon128-vulpera-male",atlasfemale="raceicon128-vulpera-female"},
	{name="Naga",raceid="13",texturemale=textureBasePath.."Naga_male.blp",texturefemale=textureBasePath.."Naga_female.blp",atlasmale="",atlasfemale=""},
	{name="Thin Human",raceid="33",texturemale=textureBasePath.."thin_human.blp",atlasmale="",atlasfemale=""},
	{name="Fel Orc",raceid="12",texturemale=textureBasePath.."felorc.blp",atlasmale="",atlasfemale=""},
	{name="Broken",raceid="14",texturemale=textureBasePath.."broken.blp",atlasmale="",atlasfemale=""},
	{name="Skeleton",raceid="15",texturemale=textureBasePath.."Skeleton.blp",atlasmale="",atlasfemale=""},
	{name="Vrykul",raceid="16",texturemale=textureBasePath.."Vrykul_male.blp",atlasmale="",atlasfemale=""},
}

local extraRaceIcon = {
	{name="Tuskarr",raceid="17",texturemale=textureBasePath.."tuskarr.blp",atlasmale="",atlasfemale=""},
	{name="Forest Troll",raceid="18",texturemale=textureBasePath.."forest_troll.blp",atlasmale="",atlasfemale=""},
	{name="Taunka",raceid="19",texturemale=textureBasePath.."taunka.blp",atlasmale="",atlasfemale=""},
	{name="Northrend Skeleton",raceid="20",texturemale=textureBasePath.."northrend_skeleton.blp",atlasmale="",atlasfemale=""},
	{name="Ice troll",raceid="21",texturemale=textureBasePath.."ice_troll.blp",atlasmale="",atlasfemale=""},
}

local function getRaceDataFromRaceName(raceName)
	for _, data in ipairs(firstColumnIcon) do
		if data.name == raceName then
			return data
		end
	end
	for _, data in ipairs(secondColumnIcon) do
		if data.name == raceName then
			return data
		end
	end
	for _, data in ipairs(thirdColumnIcon) do
		if data.name == raceName then
			return data
		end
	end
	for _, data in ipairs(extraRaceIcon) do
		if data.name == raceName then
			return data
		end
	end
	return nil -- Not found, should not happen if used correctly
end

-- // EpsilonLib for AddOnCommands:
local sendAddonCmd, sendAddonCommandChain

if EpsilonLib and EpsilonLib.AddonCommands then
	sendAddonCmd, sendAddonCommandChain = EpsilonLib.AddonCommands.Register("PhaseToolkit")
else
	-- command, callbackFn, forceShowMessages
	function sendAddonCmd(command, callbackFn, forceShowMessages)
		if EpsilonLib and EpsilonLib.AddonCommands then
			-- Reassign it.
			sendAddonCmd, sendAddonCommandChain = EpsilonLib.AddonCommands.Register("PhaseToolkit")
			sendAddonCmd(command, callbackFn, forceShowMessages)
			return
		end

		-- Fallback ...
		print("Something went wrong with epsilib... report this please")
		SendChatMessage("." .. command, "GUILD")
	end

	-- Fallback function for sendAddonCommandChain if EpsilonLib is not available
	function sendAddonCommandChain(commands, callbackFn, forceShowMessages)
		if EpsilonLib and EpsilonLib.AddonCommands then
			-- Reassign it.
			sendAddonCmd, sendAddonCommandChain = EpsilonLib.AddonCommands.Register("PhaseToolkit")
			sendAddonCommandChain(commands, callbackFn, forceShowMessages)
			return
		end

		-- Fallback - send commands with delays
		for i, command in ipairs(commands) do
			local delay = (i - 1) * 0.5
			C_Timer.After(delay, function()
				SendChatMessage("." .. command, "GUILD")
			end)
		end

		if callbackFn then
			C_Timer.After(#commands * 0.5 + 1, function()
				callbackFn(true, {})
			end)
		end
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
-- ============================== MAIN FUNCTIONS ============================== --
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
	if UnitExists("target") and not UnitIsPlayer("target") then
		sendAddonCmd("phase forge npc outfit race " .. RaceId, nil)
	end
end

function PhaseToolkit.ChangeNpcGender(GenderString)
	-- if we have a target and it's a NPC we change
	if UnitExists("target") and not UnitIsPlayer("target") then
		sendAddonCmd("phase forge npc outfit gender " .. GenderString, nil,false)
	end
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

local function getBindingObject(bindName)
	for _,binding in ipairs(PhaseToolkit.itemBonding) do
		if(bindName:lower():find(binding.name:lower())) then
			return binding.bondingId
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
	for _,weapontypeOBJ in ipairs(PhaseToolkit.itemClass[PhaseToolkit.itemCreatorData.selectedItemClass].subclass) do
		if(string.lower(weapontypeOBJ.name)==string.lower(weapontypeSTR)) then
			returnObj= weapontypeOBJ
		end
		if(PhaseToolkit.IsTableEmpty(subString) and string.lower(weapontypeOBJ.name):find(string.lower(weapontypeSTR)) ) then
			returnObj= weapontypeOBJ
		end
	end

	--Second pass looking for 1h or 2h u know only if we didn't got it the first time
	if(returnObj==nil or returnObj=={}) then
		for _,weapontypeOBJ in ipairs(PhaseToolkit.itemClass[PhaseToolkit.itemCreatorData.selectedItemClass].subclass) do
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

	PhaseToolkit.NombreDeLigne = math.ceil(((PhaseToolkit.CountElements(PhaseToolkit.InfoCustom[PhaseToolkit.GetRaceNameByID(PhaseToolkit.SelectedRace.raceid)][PhaseToolkit.SelectedGender]) / 3)))
	PhaseToolkit.ToggleCustomFrame(PhaseToolkit.GetRaceNameByID(PhaseToolkit.SelectedRace.raceid))
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
	-- Create a temporary FontString object to measure text sizes
	local tempFontString = UIParent:CreateFontString(nil, "OVERLAY", "GameFontNormal")

	-- Variable to store the maximum width found
	local maxWidth = 0

	-- Loop through the creature table
	for _, creature in ipairs(creatureTable) do
		-- Assign the creature name to the FontString
		tempFontString:SetText(creature["NomCreature"])

		-- Get the pixel width of the name and compare with the current maximum width
		local nameWidth = tempFontString:GetStringWidth()
		if nameWidth > maxWidth then
			maxWidth = nameWidth
		end
	end

	-- Return the maximum width
	return maxWidth
end

function PhaseToolkit.GetMaxStringWidth(stringTable)
	-- Create a temporary FontString object to measure text sizes
	local tempFontString = UIParent:CreateFontString(nil, "OVERLAY", "GameFontNormal")

	-- Variable to store the maximum width found
	local maxWidth = 0

	-- Loop through the string table
	for _, str in ipairs(stringTable) do
		-- Assign the text to the FontString
		tempFontString:SetText(str)

		-- Get the pixel width of the string and compare with the current maximum width
		local stringWidth = tempFontString:GetStringWidth()
		if stringWidth > maxWidth then
			maxWidth = stringWidth
		end
	end

	-- Return the maximum width
	return maxWidth
end

function PhaseToolkit.RemoveDuplicates(creatureList)
	local uniqueCreatures = {}
	local seenIds = {}

	for _, creature in ipairs(creatureList) do
		local uniqueKey = nil

		if type(creature) == "table" then
			if creature.IdCreature ~= nil then
				uniqueKey = "npc:" .. tostring(creature.IdCreature)
			elseif creature.NomCreature ~= nil then
				uniqueKey = "npcname:" .. tostring(creature.NomCreature)
			end
		elseif creature ~= nil then
			uniqueKey = "value:" .. tostring(creature)
		end

		if uniqueKey and not seenIds[uniqueKey] then
			-- Add the entry to the new list if its unique key hasn't been seen yet
			table.insert(uniqueCreatures, creature)
			seenIds[uniqueKey] = true
		end
	end

	return uniqueCreatures
end

function PhaseToolkit.ShowTooltip(self, tooltip)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT") -- Position the tooltip to the right of the button
	GameTooltip:SetText(tooltip, 1, 1, 1, 1, true)   -- Set the tooltip text
	GameTooltip:Show()                      -- Show the tooltip
end

function PhaseToolkit.DisableComponent(self)
	self:SetAlpha(0.5);
	self:EnableMouse(false);
end

function PhaseToolkit.EnableComponent(self)
	self:SetAlpha(1);
	self:EnableMouse(true);
end

function PhaseToolkit.HideTooltip()
	GameTooltip:Hide() -- Hide the tooltip
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
	if type(t) ~= "table" then
		return
	end
	for i = #t, 1, -1 do -- Traverse the table in reverse order
		if t[i] == strToRemove then
			table.remove(t, i)
		end
	end
end

function PhaseToolkit.RemoveCreatureById(creatureList, creatureId)
	if type(creatureList) ~= "table" then
		return
	end
	for i = #creatureList, 1, -1 do
		if creatureList[i]["IdCreature"] == creatureId then
			table.remove(creatureList, i)
			break -- We can exit the loop after deletion since the ID is unique
		end
	end
end

function PhaseToolkit.RandomiseNpc()
	for attribute, value in pairs(PhaseToolkit.InfoCustom[PhaseToolkit.GetRaceNameByID(PhaseToolkit.SelectedRace.raceid)][PhaseToolkit.SelectedGender]) do
		if(not PhaseToolkit.CustomFieldLocks[attribute]) then
			local randomValue = math.random(1, value)
			PhaseToolkit.GeneralStat[attribute] = randomValue
			sendAddonCmd("phase forge npc outfit custom " .. attribute .. " " .. randomValue, nil)
		end
	end
	if (PhaseToolkit.CustomFrame ~= nil) then
		if PhaseToolkit.CustomFrame:IsShown() then
			PhaseToolkit.CustomFrame:Hide()
			PhaseToolkit.CustomFrame = nil
			PhaseToolkit.CreateCustomFrame()
			PhaseToolkit.CreateCustomGrid(PhaseToolkit.InfoCustom[PhaseToolkit.GetRaceNameByID(PhaseToolkit.SelectedRace.raceid)][PhaseToolkit.SelectedGender])
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

local function cleanHighlights()
	for _,row in ipairs(PhaseToolkit.itemCreatorData.selectedRows) do
		row.highlight:Hide()
	end
end

-- ============================== FONCTIONS ² ============================== --
local function getItemInfoFromHyperlink(link)
	local strippedItemLink, itemID = link:match("|Hitem:((%d+).-)|h");
	if itemID then
		return tonumber(itemID), strippedItemLink;
	end
end

-- Function to copy all NPC customizations (customizations + equipment + weapons + name)
-- This function uses two main commands :
-- 1. "npc info" to retrieve race, gender and all equipment (including weapons)
-- 2. "phase forg npc out info" to retrieve customization parameters
-- Normal equipment is stored with their slot and extracted object ID
-- Weapons are detected and stored separately with their numeric slot :
--   - Slot 0 = Main hand (main hand, mainhand)
--   - Slot 1 = Off hand (off hand, offhand)
--   - Slot 2 = Ranged (ranged, bow, gun, crossbow)
-- Application :
--   - Normal equipment: .ph f n out equip ITEMID
--   - Weapons: .ph fo np weapon ITEMID SLOT
--   - Name: .ph f n name NPCNAME
function PhaseToolkit.CopyNpcCustomisation()

	if not UnitExists("target") or UnitIsPlayer("target") then
		print("You need to target an NPC to copy their customisations.")
		return
	end

	-- Check if at least one copy option is enabled
	if not (PhaseToolkit.CopyNpcNameEnabled or PhaseToolkit.CopyNpcCustomisationEnabled or PhaseToolkit.CopyNpcGearEnabled or PhaseToolkit.CopyNpcWeaponsEnabled) then
		print("|cffff0000Error: No copy options are enabled. Please enable at least one option in the copy settings.|r")
		return
	end

	-- Create a table to store customization information
	local outfitInformation = {}

	-- Get the targeted NPC name (only if copy name is enabled)
	if PhaseToolkit.CopyNpcNameEnabled then
		local npcName = UnitName("target")
		if npcName then
			outfitInformation["_name"] = npcName
		else
			print("|cffff0000Error: Could not get NPC name|r")
			return
		end
	end

	-- Check that sendAddonCmd exists
	if not sendAddonCmd then
		print("|cffff0000Error: sendAddonCmd function not found|r")
		return
	end

	-- Get info via "npc info"
	sendAddonCmd("npc info", function(isSuccessful, responses)
		if not isSuccessful or not responses then
			print("|cffff0000Error: 'npc info' command failed. You need to be in the origin phase of the creature to gather info, and must be either its creator or a Phase officer|r")
			return
		end

		-- Initialize structures (only if needed)
		if PhaseToolkit.CopyNpcGearEnabled then
			outfitInformation["_equipment"] = {}
		end
		if PhaseToolkit.CopyNpcWeaponsEnabled then
			outfitInformation["_weapons"] = {}
		end

		-- Parse each line
		for _, line in ipairs(responses) do
			local cleanLine = line:gsub("|cff%x%x%x%x%x%x", ""):gsub("|r", "")
			-- Also clean item links
			cleanLine = cleanLine:gsub("|H[^|]*|h", ""):gsub("|h", "")

			-- DisplayID for race/gender
			if PhaseToolkit.CopyNpcCustomisationEnabled then
				local displayID = string.match(cleanLine, "DisplayID: (%d+)")
				if displayID then
					local identity = PhaseToolkit.infoPerDisplay[displayID]
					if identity then
						outfitInformation["_race"] = identity.race
						outfitInformation["_gender"] = identity.sexe
					end
				end
			end

			local slot, itemData = string.match(cleanLine, "^([^:]+):%s*%[(.+)")
			if slot and itemData and (PhaseToolkit.CopyNpcGearEnabled or PhaseToolkit.CopyNpcWeaponsEnabled) then
				slot = slot:gsub("^%s+", ""):gsub("%s+$", "")

				-- Filter lines that are not really equipment
				if not (string.find(slot, "NPC") or string.find(slot, "Info")) then

				-- Use existing function to extract ID from item link
				local itemID, strippedLink = getItemInfoFromHyperlink(line)

				if itemID then
					local slotLower = string.lower(slot)
					if slotLower:find("main") or slotLower:find("off") or slotLower:find("ranged") then
						-- This is a weapon slot
						if PhaseToolkit.CopyNpcWeaponsEnabled then
							if not outfitInformation["_weapons"] then
								outfitInformation["_weapons"] = {}
							end
							if slotLower:find("main") then
								outfitInformation["_weapons"]["0"] = itemID
							elseif slotLower:find("off") then
								outfitInformation["_weapons"]["1"] = itemID
							elseif slotLower:find("ranged") then
								outfitInformation["_weapons"]["2"] = itemID
							end
						end
					else
						-- This is equipment slot
						if PhaseToolkit.CopyNpcGearEnabled then
							if not outfitInformation["_equipment"] then
								outfitInformation["_equipment"] = {}
							end
							outfitInformation["_equipment"][slot] = itemID
						end
					end
					end
				end
			end
		end  -- End of for loop

		-- Check if we need to get customizations
		if PhaseToolkit.CopyNpcCustomisationEnabled then
			-- Now get customizations via "ph f n out info"
			sendAddonCmd("ph f n out info", function(isSuccessful2, responses2)

				if not isSuccessful2 then
					print("|cffff0000Error: 'ph f n out info' command failed. You need to be in the origin phase of the creature & either be it's creator or a Phase Officer to gather info.|r")
					return
				end

				if not responses2 then
					print("|cffff0000Error: No responses from 'ph f n out info' command|r")
					return
				end

				if #responses2 == 0 then
					print("|cffff0000Error: Empty responses from 'ph f n out info' command|r")
					return
				end


				-- Initialize customizations (only if copy customization is enabled)
				if PhaseToolkit.CopyNpcCustomisationEnabled then
					outfitInformation["_customizations"] = {}
				end

				-- Parse customizations from response (only if enabled)
				if PhaseToolkit.CopyNpcCustomisationEnabled then
					for _, line in ipairs(responses2) do
						-- Clean color codes
						local cleanLine = line:gsub("|cff%x%x%x%x%x%x", ""):gsub("|r", "")

						-- Only parse "Character Select IDs" lines, ignore "Internal IDs"
						if string.find(cleanLine, "%(Character Select IDs%)") then
							-- Parse lines of format: "(Character Select IDs) Option: tattoocolor, Choice(s): 5,)"
							local optionName, choiceValue = string.match(cleanLine, "Option:%s*([^,]+),%s*Choice%(s%):%s*(%d+)")
							if optionName and choiceValue then
								-- Clean option name (remove spaces)
								optionName = optionName:gsub("^%s+", ""):gsub("%s+$", "")
								local numValue = tonumber(choiceValue)
								if numValue then
									if numValue>200 then
										 outfitInformation["_customizations"][optionName] = 1
									else
										outfitInformation["_customizations"][optionName] = numValue
									end
								end
							end
						end
					end
				end

				-- Serialize and show data
				PhaseToolkit.SerializeAndShowOutfitData(outfitInformation)
			end, false)
		else
			-- No customizations needed, serialize directly
			PhaseToolkit.SerializeAndShowOutfitData(outfitInformation)
		end
	end, false)
end

-- Helper function to serialize and show outfit data
function PhaseToolkit.SerializeAndShowOutfitData(outfitInformation)
	local serializedData = AceSerializer:Serialize(outfitInformation)
	if serializedData then
		-- We have the data so we show them to the user using the OPEN_OUTFIT_COPY_POPUP
		StaticPopup_Show("OPEN_OUTFIT_COPY_POPUP", nil, nil, { serializedData = serializedData })
	else
		print("|cffff0000Error: Failed to serialize data|r")
	end
end

-- Function to paste/apply an NPC outfit
function PhaseToolkit.PasteNpcCustomisation()
	if not UnitExists("target") or UnitIsPlayer("target") then
		print("You need to target an NPC to apply customisations.")
		return
	end
	StaticPopup_Show("OPEN_OUTFIT_PASTE_POPUP")
end

-- Function to apply customizations from serialized data
function PhaseToolkit.ApplyNpcCustomisation(serializedData)
	if not serializedData or serializedData == "" then
		print("No data to apply.")
		return
	end

	if not UnitExists("target") or UnitIsPlayer("target") then
		print("You need to target an NPC to apply customisations.")
		return
	end

	-- Deserialize data
	local success, deserializedData = AceSerializer:Deserialize(serializedData)
	if not success or not deserializedData then
		print("Invalid outfit data format.")
		return
	end

	-- Build commands
	local commands = {}

	-- VERY IMPORTANT: Race and gender FIRST, otherwise everything else will fail!
	if deserializedData["_race"] and deserializedData["_gender"] then
		-- Use PhaseToolkit.Races to convert race name to ID
		local raceID = PhaseToolkit.Races[deserializedData["_race"]]
		if raceID then
			table.insert(commands, "ph f n out race " .. raceID)
			table.insert(commands, "ph f n out gender " .. deserializedData["_gender"])
		end
	end

	-- Apply name if available
	if deserializedData["_name"] and deserializedData["_name"] ~= "" then
		table.insert(commands, "ph f n name " .. deserializedData["_name"])
	end

	-- Apply customizations
	if deserializedData["_customizations"] and type(deserializedData["_customizations"]) == "table" then
		local customizationCount = 0
		for optionName, choiceValue in pairs(deserializedData["_customizations"]) do
			if optionName and choiceValue then
				table.insert(commands, "ph f n out custom " .. optionName .. " " .. choiceValue)
				customizationCount = customizationCount + 1
			end
		end
	end

	-- Apply normal equipment
	if deserializedData["_equipment"] and type(deserializedData["_equipment"]) == "table" then
		local equipmentCount = 0
		for slot, itemData in pairs(deserializedData["_equipment"]) do
			if itemData and itemData ~= "" then
				-- If it's a number (ID), use it directly, otherwise it's a link
				local itemToUse = tonumber(itemData) or itemData
				table.insert(commands, "ph f n out equip " .. itemToUse)
				equipmentCount = equipmentCount + 1
			end
		end
	end

	-- Apply weapons with special command
	if deserializedData["_weapons"] and type(deserializedData["_weapons"]) == "table" then
		local weaponCount = 0
		for weaponSlot, itemData in pairs(deserializedData["_weapons"]) do
			if itemData and itemData ~= "" then
				-- If it's a number (ID), use it directly, otherwise it's a link
				local itemToUse = tonumber(itemData) or itemData
				-- Use special command for weapons
				-- .ph fo np weapon ITEMID SLOT
				table.insert(commands, "ph fo np weapon " .. itemToUse .. " " .. weaponSlot)
				weaponCount = weaponCount + 1
			end
		end
	end

	-- Send all commands in sequential chain
	if #commands > 0 then
		sendAddonCommandChain(commands, function(success, allReturnMessages)
			if not success then
				print("Some commands failed during NPC customisation application.")

				-- Identify the command that failed
				local totalCommands = #commands
				local returnedMessages = (allReturnMessages and #allReturnMessages) or 0

				if returnedMessages < totalCommands then
					-- The chain stopped, the failed command is the next one
					local failedCommandIndex = returnedMessages
					if commands[failedCommandIndex] then
						print("Failed command [" .. failedCommandIndex .. "]: " .. commands[failedCommandIndex])
					end
				end
			else
				print("|cff00ff00All NPC customisation commands completed successfully!|r")
			end
		end, false)
	else
		print("No valid customisation data to apply.")
	end
end

-- Alternative function to apply directly from copied data
function PhaseToolkit.ApplyNpcCustomisationDirect(outfitInformation)
	if not outfitInformation then
		print("No outfit data provided.")
		return
	end

	if not UnitExists("target") or UnitIsPlayer("target") then
		print("You need to target an NPC to apply customisations.")
		return
	end

	-- Build commands directly from outfitInformation
	local commands = {}

	-- VERY IMPORTANT: Race and gender FIRST, otherwise everything else will fail!
	if outfitInformation["_race"] and outfitInformation["_gender"] then
		-- Use PhaseToolkit.Races to convert race name to ID
		local raceID = PhaseToolkit.Races[outfitInformation["_race"]]
		if raceID then
			table.insert(commands, "ph f n race " .. raceID)
			table.insert(commands, "ph f n gender " .. outfitInformation["_gender"])
			print("🧬 Race/Gender commands added first: " .. outfitInformation["_race"] .. " (ID:" .. raceID .. ") " .. outfitInformation["_gender"])
		end
	end

	-- Apply the name if available
	if outfitInformation["_name"] and outfitInformation["_name"] ~= "" then
		table.insert(commands, "ph f n name " .. outfitInformation["_name"])
	end

	-- Apply the customizations
	if outfitInformation["_customizations"] and type(outfitInformation["_customizations"]) == "table" then
		for optionName, choiceValue in pairs(outfitInformation["_customizations"]) do
			if optionName and choiceValue then
				table.insert(commands, "ph f n out custom " .. optionName .. " " .. choiceValue)
			end
		end
	end

	-- Apply normal equipment
	if outfitInformation["_equipment"] and type(outfitInformation["_equipment"]) == "table" then
		for slot, itemData in pairs(outfitInformation["_equipment"]) do
			if itemData and itemData ~= "" then
				-- If it's a number (ID), use it directly, otherwise it's a link
				local itemToUse = tonumber(itemData) or itemData
				table.insert(commands, "ph f n out equip " .. itemToUse)
			end
		end
	end

	-- Apply weapons with the special command
	if outfitInformation["_weapons"] and type(outfitInformation["_weapons"]) == "table" then
		for weaponSlot, itemData in pairs(outfitInformation["_weapons"]) do
			if itemData and itemData ~= "" then
				-- If it's a number (ID), use it directly, otherwise it's a link
				local itemToUse = tonumber(itemData) or itemData
				table.insert(commands, "ph fo np weapon " .. itemToUse .. " " .. weaponSlot)
			end
		end
	end

	-- Send the commands
	if #commands > 0 then
		sendAddonCommandChain(commands, function(success, allReturnMessages)
			if not success then
				print("Some commands failed during NPC customisation application.")

				-- Identify the command that failed
				local totalCommands = #commands
				local returnedMessages = (allReturnMessages and #allReturnMessages) or 0

				if returnedMessages < totalCommands then
					-- The chain stopped, the failed command is the next one
					local failedCommandIndex = returnedMessages
					if commands[failedCommandIndex] then
						print("Failed command [" .. failedCommandIndex .. "]: " .. commands[failedCommandIndex])
					end
				end
			else
				print("|cff00ff00All NPC customisation paste commands completed successfully!|r")
			end
		end, false)
		PhaseToolkit.pasteFrame:Hide()
	else
		print("No valid customisation data found in pasted text.")
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


-- ============================== MAIN FRAME ============================== --
PhaseToolkit.NombreDeLigne = 1
PhaseToolkit.HauteurDispoCustomFrame = ((PhaseToolkit.NombreDeLigne - 1) * 65)


PhaseToolkit.NPCCustomiserMainFrame = CreateFrame("Frame", "NPCCustomiserMainFrame", UIParent, "PortraitFrameTemplate")
ButtonFrameTemplateMinimizable_HidePortrait(PhaseToolkit.NPCCustomiserMainFrame)
NineSliceUtil.ApplyLayoutByName(PhaseToolkit.NPCCustomiserMainFrame.NineSlice, "EpsilonGoldBorderFrameTemplateNoPortrait")
EpsilonLib.Utils.NineSlice.CropNineSliceCorners(PhaseToolkit.NPCCustomiserMainFrame.NineSlice, 0.8, true)
EpsilonLib.Utils.NineSlice.CropNineSliceCorners(PhaseToolkit.NPCCustomiserMainFrame.NineSlice, 0.4)
EpsilonLib.Utils.NineSlice.SetBackgroundAsViewport(PhaseToolkit.NPCCustomiserMainFrame, PhaseToolkit.NPCCustomiserMainFrame.Bg)
PhaseToolkit.NPCCustomiserMainFrame.Bg:SetAlpha(0.975)
PhaseToolkit.NPCCustomiserMainFrame:SetToplevel(true)

PhaseToolkit.NPCCustomiserMainFrame:SetSize(260,70)
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
	local CommandsToSend = {}

	-- Collect all commands to send
	if(PhaseToolkit.itemCreatorData.itemName~=nil) then
		table.insert(CommandsToSend, "forge item set name "..itemLink..PhaseToolkit.itemCreatorData.itemName)
	end

	if(PhaseToolkit.itemCreatorData.itemDescription~=nil) then
		local maxDescriptionSize=238-(string.len("f i s de ")+string.len(itemLink))
		if(string.len(PhaseToolkit.itemCreatorData.itemDescription)>maxDescriptionSize) then
			-- Note: sendMessageInChunks will need to be handled separately
			table.insert(CommandsToSend, "f i s de "..itemLink..PhaseToolkit.itemCreatorData.itemDescription)
		else
			table.insert(CommandsToSend, "f i s de "..itemLink..PhaseToolkit.itemCreatorData.itemDescription)
		end
	end

	if(PhaseToolkit.itemClass~=nil and PhaseToolkit.itemClass~=-1) then
		table.insert(CommandsToSend, "forge item set class "..itemLink..PhaseToolkit.itemClass)
	end

	if(PhaseToolkit.itemCreatorData.itemSubClass~=nil and PhaseToolkit.itemCreatorData.itemSubClass~=-1) then
		--apparently if itemclass is 4 (armor) subclass 5 (cosmetic) isn't valid
		-- so we set to 0 (generic) instead to avoid error spam
		if(PhaseToolkit.itemClass==4 and PhaseToolkit.itemCreatorData.itemSubClass==5) then
			PhaseToolkit.itemCreatorData.itemSubClass=0
		end
		table.insert(CommandsToSend, "forge item set subclass "..itemLink..PhaseToolkit.itemCreatorData.itemSubClass)

	end

	if(PhaseToolkit.itemCreatorData.inventoryType~=nil and PhaseToolkit.itemCreatorData.inventoryType~=-1) then
		table.insert(CommandsToSend, "forge item set inventorytype "..itemLink..PhaseToolkit.itemCreatorData.inventoryType)
	end

	if(PhaseToolkit.itemCreatorData.itemDisplayLink~=nil and PhaseToolkit.itemCreatorData.itemDisplayLink~=-1) then
		table.insert(CommandsToSend, "forge item set display "..itemLink..PhaseToolkit.itemCreatorData.itemDisplayLink)
	end

	if(PhaseToolkit.itemCreatorData.bonding~=nil and PhaseToolkit.itemCreatorData.bonding~=-1) then
		table.insert(CommandsToSend, "forge item set bonding "..itemLink..PhaseToolkit.itemCreatorData.bonding)
	end

	if(PhaseToolkit.itemCreatorData.quality~=nil and PhaseToolkit.itemCreatorData.quality~=-1) then
		table.insert(CommandsToSend, "forge item set quality "..itemLink..PhaseToolkit.itemCreatorData.quality)
	end

	if(PhaseToolkit.itemCreatorData.sheath~=nil and PhaseToolkit.itemCreatorData.sheath~=-1) then
		table.insert(CommandsToSend, "forge item set sheath "..itemLink..PhaseToolkit.itemCreatorData.sheath)
	end

	if(PhaseToolkit.itemCreatorData.itemIconIdOrLink~=nil and PhaseToolkit.itemCreatorData.itemIconIdOrLink~=-1) then
		table.insert(CommandsToSend, "forge item set icon "..itemLink..PhaseToolkit.itemCreatorData.itemIconIdOrLink)
	end

	if(PhaseToolkit.itemCreatorData.stackable~=nil and PhaseToolkit.itemCreatorData.stackable~=-1) then
		local value=1
		if(PhaseToolkit.itemCreatorData.stackable==true) then
			if( PhaseToolkit.itemCreatorData.stackablecount and PhaseToolkit.itemCreatorData.stackablecount>0) then
				value=PhaseToolkit.itemCreatorData.stackablecount
			end
		end
		table.insert(CommandsToSend, "forge item set stackable "..itemLink..value)
	end

	if(PhaseToolkit.itemCreatorData.adder~=nil and PhaseToolkit.itemCreatorData.adder~=-1) then
		table.insert(CommandsToSend, "forge item set property adder"..itemLink..PhaseToolkit.itemCreatorData.adder)
	end

	if(PhaseToolkit.additemOption~=nil) then
		for _,option in ipairs(PhaseToolkit.additemOption) do
			local value=""
			if option.value==false then  value="off" else value="on" end
			table.insert(CommandsToSend, "forge item set property additem "..option.text..itemLink..value)
		end
	end

	if(PhaseToolkit.itemCreatorData.copy~=nil and PhaseToolkit.itemCreatorData.copy~=-1) then
		table.insert(CommandsToSend, "forge item set property copy"..itemLink..PhaseToolkit.itemCreatorData.copy)
	end

	if(PhaseToolkit.itemCreatorData.creator~=nil and PhaseToolkit.itemCreatorData.creator~=-1) then
		table.insert(CommandsToSend, "forge item set property creator"..itemLink..PhaseToolkit.itemCreatorData.creator)
	end

	if(PhaseToolkit.itemCreatorData.info~=nil and PhaseToolkit.itemCreatorData.info~=-1) then
		table.insert(CommandsToSend, "forge item set property info"..itemLink..PhaseToolkit.itemCreatorData.info)
	end

	if(PhaseToolkit.itemCreatorData.lookup~=nil and PhaseToolkit.itemCreatorData.lookup~=-1) then
		table.insert(CommandsToSend, "forge item set property lookup"..itemLink..PhaseToolkit.itemCreatorData.lookup)
	end

	if(PhaseToolkit.itemCreatorData.whitelistedChar~=nil and #PhaseToolkit.itemCreatorData.whitelistedChar>0) then
		for  i=1 , #PhaseToolkit.itemCreatorData.whitelistedChar do
			table.insert(CommandsToSend, "forge item set whitelist character add"..itemLink..PhaseToolkit.itemCreatorData.whitelistedChar[i])
		end
	end

	if(PhaseToolkit.itemCreatorData.whitelistedPhaseForMember~=nil and #PhaseToolkit.itemCreatorData.whitelistedPhaseForMember>0) then
		for  i=1 , #PhaseToolkit.itemCreatorData.whitelistedPhaseForMember do
			table.insert(CommandsToSend, "forge item set whitelist member add"..itemLink..PhaseToolkit.itemCreatorData.whitelistedPhaseForMember[i])
		end
	end

	if(PhaseToolkit.itemCreatorData.whitelistedPhaseForOfficer~=nil and #PhaseToolkit.itemCreatorData.whitelistedPhaseForOfficer>0) then
		for  i=1 , #PhaseToolkit.itemCreatorData.whitelistedPhaseForOfficer do
			table.insert(CommandsToSend, "forge item set whitelist officer add"..itemLink..PhaseToolkit.itemCreatorData.whitelistedPhaseForOfficer[i])
		end
	end

	-- Use EpsilonLib's sendAddonCommandChain to send all commands in sequence
	if #CommandsToSend > 0 then
		sendAddonCommandChain(CommandsToSend, function(success, allReturnMessages)
			-- Command chain completed
			PhaseToolkit.itemCreatorData.itemLink=nil

			-- Reset everything after all commands are done
			for key in pairs(PhaseToolkit.itemCreatorData) do
				PhaseToolkit.itemCreatorData[key] = nil
			end

			if success then
				print("Item Forging done !\nyou can use your item !")
			else
				if(PhaseToolkit.debugMode) then
					print("Item Forging had some issues. Here are the errors:")
					dump(allReturnMessages)
				else
					print("Item Forging had some issues. Run : /run PhaseToolkit.debugMode=true\nThen try again and check the chat for errors, if needed create a bug report.")
				end
			end
			ContainerFrame_UpdateAll()
		end, false)
	else
		-- No commands to send, just clean up
		PhaseToolkit.itemCreatorData.itemLink=nil
		for key in pairs(PhaseToolkit.itemCreatorData) do
			PhaseToolkit.itemCreatorData[key] = nil
		end
	end

end

function GetItemIDFromLink(itemLink)
    if not itemLink then return nil end
    -- Extract the item ID from the link
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

local function getClassFromClassString(classString)
	for _, class in ipairs(PhaseToolkit.itemClass) do
		if class.name == classString then
			return class.classId
		end
	end
	return nil -- Return nil if not found
end

local function getSubClassCompTableFromClassId(classID)
	local retour = nil
	if classID then
		if classID == 2 then
			retour = PhaseToolkit.itemSubtypeToSubclassIdWeapon
		elseif classID == 4 then
			retour = PhaseToolkit.itemSubtypeToSubclassIdArmor
		elseif classID == 15 then
			retour = PhaseToolkit.itemSubtypeToSubclassIdMisc
		elseif classID == 13 then
			retour = PhaseToolkit.itemSubtypeToSubclassIdKey
		end
	end
	return retour
end

local function getSubClassFromSubClassString(subclassString,classID)
	local compTable = getSubClassCompTableFromClassId(classID)
	if compTable then
		for compString,value in pairs(compTable) do
			print("Comparing: "..compString.." with "..subclassString)
			if compString == subclassString then
				return value
			end
		end
	end
	return nil -- Return nil if not found
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
	tooltipScanner:SetOwner(WorldFrame, "ANCHOR_NONE") -- Make it invisible
	tooltipScanner:SetHyperlink("item:" .. itemId) -- Load the item by its ID
	PhaseToolkit.ModifyItemData=false

    for i = 1, tooltipScanner:NumLines() do
        local leftText = _G["TooltipScannerTextLeft" .. i]
        local rightText = _G["TooltipScannerTextRight" .. i]

        -- Add left text
        if leftText and leftText:GetText() then
            table.insert(content, leftText:GetText())
        end

        -- Add right text
        if rightText and rightText:GetText() then
            table.insert(content, rightText:GetText())
        end
    end
	classID = getClassFromClassString(itemType)
	if(classID~=nil) then
		PhaseToolkit.itemCreatorData.selectedItemClass=classID
	end

	subclassID = getSubClassFromSubClassString(itemSubType,classID)
	if(subclassID~=nil) then
		PhaseToolkit.itemCreatorData.selectedItemSubClass=subclassID
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
		PhaseToolkit.DeployingFrame.itemForgeDescriptionFrame:SetText(description)
	end


	if(inventoryTypeLabel~=nil and inventoryTypeLabel~="") then
		if(string.lower(inventoryTypeLabel):find("one")~=nil) then
			inventoryTypeLabel="Weapon"
		end
		local position =getInventoryTypePosition(inventoryTypeLabel);
		if(position~=nil) then
			PhaseToolkit.itemCreatorData.selectedInventoryType=position
		end
	end

	if(itemQuality~=nil and itemQuality~="") then
		local quality = getQualityObject(itemQuality)
		if(quality~=nil) then
			PhaseToolkit.itemCreatorData.selectedItemQuality=quality.qualityId
		end
	end

	if(isBindingDetected) then
		local binding = getBindingObject(content[3])
		if(binding~=nil) then
			PhaseToolkit.itemCreatorData.selectedItemBonding=binding
		end
	end

	PhaseToolkit.DeployingFrame.itemForgeNameInput:SetText(itemName)

	C_Timer.After(1, function()
		PhaseToolkit.ModifyItemData=true
	  end)

	PhaseToolkit.refreshAllItemCreatorScrollFrame()

end



-- DeployingFrameCreation
local animClipFrame = CreateFrame("Frame", nil, PhaseToolkit.NPCCustomiserMainFrame);
animClipFrame:SetSize(PhaseToolkit.NPCCustomiserMainFrame:GetWidth()*3, PhaseToolkit.deployingFrameBaseSize);
animClipFrame:SetPoint("TOP", PhaseToolkit.NPCCustomiserMainFrame, "BOTTOM", 0, 10);
animClipFrame:SetClipsChildren(true)
-- hook script down below to ensure that we follow sizing on DeployingFrame

PhaseToolkit.DeployingFrame = CreateFrame("Frame", nil, animClipFrame, "PortraitFrameTemplate");
PhaseToolkit.DeployingFrame:SetSize(PhaseToolkit.NPCCustomiserMainFrame:GetWidth(), PhaseToolkit.deployingFrameBaseSize);
PhaseToolkit.DeployingFrame:SetPoint("TOP", PhaseToolkit.NPCCustomiserMainFrame, "BOTTOM", 0, 60);
ButtonFrameTemplateMinimizable_HidePortrait(PhaseToolkit.DeployingFrame)
NineSliceUtil.ApplyLayoutByName(PhaseToolkit.DeployingFrame.NineSlice, "EpsilonGoldBorderFrameTemplateNoPortrait")
EpsilonLib.Utils.NineSlice.CropNineSliceCorners(PhaseToolkit.DeployingFrame.NineSlice, 0.8, true)
EpsilonLib.Utils.NineSlice.CropNineSliceCorners(PhaseToolkit.DeployingFrame.NineSlice, 0.4)
EpsilonLib.Utils.NineSlice.SetBackgroundAsViewport(PhaseToolkit.DeployingFrame, PhaseToolkit.DeployingFrame.Bg)
PhaseToolkit.DeployingFrame.NineSlice.TopEdge:Hide()
PhaseToolkit.DeployingFrame.NineSlice.TopLeftCorner:Hide()
PhaseToolkit.DeployingFrame.NineSlice.TopRightCorner:Hide()
PhaseToolkit.DeployingFrame.TitleBg:Hide()
PhaseToolkit.DeployingFrame.CloseButton:Hide()
PhaseToolkit.DeployingFrame:Hide()
PhaseToolkit.DeployingFrame.isDeployed = false;
PhaseToolkit.DeployingFrame.OffsetFromTop=-40;
PhaseToolkit.DeployingFrame.activeDeployingContext = nil
PhaseToolkit.DeployingFrame.lastDeployingContext = "npc_forge"
PhaseToolkit.DeployingFrame.pendingDeployingContext = nil

hooksecurefunc(PhaseToolkit.DeployingFrame, "SetSize", function(self, ...)
    animClipFrame:SetSize(...)
end)
hooksecurefunc(PhaseToolkit.DeployingFrame, "SetHeight", function(self, ...)
    animClipFrame:SetHeight(...)
end)

--DeployingFrame Anim

local function createDeployRetractAnimsForFrame(frame, offsetX, offsetY, scripts)
	local panel, OFFSET_X, OFFSET_Y = frame, offsetX, offsetY

	if not panel.animGroupDeploy then
		local AnimationGroup = panel.animGroupDeploy or panel:CreateAnimationGroup("DeployAnimation");
		panel.animGroupDeploy = AnimationGroup

		local snapToStart = AnimationGroup.SnapToStart or AnimationGroup:CreateAnimation("Translation")
		AnimationGroup.SnapToStart = snapToStart
		snapToStart:SetOrder(1)
		snapToStart:SetOffset(OFFSET_X, OFFSET_Y)
		snapToStart:SetDuration(0)

		local fadeIn = AnimationGroup.FadeIn or AnimationGroup:CreateAnimation("Alpha");
		AnimationGroup.FadeIn = fadeIn
		fadeIn:SetOrder(2);
		fadeIn:SetFromAlpha(0);
		fadeIn:SetToAlpha(1);
		fadeIn:SetDuration(0.5);
		fadeIn:SetSmoothing("OUT")

		local slideIn = AnimationGroup.SlideIn or AnimationGroup:CreateAnimation("Translation")
		AnimationGroup.SlideIn = slideIn
		slideIn:SetOrder(2)
		slideIn:SetOffset(-OFFSET_X, -OFFSET_Y)
		slideIn:SetDuration(0.5)
		slideIn:SetSmoothing("OUT")

		if scripts.onPlayDeploy then
			AnimationGroup:SetScript("OnPlay", scripts.onPlayDeploy);
		end
		if scripts.onFinishedDeploy then
			AnimationGroup:SetScript("OnFinished", scripts.onFinishedDeploy);
		end
	end

	if not panel.animGroupRetract then
		local AnimationGroup = panel.animGroupRetract or panel:CreateAnimationGroup("RetractAnimation");
		panel.animGroupRetract = AnimationGroup

		local fadeOut = AnimationGroup:CreateAnimation("Alpha");
		fadeOut:SetOrder(1);
		fadeOut:SetFromAlpha(1);
		fadeOut:SetToAlpha(0);
		fadeOut:SetDuration(0.5);
		fadeOut:SetSmoothing("IN")

		local slideOut = AnimationGroup.SlideOut or AnimationGroup:CreateAnimation("Translation")
		AnimationGroup.SlideOut = slideOut
		slideOut:SetOrder(1)
		slideOut:SetOffset(OFFSET_X, OFFSET_Y)
		slideOut:SetDuration(0.5)
		slideOut:SetSmoothing("IN")

		if scripts.onPlayRetract then
			AnimationGroup:SetScript("OnPlay", scripts.onPlayRetract);
		end
		if scripts.onFinishedRetract then
			AnimationGroup:SetScript("OnFinished", scripts.onFinishedRetract);
		end
	end

end

createDeployRetractAnimsForFrame(PhaseToolkit.DeployingFrame, 0, 60, {
	onPlayDeploy = function()
		animClipFrame:SetClipsChildren(true)
		PhaseToolkit.DeployingFrame:Show()
		PhaseToolkit.DeployingFrame:SetFrameLevel(PhaseToolkit.NPCCustomiserMainFrame:GetFrameLevel()-1)
		hideContext(PhaseToolkit.DeployingFrame.activeDeployingContext)
	end,
	onFinishedDeploy = function()
		if(PhaseToolkit.context and #PhaseToolkit.context>0) then
			showContext(PhaseToolkit.context)
		end
		animClipFrame:SetClipsChildren(false)
		PhaseToolkit.DeployingFrame:SetFrameLevel(PhaseToolkit.NPCCustomiserMainFrame:GetFrameLevel()-1)
		PhaseToolkit.DeployingFrame.isDeployed = true;
	end,
	onPlayRetract = function()
		animClipFrame:SetClipsChildren(true)
		PhaseToolkit.DeployingFrame:SetFrameLevel(PhaseToolkit.NPCCustomiserMainFrame:GetFrameLevel()-1)
		if(PhaseToolkit.context and #PhaseToolkit.context>0) then
			hideContext(PhaseToolkit.context)
		end
	end,
	onFinishedRetract = function()
		animClipFrame:SetClipsChildren(false)
		PhaseToolkit.DeployingFrame:SetFrameLevel(PhaseToolkit.NPCCustomiserMainFrame:GetFrameLevel()-1)
        PhaseToolkit.DeployingFrame:Hide()
        PhaseToolkit.DeployingFrame.isDeployed = false;
	end,
})

PhaseToolkit.DeployingFrame.PlayDeployAnimation = function()
	local panel = PhaseToolkit.DeployingFrame
	local AnimationGroup = panel.animGroupDeploy
	AnimationGroup:Play();
end

PhaseToolkit.DeployingFrame.PlayRetractAnimation = function()
	local panel = PhaseToolkit.DeployingFrame
	local AnimationGroup = panel.animGroupRetract
    AnimationGroup:Play();
end

PhaseToolkit.DeployingFrame.handleDeployingFrameState = function(self)
	if self.isDeployed then
		self:PlayRetractAnimation();
	else
		self:PlayDeployAnimation();
	end
end

local function Lerp(a, b, t) return a + (b - a) * t end

local function SetAtlasVerticalHalf(tex, atlasName, side) -- "LEFT" ou "RIGHT"
    tex:SetAtlas(atlasName, true) -- IMPORTANT: d'abord SetAtlas

    -- 8 coords (UL, LL, UR, LR)
    local ulx, uly, llx, lly, urx, ury, lrx, lry = tex:GetTexCoord()

    -- milieu entre gauche et droite (sur le bord haut et bas)
    local mtx, mty = Lerp(ulx, urx, 0.5), Lerp(uly, ury, 0.5)
    local mbx, mby = Lerp(llx, lrx, 0.5), Lerp(lly, lry, 0.5)

    if side == "LEFT" then
        -- UL, LL, (milieu haut), (milieu bas)
        tex:SetTexCoord(ulx, uly, llx, lly, mtx, mty, mbx, mby)
    else
        -- (milieu haut), (milieu bas), UR, LR
        tex:SetTexCoord(mtx, mty, mbx, mby, urx, ury, lrx, lry)
    end
end

local function activateNpcCustomHighlights()
	if PhaseToolkit.DeployingFrame.CustomCategoryButtons then
		for _, button in ipairs(PhaseToolkit.DeployingFrame.CustomCategoryButtons) do
			button:SetScript("OnEnter",function()
				button.Highlight:Show()
			end)
		end
	end
end

local function getSelectedGender()
	local gender = "MALE"
	if (PhaseToolkit.DeployingFrame.NpcGenderSlider:GetValue() == 1) then
        gender = "FEMALE"
    end
	return gender
end

local function buildCustomDatasetForCategory(category)
	if (PhaseToolkit.SelectedRace) then
		local raceName= PhaseToolkit.SelectedRace.name
		local categoryField = raceGenderCategory[raceName][getSelectedGender()]["CATEGORY"][category]
		local customs = PhaseToolkit.InfoCustom[raceName][getSelectedGender():lower()]
		local dataset = {}
		-- We get rid of spaces, and uppercase letter
		local concatFields = table.concat(categoryField,","):gsub(" ",""):lower()
		local fields = strsplittable(",",concatFields)
		for fieldName,fieldValue in pairs (customs) do
			local cleanName = string.gsub(fieldName,"_",""):lower()
			if(fields and tContains(fields,cleanName))then
				dataset[fieldName]=fieldValue
			end
		end
		return dataset
	else
		return nil
	end
end

local function getPaddingForLanguage()
	local currentLang= PhaseToolKitConfig["CurrentLang"]
	local padding = 0
	if (currentLang == "English") then
		padding = 0
	elseif (currentLang == "French") then
		padding = 150
	elseif (currentLang == "Spanish") then
		padding = 50
	elseif (currentLang == "German") then
		padding = 50
	elseif (currentLang == "Portuguese") then
		padding = 50
	elseif (currentLang == "Russian") then
		padding = 50
	end
	return padding
end

local function CustomizeNpc(fieldName,value)
	if(PhaseToolkit.CustomFieldLocks[fieldName]) then
		return
	end
	if( UnitExists("target") and UnitIsPlayer("target")==false) then
		sendAddonCmd("phase forge npc out custom "..fieldName.." "..value, nil)
	end
end

local function isCategoryExistingOnRace()
	if(PhaseToolkit.SelectedRace and PhaseToolkit.SelectedCategory)then
		local raceName= PhaseToolkit.SelectedRace.name
		local category=PhaseToolkit.SelectedCategory.LinkedCategory
		return raceGenderCategory[raceName][getSelectedGender()]["CATEGORY"][category]~=nil
	else
		return false
	end
end

local function deployCustomPanel()
	local AnimationGroup = PhaseToolkit.customPanel:CreateAnimationGroup("DeployRacePanelAnimation");

	local fadeIn = AnimationGroup:CreateAnimation("Alpha");
	fadeIn:SetOrder(1);
	fadeIn:SetFromAlpha(0);
	fadeIn:SetToAlpha(1);
	fadeIn:SetDuration(0.5);
	fadeIn:SetSmoothing("OUT")

	local scaleUp= AnimationGroup:CreateAnimation("Scale");
	scaleUp:SetOrder(1);
	scaleUp:SetFromScale(0.0,1.0);
	scaleUp:SetToScale(1.0,1.0);
	scaleUp:SetDuration(0.5);
	scaleUp:SetSmoothing("OUT")
	scaleUp:SetOrigin("LEFT",0,0)

	AnimationGroup:SetScript("OnPlay", function()
		hideContent(PhaseToolkit.customPanel.contentToManage)
		hideContent(PhaseToolkit.customPanel.activeCells)
		PhaseToolkit.customPanel:Show()
	end);

	AnimationGroup:SetScript("OnFinished", function()
		showContent(PhaseToolkit.customPanel.contentToManage)
		-- FIX: on ne montre QUE les cellules actives du dataset courant,
		-- pas toutes les cellules jamais créées (sinon des cellules d'un
		-- dataset précédent, plus grand, réapparaissent à la réouverture).
		showContent(PhaseToolkit.customPanel.activeCells)
	end);

	AnimationGroup:Play();
end

local function retractCustomPanel()
	local AnimationGroup = PhaseToolkit.customPanel:CreateAnimationGroup("DeployRacePanelAnimation");

	local fadeIn = AnimationGroup:CreateAnimation("Alpha");
	fadeIn:SetOrder(1);
	fadeIn:SetFromAlpha(1);
	fadeIn:SetToAlpha(0);
	fadeIn:SetDuration(0.5);
	fadeIn:SetSmoothing("OUT")

	local scaleUp= AnimationGroup:CreateAnimation("Scale");
	scaleUp:SetOrder(1);
	scaleUp:SetFromScale(1.0,1.0);
	scaleUp:SetToScale(0.0,1.0);
	scaleUp:SetDuration(0.5);
	scaleUp:SetSmoothing("OUT")
	scaleUp:SetOrigin("LEFT",0,0)

	AnimationGroup:SetScript("OnPlay", function()
		hideContent(PhaseToolkit.customPanel.contentToManage)
		hideContent(PhaseToolkit.customPanel.activeCells)
	end);

	AnimationGroup:SetScript("OnFinished", function()
		PhaseToolkit.customPanel:Hide()
	end);

	AnimationGroup:Play();
end


local function buildCustomPanelForDataset(dataset,category,refreshOnly)
	local paddingForLangageReason=getPaddingForLanguage()
	if(PhaseToolkit.DeployingFrame )then
		local panelContent = (PhaseToolkit.customPanel and PhaseToolkit.customPanel.contentToManage) or {}
		if(not PhaseToolkit.customPanel) then
			local Panel = CreateFrame("Frame", nil, PhaseToolkit.DeployingFrame, "PortraitFrameTemplate");
			Panel:SetSize(PhaseToolkit.DeployingFrame:GetWidth()+200, 245);
			Panel:SetPoint("LEFT", PhaseToolkit.DeployingFrame, "RIGHT", 0, -27.5);
			ButtonFrameTemplateMinimizable_HidePortrait(Panel)
			NineSliceUtil.ApplyLayoutByName(Panel.NineSlice, "EpsilonGoldBorderFrameTemplateNoPortrait")
			EpsilonLib.Utils.NineSlice.CropNineSliceCorners(Panel.NineSlice, 0.8, true)
			EpsilonLib.Utils.NineSlice.CropNineSliceCorners(Panel.NineSlice, 0.4)
			EpsilonLib.Utils.NineSlice.SetBackgroundAsViewport(Panel, Panel.Bg)
			Panel:SetFrameStrata("LOW")
			local titleBgColor = Panel:CreateTexture(nil, "BACKGROUND")
			local color = CreateColorFromHexString("80FF7100")
			titleBgColor:SetPoint("TOPLEFT", Panel.TitleBg)
			titleBgColor:SetPoint("BOTTOMRIGHT", Panel.TitleBg, -0, 0)
			titleBgColor:SetColorTexture(color:GetRGBA())
			Panel.TitleBgColor = titleBgColor

			Panel.gridMaster =CreateFrame("Frame", nil, Panel)
			Panel.gridMaster:SetPoint("TOPLEFT", Panel, "TOPLEFT", 10, -5)
			Panel.gridMaster:SetPoint("BOTTOMRIGHT", Panel, "BOTTOMRIGHT", -10, 5)
			Panel.gridMaster:SetFrameLevel(Panel:GetFrameLevel()+1)
			Panel.gridMaster:SetSize(100,100)
			Panel.TitleText:SetText("Category : "..category)
			Panel.randomizeCategoryButton = CreateFrame("Button", nil, Panel, "UIPanelButtonTemplate")
			Panel.randomizeCategoryButton:SetSize(18, 18)
			Panel.randomizeCategoryButton:SetPoint("RIGHT", Panel.TitleText, "LEFT", -4, 0)
			Panel.randomizeCategoryButton.icon  = Panel.randomizeCategoryButton:CreateTexture(nil, "ARTWORK")
			Panel.randomizeCategoryButton.icon:SetAllPoints(Panel.randomizeCategoryButton)
			Panel.randomizeCategoryButton.icon:SetAtlas("charactercreate-icon-dice")
			Panel.randomizeCategoryButton:SetScript("OnClick", function(self)
				local parentPanel = self:GetParent()
				if(not parentPanel.currentDataset) then
					return
				end

				for fieldName, maxValue in pairs(parentPanel.currentDataset) do
					local maxNumericValue = tonumber(maxValue)
					if(maxNumericValue and maxNumericValue >= 1 and not PhaseToolkit.CustomFieldLocks[fieldName]) then
						local randomValue = math.random(1, maxNumericValue)
						CustomizeNpc(fieldName, randomValue)
						if(parentPanel.fieldCellByName and parentPanel.fieldCellByName[fieldName] and parentPanel.fieldCellByName[fieldName].modifyPart and parentPanel.fieldCellByName[fieldName].modifyPart.editBox) then
							parentPanel.fieldCellByName[fieldName].modifyPart.editBox:SetNumber(randomValue)
						end
					end
				end
			end)
			-- Uniquement le contenu STATIQUE ici (toujours visible dès que le panel est ouvert)
			tinsert(panelContent, Panel.randomizeCategoryButton)
			tinsert(panelContent, Panel.gridMaster)
			tinsert(panelContent, Panel.TitleText)

			PhaseToolkit.RegisterTooltip(Panel.randomizeCategoryButton, "Randomize this category")
			PhaseToolkit.customPanel = Panel
			deployCustomPanel()
		else
			if( PhaseToolkit.customPanel:IsShown() and not refreshOnly) then
			--if the panel is visible )
				if(PhaseToolkit.SelectedCategory and PhaseToolkit.SelectedCategory.LinkedCategory == category and not refreshOnly)then
					-- if we click on the same category, we hide the panel
					retractCustomPanel()
				else
					-- if we click on another category while the panel is visible, we update it with the new category
					PhaseToolkit.customPanel.TitleText:SetText("Category : "..category)
				end
			else
				-- if we click on another category while the panel is hidden, we show it with the new category
				deployCustomPanel()
				PhaseToolkit.customPanel.TitleText:SetText("Category : "..category)
			end
		end

		--now that we have the visibility of the panel handled we need to update the content now !
		--everything will be in a grid 3x3 cause max is 9 fields per category, so we need to calculate the size of each cell based on the number of fields
		PhaseToolkit.customPanel.currentDataset = dataset
		local datasetSize = 0
		for k,v in pairs(dataset) do
			datasetSize = datasetSize +1
		end
		local numColumns = math.min(3, datasetSize)
		local numRows = math.ceil(datasetSize/numColumns)
		local cellWidth = (PhaseToolkit.customPanel.gridMaster:GetWidth() - (numColumns -1)*5) / numColumns
		local cellHeight = (PhaseToolkit.customPanel.gridMaster:GetHeight() - (numRows -1)*5) / numRows
		local index = 0

		local function bindCustomCellHandlers(cell, maxValue)
			cell.modifyPart.editBox:SetScript("OnEnterPressed", function()
				if(PhaseToolkit.CustomFieldLocks[cell.fieldToModify]) then
					cell.modifyPart.editBox:ClearFocus()
					return
				end
				local text = cell.modifyPart.editBox:GetText()
				local number = tonumber(text)
				if number and number >= 1 and number <= maxValue then
					CustomizeNpc(cell.fieldToModify, number)
					cell.modifyPart.editBox:ClearFocus()
				end
			end)

			cell.modifyPart.minusButton:SetScript("OnClick", function()
				if(PhaseToolkit.CustomFieldLocks[cell.fieldToModify]) then
					return
				end
				local currentValue = cell.modifyPart.editBox:GetNumber()
				if(cell.modifyPart.editBox:GetNumber() == 1)then
					currentValue = maxValue
					cell.modifyPart.editBox:SetNumber(currentValue)
					CustomizeNpc(cell.fieldToModify, currentValue)
					return
				end
				if currentValue > 1 then
					cell.modifyPart.editBox:SetNumber(currentValue - 1)
					CustomizeNpc(cell.fieldToModify, currentValue - 1)
				end
			end)

			cell.modifyPart.plusButton:SetScript("OnClick", function()
				if(PhaseToolkit.CustomFieldLocks[cell.fieldToModify]) then
					return
				end
				local currentValue = cell.modifyPart.editBox:GetNumber()
				if(cell.modifyPart.editBox:GetNumber() == maxValue)then
					currentValue = 1
					cell.modifyPart.editBox:SetNumber(currentValue )
					CustomizeNpc(cell.fieldToModify, currentValue )
					return
				end
				if currentValue < maxValue then
					cell.modifyPart.editBox:SetNumber(currentValue + 1)
					CustomizeNpc(cell.fieldToModify, currentValue + 1)
				end
			end)

			cell.modifyPart.randomButton:SetScript("OnClick", function()
				if(PhaseToolkit.CustomFieldLocks[cell.fieldToModify]) then
					return
				end
				local randomValue = math.random(1, maxValue)
				cell.modifyPart.editBox:SetNumber(randomValue)
				CustomizeNpc(cell.fieldToModify, randomValue)
			end)

			cell.modifyPart.lockButton:SetScript("OnClick", function()
				PhaseToolkit.CustomFieldLocks[cell.fieldToModify] = not PhaseToolkit.CustomFieldLocks[cell.fieldToModify]
				if(cell.modifyPart.UpdateLockState) then
					cell.modifyPart.UpdateLockState()
				end
			end)

			cell.modifyPart.UpdateLockState = function()
				local isLocked = PhaseToolkit.CustomFieldLocks[cell.fieldToModify] == true
				if(isLocked) then
					cell.modifyPart.editBox:Disable()
					cell.modifyPart.editBox:ClearFocus()
				else
					cell.modifyPart.editBox:Enable()
				end
				cell.modifyPart.minusButton:SetEnabled(not isLocked)
				cell.modifyPart.plusButton:SetEnabled(not isLocked)
				cell.modifyPart.randomButton:SetEnabled(not isLocked)

				local alpha = isLocked and 0.4 or 1
				cell.modifyPart.minusButton:SetAlpha(alpha)
				cell.modifyPart.plusButton:SetAlpha(alpha)
				cell.modifyPart.randomButton:SetAlpha(alpha)
				if (cell.modifyPart.lockButton.icon) then
					cell.modifyPart.lockButton.icon:SetDesaturated(not isLocked)
				end
				if (not isLocked) then
					cell.modifyPart.lockButton.icon:SetVertexColor(0.5, 0.5, 0.5, 1)
				else
					cell.modifyPart.lockButton.icon:SetVertexColor(1, 1, 1, 1)
				end
			end

			if(cell.modifyPart.UpdateLockState) then
				cell.modifyPart.UpdateLockState()
			end
		end

		--We need to create the cell if it doesn't exist, else we just update cell content, to avoid creating new frames every time we click on a category
		for i = 0, 8 do
			local cellName = "Cell"..i
			local cell = PhaseToolkit.customPanel.gridMaster[cellName]
			if(cell)then
				cell:Hide()
			end
		end

		local sortedFieldNames = {}
		for fieldName in pairs(dataset) do
			tinsert(sortedFieldNames, fieldName)
		end
		table.sort(sortedFieldNames)

		local fieldCellByName = {}
		-- FIX: liste des cellules effectivement utilisées par CE dataset,
		-- utilisée par deployCustomPanel pour ne réafficher qu'elles.
		local activeCells = {}

		for _, fieldName in ipairs(sortedFieldNames) do
			local fieldValue = dataset[fieldName]
			local row = math.floor(index/numColumns)
			local column = index % numColumns
			local cellName = "Cell"..index
			local cell = PhaseToolkit.customPanel.gridMaster[cellName]
			local isNewCell = (cell == nil)

			if(isNewCell)then
				cell = CreateFrame("Frame", nil, PhaseToolkit.customPanel.gridMaster)
				cell.Text = cell:CreateFontString(nil, "OVERLAY", "GameFontNormal")
				cell.Text:SetPoint("CENTER", cell, "CENTER", 0, 0)
				PhaseToolkit.customPanel.gridMaster[cellName]=cell
				cell.modifyPart={}
				cell.modifyPart.background = cell:CreateTexture(nil, "BACKGROUND")
				cell.modifyPart.background:SetPoint("TOP",cell.Text,"BOTTOM",0,-2)
				cell.modifyPart.editBox = CreateFrame("EditBox", nil, cell, "InputBoxTemplate")
				cell.modifyPart.editBox:SetPoint("CENTER",cell.modifyPart.background,"CENTER",-10,0)
				cell.modifyPart.editBox:SetSize(30, 20)
				cell.modifyPart.editBox:SetAutoFocus(false)
				cell.modifyPart.maxValue = cell:CreateFontString(nil, "OVERLAY", "GameFontNormal")
				cell.modifyPart.maxValue:SetPoint("LEFT", cell.modifyPart.editBox, "RIGHT", 5, 0)

				cell.modifyPart.minusButton = CreateFrame("Button", nil, cell)
				cell.modifyPart.minusButton:SetSize(20, 20)
				cell.modifyPart.minusButton:SetPoint("RIGHT", cell.modifyPart.editBox, "LEFT", -5, 0)
				cell.modifyPart.minusButton.Icon = cell.modifyPart.minusButton:CreateTexture(nil, "OVERLAY")
				cell.modifyPart.minusButton.Icon:SetAtlas("charactercreate-customize-backbutton")
				cell.modifyPart.minusButton.Icon:SetSize(20, 20)
				cell.modifyPart.minusButton.Icon:SetPoint("CENTER", cell.modifyPart.minusButton, "CENTER", 0, 0)

				cell.modifyPart.plusButton = CreateFrame("Button", nil, cell)
				cell.modifyPart.plusButton:SetSize(20, 20)
				cell.modifyPart.plusButton:SetPoint("LEFT", cell.modifyPart.editBox, "RIGHT",30, 0)
				cell.modifyPart.plusButton.Icon = cell.modifyPart.plusButton:CreateTexture(nil, "OVERLAY")
				cell.modifyPart.plusButton.Icon:SetAtlas("charactercreate-customize-nextbutton")
				cell.modifyPart.plusButton.Icon:SetSize(20, 20)
				cell.modifyPart.plusButton.Icon:SetPoint("CENTER", cell.modifyPart.plusButton, "CENTER", 0, 0)

				cell.modifyPart.randomButton = CreateFrame("Button", nil, cell, "UIPanelButtonTemplate")
				cell.modifyPart.randomButton:SetSize(18, 18)
				cell.modifyPart.randomButton:SetPoint("RIGHT",cell.Text, "LEFT", -3, 0)
				cell.modifyPart.randomButton.icon = cell.modifyPart.randomButton:CreateTexture(nil, "ARTWORK")
				cell.modifyPart.randomButton.icon:SetAllPoints(cell.modifyPart.randomButton)
				cell.modifyPart.randomButton.icon:SetAtlas("charactercreate-icon-dice")
				cell.modifyPart.randomButton.icon:SetSize(15, 15)
				PhaseToolkit.RegisterTooltip(cell.modifyPart.randomButton, "Randomize this field")

				cell.modifyPart.lockButton = CreateFrame("Button", nil, cell, "UIPanelButtonTemplate")
				cell.modifyPart.lockButton:SetSize(18, 18)
				cell.modifyPart.lockButton:SetPoint("LEFT", cell.Text, "RIGHT", 3, 0)
				cell.modifyPart.lockButton.icon = cell.modifyPart.lockButton:CreateTexture(nil, "ARTWORK")
				cell.modifyPart.lockButton.icon:SetAllPoints(cell.modifyPart.lockButton)
				cell.modifyPart.lockButton.icon:SetAtlas("AdventureMapIcon-Lock")
				cell.modifyPart.lockButton.icon:SetSize(15, 15)
				cell.modifyPart.lockButton.icon:SetDesaturated(true)
				PhaseToolkit.RegisterTooltip(cell.modifyPart.lockButton, "Lock/unlock this field")

				-- FIX: on ne met plus les cellules dans panelContent/contentToManage,
				-- sinon deployCustomPanel les réaffiche toutes indistinctement.
			else
				cell:Show()
			end

			cell:SetSize(cellWidth, cellHeight)
			cell:SetPoint("TOPLEFT", PhaseToolkit.customPanel.gridMaster, "TOPLEFT", column*(cellWidth+5), -row*(cellHeight+5))
			cell.modifyPart.background:SetSize(cellWidth, 35)
			cell.modifyPart.background:SetAtlas("charactercreate-customize-dropdownbox-hover")

			cell.fieldToModify = fieldName
			cell.modifyPart.maxValue:SetText("/ "..fieldValue)
			cell.modifyPart.editBox:SetNumber(1)

			bindCustomCellHandlers(cell, fieldValue)

			local displayText = PhaseToolkit.CurrentLang[fieldName] or fieldName
			local numberOfWords = #strsplittable(" ", displayText)
			if(numberOfWords>=2)then
				local text = string.gsub(displayText," ","\n")
				cell.Text:SetText(text)
				if(numberOfWords==3)then
					cell.Text:SetPoint("CENTER", cell, "CENTER", 0, 14)
				elseif (numberOfWords==2)then
					cell.Text:SetPoint("CENTER", cell, "CENTER", 0, 7.5)
				end
			else
				cell.Text:SetText(displayText)
				cell.Text:SetPoint("CENTER", cell, "CENTER", 0, 0)
			end

			index = index + 1
			fieldCellByName[fieldName] = cell
			tinsert(activeCells, cell)
		end

		PhaseToolkit.customPanel.fieldCellByName = fieldCellByName
		PhaseToolkit.customPanel.contentToManage = panelContent
		-- FIX: la liste des cellules actives est remplacée à chaque appel,
		-- donc elle reflète toujours exactement le dataset courant.
		PhaseToolkit.customPanel.activeCells = activeCells
	end
end

local function getCategoryFromLinkedCategory(linked)
	for _, button in pairs(PhaseToolkit.DeployingFrame.CustomCategoryButtons) do
		if(button.LinkedCategory == linked)then
			return button
		end
	end
end

local function getAssociativeTableCount(table)
	local count = 0
	for _ in pairs(table) do
		count = count + 1
	end
	return count
end

local function updateCustomCategoryButtons()
	local selectedRace = PhaseToolkit.SelectedRace
	if selectedRace and selectedRace.raceid then
		if PhaseToolkit.DeployingFrame.CustomCategoryButtons then
			local raceNameKey=selectedRace.name
			local categoriesForRace =  raceGenderCategory[raceNameKey][getSelectedGender()]["CATEGORY"]
			local visiblebutton =0

			if(getAssociativeTableCount(categoriesForRace)>0) then
				for _, button in ipairs(PhaseToolkit.DeployingFrame.CustomCategoryButtons) do
					if(categoriesForRace and categoriesForRace[button.LinkedCategory])then
						button:Show()
						visiblebutton=visiblebutton+1
						button:SetPoint("TOPRIGHT", PhaseToolkit.DeployingFrame, "TOPRIGHT", 5, -50*visiblebutton);
					else
						button:Hide()
					end
					if(PhaseToolkit.SelectedCategory and button.LinkedCategory == PhaseToolkit.SelectedCategory.LinkedCategory)then
						button.EnabledIcon:Show()
						button.DisabledIcon:Hide()
					else
						button.EnabledIcon:Hide()
						button.DisabledIcon:Show()
					end
					if(PhaseToolkit.customPanel and  not PhaseToolkit.customPanel:IsShown()) then
						button.EnabledIcon:Hide()
						button.DisabledIcon:Show()
					end
				end
			end
		end
	end
end

local function populateRowsOfRaceIcons(_RingBackground,racePage)
    local gender = "male"
    if (PhaseToolkit.DeployingFrame.NpcGenderSlider:GetValue() == 1) then
        gender = "female"
    end
	local firstList;
	local SecondList;

	if(racePage==1)then
		firstList=firstColumnIcon
		SecondList=secondColumnIcon
	elseif(racePage==2)then
		firstList=thirdColumnIcon
		SecondList=extraRaceIcon
	end

    local iconSize = 30
	local iconSize2=30

    -- Réglages arc (à ajuster)
    local radius = 120
	local radius2=85   -- rayon du cercle (px)
    local startDeg, endDeg = 110, 247.5  -- arc gauche (de haut-gauche à bas-gauche)
	local startDeg2, endDeg2 = 120, 240  -- arc droite (de haut-gauche à bas-gauche)
	--check if list is empty
	if(#PhaseToolkit.DeployingFrame.raceIconList == 0) then
		for index, raceData in ipairs(firstList) do
			local raceButton = CreateFrame("Button", nil, _RingBackground:GetParent())
			raceButton:SetSize(iconSize, iconSize)

			-- Position sur l'arc
			local n = #firstColumnIcon
			local t = (n <= 1) and 0 or ((index - 1) / (n - 1))
			local deg = startDeg + (endDeg - startDeg) * t
			local rad = math.rad(deg)
			local x = math.cos(rad) * radius
			local y = math.sin(rad) * radius

			local endInset = 18                          -- + grand = extrémités plus à droite
			local endFactor = math.abs(2 * t - 1)        -- 1 aux extrémités, 0 au milieu
			x = x + endInset * endFactor

			raceButton:SetPoint("CENTER", _RingBackground, "CENTER", x-20, y)

			raceButton.Icon = raceButton:CreateTexture(nil, "ARTWORK")
			raceButton.Icon:SetSize(iconSize, iconSize)
			raceButton.Icon:SetPoint("CENTER", raceButton, "CENTER", 0, 0)

			raceButton.border = raceButton:CreateTexture(nil, "BORDER")
			raceButton.border:SetAtlas("QuestSharing-Dialog-Portrait")
			raceButton.border:SetSize(iconSize + 5, iconSize + 5)
			raceButton.border:SetPoint("CENTER", raceButton, "CENTER", 0, 0)

			raceButton.highLight = raceButton:CreateTexture(nil, "HIGHLIGHT")
			raceButton.highLight:SetAtlas("charactercreate-ring-select");
			raceButton.highLight:SetSize(iconSize + 10, iconSize + 10)
			raceButton.highLight:SetPoint("CENTER", raceButton, "CENTER", 0, 0)
			raceButton:SetHighlightTexture(raceButton.highLight)

			raceButton:SetScript("OnClick", function()
				PhaseToolkit.ChangeNpcRace(raceData.raceid)
				PhaseToolkit.SelectedRace=raceData
				if(raceData["texture" .. gender]~="")then
					PhaseToolkit.DeployingFrame.NpcPortraitButton.Content:SetTexture(raceData["texture" .. gender])
				else
					PhaseToolkit.DeployingFrame.NpcPortraitButton.Content:SetAtlas(raceData["atlas" .. gender])
				end
				activateNpcCustomHighlights()
				if(PhaseToolkit.customPanel and PhaseToolkit.SelectedCategory and PhaseToolkit.SelectedCategory.LinkedCategory)then
					local categoryToOpen = PhaseToolkit.SelectedCategory.LinkedCategory
					if( not isCategoryExistingOnRace()) then
						categoryToOpen = "Head"
						PhaseToolkit.SelectedCategory = getCategoryFromLinkedCategory(categoryToOpen)
					end
					if(PhaseToolkit.customPanel:IsShown()) then
						buildCustomPanelForDataset(buildCustomDatasetForCategory(categoryToOpen),categoryToOpen,true)
					end
				end
				updateCustomCategoryButtons()
			end)

			if (raceData.texturemale == "" or raceData.texturefemale == "") then
				raceButton.Icon:SetAtlas(raceData["atlas" .. gender])
			end

			local mask = raceButton:CreateMaskTexture()
			mask:SetTexture("Interface\\CharacterFrame\\TempPortraitAlphaMask", "CLAMPTOBLACKADDITIVE")
			mask:SetSize(iconSize, iconSize)
			mask:SetPoint("CENTER", raceButton, "CENTER", 0, 0)
			raceButton.Icon:AddMaskTexture(mask)
			tinsert(PhaseToolkit.DeployingFrame.raceIconList,raceButton)
		end
		for index, raceData in ipairs(SecondList) do
			local raceButton = CreateFrame("Button", nil, _RingBackground:GetParent())
			raceButton:SetSize(iconSize, iconSize)

			-- Position sur l'arc
			local n = #secondColumnIcon
			local t = (n <= 1) and 0 or ((index - 1) / (n - 1))
			local deg = startDeg2 + (endDeg2 - startDeg2) * t
			local rad = math.rad(deg)
			local x = math.cos(rad) * radius2
			local y = math.sin(rad) * radius2

			local endInset = 18                          -- + grand = extrémités plus à droite
			local endFactor = math.abs(2 * t - 1)        -- 1 aux extrémités, 0 au milieu
			x = x + endInset * endFactor

			raceButton:SetPoint("CENTER", _RingBackground, "CENTER", x-20, y)

			raceButton.Icon = raceButton:CreateTexture(nil, "ARTWORK")
			raceButton.Icon:SetSize(iconSize2, iconSize2)
			raceButton.Icon:SetPoint("CENTER", raceButton, "CENTER", 0, 0)

			raceButton.border = raceButton:CreateTexture(nil, "BORDER")
			raceButton.border:SetAtlas("QuestSharing-Dialog-Portrait")
			raceButton.border:SetSize(iconSize2 + 5, iconSize2 + 5)
			raceButton.border:SetPoint("CENTER", raceButton, "CENTER", 0, 0)

			raceButton.highLight = raceButton:CreateTexture(nil, "HIGHLIGHT")
			raceButton.highLight:SetAtlas("charactercreate-ring-select");
			raceButton.highLight:SetSize(iconSize + 10, iconSize + 10)
			raceButton.highLight:SetPoint("CENTER", raceButton, "CENTER", 0, 0)
			raceButton:SetHighlightTexture(raceButton.highLight)

			raceButton:SetScript("OnClick", function()
				PhaseToolkit.ChangeNpcRace(raceData.raceid)
				PhaseToolkit.SelectedRace=raceData
				if(raceData["texture" .. gender]~="")then
					PhaseToolkit.DeployingFrame.NpcPortraitButton.Content:SetTexture(raceData["texture" .. gender])
				else
					PhaseToolkit.DeployingFrame.NpcPortraitButton.Content:SetAtlas(raceData["atlas" .. gender])
				end
				activateNpcCustomHighlights()

				if(PhaseToolkit.customPanel and PhaseToolkit.SelectedCategory and PhaseToolkit.SelectedCategory.LinkedCategory)then
					local categoryToOpen = PhaseToolkit.SelectedCategory.LinkedCategory
					if( not isCategoryExistingOnRace() and PhaseToolkit.customPanel) then
						categoryToOpen = "Head"
						PhaseToolkit.SelectedCategory = getCategoryFromLinkedCategory(categoryToOpen)
					end

					buildCustomPanelForDataset(buildCustomDatasetForCategory(categoryToOpen),categoryToOpen,true)

				end
				updateCustomCategoryButtons()
			end)
			if (raceData.texturemale == "" or raceData.texturefemale == "") then
				raceButton.Icon:SetAtlas(raceData["atlas" .. gender])
			end

			local mask = raceButton:CreateMaskTexture()
			mask:SetTexture("Interface\\CharacterFrame\\TempPortraitAlphaMask", "CLAMPTOBLACKADDITIVE")
			mask:SetSize(iconSize2, iconSize2)
			mask:SetPoint("CENTER", raceButton, "CENTER", 0, 0)
			raceButton.Icon:AddMaskTexture(mask)

			tinsert(PhaseToolkit.DeployingFrame.raceIconList,raceButton)
		end
	else
		local pos=0
		--if we already have buttons created, just update the icons
		for index, raceData in ipairs(firstList) do
			local raceButton=PhaseToolkit.DeployingFrame.raceIconList[index]
			if (raceData.texturemale == "" or raceData.texturefemale == "") then
				raceButton.Icon:SetAtlas(raceData["atlas" .. gender])
				raceButton.Icon:Show()
				raceButton.border:Show()
				raceButton:SetHighlightTexture(raceButton.highLight)
				raceButton:SetScript("OnClick", function()
					PhaseToolkit.ChangeNpcRace(raceData.raceid)
					PhaseToolkit.SelectedRace=raceData
					PhaseToolkit.DeployingFrame.NpcPortraitButton.Content:SetAtlas(raceData["atlas" .. gender])
					activateNpcCustomHighlights()
					if(PhaseToolkit.customPanel and PhaseToolkit.SelectedCategory and PhaseToolkit.SelectedCategory.LinkedCategory)then
						local categoryToOpen = PhaseToolkit.SelectedCategory.LinkedCategory
						if( not isCategoryExistingOnRace() and PhaseToolkit.customPanel) then
							categoryToOpen = "Head"
							PhaseToolkit.SelectedCategory = getCategoryFromLinkedCategory(categoryToOpen)
						end

						buildCustomPanelForDataset(buildCustomDatasetForCategory(categoryToOpen),categoryToOpen,true)

					end
					updateCustomCategoryButtons()
				end)
			else
				if(raceData["texture" .. gender] and raceData["texture" .. gender] ~= "")then
					raceButton.Icon:SetTexture(raceData["texture" .. gender])
					raceButton.Icon:Show()
					raceButton.border:Show()
					raceButton:SetHighlightTexture(raceButton.highLight)
					raceButton:SetScript("OnClick", function()
						PhaseToolkit.ChangeNpcRace(raceData.raceid)
						PhaseToolkit.SelectedRace=raceData
						PhaseToolkit.DeployingFrame.NpcPortraitButton.Content:SetTexture(raceData["texture" .. gender])
						activateNpcCustomHighlights()
						if(PhaseToolkit.customPanel and PhaseToolkit.SelectedCategory and PhaseToolkit.SelectedCategory.LinkedCategory)then
							local categoryToOpen = PhaseToolkit.SelectedCategory.LinkedCategory
							if( not isCategoryExistingOnRace() and PhaseToolkit.customPanel) then
								categoryToOpen = "Head"
								PhaseToolkit.SelectedCategory = getCategoryFromLinkedCategory(categoryToOpen)
							end

							buildCustomPanelForDataset(buildCustomDatasetForCategory(categoryToOpen),categoryToOpen,true)

						end
						updateCustomCategoryButtons()
					end)
				end
			end
			pos=index
		end
		for index, raceData in ipairs(SecondList) do
			local raceButton=PhaseToolkit.DeployingFrame.raceIconList[pos+index]
			if (raceData.texturemale == "" or raceData.texturefemale == "") then
				raceButton.Icon:SetAtlas(raceData["atlas" .. gender])
				raceButton.Icon:Show()
				raceButton.border:Show()
				raceButton:SetHighlightTexture(raceButton.highLight)
				raceButton:SetScript("OnClick", function()
					PhaseToolkit.ChangeNpcRace(raceData.raceid)
					PhaseToolkit.SelectedRace=raceData
					PhaseToolkit.DeployingFrame.NpcPortraitButton.Content:SetAtlas(raceData["atlas" .. gender])
					activateNpcCustomHighlights()
					if(PhaseToolkit.customPanel and PhaseToolkit.SelectedCategory and PhaseToolkit.SelectedCategory.LinkedCategory)then
						local categoryToOpen = PhaseToolkit.SelectedCategory.LinkedCategory
						if( not isCategoryExistingOnRace() and PhaseToolkit.customPanel) then
							categoryToOpen = "Head"
							PhaseToolkit.SelectedCategory = getCategoryFromLinkedCategory(categoryToOpen)
						end

						buildCustomPanelForDataset(buildCustomDatasetForCategory(categoryToOpen),categoryToOpen,true)

					end
					updateCustomCategoryButtons()
				end)
			else
				if(gender ~="female" and raceData.texturefemale~="")then
					raceButton.Icon:SetTexture(raceData["texture" .. gender])
					raceButton.Icon:Show()
					raceButton.border:Show()
					raceButton:SetHighlightTexture(raceButton.highLight)
					raceButton:SetScript("OnClick", function()
						PhaseToolkit.ChangeNpcRace(raceData.raceid)
						PhaseToolkit.SelectedRace=raceData
						PhaseToolkit.DeployingFrame.NpcPortraitButton.Content:SetTexture(raceData["texture" .. gender])
						activateNpcCustomHighlights()
						if(PhaseToolkit.customPanel and PhaseToolkit.SelectedCategory and PhaseToolkit.SelectedCategory.LinkedCategory)then
							local categoryToOpen = PhaseToolkit.SelectedCategory.LinkedCategory
							if( not isCategoryExistingOnRace() and PhaseToolkit.customPanel) then
								categoryToOpen = "Head"
								PhaseToolkit.SelectedCategory = getCategoryFromLinkedCategory(categoryToOpen)
							end

							buildCustomPanelForDataset(buildCustomDatasetForCategory(categoryToOpen),categoryToOpen,true)

						end
						updateCustomCategoryButtons()
					end)

				end
			end
		end
	end
end

local function clearRaceButton()
	for _, raceButton in ipairs(PhaseToolkit.DeployingFrame.raceIconList) do
		raceButton.Icon:Hide()
		raceButton.border:Hide()
		raceButton:SetHighlightTexture(nil)
		raceButton:SetScript("OnClick", function() end)
	end
end

local function deployRacePanel()
	local panel = PhaseToolkit.DeployingFrame.createRaceSelectionHalfPie
	local AnimationGroup = panel.animGroupDeploy
	AnimationGroup:Play()
end

local function retractRacePanel()
	local panel = PhaseToolkit.DeployingFrame.createRaceSelectionHalfPie
	local AnimationGroup = panel.animGroupRetract
	AnimationGroup:Play()
end

local function createRaceSelectionHalfPie(context)
	PhaseToolkit.DeployingFrame.raceIconList = {}
	PhaseToolkit.DeployingFrame.currentRacePage=1

	local RacePanel = CreateFrame("Frame", nil, PhaseToolkit.DeployingFrame)
	RacePanel:SetSize(400, 300)
	RacePanel:SetPoint("RIGHT", PhaseToolkit.DeployingFrame, "LEFT", 2.5, 0)
	RacePanel:SetFrameStrata("LOW")
	RacePanel:SetFrameLevel(1)

	local OuterRing = RacePanel:CreateTexture(nil, "ARTWORK");
	OuterRing:SetPoint("RIGHT", RacePanel, "RIGHT", 0, 0);
	SetAtlasVerticalHalf(OuterRing, "Azerite-GoldRing-Rank2", "LEFT");
	OuterRing:SetSize(150,300)

	local RingBackground = RacePanel:CreateTexture(nil, "BACKGROUND");
	RingBackground:SetPoint("CENTER", OuterRing, "CENTER", 100, 0);
	RingBackground:SetTexture("Interface\\AddOns\\"..addonName.."\\assets\\MainBG.blp")
	RingBackground:SetSize(350, 277.5);

	local RingBackgroundmask = RacePanel:CreateMaskTexture()
	RingBackgroundmask:SetTexture("Interface\\CharacterFrame\\TempPortraitAlphaMask", "CLAMPTOBLACKADDITIVE")
	RingBackgroundmask:SetSize(350, 277.5)
	RingBackgroundmask:SetPoint("CENTER", OuterRing, "CENTER", 100, 0)
	RingBackground:AddMaskTexture(RingBackgroundmask)

	populateRowsOfRaceIcons(RingBackground,1)

	local ArrowUp={}
	local ArrowDown={}
	ArrowUp.enabledAtlas = "hud-MainMenuBar-arrowup-up";
	ArrowUp.disabledAtlas = "hud-MainMenuBar-arrowup-disabled";
	ArrowDown.enabledAtlas = "hud-MainMenuBar-arrowdown-up";
	ArrowDown.disabledAtlas = "hud-MainMenuBar-arrowdown-disabled";

	local nextPageButton = CreateFrame("Button", nil, RacePanel, "UIPanelButtonTemplate")
	nextPageButton:SetSize(25, 25)
	nextPageButton:SetPoint("CENTER", RingBackground, "CENTER", -45, -20)
	nextPageButton.Icon = nextPageButton:CreateTexture(nil, "ARTWORK")
	nextPageButton.Icon:SetSize(25, 25)
	nextPageButton.Icon:SetPoint("CENTER", nextPageButton, "CENTER", 0, 0)
	nextPageButton.Icon:SetAtlas(ArrowDown.enabledAtlas)

	local previousPageButton = CreateFrame("Button", nil, RacePanel, "UIPanelButtonTemplate")
	previousPageButton:SetSize(25, 25)
	previousPageButton:SetPoint("CENTER", RingBackground, "CENTER", -45, 20)
	previousPageButton.Icon = previousPageButton:CreateTexture(nil, "ARTWORK")
	previousPageButton.Icon:SetSize(25, 25)
	previousPageButton.Icon:SetPoint("CENTER", previousPageButton, "CENTER", 0, 0)
	previousPageButton.Icon:SetAtlas(ArrowUp.disabledAtlas)

	nextPageButton:SetScript("OnClick", function()
		clearRaceButton()
		populateRowsOfRaceIcons(RingBackground,2)
		PhaseToolkit.DeployingFrame.currentRacePage=2
		nextPageButton.Icon:SetAtlas(ArrowDown.disabledAtlas)
		previousPageButton.Icon:SetAtlas(ArrowUp.enabledAtlas)
		nextPageButton:EnableMouse(false)
		previousPageButton:EnableMouse(true)
	end)

	previousPageButton:SetScript("OnClick", function()
		clearRaceButton()
		populateRowsOfRaceIcons(RingBackground,1)
		PhaseToolkit.DeployingFrame.currentRacePage=1
		previousPageButton.Icon:SetAtlas(ArrowUp.disabledAtlas)
		nextPageButton.Icon:SetAtlas(ArrowDown.enabledAtlas)
		previousPageButton:EnableMouse(false)
		nextPageButton:EnableMouse(true)

	end)

	RacePanel.isHiddenByDefault = true
	tinsert(context, RacePanel)

	EpsilonLib.Utils.NineSlice.SetBackgroundAsViewport(PhaseToolkit.DeployingFrame, RingBackground)
	PhaseToolkit.DeployingFrame.createRaceSelectionHalfPie = RacePanel
	PhaseToolkit.DeployingFrame.raceRingBackground = RingBackground
	RacePanel:Hide()

	createDeployRetractAnimsForFrame(PhaseToolkit.DeployingFrame.createRaceSelectionHalfPie, 60, 0, {
		onPlayDeploy = function() PhaseToolkit.DeployingFrame.createRaceSelectionHalfPie:Show() end,
		--onFinishedDeploy = function() end,
		--onPlayRetract = function() end,
		onFinishedRetract = function() PhaseToolkit.DeployingFrame.createRaceSelectionHalfPie:Hide() end,
	})

end


local function createCopyPasteOption(_anchor)
	local parentFrame = CreateFrame("Frame", nil, PhaseToolkit.DeployingFrame, "BackdropTemplate")
	parentFrame:SetSize(90, 100)
	parentFrame:SetPoint("BOTTOMLEFT", PhaseToolkit.DeployingFrame, "BOTTOMLEFT", 130, 35)
	parentFrame:SetBackdrop({
		bgFile = "Interface/AddOns/"..addonName.."\\assets\\MainBG.blp",
		edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
		tile = true,
		tileSize = 16,
		edgeSize = 16,
		insets = { left = 4, right = 4, top = 4, bottom = 4 }
	})
	parentFrame:SetBackdropColor(0, 0, 0, 0.5)
	parentFrame:SetBackdropBorderColor(1, 1, 1, 0.5)

	parentFrame:SetFrameStrata("HIGH")
	-- name + customizations + equipment + weapons + name
	local enableCustomNameCheckbox = CreateFrame("CheckButton", nil, parentFrame)
	enableCustomNameCheckbox:SetPoint("TOPLEFT", parentFrame, "TOPLEFT", 5, -5)
	enableCustomNameCheckbox.checked=PhaseToolkit.CopyNpcNameEnabled
	enableCustomNameCheckbox:SetSize(18,18)
	enableCustomNameCheckbox.background = enableCustomNameCheckbox:CreateTexture(nil, "BACKGROUND")
	enableCustomNameCheckbox.background:SetAtlas("common-radiobutton-circle")
	enableCustomNameCheckbox.background:SetPoint("CENTER", enableCustomNameCheckbox, "CENTER", 0, 0)
	enableCustomNameCheckbox.background:SetSize(18, 18)
	enableCustomNameCheckbox.thumb = enableCustomNameCheckbox:CreateTexture(nil, "ARTWORK")
	enableCustomNameCheckbox.thumb:SetAtlas("common-radiobutton-dot")
	enableCustomNameCheckbox.thumb:SetPoint("CENTER", enableCustomNameCheckbox, "CENTER", 0, 0)
	enableCustomNameCheckbox.thumb:SetSize(18, 18)
	enableCustomNameCheckbox.thumb:SetShown(enableCustomNameCheckbox.checked)

	enableCustomNameCheckbox.Text = enableCustomNameCheckbox:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	enableCustomNameCheckbox.Text:SetPoint("LEFT", enableCustomNameCheckbox, "RIGHT", 5, 0)
	enableCustomNameCheckbox.Text:SetText("Name")

	enableCustomNameCheckbox:SetScript("OnClick", function()
		local checked = enableCustomNameCheckbox.checked
		if checked then
			checked = false
			enableCustomNameCheckbox.checked=false
			enableCustomNameCheckbox.thumb:Hide()
		else
			checked = true
			enableCustomNameCheckbox.checked=true
			enableCustomNameCheckbox.thumb:Show()
		end
		PhaseToolkit.CopyNpcNameEnabled = checked
	end)

	local enableCustomCheckbox = CreateFrame("CheckButton", nil, parentFrame)
	enableCustomCheckbox:SetPoint("TOPLEFT", enableCustomNameCheckbox, "BOTTOMLEFT", 0, -5)
	enableCustomCheckbox.checked=PhaseToolkit.CopyNpcCustomisationEnabled
	enableCustomCheckbox:SetSize(18,18)
	enableCustomCheckbox.background = enableCustomCheckbox:CreateTexture(nil, "BACKGROUND")
	enableCustomCheckbox.background:SetAtlas("common-radiobutton-circle")
	enableCustomCheckbox.background:SetPoint("CENTER", enableCustomCheckbox, "CENTER", 0, 0)
	enableCustomCheckbox.background:SetSize(18, 18)
	enableCustomCheckbox.thumb = enableCustomCheckbox:CreateTexture(nil, "ARTWORK")
	enableCustomCheckbox.thumb:SetAtlas("common-radiobutton-dot")
	enableCustomCheckbox.thumb:SetPoint("CENTER", enableCustomCheckbox, "CENTER", 0, 0)
	enableCustomCheckbox.thumb:SetSize(18, 18)
	enableCustomCheckbox.thumb:SetShown(enableCustomCheckbox.checked)

	enableCustomCheckbox.Text = enableCustomCheckbox:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	enableCustomCheckbox.Text:SetPoint("LEFT", enableCustomCheckbox, "RIGHT", 5, 0)
	enableCustomCheckbox.Text:SetText("Custom")

	enableCustomCheckbox:SetScript("OnClick", function()
		local checked = enableCustomCheckbox.checked
		if checked then
			checked = false
			enableCustomCheckbox.checked=false
			enableCustomCheckbox.thumb:Hide()
		else
			checked = true
			enableCustomCheckbox.checked=true
			enableCustomCheckbox.thumb:Show()
		end
		PhaseToolkit.CopyNpcCustomisationEnabled = checked
	end)

	local enableEquipmentCheckbox = CreateFrame("CheckButton", nil, parentFrame)
	enableEquipmentCheckbox:SetPoint("TOPLEFT", enableCustomCheckbox, "BOTTOMLEFT", 0, -5)
	enableEquipmentCheckbox.checked = PhaseToolkit.CopyNpcGearEnabled
	enableEquipmentCheckbox:SetSize(18,18)
	enableEquipmentCheckbox.background = enableEquipmentCheckbox:CreateTexture(nil, "BACKGROUND")
	enableEquipmentCheckbox.background:SetAtlas("common-radiobutton-circle")
	enableEquipmentCheckbox.background:SetPoint("CENTER", enableEquipmentCheckbox, "CENTER", 0, 0)
	enableEquipmentCheckbox.background:SetSize(18, 18)
	enableEquipmentCheckbox.thumb = enableEquipmentCheckbox:CreateTexture(nil, "ARTWORK")
	enableEquipmentCheckbox.thumb:SetAtlas("common-radiobutton-dot")
	enableEquipmentCheckbox.thumb:SetPoint("CENTER", enableEquipmentCheckbox, "CENTER", 0, 0)
	enableEquipmentCheckbox.thumb:SetSize(18, 18)
	enableEquipmentCheckbox.thumb:SetShown(enableEquipmentCheckbox.checked)

	enableEquipmentCheckbox.Text = enableEquipmentCheckbox:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	enableEquipmentCheckbox.Text:SetPoint("LEFT", enableEquipmentCheckbox, "RIGHT", 5, 0)
	enableEquipmentCheckbox.Text:SetText("Gear")

	enableEquipmentCheckbox:SetScript("OnClick", function()
		local checked = enableEquipmentCheckbox.checked
		if checked then
			checked = false
			enableEquipmentCheckbox.checked=false
			enableEquipmentCheckbox.thumb:Hide()
		else
			checked = true
			enableEquipmentCheckbox.checked=true
			enableEquipmentCheckbox.thumb:Show()
		end
		PhaseToolkit.CopyNpcGearEnabled = checked
	end)

	local enableWeaponCheckbox = CreateFrame("CheckButton", nil, parentFrame)
	enableWeaponCheckbox:SetPoint("TOPLEFT", enableEquipmentCheckbox, "BOTTOMLEFT", 0, -5)
	enableWeaponCheckbox.checked = PhaseToolkit.CopyNpcWeaponEnabled
	enableWeaponCheckbox:SetSize(18,18)
	enableWeaponCheckbox.background = enableWeaponCheckbox:CreateTexture(nil, "BACKGROUND")
	enableWeaponCheckbox.background:SetAtlas("common-radiobutton-circle")
	enableWeaponCheckbox.background:SetPoint("CENTER", enableWeaponCheckbox, "CENTER", 0, 0)
	enableWeaponCheckbox.background:SetSize(18, 18)
	enableWeaponCheckbox.thumb = enableWeaponCheckbox:CreateTexture(nil, "ARTWORK")
	enableWeaponCheckbox.thumb:SetAtlas("common-radiobutton-dot")
	enableWeaponCheckbox.thumb:SetPoint("CENTER", enableWeaponCheckbox, "CENTER", 0, 0)
	enableWeaponCheckbox.thumb:SetSize(18, 18)
	enableWeaponCheckbox.thumb:SetShown(enableWeaponCheckbox.checked)

	enableWeaponCheckbox.Text = enableWeaponCheckbox:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	enableWeaponCheckbox.Text:SetPoint("LEFT", enableWeaponCheckbox, "RIGHT", 5, 0)
	enableWeaponCheckbox.Text:SetText("Weapon")

	enableWeaponCheckbox:SetScript("OnClick", function()
		local checked = enableWeaponCheckbox.checked
		if checked then
			checked = false
			enableWeaponCheckbox.checked=false
			enableWeaponCheckbox.thumb:Hide()
		else
			checked = true
			enableWeaponCheckbox.checked=true
			enableWeaponCheckbox.thumb:Show()
		end
		PhaseToolkit.CopyNpcWeaponsEnabled = checked
	end)

	_anchor.options = parentFrame
end

local function createNpcEditBox(context)
	local npcNameEditBox = CreateFrame("EditBox", nil, PhaseToolkit.DeployingFrame, "InputBoxTemplate")
	npcNameEditBox:SetSize(70, 20)
	npcNameEditBox:SetPoint("TOPLEFT", PhaseToolkit.DeployingFrame, "TOPLEFT", 55, -170)
	npcNameEditBox:SetAutoFocus(false)
	npcNameEditBox:SetScript("OnEnterPressed", function()
		local text = npcNameEditBox:GetText()
		sendAddonCmd("phase forge npc name " .. text, nil)
		npcNameEditBox:ClearFocus()
	end)


	npcNameEditBox.label = npcNameEditBox:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	npcNameEditBox.label:SetPoint("RIGHT", npcNameEditBox, "LEFT", -5, 0)
	npcNameEditBox.label:SetText("Name")
	tinsert(context, npcNameEditBox)

	local npcSubNameEditBox = CreateFrame("EditBox", nil, PhaseToolkit.DeployingFrame, "InputBoxTemplate")
	npcSubNameEditBox:SetSize(70, 20)
	npcSubNameEditBox:SetPoint("TOPLEFT", npcNameEditBox, "BOTTOMLEFT", 0, -5)
	npcSubNameEditBox:SetAutoFocus(false)
	npcSubNameEditBox:SetScript("OnEnterPressed", function()
		local text = npcSubNameEditBox:GetText()
		sendAddonCmd("phase forge npc subname " .. text, nil)
		npcSubNameEditBox:ClearFocus()
	end)

	npcSubNameEditBox.label = npcSubNameEditBox:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	npcSubNameEditBox.label:SetPoint("RIGHT", npcSubNameEditBox, "LEFT", -5, 0)
	npcSubNameEditBox.label:SetText("Sub.")
	tinsert(context, npcSubNameEditBox)

	local npcFactionEditBox = CreateFrame("EditBox", nil, PhaseToolkit.DeployingFrame, "InputBoxTemplate")
	npcFactionEditBox:SetSize(70, 20)
	npcFactionEditBox:SetPoint("TOPLEFT", npcSubNameEditBox, "BOTTOMLEFT", 0, -5)
	npcFactionEditBox:SetAutoFocus(false)
	npcFactionEditBox:SetScript("OnEnterPressed", function()
		local text = npcFactionEditBox:GetText()
		sendAddonCmd("phase forge npc faction " .. text, nil)
		npcFactionEditBox:ClearFocus()
	end)

	npcFactionEditBox.label = npcFactionEditBox:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	npcFactionEditBox.label:SetPoint("RIGHT", npcFactionEditBox, "LEFT", -5, 0)
	npcFactionEditBox.label:SetText("Faction")
	tinsert(context, npcFactionEditBox)

	local mouseBoundBox = CreateFrame("Button", nil, PhaseToolkit.DeployingFrame)
	mouseBoundBox:SetAllPoints(npcFactionEditBox)
	mouseBoundBox:RegisterForClicks("AnyUp")
	mouseBoundBox:SetScript("OnClick", function(_,buttonPressed)
		if(buttonPressed=="RightButton")then
			SendChatMessage(".lookup faction a","GUILD")
			npcFactionEditBox:ClearFocus()
		else
			npcFactionEditBox:SetFocus()
		end
	end)
	mouseBoundBox:EnableMouse(true)
	PhaseToolkit.RegisterTooltip(mouseBoundBox,"Right-Click to lookup Factions")
	PhaseToolkit.DeployingFrame.npcNameEditBox = npcNameEditBox
	tinsert(context, mouseBoundBox)
end

local createDatasetForDisplaysList

local function createDisplayListFrame(DisplayData)
	if(PhaseToolkit.DeployingFrame )then
		if(not PhaseToolkit.DisplayListFrame) then
			local Panel = CreateFrame("Frame", nil, PhaseToolkit.DeployingFrame, "PortraitFrameTemplate");
			Panel:SetSize(PhaseToolkit.DeployingFrame:GetWidth()+135, 245);
			Panel:SetPoint("LEFT", PhaseToolkit.DeployingFrame, "RIGHT", 0, -27.5);
			ButtonFrameTemplateMinimizable_HidePortrait(Panel)
			NineSliceUtil.ApplyLayoutByName(Panel.NineSlice, "EpsilonGoldBorderFrameTemplateNoPortrait")
			EpsilonLib.Utils.NineSlice.CropNineSliceCorners(Panel.NineSlice, 0.8, true)
			EpsilonLib.Utils.NineSlice.CropNineSliceCorners(Panel.NineSlice, 0.4)
			EpsilonLib.Utils.NineSlice.SetBackgroundAsViewport(Panel, Panel.Bg)
			Panel:SetFrameStrata("LOW")
			local titleBgColor = Panel:CreateTexture(nil, "BACKGROUND")
			local color = CreateColorFromHexString("80FF7100")
			titleBgColor:SetPoint("TOPLEFT", Panel.TitleBg)
			titleBgColor:SetPoint("BOTTOMRIGHT", Panel.TitleBg, -0, 0)
			titleBgColor:SetColorTexture(color:GetRGBA())
			Panel.TitleBgColor = titleBgColor
			PhaseToolkit.DisplayListFrame = Panel
			Panel.TitleText:SetText("Outfits / DisplayIDs list")

			local scrollFrame = CreateFrame("ScrollFrame", nil, Panel, "FauxScrollFrameTemplate")
			scrollFrame:SetPoint("TOPLEFT", Panel, "TOPLEFT", 10, -40)
			scrollFrame:SetPoint("BOTTOMRIGHT", Panel, "BOTTOMRIGHT", -18, 15)

			local content = CreateFrame("Frame", nil, Panel)
			content:SetPoint("TOPLEFT", Panel, "TOPLEFT", 10, -48)
			content:SetPoint("BOTTOMRIGHT", Panel, "BOTTOMRIGHT", -14, 18)

			Panel.scrollFrame = scrollFrame
			Panel.content = content
			Panel.displayRows = Panel.displayRows or {}
			Panel.DisplayData = Panel.DisplayData or {}
			Panel.rowHeight = 28
			Panel.visibleRows = 6

			local rowHeight = Panel.rowHeight
			local visibleRows = Panel.visibleRows

			local function createRow(index)
				local row = CreateFrame("Button", "PTK_DISPLAY_ROW"..index, content, "BackdropTemplate")
				row:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -((index - 1) * rowHeight))
				row:SetPoint("RIGHT", content, "RIGHT", 0, 0)
				row:SetHeight(rowHeight)
				row:SetBackdrop({
					bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
					edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
					edgeSize = 10,
					insets = { left = 2, right = 2, top = 2, bottom = 2 },
				})
				row:SetBackdropColor(0, 0, 0, 0.25)
				row:SetBackdropBorderColor(1, 1, 1, 0.12)

				row.highlight = row:CreateTexture(nil, "BACKGROUND")
				row.highlight:SetAllPoints(row)
				row.highlight:SetColorTexture(1, 1, 1, 0.05)
				row.highlight:Hide()

				row.label = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
				row.label:SetPoint("LEFT", row, "LEFT", 8, 0)
				row.label:SetPoint("RIGHT", row, "RIGHT", -30, 0)
				row.label:SetJustifyH("LEFT")
				row.label:SetWordWrap(false)
				row.label:SetNonSpaceWrap(true)

				row.deleteButton = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
				row.deleteButton:SetSize(18, 18)
				row.deleteButton:SetPoint("RIGHT", row, "RIGHT", -6, 0)
				row.deleteButton:SetText("X")
				row.deleteButton:SetScript("OnClick", function(self)
					local rowParent = self:GetParent()
					if(not rowParent or not rowParent.displayData) then
						return
					end

					if(PhaseToolkit.DisplayListFrame and PhaseToolkit.DisplayListFrame.scrollFrame) then
						local currentOffset = FauxScrollFrame_GetOffset(PhaseToolkit.DisplayListFrame.scrollFrame)
						local rowsPerPage = PhaseToolkit.DisplayListFrame.visibleRows or visibleRows
						PhaseToolkit.DisplayListFrame.requestedPage = math.floor(currentOffset / rowsPerPage)
					end

					local entry = rowParent.displayData
					if(entry.entryType == "outfit") then
						local outfitId = entry.OutfitId or entry.id
						if(outfitId) then
							sendAddonCmd("ph f n out remove "..tostring(outfitId), function()
								createDatasetForDisplaysList()
							end)
						end
					else
						if(entry.id) then
							sendAddonCmd("phase forge npc displays remove "..tostring(entry.id), function()
								createDatasetForDisplaysList()
							end)
						end
					end
				end)

				row:SetScript("OnEnter", function(self)
					self.highlight:Show()
				end)

				row:SetScript("OnLeave", function(self)
					self.highlight:Hide()
				end)

				row:SetScript("OnClick", function(self, button)
					if not self.displayData then
						return
					end
					if(button == "RightButton") then
						if(self.displayData.DisplayID) then
							ChatFrame_OpenChat(tostring(self.displayData.DisplayID))
						end
					else
						if(self.displayData.entryType == "outfit") then
							local outfitId = self.displayData.OutfitId or self.displayData.id
							if(outfitId) then
								sendAddonCmd("ph f n out set "..tostring(outfitId), nil)
							end
						else
							if(self.displayData.DisplayID) then
								sendAddonCmd("n set model "..tostring(self.displayData.DisplayID), nil)
							end
						end
					end
				end)

				return row
			end

			function Panel.UpdateScrollFrame()
				local displayData = Panel.DisplayData or {}
				local offset = FauxScrollFrame_GetOffset(scrollFrame)

				for i = 1, visibleRows do
					local rowIndex = offset + i
					local row = Panel.displayRows[i]
					if(not row) then
						row = createRow(i)
						Panel.displayRows[i] = row
					end

					local entry = displayData[rowIndex]
					if(entry) then
						row.displayData = entry
						if(entry.entryType == "outfit") then
							row.label:SetText(string.format(
								"Outfit: %s | Gender: %s | Race: %s",
								tostring(entry.OutfitId or entry.id or "?"),
								tostring(entry.gender or "?"),
								tostring(entry.race or "?")
							))
						else
							row.label:SetText(string.format(
								"DisplayID: %s | Scale: %s | Weight: %s",
								tostring(entry.id or "?"),
								tostring(entry.DisplayID or "?"),
								entry.scale and string.format("%.2f", entry.scale) or "?",
								entry.weightText or (entry.weight and string.format("%.2f", entry.weight) or "?")
							))
						end
						row:Show()
					else
						row.displayData = nil
						row:Hide()
					end
				end

				FauxScrollFrame_Update(scrollFrame, #displayData, visibleRows, rowHeight)
			end

			scrollFrame:SetScript("OnVerticalScroll", function(self, offset)
				FauxScrollFrame_OnVerticalScroll(self, offset, rowHeight, Panel.UpdateScrollFrame)
			end)

			Panel:SetScript("OnShow", function()
				Panel.UpdateScrollFrame()
			end)
		else
			PhaseToolkit.DisplayListFrame:Show()
		end
		--Maintenant qu'on est sure d'avoir ou non la frame, on peut la remplir avec les données
		if(PhaseToolkit.DisplayListFrame and DisplayData)then
			PhaseToolkit.DisplayListFrame.DisplayData = DisplayData
			if(PhaseToolkit.DisplayListFrame.scrollFrame and PhaseToolkit.DisplayListFrame.scrollFrame.ScrollBar) then
				local visibleRows = PhaseToolkit.DisplayListFrame.visibleRows or 6
				local rowHeight = PhaseToolkit.DisplayListFrame.rowHeight or 28
				local maxOffset = math.max(0, #DisplayData - visibleRows)
				local targetOffset = 0
				if(PhaseToolkit.DisplayListFrame.requestedPage) then
					targetOffset = math.min(maxOffset, PhaseToolkit.DisplayListFrame.requestedPage * visibleRows)
				end
				PhaseToolkit.DisplayListFrame.scrollFrame.ScrollBar:SetValue(targetOffset * rowHeight)
				PhaseToolkit.DisplayListFrame.requestedPage = nil
			end
			PhaseToolkit.DisplayListFrame:Show()
			if(PhaseToolkit.DisplayListFrame.UpdateScrollFrame) then
				PhaseToolkit.DisplayListFrame.UpdateScrollFrame()
			end
		end
	end
end

createDatasetForDisplaysList = function()
	local DisplayData = {}
	local OutfitData={}

	local function parseGenderRace(message)
		local gender, race = message:match("%((%a+)%s+([%a%s]+)%)")
		if(race) then
			race = race:match("^%s*(.-)%s*$")
		end
		return gender, race
	end
	sendAddonCmd("phase forge npc outfit list", function(isSuccessful,results)
		if(isSuccessful and results)then
			for i = 1, #results do
				local OutfitDataObject={}
				message = results[i]
				message = message:gsub("|cff%x%x%x%x%x%x", ""):gsub("|r", "")
				local OutfitId = message:match("[Oo]utfit%s*ID:%s*(%d+)")
				local gender,race = parseGenderRace(message)
				OutfitDataObject.gender = gender and gender:lower() or nil
				OutfitDataObject.race = race
				OutfitDataObject.entryType = "outfit"
				OutfitDataObject.OutfitId = tonumber(OutfitId)
				OutfitDataObject.id = tonumber(OutfitId)
				OutfitDataObject.DisplayID = nil
				if(OutfitId)then
					OutfitData[OutfitId] = OutfitDataObject
					tinsert(DisplayData, OutfitDataObject)
				end
			end
	 	end
		sendAddonCmd("phase forge npc displays list", function(isSuccessful,results)
			if(isSuccessful and results)then
				for i = 2, #results do
					message = results[i]
					message = message:gsub("|cff%x%x%x%x%x%x", ""):gsub("|r", "")
					local id = message:match("ID:%s*(%d+)")
					local scale = message:match("Scale:%s*([%d%.]+)")
					local weight = message:match("Probability Weight:%s*([%d%.]+)")
					if(weight) then
						weight = weight:gsub("%.$", "")
					end
					local OutfitId = message:match(".Outfit (%d+).")
					local DisplayID = message:match(".Display (%d+).")

					if(not (OutfitId and OutfitData[OutfitId])) then
						local DisplayDataObject={}
						local entryType = "display"

						DisplayDataObject.id = tonumber(id)
						DisplayDataObject.scale = tonumber(scale)
						DisplayDataObject.weight = tonumber(weight)
						DisplayDataObject.weightText = weight
						DisplayDataObject.OutfitId = tonumber(OutfitId)
						DisplayDataObject.DisplayID = tonumber(DisplayID)
						DisplayDataObject.entryType = entryType
						DisplayDataObject.gender = OutfitData[OutfitId] and OutfitData[OutfitId].gender
						DisplayDataObject.race = OutfitData[OutfitId] and OutfitData[OutfitId].race
						if(not DisplayDataObject.gender or not DisplayDataObject.race) then
							local fallbackGender, fallbackRace = parseGenderRace(message)
							DisplayDataObject.gender = DisplayDataObject.gender or (fallbackGender and fallbackGender:lower() or nil)
							DisplayDataObject.race = DisplayDataObject.race or fallbackRace
						end
						tinsert(DisplayData,DisplayDataObject)
					end
				end
				table.sort(DisplayData, function(a, b)
					if a.entryType ~= b.entryType then
						if a.entryType == "outfit" then
							return true
						end
						if b.entryType == "outfit" then
							return false
						end
						return tostring(a.entryType or "") < tostring(b.entryType or "")
					end
					return tonumber(a.id or a.OutfitId or 0) < tonumber(b.id or b.OutfitId or 0)
				end)
			end
			createDisplayListFrame(DisplayData)
		end)
	end,false)
end



local function createNpcToolkitButtons(context)
	local createNpcButton = CreateFrame("Button", nil, PhaseToolkit.DeployingFrame, "UIPanelButtonTemplate")
	createNpcButton:SetSize(22.5, 22.5)
	createNpcButton:SetPoint("TOPLEFT", PhaseToolkit.DeployingFrame, "TOPLEFT", 10, -140)
	createNpcButton.Icon = createNpcButton:CreateTexture(nil, "OVERLAY")
	createNpcButton.Icon:SetTexture("Interface\\AddOns\\"..addonName.."\\assets\\eps_AddButton.blp")
	createNpcButton.Icon:SetSize(22.5, 22.5)
	createNpcButton.Icon:SetPoint("CENTER", createNpcButton, "CENTER", 0, 0)

	createNpcButton:SetScript("OnClick", function()
		sendAddonCmd("ph f n create",nil,true)
	end)

	tinsert(context,createNpcButton)

	PhaseToolkit.RegisterTooltip(createNpcButton, "Create NPC")

	local duplicateNpcButton = CreateFrame("Button", nil, PhaseToolkit.DeployingFrame, "UIPanelButtonTemplate")
	duplicateNpcButton:SetSize(22.5, 22.5)
	duplicateNpcButton:SetPoint("LEFT", createNpcButton, "RIGHT", 5, 0)
	duplicateNpcButton.Icon = duplicateNpcButton:CreateTexture(nil, "OVERLAY")
	duplicateNpcButton.Icon:SetTexture("Interface\\AddOns\\"..addonName.."\\assets\\eps_ptk_icon_outfittarget.blp")
	duplicateNpcButton.Icon:SetSize(22.5, 22.5)
	duplicateNpcButton.Icon:SetPoint("CENTER", duplicateNpcButton, "CENTER", 0, 0)

	duplicateNpcButton:SetScript("OnClick", function()
		--if we have a target

		if(UnitExists("target") and UnitIsPlayer("target")==false) then
			ns.BarberCapture.Capture(function(cmd,err)
			if(cmd)then
				sendAddonCommandChain(cmd,nil,false)
			else
				print("Capture failed : "..err)
			end
		 end)
		else
			print("Duplication Need a target")
		end
	end)
	tinsert(context,duplicateNpcButton)

	PhaseToolkit.RegisterTooltip(duplicateNpcButton, "Duplicate Player Customs on NPC")

	local copyNpcButton = CreateFrame("Button", nil, PhaseToolkit.DeployingFrame, "UIPanelButtonTemplate")
	copyNpcButton:SetSize(22.5, 22.5)
	copyNpcButton:SetPoint("LEFT", duplicateNpcButton, "RIGHT", 5, 0)
	copyNpcButton.Icon = copyNpcButton:CreateTexture(nil, "OVERLAY")
	copyNpcButton.Icon:SetTexture("Interface\\AddOns\\"..addonName.."\\assets\\eps_ptk_icon_copynpc.blp")
	copyNpcButton.Icon:SetSize(22.5, 22.5)
	copyNpcButton.Icon:SetPoint("CENTER", copyNpcButton, "CENTER", 0, 0)

	copyNpcButton:SetScript("OnClick", function()
		if(UnitExists("target") and UnitIsPlayer("target")==false) then
				PhaseToolkit.CopyNpcCustomisation()
		end
	end)

	tinsert(context,copyNpcButton)

	PhaseToolkit.RegisterTooltip(copyNpcButton, "Create a Copy Code of the NPC")

	local pasteNpcButton = CreateFrame("Button", nil, PhaseToolkit.DeployingFrame, "UIPanelButtonTemplate")
	pasteNpcButton:SetSize(22.5, 22.5)
	pasteNpcButton:SetPoint("LEFT", copyNpcButton, "RIGHT", 5, 0)
	pasteNpcButton.Icon = pasteNpcButton:CreateTexture(nil, "OVERLAY")
	pasteNpcButton.Icon:SetTexture("Interface\\AddOns\\"..addonName.."\\assets\\eps_ptk_icon_pastenpc.blp")
	pasteNpcButton.Icon:SetSize(22.5, 22.5)
	pasteNpcButton.Icon:SetPoint("CENTER", pasteNpcButton, "CENTER", 0, 0)

	pasteNpcButton:SetScript("OnClick", function()
		if(UnitExists("target") and UnitIsPlayer("target")==false) then
				PhaseToolkit.PasteNpcCustomisation()
		end
	end)

	PhaseToolkit.RegisterTooltip(pasteNpcButton, "Paste a Copy Code onto this NPC")
	tinsert(context,pasteNpcButton)

	local copyPasteOptionsButton = CreateFrame("Button", nil, PhaseToolkit.DeployingFrame, "UIPanelButtonTemplate")
	copyPasteOptionsButton:SetSize(22.5, 22.5)
	copyPasteOptionsButton:SetPoint("LEFT", pasteNpcButton, "RIGHT", 5, 0)
	copyPasteOptionsButton.Icon = copyPasteOptionsButton:CreateTexture(nil, "OVERLAY")
	copyPasteOptionsButton.Icon:SetTexture("Interface\\AddOns\\"..addonName.."\\assets\\eps_ptk_icon_settings.blp")
	copyPasteOptionsButton.Icon:SetSize(22.5, 22.5)
	copyPasteOptionsButton.Icon:SetPoint("CENTER", copyPasteOptionsButton, "CENTER", 0, 0)

	copyPasteOptionsButton:SetScript("OnClick", function()
		if(not copyPasteOptionsButton.options) then
			createCopyPasteOption(copyPasteOptionsButton)
		else
			if(copyPasteOptionsButton.options:IsShown())then
				copyPasteOptionsButton.options:Hide()
			else
				copyPasteOptionsButton.options:Show()
			end
		end
	end)

	tinsert(context,copyPasteOptionsButton)


	PhaseToolkit.RegisterTooltip(copyPasteOptionsButton, "Copy/Paste Options")

	local autoUpdateCheckbox = CreateFrame("CheckButton", nil, PhaseToolkit.DeployingFrame)
	autoUpdateCheckbox:SetPoint("TOPLEFT", PhaseToolkit.DeployingFrame, "TOPLEFT", 120, -60)
	autoUpdateCheckbox:SetSize(30, 30)
	autoUpdateCheckbox.checked= PhaseToolkit.AutoRefreshNPC
	autoUpdateCheckbox.enabledIcon = autoUpdateCheckbox:CreateTexture(nil, "OVERLAY")
	autoUpdateCheckbox.enabledIcon:SetTexture("Interface\\AddOns\\"..addonName.."\\assets\\autoRefresh_enabled.blp")
	autoUpdateCheckbox.enabledIcon:SetSize(30, 30)
	autoUpdateCheckbox.enabledIcon:SetPoint("CENTER", autoUpdateCheckbox, "CENTER", 0, 0)
	autoUpdateCheckbox.disabledIcon = autoUpdateCheckbox:CreateTexture(nil, "OVERLAY")
	autoUpdateCheckbox.disabledIcon:SetTexture("Interface\\AddOns\\"..addonName.."\\assets\\autoRefresh_disabled.blp")
	autoUpdateCheckbox.disabledIcon:SetSize(30, 30)
	autoUpdateCheckbox.disabledIcon:SetPoint("CENTER", autoUpdateCheckbox, "CENTER", 0, 0)

	if(autoUpdateCheckbox.checked)then
		autoUpdateCheckbox.enabledIcon:Show()
		autoUpdateCheckbox.disabledIcon:Hide()
	else
		autoUpdateCheckbox.enabledIcon:Hide()
		autoUpdateCheckbox.disabledIcon:Show()
	end

	autoUpdateCheckbox:SetScript("OnClick", function()
		if(autoUpdateCheckbox.checked)then
			autoUpdateCheckbox.checked = false
			autoUpdateCheckbox.enabledIcon:Hide()
			autoUpdateCheckbox.disabledIcon:Show()
			PhaseToolkit.DeployingFrame:UnregisterEvent("PLAYER_TARGET_CHANGED")
		else
			autoUpdateCheckbox.checked = true
			autoUpdateCheckbox.enabledIcon:Show()
			autoUpdateCheckbox.disabledIcon:Hide()
			PhaseToolkit.DeployingFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
		end
		PhaseToolkit.AutoRefreshNPC = autoUpdateCheckbox.checked
	end)

	PhaseToolkit.DeployingFrame:SetScript("OnEvent", function(self, event)
		-- If we change target while Phase toolkit is opened, and it's a npc we take data
		if (event == "PLAYER_TARGET_CHANGED" and not UnitIsPlayer("target") and UnitExists("target")) then
			sendAddonCmd("npc info", PhaseToolkit.parseForDisplayId, false)
			if PhaseToolkit.DeployingFrame.npcNameEditBox then
				PhaseToolkit.DeployingFrame.npcNameEditBox:SetText(UnitName("target"))
				PhaseToolkit.DeployingFrame.npcNameEditBox:ClearFocus()
			end
			if(PhaseToolkit.DisplayListFrame and PhaseToolkit.DisplayListFrame:IsShown()) then
				createDatasetForDisplaysList()
			end
		end
	end)

	PhaseToolkit.RegisterTooltip(autoUpdateCheckbox, "Auto-Update Toggle")
	tinsert(context,autoUpdateCheckbox)

	local npcLevelEditBox = CreateFrame("EditBox", nil, PhaseToolkit.DeployingFrame, "InputBoxTemplate")
	npcLevelEditBox:SetSize(70, 20)
	npcLevelEditBox:SetPoint("LEFT", autoUpdateCheckbox, "RIGHT", -10, -110)
	npcLevelEditBox:SetAutoFocus(false)
	npcLevelEditBox.label = npcLevelEditBox:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	npcLevelEditBox.label:SetPoint("BOTTOM", npcLevelEditBox, "TOP", -2, 2.5)
	npcLevelEditBox.label:SetText("Level")
	npcLevelEditBox:SetScript("OnEnterPressed", function()
		local text = npcLevelEditBox:GetText()
		local level = tonumber(text)
		if level then
			sendAddonCmd("phase forge npc level " .. level, nil)
		end
		npcLevelEditBox:ClearFocus()
	end)
	tinsert(context,npcLevelEditBox)

	local healthMod = {
		[1]=0.0001,
		[2]=0.0002,
		[3]=0.0003,
		[4]=0.0004,
		[5]=0.0005,
		[6]=0.00055,
		[7]=0.0006,
		[8]=0.0007,
		[9]=0.0008,
	}

	local npcHealthEditBox = CreateFrame("EditBox", nil, PhaseToolkit.DeployingFrame, "InputBoxTemplate")
	npcHealthEditBox:SetSize(70, 20)
	npcHealthEditBox:SetPoint("TOP", npcLevelEditBox, "BOTTOM", 0, -15)
	npcHealthEditBox:SetAutoFocus(false)
	npcHealthEditBox.label = npcHealthEditBox:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	npcHealthEditBox.label:SetPoint("BOTTOM", npcHealthEditBox, "TOP", -2, 2.5)
	npcHealthEditBox.label:SetText("Health")
	npcHealthEditBox:SetScript("OnEnterPressed", function()
		local text = npcHealthEditBox:GetText()
		local health = tonumber(text)
		if health then
			if( health<10)then
				health=healthMod[health] or 0.01
				sendAddonCmd("phase forge npc healthexact " .. 1, function()
					sendAddonCmd("phase forge npc healthexact " .. health, false)
				end)
			else
				sendAddonCmd("phase forge npc healthexact " .. health, nil)
			end
		end
		npcHealthEditBox:ClearFocus()
	end)
	tinsert(context,npcHealthEditBox)

	local CreatureTypes={
		"Beast",
		"Dragonkin",
		"Demon",
		"Elemental",
		"Giant",
		"Undead",
		"Humanoid",
		"Critter",
		"Mechanical",
		"Totem",
		"Pet"
	}

	-- creature type dropdown
	local creatureType = CreateFrame("Frame", "PTKCreatureTypeDropDown", PhaseToolkit.DeployingFrame, "UIDropDownMenuTemplate")
	creatureType:SetSize(80, 20)
	creatureType:SetPoint("TOP", npcHealthEditBox, "BOTTOM", -10, 130)

	UIDropDownMenu_SetWidth(creatureType, 80)
	UIDropDownMenu_SetText(creatureType, "Creature Type")

	local function OnClick(self)
		UIDropDownMenu_SetSelectedID(creatureType, self:GetID())
		local selectedType = self.value or CreatureTypes[self:GetID()]
		UIDropDownMenu_SetText(creatureType, selectedType)
		sendAddonCmd("phase forge npc creaturetype "..selectedType, nil)
	end

	creatureType.initialize = function(self, level)
		for i, v in ipairs(CreatureTypes) do
			local info = UIDropDownMenu_CreateInfo()
			info.text = v
			info.value = v
			info.func = OnClick
			info.checked = (UIDropDownMenu_GetText(creatureType) == v)
			UIDropDownMenu_AddButton(info)
		end
	end

	UIDropDownMenu_Initialize(creatureType, creatureType.initialize)
	tinsert(context,creatureType)


	local openDisplaysListButton = CreateFrame("Button", nil, PhaseToolkit.DeployingFrame, "UIPanelButtonTemplate")
	openDisplaysListButton:SetSize(22.5, 22.5)
	openDisplaysListButton:SetPoint("LEFT", autoUpdateCheckbox, "RIGHT", 5, 0)
	openDisplaysListButton.Icon = openDisplaysListButton:CreateTexture(nil, "OVERLAY")
	openDisplaysListButton.Icon:SetTexture("Interface\\AddOns\\"..addonName.."\\assets\\eps_ptk_icon_list.blp")
	openDisplaysListButton.Icon:SetSize(22.5, 22.5)
	openDisplaysListButton.Icon:SetPoint("CENTER", openDisplaysListButton, "CENTER", 0, 0)

	openDisplaysListButton:SetScript("OnClick", function()
		if(not PhaseToolkit.DisplayListFrame)then
			createDatasetForDisplaysList()
		else
			if(PhaseToolkit.DisplayListFrame:IsShown())then
				PhaseToolkit.DisplayListFrame:Hide()
			else
				createDatasetForDisplaysList()
			end
		end
	end)

	PhaseToolkit.RegisterTooltip(openDisplaysListButton, "Open Display List")
	tinsert(context,openDisplaysListButton)
end

local function ChangeNpcRank(rankID)
	if(UnitExists("target") and UnitIsPlayer("target")==false) then
		sendAddonCmd("phase forge npc rank "..rankID, nil)
	end
end

local function createNpcRankRadios(context)
	PhaseToolkit.selectedRank=nil
	local EliteRadio = CreateFrame("CheckButton", nil, PhaseToolkit.DeployingFrame)
	EliteRadio:SetPoint("BOTTOMLEFT", PhaseToolkit.DeployingFrame, "BOTTOMLEFT", 10, 5)
	EliteRadio:SetSize(24,24)
	EliteRadio.background = EliteRadio:CreateTexture(nil, "BACKGROUND")
	EliteRadio.background:SetAtlas("common-radiobutton-circle")
	EliteRadio.background:SetPoint("CENTER", EliteRadio, "CENTER", 0, 0)
	EliteRadio.background:SetSize(24, 24)
	EliteRadio.thumb = EliteRadio:CreateTexture(nil, "ARTWORK")
	EliteRadio.thumb:SetAtlas("common-radiobutton-dot")
	EliteRadio.thumb:SetPoint("CENTER", EliteRadio, "CENTER", 0, 0)
	EliteRadio.thumb:SetSize(24, 24)
	EliteRadio.thumb:Hide()
	EliteRadio.isSelected=false
	EliteRadio.Text = EliteRadio:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	EliteRadio.Text:SetPoint("BOTTOM", EliteRadio, "TOP", 0, 2.5)
	EliteRadio.Text:SetText("Elite")

	local RareEliteRadio = CreateFrame("CheckButton", nil, PhaseToolkit.DeployingFrame)
	RareEliteRadio:SetPoint("LEFT", EliteRadio, "RIGHT", 15, 0)
	RareEliteRadio:SetSize(24,24)
	RareEliteRadio.background = RareEliteRadio:CreateTexture(nil, "BACKGROUND")
	RareEliteRadio.background:SetAtlas("common-radiobutton-circle")
	RareEliteRadio.background:SetPoint("CENTER", RareEliteRadio, "CENTER", 0, 0)
	RareEliteRadio.background:SetSize(24, 24)
	RareEliteRadio.thumb = RareEliteRadio:CreateTexture(nil, "ARTWORK")
	RareEliteRadio.thumb:SetAtlas("common-radiobutton-dot")
	RareEliteRadio.thumb:SetPoint("CENTER", RareEliteRadio, "CENTER", 0, 0)
	RareEliteRadio.thumb:SetSize(24, 24)
	RareEliteRadio.thumb:Hide()
	RareEliteRadio.isSelected=false
	RareEliteRadio.Text = RareEliteRadio:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	RareEliteRadio.Text:SetPoint("BOTTOM", RareEliteRadio, "TOP", 0, 2.5)
	RareEliteRadio.Text:SetText("Rare \nElite")

	local RareRadio = CreateFrame("CheckButton", nil, PhaseToolkit.DeployingFrame)
	RareRadio:SetPoint("LEFT", RareEliteRadio, "RIGHT", 15, 0)
	RareRadio:SetSize(24,24)
	RareRadio.background = RareRadio:CreateTexture(nil, "BACKGROUND")
	RareRadio.background:SetAtlas("common-radiobutton-circle")
	RareRadio.background:SetPoint("CENTER", RareRadio, "CENTER", 0, 0)
	RareRadio.background:SetSize(24, 24)
	RareRadio.thumb = RareRadio:CreateTexture(nil, "ARTWORK")
	RareRadio.thumb:SetAtlas("common-radiobutton-dot")
	RareRadio.thumb:SetPoint("CENTER", RareRadio, "CENTER", 0, 0)
	RareRadio.thumb:SetSize(24, 24)
	RareRadio.thumb:Hide()
	RareRadio.isSelected=false
	RareRadio.Text = RareRadio:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	RareRadio.Text:SetPoint("BOTTOM", RareRadio, "TOP", 0, 2.5)
	RareRadio.Text:SetText("Rare")

	local BossRadio = CreateFrame("CheckButton", nil, PhaseToolkit.DeployingFrame)
	BossRadio:SetPoint("LEFT", RareRadio, "RIGHT", 15, 0)
	BossRadio:SetSize(24,24)
	BossRadio.background = BossRadio:CreateTexture(nil, "BACKGROUND")
	BossRadio.background:SetAtlas("common-radiobutton-circle")
	BossRadio.background:SetPoint("CENTER", BossRadio, "CENTER", 0, 0)
	BossRadio.background:SetSize(24, 24)
	BossRadio.thumb = BossRadio:CreateTexture(nil, "ARTWORK")
	BossRadio.thumb:SetAtlas("common-radiobutton-dot")
	BossRadio.thumb:SetPoint("CENTER", BossRadio, "CENTER", 0, 0)
	BossRadio.thumb:SetSize(24, 24)
	BossRadio.thumb:Hide()
	BossRadio.isSelected=false
	BossRadio.Text = BossRadio:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	BossRadio.Text:SetPoint("BOTTOM", BossRadio, "TOP", 0, 2.5)
	BossRadio.Text:SetText("Boss")

	--Scripts after because we don't want nullpointer shit
	EliteRadio:SetScript("OnClick", function()
		if(EliteRadio.isSelected)then
			PhaseToolkit.selectedRank=nil
			EliteRadio.isSelected = false
			ChangeNpcRank(0)
			EliteRadio.thumb:Hide()
			RareEliteRadio.thumb:Hide()
			RareRadio.thumb:Hide()
			BossRadio.thumb:Hide()
		else
			PhaseToolkit.selectedRank=EliteRadio
			EliteRadio.isSelected = true
			ChangeNpcRank(1)
			EliteRadio.thumb:Show()
			RareEliteRadio.thumb:Hide()
			RareRadio.thumb:Hide()
			BossRadio.thumb:Hide()
		end
	end)

	RareEliteRadio:SetScript("OnClick", function()
		if(RareEliteRadio.isSelected)then
			PhaseToolkit.selectedRank=nil
			RareEliteRadio.isSelected = false
			ChangeNpcRank(0)
			EliteRadio.thumb:Hide()
			RareEliteRadio.thumb:Hide()
			RareRadio.thumb:Hide()
			BossRadio.thumb:Hide()
		else
			PhaseToolkit.selectedRank=RareEliteRadio
			RareEliteRadio.isSelected = true
			ChangeNpcRank(2)
			EliteRadio.thumb:Hide()
			RareEliteRadio.thumb:Show()
			RareRadio.thumb:Hide()
			BossRadio.thumb:Hide()
		end
	end)

	RareRadio:SetScript("OnClick", function()
		if(RareRadio.isSelected)then
			PhaseToolkit.selectedRank=nil
			RareRadio.isSelected = false
			ChangeNpcRank(0)
			EliteRadio.thumb:Hide()
			RareEliteRadio.thumb:Hide()
			RareRadio.thumb:Hide()
			BossRadio.thumb:Hide()
		else
			PhaseToolkit.selectedRank=RareRadio
			RareRadio.isSelected = true
			ChangeNpcRank(4)
			EliteRadio.thumb:Hide()
			RareEliteRadio.thumb:Hide()
			RareRadio.thumb:Show()
			BossRadio.thumb:Hide()
		end
	end)

	BossRadio:SetScript("OnClick", function()
		if(BossRadio.isSelected)then
			PhaseToolkit.selectedRank=nil
			BossRadio.isSelected = false
			ChangeNpcRank(0)
			EliteRadio.thumb:Hide()
			RareEliteRadio.thumb:Hide()
			RareRadio.thumb:Hide()
			BossRadio.thumb:Hide()
		else
			PhaseToolkit.selectedRank=BossRadio
			BossRadio.isSelected = true
			ChangeNpcRank(3)
			EliteRadio.thumb:Hide()
			RareEliteRadio.thumb:Hide()
			RareRadio.thumb:Hide()
			BossRadio.thumb:Show()
		end
	end)
	tinsert(context, EliteRadio)
	tinsert(context, RareEliteRadio)
	tinsert(context, RareRadio)
	tinsert(context, BossRadio)

end

local function createRaceButton(context)
	local NpcPortraitButton = CreateFrame("Button", nil, PhaseToolkit.DeployingFrame)
	NpcPortraitButton:SetSize(80, 80)

	NpcPortraitButton.Border = NpcPortraitButton:CreateTexture(nil, "BORDER")
	NpcPortraitButton.Border:SetAtlas("QuestSharing-Dialog-Portrait")
	NpcPortraitButton.Border:SetSize(70, 70)
	NpcPortraitButton.Border:SetPoint("CENTER", NpcPortraitButton, "CENTER", 0, 0)

	NpcPortraitButton.Background = NpcPortraitButton:CreateTexture(nil, "BACKGROUND")
	NpcPortraitButton.Background:SetAtlas("charactercreate-ring-customizebackground")
	NpcPortraitButton.Background:SetSize(80, 80)
	NpcPortraitButton.Background:SetPoint("CENTER", NpcPortraitButton, "CENTER", 0, 0)

	NpcPortraitButton.Highlight = NpcPortraitButton:CreateTexture(nil, "HIGHLIGHT")
	NpcPortraitButton.Highlight:SetAtlas("charactercreate-ring-select");
	NpcPortraitButton.Highlight:SetSize(80, 80);
	NpcPortraitButton.Highlight:SetPoint("CENTER", NpcPortraitButton, "CENTER", 0, 0);
	NpcPortraitButton.Highlight:Hide()

	NpcPortraitButton.Content = NpcPortraitButton:CreateTexture(nil, "ARTWORK")
	NpcPortraitButton.Content:SetSize(60, 60)
	NpcPortraitButton.Content:SetPoint("CENTER", NpcPortraitButton, "CENTER", 0, 0)
	NpcPortraitButton.Content:SetTexture("Interface\\AddOns\\"..addonName.."\\assets\\CustomBiGenderIcon256.blp")

	-- add a mask circular
	local mask = NpcPortraitButton:CreateMaskTexture()
	mask:SetTexture("Interface\\CharacterFrame\\TempPortraitAlphaMask", "CLAMPTOBLACKADDITIVE")
	mask:SetSize(60, 60)
	mask:SetPoint("CENTER", NpcPortraitButton, "CENTER", 0, 0)
	NpcPortraitButton.Content:AddMaskTexture(mask)

	NpcPortraitButton:SetScript("OnEnter", function(self)
		NpcPortraitButton.Highlight:Show()
	end)
	NpcPortraitButton:SetScript("OnLeave", function(self)
		NpcPortraitButton.Highlight:Hide()
	end)

	NpcPortraitButton:SetScript("OnClick", function()
		if(PhaseToolkit.DeployingFrame.createRaceSelectionHalfPie)then
			if(PhaseToolkit.DeployingFrame.createRaceSelectionHalfPie:IsShown())then
				retractRacePanel()
			else
				deployRacePanel()
			end
			return
		else
			createRaceSelectionHalfPie(context)
			deployRacePanel()
		end
	end)

	createNpcToolkitButtons(context)

	createNpcEditBox(context)

	createNpcRankRadios(context)

	PhaseToolkit.RegisterTooltip(NpcPortraitButton, "Race Selection")
	table.insert(context, NpcPortraitButton)
	table.insert(context, NpcPortraitButton.Border)
	table.insert(context, NpcPortraitButton.Background)
	table.insert(context, NpcPortraitButton.Content)
	PhaseToolkit.DeployingFrame.NpcPortraitButton = NpcPortraitButton
end

local function createGenderSlider(context)
	local NpcGenderSlider = CreateFrame("Slider", nil, PhaseToolkit.DeployingFrame, "OptionsSliderTemplate")
	NpcGenderSlider:SetPoint("TOPLEFT", PhaseToolkit.DeployingFrame.NpcPortraitButton, "TOPRIGHT", 0, 0)
	NpcGenderSlider:SetMinMaxValues(0, 1)
	NpcGenderSlider:SetValueStep(1)
	NpcGenderSlider:SetObeyStepOnDrag(true)
	NpcGenderSlider:SetSize(25, 80)
	NpcGenderSlider:SetValue(0) -- Default
	NpcGenderSlider:SetOrientation("VERTICAL")
	NpcGenderSlider.Low:Hide()
	NpcGenderSlider.High:Hide()
	NpcGenderSlider:EnableMouse(false)

	local clicker = CreateFrame("Button", nil, NpcGenderSlider)
    clicker:SetAllPoints(NpcGenderSlider)
    clicker:RegisterForClicks("LeftButtonUp")
	PhaseToolkit.RegisterTooltip(clicker, "Gender Toggle")

	local thumb = NpcGenderSlider:GetThumbTexture()
	thumb:SetAtlas("common-slider-thumb")

	NpcGenderSlider.CustomIcon= NpcGenderSlider:CreateTexture(nil, "OVERLAY",nil,1)
	NpcGenderSlider.CustomIcon:SetSize(20, 20)
	NpcGenderSlider.CustomIcon:SetPoint("CENTER", thumb, "CENTER", 0, 0)
	NpcGenderSlider.CustomIcon:SetAtlas("charactercreate-gendericon-male-selected")

	--mask it
	local mask = NpcGenderSlider:CreateMaskTexture()
	mask:SetTexture("Interface\\CharacterFrame\\TempPortraitAlphaMask", "CLAMPTOBLACKADDITIVE")
	mask:SetSize(20, 20)
	mask:SetPoint("CENTER", thumb, "CENTER", 0, 0)
	NpcGenderSlider.CustomIcon:AddMaskTexture(mask)

	local AnimationGroupDown = thumb:CreateAnimationGroup("GenderSliderAnim");

	local translateDown = AnimationGroupDown:CreateAnimation("Translation");
	translateDown:SetDuration(0.2);
	translateDown:SetSmoothing("IN_OUT")
	translateDown:SetOffset(0, -50);

	AnimationGroupDown:SetScript("OnFinished", function()
		NpcGenderSlider:SetValue(1)
		NpcGenderSlider.CustomIcon:SetAtlas("charactercreate-gendericon-female-selected")

		if(PhaseToolkit.DeployingFrame.raceRingBackground) then
			clearRaceButton()
			populateRowsOfRaceIcons(PhaseToolkit.DeployingFrame.raceRingBackground,PhaseToolkit.DeployingFrame.currentRacePage)
		end
		PhaseToolkit.ChangeNpcGender("female")
		if(type(PhaseToolkit.SelectedRace) == "table")then
			local race = PhaseToolkit.SelectedRace
			if(race.texturefemale and race.texturefemale ~= "")then
				PhaseToolkit.DeployingFrame.NpcPortraitButton.Content:SetTexture(race.texturefemale)
			elseif(race.atlasfemale and race.atlasfemale ~= "")then
				PhaseToolkit.DeployingFrame.NpcPortraitButton.Content:SetAtlas(race.atlasfemale)
			else
				PhaseToolkit.DeployingFrame.NpcPortraitButton.Content:SetTexture("Interface\\AddOns\\"..addonName.."\\assets\\CustomBiGenderIcon256.blp")
			end
		else
			PhaseToolkit.DeployingFrame.NpcPortraitButton.Content:SetTexture("Interface\\AddOns\\"..addonName.."\\assets\\CustomBiGenderIcon256.blp")
		end
		if(PhaseToolkit.customPanel and PhaseToolkit.SelectedCategory and PhaseToolkit.SelectedCategory.LinkedCategory)then
			local categoryToOpen = PhaseToolkit.SelectedCategory.LinkedCategory
			if( not isCategoryExistingOnRace()) then
				categoryToOpen = "Head"
				PhaseToolkit.SelectedCategory = getCategoryFromLinkedCategory(categoryToOpen)
			end
			if(PhaseToolkit.customPanel:IsShown()) then
				buildCustomPanelForDataset(buildCustomDatasetForCategory(categoryToOpen),categoryToOpen,true)
			end
		end
		updateCustomCategoryButtons()
	end);

	local AnimationGroupUp = thumb:CreateAnimationGroup("GenderSliderAnim");

	local translateUp = AnimationGroupUp:CreateAnimation("Translation");
	translateUp:SetDuration(0.2);
	translateUp:SetSmoothing("IN_OUT")
	translateUp:SetOffset(0, 50);

	AnimationGroupUp:SetScript("OnFinished", function()
		NpcGenderSlider:SetValue(0)
		NpcGenderSlider.CustomIcon:SetAtlas("charactercreate-gendericon-male-selected")
		PhaseToolkit.ChangeNpcGender("male")
		if(PhaseToolkit.DeployingFrame.raceRingBackground) then
			clearRaceButton()
			populateRowsOfRaceIcons(PhaseToolkit.DeployingFrame.raceRingBackground,PhaseToolkit.DeployingFrame.currentRacePage)
		end
		-- Same logic for male.
		if(type(PhaseToolkit.SelectedRace) == "table")then
			local race = PhaseToolkit.SelectedRace
			if(race.texturemale and race.texturemale ~= "")then
				PhaseToolkit.DeployingFrame.NpcPortraitButton.Content:SetTexture(race.texturemale)
			elseif(race.atlasmale and race.atlasmale ~= "")then
				PhaseToolkit.DeployingFrame.NpcPortraitButton.Content:SetAtlas(race.atlasmale)
			else
				PhaseToolkit.DeployingFrame.NpcPortraitButton.Content:SetTexture("Interface\\AddOns\\"..addonName.."\\assets\\CustomBiGenderIcon256.blp")
			end
		else
			PhaseToolkit.DeployingFrame.NpcPortraitButton.Content:SetTexture("Interface\\AddOns\\"..addonName.."\\assets\\CustomBiGenderIcon256.blp")
		end
		if(PhaseToolkit.customPanel and PhaseToolkit.SelectedCategory and PhaseToolkit.SelectedCategory.LinkedCategory)then
			local categoryToOpen = PhaseToolkit.SelectedCategory.LinkedCategory
			if( not isCategoryExistingOnRace()) then
				categoryToOpen = "Head"
				PhaseToolkit.SelectedCategory = getCategoryFromLinkedCategory(categoryToOpen)
			end
			if(PhaseToolkit.customPanel:IsShown()) then
				buildCustomPanelForDataset(buildCustomDatasetForCategory(categoryToOpen),categoryToOpen,true)
			end
		end
		updateCustomCategoryButtons()
	end);


	clicker:SetScript("OnClick", function()
		if NpcGenderSlider:GetValue() == 0 then
			AnimationGroupDown:Play();
		else
			AnimationGroupUp:Play();
		end

	end)

	PhaseToolkit.DeployingFrame.NpcGenderSlider = NpcGenderSlider
	PhaseToolkit.DeployingFrame.NpcGenderSlider.GoMaleAnimation = AnimationGroupUp
	PhaseToolkit.DeployingFrame.NpcGenderSlider.GoFemaleAnimation = AnimationGroupDown
	tinsert(context, NpcGenderSlider)
end

local function handleIconBehavior(button)
	if( PhaseToolkit.SelectedCategory) then
		if( PhaseToolkit.SelectedCategory.LinkedCategory ~= button.LinkedCategory) then
			PhaseToolkit.SelectedCategory.EnabledIcon:Hide()
			PhaseToolkit.SelectedCategory.DisabledIcon:Show()
			button.EnabledIcon:Show()
			button.DisabledIcon:Hide()
		end
		if(PhaseToolkit.SelectedCategory.LinkedCategory == button.LinkedCategory )then
			if(PhaseToolkit.customPanel and PhaseToolkit.customPanel:IsShown())then
				button.EnabledIcon:Hide()
				button.DisabledIcon:Show()
			else
				button.EnabledIcon:Show()
				button.DisabledIcon:Hide()
			end

		end
	else
		button.EnabledIcon:Show()
		button.DisabledIcon:Hide()
	end
end

local function createCustomCategoryButton(context)
	local Buttons ={}
	local firstCategoryButton = CreateFrame("Button", nil, PhaseToolkit.DeployingFrame);
	firstCategoryButton:SetSize(60, 60);
	firstCategoryButton:SetPoint("TOPRIGHT", PhaseToolkit.DeployingFrame, "TOPRIGHT", 5, -50);
	firstCategoryButton.EnabledIcon = firstCategoryButton:CreateTexture(nil, "OVERLAY");
	firstCategoryButton.EnabledIcon:SetAtlas("charactercreate-icon-customize-head-selected")
	firstCategoryButton.EnabledIcon:SetSize(60, 60);
	firstCategoryButton.EnabledIcon:SetPoint("CENTER", firstCategoryButton, "CENTER", 0, 0);
	firstCategoryButton.EnabledIcon:Hide();

	firstCategoryButton.DisabledIcon = firstCategoryButton:CreateTexture(nil, "OVERLAY");
	firstCategoryButton.DisabledIcon:SetAtlas("charactercreate-icon-customize-head")
	firstCategoryButton.DisabledIcon:SetSize(60, 60);
	firstCategoryButton.DisabledIcon:SetPoint("CENTER", firstCategoryButton, "CENTER", 0, 0);

	firstCategoryButton.Highlight = firstCategoryButton:CreateTexture(nil, "HIGHLIGHT")
	firstCategoryButton.Highlight:SetAtlas("charactercreate-ring-select");
	firstCategoryButton.Highlight:SetSize(65, 65);
	firstCategoryButton.Highlight:SetPoint("CENTER", firstCategoryButton, "CENTER", 0, 0);
	firstCategoryButton.Highlight:Hide()
	firstCategoryButton.LinkedCategory="Head"

	local secondCategoryButton = CreateFrame("Button", nil, PhaseToolkit.DeployingFrame);
	secondCategoryButton:SetSize(60, 60);
	secondCategoryButton:SetPoint("TOPRIGHT", PhaseToolkit.DeployingFrame, "TOPRIGHT", 5, -100);
	secondCategoryButton.EnabledIcon = secondCategoryButton:CreateTexture(nil, "OVERLAY");
	secondCategoryButton.EnabledIcon:SetAtlas("charactercreate-icon-customize-hair-selected")
	secondCategoryButton.EnabledIcon:SetSize(60, 60);
	secondCategoryButton.EnabledIcon:SetPoint("CENTER", secondCategoryButton, "CENTER", 0, 0);
	secondCategoryButton.EnabledIcon:Hide();

	secondCategoryButton.DisabledIcon = secondCategoryButton:CreateTexture(nil, "OVERLAY");
	secondCategoryButton.DisabledIcon:SetAtlas("charactercreate-icon-customize-hair")
	secondCategoryButton.DisabledIcon:SetSize(60, 60);
	secondCategoryButton.DisabledIcon:SetPoint("CENTER", secondCategoryButton, "CENTER", 0, 0);

	secondCategoryButton.Highlight = secondCategoryButton:CreateTexture(nil, "HIGHLIGHT")
	secondCategoryButton.Highlight:SetAtlas("charactercreate-ring-select");
	secondCategoryButton.Highlight:SetSize(55, 55);
	secondCategoryButton.Highlight:SetPoint("CENTER", secondCategoryButton, "CENTER", 0, 0);
	secondCategoryButton.Highlight:Hide()
	secondCategoryButton.LinkedCategory="Hair"

	local thirdCategoryButton = CreateFrame("Button", nil, PhaseToolkit.DeployingFrame);
	thirdCategoryButton:SetSize(60, 60);
	thirdCategoryButton:SetPoint("TOPRIGHT", PhaseToolkit.DeployingFrame, "TOPRIGHT", 5, -150);
	thirdCategoryButton.EnabledIcon = thirdCategoryButton:CreateTexture(nil, "OVERLAY");
	thirdCategoryButton.EnabledIcon:SetAtlas("charactercreate-icon-customize-body-selected")
	thirdCategoryButton.EnabledIcon:SetSize(60, 60);
	thirdCategoryButton.EnabledIcon:SetPoint("CENTER", thirdCategoryButton, "CENTER", 0, 0);
	thirdCategoryButton.EnabledIcon:Hide();

	thirdCategoryButton.DisabledIcon = thirdCategoryButton:CreateTexture(nil, "OVERLAY");
	thirdCategoryButton.DisabledIcon:SetAtlas("charactercreate-icon-customize-body")
	thirdCategoryButton.DisabledIcon:SetSize(60, 60);
	thirdCategoryButton.DisabledIcon:SetPoint("CENTER", thirdCategoryButton, "CENTER", 0, 0);

	thirdCategoryButton.Highlight = thirdCategoryButton:CreateTexture(nil, "HIGHLIGHT")
	thirdCategoryButton.Highlight:SetAtlas("charactercreate-ring-select");
	thirdCategoryButton.Highlight:SetSize(55, 55);
	thirdCategoryButton.Highlight:SetPoint("CENTER", thirdCategoryButton, "CENTER", 0, 0);
	thirdCategoryButton.Highlight:Hide()
	thirdCategoryButton.LinkedCategory="Body"

	local fourthCategoryButton = CreateFrame("Button", nil, PhaseToolkit.DeployingFrame);
	fourthCategoryButton:SetSize(60, 60);
	fourthCategoryButton:SetPoint("TOPRIGHT", PhaseToolkit.DeployingFrame, "TOPRIGHT", 5, -250);
	fourthCategoryButton.EnabledIcon = fourthCategoryButton:CreateTexture(nil, "OVERLAY");
	fourthCategoryButton.EnabledIcon:SetAtlas("charactercreate-icon-customize-accessories-selected")
	fourthCategoryButton.EnabledIcon:SetSize(60, 60);
	fourthCategoryButton.EnabledIcon:SetPoint("CENTER", fourthCategoryButton,	 "CENTER", 0, 0);
	fourthCategoryButton.EnabledIcon:Hide();

	fourthCategoryButton.DisabledIcon = fourthCategoryButton:CreateTexture(nil, "OVERLAY");
	fourthCategoryButton.DisabledIcon:SetAtlas("charactercreate-icon-customize-accessories")
	fourthCategoryButton.DisabledIcon:SetSize(60, 60);
	fourthCategoryButton.DisabledIcon:SetPoint("CENTER", fourthCategoryButton, "CENTER", 0, 0);

	fourthCategoryButton.Highlight = fourthCategoryButton:CreateTexture(nil, "HIGHLIGHT")
	fourthCategoryButton.Highlight:SetAtlas("charactercreate-ring-select");
	fourthCategoryButton.Highlight:SetSize(55, 55);
	fourthCategoryButton.Highlight:SetPoint("CENTER", fourthCategoryButton, "CENTER", 0, 0);
	fourthCategoryButton.Highlight:Hide()
	fourthCategoryButton.LinkedCategory="Jewelry"

	local fifthCategoryButton = CreateFrame("Button", nil, PhaseToolkit.DeployingFrame);
	fifthCategoryButton:SetSize(60, 60);
	fifthCategoryButton:SetPoint("TOPRIGHT", PhaseToolkit.DeployingFrame, "TOPRIGHT", 5, -200);
	fifthCategoryButton.EnabledIcon = fifthCategoryButton:CreateTexture(nil, "OVERLAY");
	fifthCategoryButton.EnabledIcon:SetAtlas("charactercreate-icon-customize-torso-selected")
	fifthCategoryButton.EnabledIcon:SetSize(60, 60);
	fifthCategoryButton.EnabledIcon:SetPoint("CENTER", fifthCategoryButton, "CENTER", 0, 0);
	fifthCategoryButton.EnabledIcon:Hide();

	fifthCategoryButton.DisabledIcon = fifthCategoryButton:CreateTexture(nil, "OVERLAY");
	fifthCategoryButton.DisabledIcon:SetAtlas("charactercreate-icon-customize-torso")
	fifthCategoryButton.DisabledIcon:SetSize(60, 60);
	fifthCategoryButton.DisabledIcon:SetPoint("CENTER", fifthCategoryButton, "CENTER", 0, 0);

	fifthCategoryButton.Highlight = fifthCategoryButton:CreateTexture(nil, "HIGHLIGHT")
	fifthCategoryButton.Highlight:SetAtlas("charactercreate-ring-select");
	fifthCategoryButton.Highlight:SetSize(55, 55);
	fifthCategoryButton.Highlight:SetPoint("CENTER", fifthCategoryButton, "CENTER", 0, 0);
	fifthCategoryButton.Highlight:Hide()
	fifthCategoryButton.LinkedCategory="BodyMark"


	if(type(PhaseToolkit.SelectedRace)=="table") then
		firstCategoryButton:SetScript("OnEnter", function()
			firstCategoryButton.Highlight:Show()
		end)

		secondCategoryButton:SetScript("OnEnter", function()
			secondCategoryButton.Highlight:Show()
		end)

		thirdCategoryButton:SetScript("OnEnter", function()
			thirdCategoryButton.Highlight:Show()
		end)

		fifthCategoryButton:SetScript("OnEnter", function()
			fifthCategoryButton.Highlight:Show()
		end)
	end

	firstCategoryButton:SetScript("OnClick", function(self)
		if(PhaseToolkit.SelectedRace) then
			handleIconBehavior(self)
			buildCustomPanelForDataset(buildCustomDatasetForCategory(self.LinkedCategory), self.LinkedCategory)
			PhaseToolkit.SelectedCategory=self
		end
	end)

	secondCategoryButton:SetScript("OnClick", function(self)
		if(PhaseToolkit.SelectedRace) then
			handleIconBehavior(self)
			buildCustomPanelForDataset(buildCustomDatasetForCategory(self.LinkedCategory), self.LinkedCategory)
			PhaseToolkit.SelectedCategory=self
		end
	end)

	thirdCategoryButton:SetScript("OnClick", function(self)
		if(PhaseToolkit.SelectedRace) then
			handleIconBehavior(self)
			buildCustomPanelForDataset(buildCustomDatasetForCategory(self.LinkedCategory), self.LinkedCategory)
			PhaseToolkit.SelectedCategory=self
		end
	end)

	fourthCategoryButton:SetScript("OnClick", function(self)
		if(PhaseToolkit.SelectedRace) then
			handleIconBehavior(self)
			buildCustomPanelForDataset(buildCustomDatasetForCategory(self.LinkedCategory), self.LinkedCategory)
			PhaseToolkit.SelectedCategory=self
		end
	end)

	fifthCategoryButton:SetScript("OnClick", function(self)
		if(PhaseToolkit.SelectedRace) then
			handleIconBehavior(self)
			buildCustomPanelForDataset(buildCustomDatasetForCategory(self.LinkedCategory), self.LinkedCategory)
			PhaseToolkit.SelectedCategory=self
		end
	end)

	tinsert(Buttons, firstCategoryButton)
	tinsert(Buttons, secondCategoryButton)
	tinsert(Buttons, thirdCategoryButton)
	tinsert(Buttons, fourthCategoryButton)
	tinsert(Buttons, fifthCategoryButton)
	tinsert(context, firstCategoryButton)
	tinsert(context, secondCategoryButton)
	tinsert(context, thirdCategoryButton)
	tinsert(context, fourthCategoryButton)
	tinsert(context, fifthCategoryButton)

	PhaseToolkit.DeployingFrame.CustomCategoryButtons=Buttons
end

function PhaseToolkit.gatherPhaseInfo(isCommandSuccessful, replies)
	if isCommandSuccessful then
		local listType
		for i = 1, #replies do
			message = replies[i]
			message = message:gsub("|cff%x%x%x%x%x%x", ""):gsub("|r", "")

			if listType == nil then
				listType = string.match(message, "List%s+Type:%s*(%S+)")
			end
			local phaseID;
			if not PhaseToolkit.lastPhaseID then
				phaseID = string.match(message, "Phase%s+%[.*%-%s*(%d+)%]")
			end

			if listType == "Blacklist" then
				PhaseToolkit.IsPhaseWhitelist = false
				if(PhaseToolkit.RadioWhitelist) then
					PhaseToolkit.RadioWhitelist:SetChecked(false)
				end
				if(PhaseToolkit.RadioBlacklist) then
					PhaseToolkit.RadioBlacklist:SetChecked(true)
				end
			elseif listType == "Whitelist" then
				PhaseToolkit.IsPhaseWhitelist = true
				if(PhaseToolkit.RadioWhitelist) then
					PhaseToolkit.RadioWhitelist:SetChecked(true)
				end
				if(PhaseToolkit.RadioBlacklist) then
					PhaseToolkit.RadioBlacklist:SetChecked(false)
				end
			end

			local phaseName = string.match(message, "Phase%s+%[(.*)-")
			if (phaseName ~= nil) then
				PhaseToolkit.phaseName=phaseName
			end
			if (phaseID ~= nil) then
				PhaseToolkit.lastPhaseID=phaseID
			end
		end
		PhaseToolkit.createPhaseOptions()
	end
end

function PhaseToolkit.OpenPhaseOption()
	sendAddonCmd("phase info", PhaseToolkit.gatherPhaseInfo, false)
end

local function phaseTimeMinutesToText(minutes)
	minutes = ((minutes or 0) % 1440 + 1440) % 1440
	local hours = math.floor(minutes / 60)
	local mins = minutes % 60
	return string.format("%02d:%02d", hours, mins)
end

local function phaseTimeGetDialAngle(frame)
	local scale = frame:GetEffectiveScale()
	local cursorX, cursorY = GetCursorPosition()
	local centerX, centerY = frame:GetCenter()
	if not centerX or not centerY then
		return nil
	end

	local relativeX = cursorX / scale - centerX
	local relativeY = cursorY / scale - centerY
	if relativeX == 0 and relativeY == 0 then
		return nil
	end

	local angle
	if math.atan2 then
		angle = math.atan2(relativeX, relativeY)
	else
		if relativeY == 0 then
			angle = relativeX >= 0 and (math.pi / 2) or (-math.pi / 2)
		else
			angle = math.atan(relativeX / relativeY)
			if relativeY < 0 then
				angle = angle + math.pi
			end
		end
	end

	if angle < 0 then
		angle = angle + math.pi * 2
	end

	return angle
end

local function phaseTimeAngleToMinutes(angle)
	if not angle then
		return 0
	end
	return math.floor(((angle / (math.pi * 2)) * 1440) + 0.5) % 1440
end

local function deployPhaseTimePanel()
	local AnimationGroup = PhaseToolkit.DeployingFrame.phaseTimePickerWindow.animGroupDeploy
	AnimationGroup:Play();
end

local function retractPhaseTimePanel()
	local AnimationGroup = PhaseToolkit.DeployingFrame.phaseTimePickerWindow.animGroupRetract
	AnimationGroup:Play();
end

local function createPhaseTimePickerButton(context)
	local timePickerButton = CreateFrame("Button", nil, PhaseToolkit.DeployingFrame, "UIPanelButtonTemplate")
	timePickerButton:SetSize(30, 30)
	timePickerButton:SetPoint("TOPRIGHT", PhaseToolkit.DeployingFrame, "TOPRIGHT", -2.5, -60)
	timePickerButton.icon = timePickerButton:CreateTexture(nil, "OVERLAY")
	timePickerButton.icon:SetTexture("Interface\\AddOns\\"..addonName.."\\assets\\eps_ptk_icon_clock.blp")
	timePickerButton.icon:SetAllPoints()
	timePickerButton:SetFrameStrata("HIGH")

	timePickerButton:SetScript("OnClick", function()

		if not PhaseToolkit.DeployingFrame.phaseTimePickerWindow then
			return
		end

		local shouldShow = not PhaseToolkit.DeployingFrame.phaseTimePickerWindow:IsShown()

		if shouldShow then
			deployPhaseTimePanel()
		else
			retractPhaseTimePanel()
		end

		if shouldShow and PhaseToolkit.DeployingFrame.phaseTimePickerWindow.RefreshDisplay then
			PhaseToolkit.DeployingFrame.phaseTimePickerWindow:RefreshDisplay()
		end
	end)

	PhaseToolkit.RegisterTooltip(timePickerButton, "Open Phase Time Picker")
	PhaseToolkit.DeployingFrame.phaseTimePickerButton = timePickerButton
	tinsert(context, timePickerButton)
end

local function createPhaseTimePickerWindow(context)
	local timePickerWindow = CreateFrame("Frame", nil, PhaseToolkit.DeployingFrame, "PortraitFrameTemplate");
	timePickerWindow:SetSize(180, 230);
	timePickerWindow:SetPoint("LEFT", PhaseToolkit.DeployingFrame, "RIGHT", 0, 0);
	ButtonFrameTemplateMinimizable_HidePortrait(timePickerWindow)
	NineSliceUtil.ApplyLayoutByName(timePickerWindow.NineSlice, "EpsilonGoldBorderFrameTemplateNoPortrait")
	EpsilonLib.Utils.NineSlice.CropNineSliceCorners(timePickerWindow.NineSlice, 0.8, true)
	EpsilonLib.Utils.NineSlice.CropNineSliceCorners(timePickerWindow.NineSlice, 0.4)
	EpsilonLib.Utils.NineSlice.SetBackgroundAsViewport(timePickerWindow, timePickerWindow.Bg)
	timePickerWindow:SetFrameStrata("LOW")
	local titleBgColor = timePickerWindow:CreateTexture(nil, "BACKGROUND")
	local color = CreateColorFromHexString("80FF7100")
	titleBgColor:SetPoint("TOPLEFT", timePickerWindow.TitleBg)
	titleBgColor:SetPoint("BOTTOMRIGHT", timePickerWindow.TitleBg, -0, 0)
	titleBgColor:SetColorTexture(color:GetRGBA())
	timePickerWindow.TitleBgColor = titleBgColor
	timePickerWindow.TitleText:SetText(PhaseToolkit.CurrentLang["Phase Time"] or "Phase Time")
	timePickerWindow.TitleText:SetPoint("LEFT", timePickerWindow.TitleBg, "LEFT", 30, 0)

	timePickerWindow.phaseOptionVisibleState = false
	timePickerWindow:Hide()

	local content = {}

	timePickerWindow.Value = CreateFrame("EditBox", nil, 	timePickerWindow);
	timePickerWindow.Value:SetSize(80, 30);
	timePickerWindow.Value:SetFont("Fonts\\FRIZQT__.TTF", 14, "OUTLINE");
	timePickerWindow.Value:SetAutoFocus(false);
	timePickerWindow.Value:SetJustifyH("CENTER");


	timePickerWindow.Value:SetScript("OnEscapePressed",function(self)
		self:clearFocus()
	end)

	timePickerWindow.Value:SetScript("OnEnterPressed",function(self)
		self:ClearFocus()
	end)

	timePickerWindow.Value:SetPoint("TOP", timePickerWindow, "TOP", 0, -25)

	tinsert(content, timePickerWindow.Value)

	local dial = CreateFrame("Frame", nil, timePickerWindow)
	dial:SetSize(160, 160)
	dial:SetPoint("LEFT", timePickerWindow, "LEFT", 10, -20)
	dial:EnableMouse(true)
	local dialRadius = 62

	dial.Background = dial:CreateTexture(nil, "BACKGROUND")
	dial.Background:SetTexture("Interface\\AddOns\\"..addonName.."\\assets\\EpsilonClockBackGround.blp")
	dial.Background:SetAllPoints()

	dial.CenterDot = dial:CreateTexture(nil, "ARTWORK")
	dial.CenterDot:SetTexture("Interface\\AddOns\\"..addonName.."\\assets\\EpsilonClockHand.blp")
	dial.CenterDot:SetPoint("CENTER", dial, "CENTER", 0, 0)
	dial.CenterDot:SetScale(0.20)

	dial.Marker = dial:CreateTexture(nil, "OVERLAY")
	dial.Marker:SetTexture("Interface\\AddOns\\"..addonName.."\\assets\\EpsilonClockPin.blp")
	dial.Marker:SetSize(17.5, 17.5)

	dial.CenterDot1 = dial:CreateTexture(nil, "ARTWORK")
	dial.CenterDot1:SetTexture("Interface\\AddOns\\"..addonName.."\\assets\\EpsilonClockPin.blp")
	dial.CenterDot1:SetPoint("CENTER", dial, "CENTER", 0, 0)
	dial.CenterDot1:SetSize(17,17)
	dial.CenterDot1:SetDrawLayer("OVERLAY")

	tinsert(content, dial)
	tinsert(content,dial.Background)
	tinsert(content,dial.CenterDot)
	tinsert(content,dial.Marker)

	local function updateTimePickerDisplay(minutes)
		minutes = ((minutes or 0) % 1440 + 1440) % 1440
		PhaseToolkit.phaseTimePickerMinutes = minutes
		local angle = (minutes / 1440) * math.pi * 2
		dial.Marker:SetPoint("CENTER", dial, "CENTER", math.sin(angle) * dialRadius, math.cos(angle) * dialRadius)
		timePickerWindow.Value:SetText(phaseTimeMinutesToText(minutes))
		dial.CenterDot:SetRotation(-angle)
	end

	local function commitTimePickerValue()
		sendAddonCmd("phase set time " .. phaseTimeMinutesToText(PhaseToolkit.phaseTimePickerMinutes or 0), nil)
	end

	timePickerWindow.Value:SetScript("OnEditFocusLost",function(self)
		local text = self:GetText()
		local hours, minutes = string.match(text, "(%d+):(%d+)")
		hours = tonumber(hours) or 0
		minutes = tonumber(minutes) or 0
		local totalMinutes = (hours * 60) + minutes
		updateTimePickerDisplay(totalMinutes)
		commitTimePickerValue()
	end)

	local function updateTimeFromCursor()
		local angle = phaseTimeGetDialAngle(dial)
		if not angle then
			return
		end
		dial.CenterDot:SetRotation(-angle)
		updateTimePickerDisplay(phaseTimeAngleToMinutes(angle))
	end

	dial:SetScript("OnMouseDown", function(self, button)
		if button ~= "LeftButton" then
			return
		end
		self.isDragging = true
		updateTimeFromCursor()
	end)

	dial:SetScript("OnMouseUp", function(self, button)
		if button ~= "LeftButton" then
			return
		end
		self.isDragging = false
		updateTimeFromCursor()
		commitTimePickerValue()
	end)

	dial:SetScript("OnHide", function(self)
		self.isDragging = false
	end)

	dial:SetScript("OnUpdate", function(self)
		if self.isDragging then
			updateTimeFromCursor()
		end
	end)

	function timePickerWindow:RefreshDisplay()
		if PhaseToolkit.phaseTimePickerMinutes == nil then
			local hour, minute = GetGameTime()
			PhaseToolkit.phaseTimePickerMinutes = (hour * 60) + minute
		end
		updateTimePickerDisplay(PhaseToolkit.phaseTimePickerMinutes)
	end

	timePickerWindow:RefreshDisplay()
	timePickerWindow.isHiddenByDefault = true
	PhaseToolkit.DeployingFrame.phaseTimePickerWindow = timePickerWindow
	PhaseToolkit.DeployingFrame.phaseTimePickerWindow.content = content
	tinsert(context, timePickerWindow)

	createDeployRetractAnimsForFrame(PhaseToolkit.DeployingFrame.phaseTimePickerWindow, -60, 0, {
		onPlayDeploy = function()
			hideContent(PhaseToolkit.DeployingFrame.phaseTimePickerWindow.content)
			PhaseToolkit.DeployingFrame.phaseTimePickerWindow:Show()
		end,
		onFinishedDeploy = function()
			showContent(PhaseToolkit.DeployingFrame.phaseTimePickerWindow.content)

		end,
		onPlayRetract = function()
			hideContent(PhaseToolkit.DeployingFrame.phaseTimePickerWindow.content)
		end,
		onFinishedRetract = function()
			PhaseToolkit.DeployingFrame.phaseTimePickerWindow:Hide()
		end,
	})

end

local function createPhaseNameComponent(context)
	local phaseNameEditionLabel = CreateFrame("EditBox", nil, 	PhaseToolkit.DeployingFrame);
	phaseNameEditionLabel:SetSize(210, 30);
    phaseNameEditionLabel:SetPoint("CENTER", 0, 70);
    phaseNameEditionLabel:SetAutoFocus(false);
    phaseNameEditionLabel:SetFont("Fonts\\FRIZQT__.TTF", 14, "OUTLINE");
    phaseNameEditionLabel:SetTextColor(1, 1, 1, 1); -- Blanc

    phaseNameEditionLabel:SetMaxLetters(50);

    local textureTopNom= phaseNameEditionLabel:CreateTexture(nil, "OVERLAY");
    textureTopNom:SetTexture("Interface/AddOns/"..addonName.."/assets/BPMLineName.blp");
    textureTopNom:SetPoint("BOTTOM",phaseNameEditionLabel,"TOP", 0, -7.5);
    textureTopNom:SetSize(250,12);
    textureTopNom:SetVertexColor(0.1, 0.1, 0.8);

    local textureBottomNom= phaseNameEditionLabel:CreateTexture(nil, "OVERLAY");
    textureBottomNom:SetTexture("Interface/AddOns/"..addonName.."/assets/BPMLineName.blp");
    textureBottomNom:SetPoint("TOP",phaseNameEditionLabel,"BOTTOM", 0, 7.5);
    textureBottomNom:SetSize(250,12);
    textureBottomNom:SetVertexColor(0.1, 0.1, 0.8);

    phaseNameEditionLabel:SetJustifyH("CENTER")
    phaseNameEditionLabel:SetMultiLine(false)

	phaseNameEditionLabel:SetScript("OnEditFocusGained", function(self)
		phaseNameEditionLabel.lastvalue = phaseNameEditionLabel:GetText()
	end)

	phaseNameEditionLabel:SetScript("OnEditFocusLost", function(self)
		local newPhaseName = phaseNameEditionLabel:GetText()
		if newPhaseName ~= phaseNameEditionLabel.lastvalue then
			PhaseToolkit.phaseName = newPhaseName
			sendAddonCmd("phase rename "..newPhaseName, nil)
		end
	end)

    phaseNameEditionLabel:SetScript("OnEnterPressed", function(self)
        self:ClearFocus()
    end)
    phaseNameEditionLabel:SetScript("OnEscapePressed", function(self)
        self:ClearFocus()
    end)

	phaseNameEditionLabel:SetText(PhaseToolkit.phaseName or "")
	PhaseToolkit.DeployingFrame.phaseNameEditionLabel = phaseNameEditionLabel

	tinsert(context, phaseNameEditionLabel)
	tinsert(context,textureTopNom)
	tinsert(context,textureBottomNom)
end

local function createPhaseDescriptionComponent(context)
	local PhasedescriptionField = CreateFrame("EditBox", nil, PhaseToolkit.DeployingFrame)
    PhasedescriptionField:SetSize(220, 50)
    PhasedescriptionField:SetPoint("TOP",PhaseToolkit.DeployingFrame.phaseNameEditionLabel,"BOTTOM",0, -32.5)
    PhasedescriptionField:SetAutoFocus(false)
    PhasedescriptionField:SetFontObject("GameFontHighlight")
    PhasedescriptionField.texture= PhasedescriptionField:CreateTexture(nil, "BACKGROUND")

    PhasedescriptionField.interactionOverlay = CreateFrame("Frame", nil, PhasedescriptionField)
    PhasedescriptionField.interactionOverlay:SetPoint("TOPLEFT", PhasedescriptionField, "TOPLEFT", 0, -5)
    PhasedescriptionField.interactionOverlay:SetSize(PhasedescriptionField:GetWidth(), PhasedescriptionField:GetHeight())
    PhasedescriptionField.interactionOverlay:EnableMouse(true)

    PhasedescriptionField.interactionOverlay:SetScript("OnMouseDown", function(self, button)
        if button == "LeftButton" then
            PhasedescriptionField:SetFocus()
        end
    end)

	PhasedescriptionField:SetScript("OnEditFocusGained", function(self)
		PhasedescriptionField.lastvalue = PhasedescriptionField:GetText()
	end)

	PhasedescriptionField:SetScript("OnEditFocusLost", function(self)
		local newPhaseDescription = PhasedescriptionField:GetText()
		if newPhaseDescription ~= PhasedescriptionField.lastvalue then
			PhaseToolkit.phaseDescription = newPhaseDescription
			sendAddonCmd("phase set desc "..newPhaseDescription, nil)
		end
	end)

    PhasedescriptionField:SetScript("OnEnterPressed", function(self)
        PhasedescriptionField:ClearFocus()
    end)

    PhasedescriptionField:SetScript("OnEscapePressed", function(self)
        PhasedescriptionField:ClearFocus()
    end)

    PhasedescriptionField.texture:SetAtlas("UI-Frame-Kyrian-PortraitWiderDisable")
    PhasedescriptionField.texture:SetPoint("TOPLEFT", -10, 10)
    PhasedescriptionField.texture:SetSize(240,70)
    PhasedescriptionField:SetMultiLine(true)
    PhasedescriptionField:SetJustifyH("LEFT")
    PhasedescriptionField:SetMaxLetters(60)
    PhasedescriptionField:EnableMouse(true)
    PhasedescriptionField:SetCursorPosition(0)

    PhasedescriptionField.title = PhasedescriptionField:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    PhasedescriptionField.title:SetPoint("BOTTOM",PhasedescriptionField,"TOP", 0, 15)
    PhasedescriptionField.title:SetText("Description")

	PhasedescriptionField:Show()
	PhaseToolkit.DeployingFrame.PhasedescriptionField = PhasedescriptionField
	tinsert(context, PhasedescriptionField)
end

local function createPhaseMotdComponent(context)
	local PhaseMotdEditbox = CreateFrame("EditBox", nil, PhaseToolkit.DeployingFrame)
    PhaseMotdEditbox:SetSize(220, 50)
    PhaseMotdEditbox:SetPoint("TOP",PhaseToolkit.DeployingFrame.PhasedescriptionField,"BOTTOM",0, -75)
    PhaseMotdEditbox:SetAutoFocus(false)
    PhaseMotdEditbox:SetFontObject("GameFontHighlight")
    PhaseMotdEditbox.texture= PhaseMotdEditbox:CreateTexture(nil, "BACKGROUND")

    PhaseMotdEditbox.interactionOverlay = CreateFrame("Frame", nil, PhaseMotdEditbox)
    PhaseMotdEditbox.interactionOverlay:SetPoint("TOPLEFT", PhaseMotdEditbox, "TOPLEFT", 0, -5)
    PhaseMotdEditbox.interactionOverlay:SetSize(PhaseMotdEditbox:GetWidth(), PhaseMotdEditbox:GetHeight())
    PhaseMotdEditbox.interactionOverlay:EnableMouse(true)

    PhaseMotdEditbox.interactionOverlay:SetScript("OnMouseDown", function(self, button)
        if button == "LeftButton" then
            PhaseMotdEditbox:SetFocus()
        end
    end)

	PhaseMotdEditbox:SetScript("OnEditFocusGained", function(self)
		PhaseMotdEditbox.lastvalue = PhaseMotdEditbox:GetText()
	end)

	PhaseMotdEditbox:SetScript("OnEditFocusLost", function(self)
		local newPhaseMotd = PhaseMotdEditbox:GetText()
		if newPhaseMotd ~= PhaseMotdEditbox.lastvalue then
			PhaseToolkit.phaseMotd = newPhaseMotd
			sendAddonCmd("ph set mess "..newPhaseMotd, nil)
		end
	end)

    PhaseMotdEditbox:SetScript("OnEnterPressed", function(self)
        PhaseMotdEditbox:ClearFocus()
    end)

    PhaseMotdEditbox:SetScript("OnEscapePressed", function(self)
        PhaseMotdEditbox:ClearFocus()
    end)

    PhaseMotdEditbox.texture:SetAtlas("UI-Frame-Kyrian-PortraitWiderDisable")
    PhaseMotdEditbox.texture:SetPoint("TOPLEFT", -10, 10)
    PhaseMotdEditbox.texture:SetSize(240,70)
    PhaseMotdEditbox:SetMultiLine(true)
	PhaseMotdEditbox:SetVisibleTextByteLimit(124)
    PhaseMotdEditbox:SetJustifyH("LEFT")
    PhaseMotdEditbox:SetMaxLetters(0) -- unlimited text length
    PhaseMotdEditbox:EnableMouse(true) -- ensure mouse interaction
    PhaseMotdEditbox:SetCursorPosition(0) -- set initial cursor position

    PhaseMotdEditbox.title = PhaseMotdEditbox:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    PhaseMotdEditbox.title:SetPoint("BOTTOM",PhaseMotdEditbox,"TOP", 0, 15)
    PhaseMotdEditbox.title:SetText("Message of the Day")

	PhaseToolkit.DeployingFrame.PhaseMotdEditbox = PhaseMotdEditbox
	tinsert(context, PhaseMotdEditbox)
end

-- Phase Weather Panel

local function deployPhaseWeatherPanel()
	local AnimationGroup = PhaseToolkit.DeployingFrame.phaseWeatherWindow.animGroupDeploy
	AnimationGroup:Play();
end

local function retractPhaseWeatherPanel()
	local AnimationGroup = PhaseToolkit.DeployingFrame.phaseWeatherWindow.animGroupRetract
	AnimationGroup:Play();
end

local function createPhaseWeatherWindow(context)
	local phaseWeatherWindow = CreateFrame("Frame", nil, PhaseToolkit.DeployingFrame, "PortraitFrameTemplate");
	phaseWeatherWindow:SetSize(235, 300);
	phaseWeatherWindow:SetPoint("RIGHT", PhaseToolkit.DeployingFrame, "LEFT", 0, 0);
	ButtonFrameTemplateMinimizable_HidePortrait(phaseWeatherWindow)
	NineSliceUtil.ApplyLayoutByName(phaseWeatherWindow.NineSlice, "EpsilonGoldBorderFrameTemplateNoPortrait")
	EpsilonLib.Utils.NineSlice.CropNineSliceCorners(phaseWeatherWindow.NineSlice, 0.8, true)
	EpsilonLib.Utils.NineSlice.CropNineSliceCorners(phaseWeatherWindow.NineSlice, 0.4)
	EpsilonLib.Utils.NineSlice.SetBackgroundAsViewport(phaseWeatherWindow, phaseWeatherWindow.Bg)
	phaseWeatherWindow:SetFrameStrata("LOW")
	local titleBgColor = phaseWeatherWindow:CreateTexture(nil, "BACKGROUND")
	local color = CreateColorFromHexString("80FF7100")
	titleBgColor:SetPoint("TOPLEFT", phaseWeatherWindow.TitleBg)
	titleBgColor:SetPoint("BOTTOMRIGHT", phaseWeatherWindow.TitleBg, -0, 0)
	titleBgColor:SetColorTexture(color:GetRGBA())
	phaseWeatherWindow.TitleBgColor = titleBgColor
	phaseWeatherWindow.TitleText:SetText(PhaseToolkit.CurrentLang["Phase Weather"] or "Phase Weather")
	phaseWeatherWindow.TitleText:SetPoint("LEFT", phaseWeatherWindow.TitleBg, "LEFT", 30, 0)

	local panelContent = {}

	local permanentCheckbox = CreateFrame("CheckButton", nil, phaseWeatherWindow, "UICheckButtonTemplate")
	permanentCheckbox:SetPoint("TOPLEFT", phaseWeatherWindow, "TOPLEFT", 10, -30)
	permanentCheckbox:SetSize(20, 20)
	permanentCheckbox.text = permanentCheckbox:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	permanentCheckbox.text:SetPoint("LEFT", permanentCheckbox, "RIGHT", 2.5, 1.5)
	permanentCheckbox.text:SetText("Permanent")

	tinsert(panelContent, permanentCheckbox)


	local IntensitySlider = CreateFrame("Slider", nil, phaseWeatherWindow, "OptionsSliderTemplate")
	IntensitySlider:SetPoint("TOPLEFT", phaseWeatherWindow, "TOPLEFT", 10, -70)
	IntensitySlider:SetSize(200, 20)
	IntensitySlider:SetMinMaxValues(0, 100)
	IntensitySlider:SetValueStep(1)
	IntensitySlider:SetObeyStepOnDrag(true)

	IntensitySlider.Low:Hide()
	IntensitySlider.High:Hide()
	IntensitySlider:SetValue(0)

	local thumb = IntensitySlider:GetThumbTexture()
	thumb:SetAtlas("common-slider-thumb")

	IntensitySlider.value = CreateFrame("EditBox", nil, IntensitySlider)
	IntensitySlider.value:SetSize(40, 20)
	IntensitySlider.value:SetPoint("BOTTOM", IntensitySlider, "TOP", 5, 0)
	IntensitySlider.value:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
	IntensitySlider.value:SetAutoFocus(false)
	IntensitySlider.value:SetJustifyH("CENTER")
	IntensitySlider.value:SetText(IntensitySlider:GetValue())

	tinsert(panelContent, IntensitySlider)

	permanentCheckbox:SetScript("OnClick", function(self)
		sendAddonCmd("phase set weather "..PhaseToolkit.SelectedMeteo.value.." "..IntensitySlider:GetValue().." "..(self:GetChecked() and "permanent" or ""), nil,false)
	end)

	IntensitySlider:SetScript("OnValueChanged", function(self, value)
		self.value:SetText(math.floor(value))
		sendAddonCmd("phase set weather "..PhaseToolkit.SelectedMeteo.value.." "..value.." "..(permanentCheckbox:GetChecked() and "permanent" or ""), nil,false)
	end)

	local scrollFrame = CreateFrame("ScrollFrame", nil, phaseWeatherWindow, "FauxScrollFrameTemplate")
	scrollFrame:SetPoint("TOPLEFT", phaseWeatherWindow, "TOPLEFT", 10, -100)
	scrollFrame:SetPoint("BOTTOMRIGHT", phaseWeatherWindow, "BOTTOMRIGHT", -18, 15)

	local content = CreateFrame("Frame", nil, phaseWeatherWindow)
	content:SetPoint("TOPLEFT", phaseWeatherWindow, "TOPLEFT", 0, -88)
	content:SetPoint("BOTTOMRIGHT", phaseWeatherWindow, "BOTTOMRIGHT", -4, 18)

	tinsert(panelContent, scrollFrame)
	tinsert(panelContent, content)

	phaseWeatherWindow.scrollFrame = scrollFrame
	phaseWeatherWindow.content = content
	phaseWeatherWindow.displayRows = phaseWeatherWindow.displayRows or {}
	phaseWeatherWindow.rowHeight = 32
	phaseWeatherWindow.visibleRows = 6

	local rowHeight = phaseWeatherWindow.rowHeight
	local visibleRows = phaseWeatherWindow.visibleRows

	local function createRow(index)
		local row = CreateFrame("Button", "PTK_METEO_ROW"..index, content)
		row:SetPoint("TOPLEFT", content, "TOPLEFT", -5, -((index - 1) * rowHeight))
		row:SetPoint("RIGHT", content, "RIGHT", 0, 0)
		row:SetHeight(rowHeight)

		--first column
		row.firstElement = CreateFrame("Frame", nil, row)
		row.firstElement:SetPoint("TOPLEFT", row, "TOPLEFT", -5, 0)
		row.firstElement:SetSize(130, 45)
		row.firstElement.background = row.firstElement:CreateTexture(nil, "BACKGROUND")
		row.firstElement.background:SetTexture("Interface\\AddOns\\"..addonName.."\\assets\\BlueprintManagerFrameBackground.blp")
		row.firstElement.background:SetAllPoints(row.firstElement)

		row.firstElement.highlight = row.firstElement:CreateTexture(nil, "OVERLAY")
		row.firstElement.highlight:SetTexture("Interface\\AddOns\\"..addonName.."\\assets\\BlueprintManagerFrameForeground.blp")
		row.firstElement.highlight:SetAllPoints(row.firstElement)
		row.firstElement.highlight:Hide()

		row.firstElement.label = row.firstElement:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
		row.firstElement.label:SetPoint("CENTER", row.firstElement, "CENTER", 0, 0)
		row.firstElement.label:SetJustifyH("CENTER")
		row.firstElement.label:SetWordWrap(false)
		row.firstElement.label:SetNonSpaceWrap(true)

		row.firstElement:SetScript("OnEnter", function(self)
			self.highlight:Show()
		end)

		row.firstElement:SetScript("OnLeave", function(self)
			if(row.firstElement.label and row.firstElement.label:GetText() == PhaseToolkit.SelectedMeteo.text) then
				self.highlight:Show()
			else
				self.highlight:Hide()
			end
		end)

		--second column
		row.secondElement = CreateFrame("Frame", nil, row)
		row.secondElement:SetPoint("TOPRIGHT", row, "TOPRIGHT", -10, 0)
		row.secondElement:SetSize(130, 45)
		row.secondElement.background = row.secondElement:CreateTexture(nil, "BACKGROUND")
		row.secondElement.background:SetTexture("Interface\\AddOns\\"..addonName.."\\assets\\BlueprintManagerFrameBackground.blp")
		row.secondElement.background:SetAllPoints(row.secondElement)

		row.secondElement.highlight = row.secondElement:CreateTexture(nil, "OVERLAY")
		row.secondElement.highlight:SetTexture("Interface\\AddOns\\"..addonName.."\\assets\\BlueprintManagerFrameForeground.blp")
		row.secondElement.highlight:SetAllPoints(row.secondElement)
		row.secondElement.highlight:Hide()

		row.secondElement.label = row.secondElement:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
		row.secondElement.label:SetPoint("CENTER", row.secondElement, "CENTER", 0, 0)
		row.secondElement.label:SetJustifyH("CENTER")
		row.secondElement.label:SetWordWrap(false)
		row.secondElement.label:SetNonSpaceWrap(true)

		row.secondElement:SetScript("OnEnter", function(self)
			self.highlight:Show()
		end)

		row.secondElement:SetScript("OnLeave", function(self)
			if(row.secondElement.label and row.secondElement.label:GetText() == PhaseToolkit.SelectedMeteo.text) then
				self.highlight:Show()
			else
				self.highlight:Hide()
			end
		end)

		return row
	end

	function phaseWeatherWindow.UpdateScrollFrame()
		local offset = FauxScrollFrame_GetOffset(scrollFrame)
		for i = 1, visibleRows do
			local firstMeteo = ((offset + i - 1) * 2) + 1
			local secondMeteo = firstMeteo + 1

			local row = phaseWeatherWindow.displayRows[i]
			if(not row) then
				row = createRow(i)
				phaseWeatherWindow.displayRows[i] = row
			end

			row.firstElement.label:SetText(PhaseToolkit.Meteo[firstMeteo].text)
			row.firstElement:SetScript("OnMouseDown", function(self, button)
				if button == "LeftButton" then
					sendAddonCmd("phase set weather "..PhaseToolkit.Meteo[firstMeteo].value.." "..IntensitySlider:GetValue().." "..(permanentCheckbox:GetChecked() and "permanent" or ""), nil,false)
					PhaseToolkit.SelectedMeteo = PhaseToolkit.Meteo[firstMeteo]
				end
				phaseWeatherWindow.UpdateScrollFrame()
			end)

			row.secondElement.label:SetText(PhaseToolkit.Meteo[secondMeteo].text)
			row.secondElement:SetScript("OnMouseDown", function(self, button)
				if button == "LeftButton" then
					sendAddonCmd("phase set weather "..PhaseToolkit.Meteo[secondMeteo].value.." "..IntensitySlider:GetValue().." "..(permanentCheckbox:GetChecked() and "permanent" or ""), nil,false)
					PhaseToolkit.SelectedMeteo = PhaseToolkit.Meteo[secondMeteo]
				end
				phaseWeatherWindow.UpdateScrollFrame()
			end)

			if(PhaseToolkit.Meteo[firstMeteo].value == PhaseToolkit.SelectedMeteo.value) then
				row.firstElement.highlight:Show()
			else
				row.firstElement.highlight:Hide()
			end

			if(PhaseToolkit.Meteo[secondMeteo].value == PhaseToolkit.SelectedMeteo.value) then
				row.secondElement.highlight:Show()
			else
				row.secondElement.highlight:Hide()
			end

			row:Show()

		end

		FauxScrollFrame_Update(scrollFrame, math.ceil(#PhaseToolkit.Meteo / 2), visibleRows, rowHeight)
	end

	scrollFrame:SetScript("OnVerticalScroll", function(self, offset)
		FauxScrollFrame_OnVerticalScroll(self, offset, rowHeight, phaseWeatherWindow.UpdateScrollFrame)
	end)

	phaseWeatherWindow:SetScript("OnShow", function()
		phaseWeatherWindow.UpdateScrollFrame()
	end)

	scrollFrame.ScrollBar:SetPoint("TOPRIGHT", scrollFrame, "TOPRIGHT", 0, -36)
	scrollFrame.ScrollBar:SetPoint("BOTTOMRIGHT", scrollFrame, "BOTTOMRIGHT", -2, 16)

	tinsert(panelContent, scrollFrame.ScrollBar)

	phaseWeatherWindow:Hide()
	phaseWeatherWindow.isHiddenByDefault = true
	PhaseToolkit.DeployingFrame.phaseWeatherWindow = phaseWeatherWindow
	PhaseToolkit.DeployingFrame.phaseWeatherWindow.content = panelContent
	tinsert(context, phaseWeatherWindow)

	createDeployRetractAnimsForFrame(PhaseToolkit.DeployingFrame.phaseWeatherWindow, 60, 0, {
		onPlayDeploy = function()
			hideContent(PhaseToolkit.DeployingFrame.phaseWeatherWindow.content)
			if(PhaseToolkit.DeployingFrame.phasePermissionWindow and PhaseToolkit.DeployingFrame.phasePermissionWindow:IsShown()) then
				PhaseToolkit.DeployingFrame.phasePermissionWindow:Hide()
			end
			PhaseToolkit.DeployingFrame.phaseWeatherWindow:Show()
		end,
		onFinishedDeploy = function()
			showContent(PhaseToolkit.DeployingFrame.phaseWeatherWindow.content)
		end,
		onPlayRetract = function()
			hideContent(PhaseToolkit.DeployingFrame.phaseWeatherWindow.content)
		end,
		onFinishedRetract = function()
			PhaseToolkit.DeployingFrame.phaseWeatherWindow:Hide()
		end,
	})

end

local function createPhaseWeatherButton(context)
	local PhaseWeatherButton = CreateFrame("Button", nil, PhaseToolkit.DeployingFrame, "UIPanelButtonTemplate")
	PhaseWeatherButton:SetSize(30, 30)
	PhaseWeatherButton:SetPoint("TOPLEFT", PhaseToolkit.DeployingFrame, "TOPLEFT", 2.5, -60)
	PhaseWeatherButton.icon = PhaseWeatherButton:CreateTexture(nil, "OVERLAY")
	PhaseWeatherButton.icon:SetTexture("Interface\\AddOns\\"..addonName.."\\assets\\eps_ptk_icon_weather.blp")
	PhaseWeatherButton.icon:SetAllPoints()
	PhaseWeatherButton:SetFrameStrata("HIGH")

	PhaseWeatherButton:SetScript("OnClick", function()
		if not PhaseToolkit.DeployingFrame.phaseWeatherWindow then
			return
		end

		local shouldShow = not PhaseToolkit.DeployingFrame.phaseWeatherWindow:IsShown()

		if shouldShow then
			deployPhaseWeatherPanel()
		else
			retractPhaseWeatherPanel()
		end
	end)

	PhaseToolkit.RegisterTooltip(PhaseWeatherButton, "Open Phase Weather Settings")
	PhaseToolkit.DeployingFrame.PhaseWeatherButton = PhaseWeatherButton
	tinsert(context, PhaseWeatherButton)
end

local function createPhaseAccessRadioButtons(context)
	local radiosFrame = CreateFrame("Frame", nil, PhaseToolkit.DeployingFrame)
	radiosFrame:SetSize(200, 30)
	radiosFrame:SetPoint("BOTTOM", PhaseToolkit.DeployingFrame, "BOTTOM", -25, 0)

	local whitelistRadioButton = CreateFrame("CheckButton", nil, radiosFrame, "UIRadioButtonTemplate")
	whitelistRadioButton:SetPoint("LEFT", radiosFrame, "LEFT", 0, 0)
	whitelistRadioButton:SetSize(20, 20)
	whitelistRadioButton.text = whitelistRadioButton:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	whitelistRadioButton.text:SetPoint("LEFT", whitelistRadioButton, "RIGHT", 2.5, 0)
	whitelistRadioButton.text:SetText("Whitelist")
	whitelistRadioButton:SetChecked(PhaseToolkit.IsPhaseWhitelist==true)

	local blacklistRadioButton = CreateFrame("CheckButton", nil, radiosFrame, "UIRadioButtonTemplate")
	blacklistRadioButton:SetPoint("LEFT", whitelistRadioButton, "RIGHT", 65, 0)
	blacklistRadioButton:SetSize(20, 20)
	blacklistRadioButton.text = blacklistRadioButton:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	blacklistRadioButton.text:SetPoint("LEFT", blacklistRadioButton, "RIGHT", 2.5, 0)
	blacklistRadioButton.text:SetText("Blacklist")
	blacklistRadioButton:SetChecked(PhaseToolkit.IsPhaseWhitelist==false)

	whitelistRadioButton:SetScript("OnClick", function()
		whitelistRadioButton:SetChecked(true)
		blacklistRadioButton:SetChecked(false)
		sendAddonCmd("ph togg private ", nil)
	end)

	blacklistRadioButton:SetScript("OnClick", function()
		whitelistRadioButton:SetChecked(false)
		blacklistRadioButton:SetChecked(true)
		sendAddonCmd("ph togg private ", nil)
	end)

	PhaseToolkit.RadioBlacklist=blacklistRadioButton
	PhaseToolkit.RadioWhitelist=whitelistRadioButton

	PhaseToolkit.DeployingFrame.phaseAccessRadioButtons = radiosFrame
	tinsert(context, radiosFrame)
end

local function createPhaseStartingButton(context)
	local phaseStartingButton = CreateFrame("Button", nil, PhaseToolkit.DeployingFrame, "UIPanelButtonTemplate")
	phaseStartingButton:SetSize(30, 30)
	phaseStartingButton:SetPoint("TOP", PhaseToolkit.DeployingFrame.phaseTimePickerButton, "BOTTOM", 0, 0)

	phaseStartingButton.background = phaseStartingButton:CreateTexture(nil, "OVERLAY")
	phaseStartingButton.background:SetTexture("Interface\\AddOns\\"..addonName.."\\assets\\BPMEmptyButton.blp")
	phaseStartingButton.background:SetAllPoints()

	phaseStartingButton.icon = phaseStartingButton:CreateTexture(nil, "OVERLAY")
	phaseStartingButton.icon:SetAtlas("poi-door-down")
	phaseStartingButton.icon:SetSize(20, 20)
	phaseStartingButton.icon:SetPoint("CENTER", phaseStartingButton, "CENTER", 0, 0)

	phaseStartingButton:SetFrameStrata("HIGH")

	phaseStartingButton:SetScript("OnMouseDown", function(self,button)
		if button == "LeftButton" then
			sendAddonCmd("ph set start ", nil,true)
		end
		if button == "RightButton" then
			sendAddonCmd("ph set start disable", nil,true)
		end
	end)

	PhaseToolkit.RegisterTooltip(phaseStartingButton, "Left -Click to set the Phase Starting Point.\nRight-Click to disable the Phase Starting Point")
	PhaseToolkit.DeployingFrame.phaseStartingButton = phaseStartingButton
	tinsert(context, phaseStartingButton)
end

-- Phase Permissions Panel

local function deployPhasePermissionPanel()
	local AnimationGroup = PhaseToolkit.DeployingFrame.phasePermissionWindow.animGroupDeploy
	AnimationGroup:Play();
end

local function retractPhasePermissionPanel()
	local AnimationGroup = PhaseToolkit.DeployingFrame.phasePermissionWindow.animGroupRetract
	AnimationGroup:Play();
end


local function createPhasePermissionButton(context)
	local phasePermissionButton = CreateFrame("Button", nil, PhaseToolkit.DeployingFrame, "UIPanelButtonTemplate")
	phasePermissionButton:SetSize(30, 30)
	phasePermissionButton:SetPoint("TOP", PhaseToolkit.DeployingFrame.PhaseWeatherButton, "BOTTOM", 0, 0)

	phasePermissionButton.icon = phasePermissionButton:CreateTexture(nil, "OVERLAY")
	phasePermissionButton.icon:SetTexture("Interface\\AddOns\\"..addonName.."\\assets\\eps_ptk_icon_list.blp")
	phasePermissionButton.icon:SetAllPoints()
	phasePermissionButton:SetFrameStrata("HIGH")

	PhaseToolkit.RegisterTooltip(phasePermissionButton, "Left-Click to access Phase Permission Panel")
	phasePermissionButton:SetScript("OnClick", function(self, button)
		local shouldShow = not PhaseToolkit.DeployingFrame.phasePermissionWindow:IsShown()
		if shouldShow then
			deployPhasePermissionPanel()
		else
			retractPhasePermissionPanel()
		end
	end)

	PhaseToolkit.DeployingFrame.phasePermissionButton = phasePermissionButton
	tinsert(context, phasePermissionButton)
end

local function createPhasePermissionWindow(context)
	local phasePermissionWindow = CreateFrame("Frame", nil, PhaseToolkit.DeployingFrame, "PortraitFrameTemplate");
	phasePermissionWindow:SetSize(135, 300);
	phasePermissionWindow:SetPoint("RIGHT", PhaseToolkit.DeployingFrame, "LEFT", 0, 0);
	ButtonFrameTemplateMinimizable_HidePortrait(phasePermissionWindow)
	NineSliceUtil.ApplyLayoutByName(phasePermissionWindow.NineSlice, "EpsilonGoldBorderFrameTemplateNoPortrait")
	EpsilonLib.Utils.NineSlice.CropNineSliceCorners(phasePermissionWindow.NineSlice, 0.8, true)
	EpsilonLib.Utils.NineSlice.CropNineSliceCorners(phasePermissionWindow.NineSlice, 0.4)
	EpsilonLib.Utils.NineSlice.SetBackgroundAsViewport(phasePermissionWindow, phasePermissionWindow.Bg)
	phasePermissionWindow:SetFrameStrata("LOW")
	local titleBgColor = phasePermissionWindow:CreateTexture(nil, "BACKGROUND")
	local color = CreateColorFromHexString("80FF7100")
	titleBgColor:SetPoint("TOPLEFT", phasePermissionWindow.TitleBg)
	titleBgColor:SetPoint("BOTTOMRIGHT", phasePermissionWindow.TitleBg, -0, 0)
	titleBgColor:SetColorTexture(color:GetRGBA())
	phasePermissionWindow.TitleBgColor = titleBgColor
	phasePermissionWindow.TitleText:SetText(PhaseToolkit.CurrentLang["Phase Permissions"] or "Phase Permissions")

	phasePermissionWindow:Hide()
	phasePermissionWindow.isHiddenByDefault = true
	local permissionToggleList = {}
	local content = {}

	for _,permission in pairs(PhaseToolkit.Toggleslist) do
		local permissionToggle = CreateFrame("CheckButton", "permissionToggle"..permission, phasePermissionWindow, "UICheckButtonTemplate")
		permissionToggle:SetSize(20, 20)
		permissionToggle.text = permissionToggle:CreateFontString(nil, "OVERLAY", "GameFontNormal")
		permissionToggle.text:SetPoint("LEFT", permissionToggle, "RIGHT", 2.5, 0)
		permissionToggle.text:SetText(permission)
		permissionToggle:SetPoint("TOPLEFT", phasePermissionWindow, "TOPLEFT", 10, -30 - (#permissionToggleList * 30))
		permissionToggle:SetChecked(true)
		tinsert(permissionToggleList, permissionToggle)
		tinsert(content, permissionToggle)

		permissionToggle:SetScript("OnClick", function(self)
			sendAddonCmd("ph togg "..permission, nil,true)
		end)
	end

	PhaseToolkit.DeployingFrame.phasePermissionWindow = phasePermissionWindow
	PhaseToolkit.DeployingFrame.phasePermissionWindow.content = content
	tinsert(context, phasePermissionWindow)

	createDeployRetractAnimsForFrame(PhaseToolkit.DeployingFrame.phasePermissionWindow, 60, 0, {
		onPlayDeploy = function()
			hideContent(PhaseToolkit.DeployingFrame.phasePermissionWindow.content)
			if(PhaseToolkit.DeployingFrame.phaseWeatherWindow and PhaseToolkit.DeployingFrame.phaseWeatherWindow:IsShown()) then
				retractPhaseWeatherPanel()
			end
			PhaseToolkit.DeployingFrame.phasePermissionWindow:Show()
		end,
		onFinishedDeploy = function()
			showContent(PhaseToolkit.DeployingFrame.phasePermissionWindow.content)
		end,
		onPlayRetract = function()
			hideContent(PhaseToolkit.DeployingFrame.phasePermissionWindow.content)
		end,
		onFinishedRetract = function()
			PhaseToolkit.DeployingFrame.phasePermissionWindow:Hide()
		end,
	})
end

function PhaseToolkit.createPhaseOptions()
	--if we had a previous context, we need to hide it before creating a new one
	if PhaseToolkit.context.id ~="NONE" then
		PhaseToolkit.changeContext(deployingFrameContext["NONE"])
	end

	local context = {}
	context.id="PHASEOPTION"
	PhaseToolkit.extendDeployingFrame(0)
	if not PhaseToolkit.DeployingFrame.phaseNameEditionLabel then
		createPhaseNameComponent(context)
	end

	if not PhaseToolkit.DeployingFrame.PhasedescriptionField then
		createPhaseDescriptionComponent(context)
	end

	if not PhaseToolkit.DeployingFrame.PhaseMotdEditbox then
		createPhaseMotdComponent(context)
	end

	if not PhaseToolkit.DeployingFrame.phaseTimePickerWindow then
		createPhaseTimePickerWindow(context)
	end

	if not PhaseToolkit.DeployingFrame.phaseTimePickerButton then
		createPhaseTimePickerButton(context)
	end

	if not PhaseToolkit.DeployingFrame.phaseWeatherWindow then
		createPhaseWeatherWindow(context)
	end

	if not PhaseToolkit.DeployingFrame.PhaseWeatherButton then
		createPhaseWeatherButton(context)
	end

	if not PhaseToolkit.DeployingFrame.phaseAccessRadioButtons then
		createPhaseAccessRadioButtons(context)
	end

	if not PhaseToolkit.DeployingFrame.phaseStartingButton then
		createPhaseStartingButton(context)
	end

	if not PhaseToolkit.DeployingFrame.phasePermissionWindow then
		createPhasePermissionWindow(context)
	end

	if not PhaseToolkit.DeployingFrame.phasePermissionButton then
		createPhasePermissionButton(context)
	end

	if(#deployingFrameContext["PHASEOPTION"]<1) then
		deployingFrameContext["PHASEOPTION"] = context
	end

	PhaseToolkit.changeContext(deployingFrameContext["PHASEOPTION"])
end

local function parseReplies(isCommandSuccessful, repliesList)
	local function SetNpcListRefreshLoadingState(isLoading)
		PhaseToolkit.isNpcListRefreshInProgress = isLoading and true or false
		local refreshButton = PhaseToolkit.DeployingFrame and PhaseToolkit.DeployingFrame.NpcListRefreshButton
		if refreshButton then
			if isLoading then
				refreshButton:Disable()
				refreshButton:SetAlpha(0.5)
			else
				refreshButton:Enable()
				refreshButton:SetAlpha(1)
			end
		end
	end

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
			if PhaseToolkit.context.id == "NPCLIST" and PhaseToolkit.DeployingFrame.NpcListScrollFrame then
				PhaseToolkit.RefreshNpcListView()
			else
				PhaseToolkit.OpenNpcList()
			end
			SetNpcListRefreshLoadingState(false)
		end
	else
		SetNpcListRefreshLoadingState(false)
	end
end

function PhaseToolkit.createNPCList()
	-- Use Epsilib to fetch the replies
	if(not PhaseToolkit.creatureList or #PhaseToolkit.creatureList == 0) then
		sendAddonCmd("ph f n list", parseReplies, false)
	else
		PhaseToolkit.OpenNpcList()
	end

end


local function BuildNpcListView()
    local source = PhaseToolkit.creatureList or {}
    local hasCategoryFilter = PhaseToolkit.NPCcategoryToFilterPool and #PhaseToolkit.NPCcategoryToFilterPool > 0
    local byCategory = {}

    if hasCategoryFilter then
        local allowedIds = {}

        for _, categoryId in ipairs(PhaseToolkit.NPCcategoryToFilterPool) do
            local category = PhaseToolkit.getCategoryByIdGENERIC(categoryId, "NPC")
            if category and category.members then
                for _, memberId in ipairs(category.members) do
                    allowedIds[tostring(memberId)] = true
                end
            end
        end

        for _, npc in ipairs(source) do
            if allowedIds[tostring(npc.IdCreature)] then
                table.insert(byCategory, npc)
            end
        end

		if #byCategory == 0 and #source > 0 then
			byCategory = source
		end
    else
        byCategory = source
    end

    local query = (PhaseToolkit.CurrenttextToLookForNpc or ""):lower()
    if query == "" then
        return byCategory
    end

    local filtered = {}
    for _, npc in ipairs(byCategory) do
		local name = tostring(npc.NomCreature or ""):lower()
        if string.find(name, query) then
            table.insert(filtered, npc)
        end
    end

    return filtered
end

function PhaseToolkit.RefreshNpcListView(preserveOffset)
    PhaseToolkit.npcListView = BuildNpcListView()

    local scrollFrame = PhaseToolkit.DeployingFrame.NpcListScrollFrame
    if not scrollFrame then
        return
    end

    local rowHeight = scrollFrame.rowHeight or 32
    local visibleRows = scrollFrame.visibleRows or 11
    local maxOffset = math.max(0, #PhaseToolkit.npcListView - visibleRows)
	local targetOffset = 0

	if preserveOffset then
		if FauxScrollFrame_GetOffset then
			targetOffset = FauxScrollFrame_GetOffset(scrollFrame) or 0
		elseif scrollFrame.ScrollBar and scrollFrame.ScrollBar.GetValue then
			targetOffset = math.floor((scrollFrame.ScrollBar:GetValue() or 0) / rowHeight)
		end
	end

    if scrollFrame.ScrollBar and scrollFrame.ScrollBar.GetValue and scrollFrame.ScrollBar.SetValue then
		targetOffset = math.max(0, math.min(targetOffset, maxOffset))
		scrollFrame.ScrollBar:SetValue(targetOffset * rowHeight)
    end

	if FauxScrollFrame_SetOffset then
		FauxScrollFrame_SetOffset(scrollFrame, targetOffset)
		scrollFrame.offset = targetOffset
	end

    PhaseToolkit.DeployingFrame.NpcListScrollFrame:UpdateRows()
end

function PhaseToolkit.RemoveNpcById(npcList, idToRemove)
	local updatedList = {}
	for _, npc in ipairs(npcList) do
		if tostring(npc.IdCreature) ~= tostring(idToRemove) then
			table.insert(updatedList, npc)
		end
	end
	return updatedList
end

local function deployTagListPanel(contentContext, deployingFrameContext)
	local AnimationGroup = PhaseToolkit.DeployingFrame.tagListPanel.animGroupDeploy

	AnimationGroup:Play();
end

local function retractTagListPanel(contentContext, deployingFrameContext)
	local AnimationGroup = PhaseToolkit.DeployingFrame.tagListPanel.animGroupRetract
	AnimationGroup:Play();
end

-- we have to be vigilent about the content, cause the tag list is used for both NPC and TELE, so we need to make sure we are using the right context
function PhaseToolkit.CreateTagList(contentContext, deployingFrameContext)
	local tagListPanel = CreateFrame("Frame", nil, PhaseToolkit.DeployingFrame, "PortraitFrameTemplate");
	tagListPanel:SetSize(235, 300);
	tagListPanel:SetPoint("RIGHT", PhaseToolkit.DeployingFrame, "LEFT", 0, 20);
	ButtonFrameTemplateMinimizable_HidePortrait(tagListPanel)
	NineSliceUtil.ApplyLayoutByName(tagListPanel.NineSlice, "EpsilonGoldBorderFrameTemplateNoPortrait")
	EpsilonLib.Utils.NineSlice.CropNineSliceCorners(tagListPanel.NineSlice, 0.8, true)
	EpsilonLib.Utils.NineSlice.CropNineSliceCorners(tagListPanel.NineSlice, 0.4)
	EpsilonLib.Utils.NineSlice.SetBackgroundAsViewport(tagListPanel, tagListPanel.Bg)
	tagListPanel:SetFrameStrata("LOW")
	local titleBgColor = tagListPanel:CreateTexture(nil, "BACKGROUND")
	local color = CreateColorFromHexString("80FF7100")
	titleBgColor:SetPoint("TOPLEFT", tagListPanel.TitleBg)
	titleBgColor:SetPoint("BOTTOMRIGHT", tagListPanel.TitleBg, -0, 0)
	titleBgColor:SetColorTexture(color:GetRGBA())
	tagListPanel.TitleBgColor = titleBgColor
	tagListPanel.TitleText:SetText("Tag list")
	tagListPanel.TitleText:SetPoint("LEFT", tagListPanel.TitleBg, "LEFT", 30, 0)

	local panelContent = {}

	local createCategoryButton = CreateFrame("Button", nil, tagListPanel, "UIPanelButtonTemplate")
	createCategoryButton:SetSize(20, 20)
	createCategoryButton:SetPoint("TOPLEFT", tagListPanel, "TOPLEFT", 0, 0)
	createCategoryButton.icon = createCategoryButton:CreateTexture(nil, "OVERLAY")
	createCategoryButton.icon:SetAtlas("GreenCross")
	createCategoryButton.icon:SetAllPoints()
	PhaseToolkit.RegisterTooltip(createCategoryButton, "Create Category")

	tinsert(panelContent, createCategoryButton)

	local fetchCategoryButton = CreateFrame("Button", nil, tagListPanel, "UIPanelButtonTemplate")
	fetchCategoryButton:SetSize(20, 20)
	fetchCategoryButton:SetPoint("LEFT", createCategoryButton, "RIGHT", 2, -1)
	fetchCategoryButton.icon = fetchCategoryButton:CreateTexture(nil, "OVERLAY")
	fetchCategoryButton.icon:SetTexture("Interface\\AddOns\\"..addonName.."\\assets\\BPMRefreshButton.blp")
	fetchCategoryButton.icon:SetAllPoints()
	fetchCategoryButton:SetFrameStrata("HIGH")
	fetchCategoryButton:SetScript("OnClick", function()
		PhaseToolkit.getNpcCategoryFromPhaseData(function()
			if tagListPanel and tagListPanel.UpdateRows then
				tagListPanel.UpdateRows()
			end
			PhaseToolkit.RefreshNpcListView(true)
		end)
	end)
	PhaseToolkit.RegisterTooltip(fetchCategoryButton, "Fetch Categories")
	tinsert(panelContent, fetchCategoryButton)

	local helpButton = CreateFrame("Button", nil, tagListPanel, "UIPanelButtonTemplate")
	helpButton:SetSize(20, 20)
	helpButton:SetPoint("LEFT", fetchCategoryButton, "RIGHT", 2, -1)
	helpButton:SetText("?")
	helpButton:SetFrameStrata("HIGH")
	helpButton:SetScript("OnEnter", function(self)
		PhaseToolkit.ShowCategoryCustomTooltip(self)
	end)
	helpButton:SetScript("OnLeave", function()
		GameTooltip:Hide()
	end)
	tinsert(panelContent, helpButton)
	local inputFrame = nil
	createCategoryButton:SetScript("OnClick", function()
		if not inputFrame then
			inputFrame = CreateFrame("Frame", nil, tagListPanel, "PortraitFrameTemplate")
			inputFrame:SetSize(235, 90)
			inputFrame:SetPoint("BOTTOM", tagListPanel, "TOP", 0, 2.5)
			ButtonFrameTemplateMinimizable_HidePortrait(inputFrame)
			NineSliceUtil.ApplyLayoutByName(inputFrame.NineSlice, "EpsilonGoldBorderFrameTemplateNoPortrait")
			EpsilonLib.Utils.NineSlice.CropNineSliceCorners(inputFrame.NineSlice, 0.8, true)
			EpsilonLib.Utils.NineSlice.CropNineSliceCorners(inputFrame.NineSlice, 0.4)
			EpsilonLib.Utils.NineSlice.SetBackgroundAsViewport(inputFrame, inputFrame.Bg)
			inputFrame:SetFrameStrata("DIALOG")
			local inputTitleBgColor = inputFrame:CreateTexture(nil, "BACKGROUND")
			local inputTitleColor = CreateColorFromHexString("80FF7100")
			inputTitleBgColor:SetPoint("TOPLEFT", inputFrame.TitleBg)
			inputTitleBgColor:SetPoint("BOTTOMRIGHT", inputFrame.TitleBg, -0, 0)
			inputTitleBgColor:SetColorTexture(inputTitleColor:GetRGBA())
			inputFrame.TitleBgColor = inputTitleBgColor
			inputFrame.TitleText:SetText("Create Category")
			inputFrame.TitleText:SetPoint("LEFT", inputFrame.TitleBg, "LEFT", 30, 0)

			local deployAnimation = inputFrame:CreateAnimationGroup("DeployNpcCategoryInputFrame")
			local deployFade = deployAnimation:CreateAnimation("Alpha")
			deployFade:SetOrder(1)
			deployFade:SetFromAlpha(0)
			deployFade:SetToAlpha(1)
			deployFade:SetDuration(0.5)
			deployFade:SetSmoothing("OUT")

			local deployScale = deployAnimation:CreateAnimation("Scale")
			deployScale:SetOrder(1)
			deployScale:SetFromScale(1.0, 0.1)
			deployScale:SetToScale(1.0, 1.0)
			deployScale:SetDuration(0.5)
			deployScale:SetSmoothing("OUT")
			deployScale:SetOrigin("BOTTOM", 0, 0)

			deployAnimation:SetScript("OnPlay", function()
				inputFrame:Show()
			end)
			deployAnimation:SetScript("OnFinished", function()
				inputFrame:SetAlpha(1)
				inputFrame:Show()
			end)

			local retractAnimation = inputFrame:CreateAnimationGroup("RetractNpcCategoryInputFrame")
			local retractFade = retractAnimation:CreateAnimation("Alpha")
			retractFade:SetOrder(1)
			retractFade:SetFromAlpha(1)
			retractFade:SetToAlpha(0)
			retractFade:SetDuration(0.5)
			retractFade:SetSmoothing("OUT")

			local retractScale = retractAnimation:CreateAnimation("Scale")
			retractScale:SetOrder(1)
			retractScale:SetFromScale(1.0, 1.0)
			retractScale:SetToScale(1.0, 0.1)
			retractScale:SetDuration(0.5)
			retractScale:SetSmoothing("OUT")
			retractScale:SetOrigin("BOTTOM", 0, 0)

			retractAnimation:SetScript("OnFinished", function()
				inputFrame:Hide()
				inputFrame:SetAlpha(1)
			end)

			inputFrame.deployAnimation = deployAnimation
			inputFrame.retractAnimation = retractAnimation
			inputFrame:Hide()

			local function deployInputFrame()
				if inputFrame.retractAnimation and inputFrame.retractAnimation:IsPlaying() then
					inputFrame.retractAnimation:Stop()
				end
				inputFrame:Show()
				inputFrame:SetAlpha(1)
				if inputFrame.deployAnimation and inputFrame.deployAnimation:IsPlaying() then
					inputFrame.deployAnimation:Stop()
				end
				inputFrame.deployAnimation:Play()
			end

			local function retractInputFrame()
				if not inputFrame:IsShown() then
					return
				end
				if inputFrame.deployAnimation and inputFrame.deployAnimation:IsPlaying() then
					inputFrame.deployAnimation:Stop()
				end
				inputFrame.retractAnimation:Play()
			end

			inputFrame.editBox = CreateFrame("EditBox", nil, inputFrame, "InputBoxTemplate")
			inputFrame.editBox:SetSize(180, 24)
			inputFrame.editBox:SetPoint("TOP", inputFrame.TitleBg, "BOTTOM", 0, -18)
			inputFrame.editBox:SetAutoFocus(true)

			inputFrame.editBox:SetScript("OnEnterPressed", function(self)
				local categoryName = self:GetText()
				if categoryName and categoryName ~= "" then
					PhaseToolkit.CreateNewNpcCategory(categoryName, function()
						if tagListPanel and tagListPanel.UpdateRows then
							tagListPanel.UpdateRows()
						end
					end)
				end
				self:ClearFocus()
				retractInputFrame()
			end)

			inputFrame.editBox:SetScript("OnEscapePressed", function(self)
				self:ClearFocus()
				retractInputFrame()
			end)

			inputFrame.deploy = deployInputFrame
			inputFrame.retract = retractInputFrame
			inputFrame.deploy()
		elseif inputFrame:IsShown() then
			inputFrame.retract()
			inputFrame.editBox:SetText("")
		else
			inputFrame.deploy()
			inputFrame.editBox:SetText("")
			inputFrame.editBox:SetFocus()
		end
	end)

	--FauxScrollFrame for the tagList

	local scrollFrame = CreateFrame("ScrollFrame", nil, tagListPanel, "FauxScrollFrameTemplate")
	scrollFrame:SetPoint("TOPLEFT", tagListPanel, "TOPLEFT", 10, -30)
	scrollFrame:SetPoint("BOTTOMRIGHT", tagListPanel, "BOTTOMRIGHT", -7.5, 2.5)
	scrollFrame:Show()

	local content = CreateFrame("Frame", nil, scrollFrame)
	content:SetPoint("TOPLEFT", scrollFrame, "TOPLEFT", 0, 0)
	content:SetPoint("BOTTOMRIGHT", scrollFrame, "BOTTOMRIGHT", 0, 0)
	content:Show()

	tinsert(panelContent, scrollFrame)
	tinsert(panelContent, content)

	local rowHeight = 25
	local visibleRows = 9
	local rowSpacing = 5

	content.displayRows = content.displayRows or {}

	local function clearNpcCategoryFilterPool()
		for i = #PhaseToolkit.NPCcategoryToFilterPool, 1, -1 do
			table.remove(PhaseToolkit.NPCcategoryToFilterPool, i)
		end
	end

	local function keepOnlyNpcCategoryInFilterPool(categoryId)
		for i = #PhaseToolkit.NPCcategoryToFilterPool, 1, -1 do
			if PhaseToolkit.NPCcategoryToFilterPool[i] ~= categoryId then
				table.remove(PhaseToolkit.NPCcategoryToFilterPool, i)
			end
		end
	end

	local function createRow(index)
		local row = CreateFrame("Button", "PTK_TAG_ROW"..index, content)
		row:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -((index - 1) * (rowHeight + rowSpacing)))
		row:SetSize(202.5,rowHeight)

		row.background = row:CreateTexture(nil, "BACKGROUND")
		row.background:SetTexture("Interface\\AddOns\\"..addonName.."\\assets\\BlueprintManagerFrameBackground.blp")
		row.background:SetTexCoord(
			77/512, (77+360)/512,   -- left, right (77 to 437)
			26/128, (26+78)/128     -- top, bottom (26 to 104)
		);
		row.background:SetAllPoints(row)

		row.highlight = row:CreateTexture(nil, "OVERLAY")
		row.highlight:SetTexture("Interface\\AddOns\\"..addonName.."\\assets\\BlueprintManagerFrameForeground.blp")
		row.highlight:SetTexCoord(
			77/512, (77+360)/512,   -- left, right (77 to 437)
			26/128, (26+78)/128     -- top, bottom (26 to 104)
		);
		row.highlight:SetAllPoints(row.background)
		row.highlight:Hide()

		row.label = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
		row.label:SetPoint("LEFT", row, "LEFT", 5, 0)
		row.label:SetJustifyH("LEFT")
		row.label:SetWordWrap(false)
		row.label:SetNonSpaceWrap(true)

		row.deleteButton = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
		row.deleteButton:SetSize(20, 20)
		row.deleteButton:SetPoint("RIGHT", row, "RIGHT", -2.5, 0)
		row.deleteButton.icon = row.deleteButton:CreateTexture(nil, "OVERLAY")
		row.deleteButton.icon:SetTexture("Interface\\AddOns\\"..addonName.."\\assets\\BPMXButton.blp")
		row.deleteButton.icon:SetAllPoints()
		row.deleteButton:SetFrameStrata("HIGH")

		PhaseToolkit.RegisterTooltip(row.deleteButton, "Delete this category")

		row.EditionMode = false

		row:SetScript("OnEnter", function(self)
			if self.fullText then
				PhaseToolkit.ShowTooltip(self, self.fullText)
			end
			self.highlight:Show()
		end)

		row:SetScript("OnLeave", function(self)
			PhaseToolkit.HideTooltip()
			if not isKeyInArray(PhaseToolkit.NPCcategoryToFilterPool, self.category.id) and not self.EditionMode then
				self.highlight:Hide()
			end
		end)

		return row
	end



	local function updateScrollFrame()
		local offset = FauxScrollFrame_GetOffset(scrollFrame)
		local tagList = PhaseToolkit.NPCcategoryList or {}

		for i = 1, visibleRows do
			local tagIndex = offset + i
			local row = content.displayRows[i]
			local category = tagList[tagIndex]

			if(not row) then
				row = createRow(i)
				content.displayRows[i] = row
			end

			if category then
				local fullName = category.name or ""
				SetCroppedTextWithTooltip(row, row.label, fullName, 180)
				row.category=category
				row.EditionMode = (PhaseToolkit.SelectedCategory and PhaseToolkit.SelectedCategory.id == category.id) or false

				row.deleteButton:SetScript("OnClick", function()
					StaticPopup_Show("CONFIRM_DELETE_CATEGORY_NPC", nil, nil, {
						deleteIndex = tagIndex,
						funcOnYes = function()
							if PhaseToolkit.SelectedCategory and PhaseToolkit.SelectedCategory.id == category.id then
								PhaseToolkit.SelectedCategory = nil
							end
							deleteKeyFromArray(PhaseToolkit.NPCcategoryToFilterPool, category.id)
							PhaseToolkit.RefreshNpcListView(true)
							scrollFrame.refreshTagListPreserveOffset()
						end
					})
				end)

				row:SetScript("OnMouseDown", function(self, button)
					if button == "LeftButton" then
						if PhaseToolkit.SelectedCategory then
							if PhaseToolkit.SelectedCategory.id ~= category.id then
								PhaseToolkit.SelectedCategory = nil
							else
								keepOnlyNpcCategoryInFilterPool(category.id)
							end
						end

						--if the category is already in the filter pool, we remove it, otherwise we add it
						if isKeyInArray(PhaseToolkit.NPCcategoryToFilterPool, category.id) then
							deleteKeyFromArray(PhaseToolkit.NPCcategoryToFilterPool, category.id)
						else
							tinsert(PhaseToolkit.NPCcategoryToFilterPool, category.id)
						end
						PhaseToolkit.RefreshNpcListView(true)
						scrollFrame.refreshTagListPreserveOffset()
					end
					if button == "RightButton" then
						local willSelect = (not PhaseToolkit.SelectedCategory) or (PhaseToolkit.SelectedCategory.id ~= category.id)
						if willSelect then
							local isSameDisplayed = (#PhaseToolkit.NPCcategoryToFilterPool == 1) and isKeyInArray(PhaseToolkit.NPCcategoryToFilterPool, category.id)
							if not isSameDisplayed then
								clearNpcCategoryFilterPool()
							end
						end

						if not PhaseToolkit.SelectedCategory then
							PhaseToolkit.SelectedCategory = category
							row.EditionMode = true
						else
							if PhaseToolkit.SelectedCategory.id == category.id then
								PhaseToolkit.SelectedCategory = nil
								row.EditionMode = false
							else
								PhaseToolkit.SelectedCategory = category
								row.EditionMode = true
							end
						end
						PhaseToolkit.RefreshNpcListView(true)
						scrollFrame.refreshTagListPreserveOffset()
					end
				end)

				if row.EditionMode then
					row.highlight:SetVertexColor(0, 0, 1, 1)
					row.highlight:Show()
				elseif isKeyInArray(PhaseToolkit.NPCcategoryToFilterPool, category.id) then
					row.highlight:SetVertexColor(0, 1, 0, 1)
					row.highlight:Show()
				else
					row.highlight:SetVertexColor(1, 1, 1, 1)
					row.highlight:Hide()
				end

				row:Show()

			else
				row:Hide()
			end
		end

		if(#tagList > visibleRows) then
			FauxScrollFrame_Update(scrollFrame, #tagList, visibleRows, rowHeight)
		end
	end

	 scrollFrame.refreshTagListPreserveOffset= function ()
		local currentOffset = FauxScrollFrame_GetOffset(scrollFrame) or 0
		local maxOffset = math.max(0, #(PhaseToolkit.NPCcategoryList or {}) - visibleRows)
		currentOffset = math.max(0, math.min(currentOffset, maxOffset))

		if scrollFrame.ScrollBar and scrollFrame.ScrollBar.SetValue then
			scrollFrame.ScrollBar:SetValue(currentOffset * rowHeight)
		end

		if FauxScrollFrame_SetOffset then
			FauxScrollFrame_SetOffset(scrollFrame, currentOffset)
		end

		updateScrollFrame()
	end



	scrollFrame:SetScript("OnVerticalScroll", function(self, offset)
		FauxScrollFrame_OnVerticalScroll(self, offset, rowHeight, updateScrollFrame)
	end)

	tinsert(deployingFrameContext, scrollFrame)
	tinsert(deployingFrameContext, content)

	scrollFrame.ScrollBar:SetPoint("TOPLEFT", scrollFrame, "TOPRIGHT", -12.5, -15)
	scrollFrame.ScrollBar:SetFrameStrata("HIGH")
	scrollFrame.ScrollBar:Show()

	tinsert(panelContent, scrollFrame.ScrollBar)

	tagListPanel:Hide()
	tagListPanel.isHiddenByDefault = true
	table.insert(deployingFrameContext, tagListPanel)
	PhaseToolkit.DeployingFrame.tagListPanel = tagListPanel
	PhaseToolkit.DeployingFrame.tagListPanel.content = panelContent
	PhaseToolkit.DeployingFrame.tagListPanel.rowHeight = rowHeight
	PhaseToolkit.DeployingFrame.tagListPanel.visibleRows = visibleRows
	PhaseToolkit.DeployingFrame.tagListPanel.UpdateRows = updateScrollFrame

	createDeployRetractAnimsForFrame(PhaseToolkit.DeployingFrame.tagListPanel, 60, 0, {
		onPlayDeploy = function()
			hideContent(PhaseToolkit.DeployingFrame.tagListPanel.content)
			PhaseToolkit.DeployingFrame.tagListPanel:Show()
			PhaseToolkit.DeployingFrame.tagListPanel.UpdateRows()

		end,
		onFinishedDeploy = function()
			showContent(PhaseToolkit.DeployingFrame.tagListPanel.content)

		end,
		onPlayRetract = function()
			hideContent(PhaseToolkit.DeployingFrame.tagListPanel.content)

		end,
		onFinishedRetract = function()
			PhaseToolkit.DeployingFrame.tagListPanel:Hide()

		end,
	})

end

function PhaseToolkit.OpenNpcList()
	if PhaseToolkit.context.id ~="NONE" then
		PhaseToolkit.changeContext(deployingFrameContext["NONE"])
	end

	local context = {}
	context.id="NPCLIST"
	PhaseToolkit.extendDeployingFrame(450)

	if not PhaseToolkit.DeployingFrame.NpcListSearchBox then
		local searchBox = CreateFrame("EditBox", nil, PhaseToolkit.DeployingFrame, "InputBoxTemplate")
		searchBox:SetSize(155, 20)
		searchBox:SetPoint("TOPLEFT", PhaseToolkit.DeployingFrame, "TOPLEFT", 62.5, -62.5)
		searchBox:SetAutoFocus(false)
		searchBox:SetFontObject(GameFontHighlightSmall)
		searchBox:SetMaxLetters(100)
		searchBox:SetTextInsets(5, 5, 0, 0)

		searchBox:SetScript("OnTextChanged", function(self)
			PhaseToolkit.CurrenttextToLookForNpc = self:GetText()
			PhaseToolkit.RefreshNpcListView()
		end)

		tinsert(context, searchBox)
		PhaseToolkit.DeployingFrame.NpcListSearchBox = searchBox
	end

	if not PhaseToolkit.DeployingFrame.NpcListTagListButton then
		local tagListButton = CreateFrame("Button", nil, PhaseToolkit.DeployingFrame, "UIPanelButtonTemplate")
		tagListButton:SetSize(20, 20)
		tagListButton:SetPoint("TOPLEFT", PhaseToolkit.DeployingFrame, "TOPLEFT", 10, -62.5)
		tagListButton.icon = tagListButton:CreateTexture(nil, "OVERLAY")
		tagListButton.icon:SetTexture("Interface\\AddOns\\"..addonName.."\\assets\\eps_ptk_icon_list.blp")
		tagListButton.icon:SetAllPoints()
		tagListButton:SetFrameStrata("HIGH")

		tagListButton:SetScript("OnClick", function()
			if not PhaseToolkit.DeployingFrame.tagListPanel then
				PhaseToolkit.CreateTagList(deployingFrameContext["NPCLIST"],context)
			end

			local shouldShow = not PhaseToolkit.DeployingFrame.tagListPanel:IsShown()
			if shouldShow then
				PhaseToolkit.getNpcCategoryFromPhaseData(function()
					deployTagListPanel(deployingFrameContext["NPCLIST"],context)
				end)
			else
				retractTagListPanel(deployingFrameContext["NPCLIST"],context)
			end
		end)

		tinsert(context, tagListButton)

		PhaseToolkit.RegisterTooltip(tagListButton, "Open the NPC Tag List")
		PhaseToolkit.DeployingFrame.NpcListTagListButton = tagListButton
	end

	if not PhaseToolkit.DeployingFrame.tagListPanel then
		PhaseToolkit.CreateTagList(deployingFrameContext["NPCLIST"],context)
	end

	if not PhaseToolkit.DeployingFrame.NpcListRefreshButton then
		local refreshButton = CreateFrame("Button", nil, PhaseToolkit.DeployingFrame, "UIPanelButtonTemplate")
		refreshButton:SetSize(25, 25)
		refreshButton:SetPoint("TOPLEFT", PhaseToolkit.DeployingFrame, "TOPLEFT", 32.5, -60)
		refreshButton.icon = refreshButton:CreateTexture(nil, "OVERLAY")
		refreshButton.icon:SetTexture("Interface\\AddOns\\"..addonName.."\\assets\\BPMRefreshButton.blp")
		refreshButton.icon:SetAllPoints()
		refreshButton:SetFrameStrata("HIGH")

		refreshButton:SetScript("OnClick", function()
			if PhaseToolkit.isNpcListRefreshInProgress then
				return
			end
			PhaseToolkit.isNpcListRefreshInProgress = true
			refreshButton:Disable()
			refreshButton:SetAlpha(0.5)
			PhaseToolkit.creatureList = {}
			sendAddonCmd("ph f n list", parseReplies, false)
		end)

		tinsert(context, refreshButton)

		PhaseToolkit.RegisterTooltip(refreshButton, "Refresh the NPC List")
		PhaseToolkit.DeployingFrame.NpcListRefreshButton = refreshButton
	end


	local scrollFrame, content

	if not PhaseToolkit.DeployingFrame.NpcListScrollFrame then
		scrollFrame = CreateFrame("ScrollFrame", nil, PhaseToolkit.DeployingFrame, "FauxScrollFrameTemplate")
		scrollFrame:SetPoint("TOPLEFT", PhaseToolkit.DeployingFrame, "TOPLEFT", 5, -70)
		scrollFrame:SetPoint("BOTTOMRIGHT", PhaseToolkit.DeployingFrame, "BOTTOMRIGHT", -10, 10)
		scrollFrame:Show()
		PhaseToolkit.DeployingFrame.NpcListScrollFrame = scrollFrame
	else
		scrollFrame = PhaseToolkit.DeployingFrame.NpcListScrollFrame
		scrollFrame:Show()
	end

	if not PhaseToolkit.DeployingFrame.NpcListContent then
		content = CreateFrame("Frame", nil, scrollFrame)
		content:SetPoint("TOPLEFT", scrollFrame, "TOPLEFT", 0, -10)
		content:SetPoint("BOTTOMRIGHT", scrollFrame, "BOTTOMRIGHT", 0, 0)
		content:Show()
		PhaseToolkit.DeployingFrame.NpcListContent = content
	else
		content = PhaseToolkit.DeployingFrame.NpcListContent
		content:Show()
	end

	local rowHeight = 32
	local visibleRows = 11
	content.displayRows = content.displayRows or {}

	local function createRow(index)
		local row = CreateFrame("Button", "PTK_NPC_ROW"..index, content)
		row:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -((index - 1) * rowHeight))
		row:SetPoint("TOPRIGHT", content, "TOPRIGHT", 0, -((index - 1) * rowHeight))
		row:SetHeight(rowHeight)

		row.background = row:CreateTexture(nil, "BACKGROUND")
		row.background:SetTexture("Interface\\AddOns\\"..addonName.."\\assets\\BlueprintManagerFrameBackground.blp")
		row.background:SetSize(310,35)
		row.background:SetPoint("TOPLEFT", row, "TOPLEFT", -50, 0)

		row.highlight = row:CreateTexture(nil, "OVERLAY")
		row.highlight:SetTexture("Interface\\AddOns\\"..addonName.."\\assets\\BlueprintManagerFrameForeground.blp")
		row.highlight:SetSize(215,28)
		row.highlight:SetTexCoord(
			77/512, (77+360)/512,   -- left, right (77 to 437)
			26/128, (26+78)/128     -- top, bottom (26 to 104)
		);
		row.highlight:SetPoint("CENTER", row, "CENTER", -15, 0)
		row.highlight:Hide()

		row.label = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
		row.label:SetPoint("LEFT", row, "LEFT", 0, 0)
		row.label:SetJustifyH("LEFT")
		row.label:SetWordWrap(false)
		row.label:SetNonSpaceWrap(true)

		row.deleteButton = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
		row.deleteButton:SetSize(20, 20)
		row.deleteButton:SetPoint("RIGHT", row, "RIGHT", -12.5, 0)

		row.deleteButton.icon = row.deleteButton:CreateTexture(nil, "OVERLAY")
		row.deleteButton.icon:SetTexture("Interface\\AddOns\\"..addonName.."\\assets\\BPMXButton.blp")
		row.deleteButton.icon:SetAllPoints()
		row.deleteButton:SetFrameStrata("HIGH")

		row.categoryManagementButton = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
		row.categoryManagementButton:SetSize(20, 20)
		row.categoryManagementButton:SetPoint("RIGHT", row, "RIGHT", -12.5, 0)
		row.categoryManagementButton.icon = row.categoryManagementButton:CreateTexture(nil, "OVERLAY")
		row.categoryManagementButton.icon:SetTexture("Interface\\AddOns\\"..addonName.."\\assets\\eps_ptk_icon_list.blp")
		row.categoryManagementButton.icon:SetAllPoints()
		row.categoryManagementButton:SetFrameStrata("HIGH")
		row.categoryManagementButton:Hide()

		row.categoryManagementState = "ADD"

		row:SetScript("OnMouseDown", function(self, button)
			if button == "LeftButton" and self.npcId then
				sendAddonCmd("n spawn "..self.npcId, nil, false)
			end
		end)

		-- if we are on ADD mode, we add the npc to the selected category, if we are on REMOVE mode, we remove it from the selected category
		row.categoryManagementButton:SetScript("OnMouseDown", function(self, button)
			if button == "LeftButton" and self:GetParent() and self:GetParent().npcId then
				if PhaseToolkit.SelectedCategory then
					if self:GetParent().categoryManagementState == "ADD" then
						tinsert(PhaseToolkit.SelectedCategory.members,self:GetParent().npcId)
						self:GetParent().categoryManagementState = "REMOVE"
						row.categoryManagementButton.icon:SetTexture("Interface\\AddOns\\"..addonName.."\\assets\\BPMBackButton.blp")
					else
						if(isKeyInArray(PhaseToolkit.SelectedCategory.members,self:GetParent().npcId)) then
							PhaseToolkit.SelectedCategory.members = deleteKeyFromArray(PhaseToolkit.SelectedCategory.members,self:GetParent().npcId)
							self:GetParent().categoryManagementState = "ADD"
							row.categoryManagementButton.icon:SetTexture("Interface\\AddOns\\"..addonName.."\\assets\\BPMAddButton.blp")
						end
					end
				end
				PhaseToolkit.saveNpcCategoryDataToServer()
				PhaseToolkit.RefreshNpcListView(true)
			end
		end)

		row.deleteButton:SetScript("OnMouseDown", function(self, button)
			if button == "LeftButton" then
				local parent = self:GetParent()
				if parent and parent.npcId then
					StaticPopup_Show("CONFIRM_DELETE_NPC", nil, nil, { npcId = parent.npcId })
				end
			end
		end)


		row:SetScript("OnEnter", function(self)
			if self.fullText then
				PhaseToolkit.ShowTooltip(self, self.fullText)
			end
			self.highlight:Show()
		end)

		row:SetScript("OnLeave", function(self)
			PhaseToolkit.HideTooltip()
			self.highlight:Hide()
		end)
		return row
	end

	local function updateScrollFrame()
		local data = PhaseToolkit.npcListView or PhaseToolkit.creatureList or {}
		local totalRows = #data

		if(totalRows>11) then
			FauxScrollFrame_Update(scrollFrame, totalRows, visibleRows, rowHeight)
		end

		local offset = 0
		if FauxScrollFrame_GetOffset then
			offset = FauxScrollFrame_GetOffset(scrollFrame) or 0
		elseif scrollFrame.ScrollBar and scrollFrame.ScrollBar.GetValue then
			offset = math.floor((scrollFrame.ScrollBar:GetValue() or 0) / rowHeight)
		end

		local maxOffset = math.max(0, totalRows - visibleRows)
		offset = math.max(0, math.min(offset, maxOffset))

		if scrollFrame.ScrollBar and scrollFrame.ScrollBar.SetValue then
			scrollFrame.ScrollBar:SetValue(offset * rowHeight)
		end

		if FauxScrollFrame_SetOffset then
			FauxScrollFrame_SetOffset(scrollFrame, offset)
		else
			scrollFrame.offset = offset
		end

		for i = 1, visibleRows do
			local npcIndex = offset + i
			local row = content.displayRows[i]

			if not row then
				row = createRow(i)
				content.displayRows[i] = row
			end

			local npcData = data[npcIndex]
			if npcData then
				row.npcId = npcData.IdCreature
				local fullName = npcData.NomCreature or ""
				SetCroppedTextWithTooltip(row, row.label, fullName, 210)
				if(PhaseToolkit.SelectedCategory) then
					row.deleteButton:Hide()
					row.categoryManagementButton:Show()
				else
					row.deleteButton:Show()
					row.categoryManagementButton:Hide()
				end
				if checkIfCreatureInSelectedCategory(npcData) then
					row.categoryManagementState = "REMOVE"
					row.categoryManagementButton.icon:SetTexture("Interface\\AddOns\\"..addonName.."\\assets\\BPMBackButton.blp")
				else
					row.categoryManagementState = "ADD"
					row.categoryManagementButton.icon:SetTexture("Interface\\AddOns\\"..addonName.."\\assets\\BPMAddButton.blp")
				end
				row:Show()
			else
				row.npcId = nil
				row:Hide()
			end
		end
	end

	scrollFrame:SetScript("OnVerticalScroll", function(self, offset)
		FauxScrollFrame_OnVerticalScroll(self, offset, rowHeight, updateScrollFrame)
	end)

	PhaseToolkit.DeployingFrame.NpcListScrollFrame .rowHeight = rowHeight
	PhaseToolkit.DeployingFrame.NpcListScrollFrame .visibleRows = visibleRows
	PhaseToolkit.DeployingFrame.NpcListScrollFrame .UpdateRows = updateScrollFrame


	PhaseToolkit.DeployingFrame.NpcListContent = content



	scrollFrame.ScrollBar:SetPoint("TOPRIGHT", scrollFrame, "TOPRIGHT", -15, -12)
	scrollFrame.ScrollBar:SetPoint("BOTTOMRIGHT", scrollFrame, "BOTTOMRIGHT",-15, 15)
	scrollFrame.ScrollBar:SetFrameStrata("HIGH")

	tinsert(context, scrollFrame)
	tinsert(context, content)

	if(#deployingFrameContext["NPCLIST"]<1) then
		deployingFrameContext["NPCLIST"] = context
	end

	PhaseToolkit.changeContext(deployingFrameContext["NPCLIST"])
	PhaseToolkit.DeployingFrame.NpcListScrollFrame:Show()
	PhaseToolkit.RefreshNpcListView()
end

local function BuildTeleListView()
	local source = PhaseToolkit.teleList or {}
	local hasCategoryFilter = PhaseToolkit.TELEcategoryToFilterPool and #PhaseToolkit.TELEcategoryToFilterPool > 0
	local byCategory = {}

	if hasCategoryFilter then
		local allowedNames = {}

		for _, categoryId in ipairs(PhaseToolkit.TELEcategoryToFilterPool) do
			local category = PhaseToolkit.getCategoryByIdGENERIC(categoryId, "TELE")
			if category and category.members then
				for _, memberName in ipairs(category.members) do
					allowedNames[tostring(memberName)] = true
				end
			end
		end

		for _, teleName in ipairs(source) do
			if allowedNames[tostring(teleName)] then
				table.insert(byCategory, teleName)
			end
		end

		if #byCategory == 0 and #source > 0 then
			byCategory = source
		end
	else
		byCategory = source
	end

	local query = (PhaseToolkit.CurrenttextToLookForTele or ""):lower()
	if query == "" then
		return byCategory
	end

	local filtered = {}
	for _, teleName in ipairs(byCategory) do
		local name = tostring(teleName or ""):lower()
		if string.find(name, query) then
			table.insert(filtered, teleName)
		end
	end

	return filtered
end

function PhaseToolkit.RefreshTeleListView(preserveOffset)
	PhaseToolkit.teleListView = BuildTeleListView()

	local scrollFrame = PhaseToolkit.DeployingFrame.TeleListScrollFrame
	if not scrollFrame then
		return
	end

	local rowHeight = scrollFrame.rowHeight or 32
	local visibleRows = scrollFrame.visibleRows or 11
	local maxOffset = math.max(0, #PhaseToolkit.teleListView - visibleRows)
	local targetOffset = 0

	if preserveOffset then
		if FauxScrollFrame_GetOffset then
			targetOffset = FauxScrollFrame_GetOffset(scrollFrame) or 0
		elseif scrollFrame.ScrollBar and scrollFrame.ScrollBar.GetValue then
			targetOffset = math.floor((scrollFrame.ScrollBar:GetValue() or 0) / rowHeight)
		end
	end

	if scrollFrame.ScrollBar and scrollFrame.ScrollBar.GetValue and scrollFrame.ScrollBar.SetValue then
		targetOffset = math.max(0, math.min(targetOffset, maxOffset))
		scrollFrame.ScrollBar:SetValue(targetOffset * rowHeight)
	end

	if FauxScrollFrame_SetOffset then
		FauxScrollFrame_SetOffset(scrollFrame, targetOffset)
		scrollFrame.offset = targetOffset
	end

	PhaseToolkit.DeployingFrame.TeleListScrollFrame:UpdateRows()
end

local function parseTeleListReplies(isCommandSuccessful, repliesList)
	local function SetTeleListRefreshLoadingState(isLoading)
		PhaseToolkit.isTeleListRefreshInProgress = isLoading and true or false
		local refreshButton = PhaseToolkit.DeployingFrame and PhaseToolkit.DeployingFrame.TeleListRefreshButton
		if refreshButton then
			if isLoading then
				refreshButton:Disable()
				refreshButton:SetAlpha(0.5)
			else
				refreshButton:Enable()
				refreshButton:SetAlpha(1)
			end
		end
	end

	if isCommandSuccessful then
		for i = 1, #repliesList do
			local message = repliesList[i]
			message = message:gsub("|cff%x%x%x%x%x%x", ""):gsub("|r", "")
			local isHeader = string.find(message, "We have found ") ~= nil
			local teleName = string.match(message, "%[(.+)%]")

			if not isHeader and teleName and teleName ~= "" then
				teleName = teleName:gsub("%[", ""):gsub("%]", "")
				table.insert(PhaseToolkit.teleList, teleName)
			end
		end

		PhaseToolkit.teleList = PhaseToolkit.RemoveDuplicates(PhaseToolkit.teleList)
		if PhaseToolkit.context.id == "TELELIST" and PhaseToolkit.DeployingFrame.TeleListScrollFrame then
			PhaseToolkit.RefreshTeleListView()
		else
			PhaseToolkit.OpenTeleList()
		end
	end

	SetTeleListRefreshLoadingState(false)
end

function PhaseToolkit.createTELEList()
	if not PhaseToolkit.teleList or #PhaseToolkit.teleList == 0 then
		PhaseToolkit.teleList = {}
		sendAddonCmd("ph tele list", parseTeleListReplies, false)
	else
		PhaseToolkit.OpenTeleList()
	end
end


local function deployTeleTagListPanel(contentContext, deployingFrameContext)
	local AnimationGroup = PhaseToolkit.DeployingFrame.teleTagListPanel.animGroupDeploy
	AnimationGroup:Play()
end

local function retractTeleTagListPanel(contentContext, deployingFrameContext)
	local AnimationGroup = PhaseToolkit.DeployingFrame.teleTagListPanel.animGroupRetract
	AnimationGroup:Play()
end

function PhaseToolkit.CreateTeleTagList(contentContext, deployingFrameContext)
	local tagListPanel = CreateFrame("Frame", nil, PhaseToolkit.DeployingFrame, "PortraitFrameTemplate")
	tagListPanel:SetSize(235, 300)
	tagListPanel:SetPoint("RIGHT", PhaseToolkit.DeployingFrame, "LEFT", 0, 20)
	ButtonFrameTemplateMinimizable_HidePortrait(tagListPanel)
	NineSliceUtil.ApplyLayoutByName(tagListPanel.NineSlice, "EpsilonGoldBorderFrameTemplateNoPortrait")
	EpsilonLib.Utils.NineSlice.CropNineSliceCorners(tagListPanel.NineSlice, 0.8, true)
	EpsilonLib.Utils.NineSlice.CropNineSliceCorners(tagListPanel.NineSlice, 0.4)
	EpsilonLib.Utils.NineSlice.SetBackgroundAsViewport(tagListPanel, tagListPanel.Bg)
	tagListPanel:SetFrameStrata("LOW")
	local titleBgColor = tagListPanel:CreateTexture(nil, "BACKGROUND")
	local color = CreateColorFromHexString("80FF7100")
	titleBgColor:SetPoint("TOPLEFT", tagListPanel.TitleBg)
	titleBgColor:SetPoint("BOTTOMRIGHT", tagListPanel.TitleBg, -0, 0)
	titleBgColor:SetColorTexture(color:GetRGBA())
	tagListPanel.TitleBgColor = titleBgColor
	tagListPanel.TitleText:SetText("Tele Tag List")
	tagListPanel.TitleText:SetPoint("LEFT", tagListPanel.TitleBg, "LEFT", 30, 0)

	local panelContent = {}

	local createCategoryButton = CreateFrame("Button", nil, tagListPanel, "UIPanelButtonTemplate")
	createCategoryButton:SetSize(20, 20)
	createCategoryButton:SetPoint("TOPLEFT", tagListPanel, "TOPLEFT", 0, 0)
	createCategoryButton.icon = createCategoryButton:CreateTexture(nil, "OVERLAY")
	createCategoryButton.icon:SetAtlas("GreenCross")
	createCategoryButton.icon:SetAllPoints()
	PhaseToolkit.RegisterTooltip(createCategoryButton, "Create Category")
	tinsert(panelContent, createCategoryButton)

	local fetchCategoryButton = CreateFrame("Button", nil, tagListPanel, "UIPanelButtonTemplate")
	fetchCategoryButton:SetSize(20, 20)
	fetchCategoryButton:SetPoint("LEFT", createCategoryButton, "RIGHT", 2, -1)
	fetchCategoryButton.icon = fetchCategoryButton:CreateTexture(nil, "OVERLAY")
	fetchCategoryButton.icon:SetTexture("Interface\\AddOns\\"..addonName.."\\assets\\BPMRefreshButton.blp")
	fetchCategoryButton.icon:SetAllPoints()
	fetchCategoryButton:SetFrameStrata("HIGH")
	fetchCategoryButton:SetScript("OnClick", function()
		PhaseToolkit.getTeleCategoryFromPhaseData(function()
			if tagListPanel and tagListPanel.UpdateRows then
				tagListPanel.UpdateRows()
			end
			PhaseToolkit.RefreshTeleListView(true)
		end)
	end)
	PhaseToolkit.RegisterTooltip(fetchCategoryButton, "Fetch Categories")
	tinsert(panelContent, fetchCategoryButton)

	local inputFrame = nil
	createCategoryButton:SetScript("OnClick", function()
		if not inputFrame then
			inputFrame = CreateFrame("Frame", nil, tagListPanel, "PortraitFrameTemplate")
			inputFrame:SetSize(235, 90)
			inputFrame:SetPoint("BOTTOM", tagListPanel, "TOP", 0, 2.5)
			ButtonFrameTemplateMinimizable_HidePortrait(inputFrame)
			NineSliceUtil.ApplyLayoutByName(inputFrame.NineSlice, "EpsilonGoldBorderFrameTemplateNoPortrait")
			EpsilonLib.Utils.NineSlice.CropNineSliceCorners(inputFrame.NineSlice, 0.8, true)
			EpsilonLib.Utils.NineSlice.CropNineSliceCorners(inputFrame.NineSlice, 0.4)
			EpsilonLib.Utils.NineSlice.SetBackgroundAsViewport(inputFrame, inputFrame.Bg)
			inputFrame:SetFrameStrata("DIALOG")
			local inputTitleBgColor = inputFrame:CreateTexture(nil, "BACKGROUND")
			local inputTitleColor = CreateColorFromHexString("80FF7100")
			inputTitleBgColor:SetPoint("TOPLEFT", inputFrame.TitleBg)
			inputTitleBgColor:SetPoint("BOTTOMRIGHT", inputFrame.TitleBg, -0, 0)
			inputTitleBgColor:SetColorTexture(inputTitleColor:GetRGBA())
			inputFrame.TitleBgColor = inputTitleBgColor
			inputFrame.TitleText:SetText("Create Category")
			inputFrame.TitleText:SetPoint("LEFT", inputFrame.TitleBg, "LEFT", 30, 0)

			local deployAnimation = inputFrame:CreateAnimationGroup("DeployTeleCategoryInputFrame")
			local deployFade = deployAnimation:CreateAnimation("Alpha")
			deployFade:SetOrder(1)
			deployFade:SetFromAlpha(0)
			deployFade:SetToAlpha(1)
			deployFade:SetDuration(0.5)
			deployFade:SetSmoothing("OUT")

			local deployScale = deployAnimation:CreateAnimation("Scale")
			deployScale:SetOrder(1)
			deployScale:SetFromScale(1.0, 0.1)
			deployScale:SetToScale(1.0, 1.0)
			deployScale:SetDuration(0.5)
			deployScale:SetSmoothing("OUT")
			deployScale:SetOrigin("BOTTOM", 0, 0)

			deployAnimation:SetScript("OnPlay", function()
				inputFrame:Show()
			end)
			deployAnimation:SetScript("OnFinished", function()
				inputFrame:SetAlpha(1)
				inputFrame:Show()
			end)

			local retractAnimation = inputFrame:CreateAnimationGroup("RetractTeleCategoryInputFrame")
			local retractFade = retractAnimation:CreateAnimation("Alpha")
			retractFade:SetOrder(1)
			retractFade:SetFromAlpha(1)
			retractFade:SetToAlpha(0)
			retractFade:SetDuration(0.5)
			retractFade:SetSmoothing("OUT")

			local retractScale = retractAnimation:CreateAnimation("Scale")
			retractScale:SetOrder(1)
			retractScale:SetFromScale(1.0, 1.0)
			retractScale:SetToScale(1.0, 0.1)
			retractScale:SetDuration(0.5)
			retractScale:SetSmoothing("OUT")
			retractScale:SetOrigin("BOTTOM", 0, 0)

			retractAnimation:SetScript("OnFinished", function()
				inputFrame:Hide()
				inputFrame:SetAlpha(1)
			end)

			inputFrame.deployAnimation = deployAnimation
			inputFrame.retractAnimation = retractAnimation
			inputFrame:Hide()

			local function deployInputFrame()
				if inputFrame.retractAnimation and inputFrame.retractAnimation:IsPlaying() then
					inputFrame.retractAnimation:Stop()
				end
				inputFrame:Show()
				inputFrame:SetAlpha(1)
				if inputFrame.deployAnimation and inputFrame.deployAnimation:IsPlaying() then
					inputFrame.deployAnimation:Stop()
				end
				inputFrame.deployAnimation:Play()
			end

			local function retractInputFrame()
				if not inputFrame:IsShown() then
					return
				end
				if inputFrame.deployAnimation and inputFrame.deployAnimation:IsPlaying() then
					inputFrame.deployAnimation:Stop()
				end
				inputFrame.retractAnimation:Play()
			end

			inputFrame.editBox = CreateFrame("EditBox", nil, inputFrame, "InputBoxTemplate")
			inputFrame.editBox:SetSize(180, 24)
			inputFrame.editBox:SetPoint("TOP", inputFrame.TitleBg, "BOTTOM", 0, -18)
			inputFrame.editBox:SetAutoFocus(true)

			inputFrame.editBox:SetScript("OnEnterPressed", function(self)
				local categoryName = self:GetText()
				if categoryName and categoryName ~= "" then
					PhaseToolkit.CreateNewTELECategory(categoryName, function()
						if tagListPanel and tagListPanel.UpdateRows then
							tagListPanel.UpdateRows()
						end
					end)
				end
				self:ClearFocus()
				retractInputFrame()
			end)

			inputFrame.editBox:SetScript("OnEscapePressed", function(self)
				self:ClearFocus()
				retractInputFrame()
			end)

			inputFrame.deploy = deployInputFrame
			inputFrame.retract = retractInputFrame
			inputFrame.deploy()
		elseif inputFrame:IsShown() then
			inputFrame.retract()
			inputFrame.editBox:SetText("")
		else
			inputFrame.deploy()
			inputFrame.editBox:SetText("")
			inputFrame.editBox:SetFocus()
		end
		tinsert(deployingFrameContext, inputFrame)
	end)

	local scrollFrame = CreateFrame("ScrollFrame", nil, tagListPanel, "FauxScrollFrameTemplate")
	scrollFrame:SetPoint("TOPLEFT", tagListPanel, "TOPLEFT", 10, -30)
	scrollFrame:SetPoint("BOTTOMRIGHT", tagListPanel, "BOTTOMRIGHT", -7.5, 2.5)
	scrollFrame:Show()
	tinsert(panelContent, scrollFrame)

	local content = CreateFrame("Frame", nil, scrollFrame)
	content:SetPoint("TOPLEFT", scrollFrame, "TOPLEFT", 0, 0)
	content:SetPoint("BOTTOMRIGHT", scrollFrame, "BOTTOMRIGHT", 0, 0)
	content:Show()
	tinsert(panelContent, content)

	local rowHeight = 25
	local visibleRows = 9
	local rowSpacing = 5

	content.displayRows = content.displayRows or {}

	local function clearTeleCategoryFilterPool()
		for i = #PhaseToolkit.TELEcategoryToFilterPool, 1, -1 do
			table.remove(PhaseToolkit.TELEcategoryToFilterPool, i)
		end
	end

	local function keepOnlyTeleCategoryInFilterPool(categoryId)
		for i = #PhaseToolkit.TELEcategoryToFilterPool, 1, -1 do
			if PhaseToolkit.TELEcategoryToFilterPool[i] ~= categoryId then
				table.remove(PhaseToolkit.TELEcategoryToFilterPool, i)
			end
		end
	end

	local function createRow(index)
		local row = CreateFrame("Button", "PTK_TELE_TAG_ROW"..index, content)
		row:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -((index - 1) * (rowHeight + rowSpacing)))
		row:SetSize(202.5,rowHeight)

		row.background = row:CreateTexture(nil, "BACKGROUND")
		row.background:SetTexture("Interface\\AddOns\\"..addonName.."\\assets\\BlueprintManagerFrameBackground.blp")
		row.background:SetAllPoints(row)
		row.background:SetTexCoord(
			77/512, (77+360)/512,   -- left, right (77 to 437)
			26/128, (26+78)/128     -- top, bottom (26 to 104)
		);

		row.highlight = row:CreateTexture(nil, "OVERLAY")
		row.highlight:SetTexture("Interface\\AddOns\\"..addonName.."\\assets\\BlueprintManagerFrameForeground.blp")
		row.highlight:SetSize(80,25)
		row.highlight:SetAllPoints(row.background)
		row.highlight:SetTexCoord(
			77/512, (77+360)/512,   -- left, right (77 to 437)
			26/128, (26+78)/128     -- top, bottom (26 to 104)
		);
		row.highlight:Hide()

		row.label = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
		row.label:SetPoint("LEFT", row, "LEFT", 5, 0)
		row.label:SetJustifyH("LEFT")
		row.label:SetWordWrap(false)
		row.label:SetNonSpaceWrap(true)

		row.deleteButton = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
		row.deleteButton:SetSize(20, 20)
		row.deleteButton:SetPoint("RIGHT", row, "RIGHT", -2.5, 0)
		row.deleteButton.icon = row.deleteButton:CreateTexture(nil, "OVERLAY")
		row.deleteButton.icon:SetTexture("Interface\\AddOns\\"..addonName.."\\assets\\BPMXButton.blp")
		row.deleteButton.icon:SetAllPoints()
		row.deleteButton:SetFrameStrata("HIGH")

		PhaseToolkit.RegisterTooltip(row.deleteButton, "Delete this category")

		row.EditionMode = false

		row:SetScript("OnEnter", function(self)
			if self.fullText then
				PhaseToolkit.ShowTooltip(self, self.fullText)
			end
			self.highlight:Show()
		end)

		row:SetScript("OnLeave", function(self)
			PhaseToolkit.HideTooltip()
			if not isKeyInArray(PhaseToolkit.TELEcategoryToFilterPool, self.category.id) and not self.EditionMode then
				self.highlight:Hide()
			end
		end)

		return row
	end

	local function updateScrollFrame()
		local offset = FauxScrollFrame_GetOffset(scrollFrame)
		local tagList = PhaseToolkit.TELEcategoryList or {}

		for i = 1, visibleRows do
			local tagIndex = offset + i
			local row = content.displayRows[i]
			local category = tagList[tagIndex]

			if not row then
				row = createRow(i)
				content.displayRows[i] = row
			end

			if category then
				SetCroppedTextWithTooltip(row, row.label, category.name or "", 180)
				row.category = category
				row.EditionMode = (PhaseToolkit.TELEselectedCategory and PhaseToolkit.TELEselectedCategory.id == category.id) or false

				row.deleteButton:SetScript("OnClick", function()
					StaticPopup_Show("CONFIRM_DELETE_CATEGORY_TELE", nil, nil, {
						deleteIndex = tagIndex,
						funcOnYes = function()
							if PhaseToolkit.TELEselectedCategory and PhaseToolkit.TELEselectedCategory.id == category.id then
								PhaseToolkit.TELEselectedCategory = nil
							end
							deleteKeyFromArray(PhaseToolkit.TELEcategoryToFilterPool, category.id)
							PhaseToolkit.RefreshTeleListView(true)
							scrollFrame.refreshTagListPreserveOffset()
						end
					})
				end)

				row:SetScript("OnMouseDown", function(self, button)
					if button == "LeftButton" then
						if PhaseToolkit.TELEselectedCategory then
							if PhaseToolkit.TELEselectedCategory.id ~= category.id then
								PhaseToolkit.TELEselectedCategory = nil
							else
								keepOnlyTeleCategoryInFilterPool(category.id)
							end
						end

						if isKeyInArray(PhaseToolkit.TELEcategoryToFilterPool, category.id) then
							deleteKeyFromArray(PhaseToolkit.TELEcategoryToFilterPool, category.id)
						else
							tinsert(PhaseToolkit.TELEcategoryToFilterPool, category.id)
						end
						PhaseToolkit.RefreshTeleListView(true)
						scrollFrame.refreshTagListPreserveOffset()
					end
					if button == "RightButton" then
						local willSelect = (not PhaseToolkit.TELEselectedCategory) or (PhaseToolkit.TELEselectedCategory.id ~= category.id)
						if willSelect then
							local isSameDisplayed = (#PhaseToolkit.TELEcategoryToFilterPool == 1) and isKeyInArray(PhaseToolkit.TELEcategoryToFilterPool, category.id)
							if not isSameDisplayed then
								clearTeleCategoryFilterPool()
							end
						end

						if not PhaseToolkit.TELEselectedCategory then
							PhaseToolkit.TELEselectedCategory = category
							row.EditionMode = true
						else
							if PhaseToolkit.TELEselectedCategory.id == category.id then
								PhaseToolkit.TELEselectedCategory = nil
								row.EditionMode = false
							else
								PhaseToolkit.TELEselectedCategory = category
								row.EditionMode = true
							end
						end
						PhaseToolkit.RefreshTeleListView(true)
						scrollFrame.refreshTagListPreserveOffset()
					end
				end)

				if row.EditionMode then
					row.highlight:SetVertexColor(0, 0, 1, 1)
					row.highlight:Show()
				elseif isKeyInArray(PhaseToolkit.TELEcategoryToFilterPool, category.id) then
					row.highlight:SetVertexColor(0, 1, 0, 1)
					row.highlight:Show()
				else
					row.highlight:SetVertexColor(1, 1, 1, 1)
					row.highlight:Hide()
				end

				row:Show()
			else
				row:Hide()
			end
		end

		if #tagList > visibleRows then
			FauxScrollFrame_Update(scrollFrame, #tagList, visibleRows, rowHeight)
		end
	end

	scrollFrame.refreshTagListPreserveOffset = function()
		local currentOffset = FauxScrollFrame_GetOffset(scrollFrame) or 0
		local maxOffset = math.max(0, #(PhaseToolkit.TELEcategoryList or {}) - visibleRows)
		currentOffset = math.max(0, math.min(currentOffset, maxOffset))

		if scrollFrame.ScrollBar and scrollFrame.ScrollBar.SetValue then
			scrollFrame.ScrollBar:SetValue(currentOffset * rowHeight)
		end

		if FauxScrollFrame_SetOffset then
			FauxScrollFrame_SetOffset(scrollFrame, currentOffset)
		end

		updateScrollFrame()
	end

	scrollFrame:SetScript("OnVerticalScroll", function(self, offset)
		FauxScrollFrame_OnVerticalScroll(self, offset, rowHeight, updateScrollFrame)
	end)

	tinsert(deployingFrameContext, scrollFrame)
	tinsert(deployingFrameContext, content)

	scrollFrame.ScrollBar:SetPoint("TOPLEFT", scrollFrame, "TOPRIGHT", -12.5, -15)
	scrollFrame.ScrollBar:SetFrameStrata("HIGH")
	scrollFrame.ScrollBar:Show()

	tinsert(panelContent, scrollFrame)
	tinsert(panelContent, content)

	tagListPanel:Hide()
	tagListPanel.isHiddenByDefault = true
	table.insert(deployingFrameContext, tagListPanel)

	tinsert(panelContent, scrollFrame.ScrollBar)

	PhaseToolkit.DeployingFrame.teleTagListPanel = tagListPanel
	PhaseToolkit.DeployingFrame.teleTagListPanel.content = panelContent
	PhaseToolkit.DeployingFrame.teleTagListPanel.rowHeight = rowHeight
	PhaseToolkit.DeployingFrame.teleTagListPanel.visibleRows = visibleRows
	PhaseToolkit.DeployingFrame.teleTagListPanel.UpdateRows = updateScrollFrame

	createDeployRetractAnimsForFrame(PhaseToolkit.DeployingFrame.teleTagListPanel, 60, 0, {
	onPlayDeploy = function()
		hideContent(PhaseToolkit.DeployingFrame.teleTagListPanel.content)
		PhaseToolkit.DeployingFrame.teleTagListPanel:Show()
		PhaseToolkit.DeployingFrame.teleTagListPanel.UpdateRows()

	end,
	onFinishedDeploy = function()
		PhaseToolkit.DeployingFrame.teleTagListPanel:Show()
		showContent(PhaseToolkit.DeployingFrame.teleTagListPanel.content)

	end,
	onPlayRetract = function()
		hideContent(PhaseToolkit.DeployingFrame.teleTagListPanel.content)

	end,
	onFinishedRetract = function()
		PhaseToolkit.DeployingFrame.teleTagListPanel:Hide()

	end,
})

end

function PhaseToolkit.OpenTeleList()
	if PhaseToolkit.context.id ~= "NONE" then
		PhaseToolkit.changeContext(deployingFrameContext["NONE"])
	end

	local context = {}
	context.id = "TELELIST"
	PhaseToolkit.extendDeployingFrame(450)

	if not PhaseToolkit.DeployingFrame.TeleListSearchBox then
		local searchBox = CreateFrame("EditBox", nil, PhaseToolkit.DeployingFrame, "InputBoxTemplate")
		searchBox:SetSize(165, 20)
		searchBox:SetPoint("TOPLEFT", PhaseToolkit.DeployingFrame, "TOPLEFT", 62.5, -62.5)
		searchBox:SetAutoFocus(false)
		searchBox:SetFontObject(GameFontHighlightSmall)
		searchBox:SetMaxLetters(100)
		searchBox:SetTextInsets(5, 5, 0, 0)

		searchBox:SetScript("OnTextChanged", function(self)
			PhaseToolkit.CurrenttextToLookForTele = self:GetText()
			PhaseToolkit.RefreshTeleListView()
		end)

		tinsert(context, searchBox)
		PhaseToolkit.DeployingFrame.TeleListSearchBox = searchBox
	end

	if not PhaseToolkit.DeployingFrame.TeleListTagListButton then
		local tagListButton = CreateFrame("Button", nil, PhaseToolkit.DeployingFrame, "UIPanelButtonTemplate")
		tagListButton:SetSize(20, 20)
		tagListButton:SetPoint("TOPLEFT", PhaseToolkit.DeployingFrame, "TOPLEFT", 10, -62.5)
		tagListButton.icon = tagListButton:CreateTexture(nil, "OVERLAY")
		tagListButton.icon:SetTexture("Interface\\AddOns\\"..addonName.."\\assets\\eps_ptk_icon_list.blp")
		tagListButton.icon:SetAllPoints()
		tagListButton:SetFrameStrata("HIGH")

		tagListButton:SetScript("OnClick", function()
			if not PhaseToolkit.DeployingFrame.teleTagListPanel then
				PhaseToolkit.CreateTeleTagList(deployingFrameContext["TELELIST"], context)
			end

			local shouldShow = not PhaseToolkit.DeployingFrame.teleTagListPanel:IsShown()
			if shouldShow then
				PhaseToolkit.getTeleCategoryFromPhaseData(function()
					deployTeleTagListPanel(deployingFrameContext["TELELIST"], context)
				end)
			else
				retractTeleTagListPanel(deployingFrameContext["TELELIST"], context)
			end
		end)

		tinsert(context, tagListButton)
		PhaseToolkit.RegisterTooltip(tagListButton, "Open the Teleport Tag List")
		PhaseToolkit.DeployingFrame.TeleListTagListButton = tagListButton
	end

	if not PhaseToolkit.DeployingFrame.teleTagListPanel then
		PhaseToolkit.CreateTeleTagList(deployingFrameContext["TELELIST"], context)
	end

	if not PhaseToolkit.DeployingFrame.TeleListRefreshButton then
		local refreshButton = CreateFrame("Button", nil, PhaseToolkit.DeployingFrame, "UIPanelButtonTemplate")
		refreshButton:SetSize(25, 25)
		refreshButton:SetPoint("TOPLEFT", PhaseToolkit.DeployingFrame, "TOPLEFT", 32.5, -60)
		refreshButton.icon = refreshButton:CreateTexture(nil, "OVERLAY")
		refreshButton.icon:SetTexture("Interface\\AddOns\\"..addonName.."\\assets\\BPMRefreshButton.blp")
		refreshButton.icon:SetAllPoints()
		refreshButton:SetFrameStrata("HIGH")

		refreshButton:SetScript("OnClick", function()
			if PhaseToolkit.isTeleListRefreshInProgress then
				return
			end
			PhaseToolkit.isTeleListRefreshInProgress = true
			refreshButton:Disable()
			refreshButton:SetAlpha(0.5)
			PhaseToolkit.teleList = {}
			sendAddonCmd("ph tele list", parseTeleListReplies, false)
		end)

		tinsert(context, refreshButton)
		PhaseToolkit.RegisterTooltip(refreshButton, "Refresh the Teleport List")
		PhaseToolkit.DeployingFrame.TeleListRefreshButton = refreshButton
	end

	local scrollFrame, content

	if not PhaseToolkit.DeployingFrame.TeleListScrollFrame then
		scrollFrame = CreateFrame("ScrollFrame", nil, PhaseToolkit.DeployingFrame, "FauxScrollFrameTemplate")
		scrollFrame:SetPoint("TOPLEFT", PhaseToolkit.DeployingFrame, "TOPLEFT", 5, -70)
		scrollFrame:SetPoint("BOTTOMRIGHT", PhaseToolkit.DeployingFrame, "BOTTOMRIGHT", -10, 10)
		scrollFrame:Show()
		PhaseToolkit.DeployingFrame.TeleListScrollFrame = scrollFrame
	else
		scrollFrame = PhaseToolkit.DeployingFrame.TeleListScrollFrame
		scrollFrame:Show()
	end

	if not PhaseToolkit.DeployingFrame.TeleListContent then
		content = CreateFrame("Frame", nil, scrollFrame)
		content:SetPoint("TOPLEFT", scrollFrame, "TOPLEFT", 0, -10)
		content:SetPoint("BOTTOMRIGHT", scrollFrame, "BOTTOMRIGHT", 0, 0)
		content:Show()
		PhaseToolkit.DeployingFrame.TeleListContent = content
	else
		content = PhaseToolkit.DeployingFrame.TeleListContent
		content:Show()
	end

	local rowHeight = 32
	local visibleRows = 11
	content.displayRows = content.displayRows or {}

	local function createRow(index)
		local row = CreateFrame("Button", "PTK_TELE_ROW"..index, content)
		row:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -((index - 1) * rowHeight))
		row:SetPoint("TOPRIGHT", content, "TOPRIGHT", 0, -((index - 1) * rowHeight))
		row:SetHeight(rowHeight)

		row.background = row:CreateTexture(nil, "BACKGROUND")
		row.background:SetTexture("Interface\\AddOns\\"..addonName.."\\assets\\BlueprintManagerFrameBackground.blp")
		row.background:SetSize(310, 35)
		row.background:SetPoint("TOPLEFT", row, "TOPLEFT", -50, 0)

		row.highlight = row:CreateTexture(nil, "OVERLAY")
		row.highlight:SetTexture("Interface\\AddOns\\"..addonName.."\\assets\\BlueprintManagerFrameForeground.blp")
		row.highlight:SetSize(215, 28)
		row.highlight:SetTexCoord(77/512, (77+360)/512, 26/128, (26+78)/128)
		row.highlight:SetPoint("CENTER", row, "CENTER", -15, 0)
		row.highlight:Hide()

		row.label = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
		row.label:SetPoint("LEFT", row, "LEFT", 0, 0)
		row.label:SetJustifyH("LEFT")
		row.label:SetWordWrap(false)
		row.label:SetNonSpaceWrap(true)

		row.deleteButton = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
		row.deleteButton:SetSize(20, 20)
		row.deleteButton:SetPoint("RIGHT", row, "RIGHT", -12.5, 0)
		row.deleteButton.icon = row.deleteButton:CreateTexture(nil, "OVERLAY")
		row.deleteButton.icon:SetTexture("Interface\\AddOns\\"..addonName.."\\assets\\BPMXButton.blp")
		row.deleteButton.icon:SetAllPoints()
		row.deleteButton:SetFrameStrata("HIGH")

		row.categoryManagementButton = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
		row.categoryManagementButton:SetSize(20, 20)
		row.categoryManagementButton:SetPoint("RIGHT", row, "RIGHT", -12.5, 0)
		row.categoryManagementButton.icon = row.categoryManagementButton:CreateTexture(nil, "OVERLAY")
		row.categoryManagementButton.icon:SetTexture("Interface\\AddOns\\"..addonName.."\\assets\\eps_ptk_icon_list.blp")
		row.categoryManagementButton.icon:SetAllPoints()
		row.categoryManagementButton:SetFrameStrata("HIGH")
		row.categoryManagementButton:Hide()
		row.categoryManagementState = "ADD"

		row:SetScript("OnMouseDown", function(self, button)
			if button == "LeftButton" and self.teleName then
				sendAddonCmd("phase tele " .. self.teleName, nil, false)
			end
		end)

		row.deleteButton:SetScript("OnMouseDown", function(self, button)
			if button == "LeftButton" then
				local parent = self:GetParent()
				if parent and parent.teleName then
					StaticPopup_Show("CONFIRM_DELETE_TELE", nil, nil, { teleId = parent.teleName })
				end
			end
		end)

		row.categoryManagementButton:SetScript("OnMouseDown", function(self, button)
			if button == "LeftButton" and self:GetParent() and self:GetParent().teleName then
				if PhaseToolkit.TELEselectedCategory then
					if self:GetParent().categoryManagementState == "ADD" then
						tinsert(PhaseToolkit.TELEselectedCategory.members, self:GetParent().teleName)
						self:GetParent().categoryManagementState = "REMOVE"
						self:GetParent().categoryManagementButton.icon:SetTexture("Interface\\AddOns\\"..addonName.."\\assets\\BPMBackButton.blp")
					else
						local indexToDelete = getIndexOfMembers(PhaseToolkit.TELEselectedCategory.members, self:GetParent().teleName)
						if indexToDelete > 0 then
							table.remove(PhaseToolkit.TELEselectedCategory.members, indexToDelete)
							self:GetParent().categoryManagementState = "ADD"
							self:GetParent().categoryManagementButton.icon:SetTexture("Interface\\AddOns\\"..addonName.."\\assets\\BPMAddButton.blp")
						end
					end
					PhaseToolkit.saveTELECategoryDataToServer()
					PhaseToolkit.RefreshTeleListView(true)
				end
			end
		end)

		row:SetScript("OnEnter", function(self)
			if self.fullText then
				PhaseToolkit.ShowTooltip(self, self.fullText)
			end
			self.highlight:Show()
		end)

		row:SetScript("OnLeave", function(self)
			PhaseToolkit.HideTooltip()
			self.highlight:Hide()
		end)

		return row
	end

	local function updateScrollFrame()
		local data = PhaseToolkit.teleListView or PhaseToolkit.teleList or {}
		local totalRows = #data

		if totalRows > visibleRows then
			FauxScrollFrame_Update(scrollFrame, totalRows, visibleRows, rowHeight)
		end

		local offset = 0
		if FauxScrollFrame_GetOffset then
			offset = FauxScrollFrame_GetOffset(scrollFrame) or 0
		elseif scrollFrame.ScrollBar and scrollFrame.ScrollBar.GetValue then
			offset = math.floor((scrollFrame.ScrollBar:GetValue() or 0) / rowHeight)
		end

		local maxOffset = math.max(0, totalRows - visibleRows)
		offset = math.max(0, math.min(offset, maxOffset))

		if scrollFrame.ScrollBar and scrollFrame.ScrollBar.SetValue then
			scrollFrame.ScrollBar:SetValue(offset * rowHeight)
		end

		if FauxScrollFrame_SetOffset then
			FauxScrollFrame_SetOffset(scrollFrame, offset)
		else
			scrollFrame.offset = offset
		end

		for i = 1, visibleRows do
			local teleIndex = offset + i
			local row = content.displayRows[i]

			if not row then
				row = createRow(i)
				content.displayRows[i] = row
			end

			local teleName = data[teleIndex]
			if teleName then
				row.teleName = teleName
				SetCroppedTextWithTooltip(row, row.label, teleName, 210)

				if PhaseToolkit.TELEselectedCategory then
					row.deleteButton:Hide()
					row.categoryManagementButton:Show()
				else
					row.deleteButton:Show()
					row.categoryManagementButton:Hide()
				end

				if checkIfTeleInSelectedCategory(teleName) then
					row.categoryManagementState = "REMOVE"
					row.categoryManagementButton.icon:SetTexture("Interface\\AddOns\\"..addonName.."\\assets\\BPMBackButton.blp")
				else
					row.categoryManagementState = "ADD"
					row.categoryManagementButton.icon:SetTexture("Interface\\AddOns\\"..addonName.."\\assets\\BPMAddButton.blp")
				end

				row:Show()
			else
				row.teleName = nil
				row:Hide()
			end
		end
	end

	scrollFrame:SetScript("OnVerticalScroll", function(self, offset)
		FauxScrollFrame_OnVerticalScroll(self, offset, rowHeight, updateScrollFrame)
	end)

	PhaseToolkit.DeployingFrame.TeleListScrollFrame.rowHeight = rowHeight
	PhaseToolkit.DeployingFrame.TeleListScrollFrame.visibleRows = visibleRows
	PhaseToolkit.DeployingFrame.TeleListScrollFrame.UpdateRows = updateScrollFrame

	PhaseToolkit.DeployingFrame.TeleListContent = content

	scrollFrame.ScrollBar:SetPoint("TOPRIGHT", scrollFrame, "TOPRIGHT", -15, -12)
	scrollFrame.ScrollBar:SetPoint("BOTTOMRIGHT", scrollFrame, "BOTTOMRIGHT", -15, 15)
	scrollFrame.ScrollBar:SetFrameStrata("HIGH")

	tinsert(context, scrollFrame)
	tinsert(context, content)

	if #deployingFrameContext["TELELIST"] < 1 then
		deployingFrameContext["TELELIST"] = context
	end

	PhaseToolkit.changeContext(deployingFrameContext["TELELIST"])
	PhaseToolkit.DeployingFrame.TeleListScrollFrame:Show()
	PhaseToolkit.RefreshTeleListView()
end

function PhaseToolkit.OpenNpcForge()
	local context = {}
	context.id="NPCFORGE"
	PhaseToolkit.extendDeployingFrame(0)
	-- Create once, store on the DeployingFrame
    if not PhaseToolkit.DeployingFrame.NpcPortraitButton then
    	createRaceButton(context)

    end

	if not PhaseToolkit.DeployingFrame.NpcGenderSlider then
		createGenderSlider(context)

	end

	if not PhaseToolkit.DeployingFrame.CustomCategoryButtons then
		createCustomCategoryButton(context)
		for _, button in ipairs(PhaseToolkit.DeployingFrame.CustomCategoryButtons) do
			tinsert(context, button)
		end
	end

	if(#deployingFrameContext["NPCFORGE"]<1) then
		deployingFrameContext["NPCFORGE"] = context
	end

	PhaseToolkit.changeContext(deployingFrameContext["NPCFORGE"])

    -- Re-anchor safely (OffsetFromTop can change)
    local NpcPortraitButton = PhaseToolkit.DeployingFrame.NpcPortraitButton
    NpcPortraitButton:ClearAllPoints()
    NpcPortraitButton:SetPoint("TOPLEFT", PhaseToolkit.DeployingFrame, "TOPLEFT", 10, PhaseToolkit.DeployingFrame.OffsetFromTop - 20)
    NpcPortraitButton:Show()
end

local function createItemSlotButton(context)
	local itemDropSlot = CreateFrame("Button", nil, PhaseToolkit.DeployingFrame, "BackdropTemplate")
	itemDropSlot:SetSize(36,36)
	itemDropSlot:SetPoint("TOPLEFT", PhaseToolkit.DeployingFrame, "TOPLEFT", 8, PhaseToolkit.DeployingFrame.OffsetFromTop - 25)
	itemDropSlot:SetBackdrop({
		bgFile = "Interface\\Buttons\\UI-Quickslot2",
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		edgeSize = 16,
		insets = { left = 2, right = 2, top = 2, bottom = 2 },
	})

	itemDropSlot.icon = itemDropSlot:CreateTexture(nil, "ARTWORK")
	itemDropSlot.icon:SetSize(29, 29)
	itemDropSlot.icon:SetPoint("CENTER", itemDropSlot, "CENTER", 0, 0)
	itemDropSlot.icon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")


	itemDropSlot:SetScript("OnReceiveDrag", function(self)
		local cursorType, itemID, itemLink = GetCursorInfo()
		if cursorType == "item" and itemLink then
			self.icon:SetTexture(GetItemIcon(itemID) or "Interface\\Icons\\INV_Misc_QuestionMark")
			PhaseToolkit.itemCreatorData.itemLink = itemLink
			GameTooltip:Hide()
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
			GameTooltip:SetHyperlink(PhaseToolkit.itemCreatorData.itemLink)
			GameTooltip:Show()
			updateFields(PhaseToolkit.itemCreatorData.itemLink)
			local maxDescriptionSize=238-(string.len("f i s de ")+string.len(PhaseToolkit.itemCreatorData.itemLink or ""))
			PhaseToolkit.DeployingFrame.itemForgeDescriptionFrame.ScrollFrame.EditBox:SetMaxLetters(maxDescriptionSize)
		end
		ClearCursor()
	end)

	itemDropSlot:SetScript("OnEnter", function(self)
		if PhaseToolkit.itemCreatorData.itemLink then
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
			GameTooltip:SetHyperlink(PhaseToolkit.itemCreatorData.itemLink)
			GameTooltip:Show()
		else
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
			GameTooltip:SetText("Drop an Item here to use it as a Template for the Item Forge.",1,1,1)
			GameTooltip:Show()
		end
		itemDropSlot:SetBackdropBorderColor(1, 1, 0, 1)
	end)

	itemDropSlot:SetScript("OnLeave", function(self)
		GameTooltip:Hide()
		itemDropSlot:SetBackdropBorderColor(1, 1, 1, 1)
	end)

	itemDropSlot:SetScript("OnMouseDown", function(self, button)
		if button == "RightButton" then
			self.icon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
			PhaseToolkit.itemCreatorData.itemLink = nil
			GameTooltip:Hide()
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
			GameTooltip:SetText("Drop an Item here to use it as a Template for the Item Forge.",1,1,1)
			GameTooltip:Show()
		end
	end)

	tinsert(context, itemDropSlot)
	PhaseToolkit.DeployingFrame.ItemDropSlot = itemDropSlot
end

local function createItemForgeNameInput(context)
	local nameInput = CreateFrame("EditBox", nil, PhaseToolkit.DeployingFrame, "InputBoxTemplate")
	nameInput:SetSize(190, 20)
	nameInput:SetPoint("TOPLEFT", PhaseToolkit.DeployingFrame, "TOPLEFT", 60, PhaseToolkit.DeployingFrame.OffsetFromTop - 35)
	nameInput:SetAutoFocus(false)
	nameInput:SetFontObject(GameFontHighlightSmall)
	nameInput:SetMaxLetters(100)
	nameInput:SetTextInsets(5, 5, 0, 0)

	nameInput.label = nameInput:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	nameInput.label:SetPoint("BOTTOMLEFT", nameInput, "TOPLEFT", 0, 2)
	nameInput.label:SetText(PhaseToolkit.CurrentLang["Item Name"] or "Item Name")
	--change the font size
	nameInput.label:SetFontObject(GameTooltipTextSmall)

	nameInput:SetScript("OnEnterPressed", function(self)
		local itemName = self:GetText()
		if itemName and itemName ~= "" then
			PhaseToolkit.itemCreatorData.itemName = itemName
		end
		if PhaseToolkit.itemCreatorData.itemLink then
			sendAddonCmd(buildItemForgeCommand("name",{PhaseToolkit.itemCreatorData.itemLink},itemName),nil,false)
		end
		self:ClearFocus()
	end)

	nameInput:SetScript("OnTextChanged", function(self)
		local itemName = self:GetText()
		if itemName and itemName ~= "" then
			PhaseToolkit.itemCreatorData.itemName = itemName
		end
		if PhaseToolkit.itemCreatorData.itemLink then
			sendAddonCmd(buildItemForgeCommand("name",{PhaseToolkit.itemCreatorData.itemLink},itemName),nil,false)
		end
	end)

	nameInput:SetScript("OnEscapePressed", function(self)
		self:ClearFocus()
	end)

	tinsert(context, nameInput)
	PhaseToolkit.DeployingFrame.itemForgeNameInput = nameInput
end

local function createItemForgeDescriptionEditbox(context)
	local descriptionFrame  = CreateFrame("FRAME", "$parentEdit", PhaseToolkit.DeployingFrame, "EpsilonInputScrollTemplate")
	descriptionFrame:SetPoint("TOPLEFT", PhaseToolkit.DeployingFrame.itemForgeNameInput, "BOTTOMLEFT", -5, -15)
	descriptionFrame:SetSize(195, 85)
	descriptionFrame.SetText = function(self, text)
		descriptionFrame.ScrollFrame.EditBox:SetText(text)
	end

	descriptionFrame.label = descriptionFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	descriptionFrame.label:SetPoint("BOTTOMLEFT", descriptionFrame, "TOPLEFT", 5, 2)
	descriptionFrame.label:SetText(PhaseToolkit.CurrentLang["Item Description"] or "Item Description")
	--change the font size
	descriptionFrame.label:SetFontObject(GameTooltipTextSmall)

	descriptionFrame.ScrollFrame.EditBox:SetScript("OnTextChanged", function(self)
		local maxDescriptionSize=238-(string.len("f i s de ")+string.len(PhaseToolkit.itemCreatorData.itemLink or ""))
		PhaseToolkit.itemCreatorData.itemDescription = self:GetText()
		if((string.len(self:GetText())<maxDescriptionSize)) then
			if PhaseToolkit.itemCreatorData.itemLink then
				sendAddonCmd(buildItemForgeCommand("description",{PhaseToolkit.itemCreatorData.itemLink},self:GetText()),nil,false)
				PhaseToolkit.HideTooltip()
				self:SetScript("OnEnter",nil)
				self:SetScript("OnLeave",nil)
			end
		else
			local border = descriptionFrame:CreateTexture(nil, "BACKGROUND")
			border:SetPoint("TOPLEFT", -2, 2)
			border:SetPoint("BOTTOMRIGHT", 2, -2)
			self:SetScript("OnLeave",function() PhaseToolkit.HideTooltip() end)

			C_Timer.After(1.5, function()
				border:SetColorTexture(1, 0, 0, 0)
			end)
		end
	end)

	tinsert(context, descriptionFrame)
	tinsert(context, descriptionFrame.ScrollFrame)
	tinsert(context, descriptionFrame.ScrollFrame.EditBox)
	PhaseToolkit.DeployingFrame.itemForgeDescriptionFrame = descriptionFrame
end

local function createCharacterWhitelistPanel(context)
	local panel = CreateFrame("Frame", nil, PhaseToolkit.DeployingFrame,"PortraitFrameTemplate")
	panel:SetSize(200, 300)
	panel:SetPoint("BOTTOMLEFT", PhaseToolkit.DeployingFrame, "BOTTOMRIGHT", 0, 0)
	ButtonFrameTemplateMinimizable_HidePortrait(panel)
	NineSliceUtil.ApplyLayoutByName(panel.NineSlice, "EpsilonGoldBorderFrameTemplateNoPortrait")
	EpsilonLib.Utils.NineSlice.CropNineSliceCorners(panel.NineSlice, 0.8, true)
	EpsilonLib.Utils.NineSlice.CropNineSliceCorners(panel.NineSlice, 0.4)
	EpsilonLib.Utils.NineSlice.SetBackgroundAsViewport(panel, panel.Bg)
	panel:SetFrameStrata("LOW")
	local titleBgColor = panel:CreateTexture(nil, "BACKGROUND")
	local color = CreateColorFromHexString("80FF7100")
	titleBgColor:SetPoint("TOPLEFT", panel.TitleBg)
	titleBgColor:SetPoint("BOTTOMRIGHT", panel.TitleBg, -0, 0)
	titleBgColor:SetColorTexture(color:GetRGBA())
	panel.TitleBgColor = titleBgColor
	panel.TitleText:SetText(PhaseToolkit.CurrentLang["Character Whitelist"] or "Character Whitelist")
	panel.TitleText:SetPoint("LEFT", panel.TitleBg, "LEFT", 30, 0)
	panel:Hide()
	panel.isHiddenByDefault = true

	local addCharacterButton = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
	addCharacterButton:SetSize(25, 25)
	addCharacterButton:SetPoint("TOPLEFT", panel, "TOPLEFT", 5, -30)
	addCharacterButton.icon = addCharacterButton:CreateTexture(nil, "OVERLAY")
	addCharacterButton.icon:SetTexture("Interface\\AddOns\\"..addonName.."\\assets\\BPMAddButton.blp")
	addCharacterButton.icon:SetAllPoints()
	PhaseToolkit.RegisterTooltip(addCharacterButton, "Add character to whitelist")
	PhaseToolkit.DisableComponent(addCharacterButton)

	local nameInput = CreateFrame("EditBox", nil, panel, "InputBoxTemplate")
	nameInput:SetSize(120, 20)
	nameInput:SetPoint("TOPLEFT", addCharacterButton, "TOPRIGHT", 5, 0)
	nameInput:SetAutoFocus(false)
	nameInput:SetFontObject(GameFontHighlightSmall)
	nameInput:SetScript("OnTextChanged", function(self)
		local text = self:GetText()
		if text and text ~= "" then
			PhaseToolkit.EnableComponent(addCharacterButton)
		else
			PhaseToolkit.DisableComponent(addCharacterButton)
		end
	end)
	nameInput:SetScript("OnEscapePressed", function(self)
		self:ClearFocus()
	end)



	--fauxscrollframe setup for the character whitelist
	local scrollFrame = CreateFrame("ScrollFrame", nil, panel, "FauxScrollFrameTemplate")
	scrollFrame:SetPoint("TOPLEFT", panel, "TOPLEFT", 10, -50)
	scrollFrame:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -20, 10)
	scrollFrame:Show()

	local content = CreateFrame("Frame", nil, scrollFrame)
	content:SetPoint("TOPLEFT", scrollFrame, "TOPLEFT", 0, -10)
	content:SetPoint("BOTTOMRIGHT", scrollFrame, "BOTTOMRIGHT", 0, 0)
	content:Show()

	local rowHeight = 32
	local visibleRows = 7

	content.displayRows = content.displayRows or {}

	local function createRow(index)
		local row = CreateFrame("Button", "PTK_TAG_ROW"..index, content)
		row:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -((index - 1) * rowHeight))
		row:SetPoint("RIGHT", content, "RIGHT", 0, 0)
		row:SetHeight(rowHeight)

		row.background = row:CreateTexture(nil, "BACKGROUND")
		row.background:SetTexture("Interface\\AddOns\\"..addonName.."\\assets\\BlueprintManagerFrameBackground.blp")
		row.background:SetSize(250,35)
		row.background:SetPoint("TOPLEFT", row, "TOPLEFT", -50, 0)

		row.highlight = row:CreateTexture(nil, "OVERLAY")
		row.highlight:SetTexture("Interface\\AddOns\\"..addonName.."\\assets\\BlueprintManagerFrameForeground.blp")
		row.highlight:SetSize(170,25)
		row.highlight:SetPoint("TOPLEFT", row, "TOPLEFT", -8.5, -5.5)
		row.highlight:SetTexCoord(
			77/512, (77+360)/512,   -- left, right (77 to 437)
			26/128, (26+78)/128     -- top, bottom (26 to 104)
		);
		row.highlight:Hide()

		row.label = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
		row.label:SetPoint("LEFT", row, "LEFT", 5, 0)
		row.label:SetJustifyH("LEFT")
		row.label:SetWordWrap(false)
		row.label:SetNonSpaceWrap(true)

		row.deleteButton = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
		row.deleteButton:SetSize(20, 20)
		row.deleteButton:SetPoint("RIGHT", row, "RIGHT", -5, 0)
		row.deleteButton.icon = row.deleteButton:CreateTexture(nil, "OVERLAY")
		row.deleteButton.icon:SetTexture("Interface\\AddOns\\"..addonName.."\\assets\\BPMXButton.blp")
		row.deleteButton.icon:SetAllPoints()
		row.deleteButton:SetFrameStrata("HIGH")

		row:SetScript("OnEnter", function(self)
			if self.fullText then
				PhaseToolkit.ShowTooltip(self, self.fullText)
			end
			self.highlight:Show()
		end)

		row:SetScript("OnLeave", function(self)
			PhaseToolkit.HideTooltip()
			self.highlight:Hide()
		end)
		return row
	end


	local function updateScrollFrame()
		local offset = FauxScrollFrame_GetOffset(scrollFrame)
		local characterList = PhaseToolkit.itemCreatorData.characterWhitelist or {}

		for i = 1, visibleRows do
			local tagIndex = offset + i
			local row = content.displayRows[i]
			local character = characterList[tagIndex]

			if(not row) then
				row = createRow(i)
				content.displayRows[i] = row
			end

			if character then
				local fullName = character
				SetCroppedTextWithTooltip(row, row.label, fullName, 180)
				row.deleteButton:SetScript("OnClick", function()
					deleteKeyFromArray(PhaseToolkit.itemCreatorData.characterWhitelist, character)
					if(PhaseToolkit.itemCreatorData.itemLink) then
						sendAddonCmd(buildItemForgeCommand("whitelist character remove",{PhaseToolkit.itemCreatorData.itemLink},character),nil,false)
					end
					updateScrollFrame()
				end)

				row:Show()
			else
				row:Hide()
			end
		end

		if(#characterList > visibleRows) then
			FauxScrollFrame_Update(scrollFrame, #characterList, visibleRows, rowHeight)
		end
	end

	scrollFrame:SetScript("OnVerticalScroll", function(self, offset)
		FauxScrollFrame_OnVerticalScroll(self, offset, rowHeight, updateScrollFrame)
	end)

	addCharacterButton:SetScript("OnClick", function()
		local characterName = nameInput:GetText()
		if characterName and characterName ~= "" then
			tinsert(PhaseToolkit.itemCreatorData.characterWhitelist, characterName)
			nameInput:SetText("")
			PhaseToolkit.DisableComponent(addCharacterButton)
			updateScrollFrame()
			if(PhaseToolkit.itemCreatorData.itemLink) then
				sendAddonCmd(buildItemForgeCommand("whitelist character add",{PhaseToolkit.itemCreatorData.itemLink},characterName),nil,false)
			end
		end
	end)

	nameInput:SetScript("OnEnterPressed", function(self)
		local characterName = self:GetText()
		if characterName and characterName ~= "" then
			tinsert(PhaseToolkit.itemCreatorData.characterWhitelist, characterName)
			self:SetText("")
			PhaseToolkit.DisableComponent(addCharacterButton)
			updateScrollFrame()
			if(PhaseToolkit.itemCreatorData.itemLink) then
				sendAddonCmd(buildItemForgeCommand("whitelist character add",{PhaseToolkit.itemCreatorData.itemLink},characterName),nil,false)
			end
		end
	end)


	scrollFrame.ScrollBar:SetPoint("TOPRIGHT", scrollFrame, "TOPRIGHT", 5, -12)
	scrollFrame.ScrollBar:SetPoint("BOTTOMRIGHT", scrollFrame, "BOTTOMRIGHT", 5, 15)
	scrollFrame.ScrollBar:SetFrameStrata("HIGH")


	tinsert(context, panel)
	PhaseToolkit.DeployingFrame.characterWhitelistPanel = panel
	PhaseToolkit.DeployingFrame.characterWhitelistPanel.updateScrollFrame = updateScrollFrame
	PhaseToolkit.DeployingFrame.characterWhitelistPanel.deployAnimation = function()
	local AnimationGroup = PhaseToolkit.DeployingFrame.characterWhitelistPanel:CreateAnimationGroup("deployCharacterWhitelistPanel");

	local fadeIn = AnimationGroup:CreateAnimation("Alpha");
	fadeIn:SetOrder(1);
	fadeIn:SetFromAlpha(0);
	fadeIn:SetToAlpha(1);
	fadeIn:SetDuration(0.5);
	fadeIn:SetSmoothing("OUT")

	local scaleUp= AnimationGroup:CreateAnimation("Scale");
	scaleUp:SetOrder(1);
	scaleUp:SetFromScale(0.0,1.0);
	scaleUp:SetToScale(1.0,1.0);
	scaleUp:SetDuration(0.5);
	scaleUp:SetSmoothing("OUT")
	scaleUp:SetOrigin("LEFT",0,0)

	AnimationGroup:SetScript("OnPlay", function()
		if(PhaseToolkit.DeployingFrame.itemForgeRightPanelOpened) then
				PhaseToolkit.DeployingFrame.itemForgeRightPanelOpened.retractAnimation()
			end
			PhaseToolkit.DeployingFrame.characterWhitelistPanel:Show()
			PhaseToolkit.DeployingFrame.itemForgeRightPanelOpened = PhaseToolkit.DeployingFrame.characterWhitelistPanel
	end);

	AnimationGroup:Play();
	end

	PhaseToolkit.DeployingFrame.characterWhitelistPanel.retractAnimation = function ()
		local AnimationGroup = PhaseToolkit.DeployingFrame.characterWhitelistPanel:CreateAnimationGroup("retractCharacterWhitelistPanel");

		local fadeOut = AnimationGroup:CreateAnimation("Alpha");
		fadeOut:SetOrder(1);
		fadeOut:SetFromAlpha(1);
		fadeOut:SetToAlpha(0);
		fadeOut:SetDuration(0.5);
		fadeOut:SetSmoothing("OUT")

		local scaleDown= AnimationGroup:CreateAnimation("Scale");
		scaleDown:SetOrder(1);
		scaleDown:SetFromScale(1.0,1.0);
		scaleDown:SetToScale(0.0,1.0);
		scaleDown:SetDuration(0.5);
		scaleDown:SetSmoothing("OUT")
		scaleDown:SetOrigin("LEFT",0,0)

		AnimationGroup:SetScript("OnFinished", function()
			PhaseToolkit.DeployingFrame.characterWhitelistPanel:Hide()
			if PhaseToolkit.DeployingFrame.itemForgeRightPanelOpened == PhaseToolkit.DeployingFrame.characterWhitelistPanel then
				PhaseToolkit.DeployingFrame.itemForgeRightPanelOpened = nil
			end
		end);

		AnimationGroup:Play();
	end
end

local function createPhaseMemberWhitelistPanel(context)
	local panel = CreateFrame("Frame", nil, PhaseToolkit.DeployingFrame,"PortraitFrameTemplate")
	panel:SetSize(200, 300)
	panel:SetPoint("BOTTOMLEFT", PhaseToolkit.DeployingFrame, "BOTTOMRIGHT", 0, 0)
	ButtonFrameTemplateMinimizable_HidePortrait(panel)
	NineSliceUtil.ApplyLayoutByName(panel.NineSlice, "EpsilonGoldBorderFrameTemplateNoPortrait")
	EpsilonLib.Utils.NineSlice.CropNineSliceCorners(panel.NineSlice, 0.8, true)
	EpsilonLib.Utils.NineSlice.CropNineSliceCorners(panel.NineSlice, 0.4)
	EpsilonLib.Utils.NineSlice.SetBackgroundAsViewport(panel, panel.Bg)
	panel:SetFrameStrata("LOW")
	local titleBgColor = panel:CreateTexture(nil, "BACKGROUND")
	local color = CreateColorFromHexString("80FF7100")
	titleBgColor:SetPoint("TOPLEFT", panel.TitleBg)
	titleBgColor:SetPoint("BOTTOMRIGHT", panel.TitleBg, -0, 0)
	titleBgColor:SetColorTexture(color:GetRGBA())
	panel.TitleBgColor = titleBgColor
	panel.TitleText:SetText(PhaseToolkit.CurrentLang["Phase Member Whitelist"] or "Phase Member Whitelist")
	panel.TitleText:SetPoint("LEFT", panel.TitleBg, "LEFT", 30, 0)
	panel:Hide()
	panel.isHiddenByDefault = true

	local addPhaseIdButton = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
	addPhaseIdButton:SetSize(25, 25)
	addPhaseIdButton:SetPoint("TOPLEFT", panel, "TOPLEFT", 5, -30)
	addPhaseIdButton.icon = addPhaseIdButton:CreateTexture(nil, "OVERLAY")
	addPhaseIdButton.icon:SetTexture("Interface\\AddOns\\"..addonName.."\\assets\\BPMAddButton.blp")
	addPhaseIdButton.icon:SetAllPoints()
	PhaseToolkit.RegisterTooltip(addPhaseIdButton, "Add phase ID to whitelist")
	PhaseToolkit.DisableComponent(addPhaseIdButton)

	local idInput = CreateFrame("EditBox", nil, panel, "InputBoxTemplate")
	idInput:SetSize(120, 20)
	idInput:SetPoint("TOPLEFT", addPhaseIdButton, "TOPRIGHT", 5, 0)
	idInput:SetAutoFocus(false)
	idInput:SetFontObject(GameFontHighlightSmall)
	idInput:SetNumeric(true)
	idInput:SetScript("OnTextChanged", function(self)
		local text = self:GetText()
		if text and text ~= "" then
			PhaseToolkit.EnableComponent(addPhaseIdButton)
		else
			PhaseToolkit.DisableComponent(addPhaseIdButton)
		end
	end)

	local scrollFrame = CreateFrame("ScrollFrame", nil, panel, "FauxScrollFrameTemplate")
	scrollFrame:SetPoint("TOPLEFT", panel, "TOPLEFT", 10, -50)
	scrollFrame:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -20, 10)
	scrollFrame:Show()

	local content = CreateFrame("Frame", nil, scrollFrame)
	content:SetPoint("TOPLEFT", scrollFrame, "TOPLEFT", 0, -10)
	content:SetPoint("BOTTOMRIGHT", scrollFrame, "BOTTOMRIGHT", 0, 0)
	content:Show()

	local rowHeight = 32
	local visibleRows = 7

	content.displayRows = content.displayRows or {}

	local function createRow(index)
		local row = CreateFrame("Button", "PTK_TAG_ROW"..index, content)
		row:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -((index - 1) * rowHeight))
		row:SetPoint("RIGHT", content, "RIGHT", 0, 0)
		row:SetHeight(rowHeight)

		row.background = row:CreateTexture(nil, "BACKGROUND")
		row.background:SetTexture("Interface\\AddOns\\"..addonName.."\\assets\\BlueprintManagerFrameBackground.blp")
		row.background:SetSize(250,35)
		row.background:SetPoint("TOPLEFT", row, "TOPLEFT", -50, 0)

		row.highlight = row:CreateTexture(nil, "OVERLAY")
		row.highlight:SetTexture("Interface\\AddOns\\"..addonName.."\\assets\\BlueprintManagerFrameForeground.blp")
		row.highlight:SetSize(170,25)
		row.highlight:SetPoint("TOPLEFT", row, "TOPLEFT", -8.5, -5.5)
		row.highlight:SetTexCoord(
			77/512, (77+360)/512,   -- left, right (77 to 437)
			26/128, (26+78)/128     -- top, bottom (26 to 104)
		);
		row.highlight:Hide()

		row.label = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
		row.label:SetPoint("LEFT", row, "LEFT", 5, 0)
		row.label:SetJustifyH("LEFT")
		row.label:SetWordWrap(false)
		row.label:SetNonSpaceWrap(true)

		row.deleteButton = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
		row.deleteButton:SetSize(20, 20)
		row.deleteButton:SetPoint("RIGHT", row, "RIGHT", -5, 0)
		row.deleteButton.icon = row.deleteButton:CreateTexture(nil, "OVERLAY")
		row.deleteButton.icon:SetTexture("Interface\\AddOns\\"..addonName.."\\assets\\BPMXButton.blp")
		row.deleteButton.icon:SetAllPoints()
		row.deleteButton:SetFrameStrata("HIGH")

		row:SetScript("OnEnter", function(self)
			if self.fullText then
				PhaseToolkit.ShowTooltip(self, self.fullText)
			end
			self.highlight:Show()
		end)

		row:SetScript("OnLeave", function(self)
			PhaseToolkit.HideTooltip()
			self.highlight:Hide()
		end)
		return row
	end


	local function updateScrollFrame()
		local offset = FauxScrollFrame_GetOffset(scrollFrame)
		local phaseIdList = PhaseToolkit.itemCreatorData.phaseWhitelistForMember or {}

		for i = 1, visibleRows do
			local tagIndex = offset + i
			local row = content.displayRows[i]
			local phaseId = phaseIdList[tagIndex]

			if(not row) then
				row = createRow(i)
				content.displayRows[i] = row
			end

			if phaseId then
				local fullName = phaseId
				SetCroppedTextWithTooltip(row, row.label, fullName, 180)
				row.deleteButton:SetScript("OnClick", function()
					deleteKeyFromArray(PhaseToolkit.itemCreatorData.phaseWhitelistForMember, phaseId)
					updateScrollFrame()
					if(PhaseToolkit.itemCreatorData.itemLink) then
						sendAddonCmd(buildItemForgeCommand("whitelist member remove",{PhaseToolkit.itemCreatorData.itemLink},phaseId),nil,false)
					end
				end)

				row:Show()
			else
				row:Hide()
			end
		end

		if(#phaseIdList > visibleRows) then
			FauxScrollFrame_Update(scrollFrame, #phaseIdList, visibleRows, rowHeight)
		end
	end

	scrollFrame:SetScript("OnVerticalScroll", function(self, offset)
		FauxScrollFrame_OnVerticalScroll(self, offset, rowHeight, updateScrollFrame)
	end)

	addPhaseIdButton:SetScript("OnClick", function()
		local phaseID = idInput:GetText()
		if phaseID and phaseID ~= "" then
			tinsert(PhaseToolkit.itemCreatorData.phaseWhitelistForMember, phaseID)
			idInput:SetText("")
			PhaseToolkit.DisableComponent(addPhaseIdButton)
			updateScrollFrame()
			if(PhaseToolkit.itemCreatorData.itemLink) then
						sendAddonCmd(buildItemForgeCommand("whitelist member add",{PhaseToolkit.itemCreatorData.itemLink},phaseID),nil,false)
					end
		end
	end)

	idInput:SetScript("OnEnterPressed", function(self)
		local phaseID = self:GetText()
		if phaseID and phaseID ~= "" then
			tinsert(PhaseToolkit.itemCreatorData.phaseWhitelistForMember, phaseID)
			self:SetText("")
			PhaseToolkit.DisableComponent(addPhaseIdButton)
			updateScrollFrame()
			if(PhaseToolkit.itemCreatorData.itemLink) then
				sendAddonCmd(buildItemForgeCommand("whitelist member add",{PhaseToolkit.itemCreatorData.itemLink},phaseID),nil,false)
			end
		end
	end)


	scrollFrame.ScrollBar:SetPoint("TOPRIGHT", scrollFrame, "TOPRIGHT", 5, -12)
	scrollFrame.ScrollBar:SetPoint("BOTTOMRIGHT", scrollFrame, "BOTTOMRIGHT", 5, 15)
	scrollFrame.ScrollBar:SetFrameStrata("HIGH")


	tinsert(context, panel)
	PhaseToolkit.DeployingFrame.phaseMemberWhitelistPanel = panel
	PhaseToolkit.DeployingFrame.phaseMemberWhitelistPanel.updateScrollFrame = updateScrollFrame
	PhaseToolkit.DeployingFrame.phaseMemberWhitelistPanel.deployAnimation = function()
		local AnimationGroup = PhaseToolkit.DeployingFrame.phaseMemberWhitelistPanel:CreateAnimationGroup("deployCharacterWhitelistPanel");

		local fadeIn = AnimationGroup:CreateAnimation("Alpha");
		fadeIn:SetOrder(1);
		fadeIn:SetFromAlpha(0);
		fadeIn:SetToAlpha(1);
		fadeIn:SetDuration(0.5);
		fadeIn:SetSmoothing("OUT")

		local scaleUp= AnimationGroup:CreateAnimation("Scale");
		scaleUp:SetOrder(1);
		scaleUp:SetFromScale(0.0,1.0);
		scaleUp:SetToScale(1.0,1.0);
		scaleUp:SetDuration(0.5);
		scaleUp:SetSmoothing("OUT")
		scaleUp:SetOrigin("LEFT",0,0)

		AnimationGroup:SetScript("OnPlay", function()
			if(PhaseToolkit.DeployingFrame.itemForgeRightPanelOpened) then
				PhaseToolkit.DeployingFrame.itemForgeRightPanelOpened.retractAnimation()
			end
			PhaseToolkit.DeployingFrame.phaseMemberWhitelistPanel:Show()
			PhaseToolkit.DeployingFrame.itemForgeRightPanelOpened = PhaseToolkit.DeployingFrame.phaseMemberWhitelistPanel
		end);

		AnimationGroup:Play();
	end

	PhaseToolkit.DeployingFrame.phaseMemberWhitelistPanel.retractAnimation = function ()
		local AnimationGroup = PhaseToolkit.DeployingFrame.phaseMemberWhitelistPanel:CreateAnimationGroup("retractCharacterWhitelistPanel");

		local fadeOut = AnimationGroup:CreateAnimation("Alpha");
		fadeOut:SetOrder(1);
		fadeOut:SetFromAlpha(1);
		fadeOut:SetToAlpha(0);
		fadeOut:SetDuration(0.5);
		fadeOut:SetSmoothing("OUT")

		local scaleDown= AnimationGroup:CreateAnimation("Scale");
		scaleDown:SetOrder(1);
		scaleDown:SetFromScale(1.0,1.0);
		scaleDown:SetToScale(0.0,1.0);
		scaleDown:SetDuration(0.5);
		scaleDown:SetSmoothing("OUT")
		scaleDown:SetOrigin("LEFT",0,0)

		AnimationGroup:SetScript("OnFinished", function()
			PhaseToolkit.DeployingFrame.phaseMemberWhitelistPanel:Hide()
			if PhaseToolkit.DeployingFrame.itemForgeRightPanelOpened == PhaseToolkit.DeployingFrame.phaseMemberWhitelistPanel then
				PhaseToolkit.DeployingFrame.itemForgeRightPanelOpened = nil
			end
		end);

		AnimationGroup:Play();
	end
end

local function createPhaseOfficerWhitelistPanel(context)
	local panel = CreateFrame("Frame", nil, PhaseToolkit.DeployingFrame,"PortraitFrameTemplate")
	panel:SetSize(200, 300)
	panel:SetPoint("BOTTOMLEFT", PhaseToolkit.DeployingFrame, "BOTTOMRIGHT", 0, 0)
	ButtonFrameTemplateMinimizable_HidePortrait(panel)
	NineSliceUtil.ApplyLayoutByName(panel.NineSlice, "EpsilonGoldBorderFrameTemplateNoPortrait")
	EpsilonLib.Utils.NineSlice.CropNineSliceCorners(panel.NineSlice, 0.8, true)
	EpsilonLib.Utils.NineSlice.CropNineSliceCorners(panel.NineSlice, 0.4)
	EpsilonLib.Utils.NineSlice.SetBackgroundAsViewport(panel, panel.Bg)
	panel:SetFrameStrata("LOW")
	local titleBgColor = panel:CreateTexture(nil, "BACKGROUND")
	local color = CreateColorFromHexString("80FF7100")
	titleBgColor:SetPoint("TOPLEFT", panel.TitleBg)
	titleBgColor:SetPoint("BOTTOMRIGHT", panel.TitleBg, -0, 0)
	titleBgColor:SetColorTexture(color:GetRGBA())
	panel.TitleBgColor = titleBgColor
	panel.TitleText:SetText(PhaseToolkit.CurrentLang["Phase Officer Whitelist"] or "Phase Officer Whitelist")
	panel.TitleText:SetPoint("LEFT", panel.TitleBg, "LEFT", 30, 0)
	panel:Hide()
	panel.isHiddenByDefault = true

	local addPhaseIdButton = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
	addPhaseIdButton:SetSize(25, 25)
	addPhaseIdButton:SetPoint("TOPLEFT", panel, "TOPLEFT", 5, -30)
	addPhaseIdButton.icon = addPhaseIdButton:CreateTexture(nil, "OVERLAY")
	addPhaseIdButton.icon:SetTexture("Interface\\AddOns\\"..addonName.."\\assets\\BPMAddButton.blp")
	addPhaseIdButton.icon:SetAllPoints()
	PhaseToolkit.RegisterTooltip(addPhaseIdButton, "Add phase ID to whitelist")
	PhaseToolkit.DisableComponent(addPhaseIdButton)

	local idInput = CreateFrame("EditBox", nil, panel, "InputBoxTemplate")
	idInput:SetSize(120, 20)
	idInput:SetPoint("TOPLEFT", addPhaseIdButton, "TOPRIGHT", 5, 0)
	idInput:SetAutoFocus(false)
	idInput:SetFontObject(GameFontHighlightSmall)
	idInput:SetNumeric(true)
	idInput:SetScript("OnTextChanged", function(self)
		local text = self:GetText()
		if text and text ~= "" then
			PhaseToolkit.EnableComponent(addPhaseIdButton)
		else
			PhaseToolkit.DisableComponent(addPhaseIdButton)
		end
	end)

	local scrollFrame = CreateFrame("ScrollFrame", nil, panel, "FauxScrollFrameTemplate")
	scrollFrame:SetPoint("TOPLEFT", panel, "TOPLEFT", 10, -50)
	scrollFrame:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -20, 10)
	scrollFrame:Show()

	local content = CreateFrame("Frame", nil, scrollFrame)
	content:SetPoint("TOPLEFT", scrollFrame, "TOPLEFT", 0, -10)
	content:SetPoint("BOTTOMRIGHT", scrollFrame, "BOTTOMRIGHT", 0, 0)
	content:Show()

	local rowHeight = 32
	local visibleRows = 7

	content.displayRows = content.displayRows or {}

	local function createRow(index)
		local row = CreateFrame("Button", "PTK_TAG_ROW"..index, content)
		row:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -((index - 1) * rowHeight))
		row:SetPoint("RIGHT", content, "RIGHT", 0, 0)
		row:SetHeight(rowHeight)

		row.background = row:CreateTexture(nil, "BACKGROUND")
		row.background:SetTexture("Interface\\AddOns\\"..addonName.."\\assets\\BlueprintManagerFrameBackground.blp")
		row.background:SetSize(250,35)
		row.background:SetPoint("TOPLEFT", row, "TOPLEFT", -50, 0)

		row.highlight = row:CreateTexture(nil, "OVERLAY")
		row.highlight:SetTexture("Interface\\AddOns\\"..addonName.."\\assets\\BlueprintManagerFrameForeground.blp")
		row.highlight:SetSize(170,25)
		row.highlight:SetPoint("TOPLEFT", row, "TOPLEFT", -8.5, -5.5)
		row.highlight:SetTexCoord(
			77/512, (77+360)/512,   -- left, right (77 to 437)
			26/128, (26+78)/128     -- top, bottom (26 to 104)
		);
		row.highlight:Hide()

		row.label = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
		row.label:SetPoint("LEFT", row, "LEFT", 5, 0)
		row.label:SetJustifyH("LEFT")
		row.label:SetWordWrap(false)
		row.label:SetNonSpaceWrap(true)

		row.deleteButton = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
		row.deleteButton:SetSize(20, 20)
		row.deleteButton:SetPoint("RIGHT", row, "RIGHT", -5, 0)
		row.deleteButton.icon = row.deleteButton:CreateTexture(nil, "OVERLAY")
		row.deleteButton.icon:SetTexture("Interface\\AddOns\\"..addonName.."\\assets\\BPMXButton.blp")
		row.deleteButton.icon:SetAllPoints()
		row.deleteButton:SetFrameStrata("HIGH")

		row:SetScript("OnEnter", function(self)
			if self.fullText then
				PhaseToolkit.ShowTooltip(self, self.fullText)
			end
			self.highlight:Show()
		end)

		row:SetScript("OnLeave", function(self)
			PhaseToolkit.HideTooltip()
			self.highlight:Hide()
		end)
		return row
	end


	local function updateScrollFrame()
		local offset = FauxScrollFrame_GetOffset(scrollFrame)
		local phaseIdList = PhaseToolkit.itemCreatorData.phaseWhitelistForOfficer or {}

		for i = 1, visibleRows do
			local tagIndex = offset + i
			local row = content.displayRows[i]
			local phaseId = phaseIdList[tagIndex]

			if(not row) then
				row = createRow(i)
				content.displayRows[i] = row
			end

			if phaseId then
				local fullName = phaseId
				SetCroppedTextWithTooltip(row, row.label, fullName, 180)
				row.deleteButton:SetScript("OnClick", function()
					deleteKeyFromArray(PhaseToolkit.itemCreatorData.phaseWhitelistForOfficer, phaseId)
					updateScrollFrame()
					if(PhaseToolkit.itemCreatorData.itemLink) then
						sendAddonCmd(buildItemForgeCommand("whitelist officer remove",{PhaseToolkit.itemCreatorData.itemLink},phaseId),nil,false)
					end
				end)

				row:Show()
			else
				row:Hide()
			end
		end

		if(#phaseIdList > visibleRows) then
			FauxScrollFrame_Update(scrollFrame, #phaseIdList, visibleRows, rowHeight)
		end
	end

	scrollFrame:SetScript("OnVerticalScroll", function(self, offset)
		FauxScrollFrame_OnVerticalScroll(self, offset, rowHeight, updateScrollFrame)
	end)

	addPhaseIdButton:SetScript("OnClick", function()
		local phaseID = idInput:GetText()
		if phaseID and phaseID ~= "" then
			tinsert(PhaseToolkit.itemCreatorData.phaseWhitelistForOfficer, phaseID)
			idInput:SetText("")
			PhaseToolkit.DisableComponent(addPhaseIdButton)
			updateScrollFrame()
			if(PhaseToolkit.itemCreatorData.itemLink) then
				sendAddonCmd(buildItemForgeCommand("whitelist officer add",{PhaseToolkit.itemCreatorData.itemLink},phaseID),nil,false)
			end
		end
	end)

	idInput:SetScript("OnEnterPressed", function(self)
		local phaseID = self:GetText()
		if phaseID and phaseID ~= "" then
			tinsert(PhaseToolkit.itemCreatorData.phaseWhitelistForOfficer, phaseID)
			self:SetText("")
			PhaseToolkit.DisableComponent(addPhaseIdButton)
			updateScrollFrame()
			if(PhaseToolkit.itemCreatorData.itemLink) then
				sendAddonCmd(buildItemForgeCommand("whitelist officer add",{PhaseToolkit.itemCreatorData.itemLink},phaseID),nil,false)
			end
		end
	end)


	scrollFrame.ScrollBar:SetPoint("TOPRIGHT", scrollFrame, "TOPRIGHT", 5, -12)
	scrollFrame.ScrollBar:SetPoint("BOTTOMRIGHT", scrollFrame, "BOTTOMRIGHT", 5, 15)
	scrollFrame.ScrollBar:SetFrameStrata("HIGH")


	tinsert(context, panel)
	PhaseToolkit.DeployingFrame.phaseOfficerWhitelistPanel = panel
	PhaseToolkit.DeployingFrame.phaseOfficerWhitelistPanel.updateScrollFrame = updateScrollFrame
	PhaseToolkit.DeployingFrame.phaseOfficerWhitelistPanel.deployAnimation = function()
		local AnimationGroup = PhaseToolkit.DeployingFrame.phaseOfficerWhitelistPanel:CreateAnimationGroup("deployCharacterWhitelistPanel");

		local fadeIn = AnimationGroup:CreateAnimation("Alpha");
		fadeIn:SetOrder(1);
		fadeIn:SetFromAlpha(0);
		fadeIn:SetToAlpha(1);
		fadeIn:SetDuration(0.5);
		fadeIn:SetSmoothing("OUT")

		local scaleUp= AnimationGroup:CreateAnimation("Scale");
		scaleUp:SetOrder(1);
		scaleUp:SetFromScale(0.0,1.0);
		scaleUp:SetToScale(1.0,1.0);
		scaleUp:SetDuration(0.5);
		scaleUp:SetSmoothing("OUT")
		scaleUp:SetOrigin("LEFT",0,0)

		AnimationGroup:SetScript("OnPlay", function()
			if(PhaseToolkit.DeployingFrame.itemForgeRightPanelOpened) then
				PhaseToolkit.DeployingFrame.itemForgeRightPanelOpened.retractAnimation()
			end
			PhaseToolkit.DeployingFrame.phaseOfficerWhitelistPanel:Show()
			PhaseToolkit.DeployingFrame.itemForgeRightPanelOpened = PhaseToolkit.DeployingFrame.phaseOfficerWhitelistPanel
		end);

		AnimationGroup:Play();
	end

	PhaseToolkit.DeployingFrame.phaseOfficerWhitelistPanel.retractAnimation = function ()
		local AnimationGroup = PhaseToolkit.DeployingFrame.phaseOfficerWhitelistPanel:CreateAnimationGroup("retractCharacterWhitelistPanel");

		local fadeOut = AnimationGroup:CreateAnimation("Alpha");
		fadeOut:SetOrder(1);
		fadeOut:SetFromAlpha(1);
		fadeOut:SetToAlpha(0);
		fadeOut:SetDuration(0.5);
		fadeOut:SetSmoothing("OUT")

		local scaleDown= AnimationGroup:CreateAnimation("Scale");
		scaleDown:SetOrder(1);
		scaleDown:SetFromScale(1.0,1.0);
		scaleDown:SetToScale(0.0,1.0);
		scaleDown:SetDuration(0.5);
		scaleDown:SetSmoothing("OUT")
		scaleDown:SetOrigin("LEFT",0,0)

		AnimationGroup:SetScript("OnFinished", function()
			PhaseToolkit.DeployingFrame.phaseOfficerWhitelistPanel:Hide()
			if PhaseToolkit.DeployingFrame.itemForgeRightPanelOpened == PhaseToolkit.DeployingFrame.phaseOfficerWhitelistPanel then
				PhaseToolkit.DeployingFrame.itemForgeRightPanelOpened = nil
			end
		end);

		AnimationGroup:Play();
	end
end

local function createItemPropertyPanel(context)
	local panel = CreateFrame("Frame", nil, PhaseToolkit.DeployingFrame,"PortraitFrameTemplate")
	panel:SetSize(200, 300)
	panel:SetPoint("BOTTOMRIGHT", PhaseToolkit.DeployingFrame, "BOTTOMLEFT", 0, 0)
	ButtonFrameTemplateMinimizable_HidePortrait(panel)
	NineSliceUtil.ApplyLayoutByName(panel.NineSlice, "EpsilonGoldBorderFrameTemplateNoPortrait")
	EpsilonLib.Utils.NineSlice.CropNineSliceCorners(panel.NineSlice, 0.8, true)
	EpsilonLib.Utils.NineSlice.CropNineSliceCorners(panel.NineSlice, 0.4)
	EpsilonLib.Utils.NineSlice.SetBackgroundAsViewport(panel, panel.Bg)
	panel:SetFrameStrata("LOW")
	local titleBgColor = panel:CreateTexture(nil, "BACKGROUND")
	local color = CreateColorFromHexString("80FF7100")
	titleBgColor:SetPoint("TOPLEFT", panel.TitleBg)
	titleBgColor:SetPoint("BOTTOMRIGHT", panel.TitleBg, -0, 0)
	titleBgColor:SetColorTexture(color:GetRGBA())
	panel.TitleBgColor = titleBgColor
	panel.TitleText:SetText(PhaseToolkit.CurrentLang["Item Property Panel"] or "Item Property Panel")
	panel.TitleText:SetPoint("LEFT", panel.TitleBg, "LEFT", 30, 0)
	panel:Hide()
	panel.isHiddenByDefault = true

	local adderPropertyCheckbox = CreateFrame("CheckButton", nil, panel, "UICheckButtonTemplate")
	adderPropertyCheckbox:SetPoint("TOPLEFT", panel, "TOPLEFT", 0, -25)
	adderPropertyCheckbox.text:SetText(PhaseToolkit.CurrentLang["Adder Property"] or "Adder Property")
	adderPropertyCheckbox.text:SetFontObject("GameFontHighlightSmall")
	adderPropertyCheckbox:SetSize(30,30)
	adderPropertyCheckbox:SetChecked(PhaseToolkit.itemCreatorData.itemProperty["adder"] or false)

	PhaseToolkit.RegisterTooltip(adderPropertyCheckbox, "Adder Property Tooltip")

	local addItemAnyoneCheckbox = CreateFrame("CheckButton", nil, panel, "UICheckButtonTemplate")
	addItemAnyoneCheckbox:SetPoint("TOPLEFT", adderPropertyCheckbox, "BOTTOMLEFT", 0, 0)
	addItemAnyoneCheckbox.text:SetText(PhaseToolkit.CurrentLang["Additem Anyone"] or "Additem Anyone")
	addItemAnyoneCheckbox.text:SetFontObject("GameFontHighlightSmall")
	addItemAnyoneCheckbox:SetSize(30,30)
	addItemAnyoneCheckbox:SetChecked(PhaseToolkit.itemCreatorData.itemProperty["additem"] and PhaseToolkit.itemCreatorData.itemProperty["additem"]["anyone"] or false)
	addItemAnyoneCheckbox:SetScript("OnClick", function(self)
		PhaseToolkit.itemCreatorData.itemProperty["additem"]["anyone"] = self:GetChecked()
		if(PhaseToolkit.itemCreatorData.itemLink) then
			sendAddonCmd(buildItemForgeCommand("property additem anyone", {PhaseToolkit.itemCreatorData.itemLink}, transformBoolToOnOff(PhaseToolkit.itemCreatorData.itemProperty["additem"]["anyone"])))
		end
	end)
	PhaseToolkit.RegisterTooltip(addItemAnyoneCheckbox, "Additem Anyone Tooltip")

	local addItemCharacterCheckbox = CreateFrame("CheckButton", nil, panel, "UICheckButtonTemplate")
	addItemCharacterCheckbox:SetPoint("TOPLEFT", addItemAnyoneCheckbox, "BOTTOMLEFT", 0, 0)
	addItemCharacterCheckbox.text:SetText(PhaseToolkit.CurrentLang["Additem Character"] or "Additem Character")
	addItemCharacterCheckbox.text:SetFontObject("GameFontHighlightSmall")
	addItemCharacterCheckbox:SetSize(30,30)
	addItemCharacterCheckbox:SetChecked(PhaseToolkit.itemCreatorData.itemProperty["additem"] and PhaseToolkit.itemCreatorData.itemProperty["additem"]["character"] or false)
	addItemCharacterCheckbox:SetScript("OnClick", function(self)
		PhaseToolkit.itemCreatorData.itemProperty["additem"]["character"] = self:GetChecked()
		if(PhaseToolkit.itemCreatorData.itemLink) then
			sendAddonCmd(buildItemForgeCommand("property additem character", {PhaseToolkit.itemCreatorData.itemLink}, transformBoolToOnOff(PhaseToolkit.itemCreatorData.itemProperty["additem"]["character"])))
		end
	end)
	PhaseToolkit.RegisterTooltip(addItemCharacterCheckbox, "Additem Character Tooltip")

	local addItemMemberCheckbox = CreateFrame("CheckButton", nil, panel, "UICheckButtonTemplate")
	addItemMemberCheckbox:SetPoint("TOPLEFT", addItemCharacterCheckbox, "BOTTOMLEFT", 0, 0)
	addItemMemberCheckbox.text:SetText(PhaseToolkit.CurrentLang["Additem Phase Member"] or "Additem Phase Member")
	addItemMemberCheckbox.text:SetFontObject("GameFontHighlightSmall")
	addItemMemberCheckbox:SetSize(30,30)
	addItemMemberCheckbox:SetChecked(PhaseToolkit.itemCreatorData.itemProperty["additem"] and PhaseToolkit.itemCreatorData.itemProperty["additem"]["member"] or false)
	addItemMemberCheckbox:SetScript("OnClick", function(self)
		PhaseToolkit.itemCreatorData.itemProperty["additem"]["member"] = self:GetChecked()
		if(PhaseToolkit.itemCreatorData.itemLink) then
			sendAddonCmd(buildItemForgeCommand("property additem member", {PhaseToolkit.itemCreatorData.itemLink}, transformBoolToOnOff(PhaseToolkit.itemCreatorData.itemProperty["additem"]["member"])))
		end
	end)
	PhaseToolkit.RegisterTooltip(addItemMemberCheckbox, "Additem Phase Member Tooltip")

	local addItemOfficerCheckbox = CreateFrame("CheckButton", nil, panel, "UICheckButtonTemplate")
	addItemOfficerCheckbox:SetPoint("TOPLEFT", addItemMemberCheckbox, "BOTTOMLEFT", 0, 0)
	addItemOfficerCheckbox.text:SetText(PhaseToolkit.CurrentLang["Additem Phase Officer"] or "Additem Phase Officer")
	addItemOfficerCheckbox.text:SetFontObject("GameFontHighlightSmall")
	addItemOfficerCheckbox:SetSize(30,30)
	addItemOfficerCheckbox:SetChecked(PhaseToolkit.itemCreatorData.itemProperty["additem"] and PhaseToolkit.itemCreatorData.itemProperty["additem"]["officer"] or false)
	addItemOfficerCheckbox:SetScript("OnClick", function(self)
		PhaseToolkit.itemCreatorData.itemProperty["additem"]["officer"] = self:GetChecked()
		if(PhaseToolkit.itemCreatorData.itemLink) then
			sendAddonCmd(buildItemForgeCommand("property additem officer", {PhaseToolkit.itemCreatorData.itemLink}, transformBoolToOnOff(PhaseToolkit.itemCreatorData.itemProperty["additem"]["officer"])))
		end
	end)
	PhaseToolkit.RegisterTooltip(addItemOfficerCheckbox, "Additem Phase Officer Tooltip")

	local copyPropertyCheckbox = CreateFrame("CheckButton", nil, panel, "UICheckButtonTemplate")
	copyPropertyCheckbox:SetPoint("TOPLEFT", addItemOfficerCheckbox, "BOTTOMLEFT", 0, 0)
	copyPropertyCheckbox.text:SetText(PhaseToolkit.CurrentLang["Copy Property"] or "Copy Property")
	copyPropertyCheckbox.text:SetFontObject("GameFontHighlightSmall")
	copyPropertyCheckbox:SetSize(30,30)
	copyPropertyCheckbox:SetChecked(PhaseToolkit.itemCreatorData.itemProperty["copy"] or false)
	copyPropertyCheckbox:SetScript("OnClick", function(self)
		PhaseToolkit.itemCreatorData.itemProperty["copy"] = self:GetChecked()
		if(PhaseToolkit.itemCreatorData.itemLink) then
			sendAddonCmd(buildItemForgeCommand("property copy", {PhaseToolkit.itemCreatorData.itemLink}, transformBoolToOnOff(PhaseToolkit.itemCreatorData.itemProperty["copy"])))
		end
	end)
	PhaseToolkit.RegisterTooltip(copyPropertyCheckbox, "Copy Property Tooltip")

	local creatorPropertyCheckbox = CreateFrame("CheckButton", nil, panel, "UICheckButtonTemplate")
	creatorPropertyCheckbox:SetPoint("TOPLEFT", copyPropertyCheckbox, "BOTTOMLEFT", 0, 0)
	creatorPropertyCheckbox.text:SetText(PhaseToolkit.CurrentLang["Creator Property"] or "Creator Property")
	creatorPropertyCheckbox.text:SetFontObject("GameFontHighlightSmall")
	creatorPropertyCheckbox:SetSize(30,30)
	creatorPropertyCheckbox:SetChecked(PhaseToolkit.itemCreatorData.itemProperty["creator"] or false)
	creatorPropertyCheckbox:SetScript("OnClick", function(self)
		PhaseToolkit.itemCreatorData.itemProperty["creator"] = self:GetChecked()
		if(PhaseToolkit.itemCreatorData.itemLink) then
			sendAddonCmd(buildItemForgeCommand("property creator", {PhaseToolkit.itemCreatorData.itemLink}, transformBoolToOnOff(PhaseToolkit.itemCreatorData.itemProperty["creator"])))
		end
		if PhaseToolkit.itemCreatorData.itemProperty["creator"] then
			PhaseToolkit.itemCreatorData.itemProperty["adder"] = false
			adderPropertyCheckbox:SetChecked(false)
		end
	end)
	PhaseToolkit.RegisterTooltip(creatorPropertyCheckbox, "Creator Property Tooltip")

	local infoPropertyCheckbox = CreateFrame("CheckButton", nil, panel, "UICheckButtonTemplate")
	infoPropertyCheckbox:SetPoint("TOPLEFT", creatorPropertyCheckbox, "BOTTOMLEFT", 0, 0)
	infoPropertyCheckbox.text:SetText(PhaseToolkit.CurrentLang["Info Property"] or "Info Property")
	infoPropertyCheckbox.text:SetFontObject("GameFontHighlightSmall")
	infoPropertyCheckbox:SetSize(30,30)
	infoPropertyCheckbox:SetChecked(PhaseToolkit.itemCreatorData.itemProperty["info"] or false)
	infoPropertyCheckbox:SetScript("OnClick", function(self)
		PhaseToolkit.itemCreatorData.itemProperty["info"] = self:GetChecked()
		if(PhaseToolkit.itemCreatorData.itemLink) then
			sendAddonCmd(buildItemForgeCommand("property info", {PhaseToolkit.itemCreatorData.itemLink}, transformBoolToOnOff(PhaseToolkit.itemCreatorData.itemProperty["info"])))
		end
	end)
	PhaseToolkit.RegisterTooltip(infoPropertyCheckbox, "Info Property Tooltip")

	local lookupPropertyCheckbox = CreateFrame("CheckButton", nil, panel, "UICheckButtonTemplate")
	lookupPropertyCheckbox:SetPoint("TOPLEFT", infoPropertyCheckbox, "BOTTOMLEFT", 0, 0)
	lookupPropertyCheckbox.text:SetText(PhaseToolkit.CurrentLang["Lookup Property"] or "Lookup Property")
	lookupPropertyCheckbox.text:SetFontObject("GameFontHighlightSmall")
	lookupPropertyCheckbox:SetSize(30,30)
	lookupPropertyCheckbox:SetChecked(PhaseToolkit.itemCreatorData.itemProperty["lookup"] or false)
	lookupPropertyCheckbox:SetScript("OnClick", function(self)
		PhaseToolkit.itemCreatorData.itemProperty["lookup"] = self:GetChecked()
		if(PhaseToolkit.itemCreatorData.itemLink) then
			sendAddonCmd(buildItemForgeCommand("property lookup", {PhaseToolkit.itemCreatorData.itemLink}, transformBoolToOnOff(PhaseToolkit.itemCreatorData.itemProperty["lookup"])))
		end
	end)
	PhaseToolkit.RegisterTooltip(lookupPropertyCheckbox, "Lookup Property Tooltip")

	adderPropertyCheckbox:SetScript("OnClick", function(self)
		PhaseToolkit.itemCreatorData.itemProperty["adder"] = self:GetChecked()
		if(PhaseToolkit.itemCreatorData.itemLink) then
			sendAddonCmd(buildItemForgeCommand("property adder", {PhaseToolkit.itemCreatorData.itemLink}, transformBoolToOnOff(PhaseToolkit.itemCreatorData.itemProperty["adder"])))
		end
		if PhaseToolkit.itemCreatorData.itemProperty["adder"] then
			PhaseToolkit.itemCreatorData.itemProperty["creator"] = false
			creatorPropertyCheckbox:SetChecked(false)
		end
	end)

	tinsert(context, panel)
	PhaseToolkit.DeployingFrame.itemPropertyPanel = panel
	PhaseToolkit.DeployingFrame.itemPropertyPanel.deployAnimation = function()
		local AnimationGroup = PhaseToolkit.DeployingFrame.itemPropertyPanel:CreateAnimationGroup("deployCharacterWhitelistPanel");

		local fadeIn = AnimationGroup:CreateAnimation("Alpha");
		fadeIn:SetOrder(1);
		fadeIn:SetFromAlpha(0);
		fadeIn:SetToAlpha(1);
		fadeIn:SetDuration(0.5);
		fadeIn:SetSmoothing("OUT")

		local scaleUp= AnimationGroup:CreateAnimation("Scale");
		scaleUp:SetOrder(1);
		scaleUp:SetFromScale(0.0,1.0);
		scaleUp:SetToScale(1.0,1.0);
		scaleUp:SetDuration(0.5);
		scaleUp:SetSmoothing("OUT")
		scaleUp:SetOrigin("RIGHT",0,0)

		AnimationGroup:SetScript("OnPlay", function()
			if(PhaseToolkit.DeployingFrame.itemForgeLeftPanelOpened) then
				PhaseToolkit.DeployingFrame.itemForgeLeftPanelOpened.retractAnimation()
			end
			PhaseToolkit.DeployingFrame.itemPropertyPanel:Show()
			PhaseToolkit.DeployingFrame.itemForgeLeftPanelOpened = PhaseToolkit.DeployingFrame.itemPropertyPanel
		end);

		AnimationGroup:Play();
	end

	PhaseToolkit.DeployingFrame.itemPropertyPanel.retractAnimation = function ()
		local AnimationGroup = PhaseToolkit.DeployingFrame.itemPropertyPanel:CreateAnimationGroup("retractCharacterWhitelistPanel");

		local fadeOut = AnimationGroup:CreateAnimation("Alpha");
		fadeOut:SetOrder(1);
		fadeOut:SetFromAlpha(1);
		fadeOut:SetToAlpha(0);
		fadeOut:SetDuration(0.5);
		fadeOut:SetSmoothing("OUT")

		local scaleDown= AnimationGroup:CreateAnimation("Scale");
		scaleDown:SetOrder(1);
		scaleDown:SetFromScale(1.0,1.0);
		scaleDown:SetToScale(0.0,1.0);
		scaleDown:SetDuration(0.5);
		scaleDown:SetSmoothing("OUT")
		scaleDown:SetOrigin("RIGHT",0,0)

		AnimationGroup:SetScript("OnFinished", function()
			PhaseToolkit.DeployingFrame.itemPropertyPanel:Hide()
			if PhaseToolkit.DeployingFrame.itemForgeLeftPanelOpened == PhaseToolkit.DeployingFrame.itemPropertyPanel then
				PhaseToolkit.DeployingFrame.itemForgeLeftPanelOpened = nil
			end
		end);

		AnimationGroup:Play();
	end
end

local function getItemClassObjectFromId(itemClassId)
	for _, classObject in pairs(PhaseToolkit.itemClass) do
		if classObject.classId == itemClassId then
			return classObject
		end
	end
	return nil
end

local function createItemMainConfigurationPanel(context)
	local panel = CreateFrame("Frame", nil, PhaseToolkit.DeployingFrame,"PortraitFrameTemplate")
	panel:SetSize(200, 350)
	panel:SetPoint("BOTTOMRIGHT", PhaseToolkit.DeployingFrame, "BOTTOMLEFT", 0, 0)
	ButtonFrameTemplateMinimizable_HidePortrait(panel)
	NineSliceUtil.ApplyLayoutByName(panel.NineSlice, "EpsilonGoldBorderFrameTemplateNoPortrait")
	EpsilonLib.Utils.NineSlice.CropNineSliceCorners(panel.NineSlice, 0.8, true)
	EpsilonLib.Utils.NineSlice.CropNineSliceCorners(panel.NineSlice, 0.4)
	EpsilonLib.Utils.NineSlice.SetBackgroundAsViewport(panel, panel.Bg)
	panel:SetFrameStrata("LOW")
	local titleBgColor = panel:CreateTexture(nil, "BACKGROUND")
	local color = CreateColorFromHexString("80FF7100")
	titleBgColor:SetPoint("TOPLEFT", panel.TitleBg)
	titleBgColor:SetPoint("BOTTOMRIGHT", panel.TitleBg, -0, 0)
	titleBgColor:SetColorTexture(color:GetRGBA())
	panel.TitleBgColor = titleBgColor
	panel.TitleText:SetText(PhaseToolkit.CurrentLang["Main Configuration"] or "Main Configuration")
	panel.TitleText:SetPoint("LEFT", panel.TitleBg, "LEFT", 30, 0)
	panel:Hide()
	panel.isHiddenByDefault = true

	local copyDisplayItemSlot = CreateFrame("Button", nil, panel, "BackdropTemplate")
	copyDisplayItemSlot:SetSize(36,36)
	copyDisplayItemSlot:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -35, 100)
	copyDisplayItemSlot:SetBackdrop({
		bgFile = "Interface\\Buttons\\UI-Quickslot2",
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		edgeSize = 16,
		insets = { left = 2, right = 2, top = 2, bottom = 2 },
	})

	copyDisplayItemSlot.icon = copyDisplayItemSlot:CreateTexture(nil, "OVERLAY")
	copyDisplayItemSlot.icon:SetSize(29, 29)
	copyDisplayItemSlot.icon:SetPoint("CENTER", copyDisplayItemSlot, "CENTER", 0, 0)
	copyDisplayItemSlot.icon:Hide()

	copyDisplayItemSlot.label = copyDisplayItemSlot:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	copyDisplayItemSlot.label:SetPoint("BOTTOM", copyDisplayItemSlot, "TOP", 0, 2)
	copyDisplayItemSlot.label:SetText(PhaseToolkit.CurrentLang["Display from item"] or "Display from item")

	copyDisplayItemSlot:SetScript("OnReceiveDrag", function(self)
		local cursorType, itemID, itemLink = GetCursorInfo()
		if cursorType == "item" and itemLink then
			local itemicon = GetItemIcon(itemID)
			self.icon:SetTexture(itemicon)
			if itemicon then
				self.icon:Show()
			else
				self.icon:Hide()
			end
			PhaseToolkit.itemCreatorData.itemDisplaySourceLink = itemLink
			GameTooltip:Hide()
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
			GameTooltip:SetText("we will copy the display id onto your forged item !",1,1,1)
			GameTooltip:SetHyperlink(PhaseToolkit.itemCreatorData.itemDisplaySourceLink)
			GameTooltip:Show()
			if(PhaseToolkit.itemCreatorData.itemLink) then
				sendAddonCmd(buildItemForgeCommand("display", {PhaseToolkit.itemCreatorData.itemLink,PhaseToolkit.itemCreatorData.itemDisplaySourceLink} ),nil,true)
			end
		end
		ClearCursor()
	end)

	copyDisplayItemSlot:SetScript("OnMouseDown", function(self, button)
		if button == "RightButton" then
			self.icon:Hide()
			PhaseToolkit.itemCreatorData.itemDisplaySourceLink = nil
			GameTooltip:Hide()
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
			GameTooltip:SetText("Drop a item here to copy it's display on your forged item",1,1,1)
			GameTooltip:Show()
		end
	end)

	copyDisplayItemSlot:SetScript("OnEnter", function(self)
		if PhaseToolkit.itemCreatorData.itemDisplaySourceLink then
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
			GameTooltip:SetText("we will copy the display id onto your forged item !",1,1,1)
			GameTooltip:SetHyperlink(PhaseToolkit.itemCreatorData.itemDisplaySourceLink)
			GameTooltip:Show()
		else
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
			GameTooltip:SetText("Drop a item here to copy it's display on your forged item",1,1,1)
			GameTooltip:Show()
		end
		copyDisplayItemSlot:SetBackdropBorderColor(1, 1, 0, 1)
	end)

	copyDisplayItemSlot:SetScript("OnLeave", function(self)
		GameTooltip:Hide()
		copyDisplayItemSlot:SetBackdropBorderColor(1, 1, 1, 1)
	end)

	tinsert(context,copyDisplayItemSlot)

	local itemAppearanceID = CreateFrame("EditBox", nil, panel, "InputBoxTemplate")
	itemAppearanceID:SetSize(80, 20)
	itemAppearanceID:SetPoint("TOP", copyDisplayItemSlot, "BOTTOM", 2, -15)
	itemAppearanceID:SetAutoFocus(false)
	itemAppearanceID:SetFontObject(GameFontHighlightSmall)
	itemAppearanceID:SetScript("OnEnterPressed", function(self)
		local appearanceID = self:GetText()
		if appearanceID and appearanceID ~= "" then
			PhaseToolkit.itemCreatorData.itemAppearanceID = appearanceID
			if(PhaseToolkit.itemCreatorData.itemLink and PhaseToolkit.itemCreatorData.itemAppearanceID) then
				sendAddonCmd(buildItemForgeCommand("appearance", {PhaseToolkit.itemCreatorData.itemLink,PhaseToolkit.itemCreatorData.itemAppearanceID} ))
			end
		end
		ClearCursor()
	end)

	itemAppearanceID.label = itemAppearanceID:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	itemAppearanceID.label:SetPoint("BOTTOM", itemAppearanceID, "TOP", 0, 2)
	itemAppearanceID.label:SetText(PhaseToolkit.CurrentLang["Appearance ID"] or "Appearance ID")

	PhaseToolkit.RegisterTooltip(itemAppearanceID, "Appearance ID Tooltip")

	--Scrollframes for the item class, subclass, and inventory type selection
	local leftScrollFrame = CreateFrame("ScrollFrame", nil, panel, "FauxScrollFrameTemplate")
	leftScrollFrame:SetPoint("TOPLEFT", panel, "TOPLEFT", 10, -45)
	leftScrollFrame:SetSize(80,140)
	leftScrollFrame:Show()

	local leftContent = CreateFrame("Frame", nil, leftScrollFrame)
	leftContent:SetPoint("TOPLEFT", leftScrollFrame, "TOPLEFT", -5, 5)
	leftContent:SetPoint("BOTTOMRIGHT", leftScrollFrame, "BOTTOMRIGHT", 0, 0)
	leftContent:Show()

	local leftLabel = leftContent:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	leftLabel:SetPoint("BOTTOM", leftScrollFrame, "TOP", 0, 5.5 )
	leftLabel:SetText("Item Class")

	local rightScrollFrame = CreateFrame("ScrollFrame", nil, panel, "FauxScrollFrameTemplate")
	rightScrollFrame:SetPoint("TOPLEFT", leftScrollFrame, "TOPRIGHT", 22.5, 0)
	rightScrollFrame:SetSize(60,140)

	local rightContent = CreateFrame("Frame", nil, rightScrollFrame)
	rightContent:SetPoint("TOPLEFT", rightScrollFrame, "TOPLEFT", -5, 5)
	rightContent:SetPoint("BOTTOMRIGHT", rightScrollFrame, "BOTTOMRIGHT", 0, 0)
	rightContent:Show()

	local rightLabel = rightContent:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	rightLabel:SetPoint("BOTTOM", rightScrollFrame, "TOP", 0, 5 )
	rightLabel:SetText("Item SubClass")
	rightLabel:Hide()

	local bottomScrollFrame = CreateFrame("ScrollFrame", nil, panel, "FauxScrollFrameTemplate")
	bottomScrollFrame:SetPoint("BOTTOMLEFT", panel, "BOTTOMLEFT", 5, 10)
	bottomScrollFrame:SetSize(80,150)
	bottomScrollFrame:Show()

	local bottomContent = CreateFrame("Frame", nil, bottomScrollFrame)
	bottomContent:SetPoint("TOPLEFT", bottomScrollFrame, "TOPLEFT", 0, -10)
	bottomContent:SetPoint("BOTTOMRIGHT", bottomScrollFrame, "BOTTOMRIGHT", 0, 0)
	bottomContent:Show()

	local bottomLabel = bottomContent:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	bottomLabel:SetPoint("BOTTOM", bottomScrollFrame, "TOP", 0, -10 )
	bottomLabel:SetText("Inventory Type")
	bottomLabel:Hide()

	local currentSubClassList = nil
	local currentInventoryTypeList = nil
	local rowHeight = 25
	local visibleRows = 5
	local rowSpacing = 5

	leftContent.displayRows = leftContent.displayRows or {}
	rightContent.displayRows = rightContent.displayRows or {}
	bottomContent.displayRows = bottomContent.displayRows or {}

	local function createRow(index,side)
		local parent = side == "left" and leftContent or side == "right" and rightContent or bottomContent
		local row = CreateFrame("Button", "PTK_TAG_ROW"..index, parent)

		row:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, -((index - 1) * (rowHeight + rowSpacing)))
		row:SetHeight(rowHeight)

		if side == "left" or side=="bottom" then
			row:SetWidth(80)
		else
			row:SetWidth(60)
		end

		row.background = row:CreateTexture(nil, "BACKGROUND")
		row.background:SetTexture("Interface\\AddOns\\"..addonName.."\\assets\\BlueprintManagerFrameBackground.blp")
		row.background:SetAllPoints(row)
		row.background:SetTexCoord(
			77/512, (77+360)/512,   -- left, right (77 to 437)
			26/128, (26+78)/128     -- top, bottom (26 to 104)
		);

		row.highlight = row:CreateTexture(nil, "OVERLAY")
		row.highlight:SetTexture("Interface\\AddOns\\"..addonName.."\\assets\\BlueprintManagerFrameForeground.blp")
		row.highlight:SetSize(80,25)
		row.highlight:SetAllPoints(row.background)
		row.highlight:SetTexCoord(
			77/512, (77+360)/512,   -- left, right (77 to 437)
			26/128, (26+78)/128     -- top, bottom (26 to 104)
		);
		row.highlight:Hide()

		row.label = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
		row.label:SetPoint("LEFT", row, "LEFT", 5, 0)
		row.label:SetJustifyH("LEFT")
		row.label:SetWordWrap(false)
		row.label:SetNonSpaceWrap(true)

		row:SetScript("OnEnter", function(self)
			if self.fullText then
				PhaseToolkit.ShowTooltip(self, self.fullText)
			end
			self.highlight:Show()
		end)

		return row
	end

	local function updateRightScrollFrame()
		currentSubClassList = currentSubClassList or {}
		if PhaseToolkit.itemCreatorData.selectedItemClass then
			currentSubClassList = getItemClassObjectFromId(PhaseToolkit.itemCreatorData.selectedItemClass).subclass
		end
		if #currentSubClassList / visibleRows <1 then
			FauxScrollFrame_SetOffset(rightScrollFrame, 0)
			rightScrollFrame.ScrollBar:Hide()
		end
		local offset = FauxScrollFrame_GetOffset(rightScrollFrame)
		local itemSubClass = currentSubClassList or {}

		if #itemSubClass >0 then
			rightLabel:Show()
		else
			rightLabel:Hide()
		end

		for i = 1, visibleRows do
			local tagIndex = offset + i
			local row = rightContent.displayRows[i]
			local itemSubClassEntry = itemSubClass[tagIndex]

			if(not row) then
				row = createRow(i, "right")
				rightContent.displayRows[i] = row
			end

			if itemSubClassEntry then
				local fullName = itemSubClassEntry.name
				SetCroppedTextWithTooltip(row, row.label, fullName, 60)
				row:Show()
				row:SetScript("OnClick", function()
					PhaseToolkit.itemCreatorData.selectedItemSubClass = itemSubClassEntry.subclassId
					if(PhaseToolkit.itemCreatorData.itemLink) then
						sendAddonCmd(buildItemForgeCommand("subclass", {PhaseToolkit.itemCreatorData.itemLink}, itemSubClassEntry.subclassId))
					end
					tinsert(PhaseToolkit.itemCreatorData.selectedRows,row)
					updateRightScrollFrame()
				end)
				if itemSubClassEntry.subclassId == PhaseToolkit.itemCreatorData.selectedItemSubClass then
					row.highlight:Show()
				else
					row.highlight:Hide()
				end

				row:SetScript("OnLeave", function(self)
					PhaseToolkit.HideTooltip()
					if PhaseToolkit.itemCreatorData.selectedItemSubClass == itemSubClassEntry.subclassId then
						self.highlight:Show()
					else
						self.highlight:Hide()
					end
				end)
			else
				row:Hide()
			end


		end

		if(#itemSubClass > visibleRows) then
			FauxScrollFrame_Update(rightScrollFrame, #itemSubClass, visibleRows, rowHeight)
		end
	end

	local function updateBottomScrollFrame()
		currentInventoryTypeList = currentInventoryTypeList or {}
		if PhaseToolkit.itemCreatorData.selectedItemClass then
			currentInventoryTypeList = filterInventoryTypeByClass(PhaseToolkit.itemCreatorData.selectedItemClass)
		end
		if #currentInventoryTypeList / visibleRows <1 then
			FauxScrollFrame_SetOffset(bottomScrollFrame, 0)
			bottomScrollFrame.ScrollBar:Hide()
		end
		local offset = FauxScrollFrame_GetOffset(bottomScrollFrame)
		local inventoryTypeList = currentInventoryTypeList or  {}

		if #inventoryTypeList >0 then
			bottomLabel:Show()
		else
			bottomLabel:Hide()
		end

		for i = 1, visibleRows do
			local tagIndex = offset + i
			local row = bottomContent.displayRows[i]
			local inventoryTypeEntry = inventoryTypeList[tagIndex]

			if(not row) then
				row = createRow(i, "bottom")
				bottomContent.displayRows[i] = row
			end

			if inventoryTypeEntry then
				local fullName = inventoryTypeEntry.name
				SetCroppedTextWithTooltip(row, row.label, fullName, 75)
				row:SetScript("OnClick", function()
					PhaseToolkit.itemCreatorData.selectedInventoryType = inventoryTypeEntry.inventoryTypeId
					if(PhaseToolkit.itemCreatorData.itemLink) then
						sendAddonCmd(buildItemForgeCommand("inventorytype", {PhaseToolkit.itemCreatorData.itemLink}, inventoryTypeEntry.inventoryTypeId))
					end
					tinsert(PhaseToolkit.itemCreatorData.selectedRows,row)
					updateBottomScrollFrame()
				end)

				if inventoryTypeEntry.inventoryTypeId == PhaseToolkit.itemCreatorData.selectedInventoryType then
					row.highlight:Show()
				else
					row.highlight:Hide()
				end
				row:SetScript("OnLeave", function(self)
					PhaseToolkit.HideTooltip()
					if PhaseToolkit.itemCreatorData.selectedInventoryType == inventoryTypeEntry.inventoryTypeId then
						self.highlight:Show()
					else
						self.highlight:Hide()
					end
				end)

				row:Show()
			else
				row:Hide()
			end
		end

		if(#inventoryTypeList > visibleRows) then
			FauxScrollFrame_Update(bottomScrollFrame, #inventoryTypeList, visibleRows, rowHeight)
		end
	end

	local function updateLeftScrollFrame()
		local offset = FauxScrollFrame_GetOffset(leftScrollFrame)
		local itemClass = PhaseToolkit.itemClass or {}

		for i = 1, visibleRows do
			local tagIndex = offset + i
			local row = leftContent.displayRows[i]
			local itemClassEntry = itemClass[tagIndex]

			if(not row) then
				row = createRow(i, "left")
				leftContent.displayRows[i] = row
			end

			if itemClassEntry then
				local fullName = itemClassEntry.name
				SetCroppedTextWithTooltip(row, row.label, fullName, 80)
				row:SetScript("OnClick", function()
					currentSubClassList = itemClassEntry.subclass
					if(itemClassEntry.classId ~= -1) then
						rightScrollFrame.ScrollBar:Show()
						bottomScrollFrame.ScrollBar:Show()
						bottomLabel:Show()
					else
						rightScrollFrame.ScrollBar:Hide()
						bottomScrollFrame.ScrollBar:Hide()
						bottomLabel:Hide()
					end
					tinsert(PhaseToolkit.itemCreatorData.selectedRows,row)
					updateRightScrollFrame()
					currentInventoryTypeList = filterInventoryTypeByClass(itemClassEntry.classId)
					updateBottomScrollFrame()

					if (itemClassEntry.classId == -1) then
						PhaseToolkit.itemCreatorData.selectedItemClass = nil
					else
						PhaseToolkit.itemCreatorData.selectedItemClass = itemClassEntry.classId
					end

					PhaseToolkit.itemCreatorData.selectedItemSubClass = nil
					if(PhaseToolkit.itemCreatorData.itemLink and itemClassEntry.classId ~= -1) then
						sendAddonCmd(buildItemForgeCommand("class", {PhaseToolkit.itemCreatorData.itemLink}, itemClassEntry.classId))
					end

					updateLeftScrollFrame()
				end)

				if itemClassEntry.classId == PhaseToolkit.itemCreatorData.selectedItemClass then
					row.highlight:Show()
					currentSubClassList = itemClassEntry.subclass
					currentInventoryTypeList = filterInventoryTypeByClass(itemClassEntry.classId)
					updateRightScrollFrame()
					updateBottomScrollFrame()
				else
					row.highlight:Hide()
				end

				row:SetScript("OnLeave", function(self)
					PhaseToolkit.HideTooltip()
					if PhaseToolkit.itemCreatorData.selectedItemClass == itemClassEntry.classId then
						self.highlight:Show()
					else
						self.highlight:Hide()
					end
				end)

				row:Show()
			else
				row:Hide()
			end
		end

		if(#itemClass > visibleRows) then
			FauxScrollFrame_Update(leftScrollFrame, #itemClass, visibleRows, rowHeight)
		end
	end

	leftScrollFrame.ScrollBar:SetPoint("TOPLEFT", leftScrollFrame, "TOPRIGHT", 0, -12.5)
	leftScrollFrame.ScrollBar:SetFrameStrata("HIGH")
	leftScrollFrame.ScrollBar:Hide()

	updateLeftScrollFrame()

	leftScrollFrame:SetScript("OnVerticalScroll", function(self, offset)
		FauxScrollFrame_OnVerticalScroll(self, offset, rowHeight, updateLeftScrollFrame)
	end)

	rightScrollFrame:SetScript("OnVerticalScroll", function(self, offset)
		FauxScrollFrame_OnVerticalScroll(self, offset, rowHeight, updateRightScrollFrame)
	end)

	bottomScrollFrame:SetScript("OnVerticalScroll", function(self, offset)
		FauxScrollFrame_OnVerticalScroll(self, offset, rowHeight, updateBottomScrollFrame)
	end)

	rightScrollFrame.ScrollBar:SetPoint("TOPLEFT", rightScrollFrame, "TOPRIGHT", 0, -12.5)
	rightScrollFrame.ScrollBar:SetFrameStrata("HIGH")
	rightScrollFrame.ScrollBar:Hide()

	bottomScrollFrame.ScrollBar:SetPoint("TOPLEFT", bottomScrollFrame, "TOPRIGHT", 2.5, -12.5)
	bottomScrollFrame.ScrollBar:SetPoint("BOTTOMLEFT", bottomScrollFrame, "BOTTOMRIGHT", 0, 10)
	bottomScrollFrame.ScrollBar:SetFrameStrata("HIGH")
	bottomScrollFrame.ScrollBar:Hide()


	tinsert(context,rightScrollFrame)
	tinsert(context, leftContent)
	tinsert(context, leftScrollFrame)
	tinsert(context, rightContent)

	PhaseToolkit.DeployingFrame.itemMainConfigurationPanel = panel
	PhaseToolkit.DeployingFrame.itemMainConfigurationPanel.updateItemClassScrollFrame = updateLeftScrollFrame
	PhaseToolkit.DeployingFrame.itemMainConfigurationPanel.updateItemSubClassScrollFrame = updateRightScrollFrame
	PhaseToolkit.DeployingFrame.itemMainConfigurationPanel.updateItemInventoryTypeScrollFrame = updateBottomScrollFrame

	PhaseToolkit.DeployingFrame.itemMainConfigurationPanel.deployAnimation = function()
		local AnimationGroup = PhaseToolkit.DeployingFrame.itemMainConfigurationPanel:CreateAnimationGroup("deployCharacterWhitelistPanel");

		local fadeIn = AnimationGroup:CreateAnimation("Alpha");
		fadeIn:SetOrder(1);
		fadeIn:SetFromAlpha(0);
		fadeIn:SetToAlpha(1);
		fadeIn:SetDuration(0.5);
		fadeIn:SetSmoothing("OUT")

		local scaleUp= AnimationGroup:CreateAnimation("Scale");
		scaleUp:SetOrder(1);
		scaleUp:SetFromScale(0.0,1.0);
		scaleUp:SetToScale(1.0,1.0);
		scaleUp:SetDuration(0.5);
		scaleUp:SetSmoothing("OUT")
		scaleUp:SetOrigin("RIGHT",0,0)

		AnimationGroup:SetScript("OnPlay", function()
			if(PhaseToolkit.DeployingFrame.itemForgeLeftPanelOpened) then
				PhaseToolkit.DeployingFrame.itemForgeLeftPanelOpened.retractAnimation()
			end
			PhaseToolkit.DeployingFrame.itemMainConfigurationPanel:Show()
			PhaseToolkit.DeployingFrame.itemForgeLeftPanelOpened = PhaseToolkit.DeployingFrame.itemMainConfigurationPanel
		end);

		AnimationGroup:Play();
	end

	PhaseToolkit.DeployingFrame.itemMainConfigurationPanel.retractAnimation = function ()
		local AnimationGroup = PhaseToolkit.DeployingFrame.itemMainConfigurationPanel:CreateAnimationGroup("retractCharacterWhitelistPanel");

		local fadeOut = AnimationGroup:CreateAnimation("Alpha");
		fadeOut:SetOrder(1);
		fadeOut:SetFromAlpha(1);
		fadeOut:SetToAlpha(0);
		fadeOut:SetDuration(0.5);
		fadeOut:SetSmoothing("OUT")

		local scaleDown= AnimationGroup:CreateAnimation("Scale");
		scaleDown:SetOrder(1);
		scaleDown:SetFromScale(1.0,1.0);
		scaleDown:SetToScale(0.0,1.0);
		scaleDown:SetDuration(0.5);
		scaleDown:SetSmoothing("OUT")
		scaleDown:SetOrigin("RIGHT",0,0)

		AnimationGroup:SetScript("OnFinished", function()
			PhaseToolkit.DeployingFrame.itemMainConfigurationPanel:Hide()
			if PhaseToolkit.DeployingFrame.itemForgeLeftPanelOpened == PhaseToolkit.DeployingFrame.itemMainConfigurationPanel then
				PhaseToolkit.DeployingFrame.itemForgeLeftPanelOpened = nil
			end
		end);

		AnimationGroup:Play();
	end
end

local function createItemSubConfigurationPanel(context)
	local panel = CreateFrame("Frame", nil, PhaseToolkit.DeployingFrame,"PortraitFrameTemplate")
	panel:SetSize(300, 200)
	panel:SetPoint("BOTTOMRIGHT", PhaseToolkit.DeployingFrame, "BOTTOMLEFT", 0, 0)
	ButtonFrameTemplateMinimizable_HidePortrait(panel)
	NineSliceUtil.ApplyLayoutByName(panel.NineSlice, "EpsilonGoldBorderFrameTemplateNoPortrait")
	EpsilonLib.Utils.NineSlice.CropNineSliceCorners(panel.NineSlice, 0.8, true)
	EpsilonLib.Utils.NineSlice.CropNineSliceCorners(panel.NineSlice, 0.4)
	EpsilonLib.Utils.NineSlice.SetBackgroundAsViewport(panel, panel.Bg)
	panel:SetFrameStrata("LOW")
	local titleBgColor = panel:CreateTexture(nil, "BACKGROUND")
	local color = CreateColorFromHexString("80FF7100")
	titleBgColor:SetPoint("TOPLEFT", panel.TitleBg)
	titleBgColor:SetPoint("BOTTOMRIGHT", panel.TitleBg, -0, 0)
	titleBgColor:SetColorTexture(color:GetRGBA())
	panel.TitleBgColor = titleBgColor
	panel.TitleText:SetText(PhaseToolkit.CurrentLang["Sub Configuration"] or "Sub Configuration")
	panel.TitleText:SetPoint("LEFT", panel.TitleBg, "LEFT", 30, 0)
	panel:Hide()
	panel.isHiddenByDefault = true

	-- we need 3 scrollsframes, for the itembonding, the itemQuality,and the itemSheath
	-- they are independant from each other
	local itemBondingScrollFrame = CreateFrame("ScrollFrame", nil, panel, "FauxScrollFrameTemplate")
	itemBondingScrollFrame:SetPoint("TOPLEFT", panel, "TOPLEFT", 5, -45)
	itemBondingScrollFrame:SetSize(75,140)

	local itemBondingContent = CreateFrame("Frame", nil, itemBondingScrollFrame)
	itemBondingContent:SetPoint("TOPLEFT", itemBondingScrollFrame, "TOPLEFT", 0, 5)
	itemBondingContent:SetPoint("BOTTOMRIGHT", itemBondingScrollFrame, "BOTTOMRIGHT", 0, 0)
	itemBondingContent:Show()

	local itemBondingLabel = itemBondingContent:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	itemBondingLabel:SetPoint("BOTTOM", itemBondingScrollFrame, "TOP", 0, 5.5 )
	itemBondingLabel:SetText("Item Bonding")

	local itemQualityScrollFrame = CreateFrame("ScrollFrame", nil, panel, "FauxScrollFrameTemplate")
	itemQualityScrollFrame:SetPoint("TOPLEFT", itemBondingScrollFrame, "TOPRIGHT", 22.5, 0)
	itemQualityScrollFrame:SetSize(75,140)

	local itemQualityContent = CreateFrame("Frame", nil, itemQualityScrollFrame)
	itemQualityContent:SetPoint("TOPLEFT", itemQualityScrollFrame, "TOPLEFT", 0, 5)
	itemQualityContent:SetPoint("BOTTOMRIGHT", itemQualityScrollFrame, "BOTTOMRIGHT", 0, 0)
	itemQualityContent:Show()

	local itemQualityLabel = itemQualityContent:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	itemQualityLabel:SetPoint("BOTTOM", itemQualityScrollFrame, "TOP", 0, 5 )
	itemQualityLabel:SetText("Item Quality")

	local itemSheathScrollFrame = CreateFrame("ScrollFrame", nil, panel, "FauxScrollFrameTemplate")
	itemSheathScrollFrame:SetPoint("TOPLEFT", itemQualityScrollFrame, "TOPRIGHT", 22.5, 0)
	itemSheathScrollFrame:SetSize(75,150)

	local itemSheathContent = CreateFrame("Frame", nil, itemSheathScrollFrame)
	itemSheathContent:SetPoint("TOPLEFT", itemSheathScrollFrame, "TOPLEFT", 0, 5)
	itemSheathContent:SetPoint("BOTTOMRIGHT", itemSheathScrollFrame, "BOTTOMRIGHT", 0, 0)
	itemSheathContent:Show()

	local itemSheathLabel = itemSheathContent:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	itemSheathLabel:SetPoint("BOTTOM", itemSheathScrollFrame, "TOP", 0, 5 )
	itemSheathLabel:SetText("Item Sheath")

	local rowHeight = 25
	local visibleRows = 5
	local rowSpacing = 5

	itemBondingContent.displayRows = itemBondingContent.displayRows or {}
	itemQualityContent.displayRows = itemQualityContent.displayRows or {}
	itemSheathContent.displayRows = itemSheathContent.displayRows or {}

	local function createRow(index,parent)
		local row = CreateFrame("Button", "PTK_TAG_ROW"..index, parent)

		row:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, -((index - 1) * (rowHeight + rowSpacing)))
		row:SetHeight(rowHeight)

		row:SetWidth(75)

		row.background = row:CreateTexture(nil, "BACKGROUND")
		row.background:SetTexture("Interface\\AddOns\\"..addonName.."\\assets\\BlueprintManagerFrameBackground.blp")
		row.background:SetAllPoints(row)
		row.background:SetTexCoord(
			77/512, (77+360)/512,   -- left, right (77 to 437)
			26/128, (26+78)/128     -- top, bottom (26 to 104)
		);

		row.highlight = row:CreateTexture(nil, "OVERLAY")
		row.highlight:SetTexture("Interface\\AddOns\\"..addonName.."\\assets\\BlueprintManagerFrameForeground.blp")
		row.highlight:SetSize(80,25)
		row.highlight:SetAllPoints(row.background)
		row.highlight:SetTexCoord(
			77/512, (77+360)/512,   -- left, right (77 to 437)
			26/128, (26+78)/128     -- top, bottom (26 to 104)
		);
		row.highlight:Hide()

		row.label = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
		row.label:SetPoint("LEFT", row, "LEFT", 5, 0)
		row.label:SetJustifyH("LEFT")
		row.label:SetWordWrap(false)
		row.label:SetNonSpaceWrap(true)

		row:SetScript("OnEnter", function(self)
			if self.fullText then
				PhaseToolkit.ShowTooltip(self, self.fullText)
			end
			self.highlight:Show()
		end)
		return row
	end

	local function updateItemBondingScrollFrame()
		local offset = FauxScrollFrame_GetOffset(itemBondingScrollFrame)
    	local itemBondingList = PhaseToolkit.itemBonding or {}
		for i = 1, visibleRows do
			local row = itemBondingContent.displayRows[i]
			local itemBondingEntry = itemBondingList[offset + i]

			if(not row) then
				row = createRow(i, itemBondingContent)
				itemBondingContent.displayRows[i] = row
			end

			if itemBondingEntry then
				local fullName = itemBondingEntry.name
				SetCroppedTextWithTooltip(row, row.label, fullName, 70)
				row:SetScript("OnClick", function()
					PhaseToolkit.itemCreatorData.selectedItemBonding = itemBondingEntry.bondingId
					if(PhaseToolkit.itemCreatorData.itemLink) then
						sendAddonCmd(buildItemForgeCommand("bonding", {PhaseToolkit.itemCreatorData.itemLink}, tostring(itemBondingEntry.bondingId)))
					end
					updateItemBondingScrollFrame()
				end)

				row:Show()
				if itemBondingEntry.bondingId == PhaseToolkit.itemCreatorData.selectedItemBonding then
					print("highlighting row for bondingId: "..itemBondingEntry.bondingId)
					row.highlight:Show()
				else
					row.highlight:Hide()
				end

				row:SetScript("OnLeave", function(self)
					PhaseToolkit.HideTooltip()
					if PhaseToolkit.itemCreatorData.selectedItemBonding ~= itemBondingEntry.bondingId then
						self.highlight:Hide()
					end
				end)
			else
				row:Hide()
			end

		end
		if #itemBondingList > visibleRows then
			FauxScrollFrame_Update(itemBondingScrollFrame, #itemBondingList, visibleRows, rowHeight)
		end
	end

	local function updateItemQualityScrollFrame()
		local offset = FauxScrollFrame_GetOffset(itemQualityScrollFrame)
		local itemQualityList = PhaseToolkit.itemQuality or {}
		for i = 1, visibleRows do
			local row = itemQualityContent.displayRows[i]
			local itemQualityEntry = itemQualityList[offset + i]

			if(not row) then
				row = createRow(i, itemQualityContent)
				itemQualityContent.displayRows[i] = row
			end

			if itemQualityEntry then
				local fullName = itemQualityEntry.name
				SetCroppedTextWithTooltip(row, row.label, fullName, 70)
				row:SetScript("OnClick", function()
					PhaseToolkit.itemCreatorData.selectedItemQuality = itemQualityEntry.qualityId
					if(PhaseToolkit.itemCreatorData.itemLink) then
						sendAddonCmd(buildItemForgeCommand("quality", {PhaseToolkit.itemCreatorData.itemLink}, tostring(itemQualityEntry.qualityId)))
					end
					tinsert(PhaseToolkit.itemCreatorData.selectedRows,row)
				end)

				row:SetScript("OnLeave", function(self)
					PhaseToolkit.HideTooltip()
					if PhaseToolkit.itemCreatorData.selectedItemQuality ~= itemQualityEntry.qualityId then
						self.highlight:Hide()
					end
				end)

				row:Show()
			else
				row:Hide()
			end
		end

		if #itemQualityList > visibleRows then
			FauxScrollFrame_Update(itemQualityScrollFrame, #itemQualityList, visibleRows, rowHeight)
		end
	end

	local function updateItemSheathScrollFrame()
		local offset = FauxScrollFrame_GetOffset(itemSheathScrollFrame)
		local itemSheathList = PhaseToolkit.itemSheath or {}
		for i = 1, visibleRows do
			local row = itemSheathContent.displayRows[i]
			local itemSheathEntry = itemSheathList[offset + i]

			if(not row) then
				row = createRow(i, itemSheathContent)
				itemSheathContent.displayRows[i] = row
			end

			if itemSheathEntry then
				local fullName = itemSheathEntry.name
				SetCroppedTextWithTooltip(row, row.label, fullName, 70)
				row:SetScript("OnClick", function()
					PhaseToolkit.itemCreatorData.selectedItemSheath = itemSheathEntry.sheathId
					if(PhaseToolkit.itemCreatorData.itemLink) then
						sendAddonCmd(buildItemForgeCommand("sheath", {PhaseToolkit.itemCreatorData.itemLink}, tostring(itemSheathEntry.sheathId)))
					end
					tinsert(PhaseToolkit.itemCreatorData.selectedRows,row)
				end)

				row:SetScript("OnLeave", function(self)
					PhaseToolkit.HideTooltip()
					if PhaseToolkit.itemCreatorData.selectedItemSheath ~= itemSheathEntry.sheathId then
						self.highlight:Hide()
					end
				end)

				row:Show()
			else
				row:Hide()
			end

		end

		if #itemSheathList > visibleRows then
			FauxScrollFrame_Update(itemSheathScrollFrame, #itemSheathList, visibleRows, rowHeight)
		end
	end

	itemBondingScrollFrame:SetScript("OnVerticalScroll", function(self, offset)
		FauxScrollFrame_OnVerticalScroll(self, offset, rowHeight, updateItemBondingScrollFrame)
	end)

	itemQualityScrollFrame:SetScript("OnVerticalScroll", function(self, offset)
		FauxScrollFrame_OnVerticalScroll(self, offset, rowHeight, updateItemQualityScrollFrame)
	end)

	itemSheathScrollFrame:SetScript("OnVerticalScroll", function(self, offset)
		FauxScrollFrame_OnVerticalScroll(self, offset, rowHeight, updateItemSheathScrollFrame)
	end)

	updateItemBondingScrollFrame()
	updateItemQualityScrollFrame()
	updateItemSheathScrollFrame()

	tinsert(context,panel)
	tinsert(context,itemBondingScrollFrame)
	tinsert(context,itemBondingContent)
	tinsert(context,itemQualityScrollFrame)
	tinsert(context,itemQualityContent)
	tinsert(context,itemSheathScrollFrame)
	tinsert(context,itemSheathContent)

	PhaseToolkit.DeployingFrame.itemSubConfigurationPanel = panel
	PhaseToolkit.DeployingFrame.itemSubConfigurationPanel.updateItemBondingScrollFrame = updateItemBondingScrollFrame
	PhaseToolkit.DeployingFrame.itemSubConfigurationPanel.updateItemQualityScrollFrame = updateItemQualityScrollFrame
	PhaseToolkit.DeployingFrame.itemSubConfigurationPanel.updateItemSheathScrollFrame = updateItemSheathScrollFrame

	PhaseToolkit.DeployingFrame.itemSubConfigurationPanel.deployAnimation = function()
		local AnimationGroup = PhaseToolkit.DeployingFrame.itemSubConfigurationPanel:CreateAnimationGroup("deployCharacterWhitelistPanel");

		local fadeIn = AnimationGroup:CreateAnimation("Alpha");
		fadeIn:SetOrder(1);
		fadeIn:SetFromAlpha(0);
		fadeIn:SetToAlpha(1);
		fadeIn:SetDuration(0.5);
		fadeIn:SetSmoothing("OUT")

		local scaleUp= AnimationGroup:CreateAnimation("Scale");
		scaleUp:SetOrder(1);
		scaleUp:SetFromScale(0.0,1.0);
		scaleUp:SetToScale(1.0,1.0);
		scaleUp:SetDuration(0.5);
		scaleUp:SetSmoothing("OUT")
		scaleUp:SetOrigin("RIGHT",0,0)

		AnimationGroup:SetScript("OnPlay", function()
			if(PhaseToolkit.DeployingFrame.itemForgeLeftPanelOpened) then
				PhaseToolkit.DeployingFrame.itemForgeLeftPanelOpened.retractAnimation()
			end
			PhaseToolkit.DeployingFrame.itemSubConfigurationPanel:Show()
			PhaseToolkit.DeployingFrame.itemForgeLeftPanelOpened = PhaseToolkit.DeployingFrame.itemSubConfigurationPanel
		end);
		AnimationGroup:Play()
	end
	PhaseToolkit.DeployingFrame.itemSubConfigurationPanel.retractAnimation = function ()
		local AnimationGroup = PhaseToolkit.DeployingFrame.itemSubConfigurationPanel:CreateAnimationGroup("retractCharacterWhitelistPanel");

		local fadeOut = AnimationGroup:CreateAnimation("Alpha");
		fadeOut:SetOrder(1);
		fadeOut:SetFromAlpha(1);
		fadeOut:SetToAlpha(0);
		fadeOut:SetDuration(0.5);
		fadeOut:SetSmoothing("OUT")

		local scaleDown= AnimationGroup:CreateAnimation("Scale");
		scaleDown:SetOrder(1);
		scaleDown:SetFromScale(1.0,1.0);
		scaleDown:SetToScale(0.0,1.0);
		scaleDown:SetDuration(0.5);
		scaleDown:SetSmoothing("OUT")
		scaleDown:SetOrigin("RIGHT",0,0)

		AnimationGroup:SetScript("OnFinished", function()
			PhaseToolkit.DeployingFrame.itemSubConfigurationPanel:Hide()
			if PhaseToolkit.DeployingFrame.itemForgeLeftPanelOpened == PhaseToolkit.DeployingFrame.itemSubConfigurationPanel then
				PhaseToolkit.DeployingFrame.itemForgeLeftPanelOpened = nil
			end
		end);

		AnimationGroup:Play();
	end
end


local function wipeForgeData()
	for key in pairs(PhaseToolkit.itemCreatorData) do
		if type(PhaseToolkit.itemCreatorData[key]) == "table" then
			wipe(PhaseToolkit.itemCreatorData[key])
		else
			PhaseToolkit.itemCreatorData[key] = nil
		end
	end
end

local function forgeItem()
	local commands = {}
	if PhaseToolkit.itemCreatorData.itemLink then
		if PhaseToolkit.itemCreatorData.selectedItemClass then
			tinsert(commands, buildItemForgeCommand("class", {PhaseToolkit.itemCreatorData.itemLink}, PhaseToolkit.itemCreatorData.selectedItemClass))
		end

		if PhaseToolkit.itemCreatorData.selectedItemSubClass then
			tinsert(commands, buildItemForgeCommand("subclass", {PhaseToolkit.itemCreatorData.itemLink}, PhaseToolkit.itemCreatorData.selectedItemSubClass))
		end

		if PhaseToolkit.itemCreatorData.selectedInventoryType then
			tinsert(commands, buildItemForgeCommand("inventorytype", {PhaseToolkit.itemCreatorData.itemLink}, PhaseToolkit.itemCreatorData.selectedInventoryType))
		end

		if PhaseToolkit.itemCreatorData.selectedItemBonding then
			tinsert(commands, buildItemForgeCommand("bonding", {PhaseToolkit.itemCreatorData.itemLink}, tostring(PhaseToolkit.itemCreatorData.selectedItemBonding)))
		end

		if PhaseToolkit.itemCreatorData.selectedItemQuality then
			tinsert(commands, buildItemForgeCommand("quality", {PhaseToolkit.itemCreatorData.itemLink}, tostring(PhaseToolkit.itemCreatorData.selectedItemQuality)))
		end

		if PhaseToolkit.itemCreatorData.selectedItemSheath then
			tinsert(commands, buildItemForgeCommand("sheath", {PhaseToolkit.itemCreatorData.itemLink}, tostring(PhaseToolkit.itemCreatorData.selectedItemSheath)))
		end

		if PhaseToolkit.itemCreatorData.itemDisplaySourceLink then
			tinsert(commands, buildItemForgeCommand("display ", {PhaseToolkit.itemCreatorData.itemLink,PhaseToolkit.itemCreatorData.itemDisplaySourceLink}))
		end

		if PhaseToolkit.itemCreatorData.itemAppearanceID then
			tinsert(commands, buildItemForgeCommand("display", {PhaseToolkit.itemCreatorData.itemLink},PhaseToolkit.itemCreatorData.itemAppearanceID))
		end

		if PhaseToolkit.itemCreatorData.itemName then
			tinsert(commands, buildItemForgeCommand("name", {PhaseToolkit.itemCreatorData.itemLink,PhaseToolkit.itemCreatorData.itemName}))
		end

		if PhaseToolkit.itemCreatorData.itemDescription then
			local maxDescriptionSize=238-(string.len("f i s de ")+string.len(PhaseToolkit.itemCreatorData.itemLink))
			if string.len(PhaseToolkit.itemCreatorData.itemDescription)>maxDescriptionSize then
				sendItemDescriptionInChunk("f i s de "..PhaseToolkit.itemCreatorData.itemLink.." "..PhaseToolkit.itemCreatorData.itemDescription)
			else
				tinsert(commands, buildItemForgeCommand("description", {PhaseToolkit.itemCreatorData.itemLink,PhaseToolkit.itemCreatorData.itemDescription}))
			end
		end

		if PhaseToolkit.itemCreatorData.itemProperty then
			for _,property in ipairs(PhaseToolkit.itemCreatorData.itemProperty) do
				if type(PhaseToolkit.itemCreatorData.itemProperty[property]) == "boolean" then
					tinsert(commands, buildItemForgeCommand("property "..property, {PhaseToolkit.itemCreatorData.itemLink},transformBoolToOnOff(PhaseToolkit.itemCreatorData.itemProperty[property])))
				else
					for _,value in ipairs(PhaseToolkit.itemCreatorData.itemProperty[property]) do
						tinsert(commands, buildItemForgeCommand("property "..property.." "..value, {PhaseToolkit.itemCreatorData.itemLink},transformBoolToOnOff(PhaseToolkit.itemCreatorData.itemProperty[property][value])))
					end
				end

			end
		end

		if #PhaseToolkit.itemCreatorData.characterWhitelist > 0 then
			for i, characterName in ipairs(PhaseToolkit.itemCreatorData.characterWhitelist) do
				tinsert(commands, buildItemForgeCommand("whitelist character add", {PhaseToolkit.itemCreatorData.itemLink},characterName))
			end
		end

		if #PhaseToolkit.itemCreatorData.phaseWhitelistForMember > 0 then
			for i, phaseId in ipairs(PhaseToolkit.itemCreatorData.phaseWhitelistForMember) do
				tinsert(commands, buildItemForgeCommand("whitelist member add", {PhaseToolkit.itemCreatorData.itemLink},phaseId))
			end
		end

		if #PhaseToolkit.itemCreatorData.phaseWhitelistForOfficer > 0 then
			for i, phaseId in ipairs(PhaseToolkit.itemCreatorData.phaseWhitelistForOfficer) do
				tinsert(commands, buildItemForgeCommand("whitelist officer add", {PhaseToolkit.itemCreatorData.itemLink},phaseId))
			end
		end

		if PhaseToolkit.itemCreatorData.selectedIcon then
			tinsert(commands, buildItemForgeCommand("icon", {PhaseToolkit.itemCreatorData.itemLink},PhaseToolkit.itemCreatorData.selectedIcon))
		end

		if #commands > 0 then
			sendAddonCommandChain(commands, function(success, allReturnMessages)
				-- Command chain completed
				PhaseToolkit.itemCreatorData.itemLink=nil

				-- Reset everything after all commands are done
				for key in pairs(PhaseToolkit.itemCreatorData) do
					PhaseToolkit.itemCreatorData[key] = nil
				end

				if success then
					print("Item Forging done !\nyou can use your item !")
				else
					if(PhaseToolkit.debugMode) then
						print("Item Forging had some issues. Here are the errors:")
						dump(allReturnMessages)
					else
						print("Item Forging had some issues. Run : /run PhaseToolkit.debugMode=true\nThen try again and check the chat for errors, if needed create a bug report.")
					end
				end
				ContainerFrame_UpdateAll()
			end, false)
		end

	else
		print("No item link found.\nWe should have one now.. Odd make a bug report please.")
	end

end

local function createItemAndContinue()
	if(PhaseToolkit.itemCreatorData.itemLink==nil) then
		local previousItems = updateBagContents()
		PhaseToolkit.DeployingFrame:RegisterEvent("BAG_UPDATE")
		PhaseToolkit.DeployingFrame:SetScript("OnEvent",function(self, event, arg1) C_Timer.After(1, function()
			if event == "BAG_UPDATE" then
				for _, itemID in ipairs(PhaseToolkit.currentItems) do
					if not tContains(previousItems, itemID) then
						local itemName, itemLink = GetItemInfo(itemID)

						if itemLink == nil then
							-- ItemLink failed. Let's generate a fake link.
							itemLink = minItemLink:format(tonumber(itemID), "TempLink")
						end

						PhaseToolkit.itemCreatorData.itemLink=itemLink
						forgeItem()
					end
				end
				previousItems = PhaseToolkit.currentItems
			end
		end)
	end);

		SendChatMessage(".forge item create")
		C_Timer.After(1, function()
			PhaseToolkit.currentItems=updateBagContents()

		end)
	end
end


local function forgeItem()
	print("Forging your item...")
	createItemAndContinue()
end

function PhaseToolkit.refreshAllItemCreatorScrollFrame()
	PhaseToolkit.DeployingFrame.itemMainConfigurationPanel.updateItemClassScrollFrame()
	PhaseToolkit.DeployingFrame.itemMainConfigurationPanel.updateItemSubClassScrollFrame()
	PhaseToolkit.DeployingFrame.itemMainConfigurationPanel.updateItemInventoryTypeScrollFrame()
	PhaseToolkit.DeployingFrame.itemSubConfigurationPanel.updateItemBondingScrollFrame()
	PhaseToolkit.DeployingFrame.itemSubConfigurationPanel.updateItemQualityScrollFrame()
	PhaseToolkit.DeployingFrame.itemSubConfigurationPanel.updateItemSheathScrollFrame()
	PhaseToolkit.DeployingFrame.characterWhitelistPanel.updateScrollFrame()
	PhaseToolkit.DeployingFrame.phaseMemberWhitelistPanel.updateScrollFrame()
	PhaseToolkit.DeployingFrame.phaseOfficerWhitelistPanel.updateScrollFrame()
end

local function resetForge()
	wipeForgeData()
	PhaseToolkit.DeployingFrame.itemForgeNameInput:SetText("")
	PhaseToolkit.DeployingFrame.itemForgeDescriptionFrame:SetText("")
	PhaseToolkit.DeployingFrame.midButtons.stackableSizeInput:SetNumber(1)
	PhaseToolkit.DeployingFrame.ItemDropSlot.icon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
	PhaseToolkit.refreshAllItemCreatorScrollFrame()

end

local function createItemForgeUtilityButtons(context)
	local parentFrame = CreateFrame("Frame", nil, PhaseToolkit.DeployingFrame)
	local createAndForgeItemButton = CreateFrame("Button", nil, parentFrame, "UIPanelButtonTemplate")
	createAndForgeItemButton:SetSize(30, 30)
	createAndForgeItemButton:SetPoint("TOPLEFT", PhaseToolkit.DeployingFrame, "TOPLEFT", 10, -110)
	createAndForgeItemButton.icon = createAndForgeItemButton:CreateTexture(nil, "OVERLAY")
	createAndForgeItemButton.icon:SetTexture("Interface\\Icons\\trade_blacksmithing")
	createAndForgeItemButton.icon:SetAllPoints()
	createAndForgeItemButton:SetScript("OnClick", function()
		forgeItem()
	end)

	PhaseToolkit.RegisterTooltip(createAndForgeItemButton, "Forge Item (This may take some time)")

	-- Reset Button
	local resetForgeButton=CreateFrame("Button",nil,parentFrame,"UIPanelButtonTemplate");
	resetForgeButton:SetSize(30, 30)
	resetForgeButton:SetPoint("TOPLEFT", PhaseToolkit.DeployingFrame, "TOPLEFT", 10, -140)
	resetForgeButton.icon = resetForgeButton:CreateTexture(nil, "OVERLAY")
	resetForgeButton.icon:SetTexture("Interface\\Icons\\trade_blacksmithing")
	resetForgeButton.icon:SetAllPoints()
	resetForgeButton.icon2 = resetForgeButton:CreateTexture(nil, "OVERLAY", nil, select(2,resetForgeButton.icon:GetDrawLayer())+1)
	resetForgeButton.icon2:SetAtlas("common-icon-redx")
	resetForgeButton.icon2:SetAllPoints()

	PhaseToolkit.RegisterTooltip(resetForgeButton, "Reset Forge")
	resetForgeButton:SetScript("OnClick", function()
		resetForge()
	end)

	local characterWhitelistPanelButton = CreateFrame("Button", nil, parentFrame, "UIPanelButtonTemplate")
	characterWhitelistPanelButton:SetSize(25,25)
	characterWhitelistPanelButton:SetPoint("TOPRIGHT", PhaseToolkit.DeployingFrame, "TOPRIGHT", -10, -200)
	characterWhitelistPanelButton.icon = characterWhitelistPanelButton:CreateTexture(nil, "OVERLAY")
	characterWhitelistPanelButton.icon:SetTexture("Interface\\Icons\\INV_Misc_Book_09")
	characterWhitelistPanelButton.icon:SetAllPoints()
	if not PhaseToolkit.DeployingFrame.characterWhitelistPanel then
		createCharacterWhitelistPanel(context)
	end
	characterWhitelistPanelButton:SetScript("OnClick", function()
		if PhaseToolkit.DeployingFrame.characterWhitelistPanel:IsShown() then
			PhaseToolkit.DeployingFrame.characterWhitelistPanel.retractAnimation()
		else
			PhaseToolkit.DeployingFrame.characterWhitelistPanel.deployAnimation()
		end
	end)

	PhaseToolkit.RegisterTooltip(characterWhitelistPanelButton, "Character Whitelist Panel")

	local phaseMemberWhitelistPanelButton = CreateFrame("Button", nil, parentFrame, "UIPanelButtonTemplate")
	phaseMemberWhitelistPanelButton:SetSize(25,25)
	phaseMemberWhitelistPanelButton:SetPoint("TOP", characterWhitelistPanelButton, "BOTTOM", 0, -5)
	phaseMemberWhitelistPanelButton.icon = phaseMemberWhitelistPanelButton:CreateTexture(nil, "OVERLAY")
	phaseMemberWhitelistPanelButton.icon:SetTexture("Interface\\Icons\\INV_Misc_Book_09")
	phaseMemberWhitelistPanelButton.icon:SetAllPoints()
	if not PhaseToolkit.DeployingFrame.phaseMemberWhitelistPanel then
		createPhaseMemberWhitelistPanel(context)
	end
	phaseMemberWhitelistPanelButton:SetScript("OnClick", function()
		if PhaseToolkit.DeployingFrame.phaseMemberWhitelistPanel:IsShown() then
			PhaseToolkit.DeployingFrame.phaseMemberWhitelistPanel.retractAnimation()
		else
			PhaseToolkit.DeployingFrame.phaseMemberWhitelistPanel.deployAnimation()
		end
	end)

	PhaseToolkit.RegisterTooltip(phaseMemberWhitelistPanelButton, "Phase Member Whitelist Panel")

	local phaseOfficerWhitelistPanelButton = CreateFrame("Button", nil, parentFrame, "UIPanelButtonTemplate")
	phaseOfficerWhitelistPanelButton:SetSize(25,25)
	phaseOfficerWhitelistPanelButton:SetPoint("TOP", phaseMemberWhitelistPanelButton, "BOTTOM", 0, -6)
	phaseOfficerWhitelistPanelButton.icon = phaseOfficerWhitelistPanelButton:CreateTexture(nil, "OVERLAY")
	phaseOfficerWhitelistPanelButton.icon:SetTexture("Interface\\Icons\\INV_Misc_Book_09")
	phaseOfficerWhitelistPanelButton.icon:SetAllPoints()
	if not PhaseToolkit.DeployingFrame.phaseOfficerWhitelistPanel then
		createPhaseOfficerWhitelistPanel(context)
	end
	phaseOfficerWhitelistPanelButton:SetScript("OnClick", function()
		if PhaseToolkit.DeployingFrame.phaseOfficerWhitelistPanel and PhaseToolkit.DeployingFrame.phaseOfficerWhitelistPanel:IsShown() then
			PhaseToolkit.DeployingFrame.phaseOfficerWhitelistPanel.retractAnimation()
		else
			PhaseToolkit.DeployingFrame.phaseOfficerWhitelistPanel.deployAnimation()
		end
	end)

	PhaseToolkit.RegisterTooltip(phaseOfficerWhitelistPanelButton, "Phase Officer Whitelist Panel")

	local itemPropertyPanelButton = CreateFrame("Button", nil, parentFrame, "UIPanelButtonTemplate")
	itemPropertyPanelButton:SetSize(25,25)
	itemPropertyPanelButton:SetPoint("BOTTOMLEFT", PhaseToolkit.DeployingFrame, "BOTTOMLEFT", 10, 14)
	itemPropertyPanelButton.icon = itemPropertyPanelButton:CreateTexture(nil, "OVERLAY")
	itemPropertyPanelButton.icon:SetTexture("Interface\\Icons\\INV_Misc_Book_09")
	itemPropertyPanelButton.icon:SetAllPoints()
	if not PhaseToolkit.DeployingFrame.itemPropertyPanel then
		createItemPropertyPanel(context)
	end
	itemPropertyPanelButton:SetScript("OnClick", function()
		if PhaseToolkit.DeployingFrame.itemPropertyPanel:IsShown() then
			PhaseToolkit.DeployingFrame.itemPropertyPanel.retractAnimation()
		else
			PhaseToolkit.DeployingFrame.itemPropertyPanel.deployAnimation()
		end
	end)

	PhaseToolkit.RegisterTooltip(itemPropertyPanelButton, "Item Property Panel")


	local itemSubConfigurationPanelButton = CreateFrame("Button", nil, parentFrame, "UIPanelButtonTemplate")
	itemSubConfigurationPanelButton:SetSize(25,25)
	itemSubConfigurationPanelButton:SetPoint("BOTTOM", itemPropertyPanelButton, "TOP", 0, 5)
	itemSubConfigurationPanelButton.icon = itemSubConfigurationPanelButton:CreateTexture(nil, "OVERLAY")
	itemSubConfigurationPanelButton.icon:SetTexture("Interface\\Icons\\INV_Misc_Book_09")
	itemSubConfigurationPanelButton.icon:SetAllPoints()
	if not PhaseToolkit.DeployingFrame.itemSubConfigurationPanel then
		createItemSubConfigurationPanel(context)
	end
	itemSubConfigurationPanelButton:SetScript("OnClick", function()
		if PhaseToolkit.DeployingFrame.itemSubConfigurationPanel:IsShown() then
			PhaseToolkit.DeployingFrame.itemSubConfigurationPanel.retractAnimation()
		else
			PhaseToolkit.DeployingFrame.itemSubConfigurationPanel.deployAnimation()
		end
	end)


	PhaseToolkit.RegisterTooltip(itemSubConfigurationPanelButton, "Item Sub Configuration Panel")

	local itemMainConfigurationPanelButton = CreateFrame("Button", nil, parentFrame, "UIPanelButtonTemplate")
	itemMainConfigurationPanelButton:SetSize(25,25)
	itemMainConfigurationPanelButton:SetPoint("BOTTOM", itemSubConfigurationPanelButton, "TOP", 0, 5)
	itemMainConfigurationPanelButton.icon = itemMainConfigurationPanelButton:CreateTexture(nil, "OVERLAY")
	itemMainConfigurationPanelButton.icon:SetTexture("Interface\\Icons\\INV_Misc_Book_09")
	itemMainConfigurationPanelButton.icon:SetAllPoints()
	if not PhaseToolkit.DeployingFrame.itemMainConfigurationPanel then
		createItemMainConfigurationPanel(context)
	end
	itemMainConfigurationPanelButton:SetScript("OnClick", function()
		if PhaseToolkit.DeployingFrame.itemMainConfigurationPanel:IsShown() then
			PhaseToolkit.DeployingFrame.itemMainConfigurationPanel.retractAnimation()
		else
			PhaseToolkit.DeployingFrame.itemMainConfigurationPanel.deployAnimation()
		end
	end)

	PhaseToolkit.RegisterTooltip(itemMainConfigurationPanelButton, "Item Main Configuration Panel")

	parentFrame.createAndForgeItemButton = createAndForgeItemButton
	parentFrame.resetForgeButton = resetForgeButton
	parentFrame.characterWhitelistPanelButton = characterWhitelistPanelButton
	parentFrame.phaseMemberWhitelistPanelButton = phaseMemberWhitelistPanelButton
	parentFrame.phaseOfficerWhitelistPanelButton = phaseOfficerWhitelistPanelButton
	parentFrame.itemPropertyPanelButton = itemPropertyPanelButton
	parentFrame.itemMainConfigurationPanelButton = itemMainConfigurationPanelButton
	parentFrame.itemSubConfigurationPanelButton = itemSubConfigurationPanelButton

	tinsert(context,parentFrame)
	PhaseToolkit.DeployingFrame.itemForgeUtilityButtons = parentFrame
end

local function createItemMidButtons(context)
	local parentFrame = CreateFrame("Frame", nil, PhaseToolkit.DeployingFrame)
	parentFrame:SetSize(180, 90)
	parentFrame:SetPoint("BOTTOM", PhaseToolkit.DeployingFrame, "BOTTOM", 0, 5)

	local stackableSizeInput = CreateFrame("EditBox", nil, parentFrame, "InputBoxTemplate")
	stackableSizeInput:SetSize(50, 20)
	stackableSizeInput:SetPoint("BOTTOM", parentFrame, "BOTTOM", 0, 50)
	stackableSizeInput:SetAutoFocus(false)
	stackableSizeInput:SetNumeric(true)
	stackableSizeInput:SetNumber(1)
	stackableSizeInput:SetJustifyH("CENTER")
	stackableSizeInput:SetMaxLetters(4)
	stackableSizeInput:SetScript("OnTextChanged", function(self)
		local number = self:GetText()
		if number then
			PhaseToolkit.itemCreatorData.stackableSize = number
			if(PhaseToolkit.itemCreatorData.itemLink) then
				sendAddonCmd(buildItemForgeCommand("stackable", {PhaseToolkit.itemCreatorData.itemLink}, tostring(PhaseToolkit.itemCreatorData.stackableSize)))
			end
		end
	end)

	stackableSizeInput:SetScript("OnEnterPressed", function(self)
		self:ClearFocus()
	end)

	stackableSizeInput:SetScript("OnEscapePressed", function(self)
		self:ClearFocus()
	end)

	stackableSizeInput.label = stackableSizeInput:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	stackableSizeInput.label:SetPoint("BOTTOM", stackableSizeInput, "TOP", 0, 5)
	stackableSizeInput.label:SetText(PhaseToolkit.CurrentLang["Stack Size"] or "Stack Size")

	local openIconSelectorButton = CreateFrame("Button", nil, parentFrame, "UIPanelButtonTemplate")
	openIconSelectorButton:SetSize(60, 20)
	openIconSelectorButton:SetPoint("BOTTOM", parentFrame, "BOTTOM", 0, 5)
	openIconSelectorButton:SetScript("OnClick", function()
		if EpsilonLibIconPicker and EpsilonLibIconPicker:IsShown() then
			EpsilonLibIconPicker:SetPoint("TOP", PhaseToolkit.DeployingFrame, "BOTTOM", 0, -5)
			EpsilonLibIconPicker:SetMovable(true)
			EpsilonLibIconPicker_Close()
		else
			EpsilonLibIconPicker_Open(function(iconPath,iconName,iconId)
				PhaseToolkit.itemCreatorData.selectedIcon = iconId
				if PhaseToolkit.itemCreatorData.itemLink then
					sendAddonCmd(buildItemForgeCommand("icon", {PhaseToolkit.itemCreatorData.itemLink}, iconId))
				end
				PhaseToolkit.DeployingFrame.ItemDropSlot.icon:SetTexture(iconPath)
				EpsilonLibIconPicker:SetMovable(true)
			end, true, true)
			EpsilonLibIconPicker:SetPoint("TOP", PhaseToolkit.DeployingFrame, "BOTTOM", 0, -5)
			EpsilonLibIconPicker:SetMovable(false)
		end
	end)

	openIconSelectorButton.Text:SetText("Set Icon")

	tinsert(context,parentFrame)
	PhaseToolkit.DeployingFrame.midButtons = parentFrame
	PhaseToolkit.DeployingFrame.midButtons.stackableSizeInput = stackableSizeInput
end

function PhaseToolkit.OpenItemForge()
	local context = {}
	context.id="ITEMFORGE"
	PhaseToolkit.extendDeployingFrame(0)
	if not PhaseToolkit.DeployingFrame.ItemDropSlot then
		createItemSlotButton(context)
	end
	if not PhaseToolkit.DeployingFrame.itemForgeNameInput then
		createItemForgeNameInput(context)
	end
	if not PhaseToolkit.DeployingFrame.itemForgeDescriptionFrame then
		createItemForgeDescriptionEditbox(context)
	end
	if not PhaseToolkit.DeployingFrame.itemForgeUtilityButtons then
		createItemForgeUtilityButtons(context)
	end

	if not PhaseToolkit.DeployingFrame.midButtons then
		createItemMidButtons(context)
	end

	if(#deployingFrameContext["ITEMFORGE"]<1) then
		deployingFrameContext["ITEMFORGE"] = context
	end

	PhaseToolkit.changeContext(deployingFrameContext["ITEMFORGE"])
end

-- BUTTON FRAME THING OF DOOM
function PhaseToolkit.CreateAdditionalButtonFrame()
	local NPCForgeButton=  CreateFrame("Button", nil, PhaseToolkit.NPCCustomiserMainFrame, "UIPanelButtonTemplate");
	NPCForgeButton:SetSize(40, 40);
	NPCForgeButton:SetPoint("TOPLEFT", PhaseToolkit.NPCCustomiserMainFrame, "TOPLEFT", 10, -22.5);
	NPCForgeButton.icon = NPCForgeButton:CreateTexture(nil, "OVERLAY");
	NPCForgeButton.icon:SetTexture("Interface\\AddOns\\"..addonName.."\\assets\\eps_ptk_icon_npcforge.blp");
	NPCForgeButton.icon:SetSize(33, 33);
	NPCForgeButton.icon:SetPoint("CENTER", NPCForgeButton, "CENTER", 0, 0);

	NPCForgeButton:SetScript("OnClick", function()
		if PhaseToolkit.context.id ~= "NPCFORGE" then
			PhaseToolkit.hideContext()
			PhaseToolkit.DeployingFrame.isDeployed=false
		end
		PhaseToolkit.OpenNpcForge()
	end)

	local PhaseOptionButton=CreateFrame("Button", nil, PhaseToolkit.NPCCustomiserMainFrame, "UIPanelButtonTemplate");
	PhaseOptionButton:SetSize(40, 40);
	PhaseOptionButton:SetPoint("TOPLEFT", PhaseToolkit.NPCCustomiserMainFrame, "TOPLEFT", 60, -22.5);
	PhaseOptionButton.icon = PhaseOptionButton:CreateTexture(nil, "OVERLAY")
	PhaseOptionButton.icon:SetTexture("Interface\\AddOns\\"..addonName.."\\assets\\eps_ptk_icon_settings.blp")
	PhaseOptionButton.icon:SetSize(33, 33)
	PhaseOptionButton.icon:SetPoint("CENTER", PhaseOptionButton, "CENTER", 0, 0)

	PhaseOptionButton:SetScript("OnClick", function()
		if PhaseToolkit.context.id ~= "PHASEOPTION" then
			PhaseToolkit.hideContext()
			PhaseToolkit.DeployingFrame.isDeployed=false
		end
		PhaseToolkit.OpenPhaseOption()
	end)

	local NpcListButton=CreateFrame("Button", nil, PhaseToolkit.NPCCustomiserMainFrame, "UIPanelButtonTemplate");
	NpcListButton:SetSize(40, 40);
	NpcListButton:SetPoint("TOPLEFT", PhaseToolkit.NPCCustomiserMainFrame, "TOPLEFT", 110, -22.5);
	NpcListButton.icon = NpcListButton:CreateTexture(nil, "OVERLAY")
	NpcListButton.icon:SetTexture("Interface\\AddOns\\"..addonName.."\\assets\\eps_ptk_icon_npclist.blp")
	NpcListButton.icon:SetSize(33, 33)
	NpcListButton.icon:SetPoint("CENTER", NpcListButton, "CENTER", 0, 0)

	NpcListButton:SetScript("OnClick", function()
		if PhaseToolkit.context.id ~= "NPCLIST" then
			PhaseToolkit.hideContext()
			PhaseToolkit.DeployingFrame.isDeployed=false
		end
		PhaseToolkit.createNPCList()
	end)

	local TeleListButton=CreateFrame("Button", nil, PhaseToolkit.NPCCustomiserMainFrame, "UIPanelButtonTemplate");
	TeleListButton:SetSize(40, 40);
	TeleListButton:SetPoint("TOPLEFT", PhaseToolkit.NPCCustomiserMainFrame, "TOPLEFT", 160, -22.5);
	TeleListButton.icon = TeleListButton:CreateTexture(nil, "OVERLAY")
	TeleListButton.icon:SetTexture("Interface\\AddOns\\"..addonName.."\\assets\\eps_ptk_icon_teleports.blp")
	TeleListButton.icon:SetSize(33, 33)
	TeleListButton.icon:SetPoint("CENTER", TeleListButton, "CENTER", 0, 0)

	TeleListButton:SetScript("OnClick", function()
		if PhaseToolkit.context.id ~= "TELELIST" then
			PhaseToolkit.hideContext()
			PhaseToolkit.DeployingFrame.isDeployed=false
		end
		PhaseToolkit.createTELEList()
	end)

	local ItemForgeButton=CreateFrame("Button", nil, PhaseToolkit.NPCCustomiserMainFrame, "UIPanelButtonTemplate");
	ItemForgeButton:SetSize(40, 40);
	ItemForgeButton:SetPoint("TOPLEFT", PhaseToolkit.NPCCustomiserMainFrame, "TOPLEFT", 210, -22.5);
	ItemForgeButton.icon = ItemForgeButton:CreateTexture(nil, "OVERLAY")
	ItemForgeButton.icon:SetTexture("Interface\\AddOns\\"..addonName.."\\assets\\eps_ptk_icon_itemcreator.blp")
	ItemForgeButton.icon:SetSize(33, 33)
	ItemForgeButton.icon:SetPoint("CENTER", ItemForgeButton, "CENTER", 0, 0)

	ItemForgeButton:SetScript("OnClick", function()
		if PhaseToolkit.context.id ~= "ITEMFORGE" then
			PhaseToolkit.hideContext()
			PhaseToolkit.DeployingFrame.isDeployed=false
		end
		PhaseToolkit.OpenItemForge()
	end)
end

---@param newLang string The name of the language from LangList
function PhaseToolkit.changeLang(newLang)
	--PhaseToolkit.CurrentLang = newLang
	PhaseToolkit.CurrentLang = ns.getLangTabByString(newLang) -- Since we now only pass the language name, pull the table instead
	PhaseToolkit:CreateAdditionalButtonFrame()
end

-- -- -- -- -- -- -- -- -- -- -- --
--#region Listes
-- -- -- -- -- -- -- -- -- -- -- --
--=============================== Teleport Retrieval ===========================--
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

-- ============================== Frame for Custom ============================== --

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
			PhaseToolkit.SelectedRace = getRaceDataFromRaceName(identity.race)
			PhaseToolkit.SelectedGender = identity.sexe
			--we somehow need to update the UI
			if PhaseToolkit.SelectedGender == "male" then
				PhaseToolkit.DeployingFrame.NpcGenderSlider.GoMaleAnimation:Play()
			else
				PhaseToolkit.DeployingFrame.NpcGenderSlider.GoFemaleAnimation:Play()
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



-- -- -- -- -- -- -- -- -- -- -- --
--#endregion
-- -- -- -- -- -- -- -- -- -- -- --
-- -- -- -- -- -- -- -- -- -- -- --
--#region Category System NPC
-- -- -- -- -- -- -- -- -- -- -- --
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

		if functionToCall then
			functionToCall()
		end
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

--Static popup for confirming deletion of a NPC
StaticPopupDialogs["CONFIRM_DELETE_NPC"] = {
	text = "Are you sure you want to delete this NPC?",
	button1 = "Yes",
	button2 = "No",
	OnAccept = function(self, data)
		local npcId = data and (data.npcId or data.pnjId)
		if not npcId then
			return
		end

		sendAddonCmd("phase forge npc delete " .. npcId, nil, false)
		PhaseToolkit.RemoveCreatureById(PhaseToolkit.creatureList, npcId)

		if PhaseToolkit.context
			and PhaseToolkit.context.id == "NPCLIST"
			and PhaseToolkit.DeployingFrame
			and PhaseToolkit.DeployingFrame.NpcListScrollFrame
		then
			PhaseToolkit.RefreshNpcListView()
		end
	end,
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
		sendAddonCmd("phase tele delete " .. data.teleId, nil, false)
		PhaseToolkit.RemoveStringFromTable(PhaseToolkit.teleList, data.teleId)

		if PhaseToolkit.context
			and PhaseToolkit.context.id == "TELELIST"
			and PhaseToolkit.DeployingFrame
			and PhaseToolkit.DeployingFrame.TeleListScrollFrame
		then
			PhaseToolkit.RefreshTeleListView(true)
			return
		end

		if (PhaseToolkit.IsCurrentlyFilteringTeleViaText or PhaseToolkit.IsCurrentlyFilteringTeleViaCategory) then
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

StaticPopupDialogs["OPEN_OUTFIT_COPY_POPUP"]={
	text="Copy / Export Outfit Data",
	OnShow=function(self,data)
		self.editBox:SetWidth(270)
		self.editBox:SetText(data.serializedData)
		self.editBox:SetFocus(true)
		self.editBox:HighlightText()
		self.editBox:SetScript("OnEscapePressed", function()
			self.editBox:ClearFocus()
			self:Hide()
		end)
	end,
	hasEditBox=true,
	OnAccept= function(self)
		self:Hide();
	end,
	OnCancel=function(self)
		self:Hide();
	end,
	button1 = "Close",
	timeout=0,
	hideOnEscape=true,
}

StaticPopupDialogs["OPEN_OUTFIT_PASTE_POPUP"]={
	text="Paste Outfit Data",
	OnShow=function(self,data)
		self.editBox:SetWidth(270)
		self.editBox:SetFocus(true)
		self.editBox:SetCursorPosition(0)
		self.editBox:SetScript("OnEscapePressed", function()
			self.editBox:ClearFocus()
			self:Hide()
		end)
	end,
	hasEditBox=true,
	OnAccept= function(self)
		--paste the serialized data from the edit box onto the npc
		self:Hide();
		local text = self.editBox:GetText()
		if(text and text~="") then
			PhaseToolkit.ApplyNpcCustomisation(text)
		end
	end,
	OnCancel=function(self)
		self:Hide();
	end,
	button1 = "Close",
	timeout=0,
	hideOnEscape=true,
}
