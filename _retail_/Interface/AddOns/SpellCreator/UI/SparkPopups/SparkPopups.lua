---@class ns
local ns                              = select(2, ...)
local addonName                       = ...

local Animation                       = ns.UI.Animation
local AceComm                         = ns.Libs.AceComm
local Comms                           = ns.Comms
local Constants                       = ns.Constants
local Vault                           = ns.Vault
local Icons                           = ns.UI.Icons
local Logging                         = ns.Logging
local Permissions                     = ns.Permissions
local serializer                      = ns.Serializer
local Tooltip                         = ns.Utils.Tooltip
local SparkPopups                     = ns.UI.SparkPopups
local CreateSparkUI                   = SparkPopups.CreateSparkUI
local SparkInit                       = SparkPopups.Init

local AceConfigDialog                 = ns.Libs.AceConfigDialog

local addonMsgPrefix                  = Comms.PREFIX
local DataUtils                       = ns.Utils.Data
local Debug                           = ns.Utils.Debug

local Cooldowns                       = ns.Actions.Cooldowns

local isOfficerPlus                   = Permissions.isOfficerPlus
local getDistanceBetweenPoints        = DataUtils.getDistanceBetweenPoints
local areTablesFunctionallyEquivalent = DataUtils.areTablesFunctionallyEquivalent

local ASSETS_PATH                     = Constants.ASSETS_PATH

local defaultSparkPopupStyle          = "Interface\\ExtraButton\\Default";

---@type table<number, SparkTriggerData[]>
local phaseSparkTriggers              = {}

local getPlayerPositionData           = C_Epsilon.GetPosition or function() return UnitPosition("player") end

local multiMessageData                = ns.Comms.multiMessageData
local MSG_MULTI_FIRST                 = multiMessageData.MSG_MULTI_FIRST
local MSG_MULTI_NEXT                  = multiMessageData.MSG_MULTI_NEXT
local MSG_MULTI_LAST                  = multiMessageData.MSG_MULTI_LAST
local MAX_CHARS_PER_SEGMENT           = multiMessageData.MAX_CHARS_PER_SEGMENT

local _sparkTypesMap                  = CreateSparkUI.sparkTypesMap

-------------------------------
--#region || Shared Funcs
-------------------------------
local genSparkCDNameOverride          = SparkInit.genSparkCDNameOverride
local isSparkConditionsMet            = SparkInit.isSparkConditionsMet
local isSparkOrSpellNotOnCD           = SparkInit.isSparkOrSpellNotOnCD
local isSparkType                     = ns.UI.SparkPopups.CreateSparkUI.isSparkType


---Checks if spark is in range of given X Y Z, or Player Pos if X Y Z not given
---@param sparkData SparkTriggerData
---@param x? number
---@param y? number
---@param z? number
---@return boolean
local function isSparkInRange(sparkData, x, y, z)
	if not x or not y or not z then
		x, y, z = getPlayerPositionData()
	end -- get this from player pos if we did not pass it in

	local v = sparkData
	local commID, sX, sY, sZ, sR, barTex, colorHex = v[1], v[2], v[3], v[4], v[5], v[6], v[7]

	if commID and sX and sY and sZ and sR then        -- spark has all conditions we need
		if getDistanceBetweenPoints(sX, sY, x, y) < sR then -- is in XY range
			if getDistanceBetweenPoints(z, sZ) <= sR then -- In in Z range
				return true
			end
		end
	end
	return false -- did not meet all requirements to hit true, so false
end

---Triggers a Spark! Does not parse any form of checks regarding CD, distance, or conditions.
---@param sparkData SparkTriggerData
local function triggerSpark(sparkData)
	local commID, sX, sY, sZ = sparkData[1], sparkData[2], sparkData[3], sparkData[4]
	local sparkOptions = sparkData[8] --[[@as SparkTriggerDataOptions]]

	-- Pull the Spark Data locally for easy access
	local sparkCdTime, sparkCdTrigger, sparkCdBroadcast
	if sparkOptions then
		sparkCdTime, sparkCdTrigger, sparkCdBroadcast = sparkOptions.cooldownTime, sparkOptions.trigSpellCooldown, sparkOptions.broadcastCooldown
	end

	-- All good, not on CD & Conditions met. Trigger CD's if needed & Cast the Spell.
	local bypassCD = false
	if sparkCdTime then
		local sparkCDNameOverride = genSparkCDNameOverride(commID, sX, sY, sZ) -- // need to gen the name for the override

		Cooldowns.addSparkCooldown(sparkCDNameOverride, sparkCdTime, commID)
		bypassCD = true
		if sparkCdTrigger then
			bypassCD = false
		end
		if sparkCdBroadcast then
			ns.Comms.sendSparkCooldown(sparkCDNameOverride, sparkCdTime)
			-- send something to the comms to trigger that cd on the phase.. ick..
		end
	end
	if sparkOptions.inputs then
		local success, argTable, numArgs = pcall(DataUtils.parseStringToArgs, sparkOptions.inputs)
		if success then
			ARC.PHASE:CAST(commID, bypassCD, unpack(argTable, 1, numArgs))
		else
			ARC.PHASE:CAST(commID, bypassCD)
		end
	else
		ARC.PHASE:CAST(commID, bypassCD)
	end
end


--#endregion
-------------------------------
--#region || Standard Spark
-------------------------------

