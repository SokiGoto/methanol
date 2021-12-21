#!/usr/bin/python3
import os
import re
import glob
import numpy as np
import subprocess

import option

line_len = 8

root_dir = os.getcwd()
p = re.compile(".*/([singlet|triplet].*)/.*")
res = p.findall(root_dir)
tri_sin = res[0]

cmd = "mkdir -p " + root_dir + "/move_h_xyz/"
subprocess.run(cmd, shell=True)
cmd = "mkdir -p " + root_dir + "/input/"
subprocess.run(cmd, shell=True)
cmd = "mkdir -p " + root_dir + "/n_OH_ang/"
subprocess.run(cmd, shell=True)
cmd = "mkdir -p " + root_dir + "/HOH_ang/"
subprocess.run(cmd, shell=True)

#input_para = option.input_parameter()
#exit()
files = option.average_torajectry()
print(files)

output_file = root_dir + "/n_OH_ang/plane_OH_ang_before.dat"
f_poa_b = open(output_file, mode = "w")
output_file = root_dir + "/n_OH_ang/plane_OH_ang_after.dat"
f_poa_a = open(output_file, mode = "w")
output_file = root_dir + "/n_OH_ang/plane_OH_ang_chenge.dat"
f_poa_c = open(output_file, mode = "w")
output_file = root_dir + "/n_OH_ang/plane_OH_ang.dat"
f_poa = open(output_file, mode = "w")

f_HOH = open("./HOH_ang/HOH_ang.dat", mode = "w")

f_moveh = []
for i in range(101):
    output_file = root_dir + "/move_h_xyz/STEP"+str(i)+".dat"
    f_moveh.append(open(output_file, mode = "w"))

save = 100
save_check = 0


O_sum  = [[0 for _ in range(3)] for _ in range(101)]
C_sum  = [[0 for _ in range(3)] for _ in range(101)]
H0_sum = [[0 for _ in range(3)] for _ in range(101)]
H1_sum = [[0 for _ in range(3)] for _ in range(101)]
H2_sum = [[0 for _ in range(3)] for _ in range(101)]
H3_sum = [[0 for _ in range(3)] for _ in range(101)]

