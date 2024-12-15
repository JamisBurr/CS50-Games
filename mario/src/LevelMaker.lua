-- LevelMaker Class for a Super Mario Bros. Remake
LevelMaker = Class{}

function LevelMaker.findSolidGroundColumn(tiles, width, height)
    for x = 1, width do
        for y = 1, height do
            if tiles[y][x].id == TILE_ID_GROUND then
                -- Found a column with solid ground, return its position
                return x
            end
        end
    end
    -- Fallback to the first column if no solid ground is found (shouldn't happen with proper level design)
    return 1
end

function LevelMaker.generate(width, height)
    local tiles = {}
    local entities = {}
    local objects = {}
    local specialPositions = {}

    -- Additional variables for key and lock placement
    local keyPlaced = false
    local lockPlaced = false
    local keyColor = math.random(4) -- Assuming there are 4 key/lock colors
    local poleColor = math.random(6)
    local flagColor = 7 + (9 * math.random(0, 3))
    local columnNotFree = true

    local keyColumn = math.random(1, math.floor(width / 3))
    local lockColumn = math.random(math.floor(width * 2 / 3), width)

    local tileID = TILE_ID_GROUND

    -- whether we should draw our tiles with toppers
    local topper = true
    local tileset = math.random(20)
    local topperset = math.random(20)

    -- insert blank tables into tiles for later access
    for x = 1, height do
        table.insert(tiles, {})
    end

    -- column by column generation instead of row; sometimes better for platformers
    for x = 1, width do
        local tileID = TILE_ID_EMPTY

        -- lay out the empty space
        for y = 1, 6 do
            table.insert(tiles[y], Tile(x, y, tileID, nil, tileset, topperset))
        end

        -- chance to just be emptiness
        if math.random(7) == 1 then
            for y = 7, height do
                table.insert(tiles[y], Tile(x, y, tileID, nil, tileset, topperset))
            end
        else
            tileID = TILE_ID_GROUND

            -- height at which we would spawn a potential jump block
            blockHeight = 4

            for y = 7, height do
                table.insert(tiles[y], Tile(x, y, tileID, y == 7 and topper or nil, tileset, topperset))
            end

            -- chance to generate a pillar
            if math.random(8) == 1 then
                blockHeight = 2

                -- chance to generate bush on pillar
                if math.random(8) == 1 then
                    table.insert(objects, GameObject {
                        texture = 'bushes',
                        x = (x - 1) * TILE_SIZE,
                        y = (4 - 1) * TILE_SIZE,
                        width = 16,
                        height = 16,

                        -- select random frame from bush_ids whitelist, then random row for variance
                        frame = BUSH_IDS[math.random(#BUSH_IDS)] + (math.random(4) - 1) * 7,
                        collidable = false
                    })
                end

                -- pillar tiles
                tiles[5][x] = Tile(x, 5, tileID, topper, tileset, topperset)
                tiles[6][x] = Tile(x, 6, tileID, nil, tileset, topperset)
                tiles[7][x].topper = nil

            -- chance to generate bushes
            elseif math.random(8) == 1 then
                table.insert(objects, GameObject {
                    texture = 'bushes',
                    x = (x - 1) * TILE_SIZE,
                    y = (6 - 1) * TILE_SIZE,
                    width = 16,
                    height = 16,
                    frame = BUSH_IDS[math.random(#BUSH_IDS)] + (math.random(4) - 1) * 7,
                    collidable = false
                })
            end
        end

        -- Inside LevelMaker.generate, when creating a locked block
        if x == lockColumn and not lockPlaced and not specialPositions[x] then
            table.insert(objects, GameObject {
                texture = 'keys-and-locks',
                x = (x - 1) * TILE_SIZE,
                y = (blockHeight - 2) * TILE_SIZE,
                width = 16,
                height = 16,
                frame = keyColor + 4, -- Adjust frame for lock appearance
                type = 'lock',
                collidable = true,
                consumable = false,
                solid = true,
                onCollide = function(obj, player)
                    if player.hasKey then
                        -- Remove the locked block
                        for i, object in ipairs(player.level.objects) do
                            if object == obj then
                                table.remove(player.level.objects, i)
                                break
                            end
                        end
                        
                        player.hasKey = false
                        gSounds['empty-block']:play()
                        player.score = player.score + 500
                        
                            -- calculate a suitable X coord for the flag
                        local flagX = width
                        local columnNotFree = true

                        while columnNotFree do
                            flagX = flagX - 1
                            -- if tiles at y = 6 & 7 are the same, it is either a chasm or pillar and not free
                            columnNotFree = tiles[7][flagX].id == tiles[6][flagX].id

                            -- check whether another block already occupies column flagX
                            for k, object in pairs(objects) do
                                if (object.x - 1) == flagX then
                                    columnNotFree = true
                                end
                            end
                        end

                        local polePositionX = ((flagX - 1) * TILE_SIZE) -- Assuming you want it at the last column
                        local polePositionY = 3 * TILE_SIZE -- Adjust based on the ground placement
                        
                        -- Spawn the pole
                        table.insert(objects,
                            GameObject {
                                texture = 'poles',
                                x = polePositionX,
                                y = polePositionY,
                                width = 16,
                                height = 48,
                                frame = poleColor, -- Assuming the first frame in 'poles' represents the entire pole
                                collidable = false,
                                consumable = false,
                                solid = false
                            }
                        )
                    
                        local flagPositionX = (flagX) * TILE_SIZE - 8 -- Assuming you want it at the last column
                        local flagPositionY = 3 * TILE_SIZE + 6 -- Adjust based on the ground placement
                
                        -- Spawn the flag
                        table.insert(objects,
                            GameObject {
                                texture = 'flags',
                                x = flagPositionX,
                                y = flagPositionY,
                                width = 16,
                                height = 16,
                                frame = flagColor, -- Assuming the first frame in 'poles' represents the entire pole
                                                                    
                                -- animate the flag
                                animation = Animation {
                                    frames = {0, 1},
                                    interval = 0.25
                                },                               
                                
                                collidable = false,
                                consumable = true,
                                solid = false,

                                onConsume = function(obj)
                                    gStateMachine:change('play', {
                                        score = player.score + 500,  -- Update the score
                                        width = width + 10  -- Increase the width for the next level
                                    })
                                end                
                            }
                            )

                    else
                        gSounds['empty-block']:play()
                    end
                end
            })
            lockPlaced = true
            specialPositions[x] = true

        -- Ensure key and lock do not spawn on top of each other or on a special block
        elseif x == keyColumn and not keyPlaced and not specialPositions[x] then
            table.insert(objects, GameObject {
                texture = 'keys-and-locks',
                x = (x - 1) * TILE_SIZE,
                y = (blockHeight - 1) * TILE_SIZE,
                width = 16,
                height = 16,
                frame = keyColor,
                type = 'key',
                collidable = true,
                consumable = true,
                onConsume = function(player, object)
                    player.hasKey = true
                    gSounds['pickup']:play()
                end
            })
            keyPlaced = true
            specialPositions[x] = true
        

        -- chance to spawn a block
        elseif math.random(20) == 1 and not specialPositions[x] then
            table.insert(objects, GameObject {
                texture = 'jump-blocks',
                x = (x - 1) * TILE_SIZE,
                y = (blockHeight - 1) * TILE_SIZE,
                width = 16,
                height = 16,

                -- make it a random variant
                frame = math.random(#JUMP_BLOCKS),
                collidable = true,
                hit = false,
                solid = true,

                -- collision function takes itself
                onCollide = function(obj)
                    -- spawn a gem if we haven't already hit the block
                    if not obj.hit then
                        -- chance to spawn gem, not guaranteed
                        if math.random(5) == 1 then
                            -- maintain reference so we can set it to nil
                            local gem = GameObject {
                                texture = 'gems',
                                x = (x - 1) * TILE_SIZE,
                                y = (blockHeight - 1) * TILE_SIZE - 4,
                                width = 16,
                                height = 16,
                                frame = math.random(#GEMS),
                                collidable = true,
                                consumable = true,
                                solid = false,

                                -- gem has its own function to add to the player's score
                                onConsume = function(player, object)
                                    gSounds['pickup']:play()
                                    player.score = player.score + 100
                                end
                            }

                            -- make the gem move up from the block and play a sound
                            Timer.tween(0.1, {
                                [gem] = {y = (blockHeight - 2) * TILE_SIZE}
                            })
                            gSounds['powerup-reveal']:play()

                            table.insert(objects, gem)
                        end

                        obj.hit = true
                    end

                    gSounds['empty-block']:play()
                end
            })
            specialPositions[x] = true
        end           
    end


    -- After generating the level, find a solid ground column for player start
    local solidGroundColumn = LevelMaker.findSolidGroundColumn(tiles, width, height)

    local map = TileMap(width, height)
    map.tiles = tiles

    return GameLevel(entities, objects, map, solidGroundColumn)
end
