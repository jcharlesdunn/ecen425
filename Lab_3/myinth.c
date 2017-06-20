#include "clib.h"



extern int KeyBuffer;

void resetHandler(void)
{
    exit(0);
}

void tickHandler(void)
{
	static unsigned long tickCount = 0;	
	tickCount++;
	printString("\nTICK ");
	printUInt(tickCount);    
	printString(":\n");
}

void dKeyDelay(void)
{
	unsigned long delayCount = 0;	
	printString("\nDELAY KEY PRESSED\n");
	while(delayCount < 5000)
	{
		delayCount++;
	}
	printString("DELAY COMPLETE\n");
	
}

void keyboardHandler(void)
{
	if(KeyBuffer == 100)
	{
		dKeyDelay();
	}			
	else
	{    
		printString("\nKEYPRESS (");
		printChar(KeyBuffer);    
		printString(") IGNORED");
		printString(":\n");
	}
}

