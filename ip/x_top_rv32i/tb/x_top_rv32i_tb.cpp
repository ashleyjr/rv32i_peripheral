#include <stdlib.h>
#include <iostream>
#include <fstream>
#include <sstream>
#include <string>
#include <list>
#include <iomanip>
#include <verilated.h>
#include <verilated_vcd_c.h>
#include "Vx_top_rv32i.h"

#define MEM_SIZE     0x10000
#define MAX_SIM_TIME 100

vluint64_t sim_time = 0;

int main(int argc, char** argv, char** env) {
   Vx_top_rv32i *dut = new Vx_top_rv32i;
   
   Verilated::traceEverOn(true);
   VerilatedVcdC *m_trace = new VerilatedVcdC;
   dut->trace(m_trace, 5);
   m_trace->open("waveform.vcd");

   // Check file specified
   if(argc != 2){
      std::cout << "No .mem file specified\n\r";
      exit(EXIT_FAILURE);
   }
   
   // Load the memory file 
   unsigned int mem[MEM_SIZE]; 
   unsigned int i = 0;
   std::ifstream infile(argv[1]);
   std::string line; 
   while(std::getline(infile, line)){
      std::istringstream iss(line);  
      std::stringstream ss;
      ss << std::hex << line;
      ss >> mem[i];
      i++;
   }

   dut->i_clk = 0;
   dut->i_nrst = 0;
   
   std::cout << "sim_time   addr         data\n\r";
   while (sim_time < MAX_SIM_TIME) {
     
      dut->i_clk = 1; 
      dut->eval();
      m_trace->dump(sim_time);
      sim_time++;
      
      if(sim_time > 10){
         dut->i_nrst = 1;
         dut->i_accept = dut->o_valid;
         
         // TODO: Should be byte addressable
         dut->i_data = 0; 
         if(dut->i_accept){
            std::cout << "@";
            std::cout << std::setw(8) << std::setfill('0');
            std::cout << std::dec << sim_time << ": 0x";
            if(dut->o_rnw){
               std::cout << std::setw(8) << std::setfill('0');
               std::cout << std::hex << dut->o_addr;
               std::cout << " > 0x";
               dut->i_data = mem[dut->o_addr >> 2]; 
               std::cout << std::setw(8) << std::setfill('0'); 
               std::cout << std::hex << dut->i_data; 
            }else{
               std::cout << std::setw(8) << std::setfill('0');
               std::cout << dut->o_addr;
               std::cout << " < 0x";
               std::cout << std::setw(8) << std::setfill('0');
               std::cout << std::hex << dut->o_data;
               mem[dut->o_addr >> 2] = dut->o_data; 
            }
            std::cout << "\n\r";
         }
      }

      dut->i_clk = 0; 
      dut->eval();
      m_trace->dump(sim_time);
      sim_time++; 
   }
   
   m_trace->close();
   delete dut;
   exit(EXIT_SUCCESS);
}

