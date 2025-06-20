-- Stage logic will go here

Stage = {}

function Stage:new()
    local newObj = {}
    self.__index = self
    return setmetatable(newObj, self)
end