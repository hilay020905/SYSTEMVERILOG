module tb;

    bit [3:0] mode;
    bit [3:0] cfg;

    integer i;

    bit clk;
    always #1 clk = ~clk;

    covergroup coverg;
        coverpoint mode {
            bins range1 = {[0:7]};
            bins range2 = {[8:15]};
        }
        coverpoint cfg {
            bins range3 = {[0:15]};
        }
    endgroup

    coverg cg;

    initial begin 
        cg = new();
        for (i = 0 ; i < 2 ; i = i + 1) begin
            mode = $random;
            cfg = $random;
            $display("mode = %0d and cfg = %0d", mode, cfg);
            cg.sample();
            #1;
        end
    end
    initial begin
        #40;
        $display("coverage = %0.2f",cg.get_inst_coverage);
        $finish;
    end
endmodule
