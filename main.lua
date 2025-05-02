local StartTime = os.clock()

local config = require("./config")
local json = require("json")
_G.CONFIG = config

local Instance = require("./Instance")
_G.Instance = Instance
local Services = require("./Services")
_G.Services = Services

local function QnaEncode()
    local data = {}

    for key, obj in pairs(Instance.Instances) do
        
        if obj:IsA("QA") then
            local info = {}

            info.AuthorId = obj.AuthorId
            info.Question = obj.Question
            info.Answer = obj.Answer

            table.insert(data, info)
        end

    end

    local encoded = json.stringify(data)
    return encoded

end

local function QnaDecode(data)

    local decoded = json.decode(data)

    for key, obj in pairs(decoded) do
        local Qa = Instance.new('QA')

        Qa.AuthorId = obj.AuthorId
        Qa.Question = obj.Question
        Qa.Answer = obj.Answer
    end
    
end


local DataStoreService = Services:GetService("DataStoreService")  

local UsersDS = DataStoreService:GetDataStore("Users")        -- Each key = Each User.
local QnA_DS = DataStoreService:GetDataStore("QnA")            -- The only key has to be "Main"

local QnAdata = QnA_DS:GetSync("Main") or nil     -- keys

QnaDecode(QnAdata)



local EndTime = os.clock() - StartTime
print("Ready. Took: "..tostring(EndTime).."ms.")

