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

--Use nearest neighbor for scaling
display.setDefault( magTextureFilter, nearest )
display.setDefault( minTextureFilter, nearest )

--Draw these rectangles for cosmetic purposes (apparent later...)
--For some reason with these, you have to double the width and height (3rd and 4th params)
-- local myRectangle = display.newRect(0,0, 480-(r1.backstamps[1].width*r1.backstamps[1].xScale), 640) -- tall as screen
-- myRectangle:setFillColor( 0,0,0 )
-- local yourRectangle = display.newRect( _W+r1.backstamps[1].width*r1.backstamps[1].xScale,0 ,r1.backstamps[1].width*r1.backstamps[1].xScale , 640 ) --tall as screen
-- yourRectangle:setFillColor( 0,0,0 )
local myRectangle = display.newRect(0,0, 480-(16*2.5), 700) -- tall as screen
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
local berrycount = 0 --start at 0
for _ in pairs(berries) do berrycount = berrycount + 1 end
--array of scores relating to each berry in the berries table above
berryScore = {}
for i=1, berrycount do berryScore[i] = 0 end

--Wild Pokemon stuff
pokeScore = {}
for i=1, 400 do pokeScore[i] = 0 end

--EGG STUFF
--opne up the mapping from pokemon to eggs
local eggPath = system.pathForFile( "eggs/revEggsID.txt" , system.ResourceDirectory )
local eggFile = io.open( eggPath,"r")
io.input(eggFile)
local eggDex = {} --dictionary containing egg info: pokeID:eggID
for i = 1, 400 do
	for k,v in string.gmatch( io.read(), "(%d+):(%d+)" ) do
		eggDex[tonumber(k)] = tonumber(v)
	end
end
io.close(eggFile)
--Open up the mapping of eggs to pokemon they hatch into
local eggPath = system.pathForFile( "eggs/evosID.txt" , system.ResourceDirectory )
local eggFile = io.open(eggPath, "r")
io.input( eggFile )
local egg2poke = {}
for i = 1, 209 do
	for k,v in string.gmatch( io.read(), "(%d+):(%d*)" ) do
		egg2poke[i] = tonumber(k)
	end
end
io.close(eggFile)

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
--local p = system.pathForFile( "invP.txt",system.ResourceDirectory )
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
texts = {} --texts for berreis
trees = {} --used for tree sprites
grass = {} --holds grass tile behind tree
grass2= {} --holds the grass tile above tree
huts = {} --holds the hut tile beside tree
huts2 = {} --holds the second hut tile
hutRoofs = {} --holds the hut roof tile beside tree
hutRoofs2 = {} --holds the second hut roof tile
sheetsP = {} --used for tree sprite sheets
iconsP = {} --used for poke
textsP = {}	--texts for poke scores
sheetsP = {} --sprite sheets for pokemon
fields = {} -- pokemon field recatngles
fields2 = {}
fences2 = {}
fences = {} --fence rectangles
iconOffset = 16 --will keep the scores from resetting position each time this is run
               --used in button functions
bCursor = 1 -- points to the current element in berry score array
pCursor = 1 -- points to the current element in poke score array
d = 1 --display counter: keeps track of number of displayed icons on screen
iconLimit = 6 -- determines how many icons to display at once (per column)
colorSheet = graphics.newImageSheet( "backs/color.png" , {width=16, height=16, numFrames=880} )
--first, declare functions this score display process will need
---------------------------------------------------------------
--Add a sprite event listener to tell when animations are done
function spriteListener(event)
	--the name of the event corresponds to which tree finished
	local id = event.target.id
	if(event.phase == "loop")then
		--print(event.target.id)
		berryScore[id] = berryScore[id] + 1
	end
