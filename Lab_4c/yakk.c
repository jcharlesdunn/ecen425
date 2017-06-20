#include "clib.h"
#include "yakk.h"
#include "yaku.h"

//Variables included in yakc.c
unsigned int YKCtxSwCount = 0;  //Keeps context switches
                                //Increments each time a context switches at dispatcher

unsigned int YKIdleCount;   //Used by idle task. Increments every time it is called
unsigned int YKISRDepth;
unsigned int YKTickNum; 	//Global variable incremented by tick handler

int i = 0;                  //for loop iteration

int* YKSave;                //Pointer to the task to be saved
int* YKRestore;             //Pointer to the task to be restored

typedef struct taskblock *TCBptr;
typedef struct taskblock  //the TCB struct definition 
{                      
    void *stackptr;     // pointer to current top of stack 
    int state;          // current state 
    int priority;       // current priority 
    int delay;          // #ticks yet to wait 
    TCBptr next;        // forward ptr for dbl linked list 
    TCBptr prev;        // backward ptr for dbl linked list 
}  TCB;

TCBptr YKRdyList;           //Pointer to the ready task list
                            //First item is highest priority, ready to run task
TCBptr YKAvailTCBList;      //Pointer to the available task list
TCBptr YKSuspList;          //Pointer to list of suspended tasks(delay member != 0)
TCBptr YKRunningTask;       //Pointer to task that is currently running
TCB YKTCBArray[MAXTASKS+1]; //TCB array

int hasRun = 0;                 //Set the flag once, YKRun has executed 
int idleStk[IDLE_STACK_SIZE];   //Allocate stack space for Idle task

void save();

void YKInitialize(void)         //Initializes all required kernel data structures
{
    YKEnterMutex();             //Disable interrupts

    YKCtxSwCount = 0;           //Init variables
    YKIdleCount = 0;            //Init variables

    YKSave = NULL;              //Init task to save to null
    YKRestore = NULL;           //Iniit task to restore to null
    YKRdyList = NULL;           //Init ready list head to null 
    YKSuspList = NULL;          //Init delay list head to null
    YKRunningTask = NULL;       //Init pointer to the running task to null
    hasRun = 0;                 //Init hasRun flag to 0 for
    // Initialize TCB array
    YKAvailTCBList = &(YKTCBArray[0]);              //Set the available TCB list pointer to the memory
                                                    //address of the TCB array. This space was allocated
                                                    //for the TCB's
    //Create a linked list of TCB's
    for (i = 0; i < MAXTASKS; i++){                 //iterate through the TCB array
        YKTCBArray[i].next = &(YKTCBArray[i+1]);    //Set the pointer to the next TCB in the array
                                                    //to the address of the next TCB space.
                                                    //This will create a linked list.
        //YKTCBArray[MAXTASKS].prev = NULL; 
    }
    YKTCBArray[MAXTASKS].next = NULL;               //The last position in the array has a null pointer to next
    YKTCBArray[MAXTASKS].prev = NULL;               //The last position in the array has a null pointer to prev

    YKNewTask(YKIdleTask,(void *) &(idleStk[IDLE_STACK_SIZE]),100); //Create low priority Idle Task
}


//  Idle Task will be the lowest priority task
void YKIdleTask(){
	printString("IDLE TASK\n");
    while(1){               //Run forever to be interrupted       
		YKEnterMutex();     //Disable interrupts during atomic section
        YKIdleCount++;      //Increment the idle count
        YKExitMutex();      //Enable interrupts
    }
}

void YKScheduler(int isSaved){
    if (YKRunningTask != YKRdyList){    //If highest priority ready task is not already running
        YKCtxSwCount++;                 //Increment context switch count
        YKDispatcher(isSaved);                //Run the dispatcher
    }
}

