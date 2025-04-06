require('controllers.uiController')
require('controllers.gameController')

CARD_WIDTH = 80
CARD_HEIGHT = 120
CARDS_GAP = 20

--- @type GameController
local gameController = nil
--- @type UIController
local controller = nil

function love.load()
    print('\n')
    love.window.setFullscreen(true)
    love.window.setTitle('Card Game')
    gameController = GameController:new(0)
    gameController:dealHand()
    controller = UIController:new(gameController)
end

function love.update(dt)
    if love.keyboard.isDown("escape") then
        love.event.quit()
    end
end

function love.mousepressed(x, y, button)
    if button == 1 then
        controller:handleMouseClick(x, y)
    end
end

function love.draw()
    if controller then
        controller:draw()
    end
end