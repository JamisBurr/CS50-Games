--[[
    GD50
    Match-3 Remake

    -- PlayState Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    State in which we can actually play, moving around a grid cursor that
    can swap two tiles; when two tiles make a legal swap (a swap that results
    in a valid match), perform the swap and destroy all matched tiles, adding
    their values to the player's point score. The player can continue playing
    until they exceed the number of points needed to get to the next level
    or until the time runs out, at which point they are brought back to the
    main menu or the score entry menu if they made the top 10.
]]

PlayState = Class{__includes = BaseState}

function PlayState:init()
    
    -- start our transition alpha at full, so we fade in
    self.transitionAlpha = 1

    -- position in the grid which we're highlighting
    self.boardHighlightX = 0
    self.boardHighlightY = 0

    -- timer used to switch the highlight rect's color
    self.rectHighlighted = false

    -- flag to show whether we're able to process input (not swapping or clearing)
    self.canInput = true

    self.usingMouse = false

    -- tile we're currently highlighting (preparing to swap)
    self.highlightedTile = nil

    self.score = 0
    self.timer = 60

    self.varietyPoints = {
        [1] = 100,   -- Basic tile
        [2] = 150,  -- Cross
        [3] = 200,  -- Circle
        [4] = 250,  -- Square
        [5] = 300,  -- Triangle
        [6] = 350,  -- Star
    }

    self.varietyAdditionalTime = {
        [1] = 1,   -- Basic tile
        [2] = 2,   -- Cross
        [3] = 3,   -- Circle
        [4] = 4,   -- Square
        [5] = 5,   -- Triangle
        [6] = 6,   -- Star
    }

    -- set our Timer class to turn cursor highlight on and off
    Timer.every(0.5, function()
        self.rectHighlighted = not self.rectHighlighted
    end)

    -- subtract 1 from timer every second
    Timer.every(1, function()
        self.timer = self.timer - 1

        -- play warning sound on timer if we get low
        if self.timer <= 5 then
            gSounds['clock']:play()
        end
    end)
end

function PlayState:enter(params)    
    -- grab level # from the params we're passed
    self.level = params.level

    -- spawn a board and place it toward the right
    self.board = params.board or Board(VIRTUAL_WIDTH - 272, 16, self.level)

    -- grab score from params if it was passed
    self.score = params.score or 0

    -- score we have to reach to get to the next level
    self.scoreGoal = self.level * 1.25 * 1000

    -- create or reinitialize the board for the new level
    self.board = params.board or Board(VIRTUAL_WIDTH - 272, 16, self.level)
end

function PlayState:update(dt)
    if love.keyboard.wasPressed('escape') then
        love.event.quit()
    end
    
    -- Check if the board can be reset due to no potential matches
    if not self.board:hasPotentialMatches() then
        self.board:resetBoard()
    end

    -- Handling the timer and level progression
    if self.timer <= 0 then
        Timer.clear()
        gSounds['game-over']:play()
        gStateMachine:change('game-over', { score = self.score })
    elseif self.score >= self.scoreGoal then
        Timer.clear()
        gSounds['next-level']:play()
        gStateMachine:change('begin-game', { level = self.level + 1, score = self.score })
    end

    -- Handling player input
    if self.canInput then
        if self.usingMouse then
            -- Update the highlight based on the mouse position
            -- The logic here is handled in the mouseMoved function
        else
            -- Update the highlight based on the keyboard input
            self:handleMovementInput()        

            if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
                self:handleSelectionInput()
            end
        end
    end

    Timer.update(dt)

    -- If any keyboard button is pressed, switch back to keyboard control
    if love.keyboard.wasPressed('k') or love.keyboard.wasPressed('up') or 
       love.keyboard.wasPressed('down') or love.keyboard.wasPressed('left') or 
       love.keyboard.wasPressed('right') then
        self.usingMouse = false
    end
end

function PlayState:handleMovementInput()
    -- When a keyboard input is detected, switch to keyboard mode and re-enable keyboard highlighting
    self.usingMouse = false
    self.disableKeyboardHighlight = false

    -- Skip keyboard input handling if mouse-based tile selection is active
    if self.disableKeyboardHighlight then
        return
    end

    if love.keyboard.wasPressed('up') then
        self.boardHighlightY = math.max(0, self.boardHighlightY - 1)
        gSounds['select']:play()
    elseif love.keyboard.wasPressed('down') then
        self.boardHighlightY = math.min(7, self.boardHighlightY + 1)
        gSounds['select']:play()
    elseif love.keyboard.wasPressed('left') then
        self.boardHighlightX = math.max(0, self.boardHighlightX - 1)
        gSounds['select']:play()
    elseif love.keyboard.wasPressed('right') then
        self.boardHighlightX = math.min(7, self.boardHighlightX + 1)
        gSounds['select']:play()
    end
