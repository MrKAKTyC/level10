-- controller.lua

CARD_WIDTH = 80
CARD_HEIGHT = 120

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

---@param button Button
function UIController:addButton(button)
    print("Adding button, currently have " .. #self.buttons)
    table.insert(self.buttons, button)
end

function UIController:removeButton(button)
    for i, b in ipairs(self.buttons) do
        if b == button then
            table.remove(self.buttons, i)
            break
        end
    end
end

function UIController:update()
    self.buttons = {}
    local width, height = love.graphics.getDimensions()
    -- local cards = gc.hand
    local cardsCount = #self.gameController.hand.cards
    local handWidth = cardsCount * (CARD_WIDTH + CARDS_GAP)
    local handPos = (width - handWidth) / 2
    for i, card in ipairs(self.gameController.hand.cards) do
        local x, y = handPos + (CARD_WIDTH + CARDS_GAP) * (i - 1), height - CARD_HEIGHT - CARDS_GAP
        local cardButton = Button:new()
        cardButton:setPos(x, y)
        cardButton:setSize(CARD_WIDTH, CARD_HEIGHT)
        cardButton:onClick(function()
            if self.gameController:placeCard(card) then
                self:removeButton(cardButton)
            end
            -- self:removeButton(cardButton)
        end)
        cardButton:onDraw(function(self)
            love.graphics.rectangle('line', self.x, self.y, self.width, self.height)
            love.graphics.print(tostring(card.rank), self.x + 5, self.y + 5)
            love.graphics.print(tostring(card.suit), self.x + 5, self.y + CARD_HEIGHT / 2 - 5)
            love.graphics.print(tostring(card.rank), self.x + CARD_WIDTH - 13, self.y + CARD_HEIGHT - 20)
        end)
        table.insert(self.buttons, cardButton)
    end

    local halfGap = CARDS_GAP / 2
    local tableWidth = 11 * (CARD_WIDTH + CARDS_GAP)
    local tableHeight = 5 * (CARD_HEIGHT + CARDS_GAP)
    local tableX = (width - tableWidth) / 2
    local tableY = (height - tableHeight) / 2

    for wIndex, worldType in ipairs({'Blue', 'Purple', 'Green', 'Yellow', 'Red'}) do
        if #self.gameController.universe.restarts[worldType] == 0 then goto continue end
        local x, y = tableX + halfGap, tableY + halfGap + (CARD_HEIGHT + CARDS_GAP) * (wIndex - 1)
        local restartCardButton = Button:new()
        restartCardButton:setPos(x, y)
        restartCardButton:setSize(CARD_WIDTH, CARD_HEIGHT)
        restartCardButton:onClick(function()
            local cardsToReturn = {}
            if self.gameController:restartWorld(worldType, cardsToReturn) then
                self:removeButton(restartCardButton)
            end
        end)
        restartCardButton:onDraw(function(self)
            love.graphics.rectangle('line', self.x, self.y, self.width, self.height)
            love.graphics.print('0', self.x + 5, self.y + 5)
            love.graphics.print(worldType, self.x + 5, self.y + CARD_HEIGHT / 2 - 5)
            love.graphics.print('0', self.x + CARD_WIDTH - 13, self.y + CARD_HEIGHT - 20)
        end)
        table.insert(self.buttons, restartCardButton)
        ::continue::
    end
end

function UIController:draw()
    for _, button in ipairs(self.buttons) do
        button:draw()
    end
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