---@class SparkTriggerDataOptions
---@field cooldownTime? integer
---@field trigSpellCooldown? boolean
---@field broadcastCooldown? boolean
---@field requirement? string Deprecated, use Conditions Instead!
---@field inputs? string
---@field chat? string
---@field emote? EmoteToken
---@field conditions? ConditionDataTable
---@field showHSI? boolean Should Show HiddenSparkIcon

local multiSparkFrame --predef to use in OnShow/OnHide
local sparkPopup = CreateFrame("Frame", "ArcanumSparkPopupFrame", UIParent, "SC_ExtraActionBarFrameTemplate")

-- make the sparkPopup able to be moved by dragging it; slightly smaller than the actual style frame to account for transparency on the edges
sparkPopup:SetSize(200, 100)
sparkPopup:SetMovable(true)
sparkPopup:EnableMouse(true)
sparkPopup:RegisterForDrag("LeftButton")
sparkPopup:SetScript("OnDragStart", function(self, button)
	self:StartMoving()
end)
sparkPopup:SetScript("OnDragStop", function(self)
	self:StopMovingOrSizing()
end)

sparkPopup:SetScript("OnShow", function(self)
	if not multiSparkFrame:IsUserPlaced() then
		multiSparkFrame:ClearAllPoints()
		multiSparkFrame:SetPoint("BOTTOM", self, "TOP")
	end
end)
sparkPopup:SetScript("OnHide", function(self)
	if not multiSparkFrame:IsUserPlaced() then
		multiSparkFrame:ClearAllPoints()
		multiSparkFrame:SetPoint("CENTER", self, "CENTER")
	end
end)

--#endregion
-------------------------------
--#region || Multi Spark Frame
-------------------------------
multiSparkFrame = CreateFrame("FRAME", "ArcanumMultiSparkFrame", UIParent, "ArcanumMultiSparkFrameTemplate")
multiSparkFrame:Hide()
multiSparkFrame:SetSize(256, 128)
--multiSparkFrame:SetPoint("BOTTOM", 0, 50)
multiSparkFrame:SetPoint("CENTER", sparkPopup, "CENTER")
multiSparkFrame.SpellButtonContainer:SetTemplate("Button", "SC_ExtraActionButtonTemplate");

multiSparkFrame.Style:Hide() -- This is the blizz default one, we are not going to use it due to draw layer order
multiSparkFrame:SetMovable(true)
multiSparkFrame:EnableMouse(true)
multiSparkFrame:RegisterForDrag("LeftButton")
multiSparkFrame:SetScript("OnDragStart", function(self, button)
	self:StartMoving()
end)
multiSparkFrame:SetScript("OnDragStop", function(self)
	self:StopMovingOrSizing()
end)


---Set the spells
---@param spells CommID[]
function multiSparkFrame:SetSpells(spells)
	local numSpells = #spells
	if not numSpells or numSpells == 0 then
		multiSparkFrame.SpellButtonContainer:SetContent({})
		return false
	end -- no spells

	local spellsToContent = {}
	for _, commID in ipairs(spells) do
		commID = strtrim(commID) -- just incase our split had a space left
		local spell = Vault.phase.findSpellByID(commID)
		local sparkData = multiSparkFrame.sparkData
		tinsert(spellsToContent, { spell = spell, spark = sparkData })
	end

	multiSparkFrame.SpellButtonContainer:SetContents(spellsToContent)
end

---@param style string
---@param numSpells number
function multiSparkFrame:SetStyle(style, numSpells)
	if not numSpells then
		numSpells = #multiSparkFrame.spells
	end
	if not numSpells then numSpells = 3 end -- just use a big one idk, shouldn't be possible.. if things are working..

	style = style .. "-" .. numSpells    -- add the number of spells to pull the proper texture - Styles should always be passed as the raw name, without the final "-number"

	--[[ -- Disabled Atlas Support for the time being - there is no valid WoW Atlas's setup that would work anyways.
	local isAtlas = C_Texture.GetAtlasInfo(style)
	local useAtlasSize = false

	if isAtlas then
		if numSpells > 1 then
			if not style:find("-" .. numSpells .. "$") then
				if style:find("-%d$") then
					style = style:gsub("-%d$", "") -- remove any given number already
				end
				style = style .. "-" .. numSpells
			end
		end
		self.Style:SetAtlas(style, useAtlasSize)
	else
		self.Style:SetTexture(style)
	end
	--]]

	self.Border.Style:SetTexture(style)
end

