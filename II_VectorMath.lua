-- Author: Incendiary Moose
-- GitHub: <GithubLink>
-- Workshop: https://steamcommunity.com/profiles/76561198050556858/myworkshopfiles/?appid=573090
--
--- Developed using LifeBoatAPI - Stormworks Lua plugin for VSCode - https://code.visualstudio.com/download (search "Stormworks Lua with LifeboatAPI" extension)
--- If you have any issues, please report them here: https://github.com/nameouschangey/STORMWORKS_VSCodeExtension/issues - by Nameous Changey

require('II_MathHelpers')
require('II_Tables')

---@section IIVector 1 IIVECTORCLASS
---@class IIVector
---@field x number Initial x value. Defaults to 0
---@field y number Initial y value. Defaults to 0
---@field z number Initial z value. Defaults to 0
IIVector = {
    ---Creates a new vector
    ---@param self IIVector
    ---@param x number
    ---@param y number
    ---@param z number
    ---@overload fun():IIVector Creates a new vector with 0 for all dimensions
    ---@return IIVector Vector
    new = function (self, x, y, z)
        return appendTable({x or 0, y or 0, z or 0}, self)
    end,

    ---@section setVector
    ---Sets the values of the vector
    ---@param self IIVector
    ---@param x number
    ---@param y number
    ---@param z number
    setVector = function (self, x, y, z)
        self[1] = x
        self[2] = y
        self[3] = z
    end,
    ---@endsection

    ---@section setAdd
    ---Sets the vector to the value of itself plus the provided vector, with an optional scale
    ---@param self IIVector
    ---@param other IIVector
    ---@param scalar number
    ---@overload fun(self:IIVector, other:IIVector) Sets the vector to the value of itself plus the provided vector
    setAdd = function (self, other, scalar)
        for i = 1, 3 do
            self[i] = self[i] + other[i] * (scalar or 1)
        end
    end,
    ---@endsection

    ---@section setScale
    ---Scales the vector
    ---@param self IIVector
    ---@param scalar number
    setScale = function (self, scalar)
        for i = 1, 3 do
            self[i] = self[i] * scalar
        end
    end,
    ---@endsection

    ---@section magnitude
    ---Gets the magnitude of the vector
    ---@param self IIVector
    ---@return number magnitude
    magnitude = function (self)
        return (self[1]^2 + self[2]^2 + self[3]^2)^0.5
    end,
    ---@endsection magnitude

    ---@section distanceTo
    ---Gets the distance of the vector to another
    ---@param self IIVector
    ---@param other IIVector
    ---@return number distance
    distanceTo = function (self, other)
        return ((self[1] - other[1])^2 + (self[2] - other[2])^2 + (self[3] - other[3])^2)^0.5
    end,
    ---@endsection distanceTo
    

    ---@section toCartesian
    ---Converts the vector from the form (magnitude, yaw, pitch) to (x, y, z)
    ---@param self IIVector
    toCartesian = function (self)
        self:setVector(self[1] * math.sin(self[2]) * math.cos(self[3]), self[1] * math.cos(self[2]) * math.cos(self[3]), self[1] * math.sin(self[3]))
    end,
    ---@endsection

    ---@section dot
    ---Returns the dot of the vector with another
    ---@param self IIVector
    ---@param other IIVector
    ---@return number dot The dot of the two vectors
    dot = function (self, other)
        local dotProduct = 0
        for i = 1, 3 do
            dotProduct = dotProduct + self[i] * other[i]
        end
        return dotProduct
    end,
    ---@endsection

    ---@section toZYXMatrix
    ---Converts vector into a ZYX rotation matrix
    ---@param self IIVector Expected form of [roll, pitch, yaw] in radians
    ---@return IIMatrix rotationMatrix ZYX rotation matrix using the given rotation
    toZYXMatrix = function (self)
        local c3, s3, c2, s2, c1, s1 =
        math.cos(self[1]), math.sin(self[1]),
        math.cos(self[2]), math.sin(self[2]),
        math.cos(self[3]), math.sin(self[3])
        local c1s2, c3s1 = c1*s2, c3*s1
        return IIMatrix:new(
            IIVector:new(c1*c2, c1s2*s3 - c3s1, s1*s3 + c1s2*c3),
            IIVector:new(c2*s1, c1*c3 + s1*s2*s3, c3s1*s2 - c1*s3),
            IIVector:new(-s2, c2*s3, c2*c3)
        )
    end,
    ---@endsection

    ---@section matrixRotate
    ---Rotates the vector using the provided matrix
    ---@param self IIVector
    ---@param matrix IIMatrix
    matrixRotate = function (self, matrix)
        local result = IIVector:new()
        for j = 1, 3 do
            result[j] = self:dot(matrix[j])
        end
        self:copyVector(result)
    end,
    ---@endsection

    ---@section getVector
    ---Gets the components of the vector
    ---@param self IIVector
    ---@return number X X component
    ---@return number Y Y component
    ---@return number Z Z component
    getVector = function (self)
        return self[1], self[2], self[3]
    end,
    ---@endsection

    ---@section copyVector
    ---Copies another vector
    ---@param self IIVector
    ---@param other IIVector The vector to copy
    copyVector = function (self, other)
        self:setVector(other:getVector())
    end,
    ---@endsection

    ---@section cloneVector
    ---Clones the vector
    ---@param self IIVector
    ---@return IIVector Clone
    cloneVector = function (self)
        return IIVector(self:getVector())
    end,
    ---@endsection

    ---@section isNotZero
    ---Checks if any component of the vector is not 0
    ---@param self IIVector
    ---@return boolean isNotZero True if any component is not 0
    isNotZero = function (self)
        return self[1] ~= 0 or self[2] ~= 0 or self[3] ~= 0
    end,
    ---@endsection
}
---@endsection IIVECTORCLASS

