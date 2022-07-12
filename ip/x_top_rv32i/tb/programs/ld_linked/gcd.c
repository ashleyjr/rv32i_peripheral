void main(){ 
   unsigned int a,b;
   unsigned int * addr;
   a = 777777777;
   b = 333333333;
   addr = (unsigned int *)0x30000000;
   for(;;){
      if(b == 0){
         *addr = a;
         for(;;);
      }else{
         if(a > b){
            a -= b;
         }else{
            b -= a;
         }
      }
   }
}

// CHECK: {{.*}}0x30000000 < 0x069f6bc7 

