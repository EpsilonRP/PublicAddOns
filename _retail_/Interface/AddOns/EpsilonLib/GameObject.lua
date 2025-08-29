local EpsilonLib, EpsiLib = ...;


EpsiLib.GameObject._log = {}
EpsiLib.GameObject._log._last = nil
EpsiLib.GameObject._log._selected = nil
EpsiLib.GameObject._gobs = {}
local group_holder = {}

-- Utils
local toboolean = EpsiLib.Utils.ToBoolean
local tonumberOrFalse = EpsiLib.Utils.ToNumberOrFalse
local formatNumber = EpsiLib.Utils.TrimNumber

--[[
GameObject = {}

function EpsiLib.GameObject:ConvertToDegrees(radians)
    local angleInDegrees = radians*(180/math.pi);
    return angleInDegrees;
end

function EpsiLib.GameObject:ConvertToRadians(degrees)
    local angleInRadians = degrees*(math.pi/180);
    return angleInRadians;
end

function EpsiLib.GameObject.TestGobject()
    print("WORKS")
    return "EPSILIB.GAMEOBJECT"
end

function EpsiLib.GameObject.GetMapCoordinatesFromString(message)

    local x, y, z, orientation, map;
    local pitch, roll, yaw;
    if message:match("Map:") then
        --print("SELECTED")
        map = message:match("Map: (%d*)");
        x, y, z = message:match("%(?X: (-?%d*\.?%d*), Y: (-?%d*\.?%d*), Z: (-?%d*\.?%d*),")
        pitch, roll, yaw = message:match("Pitch: (-?%d*\.?%d*), Roll: (-?%d*\.?%d*), Yaw/Turn: (-?%d*\.?%d*)");
    elseif message:match("Moved GameObject") then
        --print("MOVED")
        map = message:match("map (%d*)")
        x, y, z = message:match("%(?X: (-?%d*\.?%d*) Y: (-?%d*\.?%d*) Z:(-?%d*\.?%d*)")
        orientation = message:match("orientation (-?%d*\.?%d*)");
    end

    if not orientation then
        orientation = EpsiLib.GameObject:ConvertToRadians(yaw);
    else
        yaw = EpsiLib.GameObject:ConvertToDegrees(orientation);
    end

    if x and y and z and orientation or x and y and z and pitch and roll and yaw then
        return x, y, z, orientation, pitch, roll, yaw, map;
    end
    return nil;
end

function EpsiLib.GameObject.GetEntryFromString(message)

    local entryID, GUID, objectName;
    entryID = message:match("gameobject_entry:(%d*)")
    GUID = message:match("gameobject_GUID:(%d*)")
    objectName = message:match("%[(.+)%s%-%s%d*%]")
    return entryID, GUID, objectName;

end
--]]
--aaa

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
	return fileName and fileName:match("(.+)%..+$") or fileName
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
	if obj:IsWMO() then return safeCallback(callback, false) end -- just exit now for WMOs. We have several wmo anti-crash checks along the way, but better safe than crash.
	obj.size = false
	dimDetectSceneFrame:GetObjectSize(obj.fileID, obj.objType, function(size)
		if size then
			obj.size = size
		else
			print("Failed to get size for object with fileID: " .. tostring(obj.fileID))
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

function GameObjectMeta:SelectGroup()
	EpsiLib.AddonCommands._SendAddonCommand("gobject group select")
end

function GameObjectMeta:IsSelected()
	return EpsiLib.GameObject._log._selected == self
end

function GameObjectMeta:IsWMO()
	local id = tonumber(self.objType)
	return WMO_TYPES[id] or false
end

function GameObjectMeta:GetGUID()
	return self.guid
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

function GameObjectMeta:SetScale(val)
	if not self:IsSelected() then
		print("You must select the GameObject before changing its scale.");
		return;
	end
	if not val or tonumber(val) <= 0 then
		print("Invalid scale value. Must be a positive number.");
		return;
	end

	EpsiLib.AddonCommands._SendAddonCommand(("gobject scale %s"):format(val), function(success, messages)
		if not success then
			print("Failed to set scale for GameObject: " .. self.guid .. " with message: " .. messages[1])
		else
			--print("Set scale for GameObject: " .. self.guid .. " to " .. self.scale)
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
	print(vector.x, vector.y, vector.z);

	EpsiLib.AddonCommands._SendAddonCommand("gobject move coords " .. self.guid .. " " .. vector.x .. " " .. vector.y .. " " .. vector.z, "GUILD");
end

---Move GameObject by given string movements (i.e., "up 10", "forward 5")
---@param ... string
function GameObjectMeta:Move(...)
	local args = { ... }
	if #args == 0 then return end

	EpsiLib.AddonCommands._SendAddonCommand("gobject move " .. self.guid .. " " .. table.concat(args, " "), function(success, messages)
		if not success then
			-- TODO - Clean this up
			print("Failed to move GameObject: " .. self.guid .. " with message: " .. messages[1])
		end
	end, false)
end

---Move GameObject relative by given string movements (i.e., "up 10", "forward 5")
---@param ... string
function GameObjectMeta:MoveRelative(...)
	local args = { ... }
	if #args == 0 then return end

	EpsiLib.AddonCommands._SendAddonCommand("gobject relative " .. self.guid .. " " .. table.concat(args, " "), function(success, messages)
		if not success then
			-- TODO - Clean this up
			print("Failed to move relative GameObject: " .. self.guid .. " with message: " .. messages[1])
		end
	end, false)
end

function GameObjectMeta:MoveWorld(dir1, dist1, ...)
	if not dir1 and not tonumber(dist1) then return error("Must provide at least one valid direction & distance") end
	if not self:IsSelected() then
		print("You must select the GameObject before being able to move (world relative) it.")
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
				print("Failed move (world) GameObject: " .. self.guid .. " with message: " .. messages[1])
			else
				print("Moved (world) GameObject: " .. self.guid)
			end
		end, false)
	end
end

function GameObjectMeta:Rotate(x, y, z, virtual)
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

--[[
function GameObjectMeta:Rotate(vector, virtual)
	-- vector.x = math.deg(vector.x);
	-- vector.y = math.deg(vector.y);
	-- vector.z = math.deg(vector.z);

	print(vector:ToString());

	self.transform.rotation = vector;

	local mover = C_Timer.After(0.15, function()
		SendChatMessage(".gobject rotate " .. vector.x .. " " .. vector.y .. " " .. vector.z, "GUILD");
	end)
end
--]]

function GameObjectMeta:Pitch(val, exact)
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
	if not val then error("Cannot turn by nothing (use Face instead).") end
	if exact then
		self:Face(val)
		return
	end
	EpsiLib.AddonCommands._SendAddonCommand("gobject turn " .. val)
	self.transform.rotation.z = val
end

function GameObjectMeta:Face(val)
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
	if not self:IsSelected() then
		print("You must select the GameObject before applying a tint.");
		return;
	end
	local command = (("gobject tint %s %s %s %s %s"):format(r, g, b, s, a))
	EpsiLib.AddonCommands._SendAddonCommand(command, function(success, messages)
		if not success then
			print("Failed to tint GameObject: " .. self.guid .. " with message: " .. messages[1])
		else
			--print("Tinted GameObject: " .. self.guid)
		end
	end, false)
end

function GameObjectMeta:Overlay(r, g, b, a, s)
	if not self:IsSelected() then
		print("You must select the GameObject before applying an overlay.");
		return;
	end
	local command = (("gobject overlay %s %s %s %s %s"):format(r, g, b, s, a))
	EpsiLib.AddonCommands._SendAddonCommand(command, function(success, messages)
		if not success then
			print("Failed to apply overlay to GameObject: " .. self.guid .. " with message: " .. messages[1])
		else
			--print("Applied overlay to GameObject: " .. self.guid)
		end
	end, false)
end

function GameObjectMeta:Copy(dir, val, count, entry)
	local command
	if not dir or val then
		command = "gobject copy"
	else
		command = ("gobject copy %s %s %s %s"):format(dir, val, count or 1, entry or "")
	end
	EpsiLib.AddonCommands._SendAddonCommand(command, function(success, messages)
		if not success then
			print("Failed to copy GameObject: " .. self.guid .. " with message: " .. messages[1])
		else
			--print("Copied GameObject: " .. self.guid)
		end
	end, false)
end

function GameObjectMeta:SpawnDuplicate()
	EpsiLib.AddonCommands._SendAddonCommand("gobject spawn " .. self.entry, function(success, messages)
		if not success then
			print("Failed to spawn duplicate GameObject: " .. self.guid .. " with message: " .. messages[1])
		else
			--print("Spawned duplicate GameObject: " .. self.guid)
		end
	end, false)
end

function GameObjectMeta:DeepCopy(samePos)
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
			print("Failed to copy GameObject: " .. gobData.guid .. " with message: " .. messages[1])
		else
			gobData.isRestored = true
			print("Deep-Copied GameObject: " .. gobData.guid)
		end
	end, false)
