void main(){ 
   unsigned int i;
   unsigned int * addr;
   addr = (unsigned int *)0x30000000; 
   for(i=0;i<4;i++){
      switch(i){
         case 3:  *addr = 0xDDDDDDDD; break;
         case 2:  *addr = 0xCCCCCCCC; break;
         case 1:  *addr = 0xBBBBBBBB; break;
         default: *addr = 0xAAAAAAAA; break;
      }
   }
   for(;;);
}

// CHECK: {{.*}}0x30000000 < 0xaaaaaaaa
// CHECK-NOT: {{.*}}0x30000000 < {{.*}}
// CHECK: {{.*}}0x30000000 < 0xbbbbbbbb
// CHECK-NOT: {{.*}}0x30000000 < {{.*}}
// CHECK: {{.*}}0x30000000 < 0xcccccccc
// CHECK-NOT: {{.*}}0x30000000 < {{.*}}
// CHECK: {{.*}}0x30000000 < 0xdddddddd
