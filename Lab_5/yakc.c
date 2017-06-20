#include "clib.h"
#include "yakk.h"
#include "yaku.h"

#define DELAYED 0
#define READY 1


unsigned int YKCtxSwCount = 0; 	

unsigned int YKIdleCount; 	

unsigned int YKTickNum; 	

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

    YKAvailTCBList = &(YKTCBArray[0]); 				

    for (i = 0; i < MAXTASKS; i++){					
        YKTCBArray[i].next = &(YKTCBArray[i+1]);	
    }
    YKTCBArray[MAXTASKS].next = NULL;				
    YKTCBArray[MAXTASKS].prev = NULL;				

    YKNewTask(YKIdleTask,(void *) &(idleStk[IDLE_STACK_SIZE]),100); 
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
        YKExitMutex();		
    }  
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
	YKTickNum++;						
	printNewLine;
	printString("TICK ");
	printInt(YKTickNum);
	printString("\n\r");
	
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
/*	printString("SEMPEND ENTER -> ");
	printInt((int)semaphore);
	printNewLine();
	printString("SEM VALUE -> ");
	printInt(semaphore->value);
	printNewLine();*/
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
	//printString("SEMPEND EXIT->going to sched\n");
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







































 
