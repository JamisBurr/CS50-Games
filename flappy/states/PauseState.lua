--[[
    PlayState Class
    Author: Jamis Burr

    The PauseState class is the break state of the game, where the player and all gameplay stop functioning temp.
]]

PauseState = Class{__includes = BaseState}

function PauseState:enter(params)
    self.previousState = params.previousState
    sounds['music']:pause()
end

function PauseState:update(dt)
    if love.keyboard.wasPressed('p') then
        sounds['music']:play()
        gStateMachine:change(self.previousState)
    end
end

function PauseState:render()
    -- Render a pause message
    love.graphics.setFont(flappyFont)
    love.graphics.printf('Game Paused', 0, VIRTUAL_HEIGHT / 2 - 16, VIRTUAL_WIDTH, 'center')
    love.graphics.setFont(mediumFont)
    love.graphics.printf('Press P to Resume', 0, VIRTUAL_HEIGHT / 2 + 16, VIRTUAL_WIDTH, 'center')
end
