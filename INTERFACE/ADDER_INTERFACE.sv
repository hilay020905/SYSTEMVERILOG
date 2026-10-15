interface hilay (input clk);
    logic d;
    logic q;

    modport master (input clk, input d, output q);
    modport slave (input clk, output d, input q);
endinterface

module tb;
    bit clk;
    always #5 clk = ~clk;
    hilay h(clk);
    dff dff_inst (
        .clk(h.clk),
        .d(h.d),
        .q(h.q)
    );
integer i;

initial begin
    for (i = 0; i < 10; i++) begin
        @(posedge h.clk);
        h.d = $random;
        $display("d=%0d and q=%0d and clk=%0d", h.d, h.q,clk);
    end
    $finish;
end
endmodule
