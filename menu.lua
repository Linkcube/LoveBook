Menu = {}
local textToPrint = ""

function Menu:Click(x, y, button)
	if button == 'l' then
		for k, v in pairs(Menu.buttons) do
			if v:Contact(x, y) then
				if v.name == "Start" then
					for key, val in pairs(sounds) do
						if val:isPaused() then val:resume() end
					end
					for key, val in pairs(musics) do
						if val:isPaused() then val:resume() end
					end
					if voicePlay then
						voiceTable[voicePos]:resume()
					end
					GameStates:Pop()
				end
			end
		end
	end
end

function Menu:Update(dt)
end

function Menu:lineSplit(s)
	split = {}
	o = 0
	for i in string.gmatch(s, "%S+") do
		split[o] = i
		o = o + 1
	end
	return split
end

function Menu:Draw()
	r, g, b, a = love.graphics.getColor()
	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.print(textToPrint)
	for k, v in pairs(Menu.buttons) do
		v:Draw()
	end
	love.graphics.setColor(r, g, b, a)
end

function Menu:KeyPress(key, isrepeat)
end

function Menu:Load()
	Menu.buttons = {}
	local buttonCount = 1
	for ls in love.filesystem.lines("menu.txt") do -- load assets
		lineS = Menu:lineSplit(ls)
		if lineS[0] == "Button" then
			if lineS[1] == "add" then
				Menu.buttons[buttonCount] = IButtonClass:new(tonumber(lineS[2]), tonumber(lineS[3]), lineS[5], lineS[4])
				buttonCount = buttonCount + 1
			end
		else 
			textToPrint = ls
		end
	end
	for k, v in pairs(sounds) do
		if v:isPlaying() then v:pause() end
	end
	for k, v in pairs(musics) do
		if v:isPlaying() then v:pause() end
	end
	if voicePlay == true then
		if voiceTable[voicePos]:isPlaying() then voiceTable[voicePos]:pause() end
	end
end