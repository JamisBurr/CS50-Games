--[[
    GD50
    Legend of Zelda

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

EntityWalkState = Class{__includes = BaseState}

function EntityWalkState:init(entity)
    self.entity = entity    
    
    self.entity:changeAnimation('walk-down')

    -- used for AI control
    self.moveDuration = 0
    self.movementTimer = 0

    -- keeps track of whether we just hit a wall
    self.bumped = false
end

function EntityWalkState:update(dt)

    -- assume we didn't hit a wall
    self.bumped = self:checkForCollisions(dt)    
end

function EntityWalkState:processAI(params, dt)
    local room = params.room
    local directions = {'left', 'right', 'up', 'down'}

    if self.moveDuration == 0 or self.bumped then
        
        -- set an initial move duration and direction
        self.moveDuration = math.random(5)
        self.entity.direction = directions[math.random(#directions)]
        self.entity:changeAnimation('walk-' .. tostring(self.entity.direction))
    elseif self.movementTimer > self.moveDuration then
        self.movementTimer = 0

        -- chance to go idle
        if math.random(3) == 1 then
            self.entity:changeState('idle')
        else
            self.moveDuration = math.random(5)
            self.entity.direction = directions[math.random(#directions)]
            self.entity:changeAnimation('walk-' .. tostring(self.entity.direction))
        end
    end

    self.movementTimer = self.movementTimer + dt
end

function EntityWalkState:render()
    local anim = self.entity.currentAnimation
    love.graphics.draw(gTextures[anim.texture], gFrames[anim.texture][anim:getCurrentFrame()],
        math.floor(self.entity.x - self.entity.offsetX), math.floor(self.entity.y - self.entity.offsetY))
    
    -- debug code
    -- love.graphics.setColor(255, 0, 255, 255)
    -- love.graphics.rectangle('line', self.entity.x, self.entity.y, self.entity.width, self.entity.height)
    -- love.graphics.setColor(255, 255, 255, 255)
end

function EntityWalkState:checkForCollisions(dt)
    if self.entity.direction == 'left' then
        self.entity.x = self.entity.x - self.entity.walkSpeed * dt
        
        -- check for left wall collisions
        if self.entity.x <= MAP_RENDER_OFFSET_X + TILE_SIZE then 
            self.entity.x = MAP_RENDER_OFFSET_X + TILE_SIZE
            return true
        end 

        -- check for left solid object collisions
        if self:checkForCollisionWithObjects() then
            self.entity.x = self.entity.x + self.entity.walkSpeed * dt
            return true
        end
    
    -- check for collisions to the right
    elseif self.entity.direction == 'right' then
        self.entity.x = self.entity.x + self.entity.walkSpeed * dt

        -- check for right wall collisions
        if self.entity.x + self.entity.width >= VIRTUAL_WIDTH - TILE_SIZE * 2 then
            self.entity.x = VIRTUAL_WIDTH - TILE_SIZE * 2 - self.entity.width
            return true
        end

         -- check for right solid object collisions
         if self:checkForCollisionWithObjects() then
            self.entity.x = self.entity.x - self.entity.walkSpeed * dt
            return true
        end

    -- check for collisions at the top    
    elseif self.entity.direction == 'up' then
        self.entity.y = self.entity.y - self.entity.walkSpeed * dt

        -- check for top wall collision
        if self.entity.y <= MAP_RENDER_OFFSET_Y + TILE_SIZE - self.entity.height / 2 then 
            self.entity.y = MAP_RENDER_OFFSET_Y + TILE_SIZE - self.entity.height / 2
            return true
        end

        -- check for top solid object collision
        if self:checkForCollisionWithObjects() then
            self.entity.y = self.entity.y + self.entity.walkSpeed * dt
            return true
        end
        
    -- check for collisions at the bottom 
    elseif self.entity.direction == 'down' then
        self.entity.y = self.entity.y + self.entity.walkSpeed * dt

        local bottomEdge = VIRTUAL_HEIGHT - (VIRTUAL_HEIGHT - MAP_HEIGHT * TILE_SIZE) 
            + MAP_RENDER_OFFSET_Y - TILE_SIZE

        -- check for bottom wall collision
        if self.entity.y + self.entity.height >= bottomEdge then
            self.entity.y = bottomEdge - self.entity.height
            return true
        end

        -- check for bottom solid object collision
        if self:checkForCollisionWithObjects() then
            self.entity.y = self.entity.y - self.entity.walkSpeed * dt
            return true
        end
    end
end

function EntityWalkState:checkForCollisionWithObjects()
    if self.entity.room then
        local objects = self.entity.room.objects
        for k, object in pairs(objects) do
            if self.entity:collides(object) and object.solid then
                return true
            end
        end
    end
    return false
end
