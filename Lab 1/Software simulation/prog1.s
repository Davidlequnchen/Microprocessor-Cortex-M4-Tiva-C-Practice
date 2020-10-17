		EXPORT Start
		AREA	prog1, CODE, READONLY
Start		
		ENTRY
		
		MOV	r0, #0x11	; load initial value
		LSL	r1, r0, #1	; shift 1 bit left
		LSL r2, r1, #1	; shift 1 bit left
		LSL r3, r2, #2  ; shitft 2 bits left 
	    MOV r4, r1      ; r0 = r1
		MVN r5, r2      ; move (negated), r5 = NOT (r2) --> r5 will be FFFFFFBB
		MOV r7, r5, LSL #2 ; r7 = r5<<2 = r5*4    --> r5 is 1111 1111 1111 1111 1111 1111 1011 1011 --> r7 will be  1111,1110,1110,1100 (FFFFFEEC)
		ROR r6, r5, #1  ; rotate right, ((unsigned) r5>>1) | r5 << (32-1)) , becomes: 1111(F) FFFFF 1101(D) 1101(D)
		RRX r7, r5      ; rotate right extended, perform 33 bits rotate, the 33rd bits is the C (carry bits), which is 0 here
		BL arithematic  ; branch with link, means it will return back to this position
		;BL carry_example 
		LDR r0, [r1]
		
		
		
arithematic
        ADD r0, r1, r2  ; r0 = r1+r2
		ADC r0, r1, r2  ; ADD with carry, r0=r1+r2+C
		SBC r0, r1, r2  ; subtract with carry, r0 = r1-r2+C-1 (00000022 - 00000044) ==>0010 - 0100
		MLA r0, r1, r2, r3; multiply and accumulate , r0 = r1xr2+r3
		RSB r0, r1, r2  ; reverse subtract, r0 = r2-r1
		; RSC r0, r3, r2  ; reverse subtract with carry, r0 = r2-r3+C-1
		BX lr     ; return from the subroutine
        
		
stop	B	stop		; stop program

		END