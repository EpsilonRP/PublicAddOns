---------------------------------------------------------------------
---------------- Custom Splash System by MindScape00 ----------------
------------------------ Made for EpsilonWoW ------------------------
---------------------------------------------------------------------

---------------------------------------------------------------------
------------------------ Instructions -------------------------------
----------- Add a new Splash to the Splash Versions Table -----------
---- Force Tia into Slave-Labor to make a new splash screen blp -----
---------------------------------------------------------------------

---------------------------------------------------------------------
-- Definitions & Vars
---------------------------------------------------------------------
---@class ns
local ns = select(2, ...)

local version, build, date, tocversion = GetBuildInfo();
local addonName = ...

-- Increment this each time we want a new splash within a build number
local INTERNAL_BUILD_VERSION = 1

build = tostring(build + INTERNAL_BUILD_VERSION)
print(build)

local addonPath = "Interface/AddOns/" .. tostring(addonName)
local assetsPath = addonPath .. "/assets/"

local Utils = ns.Utils
local Tooltip = ns.Utils.Tooltip
local cmd = Utils.cmd
local clickMMIcon = Utils.clickIconFromLauncherTray

if not Epsilon_Splash then Epsilon_Splash = {} end

local baseSplashGlowColor = CreateColorFromBytes(18, 184, 255, 255)

---------------------------------------------------------------------
-- Create Splash Display
---------------------------------------------------------------------

local frame = CreateFrame("Frame", "EpsilonSplashFrame", UIParent) -- Our Frame :)
local size = { x = 882, y = 584 }
size.wRatio = size.x / size.y
size.hRatio = size.y / size.x

frame:SetPoint("CENTER")
frame:SetSize(size.x, size.y)

frame:SetMovable(true)
frame:EnableMouse(true)
frame:SetResizable(true)
frame:SetMaxResize(size.x, size.y)
frame:SetMinResize(size.x / 2, size.y / 2)
frame:SetClampedToScreen(true)
frame:SetClampRectInsets(size.x / 2, -size.x / 2, -size.y / 4, size.y / 2)

frame:Hide()
tinsert(UISpecialFrames, frame:GetName())

frame:RegisterForDrag("LeftButton")
frame:SetScript("OnMouseDown", function(self)
	self:Raise()
end)
frame:SetScript("OnDragStart", function(self)
	self:StartMoving()
end)
frame:SetScript("OnDragStop", function(self)
	self:StopMovingOrSizing()
	self:SetUserPlaced(false) -- don't save..
end)

local resizeDragger = CreateFrame("BUTTON", nil, frame)
resizeDragger:SetSize(16, 16)
resizeDragger:SetPoint("BOTTOMRIGHT", -20, 22)
resizeDragger:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
resizeDragger:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
resizeDragger:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")

-- Dragging functionality
local initialCursorX, initialCursorY
local initialScale

resizeDragger:SetScript("OnMouseDown", function(self, button)
	if button == "LeftButton" then
		-- Store initial cursor position and scale
		initialCursorX, initialCursorY = GetCursorPosition()
		initialScale = frame:GetScale()
		self.isScaling = true
	end
end)

resizeDragger:SetScript("OnMouseUp", function(self, button)
	if button == "LeftButton" then
		self.isScaling = false
	end
end)

resizeDragger:SetScript("OnUpdate", function(self)
	if not self.isScaling then return end
	if self:IsMouseEnabled() and initialCursorX and initialCursorY then
		local currentCursorX, currentCursorY = GetCursorPosition()
		local scaleChange = (currentCursorX - initialCursorX) / frame:GetWidth()
		local newScale = math.max(0.5, initialScale + scaleChange) -- Ensure scale doesn't go below 0.5
		newScale = math.min(newScale, 1)                     -- Ensure scale doesn't go above 1

		-- Apply new scale to the main frame
		frame:SetScale(newScale)
	end
end)

local function hideSplash()
	frame:Hide()
end

