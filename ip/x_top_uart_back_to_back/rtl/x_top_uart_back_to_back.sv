module x_top_uart_back_to_back#(
   p_clk_hz = 1000000, 
   p_baud   = 9600
)(
   input    logic       i_clk,
   input    logic       i_nrst, 
   input    logic [7:0] i_data, 
   input    logic       i_valid,
   output   logic       o_accept,
   output   logic       o_valid,    
   output   logic [7:0] o_data
);

   logic uart;

   x_top_uart_tx #(
      .p_clk_hz   (p_clk_hz   ),
      .p_baud     (p_baud     )
   ) u_tx (
      .i_clk      (i_clk      ),
      .i_nrst     (i_nrst     ),
      .i_data     (i_data     ),
      .o_tx       (uart       ),
      .i_valid    (i_valid    ),
      .o_accept   (o_accept   )
   );

   x_top_uart_rx #(
      .p_clk_hz   (p_clk_hz   ),
      .p_baud     (p_baud     )
   ) u_rx (
      .i_clk      (i_clk      ),
      .i_nrst     (i_nrst     ),
      .i_rx       (uart       ),
      .o_valid    (o_valid    ),
      .o_data     (o_data     )
   );
endmodule
