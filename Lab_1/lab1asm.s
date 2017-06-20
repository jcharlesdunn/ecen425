; Modify AsmFunction to perform the calculation gvar+(a*(b+c))/(d-e).
; Keep in mind the C declaration:
; int AsmFunction(int a, char b, char c, int d, int e);

	CPU	8086
	align	2

AsmFunction:
	push    bp                          	; (1) save bp
	mov     bp, sp                      	; (2) set bp for referencing stack
	
											; (3) function definition
	push bx									; push bx onto the stack
	push dx									; push dx onto the stack
	
	mov al, byte [bp+6]						; move b into all
	add al, byte [bp+8]						; sum of b and c stored in bx
	cbw

	mov bx, word [bp+4]						; move a into bx
	imul bx									; multiply stored sum by a, stored in ax

	mov bx, word [bp+10]					; move d into bx
	sub bx, word [bp+12]					; difference of d-e stored in bx

	idiv bx									; quotient stored in ax

	add	ax, [gvar]							; sum of global variable with rest of stuff

	pop dx									; pop dx off the stack	
	pop bx									; pop bx off the stack


	mov     ax, ax 							; (4) set return value
	mov     sp, bp                       	; (5) free space used by local variables
	pop     bp                           	; (6) restore bp
	ret

