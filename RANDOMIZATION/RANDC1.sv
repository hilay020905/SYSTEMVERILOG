// Declare a class property data as randc bit [1:0] (legal range 0 to 3) and randomize it 12 times in a row, printing the iteration number and value each time.

class packet;
    randc bit [1:0] a; // rand and randc you can check it from here
endclass

module tb;
    packet hilay;
    integer i;
    initial begin
        hilay = new(); 
        for (i = 0 ; i < 12 ; i = i + 1) begin
            hilay.randomize();
            $display("cyclic randomize is like this where a is %0d and itr is %0d", hilay.a, i);
        end
    end
endmodule

    