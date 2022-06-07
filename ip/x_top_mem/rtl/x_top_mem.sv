module x_top_mem#(
   p_clk_hz  = 1000000, 
   p_baud    = 9600,
   p_timeout = 100000
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
   input    logic          i_rx,
   output   logic          o_tx
);

   localparam int p_timeout_width = $clog2(p_timeout);

   typedef enum logic [6:0] {
      IDLE,W_CMD,R_CMD,
      W0,W1,W2,W3,WD0,WD1,WD2,WD3,
      R0,R1,R2,R3,RD0,RD1,RD2,RD3,
      WF
   } sm_t;
 
   logic                            timeout;
   logic    [p_timeout_width-1:0]   timeout_inc;
   logic    [p_timeout_width-1:0]   timeout_d;
   logic    [p_timeout_width-1:0]   timeout_q;
   logic                            timeout_en;

   logic    [7:0]                   tx_data; 
   logic                            tx_valid;
   logic                            tx_accept;

   logic    [7:0]                   rx_data;
   logic                            rx_valid;

   logic                            ack_and_sent;
   sm_t                             sm_d;
   sm_t                             sm_q;
   logic                            sm_en;

   logic                            tx_valid_q;
   logic                            tx_valid_d;
 
   logic                            rx_ack_d;
   logic                            rx_ack_q;

   ///////////////////////////////////////////////////////////////////
   // Timeout

   assign timeout     = (timeout_q == p_timeout);
   assign timeout_inc = (timeout_q + 'd1);
   assign timeout_d   = (sm_en) ? 'd0 : timeout_inc; 
   assign timeout_en  = (sm_q != IDLE);  

   always_ff@(posedge i_clk or negedge i_nrst) begin
      if(!i_nrst)          timeout_q <= 'd0;
      else if(timeout_en)  timeout_q <= timeout_d;
   end 

   ///////////////////////////////////////////////////////////////////
   // State Machine

   assign ack_and_sent = (rx_ack_q & ~tx_valid_q);

   assign sm_en = (sm_q == IDLE              ) ? i_valid: 
                  (sm_q inside {R_CMD, W_CMD}) ? tx_accept:
                  (sm_q == WF                ) ? rx_ack_q:
                                                 (timeout | ack_and_sent);
                  
   always_comb begin
      case(sm_q) 
         IDLE:       if(i_rnw)   sm_d = R_CMD;
                     else        sm_d = W_CMD;
         R_CMD:                  sm_d = R0;
         R0:         if(timeout) sm_d = R_CMD;
                     else        sm_d = R1;
         R1:         if(timeout) sm_d = R_CMD;
                     else        sm_d = R2; 
         R2:         if(timeout) sm_d = R_CMD;
                     else        sm_d = R3; 
         R3:         if(timeout) sm_d = R_CMD;
                     else        sm_d = RD0; 
         RD0:        if(timeout) sm_d = R_CMD;
                     else        sm_d = RD1;
         RD1:        if(timeout) sm_d = R_CMD;
                     else        sm_d = RD2;
         RD2:        if(timeout) sm_d = R_CMD;
                     else        sm_d = RD3;
         RD3:        if(timeout) sm_d = IDLE;
                     else        sm_d = R_CMD;
         W_CMD:                  sm_d = W0;
         W0:         if(timeout) sm_d = W_CMD;
                     else        sm_d = W1; 
         W1:         if(timeout) sm_d = W_CMD;
                     else        sm_d = W2;  
         W2:         if(timeout) sm_d = W_CMD;
                     else        sm_d = W3;  
         W3:         if(timeout) sm_d = W_CMD;
                     else        sm_d = WD0;  
         WD0:        if(timeout) sm_d = W_CMD;
                     else        sm_d = WD1; 
         WD1:        if(timeout) sm_d = W_CMD;
                     else        sm_d = WD2; 
         WD2:        if(timeout) sm_d = W_CMD;
                     else        sm_d = WD3; 
         WD3:        if(timeout) sm_d = W_CMD;
                     else        sm_d = WF;
         WF:         if(timeout) sm_d = W_CMD;
                     else        sm_d = IDLE;
         default:                sm_d = IDLE;
      endcase
   end 

   always_ff@(posedge i_clk or negedge i_nrst) begin
      if(!i_nrst)    sm_q <= IDLE;
      else if(sm_en) sm_q <= sm_d;
   end 
   
   ///////////////////////////////////////////////////////////////////
   // Mem interface

   assign o_accept = (sm_q == WF) & rx_ack_q;


   ///////////////////////////////////////////////////////////////////
   // Tx

   always_comb begin
      case(sm_q) 
         W_CMD:   tx_data = 8'b00000000;
         R_CMD:   tx_data = 8'h00000001; 
         W0,R0:   tx_data = i_addr[7:0];
         W1,R1:   tx_data = i_addr[15:8];
         W2,R2:   tx_data = i_addr[23:16];
         W3,R3:   tx_data = i_addr[31:24];
         WD0:     tx_data = i_data[7:0]; 
         WD1:     tx_data = i_data[15:8]; 
         WD2:     tx_data = i_data[23:16]; 
         WD3:     tx_data = i_data[31:24];
         default: tx_data = 'd0;
      endcase
   end

   assign tx_valid_d = (sm_en & ~(sm_q inside {WD3,WF})) | (tx_valid_q & ~tx_accept);

   always_ff@(posedge i_clk or negedge i_nrst) begin
      if(!i_nrst)    tx_valid_q <= 1'b0;
      else           tx_valid_q <= tx_valid_d;
   end 
   
   x_top_uart_tx #(
      .p_clk_hz   (p_clk_hz   ),
      .p_baud     (p_baud     )
   ) u_tx (
      .i_clk      (i_clk      ),
      .i_nrst     (i_nrst     ),
      .i_data     (tx_data    ),
      .o_tx       (o_tx       ),
      .i_valid    (tx_valid_q ),
      .o_accept   (tx_accept  )
   );

   ///////////////////////////////////////////////////////////////////
   // Rx
 
   assign rx_ack_d = (rx_ack_q) ? ~sm_en : rx_valid;   

   always_ff@(posedge i_clk or negedge i_nrst) begin
      if(!i_nrst)    rx_ack_q <= 1'b0;
      else           rx_ack_q <= rx_ack_d;
   end 
   
   x_top_uart_rx #(
      .p_clk_hz   (p_clk_hz   ),
      .p_baud     (p_baud     )
   ) u_rx (
      .i_clk      (i_clk      ),
      .i_nrst     (i_nrst     ),
      .i_rx       (i_rx       ),
      .o_valid    (rx_valid   ),
      .o_data     (rx_data    )
   );

endmodule
