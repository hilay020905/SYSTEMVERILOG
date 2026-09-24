module tb;

    bit clk;
    bit req;
    bit ack;

    logic [7:0] addr;
    logic [7:0] data;

    always #5 clk = ~clk;

    initial begin
        clk  = 0;
        req  = 1;
        ack  = 1;
        addr = 8'h25;
        data = 8'h25;

        #7;
        req = 0;

        #20;
        $finish;
    end

    sequence s_addr_check;
        logic [7:0] captured_addr;

        (req, captured_addr = addr) ##2 (ack && data == captured_addr);
    endsequence

    assert property (@(posedge clk) s_addr_check)
        $display("[%0t] Match: data correctly matches the originally requested address",
                 $time);

endmodule