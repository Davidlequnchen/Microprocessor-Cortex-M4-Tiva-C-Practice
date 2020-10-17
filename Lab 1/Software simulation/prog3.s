		EXPORT Start
		AREA prog3, CODE, READONLY
Start
		ENTRY
		
		LDR r0, =0xF631024C	; load some data
		LDR r1, =0x17539ABD	; load some data
		EOR r0, r0, r1		; r0 XOR r1, store r0
		EOR r1, r0, r1		; r0 XOR r1, store r1
		EOR r0, r0, r1		; r0 XOR r1, store r0
stop		B	stop		; stop program
		END