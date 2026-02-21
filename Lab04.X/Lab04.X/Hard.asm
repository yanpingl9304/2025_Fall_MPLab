List p=18f4520
    #INCLUDE <p18f4520.inc>
    CONFIG OSC = INTIO67
    CONFIG WDT = OFF
    org 0x00
    
    ;
    ; Xn+1 = (Xn + N / Xn) / 2
    ; N = 0x020 and 0x021  = 0040 
    ; X =  0x022 and 0x023 = 0078
    ; ans = 0x24 and 0x025 = 0008
    ; X_old = 0x030 0x031
    ; quotient = 0x010 0x011
    ;
    ;dividend
    MOVLW 0x00
    MOVWF 0x020
    MOVWF 0x040

    MOVLW 0x51
    MOVWF 0x021
    MOVWF 0x041
    
    ;divisor
    MOVLW 0x00
    MOVWF 0x022
    MOVWF 0x050
    
    MOVLW 0x14
    MOVWF 0x023
    MOVWF 0x051
    
    RCALL newtonSqrt
    
    GOTO FINISH
    
    division:
    ;======
    ; compute 2's 
    ;======
    NEGF 0x022
    DECF 0x022
    NEGF 0x023
    
    MOVLW 0x001
    ANDWF STATUS , W
    ADDWF 0x022
    
    CHECK_HIGH:
    MOVF 0x030, W
    CPFSGT 0x020 ; skip if 0x020 > 0x030
    GOTO CHECK_IF_HIGH_EQUAL
    TWO_COM:
    MOVF    0x023, W
    ADDWF   0x021, F
    MOVF    0x022, W
    ADDWFC  0x020, F
    
    INCF 0x011
    MOVLW 0x000
    ADDWFC 0x010, F
    
    GOTO CHECK_HIGH
    HIGH_LESS:
    MOVF 0x031, W
    CPFSGT 0x021 ; skip if 0x021 > 0x031
    GOTO CHECK_IF_LOW_EQUAL
    GOTO TWO_COM
    
    CHECK_IF_LOW_EQUAL:
    MOVF 0x031, W
    CPFSEQ 0x021 ; skip if 0x021 = 0x031
    GOTO CLEAN
    GOTO TWO_COM
    
    CHECK_IF_HIGH_EQUAL:
    MOVF 0x030, W
    CPFSEQ 0x020 ; skip if 0x020 = 0x030
    GOTO CLEAN
    GOTO CHECK_IF_HIGH_ZERO
    
    CHECK_IF_HIGH_ZERO:
    MOVLW 0x000
    CPFSEQ 0x020
    GOTO TWO_COM
    GOTO HIGH_LESS
    
    CLEAN:
    MOVFF 0x030 , 0x022 
    MOVFF 0x031 , 0x023
    MOVFF 0x040 , 0x020
    MOVFF 0x041 , 0x021
    RETURN
    
    add_xn:
    BCF STATUS, C
    MOVF 0x031 , W 
    ADDWF 0x011 , F
    MOVF 0x030 , W 
    ADDWFC 0x010 , F
    RETURN
    
    divide_2:
    BCF STATUS, C
    RRCF 0x010
    RRCF 0x011
    RETURN
    
    check_complete:
    MOVF 0x010, W 
    CPFSEQ 0x030
    RETURN
    CHECK_LOW:
    MOVF 0x011, W 
    CPFSEQ 0x031
    RETURN
    MOVLW 0x001
    MOVWF 0x000
    RETURN
    
    newtonSqrt:
    newton_start:
    MOVFF 0x022, 0x030
    MOVFF 0x023, 0x031 
    RCALL division
    RCALL add_xn
    RCALL divide_2 ; done compute x_new
    RCALL check_complete
    MOVFF 0x010 , 0x022
    CLRF 0x010
    MOVFF 0x011 , 0x023
    CLRF 0x011
    BTFSS 0x000 , 0
    GOTO newton_start 
    MOVFF 0x030 , 0x024
    MOVFF 0x031 , 0x025
    MOVFF 0x050 , 0x022
    MOVFF 0x051 , 0x023
    
    CLRF 0x000
    CLRF 0x030
    CLRF 0x031
    CLRF 0x040
    CLRF 0x041
    CLRF 0x050
    CLRF 0x051
    
    RETURN

    FINISH:
    GOTO FINISH
    
    end





