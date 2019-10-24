/* TODO: INSERT NAME AND PENNKEY HERE */

/**
 * @param a first 1-bit input
 * @param b second 1-bit input
 * @param g whether a and b generate a carry
 * @param p whether a and b would propagate an incoming carry
 */
module gp1(input wire a, b,
           output wire g, p);
   assign g = a & b;
   assign p = a | b;
endmodule

/**
 * Computes aggregate generate/propagate signals over a 4-bit window.
 * @param gin incoming generate signals 
 * @param pin incoming propagate signals
 * @param cin the incoming carry
 * @param gout whether these 4 bits collectively generate a carry (ignoring cin)
 * @param pout whether these 4 bits collectively would propagate an incoming carry (ignoring cin)
 * @param cout the carry outs for the low-order 3 bits
 */
module gp4(input wire [3:0] gin, pin,
           input wire cin,
           output wire gout, pout,
           output wire [2:0] cout);
           
           wire p_1_0, g_1_0, p_3_2, g_3_2;
           
           assign p_1_0 = pin[0] & pin[1];
           assign g_1_0 = gin[1] | (pin[1] & gin[0]);
           assign cout[0] = (pin[0] & cin) | gin[0];
           assign p_3_2 = pin[2] & pin[3];
           
           assign pout = p_3_2 & p_1_0;
           
           assign g_3_2 = (pin[3] & gin[2]) | gin[3];
           
           assign gout = (g_1_0 & p_3_2) | g_3_2;
           assign cout[1] = (cin & p_1_0) | g_1_0;
           assign cout[2] = (pin[2] & cout[1]) | gin[2];
           
endmodule

/**
 * 16-bit Carry-Lookahead Adder
 * @param a first input
 * @param b second input
 * @param cin carry in
 * @param sum sum of a + b + carry-in
 */
module cla16
  (input wire [15:0]  a, b,
   input wire         cin,
   output wire [15:0] sum);
   wire [15:0] gin, pin;
   wire [15:0] cout;
   wire [4:0] gout, pout;
   
   genvar i;
   for (i=0; i<16; i=i+1) begin
   gp1 cla_in_0 (.a(a[i]), .b(b[i]), .g(gin[i]), .p(pin[i]));
   end
   
   assign cout[0] = cin;
   gp4 cla_out_0 (.gin(gin[3:0]), .pin(pin[3:0]), .cin(cin), .gout(gout[0]), .pout(pout[0]), .cout(cout[3:1]));
   gp4 cla_out_1 (.gin(gin[7:4]), .pin(pin[7:4]), .cin(cout[4]), .gout(gout[1]), .pout(pout[1]), .cout(cout[7:5]));
   gp4 cla_out_2 (.gin(gin[11:8]), .pin(pin[11:8]), .cin(cout[8]), .gout(gout[2]), .pout(pout[2]), .cout(cout[11:9]));
   gp4 cla_out_3 (.gin(gin[15:12]), .pin(pin[15:12]), .cin(cout[12]), .gout(gout[3]), .pout(pout[3]), .cout(cout[15:13]));
   gp4 cla_out_4 (.gin(gout[3:0]), .pin(pout[3:0]), .cin(cin), .gout(gout[4]), .pout(pout[4]), .cout({cout[12],cout[8],cout[4]}));
   
   for (i=0; i<16; i=i+1) begin
   assign sum[i] = a[i]^b[i]^cout[i];
   end
   
endmodule












