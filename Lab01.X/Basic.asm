List p=18f4520
    #include<p18f4520.inc>
        CONFIG OSC = INTIO67
        CONFIG WDT = OFF
        org 0x00

	; put x1 into 0x000 and 0x010
	MOVLW 0x2D  ; value
	MOVWF 0x000 
	MOVWF 0x010
	
	; put x2 into 0x001 and x1 + x2 = A1
	MOVLW 0x4D  ; value 
	ADDWF 0x010 
	MOVWF 0x001 
	
	; put y1 into 0x002 and 0x011
	MOVLW 0xFF  ; value
	MOVWF 0x011 
	MOVWF 0x002 
	
	; put y2 into 0x003 and y1 - y2 = A1
	MOVLW 0x11
	SUBWF 0x011 
	MOVWF 0x003
	
	MOVF 0x011, W     ; load A2 to WREG 
	CPFSGT 0x010      ; if A1 < A2 goto LESS 
	GOTO LESS    

	MOVLW 0xFF       ; load 0xFF to WREG    
	MOVWF 0x020      ; save into 0x020    
	GOTO FINISH       

	LESS:
	MOVLW 0x01       ; load 0x01 to WREG    
	MOVWF 0x020      ; save into 0x020

	FINISH:
    
	end


