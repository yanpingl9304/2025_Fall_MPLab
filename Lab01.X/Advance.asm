List p=18f4520
    #include<p18f4520.inc>
        CONFIG OSC = INTIO67
        CONFIG WDT = OFF
        org 0x00
	
	; counter = 9
	MOVLW 0x009
	MOVWF 0x002
	
	; input
	MOVLW b'00000000'
	MOVWF 0x000
	MOVWF 0x001
		
	LOOP:
	BTFSC 0x000 , 7 ; if msb == 0 skipped next
	GOTO FINISH
	DCFSNZ 0x002    ; counter-- if counter == 0 goto FINISH
	GOTO FINISH
	INCF 0x010       ; result++
	RLNCF 0x000     ; move left 
	GOTO LOOP    
	
	; put input back to 0x000
	MOVF 0x001 , W
	MOVWF 0x000
	GOTO FINISH
    
        FINISH:
    	CLRF 0x001   ; clear 0x001 temp
	CLRF 0x002   ; clear 0x002 counter
	GOTO FINISH
	
	end    
	

