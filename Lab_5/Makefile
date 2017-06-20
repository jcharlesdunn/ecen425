#####################################################################
# ECEn 525 Lab 5 Makefile

lab5.bin:	lab5final.s
		nasm lab5final.s -o lab5.bin -l lab5.lst

lab5final.s:	clib.s myisr.s myinth.s lab5app.s yakc.s
		cat clib.s myisr.s yaks.s myinth.s lab5app.s yakc.s > lab5final.s

myinth.s:	myinth.c
		cpp myinth.c myinth.i
		c86 -g myinth.i myinth.s

lab5app.s:	lab5app.c
		cpp lab5app.c lab5app.i
		c86 -g lab5app.i lab5app.s

yakc.s:		yakc.c
		cpp yakc.c yakc.i
		c86 -g yakc.i yakc.s

clean:
		rm lab5.bin lab5.lst lab5final.s myinth.s myinth.i \
		lab5app.s lab5app.i	yakc.s yakc.i


