module tb;

    event event_a, event_b;
initial begin
    fork 
        begin
            $display("t=%0t fork for a started and waiting for the event to be trigered",$time);
            #10 ->event_a;
            $display("t=%0t event trigered",$time);
        end
        begin 
            $display("waiting for the event to be trigered",$time);
            @event_a;
            $display("t=%0t event trigered using @",$time);
        end
        begin 
            $display("waiting for the event to be trigered",$time);
            #10 wait(event_a.triggered);
            $display("t=%0t event trigered using .triggered",$time);
        end
    join_none

    fork 
        begin
            $display("t=%0t fork for b started and waiting for the event to be trigered",$time);
            #15 ->>event_b; //non blocking event
            $display("t=%0t event trigered",$time);
        end
        begin 
            $display("waiting for the event to be trigered",$time);
            @event_b;
            $display("t=%0t event trigered using @",$time);
        end
        begin 
            $display("waiting for the event to be trigered",$time);
            wait(event_b.triggered);
            $display("t=%0t event trigered using .triggered",$time);
        end
    join
end
    //event_a = event_b; 

endmodule 





