-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------
local widget = require("widget")

local baseline = 280
local i = math.random( 400)
local centerX = display.contentCenterX
local centerY = display.contentCenterY
local _W = 480 --display.contentWidth
local _H = 320 --display.contentHeight

--Draw these rectangles for cosmetic purposes (apparent later...)
--For some reason with these, you have to double the width and height (3rd and 4th params)
-- local myRectangle = display.newRect(0,0, 480-(r1.backstamps[1].width*r1.backstamps[1].xScale), 640) -- tall as screen
-- myRectangle:setFillColor( 0,0,0 )
-- local yourRectangle = display.newRect( _W+r1.backstamps[1].width*r1.backstamps[1].xScale,0 ,r1.backstamps[1].width*r1.backstamps[1].xScale , 640 ) --tall as screen
-- yourRectangle:setFillColor( 0,0,0 )
local myRectangle = display.newRect(0,0, 480-(16*2.5), 640) -- tall as screen
myRectangle:setFillColor( 0,0,0 )
local yourRectangle = display.newRect( _W+16*2.5,0 ,16*2.5 , 640 ) --tall as screen
yourRectangle:setFillColor( 0,0,0 )

--Display Memory Usage (Debug)
myRectangle:toFront( )
local label = display.newText("",  50, 310, native.systemFontBold,16)
label.text="Lua Memory: "  .. "  Texture Memory: " .. system.getInfo("textureMemoryUsed")/1000

--table containing berry names
local berries = {"Aguav", "Apicot", "Aspear", "Babiri", "Belue", "Bluk", "Charti", "Cheri", "Chesto",
"Chilan", "Chople", "Coba", "Colbur", "Cornn", "Custap", "Durin", "Enigma", "Figy", "Ganlon", "Grepa",
"Haban", "Hondew", "Iapapa", "Jaboca", "Kasib", "Kebia", "Kelpsy", "Lansat", "Leppa", "Liechi", "Lum",
"Mago", "Magost", "Micle", "Nanab", "Nomel", "Occa", "Oran", "Pamtre", "Passho", "Payapa", "Pecha", 
"Persim", "Petaya", "Pinap", "Pomeg", "Qualot", "Rabuta", "Rawst", "Razz", "Rindo", "Rowap", "Salac",
"Shuca", "Sitrus", "Spelon", "Starf", "Tamato", "Tanga", "Wacan", "Watmel", "Wepear", "Wiki", "Yache",
}
--count number of entries
local berrycount = 0
for _ in pairs(berries) do berrycount = berrycount + 1 end
--array of scores relating to each berry in the berries table above
berryScore = {}
for i=1, berrycount do berryScore[i] = 0 end

--Wild Pokemon stuff
pokeScore = {}
for i=1, 400 do pokeScore[i] = 0 end

--EGG STUFF
local eggPath = system.pathForFile( "eggs/revEggsID.txt" , system.ResourceDirectory )
local eggFile = io.open( eggPath,"r")
io.input(eggFile)
local eggDex = {} --dictionary containing egg info: pokeID:eggID
for i = 1, 400 do
	for k,v in string.gmatch( io.read(), "(%d+):(%d+)" ) do
		print(k .. ":" .. v)
		eggDex[tonumber(k)] = tonumber(v)
	end
end

--START WAY TO LOAD DATA
--Berry File 
local p = system.pathForFile( "inv.txt",system.DocumentsDirectory )
local f = io.open(p, "r")
if(f ~= nil) then
	io.input(f)
	for i=1, berrycount do
		local string = io.read()
		local ID
		local quant
		_, _, ID, quant = string.find(string, "berry(%d+)quant(%d+)")
		berryScore[tonumber(ID)] = tonumber(quant)
	end
	io.close(f)
end
f = nil
-- Poke File
local p = system.pathForFile( "invP.txt",system.DocumentsDirectory )
local f = io.open(p, "r")
if(f ~= nil) then
	io.input(f)
	for i=1, 400 do
		local string = io.read()
		local ID
		local quant
		_, _, ID, quant = string.find(string, "poke(%d+)quant(%d+)")
		pokeScore[tonumber(ID)] = tonumber(quant)
	end
	io.close(f)
