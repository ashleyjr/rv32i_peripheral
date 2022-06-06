#include <stdlib.h>
#include <iostream>
#include <verilated.h>
#include <verilated_vcd_c.h>
#include "Vx_top_mem.h"

#define MAX_SIM_TIME 2000000

vluint64_t sim_time = 0;

int main(int argc, char** argv, char** env) {
   Vx_top_mem *dut = new Vx_top_mem;
   
   Verilated::traceEverOn(true);
   VerilatedVcdC *m_trace = new VerilatedVcdC;
   dut->trace(m_trace, 5);
   m_trace->open("waveform.vcd");
   
   while (sim_time < MAX_SIM_TIME) {
      dut->i_clk ^= 1; 
      
      if(sim_time == 10) 
         dut->i_nrst = 1;
 
      if(sim_time == 1000){ 
         dut->i_rnw   = 0;
         dut->i_valid = 1;
         dut->i_addr  = 55;
         dut->i_data  = 777;
      }

      dut->eval();
      m_trace->dump(sim_time);
      sim_time++;
   }
   
   m_trace->close();
   delete dut;
   exit(EXIT_SUCCESS);
}

