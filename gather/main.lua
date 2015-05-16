-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------
local widget = require("widget")

local baseline = 280 --NOT USED CURRENTLY
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

--WILD POKEMON STUFF
pokeScore = {}
for i=1, 400 do pokeScore[i] = 0 end --initialize score

--TODO: Load name list, pNameList.txt
local namePath = system.pathForFile( "lists/pNameList.txt", system.ResourceDirectory )
local nameFile = io.open(namePath, "r")
io.input(nameFile)
poke2name = {} --dictionary containing type info
for i = 1, 1470 do 
	for k,v in string.gmatch(io.read(), "#(%d+):(.*)") do
		poke2name[tonumber(k)] = v
	end
end
io.close(nameFile)


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
local egg2poke = {} --dictionary containing hatch info: eggID:poke!D
for i = 1, 209 do
	for k,v in string.gmatch( io.read(), "(%d+):(%d*)" ) do
		egg2poke[i] = tonumber(k)
	end
end
io.close(eggFile)

--TYPE STUFF
--load poke type list: pTypesEncoded.txt
local typePath = system.pathForFile( "lists/pTypesEncoded.txt", system.ResourceDirectory )
local typeFile = io.open(typePath, "r")
io.input(typeFile)
local poke2type = {} --dictionary containing type info: pokeID:table of typeID (see pTypeCodes.txt for mapping)
for i = 1,2517 do 
	for k,v,l in string.gmatch( io.read(), "#(%d+):(%d*),(%d*)") do
		poke2type[tonumber(k)] = {tonumber(v), tonumber(l)}
	end
end
io.close(typeFile)

--load poke type behavior: pTypeBehavior.txt
local typePath = system.pathForFile( "lists/pTypeBehavior.txt", system.ResourceDirectory)
local typeFile = io.open(typePath, "r")
io.input(typeFile)
local type2effect = {} --dictionary containing type behavior: typeID:table of tyepID's that it's super effective vs
for i = 1,18 do
	j = 1 --index for the subdictiona
	type2effect[i] = {} --subtables for list for each type
	for k in string.gmatch(io.read(), "%d+") do
		type2effect[i][j] = tonumber(k)
		j = j+1
	end
end
io.close(typeFile)
--function to determine who wins between two types (POSSIBLY INEFFICIENT!!! --just barely, though)
function isEffective(primType, secoType)
	local x = primType
	local y = secoType
	maxLength = 5--The length of the longest subtable in type2effective (most types effective against)
	for i = 1, maxLength do
		if(y==type2effect[x][i]) then return(true) end
	end
	return(false)
end

--FOOD STUFF
--TODO load poke food list: pFoodCode.txt
local foodPath = system.pathForFile("lists/pFoodCode.txt", system.ResourceDirectory)
local foodFile = io.open(foodPath, "r")
io.input(foodFile)
local type2food = {} --dictionary for food strings, sorted by type: typeID:table of food strings
for i = 1,90 do
	holder = io.read( )
	if (i%5==1) then --first of five numbers corresponds to type code
		k = tonumber(holder)
		type2food[k] = {}
		j = 1 --used for a counter for the sub tables
	else -- the remaining 4 of 5 lines are for the food strings, themselves
		type2food[k][j] = holder
		j = j+1
	end
end
print(type2food[3][2])
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
firstP = 0--index of first nonzero pokemon score
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

		--If it's the first nonzero score, register it
		if (firstP == 0)and(tonumber(quant)~=0) then
			firstP = i
		end

	end
	io.close(f)
end
f = nil

--if firstP still isn't set ( == 0), then set it
if (firstP == 0) then firstP = 1 end

