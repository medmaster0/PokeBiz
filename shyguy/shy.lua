ShyGuy = {}
ShyGuy__index = ShyGuy

function ShyGuy.new(width, height)
	local self = setmetatable( {}, ShyGuy )
	self.width = width --of screen
	self.height = height -- of screen
	self.vx = 2

	--HERE BEGINS DISPLAYS STUFF
	self.group = display.newGroup( ) --display group to hold all the pieces

	--SHYGUY
	self.sheet = graphics.newImageSheet("group/ShyGuyFrame.png", {width=16, height=16, numFrames=2})
	self.ShyFrame = display.newSprite(self.sheet, {name="ShyFrame", start = 1, count = 2, time = 1000})
	self.sheet = nil
	self.ShyFrame.xScale = scale
	self.ShyFrame.yScale = scale
	self.group:insert(self.ShyFrame)
	self.group["ShyFrame"]=self.ShyFrame
	self.ShyFrame:play()

	self.sheet = graphics.newImageSheet("group/ShyGuyColor.png", {width=16, height=16, numFrames=2})
	self.ShyColor = display.newSprite(self.sheet, {name="ShyColor", start = 1, count = 2, time = 1000})
	self.sheet = nil
	self.ShyColor.xScale = scale
	self.ShyColor.yScale = scale
	self.group:insert(self.ShyColor)
	self.group["ShyColor"]=self.ShyColor
	self.ShyColor:play()

	-- Other Shit
	--self.group.x = width/2
	--self.group.y = 3*height/4 
	self.group.x = 18220
	self.group.y = height - (self.group.ShyFrame.height*self.group.ShyFrame.xScale/2)

	return self

end

function ShyGuy.randomize(self)
	self.group.ShyColor:setFillColor(math.random(),math.random(),math.random() )
end
function ShyGuy.setColor(self,red,green,blue)
	self.group.ShyColor:setFillColor(red,green,blue )
end
function ShyGuy.giveSpeech(self)
	self.sheet = graphics.newImageSheet("misc/speech.png", {width=16, height=16, numFrames=2})
	self.speech = display.newSprite(self.sheet, {name="speech", start=1, count=2, time=1000})
	self.sheet = nil
	self.speech.xScale = scale
	self.speech.yScale = scale
	self.speech.x = self.group.x
	self.speech.y = self.group.y-((3/2)*self.group.height*self.group.yScale)
	self.speech:play()
end


----GUNGUY DECLARE__________________________________________________________________
GunGuy = {}
GunGuy__index = GunGuy

function GunGuy.new(width, height)
	local self = setmetatable( {}, GunGuy )
	self.width = width --of screen
	self.height = height -- of screen

	--HERE BEGINS DISPLAYS STUFF
	self.group = display.newGroup( ) --display group to hold all the pieces

	--GUNGUY
	self.sheet = graphics.newImageSheet("group/GunGuyFrame.png", {width=16, height=16, numFrames=2})
	self.GunFrame = display.newSprite(self.sheet, {name="GunFrame", start = 1, count = 2, time = 1000})
	self.sheet = nil
	self.GunFrame.xScale = scale
	self.GunFrame.yScale = scale
	self.group:insert(self.GunFrame)
	self.group["GunFrame"]=self.GunFrame
	self.GunFrame:play()

	self.sheet = graphics.newImageSheet("group/GunGuyColor.png", {width=16, height=16, numFrames=2})
	self.GunColor = display.newSprite(self.sheet, {name="GunColor", start = 1, count = 2, time = 1000})
	self.sheet = nil
	self.GunColor.xScale = scale
	self.GunColor.yScale = scale
	self.group:insert(self.GunColor)
	self.group["GunColor"]=self.GunColor
	self.GunColor:play()

	-- Other Shit
	--self.group.x = width/4
	--self.group.y = 3*height/4 
	--self.group.x = 9230
	--self.group.y = height - (self.group.GunFrame.height*self.group.GunFrame.xScale/2)
	self.group.x = 11528
	self.group.y = 18731

	return self

end

function GunGuy.randomize(self)
	self.group.GunColor:setFillColor(math.random(),math.random(),math.random() )
end
function GunGuy.setColor(self,red,green,blue)
	self.group.GunColor:setFillColor(red,green,blue )
end

----FLYGUY DECLARE__________________________________________________________________
FlyGuy = {}
FlyGuy__index = GunGuy

