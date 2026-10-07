
`default_nettype none

module tt_um_eee703128_24101019 (
    input  wire [7:0] ui_in,
    output wire [7:0] uo_out,
    input  wire [7:0] uio_in,
    output wire [7:0] uio_out,
    output wire [7:0] uio_oe,
    input  wire       ena,
    input  wire       clk,
    input  wire       rst_n
);

    // uio_in[0]: 0 = Ring, 1 = Johnson
    // uio_in[1]: 1 = cho phep dem
    // uo_out[7:0]: trang thai bo dem

    wire mode   = uio_in[0];
    wire enable = uio_in[1];

    reg [7:0] state;
    reg       mode_r;

    function ring_valid;
        input [7:0] s;
        begin
            case (s)
                8'h01, 8'h02, 8'h04, 8'h08,
                8'h10, 8'h20, 8'h40, 8'h80:
                    ring_valid = 1'b1;
                default: ring_valid = 1'b0;
            endcase
        end
    endfunction

    function johnson_valid;
        input [7:0] s;
        begin
            case (s)
                8'h00, 8'h01, 8'h03, 8'h07,
                8'h0F, 8'h1F, 8'h3F, 8'h7F,
                8'hFF, 8'hFE, 8'hFC, 8'hF8,
                8'hF0, 8'hE0, 8'hC0, 8'h80:
                    johnson_valid = 1'b1;
                default: johnson_valid = 1'b0;
            endcase
        end
    endfunction

    always @(posedge clk) begin
        if (!rst_n) begin
            state  <= 8'h01;
            mode_r <= 1'b0;
        end else begin
            mode_r <= mode;

            if (mode != mode_r) begin
                if (mode)
                    state <= 8'h00;
                else
                    state <= 8'h01;
            end else if (!mode && !ring_valid(state)) begin
                state <= 8'h01;
            end else if (mode && !johnson_valid(state)) begin
                state <= 8'h00;
            end else if (ena && enable) begin
                if (!mode)
                    state <= {state[6:0], state[7]};
                else
                    state <= {state[6:0], ~state[7]};
            end
        end
    end

    assign uo_out  = state;
    assign uio_out = 8'b0;
    assign uio_oe  = 8'b0;

    wire _unused = &{ui_in, 1'b0};

endmodule

`default_nettype wire
