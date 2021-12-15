#!/usr/bin/python3
import os
import re
import subprocess

IM = "convert"
IM = "/opt/imagemagick/7.1.0-17/magick"

dir_root = os.getcwd()
p = re.compile(".*/(.*)_(.*)eV")
res = p.findall(dir_root)
print(res)
atom = res[0][0]
energy = res[0][1]
#print(energy)
#exit()
dir_name = "tmp"
font = "" 
if not os.path.exists(dir_name):
    os.mkdir(dir_name)
STEP = [0, 5, 10, 15, 20, 25, 30]

if atom == "C":
    #C
    width = 700
    hight = 800
    x     = 480
    y     = 100
elif atom == "O":
    #O
    width = 700
    hight = 800
    x     = 480
    y     = 100
crop_range = str(width) + "x" + str(hight) + "+" + str(x) + "+" + str(y)

linewidth = 5

cmd = IM + " convert -size " + str(width) + "x" + "100 xc:white " + dir_name + "/white.png"
print(cmd)
subprocess.run(cmd, shell = True)


png_list = []
cnt = 0
for i in STEP:
    i_03d = "{:03d}".format(i)
    output = dir_name + "/crop_" + i_03d + ".png"
    png_list.append(output)


    ####  make label (** fs)
    #cmd = IM + " convert -font "+font+" -gravity center -pointsize 32 -fill brack -draw \"text 0,0 " + str(i) + " fs\" " + dir_name + "/white.png" + "label.png"
    cmd = IM + " convert -gravity center -pointsize 100 -fill black -annotate 0 \"" + str(i) + " fs\" " + dir_name + "/white.png " + dir_name + "/label.png"
    print(cmd)
    subprocess.run(cmd, shell = True)

    #### label set border
    cmd = IM + " convert " + dir_name + "/label.png -bordercolor black -border " + str(linewidth/2) + "x" + str(linewidth/2) + " " + dir_name + "/label.png"
    print(cmd)
    subprocess.run(cmd, shell = True)

    ### crop 2d-pamfpad
    cmd = IM + " convert -density 300 -crop " + crop_range+ " 2d-png/STEP-" + i_03d + ".png " + output
    print(cmd)
    subprocess.run(cmd, shell = True)
    

    if energy == "100":
        abc = "a"
    elif energy == "500":
        abc = "b"
    elif energy == "2500":
        abc = "c"
    print(abc)
    if cnt == 0:
        ### draw text atom and energy
        cmd = IM + " convert -gravity NorthWest -pointsize 100 -fill black -annotate 0 \" ("+abc+") E = " + energy + " eV\" " + dir_name + "/white.png " + dir_name + "/atom_energy.png"
        print(cmd)
        subprocess.run(cmd, shell = True)

        cmd = IM + " convert -append " + dir_name + "/atom_energy.png " + output + " " + output
        print(cmd)
        subprocess.run(cmd, shell = True)
    else:
        ### append white and 2d-pamfpad
        cmd = IM + " convert -append " + dir_name + "/white.png " + output + " " + output
        print(cmd)
        subprocess.run(cmd, shell = True)

    ### 2d-pamfpad set boeder
    cmd = IM + " convert " + output +  " -bordercolor black -border " + str(linewidth/2) + "x" + str(linewidth/2) + " "  + output
    print(cmd)
    subprocess.run(cmd, shell = True)

    if energy == "100":
        ### append label and 2d-pamfpad
        cmd = IM + " convert -append " + dir_name + "/label.png " + output + " " + output
        print(cmd)
        subprocess.run(cmd, shell = True)

    
    cnt += 1

#os.chdir(dir_name)
### appned all 2d-pamfpad
cmd = IM + " convert -density 300 +append " + " ".join(png_list) + " " + dir_name + "/output.png"
print(cmd)
subprocess.run(cmd, shell = True)


### all png set border
#cmd = IM + " convert " + dir_name + "/output.png -bordercolor black -border " + str(linewidth/2) + "x" + str(linewidth/2) + " "  + dir_name + "/output.png"
#print(cmd)
#subprocess.run(cmd, shell = True)
##convert -background white -fill blue -font aquafont.ttf -pointsize 32 label:penlabo.net text1.png
