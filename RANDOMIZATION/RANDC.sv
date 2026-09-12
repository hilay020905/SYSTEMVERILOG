class packet;
    byte a;
    randc byte b; //randamization with constraint
    constraint c_b {b < 7;}

    function new(byte a, b);
        this.a = a;
        this.b = b;
    endfunction

    function void display();
        $display("a is %0d",this.a);
        $display("b is %0d",this.b);
    endfunction

endclass

module tb;

    packet hilay;
    initial begin 
        hilay = new(4,7);
        hilay.display();
        if (hilay.randomize()) begin //rand outputs 1
            $display("b is %0d",hilay.b);
        end
        else begin
            $display("constraint failed");
        end
    end
    initial begin 
        hilay = new(4,7);
        hilay.display();
        if (hilay.randomize() with {b>20;}) begin //rand outputs 0
            $display("b is %0d",hilay.b);
        end
        else begin
            $display("constraint failed");
        end
    end
endmodule


    
