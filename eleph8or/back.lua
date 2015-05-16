Back = {}
Back.__index = Back

function Back.new(width, height)
	local self = setmetatable( {}, Back)
	self.width = width --of screen
	self.height = height -- of screen
	self.numPlats = 6 --number of platforms
	--self.platGroup = display.newGroup( )

	self.back1 = display.newImage("misc/cityBIG.png");
	self.back1.x = width/2
	self.back1.y = height/2
	self.back1.xScale = (width/self.back1.width)
	self.back1.yScale = (height/self.back1.height)

	self.back2 = display.newImage("misc/cityBIG.png");
	self.back2.xScale = (width/self.back2.width)
	self.back2.yScale = (height/self.back2.height)
	self.back2.x = (width/2) - (self.back2.width*self.back2.xScale)
	self.back2.y = height/2

	self.fore = display.newImage("misc/tree.png");
	self.fore.x = width/2
	self.fore.y = height/2
	self.fore.xScale = (width/self.fore.width)
	self.fore.yScale = (height/self.fore.height)

	--platforms
	self.platforms = {}
	for i=1,self.numPlats do
		self.sheet = graphics.newImageSheet( "misc/platform2.png", {width=64, height=8, numFrames=2} )
		self.platforms[i] = display.newSprite(self.sheet, {name="plat", start = 1, count = 2, time = 1000} )
		self.sheet = nil
		self.platforms[i].xScale = (2*width)/(3*self.platforms[i].width)
		self.platforms[i].yScale = scale
		if(i%2 == 0)then
			self.platforms[i].x = self.width/3
		else
			self.platforms[i].x = 2 * self.width/3
		end
		self.platforms[i].y = i * (self.height/self.numPlats)
		self.platforms[i]:play( )
	end

	return self

end

function Back.move(self)
	self.back1.x = self.back1.x + scale
	self.back2.x = self.back2.x + scale
	if(self.back1.x > (self.width/2)+(self.back1.width*self.back1.xScale))then
		self.back1.x = (self.width/2) - (self.back1.width*self.back1.xScale) + scale
	end
	if(self.back2.x > (self.width/2)+(self.back2.width*self.back2.xScale))then
		self.back2.x = (self.width/2) - (self.back2.width*self.back2.xScale) + scale
	end
end

--Resets the position of the platforms
function Back.resetPlatforms(self)
	for i=1,self.numPlats do	
		if(i%2 == 0)then
			self.platforms[i].x = self.width/3
		else
			self.platforms[i].x = 2 * self.width/3
		end
		self.platforms[i].y = i * (self.height/self.numPlats)
	end
end
