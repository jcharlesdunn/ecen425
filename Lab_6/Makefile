#####################################################################
# ECEn 425 Lab 6 Makefile

lab6.bin:	lab6final.s
		nasm lab6final.s -o lab6.bin -l lab6.lst

lab6final.s:	clib.s myisr.s myinth.s lab6app.s yakc.s
		cat clib.s myisr.s yaks.s myinth.s lab6app.s yakc.s > lab6final.s

myinth.s:	myinth.c
		cpp myinth.c myinth.i
		c86 -g myinth.i myinth.s

lab6app.s:	lab6app.c
		cpp lab6app.c lab6app.i
		c86 -g lab6app.i lab6app.s

yakc.s:		yakc.c
		cpp yakc.c yakc.i
		c86 -g yakc.i yakc.s

clean:
		rm lab6.bin lab6.lst lab6final.s myinth.s myinth.i \
		lab6app.s lab6app.i	yakc.s yakc.i


