---@class ns
local ns = select(2, ...)
local addonName = ...

local Cmd = ns.Cmd
local Constants = ns.Constants
local Execute = ns.Actions.Execute
local Vault = ns.Vault
local VAULT_TYPE = Constants.VAULT_TYPE
local Dropdown = ns.UI.Dropdown
local HTML = ns.Utils.HTML
local phaseVault = Vault.phase
local Logging = ns.Logging

local serializer = ns.Serializer


local Libs = ns.Libs
local AceConfig = Libs.AceConfig
local AceConfigDialog = Libs.AceConfigDialog

local cprint, dprint, eprint = Logging.cprint, Logging.dprint, Logging.eprint
local cmdWithDotCheck = Cmd.cmdWithDotCheck
local cmd = Cmd.cmd
local runMacroText = Cmd.runMacroText
local executePhaseSpell = Execute.executePhaseSpell

local tContains = tContains
local tDeleteItem = tDeleteItem
local tWipe = table.wipe

local match = string.match
local strsplit = strsplit
local strtrim = strtrim
local find = string.find
local next = next

local useGreenColor = CreateColor(0, 1, 0)

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
--#region ArcSpell <-> Item System - Direct Links Management
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

local itemsWithSpellsCache = {
	[19222] = { phase = { "someSpell" }, personal = { "drunk" } } -- example default, gets overwritten when updateCache is called.
}

---@param itemID number
---@param spellCommID CommID
---@param vaultType VaultType
---@param refreshUI boolean?
local function addItemSpellLink(itemID, spellCommID, vaultType, refreshUI)
	vaultType = string.lower(vaultType)
	if not itemsWithSpellsCache[itemID] then
		itemsWithSpellsCache[itemID] = { phase = {}, personal = {} }
	end
	tinsert(itemsWithSpellsCache[itemID][vaultType], spellCommID)
	if refreshUI and SCForgeLoadFrame:IsShown() then
		ns.MainFuncs.updateSpellLoadRows(true)
	end
end

local function deleteItemLink(itemID)
	itemsWithSpellsCache[itemID] = nil
end

local function deleteSpellFromItem(itemID, spellCommID, vaultType, refreshUI)
	vaultType = string.lower(vaultType)
	if not itemsWithSpellsCache[itemID] then return end

	if itemsWithSpellsCache[itemID] and itemsWithSpellsCache[itemID][vaultType] then
		tDeleteItem(itemsWithSpellsCache[itemID][vaultType], spellCommID)
	end

	if not next(itemsWithSpellsCache[itemID].phase) and not next(itemsWithSpellsCache[itemID].personal) then
		deleteItemLink(itemID) -- all spells removed, delete the connection
	end

	if refreshUI and SCForgeLoadFrame:IsShown() then
		ns.MainFuncs.updateSpellLoadRows(true)
	end
end

---@param vaultType VaultType
---@return table
local function getSpellsWithItemLinks(vaultType)
	vaultType = string.lower(vaultType)
	local spellsWithItems = {}
	for k, spell in pairs(Vault[vaultType].getSpells()) do
		if spell.items then
			tinsert(spellsWithItems, spell)
		end
	end
	return spellsWithItems
end

---@param refreshUI boolean? should the UI need refreshed
local function updateCache(refreshUI)
	tWipe(itemsWithSpellsCache)
	local vaults = { Constants.VAULT_TYPE.PERSONAL, Constants.VAULT_TYPE.PHASE }
	for k, vaultType in ipairs(vaults) do
		local spellsWithItems = getSpellsWithItemLinks(vaultType)
		for i, spell in ipairs(spellsWithItems) do
			for _, item in ipairs(spell.items) do
				addItemSpellLink(item, spell.commID, vaultType, refreshUI)
			end
		end
	end
end

---@param spell VaultSpell
---@param itemID integer
---@param vaultType VaultType
---@param refreshUI boolean?
---@return boolean success
local function safeAddItemToSpell(spell, itemID, vaultType, refreshUI)
	if not spell.items then spell.items = {} end
	itemID = tonumber(itemID)
	if not itemID then ns.Logging.uiErrorMessage("Invalid Item. Could not link Item & ArcSpell.", Constants.ADDON_COLORS.TOOLTIP_WARNINGRED:GetRGB()) end
	if tContains(spell.items, itemID) then
		ns.Logging.uiErrorMessage("This ArcSpell is already connected to this item (" .. itemID .. ").", Constants.ADDON_COLORS.ADDON_COLOR:GetRGB())
		return false
	end
	tinsert(spell.items, itemID)
	addItemSpellLink(itemID, spell.commID, vaultType, refreshUI)
	return true
end

---@param spell VaultSpell
---@param itemID integer|number
---@param vaultType VaultType
---@param refreshUI boolean?
---@return boolean success
local function safeRemoveItemFromSpell(spell, itemID, vaultType, refreshUI)
	if not spell.items then return false end
	itemID = tonumber(itemID)
	if not itemID then ns.Logging.uiErrorMessage("Invalid Item. Could not remove Item connection from ArcSpell.", Constants.ADDON_COLORS.TOOLTIP_WARNINGRED:GetRGB()) end

	if tContains(spell.items, itemID) then
		tDeleteItem(spell.items, itemID)
		if not next(spell.items) then
			spell.items = nil -- remove the table, save some space
		end
		deleteSpellFromItem(itemID, spell.commID, vaultType, refreshUI)
		return true
	end
	return false
end

--#endregion

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
--#region Item Description Hooking
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

