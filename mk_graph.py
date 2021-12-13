#!/usr/bin/python3
import os
import re
import subprocess

convert_cmd = "convert"
convert_cmd = "/opt/imagemagick/7.1.0-17/magick"

dir_root = os.getcwd()
p = re.compile(".*/(.*)_.*")
res = p.search(dir_root)
print(res.group(1))
if res.group(1) == "C":
    #C
    width = 500
    hight = 700
    x     = 530
    y     = 200
elif res.group(1) == "O":
    #O
    width = 500
    hight = 700
    x     = 530
    y     = 50
crop_range = str(width) + "x" + str(hight) + "+" + str(x) + "+" + str(y)

dir_name = "tmp"
if not os.path.exists(dir_name):
    os.mkdir(dir_name)
STEP = [0, 5, 10, 15, 20, 25, 30]
png_list = []
for i in STEP:
    i_03d = "{:03d}".format(i)
    output = dir_name + "/crop_" + i_03d + ".png"
    png_list.append(output)
    cmd = convert_cmd + " convert -density 300 -crop " + crop_range+ " 2d-png/STEP-" + i_03d + ".png " + output
    print(cmd)
    subprocess.run(cmd, shell = True)
#os.chdir(dir_name)
cmd = convert_cmd + " convert -density 300 +append " + " ".join(png_list) + " " + dir_name + "/output.png"
print(cmd)
subprocess.run(cmd, shell = True)

