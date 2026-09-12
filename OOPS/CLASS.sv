class myconfig;
    byte adder_width;
    byte data_width;

    function new(byte aw = 8, byte dw = 32);
        this.adder_width = aw;
        this.data_width = dw;
    endfunction

    function void display();
        $display("adder width = %0d, data width = %0d",
                 this.adder_width, this.data_width);
    endfunction
endclass


module tb;

    myconfig a;

    initial begin
        a = new(4, 5);
        a.display();
    end

endmodule