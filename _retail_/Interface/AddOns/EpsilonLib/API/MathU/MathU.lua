--MathU
local EpsilonLib, EpsiLib = ...

EpsiLib.API.MathU.Vector2 = {}
EpsiLib.API.MathU.Vector3 = {}
EpsiLib.API.MathU.Quaternion = {}
EpsiLib.API.MathU.Matrix = {}



function EpsiLib.API.MathU:Test()
    print("abc")
end

function EpsiLib.API.MathU:ConvertToDegrees(radians)
    local angleInDegrees = radians*(180/math.pi);
    return angleInDegrees;
end

function EpsiLib.API.MathU:ConvertToRadians(degrees)
    local angleInRadians = degrees*(math.pi/180);
    return angleInRadians;
end