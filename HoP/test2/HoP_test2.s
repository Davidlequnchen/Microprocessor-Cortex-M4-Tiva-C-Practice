; adc_single_ch.s
; samples one ADC channel, PortE bit 4 (PE4), using Sample Sequencer 3(SS3)

; GPIO_PORTE and ADC0 address

;Potentiometer: PE5
;Dip Switch: PA4
;Green LED: PB3
;Red LED: PD1


GPIO_PORTE_AFSEL_R 	EQU 0x40024420
GPIO_PORTE_DEN_R   	EQU 0x4002451C
GPIO_PORTE_AMSEL_R 	EQU 0x40024528

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
	
	
GPIO_PORTA_DATA_R  	EQU 0x400043FC
GPIO_PORTA_DIR_R   	EQU 0x40004400
GPIO_PORTA_AFSEL_R 	EQU 0x40004420
GPIO_PORTA_PUR_R   	EQU 0x40004510
GPIO_PORTA_DEN_R   	EQU 0x4000451C
GPIO_PORTA_AMSEL_R 	EQU 0x40004528
GPIO_PORTA_PCTL_R  	EQU 0x4000452C

GPIO_PORTB_DATA_R  	EQU 0x400053FC
GPIO_PORTB_DIR_R   	EQU 0x40005400
GPIO_PORTB_AFSEL_R 	EQU 0x40005420		
GPIO_PORTB_PUR_R   	EQU 0x40005510
GPIO_PORTB_DEN_R   	EQU 0x4000551C
GPIO_PORTB_AMSEL_R 	EQU 0x40005528
GPIO_PORTB_PCTL_R  	EQU 0x4000552C

	
GPIO_PORTF_DATA_R  	EQU 0x400253FC
GPIO_PORTF_DIR_R   	EQU 0x40025400
GPIO_PORTF_AFSEL_R 	EQU 0x40025420
GPIO_PORTF_PUR_R   	EQU 0x40025510
GPIO_PORTF_DEN_R   	EQU 0x4002551C
GPIO_PORTF_AMSEL_R 	EQU 0x40025528
GPIO_PORTF_PCTL_R  	EQU 0x4002552C

GPIO_PORTD_DATA_R  	EQU 0x400073FC
GPIO_PORTD_DIR_R   	EQU 0x40007400
GPIO_PORTD_AFSEL_R 	EQU 0x40007420
GPIO_PORTD_PUR_R   	EQU 0x40007510
GPIO_PORTD_DEN_R   	EQU 0x4000751C
GPIO_PORTD_AMSEL_R 	EQU 0x40007528
GPIO_PORTD_PCTL_R  	EQU 0x4000752C
;PD					EQU 0x40007024		; Enable Port D bit 0 and 3

PWM1_CTL_R			EQU 0x40028080			; PWM1 (Port B7) Control 
PWM1_GENA_R			EQU 0x400280A0			; PWM1 Generator A Control 
PWM1_CMPA_R			EQU 0x40028098			; PWM1 Compare A 
PWM1_LOAD_R			EQU 0x40028090			; PWM1 Load 	
PWM_ENABLE_R		EQU 0x40028008			; PWM1 Output Enable

PWM0_CTL_R			EQU 0x40028040			; M0PWM0 Control 
PWM0_GENA_R			EQU 0x40028060			; M0PWM0 Generator A Control 
PWM0_CMPA_R			EQU 0x40028058			; M0PWM0 Compare A 
PWM0_GENB_R         EQU 0x40028064
PWM0_CMPB_R			EQU 0x4002805C	
PWM0_LOAD_R			EQU 0x40028050			; M0PWM0 Load 	

	
	

PA4                	EQU 0x40004040      ; PA4 for dip switch
PB3				    EQU 0x40005020		; Port B3, for Green LED
PD2					EQU 0x40007010		; Enable Port D2 Red LED
	
