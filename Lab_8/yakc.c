#include "clib.h"
#include "yakk.h"
#include "yaku.h"

#define DELAYED 0
#define READY 1

/********************************************************************************
**										Globals								   **
********************************************************************************/
unsigned int YKCtxSwCount = 0; 		//Global variable tracking context switches
unsigned int YKIdleCount; 			//Global variable used by idle task
unsigned int YKTickNum; 			//Global variable incremented by tick handler
unsigned int ISRDepth;

int i = 0; 							//for loop. Cannot be local
int* YKSave; 						//Pointer to the value that needs to be saved
int* YKRestore; 					//Pointer to the value that needs to be restored
int hasRun = 0; 					//Set the flag once, YKRun has executed
int idleStk[IDLE_STACK_SIZE]; 		//Declare the idle stack.
int currentEvent = 0;
int queueIndex = 0;

int idxNextAvailSem;

TCBptr YKRdyList; 			//Pointer to the ready list. First item. Highest priority. Ready tasks
SEMptr temp;
TCBptr YKAvailTCBList; 		//Pointer to the available list. Available items
TCBptr YKSuspList;			//Delayed task list
TCBptr YKRunningTask; 		//Pointer to the task that is currently running
TCB YKTCBArray[MAXTASKS+1]; //TCB array
YKSEM YKSemaphoreArray[6];  //Array which contains all of the semaphores
YKQ YKQArray[2]; 			//Array which contains all of the semaphores
YKEVENT YKEventArray[2];	//Array of events

/*
*********************************************************************************
**																			   **
**							 RTOS FUNCTIONS									   **
**																			   **
*********************************************************************************
*/

/********************************************************************************
**								YKInitialize								   **
********************************************************************************/
void YKInitialize(void) 		
{
	YKEnterMutex();					//Disable the interrupts
	YKCtxSwCount = 0; 				//Init Globals
	YKIdleCount = 0; 						
	YKTickNum = 0; 				
	ISRDepth = 0;	
	idxNextAvailSem	= 0;
	queueIndex = 0;
	YKSave = NULL;
	YKRestore = NULL;
	YKRdyList = NULL;				//Set the ready list head to null for init
	YKSuspList = NULL;				//Set the delay list head to null for init
	YKRunningTask = NULL;			//Set the pointer to the running task to null
	hasRun = 0;						//Set the hasRun flag to low for init
	
    YKAvailTCBList = &(YKTCBArray[0]); 		 		// Initialize locations for TCB	
	// Set the available TCB list pointer to the memory address of the TCB array 
	// This space was allocated for the TCB's
	
	//Create a linked list of TCB's
    for (i = 0; i < MAXTASKS; i++){					//iterate through TCB array
        YKTCBArray[i].next = &(YKTCBArray[i+1]);	
		//Sets pointer of next TCB in array to the address of the next TCB space
        //YKTCBArray[MAXTASKS].prev = NULL; 
    }
    YKTCBArray[MAXTASKS].next = NULL;				//Last position in array has a null pointer to next
    YKTCBArray[MAXTASKS].prev = NULL;				//Last position in array has a null pointer to prev

    YKNewTask(YKIdleTask,(void *) &(idleStk[IDLE_STACK_SIZE]),100); 
	//Create idle task with low priority assignment, (Higher number = lower priority)
}


/********************************************************************************
**								YK Idle Task								   **
********************************************************************************/
void YKIdleTask(){
    while(1){					//Run forever to be interrupted
        YKEnterMutex();			//Disable interrupts during atomic section
        YKIdleCount++;			//Increment the idle count
        YKExitMutex();			//Enable interrupts
    }
}


/********************************************************************************
**								   Scheduler  								   **
********************************************************************************/
void YKScheduler(int isSaved){
	YKEnterMutex();
	if (YKRunningTask != YKRdyList) { 				//Highest priority ready task not running
		YKCtxSwCount++;								//Task has switched -> Increment counter
		YKDispatcher(isSaved);						//Run the dispatcher; Don't save context
	}
	YKExitMutex();
	//If the highest priority task is already running, return
}