end
----------------------------------------------------------
--Now, the actual function that updates and displays scores
--------------------------------------------------------------
local function newScore()
	myRectangle:toFront( )
	yourRectangle:toFront( )
	--turn off the network view
	if isNetworkViewOn == true then isNetworkViewOn = false end

	if(nameField~=nil)then nameField:removeSelf( ); nameField = nil end
	if(teamField~=nil)then teamField:removeSelf( ); teamField = nil end

	--Do BERRY SCORES
	d = 1 --reset counter for berries
	--i goes through all scores from where the cursor is to the end
	for i=bCursor, berrycount do 
		while(d<iconLimit) do			
			local checkScore = i + (d-1) --the id in the score array we are checking
			if(berryScore[checkScore]~=0)then
				name = berries[checkScore]
				if(icons[d] ~= nil) then icons[d]:removeSelf( ) end  --remove if there was one already
				icons[d] = display.newImage("berry/" ..name.. ".png")
				--Scale used to be 0.625 (and the others adjusted accordingly)
				icons[d].xScale = 0.5
				icons[d].yScale = 0.5
				icons[d].x = 0 + icons[d].width*icons[d].xScale + (icons[d].xScale*icons[d].width)
				icons[d].y = ( 2*d - 1 ) * (icons[d].yScale*icons[d].height) + iconOffset
				--For text
				if(texts[d] ~= nil) then texts[d]:removeSelf( ) end
				texts[d] = display.newText( berryScore[checkScore], icons[d].x,
											 icons[d].y -(icons[d].xScale*icons[d].width) , "GungsuhChe", 16)
				-- texts[i]:setFillColor( 1,0.6,0.05  )
				texts[d]:setFillColor( 0.2,0.2,0.6  )

				--For trees
				treeSheet = graphics.newImageSheet("treespace/"..name.."comboS.png",
					{width = 32, height = 32, numFrames=5})
				if(trees[d] ~= nil) then trees[d]:removeSelf( ) end
				trees[d] = display.newSprite(treeSheet, 
					{name=tostring(d), start=1, count=5, time=math.random(7000,20000)})
				trees[d].x = icons[d].x - (icons[d].xScale*icons[d].width)
				trees[d].y = icons[d].y
				trees[d].id = checkScore --berryid number of the tree

				trees[d]:play()

				trees[d]:addEventListener( "sprite", spriteListener )

				--for grass
				if(grass[d]~=nil) then grass[d]:removeSelf() end
				grass[d] = display.newImageRect(colorSheet, 26,16,16)
				grass[d].x = trees[d].x
				grass[d].y = trees[d].y
				grass[d].xScale = 2
				grass[d].yScale = 2
				if(grass2[d]~=nil) then grass2[d]:removeSelf() end
				grass2[d] = display.newImageRect(colorSheet, 126,16,16)
				grass2[d].x = trees[d].x
				grass2[d].y = trees[d].y - (icons[d].xScale*icons[d].width)
				grass2[d].xScale = 2
				grass2[d].yScale = 2

				--for huts
				if(huts[d]~=nil)then huts[d]:removeSelf( ) end
				huts[d] = display.newImageRect(colorSheet, 429,16,16)
				huts[d].x = trees[d].x + (icons[d].xScale*icons[d].width)
				huts[d].y = trees[d].y
				huts[d].xScale = 2
				huts[d].yScale = 2
				if(hutRoofs[d]~=nil)then hutRoofs[d]:removeSelf( ) end
				hutRoofs[d] = display.newImageRect(colorSheet, 377,16,16)
				hutRoofs[d].x = trees[d].x + (icons[d].xScale*icons[d].width)
				hutRoofs[d].y = trees[d].y - (icons[d].xScale*icons[d].width)
				hutRoofs[d].xScale = 2
				hutRoofs[d].yScale = 2
				if(huts2[d]~=nil)then huts2[d]:removeSelf( ) end
				huts2[d] = display.newImageRect(colorSheet, 432,16,16) --maybe tile 310
				huts2[d].x = trees[d].x + 2*(icons[d].xScale*icons[d].width)
				huts2[d].y = trees[d].y
				huts2[d].xScale = 2
				huts2[d].yScale = 2
				if(hutRoofs2[d]~=nil)then hutRoofs2[d]:removeSelf( ) end
				hutRoofs2[d] = display.newImageRect(colorSheet, 380,16,16)
				hutRoofs2[d].x = trees[d].x + 2*(icons[d].xScale*icons[d].width)
				hutRoofs2[d].y = trees[d].y - (icons[d].xScale*icons[d].width)
				hutRoofs2[d].xScale = 2
				hutRoofs2[d].yScale = 2

				--correct order
				trees[d]:toFront( )
				texts[d]:toFront( )
				icons[d]:toFront( )

				d = d + 1 --increment display counter
				--checkScore = checkScore + 1

			else 
				d = d+ 1
			end
		end
	end
	--DO POKE SCORES
	d = 1 --reset counter for berries
	--i goes through all scores from where the ursor is to the end
	for i=pCursor, 400 do 
		while(d<iconLimit) do
			local checkScore = i + (d-1) --the id in the score array we are checking
			if(pokeScore[checkScore]~=0 and pokeScore[checkScore]~=nil)then
				if(iconsP[d] ~= nil) then iconsP[d]:removeSelf( ) end 
				if(sheetsP[d] ~= nil) then sheetsP[d] = nil end
				sheetsP[d] = graphics.newImageSheet("allcombo/" .. tostring(checkScore) .. "combo.png", {width=32,height=32,numFrames=8})
				--create an array with random numbers for random frame sequence
				iconsP[d] = display.newSprite( sheetsP[d], {name="wildP", start = 1, count = 8, time=math.random(3500,4500)} )
				iconsP[d].xScale = 1
				iconsP[d].yScale = 1
				iconsP[d].x =  4 * iconsP[d].width*iconsP[d].xScale
				--iconsP[i].y = cursor * (iconsP[i].yScale*iconsP[i].height)
				iconsP[d].y = ( 2*d - 1 ) * (iconsP[d].yScale*iconsP[d].height) + iconOffset
				iconsP[d]:play( )

				--For text
				if(textsP[d] ~= nil) then textsP[d]:removeSelf( ) end
				textsP[d] = display.newText( pokeScore[checkScore], iconsP[d].x+(iconsP[d].xScale*iconsP[d].width),
											 iconsP[d].y, "GungsuhChe", 16)
				--textsP[i]:setFillColor( 1,0.05,0.8 )
				textsP[d]:setFillColor( 1,0.8,0.05 )

				--For corrall/fields that go with pokemon
				--if(fields[i] ~= nil) then textsP[i]:removeSelf( ) end
				fields[d] = display.newImageRect(colorSheet, 151, 16,16)
				fields[d].x = iconsP[d].x
				fields[d].y = iconsP[d].y
				fields[d].xScale = 2
				fields[d].yScale = 2
				fields2[d] = display.newImageRect(colorSheet, 567, 16,16)
				fields2[d].x = iconsP[d].x + (fields[d].yScale*fields[d].height)
				fields2[d].y = iconsP[d].y
				fields2[d].xScale = 2
				fields2[d].yScale = 2

				--For fences that go with pokemon
				fences[d] = display.newImageRect(colorSheet, 195 , 16,16)
				fences[d].x = fields[d].x
				fences[d].y = fields[d].y - (fields[d].yScale*fields[d].height)
				fences[d].xScale = 2
				fences[d].yScale = 2
				fences2[d] = display.newImageRect(colorSheet, 195 , 16,16)
				fences2[d].x = fields2[d].x
				fences2[d].y = fields2[d].y - (fields[d].yScale*fields[d].height)
				fences2[d].xScale = 2
				fences2[d].yScale = 2

				--correct order
				iconsP[d]:toFront( )
				textsP[d]:toFront( )

				d=d+1
				--checkScore = checkScore + 1

			else				
				--move on to the next one
				d=d+1
			end

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
		-- updateScore() --long routine

		--Start hatching egg
		if(self.hatch~=nil)then 
			if(self.hatch.frame == 5)then
				self:hatchEgg()
			else
				self.hatch:setFrame(self.hatch.frame + 1)
			end
		end

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
		self.sheet2 = nil
		--Emoticon
		self.emoteID = math.random(3)
		self.sheetE = nil
		self.sheetE = graphics.newImageSheet( "emotion/" .. tostring(self.emoteID) .. ".png", {width=16, height = 16, numFrames=2})
		self.instanceE = display.newSprite(self.sheetE, {name="emote", start = 1, count = 2, time=500})
		self.instanceE.x = self.instance2.x
		self.instanceE.y = self.instance2.y - (self.instance2.yScale*self.instance2.height)/1.5
		--The scale we be just a tad smaller than the ratio ;p
		self.instanceE.xScale = 2 
		self.instanceE.yScale = 2
		self.instanceE:play( )
		self.sheetE = nil

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

	--start an event running if it needs to...
	if(self.eventRunning == false) then
		if (self.emoteID == 1) then
			self.isPaused = true
			self.eventRunning = true
			--update the xpos of the event rect and move to front
			self.eventRectangle.x =self.instance1.x + ((self.instance1.width*self.instance1.xScale)/2)
			self.eventRectangle:toFront( )
			self.eventRectangle:setFillColor( 1,0.2,0.8 )
			self.eventSheet = graphics.newImageSheet( "events/heartRip.png", {width=32, height = 32, numFrames=5})
			self.eventInstance = display.newSprite(self.eventSheet, {name="event", start = 1, count = 5, time=500})
			self.eventInstance.x = self.eventRectangle.x
			self.eventInstance.y = self.eventRectangle.y
			self.eventInstance.yScale = 1.25
			self.eventInstance.xScale = 1.25			
			self.eventInstance:play( )
			self.eventTimer = system.getTimer( )
			return
		end
	end

	--IF an event doesn't need to be run, we just erase sprite and add the encountered poke to score

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
	if((event.time - self.eventTimer)>math.random(5000,10000))then 
		--Remove All traces of pokemon and enter score
		self.instance2:removeSelf( )
		self.instance2 = nil
		self.sheet2 = nil
		self.instanceE:removeSelf( )
		self.instanceE= nil
		self.sheetE = nil
		self.notBerry = false --flag to start berry run
		if(self.emoteID == 1)then --If heart event
			--make room for new egg
			if(self.instanceBorn~=nil)then self.instanceBorn:removeSelf();self.instanceBorn = nil end
			--make the egg if need be
			if(self.egg==nil)then
				if(math.random()>0.5)then self.eggID = eggDex[self.wildID]
				else self.eggID = eggDex[self.pokeID] end

				self.egg = display.newImage("eggs/" .. tostring(self.eggID) .. ".png")
				self.egg.x = (_W/2) - (self.instance1.width*self.instance1.xScale)
				self.egg.y = self.instance1.y
				self.egg.xScale = 0.625
				self.egg.yScale = 0.625

				--do hatch animation
				--self.hatch = display.newImage("eggs/hatchsheet.png")
				self.hatchSheet = graphics.newImageSheet( "eggs/hatchsheet.png", {width=160, height = 160, numFrames=5})
				self.hatch = display.newSprite(self.hatchSheet, {name="hatch", start = 1, count = 5, time=5000})
				self.hatch.x = self.egg.x
				self.hatch.y = self.egg.y
				self.hatch.xScale = 0.32
				self.hatch.yScale = 0.32
				--self.hatch:play()
			end
		end
		self.eventRunning = false
		self.isPaused = false
		self.eventRectangle:toBack( )
		self.eventInstance:toBack()
		self.tPrevious = system.getTimer( ) --Reset the timer
	end
