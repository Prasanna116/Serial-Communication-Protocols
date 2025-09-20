module SPI_TopModule #(
    parameter SPI_mode   = 0,
    parameter Clk_div    = 4,
    parameter Data_width = 8
)(
    input clk,
    input rst,
    input [Data_width-1:0] i_master_data,
    input [Data_width-1:0] i_slave_data,
    input i_start,

    output [Data_width-1:0] o_slave_out,
    output [Data_width-1:0] o_master_out,
    output o_master_done,
    output o_slave_done
);

    // Internal SPI signal connections
    wire o_TX_mosi;
    wire o_RX_miso;
    wire SPI_sclk;
    wire SPI_cs;

    // Master Instance
    SPI_master #(
        .SPI_mode(SPI_mode),
        .Clk_div(Clk_div),
        .Data_width(Data_width)
    ) u_spi_master (
        .clk(clk),
        .rst(rst),
        .i_TX_data(i_master_data),
        .i_TX_start(i_start),
        .i_SPI_miso(o_RX_miso),
        .o_SPI_mosi(o_TX_mosi),
        .i_TX_cs(SPI_cs),
        .i_SPI_sclk(SPI_sclk),
        .i_TX_done(o_master_done),
        .o_RX_out(o_master_out)
    );

    // Slave Instance
    SPI_slave #(
        .SPI_mode(SPI_mode),
        .Data_width(Data_width)
    ) u_spi_slave (
        .clk(clk),
        .rst(rst),
        .i_TX_mosi(o_TX_mosi),
        .i_TX_sclk(SPI_sclk),
        .i_RX_cs(SPI_cs),
        .i_RX_data(i_slave_data),
        .i_RX_miso(o_RX_miso),
        .i_RX_dataout(o_slave_out),
        .i_RX_done(o_slave_done)
    );

endmodule

