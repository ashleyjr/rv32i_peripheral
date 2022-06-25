void main(){ 
   unsigned int i;
   unsigned int * addr;
   addr = (unsigned int *)0x30000000; 
   for(i=0;i<4;i++){
      switch(i){
         case 3:  *addr = 0xDDDDDDDD;
         case 2:  *addr = 0xCCCCCCCC;
         case 1:  *addr = 0xBBBBBBBB;
         default: *addr = 0xAAAAAAAA;
      }
   }
   for(;;);
}

// CHECK: {{.*}}0x30000000 < 0xaaaaaaaa
// CHECK: {{.*}}0x30000000 < 0xbbbbbbbb
// CHECK: {{.*}}0x30000000 < 0xcccccccc
// CHECK: {{.*}}0x30000000 < 0xdddddddd
