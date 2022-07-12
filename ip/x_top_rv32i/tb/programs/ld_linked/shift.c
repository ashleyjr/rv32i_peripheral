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
// CHECK: {{.*}}0x30000000 < 0x80000000
// CHECK: {{.*}}0x30000000 < 0x00000000

