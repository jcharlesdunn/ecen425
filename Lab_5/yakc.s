; Generated by c86 (BYU-NASM) 5.1 (beta) from yakc.i
	CPU	8086
	ALIGN	2
	jmp	main	; Jump to program start
	ALIGN	2
YKCtxSwCount:
	DW	0
i:
	DW	0
hasRun:
	DW	0
	ALIGN	2
YKInitialize:
	; >>>>> Line:	36
	; >>>>> { 
	jmp	L_yakc_1
L_yakc_2:
	; >>>>> Line:	37
	; >>>>> YKEnterMutex(); 
	call	YKEnterMutex
	; >>>>> Line:	38
	; >>>>> YKIMRInit(0x00); 
	xor	ax, ax
	push	ax
	call	YKIMRInit
	add	sp, 2
	; >>>>> Line:	39
	; >>>>> YKCtxSwCount = 0; 
	mov	word [YKCtxSwCount], 0
	; >>>>> Line:	40
	; >>>>> YKIdleCount = 0; 
	mov	word [YKIdleCount], 0
	; >>>>> Line:	41
	; >>>>> YKTickNum = 0; 
	mov	word [YKTickNum], 0
	; >>>>> Line:	42
	; >>>>> ISRDepth = 0; 
	mov	word [ISRDepth], 0
	; >>>>> Line:	43
	; >>>>> YKSave = 0; 
	mov	word [YKSave], 0
	; >>>>> Line:	44
	; >>>>> YKRestore = 0; 
	mov	word [YKRestore], 0
	; >>>>> Line:	45
	; >>>>> YKRdyList = 0; 
	mov	word [YKRdyList], 0
	; >>>>> Line:	46
	; >>>>> YKSuspList = 0; 
	mov	word [YKSuspList], 0
	; >>>>> Line:	47
	; >>>>> YKRunningTask = 0; 
	mov	word [YKRunningTask], 0
	; >>>>> Line:	48
	; >>>>> hasRun = 0; 
	mov	word [hasRun], 0
	; >>>>> Line:	49
	; >>>>> YKAvaiSems = 4; 
	mov	word [YKAvaiSems], 4
	; >>>>> Line:	51
	; >>>>> YKAvailTCBList = &(YKTCBArray[0]); 
	mov	word [YKAvailTCBList], YKTCBArray
	; >>>>> Line:	53
	; >>>>> for (i = 0; 
	mov	word [i], 0
	jmp	L_yakc_4
L_yakc_3:
	; >>>>> Line:	54
	; >>>>> YKTCBArray[i].next = &(YKTCBArray[i+1]); 
	mov	ax, word [i]
	inc	ax
	mov	cx, 4
	shl	ax, cl
	add	ax, YKTCBArray
	mov	dx, word [i]
	mov	cx, 4
	shl	dx, cl
	add	dx, YKTCBArray
	mov	si, dx
	add	si, 12
	mov	word [si], ax
L_yakc_6:
	inc	word [i]
L_yakc_4:
	cmp	word [i], 6
	jl	L_yakc_3
L_yakc_5:
	; >>>>> Line:	56
	; >>>>> YKTCBArray[6].next = 0; 
	mov	word [(108+YKTCBArray)], 0
	; >>>>> Line:	57
	; >>>>> YKTCBArray[6].prev = 0; 
	mov	word [(110+YKTCBArray)], 0
	; >>>>> Line:	59
	; >>>>> YKNewTask(YKIdleTask,(void *) &(idleStk[2048]),100); 
	mov	al, 100
	push	ax
	mov	ax, (idleStk+4096)
	push	ax
	mov	ax, YKIdleTask
	push	ax
	call	YKNewTask
	add	sp, 6
	mov	sp, bp
	pop	bp
	ret
L_yakc_1:
	push	bp
	mov	bp, sp
	jmp	L_yakc_2
	ALIGN	2
YKIdleTask:
	; >>>>> Line:	63
	; >>>>> void YKIdleTask(){ 
	jmp	L_yakc_8
L_yakc_9:
	; >>>>> Line:	64
	; >>>>> while(1){ 
	jmp	L_yakc_11
L_yakc_10:
	; >>>>> Line:	66
	; >>>>> YKEnterMutex(); 
	call	YKEnterMutex
	; >>>>> Line:	67
	; >>>>> YKIdleCount++; 
	inc	word [YKIdleCount]
	; >>>>> Line:	68
	; >>>>> YKExitMutex(); 
	call	YKExitMutex
L_yakc_11:
	jmp	L_yakc_10
L_yakc_12:
	mov	sp, bp
	pop	bp
	ret
L_yakc_8:
	push	bp
	mov	bp, sp
	jmp	L_yakc_9
	ALIGN	2
YKScheduler:
	; >>>>> Line:	72
	; >>>>> void YKScheduler(int isSaved){ 
	jmp	L_yakc_14
L_yakc_15:
	; >>>>> Line:	73
	; >>>>> if (YKRunningTask != YKRdyList){ 
	mov	ax, word [YKRdyList]
	cmp	ax, word [YKRunningTask]
	je	L_yakc_16
	; >>>>> Line:	74
	; >>>>> YKCtxSwCount++; 
	inc	word [YKCtxSwCount]
	; >>>>> Line:	75
	; >>>>> YKDispatcher(isSaved); 
	push	word [bp+4]
	call	YKDispatcher
	add	sp, 2
L_yakc_16:
	mov	sp, bp
	pop	bp
	ret
L_yakc_14:
	push	bp
	mov	bp, sp
	jmp	L_yakc_15
	ALIGN	2
YKNewTask:
	; >>>>> Line:	83
	; >>>>> { 
	jmp	L_yakc_18
L_yakc_19:
	; >>>>> Line:	87
	; >>>>> YKEnterMutex(); 
	call	YKEnterMutex
	; >>>>> Line:	89
	; >>>>> newPoint = YKAvailTCBList; 
	mov	ax, word [YKAvailTCBList]
	mov	word [bp-4], ax
	; >>>>> Line:	90
	; >>>>> if(newPoint == 0){ 
	mov	ax, word [bp-4]
	test	ax, ax
	jne	L_yakc_20
	; >>>>> Line:	91
	; >>>>> return; 
	jmp	L_yakc_21
L_yakc_20:
	; >>>>> Line:	94
	; >>>>> YKAvailTCBList = newPoint->next; 
	mov	si, word [bp-4]
	add	si, 12
	mov	ax, word [si]
	mov	word [YKAvailTCBList], ax
	; >>>>> Line:	97
	; >>>>> newPoint->priority = priority; 
	mov	al, byte [bp+8]
	xor	ah, ah
	mov	si, word [bp-4]
	add	si, 4
	mov	word [si], ax
	; >>>>> Line:	98
	; >>>>> newPoint->delay = 0; 
	mov	si, word [bp-4]
	add	si, 6
	mov	word [si], 0
	; >>>>> Line:	99
	; >>>>> newPoint->state = 1; 
	mov	si, word [bp-4]
	add	si, 2
	mov	word [si], 1
	; >>>>> Line:	101
	; >>>>> if (YKRdyList == 0) 
	mov	ax, word [YKRdyList]
	test	ax, ax
	jne	L_yakc_22
	; >>>>> Line:	103
	; >>>>> YKRdyList = newPoint; 
	mov	ax, word [bp-4]
	mov	word [YKRdyList], ax
	; >>>>> Line:	104
	; >>>>> newPoint->next = 0; 
	mov	si, word [bp-4]
	add	si, 12
	mov	word [si], 0
	; >>>>> Line:	105
	; >>>>> newPoint->prev = 0; 
	mov	si, word [bp-4]
	add	si, 14
	mov	word [si], 0
	jmp	L_yakc_23
L_yakc_22:
	; >>>>> Line:	109
	; >>>>> comparisonPoint = YKRdyList; 
	mov	ax, word [YKRdyList]
	mov	word [bp-6], ax
	; >>>>> Line:	110
	; >>>>> for (i = 0; i < 6; i ++) 
	mov	word [i], 0
	jmp	L_yakc_25
L_yakc_24:
	; >>>>> Line:	112
	; >>>>> if (newPoint->priority < comparison 
	mov	si, word [bp-4]
	add	si, 4
	mov	di, word [bp-6]
	add	di, 4
	mov	ax, word [di]
	cmp	ax, word [si]
	jle	L_yakc_28
	; >>>>> Line:	113
	; >>>>> break; 
	jmp	L_yakc_26
	jmp	L_yakc_29
L_yakc_28:
	; >>>>> Line:	116
	; >>>>> comparisonPoint = comparisonPoint->next; 
	mov	si, word [bp-6]
	add	si, 12
	mov	ax, word [si]
	mov	word [bp-6], ax
L_yakc_29:
L_yakc_27:
	inc	word [i]
L_yakc_25:
	cmp	word [i], 6
	jl	L_yakc_24
L_yakc_26:
	; >>>>> Line:	119
	; >>>>> if (comparisonPoint->prev == 0){ 
	mov	si, word [bp-6]
	add	si, 14
	mov	ax, word [si]
	test	ax, ax
	jne	L_yakc_30
	; >>>>> Line:	120
	; >>>>> YKRdyList = newPoint; 
	mov	ax, word [bp-4]
	mov	word [YKRdyList], ax
	jmp	L_yakc_31
L_yakc_30:
	; >>>>> Line:	123
	; >>>>> comparisonPoint->prev->next = newPoint; 
	mov	si, word [bp-6]
	add	si, 14
	mov	si, word [si]
	add	si, 12
	mov	ax, word [bp-4]
	mov	word [si], ax
L_yakc_31:
	; >>>>> Line:	126
	; >>>>> newPoint->prev = comparisonPoint->prev; 
	mov	si, word [bp-6]
	add	si, 14
	mov	di, word [bp-4]
	add	di, 14
	mov	ax, word [si]
	mov	word [di], ax
	; >>>>> Line:	127
	; >>>>> newPoint->next = comparisonPoint; 
	mov	si, word [bp-4]
	add	si, 12
	mov	ax, word [bp-6]
	mov	word [si], ax
	; >>>>> Line:	128
	; >>>>> comparisonPoint->prev = newPoint; 
	mov	si, word [bp-6]
	add	si, 14
	mov	ax, word [bp-4]
	mov	word [si], ax
L_yakc_23:
	; >>>>> Line:	131
	; >>>>> stackPoint = (unsigned *)taskStack; 
	mov	ax, word [bp+6]
	mov	word [bp-2], ax
	; >>>>> Line:	134
	; >>>>> for (i = 0; i < 13; i++) 
	mov	word [i], 0
	jmp	L_yakc_33
L_yakc_32:
	; >>>>> Line:	136
	; >>>>> if (i == 1){ 
	cmp	word [i], 1
	jne	L_yakc_36
	; >>>>> Line:	137
	; >>>>> stackPoint[0] = 0x0200; 
	mov	si, word [bp-2]
	mov	word [si], 512
	jmp	L_yakc_37
L_yakc_36:
	; >>>>> Line:	139
	; >>>>> else if (i 
	cmp	word [i], 3
	jne	L_yakc_38
	; >>>>> Line:	140
	; >>>>> stackPoint[0] = (unsigned)task; 
	mov	si, word [bp-2]
	mov	ax, word [bp+4]
	mov	word [si], ax
	jmp	L_yakc_39
L_yakc_38:
	; >>>>> Line:	143
	; >>>>> stackPoint[0] = 0; 
	mov	si, word [bp-2]
	mov	word [si], 0
L_yakc_39:
L_yakc_37:
	; >>>>> Line:	145
	; >>>>> stackPoint--; 
	sub	word [bp-2], 2
L_yakc_35:
	inc	word [i]
L_yakc_33:
	cmp	word [i], 13
	jl	L_yakc_32
L_yakc_34:
	; >>>>> Line:	148
	; >>>>> newPoint->stackptr = (void *)stackPoint; 
	mov	si, word [bp-4]
	mov	ax, word [bp-2]
	mov	word [si], ax
	; >>>>> Line:	150
	; >>>>> if(hasRun == 1) { 
	cmp	word [hasRun], 1
	jne	L_yakc_40
	; >>>>> Line:	151
	; >>>>> YKScheduler(0); 
	xor	ax, ax
	push	ax
	call	YKScheduler
	add	sp, 2
	; >>>>> Line:	152
	; >>>>> YKExitMutex(); 
	call	YKExitMutex
L_yakc_40:
L_yakc_21:
	mov	sp, bp
	pop	bp
	ret
L_yakc_18:
	push	bp
	mov	bp, sp
	sub	sp, 6
	jmp	L_yakc_19
	ALIGN	2
YKDelayTask:
	; >>>>> Line:	157
	; >>>>> { 
	jmp	L_yakc_42
L_yakc_43:
	; >>>>> Line:	159
	; >>>>> YKEnterMutex(); 
	call	YKEnterMutex
	; >>>>> Line:	160
	; >>>>> if (count == 0){ 
	mov	ax, word [bp+4]
	test	ax, ax
	jne	L_yakc_44
	; >>>>> Line:	161
	; >>>>> YKExitMutex(); 
	call	YKExitMutex
	; >>>>> Line:	162
	; >>>>> return; 
	jmp	L_yakc_45
L_yakc_44:
	; >>>>> Line:	165
	; >>>>> delayPoint = YKRdyList; 
	mov	ax, word [YKRdyList]
	mov	word [bp-2], ax
	; >>>>> Line:	166
	; >>>>> YKRdyList = delayPoint->next; 
	mov	si, word [bp-2]
	add	si, 12
	mov	ax, word [si]
	mov	word [YKRdyList], ax
	; >>>>> Line:	167
	; >>>>> if (YKRdyList != 0) 
	mov	ax, word [YKRdyList]
	test	ax, ax
	je	L_yakc_46
	; >>>>> Line:	169
	; >>>>> YKRdyList->prev = 0; 
	mov	si, word [YKRdyList]
	add	si, 14
	mov	word [si], 0
L_yakc_46:
	; >>>>> Line:	171
	; >>>>> delayPoint->state = 0; 
	mov	si, word [bp-2]
	add	si, 2
	mov	word [si], 0
	; >>>>> Line:	172
	; >>>>> delayPoint->delay = count; 
	mov	si, word [bp-2]
	add	si, 6
	mov	ax, word [bp+4]
	mov	word [si], ax
	; >>>>> Line:	173
	; >>>>> != 0) 
	mov	si, word [bp-2]
	add	si, 12
	mov	ax, word [YKSuspList]
	mov	word [si], ax
	; >>>>> Line:	174
	; >>>>> YKSuspList = delayPoint; 
	mov	ax, word [bp-2]
	mov	word [YKSuspList], ax
	; >>>>> Line:	175
	; >>>>> delayPoint->prev = 0; 
	mov	si, word [bp-2]
	add	si, 14
	mov	word [si], 0
	; >>>>> Line:	176
	; >>>>> if (delayPoint->next != 0) 
	mov	si, word [bp-2]
	add	si, 12
	mov	ax, word [si]
	test	ax, ax
	je	L_yakc_47
	; >>>>> Line:	178
	; >>>>> delayPoint->next->prev = delayPoint; 
	mov	si, word [bp-2]
	add	si, 12
	mov	si, word [si]
	add	si, 14
	mov	ax, word [bp-2]
	mov	word [si], ax
L_yakc_47:
	; >>>>> Line:	180
	; >>>>> YKScheduler(0); 
	xor	ax, ax
	push	ax
	call	YKScheduler
	add	sp, 2
	; >>>>> Line:	181
	; >>>>> YKExitMutex(); 
	call	YKExitMutex
L_yakc_45:
	mov	sp, bp
	pop	bp
	ret
L_yakc_42:
	push	bp
	mov	bp, sp
	push	cx
	jmp	L_yakc_43
L_yakc_50:
	DB	0xA,0xD,0
L_yakc_49:
	DB	"TICK ",0
	ALIGN	2
YKTickHandler:
	; >>>>> Line:	185
	; >>>>> { 
	jmp	L_yakc_51
L_yakc_52:
	; >>>>> Line:	187
	; >>>>> YKTickNum++; 
	inc	word [YKTickNum]
	; >>>>> Line:	189
	; >>>>> printString("TICK "); 
	mov	ax, L_yakc_49
	push	ax
	call	printString
	add	sp, 2
	; >>>>> Line:	190
	; >>>>> printInt(YKTickNum); 
	push	word [YKTickNum]
	call	printInt
	add	sp, 2
	; >>>>> Line:	191
	; >>>>> printString("\n\r"); 
	mov	ax, L_yakc_50
	push	ax
	call	printString
	add	sp, 2
	; >>>>> Line:	193
	; >>>>> temp = YKSuspList; 
	mov	ax, word [YKSuspList]
	mov	word [bp-2], ax
	; >>>>> Line:	194
	; >>>>> while (temp != 0) 
	jmp	L_yakc_54
L_yakc_53:
	; >>>>> Line:	196
	; >>>>> temp->delay--; 
	mov	si, word [bp-2]
	add	si, 6
	dec	word [si]
	; >>>>> Line:	197
	; >>>>> if (temp->delay == 0) 
	mov	si, word [bp-2]
	add	si, 6
	mov	ax, word [si]
	test	ax, ax
	jne	L_yakc_56
	; >>>>> Line:	199
	; >>>>> temp->state = 1; 
	mov	si, word [bp-2]
	add	si, 2
	mov	word [si], 1
	; >>>>> Line:	200
	; >>>>> taskHold = temp->next; 
	mov	si, word [bp-2]
	add	si, 12
	mov	ax, word [si]
	mov	word [bp-4], ax
	; >>>>> Line:	201
	; >>>>> if (temp->prev != 0) 
	mov	si, word [bp-2]
	add	si, 14
	mov	ax, word [si]
	test	ax, ax
	je	L_yakc_57
	; >>>>> Line:	203
	; >>>>>  
	mov	si, word [bp-2]
	add	si, 12
	mov	di, word [bp-2]
	add	di, 14
	mov	di, word [di]
	add	di, 12
	mov	ax, word [si]
	mov	word [di], ax
	jmp	L_yakc_58
L_yakc_57:
	; >>>>> Line:	206
	; >>>>> YKSuspList = temp->next; 
	mov	si, word [bp-2]
	add	si, 12
	mov	ax, word [si]
	mov	word [YKSuspList], ax
L_yakc_58:
	; >>>>> Line:	208
	; >>>>> if (temp->next != 0) 
	mov	si, word [bp-2]
	add	si, 12
	mov	ax, word [si]
	test	ax, ax
	je	L_yakc_59
	; >>>>> Line:	210
	; >>>>> temp->next->prev = temp->prev; 
	mov	si, word [bp-2]
	add	si, 14
	mov	di, word [bp-2]
	add	di, 12
	mov	di, word [di]
	add	di, 14
	mov	ax, word [si]
	mov	word [di], ax
L_yakc_59:
	; >>>>> Line:	212
	; >>>>> comparisonPoint = YKRdyList; 
	mov	ax, word [YKRdyList]
	mov	word [bp-6], ax
	; >>>>> Line:	214
	; >>>>> for (i = 0; i < 6; i ++) 
	mov	word [i], 0
	jmp	L_yakc_61
L_yakc_60:
	; >>>>> Line:	216
	; >>>>> if (temp->priority < comparisonPoint->priority){ 
	mov	si, word [bp-2]
	add	si, 4
	mov	di, word [bp-6]
	add	di, 4
	mov	ax, word [di]
	cmp	ax, word [si]
	jle	L_yakc_64
	; >>>>> Line:	217
	; >>>>> break; 
	jmp	L_yakc_62
	jmp	L_yakc_65
L_yakc_64:
	; >>>>> Line:	220
	; >>>>> comparisonPoint = comparisonPoint->next; 
	mov	si, word [bp-6]
	add	si, 12
	mov	ax, word [si]
	mov	word [bp-6], ax
L_yakc_65:
L_yakc_63:
	inc	word [i]
L_yakc_61:
	cmp	word [i], 6
	jl	L_yakc_60
L_yakc_62:
	; >>>>> Line:	223
	; >>>>> if (comparisonPoint->prev == 0){ 
	mov	si, word [bp-6]
	add	si, 14
	mov	ax, word [si]
	test	ax, ax
	jne	L_yakc_66
	; >>>>> Line:	224
	; >>>>> YKRdyList = temp; 
	mov	ax, word [bp-2]
	mov	word [YKRdyList], ax
	jmp	L_yakc_67
L_yakc_66:
	; >>>>> Line:	227
	; >>>>> comparisonPoint->prev->next = temp; 
	mov	si, word [bp-6]
	add	si, 14
	mov	si, word [si]
	add	si, 12
	mov	ax, word [bp-2]
	mov	word [si], ax
L_yakc_67:
	; >>>>> Line:	230
	; >>>>> temp->prev = c 
	mov	si, word [bp-6]
	add	si, 14
	mov	di, word [bp-2]
	add	di, 14
	mov	ax, word [si]
	mov	word [di], ax
	; >>>>> Line:	231
	; >>>>> temp->next = comparisonPoint; 
	mov	si, word [bp-2]
	add	si, 12
	mov	ax, word [bp-6]
	mov	word [si], ax
	; >>>>> Line:	232
	; >>>>> comparisonPoint->prev = temp; 
	mov	si, word [bp-6]
	add	si, 14
	mov	ax, word [bp-2]
	mov	word [si], ax
	; >>>>> Line:	233
	; >>>>> temp = taskHold; 
	mov	ax, word [bp-4]
	mov	word [bp-2], ax
	jmp	L_yakc_68
L_yakc_56:
	; >>>>> Line:	236
	; >>>>> temp = temp->next; 
	mov	si, word [bp-2]
	add	si, 12
	mov	ax, word [si]
	mov	word [bp-2], ax
L_yakc_68:
L_yakc_54:
	mov	ax, word [bp-2]
	test	ax, ax
	jne	L_yakc_53
L_yakc_55:
	mov	sp, bp
	pop	bp
	ret
L_yakc_51:
	push	bp
	mov	bp, sp
	sub	sp, 6
	jmp	L_yakc_52
	ALIGN	2
YKRun:
	; >>>>> Line:	241
	; >>>>> void YKRun(void){ 
	jmp	L_yakc_70
L_yakc_71:
	; >>>>> Line:	242
	; >>>>> hasRun = 1; 
	mov	word [hasRun], 1
	; >>>>> Line:	243
	; >>>>> YKScheduler(0); 
	xor	ax, ax
	push	ax
	call	YKScheduler
	add	sp, 2
	mov	sp, bp
	pop	bp
	ret
L_yakc_70:
	push	bp
	mov	bp, sp
	jmp	L_yakc_71
	ALIGN	2
YKEnterISR:
	; >>>>> Line:	247
	; >>>>> { 
	jmp	L_yakc_73
L_yakc_74:
	; >>>>> Line:	248
	; >>>>> ISRDepth++; 
	inc	word [ISRDepth]
	mov	sp, bp
	pop	bp
	ret
L_yakc_73:
	push	bp
	mov	bp, sp
	jmp	L_yakc_74
	ALIGN	2
YKExitISR:
	; >>>>> Line:	252
	; >>>>> { 
	jmp	L_yakc_76
L_yakc_77:
	; >>>>> Line:	253
	; >>>>> ISRDepth--; 
	dec	word [ISRDepth]
	; >>>>> Line:	254
	; >>>>> if (ISRDepth == 0) 
	mov	ax, word [ISRDepth]
	test	ax, ax
	jne	L_yakc_78
	; >>>>> Line:	256
	; >>>>> if (hasRun) 
	mov	ax, word [hasRun]
	test	ax, ax
	je	L_yakc_79
	; >>>>> Line:	258
	; >>>>> YKScheduler(1); 
	mov	ax, 1
	push	ax
	call	YKScheduler
	add	sp, 2
L_yakc_79:
L_yakc_78:
	mov	sp, bp
	pop	bp
	ret
L_yakc_76:
	push	bp
	mov	bp, sp
	jmp	L_yakc_77
L_yakc_81:
	DB	"Not enough sems",0
	ALIGN	2
YKSemCreate:
	; >>>>> Line:	263
	; >>>>> YKSEM* YKSemCreate(int initialValue){ 
	jmp	L_yakc_82
L_yakc_83:
	; >>>>> Line:	264
	; >>>>> YKEnterMutex(); 
	call	YKEnterMutex
	; >>>>> Line:	265
	; >>>>> if (YKAvaiSems <= 0){ 
	cmp	word [YKAvaiSems], 0
	jg	L_yakc_84
	; >>>>> Line:	266
	; >>>>> YKExitMutex(); 
	call	YKExitMutex
	; >>>>> Line:	267
	; >>>>> printString("Not enough sems"); 
	mov	ax, L_yakc_81
	push	ax
	call	printString
	add	sp, 2
	; >>>>> Line:	268
	; >>>>> = 0) 
	mov	al, 255
	push	ax
	call	exit
	add	sp, 2
	jmp	L_yakc_85
L_yakc_84:
	; >>>>> Line:	271
	; >>>>> YKAvaiSems--; 
	dec	word [YKAvaiSems]
	; >>>>> Line:	272
	; >>>>> YKSems[YKAvaiSems].value = initialValue; 
	mov	ax, word [YKAvaiSems]
	shl	ax, 1
	shl	ax, 1
	mov	si, ax
	add	si, YKSems
	mov	ax, word [bp+4]
	mov	word [si], ax
	; >>>>> Line:	273
	; >>>>> YKSems[YKAvaiSems].blockedOn = 0; 
	mov	ax, word [YKAvaiSems]
	shl	ax, 1
	shl	ax, 1
	add	ax, YKSems
	mov	si, ax
	add	si, 2
	mov	word [si], 0
L_yakc_85:
	; >>>>> Line:	275
	; >>>>> YKExitMutex(); 
	call	YKExitMutex
	; >>>>> Line:	278
	; >>>>> return (&(YKSems[YKAvaiSems])); 
	mov	ax, word [YKAvaiSems]
	shl	ax, 1
	shl	ax, 1
	add	ax, YKSems
L_yakc_86:
	mov	sp, bp
	pop	bp
	ret
L_yakc_82:
	push	bp
	mov	bp, sp
	jmp	L_yakc_83
	ALIGN	2
YKSemPend:
	; >>>>> Line:	282
	; >>>>> void YKSemPend(YKSEM *semaphore){ 
	jmp	L_yakc_88
L_yakc_89:
	; >>>>> Line:	286
	; >>>>> YKEnterMutex(); 
	call	YKEnterMutex
	; >>>>> Line:	293
	; >>>>> if (semaphore->value > 0){ 
	mov	si, word [bp+4]
	cmp	word [si], 0
	jle	L_yakc_90
	; >>>>> Line:	295
	; >>>>> semaphore->value--; 
	dec	word [si]
	; >>>>> Line:	296
	; >>>>> YKExitMutex(); 
	call	YKExitMutex
	; >>>>> Line:	297
	; >>>>> return; 
	jmp	L_yakc_91
L_yakc_90:
	; >>>>> Line:	299
	; >>>>> semaphore->value--; 
	mov	si, word [bp+4]
	dec	word [si]
	; >>>>> Line:	301
	; >>>>> temp = YKRdyList; 
	mov	ax, word [YKRdyList]
	mov	word [bp-2], ax
	; >>>>> Line:	303
	; >>>>> YKRdyList = temp->next; 
	mov	si, word [bp-2]
	add	si, 12
	mov	ax, word [si]
	mov	word [YKRdyList], ax
	; >>>>> Line:	304
	; >>>>> if (YKRdyList != 0) 
	mov	ax, word [YKRdyList]
	test	ax, ax
	je	L_yakc_92
	; >>>>> Line:	305
	; >>>>>  
	mov	si, word [YKRdyList]
	add	si, 14
	mov	word [si], 0
L_yakc_92:
	; >>>>> Line:	307
	; >>>>> temp->state = 2; 
	mov	si, word [bp-2]
	add	si, 2
	mov	word [si], 2
	; >>>>> Line:	309
	; >>>>> if (semaphore->blockedOn == 0){ 
	mov	si, word [bp+4]
	add	si, 2
	mov	ax, word [si]
	test	ax, ax
	jne	L_yakc_93
	; >>>>> Line:	310
	; >>>>> semaphore->blockedOn = temp; 
	mov	si, word [bp+4]
	add	si, 2
	mov	ax, word [bp-2]
	mov	word [si], ax
	; >>>>> Line:	311
	; >>>>> temp->next = 0; 
	mov	si, word [bp-2]
	add	si, 12
	mov	word [si], 0
	; >>>>> Line:	312
	; >>>>> temp->prev = 0; 
	mov	si, word [bp-2]
	add	si, 14
	mov	word [si], 0
	jmp	L_yakc_94
L_yakc_93:
	; >>>>> Line:	315
	; >>>>> iter = semaphore->blockedOn; 
	mov	si, word [bp+4]
	add	si, 2
	mov	ax, word [si]
	mov	word [bp-6], ax
	; >>>>> Line:	316
	; >>>>> temp2 = 0; 
	mov	word [bp-4], 0
	; >>>>> Line:	317
	; >>>>> while (iter != 0 && iter->priority < temp->priority){ 
	jmp	L_yakc_96
L_yakc_95:
	; >>>>> Line:	318
	; >>>>> temp2 = iter; 
	mov	ax, word [bp-6]
	mov	word [bp-4], ax
	; >>>>> Line:	319
	; >>>>> iter = iter->next; 
	mov	si, word [bp-6]
	add	si, 12
	mov	ax, word [si]
	mov	word [bp-6], ax
L_yakc_96:
	mov	ax, word [bp-6]
	test	ax, ax
	je	L_yakc_98
	mov	si, word [bp-6]
	add	si, 4
	mov	di, word [bp-2]
	add	di, 4
	mov	ax, word [di]
	cmp	ax, word [si]
	jg	L_yakc_95
L_yakc_98:
L_yakc_97:
	; >>>>> Line:	321
	; >>>>> if (iter == 0){ 
	mov	ax, word [bp-6]
	test	ax, ax
	jne	L_yakc_99
	; >>>>> Line:	322
	; >>>>> temp2->next = temp; 
	mov	si, word [bp-4]
	add	si, 12
	mov	ax, word [bp-2]
	mov	word [si], ax
	; >>>>> Line:	323
	; >>>>> temp->prev = temp; 
	mov	si, word [bp-2]
	add	si, 14
	mov	ax, word [bp-2]
	mov	word [si], ax
	; >>>>> Line:	324
	; >>>>> temp->next = 0; 
	mov	si, word [bp-2]
	add	si, 12
	mov	word [si], 0
	jmp	L_yakc_100
L_yakc_99:
	; >>>>> Line:	327
	; >>>>> t; 
	mov	si, word [bp-2]
	add	si, 12
	mov	ax, word [bp-6]
	mov	word [si], ax
	; >>>>> Line:	328
	; >>>>> temp->prev = temp2; 
	mov	si, word [bp-2]
	add	si, 14
	mov	ax, word [bp-4]
	mov	word [si], ax
	; >>>>> Line:	329
	; >>>>> iter->prev = temp; 
	mov	si, word [bp-6]
	add	si, 14
	mov	ax, word [bp-2]
	mov	word [si], ax
	; >>>>> Line:	330
	; >>>>> if (temp2 == 0) 
	mov	ax, word [bp-4]
	test	ax, ax
	jne	L_yakc_101
	; >>>>> Line:	331
	; >>>>> semaphore->blockedOn = temp; 
	mov	si, word [bp+4]
	add	si, 2
	mov	ax, word [bp-2]
	mov	word [si], ax
	jmp	L_yakc_102
L_yakc_101:
	; >>>>> Line:	333
	; >>>>> temp2->next = temp; 
	mov	si, word [bp-4]
	add	si, 12
	mov	ax, word [bp-2]
	mov	word [si], ax
L_yakc_102:
L_yakc_100:
L_yakc_94:
	; >>>>> Line:	338
	; >>>>> YKScheduler(0); 
	xor	ax, ax
	push	ax
	call	YKScheduler
	add	sp, 2
	; >>>>> Line:	340
	; >>>>> YKExitMutex(); 
	call	YKExitMutex
L_yakc_91:
	mov	sp, bp
	pop	bp
	ret
L_yakc_88:
	push	bp
	mov	bp, sp
	sub	sp, 8
	jmp	L_yakc_89
	ALIGN	2
YKSemPost:
	; >>>>> Line:	343
	; >>>>> void YKSemPost(YKSEM *semaphore){ 
	jmp	L_yakc_104
L_yakc_105:
	; >>>>> Line:	349
	; >>>>> YKEnterMutex(); 
	call	YKEnterMutex
	; >>>>> Line:	350
	; >>>>> if (semaphore->value++ >= 0){ 
	mov	si, word [bp+4]
	mov	ax, word [si]
	inc	word [si]
	test	ax, ax
	jl	L_yakc_106
	; >>>>> Line:	351
	; >>>>> YKExitMutex(); 
	call	YKExitMutex
	; >>>>> Line:	352
	; >>>>> return; 
	jmp	L_yakc_107
L_yakc_106:
	; >>>>> Line:	355
	; >>>>> temp = semaphore->blockedOn; 
	mov	si, word [bp+4]
	add	si, 2
	mov	ax, word [si]
	mov	word [bp-2], ax
	; >>>>> Line:	356
	; >>>>> semaphore->blockedOn = temp->next; 
	mov	si, word [bp-2]
	add	si, 12
	mov	di, word [bp+4]
	add	di, 2
	mov	ax, word [si]
	mov	word [di], ax
	; >>>>> Line:	357
	; >>>>>  
	mov	si, word [bp+4]
	add	si, 2
	mov	ax, word [si]
	test	ax, ax
	je	L_yakc_108
	; >>>>> Line:	358
	; >>>>> semaphore->blockedOn->prev = 0; 
	mov	si, word [bp+4]
	add	si, 2
	mov	si, word [si]
	add	si, 14
	mov	word [si], 0
L_yakc_108:
	; >>>>> Line:	360
	; >>>>> temp->state = 1; 
	mov	si, word [bp-2]
	add	si, 2
	mov	word [si], 1
	; >>>>> Line:	362
	; >>>>> temp2 = YKRdyList; 
	mov	ax, word [YKRdyList]
	mov	word [bp-4], ax
	; >>>>> Line:	363
	; >>>>> while (temp2->priority < temp->priority){ 
	jmp	L_yakc_110
L_yakc_109:
	; >>>>> Line:	364
	; >>>>> temp2 = temp2->next; 
	mov	si, word [bp-4]
	add	si, 12
	mov	ax, word [si]
	mov	word [bp-4], ax
L_yakc_110:
	mov	si, word [bp-4]
	add	si, 4
	mov	di, word [bp-2]
	add	di, 4
	mov	ax, word [di]
	cmp	ax, word [si]
	jg	L_yakc_109
L_yakc_111:
	; >>>>> Line:	366
	; >>>>> if (temp2->prev == 0){ 
	mov	si, word [bp-4]
	add	si, 14
	mov	ax, word [si]
	test	ax, ax
	jne	L_yakc_112
	; >>>>> Line:	367
	; >>>>> YKRdyList = temp; 
	mov	ax, word [bp-2]
	mov	word [YKRdyList], ax
	jmp	L_yakc_113
L_yakc_112:
	; >>>>> Line:	370
	; >>>>> temp2->prev->next = temp; 
	mov	si, word [bp-4]
	add	si, 14
	mov	si, word [si]
	add	si, 12
	mov	ax, word [bp-2]
	mov	word [si], ax
L_yakc_113:
	; >>>>> Line:	372
	; >>>>> temp->prev = temp2->prev; 
	mov	si, word [bp-4]
	add	si, 14
	mov	di, word [bp-2]
	add	di, 14
	mov	ax, word [si]
	mov	word [di], ax
	; >>>>> Line:	373
	; >>>>> temp->next = temp2; 
	mov	si, word [bp-2]
	add	si, 12
	mov	ax, word [bp-4]
	mov	word [si], ax
	; >>>>> Line:	374
	; >>>>> temp2->prev = temp; 
	mov	si, word [bp-4]
	add	si, 14
	mov	ax, word [bp-2]
	mov	word [si], ax
	; >>>>> Line:	376
	; >>>>> if (ISRDepth == 0) 
	mov	ax, word [ISRDepth]
	test	ax, ax
	jne	L_yakc_114
	; >>>>> Line:	379
	; >>>>> YKScheduler(0); 
	xor	ax, ax
	push	ax
	call	YKScheduler
	add	sp, 2
L_yakc_114:
	; >>>>> Line:	381
	; >>>>> YKExitMutex(); 
	call	YKExitMutex
L_yakc_107:
	mov	sp, bp
	pop	bp
	ret
L_yakc_104:
	push	bp
	mov	bp, sp
	sub	sp, 4
	jmp	L_yakc_105
	ALIGN	2
YKIdleCount:
	TIMES	2 db 0
YKTickNum:
	TIMES	2 db 0
ISRDepth:
	TIMES	2 db 0
YKSave:
	TIMES	2 db 0
YKRestore:
	TIMES	2 db 0
YKSems:
	TIMES	16 db 0
YKAvaiSems:
	TIMES	2 db 0
YKRdyList:
	TIMES	2 db 0
YKAvailTCBList:
	TIMES	2 db 0
YKSuspList:
	TIMES	2 db 0
YKRunningTask:
	TIMES	2 db 0
YKTCBArray:
	TIMES	112 db 0
idleStk:
	TIMES	4096 db 0
