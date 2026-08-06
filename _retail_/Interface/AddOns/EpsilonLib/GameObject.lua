local EpsilonLib, EpsiLib = ...;


EpsiLib.GameObject._log = {}
EpsiLib.GameObject._log._last = nil
EpsiLib.GameObject._log._selected = nil
EpsiLib.GameObject._gobs = {}
EpsiLib.GameObject._groups = {}

-- Utils
local toboolean = EpsiLib.Utils.ToBoolean
local tonumberOrFalse = EpsiLib.Utils.ToNumberOrFalse
local formatNumber = EpsiLib.Utils.TrimNumber

local EpsiSystemBlue = CreateColorFromHexString("FF00CCFF")
local EpsiSystemOrange = CreateColorFromHexString("FFFF9900")

local baseCommand = "gobject"
local groupCommand = "gobject group"

local function getCommandByContext(isGroup)
	if isGroup then
		return groupCommand
	else
		return baseCommand
	end
end

local function sysMsg(text)
	SendSystemMessage(EpsiSystemBlue:WrapTextInColorCode("EpsilonLib [GameObject]") .. ": " .. (text and text or "ERROR") .. "|r")
end

local function canSpawn(vocal)
	local hasPerm = C_Epsilon.IsMember() or C_Epsilon.IsOfficer() or C_Epsilon.IsOwner()
	if vocal and not hasPerm then
		sysMsg(EpsiSystemOrange:WrapTextInColorCode("You do not have permission to spawn objects here."))
	end
	return hasPerm
end

local function safeCallback(cb, ...)
	if cb then return cb(...) end
end

local WMO_TYPES = { [14] = true, [15] = true, [33] = true, [38] = true, [43] = true, [54] = true }
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
	[12] = "AREADAMAGE",
	[13] = "CAMERA",
	[14] = "MAP_OBJECT (WMO)",
	[15] = "MAP_OBJ_TRANSPORT (WMO)",
	[16] = "DUEL_ARBITER",
	[17] = "FISHINGNODE",
	[18] = "RITUAL",
	[19] = "MAILBOX",
	[20] = "DO_NOT_USE",
	[21] = "GUARDPOST",
	[22] = "SPELLCASTER",
	[23] = "MEETINGSTONE",
	[24] = "FLAGSTAND",
	[25] = "FISHINGHOLE",
	[26] = "FLAGDROP",
	[27] = "MINI_GAME",
	[28] = "DO_NOT_USE_2",
	[29] = "CONTROL_ZONE",
	[30] = "AURA_GENERATOR",
	[31] = "DUNGEON_DIFFICULTY",
	[32] = "BARBER_CHAIR",
	[33] = "DESTRUCTIBLE_BUILDING (WMO)",
	[34] = "GUILD_BANK",
	[35] = "TRAPDOOR",
	[36] = "NEW_FLAG",
	[37] = "NEW_FLAG_DROP",
	[38] = "GARRISON_BUILDING (WMO)",
	[39] = "GARRISON_PLOT",
	[40] = "CLIENT_CREATURE",
	[41] = "CLIENT_ITEM",
	[42] = "CAPTURE_POINT (WMO)",
	[43] = "PHASEABLE_MO",
	[44] = "GARRISON_MONUMENT",
	[45] = "GARRISON_SHIPMENT",
	[46] = "GARRISON_MONUMENT_PLAQUE",
	[47] = "ITEM_FORGE",
	[48] = "UI_LINK",
	[49] = "KEYSTONE_RECEPTACLE",
	[50] = "GATHERING_NODE",
	[51] = "CHALLENGE_MODE_REWARD",
	[52] = "MULTI",
	[53] = "SIEGEABLE_MULTI",
	[54] = "SIEGEABLE_MO (WMO)",
	[55] = "PVP_REWARD",
	[56] = "PLAYER_CHOICE_CHEST",
	[57] = "LEGENDARY_FORGE",
	[58] = "GARR_TALENT_TREE",
	[59] = "WEEKLY_REWARD_CHEST",
	[60] = "CLIENT_MODEL"
}

local function shortenFileName(path)
	-- Extract the file name from the full path
	local fileName = path:match("([^\\/]+)$")
	fileName = fileName:gsub("%[.*%]", "") -- Remove any brackets and their contents
	return fileName and strtrim(fileName:match("(.+)%..+$") or fileName) or path
end

local function getFullPhaseGobGUID(guid, phase)
	if not phase then phase = C_Epsilon.GetPhaseId() end
	return phase .. "@" .. guid
end

local function _isSelected(obj, errorMsg)
	if not obj then return false end
	local selected = EpsiLib.GameObject._log._selected
	if selected and selected == obj then
		return true
	else
		if errorMsg then
			sysMsg(errorMsg)
		end
		return false
	end
end

local dimDetectSceneFrame = CreateFrame("ModelScene")
Mixin(dimDetectSceneFrame, ModelSceneMixin)
dimDetectSceneFrame.objActor = dimDetectSceneFrame:CreateActor(nil, "ModelSceneActorTemplate")
dimDetectSceneFrame.objActor.scene = dimDetectSceneFrame

dimDetectSceneFrame.objActor.queue = {}
dimDetectSceneFrame.objActor._log = {}

---Request an object size, running the callback when it's done
---@param fileID integer
---@param objType integer
---@param callback function
---@return boolean? success -- Returns true if the request was successfully queued or ran, false if it was a WMO and not queued
function dimDetectSceneFrame:GetObjectSize(fileID, objType, callback)
	-- invalid fileID
	if not fileID or type(fileID) ~= "number" then
		return error("Cannot call GetObjectSize without a valid fileID.")
	end

	if not objType or type(objType) ~= "number" then
		return error("Cannot call GetObjectSize without a valid objType. This is an anti-crash measure. Fix your call.")
	end

	if not callback or type(callback) ~= "function" then
		return error("Cannot call GetObjectSize without a valid callback function. Where do you think the data from this goes? It's async.")
	end

	if WMO_TYPES[objType] then
		if callback then callback(false) end
		return false
	end

	-- this fileID has already been logged, run the callback immediately with the size
	if self.objActor._log[fileID] then
		if callback then callback(self.objActor._log[fileID]) end
		return true
	end

	local cbObj = { fid = fileID, callback = callback }
	tinsert(self.objActor.queue, cbObj)

	self.objActor:Next()

	return true
end

function dimDetectSceneFrame.objActor:Next()
	if #self.queue == 0 then
		-- queue empty, exit recursion
		return
	end

	local nextObj = tremove(self.queue, 1)

	self.currentFileID = nextObj.fid
	self.loading = true
	self.curCallback = nextObj.callback
	self:SetModelByFileID(nextObj.fid)
end

dimDetectSceneFrame.objActor.onModelLoadedCallback = function(self)
	local mX1, mY1, mZ1, mX2, mY2, mZ2 = self:GetActiveBoundingBox()
	local mX = (mX1 or 0) - (mX2 or 0)
	local mY = (mY1 or 0) - (mY2 or 0)
	local mZ = (mZ1 or 0) - (mZ2 or 0)

	local size = EpsiLib.API.MathU.Vector3.new(abs(mX), abs(mY), abs(mZ))

	local fileID = self:GetModelFileID()

	self._log[fileID] = size

	if self.curCallback then
		self.curCallback(size) -- Call the callback with the size
		self.curCallback = nil -- destroy just to be safe
	end

	self:ClearModel()
	self.loading = false

	self:Next() -- Process the next object in the queue if needed (will short circuit if queue is empty)
end