/********************************************************************************
**								    New Task								   **
********************************************************************************/
void YKNewTask(void (* task)(void), void *taskStack, unsigned char priority)
{
    unsigned *stackPoint;							//Pointer to the stack
    TCBptr newPoint, comparisonPoint;				//Create 2 task pointers
    YKEnterMutex();									//Disable interrupts
    newPoint = YKAvailTCBList;  					//Store pointer of available TCB list
    if(newPoint == NULL){				
        return;										//No available RCB List -> return
    } 
    
    YKAvailTCBList =  newPoint->next;
	//Move available TCB list pointer to next pos since it is now next available
										
	//With the new pointer, create a new task by setting priority and state									
    newPoint->priority = priority;					//Set priority (from param)
    newPoint->delay = 0; 							//Set delay to 0 (no delay)
	newPoint->state = READY;						//Set state to ready
	newPoint->eventMask = 0;
	newPoint->eventMode = 0;
	
    if (YKRdyList == NULL) { 						//Nothing in ready list; First time through  
   		//Nothing is ready -> add this task at the head; Highest priority
        YKRdyList = newPoint;						//Add new TCB to the head of the ready list
        newPoint->next = NULL;						//Since only item in list, set next to null
        newPoint->prev = NULL;						//Since only item in list, set prev to null
    }
    else {         									//List is not empty; some ready tasks
        comparisonPoint = YKRdyList;   				//Set comparison pointer to the head of the ready list
		//Check if tasks in  ready list are higher priority than new task.
		
		/*This loop iterates though all of the ready tasks in the task list. As soon as new 
		  point has lower priority than the point in ready list, it breaks out. We know that 
		  new point will run before it in the ready list. Idle task is always least urgent */
		for (i = 0; i < MAXTASKS; i ++) {
			if (newPoint->priority < comparisonPoint->priority) {	
				break;	//Break if new point has lower priority than comparison task
			}
			else { 		//Comparison point is more urgent; keep traversing list
				comparisonPoint = comparisonPoint->next;
			}
		}
		/*If comparison pointer doesn't have task in front of it after comparison, the new
		point didn't iterate through while loop -> the new point is most urgent task*/
        if (comparisonPoint->prev == NULL) YKRdyList = newPoint;
		/*Set new point in front of the comparison point that ended the loop
		This is the priority position that new point belongs in */
        else comparisonPoint->prev->next = newPoint;		
		//Link the new point in front of the comparison point that it ended on
        newPoint->prev = comparisonPoint->prev;		//set the new point's previous task	
        newPoint->next = comparisonPoint;      		//Set the new point's next task
        comparisonPoint->prev = newPoint;			//Link comparisson task to new point
    }
	
	stackPoint = (unsigned *)taskStack;		
	//Assign local variable stackPoint to the taskStack argument. Temp pointer

	/*The stack pointer passed in points to the top of the stack. The stack grows down, so we
	need to decrement the temp stack pointer to set necessary info in the stack for new task*/
	for (i = 0; i < 13; i++) {					//Decrement temp stack pointer, set stack info
		if (i == 1){							//'i=1' is stack position for interrupt flag
			stackPoint[0] = 0x0200; 			//Set current stack pointer for interrupt flag
		}
		else if (i == 3){						//Wait until i=3
			stackPoint[0] = (unsigned)task;		//Set the current stack pointer to the task
		}
		else{									//No special case in the stack has taken place
			stackPoint[0] = 0;					//Set current stack position to 0. Inits value
		}
		stackPoint--;							//Decrement stack pointer.
	}   
 
    newPoint->stackptr = (void *)stackPoint;    //Set stack pointer of task(use temp stack ptr)
    if(hasRun == 1) {							//If kernel has started, run scheduler
        YKScheduler(0);		
    }  
	YKExitMutex();							//Enable interrupts
}


