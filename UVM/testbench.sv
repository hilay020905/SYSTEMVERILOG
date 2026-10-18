package and_pkg;

    import uvm_pkg::*;
    `include "uvm_macros.svh"

class and_transaction extends uvm_sequence_item; //just the mirror copy of the interface
    rand bit a; //for randomizing
    rand bit b;
         bit y;


    `uvm_object_utils_begin(and_transaction) //uvm to register it with the uvm macro 
        `uvm_field_int(a, UVM_ALL_ON) //uvm all on is for the uvm object like print record copy to be supported
        `uvm_field_int(b, UVM_ALL_ON)
        `uvm_field_int(y, UVM_ALL_ON)
    `uvm_object_utils_end

    function new(string name = "and_transaction");
        super.new(name); //class constructor to call parent class ie uvm transaction 
    endfunction
endclass

class and_driver extends uvm_driver #(and_transaction); //driver takes copy of transaction convert into the singals and send it to the interface and then to the dut

    `uvm_component_utils(and_driver)
    
    virtual and_if aif;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db #(virtual and_if)::get(this, "", "aif", aif)) begin 
            `uvm_fatal(get_type_name(), "didnt get the handle for and interface")
        end
    endfunction

    virtual task run_phase(uvm_phase phase);
        and_transaction tr;

        forever begin 
            seq_item_port.get_next_item(tr);

            aif.a = tr.a;
            aif.b = tr.b;
            `uvm_info("DRV", $sformatf("driving a=%0b b=%0b", tr.a, tr.b), UVM_LOW)

            #10; // let the DUT and monitor see this input before the next one
            seq_item_port.item_done();
        end
    endtask
endclass

class and_monitor extends uvm_monitor; //A UVM monitor observes DUT signals and captures their values as transactions. It doesn't just read the output; it can observe both inputs and outputs.

    `uvm_component_utils(and_monitor)

    virtual and_if aif;
    uvm_analysis_port #(and_transaction) mon_analysis_port;

    function new(string name, uvm_component parent); 
        super.new(name, parent);
    endfunction 

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        mon_analysis_port = new("mon_analysis_port", this);

        if (!uvm_config_db #(virtual and_if)::get(this, "", "aif", aif)) begin
            `uvm_fatal(get_type_name(), "Didn't get handle to virtual interface and_if")
        end
    endfunction

    virtual task run_phase(uvm_phase phase);
        and_transaction tr;

        forever begin 
             @(aif.a or aif.b);

            #1;  // Allow output to settle

            tr = and_transaction::type_id::create("tr");

            tr.a = aif.a;
            tr.b = aif.b;
            tr.y = aif.y;

            mon_analysis_port.write(tr);
        end
    endtask

endclass

class and_coverage extends uvm_subscriber #(and_transaction);

    `uvm_component_utils(and_coverage)

    and_transaction trans;

    covergroup cg_and_transaction;
        coverpoint trans.a;
        coverpoint trans.b;
    endgroup

    function new(string name, uvm_component parent);
        super.new(name, parent);
        cg_and_transaction = new();
    endfunction 

    virtual function void write(and_transaction t);
        trans = t;
        cg_and_transaction.sample();
    endfunction
endclass

class and_sequencer extends uvm_sequencer #(and_transaction); // which transaction is to give it to the driver

  `uvm_component_utils(and_sequencer)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

endclass

class and_sequence extends uvm_sequence #(and_transaction);

    `uvm_object_utils(and_sequence) // Register sequence with UVM factory

    function new(string name = "and_sequence");
        super.new(name); // Call parent constructor
    endfunction

    virtual task body();
        for (int i = 0; i < 4; i++) begin // Drive all 4 input combinations: 00, 01, 10, 11
            req = and_transaction::type_id::create("req");
            start_item(req);

            req.a = i[1];
            req.b = i[0];

            finish_item(req);
        end
    endtask

endclass

class and_agent extends uvm_agent;

    `uvm_component_utils(and_agent)

    and_driver m_driver;
    and_monitor m_monitor;
    and_sequencer m_sequencer;
    and_coverage m_coverage;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if (get_is_active()) begin
            m_sequencer = and_sequencer::type_id::create("m_sequencer", this);
            m_driver    = and_driver::type_id::create("m_driver", this);
        end

        m_monitor  = and_monitor::type_id::create("m_monitor", this);
        m_coverage = and_coverage::type_id::create("m_coverage", this);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

        if (get_is_active())
            m_driver.seq_item_port.connect(m_sequencer.seq_item_export);
            m_monitor.mon_analysis_port.connect(m_coverage.analysis_export);
    endfunction

endclass

class and_scoreboard extends uvm_scoreboard;

    `uvm_component_utils(and_scoreboard)

    uvm_analysis_imp #(and_transaction, and_scoreboard) ap_imp;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        ap_imp = new("ap_imp", this);
    endfunction

    function void write(and_transaction tr);

        if (tr.y == (tr.a & tr.b))
            `uvm_info("PASS", "AND gate output correct", UVM_MEDIUM)
        else
            `uvm_error("FAIL", "AND gate output incorrect")

    endfunction
endclass

class and_env extends uvm_env;

    `uvm_component_utils(and_env)

    and_agent      m_agent;
    and_scoreboard m_scoreboard;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        m_agent      = and_agent::type_id::create("m_agent", this);
        m_scoreboard = and_scoreboard::type_id::create("m_scoreboard", this);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        m_agent.m_monitor.mon_analysis_port.connect(m_scoreboard.ap_imp);
    endfunction

endclass

class and_test extends uvm_test;

    `uvm_component_utils(and_test)

    and_env m_top_env;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        m_top_env = and_env::type_id::create("m_top_env", this);
    endfunction

    virtual function void end_of_elaboration_phase(uvm_phase phase);
        uvm_top.print_topology();
    endfunction

    virtual task run_phase(uvm_phase phase);
        and_sequence m_seq = and_sequence::type_id::create("m_seq");

        phase.raise_objection(this);
        m_seq.start(m_top_env.m_agent.m_sequencer);
        #20; // drain time so the monitor/scoreboard finish the last transaction
        phase.drop_objection(this);
    endtask

endclass

endpackage

module tb;

    import uvm_pkg::*;
    import and_pkg::*;
    `include "uvm_macros.svh"

    and_if and_if0();
    and_block dut0 (and_if0);

    initial begin 
        and_if0.a = 0;
        and_if0.b = 0;
    end

    initial begin 
        uvm_config_db #(virtual and_if)::set(null, "uvm_test_top.*", "aif", and_if0);
        run_test("and_test");
    end

    initial begin 
        $dumpfile("dump.vcd");
        $dumpvars(0, tb);
    end
endmodule