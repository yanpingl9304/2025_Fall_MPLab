#include <xc.h>
#include <pic18f4520.h>

#pragma config OSC = INTIO67 
#pragma config WDT = OFF     
#pragma config PWRT = OFF    
#pragma config BOREN = ON    
#pragma config PBADEN = OFF  
#pragma config LVP = OFF     
#pragma config CPD = OFF     

unsigned char last_adc_value = 0;

void setDuty(unsigned char adc_value) 
{
    unsigned char inv = 255 - adc_value;  
    
    unsigned int duty10 = inv * 4;
    
    CCPR1L = duty10 >> 2;            // high 8 bits
    CCP1CONbits.DC1B = duty10 & 0x03;  // low 2 bits
}

void __interrupt(high_priority)H_ISR() {

    unsigned char current_adc = ADRESH;
    
    if ( current_adc > last_adc_value + 5 ) {
        // CLOCKWISE DECREASE   
        setDuty(current_adc);
        last_adc_value = current_adc; 
    } else if (current_adc < last_adc_value - 5){
        // COUNTER CLOCKWISE INCREASE
        setDuty(current_adc);
        last_adc_value = current_adc; 
    }

    PIR1bits.ADIF = 0;
    ADCON0bits.GO = 1;
}

void main(void) 
{
    OSCCONbits.IRCF = 0b100; // 1MHz
    
    // Timer2 -> On, prescaler -> 4
    T2CONbits.TMR2ON = 0b1;
    T2CONbits.T2CKPS = 0b01;
    
    // PWM mode, P1A, P1C active-high; P1B, P1D active-high
    CCP1CONbits.CCP1M = 0b1100;
    TRISCbits.TRISC2 = 0; 
    
    // Set up PR2, CCP to decide PWM period and Duty Cycle
    /*
     * PWM period
     * = (PR2 + 1) * 4 * Tosc * (TMR2 prescaler)
     * = (0x9B + 1) * 4 * 8µs * 4
     * = 0.019968s ~= 20ms
     */
    PR2 = 0x9B;
    
    ADCON1bits.VCFG0 = 0;     // Vref+ = Vdd
    ADCON1bits.VCFG1 = 0;     // Vref- = Vss
    ADCON1bits.PCFG = 0b1110; // AN0 analog, others digital

    ADCON0bits.CHS = 0b0000;  //  AN0
    ADCON2bits.ADCS = 0b000;  // Fosc/2 
    ADCON2bits.ACQT = 0b001;  // acquisition time >= 2.4us
    ADCON2bits.ADFM = 0;      // Left justified 

    ADCON0bits.ADON = 1;      // open ADC

    // -------------------------------------------------------------
    // interrupt
    // -------------------------------------------------------------
    PIE1bits.ADIE = 1;
    PIR1bits.ADIF = 0;
    INTCONbits.PEIE = 1;
    INTCONbits.GIE = 1;

    // -------------------------------------------------------------
    // first start ADC
    // -------------------------------------------------------------
    ADCON0bits.GO = 1;
    
    CCPR1L = 0x00;
    CCP1CONbits.DC1B = 0;
    
    last_adc_value = ADRESH;

    while(1);
}