end
f = nil

--START WAY TO SAVE DATA
--SAVE COUNT GLOBALS
saveCount = 0 --keeps ttrack of how many times we we've saved
local function saveDataArray(typeCode, berryArray, pokeArray)
	if (saveCount ~= 3) then --counts until array is actually saved
		saveCount = saveCount + 1
		return
  	end
  	--BERRY DATA
	local path = system.pathForFile( "inv.txt",system.DocumentsDirectory )
	local file = io.open(path, "w")
	for i=1, berrycount do
		if(berryArray[i] ~= nil) then 
			local payload = "berry" .. i .. "quant" .. berryArray[i] .. "\r\n"
			file:write( payload )
		end
	end
	io.close( file )
	file = nil
	--POKE DATA
	local pathP = system.pathForFile( "invP.txt",system.DocumentsDirectory )
	local fileP = io.open(pathP, "w")
	for i=1, 400 do
		if(pokeArray[i] ~= nil) then 
			local payload = "poke" .. i .. "quant" .. pokeArray[i] .. "\r\n"
			fileP:write( payload )
		end
	end
	io.close( fileP )
	fileP = nil

	saveCount = 0 --start count over

end

--START SCORE DRAW DEFINE
icons = {} --used for berry
texts = {}
iconsP = {} --used for poke
textsP = {}
sheetsP = {}
iconOffset = 0 --will keep the scores from resetting position each time this is run
               --used in button functions
local function updateScore()
	myRectangle:toFront( )
	yourRectangle:toFront( )
	--DO BERRY SCORES
	local cursor = 1
	--find out which berries have scores
	for i=1, berrycount do
		if (berryScore[i] ~= 0) then
			name = berries[i]
			if(icons[i] ~= nil) then icons[i]:removeSelf( ) end 
			icons[i] = display.newImage("berry/" ..name.. ".png")
			icons[i].xScale = 0.625
			icons[i].yScale = 0.625
			icons[i].x = 0 + icons[i].width*icons[i].xScale
			icons[i].y = cursor * (icons[i].yScale*icons[i].height) + iconOffset

			--For text
			if(texts[i] ~= nil) then texts[i]:removeSelf( ) end
			texts[i] = display.newText( berryScore[i], icons[i].x+(icons[i].xScale*icons[i].width),
										 icons[i].y, "Kalinga", 16)
			texts[i]:setFillColor( 1,0.8,0.05  )
			cursor = cursor + 1
		end
	end
	--DO POKE SCORES
	cursor = 1 --reset cursor
	--find out which pokeis have scores
	for i=1, 400 do
		if(pokeScore[i] ~= 0) then
			if(iconsP[i] ~= nil) then iconsP[i]:removeSelf( ) end 
			if(sheetsP[i] ~= nil) then sheetsP[i] = nil end
			sheetsP[i] = graphics.newImageSheet("allcombo/" .. tostring(i) .. "combo.png", {width=32,height=32,numFrames=8})
			--create an array with random numbers for random frame sequence
			iconsP[i] = display.newSprite( sheetsP[i], {name="wildP", start = 1, count = 8, time=math.random(3500,4500)} )
			iconsP[i].xScale = 1.25
			iconsP[i].yScale = 1.25
			iconsP[i].x =  3 * iconsP[i].width*iconsP[i].xScale
			--iconsP[i].y = cursor * (iconsP[i].yScale*iconsP[i].height)
			iconsP[i].y = cursor * (iconsP[i].yScale*iconsP[i].height) + iconOffset
			iconsP[i]:play( )

			--For text
			if(textsP[i] ~= nil) then textsP[i]:removeSelf( ) end
			textsP[i] = display.newText( pokeScore[i], iconsP[i].x+(iconsP[i].xScale*iconsP[i].width),
										 iconsP[i].y, "Kalinga", 16)
			textsP[i]:setFillColor( 1,0.05,0.9 )
			cursor = cursor + 1
		end
	end

