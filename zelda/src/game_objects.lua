--[[
    GD50
    Legend of Zelda

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

GAME_OBJECT_DEFS = {
    ['switch'] = {
        type = 'switch',
        texture = 'switches',
        frame = 2,
        width = TILE_SIZE,
        height = TILE_SIZE,
        solid = false,
        canBreak = false,
        defaultState = 'unpressed',
        states = {
            ['unpressed'] = {
                frame = 2
            },
            ['pressed'] = {
                frame = 1
            }
        }
    },

    ['heart'] = {
        type = 'heart',
        texture = 'hearts',
        frame = 5,
        width = TILE_SIZE,
        height = TILE_SIZE,      
        solid = false,
        canBreak = false,   
        floating = true,
        floatOffsetMax = 3,
        floatRate = 7,
        defaultState = 'full',
        states = {
            ['full'] = {
                frame = 5
            },
        }
    },        

    ['pot'] = {
        type = 'pot',
        texture = 'tiles',            
        frame = 33,
        width = TILE_SIZE,
        height = TILE_SIZE,        
        solid = true,
        canBreak = true,
        canGrab = true,   
        defaultState = 'fresh',  
        states = {      
            ['fresh'] = {                
                frame = 14
            },         
            ['broken'] = {                
                frame = 52
            },
        }, 
    },
}
