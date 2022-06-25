void main(void){
   unsigned int i;
   unsigned int * addr;
   addr = (unsigned int *)0x30000000;
   for(i=0;i<4;i++){
      *addr = i;
   }
   for(;;);
}
