#####################################################################
# ECEn 425 Lab 7 Makefile

lab7.bin:	lab7final.s
		nasm lab7final.s -o lab7.bin -l lab7.lst

lab7final.s:	clib.s myisr.s myinth.s lab7app.s yakc.s simptris.s
		cat clib.s myisr.s yaks.s myinth.s lab7app.s yakc.s simptris.s > lab7final.s

myinth.s:	myinth.c
		cpp myinth.c myinth.i
		c86 -g myinth.i myinth.s

lab7app.s:	lab7app.c
		cpp lab7app.c lab7app.i
		c86 -g lab7app.i lab7app.s

yakc.s:		yakc.c
		cpp yakc.c yakc.i
		c86 -g yakc.i yakc.s

clean:
		rm lab7.bin lab7.lst lab7final.s myinth.s myinth.i \
		lab7app.s lab7app.i	yakc.s yakc.i


