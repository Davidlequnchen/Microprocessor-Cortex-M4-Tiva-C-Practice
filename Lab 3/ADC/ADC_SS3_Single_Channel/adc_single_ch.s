; adc_single_ch.s
; samples one ADC channel, PortE bit 4 (PE4), using Sample Sequencer 3(SS3)

; Exercise --------------
; 1. Change the PE4 to PE 5, now reading the potentio meter not temperature
; 2. When the pot output rises beyond 1.0V, green LED (PortF 3) would start to flicker
; 3. beyond 2.0V, the red LED (PortF 1) would start to flicker (Turn off Green LED). 
; 4. below 2.0V, the red LED is turned off. Falling below 1.0V would turn off the green LED too


; GPIO_PORTE and ADC0 address

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


; GPIO port F 
GPIO_PORTF_DATA_R  EQU 0x400253FC
GPIO_PORTF_DIR_R   EQU 0x40025400
GPIO_PORTF_AFSEL_R EQU 0x40025420
GPIO_PORTF_PUR_R   EQU 0x40025510
GPIO_PORTF_DEN_R   EQU 0x4002551C
GPIO_PORTF_AMSEL_R EQU 0x40025528
GPIO_PORTF_PCTL_R  EQU 0x4002552C
PE5				   EQU 0x40024080   ;   PE base is 0x40024000, PE0 starts from bits2, [2:9]
PF0                EQU 0x40025004	; 	SW2 - negative logic
PF1                EQU 0x40025008	;	RED LED
PF2                EQU 0x40025010	; 	BLUE LED - ORIG
PF3                EQU 0x40025020	;	GREEN LED
PF4                EQU 0x40025040	;	SW1 - ORIG -negative logic
PFA				   EQU 0x40025038	; 	3 Colors
PFRB			   EQU 0x40025018   ;   red and blue
PFGB               EQU 0x40025030   ;   green and blue
PFRG               EQU 0x40025028   ;   red and green

	
SYSCTL_RCGCGPIO_R  	EQU 0x400FE608		; GPIO run mode clock gating control

SYSCTL_RCGCADC_R 	EQU 0x400FE638		; ADC run mode clock gating control

		THUMB
		AREA    DATA, ALIGN=4 
		EXPORT  Result [DATA,SIZE=4]
Result  SPACE   4


		AREA    |.text|, CODE, READONLY, ALIGN=2
		THUMB
		EXPORT  Start

Start

;-----------------------------------------------------------------------
; initialize PF 1-3 output LED light, (PE5) an input, 
; enable digital I/O, ensure alt. functions off.
; Input: none, Output: none, Modifies: R0, R1

	; activate clock for Port F and Port E
    LDR R1, =SYSCTL_RCGCGPIO_R      
    LDR R0, [R1]                 
    ORR R0, R0, #0x30               ; set bit 5 to turn on clock for Port F while, turn on GPIOE clock is #0x10, therefore
    STR R0, [R1]                  
    NOP								; allow time for clock to finish
    NOP
    NOP        
	
    ; no need to unlock PF2
	
	; disable analog functionality
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
    
	
	;LDR R4, =PE5                    ; R4 = &PE5
	

; initialize Port E ------------------------------------------------------------------------------------
	 
; no need to unlock PE4

; enable alternate function
		LDR R1, =GPIO_PORTE_AFSEL_R     
		LDR R0, [R1]                     
		;ORR R0, R0, #0x10      			; enable alternate function on PE4
		ORR R0, R0, #0x20      			; enable alternate function on PE5
		STR R0, [R1] 
		
; disable digital port
		LDR R1, =GPIO_PORTE_DEN_R   	
		LDR R0, [R1]                    
		;BIC R0, R0, #0x10               ; disable digital I/O on PE4
		BIC R0, R0, #0x20               ; disable digital I/O on PE5
		STR R0, [R1]    
	 			
; enable analog mode
		LDR R1, =GPIO_PORTE_AMSEL_R     
		LDR R0, [R1]                    
		;ORR R0, R0, #0x10    			; enable PE4 analog function
		ORR R0, R0, #0x20               ; enable PE5 analog function
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
		ADD R0, R0, #8					; set channel -> select input pin AIN9 (PE4), PE5 is AIN 8
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
		