data = [[] for i in range(101)]
HOH_li = [[] for i in range(101)] 
cnt = 0
for traj in files:
    fi = "../../input/"+tri_sin+"/"+traj+".xyz"
    print(fi)
    with open(fi, mode = "r")as f:
        lines = f.readlines()
    loop = len(lines)//line_len
    H = [[]for i in range(4)]
    G = [[]for i in range(3)]
    title= [[] for i in range(loop)]
    O    = [[] for i in range(loop)]
    C    = [[] for i in range(loop)]
    H[0] = [[] for i in range(loop)]
    H[1] = [[] for i in range(loop)]
    H[2] = [[] for i in range(loop)]
    H[3] = [[] for i in range(loop)]
    G[0] = [[] for i in range(loop)]
    G[1] = [[] for i in range(loop)]
    G[2] = [[] for i in range(loop)]
    for i in range(loop):
        print("STEP" ,i)
        title[i] = lines[1 + i * line_len].replace('\n','').split()
        O[i]     = lines[6 + i * line_len].replace('\n','').split()
        C[i]     = lines[2 + i * line_len].replace('\n','').split()
        H[0][i]  = lines[3 + i * line_len].replace('\n','').split()
        H[1][i]  = lines[4 + i * line_len].replace('\n','').split()
        H[2][i]  = lines[5 + i * line_len].replace('\n','').split()
        H[3][i]  = lines[7 + i * line_len].replace('\n','').split()

        for j in range(3):
            radii = np.sqrt((float(H[j][i][1]) - float(O[i][1]))**2 + (float(H[j][i][2]) - float(O[i][2]))**2 + (float(H[j][i][3]) - float(O[i][3]))**2)
            c_fla = list(range(3))
            #print(radii)
            if radii <= 1.1:
                c_fla.pop(j)
                c_fla.insert(0, -1)
                c_fla = map(lambda x: x+2, c_fla)
                c_fla = map(str, c_fla)
                migrate_H = j
                migrate_STEP = i
                print("<= 1.1", j)
                break
        else:
            continue
        break
    fi = "../" + traj + "/input/coordinate_rotation3_G.XYZ"
    print(fi)
    with open(fi, mode = "r") as f:
        lines = f.readlines()
    for i in range(loop):
        #print("STEP" ,i)
        title[i] = lines[1  + i * (line_len + 3)].replace('\n','').split()
        O[i]     = lines[6 + i * (line_len + 3)].replace('\n','').split()
        C[i]     = lines[2 + i * (line_len + 3)].replace('\n','').split()
        H[0][i]  = lines[3 + i * (line_len + 3)].replace('\n','').split()
        H[1][i]  = lines[4 + i * (line_len + 3)].replace('\n','').split()
        H[2][i]  = lines[5 + i * (line_len + 3)].replace('\n','').split()
        H[3][i]  = lines[7 + i * (line_len + 3)].replace('\n','').split()
        G[0][i]  = lines[8 + i * (line_len + 3)].replace('\n','').split()
        G[1][i]  = lines[9 + i * (line_len + 3)].replace('\n','').split()
        G[2][i]  = lines[10 + i * (line_len + 3)].replace('\n','').split()
        f_moveh[i].write("{} {} {} {}\n".format(traj, H[migrate_H][i][1], H[migrate_H][i][2], H[migrate_H][i][3]))
        for j in range(3):
            #print(O[i][j+1])
            O_sum[i][j]  += float(O[i][j+1])
            C_sum[i][j]  += float(C[i][j+1])
            H0_sum[i][j] += float(H[0][i][j+1])
            H1_sum[i][j] += float(H[1][i][j+1])
            H2_sum[i][j] += float(H[2][i][j+1])
            H3_sum[i][j] += float(H[3][i][j+1])


    for i in range(loop):
        OC = list(range(4))
        OC[0] = "OC"
        #OC[1] = float(C[i][1]) - float(O[i][1])
        #OC[2] = float(C[i][2]) - float(O[i][2])
        #OC[3] = float(C[i][3]) - float(O[i][3])
        OC[1] = float(G[0][i][1]) - float(G[2][i][1])
        OC[2] = float(G[0][i][2]) - float(G[2][i][2])
        OC[3] = float(G[0][i][3]) - float(G[2][i][3])

        OH = [[0 for i in range(4)] for i in range(4)]
        for j in range(4):
            OH[j][0] = "OH"
            #OH[j][1] = float(H[j][i][1]) - float(O[i][1])
            #OH[j][2] = float(H[j][i][2]) - float(O[i][2])
            #OH[j][3] = float(H[j][i][3]) - float(O[i][3])
            OH[j][1] = float(H[j][i][1]) - float(G[2][i][1]) 
            OH[j][2] = float(H[j][i][2]) - float(G[2][i][2]) 
            OH[j][3] = float(H[j][i][3]) - float(G[2][i][3])
        perpendicular_line = list(range(4))
        perpendicular_line[0] = "perpendicular_line"
        #perpendicular_line[1] = OH[migrate_H[i]][2] * OC[3] - OH[migrate_H[i]][3] * OC[2]
        #perpendicular_line[2] = OH[migrate_H[i]][3] * OC[1] - OH[migrate_H[i]][1] * OC[3]
        #perpendicular_line[3] = OH[migrate_H[i]][1] * OC[2] - OH[migrate_H[i]][2] * OC[1]
        perpendicular_line[1] = OH[migrate_H][2] * OC[3] - OH[migrate_H][3] * OC[2]
        perpendicular_line[2] = OH[migrate_H][3] * OC[1] - OH[migrate_H][1] * OC[3]
        perpendicular_line[3] = OH[migrate_H][1] * OC[2] - OH[migrate_H][2] * OC[1]
        #perpendicular_line[1] = abs(OH[migrate_H][2] * OC[3] - OH[migrate_H][3] * OC[2])
        #perpendicular_line[2] = abs(OH[migrate_H][3] * OC[1] - OH[migrate_H][1] * OC[3])
        #perpendicular_line[3] = abs(OH[migrate_H][1] * OC[2] - OH[migrate_H][2] * OC[1])

        #print("=======")
        #print("STEP", i)
        #print("C ", float(C[i][1]), float(C[i][2]), float(C[i][3]))
        #print("O ", float(O[i][1]), float(O[i][2]), float(O[i][3]))
        #print("H ", float(H[3][i][1]), float(H[3][i][2]), float(H[3][i][3]))
        #print("mH", float(H[migrate_H][i][1]), float(H[migrate_H][i][2]), float(H[migrate_H][i][3]))
        #print("pl", perpendicular_line[1], perpendicular_line[2], perpendicular_line[3])
        #print("OH", OH[migrate_H][1], OH[migrate_H][2], OH[migrate_H][3])
        #print("OC", OC[1], OC[2], OC[3])
        
        HOH_a = (OH[migrate_H][1] * OH[3][1] + \
                OH[migrate_H][2] * OH[3][2] + \
                OH[migrate_H][3] * OH[3][3])
        HOH_b = (np.sqrt(OH[migrate_H][1] * OH[migrate_H][1] + \
                OH[migrate_H][2] * OH[migrate_H][2] + \
                OH[migrate_H][3] * OH[migrate_H][3]) \
                * \
                np.sqrt(OH[3][1] * OH[3][1] + \
                OH[3][2] * OH[3][2] + \
                OH[3][3] * OH[3][3]))

        HOH_ang_acos = HOH_a / HOH_b
        HOH_ang_deg = np.rad2deg(np.arccos(HOH_ang_acos))
        HOH_li[i].append(HOH_ang_deg)
        f_HOH.write("{:<3d} {:11.7f} {} {:2d}\n".format(i, HOH_ang_deg, traj, cnt))

        for j in range(4):
            a = (perpendicular_line[1] * OH[j][1] + \
                    perpendicular_line[2] * OH[j][2] + \
                    perpendicular_line[3] * OH[j][3])
            b = (np.sqrt(perpendicular_line[1] * perpendicular_line[1] + \
                    perpendicular_line[2] * perpendicular_line[2] + \
                    perpendicular_line[3] * perpendicular_line[3]) \
                    * \
                    np.sqrt(OH[j][1] * OH[j][1] + \
                    OH[j][2] * OH[j][2] + \
                    OH[j][3] * OH[j][3]))
            ang_acos = a / b
            ang_deg = np.rad2deg(np.arccos(ang_acos))
            #if 0 <= ang_deg <= 90:
            #    ang_deg = 90 - ang_deg
            #elif 0 < ang_deg <= 180:
            #    ang_deg = ang_deg - 90
            #print(ang_acos, ang_deg)
            if j == 3:
                if ang_deg < save:
                    save = ang_deg
                    save_check = traj

                data[i].append(ang_deg)
            #>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
                f_poa.write("{} {} {}\n".format(i, ang_deg, traj))
            if j == 3 and i <= migrate_STEP:
                f_poa_b.write("{} {}\n".format(i, ang_deg))
            if j == 3 and i >= migrate_STEP:
                f_poa_a.write("{} {}\n".format(i, ang_deg))
            if j == 3 and i == migrate_STEP:
                f_poa_c.write("{} {} {}\n".format(i, ang_deg, traj))
            #===============================================================        
            #    output_file = root_dir + "/plane_OH_ang.dat"
            #    with open(output_file, mode = "a") as f_pOa:
            #        f_pOa.write("{} {} {}\n".format(i, ang_deg, check))
            #        #f_pOa.write("{} {}\n".format(i, ang_deg))
            #if j == 3 and i <= migrate_STEP:
            #    output_file = root_dir + "/plane_OH_ang_before.dat"
            #    with open(output_file, mode = "a") as f_pOa:
            #        f_pOa.write("{} {}\n".format(i, ang_deg))
            #if j == 3 and i >= migrate_STEP:
            #    output_file = root_dir + "/plane_OH_ang_after.dat"
            #    with open(output_file, mode = "a") as f_pOa:
            #        f_pOa.write("{} {}\n".format(i, ang_deg))
            #if j == 3 and i == migrate_STEP:
            #    output_file = root_dir + "/plane_OH_ang_chenge.dat"
            #    with open(output_file, mode = "a") as f_pOa:
            #        f_pOa.write("{} {} {}\n".format(i, ang_deg, check))
            #<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<


        #a = (perpendicular_line[1] * OH[migrate_H][1] + \
        #        perpendicular_line[2] * OH[migrate_H][2] + \
        #        perpendicular_line[3] * OH[migrate_H][3])
        #b = (np.sqrt(perpendicular_line[1] * perpendicular_line[1] + \
        #        perpendicular_line[2] * perpendicular_line[2] + \
        #        perpendicular_line[3] * perpendicular_line[3]) \
        #        * \
        #        np.sqrt(OH[migrate_H][1] * OH[migrate_H][1] + \
        #        OH[migrate_H][2] * OH[migrate_H][2] + \
        #        OH[migrate_H][3] * OH[migrate_H][3]))
        #ang_acos = a / b
        #ang_deg = np.rad2deg(np.arccos(ang_acos))
        #print(ang_deg)
    #output_file = root_dir + "/plane_OH_ang.dat"
    #with open(output_file, mode = "a") as f_pOa:
    #    f_pOa.write("\n")

    #>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    f_poa_a.write("\n")
    f_poa_b.write("\n")
    f_HOH.write("\n")
    #=====================================================
    #output_file = root_dir + "/plane_OH_ang_after.dat"
    #with open(output_file, mode = "a") as f_pOa:
    #    f_pOa.write("\n")

    #output_file = root_dir + "/plane_OH_ang_before.dat"
    #with open(output_file, mode = "a") as f_pOa:
    #    f_pOa.write("\n")
    #<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    cnt += 1 
    os.chdir(root_dir)

