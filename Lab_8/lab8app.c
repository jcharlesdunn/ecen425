#include "clib.h"
#include "yakk.h"   
#include "simptris.h"                  /* contains kernel definitions */

#define TASK_STACK_SIZE  4096 
#define pieceQSize 10
#define moveQSize 10

#define BL_CORNER 0
#define BR_CORNER 1
#define TR_CORNER 2
#define TL_CORNER 3

#define HORIZONTAL 0
#define VERTICAL 1

#define STRAIGHT 1
#define CORNER 0

#define MOVE_LEFT 0
#define MOVE_RIGHT 1
#define MOVE_RCCW 2			//Rotate CCW in moveQ move
#define MOVE_RCW 3			//Rotate CW in moveQ move
#define ROTATE_CCW 0
#define ROTATE_CW 1

// ------------ Variable Declarations ------------------ //
extern unsigned NewPieceID;
extern unsigned NewPieceType;
extern unsigned NewPieceOrientation;
extern unsigned NewPieceColumn;
extern unsigned TouchdownID;

YKSEM* semPtr;						//Sem pointer blocks communication task until acknowledge

void *pieceQ[pieceQSize];           //Queue for the piece
YKQ* pieceQPtr;

void *moveQ[moveQSize];             //Queue for the movement
YKQ* moveQPtr;

int PTaskStk[TASK_STACK_SIZE];    
int MTaskStk[TASK_STACK_SIZE];
int STaskStk[TASK_STACK_SIZE];

typedef struct pieceInfo {
    unsigned ID;
    unsigned type;
    unsigned orient;
    unsigned column;
} PIECE;

typedef struct moveInfo {
    int move;
    unsigned id;
} MOVE;

PIECE pieces[pieceQSize];
static int availablePieces;

MOVE moves[moveQSize];
static int availableMoves;

int zone1Flat = 1;	//1 = true, 0 = false
int zone2Flat = 1;	//1 = true, 0 = false
int zone1Count = 0;
int zone2Count = 0;

/////////////////////////////////Interrupt handlers

void recievedInterrupt(void)
{
    YKSemPost(semPtr);
}

void newPieceInterrupt(void)
{
    if (availablePieces <= 0)
	{
        printString("not enough pieces\r\n");
        exit (0xff);
    }
    availablePieces--;
    pieces[availablePieces].ID = NewPieceID;
    pieces[availablePieces].type = NewPieceType;
    pieces[availablePieces].orient = NewPieceOrientation;
    pieces[availablePieces].column = NewPieceColumn;
    YKQPost(pieceQPtr, (void*) &(pieces[availablePieces]));
}

void setGameOver(void)
{
    printString("GAME OVER!");
    exit(0xff);
}

//Move Algorithms

//Queue full of moves
void move(unsigned id, int move)
{
    if (availableMoves <= 0)
	{
        printString("no moves\r\n");
        exit(0xff);
    }
    availableMoves--;
    moves[availableMoves].id = id;
    moves[availableMoves].move = move;

    YKQPost(moveQPtr, (void*) &(moves[availableMoves]));
}


