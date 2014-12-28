from urllib import urlretrieve
import re

#url = "http://pokefarm.wikia.com/wiki/Eggs"
#newpng = "1.png"
#urlretrieve(url, newpng)

f=open('1.txt','r')
strings = re.findall(r'http://img[0-9]*.wikia.nocookie.net/__cb[0-9]*/pokefarm/images/[0-9a-fA-F]*/[0-9a-fA-F]*/[^ \t\n\r\f\v]*.png', f.read())

print strings
i = 0

for url in strings:
	if i % 3 == 0: #only do every third one
		newpng = str((i/3) + 1) + '.png'
		print 'getting' + url
		urlretrieve(url, newpng)
	i = i + 1