--quat
--vector3
--MathU
local EpsilonLib, EpsiLib = ...


function EpsiLib.API.MathU.Quaternion.new(x, y, z, w)

    local self = {
        x = x or 0,
        y = y or 0,
        z = z or 0,
        w = w or 0,
    }

    --EpsiLib.API.MathU.Vector3.__index = EpsiLib.API.MathU.Vector3

    setmetatable(self, EpsiLib.API.MathU.Quaternion)

    function self:Magnitude()
        return math.sqrt(self.x^2 + self.y^2 + self.z^2 + self.w^2);
    end

    function self:Unit()
        local mag = self:Magnitude()
        if (mag > 0) then
            return EpsiLib.API.MathU.Quaternion.new(self.x / mag, self.y / mag, self.z / mag, self.w / mag);
        else
            return EpsiLib.API.MathU.Quaternion.new(0, 0, 0, 0)
        end
    end

    -- public static Quaternion operator *(Quaternion left, Quaternion right)
    -- {
    --     Quaternion result = new Quaternion();
        

    --     result.x = (left.w * right.x) + (left.x * right.w) + (left.y * right.z) - (left.z * right.y);
    --     result.y = (left.w * right.y) + (left.y * right.w) + (left.z * right.x) - (left.x * right.z);
    --     result.z = (left.w * right.z) + (left.z * right.w) + (left.x * right.y) - (left.y * right.x);
    --     result.w = (left.w * right.w) - (left.x * right.x) - (left.y * right.y) - (left.z * right.z);


    --     return result;
    -- }

    EpsiLib.API.MathU.Quaternion.__mul = function(left, right)

        local result = EpsiLib.API.MathU.Quaternion.new(self.x, self.y, self.z, self.w)

        result.x = (left.w * right.x) + (left.x * right.w) + (left.y * right.z) - (left.z * right.y);
        result.y = (left.w * right.y) + (left.y * right.w) + (left.z * right.x) - (left.x * right.z);
        result.z = (left.w * right.z) + (left.z * right.w) + (left.x * right.y) - (left.y * right.x);
        result.w = (left.w * right.w) - (left.x * right.x) - (left.y * right.y) - (left.z * right.z);

        return result;
    end



    function self:ToString()
        local output = "";

        output = self.x .. ", " .. self.y .. ", " .. self.z .. ", " .. self.w;

        return output;
    end

    return self
end

function EpsiLib.API.MathU.Quaternion:Euler(x, y, z)

    x = (math.rad(x)) / 2;
    y = (math.rad(y)) / 2;
    z = (math.rad(z)) / 2;

    local c1 = math.cos(x); --C1
    local s1 = math.sin(x); --S1

    local c2 = math.cos(y); --C2
    local s2 = math.sin(y); --S2

    local c3 = math.cos(z); --C3
    local s3 = math.sin(z); --S3

    --Permuted due to unity cardinal system.

    local result = EpsiLib.API.MathU.Quaternion.new(0, 0, 0, 0);

    -- result.x = c1 * c2 * c3 + s1 * s2 * s3;
    -- result.y = c1 * c2 * s3 - s1 * s2 * c3;
    -- result.z = c1 * s2 * c3 + s1 * c2 * s3;
    -- result.w = s1 * c2 * c3 - c1 * s2 * s3;

    result.x = s1 * c2 * c3 + c1 * s2 * s3;
    result.y = -c1 * s2 * c3 + s1 * c2 * s3;
    result.z = c1 * c2 * s3 - s1 * s2 * c3;
    result.w = c1 * c2 * c3 - s1 * s2 * s3;

    return result;
end

function EpsiLib.API.MathU.Quaternion:ToEuler(q)

    print("->Euler\n",q:ToString());

    local test = q.x * q.y + q.z * q.w;

    local xx = q.x * q.x;
    local yy = q.y * q.y;
    local zz = q.z * q.z;

    local result = EpsiLib.API.MathU.Vector3.new(0, 0, 0);

    -- Heading
    result.x = math.atan(2*q.y * q.w - 2 * q.x * q.z, 1 - 2*yy - 2*zz)
    result.y = math.asin(2 * test);
    result.z = math.atan(2 * q.x * q.w - 2 * q.y * q.z, 1 - 2 * xx - 2 * zz)
    
    result.x = -math.deg(result.x);
    result.y = -math.deg(result.y);
    result.z = -math.deg(result.z);
    
    --[[
    heading = atan2(2 * q1.y * q1.w - 2 * q1.x * q1.z , 1 - 2*sqy - 2*sqz);
	attitude = asin(2 * test);
	bank = atan2(2*q1.x*q1.w-2*q1.y*q1.z , 1 - 2*sqx - 2*sqz)
    ]]
    return result;
end