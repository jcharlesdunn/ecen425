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

typedef struct taskblock *TCBptr;
typedef struct taskblock
{
    void *stackptr;
    int state;
    int priority;
    int delay;
    TCBptr next;
    TCBptr prev;
} TCB;

typedef struct semaphore
{
 int value;
 TCBptr blockedOn;
} YKSEM;

void YKInitialize();

void YKEnterMutex();

void YKExitMutex();

void YKIMRInit(unsigned a);

void YKScheduler(int save);

void YKDispatcher(int save);

void YKIdleTask();

void YKNewTask(void (* task)(void), void *taskStack, unsigned char priority);

void YKDelayTask(unsigned count);

void YKTickHandler(void);

void YKRun();

void YKEnterISR(void);

void YKExitISR(void);

YKSEM* YKSemCreate(int initialValue);

void YKSemPend(YKSEM *inSemaphore);

void YKSemPost(YKSEM *inSemaphore);
# 3 "myinth.c" 2

extern int KeyBuffer;
extern YKSEM *NSemPtr;
int tickCount = 0;

void resetInterrupt(void)
{
 printString("Reset Inerrupt");
 exit(0);
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

 if (KeyBuffer == 100)
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

  YKSemPost(NSemPtr);
 }
 else if ((KeyBuffer > 97) && (KeyBuffer <123))
 {
  printNewLine;
  printString("KEYPRESS ");
  printChar(KeyBuffer);

  printString(" IGNORED");
  printNewLine();
 }
 else {}
}
