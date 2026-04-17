module pipe_MEM_WB (
    input wire clk, rst,
    // Tín hiệu điều khiển
    input wire reg_write_in, mem_to_reg_in,
    // Dữ liệu
    input wire [31:0] read_data_in, alu_result_in,
    input wire [4:0] rd_addr_in,
	 input wire [31:0] pc_in,

    // Đầu ra
    output reg reg_write_out, mem_to_reg_out,
    output reg [31:0] read_data_out, alu_result_out,
    output reg [4:0] rd_addr_out,
	 output reg [31:0] pc_out
);
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            reg_write_out <= 0; mem_to_reg_out <= 0;
            read_data_out <= 0; alu_result_out <= 0; rd_addr_out <= 0;
				pc_out <= 0;
        end else begin
            reg_write_out <= reg_write_in; mem_to_reg_out <= mem_to_reg_in;
            read_data_out <= read_data_in; alu_result_out <= alu_result_in; rd_addr_out <= rd_addr_in;
				pc_out <= pc_in;
        end
    end
endmodule