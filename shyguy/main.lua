
-----------------------------------------------------------------------------------------
--
-- In charge of the main view
-- includes the physics, graphics, and game logic updates 
--
-- Probz need some better organization
-----------------------------------------------------------------------------------------
local shy = require("shy")

scale = 100 --how much to stretch the pixel graphics (and for movement)
local centerX = display.contentCenterX
local centerY = display.contentCenterY
local _W = display.contentWidth --480
local _H = display.contentHeight --320
--Use nearest neighbor for scaling
display.setDefault( magTextureFilter, nearest )
display.setDefault( minTextureFilter, nearest )

local myRectangle = display.newRect(centerX,centerY, _W, _H) -- rectWidth, _H)
rectRed = 0.6
rectGreen = 0.6
rectBlue = 0.6
myRectangle:setFillColor( rectRed,rectGreen,rectBlue )
myRectangle:toFront( )
local function randomizeBack()
	if(math.random()>0.5)then 
		rectRed = rectRed + 0.1
		if rectRed > 1 then rectRed = 1 end
	else 
		rectRed = rectRed - 0.1
		if rectRed < 0 then rectRed = 0 end
	end
	if(math.random()>0.5)then 
		rectGreen = rectGreen + 0.1
		if rectGreen > 1 then rectGreen = 1 end
	else 
		rectGreen = rectGreen - 0.1
		if rectGreen < 0 then rectGreen = 0 end
	end
	if(math.random()>0.5)then 
		rectBlue = rectBlue + 0.1
		if rectBlue > 1 then rectBlue = 1 end
	else 
		rectBlue = rectBlue - 0.1
		if rectBlue < 0 then rectBlue = 0 end		
	end
	myRectangle:setFillColor( rectRed,rectGreen,rectBlue )
end


-- local rightSide = display.newRect(3*_W/4, centerY, _W/2, _H/2) --rectangle to detech righ hand touches
-- local leftSide = display.newRect(_W/4, centerY, _W/2, _H/2) --rectangle to detech righ hand touches
customerScore = 0 --How many customers have been served
--customerText = display.newText("Served: " .. tostring(customerScore), 39500, 2300, "PTSerif-Regular", 720)
--customerText = display.newText("Served: " .. tostring(customerScore), 39500, 2300, "PTSans-NarrowBold", 720)
customerText = display.newText( tostring(customerScore).. " Served", 39500, 2300, "Emulogic", 420, "right")
customerText:setFillColor( 0,0,0  )
huntedScore = 0 --How many Yoshis have been hunted
huntedText = display.newText(tostring(huntedScore).. " Hunted", 39500, 2800, "Emulogic", 420, "right")
huntedText:setFillColor( 0,0,0  )
deliverScore = 0 --How many Yoshis have been carried off for delivery
deliverText = display.newText(tostring(deliverScore).. " Delivered", 39500, 3300, "Emulogic", 420, "right")
deliverText:setFillColor( 0,0,0  )

--Use nearest neighbor for scaling
display.setDefault( magTextureFilter, nearest )
display.setDefault( minTextureFilter, nearest )

--Draw castle
-- castle = display.newImage("misc/castle.png")
-- castle.x = _W/3
-- castle.y = _H/2
-- castle.xScale = (0.5*_W/castle.width)
-- castle.yScale = (_H/castle.height)
castleBOT = display.newImage("misc/castleBOT.png")
castleBOT.x = _W/3
castleBOT.y = _H/2
castleBOT.xScale = (0.5*_W/castleBOT.width)
castleBOT.yScale = (_H/castleBOT.height)
castleMID = display.newImage("misc/castleMID.png")
castleMID.x = _W/3
castleMID.y = _H/2
castleMID.xScale = (0.5*_W/castleMID.width)
castleMID.yScale = (_H/castleMID.height)
castleTOP = display.newImage("misc/castleTOP.png")
castleTOP.x = _W/3
castleTOP.y = _H/2
castleTOP.xScale = (0.5*_W/castleTOP.width)
castleTOP.yScale = (_H/castleTOP.height)

--Obect Init
mushroom = Mushroom.new(_W,_H)
mushroom2 = Mushroom.new(_W,_H) --THe mushoom that gets delivered
yoshi = Yoshi.new(_W,_H)
shyguy = ShyGuy.new(_W,_H)
shyguy2 = ShyGuy.new(_W,_H) 
gunguy = GunGuy.new(_W,_H) --Hunts the yoshi
bullet = Bullet.new(_W,_H)
gunguy2 = GunGuy.new(_W,_H)
flyguy = FlyGuy.new(_W,_H)
flyguy2 = FlyGuy.new(_W,_H) --Picks up top mushroom
bill = Bill.new(_W,_H)
billBlast = BillBlast.new(_W,_H)
bam = Bam.new(_W,_H)
cheep = Cheep.new(_W,_H)
Cheep.randomize(cheep)
--bomb = Bomb.new(_W,_H)
customer = ShyGuy.new(_W,_H)
ShyGuy.randomize(customer)

