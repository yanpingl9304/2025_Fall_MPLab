#include <xc.h>
#include <pic18f4520.h>

#pragma config OSC = INTIO67 
#pragma config WDT = OFF     
#pragma config PWRT = OFF    
#pragma config BOREN = ON    
#pragma config PBADEN = OFF  
#pragma config LVP = OFF     
#pragma config CPD = OFF     

unsigned char date[8] = {2, 0, 2, 5, 1, 1, 2, 0};
unsigned char index = 0;

unsigned char last_adc_value = 0;

void display(unsigned char num) {
    LATD = (LATD & 0xF0) | (num & 0x0F);   // ??? RD0~RD3
}

void __interrupt(high_priority)H_ISR() {

    unsigned char current_adc = ADRESH;
    
    if ( (current_adc > last_adc_value + 5) || (current_adc < last_adc_value - 5) ) {
        index = current_adc / 32;

        display(date[index]);

        last_adc_value = current_adc;
    }

    PIR1bits.ADIF = 0;
    ADCON0bits.GO = 1;
}

void main(void) 
{

    OSCCONbits.IRCF = 0b100; // 1MHz
    TRISAbits.RA0 = 1;       // AN0 VR input

    TRISD &= 0xF0;           // LED output (RD0~3)
    LATD &= 0xF0;



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

    display(date[index]);
    last_adc_value = ADRESH;

    while(1);
}
