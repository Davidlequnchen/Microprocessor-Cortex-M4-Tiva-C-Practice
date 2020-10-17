; wr_portB.s
; output the value to PortB bit 0 - 3 (Pins PB0 - PB3 are connected to LEDs)

; GPIO_PORTB address

GPIO_PORTB_DATA_R  	EQU 0x400053FC
GPIO_PORTB_DIR_R   	EQU 0x40005400
GPIO_PORTB_AFSEL_R 	EQU 0x40005420		
GPIO_PORTB_PUR_R   	EQU 0x40005510
GPIO_PORTB_DEN_R   	EQU 0x4000551C
GPIO_PORTB_AMSEL_R 	EQU 0x40005528
GPIO_PORTB_PCTL_R  	EQU 0x4000552C
PB_0123				EQU 0x4000503C		; Port B bit 0-3
	
SYSCTL_RCGCGPIO_R  	EQU 0x400FE608		; GPIO run mode clock gating control

        AREA    |.text|, CODE, READONLY, ALIGN=2
        THUMB
        EXPORT  Start

Start

; initialize Port B, all bits
; enable digital I/O, ensure alt. functions off.

; activate clock for Port B 
		LDR R1, =SYSCTL_RCGCGPIO_R 		; R1 = address of SYSCTL_RCGCGPIO_R
		LDR R0, [R1]                
		ORR R0, R0, #0x02           	; set bit 1 to turn on clock for GPIOB
		STR R0, [R1]                  
		NOP								; allow time for clock to finish
		NOP
		NOP   
	
; no need to unlock Port B bits
; disable analog mode
		LDR R1, =GPIO_PORTB_AMSEL_R     
		LDR R0, [R1]                    
		BIC R0, R0, #0x0F    			; Clear bit 0-3, disable analog function
		STR R0, [R1]       
	
; configure as GPIO
		LDR R1, =GPIO_PORTB_PCTL_R      
		LDR R0, [R1]  
		BIC R0, R0,#0x000000FF			; bit clear PortA bit 0 & 1
		BIC R0, R0,#0X0000FF00			; bit clear PortA bit 2 & 3 
		STR R0, [R1]     
    
; set direction register
		LDR R1, =GPIO_PORTB_DIR_R       
		LDR R0, [R1]                    
		ORR R0, R0, #0x0F     			; set PortB bit 0-3 as output (0: input, 1: output)
		STR R0, [R1]    
	
; disable alternate function
		LDR R1, =GPIO_PORTB_AFSEL_R     
		LDR R0, [R1]                     
		BIC R0, R0, #0x0F    			; disable alternate function on PortB bit 0-3
		STR R0, [R1] 

; enable digital port
		LDR R1, =GPIO_PORTB_DEN_R   	
		LDR R0, [R1]                    
		ORR R0, #0x0F               	; enable PortB digital I/O      
		STR R0, [R1]    
    	    
		LDR R1, =PB_0123
	
		LDR R0, =0x0F					; set PortB bit 0-3 -> turn on 4 Leds
		STR R0, [R1]
		BL Delay	
		LDR R2,=0x0F					
Loop	
		EOR R0, R2						; R0 = Exclusive OR of R0 with R2 
		STR R0, [R1]					; clear PortB bit 0-3 -> turn off 4 Leds
		BL Delay
		B Loop

Delay
		MOV R7,#0xFFFFFF
				
Countdown
		SUBS R7, #1						; subtract and sets the flags based on the result
		BNE Countdown		 
	
		BX LR   						; return

		ALIGN                			; make sure the end of this section is aligned
		END                  			; end of file




