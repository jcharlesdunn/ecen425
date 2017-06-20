#####################################################################
# ECEn 425 Lab 3 Makefile

lab1.bin:	lab1final.s
		nasm lab1final.s -o lab1.bin -l lab1.lst

lab1final.s:	clib.s  lab1.s lab1asm.s
		cat clib.s lab1.s  lab1asm.s > lab1final.s

lab1.s:
		cpp lab1.c lab1.i
		c86 -g lab1.i lab1.s

clean:
		rm lab1.bin lab1.lst lab1final.s lab1.s lab1.i