-- Get the size of an object - takes a full object class or FileID & embeds the size on the object at the end
local function GetAndEmbedObjectSize(obj, callback)
	if obj:IsWMO() then return safeCallback(callback, nil) end -- just exit now for WMOs. We have several wmo anti-crash checks along the way, but better safe than crash.
	obj.size = false
	dimDetectSceneFrame:GetObjectSize(obj.fileID, obj.objType, function(size)
		if size then
			obj.size = size
		else
			sysMsg("Failed to get size for object with fileID: " .. tostring(obj.fileID))
		end
	end)
end

local GameObjectMeta = {}

function GameObjectMeta:GetSize(callback)
	if self.size then
		safeCallback(callback, self.size)
		return self.size
	else
		GetAndEmbedObjectSize(self, callback)
		return true
	end
end

function GameObjectMeta:Select()
	EpsiLib.AddonCommands._SendAddonCommand("gobject select " .. self.guid)
end

function GameObjectMeta:Unselect()
	EpsiLib.GameObject:Unselect(false)
end

function GameObjectMeta:SelectGroup()
	--[[
	local groupLeader = self.groupLeader
	if groupLeader == true then groupLeader = self.guid end
	local command = "gobject group select " .. self.groupLeader
	print(command)
	EpsiLib.AddonCommands._SendAddonCommand(command, nil, true)
	--]]
	local groupLeader = self.groupLeader
	if self:IsSelected() then groupLeader = nil end
	EpsiLib.GameObject:SelectGroup(groupLeader)
end

function GameObjectMeta:IsSelected()
	return EpsiLib.GameObject._log._selected == self
end

function GameObjectMeta:CanEdit(vocal)
	local hasPerm = C_Epsilon.IsOfficer() or C_Epsilon.IsOwner() or (C_Epsilon.IsMember() and (self and self.canEdit))
	if vocal and not hasPerm then
		sysMsg(EpsiSystemOrange:WrapTextInColorCode("You do not have permission to edit this object."))
	end
	return hasPerm
end

function GameObjectMeta:IsWMO()
	local id = tonumber(self.objType)
	return WMO_TYPES[id] or false
end

function GameObjectMeta:GetGUID()
	return self.guid
end

function GameObjectMeta:GetFullGUID()
	return self.phaseGUID or getFullPhaseGobGUID(self.guid, self.phase)
end

function GameObjectMeta:GetEntry()
	return self.entry
end

function GameObjectMeta:GetType()
	local typeName = ObjectTypes[self.objType]
	return self.objType, typeName or "UNKNOWN"
end

function GameObjectMeta:GetScale()
	return self.scale or 1
end

function GameObjectMeta:GetName(short)
	return short and self.sname or self.name
end

-- Helper function to find the number of decimal places
local function getDecimalDepth(numStr)
	local _, decimalPos = numStr:find("%.")
	if not decimalPos then
		return 0
	end
	return #numStr - decimalPos
end

-- Main function to get a random value with matched precision
local function getRandomVal(minStr, maxStr)
	-- Determine maximum precision
	local depthMin = getDecimalDepth(minStr)
	local depthMax = getDecimalDepth(maxStr)
	local precision = math.max(depthMin, depthMax)

	-- Convert string bounds to numbers
	local minNum = tonumber(minStr)
	local maxNum = tonumber(maxStr)

	-- Generate a random float between the two bounds
	local randomFloat = minNum + (math.random() * (maxNum - minNum))

	-- Format output string to match required decimal depth
	local formatSpecifier = "%." .. precision .. "f"
	return string.format(formatSpecifier, randomFloat)
end

function GameObjectMeta:SetScale(val, randomMax)
	if not self:IsSelected() then
		sysMsg("You must select the GameObject before changing its scale.");
		return;
	end

	if not self:CanEdit(true) then return end

	if not val or tonumber(val) <= 0 then
		sysMsg("Invalid scale value. Must be a positive number.");
		return;
	end

	if randomMax then -- calculate random
		if tonumber(randomMax) <= 0 then
			sysMsg("Invalid random scale max value. Must be a positive number.");
			return;
		end
		val = getRandomVal(val, randomMax)
	end

	EpsiLib.AddonCommands._SendAddonCommand(("gobject scale %s"):format(val), function(success, messages)
		if not success then
			sysMsg("Failed to set scale for GameObject: " .. self.guid .. " with message: " .. messages[1])
		else
			--sysMsg("Set scale for GameObject: " .. self.guid .. " to " .. self.scale)
		end
	end, false)
end

function GameObjectMeta:GoTo()
	if self.isDeleted or not self:IsSelected() then
		EpsiLib.AddonCommands._SendAddonCommand(("worldport %s %s %s %s %s"):format(self.transform.position.x, self.transform.position.y, self.transform.position.z, self.map, self.transform.rotation.z))
	else
		EpsiLib.AddonCommands._SendAddonCommand(("gobject go %s"):format(self.guid))
	end
end

---Move GameObject to a given vector position
---@param vector any
---@param relative any
function GameObjectMeta:MoveTo(vector)
	if not self:CanEdit(true) then return end

	EpsiLib.AddonCommands._SendAddonCommand("gobject move coords " .. self.guid .. " " .. vector.x .. " " .. vector.y .. " " .. vector.z, "GUILD");
end

---Move GameObject by given string movements (i.e., "up 10", "forward 5")
---@param ... string
function GameObjectMeta:Move(...)
	if not self:CanEdit(true) then return end

	local args = { ... }
	if #args == 0 then return end

	EpsiLib.AddonCommands._SendAddonCommand("gobject move " .. self.guid .. " " .. table.concat(args, " "), function(success, messages)
		if not success then
			-- TODO - Clean this up
			sysMsg("Failed to move GameObject: " .. self.guid .. " with message: " .. messages[1])
		end
	end, false)
end

---Move GameObject relative by given string movements (i.e., "up 10", "forward 5")
---@param ... string
function GameObjectMeta:MoveRelative(...)
	if not self:CanEdit(true) then return end

	local args = { ... }
	if #args == 0 then return end

	EpsiLib.AddonCommands._SendAddonCommand("gobject relative " .. self.guid .. " " .. table.concat(args, " "), function(success, messages)
		if not success then
			-- TODO - Clean this up
			sysMsg("Failed to move relative GameObject: " .. self.guid .. " with message: " .. messages[1])
		end
	end, false)
end

