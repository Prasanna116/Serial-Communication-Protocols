module SPI_master #(
    parameter SPI_mode = 0,
    parameter Clk_div = 4,
    parameter Data_width = 8
)(
    input clk,
    input rst,
    input [7:0] i_TX_data,
    input i_TX_start,
    input i_SPI_miso,

    output reg o_SPI_mosi,
    output reg i_TX_cs,
    output reg i_SPI_sclk,
    output reg i_TX_done,
    output reg [Data_width-1:0] o_RX_out
);

    reg [$clog2(Clk_div)-1:0] i_SPI_clk_count;
    reg sclk_int;

    parameter IDLE = 2'b00,
              START = 2'b01,
              TRANSFER = 2'b10,
              STOP = 2'b11;

    reg [1:0] state, nxt_state;
    reg [$clog2(Data_width):0] counter,counter1;
    reg [Data_width-1:0] hold_reg, rx_reg;

    // CPOL and CPHA from mode
    wire cpol = (SPI_mode == 2) | (SPI_mode == 3);
    wire cpha = (SPI_mode == 1) | (SPI_mode == 3);

    // Clock Divider
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            i_SPI_clk_count <= 0;
            sclk_int <= 0;
        end else if (state == TRANSFER) begin
            if (i_SPI_clk_count == Clk_div - 1) begin
                i_SPI_clk_count <= 0;
                sclk_int <= ~sclk_int;
            end else begin
                i_SPI_clk_count <= i_SPI_clk_count + 1;
            end
        end else begin
            sclk_int <= cpol;
            i_SPI_clk_count <= 0;
        end
    end

    // SCLK output with CPOL
    always @(*) begin
        i_SPI_sclk = sclk_int ^ cpol;
    end

    // FSM state register
    always @(posedge clk or negedge rst) begin
        if (!rst)
            state <= IDLE;
        else
            state <= nxt_state;
    end

    // FSM logic and data handling
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            counter <= 0;
            counter1 <=0;
            hold_reg <= 0;
            rx_reg <= 0;
            o_SPI_mosi <= 0;
            i_TX_cs <= 1'b1;
            i_TX_done <= 1'b0;
            o_RX_out <= 0;
            nxt_state <= IDLE;
        end else begin
            case (state)
                IDLE: begin
                    i_TX_cs <= 1'b1;
                    i_TX_done <= 1'b0;
                    if (i_TX_start) begin
                        hold_reg <= i_TX_data;
                        counter <= 0;
                        counter1 <= 0;
                        nxt_state <= START;
                    end else begin
                        nxt_state <= IDLE;
                    end
                end

                START: begin
                    i_TX_cs <= 1'b0;
                    if (!cpha) begin
                        o_SPI_mosi <= hold_reg[Data_width - 1]; //Preload MSB
                    end
                    nxt_state <= TRANSFER;
                end

                TRANSFER: begin
                    if (i_SPI_clk_count == Clk_div - 1) begin
                        if (sclk_int == cpha) begin
                            rx_reg <= {rx_reg[Data_width - 2:0], i_SPI_miso}; // sample
                            counter1 <= counter1+1;
                        end else begin
                            o_SPI_mosi <= (!cpha) ? hold_reg[Data_width - 2] : hold_reg[Data_width - 1] ; // send MSB
                            hold_reg <= {hold_reg[Data_width - 2:0], 1'b0}; // left shift 
                            counter <= counter + 1;
                        end
                    end
                     if ((counter == Data_width ) && (counter1 == Data_width )) begin
                                nxt_state <= STOP;
                            end
                end

                STOP: begin
                    i_TX_cs <= 1'b1;
                    i_TX_done <= 1'b1;
                    o_RX_out <= rx_reg;
                    nxt_state <= IDLE;
                end
            endcase
        end
    end

endmodule