end

function GameObjectMeta:Delete()
	EpsiLib.AddonCommands._SendAddonCommand("gobject delete " .. self.guid, function(success, messages)
		if not success then
			print("Failed to delete GameObject: " .. self.guid .. " with message: " .. messages[1])
		else
			self.isDeleted = true
			print("Deleted GameObject: " .. self.guid)
		end
	end, false)
end

function GameObjectMeta:Restore()
	local gobData = self
	if not self.isDeleted then
		print("GameObject: " .. self.guid .. " is not deleted, cannot restore.");
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
			print("Failed to restore GameObject: " .. gobData.guid .. " with message: " .. messages[1])
		else
			gobData.isRestored = true
			print("Restored GameObject: " .. gobData.guid)
		end
	end, false)
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
			print(("Failed to select GameObject (%s) with message: " .. messages[1]):format(name or id or "nearest"))
		else
			--print("Selected GameObject: " .. (name or guid or entry))
		end
	end)
end

function EpsiLib.GameObject:Unselect()
	EpsiLib.AddonCommands._SendAddonCommand("gobject unselect", function(success, messages)
		if not success then
			print("Failed to unselect GameObject with message: " .. messages[1])
		else
			-- Clear the selected object
			self._log._selected = nil
			EpsiLib.EventManager:Fire("EPSILON_OBJ_UPDATE", "UNSEL", nil)
		end
	end)
