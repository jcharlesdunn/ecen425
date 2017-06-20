extern unsigned int YKIdleCount;		//idle count for idle task
extern unsigned int YKCtxSwCount;		//Count for context switches

void YKInitialize();					//Initialize the structures for kernal
void YKEnterMutex();					//Disable interrupts
void YKExitMutex();						//Enable interupts
void YKScheduler(int save);				//Takes highest priority task and passes it to YKDispatcher
void YKDispatcher(int save);			//Runs highest priority task			
void YKIdleTask();						//Idle task
void YKNewTask(void (* task)(void), void *taskStack, unsigned char priority); 	//Create a new task
void YKRun();							//Run the kernal



// New Stuff

extern unsigned int YKTickNum; //This is an unsigned int that must be incremented each time the kernel's tick handler runs.


//YKDelayTask - Delays a task for specified number of clock ticks
//YKEnterISR - Called on entry to ISR
//YKExitISR - Called on exit from ISR
//YKTickHandler - The kernel's timer tick interrupt handler
//YKTickNum - Global variable incremented by the kernel's tick handler

void YKDelayTask(unsigned count); //This function delays a task for the specified number of clock ticks. After taking care of all required bookkeeping to mark the change of state for the currently running task, this function calls the scheduler. After the specified number of ticks, the kernel will mark the task ready. If the function is called with a count argument of 0 then it should not delay and should simply return. This function is called only by tasks, and never by interrupt handlers or ISRs.
void YKEnterISR(void); //This function must be called near the beginning of each ISR just before interrupts are re-enabled. This simply increments a counter representing the ISR call depth.
void YKExitISR(void); //This function must be called near the end of each ISR after all handlers are called and while interrupts are disabled. It decrements the counter representing ISR call depth and calls the scheduler if the counter is zero. In the case of nested interrupts, the counter is zero only when exiting the last ISR, so it indicates when control will return to task code rather than another ISR. If it is the last ISR then control should return to the highest priority ready task. This may not be the task that was interrupted by this ISR if the actions of the interrupt handler made a higher priority task ready.
void YKTickHandler(void); //This function must be called from the tick ISR each time it runs. YKTickHandler is responsible for the bookkeeping required to support the timely reawakening of delayed tasks. (If the specified number of clock ticks has occurred, a delayed task is made ready.) The tick ISR may also call a user tick handler if the user code requires actions to be taken on each clock tick.