---Quick Set-up a On-Click Context Menu in a Region by using quickMenu to handle it.
---@param self Frame The Frame / Region being called on. Typically just self, so self here too
---@param menuList table The actual MenuList table to use
---@param nameOfMenuList? string Optional name to save the menuList to the frame under. I.e., "zones" for the 'Zones' menu to teleport to. Otherwise saved under 'self._menuList'
local function quickMenu(self, menuList, nameOfMenuList)
	if not self or not menuList or type(menuList) ~= "table" then return error("Cannot have an empty self-frame or MenuList.") end

	--[[ -- This seems.. pointless. We don't need to save it, the contextual generation is minimal impact to performance?
	local subTableName = "_menuList"
	if nameOfMenuList and type(nameOfMenuList) == "string" then
		subTableName = nameOfMenuList
	end

	if not self[subTableName] then
		self[subTableName] = menuList
	end
	local subTable_menuList = self[subTableName]
	--]]

	if not self.contextMenuFrame then
		self.contextMenuFrame = CreateFrame("Frame", nil, self, "UIDropDownMenuTemplate")
	end
	EasyMenu(menuList, self.contextMenuFrame, "cursor", 0, 0, "MENU")
end

-- Generic Menu Funcs - Input is (self, arg1, arg2)
-- Lookup Gob
local function lookupGob(self, term)
	if not term then term = self end
	cmd(("lookup object %s"):format(term))
end

local defaultSplashWidthOffset = 0.12

---@class build: string

---@class SplashHighlightRegion
---@field x1 number Top Left
---@field y1 number Top Left
---@field x2 number Bottom Right
---@field y2 number Bottom Right
---@field title? string The Tooltip title
---@field lines? string The additional lines in tooltip. Use \n and \r for new lines, because too lazy to make it support an array of strings
---@field callback? function What happens when it's clicked.
---@field color? ColorMixin this overrides the color for this specific region

---@class SplashTable
---@field tex string Always just the file name, we handle the path otherwise
---@field widthOffset? number The offset to use in SetTexCoord - That is, a percentage as a decimal, calculated from ONE side
---@field heightOffset? number The offset to use in SetTexCoord - That is, a percentage as a decimal, calculated from ONE side
---@field realWidth? number The real textures width, ignoring offsets & scaling. Like, the ACTUAL FILE. Mandatory if using regions
---@field realHeight? number The real textures height, ignoring offsets & scaling. Like, the ACTUAL FILE. Mandatory if using regions
---@field regions? SplashHighlightRegion[]
---@field color? ColorMixin color for glow - this sets for all regions on this table

