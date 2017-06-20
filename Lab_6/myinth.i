# 1 "myinth.c"
# 1 "<built-in>"
# 1 "<command-line>"
# 1 "/usr/include/stdc-predef.h" 1 3 4
# 1 "<command-line>" 2
# 1 "myinth.c"






# 1 "lab6defs.h" 1
# 9 "lab6defs.h"
struct msg
{
    int tick;
    int data;
};
# 8 "myinth.c" 2
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
# 9 "myinth.c" 2
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
# 10 "myinth.c" 2

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


    MsgArray[next].tick = YKTickNum;
    data = (data + 89) % 100;
    MsgArray[next].data = data;
    if (YKQPost(MsgQPtr, (void *) &(MsgArray[next])) == 0)
 printString("  TickISR: queue overflow! \n");
    else if (++next >= 20)
 next = 0;
}

void keyboardInterrupt(void)
{
    GlobalFlag = 1;
}
