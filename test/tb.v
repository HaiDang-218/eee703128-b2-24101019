`default_nettype none
`timescale 1ns / 1ps

module tb;
    reg [7:0] ui_in, uio_in;
    reg ena, clk, rst_n;
    wire [7:0] uo_out, uio_out, uio_oe;

    integer so_ca = 0;
    integer so_sai = 0;

    tt_um_eee703128_24101019 dut (
        .ui_in(ui_in),
        .uo_out(uo_out),
        .uio_in(uio_in),
        .uio_out(uio_out),
        .uio_oe(uio_oe),
        .ena(ena),
        .clk(clk),
        .rst_n(rst_n)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    task kiem;
        input [7:0] mong_doi;
        input [255:0] ten;
        begin
            @(posedge clk);
            #1;
            so_ca = so_ca + 1;

            if (uo_out === mong_doi)
                $display("PASS | %0s | state=%02h", ten, uo_out);
            else begin
                so_sai = so_sai + 1;
                $display("FAIL | %0s | got=%02h expected=%02h",
                         ten, uo_out, mong_doi);
            end
        end
    endtask

    initial begin
        $dumpfile("tb.vcd");
        $dumpvars(0, tb);

        ena = 1;
        rst_n = 0;
        ui_in = 0;
        uio_in = 8'b00000010;

        // Reset Ring
        repeat (2) @(posedge clk);
        #1;

        so_ca = so_ca + 1;
        if (uo_out === 8'h01)
            $display("PASS | Ring reset state | state=%02h", uo_out);
        else begin
            so_sai = so_sai + 1;
            $display("FAIL | Ring reset got=%02h expected=01", uo_out);
        end

        @(negedge clk);
        rst_n = 1;

        // Ring: 8 trang thai
        kiem(8'h02, "Ring state 2");
        kiem(8'h04, "Ring state 3");
        kiem(8'h08, "Ring state 4");
        kiem(8'h10, "Ring state 5");
        kiem(8'h20, "Ring state 6");
        kiem(8'h40, "Ring state 7");
        kiem(8'h80, "Ring state 8");
        kiem(8'h01, "Ring wraparound");

        // Ring disable: giu nguyen trang thai
        @(negedge clk);
        uio_in = 8'b00000000;
        kiem(8'h01, "Ring hold");

        // Reset Johnson
        @(negedge clk);
        uio_in = 8'b00000001;
        rst_n = 0;
        @(posedge clk);
        #1;

        so_ca = so_ca + 1;
        if (uo_out === 8'h00)
            $display("PASS | Johnson reset state | state=%02h", uo_out);
        else begin
            so_sai = so_sai + 1;
            $display("FAIL | Johnson reset got=%02h expected=00", uo_out);
        end

        @(negedge clk);
        rst_n = 1;
        uio_in = 8'b00000011;

        // Johnson: 16 trang thai
        kiem(8'h01, "Johnson state 2");
        kiem(8'h03, "Johnson state 3");
        kiem(8'h07, "Johnson state 4");
        kiem(8'h0F, "Johnson state 5");
        kiem(8'h1F, "Johnson state 6");
        kiem(8'h3F, "Johnson state 7");
        kiem(8'h7F, "Johnson state 8");
        kiem(8'hFF, "Johnson state 9");
        kiem(8'hFE, "Johnson state 10");
        kiem(8'hFC, "Johnson state 11");
        kiem(8'hF8, "Johnson state 12");
        kiem(8'hF0, "Johnson state 13");
        kiem(8'hE0, "Johnson state 14");
        kiem(8'hC0, "Johnson state 15");
        kiem(8'h80, "Johnson state 16");
        kiem(8'h00, "Johnson wraparound");

        // Johnson invalid + disable: giu 55
        @(negedge clk);
        uio_in = 8'b00000001;
        dut.state = 8'h55;
        kiem(8'h55, "Johnson invalid state hold");

        // Johnson invalid + enable: phuc hoi 00
        @(negedge clk);
        uio_in = 8'b00000011;
        kiem(8'h00, "Johnson invalid-state recovery");

        // Ring invalid + disable: giu AA
        @(negedge clk);
        uio_in = 8'b00000000;
        dut.state = 8'hAA;
        kiem(8'hAA, "Ring invalid state hold");

        // Ring invalid + enable: phuc hoi 01
        @(negedge clk);
        uio_in = 8'b00000010;
        kiem(8'h01, "Ring invalid-state recovery");

        // Tong ket
        $display("");
        $display("=== KET QUA: %0d ca, %0d sai ===", so_ca, so_sai);

        if (so_sai == 0)
            $display("TAT CA CA KIEM THU DEU DAT");
        else
            $display("CO CA KIEM THU THAT BAI");

        #10;
        $finish;
    end
endmodule

`default_nettype wire
