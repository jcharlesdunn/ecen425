# 1 "lab5app.c"
# 1 "<built-in>"
# 1 "<command-line>"
# 1 "/usr/include/stdc-predef.h" 1 3 4
# 1 "<command-line>" 2
# 1 "lab5app.c"






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
# 8 "lab5app.c" 2
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
# 9 "lab5app.c" 2



YKSEM *PSemPtr;
YKSEM *SSemPtr;
YKSEM *WSemPtr;
YKSEM *NSemPtr;

int TaskWStk[512];
int TaskSStk[512];
int TaskPStk[512];
int TaskStatStk[512];
int TaskPRMStk[512];


void TaskWord(void)
{
    while (1)
    {
        YKSemPend(WSemPtr);
        printString("Hey");
        YKSemPost(PSemPtr);

        YKSemPend(WSemPtr);
        printString("it");
        YKSemPost(SSemPtr);

        YKSemPend(WSemPtr);
        printString("works");
        YKSemPost(PSemPtr);
    }
}

void TaskSpace(void)
{
    while (1)
    {
        YKSemPend(SSemPtr);
        printChar(' ');
        YKSemPost(WSemPtr);
    }
}

void TaskPunc(void)
{
    while (1)
    {
        YKSemPend(PSemPtr);
        printChar('"');
        YKSemPost(WSemPtr);

        YKSemPend(PSemPtr);
        printChar(',');
        YKSemPost(SSemPtr);

        YKSemPend(PSemPtr);
        printString("!\"\r\n");
        YKSemPost(PSemPtr);

        YKDelayTask(6);
    }
}

void TaskPrime(void)
{
    int curval = 1001;
    int j,flag,lncnt;
    int endval;

    while (1)
    {
        YKSemPend(NSemPtr);


        lncnt = 0;
        endval = curval + 500;
        for ( ; curval < endval; curval += 2)
        {
            flag = 0;
            for (j = 3; (j*j) < curval; j += 2)
            {
                if (curval % j == 0)
                {
                    flag = 1;
                    break;
                }
            }
            if (!flag)
            {
                printChar(' ');
                printInt(curval);
                lncnt++;
                if (lncnt > 9)
                {
                    printNewLine();
                    lncnt = 0;
                }
            }
        }
        printNewLine();
    }
}

void TaskStat(void)
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

 printString("P SEM VALUE -> ");
 printInt(PSemPtr->value);
 printNewLine();
    YKNewTask(TaskPrime, (void *) &TaskPRMStk[512], 32);
 printString("P SEM VALUE -> ");
 printInt(PSemPtr->value);
 printNewLine();
    YKNewTask(TaskWord, (void *) &TaskWStk[512], 10);
    YKNewTask(TaskSpace, (void *) &TaskSStk[512], 11);
    YKNewTask(TaskPunc, (void *) &TaskPStk[512], 12);

    while (1)
    {
        YKDelayTask(20);

        YKEnterMutex();
        switchCount = YKCtxSwCount;
        idleCount = YKIdleCount;
        YKExitMutex();

        printString ("<<<<< Context switches: ");
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


    PSemPtr = YKSemCreate(1);
    SSemPtr = YKSemCreate(0);
    WSemPtr = YKSemCreate(0);
    NSemPtr = YKSemCreate(0);
    YKNewTask(TaskStat, (void *) &TaskStatStk[512], 30);

    YKRun();
}
