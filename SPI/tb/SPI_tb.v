`timescale 1ns/1ps

module SPI_tb;


    // Parameters
    parameter SPI_mode   = 0;
    parameter Clk_div    = 4;
    parameter Data_width = 8;

reg clk,rst;
reg [Data_width-1:0] i_master_data, i_slave_data;
reg i_start;

wire [Data_width-1:0] o_slave_out, o_master_out;
wire o_master_done, o_slave_done;


 // Instantiate DUT
    SPI_TopModule #(
        .SPI_mode(SPI_mode),
        .Clk_div(Clk_div),
        .Data_width(Data_width)
    ) uut (
        .clk(clk),
        .rst(rst),
        .i_master_data(i_master_data),
        .i_slave_data(i_slave_data),
        .i_start(i_start),
        .o_slave_out(o_slave_out),
        .o_master_out(o_master_out),
        .o_master_done(o_master_done),
        .o_slave_done(o_slave_done)
    );

 // Clock generation: 100 MHz
initial begin
clk=0;
forever #5 clk=~clk; //10ns period
end


    // Stimulus
    initial begin
        // Initialize signals
        rst = 1;
        i_start = 0;
        i_master_data = 8'hA5;  // Master sends A5
        i_slave_data  = 8'h3C;  // Slave sends 3C

        #20 rst = 0;
        #20 rst = 1;

        #30 i_start = 1;
        #40 i_start = 0;

        // Wait for transaction to complete
        wait(o_master_done);
        wait(o_slave_done);

        // Display results
        $display("Master received: %h", o_master_out);
        $display("Slave received : %h", o_slave_out);

      

        #50 $finish;
    end
endmodule
