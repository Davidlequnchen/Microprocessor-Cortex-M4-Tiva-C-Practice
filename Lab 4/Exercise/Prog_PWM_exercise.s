; Prog_PWM.s
; 
; PWM Output on PB6 (M0PWM0) pin
;
			
			IMPORT PLL_Init					; symbol names defined in other file, named Prog_PLL.s 

; GPIO_PORTA address
GPIO_PORTA_DATA_R  	EQU 0x400043FC
GPIO_PORTA_DIR_R   	EQU 0x40004400
GPIO_PORTA_AFSEL_R 	EQU 0x40004420
GPIO_PORTA_PUR_R   	EQU 0x40004510
GPIO_PORTA_DEN_R   	EQU 0x4000451C
GPIO_PORTA_AMSEL_R 	EQU 0x40004528
GPIO_PORTA_PCTL_R  	EQU 0x4000452C
;PA_4567				EQU 0x400043C0		; PortA bit 4-7   4 + 8 + 16 + 32 = 3C0
	
GPIO_PORTB_AFSEL_R 	EQU 0x40005420		
GPIO_PORTB_DEN_R   	EQU 0x4000551C
GPIO_PORTB_AMSEL_R 	EQU 0x40005528
GPIO_PORTB_PCTL_R  	EQU 0x4000552C	
	
GPIO_PORTE_AFSEL_R 	EQU 0x40024420
GPIO_PORTE_DEN_R   	EQU 0x4002451C
GPIO_PORTE_AMSEL_R 	EQU 0x40024528
	
GPIO_PORTF_AFSEL_R EQU 0x40025420
GPIO_PORTF_DATA_R  EQU 0x400253FC
GPIO_PORTF_DIR_R   EQU 0x40025400
GPIO_PORTF_PUR_R   EQU 0x40025510
GPIO_PORTF_DEN_R   EQU 0x4002551C
GPIO_PORTF_AMSEL_R EQU 0x40025528
GPIO_PORTF_PCTL_R  EQU 0x4002552C
PF0                EQU 0x40025004	; 	SW2 - negative logic
PF1                EQU 0x40025008	;	RED LED
PF2                EQU 0x40025010	; 	BLUE LED - ORIG
PF3                EQU 0x40025020	;	GREEN LED
PF4                EQU 0x40025040	;	SW1 - ORIG -negative logic 
	
	

ADC0_ACTSS_R   		EQU 0x40038000
ADC0_PC_R           EQU	0x40038FC4
ADC0_SSPRI_R        EQU	0x40038020
ADC0_EMUX_R			EQU	0x40038014
ADC0_SSMUX3_R       EQU 0x400380A0
ADC0_SSCTL3_R       EQU	0x400380A4
ADC0_IM_R           EQU 0x40038008
ADC0_PSSI_R			EQU 0x40038028
ADC0_RIS_R			EQU	0x40038004	
ADC0_SSFIFO3_R		EQU	0x400380A8	
ADC0_ISC_R			EQU	0x4003800C		
	
	
				
SYSCTL_RCGCGPIO_R  	EQU 0x400FE608			; GPIO Run Mode Clock Gating Control
SYSCTL_RCGCPWM_R	EQU 0x400FE640			; PWM Run Mode Clock Gating Control
	
PWM0_CTL_R			EQU 0x40028040			; PWM0 Control 
PWM0_GENA_R			EQU 0x40028060			; PWM0 Generator A Control 
PWM0_CMPA_R			EQU 0x40028058			; PWM0 Compare A 
PWM0_LOAD_R			EQU 0x40028050			; PWM0 Load 	
PWM0_ENABLE_R		EQU 0x40028008			; PWM0 Output Enable


PA3					EQU 0x40004020          ; PA3 is to be connected to opto switch to control on/off of motor
PE5                 EQU 0x40024040	        ; PE5 - AIN8, is connected to potentiometer for motor speed
	
