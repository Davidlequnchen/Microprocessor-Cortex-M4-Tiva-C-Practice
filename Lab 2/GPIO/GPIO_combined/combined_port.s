; rd_portA.s
; reads PortA Bit 4-7 (Pins PA4 - PA7 are connected to dip switch) 

; GPIO_PORTA address

GPIO_PORTA_DATA_R  	EQU 0x400043FC
GPIO_PORTA_DIR_R   	EQU 0x40004400
GPIO_PORTA_AFSEL_R 	EQU 0x40004420
GPIO_PORTA_PUR_R   	EQU 0x40004510
GPIO_PORTA_DEN_R   	EQU 0x4000451C
GPIO_PORTA_AMSEL_R 	EQU 0x40004528
GPIO_PORTA_PCTL_R  	EQU 0x4000452C
PA_4567				EQU 0x400043C0		; PortA bit 4-7
	
	
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

; initialize Port A -----------------------------------------------------------
; enable digital I/O, ensure alt. functions off.

; activate clock for PortA and portB
		LDR R1, =SYSCTL_RCGCGPIO_R 		; R1 = address of SYSCTL_RCGCGPIO_R 
		LDR R0, [R1]                	; 
		ORR R0, R0, #0x03           	; turn on GPIOA clock and GPIOB clock
		STR R0, [R1]                  
		NOP								; allow time for clock to finish
		NOP
		NOP   
		
; no need to unlock Port A bits

; disable analog mode
		LDR R1, =GPIO_PORTA_AMSEL_R     
		LDR R0, [R1]                    
		BIC R0, R0, #0xF0    			; disable analog mode on PortA bit 4-7
		STR R0, [R1]       
	
;configure as GPIO
		LDR R1, =GPIO_PORTA_PCTL_R      
		LDR R0, [R1]  
		BIC R0, R0,#0x00FF0000			; clear PortA bit 4 & 5
		BIC R0, R0,#0XFF000000			; clear PortA bit 6 & 7 
		STR R0, [R1]     
    
;set direction register
		LDR R1, =GPIO_PORTA_DIR_R       
		LDR R0, [R1]                    
		BIC R0, R0, #0xF0     			; set PortA bit 4-7 input (0: input, 1: output)
		STR R0, [R1]    
	
; disable alternate function
		LDR R1, =GPIO_PORTA_AFSEL_R     
		LDR R0, [R1]                     
		BIC R0, R0, #0xF0      			; disable alternate function on PortA bit 4-7
		STR R0, [R1] 

; pull-up resistors on switch pins
		LDR R1, =GPIO_PORTA_PUR_R      	; 
		LDR R0, [R1]                   	; 
		ORR R0, R0, #0xF0              	; enable pull-up on PortA bit 4-7
		STR R0, [R1]                   

; enable digital port
		LDR R1, =GPIO_PORTA_DEN_R   	
		LDR R0, [R1]                    
		ORR R0, R0, #0xF0               ; enable digital I/O on PortA bit 4-7
		STR R0, [R1]    
    	    

; initialize Port B, all bits  ------------------------------------------------------------------------
; enable digital I/O, ensure alt. functions off.
	
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
    	    
			
			
		
        LDR R1, =PA_4567
		LDR R3, =PB_0123






Loop
		LDR R0, [R1]					; R0 = dip switch status
		LSR R0, #4
		STR R0,[R3]						; store data directly to R3, which is the PortB (LED)

		B Loop

		ALIGN                			; make sure the end of this section is aligned
		END                  			; end of file

