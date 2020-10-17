		EXPORT Start
		AREA	prog1, CODE, READONLY
Start		
		ENTRY
		
		MOV	r6, #10		; load n into r6
		MOV	r7, #1		; if n=0, n!=1
		
		a DCD (0x8321:SHL:4):OR:2
		MOV r0, a
		
		
		
		
stop	B	stop		; stop program

		END