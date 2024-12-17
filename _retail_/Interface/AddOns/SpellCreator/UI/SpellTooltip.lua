---@class ns
local ns = select(2, ...)

local Constants = ns.Constants
local Icons = ns.UI.Icons
local ASSETS_PATH = Constants.ASSETS_PATH
local Tooltip = ns.Utils.Tooltip

local tinsert = tinsert

local secondsToMinuteSecondString = ns.Utils.Data.secondsToMinuteSecondString

local goldText = function(text) return Constants.ADDON_COLORS.GAME_GOLD:WrapTextInColorCode(text) end
local whiteText = function(text) return WrapTextInColorCode(text, "FFFFFFFF") end

---@class ContextTypeData
---@field showActionCount boolean
---@field showDescription boolean
---@field showIconInName  boolean
---@field colorCodeName  boolean
---@field showProfile  boolean
---@field showArcID boolean
---@field showAuthor  boolean
---@field showItemsLinked  boolean
---@field showHotkey boolean
---@field showCastTime boolean

---@alias ArcSpellTooltipContext
---| 'default' [# description]
---| 'actionbar' [# description]
---| 'spark' [# description]
---| 'vault' [# description]

---@type { [ArcSpellTooltipContext]: ContextTypeData }
local tooltipContext = {
	default = {
		showActionCount = true,
		showDescription = true,
		showIconInName = false,
		colorCodeName = false,
		showProfile = false,
		showArcID = true,
		showAuthor = false,
		showItemsLinked = false,
		showHotkey = true,
		showCastTime = false,
	},
	actionbar = {
		showActionCount = false,
		showDescription = true,
		showIconInName = false,
		colorCodeName = true,
		showProfile = false,
		showArcID = true,
		showAuthor = false,
		showItemsLinked = false,
		showHotkey = false,
		showCastTime = true,
	},
	spark = {
		showActionCount = false,
		showDescription = true,
		showIconInName = false,
		colorCodeName = true,
		showProfile = false,
		showArcID = false,
		showAuthor = false,
		showItemsLinked = false,
		showHotkey = false,
		showCastTime = true,
	},
	vault = {
		showActionCount = true,
		showDescription = true,
		showIconInName = false,
		colorCodeName = true,
		showProfile = true,
		showArcID = true,
		showAuthor = true,
		showItemsLinked = true,
		showHotkey = true,
		showCastTime = false,
	},
}

---Get a pre-made table with lines for an ArcSpell tooltip.
---@param context ArcSpellTooltipContext|ContextTypeData
---@param spell VaultSpell|CommID
---@param isPhase boolean?
---@param noName boolean?
---@param spark frame? Spark Frame, if this came from a Spark; used for CD Override
---@return table?
local function getSpellTooltipLines(context, spell, isPhase, noName, spark)
	if type(spell) == "string" then
		-- is a commID, convert
		local commID = spell
		spell = ns.Vault[isPhase and "phase" or "personal"].findSpellByID(commID)
	end

	local contextData
	if type(context) == "table" then
		contextData = context -- custom defined context table
	else
		contextData = tooltipContext[context] or tooltipContext["default"]
	end

	if not spell then return end
	local commID = spell.commID
	local lines = {}

	-- Name Line:
	if not noName then
		local spellName = spell.fullName
		if contextData.colorCodeName then spellName = Constants.ADDON_COLORS.ADDON_COLOR:WrapTextInColorCode(spellName) end
		if contextData.showIconInName then
			spellName = CreateTextureMarkup(Icons.getFinalIcon(spell.icon), 24, 24, 24, 24, 0, 1, 0, 1) .. " " .. spellName
		end
		tinsert(lines, spellName)
	end

	-- Actions & Cooldown Line:
	local actionCountString, cooldownString = " ", " "
	if contextData.showActionCount then
		actionCountString = "Actions: " .. #spell.actions
	end

	local cooldownTime = spell.cooldown
	if spark then
		if spark.cdData[1] then
			local sparkCdTime = tonumber(spark.cdData[1])
			if spark.cdData[2] then
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
		if spark.isMulti then
			commID = "(multispark)"
		end
	end

	if cooldownTime then
		cooldownString = whiteText(("Cooldown: %s"):format(secondsToMinuteSecondString(cooldownTime)))
	end

	local castTimeString
	if contextData.showCastTime then
		local spellDuration = ns.Utils.SpellUtils.GetDuration(spell)
		if (not spellDuration) or (spellDuration < 0.25) then
			castTimeString = "Instant"
		else
			castTimeString = (secondsToMinuteSecondString(spellDuration):gsub("s", " sec"):gsub("m", " min")) .. " cast"
		end
	end

	if ((castTimeString or actionCountString) ~= " ") or cooldownString ~= " " then -- Only add if one or the other is given
		tinsert(lines, Tooltip.createDoubleLine(castTimeString or actionCountString, cooldownString))
	end

	-- Cooldown Remaining Line:
	local cooldownRemaining = ns.Actions.Cooldowns.isSpellOnCooldown(spell.commID, isPhase)

	if spark then
		local cdData = spark.cdData
		local sparkCDNameOverride = ns.UI.SparkPopups.Init.genSparkCDNameOverride(commID, cdData.loc[1], cdData.loc[2], cdData.loc[3])
		local sparkCdTimeRemaining, sparkCdLength = ns.Actions.Cooldowns.isSparkOnCooldown(sparkCDNameOverride)

		if sparkCdTimeRemaining and sparkCdTimeRemaining > (cooldownRemaining or 0) then
			cooldownRemaining = sparkCdTimeRemaining
		end
	end

	if cooldownRemaining then
		local cooldownRemainingString = whiteText(("Cooldown remaining: %s"):format(secondsToMinuteSecondString(cooldownRemaining)))
		tinsert(lines, cooldownRemainingString)
	end

	-- Description Line:
	if contextData.showDescription and spell.description and (spell.description ~= "") then
		local desc = spell.description:gsub("||", "|"):gsub("|n", "\a")
		local descLines = { strsplit("\a", desc) }
		for _, v in ipairs(descLines) do
			tinsert(lines, goldText(v))
		end
		tinsert(lines, " ")
	end

	-- Profile Line:
	if contextData.showProfile then
		tinsert(lines, Tooltip.createDoubleLine("Profile: ", spell.profile))
	end

	-- Author Line:
	if contextData.showAuthor and spell.author then
		tinsert(lines, Tooltip.createDoubleLine("Author: ", spell.author))
	end

	-- Items Line:
	if contextData.showItemsLinked and spell.items and next(spell.items) then
		tinsert(lines, "Items: " .. table.concat(spell.items, ", "))
	end

	-- Hotkey Line:
	if contextData.showHotkey then
		local hotkeyKey = ns.Actions.Hotkeys.getHotkeyByCommID(spell.commID)
		if hotkeyKey then tinsert(lines, "Hotkey: " .. hotkeyKey) end
	end

	-- ArcID (CommID) Line:
	if contextData.showArcID then
		tinsert(lines, Tooltip.createDoubleLine(goldText("ArcSpell ID: "), whiteText(spell.commID)))
	end

	-- Remove blank last line if we left an orphaned one..
	if lines[#lines] == " " then
		lines[#lines] = nil
	end

	return lines
end

local function getSpellTooltipTitle(context, spell, isPhase)
	if type(spell) == "string" then
		-- is a commID, convert
		local commID = spell
		spell = ns.Vault[isPhase and "phase" or "personal"].findSpellByID(commID)
	end

	local contextData
	if type(context) == "table" then
		contextData = context -- custom defined context table
	else
		contextData = tooltipContext[context] or tooltipContext["default"]
	end

	if not spell then return end

	local spellName = spell.fullName
	if contextData.colorCodeName then spellName = Constants.ADDON_COLORS.ADDON_COLOR:WrapTextInColorCode(spellName) end
	if contextData.showIconInName then
		spellName = CreateTextureMarkup(Icons.getFinalIcon(spell.icon), 24, 24, 24, 24, 0, 1, 0, 1) .. spellName
	end

	return spellName
end

---@class UI_SpellTooltip
ns.UI.SpellTooltip = {
	getLines = getSpellTooltipLines,
	getTitle = getSpellTooltipTitle,
}
