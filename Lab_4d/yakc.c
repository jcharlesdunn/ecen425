#include "clib.h"
#include "yakk.h"
#include "yaku.h"

#define DELAYED 0
#define READY 1


unsigned int YKCtxSwCount = 0; 	// increments on every context switch

unsigned int YKIdleCount; 	// increments in YKIdle Task

unsigned int YKTickNum; 	// increment in YKTickHandler

unsigned int ISRDepth; // increments when entering ISR, decrements when leaving IST


int i = 0; // used in for loops



typedef struct taskblock *TCBptr;
typedef struct taskblock
{						
    void *stackptr;		// pointer to tasks stack
    int state;			// state
    int priority;		// priority
    int delay;			// delay count
	// doubly linked list, pointers to task before and after it    
	TCBptr next;		// 
    TCBptr prev;		
}  TCB;

TCBptr YKRdyList; 			// pointer to ready list
TCBptr YKAvailTCBList; 		// pointer to available task list
TCBptr YKSuspList;			// pointer to suspened list
TCBptr YKRunningTask; 		// pointer to currently running task
TCB YKTCBArray[MAXTASKS+1]; 

int hasRun = 0; 			// flag used to determine if scheduler needs to be called after YKRun has been called
int idleStk[IDLE_STACK_SIZE]; 	

void YKInitialize(void) 		
{
	YKEnterMutex();		
	// Init all counts and depths to zero		
	YKCtxSwCount = 0; 		
	YKIdleCount = 0; 			
	YKTickNum = 0; 				
	ISRDepth = 0;				
	YKRdyList = NULL;			
	YKSuspList = NULL;			
	YKRunningTask = NULL;		
	hasRun = 0;					

    YKAvailTCBList = &(YKTCBArray[0]); 				
	// init available list
    for (i = 0; i < MAXTASKS; i++){					
        YKTCBArray[i].next = &(YKTCBArray[i+1]);	

    }
    YKTCBArray[MAXTASKS].next = NULL;				
    YKTCBArray[MAXTASKS].prev = NULL;				

    YKNewTask(YKIdleTask,(void *) &(idleStk[IDLE_STACK_SIZE]),100); 
}


void YKIdleTask(){
    while(1){				
		// ATOMIC SECTION
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
										
    
    YKEnterMutex();		// ATOMIC SECTION				

    newPoint = YKAvailTCBList;  		
    if(newPoint == NULL){				
        return;							
    } 
    
    YKAvailTCBList =  newPoint->next;						
									
    newPoint->priority = priority;		
    newPoint->delay = 0; 				
	newPoint->state = READY;			
	
    if (YKRdyList == NULL) 		// ready list is empty
	{		
        YKRdyList = newPoint;			
        newPoint->next = NULL;			
        newPoint->prev = NULL;			
    }
    else           				// ready list size > 1	
    {
		// insert task sorted by priority        
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
	// initialize sp and ip
	stackPoint = (unsigned *)taskStack;					
	for (i = 0; i < 13; i++)					
	{
		if (i == 1){							
			stackPoint[0] = 0x0200; 			
		}
		else if (i == 3){						//wait until i 3
			stackPoint[0] = (unsigned)task;		//Set the current stack pointer to the task
		}
		else{									
			stackPoint[0] = 0;					
		}
		stackPoint--;						
	}   
 
    newPoint->stackptr = (void *)stackPoint;	

    if(hasRun == 1) {	
        YKScheduler(1);		
        YKExitMutex();		//Enable interrupts
    }  
}

void YKDelayTask(unsigned count)		
{
	TCBptr delayPoint;					
	if (count == 0){					//If the count is 0
		return; 						
	}
	YKEnterMutex();						//Disable interrupts
	delayPoint = YKRdyList;				// grab task to bYKTickHandlere delayed from head of ready list
	YKRdyList = delayPoint->next; 		// move ready list head to next task
	if (YKRdyList != NULL)				//*** i dont think this will ever happen, we will always have an idle task
	{
		YKRdyList->prev = NULL;			
	}
	
	// change state of task to delay count and state
	delayPoint->state = DELAYED;		
	delayPoint->delay = count;			
	
	delayPoint->next = YKSuspList;		// move deak
	YKSuspList = delayPoint;			
	delayPoint->prev = NULL;			
	if (delayPoint->next != NULL)		
	{
		delayPoint->next->prev = delayPoint;	
	}
	YKScheduler(0); 					// run highest priority ready task, without restoring context
	YKExitMutex();						//Enable interrupts
}

void YKTickHandler(void)				
{
	TCBptr temp, taskHold, comparisonPoint;						
	YKTickNum++;						

	printNewLine();
	printString("TICK ");
	printInt(YKTickNum);
	printNewLine();

	temp = YKSuspList; 					
	while (temp != NULL) 			
	{
		temp->delay--; 					
		if (temp->delay == 0) // if delay is over, send delayed task back to ready list 			
		{												
			taskHold = temp->next;	// next head of susp list		
			
			// remove task from susp list	
			temp->state = READY;		
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

			// insert task back into ready list, sorted by priority
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
			temp->prev = comparisonPoint->prev;				
		    temp->next = comparisonPoint;      			
		    comparisonPoint->prev = temp;				
			temp = taskHold;
		}
		else{
			temp = temp->next;		// move to next in susp list
		}
	}
}


void YKRun(void){
	hasRun = 1; 	// flag. YKRun called
	YKScheduler(0);		// run highest priority ready task
						// do not restore context
}

void YKEnterISR(void)			
{
	ISRDepth++;		// increment ISR depth			
}

void YKExitISR(void)			
{
	ISRDepth--;		// decrement ISR depth			
	if (ISRDepth == 0)	// if not in nested interupts
	{
		if (hasRun)			
		{
			YKScheduler(1);		// run highest priority ready task
								// restore context
		}
	}
}






































 
