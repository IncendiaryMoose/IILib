-- Author: Incendiary Moose
-- GitHub: <GithubLink>
-- Workshop: https://steamcommunity.com/profiles/76561198050556858/myworkshopfiles/?appid=573090
--
--- Developed using LifeBoatAPI - Stormworks Lua plugin for VSCode - https://code.visualstudio.com/download (search "Stormworks Lua with LifeboatAPI" extension)
--- If you have any issues, please report them here: https://github.com/nameouschangey/STORMWORKS_VSCodeExtension/issues - by Nameous Changey

--TODO: Rewrite with bitwise functions

require('II_MathHelpers')

---@section binaryToOutput
function binaryToOutput(binaryTable)
    bitsCompleted = bitsCompleted + 1
    local exponent, sign, mantissa = 0, binaryTable[bitsCompleted] and -1 or 1

    for bitIndex = 1, 8 do
        bitsCompleted = bitsCompleted + 1
        exponent = binaryTable[bitsCompleted] and exponent + 2 ^ (8 - bitIndex) or exponent
    end

    mantissa = exponent > 0 and 1 or 0
    for bitIndex = 1, 23 do
        bitsCompleted = bitsCompleted + 1
        mantissa = binaryTable[bitsCompleted] and mantissa + 1 / 2 ^ bitIndex or mantissa
    end

    --print(string.format('Exponent = %.0f\nMantissa = %.16f\nValue = %.64f', exponent, mantissa, float))

    return mantissa * sign * 2 ^ IImax(exponent - 127, -126)
end
---@endsection

---@section floatToBinary
function floatToBinary(float, exponentBits, mantissaBits, bias, binaryTable, unsigned)

    binaryTable[#binaryTable + 1] = float < 0 -- Sign bit
    float = IIabs(float) -- Sign is no longer needed, and would cause problems

    local exponent, startIndex, mantissa, factor = IIfloor(IIlog(float, 2)), #binaryTable - (unsigned and 1 or 0) -- Determine what exponent is needed, and how much to offset it (based on the bits allocated to it)

    mantissa = (float / 2 ^ IImax(exponent, -bias + 1))%1 -- Also known as the significand

    --print(string.format('Exponent = %.0f\nMantissa = %.16f\nValue = %.64f', exponent, mantissa, float))

    exponent = IImax(exponent + bias, 0)
    for bitIndex = exponentBits, 1, -1 do
        binaryTable[startIndex + bitIndex] = exponent%2 == 1
        exponent = exponent // 2
    end

    for bitIndex = 1, mantissaBits - 1 do
        factor = 1 / 2 ^ bitIndex
        binaryTable[#binaryTable + 1] = mantissa >= factor
        mantissa = mantissa%factor
    end

    if mantissa >= 1 / 2 ^ mantissaBits then -- If the next digit would have been a 1, then rounding up will improve accuracy
        for bitIndex = 0, mantissaBits - 2 do
            binaryTable[#binaryTable - bitIndex] = not binaryTable[#binaryTable - bitIndex]
            if binaryTable[#binaryTable - bitIndex] then break end
        end
    end
end
---@endsection

---@section binaryToFloat
function binaryToFloat(binaryTable, exponentBits, mantissaBits, bias, startBit, unsigned)
    local exponent, sign, bitCount, mantissa = 0, unsigned and 1 or binaryTable[startBit] and -1 or 1, unsigned and 0 or 1

    for bitIndex = 1, exponentBits do
        exponent = binaryTable[startBit + bitCount] and exponent + 2 ^ (exponentBits - bitIndex) or exponent
        bitCount = bitCount + 1
    end

    mantissa = exponent > 0 and 1 or 0
    for bitIndex = 1, mantissaBits - 1 do
        mantissa = binaryTable[startBit + bitCount] and mantissa + 1 / 2 ^ bitIndex or mantissa
        bitCount = bitCount + 1
    end

    --print(string.format('Exponent = %.0f\nMantissa = %.16f\nValue = %.64f', exponent, mantissa, float))

    return mantissa * 2 ^ IImax(exponent - bias, -bias + 1) * sign
end
---@endsection

---@section inputToBinary
function inputToBinary(float)
    local numBits = {float < 0}
    float = IIabs(float) -- Sign is no longer needed, and would cause problems

    local exponent, mantissa, factor = IIfloor(IIlog(float, 2)) -- Determine what exponent is needed, and how much to offset it (based on the bits allocated to it)

    mantissa = (float / 2 ^ IImax(exponent, -126))%1 -- Also known as the significand

    --print(string.format('Exponent = %.0f\nMantissa = %.16f\nValue = %.64f', exponent, mantissa, float))

    exponent = IImax(exponent + 127, 0)
    for bitIndex = 8, 1, -1 do
        numBits[1 + bitIndex] = exponent%2 == 1
        exponent = exponent // 2
    end

    for bitIndex = 1, 23 do
        factor = 1 / 2 ^ bitIndex
        numBits[#numBits + 1] = mantissa >= factor
        mantissa = mantissa%factor
    end
    return numBits
end
---@endsection

---@section intToBinary
function intToBinary(num, bits)
    local remainder = num
    local result = {}
    local bitCount = 0
    while remainder > 0 or bitCount < bits do
        table.insert(result, remainder%2 == 1)
        remainder = remainder//2
        bitCount = bitCount + 1
    end
    return result
end
---@endsection

---@section binaryToInt
function binaryToInt(binary)
    local result = 0
    for i, bit in ipairs(binary) do
        if bit then
            result = result + 2^(i-1)
        end
    end
    return result
end
---@endsection