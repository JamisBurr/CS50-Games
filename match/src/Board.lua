--[[
    GD50
    Match-3 Remake

    -- Board Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    The Board is our arrangement of Tiles with which we must try to find matching
    sets of three horizontally or vertically.
]]

Board = Class{}

function Board:init(x, y, level)
    self.x = x
    self.y = y
    self.level = level
    self.matches = {}
    self.colorSubset = self:generateRandomColorSubset() -- store the color subset
    self:initializeTiles()
end

function Board:initializeTiles()
    self.tiles = {}

    for tileY = 1, 8 do
        self.tiles[tileY] = {}
        for tileX = 1, 8 do
            -- Determine tile variety based on level
            local variety = 1
            if self.level > 1 then
                variety = math.random(math.min(self.level, 6))
            end
    
            -- Randomly make some tiles shiny (10% chance)
            local isShiny = math.random() <= 0.1

            -- Create a new tile at X, Y with a random color and the determined variety
            table.insert(self.tiles[tileY], Tile(tileX, tileY, self.colorSubset[math.random(#self.colorSubset)], variety, isShiny))
        end
    end

    while self:calculateMatches() do
        -- Recursively initialize if matches were returned
        self:initializeTiles()
    end
end

--[[
    Goes left to right, top to bottom in the board, calculating matches by counting consecutive
    tiles of the same color. Doesn't need to check the last tile in every row or column if the 
    last two haven't been a match.
]]
function Board:calculateMatches()
    local matches = {}

    -- how many of the same color blocks in a row we've found
    local matchNum = 1

    -- horizontal matches first
    for y = 1, 8 do
        local colorToMatch = self.tiles[y][1].color

        matchNum = 1
        
        -- every horizontal tile
        for x = 2, 8 do
            
            -- if this is the same color as the one we're trying to match...
            if self.tiles[y][x].color == colorToMatch then
                matchNum = matchNum + 1
            else
                
                -- set this as the new color we want to watch for
                colorToMatch = self.tiles[y][x].color

                -- if we have a match of 3 or more up to now, add it to our matches table
                if matchNum >= 3 then
                    local match = {}

                    -- go backwards from here by matchNum
                    for x2 = x - 1, x - matchNum, -1 do
                        
                        -- add each tile to the match that's in that match
                        table.insert(match, self.tiles[y][x2])
                    end

                    -- add this match to our total matches table
                    table.insert(matches, match)
                end

                matchNum = 1

                -- don't need to check last two if they won't be in a match
                if x >= 7 then
                    break
                end
            end
        end

        -- account for the last row ending with a match
        if matchNum >= 3 then
            local match = {}
            
            -- go backwards from end of last row by matchNum
            for x = 8, 8 - matchNum + 1, -1 do
                table.insert(match, self.tiles[y][x])
            end

            table.insert(matches, match)
        end
    end

    -- vertical matches
    for x = 1, 8 do
        local colorToMatch = self.tiles[1][x].color

        matchNum = 1

        -- every vertical tile
        for y = 2, 8 do
            if self.tiles[y][x].color == colorToMatch then
                matchNum = matchNum + 1
            else
                colorToMatch = self.tiles[y][x].color

                if matchNum >= 3 then
                    local match = {}

                    for y2 = y - 1, y - matchNum, -1 do
                        table.insert(match, self.tiles[y2][x])
                    end

                    table.insert(matches, match)
                end

                matchNum = 1

                -- don't need to check last two if they won't be in a match
                if y >= 7 then
                    break
                end
            end
        end

        -- account for the last column ending with a match
        if matchNum >= 3 then
            local match = {}
            
            -- go backwards from end of last row by matchNum
            for y = 8, 8 - matchNum + 1, -1 do
                table.insert(match, self.tiles[y][x])
            end

            table.insert(matches, match)
        end
    end

    -- store matches for later reference
    self.matches = matches

    -- return matches table if > 0, else just return false
    return #self.matches > 0 and self.matches or false
end

--[[
    Remove the matches from the Board by just setting the Tile slots within
    them to nil, then setting self.matches to nil.
]]
function Board:removeMatches()
    for k, match in pairs(self.matches) do
        for k, tile in pairs(match) do
            self.tiles[tile.gridY][tile.gridX] = nil
        end
    end

    self.matches = nil
end

--[[
    Shifts down all of the tiles that now have spaces below them, then returns a table that
    contains tweening information for these new tiles.
]]
function Board:getFallingTiles()
    -- tween table, with tiles as keys and their x and y as the to values
    local tweens = {}

    for x = 1, 8 do
        local space = false
        local spaceY = 0

        local y = 8
        while y >= 1 do
            local tile = self.tiles[y][x]

            -- if the space is open, we need to shift tiles above down
            if space then
                if tile then
                    -- move tile to new spot and fix Y
                    tile.gridY = spaceY
                    tile.y = (tile.gridY - 1) * 32
                    self.tiles[spaceY][x] = tile
                    self.tiles[y][x] = nil

                    tweens[tile] = {
                        y = (tile.gridY - 1) * 32
                    }

                    space = false
                    y = spaceY

                    -- set this back to false so new tiles can fall down
                    spaceY = 0
                end
            elseif tile == nil then
                space = true
                
                -- if we haven't assigned a space yet, set this to our first space
                if spaceY == 0 then 
                    spaceY = y
                end
            end

            y = y - 1
        end
    end

    -- create replacement tiles at the top of the screen
    for x = 1, 8 do
        for y = 8, 1, -1 do
            local tile = self.tiles[y][x]

            -- if the tile is nil, we need to add a new one
            if not tile then
                -- Determine tile variety based on level
                local variety = 1
                if self.level > 1 then
                    variety = math.random(math.min(self.level, 6))
                end

                -- Create a new tile at X, Y with a random color from the subset
                local newTile = Tile(x, y, self.colorSubset[math.random(#self.colorSubset)], variety)
                newTile.y = -32
                self.tiles[y][x] = newTile

                tweens[newTile] = {
                    y = (newTile.gridY - 1) * 32
                }
            end
        end
    end

    return tweens
end

function Board:generateRandomColorSubset()
    local allColors = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18} -- assuming 18 colors
    local colorSubset = {}

    for i = 1, 8 do
        table.insert(colorSubset, table.remove(allColors, math.random(#allColors)))
    end

    return colorSubset
end

function Board:hasPotentialMatches()
    for y = 1, 8 do
        for x = 1, 8 do
            local tile = self.tiles[y][x]

            -- Check right swap
            if x < 8 then
                local swapTile = self.tiles[y][x + 1]
                self:swapTiles(tile, swapTile)
                if self:calculateMatches() then
                    self:swapTiles(tile, swapTile)
                    return true
                end
                self:swapTiles(tile, swapTile)
            end

            -- Check down swap
            if y < 8 then
                local swapTile = self.tiles[y + 1][x]
                self:swapTiles(tile, swapTile)
                if self:calculateMatches() then
                    self:swapTiles(tile, swapTile)
                    return true
                end
                self:swapTiles(tile, swapTile)
            end
        end
    end
    return false
end

function Board:swapTiles(tile1, tile2)
    -- Swap grid positions
    local tempX = tile1.gridX
    local tempY = tile1.gridY
    tile1.gridX = tile2.gridX
    tile1.gridY = tile2.gridY
    tile2.gridX = tempX
    tile2.gridY = tempY

    -- Swap tiles in the board
    self.tiles[tile1.gridY][tile1.gridX] = tile1
    self.tiles[tile2.gridY][tile2.gridX] = tile2
end


function Board:canSwapResultInMatch(tile1, tile2)
    -- Swap the tiles
    self:swapTiles(tile1, tile2)

    -- Check for matches
    local matches = self:calculateMatches()

    -- Swap the tiles back
    self:swapTiles(tile1, tile2)

    -- Return true if matches were found
    return matches and #matches > 0
end

function Board:resetBoard()
    self:initializeTiles()
end

function Board:render()
    for y = 1, #self.tiles do
        for x = 1, #self.tiles[1] do
            self.tiles[y][x]:render(self.x, self.y)
        end
    end
end