f_poa_b.close()
f_poa_a.close()
f_poa_c.close()
f_poa.close()
f_HOH.close()
for i in range(101):
    f_moveh[i].close()

# standard deviation
sd = []
HOH_sd = []

def std(li):
    length = len(li)
    ave    = sum(li)/length

    li_std = map(lambda x: (x - ave)**2, li)
    return np.sqrt(sum(li_std)/length)



for i in range(101):
    sd.append([np.average(data[i]), np.std(data[i])])
    HOH_sd.append([np.average(HOH_li[i]), np.std(HOH_li[i])])
    #sd.append([np.average(data[i]), std(data[i])])

with open("./HOH_ang/sd.dat", mode = "w") as f:
    for i in range(101):
        f.write("{} {}\n".format(i, HOH_sd[i][0]))
    f.write("\n")
    for i in range(101):
        f.write("{} {}\n".format(i, HOH_sd[i][0] + HOH_sd[i][1]))
    f.write("\n")
    for i in range(101):
        f.write("{} {}\n".format(i, HOH_sd[i][0] - HOH_sd[i][1]))
    f.write("\n")
    for i in range(101):
        f.write("{} {}\n".format(i, HOH_sd[i][0] + 2 * HOH_sd[i][1]))
    f.write("\n")
    for i in range(101):
        f.write("{} {}\n".format(i, HOH_sd[i][0] - 2 * HOH_sd[i][1]))
    f.write("\n")

