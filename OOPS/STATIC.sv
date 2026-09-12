class Packet;
	bit [15:0] 	addr;
	bit [7:0] 	data;
	static int 	static_ctr = 0;
		   int 	ctr = 0;

	function new (bit [15:0] ad, bit [7:0] d);
		addr = ad;
		data = d;
		static_ctr++;
		ctr++;
		$display ("static_ctr=%0d ctr=%0d addr=0x%0h data=0x%0h", static_ctr, ctr, addr, data);
	endfunction
endclass

module tb;
	initial begin
		Packet 	p1, p2, p3;
		p1 = new (16'hdead, 8'h12);
		p2 = new (16'hface, 8'hab);
		p3 = new (16'hcafe, 8'hfc);
	end
endmodule