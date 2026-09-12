//Declare a rand bit [7:0] queue with exactly 3 elements, and add a foreach constraint so that each element equals its index multiplied by 2 (so the queue always ends up {0, 2, 4}).

class packet;
    rand bit [7:0] a [$];
    constraint c_size {a.size()==3;}
    constraint c_val {
        foreach(a[i])
            a[i] == 8'(i * 2);
    }
    function void display ();
        $display("size of the queue is %0d and value is %0d",a.size, a);
    endfunction
endclass

module tb;
packet hilay;
initial begin 
    hilay = new();
    hilay.randomize();
    hilay.display();
end
endmodule

