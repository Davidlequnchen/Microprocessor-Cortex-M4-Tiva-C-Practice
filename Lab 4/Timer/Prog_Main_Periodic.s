; Prog_Main_Periodic.s
; 
; Main Program: Generate PWM using Timer Interrupt
; 

; PLL_Init and Timer_Init are symbol names defined in a separately assembled source files

			IMPORT   PLL_Init
			IMPORT   Timer_Init


TIMER0_ICR_R		EQU 0x40030024			; GPTM Interrupt Clear
TIMER_ICR_TATOCINT 	EQU 0x00000001   		; GPTM TimerA Time-Out Raw Interrupt
											
GPIO_PORTF2        	EQU 0x40025010
GPIO_PORTF_DIR_R   	EQU 0x40025400
GPIO_PORTF_AFSEL_R 	EQU 0x40025420
GPIO_PORTF_DEN_R   	EQU 0x4002551C
GPIO_PORTF_AMSEL_R 	EQU 0x40025528
GPIO_PORTF_PCTL_R  	EQU 0x4002552C
SYSCTL_RCGCGPIO_R  	EQU 0x400FE608

			AREA    |.text|, CODE, READONLY, ALIGN=2
			THUMB
			EXPORT  Timer0A_Handler
			EXPORT  Start

;
;
; Timer0A Interrupt Handler
;
Timer0A_Handler								; execute every 0.25 second
     
; toggle PF2 LED
			LDR R1, =GPIO_PORTF2            ; 
			LDR R0, [R1]                    ; read PF2
			EOR R0, R0, #0x04               ; R0 = R0^0x04 (toggle PF2)
			STR R0, [R1]                    ; store PF2
	
			LDR R1, =TIMER0_ICR_R           ; 
			LDR R0, =0x01     				; write "1" to clear interrupt before returning to main program 
			STR R0, [R1]                    ; 
   
			BX  LR                          ; return from interrupt

Start
			BL  PLL_Init                    ; call subroutine (in Prog_PLL.s) to generate system clock of 40MHz
											; period = 1/40MHz = 0.025 microsecond)
											
; Initialise Port F 
; configure PF2 as GPIO, digital output (disable alternate and analog functions)

; activate clock for Port F
			LDR R1, =SYSCTL_RCGCGPIO_R      ; 
			LDR R0, [R1]                   
			ORR R0, R0, #0x20				; turn on clock for GPIOF
			STR R0, [R1]                   
			NOP
			NOP                             ; allow time to finish activating
    
; set direction register
			LDR R1, =GPIO_PORTF_DIR_R      
			LDR R0, [R1]                    
			ORR R0, R0, #0x04               ; set PortF bit 2 (PF2) output
			STR R0, [R1]                    
    
; regular port function
			LDR R1, =GPIO_PORTF_AFSEL_R     
			LDR R0, [R1]                    
			BIC R0, R0, #0x04               ; R0 = R0&~0x04 (disable alternate function on PF2)
			STR R0, [R1]                    
    
; enable digital port
			LDR R1, =GPIO_PORTF_DEN_R       
			LDR R0, [R1]                    
			ORR R0, R0, #0x04               ; R0 = R0|0x04 (enable digital I/O on PF2)
			STR R0, [R1]                   
    
; configure as GPIO
			LDR R1, =GPIO_PORTF_PCTL_R     
			LDR R0, [R1]                    
			BIC R0, R0, #0x00000F00         ; R0 = R0&~0x00000F00 (clear port control field for PF2)
			ADD R0, R0, #0x00000000         ; R0 = R0+0x00000000 (configure PF2 as GPIO)
			STR R0, [R1]                   
   
; disable analog functionality
			LDR R1, =GPIO_PORTF_AMSEL_R     
			MOV R0, #0                      ; disable analog function on PortF
			STR R0, [R1]     
	
; 
; enable Timer0A interrupt every 0.25 second 
;  
			LDR R0, =10000000               ; initialize Timer0A for 0.25 second interrupts (0.025 microsecond * 10000000 = 0.25 sec)
			BL  Timer_Init                	; call subroutine (in Prog_Timer_Init.s) for Timer module 0_Timer A set up
			CPSIE I                         ; enable IRQ interrupt

loop
			WFI                             ; wait for interrupt
			B   loop                        ; 

			ALIGN                           ; make sure the end of this section is aligned
			END                             ; end of file
