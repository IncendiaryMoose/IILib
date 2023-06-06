-- Author: Incendiary Moose
-- GitHub: <GithubLink>
-- Workshop: https://steamcommunity.com/profiles/76561198050556858/myworkshopfiles/?appid=573090
--
--- Developed using LifeBoatAPI - Stormworks Lua plugin for VSCode - https://code.visualstudio.com/download (search "Stormworks Lua with LifeboatAPI" extension)
--- If you have any issues, please report them here: https://github.com/nameouschangey/STORMWORKS_VSCodeExtension/issues - by Nameous Changey

outputNumbers = {}
outputBools = {}

---@section clearOutputs
function clearOutputs()
    for i = 1, 32 do
        outputNumbers[i] = 0
        outputBools[i] = false
    end
end
---@endsection

---@section setOutputs
function setOutputs()
    for i = 1, 32 do
        output.setNumber(i, outputNumbers[i])
        output.setBool(i, outputBools[i])
    end
end
---@endsection