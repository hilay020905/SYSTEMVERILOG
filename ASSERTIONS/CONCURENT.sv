module tb;
    bit a;
    bit b;
    bit clk;

    always #5 clk = ~clk;

    integer i;

    initial begin
        for (i = 0; i < 10 ; i = i + 1) begin
            {a,b} = $random;
            $display("a=%0d and b=%0d",a,b);
            @(posedge clk);
        end
        #10 $finish;
    end

    assert property (@(posedge clk) a & b);
endmodule  
