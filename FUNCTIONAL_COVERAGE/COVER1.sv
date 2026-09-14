//Given a 4-bit variable addr (legal values 0 through 15), write a coverpoint with a fixed number of automatic bins that splits the full range into exactly 2 bins.

module tb;

    bit [3:0] addr;

    covergroup cg;
        coverpoint addr {
            bins range1 = {[0:7]};
            bins range2 = {[8:15]};
        }
    endgroup

    bit clk ;
    always #1 clk = ~ clk;

    integer i;

    cg coverg;

    initial begin 
        coverg = new();
        for ( i = 0 ; i < 5 ; i = i + 1) begin 
            addr = $random;
            $display("addr = %0d", addr);
            coverg.sample();
            #1;
        end
    end
    initial begin 
        #50;
        $display("coverage = %0.2f",coverg.get_inst_coverage());
        $finish;
    end
endmodule