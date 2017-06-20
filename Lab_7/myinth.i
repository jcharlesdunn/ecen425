# 1 "myinth.c"
# 1 "<built-in>"
# 1 "<command-line>"
# 1 "/usr/include/stdc-predef.h" 1 3 4
# 1 "<command-line>" 2
# 1 "myinth.c"

# 1 "yakk.h" 1




extern unsigned int YKIdleCount;
extern unsigned int YKCtxSwCount;
extern int YKTickNum;

typedef struct taskblock *TCBptr;
typedef struct taskblock
{
    void *stackptr;
    int state;
    int priority;
    int delay;
 int waitValue;
 int waitMode;
    TCBptr next;
    TCBptr prev;
} TCB;

typedef struct semaphore
{
 int value;
 TCBptr blockedOn;
} YKSEM;


typedef struct YKQueue {
 unsigned int length;
 unsigned int head;
 unsigned int tail;
 int full;
 int empty;
 void** msgQ;
 TCBptr waitList;
} YKQ;

typedef struct eventStruct {
 unsigned value;
 TCBptr waitList;
} YKEVENT;

typedef struct pieceStruct *YKPPtr;
typedef struct pieceStruct {
 unsigned ID;
 unsigned type;
 unsigned orient;
 unsigned column;
} YKPIECE;



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

YKQ* YKQCreate(void** start, unsigned int size);

void *YKQPend(YKQ *queue);

int YKQPost(YKQ *queue, void *msg);

YKEVENT *YKEventCreate(unsigned initialValue);

unsigned YKEventPend(YKEVENT *event, unsigned eventMask, int waitMode);

void YKEventSet(YKEVENT *event, unsigned eventMask);

void YKEventReset(YKEVENT *event, unsigned eventMask);
# 3 "myinth.c" 2
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
# 4 "myinth.c" 2
# 1 "lab7defs.h" 1
# 5 "myinth.c" 2

extern YKQ *PQPtr;
extern struct msg MsgArray[];



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
    char c;
    c = KeyBuffer;
# 55 "myinth.c"
        print("\nKEYPRESS (", 11);
        printChar(c);
        print(") IGNORED\n", 10);

}

void gameOverHandle(void)
{
 printString("gameOverHandle\n");
 exit(0);
}

void newPieceHandle(void)
{
 unsigned tempID,tempType,tempOrient,tempCol;
 printString("newPieceHandle\n");
 tempID = NewPieceID;
 tempType = NewPieceType;
 tempOrient = NewPieceOrientation;
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
