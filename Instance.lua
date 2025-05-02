local Instance = {}

local UserInstance = require("./classes/user")
local QAInstance = require("./classes/qa")

local classes = {}

classes["User"] = UserInstance
classes["QA"] = QAInstance
classes["Event"] = require("./classes/Event")

function Instance.new(class)
    local existingClass = classes[class]
    if not existingClass then
        error("Class '"..class.."' does not exist.")
    end

    return existingClass.new()
end

return Instance