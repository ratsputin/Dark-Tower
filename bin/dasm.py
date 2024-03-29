#
# Bit Reverse for 4 bit operands.
#
bitReverse4 =  [ 0,8,4,12,2,10,6,14,1,9,5,13,3,11,7,15 ]
bitReverse3 =  [ 0,4,2,6,1,5,3,7 ]
#
# Array of Mnemonics. We do not analyse LDP ($3X) BR ($80-$BF) and CALL ($C0-$FF)
#
mnemonics = [""] * 128
#
# Instructions with 4 bit operands.
#
for i in range(0,16):
	mnemonics[0x10+i] = "ldp   {0}".format(bitReverse4[i])   # Load Page Buffer with constant (this is replaced by xbr and xcall)
	mnemonics[0x40+i] = "tcy   {0}".format(bitReverse4[i])   # Transfer Constant to Y Register
	mnemonics[0x50+i] = "ynec  {0}".format(bitReverse4[i])   # If Y not equal to constant, one to status
	mnemonics[0x60+i] = "tcmiy {0}".format(bitReverse4[i])   # Transfer constant to memory and increment Y
#
# Instructions with 2 bit commands
#
for i in range(0,4):
	param = i if i == 0 or i == 3 else 3 - i
	mnemonics[0x30+i] = "sbit  {0}".format(param)           # Set memory bit - 1 -> M(X, Y, B)
	mnemonics[0x34+i] = "rbit  {0}".format(param)           # Reset memory bit - 0 -> M(X, Y, B)
	mnemonics[0x38+i] = "tbit1 {0}".format(param)           # Test memory bit.  If equal to one, one to status - M(X, Y, B) = 1

#
# Standalone instructions
#
mnemonics[0x00] = "mnea"
mnemonics[0x01] = "alem"
mnemonics[0x02] = "ynea"
mnemonics[0x03] = "xma"
mnemonics[0x04] = "dyn"
mnemonics[0x05] = "iyc"
mnemonics[0x06] = "amaac"
mnemonics[0x07] = "dman"
mnemonics[0x08] = "tka"
mnemonics[0x09] = "comx"
mnemonics[0x0A] = "tdo"
mnemonics[0x0B] = "tpc"
mnemonics[0x0C] = "rstr"
mnemonics[0x0D] = "setr"
mnemonics[0x0E] = "knez"
mnemonics[0x0F] = "retn"

mnemonics[0x20] = "tay"
mnemonics[0x21] = "tma"
mnemonics[0x22] = "tmy"
mnemonics[0x23] = "tya"
mnemonics[0x24] = "tamdyn"
mnemonics[0x25] = "tamiyc"
mnemonics[0x26] = "tamza"
mnemonics[0x27] = "tam"

for i in range(0,8):
	mnemonics[0x28+i] = "ldx   {0}".format(bitReverse3[i])

mnemonics[0x3C] = "saman"
mnemonics[0x3D] = "cpaiz"
mnemonics[0x3E] = "imac"
mnemonics[0x3F] = "mnez"

mnemonics[0x70] = "iac"
for i in range(1,15):
	mnemonics[0x70+i] = "a{0}aac".format(bitReverse4[i]+1)

mnemonics[0x77] = "dan"
mnemonics[0x7F] = "cla"
#
#	For any given value of PC, this points to the next PC value.  This is due to the oddball LFSR program counter in the TMS-1000 series.
#
tmsNextPC = [ 0x01, 0x03, 0x05, 0x07, 0x09, 0x0B, 0x0D, 0x0F, 0x11, 0x13, 0x15, 0x17, 0x19, 0x1B, 0x1D, 0x1F,
	      0x20, 0x22, 0x24, 0x26, 0x28, 0x2A, 0x2C, 0x2E, 0x30, 0x32, 0x34, 0x36, 0x38, 0x3A, 0x3C, 0x3F,
	      0x00, 0x02, 0x04, 0x06, 0x08, 0x0A, 0x0C, 0x0E, 0x10, 0x12, 0x14, 0x16, 0x18, 0x1A, 0x1C, 0x1E,
	      0x21, 0x23, 0x25, 0x27, 0x29, 0x2B, 0x2D, 0x2F, 0x31, 0x33, 0x35, 0x37, 0x39, 0x3B, 0x3D, 0x3E ]
