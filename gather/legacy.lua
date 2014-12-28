--START SCORE DRAW DEFINE
icons = {} --used for berry
texts = {} --texts for berreis
trees = {} --used for tree sprites
grass = {} --holds grass tile behind tree
grass2= {} --holds the grass tile above tree
huts = {} --holds the hut tile beside tree
huts2 = {} --holds the second hut tile
hutRoofs = {} --holds the hut roof tile beside tree
hutRoofs2 = {} --holds the second hut roof tile
sheetsP = {} --used for tree sprite sheets
iconsP = {} --used for poke
textsP = {}	--texts for poke scores
sheetsP = {} --sprite sheets for pokemon
fields = {} -- pokemon field recatngles
fields2 = {}
fences2 = {}
fences = {} --fence rectangles
iconOffset = 16 --will keep the scores from resetting position each time this is run
               --used in button functions
bCursor = 1 -- points to the current element in berry score array
pCursor = firstP -- points to the current element in poke score array
d = 1 --display counter: keeps track of number of displayed icons on screen
iconLimit = 6 -- determines how many icons to display at once (per column)
colorSheet = graphics.newImageSheet( "backs/color.png" , {width=16, height=16, numFrames=880} )
--first, declare functions this score display process will need
---------------------------------------------------------------
--Add a sprite event listener to tell when animations are done
function spriteListener(event)
	--the name of the event corresponds to which tree finished
	local id = event.target.id
	if(event.phase == "loop")then
		--print(event.target.id)
		berryScore[id] = berryScore[id] + 1
	end
