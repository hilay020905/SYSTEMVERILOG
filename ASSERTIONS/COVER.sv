//A property p_check: req |=> ack is checked against three separate occurrences of req during a test. Two of them are correctly followed by ack; the third is not. What would assert property(p_check) report, and what would cover property(p_check) report?
module tb;
    bit req;
    bit ack;
    bit clk;

    always #5 clk = ~clk;

    integer i;

    initial begin 
        for (i = 1; i < 7; i = i + 1) begin
            @(posedge clk);
            if (i < 4) begin
                req = i%2;
                ack = (i-1)%2;
            end
            else begin 
                req = 1;
                ack = 0;
            end
            $display("req=%0d and ack=%0d",req,ack);
        end
        #5 $finish;
    end

    property p_check;
        @(posedge clk) req |=> ack;
    endproperty

    assert property (p_check);
    cover property (p_check);
endmodule