void cornerPieceZone1(PIECE* input)
{
	unsigned id = input->ID;
	unsigned type = input->type;
	unsigned orientation = input->orient;
	unsigned column = input->column;
	unsigned tempColumn;
	if (!zone1Flat)
	{
		//Rotation
		if (orientation == 1)
		{
			move(id, MOVE_RCCW);
		}
		else if (orientation == 3)
		{	
			if (column == 0)
			{
				move(id, MOVE_RIGHT);
				column++;
			}
			move(id, MOVE_RCW);
		}
		else if (orientation == 0)
		{
			if (column == 0)
			{
				move(id, MOVE_RIGHT);
				column++;
			}
			move(id, MOVE_RCW);
			move(id, MOVE_RCW);
		}
		tempColumn = column;
		while (tempColumn != 2)
		{
			if (tempColumn > 2)
			{
				move(id, MOVE_LEFT);
				tempColumn--;
			}
			else
			{
				move(id, MOVE_RIGHT);
				tempColumn++;				
			}
		}
		zone1Flat = 1;
		zone1Count += 2;
	}
	else if (!zone2Flat)
	{
		//Rotation
		if (orientation == 1)
		{
			move(id, MOVE_RCCW);
		}
		else if (orientation == 3)
		{
			if (column == 0)
			{
				move(id, MOVE_RIGHT);
				column++;
			}
			move(id, MOVE_RCW);
		}
		else if (orientation == 0)
		{
			if (column == 0)
			{
				move(id, MOVE_RIGHT);
				column++;
			}
			move(id, MOVE_RCW);
			move(id, MOVE_RCW);
		}
		//Move
		tempColumn = column;
		while (tempColumn != 5)
		{
			move(id, MOVE_RIGHT);
			tempColumn++;				
		}
		zone2Flat = 1;
		zone2Count += 2;
	}
	else //put it in zone 1
	{
		if (orientation == 1)
		{	
			if (column == 5)
			{
				move(id, MOVE_LEFT);
				column--;
			}
			move(id, MOVE_RCW);
		}
		else if (orientation == 2)
		{
			if (column == 5)
			{
				move(id, MOVE_LEFT);
				column--;
			}
			move(id, MOVE_RCW);
			move(id, MOVE_RCW);
		}
		else if (orientation == 3)
		{		
			move(id, MOVE_RCCW);
		}
		tempColumn = column;
		while (tempColumn != 0){
			move(id, MOVE_LEFT);
			tempColumn--;
		}
		zone1Flat = 0;
	}
}

void cornerPieceZone2(PIECE* input)
{
	unsigned id = input->ID;
	unsigned type = input->type;
	unsigned orientation = input->orient;
	unsigned column = input->column;
	unsigned tempColumn;
	if (!zone2Flat)
	{
		if (orientation == 1)
		{
			move(id, MOVE_RCCW);
		}
		else if (orientation == 3)
		{
			if (column == 0)
			{
				move(id, MOVE_RIGHT);
				column++;
			}
			move(id, MOVE_RCW);
		}
		else if (orientation == 0)
		{
			if (column == 0)
			{
				move(id, MOVE_RIGHT);
				column++;
			}
			move(id, MOVE_RCW);
			move(id, MOVE_RCW);
		}
		tempColumn = column;
		while (tempColumn != 5)
		{
			move(id, MOVE_RIGHT);
			tempColumn++;				
		}
		zone2Flat = 1;
		zone2Count += 2;
	}
	else if (!zone1Flat)
	{
		if (orientation == 1)
		{
			move(id, MOVE_RCCW);
		}
		else if (orientation == 3)
		{
			if (column == 0)
			{
				move(id, MOVE_RIGHT);
				column++;
			}
			move(id, MOVE_RCW);
		}
		else if (orientation == 0)
		{	
			if (column == 0)
			{
				move(id, MOVE_RIGHT);
				column++;
			}
			move(id, MOVE_RCW);
			move(id, MOVE_RCW);
		}
		tempColumn = column;
		while (tempColumn != 2)
		{
			if (tempColumn > 2)
			{
				move(id, MOVE_LEFT);
				tempColumn--;
			}
			else
			{
				move(id, MOVE_RIGHT);
				tempColumn++;				
			}
		}
		zone1Flat = 1;
		zone1Count += 2;
	}
	else //put it in zone 2
	{
		if (orientation == 1)
		{
			if (column == 5)
			{
				move(id, MOVE_LEFT);
				column--;
			}
			move(id, MOVE_RCW);
		}
		else if (orientation == 2)
		{
			if (column == 5)
			{
				move(id, MOVE_LEFT);
				column--;
			}
			move(id, MOVE_RCW);
			move(id, MOVE_RCW);
		}
		else if (orientation == 3)
		{		
			move(id, MOVE_RCCW);
		}
		//move	
		tempColumn = column;
		while (tempColumn != 3)
		{
			if (tempColumn > 3)
			{
				move(id, MOVE_LEFT);
				tempColumn--;
			}
			else
			{
				move(id, MOVE_RIGHT);
				tempColumn++;				
			}
		}
		zone2Flat = 0;
	}
}

void cornerPiece(PIECE* input)
{
	if (zone1Count < zone2Count)
		cornerPieceZone1(input);
	else
		cornerPieceZone2(input);
}