--START WAY TO SAVE DATA
--SAVE COUNT GLOBALS
saveCount = 0 --keeps ttrack of how many times we we've saved
function saveDataArray(typeCode, berryArray, pokeArray)
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
pCursor = firstP -- points to the current element in poke score array
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
	--AKA be awarre of other BUTTONS
	if isNetworkViewOn == true then isNetworkViewOn = false end
	if (isSendButtonOn~=nil) then isSendButtonOn = false end
	if (sendButton ~=nil) then sendButton:toBack( ) end
	if isCookViewOn == true then isCookViewOn = false end
	if (isCookButtonOn ~=nil) then isCookButtonOn = false end

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
				icons[d].x = 0 + icons[d].width*icons[d].xScale 
				icons[d].y = ( 2*d - 1 ) * (icons[d].yScale*icons[d].height) + iconOffset
				--For text
				if(texts[d] ~= nil) then texts[d]:removeSelf( ) end
				texts[d] = display.newText( berryScore[checkScore], icons[d].x,
											 icons[d].y -(icons[d].xScale*icons[d].width) , "GungsuhChe", 16)
				texts[d]:setFillColor( 1,0,0.9  )
				--texts[d]:setFillColor( 0.2,0.2,0.6  )

				--For tree
				if(treeSheet~=nil)then treeSheet=nil end
				treeSheet = graphics.newImageSheet("treespace/"..name.."comboS.png",
					{width = 32, height = 32, numFrames=5})
				if(trees[d] ~= nil) then trees[d]:removeSelf( ) end
				trees[d] = display.newSprite(treeSheet, 
					{name=tostring(d), start=1, count=5, time=math.random(7000,20000)})
				trees[d].x = icons[d].x + (icons[d].xScale*icons[d].width)
				trees[d].y = icons[d].y - (trees[d].width/2)
				trees[d].id = checkScore --berryid number of the tree

				trees[d]:play()

				trees[d]:addEventListener( "sprite", spriteListener )

				--for custome fence sheet
				if(fenceSheet~=nil) then fenceSheet = nil end
				fenceSheet = graphics.newImageSheet("backs/fenceplot.png",
					{width = 16, height = 16, numFrames=9})
				
				--for grass		
				if(grass[d]~=nil) then grass[d]:removeSelf() end
				grass[d] = display.newImageRect(fenceSheet, 4,16,16)
				grass[d].x = icons[d].x
				grass[d].y = icons[d].y
				grass[d].xScale = 2
				grass[d].yScale = 2
				if(grass2[d]~=nil) then grass2[d]:removeSelf() end
				grass2[d] = display.newImageRect(fenceSheet, 1,16,16)
				grass2[d].x = icons[d].x
				grass2[d].y = icons[d].y - (icons[d].xScale*icons[d].width)
				grass2[d].xScale = 2
				grass2[d].yScale = 2

				--for huts
				if(huts[d]~=nil)then huts[d]:removeSelf( ) end
				huts[d] = display.newImageRect(fenceSheet, 5,16,16)
				huts[d].x = icons[d].x + (icons[d].xScale*icons[d].width)
				huts[d].y = icons[d].y
				huts[d].xScale = 2
				huts[d].yScale = 2
				if(hutRoofs[d]~=nil)then hutRoofs[d]:removeSelf( ) end
				hutRoofs[d] = display.newImageRect(fenceSheet, 2,16,16)
				hutRoofs[d].x = icons[d].x + (icons[d].xScale*icons[d].width)
				hutRoofs[d].y = icons[d].y - (icons[d].xScale*icons[d].width)
				hutRoofs[d].xScale = 2
				hutRoofs[d].yScale = 2
				if(huts2[d]~=nil)then huts2[d]:removeSelf( ) end
				huts2[d] = display.newImageRect(fenceSheet, 6,16,16) --maybe tile 310
				huts2[d].x = icons[d].x + 2*(icons[d].xScale*icons[d].width)
				huts2[d].y = icons[d].y
				huts2[d].xScale = 2
				huts2[d].yScale = 2
				if(hutRoofs2[d]~=nil)then hutRoofs2[d]:removeSelf( ) end
				hutRoofs2[d] = display.newImageRect(fenceSheet, 3,16,16)
				hutRoofs2[d].x = icons[d].x + 2*(icons[d].xScale*icons[d].width)
				hutRoofs2[d].y = icons[d].y - (icons[d].xScale*icons[d].width)
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
			if(pokeScore[checkScore]~=0)then
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
				textsP[d]:setFillColor( 0.9,00.4,0.08 )
				--textsP[d]:setFillColor( 1,0.6,0.25 )

				--for custom wood fence sheet
				if(woodSheet ~= nil) then woodSheet = nil end
				woodSheet = graphics.newImageSheet("backs/fencewood.png",
					{width = 16, height = 16, numFrames=20})

				--For corrall/fields that go with pokemon
				--if(fields[i] ~= nil) then textsP[i]:removeSelf( ) end
				fields[d] = display.newImageRect(woodSheet, 14, 16,16)
				fields[d].x = iconsP[d].x
				fields[d].y = iconsP[d].y
				fields[d].xScale = 2
				fields[d].yScale = 2
				fields2[d] = display.newImageRect(woodSheet, 14, 16,16)
				fields2[d].x = iconsP[d].x + (fields[d].yScale*fields[d].height)
				fields2[d].y = iconsP[d].y
				fields2[d].xScale = 2
				fields2[d].yScale = 2

				--For fences that go with pokemon
				fences[d] = display.newImageRect(woodSheet, 12 , 16,16)
				fences[d].x = fields[d].x
				fences[d].y = fields[d].y - (fields[d].yScale*fields[d].height)
				fences[d].xScale = 2
				fences[d].yScale = 2
				fences2[d] = display.newImageRect(woodSheet, 12 , 16,16)
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

--misc
local typeSheet = graphics.newImageSheet("misc/typeicons.png", {width = 50, height=17, numFrames=18})

