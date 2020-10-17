; Prog_Timer_Init.s
; 
; Configure Timer module 0_Timer A in periodic mode 


SYSCTL_RCGCTIMER_R   EQU 0x400FE604		; RCGCTIMER

TIMER0_CTL_R         EQU 0x4003000C		; GPTM Control register 
TIMER0_CFG_R         EQU 0x40030000		; GPTM Configuration register 
TIMER0_TAMR_R        EQU 0x40030004		; GPTM Timer A Mode register
TIMER0_TAILR_R       EQU 0x40030028		; Timer A Interval load register

NVIC_EN0_R           EQU 0xE000E100  	; NVIC register: IRQ 0 to 31 Set Enable 
NVIC_PRI4_R          EQU 0xE000E410  	; NVIC register: IRQ 16 to 19 Priority Register

TIMER0_ICR_R         EQU 0x40030024		; GPTM Interrupt Clear
TIMER0_IMR_R         EQU 0x40030018		; GPTM Interrupt Mask
 
                                

			AREA    |.text|, CODE, READONLY, ALIGN=2
			THUMB
			EXPORT   Timer_Init

; ***************** Timer_Init ****************
; Activate Timer A interrupts to run user task periodically

Timer_Init									; subroutine for Timer setup
;
; activate clock for Timer module 0
			LDR R1, =SYSCTL_RCGCTIMER_R     
			LDR R2, [R1]                    
			ORR R2, R2, #0x00000001       
			STR R2, [R1]                  
			NOP						; allow time for clock to finish
			NOP  
			NOP                           
    
; disable Timer A 
			LDR R1, =TIMER0_CTL_R           
			LDR R2, [R1]                    ; 
			BIC R2, R2, #00000001    		; disable Timer A 
			STR R2, [R1]                    
    
; configure 16/32-bit Timer 
			LDR R1, =TIMER0_CFG_R           
			LDR R2, =0x00000000      		; select 32-bit Timer configuration    
			STR R2, [R1]                    
  
; load value into Timer A
			LDR R1, =TIMER0_TAILR_R     	;
			SUB R0, R0, #1              	; R0 = R0 - 1, 
			STR R0, [R1]                   	; R0 initially assigned value of 10000000 in main program, Prog_Main_Periodic.s
	   
; clear Timer A timeout raw interrupt
			LDR R1, =TIMER0_ICR_R           
			LDR R2, =0x01					; clear TATORIS bit in the GPTMRIS register 							
			STR R2, [R1]     				; and TATOMIS bit int the GPTMMIS register               
   
; Arm controller-level interrupts
			LDR R1, =TIMER0_IMR_R           	
			LDR R2, =0x01       			; enable Timer A timer-out interrup mask
			STR R2, [R1]                    
		
; set NVIC interrupt 19 to priority 2
			LDR R1, =NVIC_PRI4_R             
			LDR R2, [R1]                    ; 
			AND R2, R2, #0x00FFFFFF         ; R2 = R2&0x00FFFFFF (clear interrupt 19 priority, bit 29:31)
			ORR R2, R2, #0x40000000         ; R2 = R2|0x40000000 (set priority 2)
			STR R2, [R1]                    
    
; enable interrupt 19 in NVIC register
			LDR R1, =NVIC_EN0_R              
			LDR R2, =0x00080000        		; enable Interrupt 19 (16/32 Timer 0A) 
			STR R2, [R1]                    
		
; enable timer A
			LDR R1, =TIMER0_CTL_R            
			LDR R2, [R1]                    ;     
			ORR R2, R2, #00000001     	    ; set enable bit
			STR R2, [R1]                    ; 
			BX  LR                          ; return

			ALIGN                           
			END                             ; end of file
