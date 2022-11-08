#!/usr/bin/python3
import os
import re
import sys
import glob
import subprocess

import option

#directorys = glob.glob("0*/")

xyz_line = 8

directorys = option.average_torajectry()

root_dir = os.getcwd()
#absort_atom_li = ["O", "C"]
absort_atom_li = ["C"]
energy_li      = ["100", "500", "2500"]
elum_diff      = 248
#0052/C_100eV/plot-data/STEP0.dat
directorys.sort()
print(directorys)
#exit()
atom = [0 for _ in range(len(directorys))]
atom_ave   = [[[0 for _ in range(3)] for _ in range(6)] for _ in range(100)]
step_count = [0 for i in range(100)]
for i, directory in enumerate(directorys):
    fi = directory + "/" + "input/coordinate_rotation3.XYZ"
    with open(fi, mode = "r") as f:
        lines = f.readlines()
    step = len(lines)//xyz_line
    atom[i] = [[0 for _ in range(6)] for _ in range(step)]
    for j in range(step):
        step_count[j] += 1
        atom[i][j][0] = lines[j * 8 + 2].replace('\n','').split()
        atom[i][j][1] = lines[j * 8 + 3].replace('\n','').split()
        atom[i][j][2] = lines[j * 8 + 4].replace('\n','').split()
        atom[i][j][3] = lines[j * 8 + 5].replace('\n','').split()
        atom[i][j][4] = lines[j * 8 + 6].replace('\n','').split()
        atom[i][j][5] = lines[j * 8 + 7].replace('\n','').split()
    #if i == 8:
    #    for j in range(step):
    #        for k in range(6):
    #            print(directory, i, j, atom[i][j][k])

#print(atom)
print(directorys)
exit()
for i in range(1):
    check_step = glob.glob(directory +"/" + absort_atom + "_" + energy + "eV/" + "STEP*/")
    #print(check_step)
    #exit()
    num = 0
    for check in check_step:
        #print(check)
        p = re.compile(".*STEP(.*)/")
        res = p.match(check)
        #print(res.group(1))
        step = int(res.group(1))
        if num < step:
            num = step
    for i in range(num + 1):
        count_read[i] += 1 
        open_file = directory + "/" + absort_atom + "_" + energy + "eV/" + "plot-data/STEP" + str(i) + ".dat" 
        print(open_file)
        with open(open_file, mode = "r") as f:
            lines = f.readlines()
        count = 0
        for line in lines:
            line = line.rstrip()
            data = line.split()
            #print(data)
            #print(line)
            if data == []:
                continue
            #print(ave_data[i][count])
            ave_data[i][count][0] = data[0]
            ave_data[i][count][1] = data[1]
            ave_data[i][count][2] += ((float(data[2]) + float(data[5]) + float(data[8])) / 3.0)
            #print(float(data[2]), float(data[5]), float(data[8]))
            #print(float(data[2]) + float(data[5]) + float(data[8]))
            #print(((float(data[2]) + float(data[5]) + float(data[8]))/3.0))
            #print(ave_data[i][count][0], ave_data[i][count][1], ave_data[i][count][2])
            #print(ave_data[i][count])
            count += 1
    for i in range(101):
        #print(ave_data[i][0])
        if count_read[i] != 0:
            print((ave_data[i][0][2]) / count_read[i])
        print(count_read[i])

#ave_data = [[list(range(3)) for i in range(181*361)] for i in range(101)]
#count_read = list(range(1,102))
#os.mkdir("./pamfpad_ave/")
#os.mkdir("./pamfpad_ave/" + absort_atom + "_" + energy + "eV")
#os.mkdir("./pamfpad_ave/" + absort_atom + "_" + energy + "eV/plot-dat/")
cmd = "mkdir -p " + "./" + absort_atom + "_" + energy + "eV/plot-data/"
print(cmd)
subprocess.run(cmd, shell=True)
for i in range(101):
    open_file = "./" + absort_atom + "_" + energy + "eV/plot-data/STEP" + str(i) + ".dat"
    with open(open_file, mode = "w") as f:
        count = 0
        for j in range(181):
            for k in range(361):
                #print(ave_data[i][count][0], ave_data[i][count][1], ave_data[i][0][2] / count_read[i])
                print(i, count)
                f.write("{0:}  {1:}  {2:}\n".format(ave_data[i][count][0], ave_data[i][count][1], (ave_data[i][count][2]/count_read[i])))
                count += 1
            f.write("\n")