function GameObjectMeta:MoveWorld(dir1, dist1, ...)
	if not self:CanEdit(true) then return end

	if not dir1 and not tonumber(dist1) then return error("Must provide at least one valid direction & distance") end
	if not self:IsSelected() then
		sysMsg("You must select the GameObject before being able to move (world relative) it.")
		return
	end

	local distances = { tonumber(dist1) }
	local directions = { dir1 }
	local dirXdistStrs = { strjoin(" ", dir1, dist1) }
	local _lastDir
	if ... then
		for i, arg in ipairs({ ... }) do
			if i % 2 == 1 then -- direction
				tinsert(directions, arg)
				_lastDir = arg -- save the dir to use with the next dist
			else      -- distance
				tinsert(distances, arg)
				tinsert(dirXdistStrs, strjoin(" ", _lastDir, arg))
			end
		end
	end

	-- Move as if facing north, using player's facing for math, outputting relative directions
	local playerFacing = GetPlayerFacing() or 0
	-- We'll convert all movement into a net X/Y vector, rotate it by -playerFacing, then decompose into relative directions

	local dx, dy = 0, 0
	for i = 1, #directions do
		local dir = directions[i]
		local dist = distances[i]
		if dir == "forward" then
			dx = dx + 0
			dy = dy + dist
		elseif dir == "back" then
			dx = dx + 0
			dy = dy - dist
		elseif dir == "left" then
			dx = dx - dist
			dy = dy + 0
		elseif dir == "right" then
			dx = dx + dist
			dy = dy + 0
		elseif dir == "forward_left" then
			local d = dist / math.sqrt(2)
			dx = dx - d
			dy = dy + d
		elseif dir == "forward_right" then
			local d = dist / math.sqrt(2)
			dx = dx + d
			dy = dy + d
		elseif dir == "back_left" then
			local d = dist / math.sqrt(2)
			dx = dx - d
			dy = dy - d
		elseif dir == "back_right" then
			local d = dist / math.sqrt(2)
			dx = dx + d
			dy = dy - d
		end
	end

	-- Rotate vector by -playerFacing
	local cos = math.cos(-playerFacing)
	local sin = math.sin(-playerFacing)
	local rx = dx * cos - dy * sin
	local ry = dx * sin + dy * cos

	-- Decompose into relative forward/back and left/right
	local rel = {}
	if math.abs(ry) > 0.0001 then
		if ry > 0 then
			table.insert(rel, ("forward %.4f"):format(ry))
		else
			table.insert(rel, ("back %.4f"):format(-ry))
		end
	end
	if math.abs(rx) > 0.0001 then
		if rx > 0 then
			table.insert(rel, ("right %.4f"):format(rx))
		else
			table.insert(rel, ("left %.4f"):format(-rx))
		end
	end

	local finalDist = table.concat(rel, " ")
	if finalDist ~= "" then
		EpsiLib.AddonCommands._SendAddonCommand("gobject relative " .. finalDist, function(success, messages)
			if not success then
				sysMsg("Failed move (world) GameObject: " .. self.guid .. " with message: " .. messages[1])
			else
				sysMsg("Moved (world) GameObject: " .. self.guid)
			end
		end, false)
	end
end

function GameObjectMeta:Rotate(x, y, z, virtual)
	if not self:CanEdit(true) then return end

	if not x then x = self.transform.rotation.x end
	if not y then y = self.transform.rotation.y end
	if not z then z = self.transform.rotation.z end

	if virtual then
		C_Epsilon.RotateObject(self.rGUIDLow, self.rGUIDHigh, x, y, z, self.scale)
	else
		local qX, qY, qZ, qW = C_Epsilon.RotateObject(self.rGUIDLow, self.rGUIDHigh, x, y, z, self.scale)
		if qX and qY and qZ and qW then
			local rotateCommand = ("gobject rotate %s %s %s %s %s %s %s"):format(
				formatNumber(qX), formatNumber(qY), formatNumber(qZ), formatNumber(qW),
				formatNumber(x), formatNumber(y), formatNumber(z)
			)
			EpsiLib.AddonCommands._SendAddonCommand(rotateCommand)
		else
			error("EpsiLib Failed Quat Check on Gob:Rotate()")
		end
	end
end

function GameObjectMeta:Pitch(val, exact)
	if not self:CanEdit(true) then return end

	if not val then error("Cannot pitch by nothing.") end
	if exact then
		local cur = self.transform.rotation.y
		local desired = val
		local diff = desired - cur
		val = diff
	end
	EpsiLib.AddonCommands._SendAddonCommand("gobject pitch " .. val)
	self.transform.rotation.y = val
end

function GameObjectMeta:Roll(val, exact)
	if not self:CanEdit(true) then return end

	if not val then error("Cannot roll by nothing.") end
	if exact then
		local cur = self.transform.rotation.x
		local desired = val
		local diff = desired - cur
		val = diff
	end
	EpsiLib.AddonCommands._SendAddonCommand("gobject roll " .. val)
	self.transform.rotation.x = val
end

function GameObjectMeta:Turn(val, exact)
	if not self:CanEdit(true) then return end

	if not val then error("Cannot turn by nothing (use Face instead).") end
	if exact then
		self:Face(val)
		return
	end
	EpsiLib.AddonCommands._SendAddonCommand("gobject turn " .. val)
	self.transform.rotation.z = val
end

function GameObjectMeta:Face(val)
	if not self:CanEdit(true) then return end

	if val == 0 or val == "0" then val = "north" end -- face 0 doesn't work? Stupid.
	if type(val) == "number" then
		EpsiLib.AddonCommands._SendAddonCommand("gobject face " .. val)
		self.transform.rotation.z = val
	elseif type(val) == "string" then
		EpsiLib.AddonCommands._SendAddonCommand("gobject face " .. val)
	else
		EpsiLib.AddonCommands._SendAddonCommand("gobject turn")
		self.transform.rotation.z = math.deg(GetPlayerFacing())
	end
end

function GameObjectMeta:GetPosString()
	return self.transform.position:ToString();
end

function GameObjectMeta:Tint(r, g, b, a, s)
	if not self:CanEdit(true) then return end

	if not self:IsSelected() then
		sysMsg("You must select the GameObject before applying a tint.");
		return;
	end

	local command = (("gobject tint %s %s %s %s %s"):format(r, g, b, s, a))
	EpsiLib.AddonCommands._SendAddonCommand(command, function(success, messages)
		if not success then
			sysMsg("Failed to tint GameObject: " .. self.guid .. " with message: " .. messages[1])
		else
			--sysMsg("Tinted GameObject: " .. self.guid)
		end
	end, false)
end

function GameObjectMeta:Overlay(r, g, b, a, s)
	if not self:CanEdit(true) then return end

	if not self:IsSelected() then
		sysMsg("You must select the GameObject before applying an overlay.");
		return;
	end
	local command = (("gobject overlay %s %s %s %s %s"):format(r, g, b, s, a))
	EpsiLib.AddonCommands._SendAddonCommand(command, function(success, messages)
		if not success then
			sysMsg("Failed to apply overlay to GameObject: " .. self.guid .. " with message: " .. messages[1])
		else
			--sysMsg("Applied overlay to GameObject: " .. self.guid)
		end
	end, false)
end

function GameObjectMeta:SetColor(type, r, g, b, a, s)
	if not type then error("Must provide a type for gob:SetColor(type, r, g, b, a, s)") end
	type = type:lower()

	if type == "tint" then
		self:Tint(r, g, b, a, s)
	elseif type == "overlay" then
		self:Overlay(r, g, b, a, s)
	else
		error("Invalid type for gob:SetColor(type, r, g, b, a, s). Must be 'tint' or 'overlay'.")
	end
end

function GameObjectMeta:Copy(dir, val, count, entry)
	if not canSpawn(true) then return end

	local command
	if not dir or val then
		command = "gobject copy"
	else
		command = ("gobject copy %s %s %s %s"):format(dir, val, count or 1, entry or "")
	end
	EpsiLib.AddonCommands._SendAddonCommand(command, function(success, messages)
		if not success then
			sysMsg("Failed to copy GameObject: " .. self.guid .. " with message: " .. messages[1])
		else
			--sysMsg("Copied GameObject: " .. self.guid)
		end
	end, false)
end

function GameObjectMeta:SpawnDuplicate()
	if not canSpawn(true) then return end

	EpsiLib.AddonCommands._SendAddonCommand("gobject spawn " .. self.entry, function(success, messages)
		if not success then
			sysMsg("Failed to spawn duplicate GameObject: " .. self.guid .. " with message: " .. messages[1])
		else
			--sysMsg("Spawned duplicate GameObject: " .. self.guid)
		end
	end, false)
