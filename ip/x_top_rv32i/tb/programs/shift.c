void main(){ 
   unsigned int data;
   unsigned int * addr;
   addr = (unsigned int *)0x30000000;
   data = 1;
   for(;;){
      *addr = data;
      data <<= 1;
   }
}


// CHECK: {{.*}}0x30000000 < 0x00000001
// CHECK: {{.*}}0x30000000 < 0x00000002
// CHECK: {{.*}}0x30000000 < 0x00000004
// CHECK: {{.*}}0x30000000 < 0x00000008
// CHECK: {{.*}}0x30000000 < 0x00000010
// CHECK: {{.*}}0x30000000 < 0x00000020
// CHECK: {{.*}}0x30000000 < 0x00000040
// CHECK: {{.*}}0x30000000 < 0x00000080
// CHECK: {{.*}}0x30000000 < 0x00000100

