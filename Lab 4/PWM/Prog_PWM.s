; Prog_PWM.s
; 
; PWM Output on PB6 (M0PWM0) pin
;
			
			IMPORT PLL_Init					; symbol names defined in other file, named Prog_PLL.s 


GPIO_PORTB_AFSEL_R 	EQU 0x40005420		
GPIO_PORTB_DEN_R   	EQU 0x4000551C
GPIO_PORTB_AMSEL_R 	EQU 0x40005528
GPIO_PORTB_PCTL_R  	EQU 0x4000552C	
				
SYSCTL_RCGCGPIO_R  	EQU 0x400FE608			; GPIO Run Mode Clock Gating Control
SYSCTL_RCGCPWM_R	EQU 0x400FE640			; PWM Run Mode Clock Gating Control
	
PWM0_CTL_R			EQU 0x40028040			; PWM0 Control 
PWM0_GENA_R			EQU 0x40028060			; PWM0 Generator A Control 
PWM0_CMPA_R			EQU 0x40028058			; PWM0 Compare A 
PWM0_LOAD_R			EQU 0x40028050			; PWM0 Load 	
PWM0_ENABLE_R		EQU 0x40028008			; PWM0 Output Enable	
	
SYSCTL_RCC_R		EQU	0x400FE060			; Run-Mode Clock Configuration
	

			AREA    |.text|, CODE, READONLY, ALIGN=2
			THUMB
			EXPORT  Start
	
Start
			BL PLL_Init						; call subroutine (in Prog_PLL.s) to generate system clock of 40MHz

; initialise PortB and PWM Module
;
; activate clock for Port B 
			LDR R1, =SYSCTL_RCGCGPIO_R 		; 
			LDR R0, [R1]                	; 
			ORR R0, R0, #0x02           	; turn on clock for GPIOB
			STR R0, [R1]                  
			NOP								; allow time for clock to finish
			NOP
			NOP   
				
; activate clock for PWM 
			LDR R1, =SYSCTL_RCGCPWM_R 		; 
			LDR R0, [R1]                	; 
			ORR R0, R0, #0x01          	 	; turn on clock for PWM Module 0
			STR R0, [R1]                  
			NOP								; allow time for clock to finish
			NOP
			NOP   

;
; disable analog functionality
			LDR R1, =GPIO_PORTB_AMSEL_R     
			LDR R0, [R1]                    
			BIC R0, R0, #0x40    			; disable PB6 analog function
			STR R0, [R1]       
	  
; select alternate function
			LDR R1, =GPIO_PORTB_AFSEL_R     
			LDR R0, [R1]                     
			ORR R0, R0, #0x40    			; enable alternate function on PB6
			STR R0, [R1] 
			
; configure as M0PWM0 output
			LDR R1, =GPIO_PORTB_PCTL_R      
			LDR R0, [R1]  
			BIC R0, R0, #0x0F000000
			ORR R0, R0, #0x04000000			; assign PB6 as M0PWM0 pin
			STR R0, [R1]     
   
			
; enable digital port
			LDR R1, =GPIO_PORTB_DEN_R   	
			LDR R0, [R1]                    
			ORR R0, #0x40               	; enable digital I/O on PB6   
			STR R0, [R1]   
			
; set PWM clock of 0.625MHz
			LDR R1, =SYSCTL_RCC_R     
			LDR R0, [R1]                    
			BIC R0, R0, #0x000E0000     	; use PWM clock divider as the source for PWM clock
			ORR R0, R0, #0x001E0000			; pre-divide system clock down for use as the timing ref for PWM module 
			STR R0, [R1]    				; select Divisor "/64" -> PWM clock = 40MHz/64 = 0.625MHz 
											; (clock period = 1/0.625 = 1.6 microsecond)
; configure PWM generator 0 block
			LDR R1, =PWM0_CTL_R  			;
			LDR R0, =0x00					; select Count-Down mode and disable PWM generation block
			STR R0, [R1]     				

; control the generation of pwm0A signal
			LDR R1, =PWM0_GENA_R
			LDR R0, =0x8C					; pwm0A goes Low when the counter matches comparator A while counting down
			STR R0, [R1]					; and drive pwmA High when the counter matches value in the PWM0LOAD register
;
; set duty cycle, about 75%
;
; comparator match value -> set PWM space time (off time)
			LDR R1, =PWM0_CMPA_R
			LDR R0, =400					; store value 400(decimal) into comparator A, PB6 goes low when match 
			STR R0, [R1]					; PWM "space" time is 0.64 millisecond (400 x 1.6 microsecond)											

; counter load value -> set period	
			LDR R1, =PWM0_LOAD_R			; load value = 1600(decimal) -> pulse period = 1600 x 1.6 microsecond = 2.56 millisecond 
			LDR R0, =1600 					; in count-down mode, this value is loaded into the counter after it reaches zero and  
			STR R0, [R1]					; PB6 pin goes high 
																		
			LDR R1, =PWM0_CTL_R  			; 
			LDR R0, =0x01					; enable PWM generation block and produces PWM signal
			STR R0, [R1]     
	
			LDR R1, =PWM0_ENABLE_R			; enable M0PWM0 pin 
			LDR R0, =0x01					; 
			STR R0, [R1] 
	
Loop
			B	Loop

			ALIGN                			; make sure the end of this section is aligned
			END                  			; end of file




