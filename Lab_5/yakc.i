# 1 "yakc.c"
# 1 "<built-in>"
# 1 "<command-line>"
# 1 "/usr/include/stdc-predef.h" 1 3 4
# 1 "<command-line>" 2
# 1 "yakc.c"
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
# 2 "yakc.c" 2
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
 int waitMode;
 int waitValue;
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
# 3 "yakc.c" 2
# 1 "yaku.h" 1
# 4 "yakc.c" 2





unsigned int YKCtxSwCount = 0;

unsigned int YKIdleCount;

unsigned int YKTickNum;

unsigned int ISRDepth;

int i = 0;

int* YKSave;
int* YKRestore;


YKSEM YKSems[4];
int YKAvaiSems;

TCBptr YKRdyList;
TCBptr YKAvailTCBList;
TCBptr YKSuspList;
TCBptr YKRunningTask;
TCB YKTCBArray[6 +1];

int hasRun = 0;
int idleStk[2048];

void YKInitialize(void)
{
 YKEnterMutex();
 YKIMRInit(0x00);
 YKCtxSwCount = 0;
 YKIdleCount = 0;
 YKTickNum = 0;
 ISRDepth = 0;
 YKSave = 0;
 YKRestore = 0;
 YKRdyList = 0;
 YKSuspList = 0;
 YKRunningTask = 0;
 hasRun = 0;
 YKAvaiSems = 4;

    YKAvailTCBList = &(YKTCBArray[0]);

    for (i = 0; i < 6; i++){
        YKTCBArray[i].next = &(YKTCBArray[i+1]);
    }
    YKTCBArray[6].next = 0;
    YKTCBArray[6].prev = 0;

    YKNewTask(YKIdleTask,(void *) &(idleStk[2048]),100);
}


void YKIdleTask(){
    while(1){

        YKEnterMutex();
        YKIdleCount++;
        YKExitMutex();
    }
}

void YKScheduler(int isSaved){
 if (YKRunningTask != YKRdyList){
  YKCtxSwCount++;
  YKDispatcher(isSaved);
 }

}



void YKNewTask(void (* task)(void), void *taskStack, unsigned char priority)
{
    unsigned *stackPoint;
    TCBptr newPoint, comparisonPoint;

    YKEnterMutex();

    newPoint = YKAvailTCBList;
    if(newPoint == 0){
        return;
    }

    YKAvailTCBList = newPoint->next;


    newPoint->priority = priority;
    newPoint->delay = 0;
 newPoint->state = 1;

    if (YKRdyList == 0)
    {
        YKRdyList = newPoint;
        newPoint->next = 0;
        newPoint->prev = 0;
    }
    else
    {
        comparisonPoint = YKRdyList;
  for (i = 0; i < 6; i ++)
  {
   if (newPoint->priority < comparisonPoint->priority){
    break;
   }
   else{
    comparisonPoint = comparisonPoint->next;
   }
  }
        if (comparisonPoint->prev == 0){
            YKRdyList = newPoint;
  }
        else{
            comparisonPoint->prev->next = newPoint;
  }

        newPoint->prev = comparisonPoint->prev;
        newPoint->next = comparisonPoint;
        comparisonPoint->prev = newPoint;
    }

 stackPoint = (unsigned *)taskStack;


 for (i = 0; i < 13; i++)
 {
  if (i == 1){
   stackPoint[0] = 0x0200;
  }
  else if (i == 3){
   stackPoint[0] = (unsigned)task;
  }
  else{
   stackPoint[0] = 0;
  }
  stackPoint--;
 }

    newPoint->stackptr = (void *)stackPoint;

    if(hasRun == 1) {
        YKScheduler(0);
        YKExitMutex();
    }
}

void YKDelayTask(unsigned count)
{
 TCBptr delayPoint;
 YKEnterMutex();
 if (count == 0){
  YKExitMutex();
  return;
 }

 delayPoint = YKRdyList;
 YKRdyList = delayPoint->next;
 if (YKRdyList != 0)
 {
  YKRdyList->prev = 0;
 }
 delayPoint->state = 0;
 delayPoint->delay = count;
 delayPoint->next = YKSuspList;
 YKSuspList = delayPoint;
 delayPoint->prev = 0;
 if (delayPoint->next != 0)
 {
  delayPoint->next->prev = delayPoint;
 }
 YKScheduler(0);
 YKExitMutex();
}