PF0                	EQU 0x40025004	; 	SW2 - negative logic
PF1                	EQU 0x40025008	;	RED LED
PF2                	EQU 0x40025010	; 	BLUE LED - ORIG
PF3                	EQU 0x40025020	;	GREEN LED
PF4                	EQU 0x40025040	;	SW1 - ORIG -negative logic
PFA				   	EQU 0x40025038	; 	3 colours :
PFRG               	EQU 0x40025028
PFGB               	EQU 0x40025030
PFRB			   	EQU 0x40025018
	

SYSCTL_RCGCADC_R 	EQU 0x400FE638		     ; ADC run mode clock gating control	
SYSCTL_RCC_R		EQU	0x400FE060			; Run-Mode Clock Configuration
SYSCTL_RCGCGPIO_R   EQU 0x400FE608
SYSCTL_RCGCPWM_R	EQU 0x400FE640			; PWM Run Mode Clock Gating Control	

		THUMB
		AREA    DATA, ALIGN=4 
		EXPORT  Result [DATA,SIZE=4]
Result  SPACE   4


		AREA    |.text|, CODE, READONLY, ALIGN=2
		THUMB
		EXPORT  Start

Start

; start clock 
			LDR R1, =SYSCTL_RCGCGPIO_R 		; R1 = address of SYSCTL_RCGCGPIO_R
			LDR R0, [R1]                	; 
			ORR R0, R0, #0x3B           	; turn on GPIO A B D E F  clock
			STR R0, [R1]                  
			NOP								; allow time for clock to finish
			NOP
			NOP  

; initialize port A--------------------------------------------------------------------------------------------
; disable analog mode
			LDR R1, =GPIO_PORTA_AMSEL_R     
			LDR R0, [R1]                    
			BIC R0, R0, #0x10    			; disable analog mode on PortA bit 4
			STR R0, [R1]       
	
;configure as GPIO
			LDR R1, =GPIO_PORTA_PCTL_R      
			LDR R0, [R1]  
			BIC R0, R0,#0x000F0000			; clear PortA bit 4 
			;BIC R0, R0,#0XFF000000			; clear PortA bit 6 & 7 
			STR R0, [R1]     
    
;set direction register
			LDR R1, =GPIO_PORTA_DIR_R       
			LDR R0, [R1]                    
			BIC R0, R0, #0x10     			; set PortA bit 4-7 input (0: input, 1: output)
			STR R0, [R1]    
	
; disable alternate function
			LDR R1, =GPIO_PORTA_AFSEL_R     
			LDR R0, [R1]                     
			BIC R0, R0, #0x10      			; disable alternate function on PortA bit 4
			STR R0, [R1] 

; pull-up resistors on switch pins
			LDR R1, =GPIO_PORTA_PUR_R      	; 
			LDR R0, [R1]                   	; 
			ORR R0, R0, #0x10              	; enable pull-up on PortA bit 4
			STR R0, [R1]                   

; enable digital port
			LDR R1, =GPIO_PORTA_DEN_R   	
			LDR R0, [R1]                    
			ORR R0, R0, #0x10               ; enable digital I/O on PortA bit 4
			STR R0, [R1]    
			
			LDR R4, =PA4
		
; initialize port B 3-----------------------------------------------------------------------------------------------
; disable analog mode
			LDR R1, =GPIO_PORTB_AMSEL_R     
			LDR R0, [R1]                    
			BIC R0, R0, #0x08    			; Clear bit 3, disable analog function
			STR R0, [R1]       
	
; configure as GPIO
			LDR R1, =GPIO_PORTB_PCTL_R      
			LDR R0, [R1]  
			BIC R0, R0,#0x0000F000			; bit clear PortB bit 3
			STR R0, [R1]     
    
; set direction register
			LDR R1, =GPIO_PORTB_DIR_R       
			LDR R0, [R1]                    
			ORR R0, R0, #0x08     			; set PortB bit 3 as output (0: input, 1: output)
			STR R0, [R1]    
	
