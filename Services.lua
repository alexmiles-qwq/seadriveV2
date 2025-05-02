local Services = {}


-- Services Managment

---Add Own Services
---@param servicename string
---@param table table
function Services:AddService(servicename, table)
    local success, err = pcall(function()
        self[servicename] = table
    end)

   if success then
        print("Service "..servicename.." was registered.")
   else
    print("An error occured while trying to regiser a server "..servicename..": "..tostring(err))
    end
end
---Return Service Module if it exist.
---@param servicename string
---@return table
function Services:GetService(servicename)
    local serv = self[servicename]

    if serv and type(serv) == 'table' then return serv else
        error("No Service "..servicename.." Found!")
    end
end


Services:AddService("DataStoreService", require("./Services/DataStoreService"))


return Services