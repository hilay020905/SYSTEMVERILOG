//Given a trace where gnt follows req by exactly 2 cycles (req at cycles 1 and 4; gnt at cycles 3 and 6), determine whether req |-> gnt, req |=> gnt, or neither correctly captures this relationship — and if neither does, write the property that does.
module tb;
    
    bit gnt;
    bit req;
    bit rst;
    bit clk;

    always #5 clk = ~clk;

    integer i;

    initial begin 
        for (i = 0 ; i < 10 ; i = i + 1) begin 
            @(posedge clk);
            if (i == 0 || i == 3) begin 
                gnt = 0;
                req = 1;
                rst = 1;
            end
            else if (i == 2 || i == 5) begin 
                gnt = 1;
                req = 0;
                rst = 1;
            end
            else begin 
                gnt = 0;
                req = 0;
                rst = 1;
            end
            $display("req=%0d and gnt=%0d",req,gnt);
        end
        #10 $finish;
    end

    assert property (@(posedge clk) disable iff (rst) req -> gnt); //no errors
endmodule
