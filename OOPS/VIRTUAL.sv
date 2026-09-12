virtual class myconfig; // this is the abstract class and this can not be intitiantiated in tb so we need to extend it always for a class
    byte addr; //it will cause error in sim so remove the virtual it is just used for extending it

    function new(byte addr = 8);
        this.addr = addr;
    endfunction

    virtual function void display();
        $display("addr width = %0d",this.addr);
    endfunction
endclass

class myconfig1 extends myconfig;
    byte data;

    function new(byte addr, byte data = 9);
        super.new(addr);
        this.data = data;
    endfunction

    function void display();
        $display("addr width = %0d, data width = %0d",this.addr, this.data);
    endfunction
endclass


module tb;

    myconfig a;
    myconfig1 b;

    initial begin
        a = new(4);
        a.display();

        b = new(3,4);

        a = b;
        a.display();
    end

endmodule