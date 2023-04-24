from PIL import Image
from math import sqrt
from sys import argv
import os

if len(argv) < 2:
	print(f'''
	Error: please pass in a filename 

	Example: python gif-to-hdgr.py my.gif
''')
	os._exit(-1)

sprite_letter="x"
if len(argv) > 2:
	sprite_letter=argv[2]

# PIL accesses images in Cartesian co-ordinates, so it is Image[columns, rows]
#img = Image.new( 'RGB', (250,250), "black") # create a new black image
img = Image.open(argv[1])
rgb_im = img.convert('RGB')
def distance3d(xyz1, xyz2):
	x1, y1, z1 = xyz1
	x2, y2, z2 = xyz2
	return sqrt((x2 - x1)**2 + (y2 - y1)**2 + (z2 - z1)**2)

colors_main = [
(0,0,0),
(0xDD,0,0x33),
(0,0,0x99),
(0xDD,0,0xDD),
(0,0x77,0),
(0x55,0x55,0x55),
(0x22,0x22,0xFF),
(0x66,0xAA,0xFF),
(0x88,0x55,0x22),
(0xFF,0x66,0),
(0xAA,0xAA,0xAA),
(0xFF,0x99,0x88),
(0,0xDD,0),
(0xFF,0xFF,0),
(0,0xFF,0x99),
(0xFF,0xFF,0xFF)
]


colors_aux = [
(0,0,0),
(0,0,0x99),
(0,0x77,0),
(0x22,0x22,0xFF),
(0x88,0x55,0x22),
(0xAA,0xAA,0xAA),
(0,0xDD,0),
(0,0xFF,0x99),
(0xDD,0,0x33),
(0xDD,0,0xDD),
(0x55,0x55,0x55),
(0x66,0xAA,0xFF),
(0xFF,0x66,0),
(0xFF,0x99,0x88),
(0xFF,0xFF,0),
(0xFF,0xFF,0xFF)
]

def print_hex_bytes_asm(bytes,bytes_per_line):
	c = 0 # col
	for b in bytes:
		if c == 0:
			print(f'  hex {b:02x}', end='')
		else: 
			print(f'{b:02x}', end='')
		c = c + 1
		if c == bytes_per_line:
			print('')
			c = 0

# bytes = []
# for j in range(img.size[1]/2):    # For every other row because we stack them into one GR byte
# 	for i in range(img.size[0]/2):    # for every other col because i'm taking an input image with doubled horizontal pixels
# 		p1 = img.getpixel((i*2,j*2))
# 		p2 = img.getpixel((i*2,(j*2)+1))

# 		nearest_idx1 = colors.index(min(colors, key=lambda x: distance3d(x, p1)))
# 		nearest_idx2 = colors.index(min(colors, key=lambda x: distance3d(x, p2)))
# 		byte = nearest_idx1 + (nearest_idx2*16)
# 		print("{:02x} {} {}".format(byte, nearest_idx1, nearest_idx2))
# 		bytes.append(byte)
# 		#print(nearest_idx)
# 		#img.show()

def get_hdgr_p1_main(image):
	return get_hdgr_chunk(image,True,1)
	bytes = []
	print(f'Size:  {image.size[0]} x {image.size[1]}')
	for j in range(int(image.size[1]/4)):    # For every fourth row because we stack them into one GR byte which is interlaced
		for i in range(int(image.size[0]/2)):    # for every other col because dgr (80 col striping)

			p1 = image.getpixel((i*2,j*4))
			p2 = image.getpixel((i*2,(j*4)+2))
			print(p1,p2)
			print('---------------')

			nearest_idx1 = colors_main.index(min(colors_main, key=lambda x: distance3d(x, p1)))
			nearest_idx2 = colors_main.index(min(colors_main, key=lambda x: distance3d(x, p2)))
			byte = nearest_idx1 + (nearest_idx2*16)
			print("{:02x} {} {}".format(byte, nearest_idx1, nearest_idx2))
			bytes.append(byte)
		#print(nearest_idx)
		#img.show()
	return bytes

