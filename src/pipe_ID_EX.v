module pipe_ID_EX (
    input wire clk, rst,
    // Tín hiệu điều khiển
    input wire reg_write_in, mem_to_reg_in, mem_read_in, mem_write_in, alu_src_in, branch_in,
    input wire [1:0] alu_op_in,
    // Dữ liệu
    input wire [31:0] pc_in, rs1_data_in, rs2_data_in, imm_in, instr_in,
    
    // Đầu ra
    output reg reg_write_out, mem_to_reg_out, mem_read_out, mem_write_out, alu_src_out, branch_out,
    output reg [1:0] alu_op_out,
    output reg [31:0] pc_out, rs1_data_out, rs2_data_out, imm_out, instr_out
);
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            reg_write_out <= 0; mem_to_reg_out <= 0; mem_read_out <= 0; mem_write_out <= 0;
            alu_src_out <= 0; branch_out <= 0; alu_op_out <= 0;
            pc_out <= 0; rs1_data_out <= 0; rs2_data_out <= 0; imm_out <= 0; instr_out <= 0;
        end else begin
            reg_write_out <= reg_write_in; mem_to_reg_out <= mem_to_reg_in; 
            mem_read_out <= mem_read_in; mem_write_out <= mem_write_in;
            alu_src_out <= alu_src_in; branch_out <= branch_in; alu_op_out <= alu_op_in;
            pc_out <= pc_in; rs1_data_out <= rs1_data_in; rs2_data_out <= rs2_data_in; 
            imm_out <= imm_in; instr_out <= instr_in;
        end
    end
endmodule