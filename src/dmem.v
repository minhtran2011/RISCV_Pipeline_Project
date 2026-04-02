module dmem (
    input wire clk,
    input wire mem_write_en,
    input wire mem_read_en,
    input wire [31:0] alu_addr,
    input wire [31:0] write_data,
    output wire [31:0] read_data
);
    reg [31:0] ram [0:1023];

    // Đọc dữ liệu bất đồng bộ
    assign read_data = (mem_read_en) ? ram[alu_addr >> 2] : 32'b0;

    // Ghi dữ liệu đồng bộ theo xung nhịp
    always @(posedge clk) begin
        if (mem_write_en) begin
            ram[alu_addr >> 2] <= write_data;
        end
    end
endmodule