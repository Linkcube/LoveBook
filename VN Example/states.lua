class = require("sunclass") -- try out using sunclass from 'qwook'
reader = require('reader')
menu = require('menu')
buttons = require('buttons')
GameStatesClass = class("GameStatesClass")

function GameStatesClass:initialize()
	self.current = 0
	self.states = {}
end

function GameStatesClass:Push(state)
	self.current = self.current + 1
	self.states[self.current] = state
	self.states[self.current]:Load()
end

function GameStatesClass:Pop()
	self.states[self.current] = self.states[self.current - 1]
	self.current = self.current - 1
	self.states[self.current + 1] = nil
end
