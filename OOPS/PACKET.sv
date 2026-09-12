class packet;
    int count;

    function new (int c = 0);
        count = c;
    endfunction
endclass

module tb;

packet pkt, pkt_alias, pkt_copy;

initial begin 
    
pkt = new(5);
pkt_alias = pkt;
$display("pkt is %0d and pkt_count is %0d", pkt.count , pkt_alias.count);
pkt.count = 9; 
$display("pkt is %0d and pkt_count is %0d", pkt.count , pkt_alias.count);

pkt_copy = new(5);
$display("pkt_copy is %0d", pkt_copy.count);

end


endmodule

