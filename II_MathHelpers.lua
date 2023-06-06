-- Author: Incendiary Moose
-- GitHub: <GithubLink>
-- Workshop: https://steamcommunity.com/profiles/76561198050556858/myworkshopfiles/?appid=573090
--
--- Developed using LifeBoatAPI - Stormworks Lua plugin for VSCode - https://code.visualstudio.com/download (search "Stormworks Lua with LifeboatAPI" extension)
--- If you have any issues, please report them here: https://github.com/nameouschangey/STORMWORKS_VSCodeExtension/issues - by Nameous Changey

---@section IIfloor
IIfloor = math.floor
---@endsection

---@section IIlog
IIlog = math.log
---@endsection

---@section IIabs
IIabs = math.abs
---@endsection

---@section PI
PI = math.pi
---@endsection

---@section PI2
PI2 = PI*2
---@endsection

---@section HUGE
HUGE = math.huge
---@endsection

---@section e
e = 2.71828182846 --2.71828182845904523536028747135266249775724709369995
---@endsection

---@section wrappedDifference
---Deals with radian wrapparound
---@param theta1 number Angle in radians
---@param theta2 number Angle in radians
---@return number theta The smallest angle that can be added to theta1 to reach theta2
function wrappedDifference(theta1, theta2)
    return (theta2 - theta1 + PI)%PI2 - PI
end
---@endsection

---@section IImin
---Faster version of math.min()
---@param n1 number
---@param n2 number
---@return number min The smaller number between n1 and n2
function IImin(n1, n2)
    return n1 < n2 and n1 or n2
end
---@endsection

---@section IImax
---Faster version of math.max()
---@param n1 number
---@param n2 number
---@return number max The larger number between n1 and n2
function IImax(n1, n2)
    return n1 > n2 and n1 or n2
end
---@endsection

---@section clamp
---Clamps n to range [lowerBound, upperBound]
---@param n number The number to clamp
---@param lowerBound number The lower limit
---@param upperBound number The upper limit
---@return number clamped n limited to the range of [lowerBound, upperBound]
function clamp(n, lowerBound, upperBound)
    return IImin(IImax(n, lowerBound), upperBound)
end
---@endsection


---@section clampAbs
---Clamps n to range [-absBound, absBound]
---@param n number The number to clamp
---@param absBound number Clamp range to use
---@return number clamped n limited to the range of [-absBound, absBound]
function clampAbs(n, absBound)
    return IImin(IImax(n, -absBound), absBound)
end
---@endsection

---@section sign
---Finds the sign of n
---@param n number
---@return integer sign The sign of n. Returns -1 if n < 0, otherwise returns 1
function sign(n)
    return n < 0 and -1 or 1
end
---@endsection

---@section normalize
---Normalizes n to range [-1, 1], using range [lowerBound, upperBound]
---@param n number Number to normalize
---@param lowerBound number smallest expected value of n
---@param upperBound number largest expected value of n
---@return number normalized n mapped from range [lowerBound, upperBound] to [-1, 1] and clamped to [-1, 1]
function normalize(n, lowerBound, upperBound)
    return clamp((n - lowerBound)/(upperBound - lowerBound)*2 - 1, -1, 1)
end
---@endsection

---@section hugeIfZero
---Huge if n is 0, n otherwise
---@param n number
---@return number nOrHuge Huge if n is 0, n otherwise
function hugeIfZero(n)
    return n == 0 and HUGE or n
end
---@endsection

---@section arccos
---The arccos of n, restricted to the domain of arccos
---@param n number
---@return number arccos The arccos of n, where n is limited to range [-1, 1]
function arccos(n)
    return math.acos(clampAbs(n, 1))
end
---@endsection

---@section arcsin
---The arcsin of n, restricted to the domain of arcsin
---@param n number
---@return number arccos The arcsin of n, where n is limited to range [-1, 1]
function arcsin(n)
    return math.asin(clampAbs(n, 1))
end
---@endsection