end

function GameObjectMeta:DeepCopy(samePos)
	if not canSpawn(true) then return end

	local gobData = self

	if samePos and select(4, C_Epsilon.GetPosition()) ~= gobData.map then
		local text = ("You need to be on the same map as the object to copy at the same position (map id %s).\n\rYou can teleport there now & then attempt to copy-in-place again after."):format(gobData.map)
		EpsiLib.Utils.GenericDialogs.CustomConfirmation({
			text = text,
			acceptText = "Teleport",
			showAlert = true,
			callback = function()
				EpsiLib.AddonCommands._SendAddonCommand(("worldport %s %s %s %s %s"):format(gobData.transform.position.x, gobData.transform.position.y, gobData.transform.position.z, gobData.map,
					gobData.transform.rotation.z))
			end
		})
		return;
	end

	local mainSpawnCommand
	if samePos then
		mainSpawnCommand = ("gobject spawn %s scale %s posx %s posy %s posz %s pitch %s roll %s face north turn %s"):format(gobData.entry, gobData.scale, gobData.transform.position.x,
			gobData.transform.position.y, gobData.transform.position.z, gobData.transform.rotation.y, gobData.transform.rotation.x, gobData.transform.rotation.z)
	else
		mainSpawnCommand = ("gobject spawn %s scale %s pitch %s roll %s face north turn %s"):format(gobData.entry, gobData.scale, gobData.transform.rotation.y, gobData.transform.rotation.x, gobData.transform.rotation.z)
	end

	if gobData.HasTint then
		local tintCommand
		if gobData.HasTint == 1 then
			tintCommand = (" tint %s %s %s"):format(gobData.color.red, gobData.color.blue, gobData.color.green, gobData.color.alpha)
		else
			tintCommand = (" overlay %s %s %s"):format(gobData.color.red, gobData.color.blue, gobData.color.green, gobData.color.saturation, gobData.color.alpha)
		end
		mainSpawnCommand = mainSpawnCommand .. tintCommand
	elseif gobData.spell and gobData.spell ~= 0 then
		mainSpawnCommand = mainSpawnCommand .. " spell " .. gobData.spell
	end

	local commands = { mainSpawnCommand }

	if gobData.groupLeader and gobData.groupLeader ~= 0 then
		table.insert(commands, ("gobject group add %s"):format(gobData.groupLeader))
	end

	EpsiLib.AddonCommands._SendAddonChain(commands, function(success, messages)
		if not success then
			sysMsg("Failed to copy GameObject: " .. gobData.guid .. " with message: " .. messages[1])
		else
			gobData.isRestored = true
			sysMsg("Deep-Copied GameObject: " .. gobData.guid)
		end
	end, false)
end

function GameObjectMeta:Delete()
	if not self:CanEdit(true) then return end

	EpsiLib.AddonCommands._SendAddonCommand("gobject delete " .. self.guid, function(success, messages)
		if not success then
			sysMsg("Failed to delete GameObject: " .. self.guid .. " with message: " .. messages[1])
		else
			self.isDeleted = true
			sysMsg("Deleted GameObject: " .. self.guid)
		end
	end, false)
end

function GameObjectMeta:Restore()
	if not canSpawn(true) then return end

	local gobData = self
	if not self.isDeleted then
		sysMsg("GameObject: " .. self.guid .. " is not deleted, cannot restore.");
		return;
	end
	if select(4, C_Epsilon.GetPosition()) ~= gobData.map then
		local text = ("You need to be on the same map the object was deleted from to restore it (map id %s).\n\rYou can teleport there now & then attempt to restore again after."):format(gobData.map)
		EpsiLib.Utils.GenericDialogs.CustomConfirmation({
			text = text,
			acceptText = "Teleport",
			showAlert = true,
			callback = function()
				EpsiLib.AddonCommands._SendAddonCommand(("worldport %s %s %s %s %s"):format(gobData.transform.position.x, gobData.transform.position.y, gobData.transform.position.z, gobData.map,
					gobData.transform.rotation.z))
			end
		})
		return;
	end

	local mainSpawnCommand = ("gobject spawn %s scale %s posx %s posy %s posz %s pitch %s roll %s face north turn %s"):format(gobData.entry, gobData.scale, gobData.transform.position.x,
		gobData.transform.position.y, gobData.transform.position.z, gobData.transform.rotation.y, gobData.transform.rotation.x, gobData.transform.rotation.z)
	if gobData.HasTint then
		local tintCommand
		if gobData.HasTint == 1 then
			tintCommand = (" tint %s %s %s"):format(gobData.color.red, gobData.color.blue, gobData.color.green, gobData.color.alpha)
		else
			tintCommand = (" overlay %s %s %s"):format(gobData.color.red, gobData.color.blue, gobData.color.green, gobData.color.saturation, gobData.color.alpha)
		end
		mainSpawnCommand = mainSpawnCommand .. tintCommand
	elseif gobData.spell and gobData.spell ~= 0 then
		mainSpawnCommand = mainSpawnCommand .. " spell " .. gobData.spell
	end

	local commands = { mainSpawnCommand }

	if gobData.groupLeader and gobData.groupLeader ~= 0 then
		table.insert(commands, ("gobject group add %s"):format(gobData.groupLeader))
	end

	EpsiLib.AddonCommands._SendAddonChain(commands, function(success, messages)
		if not success then
			sysMsg("Failed to restore GameObject: " .. gobData.guid .. " with message: " .. messages[1])
		else
			gobData.isRestored = true
			sysMsg("Restored GameObject: " .. gobData.guid)
		end
	end, false)
end

--#endregion
--#region GameObject Group Meta
--      overlay           scale      spell     tint     turn         visibility     zcopy
local GameObjectGroupMeta = {}

function GameObjectGroupMeta:SetLeader(gob) -- promote
	-- select the object to set as leader
	-- promote it
end

function GameObjectGroupMeta:GetLeader()
	return self.leaderObject or EpsiLib.GameObject._gobs[getFullPhaseGobGUID(self.leaderGUID, self.phase)]
end

function GameObjectGroupMeta:Select()

end

function GameObjectGroupMeta:Unselect()
	EpsiLib.GameObject:Unselect(true)
end

GameObjectGroupMeta.IsSelected = GameObjectMeta.IsSelected

function GameObjectGroupMeta:CanEdit(vocal)
	local leader = self.leaderObject
	local hasPerm = C_Epsilon.IsOfficer() or C_Epsilon.IsOwner() or (C_Epsilon.IsMember() and (leader and leader.canEdit))
	if vocal and not hasPerm then
		sysMsg(EpsiSystemOrange:WrapTextInColorCode("You do not have permission to edit the leader object of this group."))
	end
	return hasPerm
end

function GameObjectGroupMeta:GetName(short)
	local leader = self:GetLeader()
	if leader then
		return "<GRP>" .. leader:GetName(short)
	end
	return "<GRP> " .. (self.leaderGUID or "Unknown")
end

function GameObjectGroupMeta:Add(gob)
	-- remember our group leader,
	-- select the gob we want to add
	-- '.gob group add <leaderGUID>' to add it
end

function GameObjectGroupMeta:Remove(gob)
	-- select the gob to remove
	-- '.gob group remove' to remove it
end

function GameObjectGroupMeta:Activate()
	if not _isSelected(self, "You must select the GameObject Group before activating it.") then return end
end

function GameObjectGroupMeta:AddNear(dist)
	if not _isSelected(self, "You must select the GameObject Group before adding nearby objects to it.") then return end
