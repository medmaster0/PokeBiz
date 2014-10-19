-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------
local baseline = 280
local i = math.random( 400)
local centerX = display.contentCenterX
local centerY = display.contentCenterY
local _W = 480 --display.contentWidth
local _H = 320 --display.contentHeight

--table containing berry names
local berries = {"Aguav", "Apicot", "Aspear", "Babiri", "Belue", "Bluk", "Charti", "Cheri", "Chesto",
"Chilan", "Chople", "Coba", "Colbur", "Cornn", "Custap", "Durin", "Enigma", "Figy", "Ganlon", "Grepa",
"Haban"
}
--count number of entries
local berrycount = 0
for _ in pairs(berries) do berrycount = berrycount + 1 end
  

-- Your code here

--background
local backsheet1 = graphics.newImageSheet( "bluetileT.png", {width = 16, height=16, numFrames=480} ) --30 columns

--Define The Ribbon Object
local Ribbon = { 
	tiles_per_row = 10,
	--backstamps = {},
	ypos = 0,
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
	end

	-- Pokemon
	i = math.random( 400)
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
	self.berry = display.newImage("berry/"..name.. ".png")
	self.berry.x = (display.contentWidth/ 4) * 3
	self.berry.y = self.backstamps[1].y
	self.berry.xScale = 0.625
	self.berry.yScale = 0.625

	self.tPrevious = system.getTimer( ) --Used for animation/movement
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
			j = math.random( 400)
			--j = 17
			self.backstamps2[i]:setFrame( j )
		end


	end
end

function Ribbon:moveBerry(event)
	self.tDelta = event.time - self.tPrevious
	self.tPrevious = event.time
	self.xOffset = ( 0.02 * self.tDelta)
	self.berry.x = self.berry.x - self.xOffset

	if self.berry.x < 240 then --if berry reach pokemon
		self.berry.x = _W + 50
	end

	self.tPrevious = system.getTimer( )
end

--END OF RIBBON DEFINE

r1 = Ribbon:new{ypos =1}
r1:setup()
r2 = Ribbon:new{ypos = 2}
r2:setup()
r3 = Ribbon:new{ypos = 0}
r3:setup()

print(_W)
print( _H )

--For some reason with these, you have to double the width and height (3rd and 4th params)
local myRectangle = display.newRect(0,0, 480-(r1.backstamps[1].width*r1.backstamps[1].xScale), 640) -- tall as screen
myRectangle:setFillColor( 255, 50,2 )
local yourRectangle = display.newRect( _W+r1.backstamps[1].width*r1.backstamps[1].xScale,0 ,r1.backstamps[1].width*r1.backstamps[1].xScale , 640 ) --tall as screen

-- Berry
local berry = display.newImage("berry/Cheri.png")
berry.x = (display.contentWidth/ 4) * 3
berry.y = 1* ((r1.backstamps[1].height/2)*r1.backstamps[1].yScale) 
berry.xScale = 0.625
berry.yScale = 0.625

local tPrevious = system.getTimer( )
local moveBerry = function(event)

	local tDelta = event.time - tPrevious
	tPrevious = event.time
	local xOffset = ( 0.02 * tDelta)
	berry.x = berry.x - xOffset

	if berry.x < 0 then
		berry.x = _W
	end

	tPrevious = system.getTimer( )

end


local function move(event)

	hey = moveBerry(event)

	hey = r1:moveBerry(event)
	hey = r3:moveBerry(event)
	hey = r2:moveBerry(event)

	hi = r1:moveBackground()
	hi = r2:moveBackground()
	hi = r3:moveBackground()

end



Runtime:addEventListener( "enterFrame", move);


