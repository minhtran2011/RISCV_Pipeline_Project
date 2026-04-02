module imm_gen (
    input wire [31:0] instruction,
    output reg [31:0] imm_out
);
    wire [6:0] opcode = instruction[6:0];

    always @(*) begin
        case (opcode)
            // Lệnh định dạng I (I-type): addi, lw...
            7'b0010011, 7'b0000011: 
                imm_out = {{20{instruction[31]}}, instruction[31:20]};
            
            // Lệnh định dạng S (S-type): sw...
            7'b0100011: 
                imm_out = {{20{instruction[31]}}, instruction[31:25], instruction[11:7]};
            
            // Lệnh định dạng B (B-type): beq, bne...
            7'b1100011: 
                imm_out = {{20{instruction[31]}}, instruction[7], instruction[30:25], instruction[11:8], 1'b0};
            
            // Lệnh định dạng J (J-type): jal...
            7'b1101111: 
                imm_out = {{12{instruction[31]}}, instruction[19:12], instruction[20], instruction[30:21], 1'b0};
            
            // Lệnh định dạng U (U-type): lui, auipc...
            7'b0110111, 7'b0010111: 
                imm_out = {instruction[31:12], 12'b0};
            
            default: imm_out = 32'b0;
        endcase
    end
endmodule