function FlyGuy.new(width, height)
	local self = setmetatable( {}, FlyGuy )
	self.width = width --of screen
	self.height = height -- of screen
	self.vx = -6 --<<<<<Hardcoded?

	--HERE BEGINS DISPLAYS STUFF
	self.group = display.newGroup( ) --display group to hold all the pieces

	--FLYGUY
	self.sheet = graphics.newImageSheet("group/FlyGuyFrame.png", {width=16, height=16, numFrames=2})
	self.FlyFrame = display.newSprite(self.sheet, {name="FlyFrame", start = 1, count = 2, time = 1000})
	self.sheet = nil
	self.FlyFrame.xScale = -scale
	self.FlyFrame.yScale = scale
	self.group:insert(self.FlyFrame)
	self.group["FlyFrame"]=self.FlyFrame
	self.FlyFrame:play()

	self.sheet = graphics.newImageSheet("group/FlyGuyColor.png", {width=16, height=16, numFrames=2})
	self.FlyColor = display.newSprite(self.sheet, {name="FlyColor", start = 1, count = 2, time = 1000})
	self.sheet = nil
	self.FlyColor.xScale = -scale
	self.FlyColor.yScale = scale
	self.group:insert(self.FlyColor)
	self.group["FlyColor"]=self.FlyColor
	self.FlyColor:play()

	-- Other Shit
	self.tPrevious = system.getTimer( ) --start timer
	--self.group.x = 3*width/4
	--self.group.y = 3*height/4
	self.group.x = 32565
	self.group.y = 7537

	return self

end
function FlyGuy.randomize(self)
	self.group.FlyColor:setFillColor(math.random(),math.random(),math.random() )
end
function FlyGuy.setColor(self,red,green,blue)
	self.group.FlyColor:setFillColor(red,green,blue )
end
function FlyGuy.fly(self, event)
	local tDelta = event.time - self.tPrevious
	self.tPrevious = event.time

	--X direction
	self.xOffset = (self.vx * tDelta)
	self.group.x = self.group.x + self.xOffset
	if (self.group.x < 0-10000) then
		self.vx = self.vx * -1
		self.group.x = 0
		self.group.xScale = self.group.xScale * -1
		self.group.y = math.random(0,self.height/2)
	end
	if (self.group.x >self.width+10000) then
		self.vx = self.vx*-1
		self.group.x = self.width
		self.group.xScale = self.group.xScale * -1
		self.group.y = math.random(0,self.height/2)
	end
end

------BOMB DECLARE____---------------------
Bomb = {}
Bomb.__index = Bomb

function Bomb.new(width,height)
	local self = setmetatable( {}, Bomb )
	self.width = width --of screen
	self.height = height -- of screen

	--HERE BEGINS DISPLAYS STUFF
	self.group = display.newGroup( ) --display group to hold all the pieces

	--take care of Frame
	self.frame = display.newImage( "misc/bomb.png" , true);
	self.frame.xScale = scale
	self.frame.yScale = scale
	self.group:insert( self.frame )
	self.group["frame"]= self.frame
		-- Other Shit
	self.group.x = width/2
	self.group.y = height/2

	return self
end

------MUSHROOM DECLARE____---------------------
Mushroom = {}
Mushroom.__index = Mushroom

function Mushroom.new(width,height)
	local self = setmetatable( {}, Mushroom )
	self.width = width --of screen
	self.height = height -- of screen

	--HERE BEGINS DISPLAYS STUFF
	self.group = display.newGroup( ) --display group to hold all the pieces

	--take care of Frame
	self.frame = display.newImage( "misc/MushroomFrame.png" , true);
	self.frame.xScale = scale
	self.frame.yScale = scale
	self.group:insert( self.frame )
	self.group["frame"]= self.frame
	--take care of Primary Color
	self.prim = display.newImage( "misc/MushroomPrim.png" , true);
	self.prim.xScale = scale
	self.prim.yScale = scale
	self.group:insert( self.prim )
	self.group["prim"]= self.prim
	--take care of Secondary Color
	self.seco = display.newImage( "misc/MushroomSeco.png" , true);
	self.seco.xScale = scale
	self.seco.yScale = scale
	self.group:insert( self.seco )
	self.group["seco"]= self.seco

	self.group.prim:setFillColor(math.random(),math.random(),math.random() )
	self.group.seco:setFillColor(math.random(),math.random(),math.random() )

		-- Other Shit
	--self.group.x = width/2
	--self.group.y = height/4
	self.group.x = 13759
	self.group.y = 11418
	--self.group.x = 14715
	--self.group.y = 25312

	return self
