import re, os

i = 0

for name in os.listdir('.'):
    i = i+1
    print name
    os.rename(name, str(i)+".png")
