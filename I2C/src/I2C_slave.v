module I2C_slave #(parameter Data_width=8, parameter Address = 7) (
    input clk,
    input rst,
    input [Data_width-1:0] i_slave_datain,
    input [Address-1:0] i_slave_addr,

    inout wire i2c_sda,
    input i2c_sclk,

    output reg [Data_width-1:0] o_slave_dataout,
    output reg o_slave_done
);

    parameter IDLE = 4'd0,
              READ_ADDRESS = 4'd1,
              WR_ACK = 4'd2,
              READ = 4'd3,
              WRITE_ACK = 4'd4,
              WRITE = 4'd5,
              READ_ACK = 4'd6;

    reg [3:0] state;
    reg [2:0] counter1, counter2;
    reg [Data_width-1:0] datareg, addrreg;

    reg sda, sda_enable;
    reg sclk_d;
    reg delaycyc;
    wire sclk_negedge = (sclk_d == 1 && i2c_sclk == 0);
    wire sclk_posedge = (sclk_d == 0 && i2c_sclk == 1);

    assign i2c_sda = sda_enable ? sda : 1'bz;

    // Store previous SCLK
    always @(posedge clk or negedge rst) begin
        if (!rst)
            sclk_d <= 0;
        else
            sclk_d <= i2c_sclk;
    end

    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            state <= IDLE;
            o_slave_dataout <= 0;
            o_slave_done <= 0;
            sda <= 1;
            sda_enable <= 0;
            counter1 <= 0;
            counter2 <= 0;
            datareg <= 0;
            addrreg <= 0;
        end else begin
            case (state)
                IDLE: begin
                    o_slave_done <= 0;
                    delaycyc<=0;
                    if (i2c_sda == 0 && i2c_sclk == 1) begin
                        state <= READ_ADDRESS;
                        counter1 <= 7;
                        datareg <= i_slave_datain;
                        addrreg <= 0;
                    end
                end

                READ_ADDRESS: begin
                    sda_enable <= 0;
                    if (sclk_posedge) begin
                        addrreg <= {addrreg[6:0], i2c_sda}; // Shift in SDA bit
                        if ((counter1) == 0)
                            state <= WR_ACK;
                        else
                            counter1 <= counter1 - 1;
                    end
                end

                WR_ACK: begin
                    if (sclk_negedge) begin
                        if (addrreg[7:1] == i_slave_addr) begin
                            sda <= 0;        // ACK
                            sda_enable <= 1;
                            counter2 <= 7;
                            if (addrreg[0] == 0)
                                state <= READ;   // Master writes
                            else
                                state <= WRITE;  // Master reads
                        end else begin
                            state <= IDLE;
                        end
                    end
                end

                READ: begin  // Master sends data to slave
                    if (sclk_posedge && (!delaycyc)) begin
                          delaycyc<=1; 
                          sda_enable <= 0;
                    end else if (delaycyc && sclk_posedge)begin
                        o_slave_dataout <= {o_slave_dataout[6:0], i2c_sda}; // Shift in
                        if (counter2 == 0) begin
                            state <= WRITE_ACK;
                            delaycyc<=0;
                        end else begin
                            counter2 <= counter2 - 1;
                           end
                       end
                       end

                WRITE_ACK: begin
                    if (sclk_negedge) begin
                        sda <= 0;  // ACK
                        sda_enable <= 1;
                    end
                    if(sclk_posedge) begin
                      o_slave_done <= 1;
                      sda_enable<=0;
                      state<=IDLE;
                end
                end

                WRITE: begin  // Slave sends data to master
                    if (sclk_negedge) begin
                        sda <= datareg[7];
                        sda_enable <= 1;
                        datareg <= {datareg[6:0], 1'b0}; // Shift left
                        if (counter2 == 0)
                            state <= READ_ACK;
                        else
                            counter2 <= counter2 - 1;
                    end
                end

                READ_ACK: begin
                    if (sclk_posedge && (!delaycyc)) begin
                        delaycyc<=1;
                         sda_enable <= 0;
                    end else if(sclk_posedge && delaycyc) begin
                        if (i2c_sda == 0)
                            state <= IDLE;  // ACK received
                            o_slave_done <= 1;
                             sda_enable<=0;
      
                    end
                 end

  
            endcase
        end
    end

endmodule

              


