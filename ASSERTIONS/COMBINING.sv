class packet;

    rand bit a;
    rand bit b;

    // Force a and b to be equal
    constraint c1 {
        a == b;
    }

    function void display();
        $display("Time=%0t  a=%0d  b=%0d", $time, a, b);
    endfunction

endclass


module tb;

    bit clk;
    bit a;
    bit b;

    packet x;

    // Clock
    always #5 clk = ~clk;


    // ------------------------------------------------
    // Sequence 1:
    // a must be true, then b one clock later
    // ------------------------------------------------
    sequence sab1;
        a ##1 b;
    endsequence


    // ------------------------------------------------
    // Sequence 2:
    // a must be true, then b two clocks later
    // ------------------------------------------------
    sequence sab2;
        a ##2 b;
    endsequence


    // ------------------------------------------------
    // Both sequences must start at the same time
    // ------------------------------------------------
    sequence combining;
        sab1 and sab2;
    endsequence


    // ------------------------------------------------
    // Assertion
    // ------------------------------------------------
    assert property (@(posedge clk) combining)
        $display("Time=%0t  PASS: combining", $time);
    else
        $display("Time=%0t  FAIL: combining", $time);


    // ------------------------------------------------
    // Random stimulus
    // ------------------------------------------------
    initial begin

        x = new();

        for (int i = 0; i < 10; i++) begin

            @(negedge clk);

            if (!x.randomize()) begin
                $display("Randomization failed");
            end

            a = x.a;
            b = x.b;

            x.display();

        end

        #20 $finish;

    end

endmodule