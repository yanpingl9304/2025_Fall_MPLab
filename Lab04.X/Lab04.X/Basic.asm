List p=18f4520
    #INCLUDE <p18f4520.inc>
    CONFIG OSC = INTIO67
    CONFIG WDT = OFF
    org 0x00
    
    And_Mul macro xh, xl, yh, yl
	; AND
	MOVF xh , W
	ANDWF yh , W
	MOVWF 0x000
	MOVF xl , W
	ANDWF yl , W
	MOVWF 0x001
	
	; MUL
	MOVF 0x000, W
	MULWF 0x001
	MOVF PRODL ,W 
	MOVWF 0x011
	MOVF PRODH ,W
	MOVWF 0x010
    endm
	
    MOVLW 0x0A
    MOVWF 0x002

    MOVLW 0x0A
    MOVWF 0x003
    
    MOVLW 0x0A
    MOVWF 0x004
    
    MOVLW 0x0A
    MOVWF 0x005
    
    And_Mul 0x002, 0x003, 0x004, 0x005

    end