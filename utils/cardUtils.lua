local function suitToColor(suit)
    if suit == 'Blue' then
        return 0.2, 0.5, 1, 1
    elseif suit == 'Purple' then
        return 0.5, 0.2, 0.5, 1
    elseif suit == 'Green' then
        return 0, 1, 0, 1
    elseif suit == 'Yellow' then
        return 1, 1, 0, 1
    elseif suit == 'Red' then
        return 1, 0, 0, 1
    else
        return 1, 1, 1, 1
    end
end

local function drawCenteredText(rectX, rectY, rectWidth, rectHeight, text)
	local font       = love.graphics.getFont()
	local textWidth  = font:getWidth(text)
	local textHeight = font:getHeight()
	love.graphics.print(text, rectX+rectWidth/2, rectY+rectHeight/2, 0, 1, 1, textWidth/2, textHeight/2)
end

local function drawCard(self, card)
    local r, g, b, a = love.graphics.getColor()
    love.graphics.setColor(suitToColor(card.suit))
    love.graphics.rectangle('line', self.x, self.y, self.width, self.height)
    love.graphics.print(tostring(card.rank), self.x + 5, self.y + 5)
    drawCenteredText(self.x, self.y, self.width, self.height, tostring(card.suit))
    love.graphics.print(tostring(card.rank), self.x + CARD_WIDTH - 13, self.y + CARD_HEIGHT - 20)
    love.graphics.setColor(r, g, b, a)
end

local function createDraw(card)
    return function(self)
        local r, g, b, a = love.graphics.getColor()
        love.graphics.setColor(suitToColor(card.suit))
        love.graphics.rectangle('line', self.x, self.y, self.width, self.height)
        love.graphics.print(tostring(card.rank), self.x + 5, self.y + 5)
        drawCenteredText(self.x, self.y, self.width, self.height, tostring(card.suit))
        love.graphics.print(tostring(card.rank), self.x + CARD_WIDTH - 13, self.y + CARD_HEIGHT - 20)
        love.graphics.setColor(r, g, b, a)
    end
end

return {
    drawCard = drawCard,
    createDraw = createDraw,
    drawCenteredText = drawCenteredText,
}