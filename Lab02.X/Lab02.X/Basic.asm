List p=18f4520
    #INCLUDE <p18f4520.inc>
    CONFIG OSC = INTIO67
    CONFIG WDT = OFF
    org 0x00
    
    LFSR 0 , 0x120
    MOVLW 0x0FE ; input
    MOVWF INDF0
    
    LFSR 1 , 0x121
    MOVLW 0x0EE ; input
    MOVWF INDF1
    
    LFSR 2 , 0x122
    
    MOVLW 0x006
    MOVWF 0x000 ; counter
    
    STEP_ONE:
    DCFSNZ 0x000
    GOTO FINISH
    
    
    ; STEP_TWO
    BTFSS FSR2L , 0 ; Skip if lsb = 1
    GOTO EVEN
    
    ODD:
    MOVF POSTINC0 , W
    MOVWF INDF2
    MOVF POSTINC1 , W
    SUBWF POSTINC2
    GOTO STEP_ONE
    
    EVEN:
    MOVF POSTINC0 , W
    MOVWF INDF2
    MOVF POSTINC1 , W
    ADDWF POSTINC2
    GOTO STEP_ONE
    
    FINISH:
    GOTO FINISH
    
    end


