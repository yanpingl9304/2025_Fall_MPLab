List p=18f4520
    #INCLUDE <p18f4520.inc>
    CONFIG OSC = INTIO67
    CONFIG WDT = OFF
    org 0x00
    
    MOVLW 0x01
    MOVWF 0x000
    MOVWF 0x040

    MOVLW 0xf4
    MOVWF 0x001
    MOVWF 0x041
    
    MOVLW 0x00
    MOVWF 0x002
    MOVWF 0x030
    
    MOVLW 0x22
    MOVWF 0x003
    MOVWF 0x031
    
    RCALL division
    
    GOTO FINISH
    
    division:
    ; COMPUTE 2'S
    NEGF 0x002
    DECF 0x002
    NEGF 0x003
    
    ; check carry
    MOVLW 0x001
    ANDWF STATUS , W
    ADDWF 0x002
    
    CHECK_HIGH:
    MOVF 0x030, W
    CPFSGT 0x000 ; skip if 0x000 > 0x030
    GOTO CHECK_IF_HIGH_EQUAL
    
    TWO_COM:
    ; 2's addition
    MOVF 0x003, W
    ADDWF 0x001, F
    MOVF 0x002, W
    ADDWFC 0x000, F
    INCF 0x011
    MOVLW 0x000
    ADDWFC 0x010, F
    GOTO CHECK_HIGH
    
    HIGH_LESS:
    MOVF 0x031, W
    CPFSGT 0x001 ; skip if 0x001 > 0x031
    GOTO CHECK_IF_LOW_EQUAL
    GOTO TWO_COM
    
    CHECK_IF_LOW_EQUAL:
    MOVF 0x031, W
    CPFSEQ 0x001 ; skip if 0x001 = 0x031
    GOTO CLEAN
    GOTO TWO_COM
    
    CHECK_IF_HIGH_EQUAL:
    MOVF 0x030, W
    CPFSEQ 0x000 ; skip if 0x001 = 0x031
    GOTO CLEAN
    GOTO CHECK_IF_HIGH_ZERO
    
    CHECK_IF_HIGH_ZERO:
    MOVLW 0x000
    CPFSEQ 0x000
    GOTO TWO_COM
    GOTO HIGH_LESS
    
    CLEAN:
    MOVFF 0x000 , 0x012
    MOVFF 0x001 , 0x013
    
    MOVFF 0x030 , 0x002
    MOVFF 0x031 , 0x003
    
    MOVFF 0x040 , 0x000
    MOVFF 0x041 , 0x001
    
    CLRF 0x030
    CLRF 0x031
    CLRF 0x040
    CLRF 0x041
    RETURN
    
    FINISH:
    GOTO FINISH
    
    end


