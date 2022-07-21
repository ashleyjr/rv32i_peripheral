void main(){ 
   unsigned int i;
   unsigned int * addr;
   addr = (unsigned int *)0x30000000; 
   for(i=0;i<2000;i+=777){ 
      *addr = i / 3;
   }
   for(;;);
}


// CHECK: {{.*}}0x30000000 < 0x00000000
// CHECK: {{.*}}0x30000000 < 0x00000103
// CHECK: {{.*}}0x30000000 < 0x00000206

