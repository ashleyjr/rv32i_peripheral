void main(){ 
   unsigned int a;
   unsigned int b;
   signed int c;
   signed int d;
   unsigned int * addr;
   addr = (unsigned int *)0x30000000;
   a = 1;
   b = 19;
   c = -1;
   d = -19; 
   for(;;){
      // Unsigned left
      a <<= 1;
      *addr = a;
      // Unsigned right
      b >>= 1;
      *addr = b;
      // Signed left
      c <<= 1;
      *addr = c;
      // Signed right
      d >>= 1;
      *addr = d;
   }
}

// CHECK: {{.*}}0x30000000 < 0x00000002
// CHECK: {{.*}}0x30000000 < 0x00000009
// CHECK: {{.*}}0x30000000 < 0xfffffffe
// CHECK: {{.*}}0x30000000 < 0xfffffff6



