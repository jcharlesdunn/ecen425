
extern unsigned int YKIdleCount;		//idle count for idle task
extern unsigned int YKCtxSwCount;		//Count for context switches

void YKInitialize();					//Initialize the kernal

void YKEnterMutex();					//Disable interrupts

void YKExitMutex();						//Enable interupts

void YKScheduler(int save);	//Find most urgent task

void YKDispatcher(int save);	//Run task			

void YKIdleTask();						//Idle task, always running

void YKNewTask(void (* task)(void), void *taskStack, unsigned char priority); 	//Create a new task

void YKDelayTask(unsigned count);		//Delays a task

void YKTickHandler(void);				//Decrement the delay ticks

void YKRun();							//Run the kernal

void YKEnterISR(void);			//This function increments the ISR depth count

void YKExitISR(void);			//This function decrements the ISR depth count, and calls the sceduler




