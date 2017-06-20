
;.globl resetInterrupt

;ISR 
  
Reset:

sti							;set the interrupt flag. Enable interrupts
call resetInterrupt			;Call the interrupt handler
cli							;clear the interrupt flag. Disable interrupts
call signalEOI					;signal EOI to the PIC
iret						;return


Tick:
    					;1. Save the context 
call save

call YKEnterISR			;Call YKEnterISR
    					;2. Enable interrupts
call YKExitMutex		;sti						;set the interrupt flag. Enable interrupts
    					;3. Run the interrupt handler
call tickInterrupt		;OLD CODE
call YKTickHandler
    					;4. Disable interrupts.
call YKEnterMutex		;cli				;clear the interrupt flag. Disable interrupts
	   					;5. Send the EOI command to the PIC, 
call signalEOI

call YKExitISR			;Call YKExitISR
    					;6. Restore the context

call restore
    					;7. Execute the iret instruction. 
iret


Keyboard:
    					;1. Save the context 
call save
    					;2. Enable interrupts
sti				;set the interrupt flag. Enable interrupts
    					;3. Run the interrupt handler
call keyboardInterrupt
    					;4. Disable interrupts.
cli				;clear the interrupt flag. Disable interrupts
	   					;5. Send the EOI command to the PIC, 
call signalEOI
    					;6. Restore the context
call restore
    					;7. Execute the iret instruction. 
iret