local itemTag_ExtTags = {

	---@param payload itemTag_ScriptPayload
	del = function(payload)
		cmd("additem " .. payload.itemID .. " -1")
	end,
}

---@param payload itemTag_ScriptPayload
local function runExtensionChecks(payload)
	if not payload.extTags then return end
	for k, v in pairs(itemTag_ExtTags) do
		if payload.extTags:match(k) then
			v(payload)
		end
	end
end

local itemTag_Scripts = {

	---@param payload itemTag_ScriptPayload
	personal_cast = function(payload)
		if ARC:CAST(payload.arg) then
			runExtensionChecks(payload)
		end
	end,

	---@param payload itemTag_ScriptPayload
	phase_cast = function(payload)
		-- TODO : Reimplement Auto-Cast upon Phase Vault Loaded? See Gossip System for Reference.
		if phaseVault.isSavingOrLoadingAddonData then
			eprint("Phase Vault was still loading. Please try again in a moment."); return;
		end
		if executePhaseSpell(payload.arg) then
			runExtensionChecks(payload)
		end
	end,

	---@param payload itemTag_ScriptPayload
	save = function(payload)
		if phaseVault.isSavingOrLoadingAddonData then
			eprint("Phase Vault was still loading. Please try again in a moment."); return;
		end
		dprint("Scanning Phase Vault for Spell to Save: " .. payload.arg)

		local index = Vault.phase.findSpellIndexByID(payload.arg)
		if index ~= nil then
			dprint("Found & Saving Spell '" .. payload.arg .. "' (" .. index .. ") to your Personal Vault.")
			ns.MainFuncs.downloadToPersonal(index, true, function() runExtensionChecks(payload) end)
		end
	end,

	---@param payload itemTag_ScriptPayload
	copy = function(payload)
		ARC:COPY(payload.arg)
		runExtensionChecks(payload)
	end,

	---@param payload itemTag_ScriptPayload
	cmd = function(payload)
		cmdWithDotCheck(payload.arg)
		runExtensionChecks(payload)
	end,

	---@param payload itemTag_ScriptPayload
	macro = function(payload)
		runMacroText(payload.arg)
		runExtensionChecks(payload)
	end,

	togaura = function(payload)
		if not tonumber(payload.arg) then return end
		ns.Utils.Aura.toggleAura(tonumber(payload.arg))
		runExtensionChecks(payload)
	end,

	---@param payload itemTag_ScriptPayload
	food = function(payload)
		cmd("cast 168117")

		-- Force add _del extension tag, then run extension checks - if it's there twice, it still only gets ran once anyways.
		if not payload.extTags then
			payload.extTags = ""
		end
		payload.extTags = payload.extTags .. "_del"
		runExtensionChecks(payload)
	end,

	---@param payload itemTag_ScriptPayload
	drink = function(payload)
		cmd("cast 263434")

		-- Force add _del extension tag, then run extension checks - if it's there twice, it still only gets ran once anyways.
		if not payload.extTags then
			payload.extTags = ""
		end
		payload.extTags = payload.extTags .. "_del"
		runExtensionChecks(payload)
	end,

	---@param payload itemTag_ScriptPayload
	generic_consume = function(payload)
		cmd("cast 165290")

		-- Force add _del extension tag, then run extension checks - if it's there twice, it still only gets ran once anyways.
		if not payload.extTags then
			payload.extTags = ""
		end
		payload.extTags = payload.extTags .. "_del"
		runExtensionChecks(payload)
	end,

	remote_cast = function(payload)
		local phaseId, commId = strsplit(":", payload.arg, 2)
		assert(phaseId and commId, "Invalid remote_cast tag, must be in format <arc_rcast:phaseID:arcSpellID>")

		local keyFormatBase = "SCFORGE_S%s_"
		EpsilonLib.PhaseAddonData.Get({
			key = keyFormatBase .. commId,
			callback = function(data)
				if data and data ~= "" then
					local loaded, spell = pcall(serializer.decompressForAddonMsg, data)
					if not loaded then
						eprint(("Failed to load ArcSpell (%s) from phase %s."):format(commId, phaseId))
						return
					else
						-- Migrate Spell on load if needed
						ns.Actions.Migrations.migrateSpell(spell, false)
					end


					local itemName, itemLink, itemQuality, _, _, _, _, _, _, itemTexture = GetItemInfo(payload.itemID)
					if ns.Actions.Execute.executeSpell(spell.actions, nil, spell.fullName, spell, payload.itemID, itemName, itemLink, "|T" .. itemTexture .. ":0|t") then
						runExtensionChecks(payload)
					end
				else
					eprint(("Could not find ArcSpell (%s) in phase %s."):format(commId, phaseId))
				end
			end,
			phaseId = tonumber(phaseId)
		})
	end,

	tele = function(payLoad)
		local loc, visual = strsplit(":", payLoad, 2)
		CloseGossip() -- Teleports have a forced close always
		ns.Actions.Data_Scripts.tele.port("tele " .. loc, visual)
	end,

	ptele = function(payLoad)
		local loc, visual = strsplit(":", payLoad, 2)
		CloseGossip() -- Teleports have a forced close always
		ns.Actions.Data_Scripts.tele.port("phase tele " .. loc, visual)
	end,

	phase = function(payLoad)
		local phase, loc, visual = strsplit(":", payLoad, 3)
		phase = tonumber(phase)
		if not phase then
			eprint("Invalid Phase ID given for phase enter: " .. tostring(payLoad)); return;
		end

		if not visual and tonumber(loc) then
			-- if no visual, but loc is a number, it's probably the visual; shift values
			visual = loc
			loc = nil
		end

		local command
		if tonumber(C_Epsilon.GetPhaseId()) == phase then
			-- already in phase, do phase tele
			command = ("phase tele %s"):format(loc)
		else
			-- not in phase, do enter + tele
			command = ("phase enter %s %s"):format(phase, loc)
		end

		CloseGossip() -- Teleports have a forced close always
		ns.Actions.Data_Scripts.tele.port(command, visual)
	end,
}

