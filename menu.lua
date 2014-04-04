Menu = {}

function Menu:Click(x, y, button)
	if button == 'l' then
		for k, v in pairs(sounds) do
			if v:isPaused() then v:resume() end
		end
		for k, v in pairs(musics) do
			if v:isPaused() then v:resume() end
		end
		GameStates:Pop()
	end
end

function Menu:Update(dt)
end

function Menu:Draw()
	r, g, b, a = love.graphics.getColor()
	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.print("You're in the menu! Click to get back to your game")
	love.graphics.setColor(r, g, b, a)
end

function Menu:Load()
	for k, v in pairs(sounds) do
		if v:isPlaying() then v:pause() end
	end
	for k, v in pairs(musics) do
		if v:isPlaying() then v:pause() end
	end
end