end

function GameObjectGroupMeta:Clear(confirm)
	if not _isSelected(self, "You must select the GameObject Group before clearing it.") then return end
	if not confirm then
		EpsiLib.Utils.GenericDialogs.CustomConfirmation({
			text = "Are you sure you want to clear the GameObject Group? This will remove all GameObjects from the group.",
			acceptText = "Clear",
			showAlert = true,
			callback = function()
				self:Clear(true)
			end
		})
		return
	end
end

function GameObjectGroupMeta:Copy(dir, dist) -- dir, value
	if not _isSelected(self, "You must select the GameObject Group before copying it.") then return end
end

function GameObjectGroupMeta:Delete(confirm)
	if not _isSelected(self, "You must select the GameObject Group before deleting it.") then return end
	if not confirm then
		EpsiLib.Utils.GenericDialogs.CustomConfirmation({
			text = "Are you sure you want to delete the GameObject Group? This will delete all GameObjects in the group.",
			acceptText = "Delete",
			showAlert = true,
			callback = function()
				self:Delete(true)
			end
		})
		return
	end
end

function GameObjectGroupMeta:GoTo()
	-- accepts ID
end

function GameObjectGroupMeta:MergeInto(group)
	-- merge our current group into the given group
	-- '.gob group merge <leaderGUID>'
end

function GameObjectGroupMeta:Move(dir, dist)
	if not _isSelected(self, "You must select the GameObject Group before moving it.") then return end
end

function GameObjectGroupMeta:MoveRelative(dir, dist)
	if not _isSelected(self, "You must select the GameObject Group before moving it.") then return end
end

function GameObjectGroupMeta:Overlay(r, g, b, a, s)
	if not _isSelected(self, "You must select the GameObject Group before applying an overlay.") then return end
	if not self:CanEdit(true) then return end

	local command = (("gobject overlay %s %s %s %s %s"):format(r, g, b, s, a))
	EpsiLib.AddonCommands._SendAddonCommand(command, function(success, messages)
		if not success then
			sysMsg("Failed to apply overlay to GameObject: " .. self.guid .. " with message: " .. messages[1])
		else
			--sysMsg("Applied overlay to GameObject: " .. self.guid)
		end
	end, false)
end

function GameObjectGroupMeta:Tint(r, g, b, a, s)
	if not _isSelected(self, "You must select the GameObject Group before applying a tint.") then return end
	if not self:CanEdit(true) then return end

	local command = (("gobject group tint %s %s %s %s %s"):format(r, g, b, s, a))
	EpsiLib.AddonCommands._SendAddonCommand(command, function(success, messages)
		if not success then
			sysMsg("Failed to tint GameObject Group: " .. self.guid .. " with message: " .. messages[1])
		end
	end, false)
end

function GameObjectGroupMeta:SetColor(type, r, g, b, a, s)
	if not type then error("Must provide a type for group:SetColor(type, r, g, b, a, s)") end
	type = type:lower()

	if type == "tint" then
		self:Tint(r, g, b, a, s)
	elseif type == "overlay" then
		self:Overlay(r, g, b, a, s)
	else
		error("Invalid type for group:SetColor(type, r, g, b, a, s). Must be 'tint' or 'overlay'.")
	end
end

function GameObjectGroupMeta:SetScale(val, randomMax)
	if not _isSelected(self, "You must select the GameObject Group before scaling it.") then return end

	if not self:CanEdit(true) then return end

	if not val or tonumber(val) <= 0 then
		sysMsg("Invalid group scale value. Must be a positive number.");
		return;
	end

	if randomMax then -- calculate random
		if tonumber(randomMax) <= 0 then
			sysMsg("Invalid group random scale max value. Must be a positive number.");
			return;
		end
		val = getRandomVal(val, randomMax)
	end
	local command = ("gobject group scale %s"):format(val)
	EpsiLib.AddonCommands._SendAddonCommand(command, function(success, messages)
		if not success then
			sysMsg("Failed to set scale for GameObject Group with message: " .. messages[1])
		else
			--sysMsg("Set scale for GameObject Group to " .. value)
		end
	end, false)
end

function GameObjectGroupMeta:GetScale()
	return self.scale or 1
end

function GameObjectGroupMeta:Turn(dir)
	if not _isSelected(self, "You must select the GameObject Group before turning it.") then return end
	local command = ("gobject group turn %s"):format(dir)
	EpsiLib.AddonCommands._SendAddonCommand(command, function(success, messages)
		if not success then
			sysMsg("Failed to turn GameObject Group with message: " .. messages[1])
		else
			--sysMsg("Set scale for GameObject Group to " .. value)
		end
	end, false)
end

function GameObjectGroupMeta:Rotate(_, _, z)
	if not _isSelected(self, "You must select the GameObject Group before turning it.") then return end
	self:Turn(z)
end

--#region GameObject API

function EpsiLib.GameObject:Select(name, id)
	local command = "gobject select "
	if name then
		command = command .. name
	end
	if id then
		command = command .. id
	end

	EpsiLib.AddonCommands._SendAddonCommand(command, function(success, messages)
		if not success then
			sysMsg(("Failed to select GameObject (%s) with message: " .. messages[1]):format(name or id or "nearest"))
		else
			--sysMsg("Selected GameObject: " .. (name or guid or entry))
		end
	end)
end

function EpsiLib.GameObject:Unselect(group)
	if group == nil then
		-- double check if we have a selected group, and if so, unselect it instead of the object
		if self._log._selected and self._log._selected.isGroup then
			group = true
		end
	end
	EpsiLib.AddonCommands._SendAddonCommand(getCommandByContext(group) .. " unselect", function(success, messages)
		if not success then
			sysMsg("Failed to unselect GameObject with message: " .. messages[1])
		else
			-- Clear the selected object
			self._log._selected = nil
			EpsiLib.EventManager:Fire("EPSILON_OBJ_UPDATE", "UNSEL", nil)
		end
	end)
end

function EpsiLib.GameObject:Get(id)
	-- forgot to ever implement this?
end

function EpsiLib.GameObject:GetSelected()
	return self._log._selected
end

function EpsiLib.GameObject:GetLast()
	return self._log._last
end

function EpsiLib.GameObject:SelectGroup(guid)
	local command = "gobject group select"
	if guid and ((type(guid) == "string") or (type(guid) == "number")) then command = command .. " " .. guid end

	EpsiLib.AddonCommands._SendAddonCommand(command, function(success, messages)
		if not success then
			sysMsg("Failed to select GameObject Group with message: " .. messages[1])
		else
			--sysMsg("Selected GameObject Group")
		end
	end)
end

function EpsiLib.GameObject:SetGroupSelected(group)
	if not group or type(group) ~= "table" then
		return error("SetGroupSelected must be called with a valid group object.")
	end
	self._log._selected = group
end

function EpsiLib.GameObject:IsGroupSelected()
	return self._log._selected and self._log._selected.isGroup
end

function EpsiLib.GameObject:_addToLog(obj, selected)
	--Check if this gob already exists in our gobs list, and be sure to remove it from the log if so
	if self._gobs[obj.phaseGUID] then
		tDeleteItem(self._log, self._gobs[obj.phaseGUID])
	end

	-- Add the object to the log, along with updating it's gobs entry just to be sure it's recorded there
	table.insert(self._log, obj)
	self._gobs[obj.phaseGUID] = obj
	self._log._last = obj

	if selected then
		self._log._selected = obj
	end

	EpsiLib.GameObject.GobLogFrame.Update()
end

