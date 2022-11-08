#!/usr/bin/python3
import os
import re
import glob
import math
import numpy as np
import subprocess

import option

#structure_file, energy, spec, lmax_mode, lmax, elum, absorbing_atom = option.subroutine.option("input_methanol.txt")
#print("structure_file : ", structure_file)
#print("energy         : ", energy)
#print("spec           : ", spec)
#print("lmax_mode      : ", lmax_mode)
#print("lmax           : ", lmax)
#print("elum           : ", elum)
#print("absorbing_atom : ", absorbing_atom)
#exit()

line_len = 8
#tri_sin = "triplet"

#directorys = glob.glob("0*/")
#directorys = ["0725","0530","0121","0894","0356","0642","0843","0567","0298","0284","0503","0060","0239","0641","0973","0991","0467","0792","0277","0922","0376","0727","0282","0476","0139","0130","0459","0891","0268","0138","0885","0513","0523","0851","0830","0152","0052","0142","0697"]
#directorys = ["0044", "0131", "0152", "0196", "0340", "0351", "0357", "0462", "0476", "0503", "0513", "0523", "0806", "0885", "0922"]
directorys = option.average_torajectry()
root_dir = os.getcwd()
print(directorys)

#output_file = root_dir + "/plane_OH_ang_before.dat"
#f_poa_b = open(output_file, mode = "w")
#output_file = root_dir + "/plane_OH_ang_after.dat"
#f_poa_a = open(output_file, mode = "w")
#output_file = root_dir + "/plane_OH_ang_chenge.dat"
#f_poa_c = open(output_file, mode = "w")
#output_file = root_dir + "/plane_OH_ang.dat"
#f_poa = open(output_file, mode = "w")

line_len = 8
file_list_C = []
file_list_O = []
cmd = "mkdir histogram"
subprocess.run(cmd, shell = True)

for i in range(101):
    filename = "./histogram/STEP" + str(i) + "_O.dat"
    file_list_O.append(open(filename, mode = "w"))
    filename = "./histogram/STEP" + str(i) + "_C.dat"
    file_list_C.append(open(filename, mode = "w"))

