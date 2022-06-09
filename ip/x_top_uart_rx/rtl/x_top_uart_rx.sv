module x_top_uart_rx#(
   p_clk_hz = 1000000, 
   p_baud   = 9600
)(
   input    logic       i_clk,
   input    logic       i_nrst,
   input    logic       i_rx,
   output   logic       o_valid,    
   output   logic [7:0] o_data
);
 
   localparam p_timer_top   = 1000;
   localparam p_timer_half  = p_timer_top / 2;
   localparam p_timer_width = $clog2(p_timer_top);
    
   typedef enum logic [6:0] {
      IDLE, START, 
      A0, A1, A2, A3, A4, A5, A6, A7, P0
   } sm_uart_t;
 
   logic                      p0_rx;
   logic                      p1_rx;
   logic                      p2_rx;
   logic                      p3_rx;

   logic                      rx_rise;
   logic                      rx_fall;

   sm_uart_t                  sm_uart_q;
   sm_uart_t                  sm_uart_d;  
   sm_uart_t                  sm_uart_inc;  
   logic                      sm_uart_en;
   logic                      sm_uart_idle;
   logic                      sm_uart_start;

   logic                      timer_top;
   logic                      timer_half;
   logic                      timer_wrap;
   logic [p_timer_width-1:0]  timer_inc;
   logic [p_timer_width-1:0]  timer_d;
   logic [p_timer_width-1:0]  timer_q;
   logic                      timer_en;

   logic [7:0]                data_d;
   logic [7:0]                data_q;
   logic                      data_en;

   ///////////////////////////////////////////////////////////////////
   // Resync Input
  
   assign p0_rx = i_rx;

   always_ff@(posedge i_clk or negedge i_nrst) begin
      if(!i_nrst) p1_rx <= 'd1;
      else        p1_rx <= p0_rx;
   end
 
   always_ff@(posedge i_clk or negedge i_nrst) begin
      if(!i_nrst) p2_rx <= 'd1;
      else        p2_rx <= p1_rx;
   end   
   
   always_ff@(posedge i_clk or negedge i_nrst) begin
      if(!i_nrst) p3_rx <= 'd1;
      else        p3_rx <= p2_rx;
   end   
  
   assign rx_rise =  p2_rx & ~p3_rx;
   assign rx_fall = ~p2_rx &  p3_rx;

   ///////////////////////////////////////////////////////////////////
   // Timer

   assign timer_top  = (timer_q == p_timer_top);
   assign timer_half = (timer_q == p_timer_half) &
                       (sm_uart_q == START);
   assign timer_wrap = timer_top | timer_half;
   assign timer_inc  = timer_q + 'd1;
   assign timer_d    = (timer_wrap) ? 'd0 : timer_inc; 
   assign timer_en   =  ~sm_uart_idle |  
                       ((sm_uart_idle) & rx_fall);

   always_ff@(posedge i_clk or negedge i_nrst) begin
      if(!i_nrst)       timer_q <= 'd0;
      else if(timer_en) timer_q <= timer_d;
   end
   
   ///////////////////////////////////////////////////////////////////
   // State machine updates
  
   assign sm_uart_inc   = sm_uart_q + 'd1; 
   assign sm_uart_d     = (sm_uart_q == P0) ? IDLE  : sm_uart_inc;
   assign sm_uart_idle  = (sm_uart_q == IDLE);
   assign sm_uart_start = (sm_uart_q == START);
   assign sm_uart_en    = (sm_uart_idle ) ? rx_fall: 
                          (sm_uart_start) ? timer_half:
                                            timer_top; 

   always_ff@(posedge i_clk or negedge i_nrst) begin
      if(!i_nrst)          sm_uart_q <= IDLE;
      else if(sm_uart_en)  sm_uart_q <= sm_uart_d;
   end
  
   ///////////////////////////////////////////////////////////////////
   // Ending

   assign o_valid = (sm_uart_q == P0) & timer_top & (^data_q == p2_rx); 

   ///////////////////////////////////////////////////////////////////
   // Flop RX
 
   assign data_d  = {p2_rx, data_q[7:1]};
   assign data_en = ~(  (sm_uart_q == IDLE)|
                        (sm_uart_q == START)|
                        (sm_uart_q == P0)) & 
                      sm_uart_en;
   always_ff@(posedge i_clk or negedge i_nrst) begin
      if(!i_nrst)       data_q <= 'd0;
      else if(data_en)  data_q <= data_d;
   end

   assign o_data = data_q;
      
endmodule
