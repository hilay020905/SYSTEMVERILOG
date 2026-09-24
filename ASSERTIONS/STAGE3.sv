module tb;

    bit in;
    bit out;
    bit clk;

    always #5 clk = ~clk;

    integer i;

    initial begin
        clk = 0;
        in  = 0;
        out = 0;

        for (i = 0; i < 10; i = i + 1) begin
            @(negedge clk);

            in = i % 2;

            // Make out equal to in from 2 cycles ago
            if (i >= 2)
                out = (i-2) % 2;
            else
                out = 0;

            $display("[%0t] in=%0d out=%0d", $time, in, out);
        end

        #10 $finish;
    end

    assert property (@(posedge clk)
        out == $past(in,2)
    )
        $display("[%0t] PASS", $time);
    else
        $display("[%0t] FAIL: out=%0d past_in=%0d",
                 $time, out, $past(in,2));

endmodule