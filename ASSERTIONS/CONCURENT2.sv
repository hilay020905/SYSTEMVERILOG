module tb;
  bit a, b;
  bit clk;

  // This is a sequence that says 'b' should be high 2 clocks after
  // 'a' is found high. The sequence is checked on every positive
  // edge of the clock which ultimately ends up having multiple
  // assertions running in parallel since they all span for more
  // than a single clock cycle.
  sequence s_ab;
    @(posedge clk) a ##2 b;
  endsequence

  // Print a display statement if the assertion passed
  assert property(s_ab)
  	$display ("[%0t] Assertion passed !", $time);

  always #10 clk = ~clk;

  initial begin
    for (int i = 0; i < 10; i++) begin
      @(posedge clk);
      a <= $random;
      b <= $random;

      $display("[%0t] a=%b b=%b", $time, a, b);
    end

    #20 $finish;
  end
endmodule