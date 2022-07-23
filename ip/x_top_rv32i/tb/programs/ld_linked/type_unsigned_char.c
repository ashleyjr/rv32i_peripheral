void main(){ 
   unsigned char i;
   unsigned int * addr;
   addr = (unsigned int *)0x30000000;  
   i = 0xF0;
   for(;;){
      i++;
      *addr = (unsigned int)i;
   }
}


// CHECK: {{.*}}0x30000000 < 0x000000ff
// CHECK-NOT: {{.*}}0x30000000 < 0x00000100
// CHECK: {{.*}}0x30000000 < 0x00000000


