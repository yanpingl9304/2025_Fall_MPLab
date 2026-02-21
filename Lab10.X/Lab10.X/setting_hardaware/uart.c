#include <xc.h>
    //setting TX/RX

char mystring[20];
int lenStr = 0;

void UART_Initialize() {
           
    /*       TODObasic   
           Serial Setting      
        1.   Setting Baud rate
        2.   choose sync/async mode 
        3.   enable Serial port (configures RX/DT and TX/CK pins as serial port pins)
        3.5  enable Tx, Rx Interrupt(optional)
        4.   Enable Tx & RX
    */        
    TRISCbits.TRISC6 = 1;            
    TRISCbits.TRISC7 = 1;            
    
    //  Setting baud rate
    // for 1 mhz
    TXSTAbits.SYNC = 0;           
    BAUDCONbits.BRG16 = 0;          
    TXSTAbits.BRGH = 0;
    SPBRG = 12; 
    
    //   Serial enable
    RCSTAbits.SPEN = 1;   //           
    PIR1bits.TXIF = 1;
    PIR1bits.RCIF = 0;
    TXSTAbits.TXEN = 1;     //      
    RCSTAbits.CREN = 1;             
    PIE1bits.TXIE = 0;       
    IPR1bits.TXIP = 0;             
    PIE1bits.RCIE = 1;              
    IPR1bits.RCIP = 1;    
             
}

void UART_Write(unsigned char data)  // Output on Terminal
{
    while(!TXSTAbits.TRMT);
    TXREG = data;              //write to TXREG will send data 
}


void UART_Write_Text(char* text) { // Output on Terminal, limit:10 chars
    for(int i=0;text[i]!='\0';i++)
        UART_Write(text[i]);
}

//void ClearBuffer(){
//    for(int i = 0; i < 10 ; i++)
//        mystring[i] = '\0';
//    lenStr = 0;
//}
//
//void PrintBuffer(){
//    UART_Write('\r');
//    UART_Write('\n');
//    UART_Write_Text(mystring);
//    UART_Write('\r');
//    UART_Write('\n');
//    ClearBuffer();
//}



//void MyusartRead()
//{
//    unsigned char c = RCREG;
//
//    UART_Write(c);
//
//    if (c == '\r') {
//        mystring[lenStr] = '\0';   
//        PrintBuffer();             
//        lenStr = 0;                
//        return;
//    }
//
//    mystring[lenStr] = c;
//    lenStr++;
//
//    if (lenStr >= 10) {
//        lenStr = 0;
//    }
//}



char *GetString(){
    return mystring;
}