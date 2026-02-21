List p=18f4520
    #INCLUDE <p18f4520.inc>
    CONFIG OSC = INTIO67
    CONFIG WDT = OFF
    org 0x00
    
    MOVLW 0xA9
    MOVWF 0x0F0
    
    MOVLW 0xCD
    MOVWF 0x0F1
    
    MOVLW 0xED
    MOVWF 0x0F2

    MOVLW 0xF0
    MOVWF 0x0F3
    
    MOVLW 0xF1
    MOVWF 0x0F4
    
    MOVLW 0xED
    MOVWF 0x0F5
    
    MOVLW 0xCB
    MOVWF 0x0F6
    
    MOVLW 0xA9
    MOVWF 0x0F7
    
    LFSR 0 , 0x0F0
    MOVLW 0x009
    MOVWF 0x001 ; counter
    
    MOVLW 0x004
    MOVWF 0x00F
    
    ; use the input as index of the table
    COUNTING:
    DCFSNZ 0x001;
    GOTO FINSIH_COUNTING
    LFSR 1 , 0x0400
    MOVF POSTINC0 ,W          
    ADDWF FSR1L
    INCF INDF1
    GOTO COUNTING
    
    FINSIH_COUNTING: 
    ; check the table 
    MOVLW 0x0FF
    MOVWF 0x001
    LFSR 1 , 0x0400
    
    ; check idx = FF
    ADDWF FSR1L
    BTFSC INDF1 , 0 ; skip if lsb == 0
    GOTO CHECK_VALID
    MOVLW 0x001
    CPFSLT INDF1 ; INDF1 < 1 skip
    GOTO DIAGONAL
    
    CHECK_VALID:
    LFSR 1 , 0x0400
    DCFSNZ 0x001
    GOTO CHECK_0x400
    MOVF 0x001 , W
    ADDWF FSR1L
    MOVLW 0x001
    CPFSLT INDF1 ; if lsb < 1 skip
    GOTO CHECK_SWAP
    GOTO CHECK_VALID
    
    CHECK_SWAP:
    MOVF 0x001 , W
    MOVWF 0x030 
    SWAPF 0x030
    CPFSEQ 0x030 ; if input = reverse_input
    GOTO NOT_DIAGONAL
    GOTO DIAGONAL
    
    NOT_DIAGONAL:
    MOVF INDF1, W
    MOVWF 0x040 
    LFSR 1 , 0x0400
    MOVF 0x030 , W
    ADDWF FSR1L
    MOVF INDF1 , W
    CPFSEQ 0x040
    GOTO NOT_PAL
    GOTO CHECK_VALID
    
    DIAGONAL: ; number must be even
    BTFSC INDF1 , 0 ; skip if lsb = 0
    GOTO NOT_PAL
    GOTO CHECK_VALID
    
    NOT_PAL:
    MOVLW 0x009
    MOVWF 0x001
    LFSR 1 , 0x320
    
    STORE_FF:
    DCFSNZ 0x001
    GOTO FINISH
    MOVLW 0xFF
    MOVWF POSTINC1
    GOTO STORE_FF
    
    CHECK_0x400:
    LFSR 1 , 0x0400
    MOVLW 0x000
    CPFSEQ INDF1
    GOTO EVEN_NOT_ZERO
    GOTO INIT
    
    EVEN_NOT_ZERO:
    MOVF INDF1 , W
    MOVWF 0x003
    RRNCF 0x003
    MOVF 0x003 , W
    SUBWF 0x00F
    LFSR 1 , 0x327
    LFSR 2 ,0x320
    FILL_ZERO:
    MOVLW 0x000
    MOVWF POSTINC2
    MOVWF POSTDEC1
    DCFSNZ 0x003
    GOTO PAL
    GOTO FILL_ZERO
    
    INIT:
    LFSR 1 , 0x327
    LFSR 2 ,0x320
    
    PAL:
    MOVLW 0x009
    MOVWF 0x001
    LFSR 0 , 0x0F0
    MOVF INDF0 , W
    CPFSEQ 0x000
    GOTO FIND_SMALLEST
    GOTO FIND_FIRST_NONZERO
    
    ;find the smallest element store into 0x320 and swap nibblee store into 0x327
    ; while W == 0 contiune to find the fist nonzero element
    FIND_FIRST_NONZERO:
    INCF FSR0L
    MOVF INDF0 , W
    CPFSEQ 0x000 ; w == 0
    GOTO FIND_SMALLEST_INIT
    GOTO FIND_FIRST_NONZERO
    
    FIND_SMALLEST_INIT:
    LFSR 0 , 0x0F0
    FIND_SMALLEST:
    DCFSNZ 0x001
    GOTO FINISH_FIND_SMALLEST
    MOVWF 0x003 ; w = 0x003
    MOVLW 0x000
    CPFSEQ INDF0 ; if indf0 == 0 ; element is zero skip
    GOTO NOT_ZERO
    INCF FSR0L
    MOVF 0x003 , W
    GOTO FIND_SMALLEST
    
    NOT_ZERO:
    MOVF 0x003 ,W 
    CPFSGT INDF0 ; skip if postinc0 > w
    MOVF INDF0 , W
    INCF FSR0L
    GOTO FIND_SMALLEST
    
    FINISH_FIND_SMALLEST:
    LFSR 0 , 0x0F0
    MOVWF INDF1
    SWAPF INDF1
    MOVWF INDF2
    
    ; set used element as 0
    MOVF INDF0 , W
    CPFSEQ  INDF2
    GOTO FIND_SMALLEST_ADDR
    GOTO FINDED_SMALLEST_ADDR
    FIND_SMALLEST_ADDR:
    INCF FSR0L
    MOVF INDF0 , W
    CPFSEQ  INDF2 ; find smallest location skip
    GOTO FIND_SMALLEST_ADDR
    
    FINDED_SMALLEST_ADDR:
    CLRF INDF0
    INCF FSR2L
    
    LFSR 0 , 0x0F0
    MOVF INDF0 , W
    CPFSEQ  INDF1
    GOTO RE_FIND_SMALLEST_ADDR
    GOTO RE_FINDED_SMALLEST_ADDR
    RE_FIND_SMALLEST_ADDR:
    INCF FSR0L
    MOVF INDF0 , W
    CPFSEQ  INDF1 ; find smallest location skip
    GOTO RE_FIND_SMALLEST_ADDR
    
    RE_FINDED_SMALLEST_ADDR:
    CLRF INDF0
    DECF FSR1L
    
    DCFSNZ 0x00F
    GOTO FINISH
    GOTO PAL
    
    FINISH:
    GOTO FINISH
    
    
    end