--DEFINE The Ribbon Object
local Ribbon = { 
	tiles_per_row = 10,
	ypos = 0,
	berryID = 0, --berryID corresponds to the ribbon's berry type
	pokeID = 0, --the ribbon's pokemon's ID
	typeID = 0, --integer corresponding to type code of ribbon's poke
	wildID = 0, --wildID corresponds to the wild pokemon's ID
	wTypeID = 0, --type code of wild
	emoteID = 0, --the wild pokemon's emotion ID
	eggID = 0, --the ID of the pokemon egg (if there is one)
	pokeLevel = 1, --the pokemon's level
	wildLevel = math.random(1,4), --the wild pokemon's level
	--HACKS AND SHIT
	notBerry = true, --used to tell if we are moving berry or not
	isPaused = false, --if the ribbon is paused or not
	isNPCnotP = true, --if an NPC is being moved (as opposed to a poke being moved)
	hasMail = false, --if the Ribbon has some mail to deliver
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

	--PokeTYPE
	if (math.random() > 0.5) then
		self.typeID = poke2type[self.pokeID][1]
	else
		if (poke2type[self.pokeID][2]~=nil)then self.typeID = poke2type[self.pokeID][2]
		else self.typeID = poke2type[self.pokeID][1] end
	end
	self.type = display.newImageRect(typeSheet, self.typeID,50,17)
	self.type.x = self.instance1.x + 4
	self.type.y = self.instance1.y - (self.instance1.height*self.instance1.yScale)

	-- Berry
	i = math.random(berrycount)
	name = berries[i]
	self.berryID = i
	self.berry = display.newImage("berry/" ..name.. ".png")
	self.berry.x = _W + 60
	self.berry.y = self.backstamps[1].y
	self.berry.xScale = 0.625/1.5
	self.berry.yScale = 0.625/1.5

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

		--PokeTYPE
		if (self.wType~=nil)then self.wType:removeSelf( ); self.wType = nil end
		if (math.random() > 0.5) then
			self.wType = poke2type[self.wildID][1]
		else
			if (poke2type[self.wildID][2]~=nil)then self.wType = poke2type[self.wildID][2]
			else self.wType = poke2type[self.wildID][1] end
		end
		self.wType = display.newImageRect(typeSheet, self.wType,50,17)
		self.wType.x = _W - ((r2.instance1.height*r2.instance1.yScale) - 16)
		self.wType.y = self.instance1.y - (r2.instance1.height*r2.instance1.yScale)

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
			-- self.eventRectangle.x =self.instance1.x + ((self.instance1.width*self.instance1.xScale)/2)
			-- self.eventRectangle:toFront( )
			-- self.eventRectangle:setFillColor( 1,0.2,0.8 )
			if (self.eventInstance ~= nil) then self.eventInstance:removeSelf( ); self.eventInstance = nil end
			self.eventSheet = graphics.newImageSheet( "events/heartRip.png", {width=32, height = 32, numFrames=5})
			self.eventInstance = display.newSprite(self.eventSheet, {name="event", start = 1, count = 5, time=500})
			self.eventInstance.x = self.eventRectangle.x
			self.eventInstance.y = self.eventRectangle.y
			self.eventInstance.yScale = 1.25
			self.eventInstance.xScale = 1.25			
			self.eventInstance:play( )
			self.eventTimer = system.getTimer( )
			self.eventSheet = nil
			return
		end
		if (self.emoteID == 2) then
			--if emote is fighting exclamation
			self.isPaused = true
			self.eventRunning = true

			if (self.eventInstance ~= nil) then self.eventInstance:removeSelf( ); self.eventInstance = nil end
			self.eventSheet = graphics.newImageSheet( "events/normal2.png", {width=32, height = 32, numFrames=5})
			self.eventInstance = display.newSprite(self.eventSheet, {name="event", start = 1, count = 5, time=500})
			self.eventInstance.x = self.eventRectangle.x
			self.eventInstance.y = self.eventRectangle.y
			self.eventInstance.yScale = 1.25
			self.eventInstance.xScale = 1.25			
			self.eventInstance:play( )
			self.eventTimer = system.getTimer( )
			self.eventSheet = nil

			-- for word in type2effect[wTypeID] do
			-- 	print(word)
			-- end

			return
		end
		if (self.emoteID == 3) then
			--If emoteID is 3 (currently: singing), change wild emote and give instance 1 an emote (the event sheet)
			self.isPaused = true
			self.eventRunning = true

			if(self.eventInstance ~= nil) then self.eventInstance:removeSelf( ); self.eventInstance = nil end
			--Give instance 1 an emote
			self.eventSheet = graphics.newImageSheet( "emotion/4.png", {width = 16, height = 16, numFrames = 2} )
			self.eventInstance = display.newSprite( self.eventSheet, {name="event", start=1, count=2, time=500})
			self.eventInstance.x = self.instance1.x
			self.eventInstance.y = self.instance1.y - (self.instance1.yScale*self.instance1.height)/1.5
			--The scale will be just a tad smaller than the ratio ;P
			self.eventInstance.xScale = 2
			self.eventInstance.yScale = 2
			self.eventInstance:play()

			--Change the event of instance 2
			if self.instanceE ~= nil then self.instanceE:removeSelf(); self.instanceE = nil end
			self.sheetE = nil
			self.sheetE = graphics.newImageSheet( "emotion/5.png", {width=16, height = 16, numFrames=2})
			self.instanceE = display.newSprite(self.sheetE, {name="emote", start = 1, count = 2, time=500})
			self.instanceE.x = self.instance2.x
			self.instanceE.y = self.instance2.y - (self.instance2.yScale*self.instance2.height)/1.5
			--The scale we be just a tad smaller than the ratio ;p
			self.instanceE.xScale = 2 
			self.instanceE.yScale = 2
			self.instanceE:play( )
			self.sheetE = nil

			--House keeping
			self.eventTimer = system.getTimer( )
			self.eventSheet = nil
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
	print("this happens... probably doesn't")
	--add to score GLOBAL VARIABLE
	--pokeScore[self.wildID] = pokeScore[self.wildID] + 1
	--saveDataArray(2, berryScore, pokeScore)
end
function Ribbon:checkDone(event)
	--Concerning Pokemon Events? (or both?)
	--If the time is a certain amount after when the even started
	if((event.time - self.eventTimer)>math.random(5000,10000))then 
		--Remove All traces of pokemon and enter score
		self.instance2:removeSelf( )
		self.instance2 = nil
		self.sheet2 = nil
		self.instanceE:removeSelf( )
		self.instanceE= nil
		self.sheetE = nil
		if(self.emoteID == 1)then --If heart event
			--make room for new egg
			if(self.instanceBorn~=nil)then self.instanceBorn:removeSelf();self.instanceBorn = nil end
			--make the egg if need be
			if(self.egg==nil)then
				if(math.random()>0.5)then self.eggID = eggDex[self.wildID]
				else self.eggID = eggDex[self.pokeID] end

				-- self.egg = widget.newButton{
				-- 	width = 32,
				-- 	height = 32,
				-- 	defaultFile = "eggs/"..tostring(self.eggID)..".png",
				-- 	overFile = "eggs/"..tostring(self.eggID)..".png",
				-- 	onEvent = self:clickEgg()
				-- }
				-- self.egg.x = (_W/2) - (self.instance1.width*self.instance1.xScale)
				-- self.egg.y = self.instance1.y
				-- self.egg.xScale = 0.625
				-- self.egg.yScale = 0.625

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
		if (self.emoteID == 3) then --if singing/friend event
			--Add the pokemon to score
			pokeScore[self.wildID] = pokeScore[self.wildID] + 1
			saveDataArray(2, berryScore, pokeScore)
		end

		--remove type
		if(self.wType~=nil)then self.wType:removeSelf( );self.wType=nil end

		--decide whether to prompt an NPC or a wild poke
		if (math.random()>0.7) then self.isNPCnotP = true else self.isNPCnotP = false end

		--decide whether to propmt a berry run
		if math.random()>0.5 then self.notBerry = false end

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
	print("bug value " .. tostring(self.eggID))
	pokeScore[i] = pokeScore[i] + 1
	self.sheetBorn = graphics.newImageSheet( "allcombo/" .. tostring(i) .. "combo.png" , {width= 32, height=32,numFrames=8} )
	self.instanceBorn = display.newSprite(self.sheetBorn, {name="pokeB", start=1, count = 2, time=250})
	self.instanceBorn.x = (_W/2) - (self.instance1.width*self.instance1.xScale)
	self.instanceBorn.y = self.instance1.y
	self.instanceBorn.xScale = 1.25
	self.instanceBorn.yScale = 1.25 --Half tile scale since this is 32x32 and tile is 16x16
	self.instanceBorn:play()

end
function Ribbon:moveAndMakeNPC(event)
	if (self.npc == nil) then
		--NPC
		i = math.random( 90 )
		self.npc = display.newImage( "trainers/"..i..".png" )
		self.npc.x = _W + 60
		self.npc.y = self.backstamps[1].y
		self.npc.xScale = 1.25
		self.npc.yScale = 1.25
		--NPC speech emote
		self.sheetNE = nil
		self.sheetNE = graphics.newImageSheet( "emotion/12.png", {width=16,height=16, numFrames=2} )
		if(self.instanceNE ~= nil)then self.instanceNE:removeSelf( ); self.instanceNE = nil end
		self.instanceNE = display.newSprite(self.sheetNE, {name="emote", start = 1, count = 2, time=500})
		self.instanceNE.x = self.npc.x
		self.instanceNE.y = self.npc.y - (self.npc.yScale*self.npc.height)
		--The scale will be just a tad smaller than the raio ::P
		self.instanceNE.xScale =2
		self.instanceNE.yScale =2
		self.instanceNE:play()
		self.sheetNE = nil
	end

	--Actually Move
	self.tDelta = event.time - self.tPrevious
	self.tPrevious = event.time
	self.xOffset = ( 0.02 * self.tDelta)
	self.npc.x = self.npc.x - self.xOffset
	self.instanceNE.x = self.npc.x

	if self.npc.x < self.instance1.x + 40 then --if wild poke reach pokemon
		encounterNPC(self, event)
	end

	self.tPrevious = system.getTimer( )
end
function encounterNPC(self, event)

	--start an event running if it needs to...
	if(self.eventRunning == false ) then 
		self.isPaused = true
		self.eventRunning = true
		if (self.eventInstance ~= nil) then self.eventInstance:removeSelf( ); self.eventInstance = nil end

		if(self.hasMail == false) then -- if doesnt have mail, give it some
			--Give instance 1 a question emote
			self.eventSheet = graphics.newImageSheet( "emotion/13.png", {width = 16, height = 16, numFrames = 2} )
			self.eventInstance = display.newSprite( self.eventSheet, {name="event", start=1, count=2, time=500})
			self.eventInstance.x = self.instance1.x
			self.eventInstance.y = self.instance1.y - (self.instance1.yScale*self.instance1.height)/1.5
			--The scale will be just a tad smaller than the ratio ;P
			self.eventInstance.xScale = 2
			self.eventInstance.yScale = 2
			self.eventInstance:play()

			--Change the event emotion of npc, to "concerned"
			if self.instanceNE ~= nil then self.instanceNE:removeSelf(); self.instanceNE = nil end
			self.sheetNE = nil
			self.sheetNE = graphics.newImageSheet( "emotion/6.png", {width=16, height = 16, numFrames=2})
			self.instanceNE = display.newSprite(self.sheetNE, {name="emote", start = 1, count = 2, time=500})
			self.instanceNE.x = self.npc.x
			self.instanceNE.y = self.npc.y - (self.npc.yScale*self.npc.height)
			--The scale we be just a tad smaller than the ratio ;p
			self.instanceNE.xScale = 2 
			self.instanceNE.yScale = 2
			self.instanceNE:play( )
			self.sheetNE = nil
		end

		if(self.hasMail == true )then --if have mail, deliver it! :)
			--Give instance 1 a talking emote
			self.eventSheet = graphics.newImageSheet( "emotion/12.png", {width = 16, height = 16, numFrames = 2} )
			self.eventInstance = display.newSprite( self.eventSheet, {name="event", start=1, count=2, time=500})
			self.eventInstance.x = self.instance1.x
			self.eventInstance.y = self.instance1.y - (self.instance1.yScale*self.instance1.height)/1.5
			--The scale will be just a tad smaller than the ratio ;P
			self.eventInstance.xScale = 2
			self.eventInstance.yScale = 2
			self.eventInstance:play()

			--Change the event emotion of npc, to "happy"
			if self.instanceNE ~= nil then self.instanceNE:removeSelf(); self.instanceNE = nil end
			self.sheetNE = nil
			self.sheetNE = graphics.newImageSheet( "emotion/4.png", {width=16, height = 16, numFrames=2})
			self.instanceNE = display.newSprite(self.sheetNE, {name="emote", start = 1, count = 2, time=500})
			self.instanceNE.x = self.npc.x
			self.instanceNE.y = self.npc.y - (self.npc.yScale*self.npc.height)
			--The scale we be just a tad smaller than the ratio ;p
			self.instanceNE.xScale = 2 
			self.instanceNE.yScale = 2
			self.instanceNE:play( )
			self.sheetNE = nil
		end

		--House keeping
		self.eventTimer = system.getTimer( )
		self.eventSheet = nil
		return
	end
