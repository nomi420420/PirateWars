-- Enemy logic

Enemy = {}

function Enemy:new(x, y)
    local newObj = {
        x = x,
        y = y,
        vx = 0,
        vy = 0,
        speed = 100,
        gravity = 800,
        health = 100,
        onGround = false,
        isHit = false,
        hitTimer = 0,
        isDead = false,
        scale = 4,  -- scale sprite 4x

        -- Load sprite sheet and setup quads for 6x6 frames
        spriteSheet = love.graphics.newImage("assets/enemy_sprites.png"),
        quads = {},
        currentFrame = 1,   -- static first frame for now
        frameWidth = 100,
        frameHeight = 100,
    }

    local sheetWidth = newObj.spriteSheet:getWidth()
    local sheetHeight = newObj.spriteSheet:getHeight()

    local cols = 6
    local rows = 6

    for row = 0, rows - 1 do
        for col = 0, cols - 1 do
            local quad = love.graphics.newQuad(
                col * newObj.frameWidth,
                row * newObj.frameHeight,
                newObj.frameWidth,
                newObj.frameHeight,
                sheetWidth,
                sheetHeight
            )
            table.insert(newObj.quads, quad)
        end
    end

    newObj.w = newObj.frameWidth * newObj.scale
    newObj.h = newObj.frameHeight * newObj.scale

    self.__index = self
    return setmetatable(newObj, self)
end

function Enemy:update(dt, player)
    if self.isDead then return end

    self.vy = self.vy + self.gravity * dt
    self.y = self.y + self.vy * dt

    if self.y + self.h >= 600 then
        self.y = 600 - self.h
        self.vy = 0
        self.onGround = true
    else
        self.onGround = false
    end

    -- Simple AI follows the player
    if player.x < self.x then
        self.x = self.x - self.speed * dt
    elseif player.x > self.x then
        self.x = self.x + self.speed * dt
    end

    -- Handle hit flash timer
    if self.isHit then
        self.hitTimer = self.hitTimer - dt
        if self.hitTimer <= 0 then
            self.isHit = false
        end
    end
end

function Enemy:draw()
    if self.isDead then return end

    if self.isHit then
        love.graphics.setColor(1, 1, 0) -- flash yellow when hit
    else
        love.graphics.setColor(1, 1, 1) -- normal white for sprite
    end

    -- Flip sprite horizontally by scaling -scale on x, and offset x by width*scale to align properly
    local flipX = -self.scale
    local drawX = self.x + self.w

    local drawY = self.y + (self.frameHeight * self.scale) * 0.725

    love.graphics.draw(
        self.spriteSheet,
        self.quads[self.currentFrame],
        drawX,
        drawY,
        0,
        flipX,
        self.scale
    )

    -- HP bar setup
    local fullBarWidth = self.w * 0.25  -- 25% width of sprite
    local barHeight = 10
    local barX = self.x + (self.w - fullBarWidth) / 2
    local barY = self.y - barHeight - 2  -- 2 pixels above sprite

    -- Draw HP bar background (black, semi-transparent)
    love.graphics.setColor(0, 0, 0, 0.6)
    love.graphics.rectangle("fill", barX, barY, fullBarWidth, barHeight)

    -- Draw health amount (red)
    local healthWidth = (self.health / 100) * fullBarWidth
    love.graphics.setColor(1, 0, 0)
    love.graphics.rectangle("fill", barX, barY, healthWidth, barHeight)

    love.graphics.setColor(1, 1, 1) -- reset color
end

function Enemy:takeDamage(amount)
    if self.isDead then return end

    self.health = self.health - amount
    self.isHit = true
    self.hitTimer = 0.2

    if self.health <= 0 then
        self.health = 0
        self.isDead = true
        print("Enemy defeated!")
    end
end

return Enemy
