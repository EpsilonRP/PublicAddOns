-------------------------------------------------------------------------------
-- Initialize Variables
-------------------------------------------------------------------------------

-- local utils = Epsilon.utils
-- local messages = utils.messages
-- local server = utils.server
-- local tabs = utils.tabs

-- local main = Epsilon.main
local ADDON_NAME, ns = ...
local addonVersion, addonAuthor, addonName = GetAddOnMetadata(ADDON_NAME, "Version"), GetAddOnMetadata(ADDON_NAME, "Author"),
	GetAddOnMetadata(ADDON_NAME, "Title")

local addonColor = "|cff" .. "FFD700"

local useAddonMsgCommands = true

local OPmoveLength, OPmoveWidth, OPmoveHeight, MessageCount, ObjectClarifier, SpawnClarifier, ScaleClarifier, RotateClarifier, OPObjectSpell, cmdPref, isGroupSelected, m, rateLimited =
	0, 0, 0, 0, false, false, false, false, nil, "gobject", nil, nil, false
BINDING_HEADER_OBJECTMANIP, SLASH_OM_SHOWCLOSE1, SLASH_OM_SHOWCLOSE2, SLASH_OM_SHOWCLOSE3 = "Object Mover", "/obj", "/om",
	"/op"

local isWMO = { [14] = true, [15] = true, [33] = true, [38] = true, [43] = true, [54] = true }
local ObjectTypes = {
	[0] = "DOOR",
	[1] = "BUTTON",
	[2] = "QUESTGIVER",
	[3] = "CHEST",
	[4] = "BINDER",
	[5] = "GENERIC",
	[6] = "TRAP",
	[7] = "CHAIR",
	[8] = "SPELL_FOCUS",
	[9] = "TEXT",
	[10] = "GOOBER",
	[11] = "TRANSPORT",
	[12] =
	"AREADAMAGE",
	[13] = "CAMERA",
	[14] = "MAP_OBJECT (WMO)",
	[15] = "MAP_OBJ_TRANSPORT (WMO)",
	[16] = "DUEL_ARBITER",
	[17] =
	"FISHINGNODE",
	[18] = "RITUAL",
	[19] = "MAILBOX",
	[20] = "DO_NOT_USE",
	[21] = "GUARDPOST",
	[22] = "SPELLCASTER",
	[23] =
	"MEETINGSTONE",
	[24] = "FLAGSTAND",
	[25] = "FISHINGHOLE",
	[26] = "FLAGDROP",
	[27] = "MINI_GAME",
	[28] = "DO_NOT_USE_2",
	[29] = "CONTROL_ZONE",
	[30] = "AURA_GENERATOR",
	[31] = "DUNGEON_DIFFICULTY",
	[32] = "BARBER_CHAIR",
	[33] =
	"DESTRUCTIBLE_BUILDING (WMO)",
	[34] = "GUILD_BANK",
	[35] = "TRAPDOOR",
	[36] = "NEW_FLAG",
	[37] = "NEW_FLAG_DROP",
	[38] =
	"GARRISON_BUILDING (WMO)",
	[39] = "GARRISON_PLOT",
	[40] = "CLIENT_CREATURE",
	[41] = "CLIENT_ITEM",
	[42] =
	"CAPTURE_POINT (WMO)",
	[43] = "PHASEABLE_MO",
	[44] = "GARRISON_MONUMENT",
	[45] = "GARRISON_SHIPMENT",
	[46] =
	"GARRISON_MONUMENT_PLAQUE",
	[47] = "ITEM_FORGE",
	[48] = "UI_LINK",
	[49] = "KEYSTONE_RECEPTACLE",
	[50] = "GATHERING_NODE",
	[51] = "CHALLENGE_MODE_REWARD",
	[52] = "MULTI",
	[53] = "SIEGEABLE_MULTI",
	[54] = "SIEGEABLE_MO (WMO)",
	[55] =
	"PVP_REWARD",
	[56] = "PLAYER_CHOICE_CHEST",
	[57] = "LEGENDARY_FORGE",
	[58] = "GARR_TALENT_TREE",
	[59] =
	"WEEKLY_REWARD_CHEST",
	[60] = "CLIENT_MODEL"
}
local ObjectAnims = {
	[0] = "Stand",
	[145] = "Spawn",
	[146] = "Close",
	[147] = "Closed",
	[148] = "Open",
	[149] = "Opened",
	[150] = "Destroy",
	[157] = "Despawn"
}

-- Chat Filter Cache

local chatFilterCounter = { -- count = # of messages pending to filter, message = the format of the reply message to match for filtering - Can be a table if multiple possible messages.
	["ROTATE"] = { count = 0, message = "" },
	["SPAWN"] = { count = 0, message = "" },
	["SCALE"] = { count = 0, message = "GameObject .* has been set to scale" },
	["MOVE"] = { count = 0, message = "" },
	["COLOR"] = { count = 0, message = "" },
	["GROUP_ADD"] = { count = 0, message = "" },
	["ANIM"] = { count = 0, message = "" },
	["VIS"] = { count = 0, message = "" },
}

local chatFilterFailureMessage = { "Syntax", "was not found", "You do not have", "Incorrect" }

local function updateChatFilterQ(com, num)
	chatFilterCounter.com.count = chatFilterCounter.com.count + num
end

---@class SelectedObjectData
---@field [1] guid
---@field [2] entryID
---@field [3] fileName
---@field [4] fileDataID
---@field [5] x
---@field [6] y
---@field [7] z
---@field [8] orientation
---@field [9] rx
---@field [10] ry
---@field [11] rz
---@field [12] hasTint
---@field [13] red
---@field [14] green
---@field [15] blue
---@field [16] alpha
---@field [17] spell
---@field [18] scale
---@field [19] groupLeaderID
---@field [20] objType
---@field [21] saturation
---@field [22] rGUIDLow
---@field [23] rGUIDHigh
---@field [24] isEditable

-------------------------------------------------------------------------------
-- Simple Chat & Print Functions
-------------------------------------------------------------------------------

local function cprint(text)
	print(addonColor .. addonName .. ": " .. (text and text or "ERROR") .. "|r")
end

local function dprint(force, text, ...)
	local statements = { ... }
	if type(force) ~= "boolean" then
		table.insert(statements, 1, text)
		text = force
		force = false
	end

	if #statements == 0 then tinsert(statements, "") end -- avoid printing nil on unpack by padding an empty string.
	if text and (force == true or OPMasterTable.Options["debug"]) then
		local line = strmatch(debugstack(2), ":(%d+):")
		if line then
			print(addonColor .. addonName .. " DEBUG " .. line .. ": " .. text, unpack(statements))
		else
			print(addonColor .. addonName .. " DEBUG: " .. text, unpack(statements))
			print(debugstack(2))
		end
	end
end

local function eprint(text, ...)
	local line = strmatch(debugstack(2), ":(%d+):")

	if line then
		print(addonColor .. addonName .. " Error @ " .. line .. ": " .. text, ...)
	else
		print(addonColor .. addonName .. " @ ERROR: " .. text, ...)
		print(debugstack(2))
	end
end

local sendAddonCmd

if EpsilonLib and EpsilonLib.AddonCommands then
	sendAddonCmd = EpsilonLib.AddonCommands.Register("ObjectMover")
else
	function sendAddonCmd(text)
		local cmdPref = "i:om:"
		local fullCmd = cmdPref .. text

		C_ChatInfo.SendAddonMessage("Command", fullCmd, "GUILD")
	end
end

local function cmd(text, forceShowReply)
	if useAddonMsgCommands and OPShowMessagesToggle:GetChecked() ~= true and not forceShowReply then
		sendAddonCmd(text)
	else -- Send as a normal command if we have show messages enabled
		SendChatMessage("." .. text, "GUILD");
	end

	dprint(false, "Sending Command: " .. text)
end

function OPManagerPrint(text)
	cprint(text)
end

function OPManagerCMD(mainCom, text, groupCheck)
	if groupCheck then
		if isGroupSelected then mainCom = "gobject group" else mainCom = "gobject" end
	end
	if mainCom and text then
		cmd(mainCom .. " " .. text)
	else
		cmd(mainCom)
	end
end

-------------------------------------------------------------------------------
-- Utils
-------------------------------------------------------------------------------

local function euler_to_quaternion(x_deg, y_deg, z_deg)
	-- The inputs are in X (pitch), Y (yaw), Z (roll) order but the rotation is applied in YXZ order
	-- We will map the input directly to yaw (Y), pitch (X), and roll (Z)

	-- Convert degrees to radians
	local pitch = math.rad(x_deg) -- X-axis (Pitch)
	local yaw = math.rad(y_deg) -- Y-axis (Yaw)
	local roll = math.rad(z_deg) -- Z-axis (Roll)

	-- Compute cosines and sines for half angles
	local cy = math.cos(yaw * 0.5) -- yaw (Y rotation)
	local sy = math.sin(yaw * 0.5)
	local cx = math.cos(pitch * 0.5) -- pitch (X rotation)
	local sx = math.sin(pitch * 0.5)
	local cz = math.cos(roll * 0.5) -- roll (Z rotation)
	local sz = math.sin(roll * 0.5)

	-- Quaternion based on YXZ order
	local qw = cy * cx * cz + sy * sx * sz
	local qx = cy * sx * cz + sy * cx * sz
	local qy = sy * cx * cz - cy * sx * sz
	local qz = cy * cx * sz - sy * sx * cz

	-- Return the quaternion components
	return qx, qy, qz, qw
end

-- Function to format numbers conditionally
local function formatNumber(num)
	if math.floor(num) == num then
		return tostring(num)                      -- Integer, no decimals needed
	else
		return ("%.14f"):format(num):gsub("%.?0+$", "") -- Keep up to 12 decimals, remove trailing zeroes
	end
end

-------------------------------------------------------------------------------
-- Loading Sequence
-------------------------------------------------------------------------------

local function isNotDefined(s)
	return s == nil or s == '';
end

function loadMasterTable()
	if not OPMasterTable then OPMasterTable = {} end
	if not OPMasterTable.Options then OPMasterTable.Options = {} end
	if isNotDefined(OPMasterTable.Options["debug"]) then OPMasterTable.Options["debug"] = false end
	if isNotDefined(OPMasterTable.Options["SliderStep"]) then OPMasterTable.Options["SliderStep"] = 0.01 end
	if isNotDefined(OPMasterTable.Options["locked"]) then OPMasterTable.Options["locked"] = false end
	if isNotDefined(OPMasterTable.Options["fadePanel"]) then OPMasterTable.Options["fadePanel"] = false end
	if isNotDefined(OPMasterTable.Options["autoShow"]) then OPMasterTable.Options["autoShow"] = false end
	if isNotDefined(OPMasterTable.Options["autoShowPopout"]) then OPMasterTable.Options["autoShowPopout"] = false end
	if isNotDefined(OPMasterTable.Options["wasPopoutShown"]) then OPMasterTable.Options["wasPopoutShown"] = false end
	if isNotDefined(OPMasterTable.Options["showMessages"]) then OPMasterTable.Options["showMessages"] = false end
	if isNotDefined(OPMasterTable.Options["showTooltips"]) then OPMasterTable.Options["showTooltips"] = true end
	if isNotDefined(OPMasterTable.Options["MovePlayer"]) then OPMasterTable.Options["MovePlayer"] = false end
	if isNotDefined(OPMasterTable.Options["useOverlayMethod"]) then OPMasterTable.Options["useOverlayMethod"] = false end
	if isNotDefined(OPMasterTable.Options["autoUpdateRot"]) then OPMasterTable.Options["autoUpdateRot"] = true end
	if isNotDefined(OPMasterTable.Options["autoUpdateTint"]) then OPMasterTable.Options["autoUpdateTint"] = true end

	if not OPMasterTable.ParamPresetKeys then OPMasterTable.ParamPresetKeys = { "Building Tile", "Fine Positioning" } end
	if not OPMasterTable.ParamPresetContent then
		OPMasterTable.ParamPresetContent = {
			["Building Tile"] = {
				["ObjectID"] = false,
				["Length"] = 4,
				["Width"] = 4,
				["Height"] = 0.25,
				["Scale"] = 1,
			},
			["Fine Positioning"] = {
				["ObjectID"] = false,
				["Length"] = 0.01,
				["Width"] = 0.01,
				["Height"] = 0.01,
				["Scale"] = 1,
			},
		}
	end


	if not OPMasterTable.RotPresetKeys then OPMasterTable.RotPresetKeys = { "Reset (0,0,0)" } end
	if not OPMasterTable.RotPresetContent then
		OPMasterTable.RotPresetContent = {
			["Reset (0,0,0)"] = {
				["RotX"] = 0,
				["RotY"] = 0,
				["RotZ"] = 0,
			},
		}
	end