end
function Ribbon:checkDoneNPC(event)
	--Conecerning NPC events
	-- if the time is a certain amount after when the event started
	if((event.time - self.eventTimer)>math.random(5000,10000))then
		
		if(self.hasMail == false) then --if not have mail, give it some
			--make room for mail
			if(self.badgeInstance~=nil)then self.badgeInstance:removeSelf( );self.badgeInstance = nil end
			--make the mail if need be
			if(self.mail==nil)then 
				local i = math.random( 0,23 )
				self.mail = display.newImage( "close/".. tostring( i )..".png")
				self.mail.x = (_W/2) - (self.instance1.width*self.instance1.xScale)
				self.mail.y = self.backstamps2[1].y
				self.mail.xScale = 0.625
				self.mail.yScale = 0.625
			end

			self.hasMail = true
		elseif(self.hasMail == true) then --if have mail, remove all traces of mail
			self.hasMail = false
			self.mail:removeSelf( )
			self.mail = nil
		end
		--Remove ALL traces of NPC=
		self.npc:removeSelf( )
		self.npc = nil
		self.instanceNE:removeSelf( )
		self.instanceNE= nil
		self.sheetNE = nil

		--decide whether to prompt an NPC or a wild poke
		if (math.random()>0.75) then self.isNPCnotP = true else self.isNPCnotP = false end

		--decide whether to prompt a berry or not
		if (math.random()>0.5) then self.notBerry = false end --flag to start berry run

		self.eventRunning = false
		self.isPaused = false
		self.eventRectangle:toBack( )
		self.eventInstance:toBack()
		self.tPrevious = system.getTimer( ) --Reset the timer
	end
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
		local holder = event.target.text
		netName = holder
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
		local holder = event.target.text
		netTeam = holder
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
isSendButtonOn = false
sendEmoteId = 1
local function sendPokemonHTTP(event)

	--Do nothing if button is not enabled
	if isSendButtonOn == false then return end

	--PREPARE TO SEND--
	print("sent")
	local headers = {}
	--NOTE: variables i and sendEmoteID are globals set in "networkButton" function
	if sendEmote ~= nil then 
		local body = "player="..netName.."&team="..netTeam.."&id="..tostring(i).."&emote="..tostring(sendEmoteId).."&lvl=5"
		local params = {} 
		params.headers = headers
		params.body = body
		network.request( "http://elephator.tk:8889/up", "POST", networkListener, params )
		
		pokeScore[i] = pokeScore[i] - 1 
		--after done sending, need to close window
		newScore()
		isSendButtonOn = false --turn off
	end

