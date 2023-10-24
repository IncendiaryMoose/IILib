-- Author: Incendiary Moose
-- GitHub: <GithubLink>
-- Workshop: https://steamcommunity.com/profiles/76561198050556858/myworkshopfiles/?appid=573090
--
--- Developed using LifeBoatAPI - Stormworks Lua plugin for VSCode - https://code.visualstudio.com/download (search "Stormworks Lua with LifeboatAPI" extension)
--- If you have any issues, please report them here: https://github.com/nameouschangey/STORMWORKS_VSCodeExtension/issues - by Nameous Changey

require('II_MathHelpers')

---@section floatToInteger
---Converts a float to an integer factor of itself.
---@param float number Any number.
---@param minInput number The smallest expected float.
---@param inputRange number The expected range of the input.
---@param maxInteger integer The maximum integer to output. Resolution is inputRange/maxInteger.
---@return integer factor
function floatToInteger(float, minInput, inputRange, maxInteger)
    return IIfloor(clamp((float - minInput) / inputRange, 0, 1) * maxInteger + 0.5)
end
---@endsection

---@section fastFloatToInteger
---Converts a float to an integer factor of itself. Avoids using division.
---@param float number Any number.
---@param minInput number The smallest expected float.
---@param conversionRatio number Float equal to (1 / inputRange * maxInteger)
---@param maxInteger integer The maximum integer to output. Resolution is inputRange/maxInteger.
---@return integer factor
function fastFloatToInteger(float, minInput, conversionRatio, maxInteger)
    return clamp(IIfloor((float - minInput) * conversionRatio + 0.5), 0, maxInteger)
end
---@endsection

---@section integerToFloat
---Converts an integer to a float using itself as a factor.
---@param integer integer Any integer.
---@param minInput number The smallest expected float.
---@param inputRange number The expected range of the input.
---@param maxInteger integer The maximum integer to output. Resolution is inputRange/maxInteger.
---@return integer factor
function integerToFloat(integer, minInput, inputRange, maxInteger)
    return integer / maxInteger * inputRange + minInput
end
---@endsection

---@section fastIntegerToFloat
---Converts an integer to a float using itself as a factor.
---@param integer integer Any integer.
---@param minInput number The smallest expected float.
---@param conversionRatio number Float equal to (1 / maxInteger * inputRange)
---@return integer factor
function fastIntegerToFloat(integer, minInput, conversionRatio)
    return integer * conversionRatio + minInput
end
---@endsection

---@section checkBit
---Checks if the bit at the given location is set
---@param integer integer The integer to check the bits from.
---@param bit integer The bit to check, with 1 being the rightmost bit.
---@return boolean isBitSet True if the bit is 1, false if it is 0.
function checkBit(integer, bit)
    return integer >> (bit - 1) & 1 == 1
end
---@endsection

---@section setBit
---Sets a bit in a given integer at a given location
---@param integer integer The integer to set the bits from.
---@param bit integer The bit to set, with 1 being the rightmost bit.
---@return integer integer The input, with the given bit set.
function setBit(integer, bit)
    return integer | (1 << (bit - 1))
end
---@endsection

---@section binaryToOutput
---Converts an integer into a 32-bit float with the same binary representation.
---@param binary integer An integer containing the binary to encode.
---@return number encodedBinary A 32-bit float conaining the same binary as the input integer.
function binaryToOutput(binary)
    local exponent = binary >> 23 & 255
    return ((2^23 - 1 & binary) / 2^23 + (exponent > 0 and 1 or 0)) * 2 ^ IImax(exponent - 127, -126) * (binary < 1 << 31 ~ binary and 1 or -1)
end
---@endsection

---@section safeBinaryToOutput
---Converts a 31-bit integer into a 32-bit float for sending over composite
---@param binary integer An integer containing the binary to encode.
---@return number encodedBinary A 32-bit float containing the encoded integer
function safeBinaryToOutput(binary)
    local exponent = binary >> 23 & 2^7 - 1
    return ((2^23 - 1 & binary) / 2^23 + (exponent > 0 and 1 or 0)) * 2 ^ IImax(exponent - 127, -126) * (binary < 1 << 30 ~ binary and 1 or -1)
end
---@endsection

---@section safeInputToBinary
---Decodes an input channel into a 31-bit integer.
---@param channel integer The channel to read from.
---@return integer binary The decoded integer.
function safeInputToBinary(channel)
    local float = input.getNumber(channel)
    local exponent = IIfloor(IIlog(IIabs(float), 2) + 0.00000001) -- Very small offset is to fix rounding error.
    return IIfloor(IIabs(float) * 2 ^ IImin(23 - exponent, 149) + 0.5) & 8388607 | IImax(exponent + 127, 0) << 23 | (1/float < 0 and 1 << 30 or 0)
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
    return ((2^mantissaBits - 1 & binary) / 2^mantissaBits + (exponent > 0 and 1 or 0)) * 2 ^ IImax(exponent - bias, -bias + 1) * ((unsigned or (binary < 1 << exponentBits + mantissaBits ~ binary)) and 1 or -1)
end
---@endsection

---@section inputToBinary
---Converts an input channel into an integer with the same binary representation.
---@param channel integer The channel to read from.
---@return integer binary The binary representation of the input float, stored as an integer.
function inputToBinary(channel)
    local float = input.getNumber(channel)
    local exponent = IIfloor(IIlog(IIabs(float), 2) + 0.00000001) -- Very small offset is to fix rounding error.
    return IIfloor(IIabs(float) * 2 ^ IImin(23 - exponent, 149) + 0.5) & 8388607 | IImax(exponent + 127, 0) << 23 | (1/float < 0 and 1 << 31 or 0)
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
        if int6 then
            encodedString = encodedString << 6 | (int6 == 95 and 37 or int6 < 58 and int6 - 47 or int6 < 90 and int6 - 54 or int6 - 59)
        end
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
        if int6 ~= 0 then
            decodedString = decodedString..string.char(int6 == 37 and 95 or int6 < 11 and int6 + 47 or int6 < 37 and int6 + 54 or int6 + 59)
        end
    end
    return decodedString
end
---@endsection