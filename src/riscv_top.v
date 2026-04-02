module riscv_top (
    input wire clk,
    input wire rst
);

    // =========================================================
    // KHAI BÁO WIRE ĐỊNH TUYẾN (ROUTING WIRES)
    // =========================================================
    // Tầng IF
    wire [31:0] pc_next, pc_if, pc_plus_4_if, instr_if;
    
    // Tầng ID (Sau IF_ID reg)
    wire [31:0] pc_id, instr_id;
    wire ctrl_branch, ctrl_mem_read, ctrl_mem_to_reg, ctrl_mem_write, ctrl_alu_src, ctrl_reg_write;
    wire [1:0] ctrl_alu_op;
    wire [31:0] rs1_data_id, rs2_data_id, imm_id;

    // Tầng EX (Sau ID_EX reg)
    wire ex_reg_write, ex_mem_to_reg, ex_mem_read, ex_mem_write, ex_branch, ex_alu_src;
    wire [1:0] ex_alu_op;
    wire [31:0] pc_ex, rs1_data_ex, rs2_data_ex, imm_ex, instr_ex;
    wire [31:0] alu_src_b;
    wire [3:0] alu_ctrl_ex;
    wire [31:0] alu_result_ex, branch_target_ex;
    wire zero_flag_ex;

    // Tầng MEM (Sau EX_MEM reg)
    wire mem_reg_write, mem_mem_to_reg, mem_mem_read, mem_mem_write, mem_branch;
    wire [31:0] branch_target_mem, alu_result_mem, rs2_data_mem;
    wire zero_flag_mem;
    wire [4:0] rd_addr_mem;
    wire pc_src; // Tín hiệu quyết định có nhảy hay không
    wire [31:0] read_data_mem;

    // Tầng WB (Sau MEM_WB reg)
    wire wb_reg_write, wb_mem_to_reg;
    wire [31:0] read_data_wb, alu_result_wb;
    wire [4:0] rd_addr_wb;
    wire [31:0] write_data_wb;

    // =========================================================
    // STAGE 1: INSTRUCTION FETCH (IF)
    // =========================================================
    assign pc_plus_4_if = pc_if + 32'd4;
    assign pc_next = (pc_src) ? branch_target_mem : pc_plus_4_if; // MUX chọn địa chỉ PC tiếp theo

    pc u_pc (.clk(clk), .rst(rst), .pc_next(pc_next), .pc_out(pc_if));
    imem u_imem (.pc_addr(pc_if), .instruction(instr_if));

    pipe_IF_ID u_pipe_IF_ID (
        .clk(clk), .rst(rst),
        .pc_in(pc_if), .instr_in(instr_if),
        .pc_out(pc_id), .instr_out(instr_id)
    );

    // =========================================================
    // STAGE 2: INSTRUCTION DECODE (ID)
    // =========================================================
    control_unit u_control (
        .opcode(instr_id[6:0]),
        .branch(ctrl_branch), .mem_read(ctrl_mem_read), .mem_to_reg(ctrl_mem_to_reg),
        .alu_op(ctrl_alu_op), .mem_write(ctrl_mem_write), .alu_src(ctrl_alu_src), .reg_write(ctrl_reg_write)
    );

    regfile u_regfile (
        .clk(clk), 
        .reg_write_en(wb_reg_write),      // Nối vòng từ tầng WB về
        .rs1_addr(instr_id[19:15]), .rs2_addr(instr_id[24:20]), .rd_addr(rd_addr_wb),
        .write_data(write_data_wb),       // Dữ liệu từ tầng WB
        .rs1_data(rs1_data_id), .rs2_data(rs2_data_id)
    );

    imm_gen u_imm_gen (.instruction(instr_id), .imm_out(imm_id));

    pipe_ID_EX u_pipe_ID_EX (
        .clk(clk), .rst(rst),
        .reg_write_in(ctrl_reg_write), .mem_to_reg_in(ctrl_mem_to_reg), .mem_read_in(ctrl_mem_read), 
        .mem_write_in(ctrl_mem_write), .alu_src_in(ctrl_alu_src), .branch_in(ctrl_branch), .alu_op_in(ctrl_alu_op),
        .pc_in(pc_id), .rs1_data_in(rs1_data_id), .rs2_data_in(rs2_data_id), .imm_in(imm_id), .instr_in(instr_id),
        
        .reg_write_out(ex_reg_write), .mem_to_reg_out(ex_mem_to_reg), .mem_read_out(ex_mem_read), 
        .mem_write_out(ex_mem_write), .alu_src_out(ex_alu_src), .branch_out(ex_branch), .alu_op_out(ex_alu_op),
        .pc_out(pc_ex), .rs1_data_out(rs1_data_ex), .rs2_data_out(rs2_data_ex), .imm_out(imm_ex), .instr_out(instr_ex)
    );

    // =========================================================
    // STAGE 3: EXECUTE (EX)
    // =========================================================
    assign branch_target_ex = pc_ex + imm_ex; // Bộ cộng tính địa chỉ nhảy (Branch Adder)
    assign alu_src_b = (ex_alu_src) ? imm_ex : rs2_data_ex; // MUX chọn đầu vào ALU

    // ALU Control Logic (Tổ hợp giải mã ALU)
    assign alu_ctrl_ex = (ex_alu_op == 2'b00) ? 4'b0010 : // Lw/Sw -> ADD
                         (ex_alu_op == 2'b01) ? 4'b0110 : // Branch -> SUB
                         (ex_alu_op == 2'b10 && instr_ex[14:12] == 3'b000 && instr_ex[30] == 1'b0) ? 4'b0010 : // ADD
                         (ex_alu_op == 2'b10 && instr_ex[14:12] == 3'b000 && instr_ex[30] == 1'b1) ? 4'b0110 : // SUB
                         (ex_alu_op == 2'b10 && instr_ex[14:12] == 3'b111) ? 4'b0000 : // AND
                         (ex_alu_op == 2'b10 && instr_ex[14:12] == 3'b110) ? 4'b0001 : // OR
                         (ex_alu_op == 2'b10 && instr_ex[14:12] == 3'b010) ? 4'b0111 : 4'b0000; // SLT

    alu u_alu (
        .src_a(rs1_data_ex), .src_b(alu_src_b), .alu_ctrl(alu_ctrl_ex),
        .alu_result(alu_result_ex), .zero_flag(zero_flag_ex)
    );

    pipe_EX_MEM u_pipe_EX_MEM (
        .clk(clk), .rst(rst),
        .reg_write_in(ex_reg_write), .mem_to_reg_in(ex_mem_to_reg), .mem_read_in(ex_mem_read), 
        .mem_write_in(ex_mem_write), .branch_in(ex_branch),
        .branch_target_in(branch_target_ex), .alu_result_in(alu_result_ex), .rs2_data_in(rs2_data_ex),
        .zero_flag_in(zero_flag_ex), .rd_addr_in(instr_ex[11:7]),

        .reg_write_out(mem_reg_write), .mem_to_reg_out(mem_mem_to_reg), .mem_read_out(mem_mem_read), 
        .mem_write_out(mem_mem_write), .branch_out(mem_branch),
        .branch_target_out(branch_target_mem), .alu_result_out(alu_result_mem), .rs2_data_out(rs2_data_mem),
        .zero_flag_out(zero_flag_mem), .rd_addr_out(rd_addr_mem)
    );

    // =========================================================
    // STAGE 4: MEMORY ACCESS (MEM)
    // =========================================================
    // Cổng AND quyết định nhảy (Nếu là lệnh Branch VÀ kết quả ALU bằng 0)
    assign pc_src = mem_branch & zero_flag_mem; 

    dmem u_dmem (
        .clk(clk), .mem_write_en(mem_mem_write), .mem_read_en(mem_mem_read),
        .alu_addr(alu_result_mem), .write_data(rs2_data_mem), .read_data(read_data_mem)
    );

    pipe_MEM_WB u_pipe_MEM_WB (
        .clk(clk), .rst(rst),
        .reg_write_in(mem_reg_write), .mem_to_reg_in(mem_mem_to_reg),
        .read_data_in(read_data_mem), .alu_result_in(alu_result_mem), .rd_addr_in(rd_addr_mem),

        .reg_write_out(wb_reg_write), .mem_to_reg_out(wb_mem_to_reg),
        .read_data_out(read_data_wb), .alu_result_out(alu_result_wb), .rd_addr_out(rd_addr_wb)
    );

    // =========================================================
    // STAGE 5: WRITE BACK (WB)
    // =========================================================
    // MUX chọn dữ liệu ghi về thanh ghi: Từ RAM (Load) hay từ ALU (R-type)
    assign write_data_wb = (wb_mem_to_reg) ? read_data_wb : alu_result_wb;

endmodule