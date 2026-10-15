`timescale 1ns/1ps


//============================================================================
// [PART 1] INTERFACE BASICS
//   - an interface is a bundle of signals; declare them as logic
//   - the clock is passed in as an interface PORT
//============================================================================
interface cnt_if #(parameter WIDTH = 4) (input bit clk);
  logic             rstn;
  logic             load_en;
  logic [WIDTH-1:0] load;
  logic [WIDTH-1:0] count;
  logic             down;
  logic             rollover;
endinterface

// DUT
module counter_ud
  #(parameter WIDTH = 4)
  (
    input                   clk,
    input                   rstn,
    input wire [WIDTH-1:0]  load,
    input                   load_en,
    input                   down,
    output                  rollover,
    output reg [WIDTH-1:0]  count
  );

  always @(posedge clk or negedge rstn) begin
    if (!rstn)
      count <= 0;
    else if (load_en)
      count <= load;
    else if (down)
      count <= count - 1;
    else
      count <= count + 1;
  end

  assign rollover = &count;
endmodule

module tb_counter #(parameter time START = 0);
  logic clk = 0;                 // NOTE: initialise it, else ~x stays x forever
  always #10 clk = ~clk;         // half period 10ns => 50 MHz

  cnt_if cnt_if0 (clk);          // instance of the interface (default WIDTH=4)

  // explicit connection: DUT port <- interface member
  counter_ud c0 (.clk      (cnt_if0.clk),
                 .rstn     (cnt_if0.rstn),
                 .load     (cnt_if0.load),
                 .load_en  (cnt_if0.load_en),
                 .down     (cnt_if0.down),
                 .rollover (cnt_if0.rollover),
                 .count    (cnt_if0.count));

  initial begin
    bit       load_en, down;
    bit [3:0] load;
    int       delay;           // declared, then assigned (a declaration-with-init
                               // in a static block would only run once at t=0)
    #START;
    $display("\n---- [PART 1] interface basics: counter_ud ----");
    $monitor("[%0t] down=%0b load_en=%0b load=0x%0h count=0x%0h rollover=%0b",
             $time, cnt_if0.down, cnt_if0.load_en, cnt_if0.load,
             cnt_if0.count, cnt_if0.rollover);   // only ONE $monitor is active at a time

    // initialise TB-driven interface signals
    cnt_if0.rstn    <= 0;
    cnt_if0.load_en <= 0;
    cnt_if0.load    <= 0;
    cnt_if0.down    <= 0;

    repeat (5) @(posedge clk);   // release reset after 5 clocks
    cnt_if0.rstn <= 1;

    for (int i = 0; i < 5; i++) begin
      delay = $urandom_range(1, 30);
      #(delay);
      std::randomize(load, load_en, down);
      cnt_if0.load    <= load;
      cnt_if0.load_en <= load_en;
      cnt_if0.down    <= down;
    end

    repeat (5) @(posedge clk);
    $monitoroff;
    $display("---- [PART 1] done ----");
  end
endmodule


//============================================================================
// [PART 2] PARAMETERISED INTERFACE + MODPORTS + `.*` BUNDLING
//   - modport = direction view of the same signals for each user
//   - master drives addr/data, slave drives sready
//============================================================================
interface ms_if #(parameter D_WIDTH = 8) (input logic clk);
  logic                sready;   // slave ready to accept data
  logic                rstn;     // active-low reset
  logic [1:0]          addr;
  logic [D_WIDTH-1:0]  data;

  modport slave  (input  addr, data, rstn, clk,
                  output sready);

  modport master (output addr, data,
                  input  clk, sready, rstn);
endinterface

module ms_master (ms_if.master mif);          // port type = interface.modport
  always @(posedge mif.clk) begin
    if (!mif.rstn) begin
      mif.addr <= 0;
      mif.data <= 0;
    end else if (mif.sready) begin            // send new addr/data only if slave is ready
      mif.addr <= mif.addr + 1;
      mif.data <= mif.addr * 4;
    end                                       // else: hold current values
  end
endmodule

module ms_slave (ms_if.slave mif);
  logic [$bits(mif.data)-1:0] last;
  always @(posedge mif.clk) begin
    if (!mif.rstn) begin
      mif.sready <= 0;
    end else begin
      mif.sready <= ~mif.sready;              // toggles: ready every other clock
      if (mif.sready) begin
        last <= mif.data;
        $display("[%0t] [PART 2] slave got addr=%0d data=%0d", $time, mif.addr, mif.data);
      end
    end
  end
endmodule

module tb_ms #(parameter time START = 0);
  logic clk = 0;
  always #5 clk = ~clk;

  // parameter override on an interface instance: data is 16 bits here
  ms_if #(.D_WIDTH(16)) mif (clk);

  // port name 'mif' == instance name 'mif'  =>  `.*` connects it automatically
  ms_master m0 (.*);
  ms_slave  s0 (.*);

  initial begin
    #START;
    $display("\n---- [PART 2] modports + parameter + .* bundling ----");
    mif.rstn <= 0;
    repeat (3)  @(posedge clk);
    mif.rstn <= 1;
    repeat (12) @(posedge clk);
    mif.rstn <= 0;                            // back to reset => slave goes quiet
    $display("---- [PART 2] done ----");
  end
endmodule


//============================================================================
// [PART 3] SAME INTERFACE INSTANCE SHARED BY SEVERAL MODULES
//   - three slaves see the SAME enable and gnt
//============================================================================
interface shared_if (input logic clk, reset);   // clk/reset are ports: do NOT redeclare
  logic enable;
  logic gnt;
endinterface

module d_slave #(parameter int ID = 0) (shared_if s_if);
  always @(posedge s_if.clk)                    // signals reached through the handle s_if
    if (s_if.enable & s_if.gnt)
      $display("[%0t] [PART 3] d_slave[%0d] sees enable & gnt", $time, ID);
endmodule

module d_top (input logic clk, reset);
  shared_if sh_if (.clk(clk), .reset(reset));   // ONE instance

  d_slave #(0) slave_0 (.s_if(sh_if));          // all three connect to it
  d_slave #(1) slave_1 (.s_if(sh_if));
  d_slave #(2) slave_2 (.s_if(sh_if));
endmodule

module tb_shared #(parameter time START = 0);
  logic clk = 0;
  always #5 clk = ~clk;
  logic reset;

  d_top dtop (.clk(clk), .reset(reset));

  initial begin
    reset = 1;
    dtop.sh_if.enable = 0;                      // hierarchical reference into the interface
    dtop.sh_if.gnt    = 0;
    #START;
    $display("\n---- [PART 3] shared interface ----");
    @(posedge clk);
    dtop.sh_if.enable <= 1;
    dtop.sh_if.gnt    <= 1;
    repeat (2) @(posedge clk);
    dtop.sh_if.enable <= 0;
    dtop.sh_if.gnt    <= 0;
    repeat (2) @(posedge clk);
    $display("---- [PART 3] done ----");
  end
endmodule


//============================================================================
// [PART 4] INTERFACE ARRAYS + GENERIC INTERFACE PORT
//============================================================================
interface arr_if ();                             // no ports (clk is passed to the modules)
  logic       gnt;
  logic       ack;
  logic [7:0] irq;
endinterface

// typed interface port: the name 'dut_if' is what you use in the body
module arr_design (arr_if dut_if, input logic clk);
  always @(posedge clk)
    dut_if.gnt <= dut_if.ack;
endmodule

// GENERIC interface port: accepts ANY interface type that has .ack and .irq
module gen_design (interface a, input logic clk);
  always @(posedge clk)
    if (a.ack) a.irq <= a.irq + 1;
endmodule

module tb_array #(parameter time START = 0);
  logic clk = 0;
  always #5 clk = ~clk;

  arr_if wb_if [3:0] ();                         // array of 4 interfaces
  arr_if single_if ();                           // a single one

  // one design per array element
  genvar i;
  generate
    for (i = 0; i < 4; i++) begin : g_dut
      arr_design md (wb_if[i], clk);
    end
  endgenerate

  // `.*` connects 'clk' by name; generic port 'a' has to be named explicitly
  gen_design g0 (.*, .a(single_if));

  initial begin
    wb_if[0].ack = 0; wb_if[1].ack = 0; wb_if[2].ack = 0; wb_if[3].ack = 0;
    single_if.ack = 0;
    single_if.irq = 0;
    #START;
    $display("\n---- [PART 4] interface array + generic interface port ----");
    @(posedge clk);
    wb_if[0].ack <= 1;  wb_if[2].ack <= 1;  single_if.ack <= 1;
    repeat (2) @(posedge clk);
    #1;
    $display("[%0t] [PART 4] gnt[3:0] = %0b%0b%0b%0b   single_if.irq = %0d",
             $time, wb_if[3].gnt, wb_if[2].gnt, wb_if[1].gnt, wb_if[0].gnt, single_if.irq);
    wb_if[0].ack <= 0;  wb_if[2].ack <= 0;  single_if.ack <= 0;
    repeat (2) @(posedge clk);
    $display("---- [PART 4] done ----");
  end
endmodule


//============================================================================
// [PART 5] CLOCKING BLOCK SKEWS
//   direction is from the TESTBENCH point of view:
//     design output (gnt)  -> clocking INPUT  (TB samples)
//     design input  (req)  -> clocking OUTPUT (TB drives)
//============================================================================
interface skew_if (input logic clk);
  logic       req;
  logic       req_n;
  logic       sig;
  logic [3:0] gnt;

  // ---- OUTPUT skews ----
  clocking cb_o0 @(posedge clk); output #0ns req; endclocking   // #0   => Re-NBA, same edge (NOT "no delay")
  clocking cb_o1 @(posedge clk); output #2ns req; endclocking   // 2ns after posedge
  clocking cb_o2 @(posedge clk); output #5ns req; endclocking   // 5ns after posedge

  // ---- INPUT skews ----
  clocking cb_i0 @(posedge clk); input #0     gnt; endclocking  // sampled at posedge, Observed region
  clocking cb_i1 @(posedge clk); input #1step gnt; endclocking  // Preponed region (race-free, preferred)
  clocking cb_i2 @(posedge clk); input #1ns   gnt; endclocking  // 1ns BEFORE posedge
  clocking cb_i3 @(posedge clk); input #2ns   gnt; endclocking  // 2ns BEFORE posedge

  // ---- default skew + negedge drive + alias ----
  clocking cb_x @(posedge clk);
    default input #1step output #2ns;
    input  gnt;
    input  gnt_alias = gnt;        // alias: local name for another signal
    output negedge req_n;          // driven on the falling edge instead of after a delay
  endclocking

  // ---- one signal with both an input and an output skew ----
  clocking cb_io @(posedge clk);   // bare numbers follow the file's `timescale (1ns here)
    input #1 output #3 sig;        // sample 1 unit before, drive 3 units after
  endclocking
