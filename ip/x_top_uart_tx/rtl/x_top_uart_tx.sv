module uart_tx(
   input    logic          i_clk,
   input    logic          i_nrst,
   input    logic [31:0]   i_data,
   output   logic          o_tx,
   input    logic          i_valid,
   output   logic          o_accept
);

   typedef enum logic [3:0] {
      TX1,
      TX2,
      TX3,
      TX4,
      TX5,
      TX6,
      TX7,
      TX8,
      TX_END,
      TX_IDLE,
      TX_START
   } sm_t;
   
   sm_t  sm_q;
   sm_t  sm_d;   

   always_ff@(posedge i_clk or negedge i_nrst) begin
      if(!i_nrst) sm_q <= TX_IDLE;
      else        sm_q <= sm_d;
   end
   
endmodule