local function forceLoadLeaderGob(group, leader)
	EpsiLib.AddonCommands._SendAddonChain({ "gobject select " .. leader, "gobject group select " .. leader }, function()
		group.leaderObject = EpsiLib.GameObject._gobs[getFullPhaseGobGUID(leader, group.phase)]
	end)
end

function EpsiLib.GameObject._createGroup(leader, phase)
	if not leader then error("_createGroup requires leader.") end
	if not phase then phase = tonumber(C_Epsilon.GetPhaseId()) end
	local fullGUID = getFullPhaseGobGUID(leader, phase)
	local leaderGob = EpsiLib.GameObject._gobs[fullGUID]

	local group = {}
	setmetatable(group, { __index = GameObjectGroupMeta })

	group.isGroup = true
	group.phase = phase
	group.leaderGUID = leader
	group.leaderObject = leaderGob

	EpsiLib.GameObject._groups[fullGUID] = group

	if not leaderGob then
		forceLoadLeaderGob(group, leader)
	end
	return group --[[@as GameObjectGroupClass]]
end

function EpsiLib.GameObject._newGroup(leader)
	local phase = tonumber(C_Epsilon.GetPhaseId())
	local group = EpsiLib.GameObject._groups[getFullPhaseGobGUID(leader, phase)] or EpsiLib.GameObject._createGroup(leader)

	return group --[[@as GameObjectGroupClass]]
end

function EpsiLib.GameObject._create(id, phase)
	local object = {}
	-- Add meta for default function handlers to function as a class
	setmetatable(object, { __index = GameObjectMeta })

	if id then
		if not phase then phase = C_Epsilon.GetPhaseId() end
		object.guid = tonumber(id)
		object.phase = tonumber(phase)
		EpsiLib.GameObject._gobs[getFullPhaseGobGUID(id, phase)] = object
	end

	return object --[[@as GameObjectClass]]
end

--								guid, entry, name, fileID, x, y, z, orientation, rx, ry, rz, HasTint, red, green, blue, alpha, spell, scale, groupLeader, objType, saturation, rGUIDLow, rGUIDHigh, canEdit
function EpsiLib.GameObject._new(guid, entry, name, fileID, x, y, z, orientation, rx, ry, rz, HasTint, red, green, blue, alpha, spell, scale, groupLeader, objType, saturation, rGUIDLow, rGUIDHigh,
								 canEdit)
	guid = tonumber(guid)
	local phase = tonumber(C_Epsilon.GetPhaseId())
	local full_guid = getFullPhaseGobGUID(guid, phase)
	if not guid then return error("_new must have GUID") end
	local object = EpsiLib.GameObject._gobs[full_guid] or EpsiLib.GameObject._create(guid, phase) -- Re-use the object it it already exists, or generate a new one

	object.phase = phase
	object.guid = tonumber(guid)
	object.phaseGUID = full_guid
	object.entry = tonumber(entry)
	object.name = name
	object.sname = shortenFileName(name)
	object.fileID = tonumber(fileID)
	object.transform = object.transform or
		{} -- WARNING: position & rotation are regenerated Vector3 each time an object is updated; they are NOT stable references. Always use the object or transform table as your base reference instead.
	object.transform.position = EpsiLib.API.MathU.Vector3.new(x, y, z)
	object.transform.rotation = EpsiLib.API.MathU.Vector3.new(rx, ry, rz)
	object.orientation = tonumber(orientation)
	object.HasTint = (tonumber(HasTint) ~= 0 and tonumber(HasTint)) or false
	object.color = object.color or {}
	object.color.red = tonumber(red)
	object.color.green = tonumber(green)
	object.color.blue = tonumber(blue)
	object.color.alpha = tonumber(alpha)
	object.color.saturation = tonumber(saturation)
	object.spell = tonumberOrFalse(spell)
	object.scale = tonumber(scale)
	object.groupLeader = tonumberOrFalse(groupLeader)
	object.objType = tonumber(objType)
	object.rGUIDLow = rGUIDLow
	object.rGUIDHigh = rGUIDHigh
	object.canEdit = toboolean(canEdit)
	object.map = select(4, C_Epsilon.GetPosition()) -- we assume map ID from the player position
	object.time = time()                         -- record the time it was selected

	GetAndEmbedObjectSize(object)

	return object --[[@as GameObjectClass]]
end

EpsiLib.GameObject.CanSpawn = canSpawn

-- Event Management
local events = {
	CHAT_MSG_ADDON = function(self, event, ...)
		local prefix = select(1, ...)

		--[[ -- WTF was this doing and why?
		if prefix == "Command" then
			local reply = select(2, ...)
			if reply:find("^m:..:") then
				reply = reply:gsub("^m....", "")
			end
			return
		end
		--]]

		if prefix == "EPSILON_OBJ_INFO" or prefix == "EPSILON_OBJ_SEL" then -- If OBJ_INFO or OBJ_SEL message, process the data to our 'cache'
			local objdetails = select(2, ...)
			local sender = select(4, ...)

			local playerSelf = table.concat({ UnitFullName("PLAYER") }, "-")
			if sender == playerSelf or string.gsub(playerSelf, "%s+", "") then
				C_Timer.After(0, function()
					if objdetails == "" then
						-- Clear the selected object
						EpsiLib.GameObject._log._selected = nil
						EpsiLib.EventManager:Fire("EPSILON_OBJ_UPDATE", "UNSEL", nil)
						return
					end

					--updateGroupSelected(false)

					local objectData = { strsplit(strchar(31), objdetails) } --[[@as SelectedObjectData]]

					-- Create & Add to Log as a selected object
					local obj = EpsiLib.GameObject._new(unpack(objectData))
					EpsiLib.GameObject:_addToLog(obj, true)
					EpsiLib.EventManager:Fire("EPSILON_OBJ_UPDATE", prefix, obj)
				end)
			else
				sysMsg("EpsiLib GobCMA: Illegal Sender (Got: " .. sender .. " | Expected:" .. playerSelf .. ")")
			end
		end
	end,
	PLAYER_LOGIN = function(self, event, ...)
		C_ChatInfo.RegisterAddonMessagePrefix("EPSILON_OBJ_INFO")
		C_ChatInfo.RegisterAddonMessagePrefix("EPSILON_OBJ_SEL")
	end,
	PLAYER_ENTERING_WORLD = function(self, event, initial, reload, ...)
		if reload then
			EpsiLib.AddonCommands._SendAddonCommand("gobject move up 0", function(suc) if not suc then EpsiLib.EventManager:Fire("EPSILON_OBJ_UPDATE", "INIT", nil) end end, false)
		else
			EpsiLib.EventManager:Fire("EPSILON_OBJ_UPDATE", "INIT", nil)
		end
	end,
	SCENARIO_UPDATE = function(self, event, ...)
		EpsiLib.GameObject._log._selected = nil
		EpsiLib.EventManager:Fire("EPSILON_OBJ_UPDATE", "SCENARIO_UPDATE", nil)
		-- TODO: REFRESH UI HERE TO DISABLE IF NON-MEMBER / NON-OFFICER, OR NO OBJ SELECTED
	end,
}

for k, v in pairs(events) do
	EpsiLib.EventManager:Register(k, v, k == "PLAYER_LOGIN")
end

