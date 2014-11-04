--Wild Pokemon stuff
pokeScore = {}
for i=1, 400 do pokeScore[i] = 0 end

--EGG STUFF
local eggFile = io.open( "eggs/eggsID.txt" , "r")
io.input( eggFile )
local eggDex = {} --dictionary of eggs: {egg ID, [list of pokeIDS]
local eggString --this will hold the strings from file temporarily
local matches = {} -- this will hold the matches
for i = 1, 209 do --how many lines to read
	matches = {}
	eggString = io.read()
	for word in string.gmatch(eggString, "%d+") do 
		table.insert( matches, tonumber(word) )
	end
	eggDex[i]=matches
end
print(eggDex[58][9])
for i=1, 209 do
	for j=1, 9 do
		--print(eggDex[i][j])
	end
end
eggFile:close()
--make reverse egg file
local eggPath = system.pathForFile( "revEggsID.txt",system.DocumentsDirectory )
eggFile=io.open(eggPath, "w")
for i=1,400 do
	for k=1,209 do
		for j=1,9 do
			print(i)
			if (eggDex[k][j]==i) then
				--print(tostring(i) .. ":" .. tostring(k) .. "\r\n")
				eggFile:write(tostring(i) .. ":" .. tostring(k) .. "\r\n") 	
			end 
		end
	end
end
io.close(eggFile)