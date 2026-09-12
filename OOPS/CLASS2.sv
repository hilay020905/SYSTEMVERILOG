class hilay;
    bit a;
    bit [7:0] b;

    function new (bit a = 0, byte b = 0);
        this.a = a;
        this.b = b;
    endfunction

    function void display ();
        $display("a is %0d and b is %0d",a, b);
    endfunction

endclass

module tb;
    hilay hi;
    initial begin 
        hi = new(1,3);
        hi.display();
    end
endmodule

        