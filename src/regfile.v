module regfile (
    input wire clk,                 // Xung nhịp đồng bộ
    input wire reg_write_en,        // Tín hiệu cho phép ghi từ Control Unit
    input wire [4:0] rs1_addr,      // Địa chỉ thanh ghi nguồn 1 (5 bit = 32 thanh ghi)
    input wire [4:0] rs2_addr,      // Địa chỉ thanh ghi nguồn 2
    input wire [4:0] rd_addr,       // Địa chỉ thanh ghi đích (nơi ghi kết quả)
    input wire [31:0] write_data,   // Dữ liệu cần ghi vào thanh ghi đích
    output wire [31:0] rs1_data,    // Dữ liệu đọc ra từ rs1
    output wire [31:0] rs2_data     // Dữ liệu đọc ra từ rs2
);

    // Khai báo tập hợp 32 thanh ghi, mỗi thanh ghi 32-bit
    reg [31:0] registers [0:31];
    integer i;

    // Khởi tạo tất cả thanh ghi bằng 0 (Giúp ích rất nhiều khi mô phỏng)
    initial begin
        for (i = 0; i < 32; i = i + 1) begin
            registers[i] = 32'b0;
        end
    end

    // Mạch đọc (Combinational): Đọc thanh ghi số 0 luôn trả về 0
    assign rs1_data = (rs1_addr == 5'b0) ? 32'b0 : registers[rs1_addr];
    assign rs2_data = (rs2_addr == 5'b0) ? 32'b0 : registers[rs2_addr];

    // Mạch ghi (Sequential): Chỉ ghi ở sườn lên của clock
    always @(posedge clk) begin
        // Kiểm tra tín hiệu cho phép ghi và đảm bảo không ghi đè lên x0
        if (reg_write_en && (rd_addr != 5'b0)) begin
            registers[rd_addr] <= write_data;
        end
    end

endmodule