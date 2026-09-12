//Write a randcase block that picks between three transaction types — "READ", "WRITE", and "ERROR" — so that READ and WRITE are equally likely and ERROR is much rarer, roughly a 1-in-20 chance.

module tb;
    integer i;
    initial begin 
        for(i = 0 ; i < 20 ; i = i + 1 ) begin
            randcase 
                10 : $display("read");
                10 : $display("write");
                1 :  $display("error");
            endcase
        end
    end
endmodule
        