--[[
    GD50
    Breakout Remake

    -- PlayState Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    Represents the state of the game in which we are actively playing;
    player should control the paddle, with the ball actively bouncing between
    the bricks, walls, and the paddle. If the ball goes below the paddle, then
    the player should lose one point of health and be taken either to the Game
    Over screen if at 0 health or the Serve screen otherwise.
]]

PlayState = Class{__includes = BaseState}

--[[
    We initialize what's in our PlayState via a state table that we pass between
    states as we go from playing to serving.
]]
function PlayState:enter(params)
    self.paddle = params.paddle
    self.bricks = params.bricks
    self.health = params.health
    self.score = params.score
    self.highScores = params.highScores
    self.balls = { params.ball }
    self.level = params.level

    self.recoverPoints = 5000

    -- give ball random starting velocity
    for k, ball in pairs(self.balls) do
        ball.dx = math.random(-200, 200)
        ball.dy = math.random(-50, -60)
    end

    -- Calculate the initial paddle growth threshold based on the current score
    if self.score < 5000 then
        self.paddleGrowThreshold = 5000
    else
        self.paddleGrowThreshold = math.ceil(self.score / 5000) * 5000
    end  
    
    -- Initialize powerups
    self.powerups = {} -- Table to hold powerup instances
    
    self.needsKeyPowerup = params.needsKeyPowerup
    self.keyPowerupBrickIndex = params.keyPowerupBrickIndex
    -- Consider adding a print statement here for debugging
    print("Entered PlayState with keyPowerupBrickIndex: " .. tostring(self.keyPowerupBrickIndex))

    self.lockedBrickIndex = params.lockedBrickIndex
    
end

