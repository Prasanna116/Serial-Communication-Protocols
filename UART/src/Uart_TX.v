module Uart_TX (
    input clk,
    input rst,
    input [7:0] data_in,
    input t_start,
    input baud_tick,
    output reg d_out,
    output reg t_busy
);

    parameter idle  = 2'b00,
              start = 2'b01,
              data  = 2'b10,
              stopp = 2'b11;

    reg [1:0] state, nxt_state;
    reg [7:0] rego;
    reg [2:0] check;
    reg baud_tick_d;
    // Detect rising edge of baud_tick
    wire tick = baud_tick & ~baud_tick_d;

    always @(posedge clk or negedge rst) begin
        if (!rst)
            baud_tick_d <= 0;
        else
            baud_tick_d <= baud_tick;
    end

    // Sequential logic: State update
    always @(posedge clk or negedge rst) begin
        if (!rst)
            state <= idle;
        else if (tick)
            state <= nxt_state;
    end

    // Sequential logic: Registers update
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            rego <= 0;
            check <= 0;
            t_busy <= 0;
            d_out <= 1;
        end
        else if (tick) begin
            case (state)
                idle: begin
                    if (t_start) begin
                        rego <= data_in;
                        check <= 0;
                        t_busy <= 1;
                        d_out <= 1; 
                    end
                    else begin
                        t_busy <= 0;
                        d_out <= 1;  // line idle
                    end
                end

                start: begin
                    d_out <= 0;  // start bit
                end

                data: begin
                    d_out <= rego[check];
                    check <= check + 1;
                end

                stopp: begin
                    d_out <= 1;     // stop bit
                    t_busy <= 0;
                end
            endcase
        end
    end

    // Next-state logic
    always @(*) begin
        case (state)
            idle: begin
                if (t_start)
                    nxt_state = start;
                else
                    nxt_state = idle;
            end

            start:
                nxt_state = data;

            data:
                nxt_state = (check == 3'd7)? stopp : data;

            stopp:
                nxt_state = idle;

            default:
                nxt_state = idle;
        endcase
    end

endmodule


