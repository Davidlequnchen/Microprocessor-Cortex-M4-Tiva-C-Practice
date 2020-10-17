		EXPORT Start
		AREA prog4, CODE, READONLY
Start	
		ENTRY
	
		LDR	r0, =0xE000ED88		; read-mpdify-write
		LDR	r1, [r0]
		ORR	r1, r1, #(0xF << 20)	; Enable CP10, CP11
		STR	r1, [r0]
		VMOV.F	s0, #0x3F800000		; single =precision 1.0
		VMOV.F	s1, s0
		VADD.F	s2, s1, s0		;1.0 + 1.0 = ??

		END
			