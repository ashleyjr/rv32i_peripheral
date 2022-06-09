module x_top_uart_test#(
   p_clk_hz = 1000000, 
   p_baud   = 9600
)(
   input    logic       i_clk,
   input    logic       i_nrst,
   input    logic       i_rx,
   output   logic       o_tx
);

   logic [7:0] data;
   logic       valid;

   x_top_uart_tx #(
      .p_clk_hz   (p_clk_hz   ),
      .p_baud     (p_baud     )
   ) u_tx (
      .i_clk      (i_clk      ),
      .i_nrst     (i_nrst     ),
      .i_data     (data       ),
      .o_tx       (o_tx       ),
      .i_valid    (valid      ),
      .o_accept   (           )
   );

   x_top_uart_rx #(
      .p_clk_hz   (p_clk_hz   ),
      .p_baud     (p_baud     )
   ) u_rx (
      .i_clk      (i_clk      ),
      .i_nrst     (i_nrst     ),
      .i_rx       (i_rx       ),
      .o_valid    (valid      ),
      .o_data     (data       )
   );
endmodule
