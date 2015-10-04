Berry = {}
Berry.__index = Berry

function Berry.new(width,height)
	local self = setmetatable( {}, Berry )
	self.width = width --of screen
	self.height = height -- of screen

	--HERE BEGINS DISPLAYS STUFF
	self.group = display.newGroup( ) --display group to hold all the pieces

	--take care of Frame
	self.frame = display.newImage( "group/berryFrame.png" );
	self.frame.xScale = scale
	self.frame.yScale = scale
	self.group:insert( self.frame )
	self.group["frame"]= self.frame

	--take care of prim
	self.prim = display.newImage( "group/berryPrim.png" );
	self.prim.xScale = scale
	self.prim.yScale = scale
	self.group:insert( self.prim )
	self.group["prim"]= self.prim
	--self.group.prim:setFillColor( 0.2,0.2,0.9 )

	--take care of seco
	self.seco = display.newImage( "group/berrySeco.png" );
	self.seco.xScale = scale
	self.seco.yScale = scale
	self.group:insert( self.seco )
	self.group["seco"]= self.seco
	--self.group.seco:setFillColor( 0.2,0.2,0.9 )

	-- Other Shit
	self.group.x = width/2
	self.group.y = 3*height/4 

	return self
end

function Berry.randomize(self)
	self.group.prim:setFillColor( math.random(), math.random(), math.random() )
	self.group.seco:setFillColor( math.random(), math.random(), math.random() )
end

--Returns what platform it is sitting on based off of total platforms on level
function Berry.checkPlatform(self, numPlats)
	platHeight = self.height/numPlats --How high each platform (and space above it) is
	-- if self.group.y < platHeight then return(1)
	-- elseif self.group.y < 2*platHeight then return(2)
	for i=1,numPlats do 
		if self.group.y < i*platHeight then return(i) end
	end
end