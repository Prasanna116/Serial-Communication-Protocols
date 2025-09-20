module Uart_RX (
    input clk,
    input rst,
    input r_data,
    input baud_tick,
    output reg [7:0] r_out,
    output reg r_busy,
    output reg r_done
);

    parameter idle = 2'b00, 
              data  = 2'b10,
              stop  = 2'b11;

    reg [1:0] state, nxt_state;
    reg [7:0] rego;
    reg [2:0] check;

    reg baud_tick_d;
    wire tick = baud_tick & ~baud_tick_d;

    // Edge detector for baud tick
    always @(posedge clk or negedge rst) begin
        if (!rst)
            baud_tick_d <= 0;
        else
            baud_tick_d <= baud_tick;
    end

    // State transition logic
    always @(posedge clk or negedge rst) begin
        if (!rst)
            state <= idle;
        else if (tick)
            state <= nxt_state;
    end

    // FSM Next State Logic
    always @(*) begin
        nxt_state = state; // Default
        case (state)
            idle:  if (!r_data) nxt_state = data;
            data:  nxt_state = (check == 4'd7) ? stop : data;
            stop:  nxt_state = idle;
        endcase
    end

    // Data and control logic
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            rego   <= 0;
            check  <= 0;
            r_busy <= 0;
            r_done <= 0;
            r_out  <= 0;
        end else if (tick) begin
            r_done <= 0; // clear every tick
            case (state)
                idle: begin
                    if(!r_data)
                    r_busy <= 1;
                    check<=0;
                end

                data: begin
                    rego[check] <= r_data;
                        check <= check + 1;
                end
                stop: begin
                    r_busy <= 0;
                    r_out  <= rego;
                    r_done <= 1;
                end
            endcase
        end
    end

endmodule












