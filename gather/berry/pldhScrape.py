from urllib import urlretrieve
import urllib2
import re


def isValid(url):
    try:
        urllib2.urlopen(url)
        return True
    except:
        return False

#Create berry list from text file
p = re.compile('([\d]*)\s([\w]*)\sBerry')
f = open('listdata.txt', 'r')
writefile = open('list.txt', 'w')
for line in f:
    matchObj = re.match('([\d]*)\s([\w]*)\sBerry',line)
    if matchObj:
        print matchObj.group(2)
        writefile.write(matchObj.group(2) + '\n')

writefile.close()
##        for i in range(16):
##            for j in range(16):
##                preurl = "http://cdn.bulbagarden.net/upload/%x/%x%x/Tag" + matchObj.group(2)+ ".png"
##                url = preurl % (i, i, j)
##                print url
##                if isValid(url):    
##                    newpng = matchObj.group(2) + ".png"
##                    urlretrieve(url, newpng)
##                else:
##                    print "failed"
##                    continue

###iterate through list of each pokemon, url pldh.net/dex/sprites/<NAME>
##for x in range(1, 493):
##    #download image url pldh.net/media/pokemon/gen4/overworld/rightf2/<NUMBER1-493>.png
##    print "retrieving " + str(x)
##    url = "http://pldh.net/media/pokemon/gen4/overworld/right/%03d.png" % x
##    newpng = str(x) + "right.png"
##    urlretrieve(url, newpng)
##    url = "http://pldh.net/media/pokemon/gen4/overworld/rightf2/%03d.png" % x
##    newpng = str(x) + "right2.png"
##    urlretrieve(url, newpng)
##    url = "http://pldh.net/media/pokemon/gen4/overworld/left/%03d.png" % x
##    newpng = str(x) + "left.png"
##    urlretrieve(url, newpng)
##    url = "http://pldh.net/media/pokemon/gen4/overworld/leftf2/%03d.png" % x
##    newpng = str(x) + "left2.png"
##    urlretrieve(url, newpng)
##    url = "http://pldh.net/media/pokemon/gen4/overworld/front/%03d.png" % x
##    newpng = str(x) + "front.png"
##    urlretrieve(url, newpng)
##    url = "http://pldh.net/media/pokemon/gen4/overworld/frontf2/%03d.png" % x
##    newpng = str(x) + "front2.png"
##    urlretrieve(url, newpng)
##    url = "http://pldh.net/media/pokemon/gen4/overworld/back/%03d.png" % x
##    newpng = str(x) + "back.png"
##    urlretrieve(url, newpng)
##    url = "http://pldh.net/media/pokemon/gen4/overworld/backf2/%03d.png" % x
##    newpng = str(x) + "back2.png"
##    urlretrieve(url, newpng)
##
##    


	