end

loadMasterTable()

-- // Why are these global, MindScape!?
OPFramesAreLoaded = false
FrameLoadingPoints = 0
OPSaveType = nil
ObjectSelectLineCount = 3
local OP_AutoDimensionModelFrame = nil

function OPInitializeLoading() -- // Why is this global!? Do we call it from XML?
	FrameLoadingPoints = FrameLoadingPoints + 1
	if FrameLoadingPoints >= 3 then
		OPFramesAreLoaded = true
		FrameLoadingPoints = 0
		dprint("Frames Loaded: Rotation Enabled.")
	end
end

local dontUseClientRotation
if C_Epsilon.RotateObject then
	dprint("C_Epsilon.RotateObject exists - Using Client-Side rotation.")
	dontUseClientRotation = false
else
	dprint("C_Epsilon.RotateObject doesn't exist - Falling back to full server-side rotation.")
	dontUseClientRotation = true
end


local OPAddon_OnLoad = CreateFrame("frame", "OPAddon_OnLoad");
OPAddon_OnLoad:RegisterEvent("ADDON_LOADED");
OPAddon_OnLoad:SetScript("OnEvent", function(self, event, name)
	if name == ADDON_NAME then
		--OPMiniMapLoadPosition()
		loadMasterTable()

		--Quickly Show / Hide the Frame on Start-Up to initialize everything for key bindings & loading
		C_Timer.After(1, function()
			OPMainFrame:Show();
			--OPPanel4Tint:Show(); -- Quickly Show & Hide the Tint Frame to initialize it so it updates as well from the start if auto-update is on.
			--OPPanel4Tint:Hide();
			OPPanel4Overlay:Show();
			OPPanel4Overlay:Hide();
			OPPanel4Manager:Show();
			OPPanel4Manager:Hide();
			OPMainFrame:Hide();
			if OPMasterTable.Options["autoShow"] then OPMainFrame:Show() end
			if OPMasterTable.Options["autoShowPopout"] then OPPanelPopout:Show() end
			if OPMasterTable.Options["wasPopoutShown"] == 1 then OPPanelPopout:Show() end
		end)

		-- Create our ModelScene handler frame for use later in auto-dimensions
		OP_AutoDimensionModelFrame = CreateFrame("ModelScene")
		Mixin(OP_AutoDimensionModelFrame, ModelSceneMixin)
		OP_AutoDimensionModelFrame.o = OP_AutoDimensionModelFrame:CreateActor(nil, "ObjectMoverActorTemplate")
		OP_AutoDimensionModelFrame.o.OnModelLoaded = function()
			dprint("Model Loaded - Getting boundingbox")
			local mX1, mY1, mZ1, mX2, mY2, mZ2 = OP_AutoDimensionModelFrame.o:GetActiveBoundingBox()
			local mX = mX1 - mX2; local mY = mY1 - mY2; local mZ = mZ1 - mZ2
			OPLengthBox:SetText(roundToNthDecimal(abs(mX), 7))
			OPWidthBox:SetText(roundToNthDecimal(abs(mY), 7))
			OPHeightBox:SetText(roundToNthDecimal(abs(mZ), 7))
			dprint("AUTODIM: X: " ..
				mX .. " (" .. mX1 ..
				" | " .. mX2 .. "), Y: " .. mY .. " (" .. mY1 .. " | " .. mY2 .. "), Z: " .. mZ .. " (" ..
				mZ1 .. " | " .. mZ2 .. ")")
			OP_AutoDimensionModelFrame.o:ClearModel()
		end
	end
end);

--[[
function OPObjectPreviewGenerateFrame()
	OPPanelPopout.ObjPreview.Scene = CreateFrame("ModelScene", nil, OPPanelPopout.ObjPreview)
	Mixin(OPPanelPopout.ObjPreview.Scene, ModelSceneMixin)
	OPPanelPopout.ObjPreview.Scene:OnLoad()
	OPPanelPopout.ObjPreview.Scene:SetSize(164,160)
	OPPanelPopout.ObjPreview.Scene:SetPoint("BOTTOMLEFT", OPPanelPopout.ObjPreview, "BOTTOMLEFT", 8, 8)

	OPPanelPopout.ObjPreview.Scene.Camera = OPPanelPopout.ObjPreview.Scene:CreateCameraFromScene(112)
	OPPanelPopout.ObjPreview.Scene.Camera:SetTarget(0,0,0)
	OPPanelPopout.ObjPreview.Scene.Camera:SetPitch(0)
	OPPanelPopout.ObjPreview.Scene.Camera:SetMinZoomDistance(10)
	OPPanelPopout.ObjPreview.Scene:SetCameraNearClip(0.01)
	OPPanelPopout.ObjPreview.Scene:SetCameraFarClip(2^64)
	OPPanelPopout.ObjPreview.Scene:SetScript("OnUpdate", function(self,elapsed)
		self:OnUpdate(elapsed)
		OPPanelPopout.ObjPreview.Scene.Camera:SetYaw(OPPanelPopout.ObjPreview.Scene.Camera:GetYaw() + elapsed / 10)
	end)

	OPPanelPopout.ObjPreview.Scene.Actor = OPPanelPopout.ObjPreview.Scene:CreateActor("OPPrevierwerObject", ObjectMoverActorTemplate)
	local actor = OPPanelPopout.ObjPreview.Scene.Actor
	function actor:OnModelLoaded(self)
		local x1, y1, z1, x2, y2, z2 = self:GetActiveBoundingBox()
		if x2 == nil then return end
		local lx = x2 - x1
		local ly = y2 - y1
		local lz = z2 - z1
		local size = math.sqrt(lx ^ 2 + ly ^ 2 + lz ^ 2) * 1.5
		local angle = math.max(lx, ly) < lz and 0 or 45 / 2
		local camera = self:GetParent():GetActiveCamera()
		--self:SetPitch(math.rad(45))
		--camera:SetPitch(math.rad(angle))
		camera:SetPitch(math.rad(90))
		camera:SetTarget(0, 0, 0)
		camera:SetMinZoomDistance(size)
		camera:SetMaxZoomDistance(size)
		camera:SetZoomDistance(size)
		camera:SnapAllInterpolatedValues();
	end
end
--]]

local function getSpellVisualKitByValues(tintType, r, g, b, a, s)
	local useNewSystem = true

	local colorIncrement = 5
	local transparencyIncrement = 20
	local saturationIncrement = 20

	if tonumber(a) == 100 then return; end -- if set to fully transparent, we will ignore and show the base object.
	local rStepped = tonumber(r) / colorIncrement
	local gStepped = tonumber(g) / colorIncrement
	local bStepped = tonumber(b) / colorIncrement
	local aStepped = tonumber(a) / transparencyIncrement
	local sStepped = tonumber(s) / saturationIncrement

	local ColourSteps = (100 / colorIncrement) + 1;
	local SaturationSteps = (100 / saturationIncrement);

	-- local startingID = 100000 -- // 830
	local startingID = 100000 + 22000 -- // 927
	if useNewSystem then
		-- startingID = 100001 -- Tint SpellVisual Start ID // 830
		startingID = 100001 + 22000 -- Tint SpellVisual Start ID // 927
	end
	if tonumber(tintType) == 2 then
		-- adjust starting ID if Overlay
		-- startingID = 331526; -- Overlay SpellVisual Start ID // 830
		startingID = 331526 + 22000; -- Overlay SpellVisual Start ID // 927
	end

	local spellVisualID = startingID
	spellVisualID = spellVisualID + (rStepped)
	spellVisualID = spellVisualID + (gStepped * ColourSteps);
	spellVisualID = spellVisualID + (bStepped * ColourSteps ^ 2);
	spellVisualID = spellVisualID + ((SaturationSteps - sStepped) * ColourSteps ^ 3);
	spellVisualID = spellVisualID + (aStepped * ((ColourSteps ^ 3) * SaturationSteps));
	dprint("SpellVisualID: " .. spellVisualID)

	local spellVisualKitID = spellVisualID + 30000
	dprint("SpellVisualKitID: " .. spellVisualKitID)
	return (spellVisualKitID);
end

function OPObjectPreviewerActor_OnModelLoaded(self)
	local x1, y1, z1, x2, y2, z2 = self:GetActiveBoundingBox()
	if x2 == nil then return end
	local lx = x2 - x1
	local ly = y2 - y1
	local lz = z2 - z1
	local size = math.sqrt(lx ^ 2 + ly ^ 2 + lz ^ 2) * 1.5
	local angle = math.max(lx, ly) < lz and 45 / 3 or 45 / 2
	local camera = self:GetParent():GetActiveCamera()
	camera:SetPitch(math.rad(angle))
	camera:SetTarget(0, 0, 0)
	camera:SetMinZoomDistance(size * 0.5)
	camera:SetMaxZoomDistance(size * 2)
	camera:SetZoomDistance(size * 0.9)
	camera:SnapAllInterpolatedValues();

	-- Generating Bounding Box Sizes for the PopOut Panel Info
	if self:GetModelFileID() == 1 then
		OPSelectedObjectDimX = nil
		OPSelectedObjectDimY = nil
		OPSelectedObjectDimZ = nil
	else
		local dimX = roundToNthDecimal(abs(lx), 4); local dimY = roundToNthDecimal(abs(ly), 4); local dimZ =
			roundToNthDecimal(abs(lz), 4)
		OPPanelPopout.ObjDimensions.Text:SetText(dimX .. "*" .. dimY .. "*" .. dimZ)
		OPSelectedObjectDimX = abs(lx)
		OPSelectedObjectDimY = abs(ly)
		OPSelectedObjectDimZ = abs(lz)
	end

	if tonumber(OPLastSelectedObjectData[12]) ~= 0 then -- if it has a tint set, let's calculate the spell visual kit for it
		local tintType = OPLastSelectedObjectData[12]
		local r = OPLastSelectedObjectData[13]
		local g = OPLastSelectedObjectData[14]
		local b = OPLastSelectedObjectData[15]
		local a = OPLastSelectedObjectData[16]
		local s = OPLastSelectedObjectData[21]
		self:SetSpellVisualKit(getSpellVisualKitByValues(tintType, r, g, b, a, s))
		if tonumber(a) == 100 then
			self:SetAlpha(1)
		else
			local frameA = (100 - a) / 100
			self:SetAlpha(frameA)
		end
	end
end

--]]

function OPObjectPreviewer_OnLoad(self)
	self.cameras = {};
	self.actorTemplate = "ModelSceneActorTemplate";
	self.tagToActor = {};
	self.tagToCamera = {};

	if self.reversedLighting then
		local lightPosX, lightPosY, lightPosZ = self:GetLightPosition();
		self:SetLightPosition(-lightPosX, -lightPosY, lightPosZ);

		local lightDirX, lightDirY, lightDirZ = self:GetLightDirection();
		self:SetLightDirection(-lightDirX, -lightDirY, lightDirZ);
	end

	self:SetCameraNearClip(0.01)
	self:SetCameraFarClip(2 ^ 64)
	self.Camera = self:CreateCameraFromScene(112)
	self.Camera:SetPitch(0)
	self.Actor = self:GetActorAtIndex(1)
	self.Actor:SetUseCenterForOrigin(true, true, true)