SYSCTL_RCC_R		EQU	0x400FE060			; Run-Mode Clock Configuration
SYSCTL_RCGCADC_R 	EQU 0x400FE638		; ADC run mode clock gating control


			THUMB
			AREA    DATA, ALIGN=4 
			EXPORT  Result [DATA,SIZE=4]
Result  	SPACE   4


			AREA    |.text|, CODE, READONLY, ALIGN=2
			THUMB
			EXPORT  Start

Start
			BL PLL_Init						; call subroutine (in Prog_PLL.s) to generate system clock of 40MHz


; ---------------------


	
; initialize Port E, port A and ADC ------------------------------------------------
; activate clock for PortE, portB, portA
			LDR R1, =SYSCTL_RCGCGPIO_R 		; R1 = address of SYSCTL_RCGCGPIO_R
			LDR R0, [R1]                	; 
			ORR R0, R0, #0x13          	    ; turn on GPIOE GPIOA, GPIOB clock
			STR R0, [R1]                  
			NOP								; allow time for clock to finish
			NOP
			NOP  
	
; configure port A, which is used for the opto switch ------------------------------------PORTA--------------------
; disable analog mode
			LDR R1, =GPIO_PORTA_AMSEL_R     
			LDR R0, [R1]                    
			BIC R0, R0, #0x08   			; disable analog mode on PortA bit 3, but what we need is only portA 3
			STR R0, [R1]       
	
;configure as GPIO
			LDR R1, =GPIO_PORTA_PCTL_R      
			LDR R0, [R1]  
			;BIC R0, R0,#0x00FF0000			; clear PortA bit 4 & 5
			;BIC R0, R0,#0xFF000000			; clear PortA bit 6 & 7 
			BIC R0, R0,#0x0000F000			; clear PortA bit 3 
			STR R0, [R1]     
    
;set direction register
			LDR R1, =GPIO_PORTA_DIR_R       
			LDR R0, [R1]                    
			BIC R0, R0, #0x08     			; set PortA bit 0-3 input (0: input (use BIC), 1: output(use ORR))
			STR R0, [R1]    
		
; disable alternate function
			LDR R1, =GPIO_PORTA_AFSEL_R     
			LDR R0, [R1]                     
			BIC R0, R0, #0x08      			; disable alternate function on PortA bit 3
			STR R0, [R1] 

; pull-up resistors on switch pins
			LDR R1, =GPIO_PORTA_PUR_R      	; 
			LDR R0, [R1]                   	; 
			ORR R0, R0, #0x08              	; enable pull-up on PortA bit 3
			STR R0, [R1]                   

; enable digital port
			LDR R1, =GPIO_PORTA_DEN_R   	
			LDR R0, [R1]                    
			ORR R0, R0, #0x08               ; enable digital I/O on PortA bit 0123
			STR R0, [R1]    
				
			LDR R5, =PA3
		
		
	
; configure port E, which is used for AIN8 (PE5) potentiometer-------------------------PORTE----------------------
; enable alternate function
			LDR R1, =GPIO_PORTE_AFSEL_R     
			LDR R0, [R1]                     
			ORR R0, R0, #0x20      			; enable alternate function on PE5
			STR R0, [R1] 
		
; disable digital port
			LDR R1, =GPIO_PORTE_DEN_R   	
			LDR R0, [R1]                    
			BIC R0, R0, #0x20               ; disable digital I/O on PE5
			STR R0, [R1]    
	 			
; enable analog mode
			LDR R1, =GPIO_PORTE_AMSEL_R     
			LDR R0, [R1]                    
			ORR R0, R0, #0x20    			; enable PE5 analog function
			STR R0, [R1]       

