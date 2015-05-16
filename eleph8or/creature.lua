Creature = {}
Creature.__index = Creature

function Creature.new(width, height)
	local self = setmetatable( {}, Creature )
	self.width = width --of screen
	self.height = height -- of screen

	-- movement parameters
	self.vx = math.random(-10,-1) -- << Hardcoded to refelect scale of 100
	self.vy = 0
	self.termVy = 10 --terminal velocity
	self.gravity = 0.01

	--HERE BEGINS DISPLAYS STUFF
	self.group = display.newGroup( ) --display group to hold all the pieces
	self.hasHat = true
	self.hasBow = false
	self.hasFlag = true

	--take care of flag
	if (self.hasFlag == true) then
		self.sheet = graphics.newImageSheet( "group/flagPrim.png", {width=32, height=32,numFrames=8} )
		self.flagPrim = display.newSprite( self.sheet, {name="flagPrim", start= 5, count = 4, time = 1000} )
		self.sheet = nil
		self.flagPrim.xScale = scale
		self.flagPrim.yScale = scale
		self.flagPrim.x = (scale*8)
		self.group:insert(self.flagPrim)
		self.group["flagPrim"] = self.flagPrim
		self.flagPrim:play( )
		self.sheet = graphics.newImageSheet( "group/flagSeco.png", {width=32, height=32,numFrames=8} )
		self.flagSeco = display.newSprite( self.sheet, {name="flagPrim", start= 5, count = 4, time = 1000} )
		self.sheet = nil
		self.flagSeco.xScale = scale
		self.flagSeco.yScale = scale
		self.flagSeco.x = scale*8
		self.group:insert(self.flagSeco)
		self.group["flagSeco"] = self.flagSeco
		self.flagSeco:play( )
		self.sheet = graphics.newImageSheet( "group/flagStem.png", {width=32, height=32,numFrames=8} )
		self.flagStem = display.newSprite( self.sheet, {name="flagStem", start= 5, count = 4, time = 1000} )
		self.sheet = nil
		self.flagStem.xScale = scale
		self.flagStem.yScale = scale
		self.flagStem.x = scale*8
		self.group:insert(self.flagStem)
		self.group["flagStem"] = self.flagStem
		self.flagStem:play( )
	end

	--Take care of body
	self.sheet = graphics.newImageSheet( "group/crePrim.png", {width=32, height=32,numFrames=2} )
	self.body = display.newSprite( self.sheet, {name="cre", start= 1, count = 2, time = 1000} )
	self.sheet = nil
	self.body.xScale = scale
	self.body.yScale = scale
	self.group:insert( self.body )
	self.group["body"]= self.body
	self.group.body:setFillColor( 0.2,0.2,0.9 )

	--take care of headband
	self.band = display.newImage( "group/creSeco.png" )
	self.band.xScale = scale
	self.band.yScale = scale
	self.group:insert(self.band)
	self.group["band"] = self.band
	self.group.band:setFillColor( 0.9,0.3,0.3 )

	--take care of eye
	self.eye = display.newImage( "group/creEye.png" )
	self.eye.xScale = scale
	self.eye.yScale = scale
	self.group:insert(self.eye)
	self.group["eye"] = self.eye

	-- take care of hat
	if (self.hasHat == true) then
		self.hatPrim = display.newImage("group/hatPrim.png")
		self.hatPrim.xScale = scale
		self.hatPrim.yScale = scale
		self.group:insert(self.hatPrim)
		self.group["hatPrim"] = self.hatPrim
		self.hatSeco = display.newImage("group/hatSeco.png")
		self.hatSeco.xScale = scale
		self.hatSeco.yScale = scale
		self.group:insert(self.hatSeco)
		self.group["hatSeco"] = self.hatSeco
	end

	-- take care of bow
	if (self.hasBow == true) then
		self.bowPrim = display.newImage("group/bowPrim.png")
		self.bowPrim.xScale = scale
		self.bowPrim.yScale = scale
		self.group:insert(self.bowPrim)
		self.group["bowPrim"] = self.bowPrim
		self.bowSeco = display.newImage("group/bowSeco.png")
		self.bowSeco.xScale = scale
		self.bowSeco.yScale = scale
		self.group:insert(self.bowSeco)
		self.group["bowSeco"] = self.bowSeco
	end

	-- Other Shit
	self.group.x = width/2
	self.group.y = 3*height/4 
	self.tPrevious = system.getTimer( ) --start timer

	return self
end

function Creature.randomize(self)
	self.group.body:setFillColor( math.random(), math.random(), math.random() )
	if(self.hasHat == true) then 
		self.group.hatSeco:setFillColor( 0.2,0.9, 0.3 )
		self.group.hatPrim:setFillColor( 0, 0, 0 )
	end
	if(self.hasBow == true) then  
		self.group.bowSeco:setFillColor( 0.2,0.9, 0.3 )
		self.group.bowPrim:setFillColor( 0, 0, 0 )
	end
	if(self.hasFlag == true) then  
		self.group.flagSeco:setFillColor( 0.9,0.2, 0.3 )
		self.group.flagPrim:setFillColor( 0, 0, 0 )
	end
end

function Creature.move(self, event)
	local tDelta = event.time - self.tPrevious
	self.tPrevious = event.time

	--X direction
	self.xOffset = (self.vx * tDelta)
	self.group.x = self.group.x + self.xOffset
	if (self.group.x < 0) then
		self.vx = self.vx * -1
		self.group.x = 0
		self.group.xScale = self.group.xScale * -1
	end
	if (self.group.x >self.width) then
		self.vx = self.vx*-1
		self.group.x = self.width
		self.group.xScale = self.group.xScale * -1
	end

	-- Y direction
	self.vy = self.vy + self.gravity*tDelta
	self.yOffset = (self.vy * tDelta)
	self.group.y = self.group.y + self.yOffset
	if (self.group.y < 0) then
		self.vy = self.vy * -1
		self.group.y = 0
	end
	if (self.group.y >self.height) then
		--self.vy = self.vy*-1
		self.vy = -15.5 --This value calibrated and measured for jumping with 6 platforms
		self.group.y = self.height
	end

	--correct animation
	if (self.vy>0) then 
		self.body:setFrame( 2 ) 
	else
		self.body:setFrame( 1 )
	end


end

function Creature.pause(self)
	if self.hasFlag then 
		self.flagPrim:pause( )
		self.flagSeco:pause()
		self.flagStem:pause( )
	end
end

function Creature.play(self)
	if self.hasFlag then 
		self.flagPrim:play( )
		self.flagSeco:play()
		self.flagStem:play( )
	end
end