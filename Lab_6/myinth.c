/* 
File: lab6inth.c
Revision date: 4 November 2009
Description: Sample interrupt handler code for EE 425 lab 6 (Message queues)
*/

#include "lab6defs.h"
#include "yakk.h"
#include "clib.h"

extern YKQ *MsgQPtr; 
extern struct msg MsgArray[];
extern int GlobalFlag;

void resetInterrupt(void)
{
    exit(0);
}

void tickInterrupt(void)
{
    static int next = 0;
    static int data = 0;
	
    /* create a message with tick (sequence #) and pseudo-random data */
    MsgArray[next].tick = YKTickNum;
    data = (data + 89) % 100;
    MsgArray[next].data = data;
    if (YKQPost(MsgQPtr, (void *) &(MsgArray[next])) == 0)
	printString("  TickISR: queue overflow! \n");
    else if (++next >= MSGARRAYSIZE)
	next = 0;
}	       

void keyboardInterrupt(void)
{
    GlobalFlag = 1;
}

/* Lab 5 and below...
extern int KeyBuffer;
extern YKSEM *NSemPtr;
int tickCount = 0;

void resetInterrupt(void)
{
	printString("Reset Inerrupt");
	exit(0); //Exit program, as defined in clib.h
}

void tickInterrupt(void)
{
	tickCount++;
	printNewLine;
	printString("TICK ");
	printInt(tickCount);
	printString("\n\r");
}


void keyboardInterrupt(void)
{
	unsigned int localVar = 0;

	if (KeyBuffer == 100) //Ascii value of lowercase d ('d')
	{
		printNewLine;
		printString("DELAY KEY PRESSED");
		printNewLine();
		localVar = 0;
		while (localVar < 20000)
		{
			localVar++;
		}
		printString("DELAY COMPLETE");
		printNewLine();
	}
	else if (KeyBuffer == 'p'){
		//printString("P***************\n");
		YKSemPost(NSemPtr);
	}
	else if ((KeyBuffer > 97) && (KeyBuffer <123)) //Ascii values, not special chars
	{
		printNewLine;
		printString("KEYPRESS ");
		printChar(KeyBuffer); 	//Printing ascii value as a char. 
								//If doesn't work, do char c = KeyBuffer. Print that
		printString(" IGNORED");
		printNewLine();
	}
	else {}
}*/



