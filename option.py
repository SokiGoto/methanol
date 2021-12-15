import re


def average_torajectry():
    with open("input_methanol_ave.txt") as f:
        lines = f.readlines()
        li = []
        for line in lines:
            if line[0] != "#" and not re.match("^[\t\n\r\f\v]*$", line):
                li.append(re.sub("[\n\t\r\f\v]", "", line))
    return li

def input_parameter():
    di = {}
    with open("input_methanol.txt", mode = "r") as f:
        lines = f.readlines()
        for line in lines:
            line = re.sub("[\n\t ]", "", line)
            #print(line)
            if (re.match("structure_file=", line)):
                #structure_file = re.findall("structure_file=\"(.*)\"", line)[0]
                di["structure_file"] = re.findall("structure_file=\"(.*)\"", line)[0]
            if (re.match("energy=", line)):
                #energy = re.findall("energy=\"(.*)\"", line)[0]
                di["energy"] = re.findall("energy=\"(.*)\"", line)[0]
            if (re.match("spec=", line)):
                #spec = re.findall("spec=\"(.*)\"", line)[0]
                di["spec"] = re.findall("spec=\"(.*)\"", line)[0]
            if (re.match("lmax_mode=", line)):
                #lmax_mode = re.findall("lmax_mode=\"(.*)\"", line)[0]
                di["lmax_mode"] = re.findall("lmax_mode=\"(.*)\"", line)[0]
            if (re.match("lmax=", line)):
                #lmax = re.findall("lmax=\"(.*)\"", line)[0]
                di["lmax"] = re.findall("lmax=\"(.*)\"", line)[0]
            if (re.match("elum=", line)):
                #elum = re.findall("elum=\"(.*)\"", line)[0]
                di["elum"] = re.findall("elum=\"(.*)\"", line)[0]
            if (re.match("absorbing_atom=", line)):
                #absorbing_atom = re.findall("absorbing_atom=\"(.*)\"", line)[0]
                di["absorbing_atom"] = re.findall("absorbing_atom=\"(.*)\"", line)[0]
    print("structure_file : ", di["structure_file"])
    print("energy         : ", di["energy"])
    print("spec           : ", di["spec"])
    print("lmax_mode      : ", di["lmax_mode"])
    print("lmax           : ", di["lmax"])
    print("elum           : ", di["elum"])
    print("absorbing_atom : ", di["absorbing_atom"])
    #return structure_file, energy, spec, lmax_mode, lmax, elum, absorbing_atom
    return di




if __name__ == "__main__":
    subroutine.option("input_methanol.txt")
    subroutine.input_parameter("input_methanol.txt")

