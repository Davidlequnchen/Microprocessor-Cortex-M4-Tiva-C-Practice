		EXPORT Start
		AREA	prog1, CODE, READONLY
Start		
		ENTRY
		
		MOV	r0, #0x11	; load initial value
		LSL	r1, r0, #1	; shift 1 bit
		LSL r2, r1, #1	; shift 1 bit
	
stop	B	stop		; stop program

		END