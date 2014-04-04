local states = require('states')

function love.load()
	GameStates = GameStatesClass:new()
	GameStates:Push(Reader)
	GameStates:Push(Menu)
end

function love.update(dt)
	GameStates.states[GameStates.current]:Update(dt)
end

function love.mousepressed(x, y, button)
	GameStates.states[GameStates.current]:Click(x, y, button)
end

function love.draw()
	GameStates.states[GameStates.current]:Draw()
end
