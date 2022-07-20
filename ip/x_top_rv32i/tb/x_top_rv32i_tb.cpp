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
#include "Vx_top_rv32i.h"

#define MEM_SIZE     0x10000
#define MAX_SIM_TIME 10000

vluint64_t sim_time = 0;

int main(int argc, char** argv, char** env) { 
   Vx_top_rv32i *dut = new Vx_top_rv32i;
  
   std::cout << "Start\n\r";
   
   Verilated::traceEverOn(true);
   VerilatedVcdC *m_trace = new VerilatedVcdC;
   dut->trace(m_trace, 5);
   m_trace->open("waveform.vcd");

   // Check file specified
   if(argc != 2){
      std::cout << "No .mem file specified\n\r";
      exit(EXIT_FAILURE);
   }
   
   // Some associative memory
   unsigned int mem[MEM_SIZE]; 
   unsigned int addr[MEM_SIZE]; 
   unsigned int usage = 0;
   unsigned int rom_size = 0;

   // How large is the ROM?
   std::ifstream infile(argv[1]);
   std::string line; 
   while(std::getline(infile, line)){ 
      std::istringstream iss(line);  
      std::stringstream ss;
      rom_size++;
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
         dut->i_accept = 0;
         
         // TODO: Should be byte addressable
         dut->i_data = 0; 
         if(dut->o_valid){
            std::cout << "@";
            std::cout << std::setw(8) << std::setfill('0');
            std::cout << std::dec << sim_time << ": 0x";
            if(dut->o_rnw){
               // Read
               
               dut->i_clk = 0; 
               dut->eval();
               m_trace->dump(sim_time);
               sim_time++; 
               
               dut->i_clk = 1; 
               dut->eval();
               m_trace->dump(sim_time);
               sim_time++; 
               
               dut->i_accept = 1;
               std::cout << std::setw(8) << std::setfill('0');
               std::cout << std::hex << dut->o_addr;
               std::cout << " > 0x";
               
               if((dut->o_addr >> 2) < rom_size){
                  // The format of the input file is known
                  // 8 hex and 1 \n so skip the byte needed
                  infile.clear();
                  infile.seekg((dut->o_addr >> 2)*9);
                  std::getline(infile, line); 
                  std::istringstream iss(line);  
                  std::stringstream ss;
                  ss << std::hex << line;
                  ss >> dut->i_data;
               }else{
                  for(int i=0;i<usage;i++){
                     if(addr[i] == (dut->o_addr >> 2)){ 
                        dut->i_data = mem[i];
                        break;
                     }
                  } 
               }
               std::cout << std::setw(8) << std::setfill('0'); 
               std::cout << std::hex << dut->i_data; 
            }else{
               // Write
               dut->i_accept = 1;
               std::cout << std::setw(8) << std::setfill('0');
               std::cout << std::hex << dut->o_addr;
               std::cout << " < 0x";
               std::cout << std::setw(8) << std::setfill('0');
               std::cout << std::hex << dut->o_data;
               bool found = false;
               for(int i=0;i<usage;i++){
                  if(addr[i] == (dut->o_addr >> 2)){
                     mem[i] = dut->o_data;
                     found = true;
                     break;
                  }
               } 
               if(!found){
                  addr[usage] = (dut->o_addr >> 2);
                  mem[usage] = dut->o_data;
                  usage++;
               } 
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

