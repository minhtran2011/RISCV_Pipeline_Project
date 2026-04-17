`timescale 1ns / 1ps

module tb_riscv_top();

    // 1. Khai báo tín hiệu kích thích (Inputs)
    reg clk;
    reg rst;

    // 2. Khai báo tín hiệu quan sát (Outputs)
    // Tầng IF/ID
    wire [31:0] state_ifid_pc;
    wire [31:0] state_ifid_instr;

    // Tầng ID/EX
    wire [31:0] state_idex_pc;
    wire [31:0] state_idex_rs1_data;
    wire [31:0] state_idex_rs2_data;
    wire [31:0] state_idex_imm;
    wire [4:0]  state_idex_rd;
    wire [1:0]  state_idex_alu_op;
    wire        state_idex_reg_write;
    wire        state_idex_mem_to_reg;

    // Tầng EX/MEM
    wire [31:0] state_exmem_pc;           
    wire [31:0] state_exmem_alu_result;
    wire [31:0] state_exmem_rs2_data;
    wire [4:0]  state_exmem_rd;
    wire        state_exmem_zero;
    wire        state_exmem_reg_write;
    wire        state_exmem_mem_write;

    // Tầng MEM/WB
    wire [31:0] state_memwb_pc;           
    wire [31:0] state_memwb_alu_result;
    wire [31:0] state_memwb_read_data;
    wire [4:0]  state_memwb_rd;
    wire        state_memwb_reg_write;
    wire        state_memwb_mem_to_reg;

    // Dữ liệu Write Back
    wire [31:0] state_final_write_data;

    // 3. Khởi tạo Bo mạch chủ (Instantiate Top-Level)
    riscv_top uut (
        .clk(clk),
        .rst(rst),
        
        // Outputs từ IF/ID
        .state_ifid_pc(state_ifid_pc),
        .state_ifid_instr(state_ifid_instr),
        
        // Outputs từ ID/EX
        .state_idex_pc(state_idex_pc),
        .state_idex_rs1_data(state_idex_rs1_data),
        .state_idex_rs2_data(state_idex_rs2_data),
        .state_idex_imm(state_idex_imm),
        .state_idex_rd(state_idex_rd),
        .state_idex_alu_op(state_idex_alu_op),
        .state_idex_reg_write(state_idex_reg_write),
        .state_idex_mem_to_reg(state_idex_mem_to_reg),
        
        // Outputs từ EX/MEM
        .state_exmem_pc(state_exmem_pc),           // === ĐÃ THÊM ===
        .state_exmem_alu_result(state_exmem_alu_result),
        .state_exmem_rs2_data(state_exmem_rs2_data),
        .state_exmem_rd(state_exmem_rd),
        .state_exmem_zero(state_exmem_zero),
        .state_exmem_reg_write(state_exmem_reg_write),
        .state_exmem_mem_write(state_exmem_mem_write),
        
        // Outputs từ MEM/WB
        .state_memwb_pc(state_memwb_pc),           // === ĐÃ THÊM ===
        .state_memwb_alu_result(state_memwb_alu_result),
        .state_memwb_read_data(state_memwb_read_data),
        .state_memwb_rd(state_memwb_rd),
        .state_memwb_reg_write(state_memwb_reg_write),
        .state_memwb_mem_to_reg(state_memwb_mem_to_reg),
        
        // Final write back data
        .state_final_write_data(state_final_write_data)
    );

    // 4. Tạo Xung Nhịp Clock (Chu kỳ 20ns)
    initial begin
        clk = 0;
        forever #10 clk = ~clk; 
    end

    // 5. Kịch bản chạy mô phỏng
    initial begin
        // Dọn dẹp hệ thống
        rst = 1; 
        #25; 
        rst = 0;
        
        // =======================================================
        // UNIT TEST 1: Kiểm tra lệnh ADDI (x1 = 10)
        // =======================================================
        wait (state_memwb_rd == 5'd1 && state_memwb_reg_write == 1'b1);
        #1; // Đợi 1ns cho tín hiệu ổn định
        if (state_final_write_data == 32'd10)
            $display("[PASS] Unit Test 1 - ADDI x1: Thanh cong! Gia tri = %0d", state_final_write_data);
        else
            $display("[FAIL] Unit Test 1 - ADDI x1: LOI! Mong doi 10, nhung nhan duoc = %0d", state_final_write_data);

        // =======================================================
        // UNIT TEST 2: Kiểm tra lệnh ADD (x3 = x1 + x2 = 30)
        // =======================================================
        wait (state_memwb_rd == 5'd3 && state_memwb_reg_write == 1'b1);
        #1;
        if (state_final_write_data == 32'd30)
            $display("[PASS] Unit Test 2 - ADD x3: Thanh cong! Gia tri = %0d", state_final_write_data);
        else
            $display("[FAIL] Unit Test 2 - ADD x3: LOI! Mong doi 30, nhung nhan duoc = %0d", state_final_write_data);

        // =======================================================
        // UNIT TEST 3: Kiểm tra lệnh Rẽ nhánh BEQ (x5 = 60)
        // =======================================================
        wait (state_memwb_rd == 5'd5 && state_memwb_reg_write == 1'b1);
        #1;
        if (state_final_write_data == 32'd60)
            $display("[PASS] Unit Test 3 - BEQ Branching: Thanh cong! PC da nhay dung.");
        else
            $display("[FAIL] Unit Test 3 - BEQ Branching: LOI! Chua nhay qua lenh 50.");

        #100;
        $stop;
    end

endmodule