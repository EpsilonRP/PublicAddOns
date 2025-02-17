---@class ns
local ns = select(2, ...)

local Comms = ns.Comms
local Constants = ns.Constants
local Logging = ns.Logging
local Vault = ns.Vault

local dprint = Logging.dprint
local eprint = Logging.eprint

local ADDON_COLOR, ASSETS_PATH = Constants.ADDON_COLOR, Constants.ASSETS_PATH
local VAULT_TYPE = Constants.VAULT_TYPE

local tooltipButton

---@param spell VaultSpell
---@param vaultType VaultType
---@return string chatLink
local function generateSpellLink(spell, vaultType)
	local spellName = spell.fullName
	local spellComm = spell.commID
	local spellIcon = spell.icon
	if spellIcon == nil then spellIcon = "" end
	local charOrPhase
	if vaultType == VAULT_TYPE.PHASE then
		charOrPhase = C_Epsilon.GetPhaseId()
	else
		charOrPhase = UnitName("player")
	end
	local numActions = #spell.actions
	local chatLink = ADDON_COLOR .. "|HarcSpell:" .. spellComm .. ":" .. charOrPhase .. ":" .. numActions .. ":" .. spellIcon .. "|h[" .. spellName .. "]|h|r"
	return chatLink;
end

local orig_ChatEdit_InsertLink = ChatEdit_InsertLink -- Pre-Hook from our below modifications
local tryLinkingToHookedEditBoxes

---@param spell VaultSpell
---@param vaultType VaultType
local function linkSpell(spell, vaultType)
	local link = generateSpellLink(spell, vaultType)

	if not orig_ChatEdit_InsertLink(link) then
		if not tryLinkingToHookedEditBoxes(link) then
			ChatFrame_OpenChat(link)
		end
	end
	-- from ChatEdit_LinkItem
	--[[
	if ChatEdit_GetActiveWindow() then
		ChatEdit_InsertLink(link)
	else
		ChatFrame_OpenChat(link)
	end
	--]]
end

local function getSpellIconSequence(iconPath)
	if (not iconPath or iconPath == "") then iconPath = ASSETS_PATH .. "/BookIcon" end
	iconPath = ns.UI.Icons.getFinalIcon(iconPath)
	local spellIconSize = 24
	local spellIconSequence = "|T" .. iconPath .. ":" .. spellIconSize .. "|t  "
	return spellIconSequence
end

local function setupSpellTooltip(spellName, spellDesc, spellComm, numActions, charOrPhase, spellIconSequence, ephemeral)
	local tooltipTitle = spellIconSequence .. ADDON_COLOR .. spellName

	local tooltip = ItemRefTooltip
	if ephemeral then
		tooltip = GameTooltip
		tooltip:SetOwner(ephemeral, "ANCHOR_BOTTOMRIGHT")
	end

	GameTooltip_SetTitle(tooltip, tooltipTitle)

	tooltip:AddLine(spellDesc, nil, nil, nil, true)
	tooltip:AddLine(" ")
	tooltip:AddDoubleLine("Command: " .. spellComm, "Actions: " .. numActions, 1, 1, 1, 1, 1, 1)
	tooltip:AddDoubleLine("Arcanum Spell", charOrPhase, 0.75, 0.75, 0.75, 0.75, 0.75, 0.75)

	C_Timer.After(0, function()
		if not ephemeral then
			if tonumber(charOrPhase) and not ns.Utils.ChatLinkCache.getSpellFromCache(spellComm, charOrPhase) then -- is a phase, not a character, and no spell in cache
				if charOrPhase == "169" then
					tooltip:AddLine(" ")
					tooltip:AddLine("Get it from the Main Phase Vault")
				else
					tooltip:AddLine(" ")
					tooltip:AddLine("Get it from Phase " .. charOrPhase .. "'s Vault")
				end
			elseif charOrPhase == UnitName("player") then
				tooltip:AddLine(" ")
				tooltip:AddLine("This is your spell.")
			else
				if not tooltipButton then
					tooltipButton = CreateFrame("BUTTON", "SCForgeSpellRefTooltipButton", tooltip, "UIPanelButtonTemplate")
					local cachedSpell = ns.Utils.ChatLinkCache.getSpellFromCache(spellComm, charOrPhase)
					tooltipButton:SetScript("OnClick", function(self)
						local cachedSpell = ns.Utils.ChatLinkCache.getSpellFromCache(self.commID, self.playerName)
						if cachedSpell then
							Comms.tryToSaveReceivedSpell(cachedSpell, charOrPhase, ns.MainFuncs.updateSpellLoadRows)
						else
							Comms.requestSpellFromPlayer(self.playerName, self.commID)
						end
					end)
					if cachedSpell then
						tooltipButton:SetText("Save Spell")
					else
						tooltipButton:SetText("Request Spell")
					end
				end
				tooltipButton:SetHeight(GameTooltip_InsertFrame(tooltip, tooltipButton))
				tooltipButton:SetPoint("RIGHT", -10, 0)
				tooltipButton.playerName = charOrPhase
				tooltipButton.commID = spellComm
			end
		end

		tooltip:Show()
		if tooltip.CloseButton then
			if tooltip.TextLeft1:GetRight() > tooltip.CloseButton:GetLeft() then
				tooltip:SetPadding(16, 0)
			end
		end
	end)
