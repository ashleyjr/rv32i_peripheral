module x_top_rv32i_rf (
   input    wire           i_nrst,
   input    wire           i_clk,
   input    wire           i_wnr,
   input    logic [4:0]    i_rs1,
   output   logic [31:0]   o_rs1_data, 
   input    logic [4:0]    i_rs2,
   output   logic [31:0]   o_rs2_data,
   input    logic [4:0]    i_rd,
   input    logic [31:0]   i_rd_data
);
   
   logic [4:0]    rs1;
   logic [31:0]   rs1_data;
   logic          rs1_zero_d;
   logic          rs1_zero_q;

   logic [4:0]    rs2; 
   logic [31:0]   rs2_data;
   logic          rs2_zero_d;
   logic          rs2_zero_q;

   assign rs1 = (i_wnr) ? i_rd : i_rs1;
   assign rs2 = (i_wnr) ? i_rd : i_rs2;
  
   assign rs1_zero_d = (i_rs1 == 'd0);
   
   always_ff@(posedge i_clk or negedge i_nrst) begin
      if(!i_nrst) rs1_zero_q <= 'd0;
      else        rs1_zero_q <= rs1_zero_d;
   end

   assign rs2_zero_d = (i_rs2 == 'd0);
   
   always_ff@(posedge i_clk or negedge i_nrst) begin
      if(!i_nrst) rs2_zero_q <= 'd0;
      else        rs2_zero_q <= rs2_zero_d;
   end

   assign o_rs1_data = rs1_data & {32{~rs1_zero_q}};
   assign o_rs2_data = rs2_data & {32{~rs2_zero_q}};

   x_top_rv32i_rf_bram u_rs1_l(
      .i_nrst  (i_nrst           ),
      .i_clk   (i_clk            ), 
      .i_wnr   (i_wnr            ),
      .i_addr  (rs1              ),
      .i_data  (i_rd_data[15:0]  ),  
      .o_data  (rs1_data[15:0]   )
   );

   x_top_rv32i_rf_bram u_rs1_h(
      .i_nrst  (i_nrst           ),
      .i_clk   (i_clk            ), 
      .i_wnr   (i_wnr            ),
      .i_addr  (rs1              ),
      .i_data  (i_rd_data[31:16] ),  
      .o_data  (rs1_data[31:16]  )
   );

   x_top_rv32i_rf_bram u_rs2_l(
      .i_nrst  (i_nrst           ),
      .i_clk   (i_clk            ), 
      .i_wnr   (i_wnr            ),
      .i_addr  (rs2              ),
      .i_data  (i_rd_data[15:0]  ),  
      .o_data  (rs2_data[15:0] )
   );

   x_top_rv32i_rf_bram u_rs2_h(
      .i_nrst  (i_nrst           ),
      .i_clk   (i_clk            ), 
      .i_wnr   (i_wnr            ),
      .i_addr  (rs2              ),
      .i_data  (i_rd_data[31:16] ),  
      .o_data  (rs2_data[31:16]  )
   );

endmodule
