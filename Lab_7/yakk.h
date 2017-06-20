
#define EVENT_WAIT_ANY 0x1
#define EVENT_WAIT_ALL 0x2

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
}  TCB;

typedef struct semaphore
{
	int value;
	TCBptr blockedOn;
} YKSEM;

//Create YKQ struct
typedef struct YKQueue {
	unsigned int length;
	unsigned int head; 		//index of head
	unsigned int tail;		//index of tail
	int full;				//esentially work like bools
	int empty;
	void** msgQ;			// pointer to the queue
	TCBptr waitList;		// pointer to the queue waitlist(?)
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



