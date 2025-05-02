local qa = {}
qa.__index = qa

function qa.new()
    local self = setmetatable({}, qa)

    self.Content = "Content"
    self.AuthorId = 0

    return self

end

function qa:GetAuthorId()
    return self.AuthorId
end

return qa