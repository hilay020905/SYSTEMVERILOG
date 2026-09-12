class hilay #(parameter int size = 8);

    bit [size-1:0] a;
    bit [size-1:0] b;

    function new(
        bit [size-1:0] a = 0,
        bit [size-1:0] b = 0
    );
        this.a = a;
        this.b = b;
    endfunction

    function void display();
        $display("Number of bits in a = %0d", $bits(this.a));
        $display("Number of bits in b = %0d", $bits(this.b));
        $display("Parameter size = %0d", size);
    endfunction

endclass


module tb;

    hilay #(8) a;
    hilay #(16) b;

    initial begin

        a = new();
        a.display();

        b = new();
        b.display();

    end

endmodule