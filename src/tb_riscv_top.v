`timescale 1ns / 1ps

module tb_riscv_top();

    // 1. Khai báo tín hiệu giả lập
    reg clk;
    reg rst;

    // 2. Gọi bộ vi xử lý (Unit Under Test - UUT) ra để test
    riscv_top uut (
        .clk(clk),
        .rst(rst)
    );

    // 3. Tạo xung Clock (Chu kỳ 10ns -> Tần số 100MHz)
    always #5 clk = ~clk;

    // 4. Kịch bản test
    initial begin
        // Khởi tạo trạng thái ban đầu
        clk = 0;
        rst = 1; // Bấm giữ nút Reset
        
        // Chờ 20ns rồi nhả nút Reset ra để vi xử lý bắt đầu chạy
        #20;
        rst = 0;

        // Cho vi xử lý chạy trong 200ns (khoảng 20 chu kỳ clock) rồi dừng
        #200;
        $stop;
    end

endmodule