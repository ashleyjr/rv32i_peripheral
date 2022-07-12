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


// CHECK: {{.*}}0x30000000 < 0xaaaa0000
// CHECK: {{.*}}0x30000000 < 0x5500ffaa
// CHECK: {{.*}}0x30000000 < 0xffaaffaa