void straightPieceZone1(PIECE* input){
	unsigned id = input->ID;
	unsigned type = input->type;
	unsigned orientation = input->orient;
	unsigned column = input->column;
	unsigned tempColumn;
	//Rotation
	if (orientation == 1)
	{
		if (column == 0)
		{
			move(id, MOVE_RIGHT);
			column++;
		}
		if (column == 5)
		{
			move(id, MOVE_LEFT);
			column--;				
		}
		move(id, MOVE_RCW);
	}
	if (zone1Flat)	//Zone 1 is flat
	{
		tempColumn = column;
		while (tempColumn != 1)
		{
			move(id, MOVE_LEFT);
			tempColumn--;
		}
		zone1Count++;		
	}	
	else
	{
		tempColumn = column;
		while (tempColumn != 4)
		{
			move(id, MOVE_RIGHT);
			tempColumn++;
		}
		zone2Count++;	
	}
}

void straightPieceZone2(PIECE* input){
	unsigned id = input->ID;
	unsigned type = input->type;
	unsigned orientation = input->orient;
	unsigned column = input->column;
	unsigned tempColumn;
	if (orientation == 1)
	{	
		if (column == 0)
		{
			move(id, MOVE_RIGHT);
			column++;
		}
		if (column == 5)
		{
			move(id, MOVE_LEFT);
			column--;				
		}
		move(id, MOVE_RCW);
	}
	if (zone2Flat)
	{
		tempColumn = column;
		while (tempColumn != 4)
		{
			move(id, MOVE_RIGHT);
			tempColumn++;
		}
		zone2Count++;	
	}	
	else
	{
		tempColumn = column;
		while (tempColumn != 1)
		{
			move(id, MOVE_LEFT);
			tempColumn--;
		}
		zone1Count++;	
	}
}

void straightPeice(PIECE* input)
{
	if (zone1Count < zone2Count)
		straightPieceZone1(input);
	else
		straightPieceZone2(input);
}


//Task Code


void PTask()
{ 
    PIECE* temp;
    int id, col, orientation, type;
    while(1)
	{
        temp = (PIECE*)YKQPend(pieceQPtr); 
        availablePieces++;

        if (temp->type)		
			straightPeice(temp);		
        else
            cornerPiece(temp);
    }
}


void MTask()
{
    MOVE* temp;
    while(1)
	{
        temp = (MOVE*)YKQPend(moveQPtr);
        availableMoves++;
		if (temp->move == 0)
			SlidePiece(temp->id, MOVE_LEFT);
		else if (temp->move == 1)
			SlidePiece(temp->id, MOVE_RIGHT);
		else if (temp->move == 2)
			RotatePiece(temp->id, ROTATE_CCW);
		else
			RotatePiece(temp->id, ROTATE_CW);
        YKSemPend(semPtr);
    }
}

void STask()
{
    unsigned idleCount, max;
    int switchCount, tmp;

    YKDelayTask(1);
    printString("Welcome to the YAK kernel\r\n");
    printString("Determining CPU capacity\r\n");
    YKDelayTask(1);
    YKIdleCount = 0;
    YKDelayTask(5);
    max = YKIdleCount / 25;
    YKIdleCount = 0;

    // Run Simptris
    StartSimptris();

    YKNewTask(PTask, (void*) &PTaskStk[TASK_STACK_SIZE], 20);
    YKNewTask(MTask, (void*) &MTaskStk[TASK_STACK_SIZE], 10);
 

    while(1)
	{
        YKDelayTask(20);

        YKEnterMutex();
        switchCount = YKCtxSwCount;
        idleCount = YKIdleCount;
        YKExitMutex();
        
        printString("<CS: ");
        printInt((int)switchCount);
        printString(", CPU: ");
        tmp = (int) (idleCount/max);
        printInt(100-tmp);
        printString("% >\r\n");
        
        YKEnterMutex();
        YKCtxSwCount = 0;
        YKIdleCount = 0;
        YKExitMutex();
    }
    

}

void main(void)
{
    YKInitialize();

    YKNewTask(STask, (void *) &STaskStk[TASK_STACK_SIZE], 30);
    semPtr = YKSemCreate(0);
    pieceQPtr = YKQCreate(pieceQ, pieceQSize);
    moveQPtr = YKQCreate(moveQ, moveQSize);
    availablePieces = pieceQSize;
    availableMoves = moveQSize; 
    //SeedSimptris(87245); class seed
	SeedSimptris(87245); //gets 236
    YKRun();
}
