--- @class Universe
--- @field worlds table<WorldType, Card[]>
--- @field restarts table<WorldType, Card[]>
--- @field currentLevel integer
Universe = {}
Universe.__index = Universe

---Create new Universe
---@return Universe
function Universe:new()
    local universe = setmetatable({}, Universe)
    universe.worlds = {
        Blue = {},
        Purple = {},
        Green = {},
        Yellow = {},
        Red = {}
    }
    universe.restarts = {
        Blue = {},
        Purple = {},
        Green = {},
        Yellow = {},
        Red = {}
    }
    for wIndex, worldType in ipairs({'Blue', 'Purple', 'Green', 'Yellow', 'Red'}) do
        for i = 1, 2 do
            table.insert(universe.restarts[worldType], Card:new(52 + (2 * wIndex) + i, 0, worldType))
        end
    end
    universe.currentLevel = 1
    return universe
end

function Universe:canBeRestarted(worldType)
    local wasRestarted = false
    for _, wCards in pairs(self.worlds) do
        if #wCards == self.currentLevel and wCards[self.currentLevel].rank == 0 then
            wasRestarted = true
            break
        end
    end

    return #self.worlds[worldType] < self.currentLevel and #self.restarts[worldType] > 0 and not wasRestarted
end

function Universe:restartWorld(worldType)
    if not self:canBeRestarted(worldType) then
        return false
    end
    
    table.insert(self.worlds[worldType], table.remove(self.restarts[worldType], #self.restarts[worldType]))
    self:validateIsLevelDone()
    return true
end

---@param card Card
---@return boolean
function Universe:placeCard(card)
    -- Check if it's valid move
    -- 1. Based pn previous card in this world
    -- 2. Based on if other worlds have restart card
    if #self.worlds[card.suit] >= self.currentLevel then
        print('Invalid move', 'level overflow')
        return false
    end
    if self.currentLevel ~= 1 and self.worlds[card.suit][#self.worlds[card.suit]].rank > card.rank then
        print('Invalid move', 'lower rank')
        return false
    end
    local wasRestarted = false
    local cardsCount = 0
    for _, wCards in pairs(self.worlds) do
        cardsCount = cardsCount + #wCards
        if #wCards == self.currentLevel and wCards[self.currentLevel].rank == 0 then
            wasRestarted = true
            break
        end
    end
    if (cardsCount + 1) / 5 == self.currentLevel and not wasRestarted then
        print('Invalid move', 'restart required')
        return false
    end
    table.insert(self.worlds[card.suit], card)
    self:validateIsLevelDone()
    return true
end

function Universe:validateIsLevelDone()
    local sum = 0
    for _, value in pairs(self.worlds) do
        sum = sum + #value
    end
    if sum / 5 == self.currentLevel then
        self.currentLevel = self.currentLevel + 1
    end
end

return Universe