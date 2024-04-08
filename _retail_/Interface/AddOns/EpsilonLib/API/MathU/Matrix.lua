--aaa
local EpsilonLib, EpsiLib = ...

function EpsiLib.API.MathU.Matrix.new(rows, cols)
    local self = {
        rows = rows,
        cols = cols,
        data = {}
    }

    -- Initialize the matrix with zeros
    for i = 1, rows do
        self.data[i] = {}
        for j = 1, cols do
            self.data[i][j] = 0
        end
    end

    setmetatable(self, EpsiLib.API.MathU.Matrix)

    EpsiLib.API.MathU.Matrix.__index = function(matrix, key)
        if type(key) == "number" and key >= 1 and key <= matrix.rows then
            return setmetatable({}, {
                __index = function(row, col)
                    if type(col) == "number" and col >= 1 and col <= matrix.cols then
                        return matrix.data[key][col]
                    else
                        error("Invalid column index")
                    end
                end,
                __newindex = function(row, col, value)
                    if type(col) == "number" and col >= 1 and col <= matrix.cols then
                        matrix.data[key][col] = value
                    else
                        error("Invalid column index")
                    end
                end
            })
        else
            error("Invalid row index")
        end
    end
    
    -- operator methods

    function self:Mul(scalar)
        for i = 1, self.rows do
            for j = 1, self.cols do
                self.data[i][j] = scalar * self.data[i][j];
            end
        end

        return self;
    end
    -- Matrix Multiplication
    EpsiLib.API.MathU.Matrix.__mul = function(left, right)

        if (type(left) == "number") then
            return self:Mul(left);
        elseif (type(right) == "number") then
            return self:Mul(right);
        end

        if (left.cols == right.rows) then
            local result = EpsiLib.API.MathU.Matrix.new(left.rows, right.cols)

            for i = 1, left.rows do
                for j = 1, right.cols do
                    local sum = 0;
                    for k = 1, left.cols do
                        sum = sum + left.data[i][k] * right.data[k][j];
                    end
                    result.data[i][j] = sum;
                end
            end
            
            return result;
        else
            
            error("Unable to multiply");
        end
    end

    function self:ToString()
        local output = "\n";

        for i = 1, self.rows do
            for j = 1, self.cols do
                output = output .. self.data[i][j] .. ", ";
            end
            output = output .. "\n";
        end

        return output;
    end

    function self:Transpose()

        local mT = EpsiLib.API.MathU.Matrix.new(self.cols, self.rows)

        for i = 1, self.rows do
            for j = 1, self.cols do
                mT.data[j][i] = self.data[i][j];
            end
        end

        return mT;
    end


    function self:Determinant(m)

        local d = 0;

        if m then
            if (m.rows == 2 and m.cols == 2) then
                d = (m.data[1][1] * m.data[2][2]) - (m.data[1][2] * m.data[2][1]);
                return d;
            else
                for col = 1, m.cols do
                    local sign = 1;
                    if (col % 2 == 0) then
                        sign = -1;
                    end

                    d = d + sign * m.data[1][col] * self:Determinant(m:SubMatrix(1, col));
                end
            end
            return d;
        else
            return self:Determinant(self)
        end
        return d;
    end

    function self:SubMatrix(row, col)
        local m = EpsiLib.API.MathU.Matrix.new(self.rows - 1, self.cols - 1)
    
        local r = 1
        for i = 1, self.rows do
            if i ~= row then
                local k = 1
                for j = 1, self.cols do
                    if j ~= col then
                        m.data[r][k] = self.data[i][j]
                        k = k + 1
                    end
                end
                r = r + 1
            end
        end
    
        return m
    end
    

    function self:Minors()
        local result = EpsiLib.API.MathU.Matrix.new(self.rows, self.cols);

        for i = 1, self.rows do
            for j = 1, self.cols do
                result.data[i][j] = self:Determinant((self:SubMatrix(i, j)));
            end
        end

        return result;
    end

    function self:Cofactor()
        local result = EpsiLib.API.MathU.Matrix.new(self.rows, self.cols);
        local sign = -1;

        for i = 1, self.rows do
            for j = 1, self.cols do
                sign = (sign > 0) and -1 or 1;
                result.data[i][j] = sign * self.data[i][j];
            end
        end
        return result;
    end

    function self:Inverse()

        local d = self:Determinant();

        return (1/d) * self:Minors():Cofactor():Transpose();

    end
    
    function self:ToVector()
        if (self.rows == 3 and self.cols == 1) then
            local v = EpsiLib.API.MathU.Vector3.new(self[1][1], self[2][1], self[3][1]);
            return v;
        end

        return null;
    end

    return self
end

function EpsiLib.API.MathU.Matrix.Identity(n)

    local m = EpsiLib.API.MathU.Matrix.new(n, n)

    for i = 1, m.rows do
        for j = 1, m.cols do
            if (i == j) then
                m.data[i][j] = 1;
            end
        end
    end

    return m;
end

function EpsiLib.API.MathU.Matrix:Rotate(vector)

    local rM = EpsiLib.API.MathU.Matrix.new(3, 3);

    local rX = EpsiLib.API.MathU.Matrix.RotateAxis(vector.x, "x")
    local rY = EpsiLib.API.MathU.Matrix.RotateAxis(vector.y, "y")
    local rZ = EpsiLib.API.MathU.Matrix.RotateAxis(vector.z, "z")

    rM = rX * rY * rZ;

    return rM;

end

function EpsiLib.API.MathU.Matrix.RotateAxis(angle, axis)
    local result = EpsiLib.API.MathU.Matrix.Identity(3);

    if (axis == "x") then
        result[2][2] = math.cos(angle);
        result[2][3] = -math.sin(angle);
        result[3][2] = math.sin(angle);
        result[3][3] = math.cos(angle);
    end

    if (axis == "y") then
        result[1][1] = math.cos(angle);
        result[1][3] = math.sin(angle);
        result[3][1] = math.sin(angle);
        result[3][3] = math.cos(angle);
    end

    if (axis == "z") then
        result[1][1] = math.cos(angle);
        result[1][2] = -math.sin(angle);
        result[2][1] = math.sin(angle);
        result[2][2] = math.cos(angle);
    end

    return result;
end