---@type table<build, SplashTable>
local splashVersions = {
	["45746"] = {
		tex = "WhatsNew2026",
		widthOffset = 0.12,
		heightOffset = 0,
		realWidth = 1024,
		realHeight = 512,
		color = CreateColorFromHexString("FFFFA8F0"),
		regions = {
			{
				x1 = 150,
				y1 = 189,
				x2 = 509,
				y2 = 333,
				title = "New Customizations!",
				lines = "Man, do those characters look GOOD!\nWe've added TONS of new character customization options.\n\rClick to jump into the barber chair & check them out!",
				--[[
				callback = function(self)
					local menuList = {
						{ text = "Teleport to:",  isTitle = true,      notCheckable = true },
						{ text = "Ardenweald",    notCheckable = true, func = function() cmd("tele ardenweald") end },
						{ text = "Bastion",       notCheckable = true, func = function() cmd("tele bastion") end },
						{ text = "Exile's Reach", notCheckable = true, func = function() cmd("tele exilesreach") end },
						{ text = "Korthia",       notCheckable = true, func = function() cmd("tele korthia") end },
						{ text = "The Maw",       notCheckable = true, func = function() cmd("tele themaw") end },
						{ text = "Maldraxxus",    notCheckable = true, func = function() cmd("tele maldraxxus") end },
						{ text = "Oribos",        notCheckable = true, func = function() cmd("tele oribos") end },
						{ text = "Revendreth",    notCheckable = true, func = function() cmd("tele revendreth") end },
						{
							text = "Tazavesh",
							notCheckable = true,
							hasArrow = true,
							menuList = {
								{
									text = "Main World",
									notCheckable = true,
									func = function()
										cmd("tele tazavesh_mainmap")
									end
								},
								{
									text = "Instance",
									notCheckable = true,
									func = function()
										cmd("tele tazavesh_instance")
									end
								}
							}
						},
						{ text = "Zereth Mortis", notCheckable = true, func = function() cmd("tele zerethmortis") end },
					}

					quickMenu(self, menuList)
				end,
				--]]
				callback = function()
					hideSplash(); cmd("cheat barber")
				end
			},
			{
				x1 = 512,
				y1 = 189,
				x2 = 871,
				y2 = 333,
				title = "New Objects!",
				lines = "More objects than we can count! From Draenei, Black Empire, Classic, Fireworks (cuz it's a celebration, duh), and so much more - there's something for everyone in here!\n\rClick to see a list of pre-fixes to lookup to see what's new!",
				callback = function(self)
					local menuList = {
						{ text = "Categories (Click to search):",         isTitle = true,      notCheckable = true },
						{ text = "Black Empire",                          notCheckable = true, arg1 = "eps_bl",                 func = lookupGob },
						{ text = "Classic",                               notCheckable = true, arg1 = "eps_classic",            func = lookupGob },
						{ text = "Draenei",                               notCheckable = true, arg1 = "eps_draenei",            func = lookupGob },
						{ text = "Fireworks",                             notCheckable = true, arg1 = "eps_fireworks",          func = lookupGob },
						{ text = "Forsaken - Revendreth",                 notCheckable = true, arg1 = "eps_forsakenrevendreth", func = lookupGob },
						{ text = "Forsaken",                              notCheckable = true, arg1 = "eps_fk",                 func = lookupGob },
						{ text = "Lightforged Draenei",                   notCheckable = true, arg1 = "eps_lightforged",        func = lookupGob },
						{ text = "Orcish Building Pieces",                notCheckable = true, arg1 = "eps_orc",                func = lookupGob },
						{ text = "Party Food",                            notCheckable = true, arg1 = "eps_partyfood",          func = lookupGob },
						{ text = "Statues",                               notCheckable = true, arg1 = "eps_statue",             func = lookupGob },
						{ text = "HD Azuremyst Trees",                    notCheckable = true, arg1 = "eps_tree",               func = lookupGob },
						{ text = "Insensata's Fixed Night Elf Buildings", notCheckable = true, arg1 = "eps_7ne ",               func = lookupGob },
						{ text = "Fixed Blizzard M2s",                    notCheckable = true, arg1 = "eps_m2fix",              func = lookupGob },
						{ text = "Fixed Blizzard WMOs",                   notCheckable = true, arg1 = "eps_wmofix",             func = lookupGob },
					}

					for k, v in ipairs(menuList) do
						v.tooltipTitle = "Look-up Name:"
						v.tooltipText = v.arg1
						v.tooltipOnButton = 1
					end

					quickMenu(self, menuList)
				end
			},
			{
				x1 = 150,
				y1 = 338,
				x2 = 389,
				y2 = 482,
				title = "Shadowlands Empty WMOs!",
				lines = "The long awaited Shadowlands EmptyWMOs have arrived!\n\rClick to search!",
				callback = function()
					lookupGob(nil, "emptywmo_9")
				end
			},
			{
				x1 = 392,
				y1 = 338,
				x2 = 632,
				y2 = 482,
				title = "Addon Additions & Updates",
				lines = "|C" .. "FFFFA600" .. "Phase Toolkit|r has had a massive glow-up with a brand new UI & Improved QOL!\r\n" ..
					"|C" .. "FFC70011" .. "ObjectMover|r 8.0 is here with a brand new, sleeker Epsi UI!\r\n" ..
					"|C" .. "FF07C900" .. "Cartographer|r has a slew of new Features added to add to your maps!\n\r" ..
					"Click to Open the AddOns & see what's new!",
				callback = function(self)
					local menuList = {
						{ text = "Click & See What's New:", isTitle = true,      notCheckable = true },
						{ text = "Phase Toolkit",           notCheckable = true, func = function() SlashCmdList["PTK"]() end },
						{ text = "ObjectMover",             notCheckable = true, func = function() ObjectToolboxFrame.Toggle() end },
						{ text = "Cartographer",            notCheckable = true, func = function() OpenWorldMap() end },
					}

					for k, v in ipairs(menuList) do
						v.tooltipTitle = "Open AddOn"
						v.tooltipOnButton = 1
					end

					quickMenu(self, menuList)
				end
			},
			{ x1 = 635, y1 = 338, x2 = 873, y2 = 482, title = "Plus more to come!", lines = "There's so much more on the horizon, but there's one thing we wanted to take a moment and highlight:\n\rEnsembles!\n\rNot dead, not forgotten, and definitely not 'bugged and they can't fix it'.\nEpsilon means nothing is impossible, but doing the impossible takes time.\n\rWe promise: The wait is almost over, and it's going to be well worth it." },
		}
	},

	["45745"] = {
		tex = "WhatsNew3",
		widthOffset = 0.12,
		heightOffset = 0,
		realWidth = 1024,
		realHeight = 512,
		regions = {
			{
				x1 = 150,
				y1 = 189,
				x2 = 509,
				y2 = 333,
				title = "New Lands!",
				lines = "Experience the Shadowlands like never before!\n\rClick to choose a new zone to teleport to!",
				callback = function(self)
					local menuList = {
						{ text = "Teleport to:",  isTitle = true,      notCheckable = true },
						{ text = "Ardenweald",    notCheckable = true, func = function() cmd("tele ardenweald") end },
						{ text = "Bastion",       notCheckable = true, func = function() cmd("tele bastion") end },
						{ text = "Exile's Reach", notCheckable = true, func = function() cmd("tele exilesreach") end },
						{ text = "Korthia",       notCheckable = true, func = function() cmd("tele korthia") end },
						{ text = "The Maw",       notCheckable = true, func = function() cmd("tele themaw") end },
						{ text = "Maldraxxus",    notCheckable = true, func = function() cmd("tele maldraxxus") end },
						{ text = "Oribos",        notCheckable = true, func = function() cmd("tele oribos") end },
						{ text = "Revendreth",    notCheckable = true, func = function() cmd("tele revendreth") end },
						{
							text = "Tazavesh",
							notCheckable = true,
							hasArrow = true,
							menuList = {
								{
									text = "Main World",
									notCheckable = true,
									func = function()
										cmd("tele tazavesh_mainmap")
									end
								},
								{
									text = "Instance",
									notCheckable = true,
									func = function()
										cmd("tele tazavesh_instance")
									end
								}
							}
						},
						{ text = "Zereth Mortis", notCheckable = true, func = function() cmd("tele zerethmortis") end },
					}

					quickMenu(self, menuList)
				end,
			},
			{
				x1 = 512,
				y1 = 189,
				x2 = 871,
				y2 = 333,
				title = "New Character Options!",
				lines = "And did we mention, '.cheat barber' is working again!\n\rClick to open the barbershop & start customizing!",
				callback = function()
					hideSplash(); cmd("cheat barber")
				end
			},
			{
				x1 = 150,
				y1 = 338,
				x2 = 389,
				y2 = 482,
				title = "Object Viewer!",
				lines =
				"Search, Preview, and Catalogue objects to your hearts content, thanks to our new Object Viewer AddOn from Warli!\n\rClick to open the viewer!",
				callback = function()
					if IsAddOnLoaded("Epsilon_Viewer") then
						SlashCmdList["EPSV"]()
					else
						print("Epsilon Viewer doesn't seem to be loaded. Check you have the AddOn enabled!")
					end
				end
			},
			{
				x1 = 392,
				y1 = 338,
				x2 = 632,
				y2 = 482,
				title = "Over 2,000 new custom objects!",
				lines =
				"We're not talking Shadowlands objects, no.. Over 2,000 new custom objects unique to Epsilon!\n\rClick to see a list of object categories added & quickly look them up!",
				callback = function(self)
					local menuList = {
						{ text = "Categories (Click to search):", isTitle = true,      notCheckable = true },
						{ text = "Path Decals",                   notCheckable = true, arg1 = "eps_pathdecal",          func = lookupGob },
						{ text = "Alien",                         notCheckable = true, arg1 = "eps_alien",              func = lookupGob },
						{ text = "Astronomer",                    notCheckable = true, arg1 = "eps_astronomer",         func = lookupGob },
						{ text = "Badlands",                      notCheckable = true, arg1 = "eps_badlands",           func = lookupGob },
						{ text = "Builder's Haven - Tint",        notCheckable = true, arg1 = "eps_buildershaven_tint", func = lookupGob },
						{ text = "Ethereal",                      notCheckable = true, arg1 = "eps_ethereal",           func = lookupGob },
						{ text = "Eversong",                      notCheckable = true, arg1 = "eps_eversong",           func = lookupGob },
						{ text = "Light Blessed",                 notCheckable = true, arg1 = "eps_lightblessed",       func = lookupGob },
						{ text = "Mystic",                        notCheckable = true, arg1 = "eps_mystic",             func = lookupGob },
						{ text = "Opulent",                       notCheckable = true, arg1 = "eps_opulent",            func = lookupGob },
						{ text = "Pristine",                      notCheckable = true, arg1 = "eps_pristine",           func = lookupGob },
						{ text = "Royal",                         notCheckable = true, arg1 = "eps_royal",              func = lookupGob },
						{ text = "Sand Fury",                     notCheckable = true, arg1 = "eps_sandfury",           func = lookupGob },
						{ text = "Temporal",                      notCheckable = true, arg1 = "eps_temporal",           func = lookupGob },
						{ text = "Void Elf",                      notCheckable = true, arg1 = "eps_voidelf",            func = lookupGob },
						{ text = "Void Touched",                  notCheckable = true, arg1 = "eps_voidtouched",        func = lookupGob },
					}

					for k, v in ipairs(menuList) do
						v.tooltipTitle = "Look-up Name:"
						v.tooltipText = v.arg1
						v.tooltipOnButton = 1
					end

					quickMenu(self, menuList)
				end
			},
			{ x1 = 635, y1 = 338, x2 = 873, y2 = 482, title = "Plus more to come!", lines = "This is just the start, we have more cooking! Keep your eyes peeled for upcoming updates & news!" },
		}
	},
}

