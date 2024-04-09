local EpsilonLib, EpsiLib = ...

_G[EpsilonLib] = EpsiLib

EpsiLib.test = "TEST";

--Set Up Module Tables
EpsiLib.GameObject = {}
EpsiLib.Utils = {}
EpsiLib.SystemMessages = {}
EpsiLib.Server = {}
EpsiLib.API = {}

EpsiLib.Templates = {}
EpsiLib.ContainerTemplate = {}

local oldEuler;

EpsiLib.TestObjects = {};
EpsiLib.filterswitch = false;
EpsiLib.callcount = 0;

function EpsiLib:AddObject(object)
    if EpsiLib.filterswitch then
        table.insert(EpsiLib.TestObjects, object);
        print("Added object with GUID: " .. object.guid .. ", entry: " .. object.entry);
    end

end

function EpsiLib:Init(radius)

    EpsiLib.TestObjects = {};
    EpsiLib.filterswitch = true;
    EpsiLib.callcount = 1;
    SendChatMessage(".gobject near " .. radius, "GUILD");

    C_Timer.After(1.5, function()
        print("disabled")
        EpsiLib.filterswitch = false;
    end);
end

local oldEuler;

local oldAngle = 0;

-- function EpsiLib:Rotate(angle, axis)

    
-- end



function EpsiLib:TestR(x, y, z)

    local v = EpsiLib.API.MathU.Vector3.new(x, y, z);

    print("XYZ",x,y,z)
    local i = 1;

    local t = C_Timer.NewTicker(1, function() 
        
        print(i);
        local go = EpsiLib.TestObjects[i];
        if go.entry ~= 815303 then
            go:Select();
            go:Rotate(v);
        end
        print("go", go, go.guid)

        i = i + 1;

    end, #EpsiLib.TestObjects)
    
end

function EpsiLib:Rotate(x, y, z)

    if not oldEuler then
        oldEuler = EpsiLib.API.MathU.Vector3.new(0, 0, 0);
    end

    local v = EpsiLib.API.MathU.Vector3.new(z, y, x);

    v.x = math.rad(v.x);
    v.y = math.rad(v.y);
    v.z = math.rad(v.z);
    
    print("ANGLES \n" .. v:ToString());

    -- Rotation Matrix

    local rM = EpsiLib.API.MathU.Matrix:Rotate(v);

    print(rM:ToString());
    --Quaternion

    local qX = EpsiLib.API.MathU.Quaternion:Euler(x, 0, 0);
    local qY = EpsiLib.API.MathU.Quaternion:Euler(0, y, 0);
    local qZ = EpsiLib.API.MathU.Quaternion:Euler(0, 0, z);

    local qC = qZ * qY * qX;

    print("\nX:", qX:ToString(), "\nY:", qY:ToString(), "\nZ:", qZ:ToString(), "\nC:", qC:ToString());
    
    local qER = EpsiLib.API.MathU.Quaternion:ToEuler(qC);

    EpsiLib:RotateMatrix(rM);
    EpsiLib:TestR(qER.x, qER.y, qER.z)
    oldEuler = EpsiLib.API.MathU.Vector3.new(x, y, z);
end

function EpsiLib:RotateMatrix(m, qER)
    for k,go in pairs(EpsiLib.TestObjects) do
        local vC = go.transform.position:ToColumn();
        local vM = m * vC;
        local vP = vM:ToVector();

        local permuted = EpsiLib.API.MathU.Vector3.new(vP.x, vP.y, vP.z);
        print(k, go.transform.position:ToString(), " - ", vP:ToString());

        go:Move(permuted, true);
    end
end


function EpsiLib:Move(x, y, z)

    local v = EpsiLib.API.MathU.Vector3.new(x, y, z);

    for k,go in pairs(EpsiLib.TestObjects) do
        print(go.guid);
        --go:Move(v);
    end

end

function EpsiLib:ATest()

    local vector1 = EpsiLib.API.MathU.Vector3.new(1, 2, 3);
    local vector2 = EpsiLib.API.MathU.Vector3.new(4, 5, 6);

    local result = vector1 - vector2;

    print(result:ToString());
    

    local m = EpsiLib.API.MathU.Matrix.new(3, 3);

    m.data[1][1] = 4;
    m.data[1][2] = -1;
    m.data[1][3] = 1;
    m.data[2][1] = 4;
    m.data[2][2] = 5;
    m.data[2][3] = 3;
    m.data[3][1] = -2;
    m.data[3][2] = 0;
    m.data[3][3] = 0;

    print(m:ToString());

    print(m:Inverse():ToString());

    -- print(m:Determinant());

    -- print(m:Minors():ToString());
    -- print(m:Minors():Cofactor():ToString());


    -- local m4x4 = EpsiLib.API.MathU.Matrix.new(4, 4);
    -- m4x4.data[1][1] = 1;
    -- m4x4.data[1][2] = 2;
    -- m4x4.data[1][3] = 3;
    -- m4x4.data[1][4] = 4;
    -- m4x4.data[2][1] = 1;
    -- m4x4.data[2][2] = 0;
    -- m4x4.data[2][3] = 2;
    -- m4x4.data[2][4] = 0;
    -- m4x4.data[3][1] = 0;
    -- m4x4.data[3][2] = 1;
    -- m4x4.data[3][3] = 2;
    -- m4x4.data[3][4] = 3;
    -- m4x4.data[4][1] = 2;
    -- m4x4.data[4][2] = 3;
    -- m4x4.data[4][3] = 0;
    -- m4x4.data[4][4] = 0;

    -- print(m:ToString());

    -- print(m:Determinant());

    -- print(m:Minors():ToString());
    -- print(m:Minors():Cofactor():ToString());
    

    
    

    local i = EpsiLib.API.MathU.Matrix.Identity(3)

    print(i:ToString());
    print(i:Transpose():ToString())
    return "ATEST";
end

EpsiLib.C_API = {}
for k,v in pairs(C_Epsilon) do
    EpsiLib.C_API[k] = v
end
