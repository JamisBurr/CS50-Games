--[[
    GD50
    Legend of Zelda

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

Room = Class{}

function Room:init(player)
    self.width = MAP_WIDTH
    self.height = MAP_HEIGHT

    -- reference to player for collisions, etc.
    self.player = player
    
    self.tiles = {}
    self:generateWallsAndFloors() 

    -- doorways that lead to other dungeon rooms
    self.doorways = {}
    table.insert(self.doorways, Doorway('top', false, self))
    table.insert(self.doorways, Doorway('bottom', false, self))
    table.insert(self.doorways, Doorway('left', false, self))
    table.insert(self.doorways, Doorway('right', false, self))

    -- entities in the room
    self.entities = {}
    self:generateEntities()

    -- game objects in the room
    self.objects = {}
    self:generateObjects()

    -- projectiles in the room (empty to start)
    self.projectiles = {}


    -- used for centering the dungeon rendering
    self.renderOffsetX = MAP_RENDER_OFFSET_X
    self.renderOffsetY = MAP_RENDER_OFFSET_Y

    -- used for drawing when this room is the next room, adjacent to the active
    self.adjacentOffsetX = 0
    self.adjacentOffsetY = 0
end

--[[
    Randomly creates an assortment of enemies for the player to fight.
]]
function Room:generateEntities()
    local types = {'skeleton', 'slime', 'bat', 'ghost', 'spider'}

    for i = 1, 10 do
        local type = types[math.random(#types)]

        table.insert(self.entities, Entity {
            type = type,
            animations = ENTITY_DEFS[type].animations,
            walkSpeed = ENTITY_DEFS[type].walkSpeed or 20,

            -- ensure X and Y are within bounds of the map
            x = math.random(MAP_RENDER_OFFSET_X + TILE_SIZE,
                VIRTUAL_WIDTH - TILE_SIZE * 2 - 16),
            y = math.random(MAP_RENDER_OFFSET_Y + TILE_SIZE,
                VIRTUAL_HEIGHT - (VIRTUAL_HEIGHT - MAP_HEIGHT * TILE_SIZE) + MAP_RENDER_OFFSET_Y - TILE_SIZE - 16),
            
            width = 16,
            height = 16,
            health = 1,
            room = self
        })

        -- make sure entities don't spawn at location of player
        if self.entities[i]:collides(self.player) then
            local touchingPlayer = true
            while touchingPlayer do
                self.entities[i].x = (math.random(2, self.width - 1) * TILE_SIZE)
                self.entities[i].y = (math.random(2, self.height - 1) * TILE_SIZE)
                if self.entities[i]:collides(self.player) then
                    touchingPlayer = false
                end
            end
        end

        self.entities[i].stateMachine = StateMachine {
            ['walk'] = function() return EntityWalkState(self.entities[i]) end,
            ['idle'] = function() return EntityIdleState(self.entities[i]) end
        }

        self.entities[i]:changeState('walk')
    end
end

--[[
    Randomly creates an assortment of obstacles for the player to navigate around.
]]
function Room:generateObjects()

    -- generate the switch
    table.insert(self.objects, GameObject(
        GAME_OBJECT_DEFS['switch'],
        math.random(MAP_RENDER_OFFSET_X + TILE_SIZE,
                    VIRTUAL_WIDTH - TILE_SIZE * 2 - 16),
        math.random(MAP_RENDER_OFFSET_Y + TILE_SIZE,
                    VIRTUAL_HEIGHT - (VIRTUAL_HEIGHT - MAP_HEIGHT * TILE_SIZE) + MAP_RENDER_OFFSET_Y - TILE_SIZE - 16)
    ))

    -- add to list of objects in scene (only one switch for now)
    local switch = self.objects[1]

    -- define a function for the switch that will open all doors in the room
    switch.onCollide = function()
        if switch.state == 'unpressed' then
            switch.state = 'pressed'
            
            -- open every door in the room if we press the switch
            for k, doorway in pairs(self.doorways) do
                doorway.open = true
            end

            gSounds['door']:play()
        end
    end    

    -- rows
    for y = 2, self.width - 1 do   
        -- colms     
        for x = 2, self.height - 1 do

            -- random
            if math.random(30) == 1 then             
            
                local pot = GameObject(GAME_OBJECT_DEFS['pot'], y * TILE_SIZE, x * TILE_SIZE)
                local spaceTaken = false

                pot.onBreak = function ()
                    pot.isActive = false              
                end

                -- stop pot spawning on top of switch
                if pot:collides(switch) then
                    spaceTaken = true
                end
            
                -- stop pot spawning near doors (extend the hitbox?)
                local extPotHitbox = Hitbox(pot.x-8, pot.y-8, pot.width+16, pot.height+16) 
                for k, doorway in pairs(self.doorways) do
                    if doorway:collides(extPotHitbox) then
                        spaceTaken = true
                    end
                end

                -- stop pot spawning on top of entities
                for i = #self.entities, 1, -1 do
                    if self.entities[i]:collides(pot) 
                        or self.player:collides(pot) then
                        spaceTaken = true
                    end
                end

                -- only add pot to room if it is in a feww space                
                if not spaceTaken then
                    table.insert(self.objects, pot)
                end
            end
        end
    end
end

--[[
    Generates the walls and floors of the room, randomizing the various varieties
    of said tiles for visual variety.
]]
function Room:generateWallsAndFloors()
    for y = 1, self.height do
        table.insert(self.tiles, {})

        for x = 1, self.width do
            local id = TILE_EMPTY

            if x == 1 and y == 1 then
                id = TILE_TOP_LEFT_CORNER
            elseif x == 1 and y == self.height then
                id = TILE_BOTTOM_LEFT_CORNER
            elseif x == self.width and y == 1 then
                id = TILE_TOP_RIGHT_CORNER
            elseif x == self.width and y == self.height then
                id = TILE_BOTTOM_RIGHT_CORNER
            
            -- random left-hand walls, right walls, top, bottom, and floors
            elseif x == 1 then
                id = TILE_LEFT_WALLS[math.random(#TILE_LEFT_WALLS)]
            elseif x == self.width then
                id = TILE_RIGHT_WALLS[math.random(#TILE_RIGHT_WALLS)]
            elseif y == 1 then
                id = TILE_TOP_WALLS[math.random(#TILE_TOP_WALLS)]
            elseif y == self.height then
                id = TILE_BOTTOM_WALLS[math.random(#TILE_BOTTOM_WALLS)]
            else
                id = TILE_FLOORS[math.random(#TILE_FLOORS)]
            end
            
            table.insert(self.tiles[y], {
                id = id
            })
        end
    end
end

function Room:update(dt)    
    -- don't update anything if we are sliding to another room (we have offsets)
    if self.adjacentOffsetX ~= 0 or self.adjacentOffsetY ~= 0 then return end

    self.player:update(dt)

    for i = #self.entities, 1, -1 do
        local entity = self.entities[i]

        -- only update entity if it is alive
        if not entity.dead then
            -- remove entity from the table if health is <= 0
            if entity.health <= 0 then  
                entity.dead = true           
                if math.random(2) == 1 then 
                    local heart = GameObject(GAME_OBJECT_DEFS['heart'], entity.x, entity.y)
                    table.insert(self.objects, heart)

                    heart.onCollide = function()
                        if heart.isActive then
                            print("Player health before consuming heart:", self.player.health)
                            if self.player.health < 5.5 then
                                self.player.health = math.min(6, self.player.health + 2)                         
                                heart.isActive = false
                            end
                        end
                    end   
                end              
            else
                entity:processAI({room = self}, dt)
                entity:update(dt)            
            end
        end

        -- collision between the player and entities in the room
        if not entity.dead and self.player:collides(entity) and not self.player.invulnerable then
            gSounds['hit-player']:play()
            self.player:damage(1)
            self.player:goInvulnerable(1.5)

            if self.player.health == 0 then
                gStateMachine:change('game-over')
            end
        end

        -- calculate projectile/entity collisions
        if not entity.dead and self.projectiles then
            for k, projectile in pairs(self.projectiles) do
                if entity:collides(projectile) and projectile.active then                    
                    entity:damage(1)
                    projectile.active = false
                end
            end
        end    
    end

    local keysToRemove = {}
    
    for k, object in pairs(self.objects) do
        if object.isActive then
            object:update(dt)

            -- trigger collision callback on object
            if self.player:collides(object) then
                object:onCollide()
            end            

            -- check for object/projectile collisions
            for i, projectile in pairs(self.projectiles) do
                if object:collides(projectile) and object.canBreak and projectile.active then
                    projectile.active = false
                    object:onBreak()
                    table.insert(keysToRemove, k)
                end
            end

        -- if an object isn't active, flag it for removal
        else
            table.insert(keysToRemove, k)
        end
    end

    -- remove keys that have been flagged for removal
    for i = #keysToRemove, 1, -1 do
        table.remove(self.objects, keysToRemove[i])
    end

    -- update projectiles
    for k, projectile in pairs(self.projectiles) do
        -- only update active projectiles
        if projectile.active then
            projectile:update(dt)
        end
    end
end

function Room:render()
    for y = 1, self.height do
        for x = 1, self.width do
            local tile = self.tiles[y][x]
            love.graphics.draw(gTextures['tiles'], gFrames['tiles'][tile.id],
            (x - 1) * TILE_SIZE + self.renderOffsetX + self.adjacentOffsetX, 
            (y - 1) * TILE_SIZE + self.renderOffsetY + self.adjacentOffsetY)
        end
    end

    -- render doorways; stencils are placed where the arches are after so the player can
    -- move through them convincingly
    for k, doorway in pairs(self.doorways) do
        doorway:render(self.adjacentOffsetX, self.adjacentOffsetY)
    end

    local carried = nil

    for k, object in pairs(self.objects) do
        if object.carrier == nil then
            object:render(self.adjacentOffsetX, self.adjacentOffsetY)
        else
            carried = object
        end
    end

    -- if there is a carried object, render it after the others
    for k, entity in pairs(self.entities) do
        if not entity.dead then entity:render(self.adjacentOffsetX, self.adjacentOffsetY) end
    end

    -- stencil out the door arches so it looks like the player is going through
    love.graphics.stencil(function()
        
        -- left
        love.graphics.rectangle('fill', -TILE_SIZE - 6, MAP_RENDER_OFFSET_Y + (MAP_HEIGHT / 2) * TILE_SIZE - TILE_SIZE,
            TILE_SIZE * 2 + 6, TILE_SIZE * 2)
        
        -- right
        love.graphics.rectangle('fill', MAP_RENDER_OFFSET_X + (MAP_WIDTH * TILE_SIZE),
            MAP_RENDER_OFFSET_Y + (MAP_HEIGHT / 2) * TILE_SIZE - TILE_SIZE, TILE_SIZE * 2 + 6, TILE_SIZE * 2)
        
        -- top
        love.graphics.rectangle('fill', MAP_RENDER_OFFSET_X + (MAP_WIDTH / 2) * TILE_SIZE - TILE_SIZE,
            -TILE_SIZE - 6, TILE_SIZE * 2, TILE_SIZE * 2 + 12)
        
        --bottom
        love.graphics.rectangle('fill', MAP_RENDER_OFFSET_X + (MAP_WIDTH / 2) * TILE_SIZE - TILE_SIZE,
            VIRTUAL_HEIGHT - TILE_SIZE - 6, TILE_SIZE * 2, TILE_SIZE * 2 + 12)
    end, 'replace', 1)

    love.graphics.setStencilTest('less', 1)
    
    if self.player then
        self.player:render()
    end
   
    if carried then
        carried:render(self.adjacentOffsetX, self.adjacentOffsetY)
    end
    
    -- render all active projectiles
    for k, projectile in pairs(self.projectiles) do
        if projectile.active then projectile:render() end
    end

    love.graphics.setStencilTest()   

    --
    -- DEBUG DRAWING OF STENCIL RECTANGLES
    --

    -- love.graphics.setColor(255, 0, 0, 100)
    
    -- -- left
    -- love.graphics.rectangle('fill', -TILE_SIZE - 6, MAP_RENDER_OFFSET_Y + (MAP_HEIGHT / 2) * TILE_SIZE - TILE_SIZE,
    -- TILE_SIZE * 2 + 6, TILE_SIZE * 2)

    -- -- right
    -- love.graphics.rectangle('fill', MAP_RENDER_OFFSET_X + (MAP_WIDTH * TILE_SIZE),
    --     MAP_RENDER_OFFSET_Y + (MAP_HEIGHT / 2) * TILE_SIZE - TILE_SIZE, TILE_SIZE * 2 + 6, TILE_SIZE * 2)

    -- -- top
    -- love.graphics.rectangle('fill', MAP_RENDER_OFFSET_X + (MAP_WIDTH / 2) * TILE_SIZE - TILE_SIZE,
    --     -TILE_SIZE - 6, TILE_SIZE * 2, TILE_SIZE * 2 + 12)

    -- --bottom
    -- love.graphics.rectangle('fill', MAP_RENDER_OFFSET_X + (MAP_WIDTH / 2) * TILE_SIZE - TILE_SIZE,
    --     VIRTUAL_HEIGHT - TILE_SIZE - 6, TILE_SIZE * 2, TILE_SIZE * 2 + 12)
    
    -- love.graphics.setColor(255, 255, 255, 255)
end

function Room:stopPlayer(object, dt)
    if self.player.direction == 'right' then
        self.player.x = self.player.x - (dt * PLAYER_WALK_SPEED)
    elseif self.player.direction == 'left' then
        self.player.x = self.player.x + (dt * PLAYER_WALK_SPEED)
    elseif self.player.direction == 'up' then
        self.player.y = self.player.y + (dt * PLAYER_WALK_SPEED)
    elseif self.player.direction == 'down' then
        self.player.y = self.player.y - (dt * PLAYER_WALK_SPEED)
    end
end