end
--END SCORE DEFINE

-- --print out some of the available font names
-- fonts = native.getFontNames( ) 
-- for i =1,40 do
-- print(fonts[i]) 
-- end

--background
local backsheet1 = graphics.newImageSheet( "bluetileT.png", {width = 16, height=16, numFrames=480} ) --30 columns

--DEFINE The Ribbon Object
local Ribbon = { 
	tiles_per_row = 10,
	ypos = 0,
	berryID = 0, --berryID corresponds to the ribbon's berry type
	pokeID = 0, --the ribbon's pokemon's ID
	wildID = 0, --wildID corresponds to the wild pokemon's ID
	emoteID = 0, --the wild pokemon's emotion ID
	eggID = 0, --the ID of the pokemon egg (if there is one)
	pokeLevel = 1, --the pokemon's level
	wildLevel = math.random(1,4), --the wild pokemon's level
	--HACKS AND SHIT
	notBerry = true, --used to tell if we are moving berry or not
	isPaused = false, --if the ribbon is paused or not
	eventRunning = false, -- if an event is running
	eventRectangle = nil, --rectangle that is used for event animation
	eventTimer = 0, --timer to check if event is done
}
----Constructor
function Ribbon:new(o)
	o = o or {}
	setmetatable(o, self )
	self.__index = self
	return o
end
function Ribbon:setup()
	self.backstamps = {}
	self.backstamps2 = {}
	for i=0, self.tiles_per_row do
		self.backstamps[i] = display.newImageRect( backsheet1, 16, 16, 16 ) --first param is the tile number on sheet
		self.backstamps[i].xScale = 2.5
		self.backstamps[i].yScale = 2.5
		self.backstamps[i].x= _W - ((i)*16*self.backstamps[i].xScale) 
		self.backstamps[i].y= (1+((self.ypos*2 + 1)*2)) * ((self.backstamps[i].height/2)*self.backstamps[i].yScale) --second term is the length of stamp

		--other row
		--self.backstamps2[i] = display.newImageRect( backsheet1, 17, 16, 16 ) --first param is the tile number on sheet
		self.backstamps2[i] = display.newSprite(backsheet1, {start=1, count=480, time=250} )
		self.backstamps2[i].xScale = 2.5
		self.backstamps2[i].yScale = 2.5
		self.backstamps2[i].x= _W - ((i-1)*16*self.backstamps[i].xScale) 
		self.backstamps2[i].y= (1+(self.ypos*2*2)) * ((self.backstamps[i].height/2)*self.backstamps[i].yScale) 

		--move everything down a touch
		JAtouch = 40;
		self.backstamps[i].y = self.backstamps[i].y + JAtouch;
		self.backstamps2[i].y = self.backstamps2[i].y + JAtouch;
	end

	--Set up the Level Display
	-- local x = _W - ((self.backstamps[0].width*self.backstamps[0].xScale)/2)
	-- local y = self.backstamps2[0].y
	-- self.levelSquare = display.newRect( x,y, 
	-- 	self.backstamps[0].width*self.backstamps[0].xScale , 
	-- 	self.backstamps[0].height*self.backstamps[0].yScale )
	-- self.levelSquare:setFillColor( 0 )
	-- self.levelText = display.newText( self.pokeLevel, self.levelSquare.x,
	-- 	self.levelSquare.y, native.systemFontBold, 16)
	-- self.levelText:setFillColor( 0,1,0.5 )

	-- Pokemon
	i = math.random(400)
	self.pokeID = i
	self.sheet1 = graphics.newImageSheet( "allcombo/" .. tostring(i) .. "combo.png" , {width= 32, height=32,numFrames=8} )
	self.instance1 = display.newSprite(self.sheet1, {name="poke", start=3, count = 2, time=250})
	self.instance1.x = _W/2 --middle of screen!!
	self.instance1.y = self.backstamps[1].y 
	self.instance1.xScale = 1.25
	self.instance1.yScale = 1.25 --Half tile scale since this is 32x32 and tile is 16x16
	self.instance1:play()

	-- Berry
	i = math.random(berrycount)
	name = berries[i]
	self.berryID = i
	self.berry = display.newImage("berry/" ..name.. ".png")
	self.berry.x = _W + 60
	self.berry.y = self.backstamps[1].y
	self.berry.xScale = 0.625
	self.berry.yScale = 0.625

	--Make the Event rectangle
	local x =self.instance1.x + ((self.instance1.width*self.instance1.xScale)/2)
	local y =self.instance1.y - ((self.instance1.height*self.instance1.yScale)/2)
	local w = 2 * (self.instance1.width*self.instance1.xScale)
	self.eventRectangle = display.newRect(x,y,w,w  ) -- tall as screen
	self.eventRectangle:setFillColor( 0,0,0 )
	self.eventRectangle:toBack( )

	self.tPrevious = system.getTimer( ) --start timer
