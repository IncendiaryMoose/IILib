-- Author: Incendiary Moose
-- GitHub: <GithubLink>
-- Workshop: https://steamcommunity.com/profiles/76561198050556858/myworkshopfiles/?appid=573090
--
--- Developed using LifeBoatAPI - Stormworks Lua plugin for VSCode - https://code.visualstudio.com/download (search "Stormworks Lua with LifeboatAPI" extension)
--- If you have any issues, please report them here: https://github.com/nameouschangey/STORMWORKS_VSCodeExtension/issues - by Nameous Changey

require('II_MathHelpers')

---@section binaryToOutput
function binaryToOutput(binary)
    local exponent = binary >> 23 & 2^8 - 1

    -- print(string.format('Exponent = %.0f\nMantissa = %.16f', exponent, mantissa))

    return ((2^23 - 1 & binary) / 2^23 + (exponent > 0 and 1 or 0)) * 2 ^ IImax(exponent - 127, -126) * (binary < 1 << 31 ~ binary and 1 or -1)
end
---@endsection

---@section floatToBinary
function floatToBinary(float, exponentBits, mantissaBits, bias, unsigned)
    local exponent = IIfloor(IIlog(IIabs(float), 2))
    return IImax(exponent + bias, 0) << mantissaBits | (float > 0 or unsigned and 0 or 1 << mantissaBits + exponentBits) | IIfloor((IIabs(float) / 2 ^ IImax(exponent, -bias + 1))%1 * 2^mantissaBits + 0.5)
end
---@endsection

---@section binaryToFloat
function binaryToFloat(binary, exponentBits, mantissaBits, bias, unsigned)
    local exponent = binary >> mantissaBits & 2^exponentBits - 1

    -- print(string.format('Exponent = %.0f\nMantissa = %.16f', exponent, mantissa))

    return ((2^mantissaBits - 1 & binary) / 2^mantissaBits + (exponent > 0 and 1 or 0)) * 2 ^ IImax(exponent - bias, -bias + 1) * (unsigned or binary < 1 << exponentBits + mantissaBits ~ binary and 1 or -1)
end
---@endsection

---@section inputToBinary
function inputToBinary(float)
    local exponent = IIfloor(IIlog(IIabs(float), 2))
    return IImax(exponent + 127, 0) << 23 | (float < 0 and 1 << 31 or 0) | IIfloor((IIabs(float) / 2 ^ IImax(exponent, -126))%1 * 2^23 + 0.5)
end
---@endsection