local function highlightFrame_OnEnter(self)
	self:SetAlpha(1)
end
local function highlightFrame_OnLeave(self)
	self:SetAlpha(0)
end
local function highlightFrame_OnClick(self)
	if self.callback then self.callback(self) end
end
local function highlightFrame_ttTile(self)
	return self.ttTitle
end
local function highlightFrame_ttLines(self)
	return self.ttLines
end
local function highlightFrame_ttPred(self)
	return self.ttTitle or false
end

local function updateGlowColorOnRegion(f, color)
	for i = 1, #f.Textures do
		f.Textures[i]:SetVertexColor(color:GetRGB())
	end
end

local function customFramePoolFactory(framePool)
	local f = CreateFrame(framePool.frameType, nil, framePool.parent, framePool.frameTemplate); --[[@as BUTTON]]
	f:SetScript("OnEnter", highlightFrame_OnEnter)
	f:SetScript("OnLeave", highlightFrame_OnLeave)
	f:SetScript("OnShow", highlightFrame_OnLeave)
	f:SetScript("OnClick", highlightFrame_OnClick)
	f:RegisterForClicks("LeftButtonUp")
	updateGlowColorOnRegion(f, baseSplashGlowColor)

	Tooltip.set(f, highlightFrame_ttTile, highlightFrame_ttLines, { predicate = highlightFrame_ttPred })

	return f