with open("./n_OH_ang/sd.dat", mode = "w") as f:
    for i in range(101):
        f.write("{} {}\n".format(i, sd[i][0]))
    f.write("\n")
    for i in range(101):
        f.write("{} {}\n".format(i, sd[i][0] + sd[i][1]))
    f.write("\n")
    for i in range(101):
        f.write("{} {}\n".format(i, sd[i][0] - sd[i][1]))
    f.write("\n")
    for i in range(101):
        f.write("{} {}\n".format(i, sd[i][0] + 2 * sd[i][1]))
    f.write("\n")
    for i in range(101):
        f.write("{} {}\n".format(i, sd[i][0] - 2 * sd[i][1]))
    f.write("\n")
#print(save, save_check)

O_ave  = [[0 for _ in range(3)] for _ in range(101)]
C_ave  = [[0 for _ in range(3)] for _ in range(101)]
H0_ave = [[0 for _ in range(3)] for _ in range(101)]
H1_ave = [[0 for _ in range(3)] for _ in range(101)]
H2_ave = [[0 for _ in range(3)] for _ in range(101)]
H3_ave = [[0 for _ in range(3)] for _ in range(101)]
for i in range(101):
    for j in range(3):
        O_ave[i][j] = O_sum[i][j] / float(len(files))
        C_ave[i][j] = C_sum[i][j] / float(len(files))
        H0_ave[i][j] = H0_sum[i][j] / float(len(files))
        H1_ave[i][j] = H1_sum[i][j] / float(len(files))
        H2_ave[i][j] = H2_sum[i][j] / float(len(files))
        H3_ave[i][j] = H3_sum[i][j] / float(len(files))
#os.mkdir("pamfpad_ave/input/")
with open(root_dir+"/input/ave_xyz.dat", mode = "w") as f:
    for i in range(101):
        f.write("{}\n".format(6))
        f.write("Step : {}\n".format(i * 10))
        f.write("C {} {} {}\n".format(C_ave[i][0], C_ave[i][1], C_ave[i][2]))
        f.write("H {} {} {}\n".format(H0_ave[i][0], H0_ave[i][1], H0_ave[i][2]))
        f.write("H {} {} {}\n".format(H1_ave[i][0], H1_ave[i][1], H1_ave[i][2]))
        f.write("H {} {} {}\n".format(H2_ave[i][0], 0.0, H2_ave[i][2]))
        f.write("O {} {} {}\n".format(O_ave[i][0], O_ave[i][1], O_ave[i][2]))
        f.write("H {} {} {}\n".format(H3_ave[i][0], H3_ave[i][1], H3_ave[i][2]))