; disable alternate function
			LDR R1, =GPIO_PORTB_AFSEL_R     
			LDR R0, [R1]                     
			BIC R0, R0, #0x08    			; disable alternate function on PortB bit 3
			STR R0, [R1] 

; enable digital port
			LDR R1, =GPIO_PORTB_DEN_R   	
			LDR R0, [R1]                    
			ORR R0, #0x08               	; enable PortB 3 digital I/O      
			STR R0, [R1] 

        
    	    
; initialize Port B7 (Red LED) M0PWM1-------------------------------------------------------------------------------------------------
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
			BIC R0, R0, #0x80    			; disable PB7 analog function
			STR R0, [R1]       
	  
; select alternate function
			LDR R1, =GPIO_PORTB_AFSEL_R     
			LDR R0, [R1]                     
			ORR R0, R0, #0x80    			; enable alternate function on PB7
			STR R0, [R1] 
			
; configure as M0PWM1 output
			LDR R1, =GPIO_PORTB_PCTL_R      
			LDR R0, [R1]  
			BIC R0, R0, #0xF0000000
			ORR R0, R0, #0x40000000			; assign PB7 as M0PWM1 pin (bit field is 4)
			STR R0, [R1]     
   
			
; enable digital port
			LDR R1, =GPIO_PORTB_DEN_R   	
			LDR R0, [R1]                    
			ORR R0, #0x80               	; enable digital I/O on PB7   
			STR R0, [R1]   
			
; set PWM clock of 0.625MHz
			LDR R1, =SYSCTL_RCC_R     
			LDR R0, [R1]                    
			BIC R0, R0, #0x000E0000     	; use PWM clock divider as the source for PWM clock
			ORR R0, R0, #0x001E0000			; pre-divide system clock down for use as the timing ref for PWM module 
			STR R0, [R1]    				; select Divisor "/64" -> PWM clock = 40MHz/64 = 0.625MHz 
											; (clock period = 1/0.625 = 1.6 microsecond)
; configure PWM generator 1 block
			LDR R1, =PWM0_CTL_R  			;
			LDR R0, =0x00					; select Count-Down mode and disable PWM generation block
			STR R0, [R1]     				

; control the generation of pwm1B signal
			LDR R1, =PWM0_GENB_R
			LDR R0, =0x80C					; pwm0B goes Low when the counter matches comparator B while counting down
			STR R0, [R1]					; and drive pwmB High when the counter matches value in the PWM1LOAD register
		
; initialize Port F  (On board LED)---------------------------------------------------------------------------------------------
			LDR R1, =GPIO_PORTF_AMSEL_R     
			LDR R0, [R1]                    
			BIC R0, #0x0E                  	; 0 means analog is off
			STR R0, [R1]       
			
			;configure as GPIO
			LDR R1, =GPIO_PORTF_PCTL_R      
			LDR R0, [R1]   
			BIC R0, R0,	#0x00000FF0			; Clears bit 1 & 2
			BIC R0, R0, #0x000FF000         ; Clears bit 3 & 4
			STR R0, [R1]     
			
			;set direction register
			LDR R1, =GPIO_PORTF_DIR_R       
			LDR R0, [R1]                    
			ORR R0, R0, #0x0E               ; PF 1,2,3 output 
			BIC R0, R0, #0x10               ; Make PF4 built-in button input
			STR R0, [R1]    
			
			; regular port function
			LDR R1, =GPIO_PORTF_AFSEL_R     
			LDR R0, [R1]                     
			BIC R0, R0, #0x1E               ; 0 means disable alternate function
			STR R0, [R1] 
			
			; pull-up resistors on switch pins
			LDR R1, =GPIO_PORTF_PUR_R       ; R1 = &GPIO_PORTF_PUR_R
			LDR R0, [R1]                    ; R0 = [R1]
			ORR R0, R0, #0x10               ; R0 = R0|0x10 (enable pull-up on PF4)
			STR R0, [R1]                    ; [R1] = R0

			; enable digital port
			LDR R1, =GPIO_PORTF_DEN_R       ; 7) enable Port F digital port
			LDR R0, [R1]                    
			ORR R0,#0x0E                    ; 1 means enable digital I/O
			ORR R0, R0, #0x10               ; R0 = R0|0x10 (enable digital I/O on PF4)
			STR R0, [R1]    
		
		
