// RUN: verilator --trace --cc ip/x_top_urt_tx/rtl/x_top_uart_tx.sv --exe ip/x_top_uart_tx/tb/x_top_uart_tx_tb.cpp 
#include <stdlib.h>
#include <iostream>
#include <verilated.h>
#include <verilated_vcd_c.h>
#include "Vx_top_uart_rx.h"

#define MAX_SIM_TIME 1000000
vluint64_t sim_time = 0;

int main(int argc, char** argv, char** env) {
   Vx_top_uart_rx *dut = new Vx_top_uart_rx;
   
   Verilated::traceEverOn(true);
   VerilatedVcdC *m_trace = new VerilatedVcdC;
   dut->trace(m_trace, 5);
   m_trace->open("waveform.vcd");
   
   while (sim_time < MAX_SIM_TIME) {
      dut->i_clk ^= 1;
      
     
      dut->eval();
      m_trace->dump(sim_time);
      sim_time++;
   }
   
   m_trace->close();
   delete dut;
   exit(EXIT_SUCCESS);
}