end

function OPObjectPreviewer_OnUpdate(self, elapsed)
	self:OnUpdate(elapsed)
	self.Camera:SetYaw(OPPanelPopout.ObjPreview.Scene.Camera:GetYaw() + elapsed / 10)
end

function OPObjectPreviewer_OnMouseWheel(self, spin)
	local speed = 0.25
	if IsShiftKeyDown() then speed = 3 end
	if spin == 1 then
		local camera = self:GetActiveCamera()
		camera:SetZoomDistance(camera:GetZoomDistance() - speed)
	elseif spin == -1 then
		local camera = self:GetActiveCamera()
		camera:SetZoomDistance(camera:GetZoomDistance() + speed)
	else
		dprint("Object Preivew - No Valid Mousewheel direction detected")
	end
end

function OPObjectPreviewer_OnClick(self, button, down)
	-- nothing right now, let's add some fun stuff later to manipulate the camera angle? idk
end

-----------------------------
--- Frame & UI Functions
-----------------------------

function OPUpdateMoveButtons()
	dprint("Updated to use WASD Layout: " .. tostring(OPMasterTable.Options["wasdButtonLayout"]))
	local parentFrame = OPForwardButton:GetParent()
	local centerAnchor = parentFrame.MovementButtonsAnchor
	if OPMasterTable.Options["wasdButtonLayout"] then
		-- change to WASD Layout
		centerAnchor:SetPoint("CENTER", 0, -6)
		OPForwardButton:SetPoint("CENTER", centerAnchor, "CENTER", 0, 16)
		OPBackwardButton:SetPoint("CENTER", centerAnchor, "CENTER", 0, -4)
		OPLeftButton:SetPoint("CENTER", centerAnchor, "CENTER", -56, -4)
		OPRightButton:SetPoint("CENTER", centerAnchor, "CENTER", 56, -4)
		OPUpButton:SetPoint("CENTER", centerAnchor, "CENTER", -56, 15)
		OPDownButton:SetPoint("CENTER", centerAnchor, "CENTER", 56, 15)
		OPTeleporttoObjectButton:SetPoint("CENTER", centerAnchor, "CENTER", 0, -24)
		OPTeleporttoObjectButton:SetSize(72, 18)
	else
		-- Reset to standard Layout
		centerAnchor:SetPoint("CENTER", -21, 1)
		OPForwardButton:SetPoint("CENTER", centerAnchor, "CENTER", 0, 14)
		OPBackwardButton:SetPoint("CENTER", centerAnchor, "CENTER", 0, -26)
		OPLeftButton:SetPoint("CENTER", centerAnchor, "CENTER", -28, -6)
		OPRightButton:SetPoint("CENTER", centerAnchor, "CENTER", 28, -6)
		OPUpButton:SetPoint("CENTER", centerAnchor, "CENTER", 78, 3)
		OPDownButton:SetPoint("CENTER", centerAnchor, "CENTER", 78, -15)
		OPTeleporttoObjectButton:SetPoint("CENTER", centerAnchor, "CENTER", 78, -34)
		OPTeleporttoObjectButton:SetSize(48, 16)
	end
end

function OPMainFrame_OnUpdate(self)
	if not OPMasterTable.Options["fadePanel"] then
		if self.Timer then
			self.Timer:Cancel(); self.Timer = nil
		end
	else
		if self:IsMouseOver(0, -25, 0, 0) then
			if self.Timer then
				self.Timer:Cancel(); self.Timer = nil
			end
			if self:GetAlpha() <= 0.3 then
				UIFrameFadeIn(self, 0.2, self:GetAlpha(), 1)
			end
		elseif self:GetAlpha() == 1 then
			if not self.Timer then
				self.Timer = C_Timer.NewTicker(0.75, function()
					UIFrameFadeOut(self, 0.5, self:GetAlpha(), 0.3)
					self.Timer = nil
				end, 1)
			end
		end
	end
end

function OPMainFrame_OnShow(self)
	OPUpdateMoveButtons()
	-- Check if Version Update for Changelog
	if OPFramesAreLoaded then
		if OPMasterTable.Options["LastVersion"] then
			--[[
			local cmajor, cminor, crev = strsplit(".", addonVersion,3)
			local lmajor, lminor, lrev = strsplit(".", OPMasterTable.Options["LastVersion"],3)
			local showChangelog = false
			if cmajor > lmajor then showChangelog = true
			elseif cminor > lminor then showChangelog = true
			elseif crev > lrev then showChangelog = true end
			--]]

			if OPMasterTable.Options["LastVersion"] ~= addonVersion then
				OPNewOptionsFrame:Show()
				PanelTemplates_SetTab(OPNewOptionsFrame, 2);
				OPNewOptionsFrame.MainArea.Changelog:Show();
				OPNewOptionsFrame.MainArea.Help:Hide();
				OPNewOptionsFrame.MainArea.NewOptions:Hide();
				dprint("Addon version " ..
					addonVersion ..
					" detected as being ~= last version seen (" .. OPMasterTable.Options["LastVersion"] ..
					")")
			end

			OPMasterTable.Options["LastVersion"] = addonVersion
		else
			OPNewOptionsFrame:Show()
			PanelTemplates_SetTab(OPNewOptionsFrame, 2);
			OPNewOptionsFrame.MainArea.Changelog:Show();
			OPNewOptionsFrame.MainArea.Help:Hide();
			OPNewOptionsFrame.MainArea.NewOptions:Hide();
			OPMasterTable.Options["LastVersion"] = addonVersion
			dprint("Addon version " .. addonVersion .. " detected as being ~= .. well, nothing.")
		end
	end
end

-------------------------------------------------------------------------------
-- Main Functions
-------------------------------------------------------------------------------

--
function updateGroupSelected(status)
	if status then
		isGroupSelected = status
	else
		isGroupSelected = false
	end
	if isGroupSelected == true then
		OPRotationSliderX:Disable()
		OPRotationSliderY:Disable()
		--OPRotationSliderZ:Disable()
		OPRotationEditBoxX:Disable()
		OPRotationEditBoxY:Disable()
		--OPRotationEditBoxZ:Disable()
		rotPresetDropDownMenuButton:Disable()
		OPRotationEditBoxX:SetTextColor(0.5, 0.5, 0.5)
		OPRotationEditBoxY:SetTextColor(0.5, 0.5, 0.5)
		--OPRotationEditBoxZ:SetTextColor(0.5,0.5,0.5)
		OPRotationSliderXTitle:SetTextColor(0.5, 0.5, 0.5)
		OPRotationSliderYTitle:SetTextColor(0.5, 0.5, 0.5)
		--OPRotationSliderZTitle:SetTextColor(0.5,0.5,0.5)
	else
		OPRotationSliderX:Enable()
		OPRotationSliderY:Enable()
		OPRotationSliderZ:Enable()
		OPRotationEditBoxX:Enable()
		OPRotationEditBoxY:Enable()
		OPRotationEditBoxZ:Enable()
		rotPresetDropDownMenuButton:Enable()
		OPRotationEditBoxX:SetTextColor(255, 255, 255, 1)
		OPRotationEditBoxY:SetTextColor(255, 255, 255, 1)
		OPRotationEditBoxZ:SetTextColor(255, 255, 255, 1)
		OPRotationSliderXTitle:SetTextColor(1, 0.82, 0)
		OPRotationSliderYTitle:SetTextColor(1, 0.82, 0)
		OPRotationSliderZTitle:SetTextColor(1, 0.82, 0)
	end
end

--Check to make sure entry is valid
function CheckIfValid(Box, IsNotObjectID, Function)
	local text = Box:GetText()
	if text then text = strtrim(text) end

	if IsNotObjectID then
		if text == text:match("%d+") or text == text:match("%d+%.%d+") or text == text:match("%.%d+") then
			if Function then Function() else return true end
			--If we don't want to find an object ID, and the box's text isn't illegal, e.g. ".1d-2.*+", and if we want to run a function, then run the function, else if we don't want to run a function, just tell them that the box's text is legal
		end
	elseif not IsNotObjectID and text == text:match("%d+") then
		if Function then Function() else return true end
		--If we want to find an object ID, and the box's text is an object ID, and if we want to run a function, then run the function, else if we don't want to run a function, just tell them that the box's text is legal
	end
end

--Get Object ID Function
function OPGetObject(button)
	OPObjectIDBox:SetText(tonumber(OPLastSelectedObjectData[2]))
	dprint("Obejct ID Box updated to: " .. tonumber(OPLastSelectedObjectData[2]))
	if button == "RightButton" then
		if isWMO[tonumber(OPLastSelectedObjectData[20])] then
			dprint("Object was WMO")
		else
			if OPLastSelectedObjectData[4] then
				OP_AutoDimensionModelFrame.o:SetModelByFileID(OPLastSelectedObjectData[4])
				dprint("Generating ModelFrame to get Bounding Box (file ID " .. OPLastSelectedObjectData[4] .. ")")
				if OPLastSelectedObjectData[18] then
					OPScaleBox:SetText(OPLastSelectedObjectData[18])
				end
			end
		end
	end
end

function OPUpdateAllDimensions(amount)
	if not amount then return end;
	amount = tonumber(amount)
	OPLengthBox:SetText(tonumber(OPLengthBox:GetText()) * amount)
	OPWidthBox:SetText(tonumber(OPWidthBox:GetText()) * amount)
	OPHeightBox:SetText(tonumber(OPHeightBox:GetText()) * amount)
end

--Update Internal Dimensions for movement when used, factoring in scale, double and halve options
function updateDimensions(val)
	if OPScaleObjectToggle:GetChecked() == true and OPScaleObjectToggle:IsEnabled() then
		if val == "length" then if tonumber(OPLengthBox:GetText()) ~= nil then OPmoveLength = (tonumber(OPLengthBox:GetText()) * tonumber(OPScaleBox:GetText())) end end
		if val == "width" then if tonumber(OPWidthBox:GetText()) ~= nil then OPmoveWidth = (tonumber(OPWidthBox:GetText()) * tonumber(OPScaleBox:GetText())) end end
		if val == "height" then if tonumber(OPHeightBox:GetText()) ~= nil then OPmoveHeight = (tonumber(OPHeightBox:GetText()) * tonumber(OPScaleBox:GetText())) end end
	else
		if val == "length" then
			if tonumber(OPLengthBox:GetText()) ~= nil then
				OPmoveLength = tonumber(OPLengthBox
					:GetText())
			end
		end
		if val == "width" then
			if tonumber(OPWidthBox:GetText()) ~= nil then
				OPmoveWidth = tonumber(OPWidthBox:GetText())
			end
		end
		if val == "height" then
			if tonumber(OPHeightBox:GetText()) ~= nil then
				OPmoveHeight = tonumber(OPHeightBox
					:GetText())
			end
		end
	end
end

function OPForward()
	updateDimensions("length")
	if OPmoveLength and OPmoveLength ~= "" and OPmoveLength ~= 0 and OPmoveLength ~= nil then
		if not OPMovePlayerInstead:GetChecked() then
			if isGroupSelected then cmdPref = "gobject group" else cmdPref = "gobject" end
			if RelativeToPlayerToggle:GetChecked() then
				cmd(cmdPref .. " relative forward " .. OPmoveLength)
			else
				cmd(cmdPref .. " move for " .. OPmoveLength)
			end
		else
			cmd("gps for " .. OPmoveLength)
		end
		if SpawnonMoveButton:GetChecked() and OPMovePlayerInstead:GetChecked() then
			OPSpawn()
		end
		dprint("Moving " .. OPmoveLength .. " units forward.")
	else
		eprint("Invalid Move Length, please check your Object Parameters.")
	end
end