end

frame.regions = CreateFramePool("BUTTON", frame, "GlowBorderTemplate")
ObjectPoolMixin.OnLoad(frame.regions, customFramePoolFactory, FramePool_HideAndClearAnchors)

frame.splash = frame:CreateTexture(nil, "ARTWORK")
frame.splash:SetAllPoints()
frame.splash:SetTexture(assetsPath .. "WhatsNew3")
frame.splash:SetTexCoord(0 + defaultSplashWidthOffset, 1 - defaultSplashWidthOffset, 0, 1)

frame.close = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
frame.close:SetPoint("TOPRIGHT", -21, -10)

frame.SetSplash = function(self, splash)
	if not splash then return end
	if type(splash) == "number" then splash = tostring(splash) end -- always string

	local splashData = splashVersions[splash]
	if not splashData then return end

	self.splash:SetTexture(assetsPath .. splashData.tex)

	local texCoordX = splashData.widthOffset or 0
	local texCoordY = splashData.heightOffset or 0
	self.splash:SetTexCoord(0 + texCoordX, 1 - texCoordX, 0 + texCoordY, 1 - texCoordY)

	self.regions:ReleaseAll()

	for _, regionData in ipairs(splashData.regions) do
		local f = self.regions:Acquire() --[[@as frame]]
		local adjustedRealTexWidth = (splashData.realWidth * (1 - (texCoordX * 2)))
		local adjustedRealTexHeight = (splashData.realHeight * (1 - (texCoordY * 2)))
		--print("Xr:", adjustedRealTexWidth, "| Yr:", adjustedRealTexHeight)

		local splashXAdjustment = (splashData.realWidth - adjustedRealTexWidth) / 2
		local splashYAdjustment = (splashData.realHeight - adjustedRealTexHeight) / 2
		--print("Xa:", splashXAdjustment, "| Ya:", splashYAdjustment)

		local splashXMult = frame:GetWidth() / adjustedRealTexWidth
		local splashYMult = frame:GetHeight() / adjustedRealTexHeight
		--print("Xm:", splashXMult, "| Ym:", splashYMult)

		f.ttTitle = regionData.title
		f.ttLines = regionData.lines
		f.callback = regionData.callback

		updateGlowColorOnRegion(f, regionData.color or splashData.color or baseSplashGlowColor)

		f:SetPoint("TOPLEFT", (regionData.x1 - splashXAdjustment) * splashXMult,
			-(regionData.y1 - splashYAdjustment) * splashYMult)
		f:SetPoint("BOTTOMRIGHT", self, "TOPLEFT", (regionData.x2 - splashXAdjustment) * splashXMult,
			-(regionData.y2 - splashYAdjustment) * splashYMult)
		f:Show()
	end
