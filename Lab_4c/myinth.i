# 1 "myinth.c"
# 1 "<built-in>"
# 1 "<command-line>"
# 1 "/usr/include/stdc-predef.h" 1 3 4
# 1 "<command-line>" 2
# 1 "myinth.c"
# 1 "clib.h" 1



void print(char *string, int length);
void printNewLine(void);
void printChar(char c);
void printString(char *string);


void printInt(int val);
void printLong(long val);
void printUInt(unsigned val);
void printULong(unsigned long val);


void printByte(char val);
void printWord(int val);
void printDWord(long val);


void exit(unsigned char code);


void signalEOI(void);
# 2 "myinth.c" 2
# 1 "yakk.h" 1
extern unsigned int YKIdleCount;
extern unsigned int YKCtxSwCount;

void YKInitialize();
void YKEnterMutex();
void YKExitMutex();
void YKScheduler(int save);
void YKDispatcher(int save);
void YKIdleTask();
void YKNewTask(void (* task)(void), void *taskStack, unsigned char priority);
void YKRun();





extern unsigned int YKTickNum;
# 26 "yakk.h"
void YKDelayTask(unsigned count);
void YKEnterISR(void);
void YKExitISR(void);
void YKTickHandler(void);
# 3 "myinth.c" 2

extern int KeyBuffer;
static int tickCounter = 0;

void ResetHandler(void)
{
 printString("RESET ");
 exit(0);
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
 {
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
