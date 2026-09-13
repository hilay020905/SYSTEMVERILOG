class ABC;
  rand bit [3:0]  a;

  // Both are non-static constraints
  constraint c1 { a > 5; }
  constraint c2 { a < 12; }
endclass

module tb;
ABC obj1;
ABC obj2;
  initial begin
    for (int i = 0; i < 5; i++) begin
        obj1 = new ();
        obj2 = new (); 
      obj1.randomize();
      obj2.randomize();
      $display ("obj1.a = %0d, obj2.a = %0d", obj1.a, obj2.a);
    end
  end
endmodule