--#region GameObject History Frame
local frame = CreateFrame("Frame", "EpsilonLibGobHistoryFrame", UIParent, "ButtonFrameTemplateMinimizable")
frame:SetSize(440, 416)
frame:SetPoint("CENTER")
frame:SetMovable(true)
frame:SetToplevel(true)
frame:SetClampedToScreen(true)
frame:EnableMouse(true)
frame.TitleText:SetText("GameObject History")
ButtonFrameTemplateMinimizable_HidePortrait(frame)
EpsiLib.GameObject.GobLogFrame = frame

NineSliceUtil.ApplyLayoutByName(frame.NineSlice, "EpsilonGoldBorderFrameDoubleButtonTemplateNoPortrait")

frame.MinimizedText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
frame.MinimizedText:SetText("Minimized. Click the _ button in the top right to expand.")
frame.MinimizedText:SetTextColor(0.66, 0.66, 0.66, 1)
frame.MinimizedText:SetPoint("TOP", 0, -35)
frame.MinimizedText:Hide()

frame.BottomButtons = CreateFrame("Frame", nil, frame)
frame.BottomButtons:SetSize(380, 32)
frame.BottomButtons:SetPoint("BOTTOM")

local minimizeButton = CreateFrame("Button", nil, frame, "UIPanelHideButtonNoScripts")
minimizeButton:SetSize(32, 32)
minimizeButton:SetPoint("RIGHT", frame.CloseButton, "LEFT", 10, 0) -- Position it beside the close button

minimizeButton:SetNormalTexture("Interface\\Buttons\\UI-Panel-HideButton-Up")
minimizeButton:SetPushedTexture("Interface\\Buttons\\UI-Panel-HideButton-Down")
minimizeButton:SetHighlightTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Highlight")

frame.isMinizmized = false

minimizeButton:SetScript("OnClick", function(self)
	self.isMinimized = not self.isMinimized
	if self.isMinimized then
		frame.Inset:Hide()
		local top = frame:GetTop()
		local left = frame:GetLeft()
		frame:SetHeight(60) -- Adjust this to show just the title bar
		frame:ClearAllPoints()
		frame:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", left, top)
		EpsiLib.Utils.NineSlice.CropNineSliceCorners(frame.NineSlice, 0.4) -- Crop the corners to show only the top half
		frame.BottomButtons:Hide()                                   -- Hide the bottom buttons
		frame.MinimizedText:Show()
	else
		frame.Inset:Show()
		local top = frame:GetTop()
		local left = frame:GetLeft()
		frame:SetHeight(416) -- Restore full height
		frame:ClearAllPoints()
		frame:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", left, top)
		EpsiLib.Utils.NineSlice.ResetNineSliceCorners(frame.NineSlice) -- Reset the corners to full size
		frame.BottomButtons:Show()                               -- Show the bottom buttons
		frame.MinimizedText:Hide()
	end
end)


local dragBar = CreateFrame("Frame", nil, frame, "PanelDragBarTemplate")
dragBar:SetPoint("TOPLEFT")
dragBar:SetSize(20, 20)
dragBar:SetPoint("RIGHT", frame.CloseButton, "LEFT", -20, 0)
dragBar:EnableMouse(true)
dragBar:Init(frame)
dragBar:HookScript("OnMouseDown", function(self)
	frame:Raise()
end)

local GAME_GOLD = CreateColorFromHexString("FFFFD700")

local gobLogSTObject
local gobLogSTColumns = {
	{ name = "Time",   width = 70, defaultsort = "dsc", sortnext = 2,      hcolor = GAME_GOLD },
	{ name = "Phase",  width = 60, defaultsort = "dsc", hcolor = GAME_GOLD },
	{ name = "GUID",   width = 60, defaultsort = "dsc", hcolor = GAME_GOLD },
	{ name = "Name",   width = 80, hcolor = GAME_GOLD },
	{ name = "Entry",  width = 70, hcolor = GAME_GOLD },
	{ name = "Status", width = 60, hcolor = GAME_GOLD },
}

--CreateST(cols, numRows, rowHeight, highlight, parent, multiselection)
gobLogSTObject = LibStub("ScrollingTable"):CreateST(gobLogSTColumns, 20, 16, nil, frame.Inset)
gobLogSTObject:EnableSelection(true)

local gobLogSTFrame = gobLogSTObject.frame
EpsiLib.GameObject.GobLogFrame.ST = { obj = gobLogSTObject, frame = gobLogSTFrame }

gobLogSTFrame:SetPoint("TOP", frame.Inset)

gobLogSTObject:RegisterEvents({
	OnEnter = function(rowFrame, cellFrame, data, cols, row, realrow, column, stSelf)
		if data[realrow] and data[realrow].tooltip then
			GameTooltip:SetOwner(cellFrame, "ANCHOR_TOPLEFT")
			GameTooltip:SetText(data[realrow].tooltip, nil, nil, nil, nil, false)
			GameTooltip:Show()
		end
	end,
	OnLeave = function() GameTooltip:Hide() end,
	--[[
	OnClick = function(rowFrame, cellFrame, data, cols, row, realrow, column, stSelf)
		if IsShiftKeyDown() then
			local link = data[realrow].cols[3].value

			if not ChatEdit_InsertLink("." .. link) then
				ChatFrame_OpenChat("." .. link);
			end
		end
	end,
	--]]
})

local tt_textFormat = [[
GUID: %s / Entry: %s
Phase: %s
Name: %s
%s
Status: %s
]]
local tt_fieldFormat = "%s: %s\n"
local tt_fields = {
	{
		field = "Tint",
		func = function(object)
			return object.HasTint and
				(("[R: %s, G: %s, B: %s, A: %s, S: %s]"):format(object.color.red, object.color.green, object.color.blue, object.color.alpha, object.color.saturation))
		end
	},
	{ field = "Spell",    func = function(object) return object.spell ~= 0 and object.spell end },
	{ field = "In Group", func = function(object) return (object.groupLeaderID and "Yes" or "No") end },
}

---comment
---@param object GameObjectClass
---@param status any
---@return unknown
local function getHistoryTooltip(object, status)
	local extras = ""
	for k, v in ipairs(tt_fields) do
		local res = v.func(object)
		if res then extras = extras .. tt_fieldFormat:format(v.field, res) end
	end

	return tt_textFormat:format(object.guid, object.phase, object.entry, object.sname, extras, status)
end

EpsiLib.GameObject.GobLogFrame.Update = function()
	if gobLogSTObject and gobLogSTFrame:IsShown() then
		local gobLog = EpsiLib.GameObject._log
		-- Refresh table data
		local data = {}
		for i = #gobLog, 1, -1 do
			local object = gobLog[i]
			local status = "Spawned"
			if object == EpsiLib.GameObject._log._selected then
				status = "Selected"
			elseif object.isRestored then
				status = "Restored"
			elseif object.isDeleted then
				status = "Deleted"
			end
			tinsert(data, {
				gob = object,
				cols = {
					{ value = date("%H:%M:%S", object.time) },
					{ value = object.phase },
					{ value = object.guid },
					{ value = object.sname },
					{ value = object.entry },
					{ value = status },
				},
				tooltip = getHistoryTooltip(object, status),
			})
		end
		gobLogSTObject:SetData(data)
	end

	EpsiLib.GameObject.GobLogFrame.BottomButtons:UpdateEnabled(gobLogSTObject:GetSelectedObject())
end
EpsiLib.GameObject.GobLogFrame:HookScript("OnShow", EpsiLib.GameObject.GobLogFrame.Update)
EpsiLib.GameObject.GobLogFrame:Hide()

function gobLogSTObject:GetSelectedObject()
	local id = gobLogSTObject:GetSelection()
	if id then
		return gobLogSTObject.data[id].gob
	end
	return false
end

