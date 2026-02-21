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

char running = 1; 
int tick = 0;
int location = 15;
int direction = 1;

static void TMR1_reload_10ms(void){
    TMR1H = 0xFF;
    TMR1L = 0xE5;
}

void setServoDuty(unsigned char duty) {
    // Motor
    CCPR1L = duty >> 2;
    CCP1CONbits.DC1B = duty & 0x03;
    
    // Led
    unsigned char led_duty = (unsigned char)(((int)duty - 15) * 255 / (78 - 15));
    CCPR2L = led_duty >> 2;
    CCP2CONbits.DC2B0 = (led_duty & 0x01);
    CCP2CONbits.DC2B1 = ((led_duty >> 1) & 0x01);
}

void __interrupt() isr(void) {
    if (PIR1bits.TMR1IF) {
        PIR1bits.TMR1IF = 0; // recover interupt bit
        TMR1_reload_10ms(); // reload timer
        
        static unsigned char last_state = 1;
        unsigned char current = PORTBbits.RB0;

        if (last_state == 0 && current == 1) {
            __delay_ms(20);                 
            if (PORTBbits.RB0 == 1) {       
                running = !running;          
            }
        }

        last_state = current;
        
        if (++tick >= 4) {  // 10ms * 4 = 40ms
            tick = 0;

            if (!running) {
                location += direction;
                if (location >= 78) {
                    location = 78;
                    direction = -1;
                } else if (location <= 15) {
                    location = 15;
                    direction = 1;
                }
                setServoDuty(location);
            }
        }
    }
}

void init_timer1(void){
    // Timer1?Fosc/4, Prescale=1:8 ? 32us/tick
    T1CONbits.TMR1CS = 0;   // Clock = Fosc/4
    T1CONbits.T1CKPS = 0b11; // Prescale 1:8
    TMR1_reload_10ms();
    PIR1bits.TMR1IF = 0;
    PIE1bits.TMR1IE = 1;
    T1CONbits.TMR1ON = 1;
}

void main(void){
    
    RCONbits.IPEN = 0;
    INTCONbits.PEIE = 1;
    INTCONbits.GIE = 1;
    
    init_timer1();
    
    // Timer2 -> On, prescaler -> 4
    T2CONbits.TMR2ON = 0b1;
    T2CONbits.T2CKPS = 0b01;

    // Internal Oscillator Frequency, Fosc = 125 kHz, Tosc = 8 탎
    OSCCONbits.IRCF = 0b001;
    
    // PWM mode, P1A, P1C active-high; P1B, P1D active-high
    CCP1CONbits.CCP1M = 0b1100;
    
    CCP2CONbits.CCP2M = 0b1100;
    TRISCbits.TRISC1 = 0;
    
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

    CCPR2L = 0x00;
    CCP2CONbits.DC2B0 = 0b0;
    CCP2CONbits.DC2B1 = 0b0;
    __delay_ms(1000);
  
    while (1) {
        
    }

    return;
}
