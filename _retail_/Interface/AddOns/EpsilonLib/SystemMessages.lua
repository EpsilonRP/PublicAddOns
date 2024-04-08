--
local EpsilonLib, EpsiLib = ...;

--EpsiLib.Utils = {}

STOREDCOMMAND = STOREDCOMMAND or {};
STOREDPROGRESS = STOREDPROGRESS or 0;

function EpsiLib.SystemMessages:ObjectTemplate(data)

    local object = {}

    local self = {}
    
    for k,v in pairs(data) do
        --print(k,v)
            if v == "Selected" or v == "Moved" or v == "rotated" or v == "Spawned" then
                self.action = v:lower(); --Match the following words to obtain the action being made on the Object.
            end
            if v:match("%.m2") or v:match("%.wmo") then --Match for the beginning of the objectname string.
                self.objectName = data[k] .. "]";
                self.objectEntry = data[k+1]:match("(%d*)");
            end 
    
            if v:match("%(GUID:") then --Match for GUID and add 1 to the index, as GUID is likely to be in the next table row.
                self.objectGUID = data[k+1]:match("|h(%d*)") or data[k+1]:match("(%d*)");
            end
    
            if v:match("[Mm]ap%:?") then
                self.map = data[k+1]
            end
            if v:match("X:") then
                
                self.position = {x = data[k+1], y = data[k+3], z = data[k+5]}
                if self.action == "moved" then --Special case because of typo in system message
                    self.position.z = data[k+4]:gsub("Z:", "")
                end
                --print("Position Passed", self.position.x,self.position.y,self.position.z);
            end
            if v:match("[Oo]rientation") then
                self.orientation = data[k+1];
                --print("Orientation Passed", self.orientation)
            end
    
            if v:match("Pitch:") then
                self.transform = {x = data[k+1], y = data[k+3], z = data[k+5]}
                --print("Transforms Passed", self.transform.x,self.transform.y,self.transform.z);
            end

            if v  == "to" then
                if data[k+1]:match("[XYZ]") then
                    local axes = data[k+1]:gsub(":",""):lower();
                    local amount = data[k+2]
                    self.transform = {axis = axes, amount = amount}
                end
                
            end
        end

    local malformed = true;

    self.time = time();
    --cleanup before we set the data to a table

    for k,v in pairs(self) do
        if type(v) ~= "number" then
            if type(v) == "table" then
                for k1,v1 in pairs(v) do
                    --print("TABLE", k, v,k1,v1)
                    self[k][k1] = EpsiLib.Utils:Sanitize(v1);
                end
            else
                self[k] = EpsiLib.Utils:Sanitize(v);
            end
        end
    end
    setmetatable(object, self)
    self.__index = self;

    if self.action and self.objectGUID then
        if self.action:match("rotated") then
            if self.transform.axis and self.transform.amount then
                return object;
            end 
        end
        if self.action:match("moved") then
            if self.position.x and self.position.y and self.position.z and self.map then
                return object;
            end
        end
        if self.action and self.objectGUID and self.objectEntry and self.objectGUID then
            --Selected
            return object;
        end
    end

   
    return {};
end

function EpsiLib.SystemMessages:ObjectCoordinatesTemplate(data)

    local coordinates = {}
    local self = {}

    for k,v in pairs(data) do
        print(k,v)
    end

    return -1;
end

function EpsiLib.SystemMessages:MessageStructor(message)

end

function EpsiLib.SystemMessages:Test()
    return "SYSTEM MESSAGES WORK";
end