end
function Mushroom.randomize(self)
	self.group.prim:setFillColor(math.random(),math.random(),math.random() )
	self.group.seco:setFillColor(math.random(),math.random(),math.random() )
end

------YOSHI DECLARE____---------------------

function colorYoshi(yoshi)

	--determine colors

	--Have to decide which color we want to change on
	random = math.random(1,3)
	red = math.random()
	green = math.random()
	blue = math.random()

	--colors have to be less than 0.625 so we can lighten them for shading effect
	if(random == 1)then
		repeat
			red = math.random()
		until(red>0.625)
		yoshi.group.dark:setFillColor(red,green,blue)
		yoshi.group.med:setFillColor(red+0.1875,green,blue)
		yoshi.group.light:setFillColor(red+0.375,green,blue)		
	end
	if(random == 2)then
		repeat
			green = math.random()
		until(green>0.625)
		yoshi.group.dark:setFillColor(red,green,blue)
		yoshi.group.med:setFillColor(red,green+0.1875,blue)
		yoshi.group.light:setFillColor(red,green+0.375,blue)
	end	
	if(random == 3)then
		repeat
			blue = math.random()
		until(blue>0.625)
		yoshi.group.dark:setFillColor(red,green,blue)
		yoshi.group.med:setFillColor(red,green,blue+0.1875)
		yoshi.group.light:setFillColor(red,green,blue+0.375)
	end

end

Yoshi = {}
Yoshi.__index = Yoshi

function Yoshi.new(width,height)
	local self = setmetatable( {}, Yoshi )
	self.width = width --of screen
	self.height = height -- of screen
	self.vx = -2
	self.vy = 7
	self.leftLimit = 26518
	self.rightLimit = width + 800

	--HERE BEGINS DISPLAYS STUFF
	self.group = display.newGroup( ) --display group to hold all the pieces

	--take care of Frame
	self.frame = display.newImage( "group/YoshiFrame.png" , true);
	self.frame.xScale = scale
	self.frame.yScale = scale
	self.group:insert( self.frame )
	self.group["frame"]= self.frame
	--take care of Dark Color
	self.dark = display.newImage( "group/YoshiDark.png" , true);
	self.dark.xScale = scale
	self.dark.yScale = scale
	self.group:insert( self.dark )
	self.group["dark"]= self.dark
	--take care of Med Color
	self.med = display.newImage( "group/YoshiMed.png" , true);
	self.med.xScale = scale
	self.med.yScale = scale
	self.group:insert( self.med )
	self.group["med"]= self.med
	--take care of Light Color
	self.light = display.newImage( "group/YoshiLight.png" , true);
	self.light.xScale = scale
	self.light.yScale = scale
	self.group:insert( self.light )
	self.group["light"]= self.light

	--Color Yoshi
	colorYoshi(self)

	-- Other Shit
	self.tPrevious = system.getTimer( ) --start timer
	--self.group.x = width/2
	--self.group.y = height/2
	self.group.x = 37718
	self.group.y = height - (self.group.frame.height*self.group.frame.xScale/2)

	return self
end
function Yoshi.move(self, event)
	local tDelta = event.time - self.tPrevious
	self.tPrevious = event.time

	--X direction
	self.xOffset = (self.vx * tDelta)
	self.group.x = self.group.x + self.xOffset
	if (self.group.x < self.leftLimit) then
		self.vx = self.vx * -1
		self.group.x = self.leftLimit
		self.group.xScale = self.group.xScale * -1
	end
	if (self.group.x >self.rightLimit) then
		self.vx = self.vx*-1
		self.group.x = self.rightLimit
		self.group.xScale = self.group.xScale * -1
	end
end

------BULLET BILL DECLARE____---------------------
Bill = {}
Bill.__index = Bill

