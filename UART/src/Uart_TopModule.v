module Uart_TopModule #(
    parameter clk_rate = 50000000,
    parameter baud_rate = 9600
)(
    input clk,
    input rst,
    input [7:0] data,
    input t_start,
    output wire tx_out,
    output wire [7:0] rx_data_out,
    output wire r_stop
); // input rx_data is not used as we are using a loopback from tx to rx for testing

    wire t_baud, r_baud;
    wire t_busy, r_busy;

    BaudRate_Generator #(
        .clk_rate(clk_rate),
        .baud_rate(baud_rate)
    ) g1 (
        .clk(clk),
        .rst(rst),
        .tx_rate(t_baud),
        .rx_rate(r_baud)
    );

    Uart_TX t1(
        .clk(clk),
        .rst(rst),
        .data_in(data),
        .t_start(t_start),
        .baud_tick(t_baud),
        .d_out(tx_out),
        .t_busy(t_busy)
    );

    Uart_RX r1(
        .clk(clk),
        .rst(rst),
        .r_data(tX_out),
        .baud_tick(r_baud),
        .r_out(rx_data_out),
        .r_busy(r_busy),
        .r_done(r_stop)
    );

endmodule


