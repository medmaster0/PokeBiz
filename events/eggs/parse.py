f=open('copy.txt','r')
lines = f.readlines()
lines = [line for line in lines if line.strip()] #remove blank lines
print lines[0]

fout = open('names.txt', 'w')
nIndex = 1
while True:
    fout.write(lines[nIndex] + "\n\r")
    nIndex = nIndex + 4