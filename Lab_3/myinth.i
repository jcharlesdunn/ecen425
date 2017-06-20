# 1 "myinth.c"
# 1 "<built-in>"
# 1 "<command-line>"
# 1 "/usr/include/stdc-predef.h" 1 3 4
# 1 "<command-line>" 2
# 1 "myinth.c"

# 1 "clib.h" 1



void print(char *string, int length);
void printNewLine(void);
void printChar(char c);
void printString(char *string);


void printInt(int val);
void printLong(long val);
void printUInt(unsigned val);
void printULong(unsigned long val);


void printByte(char val);
void printWord(int val);
void printDWord(long val);


void exit(unsigned char code);


void signalEOI(void);
# 3 "myinth.c" 2



extern int KeyBuffer;

void resetHandler(void)
{
    exit(0);
}

void tickHandler(void)
{
 static unsigned long tickCount = 0;
 tickCount++;
 printString("\nTICK ");
 printUInt(tickCount);
 printString(":\n");
}

void dKeyDelay(void)
{
 unsigned long delayCount = 0;
 printString("\nDELAY KEY PRESSED\n");
 while(delayCount < 5000)
 {
  delayCount++;
 }
 printString("DELAY COMPLETE\n");

}

void keyboardHandler(void)
{
 if(KeyBuffer == 100)
 {
  dKeyDelay();
 }
 else
 {
  printString("\nKEYPRESS (");
  printChar(KeyBuffer);
  printString(") IGNORED");
  printString(":\n");
 }
}