/********************************************************************************
**								  Delay Task								   **
********************************************************************************/
void YKDelayTask(unsigned count)		
{
	TCBptr delayPoint;					//Create a task pointer for delayed task
	if (count == 0) return;
	YKEnterMutex();						//Disable interrupts
	delayPoint = YKRdyList;				//Task to be delayed; head of ready list
	YKRdyList = delayPoint->next; 		//Move ready list to next one, after delayed task
	if (YKRdyList != NULL) {			//Make sure next task in the ready list exists
		YKRdyList->prev = NULL;			//Link the tasks by making this task the head
	}
	//Found the task to be delayed (delayPoint), change TCB to delayed state
	delayPoint->state = DELAYED;		//Set the state to delayed
	delayPoint->delay = count;			//Set the delay count
	//Add newly delayed task to delay list- It can go in front, not priority based
	delayPoint->next = YKSuspList;		//Put new delayed task at head of delay list. Set next to previous head
	YKSuspList = delayPoint;			//Set head of the delay list to new task, since it took over.
	delayPoint->prev = NULL;			//Since at head, Prev task must be NULL
	if (delayPoint->next != NULL) {		//There is a next task, so we need to link back on that task
		delayPoint->next->prev = delayPoint;	//Link back to the current task so linked list is complete.
	}
	YKScheduler(0); 					//Call scheduler
	YKExitMutex();						//Enable interrupts
}


/********************************************************************************
**								Tick Handler								   **
********************************************************************************/
void YKTickHandler(void) {						//Decrement the delay ticks
	TCBptr temp, taskHold, comparisonPoint;		//Create a pointer for logic
	YKTickNum++;								//Increment tick number
	//Grab the head of the delay list to go through each task in it.
	temp = YKSuspList; 							//Set pointer to delay task head
	while (temp != NULL) {						//Traverse list
		temp->delay--; 							//Decrement the delay count in the task
		if (temp->delay == 0) {					//If delay count is 0, unblock task
			temp->state = READY;				//change the state of the task to ready
			taskHold = temp->next;				//Hold the position of task by setting it to temp
			if (temp->prev != NULL) {			//Temp is not at the head of the delay list 
				temp->prev->next = temp->next;	//link the previous task to the next one, skipping the current task
			}
			else {								//Temp is at the head of the delay list
				YKSuspList = temp->next;		//Since we are taking the head, set the head to the next in the list.	
			}
			if (temp->next != NULL)	{			//If there is a previous task
				temp->next->prev = temp->prev;	//link the next task to the previous one, skipping the current task
			}
		    comparisonPoint = YKRdyList;		//Set comparison pointer to the head of the ready list
			//Check if tasks in  ready list are higher priority than new task.
			
			/*This loop iterates though all of the ready tasks in the task list.
			 *As soon as the new point has a lower priority(more urgent) than the point in the ready list
			 *We can break out, and know that new point will go before it in the ready list.
			 *The idle task will always be less urgent than the new task
			 */
			for (i = 0; i < MAXTASKS; i ++) {
				if (temp->priority < comparisonPoint->priority){	//Find when new point has a lower priority number (more urgent)
					break;												//We have found where new point belongs
				}
				else{ 											//Comparison point is more urgent than the new point
																//New point belongs further in the ready list
					comparisonPoint = comparisonPoint->next;	//Go to the next point in the ready list, and compare with it.
				}
			}
		    if (comparisonPoint->prev == NULL){ 			// if the comparison pointer doesn't have a task in front of it after comparison
															//then new point didn't do an iteration through the while loop
															//It never iterated to other points in the while loop
															//This means that new point is the most urgent task
		        YKRdyList = temp;							//Goes in the front of the list. Most ready task
			}
		    else {											//New point is not the most urgent task, the while loop executed
															//so the most urgent ready item is still the most urgent
		        comparisonPoint->prev->next = temp;			//Set new point in front of the comparison point that ended the loop
															//This is the priority position that new point belongs in
			}
			//Link the new point in front of the comparison point that it ended on
		    temp->prev = comparisonPoint->prev;			//set the new point's previous task	
		    temp->next = comparisonPoint;      			//Set the new point's next task
		    comparisonPoint->prev = temp;				//Link the comparisson task with new point
			temp = taskHold;
		}
		else{
			temp = temp->next;							//Go to next in delay list, to check in this while loop
		}
	}
}

