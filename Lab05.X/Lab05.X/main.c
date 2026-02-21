/*SK???217
 * File:   main.c
 * Author: yanpi
 *
 * Created on October 12, 2025, 11:42 AM
 */


#include <xc.h>

extern unsigned char is_prime(unsigned char n);
extern unsigned int count_primes(unsigned int n , unsigned int m);
extern long mul_extended(int n , int m);
void main(void){
//    volatile unsigned char ans = is_prime(131);
//    volatile unsigned int ans = count_primes(1, 1234);
    volatile long ans = mul_extended(-32768, -32768);
    while(1);
    return;
}


