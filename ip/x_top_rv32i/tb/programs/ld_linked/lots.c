#define A *addr = i++;        /* 1 */
#define B A A A A A A A A A A /* 10 */
#define C B B B B B B B B B B /* 100 */
#define D C C C C C C C C C C /* 1000 */
#define E D D D D D D D D D D /* 10000 */
#define F E E E E E E E E E E /* 100000 */

void f(unsigned int * addr);

void main(){ 
   unsigned int i;
   unsigned int * addr;
   addr = (unsigned int *)0x30000000; 
   f(addr);
   *addr = 0xBEEFDEAD; 
   
   // Lots of code in the way sp a big jump needed
   F
   for(;;);
}

void f(unsigned int * addr){ 
   *addr = 0xDEADBEEF; 
   return;
}

// CHECK: {{.*}}0x30000000 < 0xdeadbeef
// CHECK: {{.*}}0x30000000 < 0xbeefdead
