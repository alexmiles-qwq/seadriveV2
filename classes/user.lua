local user = {}
user.__index = user

function user.new()
    local self = setmetatable({}, user)


    self.v = 1

    self.UserId = 0
    self.Username = "defaultUsername"
    self.DisplayName = "Default User"
    self.Description = "Default User's Description"

    self.QuestionIds = {}      -- Contain ids of messages

    return self

end


function user:HasQuestion(id)
    return table.find(self.QuestionIds, id)
end

function user:GetUserId(id)
    return self.UserId
end

function user:ReturnDataToSave()
    local data = {}

    for k, v in pairs(self) do
        if type(v) == "function" then
            goto continue
        end        

        data[k] = v

        ::continue::
    end   
    
    return data
end

return user