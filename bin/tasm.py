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
resolveLabel = [ None ] * 4096  					# label patch here, if any.
labelToAddress = {} 							# map label to address
labelToLineNum = {}                                                     # Map label to line number
addressToLabel = {}                                                     # Map addresses back to their associated label for the listing and XRef
labelXRef = {}                                                          # Track label cross-reference info

source = open("darktower.asm").readlines()				# read in source code.

programCounter = 0 							# program counter (6 bit)
pageAddress = 0 							# page address (4 bit)
lineNum = 1
listOutput = {}                                                         # Listing output - list of lists: [0] - address, [1] source

#
# Pass 1 - initial assembly
#
for line in source:                                                     # work through all the source code.
	listOutput[lineNum] = {}
	line = line.replace("\t"," "*8)                                 # clean up tabs
	listOutput[lineNum][1] = line[:-1]                              # Save the source line (except the newline at the end)
	listOutput[lineNum][0] = None                                   # Flag as not object code (yet)
	line = line[:line.find(";")] if line.find(";") >= 0 else line   # remove comments
	label = line[0:8]                                               # Pick up the label if any
	label = "".join(label.split(" "))                               # remove any spaces
	line = line[8:]                                                 # Strip the label and carry on
	line = line.strip().replace("\t"," ")                           # clean up tabs
	line = "".join(line.split(" "))                                 # Remove spaces
#
# There is code on this line; assemble it
#
	absAddress = programCounter + pageAddress
	if line != "":
		if label != "":	        				# is it a label?
			assert label not in labelToAddress, "Duplicate label %r" % label # check it doesn't exist already
			labelToAddress[label] = absAddress              # store the address
			addressToLabel[absAddress] = label
			labelToLineNum[label] = lineNum                 # and the line number of the label
#
# Check for BR or CALL
#
		if line[:2].lower() == "br" or line[:4].lower() == "call":
			isBranch = line[:2].lower() == "br"		# look for BRanch
			if isBranch:
				line = line[2:]                         # Remove br mnemonic, leaving just the label
				objectCode[absAddress] = 0x80
			else:
				line = line[4:]                         # Remove call mnemonic, leaving just the label
				objectCode[absAddress] = 0xC0
			resolveLabel[absAddress] = line # store the label required.
			if not (line in labelXRef):
				labelXRef[line] = [ str(lineNum) + ("(b)" if isBranch else "(c)") ]
			else:
				labelXRef[line].append(str(lineNum) + ("(b)" if isBranch else "(c)"))
			listOutput[lineNum][0] = absAddress
			programCounter = nextPC[programCounter]
			if programCounter == 0:                         # Advance to the next page
				pageAddress = pageAddress + 0x40
		else:
#
# Simple mnemonic
#
			line = line.lower()
			assert line in mnemonicsToOpcode, "Invalid mnemonic %r" % line
			objectCode[absAddress] = mnemonicsToOpcode[line]
			listOutput[lineNum][0] = absAddress
			programCounter = nextPC[programCounter]
			if programCounter == 0:
				pageAddress = pageAddress + 0x40
	lineNum += 1

#
# Pass 2 - symbol resolution
#
for offset in range(0,4096):
	if resolveLabel[offset] is not None:
		assert(resolveLabel[offset] in labelToAddress)
		targetAddress = labelToAddress[resolveLabel[offset]]
		objectCode[offset] = objectCode[offset] | (targetAddress & 0b00111111)        # Add the page offset of the target address

#
# Pass 3 - verify object code against original file
#
darktower = []

darktowerFile = open("darktower.bin", "rb")
for offset in range(0,4096):
	darktower.append(ord(darktowerFile.read(1)))
	assert(darktower[offset] == objectCode[offset])

print("** OK **")

#
# Generate listing
#
# outputLine[0] - Line Number
# outputLine[1] - Address and object code
# outputLine[2] - Source line
#
outputLine = {}

listFile = open("darktower.lst", "w")
for lineNum in listOutput:
	outputLine[0] = lineNum
	outputLine[1] = " "*13
	outputLine[2] = listOutput[lineNum][1]
	address = listOutput[lineNum][0]
#
# If this line has some object code, provide further information
#
	if address is not None:
		chapter = address >> 10 & 0b0011
		page = address >> 6 & 0b00001111
		addr = address & 0b00111111
		outputLine[1] = "{0:1X}:{1:1X}:{2:02X} {3:03X}:{4:02X}".format(chapter, page, addr, address, objectCode[address])  # Insert the address and object code

	listFile.write("{1} {0:4} {2}\t\n".format(lineNum, outputLine[1], outputLine[2]))
#
# Generate the cross-reference
#
listFile.write("\nCross-reference\n")
listFile.write("---------------\n\n")
listFile.write("LABEL    VALUE\t- (DEF) REF(b = BR, c=CALL)\n")

for address in range(0,4096):
	if address in addressToLabel:
		label = addressToLabel[address]
		listFile.write("{0:<8} 0x{1:04x}\t- ({2}) {3}\n".format(label, address, labelToLineNum[label], " ".join(labelXRef[label]) if label in labelXRef else ""))

listFile.close()

#
# Generate symbol file
#
symbolFile = open("darktower.sym","w")
for address in range(0,4096):
	if address in addressToLabel:
		symbolFile.write("{0}=0x{1:04x}\n".format(addressToLabel[address], address))
symbolFile.close()