def get_hdgr_p2_main(image):
	return get_hdgr_chunk(image,True,2)

def get_hdgr_p1_aux(image):
	return get_hdgr_chunk(image,False,1)

def get_hdgr_p2_aux(image):
	return get_hdgr_chunk(image,False,2)

def get_hdgr_chunk(image, main=True, page=1):
	bytes = []
	# print(f'Size:  {image.size[0]} x {image.size[1]}')
	for j in range(int(image.size[1]/4)):    # For every fourth row because we stack them into one GR byte which is interlaced
		for i in range(int(image.size[0]/2)):    # for every other col because dgr (80 col striping)
			if main:
				x_offset = 1
			else:
				x_offset = 0
			if page == 1:
				y_offset = 1
			else:
				y_offset = 0
			p1 = image.getpixel(((i*2)+x_offset,(j*4)+y_offset))
			p2 = image.getpixel(((i*2)+x_offset,(j*4)+2+y_offset))

			if main:
				nearest_idx1 = colors_main.index(min(colors_main, key=lambda x: distance3d(x, p1)))
				nearest_idx2 = colors_main.index(min(colors_main, key=lambda x: distance3d(x, p2)))
			else:
				nearest_idx1 = colors_aux.index(min(colors_aux, key=lambda x: distance3d(x, p1)))
				nearest_idx2 = colors_aux.index(min(colors_aux, key=lambda x: distance3d(x, p2)))
			byte = nearest_idx1 + (nearest_idx2*16)
			# print("{:02x} {} {}".format(byte, nearest_idx1, nearest_idx2))
			bytes.append(byte)
		#print(nearest_idx)
		#img.show()
	return bytes
bytes = get_hdgr_p1_main(rgb_im)


print("\n\n\n")
print(f'HDGR{sprite_letter}_P1_MAIN')
print_hex_bytes_asm(get_hdgr_p1_main(rgb_im),40)
print("\n\n\n")
print(f'HDGR{sprite_letter}_P1_AUX')
print_hex_bytes_asm(get_hdgr_p1_aux(rgb_im),40)
print("\n\n\n")
print(f'HDGR{sprite_letter}_P2_MAIN')
print_hex_bytes_asm(get_hdgr_p2_main(rgb_im),40)
print("\n\n\n")
print(f'HDGR{sprite_letter}_P2_AUX')
print_hex_bytes_asm(get_hdgr_p2_aux(rgb_im),40)
# newFile = open("out.GR", "wb")
# newFileByteArray = bytearray(bytes)
# newFile.write(newFileByteArray)

	#    '000000' => 0,  // black
	#    'dd0033' => 1,  // red
	#    '000099' => 2,  // dk blue
	#    'dd00dd' => 3,  // purple
	#    '007700' => 4,  // dk green
	#    '555555' => 5,  // dk grey
	#    '2222ff' => 6,  // blue
	#    '66aaff' => 7,  // lt blue
	#    '885522' => 8,  // brown
	#    'ff6600' => 9,  // orange
	#    'aaaaaa' => 10, // lt grey
	#    'ff9988' => 11, // peach
	#    '00dd00' => 12, // green
	#    'ffff00' => 13, // yellow
	#    '00ff99' => 14, // lt green
	#    'ffffff' => 15  // white

#    '000000' => 0,  // black
#    '000099' => 1,  // dk blue
#    '007700' => 2,  // dk green
#    '2222ff' => 3,  // blue
#    '885522' => 4,  // brown
#    'aaaaaa' => 5,  // lt grey
#    '00dd00' => 6,  // green
#    '00ff99' => 7,  // lt green
#    'dd0033' => 8,  // red
#    'dd00dd' => 9,  // purple
#    '555555' => 10, // dk grey
#    '66aaff' => 11, // lt blue
#    'ff6600' => 12, // orange
#    'ff9988' => 13, // peach
#    'ffff00' => 14, // yellow
#    'ffffff' => 15  // white