void YKTickHandler(void)
{
 TCBptr temp, taskHold, comparisonPoint;
 YKTickNum++;
 printNewLine;
 printString("TICK ");
 printInt(YKTickNum);
 printString("\n\r");

 temp = YKSuspList;
 while (temp != 0)
 {
  temp->delay--;
  if (temp->delay == 0)
  {
   temp->state = 1;
   taskHold = temp->next;
   if (temp->prev != 0)
   {
    temp->prev->next = temp->next;
   }
   else{
    YKSuspList = temp->next;
   }
   if (temp->next != 0)
   {
    temp->next->prev = temp->prev;
   }
      comparisonPoint = YKRdyList;

   for (i = 0; i < 6; i ++)
   {
    if (temp->priority < comparisonPoint->priority){
     break;
    }
    else{
     comparisonPoint = comparisonPoint->next;
    }
   }
      if (comparisonPoint->prev == 0){
          YKRdyList = temp;
   }
      else{
          comparisonPoint->prev->next = temp;
   }

      temp->prev = comparisonPoint->prev;
      temp->next = comparisonPoint;
      comparisonPoint->prev = temp;
   temp = taskHold;
  }
  else{
   temp = temp->next;
  }
 }
}

void YKRun(void){
 hasRun = 1;
 YKScheduler(0);
}

void YKEnterISR(void)
{
 ISRDepth++;
}

void YKExitISR(void)
{
 ISRDepth--;
 if (ISRDepth == 0)
 {
  if (hasRun)
  {
   YKScheduler(1);
  }
 }
}

YKSEM* YKSemCreate(int initialValue){
    YKEnterMutex();
    if (YKAvaiSems <= 0){
        YKExitMutex();
        printString("Not enough sems");
        exit(0xff);
    }
    else {
        YKAvaiSems--;
        YKSems[YKAvaiSems].value = initialValue;
        YKSems[YKAvaiSems].blockedOn = 0;
    }
    YKExitMutex();


    return (&(YKSems[YKAvaiSems]));

}

void YKSemPend(YKSEM *semaphore){
    TCBptr temp, temp2, iter;
    int index;

 YKEnterMutex();






    if (semaphore->value > 0){

  semaphore->value--;
        YKExitMutex();
        return;
    }
 semaphore->value--;

    temp = YKRdyList;

    YKRdyList = temp->next;
    if (YKRdyList != 0)
       YKRdyList->prev = 0;

    temp->state = 2;

    if (semaphore->blockedOn == 0){
        semaphore->blockedOn = temp;
        temp->next = 0;
        temp->prev = 0;
    }
    else{
        iter = semaphore->blockedOn;
        temp2 = 0;
        while (iter != 0 && iter->priority < temp->priority){
            temp2 = iter;
            iter = iter->next;
        }
        if (iter == 0){
            temp2->next = temp;
            temp->prev = temp;
            temp->next = 0;
        }
        else{
            temp->next = iter;
            temp->prev = temp2;
            iter->prev = temp;
            if (temp2 == 0)
                semaphore->blockedOn = temp;
            else
                temp2->next = temp;
        }
    }


    YKScheduler(0);

    YKExitMutex();
}

void YKSemPost(YKSEM *semaphore){
    TCBptr temp, temp2;




    YKEnterMutex();
    if (semaphore->value++ >= 0){
        YKExitMutex();
        return;
    }

    temp = semaphore->blockedOn;
    semaphore->blockedOn = temp->next;
    if (semaphore->blockedOn != 0)
        semaphore->blockedOn->prev = 0;

    temp->state = 1;

    temp2 = YKRdyList;
    while (temp2->priority < temp->priority){
        temp2 = temp2->next;
    }
    if (temp2->prev == 0){
        YKRdyList = temp;
    }
    else{
        temp2->prev->next = temp;
    }
    temp->prev = temp2->prev;
    temp->next = temp2;
    temp2->prev = temp;

    if (ISRDepth == 0)
 {

        YKScheduler(0);
 }
    YKExitMutex();
}
