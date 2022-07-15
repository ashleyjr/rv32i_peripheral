void main(){ 
   unsigned int i;
   unsigned int * addr;
   addr = (unsigned int *)0x30000000; 
   for(i=0;i<14;i++){ 
      *addr = i * i;
   }
   for(;;);
}


// CHECK: {{.*}}0x30000000 < 0x00000000
// CHECK: {{.*}}0x30000000 < 0x00000001
// CHECK: {{.*}}0x30000000 < 0x00000004
// CHECK: {{.*}}0x30000000 < 0x00000009
// CHECK: {{.*}}0x30000000 < 0x00000010
// CHECK: {{.*}}0x30000000 < 0x00000019
// CHECK: {{.*}}0x30000000 < 0x00000024
// CHECK: {{.*}}0x30000000 < 0x00000031
// CHECK: {{.*}}0x30000000 < 0x00000040
// CHECK: {{.*}}0x30000000 < 0x00000051
// CHECK: {{.*}}0x30000000 < 0x00000064
// CHECK: {{.*}}0x30000000 < 0x00000079
// CHECK: {{.*}}0x30000000 < 0x00000090
// CHECK: {{.*}}0x30000000 < 0x000000a9





