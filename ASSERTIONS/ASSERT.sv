//Write a property that checks: whenever req is high, busy must be high on the very next clock, and done must be high exactly 3 clocks after that.
module tb;
bit req;
bit busy;
bit done;
integer i;

bit clk;

always #5 clk = ~clk;

initial begin 
    for (i = 0 ; i < 10 ; i = i + 1) begin
        {req,busy,done} = $random;
        $display("req=%0d, busy =%0d, done=%0d",req,busy,done);
        @(posedge clk);
    end
    #10 $finish;
end

sequence s_req_busy;
    req ##1 busy;
endsequence

sequence s_busy_done;
    busy ##3 done;
endsequence

property p_handshake;
@(posedge clk) s_req_busy ##1 s_busy_done;
endproperty

assert property (p_handshake);
endmodule