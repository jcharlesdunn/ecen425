;	myisr.s John Dunn Lab3
	
	CPU 8086
	ALIGN 2

;	void isrReset(void)
isrReset:

	call resetHandler
	
isrTick:

	push ax
	push bx 
	push cx
	push dx
	push si
	push di
	push bp
	push es
	push ds
	
	sti
	call tickHandler	
	cli
	call signalEOI

	pop ds
	pop es
	pop bp
	pop di
	pop si
	pop dx
	pop cx
	pop bx
	pop ax
	iret

isrKeyboard:
	push ax
	push bx 
	push cx
	push dx
	push si
	push di
	push bp
	push es
	push ds

	sti
	call keyboardHandler
	cli
	call signalEOI
	

	pop ds
	pop es
	pop bp
	pop di
	pop si
	pop dx
	pop cx
	pop bx
	pop ax
	iret
