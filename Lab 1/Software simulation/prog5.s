		EXPORT Start
		AREA prog5, CODE, READONLY
		ENTRY
Start
		LDR	r0, =0xE000ED88		; read=mpdify write
		LDR	r1, [r0]
		ORR	r1, r1, #(0xF << 20)	; Enable CP10, CP11
		STR	r1, [r0]
		LDR	r3, =0x3F800000		; single =precision 1.0
		VMOV.F	s3, r3			; transfer from ARM to FPU
		VLDR.F	s4, =6.0221415e23	; Avogadro's constant
		VMOV.F	r4, s4			; transfer from FPU to ARM
		END