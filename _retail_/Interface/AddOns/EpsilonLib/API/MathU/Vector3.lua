--vector3
--MathU
local EpsilonLib, EpsiLib = ...


function EpsiLib.API.MathU.Vector3.new(x, y, z)

    local self = {
        x = x or 0,
        y = y or 0,
        z = z or 0
    }

    --EpsiLib.API.MathU.Vector3.__index = EpsiLib.API.MathU.Vector3

    setmetatable(self, EpsiLib.API.MathU.Vector3)

    function self:Magnitude()
        return math.sqrt(self.x^2 + self.y^2 + self.z^2);
    end

    function self:Unit()
        local mag = self:Magnitude()
        if (mag > 0) then
            return EpsiLib.API.MathU.Vector3.new(self.x / mag, self.y / mag, self.z / mag)
        else
            return EpsiLib.API.MathU.Vector3.new(0, 0, 0)
        end
    end

    EpsiLib.API.MathU.Vector3.__mul = function(left, right)

        local result = EpsiLib.API.MathU.Vector3.new(0, 0, 0)

        result.x = left.x * right.x;
        result.y = left.y * right.y;
        result.z = left.z * right.z; 

       return result;
    end

    EpsiLib.API.MathU.Vector3.__sub = function(left, right)

        local result = EpsiLib.API.MathU.Vector3.new(0, 0, 0)

        result.x = left.x - right.x;
        result.y = left.y - right.y;
        result.z = left.z - right.z; 

       return result;
    end

    EpsiLib.API.MathU.Vector3.__add = function(left, right)

        local result = EpsiLib.API.MathU.Vector3.new(0, 0, 0)

        result.x = left.x + right.x;
        result.y = left.y + right.y;
        result.z = left.z + right.z; 

       return result;
    end

    function self:ToString()
        local output = "";

        output = self.x .. ", " .. self.y .. ", " .. self.z;

        return output;
    end

    function self:ToColumn()
        local m = EpsiLib.API.MathU.Matrix.new(3, 1);
        m[1][1] = self.x;
        m[2][1] = self.y;
        m[3][1] = self.z;

        return m;
    end

    return self
end
