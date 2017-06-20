#include "clib.h"
#include "yakk.h"
#include "yaku.h"

#define DELAYED 0
#define READY 1


unsigned int YKCtxSwCount = 0; 	

unsigned int YKIdleCount; 	

int YKTickNum; 	

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
TCB YKTCBArray[MAXTASKS+1]; 

YKQ YKQArray[10];
int idxNextAvailQ;


YKEVENT YKEventArray[10];
int idxNextAvailEvent;
//TCBptr YKQMsgWaitList;

int hasRun = 0; 				
int idleStk[IDLE_STACK_SIZE]; 	

void YKInitialize(void) 		
{	
	YKEnterMutex();				
	YKIMRInit(0x00);
	YKCtxSwCount = 0; 			

	YKIdleCount = 0; 			
	YKTickNum = 0; 				
	ISRDepth = 0;				
	YKSave = NULL;
	YKRestore = NULL;

	YKRdyList = NULL;			
	YKSuspList = NULL;			
	YKRunningTask = NULL;		
	hasRun = 0;					
	YKAvaiSems = 4;
	
	//YKQMsgWaitList = NULL;
	idxNextAvailQ = 0;

	idxNextAvailEvent = 0;

    YKAvailTCBList = &(YKTCBArray[0]); 				

    for (i = 0; i < MAXTASKS; i++){					
        YKTCBArray[i].next = &(YKTCBArray[i+1]);	
    }
    YKTCBArray[MAXTASKS].next = NULL;				
    YKTCBArray[MAXTASKS].prev = NULL;				

    YKNewTask(YKIdleTask,(void *) &(idleStk[IDLE_STACK_SIZE]),100); 
	YKEnterMutex();
}