end

function PlayState:handleSelectionInput()
    local x = self.boardHighlightX + 1
    local y = self.boardHighlightY + 1

    if not self.highlightedTile then
        self.highlightedTile = self.board.tiles[y][x]
    elseif self.highlightedTile == self.board.tiles[y][x] then
        self.highlightedTile = nil
    elseif math.abs(self.highlightedTile.gridX - x) + math.abs(self.highlightedTile.gridY - y) > 1 then
        gSounds['error']:play()
        self.highlightedTile = nil
    else
        local newTile = self.board.tiles[y][x]

        if self.board:canSwapResultInMatch(self.highlightedTile, newTile) then
            self:swapTiles(self.highlightedTile, newTile)

            Timer.tween(0.1, {
                [self.highlightedTile] = {x = newTile.x, y = newTile.y},
                [newTile] = {x = self.highlightedTile.x, y = self.highlightedTile.y}
            }):finish(function()
                self:calculateMatches()
            end)
        else
            gSounds['error']:play()
            self.highlightedTile = nil
        end
    end
end

function PlayState:swapTiles(tile1, tile2)
    -- Swap grid positions
    local tempX = tile1.gridX
    local tempY = tile1.gridY
    tile1.gridX = tile2.gridX
    tile1.gridY = tile2.gridY
    tile2.gridX = tempX
    tile2.gridY = tempY

    -- Swap tiles in the board
    self.board.tiles[tile1.gridY][tile1.gridX] = tile1
    self.board.tiles[tile2.gridY][tile2.gridX] = tile2
end


--[[
    Calculates whether any matches were found on the board and tweens the needed
    tiles to their new destinations if so. Also removes tiles from the board that
    have matched and replaces them with new randomized tiles, deferring most of this
    to the Board class.
]]
function PlayState:calculateMatches()
    self.highlightedTile = nil

    local matches = self.board:calculateMatches()

    if matches then
        gSounds['match']:stop()
        gSounds['match']:play()

        -- Keep track of whether a shiny tile is found
        local shinyFound = false

        for _, match in pairs(matches) do
            -- Check if the match is horizontal or vertical
            local isHorizontal = #match > 0 and match[1].gridY == match[#match].gridY

            for _, tile in pairs(match) do
                local points = self.varietyPoints[tile.variety] or 0
                self.score = self.score + points

                -- Use the variety-specific additional time
                local additionalTime = self.varietyAdditionalTime[tile.variety] or 1
                self.timer = self.timer + additionalTime

                 -- Check if this tile is shiny
                if tile.shiny then
                    shinyFound = true
                    -- Remove only the corresponding row or column
                    if isHorizontal then
                        -- Remove entire row
                        for x = 1, 8 do
                            self.board.tiles[tile.gridY][x].remove = true
                        end
                    else
                        -- Remove entire column
                        for y = 1, 8 do
                            self.board.tiles[y][tile.gridX].remove = true
                        end
                    end
                else
                    -- Mark only this tile for removal
                    tile.remove = true
                end
            end
        end

        -- If a shiny tile was found, we need to update the board accordingly
        if shinyFound then
            for y = 1, 8 do
                for x = 1, 8 do
                    if self.board.tiles[y][x].remove then
                        local points = self.varietyPoints[self.board.tiles[y][x].variety] or 0
                        self.score = self.score + points
                        self.board.tiles[y][x] = nil
                    end
                end
            end
        else
            self.board:removeMatches()
        end

        local tilesToFall = self.board:getFallingTiles()

        Timer.tween(0.25, tilesToFall):finish(function()
            self:calculateMatches()
        end)
    else
        self.canInput = true
    end
end

function love.mousepressed(x, y, button)
    if button == 1 then -- Assuming left click is button 1
        if gStateMachine.current and gStateMachine.current.mousePressed then
            gStateMachine.current:mousePressed(x, y)
        end
    end
end

