-- Author: Incendiary Moose
-- GitHub: <GithubLink>
-- Workshop: https://steamcommunity.com/profiles/76561198050556858/myworkshopfiles/?appid=573090
--
--- Developed using LifeBoatAPI - Stormworks Lua plugin for VSCode - https://code.visualstudio.com/download (search "Stormworks Lua with LifeboatAPI" extension)
--- If you have any issues, please report them here: https://github.com/nameouschangey/STORMWORKS_VSCodeExtension/issues - by Nameous Changey

require('II_MathHelpers')

---@section binaryToOutput
---Converts an integer into a 32-bit float with the same binary representation.
---@param binary integer An integer containing the binary to encode.
---@return number encodedBinary A 32-bit float conaining the same binary as the input integer.
function binaryToOutput(binary)
    local exponent = binary >> 23 & 2^8 - 1
    return ((2^23 - 1 & binary) / 2^23 + (exponent > 0 and 1 or 0)) * 2 ^ IImax(exponent - 127, -126) * (binary < 1 << 31 ~ binary and 1 or -1)
end
---@endsection

---@section floatToBinary
---Converts a float into an integer with the same binary representation, with inputs to control the standard to convert to.
---@param float number The value to encode into binary.
---@param exponentBits integer The amount of bits to allocate to the exponent. This will determine the distance between the smallest and largest possible value.
---@param mantissaBits integer The amount of bits to allocate to the mantissa / fraction. This will determine the precision of the stored value.
---@param bias integer The offset to apply to the exponent. This will determine how small of a number can be stored.
---@param unsigned boolean Leave empty to generate a signed float, pass a value to generate an unsigned float.
---A signed float will be one bit longer than exponentBits + mantissaBits, while an unsigned float will not, however an unsigned float will not store a negative sign if it is present.
---@return unknown
function floatToBinary(float, exponentBits, mantissaBits, bias, unsigned)
    local exponent = IIfloor(IIlog(IIabs(float), 2))
    return IImax(exponent + bias, 0) << mantissaBits | ((float > 0 or unsigned) and 0 or 1 << mantissaBits + exponentBits) | IIfloor((IIabs(float) / 2 ^ IImax(exponent, -bias + 1))%1 * 2^mantissaBits + 0.5)
end
---@endsection

---@section binaryToFloat
---Converts the binary of an integer into a float of any standard.
---@param binary integer An integer containing the binary that will be used to generate a float.
---@param exponentBits integer How many bits from the binary should be used for the exponent.
---@param mantissaBits integer How many bits from the binary should be used for the mantissa / fraction. This does not include the implied bit.
---@param bias integer The offset to apply to the exponent's value when computing the result.
---@param unsigned boolean Leave empty to generate a signed float, pass a value to generate an unsigned float.
---A signed float will use the bit exponentBits + mantissaBits + 1 places from the right as the sign. An unsigned float will ignore this bit.
---@return number decodedFloat The closest possible 64-bit float to the float created using the input standard.
function binaryToFloat(binary, exponentBits, mantissaBits, bias, unsigned)
    local exponent = binary >> mantissaBits & 2^exponentBits - 1
    return ((2^mantissaBits - 1 & binary) / 2^mantissaBits + (exponent > 0 and 1 or 0)) * 2 ^ IImax(exponent - bias, -bias + 1) * (unsigned or binary < 1 << exponentBits + mantissaBits ~ binary and 1 or -1)
end
---@endsection

---@section inputToBinary
---Converts a 32-bit float into an integer with the same binary representation.
---@param float number A 32-bit float.
---@return integer binary The binary representation of the input float, stored as an integer.
function inputToBinary(float)
    local exponent = IIfloor(IIlog(IIabs(float), 2) + 0.00000001) -- Very small offset is to fix rounding error.
    return IImax(exponent + 127, 0) << 23 | ((float < 0 or (float == 0 and #tostring(float) == 4)) and 1 << 31 or 0) | IIfloor(IIabs(float) / 2 ^ IImax(exponent, -126)%1 * 2^23 + 0.5)
end
---@endsection

---@section stringTo6BitInts
---Converts the characters from startChar to endChar in a string into 6-bit integers.
---@param str string Characters must only be 0-9, _, a-z, and A-Z.
---@param startChar integer The position of the first character to encode.
---@param endChar integer The position of the last character to encode.
---@return integer encodedString An integer who's binary is the 6-bit characters spliced together.
function stringTo6BitInts(str, startChar, endChar)
    local encodedString = 0
    for i = startChar, endChar do
        local int6 = str:byte(i)
        encodedString = encodedString << 6 | (int6 == 95 and 36 or int6 < 58 and int6 - 48 or int6 < 91 and int6 - 55 or int6 - 60)
    end
    return encodedString
end
---@endsection

---@section int30ToString
---Converts 30 bits of an integer into a string.
---@param int30 integer An integer containing 30 bits generated by stringTo6BitInts.
---@return string decodedString A string containing characters based on the encoding used in stringTo6BitInts.
function int30ToString(int30)
    local decodedString = ''
    for i = 4, 0, -1 do
        local int6 = int30 >> i*6 & 2^6 - 1
        decodedString = decodedString..string.char(int6 == 36 and 95 or int6 < 10 and int6 + 48 or int6 < 36 and int6 + 55 or int6 + 60)
    end
    return decodedString
end
---@endsection