/* Group 16: 
   Weibo Teng   SID:41308916, 
   Haotian Wang SID:54413071 */

`timescale 1ns / 1ps
`default_nettype none

module lc4_divider(input  wire [15:0] i_dividend,
                   input  wire [15:0] i_divisor,
                   output wire [15:0] o_remainder,
                   output wire [15:0] o_quotient);
		   
  	wire [15:0] dividend_seg [16:0];
  	wire [15:0] remainder_seg [16:0];
  	wire [15:0] quotient_seg [16:0];
 	 
  	assign quotient_seg [0] = 16'b0;
  	assign remainder_seg [0] = 16'b0;
  	assign dividend_seg [0] = i_dividend;
 	 
 	 
  	genvar i;
  	for (i = 1; i < 17; i = i + 1) begin
    	lc4_divider_one_iter f (.i_dividend (dividend_seg [i-1]), .i_divisor (i_divisor[15:0]), .i_remainder (remainder_seg [i-1]), .i_quotient (quotient_seg [i-1]),
                            	.o_dividend (dividend_seg [i]), .o_remainder (remainder_seg [i]), .o_quotient (quotient_seg [i]));
        end 
	
	assign o_remainder = remainder_seg[16];
	assign o_quotient = quotient_seg[16];
		  
                   
                   
endmodule // lc4_divider

module lc4_divider_one_iter(input  wire [15:0] i_dividend,
                            input  wire [15:0] i_divisor,
                            input  wire [15:0] i_remainder,
                            input  wire [15:0] i_quotient,
                            output wire [15:0] o_dividend,
                            output wire [15:0] o_remainder,
                            output wire [15:0] o_quotient);
                            		   
                                 
    wire [15:0] i_remainder_tmp = (i_remainder << 1) | ((i_dividend >> 15) & 1'b1);
    wire [15:0] i_remainder_tmp_v2 = (i_remainder_tmp < i_divisor) ? i_remainder_tmp : (i_remainder_tmp - i_divisor);
    wire [15:0] i_remainder_tmp_v3 = (i_remainder_tmp < i_divisor) ? (i_quotient << 1) : ((i_quotient << 1) | 1'b1);
    assign o_remainder = (i_divisor == 0) ? 16'b0 : i_remainder_tmp_v2;
    assign o_quotient = (i_divisor == 0) ? 16'b0 : i_remainder_tmp_v3;    
    assign o_dividend = i_dividend << 1;
    
endmodule