function PlayState:mousePressed(x, y)
    -- Convert screen coordinates to game coordinates
    local gameX, gameY = push:toGame(x, y)

    if gameX and gameY then
        -- Calculate which tile was clicked
        local tileX = math.floor((gameX - self.board.x) / 32) + 1
        local tileY = math.floor((gameY - self.board.y) / 32) + 1

        -- Check if the clicked coordinates are within the board
        if tileX >= 1 and tileX <= 8 and tileY >= 1 and tileY <= 8 then
            self:selectTile(tileX, tileY)
        end
    end
end

function love.mousemoved(x, y, dx, dy, istouch)
    if gStateMachine.current and gStateMachine.current.mouseMoved then
        gStateMachine.current:mouseMoved(x, y, dx, dy, istouch)
    end
end

function PlayState:mouseMoved(x, y)
    -- When the mouse is moved, switch to mouse mode
    self.usingMouse = true

    -- Convert screen coordinates to game coordinates
    local gameX, gameY = push:toGame(x, y)

    if gameX and gameY then
        -- Calculate which tile is being hovered over
        local tileX = math.floor((gameX - self.board.x) / 32) + 1
        local tileY = math.floor((gameY - self.board.y) / 32) + 1

        -- Update board highlight coordinates if within board bounds
        if tileX >= 1 and tileX <= 8 and tileY >= 1 and tileY <= 8 then
            self.boardHighlightX = tileX - 1
            self.boardHighlightY = tileY - 1
        end
    end
end

function PlayState:selectTile(x, y)
    local tile = self.board.tiles[y][x]

    if not self.highlightedTile then
        -- First click - highlight the tile
        self.highlightedTile = tile
        -- Disable keyboard highlighting if using the mouse
        self.disableKeyboardHighlight = true
    elseif self.highlightedTile == tile then
        -- Second click on the same tile - deselect it
        self.highlightedTile = nil
    else
        -- Check if the selected tile is adjacent to the highlighted tile
        if math.abs(self.highlightedTile.gridX - x) + math.abs(self.highlightedTile.gridY - y) == 1 then
            -- Second click on an adjacent tile - attempt to swap
            if self.board:canSwapResultInMatch(self.highlightedTile, tile) then
                self:swapTiles(self.highlightedTile, tile)
                Timer.tween(0.1, {
                    [self.highlightedTile] = {x = tile.x, y = tile.y},
                    [tile] = {x = self.highlightedTile.x, y = self.highlightedTile.y}
                }):finish(function()
                    self:calculateMatches()
                end)
            else               
                gSounds['error']:play()
            end
            self.highlightedTile = nil
        else            
            gSounds['error']:play()            
            self.highlightedTile = nil
        end
    end
end


function PlayState:render()
    -- render board of tiles
    self.board:render()

    -- render highlighted tile if it exists
    if self.highlightedTile then
        
        -- multiply so drawing white rect makes it brighter
        love.graphics.setBlendMode('add')

        love.graphics.setColor(1, 1, 1, 96/255)
        love.graphics.rectangle('fill', (self.highlightedTile.gridX - 1) * 32 + (VIRTUAL_WIDTH - 272),
            (self.highlightedTile.gridY - 1) * 32 + 16, 32, 32, 4)

        -- back to alpha
        love.graphics.setBlendMode('alpha')
    end

    -- render highlight rect color based on timer
    if self.rectHighlighted then
        love.graphics.setColor(217/255, 87/255, 99/255, 1)
    else
        love.graphics.setColor(172/255, 50/255, 50/255, 1)
    end
    
    -- draw actual cursor rect
    love.graphics.setLineWidth(4)
    love.graphics.rectangle('line', self.boardHighlightX * 32 + (VIRTUAL_WIDTH - 272),
        self.boardHighlightY * 32 + 16, 32, 32, 4)

    -- GUI text
    love.graphics.setColor(56/255, 56/255, 56/255, 234/255)
    love.graphics.rectangle('fill', 16, 16, 186, 116, 4)

    love.graphics.setColor(99/255, 155/255, 1, 1)
    love.graphics.setFont(gFonts['medium'])
    love.graphics.printf('Level: ' .. tostring(self.level), 20, 24, 182, 'center')
    love.graphics.printf('Score: ' .. tostring(self.score), 20, 52, 182, 'center')
    love.graphics.printf('Goal : ' .. tostring(self.scoreGoal), 20, 80, 182, 'center')
    love.graphics.printf('Timer: ' .. tostring(self.timer), 20, 108, 182, 'center')
end