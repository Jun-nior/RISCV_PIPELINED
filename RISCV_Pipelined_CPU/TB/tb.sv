module CPU_Top_tb_top;

    logic clk, rst_n;

    CPU_Top dut (
        .clk(clk),
        .rst_n(rst_n)
    );

    initial begin
        clk = 0;
        forever begin
            #5 clk = ~clk;
        end
    end

    initial begin
        rst_n = 0;
        repeat(2) begin
            @(posedge clk);
        end
        rst_n = 1;


        repeat(15) begin
            @(posedge clk);
        end
        $finish;
    end

endmodule