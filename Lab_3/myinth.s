; Generated by c86 (BYU-NASM) 5.1 (beta) from myinth.i
	CPU	8086
	ALIGN	2
	jmp	main	; Jump to program start
	ALIGN	2
resetHandler:
	; >>>>> Line:	9
	; >>>>> { 
	jmp	L_myinth_1
L_myinth_2:
	; >>>>> Line:	10
	; >>>>> exit(0); 
	xor	al, al
	push	ax
	call	exit
	add	sp, 2
	mov	sp, bp
	pop	bp
	ret
L_myinth_1:
	push	bp
	mov	bp, sp
	jmp	L_myinth_2
	ALIGN	2
L_myinth_4:
	DD	0
L_myinth_6:
	DB	":",0xA,0
L_myinth_5:
	DB	0xA,"TICK ",0
	ALIGN	2
tickHandler:
	; >>>>> Line:	14
	; >>>>> { 
	jmp	L_myinth_7
L_myinth_8:
	; >>>>> Line:	16
	; >>>>> tickCount++; 
	add	word [(L_myinth_4+0)], 1
	adc	word [(L_myinth_4+2)], 0
	; >>>>> Line:	17
	; >>>>> printString("\nTICK "); 
	mov	ax, L_myinth_5
	push	ax
	call	printString
	add	sp, 2
	; >>>>> Line:	18
	; >>>>> printUInt(tickCount); 
	mov	ax, word [(L_myinth_4+0)]
	push	ax
	call	printUInt
	add	sp, 2
	; >>>>> Line:	19
	; >>>>> printString(":\n"); 
	mov	ax, L_myinth_6
	push	ax
	call	printString
	add	sp, 2
	mov	sp, bp
	pop	bp
	ret
L_myinth_7:
	push	bp
	mov	bp, sp
	jmp	L_myinth_8
L_myinth_11:
	DB	"DELAY COMPLETE",0xA,0
L_myinth_10:
	DB	0xA,"DELAY KEY PRESSED",0xA,0
	ALIGN	2
dKeyDelay:
	; >>>>> Line:	23
	; >>>>> { 
	jmp	L_myinth_12
L_myinth_13:
	; >>>>> Line:	25
	; >>>>> printString("\nDELAY KEY PRESSED\n"); 
	mov	word [bp-4], 0
	mov	word [bp-2], 0
	; >>>>> Line:	25
	; >>>>> printString("\nDELAY KEY PRESSED\n"); 
	mov	ax, L_myinth_10
	push	ax
	call	printString
	add	sp, 2
	; >>>>> Line:	26
	; >>>>> while(delayCount < 5000) 
	jmp	L_myinth_15
L_myinth_14:
	; >>>>> Line:	28
	; >>>>> delayCount++; 
	add	word [bp-4], 1
	adc	word [bp-2], 0
L_myinth_15:
	cmp	word [bp-2], 0
	jb	L_myinth_14
	jne	L_myinth_17
	cmp	word [bp-4], 5000
	jb	L_myinth_14
L_myinth_17:
L_myinth_16:
	; >>>>> Line:	30
	; >>>>> printString("DELAY COMPLETE\n"); 
	mov	ax, L_myinth_11
	push	ax
	call	printString
	add	sp, 2
	mov	sp, bp
	pop	bp
	ret
L_myinth_12:
	push	bp
	mov	bp, sp
	sub	sp, 4
	jmp	L_myinth_13
L_myinth_20:
	DB	") IGNORED",0
L_myinth_19:
	DB	0xA,"KEYPRESS (",0
	ALIGN	2
keyboardHandler:
	; >>>>> Line:	35
	; >>>>> { 
	jmp	L_myinth_21
L_myinth_22:
	; >>>>> Line:	36
	; >>>>> if(KeyBuffer == 100) 
	cmp	word [KeyBuffer], 100
	jne	L_myinth_23
	; >>>>> Line:	38
	; >>>>> dKeyDelay(); 
	call	dKeyDelay
	jmp	L_myinth_24
L_myinth_23:
	; >>>>> Line:	42
	; >>>>> printS 
	mov	ax, L_myinth_19
	push	ax
	call	printString
	add	sp, 2
	; >>>>> Line:	43
	; >>>>> printChar(KeyBuffer); 
	push	word [KeyBuffer]
	call	printChar
	add	sp, 2
	; >>>>> Line:	44
	; >>>>> printString(") IGNORED"); 
	mov	ax, L_myinth_20
	push	ax
	call	printString
	add	sp, 2
	; >>>>> Line:	45
	; >>>>> printString(":\n"); 
	mov	ax, L_myinth_6
	push	ax
	call	printString
	add	sp, 2
L_myinth_24:
	mov	sp, bp
	pop	bp
	ret
L_myinth_21:
	push	bp
	mov	bp, sp
	jmp	L_myinth_22
