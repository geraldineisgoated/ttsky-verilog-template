// `default_nettype none
// `timescale 1ns / 1ps

// /* This testbench just instantiates the module and makes some convenient wires
//    that can be driven / tested by the cocotb test.py.
// */
// module tb ();

//   // Dump the signals to a FST file. You can view it with gtkwave or surfer.
//   initial begin
//     $dumpfile("tb.fst");
//     $dumpvars(0, tb);
//     #1;
//   end

//   // Wire up the inputs and outputs:
//   reg clk;
//   reg rst_n;
//   reg ena;
//   reg [7:0] ui_in;
//   reg [7:0] uio_in;
//   wire [7:0] uo_out;
//   wire [7:0] uio_out;
//   wire [7:0] uio_oe;
// `ifdef GL_TEST
//   wire VPWR = 1'b1;
//   wire VGND = 1'b0;
// `endif

//   // Replace tt_um_example with your module name:
//   tt_um_example user_project (

//       // Include power ports for the Gate Level test:
// `ifdef GL_TEST
//       .VPWR(VPWR),
//       .VGND(VGND),
// `endif

//       .ui_in  (ui_in),    // Dedicated inputs
//       .uo_out (uo_out),   // Dedicated outputs
//       .uio_in (uio_in),   // IOs: Input path
//       .uio_out(uio_out),  // IOs: Output path
//       .uio_oe (uio_oe),   // IOs: Enable path (active high: 0=input, 1=output)
//       .ena    (ena),      // enable - goes high when design is selected
//       .clk    (clk),      // clock
//       .rst_n  (rst_n)     // not reset
//   );

// endmodule
`timescale 1ns/1ps

`define START_TESTBENCH error_o = 0; pass_o = 0; #10;
`define FINISH_WITH_FAIL error_o = 1; pass_o = 0; #10; $finish();
`define FINISH_WITH_PASS pass_o = 1; error_o = 0; #10; $finish();

module tb
(
    output logic error_o = 1'bx,
    output logic pass_o  = 1'bx
);

    logic [7:0] ui_in;
    logic [7:0] uio_in;
    logic       ena;
    logic       clk;
    logic       rst_n;

    wire [7:0] uo_out;
    wire [7:0] uio_out;
    wire [7:0] uio_oe;

    // Instantiate DUT
    tt_um_geraldineisawesome_counter dut (
        .ui_in(ui_in),
        .uo_out(uo_out),
        .uio_in(uio_in),
        .uio_out(uio_out),
        .uio_oe(uio_oe),
        .ena(ena),
        .clk(clk),
        .rst_n(rst_n)
    );

    // Clock generation
    initial begin
        clk = 0;

        forever begin
            #5;
            clk = ~clk;
        end
    end

    initial begin

        `START_TESTBENCH

        ena = 1;
        ui_in = 0;
        uio_in = 0;
        rst_n = 1;

        $display("Starting counter test");

        //---------------- RESET TEST ----------------//

        $display("Testing reset");

        rst_n = 0;

        @(posedge clk);
        @(posedge clk);

        if (uo_out[3:0] != 0) begin
            $display("Reset failed. Expected 0 but got %d", uo_out[3:0]);
            `FINISH_WITH_FAIL
        end

        rst_n = 1;

        @(posedge clk);
        @(posedge clk);

        if (uo_out[3:0] != 0) begin
            $display("Reset release failed. Expected 0 but got %d", uo_out[3:0]);
            `FINISH_WITH_FAIL
        end


        //---------------- COUNT UP ----------------//

        $display("Counting up");

        ui_in[0] = 1;
        ui_in[1] = 0;

        @(posedge clk);

        if (uo_out[3:0] != 1) begin
            $display("Count up step 1 failed. Expected 1 but got %d", uo_out[3:0]);
            `FINISH_WITH_FAIL
        end

        @(posedge clk);

        if (uo_out[3:0] != 2) begin
            $display("Count up step 2 failed. Expected 2 but got %d", uo_out[3:0]);
            `FINISH_WITH_FAIL
        end

        @(posedge clk);

        if (uo_out[3:0] != 3) begin
            $display("Count up step 3 failed. Expected 3 but got %d", uo_out[3:0]);
            `FINISH_WITH_FAIL
        end


        //---------------- HOLD CONDITION ----------------//

        $display("Testing hold condition");

        ui_in[0] = 1;
        ui_in[1] = 1;

        @(posedge clk);

        if (uo_out[3:0] != 3) begin
            $display("Hold test failed. Expected 3 but got %d", uo_out[3:0]);
            `FINISH_WITH_FAIL
        end

        @(posedge clk);

        if (uo_out[3:0] != 3) begin
            $display("Hold test failed. Expected 3 but got %d", uo_out[3:0]);
            `FINISH_WITH_FAIL
        end


        //---------------- COUNT DOWN ----------------//

        $display("Counting down");

        ui_in[0] = 0;
        ui_in[1] = 1;

        @(posedge clk);

        if (uo_out[3:0] != 2) begin
            $display("Count down step 1 failed. Expected 2 but got %d", uo_out[3:0]);
            `FINISH_WITH_FAIL
        end

        @(posedge clk);

        if (uo_out[3:0] != 1) begin
            $display("Count down step 2 failed. Expected 1 but got %d", uo_out[3:0]);
            `FINISH_WITH_FAIL
        end


        //---------------- OVERFLOW TEST ----------------//

        $display("Testing overflow");

        rst_n = 0;
        ui_in = 0;

        @(posedge clk);
        @(posedge clk);

        rst_n = 1;

        @(posedge clk);

        if (uo_out[3:0] != 0) begin
            $display("Overflow setup failed. Expected 0 but got %d", uo_out[3:0]);
            `FINISH_WITH_FAIL
        end

        ui_in[0] = 1;
        ui_in[1] = 0;

        repeat (15) begin
            @(posedge clk);
        end

        if (uo_out[3:0] != 15) begin
            $display("Overflow precondition failed. Expected 15 but got %d", uo_out[3:0]);
            `FINISH_WITH_FAIL
        end

        @(posedge clk);

        if (uo_out[3:0] != 0) begin
            $display("Overflow failed. Expected 0 but got %d", uo_out[3:0]);
            `FINISH_WITH_FAIL
        end


        //---------------- UNDERFLOW TEST ----------------//

        $display("Testing underflow");

        ui_in[0] = 0;
        ui_in[1] = 1;

        @(posedge clk);

        if (uo_out[3:0] != 15) begin
            $display("Underflow failed. Expected 15 but got %d", uo_out[3:0]);
            `FINISH_WITH_FAIL
        end


        $display("All tests passed");

        `FINISH_WITH_PASS

    end

endmodule