-- For a bottom row, get selected object like this:

-- gobLogSTObject:GetSelection() --> Returns the id, to use in..
-- gobLogSTObject.data[id].gob

local bottomButtons = frame.BottomButtons
--EpsiLib.GameObject.GobLogFrame._bottomButtons = bottomButtons
local bottomButtonsMap = {}
gobLogSTFrame.bottomButtons = bottomButtons

local lastBtn
local function nextBottomButton(name, onClickFn)
	local btn = CreateFrame("Button", nil, frame.BottomButtons, "UIPanelButtonTemplate")
	if lastBtn then
		btn:SetPoint("RIGHT", lastBtn, "LEFT", -4, 0)
	else
		btn:SetPoint("BOTTOMRIGHT", -4, 4)
	end
	btn:SetText(name)
	local strWidth = btn.Text:GetStringWidth()
	btn:SetSize(strWidth + 20, 20)
	btn:Disable()

	lastBtn = btn
	bottomButtons[name] = btn
	table.insert(bottomButtonsMap, btn)

	if onClickFn then
		btn:HookScript("OnClick", onClickFn)
	end

	return btn
end

local restoreButton = nextBottomButton("Restore", function(self)
	local gobData = gobLogSTObject:GetSelectedObject() --[[@as GameObjectClass]]
	if not gobData then return end
	gobData:Restore()
end)
function restoreButton:Condition(gobData)
	return gobData.isDeleted and not gobData.isRestored
end

local gotoButton = nextBottomButton("Go To", function(self)
	local selectedRow = gobLogSTObject:GetSelection()
	local gobData = gobLogSTObject.data[selectedRow].gob
	if not gobData then return end
	gobData:GoTo()
end)

local selectButton = nextBottomButton("Select", function(self)
	local selectedRow = gobLogSTObject:GetSelection()
	local gobData = gobLogSTObject.data[selectedRow].gob
	if not gobData then return end
	gobData:Select()
end)
function selectButton:Condition(gobData)
	local selected = EpsiLib.GameObject._log._selected == gobData
	return not (gobData.isDeleted or selected)
end

local copyButton = nextBottomButton("Spawn", function(self)
	local selectedRow = gobLogSTObject:GetSelection()
	local gobData = gobLogSTObject.data[selectedRow].gob
	if not gobData then return end
	gobData:SpawnDuplicate()
end)
copyButton.tooltipText = "Spawns a new object with the same entry as the chosen object."

---Updates the Bottom Buttons enabled status based on GobData conditions or false to just disable them all if not selected
---@param gobData GameObjectClass|false
function bottomButtons:UpdateEnabled(gobData)
	if gobData then
		for k, v in ipairs(bottomButtonsMap) do
			if v.Condition then -- custom condition, set enabled based on condition result
				v:SetEnabled(v:Condition(gobData))
			else       -- No handler, assume that means enable on any selection
				v:Enable()
			end
		end
	else
		for k, v in ipairs(bottomButtonsMap) do
			v:Disable()
		end
	end
end

local origSetSelection = gobLogSTObject.SetSelection
function gobLogSTObject.SetSelection(self, realrow)
	origSetSelection(self, realrow)
	if realrow then
		local gob = gobLogSTObject.data[realrow].gob
		bottomButtons:UpdateEnabled(gob)
	else
		bottomButtons:UpdateEnabled(false)
	end
end

local function gobDelCheck(self, event, msg)
	msg = msg:gsub("|cff......", ""):gsub("|r", "")
	local dbGUID = tonumber(msg:match("DBGUID: (%d+)"))
	local fullDbGuid = getFullPhaseGobGUID(dbGUID, C_Epsilon.GetPhaseId())

	local gobData = EpsiLib.GameObject._gobs[fullDbGuid]
	if gobData then
		gobData.isDeleted = true
		EpsiLib.GameObject._log._selected = nil
		EpsiLib.GameObject.GobLogFrame.Update()
		EpsiLib.EventManager:Fire("EPSILON_OBJ_UPDATE", "COMMAND", nil)
	end
end
EpsiLib.EventManager:RegisterSimpleCommandWatcher("You have deleted |c", gobDelCheck)


--- GROUP SELECTION HANDLE / DETECTION

local gobGroupCommandMessages = {
	"Selected gameobject group",
	"Spawned gameobject group",
	"Spawned blueprint",
	"added %d+ objects to gameobject group",
	"added the gameobject .* to gameobject group"
}
local function checkForGroupMessage(msg)
	for _, pattern in ipairs(gobGroupCommandMessages) do
		if msg:find(pattern) then
			return true
		end
	end
	return false
end

local groupLeaderPattern = "GUID:(%d+)"
local groupLeaderPatternAlt = "with leader.*DBGUID: (%d+)%)"

local isWaitingForGroupData
local function groupMessageCheck(self, event, msg)
	local clearmsg = gsub(msg, "|cff%x%x%x%x%x%x", "");
	local clearmsg = clearmsg:gsub("|r", "");

	-- ignore announce messages:
	if clearmsg:find("^Epsilon") or msg:find("|cff00a2d7Epsilon|r") then
		return
	end

	---------- Group Selection Detection ----------

	if checkForGroupMessage(clearmsg) then
		local groupID = nil

		if clearmsg:find("Spawned blueprint") then
			-- case handler for spawned blueprint -- it doesn't have GUID in the initial message because system admins hate us
			isWaitingForGroupData = true
			return -- ignore the rest of this message
		elseif clearmsg:find("Selected") or clearmsg:find("Spawned gameobject") then
			-- selected & spawned always give the next group data messages or info in current message
			groupID = clearmsg:match(groupLeaderPattern)
			isWaitingForGroupData = EpsiLib.GameObject._newGroup(groupID)
			EpsiLib.GameObject:SetGroupSelected(isWaitingForGroupData)
			--print("Group Selected", groupID)
			EpsiLib.EventManager:Fire("EPSILON_OBJ_UPDATE", "GROUP", isWaitingForGroupData)
		else
			-- otherwise the others don't, so need to re-select the group to get the group data
			groupID = clearmsg:match(groupLeaderPatternAlt)
			--print('reselecting group for data, leader:', groupID)
			if groupID then
				EpsiLib.AddonCommands._SendAddonCommand("gobject group sel " .. groupID)
			else
				sysMsg("ALERT: Couldn't get the group data. Please re-select the group.")
			end
		end
	end

	if isWaitingForGroupData then
		if isWaitingForGroupData == true then
			-- this is a BP Spawned edge case, need to grab group GUID & reselect
			local groupID = clearmsg:match(groupLeaderPattern)
			EpsiLib.AddonCommands._SendAddonCommand("gobject group sel " .. groupID)
			isWaitingForGroupData = false
			return
		end

		local yaw = nil
		local scale = tonumber(clearmsg:match("Scale: (%d*%.%d*)"))

		if clearmsg:find("Yaw/Turn:") then
			yaw = math.rad(tonumber(clearmsg:match("Pitch: %-?%d*%.%d*, Roll: %-?%d*%.%d*, Yaw/Turn: (%-?%d*%.%d*)")))
		elseif clearmsg:find("with orientation:") then
			yaw = tonumber(clearmsg:match("orientation: (%-?%d*%.%d*)")) -- already a radian
		end

		if yaw or scale then
			local group = isWaitingForGroupData

			if yaw then group.orientation = yaw end
			if scale then group.scale = scale end

			isWaitingForGroupData = false
		end
	end
end
EpsiLib.EventManager:AddCommandFilter(groupMessageCheck)
