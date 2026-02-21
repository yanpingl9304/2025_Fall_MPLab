#include "setting_hardaware/setting.h"
#include <stdlib.h>
#include <pic18f4520.h>
#include "stdio.h"
#include "string.h"
// using namespace std;

#define _XTAL_FREQ 1000000 

void led(int num) {
    LATD = (num & 0x0F) << 4;
}

void Basic(){
    ADCON1 = 0x0F;
    TRISBbits.TRISB0 = 1;
    TRISD = 0x00;
    LATD = 0x00;
    
    char buf[5];
    
    unsigned char last_state = 1;
    unsigned char current;

    char done = 0;
    
    int count = 0;
    
    for(int i = 0 ; i < 10 ; i++) UART_Write('\b');
    sprintf(buf, "%d", count);
    UART_Write_Text(buf);
    led(count);

    while (1) {
        current = PORTBbits.RB0;

        if (last_state == 1 && current == 0) {
            __delay_ms(20);
            if (PORTBbits.RB0 == 0) {
                done = 1;                  
                while (PORTBbits.RB0 == 0);
                __delay_ms(20);             
            }
        }
        
        last_state = current;

        if (done) {
            count++;
            for(int i = 0 ; i < 10 ; i++) UART_Write('\b');
            sprintf(buf, "%d", count);
            UART_Write_Text(buf);
            led(count);
            done = 0;
        }
    }
}

void Advance(){
    
    ADCON1 = 0x0F;
    TRISD = 0x00;
    LATD = 0x00;
    
    // Timer2
    T2CONbits.TMR2ON = 0b1;
    T2CONbits.T2CKPS = 0b10;   // Prescaler = 16
    T2CONbits.T2OUTPS = 0b1111;
    PIR1bits.TMR2IF = 0;
    PIE1bits.TMR2IE = 1;
    IPR1bits.TMR2IP = 0;
    PR2 = 97;
    
    // Interrupt
    RCONbits.IPEN = 1;
    INTCONbits.GIE = 1;
    
    while(1);
}

int subcounter = 0;
int value = 10;
int counter = 0;

char mystring[20];
int lenStr = 0;

void ClearBuffer(){
    for(int i = 0; i < 10 ; i++)
        mystring[i] = '\0';
    lenStr = 0;
}

void MyusartRead()
{
    unsigned char c = RCREG;

    UART_Write(c);

    if (c == '\r') {
        mystring[lenStr] = '\0';   
        UART_Write('\r');
        UART_Write('\n');            
        lenStr = 0;    
        
        if(mystring[0] == '0' && mystring[1] == '.') {
            value = mystring[2] - '0';
        } else if (mystring[0] == '1' && mystring[1] == '.' && mystring[2] == '0') {
            value = 10;
        }
        ClearBuffer();
        return;
    }

    mystring[lenStr] = c;
    lenStr++;

    if (lenStr >= 10) {
        lenStr = 0;
    }
}

void __interrupt(high_priority)  UART_ISR(void)
{
    if(RCIF)
    {
        if(RCSTAbits.OERR)
        {
            CREN = 0;
            Nop();
            CREN = 1;
        }
        
        MyusartRead();
    }
    
   // process other interrupt sources here, if required
    return;
}

void __interrupt(low_priority) Timer2_ISR(void)
{
    if (PIR1bits.TMR2IF) {
        PIR1bits.TMR2IF= 0;
        
        subcounter++;
        
        if(subcounter >= value) {
            subcounter = 0;
            counter++;
            led(counter%16);
        }
    }
}

int ADC_Read_Avg(int ch)
{
    long sum = 0;

    for(int i = 0; i < 8; i++) {
        sum += ADC_Read(ch);
        __delay_ms(1);
    }

    return sum / 8;
}

int ADC_To_Output(int value)
{
    if (value < 85)       return 4;
    else if (value < 170) return 5;
    else if (value < 256) return 6;
    else if (value < 341) return 7;
    else if (value < 426) return 8;
    else if (value < 512) return 9;
    else if (value < 597) return 10;
    else if (value < 682) return 11;
    else if (value < 767) return 12;
    else if (value < 852) return 13;
    else if (value < 938) return 14;
    else                  return 15;
}

void Hard(){
    
    TRISD = 0x00;
    LATD = 0x00;
    
    char buffer[10];
    int value;
    int last = -1;
    int last_len = 0;
    
    while(1) {
        
        value = ADC_Read_Avg(1);

        // only update when value changed
        if(value != last) {

            for(int i = 0; i < last_len; i++) {
                UART_Write('\b');
                UART_Write(' ');
                UART_Write('\b');
            }

            sprintf(buffer, "%d", value);
            UART_Write_Text(buffer);
            led(ADC_To_Output(value));
            last_len = strlen(buffer);

            last = value;
        }

        __delay_ms(100);
    }
}


void main(void) 
{
    
    SYSTEM_Initialize() ;
    
//    Basic();
    
//    Advance();
    
    Hard();
    
    return;
}