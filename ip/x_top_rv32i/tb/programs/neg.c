#define LEN 11

void main(){ 
   const unsigned int z[LEN] = {
      -1,
      1,
      -2,
      2,
      -3,
      3,
      -0x7FFFFFFF,
      0x7FFFFFFF,
      -0x80000000,
      0x40000000,
      0x40000000
   }; 
   unsigned int i;
   unsigned int * addr;
   unsigned int acc;
   
   addr = (unsigned int *)0x30000000;
   acc = 0;
   for(i=0;i<LEN;i++){
      acc += z[i];
      *addr = acc;
   }
   for(;;);
}

// CHECK: {{.*}}0x30000000 < 0xffffffff
// CHECK: {{.*}}0x30000000 < 0x00000000
// CHECK: {{.*}}0x30000000 < 0xfffffffe
// CHECK: {{.*}}0x30000000 < 0x00000000
// CHECK: {{.*}}0x30000000 < 0xfffffffd
// CHECK: {{.*}}0x30000000 < 0x00000000
// CHECK: {{.*}}0x30000000 < 0x80000001
// CHECK: {{.*}}0x30000000 < 0xc0000000
// CHECK: {{.*}}0x30000000 < 0x00000000