end
function Ribbon:hatchEgg(event)
	self.hatch:removeSelf( )
	self.hatch = nil
	self.egg:removeSelf( )
	self.egg = nil

	-- New Pokemon
	local i = egg2poke[self.eggID]
	pokeScore[i] = pokeScore[i] + 1
	self.sheetBorn = graphics.newImageSheet( "allcombo/" .. tostring(i) .. "combo.png" , {width= 32, height=32,numFrames=8} )
	self.instanceBorn = display.newSprite(self.sheetBorn, {name="pokeB", start=1, count = 2, time=250})
	self.instanceBorn.x = (_W/2) - (self.instance1.width*self.instance1.xScale)
	self.instanceBorn.y = self.instance1.y
	self.instanceBorn.xScale = 1.25
	self.instanceBorn.yScale = 1.25 --Half tile scale since this is 32x32 and tile is 16x16
	self.instanceBorn:play()

end
--END OF RIBBON DEFINE

r1 = Ribbon:new{ypos =1}
r1:setup()
r2 = Ribbon:new{ypos = 2}
r2:setup()
r3 = Ribbon:new{ypos = 0}
r3:setup()

--updateScore()

debugCounter = 0
newScore()

--ADD BUTTON STUFF
--Function to handle button
downTimer = 0 --timer to prevent rapid button press 
local function handleDownButtonEvent(event)
	--Return and do nothing if enough time hasn't passed
	if (event.time - downTimer) < 100 then
		return 
	end

	bCursor = bCursor + 1
	if(bCursor>(berrycount-iconLimit+2))then bCursor = berrycount-iconLimit+2 end --bounds checking
	pCursor = pCursor + 1
	if(pCursor>(400-iconLimit-1))then pCursor = 400-iconLimit+2 end --bounds Checking
	newScore()
	downTimer = event.time --reset the timer 
