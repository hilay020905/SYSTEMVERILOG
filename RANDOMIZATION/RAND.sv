//Without writing a class, use std::randomize() to randomize a local variable delay (an int) so it's constrained between 5 and 20, inclusive. Check the return value and print an error if it fails.
module tb;

    int delay;

    initial begin // randomize output 1
        if (std::randomize(delay) with {
            delay >= 5;
            delay <= 20;
        }) begin
            $display("delay = %0d", delay);
        end
        else begin
            $display("Randomization failed");
        end
    end

endmodule

