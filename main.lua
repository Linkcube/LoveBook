--------------------------------------------------------------------------------
-- The MIT License (MIT)

-- Copyright (c) 2014 Andrew Jon Yobs

-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:

-- The above copyright notice and this permission notice shall be included in
-- all copies or substantial portions of the Software.

-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
-- THE SOFTWARE.

--------------------------------------------------------------------------------
-- Visual Novel,Love Book
-- Requires sunclass
-- Read first part of file and load characters/backgrounds/sounds into classes/lists and load in the load function
local class = require 'sunclass' -- oop functionality
local cLine = 0 -- The current line being read from
local txtDisplay = "" -- The text to display, soon to be changed
local txtLimit = 0 -- The pixel width of text before wrapping
local txtTable = {} -- The table to hold characters for fading in text
local txtAlpha = {} -- Table for alpha values of txtTable
local txtMax = 0 -- The highest count of characters in txtTable
local bg = nil -- The background to be drawn
local characters = {} -- The table of characters in the vn
local backgrounds = {} -- The table of backgrounds in the vn
local width, height = love.graphics.getDimensions() -- The initial height and width of the scren, is changed after loading in init.txt
local line = {} -- The table of lines loaded from files
local br = 255 -- The 'brightness' of to draw non-text
local musics = {} -- The table of music to be played
local sounds = {} -- The table of sounds to be played
local inpt = true -- Whether the user input will be taken into account
local toFade = {} -- The table of characters to fade alpha values
local toShow = {} -- The table of characters to fade in alpha values
local voiceTable = {} -- The table of sound files dedicated to voices
local voicePos = 1 -- The voice file of voiceTable to play
local voicePlay = false -- Whether voice files should be played or not
local sX = 1 -- The scale coefficient of the x-dimension of the background
local sY = 1 -- The scale coefficient of the y-dimension of the background
local click = 0
local Font = love.graphics.newFont(12)
local oldTxt = 1

--[[
--The character class for characters to be drawn, known by a name and given various values for different modifications
--caused by functions later detailed
--]]
 local Character = class('Character')
function Character:initialize(name, imagePath)
	self.poses = {}
	self.name = name -- The name to be called by
	self.poses["default"] = love.graphics.newImage(imagePath) -- The default image to display
	self.image = self.poses["default"] -- The default image to display
	self.x = 0 -- The initial x-position to be drawn from
	self.y = height - self.image:getHeight() -- The initial y-position to be drawn from, most likely won't change
	self.alpha = 0 -- The default alpha, 0 = invisible
	self.fade = 0 -- The direction to fade, 0 = no fade actoin
end

--[[
--Adds a 'pose'; another image that can be drawn in the character's place
--@param pose The name for the pose to be called from in the character's pose table
--@param path The image path for the pose to point to
--]]
function Character:addPose(pose, path)
	self.poses[pose] = love.graphics.newImage(path)
end

--[[
--Draws a character at the alpha of the character
--@param pick The character in the characters table to use
--]]
function Character:Draw()
	love.graphics.setColor(br, br, br, self.alpha)
	love.graphics.draw(self.image, self.x, self.y)
	love.graphics.setColor(br, br, br, 255)
end

--[[
--Moves a character to a select position
--@param chr The character to move
--@param pos The position (left, right, middle) to move to the character
--]]
function Character:Move(pos)
	self.y = height - self.image:getHeight()
	if pos == "right" then
		self.x = (.8 * width) - self.image:getWidth()
	elseif pos == "left" then
		self.x = .2 * width
	elseif pos == "middle" then
		self.x = (width/2) - (self.image:getWidth()/2)
	end
end

--[[
--Initializes the sequence for text to fade in, and wraps the text
--]]
function printInit()
	local space = 0
	local tmpLength = 0
	txtMax = oldTxt
	txtLimit = width * .7
	for j=oldTxt+1, string.len(txtDisplay) do
		ch = string.sub(txtDisplay, j, j)
		txtMax = txtMax + 1
		txtAlpha[txtMax] = 0
		txtTable[txtMax] = ch
		tmpLength = tmpLength + Font:getWidth(txtTable[txtMax])
		if tmpLength > txtLimit then -- If the line goes over the limit, go back to last space and make it a line break
			txtTable[space] = "\n"
			tmpLength = 0
			space = space + 1
			while space < txtMax do
				tmpLength = tmpLength  + Font:getWidth(txtTable[space])
				space = space + 1
			end
		end
		if ch == " " then space = txtMax end
	end
	txtAlpha[1] = 1
