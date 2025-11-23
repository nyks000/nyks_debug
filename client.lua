-- client.lua
-- RedM Ultimate Developer Debugger
-- Author: Nyks
-- Description: Identifies the script owner of entities and generates search queries for VS Code.

---------------------------------------------------------------------------------
-- DATAVIEW HELPER CLASS (Required for Notifications)
---------------------------------------------------------------------------------
local DataView = {
    EndBig = ">",
    EndLittle = "<",
    Types = {
        Int8 = { code = "i1", size = 1 },
        Uint8 = { code = "I1", size = 1 },
        Int16 = { code = "i2", size = 2 },
        Uint16 = { code = "I2", size = 2 },
        Int32 = { code = "i4", size = 4 },
        Uint32 = { code = "I4", size = 4 },
        Int64 = { code = "i8", size = 8 },
        Uint64 = { code = "I8", size = 8 },
        LuaInt = { code = "j", size = 8 },
        UluaInt = { code = "J", size = 8 },
        LuaNum = { code = "n", size = 8 },
        Float32 = { code = "f", size = 4 },
        Float64 = { code = "d", size = 8 },
        String = { code = "z", size = -1 },
    },
    Fixed = {
        String = function(len) return { code = "c" .. len, size = len } end,
        Stringz = function(len) return { code = "z" .. len, size = len } end,
    },
}

function DataView.ArrayBuffer(length)
    return {
        offset = 0,
        length = length,
        blob = string.rep("\0", length),
        _view = function(self, type, offset, value)
            local p = offset + 1
            if value ~= nil then
                local s = string.pack(DataView.EndLittle .. type.code, value)
                self.blob = self.blob:sub(1, p - 1) .. s .. self.blob:sub(p + type.size)
                return self
            else
                local v = string.unpack(DataView.EndLittle .. type.code, self.blob, p)
                return v
            end
        end,
        SetInt32 = function(self, offset, value) return self:_view(DataView.Types.Int32, offset, value) end,
        SetInt64 = function(self, offset, value) return self:_view(DataView.Types.Int64, offset, value) end,
        Buffer = function(self) return self.blob end
    }
end
function BigInt(n) return n end -- Simple helper for Lua 5.3+ environments usually found in RedM
---------------------------------------------------------------------------------

local debugMode = false
local drawDistance = 12.0 

-- Helper: Send Left Top Notification (Using DataView)
local function Notify(text)
    local str = CreateVarString(10, "LITERAL_STRING", text)
    
    -- Prepare Struct for Notification
    local struct = DataView.ArrayBuffer(8*7)
    struct:SetInt64(8*0, BigInt(0))
    struct:SetInt64(8*1, BigInt(0))
    struct:SetInt64(8*2, BigInt(0))
    struct:SetInt64(8*3, BigInt(0))
    struct:SetInt64(8*4, BigInt(str))
    struct:SetInt64(8*5, BigInt(0))
    struct:SetInt64(8*6, BigInt(0))
    
    -- _UI_FEED_POST_SAMPLE_TOAST
    Citizen.InvokeNative(0x049D5C62F1997D8B, struct:Buffer(), 1) 
end

-- Helper: Get Population Type String
local function GetPopTypeString(entity)
    local popType = GetEntityPopulationType(entity)
    -- 7: Mission/Script, 6: Map/Permanent, 4/5: Random/Ambient
    if popType == 7 then return "~g~SCRIPT/MISSION" end
    if popType == 6 then return "~r~MAP/PERMANENT" end
    return "~y~RANDOM/WORLD"
end

-- Helper: Draw 3D Text
local function DrawText3D(x, y, z, text)
    local onScreen, _x, _y = GetScreenCoordFromWorldCoord(x, y, z)
    if onScreen then
        SetTextScale(0.32, 0.32)
        SetTextFontForCurrentCommand(1)
        SetTextColor(255, 255, 255, 235)
        SetTextCentre(1)
        SetTextDropshadow(1, 0, 0, 0, 255)
        local str = CreateVarString(10, "LITERAL_STRING", text)
        DisplayText(str, _x, _y)
    end