local itemTag_Tags = {
	default = "%s?<arc[anum]-_.->",
	capture = "<arc[anum]-_(.-)>",
	preview = " <arc::",
	option = {
		cmd = { script = itemTag_Scripts.cmd },
		macro = { script = itemTag_Scripts.macro },
		cast = { script = itemTag_Scripts.personal_cast },
		pcast = { script = itemTag_Scripts.phase_cast },
		--rcast = { script = itemTag_Scripts.remote_cast },
		save = { script = itemTag_Scripts.save },
		copy = { script = itemTag_Scripts.copy },
		eat = { script = itemTag_Scripts.food },
		drink = { script = itemTag_Scripts.drink },
		consume = { script = itemTag_Scripts.generic_consume },
		togaura = { script = itemTag_Scripts.togaura },
		tele = { script = itemTag_Scripts.tele },
		ptele = { script = itemTag_Scripts.ptele },
		phase = { script = itemTag_Scripts.phase },
	},
}


local function ensureTablePath(table, ...)
	if not table then error("Your table must exist first, counter-productively..") end
	for k, v in ipairs({ ... }) do
		if not table[v] then table[v] = {} end
		table = table[v]
	end

	return table
end

local itemDescARC_Cache = {}
local onUseLines = {}

---@param itemID integer|number
---@param fontStringObject FontString
local function testAndReplaceArcLinks(itemID, fontStringObject)
	itemID = tonumber(itemID)
	if not itemID then return end  -- // So LuaLS stops yelling at me
	if itemDescARC_Cache[itemID] then -- reset our cache for that item
		tWipe(itemDescARC_Cache[itemID]) -- already existed, reuse the table
	else
		itemDescARC_Cache[itemID] = {}
	end

	tWipe(ensureTablePath(onUseLines, itemID))
	local thisItemLines = onUseLines[itemID]

	local description = fontStringObject:GetText()
	if description and description ~= "" then
		-- remove the trailing " for now, we will add it back at the end
		description = description:sub(1, -2)

		while description and description:match(itemTag_Tags.default) do
			local itemDescPayload = description:match(itemTag_Tags.capture) -- capture the tag
			local strTag, strArg = strsplit(":", itemDescPayload, 2) -- split the tag from the data
			local mainTag, extTags = strsplit("_", strTag, 2)      -- split the main tag from the extension tags

			---@class itemTag_ScriptPayload
			---@field arg string the arg passed
			---@field itemID integer the item ID used
			---@field extTags string the extension tags
			local payload = {
				arg = strArg,
				itemID = itemID,
				extTags = extTags,
			}

			if itemTag_Tags.option[mainTag] then -- Checking Main Tags & Adding to our item-use cache
				tinsert(itemDescARC_Cache[itemID], function()
					itemTag_Tags.option[mainTag].script(payload)
					dprint("Item Desc Hook clicked for Item " .. itemID .. ": <" .. mainTag .. ":" .. (strArg or "") .. ">")
				end)
			end

			-- If Shift or Control is down, we should KEEP the tag, for transparency sake to players
			local tagOverride = ""
			if (IsShiftKeyDown() or IsControlKeyDown()) then
				tagOverride = Constants.ADDON_COLORS.ADDON_COLOR:WrapTextInColorCode(itemTag_Tags.preview .. itemDescPayload .. ">")
			end

			-- Let's have some fun here. Any text AFTER the tag will captured to show as a 'Use:' line instead.
			local tagStart, tagEnd = description:find(itemTag_Tags.default)

			local thisTagUseText = description:match(itemTag_Tags.default .. "([^<]*)") -- This is any description found after, OR BETWEEN tags. Basically, if someone is crazy and uses 2 arctags...
			local stringLength = #description

			if thisTagUseText then thisTagUseText = strtrim(thisTagUseText) end -- trim it just incase it's only a space or something..

			if (tagEnd == (stringLength - 1)) or (thisTagUseText == "") then
				-- The tag has nothing after it, so we cannot add Use: text, so default to old behavior (no fun tag..)
				description = description:gsub(itemTag_Tags.default, tagOverride, 1)
			else
				-- Create & Store the cool Use: tag, then remove it from the item description
				local useText = useGreenColor:WrapTextInColorCode("Use: " .. thisTagUseText .. " |T" .. ns.UI.Gems.gemPath("Prismatic") .. ":16|t" .. tagOverride)
				tinsert(thisItemLines, useText)                 -- Save the line for later use
				description = description:gsub(itemTag_Tags.default, "", 1) -- Just remove it
				if thisTagUseText and thisTagUseText ~= "" then
					-- Escape any Lua pattern magic characters in the user-provided text so we remove it literally
					local escaped = thisTagUseText:gsub("([%^%$%(%)%%%.%[%]%*%+%-%?])", "%%%1")
					description = description:gsub(escaped, "", 1) -- Also remove the description (literal match)
				end
			end

			fontStringObject:SetText(description);

			dprint("Saw an Item Desc Tag, Item: " .. itemID .. " | Tag: " .. mainTag .. " | Spell: " .. (strArg or "none"))
			description = fontStringObject:GetText()
		end

		description = strtrim(description) .. '"' -- add back the trailing "

		fontStringObject:SetText(description)
	end