end
--button to press in the network view
local sendButton = widget.newButton{
	width = 40,
	height = 40,
	defaultFile = "ball/Ac.png",
	overFile = "ball/Ao.png",
	onEvent = sendPokemonHTTP --used in conjuction with the
							  --following function's globals
}
sendButton.x = _W/4
sendButton.y =  _H - 50
sendButton:toBack( )
isNetworkViewOn = false
local function networkButton(event)
	--AKA be aware of other BUTTONS
	if isCookViewOn == true then isCookViewOn = false end
	if (isCookButtonOn ~=nil)then isCookButtonOn = false end
	
	--DOn't do anything if network stuff is already on front
	if (isNetworkViewOn==true) then 
		return
	else
		isNetworkViewOn = true
	end

	myRectangle:toFront()

	-- --Get NAME from text field
	-- --Label to indicate name
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
	isSendButtonOn = true

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
		--PokeTYPE
		if(r1.type~=nil)then r1.type:removeSelf( ); r1.type = nil end
		if (math.random() > 0.5) then
			r1.typeID = poke2type[r1.pokeID][1]
		else
			if (poke2type[r1.pokeID][2]~=nil)then r1.typeID = poke2type[r1.pokeID][2]
			else r1.typeID = poke2type[r1.pokeID][1] end
		end
		r1.type = display.newImageRect(typeSheet, r1.typeID,50,17)
		r1.type.x = r1.instance1.x + 4
		r1.type.y = r1.instance1.y - (r1.instance1.height*r1.instance1.yScale)
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
		--PokeTYPE
		if (r2.type~=nil)then r2.type:removeSelf( ); r2.type = nil end
		if (math.random() > 0.5) then
			r2.typeID = poke2type[r2.pokeID][1]
		else
			if (poke2type[r2.pokeID][2]~=nil)then r2.typeID = poke2type[r2.pokeID][2]
			else r2.typeID = poke2type[r2.pokeID][1] end
		end
		r2.type = display.newImageRect(typeSheet, r2.typeID,50,17)
		r2.type.x = r2.instance1.x + 4
		r2.type.y = r2.instance1.y - (r2.instance1.height*r2.instance1.yScale)
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
		--PokeTYPE
		if(r3.type~=nil)then r3.type:removeSelf( ); r3.type = nil end
		if (math.random() > 0.5) then
			r3.typeID = poke2type[r3.pokeID][1]
		else
			if (poke2type[r3.pokeID][2]~=nil)then r3.typeID = poke2type[r3.pokeID][2]
			else r3.typeID = poke2type[r3.pokeID][1] end
		end
		r3.type = display.newImageRect(typeSheet, r3.typeID,50,17)
		r3.type.x = r3.instance1.x + 4
		r3.type.y = r3.instance1.y - (r3.instance1.height*r3.instance1.yScale)
	end