---@section IIMatrix 1 IIMATRIXCLASS
---@class IIMatrix
---@field x IIVector Initial x row. Defaults to all 0
---@field y IIVector Initial y row. Defaults to all 0
---@field z IIVector Initial z row. Defaults to all 0
IIMatrix = {
    ---Creates a new matrix
    ---@param self IIMatrix
    ---@param x IIVector
    ---@param y IIVector
    ---@param z IIVector
    ---@overload fun():IIMatrix Creates a new vector with 0 for all dimensions
    ---@return IIMatrix Matrix
    new = function (self, x, y, z)
        return appendTable({x or IIVector:new(), y or IIVector:new(), z or IIVector:new()}, self)
    end,

    ---@section setMatrix
    ---Sets the rows of the matrix
    ---@param self IIMatrix
    ---@param x IIVector
    ---@param y IIVector
    ---@param z IIVector
    setMatrix = function (self, x, y, z)
        self[1]:setVector(x)
        self[2]:setVector(y)
        self[3]:setVector(z)
    end,
    ---@endsection

    ---@section copyMatrix
    ---Copies another matrix
    ---@param self IIMatrix
    ---@param other IIMatrix The matrix to copy
    copyMatrix = function (self, other)
        for i = 1, 3 do
            self[i]:copyVector(other[i])
        end
    end,
    ---@endsection

    ---@section matrixMultiply
    ---Multiplies the matrix by another
    ---@param self IIMatrix
    ---@param other IIMatrix
    ---@param transpose boolean Set to true to transpose matrix B, leave empty otherwise
    ---@return IIMatrix Matrix The matrix result from A X B
    matrixMultiply = function (self, other, transpose)
        local result = {}
        for i, row in ipairs(self) do
            result[i] = IIVector:new()
            for j = 1, #other[1] do
                if transpose then
                    result[i][j] = row:dot(other[j])
                else
                    result[i][j] = row:dot({other[1][j], other[2][j], other[3][j]})
                end
            end
        end
        return result
    end,
    ---@endsection

    ---@section transposedMultiply
    ---Multiplies the matrix by another
    ---@param self IIMatrix
    ---@param other IIMatrix
    transposedMultiply = function (self, other)
        local result = {}
        for k, row in ipairs(self) do
            result[k] = IIVector:new()
            for j = 1, #other[1] do
                result[k][j] = row:dot(other[j])
            end
        end
        self:copyMatrix(result)
    end,
    ---@endsection
}
---@endsection IIMATRIXCLASS