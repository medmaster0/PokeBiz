
-----------------------------------------------------------------------------------------
--
-- In charge of the main view
-- includes the physics, graphics, and game logic updates 
--
-- Probz need some better organization
-----------------------------------------------------------------------------------------
local widget = require("widget")
local physics = require("physics")
local creature = require("creature")
local berry = require("berry")
local egg = require("egg")
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

--Object initialization
back = Back.new(_W,_H)
llc = Creature.new(_W,_H) --Main Character in Game
llc:giveBow()
llc:randomize()
berry = Berry.new(_W,_H) --Berry that appears on each level for getting
berry.group.y = back.platforms[2].y - berry.frame.yScale*berry.frame.height/2
berry.group.x = berry.frame.xScale*berry.frame.width/2
berry:randomize()
boxCre = Creature.new(_W,_H) --Creature that watches over the box
boxCre.group.y = back.platforms[5].y - boxCre.body.width*boxCre.body.xScale/2
boxCre.group.x = _W - boxCre.body.width*boxCre.body.xScale/2
boxCre:randomize()
boxCre.body:play()
boxCre:giveSpeech(1)
hatCre = Creature.new(_W,_H) --Creature that has a hat (boy)
hatCre.group.y = back.platforms[4].y - hatCre.body.width*hatCre.body.xScale/2
hatCre.group.x = hatCre.body.width*hatCre.body.xScale/2
hatCre:giveHat()
hatCre:randomize()
hatCre.body:play()
hatCre:giveSpeech(1)
bowCre = Creature.new(_W,_H) --Creature that has a bow (girl)
bowCre.group.y = back.platforms[3].y - bowCre.body.width*bowCre.body.xScale/2
bowCre.group.x = _W - bowCre.body.width*bowCre.body.xScale/2
bowCre:giveBow()
bowCre:randomize()
bowCre.body:play()
bowCre:giveSpeech(1)

---Just test
egg = Egg.new(_W,_H) --egg

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
	--Berry will have already been moved in llc is it hasBerry
	if llc.hasBerry == false then
		berry.group.y = berry.group.y + scrollOffset
	end
	boxCre.group.y = boxCre.group.y + scrollOffset
	hatCre.group.y = hatCre.group.y + scrollOffset
	bowCre.group.y = bowCre.group.y + scrollOffset
	back:foreScrollDown(scrollOffset)

	----------------------------------------------
	--Check if Objects have reached bottom of screen
	-- BERRY
	if llc.hasBerry == false then
		if berry.group.y > _H then
			berry.group.y = 0
			berry:randomize()
		end
	end 
	-- BOXCRE
	if boxCre.group.y > _H then
		boxCre.group.y = 0
		boxCre:randomize()
	end
	-- HATCRE
	if hatCre.group.y > _H then
		hatCre.group.y = 0
		hatCre:randomize()
	end
	-- BOWCRE
	if bowCre.group.y > _H then
		bowCre.group.y = 0
		bowCre:randomize()
	end
	--Check if scrolled enough
	scrollCount = scrollCount - scrollOffset
	if(scrollCount < 0) then
		back:resetPlatforms()
		llc.group.y = back.platforms[back.numPlats - 1].y - 2*back.platforms[2].height*back.platforms[2].yScale
		llc:play( )
		--Reset Berry down on it's current platform
		if llc.hasBerry == false then
			berry.group.y = back.platforms[berry:checkPlatform(back.numPlats)].y - berry.frame.yScale*berry.frame.height/2
		end
		--Reset boxCre down on it's current platform
		boxCre.group.y = back.platforms[boxCre:checkPlatform(back.numPlats)].y - boxCre.body.width*boxCre.body.xScale/2
		--Reset hatCre down on it's current platform
		hatCre.group.y = back.platforms[hatCre:checkPlatform(back.numPlats)].y - hatCre.body.width*hatCre.body.xScale/2
		--Reset bowCre down on it's current platform
		bowCre.group.y = back.platforms[bowCre:checkPlatform(back.numPlats)].y - bowCre.body.width*bowCre.body.xScale/2
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
	--Berry will have already been moved in llc if it hasBerry
	if llc.hasBerry == false then
		berry.group.y = berry.group.y - scrollOffset
	end
	boxCre.group.y = boxCre.group.y - scrollOffset
	hatCre.group.y = hatCre.group.y - scrollOffset
	bowCre.group.y = bowCre.group.y - scrollOffset
	back:foreScrollUp(scrollOffset)

	----------------------------------------------
	--Check if Objects have reached top of screen
	-- BERRY
	if llc.hasBerry == false then
		if berry.group.y < 0 then
		 	berry.group.y = _H
		 	berry:randomize()
		 end
	end 
	-- BOXCRE
	if boxCre.group.y < 0 then
		boxCre.group.y = _H
		boxCre:randomize()
	end
	-- HATCRE
	if hatCre.group.y < 0 then
		hatCre.group.y = _H
		hatCre:randomize()
	end
	-- BOwCRE
	if bowCre.group.y < 0 then
		bowCre.group.y = _H
		bowCre:randomize()
	end

	--Check if scrolled enough
	scrollCount = scrollCount - scrollOffset
	if(scrollCount < 0) then
		back:resetPlatforms()
		llc.group.y = back.platforms[2].y - 2*back.platforms[2].height*back.platforms[2].yScale
		llc:play( )
		--Reset Berry down on top of current platform
		if llc.hasBerry == false then
			berry.group.y = back.platforms[berry:checkPlatform(back.numPlats)].y - berry.frame.yScale*berry.frame.height/2
		end
		--Reset boxCre down on current platform
		boxCre.group.y = back.platforms[boxCre:checkPlatform(back.numPlats)].y - boxCre.body.width*boxCre.body.xScale/2
		--Reset hatCre down on current platform
		hatCre.group.y = back.platforms[hatCre:checkPlatform(back.numPlats)].y - hatCre.body.width*hatCre.body.xScale/2
		--Reset bowCre down on current platform
		bowCre.group.y = back.platforms[bowCre:checkPlatform(back.numPlats)].y - bowCre.body.width*bowCre.body.xScale/2
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
			--print("got a landing")
			llc.vy = -15.5
			--llc.vy = -14
			llc.group.y = back.platforms[i].y - 1.5*back.platforms[i].height*back.platforms[i].yScale
			
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
			--print("hit the ceiling")
			llc.vy = 5.5
			llc.group.y = back.platforms[i].y + 1.5*back.platforms[i].height*back.platforms[i].yScale

		end
	end

