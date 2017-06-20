
#define EVENT_WAIT_ALL 1
#define EVENT_WAIT_ANY 0
/********************************************************************************
**										Structs								   **
********************************************************************************/
typedef struct taskblock *TCBptr;
typedef struct taskblock
{						/* the TCB struct definition */
    void *stackptr;		/* pointer to current top of stack */
    int state;			/* current state */
    int priority;		/* current priority */
    int delay;			/* #ticks yet to wait */
    TCBptr next;		/* forward ptr for dbl linked list */
    TCBptr prev;		/* backward ptr for dbl linked list */
	unsigned eventMask;
	unsigned eventMode;
}  TCB;

typedef struct semaphore *SEMptr;
typedef struct semaphore{
	int value;
	TCBptr waitList;
} YKSEM;

typedef struct YKqueue *YKQptr;
typedef struct YKqueue{
	int size;	// size of queue -- doesn't change
	int items;	// number of messages in queue -- will change
	int head;	// index of oldest message in queue
	int tail;	// index of next location to add message 
	void** base;
	TCBptr waitList;
} YKQ;

typedef struct WhyKayEvent *Eventptr;
typedef struct WhyKayEvent {
	unsigned eventGroup;	//Event group
	TCBptr waitList;
} YKEVENT;

extern unsigned int YKIdleCount;				//idle count for idle task
extern unsigned int YKCtxSwCount;				//Count for context switches
extern unsigned int YKTickNum; 
//extern YKSEM* PSemPtr;	
//extern YKSEM* SSemPtr;
//extern YKSEM* WSemPtr;
//extern YKSEM* NSemPtr;

void YKInitialize();							//Initialize the kernal

void YKEnterMutex(void);						//Disable interrupts

void YKExitMutex(void);							//Enable interupts

void YKScheduler(int save);						//Find most urgent task

void YKDispatcher(int save);					//Run task			

void YKIdleTask();								//Idle task, always running
	
void YKNewTask(void (* task)(void), void *taskStack, unsigned char priority); 	//Create a new task

void YKDelayTask(unsigned count);				//Delays a task

void YKTickHandler(void);						//Decrement the delay ticks

void YKRun(void);								//Run the kernel

void YKEnterISR(void);							//Increments the ISR depth count

void YKExitISR(void);							//Decrements the ISR depth count and calls the sceduler

YKSEM* YKSemCreate(int);						// Create semaphore

void YKSemPend(YKSEM*);							// Pend semaphore 

void YKSemPost(YKSEM*);							// Post semaphore 

void printLists(void);							// Debugging

YKQ *YKQCreate(void **start, unsigned size);	// Creates message queue

void *YKQPend(YKQ *queue);						// Removes oldest message from indicated queue
	
int YKQPost(YKQ *queue, void *msg);				// Places message in queue

YKEVENT *YKEventCreate(unsigned initialValue);								// Event Create 

unsigned YKEventPend(YKEVENT *event, unsigned eventMask, int waitMode); 	// Event Pend

void YKEventSet(YKEVENT *event, unsigned eventMask);						// Event Set

void YKEventReset(YKEVENT *event, unsigned eventMask); 						// Reset Event
