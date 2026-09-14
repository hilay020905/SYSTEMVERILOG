//Starting from the single-coverpoint example, add a second coverpoint that tracks cfg directly (not a bit-slice). Given the sampled values in the output log (cfg = 0x1, 0x3, 0x5, 0x2, 0x5), how many of the 8 possible values were hit, and what coverage percentage would that coverpoint alone report?

module tb;

bit [1:0] mode;
bit [2:0] cfg;

bit clk;
integer i;
always #1 clk = ~ clk;

covergroup coverg@(posedge clk);
    cg_mode : coverpoint mode; //instance
    cg_cfg  : coverpoint cfg;
endgroup

coverg abc; //intiantiated

initial begin 
    abc = new();

    for (i = 0 ; i < 50 ; i = i + 1) begin //make it 500 to increase coverage
        mode = $random;
        cfg = $random;
        abc.sample();
        $display("mode = %0d and cfg = %0d", mode,cfg);
        #1;
    end
end
initial begin 
    #500; //covergroup sampled after it has done its work
    $display("coverage = %0.2f",abc.get_inst_coverage());
    $finish;
end
endmodule