--Set Positions (if not already set)
mushroom2.group.x = 12927
mushroom2.group.y = 25600
flyguy2.group.y = 10125
flyguy.vx = -1*math.random(4,8)
customer.group.x = 1487
customer.group.y = _H - (customer.group.ShyFrame.height*customer.group.ShyFrame.xScale/2)
shyguy2.group.x = 13706
shyguy2.group.xScale = -1*shyguy2.group.xScale
shyguy2.group:toBack()
mushroom2.group:toBack()
gunguy2.group.x = 11156
gunguy2.group.y = 12600
gunguy2.group:toBack()
billBlast.group.y = gunguy2.group.y - 0.5*gunguy2.group.GunFrame.height*gunguy2.group.GunFrame.yScale
billBlast.group:toBack()
flyguy2.group:toBack()
mushroom.group:toBack()
castleMID:toBack()
castleTOP:toBack()
myRectangle:toBack()
bullet.group:toBack()
bam.frame:toBack()

--Set Guy Colors
red = math.random()
green = math.random()
blue = math.random()
ShyGuy.setColor(shyguy,red,green,blue) 
ShyGuy.setColor(shyguy2,red,green,blue)
GunGuy.setColor(gunguy,red,green,blue) 
GunGuy.setColor(gunguy2,red,green,blue) 
FlyGuy.setColor(flyguy,red,green,blue) 
FlyGuy.setColor(flyguy2,red,green,blue) 

--LISTENERS------
--Listeners will set a flag which allows approriate action in main loop
tPreviousHC = 0 --timer involved with this event (Helping Customer)
local function customerTouch(event)
	if newCustomer ~= true then return end
	if (event.x < 2291 and event.y > 24500 ) then 
		helpingCustomer = true
		newCustomer = false
		customer.speech:toBack()
		mushroom2.group:toFront()	
		customer.group:toFront()
		shyguy2.group:toFront()
		tPreviousHC = system.getTimer()
	end
end
Runtime:addEventListener("touch", customerTouch)

tPreviousSY = 0 --timer involved with Shooting Yoshi
local function gunnerTouch(event)
	if newYoshi ~= true then return end
	if (event.x < 12716 and event.x > 10292) and (event.y > 17437 and event.y < 19950)then
		shootingYoshi = true
		isHomingSY = true
		newYoshi = false
		gunguy.speech:toBack()
		bullet.group.x = gunguy.group.x
		bullet.group.y = gunguy.group.y
		bullet.group:toFront()
		tPreviousSY = system.getTimer()
	end
end
Runtime:addEventListener("touch", gunnerTouch)

tPreviousPM = 0 -- timer involved with picking Mushroom
local function mushroomTouch(event)
	if newMushroom == false then return end
	if (event.x > 12165 and event.x < 15406) and (event.y > 10293 and event.y < 13050)then
		pickingMushroom = true
		isHomingPM = true
		newMushroom = false
		mushroom.speech:toBack()
		tPreviousPM = system.getTimer()
	end
end
Runtime:addEventListener("touch", mushroomTouch)

--EVENT BRANCHES
--Branches to behavior based on event states
--flags for use in the function are listed
isMovingHC = true 
isLeavingHC = false
isArrivingHC = false
local function helpCustomer(event)

	local tDelta = event.time - tPreviousHC
	tPreviousHC = event.time
	local xOffset = (shyguy2.vx * tDelta)

	if(isMovingHC == true) then
		shyguy2.group.x = shyguy2.group.x - xOffset
		mushroom2.group.x = mushroom2.group.x - xOffset
		if(shyguy2.group.x < 3630)then
			--Get ready for next phase
			isMovingHC = false
			isLeavingHC = true
			customer.group.xScale = customer.group.xScale*-1
			shyguy2.group.xScale = shyguy2.group.xScale*-1
			mushroom2.group.x = customer.group.x - 779
			customerScore = customerScore + 1
			customerText.text = tostring(customerScore).. " Served"
			randomizeBack()
		end
	end

	if(isLeavingHC == true) then
		customer.group.x = customer.group.x - xOffset
		mushroom2.group.x = mushroom2.group.x - xOffset		
		shyguy2.group.x = shyguy2.group.x + xOffset	
		
		--get ready for next phase when reach doorway
		if(shyguy2.group.x > 13706) then
			isLeavingHC = false
			isArrivingHC = true
			shyguy2.group.x = 13706
			shyguy2.group:toBack()
			mushroom2.group.x = 12927
			mushroom2.group:toBack()
			Mushroom.randomize(mushroom2)
			ShyGuy.randomize(customer)
			customer.group.xScale = customer.group.xScale*-1
			shyguy2.group.xScale = shyguy2.group.xScale*-1
		end
	end

	if(isArrivingHC == true) then
		customer.group.x = customer.group.x + xOffset
		if(customer.group.x > 1487)then
			isArrivingHC = false
			isMovingHC = true
			helpingCustomer = false
			newCustomer = true
			customer.group.x = 1487
			customer.speech:toFront()
		end

	end

end