width = 5
num   = 180//width
histo_data_O = [[0 for _ in range(num)]for _ in range(101)]
histo_data_C = [[0 for _ in range(num)]for _ in range(101)]
for directory in directorys:
    #os.chdir(directory)
    #cmd = "pwd"
    #subprocess.run(cmd, shell = True)
    fi = directory + "/input/coordinate_rotation3_G.XYZ"
    #cmd = "cp -rp " + fi + " ."
    #subprocess.run(cmd, shell = True)
    print(fi)
    with open(fi, mode = "r")as f:
        lines = f.readlines()
    loop = len(lines)//(line_len+3)
    histogram = [0 for i in range(10)]
    H = [[]for i in range(4)]
    G = [[]for i in range(3)]
    O    = [[] for i in range(loop)]
    C    = [[] for i in range(loop)]
    H[0] = [[] for i in range(loop)]
    H[1] = [[] for i in range(loop)]
    H[2] = [[] for i in range(loop)]
    H[3] = [[] for i in range(loop)]
    G[0] = [[] for i in range(loop)]
    G[1] = [[] for i in range(loop)]
    G[2] = [[] for i in range(loop)]

    H_fromC = [[]for i in range(4)]
    G_fromC = [[]for i in range(3)]
    O_fromC    = [[] for i in range(loop)]
    C_fromC    = [[] for i in range(loop)]
    H_fromC[0] = [[] for i in range(loop)]
    H_fromC[1] = [[] for i in range(loop)]
    H_fromC[2] = [[] for i in range(loop)]
    H_fromC[3] = [[] for i in range(loop)]
    G_fromC[0] = [[] for i in range(loop)]
    G_fromC[1] = [[] for i in range(loop)]
    G_fromC[2] = [[] for i in range(loop)]

    for i in range(loop):
        #title   = lines[1  + i * (line_len + 3)].replace('\n','').split()
        #O[i]    = lines[6  + i * (line_len + 3)].replace('\n','').split()
        C[i]    = lines[2  + i * (line_len + 3)].replace('\n','').split()
        H[0][i] = lines[3  + i * (line_len + 3)].replace('\n','').split()
        H[1][i] = lines[4  + i * (line_len + 3)].replace('\n','').split()
        H[2][i] = lines[5  + i * (line_len + 3)].replace('\n','').split()
        H[3][i] = lines[7  + i * (line_len + 3)].replace('\n','').split()
        #G[0][i] = lines[8  + i * (line_len + 3)].replace('\n','').split()
        #G[1][i] = lines[9  + i * (line_len + 3)].replace('\n','').split()
        #G[2][i] = lines[10 + i * (line_len + 3)].replace('\n','').split()

        #O_fromC    = [O[i][0], O[i][1] - C[i][1], O[i][2] - C[i][2], O[i][3] - C[i][3]]
        C_fromC[i]    = [C[i][0],    float(C[i][1]) - float(C[i][1]), float(C[i][2]) - float(C[i][2]), float(C[i][3]) - float(C[i][3])]
        H_fromC[0][i] = [H[0][i][0], float(H[0][i][1]) - float(C[i][1]), float(H[0][i][2]) - float(C[i][2]), float(H[0][i][3]) - float(C[i][3])]
        H_fromC[1][i] = [H[1][i][0], float(H[1][i][1]) - float(C[i][1]), float(H[1][i][2]) - float(C[i][2]), float(H[1][i][3]) - float(C[i][3])]
        H_fromC[2][i] = [H[2][i][0], float(H[2][i][1]) - float(C[i][1]), float(H[2][i][2]) - float(C[i][2]), float(H[2][i][3]) - float(C[i][3])]
        H_fromC[3][i] = [H[3][i][0], float(H[3][i][1]) - float(C[i][1]), float(H[3][i][2]) - float(C[i][2]), float(H[3][i][3]) - float(C[i][3])]
        #G_fromC[0] = [G[0][i][0], G[0][i][1] - C[i][1], G[0][i][2] - C[i][2], G[0][i][3] - C[i][3]]
        #G_fromC[1] = [G[1][i][0], G[1][i][1] - C[i][1], G[1][i][2] - C[i][2], G[1][i][3] - C[i][3]]
        #G_fromC[2] = [G[2][i][0], G[2][i][1] - C[i][1], G[2][i][2] - C[i][2], G[2][i][3] - C[i][3]]


    
        for j in range(4):
            #print(H[j][i])
            #print(i, j)
            #print(H[j][i][1])
            if float(H[j][i][2]) == 0.0:
                #print("AAAAAAAA")
                x = float(H[j][i][1])
                y = float(H[j][i][3])
                r = math.sqrt(x**2+y**2)
                rad = math.atan2(y, x)
                degree = math.degrees(rad)
                file_list_O[i].write("{}  {}  {}  {}  {}  {}\n".format(directory[:-1] ,H[j][i][1], H[j][i][2], H[j][i][3], r, degree))
                #print(int((degree + 90)//width))
                histo_data_O[i][int((degree + 90)//width)] += 1
                #for tmp in histo_data:
                #    print(tmp)

                x_C = H_fromC[j][i][1]
                y_C = H_fromC[j][i][3]
                r_C = math.sqrt(x_C**2+y_C**2)
                rad_C = math.atan2(y_C, x_C)
                degree_C = math.degrees(rad_C)
                file_list_C[i].write("{}  {}  {}  {}  {}  {}\n".format(directory[:-1] ,H_fromC[j][i][1], H_fromC[j][i][2], H_fromC[j][i][3], r_C, degree_C))
                #print(int((degree + 90)//width))
                histo_data_C[i][int((degree_C + 90)//width)] += 1
                #for tmp in histo_data:
                #    print(tmp)

print("end")
for i in range(101):
    max_histo_data = 10#max(histo_data[i])
    fi = "histogram/STEP" + str(i) + "_histo_O.dat"
    with open(fi, mode = "w")as f:
        for j in range(180):
            #print(j//width)
            if j % width == 0:
            #>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
                f.write("{}  {}\n".format(j - 90, histo_data_O[i][j//width - 1]/max_histo_data))
                f.write("{}  {}\n".format(j - 90, 0))
            f.write("{}  {}\n".format(j - 90, histo_data_O[i][j//width]/max_histo_data))
            #========================================================================
            #    f.write("{}  {}\n".format(math.radians(j - 90), histo_data[i][j//width - 1]))
            #    f.write("{}  {}\n".format(math.radians(j - 90), 0))
            #f.write("{}  {}\n".format(math.radians(j - 90), histo_data[i][j//width]))
            #<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
            #if j % width == width - 1:
            #    if j//width + 1 >= 180//width:
            #        f.write("{}  {}\n".format(j - 90, 0))
            #    else:
            #        f.write("{}  {}\n".format(j - 90, histo_data[i][j//width + 1]))

    fi = "histogram/STEP" + str(i) + "_histo_C.dat"
    with open(fi, mode = "w")as f:
        for j in range(180):
            #print(j//width)
            if j % width == 0:
            #>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
                f.write("{}  {}\n".format(j - 90, histo_data_C[i][j//width - 1]/max_histo_data))
                f.write("{}  {}\n".format(j - 90, 0))
            f.write("{}  {}\n".format(j - 90, histo_data_C[i][j//width]/max_histo_data))
            #========================================================================
            #    f.write("{}  {}\n".format(math.radians(j - 90), histo_data[i][j//width - 1]))
            #    f.write("{}  {}\n".format(math.radians(j - 90), 0))
            #f.write("{}  {}\n".format(math.radians(j - 90), histo_data[i][j//width]))
            #<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
            #if j % width == width - 1:
            #    if j//width + 1 >= 180//width:
            #        f.write("{}  {}\n".format(j - 90, 0))
            #    else:
            #        f.write("{}  {}\n".format(j - 90, histo_data[i][j//width + 1]))

