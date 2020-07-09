def process(s):
	n = s.find(";")
	if n > 0:
		left = s[:n]+(" " * 64)
		s = left[:34]+s[n:]
	return s

f = open("revenge.asm")
code = f.readlines()
f.close()
code = [process(c.rstrip()) for c in code]
print("\n".join(code))
