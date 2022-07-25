void main(){ 
   float a,b;
   unsigned int * addr;
   addr = (unsigned int *)0x30000000; 
   a = 77777777.7;
   a /= 33.3;
   *addr = (unsigned int)a; 
   for(;;);
}

// CHECK: {{.*}}0x30000000 < 0x0023a3b5

