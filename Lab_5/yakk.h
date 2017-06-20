
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
}  TCB;

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




