-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------
local baseline = 280
local i = math.random( 400)
local centerX = display.contentCenterX
local centerY = display.contentCenterY
local _W = display.contentWidth
local _H = display.contentHeight

-- Your code here

--background
local backsheet1 = graphics.newImageSheet( "bluetile.png", {width = 16, height=16, numFrames=480} ) --30 columns
backstamps = {} --new array for back
tiles_per_row = 10
for i=0,tiles_per_row do
	backstamps[i] = display.newImageRect( backsheet1, 17, 16, 16 ) --first param is the tile number on sheet
	backstamps[i].xScale = 2.5
	backstamps[i].yScale = 2.5
	backstamps[i].x=_W - (i*16*backstamps[i].xScale) 
	backstamps[i].y= 3* ((backstamps[i].height/2)*backstamps[i].yScale) 
end

local myRectangle = display.newRect(0,0, 320, 640) -- rectWidth, _H)
myRectangle:setFillColor( 255, 50,200 )

local moveBackground = function()
	for i=0, tiles_per_row do
		backstamps[i].x = backstamps[i].x - 1
		--if backstamp is at the beginning of row on screen (so far away from RH of screen)
		if backstamps[i].x - ((backstamps[i].width/2)*backstamps[i].xScale) < _W - (backstamps[i].xScale * backstamps[i].width *(tiles_per_row))
			--Send it to the end of the screen (beggining of ribbon)
		then backstamps[i].x = _W + (backstamps[i].width * backstamps[i].xScale) - 1 -- Minus 1 to get rid of black vert
		end
	end
end

-- Pokemon
local sheet1 = graphics.newImageSheet( "allcombo/" .. tostring(i) .. "combo.png" , {width= 32, height=32,numFrames=8} )
local instance1 = display.newSprite(sheet1, {name="poke", start=3, count = 2, time=250})
instance1.x = display.contentWidth / 3 + 60
instance1.y = 3* ((backstamps[1].height/2)*backstamps[1].yScale) 
instance1.xScale = 1.25
instance1.yScale = 1.25 --Half tile scale since this is 32x32 and tile is 16x16
instance1:play()


-- Berry
local berry = display.newImage("berry/Cheri.png")
berry.x = (display.contentWidth/ 4) * 3
berry.y = 3* ((backstamps[1].height/2)*backstamps[1].yScale) 
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

	hi = moveBackground()

end



Runtime:addEventListener( "enterFrame", move);


