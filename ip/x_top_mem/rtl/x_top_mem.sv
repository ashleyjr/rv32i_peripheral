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
      IDLE,
      W_CMD,W_CMD_A,
      W0,W1,W2,W3,
      W0_A,W1_A,W2_A,W3_A,
      WD0,WD1,WD2,WD3,
      WD0_A,WD1_A,WD2_A,WD3_A, 
      R_CMD,R_CMD_A,
      R0,R1,R2,R3,
      R0_A,R1_A,R2_A,R3_A,
      RD0,RD1,RD2,RD3,
      RD0_A,RD1_A,RD2_A,RD3_A
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

   logic                            sm_tx;
   logic                            sm_ack;
   sm_t                             sm_d;
   sm_t                             sm_q;
   logic                            sm_en;
   logic                            p0_sm_en;
   logic                            p1_sm_en;
   
   logic                            tx_valid_q;
   logic                            tx_valid_d;

   logic                            data_en;
   logic    [23:0]                  data_d;
   logic    [23:0]                  data_q;

   logic                            rx_ack_d;
   logic                            rx_ack_q;

   ///////////////////////////////////////////////////////////////////
   // State Machine

   assign sm_tx = sm_q inside {R_CMD,R0,R1,R2,R3,RD0_A,RD1_A,RD2_A,RD3_A,
                               W_CMD,W0,W1,W2,W3,WD0,WD1,WD2,WD3}; 
     
   assign sm_en = (sm_q == IDLE  ) ? i_valid: 
                  (sm_tx         ) ? tx_accept: 
                                     rx_valid;
   assign p0_sm_en = sm_en;

   always_ff@(posedge i_clk or negedge i_nrst) begin
      if(!i_nrst) p1_sm_en <= 1'b0;
      else        p1_sm_en <= p0_sm_en;
   end   

   always_comb begin
      case(sm_q) 
         IDLE:       if(i_rnw)   sm_d = R_CMD;
                     else        sm_d = W_CMD;
         R_CMD:                  sm_d = R_CMD_A; 
         R_CMD_A:                sm_d = R0;    
         R0:                     sm_d = R0_A;
         R0_A:                   sm_d = R1; 
         R1:                     sm_d = R1_A;
         R1_A:                   sm_d = R2;
         R2:                     sm_d = R2_A;
         R2_A:                   sm_d = R3;
         R3:                     sm_d = R3_A;
         R3_A:                   sm_d = RD0;
         RD0:                    sm_d = RD0_A;
         RD0_A:                  sm_d = RD1;
         RD1:                    sm_d = RD1_A;
         RD1_A:                  sm_d = RD2;
         RD2:                    sm_d = RD2_A;
         RD2_A:                  sm_d = RD3;
         RD3:                    sm_d = RD3_A;
         W_CMD:                  sm_d = W_CMD_A; 
         W_CMD_A:                sm_d = W0;    
         W0:                     sm_d = W0_A;
         W0_A:                   sm_d = W1; 
         W1:                     sm_d = W1_A;
         W1_A:                   sm_d = W2;
         W2:                     sm_d = W2_A;
         W2_A:                   sm_d = W3;
         W3:                     sm_d = W3_A;
         W3_A:                   sm_d = WD0;
         WD0:                    sm_d = WD0_A;
         WD0_A:                  sm_d = WD1;
         WD1:                    sm_d = WD1_A;
         WD1_A:                  sm_d = WD2;
         WD2:                    sm_d = WD2_A;
         WD2_A:                  sm_d = WD3;
         WD3:                    sm_d = WD3_A;
         default:                sm_d = IDLE;
      endcase
   end 

   always_ff@(posedge i_clk or negedge i_nrst) begin
      if(!i_nrst)    sm_q <= IDLE;
      else if(sm_en) sm_q <= sm_d;
   end 
   
   ///////////////////////////////////////////////////////////////////
   // Mem interface

   assign o_accept = (sm_q inside {WD3_A,RD3_A}) & sm_en;

   assign data_en = (sm_q inside {RD0, RD1, RD2}) & rx_valid;

   assign data_d = {rx_data,data_q[23:8]};
   
   always_ff@(posedge i_clk or negedge i_nrst) begin
      if(!i_nrst)       data_q <= 'd0;
      else if(data_en)  data_q <= data_d;
   end

   assign o_data = {rx_data,data_q};
  
   ///////////////////////////////////////////////////////////////////
   // Tx

   always_comb begin
      case(sm_q) 
         W_CMD:   tx_data = 8'h0F;
         R_CMD:   tx_data = 8'hF0; 
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

   assign tx_valid = sm_tx;
   
   x_top_uart_tx #(
      .p_clk_hz   (p_clk_hz   ),
      .p_baud     (p_baud     )
   ) u_tx (
      .i_clk      (i_clk      ),
      .i_nrst     (i_nrst     ),
      .i_data     (tx_data    ),
      .o_tx       (o_tx       ),
      .i_valid    (tx_valid   ),
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