function PlayState:update(dt)
    if self.paused then
        if love.keyboard.wasPressed('space') then
            self.paused = false
            gSounds['pause']:play()
        else
            return
        end
    elseif love.keyboard.wasPressed('space') then
        self.paused = true
        gSounds['pause']:play()
        return
    end

    -- update positions based on velocity
    self.paddle:update(dt)
    
    -- Update each ball in the self.balls table
    for k, ball in pairs(self.balls) do
        ball:update(dt)

        -- Ball collision with paddle
        if ball:collides(self.paddle) then
            -- raise ball above paddle in case it goes below it, then reverse dy
            ball.y = self.paddle.y - 8
            ball.dy = -ball.dy

            --
            -- tweak angle of bounce based on where it hits the paddle
            --

            -- if we hit the paddle on its left side while moving left...
            if ball.x < self.paddle.x + (self.paddle.width / 2) and self.paddle.dx < 0 then
                ball.dx = -50 + -(8 * (self.paddle.x + self.paddle.width / 2 - ball.x))
            
            -- else if we hit the paddle on its right side while moving right...
            elseif ball.x > self.paddle.x + (self.paddle.width / 2) and self.paddle.dx > 0 then
                ball.dx = 50 + (8 * math.abs(self.paddle.x + self.paddle.width / 2 - ball.x))
            end

            gSounds['paddle-hit']:play()    
        end

        -- detect collision across all bricks with the ball
        for k, brick in pairs(self.bricks) do
            -- only check collision if we're in play
            if brick.inPlay and ball:collides(brick) then
                print("Brick hit at index:", k, "Key Powerup Brick Index:", self.keyPowerupBrickIndex, "Needs Key Powerup:", self.needsKeyPowerup)             
                -- add to score
                self.score = self.score + (brick.tier * 200 + brick.color * 25)

                -- Increase paddle size at the current threshold
                if self.score > self.paddleGrowThreshold and self.paddle.size < 3 then
                    self.paddle:setSize(self.paddle.size + 1)

                    -- Increase the threshold by an additional 5000 points
                    self.paddleGrowThreshold = self.paddleGrowThreshold + 5000
                end

                -- trigger the brick's hit function, which removes it from play
                brick:hit()

                -- if we have enough points, recover a point of health
                if self.score > self.recoverPoints then
                    -- can't go above 3 health
                    self.health = math.min(3, self.health + 1)

                    -- multiply recover points by 2
                    self.recoverPoints = self.recoverPoints + math.min(100000, self.recoverPoints * 2)

                    -- play recover sound effect
                    gSounds['recover']:play()
                end

                -- go to our victory screen if there are no more bricks left
                if self:checkVictory() then
                    -- Ensure there is at least one ball in the table
                    if #self.balls > 0 then
                        gSounds['victory']:play()
                        gStateMachine:change('victory', {
                            level = self.level,
                            paddle = self.paddle,
                            health = self.health,
                            score = self.score,
                            highScores = self.highScores,
                            ball = self.balls[1],  -- Pass the first ball from the list
                            recoverPoints = self.recoverPoints
                        })
                    end
                end

                --
                -- collision code for bricks
                --
                -- we check to see if the opposite side of our velocity is outside of the brick;
                -- if it is, we trigger a collision on that side. else we're within the X + width of
                -- the brick and should check to see if the top or bottom edge is outside of the brick,
                -- colliding on the top or bottom accordingly 
                --

                -- left edge; only check if we're moving right, and offset the check by a couple of pixels
                -- so that flush corner hits register as Y flips, not X flips
                if ball.x + 2 < brick.x and ball.dx > 0 then
                    
                    -- flip x velocity and reset position outside of brick
                    ball.dx = -ball.dx
                    ball.x = brick.x - 8
                
                -- right edge; only check if we're moving left, , and offset the check by a couple of pixels
                -- so that flush corner hits register as Y flips, not X flips
                elseif ball.x + 6 > brick.x + brick.width and ball.dx < 0 then
                    
                    -- flip x velocity and reset position outside of brick
                    ball.dx = -ball.dx
                    ball.x = brick.x + 32
                
                -- top edge if no X collisions, always check
                elseif ball.y < brick.y then
                    
                    -- flip y velocity and reset position outside of brick
                    ball.dy = -ball.dy
                    ball.y = brick.y - 8
                
                -- bottom edge if no X collisions or top collision, last possibility
                else
                    
                    -- flip y velocity and reset position outside of brick
                    ball.dy = -ball.dy
                    ball.y = brick.y + 16
                end

                -- slightly scale the y velocity to speed up the game, capping at +- 150
                if math.abs(ball.dy) < 150 then
                    ball.dy = ball.dy * 1.02
                end                

                -- Check if the current brick is the one with the key powerup
                if k == self.keyPowerupBrickIndex and self.needsKeyPowerup then
                    print("Key powerup brick hit. Spawning key powerup.")
                    local keyPowerup = Powerup(2, self.lockedBrickIndex) -- Pass lockedBrickIndex to the powerup
                
                    -- Calculate the centered x position for the powerup
                    keyPowerup.x = brick.x + (brick.width / 2) - (keyPowerup.width / 2)
                    keyPowerup.y = brick.y
                
                    table.insert(self.powerups, keyPowerup)
                    self.needsKeyPowerup = false              
                elseif math.random(1, 8) == 1 then
                    -- Similar calculation for other powerups
                    if not brick.isLocked then
                        if k ~= self.keyPowerupBrickIndex then
                            local powerup = Powerup(1) -- Type 1 for ball powerup
                            powerup.x = brick.x + (brick.width / 2) - (powerup.width / 2)
                            powerup.y = brick.y
                            table.insert(self.powerups, powerup)
                        end
                    end
                end
            end      
        end        

        if ball.y >= VIRTUAL_HEIGHT then
            -- Remove the ball from play
            table.remove(self.balls, k)

            -- If no more balls are in play, then decrease health and change state
            if #self.balls == 0 then
                self.health = self.health - 1
                gSounds['hurt']:play()

                -- Shrink the paddle if health is lost
                if self.paddle.size > 1 then
                    self.paddle:setSize(self.paddle.size - 1)
                end

                if self.health == 0 then
                    gStateMachine:change('game-over', {
                        score = self.score,
                        highScores = self.highScores
                    })
                else
                    gStateMachine:change('serve', {
                        paddle = self.paddle,
                        bricks = self.bricks,
                        health = self.health,
                        score = self.score,
                        highScores = self.highScores,
                        level = self.level,
                        recoverPoints = self.recoverPoints
                    })
                end
                -- Break the loop since the state has changed
                break                
            end
        end
    end

    -- for rendering particle systems
    for k, brick in pairs(self.bricks) do
        brick:update(dt)
    end

    if love.keyboard.wasPressed('escape') then
        love.event.quit()
    end

    -- Update powerups in PlayState:update
    for k, powerup in pairs(self.powerups) do
        powerup:update(dt)
        if powerup:collides(self.paddle) then
            print("Powerup collided with paddle. Type:", powerup.type, "Locked Brick Index:", self.lockedBrickIndex)
            if powerup.type == 1 then
                self:spawnExtraBalls(2)
            elseif powerup.type == 2 then
                print("Unlocking brick at index", powerup.lockedBrickIndex)
                self:unlockAllLockedBricks(powerup.lockedBrickIndex)
            end
            table.remove(self.powerups, k)
        end
    end