function OPBackward()
	updateDimensions("length")
	if OPmoveLength and OPmoveLength ~= "" and OPmoveLength ~= 0 and OPmoveLength ~= nil then
		if not OPMovePlayerInstead:GetChecked() then
			if isGroupSelected then cmdPref = "gobject group" else cmdPref = "gobject" end
			if RelativeToPlayerToggle:GetChecked() then
				cmd(cmdPref .. " relative back " .. OPmoveLength)
			else
				cmd(cmdPref .. " move back " .. OPmoveLength)
			end
		else
			cmd("gps back " .. OPmoveLength)
		end
		if SpawnonMoveButton:GetChecked() and OPMovePlayerInstead:GetChecked() then
			OPSpawn()
		end
		dprint("Moving " .. OPmoveLength .. " units backwards.")
	else
		eprint("Invalid Move Length, please check your Object Parameters.")
	end
end

function OPLeft()
	updateDimensions("width")
	if OPmoveWidth and OPmoveWidth ~= "" and OPmoveWidth ~= 0 and OPmoveWidth ~= nil then
		if not OPMovePlayerInstead:GetChecked() then
			if isGroupSelected then cmdPref = "gobject group" else cmdPref = "gobject" end
			if RelativeToPlayerToggle:GetChecked() then
				cmd(cmdPref .. " relative left " .. OPmoveWidth)
			else
				cmd(cmdPref .. " move left " .. OPmoveWidth)
			end
		else
			cmd("gps left " .. OPmoveWidth)
		end
		if SpawnonMoveButton:GetChecked() and OPMovePlayerInstead:GetChecked() then
			OPSpawn()
		end
		dprint("Moving " .. OPmoveWidth .. " units left.")
	else
		eprint("Invalid Move Width, please check your Object Parameters.")
	end
end

function OPRight()
	updateDimensions("width")
	if OPmoveWidth and OPmoveWidth ~= "" and OPmoveWidth ~= 0 and OPmoveWidth ~= nil then
		if not OPMovePlayerInstead:GetChecked() then
			if isGroupSelected then cmdPref = "gobject group" else cmdPref = "gobject" end
			if RelativeToPlayerToggle:GetChecked() then
				cmd(cmdPref .. " relative right " .. OPmoveWidth)
			else
				cmd(cmdPref .. " move right " .. OPmoveWidth)
			end
		else
			cmd("gps right " .. OPmoveWidth)
		end
		if SpawnonMoveButton:GetChecked() and OPMovePlayerInstead:GetChecked() then
			OPSpawn()
		end
		dprint("Moving " .. OPmoveWidth .. " units right.")
	else
		eprint("Invalid Move Width, please check your Object Parameters.")
	end
end

function OPUp()
	updateDimensions("height")
	if OPmoveHeight and OPmoveHeight ~= "" and OPmoveHeight ~= 0 and OPmoveHeight ~= nil then
		if not OPMovePlayerInstead:GetChecked() then
			if isGroupSelected then cmdPref = "gobject group" else cmdPref = "gobject" end
			cmd(cmdPref .. " move up " .. OPmoveHeight)
		else
			cmd("gps up " .. OPmoveHeight)
		end
		if SpawnonMoveButton:GetChecked() and OPMovePlayerInstead:GetChecked() then
			OPSpawn()
		end
		dprint("Moving " .. OPmoveHeight .. " units up.")
	else
		eprint("Invalid Move Height, please check your Object Parameters.")
	end
end

function OPDown()
	updateDimensions("height")
	if OPmoveHeight and OPmoveHeight ~= "" and OPmoveHeight ~= 0 and OPmoveHeight ~= nil then
		if not OPMovePlayerInstead:GetChecked() then
			if isGroupSelected then cmdPref = "gobject group" else cmdPref = "gobject" end
			cmd(cmdPref .. " move down " .. OPmoveHeight)
		else
			cmd("gps down " .. OPmoveHeight)
		end
		if SpawnonMoveButton:GetChecked() and OPMovePlayerInstead:GetChecked() then
			OPSpawn()
		end
		dprint("Moving " .. OPmoveHeight .. " units down.")
	else
		eprint("Invalid Move Height, please check your Object Parameters.")
	end
end

function OPSpawn()
	if CheckIfValid(OPObjectIDBox) then
		--SpawnClarifier = true
		--Check if we have an object ID in the object ID box, if we do, spawn it
		if OPScaleObjectToggle:GetChecked() == true and OPScaleObjectToggle:IsEnabled() then
			SendChatMessage(".go spawn " .. tonumber(OPObjectIDBox:GetText()) .. " scale " .. tonumber(OPScaleBox:GetText()))
		else
			SendChatMessage(".go spawn " .. tonumber(OPObjectIDBox:GetText()))
		end
	end
end

function OPTeletoObject()
	if isGroupSelected then cmdPref = "gobject group" else cmdPref = "gobject" end
	cmd(cmdPref .. " go")
	--print("Command was "..cmdPref)
end

function OPScaleObject(scale)
	cmd("gobject scale " .. tonumber(scale))
end

-- Overlay Stuff

function OPOverlaySlider_OnValueChanged(self, value, byUser)
	if byUser then
		if value ~= self.Text:GetText() then
			OPOverlayObject();
		end
	end
	if self:GetName() == "OPOverlaySliderS" then
		self.Text:SetText(100 - self:GetValue())
	else
		self.Text:SetText(self:GetValue())
	end
end

function OPOverlayObject()
	if OPFramesAreLoaded then
		local r = OPOverlaySliderR:GetValue()
		local g = OPOverlaySliderG:GetValue()
		local b = OPOverlaySliderB:GetValue()
		local t = OPOverlaySliderT:GetValue()
		local s = 100 - OPOverlaySliderS:GetValue()
		if isGroupSelected then cmdPref = "gobject group" else cmdPref = "gobject" end
		if OPMasterTable.Options["useOverlayMethod"] == true then
			cmd(cmdPref .. " overlay " .. r .. " " .. g .. " " .. b .. " " .. s .. " " .. t)
		else
			if s == 0 then
				cmd(cmdPref .. " tint " .. r .. " " .. g .. " " .. b .. " " .. t)
			else
				cmd(cmdPref .. " tint " .. r .. " " .. g .. " " .. b .. " " .. s .. " " .. t)
			end
		end
	end
end

function OPUpdateOverlays(restore)
	if restore and restore ~= "APPLY" then
		local r, g, b, a = unpack(restore)
		OPOverlaySliderR:SetValue(r * 100)
		OPOverlaySliderG:SetValue(g * 100)
		OPOverlaySliderB:SetValue(b * 100)
		OPOverlaySliderS:SetValue(a * 100)
		OPOverlayIsControllingColorPicker = false
	else
		local r, g, b = ColorPickerFrame:GetColorRGB()
		OPOverlaySliderR:SetValue(r * 100)
		OPOverlaySliderG:SetValue(g * 100)
		OPOverlaySliderB:SetValue(b * 100)
	end
	if restore == "APPLY" then
		OPOverlayObject()
	end
end

function OPUpdateOverlaysApply()
	if OPOverlayIsControllingColorPicker then
		OPUpdateOverlays("APPLY")
		OPOverlayIsControllingColorPicker = false
	end
end

function OPResetOverlay(applyAfter)
	OPOverlaySliderR:SetValue(100)
	OPOverlaySliderG:SetValue(100)
	OPOverlaySliderB:SetValue(100)
	OPOverlaySliderT:SetValue(0)
	if applyAfter then
		OPOverlayObject();
	end
end

-- Spell Button Stuff

local function updateSpellButton()
	local fontName, fontHeight, fontFlags = OPOverlaySpellButton.Text:GetFont()
	if OPObjectSpell and OPObjectSpell ~= "" and tonumber(OPObjectSpell) ~= 0 then
		OPOverlaySpellButton.Text:SetFont(fontName, 8, fontFlags)
		OPOverlaySpellButton.Text:SetText("Spell\n(" .. OPObjectSpell .. ")")
	else
		OPOverlaySpellButton.Text:SetFont(fontName, 10, fontFlags)
		OPOverlaySpellButton.Text:SetText("Spell")
	end
end

local function canEditLastSelectedObj()
	if C_Epsilon.IsOfficer() or C_Epsilon.IsOwner() then return true end
	if C_Epsilon.IsMember() and (OPLastSelectedObjectData[24] == "1") then return true end
	return false
end

function OPRotateObject(sendToServer)
	if not OPLastSelectedObjectData then
		dprint("Cannot Rotate - No Object Selected Data")
		return
	end
	if not canEditLastSelectedObj() then
		if sendToServer then
			if C_Epsilon.IsMember() then
				SendSystemMessage(("You do not have permission to edit this object (a member may only edit their own objects). (OM: CE=%s, %s)"):format(OPLastSelectedObjectData[24], tostring(OPLastSelectedObjectData[24] == "1")))
			else
				SendSystemMessage("You do not have permission to edit this object (must be a member+, if you were just promoted, try rejoining the phase).")
			end
		end
		return
	end

	--if RotateClarifier == false then
	--RotateClarifier = true
	--end
	if isGroupSelected then
		if rateLimited == true and not sendToServer then return; end
		local RotationZ1 = OPRotationSliderZ:GetValue()
		local RotationZ2 = tonumber(OPLastSelectedGroupRotZ) or tonumber(OPLastSelectedObjectData[11])
		--if RotationZ2 < 0 then RotationZ2 = RotationZ2 + 360 elseif RotationZ2 > 360 then RotationZ2 = RotationZ2 - 360 end
		RotationZ2 = (RotationZ2 % 360) -- Ensure it's within the 0-360 range by modulus instead
		local newRotZ = RotationZ1 - RotationZ2
		--updateRotateClarifierQ(1)
		cmd("gobject group turn " .. newRotZ)
		OPLastSelectedGroupRotZ = RotationZ1
		rateLimited = true
		C_Timer.After(1, function() rateLimited = false end)
	else
		local RotationX = tonumber(OPRotationSliderX:GetValue())
		local RotationY = tonumber(OPRotationSliderY:GetValue())
		local RotationZ = tonumber(OPRotationSliderZ:GetValue())
		local scale = tonumber(OPLastSelectedObjectData[18])
		local localGUIDLow = OPLastSelectedObjectData[22]
		local localGUIDHigh = OPLastSelectedObjectData[23]
		if RotationX < 0 then
			RotationX = 0; dprint("RotX < 0, Made 0");
		end
		if RotationY < 0 then
			RotationY = 0; dprint("RotY < 0, Made 0");
		end
		if RotationZ < 0 then
			RotationZ = 0; dprint("RotZ < 0, Made 0");
		end
		if sendToServer or dontUseClientRotation then
			--updateRotateClarifierQ(1)
			-- from Azar: Fuck Eulers!
			--            GO QUATS!
			local qX, qY, qZ, qW = C_Epsilon.RotateObject(localGUIDLow, localGUIDHigh, RotationX, RotationY, RotationZ, scale)
			if not qX or not qY or not qZ or not qW then
				dprint("Warning: OM Did not receive proper quaternions from the DLL! Fallback on Lua conversions...")
				dprint(false, "Received (DLL): ", qX, qY, qZ, qW)
				qX, qY, qZ, qW = euler_to_quaternion(RotationX, RotationY, RotationZ) -- Fallback on our own code incase the DLL isn't sending proper data
				dprint(false, "Expected (LUA): ", qX, qY, qZ, qW)
			end
			if qX and qY and qZ and qW then
				local rotateCommand = ("gobject rotate %s %s %s %s %s %s %s"):format(
					formatNumber(qX), formatNumber(qY), formatNumber(qZ), formatNumber(qW),
					formatNumber(RotationX), formatNumber(RotationY), formatNumber(RotationZ)
				)
				cmd(rotateCommand)
				dprint(false, "quatsD:", qX, qY, qZ, qW)
			else
				eprint("Warning: Invalid Quats Received. Got: ", qX, qY, qZ, qW)
			end
		else
			C_Epsilon.RotateObject(localGUIDLow, localGUIDHigh, RotationX, RotationY, RotationZ, scale)
			dprint("C_Epsilon.RotateObject(" ..
				localGUIDLow .. "," .. localGUIDHigh .. "," .. RotationX .. "," .. RotationY .. "," .. RotationZ .. ", " .. scale .. ")")
		end
	end
