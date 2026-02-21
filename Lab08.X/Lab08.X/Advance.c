// PIC18F4520 Configuration Bit Settings
// 'C' source line config statements

#pragma config OSC = INTIO67    // Oscillator Selection bits (Internal oscillator block, port function on RA6 and RA7)
#pragma config PWRT = OFF       // Power-up Timer Enable bit (PWRT disabled)
#pragma config BOREN = ON       // Brown-out Reset Enable bits (Brown-out Reset enabled and controlled by software (SBOREN is enabled))
#pragma config WDT = OFF        // Watchdog Timer Enable bit (WDT disabled (control is placed on the SWDTEN bit))
#pragma config PBADEN = OFF     // PORTB A/D Enable bit (PORTB<4:0> pins are configured as digital I/O on Reset)
#pragma config LVP = OFF        // Single-Supply ICSP Enable bit (Single-Supply ICSP disabled)
#pragma config CPD = OFF        // Data EEPROM Code Protection bit (Data EEPROM not code-protected)

// #pragma config statements should precede project file includes.
// Use project enums instead of #define for ON and OFF.

#include <xc.h>
#include <pic18f4520.h>

#define _XTAL_FREQ 125000 

void setServoDuty(unsigned char duty) {
    CCPR1L = duty >> 2;            // ? 8 ??
    CCP1CONbits.DC1B = duty & 0x03; // ? 2 ??
}

void main(void){
    // Timer2 -> On, prescaler -> 4
    T2CONbits.TMR2ON = 0b1;
    T2CONbits.T2CKPS = 0b01;

    // Internal Oscillator Frequency, Fosc = 125 kHz, Tosc = 8 탎
    OSCCONbits.IRCF = 0b001;
    
    // PWM mode, P1A, P1C active-high; P1B, P1D active-high
    CCP1CONbits.CCP1M = 0b1100;
    
    // CCP1/RC2 -> Output
    TRISC = 0;
    LATC = 0;
    
    // Set up PR2, CCP to decide PWM period and Duty Cycle
    /*
     * PWM period
     * = (PR2 + 1) * 4 * Tosc * (TMR2 prescaler)
     * = (0x9B + 1) * 4 * 8탎 * 4
     * = 0.019968s ~= 20ms
     */
    PR2 = 0x9B;
    
    /*
     * Duty cycle
     * = (CCPR1L:CCP1CON<5:4>) * Tosc * (TMR2 prescaler)
     * = (0x0B*4 + 0b01) * 8탎 * 4
     * = 0.00144s ~= 1450탎
     */
    
    CCPR1L = 0x03;
    CCP1CONbits.DC1B = 0b11;
    __delay_ms(1000);
    
    unsigned char last_state = 1;
    unsigned char current;
    int state = 0;
    char done = 1;
    int location = 15;
    int direction = 1;
    
    while (1) {
        current = PORTBbits.RB0;

        if (last_state == 1 && current == 0) {
            __delay_ms(20);
            if (PORTBbits.RB0 == 0) {
                state = (state + 1) % 4;
                done = 0;                  
                while (PORTBbits.RB0 == 0);
                __delay_ms(20);             
            }
        }
        
        last_state = current;
        
        if (!done) {
            int count = 47;

            while (count > 0) {

                location += direction;  
                setServoDuty(location);
                __delay_ms(20);
                count--;

                if (location >= 78) {
                    direction = -1;
                } else if (location <= 15) {
                    direction = 1;
                }
            }
            done = 1;
        }
    }

    return;
}
