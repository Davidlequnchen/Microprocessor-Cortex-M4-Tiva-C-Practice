		EXPORT Start
		AREA prog5, CODE, READONLY
		ENTRY
Start
		
		;data1 DCD (0x8321<<4),OR,2	
		LDR r0, =0x00083212
		
		MOV r0, #((1<<14):OR:(1:SHL:12))
		MOV r1, #0x5000
		CMP r0, r1
		
		
		END