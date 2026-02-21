List p=18f4520
    #INCLUDE <p18f4520.inc>
    CONFIG OSC = INTIO67
    CONFIG WDT = OFF
    org 0x00
    
    MOVLW 0x74
    MOVWF 0x000
    
    MOVLW 0x58
    MOVWF 0x001
    
    MOVLW 0x40
    MOVWF 0x010
    MOVWF 0x030
    
    MOVLW 0x46
    MOVWF 0x011
    MOVWF 0x031
    
    NEGF 0x010
    DECF 0x010
    NEGF 0x011
    
    ; check carry
    MOVLW 0x001
    ANDWF STATUS , W
    ADDWF 0x010
    
    MOVF 0x001 , W
    MOVWF 0x021
    MOVF 0x011 , W
    ADDWF 0x021
    
    MOVLW 0x001
    ANDWF STATUS , W
    MOVWF 0x020
    
    MOVF 0x000 , W 
    ADDWF 0x020
    MOVF 0x010 , W 
    ADDWF 0x020
    
    MOVF 0x030 ,  W
    MOVWF 0x010
    
    MOVF 0x031 ,  W
    MOVWF 0x011
    
    CLRF 0x030
    CLRF 0x031
    
    end


