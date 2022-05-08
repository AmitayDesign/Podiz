import win32com.client
import os
import sys, getopt

def convert_pdf_to_word(input_file):
    word = win32com.client.Dispatch("word.Application")
    word.visible = 0

    input_file = os.path.abspath(arg)

    wb = word.Documents.Open(input_file)
    output_file = os.path.abspath(arg[0, -4] + "docx".format())
    wb.SaveAs2(output_file, FileFormat = 16)

    print("Pdf to Word is completed")

    wb.Close()

    word.Quit()
    
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
        convert_pdf_to_word(inputfile)

if __name__ == "__main__":
    main(sys.argv[:1])