isHomingSY = false
isFallingOffSY = false
isArrivingSY = false
local function shootYoshi(event)

	local tDelta = event.time - tPreviousSY
	tPreviousSY = event.time
	local xOffset = (bullet.vx * tDelta)
	local yOffset = (yoshi.vy * tDelta)

	if(isHomingSY == true)then
		--bullet.group.x = bullet.group.x + xOffset
		bullet.group.x = bullet.group.x + (yoshi.group.x - bullet.group.x)/9
		--bullet.group.y = bullet.group.y + (yoshi.group.y - bullet.group.y)/18 --Denominator is the "Bully Factor"
		bullet.group.y = bullet.group.y + (yoshi.group.y - bullet.group.y)/10
		--bullet.group.y = bullet.group.y + yOffset
		if math.abs(bullet.group.x - yoshi.group.x) < 600 then
			isHomingSY = false
			isFallingOffSY = true
			yoshi.group.yScale = yoshi.group.yScale * -1
			yoshi.group.y = yoshi.group.y - 400 --move it up just a tad
			bullet.group:toBack()
			huntedScore = huntedScore + 1
			huntedText.text = tostring(huntedScore) .. " Hunted"
			randomizeBack()
		end
	end
	if(isFallingOffSY == true) then
		local yOffset = (yoshi.vy * tDelta)
		yoshi.group.y = yoshi.group.y + yOffset
		if(yoshi.group.y > _H + 3000) then
			yoshi.group.yScale = yoshi.group.yScale * -1
			yoshi.group.y = _H - (yoshi.group.frame.height*yoshi.group.frame.yScale/2)
			yoshi.group.x = _W + 8101
			colorYoshi(yoshi)
			isFallingOffSY = false
			isArrivingSY = true
		end
	end
	if(isArrivingSY == true) then
		if(yoshi.group.x < _W) then
			isArrivingSY= false
			isHomingSY = true
			shootingYoshi = false
			newYoshi = true
			gunguy.speech:toFront()

		end
	end
end

isHomingPM = false
isCarryingPM = false
isAppearingPM = false
local function pickMushroom(event)

	if(isHomingPM == true)then
		flyguy2.group.y = flyguy2.group.y + (mushroom.group.y - flyguy2.group.y)/20
		if math.abs(flyguy2.group.x - mushroom.group.x) < 600 
		and math.abs(flyguy2.group.y - mushroom.group.y) < 800 then
			isHomingPM = false
			isCarryingPM = true
			mushroom.group.y = flyguy2.group.y - 350
			randomizeBack()
		end
	end
	if(isCarryingPM == true)then
		mushroom.group.x = flyguy2.group.x + 779
		if(flyguy2.group.x < -1700)or(flyguy2.group.x > _W+1700)then
			isCarryingPM = false
			isAppearingPM = true
			deliverScore = deliverScore + 1
			deliverText.text = tostring(deliverScore).. " Delivered"
			bam.frame:toFront()
			tPreviousPM = event.time
		end
	end
	if(isAppearingPM == true)then
		local tDelta = event.time - tPreviousPM
		if tDelta > 400 then
			bam.frame:toBack()
			mushroom.group.x = 13759
			mushroom.group.y = 11418
			Mushroom.randomize(mushroom)
			isAppearingPM = false
			isHomingPM = true
			pickingMushroom = false
			newMushroom = true
			mushroom.speech:toFront()
		end
	end

end

--MAIN GAME LOOP---------
--Event variables/flags
newCustomer = true --turns off when customer has been helped
helpingCustomer = false --Starts helping customer
ShyGuy.giveSpeech(customer)
newYoshi = true --turns off when Yoshi has been shot
shootingYoshi = false --starts shooting Yoshi
ShyGuy.giveSpeech(gunguy)
newMushroom = true --turns off when mushroom has been picked up
pickingMushroom = false --start to pick up mushroom
ShyGuy.giveSpeech(mushroom)
local function move(event)

	FlyGuy.fly(flyguy, event)
	FlyGuy.fly(bill, event)	
	FlyGuy.fly(flyguy2, event)
	Yoshi.move(yoshi,event)
	Yoshi.move(billBlast, event)
 
	--Branch to game event actions
	if(helpingCustomer == true) then helpCustomer(event) end
	if(shootingYoshi == true) then shootYoshi(event) end
	if(pickingMushroom == true) then pickMushroom(event) end

end
Runtime:addEventListener( "enterFrame", move);
customerText:toFront()


---DEBUG TOOLS
local function Coords( event )
    print(event.x)
    print(event.y)
end
Runtime:addEventListener( "touch", Coords )

-- local systemFonts = native.getFontNames()

-- -- Set the string to query for (part of the font name to locate)
-- local searchString = "pt"

-- -- Display each font in the Terminal/console
-- for i, fontName in ipairs( systemFonts ) do

--     local j, k = string.find( string.lower(fontName), string.lower(searchString) )

--     if ( j ~= nil ) then
--         print( "Font Name = " .. tostring( fontName ) )
--     end
-- end