void YKIdleTask(){
    while(1){		
		// ATOMIC
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
    // ATOMIC
    YKEnterMutex();						
	
    newPoint = YKAvailTCBList;  		
    if(newPoint == NULL){				
        return;							
    } 
    
    YKAvailTCBList =  newPoint->next;	
										
									
    newPoint->priority = priority;		
    newPoint->delay = 0; 				
	newPoint->state = READY;			
	
    if (YKRdyList == NULL) 				  
    {									
        YKRdyList = newPoint;			
        newPoint->next = NULL;			
        newPoint->prev = NULL;			
    }
    else           						
    {
        comparisonPoint = YKRdyList;   					
		for (i = 0; i < MAXTASKS; i ++)
		{
			if (newPoint->priority < comparisonPoint->priority){	
				break;												
			}
			else{ 											
				comparisonPoint = comparisonPoint->next;	
			}
		}
        if (comparisonPoint->prev == NULL){ 			
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
    } 
	YKExitMutex(); 
	
}

void YKDelayTask(unsigned count)		
{
	TCBptr delayPoint;					
	YKEnterMutex();						
	if (count == 0){					
		YKExitMutex();			
		return; 						
	}
	//ATOMIC
	delayPoint = YKRdyList;				
	YKRdyList = delayPoint->next; 		
	if (YKRdyList != NULL)				
	{
		YKRdyList->prev = NULL;			
	}
	delayPoint->state = DELAYED;		
	delayPoint->delay = count;			
	delayPoint->next = YKSuspList;		
	YKSuspList = delayPoint;			
	delayPoint->prev = NULL;			
	if (delayPoint->next != NULL)		
	{
		delayPoint->next->prev = delayPoint;	
	}
	YKScheduler(0); 					//Callsceduler no context restore
	YKExitMutex();						
}

void YKTickHandler(void)				
{
	TCBptr temp, taskHold, comparisonPoint;		
	/*
	The user code tick handler should no longer output "TICK n" as in previous labs. Instead, it should be 
	rewritten so that it posts a message to a message queue each time it runs.	
	YKTickNum++;	//**************					
	printNewLine;
	printString("TICK ");
	printInt(YKTickNum);
	printString("\n\r");
	*/

	YKTickNum++;	//************** used in tick handler YKQPost call
	temp = YKSuspList; 					
	while (temp != NULL) 			
	{
		temp->delay--; 					
		if (temp->delay == 0) 			
		{								
			temp->state = READY;		
			taskHold = temp->next;			
			if (temp->prev != NULL) 	 
			{
				temp->prev->next = temp->next;
			}
			else{								
				YKSuspList = temp->next;			
			}
			if (temp->next != NULL)		
			{
				temp->next->prev = temp->prev;	
			}
		    comparisonPoint = YKRdyList;   					
	
			for (i = 0; i < MAXTASKS; i ++)
			{
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
		    else{											
		        comparisonPoint->prev->next = temp;		
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
	hasRun = 1; 		
	YKScheduler(0);		//Callsceduler no context save
}

void YKEnterISR(void)			
{
	ISRDepth++;					
}

void YKExitISR(void)			
{
	ISRDepth--;			
	if (ISRDepth == 0)			//not in nested interrupts
	{
		if (hasRun)				//if the RTOS is running
		{
			YKScheduler(1);		//Callsceduler no context save
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
        YKSems[YKAvaiSems].blockedOn = NULL;
    }
    YKExitMutex();

    // Return the address of the newely created semaphore
    return (&(YKSems[YKAvaiSems]));

}

void YKSemPend(YKSEM *semaphore){
    TCBptr temp, temp2, iter;
    int index;
    // ATOMIC
	YKEnterMutex();

    if (semaphore->value > 0){
		/*printString("hi");*/
		semaphore->value--;
        YKExitMutex();
        return;
    }
	semaphore->value--;
    // remove task from ready list
    temp = YKRdyList; 

    YKRdyList = temp->next; 
    if (YKRdyList != NULL)
       YKRdyList->prev = NULL;
    // Put task in suspended list
    temp->state = 2;
    // Put task at semaphore's blocked list
    if (semaphore->blockedOn == NULL){
        semaphore->blockedOn = temp;
        temp->next = NULL;
        temp->prev = NULL;
    }
    else{
        iter = semaphore->blockedOn;
        temp2 = NULL;
        while (iter != NULL && iter->priority < temp->priority){
            temp2 = iter;
            iter = iter->next;
        }
        if (iter == NULL){ // at end of semaphore pend list
            temp2->next = temp;
            temp->prev = temp;
            temp->next = NULL;
        }
        else{ // insert before iterator
            temp->next = iter;
            temp->prev = temp2;
            iter->prev = temp;
            if (temp2 == NULL)//inserted at beginning of list
                semaphore->blockedOn = temp;
            else
                temp2->next = temp;
        }
    }
    // call scheduler
    YKScheduler(0);
    // enable interrupts
    YKExitMutex();
}

void YKSemPost(YKSEM *semaphore){
    TCBptr temp, temp2;
    // atomic
	/*printString("SEMPOST ENTER -> ");
	printInt((int)semaphore);
	printNewLine();*/
    YKEnterMutex();
    if (semaphore->value++ >= 0){
        YKExitMutex();
        return;
    }
    // remove from pending list
    temp = semaphore->blockedOn;
    semaphore->blockedOn = temp->next;
    if (semaphore->blockedOn != NULL)
        semaphore->blockedOn->prev = NULL;
    // modify TCB of that task, place in ready list
    temp->state = READY;
    // Put in Rdy List
    temp2 = YKRdyList;
    while (temp2->priority < temp->priority){
        temp2 = temp2->next;
    }
    if (temp2->prev == NULL){
        YKRdyList = temp;
    }
    else{
        temp2->prev->next = temp;
    }
    temp->prev = temp2->prev;
    temp->next = temp2;
    temp2->prev = temp;
    // call scheduler if not called from ISR
    if (ISRDepth == 0) 
	{
		//printString("SEMPOST EXIT->going to sched\n");
        YKScheduler(0);
	}
    YKExitMutex();
}


YKQ* YKQCreate(void ** start, unsigned int size){
	YKQ *currQ = &YKQArray[idxNextAvailQ++];
	currQ->length = size;
	currQ->head = 0;
	currQ->tail = 0;
	currQ->msgQ = start; // this is the pointer to the msg queue
	currQ->full = 0;
	currQ->empty = 1;
	currQ->waitList = NULL;
	return currQ;
}

void* YKQPend(YKQ* queue){
	void* retPtr = NULL;
	TCBptr temp;
	TCBptr temp2;
	TCBptr iter;
	YKEnterMutex();

	if(queue->empty)
	{
		//remove from ready list
		temp = YKRdyList; 

		YKRdyList = temp->next; 
		if (YKRdyList != NULL)
		   YKRdyList->prev = NULL;
		// Put task in suspended list
		temp->state = 43;
		// Put task at semaphore's blocked list
		if (queue->waitList == NULL){
		    queue->waitList = temp;
		    temp->next = NULL;
		    temp->prev = NULL;
		}
		else{
		    iter = queue->waitList;
		    temp2 = NULL;
		    while (iter != NULL && iter->priority < temp->priority){
		        temp2 = iter;
		        iter = iter->next;
		    }
		    if (iter == NULL){ // at end of semaphore pend list
		        temp2->next = temp;
		        temp->prev = temp;
		        temp->next = NULL;
		    }
		    else{ // insert before iterator
		        temp->next = iter;
		        temp->prev = temp2;
		        iter->prev = temp;
		        if (temp2 == NULL)//inserted at beginning of list
		            queue->waitList = temp;
		        else
		            temp2->next = temp;
		    }
		}
		// call scheduler
		YKScheduler(0);


		retPtr = queue->msgQ[queue->head];	// Grab the first message in the queue
		queue->full = 0;
		//remove the message from the queue
		//update head location
		if(queue->head == (queue->length - 1)){
			queue->head = 0;
		}
		else{
			queue->head++;
		}
		
		if(queue->head == queue->tail)
		{	
			queue->empty = 1;
		}
		YKExitMutex();
	}
	else 
	{
		retPtr = queue->msgQ[queue->head];	// Grab the first message in the queue
		queue->full = 0;
		//remove the message from the queue
		//update head location
		if(queue->head == (queue->length - 1)){
			queue->head = 0;
		}
		else{
			queue->head++;
		}
		
		if(queue->head == queue->tail)
		{	
			queue->empty = 1;
		}
		
	}

	YKExitMutex();

	return retPtr;
}


int YKQPost(YKQ* queue, void* msg){
	TCBptr waitTask;
	TCBptr tempPtr;
	TCBptr tempPtr2;
	YKEnterMutex();
	//check to see if queue is full
	if(queue->full){
		YKExitMutex();
		return 0;
	}

	//queue is not full
	queue->msgQ[queue->tail] = msg; // this is assuming, tail is empty

	//update tail location
	if(queue->tail == (queue->length - 1)){
		queue->tail = 0;
	}
	else{
		queue->tail++;
	}


	//update empty and full booleans
	queue->empty = 0;	

	if(queue->tail == queue->head){
		queue->full = 1;
	}


	//unblocking code
	if(queue->waitList != NULL){
		//remove highest priority waiting task from waitlist
		waitTask = queue->waitList;
		if(waitTask->next !=NULL)
		{
			tempPtr = waitTask->next;
			tempPtr->prev = NULL;
			queue->waitList = tempPtr;
		}
		else
			queue->waitList = NULL;

		// modify TCB of that task, place in ready list
		waitTask->state = READY;
		// Put in Rdy List
		tempPtr2 = YKRdyList;
		while (tempPtr2->priority < waitTask->priority){
		    tempPtr2 = tempPtr2->next;
		}
		if (tempPtr2->prev == NULL){
		    YKRdyList = waitTask;
		}
		else{
		    tempPtr2->prev->next = waitTask;
		}
		waitTask->prev = tempPtr2->prev;
		waitTask->next = tempPtr2;
		tempPtr2->prev = waitTask;
	}

	if (ISRDepth == 0)
		YKScheduler(0); 		//Callsceduler no context restore ****


	YKExitMutex();

	return 1; // success

}

YKEVENT *YKEventCreate(unsigned initialValue)
{
	YKEVENT* currEvent = &YKEventArray[idxNextAvailEvent++];
	currEvent->value = initialValue;
	currEvent->waitList = NULL;

	return currEvent;
}

unsigned YKEventPend(YKEVENT *event, unsigned eventMask, int waitMode)
{
    TCBptr temp, temp2, iter;
    int index;
    // ATOMIC
	YKEnterMutex();
	
	if(waitMode == EVENT_WAIT_ANY) // any task
	{
		if(event->value & eventMask)
			return event->value;
	}
	else // all tasks
	{
		if(event->value == eventMask)
			return event->value;
	}
    temp = YKRdyList; 

    YKRdyList = temp->next; 
    if (YKRdyList != NULL)
       YKRdyList->prev = NULL;
    // Put task in suspended list
    temp->waitMode = waitMode;
	temp->waitValue = eventMask;
	
    // Put task at event's blocked list
    if (event->waitList == NULL){
        event->waitList = temp;
        temp->next = NULL;
        temp->prev = NULL;
    }
    else{
        iter = event->waitList;
        temp2 = NULL;
        while (iter != NULL && iter->priority < temp->priority){
            temp2 = iter;
            iter = iter->next;
        }
        if (iter == NULL){ // at end of event pend list
            temp2->next = temp;
            temp->prev = temp;
            temp->next = NULL;
        }
        else{ // insert before iterator
            temp->next = iter;
            temp->prev = temp2;
            iter->prev = temp;
            if (temp2 == NULL)//inserted at beginning of list
                event->waitList = temp;
            else
                temp2->next = temp;
        }
    }
	
    // call scheduler
    YKScheduler(0);
    // enable interrupts
    YKExitMutex();


	// we will update event->value
	return event->value;
}

// Unblocks task
void YKEventSet(YKEVENT *event, unsigned eventMask)
{
	TCBptr temp, temp2, temp3, temp4;
	int removeBool;
	YKEnterMutex();
	event->value = event->value | eventMask;

	temp3 = event->waitList;
	while(temp3 != NULL)// for each task in wait list
	{
		temp4 = temp3->next;
		removeBool = 0;
		if(temp3->waitMode == EVENT_WAIT_ALL) // any task
		{
			if(event->value == temp3->waitValue)
				removeBool = 1;
		}
		else
		{
			if(event->value & temp3->waitValue)
				removeBool = 1;
		}
		if(removeBool)
		{
			// remove from pending list
			
			temp = event->waitList;
			event->waitList = temp->next;
			if (event->waitList != NULL)
				event->waitList->prev = NULL;
			// modify TCB of that task, place in ready list
			temp->state = READY;
			// Put in Rdy List
			temp2 = YKRdyList;
			while (temp2->priority < temp->priority){
				temp2 = temp2->next;
			}
			if (temp2->prev == NULL){
				YKRdyList = temp;
			}
			else{
				temp2->prev->next = temp;
			}
			temp->prev = temp2->prev;
			temp->next = temp2;
			temp2->prev = temp;
		}
	temp3 = temp4;
	}	

	
	if (ISRDepth == 0)
		YKScheduler(0); 		//Callsceduler no context restore ****
	YKExitMutex();
}

// Does not unblock task
void YKEventReset(YKEVENT *event, unsigned eventMask)
{
	//YKEnterMutex();
	event->value = (event->value) & (~eventMask);
	//YKExitMutex();
}






