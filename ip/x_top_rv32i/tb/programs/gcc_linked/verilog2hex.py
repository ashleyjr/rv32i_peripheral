from sys import argv

verilog = argv[1]

# Get all the lines of the input file
with open(verilog, "r") as f:
    data = f.read()
lines = data.split("\n")

# Make sure starts at zero
assert lines[0] == "@00000000"

#
ptr = 0
for line in lines:
    if len(line) != 0:
        if line[0] == "@":
            while ptr < (int(line[1:], 16) // 4):
                ptr +=1
                print("00000000")
        else:
            pairs = line.split(" ")
            assert (len(pairs) % 4) == 0
            for i in range(len(pairs)//4):
                word = pairs[(i*4)+3]
                word += pairs[(i*4)+2]
                word += pairs[(i*4)+1]
                word += pairs[(i*4)]
                print(word)
                ptr += 1