end

-- hook setitem to override
-- done below in Tooltips region

--#endregion

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
--#region Item Use & Cooldown Handlers
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

---Trigger Item Integration Cooldowns
---@param itemID integer
local function triggerCooldowns(itemID)
	-- bag frames
	for i = 1, NUM_CONTAINER_FRAMES do
		local containerFrame = _G["ContainerFrame" .. i]
		if containerFrame:IsShown() then
			ContainerFrame_UpdateCooldowns(containerFrame)
		end
	end

	-- action bars
	for k, frame in pairs(ActionBarButtonEventsFrame.frames) do
		--ActionButton_Update(frame);
		frame:Update()
	end
end

-- Handler for checking & casting spells if connected
local function tryArcSpellsFromItem(itemID)
	if not itemID then return end -- shouldnt be possible but someone got it somehow...
	local itemName, itemLink, itemQuality, _, _, _, _, _, _, itemTexture = GetItemInfo(itemID)

	local didCast = false
	local itemFromCache = itemsWithSpellsCache[itemID]
	if itemFromCache then
		if itemFromCache.phase then
			for k, commID in ipairs(itemFromCache.phase) do
				ARC.PHASE:CAST(commID, nil, itemID, itemName, itemLink, "|T" .. itemTexture .. ":0|t")
				didCast = true
			end
		end
		if itemFromCache.personal then
			for k, commID in ipairs(itemFromCache.personal) do
				if not tContains(itemFromCache.phase, commID) then -- Skip if exists in both Phase & Personal, Prioritize Phase
					ARC:CAST(commID, itemID, itemName, itemLink, "|T" .. itemTexture .. ":0|t")
					didCast = true
				end
			end
		end
	end
	if itemDescARC_Cache[itemID] then
		for k, script in ipairs(itemDescARC_Cache[itemID]) do
			if type(script) == "function" then
				script()
				didCast = true
			end
		end
	end
	if didCast then triggerCooldowns(itemID) end
	return didCast
end

--#region Hooking Item Use Functions
local itemUseHooks = {
	["UseContainerItem"] = function(bagID, slot)
		local icon, itemCount, _, _, _, _, itemLink, _, _, itemID, _ = GetContainerItemInfo(bagID, slot)
		if IsEquippableItem(itemID) then return end
		tryArcSpellsFromItem(itemID)
	end,
	["UseInventoryItem"] = function(slot)
		local itemID = GetInventoryItemID("player", slot)
		tryArcSpellsFromItem(itemID)
	end,
	["UseItemByName"] = function()

	end,
	["UseAction"] = function(action, unit, button)
		if IsUsableAction(action) then -- this must be true for us to continue - this filters items we no longer have in inventory / can't use
			local actionType, itemID = GetActionInfo(action)
			if actionType == "item" then
				tryArcSpellsFromItem(itemID)
			end
		end
	end,
	["ContainerFrame_UpdateCooldown"] = function(container, button)
		local itemID = GetContainerItemID(container, button:GetID());
		local itemFromCache = itemsWithSpellsCache[itemID]
		local cdRemaining, cdDuration = 0, 0
		if itemFromCache then
			if itemFromCache.phase then
				for k, commID in ipairs(itemFromCache.phase) do
					local _cdRemaining, _cdDuration = ns.Actions.Cooldowns.isSpellOnCooldown(commID, C_Epsilon.GetPhaseId())
					if _cdRemaining and _cdRemaining > cdRemaining then
						cdRemaining, cdDuration = _cdRemaining, _cdDuration
					end
				end
			end
			if itemFromCache.personal then
				for k, commID in ipairs(itemFromCache.personal) do
					local _cdRemaining, _cdDuration = ns.Actions.Cooldowns.isSpellOnCooldown(commID)
					if _cdRemaining and _cdRemaining > cdRemaining then
						cdRemaining, cdDuration = _cdRemaining, _cdDuration
					end
				end
			end
		end

		local enable
		if cdRemaining > 0 then
			enable = true
		end
		local cooldown = _G[button:GetName() .. "Cooldown"];
		if not button.ArcCooldown then
			button.ArcCooldown = CreateFrame("Cooldown", nil, button, "CooldownFrameTemplate")
			button.ArcCooldown:SetSwipeTexture("", 0.35, 0.0, 0.55, 0.8)
			button.ArcCooldown:SetSwipeColor(0.45, 0.0, 0.55, 0.8)
		end
		CooldownFrame_Set(button.ArcCooldown, GetTime() - (cdDuration - cdRemaining), cdDuration, enable);
		if (cdRemaining > 0 and enable == 0) then
			SetItemButtonTextureVertexColor(button, 0.4, 0.4, 0.4);
		else
			SetItemButtonTextureVertexColor(button, 1, 1, 1);
		end
	end,
	["ActionButton_UpdateCooldown"] = function(self)
		--return if it's simply a flyout button
		if self.GetPagedID == nil then
			return
		end

		--local actionID = ActionButton_GetPagedID(self)
		local actionID = self:GetPagedID()
		--local actionID = ActionButton_CalculateAction(self)
		local actionType, itemID = GetActionInfo(actionID)

		if actionType == "item" then
			local itemFromCache = itemsWithSpellsCache[itemID]
			local cdRemaining, cdDuration = 0, 0
			if itemFromCache then
				if itemFromCache.phase then
					for k, commID in ipairs(itemFromCache.phase) do
						local _cdRemaining, _cdDuration = ns.Actions.Cooldowns.isSpellOnCooldown(commID, C_Epsilon.GetPhaseId())
						if _cdRemaining and _cdRemaining > cdRemaining then
							cdRemaining, cdDuration = _cdRemaining, _cdDuration
						end
					end
				end
				if itemFromCache.personal then
					for k, commID in ipairs(itemFromCache.personal) do
						local _cdRemaining, _cdDuration = ns.Actions.Cooldowns.isSpellOnCooldown(commID)
						if _cdRemaining and _cdRemaining > cdRemaining then
							cdRemaining, cdDuration = _cdRemaining, _cdDuration
						end
					end
				end
			end

			local enable
			if cdRemaining > 0 then
				enable = true
			end
			if not self.ArcCooldown then
				self.ArcCooldown = CreateFrame("Cooldown", nil, self, "CooldownFrameTemplate")
				self.ArcCooldown:SetSwipeTexture("", 0.35, 0.0, 0.55, 0.8)
				self.ArcCooldown:SetSwipeColor(0.45, 0.0, 0.55, 0.8)
			end
			CooldownFrame_Set(self.ArcCooldown, GetTime() - (cdDuration - cdRemaining), cdDuration, enable);
		end
	end,
}