; activate clock for ADC0
			LDR R1, =SYSCTL_RCGCADC_R 		 
			LDR R0, [R1]                	 
			ORR R0, R0, #0x01           	; activate ADC0
			STR R0, [R1]                  
		  
			BL Delay						; delay subroutine -> allow time for clock to finish
			
			LDR R1, =ADC0_PC_R       
			LDR R0, [R1]           
			BIC R0, R0, #0x0F				; clear max sample rate field
			ORR R0, R0, #0x1     			; configure for 125K samples/sec
			STR R0, [R1]    

			LDR R1, =ADC0_SSPRI_R       
			LDR R0, =0x0123           		; SS3 is highest priority
			STR R0, [R1]    

			LDR R1, =ADC0_ACTSS_R       
			LDR R0, [R1]           
			BIC R0, R0, #0x08				; disable SS3 before configuration to 
			STR R0, [R1]    				; prevent erroneous execution if a trigger event were to occur

			LDR R1, =ADC0_EMUX_R       
			LDR R0, [R1]           
			BIC R0, R0, #0xF000				; SS3 is software trigger
			STR R0, [R1]    

			LDR R1, =ADC0_SSMUX3_R      
			LDR R0, [R1]           
			BIC R0, R0, #0x000F				; clear SS3 field
			ADD R0, R0, #8					; set channel -> select input pin AIN9
			STR R0, [R1]    

			LDR R1, =ADC0_SSCTL3_R       
			LDR R0, =0x0006           		; configure 1st sample -> not reading Temp sensor, not differentially sampled,
			STR R0, [R1]    				; assert raw interrupt signal at the end of conversion, first sample is last sample
			
			LDR R1, =ADC0_IM_R     
			LDR R0, [R1]           
			BIC R0, R0, #0x0008				; disable SS3 interrupts
			STR R0, [R1]    
			
			LDR R1, =ADC0_ACTSS_R      
			LDR R0, [R1]           
			ORR R0, R0, #0x0008     		; enable SS3
			STR R0, [R1]    
		
		
		
; initialise PortB and PWM Module -------------------------------------------------------------------------PORTB-----------------------

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

;-------------------------------------------------the actual precedure starts-----------------------------------------------
;-----------------------------------first step: check the opt status---------------------

loop_check_opt
			LDR R0, [R5]					; R0 = dip switch status
			CMP R0, #0
			BEQ loop_check_opt


Loop
            ; Start sampling for the input (potentiometer)
			LDR R1, =ADC0_PSSI_R      
			MOV R0, #0x08					; initiate sampling in the SS3  
			STR R0, [R1]    
			
			LDR R1, =ADC0_RIS_R   			; R1 = address of ADC Raw Interrupt Status
			LDR R0, [R1]           			; check end of a conversion
			CMP	R0, #0x08    				; when a sample has completed conversion -> a raw interrupt is enabled
			BNE	Loop    
			
			LDR R1, =ADC0_SSFIFO3_R			; load SS3 result FIFO into R1
			LDR R3,[R1]                     ; read the value of FIFO into R3
			LDR R2, =Result					; store data
			STR R3,[R2]
			
			
			
			
; set duty cycle, controlled by the value read from potentiometer

; comparator match value -> set PWM space time (off time)
			LDR R1, =PWM0_CMPA_R
			;LDR R0, =400					; store value 400(decimal) into comparator A, PB6 goes low when match 
			BL Read_pot 					; branch into the read pot subroutine to determine the PWM on range
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
	
ClearStatus
			LDR R1, =ADC0_ISC_R
			LDR R0, [R1]
			ORR R0, R0, #08					; acknowledge conversion
			STR R0, [R1]
		
			
			B	Loop



Read_pot
			;LDR R3, =PE5                    ; R3 is address of the PE5
			;LDR R2, [R3]                    ; load the content of PE5 into R2
			CMP R3, #0x02 << 9               ; R3 should be the reading at PE5, compare
			BLT Level_1
			CMP R3, #0x0C << 8
			BGE Level_3
			BLT Level_2	

Level_1
			LDR R0, =200
			BX LR
			
Level_2
			LDR R0, =800
			BX LR

Level_3
			LDR R0, =1400
			BX LR


Delay									    ; Delay subroutine
			MOV R7,#0x20000
					
Countdown
			SUBS R7, #1						; subtract and set the flags based on the result
			BNE Countdown		 
			
			BX LR   						; return from subroutine
			
			
			ALIGN                			; make sure the end of this section is aligned
			END                  			; end of file




