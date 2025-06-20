Player = {}

function Player:new(x, y)
    local newObj = {
        x = x,
        y = y,
        vx = 0,
        vy = 0,
        speed = 200,
        jumpForce = -400,
        gravity = 800,
        onGround = false,

        spriteSheet = love.graphics.newImage("assets/player_sprites.png"),
        quads = {},
        currentFrame = 1,          -- always show first frame
        frameWidth = 133,
        frameHeight = 100,
        scaleX = 4,
        scaleY = 4,
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

    newObj.w = newObj.frameWidth * newObj.scaleX
    newObj.h = newObj.frameHeight * newObj.scaleY

    self.__index = self
    return setmetatable(newObj, self)
end

function Player:update(dt)
    -- Apply gravity & movement
    self.vy = self.vy + self.gravity * dt
    self.y = self.y + self.vy * dt

    if love.keyboard.isDown("a") then
        self.vx = -self.speed
    elseif love.keyboard.isDown("d") then
        self.vx = self.speed
    else
        self.vx = 0
    end

    self.x = self.x + self.vx * dt

    -- Ground collision
    if self.y + self.h >= 600 then
        self.y = 600 - self.h
        self.vy = 0
        self.onGround = true
    else
        self.onGround = false
    end
end

function Player:draw()
    love.graphics.setColor(1, 1, 1)
    -- Draw sprite shifted down by 72.5% of scaled height
    love.graphics.draw(
        self.spriteSheet,
        self.quads[1],
        self.x,
        self.y + (self.frameHeight * self.scaleY) * 0.725,
        0,
        self.scaleX,
        self.scaleY
    )
end

function Player:keypressed(key, enemy)
    if key == "space" and self.onGround then
        self.vy = self.jumpForce
    elseif key == "f" then
        print("Attack!")
        local attackRange = 50
        if enemy and math.abs(self.x - enemy.x) < attackRange then
            enemy:takeDamage(10)
            print("Enemy hit! Health now:", enemy.health)
        end
    end
end

return Player