endinterface

module tb_skew #(parameter time START = 0);
  logic clk = 0;
  always #5 clk = ~clk;            // 10ns period
  skew_if sif (clk);

  real t_edge;
  always @(posedge clk) t_edge = $realtime;

  // print how long after the last posedge each output actually moved
  always @(sif.req)   $display("[%0t] [PART 5] req   -> %0b  (+%0.1f ns after posedge)", $time, sif.req,   $realtime - t_edge);
  always @(sif.req_n) $display("[%0t] [PART 5] req_n -> %0b  (+%0.1f ns after posedge)", $time, sif.req_n, $realtime - t_edge);
  always @(sif.sig)   $display("[%0t] [PART 5] sig   -> %0b  (+%0.1f ns after posedge)", $time, sif.sig,   $realtime - t_edge);

  // gnt changes 1.5ns BEFORE every posedge, so the input skews give different answers
  initial begin
    sif.gnt = 0;
    forever begin
      @(negedge clk);
      #3.5 sif.gnt = sif.gnt + 1;
    end
  end

  bit show;
  always @(posedge clk) if (show) begin
    #1;
    $display("[%0t] [PART 5] raw=%0d | #0=%0d  #1step=%0d  #1ns=%0d  #2ns=%0d | cb_x.gnt=%0d alias=%0d",
             $time, sif.gnt,
             sif.cb_i0.gnt, sif.cb_i1.gnt, sif.cb_i2.gnt, sif.cb_i3.gnt,
             sif.cb_x.gnt,  sif.cb_x.gnt_alias);
  end

  initial begin
    #START;
    $display("\n---- [PART 5] clocking block skews ----");
    $display("-- output skews: #0 (cb_o0), #2ns (cb_o1), #5ns (cb_o2) --");
    @(posedge clk); sif.cb_o0.req <= 1;
    @(posedge clk); sif.cb_o0.req <= 0;
    @(posedge clk); sif.cb_o1.req <= 1;
    @(posedge clk); sif.cb_o1.req <= 0;
    @(posedge clk); sif.cb_o2.req <= 1;
    @(posedge clk); sif.cb_o2.req <= 0;

    $display("-- negedge output (cb_x.req_n) and inout-style skew (cb_io.sig) --");
    @(posedge clk); sif.cb_x.req_n <= 1;
    @(posedge clk); sif.cb_io.sig  <= 1;

    $display("-- input skews --");
    @(posedge clk); show = 1;
    repeat (4) @(posedge clk);
    show = 0;
    $display("---- [PART 5] done ----");
  end
