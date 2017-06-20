/* 
File: lab7app.c
Revision date: 10 November 2005
Description: Application code for EE 425 lab 7 (Event flags)
*/

#include "clib.h"
#include "yakk.h"                     /* contains kernel definitions */
#include "lab7defs.h"
#include "simptris.h"

#define TASK_STACK_SIZE   512         /* stack size in words */

#define PQSIZE          10


int PieceTaskStk[TASK_STACK_SIZE];
int MoveTaskStk[TASK_STACK_SIZE];
int STaskStk[TASK_STACK_SIZE];

void *PieceQ[PQSIZE];           /* space for message queue */
YKQ *PQPtr;                   /* actual name of queue */



//task that takes peices from a queue, and then smartly determines a move
//peices in that q, are placed from interrupt
void PieceTask(void)
{
	//printString("PieceTask\n");
}



//task that takes move from move q, and then calls the move,
// it pends the move semaphore




void STask(void)           /* tracks statistics */
{
    unsigned max, switchCount, idleCount;
    int tmp;

    YKDelayTask(1);
    printString("Welcome to the YAK kernel\r\n");
    printString("Determining CPU capacity\r\n");
    YKDelayTask(1);
    YKIdleCount = 0;
    YKDelayTask(5);
    max = YKIdleCount / 25;
    YKIdleCount = 0;

    //YKNewTask(CharTask, (void *) &CharTaskStk[TASK_STACK_SIZE], 2);
	YKNewTask(PieceTask, (void *) &PieceTaskStk[TASK_STACK_SIZE], 0);
    
    while (1)
    {
        YKDelayTask(20);
        
        YKEnterMutex();
        switchCount = YKCtxSwCount;
        idleCount = YKIdleCount;
        YKExitMutex();
        
        printString("<<<<< Context switches: ");
        printInt((int)switchCount);
        printString(", CPU usage: ");
        tmp = (int) (idleCount/max);
        printInt(100-tmp);
        printString("% >>>>>\r\n");
        
        YKEnterMutex();
        YKCtxSwCount = 0;
        YKIdleCount = 0;
        YKExitMutex();
    }
}   



void main(void)
{
    YKInitialize(); 
	PQPtr = YKQCreate(PieceQ, PQSIZE);
    YKNewTask(STask, (void *) &STaskStk[TASK_STACK_SIZE], 1);
    SeedSimptris((long)1);
	StartSimptris();
    YKRun();
}