end

function roundToNthDecimal(num, n)
	local mult = 10 ^ (n or 0)
	return math.floor(num * mult + 0.5) / mult
end

function OPSpellButtonFunc(button)
	if button == "LeftButton" then
		StaticPopup_Show("OP_TINTS_SPELL")
	elseif button == "RightButton" then
		if isGroupSelected then cmdPref = "gobject group" else cmdPref = "gobject" end
		cmd(cmdPref .. " spell 0")
	end
end

StaticPopupDialogs["OP_TINTS_SPELL"] = {
	text = STAT_CATEGORY_SPELL,
	button1 = APPLY,
	button2 = CANCEL,
	OnAccept = function(self)
		local spell = self.editBox:GetText()
		if isGroupSelected then cmdPref = "gobject group" else cmdPref = "gobject" end
		if tonumber(spell) ~= nil then
			if tonumber(spell) > 0 then
				cmd(cmdPref .. " spell " .. self.editBox:GetText())
			else
				cmd(cmdPref .. " spell 0")
			end
		else
			cmd(cmdPref .. " spell 0")
		end
	end,
	EditBoxOnTextChanged = function(self)
		if self:GetText() ~= "" then
			self:GetParent().button1:SetText(APPLY)
		else
			self:GetParent().button1:SetText(REMOVE)
		end
	end,
	EditBoxOnEnterPressed = function(self)
		self:GetParent().button1:Click("LeftButton")
	end,
	EditBoxOnEscapePressed = function(self)
		self:GetParent().button2:Click("LeftButton")
	end,
	OnShow = function(self)
		if OPObjectSpell and OPObjectSpell ~= "" and OPObjectSpell ~= nil then
			self.editBox:SetText(OPObjectSpell)
		else
			self.editBox:SetText("")
		end
		if self.editBox:GetText() ~= "" then
			self.button1:SetText(APPLY)
		else
			self.button1:SetText(REMOVE)
		end
		self.editBox:SetNumeric(true)
	end,
	OnHide = function(self)
		self.editBox:SetText("")
	end,
	enterClicksFirstButton = true,
	timeout = 0,
	whileDead = true,
	hideOnEscape = true,
	hasEditBox = true,
}

StaticPopupDialogs["OP_OBJ_VISIBILITY"] = {
	text = "Visibility",
	button1 = APPLY,
	button2 = CANCEL,
	OnAccept = function(self)
		local numberFromUser = self.editBox:GetText()
		if isGroupSelected then cmdPref = "gobject group" else cmdPref = "gobject set" end
		local cmdName = "vis"
		if tonumber(numberFromUser) ~= nil then
			if tonumber(numberFromUser) > 0 then
				cmd(cmdPref .. " " .. cmdName .. " " .. numberFromUser, true)
			else
				cmd(cmdPref .. " " .. cmdName .. " 0", true)
			end
		else
			cmd(cmdPref .. " " .. cmdName .. " 0", true)
		end
	end,
	EditBoxOnTextChanged = function(self)
		if self:GetText() ~= "" then
			self:GetParent().button1:SetText(APPLY)
		else
			self:GetParent().button1:SetText(REMOVE)
		end
	end,
	EditBoxOnEnterPressed = function(self)
		self:GetParent().button1:Click("LeftButton")
	end,
	EditBoxOnEscapePressed = function(self)
		self:GetParent().button2:Click("LeftButton")
	end,
	OnShow = function(self)
		if self.editBox:GetText() ~= "" then
			self.button1:SetText(APPLY)
		else
			self.button1:SetText(REMOVE)
		end
		self.editBox:SetNumeric(true)
	end,
	OnHide = function(self)
		self.editBox:SetText("")
	end,
	enterClicksFirstButton = true,
	timeout = 0,
	whileDead = true,
	hideOnEscape = true,
	hasEditBox = true,
}
StaticPopupDialogs["OP_OBJ_ANIMATION"] = {
	text = "Animation",
	button1 = APPLY,
	button2 = CANCEL,
	OnAccept = function(self)
		local numberFromUser = self.editBox:GetText()
		cmdPref = "gobject"
		local cmdName = "anim"
		if tonumber(numberFromUser) ~= nil then
			if tonumber(numberFromUser) > 0 then
				cmd(cmdPref .. " " .. cmdName .. " " .. numberFromUser, true)
			else
				cmd(cmdPref .. " " .. cmdName .. " 0", true)
			end
		else
			cmd(cmdPref .. " " .. cmdName .. " 0", true)
		end
	end,
	EditBoxOnTextChanged = function(self)
		if self:GetText() ~= "" then
			self:GetParent().button1:SetText(APPLY)
		else
			self:GetParent().button1:SetText(REMOVE)
		end
	end,
	EditBoxOnEnterPressed = function(self)
		self:GetParent().button1:Click("LeftButton")
	end,
	EditBoxOnEscapePressed = function(self)
		self:GetParent().button2:Click("LeftButton")
	end,
	OnShow = function(self)
		if self.editBox:GetText() ~= "" then
			self.button1:SetText(APPLY)
		else
			self.button1:SetText(REMOVE)
		end
		self.editBox:SetNumeric(true)
	end,
	OnHide = function(self)
		self.editBox:SetText("")
	end,
	enterClicksFirstButton = true,
	timeout = 0,
	whileDead = true,
	hideOnEscape = true,
	hasEditBox = true,
}



--- Word Generator

local wordGenCharMap = {
	[48] = "10001083", --0
	[49] = "10001086", --1
	[50] = "10001081", --2
	[51] = "10001082", --3
	[52] = "10001089", --4
	[53] = "10001085", --5
	[54] = "10001079", --6
	[55] = "10001087", --7
	[56] = "10001088", --8
	[57] = "10001084", --9

	[33] = "10001067", -- !
	[47] = "10001068", -- /
	[38] = "10001069", -- &
	[45] = "10001071", -- -
	[43] = "10001075", -- +
	[58] = "10001076", -- :
	[63] = "10001077", -- ?
	[59] = "10001078", -- ;
	[124] = "10001073", -- | -> sword replacement
	[60] = "10001538", -- <
	[62] = "10001537", -- >
}

local startingLetterID = 10001510
local function getCharIndexOffet(char, index)
	local letterID = string.byte(char, index)
	if letterID >= 65 and letterID <= 90 then -- Letter
		letterID = letterID - 65           -- offset to A == 0
		letterID = startingLetterID + letterID
	elseif wordGenCharMap[letterID] then   -- if supported symbol, or number
		letterID = wordGenCharMap[letterID]
	else                                   -- unsupported or space
		--dprint("Character not Supported, or Space, Skipped with Blank Space")
		letterID = 0
	end
	return letterID
end

local wordGenCharOffsets = {
	[getCharIndexOffet("B")] = { x = 0, y = -0.0275 },
	[getCharIndexOffet("E")] = { x = 0, y = 0.01 },
	[getCharIndexOffet("F")] = { x = 0, y = 0.0175 },
	[getCharIndexOffet("H")] = { x = 0, y = 0.01 },
	[getCharIndexOffet("I")] = { x = 0, y = 0.0175 },
	[getCharIndexOffet("J")] = { x = 0, y = -0.0175 },
	[getCharIndexOffet("K")] = { x = 0, y = 0.035 },
	[getCharIndexOffet("L")] = { x = 0, y = 0.0175 },
	[getCharIndexOffet("N")] = { x = 0, y = -0.035 },
	[getCharIndexOffet("O")] = { x = 0, y = -0.035 },
	[getCharIndexOffet("Q")] = { x = 0, y = 0.0025 },
	[getCharIndexOffet("R")] = { x = 0, y = 0.0175 },
	[getCharIndexOffet("S")] = { x = 0, y = -0.0125 },
	[getCharIndexOffet("T")] = { x = 0, y = 0.01 },
	[getCharIndexOffet("U")] = { x = 0, y = 0.0125 },
	[getCharIndexOffet("V")] = { x = 0, y = -0.02 },
	[getCharIndexOffet("W")] = { x = 0, y = 0.03 },
	[getCharIndexOffet("X")] = { x = 0, y = 0.02 },
	[getCharIndexOffet("Z")] = { x = 0, y = -0.03 },
}

local function spawnCharWithOffset(letterID, offsetX)
	if wordGenCharOffsets[letterID] then
		local charData = wordGenCharOffsets[letterID]
		cmd("gobject spawn " .. letterID .. " move left " .. offsetX .. " move up " .. charData.y)
		dprint("object required y-offset by " .. charData.y)
	else
		cmd("gobject spawn " .. letterID .. " move left " .. offsetX)
	end
end

local objectSpawningData = {}
local objectsWaitingToSpawn = false
local function resumeProcessingObjectSpawning()
	if objectsWaitingToSpawn then
		objectsWaitingToSpawn = false
		dprint("WordGen - Resuming Spawning Objects")
		local groupLeaderID = OPLastSelectedObjectData[1]
		local next = next
		if next(objectSpawningData) == nil then
			dprint("No Objects to Spawn?")
		else
			for k in pairs(objectSpawningData) do
				local letterID, offset = objectSpawningData[k][1], objectSpawningData[k][2]
				spawnCharWithOffset(letterID, offset)
				cmd("gobject group add " .. groupLeaderID)
				dprint("Spawned object (" .. letterID .. ") left (" .. offset .. ") to GUID (" .. groupLeaderID .. ")'s group.")
			end
			table.wipe(objectSpawningData)
			dprint("Wiping objectSpawningData table")
		end
	end
end

StaticPopupDialogs["OP_TOOLS_WORDGEN"] = {
	text = "Text Generator",
	subText = ("Enter the text you'd like here, then hit '%s' to spawn.\n\rSupported Symbols: ! / & - + ; : ? | < >")
		:format(START),
	button1 = START,
	button2 = CANCEL,
	OnAccept = function(self)
		local word = string.upper(self.editBox:GetText())
		word = word:gsub("%|%|", "|")
		local letterWidth = 0.75
		local isFirstObjectSpawned = false

		for i = 1, #word do
			local letterID = getCharIndexOffet(word, i)
			if not isFirstObjectSpawned then
				if letterID ~= 0 then
					spawnCharWithOffset(letterID, letterWidth * (i - 1));
					isFirstObjectSpawned = true
				end
			elseif letterID ~= 0 then
				-- add data to objectSpawningData table
				local realLetterWidth = letterWidth * (i - 1)
				table.insert(objectSpawningData, { letterID, realLetterWidth })
				objectsWaitingToSpawn = true
			end
		end
	end,
	EditBoxOnEnterPressed = function(self)
		self:GetParent().button1:Click("LeftButton")
	end,
	EditBoxOnEscapePressed = function(self)
		self:GetParent().button2:Click("LeftButton")
	end,
	OnShow = function(self)
		self.editBox:SetText("")
		self.editBox:SetNumeric(false)
	end,
	OnHide = function(self)
		self.editBox:SetText("")
	end,
	enterClicksFirstButton = true,
	timeout = 0,
	whileDead = true,
	hideOnEscape = true,
	hasEditBox = true,
}

----------- Management Tab
-- Visiblity Button
function OPSetObjVis(num)
	local cmdPref
	if isGroupSelected then cmdPref = "gobject group" else cmdPref = "gobject set" end
	cmd(cmdPref .. " vis " .. num, true)
end

-- Anim Button
function OPSetObjAnim(num)
	cmd("gobject anim " .. num, true)
end

-------------------------------------------------------------------------------
-- Save / Load Pre-set System
-------------------------------------------------------------------------------

function OPShowParamSaveMenu()
	OPMainSaveFrameTitleText:SetText("Save Parameters Pre-set Name:")
	OPMainSaveFrame:Show()
	OPSaveType = "param"
end

function OPShowRotSaveMenu()
	OPMainSaveFrameTitleText:SetText("Save Rotation Pre-set Name:")
	OPMainSaveFrame:Show()
	OPSaveType = "rot"
end

