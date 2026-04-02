module alu (
    input wire [31:0] src_a,       // Toán hạng 1
    input wire [31:0] src_b,       // Toán hạng 2
    input wire [3:0] alu_ctrl,     // Tín hiệu điều khiển ALU
    output reg [31:0] alu_result,  // Kết quả tính toán
    output wire zero_flag          // Cờ Zero (Bằng 1 nếu kết quả = 0)
);

    // Khối always @(*) đại diện cho một mạch tổ hợp (Combinational Logic).
    // Bất cứ khi nào input thay đổi, kết quả sẽ được tính toán lại ngay lập tức.
    always @(*) begin
        case (alu_ctrl)
            4'b0000: alu_result = src_a & src_b; // Phép AND
            4'b0001: alu_result = src_a | src_b; // Phép OR
            4'b0010: alu_result = src_a + src_b; // Phép CỘNG (ADD)
            4'b0110: alu_result = src_a - src_b; // Phép TRỪ (SUB)
            4'b0111: alu_result = ($signed(src_a) < $signed(src_b)) ? 32'b1 : 32'b0; // Phép SLT (Set Less Than có dấu)
            default: alu_result = 32'b0;         // Trạng thái mặc định
        endcase
    end

    // Dùng lệnh assign để gán liên tục. Cờ Zero rất quan trọng cho các lệnh nhảy có điều kiện (Branch).
    assign zero_flag = (alu_result == 32'b0) ? 1'b1 : 1'b0;

endmodule