void main(){ 
   float a,b;
   unsigned int * addr;
   addr = (unsigned int *)0x30000000; 
   a = 77.7;
   a *= 777.7;
   *addr = (unsigned int)a; 
   for(;;);
}


// CHECK: {{.*}}0x30000000 < 0x0000ec0b

