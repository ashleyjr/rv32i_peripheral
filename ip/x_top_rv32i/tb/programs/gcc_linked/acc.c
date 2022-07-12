void main(){ 
   unsigned int data;
   unsigned int * addr;
   addr = (unsigned int *)0x30000000;
   data = 0;
   for(;;){
      data++;
      *addr = data;
   }
}


// CHECK: {{.*}}0x30000000 < 0x00000001
// CHECK: {{.*}}0x30000000 < 0x00000002
// CHECK: {{.*}}0x30000000 < 0x00000003
// CHECK: {{.*}}0x30000000 < 0x00000004
// CHECK: {{.*}}0x30000000 < 0x00000005
// CHECK: {{.*}}0x30000000 < 0x00000006
// CHECK: {{.*}}0x30000000 < 0x00000007

