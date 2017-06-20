#include "clib.h"
#include "yakk.h"

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
}

