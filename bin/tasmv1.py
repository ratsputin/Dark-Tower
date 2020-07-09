#
#	Support arrays.
#
pcOrder = [ 0x00, 0x01, 0x03, 0x07, 0x0F, 0x1F, 0x3F, 0x3E, 0x3D, 0x3B, 0x37, 0x2F, 0x1E, 0x3C, 0x39, 0x33, \
            0x27, 0x0E, 0x1D, 0x3A, 0x35, 0x2B, 0x16, 0x2C, 0x18, 0x30, 0x21, 0x02, 0x05, 0x0B, 0x17, 0x2E, \
            0x1C, 0x38, 0x31, 0x23, 0x06, 0x0D, 0x1B, 0x36, 0x2D, 0x1A, 0x34, 0x29, 0x12, 0x24, 0x08, 0x11, \
            0x22, 0x04, 0x09, 0x13, 0x26, 0x0C, 0x19, 0x32, 0x25, 0x0A, 0x15, 0x2A, 0x14, 0x28, 0x10, 0x20 ]

nextPC =  [ 0x01, 0x03, 0x05, 0x07, 0x09, 0x0B, 0x0D, 0x0F, 0x11, 0x13, 0x15, 0x17, 0x19, 0x1B, 0x1D, 0x1F, \
            0x20, 0x22, 0x24, 0x26, 0x28, 0x2A, 0x2C, 0x2E, 0x30, 0x32, 0x34, 0x36, 0x38, 0x3A, 0x3C, 0x3F, \
            0x00, 0x02, 0x04, 0x06, 0x08, 0x0A, 0x0C, 0x0E, 0x10, 0x12, 0x14, 0x16, 0x18, 0x1A, 0x1C, 0x1E, \
            0x21, 0x23, 0x25, 0x27, 0x29, 0x2B, 0x2D, 0x2F, 0x31, 0x33, 0x35, 0x37, 0x39, 0x3B, 0x3D, 0x3E ]

i2Value = [ 0x00, 0x02, 0x01, 0x03 ]
i4Value = [ 0x00, 0x08, 0x04, 0x0C, 0x02, 0x0A, 0x06, 0x0E, 0x01, 0x09, 0x05, 0x0D, 0x03, 0x0B, 0x07, 0x0F ]
#
#	Mnemonics etc.
#
mnemonicsToOpcode = {}
m1 = "mnea,alem,ynea,xma,dyn,iyc,amaac,dman,tka,comx,tdo,tpc,rstr,setr,knez,retn".split(",")
m2 = "tay,tma,tmy,tya,tamdyn,tamiyc,tamza,tam,ldx0,ldx4,ldx2,ldx6,ldx1,ldx5,ldx3,ldx7".split(",")

for i in range(0,16):
	n = i4Value[i]
	mnemonicsToOpcode[m1[i]] = i
	mnemonicsToOpcode["ldp"+str(n)] = i + 0x10
	mnemonicsToOpcode[m2[i]] = i + 0x20
	mnemonicsToOpcode["tcy"+str(n)] = i + 0x40
	mnemonicsToOpcode["ynec"+str(n)] = i + 0x50
	mnemonicsToOpcode["tcmiy"+str(n)] = i + 0x60
	mnemonicsToOpcode["a"+str(i)+"aac"] = i4Value[i-1] + 0x70 if i > 0 else None

mnemonicsToOpcode["iac"] = 0x70
mnemonicsToOpcode["dan"] = 0x77
mnemonicsToOpcode["cla"] = 0x7F

for i in range(0,4):
	n = i2Value[i]
	mnemonicsToOpcode["sbit"+str(n)] = 0x30+i
	mnemonicsToOpcode["rbit"+str(n)] = 0x34+i
	mnemonicsToOpcode["tbit1"+str(n)] = 0x38+i

mnemonicsToOpcode["saman"] = 0x3C
mnemonicsToOpcode["cpaiz"] = 0x3D
mnemonicsToOpcode["imac"] = 0x3E
mnemonicsToOpcode["mnez"] = 0x3F

objectCode = [ 0 ] * 4096						# object code
labelRequired = [ None ] * 4096						# label patch here, if any.
labelToAddress = {} 							# map label (lowercase) to address

source = open("darktower.asm").readlines()				# read in source code.
##source = [s[:s.find(";")] if s.find(";")>=0 else s for s in source]	# remove comments
##source = [s.strip().lower().replace("\t"," ") for s in source]	# preprocess
##source = [s for s in source if s != ""]				# remove blank lines
##source = ["".join(s.split(" ")) for s in source]			# remove all spaces.

programCounter = 0 							# program counter (6 bit)
pageAddress = 0 							# page address (4 bit)

#
# Pass 1
#
for line in source:                                                     # work through all the source code.
	print("\t"+line[:-1])
	line = line[:line.find(";")] if line.find(";") >= 0 else line   # remove comments
	line = line.strip().lower().replace("\t"," ")                   # clean up case and tabs
	line = "".join(line.split(" "))                                 # remove spaces
	if line != "":
                if line[-1] == ":":					# is it a label?
                        assert line[:-1] not in labelToAddress 		# check it doesn't exist already
                        labelToAddress[line[:-1]] = programCounter + pageAddress# store the address of the label.
#
# check for long/short branch/call.
#
                elif line[:2] == "br" or line[:4] == "call":
                        isBranch = line[:2] == "br"			# look for BRanch
                        line = line[(2 if isBranch else 4):]		# remove br or call

#
# Store Branch/Call Opcode.
#
                        objectCode[programCounter+pageAddress] = 0x80 if isBranch else 0xC0
                        labelRequired[programCounter+pageAddress] = line# store the label required.
                        programCounter = nextPC[programCounter]
                        if programCounter == 0:
                                pageAddress = pageAddress + 0x40

                else:
                        assert(line in mnemonicsToOpcode)
                        objectCode[programCounter+pageAddress] = mnemonicsToOpcode[line]
                        print("${0:03x}: ${1:02x}".format(programCounter+pageAddress,mnemonicsToOpcode[line]))
                        programCounter = nextPC[programCounter]
                        if programCounter == 0:
                                pageAddress = pageAddress + 0x40

#
# Pass 2
#
for address in range(0,4096):
	if labelRequired[address] is not None:
#		print(labelRequired[address])
		assert(labelRequired[address] in labelToAddress)
		target = labelToAddress[labelRequired[address]]
		if objectCode[address] >= 0x80:
			objectCode[address] = objectCode[address] + target % 64
		else:
			objectCode[address] = objectCode[address] + i4Value[int(target/64)]

darktower = []

darktowerFile = open("darktower.bin","rb")
for i in range(0,4096):
	darktower.append(ord(darktowerFile.read(1)))
	print("${0:02x} - ${1:02x}".format(darktower[i],objectCode[i]))
	assert(darktower[i] == objectCode[i])

print("** OK **")

#open("darktower-new.bin","w").write(",".join([str(s) for s in darktower]))
