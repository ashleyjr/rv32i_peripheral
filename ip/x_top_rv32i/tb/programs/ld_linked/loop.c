void main(void){
   unsigned int i;
   unsigned int * addr;
   addr = (unsigned int *)0x30000000;
   for(i=0;i<4;i++){
      *addr = i;
   }
   for(;;);
}

// CHECK: {{.*}}0x30000000 < 0x00000000
// CHECK: {{.*}}0x30000000 < 0x00000001
// CHECK: {{.*}}0x30000000 < 0x00000002
// CHECK: {{.*}}0x30000000 < 0x00000003

