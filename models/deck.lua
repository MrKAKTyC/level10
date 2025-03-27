local Card = require('models.card')

--- @class Deck
--- @field cards Card[]
Deck = {}
Deck.__index = Deck

---Create new deck with specific amount of wild cards
---@param wildCardsAmount integer
---@return Deck
function Deck:new(wildCardsAmount)
    local deck = setmetatable({}, Deck)
    deck.cards = {}
    for _, worldType in ipairs({'Blue', 'Purple', 'Green', 'Yellow', 'Red'}) do
        for i = 1, 8 do
            deck:addCard(Card:new(#deck.cards, i, worldType))
        end
    end
    for i = 1, wildCardsAmount do
        deck:addCard(Card:new(#deck.cards, 0, 'Wild'))
    end
    return deck
end

--- @param card Card
function Deck:addCard(card)
    table.insert(self.cards, card)
end

function Deck:shuffle()
    local shuffled = {}
    while #self.cards > 0 do
        -- local index = love.math.random(1, #self.cards)
        local index = math.random(1, #self.cards)
        table.insert(shuffled, table.remove(self.cards, index))
    end
    self.cards = shuffled
end

---@return Card
function Deck:drawCard()
    return table.remove(self.cards)
end

return Deck