function OPSaveMenuActualSave()
	local opsavename = OPMainSaveFrameEditBox:GetText()
	if opsavename == "" or opsavename == " " or not opsavename:find("%S") then
		opsavename = nil
	end
	if OPSaveType == "param" and opsavename then
		--Do Saving for Param Here
		OPSaveMenuParamSave(opsavename)
	elseif OPSaveType == "rot" and opsavename then
		--Do Saving for Rotation Here
		OPSaveMenuRotSave(opsavename)
	elseif not opsavename then
		message("Please enter a valid name!\n\rNames must contain at least one non-space character.")
	else
		eprint(
			"There was an error saving your pre-set. Please use '/reload' and try again. If this persists, please report it as a bug.")
	end
end

--Para Saving

function OPSaveMenuParamSave(name)
	if OPMasterTable.ParamPresetKeys then
		for k, v in ipairs(OPMasterTable.ParamPresetKeys) do
			if v == name then
				if not confirmPSaveOverwrite then
					message(
						"The name specified conflicts with an already saved Parameter Pre-set name. Hit save again to confirm that you wish to overwrite the previous save.")
					confirmPSaveOverwrite = true
					confirmPSaveOverwriteName = name
					return
				elseif confirmPSaveOverwrite then
					if name == confirmPSaveOverwriteName then
						confirmPSaveOverwrite = false
						OPSaveMenuParamSaveForReal(name, false)
					else
						message(
							"The name specified conflicts with an already saved Parameter Pre-set name. Hit save again to confirm that you wish to overwrite the previous save.")
						confirmPSaveOverwrite = true
						confirmPSaveOverwriteName = name
					end
					return
				else
					eprint(
						"You tried to save with the same name as another Parameter Pre-set save, and an error occurred internally. Please remember how you did this and report it as a bug. Thanks you.")
					return
				end
				return
			end
		end
		OPSaveMenuParamSaveForReal(name, true)
	end
end

function OPSaveMenuParamSaveForReal(name, newKey)
	if newKey then
		table.insert(OPMasterTable.ParamPresetKeys, name)
		newKey = false
	end
	OPMasterTable.ParamPresetContent[name] = {}
	OPMasterTable.ParamPresetContent[name].ObjectID = OPObjectIDBox:GetText()
	OPMasterTable.ParamPresetContent[name].Length = OPLengthBox:GetText()
	OPMasterTable.ParamPresetContent[name].Width = OPWidthBox:GetText()
	OPMasterTable.ParamPresetContent[name].Height = OPHeightBox:GetText()
	OPMasterTable.ParamPresetContent[name].Scale = OPScaleBox:GetText()
	cprint("Saved new Parameter Pre-set with name: " .. name)
	OPMainSaveFrame:Hide()
end

-- Rot Saving

function OPSaveMenuRotSave(name)
	if OPMasterTable.RotPresetKeys then
		for k, v in ipairs(OPMasterTable.RotPresetKeys) do                                                                                              -- Scan all our current saved rotation preset and confirm if we're overwriting one
			if v == name then                                                                                                                           -- if already saved name == new save name
				if not confirmRSaveOverwrite then                                                                                                       -- If this is the first time, we'll do this, otherwise go to the second step
					message(
						"The name specified conflicts with an already saved Rotation Pre-set name. Hit save again confirm that you wish to overwrite the previous save.") -- Warn the user about overwriting a current preset
					confirmRSaveOverwrite = true                                                                                                        -- save that we've already warned them
					confirmRSaveOverwriteName =
						name                                                                                                                            -- keep the name in memory, so that if they close the menu and then save as a new name, we know to recheck again
					return
				elseif confirmRSaveOverwrite then                                                                                                       -- if we're in the confirmation state
					if name == confirmRSaveOverwriteName then                                                                                           -- if the name matches the last warned overwrite name
						confirmRSaveOverwrite = false                                                                                                   -- reset the check so we're back to normal
						OPSaveMenuRotSaveForReal(name, false)                                                                                           -- Save the actual preset yay!
					else                                                                                                                                -- if the name they're trying to save no longer matches the last warned name, we need to re-warn them that this name is also still taken!!
						message(
							"The name specified conflicts with an already saved Rotation Pre-set name. Hit save again to confirm that you wish to overwrite the previous save.")
						confirmRSaveOverwrite = true -- Set the check to true again to make sure
						confirmRSaveOverwriteName =
							name   -- and keep the new name in memory again, just incase they change it again
					end
					return
				else
					eprint(
						"You tried to save with the same name as another Rotation Save, and an error occurred internally. Please remember how you did this and report it as a bug. Thank you.")
					return
				end
				return
			end
		end
		OPSaveMenuRotSaveForReal(name, true)
	end
end

function OPSaveMenuRotSaveForReal(name, newKey)
	if newKey then
		table.insert(OPMasterTable.RotPresetKeys, name)
		newKey = false
	end
	OPMasterTable.RotPresetContent[name] = {}
	OPMasterTable.RotPresetContent[name].RotX = OPRotationSliderX:GetValue()
	OPMasterTable.RotPresetContent[name].RotY = OPRotationSliderY:GetValue()
	OPMasterTable.RotPresetContent[name].RotZ = OPRotationSliderZ:GetValue()
	cprint("Saved new Rotation Pre-set with name: " .. name)
	OPMainSaveFrame:Hide()
end

-- DropDown Load Boxes

local function createFramesHook(numLevels, numButtons)
	for level = 1, numLevels do
		for i = 1, numButtons do
			_G["DropDownList" .. level .. "Button" .. i]:RegisterForClicks("LeftButtonUp", "RightButtonUp")
		end
	end
end

createFramesHook(UIDROPDOWNMENU_MAXLEVELS, UIDROPDOWNMENU_MAXBUTTONS)
hooksecurefunc("UIDropDownMenu_CreateFrames", createFramesHook)

function OP_genStaticDropdownChild(parent, dropdownName, staticList, title, width)
	if not parent or not dropdownName or not staticList then return end;
	if not title then title = "Select" end
	if not width then width = 55 end
	local newDropdown = CreateFrame("Frame", dropdownName, parent, "UIDropDownMenuTemplate")
	newDropdown:SetPoint("CENTER")

	local function newDropdown_Initialize(dropdownName, level)
		for index, value in ipairs(_G[parent:GetName()].staticList) do
			--for index = 1, #dropdownName.staticList do
			if (value.text) then
				value.index = index;
				UIDropDownMenu_AddButton(value, level);
			end
		end
	end

	UIDropDownMenu_Initialize(newDropdown, newDropdown_Initialize, "nope", nil, staticList)
	UIDropDownMenu_SetWidth(newDropdown, width);
	UIDropDownMenu_SetButtonWidth(newDropdown, width + 15)
	UIDropDownMenu_SetSelectedID(newDropdown, 0)
	UIDropDownMenu_JustifyText(newDropdown, "LEFT")
	UIDropDownMenu_SetText(newDropdown, title)
	_G[dropdownName .. "Text"]:SetFontObject("GameFontWhiteTiny2")
	_G[dropdownName .. "Text"]:SetWidth(width - 15)
	local fontName, fontHeight, fontFlags = _G[dropdownName .. "Text"]:GetFont()
	_G[dropdownName .. "Text"]:SetFont(fontName, 6)

	newDropdown:GetParent():SetWidth(newDropdown:GetWidth())
	newDropdown:GetParent():SetHeight(newDropdown:GetHeight())
end

function OPCreateLoadDropDownMenus()
	--Param Loading
	local paramPresetDropSelect = CreateFrame("Frame", "paramPresetDropDownMenu", OPPanel2, "UIDropDownMenuTemplate")
	paramPresetDropSelect:SetPoint("TOP", OPParamSaveButton, "BOTTOM", 2, -2)
	paramPresetDropSelect:SetScript("OnEnter", function()
		if OPMasterTable.Options["showTooltips"] == true then
			GameTooltip:SetOwner(paramPresetDropSelect, "ANCHOR_LEFT")
			paramPresetDropSelect.Timer = C_Timer.NewTimer(0.5, function()
				GameTooltip:SetText("Select a previously saved parameter pre-set to load.", nil, nil, nil, nil, true)
				GameTooltip:AddLine(" ")
				GameTooltip:AddLine(
					"Right-Click a saved Pre-set to Delete it. You must do this twice to confirm deletion to avoid mis-clicks.",
					1, 1, 1, true)
				GameTooltip:Show()
			end)
		end
	end)
	paramPresetDropSelect:SetScript("OnLeave", function()
		GameTooltip_Hide()
		if paramPresetDropSelect.Timer then paramPresetDropSelect.Timer:Cancel() end
	end)

	local function ParamPresetOnClick(self)
		local button = GetMouseButtonClicked()
		if button == "LeftButton" then
			UIDropDownMenu_SetSelectedID(paramPresetDropSelect, self:GetID())
			if self.value ~= "Select a Preset" then
				_OPMTPPC = OPMasterTable.ParamPresetContent[self.value]
				if _OPMTPPC.ObjectID and tostring(_OPMTPPC.ObjectID) ~= "" and tostring(_OPMTPPC.ObjectID) ~= "0" then
					OPObjectIDBox:SetText(OPMasterTable.ParamPresetContent[self.value].ObjectID)
				end
				if _OPMTPPC.Length and tostring(_OPMTPPC.Length) ~= "" and tostring(_OPMTPPC.Length) ~= "0" then
					OPLengthBox:SetText(OPMasterTable.ParamPresetContent[self.value].Length)
				end
				if _OPMTPPC.Width and tostring(_OPMTPPC.Width) ~= "" and tostring(_OPMTPPC.Width) ~= "0" then
					OPWidthBox:SetText(OPMasterTable.ParamPresetContent[self.value].Width)
				end
				if _OPMTPPC.Height and tostring(_OPMTPPC.Height) ~= "" and tostring(_OPMTPPC.Height) ~= "0" then
					OPHeightBox:SetText(OPMasterTable.ParamPresetContent[self.value].Height)
				end
				if _OPMTPPC.Scale and tostring(_OPMTPPC.Scale) ~= "" and tostring(_OPMTPPC.Scale) ~= "0" then
					OPScaleBox:SetText(OPMasterTable.ParamPresetContent[self.value].Scale)
				end
				dprint("Tried to load Param Pre-set: " .. self.value)
			end
		elseif button == "RightButton" then
			SlashCmdList.OPDELPARAM(self.value)
			dprint("Trying to delete Param Pre-Set (" .. self.value .. ") from Right-Click Trigger")
		end
	end
	local function paramPresetInitialize(self, level)
		local info = UIDropDownMenu_CreateInfo()
		for k, v in ipairs(OPMasterTable.ParamPresetKeys) do
			info = UIDropDownMenu_CreateInfo()
			info.text = v
			info.value = v
			info.func = ParamPresetOnClick
			UIDropDownMenu_AddButton(info, level)
		end
	end
	UIDropDownMenu_Initialize(paramPresetDropSelect, paramPresetInitialize)
	UIDropDownMenu_SetWidth(paramPresetDropSelect, 55);
	UIDropDownMenu_SetButtonWidth(paramPresetDropSelect, 70)
	UIDropDownMenu_SetSelectedID(paramPresetDropSelect, 0)
	UIDropDownMenu_JustifyText(paramPresetDropSelect, "LEFT")
	UIDropDownMenu_SetText(paramPresetDropSelect, "Load")
	paramPresetDropDownMenuText:SetFontObject("GameFontWhiteTiny2")
	local fontName, fontHeight, fontFlags = paramPresetDropDownMenuText:GetFont()
	paramPresetDropDownMenuText:SetFont(fontName, 6)

	-- Rot Loading
	local rotPresetDropSelect = CreateFrame("Frame", "rotPresetDropDownMenu", OPPanel4Rotation, "UIDropDownMenuTemplate")
	rotPresetDropSelect:SetPoint("LEFT", OPRotSaveButton, "RIGHT", -15, -1)
	rotPresetDropSelect:SetScript("OnEnter", function()
		if OPMasterTable.Options["showTooltips"] == true then
			GameTooltip:SetOwner(rotPresetDropSelect, "ANCHOR_LEFT")
			rotPresetDropSelect.Timer = C_Timer.NewTimer(0.5, function()
				GameTooltip:SetText("Select a previously saved rotation pre-set to load.", nil, nil, nil, nil, true)
				GameTooltip:AddLine(" ")
				GameTooltip:AddLine(
					"Right-Click a saved Pre-set to Delete it. You must do this twice to confirm deletion to avoid mis-clicks.",
					1, 1, 1, true)
				GameTooltip:Show()
			end)
		end
	end)
	rotPresetDropSelect:SetScript("OnLeave", function()
		GameTooltip_Hide()
		if rotPresetDropSelect.Timer then rotPresetDropSelect.Timer:Cancel() end
	end)

	local function RotPresetOnClick(self)
		local button = GetMouseButtonClicked()
		if button == "LeftButton" then
			UIDropDownMenu_SetSelectedID(rotPresetDropSelect, self:GetID())
			if self.value ~= "Select a Preset" then
				local origx, origy, origz = OPRotationSliderX:GetValue(), OPRotationSliderY:GetValue(),
					OPRotationSliderZ:GetValue()
				_OPMTRPC = OPMasterTable.RotPresetContent[self.value]
				if _OPMTRPC.RotX and tostring(_OPMTRPC.RotX) ~= "" and tonumber(_OPMTRPC.RotX) >= 0 then
					OPRotationSliderX:SetValue(tonumber(OPMasterTable.RotPresetContent[self.value].RotX))
				end
				if _OPMTRPC.RotY and tostring(_OPMTRPC.RotY) ~= "" and tonumber(_OPMTRPC.RotY) >= 0 then
					OPRotationSliderY:SetValue(tonumber(OPMasterTable.RotPresetContent[self.value].RotY))
				end
				if _OPMTRPC.RotZ and tostring(_OPMTRPC.RotZ) ~= "" and tonumber(_OPMTRPC.RotZ) >= 0 then
					OPRotationSliderZ:SetValue(tonumber(OPMasterTable.RotPresetContent[self.value].RotZ))
				end
				dprint("Tried to load Rot Pre-set: " .. self.value)
				dprint(origx .. " | " .. origy .. " | " .. origz)

				OPRotateObject(true);
				OPIMFUCKINGROTATINGDONTSPAMME = true
				OPClearRotateChatFilter()
				--dprint("Loaded the same as whatever it is currently, so we're gonna apply the rotation anyways!")
			end
		elseif button == "RightButton" then
			SlashCmdList.OPDELROT(self.value)
			dprint("Trying to delete Rotation Pre-Set (" .. self.value .. ") from Right-Click Trigger")
		end
	end
	local function rotPresetInitialize(self, level)
		local info = UIDropDownMenu_CreateInfo()
		for k, v in ipairs(OPMasterTable.RotPresetKeys) do
			info = UIDropDownMenu_CreateInfo()
			info.text = v
			info.value = v
			info.func = RotPresetOnClick
			UIDropDownMenu_AddButton(info, level)
		end
	end
	UIDropDownMenu_Initialize(rotPresetDropSelect, rotPresetInitialize)
	UIDropDownMenu_SetWidth(rotPresetDropSelect, 65)
	UIDropDownMenu_SetButtonWidth(rotPresetDropSelect, 80)
	UIDropDownMenu_SetSelectedID(rotPresetDropSelect, 0)
	UIDropDownMenu_JustifyText(rotPresetDropSelect, "LEFT")
	UIDropDownMenu_SetText(rotPresetDropSelect, "Load")
	rotPresetDropDownMenuText:SetFontObject("GameFontWhiteTiny2")
	local fontName, fontHeight, fontFlags = rotPresetDropDownMenuText:GetFont()
	rotPresetDropDownMenuText:SetFont(fontName, 6)
