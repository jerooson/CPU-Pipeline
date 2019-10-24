/* TODO: name and PennKeys of all group members here */

`timescale 1ns / 1ps

// disable implicit wire declaration
`default_nettype none

module lc4_processor
   (input  wire        clk,                // main clock
    input wire         rst, // global reset
    input wire         gwe, // global we for single-step clock
                                    
    output wire [15:0] o_cur_pc, // Address to read from instruction memory
    input wire [15:0]  i_cur_insn, // Output of instruction memory
    output wire [15:0] o_dmem_addr, // Address to read/write from/to data memory
    input wire [15:0]  i_cur_dmem_data, // Output of data memory
    output wire        o_dmem_we, // Data memory write enable
    output wire [15:0] o_dmem_towrite, // Value to write to data memory
   
    output wire [1:0]  test_stall, // Testbench: is this is stall cycle? (don't compare the test values)
    output wire [15:0] test_cur_pc, // Testbench: program counter
    output wire [15:0] test_cur_insn, // Testbench: instruction bits
    output wire        test_regfile_we, // Testbench: register file write enable
    output wire [2:0]  test_regfile_wsel, // Testbench: which register to write in the register file 
    output wire [15:0] test_regfile_data, // Testbench: value to write into the register file
    output wire        test_nzp_we, // Testbench: NZP condition codes write enable
    output wire [2:0]  test_nzp_new_bits, // Testbench: value to write to NZP bits
    output wire        test_dmem_we, // Testbench: data memory write enable
    output wire [15:0] test_dmem_addr, // Testbench: address to read/write memory
    output wire [15:0] test_dmem_data, // Testbench: value read/writen from/to memory

    input wire [7:0]   switch_data, // Current settings of the Zedboard switches
    output wire [7:0]  led_data // Which Zedboard LEDs should be turned on?
    );
   
   /*** YOUR CODE HERE ***/
      // By default, assign LEDs to display switch inputs to avoid warnings about
   // disconnected ports. Feel free to use this for debugging input/output if
   // you desire.
   assign led_data = switch_data;

   
   /* DO NOT MODIFY THIS CODE */
   // Always execute one instruction each cycle (test_stall will get used in your pipelined processor)
   assign test_stall = 2'b0; 

   // pc wires attached to the PC register's ports
   wire [15:0]   pc;      // Current program counter (read out from pc_reg)
   wire [15:0]   next_pc; // Next program counter (you compute this and feed it into next_pc)

   // Program counter register, starts at 8200h at bootup
   Nbit_reg #(16, 16'h8200) pc_reg (.in(next_pc), .out(pc), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));

    wire select_pc_plus_one, nzp_we, regfile_we, r1re, r2re, is_branch, is_control_insn, is_store, is_load;
    wire [2:0] wsel;
    wire [2:0] r1sel;
    wire [2:0] r2sel;
    wire [15:0] o_rs_data, o_rt_data;
    
    //Decoder
    lc4_decoder decoder_0 (.insn(i_cur_insn), .r1sel(r1sel), .r1re(r1re), .r2sel(r2sel), .r2re(r2re), .wsel(wsel), 
                           .regfile_we(regfile_we), .nzp_we(nzp_we), .select_pc_plus_one(select_pc_plus_one), .is_load(is_load),
                           .is_store(is_store), .is_branch(is_branch), .is_control_insn(is_control_insn));
    
    cla16 cla_16 (.a(pc), .b(16'd1), .cin(16'd0), .sum(pc_plus_one));
        
    //Regifle
    wire [15:0] i_wdata;
    lc4_regfile #(16) regfile_0 (.clk(clk), .gwe(gwe), .rst(rst), .i_rs(r1sel), .o_rs_data(o_rs_data), .i_rt(r2sel), .o_rt_data(o_rt_data), .i_rd(wsel), .i_wdata(i_wdata), .i_rd_we(regfile_we)); 
    
    //NZP
    wire [2:0] o_nzp;
    /*wire [2:0] initial_nzp = ($signed (o_result_alu) < $signed (16'b0)) ? 3'b100 : 
                             ($signed (o_result_alu) > $signed (16'b0)) ? 3'b001 : 
                             (o_result_alu == 16'b0) ? 3'b010:
                             3'b010;*/
                             
    wire [2:0] initial_nzp = (i_wdata == 16'd0) ? 3'b010 : 
                             (i_wdata [15] == 1'b1) ? 3'b100 :
                             3'b001;
                              
    Nbit_reg #(3,3'b000) NZP_reg (.in(initial_nzp), .out(o_nzp), .clk(clk), .we(nzp_we), .gwe(gwe), .rst(rst));
    
    //Branch
    wire o_branch;

    assign o_branch = (o_nzp[0] & i_cur_insn[9]) | (o_nzp[1] & i_cur_insn[10]) | (o_nzp[2] & i_cur_insn[11]);
    
    wire [15:0] control_insn;
    assign control_insn = (is_control_insn) ? o_result_alu : pc_plus_one;
    assign next_pc = (o_branch == 1'b1 & is_branch == 1'b1) ? o_result_alu : control_insn;
    
    assign o_cur_pc = pc;
    
    wire [15:0] o_result_alu;
    
    lc4_alu alu_0 (.i_insn(i_cur_insn), .i_pc(pc), .i_r1data(o_rs_data), .i_r2data(o_rt_data), .o_result(o_result_alu));
    
    //Data MEM
    wire [15:0] pc_plus_one;
    
    assign o_dmem_addr = (is_load || is_store) ? o_result_alu : 16'd0;
    assign i_wdata = (select_pc_plus_one) ? pc_plus_one :
                     ((is_load) ? i_cur_dmem_data : o_result_alu);
    assign o_dmem_towrite = (is_store) ? o_rt_data : ((is_load) ? i_wdata : 16'd0);
    assign o_dmem_we = is_store;


    
    //test
    //assign test_stall = pc;o_nzp
    assign test_cur_pc = pc;//o_cur_pc;
    assign test_cur_insn = i_cur_insn;
    assign test_regfile_we = regfile_we;
    assign test_regfile_wsel = wsel;
    assign test_regfile_data = i_wdata;
    assign test_nzp_we = nzp_we;
    assign test_nzp_new_bits = initial_nzp;
    assign test_dmem_we = o_dmem_we;
    assign test_dmem_addr = o_dmem_addr;
    assign test_dmem_data = o_dmem_towrite;
   /* Add $display(...) calls in the always block below to
    * print out debug information at the end of every cycle.
    * 
    * You may also use if statements inside the always block
    * to conditionally print out information.
    *
    * You do not need to resynthesize and re-implement if this is all you change;
    * just restart the simulation.
    */
`ifndef NDEBUG
   always @(posedge gwe) begin
      // $display("%d %h %h %h %h %h", $time, f_pc, d_pc, e_pc, m_pc, test_cur_pc);
      // if (o_dmem_we)
      //   $display("%d STORE %h <= %h", $time, o_dmem_addr, o_dmem_towrite);

      // Start each $display() format string with a %d argument for time
      // it will make the output easier to read.  Use %b, %h, and %d
      // for binary, hex, and decimal output of additional variables.
      // You do not need to add a \n at the end of your format string.
      // $display("%d ...", $time);

      // Try adding a $display() call that prints out the PCs of
      // each pipeline stage in hex.  Then you can easily look up the
      // instructions in the .asm files in test_data.

      // basic if syntax:
      // if (cond) begin
      //    ...;
      //    ...;
      // end

      // Set a breakpoint on the empty $display() below
      // to step through your pipeline cycle-by-cycle.
      // You'll need to rewind the simulation to start
      // stepping from the beginning.

      // You can also simulate for XXX ns, then set the
      // breakpoint to start stepping midway through the
      // testbench.  Use the $time printouts you added above (!)
      // to figure out when your problem instruction first
      // enters the fetch stage.  Rewind your simulation,
      // run it for that many nano-seconds, then set
      // the breakpoint.

      // In the objects view, you can change the values to
      // hexadecimal by selecting all signals (Ctrl-A),
      // then right-click, and select Radix->Hexadecimal.

      // To see the values of wires within a module, select
      // the module in the hierarchy in the "Scopes" pane.
      // The Objects pane will update to display the wires
      // in that module.

      //$display(); 
   end
`endif
endmodule
