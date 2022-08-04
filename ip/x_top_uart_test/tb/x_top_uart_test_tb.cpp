#include <stdlib.h>
#include <iostream>
#include <verilated.h>
#include <verilated_vcd_c.h>
#include "Vx_top_uart_test.h"

#define MAX_SIM_TIME 1000000
vluint64_t sim_time = 0;

int main(int argc, char** argv, char** env) {
   Vx_top_uart_test *dut = new Vx_top_uart_test;
   
   Verilated::traceEverOn(true);
   VerilatedVcdC *m_trace = new VerilatedVcdC;
   dut->trace(m_trace, 5);
   m_trace->open("waveform.vcd");

   dut->i_nrst = 0;
   dut->i_rx = 1;

   while (sim_time < MAX_SIM_TIME) {
      dut->i_clk ^= 1;
      
      dut->eval();
      m_trace->dump(sim_time);
      sim_time++;

      switch(sim_time){
         case 1:    dut->i_nrst = 1; break;
         case 5000: dut->i_rx = 0; break;
         case 5600: dut->i_rx = 1; break;
         case 5800: dut->i_rx = 0; break;
         case 6900: dut->i_rx = 1; break;
         default:;
      }

   }
   
   m_trace->close();
   delete dut;
   exit(EXIT_SUCCESS);
}

