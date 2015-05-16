-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------
local widget = require("widget")

local baseline = 280
local i = math.random( 400)
local centerX = display.contentCenterX
local centerY = display.contentCenterY
local _W = display.contentWidth --480
local _H = display.contentHeight --320

local myRectangle = display.newRect(display.contentCenterX,display.contentCenterY, _W, _H) -- rectWidth, _H)
myRectangle:setFillColor( 0,0,0 )

myMap = native.newMapView( 3*_W/4, _H/4,240,160)

myRectangle:toFront( )

--GPS SHIT
local attempts = 0
local locationText = display.newText( "Location: ", 0, 400, native.systemFont, 16 )
locationText.anchorY = 0
locationText.x = display.contentCenterX
locationText.y = display.contentCenterY + 50
long = 0 --global to keep track of longitude
lat = 0 --global to keep track of latitiude
local function locationHandler( event )

    local currentLocation = myMap:getUserLocation()

    if ( currentLocation.errorCode or ( currentLocation.latitude == 0 and currentLocation.longitude == 0 ) ) then
        locationText.text = currentLocation.errorMessage

        attempts = attempts + 1

        if ( attempts > 10 ) then
            print("no gps")
        else
            timer.performWithDelay( 1000, locationHandler )
        end
    else
        locationText.text = "Current location: " .. currentLocation.latitude .. "," .. currentLocation.longitude
        myMap:setCenter( currentLocation.latitude, currentLocation.longitude )
  		long = currentLocation.longitude
  		lat = currentLocation.latitude
        --myMap:addMarker( currentLocation.latitude, currentLocation.longitude )
    end
end
locationHandler()

-- local object = display.newImage( "ball.png" )
-- object.id = "ball object"
-- object.x = display.contentCenterX + 50
-- local function onObjectTouch( event )
--     locationHandler()
--     return true
-- end
-- object:addEventListener( "touch", onObjectTouch )

--MenusAND PICS
whatto = display.newImage( "misc/whatto.png" );
whatto.x = display.contentCenterX
whatto.y = 80
readrage = display.newImage( "misc/readrage.png");
readrage.x = _W/4
readrage.y = 220
makepost = display.newImage( "misc/makepost.png" );
makepost.x = 3 * _W/4
makepost.y = 220
mappost = display.newImage("misc/mapPost.png");
mappost.x = _W/4
mappost.y = 80

--ADD BUTTON STUFF
--Function to handle button
downTimer = 0 --timer to prevent rapid button press 
local function handleListButtonEvent(event)
	--Return and do nothing if enough time hasn't passed
	print("Need to generate and list previous posts here")
	menuState = 1
	downTimer = event.time --reset the timer 
end
local button1 = widget.newButton{
	width = 32,
	height = 32,
	defaultFile = "misc/rdButton.png",
	overFile = "misc/rdButton.png",
	onEvent = handleListButtonEvent
}
button1.x = _W/4
button1.y = _H - 20
local function handlePostButtonEvent(event)
	--Return and do nothing if enough time hasn't passed
	print("Need to enable posting to server here")
	menuState = 2
	downTimer = event.time --reset the timer 
end
local button2 = widget.newButton{
	width = 32,
	height = 32,
	defaultFile = "misc/gnButton.png",
	overFile = "misc/gnButton.png",
	onEvent = handlePostButtonEvent
}
button2.x = 3 * _W/4
button2.y = _H - 20




menuState = 0 --menu system:
				--0: menu screen
				--1: list posts
				--2: make post
local function move(event)

	--hey = moveBerry(event)
	i = 1;
	locationHandler()
	--print(long)
	--print(lat)
	--myRectangle:toFront( )
	--locationText:toFront( )
	--MENU
	if (menuState == 0) then 
		myRectangle:toFront( )
		whatto:toFront( )
		readrage:toFront( )
		makepost:toFront( )
		button1:toFront()
		button2:toFront()
	--LIST
	elseif (menuState == 1) then
		myRectangle:toFront( )
		mappost:toFront( )
		locationText:toFront( )
	--POST
	elseif (menuState == 2) then
		myRectangle:toFront( )
	end

end

Runtime:addEventListener( "enterFrame", move);