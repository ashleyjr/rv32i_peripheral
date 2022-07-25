void main(){ 
   unsigned int a;
   unsigned int b;
   signed int c;
   signed int d;
   unsigned int i;
   unsigned int * addr;
   addr = (unsigned int *)0x30000000;
   a = 1;
   b = 19;
   c = -1;
   d = -19; 
   for(i=0;i<2;i++){
      // Unsigned left 
      *addr = a << i;
      // Unsigned right 
      *addr = b >> i;
      // Signed left 
      *addr = c << i;
      // Signed right 
      *addr = d >> i;
   }
   for(;;);
}

// CHECK: {{.*}}0x30000000 < 0x00000001
// CHECK: {{.*}}0x30000000 < 0x00000013
// CHECK: {{.*}}0x30000000 < 0xffffffff
// CHECK: {{.*}}0x30000000 < 0xffffffed

// CHECK: {{.*}}0x30000000 < 0x00000002
// CHECK: {{.*}}0x30000000 < 0x00000009
// CHECK: {{.*}}0x30000000 < 0xfffffffe
// CHECK: {{.*}}0x30000000 < 0xfffffff6




