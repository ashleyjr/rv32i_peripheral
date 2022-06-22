module x_top_rv32i(
   input    logic          i_clk,
   input    logic          i_nrst, 
   input    logic [31:0]   i_data, 
   input    logic          i_accept,
   output   logic          o_valid,  
   output   logic          o_rnw,
   output   logic [31:0]   o_addr,
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
      logic [6:0]    imm_11_5;
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
      logic [19:0]   imm_31_12;
      logic [4:0]    rd;
      logic [6:0]    opcode;
   } is_u_t;
   
   typedef struct packed {  
      logic          imm_20;
      logic [9:0]    imm_10_1;
      logic          imm_11;
      logic [7:0]    imm_19_12;
      logic [4:0]    rd;
      logic [6:0]    opcode;
   } is_j_t;

   typedef struct packed {
      logic [6:0]    u1;   
      logic [4:0]    rs2;
      logic [4:0]    rs1;
      logic [2:0]    u0;
      logic [4:0]    rd;
      logic [4:0]    opcode;
      logic [1:0]    always_one;
   } is_unknown_t;

   typedef union packed {
      is_r_t         r;
      is_i_t         i;
      is_s_t         s;
      is_b_t         b;
      is_u_t         u;
      is_j_t         j;
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
      EXECUTE_J,
      EXECUTE_L
   } sm_t; 

   logic [4:0]    rs1;
   logic [4:0]    rs2;
   logic [4:0]    rd;

   logic          sm_en;
   sm_t           sm_q;
   sm_t           sm_d;

   logic [31:0]   pc_next;
   logic signed [31:0]   pc_imm;
   logic [31:0]   pc_jump;
   logic          pc_en;
   logic [31:0]   pc_q;
   logic [31:0]   pc_d;

   logic          is_en;
   is_t           is_q;
   is_t           is_d;

   logic                rf_en;
   logic [4:0]          rf_sel;
   logic [31:0]         rf_data;
   logic [31:0] [31:0]  rf_d;
   logic [31:0] [31:0]  rf_q;

   logic                alu_add;
   logic                alu_lt;
   logic                alu_xor;
   logic                alu_or;
   logic [4:0]          alu_sel;
   logic signed [31:0]         alu_a;
   logic signed [31:0]         alu_b;
   logic signed [31:0]         alu_c;

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
         EXECUTE_J:  sm_en = 1'b1;
         EXECUTE_L:  sm_en = 1'b1;
         EXECUTE_S:  sm_en = i_accept;
         EXECUTE_U:  sm_en = 1'b1;
         default:;
      endcase
   end
   
   always_comb begin
      sm_d = FETCH;
      case(sm_q)
         FETCH:   sm_d = DECODE; 
         DECODE:  case(is_q.unknown.opcode)
                     5'b00100: sm_d = EXECUTE_I;          
                     5'b11011: sm_d = EXECUTE_J;
                     5'b01000: sm_d = EXECUTE_S;                    
                     5'b00000: sm_d = EXECUTE_L;                    
                     5'b01101: sm_d = EXECUTE_U;
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
   // Selects

   assign rs1  = is_q.unknown.rs1;
   assign rs2  = is_q.unknown.rs2;
   assign rd   = is_q.unknown.rd;

   ///////////////////////////////////////////////////////////////////
   // Reg File

   assign rf_sel = is_q.unknown.rd;
   
   always_comb begin
      rf_data = 'd0;
      case(sm_q)
         EXECUTE_I: rf_data = alu_c;  
         EXECUTE_J: rf_data = pc_d; 
         EXECUTE_U: rf_data = {is_q.u.imm_31_12,12'd0}; 
         default:;
      endcase
   end

   always_comb begin
      rf_d = rf_q; 
      rf_d[rf_sel] = rf_data;   
   end
   
   assign rf_en = (sm_q == EXECUTE_I)|
                  (sm_q == EXECUTE_L)|
                  (sm_q == EXECUTE_U); 

   always_ff@(posedge i_clk or negedge i_nrst) begin
      if(!i_nrst)    rf_q <= 'd0;
      else if(rf_en) rf_q <= rf_d;
   end
  
   ///////////////////////////////////////////////////////////////////
   // ALU

   assign alu_sel = (sm_q == EXECUTE_S) ? rs2 : rs1;
   assign alu_a   = rf_q[alu_sel];
      
   always_comb begin
      alu_b = 'd0; 
      case(sm_q)
         EXECUTE_S: alu_b[11:0] = {is_q.s.imm_11_5, is_q.s.imm_4_0};
         EXECUTE_I: alu_b = {{20{is_q.i.imm_11_0[11]}},is_q.i.imm_11_0};
         default:;
      endcase
   end

   assign alu_add = (sm_q == EXECUTE_S) | 
                   ((sm_q == EXECUTE_I) & (is_q.i.funct3 == 3'b00));

   assign alu_lt  = (sm_q == EXECUTE_I) & (
                        (is_q.i.funct3 == 3'b010) |
                        (is_q.i.funct3 == 3'b011)
                     );

   assign alu_xor = (sm_q == EXECUTE_I) & (is_q.i.funct3 == 3'b100);
   
   assign alu_or = (sm_q == EXECUTE_I) & (is_q.i.funct3 == 3'b110);
   
   always_comb begin
      alu_c = alu_a & alu_b;
      case(1'b1)
         alu_add:    alu_c = alu_a + alu_b;
         alu_lt:     alu_c = (alu_a < alu_b) ?  32'd1 : 32'd0; 
         alu_xor:    alu_c = alu_a ^ alu_b;
         alu_or:     alu_c = alu_a | alu_b;
         default:; 
      endcase
   end

   ///////////////////////////////////////////////////////////////////
   // Program Counter

   assign pc_next = pc_q + 'd4;
   assign pc_imm  = {   {11{is_q.j.imm_20}},
                        is_q.j.imm_20,
                        is_q.j.imm_19_12,
                        is_q.j.imm_11,
                        is_q.j.imm_10_1,
                        1'b0};
   assign pc_jump = pc_q + pc_imm; 
   assign pc_d    = (sm_q == EXECUTE_J) ? pc_jump : pc_next;
   assign pc_en   = (sm_q == EXECUTE_I)|
                    (sm_q == EXECUTE_J)|
                    (sm_q == EXECUTE_L)|
                    (sm_q == EXECUTE_U)|
                    (sm_q == EXECUTE_S);

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

   assign o_rnw   = (sm_q == FETCH)|
                    (sm_q == EXECUTE_L);
   assign o_valid = (sm_q == FETCH)| 
                    (sm_q == EXECUTE_L)|
                    (sm_q == EXECUTE_S);
   assign o_addr  = (sm_q == FETCH) ? pc_q : alu_c;
   
   assign o_data  = (sm_q == FETCH     ) ? pc_q : 
                    (sm_q == EXECUTE_S ) ? rf_q[rs1]:
                                           rf_q[rs2];

endmodule