endmodule


//============================================================================
// [PART 6] CLOCKING BLOCK + MODPORT + VIRTUAL INTERFACE
//   - modport exposes the clocking block, so classes drive through it
//   - a class cannot hold signals, only a HANDLE (virtual interface)
//============================================================================
interface req_gnt_if (input logic clk);
  logic req;
  logic gnt;
  logic rstn;

  clocking cb @(posedge clk);                  // driver view
    default input #1step output #2ns;
    output req;                                // TB drives it   -> output
    input  gnt;                                // TB reads it    -> input
  endclocking

  clocking mcb @(posedge clk);                 // monitor view: everything is input
    default input #1step;
    input req, gnt;
  endclocking

  modport TB  (clocking cb,  output rstn);
  modport MON (clocking mcb, input  rstn);
endinterface

class Driver;
  virtual req_gnt_if.TB vif;                   // handle only - no signals of its own

  function new (virtual req_gnt_if.TB vif);
    this.vif = vif;
  endfunction

  task drive_req (bit value);
    vif.cb.req <= value;                       // drive through the clocking block
  endtask
endclass

class Monitor;
  virtual req_gnt_if.MON vif;

  function new (virtual req_gnt_if.MON vif);
    this.vif = vif;
  endfunction

  task run (int n);
    repeat (n) begin
      @(vif.mcb);                              // wait for the clocking event
      $display("[%0t] [PART 6] MON  rstn=%0b req=%0b gnt=%0b",
               $time, vif.rstn, vif.mcb.req, vif.mcb.gnt);
    end
  endtask
