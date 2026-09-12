class packet;
    float a;
    byte b;

    function new(byte a = 8'h00, byte b = 8'h00);
        this.a = a;
        this.b = b;
    endfunction

    function void display();
        $display("a is %0d and b is %0d",a, b);
    endfunction
endclass

module tb;

packet pk0, pk1, pk2;

initial begin 
    pk0 = new();
    pk0.display();

    pk1 = new(1,5);
    pk1.display();

    pk2 = new(13,14);
    pk2.display();
end

endmodule