void YKRun(void){
	hasRun = 1; 		//Set the hasRun flag to high, so tasks can begin to execute
	YKScheduler(0);		//Run the scheduler to start the tasks. Don't save the context of the task
}

// Increments ISR depth count
void YKEnterISR(void) {		
	ISRDepth++;				
}

// Decrements ISR depth count and call Scheduler 
void YKExitISR(void) {	
	ISRDepth--;					
	if ((ISRDepth == 0)) {		//If depth count is 0, no more nesting
		if (hasRun) {			//Call scheduler if RTOS is running
			YKScheduler(1);		//Don't save context
		}
	}
}

/*
*********************************************************************************
**																			   **
**							     SEMAPHORE ROUTINES							   **
**																			   **
*********************************************************************************
*/

/********************************************************************************
**							   Create Semaphore								   **
********************************************************************************/
YKSEM* YKSemCreate(int initialValue) {
	if (initialValue >= 0) {
		SEMptr currSem = &YKSemaphoreArray[idxNextAvailSem];
		idxNextAvailSem++;
		currSem->value = initialValue;
		currSem->waitList = NULL;
		return currSem;
	}
}


/********************************************************************************
**							   Pend on Semaphore							   **
********************************************************************************/
void YKSemPend(YKSEM* currSem) {
	TCBptr temp, comparisonPoint;
	YKEnterMutex();	
	if( ( (currSem->value) <= 0) && (hasRun == 1) ) { // wait for semaphore
		int value = currSem->value;
		value = value - 1;
		currSem->value = value;
		temp = YKRdyList;
		YKRdyList = temp->next;
		if (YKRdyList != NULL) {			//Make sure next task in the ready list exists
			YKRdyList->prev = NULL;			//Link the tasks by making this task the head
		}
		temp->state = DELAYED;				//Set the state to delayed
		comparisonPoint = currSem->waitList;
		if (comparisonPoint == NULL)
		{
			currSem->waitList = temp;
			currSem->waitList->next = NULL;
			currSem->waitList->prev = NULL;
		}
		else{
			for (i = 0; i < MAXTASKS; i ++) {
				if (temp->priority < comparisonPoint->priority) {
					break;											
				}
				else{ 											
					comparisonPoint = comparisonPoint->next;
				}
			}
			if (comparisonPoint->prev == NULL) { 
			    currSem->waitList = temp;					
			}
			else {											
			    comparisonPoint->prev->next = temp;			
			}
			temp->prev = comparisonPoint->prev;			//set the new point's previous task	
			temp->next = comparisonPoint;      			//Set the new point's next task
			comparisonPoint->prev = temp;				//Link the comparisson task with new point
		}
		YKScheduler(0); // 0 = save context; 1 = don't save
	}
	else{
		int value = currSem->value;
		value = value - 1;
		currSem->value = value;
	}
	YKExitMutex();
}


