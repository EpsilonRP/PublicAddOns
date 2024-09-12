---@class ns
local ns = select(2, ...)

local Constants = ns.Constants
local ASSETS_PATH = Constants.ASSETS_PATH
local Tooltip = ns.Utils.Tooltip

local Logging = ns.Logging
local cprint = Logging.cprint

local stratacastDB = { -- Example, overwritten when the DB gets retargetted anyways
	-- { commID = "drunk",    code = { "up", "up", "down" } },
	-- { commID = "arcsmash", code = { "up", "right", "left" } },
}

local strataKey = "LCTRL"

local inputKeys = {
	["DOWN"] = 0,
	["RIGHT"] = 90,
	["UP"] = 180,
	["LEFT"] = 270,
}

local frame = CreateFrame("Frame", nil, UIParent, "InsetFrameTemplate")
--frame.border = CreateFrame("Frame", nil, frame, "DialogBorderTemplate")
frame.NineSlice:SetAlpha(0.33)
frame.Bg:SetAlpha(0.33)
frame:SetPoint("TOPLEFT", 20, -95)
frame:SetWidth(400)
frame:SetHeight(200)
frame:Hide()

frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalMed2")
frame.title:SetPoint("TOPLEFT", 5, 8)
frame.title:SetJustifyH("LEFT")
frame.title:SetText("Stratacast")
frame.title:SetShadowColor(0.2, 0.2, 0.2, 1)
frame.title:SetShadowOffset(1, -1)

frame.noStratagemsText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalMed2")
frame.noStratagemsText:SetText("No Spells Connected\nRight-Click a Spell in your Vault to connect")
frame.noStratagemsText:Hide()
frame.noStratagemsText:SetAllPoints()

local passiveArrowTex = "interface/buttons/ui-microstream-yellow"
local completeArrowTex = "interface/buttons/ui-microstream-green"
local arrowTexturePool = CreateTexturePool(frame, "OVERLAY")
local function acquireArrow(direction)
	local arrow = arrowTexturePool:Acquire()
	arrow:Show()
	arrow:SetSize(24, 24)
	arrow:SetTexture(passiveArrowTex)
	arrow:SetRotation(math.rad(inputKeys[string.upper(direction)]))

	return arrow
end

local function icon_OnClick(self, button)
	ARC:CAST(self:GetParent().commID)
end

local function row_ResetArrows(widget)
	local arrows = widget.arrows
	for k, v in ipairs(arrows) do
		v:SetTexture(passiveArrowTex)
	end
end

local function row_CheckArrowPress(widget, key)
	local arrows = widget.arrows
	local numArrows = #arrows
	local strataData = widget.strataData
	local currentIter = (widget.progress and widget.progress + 1) or 1
	if currentIter > numArrows then return end -- Already at max; exit because probably waiting on reset

	if string.upper(strataData.code[currentIter]) == key then
		-- correct next key, update the visual & progress
		arrows[currentIter]:SetTexture(completeArrowTex)
		widget.progress = currentIter
		if widget.progress >= numArrows then
			-- we've completed the arrows! CAST!
			ARC:CAST(widget.commID)
			C_Timer.After(0.2, function()
				widget.progress = 0 -- reset progress
				row_ResetArrows(widget)
			end)
		end
	else
		-- failed a hit! Reset it all
		widget.progress = 0
		row_ResetArrows(widget)
	end
end