end
upTimer = 0 --timer to prevent rapid button press
local function handleUpButtonEvent(event)
	--Return and do nothing if enought time hasn't passed
	if (event.time - upTimer) < 100 then
		return
	end

	bCursor = bCursor - 1
	if(bCursor<1)then bCursor = 1 end --bounds checking
	pCursor = pCursor - 1
	if(pCursor<1)then pCursor = 1 end --bounds Checking
	newScore()
	upTimer = event.time --reset the timer
end
--NETWORK BUTTON STUFF
netName = "Silver" --the user's network name DEFAULT
netTeam = "Rocket" -- the user's network team name DEFAULT
netBerries = 0 --the amount of berries to send over the network
--Listeners for text boxes
local function nameTextListener(event)
	if(event.phase=="began")then
		print(event.text)
	elseif(event.phase=="ended" or event.phase=="submitted")then
		print("Submitted Text: " .. event.target.text)
		netName = event.target.text
	elseif(event.phase=="editing")then
		print(event.newCharacters)
		print(event.oldText)
		print(event.startPosition)
		print(event.text)
	end
end
local function teamTextListener(event)
	if(event.phase=="began")then
		print(event.text)
	elseif(event.phase=="ended" or event.phase=="submitted")then
		print("Submitted Text: " .. event.target.text)
		netTeam = event.target.text
	elseif(event.phase=="editing")then
		print(event.newCharacters)
		print(event.oldText)
		print(event.startPosition)
		print(event.text)
	end
