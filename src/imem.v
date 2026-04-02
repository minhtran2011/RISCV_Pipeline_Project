module imem (
    input wire [31:0] pc_addr,
    output wire [31:0] instruction
);
    // Bộ nhớ 1024 ô, mỗi ô 32-bit (Tổng: 4KB)
    reg [31:0] rom [0:1023];

    // Đọc mã máy từ file program.hex (bạn sẽ tạo file này sau để test)
    initial begin
        $readmemh("E:/2025.2/KTMTNC/BTL/program.hex", rom);
    end

    // Đọc dữ liệu ngay lập tức (Combinational)
    assign instruction = rom[pc_addr >> 2];
endmodule