for k, v in pairs(itemUseHooks) do
	hooksecurefunc(k, v)
end

--#endregion

local sourceTagOverride = Constants.ADDON_COLORS.ADDON_COLOR:WrapTextInColorCode("%s: %s")
local gemTagFormat = "|T%s:16|t"
local gemTagViolet = gemTagFormat:format(ns.UI.Gems.gemPath("Violet"))
local gemTagBlue = gemTagFormat:format(ns.UI.Gems.gemPath("Blue"))

local function getSpellUseText(spellData, isPhase, showSource)
	if not spellData then return end
	local spellDesc = ns.Utils.SpellUtils.GetDescriptionForUI(spellData)
	local gemTag = isPhase and gemTagBlue or gemTagViolet
	local sourceText = (sourceTagOverride):format(isPhase and "Cast (Phase)" or "Cast (Personal)", spellData.fullName)

	if not spellDesc or spellDesc == "" then
		return ("Use: %s %s"):format(gemTag, sourceText)
	end

	return ("Use: %s %s %s"):format(spellDesc, gemTag, showSource and sourceText or "")
end

--#region Hooking Tooltips

local function GameTooltip_OnTooltipSetItem(tooltip)
	local _, link = tooltip:GetItem()
	if not link then return; end

	local itemString = match(link, "item[%-?%d:]+")
	local _, itemId = strsplit(":", itemString)

	--From idTip: http://www.wowinterface.com/downloads/info17033-idTip.html
	if itemId == "0" and TradeSkillFrame ~= nil and TradeSkillFrame:IsVisible() then
		if (GetMouseFocus():GetName()) == "TradeSkillSkillIcon" then
			itemId = GetTradeSkillItemLink(TradeSkillFrame.selectedSkill):match("item:(%d+):") or nil
		else
			for i = 1, 8 do
				if (GetMouseFocus():GetName()) == "TradeSkillReagent" .. i then
					itemId = GetTradeSkillReagentItemLink(TradeSkillFrame.selectedSkill, i):match("item:(%d+):") or nil
					break
				end
			end
		end
	end

	itemId = tonumber(itemId) -- make it  a number instead of string

	-- Store all text and text colours of the original tooltip lines.
	local leftText = {}
	local leftTextR = {}
	local leftTextG = {}
	local leftTextB = {}

	local rightText = {}
	local rightTextR = {}
	local rightTextG = {}
	local rightTextB = {}

	-- Store the number of lines for after ClearLines().
	local numLines = tooltip:NumLines()

	-- Store all lines of the original tooltip.
	local offset = 0;
	for i = 1, numLines, 1 do
		-- handle ArcTags first
		local left = _G[tooltip:GetName() .. "TextLeft" .. i]
		local lText = left:GetText()
		if lText:find("<arc") then
			testAndReplaceArcLinks(itemId, left)
			rightText[1] = Constants.ADDON_COLORS.ADDON_COLOR:WrapTextInColorCode("ArcCast") -- Add ArcCast tag to line 1 right, aka item name
		end

		-- Store line
		leftText[i] = left:GetText()
		leftTextR[i], leftTextG[i], leftTextB[i] = left:GetTextColor()

		local right = _G[tooltip:GetName() .. "TextRight" .. i]
		rightText[i] = right:GetText()
		rightTextR[i], rightTextG[i], rightTextB[i] = right:GetTextColor()

		if leftText[i]:match("ItemID") then
			offset = 2;
		end
	end

	local showSource = IsShiftKeyDown() or IsControlKeyDown()
	-- Add ArcSpell descriptions to Use: text.
	if itemId and (itemsWithSpellsCache[tonumber(itemId)] or onUseLines[tonumber(itemId)]) then
		tooltip:ClearLines()
		local greenText;
		local missingCommIDs = ""
		local data = itemsWithSpellsCache[tonumber(itemId)]
		if data and next(data.personal) then
			local spells, numSpells = "", 0
			local spellDesc
			for k, commID in ipairs(data.personal) do
				if not tContains(data.phase, commID) then -- Skip if it exists in both Phase & Personal, Prioritize Phase
					local spellData = ns.Vault.personal.findSpellByID(commID)
					if spellData then
						if spellDesc then
							spellDesc = spellDesc .. "\n" .. getSpellUseText(spellData, false, showSource)
						else
							spellDesc = getSpellUseText(spellData, false, showSource)
						end
						numSpells = numSpells + 1
					else
						missingCommIDs = missingCommIDs .. commID .. ", "
					end
				end
			end
			greenText = spellDesc
		end
		if data and next(data.phase) then
			local spells, numSpells = "", 0
			local spellDesc
			for k, commID in ipairs(data.phase) do
				local spellData = ns.Vault.phase.findSpellByID(commID)
				if spellData then
					if spellDesc then
						spellDesc = spellDesc .. "\n" .. getSpellUseText(spellData, true, showSource)
					else
						spellDesc = getSpellUseText(spellData, true, showSource)
					end
					numSpells = numSpells + 1
				else
					missingCommIDs = missingCommIDs .. commID .. (" (P)") .. ", "
				end
			end
			greenText = (greenText and (greenText .. "\n") or "") .. spellDesc
		end

		-- Refill the tooltip with the stored lines plus our added lines.
		local found;
		for i = 1, numLines do
			if rightText[i] then
				tooltip:AddDoubleLine(leftText[i], rightText[i], leftTextR[i], leftTextG[i], leftTextB[i], rightTextR[i], rightTextG[i], rightTextB[i])
			else
				-- TODO: Unfortunately I do not know how to store the "indented word wrap".
				--       Therefore, we have to put wrap=true for all lines in the new tooltip.
				if not (found) and (leftText[i]:find("^Use:") or leftText[i]:find("^Equip:") or leftText[i]:match("[\"].-[\"]") or leftText[i]:find("^Requires") or leftText[i]:find("^Durability") or leftText[i]:match("ItemID")) then
					found = true;
					if onUseLines[itemId] then
						for k, v in ipairs(onUseLines[itemId]) do
							tooltip:AddLine(v, 0, 1, 0, true)
						end
					end
					tooltip:AddLine(greenText, 0, 1, 0, true)
				end

				if leftText[i] ~= [[""]] and leftText[i] ~= "" and (not leftText[i]:match('^"%s*"$')) then -- force skip blank description lines if there was one.
					tooltip:AddLine(leftText[i], leftTextR[i], leftTextG[i], leftTextB[i], true)
				end

				if not (found) and i == (numLines - offset) then
					if onUseLines[itemId] then
						for k, v in ipairs(onUseLines[itemId]) do
							tooltip:AddLine(v, 0, 1, 0, true)
						end
					end
					tooltip:AddLine(greenText, 0, 1, 0, true)
				end
			end
		end

		if missingCommIDs ~= "" then
			missingCommIDs = strtrim(missingCommIDs, " ,")
			tooltip:AddLine(Constants.ADDON_COLORS.TOOLTIP_WARNINGRED:WrapTextInColorCode("The following ArcSpells are missing and could not be loaded:"), nil, nil, nil, true)
			tooltip:AddLine(Constants.ADDON_COLORS.TOOLTIP_WARNINGRED:WrapTextInColorCode(missingCommIDs), nil, nil, nil, true)
		end
	end

	tooltip:Show() -- refreshes the tooltip layout
