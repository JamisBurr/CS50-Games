BrickLocked = Class{__includes = Brick}

function BrickLocked:init(x, y)
    -- Initialize the locked brick
    -- Call the base class constructor
    Brick.init(self, x, y)

    -- Set specific properties for the locked brick
    self.isLocked = true
end

function BrickLocked:hit()
    if self.isLocked then
        print("Hit locked brick, not breaking")
        -- gSounds['locked']:play()
    else
        print("Hit unlocked brick, should break")
        Brick.hit(self)
    end
end

function BrickLocked:update(dt)
    -- Implement any update logic here, or leave empty if not needed
end

function BrickLocked:render()
    if self.inPlay then
        if self.isLocked then           
            love.graphics.draw(gTextures['main'], gFrames['keyBricks'], self.x, self.y)
        else            
            Brick.render(self)
        end
    end
end

function BrickLocked:renderParticles()
    -- If you want to have a particle effect for locked bricks, add it here
    -- Otherwise, you can leave this empty if locked bricks don't have particle effects
end