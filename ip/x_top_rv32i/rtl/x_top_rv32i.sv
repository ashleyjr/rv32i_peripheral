module x_top_rv32i(
   input    logic          i_clk,
   input    logic          i_nrst, 
   input    logic [31:0]   i_data, 
   input    logic          i_accept,
   output   logic          o_accept,
   output   logic          o_valid,    
   output   logic [31:0]   o_data
);
   
   typedef struct packed {
      logic [6:0]    funct7;
      logic [4:0]    rs2;
      logic [4:0]    rs1;
      logic [2:0]    funct3;
      logic [4:0]    rd;
      logic [6:0]    opcode;
   } is_r_t;

   typedef struct packed {
      logic [11:0]   imm_11_0; 
      logic [4:0]    rs1;
      logic [2:0]    funct3;
      logic [4:0]    rd;
      logic [6:0]    opcode;
   } is_i_t;

   typedef struct packed {
      logic [6:0]    imm_11_0;
      logic [4:0]    rs2;
      logic [4:0]    rs1;
      logic [2:0]    funct3;
      logic [4:0]    imm_4_0;
      logic [6:0]    opcode;
   } is_s_t;

   typedef struct packed {
      logic [6:0]    imm_12_10_5;
      logic [4:0]    rs2;
      logic [4:0]    rs1;
      logic [2:0]    funct3;
      logic [4:0]    imm_4_1_11;
      logic [6:0]    opcode;
   } is_b_t;

   typedef struct packed { 
      logic [19:0]   imm;
      logic [4:0]    rd;
      logic [6:0]    opcode;
   } is_u_j_t;

   typedef struct packed {
      logic [24:0]   unknown;    
      logic [4:0]    opcode;
      logic [1:0]    always_one;
   } is_unknown_t;

   typedef union packed {
      is_r_t         r;
      is_i_t         i;
      is_s_t         s;
      is_b_t         b;
      is_u_j_t       u_j;
      is_unknown_t   unknown;
      logic [31:0]   data;
   } is_t;

   typedef enum logic [2:0] {
      R, I, S, B, U, J   
   } type_t;

   typedef enum logic [3:0] {
      FETCH, 
      DECODE,
      EXECUTE_R,
      EXECUTE_I,
      EXECUTE_S,
      EXECUTE_B,
      EXECUTE_U,
      EXECUTE_J
   } sm_t; 

   logic          sm_en;
   sm_t           sm_q;
   sm_t           sm_d;

   logic          pc_en;
   logic [31:0]   pc_q;
   logic [31:0]   pc_d;

   logic          is_en;
   is_t           is_q;
   is_t           is_d;

   logic                rf_en;
   logic [31:0] [31:0]  rf_d;
   logic [31:0] [31:0]  rf_q;

   logic [31:0]         alu_a;
   logic [31:0]         alu_b;
   logic [31:0]         alu_c;

   logic [7:0]    opcode;

   ///////////////////////////////////////////////////////////////////
   // State Machine
   //    - Includes instruction type decode

   always_comb begin
      sm_en = 1'b0;
      case(sm_q)
         FETCH:      sm_en = i_accept;  
         DECODE:     sm_en = 1'b1; 
         EXECUTE_I:  sm_en = 1'b1;
         default:;
      endcase
   end
   
   always_comb begin
      sm_d = FETCH;
      case(sm_q)
         FETCH:   sm_d = DECODE; 
         DECODE:  case(is_q.unknown.opcode)
                     5'b00100: sm_d = EXECUTE_I;           
                     default:;
                  endcase
         default:;
      endcase
   end

   always_ff@(posedge i_clk or negedge i_nrst) begin
      if(!i_nrst)    sm_q <= 'd0;
      else if(sm_en) sm_q <= sm_d;
   end
    
   ///////////////////////////////////////////////////////////////////
   // Reg File

   always_comb begin
      rf_d = rf_q;
      rf_d[is_q.i.rd] = alu_c;  
   end

   always_ff@(posedge i_clk or negedge i_nrst) begin
      if(!i_nrst)    rf_q <= 'd0;
      else if(rf_en) rf_q <= rf_d;
   end
  
   ///////////////////////////////////////////////////////////////////
   // ALU

   assign alu_a = rf_q[is_q.i.rs1];
   assign alu_b = {20'd0, is_q.i.imm_11_0};

   always_comb begin
      alu_c = alu_a & alu_b;
      case(is_q.i.funct3)
         3'b000:     alu_c = alu_a + alu_b;
         3'b010,
         3'b011:     alu_c = (alu_a < alu_b) ?  32'd1 : 32'd0; 
         3'b100:     alu_c = alu_a ^ alu_b;
         3'b110:     alu_c = alu_a | alu_b;
         default:; 
      endcase
   end

   ///////////////////////////////////////////////////////////////////
   // Program Counter
   
   always_ff@(posedge i_clk or negedge i_nrst) begin
      if(!i_nrst)    pc_q <= 'd0;
      else if(pc_en) pc_q <= pc_d;
   end
 
   ///////////////////////////////////////////////////////////////////
   // Store Instruction
   
   assign is_en     = (sm_q == FETCH) & i_accept;
   assign is_d.data = i_data;

   always_ff@(posedge i_clk or negedge i_nrst) begin
      if(!i_nrst)    is_q <= 'd0;
      else if(is_en) is_q <= is_d;
   end
    
   ///////////////////////////////////////////////////////////////////
   // Drive Memory Interface

   assign o_valid = (sm_q == FETCH);
   assign o_data  = (sm_q == FETCH) ? pc_q : 'd0;

endmodule