end
--COOK BUTTON STUFF
isCookViewOn = false
--Label to indicate cook
cookLabel = display.newText( "Cook", _W/4,
				_H/6 , "GungsuhChe", 16)
cookLabel:toBack( )
kitchenLabel = display.newText( "Kitchen", _W/4,
				3*_H/5 , "GungsuhChe", 16)
kitchenLabel:toBack( )
cookSheetB = graphics.newImageSheet( "ball/D.png" , {width= 32, height=32,numFrames=3} )
cookBall = display.newSprite(cookSheetB, {name="cookBall", start=1, count = 3, time=250})
cookBall.x = _W/4
cookBall.y =  _H - 50
cookBall:play( )
cookBall:toBack( )
cookSheet = nil
cookID = 0 --The ID corresponding to the poke we're going to cook
cookTypeID = 0 --The type of the pokemon we're cooking
cookEmoteID = 0 --The id of the emote of the cooked pokemon
--Sub Cook Pokeball Button
isCookButtonOn = false --DIFFERENT THAN ISCOOKVIEWON
madeLabel = display.newText( "Done Cooking", _W/4,
				_H/6 , "GungsuhChe", 16)
madeLabel:toBack( )
dishName = "" --String containing dish food name
dishPoke = "" --String containing dish poke name
local function cookPokemonDish(event)

	--Do nothing if button is not enabled
	if isCookButtonOn == false then return end
	isCookButtonOn = false
	isCookViewOn = false

	myRectangle:toFront()
	madeLabel:toFront( )

	--Color Pokemon Name?
	dishName = poke2name[cookID]
	if nameLabel~=nil then nameLabel:removeSelf( ); nameLabel=nil end
	nameLabel = display.newText(dishName, _W/4,
				_H/4, "GungsuhChe", 16) --Height used to be _H/3
	if (cookTypeID == 1 ) then
		nameLabel:setFillColor( 0.7,0.7,0.7 )
	elseif (cookTypeID == 2) then
		nameLabel:setFillColor( 1,0.6,0.2 )
	elseif (cookTypeID == 3) then
		nameLabel:setFillColor( 1,0.5,0.5 )
	elseif (cookTypeID == 4) then
		nameLabel:setFillColor( 0.4,0.6,1 )
	elseif (cookTypeID == 5) then	
		nameLabel:setFillColor( 0.2,0.8,1 )
	elseif (cookTypeID == 6) then	
		nameLabel:setFillColor( 0.6,0.9,0.5 )
	elseif (cookTypeID == 7) then	
		nameLabel:setFillColor( 0.9,0.6,1 )
	elseif (cookTypeID == 8) then	
		nameLabel:setFillColor( 1,0.9,0 )
	elseif (cookTypeID == 9) then	
		nameLabel:setFillColor( 0.9,0.8,0.6 )
	elseif (cookTypeID == 10) then	
		nameLabel:setFillColor( 1,0.2,0.7 )
	elseif (cookTypeID == 11) then	
		nameLabel:setFillColor( 0.3,0.2,0.2 )
	elseif (cookTypeID == 12) then	
		nameLabel:setFillColor( 0.5,0.6,0.9 )
	elseif (cookTypeID == 13) then	
		nameLabel:setFillColor( 0.6,0.8,0.5 )
	elseif (cookTypeID == 14) then	
		nameLabel:setFillColor( 0.3,0.4,0.6 )
	elseif (cookTypeID == 15) then	
		nameLabel:setFillColor( 0.7,0.4,1 )
	elseif (cookTypeID == 16) then	
		nameLabel:setFillColor( 0.4,0.4,0.4 )
	elseif (cookTypeID == 17) then	
		nameLabel:setFillColor( 0.6,0.6,0.8 )
	elseif (cookTypeID == 18) then	
		nameLabel:setFillColor( 1,0.5,0.8 )
	end

	--White Food Name?
	i = math.random(1,4)
	dishName = 	type2food[cookTypeID][i]
	one, two = dishName:match("([^#]*)#([^#]*)")
	if(one~=nil)then
		if(foodLabel1~=nil)then foodLabel1:removeSelf( ); foodLabel1=nil end
		foodLabel1 = display.newText(one, _W/4,
			_H/4, "GungsuhChe", 16)
	end
	if(two~=nil)then
		if(foodLabel2~=nil)then foodLabel2:removeSelf( ); foodLabel2=nil end
		foodLabel2 = display.newText(two, _W/4,
			_H/4, "GungsuhChe", 16)
	end
	--Determine total width of all three labels
	local totalWidth = 0
	totalWidth = totalWidth + nameLabel.width
	if(one~=nil)then totalWidth = totalWidth + foodLabel1.width end
	if(two~=nil)then totalWidth = totalWidth + foodLabel2.width end
	--Calculate important points
	local left = _W/4 - (totalWidth/2) --the left boundary
	local right = _W/4 + (totalWidth/2) --the right boundary
	--Put labels in proper places
	if(one~=nil)then foodLabel1.x = left + (foodLabel1.width/2) end
	if(two~=nil)then foodLabel2.x = right - (foodLabel2.width/2) end
	if(one~=nil)then
		nameLabel.x = foodLabel1.x + (foodLabel1.width/2) + (nameLabel.width/2)
	else
		nameLabel.x = foodLabel2.x - (foodLabel2.width/2) - (nameLabel.width/2)
	end
	--Put first label in correct spot



	--Describe how it tastes


	--Center the three different strings



	--Subtract from score

	print("YEAH")

