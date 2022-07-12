unsigned int f(unsigned int data);

void main(){ 
   unsigned int a,b;
   unsigned int * addr;
   addr = (unsigned int *)0x30000000; 
   *addr = f(10); 
   for(;;);
}

unsigned int f(unsigned int data){
   if(data == 0){
      return 0;
   }else{
      return data + f(data - 1);
   }
}
// CHECK: {{.*}}0x30000000 < 0x00000037
