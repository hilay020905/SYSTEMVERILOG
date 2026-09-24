//Write an immediate assertion inside an always @(posedge clk) block that checks wr_en and rd_en are never both high at the same time. Name the assertion a_mutex, and print "[FAIL] wr_en and rd_en both high!" on failure.
module tb;

    bit wr_en;
    bit rd_en;

    bit clk;

    always #5 clk = ~clk;

    integer i;

    initial begin 
      for (i = 0 ; i < 10 ; i = i + 1) begin 
        {wr_en,rd_en} = $random;
      end
      #100 $finish;
    end


always @ (posedge clk) begin
  a_mutex: assert (!(wr_en && rd_en)) begin
    $display ("[FAIL] wr_en and rd_en both are not high!");
  end
  else begin
    $display ("[FAIL] wr_en and rd_en both high!");
  end
end
endmodule