class myconfig;
    byte addr_width;
    byte data_width;

    function new (byte addr_width=0, data_width=0); //class constructor
        this.addr_width = addr_width;
        this.data_width = data_width;
    endfunction

    function void display();
        $display("address width = %0d and data width = %0d", addr_width , data_width);
    endfunction
endclass
module tb;
    myconfig a, b, c; //class handle
    initial begin
        a = new (4,5); // class object
        b = a; //remove new for not doing the shallow copy use copy() to use the depp copy including those nested loops
        a.display();
        b.display();
        a.addr_width = 10;
        a.data_width = 11;
        c = new (4,10);
        a.display();
        b.display();
        c.display();
    end
endmodule
