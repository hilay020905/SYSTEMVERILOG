interface and_if;
    logic a, b, y;
endinterface

module and_block(
    and_if aif
);

assign aif.y = aif.a & aif.b;

endmodule