endclass

// DUT
module des (input logic clk, req, rstn, output logic gnt);
  always @(posedge clk or negedge rstn)
    if (!rstn) gnt <= 0;
    else       gnt <= req;
endmodule

module tb_vif #(parameter time START = 0);
  logic clk = 0;
  always #10 clk = ~clk;

  req_gnt_if vif (.clk(clk));
  des dut (.clk(clk), .req(vif.req), .rstn(vif.rstn), .gnt(vif.gnt));

  Driver  drv;
  Monitor mon;

  initial begin
    #START;
    $display("\n---- [PART 6] clocking + modport + virtual interface ----");
    vif.rstn <= 0;

    // the physical instance 'vif' is converted to a virtual interface handle here
    drv = new (vif);
    mon = new (vif);
    fork
      mon.run(12);
    join_none

    drv.drive_req(0);
    repeat (3) @(posedge clk);
    vif.rstn <= 1;

    repeat (2) @(posedge clk);
    drv.drive_req(1);
    repeat (2) @(posedge clk);
    drv.drive_req(0);
    repeat (5) @(posedge clk);
    $display("---- [PART 6] done ----");
  end
endmodule


//============================================================================
// [PART 7] IMPLICIT PORT CONNECTIONS
//============================================================================
module alu (input  logic [7:0] ain, bin,
            input  logic [1:0] opcode,
            output logic [7:0] alu_out,
            output logic       zero);
  always_comb begin
    case (opcode)
      2'd0:    alu_out = ain + bin;
      2'd1:    alu_out = ain - bin;
      2'd2:    alu_out = ain & bin;
      default: alu_out = ain | bin;
    endcase
    zero = (alu_out == 0);
  end
