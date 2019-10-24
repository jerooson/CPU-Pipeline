/* TODO: name and PennKeys of all group members here
 *
 * lc4_regfile.v
 * Implements an 8-register register file parameterized on word size.
 *
 */

`timescale 1ns / 1ps

// Prevent implicit wire declaration
`default_nettype none

module lc4_regfile #(parameter n = 16)
   (input  wire         clk,
    input  wire         gwe,
    input  wire         rst,
    input  wire [  2:0] i_rs,      // rs selector
    output wire [n-1:0] o_rs_data, // rs contents
    input  wire [  2:0] i_rt,      // rt selector
    output wire [n-1:0] o_rt_data, // rt contents
    input  wire [  2:0] i_rd,      // rd selector
    input  wire [n-1:0] i_wdata,   // data to write
    input  wire         i_rd_we    // write enable
    );

   /***********************
    * TODO YOUR CODE HERE *
    ***********************/
    wire [15:0] o_reg [7:0];
    wire [7:0] one_hot;
    
    assign one_hot [0] =  (~i_rd[2] & ~i_rd[1] & ~i_rd[0]) & i_rd_we; //000
    assign one_hot [1] =  (~i_rd[2] & ~i_rd[1] & i_rd[0]) & i_rd_we; //001
    assign one_hot [2] =  (~i_rd[2] & i_rd[1] & ~i_rd[0]) & i_rd_we; //010
    assign one_hot [3] =  (~i_rd[2] & i_rd[1] & i_rd[0]) & i_rd_we; //011
    assign one_hot [4] =  (i_rd[2] & ~i_rd[1] & ~i_rd[0]) & i_rd_we; //100
    assign one_hot [5] =  (i_rd[2] & ~i_rd[1] & i_rd[0]) & i_rd_we; //101
    assign one_hot [6] =  (i_rd[2] & i_rd[1] & ~i_rd[0]) & i_rd_we; //110
    assign one_hot [7] =  (i_rd[2] & i_rd[1] & i_rd[0]) & i_rd_we; //111
    
    genvar i;
    for (i = 0; i < 8; i = i + 1 ) begin
        Nbit_reg #(16,0) reg_0 (.in(i_wdata), .out(o_reg[i]), .clk(clk), .we(one_hot[i]), .gwe(gwe), .rst(rst));
    end
    
    assign o_rs_data = (i_rs == 3'd7) ? o_reg[7] :
                       (i_rs == 3'd6) ? o_reg[6] :
                       (i_rs == 3'd5) ? o_reg[5] :
                       (i_rs == 3'd4) ? o_reg[4] :
                       (i_rs == 3'd3) ? o_reg[3] :
                       (i_rs == 3'd2) ? o_reg[2] :
                       (i_rs == 3'd1) ? o_reg[1] :
                       (i_rs == 3'd0) ? o_reg[0] : 16'd0;
                       
    assign o_rt_data = (i_rt == 3'd7) ? o_reg[7] :
                       (i_rt == 3'd6) ? o_reg[6] :
                       (i_rt == 3'd5) ? o_reg[5] :
                       (i_rt == 3'd4) ? o_reg[4] :
                       (i_rt == 3'd3) ? o_reg[3] :
                       (i_rt == 3'd2) ? o_reg[2] :
                       (i_rt == 3'd1) ? o_reg[1] :
                       (i_rt == 3'd0) ? o_reg[0] : 16'd0;


endmodule
