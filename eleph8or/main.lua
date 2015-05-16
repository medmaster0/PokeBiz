
-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------
local widget = require("widget")
local physics = require("physics")
local creature = require("creature")
require("back")
require("collision")

local baseline = 280
local i = math.random( 400)

scale = 100 --how much to stretch the pixel graphics (and for movement)
local centerX = display.contentCenterX
local centerY = display.contentCenterY
local _W = display.contentWidth --480
local _H = display.contentHeight --320

local myRectangle = display.newRect(centerX,centerY, _W, _H) -- rectWidth, _H)
myRectangle:setFillColor( 0,0,0 )
myRectangle:toFront( )
-- local rightSide = display.newRect(3*_W/4, centerY, _W/2, _H/2) --rectangle to detech righ hand touches
-- local leftSide = display.newRect(_W/4, centerY, _W/2, _H/2) --rectangle to detech righ hand touches


--Use nearest neighbor for scaling
display.setDefault( magTextureFilter, nearest )
display.setDefault( minTextureFilter, nearest )

back = Back.new(_W,_H)
llc = Creature.new(_W,_H)
llc:randomize()

--Game Logic States
moveFunction = nil --used as a pointer to the move function (defined later)
scrollTimer = 0 --used for smooth scrolling in levelling
scrollTotal = (back.numPlats - 2)*_H/back.numPlats --the total amount we scroll
scrollCount = 0 --decrements and resets to scrollTotal during the scroll process

--Scroll down
local function levelUp(event)
	local scrollSpeed = 20 --how fast we scroll
	local tDelta = event.time - scrollTimer
	local scrollOffset = scrollSpeed*tDelta

	--Actual Scrolling
	for i = 1, back.numPlats do
		back.platforms[i].y = back.platforms[i].y + scrollOffset
		if(back.platforms[i].y > _H) then back.platforms[i].y = 0 end
	end
	llc.group.y = llc.group.y + scrollOffset

	--Check if scrolled enough
	scrollCount = scrollCount - scrollOffset
	if(scrollCount < 0) then
		back:resetPlatforms()
		llc.group.y = back.platforms[back.numPlats - 1].y - back.platforms[2].height*back.platforms[2].yScale
		llc:play( )
		Runtime:removeEventListener( "enterFrame", levelUp )
		Runtime:addEventListener( "enterFrame", moveFunction ) --go back to regular movement
		llc.tPrevious = system.getTimer( ) --reset creature move timer
		return
	end

	scrollTimer = event.time --for next round

end

--Scroll up
local function levelDown(event)
	local scrollSpeed = 20 --how fast we scroll
	local tDelta = event.time - scrollTimer
	local scrollOffset = scrollSpeed*tDelta

	--Actual Scrolling
	for i = 1, back.numPlats do
		back.platforms[i].y = back.platforms[i].y - scrollOffset
		if(back.platforms[i].y < 0) then back.platforms[i].y = _H end
	end
	llc.group.y = llc.group.y - scrollOffset

	--Check if scrolled enough
	scrollCount = scrollCount - scrollOffset
	if(scrollCount < 0) then
		back:resetPlatforms()
		llc.group.y = back.platforms[2].y - back.platforms[2].height*back.platforms[2].yScale
		llc:play( )
		Runtime:removeEventListener( "enterFrame", levelDown )
		Runtime:addEventListener( "enterFrame", moveFunction ) --go back to regular movement
		llc.tPrevious = system.getTimer( ) --reset creature move timer
		return
	end

	scrollTimer = event.time --for next round

end

local function move(event)

	llc:move(event)
	back:move()

	--check if llc has landed on platforms
	for i=1, back.numPlats do
		--checkLand returns 1 if from top, 2 if from bottom, 0 otherwise
		check = checkLand(llc, back.platforms[i])
		if(check == 1)then 
			print("got a landing")
			llc.vy = -15.5
			llc.group.y = back.platforms[i].y - back.platforms[i].height*back.platforms[i].yScale
			
			--Check if reach top
			if (llc.group.y < _H/back.numPlats) then 
				--print("rach tap") 
				llc:pause( )
				Runtime:removeEventListener( "enterFrame", move )
				Runtime:addEventListener( "enterFrame", levelUp )
				scrollCount = scrollTotal
				scrollTimer = event.time --get ready to scroll
				back:resetPlatforms()
			end
			
			--Check if reach bottom
			if (llc.group.y > (back.numPlats - 1)*_H/(back.numPlats)) then 
				--print("rach battum") 
				llc:pause( )
				Runtime:removeEventListener( "enterFrame", move )
				Runtime:addEventListener( "enterFrame", levelDown )
				scrollCount = scrollTotal
				scrollTimer = event.time --get ready to scroll
				back:resetPlatforms()				
			end

		elseif(check ==2) then
			print("hit the ceiling")
			llc.vy = 5.5
			llc.group.y = back.platforms[i].y + back.platforms[i].height*back.platforms[i].yScale

		end
	end
end

local function onTouch(event)
	if event.x < centerX then
		if (llc.vx > 0) then
			llc.vx = llc.vx * -1
			llc.group.xScale = llc.group.xScale * -1
		end
	else
		if (llc.vx < 0) then
			llc.vx = llc.vx * -1
			llc.group.xScale = llc.group.xScale * -1
		end

	end
end

moveFunction = move
Runtime:addEventListener( "enterFrame", move);
myRectangle:addEventListener( "touch", onTouch )
-----------
-----------
-----------
-----------
--TEST JUNK
berry = display.newImage( "misc/Frame1.png" );
berry.x = centerX/2
berry.y = centerY/2
berry.xScale = scale
berry.yScale = scale

-- --Physics stuff
-- physics.start( )
-- physics.setGravity( 0, 0 ) --gravity is taken care of internally by Creature class
-- physics.addBody( llc.group )
-- for i = 1,back.numPlats do
-- 	physics.addBody( back.platforms[i] )
-- end