#include <stdlib.h>
#include <iostream>
#include <verilated.h>
#include <verilated_vcd_c.h>
#include "Vx_top_mem_link.h"

#define MAX_SIM_TIME 2000000

vluint64_t sim_time = 0;

int main(int argc, char** argv, char** env) {
   Vx_top_mem_link *dut = new Vx_top_mem_link;
   
   Verilated::traceEverOn(true);
   VerilatedVcdC *m_trace = new VerilatedVcdC;
   dut->trace(m_trace, 5);
   m_trace->open("waveform.vcd");
   
   while (sim_time < MAX_SIM_TIME) {
      dut->i_clk = 0; 
     
      if(sim_time == 10){
         dut->i_nrst = 1;
      }

      if(sim_time == 1000){
         dut->i_addr = 0xDEADBEEF;
         dut->i_data = 0xFEEDBEAD;
      }

      // i_valid
      if(dut->o_accept == 1){
         dut->i_valid = 0;
      }else{
         switch(sim_time){
            case 1000:     dut->i_rnw = 0;
                           dut->i_valid = 1;
                           break;
            case 1000000:  dut->i_rnw = 1;
                           dut->i_valid = 1;
                           break;
            default:       dut->i_valid = 0;
         }
      }
      
      // i_uart_valid
      switch(sim_time){
         case 100000:   
         case 200000:   
         case 300000:   
         case 400000:   
         case 500000:   
         case 600000:   
         case 700000:   
         case 800000:   
         case 900000: 
         case 1100000:
         case 1200000:
         case 1300000:
         case 1400000:
         case 1500000:
                        dut->i_uart_valid = 1;
                        break;
         case 1600000:  dut->i_uart_valid = 1;
                        dut->i_uart_data  = 0xEF;
                        break;
         case 1700000:  dut->i_uart_valid = 1;
                        dut->i_uart_data  = 0xBE;
                        break;
         case 1800000:  dut->i_uart_valid = 1;
                        dut->i_uart_data  = 0xAD;
                        break;
         case 1900000:  dut->i_uart_valid = 1;
                        dut->i_uart_data  = 0xDE;
                        break;
         default:       dut->i_uart_valid = 0;
      }

          

      dut->eval();
      m_trace->dump(sim_time);
      sim_time++;
      
      dut->i_clk = 1; 
      dut->eval();
      m_trace->dump(sim_time);
      sim_time++;
   }
   
   m_trace->close();
   delete dut;
   exit(EXIT_SUCCESS);
}