end
function Ribbon:moveBackground()
	for i=0, self.tiles_per_row do
		self.backstamps[i].x = self.backstamps[i].x - 1
		--if backstamp is at the beginning of row on screen (so far away from RH of screen)
		if self.backstamps[i].x - ((self.backstamps[i].width/2)*self.backstamps[i].xScale) < _W - (self.backstamps[i].xScale * self.backstamps[i].width *(self.tiles_per_row))
			--Send it to the end of the screen (beggining of ribbon)
		then self.backstamps[i].x = _W + (self.backstamps[i].width * self.backstamps[i].xScale) - 1-- Minus 1 to get rid of black vert
		end

		self.backstamps2[i].x = self.backstamps2[i].x - 1
		--if backstamp is at the beginning of row on screen (so far away from RH of screen)
		if self.backstamps2[i].x - ((self.backstamps2[i].width/2)*self.backstamps2[i].xScale) < _W - (self.backstamps2[i].xScale * self.backstamps2[i].width *(self.tiles_per_row))
			--Send it to the end of the screen (beggining of ribbon)
		then 
			self.backstamps2[i].x = _W + (self.backstamps2[i].width * self.backstamps2[i].xScale) - 1-- Minus 1 to get rid of black vert
			--j = math.random(400)
			j = 134

			self.backstamps2[i]:setFrame( j )
		end
	end

end
function Ribbon:moveBerry(event)
	self.tDelta = event.time - self.tPrevious
	self.tPrevious = event.time
	self.xOffset = ( 0.02 * self.tDelta)
	self.berry.x = self.berry.x - self.xOffset

	if self.berry.x < 240+ 16 then --if berry reach pokemon
		self.berry.x = _W + 50
		self.notBerry = true --give the berry a break
		--add to score GLOBAL VARIABLE
		berryScore[self.berryID] = berryScore[self.berryID] + 1
		--updateScore()

		saveDataArray(1, berryScore, pokeScore)
	end

	self.tPrevious = system.getTimer( )
end
function Ribbon:moveAndMakeWildPokemon(event)
	if (self.instance2 == nil) then
		-- Pokemon
		self.wildID = math.random( 400)
		--self.wildID = 53
		self.sheet2 = graphics.newImageSheet( "allcombo/" .. tostring(self.wildID) .. "combo.png" , {width= 32, height=32,numFrames=8} )
		self.instance2 = display.newSprite(self.sheet2, {name="pokeW", start=5, count = 2, time=250})
		self.instance2.x = _W + 60
		self.instance2.y = self.backstamps[1].y 
		self.instance2.xScale = 1.25
		self.instance2.yScale = 1.25 --Half tile scale since this is 32x32 and tile is 16x16
		self.instance2:play()
		--Emoticon
		self.emoteID = math.random(3)
		self.sheetE = nil
		self.sheetE = graphics.newImageSheet( "emotion/" .. tostring(self.emoteID) .. ".png", {width=16, height = 16, numFrames=2})
		self.instanceE = display.newSprite(self.sheetE, {name="emote", start = 1, count = 2, time=500})
		self.instanceE.x = self.instance2.x
		self.instanceE.y = self.instance2.y - (self.instance2.yScale*self.instance2.height)
		self.instanceE.xScale = 2.5
		self.instanceE.yScale = 2.5
		self.instanceE:play( )


	end
	--Actually Move
	self.tDelta = event.time - self.tPrevious
	self.tPrevious = event.time
	self.xOffset = ( 0.02 * self.tDelta)
	self.instance2.x = self.instance2.x - self.xOffset
	self.instanceE.x = self.instance2.x

	if self.instance2.x < self.instance1.x + (self.instance2.xScale*self.instance1.width) then --if wild poke reach pokemon
		encounterWild(self,event)
	end

	self.tPrevious = system.getTimer( )
