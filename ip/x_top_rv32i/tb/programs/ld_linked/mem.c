unsigned int f(unsigned int data);

void main(){ 
   unsigned int i;
   unsigned int * addr;
   unsigned int mem[0x8000];
   addr = (unsigned int *)0x30000000;  
   for(i=0;i<0x8000;i+=0x1000){
      mem[i] = 0xDEADBEEF;
   }
   for(i=0;i<0x8000;i+=0x1000){
      *addr = mem[i]; 
   }
   for(;;);
}

// CHECK-COUNT-8: {{.*}}0x30000000 < 0xdeadbeef
