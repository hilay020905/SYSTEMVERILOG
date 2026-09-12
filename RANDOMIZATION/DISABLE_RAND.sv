class Fruits;
  rand bit [3:0] var1;
  rand bit [3:0] var2;
endclass

module tb;
  initial begin
    Fruits f;

    f = new();
    $display ("Before randomization var1=%0d var2=%0d", f.var1, f.var2);

    // Turn off randomization for var1
    f.var1.rand_mode (0);

    // Print if var1 has randomization enabled/disabled
    if (f.var1.rand_mode())
      $display ("Randomization of var1 enabled");
    else
      $display ("Randomization of var1 disabled");

    f.var2.rand_mode (1);

    // Print if var2 has randomization enabled/disabled
    if (f.var2.rand_mode())
      $display ("Randomization of var2 enabled");
    else
      $display ("Randomization of var2 disabled");

    f.randomize();

    $display ("After randomization var1=%0d var2=%0d", f.var1, f.var2);
  end

endmodule