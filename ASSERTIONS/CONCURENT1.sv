module tb;

    bit a;
    bit clk;

    always #5 clk = ~clk;

    integer i;

    initial begin
        a = 0;

        for (i = 0; i < 6; i = i + 1) begin

            @(negedge clk);

            if (i == 0 || i == 1 || i == 4)
                a = 1;
            else
                a = 0;

            $display("Time=%0t  a=%0d", $time, a);
        end

        #10 $finish;
    end


    sequence s_a1;
        @(posedge clk) $stable(a);
    endsequence

    sequence s_a2;
        @(posedge clk) $fell(a);
    endsequence

    sequence s_a3;
        @(posedge clk) $rose(a);
    endsequence


    // $stable
    assert property (s_a1)
        $display("Time=%0t  $stable(a) = PASS", $time);
    else
        $display("Time=%0t  $stable(a) = FAIL", $time);


    // $fell
    assert property (s_a2)
        $display("Time=%0t  $fell(a) = PASS", $time);
    else
        $display("Time=%0t  $fell(a) = FAIL", $time);


    // $rose
    assert property (s_a3)
        $display("Time=%0t  $rose(a) = PASS", $time);
    else
        $display("Time=%0t  $rose(a) = FAIL", $time);

endmodule