		area SensorTest, code, readonly
			
DETECTED_ON  EQU 0xEE
DETECTED_OFF EQU 0xDE
RED_ON       EQU 0x10
GREEN_ON     EQU 0x20
	
PORT_ADDRESS   RN r0
OUTPUT_BITS    RN r1
INPUT_STATUS   RN r2
	
		    export __main
__main  proc
	
	    	; Configure GPIO
		    LDR PORT_ADDRESS, =0x40004C00   ; Port 1 Base Address
		    ADD PORT_ADDRESS, #0x41            ; PO
		    MOV OUTPUT_BITS, #0x30          ; Byte to configure pins 0 as input, 4 and 5 as output
		    STRB OUTPUT_BITS, [PORT_ADDRESS, #0x04]   ; Configure pins 6.0 as input, 6.4 and 6.5 as output
		
		    ; If the green light is on, don't toggle red on
start	  LDRB INPUT_STATUS, [PORT_ADDRESS]
        CMP INPUT_STATUS, #DETECTED_ON
        BEQ lightOn
		
		    ; Set green LED to off, red LED to on
check	  MOV OUTPUT_BITS, #RED_ON
		    STRB OUTPUT_BITS, [PORT_ADDRESS, #0x02]
		
		    ; Check sensor status
sensor  LDRB INPUT_STATUS, [PORT_ADDRESS]
		    CMP INPUT_STATUS, #DETECTED_OFF
		    BNE check
		
		    ; Set LED to on
lightOn MOV OUTPUT_BITS, #GREEN_ON
		    STRB OUTPUT_BITS, [PORT_ADDRESS, #0x02]
		
		    B start

		    endp

		    end