void YKNewTask(void (* task)(void), void *taskStack, unsigned char priority)
{
    unsigned *stackPoint;               //pointer for task Stack
    TCBptr tempPtr0, tempPtr1;   //Create 2 task pointers. 
    
    YKEnterMutex();                     //Disable interrupts

    tempPtr0 = YKAvailTCBList;          //Store the pointer of the available TCB list. New pointer
    if(tempPtr0 == NULL){               //If there is no available TCB
        return;                         //No task created before YKRun was called, exit.
    } 
    
    YKAvailTCBList =  tempPtr0->next;   //move Available TCB list pointer to next position for next YKNewTask() 
                                                                           
    tempPtr0->priority = priority;      //Set the priority of the new task
    tempPtr0->delay = 0;                //Set the delay of the new task to 0 (no delay)
    
    if (YKRdyList == NULL)              //If there is nothing in the ready list. First time through  
    {                                   
        YKRdyList = tempPtr0;           //Add our new TCB to the head of the ready list.
        tempPtr0->next = NULL;          //Since only item in list, set next to null
        tempPtr0->prev = NULL;          //Since only item in list, set prev to null
    }
    else                                //not first task in YKReadyList
    {
        tempPtr1 = YKRdyList;                    //Set comparison pointer to the head of the ready list. 
														//Compare priorities
        for (i = 0; i < MAXTASKS; i ++)
        {
            if (tempPtr0->priority < tempPtr1->priority){    //Find higher priority task(lower number) 
                break;                                             
            }
            else{                                           //Comparison is higher priority than new
                                                            
                tempPtr1 = tempPtr1->next;    //Go to the next point in the ready list, and compare with it.
            }
        }
        if (tempPtr1->prev == NULL){             
            YKRdyList = tempPtr0;            
        }
        else{ 
            tempPtr1->prev->next = tempPtr0;     //Set new point in front of the comparison point that ended the loop
        }
        tempPtr0->prev = tempPtr1->prev;         //set the new point's previous task 
        tempPtr0->next = tempPtr1;               //Set the new point's next task
        tempPtr1->prev = tempPtr0;               //Link the comparisson task with new point
    }
    stackPoint = (unsigned *)taskStack;       

    // The stack pointer passed in points to the top of the stack.
    //The stack grows down, so we need to decrement the temporary stack pointer
    //So we can set all of the necessary information in the stack for the new task
    for (i = 0; i < 13; i++)                    //Decrement the temp stack pointer, and set stack information
    {
        if (i == 1){                 
            stackPoint[0] = 0x0200;             //set the current stack pointer for the interrupt flag
        }
        else if (i == 3){ 
            stackPoint[0] = (unsigned)task;     //Set the current stack pointer to the task
        }
        else{
            stackPoint[0] = 0;                  //Set the current stack position to 0. Initialize the value.
        }
        stackPoint--;                           //Decrement the stack pointer.
    }   
 
    tempPtr0->stackptr = (void *)stackPoint;    //Finally set the stack pointer of the task
    
    if(hasRun == 1) {       //if YKRun has been called, continue execution
        YKScheduler(1);    
        YKExitMutex();
    }  
}



//This function delays a task for the specified number of clock ticks. After taking care of all required bookkeeping to mark the change of state for the currently running task, this function calls the scheduler. After the specified number of ticks, the kernel will mark the task ready. If the function is called with a count argument of 0 then it should not delay and should simply return. This function is called only by tasks, and never by interrupt handlers or ISRs.
void YKDelayTask(unsigned count){ 

	TCBptr tempPtr0;
	TCBptr tempPtr1;
	TCBptr tempPtr2;
	// if count == 0, return
	if(count == 0){
		return;
	}
	YKEnterMutex();						//Disable interrupts
	// set pointer to running task
	tempPtr0 = YKRdyList;
	tempPtr0->delay = count;

	// set pointer to suspended list
	tempPtr1 = YKSuspList;
	// set pointer to second item in YKRdyList
	tempPtr2 = YKRdyList->next;

	//Add delayed task to YKSuspList
	if (YKSuspList == NULL)              //If there is nothing in the ready list. First time through  
    {                                   
        YKSuspList = tempPtr0;          //Add our new TCB to the head of the ready list.
        tempPtr0->next = NULL;          //Since only item in list, set next to null
        tempPtr0->prev = NULL;          //Since only item in list, set prev to null
    }
	else
	{
		while(tempPtr1->next != NULL) // get to end of susp list - used when we add a second or third task etc.
		{
			tempPtr1 = tempPtr1->next;
		}
		tempPtr1->next = tempPtr0;
		tempPtr1->next->prev = tempPtr1;
		tempPtr1->next->next = NULL;
	}	
	//Removes delayed task from ready list
	tempPtr2->prev = NULL;
	YKRdyList = tempPtr2;	 // set ready head next highest priority task

	// call scheduler
	YKScheduler(0); // save without restore
	YKExitMutex();						//Enable interrupts
	
}




