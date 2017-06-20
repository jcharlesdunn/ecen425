#include "clib.h"
#include "yakk.h"

extern YKQ *MsgQPtr; 
extern struct msg MsgArray[];
extern int GlobalFlag;
extern int KeyBuffer;

void resetInterrupt(void) {
	printString("Reset Inerrupt\r\n");
	exit(0); 			//Exit program, as defined in clib.h
}

void tickInterrupt(void) {

}


void keyboardInterrupt(void) {
	char c;
    c = KeyBuffer;

}

