module pc (
    input wire clk,
    input wire rst,
    input wire [31:0] pc_next,
    output reg [31:0] pc_out
);
    // Luôn cập nhật ở sườn lên của clock. Nếu có reset, đưa về 0.
    always @(posedge clk or posedge rst) begin
        if (rst)
            pc_out <= 32'h00000000;
        else
            pc_out <= pc_next;
    end
endmodule