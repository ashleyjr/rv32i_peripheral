#include <stdlib.h>
#include <iostream>
#include <verilated.h>
#include <verilated_vcd_c.h>
#include "Vx_top_rv32i.h"

#define MAX_SIM_TIME 100
vluint64_t sim_time = 0;

int main(int argc, char** argv, char** env) {
   Vx_top_rv32i *dut = new Vx_top_rv32i;
   
   Verilated::traceEverOn(true);
   VerilatedVcdC *m_trace = new VerilatedVcdC;
   dut->trace(m_trace, 5);
   m_trace->open("waveform.vcd");
  
   dut->i_clk = 0;
   dut->i_nrst = 0;
   while (sim_time < MAX_SIM_TIME) {
     
      if(sim_time > 10){
         dut->i_nrst = 1;
      }

      dut->i_accept = dut->o_valid;
      dut->i_data = 0x010000013; 
         

      for(int i=0;i<2;i++){
         dut->i_clk ^= 1; 
         dut->eval();
         m_trace->dump(sim_time);
         sim_time++;
      }
   }
   
   m_trace->close();
   delete dut;
   exit(EXIT_SUCCESS);
}

