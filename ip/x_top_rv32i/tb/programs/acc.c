void main(){ 
   unsigned int data;
   unsigned int * addr;
   addr = (unsigned int *)0x30000000;
   data = 0;
   for(;;){
      data++;
      *addr = data;
   }
}