end
--button to press in the network view
local cookButtonButton = widget.newButton{
	width = 40,
	height = 40,
	defaultFile = "misc/takE.png",
	overFile = "misc/takE.png",
	onEvent = cookPokemonDish --Used in conjuction with the previous globals
}
cookButtonButton.x = _W/4
cookButtonButton.y =  _H - 50
cookButtonButton:toBack( )
local function cookButton(event)

	--AKA be aware of other BUTTONS
	if isNetworkViewOn == true then isNetworkViewOn = false end
	if (isSendButtonOn~=nil) then print("turned off"); isSendButtonOn = false end
	if (sendButton ~=nil) then sendButton:toBack( ) end

	--DOn't do anything if network stuff is already on front
	if (isCookViewOn==true) then 
		return
	else
		isCookViewOn = true
	end

	myRectangle:toFront()
	cookLabel:toFront( )
	kitchenLabel:toFront( )
	cookBall:toFront( )
	cookButtonButton:toFront( )
	isCookButtonOn = true

	--Select first pokemon to cook
	print(pCursor)
	for i = pCursor,400 do
		if(pokeScore[i] ~= 0)then cookID = i; break end
	end
	if cookID == 0 then --then it hasn't found poke
		for i = 1, pCursor do
			if(pokeScore[i]~=0)then cookID = i; break end
		end
	end

	--Determine type
	if (math.random() > 0.5) then
		cookTypeID = poke2type[cookID][1]
	else
		if (poke2type[cookID][2]~=nil)then cookTypeID = poke2type[cookID][2]
		else cookTypeID = poke2type[cookID][1] end
	end

	-- Display Pokemon
	 cookSheetP = graphics.newImageSheet( "allcombo/" .. tostring(cookID) .. "combo.png" , {width= 32, height=32,numFrames=8} )
	if(cookPoke~=nil)then cookPoke:removeSelf( ); cookPoke = nil end
	cookPoke = display.newSprite(cookSheetP, {name="pokeC", start=5, count = 2, time=250})
	cookPoke.x = _W/4
	cookPoke.y = _H/2
	--(No Scale for these pokemon)
	cookPoke:play()
	cookSheetP = nil
	--PokeTYPE
	if(cookType~=nil)then cookType:removeSelf( ); cookType = nil end
	cookType = display.newImageRect(typeSheet, cookTypeID,50,17)
	cookType.x = _W/4
	cookType.y = _H/4
	--Emoticon
	cookEmoteId = math.random(3)
	if(cookEmote ~= nil)then cookEmote:removeSelf(); cookEmote = nil end
	cookSheetE = graphics.newImageSheet( "emotion/" .. tostring(cookEmoteId) .. ".png", {width=16, height = 16, numFrames=2})
	cookEmote = display.newSprite(cookSheetE, {name="emoteC", start = 1, count = 2, time=500})
	cookEmote.x = cookPoke.x
	cookEmote.y = cookPoke.y - 2*(cookEmote.height*cookEmote.yScale)
	cookEmote.xScale = 2
	cookEmote.yScale = 2
	cookEmote:play( )
	cookSheetE = nil


	print("YEEHEHEHEH")
	print(cookID)
	print(cookTypeID)

