module tb;

    bit read;
    bit write;
    bit clk;

    always #1 clk = ~clk;

    covergroup cg @(posedge clk);

        cp_read : coverpoint read {
            bins low  = {0};
            bins high = {1};
        }

        cp_write : coverpoint write {
            bins low  = {0};
            bins high = {1};
        }

        cc_cg : cross cp_read, cp_write {

            bins r0w0 =
                binsof(cp_read.low) &&
                binsof(cp_write.low);

            bins r1w1 =
                binsof(cp_read.high) &&
                binsof(cp_write.high);

            illegal_bins r1w0 =
                binsof(cp_read.high) &&
                binsof(cp_write.low);

            ignore_bins r0w1 =
                binsof(cp_read.low) &&
                binsof(cp_write.high);
        }

    endgroup

    cg coverg;

    initial begin
        integer i;

        coverg = new();

        for (i = 0; i < 5; i = i + 1) begin
            read  = $random;
            write = $random;

            $display("read=%0d and write=%0d", read, write);

            // Since your covergroup has @(posedge clk),
            // don't need coverg.sample() here.
            #1;
        end
    end

    initial begin
        #50;
        $display("coverage = %0.2f", coverg.get_inst_coverage());
        $finish;
    end

endmodule