local function row_Create(framePool)
	local f = CreateFrame(framePool.frameType, nil, framePool.parent, framePool.frameTemplate); --[[@as FRAME]]
	f:SetSize(frame:GetWidth() - 10, 50)

	f.icon = CreateFrame("BUTTON", nil, f)
	local icon = f.icon
	icon:SetPoint("LEFT")
	icon:SetSize(48, 48)
	icon:SetNormalTexture("Interface/Icons/inv_misc_questionmark")
	icon:SetHighlightTexture(ASSETS_PATH .. "/dm-trait-select")
	f.icon:SetScript("OnClick", icon_OnClick)

	icon.border = icon:CreateTexture(nil, "OVERLAY")
	icon.border:SetTexture(ASSETS_PATH .. "/dm-trait-border")
	icon.border:SetPoint("TOPLEFT", -6, 6)
	icon.border:SetPoint("BOTTOMRIGHT", 6, -6)

	icon.cooldown = CreateFrame("Cooldown", nil, icon, "CooldownFrameTemplate")
	icon.cooldown:SetAllPoints()
	icon.cooldown:SetUseCircularEdge(true)

	f.name = f:CreateFontString(nil, "OVERLAY", "GameFontNormalMed2")
	local name = f.name
	name:SetPoint("TOPLEFT", icon, "TOPRIGHT", 5, 0)
	name:SetPoint("RIGHT", f, "RIGHT", -10, 0)
	name:SetJustifyH("LEFT")
	name:SetText("Spell Name Loading...")
	name:SetWordWrap(false)

	f.codeText = f:CreateFontString(nil, "OVERLAY", "GameFontNormalMed2")
	local codeText = f.codeText
	codeText:SetPoint("TOPLEFT", name, "BOTTOMLEFT")
	codeText:SetPoint("TOPRIGHT", name, "BOTTOMRIGHT", -10, 0)
	codeText:SetJustifyH("LEFT")
	codeText:SetText("Code Loading...")

	f.codeRegion = CreateFrame("FRAME")
	local codeRegion = f.codeRegion
	codeRegion:SetPoint("TOPLEFT", name, "BOTTOMLEFT")
	codeRegion:SetPoint("RIGHT", name)
	codeRegion:SetHeight(50 - name:GetHeight())

	f.arrows = {}

	return f
end

local function row_Reset(pool, widget)
	widget.icon:SetNormalTexture("Interface/Icons/inv_misc_questionmark")
	widget.name:SetText("Name Loading ...")
	widget.codeText:SetText("Code Loading ...")
	table.wipe(widget.arrows)
	widget.progress = 0
	widget:Hide()
	widget:ClearAllPoints()
end

---@param widget frame
---@param spell VaultSpell
local function row_SetSpell(widget, spell, dbData)
	local iconTex = ns.UI.Icons.getFinalIcon(spell.icon)
	widget.commID = spell.commID
	widget.strataData = dbData
	widget.icon:SetNormalTexture(iconTex)
	widget.name:SetText(spell.fullName)
	widget.codeText:Hide()

	local codeRegion = widget.codeRegion
	local lastArrow

	table.wipe(widget.arrows)
	for _, direction in ipairs(dbData.code) do
		local arrow = acquireArrow(string.upper(direction))

		if lastArrow then
			arrow:SetPoint("LEFT", lastArrow, "RIGHT", -5, 0)
		else
			arrow:SetPoint("LEFT", codeRegion, "LEFT")
		end
		lastArrow = arrow
		tinsert(widget.arrows, arrow)
	end
end

local castRowsPool = CreateFramePool("FRAME", frame)
ObjectPoolMixin.OnLoad(castRowsPool, row_Create, row_Reset)

