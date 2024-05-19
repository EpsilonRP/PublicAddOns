---@class ns
local ns = select(2, ...)

-- Real Init

---@class UI_SparkPopups
---@field CreateSparkUI UI_SparkPopups_CreateSparkUI
---@field SparkManagerUI UI_SparkPopups_SparkManagerUI
---@field SparkPopups UI_SparkPopups_SparkPopups
---@field Init UI_SparkPopups_Init

ns.UI.SparkPopups = {}

-- Extra Stuff we needed pre-XML


local C_Epsilon                = C_Epsilon

local Animation                = ns.UI.Animation
local AceComm                  = ns.Libs.AceComm
local Comms                    = ns.Comms
local Constants                = ns.Constants
local Vault                    = ns.Vault
local Icons                    = ns.UI.Icons
local Logging                  = ns.Logging
local Permissions              = ns.Permissions
local serializer               = ns.Serializer
local Tooltip                  = ns.Utils.Tooltip
local SparkPopups              = ns.UI.SparkPopups

local AceConfigDialog          = ns.Libs.AceConfigDialog

local addonMsgPrefix           = Comms.PREFIX
local DataUtils                = ns.Utils.Data
local Debug                    = ns.Utils.Debug

local Cooldowns                = ns.Actions.Cooldowns

local isOfficerPlus            = Permissions.isOfficerPlus
local getDistanceBetweenPoints = DataUtils.getDistanceBetweenPoints

local ASSETS_PATH              = Constants.ASSETS_PATH
local SPARK_ASSETS_PATH        = ASSETS_PATH .. "/Sparks/"

local defaultSparkPopupStyle   = "Interface\\ExtraButton\\Default";

---@type table<number, SparkTriggerData[]>
local phaseSparkTriggers       = {}

local getPlayerPositionData    = C_Epsilon.GetPosition or function() return UnitPosition("player") end

local multiMessageData         = ns.Comms.multiMessageData
local MSG_MULTI_FIRST          = multiMessageData.MSG_MULTI_FIRST
local MSG_MULTI_NEXT           = multiMessageData.MSG_MULTI_NEXT
local MSG_MULTI_LAST           = multiMessageData.MSG_MULTI_LAST
local MAX_CHARS_PER_SEGMENT    = multiMessageData.MAX_CHARS_PER_SEGMENT

-- Helper Funcs

---Gets the Spark Spell CommID + X Y Z coords concat to it for a unique name to use for CDs
---@param commID CommID
---@param x number
---@param y number
---@param z number
---@return string
local function genSparkCDNameOverride(commID, x, y, z)
	--local sparkCDNameOverride = strjoin(string.char(31), commID, x, y, z)
	local sparkCDNameOverride = strjoin("+", commID, x, y, z)
	return sparkCDNameOverride
end

local function genMultiSparkCDNameOverride(x,y,z)
	return genSparkCDNameOverride("(multispark)", x, y, z)
end

---Checks if a Sparks' conditions are met
---@param sparkData SparkTriggerData
local function isSparkConditionsMet(sparkData)
	local v = sparkData
	local sparkOptions = v[8] --[[@as SparkTriggerDataOptions]]

	if not sparkOptions then return true end -- early exit if sparkOptions don't exist for some reason

	local shouldShowSpark = true
	if sparkOptions.conditions then
		shouldShowSpark = ns.Actions.Execute.checkConditions(sparkOptions.conditions)
	elseif sparkOptions.requirement then
		local script = sparkOptions.requirement
		if not script:match("return") then
			script = "return " .. script
		end
		if ns.Cmd.runMacroText(script) then
			shouldShowSpark = true
		end
	end

	return shouldShowSpark
end

---Generic Handler for sending a Spark On CD UI Message
---@param sparkOrSpellName string
---@param cdTimeRemaining number
---@param isSpell? boolean
local function sendSparkCDMessage(sparkOrSpellName, cdTimeRemaining, isSpell)
	cdTimeRemaining = ns.Utils.Data.roundToNthDecimal(cdTimeRemaining, 2) -- Round it so it's not obnoxious

	local cooldownMessage
	if isSpell then
		cooldownMessage = ("Spark's Spell (%s) is on Cooldown (%ss)."):format(sparkOrSpellName, cdTimeRemaining)
	else
		cooldownMessage = ("Spark (%s) is on cooldown (%ss)."):format(sparkOrSpellName, cdTimeRemaining)
	end

	UIErrorsFrame:AddMessage(cooldownMessage, Constants.ADDON_COLORS.ADDON_COLOR:GetRGBA())
	PlayVocalErrorSoundID(12);
end

