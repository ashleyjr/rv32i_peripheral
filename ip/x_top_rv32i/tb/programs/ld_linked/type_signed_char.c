void main(){ 
   signed char i;
   int * addr;
   addr = (unsigned int *)0x30000000;  
   i = 2;
   for(;;){
      i--;
      *addr = (int)i;
   }
}


// CHECK: {{.*}}0x30000000 < 0x00000001
// CHECK: {{.*}}0x30000000 < 0x00000000
// CHECK: {{.*}}0x30000000 < 0xffffffff
// CHECK: {{.*}}0x30000000 < 0xfffffffe
