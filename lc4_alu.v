/* Weibo Teng, Haotian Wang */

`timescale 1ns / 1ps

`default_nettype none

module lc4_alu(input  wire [15:0] i_insn,
               input wire [15:0]  i_pc,
               input wire [15:0]  i_r1data,
               input wire [15:0]  i_r2data,
               output wire [15:0] o_result);

               wire [15:0] sum;
               wire [15:0] o_quotient, o_remainder;
               
               parameter ZERO = 1'b0;
               parameter NULL = 16'b0000_0000_0000_0000;
               parameter ONE = 16'b0000_0000_0000_0001;
               
               wire [10:0] IMM11 = i_insn [10:0];
               wire [8:0] IMM9 = i_insn [8:0];
               wire [7:0] IMM8 = i_insn [7:0];
               wire [6:0] IMM7 = i_insn [6:0];
               wire [5:0] IMM6 = i_insn [5:0];
               wire [4:0] IMM5 = i_insn [4:0];
               wire [3:0] IMM4 = i_insn [3:0];
               wire [15:0] SX_IMM11 = {{5{IMM11[10]}}, IMM11}; 
               wire [15:0] SX_IMM9 = {{7{IMM9[8]}}, IMM9};
               wire [15:0] SX_IMM7 = {{9{IMM9[6]}}, IMM7};
               wire [15:0] SX_IMM6 = {{10{IMM6[5]}}, IMM6};
               wire [15:0] SX_IMM5 = {{11{IMM5[4]}}, IMM5};
               
               wire [15:0] US_IMM8 = {ZERO,ZERO,ZERO,ZERO,ZERO,ZERO,ZERO,ZERO,IMM8};
               wire [15:0] US_IMM4 = {ZERO,ZERO,ZERO,ZERO,ZERO,ZERO,ZERO,ZERO,ZERO,ZERO,ZERO,ZERO,IMM4};
               wire [15:0] US_IMM7 = {ZERO,ZERO,ZERO,ZERO,ZERO,ZERO,ZERO,ZERO,ZERO,IMM7};
               
               
               wire [15:0] a = (i_insn [15:12] == 4'b0000) ? i_pc :
                               (i_insn [15:12] == 4'b0001) ? i_r1data :
                               (i_insn [15:12] == 4'b0110) ? i_r1data :
                               (i_insn [15:12] == 4'b0111) ? i_r1data :
                               (i_insn [15:12] == 4'b1100) ? ((i_insn [11] == 1'b0) ? i_r1data : i_pc) :
                               /*else*/ NULL;
                               
               wire [15:0] b =(i_insn [15:12] == 4'b0000) ? SX_IMM9 : 
                              (i_insn [15:12] == 4'b0001) ? ((i_insn [5:3] == 3'b000) ? i_r2data : 
                                                             (i_insn [5:3] == 3'b010) ? ~i_r2data : 
                                                             (i_insn [5] == 1'b1) ? SX_IMM5 : 
                                                             NULL) :
                              (i_insn [15:12] == 4'b0110) ? SX_IMM6 :
                              (i_insn [15:12] == 4'b0111) ? SX_IMM6 :
                              (i_insn [15:12] == 4'b1100) ? ((i_insn [11] == 1'b0) ? NULL : SX_IMM11) : NULL; 
    
            
               wire [15:0] cin = (i_insn [15:12] == 4'b0000) ? ONE :
                                 (i_insn [15:12] == 4'b0001) ? ((i_insn [5:3] == 3'b010) ? ONE : NULL) :
                                 (i_insn [15:12] == 4'b1100) ? ((i_insn [11] == 1'b1) ? ONE : NULL) :
                                 NULL;
               
               cla16 cla_0 (.a(a), .b(b), .cin(cin), .sum(sum));
               lc4_divider div_0 (.i_dividend(i_r1data), .i_divisor(i_r2data), .o_remainder(o_remainder), .o_quotient(o_quotient));
             
               
               wire [15:0] add_section = (i_insn [15:12] == 4'b0001) ? ((i_insn [5:3] == 3'b000) ? sum :
                                                                        (i_insn [5:3] == 3'b010) ? sum :
                                                                        (i_insn [5:3] == 3'b001) ? i_r1data * i_r2data :
                                                                        (i_insn [5:3] == 3'b011) ? o_quotient :
                                                                        (i_insn [5] == 1'b1) ? sum : NULL) :
                                                                        NULL;
               
               
               wire [15:0] jsr_section = (i_insn [15:12] == 4'b0100) ? ((i_insn [11] == 1'b0) ? i_r1data : 
                                                                                                ((i_pc & 16'h0x8000) | (IMM11 << 4))):
                                                                        NULL;
            
               
               wire [15:0] gate_section = ((i_insn [15:12] == 4'b0101) & (i_insn [5:3] == 3'b000))? i_r1data & i_r2data : (((i_insn [15:12] == 4'b0101) & (i_insn [5:3] == 3'b001))? ~i_r1data : (((i_insn [15:12] == 4'b0101) & (i_insn [5:3] == 3'b010))? (i_r1data | i_r2data) : (((i_insn [15:12] == 4'b0101) & (i_insn [5:3] == 3'b011))? (i_r1data ^ i_r2data) : (((i_insn [15:12] == 4'b0101) & (i_insn [5] == 1'b1))? (i_r1data & SX_IMM5) : NULL))));
               

            

            /*wire is_PP = (i_r1data [15] == 0 && i_r2data [15] == 0);
            wire is_PN = (i_r1data [15] < i_r2data [15]);
            wire is_NP = (i_r2data [15] < i_r1data [15]);
            wire is_NN = (i_r1data [15] == 1 && i_r2data [15] == 1);
            wire is_EQ = (i_r1data == i_r2data);

            wire [15:0] NZP = is_EQ ? 16'd0 : 
                         is_PP ? ( (i_r1data [14:0] > i_r2data [14:0]) ? 16'd1 : 16'b1111111111111111) :
                         is_PN ? 16'd1 :
                         is_NP ? 16'b1111111111111111 :
                         is_NN ? ( (i_r1data [14:0] > i_r2data [14:0]) ? 16'd1 : 16'b1111111111111111) :
                         NULL ;*/
            
            wire [15:0] NZP = ($signed (i_r1data) > $signed (i_r2data)) ? 16'd1 :
                              ($signed (i_r2data) > $signed (i_r1data)) ? 16'b1111111111111111 :
                           /*else*/ 16'd0 ;

            wire [15:0] uNZP = (i_r1data > i_r2data) ? 16'd1 :
                               (i_r2data > i_r1data) ? 16'b1111111111111111 :
                          /*else*/ 16'd0 ;

            /*wire is_PP7 = (i_r1data [15] == 0 && IMM7 [6] == 0);
            wire is_PN7 = (i_r1data [15] < IMM7 [6]);
            wire is_NP7 = (IMM7 [6] < i_r1data [15]);
            wire is_NN7 = (i_r1data [15] == 1 && IMM7 [6] == 1);
            wire is_EQ7 = (i_r1data [6:0] == IMM7 [6:0]) && ((i_r1data [15:7] == 9'd0) || (i_r1data [15:7] == 9'b111111111));

            wire [15:0] NZP7 = is_EQ7? 16'd0 :
                          is_PP7 ? ( (i_r1data [14:0] > IMM7 [5:0]) ? 16'd1 : 16'b1111111111111111) :
                          is_PN7 ? 16'd1 :
                          is_NP7 ? 16'b1111111111111111 :
                          is_NN7 ? ( (i_r1data [14:0] < IMM7 [5:0]) ? 16'd1 : 16'b1111111111111111) :
                          NULL ;*/
            
            wire [15:0] NZP7 = ($signed (i_r1data) > $signed (SX_IMM7)) ? 16'd1 :
                               ($signed (SX_IMM7) > $signed (i_r1data)) ? 16'b1111111111111111 :
                           /*else*/ 16'd0 ;

            wire [15:0] uNZP7 = (i_r1data > US_IMM7) ? 16'd1 :
                                (US_IMM7 > i_r1data) ? 16'b1111111111111111 :
                           /*else*/ 16'd0 ;


            wire [15:0] NZPsum = (i_insn [8:7] == 2'd0) ? NZP :
                                 (i_insn [8:7] == 2'd1) ? uNZP :
                                 (i_insn [8:7] == 2'd2) ? NZP7 :
                                 (i_insn [8:7] == 2'd3) ? uNZP7 :
                            /*else*/ NULL;
               

               

               wire [15:0] rti_section = (i_insn [15:12] == 4'b1000)? i_r1data : NULL;
               
               wire [15:0] cons_section = (i_insn [15:12] == 4'b1001)? SX_IMM9 : NULL;
               
               wire [15:0] shift_section = (i_insn [15:12] == 4'b1010) ? (i_insn [5:4] == 2'b00 ? i_r1data << US_IMM4 :
                                                                          i_insn [5:4] == 2'b01 ? $signed ($signed(i_r1data) >>> US_IMM4) :
                                                                          i_insn [5:4] == 2'b10 ? i_r1data >> US_IMM4 :
                                                                          i_insn [5:4] == 2'b11 ? o_remainder : NULL) : 
                                                                        NULL;
               

               
               wire [15:0] hiconst_section = (i_insn [15:12] == 4'b1101)? ((i_r1data & 8'h0xFF) | (US_IMM8 << 8)) : NULL; 
               
               wire [15:0] trap_section = (i_insn [15:12] == 4'b1111)? (17'h0x8000 | US_IMM8) : NULL;
               
               assign o_result = ((i_insn [15:12] == 4'b0000) | (i_insn [15:12] == 4'b0110) | (i_insn [15:12] == 4'b0111) | (i_insn [15:12] == 4'b1100))? sum :
                                 (i_insn [15:12] == 4'b0001) ? add_section :
                                 (i_insn [15:12] == 4'b0010) ? NZPsum :
                                 (i_insn [15:12] == 4'b0100) ? jsr_section :
                                 (i_insn [15:12] == 4'b0101) ? gate_section :
                                 (i_insn [15:12] == 4'b1001)? cons_section :
                                 (i_insn [15:12] == 4'b1010)? shift_section :
                                 (i_insn [15:12] == 4'b1101)? hiconst_section :
                                 (i_insn [15:12] == 4'b1111)? trap_section :
                                 (i_insn [15:12] == 4'b1000)? rti_section :
                                 NULL;
               

           


endmodule



