; prog_portD.s
; read portD bit 0 (push button) and output the value to portD bit 3 (buzzer)

; GPIO_PORTD address

GPIO_PORTD_DATA_R  	EQU 0x400073FC
GPIO_PORTD_DIR_R   	EQU 0x40007400
GPIO_PORTD_AFSEL_R 	EQU 0x40007420
GPIO_PORTD_PUR_R   	EQU 0x40007510
GPIO_PORTD_DEN_R   	EQU 0x4000751C
GPIO_PORTD_AMSEL_R 	EQU 0x40007528
GPIO_PORTD_PCTL_R  	EQU 0x4000752C
PD					EQU 0x40007024		; Enable Port D bit 0 and 3

SYSCTL_RCGCGPIO_R  	EQU 0x400FE608		; GPIO run mode clock gating control

        AREA    |.text|, CODE, READONLY, ALIGN=2
        THUMB
        EXPORT  Start

Start

; initialize Port D
; enable digital I/O, ensure alt. functions off.

; activate clock for Port D
		LDR R1, =SYSCTL_RCGCGPIO_R 		; R1 = address of SYSCTL_RCGCGPIO_R
		LDR R0, [R1]                	; 
		ORR R0, R0, #0x08          		; set bit 3 to turn on clock for GPIOD
		STR R0, [R1]                  
		NOP								; allow time for clock to finish
		NOP
		NOP   
		
; no need to unlock Port D bits
; disable analog mode
		LDR R1, =GPIO_PORTD_AMSEL_R     
		LDR R0, [R1]                    
		BIC R0, R0, #0x09    			; Clear bit 0 and 3 to disable analog function
		STR R0, [R1]       
	
; configure as GPIO
		LDR R1, =GPIO_PORTD_PCTL_R      
		LDR R0, [R1]  
		BIC R0, R0,#0x0000000F			; clear PortD bit 0
		BIC R0, R0,#0X0000F000			; clear PortD bit 3
		STR R0, [R1]     
    
; set direction register
		LDR R1, =GPIO_PORTD_DIR_R       
		LDR R0, [R1]       
		BIC R0, R0, #0x01				; set PortD bit 0 input
		ORR R0, R0, #0x08     			; set PortD bit 3 output (0: input, 1: output)
		STR R0, [R1]    
	
; disable alternate function
		LDR R1, =GPIO_PORTD_AFSEL_R     
		LDR R0, [R1]                     
		BIC R0, R0, #0x09      			; disable alternate function on bit 0 and 3 
		STR R0, [R1] 

; pull-up resistors on switch pins
		LDR R1, =GPIO_PORTD_PUR_R      	; R1 = address of GPIO_PORTD_PUR_R
		LDR R0, [R1]                   	; 
		ORR R0, R0, #0x01              	; enable pull-up on PortD bit 0
		STR R0, [R1]                   

; enable digital port
		LDR R1, =GPIO_PORTD_DEN_R   	
		LDR R0, [R1]                    
		ORR R0, R0, #0x09               ; enable digital I/O on bit 0 and 3
		STR R0, [R1]    
	
		LDR R1, =PD

Again1	
		MOV R0, #0						
		STR R0, [R1]					; "off" buzzer
		LDR R2, [R1]					; check switch, PortD bit 0 status
		TST R2, #1 						; 
		BNE Again1						; perform a bitwise AND operation and test again if switch is not pressed
		MOV R0, #0x08					; when switch is pressed, set PortD bit 3 "high" to turn on buzzer
		STR R0, [R1]					; 
Again2
		LDR R2, [R1]					; check switch 
		TST R2, #1 						; perform a bitwise AND operation and test again if switch is not released
		BEQ Again2						;
		B Again1						; 
	
		ALIGN                			; make sure the end of this section is aligned
		END                  			; end of file	

			
	
