void main(){ 
   unsigned short i;
   unsigned int * addr;
   addr = (unsigned int *)0x30000000;  
   i = 0xFFF0;
   for(;;){
      i++;
      *addr = (unsigned int)i;
   }
}


// CHECK: {{.*}}0x30000000 < 0x0000ffff
// CHECK-NOT: {{.*}}0x30000000 < 0x00010000
// CHECK: {{.*}}0x30000000 < 0x00000000


