/* 
File: lab4d_app.c
Revision date: 23 December 2003
Description: Application code for EE 425 lab 4D (Kernel essentials D)
*/

#include "clib.h"
#include "yakk.h"

#define ASTACKSIZE 256          /* Size of task's stack in words */
#define BSTACKSIZE 256
#define CSTACKSIZE 256
#define DSTACKSIZE 256

int AStk[ASTACKSIZE];           /* Space for each task's stack  */
int BStk[BSTACKSIZE];
int CStk[CSTACKSIZE];
int DStk[CSTACKSIZE];

void ATask(void);               /* Function prototypes for task code */
void BTask(void);
void CTask(void);
void DTask(void);

void main(void)
{
    YKInitialize();
    
    printString("Creating tasks...\n");
    YKNewTask(ATask, (void *) &AStk[ASTACKSIZE], 3);
    YKNewTask(BTask, (void *) &BStk[BSTACKSIZE], 5);
    YKNewTask(CTask, (void *) &CStk[CSTACKSIZE], 7);
    YKNewTask(DTask, (void *) &DStk[DSTACKSIZE], 8);
    
    printString("Starting kernel...\n");
    YKRun();
}

void ATask(void)
{
    printString("Task A started.\n");
    while (1)
    {
        printString("Task A, delaying 2.\n");
        YKDelayTask(2);
    }
}

void BTask(void)
{
    printString("Task B started.\n");
    while (1)
    {
        printString("Task B, delaying 3.\n");
        YKDelayTask(3);
    }
}

void CTask(void)
{
    printString("Task C started.\n");
    while (1)
    {
        printString("Task C, delaying 5.\n");
        YKDelayTask(5);
    }
}

void DTask(void)
{
    printString("Task D started.\n");
    while (1)
    {
        printString("Task D, delaying 10.\n");
        YKDelayTask(10);
    }
}



/* 
File: lab4c_app.c
Revision date: 23 December 2003
Description: Application code for EE 425 lab 4C (Kernel essentials C)
*/
/*
#include "clib.h"
#include "yakk.h"

#define STACKSIZE 256          

int TaskStack[STACKSIZE];     

void Task(void);               

void main(void)
{
    YKInitialize();
    
    printString("Creating task...\n");
    YKNewTask(Task, (void *) &TaskStack[STACKSIZE], 0);

    printString("Starting kernel...\n");
    YKRun();
}

void Task(void)
{
    unsigned idleCount;
    unsigned numCtxSwitches;

    printString("Task started.\n");
    while (1)
    {
        printString("Delaying task...\n");

        YKDelayTask(2);

        YKEnterMutex();
        numCtxSwitches = YKCtxSwCount;
        idleCount = YKIdleCount;
        YKIdleCount = 0;
        YKExitMutex();

        printString("Task running after ");
        printUInt(numCtxSwitches);
        printString(" context switches! YKIdleCount is ");
        printUInt(idleCount);
        printString(".\n");
    }
}*/

