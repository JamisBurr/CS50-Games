--[[
    GD50
    Pokemon

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

MenuState = Class{__includes = BaseState}

function MenuState:init(battleState, stats, onClose)
    -- function to be called once this message is popped
    self.onClose = onClose or function() end

    self.statIncreaseMenu = Menu {        
        x = battleState.playerHealthBar.x,
        y = 8,
        width = math.abs(battleState.playerHealthBar.x - VIRTUAL_WIDTH),
        height = battleState.playerHealthBar.y - 10 - 10,
        font = gFonts['medium'],
        align = 'left',
        items = {
            {
                text = self:statText(' HP', battleState.playerPokemon.HP - stats['HPIncrease'], stats['HPIncrease']),
                    onSelect = function() end
            },
            {
                text = self:statText(' Atk', battleState.playerPokemon.attack - stats['attackIncrease'], stats['attackIncrease']),
                    onSelect = function() end
            },
            {
                text = self:statText(' Def', battleState.playerPokemon.defense - stats['defenseIncrease'], stats['defenseIncrease']),
                    onSelect = function() end
            },
            {
                text = self:statText(' Spd', battleState.playerPokemon.speed - stats['speedIncrease'], stats['speedIncrease']),
                    onSelect = function() end
            },
        }
    }
    -- turn off selection so all the items are gonna display like a list without selection or cursor
    self.statIncreaseMenu.selection:selectionOff()
end

function MenuState:update(dt)
    self.statIncreaseMenu:update(dt)
    if love.keyboard.wasPressed('space') or love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
        gStateStack:pop()
        self.onClose()
    end
end

function MenuState:render()
    gFonts['medium']:setFilter('nearest', 'nearest')
    love.graphics.setFont(gFonts['medium'])
    self.statIncreaseMenu:render()
end

function MenuState:statText(stateLabel, currentValue, increase)
    return stateLabel .. ': ' .. tostring(currentValue) .. '+' .. tostring(increase)
        .. ' = ' .. '(' .. tostring(currentValue + increase) .. ')'
end