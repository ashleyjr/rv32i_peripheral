module x_top #(
   p_clk_hz    = 1200000, 
   p_baud      = 115200,
   p_timeout   = 100000
)(
   input    logic       i_clk,
   input    logic       i_nrst,
   input    logic       i_rx,
   output   logic       o_tx
);
 
   logic          rnw;
   logic          valid;
   logic          accept;
   logic [31:0]   addr;
   logic [31:0]   data_rv; 
   logic [31:0]   data_mem;

   x_top_rv32i u_rv (
      .i_clk      (i_clk      ),
      .i_nrst     (i_nrst     ), 
      .i_data     (data_rv    ), 
      .i_accept   (accept     ),
      .o_valid    (valid      ),  
      .o_rnw      (rnw        ),
      .o_addr     (addr       ),
      .o_data     (data_mem   )
   );

   x_top_mem #(
      .p_clk_hz   (p_clk_hz   ),
      .p_baud     (p_baud     ),
      .p_timeout  (p_timeout  )
   ) u_mem (
      .i_clk      (i_clk      ),
      .i_nrst     (i_nrst     ),
      .i_rnw      (rnw        ),
      .i_valid    (valid      ),
      .o_accept   (accept     ),
      .i_addr     (addr       ),
      .i_data     (data_mem   ),
      .o_data     (data_rv    ),
      .i_rx       (i_rx       ),
      .o_tx       (o_tx       )
   );

endmodule
