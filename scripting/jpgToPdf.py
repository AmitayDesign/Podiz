import img2pdf
import sys, getopt

def convert_jpeg_to_pdf(file):
     with open("output.pdf", "wb") as f:
        f.write(img2pdf.convert(filepath))

def main(argv):
    inputfile = ''
    try:
        opts, args = getopt.getopt(argv,"hi:o:",["ifile="])
    except getopt.GetoptError:
        print*'test.py -n <name>'
        sys.exit(2)
    for opt, arg in opts:
        if opt == '-h':
            print('test.py -n <name>')
            sys.exit()
        elif opt in ("-n", "--name"):
            inputfile = arg
    
    if(inputfile != '' ):
        convert_jpeg_to_pdf(inputfile)

if __name__ == "__main__":
    main(sys.argv[:1])
   