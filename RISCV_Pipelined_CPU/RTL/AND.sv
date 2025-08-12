module AND (
    input   branch,
    input   zero,
    output  and_o
);

assign and_o = branch & zero;

endmodule