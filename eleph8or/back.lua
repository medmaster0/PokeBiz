--Use nearest neighbor for scaling
display.setDefault( magTextureFilter, nearest )
display.setDefault( minTextureFilter, nearest )

Back = {}
Back.__index = Back

function Back.new(width, height)
	local self = setmetatable( {}, Back)
	self.width = width --of screen
	self.height = height -- of screen
	self.numPlats = 6 --number of platforms
	--self.platGroup = display.newGroup( )

	self.back1 = display.newImage("misc/cityBIG2.png");
	self.back1.x = width/2
	self.back1.y = height/2
	self.back1.xScale = (width/self.back1.width)
	self.back1.yScale = (height/self.back1.height)

	self.back2 = display.newImage("misc/cityBIG2.png");
	self.back2.xScale = (width/self.back2.width)
	self.back2.yScale = (height/self.back2.height)
	self.back2.x = (width/2) - (self.back2.width*self.back2.xScale)
	self.back2.y = height/2

	--Take care of building in foreground
	-- self.red = 0.462
	-- self.green = 0.043
	-- self.blue = 0
	self.red = math.random( )
	self.green = math.random( )
	self.blue = math.random(  )

	self.fore = display.newGroup( )
	self.forePRIM = display.newImage("misc/buildingPRIM.png");
	self.forePRIM.xScale = (width/self.forePRIM.width)
	self.forePRIM.yScale = (height/self.forePRIM.height)
	self.fore:insert( self.forePRIM )
	self.fore["forePRIM"] = self.forePRIM
	self.foreWIND = display.newImage("misc/buildingWIND.png");
	self.foreWIND.xScale = (width/self.foreWIND.width)
	self.foreWIND.yScale = (height/self.foreWIND.height)
	self.fore:insert( self.foreWIND )
	self.fore["foreWIND"] = self.foreWIND
	self.fore.x = width/2
	self.fore.y = height/2
	self.fore.forePRIM:setFillColor( self.red, self.green, self.blue )

	self.fore2 = display.newGroup( )
	self.fore2PRIM = display.newImage("misc/buildingPRIM.png");
	self.fore2PRIM.xScale = (width/self.fore2PRIM.width)
	self.fore2PRIM.yScale = (height/self.fore2PRIM.height)
	self.fore2:insert( self.fore2PRIM )
	self.fore2["fore2PRIM"] = self.fore2PRIM
	self.fore2WIND = display.newImage("misc/buildingWIND.png");
	self.fore2WIND.xScale = (width/self.fore2WIND.width)
	self.fore2WIND.yScale = (height/self.fore2WIND.height)
	self.fore2:insert( self.fore2WIND )
	self.fore2["fore2WIND"] = self.fore2WIND
	self.fore2.x = width/2
	self.fore2.y = self.fore.y + self.foreWIND.height*self.foreWIND.yScale
	self.fore2.fore2PRIM:setFillColor( self.red, self.green, self.blue )

	self.HALF_HEIGHT = self.forePRIM.height*self.forePRIM.yScale/2 -- a value that comes up a lot for scaling/scrolling

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
	self.back1.x = self.back1.x + scale/2
	self.back2.x = self.back2.x + scale/2
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

--Fore goes up
function Back.foreScrollUp(self, scrollOffset)
	self.fore.y = self.fore.y - scrollOffset
	self.fore2.y = self.fore2.y - scrollOffset

	if(self.fore.y+(self.HALF_HEIGHT) < 0)then 
		self.fore.y = self.fore2.y+self.fore2PRIM.height*self.fore2PRIM.yScale 
		self.fore.xScale = -1*self.fore.xScale
		self:foreFillInc(self.fore.forePRIM)
	end
	if(self.fore2.y+(self.HALF_HEIGHT) < 0)then
		self.fore2.y = self.fore.y+self.forePRIM.height*self.forePRIM.yScale 
		self.fore2.xScale = -1*self.fore2.xScale
		self:foreFillInc(self.fore2.fore2PRIM)
	end
end

--Fore goes Down
function Back.foreScrollDown(self, scrollOffset)
	self.fore.y = self.fore.y + scrollOffset
	self.fore2.y = self.fore2.y + scrollOffset

	if(self.fore.y-(self.HALF_HEIGHT) > self.height)then 
		self.fore.y = self.fore2.y-self.fore2PRIM.height*self.fore2PRIM.yScale
		self.fore.xScale = -1*self.fore.xScale
		self:foreFillInc(self.fore.forePRIM)	 
	end
	if(self.fore2.y-(self.HALF_HEIGHT) > self.height)then 
		self.fore2.y = self.fore.y-self.forePRIM.height*self.forePRIM.yScale 
		self.fore2.xScale = -1*self.fore2.xScale	
		self:foreFillInc(self.fore2.fore2PRIM)	
	end
end

--Function that will slightly change the fill color
function Back.foreFillInc(self, fore)
	local increment = 0.05 --how much to change the color values by
	local rand = math.random() --chooses whether we inc or dec a color value
	local rand2 = math.random(0,3) --chooses which color we change
	if rand < 0.5 then
		if rand2 < 1 then
			--print("change red")
			self.red = self.red - increment
			if(self.red < 0 ) then self.red = 0 end
		elseif rand2 < 2 then
			--print("change green")
			self.green = self.green - increment
			if(self.green < 0 ) then self.green = 0 end
		elseif rand2 < 3 then
			--print("change blue")			
			self.blue = self.blue - increment
			if(self.blue < 0 ) then self.blue = 0 end
		end
	else
		if rand2 < 1 then
			--print("change red")
			self.red = self.red + increment
			if(self.red > 1 ) then self.red = 1 end
		elseif rand2 < 2 then
			--print("cahnge free")
			self.green = self.green + increment
			if(self.green > 1 ) then self.green = 1 end
		elseif rand2 < 3 then
			--print("change bleo")
			self.blue = self.blue + increment
			if(self.blue > 1 ) then self.blue = 1 end
		end
	end
	fore:setFillColor( self.red,self.green,self.blue )

end