#include "xc.inc"
GLOBAL _is_prime
PSECT mytext, local, class=CODE, reloc=2
 
_is_prime:
    MOVWF 0x001
    MOVWF 0x010
    MOVWF 0x040
    DECF 0x040
    CHECK_IF_EVEN:
    BTFSS 0x001 , 0
    GOTO EVEN
    GOTO CHECK_ONE
    
    CHECK_ONE:
    MOVLW 0x001
    CPFSEQ 0x001
    GOTO CHECK_PRIME
    GOTO NOT_PRIME
    
    CHECK_PRIME:
    MOVLW 0x02
    MOVWF 0x011
    MOVWF 0x020
    DIV:
    RCALL division
    MOVLW 0x00
    BTFSS 0x030 , 0 
    GOTO NOT_SET
    GOTO NOT_PRIME
    NOT_SET:
    MOVF 0x040 , W
    CPFSEQ 0x020
    GOTO CONT
    GOTO PRIME
    CONT:
    INCF 0x020
    MOVFF 0x020 , 0x011
    MOVFF 0x001 , 0x010
    CLRF 0x012
    GOTO DIV
    
    EVEN:
    MOVLW 0x002
    CPFSEQ 0x001
    GOTO NOT_PRIME
    GOTO PRIME
    
    NOT_PRIME:
    MOVLW 0xFF
    RETURN
    
    PRIME:
    MOVLW 0x01	
    RETURN     
    
    division:
    ; COMPUTE 2'S
    NEGF 0x011
    
    CHECK_HIGH:
    MOVF 0x020, W
    CPFSGT 0x010 ; skip if 0x010 > 0x020
    GOTO CHECK_IF_HIGH_EQUAL
    
    TWO_COM:
    ; 2's addition
    MOVF 0x011, W
    ADDWF 0x010, F
    INCF 0x012
    GOTO CHECK_HIGH
    
    CHECK_IF_HIGH_EQUAL:
    MOVF 0x010, W
    CPFSEQ 0x020 ; skip if 0x001 = 0x031
    GOTO CLEAN
    GOTO CHECK_IF_HIGH_ZERO
    
    CHECK_IF_HIGH_ZERO:
    MOVLW 0x000
    CPFSEQ 0x010
    GOTO TWO_COM
    GOTO CLEAN
    
    CLEAN:
    MOVLW 0x000
    CPFSEQ 0x010
    RETURN
    INCF 0x030
    RETURN