#
#       Read the Dark Tower symbol file
#
symbols = []
try:
	symbolFile = open("darktower.sym","r")
	symbols = symbolFile.readlines()
	symbolFile.close()
except FileNotFoundError:
	print("Symbol file not found.  Generating new symbol table.")

#
#       Parse the symbols (if any)
#
addressToLabel = [ None ] * 4096
for line in symbols:
	line = line[:line.find(";")] if line.find(";") >= 0 else line           # Remove comments
	line = line.strip().replace("\t"," ")                                   # Clean up tabs
	line = "".join(line.split(" "))                                         # Remove spaces
	if line != "":
		label, address = line.split("=")                                # Parse the line
		addressToLabel[int(address,0)] = label                          # Save the label's value

#
#	Read the Dark Tower binary
#
darktower = []
darktowerFile = open("darktower.bin","rb")
for i in range(0,4096):
	darktower.append(ord(darktowerFile.read(1)))
#
#	Disassembly.
#
disasm = []
lineNum = 1

for chapter in range(0,4):
	for page in range(0,16):
		pageBaseAddress = (chapter << 10) + (page << 6)
		pageBuffer = page
		chapterBuffer = chapter
		programCounter = 0
		processCount = 64
		while processCount > 0:
			absAddress = pageBaseAddress + programCounter
			opcode = darktower[absAddress]
			line = [absAddress,"${0:03X}: ${1:02X}".format(absAddress,opcode),"" ] 

			if opcode >= 0x10 and opcode < 0x20:                    # Load Page Buffer (LDP)
				line[2] = mnemonics[opcode]                     # Insert the LDP
				disasm.append(line)
				lineNum += 1
				programCounter = tmsNextPC[programCounter]
				processCount = processCount - 1
				pageBuffer = bitReverse4[opcode & 0b00001111]
			elif opcode == 0x0B:                                    # Transfer Page Buffer to Chapter Buffer (TPC)
				line[2] = mnemonics[opcode]                     # Insert the TPC
				disasm.append(line)
				lineNum += 1
				programCounter = tmsNextPC[programCounter]
				processCount = processCount - 1
				chapterBuffer = pageBuffer & 0b0011
			elif opcode >= 0x80:                                    # Branch or Call (BR/CALL)
				shortXfer = (chapter == chapterBuffer and page == pageBuffer)
				baseTargetAddress = (chapterBuffer << 10) + (pageBuffer << 6)
				targetAddress = baseTargetAddress + (opcode & 0b00111111)
				if addressToLabel[targetAddress] is None:       # A label hasn't already been assigned to this target address
					label = "S{0:03X}".format(targetAddress) if shortXfer else "L{0:03X}".format(targetAddress) # Generate a new label
					assert label not in addressToLabel      # Check to make sure the label doesn't already exist at a different address
					addressToLabel[targetAddress] = label   # Save the label for this address
				else:
					label = addressToLabel[targetAddress]
					if label[:1] == "S" and (not shortXfer):
						print("*** Warning, long transfer to short label {} at ${:03X}".format(label, absAddress))
					elif label[:1] == "L" and shortXfer:
						print("*** Warning, short transfer to long label {} at ${:03X}".format(label, absAddress))
				line[2] = "{0}  {1}".format("br  " if opcode < 0xC0 else "call", label)
				disasm.append(line)
				lineNum += 1
				programCounter = tmsNextPC[programCounter]
				processCount = processCount - 1
				chapterBuffer = chapter                         # reset chapter and page buffers for next instruction
				pageBuffer = page
			else:
				line[2] = mnemonics[opcode]
				disasm.append(line)
				lineNum += 1
				programCounter = tmsNextPC[programCounter]
				processCount = processCount - 1

#
# Generate assembler file output
#
asmFile = open("darktower.asm","w")
lineNum = 0
for outputLine in disasm:
	absAddress = outputLine[0]
	chapter = absAddress >> 10 & 0b0011
	page = absAddress >> 6 & 0b00001111
	if absAddress & 0b00111111 == 0:
		asmFile.write(";---------------------\n")
		asmFile.write("; chapter {0} page {1}\n".format(chapter,page))
		asmFile.write(";---------------------\n")
	if addressToLabel[absAddress] is not None:
		label = "{0:8}".format(addressToLabel[absAddress])
		asmFile.write("{0}".format(label))
	else:
		asmFile.write("\t")
	asmFile.write("{0:16}\n".format(outputLine[2]))
asmFile.close()