---Checks if a Spark, or it's Spell, is on CD
---@param sparkData SparkTriggerData
local function isSparkOrSpellNotOnCD(sparkData)
	local v = sparkData
	local commID, sX, sY, sZ, sR, barTex, colorHex = v[1], v[2], v[3], v[4], v[5], v[6], v[7]

	-- Check if Spark on CD
	local sparkCDNameOverride = genSparkCDNameOverride(commID, sX, sY, sZ)
	local sparkCdTimeRemaining, sparkCdLength = Cooldowns.isSparkOnCooldown(sparkCDNameOverride)
	if sparkCdTimeRemaining then
		sendSparkCDMessage(sparkCDNameOverride, sparkCdTimeRemaining, false)
		return false
	end

	-- Check if Spell on CD
	local spellCdTimeRemaining, spellCdLength = Cooldowns.isSpellOnCooldown(commID, C_Epsilon.GetPhaseId())
	if spellCdTimeRemaining then
		sendSparkCDMessage(commID, spellCdTimeRemaining, true)
		return false
	end

	-- Neither were on CD
	return true
end


-- SparkFrame - SC_ExtraActionBarFrameTemplate - Mixin
SC_ExtraActionButtonMixin = {}

---Update a SparkButton's Cooldown forcefully (Checks for fresh CD Data & Updates it as needed)
---@param sparkData any
function SC_ExtraActionButtonMixin:UpdateCooldown(sparkData)
	local spell = self.spell
	if not spell then return end
	local commID = spell.commID
	if self.isMulti then commID = "(multispark)" end

	-- check if the spell is currently on cooldown so we can show the correct cooldown timer visual, or clear it if there's one running from another spell
	local cooldownTime, cooldownLength = Cooldowns.isSpellOnCooldown(spell.commID, C_Epsilon.GetPhaseId())

	local sparkCDNameOverride
	local remainingSparkCdTime, sparkCdLength
	if sparkData then
		sparkCDNameOverride = genSparkCDNameOverride(commID, sparkData[2], sparkData[3], sparkData[4])
		remainingSparkCdTime, sparkCdLength = Cooldowns.isSparkOnCooldown(sparkCDNameOverride)
	end

	if remainingSparkCdTime then
		if cooldownTime then
			if (remainingSparkCdTime > cooldownTime) then
				cooldownTime = remainingSparkCdTime
				cooldownLength = sparkCdLength
			end
		else
			cooldownTime = remainingSparkCdTime
			cooldownLength = sparkCdLength
		end
	end
	if cooldownTime then
		self.cooldown:SetCooldown(GetTime() - (cooldownLength - cooldownTime), cooldownLength)
	else
		self.cooldown:Clear()
	end
end

---Update an ExtraActionButton to show an ArcSpell
---@param spell VaultSpell
---@param sparkData SparkTriggerData
---@return boolean
function SC_ExtraActionButtonMixin:SetSpell(spell, sparkData)
	if not spell then return false end -- No Spell, wtf

	local icon = Icons.getFinalIcon(spell.icon)
	self.icon:SetTexture(icon)

	self.spell = spell

	-- spark cooldown overrides
	if sparkData then -- Assign CD Data as needed
		local sparkOptions = sparkData[8] or {} --[[@as SparkTriggerDataOptions]]
		local sparkCdTime, sparkCdTrigger, sparkCdBroadcast
		if sparkOptions then
			sparkCdTime, sparkCdTrigger, sparkCdBroadcast = sparkOptions.cooldownTime, sparkOptions.trigSpellCooldown, sparkOptions.broadcastCooldown
		end
		self.cdData = {
			sparkCdTime,
			sparkCdTrigger,
			sparkCdBroadcast,
			loc = { sparkData[2], sparkData[3], sparkData[4] },
			inputs = (sparkOptions.inputs or nil)
		}
	end

	return true
end

function SC_ExtraActionButtonMixin:SetSquare()
	local highlight = self.HighlightTexture
	highlight:SetTexture("Interface\\Buttons\\ButtonHilight-Square")
	--highlight:SetTexture(ASSETS_PATH .. "/dm-trait-select") -- didn't look very good being so thin / clean / bright.
	highlight:ClearAllPoints()
	highlight:SetAllPoints()

	self.cooldown:SetSwipeColor(0, 0, 0, 0.8)
	self.cooldown:SetUseCircularEdge(false)
	self.CircleMask:Hide()
end

function SC_ExtraActionButtonMixin:SetCircular()
	local highlight = self.HighlightTexture
	highlight:SetTexture(SPARK_ASSETS_PATH .. "CircleSparkFrameHighlight")
	highlight:ClearAllPoints()
	highlight:SetPoint("Center", 0, -1)
	highlight:SetSize(64, 64)

	self.cooldown:SetSwipeTexture(SPARK_ASSETS_PATH .. 'circular-mask-alpha')
	self.cooldown:SetUseCircularEdge(true)
	self.CircleMask:Show()
