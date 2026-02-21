List p=18f4520
    #include<p18f4520.inc>
        CONFIG OSC = INTIO67
        CONFIG WDT = OFF
        org 0x00
	
	; input
	MOVLW b'01010101' ; x
	MOVWF 0x000  
	MOVWF 0x001 ; save input
	
	;Step 1
	;   c = (x < 0x10);
	MOVLW 0x001 
	MOVWF 0x002 ; c = 1
	MOVLW 0x010 ; W = 0x010 value
	CPFSLT 0x000 ; skip if x < W 
	DECF 0x002   ; c = 0
	
	;   c *= 4;
	MOVLW 0x004 ; w = 4
	MULWF 0x002 ; c * 4
	MOVF PRODL , W 
	MOVWF 0x002
	
	;   r += c;
	ADDWF 0x010
	MOVWF 0x010
	
	;   x <<= c;
	MOVF 0x002 , W ;  W = c 
	CPFSEQ 0x003 ; skip if c = 0
	MOVLW 0x004 ; w = 4
	MULWF 0x002 ; c * 4
	CPFSEQ 0x003 ; skip if w = 0
	MOVF PRODL , W 
	CPFSEQ 0x003 ; skip if w = 0
	MULWF 0x000 ; x << c
	CPFSEQ 0x003 ; skip if w = 0
	MOVF PRODL , W
	CPFSEQ 0x003 ; skip if w = 0
	MOVWF 0x000

	
	; Step 2
	;    c = (x < 0x40);
	MOVLW 0x001 
	MOVWF 0x002 ; c = 1
	MOVLW 0x040 ; W = 0x040 value
	CPFSLT 0x000 ; skip if x < W 
	DECF 0x002 
	
	;    c *= 2;
	MOVLW 0x002 ; w = 2
	MULWF 0x002 ; c *= 2
	MOVF PRODL , W 
	MOVWF 0x002 
	
	;    r += c
	ADDWF 0x010
	
	;    x <<= c;
	MOVF 0x002 , W ;  W = c 
	CPFSEQ 0x003 ; skip if c = 0
	MOVLW 0x002 ; w = 2
	MULWF 0x002 ; c * 2
	CPFSEQ 0x003 ; skip if w = 0
	MOVF PRODL , W
	CPFSEQ 0x003 ; skip if w = 0
	MULWF 0x000 ; x << c
	CPFSEQ 0x003 ; skip if w = 0
	MOVF PRODL , W
	CPFSEQ 0x003 ; skip if w = 0
	MOVWF 0x000
	
	; Step 3
	;    c = x < 0x80;
	MOVLW 0x001 
	MOVWF 0x002 ; c = 1
	MOVLW 0x080 ; W = 0x080 value
	CPFSLT 0x000 ; skip if x < W 
	DECF 0x002 
	
	;    r += c
	MOVLW 0x001 ; w = 1
	MULWF 0x002
	MOVF PRODL , W 
	MOVWF 0x002 ; c *= 1
	ADDWF 0x010
	
	;    x <<= c;
	MOVF 0x002 , W ;  W = c 
	CPFSEQ 0x003 ; skip if c = 0
	MOVLW 0x002 ; w = 2
	MULWF 0x002
	CPFSEQ 0x003 ; skip if w = 0
	MOVF PRODL , W
	CPFSEQ 0x003 ; skip if w = 0
	MULWF 0x000 ; c * x
	CPFSEQ 0x003 ; skip if w = 0
	MOVF PRODL , W
	CPFSEQ 0x003 ; skip if w = 0
	MOVWF 0x000
	
	; Step 4
	MOVLW 0x000
	CPFSGT 0x000 ; f > 1 skip
	INCF 0x010
	
	MOVF 0x001 , W
	MOVWF 0x000
	CLRF 0x001
	CLRF 0x002
	
	end
	
	
	

;    c = (x < 0x10);
;    c *= 4;
;    r += c; x <<= c;
;	
;    c = (x < 0x40);
;    c *= 2;
;    r += c; x <<= c;
;
;    c = x < 0x80;
;    r += c; x <<= c;
;
;    r += x == 0;