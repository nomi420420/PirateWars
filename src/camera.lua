-- Camera control

Camera = {}

function Camera:new()
    local newObj = {}
    self.__index = self
    return setmetatable(newObj, self)
end