local Player = require("src.player")
local Enemy = require("src.enemy")

Game = {}

function Game:new()
    local newObj = {
        state = "menu",
        player = Player:new(100, 500),
        enemies = {},
        waveNumber = 1,
        enemiesToSpawn = 3,
        enemiesSpawned = 0,
        spawnDelay = 1.5,
        spawnTimer = 0,
        spawning = true,
        bossSpawned = false,
    }
    self.__index = self
    return setmetatable(newObj, self)
end

function Game:load()
    self.state = "menu"
    self.waveNumber = 1
    self.enemiesToSpawn = 3
    self.enemiesSpawned = 0
    self.spawnTimer = 0
    self.enemies = {}
    self.bossSpawned = false
    self.spawning = true
    self.player = Player:new(100, 500)
end

function Game:update(dt)
    if self.state == "play" then
        self.player:update(dt)

        -- Enemy spawn logic
        if self.spawning and self.enemiesSpawned < self.enemiesToSpawn then
            self.spawnTimer = self.spawnTimer + dt
            if self.spawnTimer >= self.spawnDelay then
                self.spawnTimer = 0
                table.insert(self.enemies, Enemy:new(800, 500))
                self.enemiesSpawned = self.enemiesSpawned + 1
            end
        elseif not self.bossSpawned and self:allEnemiesDefeated() then
            self:spawnBoss()
        elseif self.bossSpawned and self:allEnemiesDefeated() then
            self:startNextWave()
        end

        -- Update all enemies
        for _, enemy in ipairs(self.enemies) do
            enemy:update(dt, self.player)
        end

        -- End condition
        if self.player.y > love.graphics.getHeight() then
            self.state = "gameover"
        end
    end
end

function Game:allEnemiesDefeated()
    for _, enemy in ipairs(self.enemies) do
        if not enemy.isDead then
            return false
        end
    end
    return true
end

function Game:spawnBoss()
    local boss = Enemy:new(800, 500)
    boss.health = 200 -- double regular enemy
    boss.maxHealth = 200
    boss.isBoss = true
    boss.speed = 150
    table.insert(self.enemies, boss)
    self.bossSpawned = true
    print("Boss spawned!")
end

function Game:startNextWave()
    self.waveNumber = self.waveNumber + 1
    self.enemiesToSpawn = 2 + self.waveNumber  -- increase enemies per wave
    self.enemiesSpawned = 0
    self.spawnTimer = 0
    self.spawning = true
    self.bossSpawned = false
    self.enemies = {}
    print("Wave " .. self.waveNumber)
end

function Game:draw()
    if self.state == "menu" then
        love.graphics.printf("🏴‍☠️ PIRATE WARS\nPress [Enter] to Start", 0, love.graphics.getHeight() / 2 - 40, love.graphics.getWidth(), "center")
    elseif self.state == "play" then
        self.player:draw()
        for _, enemy in ipairs(self.enemies) do
            enemy:draw()
        end
        love.graphics.print("Wave: " .. self.waveNumber, 10, 10)
        love.graphics.print("Press [P] to Pause", 10, 30)
    elseif self.state == "pause" then
        love.graphics.printf("⏸️ PAUSED\nPress [P] to Resume\n[Q] to Quit", 0, love.graphics.getHeight() / 2, love.graphics.getWidth(), "center")
    elseif self.state == "gameover" then
        love.graphics.printf("💀 GAME OVER 💀\nPress [R] to Restart\n[Q] to Quit", 0, love.graphics.getHeight() / 2, love.graphics.getWidth(), "center")
    end
end

function Game:keypressed(key)
    if self.state == "menu" and key == "return" then
        self:load()
        self.state = "play"
    elseif self.state == "play" then
        if key == "p" then
            self.state = "pause"
        else
            for _, e in ipairs(self.enemies) do
                if not e.isDead then
                    self.player:keypressed(key, e)
                    break
                end
            end
        end
    elseif self.state == "pause" then
        if key == "p" then
            self.state = "play"
        elseif key == "q" then
            love.event.quit()
        end
    elseif self.state == "gameover" then
        if key == "r" then
            self:load()
            self.state = "play"
        elseif key == "q" then
            love.event.quit()
        end
    end
end

return Game:new()