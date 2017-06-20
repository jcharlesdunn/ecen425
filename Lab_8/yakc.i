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
int hasRun = 0;
int idleStk[2048];
int currentEvent = 0;
int queueIndex = 0;

int idxNextAvailSem;

TCBptr YKRdyList;
SEMptr temp;
TCBptr YKAvailTCBList;
TCBptr YKSuspList;
TCBptr YKRunningTask;
TCB YKTCBArray[10 +1];
YKSEM YKSemaphoreArray[6];
YKQ YKQArray[2];
YKEVENT YKEventArray[2];
# 47 "yakc.c"
void YKInitialize(void)
{
 YKEnterMutex();
 YKCtxSwCount = 0;
 YKIdleCount = 0;
 YKTickNum = 0;
 ISRDepth = 0;
 idxNextAvailSem = 0;
 queueIndex = 0;
 YKSave = 0;
 YKRestore = 0;
 YKRdyList = 0;
 YKSuspList = 0;
 YKRunningTask = 0;
 hasRun = 0;

    YKAvailTCBList = &(YKTCBArray[0]);




    for (i = 0; i < 10; i++){
        YKTCBArray[i].next = &(YKTCBArray[i+1]);


    }
    YKTCBArray[10].next = 0;
    YKTCBArray[10].prev = 0;

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
 YKEnterMutex();
 if (YKRunningTask != YKRdyList) {
  YKCtxSwCount++;
  YKDispatcher(isSaved);
 }
 YKExitMutex();

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
 newPoint->eventMask = 0;
 newPoint->eventMode = 0;

    if (YKRdyList == 0) {

        YKRdyList = newPoint;
        newPoint->next = 0;
        newPoint->prev = 0;
    }
    else {
        comparisonPoint = YKRdyList;





  for (i = 0; i < 10; i ++) {
   if (newPoint->priority < comparisonPoint->priority) {
    break;
   }
   else {
    comparisonPoint = comparisonPoint->next;
   }
  }


        if (comparisonPoint->prev == 0) YKRdyList = newPoint;


        else comparisonPoint->prev->next = newPoint;

        newPoint->prev = comparisonPoint->prev;
        newPoint->next = comparisonPoint;
        comparisonPoint->prev = newPoint;
    }

 stackPoint = (unsigned *)taskStack;




 for (i = 0; i < 13; i++) {
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
    }
 YKExitMutex();
}





void YKDelayTask(unsigned count)
{
 TCBptr delayPoint;
 if (count == 0) return;
 YKEnterMutex();
 delayPoint = YKRdyList;
 YKRdyList = delayPoint->next;
 if (YKRdyList != 0) {
  YKRdyList->prev = 0;
 }

 delayPoint->state = 0;
 delayPoint->delay = count;

 delayPoint->next = YKSuspList;
 YKSuspList = delayPoint;
 delayPoint->prev = 0;
 if (delayPoint->next != 0) {
  delayPoint->next->prev = delayPoint;
 }
 YKScheduler(0);
 YKExitMutex();
}





