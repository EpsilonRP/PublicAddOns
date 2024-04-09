local EpsilonLib, EpsiLib = ...;

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


--aaa
local EpsilonLib, EpsiLib = ...

function EpsiLib.GameObject.new(guid, entry, name, filedataid, x, y, z, orientation, rx, ry, rz, HasTint, red, green, blue, alpha, spell, scale, groupLeader, objType, saturation, rGUIDLow, rGUIDHigh)

    local self =
    {
        guid = guid,
        entry = entry,
        name = name,
        filedataid = filedataid,
        transform = {
            position = EpsiLib.API.MathU.Vector3.new(x, y, z),
            rotation = EpsiLib.API.MathU.Vector3.new(rx, ry, rz),
        },
        orientation = orientation,
        HasTint = HasTint,
        colour =
        {
            red = red,
            green = green,
            blue = blue,
            alpha = alpha,
        },
        spell = spell,
        scale = scale,
        groupLeader = groupLeader,
        objType = objType,
        saturation = saturation,
        rGUIDLow = rGUIDLow,
        rGUIDHigh = rGUIDHigh,
    }


    setmetatable(self, EpsiLib.GameObject)
    
    -- operator methods
    
    function self:Move(vector, relative)
        print(vector.x, vector.y, vector.z);

        local mover = C_Timer.After(0.15, function() 
            SendChatMessage(".gobject move coords " .. self.guid .. " " .. vector.x .. " " .. vector.y .. " " .. vector.z, "GUILD");
        end)

    end

    function self:Rotate(vector)

        -- vector.x = math.deg(vector.x);
        -- vector.y = math.deg(vector.y);
        -- vector.z = math.deg(vector.z);

        print(vector:ToString());

        self.transform.rotation = vector;

        local mover = C_Timer.After(0.15, function() 
            SendChatMessage(".gobject rotate " .. vector.x .. " " .. vector.y .. " " .. vector.z, "GUILD");
        end)
    end

    function self:Select()
        SendChatMessage(".gobject select " .. self.guid, "GUILD");
    end

    function self:ToString()
        local output = "";

        output = output .. self.transform.position:ToString();
        -- .. self.transform.position:ToString();
        return output;
    end

    return self
end

