; Prog_PLL.s
; 
; Use PLL output and divider to produce 40MHz system clock 
	

SYSCTL_RIS_R		EQU	0x400FE050		; Raw Interrupt Status 
SYSCTL_RCC_R		EQU	0x400FE060		; Run-Mode Clock Configuration 
SYSCTL_RCC2_R		EQU	0x400FE070		; Run-Mode Clock Configuration 2 

SYSCTL_RCGCGPIO_R  	EQU 0x400FE608		; GPIO Run Mode Clock Gating Control
SYSCTL_RCGCPWM_R	EQU 0x400FE640		; PWM Run Mode Clock Gating Control
	
	
			AREA    |.text|, CODE, READONLY, ALIGN=2
			THUMB
			EXPORT  PLL_Init			; 
	
PLL_Init								; 

;
; configure clock source for PLL (use RCC2 divider, 16MHz crystal, main oscillator source)
;
; system clock divider
			LDR R1, =SYSCTL_RCC2_R     	; R1 = address of SYSCTL_RCC2_R 
			LDR R0, [R1]                    
			ORR R0, R0, #0x80000000    	; use RCC2 divider as system clock divider
			STR R0, [R1]    

; Configure PLL Bypass 2 	
			LDR R0, [R1]               	;    		
			ORR R0, R0, #0x00000800   	; system clock is derived from the OSC source and
			STR R0, [R1]    			; divided by the divisor specified by SYSDIV2
										
; select crystal value						
			LDR R1, =SYSCTL_RCC_R     	;    
			LDR R0, [R1]                    
			BIC R0, R0, #0x000007C0   	; clear RCC bit 6-10 -> clear XTAL field 
			ADD R0, R0, #0x00000540		; select 16MHz crystal, 0x15 (binary 10101)
			STR R0, [R1]    			; 

; select input source for the oscillator 
			LDR R1, =SYSCTL_RCC2_R    	;
			LDR R0, [R1]               	;  
			BIC R0, R0, #0x00000070		; clear oscillator source field
			ADD R0, R0, #0x00000000		; use main oscillator source	
			STR R0, [R1]    

;
; generate the system clock from PLL output
; activate PLL, select divider /10 to obtain 40MHz system clock
;
; activate PLL

			LDR R0, [R1]               	; configure SYSCTL_RCC2_R 
			BIC R0, R0, #0x00002000    	; activate PLL by clearing PWRDN bit
			STR R0, [R1]    

; set the desired system divider and the system divider least significant bit
			    
			LDR R0, [R1]             	; configure SYSCTL_RCC2_R to use 400 MHz PLL   
			ORR R0, R0, #0x40000000    	; 
			STR R0, [R1]    

		    LDR R0, [R1]             	; configure SYSCTL_RCC2_R    
			BIC R0, R0, #0x1FC00000   	; clear system clock divider field
			ADD R0, R0, #0x02400000		; select divider /10 to produce 40MHz system clock (400MHz/10 = 40MHz)
			STR R0, [R1]       			; 

; ensure PLL is locked
  			LDR R1, =SYSCTL_RIS_R     	; 

Check_PLL_lock
    		LDR R0, [R1]            	; 
    		ANDS R0, R0, #0x40			; check Raw Interrupt Status for PLL Lock 
    		BEQ Check_PLL_lock     		; if not locked, keep polling

; enable use of PLL
			LDR R1, =SYSCTL_RCC2_R     	; R1 = address of SYSCTL_RCC2_R 
			LDR R0, [R1]              	; 		
			BIC R0, R0, #0x00000800   	; clear PLL Bypass 
			STR R0, [R1]    			; 
			
			BX LR						; return

			ALIGN                		; make sure the end of this section is aligned
			END                  		; end of file



