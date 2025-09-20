module SPI_slave #(
    parameter SPI_mode = 0,
    parameter Data_width = 8
)(
    input clk,
    input rst,
    input i_TX_mosi,
    input i_TX_sclk,
    input i_RX_cs,
    input [Data_width-1:0] i_RX_data,

    output reg i_RX_miso,
    output reg [Data_width-1:0] i_RX_dataout,
    output reg i_RX_done
);

    // FSM states
    parameter IDLE    = 2'b00,
              START   = 2'b01,
              TRANSFER= 2'b10,
              STOP    = 2'b11;

    reg [1:0] state, nxt_state;

    reg [Data_width-1:0] tx_reg, rx_reg;
    reg [$clog2(Data_width):0] counter,counter1;

    // CPOL and CPHA logic based on SPI_mode
    wire cpol = (SPI_mode == 2) || (SPI_mode == 3);
    wire cpha = (SPI_mode == 1) || (SPI_mode == 3);

    // Edge detection on SCLK
    reg i_TX_sclk_prev;
    wire rising_edge = (i_TX_sclk_prev == 0) && (i_TX_sclk == 1);
    wire falling_edge = (i_TX_sclk_prev == 1) && (i_TX_sclk == 0);

    // Define sample and shift edges based on mode
    wire sample_edge = (cpol ^ cpha) ? falling_edge : rising_edge;
    wire shift_edge  = (cpol ^ cpha) ? rising_edge  : falling_edge;

    // Store previous SCLK for edge detection
    always @(posedge clk or negedge rst) begin
        if (!rst)
            i_TX_sclk_prev <= cpol;
        else
            i_TX_sclk_prev <= i_TX_sclk;
    end

    // FSM state transition
    always @(posedge clk or negedge rst) begin
        if (!rst)
            state <= IDLE;
        else
            state <= nxt_state;
    end

    // FSM operation and datapath
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            i_RX_miso     <= 0;
            i_RX_dataout  <= 0;
            i_RX_done     <= 0;
            tx_reg        <= 0;
            rx_reg        <= 0;
            counter       <= 0;
            counter1      <= 0;
            nxt_state     <= IDLE;
        end else begin
            case (state)
                IDLE: begin
                    i_RX_done <= 0;
                    counter   <= 0;
                    counter1 <=0;
                    if (!i_RX_cs) begin
                        tx_reg    <= i_RX_data;
                        nxt_state <= START;
                    end else begin
                        nxt_state <= IDLE;
                    end
                end

                START: begin
                    if (!cpha) begin
                        i_RX_miso <= tx_reg[Data_width - 1]; // preload MSB
                    end
                    nxt_state <= TRANSFER;
                end

                TRANSFER: begin
                        if (sample_edge) begin
                            rx_reg <= {rx_reg[Data_width - 2:0], i_TX_mosi};
                            counter <= counter + 1;
                        end
                        if (shift_edge) begin
                            // drive MISO with correct bit and shift
                            i_RX_miso <= (!cpha) ? tx_reg[Data_width - 2]: tx_reg[Data_width - 1];
                            tx_reg    <= {tx_reg[Data_width - 2:0], 1'b0};
                            counter1 <=counter1 + 1;
                        end
 
                       if (((counter == Data_width ) && (counter1 == Data_width ))) begin
                                nxt_state <= STOP;
                       end
                end

                STOP: begin
                    i_RX_dataout <= rx_reg;
                    i_RX_done    <= 1;
                    nxt_state    <= IDLE;
                end
            endcase
        end
    end

endmodule











