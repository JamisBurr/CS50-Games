-- Powerup Class

Powerup = Class{}

function Powerup:init(type, lockedBrickIndex)
    -- Initialize properties like position, type, etc.
    self.x = 0
    self.y = 0
    self.width = 16  -- Assuming the powerup is 16 pixels wide
    self.dy = 30 -- Falling speed
    self.type = type  -- Type of the power-up (e.g., 1 for ball, 2 for key)
    self.lockedBrickIndex = lockedBrickIndex
    -- Other properties...
end

function Powerup:update(dt)
    self.y = self.y + self.dy * dt
    -- Add any other update logic needed
end

function Powerup:collides(paddle)
    -- AABB (Axis-Aligned Bounding Box) collision detection
    if self.x > paddle.x + paddle.width or paddle.x > self.x + 16 then
        return false
    end

    if self.y > paddle.y + paddle.height or paddle.y > self.y + 16 then
        return false
    end 

    return true
end

function Powerup:render()
    -- Use self.type to determine which sprite to render
    if self.type == 1 then
        -- Render the sprite for the regular ball powerup
        love.graphics.draw(gTextures['main'], gFrames['powerups'][1], self.x, self.y)
        
    elseif self.type == 2 then
        love.graphics.draw(gTextures['main'], gFrames['powerups'][2], self.x, self.y)
    end
end