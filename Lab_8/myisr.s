
;.globl resetInterrupt

;ISR 
  
Reset:

sti							;set the interrupt flag. Enable interrupts
call resetInterrupt			;Call the interrupt handler
cli							;clear the interrupt flag. Disable interrupts
call signalEOI				;signal EOI to the PIC
iret						;return


Tick:
    						;1. Save the context 
call save

call YKEnterISR			
    						
call YKExitMutex			;2.set the interrupt flag. Enable interrupts
    						
call YKTickHandler			;3. Run interrupt handler

call tickInterrupt			;3. Run interupt handler 
    						
call YKEnterMutex			;4. clear the interrupt flag. Disable interrupts
	   						 
call signalEOI				;5. Send the EOI command to the PIC,

call YKExitISR				
    						
call restore				;6. Restore context
    						 
iret


Keyboard:
    						;1. Save the context 
call save
    						;2. Enable interrupts
sti							;set the interrupt flag. Enable interrupts
    						;3. Run the interrupt handler
call keyboardInterrupt
    						;4. Disable interrupts.
cli							;clear the interrupt flag. Disable interrupts
	   						;5. Send the EOI command to the PIC, 
call signalEOI
    						;6. Restore the context
call restore
    						;7. Execute the iret instruction. 
iret

gameOver:
	call	save
	call	YKEnterISR

	sti				; enable interrupts
	call	setGameOver
	cli 			; disable interrupts

	mov	al, 0x20	; Load nonspecific EOI value (0x20) into register al
	out	0x20, al	; Write EOI to PIC (port 0x20)
	call	YKExitISR
	call	restore
	iret

newPiece:
	call	save
	call	YKEnterISR

	sti				; enable interrupts
	call	newPieceInterrupt
	cli 			; disable interrupts

	mov	al, 0x20	; Load nonspecific EOI value (0x20) into register al
	out	0x20, al	; Write EOI to PIC (port 0x20)
	call	YKExitISR
	call	restore
	iret

received:
	call	save
	call	YKEnterISR

	sti				; enable interrupts
	call	recievedInterrupt
	cli 			; disable interrupts

	mov	al, 0x20	; Load nonspecific EOI value (0x20) into register al
	out	0x20, al	; Write EOI to PIC (port 0x20)
	call	YKExitISR
	call	restore
	iret

touchdown:
	push	ax
	mov	al, 0x20	; Load nonspecific EOI value (0x20) into register al
	out	0x20, al
	pop	ax
	iret

lineClear:
	push	ax
	mov	al, 0x20	; Load nonspecific EOI value (0x20) into register al
	out	0x20, al
	pop	ax
	iret
