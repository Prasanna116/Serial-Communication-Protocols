`timescale 1ns/1ps

module UART_TB1;

    reg clk;
    reg rst;
    reg [7:0] data;
    reg t_start;

    wire [7:0] data_out;
    wire r_stop;

    // Instantiate the UART Top Module with lower clk rate for simulation
    Uart_TopModule #(
        .clk_rate(1000000),      // Sim-friendly 1 MHz clock
        .baud_rate(9600)
    ) uut (
        .clk(clk),
        .rst(rst),
        .data(data),
        .t_start(t_start),
        .data_out(data_out),
        .r_stop(r_stop)
    );

    // Clock generator: 1 MHz => 1us period
    initial clk = 0;
    always #500 clk = ~clk;

    initial begin
        // Initialize signals
        rst = 0;
        data = 8'h00;
        t_start = 0;

        #1000;  // wait 1us
        rst = 1;

        #1000;
        data = 8'hA5; // 10100101
        t_start = 1;
        #1800000;        // 104us ON time + 104us OFF time for one baud signal. For 8 bit data- 8 baud signals required
        t_start = 0;

        // Wait for reception to complete
        wait (r_stop == 1);
        #1000;

        if (data_out == 8'hA5)
            $display("? Test Passed: Received = %h", data_out);
        else
            $display("? Test Failed: Received = %h", data_out);

        #5000;
        $stop;
    end

endmodule

