dButtons = {}

function dButtons:Click(x, y, button)
	if button == 'l' then
		for k, v in pairs(dButtons.buttons) do
			if v:Contact(x, y) then
				dButtons.choosen = v.name
				GameStates:Pop()
			end
		end
	end
end

function dButtons:Update(dt)
end

function dButtons:lineSplit(s)
	split = {}
	o = 0
	for i in string.gmatch(s, "%S+") do
		split[o] = i
		o = o + 1
	end
	return split
end

function dButtons:Draw()
	Reader:Draw()
	r, g, b, a = love.graphics.getColor()
	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.print(textToPrint)
	for k, v in pairs(dButtons.buttons) do
		v:Draw()
	end
	love.graphics.setColor(r, g, b, a)
end

function dButtons:Load()
	dButtons.buttons = {}
	dButtons.choosen = ""
end