endmodule

// input with a default value
module dflt_mod (input  logic rst_n = 1'b1,
                 output logic rst_level);
  assign rst_level = rst_n;
endmodule

// `.name` : same as .ain(ain), .bin(bin) ...
module demo_dot_name #(parameter time START = 0);
  logic [7:0] ain, bin, alu_out;
  logic [1:0] opcode;
  logic       zero;

  alu a0 (.alu_out, .zero, .ain, .bin, .opcode);

  initial begin
    #START;
    $display("\n---- [PART 7a] .name shorthand ----");
    ain = 8'd5; bin = 8'd3; opcode = 2'd0;
    #1 $display("[%0t] [PART 7a] 5 + 3 = %0d zero=%0b", $time, alu_out, zero);
    opcode = 2'd1; ain = 8'd3;
    #1 $display("[%0t] [PART 7a] 3 - 3 = %0d zero=%0b", $time, alu_out, zero);
  end
endmodule

// `.*` : wildcard, with overrides listed explicitly
module demo_dot_star #(parameter time START = 0);
  logic [7:0] ain_reg, bin, alu_out;
  logic [1:0] opcode;
  logic       rst_level;                       // NOTE: no 'rst_n' signal exists here

  alu a1 (.zero  (),                           // leave this output unconnected
          .ain   (ain_reg),                    // differently named signal
          .*);                                 // alu_out, bin, opcode connect by name

  // .*  -> rst_n is not matched, so the DEFAULT value 1'b1 is used
  // .rst_n would be an elaboration error (implicit named never uses the default)
  dflt_mod d0 (.*);

  initial begin
    #(START + 5);
    $display("\n---- [PART 7b] .* wildcard ----");
    ain_reg = 8'hF0; bin = 8'h3C; opcode = 2'd2;
    #1 $display("[%0t] [PART 7b] F0 & 3C = 0x%0h   rst_level (default) = %0b", $time, alu_out, rst_level);
    opcode = 2'd3;
    #1 $display("[%0t] [PART 7b] F0 | 3C = 0x%0h", $time, alu_out);
  end
endmodule

module tb_implicit #(parameter time START = 0);
  demo_dot_name #(.START(START)) d_name ();
  demo_dot_star #(.START(START)) d_star ();
endmodule


//============================================================================
// TOP - starts each demo at a different time
//============================================================================
module top;
  tb_counter  #(.START(0))    t1 ();
  tb_ms       #(.START(500))  t2 ();
  tb_shared   #(.START(1000)) t3 ();
  tb_array    #(.START(1500)) t4 ();
  tb_skew     #(.START(2000)) t5 ();
  tb_vif      #(.START(3000)) t6 ();
  tb_implicit #(.START(4000)) t7 ();

  initial $timeformat(-9, 1, " ns", 0);
  initial begin
    #5000;
    $finish;
  end
endmodule