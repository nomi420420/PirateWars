local Game = require("src.game")

local background
local bgX, bgY
local scaleX, scaleY

function love.load()
    background = love.graphics.newImage("assets/background.png")
    Game:load()
    
    local windowWidth, windowHeight = love.graphics.getWidth(), love.graphics.getHeight()
    local imgWidth, imgHeight = background:getWidth(), background:getHeight()
    
    scaleX = 1.5  -- stretch horizontally by 150% (wider to cover)
    scaleY = 1.25 -- stretch vertically by 125%

    local bgWidth, bgHeight = imgWidth * scaleX, imgHeight * scaleY

    -- Center horizontally and vertically
    bgX = (windowWidth - bgWidth) / 2
    bgY = (windowHeight - bgHeight) / 2
end

function love.update(dt)
    Game:update(dt)
end

function love.draw()
    love.graphics.draw(background, bgX, bgY, 0, scaleX, scaleY)
    Game:draw()
end

function love.keypressed(key)
    Game:keypressed(key)
end
