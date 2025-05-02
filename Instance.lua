local Instance = {}
Instance.Instances = {}

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

    local obj = existingClass.new()
    obj.ClassName = class

    function obj:IsA(class)
        return self.ClassName == class
    end



    table.insert(Instance.Instances, obj)

    return obj
end

return Instance