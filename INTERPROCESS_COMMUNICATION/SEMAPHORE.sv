module tb;
    
    semaphore key;
    initial begin
       key = new(2); //only 2 key is assigned
       fork  
       worker0 ();
       worker1 ();
       worker2 ();
       join_none
    end

 
        task getroom (bit [1:0] id);
            fork 
                begin 
                    $display("t=%0t worker with id=%0d is trying to get a key",$time, id);
                    key.get(1);
                    $display("t=%0t worker with id=%0d gott a key",$time, id);
                end
            join_none
        endtask
        task putroom (bit [1:0] id);
            fork 
                begin 
                    $display("t=%0t worker with id=%0d have completed its work",$time, id);
                    key.put(1);
                    $display("t=%0t worker with id=%0d have put down the key",$time, id);
                end
            join_none
        endtask

        task worker0();
            getroom(0);
            #10
            putroom(0);
        endtask
        task worker1();
            getroom(1);
            #10
            putroom(1);
        endtask
        task worker2();
            getroom(2);
            #11
            putroom(2);
        endtask

endmodule





