void main(){ 
   unsigned int a,b;
   unsigned int * addr;
   addr = (unsigned int *)0x30000000;
   a = 0xAAAAAAAA;
   b = 0xFFAA5500;
   *addr = a & b;
   *addr = a ^ b;
   *addr = a | b;
   for(;;);
}
