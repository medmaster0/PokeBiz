
-- function checkCol(body1,body2)
-- 	if(body1.)

-- end

--A collision detction function to see if creature lands on platform
function checkLand(cre, plat)
	if(cre.group.y < plat.y+1.5*plat.height*plat.yScale) and (cre.group.y > plat.y-1.5*plat.height*plat.yScale)
	and (cre.group.x > plat.x-plat.width*plat.xScale/2) and (cre.group.x < plat.x+plat.width*plat.xScale/2) then

		--if cre is going down
		if(cre.vy > 0 ) then 
			return 1
		--if cre is going up
		else 
			return 2
		end

	end

	return 0

end