//Extend the Beverage class with a second field, bit [7:0] checksum, that is not declared rand. In post_randomize(), set checksum to the bitwise complement of beer_id (~beer_id), then print both fields.

class Beverage;
  bit [7:0] checksum;
  rand bit [7:0] beer_id;
  constraint c_beer_id { beer_id >= 10; beer_id <= 50; };

  function void post_randomize (); //cant be declared as virtual but it act as virtual
  	$display ("This will be called just after randomization");
    this.checksum = ~beer_id;
    $display("This is checksum %0d and this is the beer_id %0d",checksum, beer_id); 
  endfunction

endclass

module tb;
   Beverage b;

    initial begin
      b = new ();
      $display ("Initial beerId = %0d", b.beer_id);
      if (b.randomize ()) //if beer_id randomize is successful then only the post_randomize is called!
      	$display ("Randomization successful!");
      $display ("After randomization beerId = %0d", b.beer_id);
    end
endmodule