end

---------------------------------------------------------------------
-- Run to see if we're gonna show it
---------------------------------------------------------------------

local function epsilonShowSplash(override)
	local _splashVersion = override or build
	if type(_splashVersion) == "number" then _splashVersion = tostring(_splashVersion) end -- always string

	if splashVersions[_splashVersion] then
		frame:SetSplash(_splashVersion)
		frame:Show()
		return true
	end

	return false -- no available splash
end

local showLatestSplash = function(...)
	local latestSplash = 0
	for k, v in pairs(splashVersions) do
		k = tonumber(k) -- convert to number
		if k and k > latestSplash then
			latestSplash = k
		end
	end
	epsilonShowSplash(latestSplash)
end


local function init(override)
	local build = tonumber(build)

	if Epsilon_Splash.lastSplash then
		if tonumber(Epsilon_Splash.lastSplash) < build then
			-- our last splash is older, let's check if there's a splash available
			if epsilonShowSplash() then
				C_SplashScreen.AcknowledgeSplash()
				Epsilon_Splash.lastSplash = build
			end
		else
			return
		end
	else
		if epsilonShowSplash() then
			C_SplashScreen.AcknowledgeSplash()
			Epsilon_Splash.lastSplash = build
		end
	end
end

frame:RegisterEvent("ADDON_LOADED");
local function eventHandler(self, event, ...)
	C_Timer.After(0, init)
	frame:UnregisterEvent("ADDON_LOADED")