end


GameTooltip:HookScript("OnTooltipSetItem", GameTooltip_OnTooltipSetItem)
ItemRefTooltip:HookScript("OnTooltipSetItem", GameTooltip_OnTooltipSetItem)

-- hooking ItemRefTooltip to listen for shift presses to preview the Arc Scripts

local SHIFT_KEY = "LSHIFT"
local CTRL_KEY = "LCTRL"
ItemRefTooltip:EnableKeyboard(true); ItemRefTooltip:SetPropagateKeyboardInput(true);
ItemRefTooltip:HookScript("OnKeyDown", function(self, key)
	self:SetPropagateKeyboardInput(key ~= SHIFT_KEY and key ~= CTRL_KEY)
	if key ~= SHIFT_KEY and key ~= CTRL_KEY then return end

	local _, link = self:GetItem()
	if not link then return; end

	local itemString = match(link, "item[%-?%d:]+")
	local _, itemID = strsplit(":", itemString)

	ItemRefTooltip:SetItemByID(itemID)
end)

ItemRefTooltip:SetScript("OnKeyUp", function(self, key)
	--if key ~= SHIFT_KEY then return end -- our propagate block stops any other keys but shift from firing OnKeyUp
	local _, link = self:GetItem()
	if not link then return; end

	local itemString = match(link, "item[%-?%d:]+")
	local _, itemID = strsplit(":", itemString)

	ItemRefTooltip:SetItemByID(itemID)
end)

--[[
hooksecurefunc("SetItemRef", function(link, ...)
	GameTooltip_OnTooltipSetItem(ItemRefTooltip)
end)
--]]

--#endregion

--#region Hooking Right-Click on Items with ALT pressed to show our custom context menu

local contextMenuLastItem = {}

