#include "clib.h"
#include "yakk.h"

extern int KeyBuffer;
static int tickCounter = 0;

void ResetHandler(void)
{
	printString("RESET ");	
	exit(0);        // Terminate with exit code
}

void TickHandler(void)
{
	tickCounter++;
	printNewLine(); 	
	printString("TICK ");
	printUInt(tickCounter);
	printString("\n");
	YKTickHandler();
}

void KeyHandler(void)
{
	static counter = 0;
	if(KeyBuffer == 100)
	{ //D
		counter = 0;
		printString("DELAY KEY PRESSED\n ");
		while(counter < 5000) counter++;
		printString("DELAY COMPLETE\n ");
	}
	else
	{
		printString("KEYPRESS (");
		printChar(KeyBuffer);
		printString(") IGNORED\n");
	}

}