end

--[[
--Prints out the txtTable
--]]
function Print()
	local x = width * .15
	local y = 0
	for i=1, txtMax do
		if txtTable[i] ~= nil then
			if txtTable[i] == "\n" then
				x = width * .15
				y = y + Font:getHeight("T")
			else
				love.graphics.setColor(255, 255, 255, txtAlpha[i])
				love.graphics.print(txtTable[i], x, y)
				x = x + Font:getWidth(txtTable[i])
			end
		end
	end
end

--[[
--Splits a string into words
--@param s The string to split
--@return The table of words from 0,...length-1
--]]
function lineSplit(s)
	split = {}
	o = 0
	for i in string.gmatch(s, "%S+") do
		split[o] = i
		o = o + 1
	end
	return split
end

--[[
-- Interprets called for computing a script block that isn't simply adding text
--]]
function computeScript()
	cLine = cLine + 1
	while line[cLine] ~= "--Conf" do
		-- split the line and check 
		lineS = lineSplit(line[cLine])
		-- Characters
		if lineS[0] == "Character" then
			if lineS[2] == "move" then
				characters[lineS[1]]:Move(lineS[3])
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
				sX = width / backgrounds[lineS[1]]:getWidth()
				sY = height /  backgrounds[lineS[1]]:getHeight()
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
			backgrounds[lineS[1]]:setFilter("nearest","nearest", 16)
		elseif lineS[0] == "setResolution" then
			success = love.window.setMode(lineS[1], lineS[2])
		elseif lineS[0] == "setTitle" then
			love.window.setTitle(string.sub(ls, 10))
		-- Sound
		elseif lineS[0] == "Sound" then
		-- Music
			sounds[lineS[1]] = love.audio.newSource(lineS[2], "static")
		elseif lineS[0] == "Music" then
			musics[lineS[1]] = love.audio.newSource(lineS[2], "stream")
			musics[lineS[1]]:setLooping(true)
		-- Font	
		elseif lineS[0] == "Font" then
			Font = love.graphics.newFont(tonumber(lineS[2]))
			love.graphics.setFont(Font)
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
		txtTable = {}
		oldTxt = 1
		txtAlpha =  {}
		bg = nil
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
	-- Fade in text
	for k = oldTxt, txtMax do
		if txtAlpha[k] ~= nil then
			if txtAlpha[k] > 0 and txtAlpha[k] < 255 then
				txtAlpha[k] = txtAlpha[k] + (256 * dt * 2.6 / 1)
			end
			if txtAlpha[k] > 255 then txtAlpha[k] = 255 end
			if txtAlpha[k] > 40 and txtAlpha[k+1] ~= nil and txtAlpha[k+1] == 0 then
				txtAlpha[k+1] = 1
			end
		end
	end
	if txtAlpha[txtMax] == 255 then click = 1 end -- If all text is shown, player click should move to new line
end

--[[
--Takes user input as moving onto the next chunk of text
--@param x The x-pos of the mouse
--@param y The y-pos of the mouse
--@button Which button is being pressed
--]]
function love.mousepressed(x, y, button)
	if inpt == true and button == 'l' then
		if click == 0 then
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
			-- Finish fade on text
			for j=1, txtMax do
				txtAlpha[j] = 255
			end
			click = 1
		else -- Second click, fading et al is done
			click = 0
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
				oldTxt = 1
				y = 0
				printInit()
			elseif line[cLine] == "--Conf" then
				computeScript()
			elseif line[cLine] ~= nill then
				if txtDisplay ~= "" then
					oldTxt = txtMax
				end
				txtDisplay = txtDisplay .. "\n" .."\n" .."\n" .. line[cLine]
				printInit()
			end
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
		love.graphics.draw(bg, 0, 0, 0, sX, sY)
		love.graphics.setColor(255, 255, 255, 255)
	end
	for k,character in pairs(characters) do
		character:Draw()
	end
	Print()
	--love.graphics.print(cLine, 400, 100)
end