; initialize the port E with ADC funcionality ---------------------------------------------------
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
			
			;LDR R4, =PF4                    ; R4 = &PF5
			
		
Loop		


Check_switch
		LDR R0, [R4]					; R0 = dip switch status
		CMP R0, #0
		BEQ Green_Off
		BNE Green_On
		
Read_pot			
		LDR R1, =ADC0_PSSI_R      
		MOV R0, #0x08					; initiate sampling in the SS3  
		STR R0, [R1]    
		
		LDR R1, =ADC0_RIS_R   			; R1 = address of ADC Raw Interrupt Status
		LDR R0, [R1]           			; check end of a conversion
		CMP	R0, #0x08    				; when a sample has completed conversion -> a raw interrupt is enabled
		BNE	Loop    
		
		LDR R1, =ADC0_SSFIFO3_R			; load SS3 result FIFO into R1
		LDR R0,[R1]
		LDR R2, =Result					; store data
		STR R0,[R2]	
		
		; set duty cycle, controlled by the value read from potentiometer
		; comparator match value -> set PWM space time (off time)
		LDR R1, =PWM0_CMPB_R
		;LDR R0, =400					; store value 400(decimal) into comparator A, PB7 goes low when match 
		;B Compare_pot 					; branch into the read pot subroutine to determine the PWM on range
		STR R0, [R1]					; PWM "space" time is 0.64 millisecond (400 x 1.6 microsecond)											

		; counter load value -> set period	
		LDR R1, =PWM0_LOAD_R			; load value = 1600(decimal) -> pulse period = 1600 x 1.6 microsecond = 2.56 millisecond 
		LDR R0, =0xFFF					; in count-down mode, this value is loaded into the counter after it reaches zero and  
		STR R0, [R1]					; PB7 pin goes high 
																		
		LDR R1, =PWM0_CTL_R  			; 
		LDR R0, =0x01					; enable PWM generation block and produces PWM signal
		STR R0, [R1]     
	
		LDR R1, =PWM_ENABLE_R			; enable M0PWM1 pin 
		LDR R0, =0x02					; 
		STR R0, [R1] 


ClearStatus
		LDR R1, =ADC0_ISC_R
		LDR R0, [R1]
		ORR R0, R0, #08					; acknowledge conversion
		STR R0, [R1]
		
		B Loop



Green_On 
		LDR R1, =PB3                     ; turn on the Green LED
		MOV R0, #0x0E                    ; Turn on Green
		STR R0, [R1] 
		B Read_pot

Green_Off
		LDR R1, =PB3                     ; turn on the Green LED
		MOV R0, #0x00                   ;  Turn off Green
		STR R0, [R1] 
		B Read_pot


Blue_blink
		LDR R1, =PFRG                   ; R1 = &PF2
		MOV R0, #0x00                   ; R0 = 0x04 (turn on the appliance)
		STR R0, [R1]
		LDR R1, =PF2                    ; R1 = &PF2
		MOV R0, #0x0E                   ; R0 = 0x04 (turn on the appliance)
		STR R0, [R1]                    ; [R1] = R0, write to PF2
		BL Delay
		MOV R0, #0x00                   ; R0 = 0x04 (turn on the appliance)
		STR R0, [R1]  	
		BL Delay
		B ClearStatus   

All_off
        LDR R1, =PFA                    ; 
		MOV R0, #0x00                   ; turn off all
		STR R0, [R1] 
		BX LR  

Delay									; Delay subroutine
		MOV R7,#0x80000
					
Countdown
		SUBS R7, #1						; subtract and set the flags based on the result
		BNE Countdown		 
		
		BX LR   						; return from subroutine

		ALIGN                			; make sure the end of this section is aligned
		END                  			; end of file
			
