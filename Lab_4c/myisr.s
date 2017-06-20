	CPU	8086
	align	2

isrReset:
		call ResetHandler

isrKey:

        call save
		call YKEnterISR
		sti
		call KeyHandler
		cli
		call signalEOI
		call YKExitISR
		
		call restore
        iret

isrTick:

        call save
		call YKEnterISR
		sti
		call YKTickHandler
		cli
		call signalEOI
		call YKExitISR
		
		call restore
        iret




