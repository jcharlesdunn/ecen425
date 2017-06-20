# 1 "lab7app.c"
# 1 "<built-in>"
# 1 "<command-line>"
# 1 "/usr/include/stdc-predef.h" 1 3 4
# 1 "<command-line>" 2
# 1 "lab7app.c"






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
# 8 "lab7app.c" 2
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
# 9 "lab7app.c" 2
# 1 "lab7defs.h" 1
# 10 "lab7app.c" 2
# 1 "simptris.h" 1


void SlidePiece(int ID, int direction);
void RotatePiece(int ID, int direction);
void SeedSimptris(long seed);
void StartSimptris(void);
# 11 "lab7app.c" 2






int PieceTaskStk[512];
int MoveTaskStk[512];
int STaskStk[512];

void *PieceQ[10];
YKQ *PQPtr;





void PieceTask(void)
{

}
# 41 "lab7app.c"
void STask(void)
{
    unsigned max, switchCount, idleCount;
    int tmp;

    YKDelayTask(1);
    printString("Welcome to the YAK kernel\r\n");
    printString("Determining CPU capacity\r\n");
    YKDelayTask(1);
    YKIdleCount = 0;
    YKDelayTask(5);
    max = YKIdleCount / 25;
    YKIdleCount = 0;


 YKNewTask(PieceTask, (void *) &PieceTaskStk[512], 0);

    while (1)
    {
        YKDelayTask(20);

        YKEnterMutex();
        switchCount = YKCtxSwCount;
        idleCount = YKIdleCount;
        YKExitMutex();

        printString("<<<<< Context switches: ");
        printInt((int)switchCount);
        printString(", CPU usage: ");
        tmp = (int) (idleCount/max);
        printInt(100-tmp);
        printString("% >>>>>\r\n");

        YKEnterMutex();
        YKCtxSwCount = 0;
        YKIdleCount = 0;
        YKExitMutex();
    }
}



void main(void)
{
    YKInitialize();
 PQPtr = YKQCreate(PieceQ, 10);
    YKNewTask(STask, (void *) &STaskStk[512], 1);
    SeedSimptris((long)1);
 StartSimptris();
    YKRun();
}
