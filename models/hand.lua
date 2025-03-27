
--- Hand class.
--- @class Hand
--- @field cards Card[]
Hand = {}
Hand.__index = Hand

function Hand:new()
    local hand = setmetatable({}, self)
    hand.cards = {}
    return hand
end

---@param card Card
function Hand:addCard(card)
    table.insert(self.cards, card)
end

---@param card Card
function Hand:removeCard(card)
    for i, c in ipairs(self.cards) do
        if c == card then
            table.remove(self.cards, i)
            break
        end
    end
end

---@return Card[]
function Hand:getCards()
    return self.cards
end

return Hand