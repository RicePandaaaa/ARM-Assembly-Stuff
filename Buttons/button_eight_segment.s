		area SwitchEightSegment, code, readonly
			
			
; Rename the registers			
PORT_3_ADDRESS RN r0
PORT_4_ADDRESS RN r1
PORT_5_ADDRESS RN r2
PORT_6_ADDRESS RN r3
TEMP_REGISTER  RN r4
CURRENT_OUTPUT RN r5
COUNTER        RN r8
ALREADY_ON     RN r9

; Name important constants
OUTPUT_OFFSET  EQU 0x02
DDIR_OFFSET    EQU 0x04
REN_OFFSET     EQU 0x06
	
PORT_3_DDIR    EQU 0xE0
PORT_4_DDIR    EQU 0xA0
PORT_5_DDIR    EQU 0x70
PORT_6_DDIR    EQU 0xFE
	
BUTTON_ON      EQU 0x01
BUTTON_OFF     EQU 0x00
	
; Define subroutine arguments
TARGET_ADDRESS RN r6
PIN_NUM        RN r7


		export __main
__main  proc
	
		; Set up the base addresses ; 
		LDR PORT_3_ADDRESS, =0x40004C20
		LDR PORT_4_ADDRESS, =0x40004C21
		LDR PORT_5_ADDRESS, =0x40004C40
		LDR PORT_6_ADDRESS, =0x40004C41
		
		; Set up the GPIO
		; Input: 6.0
		; Output: 4.5, 4.7, 5.4, 5.5
		; Output: 3.6, 5.6, 3.5, 3.7
		MOV TEMP_REGISTER, #PORT_3_DDIR
		STRB TEMP_REGISTER, [PORT_3_ADDRESS, #DDIR_OFFSET]
		
		MOV TEMP_REGISTER, #PORT_4_DDIR
		STRB TEMP_REGISTER, [PORT_4_ADDRESS, #DDIR_OFFSET]
		
		MOV TEMP_REGISTER, #PORT_5_DDIR
		STRB TEMP_REGISTER, [PORT_5_ADDRESS, #DDIR_OFFSET]
		
		MOV TEMP_REGISTER, #PORT_6_DDIR
		STRB TEMP_REGISTER, [PORT_6_ADDRESS, #DDIR_OFFSET]
		
		; Turn off the LEDS, set counter
		BL ALL_OFF
		MOV COUNTER, #0x00
		
		; Set up pull down resistor
		MOV TEMP_REGISTER, #0x01
		STRB TEMP_REGISTER, [PORT_6_ADDRESS, #REN_OFFSET]
		MOV TEMP_REGISTER, #0x00
		STRB TEMP_REGISTER, [PORT_6_ADDRESS, #OUTPUT_OFFSET]
		
		; Check if button is off
IF_OFF  LDRB TEMP_REGISTER, [PORT_6_ADDRESS]
        CMP TEMP_REGISTER, #0x00
		BEQ TURNOFF
		
		; If here, button is on, check if it's been on
TURNON	CMP ALREADY_ON, #0x01
        BEQ IF_OFF

		BL SET_NUM
        CMP COUNTER, #0x09
        BEQ RESET
        ADD COUNTER, #0x01
        B IF_OFF
		
RESET   MOV COUNTER, #0x00
		B IF_OFF
		
TURNOFF BL ALL_OFF
        MOV ALREADY_ON, #0x00
        B IF_OFF
		endp
			
		; Function to turn the LEDs off
ALL_OFF function
		MOV TEMP_REGISTER, #0x00
		STRB TEMP_REGISTER, [PORT_3_ADDRESS, #OUTPUT_OFFSET]
		STRB TEMP_REGISTER, [PORT_4_ADDRESS, #OUTPUT_OFFSET]
		STRB TEMP_REGISTER, [PORT_5_ADDRESS, #OUTPUT_OFFSET]
		BX LR
		endp
			
			
		
		; Function to turn a segment on the 8-segment lED on
SEG_ON  function
		LDRB CURRENT_OUTPUT, [TARGET_ADDRESS, #OUTPUT_OFFSET]
	    ORR TEMP_REGISTER, CURRENT_OUTPUT, PIN_NUM
		STRB TEMP_REGISTER, [TARGET_ADDRESS, #OUTPUT_OFFSET]
		BX LR
	    endp
			
		; Function to turn on A-segment
SET_A   function
	    MOV TARGET_ADDRESS, PORT_3_ADDRESS
		MOV PIN_NUM, #0x30
		PUSH {LR}
		BL SEG_ON
		POP {LR}
		BX LR
		endp
			
		; Function to turn on B-segment
SET_B   function
	    MOV TARGET_ADDRESS, PORT_3_ADDRESS
		MOV PIN_NUM, #0x80
		PUSH {LR}
		BL SEG_ON
		POP {LR}
		BX LR
		endp

		; Function to turn on C-segment
SET_C   function
	    MOV TARGET_ADDRESS, PORT_5_ADDRESS
		MOV PIN_NUM, #0x10
		PUSH {LR}
		BL SEG_ON
		POP {LR}
		BX LR
		endp
			
		; Function tovturn on D-segment
SET_D   function
	    MOV TARGET_ADDRESS, PORT_4_ADDRESS
		MOV PIN_NUM, #0x80
		PUSH {LR}
		BL SEG_ON
		POP {LR}
		BX LR
		endp
			
		; Function to turn on E-segment
SET_E   function
	    MOV TARGET_ADDRESS, PORT_4_ADDRESS
		MOV PIN_NUM, #0x20
		PUSH {LR}
		BL SEG_ON
		POP {LR}
		BX LR
		endp
			
		; Function to turn on F-segment
SET_F   function
	    MOV TARGET_ADDRESS, PORT_5_ADDRESS
		MOV PIN_NUM, #0x40
		PUSH {LR}
		BL SEG_ON
		POP {LR}
		BX LR
		endp
			
		; Function to turn on G-segment
SET_G   function
	    MOV TARGET_ADDRESS, PORT_3_ADDRESS
		MOV PIN_NUM, #0x40
		PUSH {LR}
		BL SEG_ON
		POP {LR}
		BX LR
		endp
			
        ;Function to display "0"
ZERO    function
	    PUSH {LR}
		BL SET_A
		BL SET_B
		BL SET_C
		BL SET_D
		BL SET_E
		BL SET_F
		POP {LR}
		BX LR
		endp
			
        ;Function to display "1"
ONE     function
	    PUSH {LR}
		BL SET_B
		BL SET_C
		POP {LR}
		BX LR
		endp
			
        ;Function to display "2"
TWO     function
	    PUSH {LR}
		BL SET_A
		BL SET_B
		BL SET_G
		BL SET_E
		BL SET_D
		POP {LR}
		BX LR
		endp
			
        ;Function to display "3"
THREE   function
	    PUSH {LR}
		BL SET_A
		BL SET_B
		BL SET_G
		BL SET_C
		BL SET_D
		POP {LR}
		BX LR
		endp
			
        ;Function to display "4"
FOUR    function
	    PUSH {LR}
		BL SET_F
		BL SET_G
		BL SET_B
		BL SET_C
		POP {LR}
		BX LR
		endp
			
        ;Function to display "5"
FIVE    function
	    PUSH {LR}
		BL SET_A
		BL SET_F
		BL SET_G
		BL SET_C
		BL SET_D
		POP {LR}
		BX LR
		endp
		
        ;Function to display "6"
SIX     function
	    PUSH {LR}
		BL SET_A
        BL SET_E
		BL SET_F
		BL SET_G
		BL SET_C
		BL SET_D
		POP {LR}
		BX LR
		endp
			
        ;Function to display "7"
SEVEN   function
	    PUSH {LR}
		BL SET_A
		BL SET_B
		BL SET_C
		POP {LR}
		BX LR
		endp
			
        ;Function to display "8"
EIGHT   function
	    PUSH {LR}
		BL SET_A
		BL SET_B
		BL SET_C
		BL SET_D
		BL SET_E
		BL SET_F
		BL SET_G
		POP {LR}
		BX LR
		endp
			
        ;Function to display "9"
NINE    function
	    PUSH {LR}
		BL SET_A
		BL SET_B
		BL SET_C
		BL SET_D
		BL SET_F
		BL SET_G
		POP {LR}
		BX LR
		endp
			
        ; Function to set the correct number
SET_NUM function
	PUSH {LR}
	    MOV ALREADY_ON, #0x01
		CMP COUNTER, #0x00
		BNE IS_ONE
		BL ZERO
		POP {LR}
		BX LR
		
IS_ONE  CMP COUNTER, #0x01
		BNE IS_TWO
		BL ONE
		POP {LR}
		BX LR

IS_TWO  CMP COUNTER, #0x02
		BNE IS_THR
		BL TWO
		POP {LR}
		BX LR
		
IS_THR  CMP COUNTER, #0x03
		BNE IS_FOUR
		BL THREE
		POP {LR}
		BX LR
		
IS_FOUR CMP COUNTER, #0x04
		BNE IS_FIVE
		BL FOUR
		POP {LR}
		BX LR
		
IS_FIVE CMP COUNTER, #0x05
		BNE IS_SIX
		BL FIVE
		POP {LR}
		BX LR
		
IS_SIX  CMP COUNTER, #0x06
		BNE IS_SEV
		BL SIX
		POP {LR}
		BX LR
		
IS_SEV  CMP COUNTER, #0x07
		BNE IS_EIG
		BL SEVEN
		POP {LR}
		BX LR
		
IS_EIG  CMP COUNTER, #0x08
		BNE IS_NINE
		BL EIGHT
		POP {LR}
		BX LR
		
IS_NINE CMP COUNTER, #0x09
		BL NINE
		POP {LR}
		BX LR
	
		endp
			
		end