end
local function networkListener(event)
--Just a probe to check network connectivity...
	if(event.isError)then
		print("Netw Error")
	else
		print("Response"..event.response)
	end
end
local function sendPokemonHTTP(event)
	--PREPARE TO SEND--
	print("sent")
	local headers = {}
	--NOTE: variables i and sendEmoteID are globals set in "networkButton" function
	local body = "player="..netName.."&team="..netTeam.."&id="..tostring(i).."&emote="..tostring(sendEmoteID).."&lvl=5"
	local params = {} 
	params.headers = headers
	params.body = body
	network.request( "http://elephator.tk:8889/up", "POST", networkListener, params )
	
	pokeScore[i] = pokeScore[i] - 1 
	--after done sending, need to close window
	newScore()

end
--button to press in the network view
local sendButton = widget.newButton{
	width = 20,
	height = 20,
	defaultFile = "ball/1.png",
	overFile = "ball/2.png",
	onEvent = sendPokemonHTTP --used in conjuction with the
							  --following function's globals
}
sendButton.x = _W/4
sendButton.y =  _H - 50
isNetworkViewOn = false
local function networkButton(event)
	
	--DOn't do anything if network stuff is already on front
	if (isNetworkViewOn==true) then 
		return
	else
		isNetworkViewOn = true
	end

	myRectangle:toFront()

	--Get NAME from text field
	--Label to indicate name
	if(nameLabel~=nil)then nameLabel:removeSelf( ); nameLabel = nil end
	nameLabel = display.newText( "Name", _W/4,
					_H/6 , "GungsuhChe", 16)
	--Text box to accept user input
	if(nameField~=nil)then nameField:removeSelf(); nameLabel = nil end
	nameField = native.newTextField( _W/4, _H/4, 126, 32)
	nameField:addEventListener( "userInput", nameTextListener ) 
	nameField.placeholder = netName

	--Get TEAM from text field
	--Label to indicate team
	if(teamLabel ~= nil)then teamLabel:removeSelf( ); teamLabel = nil end
	teamLabel = display.newText( "Team", _W/4,
					3*_H/5 , "GungsuhChe", 16)
	--Text box to accept user input
	if(teamField~=nil)then teamField:removeSelf(); teamField = nil end
	teamField = native.newTextField( _W/4, 7*_H/10, 126, 32)
	teamField:addEventListener( "userInput", teamTextListener ) 
	teamField.placeholder = netTeam

	--Choose random pokemon from your score to send
	i = math.random(400)
	if(pokeScore[i]>0)then 
		print("had")
	else
		print("didnt have")
		return --just return if you don't have a pokemon to send
	end

	-- Display Pokemon
	sendSheetP = graphics.newImageSheet( "allcombo/" .. tostring(i) .. "combo.png" , {width= 32, height=32,numFrames=8} )
	if(sendPoke~=nil)then sendPoke:removeSelf( ); sendPoke = nil end
	sendPoke = display.newSprite(sendSheetP, {name="pokeS", start=5, count = 2, time=250})
	sendPoke.x = _W/4
	sendPoke.y = _H/2
	--(No Scale for these pokemon)
	sendPoke:play()
	sendSheetP = nil
	--Emoticon
	sendEmoteId = math.random(3)
	if(sendEmote ~= nil)then sendEmote:removeSelf(); sendEmote = nil end
	sendSheetE = graphics.newImageSheet( "emotion/" .. tostring(sendEmoteId) .. ".png", {width=16, height = 16, numFrames=2})
	sendEmote = display.newSprite(sendSheetE, {name="emote", start = 1, count = 2, time=500})
	sendEmote.x = sendPoke.x
	sendEmote.y = sendPoke.y - 2*(sendEmote.height*sendEmote.yScale)
	sendEmote.xScale = 2
	sendEmote.yScale = 2
	sendEmote:play( )
	sendSheetE = nil
	--Create a separate button to send pokemon
	--Pokeball button under team... TODO
	--Also, berry send

	--PREPARE TO SEND--
	sendButton:toFront( )

