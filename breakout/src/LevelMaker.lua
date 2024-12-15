--[[
    GD50
    Breakout Remake

    -- LevelMaker Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    Creates randomized levels for our Breakout game. Returns a table of
    bricks that the game can render, based on the current level we're at
    in the game.
]]

-- global patterns (used to make the entire map a certain shape)
NONE = 1
SINGLE_PYRAMID = 2
MULTI_PYRAMID = 3

-- per-row patterns
SOLID = 1           -- all colors the same in this row
ALTERNATE = 2       -- alternate colors
SKIP = 3            -- skip every other block
NONE = 4            -- no blocks this row

LevelMaker = Class{}

--[[
    Creates a table of Bricks to be returned to the main game, with different
    possible ways of randomizing rows and columns of bricks. Calculates the
    brick colors and tiers to choose based on the level passed in.
]]
function LevelMaker.createMap(level)
    local needsKeyPowerup = false
    local lockedBrickIndex = nil

    local bricks = {}

    -- Randomly choose the number of rows and columns, ensuring odd columns
    local numRows = math.random(1, 5)
    local numCols = math.random(7, 13)
    numCols = numCols % 2 == 0 and (numCols + 1) or numCols

    local highestTier = math.min(3, math.floor(level / 5))
    local highestColor = math.min(5, level % 5 + 3)

    -- Determine position for the locked brick based on level or other criteria 
    -- Variable to hold the position of the locked brick
    local lockedBrickPosition = {x = math.ceil(numCols / 2), y = 3}
    local lockedBrickPlaced = false  -- Flag to indicate whether locked brick has been placed
    print("Locked Brick Position: x =", lockedBrickPosition.x, "y =", lockedBrickPosition.y)

    for y = 1, numRows do
        local skipPattern = math.random(1, 2) == 1
        local alternatePattern = math.random(1, 2) == 1
        local alternateColor1, alternateColor2, alternateTier1, alternateTier2
        local skipFlag, alternateFlag = true, true
        local solidColor = math.random(1, highestColor)
        local solidTier = math.random(0, highestTier)

        if alternatePattern then
            alternateColor1 = math.random(1, highestColor)
            alternateColor2 = math.random(1, highestColor)
            alternateTier1 = math.random(0, highestTier)
            alternateTier2 = math.random(0, highestTier)
        end

        for x = 1, numCols do
            if skipPattern and skipFlag then
                skipFlag = not skipFlag
                goto continue
            else
                skipFlag = not skipFlag
            end

            if lockedBrickPosition and x == lockedBrickPosition.x and y == lockedBrickPosition.y then
                -- Create and place the locked brick
                local lockedBrick = BrickLocked((x - 1) * 32 + 8 + (13 - numCols) * 16, y * 16)
                lockedBrickIndex = (y - 1) * numCols + x
                table.insert(bricks, lockedBrick)
                needsKeyPowerup = true
                lockedBrickPlaced = true
            else
                -- Create a normal brick
                local brick = Brick((x - 1) * 32 + 8 + (13 - numCols) * 16, y * 16)

                if alternatePattern and alternateFlag then
                    brick.color = alternateColor1
                    brick.tier = alternateTier1
                    alternateFlag = not alternateFlag
                else
                    brick.color = alternateColor2 or solidColor
                    brick.tier = alternateTier2 or solidTier
                    alternateFlag = not alternateFlag
                end

                table.insert(bricks, brick)
            end
            ::continue::
        end
    end

    if lockedBrickPlaced then
        for i, brick in ipairs(bricks) do
            if brick.isLocked then
                lockedBrickIndex = i
                break
            end
        end
    end

    print("Locked Brick Index:", lockedBrickIndex, "Total Bricks:", #bricks)

    -- Generate keyPowerupBrickIndex
    if needsKeyPowerup then
        keyPowerupBrickIndex = math.random(1, #bricks)
        while lockedBrickPosition and keyPowerupBrickIndex == (lockedBrickPosition.y - 1) * numCols + lockedBrickPosition.x do
            keyPowerupBrickIndex = math.random(1, #bricks)
        end
        print("Key Powerup Brick Index:", keyPowerupBrickIndex)
    end

    return bricks, needsKeyPowerup, keyPowerupBrickIndex, lockedBrickIndex
end

