List p=18f4520
    #INCLUDE <p18f4520.inc>
    CONFIG OSC = INTIO67
    CONFIG WDT = OFF
    org 0x00
    
    MOVLW 0xFE
    MOVWF 0x000
    
    MOVLW 0x06
    MOVWF 0x001
    MOVWF 0x030
    
    MOVLW 0x008
    MOVWF 0x010
    
    MOVLW 0x001
    MOVWF 0x011
    
    LOOP:
    BTFSC 0x001 , 0
    GOTO NOT_ZERO
    GOTO ZERO
    
    NOT_ZERO:
    MOVF 0x011 , W
    MOVWF 0x012 ; counter for rotate
    MOVF 0x000 , W
    MOVWF 0x003
    ROTATE:
    DCFSNZ  0x012
    GOTO FINISH_ROTATE
    BCF STATUS, C
    RLCF 0x003
    GOTO ROTATE
    
    FINISH_ROTATE:
    MOVF 0x003 , W
    ADDWF 0x002
    INCF 0x011
    BCF STATUS, C
    RRCF 0x001
    DECFSZ 0x010
    GOTO LOOP
    GOTO CLEAR
    
    ZERO:
    INCF 0x011
    BCF STATUS, C
    RRCF 0x001
    DECFSZ 0x010
    GOTO LOOP
    GOTO CLEAR
    
    CLEAR:
    MOVF 0x030, W 
    MOVWF 0x001
    CLRF 0x030
    CLRF 0x010
    CLRF 0x011
    CLRF 0x003
    FINISH:
    GOTO FINISH
    
    end


