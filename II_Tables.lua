-- Author: Incendiary Moose
-- GitHub: <GithubLink>
-- Workshop: https://steamcommunity.com/profiles/76561198050556858/myworkshopfiles/?appid=573090
--
--- Developed using LifeBoatAPI - Stormworks Lua plugin for VSCode - https://code.visualstudio.com/download (search "Stormworks Lua with LifeboatAPI" extension)
--- If you have any issues, please report them here: https://github.com/nameouschangey/STORMWORKS_VSCodeExtension/issues - by Nameous Changey

---@section appendTable
---Adds all items from the reference table into the table, with the same keys
---@param table table
---@param referenceTable table
function appendTable(table, referenceTable)
    for key, item in pairs(referenceTable) do
        table[key] = item
    end
    return table
end
---@endsection

---@section joinTables
---Adds the values of tableB in range [startIndex, endIndex] to the end of tableA
---@param tableA table The table to add to
---@param tableB table The table to add from
---@param startIndex integer The first index of tableB to join
---@param endIndex integer The last index of tableB to join
function joinTables(tableA, tableB, startIndex, endIndex)
    for index = startIndex, endIndex do
        tableA[#tableA+1] = tableB[index]
    end
end
---@endsection