end
function encounterWild(self,event)

	--self.isPaused = true
	--self.instance1:pause( )
	--self.instance2:pause()
	if(self.eventRunning == false) then
		if (self.emoteID == 1) then
			self.isPaused = true
			self.eventRunning = true
			--update the xpos of the event rect and move to front
			self.eventRectangle.x =self.instance1.x + ((self.instance1.width*self.instance1.xScale)/2)
			self.eventRectangle:toFront( )
			self.eventRectangle:setFillColor( 1,0.2,0.8 )
			self.eventSheet = graphics.newImageSheet( "events/heart.png", {width=32, height = 32, numFrames=8})
			self.eventInstance = display.newSprite(self.eventSheet, {name="event", start = 1, count = 8, time=500})
			self.eventInstance.x = self.eventRectangle.x
			self.eventInstance.y = self.eventRectangle.y
			self.eventInstance:play( )
			self.eventTimer = system.getTimer( )
			return
		end
	end

	--Remove All traces of pokemon and enter score
	self.instance2:removeSelf( )
	self.instance2 = nil
	self.sheet2 = nil
	self.instanceE:removeSelf( )
	self.instanceE= nil
	self.sheetE = nil
	self.notBerry = false --flag to start berry run
	--add to score GLOBAL VARIABLE
	pokeScore[self.wildID] = pokeScore[self.wildID] + 1
	saveDataArray(2, berryScore, pokeScore)
end
function Ribbon:checkDone(event)
	--If the time is a certain amount after when the even started
	if((event.time - self.eventTimer)>5000)then 
		--Remove All traces of pokemon and enter score
		self.instance2:removeSelf( )
		self.instance2 = nil
		self.sheet2 = nil
		self.instanceE:removeSelf( )
		self.instanceE= nil
		self.sheetE = nil
		self.notBerry = false --flag to start berry run
		if(self.emoteID == 1)then --If heart event
			if(math.random()>0.5)then self.eggID = eggDex[self.wildID]
			else self.eggID = eggDex[self.pokeID] end
			print(tostring(self.eggID))

			self.egg = widget.newButton{
				width = 32,
				height = 32,
				defaultFile = "eggs/"..tostring(self.eggID)..".png",
				overFile = "eggs/"..tostring(self.eggID)..".png",
				onEvent = self:clickEgg()
			}
			self.egg.x = (_W/2) - (self.instance1.width*self.instance1.xScale)
			self.egg.y = self.instance1.y
			self.egg.xScale = 0.625
			self.egg.yScale = 0.625

			-- self.egg = display.newImage("eggs/" .. tostring(self.eggID) .. ".png")
			-- self.egg.x = (_W/2) - (self.instance1.width*self.instance1.xScale)
			-- self.egg.y = self.instance1.y
			-- self.egg.xScale = 0.625
			-- self.egg.yScale = 0.625
		end

		self.eventRunning = false
		self.isPaused = false
		self.eventRectangle:toBack( )
		self.eventInstance:toBack()
	end
end
function Ribbon:clickEgg(event)
	print("this")
	if(self.egg ~= nil) then
		print("happened")
	end
end
--END OF RIBBON DEFINE

r1 = Ribbon:new{ypos =1}
r1:setup()
r2 = Ribbon:new{ypos = 2}
r2:setup()
r3 = Ribbon:new{ypos = 0}
r3:setup()