end
frame:SetScript("OnEvent", eventHandler);

---------------------------------------------------------------------
-- Chat Command
---------------------------------------------------------------------

SLASH_SPLASH1 = '/splash';
function SlashCmdList.SPLASH(msg, editbox)
	if msg == "help" then
		print("CVAR: " .. GetCVar("splashScreenNormal") .. " | Epsilon_Splash.lastSplash: " .. Epsilon_Splash.lastSplash .. " | Build: " .. build)
	elseif msg and msg ~= "" then
		epsilonShowSplash(msg)
	else
		showLatestSplash()
	end
end

---------------------------------------------------------------------
-- Override Blizzard What's New Button
---------------------------------------------------------------------

C_SplashScreen.RequestLatestSplashScreen = showLatestSplash

-- Forcing the "Whats New" button to always show on the ESC Menu
origGameMenuFrame_UpdateVisibleButtons = GameMenuFrame_UpdateVisibleButtons
GameMenuFrame_UpdateVisibleButtons = function(self)
	--origGameMenuFrame_UpdateVisibleButtons
	--GameMenuButtonWhatsNew:Show();
	--GameMenuButtonOptions:SetPoint("TOP", GameMenuButtonWhatsNew, "BOTTOM", 0, -16);

	local height = 292;
	GameMenuButtonUIOptions:SetPoint("TOP", GameMenuButtonOptions, "BOTTOM", 0, -1);

	local buttonToReanchor = GameMenuButtonWhatsNew;
	local reanchorYOffset = -1;

	local forceShowSplash = true; -- not actually true, if there's no tag, then this won't be shown.
	-- if not SplashFrame_GetShowTag(forceShowSplash) then
	-- GameMenuButtonWhatsNew:Hide();
	-- height = height - 20;
	-- buttonToReanchor = GameMenuButtonOptions;
	-- reanchorYOffset = -16;
	-- else
	-- GameMenuButtonWhatsNew:Show();
	-- GameMenuButtonOptions:SetPoint("TOP", GameMenuButtonWhatsNew, "BOTTOM", 0, -16);
	-- end

	if (C_StorePublic.IsEnabled()) then
		height = height + 20;
		GameMenuButtonStore:Show();
		buttonToReanchor:SetPoint("TOP", GameMenuButtonStore, "BOTTOM", 0, reanchorYOffset);
	else
		GameMenuButtonStore:Hide();
		buttonToReanchor:SetPoint("TOP", GameMenuButtonHelp, "BOTTOM", 0, reanchorYOffset);
	end

	if (not GameMenuButtonRatings:IsShown() and GetNumAddOns() == 0) then
		GameMenuButtonLogout:SetPoint("TOP", GameMenuButtonMacros, "BOTTOM", 0, -16);
	else
		if (GetNumAddOns() ~= 0) then
			height = height + 20;
			GameMenuButtonLogout:SetPoint("TOP", GameMenuButtonAddons, "BOTTOM", 0, -16);
		end

		if (GameMenuButtonRatings:IsShown()) then
			height = height + 20;
			GameMenuButtonLogout:SetPoint("TOP", GameMenuButtonRatings, "BOTTOM", 0, -16);
		end
	end

	self:SetHeight(height);
end


local function showOurSplashInstead(self)
	if not self then self = SplashFrame end
	C_SplashScreen.AcknowledgeSplash()
	self:Hide()
	showLatestSplash()
end
if SplashFrame then
	SplashFrame:SetScript("OnShow", showOurSplashInstead)

	if SplashFrame:IsShown() then
		showOurSplashInstead(SplashFrame)
	end
end