end

function EpsiLib.GameObject:Get(id)

end

function EpsiLib.GameObject:GetSelected()
	if self._log._selected == group_holder then
		return nil -- If the selected object is the group holder, return nil
	end
	return self._log._selected
end

function EpsiLib.GameObject:GetLast()
	return self._log._last
end

function EpsiLib.GameObject:IsGroupSelected()
	return self._log._selected == group_holder
end

function EpsiLib.GameObject:_addToLog(obj, selected)
	--Check if this gob already exists in our gobs list, and be sure to remove it from the log if so
	if self._gobs[obj.guid] then
		tDeleteItem(self._log, self._gobs[obj.guid])
	end

	-- Add the object to the log, along with updating it's gobs entry just to be sure it's recorded there
	table.insert(self._log, obj)
	self._gobs[obj.guid] = obj
	self._log._last = obj

	if selected then
		self._log._selected = obj
	end

	EpsiLib.GameObject.GobLogFrame.Update()
end

function EpsiLib.GameObject._create(id)
	local object = {}
	-- Add meta for default function handlers to function as a class
	setmetatable(object, { __index = GameObjectMeta })

	if id then
		object.guid = tonumber(id)
		EpsiLib.GameObject._gobs[id] = object
	end

	return object --[[@as GameObjectClass]]
end

--								guid, entry, name, fileID, x, y, z, orientation, rx, ry, rz, HasTint, red, green, blue, alpha, spell, scale, groupLeader, objType, saturation, rGUIDLow, rGUIDHigh, canEdit
function EpsiLib.GameObject._new(guid, entry, name, fileID, x, y, z, orientation, rx, ry, rz, HasTint, red, green, blue, alpha, spell, scale, groupLeader, objType, saturation, rGUIDLow, rGUIDHigh,
								 canEdit)
	guid = tonumber(guid)
	if not guid then return error("_new must have GUID") end
	local object = EpsiLib.GameObject._gobs[guid] or EpsiLib.GameObject._create() -- Re-use the object it it already exists, or generate a new one

	object.guid = tonumber(guid)
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
				print("EpsiLib GobCMA: Illegal Sender (Got: " .. sender .. " | Expected:" .. playerSelf .. ")")
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
frame:SetSize(380, 416)
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

	return tt_textFormat:format(object.guid, object.entry, object.sname, extras, status)
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

	local gobData = EpsiLib.GameObject._gobs[dbGUID]
	if gobData then
		gobData.isDeleted = true
		EpsiLib.GameObject._log._selected = nil
		EpsiLib.GameObject.GobLogFrame.Update()
		EpsiLib.EventManager:Fire("EPSILON_OBJ_UPDATE", "COMMAND", nil)
	end
end
EpsiLib.EventManager:RegisterSimpleCommandWatcher("You have deleted |c", gobDelCheck)
