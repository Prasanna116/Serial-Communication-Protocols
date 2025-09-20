module BaudRate_Generator #(
    parameter clk_rate = 50000000,     // System clock
    parameter baud_rate = 9600         // Baud rate
)(
    input clk,
    input rst,                         // Active-low reset
    output reg tx_rate,
    output reg rx_rate
);

    parameter integer tx_count = clk_rate / baud_rate;
    parameter integer rx_count = clk_rate / baud_rate;

    reg [$clog2(tx_count)-1:0] tx_counter;
    reg [$clog2(rx_count)-1:0] rx_counter;

    // Transmit clock generation
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            tx_counter <= 0;
            tx_rate <= 0;
        end
        else if (tx_counter == tx_count - 1) begin
            tx_counter <= 0;
            tx_rate <= ~tx_rate;
        end
        else begin
            tx_counter <= tx_counter + 1;
        end
    end

    // Receive clock generation
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            rx_counter <= 0;
            rx_rate <= 0;
        end
        else if (rx_counter == rx_count - 1) begin
            rx_counter <= 0;
            rx_rate <= ~rx_rate;
        end
        else begin
            rx_counter <= rx_counter + 1;
        end
    end

endmodule

