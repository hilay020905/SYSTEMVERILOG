class ABC;
  rand bit[3:0] array [5];

  // Intrepreted as int'(array[0]) + int'(array[1]) + .. + int'(array[4]) == 20;
  constraint c_sum { array.sum() with (int'(item)) == 20; }

endclass

module tb;
    ABC abc;
  initial begin
    abc = new();
    abc.randomize();
    $display ("array = %p", abc.array);
  end
endmodule