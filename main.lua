-- Disclaimer: All software is provided as is, with no expectations. All rights are reserved by respective owners (love2d et al) as well as by the writer of this code, and all conditions of use can be changed on a whim without notification.
-- With the above line in consideration, you may distribute this code along with your script.txt and init.txt, but let the creator know of this (he would like to know when someone has used this ;) ) 
-- Visual Novel,Love Book
-- Requires middleclass, may switch over to sunclass later
-- Read first part of file and load characters/backgrounds/sounds into classes/lists and load in the load function
local class = require 'middleclass' -- oop functionality
local cLine = 0
local txtDisplay = ""
local bg = nil
local characters = {}
local backgrounds = {}
local width, height = love.graphics.getDimensions()
local line = {}
local br = 255
local musics = {}
local sounds = {}
local inpt = true
local toFade = {}
local toShow = {}
local voiceTable = {}
local voicePos = 1
local voicePlay = false

 local Character = class('Character')
function Character:initialize(name, imagePath)
	self.poses = {}
	self.name = name
	self.poses["default"] = love.graphics.newImage(imagePath)
	self.image = self.poses["default"]
	self.x = 0
	self.y = height - self.image:getHeight()
	self.alpha = 0
	self.fade = 0
end

function Character:addPose(pose, path)
	self.poses[pose] = love.graphics.newImage(path)
end

function draw(pick)
	love.graphics.setColor(br, br, br, characters[pick].alpha)
	love.graphics.draw(characters[pick].image, characters[pick].x, characters[pick].y)
	love.graphics.setColor(br, br, br, 255)
end

function Move(chr, pos)
	characters[chr].y = height - characters[chr].image:getHeight()
	if pos == "right" then
		characters[chr].x = (.8 * width) - characters[chr].image:getWidth()
	elseif pos == "left" then
		characters[chr].x = .2 * width
	elseif pos == "middle" then
		characters[chr].x = (width/2) - (characters[chr].image:getWidth()/2)
	end
end

function lineSplit(s)
	split = {}
	o = 0
	for i in string.gmatch(s, "%S+") do
		split[o] = i
		o = o + 1
	end
	return split
end

-- Gets called for computing a script block that isn't simply adding text
function computeScript()
	cLine = cLine + 1
	while line[cLine] ~= "--Conf" do
		-- split the line and check 
		lineS = lineSplit(line[cLine])
		-- Characters
		if lineS[0] == "Character" then
			if lineS[2] == "move" then
				Move(lineS[1],lineS[3])
			elseif lineS[2] == "show" then
				characters[lineS[1]].fade = 1
				--characters[lineS[1]].alpha = 255
			elseif lineS[2] == "hide" then
				characters[lineS[1]].fade = -1
			elseif lineS[2] == "pose" then
				characters[lineS[1]].image = characters[lineS[1]].poses[lineS[3]]
			end
		-- Backgrounds
		elseif lineS[0] == "Background" then
			if lineS[2] == "set" then
				bg = backgrounds[lineS[1]]
			end
			if lineS[1] == "remove" then
				bg = nil
			end
		-- Sounds
		elseif lineS[0] == "Sound" then
			if lineS[2] == "play" then
				sounds[lineS[1]]:play()
			elseif lineS[2] == "stop" then
				sounds[lineS[1]]:stop()
			elseif lineS[2] == "volume" then
				sounds[lineS[1]]:setVolume(tonumber(lineS[3]))
			end
		-- Musics
		elseif lineS[0] == "Music" then
			if lineS[2] == "play" then
				musics[lineS[1]]:play()
			elseif lineS[2] == "stop" then
				musics[lineS[1]]:stop()
			elseif lineS[2] == "volume" then
				musics[lineS[1]]:setVolume(tonumber(lineS[3]))
			end
		end
		cLine = cLine + 1
	end
end

