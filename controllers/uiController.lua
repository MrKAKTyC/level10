local cardUtils = require("utils.cardUtils")

CARD_WIDTH = 80
CARD_HEIGHT = 120
IS_SELECT_MODE = false
---@type Card[]
SELECTED_CARDS = {}

-- Controller to manage buttons
--- @class UIController
--- @field buttons Button[]
--- @field gameController GameController
UIController = {}
UIController.__index = UIController

---@param gc GameController
function UIController:new(gc)
    local controller = setmetatable({}, UIController)
    controller.buttons = {}
    controller.gameController = gc
    return controller
end

-- ---@param button Button
-- function UIController:addButton(button)
--     print("Adding button, currently have " .. #self.buttons)
--     table.insert(self.buttons, button)
-- end

-- function UIController:removeButton(button)
--     for i, b in ipairs(self.buttons) do
--         if b == button then
--             table.remove(self.buttons, i)
--             break
--         end
--     end
-- end

-- local function drawDiscard()
--     local width, height = love.graphics.getDimensions()
--     local x, y = width - CARD_WIDTH - CARDS_GAP, height - CARD_HEIGHT - CARDS_GAP
--     love.graphics.rectangle('line', x, y, CARD_WIDTH, CARD_HEIGHT)
--     love.graphics.print('Discard', x + 5, y + 5)
-- end

function UIController:drawState()
    local width, _ = love.graphics.getDimensions()
    local winMsg = "Winner, winner, chicken diner!"
    local loseMsg = "Better luck next time!"
    if self.gameController.state == 'win' then
        local font       = love.graphics.getFont()
        local textWidth  = font:getWidth(winMsg)
        local textHeight = font:getHeight()
        love.graphics.print(winMsg, width / 2, 30, 0, 3, 3, textWidth / 2, textHeight / 2)
    elseif self.gameController.state == 'lose' then
        local font       = love.graphics.getFont()
        local textWidth  = font:getWidth(loseMsg)
        local textHeight = font:getHeight()
        love.graphics.print(loseMsg, width / 2, 30, 0, 3, 3, textWidth / 2, textHeight / 2)
    end
end

function UIController:drawDeck()
    if #self.gameController.deck.cards == 0 then
        love.graphics.print('Deck is empty', 10, 10)
    else
        love.graphics.print('Cards in deck: ' .. #self.gameController.deck.cards, 10, 10)
    end
    if IS_SELECT_MODE then
        local _, height = love.graphics.getDimensions()
        local x, y = CARDS_GAP, height - CARD_WIDTH - CARDS_GAP


        love.graphics.print(string.format('Restarting %s level', SELECTED_WORLD), x, y - 20 * (#SELECTED_CARDS + 3))
        love.graphics.print('Select cards to return to deck', x, y - 20 * (#SELECTED_CARDS + 2))
        love.graphics.print(string.format('Selected %d / max: 2 ', #SELECTED_CARDS), x, y - 20 * (#SELECTED_CARDS + 1))
        for i, card in ipairs(SELECTED_CARDS) do
            local cardY = y - 20 * (#SELECTED_CARDS + 1 - i)
            love.graphics.print(card.rank .. ' ' .. card.suit, x, cardY)
        end
        local backToDeckButton = Button:new()
        backToDeckButton:setPos(x, y)
        backToDeckButton:setSize(CARD_HEIGHT, CARD_WIDTH)
        backToDeckButton:onClick(function()
            if (self.gameController:restartWorld(SELECTED_WORLD, SELECTED_CARDS)) then
                SELECTED_CARDS = {}
                SELECTED_WORLD = nil
                IS_SELECT_MODE = false
            end
        end)
        backToDeckButton:onDraw(function()
            love.graphics.rectangle('line', x, y, CARD_HEIGHT, CARD_WIDTH)
            cardUtils.drawCenteredText(x, y, CARD_HEIGHT, CARD_WIDTH, 'Confirm')
        end)
        table.insert(self.buttons, backToDeckButton)
    end
end

function UIController:drawRestart()
    local width, _ = love.graphics.getDimensions()
    local x, y = width - CARD_HEIGHT - 20, 20

    local restartButton = Button:new()
    restartButton:setPos(x, y)
    restartButton:setSize(CARD_HEIGHT, CARD_WIDTH)
    restartButton:onClick(function()
        self.gameController = GameController:new(0)
        self.gameController:dealHand()
    end)
    restartButton:onDraw(function()
        love.graphics.rectangle('line', x, y, CARD_HEIGHT, CARD_WIDTH)
        cardUtils.drawCenteredText(x, y, CARD_HEIGHT, CARD_WIDTH, 'Restart')
    end)
    table.insert(self.buttons, restartButton)
end

function UIController:update()
    self.buttons = {}
    local width, height = love.graphics.getDimensions()
    -- Hand render part
    local cardsCount = #self.gameController.hand.cards
    local handWidth = cardsCount * (CARD_WIDTH + CARDS_GAP)
    local handPos = (width - handWidth) / 2
    for i, card in ipairs(self.gameController.hand.cards) do
        local x, y = handPos + (CARD_WIDTH + CARDS_GAP) * (i - 1), height - CARD_HEIGHT - CARDS_GAP
        local cardButton = Button:new()
        cardButton:setPos(x, y)
        cardButton:setSize(CARD_WIDTH, CARD_HEIGHT)
        cardButton:onClick(function()
            if IS_SELECT_MODE then
                if #SELECTED_CARDS == 0 then
                    table.insert(SELECTED_CARDS, card)
                    return
                end
                for key, cardFromSelected in ipairs(SELECTED_CARDS) do
                    if cardFromSelected.rank == card.rank and cardFromSelected.suit == card.suit then
                        table.remove(SELECTED_CARDS, key)
                        break
                    else
                        if #SELECTED_CARDS <= 1 then
                            table.insert(SELECTED_CARDS, card)
                            break
                        end
                    end
                end
            else
                self.gameController:placeCard(card)
            end
        end)
        cardButton:onDraw(cardUtils.createDraw(card))
        table.insert(self.buttons, cardButton)
    end

    -- Table render part

    local halfGap = CARDS_GAP / 2
    local tableWidth = 10 * (CARD_WIDTH + CARDS_GAP)
    local tableHeight = 5 * (CARD_HEIGHT + CARDS_GAP)
    local tableX = (width - tableWidth) / 2
    local tableY = (height - CARD_HEIGHT - tableHeight) / 2
    love.graphics.rectangle('line', tableX, tableY, tableWidth, tableHeight)
    for wIndex, worldType in ipairs({ 'Blue', 'Purple', 'Green', 'Yellow', 'Red' }) do
        for index, cardData in ipairs(self.gameController.universe.worlds[worldType]) do
            local x = tableX + (CARDS_GAP + CARD_WIDTH) + (CARD_WIDTH * (index - 1) + halfGap * (index - 1))
            local y = tableY + halfGap + (CARD_HEIGHT + CARDS_GAP) * (wIndex - 1)
            cardUtils.drawCard({ x = x, y = y, height = CARD_HEIGHT, width = CARD_WIDTH }, cardData)
        end
        if #self.gameController.universe.restarts[worldType] == 0 then goto continue end
        local x, y = tableX + halfGap, tableY + halfGap + (CARD_HEIGHT + CARDS_GAP) * (wIndex - 1)
        local restartCardButton = Button:new()
        restartCardButton:setPos(x, y)
        restartCardButton:setSize(CARD_WIDTH, CARD_HEIGHT)
        restartCardButton:onClick(function()
            if #self.gameController.deck.cards == 0 and self.gameController.universe:canBeRestarted(worldType) then
                return self.gameController:restartWorld(worldType, {})
            end

            if not IS_SELECT_MODE and self.gameController.universe:canBeRestarted(worldType) then
                IS_SELECT_MODE = true
                SELECTED_WORLD = worldType
            end
        end)
        restartCardButton:onDraw(cardUtils.createDraw({ rank = 0, suit = worldType }))

        table.insert(self.buttons, restartCardButton)
        ::continue::
    end
end

function UIController:draw()
    for _, button in ipairs(self.buttons) do
        button:draw()
    end
    self:update()
    self:drawDeck()
    self:drawRestart()
    self:drawState()
end

function UIController:handleMouseClick(mouseX, mouseY)
    for _, button in ipairs(self.buttons) do
        if button:isClicked(mouseX, mouseY) then
            button:click()
            self:update()
            break
        end
    end
end

-- Define a Button class
--- @class Button
--- @field x integer
--- @field y integer
--- @field width integer
--- @field height integer
--- @field renderHandler function
--- @field clickHandler function
Button = {}
Button.__index = Button

function Button:new()
    return setmetatable({}, Button)
end

function Button:setPos(x, y)
    self.x = x
    self.y = y
end

function Button:setSize(width, height)
    self.width = width
    self.height = height
end

function Button:onDraw(callback)
    self.renderHandler = callback
end

function Button:onClick(callback)
    self.clickHandler = callback
end

--- Function to check if the button is clicked
---@param mouseX integer
---@param mouseY integer
---@return boolean
function Button:isClicked(mouseX, mouseY)
    return mouseX >= self.x and mouseX <= (self.x + self.width) and
        mouseY >= self.y and mouseY <= (self.y + self.height)
end

function Button:click()
    if self.clickHandler then
        self.clickHandler()
    end
end

function Button:draw()
    self:renderHandler()
end

-- Return the module
return {
    Button = Button,
    UIController = UIController
}
