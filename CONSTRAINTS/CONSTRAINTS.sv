//show all the possible type of constraints in this using randomize function and constraint block.

class ABC;
    rand byte a; //relational constraint
    rand byte b; //inside constraint 
    rand byte c; //weighted constraint 1
    rand byte d; //weighted constraint 2
    rand byte e; //implication constraint 
    rand bit en_e; 
    rand byte inv_b;
    rand byte f; //inplication constraint with if-else
    rand byte g; //external constraints
    rand byte h; // inline constraint
    rand bit i_i; // for solve before 
    rand bit [2:0] i; //solve before no use 
    rand bit [2:0] i_sb; //solve before use
    rand bit[4:0][3:0] array [3][5];

    constraint c1 {a > 10;}
    constraint c2 {b inside {[4:7]};}
    constraint c3 {!(inv_b inside {[4:7]});}
    constraint c4 {c dist {0 := 5, 1 := 30, 2 := 50, 3 := 15};}
    constraint c5 {d dist{0 :/ 5, 1 :/ 30, 2 :/ 50, 3 :/ 15};} 
    constraint c6 {e inside {[4:8]} -> en_e == 1;} // if that is not inside it doesnt gaurantee that the en wil be 1!
    constraint c7 {if (f inside {[4:8]}) 
                         en_e == 1;
                  }
    extern constraint c8;
    constraint c9 {i_i -> i==3;}
    constraint c10 {i_i -> i_sb==3;
            solve i_i before i_sb;
    }
    constraint c11 {
    foreach (array[i]) {
    	foreach (array[i][j]) {
          foreach (array[i][j][k]) {
            if (k%2 == 0)
              array[i][j][k] == 'hF;
            else
              array[i][j][k] == 0;
        }
      }
    }
  }


    function void display();
        $display("a = %0d, b = %0d, c = %0d, d = %0d, e = %0d, en_e = %0d, inv_b = %0d, f = %0d, g = %0d, h = %0d, i_i = %0d, i = %0d, i_sb = %0d"
        , a,b,c,d,e,en_e,inv_b,f,g,h,i_i,i,i_sb);
        $display("array is %0d", array);
    endfunction
endclass

constraint ABC::c8 {g > 10;}

module tb;
        ABC a;
        integer i;
        initial begin 
            for ( i = 0 ; i < 25 ; i = i + 1) begin 
                a = new();
                a.c1.constraint_mode(0); //TURNING OFF THE C1
                a.randomize();
                assert(a.randomize() with {h == 7;});
                a.display();
            end 
        end
endmodule