end
----------------------------------------------------------
--Now, the actual function that updates and displays scores
--------------------------------------------------------------
local function newScore()
	myRectangle:toFront( )
	yourRectangle:toFront( )
	--turn off the network view
	if isNetworkViewOn == true then isNetworkViewOn = false end

	if(nameField~=nil)then nameField:removeSelf( ); nameField = nil end
	if(teamField~=nil)then teamField:removeSelf( ); teamField = nil end

	--Do BERRY SCORES
	d = 1 --reset counter for berries
	--i goes through all scores from where the cursor is to the end
	for i=bCursor, berrycount do 
		while(d<iconLimit) do			
			local checkScore = i + (d-1) --the id in the score array we are checking
			if(berryScore[checkScore]~=0)then
				name = berries[checkScore]
				if(icons[d] ~= nil) then icons[d]:removeSelf( ) end  --remove if there was one already
				icons[d] = display.newImage("berry/" ..name.. ".png")
				--Scale used to be 0.625 (and the others adjusted accordingly)
				icons[d].xScale = 0.5
				icons[d].yScale = 0.5
				icons[d].x = 0 + icons[d].width*icons[d].xScale + (icons[d].xScale*icons[d].width)
				icons[d].y = ( 2*d - 1 ) * (icons[d].yScale*icons[d].height) + iconOffset
				--For text
				if(texts[d] ~= nil) then texts[d]:removeSelf( ) end
				texts[d] = display.newText( berryScore[checkScore], icons[d].x,
											 icons[d].y -(icons[d].xScale*icons[d].width) , "GungsuhChe", 16)
				-- texts[i]:setFillColor( 1,0.6,0.05  )
				texts[d]:setFillColor( 0.2,0.2,0.6  )

				--For trees
				treeSheet = graphics.newImageSheet("treespace/"..name.."comboS.png",
					{width = 32, height = 32, numFrames=5})
				if(trees[d] ~= nil) then trees[d]:removeSelf( ) end
				trees[d] = display.newSprite(treeSheet, 
					{name=tostring(d), start=1, count=5, time=math.random(7000,20000)})
				trees[d].x = icons[d].x - (icons[d].xScale*icons[d].width)
				trees[d].y = icons[d].y
				trees[d].id = checkScore --berryid number of the tree

				trees[d]:play()

				trees[d]:addEventListener( "sprite", spriteListener )

				--for grass
				if(grass[d]~=nil) then grass[d]:removeSelf() end
				grass[d] = display.newImageRect(colorSheet, 26,16,16)
				grass[d].x = trees[d].x
				grass[d].y = trees[d].y
				grass[d].xScale = 2
				grass[d].yScale = 2
				if(grass2[d]~=nil) then grass2[d]:removeSelf() end
				grass2[d] = display.newImageRect(colorSheet, 126,16,16)
				grass2[d].x = trees[d].x
				grass2[d].y = trees[d].y - (icons[d].xScale*icons[d].width)
				grass2[d].xScale = 2
				grass2[d].yScale = 2

				--for huts
				if(huts[d]~=nil)then huts[d]:removeSelf( ) end
				huts[d] = display.newImageRect(colorSheet, 429,16,16)
				huts[d].x = trees[d].x + (icons[d].xScale*icons[d].width)
				huts[d].y = trees[d].y
				huts[d].xScale = 2
				huts[d].yScale = 2
				if(hutRoofs[d]~=nil)then hutRoofs[d]:removeSelf( ) end
				hutRoofs[d] = display.newImageRect(colorSheet, 377,16,16)
				hutRoofs[d].x = trees[d].x + (icons[d].xScale*icons[d].width)
				hutRoofs[d].y = trees[d].y - (icons[d].xScale*icons[d].width)
				hutRoofs[d].xScale = 2
				hutRoofs[d].yScale = 2
				if(huts2[d]~=nil)then huts2[d]:removeSelf( ) end
				huts2[d] = display.newImageRect(colorSheet, 432,16,16) --maybe tile 310
				huts2[d].x = trees[d].x + 2*(icons[d].xScale*icons[d].width)
				huts2[d].y = trees[d].y
				huts2[d].xScale = 2
				huts2[d].yScale = 2
				if(hutRoofs2[d]~=nil)then hutRoofs2[d]:removeSelf( ) end
				hutRoofs2[d] = display.newImageRect(colorSheet, 380,16,16)
				hutRoofs2[d].x = trees[d].x + 2*(icons[d].xScale*icons[d].width)
				hutRoofs2[d].y = trees[d].y - (icons[d].xScale*icons[d].width)
				hutRoofs2[d].xScale = 2
				hutRoofs2[d].yScale = 2

				--correct order
				trees[d]:toFront( )
				texts[d]:toFront( )
				icons[d]:toFront( )

				d = d + 1 --increment display counter
				--checkScore = checkScore + 1

			else 
				d = d+ 1
			end
		end
	end
	--DO POKE SCORES
	d = 1 --reset counter for berries
	--i goes through all scores from where the ursor is to the end
	for i=pCursor, 400 do 
		while(d<iconLimit) do
			local checkScore = i + (d-1) --the id in the score array we are checking
			if(pokeScore[checkScore]~=0)then
				if(iconsP[d] ~= nil) then iconsP[d]:removeSelf( ) end 
				if(sheetsP[d] ~= nil) then sheetsP[d] = nil end
				sheetsP[d] = graphics.newImageSheet("allcombo/" .. tostring(checkScore) .. "combo.png", {width=32,height=32,numFrames=8})
				--create an array with random numbers for random frame sequence
				iconsP[d] = display.newSprite( sheetsP[d], {name="wildP", start = 1, count = 8, time=math.random(3500,4500)} )
				iconsP[d].xScale = 1
				iconsP[d].yScale = 1
				iconsP[d].x =  4 * iconsP[d].width*iconsP[d].xScale
				--iconsP[i].y = cursor * (iconsP[i].yScale*iconsP[i].height)
				iconsP[d].y = ( 2*d - 1 ) * (iconsP[d].yScale*iconsP[d].height) + iconOffset
				iconsP[d]:play( )

				--For text
				if(textsP[d] ~= nil) then textsP[d]:removeSelf( ) end
				textsP[d] = display.newText( pokeScore[checkScore], iconsP[d].x+(iconsP[d].xScale*iconsP[d].width),
											 iconsP[d].y, "GungsuhChe", 16)
				--textsP[i]:setFillColor( 1,0.05,0.8 )
				textsP[d]:setFillColor( 1,0.8,0.05 )

				--For corrall/fields that go with pokemon
				--if(fields[i] ~= nil) then textsP[i]:removeSelf( ) end
				fields[d] = display.newImageRect(colorSheet, 151, 16,16)
				fields[d].x = iconsP[d].x
				fields[d].y = iconsP[d].y
				fields[d].xScale = 2
				fields[d].yScale = 2
				fields2[d] = display.newImageRect(colorSheet, 567, 16,16)
				fields2[d].x = iconsP[d].x + (fields[d].yScale*fields[d].height)
				fields2[d].y = iconsP[d].y
				fields2[d].xScale = 2
				fields2[d].yScale = 2

				--For fences that go with pokemon
				fences[d] = display.newImageRect(colorSheet, 195 , 16,16)
				fences[d].x = fields[d].x
				fences[d].y = fields[d].y - (fields[d].yScale*fields[d].height)
				fences[d].xScale = 2
				fences[d].yScale = 2
				fences2[d] = display.newImageRect(colorSheet, 195 , 16,16)
				fences2[d].x = fields2[d].x
				fences2[d].y = fields2[d].y - (fields[d].yScale*fields[d].height)
				fences2[d].xScale = 2
				fences2[d].yScale = 2

				--correct order
				iconsP[d]:toFront( )
				textsP[d]:toFront( )

				d=d+1
				--checkScore = checkScore + 1

			else				
				--move on to the next one
				d=d+1
			end

		end
	end
end
--END SCORE DEFINE