/********************************************************************************
**							   Post to Semaphore							   **
********************************************************************************/
void YKSemPost(YKSEM* currSem) {
	TCBptr temp, comparisonPoint;
	YKEnterMutex();
	(currSem->value)++;

	if (currSem->waitList != NULL) {
		temp = currSem->waitList;
		currSem->waitList = temp->next;
		if (currSem->waitList != NULL) {			//Make sure next task in the ready list exists
			currSem->waitList->prev = NULL;			//Link the tasks by making this task the head
		}
		temp->state = READY;		//Set the state to delayed
		comparisonPoint = YKRdyList;
		if (comparisonPoint == NULL)
		{
			YKRdyList = temp;
			YKRdyList->next = NULL;
			YKRdyList->prev = NULL;
		}
		else{
			for (i = 0; i < MAXTASKS; i ++) {
				if (temp->priority < comparisonPoint->priority){	//Find when new point has a lower priority number (more urgent)
					break;											//We have found where new point belongs
				}
				else{ 											
					comparisonPoint = comparisonPoint->next;	//Go to the next point in the ready list, and compare with it.
				}
			}
			if (comparisonPoint->prev == NULL){ 			
			    YKRdyList = temp;							//Goes in the front of the list. Most ready task
			}
			else {											
			    comparisonPoint->prev->next = temp;			
			}
			temp->prev = comparisonPoint->prev;			//set the new point's previous task	
			temp->next = comparisonPoint;      			//Set the new point's next task
			comparisonPoint->prev = temp;				//Link the comparisson task with new point
		}
	}
	if (ISRDepth == 0) { YKScheduler(0); }
	YKExitMutex();
}

/*
*********************************************************************************
**																			   **
**							      QUEUE ROUTINES							   **
**																			   **
*********************************************************************************
*/

/********************************************************************************
**							  	 YK Queue Create							   **
********************************************************************************/
YKQ *YKQCreate(void **start, unsigned size) {
	if (size > 0 ) {
		YKQptr currQueue = &YKQArray[queueIndex];
		queueIndex++;
		currQueue->head = 0;
		currQueue->tail = 0;
		currQueue->items = 0;
		currQueue->base = start;
		currQueue->size = size;
		currQueue->waitList = NULL;
		return currQueue;
	}
}


