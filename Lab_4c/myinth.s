; Generated by c86 (BYU-NASM) 5.1 (beta) from myinth.i
	CPU	8086
	ALIGN	2
	jmp	main	; Jump to program start
	ALIGN	2
L_myinth_1:
	DW	0
L_myinth_2:
	DB	"RESET ",0
	ALIGN	2
ResetHandler:
	; >>>>> Line:	8
	; >>>>> { 
	jmp	L_myinth_3
L_myinth_4:
	; >>>>> Line:	9
	; >>>>> printString("RESET "); 
	mov	ax, L_myinth_2
	push	ax
	call	printString
	add	sp, 2
	; >>>>> Line:	10
	; >>>>> exit(0); 
	xor	al, al
	push	ax
	call	exit
	add	sp, 2
	mov	sp, bp
	pop	bp
	ret
L_myinth_3:
	push	bp
	mov	bp, sp
	jmp	L_myinth_4
L_myinth_7:
	DB	0xA,0
L_myinth_6:
	DB	"TICK ",0
	ALIGN	2
TickHandler:
	; >>>>> Line:	14
	; >>>>> { 
	jmp	L_myinth_8
L_myinth_9:
	; >>>>> Line:	15
	; >>>>> tickCounter++; 
	inc	word [L_myinth_1]
	; >>>>> Line:	16
	; >>>>> printNewLine(); 
	call	printNewLine
	; >>>>> Line:	17
	; >>>>> printString("TICK "); 
	mov	ax, L_myinth_6
	push	ax
	call	printString
	add	sp, 2
	; >>>>> Line:	18
	; >>>>> printUInt(tickCounter); 
	push	word [L_myinth_1]
	call	printUInt
	add	sp, 2
	; >>>>> Line:	19
	; >>>>> printString("\n"); 
	mov	ax, L_myinth_7
	push	ax
	call	printString
	add	sp, 2
	; >>>>> Line:	20
	; >>>>> YKTickHandler(); 
	call	YKTickHandler
	mov	sp, bp
	pop	bp
	ret
L_myinth_8:
	push	bp
	mov	bp, sp
	jmp	L_myinth_9
	ALIGN	2
L_myinth_11:
	DW	0
L_myinth_15:
	DB	") IGNORED",0xA,0
L_myinth_14:
	DB	"KEYPRESS (",0
L_myinth_13:
	DB	"DELAY COMPLETE",0xA," ",0
L_myinth_12:
	DB	"DELAY KEY PRESSED",0xA," ",0
	ALIGN	2
KeyHandler:
	; >>>>> Line:	24
	; >>>>> { 
	jmp	L_myinth_16
L_myinth_17:
	; >>>>> Line:	26
	; >>>>> if(KeyBuffer == 100) 
	cmp	word [KeyBuffer], 100
	jne	L_myinth_18
	; >>>>> Line:	28
	; >>>>> counter = 0; 
	mov	word [L_myinth_11], 0
	; >>>>> Line:	29
	; >>>>> printString("DELAY KEY PRESSED\n "); 
	mov	ax, L_myinth_12
	push	ax
	call	printString
	add	sp, 2
	; >>>>> Line:	30
	; >>>>> while(counter < 5000) counter++; 
	jmp	L_myinth_20
L_myinth_19:
	; >>>>> Line:	30
	; >>>>> while(counter < 5000) counter++; 
	inc	word [L_myinth_11]
L_myinth_20:
	cmp	word [L_myinth_11], 5000
	jl	L_myinth_19
L_myinth_21:
	; >>>>> Line:	31
	; >>>>> printString("DELAY COMPLETE\n "); 
	mov	ax, L_myinth_13
	push	ax
	call	printString
	add	sp, 2
	jmp	L_myinth_22
L_myinth_18:
	; >>>>> Line:	35
	; >>>>> printString("KEYPRESS ("); 
	mov	ax, L_myinth_14
	push	ax
	call	printString
	add	sp, 2
	; >>>>> Line:	36
	; >>>>> printChar(Ke 
	push	word [KeyBuffer]
	call	printChar
	add	sp, 2
	; >>>>> Line:	37
	; >>>>> printString(") IGNORED\n"); 
	mov	ax, L_myinth_15
	push	ax
	call	printString
	add	sp, 2
L_myinth_22:
	mov	sp, bp
	pop	bp
	ret
L_myinth_16:
	push	bp
	mov	bp, sp
	jmp	L_myinth_17
