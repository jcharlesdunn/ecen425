
#include "yakk.h"
#include "clib.h"
#include "lab7defs.h"

extern YKQ *PQPtr; 
extern struct msg MsgArray[];
//extern int GlobalFlag;

 //Lab 5 and below...
extern int KeyBuffer;
int tickCount = 0;

extern unsigned NewPieceID;
extern unsigned NewPieceType;
extern unsigned NewPieceOrientation;
extern unsigned NewPieceColumn;

extern unsigned ScreenBitMap0;
extern unsigned ScreenBitMap1;
extern unsigned ScreenBitMap2;
extern unsigned ScreenBitMap3;
extern unsigned ScreenBitMap4;


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
    char c;
    c = KeyBuffer;

    /*if(c == 'a') YKEventSet(charEvent, EVENT_A_KEY);
    else if(c == 'b') YKEventSet(charEvent, EVENT_B_KEY);
    else if(c == 'c') YKEventSet(charEvent, EVENT_C_KEY);
    else if(c == 'd') YKEventSet(charEvent, EVENT_A_KEY | EVENT_B_KEY | EVENT_C_KEY);
    else if(c == '1') YKEventSet(numEvent, EVENT_1_KEY);
    else if(c == '2') YKEventSet(numEvent, EVENT_2_KEY);
    else if(c == '3') YKEventSet(numEvent, EVENT_3_KEY);
    else {*/
        print("\nKEYPRESS (", 11);
        printChar(c);
        print(") IGNORED\n", 10);
    //}
}

void gameOverHandle(void)
{
	printString("gameOverHandle\n");
	exit(0); //Exit program, as defined in clib.h
}

void newPieceHandle(void)
{
	unsigned tempID,tempType,tempOrient,tempCol;
	printString("newPieceHandle\n");
	tempID = NewPieceID;
	tempType = NewPieceType;
	tempOrient  = NewPieceOrientation;
	tempCol = NewPieceColumn;
	printString("ID: ");
	printUInt(tempID);
	printNewLine();
	printString("TYPE: ");
	printUInt(tempType);
	printNewLine();
	printString("ORIENT: ");
	printUInt(tempOrient);
	printNewLine();
	printString("COL: ");
	printUInt(tempCol);
	printNewLine();

	// take that peiece and put in q
	//YKQPost(PQPtr, (void*)1);

}

void recieveCommandHandle(void)
{
	printString("recieveCommandHandle\n");
}

void touchdownHandle(void)
{
	printString("touchdownHandle\n");
}

void lineClearHandle(void)
{
	printString("lineClearHandle\n");
}



