local Player = require("src.player")
local Enemy = require("src.enemy")

Game = {}

function Game:new()
    local newObj = {
        state = "menu",
        player = Player:new(100, 500),
        enemies = {},           -- list of enemies
        spawnDelay = 2,         -- seconds between spawns
        spawnTimer = 0,
        maxEnemies = 5,
    }
    self.__index = self
    return setmetatable(newObj, self)
end

function Game:load()
    self.state = "menu"
    self.enemies = {}
    self.spawnTimer = 0
    -- Spawn first enemy at start position
    table.insert(self.enemies, Enemy:new(800, 500))
end

function Game:update(dt)
    if self.state == "play" then
        self.player:update(dt)

        -- Update all enemies
        for i = #self.enemies, 1, -1 do
            local e = self.enemies[i]
            e:update(dt, self.player)

            -- Optional: Remove enemy from list if dead (if you want cleanup)
            -- But here we keep it to control spawn timing
        end

        -- Check last enemy and spawn new after delay if dead
        local lastEnemy = self.enemies[#self.enemies]

        if lastEnemy and lastEnemy.isDead then
            self.spawnTimer = self.spawnTimer + dt
            if self.spawnTimer >= self.spawnDelay and #self.enemies < self.maxEnemies then
                self.spawnTimer = 0
                -- Spawn new enemy, you can randomize position or keep fixed
                table.insert(self.enemies, Enemy:new(800, 500))
            end
        else
            -- Reset spawn timer if last enemy alive
            self.spawnTimer = 0
        end
    end
end

function Game:draw()
    if self.state == "menu" then
        love.graphics.printf("Press Enter to Start Pirate Wars", 0, love.graphics.getHeight() / 2, love.graphics.getWidth(), "center")
    elseif self.state == "play" then
        self.player:draw()
        for _, e in ipairs(self.enemies) do
            e:draw()
        end
    end
end

function Game:keypressed(key)
    if self.state == "menu" and key == "return" then
        self.state = "play"
    elseif self.state == "play" then
        -- Pass first alive enemy for attack checks
        local targetEnemy = nil
        for _, e in ipairs(self.enemies) do
            if not e.isDead then
                targetEnemy = e
                break
            end
        end
        self.player:keypressed(key, targetEnemy)
    end
end

return Game:new()