end

-------------------------------------------------------------------------------
-- Message Filters
-------------------------------------------------------------------------------

function OPClearRotateChatFilter()
	if RotateClarifier then
		OPIMFUCKINGROTATINGDONTSPAMME = false
		C_Timer.After(0.25, OPClearRotateChatFilterDontSpamIfStillRotating);
	end
end

function OPClearRotateChatFilterDontSpamIfStillRotating()
	if OPIMFUCKINGROTATINGDONTSPAMME ~= true then
		RotateClarifier = false
	end
end

local function checkForFilter(Message)
	local clearmsg = gsub(Message, "|cff%x%x%x%x%x%x", "");
	local clearmsg = clearmsg:gsub("|r", "")

	-- GObject Rotate Message Filter
	if RotateClarifier and Message:gsub("|.........", ""):find("rotated") then
		--updateRotateClarifierQ(-1)
		dprint("RotateClarifier Caught Message")
		return true

		-- GObject Spawn Message Filter
	elseif SpawnClarifier and clearmsg:find("[Spawned gameobject|Map:|Syntax|was not found|You do not have]") then
		if clearmsg:find("Spawned gameobject") then
			dprint("SpawnClarifier Caught SPAWNED Message")
			return true
		elseif clearmsg:find("Map:") then
			SpawnClarifier = false
			dprint("SpawnClarifier Caught MAP Message")
			return true
		elseif clearmsg:find("[Syntax|was not found|You do not have]") then
			SpawnClarifier = false
			dprint("SpawnClarifier Caught Syntax or Failure, Disabled.")
		end

		-- GObject Scale Message Filter
	elseif ScaleClarifier and clearmsg:find("[Syntax|was not found|You do not have|Incorrect|GameObject .* has been set to scale]") then
		if clearmsg:find("Syntax") or clearmsg:find("was not found") or clearmsg:find("You do not have") or clearmsg:find("Incorrect") then
			ScaleClarifier = false
			dprint("ScaleClarifier Caught Syntax or Failure, Disabled.")
			return false
		elseif clearmsg:find("GameObject .* has been set to scale") then
			ScaleClarifier = false
			dprint("ScaleClarifier Caught SCALE Message")
			return true
		end
	else
		dprint("No Clarifier Caught this, so lets let it pass")
		return false
	end
end

local isWaitingForGroupData
local function OMChatFilter(Self, Event, Message)
	local clearmsg = gsub(Message, "|cff%x%x%x%x%x%x", "");
	local clearmsg = clearmsg:gsub("|r", "");

	---------- Group Selection Detection ----------

	if clearmsg:find("Selected gameobject group") or clearmsg:find("Spawned gameobject group") or clearmsg:find("Spawned blueprint") or clearmsg:find("added %d+ objects to gameobject group") or clearmsg:find("added the gameobject .* to gameobject group") then
		updateGroupSelected(true)
		dprint("isGroupSelected true")
		local groupID = nil

		if clearmsg:find("Selected") or clearmsg:find("Spawned") then
			isWaitingForGroupData = true
			dprint("Listening for Group Data")
		elseif OPRotAutoUpdate:GetChecked() then
			groupID = clearmsg:match("with leader.*DBGUID: (%d+)%)")
			if groupID then
				print(groupID, clearmsg)
				cmd("gobject group sel " .. groupID)
				dprint("Added objects to a group, re-selecting group to capture the rotation..")
			else
				cprint(
					"ALERT: Objects added to group with Auto-Rotate enabled, but we couldn't get the group data. Please re-select the group.")
			end
		end
	end

	if isWaitingForGroupData then
		local yaw = nil
		if clearmsg:find("Yaw/Turn:") then
			yaw = tonumber(clearmsg:match("Pitch: %-?%d*%.%d*, Roll: %-?%d*%.%d*, Yaw/Turn: (%-?%d*%.%d*)"))
		elseif clearmsg:find("with orientation:") then
			yaw = tonumber(clearmsg:match("orientation: (%-?%d*%.%d*)"))
		end
		if yaw then
			if OPRotAutoUpdate:GetChecked() then
				OPRotationSliderZ:SetValueStep(0.0001)
				OPRotationSliderZ:SetValue(yaw)
				dprint("Set Slider Z to " .. yaw)
			end
			OPLastSelectedGroupRotZ = yaw
			isWaitingForGroupData = false
			dprint("Group Data collected, not listening.")
		end
	end

	---------- Auto Update Rotation CAPTURES ----------

	if OPRotAutoUpdate:GetChecked() == true and not RotateClarifier then -- Is the AutoUpdate Rot enabled? (Check if RotateClarifier is enabled - if it is, we don't do anything as to not impact the sliders functioning normally)
		if clearmsg:find("You have rotated group .* [%X%Y%Z]+") then  -- Did we get a rotated object message?
			dontFuckingRotate = true                                  -- Stop the sliders from actually causing a rotation
			dprint("Group Rotate detected")

			if clearmsg:find("Z:") then -- Matching for Group Rotation Message which is always relative..
				local z = tonumber(clearmsg:match("Z: (%-?%d*%.%d*)"))
				if z < 0 then z = z + 360 elseif z > 360 then z = z - 360 end
				OPRotationSliderZ:SetValueStep(0.0001)
				local newYaw = OPRotationSliderZ:GetValue() + z

				-- if newYaw < 0 then newYaw = newYaw + 360 elseif newYaw > 360 then newYaw = newYaw - 360 end -- replaced with whiles
				while newYaw < 0 do newYaw = newYaw + 360 end
				while newYaw > 360 do newYaw = newYaw - 360 end
				OPRotationSliderZ:SetValue(newYaw)
				dprint("Set Slider Z to " .. newYaw)
			end
			dontFuckingRotate = false -- Allow sliders to cause rotation again
		end
	end


	------------------------------------------------


	---- Handling Hiding Messages to avoid Spam ----
	-- // Nope - SILENT SENDING NOW!
	--[[
	if ObjectClarifier or SpawnClarifier or ScaleClarifier or RotateClarifier then
		--Check to see if we sent a request and we don't want to see messages
		if OPShowMessagesToggle:GetChecked() ~= true then
			if (checkForFilter(Message)) then
				return true
			end
		else
			checkForFilter(Message)
		end
	end
	--]]
end

--Apply filter
ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", OMChatFilter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_ACHIEVEMENT", OMChatFilter);
ChatFrame_AddMessageEventFilter("CHAT_MSG_BN_WHISPER_INFORM", OMChatFilter);
ChatFrame_AddMessageEventFilter("CHAT_MSG_COMBAT_XP_GAIN", OMChatFilter);
ChatFrame_AddMessageEventFilter("CHAT_MSG_COMBAT_HONOR_GAIN", OMChatFilter);
ChatFrame_AddMessageEventFilter("CHAT_MSG_COMBAT_FACTION_CHANGE", OMChatFilter);
ChatFrame_AddMessageEventFilter("CHAT_MSG_TRADESKILLS", OMChatFilter);
ChatFrame_AddMessageEventFilter("CHAT_MSG_OPENING", OMChatFilter);
ChatFrame_AddMessageEventFilter("CHAT_MSG_PET_INFO", OMChatFilter);
ChatFrame_AddMessageEventFilter("CHAT_MSG_COMBAT_MISC_INFO", OMChatFilter);
ChatFrame_AddMessageEventFilter("CHAT_MSG_BG_SYSTEM_HORDE", OMChatFilter);
ChatFrame_AddMessageEventFilter("CHAT_MSG_BG_SYSTEM_ALLIANCE", OMChatFilter);
ChatFrame_AddMessageEventFilter("CHAT_MSG_BG_SYSTEM_NEUTRAL", OMChatFilter);
ChatFrame_AddMessageEventFilter("CHAT_MSG_TARGETICONS", OMChatFilter);
ChatFrame_AddMessageEventFilter("CHAT_MSG_BN_CONVERSATION_NOTICE", OMChatFilter);

-------------------------------------------------------------------------------
-- Receiving GObject Info on Select / Object Update
-------------------------------------------------------------------------------

