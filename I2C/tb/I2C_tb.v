`timescale 1ns/1ps

module I2C_tb;


parameter Data_width=8,
          Clk_div=4, 
          Address=7;
          
reg clk,rst;
reg start,rd_wr;
reg [Data_width-1:0] master_data_in,slave_data_in;
reg [Address-1:0] address;

wire sda,sclk;
wire [Data_width-1:0] master_dataout,slave_dataout;
wire master_done,slave_done;

I2C_module #(.Data_width(Data_width),.Address(Address),.clk_div(Clk_div)) utt(
        .clk(clk),
        .rst(rst),
        .START(start),
        .Slave_Address(address),
        .RD_WR(rd_wr),
        .sda(sda),
        .scl(sclk),
        .Master_data_in(master_data_in),
        .Slave_data_in(slave_data_in),
        .Master_dataout(master_dataout),
        .Slave_dataout(slave_dataout),
        .Master_done(master_done),
        .Slave_done(slave_done)
    );

initial begin
clk=0;
forever #5 clk= ~clk; //Freq= 100 Mhz
end

  initial begin
        // Initial values
        rst = 1;
        start = 0;
        address = 7'b1010101;
        rd_wr = 0;                    // Write operation first
        master_data_in = 8'h5A;    // Master will send this
        slave_data_in  = 8'hA5;    // Slave ready with this if read
        #20;

        rst = 0;
        #20;
        rst = 1;

        // Start I2C write transaction
        #40;
        start = 1;
        #10;
        start = 0;

        // Wait for write transaction to complete
        wait (master_done == 1);
        $display("Write Done. Slave received: %h", slave_dataout);

        // Delay before next transaction
        #200;

        // Set up for read operation
        rd_wr = 1; // Read from slave
        start = 1;
        #10;
        start = 0;

        // Wait for read transaction to complete
        wait (master_done == 1);
        $display("Read Done. Master received: %h", master_dataout);

        // Finish simulation
        #100;
        $finish;
    end

endmodule