end

---comment
---@param commID any
---@param spellName any
---@param charOrPhase any
---@param linkData any
---@param manualSpellData any
---@param ephemeral frame -- The frame to use if this is considered an ephemeral tooltip - aka, temporary popup. if given, does not give the clicky button either
local function showSpellTooltip(commID, spellName, charOrPhase, linkData, manualSpellData, ephemeral)
	local theSpell
	if manualSpellData then
		theSpell = manualSpellData
	elseif charOrPhase == UnitName("player") then
		theSpell = Vault.personal.findSpellByID(commID)
	else
		theSpell = ns.Utils.ChatLinkCache.getSpellFromCache(commID, charOrPhase)
	end
	if theSpell then
		dprint("Spell Existed somewhere - using it's data, not the link data!")
		local spellName, spellDesc, spellComm, numActions = theSpell.fullName, theSpell.description, theSpell.commID, #theSpell.actions
		local spellIconSequence = getSpellIconSequence(theSpell.icon)
		setupSpellTooltip(spellName, spellDesc, spellComm, numActions, charOrPhase, spellIconSequence, ephemeral)
	else
		local spellComm, spellcharOrPhase, numActions, spellIconID = strsplit(":", linkData)
		local spellIconSequence = getSpellIconSequence(spellIconID)
		setupSpellTooltip(spellName, nil, spellComm, numActions, spellcharOrPhase, spellIconSequence, ephemeral)
	end
end

local _ChatFrame_OnHyperlinkShow = ChatFrame_OnHyperlinkShow
function ChatFrame_OnHyperlinkShow(...)
	pcall(_ChatFrame_OnHyperlinkShow, ...)
	if IsModifiedClick() then return end
	local linkType, linkData, displayText = LinkUtil.ExtractLink(select(3, ...))

	if linkType == "arcSpell" then
		local spellName = displayText:gsub("%[(.+)%]", "%1")
		local spellComm, charOrPhase, numActions, spellIcon = strsplit(":", linkData)

		showSpellTooltip(spellComm, spellName, charOrPhase, linkData)
	end
end

local function chatMessageSendLinkHook(msg, chatType, languageID, target)
	if msg:find("|HarcSpell:") then
		local linkData, displayText = string.match(msg, [[|HarcSpell:([^|]*)|h(.*)|h]]);
		local spellComm, charOrPhase, numActions, spellIcon = strsplit(":", linkData)
		if not spellComm or not charOrPhase then
			eprint("Erorr in Link: No Valid SpellComm or charOrPhase.")
			return
		end

		if msg:find("^%.") then
			chatType = "EPSI_ANNOUNCE"; dprint("Arc SCM Hook: Sent as command, sending global cache")
		end
		if charOrPhase == UnitName("player") or (tonumber(charOrPhase) == tonumber(C_Epsilon.GetPhaseId()) and ns.Vault.phase.isLoaded == true) then -- make sure we are sending our own spell or our current phases vault, and not sending another person's link..
			Comms.sendSpellForCache(spellComm, charOrPhase, chatType, target)
		else
			dprint(nil, "Spell Link caught, but not ours or not the phase we are in, or phase vault not loaded. (" .. spellComm .. " from " .. charOrPhase .. "'s vault)")
		end
	end
end

hooksecurefunc("SendChatMessage", chatMessageSendLinkHook)

--#region ChatLink EditBox Linking

local hookedEditBoxes = {}

---@param editBox EditBox
local function registerEditBoxForChatLinks(editBox)
	tinsert(hookedEditBoxes, editBox)
	editBox.registeredForHyperlinks = true
	editBox:SetHyperlinksEnabled(1)
end

local function unregisterEditBoxForChatLinks(editBox)
	editBox.registeredForHyperlinks = false
	tDeleteItem(hookedEditBoxes, editBox)
end

tryLinkingToHookedEditBoxes = function(link)
	if (not link) then return false end
	for k, editBox in ipairs(hookedEditBoxes) do
		if editBox:IsVisible() and editBox:HasFocus() then
			editBox:SetText(editBox:GetText() .. link)
			return true;
		end
	end
end
hooksecurefunc("ChatEdit_InsertLink", tryLinkingToHookedEditBoxes)

--#endregion

---@class UI_ChatLink
ns.UI.ChatLink = {
	linkSpell = linkSpell,
	showSpellTooltip = showSpellTooltip,
	generateSpellLink = generateSpellLink,

	registerEditBox = registerEditBoxForChatLinks,
	unregisterEditBox = unregisterEditBoxForChatLinks,
}
