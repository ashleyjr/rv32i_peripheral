module x_top_uart_test#(
   p_clk_hz = 12000000, 
   p_baud   = 115200
)(
   input    logic       i_clk,
   input    logic       i_nrst,
   input    logic       i_rx,
   output   logic       o_tx,
   output   logic       o_led0,
   output   logic       o_led1,
   output   logic       o_led2,
   output   logic       o_led3,
   output   logic       o_led4,
   output   logic       o_led5,
   output   logic       o_led6,
   output   logic       o_led7
);

   logic [7:0] data;
   logic       rx_valid;
   logic       valid_d;
   logic       valid_q;
   logic       accept;

   assign { o_led7,
            o_led6,
            o_led5,
            o_led4,
            o_led3,
            o_led2,
            o_led1,
            o_led0 } = data;

   assign valid_d = (rx_valid | valid_q) & ~accept;

   always_ff@(posedge i_clk or negedge i_nrst) begin
      if(!i_nrst) valid_q <= 'd0;
      else        valid_q <= valid_d;
   end

   x_top_uart_tx #(
      .p_clk_hz   (p_clk_hz   ),
      .p_baud     (p_baud     )
   ) u_tx (
      .i_clk      (i_clk      ),
      .i_nrst     (i_nrst     ),
      .i_data     (data       ),
      .o_tx       (o_tx       ),
      .i_valid    (valid_q    ),
      .o_accept   (accept     )
   );

   x_top_uart_rx #(
      .p_clk_hz   (p_clk_hz   ),
      .p_baud     (p_baud     )
   ) u_rx (
      .i_clk      (i_clk      ),
      .i_nrst     (i_nrst     ),
      .i_rx       (i_rx       ),
      .o_valid    (rx_valid   ),
      .o_data     (data       )
   );
endmodule
