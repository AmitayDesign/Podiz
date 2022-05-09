import img2pdf

print("olaaaa")
def convert_jpeg_to_pdf(file):
    file = file.split("/")[1]
    print("converting " + file)
    with open("/pics/{}_output.pdf".format(file[:-4]), "wb") as f:
        f.write(img2pdf.convert(file))

convert_jpeg_to_pdf("pics/photo.jpg")