function love.load()
	for ls in love.filesystem.lines("init.txt") do -- load assets
		lineS = lineSplit(ls)
		if lineS[0] == "Character" then
			if lineS[2] == "addPose" then
				characters[lineS[1]]:addPose(lineS[3], lineS[4])
			else
				characters[lineS[1]] = Character:new(lineS[1], lineS[2])
			end
		elseif lineS[0] == "Background" then
			backgrounds[lineS[1]] = love.graphics.newImage(lineS[2])
		elseif lineS[0] == "setResolution" then
			success = love.window.setMode(lineS[1], lineS[2])
		elseif lineS[0] == "setTitle" then
		-- Sound
			love.window.setTitle(string.sub(ls, 12, 0))
		elseif lineS[0] == "Sound" then
		-- Music
			sounds[lineS[1]] = love.audio.newSource(lineS[2], "static")
		elseif lineS[0] == "Music" then
			musics[lineS[1]] = love.audio.newSource(lineS[2], "stream")
			musics[lineS[1]]:setLooping(true)
		-- Font	
		elseif lineS[0] == "Font" then
			font = love.graphics.newFont(tonumber(lineS[2]))
			love.graphics.setFont(font)
		-- Voice Table
		elseif lineS[0] == "VoiceTable" then
			for title, dir in pairs(love.filesystem.getDirectoryItems(lineS[1])) do
				voiceTable[voicePos] = dir
				voicePos = voicePos
			end
			voicePlay = true
			voicePos = 1
		end
	end
	width, height = love.graphics.getDimensions()
	ls = nil
	for ls in love.filesystem.lines("script.txt") do -- load script into memory
		line[cLine] = ls
		cLine = cLine + 1
	end
	lineCount = cLine
	cLine = 0
	txtDisplay = line[0]
end

function love.update(dt)
	-- when player input of mouse/enter/space go to next block of script
	if love.keyboard.isDown("r") then -- restart
		cLine = 0
		txtDisplay = ""
		drawableBg = {}
		characters = {}
		line = {}
		br = 255
		love.audio.stop()
		love.load()
	end
	-- Fade out action, done in update to make it gradual
	for k,character in pairs(characters) do
		if character.fade == -1 then
			if character.alpha > 0 then
				character.alpha = character.alpha - (256 * dt * 2 / 1) -- Total value * delta time * balance / time to die
			end
			if character.alpha < 0 then
				character.alpha = 0
				character.fade = 0
			end
		elseif character.fade == 1 then
			if character.alpha < 255 then
				character.alpha = character.alpha + (256 * dt * 2 / 1) -- Total value * delta time * balance / time to die
			end
			if character.alpha > 255 then
				character.alpha = 255
				character.fade = 0
			end
		end
	end
end

function love.mousepressed(x, y, button)
	if button == 'l' and inpt == true then
		-- Finish fade on player demand
		for character,k in pairs(characters) do
			if k.fade == -1 then
				k.alpha = 0
				k.fade = 0
			elseif k.fade == 1 then
				k.alpha = 255
				k.fade = 1
			end
		end
		-- Voice Cancel/Refresh
		if voicePlay then
			voiceTable[voicePos-1]:stop()
			voiceTable[voicePos]:play()
			voicePos = voicePos + 1
		end
		-- Start traversing the next chunk of lines
		cLine = cLine + 1
		if line[cLine] == "--Clear" then
			txtDisplay = ""
		elseif line[cLine] == "--Conf" then
			computeScript()
		elseif line[cLine] ~= nill then
			txtDisplay = txtDisplay .. "\n\n\n " .. line[cLine]
		end
	end
end

function love.draw()
	-- If there is text being displayed dim the rest of the screen
	if txtDisplay ~= "" then
		br = 125
	else 
		br = 255 
	end
	-- If there is a background then draw it
	if bg ~= nil then
		love.graphics.setColor(br, br, br, 255)
		love.graphics.draw(bg, 0, 0)
		love.graphics.setColor(255, 255, 255, 255)
	end
	for character,k in pairs(characters) do
		draw(character)
	end
	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.printf(txtDisplay, width*.15, 0, .7 * width)
	--love.graphics.print(cLine, 400, 100)
end