module x_top_mem_link#(
   p_clk_hz = 1000000, 
   p_baud   = 9600
)(
   input    logic          i_clk,
   input    logic          i_nrst,
   // Mem Interface
   input    logic          i_rnw,
   input    logic          i_valid,
   output   logic          o_accept,
   input    logic [31:0]   i_addr,
   input    logic [31:0]   i_data, 
   output   logic [31:0]   o_data,
   // UART Interface
   input    logic [7:0]    i_uart_data, 
   input    logic          i_uart_valid,
   output   logic          o_uart_accept,
   output   logic          o_uart_valid,    
   output   logic [7:0]    o_uart_data
);

   logic rx;
   logic tx;

   ///////////////////////////////////////////////////////////////////
   // DUT

   x_top_mem #(
      .p_clk_hz   (p_clk_hz   ),
      .p_baud     (p_baud     )
   ) u_top_mem (
      .i_clk      (i_clk      ),
      .i_nrst     (i_nrst     ),
      .i_rnw      (i_rnw      ),
      .i_valid    (i_valid    ),
      .o_accept   (o_accept   ),
      .i_addr     (i_addr     ),
      .i_data     (i_data     ), 
      .o_data     (o_data     ),         
      .i_rx       (rx         ),
      .o_tx       (tx         )
   );

 
   ///////////////////////////////////////////////////////////////////
   // Tx
 
   x_top_uart_tx #(
      .p_clk_hz   (p_clk_hz      ),
      .p_baud     (p_baud        )
   ) u_tx (
      .i_clk      (i_clk         ),
      .i_nrst     (i_nrst        ),
      .i_data     (i_uart_data   ),
      .o_tx       (rx            ),
      .i_valid    (i_uart_valid  ),
      .o_accept   (o_uart_accept )
   );

   ///////////////////////////////////////////////////////////////////
   // Rx
 
   x_top_uart_rx #(
      .p_clk_hz   (p_clk_hz      ),
      .p_baud     (p_baud        )
   ) u_rx (
      .i_clk      (i_clk         ),
      .i_nrst     (i_nrst        ),
      .i_rx       (tx            ),
      .o_valid    (o_uart_valid  ),
      .o_data     (o_uart_data   )
   );

endmodule
