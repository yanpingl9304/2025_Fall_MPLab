LIST p=18f4520
#include<p18f4520.inc>

    CONFIG OSC = INTIO67 ; Set internal oscillator to 1 MHz
    CONFIG WDT = OFF     ; Disable Watchdog Timer
    CONFIG LVP = OFF     ; Disable Low Voltage Programming

    L1 EQU 0x14         ; Define L1 memory location
    L2 EQU 0x15         ; Define L2 memory location
    L3 EQU 0x16         ; Define L1 memory location
    L4 EQU 0x17         ; Define L2 memory location
    org 0x00            ; Set program start address to 0x00

; instruction frequency = 1 MHz / 4 = 0.25 MHz
; instruction time = 1/0.25 = 4 ?s
; Total_cycles = 2 + (2 + 8 * num1 + 3) * num2 cycles
; num1 = 111, num2 = 70, Total_cycles = 62512 cycles
; Total_delay ~= Total_cycles * instruction time = 0.25 s
    DELAY_CUSTOM macro num1, num2
	local LOOP1         ; Inner loop
	local LOOP2         ; Outer loop

	; 2 cycles
	MOVLW num2          ; Load num2 into WREG
	MOVWF L2            ; Store WREG value into L2

	; Total_cycles for LOOP2 = 2 cycles
	LOOP2:
	MOVLW num1          
	MOVWF L1  

	; Total_cycles for LOOP1 = 8 cycles
	LOOP1:
	NOP                 ; busy waiting
	NOP
	NOP
	NOP
	NOP
	DECFSZ L1, 1        
	BRA LOOP1           ; BRA instruction spends 2 cycles

	; 3 cycles
	DECFSZ L2, 1        ; Decrement L2, skip if zero
	BRA LOOP2           
    endm
    
    delay macro ; ??????? 0.5s delay
	    local LOOP1
	    local LOOP2
	    local CONT

	    MOVLW d'140'
	    MOVWF L4
	; 2 + (2+15*num1 + 3) * num2
    LOOP2:
	    MOVLW d'111'
	    MOVWF L3

    LOOP1:
	    NOP
	    NOP
	    NOP
	    NOP
	    NOP
	    BTFSC PORTB, 0    
	    BRA CONT
	    DELAY_CUSTOM d'50', d'30'
	    BTFSC PORTB, 0
	    BRA CONT
	    INCF 0x011
    CONT:
	    DECFSZ L3, 1
	    BRA LOOP1

	    DECFSZ L4, 1
	    BRA LOOP2
    endm


start:
int:
; let pin can receive digital signal
; set = input , clear = output
    MOVLW 0x0f          ; Set ADCON1 register for digital mode
    MOVWF ADCON1        ; Store WREG value into ADCON1 register
    CLRF PORTB          ; Clear PORTB
    CLRF TRISB
    BSF TRISB, 0        ; Set RB0 as input (TRISB = 0000 0001)
    CLRF LATA           ; Clear LATA
    CLRF TRISA
    BCF TRISA, 0        ; Set RA0 as output (TRISA = 0000 0000)
    BCF TRISA, 1
    BCF TRISA, 2
    CLRF 0x010
    
    MOVLW   b'00000000'      ; RA0?
    MOVWF   LATA
    
; state @ 0x010
; Button check
check_process:
;    BCF PORTB ,0
    BTFSC PORTB, 0      ; Check if PORTB bit 0 is low (button pressed)
    BRA check_process   ; If button is not pressed, branch back to check_process
    ; debounce
    DELAY_CUSTOM d'50', d'30'     
    BTFSC PORTB, 0       
    BRA check_process   
wait_release:
    BTFSS PORTB,0
    BRA wait_release
CLICK:
    CLRF 0x011
    INCF 0x010          ; state ++
    MOVLW 0x03 
    CPFSLT 0x010        ; skip if 0x010 <= 3
    CLRF 0x010
    
CASE0:
    MOVLW 0x00
    CPFSEQ 0x010
    GOTO CASE1
    
    MOVLW   b'00000000'      ; RA0
    MOVWF   LATA
    delay
    MOVLW 0x001
    CPFSLT 0x011 ; 0x011 <= 1 skip 
    GOTO CLICK
    
    GOTO CASE0
    
CASE1:
    MOVLW 0x01
    CPFSEQ 0x010
    GOTO CASE2
    
    MOVLW   b'00000001'      ;  RA0
    MOVWF   LATA
    delay
    MOVLW 0x001
    CPFSLT 0x011 ; 0x011 <= 1 skip 
    GOTO CLICK

    MOVLW   b'00000010'      ;  RA1
    MOVWF   LATA
    delay
    MOVLW 0x001
    CPFSLT 0x011 ; 0x011 <= 1 skip 
    GOTO CLICK
    
    MOVLW   b'00000100'      ;  RA2
    MOVWF   LATA
    delay
    MOVLW 0x001
    CPFSLT 0x011 ; 0x011 <= 1 skip 
    GOTO CLICK
    
    GOTO CASE1

CASE2:
    MOVLW   b'00000001'      ;  RA0
    MOVWF   LATA
    delay
    MOVLW 0x001
    CPFSLT 0x011 ; 0x011 <= 1 skip 
    GOTO CLICK
    delay
    MOVLW 0x001
    CPFSLT 0x011 ; 0x011 <= 1 skip 
    GOTO CLICK
    
    MOVLW b'00000011'
    MOVWF LATA
    delay
    MOVLW 0x001
    CPFSLT 0x011 ; 0x011 <= 1 skip 
    GOTO CLICK
    delay
    MOVLW 0x001
    CPFSLT 0x011 ; 0x011 <= 1 skip 
    GOTO CLICK
    
    ; 2-3
    MOVLW b'00000100'
    MOVWF LATA
    delay
    MOVLW 0x001
    CPFSLT 0x011 ; 0x011 <= 1 skip 
    GOTO CLICK
    
    MOVLW b'00000000'
    MOVWF LATA
    delay
    MOVLW 0x001
    CPFSLT 0x011 ; 0x011 <= 1 skip 
    GOTO CLICK
    delay
    MOVLW 0x001
    CPFSLT 0x011 ; 0x011 <= 1 skip 
    GOTO CLICK
    
    MOVLW b'00000100'
    MOVWF LATA
    delay
    MOVLW 0x001
    CPFSLT 0x011 ; 0x011 <= 1 skip 
    GOTO CLICK
    
    MOVLW b'00000000'
    MOVWF LATA
    delay
    MOVLW 0x001
    CPFSLT 0x011 ; 0x011 <= 1 skip 
    GOTO CLICK
    delay
    MOVLW 0x001
    CPFSLT 0x011 ; 0x011 <= 1 skip 
    GOTO CLICK
    
    MOVLW b'00000100'
    MOVWF LATA
    delay
    MOVLW 0x001
    CPFSLT 0x011 ; 0x011 <= 1 skip 
    GOTO CLICK
    
    GOTO CASE2

end