function Bill.new(width,height)
	local self = setmetatable( {}, Bill)
	self.width = width --of screen
	self.height = height -- of screen
	self.vx = 8

	--HERE BEGINS DISPLAYS STUFF
	self.group = display.newGroup( ) --display group to hold all the pieces

	--take care of Frame
	self.frame = display.newImage( "misc/bill.png" , true);
	self.frame.xScale = scale
	self.frame.yScale = scale
	self.group:insert( self.frame )
	self.group["frame"]= self.frame

		-- Other Shit
	self.tPrevious = system.getTimer( ) --start timer
	--self.group.x = width/2
	--self.group.y = height/4
	self.group.x = 13759
	self.group.y = 11418
	--self.group.x = 14715
	--self.group.y = 25312

	return self
end

------BULLET (FROM GUNGUY) DECLARE____---------------------
Bullet = {}
Bullet.__index = Bullet

function Bullet.new(width,height)
	local self = setmetatable( {}, Bill)
	self.width = width --of screen
	self.height = height -- of screen
	self.vx = 16
	self.vy = 5

	--HERE BEGINS DISPLAYS STUFF
	self.group = display.newGroup( ) --display group to hold all the pieces

	--take care of Frame
	self.frame = display.newImage( "misc/bullet.png" , true);
	self.frame.xScale = scale
	self.frame.yScale = scale
	self.group:insert( self.frame )
	self.group["frame"]= self.frame

		-- Other Shit
	self.tPrevious = system.getTimer( ) --start timer
	--self.group.x = width/2
	--self.group.y = height/4
	self.group.x = 13759
	self.group.y = 11418
	--self.group.x = 14715
	--self.group.y = 25312

	return self
end

---BAM DECLARE __-------------
Bam = {}
Bam.__index = Bam
function Bam.new(width,height)
	local self = setmetatable( {}, Bam)
	self.width = width
	self.height = height -- of screen

	self.frame = display.newImage( "misc/bam.png" , true);
	self.frame.xScale = scale
	self.frame.yScale = scale
	self.frame.x = 13759
	self.frame.y = 10500

	return self
end

-- BILLBLAST DECLARE------------______
BillBlast = {}
BillBlast.__index = BillBlast
function BillBlast.new(width, height)
	local self = setmetatable( {}, BillBlast)
	self.width = width --of screen
	self.height = height -- of screen
	self.vx = -2
	self.leftLimit = 5312
	self.rightLimit = 23242

	--HERE BEGINS DISPLAYS STUFF
	self.group = display.newGroup( ) --display group to hold all the pieces

	--BILLBLAST
	self.sheet = graphics.newImageSheet("misc/BillBlast.png", {width=16, height=32, numFrames=2})
	self.frame = display.newSprite(self.sheet, {name="BillBlast", start = 1, count = 2, time = 1000})
	self.sheet = nil
	self.frame.xScale = scale
	self.frame.yScale = scale
	self.group:insert(self.frame)
	self.group["frame"]=self.frame
	self.frame:play()

	-- Other Shit
	self.tPrevious = system.getTimer( ) --start timer
	--self.group.x = width/2
	--self.group.y = 3*height/4 
	self.group.x = 18220
	self.group.y = height - (self.group.frame.height*self.group.frame.xScale/2)

	return self

end

-- CHEEP CHEEP DECLARE -------
Cheep = {}
Cheep__index = Cheep
function Cheep.new(width, height)
	local self = setmetatable({}, Cheep)
	self.width = width --of screen
	self.height = height -- of screen
	self.vx = 2

	--HERE BEGINS DISPLAYS STUFF
	self.group = display.newGroup( ) --display group to hold all the pieces

	--CHEEP
	self.sheet = graphics.newImageSheet("group/cheepFrame.png", {width=16, height=16, numFrames=2})
	self.frame = display.newSprite(self.sheet, {name="frame", start = 1, count = 2, time = 1000})
	self.sheet = nil
	self.frame.xScale = scale
	self.frame.yScale = scale
	self.group:insert(self.frame)
	self.group["frame"]=self.frame
	self.frame:play()

	self.sheet = graphics.newImageSheet("group/cheepColor.png", {width=16, height=16, numFrames=2})
	self.color = display.newSprite(self.sheet, {name="color", start = 1, count = 2, time = 1000})
	self.sheet = nil
	self.color.xScale = scale
	self.color.yScale = scale
	self.group:insert(self.color)
	self.group["color"]=self.color
	self.color:play()

	-- Other Shit
	self.group.x = width/1.25
	self.group.y = 3*height/4 
	
	return self
end
function Cheep.randomize(self)
	self.group.color:setFillColor(math.random(),math.random(),math.random() )
end