Loop		
		LDR R1, =ADC0_PSSI_R      
		MOV R0, #0x08					; initiate sampling in the SS3  
		STR R0, [R1]    
		
		LDR R1, =ADC0_RIS_R   			; R1 = address of ADC Raw Interrupt Status
		LDR R0, [R1]           			; check end of a conversion, R0 is now the signal of interrupt
		CMP	R0, #0x08    				; when a sample has completed conversion -> a raw interrupt is enabled
		BNE	Loop    					; not equal means the conversion has not completed, go back and check again
		
		LDR R1, =ADC0_SSFIFO3_R			; load SS3 result FIFO into R1, the address of conversion result
		LDR R0,[R1]						; load to R0 (the temp variable)
		LDR R2, =Result					; store data to the address
		STR R0,[R2]
		
		B Control_loop      			; go to the LED control subroutine
		
Clear_status
		LDR R1, =ADC0_ISC_R				; interrupt status and clear
		LDR R0, [R1]
		ORR R0, R0, #08					; acknowledge conversion
		STR R0, [R1]
		
		B Loop


; ------------LED control----------

Control_loop
		LDR  R1, = 0x20000000               ; R1 is the address to read the value of pot
		LDR  R0, [R1]                       ; load the pot reading to R0
		CMP  R0, #0x40  				    ; compare with 1 V
		BNE  Red_On                         ; if smaller than 1 V, turn on Red
		
		CMP  R0, #0x90                      ; compare with 2 V
		BNE  Blue_On                        ; if larger than 1V, but smaller than 2 V, turn on blue
		
		CMP  R0, #0xE0                      ; compare with 3 V
		BNE  Green_On                       ; if smaller than 3V, larger than 2V, turn on green
		
		;BX  LR 



;------------Red_On------------
; Make PF1 (Red) high. PF2(blue), PF3 (Green) low
; Input: none
; Output: none
; Modifies: R0, R1
Red_On
		LDR R1, =PF1                    ; R1 = &PF1
		LDR R2, =PFGB					; R2 is green and blue
		MOV R0, #0x0E                   ; R0 = 0x04 (turn on the appliance)
		STR R0, [R1]                    ; [R1] = R0, write to PF1 (red)
		MOV R0, #0x00                   ; R0 = 0x00 (turn off the appliance)
		STR R0, [R2]					; turn off green blue
		
		B Clear_status
		;BX  LR                          ; return. bx stands for branch and exchange instruction set 
		;Which means that according to the 
		;lsb (least significant bit) of the address to branch to, 
		;the processor will treat the next instruction as ARM or as thumb.
	


;------------Blue_On------------
; Make PF1 (Red) low . PF2(blue) high, PF3 (Green) low
; Input: none
; Output: none
; Modifies: R0, R1
Blue_On
		LDR R1, =PF2                    ; R1 = &PF2
		LDR R2, =PFRG					; R2 is green and red
		MOV R0, #0x0E                   ; R0 = 0x04 (turn on the appliance)
		STR R0, [R1]                    ; [R1] = R0, write to PF1 (red)
		MOV R0, #0x00                   ; R0 = 0x00 (turn off the appliance)
		STR R0, [R2]					; turn off green blue
		
		B Clear_status
		;BX  LR                          ; return. bx stands for branch and exchange instruction set 
		;Which means that according to the 
		;lsb (least significant bit) of the address to branch to, 
		;the processor will treat the next instruction as ARM or as thumb.
		
	
;------------Green_On------------
; Make PF1 (Red) low . PF2(blue) low, PF3 (Green) high
; Input: none
; Output: none
; Modifies: R0, R1
Green_On
		LDR R1, =PF3                    ; R1 = &PF2
		LDR R2, =PFRB					; R2 is red and blue
		MOV R0, #0x0E                   ; R0 = 0x04 (turn on the appliance)
		STR R0, [R1]                    ; [R1] = R0, write to PF1 (red)
		MOV R0, #0x00                   ; R0 = 0x00 (turn off the appliance)
		STR R0, [R2]					; turn off green blue
		
		B Clear_status
		;BX  LR                          ; return. bx stands for branch and exchange instruction set 
		;Which means that according to the 
		;lsb (least significant bit) of the address to branch to, 
		;the processor will treat the next instruction as ARM or as thumb.




Delay									; Delay subroutine
		MOV R7,#0x0F
					
Countdown
		SUBS R7, #1						; subtract and set the flags based on the result
		BNE Countdown		 
		
		BX LR   						; return from subroutine

		ALIGN                			; make sure the end of this section is aligned
		END                  			; end of file

