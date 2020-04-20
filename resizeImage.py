import argparse
from PIL import Image

parser = argparse.ArgumentParser()
parser.add_argument("-i", "--image",
                    help="image path")
parser.add_argument("-x", "--xPixelNo", type=int,
                    help="x pixel no.")
parser.add_argument("-y", "--yPixelNo", type=int,
                    help="y pixel no.")
args = parser.parse_args()


img = Image.open(args.image)
(w, h) = img.size
print('w=%d, h=%d', w, h)
img.show()

new_img = img.resize((args.xPixelNo, args.yPixelNo))
new_img.show()
newFileName = 'untitled-' + str(args.xPixelNo) + 'x' + str(args.yPixelNo) + '.jpg'
print(newFileName)
new_img.save(newFileName)