end

function SC_ExtraActionButtonMixin:SetContent(content)
	local spell = content.spell
	local sparkData = content.spark

	self.isMulti = true
	self:SetSpell(spell, sparkData)
	self:SetSquare()
end

function SC_ExtraActionButtonMixin:OnClick(button)
	local sparkPopup = self:GetParent()
	local cdData = self.cdData
	local spell = self.spell
	local commID = spell.commID
	if self.isMulti then commID = "(multispark)" end -- use this as your commID for sending CDs

	if self.SetChecked then self:SetChecked(false) end
	if (isOfficerPlus() or SpellCreatorMasterTable.Options["debug"]) and button == "RightButton" then

		if IsAltKeyDown() then
			local sparkCDNameOverride = genSparkCDNameOverride(commID, cdData.loc[1], cdData.loc[2], cdData.loc[3])
			ns.Actions.Data_Scripts.runScriptPriv("CopyToClipboard('" .. sparkCDNameOverride .. "')")
			Logging.cprint("Spark CD Name (Copied to Clipboard): ".. sparkCDNameOverride)
			return
		end
		SparkPopups.SparkManagerUI.showSparkManagerUI()
		return
	end
	if button == "keybind" and not sparkPopup:IsShown() then
		Logging.dprint("SparkPopups Keybind Pressed, but not shown so skipped.")
		return
	end
	if not spell then
		Logging.eprint("No spell found on the button. Report this.")
		return
	end

	--spark cooldown overrides
	local pseudoSparkData = { commID, cdData.loc[1], cdData.loc[2], cdData.loc[3] }

	if not isSparkOrSpellNotOnCD(pseudoSparkData) then return end -- Exit if spark & spell not not on CD (aka: On CD) -- Print CD messages are handled in the check

	local bypassCD = false
	if cdData[1] then
		local sparkCDNameOverride = genSparkCDNameOverride(commID, cdData.loc[1], cdData.loc[2], cdData.loc[3])
		Cooldowns.addSparkCooldown(sparkCDNameOverride, cdData[1], commID)
		bypassCD = true
		if cdData[2] then
			bypassCD = false
		end
		if cdData[3] then
			ns.Comms.sendSparkCooldown(sparkCDNameOverride, cdData[1])
			-- send something to the comms to trigger that cd on the phase.. ick..
		end
	end
	if cdData.inputs then
		ARC.PHASE:CAST(spell.commID, bypassCD, unpack(DataUtils.parseStringToArgs(cdData.inputs)))
	else
		ARC.PHASE:CAST(spell.commID, bypassCD)
	end
end

function SC_ExtraActionButtonMixin:OnLoad()
	Tooltip.set(self,
		function(self)
			return self.spell.fullName
		end,
		function(self)
			local spell = self.spell
			local strings = {}

			if spell.description then
				tinsert(strings, spell.description)
			end
			local cooldownTime
			if spell.cooldown then
				cooldownTime = spell.cooldown
			end
			if self.cdData[1] then
				local sparkCdTime = tonumber(self.cdData[1])
				if self.cdData[2] then
					if cooldownTime then
						if sparkCdTime > cooldownTime then
							cooldownTime = sparkCdTime
						end
					else
						cooldownTime = sparkCdTime
					end
				else
					cooldownTime = sparkCdTime
				end
			end
			if cooldownTime then
				tinsert(strings, Tooltip.createDoubleLine("Actions: " .. #spell.actions, "Cooldown: " .. cooldownTime .. "s"));
				if spell.author then
					tinsert(strings, Tooltip.createDoubleLine(" ", "Author: " .. spell.author));
				end
			else
				if spell.author then
					tinsert(strings, Tooltip.createDoubleLine("Actions: " .. #spell.actions, "Author: " .. spell.author));
				else
					tinsert(strings, "Actions: " .. #spell.actions)
				end
			end

			tinsert(strings, " ")
			tinsert(strings, "Click to cast " .. Tooltip.genContrastText(spell.commID) .. "!")

			if isOfficerPlus() then tinsert(strings, "Right-Click to Open " .. Tooltip.genContrastText("Sparks Manager")) end

			return strings
		end,
		{ delay = 0 }
	)
end

---@class UI_SparkPopups_Init
ns.UI.SparkPopups.Init = {
	isSparkConditionsMet = isSparkConditionsMet,
	isSparkOrSpellNotOnCD = isSparkOrSpellNotOnCD,
	genSparkCDNameOverride = genSparkCDNameOverride,
	genMultiSparkCDNameOverride = genMultiSparkCDNameOverride,
}
