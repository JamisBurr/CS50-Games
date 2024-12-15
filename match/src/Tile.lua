--[[
    GD50
    Match-3 Remake

    -- Tile Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    The individual tiles that make up our game board. Each Tile can have a
    color and a variety, with the varietes adding extra points to the matches.
]]

-- Define the shader code
local shinyShaderCode = [[
    extern number time;
    vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
        vec4 texturecolor = Texel(texture, texture_coords);
        number brightness = 0.5 + sin(time * 3) * 0.5; // Pulsing effect
        brightness = 1.0 + brightness * 0.75; // Increase the multiplier for more brightness
        return vec4(texturecolor.rgb * brightness, texturecolor.a);
    }
]]


-- Load the shader
local shinyShader = love.graphics.newShader(shinyShaderCode)

Tile = Class{}

function Tile:init(x, y, color, variety, shiny)
    
    -- board positions
    self.gridX = x
    self.gridY = y

    -- coordinate positions
    self.x = (self.gridX - 1) * 32
    self.y = (self.gridY - 1) * 32

    -- tile appearance/points
    self.color = color
    self.variety = variety

    -- new shiny property
    self.shiny = shiny or false
end

function Tile:render(x, y)
    -- draw shadow
    love.graphics.setColor(34, 32, 52, 255)
    love.graphics.draw(gTextures['main'], gFrames['tiles'][self.color][self.variety],
        self.x + x + 2, self.y + y + 2)

    -- If the tile is shiny, apply the shader
    if self.shiny then
        shinyShader:send('time', love.timer.getTime())
        love.graphics.setShader(shinyShader)
    end

    -- draw tile itself
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.draw(gTextures['main'], gFrames['tiles'][self.color][self.variety],
        self.x + x, self.y + y)

    -- Reset shader to default if it was changed
    if self.shiny then
        love.graphics.setShader()
    end
end


