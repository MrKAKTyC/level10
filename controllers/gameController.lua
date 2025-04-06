local Deck = require('models.deck')
local Hand = require('models.hand')
local Universe = require('models.universe')

---@alias GameState
---| 'win' 
---| 'lose' 
---| 'in_progress' 

--- @class GameController
--- @field deck Deck
--- @field hand Hand
--- @field universe Universe
--- @field state GameState
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
    gameController.state = 'in_progress'
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

    if #cardsToReturn == 0 then
        return self.universe:restartWorld(worldType)
    end

    print("====| Start returning |====")
    print("Cards to return: ", #cardsToReturn)
    for _, card in ipairs(cardsToReturn) do
        print(card.rank, card.suit)
    end
    for i, cardInHand in ipairs(self.hand.cards) do
        for _, returnCard in ipairs(cardsToReturn) do
            if cardInHand.rank == returnCard.rank and cardInHand.suit == returnCard.suit then
                print('Returning back:', cardInHand.rank, cardInHand.suit)
                self.deck:addCard(table.remove(self.hand.cards, i))
                goto continue
            end
        end
        print('No match with: ', cardInHand.rank, cardInHand.suit)
        ::continue::
    end
    print("====| End returning |====")
    for i = 1, #cardsToReturn, 1 do
        self.hand:addCard(self.deck:drawCard())
    end

    self.universe:restartWorld(worldType)
    self:endTurn()
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
    self:endTurn()
    return true
end

function GameController:endTurn()
    self:update()
end


---Get list of available cards to play from hand
---@return Card[]
function GameController:getValidCards()
    --- @type Card[]
    local validMoves = {}
    for _, cardFromHand in ipairs(self.hand.cards) do
        if self.universe:canBePlaced(cardFromHand) then
            table.insert(validMoves, cardFromHand)
        end
    end
    return validMoves
end

---Get list of worldTypes available to restart
---@return WorldType[]
function GameController:getValidRestarts()
    --- @type WorldType[]
    local validRestarts = {}
    for worldType, _ in pairs(self.universe.restarts) do
        if self.universe:canBeRestarted(worldType) then
            table.insert(validRestarts, worldType)
        end
    end
    return validRestarts
end

--- @private
function GameController:isWin()
    return self.universe.worldCardsTotal == 50
end

--- @private
function GameController:isLose()
    if #self:getValidCards() == 0 and #self:getValidRestarts() == 0 then
        return true
    end

    return false
end

function GameController:update()
    if self.state == 'in_progress' then
        if self:isWin() then
            self.state = 'win'
        elseif self:isLose() then
            self.state = 'lose'
        end
    end
end

return GameController