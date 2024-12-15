--[[
    ScoreState Class
    Author: Colton Ogden
    cogden@cs50.harvard.edu

    A simple state used to display the player's score before they
    transition back into the play state. Transitioned to from the
    PlayState when they collide with a Pipe.
]]

ScoreState = Class{__includes = BaseState}

function ScoreState:init()
    -- load medal images
    self.bronzeMedal = love.graphics.newImage('images/bronzeMedal.png')
    self.silverMedal = love.graphics.newImage('images/silverMedal.png')
    self.goldMedal = love.graphics.newImage('images/goldMedal.png')
end

--[[
    When we enter the score state, we expect to receive the score
    from the play state so we know what to render to the State.
]]
function ScoreState:enter(params)
    self.score = params.score

    -- determine which medal to award based on the score
    if self.score > 20 then
        self.medal = self.goldMedal
    elseif self.score > 10 then
        self.medal = self.silverMedal
    elseif self.score >= 5 then
        self.medal = self.bronzeMedal
    else
        self.medal = nil
    end
end

function ScoreState:update(dt)
    -- go back to play if enter is pressed
    if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
        gStateMachine:change('countdown')
    end
end

function ScoreState:render()
    -- simply render the score to the middle of the screen
    love.graphics.setFont(flappyFont)
    love.graphics.printf('Oof! You lost!', 0, 64, VIRTUAL_WIDTH, 'center')

    love.graphics.setFont(mediumFont)
    love.graphics.printf('Score: ' .. tostring(self.score), 0, 100, VIRTUAL_WIDTH, 'center')

    love.graphics.printf('Press Enter to Play Again!', 0, 170, VIRTUAL_WIDTH, 'center')

    -- render medal if one was awarded
    if self.medal then
        -- scale factors
        local scaleX = 0.5 -- scale down to 50% of original size on x-axis
        local scaleY = 0.5 -- scale down to 50% of original size on y-axis

        -- adjust the position as needed
        love.graphics.draw(self.medal, VIRTUAL_WIDTH / 2 - (self.medal:getWidth() * scaleX) / 2, 120, 0, scaleX, scaleY)
    end
end