end
local function resetButton(event)
	if (r1.isPaused ~= true) then
		r1.instance1:removeSelf( )
		r1.instance1 = nil
		i = math.random(400)
		r1.pokeID = i
		r1.sheet1 = graphics.newImageSheet( "allcombo/" .. tostring(i) .. "combo.png" , {width= 32, height=32,numFrames=8} )
		r1.instance1 = display.newSprite(r1.sheet1, {name="poke", start=3, count = 2, time=250})
		r1.instance1.x = _W/2 --middle of screen!!
		r1.instance1.y = r1.backstamps[1].y 
		r1.instance1.xScale = 1.25
		r1.instance1.yScale = 1.25 --Half tile scale since this is 32x32 and tile is 16x16
		r1.instance1:play()
		r1.sheet1 = nil
	end
	if (r2.isPaused ~= true) then
		r2.instance1:removeSelf( )
		r2.instance1 = nil
		i = math.random(400)
		r2.pokeID = i
		r2.sheet1 = graphics.newImageSheet( "allcombo/" .. tostring(i) .. "combo.png" , {width= 32, height=32,numFrames=8} )
		r2.instance1 = display.newSprite(r2.sheet1, {name="poke", start=3, count = 2, time=250})
		r2.instance1.x = _W/2 --middle of screen!!
		r2.instance1.y = r2.backstamps[1].y 
		r2.instance1.xScale = 1.25
		r2.instance1.yScale = 1.25 --Half tile scale since this is 32x32 and tile is 16x16
		r2.instance1:play()
		r2.sheet1 = nil
	end
	if (r3.isPaused ~= true) then
		r3.instance1:removeSelf( )
		r3.instance1 = nil
		i = math.random(400)
		r3.pokeID = i
		r3.sheet1 = graphics.newImageSheet( "allcombo/" .. tostring(i) .. "combo.png" , {width= 32, height=32,numFrames=8} )
		r3.instance1 = display.newSprite(r3.sheet1, {name="poke", start=3, count = 2, time=250})
		r3.instance1.x = _W/2 --middle of screen!!
		r3.instance1.y = r3.backstamps[1].y 
		r3.instance1.xScale = 1.25
		r3.instance1.yScale = 1.25 --Half tile scale since this is 32x32 and tile is 16x16
		r3.instance1:play()
		r3.sheet1 = nil
	end


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
	onEvent = newScore --updateScore
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
local button5 = widget.newButton{
	width = 20,
	height = 20,
	defaultFile = "ball/1.png",
	overFile = "ball/2.png",
	onEvent = resetButton
}
button5.x = _W/2 + 50 + 50 + 50
button5.y =  _H - 10
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
	if(r1.egg ~= nil) then r1.egg:toFront( ) ; r1.hatch:toFront( ) end
	if(r2.egg ~= nil) then r2.egg:toFront( ) ; r2.hatch:toFront( ) end
	if(r3.egg ~= nil) then r3.egg:toFront( ) ; r3.hatch:toFront( ) end

	if(r1.instanceBorn~=nil)then r1.instanceBorn:toFront( ) end
	if(r2.instanceBorn~=nil)then r2.instanceBorn:toFront( ) end
	if(r3.instanceBorn~=nil)then r3.instanceBorn:toFront( ) end

	--Display Memory Usage (Debug)
	-- myRectangle:toFront( )
	-- label:toFront( )
	-- label.text="Lua Memory: "  .. "  Texture Memory: " .. system.getInfo("textureMemoryUsed")/1000

end

Runtime:addEventListener( "enterFrame", move);