end

-- Function: Print Detailed Info to F8 Console
local function PrintDetailedEntityInfo()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    
    local pools = { GetGamePool('CPed'), GetGamePool('CObject'), GetGamePool('CVehicle') }
    local closestEntity = nil
    local closestDist = 6.0 

    -- Find closest entity
    for _, pool in ipairs(pools) do
        for _, entity in ipairs(pool) do
            if DoesEntityExist(entity) and entity ~= playerPed then
                local dist = #(playerCoords - GetEntityCoords(entity))
                if dist < closestDist then
                    closestDist = dist
                    closestEntity = entity
                end
            end
        end
    end

    if closestEntity then
        local scriptName = GetEntityScript(closestEntity)
        local modelHash = GetEntityModel(closestEntity)
        local modelHex = string.format("0x%X", modelHash)
        local coords = GetEntityCoords(closestEntity)
        local heading = GetEntityHeading(closestEntity)
        
        print("\n^2################ [NYKS DEBUGGER ANALYSIS] ################^0")
        print("^7Paste the following lines into VS Code 'Search' (Ctrl+Shift+F):^0")
        print("------------------------------------------------")
        print(string.format("^31. HEX Code (Best): ^2%s", modelHex))
        print(string.format("^32. Hash Number: ^2%s", modelHash))
        print(string.format("^33. X Coordinate (Fast): ^2%.2f", coords.x))
        print(string.format("^34. Vector3: ^2vector3(%.2f, %.2f, %.2f)", coords.x, coords.y, coords.z))
        print(string.format("^35. Native Create: ^2CreateObject(%s", modelHash))
        print("------------------------------------------------")
        
        if scriptName then
            print("^2[SOURCE FOUND] This entity belongs to script: ^7" .. string.upper(scriptName) .. "^0")
        else
            print("^1[NO SCRIPT SOURCE] This is a Map or World object.^0")
        end
        print("^2##########################################################^0\n")
        
        Notify("Info copied to F8 Console!")
    else
        Notify("~r~No entity found nearby!")
    end
end

-- Command: Toggle Debug Mode
RegisterCommand('nyksdebug', function()
    debugMode = not debugMode
    if debugMode then
        print("^2[NYKS] Debug Mode: ENABLED.^0")
        Notify("Debug Mode: ~g~ENABLED")
    else
        Notify("Debug Mode: ~r~DISABLED")
    end
end)

-- Command: Get Info / Copy Log
RegisterCommand('getinfo', function()
    if debugMode then
        PrintDetailedEntityInfo()
    else
        Notify("~r~Enable debug mode first! (/nyksdebug)")
    end
end)

-- Main Thread
Citizen.CreateThread(function()
    while true do
        local sleep = 1500 
        if debugMode then
            sleep = 0
            local playerPed = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPed)
            local pools = { GetGamePool('CPed'), GetGamePool('CObject'), GetGamePool('CVehicle') }

            for _, pool in ipairs(pools) do
                for _, entity in ipairs(pool) do
                    if DoesEntityExist(entity) and entity ~= playerPed then
                        local entCoords = GetEntityCoords(entity)
                        local dist = #(playerCoords - entCoords)

                        if dist <= drawDistance then
                            local modelHex = string.format("0x%X", GetEntityModel(entity))
                            local scriptName = GetEntityScript(entity) or "NONE"
                            local popType = GetPopTypeString(entity)
                            
                            local displayText = string.format(
                                "~y~HEX: %s~s~\nScript: %s\nType: %s\n~b~X: %.1f", 
                                modelHex, 
                                string.upper(scriptName),
                                popType,
                                entCoords.x
                            )
                            
                            DrawText3D(entCoords.x, entCoords.y, entCoords.z + 0.85, displayText)
                        end
                    end
                end
            end
        end
        Citizen.Wait(sleep)
    end
end)