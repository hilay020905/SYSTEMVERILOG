module tb;

    mailbox mbx = new(3);
    integer i;
    initial begin 
        for (i=0; i < 10; i = i + 1) begin 
            $display("mailbox starting to put its value at t = %0d",$time);
            mbx.put(i);
            $display("value in mbx = %0d and mbx size = %0d",i ,mbx.num());
        end
    end
    initial begin
		forever begin
			int idx;
			#2 mbx.get (idx);
          	$display ("[%0t] Thread1: Got item #%0d, size=%0d", $time, idx, mbx.num());
		end
	end
endmodule
