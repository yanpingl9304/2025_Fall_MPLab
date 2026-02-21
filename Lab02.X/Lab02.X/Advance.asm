List p=18f4520
    #INCLUDE <p18f4520.inc>
    CONFIG OSC = INTIO67
    CONFIG WDT = OFF
    org 0x00
    
    ; Seq A 
    LFSR 0 , 0x205
    MOVLW 0x050 ; input [0x205]
    MOVWF POSTDEC0
    
    MOVLW 0x040 ; input [0x204]
    MOVWF POSTDEC0
    
    MOVLW 0x030 ; input [0x203]
    MOVWF POSTDEC0
    
    MOVLW 0x020 ; input [0x202]
    MOVWF POSTDEC0
    
    MOVLW 0x000 ; input [0x201]
    MOVWF POSTDEC0
    
    MOVLW 0x000 ; input [0x200]
    MOVWF POSTDEC0
    
    ; Seq B
    LFSR 1 , 0x214
    MOVLW 0x070 ; input [0x214]
    MOVWF POSTDEC1
    
    MOVLW 0x060 ; input [0x213]
    MOVWF POSTDEC1
    
    MOVLW 0x030 ; input [0x212]
    MOVWF POSTDEC1
    
    MOVLW 0x000 ; input [0x211]
    MOVWF POSTDEC1
    
    MOVLW 0x000 ; input [0x210]
    MOVWF POSTDEC1
    
    
    LFSR 0 , 0x200
    LFSR 1 , 0x210
    LFSR 2 , 0x220
    
    MERGE: 
    MOVLW 0x006
    CPFSLT FSR0L ; skip if 0L < 0x006
    GOTO FILL_B
    MOVLW 0x015
    CPFSLT FSR1L ; skip if 1L < 0x015
    GOTO FILL_A
    GOTO COMPARE
    
    COMPARE:
    MOVF INDF0 , W
    CPFSEQ INDF1 ; skip if b = a
    GOTO A_NOT_EQUAL_B
    ; if a == b , then store a 
    MOVF POSTINC0 , W
    MOVWF POSTINC2
    GOTO MERGE
    
    A_NOT_EQUAL_B:
    CPFSGT INDF1 ; skip if b > a ; b > a store a ; b < a store b
    GOTO STORE_B
     
    STORE_A:
    MOVF POSTINC0 , W
    MOVWF POSTINC2
    GOTO MERGE
        
    STORE_B:
    MOVF POSTINC1 , W
    MOVWF POSTINC2
    GOTO MERGE
    
    FILL_A:
    MOVLW 0x006
    CPFSLT FSR0L ; skip if 0L > 0x006
    GOTO FINISH
    MOVF POSTINC0 , W
    MOVWF POSTINC2
    GOTO FILL_A
    
    FILL_B:
    MOVLW 0x015
    CPFSLT FSR1L ; skip if 0L < 0x006
    GOTO FINISH
    MOVF POSTINC1 , W
    MOVWF POSTINC2
    GOTO FILL_B
    
    FINISH:
    GOTO FINISH
    
    end