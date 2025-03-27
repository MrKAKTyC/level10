local Deck = require('models.deck')
local Hand = require('models.hand')
local Universe = require('models.universe')

--- @class GameController
--- @field deck Deck
--- @field hand Hand
--- @field universe Universe
GameController = {}
GameController.__index = GameController

---Create new GameController
---@param wildCardsAmount integer
---@return GameController
function GameController:new(wildCardsAmount)
    local gameController = setmetatable({}, GameController)
    gameController.deck = Deck:new(wildCardsAmount)
    gameController.deck:shuffle()
    gameController.hand = Hand:new()
    gameController.universe = Universe:new()
    return gameController
end

function GameController:dealHand()
    for i = 1, 10, 1 do
        self.hand:addCard(self.deck:drawCard())
    end
end

---Restarts given world and return to deck 0-2 cards
---@param worldType WorldType
---@param cardsToReturn Card[]
---@return boolean
function GameController:restartWorld(worldType, cardsToReturn)
    if #cardsToReturn > 2 or not self.universe:canBeRestarted(worldType) then
        return false
    end

    self.universe:restartWorld(worldType)
    for _, card in ipairs(cardsToReturn) do
        self.deck:addCard(card)
    end
    for i = 1, #cardsToReturn, 1 do
        self.hand:addCard(self.deck:drawCard())
    end

    return true
end

function GameController:placeCard(card)
    if not self.universe:placeCard(card) then
        return false
    end

    self.hand:removeCard(card)
    if #self.deck.cards > 0 then
        self.hand:addCard(self.deck:drawCard())
    end
    return true
end

return GameController
-- Start game (init or constructor)
-- Make turn
-- + Place card OR Restart world
-- + Draw card