end

function PlayState:spawnExtraBalls(count)
    for i = 1, count do
        -- Create a new ball instance
        local extraBall = Ball()

        -- Initialize extraBall's properties 
        local referenceBall = self.balls[1]
        extraBall.x = referenceBall.x
        extraBall.y = referenceBall.y
        extraBall.dx = math.random(-200, 200)
        extraBall.dy = math.random(-50, -60)

        -- Randomly select a skin for the new ball
        -- Assuming you have a set number of skins, say 7
        extraBall.skin = math.random(7)

        -- Add the new ball to your balls table
        table.insert(self.balls, extraBall)
    end
end

function PlayState:unlockAllLockedBricks()
    print("Unlock function called")
    if self.lockedBrickIndex then
        local brick = self.bricks[self.lockedBrickIndex]
        if brick and brick.isLocked then
            print("Unlocking brick at index", self.lockedBrickIndex)
            brick.isLocked = false

            -- Calculate the maximum color and tier based on the current level
            local highestTier = math.min(3, math.floor(self.level / 5))
            local highestColor = math.min(5, self.level % 5 + 3)

            -- Use a slightly lower maximum tier and color for the unlocked brick
            local unlockedTier = math.max(0, highestTier - 1)
            local unlockedColor = math.max(1, highestColor - 1)

            -- Assign color and tier within the adjusted limits
            brick.color = math.random(1, unlockedColor)
            brick.tier = math.random(0, unlockedTier)
        else
            print("Brick already unlocked or not found at index", self.lockedBrickIndex)
        end
    else
        print("No locked brick index found")
    end
end



function PlayState:render()
    -- render bricks
    for k, brick in pairs(self.bricks) do
        brick:render()
    end

    -- render all particle systems
    for k, brick in pairs(self.bricks) do
        brick:renderParticles()
    end

    self.paddle:render()

    -- render each ball in the self.balls table
    for k, ball in pairs(self.balls) do
        ball:render()
    end

    renderScore(self.score)
    renderHealth(self.health)

    -- pause text, if paused
    if self.paused then
        love.graphics.setFont(gFonts['large'])
        love.graphics.printf("PAUSED", 0, VIRTUAL_HEIGHT / 2 - 16, VIRTUAL_WIDTH, 'center')
    end

    -- Render powerups
    for k, powerup in pairs(self.powerups) do
        powerup:render()
    end
end

function PlayState:checkVictory()
    for k, brick in pairs(self.bricks) do
        if brick.inPlay then
            return false
        end 
    end

    return true
end