//This function must be called from the tick ISR each time it runs. YKTickHandler is responsible for the bookkeeping required to support the timely reawakening of delayed tasks. (If the specified number of clock ticks has occurred, a delayed task is made ready.) The tick ISR may also call a user tick handler if the user code requires actions to be taken on each clock tick.
void YKTickHandler(void)				//Decrement the delay ticks
{
	TCBptr temp, taskHold, comparisonPoint;						//Create a pointer for logic
	YKTickNum++;						//Increment the tick number
	printNewLine;
	printString("\n");
	printString("TICK: ");
	printInt(YKTickNum);
	printString("\n\r");
	//Grab the head of the delay list to go through each task in it.
	temp = YKSuspList; 					//set pointer to the delay task head
	while (temp != NULL) 			//while the next item in the delay list is not null
	{
		temp->delay--; 					//Decrement the delay count in the task
		if (temp->delay == 0) 			//Check to see if the delay count in the task is now 0
		{								//take the task out of the delay task. It is no longer blocked
			taskHold = temp->next;			//Hold the position of task by setting it to temp
			if (temp->prev != NULL) 	//Temp is not at the head of the delay list 
			{
				temp->prev->next = temp->next;	//link the previous task to the next one, skipping the current task
			}
			else{								//Temp is at the head of the delay list
				YKSuspList = temp->next;		//Since we are taking the head, set the head to the next in the list.	
			}
			if (temp->next != NULL)		//If there is a previous task
			{
				temp->next->prev = temp->prev;	//link the next task to the previous one, skipping the current task
			}
		    comparisonPoint = YKRdyList;   					//Set comparison pointer to the head of the ready list. For comparrison.
															//We need to see if tasks in the ready list 
															//are higher priority than the new point.
			/*This loop iterates though all of the ready tasks in the task list.
			 *As soon as the new point has a lower priority(more urgent) than the point in the ready list
			 *We can break out, and know that new point will go before it in the ready list.
			 *The idle task will always be less urgent than the new task
			 */
			for (i = 0; i < MAXTASKS; i ++)
			{
				if (temp->priority < comparisonPoint->priority){	//Find when new point has a lower priority number (more urgent)
																		//Than the task we are comparing it to.
					break;												//Break out of the loop, we have found where new point belongs
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
		        YKRdyList = temp;						//Goes in the front of the list. Most ready task
			}
		    else{											//New point is not the most urgent task, the while loop executed
															//so the most urgent ready item is still the most urgent
		        comparisonPoint->prev->next = temp;		//Set new point in front of the comparison point that ended the loop
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

// Start kernel
void YKRun(void){
    hasRun = 1;        
    YKScheduler(0);     //Run the scheduler to start the tasks.
}

//This function must be called near the beginning of each ISR just before interrupts are re-enabled. This simply increments a counter representing the ISR call depth.
void YKEnterISR(void){
	// increment YKISRDepth
	YKISRDepth++;
}

//This function must be called near the end of each ISR after all handlers are called and while interrupts are disabled. It decrements the counter representing ISR call depth and calls the scheduler if the counter is zero. In the case of nested interrupts, the counter is zero only when exiting the last ISR, so it indicates when control will return to task code rather than another ISR. If it is the last ISR then control should return to the highest priority ready task. This may not be the task that was interrupted by this ISR if the actions of the interrupt handler made a higher priority task ready.
void YKExitISR(void){
	// decrement YKISRDepth
	YKISRDepth--;
	// if ISRDepth = 0 call scheduler
	if(YKISRDepth == 0) {
		if(hasRun == 1) // YKRun has been called
		{
			YKScheduler(1); // save with restore
		}
	}
}
 
