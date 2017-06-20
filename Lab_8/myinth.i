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






typedef struct taskblock *TCBptr;
typedef struct taskblock
{
    void *stackptr;
    int state;
    int priority;
    int delay;
    TCBptr next;
    TCBptr prev;
 unsigned eventMask;
 unsigned eventMode;
} TCB;

typedef struct semaphore *SEMptr;
typedef struct semaphore{
 int value;
 TCBptr waitList;
} YKSEM;

typedef struct YKqueue *YKQptr;
typedef struct YKqueue{
 int size;
 int items;
 int head;
 int tail;
 void** base;
 TCBptr waitList;
} YKQ;

typedef struct WhyKayEvent *Eventptr;
typedef struct WhyKayEvent {
 unsigned eventGroup;
 TCBptr waitList;
} YKEVENT;

extern unsigned int YKIdleCount;
extern unsigned int YKCtxSwCount;
extern unsigned int YKTickNum;





void YKInitialize();

void YKEnterMutex(void);

void YKExitMutex(void);

void YKScheduler(int save);

void YKDispatcher(int save);

void YKIdleTask();

void YKNewTask(void (* task)(void), void *taskStack, unsigned char priority);

void YKDelayTask(unsigned count);

void YKTickHandler(void);

void YKRun(void);

void YKEnterISR(void);

void YKExitISR(void);

YKSEM* YKSemCreate(int);

void YKSemPend(YKSEM*);

void YKSemPost(YKSEM*);

void printLists(void);

YKQ *YKQCreate(void **start, unsigned size);

void *YKQPend(YKQ *queue);

int YKQPost(YKQ *queue, void *msg);

YKEVENT *YKEventCreate(unsigned initialValue);

unsigned YKEventPend(YKEVENT *event, unsigned eventMask, int waitMode);

void YKEventSet(YKEVENT *event, unsigned eventMask);

void YKEventReset(YKEVENT *event, unsigned eventMask);
# 3 "myinth.c" 2

extern YKQ *MsgQPtr;
extern struct msg MsgArray[];
extern int GlobalFlag;
extern int KeyBuffer;

void resetInterrupt(void) {
 printString("Reset Inerrupt\r\n");
 exit(0);
}

void tickInterrupt(void) {

}


void keyboardInterrupt(void) {
 char c;
    c = KeyBuffer;

}