--[[
1 DB_guid / 2 entry / 3 name / 4 filedataid / 5 x / 6 y / 7 z / 8 rx / 9 ry / 10 rz / 11 Orientation / 12 HasTint / 13 red / 14 green / 15 blue / 16 alpha / 17 spell / 18 scale / 19 Group Leader ID / 20 objType / 21 saturation / 22 RealGUID_Low / 23 RealGUID_High

77283554 827585 7af_shaman_rockslab_a02.m2 1329986 -433.999 135.15 41.3903 0 0 0 0 0 100 100 100 0 0 1 0 5
]]

local events = {
	CHAT_MSG_ADDON = function(self, event, ...)
		local prefix = select(1, ...)
		if prefix == "EPSILON_OBJ_INFO" or prefix == "EPSILON_OBJ_SEL" then -- If OBJ_INFO or OBJ_SEL message, process the data to our 'cache'
			local objdetails = select(2, ...)
			local sender = select(4, ...)
			C_Timer.After(0, function()
				local self = table.concat({ UnitFullName("PLAYER") }, "-")
				if sender == self or string.gsub(self, "%s+", "") then
					updateGroupSelected(false)
					dprint("isGroupSelected false")

					OPLastSelectedObjectData = { strsplit(strchar(31), objdetails) } --[[@as SelectedObjectData]]

					local guid, entry, name, filedataid, x, y, z, orientation, rx, ry, rz, HasTint, red, green, blue, alpha, spell, scale, groupLeader, objType, saturation, rGUIDLow, rGUIDHigh, canEdit = unpack(
						OPLastSelectedObjectData)
					HasTint = tonumber(HasTint)

					OPLastSelectedGroupRotZ = nil
					if OPMasterTable.Options["debug"] then
						print("GOBINFO:", unpack(OPLastSelectedObjectData))
					end
					resumeProcessingObjectSpawning()

					-- Update Object
					if OPParamAutoUpdateButton:GetChecked() then
						if prefix == "EPSILON_OBJ_SEL" then
							OPGetObject("RightButton")
						else
							OPScaleBox:SetText(tonumber(scale))
						end
					end

					-- Update Manager Tab
					local shortname = name:gsub(".*/+", "")
					dprint("Name: " .. name)
					dprint("Shortname: " .. shortname)
					OPPanel2.SelectedObjName:SetText(shortname)
					OPPanel4Manager.SelectedObjName:SetText(shortname)
					local fontName, fontHeight, fontFlags = OPPanel4Manager.SelectedObjName:GetFont()
					OPPanel4Manager.SelectedObjName:SetFont(fontName, 10, fontFlags)
					while OPPanel4Manager.SelectedObjName:GetStringWidth() > OPPanel4Manager:GetWidth() - 5 do
						local fontName, fontHeight, fontFlags = OPPanel4Manager.SelectedObjName:GetFont()
						OPPanel4Manager.SelectedObjName:SetFont(fontName, fontHeight - 1, fontFlags)
						dprint("Setting Manager Object Text Font Size: " .. fontHeight - 1)
					end
					--OPPanel4Manager.GroupLeaderIndicator.Entry:SetText(groupLeader)

					-- update extended info
					OPPanelPopout.ObjName.Text:SetText(shortname)
					local fontName, fontHeight, fontFlags = OPPanelPopout.ObjName.Text:GetFont()
					OPPanelPopout.ObjName.Text:SetFont(fontName, 10, fontFlags)
					while OPPanelPopout.ObjName.Text:GetNumLines() > 2 do
						local fontName, fontHeight, fontFlags = OPPanelPopout.ObjName.Text:GetFont()
						OPPanelPopout.ObjName.Text:SetFont(fontName, fontHeight - 1, fontFlags)
						dprint("Setting Selected Object Panel Object Name Font Size: " .. fontHeight - 1)
					end
					OPPanelPopout.ObjEntry.Text:SetText(entry)
					OPPanelPopout.ObjScale.Text:SetText(scale)
					OPPanelPopout.ObjType.Text:SetText(objType .. " - " .. ObjectTypes[tonumber(objType)])
					if not isWMO[tonumber(objType)] then
						OPPanelPopout.ObjDimensions.Text:SetText("Loading...")
						OPPanelPopout.ObjPreview.Scene.Actor:SetSpellVisualKit()
						OPPanelPopout.ObjPreview.Scene.Actor:SetAlpha(1)
						OPPanelPopout.ObjPreview.Scene.Actor:SetModelByFileID(filedataid)
						OPPanelPopout.ObjPreview.Scene.Actor:Show()
					else
						OPPanelPopout.ObjPreview.Scene.Actor:SetModelByFileID(1)
						OPPanelPopout.ObjPreview.Scene.Actor:Hide()
						OPPanelPopout.ObjDimensions.Text:SetText("No Data for WMOs")
					end
					--OPPanelPopout.ObjState.Text:SetText(entry)
					--OPPanelPopout.ObjAnim.Text:SetText(objType.." - "..ObjectTypes[tonumber(objType)])

					-- Update Tints & Spell
					--if OPTintAutoUpdateButton:GetChecked() then
					if OPOverlayAutoUpdateButton:GetChecked() then
						if not OPOverlayDragging then
							if HasTint == 1 then -- using normal tint
								OPOverlayUseOverlayCheckbutton:SetChecked(false)
								OPMasterTable.Options["useOverlayMethod"] = false
							elseif HasTint == 2 then -- using overlay
								OPOverlayUseOverlayCheckbutton:SetChecked(true)
								OPMasterTable.Options["useOverlayMethod"] = true
							end
							OPOverlaySliderR:SetValue(red)
							OPOverlaySliderG:SetValue(green)
							OPOverlaySliderB:SetValue(blue)
							OPOverlaySliderT:SetValue(alpha)
							if saturation then
								OPOverlaySliderS:SetValue(100 - saturation)
								dprint("Updating Overlay Sliders, saturation: " .. saturation)
							end
						end


						if spell and spell ~= "" and tonumber(spell) > 0 then
							OPObjectSpell = spell
							updateSpellButton()
						else
							OPObjectSpell = nil
							updateSpellButton()
						end
					end

					-- Update Rotations
					if OPRotAutoUpdate:GetChecked() and not RotateClarifier then
						dprint(false, "received (srv): ", rx, ry, rz)

						-- Normalize to 0-360
						rx = rx % 360
						ry = ry % 360
						rz = rz % 360

						OPRotationSliderX:SetValueStep(0.0001)
						OPRotationSliderY:SetValueStep(0.0001)
						OPRotationSliderZ:SetValueStep(0.0001)
						OPRotationSliderX:SetValue(rx)
						OPRotationSliderY:SetValue(ry)
						OPRotationSliderZ:SetValue(rz)
					end
				else
					eprint("Illegal Sender (" .. sender .. ") | (Expected:" .. self .. ")")
				end
			end)
			dprint("Caught " .. prefix .. " prefix")
			dprint(false, event, ...)
		end
	end,
	PLAYER_LOGIN = function(self, event, ...)
		C_ChatInfo.RegisterAddonMessagePrefix("EPSILON_OBJ_INFO")
		C_ChatInfo.RegisterAddonMessagePrefix("EPSILON_OBJ_SEL")
		self:UnregisterEvent(event)
	end,
	PLAYER_ENTERING_WORLD = function(self, event, initial, reload, ...)
		if reload then
			sendAddonCmd("gobject move up 0", nil, false)
		end
	end,
	SCENARIO_UPDATE = function(self, event, ...)
		OPLastSelectedObjectData = nil
		-- TODO: REFRESH UI HERE TO DISABLE IF NON-MEMBER / NON-OFFICER, OR NO OBJ SELECTED
	end,
}

local function Addon_OnEvent(self, event, ...)
	if events[event] then events[event](self, event, ...) end
end
local f = CreateFrame("Frame")
f:SetScript("OnEvent", Addon_OnEvent)
for k, v in pairs(events) do
	f:RegisterEvent(k)
end

-------------------------------------------------------------------------------
-- Slash Command Handlers
-------------------------------------------------------------------------------

function SlashCmdList.OM_SHOWCLOSE()
	if not OPMainFrame:IsShown() then
		OPMainFrame:Show()
	else
		OPMainFrame:Hide()
	end
end

SLASH_OPDEBUG1, SLASH_OPDEBUG2 = '/opdebug', '/omdebug';
function SlashCmdList.OPDEBUG(msg, editbox) -- 4.
	if msg:find("clarifier") then
		dprint(true,
			"RotateClarifier = " ..
			tostring(RotateClarifier) ..
			" | SpawnClarifier = " ..
			tostring(SpawnClarifier) ..
			" | ObjectClarifier = " .. tostring(ObjectClarifier) .. " | ScaleClarifier = " .. tostring(ScaleClarifier))
	else
		OPMasterTable.Options["debug"] = not OPMasterTable.Options["debug"]
		dprint(true, "Object Mover Debug Set to: " .. tostring(OPMasterTable.Options["debug"]))
		if OPMasterTable.Options["debug"] and OPMainFrame:GetAlpha() < 1 then
			if OPMainFrame.Timer then OPMainFrame.Timer:Cancel() end
			UIFrameFadeIn(OPMainFrame, 0.3, OPMainFrame:GetAlpha(), 1)
		end
	end
end

SLASH_OPDELPARAM1, SLASH_OPDELPARAM2 = '/opdelparam', '/omdelparam';
function SlashCmdList.OPDELPARAM(msg, editbox) -- 4.
	local deleted
	if editbox then
		if msg then
			for k, v in ipairs(OPMasterTable.ParamPresetKeys) do
				if msg == v then
					table.remove(OPMasterTable.ParamPresetKeys, k)
					OPMasterTable.ParamPresetContent[msg] = nil
					cprint("Deleting Parameter Pre-set: " .. msg)
					deleted = true
				end
			end
		else
			cprint("SYNTAX: '/opdelparam [name of Parameter Pre-set to delete, Case Sensitive]'")
		end
	else
		if OPDeleteParamByMenuConfirm then
			for k, v in ipairs(OPMasterTable.ParamPresetKeys) do
				if msg == v then
					table.remove(OPMasterTable.ParamPresetKeys, k)
					OPMasterTable.ParamPresetContent[msg] = nil
					cprint("Deleting Parameter Pre-set: " .. msg)
					deleted = true
				end
			end
			OPDeleteParamByMenuConfirm = nil
		else
			cprint("Please Right-Click the Menu Option again to confirm deleting Parameter Preset: " .. msg)
			OPDeleteParamByMenuConfirm = true
		end
	end
	if not deleted and not OPDeleteParamByMenuConfirm then
		cprint(msg .. " is not a saved Param Pre-set.")
	end
	deleted = nil
end

SLASH_OPDELROT1, SLASH_OPDELROT2 = '/opdelrot', '/omdelrot';
function SlashCmdList.OPDELROT(msg, editbox) -- 4.
	local deleted
	if editbox then
		if msg then
			for k, v in ipairs(OPMasterTable.RotPresetKeys) do
				if msg == v then
					table.remove(OPMasterTable.RotPresetKeys, k)
					OPMasterTable.RotPresetContent[msg] = nil
					cprint("Deleting Rotation Pre-set: " .. msg)
					deleted = true
				end
			end
		else
			cprint("SYNTAX: '/opdelparam [name of Parameter Pre-set to delete, Case Sensitive]'")
		end
	else
		if OPDeleteRotByMenuConfirm then
			for k, v in ipairs(OPMasterTable.RotPresetKeys) do
				if msg == v then
					table.remove(OPMasterTable.RotPresetKeys, k)
					OPMasterTable.RotPresetContent[msg] = nil
					cprint("Deleting Rotation Pre-set: " .. msg)
					deleted = true
				end
			end
			OPDeleteRotByMenuConfirm = nil
		else
			cprint("Please Right-Click the Menu Option again to confirm deleting Rotation Preset: " .. msg)
			OPDeleteRotByMenuConfirm = true
		end
	end
	if not deleted and not OPDeleteRotByMenuConfirm then
		cprint(msg .. " is not a saved Rotation Pre-set.")
	end
	deleted = nil
end
