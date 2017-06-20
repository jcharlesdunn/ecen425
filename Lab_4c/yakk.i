# 1 "yakk.c"
# 1 "<built-in>"
# 1 "<command-line>"
# 1 "/usr/include/stdc-predef.h" 1 3 4
# 1 "<command-line>" 2
# 1 "yakk.c"
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
# 2 "yakk.c" 2
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
# 3 "yakk.c" 2
# 1 "yaku.h" 1
# 4 "yakk.c" 2


unsigned int YKCtxSwCount = 0;


unsigned int YKIdleCount;
unsigned int YKISRDepth;
unsigned int YKTickNum;

int i = 0;

int* YKSave;
int* YKRestore;

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

TCBptr YKRdyList;

TCBptr YKAvailTCBList;
TCBptr YKSuspList;
TCBptr YKRunningTask;
TCB YKTCBArray[4 +1];

int hasRun = 0;
int idleStk[2048];

void save();

void YKInitialize(void)
{
    YKEnterMutex();

    YKCtxSwCount = 0;
    YKIdleCount = 0;

    YKSave = 0;
    YKRestore = 0;
    YKRdyList = 0;
    YKSuspList = 0;
    YKRunningTask = 0;
    hasRun = 0;

    YKAvailTCBList = &(YKTCBArray[0]);



    for (i = 0; i < 4; i++){
        YKTCBArray[i].next = &(YKTCBArray[i+1]);



    }
    YKTCBArray[4].next = 0;
    YKTCBArray[4].prev = 0;

    YKNewTask(YKIdleTask,(void *) &(idleStk[2048]),100);
}



void YKIdleTask(){
 printString("IDLE TASK\n");
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
    TCBptr tempPtr0, tempPtr1;

    YKEnterMutex();

    tempPtr0 = YKAvailTCBList;
    if(tempPtr0 == 0){
        return;
    }

    YKAvailTCBList = tempPtr0->next;

    tempPtr0->priority = priority;
    tempPtr0->delay = 0;

    if (YKRdyList == 0)
    {
        YKRdyList = tempPtr0;
        tempPtr0->next = 0;
        tempPtr0->prev = 0;
    }
    else
    {
        tempPtr1 = YKRdyList;

        for (i = 0; i < 4; i ++)
        {
            if (tempPtr0->priority < tempPtr1->priority){
                break;
            }
            else{

                tempPtr1 = tempPtr1->next;
            }
        }
        if (tempPtr1->prev == 0){
            YKRdyList = tempPtr0;
        }
        else{
            tempPtr1->prev->next = tempPtr0;
        }
        tempPtr0->prev = tempPtr1->prev;
        tempPtr0->next = tempPtr1;
        tempPtr1->prev = tempPtr0;
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

    tempPtr0->stackptr = (void *)stackPoint;

    if(hasRun == 1) {
        YKScheduler(1);
        YKExitMutex();
    }
}




void YKDelayTask(unsigned count){

 TCBptr tempPtr0;
 TCBptr tempPtr1;
 TCBptr tempPtr2;

 if(count == 0){
  return;
 }
 YKEnterMutex();

 tempPtr0 = YKRdyList;
 tempPtr0->delay = count;


 tempPtr1 = YKSuspList;

 tempPtr2 = YKRdyList->next;


 if (YKSuspList == 0)
    {
        YKSuspList = tempPtr0;
        tempPtr0->next = 0;
        tempPtr0->prev = 0;
    }
 else
 {
  while(tempPtr1->next != 0)
  {
   tempPtr1 = tempPtr1->next;
  }
  tempPtr1->next = tempPtr0;
  tempPtr1->next->prev = tempPtr1;
  tempPtr1->next->next = 0;
 }

 tempPtr2->prev = 0;
 YKRdyList = tempPtr2;


 YKScheduler(0);
 YKExitMutex();

}





void YKTickHandler(void)
{
 TCBptr temp, taskHold, comparisonPoint;
 YKTickNum++;
 printNewLine;
 printString("\n");
 printString("TICK: ");
 printInt(YKTickNum);
 printString("\n\r");

 temp = YKSuspList;
 while (temp != 0)
 {
  temp->delay--;
  if (temp->delay == 0)
  {
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







   for (i = 0; i < 4; i ++)
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


void YKEnterISR(void){

 YKISRDepth++;
}


void YKExitISR(void){

 YKISRDepth--;

 if(YKISRDepth == 0) {
  if(hasRun == 1)
  {
   YKScheduler(1);
  }
 }
}
