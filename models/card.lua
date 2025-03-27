--- @alias WorldType
--- | 'Blue
--- | 'Purple'
--- | 'Green'
--- | 'Yellow'
--- | 'Red'
--- | 'Wild'

---@class Card
---@field id integer
---@field rank integer
---@field suit WorldType
Card = {}
Card.__index = Card

---Card models
---@param id integer
---@param rank integer
---@param suit WorldType
---@return Card
function Card:new(id, rank, suit)
    local card = setmetatable({}, self)
    card.id = id
    card.rank = rank
    card.suit = suit
    return card
end

function Card:getId()
    return self.id
end

function Card:getRank()
    return self.rank
end

function Card:getSuit()
    return self.suit
end

function Card:toString()
    return self.rank .. " of " .. self.suit
end

return Card