function EpsiLib.SystemMessages:GetCommandType(message)

    local data = {}
    local command = {}
    for word in string.gmatch(message, "[^%s]+") do
        if word:match("|h%[%w+") or word:match("%w+%]|h|r") or word == "-" then
            if word:match("[.m2.wmo]") then
                tinsert(data,word)
            end
        else
            --print(word)
            tinsert(data, word);
        end
    end

    local command = EpsiLib.SystemMessages:ObjectTemplate(data);

    if STOREDPROGRESS == 0 or STOREDPROGRESS == nil then
        if command.action == "selected" or command.action == "spawned" then
            tinsert(data, "--END["..STOREDPROGRESS.."]--");
            STOREDCOMMAND = data;
            local command = EpsiLib.SystemMessages:ObjectTemplate(STOREDCOMMAND);
            STOREDPROGRESS = 1;

            return nil
        else
            return command;
        end
        
    end
    
    if STOREDPROGRESS == 1 and STOREDCOMMAND then
        
        if STOREDCOMMAND then
            for _,v in ipairs(data) do
                STOREDCOMMAND[#STOREDCOMMAND+1] = v;
            end
            STOREDCOMMAND[#STOREDCOMMAND+1] = "--END["..STOREDPROGRESS.."]";
            command = EpsiLib.SystemMessages:ObjectTemplate(STOREDCOMMAND);
            if command then
                STOREDPROGRESS = 0;
                STOREDCOMMAND = {}
                return command;
            end
        end
    end

    if command then
        return command;
    end

    return nil;
end

local messagelog = {};

local function GetObjectFromString(messages)

    local entry;
    local guid;
    local x, y, z;
    local rX, rY, rZ;
    local map;

        -- print(message:gsub("|", ""))
    -- local entry = message:match("Hgameobject_entry:(%d*)");
    -- local guid = message:match("gameobject_GUID:(%d*)");
    -- local x, y, z = message:match();
    -- local rX, rY, rZ;

    for k,message in pairs(messages) do
        entry = message:match("Hgameobject_entry:(%d*)");
        guid = message:match("gameobject_GUID:(%d*)");
    end



    -- print(entry, guid)

    messagelog = {}; 
end


local goCount = 0;
local guids = {};

local Selecting = false;

local function Addon_OnEvent(self, event, ...)
    if event == "CHAT_MSG_ADDON" then
        local prefix = select(1,...)
        if prefix == "EPSILON_OBJ_INFO" or prefix == "EPSILON_OBJ_SEL" then
            local objdetails = select(2,...)
            local sender = select(4,...)
            local self = table.concat({UnitFullName("PLAYER")}, "-")
            if sender == self or string.gsub(self,"%s+","") then
                local guid, entry, name, filedataid, x, y, z, orientation, rx, ry, rz, HasTint, red, green, blue, alpha, spell, scale, groupLeader, objType, saturation, rGUIDLow, rGUIDHigh = strsplit(strchar(31),objdetails)

                local go = EpsiLib.GameObject.new(guid, entry, name, filedataid, x, y, z, orientation, rx, ry, rz, HasTint, red, green, blue, alpha, spell, scale, groupLeader, objType, saturation, rGUIDLow, rGUIDHigh);

                EpsiLib:AddObject(go)

            end
        end
    end
end

local f = CreateFrame("Frame")
f:SetScript("OnEvent", Addon_OnEvent)
f:RegisterEvent("CHAT_MSG_ADDON");

local guids = {};

local function SelectGUIDS(guids)
    for k,v in pairs(guids) do
        SendChatMessage(".gobject select " .. v, "GUILD");
    end
end


local function GobjectNearFilter(self,event,message,...)

    
	if (EpsiLib.filterswitch == true) then
        EpsiLib.callcount = EpsiLib.callcount + 1;

        if message:match("gameobject_GUID") and not message:match("Selected") then
            local guid = message:match("gameobject_GUID:(%d*)");
            table.insert(guids, guid);
            SendChatMessage(".gobject select " .. guid, "GUILD");
        end

        if message:match("Found nearby gameobjects") then
            goCount = message:match("%): (%d*)");

            if (goCount == #guids) then
                SelectGUIDS(guids);
                EpsiLib.filterswitch = false;
                guids = {};
            end
        end
       --return true; 
    end

	return false, message,...;
end
ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", GobjectNearFilter);