local itemContextMenu_PhaseVaultDropdown = Libs.AceGUI:Create("Dropdown") --[[@as AceGUIDropdown]]
itemContextMenu_PhaseVaultDropdown:SetCallback("OnValueChanged", function(widget, callback, key, toggled)
	local spell = Vault.phase.getSpellByIndex(key)
	if not spell then error("Arc Error: No Spell with ArcSpell ID (" .. key .. ") found in the phase vault. How?") end
	if toggled then
		-- link item
		ns.Logging.cprint("Linking item " .. contextMenuLastItem.id .. " with Phase ArcSpell: " .. spell.commID)
		ns.UI.ItemIntegration.manageUI.ConnectItemAndSpell(nil, contextMenuLastItem.id, spell, true)
	else
		-- unlink item
		ns.Logging.cprint("Unlinking item " .. contextMenuLastItem.id .. " from Phase ArcSpell: " .. spell.commID)
		ns.UI.ItemIntegration.manageUI.DisconnectItemAndSpell(nil, contextMenuLastItem.id, spell, true)
	end
end)
itemContextMenu_PhaseVaultDropdown:SetWidth(200)
itemContextMenu_PhaseVaultDropdown:SetPoint("CENTER")
itemContextMenu_PhaseVaultDropdown:SetMultiselect(true)
itemContextMenu_PhaseVaultDropdown.frame:Hide()
Mixin(itemContextMenu_PhaseVaultDropdown.pullout.frame, UIDropDownCustomMenuEntryMixin)

local itemContextMenu_PersonalVaultDropdown = Libs.AceGUI:Create("Dropdown") --[[@as AceGUIDropdown]]
itemContextMenu_PersonalVaultDropdown:SetCallback("OnValueChanged", function(widget, callback, key, toggled)
	local spell = Vault.personal.findSpellByID(key)
	if not spell then error("Arc Error: No Spell with ArcSpell ID (" .. key .. ") found in the personal vault. How?") end
	if toggled then
		-- link item
		ns.Logging.cprint("Linking item " .. contextMenuLastItem.id .. " with Personal ArcSpell: " .. spell.commID)
		ns.UI.ItemIntegration.manageUI.ConnectItemAndSpell(nil, contextMenuLastItem.id, spell, false)
	else
		-- unlink item
		ns.Logging.cprint("Unlinking item " .. contextMenuLastItem.id .. " from Personal ArcSpell: " .. spell.commID)
		ns.UI.ItemIntegration.manageUI.DisconnectItemAndSpell(nil, contextMenuLastItem.id, spell, false)
	end
end)
itemContextMenu_PersonalVaultDropdown:SetWidth(200)
itemContextMenu_PersonalVaultDropdown:SetPoint("CENTER")
itemContextMenu_PersonalVaultDropdown:SetMultiselect(true)
itemContextMenu_PersonalVaultDropdown.frame:Hide()
Mixin(itemContextMenu_PersonalVaultDropdown.pullout.frame, UIDropDownCustomMenuEntryMixin)

---@param vaultType? string|VaultType
---@return table spellKVTable Spells Map by CommID = Spell Icon + Name + CommID String
---@return table spellSortTable Sorted Array of CommIDs
local function getSpellsForItemContext(vaultType)
	if not vaultType or not VAULT_TYPE[vaultType:upper()] then vaultType = 'personal' end
	vaultType = vaultType:lower()

	local spells = {}
	local sort = {}
	for commID, spell in pairs(Vault[vaultType].getSpells()) do
		local iconHeight = 16
		local icon = CreateTextureMarkup(ns.UI.Icons.getFinalIcon(spell.icon), 24, 24, iconHeight, iconHeight, 0, 1, 0, 1)
		spells[commID] = ("%s %s (%s)"):format(icon, spell.fullName, spell.commID)
		table.insert(sort, commID)
	end
	table.sort(sort)

	return spells, sort
end


--[[
-- // Disabled Forge stuff, doesn't make sense to include here tbh, especially since we don't know if they even 'own' this item in order to edit it.
local forgeCommands = {}

local function safeGetTablePath(table, ...)
	if not table then return false end

	local tableRef = table
	local keys = { ... }
	while #keys > 0 do
		local innerTable = tableRef[tremove(keys, 1)]
		if innerTable then
			tableRef = innerTable
		else
			-- that key was unavailable, break out
			return false
		end
	end
	return tableRef
end

local function getItemInfoByArgNum(id, num)
	if not id then id = contextMenuLastItem.id end
	return select(num, GetItemInfo(id))
end

local function _GetItemInfoWrapper(num)
	return function(self, id) return getItemInfoByArgNum(id, num) end
end

local forgeExtensions = {
	{ key = "name",          func = _GetItemInfoWrapper(1) },
	{ key = "link",          func = _GetItemInfoWrapper(2) },
	{ key = "quality",       func = _GetItemInfoWrapper(3) },
	{ key = "inventorytype", func = function() return C_Item.GetItemInventoryTypeByID(contextMenuLastItem.id) end },
	{ key = "class",         func = _GetItemInfoWrapper(12) },
	{ key = "subclass",      func = _GetItemInfoWrapper(13) },
}

local forgeExtMap = {}
for k, v in ipairs(forgeExtensions) do
	forgeExtMap[v.key] = v.func
end

local nullFunc = function() end
local function getExtensionFunc(ext)
	return forgeExtMap[ext] or nullFunc
end

local function addForgeCommands()
	if EpsilonLib then
		local commands = EpsilonLib.CommandDefinitions
		if not commands then return end

		local commandDefs = safeGetTablePath(commands, "forge", "item", "set")
		if not commandDefs then return end

		for k, commandBase in pairs(commandDefs) do
			if commandBase._info and forgeExtMap[k] then
				local name = "Set " .. k
				local syntax = commandBase._info.syntax
				local full = commandBase._info.full
				table.insert(forgeCommands, Dropdown.input(name, {
					set = function(self, text)
						local command = strjoin(" ", full, contextMenuLastItem.id, text)
						ARC:CMD(command)
					end,
					get = getExtensionFunc(k),
					placeholder = function() return syntax end,
				}))
			end
		end
	end
end
addForgeCommands()
--]]