end
local button1 = widget.newButton{
	width = 40,
	height = 40,
	defaultFile = "ball/Bc.png",
	overFile = "ball/Bo.png",
	onEvent = handleDownButtonEvent
}
button1.x = _W/2
button1.y = _H - 20
local button2 = widget.newButton{
	width = 40,
	height = 40,
	defaultFile = "ball/Bc.png",
	overFile = "ball/Bo.png",
	onEvent = handleUpButtonEvent
}
button2.x = _W/2
button2.y = 0 + 20
local button3 = widget.newButton{
	width = 40,
	height = 40,
	defaultFile = "ball/Ac.png",
	overFile = "ball/Ao.png",
	onEvent = newScore --updateScore
}
button3.x = _W/2 + 50
button3.y =  _H - 20
local button4 = widget.newButton{
	width = 40,
	height = 40,
	defaultFile = "ball/Ac.png",
	overFile = "ball/Ao.png",
	onEvent = networkButton
}
button4.x = _W/2 + 50 + 50
button4.y =  _H - 20
local button5 = widget.newButton{
	width = 40,
	height = 40,
	defaultFile = "ball/Ac.png",
	overFile = "ball/Ao.png",
	onEvent = resetButton
}
button5.x = _W/2 + 50 + 50 + 50
button5.y =  _H - 20
local button6 = widget.newButton{
	width = 40,
	height = 40,
	defaultFile = "ball/Cc.png",
	overFile = "ball/Co.png",
	onEvent = cookButton
}
button6.x = _W/2 + 50 + 50 + 50 + 50
button6.y =  _H - 18 --special case
--END BUTTON STUFF

local function move(event)

	if(not r1.isPaused) then
		hi = r1:moveBackground()
		--Both poke and berry
		if(r1.notBerry == false) then  hey = r1:moveBerry(event)
		else 
			if r1.isNPCnotP == true then  ho = r1:moveAndMakeNPC(event) 
			else ho = r1:moveAndMakeWildPokemon(event) end
		end
	end
	if(not r2.isPaused) then
		hi = r2:moveBackground()
		--Both poke and berry
		if(r2.notBerry == false) then  hey = r2:moveBerry(event)
		else 
			if r2.isNPCnotP == true then  ho = r2:moveAndMakeNPC(event) 
			else ho = r2:moveAndMakeWildPokemon(event) end
		end
	end
	if(not r3.isPaused) then
		hi = r3:moveBackground()
		--Both poke and berry
		if(r3.notBerry == false) then  hey = r3:moveBerry(event)
		else 		
			if r3.isNPCnotP == true then  ho = r3:moveAndMakeNPC(event) 
			else ho = r3:moveAndMakeWildPokemon(event) end
		end
	end

	if(r1.eventRunning == true) then 
		if r1.isNPCnotP == true then hi = r1:checkDoneNPC(event)
		else hi = r1:checkDone(event) end
	end
	if(r2.eventRunning == true) then 
		if r2.isNPCnotP == true then hi = r2:checkDoneNPC(event)
		else hi = r2:checkDone(event) end
	end
	if(r3.eventRunning == true) then 
		if r3.isNPCnotP == true then hi = r3:checkDoneNPC(event)
		else hi = r3:checkDone(event) end
	end




	yourRectangle:toFront( )
	button1:toFront( ) --because it gets covered by rectangle
	if(r1.egg ~= nil) then r1.egg:toFront( ) ; r1.hatch:toFront( ) end
	if(r2.egg ~= nil) then r2.egg:toFront( ) ; r2.hatch:toFront( ) end
	if(r3.egg ~= nil) then r3.egg:toFront( ) ; r3.hatch:toFront( ) end

	if(r1.mail ~= nil) then r1.mail:toFront( ) end
	if(r2.mail ~= nil) then r2.mail:toFront( ) end
	if(r3.mail ~= nil) then r3.mail:toFront( ) end

	if(r1.instanceBorn~=nil)then r1.instanceBorn:toFront( ) end
	if(r2.instanceBorn~=nil)then r2.instanceBorn:toFront( ) end
	if(r3.instanceBorn~=nil)then r3.instanceBorn:toFront( ) end

	--CPU BENCHMARK
	-- local x = os.clock()
 --    local s = 0
 --    for i=1,100000 do s = s + i end
 --    print(string.format("elapsed time: %.2f\n", os.clock() - x))

	--Display Memory Usage (Debug)
	-- myRectangle:toFront( )
	-- label:toFront( )
	-- label.text="Lua Memory: "  .. "  Texture Memory: " .. system.getInfo("textureMemoryUsed")/1000

end

Runtime:addEventListener( "enterFrame", move);