---@param commIDs CommID[]
---@param barTex string
---@param i number
---@param colorHex string
---@param sparkData SparkTriggerData
---@return boolean wasShown
local function showMultiSpark(commIDs, barTex, i, colorHex, sparkData)
	if not commIDs or #commIDs < 1 then return false end

	-- check if an update is required from the last show of MultiSpark
	local needUpdate = false
	if not areTablesFunctionallyEquivalent(commIDs, (multiSparkFrame.spells or {})) then -- Only SetSpells if there's a change. If they are functionally identical, don't - this avoids the buttons 'glitching' every re-draw as they get released & re-acquired.
		-- spells updated
		needUpdate = true
	end
	if not areTablesFunctionallyEquivalent(sparkData, multiSparkFrame.sparkData or {}) then
		-- some spark Data updated
		needUpdate = true
	end

	multiSparkFrame.index = i
	multiSparkFrame.sparkData = sparkData

	-- assign spells
	if needUpdate then
		multiSparkFrame.spells = commIDs
		multiSparkFrame:SetSpells(commIDs)
	end

	-- set style
	multiSparkFrame:SetStyle(barTex, #commIDs)
	if colorHex then
		multiSparkFrame.Border.Style:SetVertexColor(CreateColorFromHexString(colorHex):GetRGB())
	else
		multiSparkFrame.Border.Style:SetVertexColor(1, 1, 1, 1)
	end

	-- update cooldowns
	for button in pairs(multiSparkFrame.SpellButtonContainer.contentFramePool.activeObjects) do
		button:UpdateCooldown(sparkData)
	end

	-- show
	if not multiSparkFrame:IsShown() then
		multiSparkFrame:Show()
		multiSparkFrame.outro:Stop()
		multiSparkFrame.intro:Play()
	end

	return true
end

local function hideMultiSparkFrame()
	multiSparkFrame.intro:Stop();
	multiSparkFrame.outro:Play();

	--[[
	for k, v in ipairs(multiSparkFrame.SpellButtonContainer.contentFramePool) do
		v.cooldown:Clear()
	end
	--]]
end

local function triggerMultiSparkCooldown(commID, cooldownTime)
	for button in pairs(multiSparkFrame.SpellButtonContainer.contentFramePool.activeObjects) do
		if not multiSparkFrame:IsShown() then return end -- multiSparkFrame was not visible..
		if not button:IsShown() then return end    -- this button is not visible? Inactive?

		local sparkSpell = button.spell
		if sparkSpell.commID == commID or commID == "(multispark)" then
			local currTime = GetTime()
			button.cooldown:SetCooldown(currTime, cooldownTime)
		end
	end
end

--#endregion
-------------------------------
--#region || Hidden Spark Notice Frame
-------------------------------

local hiddenSparkIcon = CreateFrame("BUTTON", nil, UIParent, "SC_SimpleAnimInOutTemplate")
hiddenSparkIcon:SetSize(24, 24)
hiddenSparkIcon:SetPoint("TOP", sparkPopup, "BOTTOM")
hiddenSparkIcon:Hide()

local hiddenSparkSparkColor = CreateColor(0.37254901960784, 0.63529411764706, 0.74117647058824, 1)

hiddenSparkIcon.eye = hiddenSparkIcon:CreateTexture(nil, "BORDER")
hiddenSparkIcon.eye:SetPoint("CENTER")
hiddenSparkIcon.eye:SetSize(24, 24)
hiddenSparkIcon.eye:SetTexture(ASSETS_PATH .. "/Quickcast/Orb/OrbViolet")

hiddenSparkIcon.spark = hiddenSparkIcon:CreateTexture(nil, "OVERLAY")
hiddenSparkIcon.spark:SetPoint("CENTER")
hiddenSparkIcon.spark:SetSize(24, 24)
hiddenSparkIcon.spark:SetTexture(ASSETS_PATH .. "/spark2")
hiddenSparkIcon.spark:SetDesaturated(true)
hiddenSparkIcon.spark:SetVertexColor(hiddenSparkSparkColor:GetRGBA())

---[[
hiddenSparkIcon.spark2 = hiddenSparkIcon:CreateTexture(nil, "OVERLAY")
hiddenSparkIcon.spark2:SetBlendMode("ADD")
hiddenSparkIcon.spark2:SetPoint("CENTER")
hiddenSparkIcon.spark2:SetSize(32, 32)
hiddenSparkIcon.spark2:SetTexture(ASSETS_PATH .. "/spark2")
hiddenSparkIcon.spark2:SetDesaturated(true)
hiddenSparkIcon.spark2:SetVertexColor(hiddenSparkSparkColor:GetRGBA())
--hiddenSparkIcon.spark2:SetVertexColor(Constants.ADDON_COLORS.GEM_BOOK.PINK:GetRGBA())

--]]

--[[
hiddenSparkIcon.spark3 = hiddenSparkIcon:CreateTexture(nil, "OVERLAY")
hiddenSparkIcon.spark3:SetTexture(ASSETS_PATH .. "/cosmicvoidbolt01")
hiddenSparkIcon.spark3:SetPoint("CENTER")
hiddenSparkIcon.spark3:SetSize(32, 32)
local function spark3_Animate(self, elapsed)
	if not self:IsShown() then return end
	AnimateTexCoords(self.spark3, 512, 512, 512 / 4, 512 / 4, 16, elapsed, 0.01)
end
hiddenSparkIcon:HookScript("OnUpdate", spark3_Animate)
--]]

hiddenSparkIcon.animation = hiddenSparkIcon:CreateTexture(nil, "ARTWORK")
hiddenSparkIcon.animation:SetPoint("CENTER")
hiddenSparkIcon.animation:SetSize(42, 42)
--hiddenSparkIcon.animation:SetAtlas("Relic-Arcane-TraitGlow")
hiddenSparkIcon.animation:SetTexture(ASSETS_PATH .. "/starflash_grey")
--hiddenSparkIcon.animation:SetVertexColor(Constants.ADDON_COLORS.GAME_GOLD:GetRGBA())
hiddenSparkIcon.animation:SetVertexColor(hiddenSparkSparkColor:GetRGBA())

hiddenSparkIcon.animation.anim = hiddenSparkIcon.animation:CreateAnimationGroup()
hiddenSparkIcon.animation.anim:SetLooping("REPEAT")
hiddenSparkIcon.animation.anim.rot = hiddenSparkIcon.animation.anim:CreateAnimation("Rotation")
hiddenSparkIcon.animation.anim.rot:SetDegrees(-360)
hiddenSparkIcon.animation.anim.rot:SetDuration(10)
hiddenSparkIcon.animation.anim:SetScript("OnPlay", function(self)
	--Animation.setFrameFlicker(self:GetParent(), 2, 0.1, 0.5, 1, 0.33)
	Animation.setFrameFlicker(hiddenSparkIcon.spark2, 2, 0.1, 0.5, 1, 0.75)
end)
hiddenSparkIcon.animation.anim:SetScript("OnPause", function(self)
	--Animation.stopFrameFlicker(self:GetParent(), 1)
	Animation.stopFrameFlicker(hiddenSparkIcon.spark2, 1)
end)

hiddenSparkIcon:SetScript("OnShow", function(self) self.animation.anim:Play() end)
hiddenSparkIcon:SetScript("OnHide", function(self) self.animation.anim:Pause() end)

--[[
C_Timer.After(5, function()
	OpenColorPicker({
		swatchFunc = function()
			print(ColorPickerFrame:GetColorRGB())
			hiddenSparkIcon.spark:SetVertexColor(ColorPickerFrame:GetColorRGB())
			hiddenSparkIcon.animation:SetVertexColor(ColorPickerFrame:GetColorRGB())
			hiddenSparkIcon.spark2:SetVertexColor(ColorPickerFrame:GetColorRGB())
		end
	})
end)
--]]

Tooltip.set(hiddenSparkIcon, "There's a Spark Nearby!", nil, { delay = 0.3, forced = true })
hiddenSparkIcon:SetScript("OnClick", function(self, button)
	if (isOfficerPlus() or SpellCreatorMasterTable.Options["debug"]) and button == "RightButton" then
		SparkPopups.SparkManagerUI.showSparkManagerUI()
		return
	end
end)
hiddenSparkIcon:RegisterForClicks("RightButtonUp")
hiddenSparkIcon:EnableMouse(true)
hiddenSparkIcon:RegisterForDrag("LeftButton")

hiddenSparkIcon:SetScript("OnDragStart", function(self, button)
	sparkPopup:StartMoving()
end)
hiddenSparkIcon:SetScript("OnDragStop", function(self)
	sparkPopup:StopMovingOrSizing()
end)

hiddenSparkIcon.PlayIn = function(self)
	local bar = self;
	if not bar:IsShown() then
		bar:Show();
		bar.outro:Stop();
		bar.intro:Play();
	end
end

hiddenSparkIcon.PlayOut = function(self)
	local bar = self;
	bar.intro:Stop();
	bar.outro:Play();
end

--#endregion
-------------------------------
--#region || Main Frame Functions
-------------------------------

---Handles triggering a spark CD if a spark is actually shown & matches
---@param commID CommID commID of the spell, to check if that spark is even shown
---@param cooldownTime number time in seconds for the cooldown
local function triggerSparkCooldownVisual(commID, cooldownTime)
	local bar = sparkPopup
	if not bar:IsShown() then return end -- quick exit if no sparks are shown
	local sparkSpell = bar.button.spell -- grab the spell
	if sparkSpell.commID == commID then -- check if our commID matches the current shown spark spell
		local currTime = GetTime()
		bar.button.cooldown:SetCooldown(currTime, cooldownTime)
	end
end

-- Main Function for showing the Spark 'Pop-up' / Extra Action Button; also handles setting it's visual appearance.
---@param commID CommID
---@param barTex string|integer
---@param index integer
---@param colorHex string
---@param sparkData table
---@return boolean
local function showSparkPopup(commID, barTex, index, colorHex, sparkData)
	local bar = sparkPopup;
	local spell = Vault.phase.findSpellByID(commID)
	if not spell then return false end -- spell not found in vault, return false which will hide the sparkPopup

	local sparkButton = bar.button

	sparkButton:SetSpell(spell, sparkData)


	local texture = barTex or defaultSparkPopupStyle;
	local isAtlas = (type(texture) == "string") and C_Texture.GetAtlasInfo(texture)
	if isAtlas then
		-- It's an atlas, leave it as such
		bar.Border.style:SetAtlas(texture)
	else
		-- It's not an atlas - ensure we're using the correct %-dev string for the texture path if string, then set it as a normal texture
		if type(texture) == "string" then
			texture = texture:gsub("SpellCreator%-dev", "SpellCreator"):gsub("SpellCreator", addonName)
		end
		bar.Border.style:SetTexture(texture);
	end

	local styleData = ns.UI.SparkPopups.CreateSparkUI.sparkPopupStyles_Map[barTex]
	if styleData and styleData.circular then
		sparkButton:SetCircular()
	else
		sparkButton:SetSquare()
	end

	if colorHex then
		bar.Border.style:SetVertexColor(CreateColorFromHexString(colorHex):GetRGB())
	else
		bar.Border.style:SetVertexColor(1, 1, 1, 1)
	end

	sparkButton.index = index
	--UIParent_ManageFramePositions(); -- wtf does this do?
	if not bar:IsShown() then
		bar:Show();
		bar.outro:Stop();
		bar.intro:Play();
	end

	sparkButton:UpdateCooldown(sparkData)

	return true
end

local function hideSparkPopup()
	local bar = sparkPopup;
	bar.intro:Stop();
	bar.outro:Play();
	bar.button.cooldown:Clear()
end

--#endregion
-------------------------------
--#region || Coordinate / Location System
-------------------------------

local autoSparksInRange = {}
local CoordinateListener = CreateFrame("Frame")
local throttle, counter = 1, 0
CoordinateListener:SetScript("OnUpdate", function(self, elapsed)
	counter = counter + elapsed
	if counter < throttle then
		return
	end
	counter = 0

	if not phaseSparkTriggers then return end
	if not Vault.phase.isLoaded then return end

	local shouldHideCastbar = true
	local shouldHideMultiSparkBar = true
	local shouldShowHiddenSparkIcon = false
	local x, y, z, mapID = getPlayerPositionData()

	local phaseSpellsOnThisMap = phaseSparkTriggers[mapID]
	if phaseSpellsOnThisMap then
		for i = 1, #phaseSpellsOnThisMap do
			local sparkData = phaseSpellsOnThisMap[i]
			local commID, sX, sY, sZ, sR, barTex, colorHex = sparkData[1], sparkData[2], sparkData[3], sparkData[4], sparkData[5], sparkData[6], sparkData[7]
			local _sparkOptions = sparkData[8]
			local _sparkType = sparkData[9]

			if not _sparkType or _sparkType == _sparkTypesMap["Standard"] then -- no type = legacy spark, spark type 1 = single spark; both should show
				if commID and sX and sY and sZ and sR and barTex then
					if isSparkInRange(sparkData, x, y, z) and isSparkConditionsMet(sparkData) then
						shouldHideCastbar = not showSparkPopup(commID, barTex, i, colorHex, sparkData)
					end
				else
					Logging.dprint(nil,
						string.format("Invalid Spark Trigger (Map: %s | Index: %s) - You can manually remove it using %s", mapID, i,
							Tooltip.genContrastText(string.format("/sfdebug removeTriggerByMapAndIndex %s %s", mapID, i))))
				end
			elseif _sparkTypesMap["Multi"] and _sparkType == _sparkTypesMap["Multi"] then
				-- handle showing a multi spark!
				if isSparkInRange(sparkData, x, y, z) and isSparkConditionsMet(sparkData) then
					local commIDs = ns.Utils.Data.strsplitTrimTable(",", commID, 4)

					shouldHideMultiSparkBar = not showMultiSpark(commIDs, barTex, i, colorHex, sparkData)
				end
			elseif _sparkTypesMap["Auto"] and _sparkType == _sparkTypesMap["Auto"] then
				-- auto spark handler
				if isSparkInRange(sparkData, x, y, z) and isSparkConditionsMet(sparkData) then
					-- was in range, check if it was in the tracker before casting
					local sparkCDNameOverride = genSparkCDNameOverride(commID, sX, sY, sZ)
					shouldShowHiddenSparkIcon = true -- show the hidden spark icon always for auto sparks
					if not autoSparksInRange[sparkCDNameOverride] then
						-- spark was not already in range, continue
						autoSparksInRange[sparkCDNameOverride] = true -- track it
						SendSystemMessage(Constants.ADDON_COLORS.ADDON_COLOR:WrapTextInColorCode("Arcanum Auto Spark Triggered: ") .. Constants.ADDON_COLORS.LIGHT_PURPLE:WrapTextInColorCode(commID))
						triggerSpark(sparkData)     -- trigger spark
					end
				else
					-- spark was not in range, or conditions not met, remove it from the tracker if it was in the tracker
					local sparkCDNameOverride = genSparkCDNameOverride(commID, sX, sY, sZ)
					autoSparksInRange[sparkCDNameOverride] = nil
				end
			elseif isSparkType(_sparkType, _sparkTypesMap["Emote"], _sparkTypesMap["Chat"], _sparkTypesMap["Jump"]) then
				if _sparkOptions.showHSI then
					if isSparkInRange(sparkData, x, y, z) and isSparkConditionsMet(sparkData) then
						shouldShowHiddenSparkIcon = true
					end
				end
			end
		end
	end
	if shouldHideMultiSparkBar then hideMultiSparkFrame() end
	if shouldHideCastbar then hideSparkPopup() end
	if shouldShowHiddenSparkIcon then
		hiddenSparkIcon:PlayIn()
	else
		hiddenSparkIcon:PlayOut()
	end
end)

local function setThrottle(time)
	throttle = time                                      -- local throttle
	SpellCreatorMasterTable.Options["sparkThrottle"] = time -- saved throttle
end

local function getThrottle()
	return throttle
end

--#endregion
-----------------------------------
--#region || Popup Trigger Save/Load System
-----------------------------------

local phaseAddonDataListener = CoordinateListener -- reusing the frame - since it only listens for OnUpdate, we can steal it's OnEvent
local isGettingPopupData

---Value Order: 1=CommID, 2=x, 3=y, 4=z, 5=radius, 6=style, 7=colorHex
---@alias SparkTriggerData { [1]: CommID, [2]: number, [3]: number, [4]: number, [5]: number, [6]: number, [7]: string, [8]: SparkTriggerDataOptions, [9]: SparkTypes|number }

---Cleans any excess data from a Spark based on it's type
---@param sparkData SparkTriggerData
---@return SparkTriggerData
local function cleanSparkData(sparkData)
	local sparkOptions = sparkData[8]
	local sparkType = sparkData[9]
	if isSparkType(sparkType, _sparkTypesMap["Standard"], _sparkTypesMap["Multi"]) then
		-- visual sparks, clean any 'invisible' only spark data
		sparkOptions.showHSI = nil
		sparkOptions.chat = nil
		sparkOptions.emote = nil
	else
		-- invis spark, clean any 'visible' only spark data
		sparkData[6] = nil -- style
		sparkData[7] = nil -- colorHex
	end

	if sparkData[7] == "ffffffff" then sparkData[7] = nil end -- clear ffffffff (white) to save data storage space
	return sparkData
end

---comment
---@param commID CommID
---@param radius number
---@param style? integer
---@param x number
---@param y number
---@param z number
---@param colorHex? string
---@param options SparkTriggerDataOptions?
---@param sparkType SparkTypes|number
---@return SparkTriggerData
local function createSparkEntry(commID, radius, style, x, y, z, colorHex, options, sparkType)
	if not sparkType then sparkType = 1 end -- always ensure we have a valid SparkType going forward

	local _newSparkTrigger = { commID, x, y, z, radius, style, colorHex, options, sparkType }
	_newSparkTrigger = cleanSparkData(_newSparkTrigger)
	return _newSparkTrigger
end

---@param status boolean
local function setSparkLoadingStatus(status)
	isGettingPopupData = status
	SCForgeMainFrame.LoadSpellFrame.SparkManagerButton:UpdateEnabled()
end

---@return boolean
local function getSparkLoadingStatus()
	return isGettingPopupData
end

---@param toggle boolean
local function sendPhaseSparkIOLock(toggle)
	local phaseID = tostring(C_Epsilon.GetPhaseId())
	local scforge_ChannelID = ns.Constants.ADDON_CHANNEL
	if toggle == true then
		AceComm:SendCommMessage(addonMsgPrefix .. "_SLOCK", phaseID, "CHANNEL", tostring(scforge_ChannelID))
		Logging.dprint("Sending Lock Spark IO Message for phase " .. phaseID)
	elseif toggle == false then
		AceComm:SendCommMessage(addonMsgPrefix .. "_SUNLOCK", phaseID, "CHANNEL", tostring(scforge_ChannelID))
		Logging.dprint("Sending Unlock Spark Vault IO Message for phase " .. phaseID)
	end
end

local function noPopupsToLoad()
	Logging.dprint("Phase Has No Popup Triggers to load.");
	phaseAddonDataListener:UnregisterEvent("CHAT_MSG_ADDON");
	setSparkLoadingStatus(false)
	phaseSparkTriggers = {}
end

local sparkStrings = {}
local multipartIter = 0

---@param callback function?
---@param iter integer?
local function getPopupTriggersFromPhase(callback, iter)
	if isGettingPopupData and not iter then
		Logging.eprint("Arcanum is already loading or saving Spark data. To avoid data corruption, you can't do that right now. Try again in a moment.");
		return;
	end
	setSparkLoadingStatus(true)

	phaseSparkTriggers = {}

	local dataKey = "SCFORGE_POPUPS"
	if iter then dataKey = "SCFORGE_POPUPS_" .. iter + 1 end
	local messageTicketID = C_Epsilon.GetPhaseAddonData(dataKey)
	phaseAddonDataListener:RegisterEvent("CHAT_MSG_ADDON")
	phaseAddonDataListener:SetScript("OnEvent", function(self, event, prefix, text, channel, sender, ...)
		if event == "CHAT_MSG_ADDON" and prefix == messageTicketID and text then
			phaseAddonDataListener:UnregisterEvent("CHAT_MSG_ADDON")

			if string.match(text, "^[\001-\002]") then -- if first character is a multi-part identifier - \001 = first, \002 = middle, then we can add it to the strings table, and return with a call to get the next segment
				multipartIter = multipartIter + 1 -- progress the iterator tracker
				text = text:gsub("^[\001-\002]", "") -- remove the control character
				sparkStrings[multipartIter] = text -- add to the table
				Logging.dprint("First, or Mid- Popup Data Received, Asking for Next Segment!")
				return getPopupTriggersFromPhase(callback, multipartIter)
			elseif string.match(text, "^[\003]") then -- if first character is a last identifier - \003 = last, then we can add it to our table, then concat into a final string to use and continue
				multipartIter = multipartIter + 1 -- progress the iterator tracker
				text = text:gsub("^[\003]", "") -- remove the control character
				Logging.dprint("Last Popup Data Received, Concat & Save coming up!")
				sparkStrings[multipartIter] = text -- add to the table
				text = table.concat(sparkStrings, "")

				-- reset our temp data
				wipe(sparkStrings) -- wipe it so we can just reuse the table instead of always making new ones
				multipartIter = 0
			else
				Logging.dprint("Spark Popup Data was not a multi-part tagged string, continuing to load normally.")
			end

			local noTriggers
			if not (#text < 1 or text == "") then
				local loaded
				--phaseSparkTriggers = serializer.decompressForAddonMsg(text)
				loaded, phaseSparkTriggers = pcall(serializer.decompressForAddonMsg, text)
				if not loaded then
					message("Arcanum Failed to Load Phase Sparks Data. Report this.")
					return
				end
				if next(phaseSparkTriggers) then
					--Logging.dprint("Phase Spark Triggers: ")
					--Debug.ddump(phaseSparkTriggers)
				else
					noTriggers = true
					Logging.dprint("Failed a next check on phaseSparkTriggers")
				end
			else
				noTriggers = true
				Logging.dprint("Failed text length or blank string validation on phaseSparkTriggers")
			end
			if noTriggers then noPopupsToLoad() end
			if callback then callback() end
			setSparkLoadingStatus(false)
		end
	end)
end

local function savePopupTriggersToPhaseData()
	local str = serializer.compressForAddonMsg(phaseSparkTriggers)
	local sparksLength = #str
	if sparksLength > MAX_CHARS_PER_SEGMENT then
		Logging.dprint("Sparks Exceeded MAX_CHARS_PER_SEGMENT : " .. sparksLength)
		local numEntriesRequired = math.ceil(sparksLength / MAX_CHARS_PER_SEGMENT)
		for i = 1, numEntriesRequired do
			local strSub = string.sub(str, (MAX_CHARS_PER_SEGMENT * (i - 1)) + 1, (MAX_CHARS_PER_SEGMENT * i))
			if i == 1 then
				strSub = MSG_MULTI_FIRST .. strSub
				--Logging.dprint(nil, "SCFORGE_POPUPS :: " .. strSub)
				Logging.dprint(nil, "SCFORGE_POPUPS :: " .. "<trimmed - bulk/first>")
				C_Epsilon.SetPhaseAddonData("SCFORGE_POPUPS", strSub)
			else
				local controlChar = MSG_MULTI_NEXT
				if i == numEntriesRequired then controlChar = MSG_MULTI_LAST end
				strSub = controlChar .. strSub
				--Logging.dprint(nil, "SCFORGE_POPUPS_" .. i .. " :: " .. strSub)
				Logging.dprint(nil, "SCFORGE_POPUPS_" .. i .. " :: " .. "<trimmed - bulk/mid or last>")
				C_Epsilon.SetPhaseAddonData("SCFORGE_POPUPS_" .. i, strSub)
			end
		end
	else
		--Logging.dprint(nil, "SCFORGE_POPUPS :: " .. str)
		Logging.dprint(nil, "SCFORGE_POPUPS :: " .. "<trimmed - solo>")
		C_Epsilon.SetPhaseAddonData("SCFORGE_POPUPS", str)
	end

	SparkPopups.SparkManagerUI.refreshSparkManagerUI()
	sendPhaseSparkIOLock(false)
end

---@param commID CommID
---@param radius number
---@param style integer
---@param x number
---@param y number
---@param z number
---@param mapID integer
---@param options SparkTriggerDataOptions
---@param sparkType SparkTypes|number
local function addPopupTriggerToPhaseData(commID, radius, style, x, y, z, colorHex, mapID, options, overwriteIndex, sparkType)
	sendPhaseSparkIOLock(true)
	getPopupTriggersFromPhase(function()
		local triggerData = createSparkEntry(commID, radius, style, x, y, z, colorHex, options, sparkType)
		if not phaseSparkTriggers then
			phaseSparkTriggers = {}
			Logging.dprint("Phase Spark Triggers was Blank")
		end
		if not phaseSparkTriggers[mapID] then
			phaseSparkTriggers[mapID] = {}
			Logging.dprint("PhaseSparkTriggers for map " .. mapID .. " was blank.")
		end
		if overwriteIndex then
			phaseSparkTriggers[mapID][overwriteIndex] = triggerData
		else
			tinsert(phaseSparkTriggers[mapID], triggerData)
		end
		--ns.Utils.Debug.ddump(phaseSparkTriggers)
		savePopupTriggersToPhaseData()
		--sendPhaseSparkIOLock(false) --// called in savePopupTriggersToPhaseData instead
	end)
end

---@param mapID integer
---@param index integer
---@param callback function
local function removeTriggerFromPhaseDataByMapAndIndex(mapID, index, callback)
	sendPhaseSparkIOLock(true)
	getPopupTriggersFromPhase(function()
		if not phaseSparkTriggers then return Logging.dprint("No phaseSparkTriggers found. How?") end
		if not phaseSparkTriggers[mapID] then return Logging.dprint("No phaseSparkTriggers for map " .. mapID .. " found. How?") end
		tremove(phaseSparkTriggers[mapID], index)
		if not next(phaseSparkTriggers[mapID]) then
			phaseSparkTriggers[mapID] = nil
		end

		--ns.Utils.Debug.ddump(phaseSparkTriggers)
		savePopupTriggersToPhaseData()

		if callback then callback(mapID, index) end
		--sendPhaseSparkIOLock(false) --// called in savePopupTriggersToPhaseData instead
	end)
end

local function getPhaseSparkTriggersCache()
	return phaseSparkTriggers
end

local function setPhaseSparkTriggersCache(data)
	phaseSparkTriggers = data
end

--#endregion
---------------------
--#region || Keybinding
---------------------

local default_spark_keybind = ns.Constants.SPARK_DEFAULT_KEYBIND
local sparkKeybindHolder = CreateFrame("Frame")
local function setSparkKeybind(key)
	if key then
		if key == "" then
			SpellCreatorMasterTable.Options.sparkKeybind = false
			ClearOverrideBindings(sparkKeybindHolder)
		else
			SpellCreatorMasterTable.Options.sparkKeybind = key
			SetOverrideBindingClick(sparkKeybindHolder, true, key, "ArcanumSparkPopupButton", "keybind")
		end
	else
		SpellCreatorMasterTable.Options.sparkKeybind = false
		ClearOverrideBindings(sparkKeybindHolder)
	end
end

local function getSparkKeybind()
	return SpellCreatorMasterTable.Options.sparkKeybind
end

local function setSparkDefaultKeybind()
	local fBinding = GetBindingAction(default_spark_keybind)
	if (fBinding == "") or (fBinding == "ASSISTTARGET") then -- f was not bound or was default binding, we can override it.
		setSparkKeybind("F")
	else                                                  -- player uses F for something else, dumb. Fine, we won't override, but give them a warning.
		ns.Logging.cprint(("Arcanum defaults to using the %s keybind for Spark activation. You currently have this bound to something other than default (Current Bound Action: '%s'). We recommend opening your Arcanum settings ( %s ) and setting this to something that works for you.")
			:format(ns.Utils.Tooltip.genContrastText("'" .. default_spark_keybind .. "'"), ns.Utils.Tooltip.genContrastText(GetBindingAction("F")),
				ns.Utils.Tooltip.genContrastText("'/sf options' -> Spark Settings")))
		setSparkKeybind()
	end
end

--#endregion
---------------------
--#region || Extended Spark Handlers
---------------------

---Check Sparks with an additional predicate function. Predicate must return true to continue to cast.
---@param pred fun(sparkData: VaultSpell, ...)
---@param expensive? boolean Whether the predicate should be considered expensive or not. If it's expensive, range is checked before predicate.
---@param ... unknown any additional input, this is passed to the predicate function after the sparkData
local function checkSparksWithPredicate(pred, expensive, ...)
	if not pred then error("SparkPopups:checkSparksWithPredicate -- Error: Cannot call without predicate.") end
	local x, y, z, mapID = getPlayerPositionData()

	local phaseSpellsOnThisMap = phaseSparkTriggers and phaseSparkTriggers[mapID]
	if phaseSpellsOnThisMap then
		for i = 1, #phaseSpellsOnThisMap do
			local sparkData = phaseSpellsOnThisMap[i]

			if expensive then                                                                              -- check range first
				if isSparkInRange(sparkData, x, y, z) then
					if pred(sparkData, ...) and isSparkOrSpellNotOnCD(sparkData) and isSparkConditionsMet(sparkData) then -- still check conditions after pred
						triggerSpark(sparkData)
					end
				end
			else
				if pred(sparkData, ...) then
					if isSparkInRange(sparkData, x, y, z) and isSparkOrSpellNotOnCD(sparkData) and isSparkConditionsMet(sparkData) then
						triggerSpark(sparkData)
					end
				end
			end
		end
	end
end

-- Emote
local function emotePredicate(sparkData, token)
	local sparkType = sparkData[9]
	if isSparkType(sparkType, _sparkTypesMap["Emote"]) then
		local sparkOptions = sparkData[8]
		if sparkOptions and sparkOptions.emote and token == string.upper(sparkOptions.emote) then
			return true
		end
	end
	return false
end
local function onEmote(token)
	checkSparksWithPredicate(emotePredicate, false, token)
end
hooksecurefunc("DoEmote", onEmote)

-- Chat
local allowedChats = {
	["SAY"] = true,
	["EMOTE"] = true,
	["YELL"] = true,
}

local function chatPredicate(sparkData, msg)
	local sparkType = sparkData[9]
	if isSparkType(sparkType, _sparkTypesMap["Chat"]) then
		local sparkOptions = sparkData[8] --[[@as SparkTriggerDataOptions]]
		if sparkOptions and sparkOptions.chat and string.lower(msg) == string.lower(sparkOptions.chat) then
			return true
		end
	end
	return false
end
local function onChat(msg, chatType, languageID, target)
	if not msg then return end
	if not chatType then chatType = "SAY" end

	-- only listen to say, emote, yell:
	if not allowedChats[chatType] then return end

	checkSparksWithPredicate(chatPredicate, false, msg)
end
hooksecurefunc("SendChatMessage", onChat)

-- Jump
local function jumpPredicate(sparkData)
	local sparkType = sparkData[9]
	if isSparkType(sparkType, _sparkTypesMap["Jump"]) then
		return true
	end
end
local function onJump()
	checkSparksWithPredicate(jumpPredicate)
end
hooksecurefunc("JumpOrAscendStart", onJump)

---------------------
--#endregion
---------------------


---@class UI_SparkPopups_SparkPopups
ns.UI.SparkPopups.SparkPopups = {
	getPopupTriggersFromPhase = getPopupTriggersFromPhase,
	addPopupTriggerToPhaseData = addPopupTriggerToPhaseData,
	getPhaseSparkTriggersCache = getPhaseSparkTriggersCache,
	setPhaseSparkTriggersCache = setPhaseSparkTriggersCache,
	setSparkLoadingStatus = setSparkLoadingStatus,
	getSparkLoadingStatus = getSparkLoadingStatus,
	removeTriggerFromPhaseDataByMapAndIndex = removeTriggerFromPhaseDataByMapAndIndex,
	sendPhaseSparkIOLock = sendPhaseSparkIOLock,
	savePopupTriggersToPhaseData = savePopupTriggersToPhaseData,
	triggerSparkCooldownVisual = triggerSparkCooldownVisual,
	triggerMultiSparkCooldown = triggerMultiSparkCooldown,

	setSparkKeybind = setSparkKeybind,
	getSparkKeybind = getSparkKeybind,
	setSparkDefaultKeybind = setSparkDefaultKeybind,

	genSparkCDNameOverride = genSparkCDNameOverride,

	setSparkThrottle = setThrottle,
	getSparkThrottle = getThrottle,

	checkSparksWithPredicate = checkSparksWithPredicate,
}