local itemContextMenuList = {
	Dropdown.header(function() return (contextMenuLastItem.name or "Unknown Item") end),
	Dropdown.submenu("Link to ArcSpell", {
		Dropdown.customFrame("Personal", itemContextMenu_PersonalVaultDropdown.pullout.frame),
		Dropdown.customFrame("Phase", itemContextMenu_PhaseVaultDropdown.pullout.frame, { hidden = function() return not ns.Permissions.isMemberPlus() end }),
	}),
	Dropdown.execute("Refresh Item", function() ARC:CMD("forge item request " .. contextMenuLastItem.id) end,
		{
			tooltipTitle = function() return ".forge item request " .. contextMenuLastItem.id end,
			tooltipText = "Requests the custom ItemForge Hotfix data for this item again. Typically not needed, but if information is incorrect, use this to force an update.",
			hidden = function() return not (contextMenuLastItem.id and contextMenuLastItem.id > 10000000) end
		}),
	--[[
	-- // Disabled Forge stuff, doesn't make sense to include here tbh, especially since we don't know if they even 'own' this item in order to edit it.
	Dropdown.spacer({ hidden = function() return not (contextMenuLastItem.id and contextMenuLastItem.id > 10000000) end }),
	Dropdown.submenu("Forge", forgeCommands, {
		hidden = function() return not (contextMenuLastItem.id and contextMenuLastItem.id > 10000000) end,
		disabled = function() return #forgeCommands < 1 end,
	})
	--]]
}


hooksecurefunc("ContainerFrameItemButton_OnModifiedClick", function(self, button)
	if (not IsAltKeyDown()) or (button ~= "RightButton") then return end -- Only listen if Alt pressed
	local itemLocation = ItemLocation:CreateFromBagAndSlot(self:GetParent():GetID(), self:GetID());
	local itemIsValidItem = itemLocation:IsValid() and C_Item.DoesItemExist(itemLocation);
	if not itemIsValidItem then return end

	contextMenuLastItem = { id = C_Item.GetItemID(itemLocation), name = C_Item.GetItemName(itemLocation) }

	itemContextMenu_PersonalVaultDropdown:SetList(getSpellsForItemContext(VAULT_TYPE.PERSONAL))
	itemContextMenu_PersonalVaultDropdown.pullout:Open("TOPLEFT", itemContextMenu_PersonalVaultDropdown.frame, "BOTTOMLEFT", 0, 0)
	itemContextMenu_PersonalVaultDropdown.pullout.frame:Hide()

	itemContextMenu_PhaseVaultDropdown:SetList(getSpellsForItemContext(VAULT_TYPE.PHASE))
	itemContextMenu_PhaseVaultDropdown.pullout:Open("TOPLEFT", itemContextMenu_PersonalVaultDropdown.frame, "BOTTOMLEFT", 0, 0)
	itemContextMenu_PhaseVaultDropdown.pullout.frame:Hide()

	-- kill the 'close' buttons
	do
		local self = itemContextMenu_PersonalVaultDropdown.pullout
		local closebutton = self.items[#self.items]
		closebutton = tremove(self.items, #self.items)
		closebutton.frame:Hide()

		local h = #self.items * 16
		self.itemFrame:SetHeight(h)
		self.frame:SetHeight(min(h + 34, self.maxHeight)) -- +34: 20 for scrollFrame placement (10 offset) and +14 for item placement
	end
	do
		local self = itemContextMenu_PhaseVaultDropdown.pullout
		local closebutton = self.items[#self.items]
		closebutton = tremove(self.items, #self.items)
		closebutton.frame:Hide()

		local h = #self.items * 16
		self.itemFrame:SetHeight(h)
		self.frame:SetHeight(min(h + 34, self.maxHeight)) -- +34: 20 for scrollFrame placement (10 offset) and +14 for item placement
	end

	local spellsOnThisItemTable = itemsWithSpellsCache[contextMenuLastItem.id]

	if spellsOnThisItemTable then
		local phaseSpells = spellsOnThisItemTable.phase
		local personalSpells = spellsOnThisItemTable.personal

		if phaseSpells then
			for i = 1, #phaseSpells do
				local spellCommID = phaseSpells[i]
				local spellIndex = Vault.phase.findSpellIndexByID(spellCommID)
				itemContextMenu_PhaseVaultDropdown:SetItemValue(spellIndex, true)
			end
		end

		if personalSpells then
			for i = 1, #personalSpells do
				local spellCommID = personalSpells[i]
				itemContextMenu_PersonalVaultDropdown:SetItemValue(spellCommID, true)
			end
		end
	end


	Dropdown.open(itemContextMenuList, Dropdown.genericDropdownHolder, "cursor")
end)

--#endregion

---@class UI_ItemIntegration_scripts
ns.UI.ItemIntegration.scripts = {
	updateCache = updateCache,
	triggerCooldowns = triggerCooldowns,

	getSpellsWithItemLinks = getSpellsWithItemLinks,
	addItemSpellLink = addItemSpellLink,

	deleteSpellFromItem = deleteSpellFromItem,
	deleteItemLink = deleteItemLink,

	LinkItemToSpell = safeAddItemToSpell,
	RemoveItemLinkFromSpell = safeRemoveItemFromSpell,
}
