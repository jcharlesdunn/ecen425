; Generated by c86 (BYU-NASM) 5.1 (beta) from lab8app.i
	CPU	8086
	ALIGN	2
	jmp	main	; Jump to program start
	ALIGN	2
zone1Flat:
	DW	1
zone2Flat:
	DW	1
zone1Count:
	DW	0
zone2Count:
	DW	0
	ALIGN	2
recievedInterrupt:
	; >>>>> Line:	72
	; >>>>> { 
	jmp	L_lab8app_3
L_lab8app_4:
	; >>>>> Line:	73
	; >>>>> YKSemPost(semPtr); 
	push	word [semPtr]
	call	YKSemPost
	add	sp, 2
	mov	sp, bp
	pop	bp
	ret
L_lab8app_3:
	push	bp
	mov	bp, sp
	jmp	L_lab8app_4
L_lab8app_6:
	DB	"not enough pieces",0xD,0xA,0
	ALIGN	2
newPieceInterrupt:
	; >>>>> Line:	77
	; >>>>> { 
	jmp	L_lab8app_7
L_lab8app_8:
	; >>>>> Line:	78
	; >>>>> if (availablePieces <= 0) 
	cmp	word [L_lab8app_1], 0
	jg	L_lab8app_9
	; >>>>> Line:	80
	; >>>>> printString("not enough pieces\r\n"); 
	mov	ax, L_lab8app_6
	push	ax
	call	printString
	add	sp, 2
	; >>>>> Line:	81
	; >>>>>  
	mov	al, 255
	push	ax
	call	exit
	add	sp, 2
L_lab8app_9:
	; >>>>> Line:	83
	; >>>>> availablePieces--; 
	dec	word [L_lab8app_1]
	; >>>>> Line:	84
	; >>>>> pieces[availablePieces].ID = NewPieceID; 
	mov	ax, word [L_lab8app_1]
	mov	cx, 3
	shl	ax, cl
	mov	si, ax
	add	si, pieces
	mov	ax, word [NewPieceID]
	mov	word [si], ax
	; >>>>> Line:	85
	; >>>>> pieces[availablePieces].type = NewPieceType; 
	mov	ax, word [L_lab8app_1]
	mov	cx, 3
	shl	ax, cl
	add	ax, pieces
	mov	si, ax
	add	si, 2
	mov	ax, word [NewPieceType]
	mov	word [si], ax
	; >>>>> Line:	86
	; >>>>> pieces[availablePieces].orient = NewPieceOrientation; 
	mov	ax, word [L_lab8app_1]
	mov	cx, 3
	shl	ax, cl
	add	ax, pieces
	mov	si, ax
	add	si, 4
	mov	ax, word [NewPieceOrientation]
	mov	word [si], ax
	; >>>>> Line:	87
	; >>>>> pieces[availablePieces].column = NewPieceColumn; 
	mov	ax, word [L_lab8app_1]
	mov	cx, 3
	shl	ax, cl
	add	ax, pieces
	mov	si, ax
	add	si, 6
	mov	ax, word [NewPieceColumn]
	mov	word [si], ax
	; >>>>> Line:	88
	; >>>>> YKQPost(pieceQPtr, (void*) &(pieces[availablePieces])); 
	mov	ax, word [L_lab8app_1]
	mov	cx, 3
	shl	ax, cl
	add	ax, pieces
	push	ax
	push	word [pieceQPtr]
	call	YKQPost
	add	sp, 4
	mov	sp, bp
	pop	bp
	ret
L_lab8app_7:
	push	bp
	mov	bp, sp
	jmp	L_lab8app_8
L_lab8app_11:
	DB	"GAME OVER!",0
	ALIGN	2
setGameOver:
	; >>>>> Line:	92
	; >>>>> { 
	jmp	L_lab8app_12
L_lab8app_13:
	; >>>>> Line:	93
	; >>>>> printString("GAME OVER!"); 
	mov	ax, L_lab8app_11
	push	ax
	call	printString
	add	sp, 2
	; >>>>> Line:	94
	; >>>>> exit(0xff); 
	mov	al, 255
	push	ax
	call	exit
	add	sp, 2
	mov	sp, bp
	pop	bp
	ret
L_lab8app_12:
	push	bp
	mov	bp, sp
	jmp	L_lab8app_13
L_lab8app_15:
	DB	"no moves",0xD,0xA,0
	ALIGN	2
move:
	; >>>>> Line:	101
	; >>>>> { 
	jmp	L_lab8app_16
L_lab8app_17:
	; >>>>> Line:	102
	; >>>>> if (availableMoves <= 0) 
	cmp	word [L_lab8app_2], 0
	jg	L_lab8app_18
	; >>>>> Line:	104
	; >>>>> printString("no moves\r\n"); 
	mov	ax, L_lab8app_15
	push	ax
	call	printString
	add	sp, 2
	; >>>>> Line:	105
	; >>>>> exit(0 
	mov	al, 255
	push	ax
	call	exit
	add	sp, 2
L_lab8app_18:
	; >>>>> Line:	107
	; >>>>> availableMoves--; 
	dec	word [L_lab8app_2]
	; >>>>> Line:	108
	; >>>>> moves[availableMoves].id = id; 
	mov	ax, word [L_lab8app_2]
	shl	ax, 1
	shl	ax, 1
	add	ax, moves
	mov	si, ax
	add	si, 2
	mov	ax, word [bp+4]
	mov	word [si], ax
	; >>>>> Line:	109
	; >>>>> moves[availableMoves].move = move; 
	mov	ax, word [L_lab8app_2]
	shl	ax, 1
	shl	ax, 1
	mov	si, ax
	add	si, moves
	mov	ax, word [bp+6]
	mov	word [si], ax
	; >>>>> Line:	111
	; >>>>> YKQPost(moveQPtr, (void*) &(moves[availableMoves])); 
	mov	ax, word [L_lab8app_2]
	shl	ax, 1
	shl	ax, 1
	add	ax, moves
	push	ax
	push	word [moveQPtr]
	call	YKQPost
	add	sp, 4
	mov	sp, bp
	pop	bp
	ret
L_lab8app_16:
	push	bp
	mov	bp, sp
	jmp	L_lab8app_17
	ALIGN	2
cornerPieceZone1:
	; >>>>> Line:	116
	; >>>>> { 
	jmp	L_lab8app_20
L_lab8app_21:
	; >>>>> Line:	122
	; >>>>> if (!zone1Flat) 
	mov	si, word [bp+4]
	mov	ax, word [si]
	mov	word [bp-2], ax
	mov	si, word [bp+4]
	add	si, 2
	mov	ax, word [si]
	mov	word [bp-4], ax
	mov	si, word [bp+4]
	add	si, 4
	mov	ax, word [si]
	mov	word [bp-6], ax
	mov	si, word [bp+4]
	add	si, 6
	mov	ax, word [si]
	mov	word [bp-8], ax
	; >>>>> Line:	122
	; >>>>> if (!zone1Flat) 
	mov	ax, word [zone1Flat]
	test	ax, ax
	jne	L_lab8app_22
	; >>>>> Line:	125
	; >>>>> if (orientation == 1) 
	cmp	word [bp-6], 1
	jne	L_lab8app_23
	; >>>>> Line:	127
	; >>>>> move(id, 2); 
	mov	ax, 2
	push	ax
	push	word [bp-2]
	call	move
	add	sp, 4
	jmp	L_lab8app_24
L_lab8app_23:
	; >>>>> Line:	129
	; >>>>> else if (orientation == 3) 
	cmp	word [bp-6], 3
	jne	L_lab8app_25
	; >>>>> Line:	131
	; >>>>> if (column == 0) 
	mov	ax, word [bp-8]
	test	ax, ax
	jne	L_lab8app_26
	; >>>>> Line:	133
	; >>>>> move(id, 1); 
	mov	ax, 1
	push	ax
	push	word [bp-2]
	call	move
	add	sp, 4
	; >>>>> Line:	134
	; >>>>> = 0) 
	inc	word [bp-8]
L_lab8app_26:
	; >>>>> Line:	136
	; >>>>> move(id, 3); 
	mov	ax, 3
	push	ax
	push	word [bp-2]
	call	move
	add	sp, 4
	jmp	L_lab8app_27
L_lab8app_25:
	; >>>>> Line:	138
	; >>>>> else if (orientation == 0) 
	mov	ax, word [bp-6]
	test	ax, ax
	jne	L_lab8app_28
	; >>>>> Line:	140
	; >>>>> if (column == 0) 
	mov	ax, word [bp-8]
	test	ax, ax
	jne	L_lab8app_29
	; >>>>> Line:	142
	; >>>>> move(id, 1); 
	mov	ax, 1
	push	ax
	push	word [bp-2]
	call	move
	add	sp, 4
	; >>>>> Line:	143
	; >>>>> column++; 
	inc	word [bp-8]
L_lab8app_29:
	; >>>>> Line:	145
	; >>>>> move(id, 3); 
	mov	ax, 3
	push	ax
	push	word [bp-2]
	call	move
	add	sp, 4
	; >>>>> Line:	146
	; >>>>> move(id, 3); 
	mov	ax, 3
	push	ax
	push	word [bp-2]
	call	move
	add	sp, 4
L_lab8app_28:
L_lab8app_27:
L_lab8app_24:
	; >>>>> Line:	148
	; >>>>> tempColumn = column; 
	mov	ax, word [bp-8]
	mov	word [bp-10], ax
	; >>>>> Line:	149
	; >>>>> while (tempColumn != 2) 
	jmp	L_lab8app_31
L_lab8app_30:
	; >>>>> Line:	151
	; >>>>> if (tempColumn > 2) 
	cmp	word [bp-10], 2
	jbe	L_lab8app_33
	; >>>>> Line:	153
	; >>>>> move(id, 0); 
	xor	ax, ax
	push	ax
	push	word [bp-2]
	call	move
	add	sp, 4
	; >>>>> Line:	154
	; >>>>> tempColumn--; 
	dec	word [bp-10]
	jmp	L_lab8app_34
L_lab8app_33:
	; >>>>> Line:	158
	; >>>>> move(id, 1); 
	mov	ax, 1
	push	ax
	push	word [bp-2]
	call	move
	add	sp, 4
	; >>>>> Line:	159
	; >>>>> tempColumn++; 
	inc	word [bp-10]
L_lab8app_34:
L_lab8app_31:
	cmp	word [bp-10], 2
	jne	L_lab8app_30
L_lab8app_32:
	; >>>>> Line:	162
	; >>>>> zone1Flat = 1; 
	mov	word [zone1Flat], 1
	; >>>>> Line:	163
	; >>>>> zone1Count += 2; 
	add	word [zone1Count], 2
	jmp	L_lab8app_35
L_lab8app_22:
	; >>>>> Line:	165
	; >>>>> else if (!zone2Flat) 
	mov	ax, word [zone2Flat]
	test	ax, ax
	jne	L_lab8app_36
	; >>>>> Line:	168
	; >>>>> if (orientation == 1) 
	cmp	word [bp-6], 1
	jne	L_lab8app_37
	; >>>>> Line:	170
	; >>>>> move(id, 2); 
	mov	ax, 2
	push	ax
	push	word [bp-2]
	call	move
	add	sp, 4
	jmp	L_lab8app_38
L_lab8app_37:
	; >>>>> Line:	172
	; >>>>> else if (orientation == 3) 
	cmp	word [bp-6], 3
	jne	L_lab8app_39
	; >>>>> Line:	174
	; >>>>> if (column == 0) 
	mov	ax, word [bp-8]
	test	ax, ax
	jne	L_lab8app_40
	; >>>>> Line:	176
	; >>>>>  
	mov	ax, 1
	push	ax
	push	word [bp-2]
	call	move
	add	sp, 4
	; >>>>> Line:	177
	; >>>>> column++; 
	inc	word [bp-8]
L_lab8app_40:
	; >>>>> Line:	179
	; >>>>> move(id, 3); 
	mov	ax, 3
	push	ax
	push	word [bp-2]
	call	move
	add	sp, 4
	jmp	L_lab8app_41
L_lab8app_39:
	; >>>>> Line:	181
	; >>>>> else if (orientation == 0) 
	mov	ax, word [bp-6]
	test	ax, ax
	jne	L_lab8app_42
	; >>>>> Line:	183
	; >>>>> if (column == 0) 
	mov	ax, word [bp-8]
	test	ax, ax
	jne	L_lab8app_43
	; >>>>> Line:	185
	; >>>>> move(id, 1); 
	mov	ax, 1
	push	ax
	push	word [bp-2]
	call	move
	add	sp, 4
	; >>>>> Line:	186
	; >>>>> column++; 
	inc	word [bp-8]
L_lab8app_43:
	; >>>>> Line:	188
	; >>>>> move(id, 3); 
	mov	ax, 3
	push	ax
	push	word [bp-2]
	call	move
	add	sp, 4
	; >>>>> Line:	189
	; >>>>> move(id, 3); 
	mov	ax, 3
	push	ax
	push	word [bp-2]
	call	move
	add	sp, 4
L_lab8app_42:
L_lab8app_41:
L_lab8app_38:
	; >>>>> Line:	192
	; >>>>> tempColumn = column; 
	mov	ax, word [bp-8]
	mov	word [bp-10], ax
	; >>>>> Line:	193
	; >>>>> while (tempColumn != 5) 
	jmp	L_lab8app_45
L_lab8app_44:
	; >>>>> Line:	195
	; >>>>> move(id, 1); 
	mov	ax, 1
	push	ax
	push	word [bp-2]
	call	move
	add	sp, 4
	; >>>>> Line:	196
	; >>>>> tempColumn++; 
	inc	word [bp-10]
L_lab8app_45:
	cmp	word [bp-10], 5
	jne	L_lab8app_44
L_lab8app_46:
	; >>>>> Line:	198
	; >>>>> zone2Flat = 1; 
	mov	word [zone2Flat], 1
	; >>>>> Line:	199
	; >>>>> zone2Count += 2; 
	add	word [zone2Count], 2
	jmp	L_lab8app_47
L_lab8app_36:
	; >>>>> Line:	203
	; >>>>> if (orientation == 1) 
	cmp	word [bp-6], 1
	jne	L_lab8app_48
	; >>>>> Line:	205
	; >>>>> if (column == 5) 
	cmp	word [bp-8], 5
	jne	L_lab8app_49
	; >>>>> Line:	207
	; >>>>> move(id, 0); 
	xor	ax, ax
	push	ax
	push	word [bp-2]
	call	move
	add	sp, 4
	; >>>>> Line:	208
	; >>>>> column--; 
	dec	word [bp-8]
L_lab8app_49:
	; >>>>> Line:	210
	; >>>>> move(id, 3); 
	mov	ax, 3
	push	ax
	push	word [bp-2]
	call	move
	add	sp, 4
	jmp	L_lab8app_50
L_lab8app_48:
	; >>>>> Line:	212
	; >>>>> else if (orientation == 2) 
	cmp	word [bp-6], 2
	jne	L_lab8app_51
	; >>>>> Line:	214
	; >>>>> if (column == 5) 
	cmp	word [bp-8], 5
	jne	L_lab8app_52
	; >>>>> Line:	216
	; >>>>> move(id, 0); 
	xor	ax, ax
	push	ax
	push	word [bp-2]
	call	move
	add	sp, 4
	; >>>>> Line:	217
	; >>>>> if (col 
	dec	word [bp-8]
L_lab8app_52:
	; >>>>> Line:	219
	; >>>>> move(id, 3); 
	mov	ax, 3
	push	ax
	push	word [bp-2]
	call	move
	add	sp, 4
	; >>>>> Line:	220
	; >>>>> move(id, 3); 
	mov	ax, 3
	push	ax
	push	word [bp-2]
	call	move
	add	sp, 4
	jmp	L_lab8app_53
L_lab8app_51:
	; >>>>> Line:	222
	; >>>>> else if (orientation == 3) 
	cmp	word [bp-6], 3
	jne	L_lab8app_54
	; >>>>> Line:	224
	; >>>>> move(id, 2); 
	mov	ax, 2
	push	ax
	push	word [bp-2]
	call	move
	add	sp, 4
L_lab8app_54:
L_lab8app_53:
L_lab8app_50:
	; >>>>> Line:	226
	; >>>>> tempColumn = column; 
	mov	ax, word [bp-8]
	mov	word [bp-10], ax
	; >>>>> Line:	227
	; >>>>> while (tempColumn != 0){ 
	jmp	L_lab8app_56
L_lab8app_55:
	; >>>>> Line:	228
	; >>>>> move(id, 0); 
	xor	ax, ax
	push	ax
	push	word [bp-2]
	call	move
	add	sp, 4
	; >>>>> Line:	229
	; >>>>> tempColumn--; 
	dec	word [bp-10]
L_lab8app_56:
	mov	ax, word [bp-10]
	test	ax, ax
	jne	L_lab8app_55
L_lab8app_57:
	; >>>>> Line:	231
	; >>>>> zone1Flat = 0; 
	mov	word [zone1Flat], 0
L_lab8app_47:
L_lab8app_35:
	mov	sp, bp
	pop	bp
	ret
L_lab8app_20:
	push	bp
	mov	bp, sp
	sub	sp, 10
	jmp	L_lab8app_21
	ALIGN	2
cornerPieceZone2:
	; >>>>> Line:	236
	; >>>>> { 
	jmp	L_lab8app_59
L_lab8app_60:
	; >>>>> Line:	242
	; >>>>> if (!zone2Flat) 
	mov	si, word [bp+4]
	mov	ax, word [si]
	mov	word [bp-2], ax
	mov	si, word [bp+4]
	add	si, 2
	mov	ax, word [si]
	mov	word [bp-4], ax
	mov	si, word [bp+4]
	add	si, 4
	mov	ax, word [si]
	mov	word [bp-6], ax
	mov	si, word [bp+4]
	add	si, 6
	mov	ax, word [si]
	mov	word [bp-8], ax
	; >>>>> Line:	242
	; >>>>> if (!zone2Flat) 
	mov	ax, word [zone2Flat]
	test	ax, ax
	jne	L_lab8app_61
	; >>>>> Line:	244
	; >>>>> if (orientation == 1) 
	cmp	word [bp-6], 1
	jne	L_lab8app_62
	; >>>>> Line:	246
	; >>>>> move(id, 2); 
	mov	ax, 2
	push	ax
	push	word [bp-2]
	call	move
	add	sp, 4
	jmp	L_lab8app_63
L_lab8app_62:
	; >>>>> Line:	248
	; >>>>> else if (orientation == 3) 
	cmp	word [bp-6], 3
	jne	L_lab8app_64
	; >>>>> Line:	250
	; >>>>> if (col 
	mov	ax, word [bp-8]
	test	ax, ax
	jne	L_lab8app_65
	; >>>>> Line:	252
	; >>>>> move(id, 1); 
	mov	ax, 1
	push	ax
	push	word [bp-2]
	call	move
	add	sp, 4
	; >>>>> Line:	253
	; >>>>> column++; 
	inc	word [bp-8]
L_lab8app_65:
	; >>>>> Line:	255
	; >>>>> move(id, 3); 
	mov	ax, 3
	push	ax
	push	word [bp-2]
	call	move
	add	sp, 4
	jmp	L_lab8app_66
L_lab8app_64:
	; >>>>> Line:	257
	; >>>>> else if (orientation == 0) 
	mov	ax, word [bp-6]
	test	ax, ax
	jne	L_lab8app_67
	; >>>>> Line:	259
	; >>>>> if (column == 0) 
	mov	ax, word [bp-8]
	test	ax, ax
	jne	L_lab8app_68
	; >>>>> Line:	261
	; >>>>> move(id, 1); 
	mov	ax, 1
	push	ax
	push	word [bp-2]
	call	move
	add	sp, 4
	; >>>>> Line:	262
	; >>>>> column++; 
	inc	word [bp-8]
L_lab8app_68:
	; >>>>> Line:	264
	; >>>>> move(id, 3); 
	mov	ax, 3
	push	ax
	push	word [bp-2]
	call	move
	add	sp, 4
	; >>>>> Line:	265
	; >>>>> move(id, 3); 
	mov	ax, 3
	push	ax
	push	word [bp-2]
	call	move
	add	sp, 4
L_lab8app_67:
L_lab8app_66:
L_lab8app_63:
	; >>>>> Line:	267
	; >>>>> tempColumn = column; 
	mov	ax, word [bp-8]
	mov	word [bp-10], ax
	; >>>>> Line:	268
	; >>>>> while (tempColumn != 5) 
	jmp	L_lab8app_70
L_lab8app_69:
	; >>>>> Line:	270
	; >>>>> move(id, 1); 
	mov	ax, 1
	push	ax
	push	word [bp-2]
	call	move
	add	sp, 4
	; >>>>> Line:	271
	; >>>>> tempColumn++; 
	inc	word [bp-10]
L_lab8app_70:
	cmp	word [bp-10], 5
	jne	L_lab8app_69
L_lab8app_71:
	; >>>>> Line:	273
	; >>>>> zone2Flat = 1; 
	mov	word [zone2Flat], 1
	; >>>>> Line:	274
	; >>>>> zone2Count += 2; 
	add	word [zone2Count], 2
	jmp	L_lab8app_72
L_lab8app_61:
	; >>>>> Line:	276
	; >>>>> else if (!zone1Flat) 
	mov	ax, word [zone1Flat]
	test	ax, ax
	jne	L_lab8app_73
	; >>>>> Line:	278
	; >>>>> if (orientation == 1) 
	cmp	word [bp-6], 1
	jne	L_lab8app_74
	; >>>>> Line:	280
	; >>>>> move(id, 2); 
	mov	ax, 2
	push	ax
	push	word [bp-2]
	call	move
	add	sp, 4
	jmp	L_lab8app_75
L_lab8app_74:
	; >>>>> Line:	282
	; >>>>> else if (orientation == 3) 
	cmp	word [bp-6], 3
	jne	L_lab8app_76
	; >>>>> Line:	284
	; >>>>> if (column == 0) 
	mov	ax, word [bp-8]
	test	ax, ax
	jne	L_lab8app_77
	; >>>>> Line:	286
	; >>>>> move(id, 1); 
	mov	ax, 1
	push	ax
	push	word [bp-2]
	call	move
	add	sp, 4
	; >>>>> Line:	287
	; >>>>> column++; 
	inc	word [bp-8]
L_lab8app_77:
	; >>>>> Line:	289
	; >>>>> move(id, 3); 
	mov	ax, 3
	push	ax
	push	word [bp-2]
	call	move
	add	sp, 4
	jmp	L_lab8app_78
L_lab8app_76:
	; >>>>> Line:	291
	; >>>>> else if (orientation == 0) 
	mov	ax, word [bp-6]
	test	ax, ax
	jne	L_lab8app_79
	; >>>>> Line:	293
	; >>>>> if (column == 0) 
	mov	ax, word [bp-8]
	test	ax, ax
	jne	L_lab8app_80
	; >>>>> Line:	295
	; >>>>> move(id, 1); 
	mov	ax, 1
	push	ax
	push	word [bp-2]
	call	move
	add	sp, 4
	; >>>>> Line:	296
	; >>>>> column++; 
	inc	word [bp-8]
L_lab8app_80:
	; >>>>> Line:	298
	; >>>>> move(id, 3); 
	mov	ax, 3
	push	ax
	push	word [bp-2]
	call	move
	add	sp, 4
	; >>>>> Line:	299
	; >>>>> move(id, 3); 
	mov	ax, 3
	push	ax
	push	word [bp-2]
	call	move
	add	sp, 4
L_lab8app_79:
L_lab8app_78:
L_lab8app_75:
	; >>>>> Line:	301
	; >>>>> tempColumn = column; 
	mov	ax, word [bp-8]
	mov	word [bp-10], ax
	; >>>>> Line:	302
	; >>>>> while (tempColumn != 2) 
	jmp	L_lab8app_82
L_lab8app_81:
	; >>>>> Line:	304
	; >>>>> if (tempColumn > 2) 
	cmp	word [bp-10], 2
	jbe	L_lab8app_84
	; >>>>> Line:	306
	; >>>>> move(id, 0); 
	xor	ax, ax
	push	ax
	push	word [bp-2]
	call	move
	add	sp, 4
	; >>>>> Line:	307
	; >>>>> tempColumn--; 
	dec	word [bp-10]
	jmp	L_lab8app_85
L_lab8app_84:
	; >>>>> Line:	311
	; >>>>> move(id, 1); 
	mov	ax, 1
	push	ax
	push	word [bp-2]
	call	move
	add	sp, 4
	; >>>>> Line:	312
	; >>>>> tempColumn++; 
	inc	word [bp-10]
L_lab8app_85:
L_lab8app_82:
	cmp	word [bp-10], 2
	jne	L_lab8app_81
L_lab8app_83:
	; >>>>> Line:	315
	; >>>>> zone1Flat = 1; 
	mov	word [zone1Flat], 1
	; >>>>> Line:	316
	; >>>>> zone1Count += 2; 
	add	word [zone1Count], 2
	jmp	L_lab8app_86
L_lab8app_73:
	; >>>>> Line:	320
	; >>>>> if (orientation == 1) 
	cmp	word [bp-6], 1
	jne	L_lab8app_87
	; >>>>> Line:	322
	; >>>>> if (column == 5) 
	cmp	word [bp-8], 5
	jne	L_lab8app_88
	; >>>>> Line:	324
	; >>>>> move(id, 0); 
	xor	ax, ax
	push	ax
	push	word [bp-2]
	call	move
	add	sp, 4
	; >>>>> Line:	325
	; >>>>> column--; 
	dec	word [bp-8]
L_lab8app_88:
	; >>>>> Line:	327
	; >>>>> move(id, 3); 
	mov	ax, 3
	push	ax
	push	word [bp-2]
	call	move
	add	sp, 4
	jmp	L_lab8app_89
L_lab8app_87:
	; >>>>> Line:	329
	; >>>>> else if (orientation == 2) 
	cmp	word [bp-6], 2
	jne	L_lab8app_90
	; >>>>> Line:	331
	; >>>>> if (co 
	cmp	word [bp-8], 5
	jne	L_lab8app_91
	; >>>>> Line:	333
	; >>>>> move(id, 0); 
	xor	ax, ax
	push	ax
	push	word [bp-2]
	call	move
	add	sp, 4
	; >>>>> Line:	334
	; >>>>> column--; 
	dec	word [bp-8]
L_lab8app_91:
	; >>>>> Line:	336
	; >>>>> move(id, 3); 
	mov	ax, 3
	push	ax
	push	word [bp-2]
	call	move
	add	sp, 4
	; >>>>> Line:	337
	; >>>>> move(id, 3); 
	mov	ax, 3
	push	ax
	push	word [bp-2]
	call	move
	add	sp, 4
	jmp	L_lab8app_92
L_lab8app_90:
	; >>>>> Line:	339
	; >>>>> else if (orientation == 3) 
	cmp	word [bp-6], 3
	jne	L_lab8app_93
	; >>>>> Line:	341
	; >>>>> move(id, 2); 
	mov	ax, 2
	push	ax
	push	word [bp-2]
	call	move
	add	sp, 4
L_lab8app_93:
L_lab8app_92:
L_lab8app_89:
	; >>>>> Line:	344
	; >>>>> tempColumn = column; 
	mov	ax, word [bp-8]
	mov	word [bp-10], ax
	; >>>>> Line:	345
	; >>>>> while (tempColumn != 3) 
	jmp	L_lab8app_95
L_lab8app_94:
	; >>>>> Line:	347
	; >>>>> if (tempColumn > 3) 
	cmp	word [bp-10], 3
	jbe	L_lab8app_97
	; >>>>> Line:	349
	; >>>>> move(id, 0); 
	xor	ax, ax
	push	ax
	push	word [bp-2]
	call	move
	add	sp, 4
	; >>>>> Line:	350
	; >>>>> tempColumn--; 
	dec	word [bp-10]
	jmp	L_lab8app_98
L_lab8app_97:
	; >>>>> Line:	354
	; >>>>> move(id, 1); 
	mov	ax, 1
	push	ax
	push	word [bp-2]
	call	move
	add	sp, 4
	; >>>>> Line:	355
	; >>>>> tempColumn++; 
	inc	word [bp-10]
L_lab8app_98:
L_lab8app_95:
	cmp	word [bp-10], 3
	jne	L_lab8app_94
L_lab8app_96:
	; >>>>> Line:	358
	; >>>>> zone2Flat = 0; 
	mov	word [zone2Flat], 0
L_lab8app_86:
L_lab8app_72:
	mov	sp, bp
	pop	bp
	ret
L_lab8app_59:
	push	bp
	mov	bp, sp
	sub	sp, 10
	jmp	L_lab8app_60
	ALIGN	2
cornerPiece:
	; >>>>> Line:	363
	; >>>>> { 
	jmp	L_lab8app_100
L_lab8app_101:
	; >>>>> Line:	364
	; >>>>> if (zone1Count < zone2Count) 
	mov	ax, word [zone2Count]
	cmp	ax, word [zone1Count]
	jle	L_lab8app_102
	; >>>>> Line:	365
	; >>>>> cornerPieceZone1(input); 
	push	word [bp+4]
	call	cornerPieceZone1
	add	sp, 2
	jmp	L_lab8app_103
L_lab8app_102:
	; >>>>> Line:	367
	; >>>>> cornerPieceZone2(input); 
	push	word [bp+4]
	call	cornerPieceZone2
	add	sp, 2
L_lab8app_103:
	mov	sp, bp
	pop	bp
	ret
L_lab8app_100:
	push	bp
	mov	bp, sp
	jmp	L_lab8app_101
	ALIGN	2
straightPieceZone1:
	; >>>>> Line:	371
	; >>>>> void straightPieceZone1(PIECE* input){ 
	jmp	L_lab8app_105
L_lab8app_106:
	; >>>>> Line:	378
	; >>>>> if (orientation == 1) 
	mov	si, word [bp+4]
	mov	ax, word [si]
	mov	word [bp-2], ax
	mov	si, word [bp+4]
	add	si, 2
	mov	ax, word [si]
	mov	word [bp-4], ax
	mov	si, word [bp+4]
	add	si, 4
	mov	ax, word [si]
	mov	word [bp-6], ax
	mov	si, word [bp+4]
	add	si, 6
	mov	ax, word [si]
	mov	word [bp-8], ax
	; >>>>> Line:	378
	; >>>>> if (orientation == 1) 
	cmp	word [bp-6], 1
	jne	L_lab8app_107
	; >>>>> Line:	380
	; >>>>> if (column == 0) 
	mov	ax, word [bp-8]
	test	ax, ax
	jne	L_lab8app_108
	; >>>>> Line:	382
	; >>>>> move(id, 1); 
	mov	ax, 1
	push	ax
	push	word [bp-2]
	call	move
	add	sp, 4
	; >>>>> Line:	383
	; >>>>> column++; 
	inc	word [bp-8]
L_lab8app_108:
	; >>>>> Line:	385
	; >>>>> if (column == 5) 
	cmp	word [bp-8], 5
	jne	L_lab8app_109
	; >>>>> Line:	387
	; >>>>> move(id, 0); 
	xor	ax, ax
	push	ax
	push	word [bp-2]
	call	move
	add	sp, 4
	; >>>>> Line:	388
	; >>>>> column--; 
	dec	word [bp-8]
L_lab8app_109:
	; >>>>> Line:	390
	; >>>>> move(id, 3); 
	mov	ax, 3
	push	ax
	push	word [bp-2]
	call	move
	add	sp, 4
L_lab8app_107:
	; >>>>> Line:	392
	; >>>>> if (zone1Flat) 
	mov	ax, word [zone1Flat]
	test	ax, ax
	je	L_lab8app_110
	; >>>>> Line:	394
	; >>>>> tempColumn = column; 
	mov	ax, word [bp-8]
	mov	word [bp-10], ax
	; >>>>> Line:	395
	; >>>>> while (tempColumn != 1) 
	jmp	L_lab8app_112
L_lab8app_111:
	; >>>>> Line:	397
	; >>>>> move(id, 0); 
	xor	ax, ax
	push	ax
	push	word [bp-2]
	call	move
	add	sp, 4
	; >>>>> Line:	398
	; >>>>> tempColumn--; 
	dec	word [bp-10]
L_lab8app_112:
	cmp	word [bp-10], 1
	jne	L_lab8app_111
L_lab8app_113:
	; >>>>> Line:	400
	; >>>>> zone1Count++; 
	inc	word [zone1Count]
	jmp	L_lab8app_114
L_lab8app_110:
	; >>>>> Line:	404
	; >>>>> tempColumn = column; 
	mov	ax, word [bp-8]
	mov	word [bp-10], ax
	; >>>>> Line:	405
	; >>>>> while (tempColumn != 4) 
	jmp	L_lab8app_116
L_lab8app_115:
	; >>>>> Line:	407
	; >>>>> move(id, 1); 
	mov	ax, 1
	push	ax
	push	word [bp-2]
	call	move
	add	sp, 4
	; >>>>> Line:	408
	; >>>>>  
	inc	word [bp-10]
L_lab8app_116:
	cmp	word [bp-10], 4
	jne	L_lab8app_115
L_lab8app_117:
	; >>>>> Line:	410
	; >>>>> zone2Count++; 
	inc	word [zone2Count]
L_lab8app_114:
	mov	sp, bp
	pop	bp
	ret
L_lab8app_105:
	push	bp
	mov	bp, sp
	sub	sp, 10
	jmp	L_lab8app_106
	ALIGN	2
straightPieceZone2:
	; >>>>> Line:	414
	; >>>>> void straightPieceZone2(PIECE* input){ 
	jmp	L_lab8app_119
L_lab8app_120:
	; >>>>> Line:	420
	; >>>>> if (orientation == 1) 
	mov	si, word [bp+4]
	mov	ax, word [si]
	mov	word [bp-2], ax
	mov	si, word [bp+4]
	add	si, 2
	mov	ax, word [si]
	mov	word [bp-4], ax
	mov	si, word [bp+4]
	add	si, 4
	mov	ax, word [si]
	mov	word [bp-6], ax
	mov	si, word [bp+4]
	add	si, 6
	mov	ax, word [si]
	mov	word [bp-8], ax
	; >>>>> Line:	420
	; >>>>> if (orientation == 1) 
	cmp	word [bp-6], 1
	jne	L_lab8app_121
	; >>>>> Line:	422
	; >>>>> if (column == 0) 
	mov	ax, word [bp-8]
	test	ax, ax
	jne	L_lab8app_122
	; >>>>> Line:	424
	; >>>>> move(id, 1); 
	mov	ax, 1
	push	ax
	push	word [bp-2]
	call	move
	add	sp, 4
	; >>>>> Line:	425
	; >>>>> column++; 
	inc	word [bp-8]
L_lab8app_122:
	; >>>>> Line:	427
	; >>>>> if (column == 5) 
	cmp	word [bp-8], 5
	jne	L_lab8app_123
	; >>>>> Line:	429
	; >>>>> move(id, 0); 
	xor	ax, ax
	push	ax
	push	word [bp-2]
	call	move
	add	sp, 4
	; >>>>> Line:	430
	; >>>>> column--; 
	dec	word [bp-8]
L_lab8app_123:
	; >>>>> Line:	432
	; >>>>> move(id, 3); 
	mov	ax, 3
	push	ax
	push	word [bp-2]
	call	move
	add	sp, 4
L_lab8app_121:
	; >>>>> Line:	434
	; >>>>> if (zone2Flat) 
	mov	ax, word [zone2Flat]
	test	ax, ax
	je	L_lab8app_124
	; >>>>> Line:	436
	; >>>>> tempColumn = column; 
	mov	ax, word [bp-8]
	mov	word [bp-10], ax
	; >>>>> Line:	437
	; >>>>> while (tempColumn != 4) 
	jmp	L_lab8app_126
L_lab8app_125:
	; >>>>> Line:	439
	; >>>>> move(id, 1); 
	mov	ax, 1
	push	ax
	push	word [bp-2]
	call	move
	add	sp, 4
	; >>>>> Line:	440
	; >>>>> tempColumn++; 
	inc	word [bp-10]
L_lab8app_126:
	cmp	word [bp-10], 4
	jne	L_lab8app_125
L_lab8app_127:
	; >>>>> Line:	442
	; >>>>> zone2Count++; 
	inc	word [zone2Count]
	jmp	L_lab8app_128
L_lab8app_124:
	; >>>>> Line:	446
	; >>>>> tempColumn = column; 
	mov	ax, word [bp-8]
	mov	word [bp-10], ax
	; >>>>> Line:	447
	; >>>>> while (tempColumn != 1) 
	jmp	L_lab8app_130
L_lab8app_129:
	; >>>>> Line:	449
	; >>>>> move(id, 0); 
	xor	ax, ax
	push	ax
	push	word [bp-2]
	call	move
	add	sp, 4
	; >>>>> Line:	450
	; >>>>> tempColumn--; 
	dec	word [bp-10]
L_lab8app_130:
	cmp	word [bp-10], 1
	jne	L_lab8app_129
L_lab8app_131:
	; >>>>> Line:	452
	; >>>>> zone1Count++; 
	inc	word [zone1Count]
L_lab8app_128:
	mov	sp, bp
	pop	bp
	ret
L_lab8app_119:
	push	bp
	mov	bp, sp
	sub	sp, 10
	jmp	L_lab8app_120
	ALIGN	2
straightPeice:
	; >>>>> Line:	457
	; >>>>> { 
	jmp	L_lab8app_133
L_lab8app_134:
	; >>>>> Line:	458
	; >>>>> if (zone1Count < zone2Count) 
	mov	ax, word [zone2Count]
	cmp	ax, word [zone1Count]
	jle	L_lab8app_135
	; >>>>> Line:	459
	; >>>>> straightPieceZone1(input); 
	push	word [bp+4]
	call	straightPieceZone1
	add	sp, 2
	jmp	L_lab8app_136
L_lab8app_135:
	; >>>>> Line:	461
	; >>>>> straightPieceZone2(input); 
	push	word [bp+4]
	call	straightPieceZone2
	add	sp, 2
L_lab8app_136:
	mov	sp, bp
	pop	bp
	ret
L_lab8app_133:
	push	bp
	mov	bp, sp
	jmp	L_lab8app_134
	ALIGN	2
PTask:
	; >>>>> Line:	469
	; >>>>> { 
	jmp	L_lab8app_138
L_lab8app_139:
	; >>>>> Line:	472
	; >>>>> while(1) 
	jmp	L_lab8app_141
L_lab8app_140:
	; >>>>> Line:	474
	; >>>>> temp = (PIECE*)YKQPend(pieceQPtr); 
	push	word [pieceQPtr]
	call	YKQPend
	add	sp, 2
	mov	word [bp-2], ax
	; >>>>> Line:	475
	; >>>>> availablePieces++; 
	inc	word [L_lab8app_1]
	; >>>>> Line:	477
	; >>>>> if (temp->type) 
	mov	si, word [bp-2]
	add	si, 2
	mov	ax, word [si]
	test	ax, ax
	je	L_lab8app_143
	; >>>>> Line:	478
	; >>>>> straightPeice(temp); 
	push	word [bp-2]
	call	straightPeice
	add	sp, 2
	jmp	L_lab8app_144
L_lab8app_143:
	; >>>>> Line:	480
	; >>>>> cornerPiece(temp); 
	push	word [bp-2]
	call	cornerPiece
	add	sp, 2
L_lab8app_144:
L_lab8app_141:
	jmp	L_lab8app_140
L_lab8app_142:
	mov	sp, bp
	pop	bp
	ret
L_lab8app_138:
	push	bp
	mov	bp, sp
	sub	sp, 10
	jmp	L_lab8app_139
	ALIGN	2
MTask:
	; >>>>> Line:	486
	; >>>>> { 
	jmp	L_lab8app_146
L_lab8app_147:
	; >>>>> Line:	488
	; >>>>> while(1) 
	jmp	L_lab8app_149
L_lab8app_148:
	; >>>>> Line:	490
	; >>>>> temp = (MOVE*)YKQPend(moveQPtr); 
	push	word [moveQPtr]
	call	YKQPend
	add	sp, 2
	mov	word [bp-2], ax
	; >>>>> Line:	491
	; >>>>> availableMoves++; 
	inc	word [L_lab8app_2]
	; >>>>> Line:	492
	; >>>>> if (temp->move == 0) 
	mov	si, word [bp-2]
	mov	ax, word [si]
	test	ax, ax
	jne	L_lab8app_151
	; >>>>> Line:	493
	; >>>>> SlidePiece(temp->id, 0); 
	xor	ax, ax
	push	ax
	add	si, 2
	push	word [si]
	call	SlidePiece
	add	sp, 4
	jmp	L_lab8app_152
L_lab8app_151:
	; >>>>> Line:	494
	; >>>>> else if (temp->move == 1) 
	mov	si, word [bp-2]
	cmp	word [si], 1
	jne	L_lab8app_153
	; >>>>> Line:	495
	; >>>>> SlidePiece(temp->id, 1); 
	mov	ax, 1
	push	ax
	add	si, 2
	push	word [si]
	call	SlidePiece
	add	sp, 4
	jmp	L_lab8app_154
L_lab8app_153:
	; >>>>> Line:	496
	; >>>>> else if (temp->move == 2) 
	mov	si, word [bp-2]
	cmp	word [si], 2
	jne	L_lab8app_155
	; >>>>> Line:	497
	; >>>>> RotatePiece(temp->id, 0); 
	xor	ax, ax
	push	ax
	add	si, 2
	push	word [si]
	call	RotatePiece
	add	sp, 4
	jmp	L_lab8app_156
L_lab8app_155:
	; >>>>> Line:	499
	; >>>>> RotatePiece(temp->id, 1); 
	mov	ax, 1
	push	ax
	mov	si, word [bp-2]
	add	si, 2
	push	word [si]
	call	RotatePiece
	add	sp, 4
L_lab8app_156:
L_lab8app_154:
L_lab8app_152:
	; >>>>> Line:	500
	; >>>>> YKSemPend(semPtr); 
	push	word [semPtr]
	call	YKSemPend
	add	sp, 2
L_lab8app_149:
	jmp	L_lab8app_148
L_lab8app_150:
	mov	sp, bp
	pop	bp
	ret
L_lab8app_146:
	push	bp
	mov	bp, sp
	push	cx
	jmp	L_lab8app_147
L_lab8app_162:
	DB	"% >",0xD,0xA,0
L_lab8app_161:
	DB	", CPU: ",0
L_lab8app_160:
	DB	"<CS: ",0
L_lab8app_159:
	DB	"Determining CPU capacity",0xD,0xA,0
L_lab8app_158:
	DB	"Welcome to the YAK kernel",0xD,0xA,0
	ALIGN	2
STask:
	; >>>>> Line:	505
	; >>>>> { 
	jmp	L_lab8app_163
L_lab8app_164:
	; >>>>> Line:	509
	; >>>>> YKDelayTask(1); 
	mov	ax, 1
	push	ax
	call	YKDelayTask
	add	sp, 2
	; >>>>> Line:	510
	; >>>>> printString("Welcome to the YAK kernel\r\n"); 
	mov	ax, L_lab8app_158
	push	ax
	call	printString
	add	sp, 2
	; >>>>> Line:	511
	; >>>>> tchCount); 
	mov	ax, L_lab8app_159
	push	ax
	call	printString
	add	sp, 2
	; >>>>> Line:	512
	; >>>>> YKDelayTask(1); 
	mov	ax, 1
	push	ax
	call	YKDelayTask
	add	sp, 2
	; >>>>> Line:	513
	; >>>>> YKIdleCount = 0; 
	mov	word [YKIdleCount], 0
	; >>>>> Line:	514
	; >>>>> YKDelayTask(5); 
	mov	ax, 5
	push	ax
	call	YKDelayTask
	add	sp, 2
	; >>>>> Line:	515
	; >>>>> max = YKIdleCount / 25; 
	mov	ax, word [YKIdleCount]
	xor	dx, dx
	mov	cx, 25
	div	cx
	mov	word [bp-4], ax
	; >>>>> Line:	516
	; >>>>> YKIdleCount = 0; 
	mov	word [YKIdleCount], 0
	; >>>>> Line:	519
	; >>>>> StartSimptris(); 
	call	StartSimptris
	; >>>>> Line:	521
	; >>>>> YKNewTask(PTask, (void*) &PTaskStk[4096], 20); 
	mov	al, 20
	push	ax
	mov	ax, (PTaskStk+8192)
	push	ax
	mov	ax, PTask
	push	ax
	call	YKNewTask
	add	sp, 6
	; >>>>> Line:	522
	; >>>>> YKNewTask(MTask, (void*) &MTaskStk[4096], 10); 
	mov	al, 10
	push	ax
	mov	ax, (MTaskStk+8192)
	push	ax
	mov	ax, MTask
	push	ax
	call	YKNewTask
	add	sp, 6
	; >>>>> Line:	525
	; >>>>> while(1) 
	jmp	L_lab8app_166
L_lab8app_165:
	; >>>>> Line:	527
	; >>>>> YKDelayTask(20); 
	mov	ax, 20
	push	ax
	call	YKDelayTask
	add	sp, 2
	; >>>>> Line:	529
	; >>>>> YKEnterMutex(); 
	call	YKEnterMutex
	; >>>>> Line:	530
	; >>>>> switchCount = YKCtxSwCount; 
	mov	ax, word [YKCtxSwCount]
	mov	word [bp-6], ax
	; >>>>> Line:	531
	; >>>>> idleCount = YKIdleCount; 
	mov	ax, word [YKIdleCount]
	mov	word [bp-2], ax
	; >>>>> Line:	532
	; >>>>> YKExitMutex(); 
	call	YKExitMutex
	; >>>>> Line:	534
	; >>>>> printString("<CS: "); 
	mov	ax, L_lab8app_160
	push	ax
	call	printString
	add	sp, 2
	; >>>>> Line:	535
	; >>>>> printInt((int)switchCount); 
	push	word [bp-6]
	call	printInt
	add	sp, 2
	; >>>>> Line:	536
	; >>>>> n(); 
	mov	ax, L_lab8app_161
	push	ax
	call	printString
	add	sp, 2
	; >>>>> Line:	537
	; >>>>> tmp = (int) (idleCount/max); 
	mov	ax, word [bp-2]
	xor	dx, dx
	div	word [bp-4]
	mov	word [bp-8], ax
	; >>>>> Line:	538
	; >>>>> printInt(100-tmp); 
	mov	ax, 100
	sub	ax, word [bp-8]
	push	ax
	call	printInt
	add	sp, 2
	; >>>>> Line:	539
	; >>>>> printString("% >\r\n"); 
	mov	ax, L_lab8app_162
	push	ax
	call	printString
	add	sp, 2
	; >>>>> Line:	541
	; >>>>> YKEnterMutex(); 
	call	YKEnterMutex
	; >>>>> Line:	542
	; >>>>> YKCtxSwCount = 0; 
	mov	word [YKCtxSwCount], 0
	; >>>>> Line:	543
	; >>>>> YKIdleCount = 0; 
	mov	word [YKIdleCount], 0
	; >>>>> Line:	544
	; >>>>> YKExitMutex(); 
	call	YKExitMutex
L_lab8app_166:
	jmp	L_lab8app_165
L_lab8app_167:
	mov	sp, bp
	pop	bp
	ret
L_lab8app_163:
	push	bp
	mov	bp, sp
	sub	sp, 8
	jmp	L_lab8app_164
	ALIGN	2
main:
	; >>>>> Line:	551
	; >>>>> { 
	jmp	L_lab8app_169
L_lab8app_170:
	; >>>>> Line:	552
	; >>>>> YKInitialize(); 
	call	YKInitialize
	; >>>>> Line:	554
	; >>>>> YKNewTask(STask, (void *) &STaskStk[4096], 30); 
	mov	al, 30
	push	ax
	mov	ax, (STaskStk+8192)
	push	ax
	mov	ax, STask
	push	ax
	call	YKNewTask
	add	sp, 6
	; >>>>> Line:	555
	; >>>>> semPtr = YKSemCreate(0); 
	xor	ax, ax
	push	ax
	call	YKSemCreate
	add	sp, 2
	mov	word [semPtr], ax
	; >>>>> Line:	556
	; >>>>> pieceQPtr = YKQCreate(pieceQ, 10); 
	mov	ax, 10
	push	ax
	mov	ax, pieceQ
	push	ax
	call	YKQCreate
	add	sp, 4
	mov	word [pieceQPtr], ax
	; >>>>> Line:	557
	; >>>>> moveQPtr = YKQCreate(moveQ, 10); 
	mov	ax, 10
	push	ax
	mov	ax, moveQ
	push	ax
	call	YKQCreate
	add	sp, 4
	mov	word [moveQPtr], ax
	; >>>>> Line:	558
	; >>>>> availablePieces = 10; 
	mov	word [L_lab8app_1], 10
	; >>>>> Line:	559
	; >>>>> availableMoves = 10; 
	mov	word [L_lab8app_2], 10
	; >>>>> Line:	561
	; >>>>> SeedSimptris(87245); 
	mov	ax, 21709
	mov	dx, 1
	push	dx
	push	ax
	call	SeedSimptris
	add	sp, 4
	; >>>>> Line:	562
	; >>>>> YKRun(); 
	call	YKRun
	mov	sp, bp
	pop	bp
	ret
L_lab8app_169:
	push	bp
	mov	bp, sp
	jmp	L_lab8app_170
	ALIGN	2
semPtr:
	TIMES	2 db 0
pieceQ:
	TIMES	20 db 0
pieceQPtr:
	TIMES	2 db 0
moveQ:
	TIMES	20 db 0
moveQPtr:
	TIMES	2 db 0
PTaskStk:
	TIMES	8192 db 0
MTaskStk:
	TIMES	8192 db 0
STaskStk:
	TIMES	8192 db 0
pieces:
	TIMES	80 db 0
L_lab8app_1:
	TIMES	2 db 0
moves:
	TIMES	40 db 0
L_lab8app_2:
	TIMES	2 db 0