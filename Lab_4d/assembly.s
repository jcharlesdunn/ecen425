
YKEnterMutex:
	cli			;Disable interrupts
	ret

YKExitMutex:
	sti			;Enable interrupts
	ret

save:
				;Save the context of the current task. 9 total
	push	ax
	push	bx
	push	cx
	push	dx
	push	es
	push	ds
	push 	si
	push	di
	push 	bp
				;Return address must be placed on top of the stack
				;Move 9 words up the stack
	mov		bp, sp 			;Move stack pointer
	push	word[bp+18]		;Go to the top of the stack
	mov		[bp+18], cx		;Keep track of cx

	mov cx, [ISRDepth]
	cmp cx, 0				;Compare the ISRDepth with 0. This will perform (ISRDepth-0)
	jg return				;if (ISRDepth-0) is greater than 0, we need to return.
							;If the ISRDepth is 0, it will skip the return

	mov bx, [YKRunningTask]	;Grab the currently running task
	mov bp, sp				
	add	bp, 2
	mov [bx], bp

return:
	ret

YKDispatcher:
	
	push bp 	
	mov bp, sp	
	cmp	byte[bp+4], 1		; compare the argument with 1 
	pop bp
	je	dispatcherRestore 	;if the argument is 1, restore old saved context
	push cs					
	pushf					;Push flag register onto stack
	call save				;Save the new context
	mov	bp, sp				;Move stack pointer to bp
	mov	bx, [bp+20]			;Store the task
	mov	ax, [bp+24]			;Store the interrupt flag
	mov	[bp+20], ax			;Set the task	
	or bx, 0x0200			;or flag with 0x0200
	mov	[bp+24], bx			;Move flag to flag position

dispatcherRestore:			;If not saved, restore the old context
	mov bx, [YKRdyList]		;store the new task
	mov sp, [bx]			;Store saved bp
	mov	[YKRunningTask], bx	;Grab the currently running task. to restore content
	call restore			;Restore the content of the running task
	iret					;iret to restore context not restored already

restore:					;Restore context
	
	mov	bp, sp
	mov cx, [bp+20]
	pop	word[bp+20]
	pop		bp
	pop		di
	pop		si
	pop		ds
	pop		es
	pop		dx
	pop		cx
	pop		bx
	pop		ax
	ret

