#include <stdlib.h>
#include <iostream>
#include <fstream>
#include <limits>
#include <sstream>
#include <string>
#include <list>
#include <iomanip>
#include <verilated.h>
#include <verilated_vcd_c.h>
#include "Vx_top.h"

#define MAX_SIM_TIME 2000000

vluint64_t sim_time = 0;

int main(int argc, char** argv, char** env) { 
   Vx_top *dut = new Vx_top;
  
   std::cout << "Start\n\r";
   
   Verilated::traceEverOn(true);
   VerilatedVcdC *m_trace = new VerilatedVcdC;
   dut->trace(m_trace, 5);
   m_trace->open("waveform.vcd");

   dut->i_clk = 0;
   dut->i_nrst = 0;
   dut->i_rx = 1;
   
   while (sim_time < MAX_SIM_TIME) {
     
      dut->i_clk = 1; 
      dut->eval();
      m_trace->dump(sim_time);
      sim_time++;
      
      dut->i_clk = 0; 
      dut->eval();
      m_trace->dump(sim_time); 
      sim_time++; 
   
      switch(sim_time){
         case     10: dut->i_nrst = 1;  break;
         case  30000: dut->i_rx = 0;  break;
         case  50000: dut->i_rx = 1;  break;
         case  80000: dut->i_rx = 0;  break;
         case 110000: dut->i_rx = 1;  break;
         case 140000: dut->i_rx = 0;  break;
         case 170000: dut->i_rx = 1;  break;
         case 200000: dut->i_rx = 0;  break;
         case 230000: dut->i_rx = 1;  break;
         case 260000: dut->i_rx = 0;  break;
         case 290000: dut->i_rx = 1;  break;
         // SB instruction - 00100011
         case 320000: dut->i_rx = 0;  break;
         case 322000: dut->i_rx = 1;  break;
         case 326000: dut->i_rx = 0;  break;
         case 332000: dut->i_rx = 1;  break;
         case 334000: dut->i_rx = 0;  break;
         case 350000: dut->i_rx = 1;  break;
         case 380000: dut->i_rx = 0;  break;
         case 410000: dut->i_rx = 1;  break;
         case 440000: dut->i_rx = 0;  break;
         case 470000: dut->i_rx = 1;  break; 
         case 500000: dut->i_rx = 0;  break;
         case 530000: dut->i_rx = 1;  break;
         // ACK the write
         case 600000: dut->i_rx = 0;  break;
         case 630000: dut->i_rx = 1;  break;
         case 660000: dut->i_rx = 0;  break;
         case 690000: dut->i_rx = 1;  break;
         case 720000: dut->i_rx = 0;  break;
         case 750000: dut->i_rx = 1;  break;
         case 780000: dut->i_rx = 0;  break;
         case 810000: dut->i_rx = 1;  break;
         case 830000: dut->i_rx = 0;  break;
         case 850000: dut->i_rx = 1;  break;
         case 880000: dut->i_rx = 0;  break;
         case 910000: dut->i_rx = 1;  break;
         case 940000: dut->i_rx = 0;  break;
         case 970000: dut->i_rx = 1;  break;
         case 1000000: dut->i_rx = 0;  break;
         case 1030000: dut->i_rx = 1;  break;
      }
   }
   
   m_trace->close();
   delete dut;
   exit(EXIT_SUCCESS);
}