local function updateStratacastFrame()
	castRowsPool:ReleaseAll()
	arrowTexturePool:ReleaseAll()
	if #stratacastDB > 0 then
		local lastRow
		local numRows = 0
		local maxArrows = 0
		local maxNameLength = 0

		for k, strataData in ipairs(stratacastDB) do
			local spell = ns.Vault.personal.findSpellByID(strataData.commID)
			if spell then
				local row = castRowsPool:Acquire()
				row:SetPoint("RIGHT", frame, "RIGHT", -10, 0)
				row_SetSpell(row, spell, strataData)

				if lastRow then
					row:SetPoint("TOPLEFT", lastRow, "BOTTOMLEFT", 0, -5)
				else
					row:SetPoint("TOPLEFT", frame, "TOPLEFT", 5, -10)
				end

				maxArrows = math.max(maxArrows, #row.arrows)
				maxNameLength = math.max(maxNameLength, row.name:GetUnboundedStringWidth())
				numRows = numRows + 1
				lastRow = row
				row:Show()
			else
				print("Error creating StrataCast, No CommID Found:", strataData.commID)
			end
		end
		frame:SetHeight((numRows * 50) + 20)
		-- width = arrows * their width + the icon size with border + 10 pixel inset, + 5 for adjusting to the last arrow not being 19 but 24 or something..
		local newWidth = math.max((maxArrows * 19) + 60 + 10 + 5, math.max(200, maxNameLength))
		frame:SetWidth(newWidth)
		frame.noStratagemsText:Hide()
	else
		frame:SetHeight(50)
		frame:SetWidth(350)
		frame.noStratagemsText:Show()
	end
end

local function triggerCooldownVisual(commID, cooldownTime)
	local currTime = GetTime()
	for widget in castRowsPool:EnumerateActive() do
		if widget.commID == commID then
			widget.icon.cooldown:SetCooldown(currTime, cooldownTime)
		end
	end
end

frame:SetScript("OnShow", function()
	updateStratacastFrame()
end)
frame:SetScript("OnHide", function()
	arrowTexturePool:ReleaseAll()
	castRowsPool:ReleaseAll()
end)
frame:SetScript("OnKeyDown", function(self, key)
	if inputKeys[key] then
		self:SetPropagateKeyboardInput(false) -- consume the key
		for widget in castRowsPool:EnumerateActive() do
			row_CheckArrowPress(widget, key)
		end
	else
		self:SetPropagateKeyboardInput(true)
	end
end)


local keyWatcher = CreateFrame("FRAME")
keyWatcher:Show()
keyWatcher:EnableKeyboard(true)
keyWatcher:SetPropagateKeyboardInput(true)
keyWatcher:SetScript("OnKeyDown", function(self, key)
	if key == strataKey then
		self:SetPropagateKeyboardInput(false)
		frame:Show()
	else
		self:SetPropagateKeyboardInput(true)
	end
end)
keyWatcher:SetScript("OnKeyUp", function(self, key)
	frame:Hide()
end)


------------------------------------------
--#region Stratacast DB Management
------------------------------------------

---@param commID CommID
---@param sequence table
local function addStratagem(commID, sequence)
	local newData = { commID = commID, code = sequence }
	tinsert(stratacastDB, newData)

	local lastSpell = stratacastDB[#stratacastDB]

	updateStratacastFrame()
end

---@param commID CommID
---@return number?, table?
local function getStratagemData(commID)
	return FindInTableIf(stratacastDB, function(strataData) return strataData.commID == commID end)
end

---@param commID CommID
---@return table|nil
local function removeStratagem(commID)
	local index, data = getStratagemData(commID)
	local removed = table.remove(stratacastDB, index)
	updateStratacastFrame()
	return removed
end

---Move an Item in Relatively - Positive = UP, Negative = DOWN by number of positions
---@param t table
---@param index integer
---@param positions integer
local function moveItemInTable(t, index, positions)
	local newPosition = index - positions

	-- Clamp newPosition to the bounds of the table
	newPosition = math.max(1, math.min(newPosition, #t))

	local value = table.remove(t, index)
	table.insert(t, newPosition, value)
end

local function moveStratagemUp(oldPos)
	moveItemInTable(stratacastDB, oldPos, 1)
	updateStratacastFrame()
end

local function moveStratagemDown(oldPos)
	moveItemInTable(stratacastDB, oldPos, -1)
	updateStratacastFrame()
end

local function moveStratagem(oldPos, newPos)
	local table = stratacastDB
	newPos = math.max(1, math.min(newPos, #table)) -- CLAMP
	local value = table.remove(table, oldPos)
	table.insert(table, newPos, value)
	updateStratacastFrame()
end

local connectedToSuperConduit = true
local function enable()
	SpellCreatorCharacterTable.stratacastEnabled = true
	connectedToSuperConduit = true
	keyWatcher:Show()

	cprint("Connecting to Super Conduit ... ")
	C_Timer.After(0.5, function()
		cprint(("Super Conduit: %s."):format(ns.Constants.ADDON_COLORS.TOOLTIP_EXAMPLE:WrapTextInColorCode("Connected")))
		cprint(("Press %s to begin Stratacasting."):format(Tooltip.genContrastText("Left-Control")))
	end)
end

local function disable()
	if connectedToSuperConduit then
		cprint("Disconnecting from Super Conduit ... ")
		C_Timer.After(0.5, function()
			cprint(("Super Conduit: %s."):format(ns.Constants.ADDON_COLORS.QC_DARKRED:WrapTextInColorCode("Disconnected")))
			cprint(("Why do you hate Managed Democracy?"))
		end)
	end
	SpellCreatorCharacterTable.stratacastEnabled = false
	connectedToSuperConduit = false
	keyWatcher:Hide() -- can't watch for keys when hidden :)
	frame:Hide()   -- just incase it was showing when we disabled it somehow
end

local function toggle(set)
	if set == nil then set = not SpellCreatorCharacterTable.stratacastEnabled end -- invert current if not given otherwise

	if set == connectedToSuperConduit then return end                          -- already set, exit

	if set then enable() else disable() end
end

local function retargetStratacastDB(table)
	stratacastDB = table

	-- hack to load here since the DB is loaded by now
	if not SpellCreatorCharacterTable.stratacastEnabled then
		connectedToSuperConduit = false -- set it early to avoid the print message lol
		disable()
	end
end

-- CreateFrame(framePool.frameType, nil, framePool.parent, framePool.frameTemplate);
local adderRowContainer = CreateFrame("Frame")
adderRowContainer:SetSize(450, 70)
local adderRow = row_Create({ frameType = "FRAME", parent = adderRowContainer })
adderRow:SetPoint("CENTER")
adderRow:Hide()
adderRow:EnableKeyboard(true)
adderRow.icon:Disable()

local arrowAssignmentTexturePool = CreateTexturePool(adderRow, "OVERLAY")
local function acquireAssignmentArrow(direction)
	local arrow = arrowAssignmentTexturePool:Acquire()
	arrow:Show()
	arrow:SetSize(24, 24)
	arrow:SetTexture(completeArrowTex)
	arrow:SetRotation(math.rad(inputKeys[string.upper(direction)]))

	return arrow
end


adderRow.sequence = {}
adderRow:SetScript("OnKeyDown", function(self, key)
	if inputKeys[key] then -- good key
		self:SetPropagateKeyboardInput(false)
		tinsert(self.sequence, key)
		local arrow = acquireAssignmentArrow(key)
		local lastArrow
		if #self.arrows > 0 then lastArrow = self.arrows[#self.arrows] end

		if lastArrow then
			arrow:SetPoint("LEFT", lastArrow, "RIGHT", -5, 0)
		else
			arrow:SetPoint("LEFT", self.codeRegion, "LEFT")
		end

		tinsert(self.arrows, arrow)
		self.codeText:Hide()
		self.codeRegion:Show()
	elseif key == "BACKSPACE" then
		-- remove last arrow
		local lastArrow
		if #self.arrows > 0 then lastArrow = self.arrows[#self.arrows] end
		if lastArrow then
			arrowAssignmentTexturePool:Release(lastArrow)
			tremove(self.arrows)
			tremove(self.sequence)
		end
	else
		self:SetPropagateKeyboardInput(true)
	end
end)
adderRow.Reset = function(self)
	self.sequence = {} -- new table, the last one would be junk or given over when saved
	for k, v in ipairs(self.arrows) do
		arrowAssignmentTexturePool:Release(v)
	end
	table.wipe(self.arrows)
end

StaticPopupDialogs["SCFORGE_ASSIGN_STRATACAST"] = {
	text = "Create a Stratacast Code for %s",
	subText = "Press Backspace to delete a keypress",
	button1 = "Connect",
	button2 = CANCEL,
	OnAccept = function(self, data, data2)
		addStratagem(data, adderRow.sequence)
		adderRow:Reset()
	end,
	OnCancel = function(self)
		adderRow:Reset()
	end,
	width = 300,
	timeout = 0,
	cancels = "SCFORGE_ASSIGN_STRATACAST", -- makes it so only one can be shown at a time
	whileDead = true,
	hideOnEscape = true,
	preferredIndex = 3,
	enterClicksFirstButton = true,
}

---@param spell VaultSpell
local function showStrataAdder(spell)
	local commID = spell.commID

	local row = adderRow
	row_SetSpell(row, spell, { commID = commID, code = {} })
	row.codeRegion:Hide()
	row.codeText:Show()
	row.codeText:SetText("Press Some Arrow Keys already!")
	row:Show()
	adderRowContainer:Show()

	local dialog = StaticPopup_Show("SCFORGE_ASSIGN_STRATACAST", Tooltip.genContrastText(commID), nil, nil, adderRowContainer)
	dialog.data = commID
end

---@class UI_Stratacast
ns.UI.Stratacast = {
	triggerCD = triggerCooldownVisual,
	update = updateStratacastFrame,

	add = addStratagem,
	remove = removeStratagem,
	get = getStratagemData,

	showAdder = showStrataAdder,

	moveUp = moveStratagemUp,
	moveDown = moveStratagemDown,
	moveExact = moveStratagem,

	enable = enable,
	disable = disable,
	toggle = toggle,

	retargetStratacastDB = retargetStratacastDB,
}
