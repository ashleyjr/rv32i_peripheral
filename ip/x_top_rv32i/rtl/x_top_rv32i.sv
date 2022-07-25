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
      logic [2:0]    funct3;
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
      EXECUTE
   } sm_t; 

   logic [4:0]             rs1;
   logic [4:0]             rs2;
   logic [4:0]             rd;

   logic                   sm_f;
   logic                   sm_r;
   logic                   sm_i;
   logic                   sm_s;
   logic                   sm_b;
   logic                   sm_u;
   logic                   sm_lui; 
   logic                   sm_auipc;
   logic                   sm_j;
   logic                   sm_l;
   logic                   sm_k;
   logic                   sm_en;
   sm_t                    sm_q;
   sm_t                    sm_d;

   logic [31:0]            pc_base;
   logic [31:0]            pc_next;
   logic signed [31:0]     pc_imm;
   logic [31:0]            pc_jump;
   logic                   pc_en;
   logic                   pc_branch;
   logic signed [31:0]     pc_k;
   logic signed [31:0]     pc_b;
   logic [31:0]            pc_j;
   logic [31:0]            pc_q;
   logic [31:0]            pc_d;

   logic                   is_en;
   is_t                    is_q;
   is_t                    is_d;

   logic [31:0]            ld_data;

   logic                   rf_en;
   logic [31:0]            rf_data;
   logic [31:0]            rf_d  [31:0];
   logic [31:0]            rf_q  [31:0];
   logic [31:0]            rf_rs1;
   logic [31:0]            rf_rs2;

   logic                   alu_add;
   logic                   alu_sub;
   logic                   alu_slt;
   logic                   alu_lt;
   logic                   alu_eq;
   logic                   alu_xor;
   logic                   alu_or;
   logic                   alu_sl;
   logic                   alu_sr;
   logic                   alu_sar;
   logic [4:0]             alu_shift;
   logic signed [31:0]     s_alu_a;
   logic signed [31:0]     s_alu_b; 
   logic signed [31:0]     alu_b;
   logic signed [31:0]     alu_c;

   logic [4:0]             opcode;
   logic [2:0]             funct3;

   ///////////////////////////////////////////////////////////////////
   // State Machine
   //    - Includes instruction type decode
 
   always_comb begin
      sm_d = FETCH;
      case(sm_q)
         FETCH:   sm_d = DECODE; 
         DECODE:  sm_d = EXECUTE; 
         default: sm_d = FETCH;
      endcase
   end

   assign sm_f     = (sm_q == FETCH);
   assign sm_r     = (sm_q == EXECUTE) &  (opcode == 5'b01100);          
   assign sm_i     = (sm_q == EXECUTE) &  (opcode == 5'b00100);
   assign sm_s     = (sm_q == EXECUTE) &  (opcode == 5'b01000);                    
   assign sm_b     = (sm_q == EXECUTE) &  (opcode == 5'b11000);                     
   assign sm_lui   = (sm_q == EXECUTE) &  (opcode == 5'b01101);
   assign sm_auipc = (sm_q == EXECUTE) &  (opcode == 5'b00101);
   assign sm_u     = sm_lui | sm_auipc;
   assign sm_j     = (sm_q == EXECUTE) &  (opcode == 5'b11011);
   assign sm_l     = (sm_q == EXECUTE) &  (opcode == 5'b00000);
   assign sm_k     = (sm_q == EXECUTE) &  (opcode == 5'b11001);
   
   assign sm_en = ~(sm_f | sm_l | sm_s) | i_accept;

   always_ff@(posedge i_clk or negedge i_nrst) begin
      if(!i_nrst)    sm_q <= 'd0;
      else if(sm_en) sm_q <= sm_d;
   end
    
   ///////////////////////////////////////////////////////////////////
   // Shorthand

   assign opcode = is_q.unknown.opcode;
   assign funct3 = is_q.unknown.funct3;
   assign rs1    = is_q.unknown.rs1;
   assign rs2    = is_q.unknown.rs2;
   assign rd     = is_q.unknown.rd;

   ///////////////////////////////////////////////////////////////////
   // Reg File

   // Signed extension 
   always_comb begin
      ld_data = i_data;
      case(funct3)
         3'b000:  ld_data[31:8]  = {24{i_data[7]}};
         3'b001:  ld_data[31:16] = {16{i_data[15]}}; 
         default:;
      endcase
   end

   always_comb begin
      rf_data = alu_c;
      case(1'b1)
         sm_l:      rf_data = ld_data; 
         sm_k,
         sm_j:      rf_data = pc_q; 
         sm_lui:    rf_data = {is_q.u.imm_31_12,12'd0}; 
         default:;
      endcase
   end

   always_comb begin
      for(int i=0;i<32;i++) begin
         rf_d[i] = rf_q[i]; 
      end
      rf_d[rd] = rf_data;  
      rf_d[0] = 'd0;
   end
   
   assign rf_en = sm_i | (sm_l & sm_en) | sm_r | sm_u | sm_j | sm_k;

   generate
      for(genvar i=0;i<32;i++) begin
         always_ff@(posedge i_clk or negedge i_nrst) begin
            if(!i_nrst)    rf_q[i] <= 'd0;
            else if(rf_en) rf_q[i] <= rf_d[i];
         end
      end
   endgenerate
 
   assign rf_rs1 = (rs1 == 'd0) ? 'd0 :  rf_q[rs1];
   assign rf_rs2 = (rs2 == 'd0) ? 'd0 :  rf_q[rs2];

   ///////////////////////////////////////////////////////////////////
   // ALU
   
   assign s_alu_a = (sm_u) ? pc_q : rf_rs1;
   assign s_alu_b = alu_b;

   always_comb begin
      alu_b = rf_rs2; 
      case(1'b1)
         sm_u: alu_b = {is_q.u.imm_31_12,12'd0}; 
         sm_s: alu_b = {{20{is_q.s.imm_11_5[6]}},
                                 is_q.s.imm_11_5, 
                                 is_q.s.imm_4_0};
         sm_l,
         sm_i: alu_b = {{20{is_q.i.imm_11_0[11]}},
                                 is_q.i.imm_11_0}; 
         default:;
      endcase
   end

   assign alu_add =  sm_s | sm_l | sm_u |
                    (sm_i & (funct3 == 3'b000)) | 
                    (sm_r & (funct3 == 3'b000) & (is_q.r.funct7 == 'd0));
   assign alu_sub =  sm_r & (funct3 == 3'b000) & (is_q.r.funct7 == 7'b0100000);
   assign alu_slt = (sm_b & (funct3[2:1] == 2'b10));
   assign alu_lt  = (sm_b & (funct3[2:1] == 2'b11))| 
                    ((sm_i | sm_r) & (funct3[2:1] == 2'b01));
   assign alu_xor = (sm_i | sm_r) & (funct3 == 3'b100);
   assign alu_or  = (sm_i | sm_r) & (funct3 == 3'b110);
   assign alu_eq  = sm_b & (funct3[2:1] == 2'b00);
   assign alu_sl  = (funct3 == 3'b001);
   assign alu_sr  = (funct3 == 3'b101) & (is_q.r.funct7 == 'b0000000); 
   assign alu_sar = (funct3 == 3'b101) & (is_q.r.funct7 == 'b0100000);


   assign alu_shift = (sm_i) ? rs2 : rf_rs2[4:0];

   always_comb begin
      alu_c = rf_rs1 & alu_b;
      case(1'b1)
         alu_add: alu_c = s_alu_a + s_alu_b;
         alu_sub: alu_c = rf_rs1 - alu_b;
         alu_lt:  alu_c = (rf_rs1 < alu_b) ? 'd1 : 'd0;  
         alu_slt: alu_c = (s_alu_a < s_alu_b) ? 'd1 : 'd0; 
         alu_eq:  alu_c = (rf_rs1 == alu_b) ? 'd1 : 'd0; 
         alu_sl:  alu_c = rf_rs1 << alu_shift;
         alu_sr:  alu_c = rf_rs1 >> alu_shift; 
         alu_sar: alu_c = s_alu_a >>> alu_shift; 
         alu_xor: alu_c = rf_rs1 ^ alu_b;
         alu_or:  alu_c = rf_rs1 | alu_b;
         default:; 
      endcase
   end

   ///////////////////////////////////////////////////////////////////
   // Program Counter
 
   assign pc_b[31:13]            = {19{is_q.b.imm_12_10_5[6]}};
   assign {pc_b[12],pc_b[10:5]}  = is_q.b.imm_12_10_5;
   assign {pc_b[4:1],pc_b[11]}   = is_q.b.imm_4_1_11;
   assign pc_b[0]                = 'd0;
   assign pc_j      = {{11{is_q.j.imm_20}},
                       is_q.j.imm_20,
                       is_q.j.imm_19_12,
                       is_q.j.imm_11,
                       is_q.j.imm_10_1,
                       1'b0};
   assign pc_k      = {{20{is_q.i.imm_11_0[11]}},
                           is_q.i.imm_11_0};      
   assign pc_base   = (sm_k) ? rf_rs1 : pc_q;
   assign pc_imm    = (sm_k) ? pc_k :
                      (sm_b) ? pc_b : 
                               pc_j;
   assign pc_jump   = pc_base + pc_imm - 'd4;  
   assign pc_next   = pc_q + 'd4;  
   assign pc_branch = sm_b & (alu_c[0] ^ funct3[0]); 
   assign pc_d      = (sm_k            ) ? (pc_base + pc_imm):
                      (sm_j | pc_branch) ?  pc_jump : 
                                            pc_next;
   assign pc_en     = (sm_f & sm_en)|
                      (sm_b & pc_branch) | sm_j | sm_k;

   always_ff@(posedge i_clk or negedge i_nrst) begin
      if(!i_nrst)    pc_q <= 'd0;
      else if(pc_en) pc_q <= pc_d;
   end
 
   ///////////////////////////////////////////////////////////////////
   // Store Instruction
   
   assign is_en     = sm_f & i_accept;
   assign is_d.data = i_data;

   always_ff@(posedge i_clk or negedge i_nrst) begin
      if(!i_nrst)    is_q <= 'd0;
      else if(is_en) is_q <= is_d;
   end
    
   ///////////////////////////////////////////////////////////////////
   // Drive Memory Interface

   assign o_rnw   = sm_f | sm_l;
   assign o_valid = sm_f | sm_l | sm_s;
   assign o_addr  = (sm_f) ? pc_q : alu_c;  

   always_comb begin
      o_data = rf_rs2;
      if(sm_s)
         case(funct3[1:0])
            2'b00: o_data &= 32'h000000FF;   // SB
            2'b01: o_data &= 32'h0000FFFF;   // SH
            default:;
         endcase
   end


endmodule
