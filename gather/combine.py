import Image

for i in range(1,10):

    
    image1 = Image.open("C:\\Users\\Anthony\\Documents\\Corona Projects\\ribbon\\shiny_right\\1.png")
    image2 = Image.open("shiny_rightf2\\1.png")

    blank_image = Image.open("blank.png")
    blank_image.paste(image1, (0,0))
    blank_image.paste(image2, (32,0))
    blank.image.save(str(i) + "combo.png")
