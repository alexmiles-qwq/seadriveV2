local StartTime = os.clock()

local config = require("./config")
_G.CONFIG = config

local Instance = require("./Instance")
_G.Instance = Instance
local Services = require("./Services")
_G.Services = Services

local DataStoreService = Services:GetService("DataStoreService")  



local UsersDS = DataStoreService:GetDataStore("Users")        -- Each key = Each User.
local QnA_DS = DataStoreService:GetDataStore("QnA")            -- The only key has to be "Main"

local QnAdata = QnA_DS:GetSync("Main") or nil     -- key

local EndTime = os.clock() - StartTime
print("Ready. Took: "..tostring(EndTime).."ms.")