void YKTickHandler(void) {
 TCBptr temp, taskHold, comparisonPoint;
 YKTickNum++;

 temp = YKSuspList;
 while (temp != 0) {
  temp->delay--;
  if (temp->delay == 0) {
   temp->state = 1;
   taskHold = temp->next;
   if (temp->prev != 0) {
    temp->prev->next = temp->next;
   }
   else {
    YKSuspList = temp->next;
   }
   if (temp->next != 0) {
    temp->next->prev = temp->prev;
   }
      comparisonPoint = YKRdyList;







   for (i = 0; i < 10; i ++) {
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
      else {

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


void YKEnterISR(void) {
 ISRDepth++;
}


void YKExitISR(void) {
 ISRDepth--;
 if ((ISRDepth == 0)) {
  if (hasRun) {
   YKScheduler(1);
  }
 }
}
# 310 "yakc.c"
YKSEM* YKSemCreate(int initialValue) {
 if (initialValue >= 0) {
  SEMptr currSem = &YKSemaphoreArray[idxNextAvailSem];
  idxNextAvailSem++;
  currSem->value = initialValue;
  currSem->waitList = 0;
  return currSem;
 }
}





void YKSemPend(YKSEM* currSem) {
 TCBptr temp, comparisonPoint;
 YKEnterMutex();
 if( ( (currSem->value) <= 0) && (hasRun == 1) ) {
  int value = currSem->value;
  value = value - 1;
  currSem->value = value;
  temp = YKRdyList;
  YKRdyList = temp->next;
  if (YKRdyList != 0) {
   YKRdyList->prev = 0;
  }
  temp->state = 0;
  comparisonPoint = currSem->waitList;
  if (comparisonPoint == 0)
  {
   currSem->waitList = temp;
   currSem->waitList->next = 0;
   currSem->waitList->prev = 0;
  }
  else{
   for (i = 0; i < 10; i ++) {
    if (temp->priority < comparisonPoint->priority) {
     break;
    }
    else{
     comparisonPoint = comparisonPoint->next;
    }
   }
   if (comparisonPoint->prev == 0) {
       currSem->waitList = temp;
   }
   else {
       comparisonPoint->prev->next = temp;
   }
   temp->prev = comparisonPoint->prev;
   temp->next = comparisonPoint;
   comparisonPoint->prev = temp;
  }
  YKScheduler(0);
 }
 else{
  int value = currSem->value;
  value = value - 1;
  currSem->value = value;
 }
 YKExitMutex();
}





void YKSemPost(YKSEM* currSem) {
 TCBptr temp, comparisonPoint;
 YKEnterMutex();
 (currSem->value)++;

 if (currSem->waitList != 0) {
  temp = currSem->waitList;
  currSem->waitList = temp->next;
  if (currSem->waitList != 0) {
   currSem->waitList->prev = 0;
  }
  temp->state = 1;
  comparisonPoint = YKRdyList;
  if (comparisonPoint == 0)
  {
   YKRdyList = temp;
   YKRdyList->next = 0;
   YKRdyList->prev = 0;
  }
  else{
   for (i = 0; i < 10; i ++) {
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
   else {
       comparisonPoint->prev->next = temp;
   }
   temp->prev = comparisonPoint->prev;
   temp->next = comparisonPoint;
   comparisonPoint->prev = temp;
  }
 }
 if (ISRDepth == 0) { YKScheduler(0); }
 YKExitMutex();
}
# 431 "yakc.c"
YKQ *YKQCreate(void **start, unsigned size) {
 if (size > 0 ) {
  YKQptr currQueue = &YKQArray[queueIndex];
  queueIndex++;
  currQueue->head = 0;
  currQueue->tail = 0;
  currQueue->items = 0;
  currQueue->base = start;
  currQueue->size = size;
  currQueue->waitList = 0;
  return currQueue;
 }
}





void *YKQPend(YKQ *queue) {
 TCBptr temp, comparisonPoint;
 void* message;
 YKEnterMutex();
 if ((queue->items == 0) && (hasRun == 1)) {
  temp = YKRdyList;
  YKRdyList = temp->next;
  if (YKRdyList != 0)
   YKRdyList->prev = 0;
  temp->state = 0;
  comparisonPoint = queue->waitList;
  if (comparisonPoint == 0)
  {
   queue->waitList = temp;
   queue->waitList->next = 0;
   queue->waitList->prev = 0;
  }
  else
  {
   for (i = 0; i < 10; i ++) {
    if (temp->priority < comparisonPoint->priority)
     break;
    else
     comparisonPoint = comparisonPoint->next;
   }
   if (comparisonPoint->prev == 0)
    queue->waitList = temp;
   else
    comparisonPoint->prev->next = temp;
   temp->prev = comparisonPoint->prev;
   temp->next = comparisonPoint;
   comparisonPoint->prev = temp;
  }
  YKScheduler(0);
  (queue->items)--;
  message = queue->base[queue->tail];
  if (queue->tail == ((queue->size)-1))
  {
   queue->tail = 0;
  }
  else if (queue->items == 0)
  {
  }
  else
  {
   (queue->tail)++;
  }
  YKExitMutex();
  return message;
 }
 else {
  (queue->items)--;
  message = queue->base[queue->tail];
  if (queue->tail == ((queue->size)-1))
  {
   queue->tail = 0;
  }
  else if (queue->items == 0)
  {
  }
  else
  {
   (queue->tail)++;
  }
  YKExitMutex();
  return message;
 }
}





int YKQPost(YKQ *queue, void *msg) {

 TCBptr temp, comparisonPoint, delay;
 int maxPriority = 1000;
 YKEnterMutex();
 if (queue->items == queue->size)
  return 0;
 if (queue->waitList != 0) {
  delay = queue->waitList;
  while (delay != 0)
  {
   if (delay->priority < maxPriority)
   {
    maxPriority = delay->priority;
   }
   delay = delay->next;
  }
  delay = queue->waitList;
  while (delay != 0)
  {
   if (delay->priority == maxPriority)
   {
    temp = delay;
    break;
   }
   delay = delay->next;
  }
  if (temp->prev == 0)
  {
   queue->waitList = temp->next;
   if (queue->waitList != 0)
   {
    queue->waitList->prev = 0;
   }
  }
  else
  {
   if (temp->next == 0)
   {
    temp->prev->next = 0;
   }
   else
   {
    temp->prev->next = temp->next;
    temp->next->prev = temp->prev;
   }
  }

  temp->state = 1;
  comparisonPoint = YKRdyList;
  if (comparisonPoint == 0) {
   YKRdyList = temp;
   YKRdyList->next = 0;
   YKRdyList->prev = 0;
  }
  else{
   for (i = 0; i < 10; i ++) {
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
   else {
       comparisonPoint->prev->next = temp;
   }

   temp->prev = comparisonPoint->prev;
   temp->next = comparisonPoint;
   comparisonPoint->prev = temp;
  }
 }
 if (queue->head == ((queue->size)-1))
 {
  queue->head = 0;
 }
 else if (queue->items == 0) {}
 else
 {
  (queue->head)++;
 }
 queue->base[queue->head] = msg;
 (queue->items)++;
 if (ISRDepth == 0) { YKScheduler(0); }
 YKExitMutex();
 return 1;
}
# 632 "yakc.c"
YKEVENT *YKEventCreate(unsigned initialValue) {
  Eventptr currEvent;
  YKEnterMutex();
  currEvent = &YKEventArray[currentEvent];
  currEvent->eventGroup = initialValue;
  currEvent->waitList = 0;
  currentEvent++;
  YKExitMutex();
  return currEvent;
}
# 656 "yakc.c"
unsigned YKEventPend(YKEVENT *event, unsigned eventMask, int waitMode) {
 TCBptr temp, temp2, iter;
 unsigned newEventGroup;
 YKEnterMutex();
 if (eventMask == 0)
 {
  newEventGroup = event->eventGroup;
  YKExitMutex();
  return newEventGroup;
 }
 if ((waitMode == 0) && (((event->eventGroup) & (eventMask)) != 0))
 {
  newEventGroup = event->eventGroup;
  YKExitMutex();
  return newEventGroup;
 }
 if ((waitMode == 1) && (((event->eventGroup) & (eventMask)) == eventMask))
 {
  newEventGroup = event->eventGroup;
  YKExitMutex();
  return newEventGroup;
 }
 temp = YKRdyList;
 YKRdyList = temp->next;
 if (YKRdyList != 0)
 {
  YKRdyList->prev = 0;
 }
 temp->state = 0;

 temp->eventMask = eventMask;
 temp->eventMode = waitMode;


 temp->next = event->waitList;
 event->waitList = temp;
 temp->prev = 0;
 if (temp->next != 0) {
  temp->next->prev = temp;
 }
 YKScheduler(0);
 YKExitMutex();
 return event->eventGroup;

}
# 711 "yakc.c"
void YKEventSet(YKEVENT *event, unsigned eventMask) {
 TCBptr temp, taskHold, comparisonPoint;
 unsigned newEventGroup;
 int taskReady = 0;
 YKEnterMutex();

 newEventGroup = (event->eventGroup | eventMask);
 event->eventGroup = newEventGroup;
 temp = event->waitList;

 while (temp != 0) {

  if (((temp->eventMode == 0) && (((event->eventGroup) & (temp->eventMask)) != 0)) || ((temp->eventMode == 1) && (((temp->eventMask) & (event->eventGroup)) == temp->eventMask))) {
   temp->state = 1;
   taskHold = temp->next;
   if (temp->prev != 0) {
    temp->prev->next = temp->next;
   }
   else {
    event->waitList = temp->next;
   }
   if (temp->next != 0) {
    temp->next->prev = temp->prev;
   }
      comparisonPoint = YKRdyList;
# 744 "yakc.c"
   while (comparisonPoint->priority < temp->priority)
   {
    comparisonPoint = comparisonPoint->next;
   }
      if (comparisonPoint->prev == 0){



          YKRdyList = temp;
   }
      else {

          comparisonPoint->prev->next = temp;

   }

      temp->prev = comparisonPoint->prev;
      temp->next = comparisonPoint;
      comparisonPoint->prev = temp;
   temp = taskHold;
   taskReady = 1;
  }
  else{
   temp = temp->next;
  }
 }
 if ((taskReady == 1) && (ISRDepth == 0))
 {
  YKScheduler(0);
 }
 YKExitMutex();

}







void YKEventReset(YKEVENT *event, unsigned eventMask) {
 unsigned newEventGroup;
 YKEnterMutex();

 newEventGroup = ((event->eventGroup) & ~(eventMask));
 event->eventGroup = newEventGroup;
 YKExitMutex();
}





void printLists(void){
 struct taskblock* tempPoint;
 printNewLine();
 printString("Tasks in the Ready List:");
 printNewLine();
 tempPoint = YKRdyList;
 while(tempPoint != 0){
  printString("Priority: 0x");
  printByte(tempPoint->priority);
  printString(" / Stack Pointer: 0x");
  printWord((int)tempPoint->stackptr);
  printString(" / Delay Count: 0x");
  printByte(tempPoint->delay);
  printNewLine();
  tempPoint = tempPoint->next;
 }
 printNewLine();
 printString("Tasks in the Delay List:");
 printNewLine();
 tempPoint = YKSuspList;
 while(tempPoint != 0){
  printNewLine();
  printString("Priority: 0x");
  printByte(tempPoint->priority);
  printString(" / Stack Pointer: 0x");
  printWord((int)tempPoint->stackptr);
  printString(" / Delay Count: 0x");
  printByte(tempPoint->delay);
  printNewLine();
  tempPoint = tempPoint->next;
 }
 printNewLine();
 printString("Tasks in the Delay List:");
 printNewLine();
 temp = &(YKSemaphoreArray[0]);
 printNewLine();
 printString("value: 0x");
 printInt(temp->value);
 printNewLine();
 tempPoint = temp->waitList;
 while(tempPoint != 0){
  printNewLine();
  printString("Priority: 0x");
  printByte(tempPoint->priority);
  printString(" / Stack Pointer: 0x");
  printWord((int)tempPoint->stackptr);
  printString(" / Delay Count: 0x");
  printByte(tempPoint->delay);
  printNewLine();
  tempPoint = tempPoint->next;
 }
}
