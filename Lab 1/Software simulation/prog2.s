		EXPORT Start
		AREA prog2, CODE, READONLY
Start
		ENTRY
		
		MOV	r6, #10		; load n into r6
		MOV	r7, #1		; if n=0, n!=1
loop		CMP	r6, #0
		MULGT 	r7, r6, r7
		SUBGT	r6, r6, #1
		BGT	loop
stop		B	stop		; stop program
		END
