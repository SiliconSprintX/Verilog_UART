`timescale 1ns/1ps

module uart_tb;

    reg clk;
    reg rst;

    reg       tx_start;
    reg [7:0] tx_data;

    wire tx;
    wire tx_busy;

    wire rx;

    wire [7:0] rx_data;
    wire       rx_done;


    // TX connected directly to RX
    assign rx = tx;


    // UART
    uart #(
        .CLKS_PER_BIT(10)
    ) uut (

        .clk(clk),
        .rst(rst),

        .tx_start(tx_start),
        .tx_data(tx_data),

        .tx(tx),
        .tx_busy(tx_busy),

        .rx(rx),
        .rx_data(rx_data),
        .rx_done(rx_done)
    );


    // =========================================
    // CLOCK
    // =========================================

    initial begin
        clk = 0;

        forever #5 clk = ~clk;
    end


    // =========================================
    // WAVEFORM
    // =========================================

    initial begin

        $dumpfile("uart.vcd");

        // Dump everything inside testbench
        $dumpvars(0, uart_tb);

    end


    // =========================================
    // TEST
    // =========================================

    initial begin

        rst      = 1;
        tx_start = 0;
        tx_data  = 0;


        // Reset
        #20;

        rst = 0;

        #20;


        // -------------------------------------
        // Send A
        // -------------------------------------

        @(posedge clk);

        tx_data  = 8'h41;
        tx_start = 1;

        $display("--------------------------------");
        $display("TRANSMITTING : %h", tx_data);

        @(posedge clk);

        tx_start = 0;


        // Wait for reception
        @(posedge rx_done);

        $display("RECEIVED     : %h", rx_data);

        if (rx_data == 8'h41)
            $display("RESULT       : PASS");
        else
            $display("RESULT       : FAIL");


        #100;


        // -------------------------------------
        // Send 55
        // -------------------------------------

        @(posedge clk);

        tx_data  = 8'h55;
        tx_start = 1;

        $display("--------------------------------");
        $display("TRANSMITTING : %h", tx_data);

        @(posedge clk);

        tx_start = 0;


        @(posedge rx_done);

        $display("RECEIVED     : %h", rx_data);

        if (rx_data == 8'h55)
            $display("RESULT       : PASS");
        else
            $display("RESULT       : FAIL");


        #100;


        // -------------------------------------
        // Send AA
        // -------------------------------------

        @(posedge clk);

        tx_data  = 8'hAA;
        tx_start = 1;

        $display("--------------------------------");
        $display("TRANSMITTING : %h", tx_data);

        @(posedge clk);

        tx_start = 0;


        @(posedge rx_done);

        $display("RECEIVED     : %h", rx_data);

        if (rx_data == 8'hAA)
            $display("RESULT       : PASS");
        else
            $display("RESULT       : FAIL");


        #100;

        $display("--------------------------------");
        $display("UART TEST COMPLETED");
        $display("--------------------------------");

        $finish;

    end

endmodule