updateScore()

--ADD BUTTON STUFF
--Function to handle button
local function handleDownButtonEvent(event)
	for i=1, berrycount do
		if (icons[i] ~= nil) then icons[i].y = icons[i].y - 20 end
		if (texts[i] ~= nil) then texts[i].y = texts[i].y - 20 end
	end
	for i=1, 400 do
		if (iconsP[i] ~= nil) then iconsP[i].y = iconsP[i].y - 20 end
		if (textsP[i] ~= nil) then textsP[i].y = textsP[i].y - 20 end
	end
	iconOffset = iconOffset - 20
end
local function handleUpButtonEvent(event)
	for i=1, berrycount do
		if (icons[i] ~= nil) then icons[i].y = icons[i].y + 20 end
		if (texts[i] ~= nil) then texts[i].y = texts[i].y + 20 end
	end
	for i=1, 400 do
		if (iconsP[i] ~= nil) then iconsP[i].y = iconsP[i].y + 20 end
		if (textsP[i] ~= nil) then textsP[i].y = textsP[i].y + 20 end
	end
	iconOffset = iconOffset + 20
end
local function networkButton(event)
	myRectangle:toFront()
end
local button1 = widget.newButton{
	width = 20,
	height = 20,
	defaultFile = "ball/1.png",
	overFile = "ball/2.png",
	onEvent = handleDownButtonEvent
}
button1.x = _W/2
button1.y = _H - 10
local button2 = widget.newButton{
	width = 20,
	height = 20,
	defaultFile = "ball/1.png",
	overFile = "ball/2.png",
	onEvent = handleUpButtonEvent
}
button2.x = _W/2
button2.y = 0 + 10
local button3 = widget.newButton{
	width = 20,
	height = 20,
	defaultFile = "ball/1.png",
	overFile = "ball/2.png",
	onEvent = updateScore
}
button3.x = _W/2 + 50
button3.y =  _H - 10
local button4 = widget.newButton{
	width = 20,
	height = 20,
	defaultFile = "ball/1.png",
	overFile = "ball/2.png",
	onEvent = networkButton
}
button4.x = _W/2 + 50 + 50
button4.y =  _H - 10
--END BUTTON STUFF

local function move(event)

	if(not r1.isPaused) then
		hi = r1:moveBackground()
		--Both poke and berry
		if(r1.notBerry == false) then  hey = r1:moveBerry(event)
		else ho = r1:moveAndMakeWildPokemon(event) end
	end
	if(not r2.isPaused) then
		hi = r2:moveBackground()
		--Both poke and berry
		if(r2.notBerry == false) then  hey = r2:moveBerry(event)
		else ho = r2:moveAndMakeWildPokemon(event) end
	end
	if(not r3.isPaused) then
		hi = r3:moveBackground()
		--Both poke and berry
		if(r3.notBerry == false) then  hey = r3:moveBerry(event)
		else ho = r3:moveAndMakeWildPokemon(event) end
	end

	if(r1.eventRunning == true) then 
		hi = r1:checkDone(event)
	end
	if(r2.eventRunning == true) then 
		hi = r2:checkDone(event)
	end
	if(r3.eventRunning == true) then 
		hi = r3:checkDone(event)
	end




	yourRectangle:toFront( )
	button1:toFront( ) --because it gets covered by rectangle
	if(r1.egg ~= nil) then r1.egg:toFront( ) end
	if(r2.egg ~= nil) then r2.egg:toFront( ) end
	if(r3.egg ~= nil) then r3.egg:toFront( ) end

	--Display Memory Usage (Debug)
	--myRectangle:toFront( )
	--label:toFront( )
	--label.text="Lua Memory: "  .. "  Texture Memory: " .. system.getInfo("textureMemoryUsed")/1000
	--label.text="Lua Memory: "  .. "  Texture Memory: " .. system.getInfo("textureMemoryUsed")/1000

end

Runtime:addEventListener( "enterFrame", move);


