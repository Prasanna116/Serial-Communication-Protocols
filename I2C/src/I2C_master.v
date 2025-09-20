module I2C_master #(parameter Data_width=8, parameter Address = 7, parameter Clk_div = 4)(
    input clk,
    input rst,
    input i_master_start,
    input [Address-1:0] slave_address,
    input i_master_rd_wr,
    input [Data_width-1:0] i_master_datain,

    inout wire o_master_sdata,               // Changed to wire
    output wire o_master_sclk,

    output reg [Data_width-1:0] o_master_dataout,
    output reg o_master_done
);

// FSM states
parameter IDLE = 4'd0,
          START = 4'd1,
          ADDRESS = 4'd2,
          RD_WR_ACK = 4'd3,
          READ = 4'd4,
          WRITE_ACK = 4'd5,
          WRITE = 4'd6,
          READ_ACK = 4'd7,
          STOP = 4'd8;

reg [3:0] state;
reg [Data_width-1:0] adr_reg, data_reg;
reg [2:0] counter1, counter2;

// SCLK generation
reg [$clog2(Clk_div)-1:0] clk_count;
reg sclk, sclk_enable;
reg sclk_d;
reg delaycyc;

wire sclk_negedge = (sclk_d == 1 && o_master_sclk == 0);
wire sclk_posedge = (sclk_d == 0 && o_master_sclk == 1);

// SDA tri-state logic
reg sda_drive_enable;
reg sda_out;
assign o_master_sdata = sda_drive_enable ? sda_out : 1'bz;

// SCLK output
assign o_master_sclk = (!sclk_enable) ? 1 : sclk;

// Clock divider for SCLK
always @(posedge clk or negedge rst) begin
    if (!rst) begin
        clk_count <= 0;
        sclk <= 0;
    end else if (clk_count == (Clk_div - 1)) begin
        sclk <= ~sclk;
        clk_count <= 0;
    end else begin
        clk_count <= clk_count + 1;
    end
end

// SCLK enable logic
always @(posedge clk or negedge rst) begin
    if (!rst)
        sclk_enable <= 0;
    else if (state == IDLE || state == START || state == STOP)
        sclk_enable <= 0;
    else
        sclk_enable <= 1;
end

// Store previous SCLK value
always @(posedge clk or negedge rst) begin
    if (!rst)
        sclk_d <= 0;
    else
        sclk_d <= o_master_sclk;
end

// Main FSM
always @(posedge clk or negedge rst) begin
    if (!rst) begin
        sda_out <= 1;
        sda_drive_enable <= 0;
        o_master_dataout <= 0;
        o_master_done <= 0;
        counter1 <= 0;
        counter2 <= 0;
        adr_reg <= 0;
        data_reg <= 0;
        state <= IDLE;
    end else begin
        case (state)

        IDLE: begin
            sda_out <= 1;
            sda_drive_enable <= 1;
            delaycyc<=0;
            o_master_done <= 0;
            if (i_master_start) begin
                state <= START;
                adr_reg <= {slave_address, i_master_rd_wr};
                data_reg <= i_master_datain;
            end
        end

        START: begin
            sda_out <= 0; // Start condition: SDA goes low while SCL is high
            sda_drive_enable <= 1;
            counter1 <= 7;
            state <= ADDRESS;
        end

        ADDRESS: begin
            if (sclk_negedge) begin
                sda_out <= adr_reg[counter1];
                sda_drive_enable <= 1;
                if (counter1  == 0)
                    state <= RD_WR_ACK;
                else
                    counter1 <= counter1 - 1;
            end
        end

        RD_WR_ACK: begin
               
            if (sclk_posedge && (!delaycyc)) begin 
                  sda_drive_enable<=0;
                  delaycyc<=1;
            end else if(delaycyc && sclk_posedge) begin 
                  delaycyc<=0;
                if (o_master_sdata == 0) begin  // ACK received
                    counter2 <= 7;
                    if (adr_reg[0] == 0)
                        state <= WRITE;
                    else if(adr_reg[0] == 1)
                        state <= READ;
                  
            end
        end else begin
             state<=RD_WR_ACK;
            end
        end

        WRITE: begin
            if (sclk_negedge) begin
                sda_out <= data_reg[counter2];
                sda_drive_enable <= 1;
                if (counter2 == 0)
                    state <= READ_ACK;
                else
                    counter2 <= counter2 - 1;
            end
        end

        READ_ACK: begin
            if (sclk_posedge && (!delaycyc)) begin
                delaycyc<=1;
                sda_drive_enable<=0;
            end else if(sclk_posedge && delaycyc) begin
                delaycyc<=0;
                if (o_master_sdata == 0)
                    state <= STOP;
                else
                    state <= READ_ACK; // NACK, abort
            end
        end

        READ: begin
            sda_drive_enable <= 0; // Release SDA to let slave drive
            if (sclk_posedge) begin
                o_master_dataout[counter2] <= o_master_sdata;
                if (counter2 == 0)
                    state <= WRITE_ACK;
                else
                    counter2 <= counter2 - 1;
            end
        end

        WRITE_ACK: begin
            if (sclk_negedge) begin
                sda_out <= 0; // Master ACKs read data
                sda_drive_enable <= 1;
             end else if(sclk_posedge) begin
                state <= STOP;
                 sda_drive_enable<=0;
            end
        end

        STOP: begin
            o_master_done <= 1;
            state <= IDLE;
            
            end

        endcase
    end
end

endmodule

 
                


        
     
        


       