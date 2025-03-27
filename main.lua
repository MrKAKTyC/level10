require('controllers.uiController')
require('controllers.gameController')

CARD_WIDTH = 80
CARD_HEIGHT = 120
CARDS_GAP = 20

-- local gameState = {
--     deck = {},
--     discard = {},
--     table = {
--         restart = {},
--         worlds = {
--             blue = {},
--             purple = {},
--             green = {},
--             yellow = {},
--             red = {}
--         }
--     },
--     hand = {
--         cards = {}
--     }
-- }
--- @type GameController
local gameController = nil
--- @type UIController
local controller = nil
local lastClick

-- local function updateHand()
--     local width, height = love.graphics.getDimensions()
--     local cards = gameState.hand.cards
--     local cardsCount = #cards
--     local handWidth = cardsCount * (CARD_WIDTH + CARDS_GAP)
--     local handPos = (width - handWidth) / 2
--     for i, card in ipairs(cards) do
--         local x, y = handPos + (CARD_WIDTH + CARDS_GAP) * (i - 1), height - CARD_HEIGHT - CARDS_GAP
--         card:setPos(x, y)
--     end
-- end

local function drawHand()
    local width, height = love.graphics.getDimensions()
    local cards = {}
    local cardsCount = #cards
    local handWidth = cardsCount * (CARD_WIDTH + CARDS_GAP)
    local handPos = (width - handWidth) / 2
    for i, card in ipairs(cards) do
        local x, y = handPos + (CARD_WIDTH + CARDS_GAP) * (i - 1), height - CARD_HEIGHT - CARDS_GAP
        card:draw()
    end
end

-- local function updateTable()
--     local width, height = love.graphics.getDimensions()
--     local halfGap = CARDS_GAP / 2
--     local tableWidth = 11 * (CARD_WIDTH + CARDS_GAP)
--     local tableHeight = 5 * (CARD_HEIGHT + CARDS_GAP)
--     local tableX = (width - tableWidth) / 2
--     local tableY = (height - tableHeight) / 2
--     for i, card in ipairs(gameState.table.restart) do
--         card:setPos(tableX + halfGap, tableY + halfGap + (CARD_HEIGHT + CARDS_GAP) * (i - 1))
--     end
-- end

local function drawTable()
    local width, height = love.graphics.getDimensions()
    local halfGap = CARDS_GAP / 2
    local tableWidth = 11 * (CARD_WIDTH + CARDS_GAP)
    local tableHeight = 5 * (CARD_HEIGHT + CARDS_GAP)
    local tableX = (width - tableWidth) / 2
    local tableY = (height - tableHeight) / 2

    love.graphics.rectangle('line', tableX, tableY, tableWidth, tableHeight)
    if gameController then
        for wIndex, worldType in ipairs({'Blue', 'Purple', 'Green', 'Yellow', 'Red'}) do
            for index, cardData in ipairs(gameController.universe.worlds[worldType]) do
                local x = tableX + (CARDS_GAP + CARD_WIDTH) + (CARD_WIDTH * (index - 1) + halfGap * (index - 1))
                local y = tableY + halfGap + (CARD_HEIGHT + CARDS_GAP) * (wIndex - 1)
                love.graphics.rectangle('line', x, y, CARD_WIDTH, CARD_HEIGHT)
                love.graphics.print(tostring(cardData.rank), x + 5, y + 5)
                love.graphics.print(tostring(cardData.suit), x + 5, y + CARD_HEIGHT / 2 - 5)
                love.graphics.print(tostring(cardData.rank), x + CARD_WIDTH - 13, y + CARD_HEIGHT - 20)
            end
        end
    end
    
end

local function drawDiscard()
    local width, height = love.graphics.getDimensions()
    local x, y = width - CARD_WIDTH - CARDS_GAP, height - CARD_HEIGHT - CARDS_GAP
    love.graphics.rectangle('line', x, y, CARD_WIDTH, CARD_HEIGHT)
    love.graphics.print('Discard', x + 5, y + 5)
end

local function drawDeck()
    local width, height = love.graphics.getDimensions()
    local x, y = CARDS_GAP, height - CARD_HEIGHT - CARDS_GAP
    love.graphics.rectangle('line', x, y, CARD_WIDTH, CARD_HEIGHT)
    love.graphics.print('Deck', x + 5, y + 5)
end

local function drawLastClick()
    if lastClick then
        love.graphics.line(lastClick.x - 4, lastClick.y, lastClick.x + 4, lastClick.y)
        love.graphics.line(lastClick.x, lastClick.y - 4, lastClick.x, lastClick.y + 4)
    end
end

function love.load()
    love.window.setFullscreen(true)
    love.window.setTitle('Card Game')
    gameController = GameController:new(0)
    gameController:dealHand()
    controller = UIController:new(gameController)
    controller:update()
end

function love.update(dt)
    if love.keyboard.isDown("escape") then
        love.event.quit()
    end
end

function love.mousepressed(x, y, button)
    if button == 1 then
        controller:handleMouseClick(x, y)
        lastClick = { x = x, y = y }
    end
end

function love.draw()
    if controller then
        controller:draw()
    end
    drawTable()
    drawLastClick()
    drawDeck()
    drawDiscard()
    drawHand()
end