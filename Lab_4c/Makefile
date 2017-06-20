#####################################################################
# ECEn 425 Lab 4c Makefile

lab4c.bin:	lab4cfinal.s
		nasm lab4cfinal.s -o lab4c.bin -l lab4c.lst

lab4cfinal.s:	clib.s myisr.s myinth.s yakk.s lab4c.s assembly.s
		cat clib.s myisr.s myinth.s yakk.s lab4c.s assembly.s > lab4cfinal.s

myinth.s:	myinth.c
		cpp myinth.c myinth.i
		c86 -g myinth.i myinth.s

yakk.s:	    yakk.c
		cpp yakk.c yakk.i
		c86 -g yakk.i yakk.s

lab4c.s:	lab4c.c
		cpp lab4c.c lab4c.i
		c86 -g lab4c.i lab4c.s

clean:
		rm lab4c.bin lab4c.lst lab4cfinal.s myinth.s myinth.i \
		yakk.s yakk.i lab4b.s lab4b.i


