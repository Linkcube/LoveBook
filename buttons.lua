ButtonClass = class("ButtonClass")

function ButtonClass:initialize(X, Y, W, H, N)
	self.x = X or 0
	self.y = Y or 0
	self.width = W or 0
	self.height = H or 0
	self.name = N or ""
	self.color = {255, 0, 255}
end

function ButtonClass:Contact(X, Y)
	if X >= self.x and X <= self.width + self.x then
		if Y >= self.y and Y <= self.height + self.y then
			return true
		end
	end
	return false
end

function ButtonClass:Draw()
	love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
	love.graphics.print(self.name, self.x, self.y)
end

--------------------------------------------------------------------------

IButtonClass = class("IButtonClass")

function IButtonClass:initialize(X, Y, I, N)
	self.x = X or 0
	self.y = Y or 0
	self.image = love.graphics.newImage(I) or nil
	self.width = self.image:getWidth() or 0
	self.height = self.image:getHeight() or 0
	self.name = N or ""
end

function IButtonClass:Contact(X, Y)
	if X >= self.x and X <= self.width + self.x then
		if Y >= self.y and Y <= self.height + self.y then
			return true
		end
	end
	return false
end

function IButtonClass:Draw()
	love.graphics.draw(self.image, self.x, self.y)
end