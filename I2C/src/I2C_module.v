module I2C_module #(parameter Data_width=8 , parameter Address=7, parameter clk_div=4)

(
input clk,
input rst,
input [Data_width-1:0] Master_data_in,
input START,
input RD_WR,
input [Address-1:0] Slave_Address,
input [Data_width-1:0] Slave_data_in,

  inout wire sda,             // <-- Bidirectional SDA line
    output wire scl,            // <-- Unidirectional SCL from master

output [Data_width-1:0] Master_dataout,
output Master_done,
output [Data_width-1:0] Slave_dataout,
output Slave_done
);

I2C_master #( .Data_width(Data_width), .Address(Address), .Clk_div(clk_div)) m1 (
        .clk(clk),
        .rst(rst),
        .i_master_start(START),
        .slave_address(Slave_Address),
        .i_master_rd_wr(RD_WR),
        .i_master_datain(Master_data_in),
        .o_master_sdata(sda),
        .o_master_sclk(scl),
        .o_master_dataout(Master_dataout),
        .o_master_done(Master_done)
);

I2C_slave #( .Data_width(Data_width), .Address(Address)) s1 (
        .clk(clk),
        .rst(rst),
        .i_slave_datain(Slave_data_in),
        .i_slave_addr(Slave_Address),
        .i2c_sda(sda),
        .i2c_sclk(scl),
        .o_slave_dataout(Slave_dataout),
        .o_slave_done(Slave_done)
    );

endmodule