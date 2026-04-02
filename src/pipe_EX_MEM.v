module pipe_EX_MEM (
    input wire clk, rst,
    // Tín hiệu điều khiển
    input wire reg_write_in, mem_to_reg_in, mem_read_in, mem_write_in, branch_in,
    // Dữ liệu
    input wire [31:0] branch_target_in, alu_result_in, rs2_data_in,
    input wire zero_flag_in,
    input wire [4:0] rd_addr_in,

    // Đầu ra
    output reg reg_write_out, mem_to_reg_out, mem_read_out, mem_write_out, branch_out,
    output reg [31:0] branch_target_out, alu_result_out, rs2_data_out,
    output reg zero_flag_out,
    output reg [4:0] rd_addr_out
);
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            reg_write_out <= 0; mem_to_reg_out <= 0; mem_read_out <= 0; mem_write_out <= 0; branch_out <= 0;
            branch_target_out <= 0; alu_result_out <= 0; rs2_data_out <= 0;
            zero_flag_out <= 0; rd_addr_out <= 0;
        end else begin
            reg_write_out <= reg_write_in; mem_to_reg_out <= mem_to_reg_in;
            mem_read_out <= mem_read_in; mem_write_out <= mem_write_in; branch_out <= branch_in;
            branch_target_out <= branch_target_in; alu_result_out <= alu_result_in; rs2_data_out <= rs2_data_in;
            zero_flag_out <= zero_flag_in; rd_addr_out <= rd_addr_in;
        end
    end
endmodule