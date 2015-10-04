Egg = {}
Egg.__index = Egg

function Egg.new(width,height)
	local self = setmetatable( {}, Egg )
	self.width = width --of screen
	self.height = height -- of screen
	local yScale = scale*0.85 --squash it down a bit

	--HERE BEGINS DISPLAYS STUFF
	self.group = display.newGroup( ) --display group to hold all the pieces

	--take care of prim
	self.prim = display.newImage( "group/eggPrim.png" );
	self.prim.xScale = scale
	self.prim.yScale = yScale
	self.group:insert( self.prim )
	self.group["prim"]= self.prim
	self.group.prim:setFillColor( 0.2,0.2,0.9 )

	--take care of seco
	self.seco = display.newImage( "group/eggSeco.png" );
	self.seco.xScale = scale
	self.seco.yScale = yScale
	self.group:insert( self.seco )
	self.group["seco"]= self.seco
	self.group.seco:setFillColor( 0.4,0.9,0.7 )

	-- Other Shit
	self.group.x = width/2
	self.group.y = 3*height/4 

	return self
end