end

local function onTouch(event)
	if event.x < llc.group.x then
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


--BEGIN CHARACTER COLLISION SEQUENCES
--Hacky, I know
--Pay attention to naming convention
------------------------------------
--If llc has a berry and encounters a hat
local function sequenceBerryHat2(event)
	hatCre:removeSpeech()
end
local function sequenceBerryHat(cre)
	if(cre.hasBow == true) then 
		print("make Love") 
		--llc:pause( )
		Runtime:removeEventListener( "enterFrame", move )
		Runtime:addEventListener( "enterFrame", sequenceBerryHat2 )	
		physics:pause() --stope physics movement
	end
end


-----------
-----------
-----------
-----------
-- --Physics stuff
physics.start( )
physics.setGravity( 0, 0 ) --gravity is taken care of internally by Creature class
physics.setContinuous(false)
physics.addBody( llc.group ,{density=1.0, friction = 1.0 , bounce=0})
physics.addBody(berry.group ,{density=10000000.0, friction = 1.0 , bounce=0})
physics.addBody(boxCre.group ,{density=10.0, friction = 1.0 , bounce=0})
physics.addBody(hatCre.group ,{density=100000000.0, friction = 1.0 , bounce=0})
boxCre.group.isFixedRotation = true
hatCre.group.isFixedRotation = true
llc.group.isFixedRotation = true
berry.group.isFixedRotation = true
--Gotta make a new function to translate shit
local function realBerryCollisionHandler(self,event)
	if berry.group.y < llc.group.y then return end -- return if llc hits it from underneath (doesnt count)
	berry.group.x = 0 - berry.frame.xScale*berry.frame.width/2
	berry.group.y = 0
	llc.group:insert(berry.group)
	berry.group:removeEventListener("collision", berry.group)
	llc.hasBerry = true
	berry = nil
end
local function onBerryCollision( self, event )
    if ( event.phase == "began" ) then

    elseif ( event.phase == "ended" ) then
    	timer.performWithDelay(0.1,function() return realBerryCollisionHandler( self, event) end )    
    end
end
--llc.group.collision = onBerryCollision
--llc.group:addEventListener("collision", llc.group)
berry.group.collision = onBerryCollision
berry.group:addEventListener("collision", berry.group)

--Make a function for the Creature Collsion Detection
local function realCreatureCollisionHandler(self,event)
	if event.target.y < llc.group.y then return end --return if the llc hits it from underneath

	--Determine behavior depending on mode code
	--1. Dot Dot Dot
	if(event.target.modeCode == 1) then 
		if(llc.hasBerry == true) then 
			print("hey, nice berry") 
			--Stop the llc depending on which side target is on
			llc.group.y = event.target.y
			if(event.target.x > _W/2)then --on right
				llc.group.x = event.target.x - llc.body.xScale*llc.body.width
				llc.group.xScale = -1*math.abs(llc.group.xScale)
			else --then on left
				llc.group.x = event.target.x + llc.body.xScale*llc.body.width
				llc.group.xScale = math.abs(llc.group.xScale)
			end
			--Now llc is facing the target... Determine what happens next based on who target is
			if(event.target == hatCre.group) then sequenceBerryHat(llc) end


		end
	end


end
local function onCreatureCollision(self,event)
	if(event.phase =="began")then
		timer.performWithDelay(0.1, function() return realCreatureCollisionHandler(self,event) end)
	end
end
boxCre.group.collision = onCreatureCollision
boxCre.group:addEventListener("collision", boxCre.group)
hatCre.group.collision = onCreatureCollision
hatCre.group:addEventListener("collision", hatCre.group)



