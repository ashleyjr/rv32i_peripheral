module x_top_rv32i_rf_bram (
   input    logic          i_nrst,
   input    logic          i_clk, 
   input    logic          i_wnr,
   input    logic [4:0]    i_addr,
   input    logic [15:0]   i_data,  
   output   logic [15:0]   o_data
);

   logic re;
   logic we;

   assign re = ~i_wnr;
   assign we =  i_wnr;

`ifndef SIM

   SB_RAM40_4K #(
      .WRITE_MODE (32'sd0           ),
      .READ_MODE  (32'sd0           )
   ) u_ram_rs1 (
      .MASK       (16'hxxxx         ),
      .RDATA      (o_data           ),
      .RADDR      ({3'b000, i_addr} ),
      .RCLK       (i_clk            ),
      .RCLKE      (1'b1             ),
      .RE         (re               ),
      .WADDR      ({3'b000, i_addr} ),
      .WCLK       (i_clk            ),
      .WCLKE      (1'b1             ),
      .WDATA      (i_data           ),
      .WE         (we               )
   );

`else

   logic [15:0] mem [31:0]; 
   
   always@(posedge i_clk or negedge i_nrst) begin 
      if(!i_nrst) o_data <= 16'hxxxx; 
      else begin
         if(re)   o_data <= mem[i_addr];
         else     o_data <= 16'hxxxx; 
      end
   end 
   
   always@(posedge i_clk) begin  
      if(we) mem[i_addr] <= i_data; 
   end

`endif

endmodule
