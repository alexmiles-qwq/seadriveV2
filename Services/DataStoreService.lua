local DataStoreService = {}

local DEBUGENABLED = _G.CONFIG.debug

local http = require('http')
local json = require('json')

local utils = require("../utils")

local DATA = {}

-- Helpers

-- Just a pretty print
local function print2(prefix, str)
    local stringi = '['..prefix..']: '..tostring(str)
    print(stringi)
end

-- Prints a message if debugging is enabled
local function dprint(...)
    if not DEBUGENABLED then
         return
    end
    
    print(...)
end

-- Prints a message if debugging is enabled, using print2()
local function dprint2(prefix, str)
    if not DEBUGENABLED then
         return
    end
    
    print2(prefix, str)
end

local root = process.cwd()
local DataStoreFolder = utils:FindDir(root.."/DataStore")

dprint2("DataStore Service", "Root folder: " .. tostring(root))
dprint2("DataStore Service", "Data Store Folder: " .. tostring(DataStoreFolder))

if DataStoreFolder == false then
    utils:CreateDirSync(root.."/DataStore")
end

function DataStoreService:GetDataStore(storename)
    dprint2("DataStore", "Providing Datastore "..tostring(storename))

    storename = tostring(storename)
    local folder = utils:FindDir(root.."/DataStore/"..storename)
    if not folder then
        dprint2("DataStore", "No Datastore " .. storename .. " was found. Creating...")
        utils:CreateDirSync(root.."/DataStore/"..storename)
    end

    local DataStore = {}
    DataStore.Path = root.."/DataStore/"..storename
    dprint2("DataStore", "Datastore path: "..DataStore.Path)


    function DataStore:GetSync(key, callback)
        key = tostring(key)

        dprint2("DataStore", "Datastore ".. storename.." reqires key: "..key)
        
        local foundkey = utils:FindFileSync(self.Path .. "/" .. key)
        if foundkey then
            
            dprint2("DataStore", "Key found for Datastore ".. storename..". Reqired key: "..key)

            local data = utils:ReadFileSync(self.Path .. "/" .. key)
            return data
        end

    end

    function DataStore:SetSync(key, data)
        key = tostring(key)

        dprint2("DataStore", "Datastore ".. storename.." writes key: "..key)
        
        utils:WriteFileSync(self.Path .. "/" .. key, data)
    end

    return DataStore
end

dprint2("DataStore Service", "Ready.")

return DataStoreService