/********************************************************************************
**							   	  YK Queue Pend 							   **
********************************************************************************/
void *YKQPend(YKQ *queue) {
	TCBptr temp, comparisonPoint;
	void* message;
	YKEnterMutex();	
	if ((queue->items == 0) && (hasRun == 1)) { 		// queue is empty -> suspend calling task		
		temp = YKRdyList;
		YKRdyList = temp->next;
		if (YKRdyList != NULL)					
			YKRdyList->prev = NULL;		
		temp->state = DELAYED;			
		comparisonPoint = queue->waitList;
		if (comparisonPoint == NULL) 
		{
			queue->waitList = temp;
			queue->waitList->next = NULL;
			queue->waitList->prev = NULL;
		}
		else
		{
			for (i = 0; i < MAXTASKS; i ++) {
				if (temp->priority < comparisonPoint->priority)
					break;										
				else
					comparisonPoint = comparisonPoint->next;	
			}
			if (comparisonPoint->prev == NULL)
				queue->waitList = temp;					
			else 
				comparisonPoint->prev->next = temp;												
			temp->prev = comparisonPoint->prev;			
			temp->next = comparisonPoint;      			
			comparisonPoint->prev = temp;				
		}
		YKScheduler(0); // 0 = save context; 1 = don't save
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
	else {												// queue is not empty -> remove oldest message
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


/********************************************************************************
**							      YK Queue Post								   **
********************************************************************************/
int YKQPost(YKQ *queue, void *msg) {

	TCBptr temp, comparisonPoint, delay;
	int maxPriority = 1000;
	YKEnterMutex();
	if (queue->items == queue->size) 			// queue is full
		return 0;
	if (queue->waitList != NULL) {				// tasks are waiting for queue
		delay = queue->waitList;
		while (delay != NULL)
		{
			if (delay->priority < maxPriority)
			{
				maxPriority = delay->priority;
			}
			delay = delay->next;
		}
		delay = queue->waitList;
		while (delay != NULL)
		{
			if (delay->priority == maxPriority)
			{
				temp = delay;						//Highest priority delay task
				break;
			}
			delay = delay->next;
		}
		if (temp->prev == NULL)						//if delay task at head
		{
			queue->waitList = temp->next;
			if (queue->waitList != NULL)					//Temp was only thing
			{
				queue->waitList->prev = NULL;
			}
		}
		else
		{
			if (temp->next == NULL)					//if delay task at tail
			{
				temp->prev->next = NULL;
			}
			else									//If delay task is in the middle
			{
				temp->prev->next = temp->next;
				temp->next->prev = temp->prev;
			}		
		}
		//Temp is isolated, and wait list is linked
		temp->state = READY;		
		comparisonPoint = YKRdyList;
		if (comparisonPoint == NULL) {
			YKRdyList = temp;
			YKRdyList->next = NULL;
			YKRdyList->prev = NULL;
		}
		else{
			for (i = 0; i < MAXTASKS; i ++) {
				if (temp->priority < comparisonPoint->priority){	
					break;										
				}
				else{ 										
					comparisonPoint = comparisonPoint->next;	
				}
			}
			if (comparisonPoint->prev == NULL){ 			
			    YKRdyList = temp;							
			}
			else {											
			    comparisonPoint->prev->next = temp;			
			}
			//Link the new point in front of the comparison point that it ended on
			temp->prev = comparisonPoint->prev;			//set the new point's previous task	
			temp->next = comparisonPoint;      			//Set the new point's next task
			comparisonPoint->prev = temp;				//Link the comparisson task with new point
		}
	}
	if (queue->head == ((queue->size)-1))
	{
		queue->head = 0;
	}
	else if (queue->items == NULL) {}	//nothing in queue
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

/*
*********************************************************************************
**																			   **
**							      EVENT ROUTINES							   **
**																			   **
*********************************************************************************
*/

/********************************************************************************
**							   YK Event Create								   **
********************************************************************************/
/* This function creates and initializes an event flags group and returns a pointer to the kernel's data structure used to maintain that flags group. 
YKEVENT is a typedef defined in a kernel header file that must be included in any user file that uses event flags. 
The structure it defines will be used to keep track of the event flags. 
The function must be called exactly once for each event group, and that call is typically done in main in the user code. 
The parameter initialValue gives the initial value that the flags group is to have. 
A one bit means that the event is set and a zero bit means that it is not set. 
Each event flags group is represented by a 16-bit value, allowing for 16 events in a single flags group. */
YKEVENT *YKEventCreate(unsigned initialValue) {
		Eventptr currEvent;
		YKEnterMutex();
		currEvent = &YKEventArray[currentEvent];
		currEvent->eventGroup = initialValue;
		currEvent->waitList = NULL;
		currentEvent++;
		YKExitMutex();
		return currEvent;	
} 

/********************************************************************************
**							     YK Event Pend								   **
********************************************************************************/
/* This function tests the value of the given event flags group against the mask and mode given in the eventMask and waitMode parameters. 
If the conditions for the event flags are met then the function should return immediately. 
Otherwise the calling task is suspended by the kernel until the the conditions are met and the scheduler is called. 
The two wait modes supported are EVENT_WAIT_ALL, where the task should block until all the bits set in eventMask are also set in the event flags group, 
	and EVENT_WAIT_ANY, where the task should block until any of the bits set in eventMask are also set in the event flags group. 
EVENT_WAIT_ANY and EVENT_WAIT_ALL should each be defined in your kernel header file using #define. 
(Their actual values are not important as long as they are distinct.) 
The value returned by the function is always the value of the event flags group at the time the function returns -- when the calling task resumes execution. 
(Note that other function calls to set or reset event flags may have executed between this point in time and when the task was unblocked.) 
This function is called only by tasks and never by ISRs or interrupt handlers. */
unsigned YKEventPend(YKEVENT *event, unsigned eventMask, int waitMode) {		//0 = wait for any / 1 = wait for all
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
	if (YKRdyList != NULL)	
	{				
		YKRdyList->prev = NULL;	
	}
	temp->state = DELAYED;
	//Set the condition, and event mask
	temp->eventMask = eventMask;
	temp->eventMode = waitMode;

	//add the current task to the wait list
	temp->next = event->waitList;		
	event->waitList = temp;				
	temp->prev = NULL;					//Since at head, Prev task must be NULL
	if (temp->next != NULL) {			//There is a next task, so we need to link back on that task
		temp->next->prev = temp;		//Link back to the current task so linked list is complete.
	}
	YKScheduler(0);					//call the scheduler
	YKExitMutex();
	return event->eventGroup;		//return the event value when it comes back

}

/********************************************************************************
**							      YK Event Set								   **
********************************************************************************/
/* This function causes all the bits that are set in the parameter eventMask to be set in the given event flags group. 
Any tasks waiting on this event flags group need to have their wait conditions checked against the new values of the flags. 
Any task whose conditions are met should be made ready. 
This function can be called from both task code and interrupt handlers. 
If one or more tasks was made ready and the function is called from task code then the scheduler should be called at the end of the function. 
If called from an interrupt handler then the scheduler should not be called. */
void YKEventSet(YKEVENT *event, unsigned eventMask) {
	TCBptr temp, taskHold, comparisonPoint;	
	unsigned newEventGroup;
	int taskReady = 0;
	YKEnterMutex();
	//set the new event value from the mask
	newEventGroup = (event->eventGroup | eventMask);
	event->eventGroup = newEventGroup;
	temp = event->waitList;

	while (temp != NULL) {						//Traverse list
		//Condition is met
		if (((temp->eventMode == 0) && (((event->eventGroup) & (temp->eventMask)) != 0)) || ((temp->eventMode == 1) && (((temp->eventMask) & (event->eventGroup)) == temp->eventMask))) {
			temp->state = READY;				//change the state of the task to ready
			taskHold = temp->next;				//Hold the position of task by setting it to temp
			if (temp->prev != NULL) {			//Temp is not at the head of the delay list 
				temp->prev->next = temp->next;	//link the previous task to the next one, skipping the current task
			}
			else {	
				event->waitList = temp->next;		//Since we are taking the head, set the head to the next in the list.	
			}
			if (temp->next != NULL)	{			//If there is a previous task
				temp->next->prev = temp->prev;	//link the next task to the previous one, skipping the current task
			}
		    comparisonPoint = YKRdyList;		//Set comparison pointer to the head of the ready list
			//Check if tasks in  ready list are higher priority than new task.
			
			/*This loop iterates though all of the ready tasks in the task list.
			 *As soon as the new point has a lower priority(more urgent) than the point in the ready list
			 *We can break out, and know that new point will go before it in the ready list.

			 *The idle task will always be less urgent than the new task
			 */
			while (comparisonPoint->priority < temp->priority)
			{
				comparisonPoint = comparisonPoint->next;
			}
		    if (comparisonPoint->prev == NULL){ 			// if the comparison pointer doesn't have a task in front of it after comparison
															//then new point didn't do an iteration through the while loop
															//It never iterated to other points in the while loop
															//This means that new point is the most urgent task
		        YKRdyList = temp;							//Goes in the front of the list. Most ready task
			}
		    else {											//New point is not the most urgent task, the while loop executed
															//so the most urgent ready item is still the most urgent
		        comparisonPoint->prev->next = temp;			//Set new point in front of the comparison point that ended the loop
															//This is the priority position that new point belongs in
			}
			//Link the new point in front of the comparison point that it ended on
		    temp->prev = comparisonPoint->prev;			//set the new point's previous task	
		    temp->next = comparisonPoint;      			//Set the new point's next task
		    comparisonPoint->prev = temp;				//Link the comparisson task with new point
			temp = taskHold;
			taskReady = 1;
		}
		else{
			temp = temp->next;							//Go to next in delay list, to check in this while loop
		}
	}
	if ((taskReady == 1) && (ISRDepth == 0))
	{
		YKScheduler(0);
	}
	YKExitMutex();
	
}

/********************************************************************************
**							     YK Event Reset								   **
********************************************************************************/
/* This function simply causes all the bits that are set in the parameter eventMask to be reset (made 0) in the given event flags group. 
Since our kernel does not allow tasks to block until events are reset, there is no reason to unblock any tasks or call the scheduler in this function. 
This function can be called from task code and interrupt handlers. */
void YKEventReset(YKEVENT *event, unsigned eventMask) {
	unsigned newEventGroup;
	YKEnterMutex();
	//set the new event value from the mask
	newEventGroup = ((event->eventGroup) & ~(eventMask));
	event->eventGroup = newEventGroup;
	YKExitMutex();	
}

/*
*******************************************************************************
**						         	Debug Function							 **
******************************************************************************/
void printLists(void){
	struct taskblock* tempPoint;					//Create a temp pointer
	printNewLine();									//Print a new line
	printString("Tasks in the Ready List:");		//Print heading for list
	printNewLine();									//Print a new line
	tempPoint = YKRdyList;							//Set the temp pointer to the head of the ready list (1st item)
	while(tempPoint != NULL){						//Iterate through all ready tasks
		printString("Priority: 0x");				//Format for hex number
		printByte(tempPoint->priority);				//Print out the priority of the current task
		printString(" / Stack Pointer: 0x");		//Seperate TCB variables
		printWord((int)tempPoint->stackptr);		//Print the stack pointer of the current task
		printString(" / Delay Count: 0x");			//Seperate TCB variables
		printByte(tempPoint->delay);				//Print out the delay count of the current task		
		printNewLine();								//Print a new line
		tempPoint = tempPoint->next;				//Go to the next task in the ready list
	}
	printNewLine();									//Print a new line
	printString("Tasks in the Delay List:");		//Print heading for list
	printNewLine();									//Print a new li
	tempPoint = YKSuspList;							//Set the temp pointer to the head of the delay list (1st item)
	while(tempPoint != NULL){						//Iterate through all ready tasks
		printNewLine();
		printString("Priority: 0x");				//Format for hex number
		printByte(tempPoint->priority);				//Print out the priority of the current task
		printString(" / Stack Pointer: 0x");		//Seperate TCB variables
		printWord((int)tempPoint->stackptr);		//Print the stack pointer of the current task
		printString(" / Delay Count: 0x");			//Seperate TCB variables
		printByte(tempPoint->delay);				//Print out the delay count of the current task		
		printNewLine();								//Print a new line
		tempPoint = tempPoint->next;				//Go to the next task in the delay list
	}
	printNewLine();									//Print a new line
	printString("Tasks in the Delay List:");		//Print heading for list
	printNewLine();									//Print a new li	
	temp = &(YKSemaphoreArray[0]); 				    // Initialize locations for TCB
	printNewLine();
	printString("value: 0x");						//Format for hex number
	printInt(temp->value);							//Print out the priority of the current task
	printNewLine();
	tempPoint = temp->waitList;
	while(tempPoint != NULL){						//Iterate through all ready tasks
		printNewLine();
		printString("Priority: 0x");				//Format for hex number
		printByte(tempPoint->priority);				//Print out the priority of the current task
		printString(" / Stack Pointer: 0x");		//Seperate TCB variables
		printWord((int)tempPoint->stackptr);		//Print the stack pointer of the current task
		printString(" / Delay Count: 0x");			//Seperate TCB variables
		printByte(tempPoint->delay);				//Print out the delay count of the current task		
		printNewLine();								//Print a new line
		tempPoint = tempPoint->next;				//Go to the next task in the delay list
	}
}
